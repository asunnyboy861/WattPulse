# WattPulse — App Store Connect Metadata (keytext.md)

## App Information
- **App Name**: WattPulse
- **Bundle ID**: com.zzoutuo.WattPulse
- **Primary Language**: English (U.S.)
- **Category**: Utilities
- **Secondary Category**: Lifestyle
- **Content Rating**: 4+
- **Price**: $4.99 USD (One-Time Purchase)
- **Availability**: All regions

---

## Promotional Text (170 characters max)
Real-time solar, grid & battery monitoring with AI suggestions. Connect Home Assistant and see your energy heartbeat. Track costs, CO₂ offset, and savings instantly.

---

## Description (4000 characters max)

WattPulse brings your home's energy to life. Connect your Home Assistant instance and watch solar production, grid usage, battery status, and total consumption flow together in one beautiful overlay chart.

REAL-TIME ENERGY MONITORING
• Live solar, grid, battery, and consumption metrics
• Animated energy flow diagram shows power moving through your home
• Instant updates via Home Assistant WebSocket
• Offline cache keeps data visible even when HA is unreachable

MULTI-SOURCE OVERLAY CHART
• See solar, grid, battery, and consumption on a single chart
• Switch between Today, Week, Month, and Year views
• Smooth Swift Charts visualization with interactive legends
• Compare historical patterns across 2 years of data

AI-POWERED SUGGESTIONS
• On-device suggestions to optimize energy usage
• Solar excess alerts — run appliances when production peaks
• Low-price alerts — shift load to off-peak hours
• Battery optimization tips for maximum self-consumption
• All suggestions generated locally — no cloud, no tracking

ANOMALY DETECTION
• WattPulse learns your typical usage patterns
• Get alerts when consumption spikes above normal
• Mark events as "normal" to improve detection accuracy
• History log of all detected anomalies

COST & SAVINGS TRACKING
• Three rate plan types: Flat, Time-of-Use, Real-Time Pricing
• Automatic cost calculations based on your actual rates
• Feed-in tariff support for solar export credits
• See daily, weekly, monthly, and yearly savings at a glance

CO₂ CARBON OFFSET
• Track your solar contribution to reducing emissions
• 0.417 kg/kWh emission factor (configurable)
• See your carbon offset in real time
• Monthly and yearly CO₂ summaries

HOME ASSISTANT INTEGRATION
• Direct WebSocket connection — no cloud middleman
• Auto-discovery of solar, grid, battery, and consumption sensors
• Support for multiple HA instances (home, office, vacation home)
• Secure token storage in iOS Keychain
• Works with Home Assistant 2023.x and later

DATA EXPORT & PRIVACY
• Export energy data as CSV for any time range
• All data stored locally on your device
• No analytics, no tracking, no cloud sync
• Your energy data never leaves your phone

CUSTOMIZATION
• Choose between System, Light, and Dark appearance
• Configure notification preferences (anomaly, low-price, suggestions)
• Set up multiple HA instances and switch between them
• Customize rate plans to match your utility bill

WattPulse is a one-time purchase. No subscriptions, no ads, no in-app purchases. Buy once, use forever.

REQUIREMENTS
• iOS 17.0 or later
• iPhone or iPad
• Home Assistant 2023.x or later
• Home Assistant Long-Lived Access Token

WattPulse is not affiliated with Home Assistant. Home Assistant is a trademark of its respective owners.

---

## Keywords (100 characters max, comma-separated)

solar,energy,home assistant,monitor,power,battery,grid,consumption,electricity,cost,co2

---

## What's New (Version 1.0.0)

Welcome to WattPulse 1.0 — the complete home energy visualization app!

• Real-time multi-source overlay chart (solar, grid, battery, consumption)
• AI-powered energy suggestions generated on-device
• Anomaly detection with user feedback loop
• Cost calculations for flat, time-of-use, and real-time pricing plans
• CO₂ carbon offset tracking
• 2-year historical data with SwiftData
• CSV data export
• Multi-HA instance support
• Offline cache with data reliability engine
• Beautiful SwiftUI interface with dark mode

Connect your Home Assistant and start monitoring in under 60 seconds.

---

## App URL
https://github.com/asunnyboy861/WattPulse

## Support URL
https://asunnyboy861.github.io/WattPulse/support.html

## Privacy Policy URL
https://asunnyboy861.github.io/WattPulse/privacy.html

