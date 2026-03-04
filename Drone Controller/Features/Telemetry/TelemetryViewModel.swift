import Combine
import Foundation

final class TelemetryViewModel: ObservableObject {
    @Published private(set) var telemetry: DroneTelemetry
    @Published private(set) var connectionState: DroneConnectionState

    private var cancellables = Set<AnyCancellable>()

    init(bleManager: BLEManager) {
        self.telemetry = bleManager.latestTelemetry
        self.connectionState = bleManager.connectionState

        bleManager.$latestTelemetry
            .sink { [weak self] telemetry in
                self?.telemetry = telemetry
            }
            .store(in: &cancellables)

        bleManager.$connectionState
            .sink { [weak self] state in
                self?.connectionState = state
            }
            .store(in: &cancellables)
    }
}
