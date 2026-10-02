#!/bin/bash
#
# Proves that installing the example deletes nothing outside the example folder.
#
#   Scripts/check-example-install.sh    exit 0 when the helper is contained, 1 when it is not
#
# The Podfile's cleanup helper runs with an isolated home directory. A marker file under that
# home's Xcode DerivedData folder has to survive the run.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT/Examples/DMUnLoaderPodSPMExample/podInstall_helper.rb"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

MARKER="$SANDBOX/Library/Developer/Xcode/DerivedData/another-project/marker"
mkdir -p "$(dirname "$MARKER")" "$SANDBOX/work"
: > "$MARKER"

# The helper expands "~" itself. Stop unless Ruby resolves it inside the sandbox, so a
# broken isolation can never reach the real home directory.
RESOLVED="$(HOME="$SANDBOX" ruby -e 'print File.expand_path("~/Library/Developer/Xcode/DerivedData")')"
case "$RESOLVED" in
    "$SANDBOX"/*) ;;
    *)
        echo "check-example-install: the home directory is not isolated ($RESOLVED)." >&2
        exit 2
        ;;
esac

(
    cd "$SANDBOX/work"
    HOME="$SANDBOX" ruby -e 'require ARGV[0]; clean_xcode_project("DMUnLoaderPodSPMExample")' "$HELPER"
) > "$SANDBOX/helper.log" 2>&1 || true

if [ -f "$MARKER" ]; then
    echo "check-example-install: nothing outside the example folder was deleted."
    exit 0
fi

echo "check-example-install: the install helper deleted files under ~/Library/Developer/Xcode/DerivedData." >&2
exit 1
