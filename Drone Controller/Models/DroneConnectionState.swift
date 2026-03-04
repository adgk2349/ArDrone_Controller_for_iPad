import Foundation

enum DroneConnectionState: Equatable {
    case idle
    case scanning
    case connecting(String)
    case connected(String)
    case bluetoothUnavailable(String)
    case failed(String)

    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }

    var title: String {
        switch self {
        case .idle:
            return "Ready to connect"
        case .scanning:
            return "Scanning for drone"
        case let .connecting(name):
            return "Connecting to \(name)"
        case let .connected(name):
            return "Connected to \(name)"
        case .bluetoothUnavailable:
            return "Bluetooth unavailable"
        case .failed:
            return "Connection failed"
        }
    }

    var detail: String {
        switch self {
        case .idle:
            return "Use Scan to search for your HM-10 drone."
        case .scanning:
            return "Move close to the drone and keep it powered on."
        case let .connecting(name):
            return "\(name) was discovered. Completing BLE service discovery."
        case .connected:
            return "RC packets and telemetry can flow over the HM-10 link."
        case let .bluetoothUnavailable(reason):
            return reason
        case let .failed(reason):
            return reason
        }
    }
}
