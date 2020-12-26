//
//  Command.swift
//  Talon
//
//  Created by Mike on 1/29/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation
import GEOSwift

public protocol CommandProtocol {
    var command: Command { get }
}

public protocol CommandOK: CommandProtocol {}
public protocol CommandBounds: CommandProtocol {}
public protocol CommandKeys: CommandProtocol {}
public protocol CommandStats: CommandProtocol {}
public protocol CommandTTL: CommandProtocol {}

/// Base class for all supported commands. Subclasses are responsible for
/// providing the command name and an array of values that when combined can
/// be joined together to construct the HTTP path for the command.
public struct Command {
    public struct Coordinate {
        let lat: Double
        let lon: Double
        public init(lat: Double, lon: Double) {
            self.lat = lat
            self.lon = lon
        }
    }
    
    public enum Shape {
        case bounds(swCoordinate: Command.Coordinate, neCoordinate: Command.Coordinate)
        case object(geoJSON: GeoJSON)
    }

    public struct ObjectList {
        public struct Where {
            public let field: String
            public let min: Double
            public let max: Double
            var asString: String {
                return "WHERE \(field) \(min) \(max)"
            }
        }

        public struct WhereIn {
            public let field: String
            public let values: [Double]
            var asString: String {
                let stringValues = values.compactMap { "\($0)" }
                return "WHEREIN \(field) \(values.count) \(stringValues))"
            }
        }

        public enum Format {
            case objects
            case points
            case bounds
            case hash(Int)
            var string: String {
                switch self {
                case .objects:
                    return "OBJECTS"
                case .points:
                    return "POINTS"
                case .bounds:
                    return "BOUNDS"
                case .hash(let val):
                    // Hash val must be between 1 and 22.
                    guard val >= 1 else {
                        return "HASH 1"
                    }
                    guard val <= 22 else {
                        return "HASH 22"
                    }
                    return "HASH \(val)"
                }
            }
        }

        public struct Options {
            // Options added here must be handled by values(for options:)
            public var cursor: Int?
            public var limit: Int?
            public var ids: Bool?
            public var sparse: Int?
            public var match: [String]?
            public var whereFilters: [Where]?
            public var whereInFilters: [WhereIn]?
            public var noFields: Bool?
            public var format: Command.ObjectList.Format?
            public init() {}
        }

        static func values(for shape: Command.Shape) -> [String] {
            var values: [String] = []
            switch shape {
            case .bounds(let swCoordinate, let neCoordinate):
                values.append(contentsOf: ["BOUNDS", "\(swCoordinate.lat)", "\(swCoordinate.lon)", "\(neCoordinate.lat)", "\(neCoordinate.lon)"])
            case .object(let geoJSON):
                values.append(contentsOf: ["OBJECT", geoJSON.JSONString])
            }
            return values
        }

        static func values(for options: Command.ObjectList.Options) -> [String] {
            var values: [String] = []
            if let cursor = options.cursor {
                let string = "CURSOR \(cursor)"
                values.append(string)
            }
            if let limit = options.limit {
                if options.sparse == nil {
                    let string = "LIMIT \(limit)"
                    values.append(string)
                } else {
                    print("LIMIT option ignored when SPARSE value is set")
                }
            }
            if let _ = options.ids {
                values.append("IDS")
            }
            if let sparse = options.sparse {
                values.append(contentsOf: ["SPARSE \(sparse)"])
            }
            if let matchFilters = options.match {
                matchFilters.forEach { (match) in
                    let string = "MATCH \(match)"
                    values.append(string)
                }
            }
            if let whereFilters = options.whereFilters {
                whereFilters.forEach { (filter) in
                    values.append(filter.asString)
                }
            }
            if let whereInFilters = options.whereInFilters {
                whereInFilters.forEach { (filter) in
                    values.append(filter.asString)
                }
            }
            if let noFields = options.noFields {
                if noFields == true {
                    values.append("NOFIELDS")
                }
            }
            if let format = options.format {
                values.append(format.string)
            }
            return values
        }
    }

    let name: String
    let raw: [String]
    
    var httpCommand: String {
        return raw.joined(separator: "+")
    }
    
    public init(name: String, values: [String]) {
        self.name = name
        var array = values
        array.insert(name, at: 0)
        self.raw = array
    }
}

// MARK: - Get Commands

public struct Get: CommandProtocol {
    let key: String
    let id: String
    let withFields: Bool
    let format: Get.Format

    public var command: Command {
        var array = [key, id]
        if withFields {
            array.append("WITHFIELDS")
        }
        array.append(format.string)
        return Command(name: "GET", values: array)
    }

    public enum Format {
        case object
        case point
        case bounds
        case hash(Int)
        var string: String {
            switch self {
            case .object:
                return "OBJECT"
            case .point:
                return "POINT"
            case .bounds:
                return "BOUNDS"
            case .hash(let val):
                // Hash val must be between 1 and 22.
                guard val >= 1 else {
                    return "HASH 1"
                }
                guard val <= 22 else {
                    return "HASH 22"
                }
                return "HASH \(val)"
            }
        }
    }

