# mutate.tcl -- mutation evidence for the Icy Tower vertical slice's golden
# suite (ICY-TOWER-VERTICAL-SLICE-1.md, "Mutation evidence").
#
#   tclsh9.0 audit/icy-tower/mutate.tcl ?-backends LIST? ?-jobs N? ?-timeout S? ?NAME ...?
#
# For every mutant of audit/icy-tower/mutants.txt (or the NAMEs given): a
# private application directory -- a copy of examples/games/icy-tower/'s
# golden.bot and the pure modules it imports (tower.bot, hud.bot,
# options.bot: application modules, IMPORTS.md), one of them mutated --
# and one run of that golden.bot through tests/golden/run.tcl (default
# backend compile: the mutants are rule bugs, not backend ones). A mutant
# is killed when a test fails or the suite stops compiling. Every mutant
# must still apply (its text occurs exactly once) and be killed; the
# unmutated modules must pass, so a kill means the mutation.
#
# Prints one line per mutant: killed (the failing tests), SURVIVED or NOT
# APPLIED. Exit status 1 if any survived, did not apply, or the baseline
# failed. Scratch state lives in a `file tempdir` directory (AGENTS.md).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root audit golden tools tree.tcl]

set options [dict create -backends compile -jobs [exec nproc] -timeout 900]
set names {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {[string match -* $arg]} {
        if {![dict exists $options $arg]} { error "unknown option $arg" }
        dict set options $arg [lindex $argv [incr i]]
    } else {
        lappend names $arg
    }
}

set game examples/games/icy-tower
set modules {tower.bot hud.bot options.bot golden.bot}
set originals [dict create]
foreach module $modules {
    dict set originals $game/$module [goldentools::readFile [file join $root $game $module]]
}

# A private application under WORK/NAME holding TEXTS (path -> text): the
# suite and the modules beside it. Its suite's path.
proc application {work name texts} {
    set dir [file join $work $name]
    file mkdir $dir
    dict for {path text} $texts {
        goldentools::writeFile [file join $dir [file tail $path]] $text
    }
    return [file join $dir golden.bot]
}

set work [file tempdir botlish-icy-tower-mutate]
set exit 0
try {
    set commands [dict create]
    set problems {}
    dict set commands baseline [list [info nameofexecutable] [file join $root tests golden run.tcl] \
        -backends [dict get $options -backends] -names [application $work baseline $originals]]
    foreach {name description edits} [goldentools::readMutants [file join $here mutants.txt]] {
        if {$names ne {} && $name ni $names} continue
        set texts $originals
        set applied 1
        foreach {file old new} $edits {
            if {![dict exists $texts $file]} { error "mutant $name edits $file, not one of $game's pure modules" }
            set text [dict get $texts $file]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                set applied 0
                break
            }
            dict set texts $file [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            lappend problems "$name: NOT APPLIED (its text does not occur exactly once)"
            continue
        }
        dict set commands $name [list [info nameofexecutable] [file join $root tests golden run.tcl] \
            -backends [dict get $options -backends] -names [application $work m-$name $texts]]
    }
    set results [goldentools::runParallel [dict get $options -jobs] [dict get $options -timeout] $commands]
    lassign [goldentools::suiteVerdicts [lindex [dict get $results baseline] 1]] state verdicts
    if {$state ne "ok"} {
        puts "baseline: $state -- the unmutated modules must pass"
        set exit 1
    }
    set killed 0
    set total 0
    foreach name [dict keys $commands] {
        if {$name eq "baseline"} continue
        incr total
        lassign [dict get $results $name] status output seconds
        lassign [goldentools::suiteVerdicts $output] state verdicts
        set failing [lmap {n v} $verdicts {if {$v ne "FAIL"} continue; set n}]
        if {$state eq "ok"} {
            puts [format "%-28s SURVIVED" $name]
            set exit 1
        } else {
            incr killed
            set why [expr {$state eq "failed" ? "[llength $failing] failing: [join [lrange $failing 0 3] {, }][expr {[llength $failing] > 4 ? ", ..." : ""}]" : $state}]
            puts [format "%-28s killed (%s)" $name $why]
        }
    }
    foreach p $problems { puts $p; set exit 1 }
    puts "$killed of $total mutants killed"
} finally {
    file delete -force $work
}
exit $exit
