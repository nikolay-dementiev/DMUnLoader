//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation
@testable import DMErrorHandling

struct MockDMLoadingManagerSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    
    init(autoHideDelay: Duration = .seconds(0.5)) {
        self.autoHideDelay = autoHideDelay
    }
}
