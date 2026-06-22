# WattPulse — iOS Development Guide

## Executive Summary

**WattPulse** is a premium, one-time-purchase iOS app that serves as a unified, real-time home energy dashboard. It connects to any Home Assistant (HA) instance via WebSocket, auto-discovers energy entities (solar / grid / battery / consumption), and renders them as a multi-source overlay chart with color-coded cost thresholds (Tibber-style). Core ML on-device inference powers smart suggestions ("run dishwasher now — solar surplus available"), anomaly detection, and battery optimization guidance. The app ships with a Home Screen widget, Live Activity, Apple Watch app, offline cache, CSV export, and CO₂ offset tracking.

**Target Market**: United States + Germany (high solar penetration, strong HA community, TOU/real-time pricing plans).
**Target Audience**: Home owners with solar PV ± battery storage who already run Home Assistant and are frustrated by vendor-locked, unreliable, or ugly monitoring apps.
**Key Differentiators**:
1. Only iOS app that overlays Solar + Grid + Battery + Cost on a single Swift Charts canvas with zero configuration.
2. Brand-agnostic — works with any device integrated into HA (Tesla, Enphase, SolarEdge, Growatt, Solis, Shelly, Victron, etc.).
3. 100% on-device AI (Core ML) — no API fees, no privacy concerns, no latency.
4. $4.99 one-time purchase — no subscription fatigue, no server costs.

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **GridMind Power** | Beautiful real-time power flow, EV charging, Live Activities, AI insights | Vendor-locked (Tesla/Enphase only), subscription required for Pro, requires GridMind account | Brand-agnostic via HA, one-time purchase, no account required |
| **Tibber** | Real-time electricity prices, AI suggestions, popular in Northern Europe | Requires switching electricity supplier, limited solar/battery overlay, not available in US | Works with any supplier, full multi-source overlay, US + Germany launch |
| **Home Assistant Official** | Free, complete, brand-agnostic | YAML configuration hell, ugly default charts, no on-device AI suggestions, steep learning curve | Zero-config auto-discovery, Tibber-grade visuals, Core ML suggestions, 60-second setup |
| **SvitGrid Monitor** | Direct inverter connection (Deye/Sunsynk/Sol-Ark/Victron), real-time dashboard | Limited to specific inverter brands, no HA integration, no AI suggestions | Works with any HA-integrated brand, Core ML suggestions, widget + Watch |
| **Zap Panels** | Stylish dedicated Tesla Powerwall display, wall-mounted kiosk mode | Tesla-only, display-only (no insights/AI), narrow use case | All brands, AI suggestions, anomaly alerts, full feature set |
| **Sense** | AI device disaggregation, detailed appliance detection | $349 hardware required, no solar/battery overlay, US-only | $4.99 software-only, full overlay, no hardware needed |

## Apple Design Guidelines Compliance

- **Human Interface Guidelines — Dashboards**: Glanceable hierarchy (real-time kW prominent, details secondary). Follows "Data-forward" principle from Apple's Weather and Fitness apps.
- **SwiftUI + Swift Charts**: 100% native SwiftUI, no UIKit except where WidgetKit requires. Charts use `AreaMark`, `LineMark` with `.interpolationMethod(.catmullRom)` for smooth curves.
- **Live Activities & ActivityKit**: Lock Screen / Dynamic Island energy display follows Apple's Live Activity design patterns (compact leading/trailing, expanded content state).
- **WidgetKit**: StaticConfiguration with `containerBackground(for: .widget)` per iOS 17+ requirement.
- **Dark Mode**: Dark-first design (OLED black `#000000`), respects system color scheme.
- **Accessibility**: VoiceOver labels on all charts, Dynamic Type up to AX5, WCAG AA contrast (4.5:1+), color-blind safe (icon + text + color, not color alone), respects `accessibilityReduceMotion`.
- **App Store Review Guidelines**:
  - Guideline 2.1 (App Completeness): All features functional without account; HA connection is the only setup step.
  - Guideline 3.1.1 (In-App Purchase): One-time non-consumable IAP via StoreKit 2 — no subscription.
  - Guideline 4.2 (Minimum Functionality): Full-featured energy dashboard, not a wrapper.
  - Guideline 5.1.1 (Privacy): No personal data collected; HA credentials stored in Keychain; Core ML runs on-device.

## Technical Architecture

- **Language**: Swift 5.9+ with strict concurrency (`@MainActor`, `async/await`)
- **UI Framework**: SwiftUI (iOS 17.0+), 100% declarative
- **Visualization**: Swift Charts (`AreaMark`, `LineMark`, `BarMark`, `PointMark`)
- **Persistence**: SwiftData (`@Model` classes for `EnergyRecord`, `DailySummary`)
- **Networking**: `URLSessionWebSocketTask` + Combine (`PassthroughSubject`, `AnyPublisher`)
- **AI**: Core ML (on-device inference for suggestions, anomaly detection, usage pattern learning)
- **Widgets**: WidgetKit (`StaticConfiguration`, `TimelineProvider`)
- **Live Activities**: ActivityKit (iOS 17.2+)
- **Notifications**: `UserNotifications` framework (local, scheduled)
- **Apple Watch**: watchOS 10+ companion app (independent + dependent hybrid)
- **In-App Purchase**: StoreKit 2 (`Product.purchase()`, `Transaction.updates`)
- **Keychain**: Secure storage for HA Long-Lived Access Token
- **Haptics**: `UIImpactFeedbackGenerator` for power-change and chart interactions

## Module Structure

