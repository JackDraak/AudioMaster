import XCTest
import AVFoundation
@testable import AudioMaster

class AudioInterfaceManagerTests: XCTestCase {
    var manager: AudioInterfaceManager!
    var mockManager: MockAudioInterfaceManager!

    override func setUp() {
        super.setUp()
        manager = AudioInterfaceManager.shared
        mockManager = MockAudioInterfaceManager()
    }

    override func tearDown() {
        manager?.stopAudioEngine()
        mockManager = nil
        super.tearDown()
    }
    
    func testRouteChangeDetection() {
        let expectation = XCTestExpectation(description: "Route change detected")
        
        // Simulate route change
        NotificationCenter.default.post(
            name: AVAudioSession.routeChangeNotification,
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
            ]
        )
        
        // Verify route change handling
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAudioEngineStartStop() {
        XCTAssertNoThrow(try manager.startAudioEngine())
        XCTAssertTrue(manager.isEngineRunning)

        manager.stopAudioEngine()
        XCTAssertFalse(manager.isEngineRunning)
    }
    
    func testMultiRouteConfiguration() {
        // Test multiple output configuration
        let initialRouteCount = AVAudioSession.sharedInstance().currentRoute.outputs.count
        XCTAssertGreaterThanOrEqual(initialRouteCount, 1, "Should have at least one output route")

        // Test route update functionality
        XCTAssertNoThrow(manager.updateAudioRoutes())
    }

    func testMockManagerRouting() {
        // Test routing with mock manager
        XCTAssertFalse(mockManager.updateAudioRoutingCalled)

        XCTAssertNoThrow(try mockManager.updateAudioRouting(inputIndex: 0, outputIndex: 0, enabled: true))
        XCTAssertTrue(mockManager.updateAudioRoutingCalled)
        XCTAssertEqual(mockManager.lastRoutingCall?.inputIndex, 0)
        XCTAssertEqual(mockManager.lastRoutingCall?.outputIndex, 0)
        XCTAssertEqual(mockManager.lastRoutingCall?.enabled, true)
    }

    func testMockManagerInvalidIndices() {
        XCTAssertThrowsError(try mockManager.updateAudioRouting(inputIndex: -1, outputIndex: 0, enabled: true)) { error in
            XCTAssertTrue(error is AudioError)
        }
    }

    func testLevelMonitoring() {
        let inputLevels = manager.getInputLevels()
        let outputLevels = manager.getOutputLevels()

        XCTAssertFalse(inputLevels.isEmpty)
        XCTAssertFalse(outputLevels.isEmpty)

        // Test levels are within valid range
        for level in inputLevels {
            XCTAssertGreaterThanOrEqual(level, 0.0)
            XCTAssertLessThanOrEqual(level, 1.0)
        }

        for level in outputLevels {
            XCTAssertGreaterThanOrEqual(level, 0.0)
            XCTAssertLessThanOrEqual(level, 1.0)
        }
    }
}
