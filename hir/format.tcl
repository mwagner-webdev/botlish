# format.tcl -- human-readable HIR, for debugging and tests.
#
#   hir::format HIR ?-origins 1?
#
# One line per expression, children indented by four spaces:
#
#   program s2 binds b1 x, b2 y
#   e1 bind b1 x : int
#       e2 const 10 : int
#   e3 bind b2 y : int
#       e4 call native(+) : int
#           e5 ref b3 + : native +
#           e6 ref b1 x : int
#           e7 const 1 : int
#
# Line shapes (then ": TYPE", then flags):
#
#   eN const LITERAL
#   eN ref BINDING NAME                  ref ? NAME when unresolved
#   eN bind BINDING NAME
#   eN block SCOPE (PARAMS) captures (BINDINGS) ?staticRefs (BINDINGS)?
#                                        staticRefs (hir::isModuleBinding)
#                                        omitted when empty; then ?nomethod?,
#                                        ?declares TYPE?, ?proves BINDING
#                                        NAME: TYPE? (a proof contract,
#                                        REFINEMENT-VALUES.md), ?errors ...?
#                                        and ?contexts (DIRECT) requires
#                                        (REQUIRED)? -- the block's direct and
#                                        transitive context requirements
#                                        (CONTEXTS.md), omitted when empty
#   eN call TARGET                       native(NAME), block(eN) or generic;
#                                        "= true"/"= false" when decided;
#                                        "installs ID" on a verified context
#                                        installation (CONTEXTS.md)
#   eN if                                followed by "then SCOPE ..." and
#                                        "else SCOPE ..." lines with the
#                                        refinements proven on entry
#   eN loop SCOPE
#   eN listloop SCOPE (ELEM)             children: the iterable, then the body
#   eN countloop SCOPE (I) ?DIR KIND?    DIR up|down, KIND exclusive|inclusive,
#                                        shown only when not "up exclusive";
#                                        children: start, end, then the body
#   eN lockloop SCOPE (B list) (B count DIR KIND) ...
#                                        one (BINDING NAME ...) group per
#                                        domain; children: each domain's
#                                        operands in order (one for list,
#                                        start then end for count), the body
#   eN return -> eN / break -> eN / continue -> eN
#   eN ok / eN error
#   eN struct (anon|ID) (FIELD, ...)     a struct value/construction; one
#                                        child line per field value, in
#                                        written order (STRUCTS.md)
#   eN project FIELD                     a field projection; the child is
#                                        the receiver
#
# Flags: unbound, deferred (an ambient binding: the host's value when a
# closure runs), duplicate, unreachable. With -origins 1 each line ends with @ORIGIN.

namespace eval hir::format {}

