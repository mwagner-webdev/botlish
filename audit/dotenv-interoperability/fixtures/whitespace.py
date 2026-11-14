# Whitespace in values: preservation and trimming, per quoting.

W = "whitespace"

for slug, ctx, open_, close in [("unquoted", "unquoted", "", ""), ("single", "single-quoted", "'", "'"),
                                ("double", "double-quoted", '"', '"')]:
    F("ws-leading-" + slug, W, "Leading spaces in a %s value" % ctx, "KEY=%s  value%s\n" % (open_, close),
      intended={"KEY": "  value"} if open_ else None)
    F("ws-trailing-" + slug, W, "Trailing spaces in a %s value" % ctx, "KEY=%svalue  %s\n" % (open_, close),
      intended={"KEY": "value  "} if open_ else None)
    F("ws-internal-" + slug, W, "Two inner spaces in a %s value" % ctx, "KEY=%sa  b%s\n" % (open_, close),
      intended={"KEY": "a  b"})
    F("ws-tab-" + slug, W, "An inner tab in a %s value" % ctx, "KEY=%sa\tb%s\n" % (open_, close),
      intended={"KEY": "a\tb"})
    F("ws-only-" + slug, W, "A %s value of spaces only" % ctx, "KEY=%s   %s\n" % (open_, close),
      intended={"KEY": "   "} if open_ else None)
    F("ws-nbsp-" + slug, W, "No-break spaces (U+00A0) around a %s value" % ctx,
      "KEY=%s\u00a0value\u00a0%s\n" % (open_, close), intended={"KEY": "\u00a0value\u00a0"})
    F("ws-emspace-" + slug, W, "Em spaces (U+2003) around a %s value" % ctx,
      "KEY=%s\u2003value\u2003%s\n" % (open_, close), intended={"KEY": "\u2003value\u2003"})
    F("ws-ideographic-" + slug, W, "Ideographic spaces (U+3000) around a %s value" % ctx,
      "KEY=%s\u3000value\u3000%s\n" % (open_, close), intended={"KEY": "\u3000value\u3000"})
    F("ws-before-comment-" + slug, W, "Spaces before an inline comment after a %s value" % ctx,
      "KEY=%svalue%s    # c\n" % (open_, close), intended={"KEY": "value"})

F("ws-vertical-tab", W, "A vertical tab inside an unquoted value", "KEY=a\x0bb\n", intended=None)
F("ws-form-feed", W, "A form feed inside an unquoted value", "KEY=a\x0cb\n", intended=None)
F("ws-zwsp", W, "A zero-width space (U+200B) inside a value", "KEY=a\u200bb\n", intended={"KEY": "a\u200bb"})
F("ws-feff-inside", W, "U+FEFF inside a value (not at the start of the file)", "KEY=a\ufeffb\n",
  intended={"KEY": "a\ufeffb"})
