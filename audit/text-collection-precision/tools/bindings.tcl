# bindings.tcl -- the binding table of a program, as the compiler service
# analyzes it (matrix.py's second table; LOOP-CLAUSE-BINDING-TYPE-
# CORRECTNESS-MILESTONE-1.md).
#
#   tclsh9.0 audit/text-collection-precision/tools/bindings.tcl FILE.bot
#
# One tab-separated line per binding declared in FILE: its line, its name,
# its kind, the kind of its scope's owner (block, listloop, countloop,
# lockloop, ...), 1 if it is a loop clause binding (hir::loopClauseBindings:
# an element, a counter, a lockstep clause) else 0, its recorded type
# (hir::bindingType), the type the service presents for its declaration
# (service::BindingType, what a hover shows), and the distinct types the
# checker gives its reachable references (joined by " | "). Types as
# hir::types::presented spells them.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root service service.tcl]
interp recursionlimit {} 100000

set path [file normalize [lindex $argv 0]]
set ws [service::workspace -warnings off -cache ""]
set rev [service::analyze $ws $path]
set hir [service::hir $rev]
if {$hir eq ""} {
    puts stderr "no analysis of $path"
    exit 1
}
hir::activate $hir
set refs [dict create]
dict for {e node} [dict get $hir exprs] {
    if {[dict get $node kind] eq "ref" && [dict get $node reachable]} {
        dict lappend refs [dict get $node binding] [hir::types::presented [hir::typeOf $hir $e]]
    }
}
dict for {b binding} [dict get $hir bindings] {
    set origin [dict get $binding origin]
    if {[lindex $origin 0] ne "file" || ![dict exists $hir files [lindex $origin 1]]} continue
    if {[file normalize [dict get $hir files [lindex $origin 1] path]] ne $path} continue
    set owner [dict get $hir scopes [dict get $binding scope] owner]
    set ownerKind -
    set clause 0
    if {$owner ne ""} {
        set ownerKind [dict get $hir exprs $owner kind]
        set clause [expr {$b in [hir::loopClauseBindings [dict get $hir exprs $owner]]}]
    }
    puts [join [list [dict getdef [lrange $origin 2 end] line 0] [hir::semantic::SourceName $hir $b] \
        [dict get $binding kind] $ownerKind $clause [hir::types::presented [hir::bindingType $hir $b]] \
        [hir::types::presented [service::BindingType $hir $b]] \
        [join [lsort -unique [dict getdef $refs $b {}]] " | "]] \t]
}
service::closeWorkspace $ws
