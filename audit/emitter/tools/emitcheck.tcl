# emitcheck.tcl -- grammar-constrained emission: a static checker of emitter
# coroutines against declared recognizers (EMITTER-COROUTINE-EXPLORATION.md).
# An exploratory prototype, isolated from the compiler: nothing in core/,
# hir/, surface/, compiler/ or native/ loads it.
#
#   tclsh9.0 audit/emitter/tools/emitcheck.tcl PROGRAM.bot ?-emits FN=RECOGNIZER ...?
#       prints every diagnostic (FILE:LINE:COLUMN: message (EMIT KIND)) and
#       a summary per checked emitter; exits 1 when there is a diagnostic
#
#   source audit/emitter/tools/emitcheck.tcl
#   emitcheck::check PATH ?-emits {FN RECOGNIZER ...}?
#       => {diagnostics {DIAG...} emitters {SUMMARY...}}
#
# An *emitter* is an ordinary Botlish function whose yields send symbols: an
# Int per yield, a byte, an ASCII code or a Unicode scalar value as the
# recognizer's alphabet says. It is associated with a declared recognizer R
# by a directive comment on the line before its `fn` (no syntax: the
# experiment does not change the language),
#
#   #: emits json_lex::json_number
#   fn integer(n: int) -> unit errors IndexNotFound:
#
# or by -emits. The claim checked, for every emitter: every normal
# completion of a call of it has yielded a sequence of symbols that R, fed
# them and then the end of the input, recognizes as exactly one token
# (accept, nothing left unread). Failure is not completion: an emitter may
# fail after yielding a prefix (the guarantee is about success, never about
# what an external sink already holds).
#
# The method is abstract interpretation of the emitter's HIR over R's
# *effective table* (surface/dfa.tcl's model: one partition of the whole Int
# line per state, exact interval sets), never generated code and never a
# second DFA implementation. An abstract state is a set of *composite*
# states: the stack of recognizers a call transition entered (`call D then
# T`), innermost last, each frame a state; calls are acyclic (the DFA
# checker's DFA-RECURSIVE-CALL), so the space is finite. A yield of the
# symbol set X from composite C partitions X by C's effective row: a goto
# moves, a call pushes its callee and hands it the symbols, `accept` pops
# (the caller continues in its `then` state, or completes with the
# callee), `accept before 1` pops and reconsiders the symbols in the
# caller's state -- exactly the recognizer's own semantics
# (DFA-COROUTINE-MILESTONE-2.md, section 4) -- and anything else is a
# violation. A normal completion feeds the end (-1).
#
# Symbol sets come from facts the compiler already proves: an exact
# constant; the range analysis (hir::range, per used instance, the union
# over the emitter's instances: native lowering's own facts); the result
# set of a native whose values are a set (std::char::scalar_value: the
# Unicode scalar values, never a surrogate); and path facts the checker
# adds -- the branch conditions on the path to the yield that compare the
# yielded binding with a constant (`c == 34 or c == 92` false excludes both,
# which an interval cannot say), decomposed by hir::range::Paths, and a
# *guard*: a normal completion of a call of a non-suspending recognizer
# (`dfa digit over ascii: start: json_lex::digit -> accept` is an ordinary
# function of one symbol) with the binding as its symbol, after which the
# binding is in what the guard accepts.
#
# Control flow: sequences, `if` (the join), every loop (a fixpoint over the
# finite state sets), break/continue/return, handlers (entered from any
# state the protected expression passed through), and calls of functions
# that may yield (deep yields: summaries per entry composite state, computed
# to a fixpoint, so recursion is analyzed too). A function that cannot yield
# changes nothing; a coroutine constructed inside an emitter is another
# coroutine: its yields are not the emitter's.
#
# Diagnostics (kind: what it means):
#   EMIT-REJECTED      a yield may send symbols the current state takes no
#                      transition on (an out-of-alphabet value included)
#   EMIT-BEYOND-TOKEN  a yield may send a symbol the token ends before
#                      (`accept before`): it would begin the next token
#   EMIT-AFTER-TOKEN   a yield after the token is already complete
#   EMIT-INCOMPLETE    a normal completion while the token is incomplete
#   EMIT-END-SYMBOL    a yield may send -1, which is the end, never a symbol
#   EMIT-NOT-SYMBOL    a yield sends a value that is not an Int
#   EMIT-BYTE-CHARACTER  a character's scalar value sent to a bytes
#                      recognizer (DFA-BYTE-CHARACTER's rule, for emitters)
#   EMIT-TERMINAL-VALUE  a coroutine root's final value is not -1, so a
#                      consumer reading it as a symbol source would read it
#   EMIT-UNKNOWN-RECOGNIZER  the directive names no declared recognizer
# Each is {kind KIND location FILE:LINE:COLUMN message TEXT related
# {{TEXT LOCATION}...}}.

