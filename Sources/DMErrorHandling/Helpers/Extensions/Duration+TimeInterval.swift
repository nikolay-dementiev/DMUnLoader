//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation

/// An extension on `Duration` to provide additional functionality.
internal extension Duration {
    
    /// Converts the `Duration` value into a `TimeInterval` representation.
    /// - Returns: The total duration in seconds as a `TimeInterval`, including fractional seconds.
    /// - Note: This property combines the `seconds` and `attoseconds` components of the `Duration`
    ///   to calculate the precise time interval.
    /// - Example:
    ///   ```swift
    ///   let duration = Duration.seconds(2) + Duration.attoseconds(500_000_000_000_000_000)
    ///   let timeInterval = duration.timeInterval
    ///   print(timeInterval) // Output: 2.5
    ///   ```
    var timeInterval: TimeInterval {
        let seconds = Double(components.seconds)
        let attoseconds = Double(components.attoseconds) / 1_000_000_000_000_000_000
        return seconds + attoseconds
    }
}
