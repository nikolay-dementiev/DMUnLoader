#!/bin/bash
#
# Decides which jobs of .github/workflows/ci.yml a pull request or a push to main needs, from the
# paths it changes.
#
#   Scripts/ci-changes.sh <event> <base sha> <ref>   diffs HEAD against the base, prints light=... heavy=...
#   Scripts/ci-changes.sh --classify <event>   the same decision for the paths on standard input
#   Scripts/ci-changes.sh --self-test          proves the decision on fixtures and the job table on ci.yml
#
# Two groups of jobs, each answered with run or skip:
#   light  lint, docs, api, consumer, podspec: macOS without a simulator, short. consumer reads
#          README.md and Documentation/Migration-2.0.md, podspec reads LICENSE.
#   heavy  test, example, floor, thread-sanitizer: they build and test the code.
#
# A change that only touches documents (*.md outside the code directories, Documentation, LICENSE,
# DocumentationAndBluePrints, .agents) skips heavy. A change that only touches an inert file
# (.coderabbit.yaml, which no job reads) skips both. Every other path runs both, and so does a path
# nobody listed, an empty list, a diff that cannot be made, and every event that is neither a pull
# request nor a push (schedule, workflow_dispatch, workflow_call).
#
# A push is filtered only on main, against the commit it replaced: the diff is the push's own, from
# <base sha> (github.event.before) to HEAD. Anything that is not that runs everything: another ref,
# which includes a tag push (the release calls this workflow for a version tag, and inside it the event
# is push), a base of 40 zeros (a ref that was just created), a base that is not a commit of the
# clone, a diff that fails, and a push that changes nothing.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LIGHT_JOBS="lint docs api consumer podspec"
readonly HEAVY_JOBS="test example floor thread-sanitizer"
SCRATCH=""
trap '[ -z "$SCRATCH" ] || rm -rf "$SCRATCH"' EXIT

