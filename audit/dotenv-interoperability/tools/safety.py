r"""The census's static safety classification of a fixture's bytes.

A sourced dotenv file is shell code. The census runs Bash only on a fixture
this classifier proves to be a sequence of plain assignments in a small,
audited subset of Bash's grammar, and runs a process-loading target (Node's
--env-file, Bun, DotNetEnv's default load) only on a fixture that cannot name a
variable those runtimes obey at startup. Nothing here interprets dotenv: it
decides only what may be executed.

classify(data) -> {
  "bash":   {"run": bool, "reasons": [...]},   # reasons it may NOT run, or the
                                              # benign expansions it contains
  "loader": {"run": bool, "reasons": [...]},
  "commands": bool,                           # a "$(" or "`" anywhere: Ruby's
                                              # dotenv would run a command
}

The Bash subset, statement by statement (bash 5, non-interactive, sourced):

  blank lines, comments          # ... to the end of the line
  [export ]NAME=WORD[ NAME=WORD]* [# comment]
  export NAME[ NAME]*

  NAME   [A-Za-z_][A-Za-z0-9_]*, not a variable Bash or a restricted shell
         treats specially (SPECIAL)
  WORD   a concatenation of: unquoted characters other than blanks and
         ; & | < > ( ) ` $ \ ' " (with ~ allowed: tilde expansion reads HOME);
         \C; '...'; $'...' (ANSI-C quoting); "..." holding characters, \C and
         the expansions below; and the expansions below
  EXPANSION  $NAME, ${NAME}, ${NAME:-W}, ${NAME-W}, ${NAME:+W}, ${NAME+W}
         (W a WORD of the same subset; NAME not in SPECIAL, whose values
         depend on the host or the run: $RANDOM, $HOME, $PPID ...), the
         special parameters $0..$9 $# $? $- $* $@ (never $$ or $!, a process
         id), and a $ that starts no expansion

Anything else -- a word that is not an assignment (a command), "$(", "`",
"$((", "$[", "$\"", other ${...} forms, control operators, redirections,
array assignments, arithmetic -- makes the fixture unsafe: it is classified,
never run. An unterminated quote or ${ is a syntax error Bash reports without
running anything, and is allowed (reason "syntax").
"""

import re

NAME = re.compile(rb"[A-Za-z_][A-Za-z0-9_]*")

# Variables Bash, a restricted shell or the census's dump treat specially:
# readonly, restricted, shell state, prompts and hooks that can run code,
# variables that change how the dump splits words.
SPECIAL = {
    b"BASH", b"BASHOPTS", b"BASHPID", b"BASH_ALIASES", b"BASH_ARGC", b"BASH_ARGV",
    b"BASH_ARGV0", b"BASH_CMDS", b"BASH_COMMAND", b"BASH_COMPAT", b"BASH_ENV",
    b"BASH_EXECUTION_STRING", b"BASH_LINENO", b"BASH_LOADABLES_PATH", b"BASH_REMATCH",
    b"BASH_SOURCE", b"BASH_SUBSHELL", b"BASH_VERSINFO", b"BASH_VERSION", b"BASH_XTRACEFD",
    b"CDPATH", b"CHILD_MAX", b"COLUMNS", b"COMP_CWORD", b"COMP_LINE", b"COMP_POINT",
    b"COMP_TYPE", b"COMP_KEY", b"COMP_WORDBREAKS", b"COMP_WORDS", b"COMPREPLY", b"COPROC",
    b"DIRSTACK", b"EMACS", b"ENV", b"EPOCHREALTIME", b"EPOCHSECONDS", b"EUID", b"EXECIGNORE",
    b"FCEDIT", b"FIGNORE", b"FUNCNAME", b"FUNCNEST", b"GLOBIGNORE", b"GLOBSORT", b"GROUPS",
    b"HISTCMD", b"HISTCONTROL", b"HISTFILE", b"HISTFILESIZE", b"HISTIGNORE", b"HISTSIZE",
    b"HISTTIMEFORMAT", b"HOME", b"HOSTFILE", b"HOSTNAME", b"HOSTTYPE", b"IFS", b"IGNOREEOF",
    b"INPUTRC", b"INSIDE_EMACS", b"LANG", b"LC_ALL", b"LC_COLLATE", b"LC_CTYPE",
    b"LC_MESSAGES", b"LC_NUMERIC", b"LC_TIME", b"LINENO", b"LINES", b"MACHTYPE", b"MAIL",
    b"MAILCHECK", b"MAILPATH", b"MAPFILE", b"OLDPWD", b"OPTARG", b"OPTERR", b"OPTIND",
    b"OSTYPE", b"PATH", b"PIPESTATUS", b"POSIXLY_CORRECT", b"PPID", b"PROMPT_COMMAND",
    b"PROMPT_DIRTRIM", b"PS0", b"PS1", b"PS2", b"PS3", b"PS4", b"PWD", b"RANDOM",
    b"READLINE_ARGUMENT", b"READLINE_LINE", b"READLINE_MARK", b"READLINE_POINT", b"REPLY",
    b"SECONDS", b"SHELL", b"SHELLOPTS", b"SHLVL", b"SRANDOM", b"TIMEFORMAT", b"TMOUT",
    b"TMPDIR", b"UID", b"auto_resume", b"histchars", b"_",
}

