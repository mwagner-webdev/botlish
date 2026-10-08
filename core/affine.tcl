# affine.tcl -- the Tcl backends' drop of affine aggregates (AFFINE-VALUES.md).
#
# An affine value is released where its owner dies (hir/affine.tcl decides
# where). A coroutine handle is released by coroutine#release
# (core/coroutines.tcl); an aggregate that owns affine values -- a struct with
# affine fields, a List of affine elements -- by
#
#   affine#drop(V, DESCRIPTOR)   releases every affine value V owns, by the
#                                static DESCRIPTOR of V's type
#                                (hir::affine::Descriptor): "c" a coroutine,
#                                "l"D each List element by D, "s"N"."
#                                (SLOT"."D)*N the struct fields at those
#                                layout slots, in the descriptor's order
#
# The descriptor is type-directed: only the positions the type says are
# affine are visited, never an unrestricted field or a List of unrestricted
# values. Like a coroutine release, a drop is unobservable -- no Botlish code
# runs and no value changes -- and idempotent (a coroutine release is).

namespace eval core::affine {
    # DESCRIPTOR -> its parsed tree ({c}, {l TREE}, {s {SLOT TREE} ...}).
    variable trees [dict create]
}

proc core::affine::dropNative {} { return affine#drop }

proc core::affine::dropImpl {value descriptor} {
    variable trees
    set text [core::value::strOf $descriptor]
    if {![dict exists $trees $text]} {
        set pos 0
        set tree [Parse $text pos]
        if {$pos != [string length $text]} {
            error "affine#drop: bad descriptor \"$text\""
        }
        dict set trees $text $tree
    }
    Drop $value [dict get $trees $text]
    return [core::value::unit]
}

# The descriptor tree at POS of TEXT, advancing POS past it.
proc core::affine::Parse {text posVar} {
    upvar 1 $posVar pos
    set c [string index $text $pos]
    incr pos
    switch -- $c {
        c { return {c} }
        l { return [list l [Parse $text pos]] }
        s {
            set n [Number $text pos]
            set tree {s}
            for {set i 0} {$i < $n} {incr i} {
                set slot [Number $text pos]
                lappend tree [list $slot [Parse $text pos]]
            }
            return $tree
        }
    }
    error "affine#drop: bad descriptor \"$text\" at $pos"
}

proc core::affine::Number {text posVar} {
    upvar 1 $posVar pos
    set end [string first . $text $pos]
    if {$end < 0} {
        error "affine#drop: bad descriptor \"$text\""
    }
    set n [string range $text $pos $end-1]
    set pos [expr {$end + 1}]
    return $n
}

proc core::affine::Drop {value tree} {
    switch -- [lindex $tree 0] {
        c {
            core::coroutines::releaseImpl $value
        }
        l {
            foreach element [core::value::items $value] {
                Drop $element [lindex $tree 1]
            }
        }
        s {
            set values [core::value::structValues $value]
            foreach part [lrange $tree 1 end] {
                lassign $part slot inner
                Drop [lindex $values $slot] $inner
            }
        }
    }
}

core::native::register affine#drop -arity 2 -impl core::affine::dropImpl \
    -param-types {any str} -result-type unit
