# imprint.tcl -- callable imprinting (C-ABI-TYPES.md, "Imprinting").
#
# A callable's signature may mention *imprint variables*: names that denote
# whatever type a particular call imprints there, never a declared generic
# parameter. Botlish has no `fn f[T]`, no type-parameter registry, no
# constraint, no instantiation and no specialization keyed by a variable:
#
#   fn first(xs: List[T]) -> T                 T established by the List
#   fn lookup(m: MutableArray[K], key: K) -> K  K established, then used
#   fn empty() -> List[T]                       T only in the result
#   std::ffi::c::null() -> std::ffi::c::Ptr[T]  (an intrinsic, the same way)
#
# A variable is *established* by an argument when it occurs inside an applied
# type of the parameter (an element of List, ImmutableSet, MutableArray or
# MutableVector, a pointee of std::ffi::c::Ptr, a type of a std::ffi::c::FnPtr
# signature): the argument's static type there says what it is. A bare
# parameter `x: T`, or T inside a Fn type, establishes nothing: it only *uses*
# a variable an earlier parameter established (left to right), so
#
#   fn identity(x: T) -> T        is rejected (IMPRINT): nothing says what T is
#   fn sizeof(x: T) -> int        likewise
#
# A variable that occurs only in the result is supplied at the call:
#
#   std::ffi::c::null[ssl::SSL]()      empty[int]()      first[str](xs)
#
# Explicit imprints are all or nothing: `f[A, B](...)` gives every variable of
# f, in the order they first occur in its signature (parameter types left to
# right, then the result). Without them every variable must be established by
# the arguments. Either way the imprinted parameter types are what the
# arguments are then held to (an explicit imprint also constrains an
# argument: `first[int]([])` is a List[int] call), and the result is the
# imprinted result type.
#
# One path for every callable: a Botlish function's imprint signature is its
# declared parameter and result types (resolved with imprint variables,
# hir::resolve::ResolveTypeExpr's IMPRINTS); an intrinsic's is its registry
# entry's -imprint (core/native.tcl). Both are bound by Bind, substituted by
# Substitute and checked by verify, from hir::types::Call and
# hir::range::VerifyCall.
#
# In the body a variable is rigid ({imprint T}, hir/types.tcl): it relates
# only to itself, never and any, so the body is checked once, for every T,
# and is compiled once (as values of any type are). A variable bound to an
# affine type where values of it exist would let the body copy them, so a
# binding that is affine in a value position is rejected; in a pointee
# position (std::ffi::c::Ptr[T]) no value of T exists and any pointee is fine.
#
# An imprinted callable is not a value: a reference to one is only the callee
# of a call (a function value has no call site to imprint at).

namespace eval hir::imprint {}

# 1 if NAME may be an imprint variable: one capital letter, optionally
# followed by digits (T, K, V, T2), naming no visible type.
proc hir::imprint::IsVariableName {name} {
    return [regexp {^[A-Z][0-9]*$} $name]
}

# The occurrences of imprint variables in TYPE: a list of {NAME ESTABLISHING
# POSITION}, in order, POSITION `value` (values of the variable's type exist
# there), `pointee` (a pointer's pointee: an identity only), `cvalue` (a type
# of a C signature) or `csignature` (a whole C signature, FnPtr[F]). ESTABLISHING is 1 inside an applied type, 0 for a
# bare occurrence or one inside a Fn type (CONTEXT: whether TYPE itself is
# inside an applied type).
proc hir::imprint::Occurrences {type {establishing 0} {position value}} {
    if {[hir::types::IsImprint $type]} {
        return [list [list [lindex $type 1] $establishing $position]]
    }
    set result {}
    if {[llength $type] < 2} {
        return {}
    }
    switch -- [lindex $type 0] {
        srefined {
            # A refinement of an applied type (LIST-CARDINALITY-
            # REFINEMENTS.md): its base's occurrences.
            if {[hir::types::IsRefinedApplied $type]} {
                return [Occurrences [hir::refinements::Base $type] $establishing $position]
            }
        }
        list - immutableSet - mutarray - mutvec {
            lappend result {*}[Occurrences [lindex $type 1] 1 value]
        }
        nstruct {
            # An application of a parameterized struct (TRAIT-CONSTRAINED-
            # IMPRINTED-TYPES.md): each argument is an applied type's, so a
            # variable there is established by the argument's own.
            foreach t [hir::types::StructArgs $type] {
                lappend result {*}[Occurrences $t 1 value]
            }
        }
        cptr {
            lappend result {*}[Occurrences [lindex $type 1] 1 pointee]
        }
        cfnptr {
            set fn [lindex $type 1]
            if {[hir::types::IsImprint $fn]} {
                return [list [list [lindex $fn 1] 1 csignature]]
            }
            foreach t [hir::types::FnArgs $fn] {
                lappend result {*}[Occurrences $t 1 cvalue]
            }
            lappend result {*}[Occurrences [hir::types::FnReturn $fn] 1 cvalue]
        }
        fn - coroutine {
            set fields [lindex $type 1]
            foreach t [dict get $fields args] {
                lappend result {*}[Occurrences $t 0 value]
            }
            lappend result {*}[Occurrences [dict get $fields return] 0 value]
        }
    }
    return $result
}

