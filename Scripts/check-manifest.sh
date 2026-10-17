#!/bin/bash
#
# Checks what a consumer of the package gets.
#
#   Scripts/check-manifest.sh              run the checks below
#   Scripts/check-manifest.sh --self-test  run the readers of item 2 on built-in texts
#
# 1. The manifest has no dependency by branch or revision, uses no plugin on any target
#    and does not read the environment. SwiftPM refuses a version requirement on a package
#    that has an unstable dependency, a build plugin of a dependency runs in every
#    consumer's build, a manifest that reads the environment describes more than one
#    package, and unsafe flags make a package that a consumer cannot depend on by version.
# 2. The installation manifest of README.md works. With only its URL pointed at a
#    throw-away tagged copy of the tracked manifest and sources, it resolves and builds for
#    the iOS simulator: a consumer that depends on the checkout by path cannot show a
#    failure of a version requirement, and only a build shows a wrong product or package
#    name, or a platform below the package's. The Package.resolved of that build pins the
#    copy and the libraries that the package brings (RUNTIME_DEPENDENCIES) and nothing
#    else, so a library that only the tests use is not fetched for a consumer: any other
#    pin is named with its kind, version and location, and a missing or doubled library, a
#    file that cannot be read, or one that is not of format version 2 or 3 is a failure.
#    The build keeps its own cache, so manifests and repositories cached on the machine of
#    whoever runs this cannot stand in for what the build resolves. The URL and the version
#    that the README names are not compared with anything: the copy is tagged with that
#    version, whatever it is.
# 3. Fixtures/Consumer builds in Swift 6 and in Swift 5 language mode, and its own sources
#    compile without a warning. It uses the released API, so if it stops building, a
#    consumer's code stops building.
# 4. Every Swift block of README.md and of the documentation catalog compiles as it is
#    written, in Swift 6 and in Swift 5 language mode.
#
# --self-test needs no network, no build and no swift. A reader that never fails looks the
# same as a clean tree, so it takes the python blocks of item 2 (marked readme-consumer and
# resolved-inventory) out of this very file, the text that the check runs, and runs them on
# texts that it carries: a README with no package manifest, two, exact: for from:, or two
# requirements; a Package.resolved with an extra pin, one of the libraries the package brings
# missing, no pin, the copy twice, a format other than 2 and 3, or that is not a resolution at
# all. A reader changed to pass one of these fails the self-test. It does not run the shell
# around the readers, the lines that set FAILED.
#
# Exit codes: 0 every check passed, 1 a check failed, 2 wrong usage, or the self-test could
# not be made (python3 is missing, or a marked block is not where it expects).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE="DMUnLoader"

# Takes the python block that follows the line "# <marker>" out of this script into <output file>:
# the very text that the check runs. The marker must appear once, directly under the line that
# opens the heredoc, so that a line added above it or a second marker cannot make the two differ.
extract_block() {  # <marker> <output file>
    local marker="$1" output="$2" found
    found="$(awk -v marker="# $marker" '$0 == marker { count++; opener = prev } { prev = $0 } END { print count + 0 ":" opener }' "${BASH_SOURCE[0]}")"
    case "$found" in
        "1:"*"<<'PY'") ;;
        *)
            echo "check-manifest: self-test: the marker $marker must appear once, under the line that opens the heredoc of its step (found '$found')" >&2
            exit 2
            ;;
    esac
    awk -v marker="# $marker" '$0 == marker { found = 1 } found && /^PY$/ { exit } found' "${BASH_SOURCE[0]}" > "$output"
    if [ ! -s "$output" ]; then
        echo "check-manifest: self-test: the python block marked $marker is not in ${BASH_SOURCE[0]}" >&2
        exit 2
    fi
}

