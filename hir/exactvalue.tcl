# exactvalue.tcl -- exact value facts about immutable values the compiler
# actually knows (EXACT-VALUE-FACTS.md).
#
#   hir::exact::Of HIR E ?LEVEL?      -> FACT | ""
#   hir::exact::IntOf HIR E           -> INTEGER | ""
#   hir::exact::ListOf HIR E ?LEVEL?  -> {list LEVEL SRC...} | ""
#
# The principle: if the compiler already knows the value, do not throw the
# knowledge away and keep only its broad type. E is answered from the HIR
# alone -- what the expression *constructs*, followed through immutable
# bindings -- so the answer is a pure function of (HIR, E): deterministic and
# independent of traversal order.
#
# Type facts vs value facts
# -------------------------
#   type fact    x is List[int]            hir/types.tcl (a static type)
#   value fact   x is exactly [1, 2, 3]    this file
#   range fact   i is exactly 0 / 0..2     hir/range.tcl (a Range)
#
# They interact but are not interchangeable, and no value fact is ever
# encoded in a type: a FACT never appears in a HIR type, a declared
# annotation, an intrinsic parameter contract or a public signature. It is
# ephemeral analysis metadata that any consumer may ignore, and correctness
# never depends on retaining it.
#
# Facts
# -----
#   {int N}        the expression is exactly the Int N
#   {val V}        exactly the scalar core value V (str, bool, unit, UnicodeChar)
#   {list LEVEL SRC...}
#                  exactly an immutable List with these elements, in order.
#                  LEVEL is how deep this List sits inside the outermost
#                  List the query started from (0 for that one), which is
#                  what the level bound counts. Not a type: the ordinary
#                  static type of the expression is whatever hir/types.tcl
#                  says (List[lub of the elements]).
#
# A SRC says where one element's own knowledge comes from:
#   {e EXPR}       the value of expression EXPR (its own type, Range and
#                  fact are the element's -- the compiler already processed
#                  the element expressions when it processed the literal)
#   {v VALUE}      a constant core value (an element of a constant List)
#
# What is followed: a `const` (a scalar or a List of them); a `ref` to an
# immutable local binding (its one `bind`, whose value is what every read
# sees: single assignment is what makes aliases sound without any flow
# analysis) or to a scalar root constant (true/false/unit); a call of
# `list` (a List literal), `list_append` of an exactly known List, `list_get`
# of an exactly known List at an exactly known index (nested projection),
# `list_length` of an exactly known List, and `+ - *` of two exact Ints.
# A `if` is exact when its condition is statically decided, or when both
# branches provably produce the same exact value (never a per-position
# join: "same value" or nothing).
#
# What is deliberately NOT here: a parameter, a loop element, a call of a
# user function, a MutableArray, anything read out of a value that is not
# itself exactly known. A parameter never acquires a fact from how its body
# indexes it or from what its callers pass: that would be a positional
# schema (a record type), which belongs to structs. `list_get(test, 0)`
# proves only that `test` is a list and that the selector is exactly 0.
#
# Bounds (deterministic, named, reported)
# ---------------------------------------
#   maxElements   a List fact keeps at most this many elements. It is the
#                 existing positional-shape bound (hir::types shapeLength),
#                 so every aggregate fact the compiler has forgets at one
#                 boundary. A longer List keeps its ordinary type (and, from
#                 the native's own metadata, its length *range*) and loses
#                 the exact vector -- never a truncated one.
#   maxDepth      List facts nest at most this many levels (hir::types
#                 aggregateDepth): a List whose LEVEL is maxDepth or more
#                 (the fourth nested List) is forgotten.
#   maxSteps      alias/expression steps one query may take (a cycle or
#                 pathological chain answers "no fact"), a determinism guard.
#   maxMagnitude  exact Int arithmetic stops folding beyond +-2^63: a fact
#                 that large is not a useful index and must not make the
#                 compiler compute a huge number.
#
# A fact is forgotten (the query answers "") at: a parameter, a loop
# element, an unknown or user call, a join of different values, a size or
# level bound, and any expression the rules above do not follow.

