import XCTest
@testable import AudioMaster

class AudioMasterUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testRoutingMatrixInteraction() {
        let matrix = app.otherElements["RoutingMatrix"]
        XCTAssertTrue(matrix.exists, "Routing matrix should be visible")
        
        // Test matrix toggle interactions
        let toggle = matrix.switches.firstMatch
        toggle.tap()
        XCTAssertTrue(toggle.isSelected, "Toggle should be selected after tap")
    }
    
    func testMeterUpdates() {
        let inputMeter = app.otherElements["InputMeter"]
        XCTAssertTrue(inputMeter.exists, "Input meter should be visible")
        
        // Test meter animations and updates
        let startValue = inputMeter.value as? Double ?? 0
        Thread.sleep(forTimeInterval: 1) // Wait for potential updates
        let endValue = inputMeter.value as? Double ?? 0
        XCTAssertNotEqual(startValue, endValue, "Meter should update in real-time")
    }
    
    func testAccessibilityFeatures() {
        // Test VoiceOver labels
        XCTAssertTrue(app.isAccessibilityElement)
        
        // Test routing matrix accessibility
        let matrix = app.otherElements["RoutingMatrix"]
        for toggle in matrix.switches.allElementsBoundByIndex {
            XCTAssertNotNil(toggle.label, "All toggles should have accessibility labels")
        }
        
        // Test meter accessibility
        let meters = app.otherElements.matching(identifier: "LevelMeter")
        for meter in meters.allElementsBoundByIndex {
            XCTAssertNotNil(meter.value, "Meters should have accessible values")
        }
        
        // Test color contrast
        let feedbackWarning = app.staticTexts["FeedbackWarning"]
        XCTAssertTrue(feedbackWarning.exists && feedbackWarning.isAccessibilityElement)
    }
}
