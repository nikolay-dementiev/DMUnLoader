---
name: correctness-and-concurrency
description: Review a change to DMUnLoader for isolation, the lifetime of a manager, whether the library can stop its host, and the documented limits. Use it on any change to the loading managers, the view model, the adapters or a documented limit.
---

# Correctness and concurrency

The question of this lane: does the library still behave as ENGINEERING.md and the README say it
does? The lane applies the rules of the repository and states none of its own. Report each finding
in the format of [Documentation/Review/README.md](../../../Documentation/Review/README.md).

## What it checks

- A change of what is `@MainActor`, an API that a host would have to call off the main actor, or a
  type that becomes or stops being `Sendable`. The loading manager protocol and
  `DMLoadingManagerMain` are `@MainActor`; the dismissal rules, the backdrop and the default
  settings are `Sendable`; the README tells the host to call the managers, the view providers and
  the root view on the main actor.
  (ENGINEERING.md, "The loading manager protocol and `DMLoadingManagerMain` are `@MainActor`")
  (ENGINEERING.md, "the backdrop and `DMLoadingManagerDefaultSettings` are `Sendable`")
  (README.md, "### Threads and lifetime")
- A replaced manager that the HUD keeps alive, or a manager that the library keeps for the host.
  The host keeps its manager alive, and the HUD keeps no replaced one.
  (README.md, "The HUD keeps no replaced manager alive")
- A call that stops the app in a path that the lint rules do not list, or a second case beside the
  documented one, `DMRootLoadingView(content:)` without the app delegate of DMUnLoader. The lint
  rules report the named functions, a force unwrap, `try!` and `as!` in `Sources/DMUnLoader`; a
  framework object that stops the app when it is missing is outside them.
  (ENGINEERING.md, "The library's own code does not terminate the process")
  (AGENTS.md, "The library's own code never terminates the process")
  (README.md, "### Failures")
- A change to what the library enforces or cannot promise, as the README and the DocC catalog
  state it. Hand the finding to the lane public-api-and-documentation as a change of behaviour.
  (ENGINEERING.md, "Documented limits")
  (ENGINEERING.md, "A change of one of those limits is a change of behaviour")

## What it ignores

- What a CI script already enforces: `Scripts/lint.sh` and its rules (`no_process_termination`,
  `force_unwrapping`, `force_try`, `force_cast`, the imports of `Domain/`, missing documentation,
  formatting), the `thread-sanitizer` job, which a data race fails, and `Scripts/check-warnings.sh`.
- Where code lives and which dependencies it uses: that is the lane architecture-and-dependencies.
- What the HUD tells assistive technology, which touches it takes and which scenes it appears in:
  that is the lane accessibility-and-ui-integration.
- The class of a change and its documentation: that is the lane public-api-and-documentation.
- The quality of a test: that is the lane test-discrimination.
