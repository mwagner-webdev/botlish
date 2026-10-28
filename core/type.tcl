# type.tcl -- semantic value types: what it means for a value to have a type.
#
# A (checkable) type is one of:
#
#   int str bool unit list result block native
#                             every value of that kind (a *primitive* type)
#   any                       every value
#   {refined BASE {NAME...}}  values of kind BASE that satisfy every named
#                             type NAME (sorted, unique)
#
# A registered name may be written alone as shorthand: Byte means
# {refined int {Byte}}. normalize produces the canonical form, and all
# registries store canonical types.
#
# A named type is one of two kinds:
#
#   * a *validator* type is structural: a command prefix, called with the
#     value, decides membership (1/0). The integer domains Botlish source
#     declares ("type Byte = Int in 0..255", stdlib/byte.bot) are validator
#     types (-integer-domain, which supplies the validator; see
#     SOURCE-DEFINED-INTEGER-DOMAINS.md); so are the Result tags
#     (core/predicates.tcl). -source marks a source-declared entry, purely so
#     hir/sourcetypes.tcl can unregister it again between compilations
#     (core::type::unregister) -- everything else about it (validation,
#     subtyping, facts) is identical to a Tcl-registered type.
#   * a *refinement* type (-refinement, REFINEMENT-VALUES.md) is nominal:
#     "refined type Emailish = str" declares a new type whose values are
#     exactly values of its carrier type known, by a proof, to satisfy its
#     proposition. Membership is a static proof fact only -- established by
#     a proof-producing function of the declaring module (`proves`), never by
#     a runtime test -- and a refined value has exactly its carrier's runtime
#     representation: no evidence, tag or wrapper. Its parents are its
#     carrier's own named types, so it is a subtype of its carrier (and of
#     its carrier's carrier): forgetting a refinement is ordinary subtyping.
#
# A type is never a value: registering one registers nothing callable. No
# type gets a membership predicate (a `NAME?`), a constructor or any other
# native from its registration (ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md). A
# validator decides membership for the runtime's own contract checks
# (acceptsValue, below) and for a native explicitly registered as a type
# test of the type (core/native.tcl's -tests-type: `ok?`/`error?` of the
# Result tags); Botlish source admits a value into an integer domain by
# range facts (hir/range.tcl), and into a refinement by a proof.
#
# Values carry no type information beyond their kind: there is no runtime
# evidence (Strings used to carry "evidence" of opaque named types, attached
# by trusted natives; REFINEMENT-VALUES.md replaced that with source-level
# proofs). The interpreter is the specification of these rules; the compiler
# (hir/types.tcl) consumes the same definitions for its static types.

