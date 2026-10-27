#!/bin/bash
#
# Fails when a build log holds a warning that points into this repository's own files.
#
#   Scripts/check-warnings.sh <xcodebuild log>    exit 0 with no such warning, 1 with one,
#                                                 2 when the log is not a build of this
#                                                 checkout, or the build compiled nothing
#   Scripts/check-warnings.sh --self-test         run the script on canned logs
#
# The build setting that turns warnings into errors cannot be used for this package:
# Xcode builds the dependencies with warnings suppressed, and the compiler refuses the two
# flags together. So the log of the build is checked instead. A warning inside a
# dependency's checkout is not this repository's to fix and does not count.
#
# --self-test needs no build. It copies this script into a scratch checkout and runs the copy on
# canned logs, by the path the system gave the checkout, which on macOS lies behind a link (/var
# is /private/var), and through a link of its own, against logs that print the one path or the
# other: xcodebuild prints the link, SwiftPM the real path, and the script has to find a warning
# whichever it prints. It also tries a log of a build that compiled nothing.

set -euo pipefail

# It lives in this script and runs a copy of it, so that the script CI runs is the one that is
# tried, and a change to the scan cannot leave the test behind.
self_test() {
    local work real link physical total=0 failures=0 index script prefix label base="${TMPDIR:-/tmp}" tmp_real
    # The scratch folder lies under /tmp wherever that is a link (macOS): the third root of the
    # script is for that link, and a TMPDIR with a real path would leave the cases that print the
    # link with no link to try.
    tmp_real="$(cd /tmp 2>/dev/null && pwd -P || true)"
    if [ -n "$tmp_real" ] && [ "$tmp_real" != /tmp ]; then
        base=/tmp
    fi
    work="$(mktemp -d "$base/check-warnings-self-test.XXXXXX")" || exit 2
    trap 'rm -rf "$work"' EXIT
    # The path as the script prints it for its own root: a TMPDIR that ends in a slash would
    # leave a double slash here, which the root of the copy does not have.
    work="$(cd "$work" && pwd)"
    real="$work/checkout"
    link="$work/link"
    mkdir -p "$real/Scripts" "$real/Sources/Lib" "$real/.build/checkouts/Dep"
    cp "${BASH_SOURCE[0]}" "$real/Scripts/check-warnings.sh"
    ln -s "$real" "$link"
    physical="$(cd "$real" && pwd -P)"

    compile_xcode() { echo "SwiftCompile normal arm64 $1/Sources/Lib/A.swift (in target 'Lib' from project 'Lib')"; }
    compile_swiftpm() { echo "/usr/bin/swift-frontend -frontend -c -primary-file $1/Sources/Lib/A.swift -module-name Lib"; }
    names_only() { printf '%s\n' "cd $1/.swiftpm/xcode" "-I $1/.build/debug/Modules"; }
    warning() { echo "$1/Sources/Lib/A.swift:3:5: warning: variable was never used"; }
    check() {  # <name> <expected status> <expected text> <script> <text of the log> [<locale>]
        local got=0 output locale=()
        if [ -n "${6:-}" ]; then
            locale=(env "LC_ALL=$6")
        fi
        printf '%s\n' "$5" > "$work/log.txt"
        output="$(${locale[@]+"${locale[@]}"} "$4" "$work/log.txt" 2>&1)" || got=$?
        total=$((total + 1))
        if [ "$got" -eq "$2" ] && printf '%s\n' "$output" | grep -q -F -- "$3"; then
            echo "check-warnings: self-test ok   $1"
        else
            failures=$((failures + 1))
            echo "check-warnings: self-test FAIL $1: expected status $2 and '$3', got status $got:" >&2
            printf '%s\n' "$output" | head -3 | sed 's/^/    /' >&2
        fi
    }

    # Script path and the path that the log prints: the checkout by the path the system gave it,
    # and by its real path; the link, and the real path again.
    local scripts=("$real/Scripts/check-warnings.sh" "$real/Scripts/check-warnings.sh" "$link/Scripts/check-warnings.sh" "$link/Scripts/check-warnings.sh" "$physical/Scripts/check-warnings.sh")
    local prefixes=("$real" "$physical" "$link" "$physical" "$real")
    local labels=("run by its path, the log prints that path" "run by its path, the log prints the real path" "run through a link, the log prints the link" "run through a link, the log prints the real path" "run by its real path, the log prints the path the system gave")
    for index in 0 1 2 3 4; do
        script="${scripts[$index]}"
        prefix="${prefixes[$index]}"
        label="${labels[$index]}"
        check "$label: a warning in the checkout" 1 "Sources/Lib/A.swift:3:5: warning" "$script" "$(compile_xcode "$prefix"; warning "$prefix")"
        check "$label: a clean build" 0 "no warning" "$script" "$(compile_swiftpm "$prefix")"
        check "$label: a build that compiled nothing" 2 "compiled nothing" "$script" "$(names_only "$prefix")"
    done
    script="$real/Scripts/check-warnings.sh"
    # Swift 6.4 writes colour codes into the log of `swift build` when the log is a file, between the
    # position and the word warning, and the scan has to see through them.
    check "a warning in a coloured log" 1 "Sources/Lib/A.swift:3:5: warning" "$script" "$(compile_swiftpm "$real"; printf '%s/Sources/Lib/A.swift:3:5: \033[1;33mwarning: \033[1;39mvariable was never used\033[0;0m\n' "$real")"
    # A byte that is not UTF-8 must not hide what follows it, whatever the locale of the caller is.
    check "a warning after a byte that is not UTF-8" 1 "Sources/Lib/A.swift:3:5: warning" "$script" "$(compile_swiftpm "$real"; printf 'a byte \377 in the log\n%s/Sources/Lib/A.swift:3:5: \033[1;33mwarning: \033[1;39mvariable was never used\033[0;0m\n' "$real")" en_US.UTF-8
    check "a warning outside the checkout" 0 "no warning" "$script" "$(compile_xcode "$real"; echo '/somewhere/else/Sources/X.swift:1:1: warning: x')"
    check "a warning in a dependency under .build" 0 "no warning" "$script" "$(compile_xcode "$real"; echo "$real/.build/checkouts/Dep/Sources/D.swift:1:1: warning: x")"
    check "a compile line that names no Swift file of the checkout" 2 "compiled nothing" "$script" "$(echo "SwiftCompile normal arm64 Compiling\\ nothing $real/Sources/Lib (in target 'Lib' from project 'Lib')"; names_only "$real")"
    check "only a dependency under .build compiled" 2 "compiled nothing" "$script" "$(echo "SwiftCompile normal arm64 $real/.build/checkouts/Dep/Sources/D.swift (in target 'Dep' from project 'Dep')"; names_only "$real")"
    check "a compile line that also names .build/ for its output" 0 "no warning" "$script" "/usr/bin/swift-frontend -frontend -c $real/Sources/Lib/A.swift -primary-file $real/Sources/Lib/A.swift -o $real/.build/debug/Lib.build/A.swift.o"
    check "a compile line with an include path under .build/ before the source" 0 "no warning" "$script" "/usr/bin/swift-frontend -frontend -c -I $real/.build/debug/Modules -primary-file $real/Sources/Lib/A.swift -module-name Lib"
    check "a note that quotes a warning" 0 "no warning" "$script" "$(compile_xcode "$real"; echo "$real/Sources/Lib/A.swift:9:1: note: the warning: is silenced here")"
    check "a warning that does not start the line" 0 "no warning" "$script" "$(compile_xcode "$real"; echo "see $real/Sources/Lib/A.swift:3:5: warning: variable was never used")"
    check "a compile line that names a folder of the checkout and a Swift file elsewhere" 2 "compiled nothing" "$script" "$(echo "SwiftCompile normal arm64 $real/Sources/Lib /somewhere/else/B.swift (in target 'Lib' from project 'Lib')"; names_only "$real")"
    check "a line that mentions SwiftCompile without starting with it" 2 "compiled nothing" "$script" "$(echo "echo SwiftCompile normal arm64 $real/Sources/Lib/A.swift"; names_only "$real")"
    check "a log that never names the checkout" 2 "not a build of this checkout" "$script" "Build succeeded"
    total=$((total + 1))
    local got=0 output
    output="$("$script" "$work/no-such-log.txt" 2>&1)" || got=$?
    if [ "$got" -eq 2 ] && printf '%s\n' "$output" | grep -q -F -- "there is no log"; then
        echo "check-warnings: self-test ok   no log at all"
    else
        failures=$((failures + 1))
        echo "check-warnings: self-test FAIL no log at all: expected status 2 and 'there is no log', got status $got:" >&2
        printf '%s\n' "$output" | head -3 | sed 's/^/    /' >&2
    fi

    if [ "$failures" -gt 0 ]; then
        echo "check-warnings: self-test: $failures of $total checks failed" >&2
        exit 1
    fi
    echo "check-warnings: self-test: $total checks of the scan, all ok."
    exit 0
}

