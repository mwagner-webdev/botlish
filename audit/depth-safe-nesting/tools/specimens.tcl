# specimens.tcl -- generated nested Botlish programs and what they mean
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md).
#
#   source audit/depth-safe-nesting/tools/specimens.tcl
#   dsn::specimen KIND N      -> {source TEXT value SHOWN}
#   dsn::malformed KIND N     -> {source TEXT line L column C}
#   dsn::kinds                -> the specimen kinds
#
# Each specimen nests one grammar production (or a mix of them) N deep, and
# carries the value its program's last expression shows, worked out here from
# the specimen's own structure -- an independent model of the nesting, never
# the compiler's answer. The text is deterministic: a failure names the KIND
# and N that reproduce it. Nothing here loads the compiler.

namespace eval dsn {
    variable kinds {paren rbin lbin flat neg not list struct project call
        method or and elif ifnest fnnest handler mixed}
    variable malformedKinds {paren list struct call}
}

proc dsn::kinds {} {
    variable kinds
    return $kinds
}

proc dsn::Indent {k} {
    return [string repeat "    " $k]
}

# A List value N levels deep around 1, as core::value::show prints it.
proc dsn::ListShown {n} {
    return "[string repeat \[ $n]1[string repeat \] $n]"
}

proc dsn::specimen {kind n} {
    switch -- $kind {
        paren {
            # ((((1)))): grouping, whatever its depth, is the value 1.
            return [dict create source "x = [string repeat ( $n]1[string repeat ) $n]\nx\n" value 1]
        }
        rbin {
            # 1 + (1 + (... (1))): right-nested sums.
            set s 1
            for {set i 0} {$i < $n} {incr i} {
                set s "1 + ($s)"
            }
            return [dict create source "x = $s\nx\n" value [expr {$n + 1}]]
        }
        lbin {
            # ((1) + 1) + 1 ...: left-nested differences, so associativity
            # shows: 2N+1 - N - N ... = 1 + N only when each step subtracts
            # from the left.
            set s [expr {2 * $n + 1}]
            for {set i 0} {$i < $n} {incr i} {
                set s "($s) - 1"
            }
            return [dict create source "x = $s\nx\n" value [expr {$n + 1}]]
        }
        flat {
            # 3 - 1 - 1 - ... - 1 with N operators: one line, no
            # parentheses, a left-deep tree; left-associative, so N + 1.
            set start [expr {2 * $n + 1}]
            return [dict create source "x = $start[string repeat { - 1} $n]\nx\n" value [expr {$n + 1}]]
        }
        neg {
            # ----1: N unary minuses.
            return [dict create source "x = [string repeat - $n]1\nx\n" value [expr {$n % 2 ? -1 : 1}]]
        }
        not {
            return [dict create source "x = [string repeat {not } $n]true\nx\n" value [expr {$n % 2 ? "false" : "true"}]]
        }
        list {
            return [dict create source "x = [string repeat \[ $n]1[string repeat \] $n]\nx\n" value [ListShown $n]]
        }
        struct {
            # S0 {next: S1 {next: ... SN {value: 42}}}, read back through a
            # field path N long.
            set text ""
            for {set i 0} {$i < $n} {incr i} {
                append text "struct S$i:\n    next: S[expr {$i + 1}]\n"
            }
            append text "struct S$n:\n    value: int\n"
            set s "S$n {value: 42}"
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                set s "S$i {next: $s}"
            }
            append text "x = $s\nx[string repeat .next $n].value\n"
            return [dict create source $text value 42]
        }
        project {
            # A struct chain built one level per statement, read through a
            # projection chain N long (a left-deep project tree).
            set text ""
            for {set i 0} {$i < $n} {incr i} {
                append text "struct P$i:\n    next: P[expr {$i + 1}]\n"
            }
            append text "struct P$n:\n    value: int\n"
            append text "x$n = P$n {value: 7}\n"
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                append text "x$i = P$i {next: x[expr {$i + 1}]}\n"
            }
            append text "x0[string repeat .next $n].value\n"
            return [dict create source $text value 7]
        }
        call {
            return [dict create source "fn f(a: int) -> int:\n    return a\n\nx = [string repeat f( $n]1[string repeat ) $n]\nx\n" value 1]
        }
        method {
            # x.inc().inc()...: a method chain, a left-deep call tree.
            return [dict create source "fn inc(a: int) -> int:\n    return a + 1\n\nx = 0[string repeat .inc() $n]\nx\n" value $n]
        }
        or {
            # x == 0 or x == 1 or ... : true at the last term only.
            set terms {}
            for {set i 0} {$i < $n} {incr i} {
                lappend terms "x == $i"
            }
            return [dict create source "x = [expr {$n - 1}]\ny = [join $terms { or }]\ny\n" value true]
        }
        and {
            set terms {}
            for {set i 0} {$i < $n} {incr i} {
                lappend terms "x != [expr {$i + 1000000}]"
            }
            return [dict create source "x = 5\ny = [join $terms { and }]\ny\n" value true]
        }
        elif {
            set text "x = [expr {$n - 1}]\ny = if x == 0:\n    0\n"
            for {set i 1} {$i < $n} {incr i} {
                append text "elif x == $i:\n    $i\n"
            }
            append text "else:\n    -1\ny\n"
            return [dict create source $text value [expr {$n - 1}]]
        }
        ifnest {
            # N nested `if c:` statements, an else at every level.
            set text "fn g(c: bool) -> int:\n"
            for {set i 1} {$i <= $n} {incr i} {
                append text "[Indent $i]if c:\n"
            }
            append text "[Indent [expr {$n + 1}]]42\n"
            for {set i $n} {$i >= 1} {incr i -1} {
                append text "[Indent $i]else:\n[Indent [expr {$i + 1}]]$i\n"
            }
            append text "g(true)\n"
            return [dict create source $text value 42]
        }
        fnnest {
            # N nested function declarations, each calling the next.
            set text ""
            for {set i 0} {$i < $n} {incr i} {
                append text "[Indent $i]fn f${i}() -> int:\n"
            }
            append text "[Indent $n]42\n"
            for {set i [expr {$n - 1}]} {$i >= 1} {incr i -1} {
                append text "[Indent $i]f${i}()\n"
            }
            append text "f0()\n"
            return [dict create source $text value 42]
        }
        handler {
            # g(N) fails, its handler calls g(N-1), ... g(0) is 7.
            set text "error E\n\nfn g(k: int) -> int errors E:\n    if k == 0:\n        return 7\n    fail E\n\nx = g($n):\n"
            for {set i 1} {$i <= $n} {incr i} {
                append text "[Indent [expr {2 * $i - 1}]]on E:\n"
                if {$i < $n} {
                    append text "[Indent [expr {2 * $i}]]g([expr {$n - $i}]):\n"
                } else {
                    append text "[Indent [expr {2 * $i}]]g(0):\n[Indent [expr {2 * $i + 1}]]on E:\n[Indent [expr {2 * $i + 2}]]0\n"
                }
            }
            append text "x\n"
            return [dict create source $text value 7]
        }
        mixed {
            # Lists, calls, constructions projected again and parentheses,
            # nested into each other in turn.
            set text "struct Box:\n    value: any\n\nfn f(a):\n    return a\n\n"
            set s 1
            set levels 0
            for {set i 0} {$i < $n} {incr i} {
                switch -- [expr {$i % 4}] {
                    0 { set s "\[$s\]"; incr levels }
                    1 { set s "f($s)" }
                    2 { set s "Box {value: \[$s\]}.value"; incr levels }
                    3 { set s "($s)" }
                }
            }
            return [dict create source "${text}x = $s\nx\n" value [ListShown $levels]]
        }
        default {
            error "dsn::specimen: unknown kind \"$kind\""
        }
    }
}

