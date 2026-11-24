#!/bin/sh
# Build THETRIS.EXE headlessly in DOSBox-X and print its SHA-256.
#
# usage: tools/build.sh [git-rev]
#
# Without an argument the working tree is built and THETRIS.EXE and
# THETRIS.MAP are copied back to the repository root. With a git revision
# that revision is built instead and nothing is copied back, which gives a
# reference hash to compare a working-tree build against.
#
# Needs dosbox-x on the PATH and TASM_DIR pointing at a directory that holds
# TASM.EXE and TLINK.EXE. Exits non-zero when the build fails or the
# assembler or linker reports an error or a warning.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REV="${1:-}"
TIMEOUT=180

fail() { echo "build.sh: $*" >&2; exit 2; }

command -v dosbox-x >/dev/null 2>&1 || fail "dosbox-x not found on the PATH"
[ -n "${TASM_DIR:-}" ] || fail "TASM_DIR is not set"
[ -f "$TASM_DIR/TASM.EXE" ] && [ -f "$TASM_DIR/TLINK.EXE" ] ||
    fail "TASM.EXE and TLINK.EXE not found in $TASM_DIR"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/thetris-build.XXXXXX")" || fail "mktemp failed"
trap 'rm -rf "$WORK"' EXIT
mkdir "$WORK/c"

if [ -n "$REV" ]; then
    git -C "$ROOT" archive "$REV" | tar -x -C "$WORK/c" || fail "cannot export $REV"
else
    (cd "$ROOT" && tar -c --exclude .git --exclude screenshots \
        --exclude obj --exclude 'THETRIS.EXE' --exclude 'THETRIS.MAP' .) |
        tar -x -C "$WORK/c" || fail "cannot copy the working tree"
fi

# DOSBox-X does not pass a redirection on CALL down to the programs the
# batch file runs, so build with a copy of MAKE.BAT that logs each tool.
sed -e 's/^\(for .* tasm .*\)\r$/\1 >> BUILD.LOG\r/' \
    -e 's/^\(tasm .*\)\r$/\1 >> BUILD.LOG\r/' \
    -e 's/^\(tlink .*\)\r$/\1 >> BUILD.LOG\r/' \
    "$WORK/c/MAKE.BAT" > "$WORK/c/_BUILD.BAT"

SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy dosbox-x -silent -fastlaunch -nomenu \
    -defaultconf -set "dosbox quit warning=false" -set "cpu cycles=max" \
    -c "mount c \"$WORK/c\"" -c "mount d \"$TASM_DIR\"" -c "set PATH=D:\;Z:\\" \
    -c "c:" -c "call _build.bat" -c "exit" > "$WORK/dosbox.out" 2>&1 &
pid=$!
(sleep "$TIMEOUT"; kill "$pid" 2>/dev/null) > /dev/null 2>&1 &
watchdog=$!
wait "$pid"
kill "$watchdog" 2>/dev/null
wait "$watchdog" 2>/dev/null

LOG="$WORK/c/BUILD.LOG"
[ -f "$LOG" ] || fail "DOSBox-X produced no build log (timed out after ${TIMEOUT}s?)"

status=0
if LC_ALL=C grep -q -e '\*\*Error\*\*' -e '\*Warning\*' -e '\*\*Fatal\*\*' \
    -e '^Error:' -e '^Warning:' -e '^Fatal:' \
    -e '^Error messages: *[0-9]' -e '^Warning messages: *[0-9]' "$LOG"; then
    status=1
fi

# Print the log without the banner and summary noise of a clean run.
LC_ALL=C tr -d '\r' < "$LOG" | LC_ALL=C grep -v -e '^$' -e '^Turbo Assembler' \
    -e '^Turbo Link' -e '^Assembling file' -e '^Remaining memory' \
    -e '^Error messages: *None' -e '^Warning messages: *None' -e '^Passes:'

[ -f "$WORK/c/THETRIS.EXE" ] || { echo "build.sh: THETRIS.EXE was not produced" >&2; exit 1; }

if [ -z "$REV" ]; then
    cp "$WORK/c/THETRIS.EXE" "$ROOT/THETRIS.EXE"
    [ -f "$WORK/c/THETRIS.MAP" ] && cp "$WORK/c/THETRIS.MAP" "$ROOT/THETRIS.MAP"
fi

(cd "$WORK/c" && shasum -a 256 THETRIS.EXE)
exit "$status"
