# fuzz.tcl -- focused fuzzer for SAME-RETURN-VALUE and the global warning
# modes (WARNINGS-SAME-RETURN.md, "Fuzzing").
#
#   tclsh9.0 audit/same-return-value/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED?
#
# Each seed generates one function of 2-8 terminal paths whose exits return
# values *known by construction*:
#
#   literal            return 2                     key lit:2
#   module alias       a2 = 2 / b2 = a2 ... return b2   key lit:2 (chains too)
#   branch-local alias t = 2 ; return t             key lit:2
#   parameter          return p1                    key param:p1
#   binding            r = mk(p0) ... return r      key bind:r (the same binding)
#   alias of binding   s = r ... return s           key bind:r
#   call               return mk(p0)                no key: each one is unique
#   mutable            return mutable_array_allocate(1)   no key: unique
#   unreachable        if 1 == 2: return 2          contributes nothing
#   range-unreachable  if p0 < 0: if p0 > 5: return 2   contributes nothing
#
# The final path is a `return` or the function's final value, at random. The
# oracle is independent of the compiler: it groups the generated exits by key
# and predicts exactly which groups (with which exit lines) warn. For every
# program it checks
#
#   default   compiles; the warnings are the predicted groups
#   off       compiles; no warning, and no warning pass ran
#   error     rejected with {CORE SEMANTIC SAME-RETURN-VALUE} iff a warning
#             exists, and compiles otherwise
#
# The compiler may legitimately prove *more* than the oracle models; such a
# group is printed as EXTRA (with its source) for inspection and is not a
# failure. A predicted group the compiler misses, or a warning that is not a
# superset of a predicted group's exits, is a failure.
#
# Exits non-zero on any failure.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]

set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 300}]
set first [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

# {SOURCE EXPECTED} for SEED: EXPECTED is the sorted list of predicted
# groups, each a list of exit line numbers.
proc generate {seed} {
    expr {srand($seed)}
    set header {a1 = 1
a2 = 2
a3 = 3
b1 = a1
b2 = a2
b3 = a3
fn mk(a):
    a + 1}
    set lines [split $header \n]
    lappend lines "fn f(p0, p1):" "    r = mk(p0)" "    s = r"
    set paths [expr {2 + int(rand() * 7)}]
    set exits {}
    set threshold 0
    for {set i 0} {$i < $paths} {incr i} {
        set last [expr {$i == $paths - 1}]
        if {!$last} {
            # Sometimes an unreachable exit first: statically false.
            if {rand() < 0.2} {
                lappend lines "    if 1 == 2:"
                lappend lines "        return [pick {1 2 3}]"
            }
            # ... or infeasible only by range facts (p0 < 0 and p0 > 5).
            if {rand() < 0.15} {
                lappend lines "    if p0 < 0:"
                lappend lines "        if p0 > 5:"
                lappend lines "            return [pick {1 2 3}]"
            }
            lappend lines "    if p0 < [incr threshold]:"
            set indent "        "
        } else {
            set indent "    "
        }
        # The returned expression: {TEXT KEY}.
        set k [pick {1 2 3}]
        switch -- [pick {lit lit module chain local param bind alias call mutable}] {
            lit     { set expr [list $k lit:$k] }
            module  { set expr [list a$k lit:$k] }
            chain   { set expr [list b$k lit:$k] }
            local   {
                lappend lines "${indent}t$i = $k"
                set expr [list t$i lit:$k]
            }
            param   { set expr [list p1 param:p1] }
            bind    { set expr [list r bind:r] }
            alias   { set expr [list s bind:r] }
            call    { set expr [list "mk(p0)" unique:$i] }
            mutable { set expr [list "mutable_array_allocate(1)" unique:$i] }
        }
        lassign $expr text key
        if {$last && rand() < 0.5} {
            lappend lines "    $text"
        } else {
            lappend lines "${indent}return $text"
        }
        lappend exits [list [llength $lines] $key]
        if {!$last} {
            # Exits at the same line cannot happen; nothing to do.
        }
    }
    # Group by key.
    set byKey [dict create]
    foreach exit $exits {
        lassign $exit line key
        if {![string match unique:* $key]} {
            dict lappend byKey $key $line
        }
    }
    set expected {}
    dict for {key group} $byKey {
        if {[llength $group] >= 2} {
            lappend expected $group
        }
    }
    return [list [join $lines \n]\n [lsort $expected]]
}

# 1 if every element of SMALL is in BIG.
proc subset {small big} {
    foreach x $small {
        if {$x ni $big} {
            return 0
        }
    }
    return 1
}

proc compileMode {source mode} {
    return [surface::compile $source fuzz.bot -warnings $mode -warning-channel ""]
}

proc linesOf {hir w} {
    return [lmap o [list [dict get $w primary] {*}[dict get $w secondary]] {
        dict get [lrange $o 2 end] line
    }]
}

set failures 0
set extras 0
set warned 0
set clean 0
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    lassign [generate $seed] source expected
    set problems {}
    if {[catch {compileMode $source default} hir options]} {
        lappend problems "default mode did not compile: $hir"
    } else {
        set actual [lsort [lmap w [hir::warnings::of $hir] {linesOf $hir $w}]]
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] ne "SAME-RETURN-VALUE"} {
                lappend problems "unexpected code [dict get $w code]"
            }
        }
        foreach group $expected {
            set found 0
            foreach a $actual {
                if {[subset $group $a]} {
                    set found 1
                }
            }
            if {!$found} {
                lappend problems "MISSED constructed group $group (actual: $actual)"
            }
        }
        foreach a $actual {
            set covered 0
            foreach group $expected {
                if {[subset $group $a]} {
                    set covered 1
                }
            }
            if {!$covered} {
                puts "EXTRA seed $seed: group at lines $a is not a constructed group:\n$source"
                incr extras
            }
        }
        # off: compiles, silently, runs no warning pass.
        hir::warnings::resetStats
        if {[catch {compileMode $source off} off]} {
            lappend problems "off mode did not compile: $off"
        } elseif {[hir::warnings::of $off] ne "" || [hir::warnings::stats] ne ""} {
            lappend problems "off mode ran or reported warnings"
        } elseif {$off ne [dict remove $hir warnings]} {
            lappend problems "HIR differs between off and default"
        }
        # error: rejected iff a warning exists.
        set rejected [catch {compileMode $source error} message options]
        if {$rejected} {
            if {[dict get $options -errorcode] ne {CORE SEMANTIC SAME-RETURN-VALUE}} {
                lappend problems "error mode rejected with [dict get $options -errorcode]: $message"
            }
            if {$actual eq ""} {
                lappend problems "error mode rejected a program with no warning"
            }
        } elseif {$actual ne ""} {
            lappend problems "error mode accepted a program with warnings"
        }
        if {$actual eq ""} { incr clean } else { incr warned }
    }
    if {$problems ne ""} {
        incr failures
        puts "FAIL seed $seed:\n[join $problems \n]\n$source"
    }
}
puts "seeds $seeds (from $first): $warned with warnings, $clean without; failures $failures; extra groups $extras"
exit [expr {$failures > 0}]