# inert, document or code. Code is the default, and the code directories win over a *.md in them.
classify() {
    case "$1" in
        .coderabbit.yaml) echo inert ;;
        Sources/* | Tests/* | Examples/* | Fixtures/* | Tools/* | Scripts/* | .github/*) echo code ;;
        *.md | Documentation/* | LICENSE | DocumentationAndBluePrints/* | .agents/*) echo document ;;
        *) echo code ;;
    esac
}

# Reads paths on standard input, takes the event as its argument, prints the two answers.
decide() {
    local event="$1" path count=0 mode=inert
    while IFS= read -r path; do
        [ -n "$path" ] || continue
        count=$((count + 1))
        case "$(classify "$path")" in
            code) mode=code ;;
            document) [ "$mode" = code ] || mode=document ;;
            *) ;;
        esac
    done
    if { [ "$event" != pull_request ] && [ "$event" != push ]; } || [ "$count" -eq 0 ]; then
        mode=code
    fi
    case "$mode" in
        code) echo "light=run"; echo "heavy=run" ;;
        document) echo "light=run"; echo "heavy=skip" ;;
        *) echo "light=skip"; echo "heavy=skip" ;;
    esac
}

# The repository is the fourth argument so that the self-test can run the real diff on a scratch one.
run_diff() {
    local event="$1" base="$2" ref="$3" repo="${4-$ROOT}" paths err
    local -a range
    case "$event" in
        pull_request) range=("$base...HEAD") ;;
        push)
            # An empty list runs everything. The checks come one by one so that each can be proved.
            if [ "$ref" != refs/heads/main ]; then
                printf '' | decide "$event"
                return
            fi
            if [ -z "$base" ] || [ "$base" = 0000000000000000000000000000000000000000 ]; then
                printf '' | decide "$event"
                return
            fi
            if ! err="$(git -C "$repo" cat-file -e "$base^{commit}" 2>&1)"; then
                echo "ci-changes: $base is not a commit of this clone${err:+ ($err)}, so every job runs." >&2
                printf '' | decide "$event"
                return
            fi
            range=("$base" HEAD)
            ;;
        *)
            printf '' | decide "$event"
            return
            ;;
    esac
    # A base that is not in the clone, or no common ancestor, must run everything: a path that no
    # class lists stands for the change that could not be listed.
    # --no-renames lists both paths of a moved file, so a source file moved into Documentation is
    # still a source change; core.quotePath=false keeps a non-ASCII path as it is, not in quotes.
    if ! paths="$(git -C "$repo" -c core.quotePath=false diff --no-renames --name-only "${range[@]}")"; then
        echo "ci-changes: git diff against $base failed, so every job runs." >&2
        paths="unlisted/unknown-change"
    fi
    printf '%s\n' "$paths" | decide "$event"
}

failures=0
expect() {
    local label="$1" event="$2" paths="$3" want="$4" got
    got="$(printf '%s\n' "$paths" | decide "$event" | tr '\n' ' ')"
    got="${got% }"
    if [ "$got" != "$want" ]; then
        echo "ci-changes self-test: $label: wanted '$want', got '$got'" >&2
        failures=$((failures + 1))
    fi
}

expect_diff() {
    local label="$1" repo="$2" base="$3" want="$4" event="${5-pull_request}" ref="${6-refs/pull/1/merge}" got
    got="$(run_diff "$event" "$base" "$ref" "$repo" 2> /dev/null | tr '\n' ' ')"
    got="${got% }"
    if [ "$got" != "$want" ]; then
        echo "ci-changes self-test: $label: wanted '$want', got '$got'" >&2
        failures=$((failures + 1))
    fi
}

# Every job of ci.yml is in exactly one group and asks for its group's answer, so that a job added
# later cannot run unfiltered by accident.
check_job_table() {
    local workflow="$ROOT/.github/workflows/ci.yml" job group block names
    names="$(awk '/^jobs:/ { in_jobs = 1; next } in_jobs && /^  [a-z][a-z-]*:$/ { sub(/^  /, ""); sub(/:$/, ""); print }' "$workflow" | tr '\n' ' ')"
    for job in $names; do
        [ "$job" = changes ] && continue
        group=""
        case " $LIGHT_JOBS " in *" $job "*) group=light ;; esac
        case " $HEAVY_JOBS " in *" $job "*) group=heavy ;; esac
        if [ -z "$group" ]; then
            echo "ci-changes self-test: job '$job' of ci.yml is in neither group" >&2
            failures=$((failures + 1))
            continue
        fi
        block="$(awk -v job="$job" '$0 == "  " job ":" { on = 1; next } on && /^  [a-z][a-z-]*:$/ { exit } on { print }' "$workflow")"
        if ! printf '%s\n' "$block" | grep -qF "if: \${{ !cancelled() && needs.changes.outputs.$group != 'skip' }}"; then
            echo "ci-changes self-test: job '$job' does not carry if: \${{ !cancelled() && needs.changes.outputs.$group != 'skip' }}" >&2
            failures=$((failures + 1))
        fi
    done
    for job in $LIGHT_JOBS $HEAVY_JOBS; do
        case " $names " in *" $job "*) ;; *)
            echo "ci-changes self-test: '$job' is in a group but not a job of ci.yml" >&2
            failures=$((failures + 1))
            ;;
        esac
    done
}

# Runs the real diff on a scratch repository: a source file moved into Documentation, a base that is
# not in the clone, and documents whose names hold a space and a character that is not ASCII. The
# scratch settings do not depend on the settings of the machine.
check_real_diff() {
    local dir base mark
    mark="$(printf '\342\234\205')"
    SCRATCH="$(mktemp -d)"
    dir="$SCRATCH"
    git -C "$dir" init -q
    git -C "$dir" config user.name scratch
    git -C "$dir" config user.email scratch@example.com
    git -C "$dir" config commit.gpgsign false
    git -C "$dir" config core.hooksPath /dev/null
    git -C "$dir" config core.quotePath true
    git -C "$dir" config diff.renames true
    mkdir -p "$dir/Sources/DMUnLoader" "$dir/Documentation" "$dir/DocumentationAndBluePrints/Acceptance Criteria"
    echo "let value = 1" > "$dir/Sources/DMUnLoader/Foo.swift"
    echo "text" > "$dir/README.md"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m base
    base="$(git -C "$dir" rev-parse HEAD)"
    git -C "$dir" mv Sources/DMUnLoader/Foo.swift Documentation/Foo.md
    git -C "$dir" commit -q -m moved
    expect_diff "a source file moved to Documentation/*.md runs every job" "$dir" "$base" "light=run heavy=run"
    expect_diff "a base that is not in the clone runs every job" "$dir" "0000000000000000000000000000000000000000" "light=run heavy=run"
    git -C "$dir" reset -q --hard "$base"
    echo "text" > "$dir/DocumentationAndBluePrints/Acceptance Criteria/Story - $mark.md"
    echo "text" > "$dir/User Story.md"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m documents
    expect_diff "documents with a space and a non-ASCII name skip the heavy jobs" "$dir" "$base" "light=run heavy=skip"
}

# The push cases on the scratch repository that check_real_diff made: the diff of a push is from the
# commit it replaced to HEAD, and each fall-back that runs everything has a case of its own.
check_push_diff() {
    local dir="$SCRATCH" root tip main=refs/heads/main zeros=0000000000000000000000000000000000000000
    local all="light=run heavy=run" docs="light=run heavy=skip" none="light=skip heavy=skip"
    root="$(git -C "$dir" rev-list --max-parents=0 HEAD)"
    git -C "$dir" reset -q --hard "$root"
    echo "x" > "$dir/.coderabbit.yaml"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m inert
    expect_diff "a push to main that changes only the inert file skips every job" "$dir" "$root" "$none" push "$main"
    expect_diff "the same push on a tag runs every job" "$dir" "$root" "$all" push refs/tags/1.4.0
    expect_diff "the same push on another branch runs every job" "$dir" "$root" "$all" push refs/heads/other
    expect_diff "a push whose base is 40 zeros runs every job" "$dir" "$zeros" "$all" push "$main"
    expect_diff "a push with no base runs every job" "$dir" "" "$all" push "$main"
    expect_diff "a push whose base is not a commit of the clone runs every job" "$dir" "1111111111111111111111111111111111111111" "$all" push "$main"
    expect_diff "a push that changes nothing runs every job" "$dir" "$(git -C "$dir" rev-parse HEAD)" "$all" push "$main"
    expect_diff "the inert diff on a schedule runs every job" "$dir" "$root" "$all" schedule "$main"
    expect_diff "the inert diff on a manual run runs every job" "$dir" "$root" "$all" workflow_dispatch "$main"
    expect_diff "the inert diff in a called workflow runs every job" "$dir" "$root" "$all" workflow_call "$main"
    tip="$(git -C "$dir" rev-parse HEAD)"
    echo "text" >> "$dir/README.md"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m document
    expect_diff "a push to main that changes only a document skips the heavy jobs" "$dir" "$tip" "$docs" push "$main"
    expect_diff "the push of both commits skips the heavy jobs, not the light ones" "$dir" "$root" "$docs" push "$main"
    tip="$(git -C "$dir" rev-parse HEAD)"
    echo "let value = 2" > "$dir/Sources/DMUnLoader/Foo.swift"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m source
    expect_diff "a push to main that changes a source file runs every job" "$dir" "$tip" "$all" push "$main"
    tip="$(git -C "$dir" rev-parse HEAD)"
    mkdir -p "$dir/Documentation"
    git -C "$dir" mv Sources/DMUnLoader/Foo.swift Documentation/Foo.md
    git -C "$dir" commit -q -m moved
    expect_diff "a push that moves a source file into Documentation runs every job" "$dir" "$tip" "$all" push "$main"
}

self_test() {
    local all="light=run heavy=run" docs="light=run heavy=skip" none="light=skip heavy=skip" path event
    for path in Sources/DMUnLoader/X.swift Tests/DMUnLoaderTests/X.swift Package.swift Examples/DMUnLoaderExample/X.swift Scripts/lint.sh Tools/Package.swift Fixtures/Consumer/X.swift DMUnLoader.podspec .swiftlint.yml; do
        expect "a change at $path runs every job" pull_request "$path" "$all"
    done
    expect "a change under .github runs every job" pull_request ".github/workflows/ci.yml" "$all"
    expect "a markdown file under .github runs every job" pull_request ".github/PULL_REQUEST_TEMPLATE.md" "$all"
    for path in README.md "User Story.md" LICENSE Documentation/Migration-2.0.md Documentation/Review/figure.png "DocumentationAndBluePrints/User Story.md" DocumentationAndBluePrints/diagram.png .agents/skills/x/data.json; do
        expect "the document $path alone skips the heavy jobs" pull_request "$path" "$docs"
    done
    expect "a markdown file in Sources is code" pull_request "Sources/DMUnLoader/DMUnLoader.docc/Page.md" "$all"
    expect "a README with a source file runs every job" pull_request $'README.md\nSources/DMUnLoader/X.swift' "$all"
    expect "the source file first, the README second" pull_request $'Sources/DMUnLoader/X.swift\nREADME.md' "$all"
    expect "a path that no class lists runs every job" pull_request "new/dir/x.bin" "$all"
    expect "the inert file alone skips every job" pull_request ".coderabbit.yaml" "$none"
    expect "the inert file with a README skips the heavy jobs" pull_request $'.coderabbit.yaml\nREADME.md' "$docs"
    expect "the inert file with a source file runs every job" pull_request $'.coderabbit.yaml\nSources/DMUnLoader/X.swift' "$all"
    expect "an empty list runs every job" pull_request "" "$all"
    for event in schedule workflow_dispatch workflow_call; do
        expect "the event $event runs every job whatever changed" "$event" "README.md" "$all"
        expect "the event $event runs every job for the inert file" "$event" ".coderabbit.yaml" "$all"
    done
    expect "a push of the inert file alone skips every job" push ".coderabbit.yaml" "$none"
    expect "a push of a document alone skips the heavy jobs" push "README.md" "$docs"
    expect "a push of a source file runs every job" push "Sources/DMUnLoader/X.swift" "$all"
    for path in Tests/DMUnLoaderTests/X.swift Examples/DMUnLoaderExample/X.swift Scripts/lint.sh Tools/Package.swift .github/workflows/ci.yml new/dir/x.bin; do
        expect "a push of $path runs every job" push "$path" "$all"
    done
    expect "a push with an empty list runs every job" push "" "$all"
    check_job_table
    check_real_diff
    check_push_diff
    if [ "$failures" -ne 0 ]; then
        echo "ci-changes self-test: $failures failed." >&2
        exit 1
    fi
    echo "ci-changes self-test: the decision and the job table hold."
}

case "${1-}" in
    --self-test) self_test ;;
    --classify)
        [ "$#" -eq 2 ] || { echo "usage: Scripts/ci-changes.sh --classify <event>" >&2; exit 2; }
        decide "$2"
        ;;
    "" | -*)
        echo "usage: Scripts/ci-changes.sh <event> <base sha> <ref> | --classify <event> | --self-test" >&2
        exit 2
        ;;
    *)
        [ "$#" -eq 3 ] || { echo "usage: Scripts/ci-changes.sh <event> <base sha> <ref>" >&2; exit 2; }
        run_diff "$1" "$2" "$3"
        ;;
esac