```
WattPulse/
├── WattPulseApp.swift              # App entry, SwiftData container, scene
├── ContentView.swift               # Root TabView
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift     # Tab 1: real-time dashboard
│   │   ├── DashboardViewModel.swift
│   │   ├── MetricCard.swift        # Solar / Battery / Grid cards
│   │   ├── EnergyOverlayChart.swift # Multi-source stacked area chart
│   │   ├── EnergyFlowDiagram.swift  # Sankey-style flow animation
│   │   ├── TimeRangePicker.swift    # Today/Week/Month/Year segmented
│   │   └── SavingsBanner.swift      # "Today's savings: $4.32"
│   ├── Details/
│   │   ├── DetailsView.swift       # Tab 2: per-entity deep dive
│   │   ├── DetailsViewModel.swift
│   │   ├── EntityDetailView.swift  # Single entity (Solar/Grid/Battery)
│   │   ├── HourlyCurveChart.swift  # 24-hour fine curve
│   │   └── MonthlyBarChart.swift   # Monthly comparison bars
│   ├── Insights/
│   │   ├── InsightsView.swift      # Tab 3: AI suggestions + weekly summary
│   │   ├── InsightsViewModel.swift
│   │   ├── SuggestionCard.swift    # AI suggestion card with action
│   │   ├── WeeklySummaryCard.swift
│   │   └── AnomalyHistoryCard.swift
│   ├── Settings/
│   │   ├── SettingsView.swift      # Tab 4: HA connection, rate plan, notifications
│   │   ├── SettingsViewModel.swift
│   │   ├── HAConnectionSection.swift
│   │   ├── RatePlanSection.swift
│   │   ├── NotificationsSection.swift
│   │   ├── AppearanceSection.swift
│   │   ├── AboutSection.swift      # Version, Rate, Support, Privacy, Terms
│   │   └── ContactSupportView.swift # Support form (posts to FEEDBACK_BACKEND_URL)
│   └── Onboarding/
│       ├── WelcomeView.swift       # "See your home's energy heartbeat"
│       ├── HAConnectView.swift     # URL + token input, network scan
│       └── EntityDiscoveryView.swift # Auto-discovered entities list
├── ViewModels/
│   └── AppEnvironment.swift        # Shared environment, dependency injection
├── Models/
│   ├── HAEntity.swift              # HA entity model + EnergyCategory enum
│   ├── EnergyDataPoint.swift       # Time-series point for overlay chart
│   ├── EnergyRecord.swift          # SwiftData @Model (raw samples)
│   ├── DailySummary.swift          # SwiftData @Model (daily aggregates)
│   ├── EnergySuggestion.swift      # AI suggestion model
│   ├── CostResult.swift            # Cost calculation result
│   ├── RatePlan.swift              # Flat / TimeOfUse / RealTime enum
│   └── TimeRange.swift             # Today/Week/Month/Year enum
├── Services/
│   ├── HAConnectionManager.swift   # WebSocket connection, auth, subscribe
│   ├── EnergyDiscoveryManager.swift # Auto-categorize entities
│   ├── CostCalculator.swift        # Cost + savings + CO₂ engine
│   ├── SuggestionEngine.swift      # Core ML suggestion generator
│   ├── AnomalyDetector.swift       # Spike / missing-data detection
│   ├── NotificationScheduler.swift # Local notification scheduler
│   ├── DataReliabilityEngine.swift # Cache + interpolation + smoothing
│   ├── CSVExporter.swift           # CSV export service
│   └── KeychainService.swift       # Token secure storage
├── StoreKit/
│   └── StoreManager.swift          # StoreKit 2 one-time purchase
├── Widgets/
│   ├── WattPulseWidget.swift       # Home Screen widget
│   └── EnergyProvider.swift        # TimelineProvider
├── LiveActivities/
│   └── EnergyActivityAttributes.swift # ActivityKit attributes
├── Resources/
│   ├── Assets.xcassets
│   ├── WattPulseML.mlmodel         # Core ML model (usage patterns)
│   └── Localizable.strings
└── Support/
    ├── AppConfig.swift             # Constants, feedback backend URL
    └── HapticManager.swift         # Centralized haptic feedback
```

