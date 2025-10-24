# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pilot is a SwiftUI iOS application targeting iOS 26.0+, built with Swift 5.0.

## Build and Test Commands

### Building
```bash
# Build for simulator
xcodebuild -scheme Pilot -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for device
xcodebuild -scheme Pilot -destination 'generic/platform=iOS' build

# Clean build folder
xcodebuild -scheme Pilot clean
```

### Testing
```bash
# Run unit tests
xcodebuild test -scheme Pilot -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test target
xcodebuild test -scheme Pilot -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:PilotTests

# Run UI tests
xcodebuild test -scheme Pilot -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:PilotUITests
```

### Running
Open `Pilot.xcodeproj` in Xcode and run the Pilot scheme (⌘R) on a simulator or connected device.

## Code Architecture

### Structure
- `Pilot/` - Main application code
  - `PilotApp.swift` - App entry point with `@main` attribute
  - `ContentView.swift` - Root SwiftUI view
  - `Assets.xcassets/` - Images and color assets
- `PilotTests/` - Unit tests
- `PilotUITests/` - UI automation tests

### SwiftUI App Pattern
The app follows the standard SwiftUI App lifecycle pattern:
- `PilotApp` defines the app's `WindowGroup` scene
- `ContentView` is the initial view rendered in the window
- Views use SwiftUI's declarative syntax with `View` protocol conformance

## API Configuration

### Environment Variables
API keys and sensitive configuration are managed through `Config.xcconfig`:

**API Keys:**
- `Config.anthropicAPIKey` - Anthropic Claude API key
- `Config.openAIAPIKey` - OpenAI API key (Whisper transcription)
- `Config.elevenLabsAPIKey` - ElevenLabs voice generation API key
- `Config.elevenLabsVoiceID` - ElevenLabs default voice ID
- `Config.revenueCatIOSKey` - RevenueCat iOS SDK key
- `Config.aiProvider` - AI provider selection (default: "claude")

### Setup for New Developers
1. Copy `Config.xcconfig.example` to `Config.xcconfig`
2. Fill in your API keys in `Config.xcconfig`
3. Follow instructions in `SETUP_INSTRUCTIONS.md` to configure Xcode
4. **Never commit `Config.xcconfig`** - it's in `.gitignore`

### Security
- All API keys are stored in `Config.xcconfig` (git-ignored)
- Keys are accessed via `Config.swift` enum from Info.plist
- The xcconfig file must be configured in Xcode project settings
- See `SETUP_INSTRUCTIONS.md` for complete setup guide

## Development Notes

- Bundle identifier: `com.Pilot`
- Supported platforms: iPhone and iOS Simulator
- Use Xcode previews (`#Preview`) for rapid UI iteration
