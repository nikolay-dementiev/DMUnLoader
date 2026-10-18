# Contributing to DMUnLoader

Thank you for helping. This guide says how to build and test the package and its example
app, what a test must do, and how to propose a change. [ENGINEERING.md](ENGINEERING.md) has the
compatibility and release policy, and what the package is made of.

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
| `Scripts/lint.sh` | SwiftLint, at the version pinned in `.swiftlint.yml`. The first run fetches that version into `.build/tools` and checks its checksum; runs at once on one checkout do not disturb each other. `--analyze <xcodebuild log>` also runs the analyzer rules, which CI does on the log of a build of the library |
| `Scripts/check-lint-contract.sh` | that the lint rules fire where they should: it lints the fixtures of `Fixtures/Lint` where their folder says (the root as files of the library, `Domain/` and `Adapters/` as files of that folder, `Outside/` outside the library) and compares the diagnostics of the import, force unwrap and termination rules with the ones each line expects |
| `Scripts/check-lint-tool.sh` | that the helper which fetches SwiftLint (`Scripts/swiftlint-tool.sh`) is safe to run twice at once: with a fake archive and shims for `unzip`, `curl` and `mv` it checks that the tool stays whole while another run unpacks and is replaced by a rename, that two first-time runs both succeed, that a wrong checksum never reaches the unpack, and that a failed download or unpack leaves no part file and no unpack folder behind |
| `Scripts/check-api.sh` | the public interface against `Fixtures/API/public-interface.txt`; `--self-test` runs the cases of its normalisation; `--since <ref>` prints, without a compiler, the lines the baseline lost, changed or gained since a git ref such as a release tag |
| `Scripts/check-manifest.sh` | the manifest, installation by version, the consumer fixture, and every Swift block of `README.md` and of the documentation catalog, each on its own, in Swift 6 and Swift 5 mode: a manifest block is evaluated, every other block compiled. A warning in a compiled block fails it too; a manifest block is only evaluated, so a warning in it is not checked. Installation by version is the manifest block of `README.md`, pointed at a tagged copy and built for the iOS simulator on a cache of its own; its `Package.resolved` must hold this package, DMAction and DMVariableBlurView and nothing else, so a library that only the tests use is not fetched for a consumer. `--self-test` runs the cases of the readers of the README and of `Package.resolved` |
| `Scripts/coverage-gate.sh <result bundle>` | the line coverage of the library against its floor |
| `Scripts/check-podspec.sh` | `pod lib lint` in every Swift version of the podspec, that the pod makes its consumer link no test framework, and that the consumer app carries the pod's resource bundle with every key of the string catalog |
| `Scripts/check-release.sh <version>` | that the newest heading of the changelog is that version with a real release date and has notes under it, and that the podspec still names the frozen 1.1.0; it also takes the previous release from the tags (the highest release tag below the version that the commit reaches) and refuses a changelog whose heading below the newest does not name it, is not lower than the version or skips a reachable tag; it compares the release with it and refuses a version that keeps its major version after a removed or changed line of the interface, or after a breaking-changes heading in the notes (a heading of any level, or a bold line, whose first word is "breaking"); it refuses a release whose previous release is not an ancestor of the commit, and, when the newest heading is for the version, stops with exit 2 in a shallow clone. Under GitHub Actions the reminder for added lines is also a warning annotation. `--notes` prints the notes; `--self-test` runs these decisions on scratch repositories, and the `api` job runs it |
| `Scripts/check-warnings.sh <build log>` | that no compiler warning points into this repository; CI runs it on the logs of the package tests, of the example's build, of the Release build and of the floor build |
| `Scripts/check-example-project.sh` | that the example's Xcode project matches its XcodeGen spec |
| `Scripts/test-example.sh <simulator udid>` | the example's tests, below |
| `Scripts/check-example-results.sh <family> <bundle>...` | that the runs of the example held as many tests as its sources have test methods and skipped only what may skip on that device (family `phone`: the two tests that need a second scene; `pad`: nothing, and both ran and passed); `Scripts/test-example.sh` runs it after its last group, and `--self-test` runs the cases of its reader |

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

