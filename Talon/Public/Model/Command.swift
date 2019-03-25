//
//  Command.swift
//  Talon
//
//  Created by Mike on 1/29/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation

/// Base class for all supported commands. Subclasses are responsible for
/// providing the command name and an array of values that when combined can
/// be joined together to construct the HTTP path for the command.
public class Command {
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

extension Command {
    public class Get: Command {
        enum Format {
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

        fileprivate init(key: String, id: String, withFields: Bool, format: Command.Get.Format) {
            var array = [key, id]
            if withFields {
                array.append("WITHFIELDS")
            }
            array.append(format.string)
            super.init(name: "GET", values: array)
        }
        public class Bound: Get {
            public init(key: String, id: String, withFields: Bool) {
                super.init(key: key, id: id, withFields: withFields, format: .bounds)
            }
        }
        
        public class Hash: Get {
            public init(key: String, id: String, withFields: Bool, precision: Int) {
                super.init(key: key, id: id, withFields: withFields, format: .hash(precision))
            }
        }
        
        public class Object: Get {
            public init(key: String, id: String, withFields: Bool) {
                super.init(key: key, id: id, withFields: withFields, format: .object)
            }
        }
        
        public class Point: Get {
            public init(key: String, id: String, withFields: Bool) {
                super.init(key: key, id: id, withFields: withFields, format: .point)
            }
        }
    }
}

// MARK: - OK Commands

extension Command {
    public class OK: Command {}

    public class Delete: Command.OK {
        public init(key: String, id: String) {
            super.init(name: "DEL", values: [key, id])
        }
    }

    public class Drop: Command.OK {
        public init(key: String) {
            super.init(name: "DROP", values: [key])
        }
    }

    public class Expire: Command.OK {
        public init(key: String, id: String, timeout: Int) {
            super.init(name: "EXPIRE", values: [key, id, "\(timeout)"])
        }
    }
    
    public class FSet: Command.OK {
        public init(key: String, id: String, fields: [Command.Set.Field]) {
            var array = [key, id]
            fields.forEach { (field) in
                array.append(contentsOf: ["\(field.name)", "\(field.value)"])
            }
            super.init(name: "FSET", values: array)
        }
    }
    
    public class PDelete: Command.OK {
        public init(key: String, pattern: String) {
            super.init(name: "PDEL", values: [key, pattern])
        }
    }
    
    public class Ping: Command.OK {
        public init() {
            super.init(name: "PING", values: [])
        }
    }
    
    public class Persist: Command.OK {
        public init(key: String, id: String) {
            super.init(name: "PERSIST", values: [key, id])
        }
    }
    
    public class Rename: Command.OK {
        public init(key: String, newKey: String) {
            super.init(name: "RENAME", values: [key, newKey])
        }
    }
    
    public class Set: Command.OK {
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
        public init(key: String, id: String, fields: [Field]? = nil, expire: Int? = nil, format: Command.Set.Format) {
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
            super.init(name: "SET", values: array)
        }
    }
}

// MARK: - List Commands

extension Command {
    public class ObjectList: Command {
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
        
        public struct Options {
            public var sparse: Int?
            public var whereFilters: [Where]?
            public var whereInFilters: [WhereIn]?
            public var match: [String]?
            public var noFields: Bool?
            public var limit: Int?
            public init() {}
        }
    }
    
    fileprivate static func values(for shape: Command.Shape) -> [String] {
        var values: [String] = []
        switch shape {
        case .bounds(let swCoordinate, let neCoordinate):
            values.append(contentsOf: ["BOUNDS", "\(swCoordinate.lat)", "\(swCoordinate.lon)", "\(neCoordinate.lat)", "\(neCoordinate.lon)"])
        case .object(let geoJSON):
            values.append(contentsOf: ["OBJECT", geoJSON.JSONString])
        }
        return values
    }
    
