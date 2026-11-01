---
name: accessibility-and-ui-integration
description: Review a change to DMUnLoader for what the HUD tells assistive technology, how it takes touches, the accessible appearance and the scene integrations. Use it on any change to the HUD window, the views, the scene delegates, the root view or their tests.
---

# Accessibility and UI integration

The question of this lane: does the HUD still do what the README tells an app that shows it?
Observable behaviour is a contract (ENGINEERING.md, "## Public API and behaviour"), and the README
states what the HUD does, mostly in its section "Behaviour your app must know". The lane applies
the rules of the repository and states none of its own. Report each finding in the format of
[Documentation/Review/README.md](../../../Documentation/Review/README.md).

## What it checks

- Which touches the HUD window takes and which it lets through: a tap on the card, a tap outside
  it, Close and Retry, and every touch when no HUD is shown.
  (README.md, "### Touches")
- Which windows the HUD hides from assistive technology while it is shown, when VoiceOver is told
  that the screen changed, where it starts, and where it returns when the HUD goes.
  (README.md, "### Accessibility")
- The loading HUD as one element named by its text, or by the default loading text when the text is
  empty or only whitespace; the default images, which VoiceOver does not read; and an image that
  the host supplies, which keeps the accessibility the host gives it.
  (README.md, "### Accessibility")
- The escape gesture, which hides a success or a failure as a tap outside the card does.
  (README.md, "### Accessibility")
- Reduce Motion, which keeps the card and a pressed button still. (README.md, "### Accessibility")
- The default auto-hide of 2 seconds and the way to keep a failure on the screen,
  `DMHUDDismissal(autoHide: .never)`. A changed default is also a finding of the lane
  public-api-and-documentation. (README.md, "### Accessibility")
- The guarantees of `.accessible`: a contrast of 4.5:1 for text, the failure sign and the success
  mark, 3:1 for icons, progress indicators and button outlines, an opaque card, wrapping, a card
  that scrolls, and Close and Retry one above the other at accessibility text sizes. `.standard`
  stays the look of every release.
  (README.md, "#### The accessible appearance")
- Reduce Transparency: the HUD draws neither the blur nor a material, `.variableBlur` keeps its dim
  and the card is opaque.
  (README.md, "### Backdrop")
  (README.md, "Reduce Transparency the HUD draws neither the blur nor a material")
- The default texts, which come from the string catalog and follow the language of the app, and the
  rule that a text equal to an English default counts as that default.
  (README.md, "### Texts and languages")
  (README.md, "A text equal to an English default counts as that default")
- The HUD windows of a scene: one integration per scene gives one, and the README names the case
  that gives two. The manager waits until the root view is in a window of a scene.
  (README.md, "### Threads and lifetime")
  (README.md, "### Failures")

## What it ignores

- What a CI script already enforces: `Scripts/lint.sh`; `Scripts/count-tests.sh`, which fails a run
  that dropped or skipped a test; `Scripts/check-example-results.sh`, which does the same for the
  example and decides its skips by device; `Scripts/check-warnings.sh`; `Scripts/check-manifest.sh`,
  which compiles the Swift blocks of the README; and the `docs` job.
- The manual VoiceOver pass, a step of the release.
  (CONTRIBUTING.md, "The manual VoiceOver pass")
- The contrast and the clipped text of the `.standard` look, which the README lists as known.
  (README.md, "## Known issues")
- Isolation and the lifetime of a manager: that is the lane correctness-and-concurrency.
- The quality of the tests that measure contrast: that is the lane test-discrimination.
- The class of a change and its documentation: that is the lane public-api-and-documentation.
