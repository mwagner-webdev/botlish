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
#   contexts        (C-CONTEXTS-FREESTANDING-MILESTONE-1.md) a context struct
#                   is a C struct like any other; `with context EXPR` stores
#                   its value in an object of the program function's own
#                   frame (PREFIX_program: one per run); a function whose
#                   transitive requirement (hir/contexts.tcl's
#                   requiredContexts) is not empty takes one `T *`
#                   parameter per context it requires, after its ordinary
#                   parameters, and every call passes the callee's
#                   requirement on from the caller's own parameters (or, in
#                   the program function, the installed objects); a context
#                   parameter `context io: T` is no C variable at all, its
#                   uses read through that pointer. Context traits, their
#                   selection and inject blocks are gone before any backend
#                   (the trait plan's monomorphized program calls the
#                   selected implementation directly; an inject block is an
#                   `if true:`), so nothing of them reaches C: no registry,
#                   no lookup, no global context, no dispatch.
#   coroutines      (C-COROUTINE-FRAMES-MILESTONE-1.md) a function that may
#                   yield is a stackless state machine: its C function takes
#                   a pointer to its *frame* (a struct of what survives its
#                   suspensions: a resume point, its parameters, the values
#                   live across a yield, the frame of the yielding call in
#                   progress), dispatches on the resume point and returns
#                   the internal status PREFIX_SUSPEND to suspend. A
#                   construction is storage in the constructing function's
#                   own frame (its C frame, or its persistent frame when it
#                   may yield itself): a C struct holding the coroutine's
#                   state, its cached result or error, the context pointers
#                   its construction selected and its thunk's frame; the
#                   handle is a pointer to it. No allocation, no stack per
#                   coroutine, no scheduler, no runtime service.
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
    # Context identities used, -> the C name of their installed object (in
    # the program function) and of the pointer parameter carrying it (in
    # every function that requires it): ContextName.
    variable contextNames {}
    # Coroutines (the Coroutines section): the coroutine kinds (one per
    # construction's thunk block), the handle types (one per C
    # representation of a handle: outward value and message), the handle
    # type each yielding instance's yields reach, and the frame types
    # (yielding functions' frames and kinds' storage structs) with what each
    # holds by value.
    variable coKinds {}
    variable coHandles {}
    variable yieldH {}
    variable frames {}
    # Thunk block -> its captured values (ThunkCaptures).
    variable thunkCaptures {}
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
    variable contextNames
    set contextNames [dict create]
    variable active
    variable fixedResults
    set active {}
    set fixedResults [dict create]
    variable coKinds
    variable coHandles
    variable yieldH
    variable frames
    set coKinds [dict create]
    set coHandles [dict create]
    set yieldH [dict create]
    set frames [dict create]
    variable thunkCaptures
    set thunkCaptures [dict create]
    # A program that failed context verification (a lenient HIR) has
    # context loads nothing proved are preceded by their installation: the C
    # of it is never generated (native lowering refuses to run it too). Its
    # first context diagnostic is the error, as the front end reports it.
    foreach d [dict getdef $hirProgram diagnostics {}] {
        if {[dict get $d kind] in [ContextDiagnosticKinds]} {
            core::raiseDiagnostics [hir::recovery::entries $hirProgram [list $d] 1]
        }
    }
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
        # A frame that holds itself by value (a yielding call or a
        # construction that recurses) has no C representation.
        FrameCycles
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
    if {[llength $viewType] == 1 && $viewType in {enum struct nstruct list coroutine} && [llength $baseType] > 1} {
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
        set thunk [dict exists $hir coroutines thunks $e]
        foreach b [concat [dict get $node captures] [dict getdef $node staticRefs {}]] {
            set binding [dict get $hir bindings $b]
            if {[dict get $binding kind] ni {local}} continue
            # A construction's thunk captures the construction's argument
            # temporaries, which the construction copies into the
            # coroutine's frame (Create): they are locals of the
            # constructing code, top-level code included.
            if {$thunk && [dict get $binding scope] eq [dict get $node scope]} continue
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
            if {[hir::enums::hasPayloads $id]} {
                # PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md: a payload-bearing
                # case has no C representation of this backend's (a C
                # enumeration constant is a payload-free case's only).
                Unsupported $e "an enum whose cases carry payloads ([hir::enums::display $id])"
            }
            RegisterEnum $id
            return [list enum $id]
        }
        struct {
            return [list agg [StructAggregate $type $e]]
        }
        coroutine {
            # A handle: a pointer to its coroutine's storage (Coroutines).
            if {![hir::types::IsCoroutine $type]} {
                Unsupported $e "a coroutine handle whose type is not known statically"
            }
            return [list co [HandleKey $type $e]]
        }
    }
    Unsupported $e "a value of type [hir::types::show $type]"
}

# The representation of a field or element of static TYPE: its own Range
# is the type's (no expression narrows a stored field).
proc ccompile::StorageRepr {type e} {
    if {[hir::types::IsAffine $type]} {
        # A handle inside a struct or a List would need the aggregate's drop
        # and move discipline in C; a handle is a local, a parameter or a
        # result here.
        Unsupported $e "a coroutine handle held in a struct or a List ([hir::types::show $type])"
    }
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
        co   {
            variable coHandles
            return "[dict get $coHandles [lindex $repr 1] cname] *"
        }
    }
    error "ccompile: no C type for representation $repr"
}

