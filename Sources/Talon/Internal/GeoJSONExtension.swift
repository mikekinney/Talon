//
//  GeoJSONExtension.swift
//  Talon
//
//  Created by Mike on 2/1/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation
import GEOSwift

extension GeoJSON {
    var JSONString: String {
        var jsonString: String = ""
        do {
            let json = try JSONEncoder().encode(self)
            if let string = String(data: json, encoding: .utf8) {
                jsonString = string
            }
        } catch {
            print("JSONSerialization failed: " + error.localizedDescription)
        }
        return jsonString
    }
}
