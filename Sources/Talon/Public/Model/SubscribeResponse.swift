//
//  SubscribeResponse.swift
//  Talon
//
//  Created by Mike Kinney on 12/26/20.
//

import Foundation
import GEOSwift

public struct SubscribeResponse: Decodable {
    public let command: String
    public let group: String?
    public let detect: String?
    public let hook: String?
    public let key: String?
    public let time: Date // Convert to date
    public let id: String
    public let object: GeoJSON?
}
