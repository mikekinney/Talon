//
//  ConnectionTests.swift
//  TalonTests
//
//  Created by Mike on 1/30/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import XCTest
@testable import Talon

class TalonTests: XCTestCase {

    static var connection: Connection = Connection(host: "192.168.0.2", port: 9851)
    
    func testGetBounds() {
        let expect = expectation(description: "Expect success")
        let command = Command.Get.Bound(key: "fleet", id: "point", withFields: false)
        TalonTests.connection.get(command: command, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testGetHash() {
        let expect = expectation(description: "Expect success")
        let command = Command.Get.Hash(key: "fleet", id: "point", withFields: false, precision: 10)
        TalonTests.connection.get(command: command, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testGetObject() {
        let expect = expectation(description: "Expect success")
        let command = Command.Get.Object(key: "fleet", id: "point", withFields: true)
        TalonTests.connection.get(command: command, success: { (geoJSON, fields) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testGetPoint() {
        let expect = expectation(description: "Expect success")
        let command = Command.Get.Point(key: "fleet", id: "point", withFields: false)
        TalonTests.connection.get(command: command, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testDelete() {
        let expect = expectation(description: "Expect success")
        let format = Command.Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Command.Set(key: "fleet", id: "deleteme", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let command = Command.Delete(key: "fleet", id: "deleteme")
            TalonTests.connection.send(command: command, success: { (response) in
                expect.fulfill()
            }, failure: { (error) in
                XCTFail("Failed: \(error)")
                expect.fulfill()
            })
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testDrop() {
        let expect = expectation(description: "Expect success")
        let format = Command.Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Command.Set(key: "dropme", id: "deleteme", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let command = Command.Drop(key: "dropme")
            TalonTests.connection.send(command: command, success: { (response) in
                expect.fulfill()
            }, failure: { (error) in
                XCTFail("Failed: \(error)")
                expect.fulfill()
            })
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testExpire() {
        let expect = expectation(description: "Expect success")
        let format = Command.Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Command.Set(key: "fleet", id: "expireme", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let command = Command.Expire(key: "fleet", id: "expireme", timeout: 10)
            TalonTests.connection.send(command: command, success: { (response) in
                expect.fulfill()
            }, failure: { (error) in
                XCTFail("Failed: \(error)")
                expect.fulfill()
            })
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testFSet() {
        let expect = expectation(description: "Expect success")
        let format = Command.Set.Format.point(lat: 33.5123, long: -112.2693)
        let field = Command.Set.Field(name: "speed", value: 50)
        let set = Command.Set(key: "fleet", id: "fset", fields: [field], format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let f1 = Command.Set.Field(name: "speed", value: 100)
            let command = Command.FSet(key: "fleet", id: "fset", fields: [f1])
            TalonTests.connection.send(command: command, success: { (response) in
                expect.fulfill()
            }, failure: { (error) in
                XCTFail("Failed: \(error)")
                expect.fulfill()
            })
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testPDelete() {
        let expect = expectation(description: "Expect success")
        let format = Command.Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Command.Set(key: "fleet", id: "things1", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let command = Command.PDelete(key: "fleet", pattern: "things*")
            TalonTests.connection.send(command: command, success: { (response) in
                expect.fulfill()
            }, failure: { (error) in
                XCTFail("Failed: \(error)")
                expect.fulfill()
            })
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testPing() {
        let expect = expectation(description: "Expect success")
        let ping = Command.Ping()
        TalonTests.connection.send(command: ping, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testPersist() {
        let expect = expectation(description: "Expect success")
        let format = Command.Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Command.Set(key: "fleet", id: "persist", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let command = Command.Persist(key: "fleet", id: "persist")
            TalonTests.connection.send(command: command, success: { (response) in
                expect.fulfill()
            }, failure: { (error) in
                XCTFail("Failed: \(error)")
                expect.fulfill()
            })
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testRename() {
        let expect = expectation(description: "Expect success")
        let format = Command.Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Command.Set(key: "oldname", id: "thing", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let command = Command.Rename(key: "oldname", newKey: "newname")
            TalonTests.connection.send(command: command, success: { (response) in
                expect.fulfill()
            }, failure: { (error) in
                XCTFail("Failed: \(error)")
                expect.fulfill()
            })
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testSet() {
        let expectPoint = expectation(description: "Expect success")
        let fields = [Command.Set.Field(name: "speed", value: 90)]
        //------ POINT
        let point = Command.Set(key: "fleet", id: "point", fields: fields, format: .point(lat: 33.123, long: -112.2693))
        TalonTests.connection.send(command: point, success: { (response) in
            expectPoint.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectPoint.fulfill()
        })
        //------ POINTZ
        let expectPointZ = expectation(description: "Expect success")
        let pointz = Command.Set(key: "fleet", id: "pointz", fields: fields, format: .pointz(lat: 33.123, long: -112.2693, z: 12))
        TalonTests.connection.send(command: pointz, success: { (response) in
            expectPointZ.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectPointZ.fulfill()
        })
        //------ BOUNDS
        let expectBounds = expectation(description: "Expect success")
        let bounds = Command.Set(key: "fleet", id: "bounds", fields: fields, format: .bounds(swLat: 33.462, swLong: -112.268, neLat: 33.491, neLong: -112.245))
        TalonTests.connection.send(command: bounds, success: { (response) in
            expectBounds.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectBounds.fulfill()
        })
        //------ GEOPOINT
        let expectGeoPoint = expectation(description: "Expect success")
        let geoPointDictionary: [String: Any] = [
            "coordinates": [-77.595453, 43.155059],
            "type": "Point"
        ]
        let geoPointData = try! JSONSerialization.data(withJSONObject: geoPointDictionary, options: [])
        let geoPointObject = try! JSONDecoder().decode(GeoJSON.self, from: geoPointData)
        let geoPoint = Command.Set(key: "fleet", id: "pointObject", format: .object(geoJSON: geoPointObject))
        TalonTests.connection.send(command: geoPoint, success: { (response) in
            expectGeoPoint.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectGeoPoint.fulfill()
        })
        //------ GEOPOLYGON
        let expectGeoPolygon = expectation(description: "Expect success")
        let geoPolygonDictionary: [String: Any] = [
            "type": "Feature",
            "geometry": [
                "type": "Polygon",
                "coordinates": [[[-64.73, 32.31],
                                 [-80.19, 25.76],
                                 [-66.09, 18.43],
                                 [-64.73, 32.31]]]
            ],
            "properties": [
                "name": "Bermuda Triangle"
            ]
        ]
        let geoPolygonData = try! JSONSerialization.data(withJSONObject: geoPolygonDictionary, options: [])
        let geoPolygonObject = try! JSONDecoder().decode(GeoJSON.self, from: geoPolygonData)
        let geoPolygon = Command.Set(key: "fleet", id: "polygonObject", format: .object(geoJSON: geoPolygonObject))
        TalonTests.connection.send(command: geoPolygon, success: { (response) in
            expectGeoPolygon.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectGeoPolygon.fulfill()
        })
        //------ GEOLINESTRING
        let expectGeoLineString = expectation(description: "Expect success")
        let geoLineStringDictionary: [String: Any] = [
            "coordinates": [[-111.9787,33.4411], [-111.8902,33.4377],[-111.8950,33.2892],[-111.9739,33.2932]],
            "type": "LineString"
        ]
        let geoLineStringData = try! JSONSerialization.data(withJSONObject: geoLineStringDictionary, options: [])
        let geoLineStringObject = try! JSONDecoder().decode(GeoJSON.self, from: geoLineStringData)
        let geoLineString = Command.Set(key: "fleet", id: "lineStringObject", format: .object(geoJSON: geoLineStringObject))
        TalonTests.connection.send(command: geoLineString, success: { (response) in
            expectGeoLineString.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectGeoLineString.fulfill()
        })
        //------ GEOMULTILINESTRING
        let expectGeoMultiLineString = expectation(description: "Expect success")
        let geoMultiLineStringDictionary: [String: Any] = [
            "coordinates": [[[-111.9787,33.4411], [-111.8902,33.4377],[-112.8950,33.2892],[-111.9739,33.2932]]],
            "type": "MultiLineString"
        ]
        let geoMultiLineStringData = try! JSONSerialization.data(withJSONObject: geoMultiLineStringDictionary, options: [])
        let geoMultiLineStringObject = try! JSONDecoder().decode(GeoJSON.self, from: geoMultiLineStringData)
        let geoMultiLineString = Command.Set(key: "fleet", id: "multiLineStringObject", format: .object(geoJSON: geoMultiLineStringObject))
        TalonTests.connection.send(command: geoMultiLineString, success: { (response) in
            expectGeoMultiLineString.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectGeoMultiLineString.fulfill()
        })
        //------ GEOFEATURE
        let expectGeoFeature = expectation(description: "Expect success")
        let geoFeatureDictionary: [String: Any] = [
            "type": "Feature",
            "geometry": [
                "type": "Point",
                "coordinates": [125.6, 10.1]
            ],
            "properties": [
                "name": "Dinagat Islands"
            ]
        ]
        let geoFeatureData = try! JSONSerialization.data(withJSONObject: geoFeatureDictionary, options: [])
        let geoFeatureObject = try! JSONDecoder().decode(GeoJSON.self, from: geoFeatureData)
        let geoFeature = Command.Set(key: "fleet", id: "geoFeature", format: .object(geoJSON: geoFeatureObject))
        TalonTests.connection.send(command: geoFeature, success: { (response) in
            expectGeoFeature.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectGeoFeature.fulfill()
        })
        //------ EXPIRE
        let expectExpire = expectation(description: "Expect success")
        let expire = Command.Set(key: "fleet", id: "expire", fields: fields, expire: 10, format: .point(lat: 33.123, long: -112.2693))
        TalonTests.connection.send(command: expire, success: { (response) in
            expectExpire.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectExpire.fulfill()
        })
        wait(for: [expectPoint, expectPointZ, expectBounds, expectGeoPoint, expectGeoPolygon, expectGeoLineString, expectGeoMultiLineString, expectGeoFeature, expectExpire], timeout: 20)
    }
    
    func testIntersects() {
        let expect = expectation(description: "Expect success")
        let command = Command.Intersects(key: "fleet", shape: Command.Shape.bounds(swLat: 33.462, swLon: -112.268, neLat: 33.491, neLon: -112.245))
        TalonTests.connection.list(command: command, success: { (response, objects) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testNearby() {
        let expect = expectation(description: "Expect success")
        let command = Command.Nearby(key: "fleet", point: Command.Coordinate(lat: 33.5123, lon: -112.2693), distance: 6000)
        TalonTests.connection.list(command: command, success: { (response, objects) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testScan() {
        let expect = expectation(description: "Expect success")
        let command = Command.Scan(key: "fleet")
        TalonTests.connection.list(command: command, success: { (response, objects) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }

    func testSearch() {
        let expect = expectation(description: "Expect success")
        let command = Command.Search(key: "fleet", match: "speed", order: .ascending)
        TalonTests.connection.list(command: command, success: { (response, objects) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testWithin() {
        let expect = expectation(description: "Expect success")
        let geoPolygon: [String: Any] = [
            "type": "Feature",
            "geometry": [
                "type": "Polygon",
                "coordinates": [[[-64.73, 32.31],
                [-80.19, 25.76],
                [-66.09, 18.43],
                [-64.73, 32.31]]]
            ],
            "properties": [
                "name": "Bermuda Triangle"
            ]
        ]
        let data = try!JSONSerialization.data(withJSONObject: geoPolygon, options: [])
        let geoJSON: GeoJSON = try! JSONDecoder().decode(GeoJSON.self, from: data)
        var options = Command.ObjectList.Options()
        options.sparse = 1
        let command = Command.Within(key: "fleet", shape: Command.Shape.object(geoJSON: geoJSON), options: options)
        TalonTests.connection.list(command: command, success: { (response, objects) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testBounds() {
        let expect = expectation(description: "Expect success")
        let bounds = Command.Bounds(key: "fleet")
        TalonTests.connection.bounds(command: bounds, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testKeys() {
        let expect = expectation(description: "Expect success")
        let keys = Command.Keys(pattern: "fleet")
        TalonTests.connection.keys(command: keys, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testStats() {
        let expect = expectation(description: "Expect success")
        let command = Command.Stats(keys: ["fleet", "fleet1"])
        TalonTests.connection.stats(command: command, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testTTL() {
        let expect = expectation(description: "Expect success")
        let command = Command.TTL(key: "fleet", id: "point")
        TalonTests.connection.ttl(command: command, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)

    }
}
