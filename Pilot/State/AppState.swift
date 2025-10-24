//
//  AppState.swift
//  PILOT
//
//  Global app state management - ported from lib/store.ts (Zustand)
//  Uses ObservableObject for SwiftUI reactivity
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var profile: UserProfile = .default
    @Published var entries: [DailyEntry] = []
    @Published var todayEntry: DailyEntry?
    @Published var currentTask: AIResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var chatThreads: [ChatThread] = []

    private let storage = StorageService.shared
    private let aiService = AIService.shared

    // MARK: - Initialization

    func initialize() {
        Task {
            do {
                profile = try await storage.getProfile()
                entries = try await storage.getEntries()
                todayEntry = try await storage.getTodayEntry()
                chatThreads = try await storage.getChatThreads()

                // Calculate and update streaks
                let streaks = try await storage.calculateStreaks()
                try await storage.updateProfile { p in
                    p.currentStreak = streaks.currentStreak
                    p.longestStreak = streaks.longestStreak
                }
                profile = try await storage.getProfile()
            } catch {
                errorMessage = "Failed to load data: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Task Generation

    func generateDailyTask(mood: Mood, note: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            // Check if user can generate
            guard try await storage.canGenerateTask() else {
                errorMessage = "You've reached your daily limit. Upgrade to Pro for unlimited tasks."
                isLoading = false
                return
            }

            // Get recent entries for context
            let recentEntries = entries
                .sorted { $0.date > $1.date }
                .prefix(7)
                .map { $0 }

            // Generate task with AI
            let response = try await aiService.generateTask(
                mood: mood,
                note: note,
                recentEntries: recentEntries
            )

            // Optional: Detect specific emotion from note
            var detectedEmotion: MoodDetectionResult?
            if let note = note, !note.isEmpty {
                detectedEmotion = try? await aiService.detectMood(note: note)
            }

            // Create entry
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let todayString = dateFormatter.string(from: Date())

            let entry = DailyEntry(
                date: todayString,
                mood: mood,
                note: note,
                task: response.task,
                reflection: response.reflection,
                insight: response.insight,
                emotion: detectedEmotion?.emotion,
                emotionCategory: detectedEmotion?.category,
                completed: false,
                generatedAt: Date()
            )

            // Save entry
            try await storage.saveEntry(entry)
            try await storage.incrementGenerationCount()

            // Update state
            todayEntry = entry
            currentTask = response
            entries = try await storage.getEntries()
            profile = try await storage.getProfile()

        } catch {
            errorMessage = "Failed to generate task: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Task Completion

    func completeTask() async {
        guard let today = todayEntry else { return }

        do {
            try await storage.completeEntry(today.date)

            // Recalculate streaks
            let streaks = try await storage.calculateStreaks()
            try await storage.updateProfile { p in
                p.currentStreak = streaks.currentStreak
                p.longestStreak = streaks.longestStreak
            }

            // Check for milestone
            if let milestone = storage.checkMilestoneAchieved(streaks.currentStreak) {
                // Show celebration (could trigger notification or UI feedback)
                print("Milestone: \(milestone)")
            }

            // Update state
            todayEntry = try await storage.getTodayEntry()
            entries = try await storage.getEntries()
            profile = try await storage.getProfile()

        } catch {
            errorMessage = "Failed to complete task: \(error.localizedDescription)"
        }
    }

    // MARK: - Task Regeneration (Pro only)

    func regenerateTask() async {
        guard profile.isPro else {
            errorMessage = "Task regeneration is a Pro feature"
            return
        }

        guard let current = todayEntry else { return }

        isLoading = true

        do {
            let recentEntries = entries
                .sorted { $0.date > $1.date }
                .prefix(7)
                .map { $0 }

            let response = try await aiService.generateTask(
                mood: current.mood,
                note: current.note,
                recentEntries: recentEntries
            )

            let updatedEntry = DailyEntry(
                id: current.id,
                date: current.date,
                mood: current.mood,
                note: current.note,
                task: response.task,
                reflection: response.reflection,
                insight: response.insight,
                emotion: current.emotion,
                emotionCategory: current.emotionCategory,
                completed: false,
                generatedAt: Date(),
                version: (current.version ?? 1) + 1,
                previousVersions: (current.previousVersions ?? 0) + 1
            )

            try await storage.saveEntry(updatedEntry)
            todayEntry = updatedEntry
            entries = try await storage.getEntries()

        } catch {
            errorMessage = "Failed to regenerate task: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Chat

    func sendChatMessage(_ message: String) async -> String? {
        guard let today = todayEntry else { return nil }

        do {
            // Check if user can send message
            guard try await storage.canSendChatMessage() else {
                errorMessage = "You've used all your chat credits. Upgrade to Pro for unlimited chat."
                return nil
            }

            // Get or create chat thread
            var thread = try await storage.getChatThread(forDate: today.date) ?? ChatThread(
                taskDate: today.date,
                messages: []
            )

            // Send message to AI
            let response = try await aiService.sendChatMessage(
                message: message,
                taskContext: today,
                chatHistory: thread.messages
            )

            // Add messages to thread
            thread.messages.append(ChatMessage(role: .user, content: message))
            thread.messages.append(ChatMessage(role: .assistant, content: response))

            // Save thread
            try await storage.saveChatThread(thread)

            // Use chat credit
            try await storage.useChatCredit()

            // Update state
            chatThreads = try await storage.getChatThreads()
            profile = try await storage.getProfile()

            return response

        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            return nil
        }
    }

    // MARK: - Subscription

    func setSubscriptionTier(_ tier: SubscriptionTier) async {
        do {
            try await storage.updateProfile { p in
                p.subscriptionTier = tier
            }
            profile = try await storage.getProfile()
        } catch {
            errorMessage = "Failed to update subscription: \(error.localizedDescription)"
        }
    }

    // MARK: - Onboarding

    func completeOnboarding(userName: String, theme: String) async {
        do {
            try await storage.updateProfile { p in
                p.hasCompletedOnboarding = true
                p.userName = userName
                p.selectedTheme = theme
            }
            profile = try await storage.getProfile()
        } catch {
            errorMessage = "Failed to save onboarding: \(error.localizedDescription)"
        }
    }

    // MARK: - Settings

    func updateTheme(_ theme: String) async {
        do {
            try await storage.updateProfile { p in
                p.selectedTheme = theme
            }
            profile = try await storage.getProfile()
        } catch {
            errorMessage = "Failed to update theme: \(error.localizedDescription)"
        }
    }

    func resetAccount() async {
        storage.resetAllData()
        profile = .default
        entries = []
        todayEntry = nil
        currentTask = nil
        chatThreads = []
    }

    // MARK: - Helpers

    func getRecentEntries(limit: Int = 14) -> [DailyEntry] {
        entries
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }

    func getChatThread(forDate date: String) -> ChatThread? {
        chatThreads.first { $0.taskDate == date }
    }
}
