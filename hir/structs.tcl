# structs.tcl -- struct declarations, and the static checks of struct values
# (STRUCTS.md).
#
#   hir::structs::apply DECLS       => HIR `sourceTypes` entries of the structs
#   hir::structs::lookup NAME NS    => declaration identity, or ""
#   hir::structs::names ID          => declared field names, slot order
#   hir::structs::fieldType ID NAME => the declared type of a field, or ""
#
# Vocabulary (the language's and the compiler's)
# ----------------------------------------------
#   struct          the language construct / declaration / type family
#   struct value    one concrete value
#   named struct    a nominal struct declared with `struct Name:`
#   anonymous struct  an unnamed, structurally typed struct value, `{ ... }`
#   struct field    one named member of a struct
#   field projection  `value.field`, statically resolved
#
# A named struct's identity is its *declaration identity*: the declared name
# for the entry program ("Person") and "namespace::Name" for a module's
# ("geo::Point"), so two declarations with identical fields are distinct
# types, and two modules' `Point`s never coincide (STRUCTS.md "Named nominal
# identity"). The declared schema -- field names in written order and the
# resolved type of each -- lives in this file's registry, which is how the
# pure type functions of hir/types.tcl (subtype, lub, bearing, ...) reach it
# from a type form `{nstruct ID}` without a HIR in reach. It is the same
# kind of per-compilation registry core::type's source-defined types are
# (hir/sourcetypes.tcl, "Compilation isolation"): hir::sourcetypes::apply is
# its one entry point, the struct declarations are validated and registered
# there, through the same declaration pass, in the same type namespace as
# integer-domain types (a struct never shares a name with one), and HIR keeps
# the canonical entries as its own `sourceTypes` (kind struct).
#
# A declaration is a *type* declaration, not a value binding: it introduces
# no binding, and follows the declaration-order semantics of the other type
# declarations (a struct may name a struct declared later, itself, or one in
# a cycle: a field's type is the named type, never its expansion, so
# recursion needs no special construction rule). `Name { ... }` resolves
# `Name` through this registry, never through lexical scope.
#
# Static checks (verify, below; hir/structs.tcl is HIR's one home for them)
# --------------------------------------------------------------------------
#   * every named construction provides every declared field once, none
#     undeclared (hir/resolve.tcl), and every value is *proven* admissible
#     for its declared field type: the same proof a call's argument gets for
#     a declared parameter (hir::range::ProvesValueAcceptedBy). No runtime
#     guard is ever inserted because a field type is declared.
#   * a field projection must be proven to name a field of its receiver's
#     static struct type. A receiver of type `any` is rejected -- there is no
#     dynamic lookup to fall back to -- unless the projection sits in a
#     function every call of which has a semantic instance (hir/semantic.tcl)
#     in which the receiver's struct type is known (OPPORTUNISTIC-SEMANTIC-
#     INSTANCES.md): then the definition is valid exactly for the struct
#     types its callers pass, each analyzed under its actual type.

namespace eval hir::structs {
    # ID -> {id ID name NAME namespace NS names {FIELD...} types {FIELD TYPE
    # ...} spans {FIELD SPAN ...} span SPAN}: the registry of the current
    # compilation's declarations.
    variable registry [dict create]
    # Entries of the previous compilation's registration are dropped by the
    # next apply call that brings declarations.
}

proc hir::structs::Reset {} {
    variable registry
    set registry [dict create]
}

