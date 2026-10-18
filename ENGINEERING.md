# Engineering standard

This is the standard DMUnLoader is built by: what a change to its public interface and behaviour
costs, what the package is made of, and which toolchains and platforms it promises.
[CONTRIBUTING.md](CONTRIBUTING.md) has the commands, the checks CI runs, the rules for tests and
the release steps. This file does not repeat them.

## Public API and behaviour

DMUnLoader is a published library, so what a consumer can see is a contract: every `public`
declaration and every observable behaviour. Each change belongs to one of three classes:

- **none**: no declaration and no observable behaviour changes.
- **additive**: new declarations only, with `Fixtures/API/public-interface.txt` updated in the same
  commit, and nothing a consumer must do. A raised minimum version of a dependency can be additive
  under the conditions below the table.
- **breaking**: anything else.

The rule is strict and has no carve-out: every change of observable behaviour is breaking. That
includes a crash that stops happening and a behaviour brought back in line with the documentation.
A breaking change needs the maintainer's decision, a migration note in `CHANGELOG.md` and a major
version.

| Change | Class | Release |
|---|---|---|
| A changed default value | breaking | major |
| A new case in a public enum that a consumer can switch over (`DMLoadableType`, `DMAppError` and its nested `NetworkError` and `ResourceError`) | breaking | major |
| A new protocol requirement without a default implementation | breaking | major |
| A new protocol requirement with a default implementation, as the three settings of `DMLoadingManagerSettings` that 1.1.0 added | additive or breaking, see below | minor or major |
| An added overload | additive, or breaking if an existing call now resolves to it or becomes ambiguous | minor or major |
| Depending on a new major version of a dependency | breaking | major |
| Raising the minimum version of a dependency within the same major | additive or breaking, see below | minor or major |
| A CI or tool pin, such as a runner image or the SwiftLint version | none | patch, or no release |
| A pure refactor | none | patch, or no release |
| A crash that stops happening | breaking | major |

A new protocol requirement with a default implementation is additive only when its name is new to
the protocol and to its extensions, and a review finds no member of a conformer that the
requirement would capture. A name that a protocol extension already declares changes how a call is
dispatched: the extension method was called statically and the requirement is called dynamically,
so a conformer's own member of that name starts to be called. That is a change of behaviour, so it
is breaking.

Raising the minimum version of a dependency within the same major version is additive only when it
moves no platform floor, changes no behaviour and asks nothing of a consumer. It then needs a minor
release and its own line in the changelog. A raise that does any of these is breaking.

DMAction and DMVariableBlurView are required `from: "1.1.0"`. A new major version of either
enters this package only in a major version of this package. The module re-exports DMAction
(`@_exported import DMAction`), so the public declarations of DMAction are part of what a
consumer of DMUnLoader sees. ViewInspector and swift-snapshot-testing are required by the test
target only. The library product is dynamic.

Who checks. The `api` job of CI runs `Scripts/check-api.sh` on every pull request and fails it when
the public interface differs from the baseline; on a pull request it also writes to the job summary
the delta against the base of the pull request. `Scripts/check-release.sh` runs on the version tag,
and before it by whoever releases: it refuses a version that keeps the major version of the previous
release when the baseline lost or changed a line since that release, or when the notes of the
version have a `### Breaking changes` subsection, in any letter case. A comparison that cannot run
is an error, never a pass. The baseline holds the interface as the compiler prints it. A changed
default argument is a changed line of it. The body of a method or of a property is not in it, and so
is not a default that a protocol extension supplies, nor the resolution of an overload; those stay
with review. The other gates are `Scripts/lint.sh`, `Scripts/check-lint-contract.sh`,
`Scripts/check-lint-tool.sh`, `Scripts/check-warnings.sh`, `Scripts/check-manifest.sh`,
`Scripts/coverage-gate.sh` and the Thread Sanitizer job. The pull request template asks for the
class, the changes of observable behaviour and the release the change needs. The reviewer applies
the rest: that the baseline changes in the same commit as the declaration; whether an added line
adds an overload that makes an existing call ambiguous, a requirement to a protocol or a case to a
public enum; every change of observable behaviour that the notes do not declare, which a test
catches only where a test pins the behaviour; and the approval of a dependency.

## Deprecation

No compiler deprecation attribute ships in a 1.x release. Its warning appears at every use of the
symbol and fails a consumer that builds with warnings as errors, so it would turn a notice into a
breaking change. A symbol is retired in the documentation instead: the replacement and a
migration example say what to use. The next major version removes it.

## History

Version 1.1.0 changed behaviour under a minor version (`CHANGELOG.md`, 1.1.0, "Changed"). Among the
changes, settings and states compare what they show where they compared hash values, and a loading
text or a success message of more than one line is centred where it was aligned to the leading edge.
Under the rules above it would have needed a major version. The rules apply from the release after
1.1.0.

## The package as it is

