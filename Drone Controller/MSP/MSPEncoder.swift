import Foundation

enum MSPEncoder {
    static func statusRequestPacket() -> Data {
        packet(command: .status)
    }

    static func motorStatusRequestPacket() -> Data {
        packet(command: .motor)
    }

    static func rcStatusRequestPacket() -> Data {
        packet(command: .rc)
    }

    static func armPacket() -> Data {
        packet(command: .arm)
    }

    static func disarmPacket() -> Data {
        packet(command: .disarm)
    }

    static func airStatusRequestPacket() -> Data {
        packet(command: .air)
    }

    static func accCalibrationPacket() -> Data {
        packet(command: .accCalibration)
    }

    static func resetConfPacket() -> Data {
        packet(command: .resetConf)
    }

    static func controlPacket(_ frame: RCFrame) -> Data {
        packet(command: .setRawRCSerial, payload: [
            quantize(frame.roll),
            quantize(frame.pitch),
            quantize(frame.yaw),
            quantize(frame.throttle),
            packedAuxChannels(
                aux1: frame.aux1,
                aux2: frame.aux2,
                aux3: frame.aux3,
                aux4: frame.aux4
            )
        ])
    }

    static func packet(command: MSPCommand, payload: [UInt8] = []) -> Data {
        let size = UInt8(payload.count)
        var checksum = size ^ command.rawValue
        var bytes: [UInt8] = [0x24, 0x4D, 0x3C, size, command.rawValue]

        for byte in payload {
            bytes.append(byte)
            checksum ^= byte
        }

        bytes.append(checksum)
        return Data(bytes)
    }

    private static func quantize(_ value: UInt16) -> UInt8 {
        let clamped = min(max(Int(value), 1000), 2000)
        return UInt8((clamped - 1000) / 4)
    }

    private static func packedAuxChannels(
        aux1: AuxChannelLevel,
        aux2: AuxChannelLevel,
        aux3: AuxChannelLevel,
        aux4: AuxChannelLevel
    ) -> UInt8 {
        (aux1.rawValue << 6) |
        (aux2.rawValue << 4) |
        (aux3.rawValue << 2) |
        aux4.rawValue
    }
}
