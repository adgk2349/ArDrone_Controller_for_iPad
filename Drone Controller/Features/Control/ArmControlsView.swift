import SwiftUI

struct ArmControlsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let isConnected: Bool
    let armAction: () -> Void
    let disarmAction: () -> Void
    let resetAction: () -> Void
    let calibrateAction: () -> Void
    let factoryResetAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                Button("Arm", action: armAction)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                Button("Disarm", action: disarmAction)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                Button("Reset Sticks", action: resetAction)
                    .buttonStyle(.bordered)
                
                Button("Calibrate ACC", action: calibrateAction)
                    .buttonStyle(.bordered)
                
                Button("Factory Reset", action: factoryResetAction)
                    .buttonStyle(.bordered)
                    .tint(.orange)
            }

            Text(isConnected ? "Live RC stream is active." : "Connect first to start sending RC packets.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(AppChrome.cardBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
