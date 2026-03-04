import SwiftUI

struct ConnectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ConnectionViewModel
    @State private var showsGenericDevices = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Connection")
                        .font(.title2.weight(.semibold))
                    Text(viewModel.connectionState.title)
                        .font(.headline)
                    Text(viewModel.connectionState.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(viewModel.actionTitle) {
                    viewModel.primaryAction()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canScan)
            }

            if hasAnyDiscoveredDevice {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nearby Drones")
                        .font(.headline)

                    if !viewModel.recommendedDrones.isEmpty {
                        sectionTitle("Recommended")
                        ForEach(viewModel.recommendedDrones) { drone in
                            droneButton(for: drone, accentColor: .blue)
                        }
                    }

                    if viewModel.recommendedDrones.isEmpty && !viewModel.nearbyCandidates.isEmpty {
                        sectionTitle("Other Named Devices")
                        ForEach(viewModel.nearbyCandidates) { drone in
                            droneButton(for: drone, accentColor: Color(red: 0.1, green: 0.43, blue: 0.74))
                        }
                    }

                    if !viewModel.genericHM10Devices.isEmpty {
                        Button(showsGenericDevices ? "Hide Generic HM-10 Modules" : "Show Generic HM-10 Modules (\(viewModel.genericHM10Devices.count))") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showsGenericDevices.toggle()
                            }
                        }
                        .buttonStyle(.bordered)

                        if showsGenericDevices {
                            Text("These are generic BLE UART modules nearby. Use them only if your drone was not renamed to AirCopter.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            ForEach(viewModel.genericHM10Devices) { drone in
                                droneButton(for: drone, accentColor: .gray)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(AppChrome.panelBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var hasAnyDiscoveredDevice: Bool {
        !viewModel.recommendedDrones.isEmpty ||
        !viewModel.nearbyCandidates.isEmpty ||
        !viewModel.genericHM10Devices.isEmpty
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 4)
    }

    private func droneButton(for drone: DiscoveredDrone, accentColor: Color) -> some View {
        Button {
            viewModel.connect(to: drone)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: drone.isRecommended ? "dot.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right")
                    .foregroundStyle(accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(drone.name)
                        .foregroundStyle(.primary)

                    Text("\(drone.signalSummary) signal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(drone.id.uuidString.prefix(4))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppChrome.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
