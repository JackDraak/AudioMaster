import SwiftUI

struct PreviewContainer: View {
    static let previewViewModel: AudioViewModel = {
        let vm = AudioViewModel()
        // Add mock data for preview
        return vm
    }()
    
    var body: some View {
        Group {
            // Main Interface Preview
            ContentView()
                .previewDisplayName("Full Interface")
                .previewLayout(.device)
                .previewDevice("iPad Air (4th generation)")
            
            // Routing Matrix Preview
            RoutingMatrixView(viewModel: PreviewContainer.previewViewModel)
                .previewDisplayName("Routing Matrix")
                .previewLayout(.fixed(width: 700, height: 400))
            
            // Meters Preview
            HStack {
                InputMetersView(levels: [0.3, 0.5, 0.8, 0.2])
                OutputMetersView(levels: [0.6, 0.4, 0.7, 0.3])
            }
            .padding()
            .previewDisplayName("Audio Meters")
            .previewLayout(.fixed(width: 300, height: 200))
            
            // Feedback Prevention Preview
            FeedbackPreventionView(viewModel: PreviewContainer.previewViewModel)
                .previewDisplayName("Feedback Prevention")
                .previewLayout(.fixed(width: 400, height: 300))
        }
    }
}

#Preview {
    PreviewContainer()
}
