# foreign.tcl -- `extern c fn` and `extern c library` declarations (C-FFI.md).
#
#   hir::foreign::Reset                 drops the previous compilation's
#   hir::foreign::apply DECLS LINKS     registers this compilation's
#   hir::foreign::DeclareBindings ...   their names, in their unit's scope
#   hir::foreign::declarations HIR      the HIR's `foreign` side table
#   hir::foreign::links HIR             the HIR's link plan
#
# An extern c fn is a truthful C ABI declaration with no body:
#
#   extern c fn SHA256 named "botlish_bssl_SHA256"(
#       data: ffi::c::Ptr[ffi::c::UChar] read noescape,
#       len: ffi::c::ULong,
#       out: ffi::c::Ptr[ffi::c::UChar] write noescape
#   ) -> ffi::c::Ptr[ffi::c::UChar] alias out
#
# It becomes a compilation-local native of the internal name extern#KEY
# (KEY: the Botlish qualified name, `sha::SHA256`, or the entry program's
# bare one; `#` is no source spelling, so nothing a program writes, and no
# loader check of a later compilation, can name it), registered with
# exactly the foreign call contract a -foreign native has (core/cabi.tcl,
# C-POINTER-BORROWING.md) -- the declared C types, each pointer parameter's
# access and escape, the result's provenance -- and its link symbol and ABI
# transport classes as its `extern` metadata (core/native.tcl). So a call of
# it is typed, admitted, exposed, judged direct and lowered by the one
# machinery every foreign call has (hir/borrow.tcl, hir/direct.tcl,
# native/lower.tcl's BorrowCall): no second contract representation, no body
# with a magic call. Its name is a root-kind binding of the declaring unit's
# own scope (DeclareBindings), visible from the unit's start like a type, a
# member `NS::NAME` of a module like a function: it denotes the native,
# owns no storage, and is never a value (hir::borrow::verify).
#
# The registrations are process-wide state the analyses and the backends read
# by name, so they are a declaration registry (COMPILATION-ISOLATION.md): the
# state is captured in every HIR's `declarations` and re-installed by
# hir::activate (Install). The HIR also keeps them as its own side tables:
#
#   foreign   KEY -> {key namespace name symbol native origin contract abi}
#   links     the link plan: {{library NAME origins {ORIGIN...}} ...}
#
# The link plan is every `extern c library` of the program, one entry per
# distinct name in first-declaration order (the loader's order: a module's
# own declarations after its imports', the entry program's last). A library
# is never associated with a declaration: the system linker resolves every
# symbol against all of them. Native linking passes them inside one linker
# group (codegen/aot.rs), so their order never decides a static link.

namespace eval hir::foreign {
    # KEY -> the registration record of each extern c fn of the compilation
    # in force (the header's `foreign` entries), in declaration order.
    variable registry [dict create]
    # The link plan of the compilation in force.
    variable links {}
}

# The internal native name of the extern c fn whose key is KEY.
proc hir::foreign::nativeName {key} {
    return extern#$key
}

# Unregisters the extern natives of the compilation in force.
proc hir::foreign::Reset {} {
    variable registry
    variable links
    dict for {key record} $registry {
        core::native::unregister [dict get $record native]
    }
    set registry [dict create]
    set links {}
}

# "FILE:LINE:COLUMN: " of SPAN ("" for none).
proc hir::foreign::Location {span} {
    if {$span eq ""} {
        return ""
    }
    return "[dict get $span file]:[dict get $span line]:[dict get $span column]: "
}

# The ABI transport class of the C value type TYPE (a resolved type): i8 ..
# u64 for a C integer scalar by its registry metadata's width and
# signedness (never its name), bool for C _Bool (ffi::c::Bool, Botlish's
# bool: one byte, 0 or 1), f32 or f64 for a C floating type by the IEEE 754
# format the compilation's target gives it (core::cabi::floatingInfo: C
# float is binary32, C double binary64 -- never read from their Float64
# carrier, C-FLOAT-FFI-MILESTONE-1.md), ptr for a data or function pointer,
# void for unit (a result only).
proc hir::foreign::AbiClass {type} {
    if {$type eq "unit"} {
        return void
    }
    if {$type eq "bool"} {
        return bool
    }
    if {[hir::cabi::IsFloating $type]} {
        return [dict get [hir::cabi::FloatingInfo $type] class]
    }
    if {[hir::types::IsCPtr $type] || [hir::types::IsCFnPtr $type]} {
        return ptr
    }
    set info [core::type::cabiScalar $type]
    return [expr {[dict get $info signed] ? "i" : "u"}][dict get $info bits]
}

