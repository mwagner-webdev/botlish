# lsp-client.tcl -- a language server protocol client for tests and
# benchmarks (LSP-MILESTONE-1.md, "Tests"): it starts the real server,
# `tclsh9.0 main.tcl -lsp`, as a child process and talks to it through real
# pipes, as an editor does.
#
#   lspc::start ?-scheduler S? ?-env {NAME VALUE ...}? ?-args LIST?
#               ?-initialize 0|1? ?-capabilities JSON? ?-options JSON?  => C
#   lspc::raw C BYTES                 write bytes as they are (framing tests)
#   lspc::request C METHOD PARAMS ?-timeout MS?   => the response (JSON)
#   lspc::send C METHOD PARAMS        => ID: a request, not waited for
#   lspc::response C ID ?-timeout MS? => its response
#   lspc::notify C METHOD PARAMS
#   lspc::until C SCRIPT ?-timeout MS?   wait until SCRIPT (caller's) is true
#   lspc::published C URI             the last publishDiagnostics params for
#                                     URI, or ""
#   lspc::stop C                      shutdown, exit; => {status S stderr T}
#   lspc::finish C                    wait for the process to end, without
#                                     shutting it down; => {status S stderr T}
#
# The client uses the repository's own JSON and framing (lsp/json.tcl,
# lsp/transport.tcl) to build and read messages, and records every frame
# the server sent (frames, problems) so a test can check that its stdout
# holds protocol messages and nothing else.

if {[info commands ::lsp::json::parse] eq ""} {
    set lspcRoot [file dirname [file dirname [file normalize [info script]]]]
    source [file join $lspcRoot lsp json.tcl]
    source [file join $lspcRoot lsp transport.tcl]
    source [file join $lspcRoot lsp jsonrpc.tcl]
    source [file join $lspcRoot lsp uri.tcl]
    source [file join $lspcRoot lsp positions.tcl]
    unset lspcRoot
}

namespace eval lspc {
    variable root [file dirname [file dirname [file normalize [info script]]]]
    variable clients [dict create]
    variable next 0
    variable tick 0
}

proc lspc::start {args} {
    variable root
    variable clients
    variable next
    set options [dict create -scheduler worker -env {} -args {} -initialize 1 \
        -capabilities "" -options "" -stderr ""]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "lspc::start: unknown option $option"
        }
        dict set options $option $value
    }
    set c lspc[incr next]
    set stderr [dict get $options -stderr]
    set scratch ""
    if {$stderr eq ""} {
        set scratch [file tempdir lspc]
        set stderr [file join $scratch stderr.txt]
    }
    set command [list [info nameofexecutable] [file join $root main.tcl] -lsp \
        -lsp-scheduler [dict get $options -scheduler] {*}[dict get $options -args]]
    set saved [dict create]
    foreach {name value} [dict get $options -env] {
        if {![dict exists $saved $name]} {
            dict set saved $name [array get ::env $name]
        }
        set ::env($name) $value
    }
    try {
        set chan [open |[concat $command [list 2> $stderr]] r+]
    } finally {
        dict for {name pair} $saved {
            unset -nocomplain ::env($name)
            if {$pair ne ""} {
                set ::env($name) [lindex $pair 1]
            }
        }
    }
    dict set clients $c [dict create chan $chan stderr $stderr next 0 responses [dict create] \
        notifications {} frames 0 problems {} ended 0 pid [pid $chan] scratch $scratch]
    dict set clients $c endpoint [lsp::transport::connect $chan $chan \
        -message [list lspc::Received $c] -problem [list lspc::Problem $c] -eof [list lspc::Ended $c]]
    if {[dict get $options -initialize]} {
        set capabilities [dict get $options -capabilities]
        if {$capabilities eq ""} {
            set capabilities [lsp::json::obj]
        }
        set params [lsp::json::obj processId [lsp::json::int [pid]] rootUri {null {}} capabilities $capabilities]
        if {[dict get $options -options] ne ""} {
            lset params 1 [dict replace [lindex $params 1] initializationOptions [dict get $options -options]]
        }
        set response [request $c initialize $params]
        if {[lsp::json::has $response error]} {
            error "lspc::start: initialize failed: [lsp::json::write $response]"
        }
        dict set clients $c initialize $response
        notify $c initialized [lsp::json::obj]
    }
    return $c
}

proc lspc::Get {c key} {
    variable clients
    return [dict get $clients $c $key]
}

proc lspc::Received {c bytes} {
    variable clients
    variable tick
    dict set clients $c frames [expr {[dict get $clients $c frames] + 1}]
    set message [lsp::json::decode $bytes]
    if {[lsp::json::has $message method]} {
        dict set clients $c notifications [linsert [dict get $clients $c notifications] end $message]
    } else {
        set id [lsp::json::get $message id]
        dict set clients $c responses $id $message
    }
    incr tick
}

proc lspc::Problem {c kind detail} {
    variable clients
    variable tick
    dict set clients $c problems [linsert [dict get $clients $c problems] end [list $kind $detail]]
    incr tick
}

proc lspc::Ended {c} {
    variable clients
    variable tick
    dict set clients $c ended 1
    incr tick
}

proc lspc::raw {c bytes} {
    set chan [Get $c chan]
    puts -nonewline $chan $bytes
    flush $chan
}

proc lspc::Write {c message} {
    lsp::transport::send [Get $c endpoint] [lsp::json::encode $message]
}

proc lspc::send {c method params} {
    variable clients
    dict set clients $c next [expr {[dict get $clients $c next] + 1}]
    set id [lsp::json::int [dict get $clients $c next]]
    Write $c [lsp::json::obj jsonrpc {str 2.0} id $id method [lsp::json::str $method] params $params]
    return $id
}

