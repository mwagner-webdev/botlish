# fuzz.tcl -- focused fuzzer for ONE-CHAR-STRING-LITERAL, the global warning
# modes and the spelling law (WARNINGS-ONE-CHAR-STRING-LITERAL.md, "Fuzzing
# and the spelling law").
#
#   tclsh9.0 audit/one-char-string-literal/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED?
#   tclsh9.0 audit/one-char-string-literal/tools/fuzz.tcl -show SEED
#     (prints the program SEED generates and its prediction)
#   tclsh9.0 audit/one-char-string-literal/tools/fuzz.tcl -spelling-exhaustive
#     (the spelling law's lexer clause over every Unicode scalar)
#
# Each seed generates one program whose String literals are *known by
# construction*. A literal is built from a pool of characters -- ASCII letters,
# digits, space and punctuation, both quotes, the backslash, newline, tab and
# carriage return (written as escapes), a two-byte, a three-byte and two
# supplementary-plane characters (written raw) -- with 0, 1 or 2 of them, or
# the two-code-point grapheme e + U+0301. It is placed in one of these
# contexts:
#
#   str-param      the argument of a declared `fn take_s(text: str) -> int`
#   str-length     the argument of str::length (a native's str parameter)
#   str-concat     the receiver of `.concat("ab")` (str::concat; method
#                  syntax: the functional form would be METHOD-ELIGIBLE)
#   str-compare    one side of `==` whose other side is a String (a computed
#                  one-character String `sxK`)
#   char-accepting the argument of a declared kind-tolerant matcher
#                  `fn is_K(c): c == 'X' or c == sxK` -- an untyped parameter
#                  observed as a character, accepting the character type and a
#                  one-character String alike (a declared UnicodeChar
#                  parameter rejects the original String statically, and a
#                  str one rejects the rewrite)
#   element        a list element of the program's result, and
#   field          a struct field value of it (the kind is visible in the
#                  value)
#   binding        the initializer of `bI = LIT`, read later by one of the
#                  contexts above (the read is never a site)
#
# and placed at the top level, in a nested function, in a closure, in a
# statically dead branch (`if 1 == 2:`), under a range-infeasible branch, after
# a `return`, or in a function nobody calls. Character literals of the same
# characters appear in the same contexts where the original program accepts
# them (never sites), and so do computed
# one-character Strings (`"aX".substring(1, 2)`, call results) and binding
# reads. Some programs declare a context struct named `C` and a function with a
# context parameter of it: the frontend synthesizes the one-character String
# const `context#load("C")`, which is no written literal and is never
# reported. About a third of the programs are silent by construction (no
# one-character String literal at all). Every call is written so that no other
# warning code can fire (one-parameter functions, method syntax for
# str::concat, no function returns a list, single exits).
#
# The oracle is the construction: a literal built of exactly one pool
# character is predicted as {LINE COL VALUE} -- the anchor its opening quote,
# columns counted in characters as the lexer counts them -- and nothing else
# is. For every program it checks
#
#   default   compiles; the ONE-CHAR-STRING-LITERAL warnings are exactly the
#             prediction, values included (a missed or mislocated one fails;
#             an unpredicted one is printed as EXTRA and counted, and the
#             summary must show 0; a site reported twice fails); any other
#             code fails
#   off       compiles; no warning, no pass ran (stats counter, execution
#             trace on the pass), and the HIR equals default's without its
#             side table
#   error     rejected with {CORE SEMANTIC ONE-CHAR-STRING-LITERAL} iff a
#             warning is predicted; compiles otherwise
#
# and THE SPELLING LAW, for every predicted finding (its String literal
# rewritten to the character spelling: 'X', with \' \\ \n \t \r escaped):
#
#   1. the character spelling lexes and parses: a probe `x = SPELLING` compiles
#      with no diagnostic (a gap is a language finding and a failure);
#   2. its exact value (hir::exact::Of on the probe's const) is
#      {val {UnicodeChar CP}}, CP the code point of the String's character;
#      and a typed character context takes it: `code(SPELLING)` with
#      `fn code(c: UnicodeChar) -> int` evaluates to CP;
#   3. the program with that one literal rewritten, where the literal's context
#      accepts the character type (char-accepting, directly or through a
#      binding, in any placement), compiles with exactly that one warning gone
#      and evaluates to the identical value on the reference interpreter.
#      Everywhere else the rewrite's outcome is catalogued per context, never a
#      failure: rejected statically, failing at run time, a changed value, or
#      the same value (a dead placement, or a comparison that is false with
#      either spelling) -- those contexts are the warning's purpose, the API
#      surface that takes String where a character is meant.
#
# Exits non-zero on any failure.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]

