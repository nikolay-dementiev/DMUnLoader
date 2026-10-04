# Contributing to DMUnLoader

Thank you for helping. This guide says how to build and test the package and its example
app, what a test must do, and how to propose a change.

## Build and test

You need Xcode 26.0 or later (Swift 6.2) and an iOS simulator. The package's tests run on a
simulator:

```bash
xcodebuild test -scheme DMUnLoader -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -skipPackagePluginValidation -enableCodeCoverage YES
```

CI runs them on iOS 26.5 and 26.2. The oldest supported version is iOS 17.0, and iOS 17.5 is the
oldest runtime that is run locally. Before a release they also run locally on iOS 17.5 and 18.6.

## The checks

The checks are scripts in `Scripts/`, and CI runs them as you do, except
`check-example-project.sh`, which needs XcodeGen.

| Script | What it checks |
|---|---|
| `Scripts/lint.sh` | SwiftLint, at the version pinned in `.swiftlint.yml` |
| `Scripts/check-api.sh` | the public interface against `Fixtures/API/public-interface.txt`; `--self-test` runs the cases of its normalisation |
| `Scripts/check-manifest.sh` | the manifest, installation by version, the consumer fixture, and every Swift block of `README.md` and of the documentation catalog, each on its own, in Swift 6 and Swift 5 mode: a manifest block is evaluated, every other block compiled. A warning in a compiled block fails it too; a manifest block is only evaluated, so a warning in it is not checked |
| `Scripts/coverage-gate.sh <result bundle>` | the line coverage of the library against its floor |
| `Scripts/check-podspec.sh` | `pod lib lint` in every Swift version of the podspec, that the pod makes its consumer link no test framework, and that the consumer app carries the pod's resource bundle with every key of the string catalog |
| `Scripts/check-release.sh <version>` | that the podspec and the newest heading of the changelog agree on a version; `--notes` prints its notes |
| `Scripts/check-warnings.sh <build log>` | that no compiler warning points into this repository |
| `Scripts/check-example-project.sh` | that the example's Xcode project matches its XcodeGen spec |
| `Scripts/test-example.sh <simulator udid>` | the example's tests, below |

CI also builds the documentation, with DocC's warnings as errors:

```bash
xcodebuild docbuild -scheme DMUnLoader -destination 'generic/platform=iOS Simulator' -skipPackagePluginValidation OTHER_DOCC_FLAGS=--warnings-as-errors
```

The checks and the tests run code that the branch contains: the scripts in `Scripts/`, the tests
and the example app, `Package.swift`, `Package.resolved` and the manifest blocks of the README
through Swift Package Manager, the podspec through CocoaPods, and `project.yml` through XcodeGen.
Tests in a simulator run as your macOS user. Before you run anything of someone else's branch,
read what it changes in those files; the CI run of a pull request, with its read-only token, is
the safer place to see it work.

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

## Tests

- XCTest, through the public API: no `@testable import` in a new test. A collaborator that a
  test must replace is declared `package`, and the test imports the module plainly.
- One `makeSUT()` factory per test class, and hand-written spies that record calls.
- Names say the subject, the condition and the expected result:
  `test_<subject>_<condition>_<expected>`.
- In a test with two or more assertions, every assertion carries a message.
- A test must be able to fail. Show it red against the code before your change, or, for a test of
  behaviour that already holds, with a temporary change of the code it covers.
- A fix starts with a test that reproduces the defect.
- A snapshot reference is named for its iOS version, `<name>_ios<major>_<minor>`. A local run
  records a missing reference and fails once; CI never records one. Look at a new picture before
  you commit it.

## Commits and pull requests

- One topic per commit, with a conventional prefix: `test:`, `fix:`, `feat:`, `refactor:`, `docs:`,
  `chore:`, `ci:` or `perf:`.
- The commit with a failing test comes before the commit that makes it pass.
- A change of the public interface updates `Fixtures/API/public-interface.txt` in the same commit.
- Pull requests go to `main` and are merged with a merge commit, so the test and fix pairs stay
  visible.
- A change that people using the package can notice gets an entry in `CHANGELOG.md`.

## Releases

A release starts from a tag that is the version itself, such as `1.1.0`, on a commit of `main`:
merge first, then tag. Before the tag is pushed:

1. The podspec names that version, and the newest heading of `CHANGELOG.md` is `## [1.1.0] -` with
   the release date and the notes under it. `Scripts/check-release.sh 1.1.0` checks them.
2. The tests of the package and of the example app pass on iOS 17.5, the oldest version the
   package supports, and on iOS 18.6. CI runs neither for the package and only iOS 18.6 for the
   example, so these runs are local:
   `xcodebuild test -scheme DMUnLoader -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 13 Pro,OS=17.5' -skipPackagePluginValidation`,
   the same with `name=iPhone 16 Pro,OS=18.6`, and `Scripts/test-example.sh` with the udid of
   each of those simulators.
3. The example's tests pass on an iPad simulator, where two scenes run side by side:
   `Scripts/test-example.sh` with the udid of an iPad simulator. CI runs no iPad.
4. The manual VoiceOver pass: the loading, success and failure HUDs of the example app, Retry,
   Close and the escape gesture, and the focus that returns to the app when a HUD goes.
5. The sibling pods are on the CocoaPods trunk before the podspec is pushed: DMAction and
   DMVariableBlurView, which the podspec requires with `~> 1.1`.

On the tag, the release workflow runs the check, makes sure the tagged commit is on `main`, runs the
whole CI workflow, makes sure the tag still points at the commit CI tested, and drafts a GitHub
release from the changelog section. Publishing the release, and the pod, stays a manual step:
publish the draft, then `pod trunk push DMUnLoader.podspec`.

## Security

Do not report a vulnerability in a public issue. See `SECURITY.md`.
