# fuzz.tcl -- focused fuzzer for SAME-FAILURE and the global warning modes
# (WARNINGS-SAME-FAILURE.md, "Fuzzing").
#
#   tclsh9.0 audit/same-failure/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED?
#   tclsh9.0 audit/same-failure/tools/fuzz.tcl -show SEED
#     (prints the program SEED generates and its prediction)
#
# Each seed generates a program of one to three functions g0..g2 (parameters
# x, a, xs) whose fail exits are *known by construction*. The program declares
# three failures with deliberately similar names (Bad, Bad2, Other) and one
# single-fail helper per failure (raise_N, silent itself). A function declares
# one or two of them and is a sequence of pieces, then a final statement:
#
#   exits       a guard `if x == K: fail N`; an elif pair `if x == K1: fail N`
#               / `elif x == K2: fail M`; a fail inside `loop y in xs` and
#               inside `loop i from 0 to x`; a fail inside an on-handler body
#               (`rJ = raise_M(x):` / `on M: fail N`, a re-raise when M is N);
#               a final `fail N`
#   not exits   a return (a unique constant or `x + C`, so no return value can
#               repeat and SAME-RETURN-VALUE never fires); a fail under a
#               statically false branch (`if 1 == 2`); a range-unreachable fail
#               (`if x < 0:` / `if x > 5:`); a propagating call of a failing
#               function (`rJ = raise_N(x)`, a final bare `raise_N(x)`, a call
#               of the nested function); the final value `x + C`
#   nested      a nested function (sometimes a closure over x) with its own
#               fails of one of the enclosing function's failures: predicted on
#               its own, never grouped with the enclosing function's fails
#
# Every third seed is *namespaced*: the program imports module sfm (written
# to a private copy of the library), whose `error Bad` is the identity
# sfm::Bad beside the program's own Bad -- the same short name, another
# failure. Functions may declare and raise both; the oracle groups by the
# exact name written (Bad, sfm::Bad), so it predicts they never group
# (ERROR-PAYLOADS.md, "Module-qualified error identity").
#
# Each failure is raised from 1 to 4 reachable exits of a function. About a
# third of the programs contain only silent functions (no failure raised from
# two reachable exits of one function). Every call is written so that no other
# warning code can fire (method syntax for the generated functions; one-
# parameter helpers; no list-literal exits), with one exception the oracle
# predicts too: the drivers' argument `"s"`, the generator's only one-character
# String literal, is a ONE-CHAR-STRING-LITERAL finding wherever it is written
# (WARNINGS-ONE-CHAR-STRING-LITERAL.md; its sites are construction-known). Any
# other code is a failure.
#
# The oracle is independent of the compiler: per function, it groups the
# reachable fail sites it constructed by declared name and predicts, for each
# name raised from two or more of them, one warning {LINE COL NOTES FAILURE
# FUNCTION EXITS} -- anchored at the first site in source order, the others as
# notes. For every program it checks
#
#   default   compiles; the SAME-FAILURE warnings are exactly the predicted
#             groups (a missed or mislocated prediction is a failure; an
#             unpredicted warning is printed as EXTRA and counted, and the
#             summary must show 0; a group reported twice is a failure)
#   off       compiles; no warning, no pass ran (stats counter, execution trace
#             on the pass), and the HIR equals default's without its side table
#   error     rejected iff a warning of either code is predicted, with the code
#             of the predicted warning that sorts first (source order:
#             {CORE SEMANTIC SAME-FAILURE} when a group is predicted, since the
#             drivers follow every function); compiles otherwise
#
# There is no conversion law: no mechanical rewrite exists for this warning's
# response space (merging conditions and splitting a failure are semantic
# edits). The driver calls every generated function twice per guard value,
# with arguments of two types, so each has several semantic instances (none
# of which may be reported on its own).
#
# Exits non-zero on any failure.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]

