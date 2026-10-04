#!/bin/bash
#
# Proves that the committed example project is what its XcodeGen spec generates.
#
#   Scripts/check-example-project.sh    exit 0 when they match, 1 when they differ,
#                                       2 when XcodeGen is not installed
#
# Examples/DMUnLoaderExample/project.yml is the source. The generated project is committed
# so that nobody needs a tool to open it. After a change to the spec or to the list of
# source files, regenerate and commit both:
#
#   xcodegen generate --spec Examples/DMUnLoaderExample/project.yml --project Examples/DMUnLoaderExample
#
# This is a local check. CI does not install the generator.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE="Examples/DMUnLoaderExample"
PROJECT="DMUnLoaderExample.xcodeproj"
GENERATOR_VERSION="2.45.3"

if ! command -v xcodegen > /dev/null; then
    echo "check-example-project: XcodeGen is not installed. The project was generated with $GENERATOR_VERSION." >&2
    exit 2
fi

INSTALLED="$(xcodegen --version | sed 's/^Version: //')"
if [ "$INSTALLED" != "$GENERATOR_VERSION" ]; then
    echo "check-example-project: note: the project was generated with XcodeGen $GENERATOR_VERSION," >&2
    echo "  this machine has $INSTALLED. A difference may come from the generator, not from the spec." >&2
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The project file records paths relative to the example folder and names the package
# reference after the folder of the checkout. The copy keeps the same depth below a
# stand-in for the repository root, named as the repository is.
COPY="$WORK/DMUnLoader/$EXAMPLE"
mkdir -p "$COPY"
rsync -a --exclude "$PROJECT" "$ROOT/$EXAMPLE/" "$COPY/"

if ! xcodegen generate --quiet --spec "$COPY/project.yml" --project "$COPY" > "$WORK/xcodegen.log" 2>&1; then
    echo "check-example-project: xcodegen could not generate the project." >&2
    cat "$WORK/xcodegen.log" >&2
    exit 2
fi

# User data and the resolved package versions are not generated from the spec.
if diff -r -u \
    --exclude xcuserdata --exclude swiftpm \
    "$ROOT/$EXAMPLE/$PROJECT" "$COPY/$PROJECT" > "$WORK/project.diff"; then
    echo "check-example-project: the committed project matches its spec ($(xcodegen --version))."
    exit 0
fi

echo "check-example-project: the committed project differs from what project.yml generates." >&2
echo "  Regenerate it with the command at the top of this script and commit the result." >&2
cat "$WORK/project.diff" >&2
exit 1
