//
//  DMLoadingManagerSettings.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 13.02.2025.
//

public protocol DMLoadingManagerSettings {
    var autoHideDelay: Duration { get }
}

internal struct DMLoadingManagerDefaultSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    
    internal init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}
