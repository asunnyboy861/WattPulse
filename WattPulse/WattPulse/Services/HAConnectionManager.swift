import Foundation
import Combine

enum HAConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)

    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    var displayText: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting…"
        case .connected: return "Connected"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

struct HAInstance: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var url: String
    var token: String

    init(name: String, url: String, token: String) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.token = token
    }
}

@MainActor
final class HAConnectionManager: ObservableObject {
    static let shared = HAConnectionManager()

    @Published private(set) var connectionState: HAConnectionState = .disconnected
    @Published private(set) var entities: [HAEntity] = []
    @Published private(set) var instances: [HAInstance] = []
    @Published private(set) var activeInstanceId: UUID?

    let entityPublisher = PassthroughSubject<HAEntity, Never>()
    let statePublisher = PassthroughSubject<HAConnectionState, Never>()

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private var receiveTask: Task<Void, Never>?
    private var reconnectAttempts: Int = 0
    private var nextMessageId: Int = 1
    private var pendingSubscriptions: Set<String> = []

    private init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        self.urlSession = URLSession(configuration: config)
        loadInstances()
    }

    var activeInstance: HAInstance? {
        guard let id = activeInstanceId else { return nil }
        return instances.first { $0.id == id }
    }

    var hasConfiguredInstance: Bool {
        !instances.isEmpty
    }

    func loadInstances() {
        guard let data = UserDefaults.standard.data(forKey: "HA_INSTANCES"),
              let decoded = try? JSONDecoder().decode([HAInstance].self, from: data) else { return }
        instances = decoded
        activeInstanceId = instances.first?.id
    }

    func saveInstances() {
        if let data = try? JSONEncoder().encode(instances) {
            UserDefaults.standard.set(data, forKey: "HA_INSTANCES")
        }
    }

    func addInstance(name: String, url: String, token: String) {
        let instance = HAInstance(name: name, url: url, token: token)
        instances.append(instance)
        if activeInstanceId == nil {
            activeInstanceId = instance.id
        }
        saveInstances()
        KeychainService.save(token, account: instance.id.uuidString)
    }

    func removeInstance(_ instance: HAInstance) {
        instances.removeAll { $0.id == instance.id }
        KeychainService.delete(account: instance.id.uuidString)
        if activeInstanceId == instance.id {
            activeInstanceId = instances.first?.id
        }
        saveInstances()
        if instances.isEmpty {
            disconnect()
        }
    }

    func switchToInstance(_ instance: HAInstance) {
        activeInstanceId = instance.id
        saveInstances()
        Task { await connect() }
    }

    func connect() async {
        guard let instance = activeInstance else {
            connectionState = .error("No HA instance configured")
            return
        }

        let token = KeychainService.readString(account: instance.id.uuidString) ?? instance.token
        guard !token.isEmpty else {
            connectionState = .error("Missing access token")
            return
        }

        disconnect()
        connectionState = .connecting
        statePublisher.send(.connecting)

        guard let wsURL = buildWebSocketURL(from: instance.url) else {
            connectionState = .error("Invalid HA URL")
            statePublisher.send(.error("Invalid HA URL"))
            return
        }

        var request = URLRequest(url: wsURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()

        connectionState = .connected
        statePublisher.send(.connected)
        reconnectAttempts = 0

        await authenticate(token: token)
        startReceiveLoop()
        fetchStates()
    }

    func disconnect() {
        receiveTask?.cancel()
        receiveTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
        statePublisher.send(.disconnected)
        entities = []
    }

    private func buildWebSocketURL(from rawURL: String) -> URL? {
        var urlString = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasPrefix("http://") {
            urlString = "ws://" + urlString.dropFirst("http://".count)
        } else if urlString.hasPrefix("https://") {
            urlString = "wss://" + urlString.dropFirst("https://".count)
        } else if !urlString.hasPrefix("ws://") && !urlString.hasPrefix("wss://") {
            urlString = "ws://" + urlString
        }
        if !urlString.hasSuffix("/api/websocket") {
            urlString += "/api/websocket"
        }
        return URL(string: urlString)
    }

    private func authenticate(token: String) async {
        guard let task = webSocketTask else { return }

        do {
            let firstMessage = try await task.receive()
            if case .string(let text) = firstMessage,
               let data = text.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               json["type"] as? String == "auth_required" {
                let authMessage: [String: Any] = [
                    "type": "auth",
                    "access_token": token
                ]
                if let authData = try? JSONSerialization.data(withJSONObject: authMessage),
                   let authText = String(data: authData, encoding: .utf8) {
                    task.send(.string(authText)) { _ in }
                }
            }
        } catch {
            connectionState = .error("Auth failed: \(error.localizedDescription)")
            scheduleReconnect()
        }
    }

    private func startReceiveLoop() {
        receiveTask = Task { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                do {
                    guard let task = self.webSocketTask else { break }
                    let message = try await task.receive()
                    self.handleMessage(message)
                } catch {
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.scheduleReconnect()
                        }
                    }
                    break
                }
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            handleJSON(json)
        case .data(let data):
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            handleJSON(json)
        @unknown default:
            break
        }
    }

    private func handleJSON(_ json: [String: Any]) {
        guard let type = json["type"] as? String else { return }

        switch type {
        case "auth_ok":
            subscribeToStateChanges()
        case "event":
            if let eventData = json["event"] as? [String: Any],
               let newState = eventData["new_state"] as? [String: Any] {
                handleStateChange(newState)
            }
        case "result":
            if let result = json["result"] as? [[String: Any]] {
                let newEntities = result.compactMap { HAEntityParser.parse($0) }
                entities = newEntities
            }
        default:
            break
        }
    }

    private func subscribeToStateChanges() {
        let message: [String: Any] = [
            "id": nextMessageId,
            "type": "subscribe_events",
            "event_type": "state_changed"
        ]
        sendMessage(message)
        nextMessageId += 1
    }

    private func fetchStates() {
        let message: [String: Any] = [
            "id": nextMessageId,
            "type": "get_states"
        ]
        sendMessage(message)
        nextMessageId += 1
    }

    private func sendMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let text = String(data: data, encoding: .utf8) else { return }
        webSocketTask?.send(.string(text)) { _ in }
    }

    private func handleStateChange(_ stateDict: [String: Any]) {
        guard let entity = HAEntityParser.parse(stateDict) else { return }
        if let index = entities.firstIndex(where: { $0.entityId == entity.entityId }) {
            entities[index] = entity
        } else {
            entities.append(entity)
        }
        entityPublisher.send(entity)
    }

    private func scheduleReconnect() {
        guard reconnectAttempts < AppConfig.maxReconnectAttempts else {
            connectionState = .error("Max reconnect attempts reached")
            return
        }
        reconnectAttempts += 1
        let delay = pow(2.0, Double(reconnectAttempts))
        connectionState = .connecting
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            await connect()
        }
    }
}