# The C declarator of NAME with C type CTYPE: `int64_t n`, and for a
# pointer type `T *` the conventional `T *n`.
proc ccompile::Declarator {ctype name} {
    if {[string index $ctype end] eq "*"} {
        return "$ctype$name"
    }
    return "$ctype $name"
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
        co   { return "NULL" }
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
        # (A context struct is an ordinary struct value: what makes it a
        # context is where its value comes from, which the call graph says.)
        if {[hir::structs::treeField $id] ne ""} {
            Unsupported $e "the tree struct [hir::structs::display $id] (a recursive value)"
        }
        if {[hir::structs::identityOf $id] ne ""} {
            Unsupported $e "the struct [hir::structs::display $id], which declares an identity"
        }
        set context [hir::structs::isContext $id]
        if {[hir::structs::IsAffine $id]} {
            if {$context} {
                # (An installed context owns its affine members:
                # CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md.)
                Unsupported $e "the context struct [hir::structs::display $id], which owns affine state (a C pointer, a coroutine, or a struct or collection holding one)"
            }
            Unsupported $e "the affine struct [hir::structs::display $id]"
        }
        # A struct that holds itself by value has no C representation; it is
        # rejected here, while its own registration is in progress.
        dict set aggregates $key [dict create cname "" kind pending]
        set fields {}
        foreach {field fieldType} [hir::structs::fieldTypes $id] {
            if {[catch {StorageRepr $fieldType $e} repr options]} {
                # Not registered: a later use is judged (and reported) again.
                dict unset aggregates $key
                if {$context && [dict get $options -errorcode] eq {C UNSUPPORTED}} {
                    Unsupported $e "the context struct [hir::structs::display $id], whose field \"$field\" has type [hir::types::show $fieldType],"
                }
                return -options $options $repr
            }
            if {$repr eq [list agg $key] || ([lindex $repr 0] eq "agg" && [dict get $aggregates [lindex $repr 1] kind] eq "pending")} {
                dict unset aggregates $key
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
# Contexts (CONTEXTS.md; C-CONTEXTS-FREESTANDING-MILESTONE-1.md)
#
# A Botlish program has one execution environment: at most one installed
# value per context-struct type, installed only at the entry program's top
# level, in source order. hir/contexts.tcl proved every load is preceded by
# its installation and computed each function's transitive requirement; the
# trait plan replaced every context-trait operation by a direct call of the
# selected implementation (CONTEXT-TRAITS.md, "Specialization and
# lowering"). What is left is said in C with explicit dependencies:
#
#   installation  `with context EXPR` (bind context#N EXPR, then
#                 context#install(context#N)) declares `T ctx_T = ...;`
#                 in the program function: the installed context is an
#                 object of that run's own frame, never file-scope storage,
#                 so two runs, or two programs, never share one.
#   requirement   a function whose block requires contexts R (sorted
#                 identities) takes one parameter `T *ctx_T` per T of
#                 R, after its ordinary ones: its C signature states its
#                 authority, exactly what it and its callees may use.
#   call          passes the callee block's requirement from the caller's own
#                 parameters (required(caller) holds required(callee) for
#                 every call its region makes) or, in the program function,
#                 the installed objects' addresses.
#   load          a context parameter `context io: T` binds io to `(*ctx_T)`
#                 and declares no C variable: a projection reads
#                 ctx_T->field, a use as a value copies the immutable
#                 installed value, as any struct is passed.
#
# Nothing writes through the pointer: the backend emits only reads of a
# context (a member mutated in place would be a MutableVector's or
# MutableArray's, which C does not represent yet), and a context parameter
# is immutable. Neither the pointer nor the object is const-qualified all
# the same: GCC takes the address of an object passed to a pointer-to-const
# parameter for a read of it (tree-ssa-uninit.cc's
# maybe_warn_pass_by_reference, which checks no other pointer parameter),
# and GCC 15, propagating a constant installed context into a clone of a
# recursive function, reported the initialized object "may be used
# uninitialized" (-Wmaybe-uninitialized, an error under -Werror;
# C-CONTEXTS-FREESTANDING-MILESTONE-1.md, section 16).

# The diagnostics of a program that failed context verification
# (hir/contexts.tcl): such a program is never compiled.
proc ccompile::ContextDiagnosticKinds {} {
    return {MISSING-CONTEXT DUPLICATE-CONTEXT NOT-A-CONTEXT CONTEXT-TYPE-NOT-EXACT
        CONTEXT-INSTALLATION-UNSUPPORTED CONTEXT-FUNCTION-VALUE CONTEXT-BINDING-COLLISION
        DUPLICATE-CONTEXT-PARAMETER AMBIGUOUS-CONTEXT-IMPLEMENTATION CONTEXT-NOT-INJECTED
        CONTEXT-RETAINED-AUTHORITY CONTEXT-TRAIT-SELECTION-CONFLICT}
}

# The C name of context ID's installed object and of the parameter that
# carries a pointer to it: ctx_ and the identity as a C identifier, unique
# in the program (two identities that read alike get a counter). Every
# global name the backend emits starts with PREFIX_, so no context name may:
# with the prefix `ctx` (a program file ctx.bot) the struct type ctx_Clock
# and a parameter ctx_Clock would collide, so the stem is cx_ there.
proc ccompile::ContextName {id} {
    variable contextNames
    variable prefix
    if {![dict exists $contextNames $id]} {
        foreach base {ctx cx context} {
            set stem ${base}_[Sanitize $id]
            if {![string match "${prefix}_*" $stem]} break
        }
        set name $stem
        set k 1
        while {$name in [dict values $contextNames]} {
            incr k
            set name ${stem}_$k
        }
        dict set contextNames $id $name
    }
    return [dict get $contextNames $id]
}

# The representation of context ID's value (E: where, for diagnostics): the
# C struct of its context-struct declaration.
proc ccompile::ContextRepr {id e} {
    if {![hir::structs::declared $id] || ![hir::structs::isContext $id]} {
        # (The monomorphized program requires context structs only.)
        Unsupported $e "a requirement of $id, which is no context struct"
    }
    return [list agg [StructAggregate [list nstruct $id] $e]]
}

# The context identities block BLOCK requires (transitively, sorted): the
# pointer parameters of each of its instances' C functions, in order.
proc ccompile::ContextRequirement {block} {
    variable baseHir
    if {$block eq "program"} {
        return {}
    }
    return [hir::contexts::required $baseHir $block]
}

# The C arguments call E of block BLOCK passes for BLOCK's requirement: the
# calling function's own pointer to each context (its parameter, or the
# program function's installed object's address).
proc ccompile::ContextArgs {fnVar block e} {
    upvar 1 $fnVar fn
    set words {}
    foreach id [ContextRequirement $block] {
        if {![dict exists $fn contexts $id]} {
            # Verification proved the caller requires (or, at the top level,
            # has installed) every context its reachable calls need.
            error "ccompile: internal error: call $e needs context $id, which the function compiling it does not have"
        }
        lappend words [dict get $fn contexts $id]
    }
    return $words
}

# `with context VALUE` (call E of context#install, NODE): VALUE becomes the
# installed context of its verified identity, an object of the program
# function's frame, from here to the end of the run (never written again).
proc ccompile::Install {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    if {[dict get $fn block] ne "program"} {
        Unsupported $e "a context installation outside the entry program's top level (a thread entry's)"
    }
    set id [hir::contexts::installId $hir $e]
    if {$id eq ""} {
        error "ccompile: internal error: installation $e has no verified context identity"
    }
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    set repr [ContextRepr $id $e]
    set c [ContextName $id]
    Emit fn "[CType $repr] $c = [Want fn [lindex $ops 0] $repr];"
    # (An installed context nothing reaches is still installed: marked used.)
    Emit fn "@@UNREAD:ctx:$c@@"
    dict set fn contexts $id "&$c"
    return [list unit 0]
}

# The operand of a load of context ID at E: the installed value, read
# through the function's pointer to it.
proc ccompile::ContextValue {fnVar e id} {
    upvar 1 $fnVar fn
    if {![dict exists $fn contexts $id]} {
        error "ccompile: internal error: context load $e of $id, which the function compiling it does not have"
    }
    set pointer [dict get $fn contexts $id]
    if {[string index $pointer 0] eq "&"} {
        set code [string range $pointer 1 end]
    } else {
        set code "(*$pointer)"
    }
    return [list [ContextRepr $id $e] $code]
}

# ---------------------------------------------------------------------------
# Coroutines (COROUTINES.md; C-COROUTINE-FRAMES-MILESTONE-1.md)
#
# A Botlish coroutine is an eagerly started, affine resumable computation
# whose yields may happen at any depth of its synchronous call stack. The
# front end proved everything static about it (hir/coroutines.tcl): which
# functions may yield (mayYield), the one protocol of each coroutine, that
# every yielding call graph is entered through a construction, that every
# handle has one owner (hir/affine.tcl), and that a segment hands out only
# unrestricted values (AffineProtocol). What is left is said in C as
# stackless state machines over explicit frames:
#
#   yielding function  an instance whose block may yield (or a thunk) is a C
#                 function over its *frame* (PREFIX_N_name_frame): a resume
#                 point, its parameters (the caller writes them into the
#                 frame), every value that lives across one of its
#                 suspensions (Persist), and a union of the frames of its
#                 yielding calls (one is in progress at a time). It starts
#                 with a dispatch on the resume point, takes its context
#                 pointers as every function does, a pointer to the
#                 coroutine's outward slot (yslot) and, for a struct
#                 protocol, to its message slot (mslot), and returns
#                 PREFIX_SUSPEND to suspend: never an error, never a
#                 handler's, never a run's.
#   yield V       writes V to *yslot, records its resume point and returns
#                 PREFIX_SUSPEND; resumed, it continues at its label, the
#                 message (*mslot) its value.
#   yielding call writes the arguments into the callee's frame in the
#                 union, resets its resume point, then calls it at a resume
#                 label of its own: suspended, the caller records that label
#                 and suspends too; resumed, it calls the callee again,
#                 which continues where it stopped.
#   kind          each construction's thunk is a kind: its storage struct
#                 PREFIX_coK holds the handle's target (PREFIX_cohH: state,
#                 cached failure, the outward value, the message), the
#                 context pointers the construction's requirement names --
#                 its providers are the construction's, never a resumer's --
#                 and the thunk's frame (its captured arguments, the root's
#                 frame).
#   construction  storage in the constructing function's own frame (its C
#                 frame, or its persistent frame when it may yield), zeroed
#                 and filled in; the handle is a pointer to its target. A
#                 function that constructs a coroutine never returns a
#                 handle (Function), so no handle outlives its storage.
#   resume        PREFIX_cohH_resume: a terminal coroutine answers its
#                 cached result or error again and runs nothing; a
#                 suspended one runs its next segment (a switch on its kind
#                 when several kinds share the handle type: a direct call
#                 of each).
#   release       nothing: no frame of the supported subset owns anything
#                 to clean up (affine state other than handles, and
#                 resources, are C UNSUPPORTED), and the affine analysis
#                 guarantees nothing reaches a released handle.
#
# No allocation, no stack per coroutine, no thread, no scheduler, no
# runtime service: a coroutine program needs nothing a coroutine-free one
# does not.

# 1 if block BLOCK is a coroutine construction's thunk.
proc ccompile::IsThunk {block} {
    variable baseHir
    return [dict exists $baseHir coroutines thunks $block]
}

# 1 if instance ID is compiled as a state machine: its block may yield, or
# it is a thunk (a coroutine's entry, always resumable).
proc ccompile::IsYieldingInstance {id} {
    variable spec
    variable baseHir
    set block [dict get [hir::specialize::instance $spec $id] block]
    if {$block eq "program"} {
        return 0
    }
    return [expr {[IsThunk $block] || [hir::coroutines::MayYield $baseHir $block]}]
}

# The C name of parameter binding B (a C variable, or a frame member).
proc ccompile::ParamName {b} {
    variable baseHir
    return p_[Sanitize [dict get [hir::binding $baseHir $b] name]]_[string range $b 1 end]
}

# The frame type of yielding instance ID.
proc ccompile::FrameName {id} {
    return [lindex [Params $id] 0]_frame
}

# The instance of thunk THUNK (its generic one: a thunk is a value).
proc ccompile::ThunkInstance {thunk} {
    variable spec
    variable baseHir
    set id [hir::specialize::genericInstance $baseHir $spec $thunk]
    if {$id eq ""} {
        Unsupported $thunk "a coroutine construction the specialization did not analyze"
    }
    return $id
}

# What thunk THUNK says in a comment: its root's name and where it is.
proc ccompile::ThunkTitle {thunk} {
    variable baseHir
    set root [dict get $baseHir coroutines thunks $thunk root]
    set name [if {$root eq ""} {string cat "a coroutine"} else {hir::aot::BlockName $baseHir $root}]
    if {$name eq ""} {
        set name "a function"
    }
    # (The file's name only: no host path in generated C.)
    set where [hir::originLocation $baseHir [hir::get $baseHir $thunk origin]]
    regsub {^.*[/\\]} $where "" where
    return "$name, constructed at $where"
}

# Thunk THUNK's captured values (functions it captures are called
# directly): {BINDING MEMBER REPR} each, the frame member a construction
# copies the value into. An Int is carried as an int64_t when the range
# analysis proved every use in the thunk fits (the uses' Ranges join every
# construction's value).
proc ccompile::ThunkCaptures {thunk} {
    variable thunkCaptures
    variable baseHir
    variable ranges
    if {[dict exists $thunkCaptures $thunk]} {
        return [dict get $thunkCaptures $thunk]
    }
    set tid [ThunkInstance $thunk]
    # Every reference of each captured binding in the thunk, and its Range.
    set rangesOf [dict create]
    set work [hir::get $baseHir $thunk body]
    while {$work ne ""} {
        set work [lassign $work e]
        set node [dict get $baseHir exprs $e]
        if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""} {
            dict lappend rangesOf [dict get $node binding] [hir::range::of $ranges $tid $e]
        }
        if {[dict get $node kind] ne "block"} {
            lappend work {*}[hir::children $baseHir $e]
        }
    }
    set result {}
    foreach b [hir::get $baseHir $thunk captures] {
        if {[hir::aot::BoundBlock $baseHir $b] ne ""} continue
        set range [hir::range::unknown]
        if {[dict exists $rangesOf $b]} {
            set range never
            foreach r [dict get $rangesOf $b] {
                set range [hir::range::join $range $r]
            }
        }
        set member c_[Sanitize [dict get [hir::binding $baseHir $b] name]]_[string range $b 1 end]
        lappend result [list $b $member [ReprOf [hir::bindingType $baseHir $b] $range $thunk]]
    }
    dict set thunkCaptures $thunk $result
    return $result
}

# The handle type key of coroutine type TYPE: {OUTWARD-REPR MESSAGE-REPR}
# (unit for the zero-message protocol), registered with its C struct name.
proc ccompile::HandleKey {type e} {
    variable coHandles
    variable prefix
    set protocol [hir::types::CoroutineResume $type]
    if {$protocol eq "any"} {
        Unsupported $e "a coroutine whose resume protocol is not known statically"
    }
    set out [StorageRepr [hir::types::CoroutineOutward $type] $e]
    set msg [if {$protocol eq "unit"} {string cat unit} else {StorageRepr $protocol $e}]
    set key [list $out $msg]
    if {![dict exists $coHandles $key]} {
        set index [expr {[dict size $coHandles] + 1}]
        dict set coHandles $key [dict create cname ${prefix}_coh$index out $out msg $msg kinds {}]
    }
    return $key
}

# {OUTWARD-REPR MESSAGE-REPR} of handle type H.
proc ccompile::HandleSlots {h} {
    return $h
}

# Records that the yields of instance ID reach coroutines of handle type H
# (E: the call or construction that says so). A yielding instance has one
# outward slot and one message slot type: two coroutines of different C
# representations reaching it are refused.
proc ccompile::SetYieldH {id h e} {
    variable yieldH
    if {[dict exists $yieldH $id]} {
        if {[dict get $yieldH $id] ne $h} {
            Unsupported $e "a function that may yield reached by coroutines whose outward values or messages have different C representations"
        }
        return
    }
    dict set yieldH $id $h
}

# The coroutine kind of thunk THUNK, constructed with handle type H at E:
# registered (its storage struct, its tag among H's kinds) and its thunk
# compiled. Registered before the thunk is compiled, so a construction
# reached again while it compiles finds it (FrameCycles judges a frame that
# would hold itself).
proc ccompile::CoKind {thunk h e} {
    variable coKinds
    variable coHandles
    variable referenced
    variable prefix
    variable frames
    if {[dict exists $coKinds $thunk]} {
        return [dict get $coKinds $thunk]
    }
    set tid [ThunkInstance $thunk]
    SetYieldH $tid $h $e
    set index [expr {[dict size $coKinds] + 1}]
    set cname ${prefix}_co$index
    set tag [llength [dict get $coHandles $h kinds]]
    dict set coHandles $h kinds [concat [dict get $coHandles $h kinds] [list $thunk]]
    set contexts [ContextRequirement $thunk]
    set kind [dict create cname $cname thunk $thunk instance $tid h $h tag $tag \
        contexts $contexts captures [ThunkCaptures $thunk]]
    dict set coKinds $thunk $kind
    set fields [list [list [dict get $coHandles $h cname] head]]
    foreach cid $contexts {
        lappend fields [list "[CType [ContextRepr $cid $thunk]] *" [ContextName $cid]]
    }
    lappend fields [list [FrameName $tid] body]
    dict set frames $cname [dict create role kind title "the storage of a coroutine of [ThunkTitle $thunk]" \
        fields $fields union {} deps [list [list [FrameName $tid] $e]] persistent {}]
    dict set referenced $tid 1
    Signature $tid
    return $kind
}

# `coroutine#create(THUNK)` (call E, NODE): the coroutine's storage, an
# object of the constructing function's frame, zeroed (a fresh coroutine is
# suspended before its start, resume point 0) and given the construction's
# context pointers and captured values. The operand is the handle: a
# pointer to the storage's target.
proc ccompile::Create {fnVar e node} {
    upvar 1 $fnVar fn
    variable statics
    set thunk [lindex [dict get $node args] 0]
    if {[Kind $thunk] ne "block" || ![IsThunk $thunk]} {
        Unsupported $e "a coroutine construction whose thunk is computed"
    }
    set h [HandleKey [TypeOf $e] $e]
    set kind [CoKind $thunk $h $e]
    set cname [dict get $kind cname]
    set co [Temp fn co]
    Emit fn "@@S@@[Declarator $cname $co];"
    dict lappend fn constructs [list $co $cname $e]
    # (A compound literal of the universal zero initializer: no data object,
    # and the compiler zeroes it in place.)
    Emit fn "$co = ($cname)\{0\};"
    variable coHandles
    Emit fn "@@KIND:[dict get $coHandles $h cname]@@$co.head.kind = [dict get $kind tag];"
    foreach cid [dict get $kind contexts] pointer [ContextArgs fn $thunk $e] {
        Emit fn "$co.[ContextName $cid] = $pointer;"
    }
    foreach entry [dict get $kind captures] {
        lassign $entry b member repr
        if {[dict exists $fn locals $b]} {
            set op [dict get $fn locals $b]
        } elseif {[dict exists $statics $b]} {
            set op [dict get $statics $b]
        } else {
            error "ccompile: internal error: construction $e captures [dict get [hir::binding [set ::ccompile::baseHir] $b] name], which the function compiling it has not placed"
        }
        Emit fn "$co.body.$member = [Want fn $op $repr];"
    }
    return [list [list co $h] "(&$co.head)"]
}

# `coroutine#start(H)` and `coroutine#resume(H, M...)` (call E, NODE): the
# message into the handle's slot, then its next segment; the segment's
# error is the call's, as for any call (its handlers, its function's).
proc ccompile::Resume {fnVar e node} {
    upvar 1 $fnVar fn
    variable coHandles
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    set handle [lindex $ops 0]
    if {[lindex $handle 0 0] ne "co"} {
        error "ccompile: internal error: the resumed value at $e is no coroutine handle"
    }
    set h [lindex $handle 0 1]
    lassign [HandleSlots $h] outRepr msgRepr
    if {[llength $ops] > 1 && $msgRepr ne "unit"} {
        Emit fn "[lindex $handle 1]->message = [Want fn [lindex $ops 1] $msgRepr];"
    }
    set t [Temp fn r]
    Decl fn [CType $outRepr] $t
    Checked fn "[dict get $coHandles $h cname]_resume([lindex $handle 1], &$t)"
    return [Narrowed fn $e [list $outRepr $t]]
}

# `coroutine#yield(V)` (call E, NODE) in a yielding function: V to the
# outward slot, the resume point recorded, PREFIX_SUSPEND returned; resumed
# at its label, its value is the message (copied: a later yield replaces the
# slot's).
proc ccompile::Yield {fnVar e node want} {
    upvar 1 $fnVar fn
    variable prefix
    if {![dict get $fn yielding]} {
        error "ccompile: internal error: yield $e outside a function that may yield"
    }
    set ops [Operands fn $node]
    if {$ops eq ""} {
        return [list never ""]
    }
    lassign [HandleSlots [dict get $fn h]] outRepr msgRepr
    dict incr fn resumes
    set k [dict get $fn resumes]
    Emit fn "*yslot = [Want fn [lindex $ops 0] $outRepr];"
    Emit fn "fr->resume = $k;"
    Emit fn "return ${prefix}_SUSPEND;"
    Indent fn -1
    Emit fn "@@R@@resume_$k:;"
    Indent fn 1
    if {$msgRepr eq "unit" || $want eq "discard"} {
        return [list unit 0]
    }
    set m [Temp fn msg]
    Decl fn [CType $msgRepr] $m "*mslot"
    return [list $msgRepr $m]
}

# The call E (NODE) of yielding instance CALLEE from a yielding function:
# the arguments into the callee's frame (a member of the caller's frame's
# union: one yielding call is in progress at a time), its resume point
# reset, then the call at a resume label of its own. Suspended, the caller
# suspends at that label; resumed there, it calls the callee again, which
# continues where it stopped.
proc ccompile::YieldingCall {fnVar e node callee} {
    upvar 1 $fnVar fn
    variable spec
    variable baseHir
    variable prefix
    variable referenced
    if {![dict get $fn yielding]} {
        error "ccompile: internal error: call $e of a function that may yield, outside a coroutine"
    }
    set h [dict get $fn h]
    SetYieldH $callee $h $e
    lassign [Signature $callee] cname paramReprs resultRepr
    dict set referenced $callee 1
    set calleeBlock [dict get [hir::specialize::instance $spec $callee] block]
    set args {}
    foreach arg [dict get $node args] repr $paramReprs {
        set op [Expr fn $arg value]
        if {[lindex $op 0] eq "never"} {
            return $op
        }
        lappend args [list $op $repr]
    }
    dict incr fn resumes
    set k [dict get $fn resumes]
    set member c$k
    dict set fn subs $member [list [FrameName $callee] $e]
    set sub "fr->sub.$member"
    foreach b [hir::get $baseHir $calleeBlock params] pair $args {
        lassign $pair op repr
        Emit fn "$sub.[ParamName $b] = [Want fn $op $repr];"
    }
    Emit fn "$sub.resume = 0;"
    Indent fn -1
    Emit fn "@@R@@resume_$k:;"
    Indent fn 1
    set t [Temp fn r]
    Decl fn [CType $resultRepr] $t
    set words [list "&$sub" {*}[ContextArgs fn $calleeBlock $e] yslot]
    if {[lindex [HandleSlots $h] 1] ne "unit"} {
        lappend words mslot
    }
    lappend words "&$t"
    set st [Temp fn st]
    Decl fn ${prefix}_status $st "$cname\([join $words {, }])"
    Emit fn "if ($st == ${prefix}_SUSPEND) \{"
    Emit fn "    fr->resume = $k;"
    Emit fn "    return ${prefix}_SUSPEND;"
    Emit fn "\}"
    if {[dict get [hir::specialize::instance $spec $callee] result] eq "never"} {
        Fail fn $st
        return [list never ""]
    }
    Emit fn "if ($st != ${prefix}_OK) \{"
    Indent fn 1
    Fail fn $st
    Indent fn -1
    Emit fn "\}"
    return [list $resultRepr $t]
}

# The dispatch a yielding function starts with: to the label of the resume
# point its frame records (0: the start).
proc ccompile::Dispatch {n} {
    if {$n == 0} {
        return {}
    }
    set out [list "    switch (fr->resume) \{"]
    for {set k 1} {$k <= $n} {incr k} {
        lappend out "    case $k:" "        goto resume_$k;"
    }
    lappend out "    default:" "        break;" "    \}"
    return $out
}

# The smallest unsigned C type that holds resume points 0..N.
proc ccompile::ResumeType {n} {
    if {$n <= 255} {
        return "unsigned char"
    }
    if {$n <= 65535} {
        return "unsigned short"
    }
    return "unsigned int"
}

# Registers the frame type of yielding instance ID (C function CNAME, block
# BLOCK; PARAMS its parameters as PARAMREPRS; FIELDS Persist's persistent
# variables; FN the compiled function's state: its resume points, its
# yielding calls' frames, its constructions' storage).
proc ccompile::FrameType {id cname block paramReprs params fields fnState} {
    variable frames
    variable baseHir
    set out [list [list [ResumeType [dict get $fnState resumes]] resume]]
    set persistent {}
    if {[IsThunk $block]} {
        foreach entry [ThunkCaptures $block] {
            lassign $entry b member repr
            lappend out [list [CType $repr] $member]
        }
        set title "the coroutine of [ThunkTitle $block]"
    } else {
        set title "[hir::aot::BlockName $baseHir $block] ($id)"
    }
    foreach b $params repr $paramReprs {
        lappend out [list [CType $repr] [ParamName $b]]
    }
    set deps {}
    set storage [dict create]
    foreach entry [dict get $fnState constructs] {
        lassign $entry var kindName e
        dict set storage $var [list $kindName $e]
    }
    foreach field $fields {
        lassign $field ctype name
        lappend out $field
        if {[dict exists $storage $name]} {
            lappend deps [dict get $storage $name]
        } else {
            lappend persistent $name
        }
    }
    set union {}
    dict for {member entry} [dict get $fnState subs] {
        lassign $entry frame e
        lappend union [list $frame $member]
        lappend deps [list $frame $e]
    }
    dict set frames ${cname}_frame [dict create role frame title $title fields $out union $union \
        deps $deps persistent $persistent]
}

# Every frame type that would hold itself by value -- a yielding function
# that calls itself (directly or through other yielding functions or
# constructions whose storage its frame holds) -- is C UNSUPPORTED at the
# call or construction that closes the cycle: its suspended calls need
# storage no fixed frame has.
proc ccompile::FrameCycles {} {
    variable frames
    variable diagnostics
    set state [dict create]
    set reported [dict create]
    foreach name [lsort [dict keys $frames]] {
        if {[dict exists $state $name]} continue
        set stack [list [list $name 0]]
        dict set state $name open
        while {$stack ne ""} {
            lassign [lindex $stack end] node k
            set deps [dict getdef $frames $node deps {}]
            if {$k >= [llength $deps]} {
                dict set state $node done
                set stack [lrange $stack 0 end-1]
                continue
            }
            lset stack end 1 [expr {$k + 1}]
            lassign [lindex $deps $k] dep e
            if {![dict exists $frames $dep]} continue
            switch -- [dict getdef $state $dep ""] {
                open {
                    if {![dict exists $reported $e]} {
                        dict set reported $e 1
                        if {[catch {Unsupported $e "a coroutine whose suspended calls recurse (a function that may yield, called or constructed again from its own suspended call chain, needs a frame that holds itself: unbounded storage)"} message]} {
                            lappend diagnostics [dict create message $message errorcode {C UNSUPPORTED}]
                        }
                    }
                }
                done {}
                default {
                    dict set state $dep open
                    lappend stack [list $dep 0]
                }
            }
        }
    }
}

# The frame types in definition order: each after every type it holds by
# value.
proc ccompile::FrameOrder {} {
    variable frames
    set order {}
    set seen [dict create]
    foreach name [dict keys $frames] {
        FrameVisit $name seen order
    }
    return $order
}
proc ccompile::FrameVisit {name seenVar orderVar} {
    upvar 1 $seenVar seen $orderVar order
    variable frames
    if {[dict exists $seen $name] || ![dict exists $frames $name]} {
        return
    }
    dict set seen $name 1
    foreach dep [dict get $frames $name deps] {
        FrameVisit [lindex $dep 0] seen order
    }
    lappend order $name
}

# A non-yielding function's LINES with Decl's marks dropped and its
# constructions' storage (@@S@@) moved to its top: {LINES HOISTED}.
proc ccompile::Unmark {lines} {
    set hoisted {}
    set out {}
    foreach line $lines {
        if {[regexp {^\s*@@S@@(.*);$} $line -> decl]} {
            lappend hoisted $decl
            continue
        }
        if {[string first @@D@@ $line] >= 0} {
            set line [string map {@@D@@ ""} $line]
        }
        lappend out $line
    }
    return [list $out $hoisted]
}

# The frame pass of a yielding function's LINES -- every declaration marked
# by Decl (@@D@@), every resume label (@@R@@), every construction's storage
# (@@S@@) -- deciding what survives a suspension:
#
# * A variable declared at line D, whose scope (the rest of its C block)
#   holds a resume label L after D, is *persistent* when a reference to it
#   is reachable from L: after L in its scope, or anywhere in a loop of its
#   scope that encloses L (the loop's next iteration runs from its start).
#   A persistent variable is a frame field: its declaration becomes an
#   assignment of the field, every use reads the field.
# * A variable whose scope holds a resume label but no reference reachable
#   from one is declared at the function's top (an assignment where it was
#   declared), so the dispatch's jump to the label skips no declaration.
# * Every other declaration stays where it is.
# * A construction's storage is always a frame field: the handle that
#   points to it may live in any C block, and across any suspension.
#
# Nothing else is moved: a value's lifetime that ends before a suspension
# never costs frame space. Returns {LINES FIELDS HOISTED}: FIELDS {CTYPE
# NAME} in declaration order, HOISTED the top's declarations.
proc ccompile::Persist {lines} {
    set n [llength $lines]
    set blocks {}
    set stack {}
    set innermost {}
    set labels {}
    set decls {}
    set refs [dict create]
    for {set i 0} {$i < $n} {incr i} {
        set line [lindex $lines $i]
        set text [string trim $line]
        if {[string index $text 0] eq "\}"} {
            set k [lindex $stack end]
            set stack [lrange $stack 0 end-1]
            lset blocks $k 1 $i
        }
        lappend innermost [if {$stack eq ""} {string cat -1} else {lindex $stack end}]
        if {[string index $text end] eq "\{"} {
            lappend stack [llength $blocks]
            lappend blocks [list $i $n [expr {$text eq "for (;;) \{"}]]
        }
        if {[string match @@R@@* $text]} {
            lappend labels $i
            continue
        }
        if {[regexp {^(\s*)@@([DS])@@(.*);$} $line -> indent mark decl]} {
            # TYPE NAME, or TYPE NAME = INIT (Declarator's TYPE *NAME for a
            # pointer): no type holds " = ".
            set at [string first " = " $decl]
            if {$at < 0} {
                set left $decl
                set init ""
            } else {
                set left [string range $decl 0 [expr {$at - 1}]]
                set init [string range $decl [expr {$at + 3}] end]
            }
            if {![regexp {^(.*[^A-Za-z0-9_])([A-Za-z_][A-Za-z0-9_]*)$} $left -> ctype name]} {
                error "ccompile: internal error: unreadable declaration \"$decl\""
            }
            lappend decls [dict create line $i indent $indent ctype [string trimright $ctype] name $name \
                init $init storage [expr {$mark eq "S"}]]
            foreach word [lsort -unique [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $init]] {
                dict lappend refs $word $i
            }
            continue
        }
        if {[regexp {^\(void\)[A-Za-z_][A-Za-z0-9_]*;$} $text]} continue
        foreach word [lsort -unique [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $text]] {
            dict lappend refs $word $i
        }
    }
    set loops [lmap b $blocks {if {[lindex $b 2]} {set b} else continue}]
    set persistent [dict create]
    set hoist [dict create]
    foreach d $decls {
        set name [dict get $d name]
        set at [dict get $d line]
        if {[dict get $d storage]} {
            dict set persistent $name 1
            continue
        }
        set owner [lindex $innermost $at]
        set end [if {$owner < 0} {set n} else {lindex $blocks $owner 1}]
        set within [lmap l $labels {if {$l > $at && $l < $end} {set l} else continue}]
        if {$within eq ""} continue
        set uses [dict getdef $refs $name {}]
        set live 0
        foreach l $within {
            foreach r $uses {
                if {$r > $l && $r < $end} {
                    set live 1
                    break
                }
            }
            if {$live} break
            foreach loop $loops {
                lassign $loop s e
                if {$s > $at && $s < $l && $l < $e && $e <= $end} {
                    foreach r $uses {
                        if {$r >= $s && $r <= $e} {
                            set live 1
                            break
                        }
                    }
                }
                if {$live} break
            }
            if {$live} break
        }
        if {$live} {
            dict set persistent $name 1
        } else {
            dict set hoist $name 1
        }
    }
    # Every use of a persistent variable reads the frame's field.
    set rewrite [dict keys $persistent]
    set out {}
    set fields {}
    set hoisted {}
    set declAt [dict create]
    foreach d $decls {
        dict set declAt [dict get $d line] $d
    }
    for {set i 0} {$i < $n} {incr i} {
        set line [lindex $lines $i]
        if {[dict exists $declAt $i]} {
            set d [dict get $declAt $i]
            set name [dict get $d name]
            set ctype [dict get $d ctype]
            set init [Fields [dict get $d init] $rewrite]
            set indent [dict get $d indent]
            if {[dict exists $persistent $name]} {
                lappend fields [list $ctype $name]
                if {$init ne ""} {
                    lappend out "${indent}fr->$name = $init;"
                }
            } elseif {[dict exists $hoist $name]} {
                lappend hoisted [Declarator $ctype $name]
                if {$init ne ""} {
                    lappend out "${indent}$name = $init;"
                }
            } else {
                set text [Declarator $ctype $name]
                if {$init ne ""} {
                    append text " = $init"
                }
                lappend out "${indent}$text;"
            }
            continue
        }
        if {[string first @@R@@ $line] >= 0} {
            set line [string map {@@R@@ ""} $line]
        }
        lappend out [Fields $line $rewrite]
    }
    return [list $out $fields $hoisted]
}

# LINE with every use of a variable of NAMES read from the frame (fr->NAME).
proc ccompile::Fields {line names} {
    if {$names eq "" || $line eq ""} {
        return $line
    }
    foreach word [lsort -unique [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $line]] {
        if {$word in $names} {
            regsub -all "\\m$word\\M" $line "fr->$word" line
        }
    }
    return $line
}

# The C text of the coroutine types (PREFIX.h): each handle type's target,
# then every frame and storage type, each after what it holds.
proc ccompile::CoroutineTypes {} {
    variable coHandles
    variable frames
    variable prefix
    set lines {}
    if {[dict size $coHandles] == 0} {
        return $lines
    }
    lappend lines "" "/* Coroutines (C-COROUTINE-FRAMES-MILESTONE-1.md): each type below is a" \
        " * fixed-size frame; a coroutine's storage is an object of the function" \
        " * that constructs it, so a run allocates nothing. */"
    dict for {key info} $coHandles {
        lassign $key out msg
        lappend lines "" "/* The target of a coroutine handle: its state, its cached failure, the" \
            " * value its last segment ended with[expr {$msg eq "unit" ? "" : " and the message it is resumed with"}]. */" \
            "typedef struct [dict get $info cname] \{" "    unsigned char state;"
        if {[llength [dict get $info kinds]] > 1} {
            lappend lines "    unsigned char kind;"
        }
        lappend lines "    ${prefix}_status failure;" "    [Declarator [CType $out] value];"
        if {$msg ne "unit"} {
            lappend lines "    [Declarator [CType $msg] message];"
        }
        lappend lines "\} [dict get $info cname];"
    }
    foreach name [FrameOrder] {
        set frame [dict get $frames $name]
        if {[dict get $frame role] eq "kind"} {
            lappend lines "" "/* [string toupper [dict get $frame title] 0 0]: a fresh one is all zero (suspended before its start). */"
        } else {
            lappend lines "" "/* The frame of [dict get $frame title]: what survives its suspensions. */"
        }
        lappend lines "typedef struct $name \{"
        foreach field [dict get $frame fields] {
            lassign $field ctype member
            lappend lines "    [Declarator $ctype $member];"
        }
        if {[dict get $frame union] ne ""} {
            lappend lines "    union \{"
            foreach entry [dict get $frame union] {
                lassign $entry ctype member
                lappend lines "        [Declarator $ctype $member];"
            }
            lappend lines "    \} sub;"
        }
        lappend lines "\} $name;"
    }
    return $lines
}

# The C text of the coroutine operations (PREFIX.c): the states, the
# suspension status, each kind's zero storage and segment function, each
# handle type's resume function. {DECLARATIONS PROTOTYPES DEFINITIONS}.
proc ccompile::CoroutineCode {} {
    variable coHandles
    variable coKinds
    variable signatures
    variable prefix
    set p $prefix
    if {[dict size $coHandles] == 0} {
        return [list {} {} {}]
    }
    set decls [list "" \
        "/* A coroutine's state (its handle target's), and the status a function" \
        " * that may yield returns when it suspends: never an error, never a run's. */" \
        "#define ${p}_CO_SUSPENDED 0" "#define ${p}_CO_COMPLETED 1" "#define ${p}_CO_FAILED 2" \
        "#define ${p}_SUSPEND (-1)"]
    set protos {}
    set defs {}
    dict for {thunk kind} $coKinds {
        set cname [dict get $kind cname]
        set h [dict get $kind h]
        lassign [HandleSlots $h] outRepr msgRepr
        lassign [dict get $signatures [dict get $kind instance]] tname tparams tresult
        set head "static ${p}_status ${cname}_step($cname *co)"
        lappend protos "$head;"
        set words [list "&co->body"]
        foreach cid [dict get $kind contexts] {
            lappend words "co->[ContextName $cid]"
        }
        lappend words "&co->head.value"
        if {$msgRepr ne "unit"} {
            lappend words "&co->head.message"
        }
        lappend words "&r"
        set fn [dict create lines {} indent 1]
        set body [list "/* Runs the next segment of a coroutine of [ThunkTitle $thunk]. */" $head "\{" \
            "    [Declarator [CType $tresult] r];" \
            "    ${p}_status st = $tname\([join $words {, }]);"]
        set root [dict get [hir::specialize::instance [set ::ccompile::spec] [dict get $kind instance]] result]
        if {$root eq "never"} {
            lappend body "    (void)r;"
        } else {
            lappend body "    if (st == ${p}_OK) \{" \
                "        co->head.value = [Want fn [list $tresult r] $outRepr];" "    \}"
        }
        lappend body "    return st;" "\}"
        lappend defs "" [join $body \n]
    }
    dict for {key info} $coHandles {
        set cname [dict get $info cname]
        lassign $key outRepr msgRepr
        set head "static ${p}_status ${cname}_resume($cname *co, [Declarator [CType $outRepr] *out])"
        lappend protos "$head;"
        set kinds [dict get $info kinds]
        set body [list "/* Runs the next segment of the coroutine CO points to, or answers again" \
            " * the result or error it ended with, running nothing. */" $head "\{" "    ${p}_status st;" \
            "    if (co->state == ${p}_CO_COMPLETED) \{" "        *out = co->value;" "        return ${p}_OK;" "    \}" \
            "    if (co->state == ${p}_CO_FAILED) \{" "        return co->failure;" "    \}"]
        if {[llength $kinds] == 1} {
            set kc [dict get $coKinds [lindex $kinds 0] cname]
            lappend body "    st = ${kc}_step(($kc *)co);"
        } else {
            lappend body "    switch (co->kind) \{"
            set k 0
            foreach thunk $kinds {
                set kc [dict get $coKinds $thunk cname]
                if {$k == [llength $kinds] - 1} {
                    lappend body "    default:"
                } else {
                    lappend body "    case $k:"
                }
                lappend body "        st = ${kc}_step(($kc *)co);" "        break;"
                incr k
            }
            lappend body "    \}"
        }
        lappend body "    if (st == ${p}_SUSPEND) \{" "        *out = co->value;" "        return ${p}_OK;" "    \}" \
            "    if (st != ${p}_OK) \{" "        co->state = ${p}_CO_FAILED;" "        co->failure = st;" "        return st;" "    \}" \
            "    co->state = ${p}_CO_COMPLETED;" "    *out = co->value;" "    return ${p}_OK;" "\}"
        lappend defs "" [join $body \n]
    }
    return [list $decls $protos $defs]
}

# TEXT (a function's C) with each construction's kind tag (@@KIND:H@@) kept
# where several kinds share the handle type H (its resume switches on the
# tag), and dropped where one kind has it alone.
proc ccompile::KindTags {text} {
    variable coHandles
    if {[string first @@KIND: $text] < 0} {
        return $text
    }
    set shared [dict create]
    dict for {key info} $coHandles {
        dict set shared [dict get $info cname] [expr {[llength [dict get $info kinds]] > 1}]
    }
    set out {}
    foreach line [split $text \n] {
        if {[regexp {^(\s*)@@KIND:([A-Za-z0-9_]+)@@(.*)$} $line -> indent h rest]} {
            if {![dict get $shared $h]} continue
            set line "$indent$rest"
        }
        lappend out $line
    }
    return [join $out \n]
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
    if {[IsThunk $block]} {
        # A construction's thunk: the coroutine's entry, run only through
        # its kind (Coroutines). It has no parameters; what it captures is
        # its frame's.
        return [list ${prefix}_[string range $id 1 end]_coroutine {}]
    }
    if {![dict exists [dict get $spec closed] $id]} {
        Unsupported $block "a function whose calls are not all direct (a function used as a value)"
    }
    set view [hir::specialize::view $baseHir $spec $id]
    set instRanges [dict get $ranges instances $id]
    set name [hir::aot::BlockName $baseHir $block]
    set cname ${prefix}_[string range $id 1 end]_[Sanitize [if {$name eq ""} {string cat fn} else {set name}]]
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

# The C function of instance ID (its text), compiling its body. An instance
# that may yield (its block may yield, or it is a construction's thunk:
# IsYieldingInstance) is a state machine over its frame (Coroutines): its
# parameters arrive in the frame, the values that live across a suspension
# are frame fields (Persist), and its body starts with a dispatch on the
# frame's resume point.
proc ccompile::Function {id} {
    variable spec
    variable baseHir
    variable hir
    variable prefix
    variable staticBindings
    variable active
    variable fixedResults
    variable signatures
    variable yieldH
    set instance [hir::specialize::instance $spec $id]
    set block [dict get $instance block]
    lassign [Params $id] cname paramReprs
    set hir [hir::specialize::view $baseHir $spec $id]
    lappend active $id
    set yielding [IsYieldingInstance $id]
    set thunk [expr {$block ne "program" && [IsThunk $block]}]
    set h ""
    if {$yielding} {
        if {![dict exists $yieldH $id]} {
            error "ccompile: internal error: the yielding instance $id was reached by no coroutine"
        }
        set h [dict get $yieldH $id]
    }
    set fn [dict create instance $id block $block lines {} indent 1 temps 0 labels 0 \
        locals [dict create] loops [dict create] handlers {} usedLabels [dict create] \
        result "" completions {} tail 0 joins 0 contexts [dict create] \
        yielding $yielding h $h resumes 0 subs {} constructs {}]
    # The contexts it requires arrive as pointer parameters (ContextArgs
    # passes them on; the program function's are its installations).
    set contextIds [ContextRequirement $block]
    foreach cid $contextIds {
        dict set fn contexts $cid [ContextName $cid]
    }
    if {$block eq "program"} {
        set body [hir::roots $hir]
        set params {}
    } else {
        set params [hir::get $hir $block params]
        set body [hir::get $hir $block body]
        if {$thunk} {
            # Its captures -- the construction's argument temporaries -- are
            # its frame's, copied in by the construction (Create).
            foreach entry [ThunkCaptures $block] {
                lassign $entry b member repr
                dict set fn locals $b [list $repr "fr->$member"]
            }
        } elseif {$block ni [dict get $spec context statics]} {
            # Only a block whose captures are functions or program-level
            # values (StaticBindings) is a C function of its own.
            foreach b [hir::get $hir $block captures] {
                if {[hir::aot::BoundBlock $hir $b] eq "" && ![dict exists $staticBindings $b]} {
                    Unsupported $block "a closure (a function that captures a local value of an enclosing function)"
                }
            }
        }
        foreach b $params repr $paramReprs {
            set c [ParamName $b]
            if {$yielding} {
                # (The caller writes the arguments into the callee's frame.)
                set c "fr->$c"
            }
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
        set resultRepr [if {$completions eq ""} {string cat unit} else {lindex $completions 0 0}]
        variable programResult
        set programResult $resultRepr
    } else {
        set resultRepr [RangeResult $id]
        if {$resultRepr eq "int" && $completions ne ""
                && [lsearch -not -exact -index 0 $completions i64] < 0} {
            set resultRepr i64
        }
    }
    # A construction's storage is the constructing function's own (its C
    # frame, or its persistent frame): a handle that could leave the
    # function would outlive it. Only a value whose type holds a handle can
    # carry one (affinity is a property of the type), so a function that
    # constructs a coroutine and may return a handle is refused -- the
    # handles a coroutine's segments could hand out (its outward values,
    # its messages, its errors' payloads) are unrestricted already
    # (hir::coroutines::AffineProtocol).
    set constructs [dict get $fn constructs]
    if {$constructs ne "" && [hir::types::IsAffine [dict get $instance result]]} {
        set where [lindex $constructs 0 2]
        if {$block eq "program"} {
            Unsupported $where "a program whose value holds a coroutine handle (the coroutine's frame is storage of the run, which ends with it)"
        }
        Unsupported $where "a function that may return a handle of a coroutine it constructs (the coroutine's frame is storage of the function's own frame, which ends when it returns)"
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
    set lines [lmap line $lines {
        if {[regexp {^(\s*)@@UNREAD:([^:]+):(.*)@@$} $line -> indent b c]} {
            if {[regexp -all "\\m$c\\M" $text] > 2} continue
            set line "${indent}(void)$c;"
        }
        set line
    }]
    # Where each variable lives: a yielding function's frame pass decides
    # what survives a suspension; every function declares the storage of
    # its constructions at its top (a handle may outlive the C block of its
    # construction).
    if {$yielding} {
        lassign [Persist $lines] lines fields hoisted
    } else {
        lassign [Unmark $lines] lines hoisted
        set fields {}
    }
    set active [lrange $active 0 end-1]
    set paramList {}
    if {$yielding} {
        lappend paramList "${cname}_frame *fr"
    } else {
        foreach b $params repr $paramReprs {
            lappend paramList [Declarator [CType $repr] [lindex [dict get $fn locals $b] 1]]
        }
    }
    # A required context no compiled code of this instance passes on or
    # reads (its uses are in code the instance's facts rule out) is marked
    # used, so no C compiler warns of the parameter.
    set text [join $lines \n]
    set unused {}
    foreach cid $contextIds {
        set c [ContextName $cid]
        lappend paramList "[CType [ContextRepr $cid $block]] *$c"
        if {![regexp "\\m$c\\M" $text]} {
            lappend unused "    (void)$c;"
        }
    }
    if {$yielding} {
        lassign [HandleSlots $h] outRepr msgRepr
        lappend paramList [Declarator [CType $outRepr] *yslot]
        if {![regexp {\myslot\M} $text]} {
            lappend unused "    (void)yslot;"
        }
        if {$msgRepr ne "unit"} {
            lappend paramList [Declarator [CType $msgRepr] *mslot]
            if {![regexp {\mmslot\M} $text]} {
                lappend unused "    (void)mslot;"
            }
        }
    }
    lappend paramList [Declarator [CType $resultRepr] *out]
    if {![regexp {\mout\M} $text]} {
        # (A function that never completes normally -- an endless
        # generator -- writes no result.)
        lappend unused "    (void)out;"
    }
    set head "static ${prefix}_status $cname\([join $paramList {, }])"
    set name [if {$block eq "program"} {string cat "the program"} elseif {$thunk} {
        string cat "the coroutine of [ThunkTitle $block]"} else {hir::aot::BlockName $baseHir $block}]
    set key [if {[dict get $instance generic]} {string cat generic} else {join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }}]
    set out [list "/* $name ([string trim "$id $key"]) */" $head "\{" {*}$unused]
    foreach decl $hoisted {
        lappend out "    $decl;"
    }
    if {$yielding} {
        lappend out {*}[Dispatch [dict get $fn resumes]]
        FrameType $id $cname $block $paramReprs $params $fields $fn
    }
    if {[dict get $fn tail]} {
        lappend out "top:;"
    }
    lappend out {*}$lines
    lappend out "\}"
    dict set signatures $id [list $cname $paramReprs $resultRepr]
    return [list $head [join $out \n]]
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
# Declares the C variable NAME of C type CTYPE, initialized with INIT (a C
# expression) unless it is "". The line is marked @@D@@, so that a yielding
# function's frame pass (Persist) can move the variable into the frame or
# to the function's top; in any other function the mark is dropped and the
# line is the plain declaration.
proc ccompile::Decl {fnVar ctype name {init ""}} {
    upvar 1 $fnVar fn
    set text [Declarator $ctype $name]
    if {$init ne ""} {
        append text " = $init"
    }
    Emit fn "@@D@@$text;"
}

# Declares a C variable of REPR holding CODE; returns its name.
proc ccompile::Declare {fnVar repr code {stem t}} {
    upvar 1 $fnVar fn
    set t [Temp fn $stem]
    Decl fn [CType $repr] $t $code
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
    Decl fn ${prefix}_status $st $call
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
        set mode [if {$i == $n} {set want} else {string cat discard}]
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
            Decl fn botlish_rt_v1_int $t
            set service [Service int.from_decimal]
            Helper rt_status
            set st [Temp fn st]
            variable prefix
            Decl fn botlish_rt_v1_status $st "$service\(\"$n\", [string length $n]u, &$t)"
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
    set id [hir::contexts::loadId $hir $valueExpr]
    if {$id ne ""} {
        # A context parameter: no C variable, its uses read the installed
        # context through the function's pointer to it.
        set op [ContextValue fn $valueExpr $id]
        dict set fn locals $b $op
        return $op
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
    Decl fn [CType [lindex $value 0]] $c [lindex $value 1]
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
            return [NativeCall fn $e $node $name $want]
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
    if {!$selfTail && [IsYieldingInstance $callee]} {
        return [YieldingCall fn $e $node $callee]
    }
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
    lappend words {*}[ContextArgs fn [dict get [hir::specialize::instance $spec $callee] block] $e]
    set calleeResult [dict get [hir::specialize::instance $spec $callee] result]
    set t [Temp fn r]
    Decl fn [CType $resultRepr] $t
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

proc ccompile::NativeCall {fnVar e node name {want value}} {
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
        context#install {
            return [Install fn $e $node]
        }
        coroutine#create {
            return [Create fn $e $node]
        }
        coroutine#start - coroutine#resume {
            return [Resume fn $e $node]
        }
        coroutine#yield {
            return [Yield fn $e $node $want]
        }
        std::coroutine::done? {
            set ops [Operands fn $node]
            if {$ops eq ""} {
                return [list never ""]
            }
            return [list bool "([lindex $ops 0 1]->state != ${::ccompile::prefix}_CO_SUSPENDED)"]
        }
        coroutine#release {
            # Nothing to clean up (Coroutines); the handle is dead.
            set ops [Operands fn $node]
            if {$ops eq ""} {
                return [list never ""]
            }
            return [list unit 0]
        }
        coroutine#abandon {
            Unsupported $e "the abandonment of a suspended coroutine (resources)"
        }
        context#load {
            return [ContextValue fn $e [hir::contexts::loadId [set ::ccompile::hir] $e]]
        }
        context#unreachable {
            # Where the trait plan put an operation no installed context
            # reaches (CONTEXT-TRAITS.md, "Dead code"): never run, as
            # verification proved. Its arguments run first (a dead call of a
            # trait-polymorphic function keeps them); should it run, it is the
            # Tcl backends' error, as a status -- never a trap or an exit.
            set ops [Operands fn $node]
            if {$ops eq "" && $argExprs ne ""} {
                return [list never ""]
            }
            Fail fn [StatusOf {semantic UNREACHABLE context} {CORE SEMANTIC UNREACHABLE} \
                "context#unreachable: code that no installed context reaches was executed (a compiler bug: static verification proved it never runs)" \
                UNREACHABLE_CONTEXT]
            return [list never ""]
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
    Decl fn botlish_rt_v1_int $t
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
    Decl fn botlish_rt_v1_int $t
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
        set kcode [if {[lindex $k 0] eq "i64"} {lindex $k 1} else {string cat ([lindex $k 1]).small}]
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
    if {[regexp {^\(\*([A-Za-z_][A-Za-z0-9_]*)\)$} [lindex $receiver 1] -> pointer]} {
        # A field of a context, read through its pointer.
        return [Narrowed fn $e [list $repr "$pointer->[Member $name]"]]
    }
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
    Emit fn "@@D@@@@JT$n@@ $var = @@JZ$n@@;"
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
    set var [dict get $join var]
    set map [list "@@JT$n@@ $var" [Declarator [CType $repr] $var] @@JZ$n@@ [ZeroOf $repr]]
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
        set body [if {$thenDead} {set elseBody} else {set thenBody}]
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
    Decl fn ${prefix}_status $hst ${prefix}_OK
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
    set from [if {$source eq ""} {string cat "a Botlish program"} else {set source}]
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
    lappend h {*}[CoroutineTypes]
    lappend h "" "/* The program's value. */" "typedef [CType $programResult] ${p}_value;" ""
    if {[dict size $statics]} {
        lappend h "/* Runs the program: on ${p}_OK its value is in *value. Not reentrant (the" \
            " * program's top-level values that functions read are file-scope objects). */"
    } else {
        # (Its installed contexts are objects of the run's own frame: a run
        # writes nothing a second run, or another program, could see.)
        lappend h "/* Runs the program: on ${p}_OK its value is in *value. Writes no object of" \
            " * static storage duration: its installed contexts and values live in the" \
            " * run's own frame (a runtime-service provider has its own rules). */"
    }
    lappend h "${p}_status ${p}_run(${p}_value *value);" "" \
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
    lassign [CoroutineCode] coDecls coProtos coDefs
    lappend c {*}$coDecls
    lappend c ""
    variable referenced
    set order [concat [list $programId] [lsort -dictionary [lsearch -all -inline -not -exact [dict keys $referenced] $programId]]]
    foreach id $order {
        lappend c "[lindex [dict get $compiled $id] 0];"
    }
    lappend c {*}$coProtos
    foreach id $order {
        lappend c "" [KindTags [lindex [dict get $compiled $id] 1]]
    }
    lappend c {*}$coDefs
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
                        set label [if {$kind eq "list"} {string cat ""} else {string cat "$field: "}]
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
    set frames [CoroutineManifest]
    set comma [expr {$frames eq "" ? "" : ","}]
    if {[dict size $entries] == 0} {
        lappend lines "  \"required_services\": \[\]$comma"
    } else {
        lappend lines "  \"required_services\": \[" "[join [dict values $entries] ",\n"]" "  \]$comma"
    }
    if {$frames ne ""} {
        lappend lines {*}$frames
    }
    lappend lines "\}"
    return "[join $lines \n]\n"
}

