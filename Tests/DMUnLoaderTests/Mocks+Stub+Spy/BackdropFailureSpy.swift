//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

/// Records what the handler of a host receives when the backdrop of the HUD loses its blur.
@MainActor
final class BackdropFailureSpy {
    private(set) var received: [DMHUDBackdropFailure] = []

    func record(_ failure: DMHUDBackdropFailure) {
        received.append(failure)
    }
}
