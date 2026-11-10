#!/usr/bin/env python3
"""release.py -- Icy Tower.app's release (ICY-TOWER-MACOS-APP-MILESTONE-1.md,
"Release pipeline"): the stages of tools/macos-release/release.py, every
application's, for this one -- its bundle module is bundle.py beside this
file (the game's name, executable and resources, its bundle's checks, its
ZIP, notarytool profile and keychain; the identifier is MACOS_BUNDLE_ID's).

    python3 -I examples/games/icy-tower/macos/release.py STAGE --work DIR [options]

The stages, their options and their diagnostics are the shared tool's: see
its own documentation.
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SHARED = os.path.join(HERE, "..", "..", "..", "..", "tools", "macos-release")
sys.path.insert(0, HERE)
sys.path.insert(0, SHARED)
import bundle  # noqa: E402

spec = importlib.util.spec_from_file_location("macos_release", os.path.join(SHARED, "release.py"))
core = importlib.util.module_from_spec(spec)
spec.loader.exec_module(core)

if __name__ == "__main__":
    sys.exit(core.main(sys.argv[1:], bundle))
