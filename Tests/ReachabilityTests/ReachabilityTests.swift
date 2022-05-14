import XCTest
@testable import Reachability

final class ReachabilityTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Reachability().text, "Hello, World!")
    }
}
