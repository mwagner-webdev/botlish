# dfa.tcl -- the DFA front end of DFA-COROUTINE-EXPLORATION.md: declarative
# finite-state recognizers, statically checked, lowered to ordinary Botlish
# coroutine functions.
#
#   tclsh9.0 audit/dfa/tools/dfa.tcl generate FILE.dfa ?-out FILE.bot?
#   tclsh9.0 audit/dfa/tools/dfa.tcl check FILE.dfa ?-committed 1?
#   tclsh9.0 audit/dfa/tools/dfa.tcl describe FILE.dfa
#
# An exploratory prototype, not part of the compiler: nothing in core/, hir/,
# surface/, compiler/ or native/ loads it, and tests/local.tcl and CI do not
# run it. A FILE.dfa is an ordinary Botlish module with two more kinds of
# top-level declaration, which this tool checks and replaces by ordinary
# Botlish; everything else passes through unchanged:
#
#   class NAME = ITEMS [except ITEMS]
#   dfa NAME over (bytes | unicode):
#       class NAME = ITEMS [except ITEMS]        -- local classes first
#       STATE:                                    -- the first state starts
#           ITEMS -> STATE                        -- consume, continue
#           ITEMS -> accept                       -- consume, complete
#           ITEMS -> accept before                -- leave unread, complete
#           ITEMS -> reject                       -- reject (explicitly)
#           ITEMS -> call DFA then (STATE|accept) -- delegate to an earlier dfa
#           ITEMS => STATE                        -- reconsider in STATE
#
#   ITEMS = ITEM { [","] ITEM }
#   ITEM  = 'c' | 'c'..'d' | N | N..M | CLASS | any | end | "sequence"
#
# N is decimal or 0x hexadecimal; `end` is the end of the input, which is no
# symbol of the alphabet (it is never consumed); `any` is the alphabet; a
# "sequence" (its own transition line, `->` only) consumes its symbols
# through anonymous states and then acts. The recognizer is an ordinary
# coroutine function (DFA-COROUTINE-EXPLORATION.md, "Coroutine
# correspondence"):
#
#   fn NAME(first: int, resume dfa::Symbol) -> bool errors ...
#
# constructed with the first symbol, resumed with one dfa::Symbol per further
# symbol (code -1: the end of the input); a yield (true) means "consumed, send
# the next", the return completes (true: the last symbol was part of the
# token; false: it is the first symbol after it, unread), a symbol no
# transition takes fails dfa::UnrecognizedInput, the end where none takes it
# dfa::UnexpectedEnd. The support module dfa.bot (written beside the output)
# declares the message and the errors.
#
# The checks (each a structured diagnostic, CORE SEMANTIC DFA-...; every
# independent one is reported): syntax, unknown or duplicate names, symbols
# outside the alphabet (a non-ASCII character in a bytes recognizer),
# overlapping transitions of one state, a cycle of non-consuming moves some
# symbol can take, unreachable states, states from which nothing is ever
# accepted, non-consuming transitions that can only reject, a state that
# accepts before a symbol but says nothing about the end, recursive calls and
# calls across alphabets.

namespace eval dfa {
    variable root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
    # The integer line beyond every symbol: segment bounds, never emitted.
    variable MIN -1000000000000000000000
    variable MAX 1000000000000000000000
    variable END -1
    variable reserved {accept before reject call then end any over class dfa except}
}

# ---------------------------------------------------------------------------
# Interval sets: sorted, disjoint, non-adjacent closed intervals {lo hi}.

proc dfa::Norm {intervals} {
    set sorted [lsort -command {apply {{a b} {
        set d [expr {[lindex $a 0] - [lindex $b 0]}]
        expr {$d < 0 ? -1 : ($d > 0 ? 1 : 0)}
    }}} [lmap i $intervals {if {[lindex $i 0] > [lindex $i 1]} continue; set i}]]
    set out {}
    foreach i $sorted {
        lassign $i lo hi
        if {[llength $out] && $lo <= [lindex $out end 1] + 1} {
            if {$hi > [lindex $out end 1]} {
                lset out end 1 $hi
            }
        } else {
            lappend out [list $lo $hi]
        }
    }
    return $out
}

proc dfa::Union {a b} { return [Norm [concat $a $b]] }

proc dfa::Inter {a b} {
    set out {}
    foreach x $a {
        lassign $x alo ahi
        foreach y $b {
            lassign $y blo bhi
            set lo [expr {max($alo, $blo)}]
            set hi [expr {min($ahi, $bhi)}]
            if {$lo <= $hi} {
                lappend out [list $lo $hi]
            }
        }
    }
    return [Norm $out]
}

proc dfa::Minus {a b} {
    set out $a
    foreach y $b {
        lassign $y blo bhi
        set next {}
        foreach x $out {
            lassign $x lo hi
            if {$bhi < $lo || $blo > $hi} {
                lappend next $x
                continue
            }
            if {$lo < $blo} {
                lappend next [list $lo [expr {$blo - 1}]]
            }
            if {$hi > $bhi} {
                lappend next [list [expr {$bhi + 1}] $hi]
            }
        }
        set out $next
    }
    return [Norm $out]
}

proc dfa::Universe {} {
    variable MIN
    variable MAX
    return [list [list $MIN $MAX]]
}

# The symbols of ALPHABET (bytes, unicode); the end is not one of them.
proc dfa::AlphabetSet {alphabet} {
    switch -- $alphabet {
        ascii { return {{0 127}} }
        bytes { return {{0 255}} }
    }
    return {{0 55295} {57344 1114111}}
}

proc dfa::AlphabetHull {alphabet} {
    return [dict get {ascii {0 127} bytes {0 255} unicode {0 1114111}} $alphabet]
}

# How one symbol of ALPHABET is shown in a message.
proc dfa::Sym {s alphabet} {
    variable END
    if {$s == $END} {
        return end
    }
    if {$s >= 0x21 && $s <= 0x7E && $s != 0x27 && $s != 0x5C} {
        return '[format %c $s]'
    }
    switch -- $s {
        32 { return "' '" }
        39 { return {'\''} }
        92 { return {'\\'} }
        10 { return {'\n'} }
        13 { return {'\r'} }
        9 { return {'\t'} }
    }
    if {$s < 0 || $s > 0x10FFFF} {
        return $s
    }
    if {$alphabet eq "bytes"} {
        return [format 0x%02X $s]
    }
    return [format U+%04X $s]
}

proc dfa::SetText {set alphabet {limit 6}} {
    variable MIN
    variable MAX
    set parts {}
    foreach i $set {
        lassign $i lo hi
        if {$lo == $MIN || $hi == $MAX} {
            lappend parts "every value outside the alphabet"
        } elseif {$lo == $hi} {
            lappend parts [Sym $lo $alphabet]
        } else {
            lappend parts "[Sym $lo $alphabet]..[Sym $hi $alphabet]"
        }
    }
    if {[llength $parts] > $limit} {
        set parts [list {*}[lrange $parts 0 [expr {$limit - 1}]] "... ([llength $parts] ranges)"]
    }
    return [join $parts " "]
}

# ---------------------------------------------------------------------------
# Diagnostics: the compiler's structured entries (core::raiseDiagnostics).

proc dfa::Diag {code loc text {related {}}} {
    variable diagnostics
    lappend diagnostics [list code $code loc $loc text $text related $related]
}

# A location: {line L column C endColumn C2}.
proc dfa::Loc {line col {width 1}} {
    return [list line $line column $col endColumn [expr {$col + max(1, $width)}]]
}

proc dfa::LocText {file loc} {
    return "[file tail $file]:[dict get $loc line]:[dict get $loc column]"
}

