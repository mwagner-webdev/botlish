# exports.tcl -- C exports of a native library: `exported c fn`
# (NATIVE-LIBRARY-MILESTONE-1.md).
#
#   hir::exports::of $hir                  -> the program's export records
#   hir::exports::verify hirVar            (in hir::CheckOnce)
#   set hir [hir::exports::select $hir {NAME ...}]
#
# An exported function is an ordinary Botlish function -- its body, its
# Botlish callers, every analysis and every backend see an ordinary block --
# with one more fact: a native library built from the program gives it a C
# entry point whose C signature is its declared Botlish signature at the
# boundary. Nothing here infers a C signature from the function's callers or
# body: every parameter and the result are declared, each with a type that
# has a C representation:
#
#   int       int64_t: every int64_t value enters exactly; an Int result
#             outside int64_t is a boundary error, never truncated
#   bool      C's bool
#   Float64   a finite double (NaN and the infinities are no Float64)
#   str       UTF-8 bytes: a pointer and a length in (validated), an owned
#             buffer out
#   unit      a result only: no result at all
#
# Declared errors cross as data (runtime::library). The block carries the
# export as `exported {c SYMBOL}` (hir/syntax.tcl): SYMBOL the C symbol the
# declaration states (`named "SYMBOL"`), or "" for the library's default,
# LIBRARY_NAME (native::library).
#
# An export is called by a foreign caller with any value its declared types
# admit, so a library compiles it as an independent root
# (hir::specialize's "Export roots"): its instance assumes only its declared
# contract, whatever its Botlish callers pass. That needs an
# environment-free function, which is why a capture is an error here: a
# library never runs its root file's top-level statements (native::library),
# so a captured binding of them would never have a value.
#
# `select` is the compiler API's other way to choose exports, for a caller
# that names them (native::library -exports): it marks top-level functions
# of the entry program as if they were declared `exported c fn`, so both
# ways reach the same representation, checked the same way.

namespace eval hir::exports {
    # A declared Botlish type -> its C representation (the header above).
    variable representations {int int bool bool Float64 Float64 str str}
}

# The exported function blocks of HIR, in program order.
proc hir::exports::blocks {hir} {
    set found {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "block" && [dict exists $node exported]} {
            lappend found $e
        }
    }
    return [lsort -dictionary $found]
}

# The binding bound to block E by a declaration (its `bind`), or "".
proc hir::exports::Binding {hir e} {
    foreach b [dict get $hir scopes [dict get $hir exprs $e scope] bindings] {
        set declaredBy [dict get $hir bindings $b declaredBy]
        if {$declaredBy ne "" && [dict exists $hir exprs $declaredBy]
                && [dict get $hir exprs $declaredBy value] eq $e} {
            return $b
        }
    }
    return ""
}

# The C representation of the declared type TYPE of an exported function's
# parameter (RESULT 0) or result (RESULT 1), or "" when it has none.
proc hir::exports::Representation {type result} {
    variable representations
    if {$result && $type eq "unit"} {
        return unit
    }
    return [dict getdef $representations $type ""]
}

# The export records of HIR, one per exported function, in program order:
# dicts {block E binding B name NAME symbol SYMBOL params {{NAME REP} ...}
# result REP errors {ERROR ...}}. NAME is the function's source name
# (module-qualified in a module); SYMBOL its stated C symbol or "". Only for
# a HIR verify accepted.
proc hir::exports::of {hir} {
    set records {}
    foreach e [blocks $hir] {
        set node [dict get $hir exprs $e]
        set params [lmap b [dict get $node params] type [dict get $node declaredParamTypes] {
            list [hir::semantic::SourceName $hir $b] [Representation $type 0]
        }]
        lappend records [dict create block $e binding [Binding $hir $e] \
            name [hir::semantic::CallableName $hir $e] symbol [lindex [dict get $node exported] 1] \
            params $params result [Representation [dict get $node declaredResult] 1] \
            errors [dict getdef $node declaredErrors {}]]
    }
    return $records
}

