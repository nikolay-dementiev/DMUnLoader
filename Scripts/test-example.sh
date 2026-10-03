#!/bin/bash
#
# Runs the example's tests on one simulator: the app-hosted tests, then the UI tests group
# by group, with the example app uninstalled before each group.
#
#   Scripts/test-example.sh <simulator udid> [<results dir>]
#
# Why the groups: the example is one app that starts in several integration modes. A launch
# that ends with the app in the background leaves its scene session saved, and the next
# launch restores that session with the scene delegate of the earlier mode. Measured on
# iOS 26.5: UIKit does not ask the app delegate for the configuration of a restored session,
# and an iPhone app cannot destroy it ("The current device does not support multiple
# scenes"), so a UIKit launch after a SwiftUI one can show no screen at all. Uninstalling the
# app removes the saved session. Each group launches the modes of one scene-delegate class.
#
# Exit codes: 0 every run passed, 1 a build or a test run failed, 2 the runs could not be
# set up (a UI test class outside the groups, a grouped class that does not exist, an
# unknown simulator, an uninstall that fails).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UDID="${1:?give the udid of a simulator}"
RESULTS="${2:-$ROOT/.build/results/example}"
PROJECT="$ROOT/Examples/DMUnLoaderExample/DMUnLoaderExample.xcodeproj"
SCHEME="DMUnLoaderExample"
APP_ID="com.dmunloader.example.app"
UI_TESTS="$ROOT/Examples/DMUnLoaderExample/UITests"
DERIVED="$ROOT/.build/example"
PACKAGES="$ROOT/.build/example-packages"

# One group per scene-delegate class that a saved session would restore: the SwiftUI path
# with or without a custom manager (SwiftUI.AppSceneDelegate), --uikit
# (DMSceneDelegateTypeUIKit) and --uikit --custom-manager (DMSceneDelegateUIKit).
TEST_GROUPS=(
    "swiftui|HUDAppearanceUITests HUDControlsUITests HUDTouchRoutingUITests"
    "uikit|HUDTouchRoutingUIKitUITests"
    "uikit-custom-manager|HUDControlsUIKitCustomManagerUITests"
)

# A UI test class that no group names would run outside this order, and a grouped class
# that does not exist would run no test at all.
DECLARED="$(grep -hoE '^(final )?class [A-Za-z0-9_]+: XCTestCase' "$UI_TESTS"/*.swift \
    | sed -E 's/.*class ([A-Za-z0-9_]+):.*/\1/' | sort -u)"
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

summary() {
    xcrun xcresulttool get test-results summary --path "$1" 2> /dev/null | python3 -c '
import json, sys
d = json.load(sys.stdin)
print("{} tests, {} passed, {} failed, {} skipped".format(d["totalTestCount"], d["passedTests"], d["failedTests"], d["skippedTests"]))
' 2> /dev/null || echo "no test results"
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
    if [ "$status" -eq 0 ]; then
        echo "test-example: $name: passed, $(summary "$bundle")"
    else
        echo "test-example: $name: FAILED (xcodebuild exit $status), $(summary "$bundle"). See ${RESULTS#"$ROOT"/}/$name.log" >&2
        FAILED=1
    fi
}

# simctl uninstalls only from a running device.
boot() {
    local state
    state="$(xcrun simctl list devices -j | python3 -c '
import json, sys
for devices in json.load(sys.stdin)["devices"].values():
    for device in devices:
        if device["udid"] == sys.argv[1]:
            print(device["state"])
' "$UDID")"
    case "$state" in
        Booted) ;;
        "") echo "test-example: no simulator with the udid $UDID" >&2; exit 2 ;;
        *) xcrun simctl bootstatus "$UDID" -b > /dev/null ;;
    esac
}

if ! xcodebuild build-for-testing \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "id=$UDID" \
    -derivedDataPath "$DERIVED" \
    -clonedSourcePackagesDirPath "$PACKAGES" \
    -onlyUsePackageVersionsFromResolvedFile \
    -skipPackagePluginValidation \
    > "$RESULTS/build-for-testing.log" 2>&1; then
    echo "test-example: the build for testing failed. See ${RESULTS#"$ROOT"/}/build-for-testing.log" >&2
    grep -E "error:" "$RESULTS/build-for-testing.log" | sort -u | head -20 >&2 || true
    exit 1
fi
echo "test-example: built for testing."

run_tests app-hosted -only-testing:DMUnLoaderExampleTests

for group in "${TEST_GROUPS[@]}"; do
    name="${group%%|*}"
    boot
    # Removes the scene session that the previous run may have left saved.
    if ! xcrun simctl uninstall "$UDID" "$APP_ID"; then
        echo "test-example: the example app could not be uninstalled before the group $name." >&2
        exit 2
    fi
    arguments=()
    for class in ${group#*|}; do
        arguments+=("-only-testing:DMUnLoaderExampleUITests/$class")
    done
    run_tests "ui-$name" "${arguments[@]}"
done

exit "$FAILED"
