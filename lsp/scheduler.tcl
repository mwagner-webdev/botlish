# scheduler.tcl -- where the language server's analyses run
# (LSP-MILESTONE-1.md, "Scheduling").
#
#   lsp::scheduler::create KIND -workspace WS -deliver CMD ?OPTION...?   => S
#   lsp::scheduler::document S PATH ENTRY   an overlay change ({text T version
#                                           V}, or "" for back to the disk)
#   lsp::scheduler::submit S ROOT ENTRY JOB analyze the program ENTRY for ROOT
#   lsp::scheduler::cancel S ROOT           forget ROOT's queued or running job
#   lsp::scheduler::busy S ROOT             queued, running or ""
#   lsp::scheduler::close S
#
# One interface, two strategies, both running the one analysis there is
# (service::analyze in the server's workspace configuration) and delivering
# its revision as a revision of the server's workspace WS: CMD ROOT JOB
# revision REV, CMD ROOT JOB failed MESSAGE (the analysis raised: its entry
# vanished) or CMD ROOT JOB crashed MESSAGE (the worker died). JOB is the
# server's identity for the request; a ROOT has at most one job queued (a
# newer submission replaces it: an intermediate version is never analyzed
# when a later one is available) and at most one running.
#
#   sync    in the server's own process, on its event loop: the reference
#           design. While an analysis runs nothing else is read; the
#           workspace's overlay is the server's, current when it starts.
#   worker  a persistent worker process (main.tcl -lsp-worker: worker.tcl)
#           that keeps the compiler, its bytecode and its parse cache warm,
#           receives the overlay's changes and analysis requests over a
#           private protocol (below), and answers with the revision as text
#           (service::export), which the server imports (service::import).
#           The server's event loop keeps reading while it works. A newer
#           job for the root whose job is running supersedes it: with
#           -supersede kill (the default) the worker is killed and a fresh
#           one started for the newer job; with -supersede finish the
#           running job completes and the newer one waits. A worker that
#           dies on its own is reported (CMD ... crashed) and replaced when
#           the next job needs one; its partial output is never a result
#           (Content-Length framing: an incomplete message is no message).
#
# The worker protocol (private, versioned): the worker's stdin and stdout,
# Content-Length framed (transport.tcl), each message a UTF-8 Tcl list
# {TYPE BODY}:
#
#   worker -> server  hello {protocol 1 frontEnd FINGERPRINT pid PID}
#                     revision {job J text EXPORT ms ELAPSED}
#                     failed {job J message M}
#   server -> worker  documents {PATH ENTRY ...}   ENTRY {text T version V},
#                                                  or "" for the disk
#                     analyze {job J entry PATH}
#                     exit {}
#
# A worker of another front end (another tree) is refused at its hello.

namespace eval lsp::scheduler {
    variable schedulers [dict create]
    variable next 0
    variable protocol 1
}

proc lsp::scheduler::create {kind args} {
    variable schedulers
    variable next
    set options [dict create -workspace "" -deliver "" -command "" -supersede kill -faults {} -log ""]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "lsp::scheduler::create: unknown option \"$option\""
        }
        dict set options $option $value
    }
    if {$kind ni {sync worker}} {
        error "lsp::scheduler::create: unknown scheduler \"$kind\" (sync or worker)"
    }
    set s sched[incr next]
    dict set schedulers $s [dict create kind $kind options $options queue [dict create] \
        running "" scheduled 0 docs [dict create] sent [dict create] chan "" endpoint "" \
        phase dead pids {} crashes {} restartAt 0]
    return $s
}

proc lsp::scheduler::Get {s key} {
    variable schedulers
    return [dict get $schedulers $s $key]
}

proc lsp::scheduler::Set {s key value} {
    variable schedulers
    dict set schedulers $s $key $value
}

proc lsp::scheduler::Option {s name} {
    variable schedulers
    return [dict get $schedulers $s options $name]
}

proc lsp::scheduler::Log {s message} {
    set log [Option $s -log]
    if {$log ne ""} {
        {*}$log $message
    }
}