set show ""
if {[lindex $argv 0] eq "-show"} {
    set show [lindex $argv 1]
    set argv {}
}
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 300}]
set first [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

set ::failureNames {Bad Bad2 Other}
# The failures of the program being generated (generate).
set ::names $::failureNames

# A private copy of the library holding module sfm, removed at exit.
set ::fuzzLib [file tempdir same-failure-fuzz-lib]
foreach entry [glob -directory $::core::libraryDir *] {
    file copy $entry $::fuzzLib
}
set ::core::libraryDir $::fuzzLib
set channel [open [file join $::fuzzLib sfm.bot] w]
puts -nonewline $channel "error Bad\n\nfn id(x):\n    x\n"
close $channel
unset channel

# The helper suffix of failure N: its name with "::" spelled "_".
proc helper {n} {
    return [string map {:: _} $n]
}

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc chance {p} {
    return [expr {rand() < $p}]
}

proc census {key {n 1}} {
    dict incr ::census $key $n
}

# A failure of DECLARED that may still be raised from one more reachable exit
# of the function (COUNTS: name -> sites so far): at most one per name in a
# quiet function, at most four otherwise. "" if none may.
proc nextName {declared countsVar quiet} {
    upvar 1 $countsVar counts
    set limit [expr {$quiet ? 1 : 4}]
    set open [lmap n $declared {
        if {[dict exists $counts $n] && [dict get $counts $n] >= $limit} continue
        set n
    }]
    if {$open eq ""} {
        return ""
    }
    # Prefer repeating a name already raised (groups are the point), then a
    # fresh one.
    set raised [lmap n $open {if {![dict exists $counts $n]} continue; set n}]
    if {$raised ne "" && !$quiet && [chance 0.6]} {
        return [pick $raised]
    }
    return [pick $open]
}

# Generates function F. Returns a dict: lines (body text lines, header
# first), sites ({INDEX COL NAME} of each reachable fail, INDEX into lines),
# nested ({FUNCTION SITES} of each nested function), declared, completes (1 if
# a call can complete normally whatever x is not).
proc genFunction {f quiet} {
    set want [expr {[chance 0.6] ? 1 : 2}]
    set declared {}
    while {[llength $declared] < $want} {
        set n [pick $::names]
        if {$n ni $declared} {
            lappend declared $n
        }
    }
    set declared [lsort $declared]
    set body {}
    set sites {}
    set nested {}
    set counts [dict create]
    set constant 100
    set bindings 0
    set hasReturn 0
    set pieces [expr {1 + int(rand() * 6)}]
    for {set k 0} {$k < $pieces} {incr k} {
        set kind [pick {guard guard guard elif return return dead range loop countloop handler propagate nested}]
        if {$kind in {guard elif loop countloop handler}} {
            set n [nextName $declared counts $quiet]
            if {$n eq ""} {
                set kind [pick {return dead range propagate}]
            } else {
                dict incr counts $n
            }
        }
        set K [expr {1 + int(rand() * 7)}]
        switch -- $kind {
            guard {
                lappend body "    if x == $K:" "        fail $n"
                lappend sites [list [expr {[llength $body] - 1}] 9 $n]
                census guard
            }
            elif {
                lappend body "    if x == $K:" "        fail $n"
                lappend sites [list [expr {[llength $body] - 1}] 9 $n]
                set m [nextName $declared counts $quiet]
                set K2 [expr {$K % 7 + 1}]
                if {$m eq ""} {
                    lappend body "    elif x == $K2:" "        return [incr constant]"
                } else {
                    dict incr counts $m
                    lappend body "    elif x == $K2:" "        fail $m"
                    lappend sites [list [expr {[llength $body] - 1}] 9 $m]
                }
                census elif
            }
            return {
                set K [expr {1 + int(rand() * 4)}]
                lappend body "    if x == $K:" "        return [pick [list [incr constant] "x + [incr constant]"]]"
                set hasReturn 1
                census return
            }
            dead {
                lappend body "    if 1 == 2:" "        fail [pick $declared]"
                census dead
            }
            range {
                lappend body "    if x < 0:" "        if x > 5:" "            fail [pick $declared]"
                census range
            }
            loop {
                lappend body "    loop y in xs:" "        if y == $K:" "            fail $n"
                lappend sites [list [expr {[llength $body] - 1}] 13 $n]
                census loop
            }
            countloop {
                lappend body "    loop i from 0 to x:" "        if i == $K:" "            fail $n"
                lappend sites [list [expr {[llength $body] - 1}] 13 $n]
                census countloop
            }
            handler {
                # A handler of one of the program's failures whose body raises
                # N: a re-raise when it handles N itself.
                set m [expr {[chance 0.5] ? $n : [pick $::names]}]
                lappend body "    r[incr bindings] = raise_[helper $m]\(x):" "        on $m:" "            fail $n"
                lappend sites [list [expr {[llength $body] - 1}] 13 $n]
                census [expr {$m eq $n ? "reraise" : "handler"}]
            }
            propagate {
                lappend body "    r[incr bindings] = raise_[helper [pick $declared]](x)"
                census propagate
            }
            nested {
                # Its own fails of one name, predicted on its own; one in a
                # quiet program. Sometimes a closure over x, and sometimes
                # called (a propagating call, never an exit here).
                set name inner$f$k
                set n [pick $declared]
                set own [expr {$quiet ? 1 : 1 + int(rand() * 3)}]
                set start [llength $body]
                lappend body "    fn $name\(y) errors $n:"
                set innerSites {}
                for {set j 0} {$j < $own} {incr j} {
                    set test [expr {[chance 0.3] ? "y == x + $j" : "y == [expr {$j + 1}]"}]
                    lappend body "        if $test:" "            fail $n"
                    lappend innerSites [list [expr {[llength $body] - 1}] 13 $n]
                }
                if {[chance 0.3]} {
                    lappend body "        if 1 == 2:" "            fail $n"
                }
                lappend body "        y"
                lappend nested [list $name $innerSites]
                if {[chance 0.5]} {
                    lappend body "    r[incr bindings] = $name\(x)"
                    census propagate
                }
                census nested
            }
        }
    }
    # The final statement.
    set finalKind [pick {value value value fail barecall}]
    if {$finalKind eq "fail"} {
        set n [nextName $declared counts $quiet]
        if {$n eq ""} {
            set finalKind value
        }
    }
    switch -- $finalKind {
        value {
            lappend body "    x + [incr constant]"
        }
        fail {
            # A function whose every path fails could never complete, and a
            # call of it would be a statically known failure: give it a
            # return first.
            if {!$hasReturn} {
                lappend body "    if x == 1:" "        return [incr constant]"
                census return
            }
            dict incr counts $n
            lappend body "    fail $n"
            lappend sites [list [expr {[llength $body] - 1}] 5 $n]
            census finalfail
        }
        barecall {
            lappend body "    raise_[helper [pick $declared]](x)"
            census barecall
        }
    }
    set header "fn g$f\(x, a, xs) errors [join $declared {, }]:"
    set lines [concat [list $header] $body]
    # Indexes shift by the header line.
    set sites [lmap s $sites {lset s 0 [expr {[lindex $s 0] + 1}]; set s}]
    set nested [lmap n $nested {
        list [lindex $n 0] [lmap s [lindex $n 1] {lset s 0 [expr {[lindex $s 0] + 1}]; set s}]
    }]
    census functions
    census sites [llength $sites]
    return [dict create lines $lines sites $sites nested $nested declared $declared]
}

# The oracle: {LINE COL NOTES FAILURE FUNCTION EXITS} for each failure FUNCTION
# raises from two or more of SITES (line indexes absolute from BASE).
proc predict {function sites base} {
    set groups [dict create]
    foreach site $sites {
        lassign $site index col name
        dict lappend groups $name [list [expr {$base + $index + 1}] $col]
    }
    set result {}
    dict for {name located} $groups {
        if {[llength $located] >= 2} {
            lappend result [list {*}[lindex $located 0] [lrange $located 1 end] $name $function [llength $located]]
        }
    }
    return $result
}

# {SOURCE PREDICTED}: PREDICTED a sorted list of {LINE COL NOTES FAILURE
# FUNCTION EXITS}.
proc generate {seed} {
    expr {srand($seed)}
    set quiet [expr {rand() < 0.33}]
    set lines {}
    set ::names $::failureNames
    if {$seed % 3 == 0} {
        lappend ::names sfm::Bad
        lappend lines "import sfm"
        census namespaced
    }
    foreach n $::names {
        if {[string first :: $n] < 0} {
            lappend lines "error $n"
        }
    }
    foreach n $::names {
        lappend lines "fn raise_[helper $n]\(x) errors $n:" "    if x == 3:" "        fail $n" "    x"
    }
    set predicted {}
    set drivers {}
    set functions [expr {1 + int(rand() * 3)}]
    for {set f 0} {$f < $functions} {incr f} {
        set fn [genFunction $f $quiet]
        set base [llength $lines]
        lappend predicted {*}[predict g$f [dict get $fn sites] $base]
        foreach n [dict get $fn nested] {
            lappend predicted {*}[predict [lindex $n 0] [lindex $n 1] $base]
        }
        lappend lines {*}[dict get $fn lines]
        lappend drivers [list $f [dict get $fn declared]]
    }
    lappend lines "ks = \[0, 1, 2, 3, 4, 7\]"
    set results {}
    # {LINE COL} of every `"s"` written (ONE-CHAR-STRING-LITERAL sites).
    set literals {}
    foreach driver $drivers {
        lassign $driver f declared
        foreach {v args} [list v$f {1, [1, 2]} u$f {"s", [3]}] {
            lappend lines "$v = loop k in ks:" "    w = k.g$f\($args):"
            set at [string first {"s"} [lindex $lines end]]
            if {$at >= 0} {
                lappend literals [list [llength $lines] [expr {$at + 1}]]
            }
            foreach n $declared {
                lappend lines "        on $n:" "            -1"
            }
            lappend lines "    w"
            lappend results $v
        }
    }
    lappend lines "\[[join $results {, }]\]"
    if {$predicted eq ""} {
        census silentPrograms
    }
    return [list [join $lines \n] [lsort -dictionary $predicted] $literals]
}

# {LINE COL} of each ONE-CHAR-STRING-LITERAL warning of HIR, in source order.
proc literalsOf {hir} {
    set result {}
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "ONE-CHAR-STRING-LITERAL"} continue
        set at [lrange [dict get $w primary] 2 end]
        lappend result [list [dict get $at line] [dict get $at column]]
    }
    return [lsort -dictionary $result]
}

