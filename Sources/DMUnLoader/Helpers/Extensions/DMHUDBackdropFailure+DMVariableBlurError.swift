//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMVariableBlurView

extension DMHUDBackdropFailure {
    /// The failure that stands for a reason of DMVariableBlurView.
    ///
    /// The switch has no `default`: a reason that a new major version of DMVariableBlurView adds
    /// stops the build here instead of being taken for another.
    package init(_ error: DMVariableBlurError) {
        switch error {
        case .effectUnavailable:
            self = .effectUnavailable
        case .maskCreationFailed:
            self = .maskCreationFailed
        case .invalidMaxBlurRadius, .invalidCenterBandProportion, .invalidStartOffset:
            self = .invalidConfiguration
        }
    }
}
