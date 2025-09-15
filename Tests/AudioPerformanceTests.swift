import XCTest
import AVFoundation
@testable import AudioMaster

/// Performance and reliability tests for real-time audio processing
class AudioPerformanceTests: XCTestCase {
    var engine: AVAudioEngine!
    var feedbackPrevention: FeedbackPrevention!
    
    // Standard audio parameters for testing
    let sampleRate: Double = 48000
    let expectedLatency: TimeInterval = 0.005 // 5ms target latency
    let bufferSize = 512 // Standard buffer size for low latency
    
    override func setUp() {
        super.setUp()
        engine = AVAudioEngine()
        feedbackPrevention = FeedbackPrevention(engine: engine)
    }
    
    override func tearDown() {
        engine.stop()
        engine = nil
        feedbackPrevention = nil
        super.tearDown()
    }
    
    /// Test audio processing latency under normal conditions
    func testAudioLatency() {
        measure {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setPreferredIOBufferDuration(Double(bufferSize) / sampleRate)
                let actualLatency = session.outputLatency
                XCTAssertLessThanOrEqual(actualLatency, expectedLatency, 
                    "Output latency (\(actualLatency)s) exceeds target (\(expectedLatency)s)")
            } catch {
                XCTFail("Failed to configure audio session: \(error)")
            }
        }
    }
    
    /// Test CPU usage during audio processing
    func testProcessingLoad() {
        // Setup audio processing chain
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        let audioFile = try? AVAudioFile(forReading: createTestAudioFile())
        
        guard let file = audioFile else {
            XCTFail("Could not create test audio file")
            return
        }
        
        // Measure CPU usage during processing
        var threadInfo = thread_basic_info()
        var count = mach_msg_type_number_t(THREAD_BASIC_INFO_COUNT)
        let thread = pthread_mach_thread_np(pthread_self())
        
        measure {
            let startTime = ProcessInfo.processInfo.systemUptime
            try? engine.start()
            
            // Process 5 seconds of audio
            Thread.sleep(forTimeInterval: 5)
            
            withUnsafeMutablePointer(to: &threadInfo) { infoPointer in
                thread_info(thread, thread_basic_info_t(bitPattern: UInt32(THREAD_BASIC_INFO)),
                          infoPointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { $0 },
                          &count)
            }
            
            let cpuUsage = Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE)
            XCTAssertLessThan(cpuUsage, 0.3, "CPU usage exceeded 30%")
            
            engine.stop()
        }
    }
    
    /// Test feedback detection response time
    func testFeedbackDetectionSpeed() {
        let delegate = MockFeedbackPreventionDelegate()
        feedbackPrevention.delegate = delegate
        
        measure {
            // Simulate feedback by creating a sine wave at a known feedback frequency
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(bufferSize))!
            
            // Fill buffer with sine wave
            let frequency: Float = 1000.0 // 1kHz test tone
            let amplitude: Float = 0.8
            
            for frame in 0..<Int(buffer.frameCapacity) {
                let value = amplitude * sin(2.0 * Float.pi * frequency * Float(frame) / Float(sampleRate))
                buffer.floatChannelData?[0][frame] = value
                buffer.floatChannelData?[1][frame] = value
            }
            
            buffer.frameLength = buffer.frameCapacity
            
            // Start timing feedback detection
            let startTime = DispatchTime.now()
            feedbackPrevention.analyzeBuffer(buffer, atTime: AVAudioTime(hostTime: 0))
            let endTime = DispatchTime.now()
            
            let detectionTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0 // ms
            XCTAssertLessThan(detectionTime, 1.0, "Feedback detection took longer than 1ms")
        }
    }
    
    /// Helper to create test audio file
    private func createTestAudioFile() -> URL {
        let documentsPath = FileManager.default.temporaryDirectory
        let testFileURL = documentsPath.appendingPathComponent("test_audio.wav")
        
        // Create simple test audio file
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let file = try? AVAudioFile(forWriting: testFileURL, settings: format.settings)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleRate))!
        
        // Fill with simple sine wave
        for frame in 0..<Int(buffer.frameCapacity) {
            let value = sin(2.0 * Double.pi * 440.0 * Double(frame) / sampleRate)
            buffer.floatChannelData?[0][frame] = Float(value)
            buffer.floatChannelData?[1][frame] = Float(value)
        }
        buffer.frameLength = buffer.frameCapacity
        
        try? file?.write(from: buffer)
        
        return testFileURL
    }
}
