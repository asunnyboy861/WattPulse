import SwiftUI
import SwiftData

@main
struct WattPulseApp: App {
    @StateObject private var env = AppEnvironment.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(env)
                .modelContainer(env.modelContainer)
                .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        let mode = UserDefaults.standard.string(forKey: "APPEARANCE_MODE") ?? "system"
        switch mode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
