# fuzz.tcl -- focused fuzzer for METHOD-ELIGIBLE, the `nomethod` declaration's
# silence, and the global warning modes (WARNINGS-METHOD-ELIGIBLE.md, "Fuzzing").
#
#   tclsh9.0 audit/method-eligible/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED?
#
# Each seed generates a program of one to three functions whose calls are
# *known by construction*:
#
#   functions       f1 (1 parameter), f2 (2), f3 (3), and `nomethod fn nm` (2),
#                   plus `import str` for the intrinsic str::concat (2)
#   eligible        f2(R, 1) / f3(R, 1, 2) / str::concat(s, "x"), R a plain
#                   name or another postfix/primary form (literal, list
#                   literal, field, call result, method-call result): predicted
#                   at the call's own line and column
#   chain           f2(f2(n, 1), 2): two eligible calls
#   in a loop / a nested function: eligible, at their own locations
#   sugar           R.f2(1): written with method sugar, never warned
#   one parameter   f1(R): never warned
#   nomethod        nm(R, 1): never warned
#   dead branch     if 1 == 2: f2(R, 1): structurally unreachable, never warned
#   function value  g = f2 ; g(R, 1) and a parameter h ; h(R, 1): never warned
#   ineligible      f2(n + 1, 1), f2(-n, 1), f2(n == 1, 1), f2(not b, 1),
#   receiver        f2(b and b, 1), f2(n != 1, 1), f2((n + 1), 1): never warned
#
# No shadowing is generated (the unit tests own it). The oracle is independent
# of the compiler: it knows, from how each statement was built, which calls are
# eligible, and predicts the exact (line, column) of each warning. For every
# program it checks
#
#   default   compiles; the warnings are exactly the predicted sites (a
#             predicted site the compiler misses is a failure; an extra warning
#             is printed as EXTRA for inspection and counted, and fails only if
#             it is not a METHOD-ELIGIBLE warning)
#   off       compiles; no warning, no warning pass ran (the stats counter and
#             an execution trace), and the HIR equals the default compile's
#             HIR without its side table
#   error     rejected with {CORE SEMANTIC METHOD-ELIGIBLE} iff a warning is
#             predicted, and compiles otherwise
#   round trip  for every predicted site, the program with that one call
#             written with method sugar compiles with one warning fewer to the
#             same HIR text, core IR and NIR (specialized and generic), and --
#             for programs the interpreter can run -- the same value
#
# Exits non-zero on any failure.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 300}]
set first [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

# Receivers whose spelling is a postfix/primary expression: {FUNCTIONAL SUGARED}
# -- the receiver as an argument and as the text before a "." (the same text,
# since these forms need no parentheses).
set ::receivers {
    x n b s xs rec
    5 {"t"} {'c'} {[1, 2]} {rec.a} {f1(n)} {n.f1()} {true} {unit}
}

# A statement is {LINES SITES VARIANTS}: its lines (relative indentation 0),
# the predicted warnings {LINE-OFFSET COLUMN-OFFSET}, and for each site the
# lines of the statement with that one call written with method sugar.
# PREFIX is what precedes the call on its first line ("v3 = " or ""); the
# caller indents.

proc eligibleStatement {prefix} {
    set recv [pick $::receivers]
    switch [pick {f2 f3 f2 f3 concat}] {
        f2 {
            set functional "f2($recv, 1)"
            set sugared "$recv.f2(1)"
        }
        f3 {
            set functional "f3($recv, 1, 2)"
            set sugared "$recv.f3(1, 2)"
        }
        concat {
            set functional "str::concat(s, \"x\")"
            set sugared "s.concat(\"x\")"
        }
    }
    return [list [list "$prefix$functional"] [list [list 0 [string length $prefix]]] \
        [list [list "$prefix$sugared"]]]
}

proc chainStatement {prefix} {
    # f2(f2(n, 1), 2): outer at the prefix, inner after "f2(".
    return [list [list "${prefix}f2(f2(n, 1), 2)"] \
        [list [list 0 [string length $prefix]] [list 0 [expr {[string length $prefix] + 3}]]] \
        [list [list "${prefix}f2(n, 1).f2(2)"] [list "${prefix}f2(n.f2(1), 2)"]]]
}

# A statement that predicts nothing.
proc quiet {lines} {
    return [list $lines {} {}]
}

proc quietStatement {prefix i} {
    set recv [pick $::receivers]
    switch [pick {sugar sugar3 one onesugar nomethod alias param ops}] {
        sugar    { return [quiet [list "$prefix$recv.f2(1)"]] }
        sugar3   { return [quiet [list "$prefix$recv.f3(1, 2)"]] }
        one      { return [quiet [list "${prefix}f1($recv)"]] }
        onesugar { return [quiet [list "$prefix$recv.f1()"]] }
        nomethod { return [quiet [list "${prefix}nm($recv, 1)"]] }
        alias    { return [quiet [list "g${i} = f2" "${prefix}g${i}($recv, 1)"]] }
        param    { return [quiet [list "${prefix}h($recv, 1)"]] }
        ops {
            set op [pick {{n + 1} {-n} {n == 1} {not b} {b and b} {n != 1} {(n + 1)} {n * 2} {n - 1} {b or b}}]
            return [quiet [list "${prefix}f2($op, 1)"]]
        }
    }
}

# {LINES SITES VARIANTS} of statement number I at indentation INDENT (a
# string of spaces), absolute-position data left relative.
proc statement {i} {
    if {$::quietOnly} {
        set kind [pick {quiet quiet quiet dead}]
    } else {
        set kind [pick {eligible eligible eligible quiet quiet chain loop nested dead}]
    }
    set prefix [pick [list "" "" "v$i = "]]
    switch $kind {
        eligible { return [eligibleStatement $prefix] }
        chain    { return [chainStatement $prefix] }
        quiet    { return [quietStatement $prefix $i] }
        dead {
            set inner [quietOrEligible]
            return [quiet [list "if 1 == 2:" "    $inner"]]
        }
        loop {
            # loop e in xs: / one eligible call on the element.
            set functional "    f2(e$i, 1)"
            return [list [list "loop e$i in xs:" $functional] [list [list 1 4]] \
                [list [list "loop e$i in xs:" "    e$i.f2(1)"]]]
        }
        nested {
            # A nested function and a call to it.
            return [list [list "fn in${i}(p, q):" "    p" "${prefix}in${i}(x, 1)"] \
                [list [list 2 [string length $prefix]]] \
                [list [list "fn in${i}(p, q):" "    p" "${prefix}x.in${i}(1)"]]]
        }
    }
}

proc quietOrEligible {} {
    return "f2([pick $::receivers], 1)"
}

# {SOURCE SITES VARIANTS}: SITES the predicted {line column}, 1-based, in
# order; VARIANTS the whole program text for each site with that call written
# with method sugar.
proc generate {seed} {
    expr {srand($seed)}
    # About a third of the programs contain only calls that must stay silent.
    set ::quietOnly [expr {rand() < 0.3}]
    set lines {}
    foreach line {
        "import str"
        "fn f1(a):" "    a"
        "fn f2(a, b):" "    a"
        "fn f3(a, b, c):" "    a"
        "nomethod fn nm(a, b):" "    a"
    } {
        lappend lines $line
    }
    set sites {}
    set variants {}
    set drivers {}
    set functions [expr {1 + int(rand() * 3)}]
    for {set f 0} {$f < $functions} {incr f} {
        lappend lines "fn t${f}(x, h):"
        foreach line {"    n = 5" "    b = true" "    s = \"s\"" "    xs = \[1, 2\]" "    rec = {a: 1}"} {
            lappend lines $line
        }
        set count [expr {2 + int(rand() * 6)}]
        for {set k 0} {$k < $count} {incr k} {
            lassign [statement "${f}_$k"] stLines stSites stVariants
            set base [llength $lines]
            foreach line $stLines {
                lappend lines "    $line"
            }
            set n 0
            foreach site $stSites {
                lassign $site lineOffset columnOffset
                lappend sites [list [expr {$base + $lineOffset + 1}] [expr {5 + $columnOffset}] $base [llength $stLines] [lindex $stVariants $n]]
                incr n
            }
        }
        lappend lines "    0"
        lappend drivers "1.t${f}(f2)"
    }
    foreach line $drivers {
        lappend lines $line
    }
    set source [join $lines \n]
    # The variant program of each site: the statement's lines replaced.
    set predicted {}
    set programs {}
    foreach site $sites {
        lassign $site line column base length replacement
        lappend predicted [list $line $column]
        set copy $lines
        set new [lmap l $replacement {string cat "    " $l}]
        set copy [lreplace $copy $base [expr {$base + $length - 1}] {*}$new]
        lappend programs [join $copy \n]
    }
    return [list $source $predicted $programs]
}

proc compileMode {source mode} {
    return [surface::compile $source fuzz.bot -warnings $mode -warning-channel ""]
}

proc sitesOf {hir} {
    return [lmap w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "METHOD-ELIGIBLE"} continue
        set f [lrange [dict get $w primary] 2 end]
        list [dict get $f line] [dict get $f column]
    }]
}

