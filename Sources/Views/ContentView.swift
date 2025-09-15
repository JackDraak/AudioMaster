import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioViewModel = AudioViewModel()
    
    var body: some View {
        NavigationView {
            Sidebar(viewModel: audioViewModel)
            MainControlView(viewModel: audioViewModel)
        }
    }
}

struct Sidebar: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        List {
            Section("Input Devices") {
                ForEach(viewModel.inputDevices, id: \.id) { device in
                    DeviceRowView(device: device, isInput: true)
                }
            }
            
            Section("Output Devices") {
                ForEach(viewModel.outputDevices, id: \.id) { device in
                    DeviceRowView(device: device, isInput: false)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 250)
    }
}

struct DeviceRowView: View {
    let device: AudioDevice
    let isInput: Bool

    var body: some View {
        HStack {
            Image(systemName: deviceIcon)
                .foregroundColor(device.isActive ? .green : .gray)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.displayName)
                    .font(.body)
                    .foregroundColor(.primary)

                HStack {
                    Text("\(device.channels) ch")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if device.isUSB {
                        Text("USB")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }

                    Spacer()

                    Text("\(Int(device.sampleRate/1000))kHz")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Circle()
                .fill(device.isActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 2)
    }

    private var deviceIcon: String {
        switch device.type {
        case .builtInMic:
            return "mic"
        case .headsetMic:
            return "headphones.circle"
        case .bluetoothHFP:
            return "bluetooth"
        case .usbAudio:
            return "cable.connector"
        case .lineIn:
            return "line.horizontal.3.decrease"
        case .builtInSpeaker:
            return "speaker"
        case .headphones:
            return "headphones"
        case .bluetoothA2DP, .bluetoothLE:
            return "bluetooth"
        case .lineOut:
            return "line.horizontal.3.decrease.circle"
        case .airPlay:
            return "airplayaudio"
        default:
            return isInput ? "mic" : "speaker"
        }
    }
}
