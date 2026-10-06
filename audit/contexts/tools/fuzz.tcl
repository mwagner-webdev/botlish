#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated static-context programs against an independent oracle
# (CONTEXTS.md).
#
#   tclsh9.0 audit/contexts/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                          ?-backends LIST?
#
# Each program has 0..3 synthetic context types (some opaque, some not, all
# with fields that fit fixed native slots), and functions of five shapes:
#
#   direct   fn dN(context L1: Ci, L2: Cj): L1.value + L2.value + K
#            (random local names: identity is the type, never the name)
#   mid      fn mN(): f() + g() + K           calls earlier functions
#   rec      fn rN(n, context L: Ci): if n == 0: L.value + K else: rN(n - 1)
#   cycle    fn aN(n): fn bN(m, context L: Ci): ... aN(m - 1) ...; bN(n)
#            (a requirement cycle through a nested function)
#   outer    fn oN(n, context L: Ci): fn pN(m): ... oN(m - 1) ...; L.value + pN(n)
#            (the nested function requires Ci only through its call back out)
#   ctor     fn makeN(context L: Cj) -> Ci: Ci {value: L.value, on: true}
#            (a constructor that itself needs an earlier context)
#
# and a top level of installations (literal, through a binding, through a
# constructor; in random order; some missing, some duplicated) interleaved
# with calls of random functions; some functions are never called. The
# oracle computes, independently of the compiler:
#
#   * every function's direct and transitive context set, compared with
#     hir::contexts::direct / ::required of the -strict 0 HIR;
#   * the first error of the top level walked in source order (MISSING-CONTEXT
#     for a call or constructor that needs an uninstalled type, DUPLICATE-
#     CONTEXT for a second installation of a type), compared with the error
#     kind strict compilation raises;
#   * for an accepted program, its value, compared with what every backend
#     in BACKENDS computes.
#
# The last line is "programs N disagreements D"; the exit status is 1 if D >
# 0. Nothing here needs the native backend unless BACKENDS names one.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 50
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

# A private directory (never the working directory: concurrent runs, AGENTS.md).
set scratch [file tempdir contexts-fuzz]

