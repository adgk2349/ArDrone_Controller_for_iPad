import Combine
import Foundation

final class ControlViewModel: ObservableObject {
    @Published var roll: Double = 1500
    @Published var pitch: Double = 1500
    @Published var yaw: Double = 1500
    @Published var throttle: Double = 1000

    @Published var aux1: AuxChannelLevel = .low
    @Published var aux2: AuxChannelLevel = .low
    @Published var aux3: AuxChannelLevel = .low
    @Published var aux4: AuxChannelLevel = .low

    @Published private(set) var isConnected = false

    private let bleManager: BLEManager
    private var cancellables = Set<AnyCancellable>()
    private var controlLoop: AnyCancellable?
    private var telemetryLoop: AnyCancellable?
    private var telemetryPollStep = 0

    init(bleManager: BLEManager) {
        self.bleManager = bleManager

        bleManager.$connectionState
            .map(\.isConnected)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                if !isConnected {
                    self?.resetSticks()
                } else {
                    self?.resetSticks()
                }
            }
            .store(in: &cancellables)

        controlLoop = Timer.publish(every: 0.02, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                bleManager.sendControl(self.currentFrame)
            }

        telemetryLoop = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isConnected else { return }

                switch telemetryPollStep {
                case 0:
                    bleManager.requestAirStatus()
                case 1:
                    bleManager.requestRCStatus()
                case 2:
                    bleManager.requestMotorStatus()
                default:
                    bleManager.requestStatus()
                }

                telemetryPollStep = (telemetryPollStep + 1) % 4
            }
    }

    func arm() {
        bleManager.sendArm()
    }

    func disarm() {
        bleManager.sendDisarm()
    }

    func calibrateAccelerometer() {
        bleManager.triggerAccCalibration()
    }

    func factoryReset() {
        bleManager.triggerFactoryReset()
    }

    func resetSticks() {
        roll = 1500
        pitch = 1500
        yaw = 1500
        throttle = 1000
    }

    var currentFrame: RCFrame {
        RCFrame(
            roll: UInt16(roll.rounded()),
            pitch: UInt16(pitch.rounded()),
            yaw: UInt16(yaw.rounded()),
            throttle: UInt16(throttle.rounded()),
            aux1: aux1,
            aux2: aux2,
            aux3: aux3,
            aux4: aux4
        )
    }
}
