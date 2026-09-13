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
# Named types are registered from Tcl (there is no type declaration IR yet):
#
#   core::type::register Emailish -base str -validator {core::regex::matches $re}
#   core::type::register UriQueryValue -base str -opaque 1
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
    variable primitives {int str bool unit list result block native}
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
    set options [dict create -base "" -validator "" -opaque 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "core::type::register: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set base [dict get $options -base]
    set validator [dict get $options -validator]
    set opaque [dict get $options -opaque]
    if {$base ni $primitives} {
        error "core::type::register: -base must be one of: $primitives"
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
    dict set registry $name [dict create name $name base $base validator $validator opaque $opaque]
    return $name
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

# Registers NAME? (or PREDICATE-NAME): an ordinary native predicate that
# requires a value of the type's base kind and answers whether it satisfies
# NAME. It is declared a type test of NAME (see native.tcl -tests-type), so
# it refines its argument to NAME in the true branch and compilers may
# decide it from static types.
proc core::type::definePredicate {name {predicateName ""}} {
    if {$predicateName eq ""} {
        set predicateName $name?
    }
    set base [dict get [metadata $name] base]
    return [core::native::register $predicateName -arity 1 \
        -impl [list core::type::PredicateImpl $name] \
        -param-types [list $base] \
        -tests-type [list refined $base [list $name]]]
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
    foreach name [evidenceOf $b] {
        if {$name ni [evidenceOf $a]} {
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
    foreach name [evidenceOf $a] {
        if {$name in [evidenceOf $b]} {
            lappend shared $name
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
