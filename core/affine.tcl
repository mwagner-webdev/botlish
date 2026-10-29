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
#                                "l"D each List element by D, "v"D each
#                                element of a MutableVector by D, first to
#                                last, leaving it empty (core/mutvec.tcl),
#                                "a"D each element of a MutableArray by D,
#                                first to last (core/mutarray.tcl),
#                                "s"N"."(SLOT"."D)*N the struct fields at
#                                those layout slots, in the descriptor's
#                                order
#
# The descriptor is type-directed: only the positions the type says are
# affine are visited, never an unrestricted field or a List of unrestricted
# values. Like a coroutine release, a drop is unobservable -- no Botlish code
# runs and no value changes -- and idempotent (a coroutine release is).
#
# Resources (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md) add two
# parts, each of which runs Botlish code -- exactly the program's own
# release code, never anything else:
#
#   "r"K"."   a resource: its cleanup function, entry K of the program's
#             cleanup table (hir/resources.tcl), called with the value
#   "C"       a coroutine of an unwinding program: coroutine#abandon
#             (core/coroutines.tcl), which runs its suspended frames'
#             releases
#
# The cleanup table is the run's: affine#register_cleanup(K, F) is written
# right after cleanup function F's declaration (hir/lower.tcl, the Tcl
# compiler), and affine#cleanup(K, V) -- a resource's own release -- calls F
# with V.

namespace eval core::affine {
    # DESCRIPTOR -> its parsed tree ({c}, {l TREE}, {s {SLOT TREE} ...}).
    variable trees [dict create]
    # The running program's cleanup functions: index K -> its Block value.
    variable cleanups [dict create]
    # Test probe: when not "none", every cleanup call appends its index and
    # the value it releases ({K VALUE}), in order.
    variable cleanupTrace none
}

proc core::affine::registerCleanupImpl {k f} {
    variable cleanups
    dict set cleanups [core::value::intOf $k] $f
    return [core::value::unit]
}

# Releases resource VALUE by its cleanup, entry K of the cleanup table: the
# cleanup's own completion -- normal (its result is unit), or a run-time
# fault -- is the release's.
proc core::affine::cleanupImpl {k value} {
    RunCleanup [core::value::intOf $k] $value
    return [core::value::unit]
}

proc core::affine::RunCleanup {k value} {
    variable cleanups
    variable cleanupTrace
    if {![dict exists $cleanups $k]} {
        error "affine#cleanup: no cleanup function $k is declared yet in this run (a compiler bug: hir/resources.tcl orders the declaration first)"
    }
    if {$cleanupTrace ne "none"} {
        lappend cleanupTrace [list $k $value]
    }
    set completion [core::runtime::callValue [dict get $cleanups $k] [list $value]]
    return
}

proc core::affine::dropNative {} { return affine#drop }

proc core::affine::dropImpl {value descriptor} {
    Drop $value [Tree [core::value::strOf $descriptor] affine#drop]
    return [core::value::unit]
}

# The parsed tree of descriptor TEXT (cached); WHO names the operation in an
# error. The same grammar serves the drop descriptors and the share
# descriptors of mutable_vector#share (core/mutvec.tcl).
proc core::affine::Tree {text who} {
    variable trees
    if {![dict exists $trees $text]} {
        set pos 0
        set tree [Parse $text pos]
        if {$pos != [string length $text]} {
            error "$who: bad descriptor \"$text\""
        }
        dict set trees $text $tree
    }
    return [dict get $trees $text]
}

# The descriptor tree at POS of TEXT, advancing POS past it.
proc core::affine::Parse {text posVar} {
    upvar 1 $posVar pos
    set c [string index $text $pos]
    incr pos
    switch -- $c {
        c { return {c} }
        C { return {C} }
        r { return [list r [Number $text pos]] }
        v { return [list v [Parse $text pos]] }
        a { return [list a [Parse $text pos]] }
        d {
            # A share descriptor's dynamic copy (mutable_vector#share,
            # core/mutvec.tcl): a value of a statically unknown type.
            return {d}
        }
        h {
            # A share descriptor's collection header -- a MutableVector's or
            # a MutableArray's (mutable_vector#share, core/mutvec.tcl);
            # never part of a drop descriptor.
            return {h}
        }
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
        C {
            core::coroutines::abandonImpl $value
        }
        r {
            RunCleanup [lindex $tree 1] $value
        }
        l {
            foreach element [core::value::items $value] {
                Drop $element [lindex $tree 1]
            }
        }
        v {
            core::mutvec::DropElements $value [lindex $tree 1]
        }
        a {
            core::mutarray::DropElements $value [lindex $tree 1]
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
    -param-types {any str} -result-type unit -ownership {release observe}

core::native::register affine#register_cleanup -arity 2 -impl core::affine::registerCleanupImpl \
    -param-types {int any} -result-type unit -ownership {observe observe}
core::native::register affine#cleanup -arity 2 -impl core::affine::cleanupImpl \
    -param-types {int any} -result-type unit -ownership {observe release}
