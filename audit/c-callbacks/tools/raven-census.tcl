# raven-census.tcl -- Raven's callback-taking functions against
# C-CALLBACK-MILESTONE-1.md's synchronous callbacks.
#
#   tclsh9.0 audit/c-callbacks/tools/raven-census.tcl ?-out FILE?
#
# Reads the committed Raven binding (generated/c/raven/linux-x86_64/raven/,
# RAVEN-BINDINGS.md) -- every `extern c fn` with a std::ffi::c::FnPtr
# parameter, its C prototype (the binding's `# C:` line) and each function
# pointer's signature -- and classifies each function by when and where
# Raven calls what it is given (Raven's documentation, RAVEN-BINDINGS.md
# section 2 and 7.1):
#
#   synchronous   called during the call that receives it, on the calling
#                 thread, not kept: what this milestone runs (a FnPtr
#                 parameter declared noescape)
#   retained      kept by Raven and called later -- during Rdraw_frame or
#                 Rwait_frame, on the UI thread -- until replaced: a
#                 retained registration, which this milestone refuses
#                 (NATIVE CALLBACK INACTIVE; the registration call itself
#                 is a retaining C call, DIRECT)
#   worker        called on Raven's worker threads (or the thread that
#                 raised an error): thread and actor integration
#
# and each signature by what its answer is: `notification` (void: the event
# bridge, packages/raven/native/raven_bridge.c, can record it) or `answer`
# (Raven acts on the returned value: a callback is required), and by whether
# it carries a C float (std::ffi::c::Float: a callback declares RawFloat for
# it, or the binding's representations make it raw -- C-BINDGEN.md).
#
# Writes one TSV row per function (FUNCTION FILE CATEGORY ANSWER FLOAT
# PROTOTYPE) and prints the counts. audit/c-callbacks/raven-callbacks.tsv is
# its committed output (C-CALLBACK-MILESTONE-1.md, section 11).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -out [file join $root audit c-callbacks raven-callbacks.tsv]]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# Raven calls these on worker threads (Rtask_run_async, Rparallel_for's
# ranges, the Vulkan queue lock of its render threads) or on the thread that
# raised an error (Rerror_set_callback): RAVEN-BINDINGS.md, sections 5 and
# 7.1. Every other callback-taking function registers a callback Raven keeps
# and calls on the UI thread during a later frame (its name says set_,
# bind, create, post, open or register: none calls it before returning).
set worker {Rtask_run_async Rparallel_for Rvulkan_set_queue_lock_callbacks Rerror_set_callback}
set synchronous {}

set rows {}
set counts [dict create]
foreach path [lsort [glob [file join $root generated c raven linux-x86_64 raven *.bot]]] {
    set f [open $path r]
    set text [read $f]
    close $f
    # Each declaration: its `# C:` prototype line, then `extern c fn NAME(`
    # and its parameters, through the line that closes them.
    foreach chunk [lrange [split [string map [list "\n# C: " \x01] $text] \x01] 1 end] {
        set prototype [lindex [split $chunk \n] 0]
        if {![regexp {\nextern c fn (\w+)\(} $chunk -> name]} continue
        set params [string range $chunk [string first "extern c fn $name\(" $chunk] end]
        set close [string first "\n)" $params]
        if {$close >= 0} { set params [string range $params 0 $close] }
        if {[string first FnPtr $params] < 0} continue
        set answer notification
        set float 0
        # Each function pointer's signature: from its FnPtr to the closing
        # brace of its Fn type (argument types nest brackets only).
        set at 0
        while {[set at [string first "FnPtr\[Fn\{" $params $at]] >= 0} {
            set end [string first "\}" $params $at]
            set signature [string range $params $at $end]
            set at $end
            regexp {return: ([^\}]*)$} [string range $signature 0 end-1] -> result
            if {[string trim $result] ne "unit"} { set answer answer }
            if {[string first std::ffi::c::Float $signature] >= 0} { set float 1 }
        }
        set category [expr {$name in $worker ? "worker" : ($name in $synchronous ? "synchronous" : "retained")}]
        lappend rows [list $name [file rootname [file tail $path]] $category $answer $float $prototype]
        dict incr counts $category
        dict incr counts "$category/$answer"
        if {$float} { dict incr counts float }
    }
}

set out [open [dict get $options -out] w]
fconfigure $out -translation lf
puts $out [join {function file category answer c_float prototype} \t]
foreach row $rows {
    puts $out [join $row \t]
}
close $out
puts "[llength $rows] callback-taking functions: [dict getdef $counts synchronous 0] synchronous, [dict getdef $counts retained 0] retained ([dict getdef $counts retained/answer 0] needing an answer, [dict getdef $counts retained/notification 0] notifications), [dict getdef $counts worker 0] on worker threads; [dict getdef $counts float 0] with a C float in a callback signature"
