//
//  ListObjectsResponseExtension.swift
//  Talon
//
//  Created by Mike Kinney on 3/26/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation

extension ListObjectsResponse {
    
    /// Converts the objects array to an array of GeoJSON objects.
    public var geoJSONObjects: [GeoJSON] {
        var jsonObjects: [GeoJSON] = []
        objects.forEach({ (codableDictionary) in
            let dict = codableDictionary.dictionary as [String:Any]
            guard let obj = dict["object"] as? [String:Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: obj, options: [])
                let geoJSON = try JSONDecoder().decode(GeoJSON.self, from: data)
                jsonObjects.append(geoJSON)
            } catch {
                Log.debug(message: "Unable to parse GeoJSON object \(obj)")
            }
        })
        return jsonObjects
    }
    
}
