import Foundation

struct MSPPacket: Equatable {
    enum Direction: Equatable {
        case toFlightController
        case fromFlightController
        case error

        init?(byte: UInt8) {
            switch byte {
            case 0x3C:
                self = .toFlightController
            case 0x3E:
                self = .fromFlightController
            case 0x21:
                self = .error
            default:
                return nil
            }
        }
    }

    let command: UInt8
    let payload: Data
    let direction: Direction
}