# Registers DECLS (surface/lower.tcl's ExternDeclOf dicts, across every unit
# the program loads) as this compilation's extern natives, and LINKDECLS
# (LinkDeclOf dicts) as its link plan. An invalid declaration is a located
# semantic error: an unknown or non-C type, a fact a parameter cannot have,
# a provenance the result cannot have, a duplicate.
proc hir::foreign::apply {decls linkDecls} {
    variable registry
    variable links
    Reset
    foreach decl $decls {
        set ns [dict get $decl namespace]
        set name [dict get $decl name]
        if {$ns eq ""} {
            set key $name
        } else {
            set key "${ns}::$name"
        }
        set where [expr {$ns eq "" ? "the entry program" : "module \"$ns\""}]
        set what "extern c fn \"$name\""
        if {[dict exists $registry $key]} {
            core::semanticError DUPLICATE \
                "[Location [dict get $decl nameSpan]]$what is already declared in $where (at [string range [Location [dict get $registry $key nameSpan]] 0 end-2]): two declarations of one Botlish name are never merged, whatever their signatures"
        }
        set params {}
        set abiParams {}
        set names {}
        foreach param [dict get $decl params] {
            set pname [dict get $param name]
            if {$pname in $names} {
                core::semanticError DUPLICATE \
                    "[Location [dict get $param nameSpan]]duplicate parameter \"$pname\" of $what"
            }
            lappend names $pname
            set type [ResolveCType [dict get $param type] $ns [dict get $param typeSpan] "parameter \"$pname\" of $what"]
            if {$type eq "unit"} {
                core::semanticError TYPE \
                    "[Location [dict get $param typeSpan]]parameter \"$pname\" of $what: unit is not a C parameter type (a C function of no parameters has an empty parameter list)"
            }
            set entry [dict create name $pname type $type]
            set access [dict get $param access]
            set escape [dict get $param escape]
            set pointer [expr {[hir::types::IsCPtr $type] || [hir::types::IsCFnPtr $type]}]
            if {!$pointer && ($access ne "" || $escape ne "")} {
                core::semanticError TYPE \
                    "[Location [dict get $param factsSpan]]parameter \"$pname\" of $what is a C value ([hir::types::show $type]), not a pointer: access and escape are facts of a pointer parameter"
            }
            if {$access ne "" && ![hir::types::IsCPtr $type]} {
                core::semanticError TYPE \
                    "[Location [dict get $param factsSpan]]parameter \"$pname\" of $what is a C function pointer: C reads or writes through a data pointer only, so it states no access (its escape says whether C keeps it)"
            }
            if {$access eq "write" && $pname eq "result"} {
                core::semanticError TYPE \
                    "[Location [dict get $param nameSpan]]write parameter \"result\" of $what: a written parameter's bytes come back as the call result's field of its name, beside `result`, so it needs another name"
            }
            if {$access ne ""} {
                dict set entry access $access
            }
            if {$escape ne ""} {
                dict set entry escape $escape
            }
            lappend params $entry
            lappend abiParams [AbiClass $type]
        }
        set result [ResolveCType [dict get $decl resultType] $ns [dict get $decl resultTypeSpan] "the result of $what"]
        set provenance unknown
        set written [dict get $decl provenance]
        if {$written ne ""} {
            if {![hir::types::IsCPtr $result]} {
                core::semanticError TYPE \
                    "[Location [dict get $decl provenanceSpan]]$what returns [hir::types::show $result], not a data pointer: only a pointer result has a provenance (\"independent\" or \"alias PARAM\")"
            }
            if {[lindex $written 0] eq "alias"} {
                set target [lindex $written 1]
                set index [lsearch -exact $names $target]
                if {$index < 0} {
                    core::semanticError TYPE \
                        "[Location [dict get $decl provenanceSpan]]the result of $what is declared an alias of \"$target\", which is not one of its parameters"
                }
                set targetType [dict get [lindex $params $index] type]
                if {$targetType ne $result} {
                    core::semanticError TYPE \
                        "[Location [dict get $decl provenanceSpan]]the result of $what ([hir::types::show $result]) is declared an alias of parameter \"$target\" ([hir::types::show $targetType]): an exact alias is the same pointer, of the same type"
                }
            }
            set provenance $written
        }
        if {[dict get $decl symbol] ne ""} {
            set symbol [dict get $decl symbol]
        } else {
            set symbol $name
        }
        set contract [dict create params $params result $result provenance $provenance]
        set native [nativeName $key]
        set abi [dict create params $abiParams result [AbiClass $result]]
        # A variadic C function (VARIADICS-VERTICAL-SLICE-1.md): its
        # declaration is its fixed parameters, and a native of any arity;
        # each call's trailing arguments carry their own C types
        # (hir::borrow's `cvarargs`).
        set variadic [dict getdef $decl variadic 0]
        if {$variadic} {
            dict set contract variadic 1
            dict set abi variadic 1
        }
        set kinds [lmap p $params {
            set t [dict get $p type]
            if {[hir::types::IsCPtr $t] || [hir::types::IsCFnPtr $t]} {
                string cat "any"
            } elseif {[hir::cabi::IsFloating $t]} {
                hir::cabi::Carrier $t
            } elseif {$t eq "bool"} {
                set t
            } else {
                string cat "int"
            }
        }]
        set extern [dict create key $key namespace $ns name $name symbol $symbol abi $abi]
        # A C floating value C returns is a Float64 only when it is finite,
        # and a Float64 narrowed to a C float may round to an infinity: the
        # call completes with NonFiniteFloat then (FLOAT64-MILESTONE-1.md,
        # C-FLOAT-FFI-MILESTONE-1.md) -- after C returned, or before C is
        # called. A double argument is exact: every Float64 is a double.
        set errors ""
        if {[hir::cabi::IsFloating $result] || [NarrowedParameters $abi] ne ""} {
            set errors NonFiniteFloat
        }
        core::native::register $native -arity [expr {$variadic ? "*" : [llength $params]}] \
            -impl [list core::cabi::ExternImpl $key] \
            -param-types $kinds -result-type any -errors $errors \
            -ownership [lrepeat [llength $params] observe] \
            -foreign $contract -extern $extern
        dict set registry $key [dict create key $key namespace $ns name $name symbol $symbol \
            native $native origin [dict get $decl origin] nameSpan [dict get $decl nameSpan] \
            contract [dict get [core::native::metadata $native] foreign] abi $abi]
    }
    set plan {}
    set index [dict create]
    foreach decl $linkDecls {
        set library [dict get $decl library]
        if {![dict exists $index $library]} {
            dict set index $library [llength $plan]
            lappend plan [dict create library $library origins {}]
        }
        set i [dict get $index $library]
        lset plan $i [dict merge [lindex $plan $i] \
            [dict create origins [concat [dict get [lindex $plan $i] origins] [list [dict get $decl origin]]]]]
    }
    set links $plan
}