    public init(key: String, id: String, withFields: Bool, format: Get.Format) {
        self.key = key
        self.id = id
        self.withFields = withFields
        self.format = format
    }
}

// MARK: - OK Commands

public struct Delete: CommandOK {

    let key: String
    let id: String

    public var command: Command {
        return Command(name: "DEL", values: [key, id])
    }

    public init(key: String, id: String) {
        self.key = key
        self.id = id
    }
}

public struct Drop: CommandOK {
    let key: String
    public var command: Command {
        return Command(name: "DROP", values: [key])
    }
    public init(key: String) {
        self.key = key
    }
}

public struct Expire: CommandOK {
    let key: String
    let id: String
    let timeout: Int
    public var command: Command {
        return Command(name: "EXPIRE", values: [key, id, "\(timeout)"])
    }
    public init(key: String, id: String, timeout: Int) {
        self.key = key
        self.id = id
        self.timeout = timeout
    }
}

public struct FSet: CommandOK {
    let key: String
    let id: String
    let fields: [Set.Field]
    public var command: Command {
        var array = [key, id]
        fields.forEach { (field) in
            array.append(contentsOf: ["\(field.name)", "\(field.value)"])
        }
        return Command(name: "FSET", values: array)
    }
    public init(key: String, id: String, fields: [Set.Field]) {
        self.key = key
        self.id = id
        self.fields = fields
    }
}

public struct PDelete: CommandOK {
    let key: String
    let pattern: String
    public var command: Command {
        return Command(name: "PDEL", values: [key, pattern])
    }
}

public struct Ping: CommandOK {
    public var command: Command {
        return Command(name: "PING", values: [])
    }
}

public struct Persist: CommandOK {
    let key: String
    let id: String
    public var command: Command {
        return Command(name: "PERSIST", values: [key, id])
    }
    public init(key: String, id: String) {
        self.key = key
        self.id = id
    }
}

public struct Rename: CommandOK {
    let key: String
    let newKey: String
    public var command: Command {
        return Command(name: "RENAME", values: [key, newKey])
    }
    public init(key: String, newKey: String) {
        self.key = key
        self.newKey = newKey
    }
}

public struct Set: CommandOK {
    public enum Format {
        case point(lat: Double, long: Double)
        case pointz(lat: Double, long: Double, z: Double)
        case bounds(swLat: Double, swLong: Double, neLat: Double, neLong: Double)
        case object(geoJSON: GeoJSON)
    }
    public struct Field {
        public let name: String
        public let value: Double
    }

    let key: String
    let id: String
    let fields: [Field]?
    let expire: Int?
    let format: Set.Format

    public var command: Command {
        var array = [key, id]
        if let withFields = fields {
            withFields.forEach { (field) in
                array.append(contentsOf: ["FIELD", "\(field.name)", "\(field.value)"])
            }
        }
        if let expire = expire, expire > 0 {
            array.append(contentsOf: ["EX", "\(expire)"])
        }
        switch format {
        case .point(let lat, let long):
            array.append(contentsOf: ["POINT", "\(lat)", "\(long)"])
        case .pointz(let lat, let long, let z):
            array.append(contentsOf: ["POINT", "\(lat)", "\(long)", "\(z)"])
        case .bounds(let swLat, let swLong, let neLat, let neLong):
            array.append(contentsOf: ["BOUNDS", "\(swLat)", "\(swLong)", "\(neLat)", "\(neLong)"])
        case .object(let geoJSON):
            array.append(contentsOf: ["OBJECT", geoJSON.JSONString])
        }
        return Command(name: "SET", values: array)
    }

    public init(key: String, id: String, fields: [Field]? = nil, expire: Int? = nil, format: Set.Format) {
        self.key = key
        self.id = id
        self.fields = fields
        self.expire = expire
        self.format = format
    }
}

// MARK: - List Commands

public struct Intersects: CommandProtocol {
    let key: String
    let shape: Command.Shape
    let options: Command.ObjectList.Options?

    public var command: Command {
        var values: [String] = [key]
        if let opts = options {
            values.append(contentsOf: Command.ObjectList.values(for: opts))
        }
        values.append(contentsOf: Command.ObjectList.values(for: shape))
        return Command(name: "INTERSECTS", values: values)
    }

    public init(key: String, shape: Command.Shape, options: Command.ObjectList.Options? = nil) {
        self.key = key
        self.shape = shape
        self.options = options
    }
}

public struct Nearby: CommandProtocol {
    let key: String
    let point: Command.Coordinate
    let distance: Int
    let options: Command.ObjectList.Options?

