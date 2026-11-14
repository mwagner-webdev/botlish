# Malformed input: whole-file rejection, skipped lines, partial success.

X = "malformed"

F("bad-missing-delimiter", X, "A line without a delimiter between key and value", "KEY value\nNEXT=1\n", intended=None)
F("bad-garbage-line", X, "A garbage line between two assignments", "A=1\n!@#%^&*\nB=2\n", intended=None)
F("bad-invalid-key-middle", X, "An invalid key between two valid lines", "A=1\n1-bad=x\nB=2\n", intended=None)
F("bad-broken-quote-middle", X, "A broken quote between two valid lines", "A=1\nBAD=\"oops\nB=2\n", intended=None)
F("bad-equals-only", X, "A line that is only =", "=\nA=1\n", intended=None)
F("bad-key-only-spaces", X, "A key of spaces: '   =value'", "   =value\nA=1\n", intended=None)
F("bad-truncated-quote-eof", X, "An unterminated quote at the end of the file without newline", 'A=1\nB="abc', intended=None)
F("bad-text-after-quote", X, "Unexpected text after a quoted value", 'A="x" y z\nB=2\n', intended=None)
F("bad-unbalanced-brace", X, "An unbalanced ${ in a value", "A=${\nB=2\n", intended=None)
F("bad-long-line", X, "One 100,000-byte value", "KEY=" + "x" * 100000 + "\nNEXT=1\n", intended=None,
  modes=("clean",))
F("bad-long-key", X, "One 10,000-byte key", "K" * 10000 + "=value\n", intended=None, modes=("clean",))
F("bad-many-lines", X, "Ten thousand assignments", "".join("K%05d=v\n" % i for i in range(10000)), intended=None,
  modes=("clean",))
F("bad-deep-quotes", X, "A value of 5,000 alternating quote characters", "KEY=" + "\"'" * 2500 + "\n", intended=None,
  modes=("clean",))
F("bad-many-dollars", X, "A value of 5,000 ${ openings", "KEY=" + "${" * 5000 + "\n", intended=None, modes=("clean",))
F("bad-binary-junk", X, "A line of binary junk", b"A=1\n\x01\x02\x03\x04\nB=2\n", intended=None)
F("bad-only-comment-marker", X, "A line that is only #", "#\nA=1\n", intended=None)
F("bad-unterminated-backtick-middle", X, "An unterminated backtick between two valid lines", "A=1\nBAD=`oops\nB=2\n", intended=None)