namespace eval hir::exact {
    variable maxElements 8
    variable maxDepth 3
    variable maxSteps 64
    variable maxMagnitude [expr {1 << 63}]
    variable scalarKinds {str bool unit UnicodeChar}
}

# The exact-value fact of expression E (one of the forms above), or "".
# LEVEL is the nesting level a List E constructs would sit at (0 for a
# top-level query); a projection into an element asks it one level deeper.
proc hir::exact::Of {hir e {level 0}} {
    set steps 0
    return [Eval $hir $e $level steps]
}

# The exact Int E is, or "".
proc hir::exact::IntOf {hir e} {
    set fact [Of $hir $e]
    return [expr {[lindex $fact 0] eq "int" ? [lindex $fact 1] : ""}]
}

# E's exact List fact ({list SRC...}), or "".
proc hir::exact::ListOf {hir e {level 0}} {
    set fact [Of $hir $e $level]
    return [expr {[lindex $fact 0] eq "list" ? $fact : ""}]
}

# The number of elements of List fact FACT.
proc hir::exact::Length {fact} {
    return [expr {[llength $fact] - 2}]
}

# The nesting level of List fact FACT.
proc hir::exact::Level {fact} {
    return [lindex $fact 1]
}

# The SRC of element INDEX of List fact FACT, or "" if INDEX is outside it
# (the read then raises RANGE at run time; nothing is claimed).
proc hir::exact::Element {fact index} {
    if {$index < 0 || $index >= [Length $fact]} {
        return ""
    }
    return [lindex $fact [expr {$index + 2}]]
}

# ---------------------------------------------------------------------------
# Evaluation

proc hir::exact::Eval {hir e level stepsVar} {
    variable maxSteps
    upvar 1 $stepsVar steps
    if {[incr steps] > $maxSteps} {
        return ""
    }
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const {
            return [ValueFact [dict get $node value] $level]
        }
        ref {
            set b [dict get $node binding]
            if {$b eq ""} {
                return ""
            }
            set binding [dict get $hir bindings $b]
            switch -- [dict get $binding kind] {
                root {
                    return [ValueFact [dict get $binding value] $level]
                }
                local {
                    set declaration [dict get $binding declaredBy]
                    if {$declaration eq ""} {
                        return ""
                    }
                    set bind [dict get $hir exprs $declaration]
                    if {[dict get $bind kind] ne "bind" || [dict get $bind duplicate]} {
                        return ""
                    }
                    return [Eval $hir [dict get $bind value] $level steps]
                }
            }
            return ""
        }
        bind {
            if {[dict get $node duplicate]} {
                return ""
            }
            return [Eval $hir [dict get $node value] $level steps]
        }
        call {
            return [CallFact $hir $e $node $level steps]
        }
        if {
            return [IfFact $hir $node $level steps]
        }
    }
    return ""
}

# The fact of constant core value V asked at DEPTH.
proc hir::exact::ValueFact {v level} {
    variable scalarKinds
    variable maxElements
    variable maxDepth
    set kind [core::value::kind $v]
    if {$kind eq "int"} {
        return [list int [core::value::intOf $v]]
    }
    if {$kind in $scalarKinds} {
        return [list val $v]
    }
    if {$kind eq "list"} {
        set items [core::value::items $v]
        if {$level >= $maxDepth || [llength $items] > $maxElements} {
            return ""
        }
        return [list list $level {*}[lmap item $items {list v $item}]]
    }
    return ""
}

