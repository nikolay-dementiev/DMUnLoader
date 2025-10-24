//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

@testable import DMUnLoader
import SwiftUI

struct MockDMSuccessViewSettings: DMSuccessViewSettings {
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

extension MockDMSuccessViewSettings: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(successImageProperties)
        hasher.combine(successTextProperties)
    }
}
