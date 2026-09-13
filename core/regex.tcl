# regex.tcl -- an engine-independent regular expression IR.
#
# Botlish regexes are Tcl data, not regex source text. The IR is the
# specification; Tcl's regexp is merely the engine it is lowered to, so Tcl's
# regex language never becomes Botlish's. Constructs outside the safe
# contract below are rejected when the IR is built -- arbitrary engine syntax
# is never accepted, so there is nothing to sanitize.
#
#   {lit TEXT}              the characters of TEXT
#   {char C}                the single character C
#   {range LO HI}           one character from LO to HI (by code point)
#   {class NAME}            one character of a class:
#                             alpha digit alnum upper lower space punct xdigit
#   {set ITEM...}           one character matching any ITEM, where an ITEM is
#                           a char, range or class node
#   {any}                   any one character
#   {seq NODE...}           NODEs in sequence (empty: the empty string)
#   {alt NODE...}           any one of NODEs (at least one)
#   {repeat NODE MIN MAX}   NODE MIN to MAX times; MAX may be inf;
#                           bounds are limited to 0..255
#   {capture NAME NODE}     NODE, remembering what it matched as NAME
#   {start} {end}           start / end of the text
#
# Reserved for later: unicode-property. No backreferences or lookaround are
# part of the contract.
#
# A regex value, built by `create`, is {regex IR ARE CAPTURE-NAMES}.
# `matches` tests whether the *whole* text matches.

namespace eval core::regex {
    variable classes {alpha digit alnum upper lower space punct xdigit}
    variable maxBound 255
}

# Validates IR and lowers it. Returns a regex value.
proc core::regex::create {ir} {
    set names {}
    set are [Lower $ir names]
    return [list regex $ir $are $names]
}

proc core::regex::Reject {message node} {
    error "core::regex: $message: $node"
}

proc core::regex::Require {regex} {
    if {[lindex $regex 0] ne "regex" || [llength $regex] != 4} {
        error "core::regex: not a regex value (use core::regex::create): $regex"
    }
}

# The Tcl ARE for REGEX (unanchored).
proc core::regex::compileTcl {regex} {
    Require $regex
    return [lindex $regex 2]
}

proc core::regex::ir {regex} {
    Require $regex
    return [lindex $regex 1]
}

proc core::regex::captureNames {regex} {
    Require $regex
    return [lindex $regex 3]
}

# 1 if the whole of TEXT matches REGEX.
proc core::regex::matchesText {regex text} {
    Require $regex
    return [regexp -- "\\A(?:[lindex $regex 2])\\Z" $text]
}

# 1 if the string value V matches REGEX (the validator protocol of type.tcl).
proc core::regex::matches {regex v} {
    return [matchesText $regex [core::value::strOf [core::value::expect str $v regex]]]
}

# If the whole of TEXT matches, a dict NAME -> captured text (names that
# took no part in the match map to ""); otherwise "" .
proc core::regex::captures {regex text} {
    Require $regex
    set groups [regexp -inline -- "\\A(?:[lindex $regex 2])\\Z" $text]
    if {$groups eq ""} {
        return ""
    }
    set result [dict create]
    foreach name [lindex $regex 3] value [lrange $groups 1 end] {
        dict set result $name $value
    }
    return $result
}

# ---------------------------------------------------------------------------
# Lowering to Tcl ARE

