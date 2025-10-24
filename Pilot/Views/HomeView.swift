//
//  HomeView.swift
//  PILOT
//
//  Main home screen - ported from app/index.tsx
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMood: Mood?
    @State private var note: String = ""
    @State private var showingChat = false
    @State private var showingHistory = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Mood-based gradient background
                if let mood = appState.todayEntry?.mood {
                    AppTheme.Colors.moodGradient(for: mood)
                        .ignoresSafeArea()
                } else {
                    AppTheme.Colors.background
                        .ignoresSafeArea()
                }

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Header
                        HeaderSection(profile: appState.profile)

                        // Streak Display
                        StreakDisplay(
                            currentStreak: appState.profile.currentStreak,
                            longestStreak: appState.profile.longestStreak
                        )

                        // Today's Task or Generator
                        if let todayEntry = appState.todayEntry {
                            // Show today's task
                            VStack(spacing: AppTheme.Spacing.md) {
                                TaskCard(
                                    entry: todayEntry,
                                    onComplete: !todayEntry.completed ? {
                                        Task {
                                            await appState.completeTask()
                                        }
                                    } : nil,
                                    onRegenerate: appState.profile.isPro && !todayEntry.completed ? {
                                        Task {
                                            await appState.regenerateTask()
                                        }
                                    } : nil
                                )

                                // Chat button
                                Button(action: { showingChat = true }) {
                                    HStack {
                                        Image(systemName: "message.fill")
                                        Text("Chat about this task")
                                        Spacer()
                                        if !appState.profile.isPro {
                                            Text("\(appState.profile.chatCredits) credits")
                                                .font(AppTheme.Typography.small)
                                                .foregroundColor(AppTheme.Colors.textSecondary)
                                        }
                                    }
                                }
                                .secondaryButtonStyle()
                            }
                        } else {
                            // Show task generator
                            TaskGeneratorSection(
                                selectedMood: $selectedMood,
                                note: $note,
                                isLoading: appState.isLoading,
                                onGenerate: {
                                    guard let mood = selectedMood else { return }
                                    Task {
                                        await appState.generateDailyTask(
                                            mood: mood,
                                            note: note.isEmpty ? nil : note
                                        )
                                    }
                                }
                            )
                        }

                        // Recent History
                        if !appState.entries.isEmpty {
                            HistoryList(
                                entries: Array(appState.getRecentEntries(limit: 5)),
                                onEntryTap: { _ in }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "calendar")
                    }
                }
            }
            .sheet(isPresented: $showingChat) {
                if let todayEntry = appState.todayEntry {
                    ChatView(entry: todayEntry)
                }
            }
            .overlay(
                Group {
                    if let error = appState.errorMessage {
                        ErrorBanner(message: error, onDismiss: {
                            appState.errorMessage = nil
                        })
                    }
                }
            )
        }
    }
}

// MARK: - Header Section

struct HeaderSection: View {
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if let name = profile.userName {
                Text("Hello, \(name)")
                    .font(AppTheme.Typography.h1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            } else {
                Text("Hello")
                    .font(AppTheme.Typography.h1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }

            Text(currentDateString())
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}

// MARK: - Task Generator Section

struct TaskGeneratorSection: View {
    @Binding var selectedMood: Mood?
    @Binding var note: String
    let isLoading: Bool
    let onGenerate: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Mood Picker
            MoodPicker(selectedMood: $selectedMood)

            // Note Input
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Anything else on your mind?")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                TextEditor(text: $note)
                    .frame(height: 100)
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(AppTheme.Radius.sm)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
            }

            // Generate Button
            Button(action: onGenerate) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Generating...")
                    } else {
                        Image(systemName: "sparkles")
                        Text("Generate My Task")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
            .disabled(selectedMood == nil || isLoading)
            .opacity(selectedMood == nil || isLoading ? 0.5 : 1.0)
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppTheme.Colors.error)
                Text(message)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding()
            .background(AppTheme.Colors.error.opacity(0.2))
            .cornerRadius(AppTheme.Radius.md)
            .padding()

            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
