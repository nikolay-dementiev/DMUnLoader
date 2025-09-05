//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit

final class MockUIView: UIView {
    var updateCalled = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCalled = true
    }
}
