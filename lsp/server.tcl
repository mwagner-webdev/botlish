# server.tcl -- Botlish's language server (LSP-MILESTONE-1.md).
#
#   tclsh9.0 main.tcl -lsp ?-lsp-scheduler worker|sync? ?-warnings MODE? ?-target T?
#
#   lsp::server::main ?-scheduler worker|sync? ?-warnings MODE? ?-target T?
#                     ?-command WORKER-COMMAND?
#
# A language server over stdin and stdout (Content-Length framing,
# transport.tcl; JSON-RPC 2.0, jsonrpc.tcl; JSON, json.tcl) whose every
# semantic answer is the compiler service's (service/service.tcl): it adds
# transport, scheduling and presentation, never semantics. stdout carries
# protocol messages only; everything else goes to stderr. It runs no
# program and generates no code.
#
# What it implements (the protocol baseline is LSP 3.18; nothing outside
# the common 3.17 set is needed):
#
#   lifecycle   initialize, initialized, shutdown, exit, $/cancelRequest
#   documents   textDocument/didOpen, didChange (full text), didSave, didClose
#   diagnostics textDocument/publishDiagnostics (pushed)
#   queries     textDocument/hover, textDocument/definition,
#               textDocument/references
#
# Documents. The editor's open documents are the workspace's overlay
# (service::setDocument): their text, never the disk's, is what every
# analysis reads, the server never writes a file, and a closed document is
# the disk's again. A document's version is its LSP version within one
# opening ("G/V": the G-th opening, version V), so a document closed and
# reopened never repeats a version.
#
# Programs. The service analyzes one entry program and the modules it
# loads. Every open document is a candidate entry program, except a
# standard-library module (the library is no program); a candidate that
# another analyzed program reads (imports, directly or not) is that
# program's module, not a program of its own. Among candidates that read
# each other, the one opened first is the program. Every other path --
# every module, open or not -- belongs to the program opened first among
# those that read it: its owner, whose analysis alone publishes its
# diagnostics and answers queries in it (Roots, Owner).
#
# Revisions. Each program keeps its latest revision and its latest one with
# a HIR (when the latest has none: a syntax or loader error). A revision is
# fresh while every source it read is still what the editor and the disk
# hold (Fresh). Only a fresh revision publishes diagnostics: a result whose
# input was superseded never publishes for text it did not analyze. Queries
# prefer a fresh revision; a stale one answers only where the position
# denotes the same text (an unchanged document, or the unchanged part of an
# edited one: Mapping), its hover marked stale, its locations only where
# they still denote the same text in the documents they point into.
#
# Scheduling. A change schedules, after a short debounce, an analysis of
# every program whose sources it changed; the scheduler (scheduler.tcl:
# a persistent worker process, or in this process) runs the latest one per
# program. A query that no revision can answer while an analysis that will
# is pending waits for it (or for its cancellation).

namespace eval lsp::server {
    variable state uninitialized
    variable endpoint ""
    variable workspace ""
    variable scheduler ""
    variable options [dict create]
    # The negotiated position encoding (utf-16 or utf-32) and hover format.
    variable encoding utf-16
    variable markdown 0
    variable debounce 250
    # Open documents: path -> {uri U version V gen G text T normal N}
    variable documents [dict create]
    variable opened 0
    # Programs: path -> {gen G latest REV good REV submitted JOB applied JOB
    # timer AFTER-ID}
    variable roots [dict create]
    # What the server has published: path -> {owner ROOT version V items J}
    variable published [dict create]
    # Requests waiting for an analysis: key -> {id ... method ... ...}
    variable deferred [dict create]
    variable nextDeferred 0
    variable jobs 0
    # Per revision: what its snapshot holds, by normalized path (RevInfo).
    variable revinfo [dict create]
    # Derived caches: line starts, text mappings.
    variable cache [dict create]
    variable status ""
    variable faults [dict create]
    variable held ""
    variable library ""
    variable libraryMap ""
}

# ---------------------------------------------------------------------------
# Running

proc lsp::server::main {args} {
    variable options
    variable workspace
    variable endpoint
    variable status
    variable faults
    variable library
    set options [dict create -scheduler worker -warnings [hir::warnings::defaultMode] -target "" \
        -command "" -supersede kill]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "lsp::server::main: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set faults [Faults]
    set library [file normalize $::core::libraryDir]
    set workspace [service::workspace -warnings [dict get $options -warnings] -target [dict get $options -target]]
    fconfigure stderr -encoding utf-8
    # An error escaping an event-loop callback is the server's own failure:
    # it is logged (stderr only: stdout is the protocol's) and the server
    # goes on.
    interp bgerror {} lsp::server::BackgroundError
    set endpoint [lsp::transport::connect stdin stdout -message lsp::server::Message \
        -problem lsp::server::Problem -eof lsp::server::Ended]
    vwait lsp::server::status
    Cleanup
    if {[info exists ::env(BOTLISH_LSP_STATS)] && $::env(BOTLISH_LSP_STATS) ne ""} {
        catch {lsp::stats::write $::env(BOTLISH_LSP_STATS)}
    }
    lsp::transport::drain $endpoint
    exit $status
}

# The test hooks of BOTLISH_LSP_FAULT (comma-separated NAME=VALUE items):
# analysis-delay=MS, crash-marker=TEXT (worker.tcl), hold-result=1 (the
# first analysis result is delivered after the next one, to exercise the
# ordering guard). Never reachable from the protocol.
proc lsp::server::Faults {} {
    set faults [dict create]
    if {[info exists ::env(BOTLISH_LSP_FAULT)]} {
        foreach item [split $::env(BOTLISH_LSP_FAULT) ,] {
            if {[regexp {^([a-z-]+)=(.*)$} $item -> name value]} {
                dict set faults $name $value
            }
        }
    }
    return $faults
}

proc lsp::server::BackgroundError {message options} {
    Log "internal error: [dict get $options -errorinfo]"
}

proc lsp::server::Log {message} {
    catch {puts stderr "botlish lsp: $message"}
}

# Ends the server with exit status STATUS.
proc lsp::server::Stop {code} {
    variable status
    if {$status eq ""} {
        set status $code
    }
}

