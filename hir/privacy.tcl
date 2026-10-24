# privacy.tcl -- module-local declarations: `private`
# (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md).
#
#   hir::privacy::Entry DECLS NS CATEGORY NAME     the private entry, or ""
#   hir::privacy::Denied DECLS NS CATEGORY NAME FROM   1: no access from FROM
#   hir::privacy::verify HIRVAR                    PRIVATE-TYPE-ESCAPE, part of
#                                                  hir::CheckOnce
#
# `private` determines who may access a declaration; `opaque` who may
# inspect a representation (OPAQUE-STRUCTS.md). A declaration written
# `private` -- a function, a module binding, a type, an error, a struct, an
# enum, a trait, a layout, an extern c fn -- may be named and used by code
# of the module that declares it, and by no other code: not by an importer,
# a parent or child namespace, the entry program, method syntax, or a trait
# or context trait of another module looking for an implementation. Every
# other declaration is public, as every declaration was before.
#
# The one fact. The loader records each unit's private declarations in its
# module declaration (surface/modules.tcl's ModuleDecl), which HIR keeps as
# `moduleDecls` (hir/hir.tcl):
#
#   NS -> {direct 0|1 origin ORIGIN private {CATEGORY {NAME {kind KIND
#          origin ORIGIN} ...} ...}}
#
# CATEGORY is the member namespace the declaration's name is in: `values`
# (functions, module bindings, extern c fns), `types` (structs, types,
# enums, traits, layouts) or `errors`; KIND the declaration's AST kind and
# ORIGIN its name's. Every check reads it through Entry and Denied: the
# loader's qualified references (CheckRef) and type imports (CheckImports),
# method candidates (hir::resolve::MethodCandidates), qualified references
# HIR resolution makes itself (ResolveQualifiedRef), field access through a
# value of a private struct or layout (hir::structs::ProjectionProblem),
# and conformance of traits and context traits (hir::traits::Implementation,
# hir::contexts::TraitImplementation). Access is decided by the canonical
# module identity -- the unit's namespace, "" for the entry program --
# never by a spelling, an alias or a file. No runtime representation: the
# fact lives in HIR, never in a registry or a lowered program.
#
# Public signatures (verify). A public declaration may not expose a private
# type or error to the code that may use it: PRIVATE-TYPE-ESCAPE, at the
# declaration, for a private nominal type (struct, enum, trait, layout,
# source-defined type) or error found in
#
#   a function's  declared parameter types, declared or inferred result,
#                 context requirements (declared or inferred: a caller has
#                 to install them), declared errors and proof clause
#   a binding's   inferred type
#   a struct's    field types (unless it is opaque: hidden representation is
#                 no public API) and type slots' traits
#   an error's    payload field types
#   a trait's     requirements' parameter, result and error types
#   a layout's    field types
#   a refinement's carrier, an extern c fn's C types
#
# searched through every applied, collection, callable and C type, but not
# into another public nominal declaration (its own declaration is checked
# where it is). A private declaration may expose anything: it is the
# module's own.

namespace eval hir::privacy {
    # The member namespace (CATEGORY) of each kind of declaration.
    variable categories {
        function values bind values externfn values hole values
        typedecl types structdecl types enumdecl types traitdecl types layoutdecl types
        errordecl errors
    }
}

# The category of declaration kind KIND (an AST node kind).
proc hir::privacy::Category {kind} {
    variable categories
    return [dict get $categories $kind]
}

# The private entry ({kind KIND origin ORIGIN}) of member NAME of CATEGORY in
# unit NS ("" for the entry program), in the module declarations DECLS
# (moduleDecls), or "" when the member is public or not a source member.
proc hir::privacy::Entry {decls ns category name} {
    if {[dict exists $decls $ns private $category $name]} {
        return [dict get $decls $ns private $category $name]
    }
    return ""
}

# 1 if code of unit FROM may not access member NAME of CATEGORY of unit NS:
# the member is private and FROM is another unit. The access rule, once.
proc hir::privacy::Denied {decls ns category name from} {
    return [expr {$from ne $ns && [Entry $decls $ns $category $name] ne ""}]
}