## Feature Inventory (MANDATORY — Every Feature Listed)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | HA WebSocket Connection | 1. Open app → 2. Welcome → 3. Tap "Connect Home Assistant" → 4. Enter HA URL → 5. Enter Long-Lived Access Token → 6. Tap "Authorize" | HA URL (string), HA Token (string) | `HAConnectionManager.connect()` validates URL, upgrades to ws/wss, opens `URLSessionWebSocketTask`, sends `auth_required` → `auth` → subscribes to `subscribe_events` for `state_changed` | `connectionState = .connected`, `entities` array populated | Token saved to Keychain; URL saved to `UserDefaults` | App shows "Connected" badge; entity list non-empty within 5 seconds |
| 2 | Energy Entity Auto-Discovery | 1. After HA connect → 2. App auto-scans all entities → 3. Filters by `device_class=energy` / `unit_of_measurement=kW\|kWh` → 4. Categorizes by name pattern (solar/grid/batt) → 5. Shows discovery screen | HA entities array from `HAConnectionManager.$entities` | `EnergyDiscoveryManager.discover()` applies 5 rules: device_class=energy, name contains "solar/pv", "grid/import/export", "batt/storage", unit kW/kWh | `solarEntities`, `gridEntities`, `batteryEntities`, `consumptionEntities` arrays | Category mapping saved to `UserDefaults` (entity_id → category) | Discovery completes < 2s; at least 1 entity categorized; user can tap "Start Monitoring" |
| 3 | Real-Time Power Dashboard | 1. Open app → 2. Land on Dashboard tab → 3. See live kW values updating every 1s | WebSocket `state_changed` events from HA | `DashboardViewModel` receives entity updates via Combine, updates `@Published currentPower` | Three metric cards (Solar/Battery/Grid) show live values; total consumption in header | Latest values cached in memory; 5-min samples persisted to SwiftData `EnergyRecord` | Power numbers update visibly within 1s of HA state change; numbers animate with spring |
| 4 | Multi-Source Overlay Chart | 1. On Dashboard → 2. See stacked area chart → 3. Tap Today/Week/Month/Year to switch range → 4. Pinch to zoom, drag to pan | Time-series `EnergyDataPoint` array from SwiftData + live cache | `EnergyOverlayChart` renders `AreaMark` for solar (green), grid import (red), battery discharge (blue); `LineMark` for consumption (orange) and cost (gray dashed) | Stacked area chart with 4 layers, legend at bottom, time-aligned x-axis, kW y-axis | Historical data persisted to SwiftData `EnergyRecord` (1-hour granularity, 2-year retention) | Chart renders < 0.5s; all 4 sources visible when data exists; smooth catmullRom curves |
| 5 | Cost Calculation + Savings | 1. On Dashboard → 2. See "Today's savings: $X.XX" banner → 3. Tap for breakdown | Grid import kWh, grid export kWh, solar production kWh, rate plan config | `CostCalculator.calculateCost()` applies rate plan (flat/TOU/realTime), computes import cost, export credit, net cost, CO₂ offset (0.417 kg/kWh) | `CostResult` with `netCost`, `formattedNetCost`, `formattedCO2`; daily savings displayed | `DailySummary` SwiftData model stores daily totals | Savings number updates when new kWh data arrives; matches manual calculation within $0.01 |
| 6 | AI Smart Suggestions | 1. On Dashboard or Insights tab → 2. See suggestion cards → 3. Tap "Set Reminder" or "Dismiss" | Current power, solar power, battery level, current price, average price, usage profile | `SuggestionEngine.generateSuggestions()` runs 4 rules: solar excess, low price, anomaly, battery optimization; Core ML model predicts best action times | `[EnergySuggestion]` with title, description, potentialSaving, action type | Suggestions history persisted to SwiftData; dismissed suggestions suppressed 24h | At least 1 suggestion appears when solar excess > 1kW; suggestions refresh every 5 minutes |
| 7 | Anomaly Detection + Alerts | 1. Background monitoring → 2. Spike detected (power > 2.5x normal) → 3. Push notification sent → 4. Tap notification → 5. See anomaly detail | Real-time power readings, historical usage profile by hour | `AnomalyDetector` compares current power to `usageProfile.averageHourlyConsumption[hour] * 2.5`; triggers if exceeded and not in known high-usage period | Local notification with "Unusual spike: X kW at Y AM"; in-app anomaly detail view | Anomaly events persisted to SwiftData `AnomalyEvent` model | Notification delivered < 5s after spike; false positive rate < 1/day |
| 8 | Energy Flow Diagram | 1. On Dashboard → 2. See animated Sankey-style flow → 3. Tap any node for details | Real-time solar/grid/battery/consumption values | `EnergyFlowDiagram` renders animated particles flowing from source → destination proportional to power | Animated flow diagram: Solar → Home, Solar → Battery, Solar → Grid, Grid → Home, Battery → Home | Not persisted (real-time only) | Flow animation smooth at 60fps; particle size proportional to power |
| 9 | Electricity Rate Plan Config | 1. Settings → 2. Electricity Rate → 3. Select plan type (Flat/TOU/RealTime) → 4. Enter rates → 5. Save | Plan type selection, rate values, peak hours range | `RatePlan` enum with associated values; `CostCalculator` switches on plan type | Configured rate plan saved; cost calculations use new plan | Rate plan saved to `UserDefaults` as JSON | Cost recalculates immediately after plan change; TOU correctly applies peak/off-peak |
| 10 | Historical Data (2-Year) | 1. Dashboard → 2. Switch to Year view → 3. See monthly bars → 4. Tap any month for daily breakdown | SwiftData `DailySummary` records | `DetailsViewModel` fetches `DailySummary` by date range; aggregates to monthly | Monthly bar chart; daily breakdown on tap | `DailySummary` persisted for 2 years; auto-cleanup older records | Year view shows 12 monthly bars; tap reveals 28-31 daily bars |
| 11 | CO₂ Carbon Offset Tracking | 1. Dashboard → 2. See CO₂ offset in savings banner → 3. Details tab → 4. See CO₂ breakdown | Solar production kWh | `CostCalculator` multiplies solar kWh × 0.417 kg/kWh (US grid average) | CO₂ offset in kg displayed in banner and details | `DailySummary.co2OffsetKg` persisted | CO₂ value updates with solar production; matches kWh × 0.417 |
| 12 | Home Screen Widget | 1. Add WattPulse widget to Home Screen → 2. See live solar/grid/battery/savings | App Group shared `EnergyEntry` data | `EnergyProvider.getTimeline()` reads shared UserDefaults; returns `EnergyEntry` | Small/Medium widget showing solar kW, grid kW, battery %, today's savings | Widget data in App Group shared container; updates every 5 minutes | Widget updates within 5 min of data change; tap opens app to Dashboard |
| 13 | Live Activity (Lock Screen) | 1. App running → 2. Live Activity starts → 3. Lock Screen shows live energy | Real-time power values | `EnergyActivityAttributes` with current power, solar, grid, battery | Lock Screen / Dynamic Island compact + expanded views | ActivityKit session; auto-updates every 30 seconds | Live Activity visible on Lock Screen; updates within 30s |
| 14 | Apple Watch App | 1. Open WattPulse on Watch → 2. See real-time power → 3. Tap metric for detail | WatchConnectivity sync from iPhone, or direct HA connection | Watch app reads shared `EnergyEntry` via WatchConnectivity | Watch UI: total kW, solar, grid, battery complications | Complication data cached on Watch | Watch app launches < 2s; shows same data as iPhone widget |
| 15 | CSV Data Export | 1. Settings → 2. Export Data → 3. Choose date range → 4. Share CSV | SwiftData `DailySummary` records in date range | `CSVExporter.export()` converts records to CSV string; `UIActivityViewController` for sharing | CSV file shared via system share sheet | CSV file in app's Documents directory | CSV opens in Numbers/Excel; contains all daily fields for selected range |
| 16 | Offline Cache + Data Reliability | 1. HA goes offline → 2. App shows cached data → 3. Banner "Offline — showing cached data" → 4. HA returns → 5. Auto-reconnect + sync | In-memory cache (24h, 5-min granularity), SwiftData (2-year, 1h granularity) | `DataReliabilityEngine` detects WebSocket disconnect, serves cached data, queues missed updates, interpolates gaps | Cached dashboard with offline banner; auto-reconnect on HA return | Cache in memory; SwiftData persistent | App remains functional offline; banner shows within 5s of disconnect |
| 17 | Multi-HA Instance Support | 1. Settings → 2. Add Another HA Instance → 3. Enter URL + token → 4. Switch between instances | Multiple HA URLs + tokens | `HAConnectionManager` supports multiple connections; active instance switchable | Instance selector in Settings; entities from active instance shown | All instance configs in Keychain + UserDefaults | User can switch instances < 1s; entities refresh on switch |
| 18 | Time Range Switching | 1. Dashboard → 2. Tap Today/Week/Month/Year → 3. Chart updates | Selected `TimeRange` enum case | `DashboardViewModel` fetches data for selected range; adjusts chart x-axis stride and date format | Chart with correct time granularity; aggregated values | No persistence (view state) | Chart updates < 0.5s on tap; correct aggregation per range |
| 19 | Contact Support | 1. Settings → 2. Support → 3. Fill form (name, email, message) → 4. Send | User name, email, message text | `ContactSupportView` POSTs to `FEEDBACK_BACKEND_URL`; shows success/error | Success toast; response from backend | None (stateless) | Form submits successfully; user sees confirmation |
| 20 | One-Time Purchase (StoreKit 2) | 1. App launches (free preview) → 2. Limited features → 3. Tap "Unlock WattPulse Pro" → 4. Confirm $4.99 purchase → 5. All features unlocked | StoreKit 2 `Product` ID | `StoreManager.purchase()` calls `Product.purchase()`; listens to `Transaction.updates` | Paywall dismissed; all features unlocked; `isPremium` flag true | Purchase state in StoreKit 2 (server-validated) | Purchase completes; app unlocks; restore purchases works |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | HA Connection | Network Scan | Auto-scan local network for HA instances (port 8123) | Tap "Scan Network" button; results list appears |
| 1.2 | HA Connection | Auto-Reconnect | WebSocket auto-reconnects on disconnect with exponential backoff | Automatic; no user action needed |
| 1.3 | HA Connection | Connection Status Badge | Green dot = connected, red = disconnected, yellow = connecting | Persistent in nav bar |
| 3.1 | Dashboard | Pull-to-Refresh | Pull down to force-fetch latest HA states | Pull gesture; haptic on completion |
| 3.2 | Dashboard | Power Change Haptic | Light haptic when power changes > 20% suddenly | Automatic; no user action |
| 4.1 | Overlay Chart | Pinch-to-Zoom | Two-finger pinch zooms x-axis time range | Pinch gesture |
| 4.2 | Overlay Chart | Drag-to-Pan | One-finger horizontal drag pans chart | Drag gesture |
| 4.3 | Overlay Chart | Tap Data Point | Tap any point for tooltip with exact values | Tap gesture; tooltip appears |
| 6.1 | AI Suggestions | Long-Press for Reminder | Long-press suggestion card to set reminder | Long-press; haptic; reminder confirmation |
| 6.2 | AI Suggestions | Dismiss with Swipe | Swipe left to dismiss suggestion | Swipe gesture |
| 7.1 | Anomaly Alerts | "It's Normal" Button | Tap to mark anomaly as expected behavior; suppresses future alerts for that hour | Tap button; alert dismissed |
| 8.1 | Energy Flow | Tap Node for Details | Tap any node (Solar/Battery/Grid/Home) for detail sheet | Tap; sheet slides up |
| 10.1 | Historical Data | Month Tap → Daily Breakdown | Tap monthly bar to see daily bars for that month | Tap; chart drills down |
| 16.1 | Offline Cache | Cache Age Indicator | "Cached 5 min ago" label when offline | Automatic label |
| 20.1 | Purchase | Restore Purchases | Settings → Restore Purchases for reinstall scenario | Tap button; StoreKit restores |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Entity → Dashboard | Feature 2 (Discovery) | Feature 3 (Dashboard) | Categorized entity IDs | Discovery completes |
| Dashboard → Chart | Feature 3 (Dashboard) | Feature 4 (Overlay Chart) | Live `EnergyDataPoint` array | New data arrives |
| Dashboard → Cost | Feature 3 (Dashboard) | Feature 5 (Cost Calc) | kWh values | kWh updates |
| Dashboard → Suggestion | Feature 3 (Dashboard) | Feature 6 (AI Suggestions) | Current power, solar, battery | Every 5 minutes |
| Dashboard → Anomaly | Feature 3 (Dashboard) | Feature 7 (Anomaly) | Current power vs historical | Every state change |
| Dashboard → Flow Diagram | Feature 3 (Dashboard) | Feature 8 (Energy Flow) | Live power values | Real-time |
| Cost → Banner | Feature 5 (Cost Calc) | Feature 3 (Dashboard) | `CostResult` (savings, CO₂) | Cost recalculated |
| Suggestion → Notification | Feature 6 (AI Suggestions) | Feature 7 (Anomaly/Alerts) | Suggestion with `.showAlert` action | High-priority suggestion generated |
| Rate Plan → Cost | Feature 9 (Rate Config) | Feature 5 (Cost Calc) | `RatePlan` enum | User saves rate plan |
| Historical → Details | Feature 10 (Historical) | Details tab | `DailySummary` records | User opens Details |
| Dashboard → Widget | Feature 3 (Dashboard) | Feature 12 (Widget) | `EnergyEntry` | Every 5 minutes via App Group |
| Dashboard → Live Activity | Feature 3 (Dashboard) | Feature 13 (Live Activity) | Current power values | Every 30 seconds |
| Dashboard → Watch | Feature 3 (Dashboard) | Feature 14 (Watch) | `EnergyEntry` via WatchConnectivity | Every 5 minutes |
| Purchase → All Features | Feature 20 (Purchase) | All paid features | `isPremium: Bool` | Purchase completes |

