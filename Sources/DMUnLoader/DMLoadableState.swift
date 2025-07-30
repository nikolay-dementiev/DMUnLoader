//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

public enum DMLoadableState: Sendable {
    case idle
    case loading
    case success
    case error(Error)
}
