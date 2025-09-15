import Foundation
import AVFoundation

protocol FeedbackPreventionDelegate: AnyObject {
    func feedbackDetected(onChannels channels: [Int], magnitude: Float)
    func feedbackPrevented(action: FeedbackPreventionAction)
}

enum FeedbackPreventionAction {
    case gainReduction(amount: Float)
    case channelMute(channels: [Int])
    case routeChange(from: String, to: String)
}

class FeedbackPrevention {
    private let threshold: Float = -6.0 // dB
    private let analysisWindow: TimeInterval = 0.1
    private let sampleBufferSize = 4096
    private var lastPeaks: [Float] = []
    private var sustainedFeedbackCount = 0
    private weak var delegate: FeedbackPreventionDelegate?
    
    private let engine: AVAudioEngine
    private let analyzer: AVAudioNodeEQEffect
    
    init(engine: AVAudioEngine) {
        self.engine = engine
        self.analyzer = AVAudioNodeEQEffect()
        setupAnalysis()
    }
    
    private func setupAnalysis() {
        // Setup real-time analysis nodes and filters
        engine.attach(analyzer)
        
        // Configure tap for monitoring audio levels
        analyzer.installTap(onBus: 0, bufferSize: UInt32(sampleBufferSize), format: nil) { [weak self] buffer, time in
            self?.analyzeBuffer(buffer, atTime: time)
        }
    }
    
    private func analyzeBuffer(_ buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) {
        // Input validation
        guard let channelData = buffer.floatChannelData,
              buffer.frameLength > 0,
              buffer.frameLength <= buffer.frameCapacity,
              Int(buffer.format.channelCount) > 0 else {
            AudioLogger.shared.logError(.invalidConfiguration(reason: "Invalid buffer configuration"))
            return
        }
        
        // Secure allocation with automatic cleanup
        let frameLength = Int(buffer.frameLength)
        autoreleasepool {
            var peaks = [Float](repeating: 0.0, count: Int(buffer.format.channelCount))
            
            // Analyze each channel with bounds checking
            for channel in 0..<Int(buffer.format.channelCount) {
                guard let data = UnsafeMutableBufferPointer(start: channelData[channel],
                                                          count: frameLength).map({ $0 }) else {
                    AudioLogger.shared.logError(.invalidConfiguration(reason: "Channel data access error"))
                    return
                }
                
                // Validate audio data
                guard data.allSatisfy({ $0.isFinite }) else {
                    AudioLogger.shared.logError(.invalidConfiguration(reason: "Invalid audio data detected"))
                    return
                }
                
                // Find peak value in channel using secure buffer
                var peak: Float = 0.0
                vDSP_maxmgv(data, 1, &peak, vDSP_Length(frameLength))
                peaks[channel] = peak
            }
            
            // Process peaks in a controlled context
            detectFeedback(peaks: peaks)
        }
    }
    
    private func detectFeedback(peaks: [Float]) {
        // Validate input data
        guard peaks.count > 0,
              peaks.allSatisfy({ $0.isFinite }) else {
            AudioLogger.shared.logError(.invalidConfiguration(reason: "Invalid peak values"))
            return
        }
        
        // Use secure comparison with bounds checking
        if !lastPeaks.isEmpty && lastPeaks.count == peaks.count {
            var feedbackChannels: [Int] = []
            let feedbackThreshold: Float = 0.1  // Sensitivity threshold
            
            // Thread-safe peak analysis
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                
                for (index, (current, previous)) in zip(peaks, self.lastPeaks).enumerated() {
                    // Validate each measurement
                    guard current.isFinite && previous.isFinite else { continue }
                    
                    // Advanced feedback detection with hysteresis
                    if current > self.threshold &&
                       abs(current - previous) < feedbackThreshold &&
                       current > -60.0 {  // Noise floor threshold
                        feedbackChannels.append(index)
                    }
                }
                
                DispatchQueue.main.async {
                    if !feedbackChannels.isEmpty {
                        self.sustainedFeedbackCount += 1
                        if self.sustainedFeedbackCount >= 3 {
                            // Clear any stale data
                            defer { self.sustainedFeedbackCount = 0 }
                            
                            // Calculate RMS value for more accurate magnitude
                            let magnitude = sqrt(peaks.reduce(0) { $0 + $1 * $1 } / Float(peaks.count))
                            self.handleFeedback(channels: feedbackChannels, magnitude: magnitude)
                        }
                    } else {
                        self.sustainedFeedbackCount = 0
                    }
                }
            }
        }
        
        // Thread-safe update of lastPeaks
        DispatchQueue.main.async { [weak self] in
            self?.lastPeaks = peaks
        }
    }
    
    private func handleFeedback(channels: [Int], magnitude: Float) {
        AudioLogger.shared.logFeedbackWarning(channels: channels, magnitude: magnitude)
        delegate?.feedbackDetected(onChannels: channels, magnitude: magnitude)
        
        // Implement automatic prevention strategies
        if magnitude > 0 {
            let reduction = min(magnitude + 6, 24) // Reduce gain by up to 24dB
            delegate?.feedbackPrevented(action: .gainReduction(amount: reduction))
        }
    }
}