proc lsp::server::Cleanup {} {
    variable scheduler
    variable workspace
    variable roots
    variable deferred
    foreach key [dict keys $deferred] {
        after cancel [dict get $deferred $key timer]
    }
    dict for {root record} $roots {
        after cancel [dict get $record timer]
    }
    if {$scheduler ne ""} {
        lsp::scheduler::close $scheduler
        set scheduler ""
    }
    if {$workspace ne ""} {
        service::closeWorkspace $workspace
        set workspace ""
    }
}

proc lsp::server::Send {bytes} {
    variable endpoint
    if {[catch {lsp::transport::send $endpoint $bytes} message]} {
        Log "cannot write to the client: $message"
        Stop 1
    }
}

proc lsp::server::Notify {method params} {
    Send [lsp::rpc::notification $method $params]
}

# ---------------------------------------------------------------------------
# Messages

proc lsp::server::Message {bytes} {
    lsp::stats::timed message {
        set message [lsp::rpc::classify $bytes]
        switch -- [dict get $message kind] {
            parse-error {
                Send [lsp::rpc::failure [lsp::json::null] ParseError [dict get $message problem]]
            }
            invalid {
                Send [lsp::rpc::failure [dict get $message id] InvalidRequest [dict get $message problem]]
            }
            response {
                # The server sends no requests.
            }
            notification {
                lsp::stats::label [dict get $message method]
                Notification [dict get $message method] [dict get $message params]
            }
            request {
                lsp::stats::count "request [dict get $message method]"
                lsp::stats::label [dict get $message method]
                Request [dict get $message id] [dict get $message method] [dict get $message params]
            }
        }
    }
}

proc lsp::server::Problem {kind detail} {
    if {$kind eq "oversize"} {
        # Its id is unknowable; the stream is still in step.
        Log "a message was refused: $detail"
        Send [lsp::rpc::failure [lsp::json::null] InvalidRequest "message refused: $detail"]
        return
    }
    Log "the input cannot be read as LSP messages ($kind: $detail): exiting"
    Stop 1
}

proc lsp::server::Ended {} {
    variable state
    Stop [expr {$state eq "shutdown" ? 0 : 1}]
}

# The request handlers: METHOD -> procedure, called with the request's id
# and params, returning {answer JSON} or {deferred}.
namespace eval lsp::server {
    variable requests [dict create \
        initialize Initialize shutdown Shutdown \
        textDocument/hover Hover textDocument/definition Definition \
        textDocument/references References]
    variable notifications [dict create \
        initialized Initialized exit Exit \$/cancelRequest Cancel \
        textDocument/didOpen DidOpen textDocument/didChange DidChange \
        textDocument/didSave DidSave textDocument/didClose DidClose]
}

proc lsp::server::Request {id method params} {
    variable state
    variable requests
    if {$state eq "uninitialized" && $method ne "initialize"} {
        Send [lsp::rpc::failure $id ServerNotInitialized "the server is not initialized: send initialize first"]
        return
    }
    if {$state eq "shutdown"} {
        Send [lsp::rpc::failure $id InvalidRequest "the server is shut down: it only accepts exit"]
        return
    }
    if {$method eq "initialize" && $state ne "uninitialized"} {
        Send [lsp::rpc::failure $id InvalidRequest "the server is already initialized"]
        return
    }
    if {![dict exists $requests $method]} {
        Send [lsp::rpc::failure $id MethodNotFound "unsupported method \"$method\""]
        return
    }
    if {[catch {[dict get $requests $method] $id $params} result options]} {
        set code [dict get $options -errorcode]
        if {[lrange $code 0 1] eq {LSP RPC}} {
            Send [lsp::rpc::failure $id [lindex $code 2] $result]
        } elseif {[lrange $code 0 1] in {{LSP JSON} {LSP URI}}} {
            Send [lsp::rpc::failure $id InvalidParams $result]
        } else {
            Log "internal error in $method: [dict get $options -errorinfo]"
            Send [lsp::rpc::failure $id InternalError "internal error: $result"]
        }
        return
    }
    if {[lindex $result 0] eq "answer"} {
        Send [lsp::rpc::success $id [lindex $result 1]]
    }
}

proc lsp::server::Notification {method params} {
    variable state
    variable notifications
    if {$method eq "exit"} {
        Exit $params
        return
    }
    if {$state ne "initialized" || ![dict exists $notifications $method]} {
        # Before initialize and after shutdown notifications are dropped, as
        # is every notification this server does not handle.
        return
    }
    if {[catch {[dict get $notifications $method] $params} message options]} {
        if {[lrange [dict get $options -errorcode] 0 1] in {{LSP JSON} {LSP URI}}} {
            Log "$method ignored: $message"
        } else {
            Log "internal error in $method: [dict get $options -errorinfo]"
        }
    }
}

# The params object of a request or notification (an error unless one).
proc lsp::server::Params {params} {
    if {$params eq "" || [lsp::json::type $params] ne "obj"} {
        lsp::rpc::fail InvalidParams "params must be an object"
    }
    return $params
}

# ---------------------------------------------------------------------------
# Lifecycle

proc lsp::server::Initialize {id params} {
    variable state
    variable encoding
    variable markdown
    variable debounce
    variable scheduler
    variable options
    variable workspace
    variable faults
    set params [Params $params]
    set capabilities [lsp::json::get $params capabilities [lsp::json::obj]]
    # Position encodings, in the client's order of preference; UTF-16 when it
    # names none this server implements (every client implements UTF-16).
    set encoding utf-16
    foreach offered [lsp::json::elements [lsp::json::dig $capabilities {general positionEncodings} {arr {}}] positionEncodings] {
        if {[lsp::json::type $offered] eq "str" && [lsp::json::text $offered] in {utf-16 utf-32}} {
            set encoding [lsp::json::text $offered]
            break
        }
    }
    set markdown 0
    foreach format [lsp::json::elements [lsp::json::dig $capabilities {textDocument hover contentFormat} {arr {}}] contentFormat] {
        if {$format eq {str markdown}} {
            set markdown 1
            break
        }
        if {$format eq {str plaintext}} {
            break
        }
    }
    set settings [lsp::json::get $params initializationOptions [lsp::json::obj]]
    if {[lsp::json::has $settings debounce]} {
        set value [lsp::json::integer [lsp::json::get $settings debounce] initializationOptions.debounce]
        if {$value < 0 || $value > 10000} {
            lsp::rpc::fail InvalidParams "initializationOptions.debounce is milliseconds, 0 to 10000"
        }
        set debounce $value
    }
    set command [dict get $options -command]
    if {$command eq ""} {
        set command [WorkerCommand]
    }
    set scheduler [lsp::scheduler::create [dict get $options -scheduler] -workspace $workspace \
        -deliver lsp::server::Deliver -command $command -supersede [dict get $options -supersede] \
        -faults $faults -log lsp::server::Log]
    set state initialized
    # Compilerpedia's catalogue (topics of diagnostics and of library
    # symbols) is loaded now, while the editor is still opening documents,
    # not at the first publication or hover.
    after idle {lsp::stats::timed warm {catch {service::explain [dict create code "" text ""]}}}
    set sync [lsp::json::obj openClose {bool 1} change [lsp::json::int 1] \
        save [lsp::json::obj includeText {bool 0}]]
    set result [lsp::json::obj \
        capabilities [lsp::json::obj positionEncoding [lsp::json::str $encoding] \
            textDocumentSync $sync hoverProvider {bool 1} definitionProvider {bool 1} \
            referencesProvider {bool 1}] \
        serverInfo [lsp::json::obj name {str botlish} version [lsp::json::str [hir::interchange::fingerprint]]]]
    return [list answer $result]
}

