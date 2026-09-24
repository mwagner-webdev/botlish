# type.tcl -- semantic value types: what it means for a value to have a type.
#
# A (checkable) type is one of:
#
#   int str bool unit list result block native
#                             every value of that kind (a *primitive* type)
#   any                       every value
#   {refined BASE {NAME...}}  values of kind BASE that satisfy every named
#                             type NAME (an *evidence set*, sorted, unique)
#
# A registered name may be written alone as shorthand: Emailish means
# {refined str {Emailish}}. normalize produces the canonical form, and all
# registries store canonical types.
#
# Named types are registered from Tcl:
#
#   core::type::register Emailish -base str -validator {core::regex::matches $re}
#   core::type::register UriQueryValue -base str -opaque 1
#
# A named integer-domain refinement ("type Byte = Int in 0..255",
# lib/byte.bot) is the one thing Botlish source itself can declare
# directly, via -integer-domain below; hir/sourcetypes.tcl turns such a
# declaration into exactly the -integer-domain register call this file
# always accepted (see SOURCE-DEFINED-INTEGER-DOMAINS.md). -source below
# marks such an entry, purely so hir/sourcetypes.tcl can unregister it
# again between compilations (core::type::unregister) -- everything else
# about it (validation, subtyping, facts) is identical to a Tcl-registered
# type.
#
# A *validator* type is structural: a command prefix, called with the value,
# decides membership (1/0). An *opaque* type has no validator: a value
# belongs to it only if it carries runtime *evidence* of the type, which only
# trusted natives attach (core::value::withEvidence). Evidence on a value of a
# validator type is an optimization; evidence of an opaque type is the only
# proof there is.
#
# The interpreter is the specification of these rules; the compiler
# (compiler/types.tcl) consumes the same definitions for its static types.

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
    variable primitives {int str bool unit list result block native mutarray UnicodeChar immutableSet}
    # Kinds whose runtime representation can carry evidence (see value.tcl).
    variable evidenceKinds {str}
    # NAME -> {name NAME base KIND validator CMD opaque 0|1}
    variable registry [dict create]
}

# ---------------------------------------------------------------------------
# Registry

