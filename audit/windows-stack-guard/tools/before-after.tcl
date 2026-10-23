# before-after.tcl -- what each driver does with an exhausted stack
# (WINDOWS-X86-64-MILESTONE-4.md, sections 1 and 7): the programs of
# audit/windows-stack-guard/programs (their NIR, written by tools/lower.tcl)
# run by every driver named, in the JIT (botlish-native run) and as the
# standalone executable it links (botlish-native executable), each on a
# 16 MiB stack, and how each run ended: its exit status (an NTSTATUS for a
# process Windows ended, in hexadecimal), its last line of standard output
# and of standard error.
#
#   tclsh9.0 audit/windows-stack-guard/tools/before-after.tcl NAME=DRIVER ...
#
# The Windows workflow's roots job runs it with the driver of the revision
# before the milestone and this checkout's ([ci-probes]).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set programs [file join $root audit windows-stack-guard programs]
set work [file tempdir botlish-before-after]

proc lastLine {text} {
    set lines [split [string trim [string map {\r ""} $text]] \n]
    return [lindex $lines end]
}

# {STATUS STDOUT-LAST STDERR-LAST} of running ARGS with BOTLISH_NATIVE_STACK_BYTES set.
proc outcome {args} {
    global work
    set ::env(BOTLISH_NATIVE_STACK_BYTES) 16777216
    set out [file join $work out.txt]
    set err [file join $work err.txt]
    set code [catch {exec {*}$args > $out 2> $err} message options]
    unset ::env(BOTLISH_NATIVE_STACK_BYTES)
    set read {apply {{path} {set f [open $path rb]; set t [read $f]; close $f; return $t}}}
    set stdout [lastLine [{*}$read $out]]
    set stderr [lastLine [{*}$read $err]]
    set status 0
    if {$code} {
        set errorCode [dict get $options -errorcode]
        set status [expr {[lindex $errorCode 0] eq "CHILDSTATUS" ? [lindex $errorCode 2] : $errorCode}]
    }
    if {[string is integer -strict $status] && $status != 0 && $status != 1} {
        set status [format 0x%08x [expr {$status & 0xffffffff}]]
    }
    return [list $status $stdout $stderr]
}

try {
    foreach pair $argv {
        lassign [split $pair =] name driver
        set driver [file normalize $driver]
        puts "== $name: $driver"
        foreach nir [lsort [glob -directory $programs *.nir]] {
            set program [file rootname [file tail $nir]]
            lassign [outcome $driver run $nir] status stdout stderr
            puts [format "  %-18s jit         exit %-10s stdout %s%s" $program $status [list $stdout] [expr {$stderr eq "" ? "" : " stderr [list $stderr]"}]]
            set exe [file join $work $name-$program]
            if {[catch {exec $driver executable $exe $nir} linked]} {
                puts [format "  %-18s executable  not linked: %s" $program [lastLine $linked]]
                continue
            }
            set path [lindex [lsearch -inline -glob [split $linked \n] {*executable*}] end]
            if {![file exists $path]} { set path [expr {[file exists $exe.exe] ? "$exe.exe" : $exe}] }
            lassign [outcome $path] status stdout stderr
            puts [format "  %-18s executable  exit %-10s stdout %s stderr %s" $program $status [list $stdout] [list $stderr]]
        }
    }
} finally {
    file delete -force $work
}
