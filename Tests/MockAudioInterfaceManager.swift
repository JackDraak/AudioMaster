import Foundation
import AVFoundation
@testable import AudioMaster

class MockAudioInterfaceManager {
    var audioEngine: AVAudioEngine
    private(set) var isEngineRunning: Bool = false
    private(set) var updateAudioRoutingCalled = false
    private(set) var lastRoutingCall: (inputIndex: Int, outputIndex: Int, enabled: Bool)?

    init() {
        audioEngine = AVAudioEngine()
    }

    func startAudioEngine() throws {
        isEngineRunning = true
    }

    func stopAudioEngine() {
        isEngineRunning = false
    }

    func updateAudioRoutes() {
        // Mock implementation
    }

    func updateAudioRouting(inputIndex: Int, outputIndex: Int, enabled: Bool) throws {
        updateAudioRoutingCalled = true
        lastRoutingCall = (inputIndex, outputIndex, enabled)

        // Simulate validation
        if inputIndex < 0 || outputIndex < 0 {
            throw AudioError.invalidConfiguration(reason: "Invalid device indices")
        }
    }

    func getInputLevels() -> [Float] {
        return [0.3, 0.5, 0.2]
    }

    func getOutputLevels() -> [Float] {
        return [0.6, 0.4, 0.8]
    }
}