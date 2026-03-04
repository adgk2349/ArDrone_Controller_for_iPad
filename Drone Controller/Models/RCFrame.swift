import Foundation

struct RCFrame: Equatable {
    var roll: UInt16
    var pitch: UInt16
    var yaw: UInt16
    var throttle: UInt16
    var aux1: AuxChannelLevel
    var aux2: AuxChannelLevel
    var aux3: AuxChannelLevel
    var aux4: AuxChannelLevel

    static let neutral = RCFrame(
        roll: 1500,
        pitch: 1500,
        yaw: 1500,
        throttle: 1000,
        aux1: .low,
        aux2: .low,
        aux3: .low,
        aux4: .low
    )

    init(
        roll: UInt16,
        pitch: UInt16,
        yaw: UInt16,
        throttle: UInt16,
        aux1: AuxChannelLevel,
        aux2: AuxChannelLevel,
        aux3: AuxChannelLevel,
        aux4: AuxChannelLevel
    ) {
        self.roll = Self.clamp(roll)
        self.pitch = Self.clamp(pitch)
        self.yaw = Self.clamp(yaw)
        self.throttle = Self.clamp(throttle)
        self.aux1 = aux1
        self.aux2 = aux2
        self.aux3 = aux3
        self.aux4 = aux4
    }

    private static func clamp(_ value: UInt16) -> UInt16 {
        min(max(value, 1000), 2000)
    }
}
