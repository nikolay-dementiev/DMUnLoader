//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMVariableBlurView

extension DMHUDBackdropFailure {
    /// The failure that stands for a reason of DMVariableBlurView.
    package init(_ error: DMVariableBlurError) {
        // A placeholder for the commit that maps each reason: every reason is taken for this one.
        self = .effectUnavailable
    }
}
