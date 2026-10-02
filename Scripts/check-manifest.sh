#!/bin/bash
#
# Checks what a consumer of the package gets.
#
#   Scripts/check-manifest.sh
#
# 1. The manifest has no dependency by branch or revision, uses no plugin on any target
#    and does not read the environment. SwiftPM refuses a version requirement on a package
#    that has an unstable dependency, a build plugin of a dependency runs in every
#    consumer's build, and a manifest that reads the environment describes more than one
#    package.
# 2. A consumer that asks for the package by version resolves it. This runs against a
#    throw-away tagged copy of the tracked files: a consumer that depends on the checkout
#    by path cannot show that failure.
# 3. Fixtures/Consumer builds in Swift 6 and in Swift 5 language mode, and its own sources
#    compile without a warning. It uses the released API and the README samples, so if it
#    stops building, a consumer's code stops building.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE="DMUnLoader"
WORK="$ROOT/.build/check-manifest"
FAILED=0
# The sibling packages DMAction and DMVariableBlurView are required by branch until their
# next releases are tagged. Until then the package cannot be required by version: both
# checks below print that as a warning instead of failing. Requiring the siblings by
# version empties this list.
ALLOWED_BY_BRANCH=(dmaction dmvariableblurview)

mkdir -p "$WORK"

# The copy that the version probe tags lives in a folder this run creates, and leaves with it.
PROBE=""
# shellcheck disable=SC2329  # invoked by the trap below
cleanup() {
    if [ -n "$PROBE" ]; then rm -rf "$PROBE"; fi
}
trap cleanup EXIT

# 1. Static check of the manifest.
swift package --package-path "$ROOT" dump-package > "$WORK/manifest.json"
if ! python3 - "$WORK/manifest.json" "$ROOT/Package.swift" ${ALLOWED_BY_BRANCH[@]+"${ALLOWED_BY_BRANCH[@]}"} <<'PY'
import json
import re
import sys

manifest = json.load(open(sys.argv[1]))
source = open(sys.argv[2]).read()
allowed = set(sys.argv[3:])
problems = []
for dependency in manifest.get("dependencies", []):
    for entries in dependency.values():
        for entry in entries:
            requirement = entry.get("requirement", {})
            for unstable in ("branch", "revision"):
                if unstable not in requirement:
                    continue
                identity = entry.get("identity")
                described = f"dependency '{identity}' is required by {unstable} {requirement[unstable]}"
                if identity in allowed:
                    print(f"check-manifest: warning: {described}, so the package cannot be required by version yet.")
                else:
                    problems.append(described)
for target in manifest.get("targets", []):
    for usage in target.get("pluginUsages") or []:
        problems.append(f"target '{target['name']}' uses a plugin: {json.dumps(usage)}")
if re.search(r"ProcessInfo|getenv|\.environment\b", source):
    problems.append("Package.swift reads the environment")
for problem in problems:
    print(f"check-manifest: {problem}", file=sys.stderr)
sys.exit(1 if problems else 0)
PY
then
    FAILED=1
else
    echo "check-manifest: no unstable requirement beyond the allowed ones, no plugin and no environment switch in Package.swift."
fi

# 2. Resolution by version, against a throw-away copy of the tracked files with a tag.
PROBE="$(mktemp -d "$WORK/version-probe.XXXXXX")"
mkdir -p "$PROBE/package" "$PROBE/consumer/Sources/Probe"
(cd "$ROOT" && git ls-files -z | rsync -a --files-from=- --from0 ./ "$PROBE/package/")
# The probe repository takes nothing from the git configuration of whoever runs this:
# no signing, no hooks, no identity.
probe_git() {
    git -C "$PROBE/package" \
        -c user.name=probe -c user.email=probe@example.invalid \
        -c commit.gpgsign=false -c tag.gpgSign=false -c core.hooksPath=/dev/null \
        "$@"
}
probe_git init -q
probe_git add -A
probe_git commit -q -m probe
probe_git tag 99.0.0
cat > "$PROBE/consumer/Package.swift" <<EOF
// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "Probe",
    platforms: [.iOS(.v17)],
    dependencies: [.package(url: "file://$PROBE/package", from: "99.0.0")],
    targets: [.target(name: "Probe", dependencies: [.product(name: "$MODULE", package: "package")])]
)
EOF
echo "import $MODULE" > "$PROBE/consumer/Sources/Probe/Probe.swift"
if swift package --package-path "$PROBE/consumer" resolve > "$WORK/version-resolution.log" 2>&1; then
    echo "check-manifest: a version requirement on the package resolves."
else
    # SwiftPM names the unstable package that stopped the resolution. When that is one of
    # the allowed siblings, the failure is the known one.
    BLOCKER="$(sed -n "s/.*depends on an unstable-version package '\([^']*\)'.*/\1/p" "$WORK/version-resolution.log" | head -1)"
    if [ -n "$BLOCKER" ] && printf '%s\n' ${ALLOWED_BY_BRANCH[@]+"${ALLOWED_BY_BRANCH[@]}"} | grep -qx -- "$BLOCKER"; then
        echo "check-manifest: warning: a version requirement on the package does not resolve until '$BLOCKER' is required by version."
    else
        echo "check-manifest: a version requirement on the package does not resolve:" >&2
        grep -E "error:|cannot be used|unstable" "$WORK/version-resolution.log" | cut -c1-300 | head -5 >&2 || true
        FAILED=1
    fi
fi

# 3. The consumer fixture.

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
