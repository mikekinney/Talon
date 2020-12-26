//
//  ConnectionTests.swift
//  TalonTests
//
//  Created by Mike Kinney on 12/25/20.
//  Copyright © 2020 Mike Kinney. All rights reserved.
//

import XCTest

@testable import Talon

class ConnectionTests: XCTestCase {

    let connection = Connection2(hostname: "192.168.0.3")

    func testPing() {
        let expectResponse = expectation(description: "Expect PONG")
        let ping = Ping()
        connection.send(command: ping) { response in
            expectResponse.fulfill()
        }
        wait(for: [expectResponse], timeout: 2)
    }

    func testSet() {
        let expectResponse = expectation(description: "Expect OK")
        let command = Set(
            key: "fleet",
            id: "truck2",
            format: .point(
                lat: 33.5123,
                long: -112.2693
            )
        )
        connection.send(
            command: command) { response in
            print("Response: \(response)")
            expectResponse.fulfill()
        }
        wait(for: [expectResponse], timeout: 2)
    }

    func testWithin() {
        let expectResponse = expectation(description: "Expect Response")
        let command = Within(
            key: "fleet",
            shape: .bounds(
                swCoordinate: Command.Coordinate(
                    lat: 37.126361789080335,
                    lon: -98.14541210286053
                ),
                neCoordinate: Command.Coordinate(
                    lat: 49.283020158906936,
                    lon: -89.57607611477702
                )
            )
        )
        connection.send(
            command: command) { response in
            let geoJSON = response.geoJSON
            XCTAssert(geoJSON.count == 2)
            expectResponse.fulfill()
        }
        wait(for: [expectResponse], timeout: 2)
    }

}
