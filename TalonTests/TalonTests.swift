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

    static var connection: Connection = Connection(host: "192.168.0.3", port: 9851)
    
    func testGetBounds() {
        let expect = expectation(description: "Expect success")
        let get = Get(key: "fleet", id: "point", withFields: false, format: .bounds)
        TalonTests.connection.perform(command: get.command, success: { (response: GetBoundsResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testGetHash() {
        let expect = expectation(description: "Expect success")
        let get = Get(key: "fleet", id: "point", withFields: false, format: .hash(10))
        TalonTests.connection.perform(command: get.command, success: { (response: GetHashResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testGetObject() {
        let expect = expectation(description: "Expect success")
        let get = Get(key: "fleet", id: "point", withFields: true, format: .object)
        TalonTests.connection.perform(command: get.command, success: { (response: GetObjectResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testGetPoint() {
        let expect = expectation(description: "Expect success")
        let get = Get(key: "fleet", id: "point", withFields: false, format: .point)
        TalonTests.connection.perform(command: get.command, success: { (response: GetPointResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testDelete() {
        let expect = expectation(description: "Expect success")
        let format = Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Set(key: "fleet", id: "deleteme", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let delete = Delete(key: "fleet", id: "deleteme")
            TalonTests.connection.send(command: delete, success: { (response) in
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
        let format = Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Set(key: "dropme", id: "deleteme", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let drop = Drop(key: "dropme")
            TalonTests.connection.send(command: drop, success: { (response) in
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
        let format = Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Set(key: "fleet", id: "expireme", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let expire = Expire(key: "fleet", id: "expireme", timeout: 10)
            TalonTests.connection.send(command: expire, success: { (response) in
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
        let format = Set.Format.point(lat: 33.5123, long: -112.2693)
        let field = Set.Field(name: "speed", value: 50)
        let set = Set(key: "fleet", id: "fset", fields: [field], format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let f1 = Set.Field(name: "speed", value: 100)
            let fset = FSet(key: "fleet", id: "fset", fields: [f1])
            TalonTests.connection.send(command: fset, success: { (response) in
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
        let format = Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Set(key: "fleet", id: "things1", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let pdelete = PDelete(key: "fleet", pattern: "things*")
            TalonTests.connection.send(command: pdelete, success: { (response) in
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
        let ping = Ping()
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
        let format = Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Set(key: "fleet", id: "persist", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let persist = Persist(key: "fleet", id: "persist")
            TalonTests.connection.send(command: persist, success: { (response) in
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
        let format = Set.Format.point(lat: 33.5123, long: -112.2693)
        let set = Set(key: "oldname", id: "thing", fields: nil, format: format)
        TalonTests.connection.send(command: set, success: { (response) in
            let rename = Rename(key: "oldname", newKey: "newname")
            TalonTests.connection.send(command: rename, success: { (response) in
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
        let fields = [Set.Field(name: "speed", value: 90)]
        //------ POINT
        let point = Set(key: "fleet", id: "point", fields: fields, format: .point(lat: 33.123, long: -112.2693))
        TalonTests.connection.send(command: point, success: { (response) in
            expectPoint.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectPoint.fulfill()
        })
        //------ POINTZ
        let expectPointZ = expectation(description: "Expect success")
        let pointz = Set(key: "fleet", id: "pointz", fields: fields, format: .pointz(lat: 33.123, long: -112.2693, z: 12))
        TalonTests.connection.send(command: pointz, success: { (response) in
            expectPointZ.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectPointZ.fulfill()
        })
        //------ BOUNDS
        let expectBounds = expectation(description: "Expect success")
        let bounds = Set(key: "fleet", id: "bounds", fields: fields, format: .bounds(swLat: 33.462, swLong: -112.268, neLat: 33.491, neLong: -112.245))
        TalonTests.connection.send(command: bounds, success: { (response) in
            expectBounds.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectBounds.fulfill()
        })
        //------ GEOPOINT
        let expectGeoPoint = expectation(description: "Expect success")
        let geoPointPosition = GeoJSONPosition(longitude: -77.595453, latitude: 43.155059)
        let geoPointGeometry = GeoJSON.Geometry.point(coordinates: geoPointPosition)
        let geoPointFeature = GeoJSON.Feature(id: nil, geometry: geoPointGeometry, properties: nil)
        let geoJSONPoint = GeoJSON.feature(feature: geoPointFeature, boundingBox: nil)
        let geoPoint = Set(key: "fleet", id: "pointObject", format: .object(geoJSON: geoJSONPoint))
        TalonTests.connection.send(command: geoPoint, success: { (response) in
            expectGeoPoint.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectGeoPoint.fulfill()
        })
        //------ GEOPOLYGON
        let expectGeoPolygon = expectation(description: "Expect success")
        let geoPolygonPositions: [GeoJSONPosition] = [
            GeoJSONPosition(longitude: -64.73, latitude: 32.31),
            GeoJSONPosition(longitude: -80.19, latitude: 25.76),
            GeoJSONPosition(longitude: -66.09, latitude: 18.43),
            GeoJSONPosition(longitude: -64.73, latitude: 32.31)
        ]
        let geoPolygonGeometry = GeoJSON.Geometry.polygon(coordinates: [geoPolygonPositions])
        let geoPolygonProperties = JSON.object(["name":"Bermuda Triangle"])
        let geoPolygonFeature = GeoJSON.Feature(id: nil, geometry: geoPolygonGeometry, properties: geoPolygonProperties)
        let geoJSONPolygon = GeoJSON.feature(feature: geoPolygonFeature, boundingBox: nil)
        let geoPolygon = Set(key: "fleet", id: "polygonObject", format: .object(geoJSON: geoJSONPolygon))
        TalonTests.connection.send(command: geoPolygon, success: { (response) in
            expectGeoPolygon.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectGeoPolygon.fulfill()
        })
        //------ EXPIRE
        let expectExpire = expectation(description: "Expect success")
        let expire = Set(key: "fleet", id: "expire", fields: fields, expire: 10, format: .point(lat: 33.123, long: -112.2693))
        TalonTests.connection.send(command: expire, success: { (response) in
            expectExpire.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expectExpire.fulfill()
        })
        wait(for: [expectPoint, expectPointZ, expectBounds, expectGeoPoint, expectGeoPolygon, expectExpire], timeout: 20)
    }
    
    func testIntersects() {
        let expect = expectation(description: "Expect success")
        let sw = Command.Coordinate(lat: 33.462, lon: -112.268)
        let ne = Command.Coordinate(lat: 33.491, lon: -112.245)
        let intersects = Intersects(key: "fleet", shape: Command.Shape.bounds(swCoordinate: sw, neCoordinate: ne))
        TalonTests.connection.perform(command: intersects.command, success: { (response: ListObjectsResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testNearby() {
        let expect = expectation(description: "Expect success")
        let nearby = Nearby(key: "fleet", point: Command.Coordinate(lat: 33.5123, lon: -112.2693), distance: 6000)
        
        TalonTests.connection.perform(command: nearby.command, success: { (response: ListObjectsResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testScan() {
        let expect = expectation(description: "Expect success")
        let scan = Scan(key: "fleet")
        TalonTests.connection.perform(command: scan.command, success: { (response: ListObjectsResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }

    func testSearch() {
        let expect = expectation(description: "Expect success")
        let search = Search(key: "fleet", match: "speed", order: .ascending)
        TalonTests.connection.perform(command: search.command, success: { (response: ListObjectsResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testWithin() {
        let expect = expectation(description: "Expect success")
        let geoPolygonPositions: [GeoJSONPosition] = [
            GeoJSONPosition(longitude: -64.73, latitude: 32.31),
            GeoJSONPosition(longitude: -80.19, latitude: 25.76),
            GeoJSONPosition(longitude: -66.09, latitude: 18.43),
            GeoJSONPosition(longitude: -64.73, latitude: 32.31)
        ]
        let geoPolygonGeometry = GeoJSON.Geometry.polygon(coordinates: [geoPolygonPositions])
        let geoPolygonProperties = JSON.object(["name":"Bermuda Triangle"])
        let geoPolygonFeature = GeoJSON.Feature(id: nil, geometry: geoPolygonGeometry, properties: geoPolygonProperties)
        let geoJSONPolygon = GeoJSON.feature(feature: geoPolygonFeature, boundingBox: nil)
        var options = Command.ObjectList.Options()
        options.sparse = 1
        let within = Within(key: "fleet", shape: Command.Shape.object(geoJSON: geoJSONPolygon), options: options)
        TalonTests.connection.perform(command: within.command, success: { (response: ListObjectsResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testBounds() {
        let expect = expectation(description: "Expect success")
        let bounds = Bounds(key: "fleet")
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
        let keys = Keys(pattern: "fleet")
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
        let command = Stats(keys: ["fleet", "fleet1"])
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
        let command = TTL(key: "fleet", id: "point")
        TalonTests.connection.ttl(command: command, success: { (response) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
    
    func testIDs() {
        let expect = expectation(description: "Expect success")
        let command = Command(name: "SCAN", values: ["FLEET", "IDS"])
        TalonTests.connection.perform(command: command, success: { (response: IDsResponse) in
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("Failed: \(error)")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 10)
    }
}
