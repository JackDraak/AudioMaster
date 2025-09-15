import Foundation
import AVFoundation
import CoreAudio

class AudioInterfaceManager {
    static let shared = AudioInterfaceManager()
    var audioEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode

    var isEngineRunning: Bool {
        return audioEngine.isRunning
    }
    
    private init() {
        audioEngine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        audioEngine.attach(mixerNode)
        
        // Setup notification observers for audio route changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // Handle route changes
        switch reason {
        case .newDeviceAvailable:
            AudioLogger.shared.logRouteChange(reason: "New device connected", inputs: [], outputs: [])
            updateAudioRoutes()
        case .oldDeviceUnavailable:
            AudioLogger.shared.logRouteChange(reason: "Device disconnected", inputs: [], outputs: [])
            updateAudioRoutes()
        default:
            break
        }
    }
    
    func updateAudioRoutes() {
        let session = AVAudioSession.sharedInstance()

        // Get current route information
        let currentRoute = session.currentRoute
        AudioLogger.shared.logRouteChange(
            reason: "Route update",
            inputs: currentRoute.inputs.map { "\($0.portType) - \($0.portName)" },
            outputs: currentRoute.outputs.map { "\($0.portType) - \($0.portName)" }
        )
    }

    func updateAudioRouting(inputIndex: Int, outputIndex: Int, enabled: Bool) throws {
        // In a real implementation, this would configure audio nodes and connections
        // For now, we'll validate the routing and log the action

        let session = AVAudioSession.sharedInstance()
        let inputs = session.availableInputs ?? []
        let outputs = session.currentRoute.outputs

        guard inputIndex < inputs.count && outputIndex < outputs.count else {
            throw AudioError.invalidConfiguration(reason: "Invalid device indices")
        }

        if enabled {
            // Connect input to output through mixer node
            let inputNode = audioEngine.inputNode
            let outputNode = audioEngine.outputNode

            // Configure audio format
            let format = inputNode.outputFormat(forBus: 0)
            audioEngine.connect(inputNode, to: mixerNode, format: format)
            audioEngine.connect(mixerNode, to: outputNode, format: format)
        } else {
            // Disconnect the routing
            audioEngine.disconnectNodeInput(mixerNode)
        }

        // Apply changes if engine is running
        if audioEngine.isRunning {
            audioEngine.prepare()
        }
    }
    
    func startAudioEngine() throws {
        try audioEngine.start()
    }
    
    func stopAudioEngine() {
        audioEngine.stop()
    }
}