proc lsp::scheduler::Deliver {s root job outcome payload} {
    uplevel #0 [list {*}[Option $s -deliver] $root $job $outcome $payload]
}

proc lsp::scheduler::document {s path entry} {
    variable schedulers
    if {$entry eq ""} {
        dict unset schedulers $s docs $path
    } else {
        dict set schedulers $s docs $path $entry
    }
}

proc lsp::scheduler::submit {s root entry job} {
    variable schedulers
    dict set schedulers $s queue $root [dict create entry $entry job $job]
    set running [Get $s running]
    if {[Get $s kind] eq "worker" && $running ne "" && [dict get $running root] eq $root
            && [Option $s -supersede] eq "kill"} {
        lsp::stats::count supersededKilled
        lsp::stats::add supersededMs [expr {[clock milliseconds] - [dict get $running started]}]
        Log $s "analysis job [dict get $running job] superseded by job $job: restarting the worker"
        Kill $s
    }
    Kick $s
}

proc lsp::scheduler::cancel {s root} {
    variable schedulers
    dict unset schedulers $s queue $root
    set running [Get $s running]
    if {$running ne "" && [dict get $running root] eq $root} {
        if {[Get $s kind] eq "worker" && [Option $s -supersede] eq "kill"} {
            Kill $s
            Kick $s
        } else {
            # Its result will be dropped.
            dict set schedulers $s running cancelled 1
        }
    }
}

proc lsp::scheduler::busy {s root} {
    set running [Get $s running]
    if {$running ne "" && [dict get $running root] eq $root && ![dict getdef $running cancelled 0]} {
        return running
    }
    if {[dict exists [Get $s queue] $root]} {
        return queued
    }
    return ""
}

proc lsp::scheduler::close {s} {
    variable schedulers
    if {[Get $s kind] eq "worker" && [Get $s chan] ne ""} {
        if {[Get $s running] ne "" || [Get $s phase] ne "ready"} {
            Kill $s
        } else {
            set chan [Get $s chan]
            catch {
                lsp::transport::send [Get $s endpoint] [encoding convertto utf-8 [list exit {}]]
                lsp::transport::drain [Get $s endpoint]
            }
            lsp::transport::disconnect [Get $s endpoint]
            catch {chan configure $chan -blocking 1}
            catch {::close $chan}
        }
    }
    foreach id [after info] {
        if {[string match "lsp::scheduler::* $s*" [lindex [after info $id] 0]]} {
            after cancel $id
        }
    }
    dict unset schedulers $s
}

# Makes sure the next queued job will run.
proc lsp::scheduler::Kick {s} {
    if {[Get $s scheduled] || [Get $s running] ne "" || [Get $s queue] eq {}} {
        return
    }
    Set $s scheduled 1
    after 0 [list lsp::scheduler::Next $s]
}

proc lsp::scheduler::Next {s} {
    variable schedulers
    if {![dict exists $schedulers $s]} {
        return
    }
    Set $s scheduled 0
    if {[Get $s running] ne "" || [Get $s queue] eq {}} {
        return
    }
    if {[Get $s kind] eq "sync"} {
        RunSync $s
    } else {
        Dispatch $s
    }
}

# The first queued job, removed from the queue: {root R entry E job J}.
proc lsp::scheduler::Pop {s} {
    variable schedulers
    set queue [Get $s queue]
    set root [lindex [dict keys $queue] 0]
    dict unset schedulers $s queue $root
    return [dict merge [dict get $queue $root] [dict create root $root]]
}

# ---------------------------------------------------------------------------
# sync

proc lsp::scheduler::RunSync {s} {
    variable schedulers
    set job [Pop $s]
    dict set job started [clock milliseconds]
    Set $s running $job
    lsp::stats::timed "analysis [file tail [dict get $job entry]]" {
        set delay [dict getdef [Option $s -faults] analysis-delay 0]
        if {$delay > 0} {
            # (Test hook: a slower analysis.)
            after $delay
        }
        set failed [catch {service::analyze [Option $s -workspace] [dict get $job entry] -version [dict get $job job]} rev]
        set ms [expr {[clock milliseconds] - [dict get $job started]}]
        lsp::stats::count analyses
        lsp::stats::add analysisMs $ms
        set running [Get $s running]
        Set $s running ""
        if {[dict getdef $running cancelled 0]} {
            if {!$failed} { service::release $rev }
        } elseif {$failed} {
            Deliver $s [dict get $job root] [dict get $job job] failed $rev
        } else {
            Deliver $s [dict get $job root] [dict get $job job] revision $rev
        }
    }
    if {[dict exists $schedulers $s]} {
        Kick $s
    }
}

