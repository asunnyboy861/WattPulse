import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var hasStartedOnboarding: Bool = false

    var body: some View {
        Group {
            if !env.hasCompletedOnboarding {
                OnboardingFlow(hasStartedOnboarding: $hasStartedOnboarding)
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $env.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
                }
                .tag(0)

            DetailsView()
                .tabItem {
                    Label("Details", systemImage: "chart.bar.fill")
                }
                .tag(1)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "lightbulb.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
    }
}

private struct OnboardingFlow: View {
    @EnvironmentObject private var env: AppEnvironment
    @Binding var hasStartedOnboarding: Bool

    var body: some View {
        if !hasStartedOnboarding {
            WelcomeView(hasStartedOnboarding: $hasStartedOnboarding)
        } else {
            HAConnectView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppEnvironment.shared)
        .modelContainer(AppEnvironment.shared.modelContainer)
}
