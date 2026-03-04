import SwiftUI

enum AppChrome {
    static func appGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.12),
                    Color(red: 0.09, green: 0.12, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.97, blue: 0.99),
                Color(red: 0.89, green: 0.93, blue: 0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func panelBackground(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return Color(red: 0.10, green: 0.13, blue: 0.18).opacity(0.95)
        }

        return Color.white.opacity(0.84)
    }

    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return Color(red: 0.15, green: 0.18, blue: 0.23).opacity(0.98)
        }

        return Color.white.opacity(0.88)
    }
}
