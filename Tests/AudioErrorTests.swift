import XCTest
@testable import AudioMaster

class AudioErrorTests: XCTestCase {

    func testAudioErrorDescriptions() {
        let errors: [AudioError] = [
            .engineStartFailure(underlying: NSError(domain: "test", code: 1, userInfo: nil)),
            .routingError(description: "Test routing error"),
            .invalidConfiguration(reason: "Test configuration"),
            .deviceNotFound(deviceName: "TestDevice"),
            .feedbackDetected(channels: [1, 2]),
            .bufferOverrun(timestamp: 123.45),
            .permissionDenied
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testFeedbackDetectedChannels() {
        let error = AudioError.feedbackDetected(channels: [1, 3, 5])
        let description = error.errorDescription!

        XCTAssertTrue(description.contains("1"))
        XCTAssertTrue(description.contains("3"))
        XCTAssertTrue(description.contains("5"))
    }

    func testBufferOverrunTimestamp() {
        let timestamp: TimeInterval = 987.654
        let error = AudioError.bufferOverrun(timestamp: timestamp)
        let description = error.errorDescription!

        XCTAssertTrue(description.contains("987.654"))
    }
}