set emitcheckRoot [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
if {[info commands ::surface::readProgramFile] eq ""} {
    source [file join $emitcheckRoot surface surface.tcl]
}
if {[info commands ::hir::specialize::analyze] eq ""} {
    source [file join $emitcheckRoot native native.tcl]
}

namespace eval emitcheck {
    variable END -1
    # The Unicode scalar values (what a UnicodeChar can be).
    variable scalars {{0 55295} {57344 1114111}}
    # Natives whose result is a set an interval cannot state.
    variable resultSets [dict create std::char::scalar_value {{0 55295} {57344 1114111}}]
    # The analysis in progress (check).
    variable hir
    variable ranges
    variable instancesOf
    variable models
    variable guards
    variable summaries
    variable round
    variable changed
    variable diagnostics
    variable returns
    variable breaks
    variable continues
    variable visited
    variable facts
    variable block
    # The sets the parameters of the block being analyzed were called with
    # (binding -> interval set): part of a summary's context.
    variable params [dict create]
    # {NAME RECOGNIZER LOCATION} of the claim being checked.
    variable checking ""
}

# ---------------------------------------------------------------------------
# The recognizers: surface/dfa.tcl's analyzed models

# The files of the program whose entry file is ENTRY that hold its source:
# {NS PATH} (the entry program's NS ""), the entry and every application
# module it imports, directly or not (surface/modules.tcl's rule: ROOT/NAME.bot,
# ROOT/A/B.bot for A::B; a standard namespace holds no recognizer an
# emitter could claim).
proc emitcheck::ApplicationFiles {entry} {
    set root [file dirname [file normalize $entry]]
    set files [dict create "" [file normalize $entry]]
    set work [list [file normalize $entry]]
    while {[llength $work]} {
        set work [lassign $work path]
        set ast [surface::parse [core::ReadFile $path] $path]
        foreach i [dict get $ast imports] {
            set ns [dict get $i namespace]
            if {[string match std::* $ns] || [dict exists $files $ns]} continue
            set file [file join $root {*}[split [string map {:: /} $ns] /]].bot
            if {[file exists $file]} {
                dict set files $ns $file
                lappend work $file
            }
        }
    }
    return $files
}

# The analyzed recognizers of the program whose entry file is ENTRY: {NS
# NAME} -> model (surface::dfa::expand's dfaModel). Each file that declares
# a class or recognizer is expanded after the files it imports, with the
# registry they leave, as the loader does (surface/modules.tcl's
# ExpandDfas).
proc emitcheck::Models {entry} {
    set asts [dict create]
    dict for {ns path} [ApplicationFiles $entry] {
        set ast [surface::parse [core::ReadFile $path] $path]
        set has 0
        foreach s [dict get $ast body] {
            if {[dict get $s kind] in {classdecl dfadecl}} {
                set has 1
                break
            }
        }
        if {$has} {
            dict set asts $ns $ast
        }
    }
    set order {}
    set seen [dict create]
    dict for {ns -} $asts {
        Visit $asts $ns seen order
    }
    set registry [dict create]
    set models [dict create]
    foreach ns $order {
        set ast [dict get $asts $ns]
        set imports [lmap i [dict get $ast imports] {dict get $i namespace}]
        set result [surface::dfa::expand [dict get $ast body] -own $ns -imports $imports -registry $registry]
        set registry [dict get $result registry]
        foreach s [dict get $result statements] {
            if {[dict exists $s dfaModel]} {
                dict set models [list $ns [dict get $s name]] [dict get $s dfaModel]
            }
        }
    }
    return $models
}

proc emitcheck::Visit {asts ns seenVar orderVar} {
    upvar 1 $seenVar seen $orderVar order
    if {[dict exists $seen $ns]} {
        return
    }
    dict set seen $ns 1
    foreach i [dict get $asts $ns imports] {
        set dep [dict get $i namespace]
        if {[dict exists $asts $dep]} {
            Visit $asts $dep seen order
        }
    }
    lappend order $ns
}

# The start state of recognizer KEY.
proc emitcheck::Start {key} {
    variable models
    return [lindex [dict get $models $key entered] 0]
}

proc emitcheck::KeyText {key} {
    lassign $key ns name
    if {$ns eq ""} {
        return $name
    }
    return ${ns}::$name
}

# ---------------------------------------------------------------------------
# The emission automaton: composite states over the effective tables
#
# A composite state is {STACK KEY STATE}: recognizer KEY in STATE, called
# from the frames of STACK ({KEY THEN}..., outermost first: THEN the state
# the caller continues in, or accept), or `done`: the token is complete.

# The composite state of recognizer KEY before its first symbol.
proc emitcheck::Initial {key} {
    return [list {} $key [Start $key]]
}

# {SET RESULT}...: what composite C does with each part of the symbol set X
# (an interval set; X may hold the end, -1). RESULT is a composite state,
# `done`, or {violation KIND KEY STATE ?N?} (KIND reject, beyond, after,
# lookahead).
proc emitcheck::Step {c x} {
    if {$c eq "done" || [llength $c] == 3} {
        return [Step3 $c $x]
    }
    # A boundary obligation {DEPTH NAME CALL}: the frame at DEPTH holds the
    # token a helper (NAME, called at CALL) claims to have emitted whole, so
    # the next symbol must end it (the frame is gone after the step).
    lassign $c stack key q pending
    lassign $pending depth name call
    set out {}
    foreach r [Step3 [list $stack $key $q] $x] {
        lassign $r y result
        if {$result ne "done" && [lindex $result 0] ne "violation"
                && [llength [lindex $result 0]] >= $depth
                && [FrameKey $result $depth] eq [FrameKey $c $depth]} {
            lappend out [list $y [list violation boundary [FrameKey $c $depth] $name $call]]
            continue
        }
        lappend out $r
    }
    return $out
}

# The recognizer of the frame at DEPTH (0 the outermost) of composite C.
proc emitcheck::FrameKey {c depth} {
    lassign $c stack key
    if {$depth == [llength $stack]} {
        return $key
    }
    return [lindex $stack $depth 0]
}

# The depth of recognizer KEY's frame in composite C, or -1.
proc emitcheck::FrameDepth {c key} {
    if {$c eq "done"} {
        return -1
    }
    lassign $c stack k
    for {set i 0} {$i < [llength $stack]} {incr i} {
        if {[lindex $stack $i 0] eq $key} {
            return $i
        }
    }
    if {$k eq $key} {
        return [llength $stack]
    }
    return -1
}

proc emitcheck::Step3 {c x} {
    variable models
    if {$c eq "done"} {
        return [list [list $x [list violation after "" ""]]]
    }
    lassign $c stack key q
    set out {}
    foreach seg [dict get $models $key effective $q] {
        lassign $seg set a
        set y [surface::dfa::Inter $set $x]
        if {$y eq {}} {
            continue
        }
        switch -- [lindex $a 0] {
            goto {
                lappend out [list $y [list $stack $key [lindex $a 1]]]
            }
            accept {
                lappend out {*}[Pop $stack $key $q $y [lindex $a 1]]
            }
            reject {
                lappend out [list $y [list violation reject $key $q]]
            }
            call {
                set callee [lindex $a 1]
                set then [lindex $a 3]
                lappend out {*}[Step [list [concat $stack [list [list $key $then]]] $callee [Start $callee]] $y]
            }
        }
    }
    return $out
}

# Recognizer KEY completed in state Q on the symbols Y (or the end) leaving N
# unread: what its caller -- or, at the outermost frame, the token -- does.
proc emitcheck::Pop {stack key q y n} {
    variable END
    set atEnd [expr {$y eq [list [list $END $END]]}]
    if {$stack eq {}} {
        if {$n == 0} {
            return [list [list $y done]]
        }
        return [list [list $y [list violation beyond $key $q $n]]]
    }
    lassign [lindex $stack end] ckey then
    set rest [lrange $stack 0 end-1]
    if {$then eq "accept"} {
        return [Pop $rest $ckey $q $y $n]
    }
    set c [list $rest $ckey $then]
    if {$n == 0 && !$atEnd} {
        return [list [list $y $c]]
    }
    if {$n <= 1} {
        # The callee left the symbol (or the end) unread: the caller's state
        # reconsiders it at once.
        return [Step $c $y]
    }
    return [list [list $y [list violation lookahead $key $q $n]]]
}

# The text of composite C: the innermost recognizer's state, with the
# frames it was called from.
proc emitcheck::StateText {c} {
    if {$c eq "done"} {
        return "the complete token"
    }
    lassign $c stack key q
    set text "state $q of [KeyText $key]"
    foreach frame [lreverse $stack] {
        lassign $frame k then
        append text " (called by [KeyText $k], then $then)"
    }
    return $text
}

# The location of the declaration of state Q of recognizer KEY.
proc emitcheck::StateLocation {key q} {
    variable models
    if {$key eq "" || ![dict exists $models $key states $q nameSpan]} {
        return ""
    }
    return [surface::ast::location [dict get $models $key states $q nameSpan]]
}

# The symbols composite C takes without completing or failing, and those it
# completes on: {TAKES COMPLETES} (interval sets, the end excluded): what a
# diagnostic says C needs.
proc emitcheck::Expected {c} {
    variable END
    set takes {}
    set completes {}
    foreach r [Step $c [surface::dfa::Minus [surface::dfa::Universe] [list [list $END $END]]]] {
        lassign $r y result
        if {$result eq "done"} {
            set completes [surface::dfa::Union $completes $y]
        } elseif {[lindex $result 0] ne "violation"} {
            set takes [surface::dfa::Union $takes $y]
        }
    }
    return [list $takes $completes]
}

# ---------------------------------------------------------------------------
# Diagnostics

proc emitcheck::Location {e} {
    variable hir
    return [hir::originLocation $hir [dict get $hir exprs $e origin]]
}

# Records diagnostic KIND at expression E: WHAT a short description of the
# problem (the message's head), STATE the composite state it occurs in ("" for
# none), SET the symbols. Diagnostics of one kind at one expression are one
# diagnostic, listing each state with its symbols (Messages).
proc emitcheck::Diag {kind e what {state ""} {set {}} {alphabet unicode}} {
    variable diagnostics
    variable checking
    set id [list $kind $e $checking]
    if {![dict exists $diagnostics $id]} {
        dict set diagnostics $id [dict create kind $kind expr $e location [Location $e] what $what \
            alphabet $alphabet states [dict create] checking $checking]
    }
    if {$state ne ""} {
        set old [dict getdef [dict get $diagnostics $id states] $state {}]
        dict set diagnostics $id states $state [surface::dfa::Union $old $set]
    }
}

# The text of the interval set SET of ALPHABET: its symbols, and the values
# outside the alphabet as one phrase.
proc emitcheck::SetText {set alphabet} {
    set inside [surface::dfa::Inter $set [list [surface::dfa::AlphabetHull $alphabet]]]
    set parts {}
    if {$inside ne {}} {
        lappend parts [surface::dfa::SetText $inside $alphabet]
    }
    if {[surface::dfa::Minus $set [list [surface::dfa::AlphabetHull $alphabet]]] ne {}} {
        lappend parts "values outside the alphabet ($alphabet)"
    }
    return [join $parts " and "]
}

# DIAG ({kind expr location what states}) as the checker reports it:
# {kind KIND location LOCATION message TEXT related {{TEXT LOCATION}...}}.
proc emitcheck::Message {diag} {
    set states [dict get $diag states]
    set alphabet [dict get $diag alphabet]
    set message [dict get $diag what]
    set related {}
    set all {}
    set parts {}
    # One part per state as shown (states that differ only in a boundary
    # obligation are one).
    set byText [dict create]
    foreach c [lsort [dict keys $states]] {
        set text [StateText $c]
        dict set byText $text [surface::dfa::Union [dict getdef $byText $text {}] [dict get $states $c]]
        if {$c ne "done"} {
            lassign $c - key q
            set where [StateLocation $key $q]
            set note [list "state $q of [KeyText $key]" $where]
            if {$where ne "" && $note ni $related && [llength $related] < 4} {
                lappend related $note
            }
        }
    }
    dict for {text y} $byText {
        set all [surface::dfa::Union $all $y]
        if {$y ne {}} {
            lappend parts "[SetText $y $alphabet] in $text"
        } else {
            lappend parts $text
        }
    }
    if {$parts ne {}} {
        if {[llength $parts] > 4} {
            set parts [list {*}[lrange $parts 0 3] "and [expr {[llength $parts] - 4}] more states"]
        }
        append message ": [join $parts {; }]"
    }
    set checking [dict get $diag checking]
    if {$checking ne "" && [lindex $checking 2] ne [dict get $diag location]} {
        lappend related [list "checking [lindex $checking 0]'s claim to emit [lindex $checking 1]" [lindex $checking 2]]
    }
    return [dict create kind [dict get $diag kind] location [dict get $diag location] message $message related $related]
}

# ---------------------------------------------------------------------------
# Symbol sets

proc emitcheck::NativeName {e} {
    variable hir
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    lassign [dict get $node target] tk target
    if {$tk ne "native"} {
        return ""
    }
    return [dict get [hir::symbol $hir $target] name]
}

proc emitcheck::RefBinding {e} {
    variable hir
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "ref"} {
        return ""
    }
    set b [dict get $node binding]
    if {$b eq "" || [dict get [hir::binding $hir $b] kind] ni {local param}} {
        return ""
    }
    return $b
}

