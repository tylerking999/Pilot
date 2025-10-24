//
//  AIService.swift
//  PILOT
//
//  Anthropic Claude API integration - ported from lib/ai.ts
//

import Foundation

class AIService {
    static let shared = AIService()

    private let baseURL = "https://api.anthropic.com/v1/messages"
    private var apiKey: String {
        Config.anthropicAPIKey
    }

    private init() {}

    // MARK: - Task Generation

    func generateTask(mood: Mood, note: String?, recentEntries: [DailyEntry]) async throws -> AIResponse {
        let systemPrompt = AIPrompts.systemPrompt
        let userPrompt = buildUserPrompt(mood: mood, note: note, recentEntries: recentEntries)

        let requestBody: [String: Any] = [
            "model": "claude-3-haiku-20240307",
            "max_tokens": 2048,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userPrompt]
            ]
        ]

        let response = try await makeRequest(body: requestBody)

        // Parse JSON response
        guard let content = response["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }

        // Parse the AI response JSON
        let aiResponse = try parseAIResponse(text)
        return aiResponse
    }

    // MARK: - Chat Message

    func sendChatMessage(
        message: String,
        taskContext: DailyEntry,
        chatHistory: [ChatMessage]
    ) async throws -> String {
        let systemPrompt = AIPrompts.chatSystemPrompt

        var messages: [[String: String]] = []

        // Add context message
        let contextMessage = """
        Today's task: \(taskContext.task)
        Your mood: \(taskContext.mood.displayName)
        Your reflection: \(taskContext.reflection)
        """
        messages.append(["role": "user", "content": contextMessage])

        // Add chat history
        for msg in chatHistory {
            messages.append([
                "role": msg.role.rawValue,
                "content": msg.content
            ])
        }

        // Add new message
        messages.append(["role": "user", "content": message])

        let requestBody: [String: Any] = [
            "model": "claude-3-haiku-20240307",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": messages
        ]

        let response = try await makeRequest(body: requestBody)

        guard let content = response["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }

        return text
    }

    // MARK: - Mood Detection

    func detectMood(note: String) async throws -> MoodDetectionResult {
        let systemPrompt = AIPrompts.moodDetectionPrompt

        let requestBody: [String: Any] = [
            "model": "claude-3-haiku-20240307",
            "max_tokens": 512,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": note]
            ]
        ]

        let response = try await makeRequest(body: requestBody)

        guard let content = response["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }

        // Parse JSON response
        let jsonData = text.data(using: .utf8) ?? Data()
        let result = try JSONDecoder().decode(MoodDetectionResult.self, from: jsonData)
        return result
    }

    // MARK: - Voice Response

    func generateVoiceResponse(mood: Mood, note: String?) async throws -> String {
        let systemPrompt = AIPrompts.voiceResponsePrompt
        let userPrompt = """
        Mood: \(mood.displayName)
        \(note != nil ? "Context: \(note!)" : "No additional context provided")

        Respond naturally as if speaking to them via voice.
        """

        let requestBody: [String: Any] = [
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userPrompt]
            ]
        ]

        let response = try await makeRequest(body: requestBody)

        guard let content = response["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }

        return text
    }

    // MARK: - Weekly Insights

    func generateWeeklyInsights(entries: [DailyEntry]) async throws -> String {
        let systemPrompt = AIPrompts.weeklyInsightsPrompt

        let entriesText = entries.map { entry in
            """
            Date: \(entry.date)
            Mood: \(entry.mood.displayName)
            Task: \(entry.task)
            Completed: \(entry.completed ? "Yes" : "No")
            """
        }.joined(separator: "\n\n")

        let userPrompt = """
        Here's the user's activity from the past 7 days:

        \(entriesText)

        Generate a thoughtful weekly insight that notices patterns and provides encouragement.
        """

        let requestBody: [String: Any] = [
            "model": "claude-3-haiku-20240307",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userPrompt]
            ]
        ]

        let response = try await makeRequest(body: requestBody)

        guard let content = response["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }

        return text
    }

    // MARK: - Private Helpers

    private func makeRequest(body: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            throw AIError.apiError(statusCode: httpResponse.statusCode)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIError.invalidResponse
        }

        return json
    }

    private func buildUserPrompt(mood: Mood, note: String?, recentEntries: [DailyEntry]) -> String {
        var prompt = "Mood: \(mood.displayName)\n"

        if let note = note, !note.isEmpty {
            prompt += "Context: \(note)\n"
        }

        if !recentEntries.isEmpty {
            prompt += "\nRecent history (last 7 days):\n"
            for entry in recentEntries.prefix(7) {
                prompt += """
                - \(entry.date): \(entry.mood.displayName) → "\(entry.task)" (Completed: \(entry.completed ? "Yes" : "No"))

                """
            }
        }

        prompt += "\nGenerate one task for today in JSON format: {\"task\": \"...\", \"reflection\": \"...\", \"insight\": \"...\"}"

        return prompt
    }

    private func parseAIResponse(_ text: String) throws -> AIResponse {
        // Extract JSON from potential markdown code blocks
        var jsonText = text
        if text.contains("```json") {
            let components = text.components(separatedBy: "```json")
            if components.count > 1 {
                let jsonPart = components[1].components(separatedBy: "```")[0]
                jsonText = jsonPart.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        let jsonData = jsonText.data(using: .utf8) ?? Data()
        let response = try JSONDecoder().decode(AIResponse.self, from: jsonData)
        return response
    }
}

// MARK: - Error Types

enum AIError: LocalizedError {
    case invalidURL
    case networkError
    case invalidResponse
    case apiError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError:
            return "Network request failed"
        case .invalidResponse:
            return "Invalid response from API"
        case .apiError(let code):
            return "API error with status code: \(code)"
        }
    }
}
