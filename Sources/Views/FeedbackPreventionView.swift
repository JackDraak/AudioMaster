import SwiftUI

struct FeedbackPreventionView: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Feedback Prevention")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.feedbackWarning {
                    Label("Feedback Detected", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Feedback Prevention Controls
            VStack(alignment: .leading, spacing: 15) {
                ThresholdSlider(
                    value: .constant(-6.0),
                    range: -60.0...0.0,
                    title: "Detection Threshold"
                )
                
                ThresholdSlider(
                    value: .constant(-12.0),
                    range: -60.0...0.0,
                    title: "Prevention Threshold"
                )
                
                HStack {
                    Text("Response Time")
                    Picker("Response Time", selection: .constant(1)) {
                        Text("Fast").tag(0)
                        Text("Medium").tag(1)
                        Text("Slow").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding()
    }
}

struct ThresholdSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack {
                Slider(value: $value, in: range) { _ in
                    // Handle changes
                }
                Text("\(Int(value)) dB")
                    .monospacedDigit()
                    .frame(width: 60)
            }
        }
    }
}

