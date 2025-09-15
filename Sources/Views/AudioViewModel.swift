import SwiftUI
import AVFoundation

class AudioViewModel: ObservableObject {
    @Published var inputDevices: [AudioDevice] = []
    @Published var outputDevices: [AudioDevice] = []
    @Published var inputLevels: [Float] = []
    @Published var outputLevels: [Float] = []
    @Published var isMonitoring: Bool = false
    @Published var feedbackWarning: Bool = false
    @Published var routingMatrix: [[Bool]] = []
    
    private let audioManager: AudioInterfaceManager
    private let feedbackPrevention: FeedbackPrevention
    
    init() {
        audioManager = AudioInterfaceManager.shared
        feedbackPrevention = FeedbackPrevention(engine: audioManager.audioEngine)
        setupAudioMonitoring()
    }
    
    func setupAudioMonitoring() {
        // Initialize audio monitoring
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        updateDeviceList()
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        DispatchQueue.main.async {
            self.updateDeviceList()
        }
    }
    
    func updateDeviceList() {
        let session = AVAudioSession.sharedInstance()
        
        // Update input devices
        inputDevices = session.availableInputs?.map { port in
            AudioDevice(id: port.uid, name: port.portName, type: port.portType)
        } ?? []
        
        // Update output devices
        outputDevices = session.currentRoute.outputs.map { port in
            AudioDevice(id: port.uid, name: port.portName, type: port.portType)
        }
        
        // Update routing matrix
        routingMatrix = Array(repeating: Array(repeating: false, count: outputDevices.count),
                            count: inputDevices.count)
    }
    
    func toggleMonitoring() {
        isMonitoring.toggle()
        if isMonitoring {
            do {
                try audioManager.startAudioEngine()
            } catch {
                print("Failed to start monitoring: \(error)")
                isMonitoring = false
            }
        } else {
            audioManager.stopAudioEngine()
        }
    }
    
    func showSettings() {
        // Implement settings sheet presentation
    }
    
    func updateRouting(input: Int, output: Int, isEnabled: Bool) {
        routingMatrix[input][output] = isEnabled
        // Implement actual audio routing update
    }
}
