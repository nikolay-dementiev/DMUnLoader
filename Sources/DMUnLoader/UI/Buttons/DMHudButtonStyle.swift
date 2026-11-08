//
// DMUnLoader
//
// Created by Mykola Dementiev
//

import SwiftUI

struct DMHudButtonStyle: ButtonStyle {
    /// The colour of the label and of the outline: white, as in every release so far.
    let color: Color

    init(color: Color = .white) {
        self.color = color
    }

    private func getMainColor(_ isPressed: Bool) -> Color {
        isPressed ? color.opacity(0.8) : color
    }
    /// The label in its colour, in the outline of a capsule of that colour, with the press scale of the HUD.
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
            // The whole capsule takes the tap. Without a shape only the title and the outline
            // did, and a tap beside the title landed on the card, which hides a failure.
            .contentShape(Capsule())
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
