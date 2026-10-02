#!/bin/bash
#
# Fails when a build log holds a warning that points into this repository's own files.
#
#   Scripts/check-warnings.sh <xcodebuild log>    exit 0 with no such warning, 1 with one,
#                                                 2 when the log is not a build of this
#                                                 checkout
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

# A build of this checkout names its files. A log that never does is the wrong log, or
# a build that stopped before it compiled anything, and proves nothing.
if ! grep -q -F "$ROOT/" "$LOG"; then
    echo "check-warnings: ${LOG} never mentions $ROOT; it is not a build of this checkout." >&2
    exit 2
fi

# A diagnostic starts with the file it points to. The path is compared as text, so a
# folder name with characters that mean something in a pattern cannot change the match.
# The build folder inside the checkout holds dependency checkouts and generated files,
# so it is left out.
WARNINGS="$(awk -v root="$ROOT/" '
    index($0, root) == 1 && index($0, root ".build/") != 1 {
        rest = substr($0, length(root) + 1)
        if (rest ~ /^[^:]+:[0-9]+:[0-9]+: warning:/) print rest
    }' "$LOG" | LC_ALL=C sort -u)"

if [ -z "$WARNINGS" ]; then
    echo "check-warnings: no warning from this repository's files in ${LOG#"$ROOT"/}."
    exit 0
fi

echo "check-warnings: the build reports warnings in this repository's files:" >&2
echo "$WARNINGS" >&2
exit 1