    fileprivate static func values(for options: Command.ObjectList.Options) -> [String] {
        var values: [String] = []
        if let sparse = options.sparse {
            values.append(contentsOf: ["SPARSE \(sparse)"])
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
        if let matchFilters = options.match {
            matchFilters.forEach { (match) in
                let string = "MATCH \(match)"
                values.append(string)
            }
        }
        if let noFields = options.noFields {
            if noFields == true {
                values.append("NOFIELDS")
            }
        }
        if let limit = options.limit {
            if options.sparse == nil {
                let string = "LIMIT \(limit)"
                values.append(string)
            } else {
                Log.debug(message: "LIMIT option ignored when SPARSE value is set")
            }
        }
        return values
    }
    
    public class Intersects: Command.ObjectList {
        public init(key: String, shape: Command.Shape, options: Command.ObjectList.Options? = nil) {
            var values: [String] = [key]
            if let opts = options {
                values.append(contentsOf: Command.ObjectList.values(for: opts))
            }
            values.append(contentsOf: Command.ObjectList.values(for: shape))
            super.init(name: "INTERSECTS", values: values)
        }
    }
    
    public class Nearby: Command.ObjectList {
        public init(key: String, point: Command.Coordinate, distance: Int, options: Command.ObjectList.Options? = nil) {
            var values: [String] = [key]
            if let opts = options {
                values.append(contentsOf: Command.ObjectList.values(for: opts))
            }
            values.append(contentsOf:["POINT", "\(point.lat)", "\(point.lon)", "\(distance)"])
            super.init(name: "NEARBY", values: values)
        }
    }
    
    public class Scan: Command.ObjectList {
        public init(key: String, options: Command.ObjectList.Options? = nil) {
            var values: [String] = [key]
            if let opts = options {
                values.append(contentsOf: Command.ObjectList.values(for: opts))
            }
            super.init(name: "SCAN", values:values)
        }
    }
    
    public class Search: Command.ObjectList {
        public enum Order: String {
            case ascending = "ASC"
            case descending = "DESC"
        }
        public init(key: String, match: String?, order: Command.ObjectList.Search.Order) {
            // TODO: Support additional SEARCH options.
            var values = [key]
            if let match = match {
                values.append(contentsOf: ["MATCH", match])
            }
            values.append(order.rawValue)
            super.init(name: "SEARCH", values: values)
        }
    }
    
    public class Within: Command.ObjectList {
        public init(key: String, shape: Command.Shape, options: Command.ObjectList.Options? = nil) {
            var values: [String] = [key]
            if let opts = options {
                values.append(contentsOf: Command.ObjectList.values(for: opts))
            }
            values.append(contentsOf: Command.ObjectList.values(for: shape))
            super.init(name: "WITHIN", values: values)
        }
    }

}

// MARK: - Ungrouped Commands

extension Command {
    public class Bounds: Command {
        public init(key: String) {
            super.init(name: "BOUNDS", values: [key])
        }
    }
    
    public class Keys: Command {
        public init(pattern: String) {
            super.init(name: "KEYS", values: [pattern])
        }
    }
    
    public class Stats: Command {
        public init(keys: [String]) {
            super.init(name: "STATS", values: keys)
        }
    }
    
    public class TTL: Command {
        public init(key: String, id: String) {
            super.init(name: "TTL", values: [key, id])
        }
    }
}

// MARK: - Fence Commands

extension Command {
    public class Fence: Command {
        public enum Detect: String {
            case inside = "inside"
            case outside = "outside"
            case enter = "enter"
            case exit = "exit"
            case cross = "cross"
        }
        // Inserts the FENCE and DETECT strings into the provided command and
        // strips the original command name so that the values returned by this
        // method may be used directly in a Command(name:values:) initializer
        // while allowing the name to be re-inserted as part of the
        // initialization process.
        fileprivate static func FencedValues(for command: Command, detect: [Command.Fence.Detect]?)->[String] {
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
        public init(command: Command, detect: [Command.Fence.Detect]? = nil) {
            let fencedValues = Command.Fence.FencedValues(for: command, detect: detect)
            super.init(name: command.name, values: fencedValues)
        }
    }
    
    public class IntersectsFence: Command.Fence {
        public init(command: Command.Intersects, detect: [Command.Fence.Detect]? = nil) {
            super.init(command: command, detect: detect)
        }
    }

    public class NearbyFence: Command.Fence {
        public init(command: Command.Nearby, detect: [Command.Fence.Detect]? = nil) {
            super.init(command: command, detect: detect)
        }
    }

    public class WithinFence: Command.Fence {
        public init(command: Command.Within, detect: [Command.Fence.Detect]? = nil) {
            super.init(command: command, detect: detect)
        }
    }
    
}