set show ""
set exhaustive 0
if {[lindex $argv 0] eq "-show"} {
    set show [lindex $argv 1]
    set argv {}
} elseif {[lindex $argv 0] eq "-spelling-exhaustive"} {
    set exhaustive 1
    set argv {}
}
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 300}]
set first [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc chance {p} {
    return [expr {rand() < $p}]
}

proc census {key {n 1}} {
    dict incr ::census $key $n
}

# The characters literals are built from.
set ::pool [list a Z 7 " " % - , \" ' \\ \n \t \r "é" "世" "\U1F600" "\U1D11E"]

# The String spelling of TEXT (its escapes: \\ \" \n \t \r) and the character
# spelling of the one character CH ('X'; \\ \' \n \t \r): the rewrite the
# spelling law checks. Neither is computed by the compiler.
proc stringSpelling {text} {
    return "\"[string map [list \\ \\\\ \" \\\" \n \\n \t \\t \r \\r] $text]\""
}

proc charSpelling {ch} {
    return "'[string map [list \\ \\\\ ' \\' \n \\n \t \\t \r \\r] $ch]'"
}

# A String literal: {TEXT SPELLING}. LENGTH 0, 1 or 2; 2 is sometimes the
# grapheme e + U+0301 (two code points). ONE, when given, is the one character
# of a length-1 literal.
proc stringLiteral {length {one ""}} {
    switch -- $length {
        0 { set text "" }
        1 { set text [expr {$one ne "" ? $one : [pick $::pool]}] }
        2 {
            set text [expr {[chance 0.2] ? "é" : "[pick $::pool][pick $::pool]"}]
        }
    }
    return [list $text [stringSpelling $text]]
}

# ---------------------------------------------------------------------------
# Lines with sites. A fragment is {t TEXT} (plain text) or {s SITE} (a String
# literal: a dict with text, spelling, context, placement). addLine renders the
# fragments as the next line and records each literal's anchor.

proc addLine {fragments} {
    set line ""
    foreach fragment $fragments {
        lassign $fragment kind payload
        if {$kind eq "t"} {
            append line $payload
        } else {
            set site $payload
            dict set site line [expr {[llength $::lines] + 1}]
            dict set site col [expr {[string length $line] + 1}]
            lappend ::sites $site
            append line [dict get $site spelling]
        }
    }
    lappend ::lines $line
}

proc site {text spelling context placement} {
    return [list s [dict create text $text spelling $spelling context $context placement $placement]]
}

# The expression fragments of CONTEXT applied to LITERAL, {TEXT SPELLING
# PLAIN}: a String literal (a site) unless PLAIN, which is text written as it
# is (a character literal, a binding read). K is the matcher it uses.
proc contextFragments {context literal placement k} {
    lassign $literal text spelling plain
    set arg [expr {$plain ? [list t $spelling] : [site $text $spelling $context $placement]}]
    switch -- $context {
        str-param   { return [list {t "take_s("} $arg {t ")"}] }
        str-length  { return [list {t "str::length("} $arg {t ")"}] }
        str-concat  { return [list $arg {t ".concat(\"ab\")"}] }
        str-compare { return [list [list t "sx$k == "] $arg] }
        char-accepting { return [list [list t "is_$k\("] $arg {t ")"}] }
        element     { return [list {t "\["} $arg {t "\]"}] }
        field       { return [list [list t "\{f: "] $arg [list t "\}"]] }
    }
}

# A literal {TEXT SPELLING PLAIN} for CONTEXT with matcher K: mostly one
# character (sometimes K's own target, so matchers and comparisons see both
# outcomes), sometimes 0 or 2 characters, sometimes a character literal (only
# where a character is accepted by the original program). QUIET: never one
# character.
proc literalFor {context k quiet} {
    if {[chance 0.2] && $context ni {str-param str-length str-concat}} {
        set ch [expr {[chance 0.5] ? [lindex $::targets $k] : [pick $::pool]}]
        census charLiterals
        return [list $ch [charSpelling $ch] 1]
    }
    set length [expr {$quiet ? [pick {0 2 2}] : [pick {1 1 1 1 0 2}]}]
    set one ""
    if {$length == 1 && $context in {char-accepting str-compare} && [chance 0.5]} {
        set one [lindex $::targets $k]
    }
    return [list {*}[stringLiteral $length $one] 0]
}

# Each fragment list of BODY with INDENT prepended.
proc indented {indent body} {
    return [lmap fragments $body {list [list t $indent] {*}$fragments}]
}

# {SOURCE SITES PREDICTED} for SEED.
proc generate {seed} {
    expr {srand($seed)}
    set ::lines {}
    set ::sites {}
    set quiet [chance 0.33]
    if {$quiet} {
        census quietPrograms
    }
    addLine {{t "import str"}}
    # Matchers: K's target character and its computed one-character String
    # sxK (computed, so never a site).
    set ::targets {}
    set matchers [expr {1 + int(rand() * 2)}]
    for {set k 0} {$k < $matchers} {incr k} {
        set x [pick $::pool]
        lappend ::targets $x
        addLine [list [list t "sx$k = [stringSpelling a$x].substring(1, 2)"]]
    }
    addLine {{t "fn take_s(text: str) -> int:"}}
    addLine {{t "    str::length(text)"}}
    for {set k 0} {$k < $matchers} {incr k} {
        addLine [list [list t "fn is_$k\(c):"]]
        addLine [list [list t "    c == [charSpelling [lindex $::targets $k]] or c == sx$k"]]
    }
    set results {}
    if {[chance 0.3]} {
        # A context parameter of a struct named C: the frontend's synthesized
        # one-character String const context#load("C"), never a site.
        census contextKeys
        foreach line {"context struct C:" "    v: int" "fn ctx_get(context c: C) -> int:" "    c.v" "with context C {v: 1}"} {
            addLine [list [list t $line]]
        }
        lappend results ctx_get()
    }
    set count [expr {3 + int(rand() * 8)}]
    for {set i 0} {$i < $count} {incr i} {
        set k [expr {int(rand() * $matchers)}]
        set context [pick {str-param str-length str-concat str-compare char-accepting char-accepting element field binding}]
        set placement [pick {top top top nested closure dead range after uncalled}]
        census $placement
        # BODY: the statements (fragment lists, no indentation) whose last is
        # the value expression.
        if {$context eq "binding"} {
            # The initializer is the site; a read uses one of the contexts.
            set use [pick {str-param str-length str-compare char-accepting char-accepting element field}]
            lassign [literalFor $use $k $quiet] text spelling plain
            set init [expr {$plain ? [list t $spelling] : [site $text $spelling binding/$use $placement]}]
            set body [list [list [list t "b$i = "] $init] [contextFragments $use [list b$i b$i 1] $placement $k]]
            census binding/$use
        } else {
            set body [list [contextFragments $context [literalFor $context $k $quiet] $placement $k]]
            census $context
        }
        if {$placement eq "top"} {
            foreach fragments [lrange $body 0 end-1] {
                addLine $fragments
            }
            addLine [list [list t "r$i = "] {*}[lindex $body end]]
            lappend results r$i
            continue
        }
        # A placement in function h$i (parameter x).
        addLine [list [list t "fn h$i\(x):"]]
        switch -- $placement {
            nested - closure {
                addLine {{t "    fn inner(y):"}}
                if {$placement eq "closure"} {
                    # The inner function reads the enclosing x: a closure.
                    addLine {{t "        z = x + y"}}
                }
                foreach fragments [indented "        " $body] {
                    addLine $fragments
                }
                addLine {{t "    inner(x)"}}
            }
            dead - range - uncalled {
                switch -- $placement {
                    dead     { addLine {{t "    if 1 == 2:"}} }
                    range    { addLine {{t "    if x < 0:"}}; addLine {{t "      if x > 5:"}} }
                    uncalled { addLine {{t "    if x == x:"}} }
                }
                foreach fragments [indented "        " [lrange $body 0 end-1]] {
                    addLine $fragments
                }
                addLine [list {t "        return "} {*}[lindex $body end]]
                addLine {{t "    x"}}
            }
            after {
                # Code after an if/else that returns from both branches.
                foreach line {"    if x == 1:" "        return x" "    else:" "        return x + 1"} {
                    addLine [list [list t $line]]
                }
                foreach fragments [indented "    " [lrange $body 0 end-1]] {
                    addLine $fragments
                }
                addLine [list {t "    return "} {*}[lindex $body end]]
            }
        }
        if {$placement ne "uncalled"} {
            lappend results "h$i\(1)"
        }
    }
    addLine [list [list t "\[[join $results {, }]\]"]]
    set predicted {}
    foreach site $::sites {
        if {[string length [dict get $site text]] == 1} {
            lappend predicted [list [dict get $site line] [dict get $site col] [dict get $site text]]
        }
    }
    if {$predicted eq ""} {
        census silentPrograms
    }
    return [list [join $::lines \n] $::sites [lsort -dictionary $predicted]]
}

if {$show ne ""} {
    lassign [generate $show] source sites predicted
    puts "$source\n--- predicted (line col value):"
    foreach p $predicted {
        puts "[lrange $p 0 1] [stringSpelling [lindex $p 2]]"
    }
    exit 0
}

# ---------------------------------------------------------------------------
# The spelling law's lexer clause over every Unicode scalar: the one-character
# String spelling and the character spelling of each lex to that scalar, with
# no diagnostic (the lexer's own procedures, as the parser calls them).

if {$exhaustive} {
    set checked 0
    set gaps {}
    foreach {lo hi} {0 0xD7FF 0xE000 0x10FFFF} {
        for {set cp $lo} {$cp <= $hi} {incr cp} {
            set ch [format %c $cp]
            set diagnostics {}
            set string [surface::lexer::String [stringSpelling $ch] 0 f 1 0 diagnostics]
            set char [surface::lexer::Char [charSpelling $ch] 0 f 1 0 diagnostics]
            if {$diagnostics ne "" || [dict get $string value] ne $ch || [dict get $char value] != $cp} {
                lappend gaps [format U+%04X $cp]
            }
            incr checked
        }
    }
    puts "spelling exhaustive: $checked scalars (U+0000..U+10FFFF without the surrogates); gaps [llength $gaps][expr {$gaps eq "" ? "" : ": [lrange $gaps 0 19]"}]"
    exit [expr {$gaps ne ""}]
}

# ---------------------------------------------------------------------------
# Checking

proc compileMode {source mode} {
    return [surface::compile $source fuzz.bot -warnings $mode -warning-channel ""]
}

# {LINE COL TEXT} of each ONE-CHAR-STRING-LITERAL warning of HIR, TEXT the
# data value's String.
proc literalsOf {hir} {
    set result {}
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "ONE-CHAR-STRING-LITERAL"} continue
        set at [lrange [dict get $w primary] 2 end]
        lappend result [list [dict get $at line] [dict get $at column] [core::value::strOf [dict get $w data value]]]
    }
    return [lsort -dictionary $result]
}

proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v options]} {
        return [list error [dict get $options -errorcode]]
    }
    return [list value $v]
}

# Clauses 1 and 2 for the character CH (cached): "" when they hold, else why
# not.
proc characterClauses {ch} {
    if {[dict exists $::characterCache $ch]} {
        return [dict get $::characterCache $ch]
    }
    set spelling [charSpelling $ch]
    set cp [scan $ch %c]
    set problem ""
    if {[catch {compileMode "x = $spelling\nx" off} probe]} {
        set problem "SPELLING GAP: $spelling does not lex or parse: $probe"
    } else {
        set consts [lmap {e node} [dict get $probe exprs] {
            if {[dict get $node kind] ne "const"} continue
            set e
        }]
        set fact [expr {[llength $consts] == 1 ? [hir::exact::Of $probe [lindex $consts 0]] : ""}]
        if {$fact ne [list val [list UnicodeChar $cp]]} {
            set problem "exact value of $spelling is \"$fact\", not {val {UnicodeChar $cp}}"
        } elseif {[catch {compileMode "import char\nfn code(c: UnicodeChar) -> int:\n    char::scalar_value(c)\ncode($spelling)" off} typed]} {
            set problem "a UnicodeChar parameter rejects $spelling: $typed"
        } elseif {[valueOf $typed] ne [list value $cp]} {
            set problem "code($spelling) is [valueOf $typed], not $cp"
        }
    }
    dict set ::characterCache $ch $problem
    return $problem
}

