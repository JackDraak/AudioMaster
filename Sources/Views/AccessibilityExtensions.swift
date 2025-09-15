import SwiftUI

// Extension to add accessibility features to our custom views
extension View {
    func audioControlAccessibility(label: String, hint: String? = nil) -> some View {
        self.accessibility(label: Text(label))
            .accessibility(hint: hint.map { Text($0) })
            .accessibilityElement(children: .combine)
    }
}

extension RoutingMatrixView {
    func makeAccessible() -> some View {
        self
            .audioControlAccessibility(
                label: "Audio Routing Matrix",
                hint: "Grid of toggles to route audio between inputs and outputs"
            )
            .accessibilityRotor("Routing Controls") {
                ForEach(viewModel.inputDevices.indices, id: \.self) { inputIdx in
                    ForEach(viewModel.outputDevices.indices, id: \.self) { outputIdx in
                        AccessibilityRotorEntry("Route \(viewModel.inputDevices[inputIdx].name) to \(viewModel.outputDevices[outputIdx].name)") {
                            // Navigation action
                        }
                    }
                }
            }
    }
}

extension LevelMeterView {
    func makeAccessible() -> some View {
        self
            .audioControlAccessibility(
                label: "Audio Level Meter",
                hint: "Shows current audio level in decibels"
            )
            .accessibilityValue(Text("\(Int(level * 100))% volume"))
            .accessibilityAdjustableAction { direction in
                // Handle volume adjustment via accessibility
            }
    }
}

extension FeedbackPreventionView {
    func makeAccessible() -> some View {
        self
            .audioControlAccessibility(
                label: "Feedback Prevention Controls",
                hint: "Adjust feedback detection and prevention settings"
            )
            .accessibilityAction(named: "Reset Thresholds") {
                // Reset action
            }
    }
}

// Accessibility-specific color schemes
extension Color {
    static let highContrastPrimary = Color("HighContrastPrimary")
    static let highContrastSecondary = Color("HighContrastSecondary")
    
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(dark)
            }
            return UIColor(light)
        })
    }
}

// VoiceOver improvements for audio monitoring
extension AudioViewModel {
    func announceAudioLevelChange(for device: AudioDevice, level: Float) {
        if level > 0.8 {
            UIAccessibility.post(notification: .announcement,
                               argument: "High audio level detected on \(device.name)")
        }
    }
    
    func announceFeedbackWarning() {
        UIAccessibility.post(notification: .warning,
                           argument: "Audio feedback detected")
    }
}
