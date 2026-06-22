import Foundation

enum AppConfig {
    static let appName = "WattPulse"
    static let appBundleId = "com.zzoutuo.WattPulse"
    static let feedbackBackendURL = "https://feedback-worker.sunmingming.workers.dev"
    static let githubUser = "asunnyboy861"
    static let contactEmail = "iocompile67692@gmail.com"
    static let supportPageURL = "https://\(githubUser).github.io/WattPulse/support.html"
    static let privacyPageURL = "https://\(githubUser).github.io/WattPulse/privacy.html"
    static let termsPageURL = "https://\(githubUser).github.io/WattPulse/terms.html"

    static let co2FactorKgPerKWh: Double = 0.417
    static let defaultFeedInTariff: Double = 0.05
    static let cacheRetentionDays: Int = 1
    static let dataRetentionDays: Int = 730
    static let widgetUpdateIntervalMinutes: Int = 5
    static let liveActivityUpdateIntervalSeconds: Int = 30
    static let suggestionRefreshIntervalMinutes: Int = 5
    static let anomalyThresholdMultiplier: Double = 2.5
    static let sampleIntervalMinutes: Int = 5
    static let aggregationIntervalMinutes: Int = 60
    static let maxReconnectAttempts: Int = 5
    static let haDefaultPort: Int = 8123
    static let appGroupIdentifier = "group.com.zzoutuo.WattPulse"
}