# 1 if TYPE mentions an imprint variable.
proc hir::imprint::Mentions {type} {
    return [expr {[Occurrences $type] ne ""}]
}

# The imprint variables of PARAMS and RESULT, in the order they first occur
# (the order explicit imprints are given in).
proc hir::imprint::VariablesOf {params result} {
    set vars {}
    foreach type [concat $params [list $result]] {
        foreach occurrence [Occurrences $type] {
            set name [lindex $occurrence 0]
            if {$name ni $vars} {
                lappend vars $name
            }
        }
    }
    return $vars
}

# The problems of a declared signature: a list of {INDEX NAME} for each
# parameter INDEX whose type uses imprint variable NAME that no earlier
# parameter (nor it itself, inside an applied type) establishes.
proc hir::imprint::Unestablished {params} {
    set established {}
    set problems {}
    set index 0
    foreach type $params {
        set occurrences [Occurrences $type]
        foreach occurrence $occurrences {
            lassign $occurrence name establishing
            if {$establishing && $name ni $established} {
                lappend established $name
            }
        }
        foreach occurrence $occurrences {
            lassign $occurrence name establishing
            if {!$establishing && $name ni $established
                    && [lsearch -exact -index 1 $problems $name] < 0} {
                lappend problems [list $index $name]
            }
        }
        incr index
    }
    return $problems
}

# Diagnoses block E's declared signature (hir::resolve's function case,
# after its parameter and result types resolved with imprint variables):
# every unestablished variable is TYPE, located at the block -- from the
# program's point of view the name is an invalid type there, as it always
# was (the message says both readings). Returns the
# parameter types with each such parameter's declaration dropped ({}), so no
# analysis sees a variable no call can bind. NAMES are the parameters' source
# names.
proc hir::imprint::CheckSignature {hirVar e params names} {
    upvar 1 $hirVar hir
    foreach problem [Unestablished $params] {
        lassign $problem index name
        hir::Diagnose hir TYPE [format \
            {unknown or invalid type for parameter "%s": no type named %s is visible here, and as an imprint variable %s is not established -- a parameter whose type is %s itself (or holds it in a Fn type) cannot say what %s is; an earlier parameter must hold it in an applied type (List[%s], MutableArray[%s], std::ffi::c::Ptr[%s], ...), or it may occur in the result only, to be imprinted at each call (f[TYPE](...))} \
            [lindex $names $index] $name $name $name $name $name $name $name] $e
        lset params $index {}
    }
    return $params
}

# The imprint signature {vars {T...} params {P...} result R} of the callee
# whose static type is CALLEETYPE in HIR, or "" when it has none (no
# variable, or not a statically known callee).
proc hir::imprint::Signature {hir calleeType} {
    if {[lindex $calleeType 0] eq "native" && [llength $calleeType] == 2} {
        set meta [core::native::metadata [lindex $calleeType 1]]
        if {![dict exists $meta imprint] || [dict get $meta imprint] eq ""} {
            return ""
        }
        return [dict get $meta imprint]
    }
    if {[hir::types::IsExactBlock $calleeType]} {
        return [BlockSignature $hir [lindex $calleeType 1]]
    }
    return ""
}

# The imprint signature of block E (its declared types), or "".
proc hir::imprint::BlockSignature {hir e} {
    set node [dict get $hir exprs $e]
    if {![dict exists $node declaredParamTypes]} {
        return ""
    }
    set params [dict get $node declaredParamTypes]
    set result [dict getdef $node declaredResult {}]
    if {[string first imprint $params$result] < 0} {
        # (The common case, decided without walking the types.)
        return ""
    }
    set vars [VariablesOf $params $result]
    if {$vars eq ""} {
        return ""
    }
    return [dict create vars $vars params $params result $result]
}