namespace eval core::type {
    # UnicodeChar is a builtin primitive here (not a source-defined int
    # refinement, item 2 of UNICODE-CHAR-LITERALS.md): the type name is
    # spelled exactly as the runtime kind tag (core::value.tcl), so no
    # alias/translation layer is needed anywhere a plain primitive name is
    # accepted (hir::types::resolveNamed, hir::read::ParseType, ...).
    #
    # immutableSet is the broad ImmutableSet runtime kind (MINIMAL-IMMUTABLE-
    # SET.md), spelled the same way "list" is spelled for List: the applied,
    # source-spellable constructor name is capitalized ("ImmutableSet",
    # hir::types::constructors) and distinct from this bare primitive name,
    # exactly mirroring the List/"list" split -- so this string is also the
    # HIR structural applied-type tag ({immutableSet ELEM}, hir/types.tcl)
    # and every native's -param-types spelling of "a value of set kind",
    # which is what keeps hir::types::narrow's fact-preserving check
    # (`fact eq [kindOf $current]`) correct for a precise ImmutableSet[T]
    # argument the same way it already is for List[T].
    #
    # struct is the broad kind of every struct value (STRUCTS.md), spelled
    # like the runtime kind tag; the precise forms -- an anonymous struct's
    # field types, a named struct's declaration -- are HIR static types
    # (hir/types.tcl), exactly as {list ELEM} refines the bare `list` kind.
    #
    # coroutine is the kind of a coroutine handle (COROUTINES.md): never a
    # source-spellable type (a handle's precise static type is the HIR form
    # {coroutine RESUME OUTWARD ERRORS}, hir/types.tcl), registered so that
    # the runtime kind has a core type, exactly as `block` and `native` do.
    #
    # mutvec is the kind of a MutableVector header (MUTABLE-VECTOR.md): the
    # source-spellable type is the applied MutableVector[T] ({mutvec T},
    # hir/types.tcl); the bare kind is what natives' -param-types say.
    #
    # enum is the broad kind of every enum case value (ENUMS.md), spelled
    # like the runtime kind tag; the precise form -- one enum declaration --
    # is the HIR static type {enum ID} (hir/types.tcl), exactly as {nstruct
    # ID} refines `struct`. It is never source-spellable: an enum type is a
    # named declaration, and the bare kind would be an anonymous one
    # (hir::types::resolveNamed rejects it).
    #
    # cptr is the kind of a raw C address (C-ABI-TYPES.md): a data pointer
    # std::ffi::c::Ptr[T] ({cptr T}) or a function pointer std::ffi::c::FnPtr[F]
    # ({cfnptr F}), hir/types.tcl. Never source-spellable bare: there is no
    # pointer without a pointee identity.
    #
    # The primitive floating-point types (FLOAT64-MILESTONE-1.md) are one
    # family, described once in `floats` below: each is a primitive kind of
    # its own, spelled like its runtime kind tag exactly as UnicodeChar is,
    # and everything that treats them as a family (the operators' resolution,
    # hir/operators.tcl; the natives core/float.tcl registers; the runtime
    # values, core/value.tcl) reads the table instead of naming a width. A
    # further width is a row of the table.
    #
    # NAME -> {width BITS precision P minExponent EMIN maxExponent EMAX
    # namespace NS}: an IEEE 754 binary format of BITS bits, P significand
    # bits (the leading one included), normal exponents EMIN..EMAX; NS is the
    # flat namespace of its standard intrinsics (std::float64::from_int). This is
    # the *semantic* description of the type only. Which backends can
    # represent or compute it, and how, is theirs to say (core/float.tcl's
    # Tcl arithmetic, native/lower.tcl and native/src/runtime/value.rs's
    # FloatType): a type in this table is never assumed to have a machine
    # representation on every target.
    variable floats [dict create \
        Float64 {width 64 precision 53 minExponent -1022 maxExponent 1023 namespace std::float64}]
    # DecimalRounded is the runtime kind of the decimal-rounded numbers
    # (DECIMAL-ROUNDED-MILESTONE-1.md, core/decimal.tcl), spelled like its
    # runtime kind tag as Float64 is. Bare, it is "a decimal-rounded number
    # whose guaranteed precision is not known" -- what a native's
    # -param-types say; the source-spellable types are its scalar
    # refinements, DecimalRounded{minDecimalsPreserved: N, ...}, the HIR form
    # {srefined DecimalRounded FACTS} (hir/refinements.tcl), which an
    # annotation must write (the bare name is no annotation:
    # hir::types::resolveNamed). It is no float type: no float operation
    # takes it, and it is never a Float64.
    variable primitives [list int str bool unit list result block native mutarray UnicodeChar immutableSet struct coroutine mutvec enum cptr {*}[dict keys $floats] DecimalRounded]
    # NAME -> {name NAME base KIND validator CMD parents {NAME...}
    # integerDomain DOMAIN source 0|1 refinement {} | {carrier TYPE owner NS
    # span SPAN} cabi {} | {c SPELLING target TARGET bits N signed 0|1}}
    #
    # cabi (-c-abi) marks a C integer scalar of namespace std::ffi::c
    # (C-ABI-TYPES.md, core/cabi.tcl): an integer domain like any other --
    # its domain is the target's exact range for the C type -- that also
    # records which C type it is on which target, the width and the
    # signedness a C call lowering needs, so that nothing ever recovers them
    # from the type's name. Two scalars of equal range (int and long on
    # LLP64) stay two types: identity is the registry name.
    variable registry [dict create]
}

# ---------------------------------------------------------------------------
# Registry