# A small deterministic PRNG (an LCG), so a seed reproduces a program on any
# Tcl build.
proc rnd {n} {
    set ::rng [expr {($::rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($::rng / 65536) % $n}]
}
proc pick {list} {
    return [lindex $list [rnd [llength $list]]]
}
proc chance {percent} {
    return [expr {[rnd 100] < $percent}]
}

set localNames {io c ctx env sys a b x q this_one}

# One program: {TEXT FUNCS EXPECT} where FUNCS is NAME -> {direct DIRECT
# required REQUIRED} and EXPECT is {error KIND} or {value TEXT}.
proc generate {seed} {
    set ::rng [expr {$seed * 7919 + 17}]
    set k [rnd 4]
    set types {}
    set values [dict create]
    set lines [list "type Small = Int in 0..100000" ""]
    for {set i 0} {$i < $k} {incr i} {
        set t C$i
        lappend types $t
        dict set values $t [rnd 1000]
        set modifier [expr {[chance 50] ? "opaque " : ""}]
        lappend lines "${modifier}context struct $t:" "    value: Small" "    enabled: bool" ""
    }
    # Functions, in definition order: NAME -> {kind K direct D calls C value V
    # call SPELLING}. VALUE is the oracle's value when every type is installed
    # (types' values as installed): a script over `values`.
    set funcs [dict create]
    set order {}
    set nf [expr {2 + [rnd 6]}]
    for {set j 0} {$j < $nf} {incr j} {
        set kinds {mid}
        if {$k > 0} {
            lappend kinds direct direct rec cycle outer
        }
        if {$order eq ""} {
            set kinds [lsearch -all -inline -not $kinds mid]
            if {$kinds eq ""} {
                set kinds {const}
            }
        }
        set kind [pick $kinds]
        set constant [rnd 50]
        switch -- $kind {
            const {
                set name f$j
                lappend lines "fn ${name}():" "    $constant" ""
                dict set funcs $name [dict create direct {} calls {} value $constant call "${name}()"]
            }
            direct {
                set name d$j
                set chosen [lsort -unique [lmap _ [lrepeat [expr {1 + [rnd $k]}] x] {pick $types}]]
                set used {}
                set params {}
                set terms {}
                foreach t $chosen {
                    set local [pick [lsearch -all -inline -not -exact $::localNames {}]]
                    while {$local in $used} {
                        set local [pick $::localNames]
                    }
                    lappend used $local
                    lappend params "$local: $t"
                    lappend terms "$local.value"
                }
                lappend lines "fn ${name}(context [join $params {, }]):" "    [join $terms { + }] + $constant" ""
                set value [expr {$constant}]
                dict set funcs $name [dict create direct $chosen calls {} value [list sum $chosen $constant] call "${name}()"]
            }
            mid {
                set name m$j
                set callees [lsort -unique [lmap _ [lrepeat [expr {1 + [rnd 2]}] x] {pick $order}]]
                set terms [lmap c $callees {dict get $funcs $c call}]
                lappend lines "fn ${name}():" "    [join $terms { + }] + $constant" ""
                dict set funcs $name [dict create direct {} calls $callees value [list calls $callees $constant] call "${name}()"]
            }
            rec {
                set name r$j
                set t [pick $types]
                set local [pick $::localNames]
                lappend lines "fn ${name}(n, context $local: $t):" "    if n == 0:" "        $local.value + $constant" \
                    "    else:" "        ${name}(n - 1)" ""
                dict set funcs $name [dict create direct [list $t] calls {} value [list sum [list $t] $constant] call "${name}([rnd 4])"]
            }
            cycle {
                set name a$j
                set inner b$j
                set t [pick $types]
                set local [pick $::localNames]
                lappend lines "fn ${name}(n):" "    fn ${inner}(m, context $local: $t):" "        if m == 0:" \
                    "            $local.value + $constant" "        else:" "            ${name}(m - 1)" "    ${inner}(n)" ""
                dict set funcs $inner [dict create direct [list $t] calls {} value {} call "" nested 1]
                dict set funcs $name [dict create direct {} calls [list $inner] value [list sum [list $t] $constant] call "${name}([rnd 4])"]
            }
            outer {
                # The context on the OUTER function of the cycle: the nested
                # function requires it only through its call back out.
                set name o$j
                set inner p$j
                set t [pick $types]
                set local [pick $::localNames]
                lappend lines "fn ${name}(n, context $local: $t):" "    fn ${inner}(m):" "        if m == 0:" \
                    "            0" "        else:" "            ${name}(m - 1)" "    $local.value + ${inner}(n) + $constant" ""
                dict set funcs $inner [dict create direct {} calls [list $name] value {} call "" nested 1]
                set arg [rnd 4]
                dict set funcs $name [dict create direct [list $t] calls [list $inner] value [list times [expr {$arg + 1}] $t $constant] call "${name}($arg)"]
            }
        }
        lappend order $name
    }
    # Constructors: one per type, possibly needing another type.
    set ctorNeeds [dict create]
    foreach t $types {
        # A constructor may need an EARLIER type only (no dependency cycle
        # between installations, which would make every order wrong).
        set earlier [lrange $types 0 [expr {[lsearch -exact $types $t] - 1}]]
        if {[chance 30] && $earlier ne ""} {
            set other [pick $earlier]
            set local [pick $::localNames]
            lappend lines "fn make_${t}(context $local: $other) -> $t:" "    $t {value: $local.value, enabled: true}" ""
            dict set ctorNeeds $t $other
            dict set funcs make_$t [dict create direct [list $other] calls {} value {} call "" ctor 1]
        } else {
            lappend lines "fn make_${t}() -> $t:" "    $t {value: [dict get $values $t], enabled: false}" ""
            dict set funcs make_$t [dict create direct {} calls {} value {} call "" ctor 1]
        }
    }
    # The top level.
    set installed {}
    set error ""
    set results {}
    set steps [expr {1 + [rnd 7]}]
    set binding 0
    # Most programs install every type first (in a random order, which a
    # constructor dependency may still get wrong), then call; the rest
    # interleave freely.
    set upfront {}
    if {[chance 65]} {
        if {[chance 60]} {
            set upfront $types
        } else {
            set pool $types
            while {$pool ne ""} {
                set t [pick $pool]
                lappend upfront $t
                set pool [lsearch -all -inline -not -exact $pool $t]
            }
        }
        incr steps [llength $upfront]
    }
    for {set s 0} {$s < $steps} {incr s} {
        if {$upfront ne "" || ($types ne "" && [chance 30])} {
            if {$upfront ne ""} {
                set upfront [lassign $upfront t]
            } else {
                set t [pick $types]
            }
            if {$t in $installed && ![chance 10]} {
                set notYet [lmap x $types {if {$x in $installed} continue; set x}]
                if {$notYet eq ""} continue
                set t [pick $notYet]
            }
            set how [pick {literal binding ctor}]
            if {[dict exists $ctorNeeds $t]} {
                set how ctor
            }
            switch -- $how {
                literal { lappend lines "with context $t {value: [dict get $values $t], enabled: true}" }
                binding {
                    lappend lines "inst[incr binding] = $t {value: [dict get $values $t], enabled: false}" "with context inst$binding"
                }
                ctor { lappend lines "with context make_${t}()" }
            }
            if {$error eq ""} {
                if {$how eq "ctor" && [dict exists $ctorNeeds $t] && [dict get $ctorNeeds $t] ni $installed} {
                    set error MISSING-CONTEXT
                } elseif {$t in $installed} {
                    set error DUPLICATE-CONTEXT
                }
            }
            if {$t ni $installed} {
                lappend installed $t
                if {[dict exists $ctorNeeds $t]} {
                    # The constructor copies the other type's value.
                    dict set values $t [dict get $values [dict get $ctorNeeds $t]]
                }
            }
        } else {
            set callable [lmap f $order {if {[dict get $funcs $f call] eq ""} continue; set f}]
            if {$callable eq ""} continue
            set f [pick $callable]
            lappend lines "res$s = [dict get $funcs $f call]"
            lappend results res$s $f
            if {$error eq ""} {
                foreach t [Required $funcs $f] {
                    if {$t ni $installed} {
                        set error MISSING-CONTEXT
                        break
                    }
                }
            }
        }
    }
    set names [lmap {r f} $results {set r}]
    lappend lines [expr {$names eq "" ? "0" : "\[[join $names {, }]\]"}]
    set expect [expr {$error ne "" ? [list error $error]
        : [list value [expr {$names eq "" ? "0" : "\[[join [lmap {r f} $results {Value $funcs $f $values}] {, }]\]"}]]}]
    set required [dict create]
    foreach f [dict keys $funcs] {
        dict set required $f [dict create direct [lsort [dict get $funcs $f direct]] required [Required $funcs $f]]
    }
    return [list "[join $lines \n]\n" $required $expect]
}

# The oracle's transitive requirement of F (sorted).
proc Required {funcs f {seen {}}} {
    if {$f in $seen} {
        return {}
    }
    set result [dict get $funcs $f direct]
    foreach c [dict get $funcs $f calls] {
        lappend result {*}[Required $funcs $c [concat $seen [list $f]]]
    }
    return [lsort -unique $result]
}

# The oracle's value of a call of F with every type installed as VALUES.
proc Value {funcs f values} {
    set v [dict get $funcs $f value]
    switch -- [lindex $v 0] {
        sum {
            set total [lindex $v 2]
            foreach t [lindex $v 1] {
                incr total [dict get $values $t]
            }
            return $total
        }
        times {
            lassign $v - count t constant
            return [expr {$count * ([dict get $values $t] + $constant)}]
        }
        calls {
            set total [lindex $v 2]
            foreach c [lindex $v 1] {
                incr total [Value $funcs $c $values]
            }
            return $total
        }
    }
    return $v
}

proc hirOf {text strict} {
    set path [file join $::scratch p[incr ::counter].bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
    return [surface::readProgramFile $path -strict $strict -warnings off]
}

# The block of function NAME in HIR ("" if none).
proc blockOf {hir name} {
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] ne "local"} continue
        set shown [expr {[dict exists $binding spelling] ? [dict get $binding spelling] : [dict get $binding name]}]
        if {$shown ne $name} continue
        set by [dict get $binding declaredBy]
        if {$by ne "" && [hir::kind $hir $by] eq "bind" && [hir::kind $hir [hir::get $hir $by value]] eq "block"} {
            return [hir::get $hir $by value]
        }
    }
    return ""
}

