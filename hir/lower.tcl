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
    return [lmap e [dict get $hir roots] {hir::lower::expr $hir $e}]
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
            return [list call {*}[Exprs $hir [concat [list [dict get $node callee]] [dict get $node args]]]]
        }
        if {
            return [list if [expr $hir [dict get $node condition]] \
                [list block {} {*}[Exprs $hir [dict get $node thenBody]]] \
                [list block {} {*}[Exprs $hir [dict get $node elseBody]]]]
        }
        loop {
            return [list loop [list block {} {*}[Exprs $hir [dict get $node body]]]]
        }
        listloop {
            set elemName [dict get $hir bindings [dict get $node elementBinding] name]
            return [list listloop [expr $hir [dict get $node iterable]] \
                [list block [list $elemName] {*}[Exprs $hir [dict get $node body]]]]
        }
        countloop {
            set countName [dict get $hir bindings [dict get $node countBinding] name]
            set lowered [list countloop [expr $hir [dict get $node start]] [expr $hir [dict get $node end]] \
                [list block [list $countName] {*}[Exprs $hir [dict get $node body]]]]
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
            set lowered [list lockloop $domains [list block $names {*}[Exprs $hir [dict get $node body]]]]
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
                lappend handlers $name [list block {} {*}[Exprs $hir $body]]
            }
            return [list handle [expr $hir [dict get $node call]] {*}$handlers]
        }
    }
}

# Parameter names of block expression E.
proc hir::lower::params {hir e} {
    return [lmap b [dict get $hir exprs $e params] {dict get $hir bindings $b name}]
}

# Core IR body expressions of block expression E.
proc hir::lower::body {hir e} {
    return [Exprs $hir [dict get $hir exprs $e body]]
}

proc hir::lower::Exprs {hir ids} {
    return [lmap id $ids {expr $hir $id}]
}
