//
// DMUnLoaderPodSPMExample
//
//  Created by Mykola Dementiev
//

import SwiftUI

public struct DMBorderedCornerButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding([.vertical], 1)
            .padding(.horizontal, 1)
            .foregroundStyle(.tint)
            .background(
                Capsule()
                    .stroke(.tint, lineWidth: 2)
            )
    }
}

public extension ButtonStyle where Self == DMBorderedCornerButtonStyle {
    static var dmBorderedCorner: Self {
        return .init()
    }
}
