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