proc hir::structs::Fail {span message} {
    core::semanticError TYPE "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# The declaration identity a struct NAME declared in module NAMESPACE (""
# for the entry program) has.
proc hir::structs::identity {name namespace} {
    return [expr {$namespace eq "" ? $name : "${namespace}::${name}"}]
}

# 1 if ID is a registered struct declaration identity.
proc hir::structs::declared {id} {
    variable registry
    return [dict exists $registry $id]
}

# The identity the struct type spelled NAME (as written: "Person", or
# "geo::Point") denotes in code of module namespace NS ("" for the entry
# program), or "". A qualified spelling is exactly one declaration; an
# unqualified one is the code's own namespace's declaration.
proc hir::structs::lookup {name {ns ""}} {
    variable registry
    if {[string first :: $name] >= 0} {
        return [expr {[dict exists $registry $name] ? $name : ""}]
    }
    set id [identity $name $ns]
    return [expr {[dict exists $registry $id] ? $id : ""}]
}

proc hir::structs::names {id} {
    variable registry
    return [dict get $registry $id names]
}

# The declared type of field NAME of struct ID, or "" if ID has no such
# field.
proc hir::structs::fieldType {id name} {
    variable registry
    if {![dict exists $registry $id]} {
        return ""
    }
    set types [dict get $registry $id types]
    return [expr {[dict exists $types $name] ? [dict get $types $name] : ""}]
}

# {FIELD TYPE ...} in declared order.
proc hir::structs::fieldTypes {id} {
    variable registry
    return [dict get $registry $id types]
}

# The source spelling of declaration identity ID (for diagnostics and show).
proc hir::structs::display {id} {
    return $id
}

# The struct declaration the expression-level name NAME could be confused
# with: a non-struct type of the same spelling, for a better diagnostic.
proc hir::structs::IsOtherType {name} {
    return [expr {[core::type::valid $name] || [dict exists $::hir::types::constructors $name]}]
}

# Validates and registers DECLS (surface/lower.tcl's StructDeclOf dicts:
# {name nameSpan namespace NS fields {{name nameSpan type typeSpan}...}}),
# after the integer-domain types of the same compilation are registered (a
# struct name may collide with none of them), resetting the previous
# compilation's registry. Returns HIR's own `sourceTypes` entries for them:
# {kind struct name NAME id ID namespace NS fields {FIELD TYPE ...}}, in
# declaration order.
proc hir::structs::apply {decls} {
    variable registry
    Reset
    set byId [dict create]
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        if {$name in {Int any never Fn} || [core::type::valid $name] || [dict exists $::hir::types::constructors $name]} {
            Fail [dict get $decl nameSpan] "\"$name\" cannot be declared as a struct: the name is already a built-in or declared type"
        }
        if {[dict exists $byId $id]} {
            Fail [dict get $decl nameSpan] "type \"$name\" is already declared"
        }
        set names {}
        set spans [dict create]
        foreach field [dict get $decl fields] {
            set fieldName [dict get $field name]
            if {$fieldName in $names} {
                Fail [dict get $field nameSpan] "duplicate field \"$fieldName\" in struct \"$name\""
            }
            lappend names $fieldName
            dict set spans $fieldName [dict get $field nameSpan]
        }
        dict set byId $id $decl
        # The skeleton first: a field type may name any struct of the batch,
        # declared earlier, later, or this one itself.
        dict set registry $id [dict create id $id name $name namespace $ns names $names \
            types {} spans $spans span [dict get $decl nameSpan]]
    }
    set entries {}
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        set types {}
        foreach field [dict get $decl fields] {
            set fieldName [dict get $field name]
            set typeExpr [dict get $field type]
            if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} resolved]} {
                Fail [dict get $field typeSpan] \
                    [format {unknown or invalid type %s for field "%s" of struct "%s": %s} \
                        [hir::resolve::ShowTypeExpr $typeExpr] $fieldName $name $resolved]
            }
            lappend types $fieldName $resolved
        }
        dict set registry $id types $types
        lappend entries [dict create kind struct name $name id $id namespace $ns fields $types]
    }
    return $entries
}

# Re-registers the struct entries of a HIR's own `sourceTypes` (hir/read.tcl:
# a serialized HIR carries its declarations as resolved types).
proc hir::structs::applyEntries {entries} {
    variable registry
    Reset
    foreach entry $entries {
        set names {}
        foreach {fieldName type} [dict get $entry fields] { lappend names $fieldName }
        dict set registry [dict get $entry id] [dict create id [dict get $entry id] \
            name [dict get $entry name] namespace [dict get $entry namespace] names $names \
            types [dict get $entry fields] spans {} span {}]
    }
}

