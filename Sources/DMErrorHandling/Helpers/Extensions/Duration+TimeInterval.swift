//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 25.01.2025.
//

import Foundation

internal extension Duration {
    var timeInterval: TimeInterval {
        let seconds = Double(components.seconds)
        let attoseconds = Double(components.attoseconds) / 1_000_000_000_000_000_000
        return seconds + attoseconds
    }
}
