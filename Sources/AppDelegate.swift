import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request audio permissions early
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("Audio permission granted: \(granted)")
        }
        
        // Configure audio session for multi-route audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                          mode: .default,
                                                          options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        
        return true
    }
}
