# borrow.tcl -- temporary foreign byte exposure (C-POINTER-BORROWING.md):
# which arguments of a foreign call may be existing Botlish byte storage, how
# each is transported, and what the call returns.
#
# A foreign call contract (core/cabi.tcl; a native's -foreign today, an
# `extern c fn` declaration's parameters later) gives every C pointer
# parameter an `access` (read | write | unknown) and an `escape`
# (proven-noescape | declared-noescape | captures | unknown). A data pointer
# parameter of known access whose escape is noescape, and whose pointee is a
# byte-sized C type or Void, admits a *byte owner* for the call:
#
#   argument                  access   transport
#   abi::bytes::Bytes         read     read:  its storage, exposed as it is
#   abi::bytes::MutableBytes  read     read:  its storage, exposed as it is
#   abi::bytes::MutableBytes  write    write: a private copy of its storage
#                                      (the detach), exposed writable, and
#                                      the call's updated value of that
#                                      parameter afterwards
#
# Everything else is refused (FOREIGN-BORROW) before anything runs, in this
# order of reasons:
#
#   * the parameter may retain the pointer (escape captures or unknown:
#     unknown is never "probably synchronous") -- the central rule: no
#     pointer into Botlish storage outlives the call;
#   * its access is unknown;
#   * an immutable Bytes where C may write (write access is a semantic
#     fact, whatever memory the storage happens to be in);
#   * its pointee is not Char, SChar, UChar or Void (a C integer scalar of
#     8 bits by its registry metadata, never by its name): byte storage is
#     never a Ptr[Int], a Ptr[Long] or a pointer to a struct -- no alignment
#     or element layout is promised.
#
# Nothing here reads a fact from a C type, a `const`, a name or a
# namespace: the contract's facts, and the argument's static type, decide.
# A C pointer argument (an ffi::c::Ptr value) at such a parameter is an
# ordinary raw pointer, held to the parameter's type like any argument.
#
# No pointer value is made: an exposure is the call's argument transport,
# never a value of any type, so it cannot be bound, stored, returned,
# captured, cloned, erased or retyped. The decision is recorded on the call
# node (`borrows`: {INDEX ACCESS NAME} per exposed argument, in argument
# order, NAME the parameter's) by the typing of the call (hir::types::Call),
# and native lowering lowers the call from that field and the call's static
# type alone -- never from the callee's name, its contract or anything
# outside the HIR -- so HIR interchange carries it (HIR-INTERCHANGE.md). (The
# Tcl backends' boundary, core::cabi::ForeignBoundary, makes the same
# decision from the run-time value and the contract it is registered with.)
#
# The write-back result. A MutableBytes is a value (MUTABLE-BYTES.md: no
# update writes storage anyone else can observe), so C's writes cannot
# appear in the caller's own value: they appear in the call's result. A
# call with a write exposure returns the anonymous struct
#
#   {result: R, NAME: abi::bytes::MutableBytes, ...}
#
# R the contract's C result and NAME each written parameter's name (sorted,
# as every anonymous struct's fields are). The caller's argument is
# unchanged. A call without one returns R.
#
#   hir::borrow::Contract HIR NODE          the contract of call NODE's
#                                           target, or ""
#   hir::borrow::Decide PARAM ARGTYPE       the transport of one argument
#   hir::borrow::Type HIRVAR E META ARGTYPES  types call E (hir::types::Call)
#   hir::borrow::VerifyCall ...             its diagnostics (hir/range.tcl),
#                                           and the refusal a -strict 0 run
#                                           replays (`borrowRefused`)
#   hir::borrow::VerifyPointerKinds ...     a byte owner where another
#                                           native needs a C address
#   hir::borrow::verify HIRVAR              foreign operations are only called
#   hir::borrow::transports HIR E           call E's recorded exposures
#   hir::borrow::retaining HIR E            the `direct` hook
#
# A variadic C function (VARIADICS-VERTICAL-SLICE-1.md) has a contract of
# its fixed parameters only (`variadic 1`). A call's trailing arguments
# follow none of the above: each is passed as its own static C type with
# C's default argument promotion (hir::cabi::VariadicArgument), recorded on
# the call node by its typing (`cvarargs`: one {c SPELLING class CLASS
# promoted PROMOTED} per trailing argument, in order), and a trailing
# argument without one -- a plain Int, a String, byte storage, anything
# that is no C ABI value type -- is the call's diagnostic (TYPE, or
# FOREIGN-BORROW for byte storage: it has no contract to admit it).

