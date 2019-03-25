//
//  Response.swift
//  Talon
//
//  Created by Mike on 1/30/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation

public struct Response: Codable {
    public struct Point: Codable {
        public let lat: Double
        public let lon: Double
    }
    public struct Bounds: Codable {
        public let sw: Point
        public let ne: Point
    }
}

public struct OkResponse: Codable {
    public let ok: Bool
    public let elapsed: String
}

public struct BoundsResponse: Codable {
    public struct Bounds: Codable {
        public let type: String
        public let coordinates: [[[Double]]]
    }
    public let ok: Bool
    public let bounds: Bounds
}

public struct GetObjectResponse: Codable {
    public let object: CodableDictionary
    public let fields: CodableDictionary?
}

public struct GetPointResponse: Codable {
    public let point: Response.Point
    public let fields: CodableDictionary?
}

public struct GetBoundsResponse: Codable {
    public let bounds: Response.Bounds
    public let fields: CodableDictionary?
}

public struct GetHashResponse: Codable {
    public let hash: String
    public let fields: CodableDictionary?
}

public struct ObjectListResponse: Codable {
    public let ok: Bool
    public let fields: [String]?
    public let objects: [CodableDictionary]
    public let count: Int
    public let cursor: Int
}

public struct KeysResponse: Codable {
    public let ok: Bool
    public let keys: [String]
}

public struct IDsResponse: Codable {
    public let ok: Bool
    public let ids: [String]
    public let count: Int
    public let cursor: Int
}

public struct StatsResponse: Codable {
    public struct Stats: Codable {
        public let in_memory_size: Int
        public let num_objects: Int
        public let num_points: Int
    }
    public let ok: Bool
    public let stats: [StatsResponse.Stats?]
}

public struct TTLResponse: Codable {
    public let ok: Bool
    public let ttl: Int
}

public struct FenceUpdateResponse: Codable {
    let command: String
    let group: String
    let detect: String
    let key: String
    let time: Date
    let id: String
    let object: GeoJSON
}
