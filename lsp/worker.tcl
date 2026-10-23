# worker.tcl -- the language server's analysis worker (LSP-MILESTONE-1.md,
# "Scheduling"): main.tcl -lsp-worker.
#
#   lsp::worker::main ?-warnings MODE? ?-target T?
#
# A persistent process the server starts (scheduler.tcl's worker strategy)
# and talks to over its stdin and stdout with the private protocol
# scheduler.tcl describes. It keeps one compiler-service workspace whose
# overlay mirrors the server's documents, analyzes the entry programs it is
# asked to (service::analyze: the one analysis), and answers with each
# revision as text (service::export, with the query indexes of the open
# documents), releasing it at once: it holds no
# revision between jobs, only what the compiler keeps warm (its bytecode,
# the loader's bounded parse cache). It exits when its input ends or it is
# told to; it writes nothing to stdout but protocol messages, and logs on
# stderr.
#
# Test hooks (BOTLISH_LSP_FAULT in its environment, comma-separated; never
# reachable from the protocol): analysis-delay=MS sleeps before each
# analysis (a slow analysis); crash-marker=TEXT makes an analysis of a
# program while any document holds TEXT write half a message and exit (a
# worker dying mid-answer).

namespace eval lsp::worker {
    variable workspace ""
    variable endpoint ""
    variable faults [dict create]
}

proc lsp::worker::main {args} {
    variable workspace
    variable endpoint
    variable faults
    set options [dict create -warnings [hir::warnings::defaultMode] -target ""]
    foreach {option value} $args {
        dict set options $option $value
    }
    set faults [lsp::server::Faults]
    set workspace [service::workspace -warnings [dict get $options -warnings] -target [dict get $options -target]]
    interp bgerror {} lsp::worker::BackgroundError
    set endpoint [lsp::transport::connect stdin stdout -message lsp::worker::Message \
        -problem lsp::worker::Problem -eof lsp::worker::Ended]
    Send hello [dict create protocol $::lsp::scheduler::protocol frontEnd [hir::interchange::fingerprint] pid [pid]]
    vwait forever
}

proc lsp::worker::Send {type body} {
    variable endpoint
    lsp::transport::send $endpoint [encoding convertto utf-8 [list $type $body]]
}

# Answers one message. A failure of its own (never a diagnostic of a
# program, which an analysis reports as data) ends the worker: the server
# sees it die and replaces it, rather than waiting for an answer that
# would never come.
proc lsp::worker::Message {bytes} {
    if {[catch {Handle $bytes} message options]} {
        puts stderr "botlish lsp worker: internal error: [dict get $options -errorinfo]"
        Leave 2
    }
}

proc lsp::worker::Handle {bytes} {
    variable workspace
    variable faults
    set message [encoding convertfrom utf-8 $bytes]
    lassign $message type body
    switch -- $type {
        documents {
            dict for {path entry} $body {
                if {$entry eq ""} {
                    service::clearDocument $workspace $path
                } else {
                    service::setDocument $workspace $path [dict get $entry text] -version [dict get $entry version]
                }
            }
        }
        analyze {
            set job [dict get $body job]
            set delay [dict getdef $faults analysis-delay 0]
            if {$delay > 0} {
                after $delay
            }
            set marker [dict getdef $faults crash-marker ""]
            if {$marker ne ""} {
                dict for {path entry} [service::documents $workspace] {
                    if {[string first $marker [dict getdef $entry text ""]] >= 0} {
                        # Half a message, then death: the server must never take
                        # it for a result.
                        puts -nonewline stdout "Content-Length: 4096\r\n\r\n[list revision [dict create job $job text partial]]"
                        flush stdout
                        exit 3
                    }
                }
            }
            set start [clock milliseconds]
            if {[catch {service::analyze $workspace [dict get $body entry] -version $job} rev]} {
                Send failed [dict create job $job message $rev]
                return
            }
            set analyzed [clock milliseconds]
            try {
                # The query indexes of the documents the editor has open (and
                # the entry), computed here, where the sources are parsed
                # already, and sent with the revision (service::export
                # -derived): the server answers its first query at once.
                service::prepare $rev -paths [concat [list [dict get $body entry]] [dict keys [service::documents $workspace]]] -compilerpedia 0
                set text [service::export $rev -derived 1]
            } finally {
                service::release $rev
            }
            set now [clock milliseconds]
            Send revision [dict create job $job text $text ms [expr {$analyzed - $start}] exportMs [expr {$now - $analyzed}]]
        }
        exit {
            Leave 0
        }
        default {
            puts stderr "botlish lsp worker: unknown message \"$type\""
            Leave 2
        }
    }
}

proc lsp::worker::BackgroundError {message options} {
    puts stderr "botlish lsp worker: internal error: [dict get $options -errorinfo]"
    Leave 2
}

proc lsp::worker::Problem {kind detail} {
    puts stderr "botlish lsp worker: unreadable input ($kind: $detail)"
    Leave 2
}

proc lsp::worker::Ended {} {
    Leave 0
}

proc lsp::worker::Leave {status} {
    variable endpoint
    lsp::transport::drain $endpoint
    exit $status
}