# SOURCE with the String literal SITE (a dict: line, col, spelling, text)
# rewritten to its character spelling.
proc rewrite {source site} {
    set lines [split $source \n]
    set index [expr {[dict get $site line] - 1}]
    set line [lindex $lines $index]
    set from [expr {[dict get $site col] - 1}]
    set to [expr {$from + [string length [dict get $site spelling]] - 1}]
    if {[string range $line $from $to] ne [dict get $site spelling]} {
        error "rewrite: [dict get $site spelling] is not at [dict get $site line]:[dict get $site col]"
    }
    lset lines $index [string replace $line $from $to [charSpelling [dict get $site text]]]
    return [join $lines \n]
}

# PREDICTED ({LINE COL TEXT}) after SITE is rewritten: SITE gone, and the
# columns after it on its line shifted by the spelling's change in length.
proc afterRewrite {predicted site} {
    set shift [expr {[string length [charSpelling [dict get $site text]]] - [string length [dict get $site spelling]]}]
    set result {}
    foreach p $predicted {
        lassign $p line col text
        if {$line == [dict get $site line] && $col == [dict get $site col]} continue
        if {$line == [dict get $site line] && $col > [dict get $site col]} {
            incr col $shift
        }
        lappend result [list $line $col $text]
    }
    return [lsort -dictionary $result]
}