# The imprint variables of the functions whose bodies resolution context CTX
# is in (hir/resolve.tcl's `blocks`, outermost first): the names a call's
# explicit imprint there may forward (`fn mynull() -> Ptr[T]:
# std::ffi::c::null[T]()`), each the rigid variable of its function.
proc hir::imprint::EnclosingVariables {hir ctx} {
    set vars {}
    if {![dict exists $ctx blocks]} {
        return {}
    }
    foreach pair [dict get $ctx blocks] {
        set sig [BlockSignature $hir [lindex $pair 0]]
        if {$sig ne ""} {
            lappend vars {*}[dict get $sig vars]
        }
    }
    return [lsort -unique $vars]
}

# {NAME {TRAIT ...} ...}: the constraints of the imprint variables of the
# functions whose bodies resolution context CTX is in (EnclosingVariables'),
# as their signatures carry them (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): a
# type written in the body that names one of them is that function's
# variable, constrained exactly so.
proc hir::imprint::EnclosingConstraints {hir ctx} {
    set result [dict create]
    if {![dict exists $ctx blocks]} {
        return $result
    }
    foreach pair [dict get $ctx blocks] {
        set sig [BlockSignature $hir [lindex $pair 0]]
        if {$sig ne ""} {
            dict for {name traits} [ConstraintsOf $sig] {
                dict set result $name $traits
            }
        }
    }
    return $result
}

# TYPE, written in a body resolved in context CTX, as that body has it: in a
# specialization for one binding of its function's constrained variables
# (hir::traits' imprint clones, TRAIT-CONSTRAINED-IMPRINTED-TYPES.md) each
# of them is the type the binding imprints.
proc hir::imprint::BodyType {ctx type} {
    set binding [dict getdef $ctx cloneImprints {}]
    if {$binding eq {} || ![Mentions $type]} {
        return $type
    }
    return [hir::types::canonical [Substitute $type $binding]]
}

# The positions (value, pointee, cvalue) at which variable NAME occurs in
# signature SIG.
proc hir::imprint::Positions {sig name} {
    set positions {}
    foreach type [concat [dict get $sig params] [list [dict get $sig result]]] {
        foreach occurrence [Occurrences $type] {
            if {[lindex $occurrence 0] eq $name && [lindex $occurrence 2] ni $positions} {
                lappend positions [lindex $occurrence 2]
            }
        }
    }
    return $positions
}

# Binds signature SIG's variables for a call with argument types ARGTYPES
# and explicit imprints EXPLICIT (resolved types; "" for none, a list
# otherwise). CALLEE names the callee for messages. Returns {ok 1 binding
# {T TYPE ...}} or {ok 0 message TEXT}.
proc hir::imprint::Bind {sig argTypes explicit callee} {
    set vars [dict get $sig vars]
    set binding [dict create]
    set mismatches {}
    if {$explicit ne ""} {
        if {[llength $explicit] != [llength $vars]} {
            return [dict create ok 0 message [format \
                {%s takes %d imprint(s), [%s] (in the order they first occur in its signature), but %d %s given} \
                $callee [llength $vars] [join $vars {, }] [llength $explicit] \
                [expr {[llength $explicit] == 1 ? "is" : "are"}]]]
        }
        foreach name $vars type $explicit {
            dict set binding $name $type
        }
    } else {
        set index 0
        foreach param [dict get $sig params] argType $argTypes {
            incr index
            if {$param eq "" || $argType eq "" || ![Mentions $param]} {
                # (An argument type "" establishes nothing: a byte owner
                # exposed to a foreign pointer parameter, hir/borrow.tcl.)
                continue
            }
            set problem [Match $param $argType binding $index]
            if {$problem ne ""} {
                return [dict create ok 0 message "$callee: $problem"]
            }
        }
        foreach name $vars {
            if {![dict exists $binding $name]} {
                set where [expr {[Establishable $sig $name] ? "the arguments do not establish it here" : "it occurs only in the result, and no type named $name is visible where $callee is declared"}]
                return [dict create ok 0 unestablished 1 message [format \
                    {%s: imprint variable %s is not established (%s): write %s[%s](...) with explicit imprints} \
                    $callee $name $where $callee [join $vars {, }]]]
            }
            if {[dict get $binding $name] eq "never" && [UsedBare $sig $name]} {
                # Only an empty List's element said what the variable is,
                # which says nothing; a parameter of the variable's own type
                # would have to be held to `never`.
                return [dict create ok 0 unestablished 1 message [format \
                    {%s: imprint variable %s is not established (only an empty List holds it here, which says nothing about %s): write %s[%s](...) with explicit imprints} \
                    $callee $name $name $callee [join $vars {, }]]]
            }
        }
    }
    foreach name $vars {
        set type [dict get $binding $name]
        set problem [BindingProblem $sig $name $type]
        if {$problem ne ""} {
            return [dict create ok 0 message "$callee: $problem"]
        }
    }
    if {[ConstraintsOf $sig] ne {}} {
        # The constructors' obligations (TRAIT-CONSTRAINED-IMPRINTED-
        # TYPES.md): once the variables are established, every application
        # of the imprinted signature must be a valid one -- the ordinary
        # trait satisfaction of each constrained slot's argument. A failure
        # is a trait failure, not an imprinting one.
        foreach type [concat [dict get $sig params] [list [dict get $sig result]]] {
            if {$type eq ""} continue
            set problem [hir::structs::ApplicationProblem [Substitute $type $binding]]
            if {$problem ne ""} {
                return [dict create ok 0 trait 1 binding $binding message "$callee: $problem"]
            }
        }
    }
    return [dict create ok 1 binding $binding]
}

