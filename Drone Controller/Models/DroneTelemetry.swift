import Foundation

struct DroneTelemetry: Equatable {
    var firmwareVersion: Int?
    var altitudeCM: Int
    var targetAltitudeCM: Int
    var rollDegrees: Double
    var pitchDegrees: Double
    var batteryVoltage: Double?
    var trimPitch: Int
    var trimRoll: Int
    var isArmed: Bool
    var rcChannels: [Int]
    var motorOutputs: [Int]

    static let placeholder = DroneTelemetry(
        firmwareVersion: nil,
        altitudeCM: 0,
        targetAltitudeCM: 0,
        rollDegrees: 0,
        pitchDegrees: 0,
        batteryVoltage: nil,
        trimPitch: 0,
        trimRoll: 0,
        isArmed: false,
        rcChannels: Array(repeating: 0, count: 8),
        motorOutputs: Array(repeating: 0, count: 8)
    )
}
