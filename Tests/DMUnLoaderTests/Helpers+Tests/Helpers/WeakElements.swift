//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Foundation
@testable import DMUnLoader

internal struct WeakObject<Object: AnyObject> {
    weak var object: Object?
}

@propertyWrapper
// swiftlint:disable:next line_length
internal struct WeakElements<Collect, Element> where Collect: RangeReplaceableCollection, Collect.Element == Element?, Element: AnyObject {
    internal var wrappedValue: Collect {
        get { Collect(weakObjects.compactMap { $0.object }) }
        set (newValues) { save(collection: newValues) }
    }
    
    private var weakObjects = [WeakObject<Element>]()

    public var projectedValue: Collect {
        wrappedValue
    }
    
    internal init(wrappedValue value: Collect) {
        save(collection: value)
    }

    private mutating func save(collection: Collect) {
        weakObjects = collection.map { WeakObject(object: $0) }
    }
}
