import Combine
import Foundation

final class ConnectionViewModel: ObservableObject {
    @Published private(set) var connectionState: DroneConnectionState
    @Published private(set) var recommendedDrones: [DiscoveredDrone] = []
    @Published private(set) var nearbyCandidates: [DiscoveredDrone] = []
    @Published private(set) var genericHM10Devices: [DiscoveredDrone] = []

    private let bleManager: BLEManager
    private var cancellables = Set<AnyCancellable>()

    init(bleManager: BLEManager) {
        self.bleManager = bleManager
        self.connectionState = bleManager.connectionState

        bleManager.$connectionState
            .sink { [weak self] state in
                self?.connectionState = state
            }
            .store(in: &cancellables)

        bleManager.$discoveredDrones
            .sink { [weak self] drones in
                self?.recommendedDrones = drones.filter { $0.isRecommended || $0.isKnownDevice }
                self?.nearbyCandidates = drones.filter { !$0.isRecommended && !$0.isKnownDevice && !$0.isGenericModule }
                self?.genericHM10Devices = drones.filter(\.isGenericModule)
            }
            .store(in: &cancellables)
    }

    var actionTitle: String {
        switch connectionState {
        case .scanning:
            return "Stop Scan"
        case .connected, .connecting:
            return "Disconnect"
        case .idle, .failed, .bluetoothUnavailable:
            return "Scan for Drone"
        }
    }

    var canScan: Bool {
        switch connectionState {
        case .bluetoothUnavailable:
            return false
        default:
            return true
        }
    }

    func bootstrap() {
        bleManager.bootstrap()
    }

    func primaryAction() {
        switch connectionState {
        case .scanning:
            bleManager.stopScanning()
        case .connected, .connecting:
            bleManager.disconnect()
        case .idle, .failed, .bluetoothUnavailable:
            bleManager.startScanning()
        }
    }

    func connect(to drone: DiscoveredDrone) {
        bleManager.connect(to: drone.id)
    }
}
