# run.tcl -- run a census probe program on every backend and require one
# outcome (THREAD-ACTOR-ARCHITECTURE-CENSUS.md). Disposable tooling.
#
#   tclsh9.0 audit/thread-actor/tools/run.tcl [-backends "interp compile cranelift-generic cranelift"] [-show 1] FILE.bot ...
#
# Each FILE is run with main.tcl (-warnings off) once per backend; the
# program's value line must be identical on all of them. -show 1 prints the
# value (a List[str] one element per line). Exits 1 on any disagreement.
set root [file normalize [file join [file dirname [info script]] .. .. ..]]
set backends {interp compile cranelift-generic cranelift}
set show 0
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    switch -- $a {
        -backends { set backends [lindex $argv [incr i]] }
        -show { set show [lindex $argv [incr i]] }
        default { lappend files $a }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
set failed 0
foreach f $files {
    set values {}
    foreach b $backends {
        set t0 [clock milliseconds]
        set rc [catch {exec [info nameofexecutable] [file join $root main.tcl] -warnings off -backend $b $f 2>@1} out]
        set ms [expr {[clock milliseconds] - $t0}]
        set value ""
        foreach line [split $out \n] {
            if {[regexp {^\s+value: (.*)$} $line -> v]} { set value $v }
        }
        if {$value eq ""} {
            set value "NO VALUE: [string range $out 0 2000]"
        }
        dict set values $b $value
        puts [format "%-40s %-18s %6d ms  %s" [file tail $f] $b $ms [string range [lindex [split $value \n] 0] 0 60]]
    }
    set distinct [lsort -unique [dict values $values]]
    if {[llength $distinct] != 1} {
        puts "DISAGREE: $f"
        foreach b $backends { puts "  $b: [string range [dict get $values $b] 0 400]" }
        set failed 1
    } else {
        puts "AGREE: [file tail $f] ([llength $backends] backends)"
        if {$show} {
            foreach {- s} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} [lindex $distinct 0]] {
                puts "  $s"
            }
        }
    }
}
exit $failed
