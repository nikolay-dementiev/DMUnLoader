//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 15.02.2025.
//

import Foundation

internal struct SchemaArguments {
    internal static let isInspectionEnabled: Bool = ProcessInfo.processInfo.arguments.contains("--enable-inspection")
}
