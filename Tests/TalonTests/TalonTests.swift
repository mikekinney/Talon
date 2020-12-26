import XCTest
@testable import Talon

final class TalonTests: XCTestCase {

    let connection = Connection(hostname: "192.168.0.3")

    func testPing() {
        let expect = expectation(description: "Expect pong")
        connection.send(command: Ping()) { result in
            switch result {
            case .success(let response):
                if case Response.pong = response {
                    expect.fulfill()
                }
            case .failure:
                XCTFail("Expected success")
            }
        }
        wait(for: [expect], timeout: 2)
    }

    func testSetPoint() {
        let expect = expectation(description: "Expect OK")
        let set = Set(key: "test", id: "test1", fields: nil, expire: 10, format: .point(lat: 44.86995703569788, long: -93.19546153338577))
        connection.send(command: set) { result in
            switch result {
            case .success(let response):
                if case Response.ok = response {
                    expect.fulfill()
                }
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        }
        wait(for: [expect], timeout: 2)
    }
    
}