# The command that starts an analysis worker: this compiler's own command
# line (the single executable, or tclsh9.0 main.tcl) with -lsp-worker and
# the server's analysis options.
proc lsp::server::WorkerCommand {} {
    variable options
    set command [list [info nameofexecutable]]
    if {![info exists ::single::app]} {
        lappend command [file join $::root main.tcl]
    }
    lappend command -lsp-worker -warnings [dict get $options -warnings]
    if {[dict get $options -target] ne ""} {
        lappend command -target [dict get $options -target]
    }
    return $command
}

proc lsp::server::Initialized {params} {
}

proc lsp::server::Shutdown {id params} {
    variable state
    variable deferred
    # What the server still holds as the session ends: the revisions its
    # programs keep (at most two each), for the measurements.
    lsp::stats::count liveRevisions [dict get [service::state] revisions]
    # Every waiting request is answered first, with what the server knows.
    foreach key [dict keys $deferred] {
        Resolve $key 1
    }
    Cleanup
    set state shutdown
    return [list answer [lsp::json::null]]
}

proc lsp::server::Exit {params} {
    variable state
    Stop [expr {$state eq "shutdown" ? 0 : 1}]
}

proc lsp::server::Cancel {params} {
    variable deferred
    set id [lsp::json::get $params id]
    dict for {key request} $deferred {
        if {[dict get $request id] eq $id} {
            after cancel [dict get $request timer]
            dict unset deferred $key
            Send [lsp::rpc::failure $id RequestCancelled "cancelled"]
            return
        }
    }
    # Answered already, or never seen: nothing to do.
}

# ---------------------------------------------------------------------------
# Paths and URIs

# The path the compiler knows the document URI by (normalized), or
# {LSP URI UNSUPPORTED}.
proc lsp::server::PathOf {uri} {
    set path [file normalize [lsp::uri::toPath $uri]]
    return [Internal $path]
}

# The URI of PATH for the client: the URI it opened the document by, else
# the path's own file: URI.
proc lsp::server::UriOf {path} {
    variable documents
    if {[dict exists $documents $path]} {
        return [dict get $documents $path uri]
    }
    return [lsp::uri::fromPath [External $path]]
}

