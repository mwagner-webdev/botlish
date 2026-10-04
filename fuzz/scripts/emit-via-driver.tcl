# emit-via-driver.tcl -- emit one standalone executable through a specific
# botlish-native driver binary (used by build-asan.sh to link against an
# ASan-instrumented runtime without touching any compiler code).
#
#   tclsh9.0 fuzz/scripts/emit-via-driver.tcl SOURCE OUT-BINARY NIR-FILE
#
# Runs the repository's own lowering (native::nir, pure Tcl) and then the
# driver's `executable` command on the NIR text -- exactly what
# native::executable does, minus the readiness gate (callers only pass
# targets that already passed it) and via a chosen driver binary.
set root [file normalize [file join [file dirname [info script]] .. ..]]
if {$argc != 3} {
    puts stderr "usage: emit-via-driver.tcl SOURCE OUT-BINARY NIR-FILE"
    exit 2
}
lassign $argv source destination nirPath
source [file join $root native native.tcl]

set hir ""
switch -- [file extension $source] {
    .bot { set hir [surface::readProgramFile $source -warnings default] }
    .hir { set hir [hir::readFile $source] }
    default { puts stderr "emit-via-driver: expected .bot or .hir: $source"; exit 2 }
}
set nir [native::nir $hir]

set channel [open $nirPath w]
fconfigure $channel -encoding utf-8
puts -nonewline $channel $nir
close $channel

set driver $::env(BOTLISH_ASAN_DRIVER)
set lines [exec $driver executable [file normalize $destination] $nirPath]
foreach line [split $lines \n] {
    if {[string match "error*" $line]} { puts stderr $line; exit 1 }
}
puts "executable: $destination"