set disagreements 0
set accepted 0
set rejected 0
for {set i 0} {$i < $n} {incr i} {
    set seed [expr {$seed0 + $i}]
    lassign [generate $seed] text required expect
    if {$dump} {
        puts "### program $seed (expect $expect)\n$text"
    }
    set problems {}
    # Requirement facts (from the -strict 0 HIR, whatever the verdict).
    if {[catch {hirOf $text 0} loose]} {
        lappend problems "-strict 0 build failed: $loose"
    } else {
        dict for {f facts} $required {
            set b [blockOf $loose $f]
            if {$b eq ""} {
                lappend problems "no function $f"
                continue
            }
            set got [list direct [hir::contexts::direct $loose $b] required [hir::contexts::required $loose $b]]
            if {$got ne $facts} {
                lappend problems "requirements of $f: oracle $facts, compiler $got"
            }
        }
    }
    if {[lindex $expect 0] eq "error"} {
        incr rejected
        if {![catch {hirOf $text 1} message options]} {
            lappend problems "accepted; oracle expects [lindex $expect 1]"
        } elseif {[lindex [dict get $options -errorcode] end] ne [lindex $expect 1]} {
            lappend problems "rejected with [dict get $options -errorcode] ($message); oracle expects [lindex $expect 1]"
        }
    } else {
        incr accepted
        if {[catch {hirOf $text 1} hir]} {
            lappend problems "rejected ($hir); oracle expects the value [lindex $expect 1]"
        } else {
            foreach backend $backends {
                set outcome [outcomeUnderHir $backend $hir]
                if {[lindex $outcome 0] ne "value" || [lindex $outcome 1] ne [lindex $expect 1]} {
                    lappend problems "$backend: $outcome; oracle [lindex $expect 1]"
                }
            }
        }
    }
    if {$problems ne ""} {
        incr disagreements
        puts "DISAGREEMENT program $seed:\n[join $problems \n]\n--- program ---\n$text"
    }
}
file delete -force $scratch
puts "accepted $accepted rejected $rejected"
puts "programs $n disagreements $disagreements"
exit [expr {$disagreements > 0}]