**VERIFICATION CHECK**: 20 primary features listed. Chinese guide describes: HA connection, auto-discovery, real-time dashboard, overlay chart, cost calc, AI suggestions, anomaly alerts, energy flow, rate config, historical data, CO₂ tracking, widget, Live Activity, Watch, CSV export, offline cache, multi-HA, time range, contact support, one-time purchase = 20 features. ✅ MATCH.

## Data Flow Diagram (Every Feature's Data Lifecycle)

### Feature 1: HA WebSocket Connection
```
User Input: HA URL + Long-Lived Access Token
   │
   ▼
ViewModel: HAConnectView → HAConnectionManager.connect(url, token)
   │  - Validate URL (http/https → ws/wss + /api/websocket)
   │  - Open URLSessionWebSocketTask
   │  - Receive "auth_required" message
   │  - Send {"type":"auth","access_token":token}
   │  - Receive "auth_ok" message
   │  - Send {"type":"subscribe_events","event_type":"state_changed"}
   │  - Start receive loop (async)
   │
   ▼
Model/Persistence:
   - Token → KeychainService.save("HA_TOKEN", token)
   - URL → UserDefaults.standard.set(url, forKey: "HA_URL")
   - Entities → @Published var entities: [HAEntity]
   │
   ▼
Display Output:
   - connectionState = .connected (green badge)
   - EntityDiscoveryView shows discovered entities
   │
   ▼
Cross-Feature Output:
   - entityPublisher (Combine) → EnergyDiscoveryManager, DashboardViewModel
```

