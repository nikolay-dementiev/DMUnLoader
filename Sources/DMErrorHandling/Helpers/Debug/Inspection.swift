//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

/// For more details on the functionality of this module, refer to:
/// https://github.com/nalexn/ViewInspector/blob/0.10.2/guide.md

@preconcurrency import Combine
import SwiftUI

internal final class Inspection<V>: @unchecked Sendable {

    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

/// An extension on `ViewModifier` to provide optional inspection capabilities.
/// If inspection is enabled via `SchemaArguments`, an `Inspection` instance is returned; otherwise, `nil`.
internal extension ViewModifier {
    
    /// Returns an `Inspection` instance for the current `ViewModifier` if inspection is enabled.
    /// - Returns: An `Inspection<Self>` instance if inspection is enabled; otherwise, `nil`.
    /// - Example:
    ///   ```swift
    ///   #if DEBUG
    ///     internal let inspection: Inspection<Self>? = getInspectionIfAvailable()
    ///   #endif
    ///   ```
    static func getInspectionIfAvailable() -> Inspection<Self>? {
        return SchemaArguments().isInspectionEnabled ? Inspection<Self>() : nil
    }
}

/// An extension on `View` to provide optional inspection capabilities.
/// If inspection is enabled via `SchemaArguments`, an `Inspection` instance is returned; otherwise, `nil`.
internal extension View {
    
    /// Returns an `Inspection` instance for the current `View` if inspection is enabled.
    /// - Returns: An `Inspection<Self>` instance if inspection is enabled; otherwise, `nil`.
    /// - Example:
    ///   ```swift
    ///   #if DEBUG
    ///     internal let inspection: Inspection<Self>? = getInspectionIfAvailable()
    ///   #endif
    ///   ```
    static func getInspectionIfAvailable() -> Inspection<Self>? {
        return SchemaArguments().isInspectionEnabled ? Inspection<Self>() : nil
    }
}

/// A placeholder publisher that emits inspection-related events.
/// This struct is typically used as a fallback or empty implementation.
internal struct EmptyPublisher {
    
    /// A `PassthroughSubject` used to emit inspection events.
    /// - Events are identified by a unique line number (`UInt`).
    /// - Example:
    /// ```swift
    /// #if DEBUG
    ///  .... //view's body creation
    ///  .onReceive(inspection?.notice ?? EmptyPublisher().notice) { [weak inspection] in
    ///     inspection?.visit(self, $0)
    ///  }
    /// #endif
    /// ```
    let notice = PassthroughSubject<UInt, Never>()
}