proc hir::exact::CallFact {hir e node level stepsVar} {
    variable maxElements
    variable maxDepth
    upvar 1 $stepsVar steps
    lassign [dict get $node target] kind target
    if {$kind ne "native"} {
        return ""
    }
    set name [dict get [hir::symbol $hir $target] name]
    set args [dict get $node args]
    if {[dict get $node known] ne ""} {
        # A statically decided call (a type test, a comparison of exact
        # operands) is exactly a Boolean.
        return [list val [core::value::bool [dict get $node known]]]
    }
    switch -- $name {
        list {
            if {$level >= $maxDepth || [llength $args] > $maxElements} {
                return ""
            }
            foreach a $args {
                if {[hir::typeOf $hir $a] eq "never"} {
                    return ""
                }
            }
            return [list list $level {*}[lmap a $args {list e $a}]]
        }
        list_append {
            if {[llength $args] != 2} {
                return ""
            }
            set fact [Eval $hir [lindex $args 0] $level steps]
            if {[lindex $fact 0] ne "list" || [Length $fact] + 1 > $maxElements
                    || [hir::typeOf $hir [lindex $args 1]] eq "never"} {
                return ""
            }
            return [concat $fact [list [list e [lindex $args 1]]]]
        }
        list_get {
            if {[llength $args] != 2} {
                return ""
            }
            set fact [Eval $hir [lindex $args 0] $level steps]
            if {[lindex $fact 0] ne "list"} {
                return ""
            }
            set index [Eval $hir [lindex $args 1] 0 steps]
            if {[lindex $index 0] ne "int"} {
                return ""
            }
            set src [Element $fact [lindex $index 1]]
            if {$src eq ""} {
                return ""
            }
            return [SourceFact $hir $src [expr {[Level $fact] + 1}] steps]
        }
        list_length {
            if {[llength $args] != 1} {
                return ""
            }
            set fact [Eval $hir [lindex $args 0] $level steps]
            if {[lindex $fact 0] ne "list"} {
                return ""
            }
            return [list int [Length $fact]]
        }
    }
    if {$name in {+ - *} && [llength $args] == 2} {
        set x [Eval $hir [lindex $args 0] 0 steps]
        set y [Eval $hir [lindex $args 1] 0 steps]
        if {[lindex $x 0] ne "int" || [lindex $y 0] ne "int"} {
            return ""
        }
        return [FoldInt $name [lindex $x 1] [lindex $y 1]]
    }
    return ""
}

# {int N} for X op Y, or "" beyond the magnitude bound.
proc hir::exact::FoldInt {op x y} {
    variable maxMagnitude
    switch -- $op {
        + { set n [expr {$x + $y}] }
        - { set n [expr {$x - $y}] }
        * {
            # Cheap pre-check so an enormous product is never computed.
            if {abs($x) >= $maxMagnitude || abs($y) >= $maxMagnitude} {
                return ""
            }
            set n [expr {$x * $y}]
        }
    }
    if {abs($n) >= $maxMagnitude} {
        return ""
    }
    return [list int $n]
}

# The fact of element SRC asked at DEPTH.
proc hir::exact::SourceFact {hir src level stepsVar} {
    upvar 1 $stepsVar steps
    lassign $src kind what
    if {$kind eq "v"} {
        return [ValueFact $what $level]
    }
    return [Eval $hir $what $level steps]
}

# An `if`: exact when its condition is statically decided (the taken
# branch's value), or when both branches' final expressions are exactly the
# same value. Anything else -- in particular a join of two *different* exact
# Lists -- is forgotten: no per-position join is invented.
proc hir::exact::IfFact {hir node level stepsVar} {
    upvar 1 $stepsVar steps
    set known ""
    set condition [Eval $hir [dict get $node condition] 0 steps]
    if {[lindex $condition 0] eq "val" && [core::value::kind [lindex $condition 1]] eq "bool"} {
        set known [core::value::isTrue [lindex $condition 1]]
    }
    set thenTail [lindex [dict get $node thenBody] end]
    set elseTail [lindex [dict get $node elseBody] end]
    if {$known ne ""} {
        set tail [expr {$known ? $thenTail : $elseTail}]
        return [expr {$tail eq "" ? "" : [Eval $hir $tail $level steps]}]
    }
    if {$thenTail eq "" || $elseTail eq ""} {
        return ""
    }
    set a [Eval $hir $thenTail $level steps]
    if {$a eq ""} {
        return ""
    }
    set b [Eval $hir $elseTail $level steps]
    if {$b eq "" || ![Equal $hir $a $b]} {
        return ""
    }
    return $a
}

# ---------------------------------------------------------------------------
# Canonical values, equality and rendering

# The full core value FACT denotes, or "" when some element is not itself
# exactly known (only a fully exact value has a canonical form). Bounded by
# the fact bounds; deterministic.
proc hir::exact::Value {hir fact} {
    set steps 0
    return [MaterialValue $hir $fact 0 steps]
}

