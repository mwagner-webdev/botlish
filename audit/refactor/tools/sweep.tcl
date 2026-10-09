# sweep.tcl -- the consolidated warning sweep of the corpus
# (REFACTOR-WARNINGS-CLEAN.md). Compiles every corpus program and every
# library module with warnings on (collected, not emitted) and reports every
# warning of every code once, at its anchor, with the programs that observed
# it. It edits nothing.
#
#   tclsh9.0 audit/refactor/tools/sweep.tcl ?-root DIR?
#
# The corpus is the union of the seven warning milestones' audit corpora:
#
#   examples/{stdlib,surface,refinement,io,abi,linux}/*.bot, bench/*.bot,
#   lib/*.bot and lib/*/*.bot, each compiled as an entry program
#   ("standalone"), and a one-line loader program `import NS` / `0` for
#   every library module NS (lib/**/*.bot), the subdirectory modules
#   included -- milestone 7's loader sweep.
#
# Sourced by gate.tcl (which defines ::refactorSweepLibrary first), it only
# defines the refactor::sweep namespace and runs nothing.
#
# -root audits another checkout (a worktree of an earlier commit: swept with
# its own compiler) or a corpus-only tree (a scratch copy of examples/,
# bench/ and lib/: swept with this checkout's compiler).

namespace eval refactor::sweep {
    # Entry programs that are deliberate rejections: compiled, they must
    # fail with exactly this code (examples/surface/09 and 10 test
    # rejection, and are never edited).
    variable rejections {
        examples/surface/09-mutual-recursion.bot {CORE SEMANTIC UNBOUND}
        examples/surface/10-duplicate-binding.bot {CORE SEMANTIC DUPLICATE}
    }
}

proc refactor::sweep::readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

proc refactor::sweep::writeText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
}

# The corpus programs of ROOT, as paths relative to ROOT, in a fixed order.
proc refactor::sweep::programs {root} {
    set programs {}
    foreach dir {examples/stdlib examples/surface examples/refinement examples/io
            examples/abi examples/linux bench lib} {
        foreach path [lsort [glob -nocomplain -directory [file join $root $dir] *.bot]] {
            lappend programs [Rel $root $path]
        }
    }
    foreach path [lsort [glob -nocomplain -directory [file join $root lib] */*.bot]] {
        lappend programs [Rel $root $path]
    }
    return $programs
}

# The library modules of ROOT as namespaces (lib/abi/bytes.bot -> abi::bytes).
proc refactor::sweep::modules {root} {
    set modules {}
    foreach path [lsort [concat [glob -nocomplain -directory [file join $root lib] *.bot] \
            [glob -nocomplain -directory [file join $root lib] */*.bot]]] {
        lappend modules [string map {/ ::} [string range [file rootname [Rel $root $path]] 4 end]]
    }
    return $modules
}

proc refactor::sweep::Rel {root path} {
    set root [file normalize $root]
    set path [file normalize $path]
    if {[string first $root/ $path] == 0} {
        return [string range $path [string length $root/] end]
    }
    return $path
}

# The warnings of HIR as records {CODE LOCATION MESSAGE}, LOCATION a
# root-relative FILE:LINE:COL (the primary anchor), in the framework's order.
proc refactor::sweep::Records {root hir} {
    set records {}
    foreach w [hir::warnings::of $hir] {
        set location [hir::originLocation $hir [dict get $w primary]]
        if {[regexp {^(.*):(\d+):(\d+)$} $location -> file line column]} {
            set location "[Rel $root $file]:$line:$column"
        }
        lappend records [list [dict get $w code] $location [dict get $w message]]
    }
    return $records
}

# The files (root-relative) HIR was compiled from: the entry and every module.
proc refactor::sweep::Files {root hir} {
    set files {}
    dict for {id info} [dict get $hir files] {
        lappend files [Rel $root [dict get $info path]]
    }
    return [lsort -unique $files]
}

# Compiles one program at PATH (absolute) under warning policy MODE.
# Returns {ok WARNINGS FILES} or {failed ERRORCODE MESSAGE}.
proc refactor::sweep::Compile {root path mode} {
    if {[catch {surface::readProgramFile $path -warnings $mode -warning-channel ""} hir options]} {
        return [list failed [dict get $options -errorcode] [string map [list [file normalize $root]/ ""] $hir]]
    }
    return [list ok [Records $root $hir] [Files $root $hir]]
}

# Every compilation of the sweep: a dict from a unit name (a corpus program's
# relative path, or "import NS") to {ok WARNINGS FILES} / {failed CODE MSG}.
# MODE is the warning policy (default collects; error raises the first).
proc refactor::sweep::observe {root {mode default}} {
    set units [dict create]
    foreach program [programs $root] {
        dict set units $program [Compile $root [file join $root $program] $mode]
    }
    set scratch [file tempdir refactor-sweep]
    try {
        foreach ns [modules $root] {
            set path [file join $scratch load-[string map {:: -} $ns].bot]
            writeText $path "import $ns\n0\n"
            dict set units "import $ns" [Compile $root $path $mode]
        }
    } finally {
        file delete -force $scratch
    }
    return $units
}