proc core::type::register {name args} {
    variable primitives
    variable registry
    # A source-declared type of a module is named `NAMESPACE::Name` (its
    # qualified identity, hir/sourcetypes.tcl); a nested namespace has more
    # segments, and a package instance's module's identity begins with the
    # instance, its segments separated by "/" (BOT-MODULES-MILESTONE-1.md:
    # physics/geometry::Small).
    if {![regexp {^[A-Za-z_][A-Za-z0-9_.]*(?:/[A-Za-z_][A-Za-z0-9_]*)*(?:::[A-Za-z_][A-Za-z0-9_.]*)*$} $name]
            || $name in $primitives || $name in {any refined never}} {
        error "core::type::register: invalid type name \"$name\""
    }
    if {[dict exists $registry $name]} {
        error "core::type::register: type \"$name\" is already registered"
    }
    if {[llength $args] % 2} {
        error "core::type::register: options must be -option value pairs"
    }
    set options [dict create -base "" -validator "" -source 0 -c-abi {}]
    dict set options -parents {}
    dict set options -integer-domain {}
    dict set options -refinement {}
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "core::type::register: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set base [dict get $options -base]
    set validator [dict get $options -validator]
    set parents [dict get $options -parents]
    set integerDomain [dict get $options -integer-domain]
    set source [dict get $options -source]
    set refinement [dict get $options -refinement]
    if {$base ni $primitives} {
        error "core::type::register: -base must be one of: $primitives"
    }
    if {$refinement ne {}} {
        # A nominal refinement (REFINEMENT-VALUES.md): no validator, no
        # runtime evidence, no domain -- membership is a static proof fact
        # only, established by a proof-producing function of its owner.
        # Its parents are the evidence its carrier type already has, so
        # forgetting is subtyping (evidenceClosure) and needs no rule here.
        if {$validator ne "" || $integerDomain ne {}} {
            error "core::type::register: -refinement excludes -validator and -integer-domain"
        }
        if {[catch {dict get $refinement carrier; dict get $refinement owner}]} {
            error "core::type::register: -refinement must be a {carrier TYPE owner NAMESPACE ...} dict"
        }
        set carrier [normalize [dict get $refinement carrier]]
        if {[base $carrier] ne $base || [lsort [evidenceOf $carrier]] ne [lsort $parents]} {
            error "core::type::register: a refinement's -base and -parents are its carrier's base and evidence"
        }
        dict set refinement carrier $carrier
    }
    if {$integerDomain ne {}} {
        if {$base ne {int} || $validator ne {}} {
            error {core::type::register: -integer-domain requires -base int and supplies the validator}
        }
        set integerDomain [NormalizeIntegerDomain $integerDomain]
        set validator [list core::type::IntegerDomainValidator $integerDomain]
    }
    set cabi [dict get $options -c-abi]
    if {$cabi ne {} && (![core::cabi::validScalarInfo $cabi] || $parents ne {}
            || $integerDomain ne [core::cabi::scalarDomain $cabi])} {
        error "core::type::register: -c-abi of \"$name\" must be a C scalar's metadata (core::cabi::scalarInfo) with exactly its domain and no parent"
    }
    if {($refinement eq {}) == ($validator eq "")} {
        error "core::type::register: \"$name\" needs exactly one of -validator or -refinement"
    }
    foreach parent $parents {
        if {![dict exists $registry $parent]} { error [format {core::type::register: unknown parent type %s} $parent] }
        if {[dict get $registry $parent base] ne $base} { error [format {core::type::register: parent %s has a different base} $parent] }
    }
    dict set registry $name [dict create name $name base $base validator $validator \
        parents $parents integerDomain $integerDomain source $source refinement $refinement \
        cabi $cabi]
    return $name
}

# The C ABI metadata of type NAME (a registered name): {c SPELLING target
# TARGET bits N signed 0|1} for a C integer scalar (-c-abi), else "".
proc core::type::cabiOf {name} {
    variable registry
    if {![dict exists $registry $name] || ![dict exists $registry $name cabi]} {
        return ""
    }
    return [dict get $registry $name cabi]
}

# Every floating-point type is a runtime value kind (core/value.tcl).
foreach type [dict keys $core::type::floats] {
    if {$type ni $core::value::kinds} {
        error "core/type.tcl: the floating-point type $type is not a kind of core/value.tcl"
    }
}
unset type

# The primitive floating-point types (`floats`), in table order.
proc core::type::floatTypes {} {
    variable floats
    return [dict keys $floats]
}

