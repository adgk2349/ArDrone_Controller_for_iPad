import SwiftUI

struct JoystickView: View {
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
    
    // Joystick Configuration
    private let thumbSize: CGFloat = 60
    private let padSize: CGFloat = 140
    
    @State private var thumbPosition: CGPoint = .zero
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(primaryLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(primaryValue.rounded()))")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                
                VStack(alignment: .leading) {
                    Text(secondaryLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(secondaryValue.rounded()))")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity)
            
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = padSize / 2
                
                ZStack {
                    // Background Pad
                    Circle()
                        .fill(AppChrome.panelBackground(for: colorScheme))
                        .frame(width: padSize, height: padSize)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    
                    // Throttle Ticks (only for secondary axis if it doesn't return to neutral)
                    if secondaryNeutral == nil {
                        VStack(spacing: 0) {
                            ForEach(0..<11) { i in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: i == 5 ? 20 : 10, height: 2)
                                if i < 10 {
                                    Spacer()
                                }
                            }
                        }
                        .frame(height: padSize)
                    }
                    
                    // Crosshair
                    Path { path in
                        path.move(to: CGPoint(x: center.x, y: center.y - radius))
                        path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
                        path.move(to: CGPoint(x: center.x - radius, y: center.y))
                        path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    
                    // Thumb
                    Circle()
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .position(
                            x: center.x + thumbPosition.x,
                            y: center.y + thumbPosition.y
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updatePosition(translation: CGSize(
                                        width: dragOffset.width + value.translation.width,
                                        height: dragOffset.height + value.translation.height
                                    ), padRadius: radius)
                                }
                                .onEnded { _ in
                                    handleRelease(padRadius: radius)
                                }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: padSize + 20, height: padSize + 20)
            .frame(maxWidth: .infinity)
            
            Spacer(minLength: 0)
        }
        .frame(height: 250, alignment: .top)
        .padding(18)
        .background(AppChrome.cardBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onAppear {
            setupInitialPosition()
        }
    }
    
    private func setupInitialPosition() {
        let radius = padSize / 2
        
        let xSpan = primaryRange.upperBound - primaryRange.lowerBound
        let xPercent = CGFloat((primaryValue - primaryRange.lowerBound) / xSpan)
        let endX = (2 * xPercent - 1) * radius
        
        let ySpan = secondaryRange.upperBound - secondaryRange.lowerBound
        let yPercent = CGFloat((secondaryValue - secondaryRange.lowerBound) / ySpan)
        // Y is inverted (top is high, bottom is low)
        let endY = -(2 * yPercent - 1) * radius
        
        thumbPosition = CGPoint(x: endX, y: endY)
        dragOffset = CGSize(width: endX, height: endY)
    }
    
    private func updatePosition(translation: CGSize, padRadius: CGFloat) {
        var newX = translation.width
        var newY = translation.height
        
        // Clamp to a square boundary first, then to circle if needed. For simplicity, we just clamp axes independently.
        newX = max(-padRadius, min(padRadius, newX))
        newY = max(-padRadius, min(padRadius, newY))
        
        // If it's a throttle (secondaryNeutral == nil), we apply stepping.
        if secondaryNeutral == nil {
            let totalSteps: CGFloat = 10
            let stepSize = (padRadius * 2) / totalSteps
            
            // Map newY from [-padRadius, padRadius] into roughly steps
            let normalizedY = newY + padRadius // 0 to 2*padRadius
            let steppedY = round(normalizedY / stepSize) * stepSize
            newY = steppedY - padRadius
        }
        
        thumbPosition = CGPoint(x: newX, y: newY)
        
        // Update Bindings
        let xPercent = (newX / padRadius + 1) / 2
        let yPercent = (-newY / padRadius + 1) / 2 // Invert Y
        
        let xSpan = primaryRange.upperBound - primaryRange.lowerBound
        let ySpan = secondaryRange.upperBound - secondaryRange.lowerBound
        
        primaryValue = primaryRange.lowerBound + Double(xPercent) * xSpan
        secondaryValue = secondaryRange.lowerBound + Double(yPercent) * ySpan
    }
    
    private func handleRelease(padRadius: CGFloat) {
        var endX = thumbPosition.x
        var endY = thumbPosition.y
        
        if let neutralX = primaryNeutral {
            let xSpan = primaryRange.upperBound - primaryRange.lowerBound
            let xPercent = CGFloat((neutralX - primaryRange.lowerBound) / xSpan)
            endX = (2 * xPercent - 1) * padRadius
            primaryValue = neutralX
        }
        
        if let neutralY = secondaryNeutral {
            let ySpan = secondaryRange.upperBound - secondaryRange.lowerBound
            let yPercent = CGFloat((neutralY - secondaryRange.lowerBound) / ySpan)
            endY = -(2 * yPercent - 1) * padRadius
            secondaryValue = neutralY
        }
        
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6)) {
            thumbPosition = CGPoint(x: endX, y: endY)
        }
        
        dragOffset = CGSize(width: endX, height: endY)
    }
}
