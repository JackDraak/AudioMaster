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
