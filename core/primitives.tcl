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

core::native::register +   -arity 2 -impl core::primitives::add
core::native::register -   -arity 2 -impl core::primitives::subtract
core::native::register *   -arity 2 -impl core::primitives::multiply
core::native::register <   -arity 2 -impl core::primitives::less
core::native::register <=  -arity 2 -impl core::primitives::lessEqual
core::native::register >   -arity 2 -impl core::primitives::greater
core::native::register >=  -arity 2 -impl core::primitives::greaterEqual
core::native::register ==  -arity 2 -impl core::primitives::valueEqual
core::native::register eq  -arity 2 -impl core::primitives::stringEqual
core::native::register list -arity * -impl core::primitives::makeList
