# dfa.tcl -- the transition function of a declared recognizer
# (DFA-COROUTINE-MILESTONE-2.md).
#
#   dfa#transition(ROW, KEY, TABLE)   the code TABLE assigns KEY in row ROW
#
# The compact form surface/dfa.tcl lowers a recognizer's whole transition
# table to: one call, whose operands are the recognizer's state number, the
# symbol it was handed and the table, a String constant the compiler wrote.
# It computes nothing a recognizer did not declare: a pure, total function
# of two Ints, no error, no allocation natively (native/lower.tcl expands a
# call into a multiway branch or a table load over its constant table). It is
# an internal root native: no source can name it.
#
# TABLE is a Tcl list of rows, one per state number 0..R-1; a row is
#
#   {DEFAULT {LO...} {HI...} {CODE...}}
#
# the sorted, disjoint, closed intervals LO_i..HI_i of the keys the row maps
# to CODE_i, every other key (the end of the input -1 included, when no
# interval holds it) to DEFAULT. Codes are nonnegative Ints whose meaning is
# the generated recognizer's (surface/dfa.tcl's Codes). A row outside
# 0..R-1 is the compiler's error: a generated recognizer never computes one.

namespace eval core::dfa {}

# The code of KEY in row ROW of TABLE (the text above), KEY and ROW Tcl
# integers.
proc core::dfa::Lookup {table row key} {
    if {$row < 0 || $row >= [llength $table]} {
        error "dfa#transition: state $row is no row of the table ([llength $table] rows)"
    }
    lassign [lindex $table $row] default lows highs codes
    # Every bound a table holds is a symbol or the end (-1..0x10FFFF): a key
    # beyond them, a bignum included, is one no interval holds.
    if {$key < -2} {
        set key -2
    } elseif {$key > 0x110000} {
        set key 0x110000
    }
    set i [lsearch -sorted -integer -bisect $lows $key]
    if {$i >= 0 && $key <= [lindex $highs $i]} {
        return [lindex $codes $i]
    }
    return $default
}

proc core::dfa::transition {row key table} {
    set r [core::value::intOf [core::value::expect int $row dfa#transition]]
    set k [core::value::intOf [core::value::expect int $key dfa#transition]]
    return [core::value::int [Lookup [core::value::strOf [core::value::expect str $table dfa#transition]] $r $k]]
}

# The decided call of exactly known arguments (core/native.tcl's -fold).
proc core::dfa::Fold {row key table} {
    if {[catch {transition $row $key $table} value]} {
        return ""
    }
    return [list value $value]
}

# Every code is a state number or an outcome's number, both nonnegative
# (-result-range: the range analysis proves a state from it, and native
# lowering then checks none).
core::native::register dfa#transition -arity 3 -impl core::dfa::transition \
    -param-types {int int str} -result-type int -result-range nonneg -context-free 1 \
    -ownership {observe observe observe} -fold core::dfa::Fold

# ---------------------------------------------------------------------------
# The outcomes of a code (EMISSION-CLAIMS-MILESTONE-1.md, "One DFA outcome
# model")
#
# What each code of a recognizer's table means, stated once for both of its
# consumers: surface/dfa.tcl's Lower, which generates a recognizer's
# ordinary coroutine functions from it (one symbol at a time), and the
# emission checker (hir/emission.tcl), which steps it over sets of symbols.
# The table (surface::dfa::Codes) maps every state number and every Int to a
# code; a code below the number of states consumes the symbol and continues
# in that state; every other code stands for a *leaf*:
#
#   taken          complete, every symbol supplied taken
#   returnc        complete, the current symbol -- or the end -- unread
#   {more K}       complete, the last K symbols supplied unread
#   {call KEY THEN}  run recognizer KEY from its start on the current
#                  symbol; its completion is then resumed by THEN (Resume)
#   {reject R S}   fail: std::dfa::UnrecognizedInput, or
#                  std::dfa::UnexpectedEnd at the end (recognizer R, state S)
#
# A completion has a *class*: taken, current (returnc) or {more K}. A
# recognizer's run function (NAME#run) returns its class as an Int
# (RunResult), the protocol between a caller and its callee; a recognizer
# function returns the number of symbols it leaves unread (Unread).

# The outcome of LEAF (a code's leaf in surface::dfa::Codes, or {state N}
# for a state number): {consume N}, {complete CLASS}, {call KEY THEN} or
# {reject R S}.
proc core::dfa::Outcome {leaf} {
    switch -- [lindex $leaf 0] {
        state   { return [list consume [lindex $leaf 1]] }
        taken   { return {complete taken} }
        returnc { return {complete current} }
        more    { return [list complete [list more [lindex $leaf 1]]] }
        call    { return [list call [lindex $leaf 1] [lindex $leaf 2]] }
        reject  { return [list reject [lindex $leaf 1] [lindex $leaf 2]] }
    }
    error "core::dfa::Outcome: no leaf \"$leaf\""
}

# The run function's result of a completion of CLASS: -2 (taken), `c` (the
# current symbol, or -1 at the end: what a caller can reconsider), or
# -2 - K ({more K}: what only `then accept` passes on).
proc core::dfa::RunResult {class} {
    switch -- [lindex $class 0] {
        taken   { return -2 }
        current { return c }
        more    { return [expr {-2 - [lindex $class 1]}] }
    }
    error "core::dfa::RunResult: no completion class \"$class\""
}

# The class a run function's result R (an Int) stands for: RunResult's
# inverse.
proc core::dfa::ClassOf {r} {
    if {$r == -2} { return taken }
    if {$r >= -1} { return current }
    return [list more [expr {-2 - $r}]]
}

# What a caller does when the recognizer it called with `then THEN`
# completes with CLASS:
#
#   propagate      THEN is accept: the caller completes with the callee's
#                  completion, unchanged
#   {wait THEN}    taken: continue in THEN, which waits for the next symbol
#   {reconsider THEN}  current: THEN runs at once on the symbol (or the end)
#                  the callee left
#   reject         {more K}: no row holds -2 - K, so THEN's default -- a
#                  rejection -- takes it (surface/dfa.tcl's
#                  DFA-CALL-LOOKAHEAD rejects every recognizer where this
#                  could run)
proc core::dfa::Resume {then class} {
    if {$then eq "accept"} {
        return propagate
    }
    switch -- [lindex $class 0] {
        taken   { return [list wait $then] }
        current { return [list reconsider $then] }
        more    { return reject }
    }
    error "core::dfa::Resume: no completion class \"$class\""
}

# The number of symbols the outermost recognizer leaves unread when it
# completes with CLASS, AT-END 1 when it completed on the end of the input
# (which is never counted): the recognizer function's result, decoded from
# its run function's (`r >= 0` is 1, `r < -2` is -2 - r, -2 and -1 are 0).
proc core::dfa::Unread {class atEnd} {
    switch -- [lindex $class 0] {
        taken   { return 0 }
        current { if {$atEnd} { return 0 } else { return 1 } }
        more    { return [lindex $class 1] }
    }
    error "core::dfa::Unread: no completion class \"$class\""
}

# ---------------------------------------------------------------------------
# Messages

# The hull of the symbols of ALPHABET (bytes, ascii, unicode).
proc core::dfa::AlphabetHull {alphabet} {
    return [dict get {ascii {0 127} bytes {0 255} unicode {0 1114111}} $alphabet]
}

# How symbol S of ALPHABET is shown in a message (the end, -1, as `end`).
proc core::dfa::SymbolText {s alphabet} {
    if {$s == -1} {
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
