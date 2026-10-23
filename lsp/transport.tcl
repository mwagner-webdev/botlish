# transport.tcl -- the language server's byte transport: Content-Length
# framing over Tcl channels (LSP-MILESTONE-1.md, "Transport").
#
#   lsp::transport::reader ?-max-header N? ?-max-body N?    a new framing state
#   lsp::transport::feed READERVAR BYTES     the events BYTES complete
#   lsp::transport::finish READERVAR         the events of the end of input
#   lsp::transport::frame BYTES              BYTES framed for sending
#
#   lsp::transport::connect IN OUT -message CMD -problem CMD -eof CMD ?...?
#   lsp::transport::send ENDPOINT BYTES      write one framed message
#   lsp::transport::drain ENDPOINT           block until everything is written
#   lsp::transport::disconnect ENDPOINT      stop reading
#
# The language server protocol frames each message as
#
#   Content-Length: N\r\n
#   ?Content-Type: application/vscode-jsonrpc; charset=utf-8\r\n?
#   \r\n
#   <exactly N bytes>
#
# N counts bytes, never characters. This layer owns only that: it reads and
# writes byte strings and knows nothing of JSON, JSON-RPC or what a message
# means (the private worker protocol uses the same framing for Tcl text).
#
# The framing state is a value, fed byte strings in pieces of any size --
# a header split anywhere, a body split anywhere, several messages in one
# piece -- so it is tested on byte streams alone. Each feed returns the
# events it completed, in order:
#
#   {message BYTES}          a complete message body
#   {oversize N}             a well-framed message too large to accept (more
#                            than -max-body bytes): its N bytes are skipped
#                            as they arrive, never held, and the stream stays
#                            in step
#   {error KIND DETAIL}      the stream cannot be framed any further (KIND:
#                            header-too-large, header-syntax, no-length,
#                            bad-length, contradictory-length, charset,
#                            truncated); every later feed returns nothing
#
# Buffering is bounded: a header is held up to -max-header bytes (8 KiB), a
# body up to -max-body bytes (64 MiB: an editor's message holding a whole,
# large source file fits many times over); nothing else is kept.

namespace eval lsp::transport {
    variable endpoints [dict create]
    variable nextEndpoint 0
}

proc lsp::transport::reader {args} {
    set options [dict create -max-header 8192 -max-body [expr {64 * 1024 * 1024}]]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "lsp::transport::reader: unknown option \"$option\""
        }
        dict set options $option $value
    }
    return [dict create buffer "" state header length 0 skip 0 dead 0 \
        maxHeader [dict get $options -max-header] maxBody [dict get $options -max-body]]
}

# The events the bytes BYTES complete, for the framing state in the caller's
# variable READERVAR (updated).
proc lsp::transport::feed {readerVar bytes} {
    upvar 1 $readerVar reader
    if {[dict get $reader dead]} {
        return {}
    }
    set events {}
    # (The buffer leaves the state while it grows, so appending never
    # copies it.)
    set buffer [dict get $reader buffer]
    dict set reader buffer ""
    append buffer $bytes
    while 1 {
        switch -- [dict get $reader state] {
            header {
                set end [string first "\r\n\r\n" $buffer]
                if {$end < 0} {
                    if {[string length $buffer] > [dict get $reader maxHeader]} {
                        lappend events [Dead reader header-too-large "a header of more than [dict get $reader maxHeader] bytes"]
                        return $events
                    }
                    break
                }
                if {$end > [dict get $reader maxHeader]} {
                    lappend events [Dead reader header-too-large "a header of more than [dict get $reader maxHeader] bytes"]
                    return $events
                }
                set header [string range $buffer 0 [expr {$end - 1}]]
                set buffer [string range $buffer [expr {$end + 4}] end]
                set parsed [ParseHeader $header]
                if {[lindex $parsed 0] eq "error"} {
                    lappend events [Dead reader {*}[lrange $parsed 1 end]]
                    return $events
                }
                set length [lindex $parsed 1]
                if {$length > [dict get $reader maxBody]} {
                    lappend events [list oversize $length]
                    dict set reader state skip
                    dict set reader skip $length
                } else {
                    dict set reader state body
                    dict set reader length $length
                }
            }
            body {
                set length [dict get $reader length]
                if {[string length $buffer] < $length} {
                    break
                }
                lappend events [list message [string range $buffer 0 [expr {$length - 1}]]]
                set buffer [string range $buffer $length end]
                dict set reader state header
            }
            skip {
                set skip [dict get $reader skip]
                set have [string length $buffer]
                if {$have < $skip} {
                    dict set reader skip [expr {$skip - $have}]
                    set buffer ""
                    break
                }
                set buffer [string range $buffer $skip end]
                dict set reader state header
            }
        }
    }
    dict set reader buffer $buffer
    return $events
}

# The events of the end of input for the framing state in READERVAR: none at
# a message boundary, else {error truncated DETAIL}.
proc lsp::transport::finish {readerVar} {
    upvar 1 $readerVar reader
    if {[dict get $reader dead]} {
        return {}
    }
    set state [dict get $reader state]
    set held [string length [dict get $reader buffer]]
    if {$state eq "header" && $held == 0} {
        return {}
    }
    switch -- $state {
        header { set detail "the input ended inside a header ($held bytes)" }
        body   { set detail "the input ended inside a body ($held of [dict get $reader length] bytes)" }
        skip   { set detail "the input ended inside a skipped body" }
    }
    return [list [Dead reader truncated $detail]]
}

