# ccompile.tcl -- the C backend: analyzed HIR to freestanding C11
# (C-COMPILE-FREESTANDING-MILESTONE-1.md).
#
#   source ccompile/ccompile.tcl        ;# loads the front end (hir/) too
#   set out [ccompile::program $hir -prefix fact]
#   dict get $out files                 ;# NAME -> TEXT: fact.h, fact.c,
#                                       ;# fact_display.c, fact.runtime.json,
#                                       ;# botlish_rt_v1.h
#   ccompile::write $out DIR            ;# the same files, written
#
# The backend does no semantic analysis of its own. Like the Tcl compiler
# (compiler/compiler.tcl) it compiles HIR as the front end analyzed it, and
# like native lowering (native/lower.tcl) it compiles one C function per
# *instance* of hir/specialize.tcl, reading the instance's view for types and
# hir/range.tcl's proven Ranges for representation. Every fact it acts on is
# one those analyses already established; it decides only how to say it in
# C:
#
#   representation  an Int whose Range fits int64_t is an int64_t; any other
#                   Int a botlish_rt_v1_int (ccompile/botlish_rt_v1.h): the
#                   value inline while it fits int64_t, a provider's number
#                   otherwise. Bool is bool, unit an unsigned char, an enum
#                   case a C enumeration constant, a struct a C struct by
#                   value (immutable values: copying is the semantics).
#   arithmetic      int64_t arithmetic only where the operands' Ranges and
#                   the result's (hir::range::add/sub/mul of the operands')
#                   fit int64_t, so no C signed overflow can happen; every
#                   other Int operation is a helper with a portable inline
#                   fast path and a runtime-service call when the exact
#                   result does not fit int64_t.
#   calls           a direct C call of the callee instance's function, or a
#                   jump to the function's top for a self tail call.
#   errors          every function returns a status (0: completed, else the
#                   error); a declared error is its own status, which a
#                   handler tests; a run-time error of the language (mod by
#                   zero) is a status with Botlish's own code and message.
#   control flow    if/else, for (;;) loops, goto for break, continue and
#                   handlers.
#
# What the backend cannot translate correctly yet it reports as the
# compile-time error C UNSUPPORTED, located at the construct: never a
# runtime-service reference and never an approximation. What the generated
# C can express but not implement (arbitrary-precision arithmetic) is a call
# of a botlish_rt_v1_* service: the program compiles, and links only where a
# provider supplies the service; PREFIX.runtime.json lists every service the
# generated C references.
#
# The generated C needs only freestanding C11 (stdint.h, stdbool.h,
# stddef.h; int64_t, which exists on every target this backend supports);
# no allocation, no I/O, no hosted library, no compiler extension.

if {[info commands ::hir::build] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] hir hir.tcl]
}

namespace eval ccompile {
    variable home [file dirname [file normalize [info script]]]
    # The runtime-service interface version this backend generates calls of
    # (botlish_rt_v1.h's BOTLISH_RT_V1).
    variable abi 1
    # The v1 services: ID -> {SYMBOL DESCRIPTION}. botlish_rt_v1.h declares
    # and specifies each one; the manifest lists the ones a program's
    # generated C calls.
    variable services {
        int.add          {botlish_rt_v1_int_add          "a + b of two Ints"}
        int.sub          {botlish_rt_v1_int_sub          "a - b of two Ints"}
        int.mul          {botlish_rt_v1_int_mul          "a * b of two Ints"}
        int.mod          {botlish_rt_v1_int_mod          "the Euclidean remainder of two Ints (divisor nonzero)"}
        int.compare      {botlish_rt_v1_int_compare      "the order of two Ints"}
        int.from_decimal {botlish_rt_v1_int_from_decimal "an Int literal outside int64_t, from its decimal text"}
        int.to_decimal   {botlish_rt_v1_int_to_decimal   "the decimal text of an Int outside int64_t (display only)"}
    }
    # The largest shift amount the language accepts (core/scalarbits.tcl's
    # maxShift, native's MAX_SHIFT): beyond it a shift is a RANGE error.
    variable maxShift 1048576

    # State of the compilation in progress (reset by program).
    variable baseHir {}
    variable hir {}
    variable spec {}
    variable ranges {}
    variable prefix {}
    variable selfTails {}
    # InstanceId -> {NAME PARAMREPRS RESULTREPR}
    variable signatures {}
    # InstanceIds compiled (-> C text) and pending
    variable compiled {}
    variable pending {}
    variable diagnostics {}
    # Aggregate types: KEY -> {CNAME KIND ...}, in definition order.
    variable aggregates {}
    variable aggregateOrder {}
    # Enum identities used, -> C type name.
    variable enums {}
    # Helpers (static C functions) used, by name, and the services each
    # program/display translation unit calls.
    variable helpers {}
    variable programServices {}
    variable displayServices {}
    # Status table: index -> {CODE MESSAGE NAME}; 0 is success.
    variable statuses {}
    variable statusIndex {}
    # Bindings stored at file scope (program-level values that functions
    # read): BindingId -> 1, and the ones bound so far -> {REPR CNAME}.
    variable staticBindings {}
    variable statics {}
    variable usesInt 0
}

# ---------------------------------------------------------------------------
# Entry points

# The C translation of the analyzed program-mode HIR program HIR: a dict
#
#   prefix      the C identifier prefix of every public name (PREFIX_run)
#   files       file name -> text, in a fixed order: PREFIX.h (the
#               program's interface: types, statuses, entry point),
#               PREFIX.c (the program), PREFIX_display.c (optional display
#               of the program's value as text), PREFIX.runtime.json (the
#               runtime-requirements manifest), botlish_rt_v1.h (the
#               runtime-service interface, a copy of ccompile's own)
#   services    the services PREFIX.c calls, sorted
#   display     the services PREFIX_display.c calls, sorted
#
# Options: -prefix NAME (a C identifier; default botlish_program), -source
# TEXT (the source's name, recorded in comments and the manifest). Raises C
# UNSUPPORTED (core::raiseDiagnostics: one entry per construct) for a
# program that uses what this backend does not translate yet.
proc ccompile::program {hirProgram args} {
    set options [hir::Options ccompile::program {-prefix botlish_program -source ""} $args]
    set name [dict get $options -prefix]
    if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $name]} {
        error "ccompile::program: -prefix must be a C identifier, found \"$name\""
    }
    hir::activate $hirProgram
    set hirProgram [hir::recovery::runnable $hirProgram]
    hir::activate $hirProgram
    if {[hir::mode $hirProgram] ne "program"} {
        throw {C UNSUPPORTED} "the C backend compiles programs (program-mode HIR), not sequences"
    }
    return [hir::Deep [list ccompile::Program $hirProgram $name [dict get $options -source]]]
}

# The C prefix of the program file PATH: its name without the extension, as
# a C identifier (other characters become `_`; a leading digit is prefixed
# with `b`).
proc ccompile::PrefixOf {path} {
    set name [Sanitize [file rootname [file tail $path]]]
    if {[regexp {^[0-9]} $name]} {
        set name b$name
    }
    return $name
}

# Writes the files of OUT (program's result) into directory DIR, creating
# it. Returns the paths written, in order.
proc ccompile::write {out dir} {
    file mkdir $dir
    set paths {}
    dict for {name text} [dict get $out files] {
        set path [file join $dir $name]
        set channel [open $path w]
        fconfigure $channel -translation lf -encoding utf-8
        puts -nonewline $channel $text
        close $channel
        lappend paths $path
    }
    return $paths
}

proc ccompile::Program {hirProgram name source} {
    variable baseHir
    variable hir
    variable spec
    variable ranges
    variable prefix
    variable selfTails
    variable signatures
    variable compiled
    variable pending
    variable diagnostics
    variable aggregates
    variable aggregateOrder
    variable enums
    variable helpers
    variable programServices
    variable displayServices
    variable statuses
    variable statusIndex
    variable staticBindings
    variable statics
    variable usesInt
    set baseHir $hirProgram
    set hir $hirProgram
    set prefix $name
    set signatures [dict create]
    set compiled [dict create]
    set pending {}
    set diagnostics {}
    set aggregates [dict create]
    set aggregateOrder {}
    set enums [dict create]
    variable caseConstants
    set caseConstants [dict create]
    set helpers [dict create]
    set programServices [dict create]
    set displayServices [dict create]
    set statuses [list [list "" "" OK]]
    set statusIndex [dict create]
    set statics [dict create]
    set usesInt 0
    variable active
    variable fixedResults
    set active {}
    set fixedResults [dict create]
    set spec [hir::specialize::analyze $hirProgram]
    hir::specialize::memoizeViews $hirProgram $spec
    try {
        set ranges [hir::range::analyze $hirProgram $spec 1 1 1 1 ""]
        set selfTails [hir::aot::selfTailCalls $hirProgram]
        set staticBindings [StaticBindings $hirProgram]
        # Declared errors first, so their statuses are 1..N in declaration
        # order whatever the order in which code raises them.
        foreach error [hir::errorDecls $hirProgram] {
            DeclaredStatus $error
        }
        set programId [dict get $spec keys program]
        # Compiling the program compiles every function it calls, each
        # before its caller needs its signature (Signature).
        variable referenced
        set referenced [dict create $programId 1]
        try {
            Signature $programId
        } trap {C UNSUPPORTED REPORTED} {} {
            # Rejected: every other function the program uses is compiled
            # too, so that each construct the backend cannot translate is
            # reported, not only the first one reached.
            foreach id [dict get $spec used] {
                if {[dict exists [dict get $spec dormant] $id]} continue
                catch {Signature $id}
            }
        }
    } finally {
        hir::specialize::forgetViews
        set hir $baseHir
    }
    if {$diagnostics ne ""} {
        set unique {}
        foreach d $diagnostics {
            if {$d ni $unique} { lappend unique $d }
        }
        core::raiseDiagnostics $unique
    }
    return [Assemble $programId $source]
}

# ---------------------------------------------------------------------------
# Diagnostics

# Raises C UNSUPPORTED for WHAT (a description of the construct) at
# expression E: the backend has no correct translation of it yet.
proc ccompile::Unsupported {e what} {
    variable baseHir
    set where ""
    if {$e ne "" && [dict exists $baseHir exprs $e]} {
        set where "[hir::originLocation $baseHir [hir::get $baseHir $e origin]]: "
    }
    throw {C UNSUPPORTED} "${where}the C backend cannot compile $what yet (Compilerpedia's backend.c lists what it compiles); this is a limit of the backend, not a missing runtime service"
}

# ---------------------------------------------------------------------------
# Facts

