# transport-shapes.tcl -- generators of the probe programs shared by the audit tools and
# the tests of VALUE-TRANSPORT-MATERIALIZATION.md. Pure text generation: each
# proc returns the source of a Botlish program whose work per iteration is
# the transport of one struct value.
#
#   chainArg W E ?ITERS?     a W-field struct built by the driver crosses E
#                            exact *argument* edges (fwd{E-1} ... fwd0) and is
#                            consumed (every field) by the last callee
#   chainRet W E ?ITERS?     a W-field struct built by the bottom of a chain of
#                            E-1 exact return forwarders crosses E return edges
#                            and is consumed by the driver
#   lateFrontier W E ?ITERS? the defining probe: the driver builds a W-field
#                            struct, reads two fields locally, then forwards
#                            the struct down an E-edge argument chain
#   mixed W RETS ARGS ?ITERS?  built at the bottom of a return chain, returned
#                            to the driver, then forwarded down an argument
#                            chain
#   branchy W E ?ITERS?      one branch projects locally, the other forwards
#                            down an E-edge chain
#   nested KIND ...          the nesting probes (see the proc)
proc fieldNames {w} {
    set r {}
    for {set i 0} {$i < $w} {incr i} { lappend r f$i }
    return $r
}
proc literalOf {w base} {
    set parts {}
    for {set i 0} {$i < $w} {incr i} { lappend parts "f$i: $base + $i" }
    return "\{[join $parts {, }]\}"
}
proc sumOf {w var} { return [join [lmap f [fieldNames $w] {string cat $var . $f}] { + }] }

proc chainArg {w e {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $e} {incr k} {
        append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + fwd[expr {$e - 1}]([literalOf $w i], i))
drive(0, $iters, 0)
"
}

