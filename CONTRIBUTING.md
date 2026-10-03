# Contributing to DMUnLoader

Thank you for helping. This guide says how to build and test the package and its example
app.

## Build and test

You need Xcode 26.0 or later (Swift 6.2) and an iOS simulator. The package's tests run on a
simulator:

```bash
xcodebuild test -scheme DMUnLoader -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -skipPackagePluginValidation -enableCodeCoverage YES
```

CI runs them on iOS 26.5 and 26.2. Before a release they also run locally on iOS 17.5 and
18.6.

## The checks

The checks are scripts in `Scripts/`, and CI runs them as you do, except
`check-example-project.sh`, which needs XcodeGen.

| Script | What it checks |
|---|---|
| `Scripts/lint.sh` | SwiftLint, at the version pinned in `.swiftlint.yml` |
| `Scripts/check-api.sh` | the public interface against `Fixtures/API/public-interface.txt`; `--self-test` runs the cases of its normalisation |
| `Scripts/check-manifest.sh` | the manifest, installation by version, and the consumer fixture |
| `Scripts/coverage-gate.sh <result bundle>` | the line coverage of the library against its floor |
| `Scripts/check-warnings.sh <build log>` | that no compiler warning points into this repository |
| `Scripts/check-example-project.sh` | that the example's Xcode project matches its XcodeGen spec |
| `Scripts/check-example-install.sh` | that the old example's install helper deletes nothing outside the example |
| `Scripts/test-example.sh <simulator udid>` | the example's tests, below |

## The example app

`Examples/DMUnLoaderExample` uses the package from this checkout. Its app-hosted tests and
UI tests run with one script, on the simulator whose udid you pass
(`xcrun simctl list devices available` lists them):

```bash
Scripts/test-example.sh <simulator udid>
```

The example is one app that starts in several integration modes: SwiftUI, SwiftUI with a
manager written by the host, UIKit, and UIKit with such a manager. A launch that ends with
the app in the background leaves its scene session saved, and the next launch restores it
with the scene delegate of the earlier mode, so a UIKit launch after a SwiftUI one can show
nothing. The script builds once, runs the app-hosted tests, and then runs the UI test
classes in one group per scene delegate, with the app uninstalled before each group. A UI
test class launches the modes of one group only, and the script refuses a class that no
group names. CI runs the same script on iOS 26.5 and 18.6; before a release, run it on
iOS 17.5 too.

The Xcode project is generated with XcodeGen 2.45.3 from
`Examples/DMUnLoaderExample/project.yml`, and both are committed. Change the spec, not the
project, and run `Scripts/check-example-project.sh` before you commit.