# 1 if NAME is a primitive floating-point type (a kind of the float family).
proc core::type::isFloat {name} {
    variable floats
    return [dict exists $floats $name]
}

# The `floats` row of the floating-point type NAME.
proc core::type::floatInfo {name} {
    variable floats
    return [dict get $floats $name]
}

# The scalar kinds: the primitive kinds whose values are immutable, carry no
# other value and compare (==) and hash by content alone, with no failure --
# Int, String, Bool, unit, UnicodeChar, an enum case and every floating-point
# type. Analyses that treat "a plain scalar" alike ask this instead of
# spelling the list (a new primitive scalar, a further float width, joins
# them here).
proc core::type::scalarKinds {} {
    variable floats
    return [list int str bool unit UnicodeChar enum {*}[dict keys $floats]]
}

# The C ABI metadata of TYPE (a canonical type) when it is exactly one C
# integer scalar -- {refined int {NAME}} with NAME a -c-abi type -- else "".
proc core::type::cabiScalar {type} {
    if {[llength $type] != 3 || [lindex $type 0] ne "refined" || [lindex $type 1] ne "int"
            || [llength [lindex $type 2]] != 1} {
        return ""
    }
    return [cabiOf [lindex $type 2 0]]
}

# 1 if NAME is a nominal refinement type (REFINEMENT-VALUES.md): declared
# `refined type NAME = CARRIER`, a member exactly when a proof says so.
proc core::type::isRefinement {name} {
    variable registry
    return [expr {[dict exists $registry $name] && [dict get $registry $name refinement] ne {}}]
}

# The refinement metadata of NAME: {carrier TYPE owner NAMESPACE ...}, the
# carrier its canonical type and the owner the exact declaring module ("" for
# the entry program) -- the one module that may mint NAME.
proc core::type::refinementOf {name} {
    return [dict get [metadata $name] refinement]
}

# The one refinement name TYPE denotes, when TYPE is exactly a nominal
# refinement type (its evidence set is one refinement and what that
# refinement's carrier already implies), else "".
proc core::type::refinementName {type} {
    if {[catch {normalize $type} type] || [lindex $type 0] ne "refined"} {
        return ""
    }
    set names [evidenceOf $type]
    foreach name $names {
        if {[isRefinement $name] && [lsort [evidenceClosure $type]] eq [lsort [evidenceClosure $name]]} {
            return $name
        }
    }
    return ""
}

# Removes a -source 1 type NAME from the registry (hir/sourcetypes.tcl's own
# per-compilation reset -- see SOURCE-DEFINED-INTEGER-DOMAINS.md's
# "Compilation isolation"). Never removes a compiler-registered (-source 0)
# type: those are process-global builtins by design, exactly as before this
# milestone, and unregistering one would be a bug in the caller, not a
# reset -- a plain Tcl error, not a semantic one.
proc core::type::unregister {name} {
    variable registry
    if {![dict exists $registry $name]} {
        return
    }
    if {![dict get $registry $name source]} {
        error "core::type::unregister: \"$name\" is not a source-defined type"
    }
    dict unset registry $name
}

proc core::type::NormalizeIntegerDomain {domain} {
    switch -- [lindex $domain 0] {
        interval {
            if {[llength $domain] != 3} { error {core::type::register: interval domain needs LO and HI} }
            lassign $domain _ lo hi
            if {![string is entier -strict $lo] || ![string is entier -strict $hi] || $lo > $hi} {
                error {core::type::register: invalid integer interval}
            }
            return [list interval $lo $hi]
        }
        exact {
            if {[llength $domain] != 2 || [lindex $domain 1] eq {}} {
                error {core::type::register: exact integer domain needs values}
            }
            foreach value [lindex $domain 1] {
                if {![string is entier -strict $value]} { error {core::type::register: exact domain contains a non-integer} }
            }
            set values [lsort -unique -command {apply {{a b} {expr {$a < $b ? -1 : ($a > $b)}}}} [lindex $domain 1]]
            return [list exact $values]
        }
        default { error {core::type::register: integer domain must be interval or exact} }
    }
}