### Feature 2: Energy Entity Auto-Discovery
```
User Input: None (automatic after HA connect)
   │
   ▼
ViewModel: EnergyDiscoveryManager.discover(from: connectionManager)
   │  - Subscribe to connectionManager.$entities
   │  - For each entity:
   │    - Check entity.numericValue != nil
   │    - Apply 5 categorization rules:
   │      Rule 1: device_class == "energy" → consumption
   │      Rule 2: name contains "solar/pv/photovoltaic" → solar
   │      Rule 3: name contains "grid/import/export" → grid
   │      Rule 4: name contains "batt/storage" → battery
   │      Rule 5: unit == "kW" or "kWh" → energy entity
   │  - Populate solarEntities, gridEntities, batteryEntities, consumptionEntities
   │
   ▼
Model/Persistence:
   - Category mapping → UserDefaults (entity_id → category JSON)
   │
   ▼
Display Output:
   - EntityDiscoveryView: "Found 12 energy entities" with categorized list
   - "Start Monitoring ✨" button enabled
   │
   ▼
Cross-Feature Output:
   - solarEntities → DashboardViewModel (solar card)
   - gridEntities → DashboardViewModel (grid card)
   - batteryEntities → DashboardViewModel (battery card)
   - consumptionEntities → DashboardViewModel (total consumption)
```

### Feature 3: Real-Time Power Dashboard
```
User Input: None (opens to dashboard)
   │
   ▼
ViewModel: DashboardViewModel
   │  - Subscribes to HAConnectionManager.entityPublisher
   │  - On state_changed event:
   │    - Update currentPower for matching entity
   │    - Update @Published currentSolar, currentGrid, currentBattery, currentConsumption
   │    - Trigger DataReliabilityEngine.cacheSample()
   │    - Trigger CostCalculator.calculateCost() if kWh changed
   │    - Trigger AnomalyDetector.check() on power change
   │
   ▼
Model/Persistence:
   - In-memory: latest values per entity
   - SwiftData: EnergyRecord every 5 minutes (entity_id, value, unit, category, timestamp)
   │
   ▼
Display Output:
   - Header: "⚡ 4.3 kW" (total consumption, animated)
   - Metric cards: Solar 3.2 kW, Battery 78%, Grid 1.1 kW
   - Savings banner: "Today's savings: $4.32 🎉"
   │
   ▼
Cross-Feature Output:
   - currentPower → EnergyOverlayChart (live point)
   - currentPower → EnergyFlowDiagram (flow animation)
   - currentPower → Widget (via App Group, every 5 min)
   - currentPower → Live Activity (every 30 sec)
   - currentPower → Watch (via WatchConnectivity, every 5 min)
```

### Feature 4: Multi-Source Overlay Chart
```
User Input: Time range selection (Today/Week/Month/Year), pinch/drag gestures
   │
   ▼
ViewModel: DashboardViewModel.fetchChartData(range:)
   │  - Query SwiftData for EnergyRecord in date range
   │  - Aggregate by time stride (hour/day/month)
   │  - Build [EnergyDataPoint] with:
   │    - solarProduction (sum of solar category)
   │    - gridImport (sum of grid import)
   │    - batteryDischarge (sum of battery discharge)
   │    - totalConsumption (sum of consumption)
   │    - costPerKWh (from rate plan)
   │  - Pass to EnergyOverlayChart
   │
   ▼
Model/Persistence:
   - Read: SwiftData EnergyRecord (1-hour granularity)
   - Write: None (read-only)
   │
   ▼
Display Output:
   - Chart with AreaMark (solar green, grid red, battery blue)
   - LineMark (consumption orange, cost gray dashed)
   - Legend at bottom
   - X-axis: time-formatted per range
   - Y-axis: kW values
   │
   ▼
Cross-Feature Output:
   - None (terminal display)
```

### Feature 5: Cost Calculation + Savings
```
User Input: Rate plan config (via Settings)
   │
   ▼
ViewModel: CostCalculator.calculateCost(gridImportKWh, gridExportKWh, solarProductionKWh, at: date)
   │  - Switch on ratePlan:
   │    - .flat(rate): importCost = kWh * rate
   │    - .timeOfUse(peak, shoulder, offPeak, peakHours):
   │      - Get hour from date
   │      - Apply peak/shoulder/offPeak rate
   │    - .realTime(prices): look up price for date
   │  - exportCredit = gridExportKWh * feedInTariff (default $0.05)
   │  - netCost = importCost - exportCredit
   │  - co2Offset = solarProductionKWh * 0.417
   │  - Return CostResult
   │
   ▼
Model/Persistence:
   - Read: RatePlan from UserDefaults
   - Write: DailySummary (totalCost, solarRevenue, co2OffsetKg) to SwiftData
   │
   ▼
Display Output:
   - Savings banner: "Today's savings: $X.XX"
   - Details: "Revenue: $3.68", "CO₂ offset: 8.2 kg 🌱"
   │
   ▼
Cross-Feature Output:
   - CostResult → DashboardViewModel (savings banner)
   - co2OffsetKg → Details tab (CO₂ breakdown)
```

### Feature 6: AI Smart Suggestions
```
User Input: None (automatic, every 5 minutes)
   │
   ▼
ViewModel: SuggestionEngine.generateSuggestions(currentData, solarPower, batteryLevel, currentPrice, averagePrice)
   │  - Rule 1 (Solar Excess):
   │    IF solarPower - totalConsumption > 1.0 AND batteryLevel > 90
   │    THEN create suggestion: "Run high-power appliances now"
   │  - Rule 2 (Low Price):
   │    IF currentPrice < averagePrice * 0.7
   │    THEN create suggestion: "Electricity is cheap right now"
   │  - Rule 3 (Anomaly):
   │    IF totalConsumption > normalRange * 2.5
   │    THEN create suggestion: "Unusual energy spike"
   │  - Rule 4 (Battery Optimize):
   │    IF batteryLevel > 85 AND currentPrice < averagePrice
   │    THEN create suggestion: "Discharge during peak hours"
   │  - Core ML model: predicts best time windows for high-power appliances
   │
   ▼
Model/Persistence:
   - Read: UsageProfile (learned from 30+ days history)
   - Write: Suggestion history to SwiftData; dismissed suggestions to UserDefaults (24h suppression)
   │
   ▼
Display Output:
   - Suggestion cards on Dashboard and Insights tab
   - Each card: title, description, potential saving, action buttons
   │
   ▼
Cross-Feature Output:
   - High-priority suggestion (.showAlert) → NotificationScheduler
   - Suggestion with .setReminder(date) → UNUserNotificationCenter
```

