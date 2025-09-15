import Foundation
import AVFoundation
import CoreAudio

class AudioInterfaceManager {
    static let shared = AudioInterfaceManager()
    private var audioEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    
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
            print("New audio device connected")
            updateAudioRoutes()
        case .oldDeviceUnavailable:
            print("Audio device disconnected")
            updateAudioRoutes()
        default:
            break
        }
    }
    
    func updateAudioRoutes() {
        let session = AVAudioSession.sharedInstance()
        
        // Get current route information
        let currentRoute = session.currentRoute
        print("Current Audio Route:")
        
        for output in currentRoute.outputs {
            print("Output Port: \(output.portType) - \(output.portName)")
        }
        
        for input in currentRoute.inputs {
            print("Input Port: \(input.portType) - \(input.portName)")
        }
    }
    
    func startAudioEngine() {
        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error)")
        }
    }
    
    func stopAudioEngine() {
        audioEngine.stop()
    }
}
