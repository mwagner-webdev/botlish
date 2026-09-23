# tiny-leaf-pressure.tcl -- synthetic call-site-count pressure library and
# audit for tiny exact-leaf inlining (TINY-LEAF-DEFAULT-ON.md).
#
#   tclsh9.0 bench/tiny-leaf-pressure.tcl        prints the full report table
#
# This is a measurement/audit tool only: it exists to make the one obvious
# remaining code-growth risk (a tiny eligible leaf called from many exact
# sites, native/lower.tcl's LeafInlineEligible has no call-site-count term
# in its budget -- only a per-callee-body op-count budget) observable, not
# to decide a production policy. Nothing here is wired into
# LeafInlineEligible or any other production compiler state; the report
# table and the measurement procs are consumed by
# tests/native-tiny-leaf-pressure.test for pass/fail assertions and by this
# file's own -main- section for the human-readable table
# TINY-LEAF-DEFAULT-ON.md quotes.
#
# Fixture shape
# -------------
#   fn leaf(x):
#       x + 1 [+ 1 ...]                one native call per OPS
#
#   fn caller(x):
#       leaf(x + 0) + leaf(x + 1) + ... + leaf(x + (N-1))
#
#   caller(1)                          (direct-only), or
#   [caller(1), apply(leaf, 1)]        (direct + one dynamic use, DYNAMIC 1)
#
# CALLER takes its own unknown-at-compile-time parameter X (rather than
# calling leaf on N bare literals): every one of leaf's N call sites then
# operates on a genuinely distinct, runtime-unknown SSA value (x+i), so
# neither this compiler's own constant folding nor Cranelift's downstream
# one can collapse the whole expansion into a single precomputed constant
# or common subexpression -- discovered directly while building this file
# (an earlier bare-literal-argument version of this fixture measured
# *smaller* inlined code than call overhead alone would predict, because
# every leaf(i) call, i a literal, reduced to one compile-time constant).
#
# leaf's own body has two STYLEs (a second discovery while building this
# file): "chain" (x + 1 + 1 + ... + 1, the same shape
# tests/native-tiny-leaf-inline.test's own budget-boundary tests use) is,
# once inlined, a straight-line run of constant additions that Cranelift's
# own backend folds into a single add *regardless of inlining* -- so a
# "chain" 8-op leaf measures identically to a 1-op leaf at every call-site
# count (real, honest data: it is direct evidence that leaf op count alone
# does not predict duplicated-code cost, spec's own item 66 point, but not a
# useful *contrast* against the 1-op leaf on its own). "horner"
# (((x+1)*2+1)*2+1)*2+1)*2, alternating add/multiply by non-foldable
# runtize-unknown-dependent steps) resists that collapse and gives a
# genuinely differentiated 8-op data point.
# DYNAMIC 1 additionally passes leaf itself as a first-class value
# (apply(leaf, v)), which hir::specialize keeps as a *separate* generic
# instance from the direct calls' own specialized <int> instance
# (CLOSED-CALL-PARAMETER-FACTS.md's own finding: a specialized instance's
# caller set is closed by construction) -- this isolates true inline
# duplication cost from the "the callee becomes unreachable and its own
# canonical body disappears" effect a direct-only fixture also benefits
# from (spec's own fixture A/B distinction).

if {[info commands ::core::compiler::evalHir] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] compiler compiler.tcl]
}
if {[info commands ::surface::compile] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] surface surface.tcl]
}
if {[info commands ::native::evalHir] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] native native.tcl]
}

namespace eval tinyLeafPressure {
    variable callSiteCounts {1 2 4 8 16 32 64 128 256}
}

# The body expression of a leaf with OPS native calls, in STYLE "chain"
# ("x + 1 + 1 ... + 1", trivially fold-collapsible) or "horner"
# ("((x + 1) * 2 + 1) * 2 ...", alternating add/multiply, fold-resistant --
# OPS must be even for "horner", one add and one multiply per pair).
proc tinyLeafPressure::leafBody {ops {style chain}} {
    if {$style eq "horner"} {
        set expr "x"
        for {set i 0} {$i < $ops / 2} {incr i} {
            set expr "($expr + 1) * 2"
        }
        return $expr
    }
    set expr "x"
    for {set i 0} {$i < $ops} {incr i} {
        append expr " + 1"
    }
    return $expr
}

# Source text of the fixture: a leaf with OPS native calls (STYLE, above),
# called from N exact direct sites inside caller(x), plus (DYNAMIC 1) one
# further call through a first-class value.
proc tinyLeafPressure::source {ops n dynamic {style chain}} {
    set src "fn leaf(x):\n    [leafBody $ops $style]\n\n"
    append src "fn caller(x):\n"
    set terms {}
    for {set i 0} {$i < $n} {incr i} {
        lappend terms "leaf(x + $i)"
    }
    append src "    [join $terms " + "]\n"
    if {$dynamic} {
        append src "\nfn apply(g, v):\n    g(v)\n\n\[caller(1), apply(leaf, 1)\]\n"
    } else {
        append src "\ncaller(1)\n"
    }
    return $src
}

