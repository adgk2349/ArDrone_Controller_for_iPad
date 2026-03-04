import Foundation

enum MSPCommand: UInt8 {
    case status = 101
    case motor = 104
    case rc = 105
    case setRawRCSerial = 150
    case arm = 151
    case disarm = 152
    case air = 199
    case accCalibration = 205
    case resetConf = 208
}
