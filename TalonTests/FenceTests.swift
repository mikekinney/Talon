//
//  FenceTests.swift
//  TalonTests
//
//  Created by Mike on 1/31/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import XCTest
@testable import Talon

class FenceTestDelegate: FenceDelegate {
    
    
    let connectExpectation: XCTestExpectation
    let readyExpectation: XCTestExpectation
    let updateExpectation: XCTestExpectation
    let disconnectExpectation: XCTestExpectation
    
    init(connect: XCTestExpectation, ready: XCTestExpectation, update: XCTestExpectation, disconnect: XCTestExpectation) {
        self.connectExpectation = connect
        self.readyExpectation = ready
        self.updateExpectation = update
        self.disconnectExpectation = disconnect
    }
    
    func fenceDidConnect(_ fence: Fence) {
        connectExpectation.fulfill()
        let set = Set(key: "fleet", id: "bus", format: .point(lat: 33.460, long: -112.260))
        FenceTests.connection.send(command: set, success: { (response) in
            // nothing to do here
        }, failure: { (error) in
            // nothing to do here
        })
    }
    
    func fence(_ fence: Fence, ready response: FenceReadyResponse) {
        readyExpectation.fulfill()
    }
    
    func fenceDidDisconnect(_ fence: Fence) {
        disconnectExpectation.fulfill()
    }
    
    func fence(_ fence: Fence, didUpdate response: FenceUpdateResponse) {
        updateExpectation.fulfill()
    }

    func fence(_ fence: Fence, didDelete response: FenceDeleteResponse) {
        // nothing to do here
    }

    func fence(_ fence: Fence, error: Error) {
        // hopefully not expecting any errors
    }
}

class FenceTests: XCTestCase {

    static var connection: Connection = Connection(host: "192.168.0.2", port: 9851)
    
    func testNearbyFence() {
        let connectExpectation = expectation(description: "Expect connect")
        let readyExpectation = expectation(description: "Expect ready")
        let updateExpectation = expectation(description: "Expect update")
        let disconnectExpectation = expectation(description: "Expect disconnect")
        let nearby = Nearby(key: "fleet", point: Command.Coordinate(lat: 33.462, lon: 112.268), distance: 6000)
        let nearbyFence = NearbyFence(command: nearby, detect: [.enter, .inside, .outside])
        let fenceDelegate = FenceTestDelegate(connect: connectExpectation, ready: readyExpectation, update: updateExpectation, disconnect: disconnectExpectation)
        let fence = Fence(host: "192.168.0.2", port: 9851, delegate: fenceDelegate, command: nearbyFence)
        wait(for: [connectExpectation, readyExpectation, updateExpectation], timeout: 10)
        fence.disconnect()
        wait(for: [disconnectExpectation], timeout: 10)
    }

}