# The core::raiseDiagnostics entries of the diagnostics recorded for FILE,
# whose normalized text is TEXT, in source order.
proc dfa::Entries {file text} {
    variable diagnostics
    set starts [list 0]
    set offset 0
    foreach line [split $text \n] {
        incr offset [expr {[string length $line] + 1}]
        lappend starts $offset
    }
    set sorted [lsort -command {apply {{a b} {
        set la [dict get $a loc]
        set lb [dict get $b loc]
        set d [expr {[dict get $la line] - [dict get $lb line]}]
        if {$d == 0} {
            set d [expr {[dict get $la column] - [dict get $lb column]}]
        }
        expr {$d < 0 ? -1 : ($d > 0 ? 1 : 0)}
    }}} $diagnostics]
    set span [list apply {{file starts loc} {
        set line [dict get $loc line]
        set start [expr {[lindex $starts [expr {$line - 1}]] + [dict get $loc column] - 1}]
        set end [expr {$start + [dict get $loc endColumn] - [dict get $loc column]}]
        list file $file start $start end $end line $line column [dict get $loc column] \
            endLine $line endColumn [dict get $loc endColumn]
    }} $file $starts]
    set entries {}
    foreach d $sorted {
        set summary [dict get $d text]
        set message "[LocText $file [dict get $d loc]]: $summary"
        set related {}
        foreach r [dict get $d related] {
            lassign $r what loc
            append message "\n    $what ([LocText $file $loc])"
            lappend related [{*}$span $loc]
        }
        lappend entries [list errorcode [list CORE SEMANTIC [dict get $d code]] message $message \
            summary $summary location [{*}$span [dict get $d loc]] related $related]
    }
    return $entries
}

# ---------------------------------------------------------------------------
# Tokens of one declaration line: {kind text value col} (col 1-based).

