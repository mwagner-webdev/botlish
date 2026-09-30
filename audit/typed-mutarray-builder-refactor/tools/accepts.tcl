set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set hir::semantic::enabled [lindex $argv 1]
if {[catch {surface::readProgramFile [file join $root examples stdlib [lindex $argv 0].bot]} m]} { puts "REJECTED: [string range [regsub -all $root $m {}] 0 260]" } else { puts accepted }