proc core::type::IntegerDomainValidator {domain v} {
    set n [core::value::intOf $v]
    switch -- [lindex $domain 0] {
        interval { lassign $domain _ lo hi; return [expr {$n >= $lo && $n <= $hi}] }
        exact { return [expr {$n in [lindex $domain 1]}] }
    }
}

# 1 if every integer CHILD (a normalized integer domain, as
# NormalizeIntegerDomain produces) admits is also admitted by PARENT: the
# one generic domain-algebra operation hir/sourcetypes.tcl needs to verify
# "type Child = Parent in Domain" (spec items 30-34) -- reused, not
# duplicated, by every combination of interval/exact child and parent.
#
# The one non-trivial case is an interval child under a sparse exact parent
# (item 34): every integer in the child's own interval must be one of the
# parent's finitely many values. Checking that exactly means walking the
# child interval, which is a real (bounded) cost at declaration time, not
# the unbounded optimizer-precision budget of hir/range.tcl's own exact-set
# analysis (item 42-43: a different, deliberately separate limit) -- see
# maxIntervalUnderExactParent below.
proc core::type::integerDomainSubset {child parent} {
    variable maxIntervalUnderExactParent
    switch -- [lindex $parent 0] {
        interval {
            lassign $parent _ plo phi
            switch -- [lindex $child 0] {
                interval {
                    lassign $child _ clo chi
                    return [expr {$clo >= $plo && $chi <= $phi}]
                }
                exact {
                    foreach v [lindex $child 1] {
                        if {$v < $plo || $v > $phi} { return 0 }
                    }
                    return 1
                }
            }
        }
        exact {
            set members [dict create]
            foreach v [lindex $parent 1] { dict set members $v 1 }
            switch -- [lindex $child 0] {
                interval {
                    lassign $child _ clo chi
                    if {$chi - $clo + 1 > $maxIntervalUnderExactParent} {
                        error [format {core::type::integerDomainSubset: an interval child of a finite (exact-set) parent is only checked up to %d values (this milestone's own declaration-time limit -- distinct from hir/range.tcl's separate optimizer exact-set budget); %d..%d has %d} \
                            $maxIntervalUnderExactParent $clo $chi [expr {$chi - $clo + 1}]]
                    }
                    for {set v $clo} {$v <= $chi} {incr v} {
                        if {![dict exists $members $v]} { return 0 }
                    }
                    return 1
                }
                exact {
                    foreach v [lindex $child 1] {
                        if {![dict exists $members $v]} { return 0 }
                    }
                    return 1
                }
            }
        }
    }
}

namespace eval core::type {
    # Declaration-time-only bound on how large an interval child's own
    # domain may be when its parent is a sparse (exact) set: checking
    # membership of every one of its values costs O(n), so this exists to
    # keep a pathological declaration (e.g. "0..10000000000 in a 3-value
    # exact parent") a clear, immediate diagnostic instead of a compiler
    # hang. It is not a language-level maximum on any type's own domain
    # size (item 43) -- an interval or exact-set *type* may be as large as
    # it likes; only THIS specific validation shape is bounded.
    variable maxIntervalUnderExactParent 100000
}

# A human-readable rendering of a normalized integer domain, for
# diagnostics ("the domain of X is not a subset of its parent's domain ...").
proc core::type::showIntegerDomain {domain} {
    if {[lindex $domain 0] eq {interval}} {
        lassign $domain _ lo hi
        return "\[$lo, $hi\]"
    }
    return "{[join [lindex $domain 1] {, }]}"
}

proc core::type::names {} {
    variable registry
    return [dict keys $registry]
}

# 1 if NAME is a type the compiler itself knows: a primitive, `any`, or a
# compiler-registered named type (never a source-declared one, which exists
# only for the compilation that declared it).
proc core::type::isBuiltinName {name} {
    variable primitives
    variable registry
    if {$name in $primitives || $name eq "any"} {
        return 1
    }
    return [expr {[dict exists $registry $name] && ![dict get $registry $name source]}]
}

# 1 if NAME is a type declared by Botlish source (registered for the current
# compilation only).
proc core::type::isSource {name} {
    variable registry
    return [expr {[dict exists $registry $name] && [dict get $registry $name source]}]
}

proc core::type::isNamed {name} {
    variable registry
    return [dict exists $registry $name]
}

