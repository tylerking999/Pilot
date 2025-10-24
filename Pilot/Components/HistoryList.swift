//
//  HistoryList.swift
//  PILOT
//
//  Recent entries list component
//

import SwiftUI

struct HistoryList: View {
    let entries: [DailyEntry]
    let onEntryTap: ((DailyEntry) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Recent History")
                .font(AppTheme.Typography.h3)
                .foregroundColor(AppTheme.Colors.textPrimary)

            if entries.isEmpty {
                Text("No entries yet")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppTheme.Spacing.xl)
            } else {
                ForEach(entries) { entry in
                    HistoryItem(entry: entry)
                        .onTapGesture {
                            onEntryTap?(entry)
                        }
                }
            }
        }
    }
}

struct HistoryItem: View {
    let entry: DailyEntry

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Mood emoji
            Text(entry.mood.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.task)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(formatDate(entry.date))
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()

            if entry.completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.Colors.success)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.Radius.sm)
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background.ignoresSafeArea()
        ScrollView {
            HistoryList(
                entries: [
                    DailyEntry(
                        date: "2025-10-23",
                        mood: .hopeful,
                        note: nil,
                        task: "Organize workspace",
                        reflection: "You're feeling great!",
                        completed: true
                    ),
                    DailyEntry(
                        date: "2025-10-22",
                        mood: .scattered,
                        note: nil,
                        task: "Write down 3 projects",
                        reflection: "Focus needed",
                        completed: false
                    )
                ],
                onEntryTap: { _ in }
            )
            .padding()
        }
    }
}