namespace eval hir::borrow {}

# The byte owner types: the static types an exposure is taken from.
proc hir::borrow::OwnerTypes {} {
    return [list [list nstruct [core::bytestore::bytesType]] [list nstruct [core::bytestore::mutableBytesType]]]
}

# 1 if TYPE is a byte owner (abi::bytes::Bytes or abi::bytes::MutableBytes).
proc hir::borrow::IsOwner {type} {
    return [expr {$type in [OwnerTypes]}]
}

# 1 if TYPE is abi::bytes::MutableBytes.
proc hir::borrow::IsMutableOwner {type} {
    return [expr {$type eq [list nstruct [core::bytestore::mutableBytesType]]}]
}

# The foreign call contract of call NODE's statically known target, or ""
# (core/cabi.tcl's normalized form).
proc hir::borrow::Contract {hir node} {
    lassign [dict get $node target] kind target
    if {$kind ne "native"} {
        return ""
    }
    set meta [core::native::metadata [dict get [hir::symbol $hir $target] name]]
    return [dict getdef $meta foreign ""]
}

# 1 if pointee POINTEE may be byte storage: ffi::c::Void, or a C integer
# scalar whose registry metadata says it is 8 bits wide.
proc hir::borrow::BytePointee {pointee} {
    if {$pointee eq "void"} {
        return 1
    }
    set info [core::type::cabiScalar $pointee]
    return [expr {$info ne "" && [dict get $info bits] == 8}]
}

# The transport of an argument of static type ARGTYPE at contract parameter
# PARAM (its type imprinted for the call): "" (not an exposure -- an
# ordinary argument, held to the parameter's type), {borrow read}, {borrow
# write}, or {problem MESSAGE} (FOREIGN-BORROW) when ARGTYPE is a byte owner
# the parameter does not admit.
proc hir::borrow::Decide {param argType} {
    set type [dict get $param type]
    if {![hir::types::IsCPtr $type] || ![IsOwner $argType]} {
        return ""
    }
    set name [dict get $param name]
    set access [dict get $param access]
    set escape [dict get $param escape]
    set owner [hir::types::show $argType]
    if {![core::cabi::isNoescape $escape]} {
        return [list problem [format \
            {byte storage (%s) is exposed to C only for a call that cannot keep the pointer, but parameter "%s" may retain it (escape %s%s): a pointer C keeps after the call needs storage that outlives the call, which nothing provides yet, and only a contract that says noescape -- never a const, a name or a guess -- admits temporary exposure} \
            $owner $name $escape [expr {$escape eq "unknown" ? ", which is treated as retaining" : ""}]]]
    }
    if {$access eq "unknown"} {
        return [list problem [format \
            {byte storage (%s) is exposed to C only through a parameter whose access is declared, and parameter "%s" does not say whether C reads or modifies the bytes (access unknown)} \
            $owner $name]]
    }
    if {$access eq "write" && ![IsMutableOwner $argType]} {
        return [list problem [format \
            {parameter "%s" lets C modify the bytes (access write), and an immutable %s is exposed only for reading: expose an abi::bytes::MutableBytes, whose written bytes the call returns} \
            $name $owner]]
    }
    set pointee [lindex $type 1]
    if {![BytePointee $pointee]} {
        return [list problem [format \
            {byte storage (%s) is exposed only as a pointer to a byte-sized C type (ffi::c::Char, ffi::c::SChar, ffi::c::UChar) or ffi::c::Void, and parameter "%s" is %s: its bytes are not values of %s, and no alignment or element layout is promised} \
            $owner $name [hir::types::show $type] [hir::cabi::ShowPointee $pointee]]]
    }
    return [list borrow $access]
}

# The contract parameters of call E as the call imprints them (an imprint
# variable replaced by its binding), or "" when its imprints did not bind.
proc hir::borrow::Parameters {hir e contract} {
    if {[dict get $contract vars] ne "" && [hir::imprint::Unbound $hir $e]} {
        return ""
    }
    set binding [hir::imprint::BindingOf $hir $e]
    return [lmap param [dict get $contract params] {
        dict set param type [hir::types::canonical [hir::imprint::Substitute [dict get $param type] $binding]]
    }]
}

