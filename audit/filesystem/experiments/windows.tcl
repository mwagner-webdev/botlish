#!/usr/bin/env tclsh9.0
# windows.tcl -- the path-representation experiment on a real Windows NTFS
# directory (WINDOWS-X86-64-MILESTONE-7.md, sections 3 and 4).
#
#   tclsh9.0 audit/filesystem/experiments/windows.tcl ?-backend B?
#
# Runs windows/designs.bot natively (its C calls make it a linked run) on a
# fresh directory of the user's temporary directory and prints its rows.
# Windows only: the windows-fs-probe workflow runs it on windows-2025. The
# directory is removed afterwards through its \\?\ form (some names the probe
# makes -- "NUL", "verb." -- exist only in that namespace).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set backend cranelift
foreach {option value} $argv {
    switch -- $option {
        -backend { set backend $value }
        default { error "unknown option $option" }
    }
}
set dir [file nativename [file tempdir botlish-fs-experiment-]]
puts "directory: $dir"
set status 0
if {[catch {exec tclsh9.0 [file join $root main.tcl] -warnings off -backend $backend \
        -argv designs -argv $dir [file join $here windows designs.bot] 2>@1} out]} {
    set status 1
}
puts $out
catch {exec cmd /c rmdir /s /q "\\\\?\\$dir"} message
if {[file exists $dir]} {
    puts "cleanup: $message"
}
exit $status
