# service.tcl -- the compiler service: the compiler's analysis as one shared,
# in-process Tcl interface (COMPILER-SERVICE-MILESTONE-1.md).
#
#   source service/service.tcl          ;# loads core, hir and surface too
#
# Workspaces: the compilation environment and its unsaved documents
#
#   service::workspace ?-target T? ?-warnings MODE? ?-cache DIR? ?-root DIR?
#                                         => WS
#   service::setDocument WS PATH TEXT ?-version V?   an unsaved buffer
#   service::deleteDocument WS PATH ?-version V?     a file deleted unsaved
#   service::clearDocument WS PATH                   back to the disk
#   service::documents WS                            the overlay in force
#   service::closeWorkspace WS                       and its revisions
#
# Revisions: one analysis of one entry program against one snapshot
#
#   service::analyze WS ENTRY ?-version V?         => REV
#   service::revision REV               what it analyzed, how it ended
#   service::diagnostics REV ?-severity error|warning?
#   service::sourceText REV PATH        the text it analyzed at PATH
#   service::stale REV                  the sources that changed since
#   service::hir REV                    its HIR ("" without one)
#   service::release REV
#   service::revisions ?WS?             the live revisions
#   service::export REV ?-derived 0|1?  the revision as text, for another process
#   service::import WS TEXT ?-version V?    => REV: an exported revision
#
# Queries
#
#   service::at REV PATH LINE COLUMN ?-version V?   the facts at a position
#   service::prepare REV ?-paths PATHS? ?-compilerpedia 0|1?
#                                        build its query indexes now
#   service::explain DIAGNOSTIC          its Compilerpedia topic
#   service::state                       what the service holds (counts)
#
# The service adds no semantics. Everything it reports is the compiler's:
# the analysis is the front end's lenient compilation of a program file
# (surface::readProgramFile -strict 0: the very build a strict compilation
# raises from), its diagnostics are the entries a strict compilation raises
# (hir::recovery::entries of hir::recovery::reported, the loader's and the
# parser's own, the warning policy's rejection) and the warnings the
# compilation attached, its facts are the HIR's (resolution, types,
# signatures, origins) and the ASTs' (spans, node ids), and its explanations
# Compilerpedia's (compilerpedia::topicForDiagnostic). It knows nothing of
# editors: no protocol, document URI, request, UTF-16 column or event loop;
# a transport adds those around it.
#
# Positions are the compiler's: 1-based lines and columns, 0-based offsets,
# all counting Unicode scalar values of the normalized text a revision
# analyzed (surface/source.tcl).

if {[info commands ::surface::compile] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] surface surface.tcl]
}

namespace eval service {
    variable home [file dirname [file dirname [file normalize [info script]]]]
    # WS -> {target T warnings W cache DIR root DIR overlay PATH->ENTRY
    # revisions {REV ...}}
    variable workspaces [dict create]
    # REV -> the revision (Analyze), with `derived`: what queries computed
    # from it, on first use (Derived)
    variable revisions [dict create]
    variable nextWorkspace 0
    variable nextRevision 0
    # The facts a position query answers; each is either in its result or in
    # its `unavailable` dict, with the reason (at).
    variable facts {syntax construct binding type hover definition references diagnostics topics}
    # The format of an exported revision (export, import).
    variable exportVersion 2
}

# Raises the service error {SERVICE KIND} with MESSAGE: a misuse of the
# interface (an unknown revision, a position outside a source), never a
# diagnostic of a program.
proc service::Fail {kind message} {
    return -code error -level 2 -errorcode [list SERVICE $kind] $message
}

proc service::Options {who defaults arguments} {
    set options $defaults
    if {[llength $arguments] % 2} {
        error "$who: options come in pairs: $arguments"
    }
    foreach {option value} $arguments {
        if {![dict exists $options $option]} {
            error "$who: unknown option \"$option\" (known: [join [dict keys $defaults] {, }])"
        }
        dict set options $option $value
    }
    return $options
}

# ---------------------------------------------------------------------------
# Workspaces

# A new workspace: the compilation environment of the programs analyzed in
# it -- the C ABI target (-target, the host's when ""), the warning policy
# (-warnings default|off|error, the environment's when not given:
# hir::warnings::defaultMode), the front-end cache directory (-cache, the
# environment's when not given: surface::cache::directory; "" none) -- and
# the directory relative paths are taken from (-root; "" for the working
# directory, as the command line takes them). An entry program's application
# root, where its own modules are, is the compiler's: its file's directory
# (IMPORTS.md), whatever -root says.
proc service::workspace {args} {
    variable workspaces
    variable nextWorkspace
    set options [Options service::workspace [dict create -target "" \
        -warnings [hir::warnings::defaultMode] -cache [surface::cache::directory] -root ""] $args]
    set target [dict get $options -target]
    if {$target ne "" && ![core::cabi::isTarget $target]} {
        error "service::workspace: unknown C ABI target \"$target\" (known: [join [core::cabi::targetNames] {, }])"
    }
    hir::warnings::Mode [dict get $options -warnings]
    set root [dict get $options -root]
    if {$root ne ""} {
        set root [file normalize $root]
    }
    set ws ws[incr nextWorkspace]
    dict set workspaces $ws [dict create target $target warnings [dict get $options -warnings] \
        cache [dict get $options -cache] root $root overlay [dict create] revisions {}]
    return $ws
}

proc service::Workspace {ws} {
    variable workspaces
    if {![dict exists $workspaces $ws]} {
        Fail UNKNOWN-WORKSPACE "no workspace \"$ws\""
    }
    return [dict get $workspaces $ws]
}

# PATH as WORKSPACE takes it: joined to its root when relative.
proc service::Path {workspace path} {
    if {[dict get $workspace root] ne "" && [file pathtype $path] eq "relative"} {
        return [file join [dict get $workspace root] $path]
    }
    return $path
}

# Makes TEXT the unsaved buffer of the document at PATH in workspace WS,
# with the caller's opaque VERSION: analyses read it instead of the file
# (or as a file that does not exist on disk), normalized as the compiler
# reads any source (surface::source::text). Revisions made before keep what
# they read.
proc service::setDocument {ws path text args} {
    variable workspaces
    set options [Options service::setDocument {-version ""} $args]
    set workspace [Workspace $ws]
    dict set workspaces $ws overlay [file normalize [Path $workspace $path]] \
        [dict create text $text version [dict get $options -version]]
    return
}

# Marks the document at PATH deleted in workspace WS (an unsaved deletion):
# analyses find no file there, whatever the disk holds.
proc service::deleteDocument {ws path args} {
    variable workspaces
    set options [Options service::deleteDocument {-version ""} $args]
    set workspace [Workspace $ws]
    dict set workspaces $ws overlay [file normalize [Path $workspace $path]] \
        [dict create absent 1 version [dict get $options -version]]
    return
}

# Drops the overlay entry of PATH in workspace WS: analyses read the disk.
proc service::clearDocument {ws path} {
    variable workspaces
    set workspace [Workspace $ws]
    dict unset workspaces $ws overlay [file normalize [Path $workspace $path]]
    return
}

# Workspace WS's overlay: normalized PATH -> {text T version V} or {absent 1
# version V}.
proc service::documents {ws} {
    return [dict get [Workspace $ws] overlay]
}

# Closes workspace WS, releasing every revision made in it.
proc service::closeWorkspace {ws} {
    variable workspaces
    foreach rev [dict get [Workspace $ws] revisions] {
        release $rev
    }
    dict unset workspaces $ws
    return
}