proc core::type::metadata {name} {
    variable registry
    if {![dict exists $registry $name]} {
        error "core::type: no type named \"$name\""
    }
    return [dict get $registry $name]
}

# A sound optimizer summary derived from a semantic integer domain.
proc core::type::integerFacts {type} {
    set type [normalize $type]
    if {[base $type] ne {int}} { return {} }
    set result {}
    # The closure, not only the names: a refinement of an integer domain
    # (REFINEMENT-VALUES.md) has no domain of its own and inherits its
    # carrier's (an integer domain's own parents already imply its domain,
    # so for those the closure adds nothing new).
    foreach name [evidenceClosure $type] {
        set domain [dict get [metadata $name] integerDomain]
        if {$domain eq {}} { continue }
        if {[lindex $domain 0] eq {interval}} {
            lassign $domain _ lo hi
            set facts [dict create min $lo max $hi]
        } else {
            set values [lindex $domain 1]
            set facts [dict create min [lindex $values 0] max [lindex $values end] exact $values]
        }
        if {$result eq {}} {
            set result $facts
        } else {
            set result [IntersectIntegerFacts $result $facts]
        }
    }
    return $result
}

proc core::type::IntersectIntegerFacts {a b} {
    if {[dict get $a min] > [dict get $b min]} {
        set lo [dict get $a min]
    } else {
        set lo [dict get $b min]
    }
    if {[dict get $a max] < [dict get $b max]} {
        set hi [dict get $a max]
    } else {
        set hi [dict get $b max]
    }
    set exact {}
    foreach source [list $a $b] {
        if {![dict exists $source exact]} { continue }
        set values [lmap v [dict get $source exact] {if {$v >= $lo && $v <= $hi} {set v} else continue}]
        if {$exact eq {}} {
            set exact $values
        } else {
            set exact [lmap v $exact {if {$v in $values} {set v} else continue}]
        }
    }
    set result [dict create min $lo max $hi]
    if {$exact ne {}} { dict set result exact $exact }
    return $result
}

# ---------------------------------------------------------------------------
# Type forms

# Canonical form of TYPE; raises an error for a type that is not valid.
proc core::type::normalize {type} {
    variable primitives
    if {[catch {llength $type} length]} {
        error "core::type: malformed type \"$type\""
    }
    if {$length == 1} {
        if {$type in $primitives || $type eq "any"} {
            return $type
        }
        if {[isNamed $type]} {
            return [list refined [dict get [metadata $type] base] [list $type]]
        }
        error "core::type: unknown type \"$type\""
    }
    if {$length == 3 && [lindex $type 0] eq "refined"} {
        lassign $type _ base names
        if {$base ni $primitives} {
            error "core::type: refined base must be a primitive type: \"$type\""
        }
        foreach name $names {
            if {![isNamed $name]} {
                error "core::type: unknown type \"$name\" in \"$type\""
            }
            if {[dict get [metadata $name] base] ne $base} {
                error "core::type: \"$name\" refines [dict get [metadata $name] base], not $base"
            }
        }
        return [Make $base $names]
    }
    error "core::type: malformed type \"$type\""
}

proc core::type::valid {type} {
    return [expr {![catch {normalize $type}]}]
}

proc core::type::Make {base names} {
    set names [lsort -unique $names]
    if {$names eq ""} {
        return $base
    }
    return [list refined $base $names]
}

# The primitive type every value of TYPE has, or "" for any.
proc core::type::base {type} {
    set type [normalize $type]
    switch -- [lindex $type 0] {
        any     { return "" }
        refined { return [lindex $type 1] }
        default { return $type }
    }
}

# The named types a value of TYPE is known to satisfy.
proc core::type::evidenceOf {type} {
    set type [normalize $type]
    if {[lindex $type 0] eq "refined"} {
        return [lindex $type 2]
    }
    return {}
}

proc core::type::evidenceClosure {type} {
    set work [evidenceOf $type]
    set result {}
    while {$work ne {}} {
        set work [lassign $work name]
        if {$name in $result} { continue }
        lappend result $name
        lappend work {*}[dict get [metadata $name] parents]
    }
    return $result
}

