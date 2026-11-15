# Variable names: what each implementation accepts as a key, ignores or
# rejects. Every fixture assigns the plain value "value" so only the key's
# spelling varies; `intended` is the key as written (no implementation is
# obliged to accept it -- the portable profile is derived from which do).

NAMES = [
    ("upper", "KEY", "uppercase ASCII"),
    ("lower", "key", "lowercase ASCII"),
    ("mixed-case", "MyKey", "mixed case"),
    ("underscore-lead", "_KEY", "leading underscore"),
    ("underscore-only", "_", "a lone underscore (special in Bash)"),
    ("digit-after", "KEY2", "digits after the first character"),
    ("digit-lead", "2KEY", "a leading digit"),
    ("digits-only", "123", "digits only"),
    ("hyphen", "MY-KEY", "a hyphen"),
    ("dot", "my.key", "a dot"),
    ("dot-lead", ".KEY", "a leading dot"),
    ("colon", "A:B", "a colon"),
    ("slash", "A/B", "a slash"),
    ("at", "A@B", "an at sign"),
    ("plus", "A+B", "a plus sign"),
    ("brackets", "A[0]", "brackets (Bash array syntax)"),
    ("dollar", "A$B", "a dollar sign"),
    ("space", "MY KEY", "an inner space"),
    ("latin1-range", "CL\u00c9", "a non-ASCII Latin letter (UTF-8)"),
    ("cjk", "\u952e", "a CJK ideograph"),
    ("emoji", "K\U0001f600", "an emoji"),
    ("combining", "CLE\u0301", "a combining acute accent (decomposed form)"),
    ("builtin-echo", "echo", "a Bash builtin's name"),
    ("reserved-if", "if", "a shell reserved word"),
    ("reserved-function", "function", "a shell reserved word"),
    ("export", "export", "the word export as a key"),
    ("unset", "unset", "a builtin's name"),
    ("long-256", "K" * 256, "a 256-character key"),
    ("arabic-digit", "K\u0663", "a non-ASCII digit"),
    ("tab-inside", "MY\tKEY", "a tab inside the key"),
]

for slug, name, what in NAMES:
    F("name-" + slug, "names", "Key with %s: %r=value" % (what, name[:40]), name + "=value\n",
      intended={name: "value"})

F("name-empty", "names", "Empty key: =value", "=value\n", intended=None)
F("name-case-pair", "names", "Keys differing only by case are distinct (key, KEY)",
  "key=lower\nKEY=upper\n", intended={"key": "lower", "KEY": "upper"})
F("name-nfc-nfd-pair", "names", "Keys that are canonically equivalent Unicode (NFC vs NFD)",
  "CL\u00c9=nfc\nCLE\u0301=nfd\n", intended={"CL\u00c9": "nfc", "CLE\u0301": "nfd"})
F("name-quoted-double", "names", 'A double-quoted key: "KEY"=value', '"KEY"=value\n', intended=None)
F("name-quoted-single", "names", "A single-quoted key: 'KEY'=value", "'KEY'=value\n", intended=None)
F("name-shell-special-home", "names", "A key Bash treats specially (HOME)", "HOME=/census/home\n",
  intended={"HOME": "/census/home"}, modes=("clean",))
F("name-shell-special-path", "names", "A key Bash treats specially (PATH)", "PATH=/census/bin\n",
  intended={"PATH": "/census/bin"}, modes=("clean",))
