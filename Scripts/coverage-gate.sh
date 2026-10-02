#!/bin/bash
#
# Fails when the line coverage of the library is under the floor.
#
#   Scripts/coverage-gate.sh <result bundle>    a bundle of a test run with -enableCodeCoverage YES
#
# The floor only moves up: raise it in the commit that raises the coverage. It stays a
# little under the measured value, because the count of executable lines differs between
# OS versions.

set -euo pipefail

# Percent of the executable lines of the library target that the tests run.
FLOOR="87.5"
TARGET="DMUnLoader"
# Files left out of the measure: "<path under Sources/<target>/>|<why>". Each one is a
# decision with its reason, never a way to pass the floor. A path that is not in the report
# stops the gate, so an exclusion cannot outlive its file.
EXCLUDED=(
    "PresentationView/Helpers/PreviewRenderOwner.swift|support for the #Preview blocks, which no host runs"
)

BUNDLE="${1:?give the path of an .xcresult bundle}"
if [ ! -d "$BUNDLE" ]; then
    echo "coverage-gate: there is no result bundle at $BUNDLE" >&2
    exit 2
fi

REPORT="$(mktemp)"
ERRORS="$(mktemp)"
trap 'rm -f "$REPORT" "$ERRORS"' EXIT
if ! xcrun xccov view --report --json "$BUNDLE" > "$REPORT" 2> "$ERRORS"; then
    echo "coverage-gate: xccov could not read a coverage report from the bundle." >&2
    echo "  A bundle of a run without -enableCodeCoverage YES has none. xccov said:" >&2
    tail -5 "$ERRORS" >&2
    exit 2
fi

python3 - "$REPORT" "$TARGET" "$FLOOR" ${EXCLUDED[@]+"${EXCLUDED[@]}"} <<'PY'
import json
import sys

report_path, target_name, floor = sys.argv[1], sys.argv[2], float(sys.argv[3])
excluded = dict(entry.split("|", 1) for entry in sys.argv[4:])
with open(report_path) as report_file:
    report = json.load(report_file)

# The library is the target whose product is named after it, with or without an extension.
targets = [t for t in report.get("targets", []) if t.get("name", "").split(".")[0] == target_name]
if not targets:
    names = ", ".join(sorted(t.get("name", "?") for t in report.get("targets", [])))
    print(f"coverage-gate: no target named {target_name} in the report. Targets: {names}", file=sys.stderr)
    sys.exit(2)

covered = sum(t["coveredLines"] for t in targets)
executable = sum(t["executableLines"] for t in targets)
for path, reason in excluded.items():
    files = [f for t in targets for f in t.get("files", [])
             if f.get("path", "").endswith(f"/Sources/{target_name}/{path}")]
    if not files:
        print(f"coverage-gate: the excluded file {path} is not in the report. Remove its exclusion.", file=sys.stderr)
        sys.exit(2)
    for excluded_file in files:
        covered -= excluded_file["coveredLines"]
        executable -= excluded_file["executableLines"]
        print(f"coverage-gate: left out {path} ({excluded_file['executableLines']} lines): {reason}.")
if executable == 0:
    print(f"coverage-gate: the target {target_name} has no executable lines in the report.", file=sys.stderr)
    sys.exit(2)

percent = 100.0 * covered / executable
summary = f"{percent:.2f} % of the lines of {target_name} ({covered} of {executable}), floor {floor:.2f} %"
if percent < floor:
    print(f"coverage-gate: {summary}: under the floor.", file=sys.stderr)
    sys.exit(1)
print(f"coverage-gate: {summary}.")
PY
