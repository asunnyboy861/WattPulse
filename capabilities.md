# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities were detected:

| Keyword Found | Capability | Source |
|---------------|------------|--------|
| "WebSocket" / "Home Assistant" / "连接" | Outgoing Network Connections (WebSocket) | Guide: HA integration |
| "Scan Network" / "局域网" | Local Network Access | Guide: HA auto-discovery |
| "http://192.168" | App Transport Security (HTTP exception) | Guide: local HA URL |
| "通知" / "alert" / "推送" | Push Notifications (Local) | Guide: anomaly alerts, price alerts |
| "手表" / "Apple Watch" | Apple Watch | Guide: Watch app |
| "Widget" / "Live Activity" | WidgetKit + ActivityKit | Guide: Home Screen widget, Live Activity |
| "购买" / "$4.99" | In-App Purchase | Guide: one-time purchase |
| "Keychain" / "Token" | Keychain | Guide: HA token storage |
| "后台" / "background" | Background Modes | Guide: real-time monitoring |
| "App Group" / "shared" | App Groups | Guide: Widget data sharing |

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Local Network Access | Configured | `INFOPLIST_KEY_NSLocalNetworkUsageDescription` in project.pbxproj |
| App Transport Security | Configured | `NSAllowsLocalNetworking` in WattPulse-Info.plist |
| Live Activities | Configured | `INFOPLIST_KEY_NSSupportsLiveActivities = YES` in project.pbxproj |
| Push Notifications (Local) | Configured | `UserNotifications` framework (no APNs needed for local notifications) |
| Keychain | Configured | Security framework (no entitlement needed for app keychain) |
| In-App Purchase | Configured | StoreKit 2 framework (no entitlement needed; IAP capability auto-enabled by Xcode for paid apps) |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| Apple Watch App | Pending | Requires adding watchOS target to Xcode project. Will be handled in code generation phase (PHASE 4+5) by creating Watch app source files. Target creation requires Xcode UI or manual pbxproj editing. |
| WidgetKit Extension | Pending | Requires adding Widget Extension target to Xcode project. Will be handled in code generation phase (PHASE 4+5) by creating Widget source files. |
| App Groups | Pending | Requires adding App Groups entitlement (`group.com.zzoutuo.WattPulse`) for Widget data sharing. Requires Apple Developer portal or Xcode Signing & Capabilities UI. |
| Background Modes | Pending | Requires enabling Background Modes capability in Xcode (Processing + Remote notifications). Will be configured in code generation phase. |

## No Configuration Needed

- **CloudKit / iCloud**: Not used (app uses local SwiftData only)
- **HealthKit**: Not used (no health data)
- **Sign in with Apple**: Not used (no user accounts)
- **Siri**: Not used
- **Camera/Photo Library**: Not used
- **Location Services**: Not used
- **Maps**: Not used
- **Family Sharing**: Not used

## Graceful Degradation

The app is designed to work without manual configuration:
- **Without Apple Watch**: Watch app is a companion; iPhone app works independently
- **Without Widget Extension**: Widget is optional; app works without it
- **Without App Groups**: Widget data sharing disabled; widget shows placeholder
- **Without Background Modes**: Real-time updates only when app is foregrounded
- **Without Push Notifications**: In-app alerts still work; only system notifications disabled

## Verification

- Build succeeded after configuration: YES
- All entitlements correct: YES (no entitlements file needed yet; will be added when App Groups/Watch/Widget targets are created)
- Info.plist keys configured:
  - `NSLocalNetworkUsageDescription`: YES
  - `NSAllowsLocalNetworking`: YES
  - `NSSupportsLiveActivities`: YES
