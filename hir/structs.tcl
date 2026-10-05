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
# Representation authority (OPAQUE-STRUCTS.md)
# ---------------------------------------------
# A struct declared `opaque struct Name:` is an ordinary named struct whose
# representation belongs to the module that declares it: only code of that
# module (its *owner*: the declaring namespace, which is already the
# registry's `namespace`, "" for an entry program) may construct it from its
# fields or inspect its fields. The registry records `opaque` per declaration;
# nothing else about an opaque struct differs (identity, type algebra,
# equality, hashing, optimization). Authority is decided at the source
# semantic boundary, from three things: the declaration's owner, the namespace
# of the code performing the operation, and, for a projection, the receiver's
# static type. A construction is decided when it is resolved
# (hir/resolve.tcl's ResolveStruct knows its code's namespace); a projection
# only once types are known, so hir/resolve.tcl stamps every `project` node and
# method-call record with the namespace of its code (`ns`). A node carrying no
# `ns` (core IR, serialized HIR: already past the source boundary) is trusted.
# No `ns` or opacity is consulted after HIR is checked: the analyses, the
# interpreter, the compiler and native lowering see ordinary construct/project
# operations.
#
#   OPAQUE-CONSTRUCTION   `NS::Name { ... }` outside the owner (resolve time;
#                         no field-level diagnostic is ever given for it)
#   OPAQUE-REPRESENTATION a projection of any field name (so also a
#                         destructuring, which lowers to projections, and the
#                         callee of a field-value call) outside the owner,
#                         whether or not the field exists
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
    # ID -> {id ID name NAME namespace NS opaque 0|1 names {FIELD...} types
    # {FIELD TYPE ...} spans {FIELD SPAN ...} span SPAN}: the registry of the
    # current compilation's declarations. `namespace` is the declaring module
    # and, for an opaque struct, the owner of its representation.
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

# 1 if struct ID was declared `opaque struct`.
proc hir::structs::isOpaque {id} {
    variable registry
    return [expr {[dict exists $registry $id opaque] && [dict get $registry $id opaque]}]
}

# The namespace ("" for an entry program) that owns the representation of
# struct ID: the module that declares it.
proc hir::structs::owner {id} {
    variable registry
    return [dict get $registry $id namespace]
}

# 1 if code of namespace NS ("" for the entry program) lacks authority over
# the representation of struct ID: the struct is opaque and NS is not its
# declaring module. Authority is exact -- no import, parent, child or
# containing struct ever grants it.
proc hir::structs::representationDenied {id ns} {
    return [expr {[isOpaque $id] && [owner $id] ne $ns}]
}

# "module \"token\"" / "the entry program": the owner of struct ID in prose.
proc hir::structs::OwnerPhrase {id} {
    set owner [owner $id]
    return [expr {$owner eq "" ? "the entry program" : "module \"$owner\""}]
}

# "that module" / "the entry program": the owner as a back-reference.
proc hir::structs::OwnerRef {id} {
    return [expr {[owner $id] eq "" ? "the entry program" : "that module"}]
}

# The message of OPAQUE-CONSTRUCTION for struct ID. It names the type and its
# owner, never a field.
proc hir::structs::ConstructionMessage {id} {
    return [::format {%s has an opaque representation owned by %s; construct it through the public operations provided by %s} \
        [display $id] [OwnerPhrase $id] [OwnerRef $id]]
}

# The message of OPAQUE-REPRESENTATION for struct ID. It does not depend on
# the field named, so it cannot be used to discover which fields exist.
proc hir::structs::RepresentationMessage {id} {
    return [::format {field access on %s is not available outside %s; %s has an opaque representation, so its fields can be neither projected nor destructured here (use the public operations provided by %s)} \
        [display $id] [OwnerPhrase $id] [display $id] [OwnerRef $id]]
}

# Moves the representation-authority diagnostics (OPAQUE-CONSTRUCTION,
# OPAQUE-REPRESENTATION) ahead of the others, keeping every relative order:
# they are the root cause of whatever follows from a rejected access (the
# rejected access is typed as an unknown field is, so a later check may report
# a consequence of that), and the first diagnostic is the one a strict compile
# raises. A HIR without one is left exactly as it is.
proc hir::structs::promoteOpacity {hirVar} {
    upvar 1 $hirVar hir
    set opaque {}
    set rest {}
    foreach d [dict get $hir diagnostics] {
        if {[dict get $d kind] in {OPAQUE-CONSTRUCTION OPAQUE-REPRESENTATION}} {
            lappend opaque $d
        } else {
            lappend rest $d
        }
    }
    if {$opaque ne "" && $rest ne ""} {
        dict set hir diagnostics [concat $opaque $rest]
    }
}