proc core::type::register {name args} {
    variable primitives
    variable evidenceKinds
    variable registry
    if {![regexp {^[A-Za-z_][A-Za-z0-9_.]*$} $name]
            || $name in $primitives || $name in {any refined never}} {
        error "core::type::register: invalid type name \"$name\""
    }
    if {[dict exists $registry $name]} {
        error "core::type::register: type \"$name\" is already registered"
    }
    if {[llength $args] % 2} {
        error "core::type::register: options must be -option value pairs"
    }
    set options [dict create -base "" -validator "" -opaque 0 -source 0]
    dict set options -parents {}
    dict set options -integer-domain {}
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "core::type::register: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set base [dict get $options -base]
    set validator [dict get $options -validator]
    set opaque [dict get $options -opaque]
    set parents [dict get $options -parents]
    set integerDomain [dict get $options -integer-domain]
    set source [dict get $options -source]
    if {$base ni $primitives} {
        error "core::type::register: -base must be one of: $primitives"
    }
    if {$integerDomain ne {}} {
        if {$base ne {int} || $validator ne {} || $opaque} {
            error {core::type::register: -integer-domain requires -base int and supplies the validator}
        }
        set integerDomain [NormalizeIntegerDomain $integerDomain]
        set validator [list core::type::IntegerDomainValidator $integerDomain]
    }
    if {$opaque ni {0 1}} {
        error "core::type::register: -opaque must be 0 or 1"
    }
    if {($validator ne "") == $opaque} {
        error "core::type::register: \"$name\" needs exactly one of -validator or -opaque 1"
    }
    if {$opaque && $base ni $evidenceKinds} {
        error "core::type::register: opaque types need a base that carries evidence ($evidenceKinds)"
    }
    foreach parent $parents {
        if {![dict exists $registry $parent]} { error [format {core::type::register: unknown parent type %s} $parent] }
        if {[dict get $registry $parent base] ne $base} { error [format {core::type::register: parent %s has a different base} $parent] }
    }
    dict set registry $name [dict create name $name base $base validator $validator opaque $opaque \
        parents $parents integerDomain $integerDomain source $source]
    return $name
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

# Checked construction from an arbitrary Int: succeeds (returning the same
# Int, refined) iff the value is actually in the named type NAME's domain,
# else raises {CORE SEMANTIC RANGE} -- never masks or truncates. The one
# generic implementation behind every named refined-int type's checked
# constructor (Byte(x), a source-declared Small(x), ...): registered once
# per type name as that name's own native -impl (core/scalarbits.tcl
# formerly did this itself for its four names; hir/sourcetypes.tcl now does
# the same for a source declaration -- see item 66's "do not add a separate
# constructor implementation per declared type").
proc core::type::CheckedConstruct {typeName v} {
    core::value::expect int $v $typeName
    if {![validate $typeName $v]} {
        core::semanticError RANGE \
            "$typeName: [core::value::show $v] is not a valid $typeName"
    }
    return $v
}

# Registers NAME's checked constructor (a root native NAME(x), CheckedConstruct
# above) and membership predicate (NAME?, definePredicate) -- the two
# ordinary things every named refined int type gets, generically, whether
# NAME came from compiler registration or a source declaration.
proc core::type::declareIntConstructor {name} {
    core::native::register $name -arity 1 \
        -impl [list core::type::CheckedConstruct $name] \
        -param-types int -result-type $name -context-free 1
    definePredicate $name
}

proc core::type::names {} {
    variable registry
    return [dict keys $registry]
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
    foreach name [evidenceOf $type] {
        set domain [dict get [metadata $name] integerDomain]
        if {$domain eq {}} { continue }
        if {[lindex $domain 0] eq {interval}} {
            lassign $domain _ lo hi
            set facts [dict create min $lo max $hi]
        } else {
            set values [lindex $domain 1]
            set facts [dict create min [lindex $values 0] max [lindex $values end] exact $values]
        }
        set result [expr {$result eq {} ? $facts : [IntersectIntegerFacts $result $facts]}]
    }
    return $result
}

proc core::type::IntersectIntegerFacts {a b} {
    set lo [expr {[dict get $a min] > [dict get $b min] ? [dict get $a min] : [dict get $b min]}]
    set hi [expr {[dict get $a max] < [dict get $b max] ? [dict get $a max] : [dict get $b max]}]
    set exact {}
    foreach source [list $a $b] {
        if {![dict exists $source exact]} { continue }
        set values [lmap v [dict get $source exact] {if {$v >= $lo && $v <= $hi} {set v} else continue}]
        set exact [expr {$exact eq {} ? $values : [lmap v $exact {if {$v in $values} {set v} else continue}]}]
    }
    set result [dict create min $lo max $hi]
    if {$exact ne {}} { dict set result exact $exact }
    return $result
}

# Registers NAME? (or PREDICATE-NAME): an ordinary native predicate that
# requires a value of the type's base kind and answers whether it satisfies
# NAME. It is declared a type test of NAME (see native.tcl -tests-type), so
# it refines its argument to NAME in the true branch and compilers may
# decide it from static types.
#
# NATIVEBODY, if given, is a (block {v} BODY...) core IR node (see
# core/native.tcl's -native-body) computing the same 0/1 membership as
# NAME's -validator, in ordinary Botlish over other natives -- forwarded
# verbatim to -native-body. It is meaningful only for a *validator-backed*
# NAME: PredicateImpl's contract is core::type::validate, which for a
# validator type is "evidence, or run the validator" (never revalidate an
# opaque type -- see core::type::validate above), so NATIVEBODY must
# likewise decide membership without evidence, exactly as the validator
# does. Passing one for an opaque NAME would be wrong (it has no validator
# to reproduce: only evidence proves membership) and is not done by any
# caller today. Omitted (the default): the predicate has no -native-body,
# exactly as before -- the native (Cranelift) backend has no executable
# form of it and rejects a dynamic call, whether NAME is opaque or
# validator-backed. This is what lets validator-backed named-type
# predicates run natively in general, through the same call-site body
# substitution native/native.tcl's ExpandNativeBodies already gives any
# native (see NATIVE-EMAILISH.md): native/lower.tcl needs no named-type
# awareness at all.
proc core::type::definePredicate {name {predicateName ""} {nativeBody ""}} {
    if {$predicateName eq ""} {
        set predicateName $name?
    }
    set base [dict get [metadata $name] base]
    return [core::native::register $predicateName -arity 1 \
        -impl [list core::type::PredicateImpl $name] \
        -param-types [list $base] \
        -tests-type [list refined $base [list $name]] \
        -runtime evidence \
        -native-body $nativeBody]
}

# The runtime has already checked the base kind (a -tests-type contract).
proc core::type::PredicateImpl {name v} {
    return [core::value::bool [validate $name $v]]
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

# The type a value demonstrably has without running validators: its kind,
# refined by the evidence it carries.
proc core::type::ofValue {v} {
    return [Make [core::value::kind $v] [core::value::evidence $v]]
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
    if {[core::value::hasEvidence $v $name]} {
        return 1
    }
    if {[dict get $meta opaque]} {
        return 0
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
