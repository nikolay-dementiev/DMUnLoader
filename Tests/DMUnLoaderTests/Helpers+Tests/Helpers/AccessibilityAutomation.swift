//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Darwin
import XCTest

/// The automation mode of the system's accessibility service, asked for from the test process.
///
/// SwiftUI builds the accessibility tree of a view only while an assistive technology or the automation
/// service is on. XCUITest turns the service on; a test of the package does not run under it, and
/// without it the tree of a hosted HUD has no element. The tests that read the tree turn the mode on
/// themselves, and leave the system as they found it when the test ends. The state lives in the system's
/// service and is reported back a little later than it is set.
///
/// The switch is a function of the system library `libAccessibility`. It is not documented, so it is
/// found at run time and never linked: a system that does not offer it ends the tests that need it with a
/// message that names the switch, not with a crash and not with a skip. This is test code only. Nothing
/// of the library and nothing of the example uses it.
@MainActor
enum AccessibilityAutomation {
    /// The system library that holds the switch.
    static let defaultLibraryPath = "/usr/lib/libAccessibility.dylib"
    /// The function that sets the mode, named in the message of a failure.
    static let setterName = "_AXSSetAutomationEnabled"
    private static let getterName = "_AXSAutomationEnabled"

    /// Switches the automation on.
    ///
    /// - Parameters:
    ///   - libraryPath: The system library to look the switch up in. Tests give another path to see the
    ///     failure.
    ///   - setterName: The function to look up. Tests give another name to see the failure.
    /// - Returns: `nil` when the call was made, otherwise why the switch cannot be used.
    static func turnOn(
        libraryPath: String = AccessibilityAutomation.defaultLibraryPath,
        setterName: String = AccessibilityAutomation.setterName
    ) -> String? {
        set(true, libraryPath: libraryPath, setterName: setterName)
    }

    /// Switches the automation off.
    ///
    /// - Returns: `nil` when the call was made, otherwise why the switch cannot be used.
    @discardableResult
    static func turnOff(libraryPath: String = AccessibilityAutomation.defaultLibraryPath) -> String? {
        set(false, libraryPath: libraryPath, setterName: setterName)
    }

    /// Whether the system reports the automation as on, or `nil` when it does not say.
    static func isOn(libraryPath: String = AccessibilityAutomation.defaultLibraryPath) -> Bool? {
        guard let handle = dlopen(libraryPath, RTLD_NOW), let symbol = dlsym(handle, getterName) else {
            return nil
        }
        typealias Getter = @convention(c) () -> Bool
        return unsafeBitCast(symbol, to: Getter.self)()
    }

    private static func set(_ on: Bool, libraryPath: String, setterName: String) -> String? {
        guard let handle = dlopen(libraryPath, RTLD_NOW) else {
            return failure("the library \(libraryPath) cannot be opened")
        }
        guard let symbol = dlsym(handle, setterName) else {
            return failure("the library \(libraryPath) has no function \(setterName)")
        }
        typealias Setter = @convention(c) (Bool) -> Void
        unsafeBitCast(symbol, to: Setter.self)(on)
        return nil
    }

    private static func failure(_ reason: String) -> String {
        """
        The accessibility automation cannot be switched on: \(reason). The tests that read the \
        accessibility tree of the HUD need it, because SwiftUI builds that tree only while the \
        automation service is on; the switch is the function \(setterName) of \(defaultLibraryPath). \
        This test fails and does not skip, so that a system that drops the switch is seen; the \
        switch lives in AccessibilityAutomation.swift.
        """
    }
}

@MainActor
extension XCTestCase {
    /// Switches the accessibility automation on for this test, and leaves the system as it was found
    /// when the test ends: off, unless it was on already.
    ///
    /// - Parameters:
    ///   - libraryPath: The system library to look the switch up in. Tests give another path to see the
    ///     failure.
    ///   - report: Records the failure. The default fails the test; a test of this function gives a
    ///     recorder, because a failure that is expected is counted by the result bundle as neither passed
    ///     nor failed, and the count of the CI would then miss a test.
    /// - Returns: Whether the switch was made. When it was not, the failure has been reported with a
    ///   message that names the switch, and the caller returns.
    @discardableResult
    func turnOnAccessibilityAutomation(
        libraryPath: String = AccessibilityAutomation.defaultLibraryPath,
        report: (String, StaticString, UInt) -> Void = { XCTFail($0, file: $1, line: $2) },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        let wasOn = AccessibilityAutomation.isOn(libraryPath: libraryPath) == true
        if let reason = AccessibilityAutomation.turnOn(libraryPath: libraryPath) {
            report(reason, file, line)
            return false
        }
        addTeardownBlock {
            guard !wasOn else { return }
            if let reason = AccessibilityAutomation.turnOff() {
                XCTFail(reason, file: file, line: line)
            }
        }
        return true
    }
}
