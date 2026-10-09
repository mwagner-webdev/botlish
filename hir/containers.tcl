# containers.tcl -- intrinsic container type rules: the static relations
# between a container's element contract and the natives that build, write,
# read and freeze it (PARAMETERIZED-MUTABLEARRAY.md, MUTABLE-VECTOR.md,
# MUTABLE-ARRAY.md).
#
# Botlish has no general type variables (`fn f[T](...)` does not exist and
# this file adds none). Some operations are nevertheless *intrinsically*
# relational -- `list::at(List[T], i)` is a `T`, `from_list(List[T])` is a
# `MutableArray[T]` -- and the compiler knows such relations through
# per-native rules rather than through function types: a native's
# -result-shape (core/native.tcl), consumed by hir::types::ShapeResult, types
# its result. This file is the one central place for the rest:
#
#   * static element-contract checks for the natives that write into a
#     MutableArray[T] or a MutableVector[T] (set, swap, copy, push, ...): a
#     stored value must be *proven* admissible for T, and a copy must not
#     move values into a typed destination without the same proof. There is
#     no implicit guard and no widening -- an unproven store is a
#     compile-time TYPE error;
#   * the factory check of mutable_array::generate: the factory is called
#     with every Int index 0..n-1, so its contract must accept an Int;
#   * the argument "contexts" the typed-contract escape audit
#     (hir/callables.tcl) needs to tell a call that merely *uses* a typed
#     array -- or stores it, with its contract, in a typed container (a
#     MutableVector[MutableArray[T]]'s push) -- from one that would erase
#     its element contract.
#
# MutableArray's constructors used to be ordinary Botlish functions of
# lib/mutable_array.bot that a "module rule" here typed at every call from
# their argument types -- in place of their bodies, which the ownership
# discipline therefore never saw: `create(2, make_coroutine())` stored one
# coroutine in two slots. They are intrinsics now, each with a result shape
# for its type and an ownership role per argument for what it does with the
# value (core/native.tcl's -ownership, MUTABLE-ARRAY.md "Library
# ownership"), so no call is typed by a rule that hides a body.
#
# The rules only ever read static types. The runtime carries no element type
# (core/mutarray.tcl, core/mutvec.tcl, the native MutArrayObj/MutVecObj).

namespace eval hir::containers {
    # Native name -> rule:
    #   {store I}        a MutableArray store: argument I lands in a slot of
    #                    argument 0's array
    #   {vector I}       a MutableVector store: argument I lands in an
    #                    element of argument 0's vector
    #   copy             mutable_array::copy(dst, ds, src, ss, n)
    #   {fill I}         argument I lands in every slot of the result array
    #   {list I}         List argument I lands, element by element, in the
    #                    result collection
    #   {factory I}      argument I is a factory: called once per slot with
    #                    the slot's Int index, its results land in the slots
    variable nativeRules [dict create \
        mutable_array::set             {store 2} \
        mutable_array::swap            {store 2} \
        mutable_array#swap_drop        {store 2} \
        mutable_array#set_drop         {store 2} \
        mutable_array::copy            copy \
        mutable_array::create          {fill 1} \
        mutable_array::from_list       {list 0} \
        mutable_array::generate        {factory 1} \
        mutable_array#generate_drop    {factory 1} \
        mutable_vector::push           {vector 1} \
        mutable_vector::swap           {vector 2} \
        mutable_vector#swap_drop       {vector 2} \
        mutable_vector::from_list      {list 0}]
}

# The element contract a value of static type T is stored under: its own
# ordinary static type, never an exact-value fact. An exact callable is
# recorded by its structural contract (or its bare kind), so a
# MutableArray[...] never names one particular code target.
proc hir::containers::ElementContract {t} {
    if {$t eq "never"} {
        return any
    }
    if {[hir::types::IsExactBlock $t] || [hir::types::IsExactNative $t]} {
        set s [hir::types::structuralOf $t]
        return [expr {$s ne "" ? $s : [hir::types::kindOf $t]}]
    }
    return [hir::types::Unshaped $t]
}

# 1 if native NAME cannot retain any of its arguments where a later reader
# could find them: it returns a plain scalar and does not mutate a
# MutableArray. Such a call merely *uses* its arguments (list::length,
# type tests, mutable_array::capacity, ...), so it cannot erase a contract.
proc hir::containers::NonRetaining {name} {
    set meta [core::native::metadata $name]
    if {"mutarray-mutate" in [dict get $meta runtime]} {
        return 0
    }
    return [expr {[dict get $meta resultType] in {int str bool unit UnicodeChar}
        || [dict get $meta testsType] ne ""}]
}

# The element type of the collection type T (a MutableArray's or a
# MutableVector's), or "" when T is not an applied one.
proc hir::containers::Elem {t} {
    if {[hir::types::IsMutArray $t] || [hir::types::IsMutVec $t]} {
        return [lindex $t 1]
    }
    return ""
}

