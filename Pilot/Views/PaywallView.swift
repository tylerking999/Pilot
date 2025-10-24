//
//  PaywallView.swift
//  PILOT
//
//  Subscription paywall with RevenueCat integration
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var revenueCat: RevenueCatService
    @Environment(\.dismiss) var dismiss

    @State private var isAnnual: Bool = true // Annual selected by default (better value)
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var selectedPackage: Package?

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
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text(isPurchasing ? "Processing..." : "Start Free Trial")
                                        .font(AppTheme.Typography.bodyMedium)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .primaryButtonStyle()
                            .disabled(isPurchasing || revenueCat.currentOffering == nil)
                            .padding(.horizontal)

                            if let error = errorMessage {
                                Text(error)
                                    .font(AppTheme.Typography.small)
                                    .foregroundColor(AppTheme.Colors.error)
                                    .multilineTextAlignment(.center)
                            }

                            Text("7 days free, then \(isAnnual ? "$59.99/year" : "$7.99/month")")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textSecondary)

                            Button("Restore Purchases") {
                                restorePurchases()
                            }
                            .font(AppTheme.Typography.small)
                            .foregroundColor(AppTheme.Colors.textTertiary)

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
            .onAppear {
                // Select the appropriate package based on user choice
                updateSelectedPackage()
            }
            .onChange(of: isAnnual) { _, _ in
                updateSelectedPackage()
            }
        }
    }

    private func updateSelectedPackage() {
        guard let offering = revenueCat.currentOffering else { return }

        // Find monthly or annual package
        if isAnnual {
            // Look for annual package first
            selectedPackage = offering.annual ?? offering.availablePackages.first { package in
                package.storeProduct.subscriptionPeriod?.unit == .year
            }
        } else {
            // Look for monthly package
            selectedPackage = offering.monthly ?? offering.availablePackages.first { package in
                package.storeProduct.subscriptionPeriod?.unit == .month
            }
        }
    }

    private func subscribe() {
        guard let package = selectedPackage else {
            errorMessage = "Unable to load subscription options. Please try again."
            return
        }

        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                let success = try await revenueCat.purchase(package: package)
                if success {
                    // Update app state with premium subscription
                    await appState.setSubscriptionTier(.premium)
                    dismiss()
                } else {
                    errorMessage = "Purchase was not completed."
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isPurchasing = false
        }
    }

    private func restorePurchases() {
        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                try await revenueCat.restorePurchases()
                if revenueCat.isSubscribed {
                    await appState.setSubscriptionTier(.premium)
                    dismiss()
                } else {
                    errorMessage = "No purchases found to restore."
                }
            } catch {
                errorMessage = "Restore failed: \(error.localizedDescription)"
            }
            isPurchasing = false
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