# Reports every exported function whose declaration has no C entry point:
#
#   EXPORT-SIGNATURE  a parameter or the result without a declared type that
#                     has a C representation; a flag, context, variadic or
#                     resume section; a function that may yield
#   EXPORT-CAPTURE    a captured binding that is no environment-free
#                     function (an export is environment-free:
#                     hir::aot::StaticBlocks)
#   EXPORT-SYMBOL     a stated C symbol another export states too
proc hir::exports::verify {hirVar} {
    upvar 1 $hirVar hir
    set symbols [dict create]
    set exported [blocks $hir]
    if {$exported eq {}} {
        return
    }
    set statics [hir::aot::StaticBlocks $hir]
    foreach e $exported {
        set node [dict get $hir exprs $e]
        set name [hir::semantic::CallableName $hir $e]
        set what "exported c fn \"$name\""
        set supported "int, bool, Float64 or str"
        foreach b [dict get $node params] type [dict get $node declaredParamTypes] {
            set param [hir::semantic::SourceName $hir $b]
            if {$type eq {}} {
                hir::Diagnose hir EXPORT-SIGNATURE \
                    "$what: parameter \"$param\" needs a declared type with a C representation ($supported): a C signature is declared, never inferred from callers" $e
            } elseif {[Representation $type 0] eq ""} {
                hir::Diagnose hir EXPORT-SIGNATURE \
                    "$what: parameter \"$param\" is declared [hir::types::presented $type], which has no C representation at a native library's boundary ($supported)" $e
            }
        }
        set result [dict get $node declaredResult]
        if {$result eq {}} {
            hir::Diagnose hir EXPORT-SIGNATURE \
                "$what: its result needs a declared type with a C representation ($supported, or unit): write \"-> T\"" $e
        } elseif {[Representation $result 1] eq ""} {
            hir::Diagnose hir EXPORT-SIGNATURE \
                "$what: its result is declared [hir::types::presented $result], which has no C representation at a native library's boundary ($supported, or unit)" $e
        }
        foreach {field section} {flags "a flag section" variadic "a variadic parameter" declaredResume "a resume clause"} {
            if {[dict getdef $node $field {}] ne {}} {
                hir::Diagnose hir EXPORT-SIGNATURE "$what: it has $section, which a C caller cannot pass" $e
            }
        }
        set contexts [hir::contexts::required $hir $e]
        if {$contexts ne {}} {
            hir::Diagnose hir EXPORT-SIGNATURE \
                "$what: it requires the context [join $contexts {, }], which no native library installs: its C caller has no context to give it" $e
        }
        set binding [Binding $hir $e]
        if {[dict exists $hir coroutines mayYield $e] || ($binding ne "" && [dict exists $hir coroutines mayYield $binding])} {
            hir::Diagnose hir EXPORT-SIGNATURE "$what: it may yield, and a C caller is no coroutine" $e
        }
        if {$e ni $statics} {
            # Its environment: what it captures beyond the static functions
            # (blocks environment-free themselves, hir::aot::StaticBlocks).
            set names [lmap b [dict get $node captures] {
                if {[hir::aot::BoundBlock $hir $b] in $statics} continue
                hir::semantic::SourceName $hir $b
            }]
            hir::Diagnose hir EXPORT-CAPTURE \
                "$what: it captures [join $names {, }]: an exported function is environment-free, since a native library never runs its root file's statements; make each a function, or move it into a module" $e
        }
        set symbol [lindex [dict get $node exported] 1]
        if {$symbol ne ""} {
            if {[dict exists $symbols $symbol]} {
                hir::Diagnose hir EXPORT-SYMBOL \
                    "$what: the C symbol \"$symbol\" is also exported c fn \"[dict get $symbols $symbol]\"'s" $e
            } else {
                dict set symbols $symbol $name
            }
        }
    }
}

# HIR with the entry program's top-level functions NAMES exported to C as
# if each were declared `exported c fn` without a stated symbol (the compiler
# API's export list, native::library -exports). An unknown name, or one that
# is not a function, is an error {NATIVE LIBRARY EXPORT}. Run verify on the
# result: the selection meets exactly the declaration's rules.
proc hir::exports::select {hir names} {
    set functions [dict create]
    set top [hir::top $hir]
    foreach b [dict get $hir scopes $top bindings] {
        set declaredBy [dict get $hir bindings $b declaredBy]
        if {$declaredBy eq "" || ![dict exists $hir exprs $declaredBy]} continue
        set value [dict get $hir exprs $declaredBy value]
        if {[dict get $hir exprs $value kind] eq "block"} {
            dict set functions [hir::semantic::SourceName $hir $b] $value
        }
    }
    foreach name $names {
        if {![dict exists $functions $name]} {
            throw {NATIVE LIBRARY EXPORT} "no top-level function \"$name\" to export: the export list names functions of the library's root file"
        }
        set e [dict get $functions $name]
        if {![dict exists $hir exprs $e exported]} {
            dict set hir exprs $e exported [list c ""]
        }
    }
    return $hir
}
