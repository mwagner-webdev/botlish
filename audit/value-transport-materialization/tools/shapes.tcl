# shapes.tcl -- generators of the probe programs shared by the audit tools and
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

proc branchy {w e {iters 200000}} {
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
    v = if i >= 100:
        fwd[expr {$e - 1}](r, i)
    else:
        r.f0 + r.f1
    drive(i + 1, n, acc + v)
drive(0, $iters, 0)
"
}