proc hir::exact::MaterialValue {hir fact level stepsVar} {
    upvar 1 $stepsVar steps
    switch -- [lindex $fact 0] {
        int { return [core::value::int [lindex $fact 1]] }
        val { return [lindex $fact 1] }
        list {
            set items {}
            foreach src [lrange $fact 2 end] {
                set f [SourceFact $hir $src [expr {[Level $fact] + 1}] steps]
                if {$f eq ""} {
                    return ""
                }
                set v [MaterialValue $hir $f [expr {[Level $fact] + 1}] steps]
                if {$v eq ""} {
                    return ""
                }
                lappend items $v
            }
            return [core::value::listOf $items]
        }
    }
    return ""
}

# 1 if facts A and B denote the same exact value (never by object identity
# or expression id): structural equality of their canonical values.
proc hir::exact::Equal {hir a b} {
    set va [Value $hir $a]
    set vb [Value $hir $b]
    if {$va eq "" || $vb eq ""} {
        return 0
    }
    return [core::value::equal $va $vb]
}

# ---------------------------------------------------------------------------
# Value identity: "provably the same value" (WARNINGS-SAME-RETURN.md)
#
# The one question two consumers keep asking -- do expressions A and B denote
# the same value? -- answered only from facts this file already derives:
#
#   IDENTITY of E is one of
#     {value V}     E is exactly the immutable core value V (Of, then Value:
#                   a scalar, or a List every element of which is exact)
#     {binding B}   E reads the value of the immutable binding B, after
#                   following aliases (`y = x` makes y and x one identity):
#                   whatever B holds, an alias of it holds the same one --
#                   mutable values included, since the *binding* is the
#                   identity, never what the construction looks like
#     ""            nothing is proven
#
# Two expressions are the SAME value when their identities are both proven
# and equal: structurally equal exact values, or the same alias root. This is
# deliberately weaker than semantic equality -- it never reads a runtime `==`,
# never compares two calls (even textually identical ones: a call may have
# effects or yield distinct values), never compares two constructions of a
# mutable value -- and exactly as strong as the facts above already are.
proc hir::exact::Identity {hir e} {
    set fact [Of $hir $e]
    if {$fact ne ""} {
        set v [Value $hir $fact]
        if {$v ne ""} {
            return [list value $v]
        }
    }
    set root [AliasRoot $hir $e]
    return [expr {$root eq "" ? "" : [list binding $root]}]
}

# The BindingId E's value is the value of, following immutable aliases, or "".
# A parameter or loop element is its own root; a local is its own root unless
# its one `bind` is itself a read of another binding. Root and ambient
# bindings (host-held, or constants Of already answers) have no identity here.
proc hir::exact::AliasRoot {hir e} {
    variable maxSteps
    for {set steps 0} {$steps < $maxSteps} {incr steps} {
        set node [dict get $hir exprs $e]
        switch -- [dict get $node kind] {
            bind {
                if {[dict get $node duplicate]} {
                    return ""
                }
                set e [dict get $node value]
            }
            ref {
                set b [dict get $node binding]
                if {$b eq ""} {
                    return ""
                }
                set binding [dict get $hir bindings $b]
                switch -- [dict get $binding kind] {
                    param {
                        return $b
                    }
                    local {
                        set declaration [dict get $binding declaredBy]
                        if {$declaration eq ""} {
                            return ""
                        }
                        set bind [dict get $hir exprs $declaration]
                        if {[dict get $bind kind] ne "bind" || [dict get $bind duplicate]} {
                            return ""
                        }
                        set value [dict get $hir exprs [dict get $bind value]]
                        if {[dict get $value kind] ne "ref"} {
                            return $b
                        }
                        set e [dict get $bind value]
                    }
                    default {
                        return ""
                    }
                }
            }
            default {
                return ""
            }
        }
    }
    return ""
}

# 1 if identities A and B (Identity's results) are both proven and equal.
proc hir::exact::SameIdentity {a b} {
    if {$a eq "" || $b eq "" || [lindex $a 0] ne [lindex $b 0]} {
        return 0
    }
    if {[lindex $a 0] eq "value"} {
        return [core::value::equal [lindex $a 1] [lindex $b 1]]
    }
    return [expr {[lindex $a 1] eq [lindex $b 1]}]
}

