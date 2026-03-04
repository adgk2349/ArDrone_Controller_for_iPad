import CoreBluetooth

enum HM10Peripheral {
    static let serviceUUIDs = [
        CBUUID(string: "FFE0")
    ]

    static let dataCharacteristicUUIDs = [
        CBUUID(string: "FFE1")
    ]

    static func isDataCharacteristic(_ uuid: CBUUID) -> Bool {
        dataCharacteristicUUIDs.contains(uuid)
    }
}