# The source provider of workspace WORKSPACE: its overlay over the disk.
proc service::Provider {workspace} {
    return [surface::source::overlay [dict get $workspace overlay]]
}

# ---------------------------------------------------------------------------
# Analysis

# Analyzes the program file ENTRY in workspace WS -- its text and every module
# it loads read from the workspace's documents, else from the disk, in one
# snapshot (surface/source.tcl) -- and returns a new revision, REV.
# -version V is the caller's identity for it (an editor's document version).
#
# A revision is a value: the snapshot it read (every source path it read or
# found no file at, with the text, where the answer came from and the
# buffer's version), the configuration it was analyzed under, and its
# outcome:
#
#   ok        a HIR, no error (warnings, if any)
#   semantic  a HIR and the errors a strict compilation reports for it (the
#             warning policy's rejection under -warnings error included)
#   syntax    syntax errors in the entry or a module: every file's, then
#             the semantic errors independent of them; a partial HIR
#             (semantics `partial`) unless a module also failed to load
#   loader    no HIR: a module failed to load (resolution of an import, a
#             module file that cannot be read)
#   failure   no HIR: the compiler failed (not a diagnostic of the program)
#
# A compiler failure (not an error of the program) in a program whose entry
# has syntax errors is reported as those (outcome syntax, semantics none),
# and kept in the revision's `failure` all the same: that the analysis past
# them failed is the compiler's problem, never hidden. An error a
# declaration raises (an unknown type in a struct's field) stops an analysis
# past syntax errors as it stops any compilation: the revision reports the
# syntax errors, which may be its cause (a type a malformed declaration
# would have declared), and has no semantics.
#
# and, separately, what is known of its meaning (`semantics`): `full` (a HIR
# of the program as written: outcomes ok and semantic), `partial` (a HIR of
# a program with syntax errors, its malformed source holes and whatever
# depends on them unknown: SYNTAX-RECOVERY-MILESTONE-1.md), `none` (no HIR).
# A revision with syntax errors is never `ok`, whatever HIR it has.
#
# Editing the workspace afterwards changes nothing in it. An ENTRY with no
# source file raises, as reading it does (POSIX ENOENT): there is no
# revision of nothing.
proc service::analyze {ws entry args} {
    variable workspaces
    variable revisions
    variable nextRevision
    set options [Options service::analyze {-version ""} $args]
    set workspace [Workspace $ws]
    set path [Path $workspace $entry]
    set revision [surface::source::with [Provider $workspace] [list service::Analyze $workspace $path]]
    set rev rev[incr nextRevision]
    dict set revision id $rev
    dict set revision workspace $ws
    dict set revision version [dict get $options -version]
    dict set revision derived [dict create]
    dict set revisions $rev $revision
    dict set workspaces $ws revisions [concat [dict get $workspace revisions] [list $rev]]
    return $rev
}

# The revision of the program file PATH analyzed in the snapshot in force
# (analyze), without its identity.
proc service::Analyze {workspace path} {
    set mode [hir::warnings::Mode [dict get $workspace warnings]]
    set revision [dict create entry $path outcome ok semantics none hir "" errors {} warnings {} failure "" \
        config [Configuration $workspace $path]]
    # (An entry with no source file raises here.)
    set text [surface::source::text $path]
    try {
        # The warning policy is applied here (below): its rejection must
        # not take the HIR with it.
        set collect default
        if {$mode eq "off"} {
            set collect off
        }
        # Past syntax errors: their independent semantics too
        # (SYNTAX-RECOVERY-MILESTONE-1.md).
        set hir [surface::readProgramFile $path -strict 0 -warnings $collect -recover-syntax 1 \
            -warning-channel "" -target [dict get $workspace target] -cache [dict get $workspace cache]]
    } on error {message options} {
        set code [dict get $options -errorcode]
        if {[lindex $code 0] ni {SURFACE POSIX CORE}} {
            set failure [dict create message $message errorcode $code errorinfo [dict get $options -errorinfo]]
        }
        if {[lrange $code 0 1] ne {SURFACE SYNTAX}} {
            # The command line parses the entry before it compiles, so
            # every syntax error of the entry is what it reports, even when
            # the compilation fails before parsing it (a library a
            # `# requires:` line names). The compilation parses the entry
            # itself (with every syntax error) unless the front-end cache
            # has its HIR, so a hit parses nothing; here the parse cache
            # usually has the AST already.
            set ast [surface::modules::Parse $path $text]
            if {[dict get $ast diagnostics] ne ""} {
                set code {SURFACE SYNTAX}
                set options [dict create -diagnostics [surface::syntaxEntries [dict get $ast diagnostics]]]
            }
        }
        if {[lrange $code 0 1] eq {SURFACE SYNTAX}} {
            dict set revision outcome syntax
        } elseif {[lrange $code 0 1] eq {SURFACE MODULE} || [lindex $code 0] eq "POSIX"} {
            dict set revision outcome loader
        } else {
            dict set revision outcome failure
        }
        if {[info exists failure]} {
            dict set revision failure $failure
        }
        set entries [dict getdef $options -diagnostics [list [dict create errorcode $code message $message]]]
        dict set revision errors [lmap entry $entries {Record error $entry}]
        dict set revision sources [surface::source::observed]
        return $revision
    }
    set errors [hir::recovery::entries $hir [hir::recovery::reported $hir] 1]
    set warnings [hir::warnings::of $hir]
    set rejection [hir::warnings::Rejection $hir $warnings $mode]
    if {$rejection ne ""} {
        # -warnings error: the compilation is rejected with its first
        # warning, and reports no warning.
        lappend errors $rejection
        set warnings {}
    }
    dict set revision hir $hir
    dict set revision semantics full
    if {[dict exists $hir syntaxRecovery]} {
        # Syntax errors, analyzed past: every syntax error first, as a
        # compilation reports one of them first, then the semantic errors
        # independent of them (the warnings an error hides: none).
        set errors [concat [dict get $hir syntaxRecovery diagnostics] $errors]
        dict set revision semantics partial
    }
    dict set revision errors [lmap entry $errors {Record error $entry}]
    dict set revision warnings [lmap warning $warnings {Record warning [hir::warnings::entry $hir $warning]}]
    if {[dict exists $hir syntaxRecovery]} {
        dict set revision outcome syntax
    } elseif {$errors ne {}} {
        dict set revision outcome semantic
    }
    dict set revision sources [surface::source::observed]
    return $revision
}

# What the analysis of the entry at PATH in WORKSPACE depends on besides its
# sources: everything the front-end cache keys a compilation by
# (surface::cache::Key) but the program's text.
proc service::Configuration {workspace path} {
    return [dict create target [hir::cabi::ResolveTarget [dict get $workspace target]] \
        warnings [dict get $workspace warnings] cache [dict get $workspace cache] \
        root [file dirname [file normalize $path]] library $::core::libraryDir \
        libraries $::core::loadedLibraries frontEnd [hir::interchange::fingerprint] \
        scheduler [if {[info exists ::env(BOTLISH_STATIC_SCHEDULER)]} {set ::env(BOTLISH_STATIC_SCHEDULER)} else {string cat ""}]]
}

