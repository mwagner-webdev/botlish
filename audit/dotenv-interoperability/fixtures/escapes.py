# Escape sequences, each in an unquoted, a single-quoted and a double-quoted
# value. The text column is the escape exactly as written in the file.

E = "escapes"

ESCAPES = [
    ("backslash", "\\", "a lone backslash"),
    ("double-backslash", "\\\\", "an escaped backslash"),
    ("n", "\\n", "backslash-n"),
    ("r", "\\r", "backslash-r"),
    ("t", "\\t", "backslash-t"),
    ("dquote", '\\"', "backslash-double-quote"),
    ("squote", "\\'", "backslash-single-quote"),
    ("dollar", "\\$", "backslash-dollar"),
    ("hash", "\\#", "backslash-hash"),
    ("unknown-x", "\\x", "an unknown escape (backslash-x)"),
    ("unicode-u", "\\u00e9", "a \\u escape"),
    ("octal", "\\101", "an octal escape"),
    ("backtick", "\\`", "backslash-backtick"),
    ("space", "\\ ", "backslash-space"),
]

for slug, esc, what in ESCAPES:
    for ctx, open_, close in [("unquoted", "", ""), ("single", "'", "'"), ("double", '"', '"')]:
        if ctx == "single" and esc.endswith("'"):
            continue  # cannot be written inside single quotes; see quote-escaped-single
        F("esc-%s-%s" % (slug, ctx), E, "%s in a %s value: %s" % (what, ctx, esc),
          "KEY=%sa%sb%s\n" % (open_, esc, close), intended=None)

F("esc-line-continuation-unquoted", E, "A backslash at the end of an unquoted line",
  "KEY=first\\\nsecond\nNEXT=1\n", intended=None)
F("esc-line-continuation-double", E, "A backslash before the newline inside double quotes",
  'KEY="first\\\nsecond"\nNEXT=1\n', intended=None)
F("esc-trailing-backslash-double", E, "A double-quoted value ending in an escaped backslash",
  'KEY="a\\\\"\n', intended={"KEY": "a\\"})
F("esc-crlf-literal", E, "Backslash-r backslash-n inside double quotes", 'KEY="a\\r\\nb"\n', intended=None)
F("esc-ansi-c", E, "Bash ANSI-C quoting $'a\\nb'", "KEY=$'a\\nb'\n", intended=None)