# Runs the readers of step 2 (the README and Package.resolved) on built-in texts, and exits.
SELF_TEST_WORK=""
self_test() {
    local total=0 failures=0 got output fence app app_two copy action blur all
    local libraries=(dmaction dmvariableblurview)
    if ! command -v python3 > /dev/null; then
        echo "check-manifest: self-test: python3 is not installed" >&2
        exit 2
    fi
    SELF_TEST_WORK="$(mktemp -d "${TMPDIR:-/tmp}/check-manifest-self-test.XXXXXX")" || exit 2
    trap 'rm -rf "$SELF_TEST_WORK"' EXIT
    extract_block readme-consumer "$SELF_TEST_WORK/readme.py"
    extract_block resolved-inventory "$SELF_TEST_WORK/inventory.py"
    pin() {  # <identity> <version>
        printf '{"identity":"%s","kind":"remoteSourceControl","location":"/x/%s","state":{"revision":"abc","version":"%s"}}' "$1" "$1" "$2"
    }
    judge() {  # <name> <expected status> <expected text> <status the reader gave> <its output>
        total=$((total + 1))
        if [ "$4" -eq "$2" ] && printf '%s\n' "$5" | grep -q -F -- "$3"; then
            echo "check-manifest: self-test ok   $1"
        else
            failures=$((failures + 1))
            echo "check-manifest: self-test FAIL $1: expected status $2 and '$3', got status $4:" >&2
            printf '%s\n' "$5" | head -5 | sed 's/^/    /' >&2
        fi
    }
    expect() {  # <name> <expected status> <expected text>: the reader on Package.resolved as it is
        got=0
        output="$(python3 "$SELF_TEST_WORK/inventory.py" "$SELF_TEST_WORK/Package.resolved" "$MODULE" "${libraries[@]}" 2>&1)" || got=$?
        judge "$1" "$2" "$3" "$got" "$output"
    }
    check() {  # <name> <expected status> <expected text> <text of Package.resolved>
        printf '%s\n' "$4" > "$SELF_TEST_WORK/Package.resolved"
        expect "$1" "$2" "$3"
    }
    readme_case() {  # <name> <expected status> <expected text> <text of README.md>
        got=0
        mkdir -p "$SELF_TEST_WORK/probe/consumer"
        printf '%s\n' "$4" > "$SELF_TEST_WORK/README.md"
        output="$(python3 "$SELF_TEST_WORK/readme.py" "$SELF_TEST_WORK/README.md" "$SELF_TEST_WORK/probe" 2>&1)" || got=$?
        judge "$1" "$2" "$3" "$got" "$output"
    }
    # The pins of a consumer of the package: the copy of the package and the two libraries it brings.
    copy="$(pin dmunloader 1.1.0)"
    action="$(pin dmaction 1.1.0)"
    blur="$(pin dmvariableblurview 1.1.0)"
    all="$copy,$action,$blur"
    check "the copy and its two libraries, format 3" 0 "" "{\"version\":3,\"pins\":[$all]}"
    check "the same, format 2" 0 "" "{\"version\":2,\"pins\":[$all]}"
    check "an extra pin is named" 1 "viewinspector (remoteSourceControl, 0.10.5, /x/viewinspector)" "{\"version\":3,\"pins\":[$all,$(pin viewinspector 0.10.5)]}"
    check "an extra pin before the copy is named" 1 "viewinspector (remoteSourceControl, 0.10.5, /x/viewinspector)" "{\"version\":3,\"pins\":[$(pin viewinspector 0.10.5),$all]}"
    check "swift-snapshot-testing and what it brings are named" 1 "swift-syntax (remoteSourceControl, 600.0.1, /x/swift-syntax)" "{\"version\":3,\"pins\":[$all,$(pin swift-snapshot-testing 1.12.0),$(pin swift-syntax 600.0.1),$(pin swift-custom-dump 1.3.0),$(pin xctest-dynamic-overlay 1.5.0)]}"
    check "a library of the package is missing" 1 "dmvariableblurview, a library that the package brings, is not among the resolved packages" "{\"version\":3,\"pins\":[$copy,$action]}"
    check "the copy alone" 1 "dmaction, a library that the package brings, is not among the resolved packages" "{\"version\":3,\"pins\":[$copy]}"
    check "the libraries without the copy" 1 "dmunloader, the tagged copy, is not among the resolved packages" "{\"version\":3,\"pins\":[$action,$blur]}"
    check "no pin at all" 1 "is not among the resolved packages" '{"version":3,"pins":[]}'
    check "the copy twice" 1 "dmunloader, the tagged copy, is pinned 2 times" "{\"version\":3,\"pins\":[$all,$(pin dmunloader 1.2.0)]}"
    check "a library twice" 1 "dmaction, a library that the package brings, is pinned 2 times" "{\"version\":3,\"pins\":[$all,$(pin dmaction 1.2.0)]}"
    check "format 1" 1 "not of format version 2 or 3" '{"object":{"pins":[{"package":"DMUnLoader"}]},"version":1}'
    check "format 4" 1 "not of format version 2 or 3" "{\"version\":4,\"pins\":[$all]}"
    check "no list of pins" 1 "not of format version 2 or 3" '{"version":3}'
    check "not JSON" 1 "cannot be read" 'not json'
    check "a pin that is not an object" 1 "not of format version 2 or 3" "{\"version\":3,\"pins\":[$all,\"text\"]}"
    check "a null state" 1 "second (registry, None, None)" "{\"version\":3,\"pins\":[$all,{\"identity\":\"second\",\"kind\":\"registry\",\"state\":null}]}"
    rm -f "$SELF_TEST_WORK/Package.resolved"
    expect "a file that is not there" 1 "cannot be read"
    # The README as step 2 reads it: one package manifest in a swift fence.
    fence='```'
    swift_block() {  # <text of the block>
        printf '%s\n%s\n%s\n' "${fence}swift" "$1" "$fence"
    }
    app='// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "App",
    dependencies: [
        .package(url: "https://github.com/x/Foo.git", from: "1.2.3")
    ],
    targets: [.target(name: "App", dependencies: [.product(name: "Foo", package: "Foo")])]
)'
    readme_case "one manifest: the version and the copy" 0 "1.2.3 Foo" "$(swift_block "$app")"
    got=0
    grep -q -F "url: \"file://$SELF_TEST_WORK/probe/Foo\"" "$SELF_TEST_WORK/probe/consumer/Package.swift" || got=$?
    judge "the consumer points at the copy" 0 "" "$got" ""
    got=0
    grep -q -F "github.com" "$SELF_TEST_WORK/probe/consumer/Package.swift" || got=$?
    judge "the consumer keeps nothing of the real URL" 1 "" "$got" ""
    readme_case "a URL with a trailing slash and no .git" 0 "1.2.3 Foo" "$(swift_block "${app//Foo.git/Foo/}")"
    readme_case "no package manifest" 1 "has 0 package manifests" "$(swift_block 'let answer = 42')"
    readme_case "two package manifests" 1 "has 2 package manifests" "$(swift_block "$app")
$(swift_block "$app")"
    readme_case "a manifest in a fence that is not swift" 1 "has 0 package manifests" "~~~swift
$app
~~~"
    readme_case "exact: instead of from:" 1 "does not ask for the package with url: and from:" "$(swift_block "${app//from:/exact:}")"
    app_two='// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "App",
    dependencies: [
        .package(url: "https://github.com/x/Foo.git", from: "1.2.3"),
        .package(url: "https://github.com/x/Bar.git", from: "2.0.0")
    ],
    targets: [.target(name: "App")]
)'
    readme_case "two requirements with url: and from:" 1 "does not ask for the package with url: and from:" "$(swift_block "$app_two")"
    if [ "$failures" -gt 0 ]; then
        echo "check-manifest: self-test: $failures of $total checks failed" >&2
        exit 1
    fi
    echo "check-manifest: self-test: $total checks of the readers of the README and of Package.resolved, all ok."
    exit 0
}