# The code of the predicted warning that sorts first (source order), or "".
proc firstPredictedCode {predicted literals} {
    set all [concat [lmap p $predicted {list [lindex $p 0] [lindex $p 1] SAME-FAILURE}] \
        [lmap l $literals {list {*}$l ONE-CHAR-STRING-LITERAL}]]
    if {$all eq ""} {
        return ""
    }
    return [lindex [lsort -dictionary $all] 0 2]
}

proc compileMode {source mode} {
    return [surface::compile $source fuzz.bot -warnings $mode -warning-channel ""]
}

# {LINE COL NOTES FAILURE FUNCTION EXITS} of each SAME-FAILURE warning of HIR.
proc failuresOf {hir} {
    set result {}
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "SAME-FAILURE"} continue
        set at [lrange [dict get $w primary] 2 end]
        set notes [lmap o [dict get $w secondary] {
            set fields [lrange $o 2 end]
            list [dict get $fields line] [dict get $fields column]
        }]
        lappend result [list [dict get $at line] [dict get $at column] $notes \
            [dict get $w data failure] [dict get $w data functionName] [dict get $w data exits]]
    }
    return [lsort -dictionary $result]
}

if {$show ne ""} {
    lassign [generate $show] source predicted literals
    puts "$source\n--- predicted (line col notes failure function exits):\n[join $predicted \n]\n--- predicted ONE-CHAR-STRING-LITERAL sites (line col):\n[join $literals \n]"
    file delete -force $::fuzzLib
    exit 0
}

