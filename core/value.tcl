# value.tcl -- runtime value representation.
#
# Every runtime value is a tagged Tcl list whose first element names its kind.
# The tag is deliberate: Tcl's "everything is a string" must not leak into the
# language, so the integer 10, the string "10" and the Boolean true are
# distinct values.
#
#   {int DIGITS}              arbitrary-precision integer, canonical decimal
#   {str TEXT ?EVIDENCE?}     string; EVIDENCE is a sorted, non-empty list of
#                             named types the string is proven to satisfy
#                             (see type.tcl). Evidence is knowledge *about*
#                             the string, not part of it: equality, eq and
#                             display ignore it.
#   {bool true|false}         Boolean
#   {unit}                    the unit value
#   {list ITEMS}              ITEMS is a Tcl list of runtime values
#   {result ok|error VALUE}   Result
#   {block PARAMS BODY ENV CODE}
#                             Block: parameters, body expressions (IR),
#                             captured env, and the compiled code for the
#                             body ("" when the body is to be interpreted)
#   {native NAME}             native callable; metadata lives in the registry
#   {mutarray ID}             MutableArray handle; ID indexes
#                             core::mutarray's mutable store (mutarray.tcl).
#                             The only value kind that is NOT treated as
#                             immutable: two {mutarray ID} values with the
#                             same ID are the same storage, and mutating one
#                             is observable through the other.
#
# Values other than {mutarray ID} are treated as immutable. Code outside this
# file should construct and inspect values only through these procedures.

namespace eval core::value {
    variable kinds {int str bool unit list result block native mutarray}
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

# ---------------------------------------------------------------------------
# Evidence

# The named types V carries evidence for (a sorted list, possibly empty).
proc core::value::evidence {v} {
    if {[kind $v] eq "str" && [llength $v] == 3} {
        return [lindex $v 2]
    }
    return {}
}

proc core::value::hasEvidence {v name} {
    return [expr {$name in [evidence $v]}]
}

# V with added evidence for every named type in TYPE (a named type or a
# refined type). Only trusted Tcl code calls this. For validator types the
# validator must accept V; opaque types are taken on the caller's word, which
# is what makes such callers trusted.
proc core::value::withEvidence {v type} {
    set type [core::type::normalize $type]
    if {[core::type::base $type] ne [kind $v]} {
        error "core::value::withEvidence: [show $v] is not of base type [core::type::show $type]"
    }
    if {[kind $v] ni $::core::type::evidenceKinds} {
        error "core::value::withEvidence: [kind $v] values cannot carry evidence"
    }
    set names [evidence $v]
    foreach name [core::type::evidenceOf $type] {
        if {![dict get [core::type::metadata $name] opaque]
                && ![core::type::runValidator $name $v]} {
            error "core::value::withEvidence: [show $v] does not satisfy $name"
        }
        lappend names $name
    }
    if {$names eq ""} {
        return $v
    }
    return [list str [lindex $v 1] [lsort -unique $names]]
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

proc core::value::block {params body env {code ""}} {
    # The Block keeps its captured environment alive (env.tcl, Lifetime).
    core::env::pin $env
    return [list block $params $body $env $code]
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
proc core::value::blockCode {v}   { Require block $v; return [lindex $v 4] }

proc core::value::nativeName {v}  { Require native $v; return [lindex $v 1] }
proc core::value::mutarrayId {v}  { Require mutarray $v; return [lindex $v 1] }

# 1 if V is a Block or contains one (in a list or Result).
proc core::value::containsBlock {v} {
    switch -- [kind $v] {
        block  { return 1 }
        list {
            foreach item [lindex $v 1] {
                if {[containsBlock $item]} {
                    return 1
                }
            }
        }
        result { return [containsBlock [lindex $v 2]] }
    }
    return 0
}

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
    # MutableArray, like Block/Native, has no structural equality (its
    # identity/equality semantics are a separate design question: see
    # mutarray.tcl).
    if {$ka in {block native mutarray} || $kb in {block native mutarray}} {
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
# Display: unambiguous human-readable rendering. With WITH-EVIDENCE, evidence
# is appended as "TEXT"#{Name ...} (for debugging and differential tests).

proc core::value::show {v {withEvidence 0}} {
    switch -- [kind $v] {
        int  { return [lindex $v 1] }
        str  {
            set escaped [string map {\\ \\\\ \" \\\" \n \\n \t \\t} [lindex $v 1]]
            if {$withEvidence && [evidence $v] ne ""} {
                return "\"$escaped\"#{[evidence $v]}"
            }
            return "\"$escaped\""
        }
        bool { return [lindex $v 1] }
        unit { return unit }
        list {
            set parts {}
            foreach item [lindex $v 1] {
                lappend parts [show $item $withEvidence]
            }
            return "\[[join $parts {, }]\]"
        }
        result { return "[lindex $v 1]([show [lindex $v 2] $withEvidence])" }
        block  { return "<block ([join [lindex $v 1] { }])>" }
        native { return "<native [lindex $v 1]>" }
        mutarray { return "<mutable-array capacity=[core::value::intOf [core::mutarray::capacity $v]]>" }
    }
}
