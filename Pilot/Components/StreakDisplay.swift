//
//  StreakDisplay.swift
//  PILOT
//
//  Streak indicator component
//

import SwiftUI

struct StreakDisplay: View {
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            // Current Streak
            StreakItem(
                icon: "flame.fill",
                label: "Current",
                value: currentStreak,
                color: currentStreak > 0 ? AppTheme.Colors.warning : AppTheme.Colors.textTertiary
            )

            Divider()
                .frame(height: 40)
                .background(AppTheme.Colors.textTertiary.opacity(0.3))

            // Longest Streak
            StreakItem(
                icon: "crown.fill",
                label: "Best",
                value: longestStreak,
                color: AppTheme.Colors.primary
            )
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

struct StreakItem: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(AppTheme.Typography.h2)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(label)
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background.ignoresSafeArea()
        StreakDisplay(currentStreak: 7, longestStreak: 14)
            .padding()
    }
}