# Adds the entries of DECLS (as apply takes them) to the registry without
# resetting it (native::prepareHir loading more modules into a program).
proc hir::structs::addDecls {decls} {
    variable registry
    set saved $registry
    set entries [apply $decls]
    foreach {id entry} $saved {
        if {![dict exists $registry $id]} {
            dict set registry $id $entry
        }
    }
    return $entries
}

# ---------------------------------------------------------------------------
# Static checks of field projection (STRUCTS.md "Field projection is static")
#
# A projection `receiver.name` is *proven* in an analysis context when the
# receiver's static type there is a struct type with a field `name`. Three
# things can be wrong, none ever a run-time event:
#
#   UNKNOWN-FIELD   the receiver is a struct type without that field
#   NOT-A-STRUCT    the receiver's type is statically some other kind
#   UNPROVEN-FIELD  the receiver's struct type is not known (`any`, a bare
#                   `struct`): there is no dynamic lookup to fall back to
#
# The first two are definitional: they hold in every context (an instance
# only ever refines the generic types, so a receiver that is a struct without
# the field, or an int, stays one). The third is the one semantic instances
# (hir/semantic.tcl) can cure: `fn first(x): x.value` has x : any in its
# generic analysis but is analyzed under the actual struct type of each exact
# call. So an unproven projection in function B's generic analysis is an error
# only if B's generic body can actually run -- B is *generically live*:
#
#   * the program's top level is live;
#   * B is live if a live context calls B without a semantic instance (the
#     call's arguments say nothing more than the generic entry types), or B's
#     value escapes (a reference that is not the callee of a call: it may be
#     called from anywhere, with anything);
#   * a live context is the generic analysis of a live block, or a semantic
#     instance some live context calls (its calls are analyzed under its own
#     concrete types).
#
# In an instance's own analysis every unproven projection is an error: that
# is where the proof must come from, reported (hir/semantic.tcl) at the call
# whose arguments made the instance invalid. No projection is ever lowered
# without a known slot, and no runtime guard or lookup exists for one that
# is not.

# "": the projection E is proven in HIR's current types; else {KIND MESSAGE}
# (KIND UNPROVEN-FIELD is the one an instance may cure).
proc hir::structs::ProjectionProblem {hir e} {
    set node [dict get $hir exprs $e]
    set receiver [dict get $node receiver]
    set type [hir::typeOf $hir $receiver]
    set name [dict get $node name]
    if {$type eq "never" || ![dict get $node reachable]} {
        return ""
    }
    if {[hir::types::IsStructLike $type]} {
        if {[hir::types::StructField $type $name] ne ""} {
            return ""
        }
        return [list UNKNOWN-FIELD [format {struct type %s has no field "%s" (known fields: %s)} \
            [hir::types::show $type] $name [join [hir::types::StructLayout $type] {, }]]]
    }
    set kind [hir::types::kindOf $type]
    if {$kind ni {"" struct}} {
        return [list NOT-A-STRUCT [format {cannot project field "%s" from a value of type %s: only a struct has fields} \
            $name [hir::types::show $type]]]
    }
    return [list UNPROVEN-FIELD [format {cannot project field "%s": the receiver's struct type is not known here (its type is %s), and a field projection is resolved statically, never looked up at run time} \
        $name [hir::types::show $type]]]
}

# Diagnoses the projection problems of every `project` in BLOCKS' own bodies
# (BLOCKS: block ExprIds and/or `program`; a nested block is its own entry).
# MODE generic: an unproven projection is reported only when its function is
# generically live (above); instance: always (hir/semantic.tcl's view of one
# instance).
proc hir::structs::verifyBlocks {hirVar blocks {mode instance}} {
    upvar 1 $hirVar hir
    set live ""
    foreach block $blocks {
        if {$block eq "program"} {
            set body [hir::roots $hir]
        } else {
            set body [dict get $hir exprs $block body]
        }
        foreach child $body {
            VerifyWalk hir $child $block $mode live
        }
    }
}

proc hir::structs::VerifyWalk {hirVar e block mode liveVar} {
    upvar 1 $hirVar hir $liveVar live
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "block"} {
        return
    }
    if {[dict get $node kind] eq "project"} {
        set problem [ProjectionProblem $hir $e]
        if {$problem ne ""} {
            lassign $problem kind message
            if {$kind ne "UNPROVEN-FIELD" || $mode ne "generic"} {
                hir::DiagnoseAt hir $kind $message $e [dict get $node nameOrigin]
            } else {
                if {$live eq ""} {
                    set live [GenericLive $hir]
                }
                if {$block eq "program" || $block in $live} {
                    hir::DiagnoseAt hir $kind $message $e [dict get $node nameOrigin]
                }
            }
        }
    }
    foreach child [hir::children $hir $e] {
        VerifyWalk hir $child $block $mode live
    }
}

# The generic verification of the whole program (hir::CheckOnce).
proc hir::structs::verify {hirVar} {
    upvar 1 $hirVar hir
    set blocks [list program]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "block"} {
            lappend blocks $e
        }
    }
    verifyBlocks hir $blocks generic
}

