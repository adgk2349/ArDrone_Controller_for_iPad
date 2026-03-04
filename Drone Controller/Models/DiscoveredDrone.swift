import Foundation

struct DiscoveredDrone: Identifiable, Equatable {
    let id: UUID
    let name: String
    let rssi: Int
    let isRecommended: Bool
    let isGenericModule: Bool
    let isKnownDevice: Bool

    var signalSummary: String {
        switch rssi {
        case ..<(-90):
            return "Weak"
        case ..<(-75):
            return "Fair"
        case ..<(-60):
            return "Good"
        default:
            return "Strong"
        }
    }
}
