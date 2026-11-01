---
name: test-discrimination
description: Review the tests of a DMUnLoader change for whether each one can fail, goes through the public API and is written the way the repository asks. Use it on any change to Tests or Examples, and on any fix or change of behaviour.
---

# Test discrimination

The question of this lane: would these tests catch the defect they claim to catch? The lane
applies the rules of the repository and states none of its own. Report each finding in the format
of [Documentation/Review/README.md](../../../Documentation/Review/README.md).

## What it checks

- A new test for which the change of the code that it fails on is not named, or is named and would
  not make the test fail. For a behaviour that already holds, a temporary change of the code under
  test counts.
  (CONTRIBUTING.md, "Show it red against the code before your change")
  (CONTRIBUTING.md, "A test must be able to fail")
  (AGENTS.md, "Every new test must be able to fail")
  (PR template, "For each new test, the change to the code that it fails on")
- A new test that reaches past the public API with `@testable import`, or a type made `public`
  only so that a test can reach it, where the rule is `package`. An existing file that has the
  import is a finding only where the diff adds it.
  (AGENTS.md, "no `@testable import`")
  (CONTRIBUTING.md, "XCTest, through the public API: no `@testable import` in a new test")
  (CONTRIBUTING.md, "A collaborator that a test must replace is declared `package`")
- A test class without a `makeSUT()` factory, or a double that is not a hand-written spy that
  records calls. (CONTRIBUTING.md, "One `makeSUT()` factory per test class")
- A name that does not say the subject, the condition and the expected result, or a test with two
  or more assertions where one has no message. (CONTRIBUTING.md, "Names say the subject")
  (CONTRIBUTING.md, "every assertion carries a message")
- A fix without a test that reproduces the defect, or a commit with the failing test that does not
  come before the commit that makes it pass. (CONTRIBUTING.md, "A fix starts with a test")
  (CONTRIBUTING.md, "The commit with a failing test comes before")
- A snapshot reference whose name lacks the iOS version, or a new picture committed without anyone
  having looked at it.
  (CONTRIBUTING.md, "A snapshot reference is named for its iOS version")
  (CONTRIBUTING.md, "Look at a new picture before you commit it")
- A test that hosts the HUD and leaves the accessibility automation mode of the system switched on,
  or that mode switched on outside test code.
  (CONTRIBUTING.md, "leave the system as they found it when the test ends")
  (CONTRIBUTING.md, "The switch is test code only")
- A deleted test. The checks compare the bundle with the test methods of the sources, so a deleted
  test lowers both counts, and only the review of the diff sees it.
  (ENGINEERING.md, "only the review of the diff sees it")

## What it ignores

- What a CI script already enforces: `Scripts/lint.sh`; `Scripts/count-tests.sh`, which fails the
  `test` job unless every test method of the sources ran and passed;
  `Scripts/check-example-results.sh`, which does the same for the example and decides its skips by
  device; and the coverage floor of `Scripts/coverage-gate.sh`, so the percentage of covered lines
  is not a finding.
- The design of the production code: that is the lane architecture-and-dependencies.
- How the library behaves, and what the HUD tells assistive technology: those are the lanes
  correctness-and-concurrency and accessibility-and-ui-integration.
- The class of a change and its documentation: that is the lane public-api-and-documentation.