proc lspc::notify {c method params} {
    Write $c [lsp::json::obj jsonrpc {str 2.0} method [lsp::json::str $method] params $params]
}

proc lspc::response {c id args} {
    variable clients
    set timeout [dict getdef $args -timeout 60000]
    until $c {[dict exists $::lspc::clients $c responses $id] || [dict get $::lspc::clients $c ended]} -timeout $timeout
    if {![dict exists $clients $c responses $id]} {
        error "lspc: no response to request [lsp::json::write $id]"
    }
    set response [dict get $clients $c responses $id]
    dict unset clients $c responses $id
    return $response
}

proc lspc::request {c method params args} {
    return [response $c [send $c $method $params] {*}$args]
}

# Waits, running the event loop, until SCRIPT (evaluated in the caller) is
# true; an error after -timeout milliseconds (default 60 s).
proc lspc::until {c script args} {
    variable tick
    set timeout [dict getdef $args -timeout 60000]
    set deadline [expr {[clock milliseconds] + $timeout}]
    while {![uplevel 1 [list expr $script]]} {
        set left [expr {$deadline - [clock milliseconds]}]
        if {$left <= 0} {
            error "lspc: timed out waiting for $script"
        }
        set timer [after [expr {min($left, 50)}] [list incr ::lspc::tick]]
        vwait ::lspc::tick
        after cancel $timer
    }
}

proc lspc::published {c uri} {
    set last ""
    foreach message [Get $c notifications] {
        if {[lsp::json::get $message method] eq {str textDocument/publishDiagnostics}} {
            set params [lsp::json::get $message params]
            if {[lsp::json::get $params uri] eq [list str $uri]} {
                set last $params
            }
        }
    }
    return $last
}

# The notifications of method METHOD received so far.
proc lspc::notifications {c method} {
    return [lmap message [Get $c notifications] {
        if {[lsp::json::get $message method] ne [list str $method]} continue
        lsp::json::get $message params
    }]
}

proc lspc::stop {c} {
    set response [request $c shutdown {null {}}]
    notify $c exit {null {}}
    set result [finish $c]
    dict set result shutdown $response
    return $result
}

proc lspc::finish {c args} {
    variable clients
    set timeout [dict getdef $args -timeout 60000]
    catch {until $c {[dict get $::lspc::clients $c ended]} -timeout $timeout}
    set chan [Get $c chan]
    lsp::transport::disconnect [Get $c endpoint]
    set status 0
    if {![dict get $clients $c ended]} {
        # Still running: it is killed (the test fails on its status).
        kill $c
        set status killed
    }
    chan configure $chan -blocking 1
    if {[catch {close $chan} message options]} {
        set code [dict get $options -errorcode]
        if {[lindex $code 0] eq "CHILDSTATUS"} {
            set status [lindex $code 2]
        } elseif {[lindex $code 0] eq "CHILDKILLED"} {
            set status killed
        }
    }
    set stderr ""
    catch {
        set f [open [Get $c stderr]]
        fconfigure $f -encoding utf-8
        set stderr [read $f]
        close $f
    }
    set result [dict create status $status stderr $stderr frames [Get $c frames] problems [Get $c problems]]
    if {[Get $c scratch] ne ""} {
        catch {file delete -force [Get $c scratch]}
    }
    dict unset clients $c
    return $result
}

proc lspc::kill {c} {
    foreach p [Get $c pid] {
        if {$::tcl_platform(platform) eq "windows"} {
            catch {exec taskkill /F /T /PID $p}
        } else {
            catch {exec kill -KILL $p}
        }
    }
}

# ---------------------------------------------------------------------------
# Building messages

proc lspc::Position {line character} {
    return [lsp::json::obj line [lsp::json::int $line] character [lsp::json::int $character]]
}

proc lspc::didOpen {c uri text {version 1}} {
    notify $c textDocument/didOpen [lsp::json::obj textDocument [lsp::json::obj uri [lsp::json::str $uri] \
        languageId {str botlish} version [lsp::json::int $version] text [lsp::json::str $text]]]
}

proc lspc::didChange {c uri version text} {
    notify $c textDocument/didChange [lsp::json::obj \
        textDocument [lsp::json::obj uri [lsp::json::str $uri] version [lsp::json::int $version]] \
        contentChanges [lsp::json::arr [lsp::json::obj text [lsp::json::str $text]]]]
}

proc lspc::didClose {c uri} {
    notify $c textDocument/didClose [lsp::json::obj textDocument [lsp::json::obj uri [lsp::json::str $uri]]]
}

proc lspc::didSave {c uri} {
    notify $c textDocument/didSave [lsp::json::obj textDocument [lsp::json::obj uri [lsp::json::str $uri]]]
}

# The params of a position request.
proc lspc::at {uri line character args} {
    set params [dict create textDocument [lsp::json::obj uri [lsp::json::str $uri]] position [Position $line $character]]
    foreach {key value} $args {
        dict set params $key $value
    }
    return [list obj $params]
}

proc lspc::hover {c uri line character args} {
    return [request $c textDocument/hover [at $uri $line $character] {*}$args]
}

proc lspc::definition {c uri line character args} {
    return [request $c textDocument/definition [at $uri $line $character] {*}$args]
}

proc lspc::references {c uri line character {declaration 0} args} {
    return [request $c textDocument/references [at $uri $line $character \
        context [lsp::json::obj includeDeclaration [lsp::json::bool $declaration]]] {*}$args]
}

# The file: URI of PATH.
proc lspc::uri {path} {
    return [lsp::uri::fromPath [file normalize $path]]
}
