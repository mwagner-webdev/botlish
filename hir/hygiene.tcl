# hygiene.tcl -- keeping root references faithful through lowering.
#
# A root reference (hir::syntax::rootRef) denotes a root binding (a native,
# true, false or unit) no matter which local bindings share its name: a
# frontend uses it for names it introduces itself, such as the `list` a list
# literal calls. Core IR has only lexical `ref`, so if the reference's name
# is shadowed where it occurs, lowering it to (ref NAME) would find the local
# binding instead.
#
# Nothing in core IR is needed to express this: spelling is not identity, so
# the shadowing binding is renamed. Every such binding gets a fresh name
# NAME#N that no binding or reference in the program uses (source can never
# spell #), in the binding, its scope's names and every bind and ref of it.
# The binding keeps its original spelling in `spelling`. Afterwards a lexical
# lookup of every root reference's name finds its root binding, so lowered
# core IR, the compiler's frames and HIR text all agree with the HIR.
#
# Diagnostics are computed before renaming and keep the source spelling.

namespace eval hir::hygiene {}

# Renames bindings that shadow root references (recorded by resolution in
# HIR's rootRefs); removes rootRefs.
proc hir::hygiene::apply {hirVar} {
    upvar 1 $hirVar hir
    if {![dict exists $hir rootRefs]} {
        return
    }
    foreach e [dict get $hir rootRefs] {
        set name [dict get $hir exprs $e name]
        set root [dict get $hir exprs $e binding]
        while 1 {
            set found [hir::lookup $hir [dict get $hir exprs $e scope] $name]
            if {$found eq $root || $found eq ""} {
                break
            }
            Rename hir $found
        }
    }
    dict unset hir rootRefs
}

proc hir::hygiene::Rename {hirVar b} {
    upvar 1 $hirVar hir
    set old [dict get $hir bindings $b name]
    set used [dict create]
    dict for {id binding} [dict get $hir bindings] {
        dict set used [dict get $binding name] 1
    }
    dict for {id node} [dict get $hir exprs] {
        if {[dict exists $node name]} {
            dict set used [dict get $node name] 1
        }
    }
    set n 1
    while {[dict exists $used $old#$n]} {
        incr n
    }
    set new $old#$n

    set s [dict get $hir bindings $b scope]
    dict set hir bindings $b name $new
    if {![dict exists $hir bindings $b spelling]} {
        dict set hir bindings $b spelling $old
    }
    dict unset hir scopes $s names $old
    dict set hir scopes $s names $new $b
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] in {ref bind} && [dict get $node binding] eq $b} {
            dict set hir exprs $id name $new
        }
    }
}
