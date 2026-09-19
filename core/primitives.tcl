# primitives.tcl -- native arithmetic, comparison and equality.
#
# Integer operations use Tcl's arbitrary-precision integers. Operands are
# always canonical decimal text (guaranteed by value.tcl), so no Tcl numeric
# parsing quirks (octal, whitespace, floats) can apply.

namespace eval core::primitives {}

proc core::primitives::Ints {name args} {
    set result {}
    foreach v $args {
        lappend result [core::value::intOf [core::value::expect int $v $name]]
    }
    return $result
}

proc core::primitives::add {a b} {
    lassign [Ints + $a $b] x y
    return [core::value::int [expr {$x + $y}]]
}

proc core::primitives::subtract {a b} {
    lassign [Ints - $a $b] x y
    return [core::value::int [expr {$x - $y}]]
}

proc core::primitives::multiply {a b} {
    lassign [Ints * $a $b] x y
    return [core::value::int [expr {$x * $y}]]
}

proc core::primitives::less {a b} {
    lassign [Ints < $a $b] x y
    return [core::value::bool [expr {$x < $y}]]
}

proc core::primitives::lessEqual {a b} {
    lassign [Ints <= $a $b] x y
    return [core::value::bool [expr {$x <= $y}]]
}

proc core::primitives::greater {a b} {
    lassign [Ints > $a $b] x y
    return [core::value::bool [expr {$x > $y}]]
}

proc core::primitives::greaterEqual {a b} {
    lassign [Ints >= $a $b] x y
    return [core::value::bool [expr {$x >= $y}]]
}

# Euclidean modulo: the result always satisfies 0 <= result < |b|, regardless
# of the sign of a or b (Boute's definition), so callers normalizing an
# index (e.g. hash(key) mod capacity) never need an extra abs/max. b == 0 is
# a semantic ARITHMETIC error, not a crash or a silent default.
proc core::primitives::modulo {a b} {
    lassign [Ints mod $a $b] x y
    if {$y == 0} {
        core::semanticError ARITHMETIC "mod: division by zero"
    }
    set r [expr {$x % $y}]
    if {$r < 0} {
        set r [expr {$r + abs($y)}]
    }
    return [core::value::int $r]
}

proc core::primitives::valueEqual {a b} {
    return [core::value::bool [core::value::equal $a $b]]
}

proc core::primitives::stringEqual {a b} {
    set x [core::value::strOf [core::value::expect str $a eq]]
    set y [core::value::strOf [core::value::expect str $b eq]]
    return [core::value::bool [string equal $x $y]]
}

proc core::primitives::makeList {args} {
    return [core::value::listOf $args]
}

foreach {name impl result} {
    +  add          int
    -  subtract     int
    *  multiply     int
    <  less         bool
    <= lessEqual    bool
    >  greater      bool
    >= greaterEqual bool
} {
    core::native::register $name -arity 2 -impl core::primitives::$impl \
        -param-types {int int} -result-type $result -runtime bigint -context-free 1
}
unset name impl result

# General-purpose Euclidean modulo (see modulo above): the smallest addition
# needed on top of the existing +-*<<=>>= to let ordinary Botlish normalize
# a hash into a bucket index (hash mod capacity) -- nothing in the runtime or
# compiler knows this native's caller might be a hash table.
core::native::register mod  -arity 2 -impl core::primitives::modulo \
    -param-types {int int} -result-type int -result-range nonneg -runtime bigint -context-free 1

core::native::register ==   -arity 2 -impl core::primitives::valueEqual \
    -param-types {any any} -result-type bool -runtime structural-equality -context-free 1
core::native::register eq   -arity 2 -impl core::primitives::stringEqual \
    -param-types {str str} -result-type bool -context-free 1
core::native::register list -arity * -impl core::primitives::makeList \
    -result-type list -runtime list-alloc -result-shape elements -context-free 1