### Feature 7: Anomaly Detection + Alerts
```
User Input: None (background monitoring)
   │
   ▼
ViewModel: AnomalyDetector.check(currentData)
   │  - Get current hour
   │  - Look up usageProfile.averageHourlyConsumption[hour]
   │  - IF currentData.totalConsumption > normal * 2.5
   │    AND hour NOT in known_high_usage_period
   │  - THEN trigger anomaly:
   │    - Create AnomalyEvent (timestamp, power, normalPower, ratio)
   │    - Persist to SwiftData
   │    - Schedule local notification via NotificationScheduler
   │
   ▼
Model/Persistence:
   - Read: UsageProfile (historical averages)
   - Write: AnomalyEvent to SwiftData
   │
   ▼
Display Output:
   - Push notification: "⚠️ Unusual spike: 8.2 kW at 3 AM"
   - In-app: Anomaly detail view with possible causes
   - Insights tab: Anomaly history list
   │
   ▼
Cross-Feature Output:
   - AnomalyEvent → Insights tab (history)
   - "It's Normal" action → UsageProfile (suppress future alerts for that hour)
```

### Feature 8: Energy Flow Diagram
```
User Input: None (real-time, automatic)
   │
   ▼
ViewModel: DashboardViewModel → EnergyFlowDiagram
   │  - Read currentSolar, currentGrid, currentBattery, currentConsumption
   │  - Calculate flows:
   │    - Solar → Home: min(solar, consumption)
   │    - Solar → Battery: solar - consumption (if positive, battery < 100)
   │    - Solar → Grid: excess after battery
   │    - Grid → Home: max(0, consumption - solar - battery)
   │    - Battery → Home: max(0, consumption - solar) if battery discharging
   │  - Animate particles proportional to flow magnitude
   │
   ▼
Model/Persistence:
   - None (real-time only)
   │
   ▼
Display Output:
   - Animated Sankey-style diagram with 4 nodes
   - Particles flow from source → destination
   - Node sizes proportional to power
   - Tap node → detail sheet
   │
   ▼
Cross-Feature Output:
   - None (terminal display)
```

### Feature 9: Electricity Rate Plan Config
```
User Input: Plan type selection, rate values, peak hours
   │
   ▼
ViewModel: SettingsViewModel.saveRatePlan(plan)
   │  - Validate rate values (positive numbers)
   │  - Encode RatePlan to JSON
   │  - Save to UserDefaults
   │  - Notify CostCalculator to use new plan
   │
   ▼
Model/Persistence:
   - Write: RatePlan JSON to UserDefaults
   │
   ▼
Display Output:
   - Settings: "Plan: Time-of-Use", "Peak: $0.32/kWh (4-9 PM)"
   - Dashboard: savings recalculated immediately
   │
   ▼
Cross-Feature Output:
   - RatePlan → CostCalculator (all future calculations)
```

### Feature 10: Historical Data (2-Year)
```
User Input: Time range selection, tap to drill down
   │
   ▼
ViewModel: DetailsViewModel.fetchHistory(range:)
   │  - Query SwiftData for DailySummary in date range
   │  - For Year view: aggregate to monthly
   │  - For Month view: show daily
   │  - For Week view: show daily
   │  - For Today: show hourly (from EnergyRecord)
   │
   ▼
Model/Persistence:
   - Read: DailySummary (2-year retention)
   - Write: Auto-cleanup records older than 2 years (background task)
   │
   ▼
Display Output:
   - Year: 12 monthly bars
   - Month: 28-31 daily bars
   - Week: 7 daily bars
   - Today: 24-hour curve
   - Tap bar → drill down to next granularity
   │
   ▼
Cross-Feature Output:
   - None (terminal display)
```

### Feature 11: CO₂ Carbon Offset Tracking
```
User Input: None (automatic)
   │
   ▼
ViewModel: CostCalculator (embedded in cost calculation)
   │  - co2Offset = solarProductionKWh * 0.417 (US grid average)
   │  - Persist to DailySummary.co2OffsetKg
   │
   ▼
Model/Persistence:
   - Write: DailySummary.co2OffsetKg
   │
   ▼
Display Output:
   - Dashboard: "CO₂ offset: 8.2 kg 🌱"
   - Details: CO₂ breakdown by day/month/year
   │
   ▼
Cross-Feature Output:
   - co2OffsetKg → Details tab
```

### Feature 12: Home Screen Widget
```
User Input: User adds widget from Home Screen
   │
   ▼
ViewModel: EnergyProvider.getTimeline()
   │  - Read shared UserDefaults (App Group) for latest EnergyEntry
   │  - Create timeline with 5-minute policy
   │  - Return Timeline(entries: [entry], policy: .atEnd)
   │
   ▼
Model/Persistence:
   - Read: App Group shared UserDefaults
   - Write: DashboardViewModel writes to App Group every 5 min
   │
   ▼
Display Output:
   - Small widget: total kW, today's savings
   - Medium widget: solar, grid, battery, savings
   │
   ▼
Cross-Feature Output:
   - Tap widget → opens app to Dashboard
```

### Feature 13: Live Activity (Lock Screen)
```
User Input: None (auto-starts when app launches)
   │
   ▼
ViewModel: DashboardViewModel → EnergyActivity
   │  - Create ActivityAttributes with current power values
   │  - Start ActivityKit session
   │  - Update every 30 seconds with new values
   │  - End session when app terminates
   │
   ▼
Model/Persistence:
   - None (ephemeral)
   │
   ▼
Display Output:
   - Lock Screen: compact (leading: total kW, trailing: solar kW)
   - Dynamic Island: expanded view with all 4 metrics
   │
   ▼
Cross-Feature Output:
   - None (terminal display)
```

### Feature 14: Apple Watch App
```
User Input: User opens WattPulse on Watch
   │
   ▼
ViewModel: WatchApp
   │  - Read latest EnergyEntry via WatchConnectivity
   │  - Display total kW, solar, grid, battery
   │  - Complication: shows total kW
   │
   ▼
Model/Persistence:
   - Read: WatchConnectivity transferred data
   - Cache: Latest entry on Watch for offline
   │
   ▼
Display Output:
   - Watch main view: 4 metric cards
   - Complication: total kW
   │
   ▼
Cross-Feature Output:
   - None (terminal display)
```

