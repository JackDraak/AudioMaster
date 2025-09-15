import Foundation
import AVFoundation

/// A secure wrapper for audio buffer management with automatic cleanup
final class SecureAudioBuffer {
    private var buffer: AVAudioPCMBuffer?
    private let format: AVAudioFormat
    private let frameCapacity: AVAudioFrameCount
    
    init?(format: AVAudioFormat, frameCapacity: AVAudioFrameCount) {
        guard frameCapacity > 0 else { return nil }
        self.format = format
        self.frameCapacity = frameCapacity
        allocateBuffer()
    }
    
    private func allocateBuffer() {
        buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity)
    }
    
    func withSecureAccess<T>(_ block: (AVAudioPCMBuffer) throws -> T) throws -> T {
        guard let buffer = buffer else {
            throw AudioError.invalidConfiguration(reason: "Buffer not initialized")
        }
        
        // Ensure buffer is in a valid state
        guard buffer.frameCapacity > 0,
              buffer.format == format else {
            throw AudioError.invalidConfiguration(reason: "Buffer in invalid state")
        }
        
        return try autoreleasepool {
            // Execute the block with the buffer
            let result = try block(buffer)
            
            // Clear the buffer after use
            clearBuffer()
            
            return result
        }
    }
    
    private func clearBuffer() {
        guard let buffer = buffer,
              let channelData = buffer.floatChannelData else { return }
        
        // Securely zero out all channel data
        for channel in 0..<Int(buffer.format.channelCount) {
            let data = channelData[channel]
            memset_s(data, Int(buffer.frameCapacity) * MemoryLayout<Float>.size, 0, Int(buffer.frameCapacity) * MemoryLayout<Float>.size)
        }
    }
    
    deinit {
        // Ensure buffer is cleared before deallocation
        clearBuffer()
        buffer = nil
    }
}

extension SecureAudioBuffer {
    /// Validates audio data for common issues
    static func validateAudioData(_ data: UnsafePointer<Float>, count: Int) -> Bool {
        guard count > 0 else { return false }
        
        // Check for invalid values
        for i in 0..<count {
            let sample = data[i]
            guard sample.isFinite,                    // No inf or nan
                  abs(sample) <= 1.0,                // Within normal range
                  sample != sample.nextUp else {      // No denormals
                return false
            }
        }
        
        return true
    }
    
    /// Calculates RMS value safely
    static func calculateRMS(_ data: UnsafePointer<Float>, count: Int) -> Float {
        guard count > 0 else { return 0.0 }
        
        var sum: Float = 0.0
        vDSP_svesq(data, 1, &sum, vDSP_Length(count))
        return sqrt(sum / Float(count))
    }
}
