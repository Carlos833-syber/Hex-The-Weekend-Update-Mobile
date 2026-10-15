#!/usr/bin/env bash
set -euo pipefail
# Keep this stack together: Hex uses the HaxeFlixel 4.x drawing API.
haxelib install lime 7.9.0 --quiet
haxelib install openfl 9.2.0 --quiet
haxelib install flixel 4.11.0 --quiet
haxelib install flixel-addons 2.11.0 --quiet
haxelib install flixel-ui 2.5.0 --quiet
haxelib install hscript 2.4.0 --quiet
haxelib install actuate 1.8.9 --quiet
haxelib install polymod 1.3.1 --quiet
haxelib install hxcpp 4.2.1 --quiet
# Select exact versions even when other projects have installed newer ones.
for dependency in "lime 7.9.0" "openfl 9.2.0" "flixel 4.11.0" "flixel-addons 2.11.0" "flixel-ui 2.5.0" "hscript 2.4.0" "actuate 1.8.9" "polymod 1.3.1" "hxcpp 4.2.1"; do
  read -r library version <<< "$dependency"
  haxelib set "$library" "$version"
done
python3 scripts/patch-flixel-renderer.py
