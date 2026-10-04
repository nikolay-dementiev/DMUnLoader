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
#    compile without a warning. It uses the released API, so if it stops building, a
#    consumer's code stops building.
# 4. Every Swift block of README.md and of the documentation catalog compiles as it is
#    written, in Swift 6 and in Swift 5 language mode.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE="DMUnLoader"
WORK="$ROOT/.build/check-manifest"
FAILED=0
# Dependencies that the checks below accept by branch, with a warning that the package
# cannot be required by version while one is. Empty: every dependency is required by
# version.
ALLOWED_BY_BRANCH=()

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

# 4. The Swift blocks of README.md and of the documentation catalog, each compiled in a
#    context of its own, so that a block cannot use a name another block declares and one
#    broken block cannot hide another. A block must compile as it is written, its imports
#    included. A block that contains `Package(` is a complete package manifest, and SwiftPM
#    evaluates it. Every other block is a target of its own, twice: in Swift 6 and in Swift 5
#    language mode, in a generated package for iOS that depends on this checkout by path, the
#    way Fixtures/Consumer does. The build goes on after an error, so that one run names every
#    broken block. A warning in a block fails the check too.
SNIPPETS="$WORK/snippets"
rm -rf "$SNIPPETS"
mkdir -p "$SNIPPETS/blocks"
SNIPPETS_DERIVED="$(mktemp -d "$WORK/DerivedData.snippets.XXXXXX")"
SNIPPETS_FAILED=0
DOCUMENTS=("$ROOT/README.md")
while IFS= read -r DOCUMENT; do
    DOCUMENTS+=("$DOCUMENT")
done < <(find "$ROOT/Sources/$MODULE/$MODULE.docc" -name '*.md' | LC_ALL=C sort)
# The status of find is lost in the substitution above, so a missing catalog is caught here.
if [ "${#DOCUMENTS[@]}" -lt 2 ]; then
    echo "check-manifest: the documentation catalog Sources/$MODULE/$MODULE.docc has no Markdown file." >&2
    SNIPPETS_FAILED=1
fi
if ! python3 - "$ROOT" "$SNIPPETS" "${DOCUMENTS[@]}" > "$WORK/snippet-blocks.txt" <<'PY'
import os
import re
import sys

root, work, documents = sys.argv[1], sys.argv[2], sys.argv[3:]
number = 0
for document in documents:
    name_in_repo = os.path.relpath(document, root)
    lines = open(document, encoding="utf-8").read().split("\n")
    block, start = None, 0
    for index, line in enumerate(lines, start=1):
        if block is None:
            if line.strip() == "```swift":
                block, start = [], index + 1
            elif re.match(r"^\s*(```|~~~)", line) and "swift" in line.lower():
                sys.exit(f"{name_in_repo}:{index}: write the fence of a Swift block as ```swift, so that it is compiled")
        elif line.strip() == "```":
            number += 1
            text = "\n".join(block) + "\n"
            kind = "manifest" if "Package(" in text else "ios"
            name = f"Snippet{number:02d}"
            with open(os.path.join(work, "blocks", f"{name}.swift"), "w", encoding="utf-8") as out:
                out.write(text)
            print(kind, name, f"{name_in_repo}:{start}")
            block = None
        else:
            block.append(line)
    if block is not None:
        sys.exit(f"{name_in_repo}: the Swift block that starts on line {start} is not closed")
PY
then
    SNIPPETS_FAILED=1
elif ! grep -q " README.md:" "$WORK/snippet-blocks.txt"; then
    echo "check-manifest: README.md has no Swift block." >&2
    SNIPPETS_FAILED=1
