//
//  MoodPicker.swift
//  PILOT
//
//  Mood selection component
//

import SwiftUI

struct MoodPicker: View {
    @Binding var selectedMood: Mood?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("How are you feeling?")
                .font(AppTheme.Typography.h3)
                .foregroundColor(AppTheme.Colors.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.md) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood,
                        action: { selectedMood = mood }
                    )
                }
            }
        }
    }
}

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(mood.emoji)
                    .font(.system(size: 40))

                Text(mood.displayName)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(
                isSelected
                    ? Color(hex: mood.color).opacity(0.2)
                    : AppTheme.Colors.cardBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        isSelected ? Color(hex: mood.color) : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(AppTheme.Radius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background.ignoresSafeArea()
        MoodPicker(selectedMood: .constant(.hopeful))
            .padding()
    }
}
