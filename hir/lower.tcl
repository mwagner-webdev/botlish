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
#   return     (return VALUE)
#   break      (break) / (break VALUE)
#   continue   (continue)
#   ok         (ok VALUE)
#   error      (error-value VALUE)
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
        ok {
            return [list ok [expr $hir [dict get $node value]]]
        }
        error {
            return [list error-value [expr $hir [dict get $node value]]]
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
