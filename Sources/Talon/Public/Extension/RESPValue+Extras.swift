//
//  RESPValue+Extras.swift
//  CNIOAtomics
//
//  Created by Mike Kinney on 12/26/20.
//

import Foundation
import GEOSwift
import RediStack

extension RESPValue {
    public var okResponse: Bool {
        switch self {
        case .simpleString:
            return string == "OK"
        default:
            return false
        }
    }

    public var pongResponse: Bool {
        switch self {
        case .simpleString:
            return string == "PONG"
        default:
            return false
        }
    }

    public var geoJSON: [GeoJSON] {
        // FIXME: This should be more generic instead of expecting a specific structure.
        var json: [GeoJSON] = []
        switch self {
        case .array(let array):
            guard let last = array.last else {
                return json
            }
            switch last {
            case .array(let array):
                array.forEach { value in
                    switch value {
                    case .array(let array):
                        guard let last = array.last else {
                            break
                        }
                        switch last {
                        case .bulkString:
                            guard let data = last.data else {
                                break
                            }
                            guard let geoJSON = try? JSONDecoder().decode(GeoJSON.self, from: data) else {
                                break
                            }
                            json.append(geoJSON)
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
            default:
                break
            }
        default:
            break
        }
        return json
    }
}
