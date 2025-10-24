//
//  RevenueCatService.swift
//  Pilot
//
//  RevenueCat subscription management
//

import Foundation
import Combine
import RevenueCat

@MainActor
class RevenueCatService: ObservableObject {
    static let shared = RevenueCatService()

    @Published var isSubscribed = false
    @Published var currentOffering: Offering?
    @Published var subscriptionTier: SubscriptionTier = .free

    private init() {}

    // MARK: - Configuration

    func configure() {
        // Configure RevenueCat with your API key
        Purchases.logLevel = .debug // Remove in production
        Purchases.configure(withAPIKey: Config.revenueCatIOSKey)

        // Set up listener for subscription changes
        Task {
            await checkSubscriptionStatus()
            await fetchOfferings()
        }
    }

    // MARK: - Check Subscription Status

    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateSubscriptionStatus(customerInfo)
        } catch {
            print("Error checking subscription: \(error)")
            isSubscribed = false
            subscriptionTier = .free
        }
    }

    private func updateSubscriptionStatus(_ customerInfo: CustomerInfo) {
        // Check if user has active premium subscription
        if customerInfo.entitlements["premium"]?.isActive == true {
            isSubscribed = true
            subscriptionTier = .premium
        } else {
            isSubscribed = false
            subscriptionTier = .free
        }
    }

    // MARK: - Fetch Offerings

    func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch {
            print("Error fetching offerings: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(package: Package) async throws -> Bool {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            updateSubscriptionStatus(result.customerInfo)
            return result.customerInfo.entitlements["premium"]?.isActive == true
        } catch {
            throw PurchaseError.purchaseFailed(error.localizedDescription)
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            updateSubscriptionStatus(customerInfo)
        } catch {
            throw PurchaseError.restoreFailed(error.localizedDescription)
        }
    }

    // MARK: - Get Subscription Info

    func getSubscriptionInfo() async -> SubscriptionInfo? {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()

            guard let entitlement = customerInfo.entitlements["premium"],
                  entitlement.isActive else {
                return nil
            }

            // Determine if annual or monthly based on product identifier
            let isAnnual = entitlement.productIdentifier.lowercased().contains("annual")
            let periodType = isAnnual ? "Annual" : "Monthly"

            // Check if in trial period
            let isInTrial = entitlement.periodType == .trial

            return SubscriptionInfo(
                isActive: true,
                willRenew: entitlement.willRenew,
                periodType: periodType,
                expirationDate: entitlement.expirationDate,
                isInFreeTrial: isInTrial
            )
        } catch {
            return nil
        }
    }
}

// MARK: - Models

struct SubscriptionInfo {
    let isActive: Bool
    let willRenew: Bool
    let periodType: String
    let expirationDate: Date?
    let isInFreeTrial: Bool
}

enum PurchaseError: LocalizedError {
    case purchaseFailed(String)
    case restoreFailed(String)

    var errorDescription: String? {
        switch self {
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        }
    }
}
