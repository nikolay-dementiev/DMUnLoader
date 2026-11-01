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
- A type of `Domain/` or `Presentation/` that names a type of an outer folder, a file of
  `Presentation/` that imports more than Combine, or one that reaches the system other than through
  the protocols of the folder. The folders are one module, so no import shows the first, and no
  lint rule reports any of them.
  (ENGINEERING.md, "The folders of `Sources/DMUnLoader` follow the dependency rule")
  (ENGINEERING.md, "It imports Combine only, and reaches the system through protocols")
- A type of `Presentation/` or `Adapters/` that becomes `public`. `Scripts/check-api.sh` passes when
  the baseline changes with it, so only the reviewer asks whether the rule allows it.
  (ENGINEERING.md, "The types of `Presentation/` and `Adapters/` are `package` or internal")
- A dependency, a plugin, an unsafe flag or a read of the environment that comes with a change of
  `Scripts/check-manifest.sh`, or a change of that script that weakens it. The script rejects them
  by name, and a new dependency changes `RUNTIME_DEPENDENCIES` in the same pull request; the
  approval is the reviewer's.
  (ENGINEERING.md, "No third-party dependency without the maintainer's approval")
  (ENGINEERING.md, "a new dependency changes it in the same pull request")
  (AGENTS.md, "Add no dependency without the maintainer's approval")
- A new major version of DMAction or DMVariableBlurView outside a major version of this package, or
  DMDevKit or another tool dependency moved from `Tools/Package.swift` into the root manifest,
  where a consumer would fetch it.
  (ENGINEERING.md, "enters this package only in a major version of this package")
  (ENGINEERING.md, "so a consumer of DMUnLoader does not fetch DMDevKit")
- A raised platform floor or `swift-tools-version`, a `defaultIsolation` in the manifest, or a test
  framework other than XCTest.
  (ENGINEERING.md, "Raising the platform floor, or the `swift-tools-version`, is a breaking change")
  (ENGINEERING.md, "The manifest sets no `defaultIsolation`")
  (ENGINEERING.md, "XCTest is the test framework and stays so")
- `SWIFT_FLAGS` in `devkit.conf` and the flags in `Package.swift` that differ. No check compares
  them. (CONTRIBUTING.md, "`SWIFT_FLAGS` repeats what `Package.swift` sets")
- A lint rule added or widened without a fixture that proves that it fires on the lines that expect
  it and on no other line. (ENGINEERING.md, "The rules are proved.")

## What it ignores

- What a CI script already enforces: `Scripts/lint.sh` and its rules (the imports of `Domain/`,
  force unwraps, process termination, missing documentation, formatting),
  `Scripts/check-lint-contract.sh`, `Scripts/check-manifest.sh`, `Scripts/check-wrappers.sh` and
  `Scripts/check-warnings.sh`.
- How the loading managers behave, and what the HUD tells assistive technology: those are the lanes
  correctness-and-concurrency and accessibility-and-ui-integration.
- The class of a change and its documentation: that is the lane public-api-and-documentation.
- The quality of a test: that is the lane test-discrimination.