# 1 if some parameter of SIG holds variable NAME bare (or in a Fn type):
# where values of the variable's own type are arguments.
proc hir::imprint::UsedBare {sig name} {
    foreach param [dict get $sig params] {
        foreach occurrence [Occurrences $param] {
            if {[lindex $occurrence 0] eq $name && ![lindex $occurrence 1]} {
                return 1
            }
        }
    }
    return 0
}

# 1 if some parameter of SIG can establish variable NAME.
proc hir::imprint::Establishable {sig name} {
    foreach param [dict get $sig params] {
        foreach occurrence [Occurrences $param] {
            if {[lindex $occurrence 0] eq $name && [lindex $occurrence 1]} {
                return 1
            }
        }
    }
    return 0
}

# Why variable NAME of SIG cannot be bound to TYPE, or "".
proc hir::imprint::BindingProblem {sig name type} {
    set positions [Positions $sig $name]
    set shown [hir::cabi::ShowPointee $type]
    if {"pointee" in $positions} {
        set problem [hir::cabi::PointeeProblem $type]
        if {$problem ne ""} {
            return "$name is imprinted as $shown, which cannot be a pointee: $problem"
        }
    }
    if {"csignature" in $positions} {
        set problem [hir::cabi::SignatureProblem $type]
        if {$problem ne ""} {
            return "$name is imprinted as [hir::types::show $type], which is not a C signature: $problem"
        }
    }
    if {"cvalue" in $positions} {
        set problem [hir::cabi::ValueTypeProblem $type]
        if {$problem ne ""} {
            return "$name is imprinted as $shown, a type of a C signature: $problem"
        }
    }
    if {"value" in $positions} {
        if {$type eq "void"} {
            return "$name is imprinted as $shown, but values of $name exist here: [hir::cabi::VoidMessage]"
        }
        if {[hir::cabi::IsFloating $type]} {
            # (A C floating type is a representation: its values are its
            # carrier's, C-FLOAT-FFI-MILESTONE-1.md.)
            return "$name is imprinted as $shown, a C representation, but values of $name exist here: the values of $shown are [hir::types::show [hir::cabi::Carrier $type]]s (imprint [hir::types::show [hir::cabi::Carrier $type]])"
        }
        if {[hir::types::IsAffine $type]} {
            return "$name is imprinted as $shown, an affine type, where values of $name exist: an imprinted function's body is checked for every $name and may copy its values, so $name is never an affine type there"
        }
    }
    return ""
}

