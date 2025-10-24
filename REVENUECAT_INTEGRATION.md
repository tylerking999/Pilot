# RevenueCat Integration Guide

## ✅ WHAT YOU NEED TO DO IN XCODE (5 minutes)

### Step 1: Add RevenueCat Package
1. Open `Pilot.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies...**
3. Paste this URL: `https://github.com/RevenueCat/purchases-ios`
4. Click **Add Package**
5. Select **RevenueCat** and **RevenueCatUI** (both)
6. Click **Add Package** again

### Step 2: Set Up Products in RevenueCat Dashboard
1. Go to [app.revenuecat.com](https://app.revenuecat.com)
2. Create a new app (if you haven't)
3. Go to **Products** → **Create Product**
4. Create these 2 products:
   - **Product ID:** `pilot_premium_monthly`
   - **Product ID:** `pilot_premium_annual`

### Step 3: Set Up Offerings
1. Go to **Offerings** → **Create Offering**
2. Name it "default"
3. Add both products to the offering
4. Set `pilot_premium_annual` as the default

### Step 4: Configure in App Store Connect
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Create your app (if not done)
3. Go to **Features → In-App Purchases**
4. Create 2 Auto-Renewable Subscriptions:

**Monthly:**
- Product ID: `pilot_premium_monthly`
- Duration: 1 Month
- Price: $7.99
- Free Trial: 7 days
- Subscription Group: "Pilot Premium"

**Annual:**
- Product ID: `pilot_premium_annual`
- Duration: 1 Year
- Price: $59.99
- Free Trial: 7 days
- Subscription Group: "Pilot Premium"

---

## ✅ CODE CHANGES (I'll make these for you)

All the code is ready below. After you add the package in Xcode, the code will work!
