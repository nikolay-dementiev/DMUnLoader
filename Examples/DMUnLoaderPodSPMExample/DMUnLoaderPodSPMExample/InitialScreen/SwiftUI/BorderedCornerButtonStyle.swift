//
//  DMUnLoaderPodSPMExample
//
//  Created by Mykola Dementiev
//

import SwiftUI

struct BorderedCornerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
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

extension ButtonStyle where Self == BorderedCornerButtonStyle {
    static var borderedCorner: Self {
        return .init()
    }
}
