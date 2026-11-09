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
        method or and elif ifnest fnnest handler mixed typed pattern loops affine inject layout cond}
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

# The `loops` specimen's loops N deep, from the header continuing `y = `:
# each level's header, the next one level further in (after a fold, as the
# value bound to its `inner`), and after the innermost [1] each fold's last
# line, the innermost's first. Built in a loop: the generator nests nothing.
proc dsn::LoopsLevels {n} {
    set text ""
    set closing {}
    for {set i 0} {$i < $n} {incr i} {
        set in [Indent [expr {$i + 1}]]
        switch -- [expr {$i % 3}] {
            0 { append text "loop x$i in \[1\]:\n$in" }
            1 { append text "loop x$i from 1 through 1:\n$in" }
            2 {
                append text "fold x$i in \[1\] with intermediate a$i 0:\n${in}inner$i = "
                set closing [linsert $closing 0 "${in}a$i + std::list::length(inner$i)\n"]
            }
        }
    }
    return "$text\[1\]\n[join $closing ""]"
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
        typed {
            # A parameter's written type List[List[...int...]] N deep, given
            # a List literal as deep: the outermost List has one element.
            set type "[string repeat List\[ $n]int[string repeat \] $n]"
            set text "import std::list\n\nfn f(x: $type) -> int:\n    return std::list::length(x)\n\n"
            return [dict create source "${text}f([string repeat \[ $n]1[string repeat \] $n])\n" value 1]
        }
        pattern {
            # The struct chain of `struct`, taken apart by one destructuring
            # pattern {next: {next: ... {value: y}}} N deep.
            set text ""
            for {set i 0} {$i < $n} {incr i} {
                append text "struct D$i:\n    next: D[expr {$i + 1}]\n"
            }
            append text "struct D$n:\n    value: int\n"
            set s "D$n {value: 9}"
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                set s "D$i {next: $s}"
            }
            set pattern "[string repeat "\{next: " $n]\{value: y\}[string repeat \} $n]"
            return [dict create source "${text}x = $s\n$pattern = x\ny\n" value 9]
        }
        loops {
            # N nested loops, cycling a collecting loop over [1], a counted
            # collecting loop from 1 through 1 and a fold over [1] from 0
            # whose body binds the next loop and adds its length -- each one
            # iteration, around [1]. A collecting loop wraps its body's value
            # in a List; a fold is 0 + the length of the List its body bound,
            # 1. (A fold whose intermediate's type widens is walked again
            # per fixpoint attempt: nested, that is exponential, the report's
            # section 25; this one's intermediate stays an Int.)
            set text "import std::list\n\ny = [LoopsLevels $n]y\n"
            set value {list 1}
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                if {$i % 3 == 2} {
                    set value {int 1}
                } elseif {[lindex $value 0] eq "list"} {
                    set value [list list [expr {[lindex $value 1] + 1}]]
                } else {
                    set value {list 1}
                }
            }
            return [dict create source $text value [expr {[lindex $value 0] eq "list" ? [ListShown [lindex $value 1]] : 1}]]
        }
        affine {
            # The struct chain built in one expression, its innermost field a
            # coroutine handle: every struct of the chain is affine. Made
            # twice, passed, returned and dropped; main's value is 1.
            set text "import std::coroutine\n"
            for {set i 0} {$i < $n} {incr i} {
                append text "struct A$i:\n    next: A[expr {$i + 1}]\n"
            }
            set c {Coroutine{args: [], return: int}}
            append text "struct A$n:\n    c: $c\nfn worker(seed: int) -> int:\n    yield seed\n    seed\n"
            append text "fn make(seed: int) -> $c:\n    coroutine \{step\} = worker(seed)\n    step\n"
            set s "A$n \{c: make(1)\}"
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                set s "A$i \{next: $s\}"
            }
            append text "fn build() -> A0:\n    $s\nfn pass(x: A0) -> A0:\n    x\n"
            append text "fn main() -> int:\n    a = build()\n    b = pass(a)\n    pass(build())\n    1\nmain()\n"
            return [dict create source $text value 1]
        }
        inject {
            # N nested `inject no context:` blocks around 1.
            set text "fn f() -> int:\n"
            for {set i 1} {$i <= $n} {incr i} {
                append text "[Indent $i]inject no context:\n"
            }
            append text "[Indent [expr {$n + 1}]]1\nf()\n"
            return [dict create source $text value 1]
        }
        layout {
            # A layout field `array 1 of array 1 of ... U8` N deep, parsed
            # from one byte: its value is a List N deep, the outermost of
            # length 1.
            set repr std::binary::U8
            for {set i 0} {$i < $n} {incr i} {
                set repr "array 1 of $repr"
            }
            set text "import std::abi::bytes\nimport std::binary\nimport std::byte\nimport std::list\n\n"
            append text "layout L:\n    size 1\n    align 1\n    field a: $repr at 0\n\n"
            append text "fn g() -> int:\n    b = std::byte::from_int(7):\n        on std::byte::BelowRange:\n            0\n        on std::byte::AboveRange:\n            255\n"
            append text "    r = std::binary::parse(L, std::abi::bytes::from_list(\[b\])):\n        on LayoutLengthMismatch:\n            return 0\n"
            append text "    std::list::length(r.a)\n\ng()\n"
            return [dict create source $text value 1]
        }
        cond {
            # One Boolean condition N deep -- `and`, `or` and `not not` in
            # turn, each around a parenthesized rest, the innermost true --
            # branched on by an `if` at the top level and by one in a
            # collecting loop's body (a region consumer): true each time.
            set c "v == 5"
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                set k [expr {1000000 + $i}]
                switch -- [expr {$i % 3}] {
                    0 { set c "v != $k and ($c)" }
                    1 { set c "v == $k or ($c)" }
                    2 { set c "not not ($c)" }
                }
            }
            set text "v = 5\nz = if $c:\n    1\nelse:\n    0\n"
            append text "ys = loop v2 in \[5\]:\n    if [string map {"v " "v2 "} $c]:\n        1\n    else:\n        0\n"
            append text "\[z, ys\]\n"
            return [dict create source $text value {[1, [1]]}]
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
