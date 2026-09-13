# value.tcl -- runtime value representation.
#
# Every runtime value is a tagged Tcl list whose first element names its kind.
# The tag is deliberate: Tcl's "everything is a string" must not leak into the
# language, so the integer 10, the string "10" and the Boolean true are
# distinct values.
#
#   {int DIGITS}              arbitrary-precision integer, canonical decimal
#   {str TEXT}                string
#   {bool true|false}         Boolean
#   {unit}                    the unit value
#   {list ITEMS}              ITEMS is a Tcl list of runtime values
#   {result ok|error VALUE}   Result
#   {block PARAMS BODY ENV}   Block: parameters, body expressions, captured env
#   {native NAME}             native callable; metadata lives in the registry
#
# Values are treated as immutable. Code outside this file should construct and
# inspect values only through these procedures.

namespace eval core::value {
    variable kinds {int str bool unit list result block native}
}

proc core::value::isCanonicalInt {text} {
    regexp {^(?:0|-?[1-9][0-9]*)$} $text
}

# ---------------------------------------------------------------------------
# Constructors

proc core::value::int {digits} {
    if {![isCanonicalInt $digits]} {
        error "core::value::int: not a canonical integer: \"$digits\""
    }
    return [list int $digits]
}

proc core::value::str {text} {
    return [list str $text]
}

# The single point where a host (Tcl) truth value becomes a language Boolean.
# Only exactly 0 or 1 is accepted; no Tcl truthiness rules apply.
proc core::value::bool {flag} {
    if {$flag eq "1"} { return {bool true} }
    if {$flag eq "0"} { return {bool false} }
    error "core::value::bool: expected 0 or 1, got \"$flag\""
}

proc core::value::true {} { return {bool true} }
proc core::value::false {} { return {bool false} }
proc core::value::unit {} { return {unit} }

proc core::value::listOf {items} {
    foreach item $items { check $item }
    return [list list $items]
}

proc core::value::ok {payload} {
    return [list result ok [check $payload]]
}

proc core::value::err {payload} {
    return [list result error [check $payload]]
}

proc core::value::block {params body env} {
    return [list block $params $body $env]
}

proc core::value::native {name} {
    return [list native $name]
}

# ---------------------------------------------------------------------------
# Inspection

proc core::value::kind {v} {
    variable kinds
    if {[catch {llength $v} length] || $length == 0 || [lindex $v 0] ni $kinds} {
        error "core::value: not a runtime value: \"$v\""
    }
    return [lindex $v 0]
}

proc core::value::check {v} {
    kind $v
    return $v
}

# Implementation-level accessor guard: a mismatch here is an evaluator bug.
proc core::value::Require {kind v} {
    if {[kind $v] ne $kind} {
        error "core::value: expected $kind value, got \"$v\""
    }
}

# Language-level guard for primitives: a mismatch is an invalid program.
proc core::value::expect {kind v context} {
    if {[kind $v] ne $kind} {
        core::semanticError TYPE "$context: expected $kind, got [show $v]"
    }
    return $v
}

proc core::value::intOf {v}  { Require int $v;  return [lindex $v 1] }
proc core::value::strOf {v}  { Require str $v;  return [lindex $v 1] }
proc core::value::items {v}  { Require list $v; return [lindex $v 1] }

# Returns host 1/0 for a language Boolean.
proc core::value::isTrue {v} {
    Require bool $v
    return [expr {[lindex $v 1] eq "true"}]
}

proc core::value::resultTag {v}     { Require result $v; return [lindex $v 1] }
proc core::value::resultPayload {v} { Require result $v; return [lindex $v 2] }

proc core::value::blockParams {v} { Require block $v; return [lindex $v 1] }
proc core::value::blockBody {v}   { Require block $v; return [lindex $v 2] }
proc core::value::blockEnv {v}    { Require block $v; return [lindex $v 3] }

proc core::value::nativeName {v}  { Require native $v; return [lindex $v 1] }

# ---------------------------------------------------------------------------
# Equality: approximation of the future language's ==.
#
# Values of different kinds are never equal. Integers compare numerically,
# strings by exact characters, lists element-wise, Results by tag and payload.
# Equality of callables would require identity semantics, which are out of
# scope, so comparing a callable is an invalid program.
# Returns host 1/0.

proc core::value::equal {a b} {
    set ka [kind $a]
    set kb [kind $b]
    if {$ka in {block native} || $kb in {block native}} {
        core::semanticError EQUALITY \
            "== is not defined for callables: [show $a] == [show $b]"
    }
    if {$ka ne $kb} {
        return 0
    }
    switch -- $ka {
        int - str - bool {
            # Integers are canonical, so textual identity is numeric equality.
            return [string equal [lindex $a 1] [lindex $b 1]]
        }
        unit {
            return 1
        }
        list {
            set xs [lindex $a 1]
            set ys [lindex $b 1]
            if {[llength $xs] != [llength $ys]} {
                return 0
            }
            foreach x $xs y $ys {
                if {![equal $x $y]} {
                    return 0
                }
            }
            return 1
        }
        result {
            return [expr {[lindex $a 1] eq [lindex $b 1]
                          && [equal [lindex $a 2] [lindex $b 2]]}]
        }
    }
}

# ---------------------------------------------------------------------------
# Display: unambiguous human-readable rendering.

proc core::value::show {v} {
    switch -- [kind $v] {
        int  { return [lindex $v 1] }
        str  {
            set escaped [string map {\\ \\\\ \" \\\" \n \\n \t \\t} [lindex $v 1]]
            return "\"$escaped\""
        }
        bool { return [lindex $v 1] }
        unit { return unit }
        list {
            set parts {}
            foreach item [lindex $v 1] {
                lappend parts [show $item]
            }
            return "\[[join $parts {, }]\]"
        }
        result { return "[lindex $v 1]([show [lindex $v 2]])" }
        block  { return "<block ([join [lindex $v 1] { }])>" }
        native { return "<native [lindex $v 1]>" }
    }
}
