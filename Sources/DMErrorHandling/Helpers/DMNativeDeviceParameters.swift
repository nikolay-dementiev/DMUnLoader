//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
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

@MainActor
internal struct DMNativeDeviceParameters: DMDeviceParameters {
    
    /// The current screen size provider (injectable for testing)
    static var screenSizeProvider: ScreenSizeProvider = DefaultScreenSizeProvider()
    
    /// Reset the screen size provider to the default implementation
    static func resetScreenSizeProvider() {
        screenSizeProvider = DefaultScreenSizeProvider()
    }
    
    /// Get the current device screen size
    static var deviceScreenSize: CGSize {
        return screenSizeProvider.getScreenSize()
    }
}

// MARK: - Protocol for Screen Size Provider

/// Protocol for providing screen size
@MainActor
protocol ScreenSizeProvider {
    func getScreenSize() -> CGSize
}

/// Default implementation of ScreenSizeProvider
struct DefaultScreenSizeProvider: ScreenSizeProvider {
    func getScreenSize() -> CGSize {
        let deviceSize: CGSize
#if os(watchOS)
        deviceSize = WKInterfaceDevice.current().screenBounds.size
#elseif os(iOS)
        deviceSize = UIScreen.main.bounds.size
#endif
        return deviceSize
    }
}
