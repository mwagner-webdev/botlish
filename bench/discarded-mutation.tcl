# discarded-mutation.tcl -- the compile-time cost of the DISCARDED-MUTATION
# warning (WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md, section 17).
#
#   tclsh9.0 bench/discarded-mutation.tcl ?-runs N? ?-scale N? ?-programs FILES? ?-real 0|1?
#
# For each program: the front end's compile time with warnings off and with
# warnings on (best of N runs each), the DISCARDED-MUTATION pass's own time
# on the compiled HIR (hir::warnings::DiscardedMutation, best of N), the
# front end's time with the checked source kept and with it not kept (a copy
# of hir::BuildFull without the one line that keeps it: what keeping the
# program as written costs the elaborations' copy-on-write), and the
# program's mutation sites, folds and findings.
#
# The programs are real ones of the repository (a golden suite of each
# mutable collection, the 2048 engine, Icy-Tower-free examples) and
# generated stress shapes whose size grows with -scale: many local
# mutations, deeply nested loops, one large fold with many mutations and
# exits, an untyped function called at several types, and many application
# modules mutating their own locals. -real 0 measures the generated ones
# only (a scaling run).

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
set options [dict create -runs 3 -scale 1 -programs "" -real 1]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
unset -nocomplain env(BOTLISH_HIR_CACHE)
unset -nocomplain env(BOTLISH_WARNINGS)
source [file join $root surface surface.tcl]
interp recursionlimit {} 1000000

proc best {runs script} {
    set best ""
    for {set i 0} {$i < $runs} {incr i} {
        set t [lindex [time {uplevel 1 $script}] 0]
        if {$best eq "" || $t < $best} { set best $t }
    }
    return $best
}

proc ms {us} {
    return [format %.1f [expr {$us / 1000.0}]]
}

# hir::BuildFull without keeping the checked source: the baseline the
# capture's cost is measured against.
set ::withCapture [info body ::hir::BuildFull]
set ::withoutCapture [string map {{dict set hir checkedSource $hir} {}} $::withCapture]
if {$::withoutCapture eq $::withCapture} {
    error "hir::BuildFull no longer keeps checkedSource as this benchmark expects"
}
proc useCapture {on} {
    set args [info args ::hir::BuildFull]
    set formal {}
    foreach a $args {
        if {[info default ::hir::BuildFull $a d]} {
            lappend formal [list $a $d]
        } else {
            lappend formal $a
        }
    }
    proc ::hir::BuildFull $formal [expr {$on ? $::withCapture : $::withoutCapture}]
}

# --------------------------------------------------------------------------
# Generated stress programs (text), by -scale.

set scale [dict get $options -scale]
set vec "import std::mutable_vector\n"

proc genLocals {n} {
    set lines [list "fn ints() -> MutableVector\[int\]:" "    std::mutable_vector::from_list(\[0\])" "fn f(p: int) -> int:"]
    for {set i 0} {$i < 20} {incr i} {
        lappend lines "    v$i = ints()"
    }
    for {set i 0} {$i < $n} {incr i} {
        set v v[expr {$i % 20}]
        if {$i % 7 == 3} {
            lappend lines "    r$i = $v.length()"
        } else {
            lappend lines "    $v.push($i)"
        }
    }
    lappend lines "    v0.length() + v1.length()" "f(1)"
    return "$::vec[join $lines \n]\n"
}

proc genNested {depth n} {
    set lines [list "fn f(grid: List\[List\[MutableVector\[int\]\]\], p: int) -> int:" "    w = std::mutable_vector::from_list(\[0\])"]
    set indent "    "
    for {set d 0} {$d < $depth} {incr d} {
        lappend lines "${indent}loop row$d in grid:"
        append indent "    "
        lappend lines "${indent}loop cell$d in row$d:"
        append indent "    "
        for {set i 0} {$i < $n} {incr i} {
            lappend lines "${indent}cell$d.push($i)"
            lappend lines "${indent}w.push($i)"
        }
    }
    lappend lines "${indent}0" "    w.length()" "f(\[\[std::mutable_vector::from_list(\[1\])\]\], 1)"
    return "$::vec[join $lines \n]\n"
}

proc genFold {n} {
    set lines [list "fn ints() -> MutableVector\[int\]:" "    std::mutable_vector::from_list(\[0\])" \
        "fn f(xs: List\[int\], p: int) -> int:" "    w = fold x in xs with intermediate acc ints():"]
    for {set i 0} {$i < $n} {incr i} {
        lappend lines "        acc.push(x + $i)"
        if {$i % 5 == 4} {
            lappend lines "        if x == $i:" "            continue"
        }
    }
    lappend lines "        acc" "    w.length()" "f(\[1, 2, 3\], 1)"
    return "$::vec[join $lines \n]\n"
}

