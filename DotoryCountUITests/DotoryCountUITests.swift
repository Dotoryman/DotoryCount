import XCTest

final class DotoryCountUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateAnniversaryFlow() throws {
        let app = launchApp()

        createAnniversary(in: app)

        XCTAssertTrue(app.staticTexts["day-counter"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testDeleteAnniversaryFlow() throws {
        let app = launchApp()
        createAnniversary(in: app)

        let editButton = app.buttons["edit-anniversary-button"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 3))
        editButton.tap()

        let deleteButton = app.buttons["delete-anniversary-button"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 3))
        deleteButton.tap()
        app.alerts.buttons["삭제"].tap()

        XCTAssertTrue(app.buttons["create-anniversary-button"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testSeededAnniversaryShowsAcornJar() throws {
        let app = launchApp(additionalArguments: ["--ui-testing-seeded-anniversary"])

        let jar = app.otherElements["acorn-jar"]
        XCTAssertTrue(jar.waitForExistence(timeout: 3))
        XCTAssertTrue((jar.value as? String)?.contains("함께한 날 22일") == true)
    }

    @MainActor
    func testHundredDayMilestoneShowsGoldenAcornDetail() throws {
        let app = launchApp(additionalArguments: ["--ui-testing-100-day-anniversary"])

        XCTAssertTrue(app.staticTexts["오늘은 100일"].waitForExistence(timeout: 3))

        let goldenAcorn = app.buttons["황금도토리 100일"]
        XCTAssertTrue(goldenAcorn.waitForExistence(timeout: 3))
        goldenAcorn.tap()

        XCTAssertTrue(app.staticTexts["함께한 시간을 황금도토리로 간직했어요."].waitForExistence(timeout: 3))
    }

    @MainActor
    private func launchApp(additionalArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"] + additionalArguments
        app.launch()
        return app
    }

    @MainActor
    private func createAnniversary(in app: XCUIApplication) {

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
