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
#                                        omitted when empty; then ?nomethod?
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
        }
        bind {
            if {[dict get $node duplicate]} {
                lappend flags duplicate
            }
        }
    }
    if {![dict get $node reachable]} {
        lappend flags unreachable
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
            if {[dict exists $node requiredContexts] && [dict get $node requiredContexts] ne {}} {
                # CONTEXTS.md: the context types the block's own region loads
                # (its context parameters) and the ones it transitively
                # requires through its calls (hir/contexts.tcl).
                append text " contexts ([join [dict get $node directContexts] {, }]) requires ([join [dict get $node requiredContexts] {, }])"
            }
            if {[dict get $node declaredResult] ne {}} {
                append text [format { declares %s} [hir::types::show [dict get $node declaredResult]]]
            }
            if {[dict get $node declaredErrors] ne {}} {
                append text " errors [join [dict get $node declaredErrors] {, }]"
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