# ARGTYPES as call E's imprints are bound from (hir/imprint.tcl's Bind): a
# byte owner at a pointer parameter establishes nothing (it is not a
# pointer), so it is "" there, and its pointee comes from another argument
# or an explicit imprint.
proc hir::borrow::ImprintArgTypes {contract argTypes} {
    return [lmap param [dict get $contract params] argType $argTypes {
        if {[hir::types::IsCPtr [dict get $param type]] && [IsOwner $argType]} {string cat ""} else {set argType}
    }]
}

# Types call E of the -foreign native whose registry entry is META
# (hir::types::Call's part), with argument types ARGTYPES: records the
# exposures (`borrows`) on the node and returns the call's type -- the
# contract's result as the call imprints it, or the write-back struct when
# an argument is written.
proc hir::borrow::Type {hirVar e meta argTypes} {
    upvar 1 $hirVar hir
    set contract [dict get $meta foreign]
    set params [Parameters $hir $e $contract]
    set borrows {}
    set writes [dict create]
    if {$params ne ""} {
        set index 0
        foreach param $params argType $argTypes {
            if {$param eq ""} {
                # A variadic call's trailing arguments (below).
                break
            }
            set decision [Decide $param $argType]
            if {[lindex $decision 0] eq "borrow"} {
                lappend borrows [list $index [lindex $decision 1] [dict get $param name]]
                if {[lindex $decision 1] eq "write"} {
                    dict set writes [dict get $param name] [list nstruct [core::bytestore::mutableBytesType]]
                }
            }
            incr index
        }
    }
    dict set hir exprs $e borrows $borrows
    if {[dict getdef $contract variadic 0]} {
        # How each trailing argument is passed (the header): the call's own
        # C signature beyond the declaration's.
        dict set hir exprs $e cvarargs [lmap argType [lrange $argTypes [llength [dict get $contract params]] end] {
            hir::cabi::VariadicArgument $argType
        }]
    }
    set binding [hir::imprint::BindingOf $hir $e]
    set result [hir::types::canonical [hir::imprint::Substitute [dict get $contract result] $binding]]
    if {[hir::imprint::Mentions $result]} {
        return any
    }
    # (A C floating result is its carrier's value, admitted at the boundary:
    # a Float64, C-FLOAT-FFI-MILESTONE-1.md.)
    set result [hir::cabi::Carrier $result]
    # A result that is exactly an exposed argument's pointer (provenance
    # {alias NAME}: SHA256's `out`) is that exposure's address, which no
    # Botlish value may hold: the call yields unit in its place, and records
    # which argument it is (`resultAlias`), the one fact a backend's
    # development check of the contract compares the returned address with
    # (C-FFI.md, "Pointer results").
    set alias [core::cabi::AliasIndex $contract]
    if {$alias >= 0 && [lsearch -exact -index 0 $borrows $alias] >= 0} {
        set result unit
        dict set hir exprs $e resultAlias $alias
    } elseif {[dict exists $hir exprs $e resultAlias]} {
        dict unset hir exprs $e resultAlias
    }
    if {[dict size $writes] == 0} {
        return $result
    }
    return [hir::types::MakeStruct [dict merge $writes [dict create result $result]] 0]
}

# The argument whose exposure call E's result aliases (its contract's
# provenance {alias NAME}, that argument exposed: the call yields unit), or
# -1.
proc hir::borrow::resultAlias {hir e} {
    set node [dict get $hir exprs $e]
    return [dict getdef $node resultAlias -1]
}

# The exposures call E records ({INDEX ACCESS NAME} per exposed argument),
# or {}.
proc hir::borrow::transports {hir e} {
    set node [dict get $hir exprs $e]
    return [dict getdef $node borrows {}]
}

# The diagnostics of call E (NODE) of the -foreign native NAME
# (hir::range::VerifyCall's part; RANGES the call's analysis): every
# argument is an admitted exposure (Decide), or is proven to satisfy its
# parameter's type -- a C pointer of exactly that type, a C scalar by its
# range -- by the one admissibility proof (ProvesValueAcceptedBy); a byte
# owner the parameter refuses is FOREIGN-BORROW, anything else TYPE.
#
# A refused exposure also marks the call (`borrowRefused` "NAME: MESSAGE"),
# so that every backend running an unchecked (-strict 0) program replays the
# refusal, as a run-time TYPE error, instead of making the call: no backend
# ever exposes storage to a parameter that did not admit it.
proc hir::borrow::VerifyCall {hirVar ranges e node name} {
    upvar 1 $hirVar hir
    set name [core::native::displayName $name]
    set problems [Problems $hir $ranges $e $node $name]
    set refused ""
    foreach problem $problems {
        lassign $problem kind message arg refuse
        hir::Diagnose hir $kind $message $arg
        if {($kind eq "FOREIGN-BORROW" || $refuse eq "1") && $refused eq ""} {
            # (A trailing argument with no C type is refused alike: no
            # backend makes a C call it cannot give a C signature.)
            set refused "$name: $message"
        }
    }
    if {![dict exists $hir semanticContext]} {
        if {$refused ne ""} {
            dict set hir exprs $e borrowRefused $refused
        } elseif {[dict exists $hir exprs $e borrowRefused]} {
            dict unset hir exprs $e borrowRefused
        }
    }
}

