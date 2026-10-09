# lower.tcl -- HIR to core IR.
#
# Lowering erases everything the core evaluator does not need: binding and
# scope identity, types, captures, refinements, call targets, origins. What
# remains is the executable meaning, which for today's HIR is exactly the
# core IR it was built from:
#
#   const      (const LITERAL...)        the literal as written
#   ref        (ref NAME)                name lookup finds the same binding:
#                                        resolution followed the runtime rules
#   bind       (bind NAME VALUE)
#   block      (block PARAMS BODY...)
#   call       (call CALLEE ARG...)      one call form, whatever the target
#   if         (if COND (block {} THEN...) (block {} ELSE...))
#   loop       (loop (block {} BODY...))
#   listloop   (listloop ITERABLE (block (ELEM) BODY...))
#   countloop  (countloop START END (block (I) BODY...) DIRECTION ENDKIND)
#   lockloop   (lockloop (DOMAIN...) (block (P...) BODY...) ?REJECTED?)
#   return     (return VALUE)
#   break      (break) / (break VALUE)
#   continue   (continue)
#   struct     (struct HEAD NAME VALUE ...)   written order; HEAD {} or {ID FIELD...}
#   project    (project VALUE NAME)
#   ok         (ok VALUE)
#   error      (error-value VALUE)
#   fail       (fail NAME)
#   handle     (handle CALL NAME1 (block {} HANDLER1...) ...)
#
# Static errors recorded as diagnostics (unbound names, duplicates, ...) are
# lowered as the operations that raise them at run time, so a program built
# with -strict 0 keeps its run-time behavior.
#
# Future HIR forms (namespaces, traits, extension calls) lower to these same
# forms, e.g. a resolved `users::save` call to a call of the binding or
# symbol it denotes.

namespace eval hir::lower {}

# The core IR program of HIR: a list of expressions.
proc hir::lower {hir} {
    return [hir::lower::Seq $hir [dict get $hir roots]]
}