### Feature 15: CSV Data Export
```
User Input: Date range selection, share target
   │
   ▼
ViewModel: CSVExporter.export(range:)
   │  - Query SwiftData for DailySummary in range
   │  - Build CSV string:
   │    Header: date,solar_kwh,grid_import_kwh,grid_export_kwh,battery_charge_kwh,battery_discharge_kwh,consumption_kwh,cost_usd,solar_revenue_usd,co2_offset_kg
   │    Rows: one per day
   │  - Write to Documents directory
   │  - Present UIActivityViewController
   │
   ▼
Model/Persistence:
   - Read: DailySummary records
   - Write: CSV file to Documents
   │
   ▼
Display Output:
   - Share sheet with CSV file
   - User can AirDrop, email, save to Files
   │
   ▼
Cross-Feature Output:
   - None (terminal export)
```

### Feature 16: Offline Cache + Data Reliability
```
User Input: None (automatic)
   │
   ▼
ViewModel: DataReliabilityEngine
   │  - Layer 1 (Real-time cache): In-memory 24h, 5-min granularity
   │  - Layer 2 (Persistence): SwiftData 2-year, 1h granularity
   │  - Layer 3 (Anomaly detection):
   │    - Jump detection: value changes > 10x
   │    - Missing detection: no update > 15 min
   │    - Conflict detection: HA value vs cache mismatch
   │  - Layer 4 (Repair):
   │    - Jump: moving average smoothing
   │    - Missing: linear interpolation
   │    - Conflict: prefer HA value, mark cache deviation
   │  - On WebSocket disconnect:
   │    - Show "Offline — showing cached data" banner
   │    - Serve cached data
   │    - Queue missed updates for sync on reconnect
   │
   ▼
Model/Persistence:
   - Read: In-memory cache, SwiftData
   - Write: SwiftData (hourly), in-memory (5-min)
   │
   ▼
Display Output:
   - Offline banner when disconnected
   - "Cached 5 min ago" label
   - Smooth data despite HA hiccups
   │
   ▼
Cross-Feature Output:
   - Cached data → DashboardViewModel (when offline)
```

### Feature 17: Multi-HA Instance Support
```
User Input: Add instance (URL + token), switch active instance
   │
   ▼
ViewModel: HAConnectionManager
   │  - Store multiple instance configs in Keychain + UserDefaults
   │  - Active instance: current WebSocket connection
   │  - Switch: close current connection, open new with selected instance
   │  - Re-run EnergyDiscoveryManager.discover()
   │
   ▼
Model/Persistence:
   - Read/Write: Keychain (tokens), UserDefaults (URLs + active index)
   │
   ▼
Display Output:
   - Settings: instance list with active indicator
   - Switch updates dashboard within 1s
   │
   ▼
Cross-Feature Output:
   - New entities → DashboardViewModel, all features
```

### Feature 18: Time Range Switching
```
User Input: Tap Today/Week/Month/Year segmented control
   │
   ▼
ViewModel: DashboardViewModel.changeTimeRange(range)
   │  - Update @Published selectedRange
   │  - Call fetchChartData(range:)
   │  - Adjust chart x-axis stride and date format
   │
   ▼
Model/Persistence:
   - None (view state)
   │
   ▼
Display Output:
   - Chart updates with new data and x-axis formatting
   │
   ▼
Cross-Feature Output:
   - None (terminal display)
```

### Feature 19: Contact Support
```
User Input: Name, email, message
   │
   ▼
ViewModel: ContactSupportView → POST to FEEDBACK_BACKEND_URL
   │  - Validate fields (non-empty, valid email format)
   │  - Build JSON payload: {app_name, app_version, device_info, name, email, message}
   │  - POST via URLSession
   │  - Show success toast or error alert
   │
   ▼
Model/Persistence:
   - None (stateless)
   │
   ▼
Display Output:
   - Success: "Message sent!" toast, form clears
   - Error: "Failed to send. Please try again." alert
   │
   ▼
Cross-Feature Output:
   - None (terminal)
```

### Feature 20: One-Time Purchase (StoreKit 2)
```
User Input: Tap "Unlock WattPulse Pro", confirm purchase
   │
   ▼
ViewModel: StoreManager.purchase()
   │  - Fetch Product with ID "com.zzoutuo.WattPulse.pro"
   │  - Call Product.purchase()
   │  - Listen to Transaction.updates for async updates
   │  - On success: set @Published isPremium = true
   │  - On failure: show error alert
   │
   ▼
Model/Persistence:
   - Read/Write: StoreKit 2 (server-validated, no local storage needed)
   │
   ▼
Display Output:
   - Paywall dismissed on success
   - All features unlocked
   - Settings: "WattPulse Pro ✅"
   │
   ▼
Cross-Feature Output:
   - isPremium: Bool → All feature gates
```

## Implementation Flow

1. **Project Setup**: Configure Xcode project with SwiftData, WidgetKit extension, Watch app target, App Group, Keychain entitlements.
2. **Models & Services**: Define `HAEntity`, `EnergyDataPoint`, `EnergyRecord`, `DailySummary`, `RatePlan`, `EnergySuggestion`, `CostResult`, `TimeRange`.
3. **HA Connection Layer**: Implement `HAConnectionManager` (WebSocket auth, subscribe, receive loop, auto-reconnect), `KeychainService` for token.
4. **Discovery Layer**: Implement `EnergyDiscoveryManager` with 5 categorization rules.
5. **Dashboard UI**: Build `DashboardView` with metric cards, `EnergyOverlayChart` (Swift Charts), `EnergyFlowDiagram`, `SavingsBanner`, `TimeRangePicker`.
6. **Cost Engine**: Implement `CostCalculator` with flat/TOU/realTime rate plans, CO₂ offset.
7. **AI Layer**: Implement `SuggestionEngine` (4 rules + Core ML), `AnomalyDetector`, `NotificationScheduler`.
8. **Data Reliability**: Implement `DataReliabilityEngine` (cache, interpolation, smoothing, offline banner).
9. **Details Tab**: Build `DetailsView` with hourly curve, monthly bars, drill-down.
10. **Insights Tab**: Build `InsightsView` with suggestion cards, weekly summary, anomaly history.
11. **Settings Tab**: Build `SettingsView` with HA connection, rate plan, notifications, appearance, about, contact support.
12. **Onboarding**: Build `WelcomeView`, `HAConnectView`, `EntityDiscoveryView`.
13. **StoreKit 2**: Implement `StoreManager` with one-time purchase, paywall, restore.
14. **Widget**: Implement `WattPulseWidget` with App Group shared data.
15. **Live Activity**: Implement `EnergyActivityAttributes` with Lock Screen / Dynamic Island views.
16. **Apple Watch**: Build Watch app with metric cards and complication.
17. **CSV Export**: Implement `CSVExporter` with share sheet.
18. **Polish**: Animations, haptics, accessibility (VoiceOver, Dynamic Type, color-blind safe), dark mode.
19. **Testing**: Unit tests for cost calc, anomaly detection, categorization; UI tests for dashboard flow.
20. **App Store**: Screenshots, metadata, submission.

