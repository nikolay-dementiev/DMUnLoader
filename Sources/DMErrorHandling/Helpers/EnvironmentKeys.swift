//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

// GlobalLoadingManagerKey

internal struct GlobalLoadingManagerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: GlobalLoadingStateManager? = nil
}

internal extension EnvironmentValues {
    var globalLoadingManager: GlobalLoadingStateManager? {
        get { self[GlobalLoadingManagerKey.self] }
        set { self[GlobalLoadingManagerKey.self] = newValue }
    }
}