# A one-token-malformed nested program: N levels of KIND with the innermost
# closing token missing, or the innermost argument malformed. LINE, COLUMN
# and MESSAGE are the first syntax diagnostic's, worked out from the text by
# the parser's own conventions: inside brackets a line break is no token, so
# an unclosed bracket is reported at the next line's first token; an
# unexpected token where it stands.
proc dsn::malformed {kind n} {
    switch -- $kind {
        paren {
            # One ")" missing: the opener stays open past the end of the line.
            set line "x = [string repeat ( $n]1[string repeat ) [expr {$n - 1}]]"
            return [dict create source "$line\nx\n" line 2 column 1 \
                message {expected ")", found name "x"}]
        }
        list {
            set line "x = [string repeat \[ $n]1[string repeat \] [expr {$n - 1}]]"
            return [dict create source "$line\nx\n" line 2 column 1 \
                message {expected "," or "]" in the list, found name "x"}]
        }
        struct {
            # The innermost construction's closing brace missing.
            set decls ""
            for {set i 0} {$i < $n} {incr i} {
                append decls "struct S$i:\n    next: S[expr {$i + 1}]\n"
            }
            append decls "struct S$n:\n    value: int\n"
            set s "S$n \{value: 42"
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                set s "S$i {next: $s}"
            }
            set line "x = $s"
            return [dict create source "${decls}$line\nx\n" line [expr {2 * $n + 4}] column 1 \
                message "expected \",\" or \"\}\" after the value of field \"next\", found name \"x\""]
        }
        call {
            # The innermost argument is an operator with no operand.
            set prefix "x = [string repeat f( $n]1 +"
            set line "$prefix[string repeat ) $n]"
            return [dict create source "fn f(a: int) -> int:\n    return a\n\n$line\nx\n" line 4 \
                column [expr {[string length $prefix] + 1}] message {expected an expression, found ")"}]
        }
        default {
            error "dsn::malformed: unknown kind \"$kind\""
        }
    }
}
