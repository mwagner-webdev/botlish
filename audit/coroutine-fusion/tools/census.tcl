# census.tcl -- what coroutine fusion did over whole test runs
# (COROUTINE-FUSION-MILESTONE-1.md, "Fallback behavior").
#
#   tclsh9.0 audit/coroutine-fusion/tools/census.tcl -run COMMAND...
#   tclsh9.0 audit/coroutine-fusion/tools/census.tcl LOG...
#
# -run runs COMMAND (for example `tclsh9.0 tests/coroutines.test -tmpdir
# DIR`) with BOTLISH_NATIVE_COROUTINE_FUSION_LOG set to a private file, so
# every program the native driver loads appends its fusion report (the
# driver's `fusion` lines), then summarizes that file; otherwise it
# summarizes the given log files. The summary counts the construction sites
# fused and kept -- every native compilation counts, so a program compiled
# for two native backends counts twice -- and the kept sites by reason, with
# register and function numbers erased.

proc summarize {paths} {
    set fused 0
    set kept 0
    set reasons [dict create]
    set unboxed 0
    foreach path $paths {
        set f [open $path r]
        fconfigure $f -encoding utf-8
        foreach line [split [read $f] \n] {
            if {$line eq ""} continue
            switch -- [lindex $line 0] {
                fused {
                    incr fused
                    if {[dict getdef [lindex $line 3] unboxed 0] > 0} {
                        incr unboxed
                    }
                }
                kept {
                    incr kept
                    set reason [lindex $line 3]
                    regsub -all {%[0-9]+} $reason %N reason
                    regsub -all {(call|callenv|callmulti) [0-9]+} $reason {\1 F} reason
                    regsub -all {#[0-9]+} $reason #T reason
                    dict incr reasons $reason
                }
            }
        }
        close $f
    }
    puts "sites fused $fused (with scalar transport $unboxed), kept $kept"
    foreach {reason count} [lsort -stride 2 -index 1 -integer -decreasing $reasons] {
        puts [format "%6d  %s" $count $reason]
    }
}

if {[lindex $argv 0] eq "-run"} {
    set log [file join [file tempdir botlish-fusion-census] fusion.log]
    set ::env(BOTLISH_NATIVE_COROUTINE_FUSION_LOG) $log
    catch {exec {*}[lrange $argv 1 end] >@stdout 2>@stderr}
    if {[file exists $log]} {
        summarize [list $log]
    } else {
        puts "no construction site was compiled"
    }
    file delete -force [file dirname $log]
} else {
    summarize $argv
}