# The service's diagnostic of SEVERITY (error or warning) for the
# core::raiseDiagnostics ENTRY a producer made (surface/parser.tcl's
# syntaxEntries, surface/modules.tcl's Error, hir::recovery::entries,
# hir::warnings::Rejection and entry):
#
#   severity  error | warning
#   code      its code as the command line shows it (core::ShownCode):
#             {CORE SEMANTIC TYPE}, {SURFACE SYNTAX}, {SURFACE MODULE
#             UNKNOWN-NAMESPACE}, METHOD-ELIGIBLE, ...
#   message   its message, without a location
#   text      the compiler's own text of it: the "FILE:LINE:COLUMN: ..." a
#             strict compilation raises (a warning's rendering, its note
#             lines included) -- what main.tcl prints
#   range     span: file, start, end (offsets), line, column, endLine,
#             endColumn locate it exactly; point: the compiler gave a start
#             only, and the end is the start (a zero-width range); none: no
#             source location (file "" and every position ""), never an
#             invented one
#   related   the further ranges it names, in order ({file start end line
#             column endLine endColumn} each)
#   record    the producer's own record, when it has one (the HIR
#             diagnostic, the warning, the syntax diagnostic), else ""
proc service::Record {severity entry} {
    set diagnostic [dict create severity $severity code [core::ShownCode $entry] \
        message [dict getdef $entry summary [dict get $entry message]] text [dict get $entry message]]
    set location [dict getdef $entry location ""]
    if {$location eq ""} {
        dict set diagnostic range none
        foreach key {file start end line column endLine endColumn} {
            dict set diagnostic $key ""
        }
    } else {
        dict set diagnostic range span
        if {![dict exists $location endLine]} {
            dict set diagnostic range point
            dict set location end [dict get $location start]
            dict set location endLine [dict get $location line]
            dict set location endColumn [dict get $location column]
        }
        foreach key {file start end line column endLine endColumn} {
            dict set diagnostic $key [dict get $location $key]
        }
    }
    dict set diagnostic related [lmap span [dict getdef $entry related {}] {
        if {$span eq ""} continue
        Range $span
    }]
    dict set diagnostic record [dict getdef $entry record ""]
    return $diagnostic
}

# SPAN ({file start end line column endLine endColumn}, any key order) as the
# service's range: exactly those keys, in that order.
proc service::Range {span} {
    set range [dict create]
    foreach key {file start end line column endLine endColumn} {
        dict set range $key [dict get $span $key]
    }
    return $range
}

# ---------------------------------------------------------------------------
# Revisions

proc service::Get {rev} {
    variable revisions
    if {![dict exists $revisions $rev]} {
        Fail UNKNOWN-REVISION "no revision \"$rev\" (never made, or released)"
    }
    return [dict get $revisions $rev]
}

# The revision REV, with the declarations of the HIR its queries read active
# (hir::activate, COMPILATION-ISOLATION.md): type printing reads the
# process-wide registries, which the last compilation -- any program's --
# filled. Every query reads its revision through this.
proc service::Use {rev} {
    set revision [Get $rev]
    set hir [QueryHir $revision]
    if {$hir ne ""} {
        hir::activate $hir
    }
    return $revision
}

# The HIR queries of REVISION read: the program as written. A trait
# program's HIR is the monomorphized one, its functions cloned per witness;
# its checked source build (`traitSource`, what warnings are about) has
# each written expression once.
proc service::QueryHir {revision} {
    set hir [dict get $revision hir]
    if {$hir eq ""} {
        return ""
    }
    return [dict getdef $hir traitSource $hir]
}

# A summary of revision REV: id, workspace, entry, version, outcome, config
# (Configuration), hir (1 if it has one), errors and warnings (how many),
# failure (the compiler's error, for outcome failure), and sources: every
# path its snapshot answered for -> {exists E from disk|buffer ?version V?
# read 0|1}, read 1 for a path whose text it read (sourceText).
proc service::revision {rev} {
    set revision [Get $rev]
    set sources [dict create]
    dict for {path observation} [dict get $revision sources] {
        dict set sources $path [dict merge [dict remove $observation text] \
            [dict create read [dict exists $observation text]]]
    }
    return [dict create id $rev workspace [dict get $revision workspace] entry [dict get $revision entry] \
        version [dict get $revision version] outcome [dict get $revision outcome] \
        semantics [dict get $revision semantics] \
        config [dict get $revision config] hir [expr {[dict get $revision hir] ne ""}] \
        errors [llength [dict get $revision errors]] warnings [llength [dict get $revision warnings]] \
        failure [dict get $revision failure] sources $sources]
}

# The diagnostics of revision REV (Record), errors first, each kind in the
# compiler's order: exactly what the command line reports for the same
# program and sources. -severity error|warning keeps one kind.
proc service::diagnostics {rev args} {
    set options [Options service::diagnostics {-severity ""} $args]
    set revision [Get $rev]
    switch -- [dict get $options -severity] {
        ""      { return [concat [dict get $revision errors] [dict get $revision warnings]] }
        error   { return [dict get $revision errors] }
        warning { return [dict get $revision warnings] }
    }
    error "service::diagnostics: -severity is error or warning"
}

# The HIR of revision REV, "" for one without (syntax, loader, failure): for
# a caller that compiles or runs it with the existing backends (each
# activates the HIR itself).
proc service::hir {rev} {
    return [dict get [Get $rev] hir]
}

# The source path of revision REV that PATH names (compared normalized), or
# "" if the revision read no text there.
proc service::SourcePath {revision path} {
    set sources [dict get $revision sources]
    if {[dict exists $sources $path text]} {
        return $path
    }
    set normal [file normalize $path]
    dict for {source observation} $sources {
        if {[dict exists $observation text] && [file normalize $source] eq $normal} {
            return $source
        }
    }
    return ""
}

# The text revision REV analyzed at PATH (normalized), from its snapshot:
# never what the file or the workspace holds now.
proc service::sourceText {rev path} {
    set revision [Get $rev]
    set source [SourcePath $revision $path]
    if {$source eq ""} {
        Fail NOT-A-SOURCE "revision $rev read no source text at $path"
    }
    return [dict get $revision sources $source text]
}

# What changed, for revision REV, since it was made: PATH -> {was OBSERVATION
# now OBSERVATION} for every path of its snapshot that its workspace's
# documents and the disk now answer for differently (another text, a file
# that appeared or disappeared, another buffer version). Empty: REV is
# current. Staleness is information for the caller: a stale revision still
# answers about the sources it read, never about newer ones.
proc service::stale {rev} {
    set revision [Get $rev]
    set changed [dict create]
    set workspace [Workspace [dict get $revision workspace]]
    surface::source::with [Provider $workspace] {
        dict for {path was} [dict get $revision sources] {
            if {[dict exists $was directory]} {
                # A package directory (BOT-MODULES-MILESTONE-1.md): there
                # or not.
                surface::source::directory $path
                set now [dict get [surface::source::observed] $path]
                if {[dict get $now exists] != [dict get $was exists]} {
                    dict set changed $path [dict create was $was now $now]
                }
                continue
            }
            set now [dict create exists [surface::source::exists $path]]
            if {[dict exists $was text] && [dict get $now exists]} {
                dict set now text [surface::source::text $path]
            }
            set now [dict merge [dict remove [dict get [surface::source::observed] $path] text] $now]
            if {[dict get $now exists] != [dict get $was exists]
                    || [dict get $now from] ne [dict get $was from]
                    || [dict getdef $now version ""] ne [dict getdef $was version ""]
                    || ([dict exists $was text] && [dict getdef $now text ""] ne [dict get $was text])} {
                dict set changed $path [dict create was [dict remove $was text] now [dict remove $now text]]
            }
        }
    }
    return $changed
}

