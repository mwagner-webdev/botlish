# native-app.tcl -- build a census probe that calls C into a private
# application directory and run it on the native backend
# (THREAD-ACTOR-ARCHITECTURE-CENSUS.md). Disposable tooling.
#
#   tclsh9.0 audit/thread-actor/tools/native-app.tcl PROBE-DIR [-backend cranelift] [-gc-stress 1] [-keep 1] [-entry main.bot] [-also MODULE.bot]...
#
# Copies PROBE-DIR's *.bot and *.c into a `file tempdir` directory, builds
# every *.c into native/lib<NAME>.a (NAME: the file's root name), installs
# the Linux event-loop package (tools/event-loop-linux.tcl) and runs the
# entry program with main.tcl. Prints the program's List[str] value one
# element per line.
set root [file normalize [file join [file dirname [info script]] .. .. ..]]
source [file join $root tools event-loop-linux.tcl]
set probe [file normalize [lindex $argv 0]]
set backend cranelift
set stress 0
set keep 0
set entry main.bot
set also {}
foreach {k v} [lrange $argv 1 end] {
    switch -- $k {
        -also { lappend also [file normalize $v] }
        -backend { set backend $v }
        -gc-stress { set stress $v }
        -keep { set keep $v }
        -entry { set entry $v }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
set dir [file tempdir thread-actor-probe]
file mkdir [file join $dir native]
foreach f [concat [glob -nocomplain -directory $probe *.bot] $also] { file copy $f $dir }
eventLoopLinux::install $dir
foreach c [glob -nocomplain -directory $probe *.c] {
    set name [file rootname [file tail $c]]
    set obj [file join $dir native $name.o]
    exec cc -O2 -Wall -Wextra -Werror -fPIC -pthread -I[eventLoopLinux::include] -c $c -o $obj
    exec ar rcs [file join $dir native lib$name.a] $obj
    file delete $obj
}
if {$stress} { set env(BOTLISH_NATIVE_GC_STRESS) 1 }
set t0 [clock milliseconds]
set rc [catch {exec [info nameofexecutable] [file join $root main.tcl] -warnings off -backend $backend [file join $dir $entry] 2>@1} out]
set ms [expr {[clock milliseconds] - $t0}]
set value ""
foreach line [split $out \n] {
    if {[regexp {^\s+value: (.*)$} $line -> v]} { set value $v }
}
if {$value eq ""} {
    puts "NO VALUE (exit $rc, $ms ms):\n[string range $out 0 4000]"
} else {
    foreach {- s} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} $value] { puts $s }
    puts "-- $backend, gc-stress $stress, $ms ms (compile and run)"
}
if {$keep} { puts "kept: $dir" } else { file delete -force $dir }
