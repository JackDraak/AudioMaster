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
    private var levelTimer: Timer?
    private var levelUpdateQueue = DispatchQueue(label: "com.audiomaster.levels", qos: .userInteractive)

    init() {
        audioManager = AudioInterfaceManager.shared
        feedbackPrevention = FeedbackPrevention(engine: audioManager.audioEngine)
        setupAudioMonitoring()
        startLevelMonitoring()
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
            AudioDevice(from: port)
        } ?? []

        // Update output devices
        outputDevices = session.currentRoute.outputs.map { port in
            AudioDevice(from: port)
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
                AudioLogger.shared.logError(.engineStartFailure(underlying: error))
                isMonitoring = false
            }
        } else {
            audioManager.stopAudioEngine()
        }
    }
    
    func showSettings() {
        // Implement settings sheet presentation
    }

    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateLevels()
        }
    }

    private func updateLevels() {
        levelUpdateQueue.async { [weak self] in
            guard let self = self else { return }

            // Simulate level monitoring for now
            let inputLevels = (0..<self.inputDevices.count).map { _ in Float.random(in: 0...1) }
            let outputLevels = (0..<self.outputDevices.count).map { _ in Float.random(in: 0...1) }

            DispatchQueue.main.async {
                self.inputLevels = inputLevels
                self.outputLevels = outputLevels
            }
        }
    }

    deinit {
        levelTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateRouting(input: Int, output: Int, isEnabled: Bool) {
        guard input < routingMatrix.count && output < routingMatrix[input].count else {
            AudioLogger.shared.logError(.invalidConfiguration(reason: "Invalid routing matrix indices"))
            return
        }

        routingMatrix[input][output] = isEnabled

        // Implement actual audio routing update
        do {
            try audioManager.updateAudioRouting(inputIndex: input, outputIndex: output, enabled: isEnabled)
            AudioLogger.shared.logRouteChange(
                reason: "Manual routing update",
                inputs: [inputDevices[input].name],
                outputs: [outputDevices[output].name]
            )
        } catch {
            AudioLogger.shared.logError(.routingError(description: "Failed to update routing: \(error.localizedDescription)"))
            // Revert the UI change
            routingMatrix[input][output] = !isEnabled
        }
    }
}
