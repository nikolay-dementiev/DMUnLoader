//
//  MockDMLoadingManagerSettings.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 13.02.2025.
//

import Foundation
@testable import DMErrorHandling

struct MockDMLoadingManagerSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    
    init(autoHideDelay: Duration = .seconds(0.5)) {
        self.autoHideDelay = autoHideDelay
    }
}