proc nirOf {hir args} {
    if {[catch {native::lower::program $hir {*}$args} result options]} {
        return [list error [dict get $options -errorcode]]
    }
    return [dict get $result text]
}

# What identifies HIR as a program, computed right after its compile.
proc fingerprint {hir} {
    return [dict create format [hir::format $hir] lower [hir::lower $hir] \
        nir [nirOf $hir] nirGeneric [nirOf $hir -specialize 0]]
}

proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v]} {
        return [list error $v]
    }
    return $v
}

set failures 0
set extras 0
set warned 0
set clean 0
set roundTrips 0
set sitesTotal 0
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    lassign [generate $seed] source predicted programs
    set problems {}
    if {[catch {compileMode $source default} hir options]} {
        lappend problems "default mode did not compile: $hir"
    } else {
        set actual [sitesOf $hir]
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] ne "METHOD-ELIGIBLE"} {
                lappend problems "unexpected code [dict get $w code]"
            }
            if {[dict get $w secondary] ne ""} {
                lappend problems "METHOD-ELIGIBLE with a secondary location"
            }
        }
        foreach site $predicted {
            if {$site ni $actual} {
                lappend problems "MISSED constructed site $site (actual: $actual)"
            }
        }
        foreach site $actual {
            if {$site ni $predicted} {
                puts "EXTRA seed $seed: warning at $site is not a constructed site:\n$source"
                incr extras
            }
        }
        if {[llength $actual] != [llength [lsort -unique $actual]]} {
            lappend problems "a call site was reported twice"
        }
        set fp [fingerprint $hir]
        set value [valueOf $hir]
        # off: compiles, silently, runs no warning pass.
        hir::warnings::resetStats
        set ::passCalls 0
        trace add execution hir::warnings::MethodEligible enter {apply {{args} {incr ::passCalls}}}
        try {
            set offFailed [catch {compileMode $source off} off]
        } finally {
            trace remove execution hir::warnings::MethodEligible enter {apply {{args} {incr ::passCalls}}}
        }
        if {$offFailed} {
            lappend problems "off mode did not compile: $off"
        } elseif {[hir::warnings::of $off] ne "" || [hir::warnings::stats] ne "" || $::passCalls != 0} {
            lappend problems "off mode ran or reported warnings"
        } elseif {$off ne [dict remove $hir warnings]} {
            lappend problems "HIR differs between off and default"
        }
        # error: rejected iff a warning is predicted.
        set rejected [catch {compileMode $source error} message options]
        if {$rejected} {
            if {[dict get $options -errorcode] ne {CORE SEMANTIC METHOD-ELIGIBLE}} {
                lappend problems "error mode rejected with [dict get $options -errorcode]: $message"
            }
            if {$actual eq ""} {
                lappend problems "error mode rejected a program with no warning"
            }
        } elseif {$actual ne ""} {
            lappend problems "error mode accepted a program with warnings"
        }
        # The round-trip law, once per predicted site.
        set index 0
        foreach site $predicted {
            set variant [lindex $programs $index]
            incr index
            incr sitesTotal
            if {[catch {compileMode $variant default} sugared options]} {
                lappend problems "ROUND TRIP site $site: the sugared program does not compile: $sugared"
                continue
            }
            incr roundTrips
            set sfp [fingerprint $sugared]
            foreach key {format lower nir nirGeneric} {
                if {[dict get $fp $key] ne [dict get $sfp $key]} {
                    lappend problems "ROUND TRIP site $site: $key differs"
                }
            }
            if {[llength [sitesOf $sugared]] != [llength $actual] - 1} {
                lappend problems "ROUND TRIP site $site: [llength [sitesOf $sugared]] warnings left, expected [expr {[llength $actual] - 1}]"
            }
            if {[valueOf $sugared] ne $value} {
                lappend problems "ROUND TRIP site $site: the value differs"
            }
        }
        if {$actual eq ""} { incr clean } else { incr warned }
    }
    if {$problems ne ""} {
        incr failures
        puts "FAIL seed $seed:\n[join $problems \n]\n$source"
    }
}
puts "seeds $seeds (from $first): $warned with warnings, $clean without; failures $failures; extra warnings $extras; round trips $roundTrips of $sitesTotal predicted sites"
exit [expr {$failures > 0}]
