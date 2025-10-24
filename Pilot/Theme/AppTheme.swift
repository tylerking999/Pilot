//
//  AppTheme.swift
//  PILOT
//
//  Design system - ported from theme/tokens.ts
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary
        static let primary = Color(hex: "#6366F1") // Indigo
        static let primaryDark = Color(hex: "#4F46E5")

        // Background
        static let background = Color(hex: "#0A0A0F")
        static let cardBackground = Color(hex: "#1A1A1F")
        static let elevated = Color(hex: "#2A2A2F")

        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "#9CA3AF")
        static let textTertiary = Color(hex: "#6B7280")

        // Border
        static let border = Color(hex: "#374151")

        // Mood Colors
        static let drained = Color(hex: "#6B7280")   // Gray
        static let restless = Color(hex: "#EF4444")  // Red
        static let hopeful = Color(hex: "#10B981")   // Green
        static let scattered = Color(hex: "#F59E0B") // Amber

        // Semantic
        static let success = Color(hex: "#10B981")
        static let error = Color(hex: "#EF4444")
        static let warning = Color(hex: "#F59E0B")
        static let info = Color(hex: "#3B82F6")

        // Gradients
        static func moodGradient(for mood: Mood) -> LinearGradient {
            let topColor: Color
            let bottomColor: Color

            switch mood {
            case .drained:
                topColor = Color(hex: "#1A1A1F")
                bottomColor = Color(hex: "#2D2D35")
            case .restless:
                topColor = Color(hex: "#1A1A1F")
                bottomColor = Color(hex: "#3D1F1F")
            case .hopeful:
                topColor = Color(hex: "#1A1A1F")
                bottomColor = Color(hex: "#1F3D2D")
            case .scattered:
                topColor = Color(hex: "#1A1A1F")
                bottomColor = Color(hex: "#3D2D1F")
            }

            return LinearGradient(
                colors: [topColor, bottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Typography
    struct Typography {
        static let h1 = Font.system(size: 32, weight: .bold)
        static let h2 = Font.system(size: 24, weight: .semibold)
        static let h3 = Font.system(size: 20, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 16, weight: .medium)
        static let caption = Font.system(size: 14, weight: .regular)
        static let small = Font.system(size: 12, weight: .regular)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }

    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )

        static let medium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )

        static let large = Shadow(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )

        static let glow = Shadow(
            color: Colors.primary.opacity(0.3),
            radius: 12,
            x: 0,
            y: 0
        )
    }

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Radius.md)
            .shadow(
                color: AppTheme.Shadows.medium.color,
                radius: AppTheme.Shadows.medium.radius,
                x: AppTheme.Shadows.medium.x,
                y: AppTheme.Shadows.medium.y
            )
    }

    func elevatedCard() -> some View {
        self
            .background(AppTheme.Colors.elevated)
            .cornerRadius(AppTheme.Radius.lg)
            .shadow(
                color: AppTheme.Shadows.large.color,
                radius: AppTheme.Shadows.large.radius,
                x: AppTheme.Shadows.large.x,
                y: AppTheme.Shadows.large.y
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.bodyMedium)
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.primary)
            .cornerRadius(AppTheme.Radius.md)
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.bodyMedium)
            .foregroundColor(AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Radius.md)
    }
}