else
    IOS_TARGETS=()
    while read -r KIND NAME PLACE; do
        if [ "$KIND" = "manifest" ]; then
            mkdir -p "$SNIPPETS/$NAME"
            cp "$SNIPPETS/blocks/$NAME.swift" "$SNIPPETS/$NAME/Package.swift"
            if ! swift package dump-package --package-path "$SNIPPETS/$NAME" > "$WORK/snippet-$NAME.log" 2>&1; then
                echo "check-manifest: the manifest at $PLACE does not evaluate:" >&2
                grep -E "error:" "$WORK/snippet-$NAME.log" | head -10 >&2 || true
                SNIPPETS_FAILED=1
            fi
        else
            for TARGET in "$NAME" "${NAME}Swift5"; do
                mkdir -p "$SNIPPETS/ios/Sources/$TARGET"
                cp "$SNIPPETS/blocks/$NAME.swift" "$SNIPPETS/ios/Sources/$TARGET/$TARGET.swift"
                IOS_TARGETS+=("$TARGET")
            done
        fi
    done < "$WORK/snippet-blocks.txt"

    if [ "${#IOS_TARGETS[@]}" -gt 0 ]; then
        {
            echo "// swift-tools-version: 6.0"
            echo "import PackageDescription"
            echo "let package = Package("
            echo "    name: \"Snippets\","
            echo "    platforms: [.iOS(.v17)],"
            echo "    products: [.library(name: \"Snippets\", targets: [$(printf '"%s", ' "${IOS_TARGETS[@]}")])],"
            echo "    dependencies: [.package(name: \"$MODULE\", path: \"$ROOT\")],"
            echo "    targets: ["
            for TARGET in "${IOS_TARGETS[@]}"; do
                SETTINGS=""
                case "$TARGET" in
                    *Swift5) SETTINGS=", swiftSettings: [.swiftLanguageMode(.v5)]" ;;
                esac
                echo "        .target(name: \"$TARGET\", dependencies: [.product(name: \"$MODULE\", package: \"$MODULE\")]$SETTINGS),"
            done
            echo "    ]"
            echo ")"
        } > "$SNIPPETS/ios/Package.swift"
        if (cd "$SNIPPETS/ios" && xcodebuild build \
                -scheme Snippets \
                -sdk iphonesimulator \
                -destination 'generic/platform=iOS Simulator' \
                -derivedDataPath "$SNIPPETS_DERIVED" \
                -clonedSourcePackagesDirPath "$WORK/SourcePackages" \
                -skipPackagePluginValidation \
                -IDEBuildingContinueBuildingAfterErrors=YES \
                ARCHS=arm64 ONLY_ACTIVE_ARCH=NO) > "$WORK/snippets-build.log" 2>&1; then
            # A block counts only when the log shows it compiled in this run.
            for TARGET in "${IOS_TARGETS[@]}"; do
                if ! grep -qE "^SwiftCompile .*/Sources/$TARGET/$TARGET\.swift" "$WORK/snippets-build.log"; then
                    echo "check-manifest: the block at $(grep " ${TARGET%Swift5} " "$WORK/snippet-blocks.txt" | cut -d ' ' -f 3) was not compiled as $TARGET" >&2
                    SNIPPETS_FAILED=1
                fi
            done
            WARNINGS="$(grep -E "/Sources/Snippet[0-9]+(Swift5)?/[^:]+:[0-9]+:[0-9]+: warning:" "$WORK/snippets-build.log" | sort -u || true)"
            if [ -n "$WARNINGS" ]; then
                echo "check-manifest: a Swift block of the documentation compiles with warnings:" >&2
                echo "$WARNINGS" | sed "s|$SNIPPETS/ios/||" | head -20 >&2
                echo "  The block numbers map to their documents in ${WORK#"$ROOT"/}/snippet-blocks.txt" >&2
                SNIPPETS_FAILED=1
            fi
        else
            echo "check-manifest: a Swift block of the documentation does not compile:" >&2
            grep -E "error:" "$WORK/snippets-build.log" | sed "s|$SNIPPETS/ios/||" | sort -u | head -20 >&2 || true
            echo "  The block numbers map to their documents in ${WORK#"$ROOT"/}/snippet-blocks.txt" >&2
            SNIPPETS_FAILED=1
        fi
    fi
    if [ "$SNIPPETS_FAILED" -eq 0 ]; then
        echo "check-manifest: the $(wc -l < "$WORK/snippet-blocks.txt" | tr -d ' ') Swift blocks of README.md and the documentation catalog compile in Swift 6 and Swift 5 mode."
    fi
fi
if [ "$SNIPPETS_FAILED" -ne 0 ]; then
    FAILED=1
fi

exit "$FAILED"
