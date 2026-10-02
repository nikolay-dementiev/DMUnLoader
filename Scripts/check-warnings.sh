#!/bin/bash
#
# Fails when a build log holds a warning that points into this repository's own files.
#
#   Scripts/check-warnings.sh <xcodebuild log>
#
# The build setting that turns warnings into errors cannot be used for this package:
# Xcode builds the dependencies with warnings suppressed, and the compiler refuses the two
# flags together. So the log of the build is checked instead. A warning inside a
# dependency's checkout is not this repository's to fix and does not count.

set -euo pipefail

LOG="${1:?give the path of an xcodebuild log}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$LOG" ]; then
    echo "check-warnings: there is no log at $LOG" >&2
    exit 2
fi

# A diagnostic starts with the file it points to. The build folder inside the checkout
# holds dependency checkouts and generated files, so it is left out.
WARNINGS="$(grep -E "^$ROOT/[^:]+:[0-9]+:[0-9]+: warning:" "$LOG" \
    | grep -v -E "^$ROOT/\.build/" \
    | sort -u || true)"

if [ -z "$WARNINGS" ]; then
    echo "check-warnings: no warning from this repository's files in ${LOG#"$ROOT"/}."
    exit 0
fi

echo "check-warnings: the build reports warnings in this repository's files:" >&2
echo "$WARNINGS" | sed "s|^$ROOT/||" >&2
exit 1
