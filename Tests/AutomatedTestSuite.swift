import XCTest
@testable import AudioMaster

class AutomatedTestSuite: XCTestCase {
    override class func setUp() {
        super.setUp()
        // Global test setup
    }
    
    override class func tearDown() {
        super.tearDown()
        // Global test cleanup
    }
}

// MARK: - Test Triggers
extension AutomatedTestSuite {
    func testAutomaticTestTrigger() {
        // This will run automatically with CI/CD
        let triggerTests = TestTrigger()
        triggerTests.runAll()
    }
}

class TestTrigger {
    func runAll() {
        // Run all test suites in sequence
        runPerformanceTests()
        runFeedbackTests()
        runUITests()
    }
    
    private func runPerformanceTests() {
        let perfTests = AudioPerformanceTests()
        perfTests.testAudioLatency()
        perfTests.testProcessingLoad()
        perfTests.testFeedbackDetectionSpeed()
    }
    
    private func runFeedbackTests() {
        let feedbackTests = FeedbackPreventionTests()
        feedbackTests.testFeedbackDetection()
        feedbackTests.testThresholdLevels()
        feedbackTests.testPreventiveMeasures()
    }
    
    private func runUITests() {
        let uiTests = AudioMasterUITests()
        uiTests.testRoutingMatrixInteraction()
        uiTests.testMeterUpdates()
        uiTests.testAccessibilityFeatures()
    }
}
