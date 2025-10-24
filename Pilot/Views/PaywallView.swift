//
//  PaywallView.swift
//  PILOT
//
//  Subscription paywall - ported from app/paywall.tsx
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var isAnnual: Bool = true // Annual selected by default (better value)

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Header
                        VStack(spacing: AppTheme.Spacing.md) {
                            Text("💜")
                                .font(.system(size: 60))

                            Text("Unlock Your Full Potential")
                                .font(AppTheme.Typography.h1)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Start your 7-day free trial")
                                .font(AppTheme.Typography.h3)
                                .foregroundColor(AppTheme.Colors.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()

                        // Pricing Toggle
                        VStack(spacing: AppTheme.Spacing.md) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                // Monthly Option
                                PricingOptionCard(
                                    title: "Monthly",
                                    price: "$7.99",
                                    period: "per month",
                                    badge: nil,
                                    isSelected: !isAnnual,
                                    onSelect: { isAnnual = false }
                                )

                                // Annual Option
                                PricingOptionCard(
                                    title: "Annual",
                                    price: "$59.99",
                                    period: "per year",
                                    badge: "SAVE 38%",
                                    isSelected: isAnnual,
                                    onSelect: { isAnnual = true }
                                )
                            }
                            .padding(.horizontal)

                            if isAnnual {
                                Text("Just $5/month billed annually")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }

                        // Features List
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            Text("Premium includes:")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            ForEach(SubscriptionTier.premium.features, id: \.self) { feature in
                                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .font(.body)
                                    Text(feature)
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(AppTheme.Radius.md)
                        .padding(.horizontal)

                        // Subscribe Button
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Button(action: subscribe) {
                                Text("Start Free Trial")
                                    .font(AppTheme.Typography.bodyMedium)
                                    .frame(maxWidth: .infinity)
                            }
                            .primaryButtonStyle()
                            .padding(.horizontal)

                            Text("7 days free, then \(isAnnual ? "$59.99/year" : "$7.99/month")")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textSecondary)

                            Text("Cancel anytime")
                                .font(AppTheme.Typography.small)
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        }

                        // Legal Text
                        Text("By subscribing you agree to our Terms of Service and Privacy Policy. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.")
                            .font(AppTheme.Typography.small)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Pilot Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func subscribe() {
        // In a real app, this would integrate with StoreKit/RevenueCat
        Task {
            await appState.setSubscriptionTier(.premium)
            dismiss()
        }
    }
}

// MARK: - Pricing Option Card

struct PricingOptionCard: View {
    let title: String
    let price: String
    let period: String
    let badge: String?
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: AppTheme.Spacing.sm) {
                if let badge = badge {
                    Text(badge)
                        .font(AppTheme.Typography.small)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.success)
                        .cornerRadius(AppTheme.Radius.full)
                } else {
                    Spacer()
                        .frame(height: 24)
                }

                Text(title)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(price)
                    .font(AppTheme.Typography.h2)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(period)
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(
                isSelected
                    ? AppTheme.Colors.primary.opacity(0.15)
                    : AppTheme.Colors.cardBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : AppTheme.Colors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(AppTheme.Radius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
