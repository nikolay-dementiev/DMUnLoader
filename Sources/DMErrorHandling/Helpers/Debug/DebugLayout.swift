//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

/*
 
 Uncomment it only when needed!
 
import SwiftUI

internal struct DebugLayout: Layout {
    let name: String
    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout ()) -> CGSize {
        
        let result = subviews[0].sizeThatFits(proposal)
        print(name, proposal, result)
        
        return result
    }
    
    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout ()) {
        
        subviews[0].place(at: bounds.origin,
                          proposal: proposal)
    }
}

internal extension View {
    func debugLog(_ name: String) -> some View {
        DebugLayout(name: name) { self }
    }
    
    /*
    func debugType() -> Self {
        let type = Mirror(reflecting: self).subjectType
        print(type)
        return self
    }
     */
    
    func printOutput(_ value: Any) -> Self {
        print(value)
        return self
    }
    
    func debugAction(_ closure: () -> Void) -> Self {
#if DEBUG
        closure()
#endif
        return self
    }
    
    func printChanges() -> Self {
#if DEBUG
        // swiftlint:disable:next redundant_discardable_let
        let _ = Self._printChanges()
#endif
        return self
    }
}
*/
