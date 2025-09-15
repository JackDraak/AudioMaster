import SwiftUI
import AVFoundation

struct MainControlView: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Audio Routing Matrix
            RoutingMatrixView(viewModel: viewModel)
            
            // Meters and Monitoring
            HStack {
                VStack {
                    Text("Input Levels")
                        .font(.headline)
                    InputMetersView(levels: viewModel.inputLevels)
                }
                
                VStack {
                    Text("Output Levels")
                        .font(.headline)
                    OutputMetersView(levels: viewModel.outputLevels)
                }
            }
            .padding()
            
            // Feedback Prevention Controls
            FeedbackPreventionView(viewModel: viewModel)
        }
        .padding()
        .navigationTitle("Audio Control Center")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: viewModel.toggleMonitoring) {
                    Label(viewModel.isMonitoring ? "Stop Monitoring" : "Start Monitoring",
                          systemImage: viewModel.isMonitoring ? "stop.circle" : "play.circle")
                }
                
                Button(action: viewModel.showSettings) {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}
