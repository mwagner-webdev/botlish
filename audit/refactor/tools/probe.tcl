# probe.tcl -- behavior probes for the warning-driven refactor
# (REFACTOR-WARNINGS-CLEAN.md, "The law: observable behavior is identical").
#
#   tclsh9.0 audit/refactor/tools/probe.tcl -before COMMIT ?-after DIR? ?-only GLOB? ?-backends LIST?
#
# A conversion that changes code (not a method-sugar respelling, whose
# round-trip law is checked call by call by method-sweep.tcl) is proven by
# probes: each converted function is called on representative inputs --
# boundary, empty, ordinary and error cases -- in a program compiled once
# against the tree before the conversion and once against the tree after it,
# on every backend, and every outcome (value, or error code) must be
# identical. The compiler is this checkout's in both; only the corpus
# sources (examples/, bench/, lib/) differ: the BEFORE tree is extracted
# from COMMIT with `git archive`, the AFTER tree is DIR (default: this
# checkout).
#
# Probe files: audit/refactor/tools/probes/*.tcl, each a list of
#
#   program PATH              the corpus file probed: an entry program (the
#                             driver is appended after its own statements,
#                             as tests/stdlib.test's drivers are) or a library
#                             module lib/NS.bot (the driver follows
#                             `import NS`)
#   probe ID DRIVER           Botlish statements whose last value is the
#                             probe's outcome; a declared error the driver
#                             leaves unhandled becomes the String naming it
#                             (examples/stdlib/corpus.tcl's corpus::handled,
#                             generalized to every declared error)
#   each ID {DRIVER ...}      one probe per DRIVER (ID-1, ID-2, ...): an
#                             error in one call never hides another's value
#   differs ID DRIVER WHY     a probe whose outcome the conversion changes on
#                             purpose, outside every caller's domain (WHY
#                             names the contract change): it must DIFFER, and
#                             both outcomes are printed -- an intended
#                             difference is shown, never hidden
#
# Output: one line per probe, the outcome shown once when identical; exit
# status 1 on any unexpected difference (or an expected one that vanished).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set before ""
set after $root
set only *
set backends {interp compile cranelift-generic cranelift}
foreach {option value} $argv {
    switch -- $option {
        -before { set before $value }
        -after { set after [file normalize $value] }
        -only { set only $value }
        -backends { set backends $value }
        default { error "unknown option $option" }
    }
}
if {$before eq ""} {
    error "usage: probe.tcl -before COMMIT ?-after DIR? ?-only GLOB? ?-backends LIST?"
}
source [file join $root examples stdlib corpus.tcl]

set scratch [file tempdir refactor-probe]
set beforeTree [file join $scratch before]
file mkdir $beforeTree
exec git -C $root archive $before examples bench lib | tar -x -C $beforeTree
set realLib $::core::libraryDir

proc readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

# DRIVER as the body of a function admitting ERRORS, each handled at top
# level by becoming the String naming it (corpus::handled, for any declared
# error).
proc handled {driver errors} {
    set body [join [lmap line [split $driver \n] {string cat "    " $line}] \n]
    set handlers [join [lmap e $errors {string cat "    on $e:\n        \"$e\""}] \n]
    return "fn probe_case() -> any errors [join $errors {, }]:\n$body\nprobe_outcome = probe_case():\n$handlers\nprobe_outcome"
}

