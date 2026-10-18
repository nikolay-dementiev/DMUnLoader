#!/bin/bash
#
# Checks that the runs of the example's tests held as many tests as its sources have test
# methods, and skipped only the tests that may skip on that device.
#
#   Scripts/check-example-results.sh <phone|pad> <bundle>...   check the runs of one device family
#   Scripts/check-example-results.sh --self-test                run the reader on built-in texts
#
# Scripts/test-example.sh calls it after its last group with the bundles it made, so the example
# job and the run of the release checklist on an iPad use the same check.
#
# A run that lost a test class, or skipped tests, passes the build and the runs of the example
# as they are: Scripts/test-example.sh fails a group only for a bundle that cannot be read or
# holds no test. This check adds three things:
#
# 1. The bundles of the groups together hold exactly the test methods of the example's sources
#    (EXAMPLE_SOURCES), all passed or skipped, none failed.
# 2. On a phone, only the tests in TWO_SCENE_TESTS may skip: a phone gives an app one scene,
#    so they skip there by design. Any other skip fails.
# 3. On an iPad, no test skips, and both TWO_SCENE_TESTS ran and passed, by name. The system
#    can decline a second scene, as the iPadOS 18.6 simulator does, and the tests then skip:
#    that run proves nothing about two scenes, so it fails.
#
# --self-test needs no simulator, no build and no result bundle. A reader that never fails looks
# the same as a clean run, so it takes the python block marked example-results out of this very
# file, the text that the check runs, and runs it on result texts that it carries: fewer or
# more tests than the sources hold, a failed test, a skip that may not happen on a phone or on
# an iPad, the two-scene tests missing on an iPad, a bundle that cannot be read or holds no
# test, and a test that neither passed nor skipped. A reader changed to pass one of these
# fails the self-test. It does not run the shell around the reader.
#
# Exit codes: 0 every check passed, 1 a check failed, 2 wrong usage, or the check could not be
# made (python3 is missing, no bundle is given, or a name in TWO_SCENE_TESTS is not a test of
# the sources).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The folders of the example's test sources, relative to the repository root.
EXAMPLE_SOURCES=(
    "Examples/DMUnLoaderExample/AppTests"
    "Examples/DMUnLoaderExample/UITests"
)
# The tests that skip on a device that gives an app one scene. They need a second scene, which
# an iPad opens: they run there, and the run must show it.
TWO_SCENE_TESTS=(
    "test_secondScene_showsItsOwnHUD_andClosingItRemovesOnlyThatOne"
    "test_injectedRoot_twoScenes_eachHUDJoinsTheSceneOfItsRootView"
)

# Takes the python block that follows the line "# <marker>" out of this script into <output file>:
# the very text that the check runs. The marker must appear once, directly under the line that
# opens the heredoc, so that a line added above it or a second marker cannot make the two differ.
extract_block() {  # <marker> <output file>
    local marker="$1" output="$2" found
    found="$(awk -v marker="# $marker" '$0 == marker { count++; opener = prev } { prev = $0 } END { print count + 0 ":" opener }' "${BASH_SOURCE[0]}")"
    case "$found" in
        "1:"*"<<'PY'") ;;
        *)
            echo "check-example-results: self-test: the marker $marker must appear once, under the line that opens the heredoc of its step (found '$found')" >&2
            exit 2
            ;;
    esac
    awk -v marker="# $marker" '$0 == marker { found = 1 } found && /^PY$/ { exit } found' "${BASH_SOURCE[0]}" > "$output"
    if [ ! -s "$output" ]; then
        echo "check-example-results: self-test: the python block marked $marker is not in ${BASH_SOURCE[0]}" >&2
        exit 2
    fi
}