# The interval set of a Range (hir::range): its exact values when it tracks
# them, else its interval, the whole line when unbounded.
proc emitcheck::RangeSet {r} {
    set min $::surface::dfa::MIN
    set max $::surface::dfa::MAX
    if {$r eq "never"} {
        return {}
    }
    if {[dict exists $r exact] && [dict get $r exact] ne ""} {
        return [surface::dfa::Norm [lmap v [dict get $r exact] {list $v $v}]]
    }
    set lo [dict get $r min]
    set hi [dict get $r max]
    if {$lo eq "-inf" || $lo < $min} {
        set lo $min
    }
    if {$hi eq "+inf" || $hi > $max} {
        set hi $max
    }
    return [list [list $lo $hi]]
}

# What the range analysis proves of E in the function being analyzed: the
# union over the function's used instances (none: nothing).
proc emitcheck::RangeOf {e} {
    variable ranges
    variable instancesOf
    variable block
    set ids [dict getdef $instancesOf $block {}]
    if {$ids eq {}} {
        return [surface::dfa::Universe]
    }
    set out {}
    foreach id $ids {
        set out [surface::dfa::Union $out [RangeSet [hir::range::of $ranges $id $e]]]
    }
    return $out
}

# The set a native call E's result is in beyond its Range, or the universe.
proc emitcheck::ResultSet {e} {
    variable resultSets
    set name [NativeName $e]
    if {[dict exists $resultSets $name]} {
        return [dict get $resultSets $name]
    }
    return [surface::dfa::Universe]
}