- **Layers.** The folders of `Sources/DMUnLoader` follow the dependency rule: the inner layers know
  nothing of the outer ones.
  - `Domain/` holds the plain types and policies: the rules for dismissing and auto-hiding the HUD,
    its phase and card style, and the accessibility transition. It imports nothing today, and may
    import Foundation only. `Scripts/lint.sh` enforces that: the custom rule `domain_imports`
    reports any import in that folder except Foundation, whatever its attribute, access level or
    kind, and a second import after a semicolon too. An import in a comment or a string is not
    one. An import that follows a block comment on the same line is not seen.
  - `Presentation/` holds the view model, the lifecycle of the HUD window and the accessibility
    coordinator. It imports Combine only, and reaches the system through protocols
    (`HUDOverlayPresenting`, `AutoHideScheduler`, `HUDScene`, `ContentUnderneathHiding`,
    `AccessibilityAnnouncer`, `HUDTexts`).
  - `Adapters/` implements those protocols with UIKit, SwiftUI and `os`: the overlay window, the
    run-loop scheduler, the accessibility announcer and content hider, the bundle texts and
    `UIWindowScene` as the HUD scene. It also holds the observer of scene disconnection.
  - `PresentationView/` holds the SwiftUI views and their settings types, and `Helpers/` the scene
    delegates, the HUD window and scene view, the type-erased view provider and the extensions
    they use.
  - The types of `Presentation/` and `Adapters/` are `package` or internal. The facade that a host
    uses is public: `DMRootLoadingView`, `DMLoadingManager` and `DMLoadingManagerMain`,
    `DMLoadingViewProvider` and `DefaultDMLoadingViewProvider`, `DMAppDelegate`,
    `DMSceneDelegateBase` and `DMSceneDelegateUIKit`, with the settings types. The value types of
    the dismissal rules in `Domain/` are public too, because the settings return them.
- **Isolation.** The loading manager protocol and `DMLoadingManagerMain` are `@MainActor`. The
  library asks a view provider for its views on the main actor, and `DefaultDMLoadingViewProvider`
  conforms to `DMLoadingViewProvider` with an isolated conformance on the main actor. The dismissal
  rules, the backdrop and `DMLoadingManagerDefaultSettings` are `Sendable`.
- **The library's own code does not terminate the process.** The custom rule
  `no_process_termination` reports the names `fatalError`, `preconditionFailure`,
  `assertionFailure`, `precondition`, `assert`, `dispatchPrecondition`, `abort` and `exit` when a
  parenthesis follows, in `Sources/DMUnLoader`, so a method of that name is reported too, and
  SwiftLint's `force_unwrapping`, `force_try` and `force_cast` are on, so a force unwrap, a `try!`
  and an `as!` are reported too. The force unwrap rule has no exemption for a call with a literal
  argument, so `URL(string: "...")!` is reported as well. All of them run in `Scripts/lint.sh`. One
  documented case is outside them: `DMRootLoadingView(content:)` without the app delegate of
  DMUnLoader stops the app when the view appears, because SwiftUI does when the object the view
  needs is missing (README, "Failures"). `DMRootLoadingView(manager:content:)` needs no app
  delegate.
- **The rules are proved.** A rule that never matches reports nothing, so
  `Scripts/check-lint-contract.sh` lints the fixtures of `Fixtures/Lint` and proves that
  `domain_imports`, `force_unwrapping` and `no_process_termination` fire on the lines that expect
  them and on no other line. Where a fixture lies decides where it is linted: in the root of
  `Fixtures/Lint` as a file of the library, in `Domain/` or `Adapters/` as a file of that folder,
  and under `Outside/` outside the library, where the fixture expects nothing. So the contract shows
  that the termination rule reaches the root, `Domain/` and `Adapters/`, that the import rule
  reaches `Domain/` and neither the root nor `Adapters/`, and that neither reaches a fixture package
  or a second module, one whose name starts like the library's included. `force_unwrapping` has no
  include and applies everywhere. The real tree is a second proof for the import rule: the library
  imports UI frameworks outside `Domain/`, so `Scripts/lint.sh` fails when the rule is widened. The
  termination rule has no lasting proof of that kind: no source of the library calls those
  functions, so only the fixtures show its scope. CI runs the contract right after
  `Scripts/lint.sh`.
  `Scripts/check-lint-tool.sh` proves, with a fake archive, that two runs of the helper that fetches
  SwiftLint on one checkout do not disturb each other.
- **The analyzer runs in CI.** `unused_import` is an analyzer rule, so the `lint` job builds the
  library and runs `Scripts/lint.sh --analyze` on the log of that build. The analyzer reads the
  files of the library that the log names; `Tests/` and `Examples/` are not in the log. The settings
  of the rule in `.swiftlint.yml` keep two imports that it does not see used, `Combine` and
  `CoreGraphics`, and say why.
