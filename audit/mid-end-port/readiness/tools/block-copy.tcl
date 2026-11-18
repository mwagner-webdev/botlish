# block-copy.tcl -- the reduced reproducer of hir::types::Block's inherited
# context (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 10): a
# body's context starts from the creating context's `types`
# (`dict set ctx types [dict get $outer types]`, hir/types.tcl) and its
# first write -- the function's own binding, or a parameter's declared
# type -- copies that dict, Tcl's copy-on-write of a shared value. This
# times that one operation for dicts of N entries shaped like binding
# types, so its share of Block can be bounded without changing the
# compiler.
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/block-copy.tcl ?N ...?
#
# Prints `N entries: COPY us per body`.
set sizes [expr {$argc ? $argv : {227 399 743 1487 2970}}]
foreach n $sizes {
    set outer [dict create types [dict create] facts [dict create] implies [dict create]]
    for {set i 0} {$i < $n} {incr i} {
        dict set outer types b$i [list nstruct pass_[expr {$i % 64}]::Info {}]
    }
    set rounds 2000
    set t0 [clock microseconds]
    for {set r 0} {$r < $rounds} {incr r} {
        set ctx [dict create]
        dict set ctx types [dict get $outer types]
        dict set ctx types self [list block e$r 1 int]
        unset ctx
    }
    set us [expr {double([clock microseconds] - $t0) / $rounds}]
    puts [format "%5d entries: %.1f us per body" $n $us]
}
