import Foundation

struct MSPAirStatus: Equatable {
    let flightState: UInt8
    let firmwareVersion: Int
    let altitudeCM: Int
    let rollTenths: Int
    let pitchTenths: Int
    let targetAltitudeCM: Int
    let batteryTenths: Int
    let trimPitch: Int
    let trimRoll: Int

    init?(payload: Data) {
        guard payload.count >= 14 else { return nil }
        guard
            let firmwareVersion = payload.uint16LE(at: 1),
            let altitude = payload.int16LE(at: 3),
            let roll = payload.int16LE(at: 5),
            let pitch = payload.int16LE(at: 7),
            let targetAltitude = payload.int16LE(at: 9)
        else {
            return nil
        }

        self.flightState = payload[0]
        self.firmwareVersion = Int(firmwareVersion)
        self.altitudeCM = Int(altitude)
        self.rollTenths = Int(roll)
        self.pitchTenths = Int(pitch)
        self.targetAltitudeCM = Int(targetAltitude)
        self.batteryTenths = Int(payload[11])
        self.trimPitch = Int(Int8(bitPattern: payload[12]))
        self.trimRoll = Int(Int8(bitPattern: payload[13]))
    }

    var telemetry: DroneTelemetry {
        DroneTelemetry(
            firmwareVersion: firmwareVersion,
            altitudeCM: altitudeCM,
            targetAltitudeCM: targetAltitudeCM,
            rollDegrees: Double(rollTenths) / 10.0,
            pitchDegrees: Double(pitchTenths) / 10.0,
            batteryVoltage: Double(batteryTenths) / 10.0,
            trimPitch: trimPitch,
            trimRoll: trimRoll,
            isArmed: false,
            rcChannels: [],
            motorOutputs: []
        )
    }
}
