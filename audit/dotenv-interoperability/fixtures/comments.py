# Comments: whole-line, inline, inside each quote style, escaped.

C = "comments"

F("comment-line", C, "A whole-line comment before an assignment", "# a comment\nKEY=value\n", intended={"KEY": "value"})
F("comment-indented", C, "An indented comment line", "   # indented\nKEY=value\n", intended={"KEY": "value"})
F("comment-commented-assignment", C, "A commented-out assignment", "#KEY=value\n", intended={})
F("comment-inline-space", C, "An inline comment after a space", "KEY=value # comment\n", intended={"KEY": "value"})
F("comment-inline-tab", C, "An inline comment after a tab", "KEY=value\t# comment\n", intended={"KEY": "value"})
F("comment-inline-nospace", C, "A # immediately after the value", "KEY=value#notcomment\n", intended=None)
F("comment-inline-empty", C, "An empty inline comment", "KEY=value #\n", intended={"KEY": "value"})
F("comment-value-starts-hash", C, "A value that starts with #", "KEY=#value\n", intended=None)
F("comment-empty-value", C, "An empty value then a comment", "KEY= # comment\n", intended=None)
F("comment-single-hash", C, "# inside single quotes", "KEY='a #b'\n", intended={"KEY": "a #b"})
F("comment-single-hash-nospace", C, "# inside single quotes, no space", "KEY='a#b'\n", intended={"KEY": "a#b"})
F("comment-double-hash", C, "# inside double quotes", 'KEY="a #b"\n', intended={"KEY": "a #b"})
F("comment-backtick-hash", C, "# inside backticks", "KEY=`a #b`\n", intended=None)
F("comment-after-double", C, "A comment after a double-quoted value", 'KEY="value" # comment\n', intended={"KEY": "value"})
F("comment-after-single-nospace", C, "A comment right after a single-quoted value", "KEY='value'#comment\n",
  intended={"KEY": "value"})
F("comment-after-double-quote-in", C, "A comment containing a double quote", 'KEY="value" # say "hi"\n',
  intended={"KEY": "value"})
F("comment-after-single-quote-in", C, "A comment containing a single quote", "KEY='value' # it's\n",
  intended={"KEY": "value"})
F("comment-escaped-hash", C, "An escaped hash in an unquoted value", "KEY=a\\#b\n", intended=None)
F("comment-escaped-hash-space", C, "An escaped hash after a space", "KEY=a \\#b\n", intended=None)
F("comment-hash-url", C, "A URL fragment: KEY=http://x/#frag", "KEY=http://x/#frag\n", intended=None)
F("comment-after-multiline", C, "A comment after a multiline double-quoted value",
  'KEY="line1\nline2" # comment\nNEXT=1\n', intended={"KEY": "line1\nline2", "NEXT": "1"})
F("comment-before-eof", C, "A comment as the last line, no newline", "KEY=value\n# end", intended={"KEY": "value"})
F("comment-double-slash", C, "A // line (comment in some formats)", "// not a comment\nKEY=value\n", intended=None)
F("comment-semicolon", C, "A ; line (INI comment)", "; not a comment\nKEY=value\n", intended=None)
