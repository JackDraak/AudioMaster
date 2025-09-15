import SwiftUI

struct RoutingMatrixView: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        VStack {
            Text("Routing Matrix")
                .font(.headline)
                .padding(.bottom)
            
            // Column Headers (Output Devices)
            HStack {
                Text("")
                    .frame(width: 150)
                ForEach(viewModel.outputDevices, id: \.id) { device in
                    Text(device.name)
                        .rotationEffect(.degrees(-45))
                        .frame(width: 100)
                }
            }
            
            // Matrix Rows
            ForEach(Array(viewModel.inputDevices.enumerated()), id: \.element.id) { inputIndex, input in
                HStack {
                    // Row Header (Input Device)
                    Text(input.name)
                        .frame(width: 150, alignment: .leading)
                    
                    // Routing Toggle Buttons
                    ForEach(Array(viewModel.outputDevices.enumerated()), id: \.element.id) { outputIndex, _ in
                        Toggle("", isOn: Binding(
                            get: { viewModel.routingMatrix[inputIndex][outputIndex] },
                            set: { viewModel.updateRouting(input: inputIndex, output: outputIndex, isEnabled: $0) }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .frame(width: 100)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct InputMetersView: View {
    let levels: [Float]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                LevelMeterView(level: level)
            }
        }
    }
}

struct OutputMetersView: View {
    let levels: [Float]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                LevelMeterView(level: level)
            }
        }
    }
}

struct LevelMeterView: View {
    let level: Float
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach((0..<20).reversed(), id: \.self) { segment in
                    let threshold = Float(segment) / 20.0
                    let isLit = level >= threshold
                    
                    Rectangle()
                        .fill(self.color(for: segment))
                        .opacity(isLit ? 1.0 : 0.2)
                        .frame(height: geometry.size.height / 20 - 1)
                }
            }
        }
        .frame(width: 20)
        .animation(.linear(duration: 0.1), value: level)
    }
    
    private func color(for segment: Int) -> Color {
        switch segment {
        case 16...19: return .red
        case 12...15: return .yellow
        default: return .green
        }
    }
}
