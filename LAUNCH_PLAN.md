# 🚀 PILOT - Launch Plan & Feature Roadmap

## 📊 Current Status: MVP Complete ✅
You have a working SwiftUI app with:
- ✅ AI-powered task generation
- ✅ Mood tracking & streaks
- ✅ Chat functionality
- ✅ 4-tier subscription model ($0, $14.99, $24.99, $49.99)
- ✅ API integration (Claude, OpenAI, ElevenLabs, RevenueCat keys ready)
- ✅ Local data persistence

---

## 🎯 CRITICAL PATH TO LAUNCH (Must-Haves)

### 1. 💰 REAL MONETIZATION (Week 1 Priority)
**Status:** Currently using placeholder subscription switching

#### Implementation Tasks:
- [ ] **Integrate RevenueCat SDK**
  - Add RevenueCat Swift package to Xcode
  - Configure with your `appl_kVcTpxZjBCBjoNzOSYMgFzuMYqa` key
  - Set up products in App Store Connect

- [ ] **Create In-App Purchase Products**
  - App Store Connect → Features → In-App Purchases
  - Create 3 auto-renewable subscriptions:
    - `pilot.pro.monthly` - $14.99/month
    - `pilot.premium.monthly` - $24.99/month
    - `pilot.elite.monthly` - $49.99/month
  - Add localized descriptions for each tier

- [ ] **Implement StoreKit 2 / RevenueCat**
  ```swift
  // Replace PaywallView.swift subscribe() function
  // Add real purchase flow with Purchases SDK
  // Handle purchase restoration
  // Verify subscription status on app launch
  ```

- [ ] **Test Subscription Flow**
  - Sandbox testing with test account
  - Purchase, restore, cancel flows
  - Family Sharing (if enabled)
  - Trial period (consider 7-day free trial)

**Revenue Optimization:**
- Consider annual subscriptions with 20% discount
- Add lifetime unlock option at $99.99-$199.99
- A/B test free trial length (3 days vs 7 days)

---

### 2. 🎨 APP STORE ASSETS (Week 1 Priority)