# 1 if expressions A and B are provably the same value.
proc hir::exact::SameValue {hir a b} {
    return [SameIdentity [Identity $hir $a] [Identity $hir $b]]
}

# FACT as text, rendered as a *fact*, never as a type:
#   exact-list[str("x"), int(7)]   int(7)   str("x")
proc hir::exact::describe {hir fact} {
    set steps 0
    return [Describe $hir $fact 0 steps]
}

proc hir::exact::Describe {hir fact level stepsVar} {
    upvar 1 $stepsVar steps
    switch -- [lindex $fact 0] {
        int { return "int([lindex $fact 1])" }
        val {
            set v [lindex $fact 1]
            return "[core::value::kind $v]([core::value::show $v])"
        }
        list {
            set parts {}
            foreach src [lrange $fact 2 end] {
                set f [SourceFact $hir $src [expr {[Level $fact] + 1}] steps]
                if {$f ne ""} {
                    lappend parts [Describe $hir $f [expr {[Level $fact] + 1}] steps]
                } else {
                    set t [ElementType $hir $src]
                    lappend parts [expr {$t eq "" ? "?" : "[hir::types::show $t]?"}]
                }
            }
            return "exact-list\[[join $parts {, }]\]"
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Projection: what a consumer learns from element SRC

# The static type of element SRC, or "" (unknown, or dead).
proc hir::exact::ElementType {hir src} {
    lassign $src kind what
    if {$kind eq "v"} {
        return [hir::types::ofValue $what]
    }
    set t [hir::typeOf $hir $what]
    return [expr {$t eq "never" ? "" : $t}]
}

# The Range of element SRC: the range EXPRRANGES (the analysis's ExprId ->
# Range table for the instance being analyzed) recorded for its expression,
# else its exact Int, else unknown.
proc hir::exact::ElementRange {hir src exprRanges} {
    lassign $src kind what
    if {$kind eq "v"} {
        if {[core::value::kind $what] eq "int"} {
            return [hir::range::point [core::value::intOf $what]]
        }
        return [hir::range::unknown]
    }
    if {[dict exists $exprRanges $what]} {
        set r [dict get $exprRanges $what]
        if {$r ne "never"} {
            return $r
        }
    }
    set n [IntOf $hir $what]
    return [expr {$n eq "" ? [hir::range::unknown] : [hir::range::point $n]}]
}

# The static type of `list_get(LISTEXPR, INDEXEXPR)` from exact facts, or ""
# when the list is not exactly known, the index is not exactly known, or the
# index is outside the list (no claim is made about a read that raises).
proc hir::exact::ProjectType {hir listExpr indexExpr} {
    set fact [ListOf $hir $listExpr]
    if {$fact eq ""} {
        return ""
    }
    set n [IntOf $hir $indexExpr]
    if {$n eq ""} {
        return ""
    }
    set src [Element $fact $n]
    if {$src eq ""} {
        return ""
    }
    return [ElementType $hir $src]
}

# The Range of `list_get(LISTEXPR, i)` for an index with Range INDEXRANGE, or
# "" when the list is not exactly known. Every successful read returns some
# element at an index that is both in INDEXRANGE and inside the list, so the
# result is the join of those elements' Ranges: an exact index selects one
# element; a ranged one their join (opportunistic: only the interval and
# exact set the Range domain already carries); an unrestricted valid index
# the join of them all.
proc hir::exact::ProjectRange {hir listExpr indexRange exprRanges} {
    set fact [ListOf $hir $listExpr]
    if {$fact eq ""} {
        return ""
    }
    set indices [CandidateIndices $fact $indexRange]
    if {$indices eq "none"} {
        return ""
    }
    set result never
    foreach i $indices {
        set r [ElementRange $hir [Element $fact $i] $exprRanges]
        set result [expr {$result eq "never" ? $r : [hir::range::join $result $r]}]
    }
    return [expr {$result eq "never" ? "" : $result}]
}

# The indices of List fact FACT a read at a value in INDEXRANGE can reach
# (ascending), or "none" if there is none (the read always raises).
proc hir::exact::CandidateIndices {fact indexRange} {
    set n [Length $fact]
    set exact [hir::range::ExactOf $indexRange]
    set candidates {}
    if {$exact ne ""} {
        foreach i $exact {
            if {$i >= 0 && $i < $n} {
                lappend candidates $i
            }
        }
    } else {
        set lo [dict get $indexRange min]
        set hi [dict get $indexRange max]
        set lo [expr {$lo eq "-inf" || $lo < 0 ? 0 : $lo}]
        set hi [expr {$hi eq "+inf" || $hi > $n - 1 ? $n - 1 : $hi}]
        for {set i $lo} {$i <= $hi} {incr i} {
            lappend candidates $i
        }
    }
    return [expr {$candidates eq "" ? "none" : $candidates}]
}

# The exact length Range of LISTEXPR, or "" if it is not an exactly known List.
proc hir::exact::LengthRange {hir listExpr} {
    set fact [ListOf $hir $listExpr]
    return [expr {$fact eq "" ? "" : [hir::range::point [Length $fact]]}]
}

# Whether `list_get(LISTEXPR, i)` for i in INDEXRANGE stays inside an exactly
# known List: in (every reachable index is inside), out (none is: the read
# always raises RANGE, kept as a run-time error -- there is no static
# RANGE diagnostic to reuse), or "" (unknown, or the List is not exactly
# known).
proc hir::exact::BoundsOf {hir listExpr indexRange} {
    set fact [ListOf $hir $listExpr]
    if {$fact eq ""} {
        return ""
    }
    set n [Length $fact]
    set lo [dict get $indexRange min]
    set hi [dict get $indexRange max]
    if {$lo ne "-inf" && $hi ne "+inf" && $lo >= 0 && $hi < $n} {
        return in
    }
    if {($hi ne "+inf" && $hi < 0) || ($lo ne "-inf" && $lo >= $n)} {
        return out
    }
    set exact [hir::range::ExactOf $indexRange]
    if {$exact ne ""} {
        set inside [lmap i $exact {expr {$i >= 0 && $i < $n ? $i : [continue]}}]
        if {[llength $inside] == [llength $exact]} {
            return in
        }
        if {$inside eq ""} {
            return out
        }
    }
    return ""
}

# The Range a native call NAME of ARGEXPRS (with argument Ranges ARGRANGES,
# and EXPRRANGES the analysis's ExprId -> Range table so far) provably has
# from exact value facts, or "" when none applies. The one entry point
# hir/range.tcl and hir/completions.tcl share, so both read one fact domain.
proc hir::exact::NativeRange {hir name argExprs argRanges exprRanges} {
    switch -- $name {
        list_length {
            if {[llength $argExprs] == 1} {
                return [LengthRange $hir [lindex $argExprs 0]]
            }
        }
        list_get {
            if {[llength $argExprs] == 2} {
                return [ProjectRange $hir [lindex $argExprs 0] [lindex $argRanges 1] $exprRanges]
            }
        }
    }
    return ""
}

# 1/0 if `A OP B` (OP one of == < <= > >=) is statically decided because
# both operands are exactly known, else "". == is structural value equality,
# never object identity (3 == 3 is true, "a" == "b" is false) and is decided
# only between two scalars of one kind; the orderings only between two exact
# Ints. Different kinds, Lists and everything not exactly known decide
# nothing.
proc hir::exact::DecideCompare {op hir a b} {
    set x [Of $hir $a]
    set y [Of $hir $b]
    set kx [lindex $x 0]
    if {$kx eq "" || $kx eq "list" || $kx ne [lindex $y 0]} {
        return ""
    }
    if {$kx eq "int"} {
        set m [lindex $x 1]
        set n [lindex $y 1]
        switch -- $op {
            == { return [expr {$m == $n}] }
            <  { return [expr {$m < $n}] }
            <= { return [expr {$m <= $n}] }
            >  { return [expr {$m > $n}] }
            >= { return [expr {$m >= $n}] }
        }
    }
    if {$op ne "=="} {
        return ""
    }
    set vx [lindex $x 1]
    set vy [lindex $y 1]
    if {[core::value::kind $vx] ne [core::value::kind $vy]} {
        return ""
    }
    return [core::value::equal $vx $vy]
}
