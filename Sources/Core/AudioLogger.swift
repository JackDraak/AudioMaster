import Foundation
import os.log

class AudioLogger {
    static let shared = AudioLogger()
    private let logger: Logger
    
    private init() {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.audiomaster",
                       category: "AudioSystem")
    }
    
    func logRouteChange(reason: String, inputs: [String], outputs: [String]) {
        logger.info("🔄 Route changed: \(reason) - Inputs: \(inputs.joined(separator: ", ")) Outputs: \(outputs.joined(separator: ", "))")
    }
    
    func logError(_ error: AudioError) {
        logger.error("❌ \(error.localizedDescription)")
    }
    
    func logFeedbackWarning(channels: [Int], magnitude: Float) {
        logger.warning("⚠️ Feedback detected - Channels: \(channels), Magnitude: \(magnitude)")
    }
    
    func logPerformanceMetrics(latency: TimeInterval, bufferSize: Int, sampleRate: Double) {
        logger.debug("📊 Performance - Latency: \(latency)ms, Buffer: \(bufferSize), Rate: \(sampleRate)Hz")
    }
}