# 1 if NODE (a `project` node, or a method-call receiver's context) performs
# its field access without authority over TYPE, a receiver type: TYPE is a
# named opaque struct whose owner is not the namespace NODE's code is in. A
# node without an `ns` stamp is trusted (see the file header). Never consulted
# for a type that is not a named struct.
proc hir::structs::projectionDenied {type node} {
    if {![hir::types::IsNamedStruct $type] || ![dict exists $node ns]} {
        return 0
    }
    set id [lindex $type 1]
    return [expr {[declared $id] && [representationDenied $id [dict get $node ns]]}]
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
# {kind struct name NAME id ID namespace NS opaque 0|1 fields {FIELD TYPE ...}},
# in declaration order.
proc hir::structs::apply {decls} {
    variable registry
    Reset
    set byId [dict create]
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        if {$name in {Int any never Fn} || [core::type::isBuiltinName $name] || [core::type::valid $id]
                || [dict exists $::hir::types::constructors $name]} {
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
        dict set registry $id [dict create id $id name $name namespace $ns \
            opaque [expr {[dict exists $decl opaque] && [dict get $decl opaque]}] names $names \
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
        lappend entries [dict create kind struct name $name id $id namespace $ns \
            opaque [dict get $registry $id opaque] fields $types]
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
            name [dict get $entry name] namespace [dict get $entry namespace] \
            opaque [expr {[dict exists $entry opaque] && [dict get $entry opaque]}] names $names \
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
    set hint [expr {[dict exists $node methodCallee] ? [MethodHint $name] : ""}]
    if {[projectionDenied $type $node]} {
        # The receiver is an opaque struct and this code is not its owner
        # (OPAQUE-STRUCTS.md): whatever the field is called, the access needs
        # the representation. The same message for a field that exists and
        # for one that does not, and no field named or listed.
        return [list OPAQUE-REPRESENTATION "[RepresentationMessage [lindex $type 1]]$hint"]
    }
    if {[hir::types::IsStructLike $type]} {
        if {[hir::types::StructField $type $name] ne ""} {
            return ""
        }
        return [list UNKNOWN-FIELD [format {struct type %s has no field "%s" (known fields: %s)%s} \
            [hir::types::show $type] $name [join [hir::types::StructLayout $type] {, }] $hint]]
    }
    set kind [hir::types::kindOf $type]
    if {$kind ni {"" struct}} {
        return [list NOT-A-STRUCT [format {cannot project field "%s" from a value of type %s: only a struct has fields%s} \
            $name [hir::types::show $type] $hint]]
    }
    return [list UNPROVEN-FIELD [format {cannot project field "%s": the receiver's struct type is not known here (its type is %s), and a field projection is resolved statically, never looked up at run time%s} \
        $name [hir::types::show $type] $hint]]
}

# What a projection problem adds when the projection is the callee of a
# method-style call `receiver.NAME(args)` that found no function NAME to
# apply (METHOD-SUGAR.md): the call is then a call of the field NAME, and the
# programmer may have meant the function spelling, which needs a function
# visible under that name here: one defined or bound in this file, or a member
# of a namespace this file directly imports (`import list` makes `list::at`
# a candidate for `xs.at(i)`; there is no search by receiver type).
proc hir::structs::MethodHint {name} {
    set hint [::format {; as a method-style call, no function named "%s" is visible here either: method syntax only applies a function that is already visible by that name (define it here, or import the namespace that defines it with `import NAMESPACE`)} \
        $name]
    # Cheap and deterministic: the intrinsics of that name (never a search of
    # modules, which are only known once imported).
    set owners {}
    foreach native [core::native::names] {
        if {![core::native::isQualifiedNative $native]} continue
        set i [string last :: $native]
        if {[string range $native [expr {$i + 2}] end] eq $name} {
            lappend owners [string range $native 0 [expr {$i - 1}]]
        }
    }
    if {$owners ne ""} {
        append hint [::format { -- `%s` exist%s: add %s} \
            [join [lmap o [lsort $owners] {string cat $o :: $name}] {`, `}] \
            [expr {[llength $owners] == 1 ? "s" : ""}] \
            [join [lmap o [lsort $owners] {string cat "`import " $o "`"}] { or }]]
    }
    return $hint
}

# Diagnoses the projection problems among the expressions EXPRS (an instance's
# region, hir/semantic.tcl): an unproven projection is always reported, since
# that is where an instance's proof has to come from. A flat scan: a struct
# program's projections are found by kind, never by walking the whole tree.
proc hir::structs::verifyExprs {hirVar exprs} {
    upvar 1 $hirVar hir
    foreach e $exprs {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] eq "call" && [dict exists $node method]} {
            # The instance knows the receiver's concrete type: a field the
            # generic analysis could not see may compete with the function.
            set problem [AmbiguousMethodCall $hir $e]
            if {$problem ne ""} {
                hir::DiagnoseAt hir AMBIGUOUS-METHOD-CALL $problem $e [dict get $node method nameOrigin]
            }
            continue
        }
        if {[dict get $node kind] ne "project"} continue
        set problem [ProjectionProblem $hir $e]
        if {$problem ne ""} {
            lassign $problem kind message
            hir::DiagnoseAt hir $kind $message $e [dict get $node nameOrigin]
        }
    }
}

# The generic verification of the whole program (hir::CheckOnce): every
# projection, found by a flat scan of the expression table. An unproven one is
# reported only when its function is generically live (above).
proc hir::structs::verify {hirVar} {
    upvar 1 $hirVar hir
    set live ""
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call" && [dict exists $node method]} {
            set problem [AmbiguousMethodCall $hir $e]
            if {$problem ne ""} {
                hir::DiagnoseAt hir AMBIGUOUS-METHOD-CALL $problem $e [dict get $node method nameOrigin]
            }
            continue
        }
        if {[dict get $node kind] ne "project"} continue
        set problem [ProjectionProblem $hir $e]
        if {$problem eq ""} continue
        lassign $problem kind message
        if {$kind eq "UNPROVEN-FIELD"} {
            if {$live eq ""} {
                set live [GenericLive $hir]
            }
            set owner [OwnerBlock $hir $e]
            if {$owner ne "program" && $owner ni $live} continue
        }
        hir::DiagnoseAt hir $kind $message $e [dict get $node nameOrigin]
    }
}

# "": the method-style call E (a call carrying `method`, i.e. written
# `receiver.NAME(args)` with a function NAME visible: METHOD-SUGAR.md) has
# exactly one meaning; else the message of its AMBIGUOUS-METHOD-CALL.
#
# The written form already meant something before the sugar existed: call the
# value of field NAME. When the receiver's static type is a struct with a
# field NAME that could hold a callable (anything not statically some other
# kind of value), both the field's value and the visible function are
# candidates for the one callee, and Botlish picks neither: the programmer
# writes `(receiver.NAME)(args)` for the field or `NAME(receiver, args)` for
# the function. A field statically of another kind (an Int, a String, ...)
# could never be called, so the function is the only candidate. A receiver
# whose struct type is not known here has no field the generic analysis can
# see; the call is the function call there, and a semantic instance
# (verifyExprs), which does know the receiver's concrete type, diagnoses the
# same ambiguity at the call that made the instance.
proc hir::structs::AmbiguousMethodCall {hir e} {
    set node [dict get $hir exprs $e]
    if {![dict get $node reachable]} {
        return ""
    }
    set receiver [lindex [dict get $node args] 0]
    set type [hir::typeOf $hir $receiver]
    if {$type eq "never" || ![hir::types::IsStructLike $type]} {
        return ""
    }
    set name [dict get $node method name]
    if {![FieldCompetes $type $name [dict get $node method]]} {
        return ""
    }
    return [format {method-style call "%s" is ambiguous: the receiver (type %s) has a field "%s" whose value may be callable, and a function "%s" is also visible here; write (receiver.%s)(...) to call the field, or %s(receiver, ...) to call the function} \
        $name [hir::types::show $type] $name $name $name $name]
}

# 1 if a receiver of the struct type TYPE (a struct-like type) has a field NAME
# that could compete with a visible function NAME for `receiver.NAME(args)`:
# the field exists, is visible to the code the call is in (CONTEXT carries its
# `ns`; an opaque struct's fields are not source-visible outside its owner,
# OPAQUE-STRUCTS.md, so they are not method candidates and cannot make the
# call ambiguous) and its value may be callable (anything not statically some
# other kind of value). The one rule of the field/function ambiguity above;
# the METHOD-ELIGIBLE warning (hir/warnings.tcl) asks it of the sugared
# spelling it would suggest.
proc hir::structs::FieldCompetes {type name context} {
    if {[projectionDenied $type $context]} {
        return 0
    }
    if {$name ni [hir::types::StructLayout $type]} {
        return 0
    }
    set fieldType [hir::types::StructField $type $name]
    return [expr {[hir::types::IsCallable $fieldType] || [hir::types::kindOf $fieldType] in {"" any block native}}]
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

# The value printer (core/value.tcl) renders a value of an opaque struct by its
# nominal type only; whether an identity is opaque is this registry's
# knowledge (OPAQUE-STRUCTS.md).
core::value::setOpaqueStructTest hir::structs::isOpaque