# The HIR of PROGRAM (relative path) of TREE followed by DRIVER, handling
# the declared errors the driver leaves unhandled (one per rejection).
proc probeHir {tree program driver} {
    if {[string match lib/*.bot $program]} {
        set ns [string map {/ ::} [string range [file rootname $program] 4 end]]
        set prefix "import $ns\n"
    } else {
        set prefix "[readText [file join $tree $program]]\n"
    }
    set errors {}
    set ::core::libraryDir [file join $tree lib]
    try {
        while 1 {
            set text [expr {$errors eq {} ? $driver : [handled $driver $errors]}]
            if {![catch {corpus::compile "$prefix$text\n" [file join $tree $program] -warnings off} hir options]} {
                return $hir
            }
            if {[dict get $options -errorcode] ne {CORE SEMANTIC UNHANDLED-ERROR}
                    || ![regexp {declared error "([A-Za-z_][A-Za-z0-9_]*)"} $hir -> error]
                    || $error in $errors} {
                return -options $options $hir
            }
            lappend errors $error
        }
    } finally {
        set ::core::libraryDir $::realLib
    }
}

proc outcomes {tree program driver} {
    global backends
    if {[catch {probeHir $tree $program $driver} hir options]} {
        return [lrepeat [llength $backends] [list rejected [dict get $options -errorcode]]]
    }
    set ::core::libraryDir [file join $tree lib]
    try {
        return [lmap backend $backends {outcome $backend $hir}]
    } finally {
        set ::core::libraryDir $::realLib
    }
}

# {value SHOWN} or {error ERRORCODE} of running HIR on BACKEND
# (corpus::run), with corpus::outcome's stand-in: cranelift-generic has no
# slot for a struct projection only a semantic instance proves, so such a
# program's generic run is the specialized one.
proc outcome {backend hir} {
    if {[catch {corpus::run $backend $hir} value options]} {
        if {$backend eq "cranelift-generic" && [dict get $options -errorcode] eq "NATIVE UNSUPPORTED struct-shape"} {
            return [outcome cranelift $hir]
        }
        return [list error [dict get $options -errorcode]]
    }
    return [list value [core::value::show $value 1]]
}

# ---------------------------------------------------------------------------

set probes {}
namespace eval probefile {}
proc probefile::program {path} {
    set ::probeProgram $path
}
proc probefile::probe {id driver} {
    lappend ::probes [list $::probeProgram $id $driver ""]
}
proc probefile::each {id drivers} {
    set i 0
    foreach driver $drivers {
        lappend ::probes [list $::probeProgram $id-[incr i] $driver ""]
    }
}
proc probefile::differs {id driver why} {
    lappend ::probes [list $::probeProgram $id $driver $why]
}
foreach file [lsort [glob -directory [file join $here probes] *.tcl]] {
    set ::probeProgram ""
    namespace eval probefile [list source -encoding utf-8 $file]
}

puts "# Behavior probes: before [exec git -C $root rev-parse --short $before], after $after"
puts "# backends: [join $backends {, }]"
puts ""
set failures 0
set count 0
set perProgram [dict create]
set intended 0
foreach entry $probes {
    lassign $entry program id driver why
    if {![string match $only $program]} continue
    incr count
    dict incr perProgram $program
    set old [outcomes $beforeTree $program $driver]
    set new [outcomes $after $program $driver]
    if {$why ne ""} {
        if {$old eq $new} {
            incr failures
            puts "SAME  $program $id: an intended difference ($why) did not occur"
        } else {
            incr intended
            puts "INTENDED $program $id ($why)"
            puts "        before [string range [lsort -unique $old] 0 200]"
            puts "        after  [string range [lsort -unique $new] 0 200]"
        }
        continue
    }
    if {$old eq $new} {
        set shown [lsort -unique $old]
        puts "same  $program $id: [join [lmap o $shown {string range [join $o { }] 0 160}] { | }]"
    } else {
        incr failures
        puts "DIFF  $program $id"
        foreach backend $backends o $old n $new {
            if {$o ne $n} {
                puts "        $backend: before [string range $o 0 200]"
                puts "        $backend: after  [string range $n 0 200]"
            }
        }
    }
}
puts ""
dict for {program n} $perProgram {
    puts "  $n probes: $program"
}
puts "probes: $count; intended contract changes: $intended; unexpected differences: $failures"
file delete -force $scratch
exit [expr {$failures > 0}]