#### A. App Icon (1024x1024px)
**Design Brief:**
- Modern, minimal design
- Represents mental wellness + AI
- Colors: Use AppTheme.Colors.primary (#7C3AED purple) as base
- Consider: Brain + checkmark, Mood circles, or Abstract pilot symbol
- Test at small sizes (ensure readability at 60x60px)

**Tools:**
- Design in Figma/Canva (free templates available)
- Use SF Symbols as inspiration
- Export at @1x, @2x, @3x for all sizes

**Icon Generator:**
```bash
# Use this service to generate all required sizes:
# https://www.appicon.co/ or https://appicon.build/
```

#### B. Screenshots (Required: 6.7" & 6.5" displays)
Create 3-6 screenshots showcasing:
1. **Onboarding** - "AI that understands your mood"
2. **Task Generation** - "Personalized tasks every day"
3. **Streak Tracking** - "Build consistency, see progress"
4. **Chat Feature** - "Talk it through with AI"
5. **Insights** - "Understand your patterns" (Pro feature)
6. **Subscription** - "Unlock unlimited potential"

**Screenshot Tips:**
- Add device frames (use screenshots.pro or Shotsnapp)
- Add captions with value props
- Show diverse moods (not just "hopeful")
- Display actual generated tasks (not placeholder text)

#### C. App Preview Video (Optional but Recommended)
- 15-30 second demo video
- Show: Mood selection → Task generation → Completion + Streak
- Add upbeat music (royalty-free from Epidemic Sound)
- Voiceover: "Meet Pilot. Your AI companion for daily momentum."

#### D. App Store Metadata
```
App Name: Pilot - AI Daily Tasks
Subtitle: Mood-based productivity coach

Description:
Pilot understands how you feel and generates one meaningful task
every day—perfectly matched to your mood. Build streaks, gain insights,
and chat with your AI companion.

Features:
✨ AI-powered task generation
📊 Mood & emotion tracking
🔥 Streak tracking
💬 Supportive AI chat
📈 Weekly insights & patterns
🎯 One task, every day

Keywords:
mental health, productivity, AI, mood tracker, daily planner,
task manager, mindfulness, habit tracker, streak, wellness
```

---

### 3. 🧪 TESTING PLAN (Week 1-2)

#### A. Manual Testing Checklist
Create test scenarios for:

**Onboarding Flow:**
- [ ] New user sees 3-page onboarding
- [ ] Can input name and select theme
- [ ] Onboarding dismisses after completion
- [ ] Can't access app without completing onboarding

**Task Generation:**
- [ ] Can select each of 4 moods
- [ ] Can add optional note
- [ ] AI generates task within 5 seconds
- [ ] Task, reflection, and insight display correctly
- [ ] Free tier limited to 1 task/day (test hitting limit)
- [ ] Pro tier allows unlimited generation

**Task Completion:**
- [ ] Can mark task complete
- [ ] Streak increments correctly
- [ ] Completion confetti/animation triggers
- [ ] Can't generate new task after completing

**Chat:**
- [ ] Chat opens with task context
- [ ] Can send message and get AI response
- [ ] Free tier limited to 3 total messages
- [ ] Pro tier unlimited messages
- [ ] Chat history persists

**Streaks:**
- [ ] Current streak shows correctly
- [ ] Longest streak tracked
- [ ] Streak breaks if day missed
- [ ] Milestone notifications (3, 7, 30 days)

**Subscriptions:**
- [ ] Paywall shows when free limit hit
- [ ] Can purchase subscription
- [ ] Features unlock after purchase
- [ ] Can restore purchases
- [ ] Subscription status persists after restart

**Settings:**
- [ ] Shows current plan correctly
- [ ] Can reset account (with confirmation)
- [ ] Usage stats display accurately
- [ ] Can export data (Pro feature)

#### B. Edge Cases
- [ ] What happens if API key invalid?
- [ ] What if network offline?
- [ ] What if user denies notifications?
- [ ] What if subscription expires?
- [ ] What if user changes timezone?
- [ ] Data migration after app update

#### C. Device Testing
Test on these real devices (not just simulator):
- [ ] iPhone SE (smallest screen)
- [ ] iPhone 15 Pro (current flagship)
- [ ] iPhone 15 Pro Max (largest screen)
- [ ] iPad (if supporting tablets)

#### D. Beta Testing
- [ ] TestFlight with 5-10 friends/family
- [ ] Collect feedback on UX confusion points
- [ ] Monitor crash reports
- [ ] Fix critical bugs before public launch

---

### 4. ⚡️ MISSING CRITICAL FEATURES

#### A. Voice Mode (Mentioned in Tiers but Not Implemented)
**Current:** Voice features promised but not built
**Fix Options:**
1. **Remove from free/pro tiers** - Simplify for v1.0
2. **Implement basic version:**
   - Use iOS Speech framework for transcription
   - Use ElevenLabs API (key already configured) for TTS
   - Add voice button in HomeView
   - Voice conversation = chat with voice I/O

**Recommendation:** Remove voice for v1.0, add in v1.1 update

#### B. Data Export (Promised in Premium)
```swift
// Add to SettingsView.swift
func exportData() async {
    let entries = await storage.getEntries()
    let jsonData = try? JSONEncoder().encode(entries)
    // Share as .json file via share sheet
}
```

#### C. Weekly Insights Generation
**Current:** InsightsView shows stats but no AI-generated summary
**Fix:**
```swift
// Add to InsightsView
Button("Generate Weekly Insight") {
    Task {
        let insight = try await aiService.generateWeeklyInsights(
            entries: appState.getRecentEntries(limit: 7)
        )
        weeklyInsight = insight
    }
}
```

---

## 🎁 GROWTH FEATURES (Post-Launch)

### Phase 2: Engagement Boosters (Week 3-4)

#### 1. Notifications
```swift
// Add UNUserNotificationCenter
// Daily reminder: "How are you feeling today?"
// Streak reminder: "Keep your 7-day streak going!"
// Milestone celebrations: "You hit 30 days! 🎉"
```

#### 2. Home Screen Widget
```swift
// WidgetKit extension
// Show: Current streak + Today's mood
// Tap to open app
```

#### 3. Share Feature
```swift
// Share completed task to social media
// "I completed my task with @PilotApp! 🎯"
// Include App Store link for referrals
```

### Phase 3: Retention Features (Month 2)

#### 4. Apple Watch Companion
```swift
// Quick mood check-in
// See today's task on wrist
// Complete task from watch
```

#### 5. Siri Shortcuts
```swift
// "Hey Siri, check in with Pilot"
// "Hey Siri, what's my Pilot task?"
```

#### 6. CloudKit Sync
```swift
// Sync across iPhone + iPad + Mac
// Backup data to iCloud
// Family sharing support
```

### Phase 4: Advanced AI (Month 3)

#### 7. Voice Personalities
**Current:** Mentions "4 voice personalities" but only "Charlotte"
**Add:**
- Alex (Motivational coach)
- Sam (Gentle therapist)
- Jordan (Tough love mentor)
- Different prompts + voice IDs for each

#### 8. Custom AI Tuning (Elite Feature)
```swift
// User adjusts:
// - Tone (supportive vs challenging)
// - Task difficulty (easy vs ambitious)
// - Focus areas (work, health, relationships)
```

#### 9. Pattern Detection
```swift
// AI detects:
// "You tend to feel drained on Mondays"
// "Your longest streaks happen when you..."
// Proactive suggestions based on history
```

---

## 💎 PREMIUM FEATURE IDEAS

### Make Free Tier More Limited
**Current limits:**
- 1 task/day ✅
- 3 chat messages total ✅
- 3 voice conversations/month ⚠️ (not implemented)

**Additional limits to drive upgrades:**
- Show ads on free tier? (Optional)
- Limit insights to last 3 days (vs full history)
- No task regeneration (Pro feature)
- No data export
- No custom themes

### Make Pro Tier More Valuable
**Add:**
- Multiple tasks per day (power users)
- Priority API responses (faster generation)
- Advanced emotion detection
- Mood journaling (long-form notes)
- Progress photos (attach images to entries)

### Make Elite Tier Irresistible
**Add:**
- 1-on-1 onboarding call
- Monthly check-in with founder
- Early access to new features
- Custom integration requests
- Personalized AI model fine-tuning

---

## 🎨 UX POLISH (Nice-to-Haves)

### Animations
```swift
// Add to TaskCard completion:
withAnimation(.spring()) {
    // Confetti particles using Canvas
    // Scale up checkmark
    // Haptic feedback
}
```

### Loading States
```swift
// Replace spinners with skeleton screens
// Shimmer effect while loading
```

### Empty States
```swift
// Better illustrations for:
// - No tasks yet
// - No chat history
// - No insights (less than 3 days)
```

### Onboarding Improvements
```swift
// Add sample task preview
// Show mood-to-task examples
// Preview chat conversation
```

---

## 📈 ANALYTICS & METRICS

### Track These KPIs
```swift
// Implement with TelemetryDeck or Mixpanel
- Daily Active Users (DAU)
- Weekly Active Users (WAU)
- Task completion rate
- Streak distribution
- Free → Pro conversion rate
- Churn rate
- Revenue per user
```

### Critical Metrics
- **Activation:** % who complete 1st task
- **Retention:** % who return day 2, day 7, day 30
- **Monetization:** % who subscribe within 7 days
- **Referral:** % who share app

---

## 🚀 LAUNCH STRATEGY

### Pre-Launch (1 week before)
- [ ] Submit to App Store (7-day review)
- [ ] Create landing page (Carrd.co or Framer)
- [ ] Announce on Twitter/ProductHunt
- [ ] Reach out to mental health influencers
- [ ] Prepare launch day social posts

### Launch Day
- [ ] Post on ProductHunt (aim for top 5)
- [ ] Post on Reddit (r/productivity, r/mentalhealth)
- [ ] Post on Twitter with video demo
- [ ] Email friends/family to download & review
- [ ] Monitor crash reports & fix critical bugs

### Post-Launch (Week 1)
- [ ] Respond to all reviews
- [ ] Fix reported bugs quickly
- [ ] Post user testimonials
- [ ] Share metrics (if impressive)
- [ ] Plan v1.1 update based on feedback

---

## 💰 PRICING STRATEGY

### Current Tiers Review
| Tier | Price | Value Prop | Issues |
|------|-------|-----------|--------|
| Free | $0 | Try before buy | Too limited? |
| Pro | $14.99 | Power users | Good value ✅ |
| Premium | $24.99 | Not differentiated enough | ⚠️ |
| Elite | $49.99 | Too expensive? | ⚠️ |

### Recommendations
1. **Add free trial:** 7 days of Pro (increases conversion)
2. **Simplify to 2 tiers:** Free + Pro ($9.99/mo or $79.99/yr)
3. **Or keep 3 tiers:** Free, Pro ($14.99), Premium ($24.99, remove Elite)
4. **Anchor pricing:** Show "$49.99" crossed out, now $14.99

### Annual Pricing
- Pro: $14.99/mo or $119.99/yr (save $60)
- Premium: $24.99/mo or $199.99/yr (save $100)

---

## ✅ FINAL PRE-LAUNCH CHECKLIST

### Code
- [ ] Remove all `print()` debug statements
- [ ] Add error logging (Sentry or Crashlytics)
- [ ] Verify API keys in Config.xcconfig
- [ ] Test with production API keys
- [ ] Enable bitcode (if required)
- [ ] Set minimum iOS version (26.0 or lower to 17.0?)

### App Store
- [ ] Create App Store Connect listing
- [ ] Upload app icon (all sizes)
- [ ] Upload screenshots (all device sizes)
- [ ] Write app description
- [ ] Set pricing & availability
- [ ] Add privacy policy URL
- [ ] Add support URL
- [ ] Set age rating (4+ or 12+)
- [ ] Enable Family Sharing
- [ ] Submit for review

### Legal
- [ ] Privacy Policy (use iubenda or termly)
- [ ] Terms of Service
- [ ] COPPA compliance (if under 13)
- [ ] GDPR compliance (if EU users)
- [ ] Add in SettingsView

### Marketing
- [ ] Create social media accounts (@PilotApp)
- [ ] Landing page with App Store link
- [ ] Press kit (logo, screenshots, description)
- [ ] Email list signup
- [ ] Prepare launch posts

---

## 🎯 SUCCESS METRICS (First 30 Days)

### Goals
- **Downloads:** 1,000+ installs
- **Conversion:** 5% free → paid ($500 MRR)
- **Retention:** 40% return on day 7
- **Rating:** 4.5+ stars with 50+ reviews
- **Virality:** K-factor > 0.5 (each user brings 0.5 more)

### Milestones
- Week 1: 100 downloads
- Week 2: 500 downloads
- Week 3: 1,000 downloads
- Week 4: 2,000 downloads + $1,000 MRR

---

## 🛠 PRIORITY ORDER

### Sprint 1: Launch Blockers (This Week)
1. ✅ Real RevenueCat integration
2. ✅ App icon design
3. ✅ App Store screenshots
4. ✅ Privacy policy
5. ✅ TestFlight beta testing

### Sprint 2: Polish (Next Week)
1. ✅ Fix critical bugs from beta
2. ✅ Add animations
3. ✅ Improve onboarding
4. ✅ Weekly insights generation
5. ✅ Submit to App Store

### Sprint 3: Post-Launch (Week 3)
1. Marketing push
2. Monitor analytics
3. Respond to reviews
4. Fix reported bugs
5. Plan v1.1 features

---

## 📞 NEXT STEPS FOR YOU

### Today:
1. **Design app icon** (or hire on Fiverr for $20-50)
2. **Create App Store Connect account**
3. **Set up in-app purchase products**

### This Week:
1. **Integrate RevenueCat SDK**
2. **Take screenshots of app**
3. **Write privacy policy**
4. **TestFlight with 5 people**

### Next Week:
1. **Fix beta feedback**
2. **Submit to App Store**
3. **Prepare launch posts**

---

## 💡 QUESTIONS TO ANSWER

1. **Who is your target user?**
   - Busy professionals? Students? Mental health seekers?

2. **What's your unique angle?**
   - "AI that reads your mood" vs competitors like Todoist/Notion

3. **What's your acquisition strategy?**
   - Paid ads? Influencers? Organic social? SEO?

4. **What's your retention strategy?**
   - Daily notifications? Gamification? Social features?

5. **What's your monetization focus?**
   - High volume / low price? Or niche / premium pricing?

---

## 🎉 YOU'RE ALMOST THERE!

You have a **working, production-ready app**. The foundation is solid. Now it's about:
1. **Plugging in real payments** (RevenueCat)
2. **Making it look professional** (icon, screenshots)
3. **Testing thoroughly** (beta, devices)
4. **Shipping confidently** (App Store)

**This app has real potential.** The mood-based AI task generation is unique. The UX is clean. The monetization is clear.

Now execute! 🚀

---

**Need help with any specific step? Let's tackle it together.**
