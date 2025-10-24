//
//  InsightsView.swift
//  PILOT
//
//  Insights and patterns - ported from app/insights.tsx
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var appState: AppState
    @State private var weeklyInsight: String?
    @State private var isLoadingInsight = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Stats Overview
                        StatsOverview(
                            totalEntries: appState.entries.count,
                            completedTasks: appState.entries.filter { $0.completed }.count,
                            currentStreak: appState.profile.currentStreak
                        )

                        // Weekly Insight
                        if appState.profile.isPro {
                            WeeklyInsightCard(
                                insight: weeklyInsight,
                                isLoading: isLoadingInsight,
                                onGenerate: generateWeeklyInsight
                            )
                        } else {
                            ProFeatureCard(
                                title: "Weekly Insights",
                                description: "Get AI-powered weekly summaries and pattern analysis",
                                icon: "chart.line.uptrend.xyaxis"
                            )
                        }

                        // Local Patterns
                        if !appState.entries.isEmpty {
                            LocalPatternsCard(entries: appState.entries)
                        }

                        // Mood Distribution
                        MoodDistributionCard(entries: appState.entries)
                    }
                    .padding()
                }
            }
            .navigationTitle("Insights")
            .onAppear {
                if weeklyInsight == nil && appState.profile.isPro {
                    generateWeeklyInsight()
                }
            }
        }
    }

    private func generateWeeklyInsight() {
        isLoadingInsight = true

        Task {
            do {
                let lastWeek = appState.getRecentEntries(limit: 7)
                let insight = try await AIService.shared.generateWeeklyInsights(entries: lastWeek)
                weeklyInsight = insight
            } catch {
                weeklyInsight = "Unable to generate insights at this time."
            }
            isLoadingInsight = false
        }
    }
}

// MARK: - Stats Overview

struct StatsOverview: View {
    let totalEntries: Int
    let completedTasks: Int
    let currentStreak: Int

    var completionRate: Int {
        guard totalEntries > 0 else { return 0 }
        return Int((Double(completedTasks) / Double(totalEntries)) * 100)
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(totalEntries)",
                    label: "Total Tasks",
                    color: AppTheme.Colors.primary
                )

                StatCard(
                    icon: "chart.bar.fill",
                    value: "\(completionRate)%",
                    label: "Completion",
                    color: AppTheme.Colors.success
                )
            }

            StatCard(
                icon: "flame.fill",
                value: "\(currentStreak) days",
                label: "Current Streak",
                color: AppTheme.Colors.warning
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(AppTheme.Typography.h2)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(label)
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

// MARK: - Weekly Insight Card

struct WeeklyInsightCard: View {
    let insight: String?
    let isLoading: Bool
    let onGenerate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppTheme.Colors.primary)
                Text("Weekly Insight")
                    .font(AppTheme.Typography.h3)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Button(action: onGenerate) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .disabled(isLoading)
            }

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let insight = insight {
                Text(insight)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineSpacing(6)
            } else {
                Text("Tap refresh to generate your weekly insight")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .italic()
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Local Patterns Card

struct LocalPatternsCard: View {
    let entries: [DailyEntry]

    var mostProductiveMood: Mood? {
        let moodCompletions = Dictionary(grouping: entries.filter { $0.completed }) { $0.mood }
        return moodCompletions.max { $0.value.count < $1.value.count }?.key
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppTheme.Colors.warning)
                Text("Patterns")
                    .font(AppTheme.Typography.h3)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }

            if let mood = mostProductiveMood {
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    Text(mood.emoji)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Most Productive Mood")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("You complete more tasks when feeling \(mood.displayName.lowercased())")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding()
                .background(Color(hex: mood.color).opacity(0.1))
                .cornerRadius(AppTheme.Radius.sm)
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Mood Distribution Card

struct MoodDistributionCard: View {
    let entries: [DailyEntry]

    var moodCounts: [(Mood, Int)] {
        let grouped = Dictionary(grouping: entries) { $0.mood }
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(AppTheme.Colors.info)
                Text("Mood Distribution")
                    .font(AppTheme.Typography.h3)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }

            ForEach(moodCounts, id: \.0) { mood, count in
                HStack {
                    Text(mood.emoji)
                    Text(mood.displayName)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(count)")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(Color(hex: mood.color))
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Pro Feature Card

struct ProFeatureCard: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.primary)

            Text(title)
                .font(AppTheme.Typography.h3)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(description)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Text("Pro Feature")
                .font(AppTheme.Typography.small)
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(AppTheme.Colors.primary)
                .cornerRadius(AppTheme.Radius.full)
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

#Preview {
    InsightsView()
        .environmentObject(AppState())
}
