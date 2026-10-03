//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

@testable import DMUnLoader
import SwiftUI

struct StubDMSuccessViewSettings: DMSuccessViewSettings {
    var spacingBetweenElements: CGFloat?
    
    var successImageProperties: SuccessImageProperties = SuccessImageProperties(
        image: Image(systemName: "checkmark.circle.fill"),
        frame: CustomViewSize(width: 50, height: 50),
        foregroundColor: .green
    )
    
    var successTextProperties: SuccessTextProperties = SuccessTextProperties(
        text: "Mock Success!",
        foregroundColor: .white
    )
}

extension StubDMSuccessViewSettings: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.spacingBetweenElements == rhs.spacingBetweenElements
            && lhs.successImageProperties == rhs.successImageProperties
            && lhs.successTextProperties == rhs.successTextProperties
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(spacingBetweenElements)
        hasher.combine(successImageProperties)
        hasher.combine(successTextProperties)
    }
}
