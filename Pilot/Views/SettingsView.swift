//
//  SettingsView.swift
//  PILOT
//
//  Settings and account management - ported from app/settings.tsx
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingResetConfirmation = false
    @State private var showingPaywall = false
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                List {
                    // Account Section
                    Section {
                        HStack {
                            Text("Name")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Text(appState.profile.userName ?? "Not set")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }

                        HStack {
                            Text("Subscription")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Text(appState.profile.subscriptionTier.displayName)
                                .foregroundColor(AppTheme.Colors.primary)
                        }

                        if !appState.profile.isPro {
                            Button(action: { showingPaywall = true }) {
                                HStack {
                                    Text("Upgrade to Pro")
                                        .foregroundColor(AppTheme.Colors.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                            }
                        }
                    } header: {
                        Text("Account")
                    }

                    // Usage Section
                    Section {
                        HStack {
                            Text("Current Streak")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(AppTheme.Colors.warning)
                                Text("\(appState.profile.currentStreak)")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }

                        HStack {
                            Text("Longest Streak")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("\(appState.profile.longestStreak)")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }

                        if !appState.profile.isPro {
                            HStack {
                                Text("Chat Credits")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Text("\(appState.profile.chatCredits)")
                                    .foregroundColor(
                                        appState.profile.chatCredits > 0
                                            ? AppTheme.Colors.textPrimary
                                            : AppTheme.Colors.error
                                    )
                            }
                        }
                    } header: {
                        Text("Usage")
                    }

                    // Preferences Section
                    Section {
                        HStack {
                            Text("Theme")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Text(appState.profile.selectedTheme.capitalized)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    } header: {
                        Text("Preferences")
                    }

                    // Data Section
                    Section {
                        if appState.profile.isPro {
                            Button(action: exportData) {
                                HStack {
                                    Text("Export Data")
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    Spacer()
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                            }
                        } else {
                            Button(action: { showingPaywall = true }) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                    Text("Export Data")
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                    Spacer()
                                    Text("Premium")
                                        .font(AppTheme.Typography.small)
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                            }
                        }

                        Button(action: { showingResetConfirmation = true }) {
                            HStack {
                                Text("Reset Account")
                                    .foregroundColor(AppTheme.Colors.error)
                                Spacer()
                            }
                        }
                    } header: {
                        Text("Data")
                    } footer: {
                        Text(appState.profile.isPro
                            ? "Export your data as JSON. Reset will delete all entries permanently."
                            : "This will delete all your entries and reset your profile. This action cannot be undone.")
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }

                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }

                        Link(destination: URL(string: "https://tekhub.app/privacy")!) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                    .font(.caption)
                            }
                        }

                        Link(destination: URL(string: "https://tekhub.app/terms")!) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                    .font(.caption)
                            }
                        }
                    } header: {
                        Text("About")
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(item: $exportURL) { url in
                ShareSheet(activityItems: [url])
            }
            .confirmationDialog(
                "Reset Account",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Account", role: .destructive) {
                    Task {
                        await appState.resetAccount()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all your entries and reset your profile. This action cannot be undone.")
            }
        }
    }

    private func exportData() {
        Task {
            do {
                let entries = appState.entries
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601

                let jsonData = try encoder.encode(entries)

                // Save to temporary file
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "pilot-export-\(Date().timeIntervalSince1970).json"
                let fileURL = tempDir.appendingPathComponent(fileName)

                try jsonData.write(to: fileURL)
                exportURL = fileURL
                showingShareSheet = true
            } catch {
                print("Export failed: \(error)")
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Make URL Identifiable for sheet
extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
