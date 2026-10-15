#!/usr/bin/env python3
"""Install the exact renderer workaround supplied by this mod's README."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
readme = (root / "README.md").read_text(encoding="utf-8")
renderer = readme.split("```haxe\n", 1)[1].split("```", 1)[0]
if "class FlxDrawQuadsItem" not in renderer:
    raise SystemExit("README renderer workaround missing")
paths = subprocess.check_output(["haxelib", "path", "flixel"], text=True).splitlines()
for path in paths:
    if path.startswith("-"):
        continue
    target = Path(path) / "flixel/graphics/tile/FlxDrawQuadsItem.hx"
    if target.is_file():
        target.write_text(renderer, encoding="utf-8")
        print("Installed Hex renderer workaround:", target)
        break
else:
    raise SystemExit("Cannot find installed Flixel renderer")

# Lime 7 predates Android 12's exported activity requirement and JCenter retirement.
lime_paths = subprocess.check_output(["haxelib", "path", "lime"], text=True).splitlines()
for path in lime_paths:
    if path.startswith("-"):
        continue
    templates = Path(path).parent / "templates/android/template"
    if not templates.is_dir():
        templates = Path(path) / "templates/android/template"
    if templates.is_dir():
        manifest = templates / "app/src/main/AndroidManifest.xml"
        text = manifest.read_text(encoding="utf-8")
        text = text.replace('android:name="MainActivity" android:launchMode',
                            'android:name="MainActivity" android:exported="true" android:launchMode')
        manifest.write_text(text, encoding="utf-8")
        gradle = templates / "build.gradle"
        gradle.write_text(gradle.read_text(encoding="utf-8").replace("jcenter()", "mavenCentral()"), encoding="utf-8")
        print("Updated legacy Lime Android templates:", templates)
        break
else:
    raise SystemExit("Cannot find installed Lime Android templates")
