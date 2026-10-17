#!/bin/bash
#
# Lints the repository with one pinned SwiftLint version.
#
#   Scripts/lint.sh                         lint; a warning fails the run
#   Scripts/lint.sh --analyze <build log>   also run the analyzer rules, which need the
#                                           compiler invocations of an xcodebuild log
#
# The tool is fetched once into .build/tools and checked against the pinned checksum
# before it is unpacked. Nothing is installed or upgraded on the machine.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=SCRIPTDIR/swiftlint-tool.sh
. "$ROOT/Scripts/swiftlint-tool.sh"
VERSION="$(swiftlint_version "$ROOT" lint)"
SWIFTLINT="$(swiftlint_fetch "$ROOT" "$VERSION" lint)"

cd "$ROOT"
"$SWIFTLINT" lint --strict --quiet

if [ "${1:-}" = "--analyze" ]; then
    "$SWIFTLINT" analyze --strict --quiet --compiler-log-path "${2:?give the path of an xcodebuild log}"
fi

echo "lint: no violations (SwiftLint $("$SWIFTLINT" version))."
