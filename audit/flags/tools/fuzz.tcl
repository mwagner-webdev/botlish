#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized differential check of flag parameters
# (FLAGS.md).
#
#   tclsh9.0 audit/flags/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1? ?-backends LIST?
#
# Each program is generated as a record of functions and a tree of calls, then
# rendered to Botlish source. The functions declare 0..4 flags (a random
# subset of a name pool, in a random declaration order) and 0..3 ordinary
# parameters; every function returns `[sum, flag...]` -- its ordinary
# arguments plus a constant, then the Bool value of each *used* flag in
# declaration order -- but its body is one of several shapes, so the flags
# are exercised in different positions:
#
#   direct      the flags in a list literal
#   ifs         each flag read through `if` (a Bool condition) into a binding
#   forward     the flags passed to an ordinary function as Bool arguments
#   struct      the flags stored in a struct value and projected back
#   closure     the flags read by a nested function that captures them
#   recursive   a depth parameter; the function calls itself with a flag set
#               rebuilt from the Bool values it received (a decision tree of
#               `if`s, each leaf writing a different permutation of the flags)
#
# plus flags declared but never read ("unused" flags: the tail of the
# declaration) and functions with no flags at all. Calls are
#
#   free        f(a, b, :x, :y)
#   method      a.f(b, :x, :y)  (receiver = first ordinary argument)
#   alias       g(...) / a.g(...) for a name bound to a function (`g = f`)
#   nested      an argument is `head(CALL)` or `CALL.head()` (head: the
#               first element via a proven list::at, STDLIB-NAMESPACES.md)
#   probed      an argument is `probe(log, ID, ARG)`, so evaluation order is
#               part of the outcome; flags contribute no event
#
# with a random subset of the callee's flags in a random written order.
#
# The oracle is a model in Tcl, independent of every backend: the value and
# the evaluation log the generator computes for the call tree. On every
# backend the program must produce exactly that, and the backends must agree.
#
# NEGATIVE programs each carry one defect and must be rejected statically with
# the one diagnostic expected of it (never silently accepted, never a generic
# parse failure where a precise diagnostic exists):
#
#   unknown-flag      a call supplies a flag the callee does not declare
#   unknown-method    the same, through method spelling
#   duplicate-flag    a call supplies one flag twice
#   duplicate-decl    a declaration lists one flag twice
#   collision         a flag named like an ordinary parameter of its function
#   ordinary-after    an ordinary argument after the call's flags
#   misplaced-flags   an ordinary parameter after the flag section
#   flag-value        a flag spelled where a value is
#   function-value    a function with flags used as a value
#   arity             the wrong number of ordinary arguments
#   unknown-callee    flags supplied to a parameter's callee
#
# Every program is seeded individually, so any failure replays with
# `-seed S -n 1 -dump 1`. The run ends with a summary line
# "flags-fuzz programs N values V negatives M oracle-disagreements D
# negative-escapes X backend-disagreements B"; the exit status is 1 if D, X or
# B is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 100
set seed0 1
set dump 0
set backends {interp compile cranelift-generic cranelift}
while {[lindex $args 0] in {-n -seed -dump -backends}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }
proc shuffle {list} {
    set result {}
    while {[llength $list]} {
        set i [expr {int(rand() * [llength $list])}]
        lappend result [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $result
}

set ::flagPool {quiet flush strict trace append creat sync verbose dry}
set ::variants {direct ifs forward struct closure recursive}

# ---------------------------------------------------------------------------
# Functions
#
# A function is a dict: name, ordinary (parameter names, including the depth
# parameter `d` of a recursive function, which is first), flags (declaration
# order), used (how many leading flags the result reports), variant, k.

proc genFunction {index} {
    set flags [lrange [shuffle $::flagPool] 0 [expr {[rnd 0 4] - 1}]]
    if {[chance 0.15]} {
        set flags {}
    }
    set variant [pick $::variants]
    set used [llength $flags]
    if {$used > 0 && [chance 0.3]} {
        set used [rnd 0 $used]
    }
    if {$variant eq "recursive" && ([llength $flags] > 3 || $used == 0)} {
        set variant direct
    }
    set ordinary [lrange {p0 p1 p2} 0 [expr {[rnd 0 3] - 1}]]
    if {$variant eq "recursive"} {
        set ordinary [linsert $ordinary 0 d]
    }
    return [dict create name f$index ordinary $ordinary flags $flags used $used \
        variant $variant k [rnd 0 9]]
}

# The Botlish source of function F, and of its helpers.
proc renderFunction {f mutation} {
    set name [dict get $f name]
    set ordinary [dict get $f ordinary]
    set flags [dict get $f flags]
    set used [lrange $flags 0 [expr {[dict get $f used] - 1}]]
    set k [dict get $f k]
    set values [lrange $ordinary [expr {[dict get $f variant] eq "recursive"}] end]
    set sum [join [concat $values $k] { + }]
    set params [join $ordinary {, }]
    set flagList [lmap x $flags {string cat : $x}]
    set declFlags $flags
    if {[dict exists $mutation function] && [dict get $mutation function] eq $name} {
        switch -- [dict get $mutation kind] {
            duplicate-decl { set declFlags [linsert $declFlags 1 [lindex $flags 0]] }
            collision { set declFlags [linsert $declFlags 0 [lindex $ordinary 0]] }
            misplaced-flags {
                set tail "flags [join [lmap x $flags {string cat : $x}] {, }], zz"
                set head [join $ordinary {, }]
                return "fn ${name}($tail):\n    $k\n"
            }
        }
    }
    set header "fn ${name}("
    set parts {}
    if {$params ne ""} { lappend parts $params }
    if {$declFlags ne {}} { lappend parts "flags [join [lmap x $declFlags {string cat : $x}] {, }]" }
    append header [join $parts {, }] "):\n"
    set results [concat [list $sum] $used]
    switch -- [dict get $f variant] {
        direct {
            append header "    \[[join $results {, }]\]\n"
        }
        ifs {
            set names {}
            foreach x $used {
                append header "    v_$x = if $x:\n        true\n    else:\n        false\n"
                lappend names v_$x
            }
            append header "    \[[join [concat [list $sum] $names] {, }]\]\n"
        }
        forward {
            append header "    fwd[llength $used]([join $results {, }])\n"
        }
        struct {
            set fields [list "s: $sum"]
            set reads [list st.s]
            set i 0
            foreach x $used {
                lappend fields "b$i: $x"
                lappend reads st.b$i
                incr i
            }
            append header "    st = {[join $fields {, }]}\n    \[[join $reads {, }]\]\n"
        }
        closure {
            append header "    fn inner():\n        \[[join $results {, }]\]\n    inner()\n"
        }
        recursive {
            append header "    if d == 0:\n        return \[[join $results {, }]\]\n"
            append header [recursiveTree $name $ordinary $used 0 {} "    "]
        }
    }
    return $header
}

# The decision tree of a recursive function: for each used flag in turn, an
# `if` on its Bool value; at a leaf, the call of the function itself with
# exactly the flags that were true, written in a random order.
proc recursiveTree {name ordinary used index trueFlags indent} {
    if {$index == [llength $used]} {
        set args [concat [list "d - 1"] [lrange $ordinary 1 end]]
        set text "${indent}return ${name}([join [concat $args [lmap x [shuffle $trueFlags] {string cat : $x}]] {, }])\n"
        return $text
    }
    set x [lindex $used $index]
    set text "${indent}if $x:\n"
    append text [recursiveTree $name $ordinary $used [expr {$index + 1}] [concat $trueFlags $x] "$indent    "]
    append text "${indent}else:\n"
    append text [recursiveTree $name $ordinary $used [expr {$index + 1}] $trueFlags "$indent    "]
    return $text
}

# ---------------------------------------------------------------------------
# Calls: a tree. A call node is {fn F alias A method M args {ARG...} flags
# {NAME...}}; an ARG is {int V}, {probe ID ARG}, or {call NODE VIA} (VIA: free
# or method: the value is element 0 of the call's list).

set ::probeId 0
proc nextProbe {} {
    return [expr {[incr ::probeId] % 9 + 1}]
}

proc genCall {depth} {
    set f [pick $::functions]
    set ordinary [dict get $f ordinary]
    set args {}
    foreach p $ordinary {
        if {$p eq "d"} {
            lappend args [list int [rnd 0 3]]
        } else {
            lappend args [genArg $depth]
        }
    }
    set flags [dict get $f flags]
    set supplied {}
    foreach x $flags {
        if {[chance 0.5]} { lappend supplied $x }
    }
    set alias ""
    if {[dict exists $::aliases [dict get $f name]] && [chance 0.6]} {
        set alias [dict get $::aliases [dict get $f name]]
    }
    return [dict create fn $f alias $alias method [expr {[llength $args] > 0 && [chance 0.5]}] \
        args $args flags [shuffle $supplied]]
}

proc genArg {depth} {
    set r [expr {rand()}]
    if {$depth > 0 && $r < 0.35} {
        return [list call [genCall [expr {$depth - 1}]] [pick {free method}]]
    }
    if {$r < 0.55} {
        return [list probe [nextProbe] [list int [rnd 0 9]]]
    }
    return [list int [rnd 0 9]]
}

# Source text of ARG / CALL, with MUTATION applied where it targets the call.
proc renderArg {arg mutation} {
    switch -- [lindex $arg 0] {
        int { return [lindex $arg 1] }
        probe { return "probe(log, [lindex $arg 1], [renderArg [lindex $arg 2] $mutation])" }
        call {
            set text [renderCall [lindex $arg 1] $mutation]
            if {[lindex $arg 2] eq "method"} {
                return "$text.head()"
            }
            return "head($text)"
        }
    }
}

proc renderCall {call mutation} {
    set f [dict get $call fn]
    set name [expr {[dict get $call alias] ne "" ? [dict get $call alias] : [dict get $f name]}]
    set args [lmap a [dict get $call args] {renderArg $a $mutation}]
    set flags [lmap x [dict get $call flags] {string cat : $x}]
    if {[dict exists $mutation call] && [dict get $mutation call] eq [dict get $call id]} {
        switch -- [dict get $mutation kind] {
            unknown-flag - unknown-method { lappend flags :zzz }
            duplicate-flag { lappend flags [lindex $flags 0] }
            ordinary-after { lappend flags 7 }
            arity { lappend args 7 }
        }
    }
    if {[dict get $call method] && [llength $args] > 0} {
        return "([lindex $args 0]).${name}([join [concat [lrange $args 1 end] $flags] {, }])"
    }
    return "${name}([join [concat $args $flags] {, }])"
}

# The oracle: {VALUE LOG-DIGITS} of CALL; VALUE is the shown list.
proc evalArg {arg logVar} {
    upvar 1 $logVar log
    switch -- [lindex $arg 0] {
        int { return [lindex $arg 1] }
        probe {
            set v [evalArg [lindex $arg 2] log]
            set log [expr {$log * 10 + [lindex $arg 1]}]
            return $v
        }
        call { return [lindex [evalCall [lindex $arg 1] log] 0] }
    }
}

proc evalCall {call logVar} {
    upvar 1 $logVar log
    set f [dict get $call fn]
    set values {}
    foreach a [dict get $call args] p [dict get $f ordinary] {
        set v [evalArg $a log]
        if {$p ne "d"} { lappend values $v }
    }
    set sum [dict get $f k]
    foreach v $values { incr sum $v }
    set result [list $sum]
    foreach x [lrange [dict get $f flags] 0 [expr {[dict get $f used] - 1}]] {
        lappend result [expr {$x in [dict get $call flags] ? "true" : "false"}]
    }
    return $result
}

proc show {result} {
    return "\[[join $result {, }]\]"
}

# ---------------------------------------------------------------------------
# Programs

# CALL with a unique `id` on it and on every call nested in its arguments.
proc indexCall {call counterVar} {
    upvar 1 $counterVar counter
    dict set call id [incr counter]
    set args {}
    foreach a [dict get $call args] {
        if {[lindex $a 0] eq "call"} {
            lset a 1 [indexCall [lindex $a 1] counter]
        }
        lappend args $a
    }
    dict set call args $args
    return $call
}

proc renderProgram {functions calls mutation} {
    set text "fn current(log):\n    if mutable_array::capacity(log) == 1:\n        return mutable_array::at(log, 0)\n    -1\n"
    append text "fn probe(log, id, result):\n    if mutable_array::capacity(log) == 1:\n        mutable_array::set(log, 0, current(log) * 10 + id)\n    result\n"
    append text "fn head(xs):\n    loop i from 0 to list::length(xs):\n        return list::at(xs, i)\n    0\n"
    append text "fn fresh():\n    log = mutable_array::allocate(1)\n    mutable_array::set(log, 0, 0)\n    log\n"
    for {set i 0} {$i <= 4} {incr i} {
        set ps [lmap j [lseq $i] {string cat a $j}]
        append text "fn fwd${i}([join [concat s $ps] {, }]):\n    \[[join [concat s $ps] {, }]\]\n"
    }
    foreach f $functions {
        append text [renderFunction $f $mutation]
    }
    dict for {name alias} $::aliases {
        append text "$alias = $name\n"
    }
    append text "log = fresh()\n"
    set results {}
    set i 0
    foreach call $calls {
        incr i
        append text "r$i = [renderCall $call $mutation]\n"
        lappend results r$i
    }
    if {[dict exists $mutation extra]} {
        append text "[dict get $mutation extra]\n"
    }
    append text "\[[join [concat $results [list "current(log)"]] {, }]\]"
    return $text
}

proc stripLocations {message} {
    return [regsub -all {[^ ]*\.bot:[0-9]+:[0-9]+} $message {t.bot:L:C}]
}

proc compileOrError {source} {
    if {[catch {surface::compile $source t.bot} hir options]} {
        return [list error [dict get $options -errorcode] [stripLocations $hir]]
    }
    return [list ok $hir]
}

# The kind of a static rejection: the syntax diagnostic's code, or the
# semantic error's kind.
proc rejectionKind {outcome} {
    set code [lindex $outcome 1]
    if {[lrange $code 0 1] eq "SURFACE SYNTAX"} {
        set d [lindex $code 2]
        return [expr {[dict exists $d code] ? [dict get $d code] : "-"}]
    }
    return [lindex $code end]
}

proc outcomeOn {backend hir} {
    set outcome [outcomeUnderHir $backend $hir]
    if {[lindex $outcome 0] eq "error"} {
        lset outcome 2 [stripLocations [lindex $outcome 2]]
    }
    return $outcome
}

# A program with exactly one defect of KIND, or "" when this program has
# nothing the defect can attach to.
proc negative {kind calls} {
    set flagged [lmap f $::functions {expr {[llength [dict get $f flags]] > 0 ? $f : [continue]}}]
    set ordinaryFns [lmap f $::functions {expr {[llength [dict get $f ordinary]] > 0 ? $f : [continue]}}]
    set mut [dict create kind $kind]
    switch -- $kind {
        unknown-flag - unknown-method - duplicate-flag - ordinary-after - arity {
            # A top-level call of a function that fits the defect.
            set candidates {}
            foreach call $calls {
                set f [dict get $call fn]
                switch -- $kind {
                    unknown-flag { set ok 1 }
                    unknown-method { set ok [dict get $call method] }
                    duplicate-flag { set ok [expr {[llength [dict get $call flags]] > 0}] }
                    ordinary-after { set ok [expr {[llength [dict get $call flags]] > 0}] }
                    arity { set ok [expr {[llength [dict get $f flags]] > 0}] }
                }
                if {$ok} { lappend candidates $call }
            }
            if {$candidates eq {}} { return "" }
            set call [lindex $candidates 0]
            dict set mut call [dict get $call id]
            set source [renderProgram $::functions $calls $mut]
            return [list $source]
        }
        duplicate-decl - misplaced-flags {
            if {$flagged eq {}} { return "" }
            dict set mut function [dict get [lindex $flagged 0] name]
            return [list [renderProgram $::functions $calls $mut]]
        }
        collision {
            set both {}
            foreach f $flagged {
                if {[dict get $f ordinary] ne {}} { lappend both $f }
            }
            if {$both eq {}} { return "" }
            dict set mut function [dict get [lindex $both 0] name]
            return [list [renderProgram $::functions $calls $mut]]
        }
        flag-value {
            dict set mut extra "bad = :quiet"
            return [list [renderProgram $::functions $calls $mut]]
        }
        function-value {
            if {$flagged eq {}} { return "" }
            dict set mut extra "bad = \[[dict get [lindex $flagged 0] name]\]"
            return [list [renderProgram $::functions $calls $mut]]
        }
        unknown-callee {
            dict set mut extra "fn inc(a):\n    a + 1\nfn apply(cb):\n    cb(1, :quiet)\napply(inc)"
            return [list [renderProgram $::functions $calls $mut]]
        }
    }
    return ""
}

set programs 0
set values 0
set negatives 0
set oracleDisagreements 0
set negativeEscapes 0
set backendDisagreements 0
set coverage [dict create free 0 method 0 alias 0 flagsSupplied 0 variants {}]

set negativeKinds {unknown-flag unknown-method duplicate-flag duplicate-decl collision ordinary-after
    misplaced-flags flag-value function-value arity unknown-callee}
set expectedKind {
    unknown-flag UNKNOWN-FLAG unknown-method UNKNOWN-FLAG duplicate-flag DUPLICATE-FLAG
    duplicate-decl DUPLICATE-FLAG-DECLARATION collision FLAG-BINDING-COLLISION
    ordinary-after ARGUMENT-AFTER-FLAG misplaced-flags MALFORMED-FLAG-SECTION
    flag-value FLAG-NOT-A-VALUE function-value FLAG-FUNCTION-VALUE arity ARITY
    unknown-callee FLAG-CALLEE-UNKNOWN
}

for {set k 0} {$k < $n} {incr k} {
    set seed [expr {$seed0 + $k}]
    expr {srand($seed)}
    set ::probeId 0
    set ::functions {}
    set count [rnd 3 6]
    for {set i 0} {$i < $count} {incr i} {
        lappend ::functions [genFunction $i]
    }
    set ::aliases [dict create]
    foreach f $::functions {
        if {[chance 0.3]} {
            dict set ::aliases [dict get $f name] "g[string range [dict get $f name] 1 end]"
        }
    }
    set calls {}
    set counter 0
    for {set i 0} {$i < [rnd 2 5]} {incr i} {
        lappend calls [indexCall [genCall 2] counter]
    }
    set source [renderProgram $::functions $calls {}]
    incr programs
    if {$dump} {
        puts "---- seed $seed\n$source"
    }

    # Oracle.
    set log 0
    set expectedValues {}
    foreach call $calls {
        lappend expectedValues [show [evalCall $call log]]
    }
    set expected [show [concat $expectedValues $log]]
    foreach call $calls {
        dict incr coverage [expr {[dict get $call method] ? "method" : "free"}]
        if {[dict get $call alias] ne ""} { dict incr coverage alias }
        dict incr coverage flagsSupplied [llength [dict get $call flags]]
    }
    foreach f $::functions {
        dict lappend coverage variants [dict get $f variant]
    }

    set compiled [compileOrError $source]
    if {[lindex $compiled 0] eq "error"} {
        incr oracleDisagreements
        puts "ORACLE DISAGREEMENT seed $seed: a valid program was rejected: [string range [lindex $compiled 2] 0 300]"
        continue
    }
    set outcomes [lmap b $backends {outcomeOn $b [lindex $compiled 1]}]
    if {[llength [lsort -unique $outcomes]] > 1} {
        incr backendDisagreements
        puts "BACKEND DISAGREEMENT seed $seed"
        foreach b $backends o $outcomes {
            puts "  $b: [string range $o 0 300]"
        }
    }
    set first [lindex $outcomes 0]
    if {[lindex $first 0] ne "value" || [lindex $first 1] ne $expected} {
        incr oracleDisagreements
        puts "ORACLE DISAGREEMENT seed $seed: expected $expected, got [string range $first 0 300]"
    } else {
        incr values
    }

    # One negative program per generated program.
    set kind [lindex $negativeKinds [expr {$k % [llength $negativeKinds]}]]
    set negSource [lindex [negative $kind $calls] 0]
    if {$negSource eq ""} {
        continue
    }
    incr negatives
    set neg [compileOrError $negSource]
    set escape ""
    if {[lindex $neg 0] eq "ok"} {
        set escape "accepted a $kind defect"
    } elseif {[rejectionKind $neg] ne [dict get $expectedKind $kind]} {
        set escape "rejected a $kind defect as [rejectionKind $neg] instead of [dict get $expectedKind $kind]: [string range [lindex $neg 2] 0 200]"
    }
    if {$escape ne ""} {
        incr negativeEscapes
        puts "NEGATIVE ESCAPE seed $seed ($kind): $escape"
        if {$dump} { puts $negSource }
    }
}

puts "flags-fuzz-coverage free [dict get $coverage free] method [dict get $coverage method] alias [dict get $coverage alias] flags-supplied [dict get $coverage flagsSupplied] variants [lsort -unique [dict get $coverage variants]]"
puts "flags-fuzz programs $programs values $values negatives $negatives oracle-disagreements $oracleDisagreements negative-escapes $negativeEscapes backend-disagreements $backendDisagreements"
exit [expr {$oracleDisagreements || $negativeEscapes || $backendDisagreements ? 1 : 0}]
