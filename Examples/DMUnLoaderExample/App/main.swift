import SwiftUI

// One app target, started in one of the ways the library can be integrated.
// The schemes of this project pass the arguments, and so do the UI tests.
switch (LaunchOptions.current.integration, LaunchOptions.current.usesCustomManager) {
case (.swiftUI, false):
    SwiftUIExampleApp.main()
case (.swiftUI, true):
    CustomManagerExampleApp.main()
case (.uiKit, _):
    UIKitExample.run()
}