# Revision REV as text another process with the same front end can import
# (import): everything the revision is -- the entry, its outcome, its
# diagnostics, the failure, the configuration, the snapshot (every source's
# observation and text) -- with its HIR in the HIR interchange format
# (HIR-INTERCHANGE.md), the checked source build of a trait program
# included (its queries read it: QueryHir). Not the caller's version or its
# workspace. With -derived 1 also the query indexes computed so far
# (prepare): pure functions of the revision, so the importer answers the
# same with them, without computing them again (re-parsing sources, for
# one).
proc service::export {rev args} {
    variable exportVersion
    set options [Options service::export {-derived 0} $args]
    set revision [Get $rev]
    set hir [dict get $revision hir]
    if {$hir ne ""} {
        set hir [hir::interchange::encode $hir -trait-source 1]
    }
    set body [dict create]
    foreach key {entry outcome semantics errors warnings failure config sources} {
        dict set body $key [dict get $revision $key]
    }
    dict set body hir $hir
    if {[dict get $options -derived]} {
        dict set body derived [dict get $revision derived]
    }
    return "botlish-service-revision $exportVersion\n$body"
}

# A new revision of workspace WS holding what the text TEXT (export) holds,
# with the caller's -version V: queries of it answer exactly as queries of
# the exported revision did. Its HIR is decoded from interchange text (which
# refuses another front end's text, {HIR INTERCHANGE COMPILER}) and is
# activated whenever a query reads it (Use), as any revision's is. TEXT
# made by a service with another configuration than this process's front
# end is refused ({SERVICE IMPORT}): a revision is a function of its
# configuration. Its sources are compared with WS's documents and the disk
# by `stale`, like those of a revision analyzed in WS.
proc service::import {ws text args} {
    variable exportVersion
    variable workspaces
    variable revisions
    variable nextRevision
    set options [Options service::import {-version ""} $args]
    set workspace [Workspace $ws]
    set newline [string first \n $text]
    set header [string range $text 0 [expr {$newline - 1}]]
    if {$newline < 0 || $header ne "botlish-service-revision $exportVersion"} {
        Fail IMPORT "not an exported revision of this service (it starts \"[string range $header 0 40]\")"
    }
    set body [string range $text [expr {$newline + 1}] end]
    set keys {entry outcome semantics errors warnings failure config sources hir}
    if {[catch {dict size $body}] || [lmap key $keys {dict exists $body $key}] ne [lrepeat [llength $keys] 1]} {
        Fail IMPORT "an exported revision without its [join $keys {, }]"
    }
    set config [dict get $body config]
    foreach {key mine} [list frontEnd [hir::interchange::fingerprint] library $::core::libraryDir] {
        if {[dict getdef $config $key ""] ne $mine} {
            Fail IMPORT "an exported revision of another configuration ($key [dict getdef $config $key ""], here $mine)"
        }
    }
    set revision [dict create]
    foreach key {entry outcome semantics errors warnings failure config sources} {
        dict set revision $key [dict get $body $key]
    }
    set hir [dict get $body hir]
    if {$hir ne ""} {
        set hir [hir::interchange::decode $hir]
    }
    dict set revision hir $hir
    set rev rev[incr nextRevision]
    dict set revision id $rev
    dict set revision workspace $ws
    dict set revision version [dict get $options -version]
    set derived [dict getdef $body derived [dict create]]
    if {[catch {dict size $derived}] || [lsort -unique [concat [dict keys $derived] {lines syntax semantic declarations dfaNames}]] ne {declarations dfaNames lines semantic syntax}} {
        Fail IMPORT "an exported revision whose derived data are not its query indexes"
    }
    dict set revision derived $derived
    dict set revisions $rev $revision
    dict set workspaces $ws revisions [concat [dict get $workspace revisions] [list $rev]]
    return $rev
}

# Releases revision REV: the service keeps nothing of it (its HIR, ASTs,
# indexes and texts go with it).
proc service::release {rev} {
    variable revisions
    variable workspaces
    set revision [Get $rev]
    dict unset revisions $rev
    set ws [dict get $revision workspace]
    if {[dict exists $workspaces $ws]} {
        dict set workspaces $ws revisions [lmap r [dict get $workspaces $ws revisions] {
            if {$r eq $rev} continue
            set r
        }]
    }
    return
}

# The live revisions, of workspace WS or of every workspace, oldest first.
proc service::revisions {{ws ""}} {
    variable revisions
    if {$ws ne ""} {
        return [dict get [Workspace $ws] revisions]
    }
    return [dict keys $revisions]
}

# What the service holds: workspaces, revisions, the revisions holding a HIR,
# and the derived structures computed for queries (Derived), by kind.
proc service::state {} {
    variable workspaces
    variable revisions
    set withHir 0
    set derived [dict create]
    dict for {rev revision} $revisions {
        if {[dict get $revision hir] ne ""} {
            incr withHir
        }
        dict for {kind values} [dict get $revision derived] {
            dict incr derived $kind [dict size $values]
        }
    }
    return [dict create workspaces [dict size $workspaces] revisions [dict size $revisions] \
        hirs $withHir derived $derived]
}

# ---------------------------------------------------------------------------
# Derived data: computed from a revision on first use, kept with it, released
# with it. Each is a pure function of the revision's own sources and HIR, so
# computing it later than the analysis changes nothing a query answers.

# The derived value KIND/KEY of revision REV, computed by COMMAND (a command
# prefix, given the revision) when it is not there yet.
proc service::Derived {rev kind key command} {
    variable revisions
    if {[dict exists $revisions $rev derived $kind $key]} {
        return [dict get $revisions $rev derived $kind $key]
    }
    set value [{*}$command [dict get $revisions $rev]]
    dict set revisions $rev derived $kind $key $value
    return $value
}

# Computes now every index the queries of revision REV use, and loads
# Compilerpedia's catalogue (a process's first topic lookup reads it): what
# a query would compute on first use, done before the first query (a
# transport calls it after an analysis, off the request path). Queries
# answer the same with or without it. -paths PATHS limits the per-source
# indexes to those of PATHS (the documents an editor has open: a path the
# revision did not read is skipped); -compilerpedia 0 leaves the catalogue
# unloaded.
proc service::prepare {rev args} {
    set options [Options service::prepare {-paths "" -compilerpedia 1} $args]
    set revision [Use $rev]
    set paths {}
    dict for {path observation} [dict get $revision sources] {
        if {[dict exists $observation text]} {
            lappend paths $path
        }
    }
    if {[dict exists $args -paths]} {
        set paths [lsort -unique [lmap path [dict get $options -paths] {
            set source [SourcePath $revision $path]
            if {$source eq ""} continue
            set source
        }]]
    }
    foreach path $paths {
        Derived $rev lines $path [list service::Lines $path]
        Derived $rev syntax $path [list service::SyntaxIndex $path]
    }
    if {[QueryHir $revision] ne ""} {
        set index [Derived $rev semantic all [list service::SemanticIndex]]
        dict for {f path} [dict get $index files] {
            if {$path in $paths} {
                Derived $rev declarations $f [list service::DeclarationIndex $f]
            }
        }
        foreach path $paths {
            Derived $rev dfaNames $path [list service::DfaNameIndex $path]
        }
    }
    if {[dict get $options -compilerpedia]} {
        Compilerpedia
        compilerpedia::symbolTopics ""
    }
    return
}

# The offset of each line's start in source PATH of a revision (LineStarts).
proc service::Lines {path revision} {
    return [LineStarts [dict get $revision sources $path text]]
}

