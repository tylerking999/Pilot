//
//  Config.swift
//  Pilot
//
//  API Configuration Manager
//

import Foundation

enum Config {
    // AI Provider
    static let aiProvider: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "AI_PROVIDER") as? String else {
            fatalError("AI_PROVIDER not found in Info.plist")
        }
        return value
    }()

    // Anthropic API Key
    static let anthropicAPIKey: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String else {
            fatalError("ANTHROPIC_API_KEY not found in Info.plist")
        }
        return value
    }()

    // OpenAI API Key
    static let openAIAPIKey: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("OPENAI_API_KEY not found in Info.plist")
        }
        return value
    }()

    // ElevenLabs API Key
    static let elevenLabsAPIKey: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_API_KEY") as? String else {
            fatalError("ELEVENLABS_API_KEY not found in Info.plist")
        }
        return value
    }()

    // ElevenLabs Voice ID
    static let elevenLabsVoiceID: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_VOICE_ID") as? String else {
            fatalError("ELEVENLABS_VOICE_ID not found in Info.plist")
        }
        return value
    }()

    // RevenueCat iOS Key
    static let revenueCatIOSKey: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_IOS_KEY") as? String else {
            fatalError("REVENUECAT_IOS_KEY not found in Info.plist")
        }
        return value
    }()
}

// Usage example:
// let apiKey = Config.anthropicAPIKey
