# static-census.tcl -- the compiler's procedures that call themselves and
# carry no guard (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md,
# section 24).
#
#   tclsh9.0 audit/depth-safe-nesting/tools/static-census.tcl ?-out FILE?
#
# Lists, by namespace, every procedure of the compiler (surface, hir,
# native, core's IR check, Tcl compiler and layout codec, the service,
# the language server) whose body names it as a command -- a direct self-call, the
# static over-approximation of recursion -- and that census.tsv does not
# list. Each is recursion over something other than the program's nesting
# (types and declarations, which the lattice and the declaration graph
# bound; the call graph and instance stacks, which their budgets bound;
# values of the service's protocol), or not recursion at all (the name in
# a string or another command's word): census.tcl's trace, which counts
# what is active at once on deep specimens, decides; this lists what to
# look at when a walk is added.

set options [dict create -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "unknown option $option"
    }
    dict set options $option $value
}
set ::dsnOptions $options
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
source [file join $root service service.tcl]
foreach f [lsort [glob -directory [file join $root lsp] *.tcl]] {
    catch {source $f}
}
set options $::dsnOptions

proc AllProcs {ns} {
    set out [info procs ${ns}::*]
    foreach child [namespace children $ns] {
        lappend out {*}[AllProcs $child]
    }
    return $out
}

set listed {}
set f [open [file join $root audit depth-safe-nesting census.tsv] r]
foreach line [split [read $f] \n] {
    if {$line ne "" && [string index $line 0] ne "#"} {
        lappend listed [lindex [split $line \t] 0]
    }
}
close $f

set rows {}
foreach ns {::surface ::hir ::native ::core::compiler ::core::ir ::core::binary ::service ::lsp} {
    foreach p [AllProcs $ns] {
        set tail [namespace tail $p]
        set pattern "(^|\[\\\[\\s\{;\])(\[A-Za-z0-9_:\]*::)?[regsub -all {[][\\$^.*+?(){}|]} $tail {\\&}](\\s|\\\])"
        if {$p ni $listed && [regexp $pattern [info body $p]]} {
            lappend rows $p
        }
    }
}
set counts [dict create]
foreach p $rows {
    dict incr counts [namespace qualifiers $p]
}
set out [expr {[dict get $options -out] eq "" ? "stdout" : [open [dict get $options -out] w]}]
foreach p [lsort $rows] {
    puts $out $p
}
puts $out "# [llength $rows] unguarded self-calling procedures:\
    [join [lmap {ns n} [lsort -stride 2 -index 1 -integer -decreasing $counts] {string cat "$ns $n"}] {, }]"
if {$out ne "stdout"} {
    close $out
}
