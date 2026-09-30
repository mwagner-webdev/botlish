# refcheck.tcl -- the strict-reference invariant, checked over a finished HIR.
#
# Independent of the resolver's implementation (which enforces the rule by
# construction: hir/resolve.tcl): it audits a finished HIR against the
# STRICT-REFERENCE-DETERMINISM.md invariant
#
#   every ordinary lexical reference targets a binding whose declaring `bind`
#   completed before the reference in evaluation (walk) order, except a named
#   function's reference to itself from inside its own body
#
# using nothing but the HIR's own walk order (hir::walk is the resolver's
# evaluation order: bind values before the bind establishes, callee before
# arguments, condition before branches).
#
#   hir::refcheck::forwardRefs HIR   => list of dicts, one per violating reference:
#       ref E name N binding B bind D kind KIND scope SHAPE
#     KIND    later      the reference precedes the declaring bind
#             selfvalue  inside its own (non-function) initializer
#     SHAPE   a coarse classification, see Classify
#
# Not on the compile path. hir::read uses it to reject HIR text that names a
# binding before its declaration; tests use it as the HIR invariant checker
# (forwardRefs must be empty for every built program); the census
# (audit/strict-reference-determinism/) runs it on the pre-change compiler,
# where forward references exist, to count them.

namespace eval hir::refcheck {}

proc hir::refcheck::forwardRefs {hir} {
    set order [hir::walk $hir]
    set index [dict create]
    set i 0
    foreach e $order {
        dict set index $e $i
        incr i
    }
    # last index of each expression's subtree, and the parent expression
    set last [dict create]
    set parent [dict create]
    foreach e $order {
        foreach child [hir::children $hir $e] {
            dict set parent $child $e
        }
    }
    for {set i [expr {[llength $order] - 1}]} {$i >= 0} {incr i -1} {
        set e [lindex $order $i]
        if {![dict exists $last $e]} {
            dict set last $e $i
        }
        if {[dict exists $parent $e]} {
            set p [dict get $parent $e]
            if {![dict exists $last $p] || [dict get $last $p] < [dict get $last $e]} {
                dict set last $p [dict get $last $e]
            }
        }
    }
    # function bindings: bind expressions whose value is a block, and the
    # binding each function block is bound to
    set fnBind [dict create]
    foreach e $order {
        if {[dict get $hir exprs $e kind] eq "bind"} {
            set v [dict get $hir exprs $e value]
            if {[dict get $hir exprs $v kind] eq "block"} {
                dict set fnBind $v $e
            }
        }
    }
    # graph of all references between function bindings (for mutual recursion)
    set edges [dict create]
    foreach e $order {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} continue
        set b [dict get $node binding]
        set d [dict get $hir bindings $b declaredBy]
        if {$d eq "" || ![IsFunction $hir $d]} continue
        set c [Enclosing $parent $fnBind $e]
        if {$c ne ""} {
            dict lappend edges [dict get $hir exprs $c binding] $b
        }
    }
    set result {}
    foreach e $order {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} continue
        set b [dict get $node binding]
        set binding [dict get $hir bindings $b]
        if {[dict get $binding kind] ne "local"} continue
        set d [dict get $binding declaredBy]
        if {$d eq "" || ![dict exists $index $d]} continue
        set ie [dict get $index $e]
        set id [dict get $index $d]
        set ld [dict get $last $d]
        if {$ie > $ld} continue
        set kind later
        if {$ie > $id} {
            if {[IsFunction $hir $d]} continue
            set kind selfvalue
        }
        set fnBinding ""
        set c [Enclosing $parent $fnBind $e]
        if {$c ne ""} {
            set fnBinding [dict get $hir exprs $c binding]
        }
        lappend result [dict create ref $e name [dict get $node name] binding $b bind $d kind $kind \
            shape [Classify $hir $e $d $fnBinding $edges]]
    }
    return $result
}

proc hir::refcheck::IsFunction {hir d} {
    return [expr {[dict get $hir exprs [dict get $hir exprs $d value] kind] eq "block"}]
}

# The nearest enclosing function-declaring bind of E, or "".
proc hir::refcheck::Enclosing {parent fnBind e} {
    while {[dict exists $parent $e]} {
        set e [dict get $parent $e]
        if {[dict exists $fnBind $e]} {
            return [dict get $fnBind $e]
        }
    }
    return ""
}

proc hir::refcheck::Reaches {edges from to} {
    set seen [dict create]
    set work [list $from]
    while {$work ne {}} {
        set x [lindex $work 0]
        set work [lrange $work 1 end]
        if {$x eq $to} {
            return 1
        }
        if {[dict exists $seen $x]} continue
        dict set seen $x 1
        if {[dict exists $edges $x]} {
            lappend work {*}[dict get $edges $x]
        }
    }
    return 0
}

# later-sibling-function | mutual-recursion | forward-module-binding |
# forward-local-value | closure-capture-later-binding | other
proc hir::refcheck::Classify {hir e d fnBinding edges} {
    set b [dict get $hir exprs $d binding]
    set isFn [IsFunction $hir $d]
    set inClosure [expr {$fnBinding ne ""
        || [dict get $hir scopes [dict get $hir exprs $e scope] invocation] ne
           [dict get $hir scopes [dict get $hir bindings $b scope] invocation]}]
    if {$isFn && $inClosure} {
        if {$fnBinding ne "" && [Reaches $edges $b $fnBinding]} {
            return mutual-recursion
        }
        return later-sibling-function
    }
    if {$isFn} {
        return other
    }
    if {[hir::isModuleBinding $hir $b]} {
        return forward-module-binding
    }
    if {$inClosure} {
        return closure-capture-later-binding
    }
    return forward-local-value
}