# The offset of each line's start in TEXT, line 1 first.
proc service::LineStarts {text} {
    set starts [list 0]
    set at 0
    while {[set at [string first \n $text $at]] >= 0} {
        incr at
        lappend starts $at
    }
    return $starts
}

# The AST of source PATH of a revision, parsed with recovery from the text the
# revision read (surface::modules::Parse: the loader's own AST for a file
# that parses).
proc service::Ast {path revision} {
    return [surface::modules::Parse $path [dict get $revision sources $path text]]
}

# An interval index: ITEMS {START END VALUE ...} (END exclusive; START = END
# a position) sorted by start, outermost first among equal starts, with each
# item's parent: the innermost earlier item containing it. The innermost item
# holding an offset is then found by a binary search and a walk up the
# parents (Innermost): logarithmic in the items, linear only in the nesting.
# Ranges from source spans nest; where two cross, an item's parent is the
# innermost one open where it starts, which is still deterministic.
proc service::IntervalIndex {items} {
    set sorted [lsort -stride 3 -integer -index 0 [lsort -stride 3 -integer -decreasing -index 1 $items]]
    set starts {}
    set ends {}
    set values {}
    set parents {}
    set stack {}
    set i 0
    foreach {start end value} $sorted {
        while {$stack ne {}} {
            set top [lindex $stack end]
            set topEnd [lindex $ends $top]
            if {$start < $topEnd || ($start == $topEnd && $start == [lindex $starts $top] && $end == $start)} {
                break
            }
            set stack [lrange $stack 0 end-1]
        }
        lappend parents [if {$stack eq {}} {string cat -1} else {lindex $stack end}]
        lappend starts $start
        lappend ends $end
        lappend values $value
        lappend stack $i
        incr i
    }
    return [dict create starts $starts ends $ends values $values parents $parents]
}

# 1 if item I of INDEX holds OFFSET.
proc service::Holds {index i offset} {
    set start [lindex [dict get $index starts] $i]
    set end [lindex [dict get $index ends] $i]
    return [expr {($start <= $offset && $offset < $end) || ($start == $end && $offset == $start)}]
}

# The items of INDEX that hold OFFSET, innermost first ({} if none): the
# innermost, then each enclosing one.
proc service::Innermost {index offset} {
    set starts [dict get $index starts]
    # The last item starting at or before OFFSET.
    set low 0
    set high [expr {[llength $starts] - 1}]
    set found -1
    while {$low <= $high} {
        set mid [expr {($low + $high) / 2}]
        if {[lindex $starts $mid] <= $offset} {
            set found $mid
            set low [expr {$mid + 1}]
        } else {
            set high [expr {$mid - 1}]
        }
    }
    set parents [dict get $index parents]
    set chain {}
    for {set i $found} {$i >= 0} {set i [lindex $parents $i]} {
        if {[Holds $index $i $offset]} {
            lappend chain $i
        }
    }
    return $chain
}

# The syntax index of source PATH of a revision: every AST node with a span,
# {index INTERVALS nodes ID->{kind K span S ?nameSpan N?}}. A node shares
# its id with its suite (a function's body): the id names the outer one.
proc service::SyntaxIndex {path revision} {
    set ast [Ast $path $revision]
    set items {}
    set nodes [dict create]
    foreach import [dict getdef $ast imports {}] {
        SyntaxWalk $import items nodes
    }
    SyntaxWalk $ast items nodes
    return [dict create index [IntervalIndex $items] nodes $nodes]
}

proc service::SyntaxWalk {node itemsVar nodesVar} {
    upvar 1 $itemsVar items $nodesVar nodes
    if {[dict exists $node span] && [dict exists $node id]} {
        set span [dict get $node span]
        set id [dict get $node id]
        lappend items [dict get $span start] [dict get $span end] $id
        if {![dict exists $nodes $id]} {
            set record [dict create kind [dict get $node kind] span $span]
            if {[dict exists $node nameSpan] && [dict get $node nameSpan] ne ""} {
                dict set record nameSpan [dict get $node nameSpan]
            }
            dict set nodes $id $record
        }
    }
    if {[dict exists $node kind] && [dict get $node kind] ni {import typeimport}} {
        foreach child [surface::ast::Children $node] {
            SyntaxWalk $child items nodes
        }
    }
}

# The semantic index of a revision's query HIR (QueryHir), all files:
#
#   files       FileId -> path, and paths -> FileId (`ids`)
#   exprs       FileId -> the interval index of its expressions (an
#               expression's range is its origin's span); among equal
#               ranges the one first in the HIR's pre-order walk -- the
#               written construct, before the expressions the front end
#               expanded it to -- is the outermost
#   references  BindingId -> the `ref` expressions resolved to it, in
#               pre-order
#   bindings    FileId -> the BindingIds whose origin is in that file
proc service::SemanticIndex {revision} {
    set hir [QueryHir $revision]
    set files [dict create]
    set ids [dict create]
    # Every file has an index, the empty one when no expression is written
    # there (a module of declarations only).
    set items [dict create]
    dict for {f entry} [dict get $hir files] {
        dict set files $f [dict get $entry path]
        dict set ids [dict get $entry path] $f
        dict set items $f {}
    }
    set references [dict create]
    foreach e [hir::walk $hir] {
        set node [dict get $hir exprs $e]
        set origin [dict get $node origin]
        if {[lindex $origin 0] eq "file"} {
            set fields [lrange $origin 2 end]
            dict lappend items [lindex $origin 1] [dict get $fields start] [dict get $fields end] $e
        }
        if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""
                && ![dict exists $hir syntaxDependent $e]} {
            # (A name whose binding depends on malformed source refers to it
            # only perhaps: SYNTAX-RECOVERY-MILESTONE-1.md.)
            dict lappend references [dict get $node binding] $e
        }
    }
    set exprs [dict create]
    dict for {f list} $items {
        # (In pre-order, which IntervalIndex's stable sorts keep among equal
        # ranges.)
        dict set exprs $f [IntervalIndex $list]
    }
    set bindings [dict create]
    dict for {b binding} [dict get $hir bindings] {
        set origin [dict get $binding origin]
        if {[dict get $binding kind] in {root ambient} || [lindex $origin 0] ne "file"} continue
        dict lappend bindings [lindex $origin 1] $b
    }
    return [dict create files $files ids $ids exprs $exprs references $references bindings $bindings]
}

# The declaration sites of file F (a FileId) of a revision's query HIR: where
# each binding declared there is written by name -- the AST's `nameSpan` of
# its declaration (a function's or a binding's name), else its origin's own
# span (a parameter's, a loop variable's, a destructured field's are just the
# name) -- {index INTERVALS sites BindingId->SPAN}. A binding is declared
# where the source text spells its written name (hir::semantic::SourceName,
# without its namespace): a binding the front end introduced (a hygienic
# temporary) has no such place, and none here.
proc service::DeclarationIndex {f revision} {
    set hir [QueryHir $revision]
    set rev [dict get $revision id]
    set index [Derived $rev semantic all [list service::SemanticIndex]]
    set path [dict get $index files $f]
    set sites [dict create]
    set items {}
    if {[dict exists $revision sources $path text]} {
        set text [dict get $revision sources $path text]
        set syntax [Derived $rev syntax $path [list service::SyntaxIndex $path]]
        foreach b [dict getdef $index bindings $f {}] {
            set site [NameSite $hir $b $text [dict get $syntax nodes]]
            if {$site ne ""} {
                dict set sites $b $site
                lappend items [dict get $site start] [dict get $site end] $b
            }
        }
    }
    return [dict create index [IntervalIndex $items] sites $sites]
}