# Runs the reader on built-in result texts, and exits.
SELF_TEST_WORK=""
self_test() {
    if ! command -v python3 > /dev/null; then
        echo "check-example-results: self-test: python3 is not installed" >&2
        exit 2
    fi
    SELF_TEST_WORK="$(mktemp -d "${TMPDIR:-/tmp}/check-example-results-self-test.XXXXXX")" || exit 2
    trap 'rm -rf "$SELF_TEST_WORK"' EXIT
    extract_block example-results "$SELF_TEST_WORK/reader.py"
    python3 - "$SELF_TEST_WORK/reader.py" "$SELF_TEST_WORK" "${TWO_SCENE_TESTS[@]}" <<'PY'
import json
import os
import subprocess
import sys

reader, work = sys.argv[1:3]
allowed = sys.argv[3:]
first, second = allowed
total_cases = 0
failures = 0


def bundle(name, results, listed=True, parens=True, **summary_overrides):
    """The three arguments of a bundle: its name and the paths of its summary and its tests.

    results lists (test name, result). The summary counts follow it, unless overridden. The list
    of tests nests as xcresulttool prints it: a test plan, a bundle, a suite, the test cases. With
    listed false the list holds the nodes down to the suite and no test case."""
    counts = {"Passed": 0, "Skipped": 0, "Failed": 0}
    for _, result in results:
        counts[result] = counts.get(result, 0) + 1
    summary = {"totalTestCount": len(results), "passedTests": counts["Passed"],
               "failedTests": counts["Failed"], "skippedTests": counts["Skipped"]}
    summary.update(summary_overrides)
    cases = [{"nodeType": "Test Case", "name": test + "()" if parens else test, "result": result}
             for test, result in results]
    suite = {"nodeType": "Test Suite", "name": "Suite", "children": cases if listed else []}
    unit = {"nodeType": "Unit test bundle", "name": "Bundle", "children": [suite]}
    tests = {"testNodes": [{"nodeType": "Test Plan", "name": "Plan", "children": [unit]}]}
    summary_path = os.path.join(work, name + ".summary.json")
    tests_path = os.path.join(work, name + ".tests.json")
    with open(summary_path, "w", encoding="utf-8") as handle:
        json.dump(summary, handle)
    with open(tests_path, "w", encoding="utf-8") as handle:
        json.dump(tests, handle)
    return [name, summary_path, tests_path]


def check(label, family, expected, bundles, status, text):
    global total_cases, failures
    total_cases += 1
    arguments = ["python3", reader, family, str(expected), ",".join(allowed)]
    for entry in bundles:
        arguments += entry
    process = subprocess.run(arguments, capture_output=True, text=True)
    output = process.stdout + process.stderr
    if process.returncode == status and text in output:
        print(f"check-example-results: self-test ok   {label}")
        return
    failures += 1
    print(f"check-example-results: self-test FAIL {label}: expected status {status} and '{text}', got status {process.returncode}:", file=sys.stderr)
    for line in output.splitlines()[:5]:
        print(f"    {line}", file=sys.stderr)


ordinary = [(f"test_ordinary{n}", "Passed") for n in range(4)]
check("a phone: both two-scene tests skipped, the rest passed", "phone", 6,
      [bundle("phone-ok", ordinary + [(first, "Skipped"), (second, "Skipped")])], 0, "6 tests")
check("an iPad: every test passed, both two-scene tests among them", "pad", 6,
      [bundle("pad-ok", ordinary + [(first, "Passed"), (second, "Passed")])], 0, "6 tests")
check("two bundles add up to the tests of the sources", "pad", 6,
      [bundle("one", ordinary[:2] + [(first, "Passed")]), bundle("two", ordinary[2:] + [(second, "Passed")])], 0, "6 tests in 2 bundles")
check("fewer tests than the sources hold", "pad", 7,
      [bundle("few", ordinary + [(first, "Passed"), (second, "Passed")])], 1, "the runs hold 6 tests, the sources of the example hold 7")
check("more tests than the sources hold", "pad", 5,
      [bundle("many", ordinary + [(first, "Passed"), (second, "Passed")])], 1, "the runs hold 6 tests, the sources of the example hold 5")
check("a test failed", "pad", 6,
      [bundle("failed", ordinary[:3] + [("test_broken", "Failed"), (first, "Passed"), (second, "Passed")])], 1, "1 failed")
check("a phone: another test skipped", "phone", 6,
      [bundle("phone-skip", ordinary[:3] + [("test_ordinary3", "Skipped"), (first, "Skipped"), (second, "Skipped")])], 1, "skipped, and may not skip on a phone: test_ordinary3")
check("an iPad: a two-scene test skipped", "pad", 6,
      [bundle("pad-skip", ordinary + [(first, "Skipped"), (second, "Passed")])], 1, f"skipped on an iPad: {first}")
check("an iPad: another test skipped", "pad", 6,
      [bundle("pad-other", ordinary[:3] + [("test_ordinary3", "Skipped"), (first, "Passed"), (second, "Passed")])], 1, "skipped on an iPad: test_ordinary3")
check("an iPad: the two-scene tests are not among the runs", "pad", 6,
      [bundle("pad-missing", ordinary + [("test_other1", "Passed"), ("test_other2", "Passed")])], 1, f"{first} did not run and pass on the iPad")
check("a summary that cannot be read", "pad", 6,
      [["broken", os.path.join(work, "no-such-file.json"), os.path.join(work, "no-such-file.json")]], 1, "broken: the result bundle cannot be read")
check("a bundle that holds no test", "pad", 6,
      [bundle("empty", [])], 1, "empty: the result bundle holds no test")
check("a test that neither passed nor skipped", "pad", 6,
      [bundle("odd", ordinary + [(first, "Passed"), (second, "Passed")], passedTests=5)], 1, "1 tests neither passed nor skipped")
check("a family that is neither phone nor pad", "tablet", 6,
      [bundle("tablet", ordinary + [(first, "Passed"), (second, "Passed")])], 2, "the family must be phone or pad")
check("a phone: the summary counts skipped tests, the list of tests shows none", "phone", 6,
      [bundle("unlisted", ordinary + [(first, "Skipped"), (second, "Skipped")], listed=False)], 1,
      "unlisted: the list of tests holds 0 tests, the summary 6")
check("a phone: the summary counts two skips, the list shows those tests as passed", "phone", 6,
      [bundle("renamed", ordinary + [(first, "Passed"), (second, "Passed")], passedTests=4, skippedTests=2)], 1,
      "renamed: the list of tests holds 0 skipped tests, the summary 2")
check("a phone: a skip in each of two bundles, both of tests that may skip", "phone", 6,
      [bundle("left", ordinary[:2] + [(first, "Skipped")]), bundle("right", ordinary[2:] + [(second, "Skipped")])], 0,
      "6 tests in 2 bundles, 2 skipped")
check("a phone: another test skipped in the first of two bundles", "phone", 6,
      [bundle("left", ordinary[:1] + [("test_ordinary9", "Skipped")]),
       bundle("right", ordinary[1:3] + [(first, "Skipped"), (second, "Skipped")])], 1,
      "skipped, and may not skip on a phone: test_ordinary9")
check("a test failed in the first of two bundles", "pad", 7,
      [bundle("left", ordinary[:1] + [("test_broken", "Failed")]),
       bundle("right", ordinary[1:] + [(first, "Passed"), (second, "Passed")])], 1, "1 failed")
check("an iPad: the second two-scene test failed, the first passed", "pad", 6,
      [bundle("pad-second", ordinary + [(first, "Passed"), (second, "Failed")])], 1,
      f"{second} did not run and pass on the iPad")
check("a summary that can be read and a list of tests that cannot", "pad", 6,
      [bundle("summary-only", ordinary + [(first, "Passed"), (second, "Passed")])[:2] + [os.path.join(work, "no-such-file.json")]], 1,
      "summary-only: the result bundle cannot be read")
check("test names without parentheses", "pad", 6,
      [bundle("bare", ordinary + [(first, "Passed"), (second, "Passed")], parens=False)], 0, "6 tests")

if failures > 0:
    print(f"check-example-results: self-test: {failures} of {total_cases} checks failed", file=sys.stderr)
    sys.exit(1)
print(f"check-example-results: self-test: {total_cases} checks of the reader of the results of the example, all ok.")
PY
    exit "$?"
}