proc genGeneric {n k} {
    set lines [list "fn g(x):" "    v = std::mutable_vector::from_list(\[x\])"]
    for {set i 0} {$i < $n} {incr i} {
        lappend lines "    v.push(x)"
    }
    lappend lines "    x"
    set calls {}
    set values {1 "\"a\"" true 2.5 "\[1\]" "{a: 1}"}
    for {set i 0} {$i < $k} {incr i} {
        lappend calls "g([lindex $values [expr {$i % [llength $values]}]])"
    }
    lappend lines "\[[join $calls {, }]\]"
    return "$::vec[join $lines \n]\n"
}

proc genModules {dir m n} {
    file mkdir $dir
    set imports {}
    set calls {}
    for {set j 0} {$j < $m} {incr j} {
        set lines [list "import std::mutable_vector" "fn work(p: int) -> int:" "    v = std::mutable_vector::from_list(\[0\])"]
        for {set i 0} {$i < $n} {incr i} {
            lappend lines "    v.push(p + $i)"
        }
        lappend lines "    v.length()"
        set f [open [file join $dir mod$j.bot] w]
        puts $f [join $lines \n]
        close $f
        lappend imports "import mod$j"
        lappend calls "mod${j}::work(1)"
    }
    set f [open [file join $dir main.bot] w]
    puts $f "[join $imports \n]\n\[[join $calls {, }]\]"
    close $f
    return [file join $dir main.bot]
}

# --------------------------------------------------------------------------

set programs {}
if {[dict get $options -programs] ne ""} {
    foreach p [dict get $options -programs] {
        lappend programs [list file [file normalize $p]]
    }
} else {
    set real {}
    if {[dict get $options -real]} {
        set real {
        tests/golden/mutable-vector.bot
        tests/golden/fold-loops.bot
        tests/golden/mutable-map.bot
        tests/golden/consumed-fold-intermediates.bot
        examples/games/2048/game2048.bot
        examples/games/2048/demo.bot
        }
    }
    foreach p $real {
        if {[file exists [file join $root $p]]} {
            lappend programs [list file [file join $root $p]]
        }
    }
    set tmp [file tempdir botlish-dm-bench]
    lappend programs [list text locals-[expr {400 * $scale}] [genLocals [expr {400 * $scale}]]]
    lappend programs [list text nested-[expr {6 * $scale}] [genNested [expr {6 * $scale}] 4]]
    lappend programs [list text fold-[expr {200 * $scale}] [genFold [expr {200 * $scale}]]]
    lappend programs [list text generic-[expr {200 * $scale}]x6 [genGeneric [expr {200 * $scale}] 6]]
    lappend programs [list file [genModules [file join $tmp modules] [expr {20 * $scale}] 30]]
}

proc compileProgram {program mode} {
    lassign $program kind a b
    if {$kind eq "file"} {
        return [surface::readProgramFile $a -warnings $mode -warning-channel ""]
    }
    return [surface::compile $b $a.bot -warnings $mode -warning-channel ""]
}

proc nameOf {program} {
    lassign $program kind a
    if {$kind eq "file"} {
        set n [file tail $a]
        if {$n eq "main.bot"} {
            return modules-[llength [glob -directory [file dirname $a] mod*.bot]]x30
        }
        return $n
    }
    return $a
}

set runs [dict get $options -runs]
puts "| program | exprs | sites | folds | findings | front end, warnings off (ms) | warnings on (ms) | DISCARDED-MUTATION pass (ms) | pass / front end | front end without keeping the checked source (ms) |"
puts "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
foreach program $programs {
    set name [nameOf $program]
    if {[catch {compileProgram $program off} hir options]} {
        puts "| $name | rejected: [lrange [dict get $options -errorcode] 0 2] |"
        continue
    }
    useCapture 1
    set off [best $runs {compileProgram $program off}]
    set on [best $runs {compileProgram $program default}]
    # The HIR the warning run is given (its checked source still attached:
    # the run drops it from the HIR the compilation returns).
    set ::given ""
    set trace {apply {{command op} {set ::given [lindex $command 1]}}}
    trace add execution hir::warnings::run enter $trace
    compileProgram $program default
    trace remove execution hir::warnings::run enter $trace
    set hir $::given
    set source [hir::discarded::Source [dict getdef $hir traitSource $hir]]
    set sites 0
    set folds 0
    if {$source ne ""} {
        set sites [dict size [hir::discarded::Sites $source]]
        dict for {e node} [dict get $source exprs] {
            if {[dict exists $node foldBinding]} { incr folds }
        }
    }
    set pass [best $runs {hir::warnings::DiscardedMutation [dict getdef $hir traitSource $hir]}]
    set findings [llength [hir::warnings::DiscardedMutation [dict getdef $hir traitSource $hir]]]
    useCapture 0
    set bare [best $runs {compileProgram $program off}]
    useCapture 1
    if {$source eq ""} {
        set exprs [dict size [dict get [dict getdef $hir traitSource $hir] exprs]]
    } else {
        set exprs [dict size [dict get $source exprs]]
    }
    puts "| $name | $exprs | $sites | $folds | $findings | [ms $off] | [ms $on] | [ms $pass] | [format %.1f%% [expr {100.0 * $pass / $off}]] | [ms $bare] |"
}
if {[info exists tmp]} {
    file delete -force $tmp
}