# The module declarations of HIR ({} past the source boundary).
proc hir::privacy::Decls {hir} {
    return [dict getdef $hir moduleDecls {}]
}

# {NS NAME CATEGORY} of the nominal identity ID of a type of category KIND
# (struct, enum, trait, layout, type, error): its declaring unit and its
# name there. A layout's struct view (LayoutStruct[L]) is the layout's.
proc hir::privacy::Member {id} {
    if {[regexp {^LayoutStruct\[(.*)\]$} $id -> layout]} {
        set id $layout
    }
    set cut [string last :: $id]
    if {$cut < 0} {
        return [list "" $id]
    }
    return [list [string range $id 0 [expr {$cut - 1}]] [string range $id [expr {$cut + 2}] end]]
}

# The private entry of the nominal identity ID of CATEGORY (types or
# errors), or "".
proc hir::privacy::NominalEntry {decls id category} {
    lassign [Member $id] ns name
    return [Entry $decls $ns $category $name]
}

# "module \"NS\"" or "the entry program".
proc hir::privacy::UnitPhrase {ns} {
    return [expr {$ns eq "" ? "the entry program" : "module \"$ns\""}]
}

# The word a private declaration of KIND is called in a message.
proc hir::privacy::KindWord {kind} {
    return [dict getdef {function function bind binding externfn "extern c fn" hole declaration
        typedecl type structdecl struct enumdecl enum traitdecl trait layoutdecl layout
        errordecl error} $kind declaration]
}

# PRIVATE-ACCESS's message: code of unit FROM names member NAME (KIND, as
# the private entry records it) of unit NS.
proc hir::privacy::AccessMessage {ns name kind from} {
    set qualified [if {$ns eq ""} {set name} else {string cat ${ns}:: $name}]
    return [format {%s is private to %s and cannot be accessed from %s: a private %s is accessible only to code of the module that declares it} \
        $qualified [UnitPhrase $ns] [UnitPhrase $from] [KindWord $kind]]
}

# 1 if binding B is a top-level member of its unit (a module section's or
# the entry program's) declared `private` there: what tooling shows beside
# a declaration (the compiler service's hover).
proc hir::privacy::BindingPrivate {hir b} {
    set scope [dict get $hir bindings $b scope]
    set unit ""
    if {$scope ne [dict get $hir top]} {
        set unit [lindex [dict keys [dict filter [dict getdef $hir modules {}] value $scope]] 0]
        if {$unit eq ""} {
            return 0
        }
    }
    set name [namespace tail [hir::semantic::SourceName $hir $b]]
    return [expr {[Entry [Decls $hir] $unit values $name] ne ""}]
}

