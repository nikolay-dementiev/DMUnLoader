---
name: architecture-and-dependencies
description: Review a change to DMUnLoader for imports, dependencies, platform floors and where code lives. Use it on any change to Sources, Package.swift, Tools/Package.swift, devkit.conf or the lint fixtures.
---

# Architecture and dependencies

The question of this lane: does the change keep the package what ENGINEERING.md says it is? The
lane applies the rules of the repository and states none of its own. Report each finding in the
format of [Documentation/Review/README.md](../../../Documentation/Review/README.md).

## What it checks

- An import that follows a block comment on the same line, in `Domain/`. The lint rule
  `domain_imports` reports every other import outside Foundation; this is the one case it does not
  see.
  (ENGINEERING.md, "An import that follows a block comment on the same line is not seen")
- A change that makes a type of `Domain/` name a type of `Presentation/`, `Adapters/`,
  `PresentationView/` or `Helpers/`, or a type of `Presentation/` name a type of `Adapters/`,
  `PresentationView/` or `Helpers/`; and a file of `Presentation/` that imports more than Combine
  or reaches the system other than through the protocols of the folder. The folders are one
  module, so no import shows the first, and no lint rule reports any of them.
  (ENGINEERING.md, "The folders of `Sources/DMUnLoader` follow the dependency rule")
  (ENGINEERING.md, "It imports Combine only, and reaches the system through protocols")
- A type of `Presentation/` or `Adapters/` that becomes `public`. `Scripts/check-api.sh` passes when
  the baseline changes with it, so only the reviewer asks whether the rule allows it.
  (ENGINEERING.md, "The types of `Presentation/` and `Adapters/` are `package` or internal")
- A new dependency of any kind in `Package.swift` or `Tools/Package.swift`, or a change of
  `Scripts/check-manifest.sh` that weakens its checks. The approval is the reviewer's: the script
  does not decide it, a dependency that only the tests use does not reach the consumer build, and
  a runtime one also changes `RUNTIME_DEPENDENCIES` in the same pull request.
  (ENGINEERING.md, "No third-party dependency without the maintainer's approval")
  (ENGINEERING.md, "The approval itself is a rule the reviewer applies")
  (ENGINEERING.md, "a new dependency changes it in the same pull request")
  (AGENTS.md, "Add no dependency without the maintainer's approval")
- A new major version of DMAction or DMVariableBlurView outside a major version of this package.
  (ENGINEERING.md, "enters this package only in a major version of this package")
- A raised platform floor or `swift-tools-version`, a `defaultIsolation` in the manifest, or a test
  framework other than XCTest.
  (ENGINEERING.md, "Raising the platform floor, or the `swift-tools-version`, is a breaking change")
  (ENGINEERING.md, "The manifest sets no `defaultIsolation`")
  (ENGINEERING.md, "XCTest is the test framework and stays so")
- `SWIFT_FLAGS` in `devkit.conf` and the flags in `Package.swift` that differ. No check compares
  them. (CONTRIBUTING.md, "`SWIFT_FLAGS` repeats what `Package.swift` sets")
- A lint rule added or widened that `RULES` in `devkit.conf` does not list. The contract compares
  the diagnostics of the listed rules only, with the lines their fixtures expect.
  (ENGINEERING.md, "The rules are proved.")
  (CONTRIBUTING.md, "compares the diagnostics of the rules named in `devkit.conf`")

## What it ignores

- What a CI script already enforces: `Scripts/lint.sh` and its rules (the imports of `Domain/`,
  force unwraps, process termination, missing documentation, formatting),
  `Scripts/check-lint-contract.sh`, `Scripts/check-wrappers.sh` and `Scripts/check-warnings.sh`.
- `Scripts/check-manifest.sh`, which rejects a dependency required by branch or revision, a
  plugin, an unsafe flag and a read of the environment, and fails when a consumer would resolve a
  package beyond `RUNTIME_DEPENDENCIES`, as it would if DMDevKit moved into the root manifest.
  (ENGINEERING.md, "so a consumer of DMUnLoader does not fetch DMDevKit")
- How the loading managers behave, and what the HUD tells assistive technology: those are the lanes
  correctness-and-concurrency and accessibility-and-ui-integration.
- The class of a change and its documentation: that is the lane public-api-and-documentation.
- The quality of a test: that is the lane test-discrimination.
