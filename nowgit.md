# WattPulse — GitHub Repository

**Repository URL**: https://github.com/asunnyboy861/WattPulse
**Owner**: asunnyboy861
**Branch**: main
**Push Method**: SSH (git@github.com:asunnyboy861/WattPulse.git)

## Build Status
- **Build Result**: SUCCESS
- **Simulator**: iPhone 15 Pro
- **Scheme**: WattPulse
- **iOS Deployment Target**: 17.0
- **Bundle ID**: com.asunnyboy861.WattPulse
- **Warnings**: 0
- **Errors**: 0

## Repository Contents

### Source Code
- `WattPulse/WattPulse.xcodeproj` — Xcode project file
- `WattPulse/WattPulse/` — Main app source (MVVM architecture)
  - `Models/` — Data models (EnergyRecord, DailySummary, RatePlan, etc.)
  - `Services/` — Business logic (HAConnectionManager, CostCalculator, etc.)
  - `ViewModels/` — View models (Dashboard, Details, Insights, Settings)
  - `Views/` — SwiftUI views (Dashboard, Details, Insights, Settings, Onboarding)
  - `Support/` — AppConfig, HapticManager
- `WattPulse/WattPulseTests/` — Unit tests
- `WattPulse/WattPulseUITests/` — UI tests

### Documentation
- `us.md` — English development guide
- `price.md` — Pricing configuration ($4.99 one-time purchase)
- `capabilities.md` — iOS capabilities configuration
- `icon.md` — App icon generation documentation
- `improvement_plan_1.md` — QA iteration report
- `nowgit.md` — This file

### Original Input
- `TR-20260521-家庭能耗数据可视化-操作指南.MD` — Chinese operation guide

## Features Implemented (17/20)
1. HA WebSocket Connection
2. Energy Entity Auto-Discovery
3. Real-Time Power Dashboard
4. Multi-Source Overlay Chart
5. Cost Calculation + Savings
6. AI Smart Suggestions
7. Anomaly Detection + Alerts
8. Energy Flow Diagram
9. Electricity Rate Plan Config
10. Historical Data (2-Year)
11. CO₂ Carbon Offset Tracking
12. CSV Data Export
13. Offline Cache + Data Reliability
14. Multi-HA Instance Support
15. Time Range Switching
16. Contact Support
17. Onboarding Flow

## Pending Features (require separate Xcode targets)
- Home Screen Widget (WidgetKit extension)
- Live Activity (ActivityKit)
- Apple Watch App (watchOS target)

These are documented in `capabilities.md` as manual configuration steps.

## Next Steps
1. PHASE 7: Deploy policy pages (privacy, terms, support) to GitHub Pages
2. PHASE 8: Generate ASO-optimized App Store keytext
3. PHASE 8.5: Generate manual configuration checklist
