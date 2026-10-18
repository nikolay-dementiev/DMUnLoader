#!/bin/bash
#
# Checks that the runs of the example's tests held every test of its sources, and skipped only
# the tests that may skip on that device.
#
#   Scripts/check-example-results.sh <results dir> <phone|pad>   check the .xcresult bundles in a folder
#   Scripts/check-example-results.sh --self-test                 run the reader on built-in texts
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
# made (python3 is missing, a name in TWO_SCENE_TESTS is not a test of the sources, or the
# folder holds no bundle).

set -euo pipefail

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


def bundle(name, results, **summary_overrides):
    """The three arguments of a bundle: its name and the paths of its summary and its tests.

    results lists (test name, result). The summary counts follow it, unless overridden."""
    counts = {"Passed": 0, "Skipped": 0, "Failed": 0}
    for _, result in results:
        counts[result] = counts.get(result, 0) + 1
    summary = {"totalTestCount": len(results), "passedTests": counts["Passed"],
               "failedTests": counts["Failed"], "skippedTests": counts["Skipped"]}
    summary.update(summary_overrides)
    cases = [{"nodeType": "Test Case", "name": test + "()", "result": result} for test, result in results]
    tests = {"testNodes": [{"nodeType": "Unit test bundle", "name": "Bundle", "children": cases}]}
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
echo "usage: Scripts/check-example-results.sh <results dir> <phone|pad> | --self-test" >&2
exit 2
