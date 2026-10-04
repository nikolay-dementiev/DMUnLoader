#!/bin/bash
#
# Lints the podspec in every language mode it declares and checks what a consumer gets.
#
#   Scripts/check-podspec.sh
#
# The lint builds a consumer app around the pod. The script then reads what CocoaPods made
# for that app:
#
# - its build configuration: a test framework in it means that the pod makes its consumers
#   link test code;
# - the built app: it must carry the resource bundle of the pod with the compiled string
#   table, every key of Sources/DMUnLoader/Resources/Localizable.xcstrings in it, because the
#   library reads its default texts from there.
#
# CocoaPods runs with a home folder of its own under .build, so the index of the trunk is
# fetched anew and nothing in the home folder of the machine changes. The lint builds into
# the default DerivedData; the script removes the one folder there that records the
# consumer of this run as its workspace, and no other. It installs nothing. It needs
# CocoaPods on the machine.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PODSPEC="$ROOT/DMUnLoader.podspec"
CATALOG="$ROOT/Sources/DMUnLoader/Resources/Localizable.xcstrings"
WORK="$ROOT/.build/check-podspec"
FAILED=0

# CocoaPods stops in a locale that is not UTF-8.
export LANG=en_US.UTF-8
export CP_HOME_DIR="$WORK/cocoapods-home"

if ! command -v pod > /dev/null; then
    echo "check-podspec: CocoaPods is not installed." >&2
    exit 2
fi

mkdir -p "$WORK" "$CP_HOME_DIR"

MODES="$(pod ipc spec "$PODSPEC" | python3 -c '
import json, sys
modes = json.load(sys.stdin).get("swift_versions", [])
print(" ".join([modes] if isinstance(modes, str) else modes))
')"
if [ -z "$MODES" ]; then
    echo "check-podspec: the podspec declares no swift_versions." >&2
    exit 1
fi

# Removes the DerivedData folder of a consumer workspace, when Xcode recorded exactly that
# workspace in it.
remove_derived_data() {
    local workspace="$1" products="$2" folder recorded
    folder="${products%/Build/Products/*}"
    case "$folder" in
        */DerivedData/App-*) ;;
        *) return 0 ;;
    esac
    recorded="$(plutil -extract WorkspacePath raw -o - "$folder/info.plist" 2> /dev/null || true)"
    if [ "$recorded" = "$workspace" ]; then
        rm -rf "$folder"
    fi
}

for MODE in $MODES; do
    LOG="$WORK/lint-swift$MODE.log"
    if ! pod lib lint "$PODSPEC" --platforms=ios --swift-version="$MODE" --no-clean --verbose > "$LOG" 2>&1; then
        echo "check-podspec: pod lib lint fails in Swift $MODE mode. See ${LOG#"$ROOT"/}" >&2
        grep -E "ERROR|WARN|error:" "$LOG" | head -20 >&2 || true
        FAILED=1
        continue
    fi

    # --no-clean keeps the consumer app that the lint built, and the log says where.
    WORKSPACE="$(sed -n 's/^Pods workspace available at `\(.*\)` for inspection\.$/\1/p' "$LOG" | tail -1)"
    CONSUMER="$(dirname "$WORKSPACE")"
    if [ -z "$WORKSPACE" ] || [ ! -d "$CONSUMER/Pods/Target Support Files" ]; then
        echo "check-podspec: the consumer app of the Swift $MODE lint was not found." >&2
        FAILED=1
        continue
    fi

    # grep exits 1 when nothing matches, and 2 when it cannot read what it searches. Its
    # output is kept in a variable: a file that cannot be written would end the command
    # before grep runs, with the status of "nothing matches".
    SEARCH=0
    MATCHES="$(grep -r -l "XCTest" "$CONSUMER/Pods/Target Support Files")" || SEARCH=$?
    case "$SEARCH" in
        0)
            echo "check-podspec: in Swift $MODE mode a consumer of the pod links XCTest:" >&2
            printf '%s\n' "$MATCHES" | sed "s#^$CONSUMER/##" >&2
            FAILED=1
            ;;
        1)
            echo "check-podspec: in Swift $MODE mode the pod passes the lint and links no test framework."
            ;;
        *)
            echo "check-podspec: cannot search the build configuration of the Swift $MODE consumer in $CONSUMER." >&2
            exit 2
            ;;
    esac

    PRODUCTS="$(xcodebuild -showBuildSettings -workspace "$WORKSPACE" -scheme App \
        -configuration Release -sdk iphonesimulator 2> /dev/null \
        | sed -n 's/^ *BUILT_PRODUCTS_DIR = //p' | head -1)"
    BUNDLE="$(find "$PRODUCTS/App.app" -type d -name "DMUnLoader.bundle" 2> /dev/null | head -1)"
    if [ -z "$BUNDLE" ]; then
        echo "check-podspec: in Swift $MODE mode the consumer app carries no DMUnLoader.bundle." >&2
        FAILED=1
    elif ! python3 - "$CATALOG" "$BUNDLE/en.lproj/Localizable.strings" <<'PY'
import json
import plistlib
import sys

catalog, table = sys.argv[1], sys.argv[2]
keys = set(json.load(open(catalog, encoding="utf-8"))["strings"])
try:
    with open(table, "rb") as file:
        compiled = set(plistlib.load(file))
except (OSError, plistlib.InvalidFileException) as error:
    sys.exit(f"check-podspec: the bundle has no readable English table: {error}")
missing = sorted(keys - compiled)
if missing:
    sys.exit(f"check-podspec: the English table of the bundle lacks {', '.join(missing)}")
PY
    then
        FAILED=1
    else
        echo "check-podspec: in Swift $MODE mode the consumer app carries DMUnLoader.bundle with every key of the string catalog."
    fi

    remove_derived_data "$WORKSPACE" "$PRODUCTS"
    rm -rf "$CONSUMER"
done

exit "$FAILED"