proc ccompile::Node {e} {
    variable hir
    return [dict get $hir exprs $e]
}
proc ccompile::Get {e key} {
    variable hir
    return [dict get $hir exprs $e $key]
}
proc ccompile::Kind {e} {
    variable hir
    return [dict get $hir exprs $e kind]
}
# The static type of expression E in the instance being compiled: the
# instance view's, unless that is only a kind (a specialization key keeps
# kinds, not identities: `enum`, `struct`) where the semantic HIR's type
# names the identity -- both hold for every value E has in the instance.
proc ccompile::TypeOf {e} {
    variable hir
    variable baseHir
    return [Precise [hir::typeOf $hir $e] [hir::typeOf $baseHir $e]]
}
proc ccompile::BindingTypeOf {b} {
    variable hir
    variable baseHir
    return [Precise [hir::bindingType $hir $b] [hir::bindingType $baseHir $b]]
}
# The semantic result type of block E (its resultType), any if unknown.
proc ccompile::BlockResultType {e} {
    variable baseHir
    set t [dict getdef [dict get $baseHir exprs $e] resultType ""]
    if {$t eq ""} {
        return any
    }
    return [hir::type $baseHir $t]
}
proc ccompile::Precise {viewType baseType} {
    if {[llength $viewType] == 1 && $viewType in {enum struct nstruct list} && [llength $baseType] > 1} {
        return $baseType
    }
    return $viewType
}
proc ccompile::Binding {b} {
    variable hir
    return [dict get $hir bindings $b]
}
# The Range instance ID's analysis proved for expression E.
proc ccompile::RangeOf {id e} {
    variable ranges
    return [hir::range::of $ranges $id $e]
}
# The Range of expression E (compiled to operand OP) in the function being
# compiled: the analysis's, and within int64_t when OP is an int64_t (a
# representation is only ever chosen on a proof, so it is one too).
proc ccompile::OpRange {fnVar e op} {
    upvar 1 $fnVar fn
    set r [RangeOf [dict get $fn instance] $e]
    if {[lindex $op 0] eq "i64" && ![FitsI64 $r]} {
        set r [hir::range::intersect $r {min -9223372036854775808 max 9223372036854775807}]
    }
    return $r
}