if [ "$#" -eq 1 ] && [ "$1" = "--self-test" ]; then
    self_test
fi
if [ "$#" -lt 2 ]; then
    echo "usage: Scripts/check-example-results.sh <phone|pad> <bundle>... | --self-test" >&2
    exit 2
fi
if ! command -v python3 > /dev/null; then
    echo "check-example-results: python3 is not installed" >&2
    exit 2
fi
FAMILY="$1"
shift

# A name that is not a test of the sources would let a two-scene test vanish unnoticed.
SOURCE_PATHS=()
for source in "${EXAMPLE_SOURCES[@]}"; do
    SOURCE_PATHS+=("$ROOT/$source")
done
for test in "${TWO_SCENE_TESTS[@]}"; do
    if ! grep -rqE --include='*.swift' "func $test\(\)" "${SOURCE_PATHS[@]}"; then
        echo "check-example-results: $test is in TWO_SCENE_TESTS and is not a test of ${EXAMPLE_SOURCES[*]}" >&2
        exit 2
    fi
done
# The test methods of the sources, with an attribute allowed before func, such as @MainActor.
EXPECTED="$(grep -rhE --include='*.swift' '^[[:space:]]*(@[[:alnum:]_]+[[:space:]]+)*func test[[:alnum:]_]*\(\)' "${SOURCE_PATHS[@]}" | wc -l | tr -d ' ')"
ALLOWED="$(IFS=,; echo "${TWO_SCENE_TESTS[*]}")"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/check-example-results.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
ARGUMENTS=()
INDEX=0
for bundle in "$@"; do
    INDEX=$((INDEX + 1))
    # A bundle that cannot be read leaves an empty file, which the reader reports by name.
    xcrun xcresulttool get test-results summary --path "$bundle" > "$WORK/$INDEX.summary.json" 2> /dev/null || : > "$WORK/$INDEX.summary.json"
    xcrun xcresulttool get test-results tests --path "$bundle" > "$WORK/$INDEX.tests.json" 2> /dev/null || : > "$WORK/$INDEX.tests.json"
    ARGUMENTS+=("$(basename "$bundle" .xcresult)" "$WORK/$INDEX.summary.json" "$WORK/$INDEX.tests.json")
