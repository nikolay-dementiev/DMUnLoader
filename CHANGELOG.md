# Changelog

All notable changes to DMUnLoader are recorded in this file. The format follows Keep a
Changelog 1.1.0, and versions follow Semantic Versioning 2.0.0.

## [1.1.0] - 2026-10-04

### Added

- `DMRootLoadingView(manager:content:onAttachmentFailure:)` shows the HUD of a loading manager
  that the app owns over the scene of the view, with no app delegate of the library.
  `DMHUDAttachmentFailure` is the reason it would report; version 1.1.0 knows none.
- `DMLoadingManagerDefaultSettings` is public and `Sendable`, with one initializer whose
  arguments default to the released values.
- Three settings of a loading manager, each defaulting to the released behaviour, so a settings
  type that does not implement them keeps it: `hudDismissal` (`DMHUDDismissalRules`,
  `DMHUDDismissal`, `DMHUDAutoHide`: how a success, a failure without Retry and a failure with
  Retry leave the screen), `hudWindowLevel` (the level of the HUD window) and `backdrop`
  (`DMHUDBackdrop`: `.variableBlur`, the default, `.dim(_:)`, `.material(_:)` and `.clear`).
- `showFailure(_:provider:)` on every loading manager: a failure without Retry.
- Accessibility. While a HUD is shown, the windows of its scene at its window's level or below
  that are open when it appears are hidden from assistive technology. When the HUD appears or
  shows another state, VoiceOver is told that the screen changed; when it goes, VoiceOver returns
  to the element it was on, if that element is still on the screen. The escape gesture hides a
  success or a failure as a tap outside the card does. Reduce Motion keeps the card and a pressed
  button still; Reduce Transparency draws the dim without a blur or a material.
- The default texts come from a string catalog, English only in this version, and follow the
  language of the app. A text the app sets is shown as written, unless it equals an English
  default: then it counts as that default and follows the catalog.
- Documentation for every public symbol, and a documentation catalog.

### Fixed

- Retry, Close and a tap outside the card work on every supported version of iOS. On iOS 18
  and 26 the buttons of the failure HUD did nothing: the HUD window guessed from the view a
  touch landed on whether to take it. It now takes touches while a HUD is shown and lets every
  touch through while none is, decided from the state of the loading manager.
- A late automatic hide no longer hides a newer HUD. The auto-hide of a success or a failure is
  cancelled when the state is replaced, and a hide that was already on its way is ignored.
- One HUD window per scene. The window is reused for a new loading manager, so the replaced
  manager is released. It is removed when the loading manager of the scene delegate is set to
  `nil` and when the scene disconnects, and created when a manager was set before the scene
  connected. The UIKit integration no longer creates two HUD windows.
- A second appearance of the HUD view no longer reverses its fade. No route of the library
  makes that view appear twice today; the fix guards a later change.
- The package can be added by version. The manifest of 1.0.x required a lint plugin and its two
  sibling packages by branch, and Swift Package Manager refuses a version requirement on a
  package that does that; the lint plugin also ran in every app's build. DMAction and
  DMVariableBlurView are required from 1.1.0, and the libraries that only the tests use are
  not fetched for an app.
- A loading manager and a view provider are equal only to themselves. Both compared hash
  values, so two different providers could be equal.
- The alignment settings of the loading text and of the success text are applied.
- The default failure title reads "An error has occurred!". It read "An error has occured!".
- A tap anywhere inside the capsule of Close or Retry presses the button. Only the title and
  the outline took a tap, and a tap beside the title fell through to the card, which hides a
  failure by default.
- The pod no longer makes the apps that use it link XCTest.
- The README and the doc comments say that the auto-hide delay belongs to the loading manager's
  settings. The README of 1.0.x set it in the view provider, which never had an effect.

### Changed

Behaviour changes. None of them removes a declaration; each one is pinned by a test.

- Building needs the Swift 6.2 compiler, which is Xcode 26.0 or later. The sources already
  needed it; the manifest now declares Swift tools 6.2. The pod declares the Swift 5.0 and 6.0
  language modes.
- Settings and states compare what they show, where twelve equality operators compared hash
  values. A view that animates on the state animates a change it missed before, such as a
  failure shown again with a retry action.
- A loading text or a success message of more than one line is centred with the default
  settings. It was aligned to the leading edge.
- While a HUD is shown, the content under it is hidden from assistive technology, and so from
  the UI tests of the app.
- VoiceOver does not read the default images of the success and the failure HUD. An image the
  app supplies keeps the accessibility it was given.

### Deprecated

- The CocoaPods channel. Version 1.1.0 is the last release published to the CocoaPods trunk,
  which becomes read-only on 2 December 2026. Later releases come through Swift Package Manager
  only.

### Removed

- The example that resolves the package through both CocoaPods and Swift Package Manager. It
  remains at the tag 1.0.3, where its CocoaPods install helper deletes the whole DerivedData
  folder of Xcode, the build data of every project on the machine. `Examples/DMUnLoaderExample`
  is the example now.
- The Bitrise and Codemagic configurations. GitHub Actions runs every check.

### Known issues

- The default card of the HUD, white text on gray at opacity 0.8, does not reach the contrast of
  4.5:1; an app that needs it sets its own colours through the settings types, or supplies its
  own views through `DMLoadingViewProvider`.
- At large accessibility text sizes the default loading view, at most 150 points wide, cuts its
  text; an app that needs those sizes gives `DMProgressViewDefaultSettings` a larger
  `frameGeometrySize`, or supplies its own loading view.

## [1.0.3] - 2025-12-29

- A new main image in the README. No change in the library.

## [1.0.2] - 2025-12-28

- The version of the podspec and an action of a workflow. No change in the library.

## [1.0.1] - 2025-12-28

- Badges, icons and the link to the example project in the README. No change in the library.

## [1.0.0] - 2025-12-27

- First release: loading, success and failure states shown one at a time in a window of their
  own, for SwiftUI and UIKit, with default views and views of the app's own through
  `DMLoadingViewProvider`.

[1.1.0]: https://github.com/nikolay-dementiev/DMUnLoader/compare/1.0.3...1.1.0
[1.0.3]: https://github.com/nikolay-dementiev/DMUnLoader/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/nikolay-dementiev/DMUnLoader/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/nikolay-dementiev/DMUnLoader/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/nikolay-dementiev/DMUnLoader/tree/1.0.0
