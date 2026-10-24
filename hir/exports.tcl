# exports.tcl -- C exports of a native library (NATIVE-LIBRARY-MILESTONE-1.md).
#
#   exported c fn checked(n: int) -> int errors Rejected:
#       if n < 0:
#           fail Rejected {code: n}
#       n * 2
#
# `exported c fn` declares an ordinary Botlish function -- Botlish callers
# call it exactly as any other function, with every optimization -- that a
# native library also exports to C (native::library): a C function
# `LIB_checked(instance, int64_t n, int64_t *result, LIB_error **error)` whose
# call runs the function's export root, its generic instance compiled under
# the declared contract only (hir/specialize.tcl's ProgramValues). Its C ABI
# is read from its declaration, never from how Botlish code calls it, so the
# declaration states every boundary type:
#
#   * a parameter is int (C int64_t), bool (C bool), Float64 (C double) or
#     str (UTF-8 bytes: pointer and length), declared exactly so;
#   * the result is one of those or unit, declared (`-> unit` for none);
#   * the declared errors are what a call can fail with (the completion
#     analysis holds the body to them, as for every function); each reaches
#     the caller as its canonical identity, with its scalar payload fields;
#   * no flag section, context parameter, variadic parameter or resume
#     clause (EXPORT-SIGNATURE);
#   * a top-level function of the entry program or of a module
#     (EXPORT-PLACEMENT), whose name is a C identifier, the suffix of its C
#     symbol (EXPORT-NAME);
#   * environment-free: it captures nothing, requires no context and never
#     suspends (EXPORT-ENVIRONMENT) -- a C caller has no environment, no
#     installed context and no coroutine to give it.
#
# Exported, public and foreign are three different things: a module's
# functions are public to the modules that import it (IMPORTS.md) unless
# declared `private` (hir/privacy.tcl, which decides Botlish names only: a
# private exported function is still a C export), an
# `extern c fn` is a C function Botlish calls (C-FFI.md), and an `exported
# c fn` is a Botlish function C calls. Only the last makes a C symbol, and
# only in a native library: a program run or linked as an executable treats
# it as the ordinary function it is.
#
# A library may also export top-level functions of its entry program by
# name (native::library -exports NAMES, `select`), for programs written
# before this declaration: the same checks, the same records.

namespace eval hir::exports {
    # The boundary types (core types as the HIR spells them) and their C
    # forms, in the export record's spelling (NIR's `export` declarations).
    variable boundary {int int bool bool Float64 float64 str str}
}

# Diagnoses every `exported c fn` of HIRVAR's program.
proc hir::exports::verify {hirVar} {
    upvar 1 $hirVar hir
    if {[hir::mode $hir] ne "program"} {
        return
    }
    if {[hir::traits::Planning] || [dict exists $hir traitSource]} {
        # The monomorphized program: judged as written.
        return
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![dict exists $node exported]} continue
        foreach problem [Problems $hir $e] {
            lassign $problem kind message
            hir::Diagnose hir $kind $message $e
        }
    }
}

# The export records of HIR's `exported c fn`s, in program order: one dict
# each (see Record). An export verify refused has none.
proc hir::exports::of {hir} {
    set records {}
    foreach e [Declarations $hir] {
        if {![llength [Problems $hir $e]]} {
            lappend records [Record $hir $e]
        }
    }
    return $records
}

# The block ExprIds of HIR's `exported c fn`s, in program order.
proc hir::exports::Declarations {hir} {
    set found {}
    foreach e [dict get $hir roots] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "bind"} continue
        set value [dict get $node value]
        if {[dict exists $hir exprs $value exported]} {
            lappend found $value
        }
    }
    return $found
}

# The records of the entry program's top-level functions NAMES, exported by
# name (native::library -exports): {RECORDS PROBLEMS}, PROBLEMS a list of
# {NAME KIND MESSAGE} for every name that is no top-level function or would
# be refused as an `exported c fn` is.
proc hir::exports::select {hir names} {
    set top [dict get $hir top]
    set functions [dict create]
    foreach e [dict get $hir roots] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "bind"} continue
        set b [dict get $node binding]
        if {[dict get $hir bindings $b scope] ne $top} continue
        set value [dict get $node value]
        if {[dict get $hir exprs $value kind] eq "block"} {
            dict set functions [hir::semantic::SourceName $hir $b] $value
        }
    }
    set records {}
    set problems {}
    foreach name $names {
        if {![dict exists $functions $name]} {
            lappend problems [list $name EXPORT-PLACEMENT "the entry program has no top-level function \"$name\" to export"]
            continue
        }
        set e [dict get $functions $name]
        set found [Problems $hir $e]
        foreach problem $found {
            lappend problems [list $name {*}$problem]
        }
        if {![llength $found]} {
            lappend records [Record $hir $e]
        }
    }
    return [list $records $problems]
}

# The bind of block E (an ExprId), or "" when E is no bind's value.
proc hir::exports::BindOf {hir e} {
    dict for {b node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "bind" && [dict get $node value] eq $e} {
            return $b
        }
    }
    return ""
}

# The function's name: its written name, without its module.
proc hir::exports::ShortName {hir bind} {
    return [namespace tail [hir::semantic::SourceName $hir [dict get $hir exprs $bind binding]]]
}

