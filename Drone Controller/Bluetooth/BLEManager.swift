import Combine
import CoreBluetooth
import Foundation

final class BLEManager: NSObject, ObservableObject {
    @Published private(set) var connectionState: DroneConnectionState = .idle
    @Published private(set) var discoveredDrones: [DiscoveredDrone] = []
    @Published private(set) var latestTelemetry: DroneTelemetry = .placeholder

    private let centralManager: CBCentralManager
    private let decoder = MSPDecoder()
    private let reconnectStorageKey = "lastConnectedDroneID"
    private let preferredNameTokens = ["aircopter"]
    private let genericModuleTokens = ["hm-10", "hm10", "hm soft", "hmsoft", "bt05", "cc41", "at-09", "mlt-bt05"]

    private var peripheralsByID: [UUID: CBPeripheral] = [:]
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?
    private var pendingReconnectID: UUID?
    private var shouldAttemptReconnect = false

    override init() {
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        self.centralManager.delegate = self
    }

    func bootstrap() {
        shouldAttemptReconnect = true
        attemptReconnectIfPossible()
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            connectionState = .bluetoothUnavailable(reason(for: centralManager.state))
            return
        }

        peripheralsByID.removeAll()
        discoveredDrones.removeAll()

        if !centralManager.isScanning {
            centralManager.scanForPeripherals(withServices: HM10Peripheral.serviceUUIDs, options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: false
            ])
        }

        connectionState = .scanning
    }

    func stopScanning() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }

        if !connectionState.isConnected {
            connectionState = .idle
        }
    }

    func connect(to id: UUID) {
        guard let peripheral = peripheralsByID[id] else {
            connectionState = .failed("Selected drone is no longer available.")
            return
        }

        stopScanning()
        writeCharacteristic = nil
        notifyCharacteristic = nil
        connectedPeripheral = peripheral
        peripheral.delegate = self
        connectionState = .connecting(displayName(for: peripheral))
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        stopScanning()

        guard let connectedPeripheral else {
            connectionState = .idle
            return
        }

        centralManager.cancelPeripheralConnection(connectedPeripheral)
    }

    func sendControl(_ frame: RCFrame) {
        send(MSPEncoder.controlPacket(frame))
    }

    func sendArm() {
        send(MSPEncoder.armPacket())
    }

    func sendDisarm() {
        send(MSPEncoder.disarmPacket())
    }

    func requestAirStatus() {
        send(MSPEncoder.airStatusRequestPacket())
    }

    func requestRCStatus() {
        send(MSPEncoder.rcStatusRequestPacket())
    }

    func requestMotorStatus() {
        send(MSPEncoder.motorStatusRequestPacket())
    }

    func requestStatus() {
        send(MSPEncoder.statusRequestPacket())
    }

    func triggerAccCalibration() {
        send(MSPEncoder.accCalibrationPacket())
    }

    func triggerFactoryReset() {
        send(MSPEncoder.resetConfPacket())
    }

    private func send(_ data: Data) {
        guard let peripheral = connectedPeripheral else { return }
        guard let characteristic = writeCharacteristic ?? notifyCharacteristic else { return }

        let writeType: CBCharacteristicWriteType =
            characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse

        guard characteristic.properties.contains(.writeWithoutResponse) || characteristic.properties.contains(.write) else {
            return
        }

        peripheral.writeValue(data, for: characteristic, type: writeType)
    }

    private func attemptReconnectIfPossible() {
        guard shouldAttemptReconnect else { return }
        guard !connectionState.isConnected else { return }
        guard centralManager.state == .poweredOn else { return }
        guard let reconnectID = loadLastPeripheralID() else { return }

        let knownPeripherals = centralManager.retrievePeripherals(withIdentifiers: [reconnectID])
        if let peripheral = knownPeripherals.first {
            pendingReconnectID = nil
            peripheralsByID[peripheral.identifier] = peripheral
            connect(to: peripheral.identifier)
            return
        }

        pendingReconnectID = reconnectID
        startScanning()
    }

    private func loadLastPeripheralID() -> UUID? {
        guard let rawValue = UserDefaults.standard.string(forKey: reconnectStorageKey) else {
            return nil
        }

        return UUID(uuidString: rawValue)
    }

    private func saveLastPeripheralID(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: reconnectStorageKey)
    }

    private func clearConnectionArtifacts() {
        writeCharacteristic = nil
        notifyCharacteristic = nil
        connectedPeripheral = nil
        latestTelemetry = .placeholder
    }

    private func displayName(for peripheral: CBPeripheral, advertisementData: [String: Any] = [:]) -> String {
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let trimmedName = (advertisedName ?? peripheral.name ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            return "HM-10 Drone"
        }
        return trimmedName
    }

    private func remember(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        peripheralsByID[peripheral.identifier] = peripheral

        guard let drone = discoveredDrone(for: peripheral, advertisementData: advertisementData, rssi: rssi) else {
            return
        }

        if let existingIndex = discoveredDrones.firstIndex(where: { $0.id == drone.id }) {
            discoveredDrones[existingIndex] = drone
        } else {
            discoveredDrones.append(drone)
        }

        discoveredDrones.sort(by: sortDiscoveredDrones)
    }

    private func discoveredDrone(for peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) -> DiscoveredDrone? {
        let name = displayName(for: peripheral, advertisementData: advertisementData)
        let normalizedName = name.lowercased()
        let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []

        let isRecommended = preferredNameTokens.contains { normalizedName.contains($0) }
        let isGenericModule = genericModuleTokens.contains { normalizedName.contains($0) }
        let isKnownDevice = loadLastPeripheralID() == peripheral.identifier
        let hasHM10Service = serviceUUIDs.contains(where: { HM10Peripheral.serviceUUIDs.contains($0) })
        let isReconnectTarget = pendingReconnectID == peripheral.identifier
        let isSupportedDevice = isRecommended || isGenericModule || hasHM10Service || isReconnectTarget || isKnownDevice

        guard isSupportedDevice else {
            return nil
        }

        return DiscoveredDrone(
            id: peripheral.identifier,
            name: name,
            rssi: rssi.intValue,
            isRecommended: isRecommended,
            isGenericModule: isGenericModule,
            isKnownDevice: isKnownDevice
        )
    }

    private func sortDiscoveredDrones(_ lhs: DiscoveredDrone, _ rhs: DiscoveredDrone) -> Bool {
        if lhs.isRecommended != rhs.isRecommended {
            return lhs.isRecommended && !rhs.isRecommended
        }

        if lhs.isKnownDevice != rhs.isKnownDevice {
            return lhs.isKnownDevice && !rhs.isKnownDevice
        }

        if lhs.isGenericModule != rhs.isGenericModule {
            return !lhs.isGenericModule && rhs.isGenericModule
        }

        if lhs.rssi != rhs.rssi {
            return lhs.rssi > rhs.rssi
        }

        return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }

    private func reason(for state: CBManagerState) -> String {
        switch state {
        case .poweredOn:
            return "Bluetooth is ready."
        case .unsupported:
            return "This iPad does not support Bluetooth Low Energy."
        case .unauthorized:
            return "Bluetooth permission is not granted."
        case .poweredOff:
            return "Bluetooth is turned off."
        case .resetting:
            return "Bluetooth is resetting."
        case .unknown:
            return "Bluetooth state is not available yet."
        @unknown default:
            return "Bluetooth is unavailable."
        }
    }

    private func parseUInt16Array(payload: Data, count: Int) -> [Int]? {
        guard payload.count >= count * 2 else { return nil }

        return (0..<count).compactMap { index in
            payload.uint16LE(at: index * 2).map(Int.init)
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            discoveredDrones.removeAll()
            peripheralsByID.removeAll()
            clearConnectionArtifacts()
            connectionState = .bluetoothUnavailable(reason(for: central.state))
            return
        }

        if !connectionState.isConnected {
            connectionState = .idle
        }

        attemptReconnectIfPossible()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        remember(peripheral, advertisementData: advertisementData, rssi: RSSI)

        if let pendingReconnectID, pendingReconnectID == peripheral.identifier {
            self.pendingReconnectID = nil
            connect(to: peripheral.identifier)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        saveLastPeripheralID(peripheral.identifier)
        connectionState = .connecting(displayName(for: peripheral))
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        clearConnectionArtifacts()
        connectionState = .failed(error?.localizedDescription ?? "Failed to connect to the drone.")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        clearConnectionArtifacts()

        if let error {
            connectionState = .failed(error.localizedDescription)
        } else {
            connectionState = .idle
        }
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            connectionState = .failed(error?.localizedDescription ?? "Failed to discover services.")
            return
        }

        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            connectionState = .failed(error?.localizedDescription ?? "Failed to discover characteristics.")
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            let supportsWrite = characteristic.properties.contains(.writeWithoutResponse) || characteristic.properties.contains(.write)
            let supportsNotify = characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate)

            if HM10Peripheral.isDataCharacteristic(characteristic.uuid) || supportsWrite {
                if supportsWrite {
                    writeCharacteristic = characteristic
                }

                if supportsNotify || characteristic.properties.contains(.read) {
                    notifyCharacteristic = characteristic
                }
            }

            if supportsNotify {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }

        if writeCharacteristic != nil || notifyCharacteristic != nil {
            connectionState = .connected(displayName(for: peripheral))
            requestAirStatus()
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else { return }
        guard let value = characteristic.value else { return }

        let packets = decoder.append(value)
        for packet in packets {
            switch packet.command {
            case MSPCommand.air.rawValue:
                guard let airStatus = MSPAirStatus(payload: packet.payload) else { continue }
                var telemetry = latestTelemetry
                telemetry.firmwareVersion = airStatus.telemetry.firmwareVersion
                telemetry.altitudeCM = airStatus.telemetry.altitudeCM
                telemetry.targetAltitudeCM = airStatus.telemetry.targetAltitudeCM
                telemetry.rollDegrees = airStatus.telemetry.rollDegrees
                telemetry.pitchDegrees = airStatus.telemetry.pitchDegrees
                telemetry.batteryVoltage = airStatus.telemetry.batteryVoltage
                telemetry.trimPitch = airStatus.telemetry.trimPitch
                telemetry.trimRoll = airStatus.telemetry.trimRoll
                latestTelemetry = telemetry
            case MSPCommand.status.rawValue:
                guard packet.payload.count >= 11 else { continue }
                guard let flags = packet.payload.uint32LE(at: 6) else { continue }
                var telemetry = latestTelemetry
                telemetry.isArmed = (flags & 1) != 0
                latestTelemetry = telemetry
            case MSPCommand.rc.rawValue:
                guard let channels = parseUInt16Array(payload: packet.payload, count: 8) else { continue }
                var telemetry = latestTelemetry
                telemetry.rcChannels = channels
                latestTelemetry = telemetry
            case MSPCommand.motor.rawValue:
                guard let motors = parseUInt16Array(payload: packet.payload, count: 8) else { continue }
                var telemetry = latestTelemetry
                telemetry.motorOutputs = motors
                latestTelemetry = telemetry
            default:
                continue
            }
        }
    }
}
