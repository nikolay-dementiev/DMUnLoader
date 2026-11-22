#!/bin/bash
#
# Runs the example's tests on one simulator, or on two at once (--second-simulator): the
# app-hosted tests, then the UI tests group by group, with the example app uninstalled before
# each group.
#
#   Scripts/test-example.sh [--second-simulator <udid>] [--sequential] <simulator udid> [<results dir>]
#   Scripts/test-example.sh --build [<results dir>]
#   Scripts/test-example.sh --no-build [--second-simulator <udid>] [--sequential] <simulator udid> [<results dir>]
#
# The first form builds the example for that simulator and runs the tests. The other two do the
# same in two steps, so that a build can run while a simulator boots: --build builds for the generic
# simulator destination, one architecture, and touches no simulator; --no-build runs the tests of a
# build that --build made.
#
# With --second-simulator the runs share two simulators of one family and go in parallel: the
# SwiftUI group, the longest, has the first simulator to itself, and the app-hosted tests and the
# other groups follow one another on the second. Two groups never share a simulator at the same
# time, for the reason given under "Why the groups", so two simulators are the one way to overlap
# them. --sequential runs everything on the first simulator, one run after the other, though a
# second one is given.
#
# Why the groups: the example is one app that starts in several integration modes. A launch
# that ends with the app in the background leaves its scene session saved, and the next
# launch restores that session with the scene delegate of the earlier mode. Measured on
# iOS 26.5: UIKit does not ask the app delegate for the configuration of a restored session,
# and an iPhone app cannot destroy it ("The current device does not support multiple
# scenes"), so a UIKit launch after a SwiftUI one can show no screen at all. Uninstalling the
# app removes the saved session. Each group launches the modes of one scene-delegate class.
#
# When the last group has run, Scripts/check-example-results.sh checks that the runs together hold
# every test of the example's sources and skipped only the tests that may skip on that device:
# on an iPad none, so an iPad whose system declines a second scene fails here.
#
# Exit codes: 0 every run passed, 1 a build or a test run failed, a run left no readable
# result with a test in it, or the check of the results failed, 2 the runs could not be set up
# (an unknown simulator, a UI test class outside the groups, a grouped class that does not
# exist, an uninstall that fails, a simulator that does not boot, a second simulator that is the
# first again, unknown or of another family, --no-build without a build to run).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# all: build for the simulator and run. build: build only. run: run an existing build.
MODE=all
SECOND_UDID=""
SEQUENTIAL=no
while [ "$#" -gt 0 ]; do
    case "$1" in
        --build) MODE=build; shift ;;
        --no-build) MODE=run; shift ;;
        --second-simulator) SECOND_UDID="${2:?give the udid of the second simulator}"; shift 2 ;;
        --sequential) SEQUENTIAL=yes; shift ;;
        *) break ;;
    esac
done
if [ "$MODE" = build ]; then
    if [ -n "$SECOND_UDID" ]; then
        echo "test-example: --build touches no simulator, so --second-simulator has no use with it." >&2
        exit 2
    fi
    RESULTS="${1:-$ROOT/.build/results/example}"
else
    UDID="${1:?give the udid of a simulator}"
    RESULTS="${2:-$ROOT/.build/results/example}"
fi

# The state of the simulator with the udid in $UDID, or nothing when no simulator has it.
simulator_state() {
    xcrun simctl list devices -j | python3 -c '
import json, sys
for devices in json.load(sys.stdin)["devices"].values():
    for device in devices:
        if device["udid"] == sys.argv[1]:
            print(device["state"])
' "$UDID"
}

# The simulators are checked before anything is built, installed or uninstalled. A build alone
# needs none.
if [ "$MODE" != build ] && [ -z "$(simulator_state)" ]; then
    echo "test-example: no simulator with the udid $UDID" >&2
    exit 2
fi
if [ -n "$SECOND_UDID" ] && [ -z "$(UDID="$SECOND_UDID" simulator_state)" ]; then
    echo "test-example: no simulator with the udid $SECOND_UDID" >&2
    exit 2
fi
PROJECT="$ROOT/Examples/DMUnLoaderExample/DMUnLoaderExample.xcodeproj"
SCHEME="DMUnLoaderExample"
APP_ID="com.dmunloader.example.app"
UI_TESTS="$ROOT/Examples/DMUnLoaderExample/UITests"
DERIVED="$ROOT/.build/example"
PACKAGES="$ROOT/.build/example-packages"

# One group per scene-delegate class that a saved session would restore: the SwiftUI path
# with or without a custom manager, and with --injected (SwiftUI.AppSceneDelegate), --uikit
# (DMSceneDelegateTypeUIKit) and --uikit --custom-manager (DMSceneDelegateUIKit).
# The tests of the UI test helpers launch no app, so they run in the first group.
TEST_GROUPS=(
    "swiftui|AccessibilityAuditRetryTests HUDAccessibilityUITests HUDAccessibleAppearanceUITests HUDAppearanceUITests HUDControlsUITests HUDLanguageUITests HUDTouchRoutingUITests InjectedManagerUITests SettledFrameTests"
    "uikit|HUDTouchRoutingUIKitUITests"
    "uikit-custom-manager|HUDControlsUIKitCustomManagerUITests"
)