done

python3 - "$FAMILY" "$EXPECTED" "$ALLOWED" "${ARGUMENTS[@]}" <<'PY'
# example-results
import json
import sys

family, expected_text, allowed_text = sys.argv[1:4]
if family not in ("phone", "pad"):
    print("check-example-results: the family must be phone or pad", file=sys.stderr)
    sys.exit(2)
expected = int(expected_text)
allowed = [name for name in allowed_text.split(",") if name]
arguments = sys.argv[4:]
bundles = [arguments[index:index + 3] for index in range(0, len(arguments), 3)]


def load(path):
    try:
        with open(path, encoding="utf-8") as handle:
            return json.load(handle)
    except (OSError, ValueError):
        return None


def cases(nodes):
    for node in nodes:
        if node.get("nodeType") == "Test Case":
            yield node
        yield from cases(node.get("children") or [])


problems = []
total = passed = failed = skipped = 0
passed_names = set()
skipped_names = []
for name, summary_path, tests_path in bundles:
    summary, tests = load(summary_path), load(tests_path)
    counts = [summary.get(key) if isinstance(summary, dict) else None
              for key in ("totalTestCount", "passedTests", "failedTests", "skippedTests")]
    if not isinstance(tests, dict) or not all(isinstance(count, int) for count in counts):
        problems.append(f"  {name}: the result bundle cannot be read")
        continue
    if counts[0] == 0:
        problems.append(f"  {name}: the result bundle holds no test")
    # The skips are decided by the names in the list of tests, so the list must hold the tests that
    # the summary counts: a list without its test cases would hide every skip.
    listed = list(cases(tests.get("testNodes") or []))
    listed_skipped = sum(1 for case in listed if case.get("result") == "Skipped")
    if len(listed) != counts[0]:
        problems.append(f"  {name}: the list of tests holds {len(listed)} tests, the summary {counts[0]}")
    if listed_skipped != counts[3]:
        problems.append(f"  {name}: the list of tests holds {listed_skipped} skipped tests, the summary {counts[3]}")
    total, passed, failed, skipped = total + counts[0], passed + counts[1], failed + counts[2], skipped + counts[3]
    for case in listed:
        test = str(case.get("name", ""))
        test = test[:-2] if test.endswith("()") else test
        if case.get("result") == "Passed":
            passed_names.add(test)
        elif case.get("result") == "Skipped":
            skipped_names.append(test)
if total != expected:
    problems.append(f"  the runs hold {total} tests, the sources of the example hold {expected}")
if failed:
    problems.append(f"  {failed} failed")
if passed + skipped + failed != total:
    problems.append(f"  {total - passed - skipped - failed} tests neither passed nor skipped")
if family == "pad":
    for test in skipped_names:
        problems.append(f"  skipped on an iPad: {test}")
    for test in allowed:
        if test not in passed_names:
            problems.append(f"  {test} did not run and pass on the iPad")
else:
    for test in skipped_names:
        if test not in allowed:
            problems.append(f"  skipped, and may not skip on a phone: {test}")
if problems:
    print("check-example-results: the runs of the example do not hold what its sources promise:", file=sys.stderr)
    print("\n".join(problems), file=sys.stderr)
    sys.exit(1)
noun = "bundle" if len(bundles) == 1 else "bundles"
print(f"check-example-results: {total} tests in {len(bundles)} {noun}, {skipped} skipped ({family}).")
PY
