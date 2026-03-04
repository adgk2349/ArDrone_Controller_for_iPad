import SwiftUI

struct AppRootView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var connectionViewModel: ConnectionViewModel
    @StateObject private var controlViewModel: ControlViewModel
    @StateObject private var telemetryViewModel: TelemetryViewModel

    init(bleManager: BLEManager) {
        _connectionViewModel = StateObject(wrappedValue: ConnectionViewModel(bleManager: bleManager))
        _controlViewModel = StateObject(wrappedValue: ControlViewModel(bleManager: bleManager))
        _telemetryViewModel = StateObject(wrappedValue: TelemetryViewModel(bleManager: bleManager))
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    ConnectionView(viewModel: connectionViewModel)

                    if geometry.size.width >= 980 {
                        HStack(alignment: .top, spacing: 24) {
                            ControlView(viewModel: controlViewModel)
                                .frame(maxWidth: .infinity)

                            TelemetryPanel(viewModel: telemetryViewModel)
                                .frame(width: 320)
                        }
                    } else {
                        ControlView(viewModel: controlViewModel)
                        TelemetryPanel(viewModel: telemetryViewModel)
                    }
                }
                .padding(24)
            }
            .background(AppChrome.appGradient(for: colorScheme).ignoresSafeArea())
        }
        .onAppear {
            connectionViewModel.bootstrap()
        }
    }
}