# 1 if E's value is a character's scalar value: a std::char::scalar_value
# call, or a reference to a binding bound to one.
proc emitcheck::IsCharacter {e} {
    variable hir
    if {[NativeName $e] eq "std::char::scalar_value"} {
        return 1
    }
    set b [RefBinding $e]
    if {$b ne "" && [dict get [hir::binding $hir $b] declaredBy] ne ""} {
        set bind [dict get [hir::binding $hir $b] declaredBy]
        return [IsCharacter [dict get $hir exprs $bind value]]
    }
    return 0
}

# The set of values the Int expression E can have here: the facts the
# header lists, intersected -- an exact constant; the range analysis; a
# native's result set; for a reference, what its parameter was called with
# (the summary's context), what its binding was bound to, and the path and
# guard facts on it; for `X + K`, `X - K`, `X.shift_right(K)` and `X.mod(K)`
# (K an exact constant), X's set transformed exactly.
proc emitcheck::SymbolSet {e {depth 0}} {
    variable hir
    variable facts
    variable params
    set k [hir::exact::IntOf $hir $e]
    if {$k ne ""} {
        return [list [list $k $k]]
    }
    set set [surface::dfa::Inter [RangeOf $e] [ResultSet $e]]
    if {$depth > 12} {
        return $set
    }
    set op [NativeName $e]
    if {$op in {+ - shift_right mod}} {
        lassign [dict get $hir exprs $e args] x y
        set kx [hir::exact::IntOf $hir $x]
        set ky [hir::exact::IntOf $hir $y]
        if {$ky ne "" && $kx eq ""} {
            set set [surface::dfa::Inter $set [Arith $op [SymbolSet $x [expr {$depth + 1}]] $ky]]
        } elseif {$op eq "+" && $kx ne "" && $ky eq ""} {
            set set [surface::dfa::Inter $set [Arith + [SymbolSet $y [expr {$depth + 1}]] $kx]]
        }
        return $set
    }
    set b [RefBinding $e]
    if {$b eq ""} {
        return $set
    }
    if {[dict exists $params $b]} {
        set set [surface::dfa::Inter $set [dict get $params $b]]
    }
    set bind [dict get [hir::binding $hir $b] declaredBy]
    if {$bind ne "" && [hir::typeOf $hir [dict get $hir exprs $bind value]] eq "int"} {
        # (A fact on the path here is a fact of an immutable binding: it held
        # where the binding's value was computed too.)
        set set [surface::dfa::Inter $set [SymbolSet [dict get $hir exprs $bind value] [expr {$depth + 1}]]]
    }
    foreach fact $facts {
        set set [surface::dfa::Inter $set [FactSet $b $fact]]
    }
    return $set
}

# OP (+ - shift_right mod) of every value of the interval set X with the
# constant K, as an interval set (exact for + - shift_right; mod keeps an
# interval that does not wrap, else the whole residue range).
proc emitcheck::Arith {op x k} {
    set min $::surface::dfa::MIN
    set max $::surface::dfa::MAX
    set out {}
    foreach i $x {
        lassign $i lo hi
        switch -- $op {
            + {
                set lo [expr {$lo == $min ? $min : $lo + $k}]
                set hi [expr {$hi == $max ? $max : $hi + $k}]
            }
            - {
                set lo [expr {$lo == $min ? $min : $lo - $k}]
                set hi [expr {$hi == $max ? $max : $hi - $k}]
            }
            shift_right {
                if {$k < 0 || $k > 64} {
                    return [surface::dfa::Universe]
                }
                set lo [expr {$lo == $min ? $min : $lo >> $k}]
                set hi [expr {$hi == $max ? $max : $hi >> $k}]
            }
            mod {
                if {$k <= 0} {
                    return [surface::dfa::Universe]
                }
                if {$lo != $min && $hi != $max && $hi - $lo < $k && $lo % $k <= $hi % $k} {
                    set lo [expr {$lo % $k}]
                    set hi [expr {$hi % $k}]
                } else {
                    set lo 0
                    set hi [expr {$k - 1}]
                }
            }
        }
        lappend out [list $lo $hi]
    }
    return [surface::dfa::Norm $out]
}

# What FACT ({condition C OUTCOME} or {guard B SET}) says of binding B: an
# interval set (the universe: nothing).
proc emitcheck::FactSet {b fact} {
    variable hir
    if {[lindex $fact 0] eq "guard"} {
        if {[lindex $fact 1] eq $b} {
            return [lindex $fact 2]
        }
        return [surface::dfa::Universe]
    }
    lassign $fact - condition outcome
    set out {}
    foreach path [hir::range::Paths $hir $condition $outcome] {
        set s [surface::dfa::Universe]
        foreach pair $path {
            lassign $pair c o
            set s [surface::dfa::Inter $s [PairSet $b $c $o]]
        }
        set out [surface::dfa::Union $out $s]
    }
    return $out
}

# What the comparison C evaluating to O says of binding B.
proc emitcheck::PairSet {b c o} {
    variable hir
    set op [NativeName $c]
    set all [surface::dfa::Universe]
    if {$op ni {== < <= > >=}} {
        return $all
    }
    lassign [dict get $hir exprs $c args] x y
    set kx [hir::exact::IntOf $hir $x]
    set ky [hir::exact::IntOf $hir $y]
    if {[RefBinding $x] eq $b && $ky ne ""} {
        set k $ky
    } elseif {[RefBinding $y] eq $b && $kx ne ""} {
        set k $kx
        set op [dict get {== == < > <= >= > < >= <=} $op]
    } else {
        return $all
    }
    set min $::surface::dfa::MIN
    set max $::surface::dfa::MAX
    set s [switch -- $op {
        == { list [list $k $k] }
        <  { list [list $min [expr {$k - 1}]] }
        <= { list [list $min $k] }
        >  { list [list [expr {$k + 1}] $max] }
        >= { list [list $k $max] }
    }]
    if {!$o} {
        set s [surface::dfa::Minus $all $s]
    }
    return $s
}