# The core IR node of expression E.
proc hir::lower::expr {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const {
            return [list const {*}[dict get $node literal]]
        }
        ref {
            return [list ref [dict get $node name]]
        }
        bind {
            return [list bind [dict get $node name] [expr $hir [dict get $node value]]]
        }
        block {
            return [list block [params $hir $e] {*}[body $hir $e]]
        }
        call {
            if {[dict exists $node traitCall]} {
                # A trait operation of a program that was not monomorphized
                # (its check failed: TRAITS.md): it has no implementation to
                # call, so it raises at run time like any static error a
                # -strict 0 program keeps -- never a call of whatever function
                # the method name happened to resolve to.
                return [list call [list ref "trait-operation#[dict get $node traitCall requirement]"] \
                    {*}[Exprs $hir [dict get $node args]]]
            }
            set operands [concat [list [dict get $node callee]] [dict get $node args]]
            set lowered [Pending $hir $e $operands {apply {{ops} {list call {*}$ops}}}]
            if {$lowered eq ""} {
                set lowered [list call {*}[Exprs $hir $operands]]
            }
            return [ReleasingOnError $hir $e $lowered]
        }
        if {
            return [list if [expr $hir [dict get $node condition]] \
                [list block {} {*}[Seq $hir [dict get $node thenBody]]] \
                [list block {} {*}[Seq $hir [dict get $node elseBody]]]]
        }
        loop {
            return [list loop [list block {} {*}[Seq $hir [dict get $node body]]]]
        }
        listloop {
            set elemName [dict get $hir bindings [dict get $node elementBinding] name]
            set iterable [dict get $node iterable]
            set body [list block [list $elemName] {*}[Seq $hir [dict get $node body]]]
            set domain [expr $hir $iterable]
            set consuming [hir::mutvec::IsConsumingLoop $hir $e]
            if {$consuming} {
                # A loop consuming an affine MutableVector (MUTABLE-VECTOR.md):
                # marked as such in Core IR, which has no types to say so
                # (hir::mutvec::IsConsumingLoop reads the mark back).
                set marked [list call [list ref [hir::mutvec::ConsumeNative]] $domain]
            }
            if {[dict exists [hir::affine::temporaries $hir] $iterable]} {
                # A consuming loop whose remaining elements an early exit
                # releases by the domain's own name (hir::affine::LoopDomain).
                set temp [TempName $iterable]
                return [list if [list ref true] [list block {} [list bind $temp $domain] \
                    [list listloop [list call [list ref [hir::mutvec::ConsumeNative]] [list ref $temp]] $body]] [list block {}]]
            }
            if {$consuming} {
                return [list listloop $marked $body]
            }
            return [list listloop $domain $body]
        }
        countloop {
            set countName [dict get $hir bindings [dict get $node countBinding] name]
            set lowered [list countloop [expr $hir [dict get $node start]] [expr $hir [dict get $node end]] \
                [list block [list $countName] {*}[Seq $hir [dict get $node body]]]]
            if {[dict get $node direction] ne "up" || [dict get $node endKind] ne "exclusive"} {
                lappend lowered [dict get $node direction] \
                    [::expr {[dict get $node endKind] eq "inclusive" ? "through" : "to"}]
            }
            return $lowered
        }
        lockloop {
            set domains {}
            set names {}
            foreach domain [dict get $node domains] {
                lappend names [dict get $hir bindings [dict get $domain binding] name]
                if {[dict get $domain kind] eq "list"} {
                    lappend domains [list list [expr $hir [dict get $domain iterable]]]
                } else {
                    lappend domains [list count [expr $hir [dict get $domain start]] \
                        [expr $hir [dict get $domain end]] [dict get $domain direction] \
                        [::expr {[dict get $domain endKind] eq "inclusive" ? "through" : "to"}]]
                }
            }
            set lowered [list lockloop $domains [list block $names {*}[Seq $hir [dict get $node body]]]]
            if {[dict exists $node unproven]} {
                # A -strict 0 program whose lockstep obligation was rejected:
                # replay the diagnostic at run time instead of ever running
                # an unproven lockstep loop (see hir/lockstep.tcl).
                lappend lowered [dict get $node unproven]
            }
            return $lowered
        }
        return {
            return [list return [expr $hir [dict get $node value]]]
        }
        break {
            if {[dict get $node value] eq ""} {
                return [list break]
            }
            return [list break [expr $hir [dict get $node value]]]
        }
        continue {
            return [list continue]
        }
        struct {
            # The written order is the evaluation order; the head carries the
            # declaration identity and slot order of a named struct (an
            # anonymous struct's shape is just its field set). A named
            # construction whose type did not resolve (a diagnostic of a
            # -strict 0 HIR) lowers like an anonymous one.
            set head {}
            if {[dict get $node named] && [dict get $node structId] ne ""} {
                set head [linsert [dict get $node layout] 0 [dict get $node structId]]
            }
            set lowered [Pending $hir $e [dict get $node fields] [list apply {{head names ops} {
                set parts {}
                foreach name $names op $ops {
                    lappend parts $name $op
                }
                list struct $head {*}$parts
            }} $head [dict get $node names]]]
            if {$lowered ne ""} {
                return $lowered
            }
            set parts {}
            foreach name [dict get $node names] field [dict get $node fields] {
                lappend parts $name [expr $hir $field]
            }
            return [list struct $head {*}$parts]
        }
        project {
            return [list project [expr $hir [dict get $node receiver]] [dict get $node name]]
        }
        ok {
            return [list ok [expr $hir [dict get $node value]]]
        }
        error {
            return [list error-value [expr $hir [dict get $node value]]]
        }
        fail {
            return [list fail [dict get $node name]]
        }
        handle {
            set handlers {}
            foreach name [dict get $node handlerNames] body [dict get $node handlerBodies] {
                lappend handlers $name [list block {} {*}[Seq $hir $body]]
            }
            return [ReleasingOnError $hir $e [list handle [expr $hir [dict get $node call]] {*}$handlers]]
        }
    }
}

# Parameter names of block expression E.
proc hir::lower::params {hir e} {
    return [lmap b [dict get $hir exprs $e params] {dict get $hir bindings $b name}]
}

# Core IR body expressions of block expression E.
proc hir::lower::body {hir e} {
    return [Seq $hir [dict get $hir exprs $e body]]
}

