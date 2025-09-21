import XCTest

final class WeightTrackerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Weight Tracker"].exists)
        XCTAssertTrue(app.buttons["addEntry"].exists)
    }
}