# The names of recognizer declarations in source PATH of a revision:
# {index INTERVALS all FACTS}, the intervals of the facts written in PATH,
# FACTS every fact of the program (surface/dfa.tcl's Fact: {kind use decl
# hover}).
proc service::DfaNameIndex {path revision} {
    set all [dict getdef [dict get $revision hir] dfaNames {}]
    set items {}
    foreach fact $all {
        if {[dict get $fact use file] eq $path} {
            lappend items [dict get $fact use start] [dict get $fact use end] $fact
        }
    }
    return [dict create index [IntervalIndex $items] all $all]
}

# The span in TEXT where binding B of HIR is declared by name (above), or "".
proc service::NameSite {hir b text nodes} {
    set origin [dict get $hir bindings $b origin]
    set fields [lrange $origin 2 end]
    set name [namespace tail [hir::semantic::SourceName $hir $b]]
    set candidates {}
    set node [dict getdef $fields node ""]
    if {[dict exists $nodes $node nameSpan]} {
        lappend candidates [dict get $nodes $node nameSpan]
    }
    set span [dict create]
    foreach key {start end line column endLine endColumn} {
        dict set span $key [dict get $fields $key]
    }
    lappend candidates $span
    foreach candidate $candidates {
        set start [dict get $candidate start]
        set end [dict get $candidate end]
        if {$end > $start && [string range $text $start [expr {$end - 1}]] eq $name} {
            return $candidate
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Position queries

# The facts at LINE and COLUMN (the compiler's: 1-based, counting Unicode
# scalar values of the normalized text) of source PATH of revision REV: what
# the revision knows there, and only that. -version V, when given, must be
# the version of PATH's buffer the revision read (an editor's document
# version): a query about any other text of PATH is refused ({SERVICE
# STALE}), never answered with positions of one text and facts of another.
#
# The result: revision, path (the revision's spelling of it), position
# {line L column C offset O}, each available fact --
#
#   syntax       the innermost AST node there: {kind K node ID range R}
#   construct    the innermost construct: the declaration whose name is
#                written there ({kind declaration binding B range R}), else
#                the innermost HIR expression ({kind K expr E node ID range
#                R}; among expressions with equal ranges the written one,
#                not what the front end expanded it to), with `enclosing`,
#                the expressions around it, innermost first ({kind expr
#                range} each)
#   binding      the binding the construct declares or refers to: {id B name
#                N kind local|param|root|ambient module NS node ID} -- name
#                its source name, module the canonical namespace of the
#                module declaring it ("" for the entry program), node the AST
#                node id of its declaration ({module, node} is the identity
#                of a declaration across revisions that keep the
#                declaration's place: COMPILER-SERVICE-MILESTONE-1.md; B is
#                its identity within this revision only)
#   type         {text T}: the construct's type as a person reads it
#                (hir::types::presented: never an expression id)
#   hover        a line of text: a function's signature (hir::signatures::
#                text), "NAME: TYPE" for another binding, the type otherwise
#   definition   the range of the binding's declaration: its name where the
#                source writes it, else its whole declaration
#   references   the ranges of every reference to the binding in this
#                revision (by resolved identity, never by name), in source
#                order per file, files in the HIR's order
#   diagnostics  the revision's diagnostics whose range holds the position
#   topics       the Compilerpedia topics of those diagnostics, and of a
#                standard-library binding the construct resolves to:
#                {id ID title T for {diagnostic CODE}|{symbol NAME}} each
#
# -- and `unavailable`: each fact it does not have -> why (no HIR: a syntax
# or loader error; no binding there; ...). Every fact is in exactly one of
# the two.
proc service::at {rev path line column args} {
    variable facts
    set options [Options service::at {-version ""} $args]
    set revision [Use $rev]
    set source [SourcePath $revision $path]
    if {$source eq ""} {
        Fail NOT-A-SOURCE "revision $rev read no source text at $path"
    }
    set observation [dict get $revision sources $source]
    if {[dict exists $args -version] && [dict get $options -version] ne [dict getdef $observation version ""]} {
        if {[dict get $observation from] eq "buffer"} {
            set what "version \"[dict getdef $observation version ""]\" of its buffer"
        } else {
            set what "the file on disk, not a buffer"
        }
        Fail STALE "revision $rev analyzed $what at $source, not version \"[dict get $options -version]\": its positions are not that text's"
    }
    set offset [Offset $revision $source $line $column]
    set result [dict create revision $rev path $source position [dict create line $line column $column offset $offset]]
    set unavailable [dict create]
    # Syntax: any source the revision read has an AST.
    set syntax [Derived $rev syntax $source [list service::SyntaxIndex $source]]
    set chain [Innermost [dict get $syntax index] $offset]
    if {$chain ne {}} {
        set id [lindex [dict get $syntax index values] [lindex $chain 0]]
        set node [dict get $syntax nodes $id]
        dict set result syntax [dict create kind [dict get $node kind] node $id \
            range [Range [dict merge [dict get $node span] [dict create file $source]]]]
    } else {
        dict set unavailable syntax "no syntax node at this position"
    }
    # The diagnostics there, and their topics.
    set here [lmap d [diagnostics $rev] {
        # (A diagnostic names its file as the compiler does: as the
        # revision's sources do.)
        if {[dict get $d range] eq "none" || [dict get $d file] ne $source} continue
        set start [dict get $d start]
        set end [dict get $d end]
        if {!(($start <= $offset && $offset < $end) || ($start == $end && $offset == $start))} continue
        set d
    }]
    dict set result diagnostics $here
    set topics {}
    foreach d $here {
        set topic [explain $d]
        if {$topic ne {} && [dict get $topic id] ni [lmap t $topics {dict get $t id}]} {
            lappend topics [dict create id [dict get $topic id] title [dict get $topic title] \
                for [list diagnostic [dict get $d code]]]
        }
    }
    set hir [QueryHir $revision]
    if {$hir eq ""} {
        set reason "no semantic analysis: the revision's outcome is [dict get $revision outcome] (no HIR)"
        foreach fact {construct binding type hover definition references} {
            dict set unavailable $fact $reason
        }
        dict set result topics $topics
        dict set result unavailable $unavailable
        return $result
    }
    # A name in a recognizer declaration -- a state, a class, a called
    # recognizer -- is no binding of the program: its facts are the ones the
    # declaration's checker recorded (the HIR's `dfaNames`, surface/dfa.tcl's
    # Fact; DFA-COROUTINE-MILESTONE-2.md).
    set names [Derived $rev dfaNames $source [list service::DfaNameIndex $source]]
    set chain [Innermost [dict get $names index] $offset]
    if {$chain ne {}} {
        set fact [lindex [dict get $names index values] [lindex $chain 0]]
        set kind [dict get $fact kind]
        dict set result construct [dict create kind dfa-$kind range [Range [dict get $fact use]]]
        dict set result hover [dict get $fact hover]
        dict set result definition [Range [dict get $fact decl]]
        dict set result references [lmap other [dict get $names all] {
            if {[dict get $other decl] ne [dict get $fact decl] || [dict get $other use] eq [dict get $other decl]} continue
            Range [dict get $other use]
        }]
        set why [dict get {
            state "a state of a recognizer is no binding or value of the program"
            class "a class names symbols of recognizer declarations: it is no binding or value of the program"
            recognizer "a recognizer a declaration calls is named as a callee here: its declaration's name is the binding of its coroutine function"
        } $kind]
        foreach missing {binding type} {
            dict set unavailable $missing $why
        }
        Compilerpedia
        if {"concept.recognizers" ni [lmap t $topics {dict get $t id}]} {
            lappend topics [dict create id concept.recognizers \
                title [dict get [compilerpedia::topic concept.recognizers] title] for [list syntax dfa-$kind]]
        }
        dict set result topics $topics
        dict set result unavailable $unavailable
        return $result
    }
    set index [Derived $rev semantic all [list service::SemanticIndex]]
    set f [dict getdef [dict get $index ids] $source ""]
    set construct ""
    set binding ""
    set e ""
    if {$f ne ""} {
        set declarations [Derived $rev declarations $f [list service::DeclarationIndex $f]]
        set names [Innermost [dict get $declarations index] $offset]
        if {$names ne {}} {
            set binding [lindex [dict get $declarations index values] [lindex $names 0]]
            set construct [dict create kind declaration binding $binding \
                range [Range [dict merge [dict get $declarations sites $binding] [dict create file $source]]]]
        }
        set exprs [Innermost [dict get $index exprs $f] $offset]
        # Equal ranges: the written construct, the outermost of them.
        set values [dict get $index exprs $f values]
        set starts [dict get $index exprs $f starts]
        set ends [dict get $index exprs $f ends]
        while {[llength $exprs] > 1
                && [lindex $starts [lindex $exprs 0]] == [lindex $starts [lindex $exprs 1]]
                && [lindex $ends [lindex $exprs 0]] == [lindex $ends [lindex $exprs 1]]} {
            set exprs [lrange $exprs 1 end]
        }
        if {$construct eq "" && $exprs ne {}} {
            set e [lindex $values [lindex $exprs 0]]
            set node [dict get $hir exprs $e]
            set construct [dict create kind [dict get $node kind] expr $e \
                node [dict get [lrange [dict get $node origin] 2 end] node] \
                range [OriginRange $hir [dict get $node origin]]]
            if {[dict get $node kind] in {ref bind}} {
                set binding [dict get $node binding]
            }
        }
        if {$construct ne ""} {
            set outer $exprs
            if {$e ne ""} {
                set outer [lrange $exprs 1 end]
            }
            dict set construct enclosing [lmap i $outer {
                set x [lindex $values $i]
                dict create kind [dict get $hir exprs $x kind] expr $x \
                    range [OriginRange $hir [dict get $hir exprs $x origin]]
            }]
        }
    }
    if {$construct eq ""} {
        foreach fact {construct binding type hover definition references} {
            dict set unavailable $fact "no expression or declaration of the program at this position"
        }
        dict set result topics $topics
        dict set result unavailable $unavailable
        return $result
    }
    dict set result construct $construct
    if {$e ne "" && [dict exists $hir syntaxDependent $e] && [dict get $hir exprs $e kind] eq "ref"} {
        # Which binding the name denotes depends on malformed source
        # (SYNTAX-RECOVERY-MILESTONE-1.md): never a guess.
        set binding ""
    }
    if {$binding eq ""} {
        if {$e ne "" && [dict exists $hir exprs $e hole]} {
            set reason "malformed source: no meaning is known for it (its syntax error says why)"
        } elseif {$e ne "" && [dict exists $hir syntaxDependent $e] && [dict get $hir exprs $e kind] eq "ref"} {
            set reason "a malformed statement before it, in a scope it sees, may bind this name: which binding it denotes is not known"
        } elseif {[dict get $construct kind] eq "ref"} {
            set reason "the name is not resolved (its diagnostic says why)"
        } else {
            set reason "this construct is not a name"
        }
        foreach fact {binding definition references} {
            dict set unavailable $fact $reason
        }
        # The expression's own type.
        set type [hir::typeOf $hir $e]
        set unknown [TypeUnknown $hir $e "" $type]
        if {$unknown ne ""} {
            dict set unavailable type $unknown
            dict set unavailable hover $unknown
        } else {
            dict set result type [dict create text [hir::types::presented $type]]
            dict set result hover [Hover $hir $type ""]
        }
    } else {
        set record [BindingFacts $hir $binding]
        dict set result binding $record
        if {$e ne "" && [dict get $hir exprs $e kind] eq "ref"} {
            # A reference: its type where it is read (flow facts included).
            set type [hir::typeOf $hir $e]
            set unknown [TypeUnknown $hir $e $binding $type]
        } else {
            set type [BindingType $hir $binding]
            set unknown [TypeUnknown $hir "" $binding $type]
        }
        if {$unknown ne ""} {
            dict set unavailable type $unknown
            dict set unavailable hover $unknown
        } else {
            dict set result type [dict create text [hir::types::presented $type]]
            dict set result hover [Hover $hir $type $binding]
        }
        set definition [Definition $rev $revision $index $binding]
        if {[lindex $definition 0] eq "unavailable"} {
            dict set unavailable definition [lindex $definition 1]
        } else {
            dict set result definition $definition
        }
        dict set result references [lmap r [dict getdef $index references $binding {}] {
            OriginRange $hir [dict get $hir exprs $r origin]
        }]
        set symbol [SymbolOf $hir $binding]
        if {$symbol ne ""} {
            Compilerpedia
            foreach id [compilerpedia::symbolTopics $symbol] {
                if {$id ni [lmap t $topics {dict get $t id}]} {
                    lappend topics [dict create id $id title [dict get [compilerpedia::topic $id] title] \
                        for [list symbol $symbol]]
                }
            }
        }
    }
    dict set result topics $topics
    dict set result unavailable $unavailable
    return $result
}

# The offset of LINE and COLUMN in source PATH of REVISION; {SERVICE
# POSITION} outside its text (a column one past a line's last character, its
# end, is inside).
proc service::Offset {revision path line column} {
    set rev [dict get $revision id]
    set starts [Derived $rev lines $path [list service::Lines $path]]
    if {![string is integer -strict $line] || ![string is integer -strict $column]
            || $line < 1 || $line > [llength $starts] || $column < 1} {
        Fail POSITION "line $line, column $column is not a position of $path (lines 1 to [llength $starts], columns from 1)"
    }
    set start [lindex $starts [expr {$line - 1}]]
    if {$line < [llength $starts]} {
        set length [expr {[lindex $starts $line] - 1 - $start}]
    } else {
        set length [expr {[string length [dict get $revision sources $path text]] - $start}]
    }
    if {$column - 1 > $length} {
        Fail POSITION "line $line of $path has [expr {$length + 1}] columns, not $column"
    }
    return [expr {$start + $column - 1}]
}

# ORIGIN (a HIR source origin) of HIR as a range ({file start end line
# column endLine endColumn}), "" for an origin that is not a source span.
proc service::OriginRange {hir origin} {
    set span [hir::originSpan $hir $origin]
    if {$span eq ""} {
        return ""
    }
    return [Range $span]
}

# The facts of binding B of HIR (at).
proc service::BindingFacts {hir b} {
    set binding [dict get $hir bindings $b]
    set origin [dict get $binding origin]
    set node ""
    if {[lindex $origin 0] eq "file"} {
        set node [dict get [lrange $origin 2 end] node]
    }
    return [dict create id $b name [hir::semantic::SourceName $hir $b] kind [dict get $binding kind] \
        module [ModuleOf $hir $b] node $node]
}

# The type of binding B of HIR as declared: a function parameter's is the
# contract its function is entered with (hir::signatures::paramType: the
# declared type, else the inferred one, else any); any other binding's, the
# type of the value it is bound to (hir::bindingType).
proc service::BindingType {hir b} {
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "param"} {
        set owner [dict get $hir scopes [dict get $binding scope] owner]
        if {$owner ne "" && [dict get $hir exprs $owner kind] eq "block"} {
            set i [lsearch -exact [dict get $hir exprs $owner params] $b]
            if {$i >= 0} {
                return [hir::signatures::paramType [lindex [dict get [hir::signatures::of $hir $owner] params] $i]]
            }
        }
    }
    return [hir::bindingType $hir $b]
}

# Why the TYPE of expression E ("" for none) or binding B ("" for none) of
# HIR is not known, or "": E or B is poison (hir/types.tcl, "Poison") --
# source nobody could read, a value that depends on it
# (SYNTAX-RECOVERY-MILESTONE-1.md), or one an earlier check proved invalid --
# or TYPE is a function whose result is (an incomplete body's). Never a
# placeholder type for an unknown one.
proc service::TypeUnknown {hir e b type} {
    if {$e ne "" && [dict exists $hir exprs $e hole]} {
        return "malformed source: no meaning is known for it (its syntax error says why)"
    }
    if {$e ne "" && [dict exists $hir syntaxDependent $e]} {
        return "its meaning depends on malformed source (a syntax error says where)"
    }
    # (A function's poison is its result's, below: the function is known.)
    if {($e ne "" && [dict exists $hir poisoned $e] && [dict get $hir exprs $e kind] ne "block")
            || ($b ne "" && [dict exists $hir poisoned $b])} {
        if {[dict exists $hir syntaxRecovery]} {
            return "its value is not known: it depends on malformed source or on a construct a diagnostic rejects"
        }
        return "its value is not known: it depends on a construct a diagnostic rejects"
    }
    if {$b ne "" && [dict get $hir bindings $b kind] eq "param"} {
        set owner [dict get $hir scopes [dict get $hir bindings $b scope] owner]
        if {$owner ne "" && [dict exists $hir holeBlocks $owner]
                && [lindex [dict get $hir exprs $owner declaredParamTypes] \
                    [lsearch -exact [dict get $hir exprs $owner params] $b]] eq {}} {
            return "its contract is not known: it declares no type, and its function's body, which would require one, holds malformed source"
        }
    }
    if {[hir::types::IsExactBlock $type] && [dict exists $hir exprs [lindex $type 1]]} {
        set block [lindex $type 1]
        if {[dict exists $hir holeBlocks $block]
                && ([dict get $hir exprs $block declaredResult] eq {} || {} in [dict get $hir exprs $block declaredParamTypes])} {
            # (Only a fully declared signature is known of a function whose
            # body holds malformed source: SYNTAX-RECOVERY-MILESTONE-1.md.)
            return "its signature is not known: its body holds malformed source and the signature does not declare every type"
        }
        if {[dict exists $hir poisoned $block] && [dict get $hir exprs $block declaredResult] eq {}} {
            return "its result is not known: its body depends on a construct a diagnostic rejects"
        }
    }
    return ""
}

# The canonical namespace of the module that declares binding B of HIR, ""
# for the entry program or a binding of no module (a root one).
proc service::ModuleOf {hir b} {
    set modules [dict getdef $hir modules {}]
    for {set s [dict get $hir bindings $b scope]} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        if {[dict exists $hir moduleScopeIds $s]} {
            dict for {ns scope} $modules {
                if {$scope eq $s} {
                    return $ns
                }
            }
        }
    }
    return ""
}

# The hover line of a construct of TYPE in HIR, whose binding is B ("" for
# none): a function's signature (`private fn ...` for a private one),
# "NAME: TYPE" for another binding, TYPE otherwise.
proc service::Hover {hir type b} {
    if {[hir::types::IsExactBlock $type] && [dict exists $hir exprs [lindex $type 1]]} {
        # (A private function says so: MODULE-PRIVACY-AND-CONTEXT-ESCAPE-
        # MILESTONE-1.md.)
        set prefix [expr {$b ne "" && [hir::privacy::BindingPrivate $hir $b] ? "private " : ""}]
        return "$prefix[hir::signatures::text $hir [lindex $type 1]]"
    }
    if {$b eq ""} {
        return [hir::types::presented $type]
    }
    return "[hir::semantic::SourceName $hir $b]: [hir::types::presented $type]"
}

# The definition of binding B (at): its declaration site's range, or
# {unavailable REASON}.
proc service::Definition {rev revision index b} {
    set hir [QueryHir $revision]
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] in {root ambient}} {
        return [list unavailable "a compiler intrinsic: no source declares it"]
    }
    set origin [dict get $binding origin]
    if {[lindex $origin 0] ne "file"} {
        return [list unavailable "its declaration has no source location"]
    }
    set f [lindex $origin 1]
    set path [dict get $index files $f]
    set declarations [Derived $rev declarations $f [list service::DeclarationIndex $f]]
    if {[dict exists $declarations sites $b]} {
        return [Range [dict merge [dict get $declarations sites $b] [dict create file $path]]]
    }
    # Introduced by the front end: its whole construct.
    return [OriginRange $hir $origin]
}