# Variables a runtime obeys when it starts or loads: never put into a real
# process environment by a loading target (Node reads NODE_OPTIONS from the
# --env-file itself).
CONTROL_PREFIXES = ("NODE_", "BUN_", "LD_", "DYLD_", "DOTNET_", "COMPLUS_", "CORECLR_", "PYTHON", "PERL5",
                    "UV_", "SSL_CERT", "OPENSSL_", "MALLOC_", "GLIBC_")
CONTROL_NAMES = {"TZ", "JAVA_TOOL_OPTIONS", "_JAVA_OPTIONS", "JDK_JAVA_OPTIONS", "RUBYOPT", "RUBYLIB", "BASH_ENV",
                 "ENV", "GCONV_PATH", "HOSTALIASES", "LOCPATH", "NLSPATH", "RES_OPTIONS", "PATH", "PATHEXT",
                 "COMSPEC", "SYSTEMROOT", "HOME", "TMPDIR", "TEMP", "TMP", "LANG", "LC_ALL", "LC_CTYPE"}


class _Control:
    """Whether a key token names a variable a runtime obeys (case-insensitive:
    Windows' environment is)."""
    @staticmethod
    def match(token):
        t = token.decode("latin-1").upper() if isinstance(token, bytes) else token.upper()
        return t in CONTROL_NAMES or t.startswith(CONTROL_PREFIXES)


LOADER_CONTROL = _Control()
# Where any observed dialect can read a key: at the start of a physical line
# (after blanks, an optional export and an optional opening quote), also
# inside a quoted value's continuation lines, which a dialect without
# multiline values reads as lines of their own.
LINE_START_KEY = re.compile(rb"(?:^|[\r\n])[ \t]*(?:export[ \t]+)?[\"']?([^=:\s\"']+)[\"']?[ \t]*[=:]", re.I)

BLANK = b" \t"
METAS = b";&|<>()"


class Unsafe(Exception):
    pass


class Scanner:
    def __init__(self, data):
        self.s = data
        self.i = 0
        self.reasons = []

    def peek(self, k=0):
        j = self.i + k
        return self.s[j:j + 1]

    def note(self, reason):
        if reason not in self.reasons:
            self.reasons.append(reason)

    def unsafe(self, reason):
        raise Unsafe(reason)

    # -- statements ---------------------------------------------------------

    def statements(self):
        while self.i < len(self.s):
            self.skip_blanks()
            c = self.peek()
            if c == b"":
                return
            if c == b"\n":
                self.i += 1
                continue
            if c == b"#":
                self.comment()
                continue
            self.statement()

    def skip_blanks(self):
        while self.peek() and self.peek() in BLANK:
            self.i += 1

    def comment(self):
        while self.peek() not in (b"", b"\n"):
            self.i += 1

    def statement(self):
        exported = False
        if self.s.startswith(b"export", self.i) and self.peek(6) in (b" ", b"\t"):
            self.i += 6
            self.skip_blanks()
            exported = True
        words = 0
        while True:
            m = NAME.match(self.s, self.i)
            if not m:
                if words == 0:
                    self.unsafe("command: a statement that is not an assignment")
                self.unsafe("command: a word after the assignments")
            name = m.group(0)
            after = self.s[m.end():m.end() + 1]
            if after == b"=":
                if name in SPECIAL:
                    self.unsafe("special-variable: %s" % name.decode())
                self.i = m.end() + 1
                if self.peek() == b"(":
                    self.unsafe("array-assignment")
                self.word(in_assignment=True)
            elif exported and after in (b"", b"\n", b" ", b"\t", b"#"):
                if name in SPECIAL:
                    self.unsafe("special-variable: %s" % name.decode())
                self.i = m.end()
                self.note("export-without-value")
            else:
                self.unsafe("command: a statement that is not an assignment")
            words += 1
            self.skip_blanks()
            c = self.peek()
            if c in (b"", b"\n"):
                return
            if c == b"#":
                self.comment()
                return
            if c in METAS or c == b"`":
                self.unsafe("control-operator-or-redirection")

    # -- words --------------------------------------------------------------

    def word(self, in_assignment, until=None):
        """A WORD, ending at an unquoted blank or newline (or, inside ${...},
        at the closing brace)."""
        start = True
        while True:
            c = self.peek()
            if c == b"":
                if until:
                    self.note("syntax")
                return
            if until and c == until:
                return
            if c in BLANK or c == b"\n":
                if until:
                    # inside ${NAME:-W} blanks are part of W
                    self.i += 1
                    continue
                return
            if c == b"'":
                self.single()
            elif c == b'"':
                self.double()
            elif c == b"\\":
                self.i += 2
            elif c == b"$":
                self.dollar(quoted=False)
            elif c == b"`":
                self.unsafe("command-substitution")
            elif c in METAS:
                self.unsafe("control-operator-or-redirection")
            elif c == b"~" and (start or self.s[self.i - 1:self.i] == b":"):
                self.note("tilde-expansion")
                self.i += 1
            else:
                self.i += 1
            start = False

    def single(self):
        j = self.s.find(b"'", self.i + 1)
        if j < 0:
            self.note("syntax")
            self.i = len(self.s)
        else:
            self.i = j + 1

    def ansi_c(self):
        self.i += 2  # $'
        while True:
            c = self.peek()
            if c == b"":
                self.note("syntax")
                return
            if c == b"\\":
                self.i += 2
                continue
            self.i += 1
            if c == b"'":
                self.note("ansi-c-quoting")
                return

    def double(self):
        self.i += 1
        while True:
            c = self.peek()
            if c == b"":
                self.note("syntax")
                return
            if c == b'"':
                self.i += 1
                return
            if c == b"\\":
                self.i += 2
            elif c == b"$":
                self.dollar(quoted=True)
            elif c == b"`":
                self.unsafe("command-substitution")
            else:
                self.i += 1

    def dollar(self, quoted):
        n = self.peek(1)
        if n == b"(":
            self.unsafe("arithmetic-expansion" if self.peek(2) == b"(" else "command-substitution")
        if n == b"[":
            self.unsafe("arithmetic-expansion")
        if n == b"'" and not quoted:
            self.ansi_c()
            return
        if n == b'"' and not quoted:
            self.unsafe("locale-translation")
        if n == b"{":
            self.braced()
            return
        m = NAME.match(self.s, self.i + 1)
        if m:
            if m.group(0) in SPECIAL:
                self.unsafe("host-dependent-expansion: $%s" % m.group(0).decode())
            self.note("parameter-expansion")
            self.i = m.end()
            return
        if n and n in b"$!":
            self.unsafe("host-dependent-expansion: $%s" % n.decode())
        if n and n in b"0123456789#?-*@":
            self.note("special-parameter")
            self.i += 2
            return
        self.i += 1  # a $ that starts no expansion is literal

    def braced(self):
        self.i += 2
        m = NAME.match(self.s, self.i)
        if not m:
            if self.peek() == b"":
                self.note("syntax")
                return
            self.unsafe("parameter-expansion-form")
        if m.group(0) in SPECIAL:
            self.unsafe("host-dependent-expansion: ${%s}" % m.group(0).decode())
        self.i = m.end()
        self.note("parameter-expansion")
        c = self.peek()
        if c == b"}":
            self.i += 1
            return
        if c == b"":
            self.note("syntax")
            return
        op = self.s[self.i:self.i + 2]
        if op in (b":-", b":+"):
            self.i += 2
        elif c in (b"-", b"+"):
            self.i += 1
        else:
            self.unsafe("parameter-expansion-form")
        self.note("parameter-default")
        self.word(in_assignment=False, until=b"}")
        if self.peek() == b"}":
            self.i += 1