# The manifest's coroutine section (a program with coroutines only): every
# coroutine type PREFIX.h defines, in definition order, with what it holds
# by value and, for a function's frame, which of its fields are values that
# survive a suspension -- what an embedding needs to account for a
# program's storage (sizeof and _Alignof of each type are the target C
# compiler's).
proc ccompile::CoroutineManifest {} {
    variable coHandles
    variable frames
    if {[dict size $coHandles] == 0} {
        return {}
    }
    set entries {}
    dict for {key info} $coHandles {
        lappend entries "    \{\"type\": [JString [dict get $info cname]], \"role\": \"handle\", \"holds\": \[\]\}"
    }
    foreach name [FrameOrder] {
        set frame [dict get $frames $name]
        set holds [lsort -unique [concat [lmap d [dict get $frame deps] {lindex $d 0}] \
            [lmap f [dict get $frame fields] {
                if {[string match *_coh* [lindex $f 0]] && [lindex $f 1] eq "head"} {lindex $f 0} else continue
            }]]]
        set role [expr {[dict get $frame role] eq "kind" ? "storage" : "frame"}]
        set entry "    \{\"type\": [JString $name], \"role\": [JString $role], \"of\": [JString [dict get $frame title]], \"holds\": \[[join [lmap t $holds {JString $t}] {, }]\]"
        if {$role eq "frame"} {
            append entry ", \"suspension_values\": \[[join [lmap f [dict get $frame persistent] {JString $f}] {, }]\]"
        }
        lappend entries "$entry\}"
    }
    return [list "  \"coroutine_frames\": \[" [join $entries ",\n"] "  \]"]
}