# Inside the single executable the standard library is in its archive
# (//zipfs:/...), where no editor can open a file. Its modules are copied,
# once per build, to a cache directory, and paths are translated between
# the two at this boundary only (External, Internal).
proc lsp::server::External {path} {
    variable library
    variable libraryMap
    if {![string match //zipfs:* $library] || ![string match $library/* $path]} {
        return $path
    }
    if {$libraryMap eq ""} {
        set libraryMap [ExtractLibrary]
    }
    if {$libraryMap eq "-"} {
        return $path
    }
    return $libraryMap[string range $path [string length $library] end]
}

proc lsp::server::Internal {path} {
    variable library
    variable libraryMap
    if {$libraryMap ne "" && $libraryMap ne "-" && [string match $libraryMap/* $path]} {
        return $library[string range $path [string length $libraryMap] end]
    }
    return $path
}

proc lsp::server::ExtractLibrary {} {
    variable library
    set roots {}
    if {[info commands ::single::CacheRoots] ne ""} {
        set roots [::single::CacheRoots]
    }
    set files [lsort [LibraryFiles $library]]
    set digest {}
    foreach path $files {
        lappend digest [string range $path [string length $library] end] [file size $path]
    }
    set id [format %08x [zlib crc32 [join $digest \n]]]
    foreach root $roots {
        set dir [file join $root stdlib-$id]
        if {![catch {
            foreach path $files {
                set target $dir[string range $path [string length $library] end]
                if {[file isfile $target] && [file size $target] == [file size $path]} continue
                file mkdir [file dirname $target]
                file copy -force $path $target
            }
        }]} {
            return [file normalize $dir]
        }
    }
    Log "the standard library cannot be copied out of the executable: definitions in it have no file"
    return -
}

proc lsp::server::LibraryFiles {dir} {
    set files [glob -nocomplain -directory $dir -types f *.bot]
    foreach sub [glob -nocomplain -directory $dir -types d *] {
        lappend files {*}[LibraryFiles $sub]
    }
    return $files
}

# 1 if PATH is a standard-library module.
proc lsp::server::InLibrary {path} {
    variable library
    return [string match $library/* $path]
}

# ---------------------------------------------------------------------------
# Documents

proc lsp::server::TextDocument {params} {
    return [lsp::json::get [Params $params] textDocument]
}

proc lsp::server::DidOpen {params} {
    variable documents
    variable opened
    set document [TextDocument $params]
    set uri [lsp::json::text [lsp::json::get $document uri] uri]
    set version [lsp::json::integer [lsp::json::get $document version] version]
    set text [lsp::json::text [lsp::json::get $document text] text]
    set path [PathOf $uri]
    SetDocument $path $uri [incr opened] $version $text
    Changed [list $path] 0
}

proc lsp::server::DidChange {params} {
    variable documents
    set document [TextDocument $params]
    set uri [lsp::json::text [lsp::json::get $document uri] uri]
    set version [lsp::json::integer [lsp::json::get $document version] version]
    set path [PathOf $uri]
    if {![dict exists $documents $path]} {
        Log "didChange of $uri, which is not open: ignored"
        return
    }
    set current [dict get $documents $path]
    if {$version <= [dict get $current version]} {
        Log "didChange of $uri to version $version, not after version [dict get $current version]: ignored"
        return
    }
    set text ""
    set full 0
    foreach change [lsp::json::elements [lsp::json::get [Params $params] contentChanges] contentChanges] {
        if {[lsp::json::has $change range]} {
            Log "didChange of $uri with a range edit (this server takes whole texts): ignored"
            return
        }
        set text [lsp::json::text [lsp::json::get $change text] text]
        set full 1
    }
    if {!$full} {
        return
    }
    SetDocument $path [dict get $current uri] [dict get $current gen] $version $text
    Changed [list $path] 1
}

proc lsp::server::DidSave {params} {
    variable roots
    set document [TextDocument $params]
    PathOf [lsp::json::text [lsp::json::get $document uri] uri]
    # The editor's text is unchanged; files other programs read may have
    # changed on disk (a save of another tool, a checkout): every program
    # whose sources the workspace and the disk no longer answer the same for
    # is analyzed again.
    dict for {root record} $roots {
        set latest [dict get $record latest]
        if {$latest ne "" && [service::stale $latest] ne {}} {
            Schedule $root
        }
    }
}

proc lsp::server::DidClose {params} {
    variable documents
    variable workspace
    variable scheduler
    set document [TextDocument $params]
    set path [PathOf [lsp::json::text [lsp::json::get $document uri] uri]]
    if {![dict exists $documents $path]} {
        return
    }
    dict unset documents $path
    service::clearDocument $workspace $path
    lsp::scheduler::document $scheduler $path ""
    Changed [list $path] 1
}

proc lsp::server::SetDocument {path uri gen version text} {
    variable documents
    variable workspace
    variable scheduler
    set normal $text
    if {[string first \r $text] >= 0} {
        set normal [surface::source::normalize $text]
    }
    dict set documents $path [dict create uri $uri version $version gen $gen text $text normal $normal]
    service::setDocument $workspace $path $text -version $gen/$version
    lsp::scheduler::document $scheduler $path [dict create text $text version $gen/$version]
}

# After the documents PATHS changed (opened, edited or closed): the programs
# are what they now are, every program a change concerns is analyzed again
# (after the debounce when DEBOUNCED), and the published diagnostics follow.
proc lsp::server::Changed {paths debounced} {
    variable roots
    set new [UpdateRoots]
    dict for {root record} $roots {
        if {$root in $new} {
            Schedule $root 0
            continue
        }
        set concerned 0
        foreach path $paths {
            if {$path eq $root || [Observes $root $path]} {
                set concerned 1
                break
            }
        }
        if {!$concerned} continue
        set latest [dict get $record latest]
        if {$latest eq "" || ![Fresh $latest]} {
            Schedule $root [expr {$debounced ? "" : 0}]
        }
    }
    Reconcile
}

# ---------------------------------------------------------------------------
# Programs

# The candidate entry programs: open documents outside the standard library,
# in the order they were opened.
proc lsp::server::Candidates {} {
    variable documents
    set candidates {}
    dict for {path document} $documents {
        if {![InLibrary $path]} {
            lappend candidates [list [dict get $document gen] $path]
        }
    }
    return [lmap c [lsort -integer -index 0 $candidates] {lindex $c 1}]
}

# The paths program ROOT's revisions read (its sources), ROOT included.
proc lsp::server::Reads {root} {
    variable roots
    set paths [list $root]
    if {[dict exists $roots $root]} {
        foreach rev [list [dict get $roots $root latest] [dict get $roots $root good]] {
            if {$rev ne ""} {
                lappend paths {*}[dict get [RevInfo $rev] read]
            }
        }
    }
    return [lsort -unique $paths]
}

# 1 if program ROOT's revisions asked about PATH (read it, or found nothing
# there): a change there concerns it.
proc lsp::server::Observes {root path} {
    variable roots
    foreach rev [list [dict get $roots $root latest] [dict get $roots $root good]] {
        if {$rev ne "" && [dict exists [RevInfo $rev] sources $path]} {
            return 1
        }
    }
    return 0
}

# Brings the programs up to date with the documents (the rule in the header):
# each candidate is a program unless another program reads it; among
# programs that read each other, the later opened yields. Programs no
# longer programs are dropped, with their jobs and revisions. Returns the
# new programs.
proc lsp::server::UpdateRoots {} {
    variable roots
    variable documents
    set current [Candidates]
    set changed 1
    while {$changed} {
        set changed 0
        foreach candidate [lreverse $current] {
            foreach other $current {
                if {$other ne $candidate && $candidate in [Reads $other]} {
                    set current [lsearch -all -inline -not -exact $current $candidate]
                    set changed 1
                    break
                }
            }
            if {$changed} break
        }
    }
    foreach root [dict keys $roots] {
        if {$root ni $current} {
            Drop $root
        }
    }
    set new {}
    foreach root $current {
        if {![dict exists $roots $root]} {
            dict set roots $root [dict create gen [dict get $documents $root gen] latest "" good "" \
                submitted 0 applied 0 timer ""]
            lappend new $root
        }
    }
    return $new
}

proc lsp::server::Drop {root} {
    variable roots
    variable scheduler
    set record [dict get $roots $root]
    after cancel [dict get $record timer]
    lsp::scheduler::cancel $scheduler $root
    foreach rev [lsort -unique [list [dict get $record latest] [dict get $record good]]] {
        if {$rev ne ""} {
            Release $rev
        }
    }
    dict unset roots $root
}

# The program PATH belongs to (the header's rule), or "".
proc lsp::server::Owner {path} {
    variable roots
    set best ""
    set bestGen ""
    dict for {root record} $roots {
        if {($bestGen eq "" || [dict get $record gen] < $bestGen) && $path in [Reads $root]} {
            set best $root
            set bestGen [dict get $record gen]
        }
    }
    return $best
}

# 1 while an analysis of program ROOT is due: debouncing, queued or running.
proc lsp::server::Pending {root} {
    variable roots
    variable scheduler
    if {![dict exists $roots $root]} {
        return 0
    }
    return [expr {[dict get $roots $root timer] ne "" || [lsp::scheduler::busy $scheduler $root] ne ""}]
}

# Schedules an analysis of program ROOT after DELAY milliseconds (the
# debounce when ""); a pending one is postponed.
proc lsp::server::Schedule {root {delay ""}} {
    variable roots
    variable debounce
    if {$delay eq ""} {
        set delay $debounce
    }
    after cancel [dict get $roots $root timer]
    dict set roots $root timer [after $delay [list lsp::server::Submit $root]]
}

proc lsp::server::Submit {root} {
    variable roots
    variable scheduler
    variable jobs
    if {![dict exists $roots $root]} {
        return
    }
    lsp::stats::timed submit {
        dict set roots $root timer ""
        set job [incr jobs]
        dict set roots $root submitted $job
        lsp::stats::count submitted
        lsp::scheduler::submit $scheduler $root $root $job
    }
}

# The scheduler's delivery: job JOB of program ROOT ended with OUTCOME
# (revision, failed, crashed) and PAYLOAD (the revision, or why).
proc lsp::server::Deliver {root job outcome payload} {
    variable roots
    variable faults
    variable held
    lsp::stats::timed deliver {
        if {[dict getdef $faults hold-result 0] && $outcome eq "revision" && $held eq "" && $job == 1} {
            # (Test hook: the first result arrives after the next one.)
            set held [list $root $job $outcome $payload]
            Log "holding the result of job $job (BOTLISH_LSP_FAULT hold-result)"
            return
        }
        Apply $root $job $outcome $payload
        if {$held ne "" && $job != 1} {
            set late $held
            set held "-"
            Apply {*}$late
        }
    }
}

proc lsp::server::Apply {root job outcome payload} {
    variable roots
    if {![dict exists $roots $root] || $job <= [dict get $roots $root applied]} {
        # The program is gone, or a newer job's result was applied: this one
        # is obsolete, and never becomes the program's revision.
        lsp::stats::count obsoleteResults
        if {$outcome eq "revision"} {
            Release $payload
        }
        return
    }
    dict set roots $root applied $job
    switch -- $outcome {
        revision {
            set record [dict get $roots $root]
            set old [list [dict get $record latest] [dict get $record good]]
            dict set roots $root latest $payload
            if {[service::hir $payload] ne ""} {
                dict set roots $root good $payload
            }
            set keep [list [dict get $roots $root latest] [dict get $roots $root good]]
            foreach rev [lsort -unique $old] {
                if {$rev ne "" && $rev ni $keep} {
                    Release $rev
                }
            }
            # The query indexes of the open documents it owns, before the
            # first query asks (a worker's revision brings them; the
            # synchronous scheduler's are computed here, in a callback of
            # their own).
            after idle [list lsp::server::Prepare $root $payload]
            if {[Fresh $payload]} {
                lsp::stats::count freshResults
            } else {
                lsp::stats::count staleResults
                # A source it read changed while it ran; that change may not
                # have concerned the program as its earlier revisions knew
                # it (a module it imports since this revision).
                if {![Pending $root]} {
                    Schedule $root
                }
            }
        }
        failed {
            Log "the analysis of [file tail $root] failed: $payload"
        }
        crashed {
            Log "the analysis of [file tail $root] did not complete: $payload"
            Notify window/logMessage [lsp::json::obj type [lsp::json::int 1] \
                message [lsp::json::str "botlish: the analysis of [file tail $root] did not complete ($payload); the last analysis stays in use"]]
        }
    }
    foreach new [UpdateRoots] {
        Schedule $new 0
    }
    Reconcile
    Retry $root
}

proc lsp::server::Prepare {root rev} {
    variable roots
    variable documents
    if {![dict exists $roots $root] || $rev ni [list [dict get $roots $root latest] [dict get $roots $root good]]} {
        return
    }
    lsp::stats::timed prepare {
        set paths {}
        foreach path [dict keys $documents] {
            if {[Owner $path] eq $root && [dict exists [RevInfo $rev] sources $path path]} {
                lappend paths [dict get [RevInfo $rev] sources $path path]
            }
        }
        catch {service::prepare $rev -paths $paths -compilerpedia 0}
    }
}

# ---------------------------------------------------------------------------
# Revisions

proc lsp::server::Release {rev} {
    variable revinfo
    variable cache
    dict unset revinfo $rev
    foreach key [dict keys $cache $rev,*] {
        dict unset cache $key
    }
    catch {service::release $rev}
}

# What revision REV's snapshot holds: sources (normalized path -> {path P
# exists E from F version V read R}), read (the normalized paths it read
# text from), entry, hir (0|1).
proc lsp::server::RevInfo {rev} {
    variable revinfo
    if {![dict exists $revinfo $rev]} {
        set revision [service::revision $rev]
        set sources [dict create]
        set read {}
        dict for {path observation} [dict get $revision sources] {
            set key [Internal [file normalize $path]]
            dict set sources $key [dict merge $observation [dict create path $path]]
            if {[dict get $observation read]} {
                lappend read $key
            }
        }
        dict set revinfo $rev [dict create sources $sources read $read hir [dict get $revision hir] \
            entry [file normalize [dict get $revision entry]]]
    }
    return [dict get $revinfo $rev]
}

# The text revision REV analyzed at PATH (normalized), or an error.
proc lsp::server::RevText {rev path} {
    set info [RevInfo $rev]
    if {![dict exists $info sources $path path]} {
        error "revision $rev read nothing at $path"
    }
    return [service::sourceText $rev [dict get $info sources $path path]]
}

# 1 if PATH is now what revision REV saw there: the same open document
# version, or the same text; for a path it found no file at, still none. A
# closed document is the disk's, which is taken to be unchanged since the
# revision read it (a save re-checks the disk: DidSave), unless the revision
# read the document's unsaved buffer: then the disk's text is compared.
proc lsp::server::SameSource {rev path} {
    variable documents
    set info [RevInfo $rev]
    if {![dict exists $info sources $path]} {
        return 1
    }
    set seen [dict get $info sources $path]
    if {[dict exists $documents $path]} {
        set document [dict get $documents $path]
        if {![dict get $seen exists]} {
            return 0
        }
        if {![dict get $seen read]} {
            return 1
        }
        if {[dict get $seen from] eq "buffer" && [dict getdef $seen version ""] eq "[dict get $document gen]/[dict get $document version]"} {
            return 1
        }
        return [expr {[RevText $rev $path] eq [dict get $document normal]}]
    }
    if {[dict get $seen from] eq "disk"} {
        return 1
    }
    # Its buffer was closed: the disk's text now.
    set exists [surface::source::exists [dict get $seen path]]
    if {$exists != [dict get $seen exists]} {
        return 0
    }
    if {!$exists || ![dict get $seen read]} {
        return 1
    }
    return [expr {[catch {surface::source::text [dict get $seen path]} disk] == 0 && $disk eq [RevText $rev $path]}]
}

# 1 if every source revision REV read or probed is still what it saw.
proc lsp::server::Fresh {rev} {
    dict for {path seen} [dict get [RevInfo $rev] sources] {
        if {![SameSource $rev $path]} {
            return 0
        }
    }
    return 1
}

# The sources of REV that changed since (their file names).
proc lsp::server::Changes {rev} {
    set changed {}
    dict for {path seen} [dict get [RevInfo $rev] sources] {
        if {![SameSource $rev $path]} {
            lappend changed [file tail $path]
        }
    }
    return $changed
}

# The current normalized text of PATH -- the open document's, else the
# disk's -- or "" with exists 0.
proc lsp::server::CurrentText {path} {
    variable documents
    if {[dict exists $documents $path]} {
        return [list 1 [dict get $documents $path normal]]
    }
    if {[catch {surface::source::text $path} text]} {
        return [list 0 ""]
    }
    return [list 1 $text]
}

# The line starts of TEXT, cached under KEY ("": not cached -- a text that
# can change under the same name, the disk's, is never cached).
proc lsp::server::Starts {key text} {
    variable cache
    if {$key eq ""} {
        return [lsp::positions::lineStarts $text]
    }
    if {![dict exists $cache $key]} {
        dict set cache $key [lsp::positions::lineStarts $text]
    }
    return [dict get $cache $key]
}

# The mapping from OLD (a revision's text) to NEW (the text a position or a
# location is wanted in), cached under KEY: {prefix P suffix S delta D}, the
# common prefix and suffix of the two texts (character counts) and the
# difference of their lengths. A position of NEW in its unchanged prefix or
# suffix denotes the same character of OLD; anything in between is text OLD
# never saw. Identical texts are one prefix.
proc lsp::server::Mapping {key old new} {
    variable cache
    if {$key ne "" && [dict exists $cache $key]} {
        return [dict get $cache $key]
    }
    set oldLength [string length $old]
    set newLength [string length $new]
    if {$old eq $new} {
        set mapping [list $oldLength 0 0]
    } else {
        set prefix [CommonPrefix $old $new]
        set limit [expr {min($oldLength, $newLength) - $prefix}]
        set suffix [CommonPrefix [string reverse $old] [string reverse $new]]
        if {$suffix > $limit} {
            set suffix $limit
        }
        set mapping [list $prefix $suffix [expr {$newLength - $oldLength}]]
    }
    set result [list $mapping $oldLength $newLength]
    if {$key eq ""} {
        return $result
    }
    if {[dict size $cache] > 256} {
        set cache [dict create]
    }
    dict set cache $key $result
    return $result
}

proc lsp::server::CommonPrefix {a b} {
    set low 0
    set high [expr {min([string length $a], [string length $b])}]
    while {$low < $high} {
        set mid [expr {($low + $high + 1) / 2}]
        if {[string equal -length $mid $a $b]} {
            set low $mid
        } else {
            set high [expr {$mid - 1}]
        }
    }
    return $low
}

# The offset of OLD's text that offset OFFSET of NEW denotes (MAPPING), or "".
proc lsp::server::ToOld {mapping offset} {
    lassign $mapping m oldLength newLength
    lassign $m prefix suffix delta
    if {$offset < $prefix || ($oldLength == $newLength && $prefix == $oldLength)} {
        return $offset
    }
    if {$offset >= $newLength - $suffix} {
        return [expr {$offset - $delta}]
    }
    return ""
}

# The range of NEW's text that the range START END of OLD's text is
# (MAPPING), or "" when it is not wholly in the unchanged text.
proc lsp::server::ToNew {mapping start end} {
    lassign $mapping m oldLength newLength
    lassign $m prefix suffix delta
    if {$end <= $prefix} {
        return [list $start $end]
    }
    if {$start >= $oldLength - $suffix} {
        return [list [expr {$start + $delta}] [expr {$end + $delta}]]
    }
    return ""
}

# The protocol range of START END of TEXT.
proc lsp::server::LspRange {key text start end} {
    variable encoding
    set starts [Starts $key $text]
    lassign [lsp::positions::toLsp $text $starts $start $encoding] l1 c1
    lassign [lsp::positions::toLsp $text $starts $end $encoding] l2 c2
    return [lsp::json::obj start [lsp::json::obj line [lsp::json::int $l1] character [lsp::json::int $c1]] \
        end [lsp::json::obj line [lsp::json::int $l2] character [lsp::json::int $c2]]]
}

# The location, for the client, of RANGE (a service range: file, start, end)
# that revision REV reports: {uri, range} in the text that file has now, or
# "" when that text no longer holds the range (it changed there).
proc lsp::server::Location {rev range} {
    variable documents
    set path [Internal [file normalize [dict get $range file]]]
    if {[catch {RevText $rev $path} old]} {
        return ""
    }
    if {[dict exists $documents $path]} {
        set document [dict get $documents $path]
        set key "$rev,$path,[dict get $document gen]/[dict get $document version]"
        set new [dict get $document normal]
    } elseif {[SameSource $rev $path]} {
        set key "$rev,$path,same"
        set new $old
    } else {
        lassign [CurrentText $path] exists new
        if {!$exists} {
            return ""
        }
        # (The disk's text: never cached, it may change under its name.)
        set key ""
    }
    set mapped [ToNew [Mapping $key $old $new] [dict get $range start] [dict get $range end]]
    if {$mapped eq ""} {
        return ""
    }
    return [lsp::json::obj uri [lsp::json::str [UriOf $path]] range [LspRange [if {$key eq ""} {string cat ""} else {string cat $key,lines}] $new {*}$mapped]]
}

# ---------------------------------------------------------------------------
# Diagnostics

# Publishes, for every path, what its owner's fresh latest revision reports
# there (nothing changes while it is not fresh), and clears what a program
# no longer owning a path published. Sends only what differs from what the
# client has.
proc lsp::server::Reconcile {} {
    variable roots
    variable published
    set paths [dict keys $published]
    set reports [dict create]
    dict for {root record} $roots {
        set latest [dict get $record latest]
        if {$latest eq "" || ![Fresh $latest]} continue
        set grouped [dict create]
        foreach path [dict get [RevInfo $latest] read] {
            dict set grouped $path {}
        }
        foreach d [service::diagnostics $latest] {
            if {[dict get $d range] eq "none"} {
                set path $root
            } else {
                set path [Internal [file normalize [dict get $d file]]]
            }
            dict lappend grouped $path $d
        }
        dict set reports $root $grouped
        lappend paths {*}[dict keys $grouped]
    }
    foreach path [lsort -unique $paths] {
        set owner [Owner $path]
        set before [dict getdef $published $path [dict create owner "" version "" items {}]]
        if {$owner ne "" && [dict exists $reports $owner $path]} {
            set latest [dict get $roots $owner latest]
            set items [lmap d [dict get $reports $owner $path] {Diagnostic $latest $path $d}]
            set version [DocumentVersion $path]
        } elseif {$owner ne "" && [dict get $before owner] eq $owner} {
            # Its owner has nothing fresh to say yet: what it said stays.
            continue
        } else {
            # No owner, or a new one with nothing to say yet: what another
            # program said is withdrawn.
            set items {}
            set version [DocumentVersion $path]
        }
        # An open document hears about every version analyzed (no
        # diagnostics is news too); a closed file only of a change.
        set open [expr {$version ne ""}]
        if {$items ne [dict get $before items] || $version ne [dict get $before version]
                || $owner ne [dict get $before owner]} {
            if {$items ne {} || [dict get $before items] ne {} || ($open && $owner ne "")} {
                set params [dict create uri [lsp::json::str [UriOf $path]]]
                if {$version ne ""} {
                    dict set params version [lsp::json::int $version]
                }
                dict set params diagnostics [lsp::json::arrayOf $items]
                Notify textDocument/publishDiagnostics [list obj $params]
                lsp::stats::count published
            }
            if {$items eq {} && !($open && $owner ne "")} {
                # The client holds nothing for it: nothing to withdraw later.
                dict unset published $path
            } else {
                dict set published $path [dict create owner $owner version $version items $items]
            }
        }
    }
}

proc lsp::server::DocumentVersion {path} {
    variable documents
    if {[dict exists $documents $path]} {
        return [dict get $documents $path version]
    }
    return ""
}

# The protocol diagnostic of the service diagnostic D of revision REV, in
# the file PATH (normalized; D's own, or its program's entry when D has no
# location).
proc lsp::server::Diagnostic {rev path d} {
    variable topics
    set text [RevText $rev $path]
    if {[dict get $d range] eq "none"} {
        set range [LspRange $rev,$path,lines $text 0 0]
    } else {
        set range [LspRange $rev,$path,lines $text [dict get $d start] [dict get $d end]]
    }
    set diagnostic [dict create range $range \
        severity [lsp::json::int [expr {[dict get $d severity] eq "error" ? 1 : 2}]] \
        code [lsp::json::str [dict get $d code]] source {str botlish} \
        message [lsp::json::str [dict get $d message]]]
    set related {}
    set record [dict get $d record]
    set note "related location"
    if {[dict get $d severity] eq "warning" && $record ne "" && [dict exists $record data note]} {
        set note [dict get $record data note]
    }
    foreach r [dict get $d related] {
        set location [Location $rev $r]
        if {$location ne ""} {
            lappend related [lsp::json::obj location $location message [lsp::json::str $note]]
        }
    }
    if {$related ne {}} {
        dict set diagnostic relatedInformation [lsp::json::arrayOf $related]
    }
    set topic [Topic $d]
    if {$topic ne ""} {
        # The Compilerpedia topic, kept for the client (a diagnostic's data
        # comes back with code-action requests); there is no web page to
        # link as a codeDescription.
        dict set diagnostic data [lsp::json::obj topic [lsp::json::str $topic]]
    }
    return [list obj $diagnostic]
}

# The Compilerpedia topic of diagnostic D (service::explain), or "".
proc lsp::server::Topic {d} {
    variable cache
    set key "topic,[dict get $d code],[dict get $d text]"
    if {![dict exists $cache $key]} {
        set topic [service::explain $d]
        dict set cache $key [if {$topic eq {}} {string cat ""} else {dict get $topic id}]
    }
    return [dict get $cache $key]
}

# ---------------------------------------------------------------------------
# Queries

# The params of a position request: {path P uri U line L character C}.
proc lsp::server::PositionParams {params} {
    set params [Params $params]
    set uri [lsp::json::text [lsp::json::get [lsp::json::get $params textDocument] uri] uri]
    set position [lsp::json::get $params position]
    set line [lsp::json::integer [lsp::json::get $position line] line]
    set character [lsp::json::integer [lsp::json::get $position character] character]
    if {$line < 0 || $character < 0} {
        lsp::rpc::fail InvalidParams "a position's line and character are not negative"
    }
    return [dict create path [PathOf $uri] uri $uri line $line character $character]
}

proc lsp::server::Hover {id params} {
    return [Ask $id hover [PositionParams $params] $params]
}

proc lsp::server::Definition {id params} {
    return [Ask $id definition [PositionParams $params] $params]
}

proc lsp::server::References {id params} {
    set where [PositionParams $params]
    set context [lsp::json::get [Params $params] context [lsp::json::obj]]
    dict set where declaration [lsp::json::boolean [lsp::json::get $context includeDeclaration {bool 0}] includeDeclaration]
    return [Ask $id references $where $params]
}

# Answers the request ID of KIND at WHERE now, or makes it wait (Answer).
proc lsp::server::Ask {id kind where params} {
    variable documents
    variable deferred
    variable nextDeferred
    set path [dict get $where path]
    if {[dict exists $documents $path]} {
        set document [dict get $documents $path]
        dict set where text [dict get $document normal]
        dict set where version [dict get $document gen]/[dict get $document version]
    } else {
        lassign [CurrentText $path] exists text
        dict set where text $text
        # (Unique: the disk's text is never cached under a version.)
        dict set where version disk[incr ::lsp::server::nextDeferred]
    }
    set result [Answer $kind $where 0]
    if {[lindex $result 0] eq "answer"} {
        return $result
    }
    # Wait: for the analysis that will answer it (Retry), its cancellation,
    # or 30 seconds, whichever comes first.
    set key d[incr nextDeferred]
    dict set deferred $key [dict create id $id kind $kind where $where \
        timer [after 30000 [list lsp::server::Resolve $key 1]]]
    lsp::stats::count deferred
    if {[dict size $deferred] > 64} {
        Resolve [lindex [dict keys $deferred] 0] 1
    }
    return [list deferred]
}

# Answers the waiting requests about documents program ROOT owns that can
# be answered now.
proc lsp::server::Retry {root} {
    variable deferred
    foreach key [dict keys $deferred] {
        if {![dict exists $deferred $key]} continue
        set owner [Owner [dict get $deferred $key where path]]
        if {$owner eq $root || $owner eq ""} {
            Resolve $key 0
        }
    }
}

# Answers the waiting request KEY if it can be (FINAL: with what there is).
proc lsp::server::Resolve {key final} {
    variable deferred
    variable documents
    if {![dict exists $deferred $key]} {
        return
    }
    set request [dict get $deferred $key]
    set where [dict get $request where]
    set path [dict get $where path]
    # A document that moved on will never be analyzed in the text the
    # request was made in: answer with what there is.
    if {[dict exists $documents $path]} {
        set document [dict get $documents $path]
        if {"[dict get $document gen]/[dict get $document version]" ne [dict get $where version]} {
            set final 1
        }
    }
    set result [Answer [dict get $request kind] $where $final]
    if {[lindex $result 0] ne "answer"} {
        return
    }
    after cancel [dict get $request timer]
    dict unset deferred $key
    Send [lsp::rpc::success [dict get $request id] [lindex $result 1]]
}

# The answer to a KIND request at WHERE ({path line character text version
# ...}: the position in the text TEXT the client had), or {wait} when it
# should wait for a pending analysis (never when FINAL).
#
# The revisions that may answer are the owner's latest and latest with a HIR.
# One interprets the position when the text it analyzed at PATH holds the
# position's character unchanged (Mapping); its answer is fresh when that
# text is TEXT and every other source is unchanged too (Fresh). A hover
# from a stale revision answers at once, marked stale; a definition or
# references from one waits for a pending analysis. With no revision able
# to interpret the position, a pending analysis is waited for; otherwise
# the answer is null (or no locations).
proc lsp::server::Answer {kind where final} {
    variable roots
    variable encoding
    set path [dict get $where path]
    set text [dict get $where text]
    set empty [if {$kind eq "references"} {lsp::json::arr} else {lsp::json::null}]
    set owner [Owner $path]
    if {$owner eq ""} {
        return [list answer $empty]
    }
    set offset [lsp::positions::fromLsp $text [Starts "request,$path,[dict get $where version]" $text] \
        [dict get $where line] [dict get $where character] $encoding]
    if {$offset eq ""} {
        return [list answer $empty]
    }
    set pending [expr {!$final && [Pending $owner]}]
    set record [dict get $roots $owner]
    foreach rev [lsort -unique [list [dict get $record latest] [dict get $record good]]] {
        if {$rev eq "" || ![dict get [RevInfo $rev] hir]} continue
        if {[catch {RevText $rev $path} old]} continue
        set mapping [Mapping "$rev,$path,[dict get $where version]" $old $text]
        set at [ToOld $mapping $offset]
        if {$at eq ""} continue
        set starts [Starts "$rev,$path,lines" $old]
        set line [lsp::positions::lineOf $starts $at]
        set column [expr {$at - [lindex $starts $line] + 1}]
        if {[catch {service::at $rev [dict get [RevInfo $rev] sources $path path] [expr {$line + 1}] $column} facts]} continue
        set fresh [expr {$old eq $text && [Fresh $rev]}]
        if {!$fresh && $kind ne "hover" && $pending} {
            return wait
        }
        return [list answer [Present $kind $rev $path $mapping $facts $fresh $where]]
    }
    if {$pending} {
        return wait
    }
    return [list answer $empty]
}

# The protocol answer to a KIND request from the facts FACTS (service::at) of
# revision REV, whose text of PATH maps to the request's by MAPPING.
proc lsp::server::Present {kind rev path mapping facts fresh where} {
    variable markdown
    variable encoding
    switch -- $kind {
        hover {
            if {![dict exists $facts hover] || ![dict exists $facts construct]} {
                return [lsp::json::null]
            }
            set range [dict get $facts construct range]
            set mapped [ToNew $mapping [dict get $range start] [dict get $range end]]
            if {$mapped eq ""} {
                # The construct reaches into text the revision never saw.
                return [lsp::json::null]
            }
            set lines [list [dict get $facts hover]]
            set notes {}
            if {!$fresh} {
                set changed [Changes $rev]
                if {[RevText $rev $path] ne [dict get $where text]} {
                    lappend changed [file tail $path]
                }
                lappend notes "stale: analyzed before the latest changes to [join [lsort -unique $changed] {, }]"
            }
            foreach topic [dict get $facts topics] {
                if {[lindex [dict get $topic for] 0] eq "symbol"} {
                    lappend notes "[dict get $topic title] ($::cliInvocation -help [dict get $topic id])"
                }
            }
            if {$markdown} {
                set value "```botlish\n[join $lines \n]\n```"
                foreach note $notes {
                    append value "\n\n*[MarkdownEscape $note]*"
                }
                set contents [lsp::json::obj kind {str markdown} value [lsp::json::str $value]]
            } else {
                set contents [lsp::json::obj kind {str plaintext} \
                    value [lsp::json::str [join [concat $lines [lmap n $notes {string cat "($n)"}]] \n]]]
            }
            set text [dict get $where text]
            return [lsp::json::obj contents $contents \
                range [LspRange "request,$path,[dict get $where version]" $text {*}$mapped]]
        }
        definition {
            if {![dict exists $facts definition]} {
                return [lsp::json::null]
            }
            set location [Location $rev [dict get $facts definition]]
            if {$location eq ""} {
                return [lsp::json::null]
            }
            return $location
        }
        references {
            set locations {}
            if {[dict get $where declaration] && [dict exists $facts definition]} {
                set location [Location $rev [dict get $facts definition]]
                if {$location ne ""} {
                    lappend locations $location
                }
            }
            foreach range [dict getdef $facts references {}] {
                if {$range eq ""} continue
                set location [Location $rev $range]
                if {$location ne ""} {
                    lappend locations $location
                }
            }
            return [lsp::json::arrayOf $locations]
        }
    }
}

proc lsp::server::MarkdownEscape {text} {
    return [regsub -all {[\\`*_\[\]<>]} $text {\\&}]
}
