//
//  TaskCard.swift
//  PILOT
//
//  Task display card component
//

import SwiftUI

struct TaskCard: View {
    let entry: DailyEntry
    let onComplete: (() -> Void)?
    let onRegenerate: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Mood indicator
            HStack {
                Text(entry.mood.emoji)
                    .font(.title2)
                Text(entry.mood.displayName)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(Color(hex: entry.mood.color))
                Spacer()
                if entry.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.success)
                        .font(.title2)
                }
            }

            Divider()
                .background(AppTheme.Colors.textTertiary.opacity(0.3))

            // Task
            Text(entry.task)
                .font(AppTheme.Typography.h3)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Reflection
            Text(entry.reflection)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            // Insight (if present)
            if let insight = entry.insight {
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(AppTheme.Colors.warning)
                    Text(insight)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .italic()
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.warning.opacity(0.1))
                .cornerRadius(AppTheme.Radius.sm)
            }

            // Actions
            if !entry.completed {
                HStack(spacing: AppTheme.Spacing.md) {
                    if let onComplete = onComplete {
                        Button(action: onComplete) {
                            Text("Mark Complete")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryButtonStyle()
                    }

                    if let onRegenerate = onRegenerate {
                        Button(action: onRegenerate) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .secondaryButtonStyle()
                    }
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.success)
                    Text("Completed")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.Colors.success)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.Colors.success.opacity(0.1))
                .cornerRadius(AppTheme.Radius.md)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background.ignoresSafeArea()
        TaskCard(
            entry: DailyEntry(
                date: "2025-10-23",
                mood: .hopeful,
                note: "Feeling good today",
                task: "Spend 20 minutes organizing your workspace",
                reflection: "You're feeling hopeful and energized. This is momentum. Use this positive energy to create a small win that sets the tone for your day.",
                insight: "You tend to complete more tasks when you start before noon.",
                completed: false
            ),
            onComplete: {},
            onRegenerate: {}
        )
        .padding()
    }
}