enum HAEntityParser {
    static func parse(_ dict: [String: Any]) -> HAEntity? {
        guard let entityId = dict["entity_id"] as? String else { return nil }
        let state = dict["state"] as? String ?? ""
        let attributes = dict["attributes"] as? [String: Any] ?? [:]
        let name = (attributes["friendly_name"] as? String) ?? entityId
        let unit = attributes["unit_of_measurement"] as? String
        let deviceClass = attributes["device_class"] as? String
        let category = categorize(entityId: entityId, deviceClass: deviceClass, unit: unit)
        return HAEntity(entityId: entityId, name: name, state: state, unit: unit, deviceClass: deviceClass, category: category)
    }

    private static func categorize(entityId: String, deviceClass: String?, unit: String?) -> EnergyCategory {
        let lower = entityId.lowercased()
        if lower.contains("solar") || lower.contains("pv") || lower.contains("photovolta") || lower.contains("_production") {
            return .solar
        }
        if lower.contains("battery") || lower.contains("batt") || lower.contains("storage") || lower.contains("_charge") || lower.contains("_discharge") {
            return .battery
        }
        if lower.contains("grid") || lower.contains("import") || lower.contains("export") || lower.contains("meter") {
            return .grid
        }
        if deviceClass == "energy" || deviceClass == "power" {
            return .consumption
        }
        if unit?.lowercased() == "kw" || unit?.lowercased() == "kwh" {
            return .consumption
        }
        return .unknown
    }
}
