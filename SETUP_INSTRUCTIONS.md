# API Keys Setup Instructions

## ⚠️ SECURITY WARNING
**The API keys you shared need to be rotated immediately:**
- Anthropic: https://console.anthropic.com/settings/keys
- OpenAI: https://platform.openai.com/api-keys
- ElevenLabs: https://elevenlabs.io/app/settings/api-keys
- RevenueCat: https://app.revenuecat.com/

## Setup Steps

### 1. Configure Xcode to Use Config.xcconfig

1. Open `Pilot.xcodeproj` in Xcode
2. In the Project Navigator, select the **Pilot** project (blue icon at top)
3. Select the **Pilot** target
4. Go to the **Info** tab
5. Under **Configurations**, for both **Debug** and **Release**:
   - Click the dropdown under **Pilot** target
   - Select **Config** (if it appears)
   - If it doesn't appear, you need to add it to the project first:
     - Right-click on the project in Navigator
     - Select "Add Files to Pilot..."
     - Navigate to and select `Config.xcconfig`
     - Make sure "Add to targets" includes Pilot

### 2. Add Environment Variables to Info.plist

1. In Xcode, select the **Pilot** target
2. Go to the **Info** tab
3. Hover over any existing key and click the **+** button
4. Add each of these keys with their values set to `$(KEY_NAME)`:

```
AI_PROVIDER = $(AI_PROVIDER)
ANTHROPIC_API_KEY = $(ANTHROPIC_API_KEY)
OPENAI_API_KEY = $(OPENAI_API_KEY)
ELEVENLABS_API_KEY = $(ELEVENLABS_API_KEY)
ELEVENLABS_VOICE_ID = $(ELEVENLABS_VOICE_ID)
REVENUECAT_IOS_KEY = $(REVENUECAT_IOS_KEY)
```

### 3. Using API Keys in Code

Access your API keys through the `Config` enum:

```swift
import Foundation

// Example usage:
let anthropicKey = Config.anthropicAPIKey
let openAIKey = Config.openAIAPIKey
let elevenLabsKey = Config.elevenLabsAPIKey
let voiceID = Config.elevenLabsVoiceID
let revenueCatKey = Config.revenueCatIOSKey
```

### 4. Verify .gitignore

Ensure `Config.xcconfig` is in `.gitignore` and will NOT be committed to git.

Run:
```bash
git status
```

You should NOT see `Config.xcconfig` in the list of files to be committed.

### 5. Team Setup

For team members:
1. Share `Config.xcconfig.example` in the repository
2. Each team member copies it to `Config.xcconfig`
3. Each team member adds their own API keys to `Config.xcconfig`
4. `Config.xcconfig` stays local and is never committed

## Alternative: Xcode Configuration File Setup via Terminal

If you prefer to set up the xcconfig via command line:

```bash
# This requires manually editing the project.pbxproj file
# It's safer to do this through Xcode UI as described above
```

## Verification

After setup, build the project. If you see errors like:
```
ANTHROPIC_API_KEY not found in Info.plist
```

Double-check that:
1. Config.xcconfig is added to the project
2. The configuration is set in Project Settings → Configurations
3. Info.plist entries are correct with $(VARIABLE_NAME) syntax
