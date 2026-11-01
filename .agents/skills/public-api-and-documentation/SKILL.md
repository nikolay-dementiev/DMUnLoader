---
name: public-api-and-documentation
description: Review a change to DMUnLoader for the class of the change, the baseline of the public interface, the changelog and the documented limits. Use it on any change that touches a public declaration, an observable behaviour or a document that people using the package read.
---

# Public API and documentation

The question of this lane: is the change classified as ENGINEERING.md classifies it, and does
everything that people using the package read say so? The lane applies the rules of the repository
and states none of its own. Report each finding in the format of
[Documentation/Review/README.md](../../../Documentation/Review/README.md).

## What it checks

- The class of the change, none, additive or breaking, is stated and is right. A change of
  observable behaviour is breaking, and so are a crash that stops happening, a changed default
  value, a new case in a public enum that a consumer can switch over and a new protocol
  requirement without a default implementation.
  (ENGINEERING.md, "## Public API and behaviour")
  (AGENTS.md, "Classify every change")
  (ENGINEERING.md, "every change of observable behaviour is breaking")
  (ENGINEERING.md, "A changed default value")
  (ENGINEERING.md, "A new case in a public enum that a consumer can switch over")
  (ENGINEERING.md, "A new protocol requirement without a default implementation")
- `Fixtures/API/public-interface.txt` changes in the same commit as the declaration.
  `Scripts/check-api.sh` sees only the tip of the branch, so it cannot tell which commit changed it.
  (ENGINEERING.md, "that the baseline changes in the same commit as the declaration")
  (CONTRIBUTING.md, "A change of the public interface updates `Fixtures/API/public-interface.txt`")
- An added overload that makes an existing call ambiguous, and a protocol requirement with a
  default implementation whose name a protocol extension already declares or that a member of a
  conformer would capture. The baseline holds the interface as the compiler prints it, so no script
  sees them.
  (ENGINEERING.md, "Who checks.")
  (ENGINEERING.md, "whether an added line adds an overload that makes an existing call ambiguous")
  (ENGINEERING.md, "a review finds no member of a conformer that the requirement would capture")
- A breaking change without the maintainer's decision, a migration note in `CHANGELOG.md` and a
  major version. `Scripts/check-release.sh` refuses a release that keeps the major version after a
  removed or changed line of the interface; it cannot see a change of behaviour, so the notes
  declare one under a `### Breaking changes` heading.
  (ENGINEERING.md, "A breaking change needs the maintainer's decision")
  (CONTRIBUTING.md, "Every breaking change, as ENGINEERING.md defines it")
  (CONTRIBUTING.md, "change listed under `### Changed` alone does not count")
- A compiler deprecation attribute in a 1.x release.
  (ENGINEERING.md, "No compiler deprecation attribute ships in a 1.x release")
- A change that people using the package can notice, with no entry in `CHANGELOG.md`.
  (CONTRIBUTING.md, "A change that people using the package can notice gets an entry")
- A change to a documented limit while the README or the DocC catalog that state it still say the
  old limit. A change of a limit is a change of behaviour.
  (ENGINEERING.md, "Documented limits")
  (ENGINEERING.md, "A change of one of those limits is a change of behaviour")
- The release the change needs is stated in the pull request. A CI or tool pin is class none, with a
  patch release or none.
  (PR template, "The release it needs")
  (ENGINEERING.md, "A CI or tool pin, such as a runner image or the SwiftLint version")

## What it ignores

- What a CI script already enforces: `Scripts/lint.sh` (including the rule that every public symbol
  is documented), `Scripts/check-api.sh` against the baseline, `Scripts/check-release.sh` (the
  changelog heading, the previous release from the tags, the major version after a removed or
  changed line of the interface, the pod frozen at 1.1.0), `Scripts/check-manifest.sh` (the Swift
  blocks of the README and of the DocC catalog compile), `Scripts/check-podspec.sh` and the `docs`
  job, where the warnings of DocC are errors.
- How the implementation is built: that is the lane architecture-and-dependencies.
- How the library behaves, and what the HUD tells assistive technology: those are the lanes
  correctness-and-concurrency and accessibility-and-ui-integration.
- The quality of a test: that is the lane test-discrimination.
