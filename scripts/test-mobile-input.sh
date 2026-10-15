#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
# Isolate the pure input model from source/import.hx, which imports the game engine.
cp source/MobileTouchState.hx tests/MobileTouchStateTest.hx "$test_dir/"
haxe -cp "$test_dir" -main MobileTouchStateTest --interp