proc hir::format {hir args} {
    set options [dict create -origins 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "hir::format: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set lines {}
    foreach entry [hir::sourceTypes $hir] {
        lappend lines [hir::format::TypeDecl $entry]
    }
    if {[dict exists $hir traits]} {
        foreach entry [dict get $hir traits] {
            lappend lines [hir::format::TraitDecl $entry]
        }
    }
    if {[dict exists $hir traitFunctions]} {
        dict for {name fn} [dict get $hir traitFunctions] {
            lappend lines [hir::format::TraitFunction $name $fn]
        }
    }
    foreach name [hir::errorDecls $hir] {
        lappend lines "error $name"
    }
    set top [dict get $hir top]
    lappend lines [string trimright "[dict get $hir scopes $top kind] $top [hir::format::Binds $hir $top]"]
    foreach e [dict get $hir roots] {
        hir::format::Expr $hir $e 0 [dict get $options -origins] lines
    }
    return [join $lines \n]
}

# One line for a source-defined type (hir::sourceTypes's own {name .. parent
# .. domain ..} entries): "type NAME parent PARENT domain interval LO HI" or
# "type NAME parent PARENT domain exact V...". Read back by hir::read::
# TypeDecl (read.tcl), which re-registers it (hir::sourcetypes::RegisterOne)
# before any expression line is parsed -- so a serialized HIR's own
# `declares TYPE`/`: TYPE` text (below) resolves exactly as it did when the
# HIR was first built, without needing the original Botlish source again.
proc hir::format::TypeDecl {entry} {
    if {[dict exists $entry kind] && [dict get $entry kind] eq "refined"} {
        # A refinement type (REFINEMENT-VALUES.md): "refined type ID carrier
        # TYPE owner NS" (NS "-" for the entry program) -- its canonical
        # identity, its resolved carrier, and the one module that may mint
        # it. Read back by hir::read::TypeDeclLine.
        set owner [dict get $entry owner]
        return "refined type [dict get $entry name] carrier [hir::types::show [dict get $entry carrier]] owner [expr {$owner eq "" ? "-" : $owner}]"
    }
    if {[dict exists $entry kind] && [dict get $entry kind] eq "enum"} {
        # An enum declaration (hir/enums.tcl, ENUMS.md): "enum ID name NAME ns
        # NS cases C1, C2, ..." (NS "-" for the entry program), the complete
        # closed case set in declaration order. Read back by hir::read::
        # EnumDeclLine.
        set ns [dict get $entry namespace]
        return "enum [dict get $entry id] name [dict get $entry name] ns [expr {$ns eq "" ? "-" : $ns}] cases [join [dict get $entry cases] {, }]"
    }
    if {[dict exists $entry kind] && [dict get $entry kind] eq "struct"} {
        # A struct declaration (hir/structs.tcl): "struct ID name NAME ns NS
        # [opaque] fields F1: T1, F2: T2" (NS "-" for the entry program), the
        # fields in declared (slot) order with their resolved types. The
        # `opaque` word is printed only for an opaque struct
        # (OPAQUE-STRUCTS.md), so ordinary declarations print as they always
        # did.
        set fields [lmap {name type} [dict get $entry fields] {
            format {%s: %s} $name [hir::types::show $type]
        }]
        set ns [dict get $entry namespace]
        set opaque [expr {[dict exists $entry opaque] && [dict get $entry opaque] ? "opaque " : ""}]
        if {[dict exists $entry context] && [dict get $entry context]} {
            append opaque "context "
        }
        return "struct [dict get $entry id] name [dict get $entry name] ns [expr {$ns eq "" ? "-" : $ns}] ${opaque}fields [join $fields {, }]"
    }
    set domain [dict get $entry domain]
    if {[lindex $domain 0] eq {interval}} {
        set domainText "interval [lindex $domain 1] [lindex $domain 2]"
    } else {
        set domainText "exact [lindex $domain 1]"
    }
    return "type [dict get $entry name] parent [dict get $entry parent] domain $domainText"
}

# One line for a trait declaration (TRAITS.md, HIR's `traits`): "trait ID
# owner NS requires REQ ; REQ ...", each REQ "NAME(P: T, ...) -> R errors E,
# ..." with the trait's own type spelled as its identity (NS "-" for the
# entry program). Read back by hir::read::TraitLine.
proc hir::format::TraitDecl {entry} {
    set reqs {}
    foreach r [dict get $entry requirements] {
        set text "[dict get $r name]([join [lmap p [dict get $r params] {format {%s: %s} [dict get $p name] [hir::types::show [dict get $p type]]}] {, }])"
        if {[dict get $r result] ne ""} {
            append text " -> [hir::types::show [dict get $r result type]]"
        }
        if {[dict get $r errors] ne {}} {
            append text " errors [join [dict get $r errors] {, }]"
        }
        lappend reqs $text
    }
    set ns [dict get $entry namespace]
    # A context trait (CONTEXT-TRAITS.md) carries its modifier.
    set context [expr {[dict exists $entry context] && [dict get $entry context] ? " context" : ""}]
    return "trait [dict get $entry id]$context owner [expr {$ns eq "" ? "-" : $ns}] requires [join $reqs { ; }]"
}

# One line for a trait-polymorphic source function the monomorphized program
# replaced by its clones (HIR's `traitFunctions`): "traitfn NAME (P: T, ...)
# -> R clones (C, ...)" (R "-" when undeclared).
proc hir::format::TraitFunction {name fn} {
    set params [join [lmap {p t} [dict get $fn params] {format {%s: %s} $p [hir::types::show $t]}] {, }]
    set result [expr {[dict get $fn result] eq "" ? "-" : [hir::types::show [dict get $fn result]]}]
    return "traitfn $name ($params) -> $result clones ([join [lmap {c w} [dict get $fn clones] {set c}] {, }])"
}

proc hir::format::BindingLabel {hir b} {
    return "$b [dict get $hir bindings $b name]"
}

proc hir::format::BindingList {hir bindings} {
    return [join [lmap b $bindings {BindingLabel $hir $b}] {, }]
}

# Like BindingList, but for a block's own PARAMS: appends ":TYPE" (hir::
# types::show) after a typed parameter's label, one entry of DECLAREDTYPES
# (parallel to PARAMS, "" for untyped) per parameter.
proc hir::format::ParamList {hir params declaredTypes} {
    set items {}
    foreach b $params type $declaredTypes {
        set label [BindingLabel $hir $b]
        if {$type ne {}} {
            append label ":[hir::types::show $type]"
        }
        lappend items $label
    }
    return [join $items {, }]
}

proc hir::format::Binds {hir s} {
    set locals [lmap b [dict get $hir scopes $s bindings] {
        if {[dict get $hir bindings $b kind] ne "local"} continue
        set b
    }]
    if {$locals eq ""} {
        return ""
    }
    return "binds [BindingList $hir $locals]"
}

proc hir::format::Facts {hir pairs} {
    set shown {}
    foreach {b fact} $pairs {
        lappend shown "[BindingLabel $hir $b] : [hir::types::show $fact]"
    }
    if {$shown eq ""} {
        return ""
    }
    return "refines [join $shown {, }]"
}

proc hir::format::Line {hir e text indent origins linesVar {typed 1}} {
    upvar 1 $linesVar lines
    set node [dict get $hir exprs $e]
    set line "[string repeat {    } $indent]$e $text"
    if {$typed} {
        append line " : [hir::types::show [hir::typeOf $hir $e]]"
    }
    set flags {}
    switch -- [dict get $node kind] {
        ref {
            if {[dict get $node binding] eq ""} {
                lappend flags unbound
            } else {
                if {[dict get $node init] eq "deferred"} {
                    lappend flags deferred
                }
            }
            if {[hir::affine::isMove $hir $e]} {
                # A move of an affine value (AFFINE-VALUES.md): the
                # referenced binding is dead from here, its value owned by
                # whatever this reference flows into.
                lappend flags move
            }
        }
        bind {
            if {[dict get $node duplicate]} {
                lappend flags duplicate
            }
            if {[hir::affine::isMoveBind $hir $e]} {
                # The move of an affine value to a new binding: the
                # bound-from binding is dead from here.
                lappend flags move
            }
            set consumed [hir::affine::ConsumedFields $hir [dict get $node binding]]
            if {$consumed ne {} && [dict get $node binding] ne ""} {
                # A destructuring's temporary: the affine fields moved out of
                # it (its release drops only the others).
                lappend flags "consumed=[join [lsort $consumed] ,]"
            }
        }
    }
    lappend flags {*}[hir::mutvec::Evidence $hir $e]
    if {![dict get $node reachable]} {
        lappend flags unreachable
    }
    set releases [hir::affine::releasesAfter $hir $e]
    if {$releases ne ""} {
        # The affine values released after this statement (AFFINE-VALUES.md,
        # COROUTINES.md "Release at the last use"): bindings dead from here,
        # or the statement's own discarded value (its ExprId).
        lappend flags "release=[join $releases ,]"
    }
    set exiting [concat {*}[hir::affine::releasesOnExit $hir $e]]
    if {$exiting ne ""} {
        # The affine values this exit (return, break, continue, fail)
        # releases as it leaves their owners' scope, or abandons as pending
        # temporaries.
        lappend flags "exit-release=[join [lsort -dictionary $exiting] ,]"
    }
    set failing [hir::affine::releasesOnError $hir $e]
    if {$failing ne ""} {
        # The affine values released when this call propagates a declared
        # error, per error name.
        lappend flags "error-release=[join [lmap {name bs} $failing {string cat $name = [join $bs ,]}] {;}]"
    }
    if {$flags ne ""} {
        append line " [join $flags { }]"
    }
    if {$origins} {
        append line " @[dict get $node origin]"
    }
    lappend lines $line
}

proc hir::format::Target {hir target} {
    lassign $target kind id
    switch -- $kind {
        native  { return "native([dict get $hir symbols $id name])" }
        block   { return "block($id)" }
        default { return generic }
    }
}

proc hir::format::Expr {hir e indent origins linesVar} {
    upvar 1 $linesVar lines
    set node [dict get $hir exprs $e]
    set inner [expr {$indent + 1}]
    switch -- [dict get $node kind] {
        const {
            Line $hir $e "const [dict get $node literal]" $indent $origins lines
        }
        ref {
            set b [dict get $node binding]
            set label [expr {$b eq "" ? "? [dict get $node name]" : [BindingLabel $hir $b]}]
            Line $hir $e "ref $label" $indent $origins lines
        }
        bind {
            Line $hir $e "bind [BindingLabel $hir [dict get $node binding]]" $indent $origins lines
            Expr $hir [dict get $node value] $inner $origins lines
        }
        block {
            set text "block [dict get $node bodyScope] ([ParamList $hir [dict get $node params] [dict get $node declaredParamTypes]])"
            append text " captures ([BindingList $hir [dict get $node captures]])"
            if {[dict get $node staticRefs] ne {}} {
                append text " staticRefs ([BindingList $hir [dict get $node staticRefs]])"
            }
            if {[dict exists $node nomethod]} {
                append text " nomethod"
            }
            if {[dict exists $node traitClone]} {
                # A trait clone (TRAITS.md): each trait parameter's source
                # view -- its declared type is the witness.
                set views {}
                foreach b [dict get $node params] {
                    if {[dict exists $hir bindings $b view]} {
                        lappend views "[BindingLabel $hir $b]: [lindex [dict get $hir bindings $b view] 1]"
                    }
                }
                append text " clone ([join $views {, }])"
            }
            if {[dict exists $node contextClone]} {
                # The installed context each context trait the clone's
                # operations call was statically selected as
                # (CONTEXT-TRAITS.md).
                append text " contextclone ([join [lmap {c w} [dict get $node contextClone] {string cat $c = $w}] {, }])"
            }
            if {[dict exists $node traitResult]} {
                append text " traitresult [lindex [dict get $node traitResult] 1]"
            }
            if {[dict exists $node requiredContexts] && [dict get $node requiredContexts] ne {}} {
                # CONTEXTS.md: the context types the block's own region loads
                # (its context parameters) and the ones it transitively
                # requires through its calls (hir/contexts.tcl).
                append text " contexts ([join [dict get $node directContexts] {, }]) requires ([join [dict get $node requiredContexts] {, }])"
            }
            if {[dict get $node declaredResult] ne {}} {
                append text [format { declares %s} [hir::types::show [dict get $node declaredResult]]]
            }
            if {[dict exists $node proofs]} {
                # The proof contract (REFINEMENT-VALUES.md): "proves BINDING
                # NAME: TYPE" -- when a call returns true (a predicate,
                # `declares bool`) or completes normally (a validator,
                # `declares unit`), its argument for that parameter
                # satisfies TYPE. The outcome is the declared result's, so
                # hir::read derives it back from the `declares` above.
                foreach proof [dict get $node proofs] {
                    append text [format { proves %s: %s} [BindingLabel $hir [dict get $proof binding]] \
                        [hir::types::show [dict get $proof fact]]]
                }
            }
            if {[dict exists $node declaredResume] && [dict get $node declaredResume] ne {}} {
                # A declared coroutine resume protocol (COROUTINES.md).
                append text " resume [hir::types::show [dict get $node declaredResume]]"
            }
            if {[dict get $node declaredErrors] ne {}} {
                append text " errors [join [dict get $node declaredErrors] {, }]"
            }
            set effect [hir::coroutines::EffectText $hir $e]
            if {$effect ne ""} {
                # The function's coroutine effect (COROUTINES.md), derived
                # (hir::check recomputes it): what its yields send and what
                # they evaluate to.
                append text " coroutine-effect ($effect)"
            }
            set binds [Binds $hir [dict get $node bodyScope]]
            if {$binds ne ""} {
                append text " $binds"
            }
            Line $hir $e $text $indent $origins lines
            foreach child [dict get $node body] {
                Expr $hir $child $inner $origins lines
            }
        }
        call {
            set text "call [Target $hir [dict get $node target]]"
            switch -- [dict get $node known] {
                1 { append text " = true" }
                0 { append text " = false" }
            }
            set installs [hir::contexts::installId $hir $e]
            if {$installs ne ""} {
                append text " installs $installs"
            }
            if {[dict exists $node traitImpl]} {
                # A trait operation resolved to its witness's implementation
                # (TRAITS.md): an ordinary direct call, annotated.
                set impl [dict get $node traitImpl]
                set word [expr {[dict exists $impl context] ? "contexttrait" : "trait"}]
                append text " $word [dict get $impl trait].[dict get $impl requirement] witness [hir::types::show [dict get $impl witness]]"
            }
            Line $hir $e $text $indent $origins lines
            Expr $hir [dict get $node callee] $inner $origins lines
            foreach arg [dict get $node args] {
                Expr $hir $arg $inner $origins lines
            }
        }
        if {
            Line $hir $e if $indent $origins lines
            Expr $hir [dict get $node condition] $inner $origins lines
            foreach {role outcome} {then 1 else 0} {
                set s [dict get $node ${role}Scope]
                set header "[string repeat {    } $inner]$role $s"
                foreach part [list [Binds $hir $s] [Facts $hir [dict get $node refinements $outcome]]] {
                    if {$part ne ""} {
                        append header " $part"
                    }
                }
                lappend lines $header
                foreach child [dict get $node ${role}Body] {
                    Expr $hir $child [expr {$inner + 1}] $origins lines
                }
            }
        }
        loop {
            set text "loop [dict get $node bodyScope]"
            set binds [Binds $hir [dict get $node bodyScope]]
            if {$binds ne ""} {
                append text " $binds"
            }
            Line $hir $e $text $indent $origins lines
            foreach child [dict get $node body] {
                Expr $hir $child $inner $origins lines
            }
        }
        listloop {
            set text "listloop [dict get $node bodyScope]\
                ([ParamList $hir [list [dict get $node elementBinding]] {{}}])"
            set binds [Binds $hir [dict get $node bodyScope]]
            if {$binds ne ""} {
                append text " $binds"
            }
            Line $hir $e $text $indent $origins lines
            Expr $hir [dict get $node iterable] $inner $origins lines
            foreach child [dict get $node body] {
                Expr $hir $child $inner $origins lines
            }
        }
        countloop {
            set text "countloop [dict get $node bodyScope]\
                ([ParamList $hir [list [dict get $node countBinding]] {{}}])"
            if {[dict get $node direction] ne "up" || [dict get $node endKind] ne "exclusive"} {
                append text " [dict get $node direction] [dict get $node endKind]"
            }
            set binds [Binds $hir [dict get $node bodyScope]]
            if {$binds ne ""} {
                append text " $binds"
            }
            Line $hir $e $text $indent $origins lines
            Expr $hir [dict get $node start] $inner $origins lines
            Expr $hir [dict get $node end] $inner $origins lines
            foreach child [dict get $node body] {
                Expr $hir $child $inner $origins lines
            }
        }
        lockloop {
            set text "lockloop [dict get $node bodyScope]"
            foreach domain [dict get $node domains] {
                set label [ParamList $hir [list [dict get $domain binding]] {{}}]
                if {[dict get $domain kind] eq "list"} {
                    append text " ($label list)"
                } else {
                    append text " ($label count [dict get $domain direction] [dict get $domain endKind])"
                }
            }
            set binds [Binds $hir [dict get $node bodyScope]]
            if {$binds ne ""} {
                append text " $binds"
            }
            Line $hir $e $text $indent $origins lines
            foreach operand [hir::loopOperands $node] {
                Expr $hir $operand $inner $origins lines
            }
            foreach child [dict get $node body] {
                Expr $hir $child $inner $origins lines
            }
        }
        return - break - continue {
            set target [dict get $node target]
            set text "[dict get $node kind] -> [expr {$target eq "" ? "?" : $target}]"
            Line $hir $e $text $indent $origins lines
            if {[dict get $node kind] ne "continue" && [dict get $node value] ne ""} {
                Expr $hir [dict get $node value] $inner $origins lines
            }
        }
        ok - error {
            Line $hir $e [dict get $node kind] $indent $origins lines
            Expr $hir [dict get $node value] $inner $origins lines
        }
        struct {
            # "struct anon (a, b)" / "struct Person (age, name)": the named
            # struct's declaration identity or `anon`, then the field names
            # in WRITTEN order (their evaluation order); one child line per
            # field value, in that order.
            set id [dict get $node structId]
            Line $hir $e "struct [expr {[dict get $node named] && $id ne "" ? $id : "anon"}]\
                ([join [dict get $node names] {, }])" $indent $origins lines
            foreach field [dict get $node fields] {
                Expr $hir $field $inner $origins lines
            }
        }
        project {
            Line $hir $e "project [dict get $node name]" $indent $origins lines
            Expr $hir [dict get $node receiver] $inner $origins lines
        }
        fail {
            Line $hir $e "fail [dict get $node name]" $indent $origins lines
        }
        handle {
            Line $hir $e handle $indent $origins lines
            Expr $hir [dict get $node call] $inner $origins lines
            foreach name [dict get $node handlerNames] s [dict get $node handlerScopes] \
                    body [dict get $node handlerBodies] {
                set header "[string repeat {    } $inner]on $name $s"
                set binds [Binds $hir $s]
                if {$binds ne ""} {
                    append header " $binds"
                }
                lappend lines $header
                foreach child $body {
                    Expr $hir $child [expr {$inner + 1}] $origins lines
                }
            }
        }
    }
}