# A UI test class that no group names would run outside this order, and a grouped class
# that does not exist would run no test at all. A declaration may follow an attribute on the
# same line. A test class with a base class of its own would escape this check, so it is
# refused.
CLASSES="$(find "$UI_TESTS" -name '*.swift' -exec grep -hoE '(^|[^A-Za-z0-9_])class +[A-Za-z0-9_]+ *: *[A-Za-z0-9_.]+' {} + \
    | sed -E 's/.*class +([A-Za-z0-9_]+) *: *([A-Za-z0-9_.]+).*/\1 \2/')"
INDIRECT="$(awk '$2 != "XCTestCase" { print $1 }' <<< "$CLASSES" | sort -u | tr '\n' ' ')"
if [ -n "${INDIRECT// /}" ]; then
    echo "test-example: UI test classes that do not derive from XCTestCase directly: ${INDIRECT}- the groups cannot see them." >&2
    exit 2
fi
DECLARED="$(awk '$2 == "XCTestCase" { print $1 }' <<< "$CLASSES" | sort -u)"
GROUPED="$(for group in "${TEST_GROUPS[@]}"; do tr ' ' '\n' <<< "${group#*|}"; done | sort -u)"
STRAYS="$(comm -23 <(echo "$DECLARED") <(echo "$GROUPED") | tr '\n' ' ')"
MISSING="$(comm -13 <(echo "$DECLARED") <(echo "$GROUPED") | tr '\n' ' ')"
if [ -n "${STRAYS// /}" ]; then
    echo "test-example: UI test classes in no group: ${STRAYS}- add each to the group of its scene-delegate class." >&2
fi
if [ -n "${MISSING// /}" ]; then
    echo "test-example: grouped classes that do not exist: $MISSING" >&2
fi
if [ -n "${STRAYS// /}" ] || [ -n "${MISSING// /}" ]; then
    exit 2
fi

mkdir -p "$RESULTS"
FAILED=0
# The runs in the order of a single simulator: the app-hosted tests, then the groups. A run named
# ui-<group> is the group of that name.
RUNS=(app-hosted)
for group in "${TEST_GROUPS[@]}"; do
    RUNS+=("ui-${group%%|*}")
done
# The bundles of the runs, for the check of the results at the end.
RAN_BUNDLES=()
for run in "${RUNS[@]}"; do
    RAN_BUNDLES+=("$RESULTS/$run.xcresult")
done

# phone or pad: the family of the simulator with the udid, from its device type.
device_family() {
    xcrun simctl list devices -j | python3 -c '
import json, sys
for devices in json.load(sys.stdin)["devices"].values():
    for device in devices:
        if device["udid"] == sys.argv[1]:
            print("pad" if "iPad" in device["deviceTypeIdentifier"] else "phone")
' "$UDID"
}

# The summary line of a result bundle. It fails when the bundle cannot be read or holds no test.
summary() {
    xcrun xcresulttool get test-results summary --path "$1" 2> /dev/null | python3 -c '
import json, sys
d = json.load(sys.stdin)
if d["totalTestCount"] == 0:
    sys.exit(1)
print("{} tests, {} passed, {} failed, {} skipped".format(d["totalTestCount"], d["passedTests"], d["failedTests"], d["skippedTests"]))
' 2> /dev/null
}

# Runs the built tests that the -only-testing arguments name into <results>/<name>.xcresult.
run_tests() {
    local name="$1"
    shift
    local bundle="$RESULTS/$name.xcresult"
    rm -rf "$bundle"
    local status=0
    xcodebuild test-without-building \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "id=$UDID" \
        -derivedDataPath "$DERIVED" \
        -clonedSourcePackagesDirPath "$PACKAGES" \
        -skipPackagePluginValidation \
        "$@" \
        -resultBundlePath "$bundle" \
        > "$RESULTS/$name.log" 2>&1 || status=$?
    local counts
    if [ "$status" -ne 0 ]; then
        echo "test-example: $name: FAILED (xcodebuild exit $status), $(summary "$bundle" || echo "no readable test results"). See ${RESULTS#"$ROOT"/}/$name.log" >&2
        FAILED=1
    elif counts="$(summary "$bundle")"; then
        echo "test-example: $name: passed, $counts"
    else
        echo "test-example: $name: FAILED, the result bundle is unreadable or holds no test. See ${RESULTS#"$ROOT"/}/$name.log" >&2
        FAILED=1
    fi
}

# Boots the simulator when it is not running: simctl uninstalls only from a running device.
boot() {
    if [ "$(simulator_state)" != "Booted" ] && ! xcrun simctl bootstatus "$UDID" -b > /dev/null; then
        echo "test-example: the simulator $UDID did not boot." >&2
        exit 2
    fi
}

# Removes the example app, and with it the scene session that an earlier run may have saved.
# The argument names the run in the message.
uninstall_example() {
    boot
    if ! xcrun simctl uninstall "$UDID" "$APP_ID"; then
        echo "test-example: the example app could not be uninstalled before $1." >&2
        exit 2
    fi
}

if [ "$MODE" = run ]; then
    if ! compgen -G "$DERIVED/Build/Products/*.xctestrun" > /dev/null; then
        echo "test-example: no build to run in ${DERIVED#"$ROOT"/}. Run Scripts/test-example.sh --build first." >&2
        exit 2
    fi
else
    # A build alone has no simulator, so it builds for the generic destination. That destination
    # compiles every architecture unless one is named, which doubles the compile time.
    DESTINATION="generic/platform=iOS Simulator"
    ARCH_ARGUMENTS=(ARCHS=arm64)
    if [ "$MODE" = all ]; then
        DESTINATION="id=$UDID"
        ARCH_ARGUMENTS=()
    fi
    if ! xcodebuild build-for-testing \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -derivedDataPath "$DERIVED" \
        -clonedSourcePackagesDirPath "$PACKAGES" \
        -onlyUsePackageVersionsFromResolvedFile \
        -skipPackagePluginValidation \
        ${ARCH_ARGUMENTS[@]+"${ARCH_ARGUMENTS[@]}"} \
        > "$RESULTS/build-for-testing.log" 2>&1; then
        echo "test-example: the build for testing failed. See ${RESULTS#"$ROOT"/}/build-for-testing.log" >&2
        grep -E "error:" "$RESULTS/build-for-testing.log" | sort -u | head -20 >&2 || true
        exit 1
    fi
    echo "test-example: built for testing."
    if [ "$MODE" = build ]; then
        exit 0
    fi
fi

# Makes the run named $1 on the simulator in $UDID, after the uninstall of the app.
run_one() {
    local run="$1" group class
    local -a arguments=()
    if [ "$run" = app-hosted ]; then
        uninstall_example "the app-hosted tests"
        run_tests app-hosted -only-testing:DMUnLoaderExampleTests
        return 0
    fi
    for group in "${TEST_GROUPS[@]}"; do
        [ "ui-${group%%|*}" = "$run" ] || continue
        uninstall_example "the group ${group%%|*}"
        for class in ${group#*|}; do
            arguments+=("-only-testing:DMUnLoaderExampleUITests/$class")
        done
        run_tests "$run" "${arguments[@]}"
    done
}

# Makes the runs that follow the udid, one after the other, on that simulator. The helpers read
# $UDID, which the local one shadows; a failed run sets FAILED.
run_lane() {
    # shellcheck disable=SC2034 # read by simulator_state, boot, uninstall_example and run_tests
    local UDID="$1" run
    shift
    for run in "$@"; do
        run_one "$run"
    done
}

if [ -n "$SECOND_UDID" ] && [ "$SEQUENTIAL" = no ]; then
    if [ "$SECOND_UDID" = "$UDID" ]; then
        echo "test-example: --second-simulator names the first simulator again." >&2
        exit 2
    fi
    # The check of the results reads one family, so the two simulators have to be of one.
    if [ "$(device_family)" != "$(UDID="$SECOND_UDID" device_family)" ]; then
        echo "test-example: the two simulators are not of one family (phone or pad)." >&2
        exit 2
    fi
    # The SwiftUI group is the longest, so it has a simulator to itself.
    SECOND_RUNS=()
    for run in "${RUNS[@]}"; do
        [ "$run" = ui-swiftui ] || SECOND_RUNS+=("$run")
    done
    if [ "${#SECOND_RUNS[@]}" -ne $((${#RUNS[@]} - 1)) ]; then
        echo "test-example: there is no ui-swiftui run to give a simulator of its own." >&2
        exit 2
    fi
    echo "test-example: two simulators at once: $UDID runs ui-swiftui, $SECOND_UDID runs ${SECOND_RUNS[*]}."
    (run_lane "$UDID" ui-swiftui; exit "$FAILED") &
    first=$!
    (run_lane "$SECOND_UDID" "${SECOND_RUNS[@]}"; exit "$FAILED") &
    second=$!
    status_first=0
    status_second=0
    wait "$first" || status_first=$?
    wait "$second" || status_second=$?
    for status in "$status_first" "$status_second"; do
        case "$status" in
            0) ;;
            1) FAILED=1 ;;
            *) exit "$status" ;;
        esac
    done
else
    run_lane "$UDID" "${RUNS[@]}"
fi

# Every test of the sources ran, and only the tests that may skip on this device skipped.
if ! "$ROOT/Scripts/check-example-results.sh" "$(device_family)" "${RAN_BUNDLES[@]}"; then
    FAILED=1
fi

exit "$FAILED"