## UI/UX Design Specifications

### Color Scheme
| Purpose | Color | Hex |
|---------|-------|-----|
| Solar production | Green | `#34C759` (Apple system green) |
| Grid import | Red | `#FF3B30` (Apple system red) |
| Battery storage | Blue | `#007AFF` (Apple system blue) |
| Home consumption | Orange | `#FF9500` (Apple system orange) |
| Cost low (deep green) | `#248A3D` |
| Cost medium (light green) | `#4CD964` |
| Cost high (light red) | `#FF6B6B` |
| Cost extreme (deep red) | `#D70015` |
| Background (dark) | Pure black `#000000` (OLED-friendly) |
| Background (light) | White `#FFFFFF` |
| Card background (dark) | `#1C1C1E` |
| Card background (light) | `#F2F2F7` |

### Typography
| Use | Font | Size | Weight |
|-----|------|------|--------|
| Real-time power number | SF Pro Rounded | 48pt | Bold |
| Card title | SF Pro | 13pt | Medium |
| Card value | SF Pro Rounded | 24pt | Semibold |
| Chart label | SF Pro | 11pt | Regular |
| Suggestion title | SF Pro | 17pt | Semibold |
| Suggestion description | SF Pro | 15pt | Regular |
| Savings amount | SF Pro Rounded | 20pt | Bold |

### Layout
- 4-tab `TabView`: Dashboard, Details, Insights, Settings
- Dashboard: vertical scroll — header → metric cards (horizontal scroll) → energy flow → overlay chart → suggestion card → savings banner → time range picker
- Cards: rounded corners (16pt), subtle shadow, padding 16pt
- Chart: full width, 240pt height, 16pt horizontal padding

### Animations
| Animation | Duration | Curve | Use |
|-----------|----------|-------|-----|
| Page transition | 0.3s | easeInOut | Tab switches |
| Number update | 0.5s | spring | Power value changes |
| Chart draw | 0.8s | easeOut | Initial load (left-to-right) |
| Card expand | 0.3s | spring | Suggestion card tap |
| Energy flow | continuous | linear | Particle flow |
| Color transition | 0.3s | easeInOut | Cost threshold color |

### Haptics
- `.light` on power change > 20%
- `.light` on chart zoom boundary
- `.light` on time range switch
- `.medium` on suggestion card expand
- `.heavy` on "Set Reminder" confirmation

## Code Generation Rules

1. **One feature per module**, high cohesion, low coupling.
2. **Semantic naming**, clear file structure following Module Structure above.
3. **Never add comments in code** unless asked.
4. **Apple native first**: prioritize SwiftUI, Swift Charts, SwiftData, Combine, Core ML, WidgetKit, ActivityKit.
5. **Open source first**: reference HAClient (MIT) for HA WebSocket patterns — but implement natively (do not add as dependency, to avoid maintenance burden).
6. **Strict concurrency**: `@MainActor` on ViewModels, `async/await` on services, no completion handlers.
7. **Error handling**: `Result` type or `throws`, never `try!` or force unwrap.
8. **No UIKit** except where WidgetKit requires (none expected — pure SwiftUI).
9. **Code comments in English**, UI copy in English (US market).
10. **Minimum iOS 17.0** deployment target.
11. **`#Preview` macros** for all SwiftUI views.
12. **Chart data must pass through time alignment and anomaly detection** before rendering.
13. **Follow Swift API Design Guidelines** — clear, concise, semantic names.
14. **Version number**: Read dynamically via `Bundle.main.infoDictionary` — never hardcode.

## Build & Deployment Checklist

- [ ] Xcode project configured with iOS 17.0 deployment target
- [ ] App Group entitlement (for Widget data sharing)
- [ ] Keychain entitlement (for HA token storage)
- [ ] WidgetKit extension target
- [ ] Watch app target (watchOS 10+)
- [ ] StoreKit 2 configuration (Product ID: `com.zzoutuo.WattPulse.pro`, $4.99)
- [ ] SwiftData model container configured in `WattPulseApp.swift`
- [ ] Core ML model added to project (`WattPulseML.mlmodel`)
- [ ] App icon generated and added to Assets.xcassets
- [ ] Launch screen configured
- [ ] Info.plist: `NSLocalNetworkUsageDescription` (for HA discovery)
- [ ] Info.plist: `NSAppTransportSecurity` (allow HTTP for local HA)
- [ ] Build succeeds on iPhone 15 Pro simulator
- [ ] Build succeeds on iPad Pro simulator
- [ ] All features functional in simulator
- [ ] App Store screenshots prepared
- [ ] App Store metadata prepared (keytext.md)
- [ ] Privacy policy URL live
- [ ] Terms of Use URL live
- [ ] Support page URL live

---

**PHASE 1 COMPLETE**
- APP_NAME: WattPulse
- BUNDLE_ID: com.zzoutuo.WattPulse
- MIN_IOS: 17.0
- GITHUB_USER: asunnyboy861
- CONTACT_EMAIL: iocompile67692@gmail.com
- MONETIZATION_HINT: paid ($4.99 one-time purchase)
- AI_FEATURE_NEEDED: yes (Core ML on-device inference for suggestions, anomaly detection, usage pattern learning)
- AI_MODEL_TYPE: built_in (Core ML local model, no user API key required)
- GUIDE_REFERENCES:
  - https://github.com/c-st/HAClient
  - https://github.com/HPMM2/Swift-Changemakers-Hackathon-2026---Tonalli-App
  - https://github.com/esmakocak/FocusPower
  - https://github.com/robeertm/shelly-energy-analyzer
  - https://github.com/dangerchris/emporia-vue-ts
  - https://github.com/TobiasLaross/IntelliNest
- FEATURE_COUNT: 20 primary features
- SUB_FEATURE_COUNT: 15 sub-features
- CROSS_FEATURE_DEPENDENCIES: 14
- DATA_FLOW_COUNT: 20 (one per primary feature)
- VERIFICATION: FEATURE_COUNT in us.md matches the actual feature count in the Chinese guide: YES (20 = 20)