proc chainRet {w e {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn ret0(i):\n    [literalOf $w i]\n"
    for {set k 1} {$k < $e} {incr k} {
        append chain "fn ret${k}(i):\n    ret[expr {$k - 1}](i)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = ret[expr {$e - 1}](i)
    drive(i + 1, n, acc + $uses)
drive(0, $iters, 0)
"
}

proc lateFrontier {w e {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $e} {incr k} {
        append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = [literalOf $w i]
    local = r.f0 + r.f1
    drive(i + 1, n, acc + local + fwd[expr {$e - 1}](r, i))
drive(0, $iters, 0)
"
}

proc mixed {w rets args {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn ret0(i):\n    [literalOf $w i]\n"
    for {set k 1} {$k < $rets} {incr k} {
        append chain "fn ret${k}(i):\n    ret[expr {$k - 1}](i)\n"
    }
    append chain "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $args} {incr k} {
        append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = ret[expr {$rets - 1}](i)
    drive(i + 1, n, acc + fwd[expr {$args - 1}](r, i))
drive(0, $iters, 0)
"
}

proc branchy {w e {iters 200000} {threshold 100}} {
    set uses [sumOf $w r]
    set chain "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $e} {incr k} {
        append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = [literalOf $w i]
    v = if i >= $threshold:
        fwd[expr {$e - 1}](r, i)
    else:
        r.f0 + r.f1
    drive(i + 1, n, acc + v)
drive(0, $iters, 0)
"
}

# A struct built at a call site that is *directly* the argument of a chain
# whose own argument is the result of a return chain: the path accumulates
# return edges and argument edges without a local to materialize at.
proc mixedDirect {w rets args {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn ret0(i):\n    [literalOf $w i]\n"
    for {set k 1} {$k < $rets} {incr k} {
        append chain "fn ret${k}(i):\n    ret[expr {$k - 1}](i)\n"
    }
    append chain "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $args} {incr k} {
        append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + fwd[expr {$args - 1}](ret[expr {$rets - 1}](i), i))
drive(0, $iters, 0)
"
}

# One local forwarded down a short chain (cheap) and a long chain (expensive).
proc twoConsumers {w long {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn cheap(r, k):\n    $uses + k\nfn long0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $long} {incr k} {
        append chain "fn long${k}(r, k):\n    long[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = [literalOf $w i]
    drive(i + 1, n, acc + cheap(r, i) + long[expr {$long - 1}](r, i))
drive(0, $iters, 0)
"
}

# A local forwarded to a shared first function that then splits into a cheap
# and a long continuation.
proc sharedPrefix {w long {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn cheap(r, k):\n    $uses + k\nfn long0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $long} {incr k} {
        append chain "fn long${k}(r, k):\n    long[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn head(r, k):
    cheap(r, k) + long[expr {$long - 1}](r, k)
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = [literalOf $w i]
    drive(i + 1, n, acc + head(r, i))
drive(0, $iters, 0)
"
}

# The late-frontier shape with TWO long forwards of the same local: the one
# materialization is reused.
proc lateTwice {w e {iters 200000}} {
    set uses [sumOf $w r]
    set chain "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $e} {incr k} {
        append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = [literalOf $w i]
    local = r.f0 + r.f1
    drive(i + 1, n, acc + local + fwd[expr {$e - 1}](r, i) + fwd[expr {$e - 1}](r, i + 1))
drive(0, $iters, 0)
"
}

# A struct of W fields threaded through a self-tail loop and rebuilt at every
# step: the cyclic-transport probe.
proc selfTail {w {iters 200000}} {
    set fields [fieldNames $w]
    set uses [sumOf $w s]
    set next {}
    for {set i 0} {$i < $w} {incr i} { lappend next "f$i: s.f$i + 1" }
    return "
fn spin(s, i, n):
    if i >= n:
        return $uses
    spin(\{[join $next {, }]\}, i + 1, n)
spin([literalOf $w 0], 0, $iters)
"
}

# The nesting probes: {NAME SOURCE-LITERAL USES} -- literals nest inner
# structs; USES reads every leaf.
proc nestedProbes {} {
    return [list \
        flat4 "\{a: i, b: i + 1, c: i + 2, d: i + 3\}" {r.a + r.b + r.c + r.d} \
        inner1 "\{a: i, b: i + 1, inner: \{c: i + 2, d: i + 3\}\}" {r.a + r.b + r.inner.c + r.inner.d} \
        inner2 "\{left: \{a: i, b: i + 1\}, right: \{c: i + 2, d: i + 3\}\}" {r.left.a + r.left.b + r.right.c + r.right.d} \
        deep "\{a: i, x: \{b: i + 1, y: \{c: i + 2, d: i + 3\}\}\}" {r.a + r.x.b + r.x.y.c + r.x.y.d}]
}

# {DIRECTION {SOURCE NAMES}} programs of one nested probe: local, one return,
# one argument, and a long (6-edge) argument chain.
proc nestedPrograms {name lit uses iters} {
    set fwd "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < 6} {incr k} { append fwd "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n" }
    return [list \
        local "
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = $lit
    drive(i + 1, n, acc + $uses)
drive(0, $iters, 0)
" {drive} \
        return "
fn mk(i):
    $lit
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = mk(i)
    drive(i + 1, n, acc + $uses)
drive(0, $iters, 0)
" {mk drive} \
        argument "
fn consume_fields(r, k):
    $uses + k
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + consume_fields($lit, i))
drive(0, $iters, 0)
" {consume_fields drive} \
        long-argument "$fwd
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + fwd5($lit, i))
drive(0, $iters, 0)
" {fwd0 fwd1 fwd2 fwd3 fwd4 fwd5 drive}]
}

# A nested value (an inner struct of INNERW fields next to two scalars) built by
# the driver and forwarded down an E-edge argument chain / returned through an
# E-edge return chain, then consumed (every leaf read).
proc nestedLiteral {innerw base} {
    set parts {}
    for {set i 0} {$i < $innerw} {incr i} { lappend parts "c$i: $base + [expr {$i + 2}]" }
    return "\{a: $base, b: $base + 1, inner: \{[join $parts {, }]\}\}"
}
proc nestedUses {innerw var} {
    set parts [list $var.a $var.b]
    for {set i 0} {$i < $innerw} {incr i} { lappend parts $var.inner.c$i }
    return [join $parts { + }]
}
proc nestedChainArg {innerw e {iters 200000}} {
    set uses [nestedUses $innerw r]
    set chain "fn fwd0(r, k):\n    $uses + k\n"
    for {set k 1} {$k < $e} {incr k} {
        append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + fwd[expr {$e - 1}]([nestedLiteral $innerw i], i))
drive(0, $iters, 0)
"
}
proc nestedChainRet {innerw e {iters 200000}} {
    set uses [nestedUses $innerw r]
    set chain "fn ret0(i):\n    [nestedLiteral $innerw i]\n"
    for {set k 1} {$k < $e} {incr k} {
        append chain "fn ret${k}(i):\n    ret[expr {$k - 1}](i)\n"
    }
    return "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = ret[expr {$e - 1}](i)
    drive(i + 1, n, acc + $uses)
drive(0, $iters, 0)
"
}
