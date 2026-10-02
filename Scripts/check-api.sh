#!/bin/bash
#
# Compares the public interface of the library with the committed baseline.
#
#   Scripts/check-api.sh            compare, exit 1 on any difference
#   Scripts/check-api.sh --update   rewrite the baseline from the current sources
#
# Any difference fails. A removed or changed line is a break of the public contract.
# An added line is new public API: run with --update and commit the baseline together
# with the change, so the whole API delta is readable in the diff of one file.
#
# The interface text depends on the compiler and the SDK. CI runs this check on one
# pinned Xcode; after a toolchain change the baseline may need --update with no API change.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE="DMUnLoader"
BASELINE="$ROOT/Fixtures/API/public-interface.txt"
WORK="$ROOT/.build/check-api"
DEPENDENCIES="$WORK/dependencies"
INTERFACE="$WORK/$MODULE.swiftinterface"
CURRENT="$WORK/public-interface.txt"
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
TARGET="arm64-apple-ios17.0-simulator"

mkdir -p "$DEPENDENCIES"

if [ ! -d "$ROOT/.build/checkouts/DMAction" ] || [ ! -d "$ROOT/.build/checkouts/DMVariableBlurView" ]; then
    swift package --package-path "$ROOT" resolve > "$WORK/resolve.log" 2>&1
fi

swift_files() {
    find "$1" -name '*.swift' | sort
}

# The interface names types of the two dependencies, so their modules are emitted first.
emit_dependency() {
    local name="$1" directory="$2" files=()
    while IFS= read -r file; do
        files+=("$file")
    done < <(swift_files "$directory")
    if ! xcrun --sdk iphonesimulator swiftc \
        -target "$TARGET" -sdk "$SDK" \
        -module-name "$name" -swift-version 6 -parse-as-library \
        -emit-module -emit-module-path "$DEPENDENCIES/$name.swiftmodule" \
        "${files[@]}" > "$WORK/$name.log" 2>&1; then
        echo "check-api: the dependency $name does not compile. See ${WORK#"$ROOT"/}/$name.log" >&2
        exit 2
    fi
}

emit_dependency DMAction "$ROOT/.build/checkouts/DMAction/Sources"
emit_dependency DMVariableBlurView "$ROOT/.build/checkouts/DMVariableBlurView/Sources/DMVariableBlurView"

SOURCES=()
while IFS= read -r file; do
    SOURCES+=("$file")
done < <(swift_files "$ROOT/Sources/$MODULE")

# The package cannot be built for the host, so the compiler is called for the simulator.
# It is called directly: the emitted text is the complete interface, and no build system
# setting can change what is compared.
if ! xcrun --sdk iphonesimulator swiftc \
    -target "$TARGET" -sdk "$SDK" \
    -module-name "$MODULE" -package-name "$MODULE" \
    -swift-version 6 -parse-as-library \
    -I "$DEPENDENCIES" \
    -emit-module -emit-module-path "$WORK/$MODULE.swiftmodule" \
    -emit-module-interface-path "$INTERFACE" \
    -no-verify-emitted-module-interface \
    "${SOURCES[@]}" > "$WORK/swiftc.log" 2>&1; then
    echo "check-api: the library does not compile. See ${WORK#"$ROOT"/}/swiftc.log" >&2
    grep -E "error:" "$WORK/swiftc.log" | sort -u | head -20 >&2 || true
    exit 2
fi

# Header comments carry the compiler version and flags. Plain imports are not API;
# the re-export of DMAction starts with an attribute and stays in the text.
grep -v -E '^(//|import )' "$INTERFACE" > "$CURRENT"

if [ "${1:-}" = "--update" ]; then
    mkdir -p "$(dirname "$BASELINE")"
    cp "$CURRENT" "$BASELINE"
    echo "check-api: baseline updated: ${BASELINE#"$ROOT"/}"
    exit 0
fi

if [ ! -f "$BASELINE" ]; then
    echo "check-api: no baseline at ${BASELINE#"$ROOT"/}. Run with --update." >&2
    exit 2
fi

if diff -u "$BASELINE" "$CURRENT" > "$WORK/api.diff"; then
    echo "check-api: the public interface matches the baseline."
    exit 0
fi

echo "check-api: the public interface differs from the baseline." >&2
echo "  '-' lines were removed or changed: that breaks the public contract." >&2
echo "  '+' lines are new public API: run Scripts/check-api.sh --update and commit the baseline." >&2
cat "$WORK/api.diff" >&2
exit 1