# The indices of the parameters of the ABI signature ABI ({params CLASSES
# result CLASS}) whose argument is narrowed on the way to C: a C float's
# (f32), which a Float64 may overflow (core::cabi::Narrow).
proc hir::foreign::NarrowedParameters {abi} {
    return [lsearch -all -exact [dict get $abi params] f32]
}

# The resolved C value type (or unit) TYPEEXPR denotes in namespace NS, for
# WHAT at SPAN, or a located semantic error. A C type is named here, so
# ffi::c::Float and ffi::c::Double are C floating types (hir::cabi::
# ResolveCType).
proc hir::foreign::ResolveCType {typeExpr ns span what} {
    if {[catch {hir::cabi::ResolveCType $typeExpr $ns} type options]} {
        core::semanticError [hir::resolve::TypeErrorKind $options TYPE] \
            "[Location $span]unknown or invalid type [hir::resolve::ShowTypeExpr $typeExpr] for $what: $type"
    }
    set type [hir::types::canonical $type]
    if {$type eq "unit"} {
        return unit
    }
    set problem [hir::cabi::ValueTypeProblem $type]
    if {$problem ne "" || [hir::types::IsImprint $type]} {
        if {$problem eq ""} {
            set problem "[hir::types::show $type] is an imprint variable, and a C function's signature is one ABI, never imprinted"
        }
        core::semanticError TYPE "[Location $span]$what: $problem"
    }
    return $type
}

# Declares, in scope SCOPE of HIR, the name of every extern c fn of unit NS
# ("" the entry program) in force: a root-kind binding of the declaration's
# spelling that denotes its native (hir::hygiene names it extern#KEY once
# resolution is done, keeping the spelling). A name the unit binds again is
# the ordinary DUPLICATE of its later binding.
proc hir::foreign::DeclareBindings {hirVar scope ns} {
    upvar 1 $hirVar hir
    variable registry
    dict for {key record} $registry {
        if {[dict get $record namespace] ne $ns} continue
        set name [dict get $record name]
        set native [dict get $record native]
        set b [hir::resolve::NewBinding hir $name root $scope [dict get $record origin]]
        dict set hir bindings $b symbol [hir::resolve::nativeSymbol hir $native]
        dict set hir bindings $b value [core::value::native $native]
        dict set hir bindings $b extern $key
    }
}

# The `foreign` side table and the link plan of the compilation in force,
# as HIR's own (hir::BuildOnce stamps them).
proc hir::foreign::tables {} {
    variable registry
    variable links
    set foreign [dict create]
    dict for {key record} $registry {
        dict set foreign $key [dict remove $record nameSpan]
    }
    return [list $foreign $links]
}

# HIR's extern c fn declarations (its `foreign` side table): KEY -> {key
# namespace name symbol native origin contract abi}.
proc hir::foreign::declarations {hir} {
    return [dict getdef $hir foreign {}]
}

# HIR's link plan: the library names, in order.
proc hir::foreign::links {hir} {
    if {![dict exists $hir links]} {
        return {}
    }
    return [lmap entry [dict get $hir links] {dict get $entry library}]
}

# The state of this registry, for hir::declarations::capture.
proc hir::foreign::capture {} {
    variable registry
    variable links
    set natives {}
    dict for {key record} $registry {
        lappend natives [dict get $record native] [core::native::metadata [dict get $record native]]
    }
    return [dict create registry $registry links $links natives $natives]
}

# Installs STATE (capture's value): the extern natives of the compilation
# in force are unregistered, STATE's registered as they were (already
# validated: nothing is resolved again).
proc hir::foreign::Install {state} {
    variable registry
    variable links
    Reset
    foreach {native meta} [dict get $state natives] {
        dict set ::core::native::registry $native $meta
    }
    set registry [dict get $state registry]
    set links [dict get $state links]
}
