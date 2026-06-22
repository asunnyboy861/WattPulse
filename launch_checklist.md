# WattPulse — Manual Configuration Checklist (MANDATORY)

This document lists ONLY the capabilities, API keys, and backend services that you must manually configure to make WattPulse fully functional after download. App Store submission steps are NOT covered here.

---

## MANDATORY Configuration Items

### 1. Enable GitHub Pages (Policy URLs)
**Why**: The app's Settings tab links to privacy.html, terms.html, and support.html hosted on GitHub Pages. Without this, the links will return 404.

**Steps**:
1. Go to https://github.com/asunnyboy861/WattPulse/settings/pages
2. Under "Build and deployment" → "Source", select **GitHub Actions**
3. The workflow at `.github/workflows/deploy-pages.yml` will automatically deploy the docs/ folder
4. Verify deployment at https://asunnyboy861.github.io/WattPulse/

**Status**: ⚠️ REQUIRES MANUAL ACTION (workflow file is in place, but Pages must be enabled in repo settings)

---

### 2. Verify Feedback Backend (Contact Support)
**Why**: The in-app Contact Support form POSTs to a Cloudflare Worker at `https://feedback-worker.sunmingming.workers.dev/api/feedback`. If this endpoint is unavailable, support submissions will fail.

**Steps**:
1. Test the endpoint: `curl -X POST https://feedback-worker.sunmingming.workers.dev/api/feedback -H "Content-Type: application/json" -d '{"name":"Test","email":"test@test.com","subject":"Test","message":"Test","app_name":"WattPulse"}'`
2. If the endpoint is down, either:
   - Deploy your own Cloudflare Worker (code template available in ios-app-developer skill)
   - Update `AppConfig.feedbackBackendURL` in `WattPulse/WattPulse/Support/AppConfig.swift` to your new endpoint
   - Or remove the Contact Support feature temporarily

**Status**: ⚠️ REQUIRES VERIFICATION (existing endpoint may or may not be active)

---

### 3. App Store Connect: One-Time Purchase Setup
**Why**: WattPulse is a paid app ($4.99). The price tier must be configured in App Store Connect.

**Steps**:
1. In App Store Connect → WattPulse → Pricing and Availability
2. Set Price: **$4.99 USD** (Price Tier 49)
3. Apply price to all territories
4. Save

**Status**: ⚠️ REQUIRES MANUAL ACTION (cannot be configured from code)

---

### 4. App Store Connect: App Information
**Why**: Required metadata for App Store submission.

**Steps**:
1. Primary Language: English (U.S.)
2. Bundle ID: com.zzoutuo.WattPulse (must match Xcode project)
3. SKU: wattpulse_2026
4. Primary Category: Utilities
5. Secondary Category: Lifestyle
6. Content Rating: 4+ (No objectionable content)
7. Copyright: 2026 WattPulse

**Status**: ⚠️ REQUIRES MANUAL ACTION

---

### 5. App Store Connect: App Review Information
**Why**: Reviewers need to understand the app requires Home Assistant.

**Steps**:
1. Use the "Review Notes" section from `keytext.md`
2. Demo Account: Not applicable (app requires user's own HA instance)
3. Contact Info: support@wattpulse.app

**Status**: ⚠️ REQUIRES MANUAL ACTION

---

## OPTIONAL Configuration Items (Feature Enhancement)

### 6. Home Screen Widget (WidgetKit Extension)
**Why**: The original guide specifies a home screen widget for quick energy glance. Currently NOT implemented because it requires a separate Widget Extension target in Xcode.

**Steps to Add**:
1. In Xcode: File → New → Target → Widget Extension
2. Name: WattPulseWidget
3. Embed in: WattPulse
4. Configure App Group: `group.com.zzoutuo.WattPulse` (already in entitlements)
5. Implement widget timeline using `EnergyRecord` data from shared SwiftData container
6. Update `AppConfig.widgetUpdateIntervalMinutes` (currently 5 minutes)

**Status**: ⏸️ OPTIONAL (app works without it; documented in capabilities.md)

---

### 7. Live Activity (ActivityKit)
**Why**: Real-time energy usage on the Dynamic Island / Lock Screen. Currently NOT implemented.

**Steps to Add**:
1. Enable "Live Activities" capability in Xcode (already in capabilities.md)
2. Create Widget Extension with ActivityConfiguration
3. Define ActivityAttributes struct for energy state
4. Start/stop Live Activity from DashboardViewModel when real-time data updates
5. Update interval: `AppConfig.liveActivityUpdateIntervalSeconds` (currently 30 seconds)

**Status**: ⏸️ OPTIONAL (app works without it; documented in capabilities.md)

---

### 8. Apple Watch App (watchOS Target)
**Why**: Quick energy glance from the wrist. Currently NOT implemented.

**Steps to Add**:
1. In Xcode: File → New → Target → watchOS App
2. Name: WattPulseWatch
3. Embed in: WattPulse
4. Share data via App Group
5. Implement simple SwiftUI views for current power, battery, and cost

**Status**: ⏸️ OPTIONAL (app works without it; documented in capabilities.md)

---

### 9. App Icon Final Review
**Why**: The app icon was generated via AI. Verify it looks good at all sizes.

**Steps**:
1. Open `WattPulse/WattPulse/Assets.xcassets/AppIcon.appiconset/` in Xcode
2. Verify the 1024x1024 PNG fills the entire asset slot
3. Check that the icon looks good at small sizes (40x40, 60x60) using Xcode preview
4. If needed, regenerate with a different prompt using the wanx-image-gen skill

**Status**: ✅ GENERATED (verify visually before submission)

---

## Build Verification

### Current Build Status
- **Build Result**: ✅ SUCCESS
- **Errors**: 0
- **Warnings**: 0
- **Simulator**: iPhone 15 Pro
- **iOS Deployment Target**: 17.0
- **Bundle ID**: com.zzoutuo.WattPulse

### Files Generated
- Source code: 38 Swift files
- Documentation: 7 markdown files
- Policy pages: 4 HTML files
- GitHub Actions: 1 workflow file
- Total: 50+ files

---

## Pre-Submission Final Checklist

Before submitting to App Store Connect, verify:

- [ ] GitHub Pages enabled (Item 1 above)
- [ ] Feedback backend verified (Item 2 above)
- [ ] App Store Connect pricing set to $4.99 (Item 3 above)
- [ ] App Store Connect metadata entered (Item 4 above)
- [ ] Review notes added (Item 5 above)
- [ ] App icon visually verified (Item 9 above)
- [ ] Build succeeds in Xcode (Release configuration)
- [ ] Archive created in Xcode (Product → Archive)
- [ ] Upload to App Store Connect
- [ ] Screenshots generated for all required device sizes
- [ ] App Store metadata fields populated from keytext.md

---

## Contact Information
- **Support Email**: support@wattpulse.app
- **GitHub Repo**: https://github.com/asunnyboy861/WattPulse
- **Privacy Policy**: https://asunnyboy861.github.io/WattPulse/privacy.html
- **Terms of Service**: https://asunnyboy861.github.io/WattPulse/terms.html
- **Support Page**: https://asunnyboy861.github.io/WattPulse/support.html