if [ "$#" -gt 0 ]; then
    if [ "$1" = "--self-test" ] && [ "$#" -eq 1 ]; then
        self_test
    fi
    echo "usage: Scripts/check-manifest.sh [--self-test]" >&2
    exit 2
fi

WORK="$ROOT/.build/check-manifest"
FAILED=0
# Dependencies that the checks below accept by branch, with a warning that the package
# cannot be required by version while one is. Empty: every dependency is required by
# version.
ALLOWED_BY_BRANCH=()
# The packages that a consumer resolves besides this package, by identity (the lower-case last
# component of the URL): the libraries that it brings. A library that only the tests use is not
# among them. Step 2 fails when a consumer's resolution holds any other package, or lacks one of
# these. A new dependency needs the maintainer's approval and a change of this list in the same
# pull request.
RUNTIME_DEPENDENCIES=(dmaction dmvariableblurview)

mkdir -p "$WORK"

# The copy that the version probe tags lives in a folder this run creates, and leaves with it.
PROBE=""
# shellcheck disable=SC2329  # invoked by the trap below
cleanup() {  # The EXIT trap below calls it. skipcq: SH-2329
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
    for setting in target.get("settings") or []:
        if "unsafeFlags" in setting.get("kind", {}):
            problems.append(f"target '{target['name']}' sets unsafe flags: {json.dumps(setting['kind']['unsafeFlags'])}")
if re.search(r"ProcessInfo|getenv|\.environment\b", source):
    problems.append("Package.swift reads the environment")
for problem in problems:
    print(f"check-manifest: {problem}", file=sys.stderr)
sys.exit(1 if problems else 0)
PY
then
    FAILED=1
else
    echo "check-manifest: no unstable requirement beyond the allowed ones, no plugin, no unsafe flag and no environment switch in Package.swift."
fi

# 2. The installation manifest of README.md, built by version against a throw-away tagged copy of
#    the tracked manifest and sources. The copy is named after the last component of the README's
#    URL, as SwiftPM names the package it fetches from there, so the package name the README uses
#    must match it. A consumer that depends on the checkout by path cannot show a failure of a
#    version requirement, and only a build shows a wrong product or package name. The package is
#    UIKit and SwiftUI, so the consumer is built for the iOS simulator with the SDK of the machine,
#    and the iOS version of the triple is the package's own floor: a README that declares a lower
#    platform fails the build. The cache, the configuration and the security folders lie in the
#    folder of the probe, so that manifests and repositories cached on the machine of whoever runs
#    this cannot stand in for what the build resolves.
PROBE="$(mktemp -d "$WORK/version-probe.XXXXXX")"
mkdir -p "$PROBE/consumer" "$PROBE/cache" "$PROBE/config" "$PROBE/security"
# The probe repository takes nothing from the git configuration of whoever runs this: no signing,
# no hooks, no identity.
probe_git() {
    git -C "$PROBE/$COPY" \
        -c user.name=probe -c user.email=probe@example.invalid \
        -c commit.gpgsign=false -c tag.gpgSign=false -c core.hooksPath=/dev/null \
        -c core.excludesFile=/dev/null \
        "$@"
}
# Writes the consumer's manifest, and prints the version the README asks for and the name of the copy.
if ! ANSWER="$(python3 - "$ROOT/README.md" "$PROBE" <<'PY'
# readme-consumer
import re
import sys

readme, probe = sys.argv[1:3]
blocks = re.findall(r"^```swift\n(.*?)^```$", open(readme, encoding="utf-8").read(), re.S | re.M)
manifests = [block for block in blocks if "Package(" in block]
if len(manifests) != 1:
    sys.exit(f"check-manifest: README.md has {len(manifests)} package manifests; it must have one")
requirements = re.findall(r'\.package\(url: "([^"]+)", from: "([^"]+)"\)', manifests[0])
if len(requirements) != 1:
    sys.exit("check-manifest: the manifest of README.md does not ask for the package with url: and from:")
url, version = requirements[0]
# SwiftPM names a package it fetches after the last component of its URL.
copy = re.sub(r"\.git$", "", url.rstrip("/").split("/")[-1])
with open(f"{probe}/consumer/Package.swift", "w", encoding="utf-8") as consumer:
    consumer.write(manifests[0].replace(f'url: "{url}"', f'url: "file://{probe}/{copy}"'))
print(version, copy)
PY
)"; then
    FAILED=1
