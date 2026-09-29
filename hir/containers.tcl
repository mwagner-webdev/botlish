# containers.tcl -- intrinsic container type rules: the static relations
# between a container's element contract and the operations that build,
# read, write and freeze it (PARAMETERIZED-MUTABLEARRAY.md).
#
# Botlish has no general type variables (`fn f[T](...)` does not exist and
# this file adds none). Some operations are nevertheless *intrinsically*
# relational -- `list_get(List[T], i)` is a `T`, `from_list(List[T])` is a
# `MutableArray[T]` -- and the compiler has always known such relations
# through per-operation rules rather than through function types:
# core/lists.tcl's -result-shape (element/append/elements), consumed by
# hir::types::ShapeResult, is the existing mechanism for natives. This file
# is the one central place for the rest:
#
#   * result rules for ordinary Botlish *module functions* whose result
#     type depends on their argument types: mutarray::from_list and
#     mutarray::create. They are keyed by the function's resolved identity
#     (the module binding "mutarray::from_list" -- lib/mutarray.bot; a user
#     function that happens to be called from_list, or a local alias of the
#     library function, cannot acquire or lose the rule), never by the
#     spelling of a call;
#   * static element-contract checks for the natives that write into a
#     MutableArray[T] (mutable_array_set, mutable_array_copy): a store must
#     be *proven* admissible for T, and a copy must not move values into a
#     typed destination without the same proof. There is no implicit guard
#     and no widening -- an unproven store is a compile-time TYPE error;
#   * the argument "contexts" the typed-contract escape audit
#     (hir/callables.tcl) needs to tell a call that merely *uses* a typed
#     array from one that would erase its element contract.
#
# The rules only ever read static types. The runtime MutableArray carries no
# element type (core/mutarray.tcl, native MutArrayObj): `MutableArray[T]` is
# a compile-time contract, so no backend needs to know any of this.
#
# Result rules for natives that project the element type (`mutable_array_get`
# -> T, `mutable_array_freeze` -> List[T]) are ordinary -result-shape entries
# (core/mutarray.tcl, hir::types::ShapeResult), exactly like list_get.

namespace eval hir::containers {
    # Qualified module function name -> rule.
    variable moduleRules [dict create \
        mutarray::from_list from-list \
        mutarray::create    create]
    # Native name -> rule for the natives that write a MutableArray's slots.
    variable nativeRules [dict create \
        mutable_array_set  set \
        mutable_array_copy copy]
}

# Records, as HIR's `intrinsicBlocks` field (block ExprId -> rule), which
# block expressions are the library functions that carry a result rule.
# Called once per build, after module qualification (hir::hygiene::apply) has
# given every module binding its "namespace::name" spelling -- a name no
# user binding can have -- and before any type inference.
proc hir::containers::index {hirVar} {
    upvar 1 $hirVar hir
    variable moduleRules
    set index [dict create]
    dict for {b binding} [dict get $hir bindings] {
        set name [dict get $binding name]
        if {![dict exists $moduleRules $name] || ![hir::isModuleBinding $hir $b]} {
            continue
        }
        set declaredBy [dict get $binding declaredBy]
        if {$declaredBy eq "" || ![dict exists $hir exprs $declaredBy]} {
            continue
        }
        set value [dict get $hir exprs $declaredBy value]
        if {[dict get $hir exprs $value kind] ne "block"} {
            continue
        }
        dict set index $value [dict get $moduleRules $name]
    }
    dict set hir intrinsicBlocks $index
}

# The result rule of block expression BLOCK, or "".
proc hir::containers::RuleOf {hir block} {
    if {![dict exists $hir intrinsicBlocks $block]} {
        return ""
    }
    return [dict get $hir intrinsicBlocks $block]
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

# The result type of a call of a rule-carrying module function with
# argument types ARGTYPES, whose ordinary (block) result is RESULT.
#
#   from-list   xs : List[T]  ->  MutableArray[T]; a broad `list` (no
#               element type) or List[any] gives MutableArray[any] -- a
#               fresh, fully initialized array whose element contract is
#               the whole `any` domain, never the raw substrate type.
#   create      (capacity, default : T)  ->  MutableArray[T], T the static
#               type of `default`, also for capacity 0.
proc hir::containers::CallResult {rule argTypes result} {
    switch -- $rule {
        from-list {
            set list [hir::types::Unshaped [lindex $argTypes 0]]
            set elem any
            if {[hir::types::IsList $list]} {
                set elem [ElementContract [lindex $list 1]]
            }
            return [hir::types::MakeMutArray $elem 0]
        }
        create {
            return [hir::types::MakeMutArray [ElementContract [lindex $argTypes 1]] 0]
        }
    }
    return $result
}

# The static type each argument of a call E of rule-carrying block BLOCK
# flows into inside the call's own result type (for the escape audit): the
# List handed to from_list lands, element by element, in the MutableArray;
# `default` lands in every slot of create's array.
proc hir::containers::BlockContexts {hir e rule} {
    set node [dict get $hir exprs $e]
    set args [dict get $node args]
    set none [lrepeat [llength $args] ""]
    set result [hir::typeOf $hir $e]
    if {![hir::types::IsMutArray $result]} {
        return $none
    }
    switch -- $rule {
        from-list {
            if {[llength $args] == 1} {
                return [list [hir::types::MakeList [lindex $result 1]]]
            }
        }
        create {
            if {[llength $args] == 2} {
                return [list "" [lindex $result 1]]
            }
        }
    }
    return $none
}

# 1 if native NAME cannot retain any of its arguments where a later reader
# could find them: it returns a plain scalar and does not mutate a
# MutableArray. Such a call merely *uses* its arguments (list_length,
# type tests, mutable_array_capacity, ...), so it cannot erase a contract.
proc hir::containers::NonRetaining {name} {
    set meta [core::native::metadata $name]
    if {"mutarray-mutate" in [dict get $meta runtime]} {
        return 0
    }
    return [expr {[dict get $meta resultType] in {int str bool unit UnicodeChar}
        || [dict get $meta testsType] ne ""}]
}

# The argument contexts of a call E of native NAME for the escape audit, or
# "" when the native has no container rule (the caller then applies its
# generic policy). One context per argument.
proc hir::containers::NativeContexts {hir e name} {
    variable nativeRules
    set node [dict get $hir exprs $e]
    set args [dict get $node args]
    set n [llength $args]
    if {[dict exists $nativeRules $name]} {
        set contexts [lmap arg $args {hir::typeOf $hir $arg}]
        switch -- [dict get $nativeRules $name] {
            set {
                if {$n == 3} {
                    # The value lands in a slot of the array: its context
                    # is the array's element contract (a raw array has no
                    # contract to keep, so a bearing value cannot be
                    # stored in one).
                    set array [lindex $contexts 0]
                    lset contexts 1 ""
                    lset contexts 2 [expr {[hir::types::IsMutArray $array] ? [lindex $array 1] : ""}]
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
        }
        return ""
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
    switch -- [dict get $nativeRules $name] {
        set {
            if {[llength $args] == 3} {
                VerifyStore hir $ranges [lindex $args 0] [lindex $args 2]
            }
        }
        copy {
            if {[llength $args] == 5} {
                VerifyCopy hir [lindex $args 0] [lindex $args 2]
            }
        }
    }
}

# mutable_array_set(ARRAY, i, VALUE): when ARRAY is a MutableArray[T], VALUE
# must be proven admissible for T. The element contract belongs to the
# object; a store never widens it.
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

# mutable_array_copy(DST, dstStart, SRC, srcStart, count): every copied
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
