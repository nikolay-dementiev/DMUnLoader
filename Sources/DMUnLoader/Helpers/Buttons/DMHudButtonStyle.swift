//
// DMUnLoader
//
// Created by Mykola Dementiev
//

import SwiftUI

struct DMHudButtonStyle: ButtonStyle {
    private func getMainColor(_ isPressed: Bool) -> Color {
        isPressed ? .white.opacity(0.8) : .white
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 1)
            .padding(.horizontal, 1)
            // TODO: deal with Light / Black modes
            .foregroundStyle(getMainColor(configuration.isPressed)) // .primary
            .background(
                Capsule()
                    .stroke(
                        getMainColor(configuration.isPressed),
                        lineWidth: 2
                    )
            )
            .modifier(HUDPressScale(isPressed: configuration.isPressed))
//            .colorInvert()
    }
}

/// Shrinks a pressed HUD button a little, unless Reduce Motion is on.
///
/// A modifier, not a property of the style: `AnyButtonStyle` calls the style's `makeBody`
/// itself, so SwiftUI would set no environment property of the style.
package struct HUDPressScale: ViewModifier {
    @Environment(\.hudReducesMotion) private var reducesMotion
    /// Whether the button is pressed.
    package let isPressed: Bool

    package init(isPressed: Bool) {
        self.isPressed = isPressed
    }

    package func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed && !reducesMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.05), value: isPressed)
    }
}

extension ButtonStyle where Self == DMHudButtonStyle {
    static var hudButtonStyle: Self {
        return .init()
    }
}