# The core IR of the statement sequence IDS: each statement, followed by the
# release of the affine values dead after it (hir::affine::releasesAfter,
# AFFINE-VALUES.md; COROUTINES.md "Release at the last use"). A release after
# the sequence's last statement keeps that statement's value as the
# sequence's: `bind T STATEMENT; release...; T` (a binding statement `bind N
# V` is followed by `ref N` instead); so does the release of a statement's own
# discarded value (an item naming the statement itself). An exit statement
# (return, break, continue, fail) releases the values it takes out of scope
# or abandons (hir::affine::releasesOnExit) before it, or, for those its
# value refers to, between evaluating the value and leaving: `bind T VALUE;
# release...; return T`.
proc hir::lower::Seq {hir ids} {
    set result {}
    set n [llength $ids]
    set i 0
    foreach id $ids {
        incr i
        lassign [hir::affine::releasesOnExit $hir $id] before after
        if {$before ne {} || $after ne {}} {
            lappend result {*}[Releases $hir $before]
            if {$after eq {}} {
                lappend result [expr $hir $id]
            } else {
                set kept "affine#kept#$id"
                lappend result [list bind $kept [expr $hir [dict get $hir exprs $id value]]] \
                    {*}[Releases $hir $after] [list [dict get $hir exprs $id kind] [list ref $kept]]
            }
            continue
        }
        set lowered [expr $hir $id]
        set releases [hir::affine::releasesAfter $hir $id]
        if {$releases eq ""} {
            lappend result $lowered
            continue
        }
        if {$id in $releases} {
            # The statement's own value is released: kept by name.
            set kept "affine#kept#$id"
            lappend result [list bind $kept $lowered]
            set lowered [list ref $kept]
            set calls [Releases $hir $releases $kept]
            lappend result {*}$calls
            if {$i == $n} {
                lappend result $lowered
            }
            continue
        }
        set calls [Releases $hir $releases]
        if {$i < $n} {
            lappend result $lowered {*}$calls
        } elseif {[lindex $lowered 0] eq "bind"} {
            # A binding statement's value is its bound value: kept by name.
            lappend result $lowered {*}$calls [list ref [lindex $lowered 1]]
        } else {
            set kept "affine#kept#$id"
            lappend result [list bind $kept $lowered] {*}$calls [list ref $kept]
        }
    }
    return $result
}

# The core IR releasing the affine values of release items ITEMS
# (hir::affine::DropPlan): a binding by its name, a pending temporary by the
# name its construction gave it (TempName), a statement's own value by KEPT.
proc hir::lower::Releases {hir items {kept ""}} {
    set result {}
    foreach item $items {
        set plan [hir::affine::DropPlan $hir $item]
        if {$plan eq ""} continue
        if {[string match b* $item]} {
            set value [list ref [dict get $hir bindings $item name]]
        } elseif {$kept ne "" && $item eq [lindex [split $kept #] end]} {
            set value [list ref $kept]
        } else {
            set value [list ref [TempName $item]]
        }
        if {[lindex $plan 0] eq "coroutine"} {
            lappend result [list call [list ref [core::coroutines::releaseNative]] $value]
        } else {
            lappend result [list call [list ref [hir::affine::DropNative]] $value [list const str [lindex $plan 1]]]
        }
    }
    return $result
}

# The Core IR name of pending temporary E: a construction operand a release
# may need by name (hir::affine::temporaries; Pending).
proc hir::lower::TempName {e} {
    return "affine#temp#$e"
}

# LOWERED, the core IR of call (or handle) E, releasing the affine values a
# declared error it propagates takes out of scope or abandons
# (hir::affine::releasesOnError): a handler per such error that releases
# and fails with the same error again -- an error is its name, so the
# propagation goes on unchanged.
proc hir::lower::ReleasingOnError {hir e lowered} {
    set byName [hir::affine::releasesOnError $hir $e]
    if {$byName eq ""} {
        return $lowered
    }
    if {[lindex $lowered 0] ne "handle"} {
        set lowered [list handle $lowered]
    }
    dict for {name items} $byName {
        lappend lowered $name [list block {} {*}[Releases $hir $items] [list fail $name]]
    }
    return $lowered
}

# The core IR of construction E (a call or struct, OPERANDS its callee and
# arguments, or field values) when one of its operands is a pending
# temporary a release names (hir::affine::temporaries): its operands are
# evaluated first, in order, into named temporaries -- inside an always-taken
# branch, which gives them a scope of their own while keeping the
# construction an expression -- and BUILD (a command prefix, given the
# operand list) builds the call or struct of those names. Evaluation order and
# meaning are unchanged; only the names exist.
proc hir::lower::Pending {hir e operands build} {
    set temps [hir::affine::temporaries $hir]
    set named 0
    foreach o $operands {
        if {[dict exists $temps $o]} {
            set named 1
        }
    }
    if {!$named} {
        return ""
    }
    set binds {}
    set ops {}
    foreach o $operands {
        set lowered [expr $hir $o]
        if {[lindex $lowered 0] in {ref const}} {
            lappend ops $lowered
            continue
        }
        lappend binds [list bind [TempName $o] $lowered]
        lappend ops [list ref [TempName $o]]
    }
    return [list if [list ref true] [list block {} {*}$binds [{*}$build $ops]] [list block {}]]
}

proc hir::lower::Exprs {hir ids} {
    return [lmap id $ids {expr $hir $id}]
}