# 1 if every value of A is a value of B.
proc core::type::subtype {a b} {
    set a [normalize $a]
    set b [normalize $b]
    if {$b eq "any"} {
        return 1
    }
    if {$a eq "any" || [base $a] ne [base $b]} {
        return 0
    }
    set have [evidenceClosure $a]
    foreach name [evidenceOf $b] {
        if {$name ni $have} {
            return 0
        }
    }
    return 1
}

# Least upper bound: the most precise type containing A and B.
# Same base: the evidence both share. Different bases: any.
proc core::type::lub {a b} {
    set a [normalize $a]
    set b [normalize $b]
    if {$a eq "any" || $b eq "any" || [base $a] ne [base $b]} {
        return any
    }
    set shared {}
    set ae [evidenceClosure $a]
    set be [evidenceClosure $b]
    foreach name $ae {
        if {$name in $be} {
            lappend shared $name
        }
    }
    foreach name $shared {
        foreach other $shared {
            if {$name ne $other && $name in [evidenceClosure $other]} {
                set shared [lsearch -all -inline -not -exact $shared $name]
                break
            }
        }
    }
    return [Make [base $a] $shared]
}

# A value known to be of type CURRENT is proven to be of type FACT: the type
# describing both. Same base: the union of the evidence. A fact of a
# different base contradicts CURRENT, which can only happen on an unreachable
# path; FACT is returned.
proc core::type::narrow {current fact} {
    set current [normalize $current]
    set fact [normalize $fact]
    if {$fact eq "any"} {
        return $current
    }
    if {$current eq "any" || [base $current] ne [base $fact]} {
        return $fact
    }
    return [Make [base $fact] [concat [evidenceOf $current] [evidenceOf $fact]]]
}

proc core::type::show {type} {
    set type [normalize $type]
    if {[lindex $type 0] eq "refined"} {
        return "[lindex $type 1]\[[join [lindex $type 2] ,]\]"
    }
    return $type
}

# ---------------------------------------------------------------------------
# Values

# The type a value demonstrably has without running validators: its kind
# (a value carries no named-type information, REFINEMENT-VALUES.md).
proc core::type::ofValue {v} {
    return [core::value::kind $v]
}

# Runs NAME's validator on V (which must have NAME's base kind). Returns 1/0.
proc core::type::runValidator {name v} {
    set result [{*}[dict get [metadata $name] validator] $v]
    if {$result ni {0 1}} {
        error "core::type: validator of \"$name\" returned \"$result\", expected 0 or 1"
    }
    return $result
}

# 1 if V satisfies the named type NAME.
proc core::type::validate {name v} {
    set meta [metadata $name]
    if {[core::value::kind $v] ne [dict get $meta base]} {
        return 0
    }
    if {[dict get $meta refinement] ne {}} {
        # A refinement's proposition is a static proof fact with no runtime
        # representation (REFINEMENT-VALUES.md): a value carries no tag that
        # could say it was proven, so the runtime can check only that it is
        # a value of the carrier. Static typing is what guarantees the rest
        # (hir/types.tcl's invariant, for a refinement, is exactly this).
        foreach parent [dict get $meta parents] {
            if {![validate $parent $v]} {
                return 0
            }
        }
        return 1
    }
    return [runValidator $name $v]
}

# 1 if V is a value of TYPE.
proc core::type::acceptsValue {type v} {
    return [acceptsCanonical [normalize $type] $v]
}

proc core::type::acceptsCanonical {type v} {
    if {$type eq "any"} {
        return 1
    }
    if {[llength $type] == 1} {
        return [expr {[core::value::kind $v] eq $type}]
    }
    if {[core::value::kind $v] ne [lindex $type 1]} {
        return 0
    }
    foreach name [lindex $type 2] {
        if {![validate $name $v]} {
            return 0
        }
    }
    return 1
}

# Asserts a *contract*: trusted code (a native) promised that V has TYPE.
# A violation is an implementation bug, reported as {CORE CONTRACT TYPE}.
proc core::type::assertValue {type v context} {
    return [AssertCanonical [normalize $type] $v $context]
}

# assertValue for a TYPE already in canonical form (registries store those).
proc core::type::AssertCanonical {type v context} {
    if {![acceptsCanonical $type $v]} {
        throw [list CORE CONTRACT TYPE] \
            "$context: contract violation: expected [show $type], got [core::value::show $v 1]"
    }
    return $v
}