# ---------------------------------------------------------------------------
# worker

proc lsp::scheduler::Start {s} {
    variable schedulers
    set now [clock milliseconds]
    # A worker that keeps dying is restarted at most five times a minute.
    set crashes [lmap t [Get $s crashes] {if {$now - $t > 60000} continue; set t}]
    Set $s crashes $crashes
    if {[llength $crashes] >= 5 && $now < [Get $s restartAt]} {
        after [expr {[Get $s restartAt] - $now}] [list lsp::scheduler::Kick $s]
        return 0
    }
    set command [Option $s -command]
    if {[catch {open |[concat $command [list 2>@ stderr]] r+} chan]} {
        Log $s "cannot start the analysis worker ($command): $chan"
        Set $s crashes [concat $crashes [list $now]]
        Set $s restartAt [expr {$now + 5000}]
        after 5000 [list lsp::scheduler::Kick $s]
        return 0
    }
    lsp::stats::count workerStarts
    Set $s chan $chan
    Set $s pids [pid $chan]
    Log $s "analysis worker started (pid [join [pid $chan] ,])"
    Set $s phase starting
    Set $s started $now
    Set $s sent [dict create]
    Set $s endpoint [lsp::transport::connect $chan $chan \
        -message [list lsp::scheduler::FromWorker $s] \
        -problem [list lsp::scheduler::WorkerProblem $s] \
        -eof [list lsp::scheduler::WorkerEnded $s]]
    return 1
}

proc lsp::scheduler::Dispatch {s} {
    variable schedulers
    if {[Get $s chan] eq "" && ![Start $s]} {
        return
    }
    if {[Get $s phase] ne "ready"} {
        # The worker's hello dispatches.
        return
    }
    set job [Pop $s]
    dict set job started [clock milliseconds]
    # The overlay's changes since the worker last heard, then the job: the
    # worker reads its messages in order, so it analyzes exactly the
    # documents the server has now.
    set changes [dict create]
    set docs [Get $s docs]
    dict for {path entry} [Get $s sent] {
        if {![dict exists $docs $path]} {
            dict set changes $path ""
        }
    }
    dict for {path entry} $docs {
        if {[dict getdef [Get $s sent] $path ""] ne [dict get $entry version]} {
            dict set changes $path $entry
        }
    }
    set sent [dict create]
    dict for {path entry} $docs {
        dict set sent $path [dict get $entry version]
    }
    Set $s sent $sent
    Set $s running $job
    Set $s phase busy
    set endpoint [Get $s endpoint]
    if {[catch {
        if {$changes ne {}} {
            lsp::transport::send $endpoint [encoding convertto utf-8 [list documents $changes]]
        }
        lsp::transport::send $endpoint [encoding convertto utf-8 [list analyze [dict create job [dict get $job job] entry [dict get $job entry]]]]
    } message]} {
        WorkerDied $s "cannot write to the analysis worker: $message"
    }
}

