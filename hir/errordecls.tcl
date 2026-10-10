# errordecls.tcl -- source-defined named error declarations.
#
#   error BelowRange
#   error AboveRange
#
# (surface/parser.tcl's ErrorDecl grammar; surface/lower.tcl turns each into
# a plain DECL dict {name .. nameSpan ..}, never an hir/syntax.tcl node: an
# error declaration has no runtime meaning, exactly like a `type`
# declaration -- hir/sourcetypes.tcl.) EXPLICIT-ERROR-COMPLETIONS.md: two
# declared errors are different semantic identities even if their names
# happen to resemble each other (spec item 6). This file keeps that
# identity mechanism exactly as simple as source-defined *type* identity
# already is: NAME is the identity, valid and unique across one whole
# compiled program (every module section plus the top level), never
# compared by message text. Unlike a source type, no other part of the
# system (no runtime registry, no native registration) ever needs to look
# an error up outside of resolving *this* program's own HIR, so -- unlike
# hir::sourcetypes.tcl's `generation`/Reset machinery, which undoes a
# genuinely process-global core::type/core::native registration -- apply
# needs no "undo the previous batch" step: `current` is simply overwritten
# each time a program brings its own (non-empty) declarations, and a call
# with no declarations of its own (every internal re-hir::build of an
# already-resolved program: the Tcl compiler backend's own GenerateUnit,
# hir/specialize.tcl, ...) leaves the previous batch in place, exactly
# mirroring hir::sourcetypes::apply's own empty-DECLS rule and for the
# identical reason (that internal rebuild's own `fail`/`handle` nodes still
# need the original program's error names to resolve against).
#
# Same single-process, non-concurrent-compilation caveat as
# hir::sourcetypes.tcl's "Compilation isolation": `current` is one Tcl
# namespace variable, not scoped to a particular HIR object.

# Error payloads (ERROR-PAYLOADS.md)
# ---------------------------------
# A declaration may give its error a named-field payload:
#
#   error PageNotFound:
#       uri: str
#       statusCode: int
#
# The *error descriptor* of every declared error is its nominal identity
# (the name, as above) and its payload fields, in declaration order, each a
# name, a declared type (resolved in the declaring module's namespace,
# exactly as a struct field's) and its source spans; a payload-free error is
# the zero-field case of the same descriptor, never another kind of error.
# The payload's static type is the anonymous struct type of those fields
# (payloadType): a statically known named product with no source name of its
# own and no identity -- the error's identity is the name, which the payload
# never contains. Two errors with the same fields remain unrelated errors.

namespace eval hir::errordecls {
    # The ordered list of names the most recent non-empty `apply` call
    # registered (HIR's own `errorDecls` field mirrors this).
    variable current {}
    # NAME -> the payload descriptor of each payload-bearing error of that
    # registration: {names {F...} types {F T ...} raw {F TYPEEXPR ...}
    # spans {F SPAN ...} typeSpans {F SPAN ...} span DECLSPAN namespace NS}.
    # TYPES (declaration order) is filled by resolvePayloads, once the
    # program's types are registered. A payload-free error has no entry.
    variable payloads [dict create]
}

proc hir::errordecls::Fail {span message} {
    if {$span eq ""} {
        core::semanticError UNDECLARED-ERROR $message
    }
    core::semanticError UNDECLARED-ERROR \
        "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# Validates DECLS (surface/lower.tcl's ErrorDeclOf dicts -- one per `error
# NAME` declaration found, across every module section a program loads plus
# its own top level, see surface/modules.tcl), returning the ordered list
# of declared names. Duplicate names, even across module sections, are
# rejected: exactly hir::sourcetypes.tcl's own single-flat-namespace rule
# for source-defined types.
proc hir::errordecls::apply {decls} {
    variable current
    variable payloads
    if {$decls eq {}} {
        return $current
    }
    set seen [dict create]
    set order {}
    set described [dict create]
    foreach decl $decls {
        set name [dict get $decl name]
        if {[core::native::isBuiltinError $name]} {
            Fail [dict get $decl nameSpan] "error \"$name\" is already declared (a builtin error of the runtime)"
        }
        if {[dict exists $seen $name]} {
            Fail [dict get $decl nameSpan] "error \"$name\" is already declared[hir::sourcetypes::ElsewhereClause [dict get $seen $name] [dict get $decl nameSpan]]"
        }
        dict set seen $name [dict get $decl nameSpan]
        lappend order $name
        set fields [expr {[dict exists $decl fields] ? [dict get $decl fields] : {}}]
        if {$fields eq {}} continue
        set names {}
        set raw {}
        set spans {}
        set typeSpans {}
        foreach field $fields {
            set fieldName [dict get $field name]
            if {$fieldName in $names} {
                core::semanticError DUPLICATE-FIELD \
                    "[Location [dict get $field nameSpan]]duplicate field \"$fieldName\" in the payload of error \"$name\": each payload field is declared once"
            }
            lappend names $fieldName
            lappend raw $fieldName [dict get $field type]
            lappend spans $fieldName [dict get $field nameSpan]
            lappend typeSpans $fieldName [dict get $field typeSpan]
        }
        dict set described $name [dict create names $names types {} raw $raw spans $spans \
            typeSpans $typeSpans span [dict get $decl nameSpan] \
            namespace [expr {[dict exists $decl namespace] ? [dict get $decl namespace] : ""}]]
    }
    set current $order
    set payloads $described
    return $order
}

# "FILE:LINE:COLUMN: " of SPAN ("" for none).
proc hir::errordecls::Location {span} {
    if {$span eq ""} {
        return ""
    }
    return "[dict get $span file]:[dict get $span line]:[dict get $span column]: "
}

# Resolves the declared type of every payload field of the current
# registration (ERROR-PAYLOADS.md), in the namespace of the module that
# declares the error -- once the program's own types (structs, enums,
# integer domains) are registered (hir::BuildOnce). A field type is what a
# struct field's may be: any declarable type, never a trait (a payload stores
# one concrete representation).
proc hir::errordecls::resolvePayloads {} {
    variable payloads
    dict for {name entry} $payloads {
        set ns [dict get $entry namespace]
        set types {}
        foreach {fieldName typeExpr} [dict get $entry raw] {
            set typeSpan [dict get $entry typeSpans $fieldName]
            if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} resolved options]} {
                core::semanticError [hir::resolve::TypeErrorKind $options TYPE] \
                    "[Location $typeSpan][format {unknown or invalid type %s for payload field "%s" of error "%s": %s} \
                        [hir::resolve::ShowTypeExpr $typeExpr] $fieldName $name $resolved]"
            }
            if {[hir::types::MentionedContextTrait $resolved] ne ""} {
                core::semanticError CONTEXT-TRAIT-POSITION "[Location $typeSpan][hir::types::ContextTraitPositionMessage \
                    [hir::types::MentionedContextTrait $resolved] "the type of payload field \"$fieldName\" of error \"$name\""]"
            }
            if {[hir::types::MentionsTrait $resolved]} {
                core::semanticError TRAIT-STORAGE-UNSUPPORTED "[Location $typeSpan][format \
                    {payload field "%s" of error "%s" cannot have trait type %s: a payload stores one concrete representation, and there is no erased or heterogeneous trait representation (store a concrete type)} \
                    $fieldName $name [hir::types::show $resolved]]"
            }
            lappend types $fieldName $resolved
        }
        dict set payloads $name types $types
    }
}