- **The sanitizer and the scans fail when they should.** The `thread-sanitizer` job sets no
  `TSAN_OPTIONS`, and a race fails it: a test that wrote one variable from many threads failed with
  the job's own command on Xcode 26.6 and the iOS 26.5 simulator, and passed without the sanitizer.
  `Scripts/check-warnings.sh` runs on the logs of the `test` job, of the build of the `example` job,
  of the Release build of the `consumer` job and of the `floor` build, so a warning in this
  repository's files fails the job, and so does one that only a Release build compiles. The floor
  build is verbose (`swift build -v`), because the log of a clean build names no path of the
  checkout, and the scan rejects such a log as the log of another build. Both scans were tried with
  a warning planted in a scratch copy (in a block that only a Release build compiles, and in any
  block of the floor build) and failed as they should, with Xcode 26.6; the floor job itself runs
  Xcode 26.0.1, which was not available for that try. No planted warning is in the repository.
- **The test runs are counted.** The coverage floor sits under the measured coverage, so a run that
  drops a test class, or has a test that skips itself, passes it: with a class dropped by a flag
  and one skipped test, the `test` job ran 321 tests and kept 92.21 percent against a floor of
  92.00. The `test` job now compares its bundle with the test methods of `Tests`, an attribute
  such as `@MainActor` allowed before `func`, and fails unless all of them ran and passed.
  `Scripts/check-example-results.sh` does the same for the example, over the bundles of all its
  groups, and decides the skips by the device: on a phone only the two tests that need a second
  scene may skip, on an iPad none, and both ran and passed by name. Only the iPad run of the
  release steps, on iOS 26.2, can show that, since CI runs no iPad, and the iPadOS 18.6 simulator
  declines a second scene, so that run fails there. The check compares counts with the sources,
  not the names of the tests with their methods. A missing snapshot reference fails in CI and is never
  written, in the package tests and in the example's UI tests; that was tried by removing the
  reference of the iOS 26.5 cell. A deleted test lowers the count in the sources and in the bundle
  alike, and only the review of the diff sees it. No canary is in the repository.
- **Documented limits.** What the library enforces and what it cannot promise are in the README,
  "Behaviour your app must know", and in the DocC catalog (`Sources/DMUnLoader/DMUnLoader.docc`).
  This file points to them and does not restate them. A change of one of those limits is a change of
  behaviour.

## Toolchain and platforms

- The manifest declares `swift-tools-version: 6.2` and the Swift 6 language mode, so the package
  needs Xcode 26.0 or later. The reason for 6.2 is an isolated conformance, a Swift 6.2 feature
  (SE-0470): `DefaultDMLoadingViewProvider` conforms to `DMLoadingViewProvider` with `@MainActor`
  (`Sources/DMUnLoader/DMLoadingViewProvider.swift`, line 121). `ExistentialAny` is on in every
  target.
- The declared platform is iOS 17.0. Raising the platform floor, or the `swift-tools-version`, is a
  breaking change.
- `.github/workflows/ci.yml` is the place that says what CI runs; this file does not restate it. The
  policy needs four facts. The oldest iOS runtime that CI runs a test on is iOS 18.6, for the
  example app; the tests of the package run on iOS 26.5 and 26.2. iOS 17.5 runs locally before a
  release (CONTRIBUTING.md, "Releases"). The `floor` job builds the library with Xcode 26.0.1, the
  oldest compiler line the manifest allows, for iOS 17.0, and runs no test; its log is scanned for
  warnings in this repository's files.
- "Oldest tested runtime" and "oldest supported version" are different statements. The supported
  version is a promise: the platform the manifest declares. The tested runtime is evidence: the
  oldest runtime a test has run on. That is iOS 17.5 against a promise of iOS 17.0.
- A consumer of the package resolves the package, DMAction and DMVariableBlurView, and nothing
  else: the libraries that only the tests use are not fetched for it. `Scripts/check-manifest.sh`
  builds the manifest of README.md by version for the iOS simulator on a cache of its own and fails
  on any other package in the `Package.resolved` of that build. The list is `RUNTIME_DEPENDENCIES`
  in the script, and a new dependency changes it in the same pull request. The check proves this
  for the toolchain of the `consumer` job; another toolchain could resolve differently.
- No third-party dependency without the maintainer's approval. `Scripts/check-manifest.sh` rejects a
  dependency required by branch or revision, a plugin on any target, an unsafe flag and a manifest
  that reads the environment. The approval itself is a rule the reviewer applies.
- XCTest is the test framework. Another one comes only by the maintainer's decision.
- The manifest sets no `defaultIsolation`: it would change the inferred isolation of public
  declarations, which is observable behaviour.

## Where the rest lives

- [CONTRIBUTING.md](CONTRIBUTING.md): how to build and test, the checks CI runs, the rules for
  tests, commits and releases.
- `Sources/DMUnLoader/DMUnLoader.docc`: what each symbol does, and how the HUD behaves.
- [CHANGELOG.md](CHANGELOG.md): the history of every release.
- [README.md](README.md): installation and usage.
