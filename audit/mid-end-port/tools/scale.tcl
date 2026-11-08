# scale.tcl -- the scale experiment's ladder (audit/mid-end-port/README.md,
# "The scale experiment"): generates synth.tcl programs of growing size and
# measures each with measure.tcl in a process of its own, under a time cap.
#
#   tclsh9.0 audit/mid-end-port/tools/scale.tcl -out FILE ?-passes {2 4 8 ...}?
#       ?-handlers F? ?-generic 0|1? ?-untyped PERCENT? ?-cap SECONDS?
#       ?-native 0|1? ?-specialize 0|1? ?-memory-mb MB? ?-seed S?
#       ?-semantic-per-block N?
#
# Appends one line per size to FILE (a Tcl dict per line: the synth options,
# synth's counts and measure.tcl's dict), as each finishes, so a long run
# can be read while it goes. A size that exceeds -cap (default 3600 s; the
# coreutils `timeout` enforces it) is recorded as `outcome timeout`, and one
# that exceeds -memory-mb (default 12288; `ulimit -v`, so Linux only) dies
# where an allocation fails and is recorded as `crashed` with the figures it
# printed before (measure.tcl prints the front end's before the native
# path's). Either ends the ladder: a larger size would only cost more. The
# generated programs live in a `file tempdir` directory removed afterwards.

set here [file dirname [file normalize [info script]]]
set options [dict create -out "" -passes {2 4 8 16 32 64 128} -handlers 40 -generic 1 \
    -untyped 25 -cap 3600 -memory-mb 12288 -native 1 -specialize 1 -seed 1 -kinds 24 -nodes 400 \
    -semantic-per-block ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "scale.tcl: unknown option $option" }
    dict set options $option $value
}
if {[dict get $options -out] eq ""} { error "scale.tcl: -out FILE is required" }
set tclsh [info nameofexecutable]
set scratch [file tempdir mid-end-scale]
try {
    foreach passes [dict get $options -passes] {
        set dir [file join $scratch p$passes]
        set synth [exec $tclsh [file join $here synth.tcl] -out $dir -passes $passes \
            -handlers [dict get $options -handlers] -generic [dict get $options -generic] \
            -untyped [dict get $options -untyped] -seed [dict get $options -seed] \
            -kinds [dict get $options -kinds] -nodes [dict get $options -nodes]]
        set record [dict create passes $passes handlers [dict get $options -handlers] \
            generic [dict get $options -generic] untyped [dict get $options -untyped] {*}$synth]
        if {[dict get $options -semantic-per-block] ne ""} {
            dict set record semanticPerBlock [dict get $options -semantic-per-block]
        }
        set t0 [clock seconds]
        set command [list ulimit -v [expr {[dict get $options -memory-mb] * 1024}] && exec timeout \
            [dict get $options -cap] $tclsh [file join $here measure.tcl] [file join $dir main.bot] \
            -native [dict get $options -native] -specialize [dict get $options -specialize]]
        if {[dict get $options -semantic-per-block] ne ""} {
            lappend command -semantic-per-block [dict get $options -semantic-per-block]
        }
        set code [catch {exec sh -c [join $command " "] 2>@1} output]
        # How the child ended: an exit status or the signal that killed it.
        if {$code == 0} {
            set how "exit 0"
        } elseif {[lindex $::errorCode 0] eq "CHILDSTATUS"} {
            set how "exit [lindex $::errorCode 2]"
        } elseif {[lindex $::errorCode 0] eq "CHILDKILLED"} {
            set how "signal [lindex $::errorCode 2]"
        } else {
            set how "error [lindex $::errorCode 0]"
        }
        set status [expr {$code == 0 ? 0 : [lindex $::errorCode 0] eq "CHILDSTATUS" ? [lindex $::errorCode 2] : -1}]
        set wall [expr {[clock seconds] - $t0}]
        set measured ""
        set stage ""
        foreach line [split $output \n] {
            if {[string is list $line] && [lindex $line 0] in {frontend final} && [llength $line] == 2} {
                lassign $line stage measured
            }
        }
        if {$measured ne ""} {
            set record [dict merge $record $measured]
        }
        if {$status == 124} {
            dict set record outcome [list timeout [dict get $options -cap] after $stage]
        } elseif {$stage ne "final"} {
            set tail [lrange [split [string trim $output] \n] end-2 end]
            # The output's last lines, minus measure.tcl's own records.
            set tail [lmap line $tail {expr {[lindex $line 0] in {frontend final} ? [continue] : $line}}]
            dict set record outcome [list crashed after [expr {$stage eq "" ? "start" : $stage}] $how [string range [join $tail " | "] 0 300]]
        }
        dict set record wall $wall
        set channel [open [dict get $options -out] a]
        puts $channel $record
        close $channel
        puts "passes $passes: [dict getdef $record lines ?] lines, frontend [dict getdef $record frontend -] s, wall $wall s, [dict get $record outcome]"
        if {[lindex [dict get $record outcome] 0] ne "ok"} break
        file delete -force $dir
    }
} finally {
    file delete -force $scratch
}
