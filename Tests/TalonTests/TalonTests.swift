import XCTest
@testable import Talon

final class TalonTests: XCTestCase {

    func testPing() {
        let connection = Connection(hostname: "192.168.0.3")
        let expect = expectation(description: "Expect pong")
        connection.send(
            command: Ping()) { result in
            switch result {
            case .success:
                expect.fulfill()
            case .failure:
                XCTFail("Expected success")
            }
        }
        wait(for: [expect], timeout: 2)
    }
    
}