proc lsp::transport::Dead {readerVar kind detail} {
    upvar 1 $readerVar reader
    dict set reader dead 1
    dict set reader buffer ""
    return [list error $kind $detail]
}

# The header block HEADER (its lines without the blank line): {length N}, or
# {error KIND DETAIL}. Field names are case-insensitive; fields other than
# Content-Length and Content-Type are ignored, as the protocol allows.
proc lsp::transport::ParseHeader {header} {
    set length ""
    foreach line [split [string map [list \r\n \n] $header] \n] {
        if {![regexp {^([!#$%&'*+.^_`|~0-9A-Za-z-]+):[ \t]*(.*?)[ \t]*$} $line -> name value]} {
            return [list error header-syntax "not a header field: \"[string range $line 0 60]\""]
        }
        switch -- [string tolower $name] {
            content-length {
                if {![regexp {^[0-9]{1,15}$} $value]} {
                    return [list error bad-length "Content-Length \"[string range $value 0 30]\" is not a byte count"]
                }
                scan $value %lld n
                if {$length ne "" && $length != $n} {
                    return [list error contradictory-length "two Content-Length fields, $length and $n"]
                }
                set length $n
            }
            content-type {
                if {[regexp -nocase {;\s*charset\s*=\s*"?([^";\s]+)"?} $value -> charset]
                        && [string tolower $charset] ni {utf-8 utf8}} {
                    return [list error charset "the content is $charset, not UTF-8"]
                }
            }
        }
    }
    if {$length eq ""} {
        return [list error no-length "a header without Content-Length"]
    }
    return [list length $length]
}

# BYTES framed as one message.
proc lsp::transport::frame {bytes} {
    return "Content-Length: [string length $bytes]\r\n\r\n$bytes"
}

# ---------------------------------------------------------------------------
# Channels

# Reads framed messages from the channel IN and writes framed messages to OUT
# (the same channel for a process pipe), both in binary mode, IN nonblocking
# and read by Tcl's event loop as bytes arrive, OUT nonblocking (Tcl writes
# it in the background, in order, without ever blocking the loop). Calls, at
# global level, CMD BYTES for each message (-message), CMD KIND DETAIL for
# an oversize message (KIND oversize) or a framing error (-problem), and
# CMD for the end of input (-eof), after every message before it. -max-header
# and -max-body bound the framing (reader). Returns the endpoint.
proc lsp::transport::connect {in out args} {
    variable endpoints
    variable nextEndpoint
    set options [dict create -message "" -problem "" -eof "" -max-header 8192 \
        -max-body [expr {64 * 1024 * 1024}]]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "lsp::transport::connect: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set endpoint ep[incr nextEndpoint]
    chan configure $in -translation binary -blocking 0
    if {$out ne $in} {
        chan configure $out -translation binary -blocking 0 -buffering full
    } else {
        chan configure $in -buffering full
    }
    dict set endpoints $endpoint [dict create in $in out $out options $options \
        reader [reader -max-header [dict get $options -max-header] -max-body [dict get $options -max-body]]]
    chan event $in readable [list lsp::transport::Readable $endpoint]
    return $endpoint
}

proc lsp::transport::Readable {endpoint} {
    variable endpoints
    if {![dict exists $endpoints $endpoint]} {
        return
    }
    set in [dict get $endpoints $endpoint in]
    if {[catch {read $in} bytes]} {
        set bytes ""
        set ended 1
    } else {
        set ended [eof $in]
    }
    set reader [dict get $endpoints $endpoint reader]
    dict set endpoints $endpoint reader ""
    set events [feed reader $bytes]
    if {$ended} {
        lappend events {*}[finish reader]
        chan event $in readable {}
    }
    dict set endpoints $endpoint reader $reader
    set options [dict get $endpoints $endpoint options]
    foreach event $events {
        if {![dict exists $endpoints $endpoint]} {
            return
        }
        switch -- [lindex $event 0] {
            message {
                Call [dict get $options -message] [lindex $event 1]
            }
            oversize {
                Call [dict get $options -problem] oversize "a message of [lindex $event 1] bytes (at most [dict get $options -max-body])"
            }
            error {
                Call [dict get $options -problem] {*}[lrange $event 1 end]
            }
        }
    }
    if {$ended && [dict exists $endpoints $endpoint]} {
        Call [dict get $options -eof]
    }
}

proc lsp::transport::Call {command args} {
    if {$command ne ""} {
        uplevel #0 [list {*}$command {*}$args]
    }
}

# Writes BYTES to ENDPOINT as one framed message: the header and the body in
# one write, so messages never interleave.
proc lsp::transport::send {endpoint bytes} {
    variable endpoints
    set out [dict get $endpoints $endpoint out]
    puts -nonewline $out [frame $bytes]
    flush $out
}

# Blocks until everything written to ENDPOINT has been written (before the
# process exits).
proc lsp::transport::drain {endpoint} {
    variable endpoints
    if {![dict exists $endpoints $endpoint]} {
        return
    }
    set out [dict get $endpoints $endpoint out]
    catch {
        chan configure $out -blocking 1
        flush $out
    }
}

# Stops reading ENDPOINT and forgets it; its channels stay open (the caller
# owns them).
proc lsp::transport::disconnect {endpoint} {
    variable endpoints
    if {![dict exists $endpoints $endpoint]} {
        return
    }
    catch {chan event [dict get $endpoints $endpoint in] readable {}}
    dict unset endpoints $endpoint
}
