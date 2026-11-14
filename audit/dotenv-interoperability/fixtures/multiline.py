# Multiline values.

M = "multiline"

F("ml-double", M, "A literal newline inside double quotes", 'KEY="line1\nline2"\n', intended={"KEY": "line1\nline2"})
F("ml-single", M, "A literal newline inside single quotes", "KEY='line1\nline2'\n", intended={"KEY": "line1\nline2"})
F("ml-backtick", M, "A literal newline inside backticks", "KEY=`line1\nline2`\n", intended=None)
F("ml-double-then-next", M, "A multiline double-quoted value followed by an assignment",
  'KEY="line1\nline2"\nNEXT=1\n', intended={"KEY": "line1\nline2", "NEXT": "1"})
F("ml-single-then-next", M, "A multiline single-quoted value followed by an assignment",
  "KEY='line1\nline2'\nNEXT=1\n", intended={"KEY": "line1\nline2", "NEXT": "1"})
F("ml-double-crlf", M, "CRLF inside a double-quoted value", 'KEY="line1\r\nline2"\r\n', intended=None)
F("ml-single-crlf", M, "CRLF inside a single-quoted value", "KEY='line1\r\nline2'\r\n", intended=None)
F("ml-double-blank-lines", M, "Blank lines inside a double-quoted value", 'KEY="a\n\n\nb"\n', intended={"KEY": "a\n\n\nb"})
F("ml-double-leading-newline", M, "A double-quoted value starting with a newline", 'KEY="\nb"\n', intended={"KEY": "\nb"})
F("ml-double-trailing-newline", M, "A double-quoted value ending with a newline", 'KEY="a\n"\n', intended={"KEY": "a\n"})
F("ml-double-hash-line", M, "A line starting with # inside a double-quoted value", 'KEY="a\n# not a comment\nb"\n',
  intended={"KEY": "a\n# not a comment\nb"})
F("ml-double-assignment-line", M, "A line that looks like an assignment inside a quoted value",
  'KEY="a\nOTHER=x\nb"\n', intended={"KEY": "a\nOTHER=x\nb"})
F("ml-double-indented", M, "Indented continuation lines inside double quotes", 'KEY="a\n    b"\n', intended={"KEY": "a\n    b"})
F("ml-pem", M, "A PEM-like block in double quotes",
  'CERT="-----BEGIN TEST-----\nQUJD\nREVG\n-----END TEST-----"\n',
  intended={"CERT": "-----BEGIN TEST-----\nQUJD\nREVG\n-----END TEST-----"})
F("ml-unterminated-double", M, "An unterminated multiline double-quoted value", 'KEY="line1\nline2\n', intended=None)
F("ml-unterminated-single", M, "An unterminated multiline single-quoted value", "KEY='line1\nline2\n", intended=None)
F("ml-escaped-newline-double", M, "Backslash-n inside double quotes (escape, not a newline)", 'KEY="a\\nb"\n', intended=None)
F("ml-closing-quote-then-comment", M, "A comment after the closing quote of a multiline value",
  'KEY="a\nb" # c\n', intended={"KEY": "a\nb"})
F("ml-closing-quote-then-text", M, "Text after the closing quote of a multiline value", 'KEY="a\nb"tail\nNEXT=1\n', intended=None)
F("ml-two-multiline", M, "Two multiline values in a row", 'A="1\n2"\nB="3\n4"\n', intended={"A": "1\n2", "B": "3\n4"})
F("ml-quote-inside-escaped", M, "An escaped double quote inside a multiline double-quoted value",
  'KEY="a\\"\nb"\n', intended={"KEY": 'a"\nb'})
F("ml-unquoted-newline-only", M, "An unquoted value never continues on the next line", "KEY=a\nb\n", intended=None)