else
    read -r VERSION COPY <<< "$ANSWER"
    mkdir -p "$PROBE/$COPY"
    # Without -l, rsync skips a symbolic link and says so only in a warning: the counts below
    # would show it. A manifest for one version of the tools, Package@swift-6.3.swift, is part of
    # the package: SwiftPM reads it in place of Package.swift when it is the newest one the tools
    # can use.
    (cd "$ROOT" && git ls-files -z -- 'Package*.swift' Sources | xargs -0 -I{} rsync -Rl {} "$PROBE/$COPY/")
    COPIED="$(cd "$PROBE/$COPY" && find . \( -type f -o -type l \) | wc -l | tr -d ' ')"
    TRACKED="$(git -C "$ROOT" ls-files -- 'Package*.swift' Sources | wc -l | tr -d ' ')"
    if [ "$COPIED" -eq "$TRACKED" ]; then
        # SwiftPM resolves the copy as soon as it reads the consumer's manifest.
        probe_git init -q
        probe_git add -A
        probe_git commit -q -m probe
        probe_git tag "$VERSION"
        # What the tag holds, not what was copied: a file that git leaves out of the commit would
        # make the build below pass on a package that is not the tracked one.
        COPIED="$(probe_git ls-tree -r --name-only HEAD | wc -l | tr -d ' ')"
    fi
    if [ "$COPIED" -ne "$TRACKED" ]; then
        echo "check-manifest: the tagged copy holds $COPIED of the $TRACKED tracked files of the package" >&2
        FAILED=1
    elif ! IOS_FLOOR="$(python3 -c 'import json, sys; print(next(p["version"] for p in json.load(open(sys.argv[1]))["platforms"] if p["platformName"] == "ios"))' \
            "$WORK/manifest.json" 2> "$WORK/ios-floor.log")"; then
        echo "check-manifest: Package.swift declares no iOS platform, or its platforms cannot be read, so the consumer cannot be built for the simulator:" >&2
        tail -3 "$WORK/ios-floor.log" | sed 's/^/  /' >&2
        FAILED=1
    elif ! SIMULATOR_SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"; then
        echo "check-manifest: the SDK of the iOS simulator cannot be found" >&2
        FAILED=1
    elif ! swift package --package-path "$PROBE/consumer" dump-package \
            > "$WORK/readme-manifest.json" 2> "$WORK/readme-manifest.log"; then
        echo "check-manifest: the manifest of README.md does not evaluate:" >&2
        head -10 "$WORK/readme-manifest.log" | sed 's/^/  /' >&2
        FAILED=1
    elif ! TARGETS="$(python3 -c 'import json, sys; print("\n".join(t["name"] for t in json.load(sys.stdin)["targets"]))' \
            < "$WORK/readme-manifest.json")"; then
        echo "check-manifest: the targets of the README's manifest cannot be read" >&2
        FAILED=1
    elif [ -z "$TARGETS" ]; then
        echo "check-manifest: the manifest of README.md has no target to build" >&2
        FAILED=1
    else
        # Every target of the consumer gets a source file that imports the module.
        while IFS= read -r TARGET; do
            mkdir -p "$PROBE/consumer/Sources/$TARGET"
            echo "import $MODULE" > "$PROBE/consumer/Sources/$TARGET/$TARGET.swift"
        done <<< "$TARGETS"
        if swift build --package-path "$PROBE/consumer" --cache-path "$PROBE/cache" \
                --config-path "$PROBE/config" --security-path "$PROBE/security" \
                --sdk "$SIMULATOR_SDK" --triple "arm64-apple-ios${IOS_FLOOR}-simulator" \
                > "$WORK/version-build.log" 2>&1; then
            # What the build resolved, as SwiftPM pinned it: the tagged copy and the libraries that the
            # package brings, and nothing else.
            if EXTRA="$(python3 - "$PROBE/consumer/Package.resolved" "$COPY" "${RUNTIME_DEPENDENCIES[@]}" <<'PY'