# The innermost block whose body CODE of expression E is in ("program" at
# the top level).
proc hir::structs::OwnerBlock {hir e} {
    set invocation [dict get $hir scopes [dict get $hir exprs $e scope] invocation]
    return [expr {$invocation eq "" ? "program" : $invocation}]
}

# The blocks whose generic analysis can actually run (see the header): a
# list of block ExprIds (`program` is always live).
proc hir::structs::GenericLive {hir} {
    # Every exact call, with its callee block and the block it is in.
    set calls {}
    set callees [dict create]
    set escapes [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {![dict get $node reachable]} continue
        if {[dict get $node kind] eq "call"} {
            dict set callees [dict get $node callee] 1
            lassign [dict get $node target] kind target
            if {$kind eq "block"} {
                lappend calls [list $e $target [OwnerBlock $hir $e]]
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {![dict get $node reachable] || [dict get $node kind] ne "ref"} continue
        if {[dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq ""} continue
        set declaration [dict get $hir bindings $b declaredBy]
        if {$declaration eq "" || ![dict exists $hir exprs $declaration]} continue
        set value [dict get $hir exprs $declaration value]
        if {[dict get $hir exprs $value kind] eq "block"} {
            dict set escapes $value 1
        }
    }
    set semanticCalls [dict create]
    set instanceBlock [dict create]
    if {[dict exists $hir semantic]} {
        set semanticCalls [dict get $hir semantic calls]
        dict for {id inst} [dict get $hir semantic instances] {
            dict set instanceBlock $id [dict get $inst block]
        }
    }
    set liveBlocks [dict create program 1]
    set liveInstances [dict create]
    dict for {block _} $escapes {
        dict set liveBlocks $block 1
    }
    set changed 1
    while {$changed} {
        set changed 0
        foreach call $calls {
            lassign $call e target owner
            set contexts {}
            if {[dict exists $liveBlocks $owner]} {
                lappend contexts generic
            }
            dict for {id block} $instanceBlock {
                if {$block eq $owner && [dict exists $liveInstances $id]} {
                    lappend contexts $id
                }
            }
            foreach context $contexts {
                set key [list $context $e]
                if {[dict exists $semanticCalls $key]} {
                    set id [dict get $semanticCalls $key]
                    if {![dict exists $liveInstances $id]} {
                        dict set liveInstances $id 1
                        set changed 1
                    }
                } elseif {![dict exists $liveBlocks $target]} {
                    dict set liveBlocks $target 1
                    set changed 1
                }
            }
        }
    }
    return [dict keys $liveBlocks]
}