proc tinyLeafPressure::hirOf {ops n dynamic {style chain}} {
    return [surface::compile [source $ops $n $dynamic $style] t.bot -strict 0]
}

# {VALUE-ON VALUE-OFF CALLS-ON CALLS-OFF FUNCS-ON FUNCS-OFF BYTES-ON
#  BYTES-OFF CALLER-BYTES-ON CALLER-BYTES-OFF MS-ON MS-OFF}: the measured
# pressure of a leaf with OPS native calls (STYLE, see leafBody), called
# from N exact sites (DYNAMIC 1 also adds one dynamic call), inline on vs
# off.
proc tinyLeafPressure::measure {ops n dynamic {style chain}} {
    set hir [hirOf $ops $n $dynamic $style]
    set valueOn [native::evalHir $hir -tiny-leaf-inline-opt 1]
    set valueOff [native::evalHir $hir -tiny-leaf-inline-opt 0]
    set nirOn [native::nir $hir -tiny-leaf-inline-opt 1]
    set nirOff [native::nir $hir -tiny-leaf-inline-opt 0]
    set callsOn [regexp -all {= call(env)? } $nirOn]
    set callsOff [regexp -all {= call(env)? } $nirOff]
    set funcsOn [regexp -all -line {^func } $nirOn]
    set funcsOff [regexp -all -line {^func } $nirOff]
    set t0 [clock microseconds]
    set sizeOn [native::codeSize $hir -tiny-leaf-inline-opt 1]
    set t1 [clock microseconds]
    set sizeOff [native::codeSize $hir -tiny-leaf-inline-opt 0]
    set t2 [clock microseconds]
    set bytesOn [lindex $sizeOn 0]
    set bytesOff [lindex $sizeOff 0]
    # caller's own function is always the largest one (leaf itself, and
    # <program>, are tiny by comparison): a simple, robust way to isolate
    # its own size without depending on NIR function-id numbering.
    set callerBytesOn [tcl::mathfunc::max {*}[lindex $sizeOn 1]]
    set callerBytesOff [tcl::mathfunc::max {*}[lindex $sizeOff 1]]
    return [dict create \
        valueOn $valueOn valueOff $valueOff \
        callsOn $callsOn callsOff $callsOff \
        funcsOn $funcsOn funcsOff $funcsOff \
        bytesOn $bytesOn bytesOff $bytesOff \
        callerBytesOn $callerBytesOn callerBytesOff $callerBytesOff \
        usOn [expr {$t1 - $t0}] usOff [expr {$t2 - $t1}]]
}

# Candidate pressure metric (report/test only -- never consulted by
# LeafInlineEligible): leaf op count times exact inline call-site count.
proc tinyLeafPressure::expansionUnits {ops n} {
    return [expr {$ops * $n}]
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    puts "Tiny exact-leaf inlining: call-site pressure audit (TINY-LEAF-DEFAULT-ON.md)"
    puts ""
    foreach dynamic {0 1} {
        foreach {ops style label} {1 chain "1-op leaf" 8 chain "8-op leaf, chain (fold-collapsible)" 8 horner "8-op leaf, horner (fold-resistant)"} {
            puts [format "--- %s, %s ---" $label \
                [expr {$dynamic ? "direct + one dynamic use (fixture B)" : "direct call sites only (fixture A)"}]]
            puts [format "%8s %10s %14s %14s %14s %14s %14s %14s %10s" \
                sites units bytes-on bytes-off caller-on caller-off funcs-on funcs-off delta%]
            foreach n $tinyLeafPressure::callSiteCounts {
                set m [tinyLeafPressure::measure $ops $n $dynamic $style]
                if {[dict get $m valueOn] ne [dict get $m valueOff]} {
                    puts "  MISMATCH at ops=$ops style=$style n=$n dynamic=$dynamic: on=[dict get $m valueOn] off=[dict get $m valueOff]"
                }
                set bytesOn [dict get $m bytesOn]
                set bytesOff [dict get $m bytesOff]
                set delta [expr {$bytesOff != 0 ? (($bytesOn - $bytesOff) * 100.0 / $bytesOff) : 0}]
                puts [format "%8d %10d %14d %14d %14d %14d %14d %14d %9.1f%%" \
                    $n [tinyLeafPressure::expansionUnits $ops $n] \
                    $bytesOn $bytesOff \
                    [dict get $m callerBytesOn] [dict get $m callerBytesOff] \
                    [dict get $m funcsOn] [dict get $m funcsOff] $delta]
            }
            puts ""
        }
    }
}
