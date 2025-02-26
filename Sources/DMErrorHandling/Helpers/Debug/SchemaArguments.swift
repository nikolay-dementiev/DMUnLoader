//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation

/// A protocol defining a provider for process information.
/// Conforming types must provide access to the command-line arguments of the current process.
///
/// This protocol is designed to abstract the retrieval of process arguments, allowing for
/// dependency injection or mocking in tests.
internal protocol ProcessInfoProvider: Sendable {
    
    /// The command-line arguments passed to the current process.
    /// - Example:
    ///   ```swift
    ///   let provider: ProcessInfoProvider = DefaultProcessInfoProvider()
    ///   print(provider.arguments) // Output: ["/path/to/executable", "--enable-inspection"]
    ///   ```
    var arguments: [String] { get }
}

/// A concrete implementation of the `ProcessInfoProvider` protocol.
/// This struct uses `ProcessInfo.processInfo.arguments` to retrieve the command-line arguments
/// of the current process.
internal struct DefaultProcessInfoProvider: ProcessInfoProvider {
    
    /// The command-line arguments passed to the current process.
    /// - Note: This implementation directly accesses `ProcessInfo.processInfo.arguments`.
    var arguments: [String] {
        return ProcessInfo.processInfo.arguments
    }
}

/// A struct that manages schema-related arguments and provides functionality to check
/// if inspection is enabled based on the current process arguments.
///
/// This struct uses a thread-safe `Atomic` wrapper to manage the `ProcessInfoProvider` instance,
/// allowing for dynamic replacement of the provider (e.g., for testing purposes).
internal struct SchemaArguments {
    
    /// A private nested type containing static settings for the `SchemaArguments` struct.
    private enum Settings {
        
        /// The default `ProcessInfoProvider` instance, which uses `DefaultProcessInfoProvider`.
        static let defaultProcessInfoProvider = DefaultProcessInfoProvider()
    }
    
    // swiftlint:disable:next orphaned_doc_comment
    /// A thread-safe wrapper around the `ProcessInfoProvider` instance.
    /// - Note: This property is marked as `nonisolated(unsafe)` due to its use of `Atomic`,
    ///   which ensures thread safety internally.
    // swiftlint:disable:next line_length
    nonisolated(unsafe) private static var processInfoProvider: Atomic<ProcessInfoProvider> = Atomic(Settings.defaultProcessInfoProvider)
    
    /// The current `ProcessInfoProvider` instance used by this struct.
    /// - Setting a new value replaces the existing provider with a new `Atomic` wrapper.
    /// - Example:
    ///   ```swift
    ///   var schemaArgs = SchemaArguments()
    ///   schemaArgs.currentProcessInfoProvider = MockProcessInfoProvider(arguments: ["--enable-inspection"])
    ///   print(schemaArgs.isInspectionEnabled) // Output: true
    ///   ```
    var currentProcessInfoProvider: ProcessInfoProvider {
        get { Self.processInfoProvider() }
        set(newProvider) { Self.processInfoProvider = Atomic(newProvider) }
    }
    
    /// Indicates whether inspection is enabled based on the presence of the `--enable-inspection` argument.
    /// - Returns: `true` if the `--enable-inspection` argument is present in the process arguments; otherwise, `false`.
    /// - Example:
    ///   ```swift
    ///   var schemaArgs = SchemaArguments()
    ///   print(schemaArgs.isInspectionEnabled) // Output depends on the actual process arguments
    ///   ```
    var isInspectionEnabled: Bool {
        return currentProcessInfoProvider
            .arguments
            .contains("--enable-inspection")
    }
    
    /// Resets the `currentProcessInfoProvider` to the default provider (`DefaultProcessInfoProvider`).
    /// - Example:
    ///   ```swift
    ///   var schemaArgs = SchemaArguments()
    ///   schemaArgs.currentProcessInfoProvider = MockProcessInfoProvider(arguments: [])
    ///   schemaArgs.resetSettingToDefault()
    ///   print(schemaArgs.isInspectionEnabled) // Output depends on the actual process arguments
    ///   ```
    mutating func resetSettingToDefault() {
        currentProcessInfoProvider = Settings.defaultProcessInfoProvider
    }
}
