//
//  OnboardingView.swift
//  PILOT
//
//  First-time user onboarding - ported from app/onboarding.tsx
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedTheme = "dark"

    let totalPages = 3

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack {
                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    WelcomePage()
                        .tag(0)

                    // Page 2: Name
                    NamePage(userName: $userName)
                        .tag(1)

                    // Page 3: Theme
                    ThemePage(selectedTheme: $selectedTheme)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Spacer()

                // Navigation
                HStack {
                    if currentPage > 0 {
                        Button(action: { currentPage -= 1 }) {
                            Text("Back")
                        }
                        .secondaryButtonStyle()
                    }

                    Spacer()

                    if currentPage < totalPages - 1 {
                        Button(action: { currentPage += 1 }) {
                            Text("Next")
                        }
                        .primaryButtonStyle()
                        .disabled(currentPage == 1 && userName.isEmpty)
                    } else {
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                        }
                        .primaryButtonStyle()
                        .disabled(userName.isEmpty)
                    }
                }
                .padding()
            }
        }
    }

    private func completeOnboarding() {
        Task {
            await appState.completeOnboarding(
                userName: userName,
                theme: selectedTheme
            )
        }
    }
}

// MARK: - Welcome Page

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Text("✨")
                .font(.system(size: 80))

            Text("Welcome to PILOT")
                .font(AppTheme.Typography.h1)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("One meaningful task per day.\nFocus on your clarity.")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
        }
        .padding()
    }
}

// MARK: - Name Page

struct NamePage: View {
    @Binding var userName: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Text("👋")
                .font(.system(size: 80))

            Text("What should we call you?")
                .font(AppTheme.Typography.h2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            TextField("Your name", text: $userName)
                .font(AppTheme.Typography.h3)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding()
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.Radius.md)
                .textFieldStyle(.plain)
        }
        .padding()
    }
}

// MARK: - Theme Page

struct ThemePage: View {
    @Binding var selectedTheme: String

    let themes = [
        ("dark", "Dark", "moon.stars.fill"),
        ("midnight", "Midnight", "moon.fill"),
        ("purple", "Purple", "sparkles")
    ]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Text("🎨")
                .font(.system(size: 80))

            Text("Choose your theme")
                .font(AppTheme.Typography.h2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            VStack(spacing: AppTheme.Spacing.md) {
                ForEach(themes, id: \.0) { theme in
                    ThemeOption(
                        id: theme.0,
                        name: theme.1,
                        icon: theme.2,
                        isSelected: selectedTheme == theme.0,
                        action: { selectedTheme = theme.0 }
                    )
                }
            }
        }
        .padding()
    }
}

struct ThemeOption: View {
    let id: String
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(name)
                    .font(AppTheme.Typography.bodyMedium)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .padding()
            .background(
                isSelected
                    ? AppTheme.Colors.primary.opacity(0.2)
                    : AppTheme.Colors.cardBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(AppTheme.Radius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
