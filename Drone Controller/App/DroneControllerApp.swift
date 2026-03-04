import SwiftUI

@main
struct DroneControllerApp: App {
    @StateObject private var bleManager = BLEManager()

    var body: some Scene {
        WindowGroup {
            AppRootView(bleManager: bleManager)
        }
    }
}
