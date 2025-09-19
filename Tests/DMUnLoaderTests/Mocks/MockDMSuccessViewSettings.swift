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
        frame: CustomSizeView(width: 50, height: 50),
        foregroundColor: .green
    )
    
    var successTextProperties: SuccessTextProperties = SuccessTextProperties(
        text: "Mock Success!",
        foregroundColor: .white
    )
}