# 0 if the facts here prove that CONDITION cannot evaluate to OUTCOME: every
# path of it (hir::range::Paths) compares a binding with a constant in a way
# the binding's set excludes. 1 otherwise (unknown: feasible).
proc emitcheck::Feasible {condition outcome} {
    variable hir
    foreach path [hir::range::Paths $hir $condition $outcome] {
        set possible 1
        foreach pair $path {
            lassign $pair c o
            if {[NativeName $c] ni {== < <= > >=}} continue
            lassign [dict get $hir exprs $c args] x y
            foreach side [list $x $y] {
                set b [RefBinding $side]
                if {$b eq ""} continue
                if {[hir::typeOf $hir $side] ne "int"} continue
                set here [SymbolSet $side]
                if {[surface::dfa::Inter $here [PairSet $b $c $o]] eq {}} {
                    set possible 0
                }
            }
        }
        if {$possible} {
            return 1
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# The walk

proc emitcheck::Uniq {states} {
    return [lsort -unique $states]
}

# The yield at E sends the symbol set X from the states S: the states after
# it; the violations as diagnostics.
proc emitcheck::Emit {s x e target alphabet character} {
    variable END
    variable visited
    lappend visited {*}$s
    if {$character && $alphabet eq "bytes" && [surface::dfa::Inter $x {{128 1114111}}] ne {}} {
        Diag EMIT-BYTE-CHARACTER $e \
            "this yield may send the scalar value of a non-ASCII character to [KeyText $target], a recognizer over bytes: a character is not a byte (send its UTF-8 bytes)"
    }
    if {[llength [surface::dfa::Inter $x [list [list $END $END]]]]} {
        Diag EMIT-END-SYMBOL $e \
            "this yield may send -1, which is the end of the input in the recognizer protocol, never a symbol: an emitter ends its token by completing"
        set x [surface::dfa::Minus $x [list [list $END $END]]]
    }
    set out {}
    foreach c $s {
        foreach r [Step $c $x] {
            lassign $r y result
            if {[lindex $result 0] ne "violation"} {
                lappend out $result
                continue
            }
            lassign $result - kind key q n
            switch -- $kind {
                reject {
                    Diag EMIT-REJECTED $e "this yield may send symbols no transition takes" $c $y $alphabet
                }
                beyond {
                    Diag EMIT-BEYOND-TOKEN $e "this yield may send a symbol the [KeyText $target] token ends before (\"accept before\"), which would begin the next token" $c $y $alphabet
                }
                after {
                    Diag EMIT-AFTER-TOKEN $e "this yield may send a symbol after the [KeyText $target] token is complete" done $y $alphabet
                }
                lookahead {
                    Diag EMIT-REJECTED $e "this yield reaches a completion leaving $n symbols unread, which emission does not model" $c $y $alphabet
                }
                boundary {
                    # (KEY the token's recognizer, Q the helper, N its call.)
                    Diag EMIT-BOUNDARY $e "this yield may send a symbol that continues the [KeyText $key] token $q emitted (called at [Location $n]), which claims to emit that token whole: the token would absorb it" [lrange $c 0 2] $y $alphabet
                }
            }
        }
    }
    return [Uniq $out]
}

# The states S complete normally at E: every one must accept at the end.
proc emitcheck::Finish {s e target} {
    variable END
    variable models
    foreach c $s {
        if {$c eq "done"} {
            continue
        }
        foreach r [Step $c [list [list $END $END]]] {
            lassign $r y result
            if {$result eq "done"} {
                continue
            }
            lassign $result - kind key q n
            lassign [Expected $c] takes completes
            set needs [surface::dfa::Union $takes $completes]
            if {$kind eq "beyond"} {
                Diag EMIT-INCOMPLETE $e "this emitter may complete where [KeyText $target]'s token ends before its last symbols (they would not be part of it)" $c $needs [dict get $models $key alphabet]
            } else {
                Diag EMIT-INCOMPLETE $e "this emitter may complete with its [KeyText $target] token incomplete, where the end of the input is rejected (the state needs one of the symbols shown)" $c $needs [dict get $models $key alphabet]
            }
        }
    }
}

proc emitcheck::Kind {e} {
    variable hir
    return [dict get $hir exprs $e kind]
}

# The states after the sequence BODY from S (its facts scoped to it).
proc emitcheck::EvalBody {body s} {
    variable facts
    set saved $facts
    foreach e $body {
        set s [Eval $e $s]
        if {$s eq {}} {
            break
        }
    }
    set facts $saved
    return $s
}

# The states after expression E from the states S: {} when E cannot
# complete normally (or S is empty).
proc emitcheck::Eval {e s} {
    variable hir
    variable returns
    variable breaks
    variable continues
    variable visited
    variable facts
    variable block
    if {$s eq {}} {
        return {}
    }
    set node [dict get $hir exprs $e]
    if {![dict get $node reachable]} {
        return {}
    }
    switch -- [dict get $node kind] {
        const - ref - block {
            return $s
        }
        bind - ok - error {
            return [Eval [dict get $node value] $s]
        }
        return {
            set s [Eval [dict get $node value] $s]
            dict lappend returns $block {*}$s
            return {}
        }
        break {
            if {[dict get $node value] ne ""} {
                set s [Eval [dict get $node value] $s]
            }
            dict lappend breaks [dict get $node target] {*}$s
            return {}
        }
        continue {
            dict lappend continues [dict get $node target] {*}$s
            return {}
        }
        fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                Eval [dict get $node value] $s
            }
            return {}
        }
        struct {
            foreach f [dict get $node fields] {
                set s [Eval $f $s]
            }
            return $s
        }
        project {
            return [Eval [dict get $node receiver] $s]
        }
        call {
            return [EvalCall $e $node $s]
        }
        if {
            set s [Eval [dict get $node condition] $s]
            if {$s eq {}} {
                return {}
            }
            set cond [dict get $node condition]
            set saved $facts
            set t {}
            set f {}
            if {[Feasible $cond 1]} {
                lappend facts [list condition $cond 1]
                set t [EvalBody [dict get $node thenBody] $s]
                set facts $saved
            }
            if {[Feasible $cond 0]} {
                lappend facts [list condition $cond 0]
                set f [EvalBody [dict get $node elseBody] $s]
                set facts $saved
            }
            # A branch that cannot complete leaves its negation behind.
            if {$t eq {} && $f ne {}} {
                lappend facts [list condition $cond 0]
            } elseif {$f eq {} && $t ne {}} {
                lappend facts [list condition $cond 1]
            }
            return [Uniq [concat $t $f]]
        }
        loop - listloop - countloop - lockloop {
            return [EvalLoop $e $node $s]
        }
        handle {
            set saved $visited
            set visited {}
            set savedFacts $facts
            set after [Eval [dict get $node call] $s]
            set inside [Uniq [concat $s $visited]]
            set afterFacts $facts
            set facts $savedFacts
            set visited [concat $saved $inside]
            set out $after
            set handled 0
            foreach body [dict get $node handlerBodies] {
                set h [EvalBody $body $inside]
                if {$h ne {}} {
                    set handled 1
                }
                lappend out {*}$h
            }
            if {!$handled} {
                set facts $afterFacts
            }
            return [Uniq $out]
        }
    }
    error "emitcheck: unexpected expression kind [dict get $node kind] at [Location $e]"
}

proc emitcheck::EvalLoop {e node s} {
    variable breaks
    variable continues
    switch -- [dict get $node kind] {
        listloop { set s [Eval [dict get $node iterable] $s] }
        countloop {
            set s [Eval [dict get $node start] $s]
            set s [Eval [dict get $node end] $s]
        }
        lockloop {
            foreach operand [hir::loopOperands $node] {
                set s [Eval $operand $s]
            }
        }
    }
    if {$s eq {}} {
        return {}
    }
    variable facts
    set saved $facts
    # A counting domain with an exact start is peeled: its first iteration
    # has the count at the start, every later one past it (`if i > 0:` a
    # separator, then a value -- the idiom of every list printer).
    lassign [Peel $node] counter first later
    set out {}
    dict set breaks $e {}
    dict set continues $e {}
    set head $s
    if {$counter ne ""} {
        lappend facts [list guard $counter $first]
        set after [EvalBody [dict get $node body] $s]
        set facts $saved
        set head [Uniq [concat $after [dict get $continues $e]]]
        set out [dict get $breaks $e]
        lappend out {*}$s
        lappend facts [list guard $counter $later]
    }
    if {$head ne {}} {
        while 1 {
            dict set continues $e {}
            set after [EvalBody [dict get $node body] $head]
            set next [Uniq [concat $head $after [dict get $continues $e]]]
            if {$next eq $head} {
                break
            }
            set head $next
        }
    }
    set facts $saved
    lappend out {*}[dict get $breaks $e]
    if {[dict get $node kind] ne "loop"} {
        # A counted, collection or lockstep loop also ends by running out.
        lappend out {*}$head
    }
    return [Uniq $out]
}

# {COUNTER FIRST LATER} for a loop NODE whose counting domain starts at an
# exact Int: its binding, the set of its first iteration, of every later
# one; {"" "" ""} otherwise.
proc emitcheck::Peel {node} {
    variable hir
    set min $::surface::dfa::MIN
    set max $::surface::dfa::MAX
    set domain ""
    switch -- [dict get $node kind] {
        countloop {
            set domain [dict create binding [dict get $node countBinding] start [dict get $node start] \
                direction [dict get $node direction]]
        }
        lockloop {
            foreach d [dict get $node domains] {
                if {[dict get $d kind] eq "count"} {
                    set domain $d
                    break
                }
            }
        }
    }
    if {$domain eq ""} {
        return {"" "" ""}
    }
    set k [hir::exact::IntOf $hir [dict get $domain start]]
    if {$k eq ""} {
        return {"" "" ""}
    }
    if {[dict get $domain direction] eq "up"} {
        return [list [dict get $domain binding] [list [list $k $k]] [list [list [expr {$k + 1}] $max]]]
    }
    return [list [dict get $domain binding] [list [list $k $k]] [list [list $min [expr {$k - 1}]]]]
}

# A call: its callee and arguments in order, then a yield, a guard or a
# call of a function that may yield.
proc emitcheck::EvalCall {e node s} {
    variable hir
    variable guards
    variable facts
    variable target
    set s [Eval [dict get $node callee] $s]
    foreach a [dict get $node args] {
        set s [Eval $a $s]
    }
    if {$s eq {}} {
        return {}
    }
    if {[hir::typeOf $hir $e] eq "never"} {
        return {}
    }
    lassign [dict get $node target] tk t
    if {$tk eq "native" && [dict get [hir::symbol $hir $t] name] eq [core::coroutines::yieldNative]} {
        set value [lindex [dict get $node args] 0]
        variable models
        set alphabet [dict get $models $target alphabet]
        if {[hir::typeOf $hir $value] ne "int"} {
            Diag EMIT-NOT-SYMBOL $e \
                "this yield sends a [hir::types::show [hir::typeOf $hir $value]], not an Int: an emitter's yields are the symbols of [KeyText $target]"
            return {}
        }
        return [Emit $s [SymbolSet $value] $e $target $alphabet [IsCharacter $value]]
    }
    if {$tk eq "block"} {
        if {[dict exists $guards $t]} {
            set arg [lindex [dict get $node args] 0]
            set b [RefBinding $arg]
            if {$b ne ""} {
                lappend facts [list guard $b [dict get $guards $t]]
            }
            return $s
        }
        if {[hir::coroutines::MayYield $hir $t]} {
            set sets {}
            foreach a [dict get $node args] {
                lappend sets [if {[hir::typeOf $hir $a] eq "int"} {SymbolSet $a} else {string cat ""}]
            }
            variable callExpr $e
            return [Apply $t $s $sets]
        }
    }
    return $s
}

# The states after a call of the function (block) B that may yield, from S,
# its Int arguments' sets SETS ("" for an argument of another type).
proc emitcheck::Apply {b s sets} {
    variable visited
    variable contexts
    # Past a bound on the contexts of one function, its arguments' sets
    # are dropped (always sound: fewer facts).
    if {[dict size [dict getdef $contexts $b {}]] > 64} {
        set sets [lmap x $sets {string cat ""}]
    }
    dict set contexts $b $sets 1
    variable claims
    variable callExpr
    # (Taken now: the summaries below analyze calls of their own.)
    set call $callExpr
    set out {}
    foreach c $s {
        lassign [Summary $b $c $sets] exits seen
        lappend visited {*}$seen
        foreach x $exits {
            # A helper that claims to emit a token whole leaves its token's
            # boundary to the next symbol (FrameDepth: the claim's recognizer
            # entered by the helper and still open).
            foreach key [dict getdef $claims $b {}] {
                set d [FrameDepth $x $key]
                if {$d >= 0 && [FrameDepth $c $key] < 0} {
                    set x [list {*}[lrange $x 0 2] [list $d [dict get $claims $b,name] $call]]
                    break
                }
            }
            lappend out $x
        }
    }
    return [Uniq $out]
}

# {EXITS VISITED} of block B entered in composite C, its Int parameters
# called with SETS: the states its normal completions leave, and every state
# it passes through; recomputed once per round (a call of a block in
# progress reads the previous round's value).
proc emitcheck::Summary {b c sets} {
    variable hir
    variable summaries
    variable round
    variable changed
    variable returns
    variable breaks
    variable continues
    variable visited
    variable facts
    variable block
    variable params
    set key [list $b $c $sets]
    if {[dict exists $summaries $key] && [lindex [dict get $summaries $key] 0] == $round} {
        return [lrange [dict get $summaries $key] 1 2]
    }
    set old [if {[dict exists $summaries $key]} {lrange [dict get $summaries $key] 1 2} else {list {} {}}]
    dict set summaries $key [list $round {*}$old]
    set saved [list $returns $breaks $continues $visited $facts $block $params]
    set returns [dict create]
    set breaks [dict create]
    set continues [dict create]
    set visited {}
    set facts {}
    set block $b
    set params [dict create]
    foreach p [dict get $hir exprs $b params] x $sets {
        if {$x ne ""} {
            dict set params $p $x
        }
    }
    set out [EvalBody [dict get $hir exprs $b body] [list $c]]
    set exits [Uniq [concat $out [dict getdef $returns $b {}]]]
    set seen [Uniq [concat [list $c] $visited]]
    lassign $saved returns breaks continues visited facts block params
    if {[list $exits $seen] ne $old} {
        set changed 1
    }
    dict set summaries $key [list $round $exits $seen]
    return [list $exits $seen]
}

# ---------------------------------------------------------------------------
# The program

# {LINE NAME RECOGNIZER} of every directive in PATH's text.
proc emitcheck::Directives {path} {
    set out {}
    set lines [split [core::ReadFile $path] \n]
    for {set i 0} {$i < [llength $lines]} {incr i} {
        if {![regexp {^\s*#:\s*emits\s+(\S+)\s*$} [lindex $lines $i] -> recognizer]} {
            continue
        }
        # (Several directives may precede one function: each is a claim.)
        for {set j [expr {$i + 1}]} {$j < [llength $lines]} {incr j} {
            set line [lindex $lines $j]
            if {[regexp {^\s*#} $line]} continue
            if {[regexp {^\s*(?:private\s+)?(?:nomethod\s+)?fn\s+([A-Za-z_][A-Za-z0-9_?]*)} $line -> name]} {
                lappend out [list [expr {$j + 1}] $name $recognizer]
            }
            break
        }
    }
    return $out
}

# The recognizer key {NS NAME} the text NAME denotes, written in the file of
# namespace OWN, or "".
proc emitcheck::RecognizerKey {name own} {
    variable models
    if {[string first :: $name] >= 0} {
        set key [list [namespace qualifiers $name] [namespace tail $name]]
    } else {
        set key [list $own $name]
    }
    if {[dict exists $models $key]} {
        return $key
    }
    return ""
}

# Checks the program at PATH. Options: -emits {FN RECOGNIZER ...} (FN the
# function's name as written in the entry program, or NS::FN).
proc emitcheck::check {path args} {
    variable hir
    variable ranges
    variable instancesOf
    variable models
    variable guards
    variable summaries
    variable round
    variable changed
    variable diagnostics
    variable returns
    variable breaks
    variable continues
    variable visited
    variable facts
    variable block
    variable target
    variable contexts
    variable params
    variable checking
    set params [dict create]
    set options [dict merge {-emits {}} $args]
    set path [file normalize $path]
    set models [Models $path]
    set hir [surface::readProgramFile $path -warnings off]
    hir::activate $hir
    set spec [hir::specialize::analyze $hir -call-facts-opt 1]
    set ranges [hir::range::analyze $hir $spec 1 1 1 1 ""]
    set instancesOf [dict create]
    foreach id [dict get $spec used] {
        dict lappend instancesOf [dict get [hir::specialize::instance $spec $id] block] $id
    }
    # The functions: bind nodes of blocks, by source file and line, and by
    # name; the recognizers' own functions, by key.
    set byLine [dict create]
    set byName [dict create]
    set recognizerBlocks [dict create]
    set files [dict create]
    dict for {f entry} [dict get $hir files] {
        dict set files $f [file normalize [dict get $entry path]]
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "bind"} continue
        set v [dict get $node value]
        if {[dict get $hir exprs $v kind] ne "block"} continue
        set name [dict get [hir::binding $hir [dict get $node binding]] name]
        dict set byName $name $v
        set origin [dict get $node origin]
        if {[lindex $origin 0] eq "file"} {
            set file [dict get $files [lindex $origin 1]]
            dict set byLine [list $file [dict get [lrange $origin 2 end] line]] [list $v $name]
        }
    }
    dict for {key model} $models {
        set q [KeyText $key]
        if {[dict exists $byName $q]} {
            dict set recognizerBlocks $key [dict get $byName $q]
        }
    }
    # Guards: the recognizers none of whose transitions suspends, by block:
    # the symbols they complete on (one symbol, nothing unread).
    set guards [dict create]
    dict for {key b} $recognizerBlocks {
        if {[hir::coroutines::MayYield $hir $b]} continue
        set accepted {}
        foreach r [Step [Initial $key] [surface::dfa::Minus [surface::dfa::Universe] {{-1 -1}}]] {
            if {[lindex $r 1] eq "done"} {
                set accepted [surface::dfa::Union $accepted [lindex $r 0]]
            }
        }
        dict set guards $b $accepted
    }
    # The emitters: directives, then -emits.
    set emitters {}
    set diagnostics [dict create]
    dict for {ns file} [ApplicationFiles $path] {
        foreach d [Directives $file] {
            lassign $d line name recognizer
            set fileKey [list [file normalize $file] $line]
            if {![dict exists $byLine $fileKey]} {
                error "emitcheck: no function $name at $file:$line"
            }
            lassign [dict get $byLine $fileKey] b -
            set key [RecognizerKey $recognizer $ns]
            lappend emitters [list $b $recognizer $key "$file:$line" $name]
        }
    }
    foreach {fn recognizer} [dict get $options -emits] {
        if {![dict exists $byName $fn]} {
            error "emitcheck: no function $fn"
        }
        set b [dict get $byName $fn]
        lappend emitters [list $b $recognizer [RecognizerKey $recognizer [namespace qualifiers $fn]] "" $fn]
    }
    # Coroutine roots: what a thunk's body calls last.
    set roots [dict create]
    foreach thunk [hir::coroutines::thunks $hir] {
        set last [lindex [dict get $hir exprs $thunk body] end]
        if {$last ne "" && [dict get $hir exprs $last kind] eq "call"} {
            lassign [dict get $hir exprs $last target] tk t
            if {$tk eq "block"} {
                dict set roots $t 1
            }
        }
    }
    # Each function's claims: the recognizers its directives name.
    variable claims [dict create]
    foreach em $emitters {
        lassign $em b - key - name
        if {$key ne ""} {
            dict lappend claims $b $key
            dict set claims $b,name $name
        }
    }
    set out {}
    set results {}
    foreach em $emitters {
        lassign $em b recognizer key where name
        set checking ""
        if {$key eq ""} {
            Diag EMIT-UNKNOWN-RECOGNIZER $b "$name is declared to emit $recognizer, which is no declared recognizer"
            continue
        }
        if {![dict exists $instancesOf $b]} {
            Diag EMIT-UNUSED $b "$name is not called by the program, so the compiler proves nothing of its values: check it with a program that calls it"
            continue
        }
        set target $key
        set checking [list $name [KeyText $key] [Location $b]]
        set summaries [dict create]
        set round 0
        set earlier $diagnostics
        while 1 {
            # Every round recomputes every summary from the last round's
            # values; the last round, which changed none, holds every
            # diagnostic (one of an earlier round may not hold any more).
            incr round
            set changed 0
            set diagnostics [dict create]
            set returns [dict create]
            set breaks [dict create]
            set continues [dict create]
            set visited {}
            set facts {}
            set block ""
            set contexts [dict create]
            lassign [Summary $b [Initial $key] [lmap p [dict get $hir exprs $b params] {string cat ""}]] exits seen
            if {!$changed} {
                break
            }
        }
        set diagnostics [dict merge $earlier $diagnostics]
        # The completion: the end from every exit, reported at the
        # function's declaration.
        Finish $exits $b $key
        set exits [lmap c $exits {if {$c eq "done"} continue; set c}]
        set terminal ""
        if {[dict exists $roots $b]} {
            set ids [dict getdef $instancesOf $b {}]
            set result {}
            foreach id $ids {
                set result [surface::dfa::Union $result [RangeSet [dict get $ranges instances $id result]]]
            }
            if {$result ne {{-1 -1}}} {
                Diag EMIT-TERMINAL-VALUE $b "$name is the root of a coroutine and its final value may be [SetText $result unicode], not -1: its stable terminal value would read as a symbol to a consumer that reads values after the end (complete with -1, the end)"
            }
            set terminal -1
        }
        lappend results [dict create name $name recognizer [KeyText $key] location [Location $b] \
            follows [Follows $exits] summaries [dict size $summaries] root [dict exists $roots $b]]
    }
    set diags [lsort -command emitcheck::ByLocation [lmap d [dict values $diagnostics] {Message $d}]]
    return [dict create diagnostics $diags emitters $results]
}

proc emitcheck::ByLocation {a b} {
    set la [split [dict get $a location] :]
    set lb [split [dict get $b location] :]
    set c [string compare [lindex $la 0] [lindex $lb 0]]
    if {$c != 0} {
        return $c
    }
    foreach i {1 2} {
        set d [expr {[lindex $la $i] - [lindex $lb $i]}]
        if {$d != 0} {
            return [expr {$d < 0 ? -1 : 1}]
        }
    }
    return [string compare [dict get $a kind] [dict get $b kind]]
}

# The boundary of the token the exit states EXITS complete: the symbols
# that may follow it (the token ends before them) in every exit, and
# whether the end may: text for the summary.
proc emitcheck::Follows {exits} {
    if {$exits eq {}} {
        return "nothing (the token completes on its own last symbol)"
    }
    set follow [surface::dfa::Minus [surface::dfa::Universe] {{-1 -1}}]
    foreach c $exits {
        set here {}
        foreach r [Step $c $follow] {
            lassign $r y result
            if {[lindex $result 0] eq "violation" && [lindex $result 1] eq "beyond" && [lindex $result 4] == 1} {
                set here [surface::dfa::Union $here $y]
            }
        }
        set follow [surface::dfa::Inter $follow $here]
    }
    variable models
    set key [lindex $exits 0 1]
    if {$follow eq {}} {
        return "the end only"
    }
    return "the end, or [surface::dfa::SetText $follow [dict get $models $key alphabet] 12]"
}

proc emitcheck::Format {result} {
    set out {}
    foreach d [dict get $result diagnostics] {
        append out "[dict get $d location]: [dict get $d message] (EMIT [dict get $d kind])\n"
        foreach r [dict get $d related] {
            append out "    [lindex $r 1]: note: [lindex $r 0]\n"
        }
    }
    foreach s [dict get $result emitters] {
        append out "emitter [dict get $s name] ([dict get $s location]) emits [dict get $s recognizer]: after it, [dict get $s follows][expr {[dict get $s root] ? "; a coroutine root" : ""}]\n"
    }
    return $out
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    set path ""
    set emits {}
    for {set i 0} {$i < [llength $argv]} {incr i} {
        set a [lindex $argv $i]
        if {$a eq "-emits"} {
            incr i
            lassign [split [lindex $argv $i] =] fn r
            lappend emits $fn $r
        } else {
            set path $a
        }
    }
    if {$path eq ""} {
        puts stderr "usage: tclsh9.0 audit/emitter/tools/emitcheck.tcl PROGRAM.bot ?-emits FN=RECOGNIZER ...?"
        exit 2
    }
    interp recursionlimit {} 100000
    set result [emitcheck::check $path -emits $emits]
    puts -nonewline [emitcheck::Format $result]
    exit [expr {[llength [dict get $result diagnostics]] ? 1 : 0}]
}
