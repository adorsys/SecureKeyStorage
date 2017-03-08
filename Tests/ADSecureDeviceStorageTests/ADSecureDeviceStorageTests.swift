import XCTest
@testable import ADSecureDeviceStorage

class ADSecureDeviceStorageTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(ADSecureDeviceStorage().text, "Hello, World!")
    }


    static var allTests : [(String, (ADSecureDeviceStorageTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