# Establishes the variables of declared type PARAM from argument type ARG
# into the binding in BINDINGVAR; returns "" or why argument INDEX does not
# have PARAM's form.
proc hir::imprint::Match {param arg bindingVar index} {
    upvar 1 $bindingVar binding
    # A List length is no part of a form a variable is established from: a
    # refined List[T]{length: N} parameter has List[T]'s form, and a refined
    # argument is matched as its List (LIST-CARDINALITY-REFINEMENTS.md).
    set param [hir::types::Unrefined $param]
    set arg [hir::types::Unrefined $arg]
    if {[hir::types::IsImprint $param]} {
        # Only reached inside an applied type: a bare top-level variable
        # is a use (Bind's caller skips nothing, but Occurrences decided).
        return ""
    }
    if {[llength $param] < 2} {
        return ""
    }
    set head [lindex $param 0]
    switch -- $head {
        list - immutableSet - mutarray - mutvec {
            set elem ""
            if {$arg eq "never"} {
                set elem never
            } elseif {[lindex $arg 0] eq $head && [llength $arg] >= 2} {
                set elem [lindex $arg 1]
            } elseif {$arg eq $head || $arg eq "any"} {
                set elem any
            } else {
                return [FormMismatch $param $arg $index]
            }
            return [MatchInner [lindex $param 1] $elem binding $index]
        }
        nstruct {
            if {![hir::types::IsAppliedStruct $param]} {
                return ""
            }
            # An application (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): the
            # argument's application of the same constructor, slot by slot.
            set id [lindex $param 1]
            set n [llength [lindex $param 2]]
            if {$arg eq "never"} {
                set args [lrepeat $n never]
            } elseif {[hir::types::IsAppliedStruct $arg] && [lindex $arg 1] eq $id} {
                set args [lindex $arg 2]
            } elseif {$arg in {any struct}} {
                set args [lrepeat $n any]
            } else {
                return [FormMismatch $param $arg $index]
            }
            foreach p [lindex $param 2] a $args {
                set problem [MatchInner $p $a binding $index]
                if {$problem ne ""} {
                    return $problem
                }
            }
            return ""
        }
        cptr {
            if {$arg eq "never"} {
                return [MatchInner [lindex $param 1] never binding $index]
            }
            if {![hir::types::IsCPtr $arg]} {
                return [FormMismatch $param $arg $index]
            }
            return [MatchInner [lindex $param 1] [lindex $arg 1] binding $index]
        }
        cfnptr {
            if {$arg eq "never"} {
                return ""
            }
            if {![hir::types::IsCFnPtr $arg]} {
                return [FormMismatch $param $arg $index]
            }
            set pf [lindex $param 1]
            set af [lindex $arg 1]
            if {[hir::types::IsImprint $pf]} {
                return [MatchInner $pf $af binding $index]
            }
            if {[llength [hir::types::FnArgs $pf]] != [llength [hir::types::FnArgs $af]]} {
                return [FormMismatch $param $arg $index]
            }
            foreach p [hir::types::FnArgs $pf] a [hir::types::FnArgs $af] {
                set problem [MatchInner $p $a binding $index]
                if {$problem ne ""} {
                    return $problem
                }
            }
            return [MatchInner [hir::types::FnReturn $pf] [hir::types::FnReturn $af] binding $index]
        }
    }
    return ""
}

# Match at an establishing position: PARAM inside an applied type.
proc hir::imprint::MatchInner {param arg bindingVar index} {
    upvar 1 $bindingVar binding
    if {[hir::types::IsImprint $param]} {
        # (A variable an argument establishes is the type a declaration
        # could state of its elements: the lengths inference minted for
        # them are forgotten, so Lists of two lengths establish one T.)
        set arg [hir::types::ForgetInferred $arg]
        set name [lindex $param 1]
        if {![dict exists $binding $name] || [dict get $binding $name] eq "never"} {
            # (`never` -- an empty List's element -- says nothing a later
            # argument cannot say better.)
            dict set binding $name $arg
        } elseif {$arg ne "never" && [dict get $binding $name] ne $arg} {
            return [format {imprint variable %s is %s by an earlier argument but %s by argument %d} \
                $name [hir::cabi::ShowPointee [dict get $binding $name]] [hir::cabi::ShowPointee $arg] $index]
        }
        return ""
    }
    return [Match $param $arg binding $index]
}

proc hir::imprint::FormMismatch {param arg index} {
    set expected [hir::types::show $param]
    set actual [hir::types::show $arg]
    if {[hir::types::IsCPtr $param] && [hir::types::IsCFnPtr $arg]} {
        return "argument $index is the C function pointer $actual where a data pointer $expected is required: data and function pointers are distinct, and nothing converts one into the other"
    }
    if {[hir::types::IsCFnPtr $param] && [hir::types::IsCPtr $arg]} {
        return "argument $index is the C data pointer $actual where a function pointer $expected is required: data and function pointers are distinct, and nothing converts one into the other"
    }
    return "argument $index of type $actual does not have the form $expected, so it cannot imprint [join [lmap o [Occurrences $param] {lindex $o 0}] {, }]"
}

# ---------------------------------------------------------------------------
# Constrained variables (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md)
#
# A parameterized struct may constrain a slot with a trait:
#
#   struct Map[K satisfies Hashable, V]: ...
#   fn get(m: Map[K, V], key: K) -> V errors KeyNotFound
#
# Every valid application Map[X, Y] has X satisfies Hashable, so a function
# whose contract mentions Map[K, V] knows K satisfies Hashable: matching the
# application establishes K and V as always (Bind), and the constructor's
# obligation on its first slot is K's. No function declares a constraint;
# Constrain derives it from the signature's applications and writes it on
# the variable, {imprint K {Hashable}}, at every occurrence, so the body sees
# K itself (never Hashable, never a view) together with the fact -- which
# the trait-reading checks consult as they consult a view's trait
# (hir::types::Totality, hir::traits::satisfies, TypeCall). A constraint
# only validates and enriches a variable an argument establishes (or a call
# supplies explicitly): it never establishes one (Unestablished is
# unchanged). At a call, every application of the imprinted signature must
# be valid for the binding (Bind: the ordinary trait satisfaction of each
# constrained slot's argument), reported as the trait failure it is.

