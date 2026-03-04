import Foundation

enum AuxChannelLevel: UInt8, CaseIterable, Identifiable {
    case low = 0
    case mid = 1
    case high = 2

    var id: UInt8 { rawValue }

    var title: String {
        switch self {
        case .low:
            return "Low"
        case .mid:
            return "Mid"
        case .high:
            return "High"
        }
    }
}
