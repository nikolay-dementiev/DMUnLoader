//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

/// A custom `EnvironmentKey` used to store and retrieve a `GlobalLoadingStateManager` instance in the SwiftUI environment.
internal struct GlobalLoadingManagerKey: EnvironmentKey {
    
    /// The default value for the `GlobalLoadingManagerKey`.
    /// - Note: The default value is `nil`, indicating that no global loading state manager is set by default.
    nonisolated(unsafe) static let defaultValue: GlobalLoadingStateManager? = nil
}

/// An extension on `EnvironmentValues` to provide access to the `globalLoadingManager` property.
internal extension EnvironmentValues {
    
    /// A computed property that retrieves or sets the `GlobalLoadingStateManager` instance in the SwiftUI environment.
    /// - Returns: The current `GlobalLoadingStateManager` instance, or `nil` if none is set.
    /// - Example:
    ///   ```swift
    ///   struct ContentView: View {
    ///       @Environment(\.globalLoadingManager) private var globalLoadingManager
    ///
    ///       var body: some View {
    ///           if let manager = globalLoadingManager {
    ///               Text("Global Loading Manager is available")
    ///           } else {
    ///               Text("No Global Loading Manager is set")
    ///           }
    ///       }
    ///   }
    ///   ```
    var globalLoadingManager: GlobalLoadingStateManager? {
        get { self[GlobalLoadingManagerKey.self] }
        set { self[GlobalLoadingManagerKey.self] = newValue }
    }
}
