#!/usr/bin/env tclsh9.0
# fuzz.tcl -- differential fuzzing of trait-implementation yield inference
# (TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md).
#
#   tclsh9.0 audit/trait-implementation-yield/tools/fuzz.tcl ?-n N? ?-seed S?
#       ?-backends LIST? ?-dump 1? ?-gc-stress 0|1? ?-contexts 0|1?
#
# Each program has one trait -- an ordinary trait `Op` (witnesses: structs
# of their own modules, each implementing `op`) or a context trait `Op`
# (implementations: installed contexts of their own modules) -- and a chain
# of D functions over it (f0 performs the operation, fK calls fK-1 and adds
# K). Each implementation yields Y times (0..2, the values it sends known),
# with the zero-message protocol or, for some, its own message struct. A
# distractor may sit beside the trait: a yielding function named `op`,
# visible to the operation's method syntax.
#
# The oracle is independent of the compiler: from the generated chain alone
# it knows which implementation every call selects (the witness passed, or
# the context installed), so whether a coroutine of fD is accepted (exactly
# when the selected implementation yields), what it sends on each resume
# and what it returns, and whether a top-level call of fD is UNWRAPPED-YIELD
# (exactly when it yields). A program is generated in up to three forms --
# a coroutine of fD driven to completion, a top-level call of fD with
# another witness (ordinary traits) and, for a yielding implementation, a
# top-level call of it -- and every form must have the oracle's outcome on
# every backend, the distractor never changing it. Exits 1 on any
# disagreement.
#
# Context requirements (TRAIT-IMPLEMENTATION-CONTEXT-REQUIREMENTS-
# MILESTONE-1.md; -contexts 1, the default): each implementation may also
# need the context trait Log or Clock of the trait's module, through 0-2
# helpers of its own module ending in a call of the trait module's `logged`
# or `clocked` -- an ordinary trait's implementation is a function of the
# witness's module, a context trait's the installed context's -- and the
# program installs 0, 1 or 2 providers of each (contexts of their own
# modules). The oracle knows the selected implementation's need: with no
# provider of it the call is MISSING-CONTEXT, with two AMBIGUOUS-CONTEXT-
# IMPLEMENTATION, with one the result adds the provider's value; another
# implementation's need, or an unused provider, changes nothing. These
# choices come from a random stream of their own: -contexts 0 generates the
# yield milestone's programs exactly.
#
# Every program is compiled from scratch in a private directory (the
# application root), removed at the end.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 60 -seed 1 -backends {interp compile cranelift-generic cranelift} -dump 0 -gc-stress 0 -contexts 1]
foreach {k v} $argv {
    if {![dict exists $options $k]} { puts stderr "unknown option $k"; exit 2 }
    dict set options $k $v
}
set argv {}
if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}
unset -nocomplain ::env(BOTLISH_HIR_CACHE)
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set ::rng [dict get $options -seed]
proc rand {n} {
    set ::rng [expr {($::rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($::rng / 65536) % $n}]
}
# The context choices' stream (-contexts): apart, so the yield choices are
# the same programs with or without them.
set ::crng [expr {[dict get $options -seed] * 7919 + 17}]
proc crand {n} {
    set ::crng [expr {($::crng * 1103515245 + 12345) % 2147483648}]
    return [expr {($::crng / 65536) % $n}]
}

proc writeText {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $text
    close $f
}

# One generated program family: {kind context|ordinary depth D impls
# {{yields Y msg 0|1 base B} ...} distractor 0|1}.
#
# With -contexts 1 each implementation also has a `need` -- "", Log or
# Clock -- reached through `helpers` (0..2) functions, and the program
# `providers` {Log COUNT Clock COUNT} (0..2 each; provider j of Log has
# the value 1000 * (j + 1), of Clock 10000 * (j + 1)).
proc Generate {} {
    set kind [lindex {ordinary context} [rand 2]]
    set impls {}
    set n [expr {2 + [rand 2]}]
    for {set i 0} {$i < $n} {incr i} {
        set y [rand 3]
        lappend impls [dict create yields $y msg [expr {$y > 0 && [rand 3] == 0}] base [expr {100 * ($i + 1)}] \
            need "" helpers 0]
    }
    set p [dict create kind $kind depth [expr {1 + [rand 3]}] impls $impls distractor [rand 2] \
        providers {Log 0 Clock 0}]
    if {$::contexts} {
        dict set p impls [lmap impl [dict get $p impls] {
            dict set impl need [lindex {"" Log Clock} [crand 3]]
            dict set impl helpers [crand 3]
            set impl
        }]
        # (A provider more often than none or two.)
        dict set p providers [list Log [lindex {0 1 1 2} [crand 4]] Clock [lindex {0 1 1 2} [crand 4]]]
    }
    return $p
}

# The value the provider of context trait NEED (Log or Clock) contributes,
# provider J.
proc ProviderValue {need j} {
    return [expr {($need eq "Log" ? 1000 : 10000) * ($j + 1)}]
}

# The module text of provider J of context trait NEED.
proc ProviderModule {need j} {
    set op [expr {$need eq "Log" ? "level" : "now"}]
    return "type Base = Int in 0..100000\n\nopaque context struct P:\n    n: Base\n\nfn create() -> P:\n    P {n: [ProviderValue $need $j]}\n\nfn $op\(context p: P) -> int:\n    p.n\n"
}

# The module name of provider J of NEED.
proc ProviderName {need j} {
    return "p[string tolower $need]$j"
}

# The module text of implementation I of program P.
proc ImplModule {p i} {
    set impl [lindex [dict get $p impls] $i]
    set y [dict get $impl yields]
    set base [dict get $impl base]
    set text "type Base = Int in 0..10000\n\n"
    set need [dict get $impl need]
    if {$need ne ""} {
        # The context requirement, through HELPERS functions of this
        # module (none: the trait module's own logged or clocked).
        set text "import t\n\n$text"
        set callee [expr {$need eq "Log" ? "t::logged" : "t::clocked"}]
        for {set h 0} {$h < [dict get $impl helpers]} {incr h} {
            append text "fn need$h\() -> int:\n    $callee\()\n\n"
            set callee need$h
        }
    }
    if {[dict get $impl msg]} {
        append text "struct Msg:\n    v: int\n\n"
    }
    if {[dict get $p kind] eq "ordinary"} {
        append text "struct W:\n    n: Base\n\nfn make() -> W:\n    W {n: $base}\n\n"
        set head "fn op(w: W, x: int"
        set self w
    } else {
        append text "opaque context struct C:\n    n: Base\n\nfn create() -> C:\n    C {n: $base}\n\n"
        set head "fn op(x: int, context w: C"
    }
    if {[dict get $impl msg]} {
        append head ", resume Msg"
    }
    append text "$head) -> int:\n"
    set sum "w.n + x"
    if {$need ne ""} {
        append sum " + $callee\()"
    }
    for {set k 0} {$k < $y} {incr k} {
        if {[dict get $impl msg]} {
            append text "    m$k = yield x + $k\n"
            append sum " + m$k.v"
        } else {
            append text "    yield x + $k\n"
        }
    }
    append text "    $sum\n"
    return $text
}

# The trait module's text (the trait, the chain f0..fD-1, the distractor).
proc TraitModule {p} {
    set text ""
    if {[dict get $p distractor]} {
        append text "struct Reg:\n    slot: int\n\n"
    }
    if {$::contexts} {
        append text "context trait Log:\n    fn level() -> int\n\ncontext trait Clock:\n    fn now() -> int\n\n"
        append text "fn logged(context g: Log) -> int:\n    g.level()\n\nfn clocked(context c: Clock) -> int:\n    c.now()\n\n"
    }
    if {[dict get $p kind] eq "ordinary"} {
        append text "trait Op:\n    fn op(self: Op, x: int) -> int\n\n"
        set param "s: Op"
        set call "s.op(1)"
        set pass "s"
    } else {
        append text "context trait Op:\n    fn op(x: int) -> int\n\n"
        set param "context d: Op"
        set call "d.op(1)"
        set pass ""
    }
    if {[dict get $p distractor]} {
        # A yielding function of the operation's name, visible to its method
        # syntax: never the operation's callee.
        append text "fn op(reg: Reg, x: int) -> int:\n    yield reg.slot\n    x\n\n"
    }
    append text "fn f0($param) -> int:\n    $call\n\n"
    for {set k 1} {$k < [dict get $p depth]} {incr k} {
        append text "fn f$k\($param) -> int:\n    f[expr {$k - 1}]($pass) + $k\n\n"
    }
    return $text
}

# What the oracle expects of implementation I through the chain of P: {Y
# SENDS RESULT MSG} -- the yields, the values sent, the chain's result when
# every message is {v: 7}.
proc Expect {p i} {
    set impl [lindex [dict get $p impls] $i]
    set y [dict get $impl yields]
    set sends {}
    set result [expr {[dict get $impl base] + 1}]
    set need [dict get $impl need]
    if {$need ne "" && [dict get $p providers $need] == 1} {
        incr result [ProviderValue $need 0]
    }
    for {set k 0} {$k < $y} {incr k} {
        lappend sends [expr {1 + $k}]
        if {[dict get $impl msg]} {
            incr result 7
        }
    }
    for {set k 1} {$k < [dict get $p depth]} {incr k} {
        incr result $k
    }
    return [list $y $sends $result [dict get $impl msg]]
}

# The selection diagnostic a call of the chain with implementation I
# selected gets ({} when its need has exactly one provider, or it has none).
proc SelectionError {p i} {
    set need [dict get [lindex [dict get $p impls] $i] need]
    if {$need eq ""} {
        return {}
    }
    switch -- [dict get $p providers $need] {
        0 { return MISSING-CONTEXT }
        2 { return AMBIGUOUS-CONTEXT-IMPLEMENTATION }
    }
    return {}
}

# The entry program's prelude for P with implementation I selected (a
# context installed, for a context trait).
proc Prelude {p i} {
    set n [llength [dict get $p impls]]
    set text "import t\n"
    for {set j 0} {$j < $n} {incr j} {
        append text "import i$j\n"
    }
    foreach need {Log Clock} {
        for {set j 0} {$j < [dict get $p providers $need]} {incr j} {
            append text "import [ProviderName $need $j]\n"
        }
    }
    foreach need {Log Clock} {
        for {set j 0} {$j < [dict get $p providers $need]} {incr j} {
            append text "with context [ProviderName $need $j]::create()\n"
        }
    }
    if {[dict get $p kind] eq "context"} {
        append text "with context i$i\::create()\n"
    }
    return $text
}

proc Arg {p i} {
    if {[dict get $p kind] eq "ordinary"} {
        return "i$i\::make()"
    }
    return ""
}

# Compiles and runs SOURCE (with P's modules in a fresh application
# directory) on every backend: one outcome, or "mismatch ...".
proc Outcome {p source} {
    set dir [file tempdir botlish-implyield]
    try {
        writeText [file join $dir t.bot] [TraitModule $p]
        for {set j 0} {$j < [llength [dict get $p impls]]} {incr j} {
            writeText [file join $dir i$j.bot] [ImplModule $p $j]
        }
        foreach need {Log Clock} {
            for {set j 0} {$j < [dict get $p providers $need]} {incr j} {
                writeText [file join $dir [ProviderName $need $j].bot] [ProviderModule $need $j]
            }
        }
        writeText [file join $dir app.bot] $source
        if {[catch {surface::readProgramFile [file join $dir app.bot] -warnings off} hir options]} {
            set code [lindex [dict get $options -errorcode] end]
            if {[dict exists $options -diagnostics]} {
                set code [lmap d [dict get $options -diagnostics] {lindex [dict get $d errorcode] end}]
            }
            return [list rejected $code]
        }
        set outcomes [lsort -unique [lmap b $::backends {lrange [outcomeUnderHir $b $hir] 0 end-1}]]
        if {[llength $outcomes] != 1} {
            return [list mismatch $outcomes]
        }
        return [lindex $outcomes 0]
    } finally {
        file delete -force $dir
    }
}

set ::backends [dict get $options -backends]
set ::contexts [dict get $options -contexts]
set failures 0
set programs 0
set forms 0
set accepted 0
set needing 0
for {set run 0} {$run < [dict get $options -n]} {incr run} {
    set p [Generate]
    incr programs
    set n [llength [dict get $p impls]]
    set sel [rand $n]
    if {[dict get [lindex [dict get $p impls] $sel] need] ne ""} {
        incr needing
    }
    lassign [Expect $p $sel] y sends result msg
    set top "f[expr {[dict get $p depth] - 1}]"
    set checks {}
    # 1. A coroutine of fD with SEL selected, driven to completion.
    set resume [if {$msg} {string cat "step(i$sel\::Msg {v: 7})"} else {string cat "step()"}]
    set source [Prelude $p $sel]
    set drive "coroutine {step, first} = t::$top\([Arg $p $sel])\nrest = loop k from 0 to 4:\n    if std::coroutine::done?(step):\n        break\n    $resume\n\[\[first\], rest\]\n"
    set source "import std::coroutine\n$source$drive"
    set selection [SelectionError $p $sel]
    if {$y == 0} {
        set want [list rejected [concat $selection COROUTINE-RHS-NOT-YIELDING]]
    } elseif {$selection ne {}} {
        set want [list rejected $selection]
    } else {
        set want [list value "\[\[[lindex $sends 0]\], \[[join [concat [lrange $sends 1 end] [list $result]] {, }]\]\]"]
    }
    lappend checks coroutine $source $want
    # 2. A top-level call of fD with SEL selected.
    set source "[Prelude $p $sel]t::$top\([Arg $p $sel])\n"
    set kinds $selection
    if {$y > 0} {
        lappend kinds UNWRAPPED-YIELD
    }
    if {$kinds eq {}} {
        set want [list value $result]
    } else {
        set want [list rejected $kinds]
    }
    lappend checks top $source $want
    # 3. Ordinary traits: the coroutine with SEL and a top-level call with
    # another witness, in one program -- each specialization its own.
    if {[dict get $p kind] eq "ordinary"} {
        set o [expr {($sel + 1 + [rand [expr {$n - 1}]]) % $n}]
        lassign [Expect $p $o] yo -> resulto
        set source "import std::coroutine\n[Prelude $p $sel][string map [list {[[first], rest]} "\[\[first\], rest, t::$top\([Arg $p $o])\]"] $drive]"
        set kinds [concat $selection [SelectionError $p $o]]
        if {$yo > 0} {
            lappend kinds UNWRAPPED-YIELD
        }
        if {$y == 0} {
            lappend kinds COROUTINE-RHS-NOT-YIELDING
        }
        if {$kinds ne {}} {
            set want [list rejected $kinds]
        } else {
            set want [list value "\[\[[lindex $sends 0]\], \[[join [concat [lrange $sends 1 end] [list $result]] {, }]\], $resulto\]"]
        }
        lappend checks mixed $source $want
    }
    foreach {form source want} $checks {
        incr forms
        set got [Outcome $p $source]
        if {[lindex $want 0] eq "rejected"} {
            set ok [expr {[lindex $got 0] eq "rejected" && [lsort [lindex $got 1]] eq [lsort [lindex $want 1]]}]
        } else {
            set ok [expr {$got eq $want}]
            if {$ok} { incr accepted }
        }
        if {!$ok || [dict get $options -dump]} {
            puts "program $run ($form): [dict get $p kind], depth [dict get $p depth], selected $sel of $n, distractor [dict get $p distractor], providers [dict get $p providers]"
            puts "  impl: [ImplModule $p $sel]"
            puts "  want: $want"
            puts "  got:  $got"
        }
        if {!$ok} {
            incr failures
        }
    }
}
puts "trait-implementation-yield fuzz: seed [dict get $options -seed], contexts [dict get $options -contexts], $programs programs, $forms forms ($accepted accepted, $needing needing a context), $failures failures"
exit [expr {$failures > 0}]
