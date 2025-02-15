//
//  DeviceParameters.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 17.01.2025.
//

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

/// This protocol provide all parameters spesific for any device type
/// which this SDK support
/// e.g. iOS, watchOS,...
///
///
@MainActor
public protocol DMDeviceParameters {
    static var deviceScreenSize: CGSize { get }
}

/// This object provide implementation for all parameters spesific for any device type
/// which this SDK support
/// e.g. iOS, watchOS,...
///

@MainActor
internal struct DMNativeDeviceParameters: DMDeviceParameters {
    
    static var deviceScreenSize: CGSize = {
        let deviceSize: CGSize
#if os(watchOS)
        deviceSize = WKInterfaceDevice.current().screenBounds.size
#elseif os(iOS)
        deviceSize = UIScreen.main.bounds.size
#endif
        return deviceSize
    }()
}