proc lsp::scheduler::FromWorker {s bytes} {
    variable schedulers
    variable protocol
    if {![dict exists $schedulers $s]} {
        return
    }
    lsp::stats::timed "worker message" {
        if {[catch {encoding convertfrom -profile strict utf-8 $bytes} text]
                || [catch {llength $text} n] || $n != 2 || [catch {dict size [lindex $text 1]}]} {
            WorkerDied $s "the analysis worker sent a message that is not of its protocol"
            return
        }
        lassign $text type body
        switch -- $type {
            hello {
                if {[dict getdef $body protocol ""] ne $protocol
                        || [dict getdef $body frontEnd ""] ne [hir::interchange::fingerprint]} {
                    Log $s "refusing an analysis worker of another protocol or front end: $body"
                    WorkerDied $s "the analysis worker is another compiler's"
                    return
                }
                lsp::stats::add workerStartMs [expr {[clock milliseconds] - [Get $s started]}]
                Set $s phase ready
                Kick $s
            }
            revision - failed {
                set running [Get $s running]
                if {$running eq "" || [dict getdef $body job ""] ne [dict get $running job]} {
                    WorkerDied $s "the analysis worker answered a job it was not given"
                    return
                }
                Set $s running ""
                Set $s phase ready
                set ms [expr {[clock milliseconds] - [dict get $running started]}]
                lsp::stats::count analyses
                lsp::stats::add analysisMs $ms
                if {[dict getdef $running cancelled 0]} {
                    # (Dropped: its root is gone.)
                } elseif {$type eq "failed"} {
                    Deliver $s [dict get $running root] [dict get $running job] failed [dict get $body message]
                } else {
                    lsp::stats::add workerAnalysisMs [dict getdef $body ms 0]
                    set start [clock microseconds]
                    if {[catch {service::import [Option $s -workspace] [dict get $body text] -version [dict get $running job]} rev]} {
                        Deliver $s [dict get $running root] [dict get $running job] failed "the worker's revision could not be imported: $rev"
                    } else {
                        lsp::stats::add importMs [expr {([clock microseconds] - $start) / 1000.0}]
                        lsp::stats::count importBytes [string length $bytes]
                        Deliver $s [dict get $running root] [dict get $running job] revision $rev
                    }
                }
                if {[dict exists $schedulers $s]} {
                    Kick $s
                }
            }
            default {
                WorkerDied $s "the analysis worker sent an unknown message \"$type\""
            }
        }
    }
}

proc lsp::scheduler::WorkerProblem {s kind detail} {
    WorkerDied $s "the analysis worker's output cannot be read ($kind: $detail)"
}

proc lsp::scheduler::WorkerEnded {s} {
    variable schedulers
    if {![dict exists $schedulers $s]} {
        return
    }
    WorkerDied $s "the analysis worker exited"
}

# The worker died, or must be treated as dead (MESSAGE says why): it is
# reclaimed, its running job is reported crashed, and the next job starts a
# new one.
proc lsp::scheduler::WorkerDied {s message} {
    variable schedulers
    set running [Get $s running]
    lsp::stats::count workerCrashes
    Set $s crashes [concat [Get $s crashes] [list [clock milliseconds]]]
    if {[llength [Get $s crashes]] >= 5} {
        Set $s restartAt [expr {[clock milliseconds] + 5000}]
    }
    # (Killed first: a worker that broke its protocol may still be running,
    # and none is left behind.)
    Kill $s
    Log $s $message
    if {$running ne "" && ![dict getdef $running cancelled 0]} {
        Deliver $s [dict get $running root] [dict get $running job] crashed $message
    }
    if {[dict exists $schedulers $s]} {
        Kick $s
    }
}

# Kills the worker (a superseded or cancelled job) and reclaims it; its
# running job is forgotten.
proc lsp::scheduler::Kill {s} {
    set pids [Get $s pids]
    if {$pids ne {}} {
        if {$::tcl_platform(platform) eq "windows"} {
            foreach p $pids {
                catch {exec taskkill /F /T /PID $p}
            }
        } else {
            catch {exec kill -KILL {*}$pids}
        }
    }
    Reap $s
}

# Forgets the worker's channel and waits for its process (dead, or ending
# now that its input is closed), so none is left behind.
proc lsp::scheduler::Reap {s} {
    set chan [Get $s chan]
    if {[Get $s endpoint] ne ""} {
        lsp::transport::disconnect [Get $s endpoint]
    }
    Set $s chan ""
    Set $s endpoint ""
    Set $s pids {}
    Set $s phase dead
    Set $s running ""
    if {$chan ne ""} {
        catch {chan configure $chan -blocking 1}
        catch {::close $chan}
    }
}
