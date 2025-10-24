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
    @State private var appear = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Text("✨")
                .font(.system(size: 80))
                .scaleEffect(appear ? 1.0 : 0.5)
                .opacity(appear ? 1 : 0)

            Text("Welcome to PILOT")
                .font(AppTheme.Typography.h1)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            Text("One meaningful task per day.\nFocus on your clarity.")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appear = true
            }
        }
    }
}

// MARK: - Name Page

struct NamePage: View {
    @Binding var userName: String
    @State private var appear = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Text("👋")
                .font(.system(size: 80))
                .scaleEffect(appear ? 1.0 : 0.5)
                .opacity(appear ? 1 : 0)

            Text("What should we call you?")
                .font(AppTheme.Typography.h2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            TextField("Your name", text: $userName)
                .font(AppTheme.Typography.h3)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding()
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.Radius.md)
                .textFieldStyle(.plain)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Theme Page

struct ThemePage: View {
    @Binding var selectedTheme: String
    @State private var appear = false

    let themes = [
        ("dark", "Classic Dark", "moon.stars.fill", "#6366F1"),
        ("midnight", "Midnight Blue", "moon.fill", "#3B82F6"),
        ("purple", "Purple Haze", "sparkles", "#8B5CF6")
    ]

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Text("🎨")
                .font(.system(size: 80))
                .scaleEffect(appear ? 1.0 : 0.5)
                .opacity(appear ? 1 : 0)

            Text("Choose your vibe")
                .font(AppTheme.Typography.h2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            VStack(spacing: AppTheme.Spacing.md) {
                ForEach(Array(themes.enumerated()), id: \.element.0) { index, theme in
                    ThemeOption(
                        id: theme.0,
                        name: theme.1,
                        icon: theme.2,
                        accentColor: theme.3,
                        isSelected: selectedTheme == theme.0,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTheme = theme.0
                            }
                        }
                    )
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: appear)
                }
            }
        }
        .padding()
        .onAppear {
            withAnimation {
                appear = true
            }
        }
    }
}

struct ThemeOption: View {
    let id: String
    let name: String
    let icon: String
    let accentColor: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Color preview circle
                Circle()
                    .fill(Color(hex: accentColor))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(.white)
                    )

                Text(name)
                    .font(AppTheme.Typography.bodyMedium)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: accentColor))
                        .font(.title3)
                }
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .padding()
            .background(
                isSelected
                    ? Color(hex: accentColor).opacity(0.2)
                    : AppTheme.Colors.cardBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        isSelected ? Color(hex: accentColor) : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(AppTheme.Radius.md)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
