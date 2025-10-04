//
// DMUnLoader
//
// Created by Mykola Dementiev
//

import SwiftUI

struct DMHudButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding([.vertical], 1)
            .padding(.horizontal, 1)
            // TODO: deal with Light / Black modes
            .foregroundStyle(.white) // .primary
            .background(
                Capsule()
                    .stroke(.white, lineWidth: 2)
            )
//            .colorInvert()
    }
}

extension ButtonStyle where Self == DMHudButtonStyle {
    static var hudButtonStyle: Self {
        return .init()
    }
}