# The outcome of a rewritten program against the original value VALUE:
# rejected, runtime, changed or same.
proc outcomeOf {source value} {
    if {[catch {compileMode $source default} hir options]} {
        return [list rejected [lindex [dict get $options -errorcode] end] ""]
    }
    set after [valueOf $hir]
    if {[lindex $after 0] eq "error"} {
        return [list runtime [lindex $after 1 end] $hir]
    }
    return [list [expr {$after eq $value ? "same" : "changed"}] "" $hir]
}

set ::census [dict create]
set ::characterCache [dict create]
set ::catalog [dict create]
set failures 0
set extras 0
set warned 0
set clean 0
set findings 0
set lawHeld 0
set lawFailures 0
set accepting 0
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    lassign [generate $seed] source sites predicted
    set problems {}
    if {[catch {compileMode $source default} hir options]} {
        lappend problems "default mode did not compile: $hir"
    } else {
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] ne "ONE-CHAR-STRING-LITERAL"} {
                lappend problems "unexpected code [dict get $w code]: [dict get $w message]"
            } elseif {[dict get $w secondary] ne ""} {
                lappend problems "a warning with secondary locations"
            }
        }
        set actual [literalsOf $hir]
        foreach p $predicted {
            if {$p ni $actual} {
                lappend problems "MISSED predicted warning $p (actual: $actual)"
            }
        }
        if {[llength $actual] != [llength [lsort -unique $actual]]} {
            lappend problems "a site was reported more than once: $actual"
        }
        foreach a $actual {
            if {$a ni $predicted} {
                puts "EXTRA seed $seed: warning $a is not predicted:\n$source"
                incr extras
            }
        }
        # off: compiles, silently, runs no warning pass, same HIR.
        hir::warnings::resetStats
        set ::passCalls 0
        trace add execution hir::warnings::OneCharStringLiteral enter {apply {{args} {incr ::passCalls}}}
        try {
            set offFailed [catch {compileMode $source off} off]
        } finally {
            trace remove execution hir::warnings::OneCharStringLiteral enter {apply {{args} {incr ::passCalls}}}
        }
        if {$offFailed} {
            lappend problems "off mode did not compile: $off"
        } elseif {[hir::warnings::of $off] ne "" || [hir::warnings::stats] ne "" || $::passCalls != 0} {
            lappend problems "off mode ran or reported warnings"
        } elseif {$off ne [dict remove $hir warnings]} {
            lappend problems "HIR differs between off and default"
        }
        # error: rejected with this code iff a warning is predicted.
        set rejected [catch {compileMode $source error} message options]
        if {$rejected} {
            if {$predicted eq ""} {
                lappend problems "error mode rejected a program with no predicted warning: $message"
            } elseif {[dict get $options -errorcode] ne {CORE SEMANTIC ONE-CHAR-STRING-LITERAL}} {
                lappend problems "error mode rejected with [dict get $options -errorcode]: $message"
            }
        } elseif {$predicted ne ""} {
            lappend problems "error mode accepted a program with a predicted warning"
        }
        # The spelling law, once per predicted finding.
        set value [valueOf $hir]
        foreach site $sites {
            if {[string length [dict get $site text]] != 1} continue
            incr findings
            set law {}
            set clause [characterClauses [dict get $site text]]
            if {$clause ne ""} {
                lappend law $clause
            }
            set rewritten [rewrite $source $site]
            lassign [outcomeOf $rewritten $value] outcome kind rhir
            set context [dict get $site context]
            set live [expr {[dict get $site placement] in {top nested closure} ? "live" : "dead"}]
            if {$rhir ne "" && [literalsOf $rhir] ne [afterRewrite $actual $site]} {
                lappend law "the rewritten program's warnings are [literalsOf $rhir], not [afterRewrite $actual $site]"
            }
            if {$context in {char-accepting binding/char-accepting}} {
                incr accepting
                if {$outcome ne "same"} {
                    lappend law "a character-accepting context: the rewrite is $outcome $kind"
                }
            }
            dict incr ::catalog [list $context $live $outcome $kind]
            if {$law eq ""} {
                incr lawHeld
            } else {
                incr lawFailures
                lappend problems "SPELLING LAW at [dict get $site line]:[dict get $site col] [dict get $site spelling] ($context, [dict get $site placement]): [join $law {; }]\n--- rewritten:\n$rewritten"
            }
        }
        if {$actual eq ""} { incr clean } else { incr warned }
    }
    if {$problems ne ""} {
        incr failures
        puts "FAIL seed $seed:\n[join $problems \n]\n--- source:\n$source"
    }
}
set c $::census
proc get {c key} {
    return [expr {[dict exists $c $key] ? [dict get $c $key] : 0}]
}
puts "catalog of rewrites (context, placement, outcome): [join [lmap key [lsort [dict keys $::catalog]] {string cat [string trim [join $key /] /] " " [dict get $::catalog $key]}] {, }]"
puts "seeds $seeds (from $first): $warned with warnings, $clean without; failures $failures; extra warnings $extras; spelling law $lawHeld of $findings findings, failures $lawFailures (character-accepting rewrites $accepting, characters probed [dict size $::characterCache]); contexts str-param [get $c str-param], str-length [get $c str-length], str-concat [get $c str-concat], str-compare [get $c str-compare], char-accepting [get $c char-accepting], element [get $c element], field [get $c field], bindings [expr {[get $c binding/str-param] + [get $c binding/str-length] + [get $c binding/str-compare] + [get $c binding/char-accepting] + [get $c binding/element] + [get $c binding/field]}]; placements top [get $c top], nested [get $c nested], closure [get $c closure], dead [get $c dead], range [get $c range], after [get $c after], uncalled [get $c uncalled]; character literals [get $c charLiterals], context keys [get $c contextKeys], quiet programs [get $c quietPrograms], only-silent programs [get $c silentPrograms]"
exit [expr {$failures > 0 || $extras > 0}]