# The Compilerpedia symbol binding B of HIR is, or "": a root native, by its
# registered name, or a declaration of a standard-library module, by its
# canonical name -- the identities generated/stdlib.topic documents
# (tools/compilerpedia.tcl generates it from the registry and stdlib/). Never a
# name that only resembles one: an application's declarations have none.
proc service::SymbolOf {hir b} {
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "root"} {
        set symbol [dict getdef $binding symbol ""]
        if {$symbol eq "" || ![dict exists $hir symbols $symbol]} {
            return ""
        }
        set entry [dict get $hir symbols $symbol]
        if {[dict get $entry kind] ne "native"} {
            return ""
        }
        return [dict get $entry name]
    }
    set module [ModuleOf $hir $b]
    set origin [dict get $binding origin]
    if {$module eq "" || [lindex $origin 0] ne "file" || [hir::isModuleBinding $hir $b] == 0} {
        return ""
    }
    set path [file normalize [dict get $hir files [lindex $origin 1] path]]
    set library [file normalize $::core::libraryDir]
    if {[string first $library/ $path] != 0} {
        return ""
    }
    return [hir::semantic::SourceName $hir $b]
}

# Loads Compilerpedia (compilerpedia/compilerpedia.tcl: the catalogue only,
# no compiler) unless it is loaded.
proc service::Compilerpedia {} {
    variable home
    if {[info commands ::compilerpedia::topicForDiagnostic] eq ""} {
        uplevel #0 [list source [file join $home compilerpedia compilerpedia.tcl]]
    }
}

# The Compilerpedia topic of DIAGNOSTIC (a record of `diagnostics`): {id ID
# title T summary S}, or {} when no topic documents it. The lookup main.tcl's
# "help:" lines make -- compilerpedia::topicForDiagnostic of its code and
# text -- so the service and the command line point at the same topic.
# Compilerpedia is loaded on first use; it never loads the compiler.
proc service::explain {diagnostic} {
    Compilerpedia
    set id [compilerpedia::topicForDiagnostic [dict get $diagnostic code] [dict get $diagnostic text]]
    if {$id eq ""} {
        return {}
    }
    set topic [compilerpedia::topic $id]
    return [dict create id $id title [dict get $topic title] summary [dict get $topic summary]]
}
