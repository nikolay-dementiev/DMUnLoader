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
# The version is pinned here and not with swiftlint_version in .swiftlint.yml: the build
# plugin named in Package.swift bundles its own SwiftLint and stops the build when the
# configuration asks for another version.
VERSION="0.65.1"
# SHA-256 of portable_swiftlint.zip of that release. It changes together with the version.
CHECKSUM="c1e429b0599cf1b516f369a2d9ec04eaf0e436f3c12b637df8851fa52ff694d0"
TOOLS="$ROOT/.build/tools/swiftlint-$VERSION"
SWIFTLINT="$TOOLS/swiftlint"

if [ ! -x "$SWIFTLINT" ]; then
    mkdir -p "$TOOLS"
    ARCHIVE="$TOOLS/portable_swiftlint.zip"
    if [ ! -f "$ARCHIVE" ]; then
        curl --fail --silent --show-error --location \
            "https://github.com/realm/SwiftLint/releases/download/$VERSION/portable_swiftlint.zip" \
            --output "$ARCHIVE"
    fi
    ACTUAL="$(shasum -a 256 "$ARCHIVE" | cut -d ' ' -f 1)"
    if [ "$ACTUAL" != "$CHECKSUM" ]; then
        echo "lint: the SwiftLint $VERSION archive has checksum $ACTUAL, expected $CHECKSUM" >&2
        exit 2
    fi
    unzip -q -o "$ARCHIVE" swiftlint -d "$TOOLS"
fi

cd "$ROOT"
"$SWIFTLINT" lint --strict --quiet

if [ "${1:-}" = "--analyze" ]; then
    "$SWIFTLINT" analyze --strict --quiet --compiler-log-path "${2:?give the path of an xcodebuild log}"
fi

echo "lint: no violations (SwiftLint $("$SWIFTLINT" version))."
