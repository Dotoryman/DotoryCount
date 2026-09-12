import XCTest

final class DotoryCountUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateAnniversaryFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let createButton = app.buttons["create-anniversary-button"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 3))
        createButton.tap()

        let titleField = app.textFields["anniversary-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("우리의 시작")

        let saveButton = app.buttons["save-anniversary-button"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(app.staticTexts["day-counter"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["--ui-testing"]
            app.launch()
        }
    }
}
