import SwiftUI

struct TelemetryPanel: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: TelemetryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Telemetry")
                .font(.title2.weight(.semibold))

            metricCard("Flight", value: viewModel.telemetry.isArmed ? "Armed" : "Disarmed")
            metricCard("Battery", value: formattedBattery)
            metricCard("Altitude", value: "\(viewModel.telemetry.altitudeCM) cm")
            metricCard("Target Alt", value: "\(viewModel.telemetry.targetAltitudeCM) cm")
            metricCard("Roll", value: String(format: "%.1f°", viewModel.telemetry.rollDegrees))
            metricCard("Pitch", value: String(format: "%.1f°", viewModel.telemetry.pitchDegrees))
            metricCard("Pitch Trim", value: "\(viewModel.telemetry.trimPitch)")
            metricCard("Roll Trim", value: "\(viewModel.telemetry.trimRoll)")
            metricCard("Firmware", value: viewModel.telemetry.firmwareVersion.map(String.init) ?? "Unknown")
            
            if viewModel.telemetry.rcChannels.count >= 4 {
                metricCard("RC [R,P,Y,T]", value: "\(viewModel.telemetry.rcChannels[0]), \(viewModel.telemetry.rcChannels[1]), \(viewModel.telemetry.rcChannels[2]), \(viewModel.telemetry.rcChannels[3])")
            }
            if viewModel.telemetry.motorOutputs.count >= 4 {
                metricCard("Motors [0-3]", value: "\(viewModel.telemetry.motorOutputs[0]), \(viewModel.telemetry.motorOutputs[1]), \(viewModel.telemetry.motorOutputs[2]), \(viewModel.telemetry.motorOutputs[3])")
            }

            Text(viewModel.connectionState.detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(AppChrome.panelBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var formattedBattery: String {
        guard let batteryVoltage = viewModel.telemetry.batteryVoltage else {
            return "Unknown"
        }

        return String(format: "%.1f V", batteryVoltage)
    }

    private func metricCard(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppChrome.cardBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