# The immediate component types of TYPE that may hold an application or a
# variable: elements, a pointee, a signature's types, fields, arguments.
proc hir::imprint::Parts {type} {
    if {[llength $type] < 2 || [hir::types::IsImprint $type]} {
        return {}
    }
    switch -- [lindex $type 0] {
        srefined {
            if {[hir::types::IsRefinedApplied $type]} {
                return [list [hir::refinements::Base $type]]
            }
        }
        list {
            if {[llength $type] == 3} {
                return [concat [list [lindex $type 1]] [lindex $type 2]]
            }
            return [list [lindex $type 1]]
        }
        immutableSet - mutarray - mutvec - cptr {
            return [list [lindex $type 1]]
        }
        cfnptr {
            return [Parts [lindex $type 1]]
        }
        fn - coroutine {
            set fields [lindex $type 1]
            return [concat [dict get $fields args] [list [dict get $fields return]]]
        }
        struct {
            return [lmap {name t} [lindex $type 1] {set t}]
        }
        nstruct {
            return [hir::types::StructArgs $type]
        }
    }
    return {}
}

# The imprint variable names TYPE mentions, at any depth.
proc hir::imprint::VariablesIn {type} {
    if {[hir::types::IsImprint $type]} {
        return [list [lindex $type 1]]
    }
    set names {}
    foreach t [Parts $type] {
        foreach name [VariablesIn $t] {
            if {$name ni $names} {
                lappend names $name
            }
        }
    }
    return $names
}

# Adds to the dict in TRAITSVAR (variable -> {TRAIT ...}) the obligations
# the applications in TYPE give its variables: a constrained slot whose
# argument is a variable gives it the slot's traits; one whose argument is
# a composite of variables, an intrinsic trait (its witness predicate
# recurses into components, HASHABLE-AND-KEYED-HASH.md: List[K] is Hashable
# exactly when K is) gives every variable of the argument the trait -- an
# over-approximation only for a slot the struct never stores, and sound. A
# composite argument never satisfies an ordinary trait (an applied type is
# no witness, TRAITS.md), which verification reports.
proc hir::imprint::Obligations {type traitsVar} {
    upvar 1 $traitsVar traits
    if {[hir::types::IsAppliedStruct $type]} {
        set constraints [hir::structs::slotConstraints [lindex $type 1]]
        foreach slot [hir::structs::slots [lindex $type 1]] arg [lindex $type 2] {
            set required [dict getdef $constraints $slot {}]
            if {$required eq {}} {
                continue
            }
            if {[hir::types::IsImprint $arg]} {
                dict lappend traits [lindex $arg 1] {*}$required
                continue
            }
            foreach trait $required {
                if {![hir::traits::isIntrinsic $trait]} {
                    continue
                }
                foreach name [VariablesIn $arg] {
                    dict lappend traits $name $trait
                }
            }
        }
    }
    foreach t [Parts $type] {
        Obligations $t traits
    }
}

# TYPE with every imprint variable named in CONSTRAINTS (variable -> {TRAIT
# ...}) constrained by exactly those traits ({imprint NAME TRAITS}), every
# other one as it is.
proc hir::imprint::ConstrainVariables {type constraints} {
    if {$constraints eq {} || [string first imprint $type] < 0} {
        return $type
    }
    set binding [dict create]
    dict for {name traits} $constraints {
        dict set binding $name [hir::types::MakeImprint $name $traits]
    }
    return [Substitute $type $binding]
}

# {PARAMS RESULT}: a function's declared parameter types PARAMS ("" for an
# untyped one) and result type RESULT ("" for none) with every imprint
# variable constrained by the obligations their applications give it
# (Obligations), at every occurrence; unchanged when there are none.
proc hir::imprint::Constrain {params result} {
    set all [concat $params [list $result]]
    if {[string first imprint $all] < 0 || [string first nstruct $all] < 0} {
        return [list $params $result]
    }
    set traits [dict create]
    foreach type $all {
        if {$type ne ""} {
            Obligations $type traits
        }
    }
    if {[dict size $traits] == 0} {
        return [list $params $result]
    }
    set constrained [lmap t $params {
        if {$t eq ""} { set t } else { ConstrainVariables $t $traits }
    }]
    if {$result ne ""} {
        set result [ConstrainVariables $result $traits]
    }
    return [list $constrained $result]
}

