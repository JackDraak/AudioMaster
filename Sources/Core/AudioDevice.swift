import Foundation
import AVFoundation

struct AudioDevice: Identifiable, Hashable {
    let id: String
    let name: String
    let type: AVAudioSession.Port
    let channels: Int
    let isActive: Bool
    let sampleRate: Double

    init(id: String, name: String, type: AVAudioSession.Port, channels: Int = 2, isActive: Bool = false, sampleRate: Double = 44100.0) {
        self.id = id
        self.name = name
        self.type = type
        self.channels = channels
        self.isActive = isActive
        self.sampleRate = sampleRate
    }

    init(from port: AVAudioSessionPortDescription) {
        self.id = port.uid
        self.name = port.portName
        self.type = port.portType
        self.channels = port.channels?.count ?? 2
        self.isActive = true
        self.sampleRate = 44100.0
    }

    var displayName: String {
        if name.isEmpty {
            return type.rawValue
        }
        return name
    }

    var isUSB: Bool {
        return type == .usbAudio
    }

    var supportsMultiChannel: Bool {
        return channels > 2
    }
}

extension AVAudioSession.Port {
    var isInput: Bool {
        switch self {
        case .builtInMic, .headsetMic, .bluetoothHFP, .usbAudio, .lineIn:
            return true
        default:
            return false
        }
    }

    var isOutput: Bool {
        switch self {
        case .builtInSpeaker, .headphones, .bluetoothA2DP, .bluetoothLE, .usbAudio, .lineOut, .airPlay:
            return true
        default:
            return false
        }
    }
}