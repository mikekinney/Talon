import XCTest
@testable import Talon

final class TalonTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Talon().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
