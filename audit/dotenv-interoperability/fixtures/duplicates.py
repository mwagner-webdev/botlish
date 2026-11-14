# Duplicate assignments within one file.

D = "duplicates"

F("dup-identical", D, "The same assignment twice", "KEY=value\nKEY=value\n", intended=None)
F("dup-different", D, "Two different values for one key", "KEY=first\nKEY=second\n", intended=None)
F("dup-three", D, "Three values for one key", "KEY=first\nKEY=second\nKEY=third\n", intended=None)
F("dup-separated", D, "Duplicates separated by comments and other keys",
  "KEY=first\n# comment\nOTHER=x\n\nKEY=second\n", intended=None)
F("dup-quoting", D, "Duplicates with different quoting", "KEY='first'\nKEY=\"second\"\n", intended=None)
F("dup-case", D, "Keys differing only by case", "KEY=upper\nkey=lower\n", intended=None)
F("dup-second-empty", D, "A value, then an empty value", "KEY=first\nKEY=\n", intended=None)
F("dup-second-bare", D, "A value, then a bare key", "KEY=first\nKEY\n", intended=None)
F("dup-export", D, "A value, then an exported value", "KEY=first\nexport KEY=second\n", intended=None)
F("dup-interp", D, "A second value referencing the first", "KEY=first\nKEY=${KEY}-second\n", intended=None)
F("dup-multiline", D, "A multiline value, then a single-line duplicate", 'KEY="a\nb"\nKEY=c\n', intended=None)
F("dup-after-malformed", D, "A duplicate after a malformed line", "KEY=first\nnot a line\nKEY=second\n", intended=None)
