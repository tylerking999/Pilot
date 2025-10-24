//
//  DataModels.swift
//  PILOT
//
//  Core data models ported from TypeScript types/index.ts
//

import Foundation

// MARK: - Mood
enum Mood: String, Codable, CaseIterable {
    case drained = "drained"
    case restless = "restless"
    case hopeful = "hopeful"
    case scattered = "scattered"

    var color: String {
        switch self {
        case .drained: return "#6B7280"  // Gray
        case .restless: return "#EF4444" // Red
        case .hopeful: return "#10B981"  // Green
        case .scattered: return "#F59E0B" // Amber
        }
    }

    var displayName: String {
        rawValue.capitalized
    }

    var emoji: String {
        switch self {
        case .drained: return "😔"
        case .restless: return "😤"
        case .hopeful: return "😊"
        case .scattered: return "😵‍💫"
        }
    }
}

// MARK: - Subscription Tier
enum SubscriptionTier: String, Codable {
    case free = "free"
    case premium = "premium"

    // Legacy tiers (for data compatibility)
    case pro = "pro"
    case elite = "elite"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        case .pro: return "Premium" // Legacy: treat as premium
        case .elite: return "Premium" // Legacy: treat as premium
        }
    }

    var price: Double {
        switch self {
        case .free: return 0.0
        case .premium, .pro, .elite: return 7.99
        }
    }

    var annualPrice: Double {
        switch self {
        case .free: return 0.0
        case .premium, .pro, .elite: return 59.99 // Save $36/year
        }
    }

    var hasFreeTrial: Bool {
        switch self {
        case .free: return false
        case .premium, .pro, .elite: return true
        }
    }

    var trialDays: Int {
        return 7 // 7-day free trial for Premium
    }

    var features: [String] {
        switch self {
        case .free:
            return [
                "1 AI task per day",
                "3 chat messages total",
                "Basic mood tracking",
                "7-day history",
                "Streak tracking"
            ]
        case .premium, .pro, .elite:
            return [
                "Unlimited AI tasks",
                "Unlimited chat messages",
                "Task regeneration",
                "Weekly AI insights",
                "Advanced emotion tracking",
                "Full history & analytics",
                "Export your data",
                "Priority support"
            ]
        }
    }
}

// MARK: - AI Provider
enum AIProvider: String, Codable {
    case claude = "claude"
    case openai = "openai"
}

// MARK: - Daily Entry
struct DailyEntry: Codable, Identifiable {
    let id: UUID
    let date: String // ISO date string (YYYY-MM-DD)
    let mood: Mood
    let note: String?
    let task: String
    let reflection: String
    let insight: String?
    let emotion: String?
    let emotionCategory: String?
    var completed: Bool
    let generatedAt: Date
    var completedAt: Date?
    let version: Int?
    let previousVersions: Int?

    init(
        id: UUID = UUID(),
        date: String,
        mood: Mood,
        note: String?,
        task: String,
        reflection: String,
        insight: String? = nil,
        emotion: String? = nil,
        emotionCategory: String? = nil,
        completed: Bool = false,
        generatedAt: Date = Date(),
        completedAt: Date? = nil,
        version: Int? = nil,
        previousVersions: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
        self.task = task
        self.reflection = reflection
        self.insight = insight
        self.emotion = emotion
        self.emotionCategory = emotionCategory
        self.completed = completed
        self.generatedAt = generatedAt
        self.completedAt = completedAt
        self.version = version
        self.previousVersions = previousVersions
    }
}

// MARK: - AI Response
struct AIResponse: Codable {
    let task: String
    let reflection: String
    let insight: String?
}

// MARK: - User Profile
struct UserProfile: Codable {
    var createdAt: Date
    var subscriptionTier: SubscriptionTier
    var isPro: Bool {
        subscriptionTier != .free
    }
    var dailyGenerationsToday: Int
    var lastGenerationDate: String?
    var chatCredits: Int
    var totalChatsSent: Int
    var currentStreak: Int
    var longestStreak: Int
    var voiceEnabled: Bool
    var selectedVoice: String
    var voiceCheckInsThisMonth: Int
    var voiceMessagesThisMonth: Int
    var voiceUsageResetDate: Date
    var unlockedVoices: [String]
    var hasCompletedOnboarding: Bool
    var selectedTheme: String
    var userName: String?

    static var `default`: UserProfile {
        UserProfile(
            createdAt: Date(),
            subscriptionTier: .free,
            dailyGenerationsToday: 0,
            lastGenerationDate: nil,
            chatCredits: 3,
            totalChatsSent: 0,
            currentStreak: 0,
            longestStreak: 0,
            voiceEnabled: false,
            selectedVoice: "charlotte",
            voiceCheckInsThisMonth: 0,
            voiceMessagesThisMonth: 0,
            voiceUsageResetDate: Date(),
            unlockedVoices: ["charlotte"],
            hasCompletedOnboarding: false,
            selectedTheme: "dark",
            userName: nil
        )
    }
}

// MARK: - Chat Message
struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

enum MessageRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
}

// MARK: - Chat Thread
struct ChatThread: Codable, Identifiable {
    let id: UUID
    let taskDate: String
    var messages: [ChatMessage]
    let createdAt: Date

    init(id: UUID = UUID(), taskDate: String, messages: [ChatMessage] = [], createdAt: Date = Date()) {
        self.id = id
        self.taskDate = taskDate
        self.messages = messages
        self.createdAt = createdAt
    }
}

// MARK: - Streak Info
struct StreakInfo {
    let currentStreak: Int
    let longestStreak: Int
}

// MARK: - Mood Detection Result
struct MoodDetectionResult: Codable {
    let emotion: String
    let category: String
    let reasoning: String
    let confidence: String
}
