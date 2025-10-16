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
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.05), value: configuration.isPressed)
//            .colorInvert()
    }
}

extension ButtonStyle where Self == DMHudButtonStyle {
    static var hudButtonStyle: Self {
        return .init()
    }
}
