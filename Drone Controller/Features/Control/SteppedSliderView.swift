import SwiftUI

struct SteppedSliderView: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let primaryLabel: String
    @Binding var primaryValue: Double
    let primaryRange: ClosedRange<Double>
    let primaryNeutral: Double?
    let secondaryLabel: String
    @Binding var secondaryValue: Double
    let secondaryRange: ClosedRange<Double>
    let secondaryNeutral: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            sliderSection(
                label: primaryLabel,
                value: $primaryValue,
                range: primaryRange,
                neutral: primaryNeutral,
                stepped: false
            )
            
            Spacer(minLength: 16)

            sliderSection(
                label: secondaryLabel,
                value: $secondaryValue,
                range: secondaryRange,
                neutral: secondaryNeutral,
                stepped: true
            )
            
            Spacer(minLength: 0)
        }
        .frame(height: 250, alignment: .top) // Match approximate total height of JoystickView
        .padding(18)
        .background(AppChrome.cardBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func sliderSection(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        neutral: Double?,
        stepped: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                Spacer()
                Text("\(Int(value.wrappedValue.rounded()))")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)
            }

            if stepped {
                // Throttle stepped slider
                let stepSize = (range.upperBound - range.lowerBound) / 10
                Slider(value: value, in: range, step: stepSize) {
                    EmptyView()
                } minimumValueLabel: {
                    Text("\(Int(range.lowerBound))").font(.caption2).foregroundStyle(.secondary)
                } maximumValueLabel: {
                    Text("\(Int(range.upperBound))").font(.caption2).foregroundStyle(.secondary)
                }
            } else {
                Slider(value: value, in: range, step: 1)
            }

            if let neutral {
                Button("Center \(label)") {
                    withAnimation {
                        value.wrappedValue = neutral
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
