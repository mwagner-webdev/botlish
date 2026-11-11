#!/usr/bin/env python3
"""release.py -- Botlish.app's release (MACOS-BOTLISH-DISTRIBUTION-
MILESTONE-1.md): the stages of tools/macos-release/release.py, every
application's -- the credential preflight, the temporary keychain, Apple's
validation of the notarization key, the Developer ID signature, its
verification, notarization, stapling, Gatekeeper, the tamper control, the
ZIP and publishable -- for the compiler's application, whose bundle module
is bundle.py beside this file: its three signing units signed inner first by
single/macos/sign.sh, each verified, its identifier fixed
(io.github.mwagner-webdev.botlish: MACOS_BUNDLE_ID is not read).

    python3 -I single/macos/release.py STAGE --work DIR [options]

The stages, their options and their diagnostics are the shared tool's: see
its own documentation.
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SHARED = os.path.join(HERE, "..", "..", "tools", "macos-release")
sys.path.insert(0, HERE)
sys.path.insert(0, SHARED)
import bundle  # noqa: E402

spec = importlib.util.spec_from_file_location("macos_release", os.path.join(SHARED, "release.py"))
core = importlib.util.module_from_spec(spec)
spec.loader.exec_module(core)

if __name__ == "__main__":
    sys.exit(core.main(sys.argv[1:], bundle))
