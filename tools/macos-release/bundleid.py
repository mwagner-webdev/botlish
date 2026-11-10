#!/usr/bin/env python3
"""bundleid.py -- a macOS application's bundle identifier, and the release
tooling's refusals (tools/macos-release/; ICY-TOWER-MACOS-APP-MILESTONE-1.md,
"Application metadata"; MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md).

Shared by every application the release tooling signs and notarizes: Icy
Tower.app (examples/games/icy-tower/macos/bundle.py) and Botlish.app
(single/macos/bundle.py). A refusal is one line, `CODE: what is wrong` with
the remedy, CODE one of the release's stable diagnostic codes.
"""
import re


class Refused(Exception):
    def __init__(self, code, text):
        super().__init__("%s: %s" % (code, text))
        self.code = code


def refuse(code, text):
    raise Refused(code, text)



# CFBundleIdentifier: "only alphanumeric characters (A-Z, a-z, 0-9), hyphens
# (-) and periods (.)", reverse-DNS: at least two non-empty components.
IDENTIFIER = re.compile(r"[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+")


def check_identifier(value, name="MACOS_BUNDLE_ID"):
    """The bundle identifier VALUE, or a refusal naming where it came from (NAME)."""
    if value is None or value == "":
        refuse("MACOS-BUNDLE-METADATA", "%s is empty: set it to the application's stable reverse-DNS bundle "
               "identifier (for example com.example.icy-tower)" % name)
    if value != value.strip():
        refuse("MACOS-BUNDLE-METADATA", "%s has leading or trailing white space: enter the identifier alone" % name)
    if any(ord(c) < 32 or ord(c) == 127 for c in value):
        refuse("MACOS-BUNDLE-METADATA", "%s holds a control character (a line break?): enter the identifier alone" % name)
    if len(value) > 255:
        refuse("MACOS-BUNDLE-METADATA", "%s is %d characters long; a bundle identifier has at most 255" % (name, len(value)))
    for bad, why in (("/", "a path separator"), (" ", "a space"), ("*", "a wildcard"), ("$", "a shell substitution"),
                     ("`", "a shell substitution"), ("_", "an underscore"), ('"', "a quotation mark"), ("'", "a quotation mark")):
        if bad in value:
            refuse("MACOS-BUNDLE-METADATA", "%s holds %s; a bundle identifier is letters, digits, hyphens and periods, "
                   "reverse-DNS (com.example.icy-tower)" % (name, why))
    if not IDENTIFIER.fullmatch(value):
        refuse("MACOS-BUNDLE-METADATA", "%s is not a reverse-DNS bundle identifier: letters (A-Z, a-z), digits, hyphens "
               "and periods, at least two components, none empty (com.example.icy-tower)" % name)
    if value.lower().startswith("com.apple."):
        refuse("MACOS-BUNDLE-METADATA", "%s is in Apple's reserved com.apple. domain: use a domain of your own" % name)
    return value
