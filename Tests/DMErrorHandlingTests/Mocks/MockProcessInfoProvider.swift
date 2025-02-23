//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

@testable import DMErrorHandling

internal struct MockProcessInfoProvider: ProcessInfoProvider {
    var arguments: [String]
}
