//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 15.02.2025.
//

import Foundation

internal protocol ProcessInfoProvider: Sendable {
    var arguments: [String] { get }
}

// Default implementation using ProcessInfo
internal struct DefaultProcessInfoProvider: ProcessInfoProvider {
    var arguments: [String] {
        return ProcessInfo.processInfo.arguments
    }
}

// Kind of Monostate
internal struct SchemaArguments {
    private enum Settings {
        static let defaultProcessInfoProvider = DefaultProcessInfoProvider()
    }
    
    // swiftlint:disable:next line_length
    nonisolated(unsafe) private static var processInfoProvider: Atomic<ProcessInfoProvider> = Atomic(Settings.defaultProcessInfoProvider)
    
    var currentProcessInfoProvider: ProcessInfoProvider {
        get { Self.processInfoProvider() }
        set(newProvider) { Self.processInfoProvider = Atomic(newProvider) }
    }
    
    var isInspectionEnabled: Bool {
        return currentProcessInfoProvider
            .arguments
            .contains("--enable-inspection")
    }
    
    mutating func resetSettingToDefault() {
        currentProcessInfoProvider = Settings.defaultProcessInfoProvider
    }
}
