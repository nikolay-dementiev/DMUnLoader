#!/bin/bash
#
# Checks what a consumer of the package gets.
#
#   Scripts/check-manifest.sh
#
# Fixtures/Consumer builds in Swift 6 and in Swift 5 language mode, and its own sources
# compile without a warning. It uses the released API and the README samples, so if it
# stops building, a consumer's code stops building.
#
# The checks of the manifest itself (no plugin, no dependency by branch, resolution by
# version) join this script in the commits that make the manifest pass them.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$ROOT/.build/check-manifest"
FAILED=0

mkdir -p "$WORK"

# A fresh build folder every run, so a product of an older build cannot hide a failure.
# The fetched dependencies are kept between runs.
find "$WORK" -maxdepth 1 -name 'DerivedData.*' -exec rm -rf {} +
DERIVED="$(mktemp -d "$WORK/DerivedData.XXXXXX")"

for scheme in ConsumerSwift6 ConsumerSwift5; do
    LOG="$WORK/$scheme.log"
    if ! xcodebuild build \
        -workspace "$ROOT/Fixtures/Consumer/.swiftpm/xcode/package.xcworkspace" \
        -scheme "$scheme" \
        -sdk iphonesimulator \
        -destination 'generic/platform=iOS Simulator' \
        -derivedDataPath "$DERIVED" \
        -clonedSourcePackagesDirPath "$WORK/SourcePackages" \
        -skipPackagePluginValidation \
        ARCHS=arm64 ONLY_ACTIVE_ARCH=NO \
        > "$LOG" 2>&1; then
        echo "check-manifest: $scheme does not build. See ${LOG#"$ROOT"/}" >&2
        grep -E "error:" "$LOG" | sort -u | head -20 >&2 || true
        FAILED=1
    elif grep -E "Fixtures/Consumer/Sources/.*warning:" "$LOG" | sort -u > "$WORK/$scheme.warnings" \
        && [ -s "$WORK/$scheme.warnings" ]; then
        echo "check-manifest: $scheme builds, but a consumer's code gets warnings:" >&2
        sed "s|$ROOT/||" "$WORK/$scheme.warnings" | head -20 >&2
        FAILED=1
    else
        echo "check-manifest: $scheme builds against this checkout without a warning."
    fi
done

exit "$FAILED"