# The argument contexts of a call E of native NAME for the escape audit, or
# "" when the native has no container rule (the caller then applies its
# generic policy). One context per argument: the static type the argument
# provably lands in, "" where it lands in no typed position.
proc hir::containers::NativeContexts {hir e name} {
    variable nativeRules
    if {![dict exists $nativeRules $name]} {
        return ""
    }
    set node [dict get $hir exprs $e]
    set args [dict get $node args]
    set n [llength $args]
    # The receiver and every other argument keep their own types (they are
    # used through the typed API); an index or count lands nowhere.
    set contexts [lmap arg $args {hir::typeOf $hir $arg}]
    set result [hir::typeOf $hir $e]
    set rule [dict get $nativeRules $name]
    switch -- [lindex $rule 0] {
        store - vector {
            set i [lindex $rule 1]
            if {$n > $i} {
                # The value lands in an element of the receiver: its context
                # is the receiver's element contract (a raw array has no
                # contract to keep, so a bearing value cannot be stored in
                # one).
                set elem [Elem [lindex $contexts 0]]
                for {set k 1} {$k < $n} {incr k} {
                    lset contexts $k [expr {$k == $i ? $elem : ""}]
                }
                return $contexts
            }
        }
        copy {
            if {$n == 5} {
                lset contexts 1 ""
                lset contexts 3 ""
                lset contexts 4 ""
                return $contexts
            }
        }
        fill {
            set i [lindex $rule 1]
            if {$n > $i} {
                set contexts [lrepeat $n ""]
                lset contexts $i [Elem $result]
                return $contexts
            }
        }
        list {
            set i [lindex $rule 1]
            if {$n > $i} {
                set contexts [lrepeat $n ""]
                set elem [Elem $result]
                lset contexts $i [expr {$elem eq "" ? "" : [hir::types::MakeList $elem]}]
                return $contexts
            }
        }
        factory {
            set i [lindex $rule 1]
            if {$n > $i} {
                # The factory is only called (VerifyFactory proves it can be
                # called with every index), never stored: it keeps its own
                # type, obligations included. A count lands nowhere.
                lset contexts 0 ""
                for {set k 2} {$k < $n} {incr k} {
                    lset contexts $k ""
                }
                return $contexts
            }
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Static element-contract checks (called from hir::range::VerifyCall, which
# supplies each expression's flow-sensitive Range for the same admissibility
# proof every declared parameter is held to).

proc hir::containers::VerifyNative {hirVar ranges e node name} {
    upvar 1 $hirVar hir
    variable nativeRules
    if {![dict exists $nativeRules $name]} {
        return
    }
    set args [dict get $node args]
    set rule [dict get $nativeRules $name]
    switch -- [lindex $rule 0] {
        vector {
            # A MutableVector[T] (MUTABLE-VECTOR.md): an element pushed or
            # swapped in must be proven admissible for T, exactly as a
            # MutableArray store.
            set i [lindex $rule 1]
            if {[llength $args] > $i} {
                VerifyElement hir $ranges [lindex $args 0] [lindex $args $i]
            }
        }
        store {
            set i [lindex $rule 1]
            if {[llength $args] > $i} {
                VerifyStore hir $ranges [lindex $args 0] [lindex $args $i]
            }
        }
        copy {
            if {[llength $args] == 5} {
                VerifyCopy hir [lindex $args 0] [lindex $args 2]
            }
        }
        factory {
            set i [lindex $rule 1]
            if {[llength $args] > $i} {
                VerifyFactory hir $name [lindex $args $i]
            }
        }
    }
}

# mutable_array::set(ARRAY, i, VALUE) / swap: when ARRAY is a
# MutableArray[T], VALUE must be proven admissible for T. The element
# contract belongs to the array's type; a store never widens it.
proc hir::containers::VerifyStore {hirVar ranges array value} {
    upvar 1 $hirVar hir
    set arrayType [hir::typeOf $hir $array]
    if {![hir::types::IsMutArray $arrayType]} {
        return
    }
    set elem [lindex $arrayType 1]
    set valueType [hir::typeOf $hir $value]
    if {$elem eq "any" || $valueType eq "never"} {
        return
    }
    set range [expr {[dict exists $ranges $value] ? [dict get $ranges $value] : [hir::range::unknown]}]
    if {[hir::range::ProvesValueAcceptedBy $valueType $range $elem]} {
        return
    }
    hir::Diagnose hir TYPE [format \
        {value of type %s is not admissible to element type %s of %s (facts: %s): a MutableArray's element type is fixed for its lifetime, a store never widens it and inserts no check} \
        [hir::types::show $valueType] [hir::types::show $elem] [hir::types::show $arrayType] \
        [hir::range::show $range]] $value
}

# mutable_vector::push(VECTOR, VALUE) / swap(VECTOR, i, VALUE): when VECTOR is
# a MutableVector[T], VALUE must be proven admissible for T.
proc hir::containers::VerifyElement {hirVar ranges vector value} {
    upvar 1 $hirVar hir
    set vectorType [hir::typeOf $hir $vector]
    if {![hir::types::IsMutVec $vectorType]} {
        return
    }
    set elem [lindex $vectorType 1]
    set valueType [hir::typeOf $hir $value]
    if {$elem eq "any" || $valueType eq "never"} {
        return
    }
    set range [expr {[dict exists $ranges $value] ? [dict get $ranges $value] : [hir::range::unknown]}]
    if {$elem ne "never" && [hir::range::ProvesValueAcceptedBy $valueType $range $elem]} {
        # (MutableVector[never], the proven-empty vector, admits nothing.)
        return
    }
    hir::Diagnose hir TYPE [format \
        {value of type %s is not admissible to element type %s of %s (facts: %s): a MutableVector's element type is fixed by its type, and an element pushed or swapped in is never widened or checked at run time} \
        [hir::types::show $valueType] [hir::types::show $elem] [hir::types::show $vectorType] \
        [hir::range::show $range]] $value
}

# mutable_array::copy(DST, dstStart, SRC, srcStart, count): every copied
# element must be valid in the destination's element contract.
#
#   typed destination MutableArray[T] (T other than any):
#       the source must be a MutableArray[S] with S admissible for T; a raw
#       or unknown source is rejected (its slots prove nothing);
#   raw destination (or MutableArray[any]):
#       accepted, except that a source whose elements carry a contract of
#       their own (MutableArray[MutableArray[str]]) would lose it in an
#       untyped slot.
proc hir::containers::VerifyCopy {hirVar dst src} {
    upvar 1 $hirVar hir
    set dstType [hir::typeOf $hir $dst]
    set srcType [hir::typeOf $hir $src]
    if {$dstType eq "never" || $srcType eq "never"} {
        return
    }
    if {[hir::types::IsMutArray $dstType] && [lindex $dstType 1] ne "any"} {
        set to [lindex $dstType 1]
        if {![hir::types::IsMutArray $srcType]} {
            hir::Diagnose hir TYPE [format \
                {cannot copy from a source of type %s into %s: the source's element type is unknown, so its slot values are not proven admissible to element type %s} \
                [hir::types::show $srcType] [hir::types::show $dstType] [hir::types::show $to]] $src
            return
        }
        set from [lindex $srcType 1]
        if {![hir::types::Admits $to $from]} {
            hir::Diagnose hir TYPE [format \
                {cannot copy from %s into %s: source element type %s is not admissible to destination element type %s} \
                [hir::types::show $srcType] [hir::types::show $dstType] \
                [hir::types::show $from] [hir::types::show $to]] $src
        }
        return
    }
    if {[hir::types::IsMutArray $srcType] && [hir::callables::Bearing $hir [lindex $srcType 1]]} {
        hir::Diagnose hir TYPE [format \
            {cannot erase element contract of %s by copying its elements into %s: the copied values would lose their own contracts in untyped mutable storage} \
            [hir::types::show $srcType] [hir::types::show $dstType]] $src
    }
}

# A factory argument F of native NAME (mutable_array::generate): the native
# calls it with each slot's Int index, so its callable contract must take
# exactly one argument that admits every Int (an untyped or `int`
# parameter): a factory declaring a narrower parameter (`i: Byte`) could be
# called with an index outside it, which no check would catch. A factory of
# unknown contract is checked when it is called (its own body is analyzed
# for the Int it gets: hir/semantic.tcl).
proc hir::containers::VerifyFactory {hirVar name f} {
    upvar 1 $hirVar hir
    set type [hir::typeOf $hir $f]
    if {$type eq "never"} {
        return
    }
    set known 0
    set params {}
    if {[hir::types::IsExactBlock $type]} {
        set block [lindex $type 1]
        if {[dict exists $hir exprs $block]} {
            set known 1
            set params [lmap t [hir::signatures::entryTypes $hir $block] {expr {$t eq {} ? "any" : $t}}]
        }
    } elseif {[hir::types::IsCoroutine $type]} {
        set known 1
        set params [dict get [lindex $type 1] args]
    } elseif {[hir::types::structuralOf $type] ne ""} {
        set known 1
        set params [hir::types::FnArgs [hir::types::structuralOf $type]]
    }
    if {!$known} {
        return
    }
    if {[llength $params] != 1 || ([lindex $params 0] ne "any" && ![hir::types::Admits [lindex $params 0] int])} {
        hir::Diagnose hir TYPE [format \
            {the factory of %s is called with one Int argument (each slot's index, 0 to the count - 1), but its contract is %s} \
            $name [hir::types::showContract $type]] $f
    }
}
