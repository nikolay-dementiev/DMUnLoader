//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

/// A protocol that defines device-specific parameters supported by this SDK.
/// This includes properties like screen size for different platforms (e.g., iOS, watchOS).
@MainActor
public protocol DMDeviceParameters {
    
    /// The screen size of the current device.
    static var deviceScreenSize: CGSize { get }
}

/// A concrete implementation of the `DMDeviceParameters` protocol.
/// This struct provides device-specific parameters for supported platforms (e.g., iOS, watchOS).
@MainActor
internal struct DMNativeDeviceParameters: DMDeviceParameters {
    
    /// A provider responsible for retrieving the screen size.
    /// - Note: This property is injectable for testing purposes.
    static var screenSizeProvider: ScreenSizeProvider = DefaultScreenSizeProvider()
    
    /// Resets the screen size provider to the default implementation.
    /// - Note: Useful for cleaning up after tests or ensuring the default behavior is restored.
    static func resetScreenSizeProvider() {
        screenSizeProvider = DefaultScreenSizeProvider()
    }
    
    /// Retrieves the current device's screen size using the configured `screenSizeProvider`.
    static var deviceScreenSize: CGSize {
        return screenSizeProvider.getScreenSize()
    }
}

// MARK: - Protocol for Screen Size Provider

/// A protocol defining the interface for providing the screen size of the current device.
@MainActor
protocol ScreenSizeProvider {
    
    /// Retrieves the screen size of the current device.
    /// - Returns: A `CGSize` representing the screen dimensions.
    func getScreenSize() -> CGSize
}

/// A default implementation of the `ScreenSizeProvider` protocol.
/// This struct retrieves the screen size based on the platform (e.g., iOS, watchOS).
struct DefaultScreenSizeProvider: ScreenSizeProvider {
    
    /// Retrieves the screen size of the current device.
    /// - Returns: A `CGSize` representing the screen dimensions.
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
