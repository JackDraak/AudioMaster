import XCTest
@testable import AudioMaster

class AudioInterfaceManagerTests: XCTestCase {
    var manager: AudioInterfaceManager!
    
    override func setUp() {
        super.setUp()
        manager = AudioInterfaceManager.shared
    }
    
    override func tearDown() {
        // Clean up any test audio routes
        manager = nil
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
    }
}