# Re-registers the payload descriptors ENTRIES of a HIR's own
# `errorPayloads` (NAME -> {fields {F T ...} namespace NS}, resolved types:
# hir/read.tcl, a serialized HIR), for the error names NAMES.
proc hir::errordecls::applyEntries {names entries} {
    variable current
    variable payloads
    set current $names
    set payloads [dict create]
    dict for {name entry} $entries {
        set fieldNames {}
        set spans {}
        foreach {fieldName type} [dict get $entry fields] {
            lappend fieldNames $fieldName
            dict set spans $fieldName ""
        }
        dict set payloads $name [dict create names $fieldNames types [dict get $entry fields] raw {} \
            spans $spans typeSpans $spans span "" \
            namespace [expr {[dict exists $entry namespace] ? [dict get $entry namespace] : ""}]]
    }
}

# 1 if error NAME declares a payload (at least one field).
proc hir::errordecls::hasPayload {name} {
    variable payloads
    return [dict exists $payloads $name]
}

# The payload fields of error NAME, {FIELD TYPE ...} in declaration order
# ({} for a payload-free or unknown error).
proc hir::errordecls::fields {name} {
    variable payloads
    if {![dict exists $payloads $name]} {
        return {}
    }
    return [dict get $payloads $name types]
}

# The payload field names of error NAME, in declaration order.
proc hir::errordecls::fieldNames {name} {
    variable payloads
    if {![dict exists $payloads $name]} {
        return {}
    }
    return [dict get $payloads $name names]
}

# The declared type of payload field FIELD of error NAME, or "".
proc hir::errordecls::fieldType {name field} {
    set types [fields $name]
    return [expr {[dict exists $types $field] ? [dict get $types $field] : ""}]
}

# The static type of error NAME's payload: the anonymous struct type of its
# declared fields ({struct {FIELD TYPE ...}}, fields sorted -- the canonical
# anonymous struct form, hir::types::MakeStruct's), or "" for a payload-free
# error. Never a named type: the payload has no source name and no identity.
proc hir::errordecls::payloadType {name} {
    set types [fields $name]
    if {$types eq {}} {
        return ""
    }
    set canonical {}
    foreach field [lsort [dict keys $types]] {
        lappend canonical $field [dict get $types $field]
    }
    return [list struct $canonical]
}

# HIR's `errorPayloads` entries of the current registration: NAME ->
# {fields {F T ...} namespace NS}, for every payload-bearing error, in
# declaration order (hir/format.tcl prints them, hir/read.tcl re-registers).
proc hir::errordecls::entries {} {
    variable payloads
    set result [dict create]
    dict for {name entry} $payloads {
        dict set result $name [dict create fields [dict get $entry types] namespace [dict get $entry namespace]]
    }
    return $result
}

# 1 if NAME is a declared error identity of the program currently being
# built (the most recent non-empty `apply` call), or a builtin error the
# runtime declares (core::native::declareError: InvalidArgumentEncoding, the
# error of `argv`) -- those are visible in every program, are never part of
# its own `errorDecls`, and cannot be redeclared.
proc hir::errordecls::isDeclared {name} {
    variable current
    return [expr {$name in $current || [core::native::isBuiltinError $name]}]
}
