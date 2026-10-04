//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// How long the tests wait for work that runs later, on a queue or a run loop.
enum TestTiming {
    /// How late a scheduled callback may run on a busy machine before a test gives up.
    /// A test that is green returns as soon as its expectation is fulfilled, so the value
    /// costs nothing when nothing is late.
    static let callbackAllowance: Double = 3
}