# {NAME {TRAIT ...} ...}: the constraints of the variables of signature SIG,
# as its types carry them.
proc hir::imprint::ConstraintsOf {sig} {
    set result [dict create]
    foreach type [concat [dict get $sig params] [list [dict get $sig result]]] {
        VariableConstraints $type result
    }
    return $result
}

proc hir::imprint::VariableConstraints {type resultVar} {
    upvar 1 $resultVar result
    if {[hir::types::IsImprint $type]} {
        if {[hir::types::ImprintConstraints $type] ne {}} {
            dict set result [lindex $type 1] [hir::types::ImprintConstraints $type]
        }
        return
    }
    foreach t [Parts $type] {
        VariableConstraints $t result
    }
}

# TYPE with every imprint variable replaced by its type in BINDING, in
# canonical form.
proc hir::imprint::Substitute {type binding} {
    if {[hir::types::IsImprint $type]} {
        set name [lindex $type 1]
        return [dict getdef $binding $name $type]
    }
    if {[llength $type] < 2} {
        return $type
    }
    switch -- [lindex $type 0] {
        srefined {
            if {[hir::types::IsRefinedApplied $type]} {
                return [hir::types::Refine [Substitute [hir::refinements::Base $type] $binding] \
                    [hir::refinements::Family $type] [hir::refinements::Facts $type]]
            }
        }
        list {
            if {[llength $type] == 3} {
                return [hir::types::MakeList [Substitute [lindex $type 1] $binding] \
                    [lmap p [lindex $type 2] {Substitute $p $binding}] 1]
            }
            return [hir::types::MakeList [Substitute [lindex $type 1] $binding]]
        }
        immutableSet {
            return [hir::types::MakeSet [Substitute [lindex $type 1] $binding] 0]
        }
        mutarray {
            return [hir::types::MakeMutArray [Substitute [lindex $type 1] $binding] 0]
        }
        mutvec {
            return [hir::types::MakeMutVec [Substitute [lindex $type 1] $binding] 0]
        }
        nstruct {
            if {[llength $type] == 3} {
                return [hir::types::MakeApplied [lindex $type 1] [lmap t [lindex $type 2] {Substitute $t $binding}]]
            }
        }
        struct {
            set fields [dict create]
            foreach {name t} [lindex $type 1] {
                dict set fields $name [Substitute $t $binding]
            }
            return [hir::types::MakeStruct $fields 0]
        }
        cptr {
            return [list cptr [Substitute [lindex $type 1] $binding]]
        }
        cfnptr {
            return [list cfnptr [Substitute [lindex $type 1] $binding]]
        }
        fn {
            return [hir::types::MakeFn [lmap t [hir::types::FnArgs $type] {Substitute $t $binding}] \
                [Substitute [hir::types::FnReturn $type] $binding] [hir::types::FnErrors $type]]
        }
        coroutine {
            set fields [lindex $type 1]
            return [hir::types::MakeCoroutineType [lmap t [dict get $fields args] {Substitute $t $binding}] \
                [Substitute [dict get $fields return] $binding] [dict get $fields errors]]
        }
    }
    return $type
}

# The binding the typing of call E recorded (hir::types::Call), or "" when
# the call binds none (no imprint signature, or a problem: callImprint).
proc hir::imprint::BindingOf {hir e} {
    set node [dict get $hir exprs $e]
    return [dict getdef $node imprintBinding ""]
}