# ORIGIN of the source span SPAN ({file PATH start ...}) of a file of HIR,
# for a diagnostic located at a declaration the registries record by span;
# "" when SPAN is no source span of HIR's files.
proc hir::privacy::SpanOrigin {hir span} {
    if {$span eq "" || ![dict exists $span file]} {
        return ""
    }
    dict for {f entry} [dict getdef $hir files {}] {
        if {[dict get $entry path] eq [dict get $span file]} {
            set origin [list file $f node declaration]
            foreach key {start end line column endLine endColumn} {
                lappend origin $key [dict get $span $key]
            }
            return $origin
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# PRIVATE-TYPE-ESCAPE

# The first private nominal type or error found in TYPE (a HIR type form),
# searched through every type it is made of but never into the fields of a
# nominal type: {ID CATEGORY}, or "". DECLS as Entry's.
proc hir::privacy::Find {decls type} {
    if {[llength $type] < 2} {
        return ""
    }
    set head [lindex $type 0]
    switch -- $head {
        nstruct {
            set id [lindex $type 1]
            if {[NominalEntry $decls $id types] ne ""} {
                return [list $id types]
            }
            foreach arg [lindex $type 2] {
                set found [Find $decls $arg]
                if {$found ne ""} { return $found }
            }
            return ""
        }
        enum - nview - nedit {
            set id [lindex $type 1]
            if {[llength $id] == 1 && [NominalEntry $decls $id types] ne ""} {
                return [list $id types]
            }
            if {[llength $id] > 1} {
                # A fixed array representation (FIXED-LAYOUT-ARRAYS.md):
                # its element.
                return [Find $decls [lindex $id end]]
            }
            return ""
        }
        array {
            return [Find $decls [lindex $type end]]
        }
        trait {
            set id [lindex $type 1]
            if {[NominalEntry $decls $id types] ne ""} {
                return [list $id types]
            }
            return ""
        }
        imprint {
            foreach id [lindex $type 2] {
                if {[NominalEntry $decls $id types] ne ""} {
                    return [list $id types]
                }
            }
            return ""
        }
        refined {
            foreach id [lindex $type 2] {
                if {[NominalEntry $decls $id types] ne ""} {
                    return [list $id types]
                }
            }
            return [Find $decls [lindex $type 1]]
        }
        struct {
            foreach {name t} [lindex $type 1] {
                set found [Find $decls $t]
                if {$found ne ""} { return $found }
            }
            return ""
        }
        list - immutableSet - mutarray - mutvec - cptr {
            set found [Find $decls [lindex $type 1]]
            if {$found ne ""} { return $found }
            foreach t [lindex $type 2] {
                set found [Find $decls $t]
                if {$found ne ""} { return $found }
            }
            return ""
        }
        srefined {
            return [Find $decls [hir::refinements::Base $type]]
        }
        fn - coroutine {
            return [FindContract $decls [lindex $type 1]]
        }
        cfnptr {
            return [Find $decls [lindex $type 1]]
        }
        block {
            # {block E ARITY RESULT ?CONTRACT?}: what calling it returns,
            # takes and lets escape.
            set found [Find $decls [lindex $type 3]]
            if {$found ne "" || [llength $type] < 5} {
                return $found
            }
            set contract [lindex $type 4]
            foreach t [dict getdef $contract args {}] {
                set found [Find $decls $t]
                if {$found ne ""} { return $found }
            }
            return [FindErrors $decls [dict getdef $contract errors {}]]
        }
    }
    return ""
}

# Find over a callable contract {args {T ...} return R errors {E ...}}.
proc hir::privacy::FindContract {decls contract} {
    foreach t [dict getdef $contract args {}] {
        set found [Find $decls $t]
        if {$found ne ""} { return $found }
    }
    set found [Find $decls [dict getdef $contract return any]]
    if {$found ne ""} {
        return $found
    }
    return [FindErrors $decls [dict getdef $contract errors {}]]
}

# The first private error among the canonical error identities ERRORS.
proc hir::privacy::FindErrors {decls errors} {
    foreach id $errors {
        if {[NominalEntry $decls $id errors] ne ""} {
            return [list $id errors]
        }
    }
    return ""
}

# "private type m::S" / "private error m::E" for Find's result FOUND.
proc hir::privacy::FoundPhrase {found} {
    lassign $found id category
    return "private [expr {$category eq "errors" ? "error" : "type"}] $id"
}

# Diagnoses PRIVATE-TYPE-ESCAPE: the public declaration WHAT (its kind and
# qualified name, "function m::handles") exposes FOUND (Find's) in WHERE ("its
# result"), located at ORIGIN (expression E anchors it, "" for none).
proc hir::privacy::Escape {hirVar what found where e origin} {
    upvar 1 $hirVar hir
    set name [lindex [split $what] end]
    lassign [Member [lindex $found 0]] ns
    hir::DiagnoseAt hir PRIVATE-TYPE-ESCAPE \
        [format {public %s exposes %s in %s: every module may use %s, but only %s may use %s (make %s private too, or keep %s out of its public interface -- an opaque struct may hold it as hidden representation)} \
            $what [FoundPhrase $found] $where $name [UnitPhrase $ns] [lindex $found 0] $name [lindex $found 0]] \
        $e $origin
}

proc hir::privacy::verify {hirVar} {
    upvar 1 $hirVar hir
    if {![dict exists $hir moduleDecls] || [hir::mode $hir] ne "program"} {
        # Past the source boundary: no module declarations.
        return
    }
    if {[hir::traits::Planning] || [dict exists $hir traitSource]} {
        # The monomorphized program: judged as written (hir/direct.tcl).
        return
    }
    set decls [dict get $hir moduleDecls]
    set any 0
    dict for {ns decl} $decls {
        if {[dict exists $decl private types] || [dict exists $decl private errors]} {
            set any 1
        }
    }
    if {!$any} {
        # No private type or error anywhere: nothing can escape.
        return
    }
    dict for {unit scope} [dict getdef $hir modules {}] {
        if {![dict exists $decls $unit]} continue
        foreach b [dict get $hir scopes $scope bindings] {
            CheckBinding hir $decls $unit $b
        }
    }
    foreach entry [dict get $hir sourceTypes] {
        CheckSourceType hir $decls $entry
    }
    foreach {id fields spans} [hir::errordecls::PayloadTypes] {
        lassign [Member $id] ns name
        if {![Judged $decls $ns] || [Entry $decls $ns errors $name] ne ""} continue
        foreach {field t} $fields {
            set found [Find $decls $t]
            if {$found ne ""} {
                Escape hir "error $id" $found "its payload field \"$field\"" "" \
                    [Located $hir [dict getdef $spans $field ""] $decls $ns errors $name]
                break
            }
        }
    }
    foreach entry [dict getdef $hir traits {}] {
        CheckTrait hir $decls $entry
    }
    dict for {key entry} [dict getdef $hir foreign {}] {
        set ns [dict get $entry namespace]
        if {![Judged $decls $ns] || [Entry $decls $ns values [dict get $entry name]] ne ""} continue
        set contract [dict get $entry contract]
        set types [lmap p [dict get $contract params] {dict get $p type}]
        lappend types [dict get $contract result]
        foreach t $types {
            set found [Find $decls $t]
            if {$found ne ""} {
                Escape hir "extern c fn $key" $found "its C signature" "" [dict get $entry origin]
                break
            }
        }
    }
}

# A public top-level binding B of unit UNIT: a function's interface, or a
# module binding's type.
proc hir::privacy::CheckBinding {hirVar decls unit b} {
    upvar 1 $hirVar hir
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "root" || [dict exists $binding extern]} {
        # (An extern c fn's binding: its C signature, below.)
        return
    }
    set source [hir::semantic::SourceName $hir $b]
    set name [namespace tail $source]
    if {[Entry $decls $unit values $name] ne ""} {
        return
    }
    set by [dict get $binding declaredBy]
    if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"} {
        return
    }
    set value [dict get $hir exprs $by value]
    if {[dict get $hir exprs $value kind] ne "block"} {
        set found [Find $decls [hir::bindingType $hir $b]]
        if {$found ne ""} {
            Escape hir "binding $source" $found "its type" $by [dict get $binding origin]
        }
        return
    }
    set node [dict get $hir exprs $value]
    set what "function $source"
    set origin [dict get $binding origin]
    set i 0
    foreach p [dict get $node params] t [dict getdef $node declaredParamTypes {}] {
        incr i
        if {$t eq {}} continue
        set found [Find $decls $t]
        if {$found ne ""} {
            Escape hir $what $found "its parameter \"[hir::semantic::SourceName $hir $p]\"" $value $origin
            return
        }
    }
    set result [dict getdef $node declaredResult {}]
    set how "its result"
    if {$result eq {} && [dict exists $node resultType] && [dict get $node resultType] ne ""} {
        set result [hir::type $hir [dict get $node resultType]]
        set how "its inferred result"
    }
    if {$result ne {}} {
        set found [Find $decls $result]
        if {$found ne ""} {
            Escape hir $what $found $how $value $origin
            return
        }
    }
    set found [FindErrors $decls [dict getdef $node declaredErrors {}]]
    if {$found ne ""} {
        Escape hir $what $found "its errors" $value $origin
        return
    }
    foreach clause [dict getdef $node proofs {}] {
        if {[dict exists $clause type]} {
            set found [Find $decls [dict get $clause type]]
            if {$found ne ""} {
                Escape hir $what $found "its proof clause" $value $origin
                return
            }
        }
    }
    # Its context requirements, declared or inferred: every caller must have
    # them installed, which takes naming them.
    foreach id [dict getdef $node requiredContexts {}] {
        if {[NominalEntry $decls $id types] ne ""} {
            Escape hir $what [list $id types] "its context requirement" $value $origin
            return
        }
    }
}

# One entry of HIR's `sourceTypes`: a public struct's fields (unless opaque)
# and slot traits, a public layout's fields, a public refinement's carrier.
proc hir::privacy::CheckSourceType {hirVar decls entry} {
    upvar 1 $hirVar hir
    switch -- [dict getdef $entry kind ""] {
        struct {
            set id [dict get $entry id]
            lassign [Member $id] ns name
            if {![Judged $decls $ns] || [Entry $decls $ns types $name] ne ""} return
            set registry [dict get $::hir::structs::registry $id]
            set origin [Located $hir [dict getdef $registry span ""] $decls $ns types $name]
            foreach {slot traits} [dict getdef $registry constraints {}] {
                foreach trait $traits {
                    if {[NominalEntry $decls $trait types] ne ""} {
                        Escape hir "struct $id" [list $trait types] "its type slot $slot" "" $origin
                        return
                    }
                }
            }
            if {[dict get $entry opaque]} {
                # Hidden representation is no public interface.
                return
            }
            foreach {field t} [dict get $entry fields] {
                set found [Find $decls $t]
                if {$found ne ""} {
                    Escape hir "struct $id" $found "its field \"$field\"" "" \
                        [Located $hir [dict getdef [dict getdef $registry spans {}] $field ""] $decls $ns types $name]
                    return
                }
            }
        }
        layout {
            set id [dict get $entry id]
            lassign [Member $id] ns name
            if {![Judged $decls $ns] || [Entry $decls $ns types $name] ne ""} return
            foreach field [dict get $entry fields] {
                set found [Find $decls [dict get $field type]]
                if {$found ne ""} {
                    Escape hir "layout $id" $found "its field \"[dict get $field name]\"" "" \
                        [Located $hir "" $decls $ns types $name]
                    return
                }
            }
        }
        refined {
            set id [dict get $entry name]
            lassign [Member $id] ns name
            if {![Judged $decls $ns] || [Entry $decls $ns types $name] ne ""} return
            set found [Find $decls [dict get $entry carrier]]
            if {$found ne ""} {
                Escape hir "type $id" $found "its carrier" "" [Located $hir "" $decls $ns types $name]
            }
        }
    }
}

# A public trait's requirements (one of HIR's `traits` entries).
proc hir::privacy::CheckTrait {hirVar decls entry} {
    upvar 1 $hirVar hir
    set id [dict get $entry id]
    set ns [dict get $entry namespace]
    if {![Judged $decls $ns] || [Entry $decls $ns types [dict get $entry name]] ne ""} return
    foreach r [dict get $entry requirements] {
        set types [lmap p [dict get $r params] {dict get $p type}]
        lappend types [dict get $r result type]
        set found ""
        foreach t $types {
            set found [Find $decls $t]
            if {$found ne ""} break
        }
        if {$found eq ""} {
            set found [FindErrors $decls [dict get $r errors]]
        }
        if {$found ne ""} {
            Escape hir "trait $id" $found "its requirement \"[dict get $r name]\"" "" \
                [Located $hir [dict get $r nameSpan] $decls $ns types [dict get $entry name]]
            return
        }
    }
}

# 1 if the declarations of unit NS have a public interface to judge: NS is
# a module of the compilation. The entry program is imported by nothing, so
# nothing it declares is any other code's interface (`private` there is
# allowed and changes nothing).
proc hir::privacy::Judged {decls ns} {
    return [expr {$ns ne "" && [dict exists $decls $ns]}]
}

# The origin of the source span SPAN (SpanOrigin), else of the name of the
# declaration NAME of CATEGORY in unit NS as the loader recorded it
# (ModuleDecl's `declarations`), else "".
proc hir::privacy::Located {hir span decls ns category name} {
    set origin [SpanOrigin $hir $span]
    if {$origin eq ""} {
        set origin [dict getdef $decls $ns declarations $category $name ""]
    }
    return $origin
}