def classify(data):
    s = Scanner(data)
    bash = {"run": True, "reasons": []}
    try:
        s.statements()
        bash["reasons"] = s.reasons
    except Unsafe as e:
        bash = {"run": False, "reasons": [str(e)]}
    loader = {"run": True, "reasons": []}
    hits = sorted({k.group(1).decode("latin-1") for k in LINE_START_KEY.finditer(data)
                   if LOADER_CONTROL.match(k.group(1))})
    if hits:
        loader = {"run": False, "reasons": ["runtime-control-variable: " + ", ".join(hits)]}
    return {"bash": bash, "loader": loader, "commands": b"$(" in data or b"`" in data}


SELFTEST = [
    (b"A=1\n", True), (b"export A=1 B=2 # c\n", True), (b"A='x y'\n", True),
    (b'A="x $B ${C:-d e} \\$ \\` $"\n', True), (b"A=$'a\\nb'\n", True), (b"A=\"unterminated\n", True),
    (b"A\n", False), (b"A = 1\n", False), (b"A=1 cmd\n", False), (b"A=$(id)\n", False),
    (b"A=`id`\n", False), (b'A="$(id)"\n', False), (b"A=1;id\n", False), (b"A=(x)\n", False),
    (b"A=$((1+1))\n", False), (b"MY-KEY=1\n", False), (b"PATH=/x\n", False), (b"IFS=x\n", False),
    (b"A=${B:=x}\n", False), (b"A=${B[0]}\n", False), (b"A=x>y\n", False), (b"export\n", False),
    (b"export -n A\n", False), (b"A=$\"x\"\n", False), (b"A=~/x\n", True), (b"A=x#y\n", True),
    (b"# just a comment\n\n", True), (b"A=1\r\n", True),
]


def selftest():
    bad = []
    for data, ok in SELFTEST:
        got = classify(data)["bash"]["run"]
        if got != ok:
            bad.append((data, ok, got))
    assert classify(b"NODE_OPTIONS=--require=x\n")["loader"]["run"] is False
    assert classify(b"A=1\n")["loader"]["run"] is True
    assert classify(b"A=\"x\nexport node_options=1\"\n")["loader"]["run"] is False
    assert classify(b"A=TZ NODE_OPTIONS\n")["loader"]["run"] is True
    return bad
