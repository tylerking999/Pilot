//
//  PilotApp.swift
//  Pilot
//
//  Main SwiftUI App Entry Point
//

import SwiftUI

@main
struct PilotApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var revenueCat = RevenueCatService.shared

    init() {
        // Configure RevenueCat on app launch
        RevenueCatService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(revenueCat)
                .preferredColorScheme(.dark)
                .onAppear {
                    appState.initialize()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.profile.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "circle.fill")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(AppTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
