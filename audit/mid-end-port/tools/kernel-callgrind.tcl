# kernel-callgrind.tcl -- where the native kernel's instructions go
# (audit/mid-end-port/README.md, section 2):
#
#   tclsh9.0 audit/mid-end-port/tools/kernel-callgrind.tcl ?-functions 300? ?-depth 7?
#
# Builds kernel/ranges-structs.bot for the size given as a native executable
# in a `file tempdir` directory (removed afterwards), runs it under
# `valgrind --tool=callgrind`, and sums the exclusive instruction counts of
# every function (`callgrind_annotate --threshold=100 --auto=no`) into four
# categories: glibc's malloc and free, the runtime's allocation and
# collection, the generated code, everything else. Then the twelve most
# expensive functions. Inclusive counts are not used: inlined pieces of a
# runtime function are listed under several file names.

set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set checkout [file dirname [file dirname $audit]]
set options [dict create -functions 300 -depth 7]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "kernel-callgrind.tcl: unknown option $option" }
    dict set options $option $value
}
set scratch [file tempdir mid-end-callgrind]
try {
    set channel [open [file join $audit kernel ranges-structs.bot]]
    set text [read $channel]
    close $channel
    regsub {\nrun\(\d+, \d+\):} $text "\nrun([dict get $options -functions], [dict get $options -depth]):" text
    set source [file join $scratch ranges-structs.bot]
    set channel [open $source w]
    puts -nonewline $channel $text
    close $channel
    exec [info nameofexecutable] [file join $checkout main.tcl] -warnings off -emit-native-executable $source
    set out [file join $scratch cg.out]
    # The program writes nothing; valgrind reports on standard error.
    exec valgrind --tool=callgrind --callgrind-out-file=$out [file rootname $source] 2>@1
    set rows {}
    set program ""
    foreach line [split [exec callgrind_annotate --threshold=100 --auto=no $out] \n] {
        if {![regexp {^\s*([\d,]+)\s+\(\s*[\d.]+%\)\s+(.*)$} $line -> count name]} continue
        set count [string map {, ""} $count]
        if {[string match "*PROGRAM TOTALS*" $name]} { set program $count; continue }
        if {[string match "=>*" $name] || [string match "*events annotated*" $name]} continue
        lappend rows [list $count $name]
    }
    set total 0
    set sums [dict create]
    foreach row $rows {
        lassign $row count name
        incr total $count
        if {[regexp {malloc/\./malloc/(malloc|arena)\.c} $name]} {
            set category "glibc malloc and free"
        } elseif {[regexp {heap\.rs|::collect|collect_with|new_struct|rt_struct_new|free_object|object_size|framewalk|framemap} $name]} {
            set category "the runtime's allocation and collection (vm.rs, heap.rs, ops.rs, the frame walk)"
        } elseif {[string match *botlish_fn_* $name]} {
            set category "generated code (botlish_fn_N)"
        } else {
            set category "everything else (runtime helpers, start-up)"
        }
        dict incr sums $category $count
    }
    puts "# kernel/ranges-structs.bot with run([dict get $options -functions], [dict get $options -depth]) as a native executable"
    puts "# under valgrind --tool=callgrind; exclusive instruction counts of every function"
    puts "# (callgrind_annotate --threshold=100 --auto=no), summed by category."
    puts "# audit/mid-end-port/README.md, section 2; tools/kernel-callgrind.tcl."
    puts "# $total instructions in the functions listed; PROGRAM TOTALS $program"
    foreach {category count} [lsort -stride 2 -index 1 -integer -decreasing $sums] {
        puts [format "%5.1f%%  %s" [expr {100.0 * $count / $total}] $category]
    }
    puts ""
    puts "# The 12 most expensive functions (exclusive):"
    foreach row [lrange [lsort -index 0 -integer -decreasing $rows] 0 11] {
        lassign $row count name
        regsub {/rustc/[0-9a-f]+/library/} $name {rust:} name
        set name [string map [list $checkout/ ""] $name]
        regsub {\s*\[[^\]]*\]$} $name {} name
        puts [format "%5.1f%%  %s" [expr {100.0 * $count / $total}] [string range $name 0 109]]
    }
} finally {
    file delete -force $scratch
}
