# stats.tcl -- the language server's own measurements (LSP-MILESTONE-1.md,
# "Performance").
#
#   lsp::stats::timed WHAT SCRIPT     SCRIPT, timed as one event-loop callback
#   lsp::stats::count KEY ?N?         a counter
#   lsp::stats::add KEY MS            a total of milliseconds
#   lsp::stats::report                everything, as a dict
#   lsp::stats::write PATH            the report, to PATH
#
# Every callback of the event loop that does work -- a message, a timer, an
# analysis, a worker's result -- runs inside `timed`, so the longest time the
# loop was unable to read a message is measured where it happens, by the
# server itself. bench/lsp.tcl reads the report a server writes when it exits
# with BOTLISH_LSP_STATS=PATH in its environment; nothing is written
# otherwise.

namespace eval lsp::stats {
    variable counters [dict create]
    variable totals [dict create]
    # The longest callbacks, longest first: {MS WHAT} each (at most 8).
    variable longest {}
    variable depth 0
}

proc lsp::stats::timed {what script} {
    variable longest
    variable depth
    incr depth
    set start [clock microseconds]
    try {
        return [uplevel 1 $script]
    } finally {
        incr depth -1
        # Nested callbacks (a delivery inside a timed message) count once,
        # as part of the outermost.
        if {$depth == 0} {
            set ms [expr {([clock microseconds] - $start) / 1000.0}]
            if {[llength $longest] < 8 || $ms > [lindex $longest end 0]} {
                lappend longest [list $ms $what]
                set longest [lrange [lsort -real -decreasing -index 0 $longest] 0 7]
            }
            add callbacks $ms
            count callbacks
        }
    }
}

proc lsp::stats::count {key {n 1}} {
    variable counters
    dict incr counters $key $n
}

proc lsp::stats::add {key ms} {
    variable totals
    dict set totals $key [expr {[dict getdef $totals $key 0] + $ms}]
}

proc lsp::stats::report {} {
    variable counters
    variable totals
    variable longest
    return [dict create counters $counters totals $totals longest $longest]
}

proc lsp::stats::write {path} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts $channel [report]
    close $channel
}
