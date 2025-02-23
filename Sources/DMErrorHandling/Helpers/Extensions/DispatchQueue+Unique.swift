//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//
// for more detail, please visit: https://stackoverflow.com/a/39983813/6643923

import Foundation

internal extension DispatchQueue {
    nonisolated(unsafe) private static var _onceTracker = [String]()
    
    static func resetTrackersSet() {
        _onceTracker.removeAll()
    }
    
    class func once(forObject object: AnyObject? = nil,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    position: ObjectPosition = .current,
                    block: () -> Void) {
        
        let objectsToProvide: [AnyObject]?
        if let object {
            objectsToProvide = [object]
        } else {
            objectsToProvide = nil
        }
        
        once(forObjects: objectsToProvide,
             file: file,
             function: function,
             line: line,
             position: position,
             block: block)
    }
    
    class func once(forObjects objects: [AnyObject]?,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    position: ObjectPosition = .current,
                    block: () -> Void) {
        let objectsTokenString: String = (
            objects?
                .map({ String.pointer($0) })
                .joined(separator: ";")
        ).getValueOrNullSting()
        
        let token: String
        switch position {
        case .any:
            token = "\(objectsTokenString)"
        case .current:
            token = "\(objectsTokenString)\(file):\(function):\(line)"
        }
       
        once(token: token, block: block)
    }
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String,
                    block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard !_onceTracker.contains(token) else {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
    
    enum ObjectPosition {
        case current, any
    }
}