# 1 if every value of Range R is an int64_t.
proc ccompile::FitsI64 {r} {
    if {$r eq "never"} {
        return 1
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn eq "-inf" || $mx eq "+inf"} {
        return 0
    }
    return [expr {$mn >= -9223372036854775808 && $mx <= 9223372036854775807}]
}
# 1 if every value of Range R lies in LO..HI.
proc ccompile::Within {r lo hi} {
    if {$r eq "never"} {
        return 1
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn eq "-inf" || $mx eq "+inf"} {
        return 0
    }
    return [expr {$mn >= $lo && $mx <= $hi}]
}
# 1 if Range R may hold 0.
proc ccompile::MayBeZero {r} {
    if {$r eq "never"} {
        return 0
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {($mn ne "-inf" && $mn > 0) || ($mx ne "+inf" && $mx < 0)} {
        return 0
    }
    if {[dict exists $r exact] && 0 ni [dict get $r exact]} {
        return 0
    }
    return 1
}
# The Range of a value of static type TYPE (its integer domain's bounds).
proc ccompile::TypeRange {type} {
    return [hir::range::TypeFact $type]
}

# The program-level and module-level value bindings some block reads (its
# captures or module-static references): stored at file scope, written once
# where the program binds them and read by the functions (BindingId -> 1).
proc ccompile::StaticBindings {hir} {
    set top [hir::top $hir]
    set result [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block"} continue
        foreach b [concat [dict get $node captures] [dict getdef $node staticRefs {}]] {
            set binding [dict get $hir bindings $b]
            if {[dict get $binding kind] ni {local}} continue
            if {[hir::aot::BoundBlock $hir $b] ne ""} continue
            if {[dict get $binding scope] eq $top || [hir::isModuleBinding $hir $b]} {
                dict set result $b 1
            }
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Representations
#
# A representation (REPR) is how a value of a static type is carried in C:
#
#   i64            int64_t: an Int whose Range fits int64_t
#   int            botlish_rt_v1_int: any other Int
#   bool           bool
#   unit           PREFIX_unit (always 0)
#   {enum ID}      the C enumeration of enum ID
#   {agg KEY}      a C struct: a named struct, an anonymous struct or a
#                  List literal of fixed length (registered in aggregates)
#
# An operand is {REPR CODE}: CODE a C expression of that representation
# with no side effect (everything with an effect or a failure is emitted
# as a statement first), or {never ""} when control does not continue.

# The representation of a value of static TYPE whose Range is R, for a
# value that crosses no aggregate boundary (a local, a parameter, a
# result): an Int fits int64_t when R does. E is where (diagnostics).
proc ccompile::ReprOf {type r e} {
    if {$type eq "never"} {
        return unit
    }
    set kind [hir::types::kindOf $type]
    switch -- $kind {
        int {
            set rr [hir::range::intersect $r [TypeRange $type]]
            if {[FitsI64 $rr]} {
                return i64
            }
            return int
        }
        bool { return bool }
        unit { return unit }
        enum {
            set id [lindex $type 1]
            if {$id eq ""} {
                # A specialization key keeps an enum's kind, not its identity:
                # an instance called with cases of several enums has no one C
                # type for them.
                Unsupported $e "an enum value whose enum is not known statically (a function called with cases of different enums)"
            }
            if {[hir::enums::payloadTypes $id] ne "" && [lsearch -not [hir::enums::payloadTypes $id] {}] >= 0} {
                Unsupported $e "an enum whose cases carry payloads ([hir::enums::display $id])"
            }
            RegisterEnum $id
            return [list enum $id]
        }
        struct {
            return [list agg [StructAggregate $type $e]]
        }
    }
    Unsupported $e "a value of type [hir::types::show $type]"
}

# The representation of a field or element of static TYPE: its own Range
# is the type's (no expression narrows a stored field).
proc ccompile::StorageRepr {type e} {
    return [ReprOf $type [hir::range::unknown] $e]
}

# The C type of representation REPR.
proc ccompile::CType {repr} {
    variable prefix
    variable aggregates
    variable enums
    switch -- [lindex $repr 0] {
        i64  { return int64_t }
        int  { return botlish_rt_v1_int }
        bool { return bool }
        unit { return ${prefix}_unit }
        enum { return [dict get $enums [lindex $repr 1]] }
        agg  { return [dict get $aggregates [lindex $repr 1] cname] }
    }
    error "ccompile: no C type for representation $repr"
}

# A C expression of representation REPR with no meaning: what a join
# variable starts as, so that no path reads an uninitialized object.
proc ccompile::ZeroOf {repr} {
    variable enums
    variable aggregates
    switch -- [lindex $repr 0] {
        i64  { return "0" }
        int  { return "[Helper int_of_i64](0)" }
        bool { return "false" }
        unit { return "0" }
        enum { return "([dict get $enums [lindex $repr 1]])0" }
        agg  {
            set key [lindex $repr 1]
            Helper zero:$key
            return "[dict get $aggregates $key cname]_zero"
        }
    }
}

# CODE without one pair of parentheses around the whole of it, if it has
# them: the condition of an `if` (whose own parentheses then suffice).
proc ccompile::Bare {code} {
    if {[string index $code 0] ne "(" || [string index $code end] ne ")"} {
        return $code
    }
    set depth 0
    set n [string length $code]
    for {set k 0} {$k < $n} {incr k} {
        switch -- [string index $code $k] {
            ( { incr depth }
            ) {
                incr depth -1
                if {$depth == 0 && $k < $n - 1} {
                    return $code
                }
            }
            \" { return $code }
        }
    }
    return [string range $code 1 end-1]
}

proc ccompile::Sanitize {text} {
    regsub -all {[^A-Za-z0-9_]+} $text _ text
    regsub -all {_+$} $text "" text
    if {$text eq ""} {
        set text x
    }
    return $text
}

proc ccompile::RegisterEnum {id} {
    variable enums
    variable prefix
    if {![dict exists $enums $id]} {
        dict set enums $id ${prefix}_[Sanitize $id]
    }
    return [dict get $enums $id]
}

# The C constant of case CASE of enum ID.
proc ccompile::EnumConstant {id case} {
    variable caseConstants
    set constant "[RegisterEnum $id]_[Sanitize $case]"
    dict set caseConstants $constant 1
    return $constant
}

# The aggregate KEY of struct type TYPE (named or anonymous), registered
# with its fields' representations (fields first: C needs a by-value
# member's type defined before it).
proc ccompile::StructAggregate {type e} {
    variable aggregates
    variable aggregateOrder
    variable prefix
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {[llength $type] > 2 && [lindex $type 2] ne ""} {
            Unsupported $e "an application of the parameterized struct [hir::structs::display $id]"
        }
        set key [list named $id]
        if {[dict exists $aggregates $key]} {
            return $key
        }
        if {[hir::structs::isContext $id]} {
            Unsupported $e "the context struct [hir::structs::display $id]"
        }
        if {[hir::structs::treeField $id] ne ""} {
            Unsupported $e "the tree struct [hir::structs::display $id] (a recursive value)"
        }
        if {[hir::structs::identityOf $id] ne ""} {
            Unsupported $e "the struct [hir::structs::display $id], which declares an identity"
        }
        if {[hir::structs::IsAffine $id]} {
            Unsupported $e "the affine struct [hir::structs::display $id]"
        }
        # A struct that holds itself by value has no C representation; it is
        # rejected here, while its own registration is in progress.
        dict set aggregates $key [dict create cname "" kind pending]
        set fields {}
        foreach {field fieldType} [hir::structs::fieldTypes $id] {
            set repr [StorageRepr $fieldType $e]
            if {$repr eq [list agg $key] || ([lindex $repr 0] eq "agg" && [dict get $aggregates [lindex $repr 1] kind] eq "pending")} {
                Unsupported $e "the recursive struct [hir::structs::display $id]"
            }
            lappend fields $field $repr
        }
        dict set aggregates $key [dict create cname ${prefix}_[Sanitize $id] kind named id $id \
            fields $fields opaque [hir::structs::isOpaque $id]]
        lappend aggregateOrder $key
        return $key
    }
    if {[hir::types::IsStruct $type]} {
        set fields {}
        foreach {field fieldType} [lindex $type 1] {
            lappend fields $field [StorageRepr $fieldType $e]
        }
        return [AnonymousAggregate struct $fields]
    }
    Unsupported $e "a value of the struct kind whose fields are unknown ([hir::types::show $type])"
}

# The aggregate of an anonymous struct (KIND struct: FIELDS {NAME REPR ...}
# in slot order) or of a fixed-length List literal (KIND list: FIELDS
# {e0 REPR e1 REPR ...}): one C struct per distinct layout.
proc ccompile::AnonymousAggregate {kind fields} {
    variable aggregates
    variable aggregateOrder
    variable prefix
    set key [list $kind $fields]
    if {![dict exists $aggregates $key]} {
        set n [llength [lmap k $aggregateOrder {if {[lindex $k 0] ne "named"} {set k} else continue}]]
        set cname ${prefix}_[expr {$kind eq "list" ? "list" : "anon"}]$n
        dict set aggregates $key [dict create cname $cname kind $kind fields $fields opaque 0]
        lappend aggregateOrder $key
    }
    return $key
}

# The C member name of field FIELD.
proc ccompile::Member {field} {
    return f_[Sanitize $field]
}

# ---------------------------------------------------------------------------
# Statuses: 0 is success; a declared error, a run-time error of the language
# or a runtime-service failure is a status of its own.

proc ccompile::DeclaredStatus {name} {
    return [StatusOf [list declared $name] $name "the declared error $name was not handled" E_[Sanitize $name]]
}

# The status of the run-time error CODE (Botlish's error code, as every
# backend reports it) with MESSAGE, named NAME in C.
proc ccompile::StatusOf {key code message name} {
    variable statuses
    variable statusIndex
    if {![dict exists $statusIndex $key]} {
        dict set statusIndex $key [llength $statuses]
        lappend statuses [list $code $message $name]
    }
    return [StatusMacro [dict get $statusIndex $key]]
}

proc ccompile::StatusMacro {index} {
    variable statuses
    variable prefix
    return ${prefix}_[lindex $statuses $index 2]
}

proc ccompile::ServiceStatus {} {
    return [StatusOf runtime-limit {C RUNTIME LIMIT} "a runtime service could not complete an operation: its provider's storage is exhausted" RUNTIME_LIMIT]
}
proc ccompile::ServiceFault {} {
    return [StatusOf runtime-fault {C RUNTIME FAULT} "a runtime service returned a status the runtime-service interface does not define" RUNTIME_FAULT]
}

# ---------------------------------------------------------------------------
# Helpers: static C functions the program translation unit defines when its
# code uses them (none is emitted unused). Each name maps to its text and to
# the services it calls.

proc ccompile::Helper {name} {
    variable helpers
    variable prefix
    if {![dict exists $helpers $name]} {
        dict set helpers $name 1
        foreach dep [HelperDeps $name] {
            Helper $dep
        }
        foreach service [HelperServices $name] {
            Service $service
        }
    }
    if {[string match zero:* $name]} {
        return ""
    }
    return ${prefix}_$name
}

proc ccompile::Service {service} {
    variable programServices
    variable services
    dict set programServices $service 1
    return [lindex [dict get $services $service] 0]
}

proc ccompile::HelperDeps {name} {
    switch -- $name {
        int_add { return {int_of_i64 rt_status i64_add_ok} }
        int_sub { return {int_of_i64 rt_status i64_sub_ok} }
        int_mul { return {int_of_i64 rt_status i64_mul_ok} }
        int_mod { return {int_of_i64 rt_status i64_mod} }
        int_cmp { return {} }
        default { return {} }
    }
}

proc ccompile::HelperServices {name} {
    switch -- $name {
        int_add { return int.add }
        int_sub { return int.sub }
        int_mul { return {int.mul} }
        int_mod { return int.mod }
        int_cmp { return int.compare }
        rt_status { ServiceStatus; ServiceFault; return {} }
        default { return {} }
    }
}

# The C text of helper NAME.
proc ccompile::HelperText {name} {
    variable prefix
    variable aggregates
    set p $prefix
    if {[string match zero:* $name]} {
        set key [string range $name 5 end]
        set cname [dict get $aggregates $key cname]
        return "/* An object of no meaning a join variable starts as. */\nstatic const $cname ${cname}_zero;\n"
    }
    switch -- $name {
        int_of_i64 {
            return "/* An Int carried as botlish_rt_v1_int, from an int64_t. */
static botlish_rt_v1_int ${p}_int_of_i64(int64_t value)
{
    botlish_rt_v1_int result;
    result.small = value;
    result.big = NULL;
    return result;
}
"
        }
        rt_status {
            return "/* The program status of a runtime service's status. */
static ${p}_status ${p}_rt_status(botlish_rt_v1_status status)
{
    if (status == BOTLISH_RT_V1_LIMIT) {
        return ${p}_RUNTIME_LIMIT;
    }
    return ${p}_RUNTIME_FAULT;
}
"
        }
        i64_add_ok {
            return "/* Whether a + b fits int64_t (checked without overflowing). */
static bool ${p}_i64_add_ok(int64_t a, int64_t b)
{
    return b >= 0 ? a <= INT64_MAX - b : a >= INT64_MIN - b;
}
"
        }
        i64_sub_ok {
            return "/* Whether a - b fits int64_t (checked without overflowing). */
static bool ${p}_i64_sub_ok(int64_t a, int64_t b)
{
    return b >= 0 ? a >= INT64_MIN + b : a <= INT64_MAX + b;
}
"
        }
        i64_mul_ok {
            return "/* Whether a * b fits int64_t, and if so the product in *product:
 * the magnitudes multiplied in 32-bit halves, so no step overflows and no
 * division (a library routine on many 32-bit targets) is needed. */
static bool ${p}_i64_mul_ok(int64_t a, int64_t b, int64_t *product)
{
    uint64_t ua = a < 0 ? (uint64_t)0 - (uint64_t)a : (uint64_t)a;
    uint64_t ub = b < 0 ? (uint64_t)0 - (uint64_t)b : (uint64_t)b;
    bool negative = (a < 0) != (b < 0);
    uint64_t alo = ua & 0xFFFFFFFFu, ahi = ua >> 32;
    uint64_t blo = ub & 0xFFFFFFFFu, bhi = ub >> 32;
    uint64_t cross, low, magnitude;
    if (ahi != 0 && bhi != 0) {
        return false;
    }
    cross = ahi * blo + alo * bhi;
    if (cross > 0xFFFFFFFFu) {
        return false;
    }
    low = alo * blo;
    magnitude = low + (cross << 32);
    if (magnitude < low) {
        return false;
    }
    if (negative) {
        if (magnitude > (uint64_t)INT64_MAX + 1u) {
            return false;
        }
        *product = magnitude == (uint64_t)INT64_MAX + 1u ? INT64_MIN : -(int64_t)magnitude;
    } else {
        if (magnitude > (uint64_t)INT64_MAX) {
            return false;
        }
        *product = (int64_t)magnitude;
    }
    return true;
}
"
        }
        i64_mod {
            return "/* The Euclidean remainder of a by b (b != 0): 0 <= r < |b|. C's % truncates
 * toward zero, and INT64_MIN % -1 overflows: both are avoided here. */
static int64_t ${p}_i64_mod(int64_t a, int64_t b)
{
    int64_t r;
    if (b == -1) {
        return 0;
    }
    r = a % b;
    if (r < 0) {
        r = b < 0 ? r - b : r + b;
    }
    return r;
}
"
        }
        i64_shr {
            return "/* a shifted right by k bits (0 <= k), rounded toward negative infinity, as
 * Botlish's arbitrary-precision shift_right is: C's >> of a negative value
 * is implementation-defined, so a negative a is shifted as its complement. */
static int64_t ${p}_i64_shr(int64_t a, int64_t k)
{
    if (k > 63) {
        k = 63;
    }
    if (a >= 0) {
        return a >> k;
    }
    return -1 - ((-1 - a) >> k);
}
"
        }
        i64_shl {
            return "/* a shifted left by k bits (0 <= k <= 62), the result proven to fit
 * int64_t: a multiplication, since C's << of a negative value is undefined. */
static int64_t ${p}_i64_shl(int64_t a, int64_t k)
{
    return a * ((int64_t)1 << k);
}
"
        }
        int_add - int_sub {
            set op [expr {$name eq "int_add" ? "+" : "-"}]
            set ok [expr {$name eq "int_add" ? "i64_add_ok" : "i64_sub_ok"}]
            set service [Service [expr {$name eq "int_add" ? "int.add" : "int.sub"}]]
            set check [Helper $ok]
            return "/* a $op b of two Ints: inline while it fits int64_t, else the service. */
static ${p}_status ${p}_$name\(botlish_rt_v1_int a, botlish_rt_v1_int b, botlish_rt_v1_int *result)
{
    botlish_rt_v1_status status;
    if (a.big == NULL && b.big == NULL && $check\(a.small, b.small)) {
        *result = ${p}_int_of_i64(a.small $op b.small);
        return ${p}_OK;
    }
    status = $service\(a, b, result);
    return status == BOTLISH_RT_V1_OK ? ${p}_OK : ${p}_rt_status(status);
}
"
        }
        int_mul {
            set service [Service int.mul]
            set check [Helper i64_mul_ok]
            return "/* a * b of two Ints: inline while it fits int64_t, else the service. */
static ${p}_status ${p}_int_mul(botlish_rt_v1_int a, botlish_rt_v1_int b, botlish_rt_v1_int *result)
{
    botlish_rt_v1_status status;
    int64_t product;
    if (a.big == NULL && b.big == NULL && $check\(a.small, b.small, &product)) {
        *result = ${p}_int_of_i64(product);
        return ${p}_OK;
    }
    status = $service\(a, b, result);
    return status == BOTLISH_RT_V1_OK ? ${p}_OK : ${p}_rt_status(status);
}
"
        }
        int_mod {
            set service [Service int.mod]
            set mod [Helper i64_mod]
            return "/* The Euclidean remainder of two Ints (b nonzero): inline for int64_t
 * operands, else the service. */
static ${p}_status ${p}_int_mod(botlish_rt_v1_int a, botlish_rt_v1_int b, botlish_rt_v1_int *result)
{
    botlish_rt_v1_status status;
    if (a.big == NULL && b.big == NULL) {
        *result = ${p}_int_of_i64($mod\(a.small, b.small));
        return ${p}_OK;
    }
    status = $service\(a, b, result);
    return status == BOTLISH_RT_V1_OK ? ${p}_OK : ${p}_rt_status(status);
}
"
        }
        int_cmp {
            set service [Service int.compare]
            return "/* The order of two Ints (-1, 0, 1): inline for int64_t operands, else the
 * service. */
static int ${p}_int_cmp(botlish_rt_v1_int a, botlish_rt_v1_int b)
{
    if (a.big == NULL && b.big == NULL) {
        return a.small < b.small ? -1 : a.small > b.small;
    }
    return $service\(a, b);
}
"
        }
        int_is_zero {
            return "/* Whether an Int is 0 (a big value never is: normalization). */
static bool ${p}_int_is_zero(botlish_rt_v1_int a)
{
    return a.big == NULL && a.small == 0;
}
"
        }
    }
    error "ccompile: unknown helper $name"
}

# Helpers in a fixed emission order: dependencies first.
proc ccompile::HelperOrder {} {
    return {int_of_i64 rt_status i64_add_ok i64_sub_ok i64_mul_ok i64_mod i64_shr i64_shl
        int_add int_sub int_mul int_mod int_cmp int_is_zero}
}

# ---------------------------------------------------------------------------
# Instances and their C signatures

# {NAME PARAM-REPRS} of instance ID's C function: its parameters carried as
# their Ranges allow (an instance is entered only by the direct calls the
# specialization saw: InstanceClosed).
proc ccompile::Params {id} {
    variable spec
    variable ranges
    variable baseHir
    variable prefix
    set instance [hir::specialize::instance $spec $id]
    set block [dict get $instance block]
    if {$block eq "program"} {
        return [list ${prefix}_program {}]
    }
    if {![dict exists [dict get $spec closed] $id]} {
        Unsupported $block "a function whose calls are not all direct (a function used as a value)"
    }
    set view [hir::specialize::view $baseHir $spec $id]
    set instRanges [dict get $ranges instances $id]
    set name [hir::aot::BlockName $baseHir $block]
    set cname ${prefix}_[string range $id 1 end]_[Sanitize [expr {$name eq "" ? "fn" : $name}]]
    set params {}
    foreach b [hir::get $view $block params] r [dict get $instRanges params] \
            entry [hir::signatures::entryTypes $baseHir $block] {
        if {$entry eq ""} {
            set entry any
        }
        lappend params [ReprOf [Precise [hir::bindingType $view $b] $entry] $r $block]
    }
    return [list $cname $params]
}

# The representation of instance ID's result as its type and the range
# analysis's result Range give it (what a recursive function returns: its
# body cannot be compiled before its own calls are).
proc ccompile::RangeResult {id} {
    variable spec
    variable ranges
    set instance [hir::specialize::instance $spec $id]
    set block [dict get $instance block]
    set type [Precise [dict get $instance result] [BlockResultType $block]]
    return [ReprOf $type [dict get $ranges instances $id result] $block]
}

# {NAME PARAM-REPRS RESULT-REPR} of instance ID's C function, compiling the
# function first if it has not been: its result is carried as an int64_t
# when every completion of its body is one (each was proven to fit), which
# can be more than the range analysis proved of its result. A function a
# call reaches while its own body is being compiled (it is recursive)
# returns its result as RangeResult says.
proc ccompile::Signature {id} {
    variable signatures
    variable active
    variable fixedResults
    variable compiled
    variable hir
    variable diagnostics
    if {[dict exists $signatures $id]} {
        return [dict get $signatures $id]
    }
    if {$id in $active} {
        lassign [Params $id] cname params
        if {![dict exists $fixedResults $id]} {
            dict set fixedResults $id [RangeResult $id]
        }
        return [list $cname $params [dict get $fixedResults $id]]
    }
    if {[dict exists $compiled $id]} {
        # Its compilation failed (and was reported): so does every caller's.
        throw {C UNSUPPORTED REPORTED} "reported"
    }
    set saved $hir
    set savedActive $active
    try {
        dict set compiled $id [Function $id]
    } trap {C UNSUPPORTED REPORTED} {} {
        dict set compiled $id ""
        throw {C UNSUPPORTED REPORTED} "reported"
    } trap {C UNSUPPORTED} {message} {
        # Reported once, at the construct. Its callers cannot be compiled
        # without it: they stop without a diagnostic of their own.
        lappend diagnostics [dict create message $message errorcode {C UNSUPPORTED}]
        dict set compiled $id ""
        throw {C UNSUPPORTED REPORTED} "reported"
    } finally {
        set hir $saved
        set active $savedActive
    }
    return [dict get $signatures $id]
}

# The C function of instance ID (its text), compiling its body.
proc ccompile::Function {id} {
    variable spec
    variable baseHir
    variable hir
    variable prefix
    variable staticBindings
    variable active
    variable fixedResults
    variable signatures
    set instance [hir::specialize::instance $spec $id]
    set block [dict get $instance block]
    lassign [Params $id] cname paramReprs
    set hir [hir::specialize::view $baseHir $spec $id]
    lappend active $id
    set fn [dict create instance $id block $block lines {} indent 1 temps 0 labels 0 \
        locals [dict create] loops [dict create] handlers {} usedLabels [dict create] \
        result "" completions {} tail 0 joins 0]
    if {$block eq "program"} {
        set body [hir::roots $hir]
        set params {}
    } else {
        set params [hir::get $hir $block params]
        set body [hir::get $hir $block body]
        if {$block ni [dict get $spec context statics]} {
            # Only a block whose captures are functions or program-level
            # values (StaticBindings) is a C function of its own.
            foreach b [hir::get $hir $block captures] {
                if {[hir::aot::BoundBlock $hir $b] eq "" && ![dict exists $staticBindings $b]} {
                    Unsupported $block "a closure (a function that captures a local value of an enclosing function)"
                }
            }
        }
        foreach b $params repr $paramReprs {
            set c p_[Sanitize [dict get [hir::binding $hir $b] name]]_[string range $b 1 end]
            dict set fn locals $b [list $repr $c]
        }
    }
    set value [Sequence fn $body value]
    if {[lindex $value 0] ne "never"} {
        Complete fn $value
    }
    # The result's representation, now that every completion is known (the
    # program's is its value's).
    set completions [dict get $fn completions]
    if {[dict exists $fixedResults $id]} {
        set resultRepr [dict get $fixedResults $id]
    } elseif {$block eq "program"} {
        set resultRepr [expr {$completions eq "" ? "unit" : [lindex $completions 0 0]}]
        variable programResult
        set programResult $resultRepr
    } else {
        set resultRepr [RangeResult $id]
        if {$resultRepr eq "int" && $completions ne ""
                && [lsearch -not -exact -index 0 $completions i64] < 0} {
            set resultRepr i64
        }
    }
    set map {}
    set k 0
    foreach op $completions {
        lappend map "@@RESULT$k@@" [Want fn $op $resultRepr]
        incr k
    }
    set lines [lmap line [dict get $fn lines] {string map $map $line}]
    # A binding whose C variable nothing but its declaration names is used
    # once, so no C compiler warns of it.
    set text [join $lines \n]
    dict set fn lines [lmap line $lines {
        if {[regexp {^(\s*)@@UNREAD:([^:]+):(.*)@@$} $line -> indent b c]} {
            if {[regexp -all "\\m$c\\M" $text] > 2} continue
            set line "${indent}(void)$c;"
        }
        set line
    }]
    set active [lrange $active 0 end-1]
    set paramList {}
    foreach b $params repr $paramReprs {
        lappend paramList "[CType $repr] [lindex [dict get $fn locals $b] 1]"
    }
    lappend paramList "[CType $resultRepr] *out"
    set head "static ${prefix}_status $cname\([join $paramList {, }])"
    set name [expr {$block eq "program" ? "the program" : [hir::aot::BlockName $baseHir $block]}]
    set key [expr {[dict get $instance generic] ? "generic" : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set lines [list "/* $name ([string trim "$id $key"]) */" $head "\{"]
    if {[dict get $fn tail]} {
        lappend lines "top:;"
    }
    lappend lines {*}[dict get $fn lines]
    lappend lines "\}"
    dict set signatures $id [list $cname $paramReprs $resultRepr]
    return [list $head [join $lines \n]]
}

# A normal completion of the function with operand VALUE: its result is
# written (in the representation decided once the whole body is known) and
# the function returns.
proc ccompile::Complete {fnVar value} {
    upvar 1 $fnVar fn
    variable prefix
    set k [llength [dict get $fn completions]]
    dict lappend fn completions $value
    Emit fn "*out = @@RESULT$k@@;"
    Emit fn "return ${prefix}_OK;"
}

# ---------------------------------------------------------------------------
# Emission

proc ccompile::Emit {fnVar line} {
    upvar 1 $fnVar fn
    dict lappend fn lines "[string repeat {    } [dict get $fn indent]]$line"
}
proc ccompile::Indent {fnVar delta} {
    upvar 1 $fnVar fn
    dict incr fn indent $delta
}
proc ccompile::Temp {fnVar {stem t}} {
    upvar 1 $fnVar fn
    dict incr fn temps
    return ${stem}[dict get $fn temps]
}
proc ccompile::Label {fnVar stem} {
    upvar 1 $fnVar fn
    dict incr fn labels
    return ${stem}_[dict get $fn labels]
}
# Declares a C variable of REPR holding CODE; returns its name.
proc ccompile::Declare {fnVar repr code {stem t}} {
    upvar 1 $fnVar fn
    set t [Temp fn $stem]
    Emit fn "[CType $repr] $t = $code;"
    return $t
}

# The C expression of operand OP as representation REPR. An int64_t widens
# to an Int for free; an Int narrows to an int64_t only where the target's
# Range fits int64_t (the caller's proof), which normalization makes a read
# of `small`.
proc ccompile::Want {fnVar op repr} {
    upvar 1 $fnVar fn
    lassign $op have code
    if {$have eq $repr} {
        return $code
    }
    if {$have eq "i64" && $repr eq "int"} {
        return "[Helper int_of_i64]($code)"
    }
    if {$have eq "int" && $repr eq "i64"} {
        return "($code).small"
    }
    if {$have eq "unit" && $repr eq "unit"} {
        return 0
    }
    error "ccompile: cannot carry a $have value as $repr"
}

# A failure with status STATUS (a C expression): to the innermost enclosing
# handler's dispatch, or out of the function.
proc ccompile::Fail {fnVar status} {
    upvar 1 $fnVar fn
    set handlers [dict get $fn handlers]
    if {$handlers eq ""} {
        Emit fn "return $status;"
        return
    }
    lassign [lindex $handlers end] label var
    dict set fn usedLabels $label 1
    Emit fn "$var = $status;"
    Emit fn "goto $label;"
}

# The status-checked call CALL (a C expression returning a status).
proc ccompile::Checked {fnVar call {never 0}} {
    upvar 1 $fnVar fn
    variable prefix
    set st [Temp fn st]
    Emit fn "${prefix}_status $st = $call;"
    if {$never} {
        Fail fn $st
        return
    }
    Emit fn "if ($st != ${prefix}_OK) \{"
    Indent fn 1
    Fail fn $st
    Indent fn -1
    Emit fn "\}"
}

# ---------------------------------------------------------------------------
# Expressions

# Compiles the sequence EXPRS: every expression but the last for its
# effects, the last as WANT (value | discard). Returns the last's operand.
proc ccompile::Sequence {fnVar exprs want} {
    upvar 1 $fnVar fn
    set value [list unit 0]
    set n [llength $exprs]
    set i 0
    foreach e $exprs {
        incr i
        set mode [expr {$i == $n ? $want : "discard"}]
        set value [Expr fn $e $mode]
        if {[lindex $value 0] eq "never"} {
            return $value
        }
    }
    return $value
}

proc ccompile::Expr {fnVar e want} {
    upvar 1 $fnVar fn
    variable hir
    set node [Node $e]
    set kind [dict get $node kind]
    switch -- $kind {
        const    { return [Const fn $e $node] }
        ref      { return [Ref fn $e $node] }
        bind     { return [Bind fn $e $node] }
        block {
            if {$want eq "discard"} {
                return [list unit 0]
            }
            Unsupported $e "a function used as a value"
        }
        call     { return [Call fn $e $node $want] }
        if       { return [If fn $e $node $want] }
        loop - countloop { return [Loop fn $e $node $want] }
        listloop - lockloop {
            Unsupported $e "a loop over a List (Lists of a length not known statically need storage)"
        }
        return {
            set value [Expr fn [dict get $node value] value]
            if {[lindex $value 0] eq "never"} {
                return $value
            }
            Complete fn $value
            return [list never ""]
        }
        break {
            if {[dict get $node value] ne ""} {
                Unsupported $e "break with a value"
            }
            set target [dict get $node target]
            set label [dict get $fn loops $target break]
            dict set fn usedLabels $label 1
            Emit fn "goto $label;"
            return [list never ""]
        }
        continue {
            set label [dict get $fn loops [dict get $node target] continue]
            dict set fn usedLabels $label 1
            Emit fn "goto $label;"
            return [list never ""]
        }
        struct   { return [Struct fn $e $node] }
        project  { return [Project fn $e $node] }
        fail {
            if {[dict get $node value] ne ""} {
                Unsupported $e "an error with a payload"
            }
            Fail fn [DeclaredStatus [dict get $node name]]
            return [list never ""]
        }
        handle   { return [Handle fn $e $node $want] }
        ok - error {
            Unsupported $e "a Result value"
        }
    }
    Unsupported $e "the expression form $kind"
}

proc ccompile::Const {fnVar e node} {
    upvar 1 $fnVar fn
    set value [dict get $node value]
    switch -- [core::value::kind $value] {
        int {
            set n [core::value::intOf $value]
            if {$n >= -9223372036854775807 && $n <= 9223372036854775807} {
                return [list i64 "INT64_C($n)"]
            }
            if {$n == -9223372036854775808} {
                return [list i64 "INT64_MIN"]
            }
            set t [Temp fn big]
            Emit fn "botlish_rt_v1_int $t;"
            set service [Service int.from_decimal]
            Helper rt_status
            set st [Temp fn st]
            variable prefix
            Emit fn "botlish_rt_v1_status $st = $service\(\"$n\", [string length $n]u, &$t);"
            Emit fn "if ($st != BOTLISH_RT_V1_OK) \{"
            Indent fn 1
            Fail fn "${prefix}_rt_status($st)"
            Indent fn -1
            Emit fn "\}"
            return [list int $t]
        }
        bool {
            return [list bool [expr {[lindex $value 1] eq "true" ? "true" : "false"}]]
        }
        unit {
            return [list unit 0]
        }
        enum {
            set id [core::value::enumId $value]
            RegisterEnum $id
            return [list [list enum $id] [EnumConstant $id [core::value::enumCaseName $value]]]
        }
        str {
            Unsupported $e "a String"
        }
    }
    Unsupported $e "a constant of kind [core::value::kind $value]"
}

proc ccompile::Ref {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable statics
    variable staticBindings
    set b [dict get $node binding]
    if {$b eq ""} {
        Unsupported $e "an unbound name"
    }
    set binding [hir::binding $hir $b]
    switch -- [dict get $binding kind] {
        root {
            set value [dict get $binding value]
            switch -- [core::value::kind $value] {
                bool { return [list bool [expr {[lindex $value 1] eq "true" ? "true" : "false"}]] }
                unit { return [list unit 0] }
            }
            Unsupported $e "the native [dict get $node name] used as a value"
        }
        ambient {
            Unsupported $e "an ambient binding"
        }
    }
    if {[dict exists $fn locals $b]} {
        return [Narrowed fn $e [dict get $fn locals $b]]
    }
    if {[dict exists $statics $b]} {
        return [Narrowed fn $e [dict get $statics $b]]
    }
    if {[hir::aot::BoundBlock $hir $b] ne ""} {
        Unsupported $e "a function used as a value"
    }
    Unsupported $e "a reference to [dict get $node name], whose storage the C backend has not placed"
}

# OP, a stored Int, as an int64_t where expression E's own Range (narrower
# than its storage's, after a comparison) fits int64_t.
proc ccompile::Narrowed {fnVar e op} {
    upvar 1 $fnVar fn
    if {[lindex $op 0] eq "int" && [FitsI64 [RangeOf [dict get $fn instance] $e]]} {
        return [list i64 [Want fn $op i64]]
    }
    return $op
}

proc ccompile::Bind {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable statics
    variable staticBindings
    variable prefix
    set b [dict get $node binding]
    set valueExpr [dict get $node value]
    if {[Kind $valueExpr] eq "block"} {
        # A function's definition: its instances are C functions of their
        # own; the binding itself holds nothing at run time.
        return [list unit 0]
    }
    if {[dict get $node duplicate]} {
        Unsupported $e "a duplicate binding"
    }
    set value [Expr fn $valueExpr value]
    if {[lindex $value 0] eq "never"} {
        return $value
    }
    set name [Sanitize [dict get [hir::binding $hir $b] name]]
    if {[dict exists $staticBindings $b]} {
        set c ${prefix}_g_${name}_[string range $b 1 end]
        dict set statics $b [list [lindex $value 0] $c]
        Emit fn "$c = [lindex $value 1];"
        return [list [lindex $value 0] $c]
    }
    set c v_${name}_[string range $b 1 end]
    Emit fn "[CType [lindex $value 0]] $c = [lindex $value 1];"
    # A binding nothing reads is still declared (a branch value may be
    # assigned to it), and marked used: resolved once the body is known.
    Emit fn "@@UNREAD:$b:$c@@"
    dict set fn locals $b [list [lindex $value 0] $c]
    return [list [lindex $value 0] $c]
}

proc ccompile::Call {fnVar e node want} {
    upvar 1 $fnVar fn
    variable hir
    lassign [dict get $node target] targetKind target
    switch -- $targetKind {
        native {
            set name [dict get [hir::symbol $hir $target] name]
            return [NativeCall fn $e $node $name]
        }
        block {
            return [BlockCall fn $e $node $target]
        }
    }
    Unsupported $e "a call of a value whose function is not known statically"
}

proc ccompile::BlockCall {fnVar e node target} {
    upvar 1 $fnVar fn
    variable spec
    variable selfTails
    variable prefix
    set id [dict get $fn instance]
    set instance [hir::specialize::instance $spec $id]
    if {![dict exists $instance calls $e]} {
        Unsupported $e "a call whose callee instance the specialization did not decide"
    }
    if {[Kind [dict get $node callee]] ne "ref"} {
        Unsupported $e "a call whose callee is computed"
    }
    set callee [dict get $instance calls $e]
    set selfTail [expr {$callee eq $id && [dict exists $selfTails $e] && [dict get $selfTails $e] eq [dict get $fn block]}]
    if {$selfTail} {
        # (Its result is the function's own: no signature is needed.)
        lassign [Params $callee] cname paramReprs
    } else {
        lassign [Signature $callee] cname paramReprs resultRepr
    }
    set args {}
    foreach arg [dict get $node args] repr $paramReprs {
        set op [Expr fn $arg value]
        if {[lindex $op 0] eq "never"} {
            return $op
        }
        lappend args [list $op $repr]
    }
    if {$selfTail} {
        # A self tail call: the arguments are computed first, then become
        # the parameters, and the body starts again.
        set temps {}
        foreach pair $args {
            lassign $pair op repr
            lappend temps [Declare fn $repr [Want fn $op $repr] a]
        }
        foreach b [hir::get [set ::ccompile::hir] [dict get $fn block] params] t $temps {
            Emit fn "[lindex [dict get $fn locals $b] 1] = $t;"
        }
        Emit fn "goto top;"
        dict set fn tail 1
        return [list never ""]
    }
    variable referenced
    dict set referenced $callee 1
    set words [lmap pair $args {
        lassign $pair op repr
        Want fn $op $repr
    }]
    set calleeResult [dict get [hir::specialize::instance $spec $callee] result]
    set t [Temp fn r]
    Emit fn "[CType $resultRepr] $t;"
    lappend words "&$t"
    Checked fn "$cname\([join $words {, }])" [expr {$calleeResult eq "never"}]
    if {$calleeResult eq "never"} {
        return [list never ""]
    }
    return [list $resultRepr $t]
}

# The operands of call NODE's arguments, evaluated in order; "" when one
# never completes.
proc ccompile::Operands {fnVar node} {
    upvar 1 $fnVar fn
    set ops {}
    foreach arg [dict get $node args] {
        set op [Expr fn $arg value]
        if {[lindex $op 0] eq "never"} {
            return ""
        }
        lappend ops $op
    }
    return $ops
}

proc ccompile::NativeCall {fnVar e node name} {
    upvar 1 $fnVar fn
    set id [dict get $fn instance]
    set argExprs [dict get $node args]
    switch -- $name {
        + - - - * {
            return [Arith fn $e $node $name]
        }
        < - <= - > - >= {
            return [Compare fn $e $node $name]
        }
        == {
            return [Equal fn $e $node]
        }
        mod {
            return [Mod fn $e $node]
        }
        bit_and - bit_or - bit_xor {
            lassign $argExprs ea eb
            set ops [Operands fn $node]
            if {$ops eq ""} {
                return [list never ""]
            }
            if {![FitsI64 [OpRange fn $ea [lindex $ops 0]]] || ![FitsI64 [OpRange fn $eb [lindex $ops 1]]]} {
                Unsupported $e "$name of Ints the compiler cannot prove fit int64_t (the v1 runtime-service interface has no bitwise services)"
            }
            set op [dict get {bit_and & bit_or | bit_xor ^} $name]
            return [list i64 "([Want fn [lindex $ops 0] i64] $op [Want fn [lindex $ops 1] i64])"]
        }
        shift_right - shift_left {
            return [Shift fn $e $node $name]
        }
        list {
            set ops [Operands fn $node]
            if {$ops eq "" && $argExprs ne ""} {
                return [list never ""]
            }
            set fields {}
            set inits {}
            set k 0
            foreach op $ops {
                lappend fields e$k [lindex $op 0]
                lappend inits ".[Member e$k] = [lindex $op 1]"
                incr k
            }
            set key [AnonymousAggregate list $fields]
            if {$inits eq ""} {
                set inits [list ".empty = 0"]
            }
            return [list [list agg $key] "(([CType [list agg $key]]){[join $inits {, }]})"]
        }
    }
    Unsupported $e "the native operation $name"
}

proc ccompile::Arith {fnVar e node name} {
    upvar 1 $fnVar fn
    set id [dict get $fn instance]
    lassign [dict get $node args] ea eb
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    lassign $ops a b
    set ra [OpRange fn $ea $a]
    set rb [OpRange fn $eb $b]
    if {$ra ne "never" && $rb ne "never"} {
        set rr [switch -- $name {
            + { hir::range::add $ra $rb }
            - { hir::range::sub $ra $rb }
            * { hir::range::mul $ra $rb }
        }]
    } else {
        set rr never
    }
    if {[FitsI64 $ra] && [FitsI64 $rb] && [FitsI64 $rr]} {
        # Proven: the exact result is an int64_t, so no C overflow.
        return [list i64 "([Want fn $a i64] $name [Want fn $b i64])"]
    }
    set helper [Helper [dict get {+ int_add - int_sub * int_mul} $name]]
    set t [Temp fn n]
    Emit fn "botlish_rt_v1_int $t;"
    Checked fn "$helper\([Want fn $a int], [Want fn $b int], &$t)"
    return [Narrowed fn $e [list int $t]]
}

proc ccompile::Compare {fnVar e node name} {
    upvar 1 $fnVar fn
    set id [dict get $fn instance]
    lassign [dict get $node args] ea eb
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    lassign $ops a b
    if {[FitsI64 [OpRange fn $ea $a]] && [FitsI64 [OpRange fn $eb $b]]} {
        return [list bool "([Want fn $a i64] $name [Want fn $b i64])"]
    }
    return [list bool "([Helper int_cmp]([Want fn $a int], [Want fn $b int]) $name 0)"]
}

proc ccompile::Equal {fnVar e node} {
    upvar 1 $fnVar fn
    set id [dict get $fn instance]
    lassign [dict get $node args] ea eb
    set ta [TypeOf $ea]
    set tb [TypeOf $eb]
    set ka [hir::types::kindOf $ta]
    set kb [hir::types::kindOf $tb]
    set scalar {int bool unit enum}
    if {$ka ni $scalar || $kb ni $scalar} {
        Unsupported $e "== of values of type [hir::types::show $ta] and [hir::types::show $tb]"
    }
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    lassign $ops a b
    if {$ka ne $kb} {
        # Values of two different kinds are never equal.
        return [list bool false]
    }
    if {[lindex $a 1] eq [lindex $b 1]} {
        # The same side-effect-free expression twice: equal (and a C
        # compiler warns of the self-comparison).
        return [list bool true]
    }
    variable caseConstants
    if {$ka eq "enum" && [dict exists $caseConstants [lindex $a 1]] && [dict exists $caseConstants [lindex $b 1]]} {
        # Two different case constants: decided here.
        return [list bool false]
    }
    switch -- $ka {
        int {
            if {[FitsI64 [OpRange fn $ea $a]] && [FitsI64 [OpRange fn $eb $b]]} {
                return [list bool "([Want fn $a i64] == [Want fn $b i64])"]
            }
            return [list bool "([Helper int_cmp]([Want fn $a int], [Want fn $b int]) == 0)"]
        }
        bool {
            return [list bool "([lindex $a 1] == [lindex $b 1])"]
        }
        unit {
            return [list bool true]
        }
        enum {
            if {[lindex $ta 1] ne [lindex $tb 1]} {
                return [list bool false]
            }
            return [list bool "([lindex $a 1] == [lindex $b 1])"]
        }
    }
}

proc ccompile::Mod {fnVar e node} {
    upvar 1 $fnVar fn
    set id [dict get $fn instance]
    lassign [dict get $node args] ea eb
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    lassign $ops a b
    set ra [OpRange fn $ea $a]
    set rb [OpRange fn $eb $b]
    set native [expr {[FitsI64 $ra] && [FitsI64 $rb]}]
    if {[MayBeZero $rb]} {
        set zero [StatusOf {semantic ARITHMETIC mod} {CORE SEMANTIC ARITHMETIC} "mod: division by zero" ARITHMETIC_MOD_ZERO]
        if {$native} {
            set test "[Want fn $b i64] == 0"
        } else {
            set test "[Helper int_is_zero]([Want fn $b int])"
        }
        Emit fn "if ($test) \{"
        Indent fn 1
        Fail fn $zero
        Indent fn -1
        Emit fn "\}"
    }
    if {$native} {
        return [list i64 "[Helper i64_mod]([Want fn $a i64], [Want fn $b i64])"]
    }
    set t [Temp fn n]
    Emit fn "botlish_rt_v1_int $t;"
    Checked fn "[Helper int_mod]([Want fn $a int], [Want fn $b int], &$t)"
    return [Narrowed fn $e [list int $t]]
}

proc ccompile::Shift {fnVar e node name} {
    upvar 1 $fnVar fn
    variable maxShift
    set id [dict get $fn instance]
    lassign [dict get $node args] ex ek
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    lassign $ops x k
    set rx [OpRange fn $ex $x]
    set rk [OpRange fn $ek $k]
    if {![FitsI64 $rx]} {
        Unsupported $e "$name of an Int the compiler cannot prove fits int64_t (the v1 runtime-service interface has no shift services)"
    }
    if {$name eq "shift_left" && (![FitsI64 [RangeOf $id $e]] || ![Within $rk 0 62])} {
        Unsupported $e "shift_left whose result the compiler cannot prove fits int64_t"
    }
    if {![Within $rk 0 $maxShift]} {
        set range [StatusOf {semantic RANGE shift} {CORE SEMANTIC RANGE} "shift amount out of range (0..$maxShift)" RANGE_SHIFT]
        if {[lindex $k 0] eq "i64"} {
            set test "[lindex $k 1] < 0 || [lindex $k 1] > $maxShift"
        } else {
            set test "([lindex $k 1]).big != NULL || ([lindex $k 1]).small < 0 || ([lindex $k 1]).small > $maxShift"
        }
        Emit fn "if ($test) \{"
        Indent fn 1
        Fail fn $range
        Indent fn -1
        Emit fn "\}"
        set kcode [expr {[lindex $k 0] eq "i64" ? [lindex $k 1] : "([lindex $k 1]).small"}]
    } else {
        set kcode [Want fn $k i64]
    }
    set helper [Helper [expr {$name eq "shift_right" ? "i64_shr" : "i64_shl"}]]
    return [list i64 "$helper\([Want fn $x i64], $kcode)"]
}

proc ccompile::Struct {fnVar e node} {
    upvar 1 $fnVar fn
    set type [TypeOf $e]
    set key [StructAggregate $type $e]
    variable aggregates
    set fields [dict get $aggregates $key fields]
    set inits {}
    set ops [Operands fn [dict create args [dict get $node fields]]]
    if {$ops eq "" && [dict get $node fields] ne ""} {
        return [list never ""]
    }
    foreach name [dict get $node names] op $ops {
        set repr [dict get $fields $name]
        lappend inits ".[Member $name] = [Want fn $op $repr]"
    }
    if {$inits eq ""} {
        set inits [list ".empty = 0"]
    }
    return [list [list agg $key] "(([CType [list agg $key]]){[join $inits {, }]})"]
}

proc ccompile::Project {fnVar e node} {
    upvar 1 $fnVar fn
    variable aggregates
    set receiver [Expr fn [dict get $node receiver] value]
    if {[lindex $receiver 0] eq "never"} {
        return $receiver
    }
    if {[lindex $receiver 0 0] ne "agg"} {
        Unsupported $e "a field projection of a value that is no struct"
    }
    set key [lindex $receiver 0 1]
    set name [dict get $node name]
    set repr [dict get $aggregates $key fields $name]
    return [Narrowed fn $e [list $repr "([lindex $receiver 1]).[Member $name]"]]
}

# The operand an `if` (or a handled call) of type TYPE joins its branches
# into, for WANT: "" when nothing is joined (discarded, unit, never).
proc ccompile::JoinRepr {fnVar e want} {
    upvar 1 $fnVar fn
    set type [TypeOf $e]
    if {$want eq "discard" || $type in {unit never}} {
        return ""
    }
    return [ReprOf $type [RangeOf [dict get $fn instance] $e] $e]
}

# Opens the join of E (an `if` or a handled call) for WANT: a variable its
# branches assign, declared now with its representation left open, or "" when
# nothing is joined. JoinAssign assigns an operand to it; JoinClose decides
# the representation once every branch is known -- an int64_t when every
# value assigned is one (each was proven to fit), else what the join's own
# Range says -- and returns the join's operand.
proc ccompile::JoinOpen {fnVar e want} {
    upvar 1 $fnVar fn
    set repr [JoinRepr fn $e $want]
    if {$repr eq ""} {
        return ""
    }
    dict incr fn joins
    set n [dict get $fn joins]
    set var [Temp fn j]
    Emit fn "@@JT$n@@ $var = @@JZ$n@@;"
    return [dict create n $n repr $repr var $var ops {}]
}
proc ccompile::JoinAssign {fnVar joinVar op} {
    upvar 1 $fnVar fn
    upvar 1 $joinVar join
    set k [llength [dict get $join ops]]
    dict lappend join ops $op
    Emit fn "[dict get $join var] = @@JV[dict get $join n]_$k@@;"
}
# The join JOIN no branch completes into: its declaration is removed.
proc ccompile::JoinDrop {fnVar join} {
    upvar 1 $fnVar fn
    if {$join eq ""} {
        return
    }
    set token @@JT[dict get $join n]@@
    dict set fn lines [lmap line [dict get $fn lines] {
        if {[string first $token $line] >= 0} continue
        set line
    }]
}
proc ccompile::JoinClose {fnVar join} {
    upvar 1 $fnVar fn
    set repr [dict get $join repr]
    set ops [dict get $join ops]
    if {$repr eq "int" && $ops ne "" && [lsearch -not -exact -index 0 $ops i64] < 0} {
        set repr i64
    }
    set n [dict get $join n]
    set map [list @@JT$n@@ [CType $repr] @@JZ$n@@ [ZeroOf $repr]]
    set k 0
    foreach op $ops {
        lappend map @@JV${n}_$k@@ [Want fn $op $repr]
        incr k
    }
    dict set fn lines [lmap line [dict get $fn lines] {string map $map $line}]
    return [list $repr [dict get $join var]]
}

# 1 if the first expression of EXPRS is unreachable under the instance's
# facts (its branch never runs).
proc ccompile::DeadBranch {exprs} {
    variable hir
    if {$exprs eq ""} {
        return 0
    }
    return [expr {![dict get $hir exprs [lindex $exprs 0] reachable]}]
}

proc ccompile::If {fnVar e node want} {
    upvar 1 $fnVar fn
    set cond [Expr fn [dict get $node condition] value]
    if {[lindex $cond 0] eq "never"} {
        return $cond
    }
    if {[lindex $cond 0] ne "bool"} {
        Unsupported $e "an if whose condition is no Bool"
    }
    set thenBody [dict get $node thenBody]
    set elseBody [dict get $node elseBody]
    set thenDead [expr {[lindex $cond 1] eq "false" || [DeadBranch $thenBody]}]
    set elseDead [expr {[lindex $cond 1] eq "true" || [DeadBranch $elseBody]}]
    if {$thenDead && $elseDead} {
        return [list never ""]
    }
    set join [JoinOpen fn $e $want]
    set branchWant [expr {$join eq "" ? "discard" : "value"}]
    set live 0
    if {$thenDead || $elseDead} {
        # A branch the facts rule out is not compiled.
        set body [expr {$thenDead ? $elseBody : $thenBody}]
        if {[lindex $cond 1] ni {true false}} {
            if {$thenDead} {
                Emit fn "if (!([Bare [lindex $cond 1]])) \{"
            } else {
                Emit fn "if ([Bare [lindex $cond 1]]) \{"
            }
        } else {
            Emit fn "\{"
        }
        Indent fn 1
        set v [Sequence fn $body $branchWant]
        if {[lindex $v 0] ne "never"} {
            set live 1
            if {$join ne ""} {
                JoinAssign fn join $v
            }
        }
        Indent fn -1
        Emit fn "\}"
        if {!$live} {
            JoinDrop fn $join
            return [list never ""]
        }
        if {$join eq ""} {
            return [list unit 0]
        }
        return [JoinClose fn $join]
    }
    Emit fn "if ([Bare [lindex $cond 1]]) \{"
    Indent fn 1
    set v [Sequence fn $thenBody $branchWant]
    if {[lindex $v 0] ne "never"} {
        set live 1
        if {$join ne ""} {
            JoinAssign fn join $v
        }
    }
    Indent fn -1
    if {$elseBody ne ""} {
        Emit fn "\} else \{"
        Indent fn 1
        set v [Sequence fn $elseBody $branchWant]
        if {[lindex $v 0] ne "never"} {
            set live 1
            if {$join ne ""} {
                JoinAssign fn join $v
            }
        }
        Indent fn -1
    } else {
        set live 1
    }
    Emit fn "\}"
    if {!$live} {
        JoinDrop fn $join
        return [list never ""]
    }
    if {$join eq ""} {
        return [list unit 0]
    }
    return [JoinClose fn $join]
}

# A bare loop, a counted loop, or a fold over either. A collecting counted
# loop is compiled only where its List is discarded (its iterations run;
# nothing observes the List).
proc ccompile::Loop {fnVar e node want} {
    upvar 1 $fnVar fn
    set id [dict get $fn instance]
    set kind [dict get $node kind]
    set fold [dict exists $node foldBinding]
    if {$kind eq "countloop" && !$fold && $want ne "discard"} {
        Unsupported $e "a collecting loop whose List is used (a List of a length not known statically needs storage)"
    }
    set counted [expr {$kind eq "countloop"}]
    if {$counted} {
        set start [Expr fn [dict get $node start] value]
        if {[lindex $start 0] eq "never"} {
            return $start
        }
        set end [Expr fn [dict get $node end] value]
        if {[lindex $end 0] eq "never"} {
            return $end
        }
        set native [expr {[FitsI64 [OpRange fn [dict get $node start] $start]] && [FitsI64 [OpRange fn [dict get $node end] $end]]}]
        set crepr [expr {$native ? "i64" : "int"}]
        if {!$native} {
        }
        set s [Declare fn $crepr [Want fn $start $crepr] lo]
        set t [Declare fn $crepr [Want fn $end $crepr] hi]
    }
    set acc ""
    if {$fold} {
        set init [Expr fn [dict get $node foldInitial] value]
        if {[lindex $init 0] eq "never"} {
            return $init
        }
        set arepr [AccRepr fn $e $node $init]
        set acc [Declare fn $arepr [Want fn $init $arepr] acc]
        dict set fn locals [dict get $node foldBinding] [list $arepr $acc]
    }
    set brk [Label fn brk]
    set cont [Label fn cont]
    dict set fn loops $e [dict create break $brk continue $cont]
    set direction [dict getdef $node direction up]
    set endKind [dict getdef $node endKind exclusive]
    if {$counted} {
        set enter [CountTest fn $crepr $s $t [expr {$direction eq "up" ? ($endKind eq "inclusive" ? "<=" : "<") : ($endKind eq "inclusive" ? ">=" : ">")}]]
        Emit fn "if ($enter) \{"
        Indent fn 1
        set i [Declare fn $crepr $s i]
        dict set fn locals [dict get $node countBinding] [list $crepr $i]
    }
    Emit fn "for (;;) \{"
    Indent fn 1
    set bodyWant [expr {$fold ? "value" : "discard"}]
    set v [Sequence fn [dict get $node body] $bodyWant]
    if {[lindex $v 0] ne "never" && $fold} {
        Emit fn "$acc = [Want fn $v [lindex [dict get $fn locals [dict get $node foldBinding]] 0]];"
    }
    if {[dict exists $fn usedLabels $cont]} {
        Indent fn -1
        Emit fn "$cont:;"
        Indent fn 1
    }
    if {$counted} {
        set step [expr {$direction eq "up" ? "+" : "-"}]
        if {$endKind eq "inclusive"} {
            Emit fn "if ([CountTest fn $crepr $i $t ==]) \{"
            Indent fn 1
            Emit fn "break;"
            Indent fn -1
            Emit fn "\}"
            CountStep fn $crepr $i $step
        } else {
            CountStep fn $crepr $i $step
            Emit fn "if (!([CountTest fn $crepr $i $t [expr {$direction eq "up" ? "<" : ">"}]])) \{"
            Indent fn 1
            Emit fn "break;"
            Indent fn -1
            Emit fn "\}"
        }
    }
    Indent fn -1
    Emit fn "\}"
    if {$counted} {
        Indent fn -1
        Emit fn "\}"
    }
    set broken [dict exists $fn usedLabels $brk]
    if {$broken} {
        Emit fn "$brk:;"
    }
    # A bare loop with no break never completes normally.
    if {!$counted && !$broken} {
        return [list never ""]
    }
    if {$fold} {
        return [dict get $fn locals [dict get $node foldBinding]]
    }
    return [list unit 0]
}

# The C condition comparing counters A and B (REPR i64 or int) with OP.
proc ccompile::CountTest {fnVar repr a b op} {
    upvar 1 $fnVar fn
    if {$repr eq "i64"} {
        return "$a $op $b"
    }
    return "[Helper int_cmp]($a, $b) $op 0"
}

# Advances counter I (REPR) by one, in direction STEP (+ or -). The test
# that precedes it (inclusive) or follows it (exclusive) keeps the counter
# inside the domain, so an int64_t counter never overflows.
proc ccompile::CountStep {fnVar repr i step} {
    upvar 1 $fnVar fn
    if {$repr eq "i64"} {
        Emit fn "$i = $i $step 1;"
        return
    }
    set helper [Helper [expr {$step eq "+" ? "int_add" : "int_sub"}]]
    Checked fn "$helper\($i, [Helper int_of_i64](1), &$i)"
}

# The representation of fold E's intermediate: every intermediate (and so
# the fold's value) is the initial value or a normal completion of the body,
# so it fits int64_t when both of their Ranges do.
proc ccompile::AccRepr {fnVar e node init} {
    upvar 1 $fnVar fn
    set id [dict get $fn instance]
    set type [TypeOf $e]
    if {[hir::types::kindOf $type] eq "int"} {
        set body [dict get $node body]
        set fits [FitsI64 [OpRange fn [dict get $node foldInitial] $init]]
        if {$body ne "" && [FitsI64 [RangeOf $id [lindex $body end]]] == 0} {
            set fits 0
        }
        if {$fits} {
            return i64
        }
        return int
    }
    return [StorageRepr $type $e]
}

proc ccompile::Handle {fnVar e node want} {
    upvar 1 $fnVar fn
    variable prefix
    foreach payload [dict getdef $node handlerPayloads {}] {
        if {$payload ne ""} {
            Unsupported $e "a handler that binds an error's payload"
        }
    }
    set join [JoinOpen fn $e $want]
    set label [Label fn handler]
    set done [Label fn handled]
    set hst [Temp fn hst]
    # The status the dispatch tests: declared here only if some failure of
    # the call reaches the dispatch (an unused variable is a warning).
    set slot [llength [dict get $fn lines]]
    Emit fn "${prefix}_status $hst = ${prefix}_OK;"
    dict lappend fn handlers [list $label $hst]
    set value [Expr fn [dict get $node call] [expr {$join eq "" ? "discard" : "value"}]]
    dict set fn handlers [lrange [dict get $fn handlers] 0 end-1]
    set live 0
    set reached [dict exists $fn usedLabels $label]
    if {!$reached} {
        dict set fn lines [lreplace [dict get $fn lines] $slot $slot]
    }
    if {[lindex $value 0] ne "never"} {
        set live 1
        if {$join ne ""} {
            JoinAssign fn join $value
        }
        if {$reached} {
            dict set fn usedLabels $done 1
            Emit fn "goto $done;"
        }
    }
    if {$reached} {
        Emit fn "$label:"
        set first 1
        foreach name [dict get $node handlerNames] body [dict get $node handlerBodies] {
            set status [DeclaredStatus $name]
            if {$first} {
                Emit fn "if ($hst == $status) \{"
            } else {
                Emit fn "\} else if ($hst == $status) \{"
            }
            set first 0
            Indent fn 1
            set v [Sequence fn $body [expr {$join eq "" ? "discard" : "value"}]]
            if {[lindex $v 0] ne "never"} {
                set live 1
                if {$join ne ""} {
                    JoinAssign fn join $v
                }
                dict set fn usedLabels $done 1
                Emit fn "goto $done;"
            }
            Indent fn -1
        }
        if {$first} {
            Emit fn "\{"
        } else {
            Emit fn "\} else \{"
        }
        Indent fn 1
        Fail fn $hst
        Indent fn -1
        Emit fn "\}"
    }
    if {[dict exists $fn usedLabels $done]} {
        Emit fn "$done:;"
    }
    if {!$live} {
        JoinDrop fn $join
        return [list never ""]
    }
    if {$join eq ""} {
        return [list unit 0]
    }
    return [JoinClose fn $join]
}

# ---------------------------------------------------------------------------
# Assembly: the files of a compiled program

# A C string literal of TEXT (ASCII; anything else escaped).
proc ccompile::CString {text} {
    set out "\""
    foreach ch [split [encoding convertto utf-8 $text] ""] {
        scan $ch %c code
        if {$ch eq "\"" || $ch eq "\\"} {
            append out "\\$ch"
        } elseif {$code < 32 || $code > 126} {
            append out [format "\\%03o" $code]
        } else {
            append out $ch
        }
    }
    return "$out\""
}

# A JSON string of TEXT.
proc ccompile::JString {text} {
    set out "\""
    foreach ch [split $text ""] {
        scan $ch %c code
        switch -- $ch {
            "\"" { append out "\\\"" }
            "\\" { append out "\\\\" }
            "\n" { append out "\\n" }
            default {
                if {$code < 32} {
                    append out [format "\\u%04x" $code]
                } else {
                    append out $ch
                }
            }
        }
    }
    return "$out\""
}

proc ccompile::Banner {file source what} {
    set from [expr {$source eq "" ? "a Botlish program" : $source}]
    return "/*
 * $file -- $what
 * Generated by the Botlish C backend (main.tcl -emit-c) from $from.
 * Do not edit: regenerate it. Freestanding C11; see
 * C-COMPILE-FREESTANDING-MILESTONE-1.md for the target contract.
 */"
}

proc ccompile::Assemble {programId source} {
    variable prefix
    variable compiled
    variable aggregates
    variable aggregateOrder
    variable enums
    variable helpers
    variable statuses
    variable statics
    variable usesInt
    variable programResult
    variable programServices
    variable displayServices
    variable home
    variable abi
    set p $prefix
    set displayServices [dict create]

    # --- PREFIX.h
    set h [list [Banner $p.h $source "the interface of the generated program"]]
    lappend h "#ifndef ${p}_H_INCLUDED" "#define ${p}_H_INCLUDED" ""
    lappend h "#include <stdbool.h>" "#include <stddef.h>" "#include <stdint.h>" @@RTHEADER@@
    lappend h "" "/* What a run ended in: ${p}_OK, or the error (${p}_status_code names it). */" \
        "typedef int ${p}_status;"
    set index 0
    foreach entry $statuses {
        lassign $entry code message name
        lappend h "#define ${p}_$name $index"
        incr index
    }
    lappend h "" "typedef unsigned char ${p}_unit;"
    dict for {id cname} $enums {
        set cases [lmap c [hir::enums::cases $id] {string cat "${cname}_[Sanitize $c]"}]
        lappend h "" "/* enum $id */" "typedef enum $cname \{ [join $cases {, }] \} $cname;"
    }
    foreach key $aggregateOrder {
        set agg [dict get $aggregates $key]
        set cname [dict get $agg cname]
        set what [switch -- [dict get $agg kind] {
            named { string cat "struct [dict get $agg id]" }
            struct { string cat "an anonymous struct" }
            list { string cat "a List literal of [expr {[llength [dict get $agg fields]] / 2}] elements" }
        }]
        lappend h "" "/* $what */" "typedef struct $cname \{"
        if {[dict get $agg fields] eq ""} {
            lappend h "    unsigned char empty;"
        }
        foreach {field repr} [dict get $agg fields] {
            lappend h "    [CType $repr] [Member $field];"
        }
        lappend h "\} $cname;"
    }
    lappend h "" "/* The program's value. */" "typedef [CType $programResult] ${p}_value;" ""
    lappend h "/* Runs the program: on ${p}_OK its value is in *value. Not reentrant (the" \
        " * program's top-level values that functions read are file-scope objects). */" \
        "${p}_status ${p}_run(${p}_value *value);" "" \
        "/* The error code and message of STATUS, as every Botlish backend reports" \
        " * them (\"\" for ${p}_OK). */" \
        "const char *${p}_status_code(${p}_status status);" \
        "const char *${p}_status_message(${p}_status status);" "" \
        "/* ${p}_display.c (optional): the program's value as Botlish displays it," \
        " * written to BUFFER (at most CAPACITY bytes, no terminator); returns its" \
        " * full length. */" \
        "size_t ${p}_show(const ${p}_value *value, char *buffer, size_t capacity);" "" \
        "#endif"

    # --- PREFIX.c
    set c [list [Banner $p.c $source "the program"] "" "#include \"$p.h\""]
    if {[dict size $statics]} {
        lappend c "" "/* The program's top-level values its functions read, written by the program before any of them runs. */"
        dict for {b entry} $statics {
            lassign $entry repr cname
            lappend c "static [CType $repr] $cname;"
        }
    }
    foreach name [HelperOrder] {
        if {[dict exists $helpers $name]} {
            lappend c "" [string trimright [HelperText $name]]
        }
    }
    foreach name [lsort [dict keys $helpers]] {
        if {[string match zero:* $name]} {
            lappend c "" [string trimright [HelperText $name]]
        }
    }
    lappend c ""
    variable referenced
    set order [concat [list $programId] [lsort -dictionary [lsearch -all -inline -not -exact [dict keys $referenced] $programId]]]
    foreach id $order {
        lappend c "[lindex [dict get $compiled $id] 0];"
    }
    foreach id $order {
        lappend c "" [lindex [dict get $compiled $id] 1]
    }
    lappend c "" "${p}_status ${p}_run(${p}_value *value)" "\{" "    return ${p}_program(value);" "\}"
    set codes [lmap s $statuses {CString [lindex $s 0]}]
    set messages [lmap s $statuses {CString [lindex $s 1]}]
    lappend c "" "static const char *const ${p}_codes\[\] = \{" "    [join $codes ",\n    "]" "\};" \
        "static const char *const ${p}_messages\[\] = \{" "    [join $messages ",\n    "]" "\};" ""
    foreach {fn table} {code codes message messages} {
        lappend c "const char *${p}_status_$fn\(${p}_status status)" "\{" \
            "    if (status < 0 || status >= [llength $statuses]) \{" \
            "        return [CString [expr {$fn eq "code" ? "C UNKNOWN STATUS" : "a status this program does not define"}]];" \
            "    \}" "    return ${p}_$table\[status\];" "\}" ""
    }

    # --- PREFIX_display.c
    set d [Display $source]

    # The runtime-service interface is included (and written) only when the
    # generated code uses something it declares.
    set usesInt [expr {[string first botlish_rt_v1 "[join $h \n][join $c \n]$d"] >= 0}]
    set h [lmap line $h {
        if {$line ne "@@RTHEADER@@"} {
            set line
        } elseif {$usesInt} {
            string cat "#include \"botlish_rt_v1.h\""
        } else {
            continue
        }
    }]
    set files [dict create]
    dict set files $p.h "[join $h \n]\n"
    dict set files $p.c "[string trimright [join $c \n]]\n"
    dict set files ${p}_display.c $d
    dict for {file text} $files {
        if {[string first @@ $text] >= 0} {
            # A representation left open (a join or a result never closed):
            # the backend's own defect, never C to hand anyone.
            error "ccompile: internal error: $file holds an unresolved placeholder"
        }
    }
    dict set files $p.runtime.json [Manifest $source]
    if {$usesInt} {
        set channel [open [file join $home botlish_rt_v1.h]]
        fconfigure $channel -translation lf -encoding utf-8
        dict set files botlish_rt_v1.h [read $channel]
        close $channel
    }
    return [dict create prefix $p files $files \
        services [lsort [dict keys $programServices]] display [lsort [dict keys $displayServices]]]
}

# ---------------------------------------------------------------------------
# Display: PREFIX_display.c writes the program's value as Botlish shows it
# (core::value::show). A translation unit of its own, so that a program
# that never displays its value links none of what displaying needs.

proc ccompile::Display {source} {
    variable prefix
    variable programResult
    variable displayShown
    variable displayFns
    set p $prefix
    set displayShown [dict create]
    set displayFns {}
    variable displayI64 0
    set top [ShowCall $programResult "*value"]
    set lines [list [Banner ${p}_display.c $source "displaying the program's value"] "" "#include \"$p.h\"" "" \
        "typedef struct ${p}_text \{" "    char *buffer;" "    size_t capacity;" "    size_t length;" "\} ${p}_text;" "" \
        "static void ${p}_put(${p}_text *text, const char *s)" "\{" \
        "    for (; *s != '\\0'; s++) \{" \
        "        if (text->length < text->capacity) \{" "            text->buffer\[text->length\] = *s;" "        \}" \
        "        text->length++;" "    \}" "\}"]
    if {$displayI64} {
        lappend lines "" \
            "/* Decimal digits by subtraction: no division (a library routine on many" \
            " * 32-bit targets). */" \
            "static void ${p}_put_i64(${p}_text *text, int64_t value)" "\{" \
            "    static const uint64_t powers\[\] = \{" \
            "        10000000000000000000u, 1000000000000000000u, 100000000000000000u," \
            "        10000000000000000u, 1000000000000000u, 100000000000000u, 10000000000000u," \
            "        1000000000000u, 100000000000u, 10000000000u, 1000000000u, 100000000u," \
            "        10000000u, 1000000u, 100000u, 10000u, 1000u, 100u, 10u, 1u" \
            "    \};" \
            "    char digits\[2\] = \{0, 0\};" \
            "    uint64_t magnitude = value < 0 ? (uint64_t)0 - (uint64_t)value : (uint64_t)value;" \
            "    bool started = false;" \
            "    size_t k;" \
            "    if (value < 0) \{" "        ${p}_put(text, \"-\");" "    \}" \
            "    for (k = 0; k < sizeof powers / sizeof powers\[0\]; k++) \{" \
            "        char digit = '0';" \
            "        while (magnitude >= powers\[k\]) \{" "            magnitude -= powers\[k\];" "            digit++;" "        \}" \
            "        if (digit != '0' || started || powers\[k\] == 1u) \{" \
            "            started = true;" "            digits\[0\] = digit;" "            ${p}_put(text, digits);" "        \}" \
            "    \}" "\}"
    }
    lappend lines {*}$displayFns
    lappend lines "" "size_t ${p}_show(const ${p}_value *value, char *buffer, size_t capacity)" "\{" \
        "    ${p}_text text;" "    text.buffer = buffer;" "    text.capacity = capacity;" "    text.length = 0;" \
        "    (void)value;" "    $top;" "    return text.length;" "\}"
    return "[join $lines \n]\n"
}

# The C statement displaying VALUE (a C expression) of REPR into `text`.
proc ccompile::ShowCall {repr value {text &text}} {
    variable prefix
    variable aggregates
    variable enums
    variable displayShown
    variable displayFns
    variable displayServices
    variable services
    set p $prefix
    variable displayI64
    if {[lindex $repr 0] in {i64 int}} {
        set displayI64 1
    }
    switch -- [lindex $repr 0] {
        i64  { return "${p}_put_i64($text, $value)" }
        bool { return "${p}_put($text, ($value) ? \"true\" : \"false\")" }
        unit { return "${p}_put($text, \"unit\")" }
    }
    set key $repr
    if {![dict exists $displayShown $key]} {
        set fname ${p}_show[dict size $displayShown]
        dict set displayShown $key $fname
        switch -- [lindex $repr 0] {
            int {
                dict set displayServices int.to_decimal 1
                set symbol [lindex [dict get $services int.to_decimal] 0]
                lappend displayFns "" "static void $fname\(${p}_text *text, botlish_rt_v1_int value)" "\{" \
                    "    if (value.big == NULL) \{" "        ${p}_put_i64(text, value.small);" "        return;" "    \}" \
                    "    text->length += $symbol\(value, text->length < text->capacity ? text->buffer + text->length : text->buffer," \
                    "        text->length < text->capacity ? text->capacity - text->length : 0);" "\}"
            }
            enum {
                set id [lindex $repr 1]
                set cname [dict get $enums $id]
                set body {}
                foreach case [hir::enums::cases $id] {
                    lappend body "    case ${cname}_[Sanitize $case]:" "        ${p}_put(text, [CString "${id}::$case"]);" "        break;"
                }
                lappend displayFns "" "static void $fname\(${p}_text *text, $cname value)" "\{" "    switch (value) \{" {*}$body "    \}" "\}"
            }
            agg {
                set agg [dict get $aggregates [lindex $repr 1]]
                set cname [dict get $agg cname]
                set body {}
                set kind [dict get $agg kind]
                if {$kind eq "named" && [dict get $agg opaque]} {
                    lappend body "    (void)value;" "    ${p}_put(text, [CString "<opaque [dict get $agg id]>"]);"
                } else {
                    if {$kind eq "list"} {
                        set open "\["
                        set close "\]"
                    } else {
                        set open "\{"
                        set close "\}"
                    }
                    if {$kind eq "named"} {
                        set open "[dict get $agg id] \{"
                    }
                    lappend body "    ${p}_put(text, [CString $open]);"
                    set first 1
                    foreach {field frepr} [dict get $agg fields] {
                        set sep [expr {$first ? "" : ", "}]
                        set label [expr {$kind eq "list" ? "" : "$field: "}]
                        if {"$sep$label" ne ""} {
                            lappend body "    ${p}_put(text, [CString $sep$label]);"
                        }
                        lappend body "    [ShowCall $frepr "value->[Member $field]" text];"
                        set first 0
                    }
                    if {[dict get $agg fields] eq ""} {
                        lappend body "    (void)value;"
                    }
                    lappend body "    ${p}_put(text, [CString $close]);"
                }
                lappend displayFns "" "static void $fname\(${p}_text *text, const $cname *value)" "\{" {*}$body "\}"
            }
        }
    }
    set fname [dict get $displayShown $key]
    if {[lindex $repr 0] eq "agg"} {
        if {[string index $value 0] eq "*"} {
            return "$fname\($text, [string range $value 1 end])"
        }
        return "$fname\($text, &$value)"
    }
    return "$fname\($text, $value)"
}

# ---------------------------------------------------------------------------
# The runtime-requirements manifest (PREFIX.runtime.json): what the
# generated C requires of its environment, deterministically ordered.

proc ccompile::Manifest {source} {
    variable prefix
    variable programServices
    variable displayServices
    variable services
    variable abi
    variable usesInt
    set p $prefix
    set entries {}
    foreach service [lsort [concat [dict keys $programServices] [dict keys $displayServices]]] {
        if {[dict exists $entries $service]} continue
        set units {}
        if {[dict exists $programServices $service]} { lappend units [JString $p.c] }
        if {[dict exists $displayServices $service]} { lappend units [JString ${p}_display.c] }
        lassign [dict get $services $service] symbol description
        dict set entries $service "    \{\n      \"service\": [JString $service],\n      \"symbol\": [JString $symbol],\n      \"header\": \"botlish_rt_v1.h\",\n      \"description\": [JString $description],\n      \"required_by\": \[[join $units {, }]\]\n    \}"
    }
    set unitLines {}
    foreach {file role list} [list $p.c program [lsort [dict keys $programServices]] ${p}_display.c display [lsort [dict keys $displayServices]]] {
        lappend unitLines "    \{\"file\": [JString $file], \"role\": [JString $role], \"required_services\": \[[join [lmap s $list {JString $s}] {, }]\]\}"
    }
    set lines [list "\{" \
        "  \"format\": \"botlish-c-runtime-requirements\"," \
        "  \"format_version\": 1," \
        "  \"runtime_abi\": [JString $abi]," \
        "  \"program\": [JString $p]," \
        "  \"source\": [JString [file tail $source]]," \
        "  \"entry\": [JString ${p}_run]," \
        "  \"c_standard\": \"C11\"," \
        "  \"hosted\": false," \
        "  \"headers\": \[\"stdbool.h\", \"stddef.h\", \"stdint.h\"\]," \
        "  \"target_requirements\": \[\"a freestanding C11 implementation\", \"int64_t and uint64_t (exact-width two's complement types)\", \"no hosted library, allocation, I/O or entry point (the embedding calls the entry)\"\]," \
        "  \"runtime_header\": [expr {$usesInt ? {"botlish_rt_v1.h"} : "null"}]," \
        "  \"translation_units\": \[" "[join $unitLines ",\n"]" "  \],"]
    if {[dict size $entries] == 0} {
        lappend lines "  \"required_services\": \[\]"
    } else {
        lappend lines "  \"required_services\": \[" "[join [dict values $entries] ",\n"]" "  \]"
    }
    lappend lines "\}"
    return "[join $lines \n]\n"
}