proc dfa::Tokens {text lineNo} {
    set tokens {}
    set i 0
    set n [string length $text]
    while {$i < $n} {
        set ch [string index $text $i]
        set col [expr {$i + 1}]
        if {$ch eq " "} {
            incr i
            continue
        }
        if {$ch eq "#"} {
            break
        }
        if {[regexp -start $i {\A[A-Za-z_][A-Za-z0-9_]*\??} $text word]} {
            lappend tokens [list IDENT $word $word $col]
            incr i [string length $word]
            continue
        }
        if {[regexp -start $i {\A0[xX][0-9A-Fa-f]+} $text word]} {
            lappend tokens [list NUM $word [expr {$word}] $col]
            incr i [string length $word]
            continue
        }
        if {[regexp -start $i {\A[0-9]+} $text word]} {
            lappend tokens [list NUM $word [scan $word %lld] $col]
            incr i [string length $word]
            continue
        }
        foreach op {.. -> => , = :} {
            if {[string range $text $i [expr {$i + [string length $op] - 1}]] eq $op} {
                lappend tokens [list $op $op $op $col]
                incr i [string length $op]
                set ch ""
                break
            }
        }
        if {$ch eq ""} {
            continue
        }
        if {$ch eq "'" || $ch eq "\""} {
            set quote $ch
            set j [expr {$i + 1}]
            set value ""
            set ok 0
            while {$j < $n} {
                set c [string index $text $j]
                if {$c eq $quote} {
                    set ok 1
                    break
                }
                if {$c eq "\\"} {
                    set e [string index $text [expr {$j + 1}]]
                    set map [expr {$quote eq "'" ? {\\ \\ ' ' n \n r \r t \t} : {\\ \\ \" \" n \n r \r t \t}}]
                    if {![dict exists $map $e]} {
                        Diag DFA-SYNTAX [Loc $lineNo [expr {$j + 1}] 2] "invalid escape \"\\$e\""
                        return {}
                    }
                    append value [dict get $map $e]
                    incr j 2
                    continue
                }
                append value $c
                incr j
            }
            if {!$ok} {
                Diag DFA-SYNTAX [Loc $lineNo $col] "unterminated [expr {$quote eq "'" ? "character" : "sequence"}] literal"
                return {}
            }
            set raw [string range $text $i $j]
            if {$quote eq "'"} {
                if {[string length $value] != 1} {
                    Diag DFA-SYNTAX [Loc $lineNo $col [string length $raw]] "a character literal is exactly one Unicode scalar value"
                    return {}
                }
                lappend tokens [list CHAR $raw [scan $value %c] $col]
            } else {
                if {$value eq ""} {
                    Diag DFA-SYNTAX [Loc $lineNo $col [string length $raw]] "an empty sequence"
                    return {}
                }
                lappend tokens [list STRING $raw [lmap c [split $value ""] {scan $c %c}] $col]
            }
            set i [expr {$j + 1}]
            continue
        }
        Diag DFA-SYNTAX [Loc $lineNo $col] "unexpected character \"$ch\""
        return {}
    }
    return $tokens
}

# ---------------------------------------------------------------------------
# Parsing a .dfa file.

# The indentation of LINE (spaces), or -1 for a blank or comment-only line.
proc dfa::Indent {line} {
    set trimmed [string trimleft $line " "]
    if {$trimmed eq "" || [string index $trimmed 0] eq "#"} {
        return -1
    }
    if {[string first "\t" [string range $line 0 [expr {[string length $line] - [string length $trimmed]}]]] >= 0} {
        return -2
    }
    return [expr {[string length $line] - [string length $trimmed]}]
}

# Items from TOKENS starting at index I up to a token whose kind is in STOP:
# {ITEMS NEXT}. An item: {kind K col C width W ...}: char/num (lo hi, ascii),
# class (name), any, end, seq (symbols).
proc dfa::Items {tokens i stop lineNo} {
    set items {}
    set n [llength $tokens]
    while {$i < $n} {
        lassign [lindex $tokens $i] kind text value col
        if {$kind in $stop} {
            break
        }
        if {$kind eq ","} {
            incr i
            continue
        }
        switch -- $kind {
            CHAR - NUM {
                set lo $value
                set hi $value
                set ascii [expr {$kind eq "NUM" || $value <= 127}]
                set width [string length $text]
                if {[lindex $tokens [expr {$i + 1}] 0] eq ".."} {
                    lassign [lindex $tokens [expr {$i + 2}]] k2 t2 v2 c2
                    if {$k2 ni {CHAR NUM}} {
                        Diag DFA-SYNTAX [Loc $lineNo [lindex $tokens [expr {$i + 1}] 3] 2] "a range needs a symbol on both sides of \"..\""
                        return [list {} -1]
                    }
                    if {$k2 eq "CHAR" && $v2 > 127} {
                        set ascii 0
                    }
                    set hi $v2
                    set width [expr {$c2 + [string length $t2] - $col}]
                    if {$hi < $lo} {
                        Diag DFA-EMPTY-RANGE [Loc $lineNo $col $width] "the range [string range [lindex $tokens $i 1] 0 end]..$t2 is empty: its end is below its start"
                        return [list {} -1]
                    }
                    incr i 2
                }
                lappend items [list kind sym lo $lo hi $hi ascii $ascii col $col width $width \
                    text [expr {$lo == $hi ? $text : "$text..[lindex $tokens $i 1]"}] chars [expr {$kind eq "CHAR"}]]
            }
            IDENT {
                if {$text eq "end"} {
                    lappend items [list kind end col $col width 3 text end]
                } elseif {$text eq "any"} {
                    lappend items [list kind any col $col width 3 text any]
                } else {
                    lappend items [list kind class name $text col $col width [string length $text] text $text]
                }
            }
            STRING {
                lappend items [list kind seq symbols $value col $col width [string length $text] text $text]
            }
            default {
                Diag DFA-SYNTAX [Loc $lineNo $col [string length $text]] "expected a symbol, a range, a class, `any`, `end` or a sequence, found \"$text\""
                return [list {} -1]
            }
        }
        incr i
    }
    return [list $items $i]
}

# A class declaration's tokens (after "class"): {name NAME items I except E line L col C}.
proc dfa::ParseClass {tokens lineNo} {
    lassign [lindex $tokens 1] kind name - col
    if {$kind ne "IDENT" || [lindex $tokens 2 0] ne "="} {
        Diag DFA-SYNTAX [Loc $lineNo [lindex $tokens 0 3] 5] "a class is declared as \"class NAME = ITEMS\""
        return {}
    }
    # "except" is an IDENT token: split on it.
    set at -1
    for {set k 3} {$k < [llength $tokens]} {incr k} {
        if {[lindex $tokens $k 0] eq "IDENT" && [lindex $tokens $k 1] eq "except"} {
            set at $k
            break
        }
    }
    if {$at < 0} {
        lassign [Items $tokens 3 {} $lineNo] items next
        set except {}
    } else {
        lassign [Items [lrange $tokens 0 [expr {$at - 1}]] 3 {} $lineNo] items next
        if {$next < 0} {
            return {}
        }
        lassign [Items $tokens [expr {$at + 1}] {} $lineNo] except next
    }
    if {$next < 0} {
        return {}
    }
    if {![llength $items]} {
        Diag DFA-SYNTAX [Loc $lineNo $col [string length $name]] "class $name has no items"
        return {}
    }
    foreach item [concat $items $except] {
        if {[dict get $item kind] in {end seq}} {
            Diag DFA-SYNTAX [Loc $lineNo [dict get $item col] [dict get $item width]] "a class holds symbols: [expr {[dict get $item kind] eq "end" ? "`end` is no symbol" : "a sequence is not a symbol"}]"
            return {}
        }
    }
    return [list name $name items $items except $except line $lineNo col $col]
}

# A transition line: {items I arrow A action ACT target T dfa D then X line L col C text TEXT}.
proc dfa::ParseTransition {tokens lineNo text} {
    set arrow -1
    for {set k 0} {$k < [llength $tokens]} {incr k} {
        if {[lindex $tokens $k 0] in {-> =>}} {
            set arrow $k
            break
        }
    }
    set col [lindex $tokens 0 3]
    if {$arrow < 1} {
        Diag DFA-SYNTAX [Loc $lineNo $col] "a transition is \"ITEMS -> ACTION\" or \"ITEMS => STATE\""
        return {}
    }
    lassign [Items [lrange $tokens 0 [expr {$arrow - 1}]] 0 {} $lineNo] items next
    if {$next < 0} {
        return {}
    }
    set a [lindex $tokens $arrow 0]
    set rest [lrange $tokens [expr {$arrow + 1}] end]
    set words [lmap t $rest {lindex $t 1}]
    set acol [expr {[llength $rest] ? [lindex $rest 0 3] : [lindex $tokens $arrow 3]}]
    set t [list items $items arrow $a line $lineNo col $col text [string trim $text] acol $acol]
    if {[llength $rest] == 0 || [lsearch -exact -not [lmap x $rest {lindex $x 0}] IDENT] >= 0} {
        Diag DFA-SYNTAX [Loc $lineNo $acol] "expected an action after \"$a\""
        return {}
    }
    if {$a eq "=>"} {
        if {[llength $words] != 1 || [lindex $words 0] in $::dfa::reserved} {
            Diag DFA-SYNTAX [Loc $lineNo $acol] "\"=>\" reconsiders the symbol in a state: \"ITEMS => STATE\""
            return {}
        }
        return [dict merge $t [list action reconsider target [lindex $words 0]]]
    }
    switch -- [lindex $words 0] {
        accept {
            if {$words eq "accept"} {
                return [dict merge $t {action accept}]
            }
            if {$words eq "accept before"} {
                return [dict merge $t {action before}]
            }
        }
        reject {
            if {$words eq "reject"} {
                return [dict merge $t {action reject}]
            }
        }
        call {
            if {[llength $words] == 4 && [lindex $words 2] eq "then"} {
                return [dict merge $t [list action call dfa [lindex $words 1] then [lindex $words 3] dcol [lindex $rest 1 3]]]
            }
            Diag DFA-SYNTAX [Loc $lineNo $acol] "a call is \"-> call DFA then STATE\" or \"-> call DFA then accept\""
            return {}
        }
        default {
            if {[llength $words] == 1 && [lindex $words 0] ni $::dfa::reserved} {
                return [dict merge $t [list action goto target [lindex $words 0]]]
            }
        }
    }
    Diag DFA-SYNTAX [Loc $lineNo $acol] "unknown action \"[join $words]\": expected a state, `accept`, `accept before`, `reject` or `call DFA then ...`"
    return {}
}

# The parsed file: {chunks C classes K dfas D order O} where CHUNKS is a list
# of {text LINES} (passthrough) and {dfa NAME} in source order.
proc dfa::Parse {text} {
    set lines [split $text \n]
    set n [llength $lines]
    set chunks {}
    set pass {}
    set classes [dict create]
    set dfas [dict create]
    set order {}
    for {set i 0} {$i < $n} {} {
        set line [lindex $lines $i]
        set lineNo [expr {$i + 1}]
        set indent [Indent $line]
        if {$indent == 0 && [regexp {^(class|dfa)\s} $line -> word]} {
            if {$word eq "class"} {
                set tokens [Tokens $line $lineNo]
                incr i
                if {![llength $tokens]} {
                    continue
                }
                set c [ParseClass $tokens $lineNo]
                lappend pass "# (dfa class [dict getdef $c name ?]: [string trim [string range $line 5 end]])"
                if {$c eq ""} {
                    continue
                }
                if {[dict exists $classes [dict get $c name]]} {
                    Diag DFA-DUPLICATE [Loc $lineNo [dict get $c col] [string length [dict get $c name]]] "class [dict get $c name] is declared twice" \
                        [list [list "first declared" [Loc [dict get $classes [dict get $c name] line] [dict get $classes [dict get $c name] col]]]]
                    continue
                }
                dict set classes [dict get $c name] $c
                continue
            }
            # A dfa block: the header, then every line indented deeper.
            set body {}
            set j [expr {$i + 1}]
            while {$j < $n && ([Indent [lindex $lines $j]] != 0)} {
                lappend body [list [expr {$j + 1}] [lindex $lines $j]]
                incr j
            }
            # Trailing blank or comment lines belong to what follows.
            while {[llength $body] && [Indent [lindex $body end 1]] == -1} {
                set body [lrange $body 0 end-1]
                incr j -1
            }
            if {[llength $pass]} {
                lappend chunks [list text $pass]
                set pass {}
            }
            set d [ParseDfa $line $lineNo $body]
            set i $j
            if {$d eq ""} {
                continue
            }
            set name [dict get $d name]
            if {[dict exists $dfas $name]} {
                Diag DFA-DUPLICATE [Loc $lineNo [dict get $d col] [string length $name]] "dfa $name is declared twice" \
                    [list [list "first declared" [Loc [dict get $dfas $name line] [dict get $dfas $name col]]]]
                continue
            }
            dict set d before $order
            dict set dfas $name $d
            lappend order $name
            lappend chunks [list dfa $name]
            continue
        }
        lappend pass $line
        incr i
    }
    if {[llength $pass]} {
        lappend chunks [list text $pass]
    }
    return [list chunks $chunks classes $classes dfas $dfas order $order]
}

proc dfa::ParseDfa {header lineNo body} {
    set tokens [Tokens $header $lineNo]
    if {![llength $tokens]} {
        return {}
    }
    set words [lmap t $tokens {lindex $t 1}]
    if {[llength $words] != 5 || [lindex $words 2] ne "over" || [lindex $words 4] ne ":"
            || [lindex $tokens 1 0] ne "IDENT" || [lindex $words 1] in $::dfa::reserved} {
        Diag DFA-SYNTAX [Loc $lineNo 1 3] "a recognizer is declared as \"dfa NAME over ALPHABET:\" (bytes, unicode or ascii)"
        return {}
    }
    set alphabet [lindex $words 3]
    if {$alphabet ni {ascii bytes unicode}} {
        Diag DFA-ALPHABET [Loc $lineNo [lindex $tokens 3 3] [string length $alphabet]] "unknown alphabet \"$alphabet\": a recognizer reads bytes (0..255), unicode (Unicode scalar values) or ascii (0..127, the same symbols in both)"
        return {}
    }
    set d [list name [lindex $words 1] alphabet $alphabet line $lineNo col [lindex $tokens 1 3] \
        classes [dict create] states [dict create] stateOrder {}]
    set levels {}
    set state ""
    foreach entry $body {
        lassign $entry no line
        set indent [Indent $line]
        if {$indent == -1} {
            continue
        }
        if {$indent == -2} {
            Diag DFA-SYNTAX [Loc $no 1] "a tab in indentation"
            continue
        }
        if {![llength $levels]} {
            lappend levels $indent
        }
        set tokens [Tokens $line $no]
        if {![llength $tokens]} {
            continue
        }
        if {$indent == [lindex $levels 0]} {
            set first [lindex $tokens 0]
            if {[lindex $first 1] eq "class"} {
                if {[dict size [dict get $d states]]} {
                    Diag DFA-SYNTAX [Loc $no [lindex $first 3] 5] "a recognizer's classes come before its states"
                    continue
                }
                set c [ParseClass $tokens $no]
                if {$c eq ""} {
                    continue
                }
                if {[dict exists $d classes [dict get $c name]]} {
                    Diag DFA-DUPLICATE [Loc $no [dict get $c col] [string length [dict get $c name]]] "class [dict get $c name] is declared twice in [dict get $d name]"
                    continue
                }
                dict set d classes [dict get $c name] $c
                continue
            }
            if {[llength $tokens] != 2 || [lindex $tokens 0 0] ne "IDENT" || [lindex $tokens 1 0] ne ":"} {
                Diag DFA-SYNTAX [Loc $no [lindex $first 3]] "expected a state (\"NAME:\") or a class"
                set state ""
                continue
            }
            set state [lindex $first 1]
            if {$state in $::dfa::reserved} {
                Diag DFA-SYNTAX [Loc $no [lindex $first 3] [string length $state]] "\"$state\" is a word of the dfa syntax and cannot name a state"
                set state ""
                continue
            }
            if {[dict exists $d states $state]} {
                Diag DFA-DUPLICATE [Loc $no [lindex $first 3] [string length $state]] "state $state is declared twice in [dict get $d name]" \
                    [list [list "first declared" [Loc [dict get $d states $state line] [dict get $d states $state col]]]]
                set state ""
                continue
            }
            dict set d states $state [list line $no col [lindex $first 3] transitions {}]
            dict lappend d stateOrder $state
            continue
        }
        if {$state eq ""} {
            if {[llength [dict get $d stateOrder]] == 0 || $indent < [lindex $levels 0]} {
                Diag DFA-SYNTAX [Loc $no [lindex $tokens 0 3]] "a transition belongs to a state"
            }
            continue
        }
        if {[llength $levels] == 1} {
            lappend levels $indent
        }
        if {$indent != [lindex $levels 1]} {
            Diag DFA-SYNTAX [Loc $no [lindex $tokens 0 3]] "inconsistent indentation"
            continue
        }
        set t [ParseTransition $tokens $no $line]
        if {$t ne ""} {
            set ts [dict get $d states $state transitions]
            lappend ts $t
            dict set d states $state transitions $ts
        }
    }
    if {![llength [dict get $d stateOrder]]} {
        Diag DFA-SYNTAX [Loc $lineNo [dict get $d col] [string length [dict get $d name]]] "dfa [dict get $d name] declares no state"
        return {}
    }
    return $d
}

# ---------------------------------------------------------------------------
# Resolution: the symbol sets of classes and items, sequences expanded.

# The set of class NAME in recognizer D (its own classes, then the file's),
# validated for its alphabet; "" (and a diagnostic) when it does not resolve.
proc dfa::ClassSet {model d name line col} {
    variable resolving
    set alphabet [dict get $d alphabet]
    if {[dict exists $d classes $name]} {
        set c [dict get $d classes $name]
        set key [dict get $d name]/$name
    } elseif {[dict exists $model classes $name]} {
        set c [dict get $model classes $name]
        set key /$name
    } else {
        Diag DFA-UNKNOWN-CLASS [Loc $line $col [string length $name]] "unknown class $name in [dict get $d name]"
        return ""
    }
    if {[info exists resolving($key)]} {
        Diag DFA-UNKNOWN-CLASS [Loc $line $col [string length $name]] "class $name is used in its own definition"
        return ""
    }
    set resolving($key) 1
    try {
        set items [ItemsSet $model $d [dict get $c items] [dict get $c line] 0]
        set except [ItemsSet $model $d [dict get $c except] [dict get $c line] 0]
    } finally {
        unset resolving($key)
    }
    if {$items eq "" || $except eq ""} {
        return ""
    }
    set s [Minus [lindex $items 0] [lindex $except 0]]
    if {![llength $s]} {
        Diag DFA-EMPTY-RANGE [Loc [dict get $c line] [dict get $c col] [string length $name]] "class $name holds no symbol of [dict get $d name]'s alphabet"
        return ""
    }
    return $s
}

# {SET} of ITEMS (no sequences) in recognizer D, or "" on an error. ENDOK:
# whether `end` may appear.
proc dfa::ItemsSet {model d items line endOk} {
    variable END
    set alphabet [dict get $d alphabet]
    set set {}
    set failed 0
    foreach item $items {
        set col [dict get $item col]
        set width [dict get $item width]
        switch -- [dict get $item kind] {
            sym {
                set lo [dict get $item lo]
                set hi [dict get $item hi]
                lassign [AlphabetHull $alphabet] hlo hhi
                if {$alphabet eq "bytes" && [dict get $item chars] && ![dict get $item ascii]} {
                    Diag DFA-BYTE-CHARACTER [Loc $line $col $width] "[dict get $item text] is a character, not a byte: a bytes recognizer reads UTF-8 code units, so only ASCII characters name one byte (write the bytes as numbers, or recognize over unicode)"
                    set failed 1
                    continue
                }
                if {$lo < $hlo || $hi > $hhi} {
                    Diag DFA-ALPHABET [Loc $line $col $width] "[dict get $item text] is outside the alphabet of [dict get $d name] ($alphabet: [Sym $hlo $alphabet]..[Sym $hhi $alphabet])"
                    set failed 1
                    continue
                }
                set s [Inter [list [list $lo $hi]] [AlphabetSet $alphabet]]
                if {![llength $s]} {
                    Diag DFA-ALPHABET [Loc $line $col $width] "[dict get $item text] holds no Unicode scalar value (U+D800..U+DFFF are surrogate code points, never characters)"
                    set failed 1
                    continue
                }
                set set [Union $set $s]
            }
            any {
                set set [Union $set [AlphabetSet $alphabet]]
            }
            end {
                if {!$endOk} {
                    Diag DFA-SYNTAX [Loc $line $col $width] "`end` is the end of the input, not a symbol: it cannot be part of a class"
                    set failed 1
                    continue
                }
                set set [Union $set [list [list $END $END]]]
            }
            class {
                set s [ClassSet $model $d [dict get $item name] $line $col]
                if {$s eq ""} {
                    set failed 1
                    continue
                }
                set set [Union $set $s]
            }
            seq {
                Diag DFA-SYNTAX [Loc $line $col $width] "a sequence is its own transition (\"\"...\" -> ACTION\")"
                set failed 1
            }
        }
    }
    return [expr {$failed ? "" : [list $set]}]
}

# Recognizer D with every transition's symbol set resolved and every sequence
# expanded into anonymous states: {... states S stateOrder O} where each
# transition gains `set`. Transitions that do not resolve are dropped.
proc dfa::Resolve {model d} {
    set states [dict get $d states]
    set order [dict get $d stateOrder]
    set out [dict create]
    set outOrder {}
    foreach name $order {
        set st [dict get $states $name]
        set ts {}
        set extra {}
        foreach t [dict get $st transitions] {
            set items [dict get $t items]
            set seqs [lmap i $items {expr {[dict get $i kind] eq "seq" ? $i : [continue]}}]
            if {[llength $seqs]} {
                if {[llength $items] != 1} {
                    Diag DFA-SYNTAX [Loc [dict get $t line] [dict get [lindex $seqs 0] col] [dict get [lindex $seqs 0] width]] "a sequence is its own transition (\"\"...\" -> ACTION\")"
                    continue
                }
                if {[dict get $t arrow] ne "->" || [dict get $t action] eq "reject"} {
                    Diag DFA-SYNTAX [Loc [dict get $t line] [dict get $t col]] "a sequence consumes its symbols: it takes \"->\" and an action other than reject"
                    continue
                }
                set seq [lindex $seqs 0]
                set symbols [dict get $seq symbols]
                set bad 0
                foreach s $symbols {
                    lassign [AlphabetHull [dict get $d alphabet]] hlo hhi
                    if {[dict get $d alphabet] eq "bytes" && $s > 127} {
                        Diag DFA-BYTE-CHARACTER [Loc [dict get $t line] [dict get $seq col] [dict get $seq width]] "[dict get $seq text] holds a non-ASCII character, not a byte: a bytes recognizer reads UTF-8 code units"
                        set bad 1
                        break
                    }
                    if {$s < $hlo || $s > $hhi || ![llength [Inter [list [list $s $s]] [AlphabetSet [dict get $d alphabet]]]]} {
                        Diag DFA-ALPHABET [Loc [dict get $t line] [dict get $seq col] [dict get $seq width]] "[dict get $seq text] holds [Sym $s [dict get $d alphabet]], which is outside the alphabet of [dict get $d name] ([dict get $d alphabet])"
                        set bad 1
                        break
                    }
                }
                if {$bad} {
                    continue
                }
                # NAME"a" ... : one anonymous state per symbol after the first.
                set from $name
                set read ""
                set n [llength $symbols]
                for {set k 0} {$k < $n} {incr k} {
                    set s [lindex $symbols $k]
                    set step [list set [list [list $s $s]] line [dict get $t line] col [dict get $seq col] \
                        text [dict get $t text] arrow -> anon 1]
                    append read [format %c $s]
                    if {$k == $n - 1} {
                        set step [dict merge $t $step]
                        dict set step anon [expr {$k > 0}]
                    } else {
                        set next "$name\"$read\""
                        dict set step action goto
                        dict set step target $next
                    }
                    if {$k == 0} {
                        lappend ts $step
                    } else {
                        dict lappend extra $from $step
                    }
                    set from [expr {$k < $n - 1 ? $next : ""}]
                }
                continue
            }
            set endOk [expr {[dict get $t action] in {accept before reject reconsider}}]
            set r [ItemsSet $model $d $items [dict get $t line] 1]
            if {$r eq ""} {
                continue
            }
            set s [lindex $r 0]
            if {[dict get $t action] ni {accept before reject reconsider} && [llength [Inter $s {{-1 -1}}]]} {
                Diag DFA-END-CONSUMED [Loc [dict get $t line] [dict get $t col]] "the end of the input cannot be consumed: `end` may only accept, reject or be reconsidered (\"end -> accept\", \"end -> reject\", \"end => STATE\")"
                continue
            }
            lappend ts [dict merge $t [list set $s]]
        }
        dict set out $name [dict merge $st [list transitions $ts anon 0]]
        lappend outOrder $name
        foreach {anonName steps} $extra {
            dict set out $anonName [list line [dict get [lindex $steps 0] line] col [dict get [lindex $steps 0] col] \
                transitions $steps anon 1]
            lappend outOrder $anonName
        }
    }
    dict set d states $out
    dict set d stateOrder $outOrder
    return $d
}

# ---------------------------------------------------------------------------
# Checks and the effective partition.

proc dfa::TransitionLoc {t} {
    return [Loc [dict get $t line] [dict get $t col] [string length [lindex [split [dict get $t text] " "] 0]]]
}

# Determinism: within each state, transitions claim disjoint symbols.
proc dfa::CheckDeterminism {d} {
    set alphabet [dict get $d alphabet]
    foreach name [dict get $d stateOrder] {
        set ts [dict get $d states $name transitions]
        set n [llength $ts]
        for {set i 0} {$i < $n} {incr i} {
            for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
                set a [lindex $ts $i]
                set b [lindex $ts $j]
                set both [Inter [dict get $a set] [dict get $b set]]
                if {[llength $both]} {
                    Diag DFA-AMBIGUOUS-TRANSITION [TransitionLoc $b] \
                        "two transitions of state $name in [dict get $d name] claim [SetText $both $alphabet]: a recognizer takes at most one transition per symbol" \
                        [list [list "[dict get $a text]" [TransitionLoc $a]] [list "[dict get $b text]" [TransitionLoc $b]]]
                }
            }
        }
    }
}

# Names: every target state, every called recognizer.
proc dfa::CheckNames {model d} {
    set ok 1
    foreach name [dict get $d stateOrder] {
        set kept {}
        foreach t [dict get $d states $name transitions] {
            set good 1
            switch -- [dict get $t action] {
                goto - reconsider {
                    if {![dict exists $d states [dict get $t target]]} {
                        Diag DFA-UNKNOWN-STATE [Loc [dict get $t line] [dict get $t acol] [string length [dict get $t target]]] "unknown state [dict get $t target] in [dict get $d name]"
                        set good 0
                    }
                }
                call {
                    set callee [dict get $t dfa]
                    set loc [Loc [dict get $t line] [dict get $t dcol] [string length $callee]]
                    if {$callee eq [dict get $d name]} {
                        Diag DFA-RECURSIVE-CALL $loc "[dict get $d name] calls itself: a recognizer that calls itself needs a stack of unbounded depth, which no finite-state recognizer has (write the nesting in ordinary code with an explicit, bounded stack)"
                        set good 0
                    } elseif {$callee ni [dict get $d before]} {
                        if {[dict exists $model dfas $callee]} {
                            Diag DFA-UNKNOWN-DFA $loc "[dict get $d name] calls $callee, which is declared after it: a recognizer calls only recognizers declared before it (so no call can recur)"
                        } else {
                            Diag DFA-UNKNOWN-DFA $loc "unknown recognizer $callee"
                        }
                        set good 0
                    } elseif {[dict exists $model dfas $callee failed]} {
                        # The callee has diagnostics of its own: this
                        # recognizer is not analyzed further.
                        dict set d failedDependency 1
                    } elseif {[dict get $model dfas $callee alphabet] ni [list ascii [dict get $d alphabet]]} {
                        Diag DFA-CALL-ALPHABET $loc "[dict get $d name] reads [dict get $d alphabet] but $callee reads [dict get $model dfas $callee alphabet]: a call hands the callee the caller's symbols, so the callee reads the same alphabet or ascii (whose symbols mean the same in every alphabet)"
                        set good 0
                    }
                    if {$good && [dict get $t then] ne "accept" && ![dict exists $d states [dict get $t then]]} {
                        Diag DFA-UNKNOWN-STATE [Loc [dict get $t line] [dict get $t acol]] "unknown state [dict get $t then] in [dict get $d name]"
                        set good 0
                    }
                }
            }
            if {$good} {
                lappend kept $t
            } else {
                set ok 0
            }
        }
        dict set d states $name transitions $kept
    }
    return $d
}

# The effective partition of state Q restricted to C: a list of {SET ACTION}
# covering C, every non-consuming move followed statically. ACTION:
#   {goto S} {accept} {before} {reject S implicit?} {call D then T}
# PATH: the states being reconsidered (a revisit is a non-consuming cycle).
# Written transitions record their resolved segments in `resolvedOf`.
proc dfa::Effective {model d q c path {origin ""}} {
    variable resolvedOf
    variable cycles
    set out {}
    set covered {}
    set ts [dict get $d states $q transitions]
    for {set k 0} {$k < [llength $ts]} {incr k} {
        set t [lindex $ts $k]
        set x [Inter $c [dict get $t set]]
        if {![llength $x]} {
            continue
        }
        set covered [Union $covered $x]
        set segs {}
        switch -- [dict get $t action] {
            goto { lappend segs [list $x [list goto [dict get $t target]]] }
            accept { lappend segs [list $x accept] }
            before { lappend segs [list $x before] }
            reject { lappend segs [list $x [list reject $q 0]] }
            reconsider {
                set r [dict get $t target]
                if {$r in $path} {
                    lappend cycles [list [dict get $d name] [concat [lrange $path [lsearch $path $r] end] $r] $x $t]
                    lappend segs [list $x cycle]
                } else {
                    set segs [Effective $model $d $r $x [concat $path $r]]
                }
            }
            call {
                set callee [dict get $model dfas [dict get $t dfa]]
                set calleeStart [lindex [dict get $callee stateOrder] 0]
                foreach seg [Effective $model $callee $calleeStart $x [list $calleeStart]] {
                    lassign $seg y a
                    switch -- [lindex $a 0] {
                        goto - accept - call {
                            lappend segs [list $y [list call [dict get $t dfa] then [dict get $t then]]]
                        }
                        before {
                            # The callee completes before this symbol without
                            # consuming it: the caller reconsiders it.
                            set then [dict get $t then]
                            if {$then eq "accept"} {
                                lappend segs [list $y before]
                            } elseif {$then in $path} {
                                lappend cycles [list [dict get $d name] [concat [lrange $path [lsearch $path $then] end] $then] $y $t]
                                lappend segs [list $y cycle]
                            } else {
                                lappend segs {*}[Effective $model $d $then $y [concat $path $then]]
                            }
                        }
                        reject {
                            lappend segs [list $y [list reject "[dict get $t dfa].[lindex $a 1]" [lindex $a 2]]]
                        }
                    }
                }
            }
        }
        if {[llength $path] == 1} {
            dict lappend resolvedOf "[dict get $d name]/$q/$k" {*}$segs
        }
        lappend out {*}$segs
    }
    set rest [Minus $c $covered]
    if {[llength $rest]} {
        lappend out [list $rest [list reject $q 1]]
    }
    return $out
}

# The effective partitions of every state of D, and the checks that read
# them. Returns D with `effective` {STATE -> partition}, `entered` (states
# that hold a state number), `canAccept`, `errors`.
proc dfa::Analyze {model d} {
    variable resolvedOf
    variable cycles
    variable END
    set resolvedOf [dict create]
    set cycles {}
    set alphabet [dict get $d alphabet]
    set effective [dict create]
    foreach q [dict get $d stateOrder] {
        dict set effective $q [Effective $model $d $q [Universe] [list $q]]
    }
    # Non-consuming cycles, one diagnostic per cycle (its first transition).
    set seen {}
    foreach cy $cycles {
        lassign $cy dname path x t
        set key [lsort -unique [lrange $path 0 end-1]]
        if {$key in $seen} {
            continue
        }
        lappend seen $key
        Diag DFA-NONPROGRESSING-CYCLE [TransitionLoc $t] \
            "$dname can move without consuming forever: on [SetText $x $alphabet] it goes [join $path " => "] and never takes a symbol, accepts or rejects"
    }
    # The states that hold a state number: the start, and every state a
    # consuming transition or a call continues in.
    set start [lindex [dict get $d stateOrder] 0]
    set entered [list $start]
    set work [list $start]
    while {[llength $work]} {
        set work [lassign $work q]
        foreach seg [dict get $effective $q] {
            set a [lindex $seg 1]
            set next ""
            if {[lindex $a 0] eq "goto"} {
                set next [lindex $a 1]
            } elseif {[lindex $a 0] eq "call" && [lindex $a 3] ne "accept"} {
                set next [lindex $a 3]
            }
            if {$next ne "" && $next ni $entered} {
                lappend entered $next
                lappend work $next
            }
        }
    }
    # Written reachability: every state a written transition names, from the
    # start (a state only reconsidered into is used, not entered).
    set reached [list $start]
    set work [list $start]
    while {[llength $work]} {
        set work [lassign $work q]
        foreach t [dict get $d states $q transitions] {
            foreach next [list [dict getdef $t target ""] [dict getdef $t then ""]] {
                if {$next ne "" && $next ne "accept" && $next ni $reached && [dict exists $d states $next]} {
                    lappend reached $next
                    lappend work $next
                }
            }
        }
    }
    foreach q [dict get $d stateOrder] {
        if {$q ni $reached && ![dict get $d states $q anon]} {
            Diag DFA-UNREACHABLE-STATE [Loc [dict get $d states $q line] [dict get $d states $q col] [string length $q]] \
                "state $q of [dict get $d name] is never reached: no transition from the start state leads to it"
        }
    }
    # Acceptance: which states can still lead to a completion.
    set canAccept [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        foreach q [dict get $d stateOrder] {
            if {[dict exists $canAccept $q]} {
                continue
            }
            foreach seg [dict get $effective $q] {
                set a [lindex $seg 1]
                set yes 0
                switch -- [lindex $a 0] {
                    accept - before { set yes 1 }
                    cycle {
                        # Reported as a cycle already: no further claim.
                        set yes 1
                    }
                    goto { set yes [dict exists $canAccept [lindex $a 1]] }
                    call {
                        set yes [expr {[lindex $a 3] eq "accept" || [dict exists $canAccept [lindex $a 3]]}]
                    }
                }
                if {$yes} {
                    dict set canAccept $q 1
                    set changed 1
                    break
                }
            }
        }
    }
    foreach q [dict get $d stateOrder] {
        if {$q in $reached && ![dict exists $canAccept $q]} {
            set what [expr {$q eq $start ? "[dict get $d name] accepts no input at all" : "from state $q of [dict get $d name] no input is ever accepted"}]
            Diag DFA-NO-ACCEPT [Loc [dict get $d states $q line] [dict get $d states $q col] [string length $q]] \
                "$what: every path from it ends in a rejection (add the transition that accepts, or remove the state)"
        }
    }
    # Non-consuming transitions that can only reject.
    foreach q [dict get $d stateOrder] {
        set ts [dict get $d states $q transitions]
        for {set k 0} {$k < [llength $ts]} {incr k} {
            set t [lindex $ts $k]
            if {[dict get $t action] ni {reconsider call}} {
                continue
            }
            set segs [dict getdef $resolvedOf "[dict get $d name]/$q/$k" {}]
            if {[llength $segs] && [llength [lmap s $segs {expr {[lindex $s 1 0] eq "reject" ? [continue] : $s}}]] == 0} {
                set target [expr {[dict get $t action] eq "call" ? "[dict get $t dfa]'s start" : "state [dict get $t target]"}]
                Diag DFA-DEAD-TRANSITION [TransitionLoc $t] \
                    "this transition of state $q in [dict get $d name] can never succeed: $target rejects every symbol it hands over ([SetText [dict get $t set] $alphabet])"
            }
        }
    }
    # A state that accepts before some symbol must say what the end means.
    foreach q [dict get $d stateOrder] {
        set before 0
        set saysEnd 0
        foreach t [dict get $d states $q transitions] {
            if {[dict get $t action] eq "before"} {
                set before 1
            }
            if {[llength [Inter [dict get $t set] [list [list $END $END]]]]} {
                set saysEnd 1
            }
        }
        if {$before && !$saysEnd} {
            Diag DFA-MISSING-END [Loc [dict get $d states $q line] [dict get $d states $q col] [string length $q]] \
                "state $q of [dict get $d name] accepts before a symbol but does not say what the end of the input means: write \"end -> accept\" (the input may end here) or \"end -> reject\""
        }
    }
    # The errors a run can raise.
    set errors {dfa::UnrecognizedInput}
    set endFails 0
    foreach q $entered {
        foreach seg [dict get $effective $q] {
            lassign $seg s a
            if {[lindex $a 0] eq "reject" && [llength [Inter $s [list [list $END $END]]]]} {
                set endFails 1
            }
            if {[lindex $a 0] eq "call" && "dfa::UnexpectedEnd" in [dict get $model dfas [lindex $a 1] errors]} {
                set endFails 1
            }
        }
    }
    if {$endFails} {
        lappend errors dfa::UnexpectedEnd
    }
    # Whether a run can complete leaving its last symbol unread.
    variable leavesUnread
    set unread 0
    foreach q $entered {
        foreach seg [dict get $effective $q] {
            lassign $seg s a
            if {[lindex $a 0] eq "before" || ([lindex $a 0] eq "accept" && [llength [Inter $s [list [list $END $END]]]])
                    || ([lindex $a 0] eq "call" && [lindex $a 3] eq "accept" && [dict get $leavesUnread [lindex $a 1]])} {
                set unread 1
            }
        }
    }
    dict set leavesUnread [dict get $d name] $unread
    dict set d effective $effective
    dict set d entered $entered
    dict set d canAccept $canAccept
    dict set d errors $errors
    return $d
}

# ---------------------------------------------------------------------------
# Lowering.

# The segments of PARTITION over the whole integer line, sorted, adjacent
# segments with one action merged (never across the end symbol).
proc dfa::Segments {partition} {
    variable END
    set segs {}
    foreach seg $partition {
        lassign $seg set a
        foreach i $set {
            # The end is a segment of its own, whatever surrounds it.
            lassign $i lo hi
            if {$lo < $END && $hi >= $END} {
                lappend segs [list $lo [expr {$END - 1}] $a]
                set lo $END
            }
            if {$lo == $END && $hi > $END} {
                lappend segs [list $END $END $a]
                set lo [expr {$END + 1}]
            }
            lappend segs [list $lo $hi $a]
        }
    }
    set segs [lsort -command {apply {{a b} {
        set d [expr {[lindex $a 0] - [lindex $b 0]}]
        expr {$d < 0 ? -1 : ($d > 0 ? 1 : 0)}
    }}} $segs]
    set out {}
    foreach s $segs {
        lassign $s lo hi a
        if {[llength $out] && [lindex $out end 2] eq $a && [lindex $out end 1] + 1 == $lo
                && $lo != $END && [lindex $out end 1] != $END} {
            lset out end 1 $hi
        } else {
            lappend out $s
        }
    }
    return $out
}

proc dfa::Pad {n} { return [string repeat "    " $n] }

proc dfa::Quote {s} { return "\"[string map {\\ \\\\ \" \\\"} $s]\"" }

# The Botlish code of one leaf ACTION at indent N: the value of the search,
# a non-negative Int code. With N the number of entered states: a state
# number S < N (the symbol is consumed: suspend for the next one), N (accept,
# consumed), N+1 (accept, unread), N+2+K (the K-th distinct call, `calls`),
# N+2+|calls|+K (reject; K indexes the qualified state names in `rejects`).
# Codes keep every call in one place, so a callee is inlined once.
proc dfa::Leaf {d a n numbers isEnd codesVar} {
    upvar 1 $codesVar codes
    set p [Pad $n]
    set name [dict get $d name]
    set states [dict size $numbers]
    switch -- [lindex $a 0] {
        goto { return "$p[dict get $numbers [lindex $a 1]]\n" }
        accept {
            # At the end nothing is consumed: `end -> accept` completes untaken.
            return "$p[expr {$isEnd ? $states + 1 : $states}]\n"
        }
        before { return "$p[expr {$states + 1}]\n" }
        reject {
            set state [lindex $a 1]
            set qualified [expr {[string first . $state] >= 0 ? $state : "$name.$state"}]
            dict lappend codes rejects
            set k [lsearch -exact [dict get $codes rejects] $qualified]
            if {$k < 0} {
                set k [llength [dict get $codes rejects]]
                dict lappend codes rejects $qualified
            }
            return "$p[list reject $k]\n"
        }
        call {
            set call [lrange $a 1 3]
            dict lappend codes calls
            set k [lsearch -exact [dict get $codes calls] $call]
            if {$k < 0} {
                set k [llength [dict get $codes calls]]
                dict lappend codes calls $call
            }
            return "$p[expr {$states + 2 + $k}]\n"
        }
    }
    error "unknown action $a"
}

# The leaves of PARTITION: {lo hi LEAF} over the whole integer line, LEAF the
# leaf's code at indent 0 (Leaf), adjacent segments with one leaf merged.
proc dfa::LeafSegments {d partition numbers codesVar} {
    upvar 1 $codesVar codes
    variable END
    set out {}
    foreach seg [Segments $partition] {
        lassign $seg lo hi a
        set leaf [Leaf $d $a 0 $numbers [expr {$lo == $END && $hi == $END}] codes]
        if {[llength $out] && [lindex $out end 2] eq $leaf && [lindex $out end 1] + 1 == $lo} {
            lset out end 1 $hi
        } else {
            lappend out [list $lo $hi $leaf]
        }
    }
    return $out
}

proc dfa::Indented {text n} {
    set p [Pad $n]
    return [join [lmap line [split [string trimright $text \n] \n] {string cat $p $line}] \n]\n
}

# A balanced search over SEGS (each {lo hi LEAF}) at indent N: disjoint
# transitions may be tested in any order, so the order is a search tree's.
proc dfa::SymbolTree {segs n} {
    if {[llength $segs] == 1} {
        return [Indented [lindex $segs 0 2] $n]
    }
    set mid [expr {[llength $segs] / 2}]
    set bound [lindex $segs $mid 0]
    set p [Pad $n]
    set left [SymbolTree [lrange $segs 0 [expr {$mid - 1}]] [expr {$n + 1}]]
    set right [SymbolTree [lrange $segs $mid end] [expr {$n + 1}]]
    return "${p}if c < $bound:\n$left${p}else:\n$right"
}

proc dfa::StateTree {d states n numbers codesVar} {
    upvar 1 $codesVar codes
    if {[llength $states] == 1} {
        return [SymbolTree [LeafSegments $d [dict get $d effective [lindex $states 0]] $numbers codes] $n]
    }
    set mid [expr {[llength $states] / 2}]
    set p [Pad $n]
    set bound [dict get $numbers [lindex $states $mid]]
    set left [StateTree $d [lrange $states 0 [expr {$mid - 1}]] [expr {$n + 1}] $numbers codes]
    set right [StateTree $d [lrange $states $mid end] [expr {$n + 1}] $numbers codes]
    return "${p}if state < $bound:\n$left${p}else:\n$right"
}

# A search over the reject codes of NAMES (code BASE+K for the K-th) giving
# the state name, at indent N.
proc dfa::NameTree {names base n} {
    set p [Pad $n]
    if {[llength $names] == 1} {
        return "$p[Quote [lindex $names 0]]\n"
    }
    set mid [expr {[llength $names] / 2}]
    set left [NameTree [lrange $names 0 [expr {$mid - 1}]] $base [expr {$n + 1}]]
    set right [NameTree [lrange $names $mid end] [expr {$base + $mid}] [expr {$n + 1}]]
    return "${p}if code < [expr {$base + $mid}]:\n$left${p}else:\n$right"
}

proc dfa::ActionText {a alphabet} {
    switch -- [lindex $a 0] {
        goto { return "-> [lindex $a 1]" }
        accept { return "-> accept" }
        before { return "-> accept before" }
        reject { return "reject[expr {[lindex $a 2] ? "" : " (written)"}][expr {[string first . [lindex $a 1]] >= 0 ? " in [lindex $a 1]" : ""}]" }
        call { return "-> call [lindex $a 1] then [lindex $a 3]" }
    }
}

# The table of D's effective transitions, as comment lines.
proc dfa::Table {d} {
    variable MIN
    variable MAX
    set alphabet [dict get $d alphabet]
    set text ""
    foreach q [dict get $d entered] {
        append text "#   $q ([dict get $d numbers $q]):\n"
        foreach s [Segments [dict get $d effective $q]] {
            lassign $s lo hi a
            if {[lindex $a 0] eq "reject" && [lindex $a 2]} {
                continue
            }
            append text "#       [SetText [list [list $lo $hi]] $alphabet] [ActionText $a $alphabet]\n"
        }
    }
    return $text
}

# The ordinary Botlish of recognizer D: one yielding function whose one
# suspension point takes every consuming transition (so a fused resume tests
# one state, COROUTINE-FUSION-MILESTONE-1.md 4.2) and whose next state is a
# self tail call (a loop); a search over the reject codes for the state's
# name; and the entry point `NAME(first)`.
proc dfa::Lower {d file} {
    set name [dict get $d name]
    set entered [dict get $d entered]
    set numbers [dict create]
    set k 0
    foreach q $entered {
        dict set numbers $q $k
        incr k
    }
    dict set d numbers $numbers
    set n [llength $entered]
    set suspends 0
    foreach q $entered {
        foreach seg [dict get $d effective $q] {
            set a [lindex $seg 1]
            if {[lindex $a 0] eq "goto" || ([lindex $a 0] eq "call" && [lindex $a 3] ne "accept")} {
                set suspends 1
            }
        }
    }
    set errors [join [dict get $d errors] ", "]
    set codes [dict create calls {} rejects {}]
    set tree [StateTree $d $entered 1 $numbers codes]
    set calls [dict get $codes calls]
    set rejects [dict get $codes rejects]
    set rejectBase [expr {$n + 2 + [llength $calls]}]
    # A reject leaf's code follows the calls': number them now.
    set lines {}
    foreach line [split $tree \n] {
        if {[regexp {^(\s*)reject (\d+)$} $line -> indent k]} {
            set line "$indent[expr {$rejectBase + $k}]"
        }
        lappend lines $line
    }
    set tree [join $lines \n]
    set text "# dfa $name over [dict get $d alphabet] ([file tail $file]:[dict get $d line]): generated by\n"
    append text "# audit/dfa/tools/dfa.tcl. [llength $entered] state(s); every symbol a state\n"
    append text "# does not list is rejected (dfa::UnrecognizedInput, at the end dfa::UnexpectedEnd).\n"
    append text [Table $d]
    if {[llength $rejects]} {
        # The qualified name of the state a reject code names (raised by the
        # recognizer itself: a function that always fails could not be
        # called, KNOWN-ERROR).
        append text "fn dfa_${name}_state(code: int) -> str:\n"
        append text [NameTree $rejects $rejectBase 1]\n
    }
    # What a code >= N does: complete, call, or reject. A run's result is
    # -2 when its last symbol was taken, else that symbol (unread; -1 at the
    # end): an Int, so that a call returns nothing to allocate.
    set finish ""
    set ret [expr {$suspends ? "return " : ""}]
    set arms [list [list $n "${ret}-2"] [list [expr {$n + 1}] "${ret}c"]]
    set k 0
    foreach call $calls {
        lassign $call callee - then
        if {$then eq "accept"} {
            set body "${ret}dfa_$callee\(0, c)"
        } elseif {![dict get $::dfa::leavesUnread $callee]} {
            # The callee always consumes its last symbol: continue in THEN.
            set body "dfa_$callee\(0, c)\n[dict get $numbers $then]"
        } else {
            set body "r = dfa_$callee\(0, c)\nif r == -2:\n    [dict get $numbers $then]\nelse:\n    return dfa_$name\([dict get $numbers $then], r)"
        }
        lappend arms [list [expr {$n + 2 + $k}] $body]
        incr k
    }
    set reject ""
    if {[llength $rejects]} {
        if {"dfa::UnexpectedEnd" in [dict get $d errors]} {
            append reject "if c == -1:\n    fail dfa::UnexpectedEnd {state: dfa_${name}_state(next)}\n"
        }
        append reject "fail dfa::UnrecognizedInput {state: dfa_${name}_state(next), symbol: c}"
    }
    # Only the arms some leaf uses.
    set used [lsort -unique [regexp -all -inline -line {^\s*\d+$} $tree]]
    set used [lmap u $used {string trim $u}]
    set chain ""
    set first 1
    foreach arm $arms {
        lassign $arm code body
        if {$code ni $used} {
            continue
        }
        append chain "[expr {$first ? "if" : "elif"}] next == $code:\n[Indented $body 1]"
        set first 0
    }
    if {$reject ne ""} {
        append chain [expr {$first ? "$reject\n" : "else:\n[Indented $reject 1]"}]
    }
    append text "fn dfa_$name\(state: int, c: int, resume dfa::Symbol) -> int errors $errors:\n"
    append text "    next = [string trimleft $tree]"
    if {$suspends} {
        append text "    target = if next < $n:\n        next\n    else:\n[Indented $chain 2]"
        append text "    m = yield true\n"
        append text "    dfa_$name\(target, m.code)\n"
    } else {
        append text [Indented $chain 1]
    }
    append text "\n"
    append text "fn $name\(first: int, resume dfa::Symbol) -> bool errors $errors:\n"
    append text "    dfa_$name\(0, first) == -2\n"
    return [list $d $text]
}

# ---------------------------------------------------------------------------
# The support module and the whole file.

proc dfa::SupportModule {} {
    return {# dfa.bot -- the support module of the DFA prototype
# (DFA-COROUTINE-EXPLORATION.md): the one protocol every recognizer that
# audit/dfa/tools/dfa.tcl generates speaks, and the errors it fails with.
# Written by that tool; every recognizer module imports it. It has no code:
# a recognizer is an ordinary coroutine function.

# One input symbol: a byte (0..255) or a Unicode scalar value, as the
# recognizer's alphabet says; -1 is the end of the input (never a symbol).
struct Symbol:
    code: int

# What a recognizer sends back is a Bool: a yield (std::coroutine::done?
# false) sends true -- the symbol was consumed, send the next one; the return
# (done? true) says whether the last symbol was part of the token (false: it
# is the first symbol after it, which the caller still holds).

# A symbol no transition of the current state takes (STATE is DFA.STATE).
error UnrecognizedInput:
    state: str
    symbol: int

# The end of the input in a state that does not accept there.
error UnexpectedEnd:
    state: str
}
}

# {bot TEXT model MODEL diagnostics ENTRIES} for the .dfa file PATH.
proc dfa::compileFile {path} {
    variable diagnostics
    variable leavesUnread
    set diagnostics {}
    set leavesUnread [dict create]
    set text [string map [list \r\n \n \r \n] [ReadText $path]]
    set model [Parse $text]
    # Resolve, check and analyze each recognizer in order: a call reads the
    # callee's analysis.
    foreach name [dict get $model order] {
        set d [dict get $model dfas $name]
        set before [llength $diagnostics]
        set d [Resolve $model $d]
        set d [CheckNames $model $d]
        CheckDeterminism $d
        if {[llength $diagnostics] == $before && ![dict exists $d failedDependency]} {
            set d [Analyze $model $d]
        } else {
            dict set d failed 1
        }
        dict set model dfas $name $d
    }
    set bot ""
    if {![llength $diagnostics]} {
        set bot "# GENERATED by audit/dfa/tools/dfa.tcl from [file tail $path]: edit that file, then\n"
        append bot "# regenerate (tclsh9.0 audit/dfa/tools/dfa.tcl generate [file tail $path]).\n"
        set imported 0
        foreach line [split $text \n] {
            if {[regexp {^import\s+dfa\s*$} $line]} {
                set imported 1
            }
        }
        set needImport [expr {!$imported}]
        foreach chunk [dict get $model chunks] {
            if {[lindex $chunk 0] eq "text"} {
                foreach line [lindex $chunk 1] {
                    if {$needImport && [regexp {^import\s} $line]} {
                        append bot "import dfa\n"
                        set needImport 0
                    }
                    append bot $line\n
                }
            } else {
                set name [lindex $chunk 1]
                lassign [Lower [dict get $model dfas $name] $path] d code
                dict set model dfas $name $d
                if {$needImport} {
                    set bot "[string trimright $bot \n]\n\nimport dfa\n\n"
                    set needImport 0
                }
                append bot $code
            }
        }
        set bot "[string trimright $bot \n]\n"
    }
    return [list bot $bot model $model diagnostics [Entries $path $text]]
}

proc dfa::ReadText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    try {
        return [read $f]
    } finally {
        close $f
    }
}

proc dfa::WriteText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# Raises the diagnostics of RESULT (compileFile's) as the compiler does.
proc dfa::raise {result} {
    set entries [dict get $result diagnostics]
    if {[llength $entries]} {
        core::raiseDiagnostics $entries
    }
}

# What describe prints: per recognizer, its facts and effective table.
proc dfa::Describe {model} {
    set text ""
    foreach name [dict get $model order] {
        set d [dict get $model dfas $name]
        if {[dict exists $d failed]} {
            continue
        }
        set written 0
        foreach q [dict get $d stateOrder] {
            incr written [llength [dict get $d states $q transitions]]
        }
        append text "dfa $name over [dict get $d alphabet]: [llength [dict get $d stateOrder]] states ([llength [dict get $d entered]] entered), $written transitions, errors [join [dict get $d errors] {, }]\n"
        append text [string map {"#   " "    " "#       " "        "} [Table $d]]
    }
    return $text
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    source [file join $dfa::root core core.tcl]
    set args $argv
    set command [lindex $args 0]
    set path [lindex $args 1]
    set options [lrange $args 2 end]
    if {$command ni {generate check describe} || $path eq ""} {
        puts stderr "usage: tclsh9.0 audit/dfa/tools/dfa.tcl generate|check|describe FILE.dfa ?-out FILE.bot? ?-committed 1?"
        exit 2
    }
    set result [dfa::compileFile $path]
    if {[llength [dict get $result diagnostics]]} {
        foreach entry [dict get $result diagnostics] {
            puts stderr "[dict get $entry message] ([lindex [dict get $entry errorcode] 2])"
        }
        exit 1
    }
    set out [dict getdef $options -out [file rootname $path].bot]
    set support [file join [file dirname $out] dfa.bot]
    switch -- $command {
        generate {
            dfa::WriteText $out [dict get $result bot]
            dfa::WriteText $support [dfa::SupportModule]
            puts "wrote $out and $support"
        }
        check {
            if {[dict getdef $options -committed 0]} {
                foreach {file want} [list $out [dict get $result bot] $support [dfa::SupportModule]] {
                    if {![file exists $file] || [dfa::ReadText $file] ne $want} {
                        puts stderr "$file is not what generation produces: regenerate it"
                        exit 1
                    }
                }
            }
            puts "[file tail $path]: [llength [dict get $result model order]] recognizer(s), no diagnostics"
        }
        describe {
            puts -nonewline [dfa::Describe [dict get $result model]]
        }
    }
}
