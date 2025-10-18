//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest

final class FulfillmentTestExpectationSpy: XCTestExpectation, @unchecked Sendable {
    private(set) var currentFulfillmentCount: Int = 0
    
    var isFulfilled: Bool {
        currentFulfillmentCount > 0
    }
    
    override func fulfill() {
        currentFulfillmentCount += 1
        super.fulfill()
    }
}