# The distinct findings of UNITS (observe's result): a dict from
# "CODE LOCATION" to {message M units {UNIT ...}}, a library module's
# finding once whatever loads it.
proc refactor::sweep::findings {units} {
    set findings [dict create]
    dict for {unit outcome} $units {
        if {[lindex $outcome 0] ne "ok"} continue
        foreach record [lindex $outcome 1] {
            lassign $record code location message
            set key [list $code $location]
            if {![dict exists $findings $key]} {
                dict set findings $key [dict create message $message units {}]
            }
            dict with findings $key {
                lappend units $unit
            }
        }
    }
    return $findings
}

# "FILE" of a LOCATION "FILE:LINE:COL".
proc refactor::sweep::fileOf {location} {
    regexp {^(.*):\d+:\d+$} $location -> file
    return $file
}

proc refactor::sweep::Commit {root} {
    if {[catch {exec git -C $root rev-parse HEAD} commit]} {
        return unknown
    }
    set dirty ""
    catch {set dirty [exec git -C $root status --porcelain -- examples bench lib]}
    return [list $commit [expr {$dirty eq "" ? "clean" : "MODIFIED"}]]
}

# The report: compile outcomes, counts per code and per file, every finding.
proc refactor::sweep::report {root} {
    variable rejections
    set units [observe $root]
    set findings [findings $units]
    lassign [Commit $root] commit state
    puts "# Consolidated warning sweep: tclsh9.0 audit/refactor/tools/sweep.tcl"
    puts "# commit $commit (corpus paths $state)"
    puts ""
    set programs [programs $root]
    set compiled 0
    set loaded 0
    set notes {}
    dict for {unit outcome} $units {
        if {[lindex $outcome 0] eq "ok"} {
            if {[string match "import *" $unit]} {incr loaded} else {incr compiled}
            continue
        }
        set code [lindex $outcome 1]
        set why [expr {[dict exists $rejections $unit] && [dict get $rejections $unit] eq $code
            ? "deliberate rejection" : "FAILS"}]
        lappend notes "  $why: $unit ([join $code { }]): [string range [lindex $outcome 2] 0 200]"
    }
    set modules [modules $root]
    puts "## Compilations"
    puts ""
    puts "$compiled of [llength $programs] corpus programs compile standalone with warnings on; $loaded of [llength $modules] library modules load through a one-line program."
    foreach note $notes {
        puts $note
    }
    puts ""
    puts "## Distinct findings: [dict size $findings]"
    puts ""
    set perCode [dict create]
    set perFile [dict create]
    dict for {key info} $findings {
        lassign $key code location
        dict incr perCode $code
        dict incr perFile "[fileOf $location] $code"
    }
    foreach code {SAME-RETURN-VALUE METHOD-ELIGIBLE FIXED-ARITY-LIST-RETURN SAME-FAILURE
            PROVES-NAMING ONE-CHAR-STRING-LITERAL MANY-BOOLEAN-ARGUMENTS} {
        puts [format "  %-26s %4d" $code [expr {[dict exists $perCode $code] ? [dict get $perCode $code] : 0}]]
    }
    puts ""
    puts "## Per file and code"
    puts ""
    foreach key [lsort -dictionary [dict keys $perFile]] {
        puts [format "  %4d  %s" [dict get $perFile $key] $key]
    }
    puts ""
    puts "## Every finding (location, code, message; the units that observed it)"
    puts ""
    foreach key [lsort -dictionary -index 1 [dict keys $findings]] {
        lassign $key code location
        set info [dict get $findings $key]
        set observers [dict get $info units]
        set shown [lrange $observers 0 2]
        if {[llength $observers] > 3} {
            lappend shown "+[expr {[llength $observers] - 3}] more"
        }
        puts "$location $code: [dict get $info message]   ([join $shown {, }])"
    }
}

if {![info exists ::refactorSweepLibrary]} {
    set here [file dirname [file normalize [info script]]]
    set root [file dirname [file dirname [file dirname $here]]]
    while {$argv ne ""} {
        set argv [lassign $argv option]
        switch -- $option {
            -root { set argv [lassign $argv value]; set root [file normalize $value] }
            default { error "unknown option $option" }
        }
    }
    # A full checkout is swept with its own compiler; a corpus-only tree
    # (examples/, bench/, lib/: a scratch copy) with this checkout's.
    if {[file exists [file join $root surface surface.tcl]]} {
        source [file join $root surface surface.tcl]
    } else {
        source [file join [file dirname [file dirname [file dirname $here]]] surface surface.tcl]
        set ::core::libraryDir [file join $root lib]
    }
    refactor::sweep::report $root
}