    public var command: Command {
        var values: [String] = [key]
        if let opts = options {
            values.append(contentsOf: Command.ObjectList.values(for: opts))
        }
        values.append(contentsOf:["POINT", "\(point.lat)", "\(point.lon)", "\(distance)"])
        return Command(name: "NEARBY", values: values)
    }

    public init(key: String, point: Command.Coordinate, distance: Int, options: Command.ObjectList.Options? = nil) {
        self.key = key
        self.point = point
        self.distance = distance
        self.options = options
    }
}

public struct Scan: CommandProtocol {
    let key: String
    let options: Command.ObjectList.Options?
    public var command: Command {
        var values: [String] = [key]
        if let opts = options {
            values.append(contentsOf: Command.ObjectList.values(for: opts))
        }
        return Command(name: "SCAN", values:values)
    }
    public init(key: String, options: Command.ObjectList.Options? = nil) {
        self.key = key
        self.options = options
    }
}

public struct Search: CommandProtocol {
    public enum Order: String {
        case ascending = "ASC"
        case descending = "DESC"
    }
    let key: String
    let match: String?
    let order: Search.Order
    public var command: Command {
        // TODO: Support additional SEARCH options.
        var values = [key]
        if let match = match {
            values.append(contentsOf: ["MATCH", match])
        }
        values.append(order.rawValue)
        return Command(name: "SEARCH", values: values)
    }
    public init(key: String, match: String?, order: Search.Order) {
        self.key = key
        self.match = match
        self.order = order
    }
}

public struct Within: CommandProtocol {
    let key: String
    let shape: Command.Shape
    let options: Command.ObjectList.Options?
    public var command: Command {
        var values: [String] = [key]
        if let opts = options {
            values.append(contentsOf: Command.ObjectList.values(for: opts))
        }
        values.append(contentsOf: Command.ObjectList.values(for: shape))
        return Command(name: "WITHIN", values: values)
    }
    public init(key: String, shape: Command.Shape, options: Command.ObjectList.Options? = nil) {
        self.key = key
        self.shape = shape
        self.options = options
    }
}

// MARK: - Ungrouped Commands

public struct Bounds: CommandBounds {
    let key: String
    public var command: Command {
        return Command(name: "BOUNDS", values: [key])
    }
    public init(key: String) {
        self.key = key
    }
}

public struct Keys: CommandKeys {
    let pattern: String
    public var command: Command {
        return Command(name: "KEYS", values: [pattern])
    }
    public init(pattern: String) {
        self.pattern = pattern
    }
}

public struct Stats: CommandStats {
    let keys: [String]
    public var command: Command {
        return Command(name: "STATS", values: keys)
    }
    public init(keys: [String]) {
        self.keys = keys
    }
}

public struct TTL: CommandTTL {
    let key: String
    let id: String
    public var command: Command {
        return Command(name: "TTL", values: [key, id])
    }
    public init(key: String, id: String) {
        self.key = key
        self.id = id
    }
}

// MARK: - Fence Commands

public class FenceCommand: CommandProtocol {
    public enum Detect: String {
        case inside = "inside"
        case outside = "outside"
        case enter = "enter"
        case exit = "exit"
        case cross = "cross"
    }
    let aCommand: CommandProtocol
    let detect: [FenceCommand.Detect]?
    public var command: Command {
        let fencedValues = FenceCommand.FencedValues(for: aCommand.command, detect: detect)
        return Command(name: aCommand.command.name, values: fencedValues)
    }
    public init(command: CommandProtocol, detect: [FenceCommand.Detect]? = nil) {
        self.aCommand = command
        self.detect = detect
    }
    // Inserts the FENCE and DETECT strings into the provided command and
    // strips the original command name so that the values returned by this
    // method may be used directly in a Command(name:values:) initializer
    // while allowing the name to be re-inserted as part of the
    // initialization process.
    fileprivate static func FencedValues(for command: Command, detect: [FenceCommand.Detect]?)->[String] {
        var newValues: [String] = ["FENCE"]
        if let detect = detect {
            var combined: [String] = []
            detect.forEach { (val) in
                combined.append(val.rawValue)
            }
            newValues.append("DETECT")
            newValues.append(combined.joined(separator: ","))
        }
        var newRawCommand = command.raw
        newRawCommand.insert(contentsOf: newValues, at: 2)
        newRawCommand.remove(at: 0)
        return newRawCommand
    }
}

public class IntersectsFence: FenceCommand {
    public init(command: Intersects, detect: [FenceCommand.Detect]? = nil) {
        super.init(command: command, detect: detect)
    }
}

public class NearbyFence: FenceCommand {
    public init(command: Nearby, detect: [FenceCommand.Detect]? = nil) {
        super.init(command: command, detect: detect)
    }
}

public class WithinFence: FenceCommand {
    public init(command: Within, detect: [FenceCommand.Detect]? = nil) {
        super.init(command: command, detect: detect)
    }
}
