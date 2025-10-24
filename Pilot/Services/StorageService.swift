//
//  StorageService.swift
//  PILOT
//
//  Data persistence layer - ported from lib/storage.ts
//  Uses UserDefaults for local-only storage (MVP)
//

import Foundation

class StorageService {
    static let shared = StorageService()

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let entries = "pilot_entries"
        static let profile = "pilot_profile"
        static let chatThreads = "pilot_chat_threads"
    }

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Entry Management

    func saveEntry(_ entry: DailyEntry) async throws {
        var entries = try await getEntries()

        // Remove existing entry for same date
        entries.removeAll { $0.date == entry.date }

        // Add new entry
        entries.append(entry)

        // Save
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: Keys.entries)
    }

    func getEntries() async throws -> [DailyEntry] {
        guard let data = userDefaults.data(forKey: Keys.entries) else {
            return []
        }
        return try decoder.decode([DailyEntry].self, from: data)
    }

    func getTodayEntry() async throws -> DailyEntry? {
        let today = todayDateString()
        let entries = try await getEntries()
        return entries.first { $0.date == today }
    }

    func getEntryByDate(_ date: String) async throws -> DailyEntry? {
        let entries = try await getEntries()
        return entries.first { $0.date == date }
    }

    func deleteEntry(_ date: String) async throws {
        var entries = try await getEntries()
        entries.removeAll { $0.date == date }
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: Keys.entries)
    }

    func completeEntry(_ date: String) async throws {
        var entries = try await getEntries()
        if let index = entries.firstIndex(where: { $0.date == date }) {
            entries[index].completed = true
            entries[index].completedAt = Date()
            let data = try encoder.encode(entries)
            userDefaults.set(data, forKey: Keys.entries)
        }
    }

    // MARK: - Profile Management

    func saveProfile(_ profile: UserProfile) async throws {
        let data = try encoder.encode(profile)
        userDefaults.set(data, forKey: Keys.profile)
    }

    func getProfile() async throws -> UserProfile {
        guard let data = userDefaults.data(forKey: Keys.profile) else {
            return UserProfile.default
        }
        return try decoder.decode(UserProfile.self, from: data)
    }

    func updateProfile(_ update: @escaping (inout UserProfile) -> Void) async throws {
        var profile = try await getProfile()
        update(&profile)
        try await saveProfile(profile)
    }

    // MARK: - Streak Calculations

    func calculateStreaks() async throws -> StreakInfo {
        let entries = try await getEntries()
        guard !entries.isEmpty else {
            return StreakInfo(currentStreak: 0, longestStreak: 0)
        }

        // Sort by date descending
        let sortedEntries = entries.sorted { $0.date > $1.date }

        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var lastDate: Date?

        let today = todayDateString()
        let yesterday = yesterdayDateString()

        // Check if there's an entry today or yesterday
        let hasRecentEntry = sortedEntries.contains { $0.date == today || $0.date == yesterday }

        for entry in sortedEntries {
            guard let entryDate = dateFromString(entry.date) else { continue }

            if let last = lastDate {
                let dayDiff = Calendar.current.dateComponents([.day], from: entryDate, to: last).day ?? 0

                if dayDiff == 1 {
                    tempStreak += 1
                } else if dayDiff > 1 {
                    // Gap found, reset
                    if hasRecentEntry && currentStreak == 0 {
                        currentStreak = tempStreak
                    }
                    longestStreak = max(longestStreak, tempStreak)
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }

            lastDate = entryDate
            longestStreak = max(longestStreak, tempStreak)
        }

        if hasRecentEntry {
            currentStreak = tempStreak
        } else {
            currentStreak = 0
        }

        longestStreak = max(longestStreak, currentStreak)

        return StreakInfo(currentStreak: currentStreak, longestStreak: longestStreak)
    }

    // MARK: - Chat Thread Management

    func saveChatThread(_ thread: ChatThread) async throws {
        var threads = try await getChatThreads()
        threads.removeAll { $0.taskDate == thread.taskDate }
        threads.append(thread)
        let data = try encoder.encode(threads)
        userDefaults.set(data, forKey: Keys.chatThreads)
    }

    func getChatThreads() async throws -> [ChatThread] {
        guard let data = userDefaults.data(forKey: Keys.chatThreads) else {
            return []
        }
        return try decoder.decode([ChatThread].self, from: data)
    }

    func getChatThread(forDate date: String) async throws -> ChatThread? {
        let threads = try await getChatThreads()
        return threads.first { $0.taskDate == date }
    }

    // MARK: - Usage Tracking

    func useChatCredit() async throws {
        try await updateProfile { profile in
            if profile.chatCredits > 0 {
                profile.chatCredits -= 1
            }
            profile.totalChatsSent += 1
        }
    }

    func canSendChatMessage() async throws -> Bool {
        let profile = try await getProfile()
        return profile.isPro || profile.chatCredits > 0
    }

    func incrementGenerationCount() async throws {
        let today = todayDateString()
        try await updateProfile { profile in
            if profile.lastGenerationDate == today {
                profile.dailyGenerationsToday += 1
            } else {
                profile.dailyGenerationsToday = 1
                profile.lastGenerationDate = today
            }
        }
    }

    func canGenerateTask() async throws -> Bool {
        let profile = try await getProfile()
        let today = todayDateString()

        if profile.isPro {
            return true
        }

        // Free tier: 1 per day
        if profile.lastGenerationDate != today {
            return true
        }

        return profile.dailyGenerationsToday < 1
    }

    func useVoiceCheckIn() async throws {
        try await updateProfile { profile in
            profile.voiceCheckInsThisMonth += 1
        }
    }

    func canUseVoiceConversation() async throws -> (allowed: Bool, remaining: Int) {
        let profile = try await getProfile()
        let limit = profile.subscriptionTier.voiceConversationsPerMonth

        if profile.subscriptionTier == .elite {
            return (true, -1) // Unlimited
        }

        let used = profile.voiceCheckInsThisMonth
        let remaining = max(0, limit - used)
        let allowed = used < limit

        return (allowed, remaining)
    }

    // MARK: - Milestone Checking

    func checkMilestoneAchieved(_ streak: Int) -> String? {
        let milestones = [3, 7, 14, 30, 60, 90, 180, 365]
        if milestones.contains(streak) {
            return "🔥 \(streak) day streak!"
        }
        return nil
    }

    // MARK: - Helper Functions

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func yesterdayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return formatter.string(from: yesterday)
    }

    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }

    // MARK: - Reset (for debugging/testing)

    func resetAllData() {
        userDefaults.removeObject(forKey: Keys.entries)
        userDefaults.removeObject(forKey: Keys.profile)
        userDefaults.removeObject(forKey: Keys.chatThreads)
    }
}