# resolved-inventory
import json
import sys

path, copy, *libraries = sys.argv[1:]
expected = copy.lower()
try:
    with open(path, encoding="utf-8") as handle:
        resolved = json.load(handle)
except (OSError, ValueError) as error:
    print(f"  Package.resolved cannot be read: {error}")
    sys.exit(1)
readable = isinstance(resolved, dict) and resolved.get("version") in (2, 3) and isinstance(resolved.get("pins"), list)
if not readable or not all(isinstance(pin, dict) for pin in resolved["pins"]):
    print("  Package.resolved is not of format version 2 or 3 with a list of pins, and only those are read")
    sys.exit(1)
identities = [pin.get("identity") for pin in resolved["pins"]]
problems = []
for pin in resolved["pins"]:
    if pin.get("identity") != expected and pin.get("identity") not in libraries:
        state = pin.get("state")
        if not isinstance(state, dict):
            state = {}
        problems.append(f"  {pin.get('identity')} ({pin.get('kind')}, {state.get('version') or state.get('revision')}, {pin.get('location')})")
for identity, description in [(expected, "the tagged copy")] + [(library, "a library that the package brings") for library in libraries]:
    if identities.count(identity) == 0:
        problems.append(f"  {identity}, {description}, is not among the resolved packages")
    elif identities.count(identity) > 1:
        problems.append(f"  {identity}, {description}, is pinned {identities.count(identity)} times")