set ::census [dict create]
set failures 0
set extras 0
set warned 0
set clean 0
set groups 0
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    lassign [generate $seed] source predicted literals
    incr groups [llength $predicted]
    set problems {}
    if {[catch {compileMode $source default} hir options]} {
        lappend problems "default mode did not compile: $hir"
    } else {
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] ni {SAME-FAILURE ONE-CHAR-STRING-LITERAL}} {
                lappend problems "unexpected code [dict get $w code]: [dict get $w message]"
            }
        }
        set actualLiterals [literalsOf $hir]
        foreach l $literals {
            if {$l ni $actualLiterals} {
                lappend problems "MISSED predicted ONE-CHAR-STRING-LITERAL at $l (actual: $actualLiterals)"
            }
        }
        foreach l $actualLiterals {
            if {$l ni $literals} {
                puts "EXTRA seed $seed: ONE-CHAR-STRING-LITERAL at $l is not predicted:\n$source"
                incr extras
            }
        }
        set actual [failuresOf $hir]
        foreach p $predicted {
            if {$p ni $actual} {
                lappend problems "MISSED predicted warning $p (actual: $actual)"
            }
        }
        if {[llength $actual] != [llength [lsort -unique $actual]]} {
            lappend problems "a failure group was reported more than once: $actual"
        }
        foreach a $actual {
            if {$a ni $predicted} {
                puts "EXTRA seed $seed: warning $a is not predicted:\n$source"
                incr extras
            }
        }
        # off: compiles, silently, runs no warning pass, same HIR.
        hir::warnings::resetStats
        set ::passCalls 0
        trace add execution hir::warnings::SameFailure enter {apply {{args} {incr ::passCalls}}}
        try {
            set offFailed [catch {compileMode $source off} off]
        } finally {
            trace remove execution hir::warnings::SameFailure enter {apply {{args} {incr ::passCalls}}}
        }
        if {$offFailed} {
            lappend problems "off mode did not compile: $off"
        } elseif {[hir::warnings::of $off] ne "" || [hir::warnings::stats] ne "" || $::passCalls != 0} {
            lappend problems "off mode ran or reported warnings"
        } elseif {$off ne [dict remove $hir warnings]} {
            lappend problems "HIR differs between off and default"
        }
        # error: rejected with this code iff a warning is predicted.
        set rejected [catch {compileMode $source error} message options]
        set firstCode [firstPredictedCode $predicted $literals]
        if {$rejected} {
            if {$firstCode eq ""} {
                lappend problems "error mode rejected a program with no predicted warning: $message"
            } elseif {[dict get $options -errorcode] ne [list CORE SEMANTIC $firstCode]} {
                lappend problems "error mode rejected with [dict get $options -errorcode]: $message"
            }
        } elseif {$firstCode ne ""} {
            lappend problems "error mode accepted a program with a predicted warning"
        }
        if {$actual eq ""} { incr clean } else { incr warned }
    }
    if {$problems ne ""} {
        incr failures
        puts "FAIL seed $seed:\n[join $problems \n]\n--- source:\n$source"
    }
}
set c $::census
proc get {c key} {
    return [expr {[dict exists $c $key] ? [dict get $c $key] : 0}]
}
puts "seeds $seeds (from $first): $warned with warnings, $clean without; failures $failures; extra warnings $extras; groups $groups; functions [get $c functions], reachable fail sites [get $c sites] (guards [get $c guard], elif pairs [get $c elif], list loops [get $c loop], counted loops [get $c countloop], handlers [get $c handler], re-raises [get $c reraise], final [get $c finalfail]), dead [get $c dead], range-unreachable [get $c range], propagating calls [get $c propagate], bare final calls [get $c barecall], returns [get $c return], nested functions [get $c nested], only-silent programs [get $c silentPrograms], namespaced programs [get $c namespaced]"
file delete -force $::fuzzLib
exit [expr {$failures > 0 || $extras > 0}]
