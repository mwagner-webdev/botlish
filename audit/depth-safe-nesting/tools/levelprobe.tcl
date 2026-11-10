# levelprobe.tcl -- how deep Tcl's frames were where hir::semantic decided
# by them (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md, section 17).
#
#   tclsh9.0 audit/depth-safe-nesting/tools/levelprobe.tcl -root DIR FILE...
#
# Before this milestone hir::semantic::Call declined a semantic instance
# where `[info level]` exceeded 700 and recorded a request as deep at half
# that. This compiles each FILE with the front end of the checkout DIR (the
# revision before the milestone, to measure what the rule saw), recording
# the deepest `[info level]` hir::semantic::Call is entered at, and prints
# one line per FILE: FILE DEEPEST CODE (CODE the compilation's catch code),
# then the deepest of all. Run on this checkout it measures the same place,
# where nothing reads the level any more.

set options [dict create -root ""]
set files {}
while {[llength $argv]} {
    set argv [lassign $argv word]
    if {[dict exists $options $word]} {
        set argv [lassign $argv value]
        dict set options $word $value
    } else {
        lappend files $word
    }
}
set ::dsnFiles [lmap file $files {file normalize $file}]
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
}
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000
set body [info body hir::semantic::Call]
proc hir::semantic::Call [info args hir::semantic::Call] \
    "set ::maxLevel \[expr {max(\$::maxLevel, \[info level\])}\]\n$body"
set deepest 0
foreach file $::dsnFiles {
    set ::maxLevel 0
    set code [catch {surface::readProgramFile $file -warnings off}]
    puts [list $file $::maxLevel $code]
    set deepest [expr {max($deepest, $::maxLevel)}]
}
puts "deepest $deepest"