# What keeps block E from being a C export: a list of {KIND MESSAGE}.
proc hir::exports::Problems {hir e} {
    variable boundary
    set node [dict get $hir exprs $e]
    set bind [BindOf $hir $e]
    set problems {}
    set scopes [list [dict get $hir top]]
    if {[dict exists $hir modules]} {
        lappend scopes {*}[dict values [dict get $hir modules]]
    }
    if {$bind eq "" || $bind ni [dict get $hir roots]
            || [dict get $hir bindings [dict get $hir exprs $bind binding] scope] ni $scopes} {
        set what [if {$bind eq ""} {string cat "this function"} else {string cat "\"[ShortName $hir $bind]\""}]
        return [list [list EXPORT-PLACEMENT "$what is not a top-level function of a program or module: a C export is a top-level declaration"]]
    }
    set name [ShortName $hir $bind]
    set what "exported c fn \"$name\""
    if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $name]} {
        lappend problems [list EXPORT-NAME "$what: its name is the suffix of its C symbol (LIBRARY_$name), so it must be a C identifier -- ASCII letters, digits and _, not starting with a digit"]
    }
    foreach b [dict get $node params] declared [dict get $node declaredParamTypes] {
        set param [dict get $hir bindings $b name]
        if {$declared eq {}} {
            lappend problems [list EXPORT-SIGNATURE "$what: parameter \"$param\" has no declared type; a C export declares every parameter's type (int, bool, Float64 or str), since its C ABI is read from the declaration alone"]
        } elseif {![dict exists $boundary $declared] || $declared eq "unit"} {
            lappend problems [list EXPORT-SIGNATURE "$what: parameter \"$param\" is declared [hir::types::presented $declared]; a C export's parameters are int (int64_t), bool, Float64 (double) or str (text: a pointer and a length)"]
        }
    }
    set result [dict get $node declaredResult]
    if {$result eq {}} {
        lappend problems [list EXPORT-SIGNATURE "$what declares no result type; a C export declares its result (int, bool, Float64, str, or -> unit for none), since its C ABI is read from the declaration alone"]
    } elseif {![dict exists $boundary $result] && $result ne "unit"} {
        lappend problems [list EXPORT-SIGNATURE "$what: the result is declared [hir::types::presented $result]; a C export's result is int (int64_t), bool, Float64 (double), str (an owned buffer of text) or unit"]
    }
    if {[dict getdef $node flags {}] ne {}} {
        lappend problems [list EXPORT-SIGNATURE "$what declares flags; a C export's parameters are ordinary ones only"]
    }
    if {[dict exists $node contextParams]} {
        lappend problems [list EXPORT-SIGNATURE "$what declares context parameters; a C caller has no installed context to give a C export"]
    }
    if {[dict exists $node variadic]} {
        lappend problems [list EXPORT-SIGNATURE "$what is variadic; a C export has a fixed parameter list"]
    }
    if {[dict getdef $node declaredResume {}] ne {}} {
        lappend problems [list EXPORT-SIGNATURE "$what declares a resume clause; a C export is never a coroutine body"]
    }
    # A function referring to other top-level functions captures their
    # bindings, and needs no environment when they need none either
    # (hir::aot::StaticBlocks): what it must not capture is a value.
    set values {}
    if {[dict get $node captures] ne {}} {
        set statics [hir::aot::StaticBlocks $hir]
        foreach b [dict get $node captures] {
            if {[hir::aot::BoundBlock $hir $b] ni $statics} {
                lappend values [hir::semantic::SourceName $hir $b]
            }
        }
    }
    if {$values ne {}} {
        lappend problems [list EXPORT-ENVIRONMENT "$what captures [join $values {, }]; a C export is environment-free (a top-level value it reads belongs in a module, where it is a module static)"]
    }
    set required [hir::contexts::required $hir $e]
    if {$required ne {}} {
        lappend problems [list EXPORT-ENVIRONMENT "$what requires the context[expr {[llength $required] > 1 ? "s" : ""}] [join $required {, }]; a C caller installs no context"]
    }
    if {[hir::coroutines::MayYield $hir $e]} {
        lappend problems [list EXPORT-ENVIRONMENT "$what may suspend (it yields, or calls a function that does); a C export runs to completion"]
    }
    return $problems
}

# The export record of block E: a dict
#
#   name     its name (the C symbol's suffix)
#   module   its module's namespace ("" for the entry program)
#   block    E
#   params   {NAME TYPE ...}, TYPE a boundary spelling (int bool float64 str)
#   result   a boundary spelling, or unit
#   errors   {ERROR {FIELD TYPE ...} ...}: the declared errors, each with its
#            payload fields in canonical (sorted) order, TYPE a boundary
#            spelling or "other" (no C form)
#   origin   the declaration's origin
proc hir::exports::Record {hir e} {
    variable boundary
    set node [dict get $hir exprs $e]
    set bind [BindOf $hir $e]
    set b [dict get $hir exprs $bind binding]
    set qualified [hir::semantic::SourceName $hir $b]
    set module [if {[string first :: $qualified] >= 0} {namespace qualifiers $qualified} else {string cat ""}]
    set params {}
    foreach p [dict get $node params] declared [dict get $node declaredParamTypes] {
        lappend params [dict get $hir bindings $p name] [dict get $boundary $declared]
    }
    set result [dict get $node declaredResult]
    set result [if {$result eq "unit"} {string cat unit} else {dict get $boundary $result}]
    set errors {}
    foreach error [dict getdef $node declaredErrors {}] {
        set fields {}
        set types [hir::errordecls::fields $error]
        foreach field [lsort [dict keys $types]] {
            set type [hir::types::Unrefined [dict get $types $field]]
            lappend fields $field [dict getdef $boundary $type other]
        }
        lappend errors $error $fields
    }
    return [dict create name [ShortName $hir $bind] module $module block $e params $params \
        result $result errors $errors origin [dict get $hir exprs $bind origin]]
}