print("\n".join(problems))
sys.exit(1 if problems else 0)
PY
)"; then
                echo "check-manifest: the manifest of README.md, pointed at a copy tagged $VERSION, resolves and builds for the iOS $IOS_FLOOR simulator, and the consumer resolves this package and ${RUNTIME_DEPENDENCIES[*]} only."
            else
                echo "check-manifest: the consumer of README.md's manifest resolves more or less than this package and its libraries:" >&2
                printf '%s\n' "$EXTRA" >&2
                FAILED=1
            fi
        else
            # SwiftPM names the unstable package that stopped the resolution. When that is one of
            # the allowed siblings, the failure is the known one.
            BLOCKER="$(sed -n "s/.*depends on an unstable-version package '\([^']*\)'.*/\1/p" "$WORK/version-build.log" | head -1)"
            if [ -n "$BLOCKER" ] && printf '%s\n' ${ALLOWED_BY_BRANCH[@]+"${ALLOWED_BY_BRANCH[@]}"} | grep -qx -- "$BLOCKER"; then
                echo "check-manifest: warning: a version requirement on the package does not resolve until '$BLOCKER' is required by version."
            else
                echo "check-manifest: the manifest of README.md does not resolve or build by version. See ${WORK#"$ROOT"/}/version-build.log" >&2
                ERRORS="$(grep -E "error:|cannot be used|unstable|unsafe" "$WORK/version-build.log" | cut -c1-300 | head -5 || true)"
                if [ -n "$ERRORS" ]; then
                    printf '%s\n' "$ERRORS" >&2
                else
                    tail -15 "$WORK/version-build.log" | sed 's/^/  /' >&2
                fi
                FAILED=1
            fi
        fi
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