1. The newest heading of `CHANGELOG.md` is `## [<version>] -` with the release date and the notes
   under it. `Scripts/check-release.sh <version>` checks it. The podspec stays at 1.1.0, because
   the pod is frozen.
2. Every breaking change, as ENGINEERING.md defines it, needs a new major version, with no
   exception for a small one. A removed or changed line of the interface is one:
   `Scripts/check-api.sh --since <previous version>` lists them. A change of behaviour is another,
   and the notes of the release declare it in a `### Breaking changes` heading, because no script
   can see behaviour: a heading of any level, or a line in bold, in any letter case, whose first
   word is "breaking" (`#### Breaking changes (API)` counts, `### No breaking changes` does not). A
   change listed under `### Changed` alone does not count.
   `Scripts/check-release.sh` takes the previous release from the tags, not from the changelog: the
   heading below the newest one has to name the highest release tag below the version that the
   commit reaches, so a release that the changelog skips is named. A run before the tag needs the
   whole history and the tags: in a shallow clone it stops (`git fetch --unshallow --tags`). The
   script refuses a version that keeps the major version of the previous one when the baseline
   lost or changed a line, or when the notes have a breaking-changes heading. Lines that were only
   added pass the script, with a reminder that is also a warning annotation in the log of the
   release run. A new case of a public enum, a protocol requirement without a default
   implementation and an overload that makes an existing call ambiguous are breaking and need a
   new major version; a requirement with a default implementation is additive only when its name
   is new to the protocol and to its extensions. The script cannot see which of them an added line
   is, nor the order of the cases of an enum or of the statements in the body of an inlinable
   function. It cannot tell a line that a new compiler reworded from a line that the code changed,
   so both count. Run `Scripts/check-api.sh` first, since the baseline is the interface of the
   library only while that check passes.
3. The tests of the package and of the example app pass on iOS 17.5, the oldest runtime a test
   runs on (the package supports iOS 17.0), and on iOS 18.6. CI runs neither for the package and
   only iOS 18.6 for the example, so these runs are local:
   `xcodebuild test -scheme DMUnLoader -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 13 Pro,OS=17.5' -skipPackagePluginValidation`,
   the same with `name=iPhone 16 Pro,OS=18.6`, and `Scripts/test-example.sh` with the udid of
   each of those simulators.
4. The example's tests pass on an iPad simulator on iOS 26.2, where two scenes run side by side:
   `Scripts/test-example.sh` with the udid of an iPad Pro 11-inch simulator on iOS 26.2, the one
   whose snapshot references are in the repository. The script fails when any test skipped on an
   iPad, so a run that passes has run the two-scene tests. The iPadOS 18.6 simulator declines a
   second scene, they skip there, and that run fails; on iOS 26.5 the UI tests have no reference
   for an iPad, and fail in CI, while a run without `CI` writes them and fails once. CI runs no
   iPad.
5. The manual VoiceOver pass: the loading, success and failure HUDs of the example app, Retry,
   Close and the escape gesture, and the focus that returns to the app when a HUD goes.

On the tag, the release workflow runs the check, makes sure the tagged commit is on `main`, runs the
whole CI workflow, makes sure the tag still points at the commit CI tested, and drafts a GitHub
release from the changelog section. Publishing the release stays a manual step: publish the draft.
Nothing goes to the CocoaPods trunk.

When the package is listed in the Swift Package Index, open its page there once the tag is pushed
and the index has built the new version, and check that the documentation build is green: on the
page of build results, the build that carries the mark for generated documentation shows
Succeeded, and the Documentation link of the package page opens. The package page links the
documentation of the latest release, so this step cannot come before the tag. Until the package
is listed, the step is skipped.

## Security

Do not report a vulnerability in a public issue. See `SECURITY.md`.