# Types call E (hir::types::Call's part): with CALLEETYPE's imprint
# signature, binds it for ARGTYPES and the call's explicit imprints, records
# the binding (imprintBinding) or the problem (imprintProblem) on the node,
# and returns RESULT -- the type the call would have without imprints (the
# callee's result, which may mention its variables) -- imprinted with the
# binding; without a binding, the signature's own result is replaced by
# FALLBACK (the run-time kind contract).
proc hir::imprint::Call {hirVar e calleeType argTypes result fallback} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    set explicit [dict getdef $node imprint ""]
    set sig [Signature $hir $calleeType]
    if {$sig eq "" && $explicit eq ""} {
        # (The common case: no imprint anywhere. The node is left alone
        # unless an earlier pass recorded something for it.)
        if {[dict exists $node imprintBinding] || [dict exists $node imprintProblem]
                || [dict exists $node imprintPoisoned]} {
            dict unset node imprintBinding
            dict unset node imprintProblem
            dict unset node imprintTrait
            dict unset node imprintPoisoned
            dict set hir exprs $e $node
        }
        return $result
    }
    dict unset node imprintBinding
    dict unset node imprintProblem
    dict unset node imprintTrait
    dict unset node imprintPoisoned
    if {$sig eq ""} {
        dict set node imprintProblem [format \
            {%s has no imprint variables, so it takes no imprint %s[...]: only a callable whose signature has an imprint variable (a statically known function or intrinsic) is imprinted at a call} \
            [CalleeName $hir $node] [CalleeName $hir $node]]
        dict set hir exprs $e $node
        return $result
    }
    set poisoned 0
    set i 0
    foreach arg [dict get $node args] {
        if {$arg ne "" && [dict exists $hir poisoned $arg]} {
            # A value an earlier diagnostic rejected (hir/types.tcl,
            # "Poison") establishes nothing.
            lset argTypes $i ""
            set poisoned 1
        }
        incr i
    }
    set bound [Bind $sig $argTypes $explicit [CalleeName $hir $node]]
    if {![dict get $bound ok] && $poisoned && [dict exists $bound unestablished]} {
        # What a poisoned argument would have established is not known:
        # no problem of this call's own, and nothing to hold the other
        # arguments to (Unbound).
        dict set node imprintPoisoned 1
        dict set hir exprs $e $node
        if {[Mentions $result]} {
            return $fallback
        }
        return $result
    }
    if {![dict get $bound ok]} {
        dict set node imprintProblem [dict get $bound message]
        if {[dict exists $bound trait]} {
            # The variables are established, but an application of the
            # signature is invalid for them: a trait failure (verify's
            # TRAIT-NOT-SATISFIED), never an imprinting one.
            dict set node imprintTrait 1
        }
        dict set hir exprs $e $node
        if {[Mentions $result]} {
            return $fallback
        }
        return $result
    }
    set binding [dict get $bound binding]
    dict set node imprintBinding $binding
    dict set hir exprs $e $node
    return [hir::types::canonical [Substitute $result $binding]]
}

# The callee of call NODE, as a message names it.
proc hir::imprint::CalleeName {hir node} {
    set callee [dict get $hir exprs [dict get $node callee]]
    if {[dict get $callee kind] eq "ref"} {
        return [hir::semantic::RefName $hir [dict get $node callee]]
    }
    return "this callee"
}

# The parameter types of the callee of call E, imprinted with the call's
# binding: TYPES (the callee's declared or registered parameter types) as the
# arguments are held to them.
proc hir::imprint::Parameters {hir e types} {
    set binding [BindingOf $hir $e]
    if {$binding eq ""} {
        return $types
    }
    return [lmap t $types {if {$t eq ""} {string cat ""} else {Substitute $t $binding}}]
}

# 1 if call E's imprints could not be bound (its problem is diagnosed by
# verify; its arguments are not checked against unbound variables).
proc hir::imprint::Unbound {hir e} {
    return [expr {[dict exists $hir exprs $e imprintProblem] || [dict exists $hir exprs $e imprintPoisoned]}]
}

# Diagnoses HIR's imprint problems: each reachable call whose imprints did
# not bind (IMPRINT, at the call), and each reference to an imprinted
# callable that is not a call's callee (IMPRINT: an imprinted callable is not
# a value). Only source-written calls are diagnosed: core IR has no imprint
# syntax, and a core IR call of an imprinted intrinsic keeps its run-time
# kind contract.
proc hir::imprint::verify {hirVar} {
    upvar 1 $hirVar hir
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict exists $node structInferProblem]
                && (![dict exists $node reachable] || [dict get $node reachable])} {
            # A parameterized struct's construction that does not establish
            # its slots (hir::types::InferApplication).
            hir::Diagnose hir IMPRINT [dict get $node structInferProblem] $e
            continue
        }
        if {[dict get $node kind] ne "call"} {
            continue
        }
        dict set callees [dict get $node callee] 1
        if {![dict exists $node imprintProblem]} {
            continue
        }
        if {![dict exists $node written] && ![dict exists $node imprint]} {
            continue
        }
        if {[dict exists $node reachable] && ![dict get $node reachable]} {
            continue
        }
        # The call's own problem with its callee: the callee's imprint
        # variables do not bind for it (hir::CheckingCall).
        hir::CheckingCall $e {
            if {[dict exists $node imprintTrait]} {
                hir::Diagnose hir TRAIT-NOT-SATISFIED [dict get $node imprintProblem] $e
            } else {
                hir::Diagnose hir IMPRINT [dict get $node imprintProblem] $e
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} {
            continue
        }
        if {[dict exists $node reachable] && ![dict get $node reachable]} {
            continue
        }
        set type [hir::typeOf $hir $e]
        if {[Signature $hir $type] eq ""} {
            continue
        }
        hir::Diagnose hir IMPRINT [format \
            {%s has imprint variables, so it is not a value: an imprinted callable is only called, where each call imprints its variables (wrap the call in a function to pass it on)} \
            [hir::semantic::RefName $hir $e]] $e
    }
}