proc core::regex::Lower {node namesVar} {
    upvar 1 $namesVar names
    variable maxBound
    if {[catch {llength $node} length] || $length == 0} {
        Reject "a regex node must be a non-empty list" $node
    }
    switch -- [lindex $node 0] {
        lit {
            Arity $node 2 2
            set out ""
            foreach c [split [lindex $node 1] ""] {
                append out [Char $c]
            }
            return $out
        }
        char {
            Arity $node 2 2
            return [Char [SingleChar [lindex $node 1] $node]]
        }
        range - class - set {
            return "\[[BracketItem $node 1]\]"
        }
        any {
            Arity $node 1 1
            return "(?:.|\\n)"
        }
        seq {
            set out ""
            foreach child [lrange $node 1 end] {
                append out [Lower $child names]
            }
            return "(?:$out)"
        }
        alt {
            Arity $node 2 *
            set parts {}
            foreach child [lrange $node 1 end] {
                lappend parts [Lower $child names]
            }
            return "(?:[join $parts |])"
        }
        repeat {
            Arity $node 4 4
            lassign $node _ child min max
            if {![string is digit -strict $min] || $min > $maxBound} {
                Reject "repeat minimum must be an integer 0..$maxBound" $node
            }
            if {$max eq "inf"} {
                set bound "{$min,}"
            } elseif {![string is digit -strict $max] || $max > $maxBound || $max < $min} {
                Reject "repeat maximum must be inf or an integer min..$maxBound" $node
            } else {
                set bound "{$min,$max}"
            }
            return "(?:[Lower $child names])$bound"
        }
        capture {
            Arity $node 3 3
            lassign $node _ name child
            if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $name]} {
                Reject "capture name must be an identifier" $node
            }
            if {$name in $names} {
                Reject "duplicate capture name \"$name\"" $node
            }
            lappend names $name
            return "([Lower $child names])"
        }
        start {
            Arity $node 1 1
            return "\\A"
        }
        end {
            Arity $node 1 1
            return "\\Z"
        }
        unicode-property {
            Reject "unicode-property is not supported yet" $node
        }
        default {
            Reject "unknown regex node \"[lindex $node 0]\"" $node
        }
    }
}

proc core::regex::Arity {node min max} {
    set n [llength $node]
    if {$n < $min || ($max ne "*" && $n > $max)} {
        Reject "wrong number of operands" $node
    }
}

proc core::regex::SingleChar {text node} {
    if {[string length $text] != 1} {
        Reject "expected a single character" $node
    }
    return $text
}

# One literal character as an ARE atom. ASCII letters and digits stand for
# themselves; everything else is written as a \uXXXX escape, which ARE reads
# as that literal character (never as an operator).
proc core::regex::Char {c} {
    if {[regexp {^[A-Za-z0-9]$} $c]} {
        return $c
    }
    return [CodePoint $c]
}

proc core::regex::CodePoint {c} {
    scan $c %c code
    if {$code > 0xFFFF} {
        return [format "\\U%08X" $code]
    }
    return [format "\\u%04X" $code]
}

# The inside of a bracket expression for a range, class or set node.
# TOP is 1 for the node itself, 0 for an item inside a set.
proc core::regex::BracketItem {node top} {
    variable classes
    if {[catch {llength $node} length] || $length == 0} {
        Reject "a regex node must be a non-empty list" $node
    }
    switch -- [lindex $node 0] {
        char {
            Arity $node 2 2
            if {$top} {
                Reject "internal: char is not a bracket node" $node
            }
            return [CodePoint [SingleChar [lindex $node 1] $node]]
        }
        range {
            Arity $node 3 3
            set lo [SingleChar [lindex $node 1] $node]
            set hi [SingleChar [lindex $node 2] $node]
            scan $lo %c loCode
            scan $hi %c hiCode
            if {$loCode > $hiCode} {
                Reject "empty range" $node
            }
            return "[CodePoint $lo]-[CodePoint $hi]"
        }
        class {
            Arity $node 2 2
            if {[lindex $node 1] ni $classes} {
                Reject "unknown class (known: $classes)" $node
            }
            return "\[:[lindex $node 1]:\]"
        }
        set {
            if {!$top} {
                Reject "sets cannot be nested" $node
            }
            Arity $node 2 *
            set out ""
            foreach item [lrange $node 1 end] {
                if {[lindex $item 0] ni {char range class}} {
                    Reject "a set item must be a char, range or class" $item
                }
                append out [BracketItem $item 0]
            }
            return $out
        }
    }
}
