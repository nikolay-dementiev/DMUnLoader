#!/bin/bash
#
# Proves that installing the example deletes nothing outside the example folder.
#
#   Scripts/check-example-install.sh    exit 0 when the helper is contained, 1 when it
#                                       deleted or changed something, 2 when it could not
#                                       be run to the end
#
# The Podfile's cleanup helper runs with an isolated home folder. The home folder holds
# files where Xcode keeps its data, and it has to look the same afterwards. A stand-in
# for xcodebuild lists one scheme, so the helper runs its whole cleanup loop.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT/Examples/DMUnLoaderPodSPMExample/podInstall_helper.rb"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

HOME_DIR="$SANDBOX/home"
mkdir -p "$SANDBOX/work" "$SANDBOX/bin" \
    "$HOME_DIR/Library/Developer/Xcode/DerivedData/another-project" \
    "$HOME_DIR/Library/Developer/Xcode/Archives" \
    "$HOME_DIR/Library/Caches/org.swift.swiftpm"
: > "$HOME_DIR/Library/Developer/Xcode/DerivedData/another-project/marker"
: > "$HOME_DIR/Library/Developer/Xcode/Archives/marker"
: > "$HOME_DIR/Library/Caches/org.swift.swiftpm/marker"
: > "$HOME_DIR/marker"

cat > "$SANDBOX/bin/xcodebuild" <<'EOF'
#!/bin/bash
# Stands in for xcodebuild: records the call, lists one scheme, changes nothing.
echo "$*" >> "$(dirname "$0")/../xcodebuild.calls"
case " $* " in
    *" -list "*)
        printf 'Information about workspace "DMUnLoaderPodSPMExample":\n    Schemes:\n        DMUnLoaderPodSPMExample\n\n'
        ;;
esac
exit 0
EOF
chmod +x "$SANDBOX/bin/xcodebuild"

# The helper expands "~" itself. Stop unless Ruby resolves it inside the sandbox, so a
# broken isolation can never reach the real home folder.
RESOLVED="$(HOME="$HOME_DIR" ruby -e 'print File.expand_path("~/Library/Developer/Xcode/DerivedData")')"
case "$RESOLVED" in
    "$HOME_DIR"/*) ;;
    *)
        echo "check-example-install: the home folder is not isolated ($RESOLVED)." >&2
        exit 2
        ;;
esac

listing() {
    find "$HOME_DIR" | LC_ALL=C sort
}
BEFORE="$(listing)"

if ! (
    cd "$SANDBOX/work"
    HOME="$HOME_DIR" PATH="$SANDBOX/bin:$PATH" \
        ruby -e 'require ARGV[0]; clean_xcode_project("DMUnLoaderPodSPMExample")' "$HELPER"
) > "$SANDBOX/helper.log" 2>&1; then
    echo "check-example-install: the helper did not run:" >&2
    cat "$SANDBOX/helper.log" >&2
    exit 2
fi

if ! grep -q "Cleanup complete!" "$SANDBOX/helper.log" || ! grep -q -- "clean -workspace" "$SANDBOX/xcodebuild.calls" 2>/dev/null; then
    echo "check-example-install: the helper did not run its cleanup loop:" >&2
    cat "$SANDBOX/helper.log" >&2
    exit 2
fi

if [ "$BEFORE" = "$(listing)" ]; then
    echo "check-example-install: nothing outside the example folder was deleted."
    exit 0
fi

echo "check-example-install: the install helper deleted or added files in the home folder:" >&2
diff <(echo "$BEFORE") <(listing) | sed "s|$HOME_DIR|~|" >&2 || true
exit 1