## Marketing URL
https://asunnyboy861.github.io/WattPulse/

---

## Review Notes

WattPulse is a paid utility app ($4.99 one-time purchase) for home energy monitoring with Home Assistant integration.

HOW TO TEST:
1. The app requires a Home Assistant instance to function. If you don't have HA installed, you can download it from https://www.home-assistant.io/
2. On first launch, you'll see the Welcome screen. Tap "Get Started".
3. Enter any Home Assistant URL (e.g., http://homeassistant.local:8123) and any string as a token.
4. The app will attempt to connect. If connection fails, you'll see an error message — this is expected without a real HA instance.
5. To fully test, you'll need a running Home Assistant with energy sensors configured.

KEY FEATURES TO REVIEW:
- Onboarding flow (Welcome → HA Connect → Entity Discovery)
- Dashboard with real-time metrics, energy flow diagram, and overlay chart
- Details tab with hourly curve and monthly bar charts
- Insights tab with AI suggestions and anomaly history
- Settings tab with rate plan configuration, notifications, appearance, CSV export
- Contact Support form (accessible from Settings)

PRIVACY:
- All data is stored locally on-device using SwiftData
- HA tokens are stored in iOS Keychain
- No analytics, no tracking, no cloud services
- AI suggestions are generated on-device (no Core ML model required for review)

SUBSCRIPTION:
- This is a one-time purchase app ($4.99). No subscriptions, no auto-renewal, no free trial.

CONTACT:
- Support: support@wattpulse.app
- Privacy: https://asunnyboy861.github.io/WattPulse/privacy.html
- Terms: https://asunnyboy861.github.io/WattPulse/terms.html

---

## App Store Localizations

### English (U.S.) — Primary
- Name: WattPulse
- Subtitle: Home Energy Monitor for HA
- Keywords: solar,energy,home assistant,monitor,power,battery,grid,consumption,electricity,cost,co2
- Promotional Text: Real-time solar, grid & battery monitoring with AI suggestions. Connect Home Assistant and see your energy heartbeat. Track costs, CO₂ offset, and savings instantly.

### English (U.K.)
- Name: WattPulse
- Subtitle: Home Energy Monitor for HA
- Keywords: solar,energy,home assistant,monitor,power,battery,grid,consumption,electricity,cost,co2

### Simplified Chinese
- Name: WattPulse
- Subtitle: 家庭能耗监测助手
- Keywords: 太阳能,能源,家庭助手,监控,电力,电池,电网,能耗,电费,碳排放
- Promotional Text: 实时太阳能、电网和电池监控，AI智能建议。连接Home Assistant，查看家庭能耗心跳。即时追踪费用、碳减排和节省金额。

### Japanese
- Name: WattPulse
- Subtitle: 家庭エネルギーモニター
- Keywords: ソーラー,エネルギー,ホームアシスタント,モニター,電力,バッテリー,グリッド,消費,電気代,CO2

### German
- Name: WattPulse
- Subtitle: Energie-Monitor für Home Assistant
- Keywords: solar,energie,home assistant,monitor,strom,batterie,netz,verbrauch,kosten,co2

### French
- Name: WattPulse
- Subtitle: Moniteur d'énergie domestique
- Keywords: solaire,énergie,home assistant,moniteur,puissance,batterie,réseau,consommation,électricité,coût

### Spanish
- Name: WattPulse
- Subtitle: Monitor de energía para HA
- Keywords: solar,energía,home assistant,monitor,potencia,batería,red,consumo,electricidad,coste

---

## ASO Strategy Notes

### Primary Keywords (high relevance, moderate competition)
- "home assistant" — direct integration match
- "solar monitor" — high intent
- "energy monitor" — broad category
- "battery monitor" — feature-specific
- "grid power" — feature-specific

### Long-tail Keywords
- "home assistant dashboard"
- "solar energy tracker"
- "electricity cost calculator"
- "home energy monitor"
- "smart home energy"

### Competitive Positioning
- vs. Home Assistant official app: WattPulse focuses on energy visualization, not general HA control
- vs. Sense/Emporia: WattPulse works with existing HA sensors, no additional hardware
- vs. PVOutput: WattPulse is native iOS, real-time, with AI suggestions

### Category Strategy
- Primary: Utilities (energy monitoring fits naturally)
- Secondary: Lifestyle (home management)