if [ "$#" -eq 1 ] && [ "$1" = "--self-test" ]; then
    self_test
fi

LOG="${1:?give the path of an xcodebuild log}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# The checkout may be reached through a link, and the tools print it differently: xcodebuild by
# the path it was reached through, SwiftPM by the real path (/tmp is /private/tmp on macOS). A
# line of the log can start with either, so both are roots. They are the same when no link is in
# the way.
REAL_ROOT="$(cd "$ROOT" && pwd -P)"
# A third form: the links of macOS itself (/tmp, /var and /etc point into /private), which a
# build run from a real path still prints as the link.
SYSTEM_LINK_ROOT="$REAL_ROOT"
case "$REAL_ROOT" in
    /private/*) SYSTEM_LINK_ROOT="${REAL_ROOT#/private}" ;;
esac
ROOT_LIST=("$ROOT")
for candidate in "$REAL_ROOT" "$SYSTEM_LINK_ROOT"; do
    known=0
    for root in "${ROOT_LIST[@]}"; do
        if [ "$root" = "$candidate" ]; then
            known=1
        fi
    done
    if [ "$known" -eq 0 ]; then
        ROOT_LIST+=("$candidate")
    fi
done
ROOTS=""
ROOT_PATTERNS=()
for candidate in "${ROOT_LIST[@]}"; do
    ROOTS="${ROOTS:+$ROOTS$'\n'}$candidate/"
    ROOT_PATTERNS+=(-e "$candidate/")
done

if [ ! -f "$LOG" ]; then
    echo "check-warnings: there is no log at $LOG" >&2
    exit 2
fi

# A build of this checkout names its files. A log that never does is the wrong log, or
# a build that stopped before it compiled anything, and proves nothing.
if ! grep -q -F "${ROOT_PATTERNS[@]}" "$LOG"; then
    echo "check-warnings: ${LOG} never mentions $ROOT; it is not a build of this checkout." >&2
    exit 2
fi

# A log can name the checkout in lines that compile nothing: the include paths and the folders
# of a build that found everything up to date. The log of such a build, a second run on a built
# tree, holds no warning and proves nothing. A compile line names a Swift file of the checkout
# outside .build/ and is a line of xcodebuild's that starts with SwiftCompile, or one of the
# compiler's invocations that SwiftPM prints with -v, which holds -primary-file.
COMPILED="$(CHECK_WARNINGS_ROOTS="$ROOTS" awk '
    BEGIN { count = split(ENVIRON["CHECK_WARNINGS_ROOTS"], roots, "\n") }
    index($0, "SwiftCompile ") == 1 || index($0, " -primary-file ") > 0 {
        for (i = 1; i <= count; i++) {
            rest = $0
            while ((position = index(rest, roots[i])) > 0) {
                rest = substr(rest, position + length(roots[i]))
                if (index(rest, ".build/") != 1 && match(rest, /^[^ \t]*\.swift/)) {
                    print "yes"
                    exit
                }
            }
        }
    }' "$LOG")"
if [ -z "$COMPILED" ]; then
    echo "check-warnings: ${LOG} shows no Swift file of this checkout compiled: the build compiled nothing" >&2
    echo "  (a second run on a built tree?) and proves nothing. Build clean." >&2
    exit 2
fi

# A diagnostic starts with the file it points to. The path is compared as text, so a
# folder name with characters that mean something in a pattern cannot change the match.
# It reaches awk through the environment: -v would turn a backslash in it into an escape.
# The build folder inside the checkout holds dependency checkouts and generated files,
# so it is left out. The colour codes are taken out of the log first: Swift 6.4 puts them into the
# log of `swift build` between the position and the word warning.
WARNINGS="$(CHECK_WARNINGS_ROOTS="$ROOTS" awk '
    BEGIN { count = split(ENVIRON["CHECK_WARNINGS_ROOTS"], roots, "\n") }
    {
        for (i = 1; i <= count; i++) {
            root = roots[i]
            if (index($0, root) == 1 && index($0, root ".build/") != 1) {
                rest = substr($0, length(root) + 1)
                if (rest ~ /^[^:]+:[0-9]+:[0-9]+: warning:/) print rest
                break
            }
        }
    }' <(sed "s/$(printf '\033')\[[0-9;]*m//g" "$LOG") | LC_ALL=C sort -u)"

if [ -z "$WARNINGS" ]; then
    echo "check-warnings: no warning from this repository's files in ${LOG#"$ROOT"/}."
    exit 0
fi

echo "check-warnings: the build reports warnings in this repository's files:" >&2
echo "$WARNINGS" >&2
exit 1