# The replayed refusal of call E (VerifyCall), or "".
proc hir::borrow::refused {hir e} {
    set node [dict get $hir exprs $e]
    return [dict getdef $node borrowRefused ""]
}

# The problems of VerifyCall, as {KIND MESSAGE EXPR ?REFUSE?}: REFUSE 1 for
# a problem a -strict 0 run replays though it is no FOREIGN-BORROW (a
# trailing argument with no C type).
proc hir::borrow::Problems {hir ranges e node name} {
    set contract [Contract $hir $node]
    if {$contract eq ""} {
        return {}
    }
    set params [Parameters $hir $e $contract]
    if {$params eq "" && [dict get $contract params] ne {}} {
        # Imprints that did not bind (IMPRINT, hir/imprint.tcl).
        return {}
    }
    set problems {}
    set native [dict get [hir::symbol $hir [lindex [dict get $node target] 1]] name]
    set variadic [dict getdef $contract variadic 0]
    if {$variadic && [llength [dict get $node args]] < [llength $params]} {
        # A variadic C call passes at least its fixed parameters.
        return [list [list ARITY [format {%s is a variadic C function of %d fixed parameter(s), its declaration's C signature, and this call passes %d argument(s)} \
            $name [llength $params] [llength [dict get $node args]]] $e]]
    }
    if {!$variadic && [core::native::isExtern $native] && [llength [dict get $node args]] != [llength $params]} {
        # A C call passes exactly its signature's arguments (the platform
        # ABI has no other call): a compile-time ARITY, never a run-time one.
        return [list [list ARITY [format {%s is a C function of %d parameter(s), its declaration's C signature, and this call passes %d argument(s)} \
            $name [llength $params] [llength [dict get $node args]]] $e]]
    }
    if {$variadic} {
        # The trailing arguments: each exactly one C type (the header).
        set index [llength $params]
        foreach arg [lrange [dict get $node args] [llength $params] end] {
            incr index
            set argType [hir::typeOf $hir $arg]
            if {$argType eq "never" || [dict exists $hir poisoned $arg]} continue
            set how [hir::cabi::VariadicArgument $argType]
            if {[dict exists $how problem]} {
                lappend problems [list [dict get $how problem] \
                    "argument $index of $name, a trailing argument of a variadic C function: [dict get $how message]" $arg 1]
            }
        }
    }
    set index 0
    foreach arg [dict get $node args] param $params {
        incr index
        if {$arg eq "" || $param eq ""} continue
        set argType [hir::typeOf $hir $arg]
        if {$argType eq "never"} continue
        set decision [Decide $param $argType]
        switch -- [lindex $decision 0] {
            borrow continue
            problem {
                lappend problems [list FOREIGN-BORROW "argument $index of $name: [lindex $decision 1]" $arg]
                continue
            }
        }
        set declared [dict get $param type]
        if {$ranges ne "" && [dict exists $ranges $arg]} {
            set argRange [dict get $ranges $arg]
        } else {
            set argRange [hir::range::unknown]
        }
        # (A C floating parameter admits its carrier's values: any Float64,
        # narrowed at the boundary. C-FLOAT-FFI-MILESTONE-1.md.)
        set carrier [hir::cabi::Carrier $declared]
        if {[hir::range::ProvesValueAcceptedBy $argType $argRange $carrier]} {
            continue
        }
        set shown [hir::types::show $declared]
        if {$carrier ne $declared} {
            append shown ", whose values are [hir::types::show $carrier]s"
        }
        lappend problems [list TYPE [format {argument %d of %s cannot be proven to satisfy %s (argument type: %s)%s} \
            $index $name $shown [hir::semantic::ShowType $hir [hir::range::ShownArgType $argType $declared]] \
            [hir::range::MismatchClause $argType $carrier]] $arg]
    }
    # A data pointer result of a call that exposes Botlish storage may point
    # into that storage (memchr's result is inside its argument) unless the
    # contract says where it comes from: `independent`, or `alias NAME` (the
    # call then yields unit, Type). Unknown provenance is refused, as an
    # unknown escape is: no pointer into Botlish storage outlives the call.
    if {[hir::types::IsCPtr [dict get $contract result]] && [dict get $contract provenance] eq "unknown"} {
        set index 0
        foreach arg [dict get $node args] param $params {
            if {$arg ne "" && $param ne "" && [lindex [Decide $param [hir::typeOf $hir $arg]] 0] eq "borrow"} {
                lappend problems [list FOREIGN-BORROW [format \
                    {argument %d of %s: byte storage (%s) is exposed to a call whose pointer result (%s) may point into it: the contract does not say where the result comes from, and a pointer into Botlish storage never outlives the call -- a result independent of every argument is declared `independent`, exactly the pointer of a parameter `alias PARAM`} \
                    [expr {$index + 1}] $name [hir::types::show [hir::typeOf $hir $arg]] [hir::types::show [dict get $contract result]]] $arg]
                break
            }
            incr index
        }
    }
    return $problems
}

# Diagnoses every reference to a native with a foreign call contract that is
# not the callee of a call (part of hir::CheckOnce): a foreign operation is
# only called. A function value of one would be called where nothing knows
# its contract, so no exposure could be made for it -- and an exposure is
# never a value to pass to it instead.
proc hir::borrow::verify {hirVar} {
    upvar 1 $hirVar hir
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call"} {
            dict set callees [dict get $node callee] 1
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} continue
        if {[dict exists $node reachable] && ![dict get $node reachable]} continue
        set b [dict get $node binding]
        if {$b eq ""} continue
        set binding [hir::binding $hir $b]
        if {[dict get $binding kind] ne "root" || ![core::native::exists [dict get $binding name]]} continue
        set name [dict get $binding name]
        if {[dict get [core::native::metadata $name] foreign] eq ""} continue
        if {[dict get [core::native::metadata $name] imprint] ne ""} continue
        if {[core::native::isExtern $name]} {
            hir::Diagnose hir TYPE \
                "[core::native::displayName $name] can only be called directly: it is a C function (extern c fn), and a call through a function value would have no C signature, no contract and no link symbol -- it is not a value (a C function pointer value is ffi::c::FnPtr, which Botlish does not call)" $e
            continue
        }
        hir::Diagnose hir TYPE \
            "$name can only be called directly: it is a foreign operation, whose byte exposures exist only as the arguments of one call, not a function value" $e
    }
}

# The diagnostics of call E (NODE) of native NAME without a foreign
# contract: a byte owner given where the native requires a C address (its
# run-time kind contract is `cptr`: ffi::c::null?, ffi::c::clone) is TYPE at
# compile time. Byte storage is never a pointer value, and no operation of
# pointers ever sees one (an imprinted one, erase or retype, is held to its
# imprinted Ptr types already: hir::range::VerifyImprintedNative).
proc hir::borrow::VerifyPointerKinds {hirVar e node name} {
    upvar 1 $hirVar hir
    set meta [core::native::metadata $name]
    if {[dict get $meta imprint] ne ""} {
        return
    }
    set index 0
    foreach arg [dict get $node args] kind [dict get $meta paramTypes] {
        incr index
        if {$arg eq "" || $kind ne "cptr"} continue
        set argType [hir::typeOf $hir $arg]
        if {[IsOwner $argType]} {
            hir::Diagnose hir TYPE [format {argument %d of %s must be a C pointer (argument type: %s)%s} \
                $index $name [hir::types::show $argType] [hir::range::MismatchClause $argType {cptr void}]] $arg
        }
    }
}

# The `direct` hook (C-POINTER-BORROWING.md, "direct"): the pointer
# parameters of call E's contract that may retain pointer authority past
# the call, as {INDEX NAME ESCAPE} (core::cabi::RetainingParameters); a raw
# call with any is capability-escaping. {} for a call with no contract or
# none. Per parameter, like the exposure rule, while the consequence the
# next milestone draws (the operation is `direct`) is the call's.
proc hir::borrow::retaining {hir e} {
    set contract [Contract $hir [dict get $hir exprs $e]]
    if {$contract eq ""} {
        return {}
    }
    return [core::cabi::RetainingParameters $contract]
}
