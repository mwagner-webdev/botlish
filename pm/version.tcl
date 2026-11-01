# version.tcl -- package versions and version requests
# (BOTLISH-JSON.md, "Versions and requests").
#
#   version  := N "." N "." N           an exact release: 1.2.3
#   request  := N | N "." N | N "." N "." N
#   N        := "0" | [1-9][0-9]{0,8}    a decimal number below 10^9, no
#                                         leading zero
#
# A request's precision is its number of components, and it accepts exactly
# the versions that begin with its components: `1` accepts 1.x.y, `1.2`
# accepts 1.2.x, `1.2.3` accepts 1.2.3 alone. There are no operators (^, ~,
# >=, *), no ranges, no prerelease (1.2.3-rc.1) and no build metadata
# (1.2.3+linux): schema 1 rejects them, naming what was written. Nothing here
# assumes what a version change means beyond the request's own components.
#
# Versions compare numerically, component by component (1.10.0 > 1.9.7).

namespace eval pm::version {
    variable number {(?:0|[1-9][0-9]{0,8})}
}

# "" when TEXT is a valid exact version, else why not.
proc pm::version::Problem {text {what version}} {
    variable number
    if {[regexp "^${number}\\.${number}\\.${number}\$" $text]} {
        return ""
    }
    return [Explain $text $what "an exact version is three numbers, MAJOR.MINOR.PATCH (1.2.3)"]
}

# "" when TEXT is a valid request, else why not.
proc pm::version::RequestProblem {text} {
    variable number
    if {[regexp "^${number}(?:\\.${number}){0,2}\$" $text]} {
        return ""
    }
    return [Explain $text request "a request is one, two or three numbers: 1 (any 1.x.y), 1.2 (any 1.2.x) or 1.2.3 (exactly 1.2.3)"]
}

proc pm::version::Explain {text what rule} {
    if {[regexp {[-+]} $text] && [regexp {^[0-9]} $text]} {
        return "the $what \"$text\" has a prerelease or build suffix, which schema 1 does not support: $rule"
    }
    if {[regexp {^[\^~<>=*]|[*xX]$|\|\||\s} $text]} {
        return "the $what \"$text\" uses an operator or range, which Botlish versions do not have: $rule"
    }
    if {[regexp {(^|\.)0[0-9]} $text]} {
        return "the $what \"$text\" has a number with a leading zero: $rule"
    }
    if {[regexp {[0-9]{10}} $text]} {
        return "the $what \"$text\" has a number of more than nine digits: $rule"
    }
    return "the $what \"$text\" is malformed: $rule"
}

proc pm::version::isVersion {text} { return [expr {[Problem $text] eq ""}] }
proc pm::version::isRequest {text} { return [expr {[RequestProblem $text] eq ""}] }

# The numeric components of a version or request.
proc pm::version::Parts {text} {
    return [lmap part [split $text .] {scan $part %d}]
}

# -1, 0 or 1 as version A is below, equal to or above version B.
proc pm::version::compare {a b} {
    foreach x [Parts $a] y [Parts $b] {
        if {$x < $y} { return -1 }
        if {$x > $y} { return 1 }
    }
    return 0
}

# 1 when the exact VERSION satisfies REQUEST.
proc pm::version::satisfies {version request} {
    set have [Parts $version]
    set want [Parts $request]
    return [expr {[lrange $have 0 [expr {[llength $want] - 1}]] eq $want}]
}

# The newest of VERSIONS that satisfies REQUEST, or "".
proc pm::version::newest {versions request} {
    set best ""
    foreach version $versions {
        if {![satisfies $version $request]} continue
        if {$best eq "" || [compare $version $best] > 0} {
            set best $version
        }
    }
    return $best
}

# The default request for a dependency added at VERSION: its MAJOR.MINOR.
proc pm::version::defaultRequest {version} {
    return [join [lrange [split $version .] 0 1] .]
}

# VERSIONS sorted newest last.
proc pm::version::sort {versions} {
    return [lsort -command pm::version::compare $versions]
}
