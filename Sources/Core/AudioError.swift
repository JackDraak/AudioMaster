import Foundation

enum AudioError: LocalizedError {
    case engineStartFailure(underlying: Error)
    case routingError(description: String)
    case invalidConfiguration(reason: String)
    case deviceNotFound(deviceName: String)
    case feedbackDetected(channels: [Int])
    case bufferOverrun(timestamp: TimeInterval)
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .engineStartFailure(let error):
            return "Failed to start audio engine: \(error.localizedDescription)"
        case .routingError(let description):
            return "Audio routing error: \(description)"
        case .invalidConfiguration(let reason):
            return "Invalid configuration: \(reason)"
        case .deviceNotFound(let deviceName):
            return "Device not found: \(deviceName)"
        case .feedbackDetected(let channels):
            return "Audio feedback detected on channels: \(channels.map(String.init).joined(separator: ", "))"
        case .bufferOverrun(let timestamp):
            return "Buffer overrun detected at \(timestamp)"
        case .permissionDenied:
            return "Audio permission denied by user"
        }
    }
}
