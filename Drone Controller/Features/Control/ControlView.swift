import SwiftUI

struct ControlView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ControlViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Control")
                        .font(.title2.weight(.semibold))
                    Text("HM-10 BLE input is sent as MSP serial RC frames at 50Hz.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label(viewModel.isConnected ? "Live" : "Offline", systemImage: viewModel.isConnected ? "dot.radiowaves.left.and.right" : "bolt.horizontal.circle")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(viewModel.isConnected ? Color.green.opacity(0.18) : Color.gray.opacity(0.18))
                    )
            }

            HStack(alignment: .top, spacing: 16) {
                SteppedSliderView(
                    title: "Left Stick",
                    primaryLabel: "Yaw",
                    primaryValue: $viewModel.yaw,
                    primaryRange: 1000...2000,
                    primaryNeutral: 1500,
                    secondaryLabel: "Throttle",
                    secondaryValue: $viewModel.throttle,
                    secondaryRange: 1000...2000,
                    secondaryNeutral: nil // No snap back for throttle
                )

                JoystickView(
                    title: "Right Stick",
                    primaryLabel: "Roll",
                    primaryValue: $viewModel.roll,
                    primaryRange: 1000...2000,
                    primaryNeutral: 1500,
                    secondaryLabel: "Pitch",
                    secondaryValue: $viewModel.pitch,
                    secondaryRange: 1000...2000,
                    secondaryNeutral: 1500
                )
            }

            auxSection

            ArmControlsView(
                isConnected: viewModel.isConnected,
                armAction: viewModel.arm,
                disarmAction: viewModel.disarm,
                resetAction: viewModel.resetSticks,
                calibrateAction: viewModel.calibrateAccelerometer,
                factoryResetAction: viewModel.factoryReset
            )
        }
        .padding(20)
        .background(AppChrome.panelBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var auxSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aux Channels")
                .font(.headline)

            HStack(spacing: 12) {
                auxPicker(title: "AUX1", selection: $viewModel.aux1)
                auxPicker(title: "AUX2", selection: $viewModel.aux2)
                auxPicker(title: "AUX3", selection: $viewModel.aux3)
                auxPicker(title: "AUX4", selection: $viewModel.aux4)
            }
        }
        .padding(18)
        .background(AppChrome.cardBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func auxPicker(title: String, selection: Binding<AuxChannelLevel>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))

            Picker(title, selection: selection) {
                ForEach(AuxChannelLevel.allCases) { level in
                    Text(level.title).tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
