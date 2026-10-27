# compilerpedia.tcl -- the maintenance tool of Compilerpedia, the compiler's
# built-in reference (COMPILERPEDIA.md). A development tool: the compiler and
# its -help never run it.
#
#   tclsh9.0 tools/compilerpedia.tcl generate
#   tclsh9.0 tools/compilerpedia.tcl check ?-examples 0|1? ?-backends LIST? ?-format text|data?
#   tclsh9.0 tools/compilerpedia.tcl examples ?-match GLOB? ?-backends LIST? ?-format text|data?
#   tclsh9.0 tools/compilerpedia.tcl inventory ?-undocumented 1?
#
# generate   writes compilerpedia/generated/stdlib.topic: a topic per
#            standard-library module and per public symbol, derived from the
#            compiler's own registries and sources -- each native's
#            signature, errors, method eligibility and backend availability
#            from core::native's registry; each library declaration and its
#            comment from stdlib/*.bot (surface::parse) -- merged with the prose
#            of compilerpedia/notes/stdlib.notes (the intrinsics have no
#            source comment). Deterministic: no time, path or host in it.
# check      every check a commit must pass (exit 1 on any problem): the
#            catalogue's structure (compilerpedia::validate); the generated
#            file is what generate would write; every diagnostic code and
#            kind the compiler's source names, and every registered warning,
#            has a topic (Inventory: an independent scan of the source, never
#            a list kept by hand); every warning topic carries the sections
#            the warnings index requires and an accepted and a silent
#            example; every diagnostic matcher is exercised by a rejected
#            example; and, unless -examples 0, every example compiles,
#            runs and is rejected exactly as documented (examples).
# examples   only the examples: each accepted example compiles through the
#            public front end (surface::readProgramFile, in its own scratch
#            directory, strict, warnings default; one importing another
#            operating system's platform namespace, for that system's
#            target, on the Tcl backends) with exactly the stated
#            warnings and runs on each stated backend to the stated value
#            (and, with @output, prints the stated lines through main.tcl);
#            each rejected one is rejected with the stated primary
#            diagnostic -- its code, location and message read from the
#            structured diagnostics, never from printed text -- which points
#            (compilerpedia::topicForDiagnostic) at its own topic when the
#            topic documents that code or matches it.
# inventory  the diagnostic inventory, each code with the topic that
#            documents it.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root compilerpedia compilerpedia.tcl]
core::useProgramRecursionLimit

namespace eval cpt {
    variable root $::root
    variable generated [file join $::root compilerpedia generated stdlib.topic]
    variable notes [file join $::root compilerpedia notes stdlib.notes]
    variable allBackends {interp compile cranelift-generic cranelift}
}

proc cpt::Options {arguments defaults} {
    set options $defaults
    foreach {k v} $arguments {
        if {![dict exists $defaults $k]} {
            puts stderr "compilerpedia: unknown option $k (known: [join [dict keys $defaults] {, }])"
            exit 2
        }
        dict set options $k $v
    }
    return $options
}

proc cpt::ReadFile {path} {
    set channel [open $path r]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

proc cpt::WriteFile {path text} {
    file mkdir [file dirname $path]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# ---------------------------------------------------------------------------
# The standard library, from the registries and the sources

# The library module files, as {NAMESPACE PATH NOTE}: stdlib/ is the
# directory of the namespace std (STD-NAMESPACE.md), so stdlib/NAME.bot is
# std::NAME and stdlib/a/b.bot std::a::b, at any depth; an
# architecture-specific module (stdlib/P.ARCH.bot) is documented from its
# x86_64 file, whose surface the others share (LINUX-SYSCALL-TRANSPORTS.md),
# so the output is the same on every host.
proc cpt::LibraryModules {} {
    variable root
    set lib [file join $root stdlib]
    set modules {}
    foreach path [lsort [ModuleFilesUnder $lib]] {
        set relative [string range $path [string length $lib]+1 end]
        set note ""
        if {[regexp {^(.*)\.(x86_64|aarch64)\.bot$} $relative -> base arch]} {
            if {$arch ne "x86_64"} {
                continue
            }
            set note "architecture-specific: stdlib/$base.x86_64.bot and stdlib/$base.aarch64.bot, chosen by the compilation's target, have one surface"
            set relative $base.bot
        }
        set ns std::[string map {/ ::} [file rootname $relative]]
        if {[core::native::isInternalNamespace $ns]} {
            # An internal module (core::native::declareInternalModule: the
            # map and set engine, std::ordered_table): no program imports
            # it, and no reference documents it as an API.
            continue
        }
        lappend modules [list $ns $path $note]
    }
    return $modules
}

# Every .bot file under DIR, at any depth.
proc cpt::ModuleFilesUnder {dir} {
    set files [glob -nocomplain -directory $dir -types f *.bot]
    foreach sub [glob -nocomplain -directory $dir -types d *] {
        lappend files {*}[ModuleFilesUnder $sub]
    }
    return $files
}

# The leading comment block of TEXT (its "#" lines up to the first other
# line), "# " removed; the file's first line names the file and is dropped
# when it reads "NAME.bot -- ...", whose rest is returned as its summary.
proc cpt::HeaderComment {text} {
    set lines {}
    foreach line [split $text \n] {
        if {![string match #* $line]} {
            break
        }
        lappend lines [regsub {^# ?} $line ""]
    }
    set summary ""
    if {[regexp {^\S+\.bot -- (.*)$} [lindex $lines 0] -> rest]} {
        set lines [lrange $lines 1 end]
        set summary $rest
        # The summary may continue on the following lines, up to a blank one.
        while {[llength $lines] && [string trim [lindex $lines 0]] ne ""} {
            append summary " [string trim [lindex $lines 0]]"
            set lines [lrange $lines 1 end]
        }
    }
    while {[llength $lines] && [string trim [lindex $lines 0]] eq ""} {
        set lines [lrange $lines 1 end]
    }
    while {[llength $lines] && [string trim [lindex $lines end]] eq ""} {
        set lines [lrange $lines 0 end-1]
    }
    return [list $summary $lines]
}

# The comment immediately above line LINE (1-based) of LINES, documenting
# NAME: its "#" lines, "# " removed, up to a blank or other line; {} for
# none. A separator rule (# ----) ends it. A block that starts on the file's
# first line is the file's header comment, never a declaration's. A block of
# several paragraphs (separated by a bare "#") whose later paragraph begins
# with NAME speaks of other declarations first: only the part from that
# paragraph on is NAME's.
proc cpt::CommentAbove {lines line name} {
    set result {}
    for {set i [expr {$line - 2}]} {$i >= 0} {incr i -1} {
        set text [lindex $lines $i]
        if {![string match #* $text] || [regexp {^#\s*-{4,}} $text]} {
            break
        }
        set result [linsert $result 0 [regsub {^# ?} $text ""]]
    }
    if {$i < 0} {
        return {}
    }
    for {set j 1} {$j < [llength $result]} {incr j} {
        if {[string trim [lindex $result $j-1]] eq "" && [string first "$name " [lindex $result $j]] == 0} {
            return [lrange $result $j end]
        }
    }
    return $result
}

# The comment LINES with each paragraph of prose (consecutive lines that start
# with neither a space nor "*") refilled to the topic text width, 76 columns;
# a bulleted item ("* " and its lines indented two spaces) is refilled the
# same way, hanging, when one of its lines is wider than that (a longer
# qualified name, std::abi::I32, can push a written line past it); other
# indented lines (code, tables) and items that fit stay as written.
proc cpt::Reflow {lines} {
    set out {}
    set paragraph {}
    set count [llength $lines]
    for {set i 0} {$i <= $count} {incr i} {
        if {$i < $count} {
            set line [lindex $lines $i]
        } else {
            set line ""
        }
        if {$line ne "" && ![string match {[ *]*} $line]} {
            lappend paragraph $line
            continue
        }
        if {$paragraph ne ""} {
            set filled [compilerpedia::Wrap [join $paragraph " "] "" 76]
            lappend out {*}[split $filled \n]
            set paragraph {}
        }
        if {$i == $count} {
            break
        }
        if {[string match {\* *} $line]} {
            set item [list $line]
            for {set j [expr {$i + 1}]} {$j < $count && [regexp {^  \S} [lindex $lines $j]]} {incr j} {
                lappend item [lindex $lines $j]
            }
            set wide 0
            foreach itemLine $item {
                if {[string length $itemLine] > 76} {
                    set wide 1
                }
            }
            if {$wide} {
                set text [join [lmap itemLine $item {string trim $itemLine}] " "]
                set filled [split [compilerpedia::Wrap [string range $text 2 end] "  " 76] \n]
                lset filled 0 "* [string range [lindex $filled 0] 2 end]"
                lappend out {*}$filled
            } else {
                lappend out {*}$item
            }
            set i [expr {$j - 1}]
            continue
        }
        lappend out $line
    }
    return $out
}

# The first sentence of the comment LINES, for a one-line listing.
proc cpt::FirstSentence {lines} {
    set text [string trim [join $lines " "]]
    if {[regexp {^(.*?[.:;])(\s|$)} $text -> sentence]} {
        set text $sentence
    }
    if {[string length $text] > 150} {
        set text "[string range $text 0 146]..."
    }
    return [string trimright $text ":;"]
}

# The declaration text of NODE (a top-level AST node of SOURCE LINES): a
# function's header (up to its body), any other declaration's lines (at most
# 24), a value binding's first line.
proc cpt::DeclarationText {node lines} {
    set span [dict get $node span]
    set first [dict get $span line]
    set last [dict get $span endLine]
    if {[dict get $node kind] eq "function" && [dict exists $node body span line]} {
        # The header ends where the body (a suite) begins.
        set last [expr {max($first, [dict get $node body span line] - 1)}]
    }
    if {[dict get $node kind] eq "bind"} {
        set last $first
    }
    set last [expr {min($last, $first + 23)}]
    set text {}
    for {set i $first} {$i <= $last} {incr i} {
        set line [string trimright [lindex $lines [expr {$i - 1}]]]
        if {[string trim $line] eq "" || [string match "#*" [string trim $line]]} {
            continue
        }
        lappend text $line
    }
    return $text
}

# The declaration kinds a module's member list shows, and what each is called.
proc cpt::DeclarationKind {node} {
    switch -- [dict get $node kind] {
        function {
            return [expr {[dict get $node nomethod] ? "function (nomethod)" : "function"}]
        }
        structdecl {
            set words {}
            if {[dict exists $node opaque] && [dict get $node opaque]} { lappend words opaque }
            if {[dict exists $node context] && [dict get $node context]} { lappend words context }
            return [join [concat $words struct] " "]
        }
        errordecl { return error }
        enumdecl  { return enum }
        traitdecl { return [expr {[dict exists $node context] && [dict get $node context] ? "context trait" : "trait"}] }
        typedecl  { return type }
        refineddecl - refinedtype { return "refined type" }
        layoutdecl - layout { return layout }
        bind      { return value }
        default   { return [dict get $node kind] }
    }
}

# Which natives source can name: not the internal ones (`#` in the name, the
# compiler's own), not the core-IR-only ones whose names contain `-`, and not
# the members of an internal namespace (core::native::
# declareInternalNamespace: the private table hash), which only the standard
# library's own modules may call and which no reference documents as an API
# (HASHABLE-AND-KEYED-HASH.md).
proc cpt::PublicNative {name} {
    return [expr {[string first # $name] < 0 && ![regexp {[a-z]-[a-z]} $name]
        && ![core::native::isInternal $name]}]
}

# The notes: compilerpedia/notes/stdlib.notes, in the topic format, by ID.
proc cpt::Notes {} {
    variable notes
    set result [dict create]
    foreach topic [compilerpedia::parse [ReadFile $notes] notes/stdlib.notes] {
        dict set result [dict get $topic id] $topic
    }
    return $result
}

# Topic-file text for one generated topic: ID, its header FIELDS (key ->
# value or list), its SECTIONS ({HEADING LINES}), merged with NOTE (a parsed
# notes topic, or ""): the note's summary replaces a derived one, its
# aliases, keywords, related and docs are added, its sections and examples
# follow the derived sections.
proc cpt::TopicText {id fields sections note} {
    if {$note ne ""} {
        if {[dict get $note summary] ne "" && [dict get $note summary] ne "-"} {
            dict set fields summary [dict get $note summary]
        }
        foreach key {alias keywords related docs index} {
            if {[dict get $note $key] ne ""} {
                set merged [expr {[dict exists $fields $key] ? [dict get $fields $key] : {}}]
                foreach value [dict get $note $key] {
                    if {$value ni $merged} {
                        lappend merged $value
                    }
                }
                dict set fields $key $merged
            }
        }
    }
    set out [list "@topic $id"]
    foreach key {title summary index code symbol alias keywords related docs} {
        if {![dict exists $fields $key] || [dict get $fields $key] eq ""} {
            continue
        }
        set value [dict get $fields $key]
        switch -- $key {
            title - summary { lappend out "$key: $value" }
            alias - keywords { lappend out "$key: [join $value {; }]" }
            code { foreach c $value { lappend out "code: $c" } }
            default { lappend out "$key: [join $value { }]" }
        }
    }
    lappend out ""
    foreach section $sections {
        lassign $section heading lines
        lappend out "== $heading" {*}$lines ""
    }
    if {$note ne ""} {
        foreach section [dict get $note body] {
            lassign $section heading items
            if {$heading ne ""} {
                lappend out "== $heading"
            }
            foreach item $items {
                lassign $item kind value
                if {$kind eq "text"} {
                    lappend out $value
                } else {
                    lappend out {*}[ExampleText [lindex [dict get $note examples] $value]]
                }
            }
            lappend out ""
        }
    }
    while {[llength $out] && [lindex $out end] eq ""} {
        set out [lrange $out 0 end-1]
    }
    return [join $out \n]
}

# The topic-file text of a parsed EXAMPLE.
proc cpt::ExampleText {example} {
    set out [list "@example [dict get $example kind]"]
    lappend out {*}[dict get $example lines]
    foreach directive {caption value error at message} {
        if {[dict get $example $directive] ne ""} {
            lappend out "@$directive [dict get $example $directive]"
        }
    }
    foreach directive {warn nowarn output} {
        foreach value [dict get $example $directive] {
            lappend out "@$directive $value"
        }
    }
    if {[dict get $example quiet]} {
        lappend out "@quiet"
    }
    if {[dict get $example backends] ne "interp compile"} {
        lappend out "@backends [dict get $example backends]"
    }
    lappend out "@end"
    return $out
}

# TEXT wrapped into lines for a section.
proc cpt::Prose {text} {
    return [split [compilerpedia::Wrap $text "" 74] \n]
}

# A native's signature, from its registration: NAME(P1, P2) -> R.
proc cpt::NativeSignature {name meta} {
    set params [dict get $meta paramTypes]
    set arity [dict get $meta arity]
    if {$arity eq "*"} {
        set shown "..."
    } elseif {$params eq "" && $arity > 0} {
        set shown [join [lrepeat $arity any] ", "]
    } else {
        set shown [join [lmap p $params {hir::types::show $p}] ", "]
    }
    return "${name}($shown) -> [hir::types::show [dict get $meta resultType]]"
}

# Where native NAME runs: a native whose implementation needs a raw machine
# address or makes a raw kernel transition (its registered runtime tags
# raw-address, raw-syscall) is native-only: the Tcl backends refuse the
# call (NATIVE-ONLY).
proc cpt::NativeBackends {meta} {
    if {[lsearch -exact [dict get $meta runtime] raw-address] >= 0 || [lsearch -exact [dict get $meta runtime] raw-syscall] >= 0} {
        return [list "native backends only (cranelift, cranelift-generic, executables); interp and compile" \
            "refuse the call at run time with NATIVE-ONLY"]
    }
    return [list "every backend (interp, compile, cranelift-generic, cranelift)"]
}

# TITLE, or SHORT when TITLE does not fit a title's line (78 characters,
# compilerpedia::validate): a long qualified name (std::mutable_byte_store::
# freeze_prefix) leaves no room to repeat its namespace.
proc cpt::Title {title short} {
    if {[string length $title] <= 78} {
        return $title
    }
    return $short
}

# The generated catalogue text: one topic per module (stdlib.module.NS, and
# stdlib.module.root for the root primitives), one per public native and per
# library declaration (stdlib.NS::NAME, stdlib.NAME at the root).
proc cpt::Generate {} {
    set notes [Notes]
    set used [dict create]
    set topics {}
    # The natives, by namespace.
    set byNamespace [dict create]
    foreach name [lsort [core::native::names]] {
        if {![PublicNative $name]} {
            continue
        }
        set ns [core::native::namespaceOf $name]
        dict lappend byNamespace [expr {$ns eq "" ? "root" : $ns}] $name
    }
    # The library modules.
    set modules [dict create]
    foreach module [LibraryModules] {
        lassign $module ns path archNote
        dict set modules $ns [list $path $archNote]
    }
    set namespaces [lsort -unique [concat [dict keys $byNamespace] [dict keys $modules]]]
    foreach ns $namespaces {
        set members {}
        set moduleSections {}
        set summary ""
        set description {}
        set relativePath ""
        set direct 0
        if {[dict exists $modules $ns]} {
            lassign [dict get $modules $ns] path archNote
            set relativePath stdlib/[string range $path [string length [file join $::cpt::root stdlib]]+1 end]
            set text [ReadFile $path]
            set lines [split $text \n]
            lassign [HeaderComment $text] summary description
            set ast [surface::parse $text $relativePath]
            set direct [expr {[dict get $ast direct] ne ""}]
            foreach node [dict get $ast body] {
                if {![dict exists $node name]} {
                    continue
                }
                if {[dict getdef $node private 0]} {
                    # A private declaration is the module's implementation,
                    # never API another module may use: not documented as
                    # one (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md).
                    continue
                }
                set name [dict get $node name]
                if {[hir::iteration::IsOperation $ns $name]} {
                    # A collection's loop protocol (hir/iteration.tcl): its
                    # operations are internal to the standard library, and
                    # a program iterates the collection with a loop.
                    continue
                }
                if {[core::native::isInternalMember "${ns}::$name"]} {
                    # A collection's representation access for another
                    # standard library module (core::native::
                    # declareInternalMember): internal, no API.
                    continue
                }
                set qualified "${ns}::$name"
                set id stdlib.$qualified
                set kind [DeclarationKind $node]
                set comment [CommentAbove $lines [dict get $node span line] $name]
                set declaration [DeclarationText $node $lines]
                lappend members [list $qualified $kind [expr {$comment ne "" ? [FirstSentence $comment] : ""}]]
                set sections [list [list DECLARATION [lmap l $declaration {string cat "    " $l}]]]
                lappend sections [list MODULE [Prose "$relativePath: import $ns, then write $qualified[expr {$kind eq "function" ? " or, as a method, receiver.${name}(...)" : ""}]."]]
                if {$comment ne ""} {
                    lappend sections [list DESCRIPTION [Reflow $comment]]
                }
                set note [expr {[dict exists $notes $id] ? [dict get $notes $id] : ""}]
                dict set used $id 1
                lappend topics [TopicText $id [dict create \
                    title [Title "$qualified -- [string totitle $kind 0 0] of module $ns" "$qualified -- [string totitle $kind 0 0]"] \
                    summary [expr {$comment ne "" ? [FirstSentence $comment] : "The $kind $qualified of the standard module $ns."}] \
                    index stdlib symbol [list $qualified] related [list stdlib.module.$ns]] $sections $note]
            }
        }
        foreach name [expr {[dict exists $byNamespace $ns] ? [dict get $byNamespace $ns] : {}}] {
            set meta [core::native::metadata $name]
            set id stdlib.$name
            set sections [list [list SIGNATURE [list "    [NativeSignature $name $meta]"]]]
            if {[dict get $meta errors] ne ""} {
                lappend sections [list ERRORS [list "    [join [dict get $meta errors] {, }]" "" {*}[Prose "A call must handle each (on NAME:), admit it in its function's errors clause, or be proven unable to raise it (rule.unhandled-errors)."]]]
            }
            set use [expr {$ns eq "root" ? "A language primitive: visible everywhere, no import." \
                : "An intrinsic of namespace $ns: import $ns, then write $name."}]
            if {[dict get $meta nomethod]} {
                append use " Declared nomethod: method syntax does not apply (NOMETHOD-CALL); call it as ${name}(...)."
            } elseif {[string is digit -strict [dict get $meta arity]] && [dict get $meta arity] >= 1 && $ns ne "root"} {
                append use " Method syntax: receiver.[namespace tail $name]\(...) is the same call."
            }
            lappend sections [list USE [Prose $use]]
            lappend sections [list BACKENDS [Prose [join [NativeBackends $meta] " "]]]
            set note [expr {[dict exists $notes $id] ? [dict get $notes $id] : ""}]
            dict set used $id 1
            set derived [expr {$note ne "" && [dict get $note summary] ni {"" -} ? "" : "The intrinsic $name."}]
            lappend members [list $name intrinsic [expr {$note ne "" ? [dict get $note summary] : ""}]]
            # A root primitive named like a namespace (`list`, what a list
            # literal calls) leaves the name to the namespace's page.
            set symbols [expr {$ns eq "root" && $name in $namespaces ? {} : [list $name]}]
            if {$ns eq "root"} {
                set title "$name -- language primitive"
            } else {
                set title [Title "$name -- intrinsic of namespace $ns" "$name -- intrinsic"]
            }
            lappend topics [TopicText $id [dict create \
                title $title \
                summary $derived index stdlib symbol $symbols related [list stdlib.module.$ns]] $sections $note]
        }
        # The module's own page.
        set id stdlib.module.$ns
        set sections {}
        if {$description ne ""} {
            lappend sections [list DESCRIPTION [Reflow $description]]
        }
        set where [expr {$ns eq "root" ? "The root namespace: language primitives, visible in every file without an import." \
            : [expr {$relativePath ne "" ? "$relativePath (import $ns)." : "Compiler intrinsics only, no module file (import $ns)."}]}]
        if {$direct} {
            append where " A direct module (DIRECT-MODULES.md): it exercises raw authority."
        }
        if {[dict exists $modules $ns] && [lindex [dict get $modules $ns] 1] ne ""} {
            append where " [string totitle [lindex [dict get $modules $ns] 1] 0 0]."
        }
        lappend sections [list SOURCE [Prose $where]]
        set memberLines {}
        foreach member [lsort -index 0 $members] {
            lassign $member name kind first
            set line "    [format %-30s $name] $kind[expr {$first ne "" ? " -- $first" : ""}]"
            if {[string length $line] > 78} {
                set line "[string range $line 0 74]..."
            }
            lappend memberLines $line
        }
        if {$memberLines ne ""} {
            lappend sections [list MEMBERS [concat $memberLines [list ""] [Prose "Each member is a topic: -help NAME (e.g. -help [lindex [lsort -index 0 $members] 0 0])."]]]
        }
        set note [expr {[dict exists $notes $id] ? [dict get $notes $id] : ""}]
        dict set used $id 1
        # The header's first sentence, without the "the NS namespace:" that
        # every module header starts with.
        regsub {^the "[^"]+" namespace:\s*} $summary "" summary
        regsub {^the "([^"]+)" namespace's} $summary {the \1 namespace's} summary
        set summary [FirstSentence [list $summary]]
        set summary [string toupper [string index $summary 0]][string range $summary 1 end]
        set summary [expr {$summary ne "" ? $summary : ($ns eq "root" ? "The language primitives: operators, kind tests, hash and argv." : "The intrinsics of namespace $ns.")}]
        lappend topics [TopicText $id [dict create \
            title "$ns -- [expr {$ns eq "root" ? "the language primitives" : "standard namespace"}]" \
            summary [string trimright $summary .]. index stdlib symbol [expr {$ns eq "root" ? {} : [list $ns]}]] $sections $note]
    }
    # A note for a symbol that no longer exists is stale.
    set stale [lmap id [dict keys $notes] {expr {[dict exists $used $id] ? [continue] : $id}}]
    set header [list "# compilerpedia/generated/stdlib.topic -- GENERATED by tools/compilerpedia.tcl generate" \
        "# from core::native's registry, stdlib/*.bot and compilerpedia/notes/stdlib.notes:" \
        "# do not edit; edit those and regenerate (COMPILERPEDIA.md)." ""]
    return [list "[join $header \n][join $topics \n\n]\n" $stale]
}

# ---------------------------------------------------------------------------
# The diagnostic inventory: what the compiler's source can report

# The inventory, a list of {CODE MATCH ORIGIN}: CODE a code as main.tcl
# prints it (or a kind, MATCH kind: a topic code ending in it documents it;
# MATCH exact: a topic code equal to it; MATCH prefix: a topic code equal to
# its leading words), ORIGIN where it was found. Read from the source by
# the patterns each reporting mechanism uses, never from a list kept by hand:
#   * diagnostic kinds: the token scan of tests/static-compile.test's census
#     (hir/*.tcl, surface/modules.tcl and surface/dfa.tcl), less the warning codes, the
#     tokens that name a design document, and the regular-expression
#     fragments; and every hir::static::codes kind
#   * the module loader's kinds: `Error KIND` in surface/modules.tcl
#   * the parser's coded syntax errors: `FailCode SPAN KIND`
#   * run-time kinds: core::semanticError KIND in core/, compiler/, native/
#   * every other literal error code a `throw` raises there
#   * the registered warnings (hir::warnings::passes)
proc cpt::Inventory {} {
    variable root
    set inventory {}
    set warnings [dict keys $::hir::warnings::passes]
    set seen [dict create]
    foreach path [concat [glob [file join $root hir *.tcl]] [list [file join $root surface modules.tcl] \
            [file join $root surface dfa.tcl]]] {
        foreach line [split [ReadFile $path] \n] {
            if {[regexp {^\s*#} $line]} continue
            foreach token [regexp -all -inline {\m[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+\M} $line] {
                dict set seen $token [file tail $path]
            }
        }
    }
    foreach kind {TYPE UNBOUND DUPLICATE ARITY IMPRINT DIRECT} {
        dict set seen $kind hir
    }
    foreach kind [dict keys [hir::static::codes]] {
        dict set seen $kind hir/static.tcl
    }
    foreach token [lsort [dict keys $seen]] {
        if {$token in $warnings || [file exists [file join $root docs $token.md]] || [string match A-Z* $token]} {
            continue
        }
        lappend inventory [list $token kind [dict get $seen $token]]
    }
    set loader [ReadFile [file join $root surface modules.tcl]]
    foreach kind [lsort -unique [regexp -all -inline {\mError [A-Z][A-Z0-9-]+} $loader]] {
        lappend inventory [list "SURFACE MODULE [lindex $kind 1]" exact surface/modules.tcl]
    }
    # The parser's coded errors: the first code-shaped word after FailCode.
    foreach line [split [ReadFile [file join $root surface parser.tcl]] \n] {
        if {[regexp {^\s*#} $line] || [regexp {^proc } $line]} continue
        set at [string first "FailCode " $line]
        if {$at >= 0 && [regexp {\m([A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+)\M} [string range $line $at end] -> kind]} {
            lappend inventory [list $kind exact surface/parser.tcl]
        }
    }
    lappend inventory [list "SURFACE SYNTAX" exact surface/parser.tcl]
    set runtimeFiles [concat [glob [file join $root core *.tcl]] [glob [file join $root compiler *.tcl]] \
        [glob [file join $root native *.tcl]] [glob [file join $root hir *.tcl]] [glob [file join $root surface *.tcl]]]
    set kinds [dict create]
    set codes [dict create]
    foreach path [lsort $runtimeFiles] {
        set text [ReadFile $path]
        foreach {- kind} [regexp -all -inline {semanticError ([A-Z][A-Z0-9-]+)} $text] {
            dict set kinds $kind [file tail $path]
        }
        foreach {- code} [regexp -all -inline {throw \{([A-Z][A-Z0-9 -]*[A-Z0-9])\}} $text] {
            dict set codes $code [file tail $path]
        }
        foreach {- code} [regexp -all -inline {throw \[list ((?:[A-Z][A-Z0-9-]* ?)+)} $text] {
            dict set codes [string trim $code] [file tail $path]
        }
    }
    dict for {kind file} $kinds {
        lappend inventory [list "CORE SEMANTIC $kind" exact $file]
    }
    dict for {code file} $codes {
        # The compiler's own families: CORE SEMANTIC KIND is covered above,
        # SURFACE MODULE and SURFACE SYNTAX by the loader's and parser's own
        # entries, Compilerpedia's format errors by its tests.
        if {$code in {{CORE SEMANTIC} {SURFACE MODULE} {SURFACE SYNTAX}} || [string match COMPILERPEDIA* $code]} {
            continue
        }
        lappend inventory [list $code prefix $file]
    }
    # The native runtime's and driver's codes (Rust): the error-code vectors
    # it reports, ["NATIVE", "KIND", ...], up to the first non-literal word.
    foreach path [lsort [glob -nocomplain [file join $root native src *.rs] [file join $root native src * *.rs] [file join $root native src * * *.rs]]] {
        foreach line [split [ReadFile $path] \n] {
            if {[regexp {^\s*//} $line]} continue
            foreach {- words} [regexp -all -inline {\["NATIVE"((?:, "[A-Z][A-Z0-9-]*")*)} $line] {
                set code [concat NATIVE [regexp -all -inline {[A-Z][A-Z0-9-]*} $words]]
                if {[llength $code] > 1} {
                    lappend inventory [list $code prefix native/src/[file tail $path]]
                }
            }
            foreach {- code} [regexp -all -inline {\((NATIVE [A-Z][A-Z0-9-]*(?: [A-Z][A-Z0-9-]*)?)\)} $line] {
                lappend inventory [list $code prefix native/src/[file tail $path]]
            }
        }
    }
    foreach code $warnings {
        lappend inventory [list $code warning hir/warnings.tcl]
    }
    return [lsort -unique -index 0 $inventory]
}

# The topics documenting inventory ENTRY ({CODE MATCH ORIGIN}).
proc cpt::Documenting {entry topicCodes} {
    lassign $entry code match
    set ids {}
    dict for {topicCode topicIds} $topicCodes {
        switch -- $match {
            kind    { set ok [expr {[lindex $topicCode end] eq $code}] }
            exact - warning { set ok [expr {$topicCode eq $code}] }
            prefix  { set ok [expr {$topicCode eq $code || [string first "$topicCode " "$code "] == 0}] }
        }
        if {$ok} {
            lappend ids {*}$topicIds
        }
    }
    return [lsort -unique $ids]
}

# ---------------------------------------------------------------------------
# Examples

# The value main.tcl prints for VALUE, the result of HIR: main.tcl's
# ShowResult, which shows a DecimalRounded value at the precision HIR's
# result type guarantees (hir::decimal::Display).
proc cpt::Shown {value hir} {
    if {[hir::roots $hir] eq ""} {
        return [core::value::show $value 1]
    }
    return [hir::decimal::Display $value [hir::typeOf $hir [lindex [hir::roots $hir] end]]]
}

# Runs EXAMPLE (of topic TOPIC) on BACKENDS (those of its own it may use);
# returns a list of problems.
proc cpt::CheckExample {topic example backends scratch} {
    set problems {}
    set id [dict get $example id]
    set dir [file join $scratch [string map {. _ # _ : _ ? _} $id]]
    file mkdir $dir
    set path [file join $dir example.bot]
    WriteFile $path "[join [dict get $example lines] \n]\n"
    # Its modules (@module NAME): application modules beside it.
    dict for {name text} [dict getdef $example modules {}] {
        WriteFile [file join $dir $name.bot] "[join $text \n]\n"
    }
    # An example importing a namespace of another operating system's
    # platform (std::linux::io on a Mac) documents that system: it compiles for
    # its target, as the golden runner's suites do, and runs where a program
    # of that target runs here, on the Tcl backends.
    # One that names its target (@target: a fact of that target, such as a
    # C scalar's width) compiles for it and runs, on another host, the same
    # way.
    set target [dict get $example target]
    if {$target eq ""} {
        set target [surface::modules::PlatformTarget [core::ReadFile $path]]
    }
    if {$target ne "" && $target ne [core::cabi::hostTarget]} {
        set backends [lmap b $backends {expr {$b in {interp compile} ? $b : [continue]}}]
    }
    set failed [catch {surface::readProgramFile $path -warnings default -warning-channel "" -target $target} hir options]
    if {[dict get $example kind] eq "reject"} {
        if {!$failed} {
            return [list "$id: compiled, but the example states it is rejected with [dict get $example error]"]
        }
        if {[lindex [dict get $options -errorcode] 0] ni {CORE SURFACE NATIVE HIR}} {
            return [list "$id: failed with an internal error, not a diagnostic: $hir"]
        }
        if {[dict exists $options -diagnostics]} {
            set first [lindex [dict get $options -diagnostics] 0]
            set code [core::ShownCode $first]
            set message [dict get $first message]
        } else {
            set code [dict get $options -errorcode]
            set message [lindex [split $hir \n] 0]
        }
        set expected [dict get $example error]
        if {$code ne $expected && [lrange $code 0 [expr {[llength $expected] - 1}]] ne $expected} {
            lappend problems "$id: rejected with ($code) $message -- the example states [dict get $example error]"
        }
        set at [dict get $example at]
        # (An @at of a module's diagnostic names its file: NAME.bot:L:C.)
        set file [expr {[string match *.bot:* $at] ? "" : "example.bot:"}]
        if {$at ne "" && ![string match "*/$file$at: *" $message]} {
            lappend problems "$id: the primary diagnostic is not at $at: $message"
        }
        regsub {^\S+:\d+:\d+: } $message {} text
        if {[dict get $example message] ne "" && ![string match [dict get $example message] $text]} {
            lappend problems "$id: the primary diagnostic's message does not match \"[dict get $example message]\": $text"
        }
        # A rejected example of a topic that documents the code, or whose
        # matcher should match it, is the diagnostic the topic is about: the
        # help line printed for it must name the topic.
        set topicId [dict get $topic id]
        set expectsHelp [expr {[lsearch -exact [dict get $topic code] $code] >= 0}]
        foreach match [dict get $topic match] {
            if {[string trim [lindex [split $match |] 0]] eq $code} {
                set expectsHelp 1
            }
        }
        if {$expectsHelp} {
            set pointed [compilerpedia::topicForDiagnostic $code $message]
            if {$pointed ne $topicId} {
                lappend problems "$id: the help line for its diagnostic names \"$pointed\", not $topicId (a matcher missing, or another one matching first)"
            }
        }
        return $problems
    }
    if {$failed} {
        return [list "$id: rejected, but the example states it compiles: $hir ([dict get $options -errorcode])"]
    }
    set codes [lmap w [hir::warnings::of $hir] {dict get $w code}]
    foreach code [dict get $example warn] {
        if {$code ni $codes} {
            lappend problems "$id: no $code warning (warnings: [expr {$codes eq "" ? "none" : [join $codes {, }]}])"
        }
    }
    foreach code [dict get $example nowarn] {
        if {$code in $codes} {
            lappend problems "$id: warns $code, which the example states it does not"
        }
    }
    # A page shows idiomatic code: an example draws exactly the warnings it
    # states (@warn), so a reader copying one is never surprised by another.
    set unstated [lsort -unique [lmap code $codes {expr {$code in [dict get $example warn] ? [continue] : $code}}]]
    if {$unstated ne ""} {
        lappend problems "$id: warns [join $unstated {, }], which the example does not state (@warn)"
    } elseif {[dict get $example quiet] && $codes ne ""} {
        lappend problems "$id: warns [join $codes {, }]; the example states no warnings"
    }
    set wanted [dict get $example backends]
    if {$wanted eq "all"} {
        set wanted $::cpt::allBackends
    }
    foreach backend $wanted {
        if {$backend ni $backends} {
            continue
        }
        if {[dict get $example output] ne ""} {
            # Printed output: through main.tcl, as a user runs it.
            set targetArgs [expr {$target eq "" ? {} : [list -target $target]}]
            set status [catch {exec [info nameofexecutable] [file join $::cpt::root main.tcl] -backend $backend -warnings off {*}$targetArgs $path 2>@1} out]
            set lines [lrange [split $out \n] 1 end]
            set printed [lrange $lines 0 [expr {[llength [dict get $example output]] - 1}]]
            if {$printed ne [dict get $example output]} {
                lappend problems "$id on $backend: printed [list $printed], the example states [list [dict get $example output]]"
            }
            if {[dict get $example value] ne "" && "   value: [dict get $example value]" ni $lines} {
                lappend problems "$id on $backend: no \"value: [dict get $example value]\" line in: $out"
            }
            continue
        }
        if {[catch {
            core::process::withArgv [core::process::defaultArgv] [list cpt::Run $hir $backend]
        } value options]} {
            lappend problems "$id on $backend: failed at run time: $value ([dict get $options -errorcode])"
            continue
        }
        if {[dict get $example value] ne "" && [Shown $value $hir] ne [dict get $example value]} {
            lappend problems "$id on $backend: value [Shown $value $hir], the example states [dict get $example value]"
        }
    }
    return $problems
}

proc cpt::Run {hir backend} {
    switch -- $backend {
        interp { return [core::evalProgram [hir::lower $hir]] }
        compile { return [core::compiler::evalHir $hir] }
        cranelift { return [native::evalHir $hir] }
        cranelift-generic { return [native::evalHir $hir -specialize 0] }
    }
}

# The backends examples may run on here: the Tcl backends, and the native
# ones when the native backend is built on a host that runs them.
proc cpt::AvailableBackends {} {
    set backends {interp compile}
    # The native examples print through std::linux::io, make Linux syscalls or
    # call C: the native runtime does that on Linux x86-64 and AArch64 (the
    # tests' nativeLinux), not yet on another host.
    if {![catch {native::binary}] && $::tcl_platform(os) eq "Linux"
            && $::tcl_platform(machine) in {x86_64 amd64 aarch64 arm64}} {
        lappend backends cranelift-generic cranelift
    }
    return $backends
}

# Every problem of the examples (of the topics whose ID matches MATCH), and
# the number of examples run.
proc cpt::Examples {match backends} {
    set scratch [file tempdir compilerpedia-examples]
    set problems {}
    set count 0
    try {
        foreach id [compilerpedia::topics] {
            if {![string match $match $id]} continue
            set topic [compilerpedia::topic $id]
            foreach example [dict get $topic examples] {
                incr count
                lappend problems {*}[CheckExample $topic $example $backends $scratch]
            }
        }
    } finally {
        file delete -force $scratch
    }
    return [list $problems $count]
}

# ---------------------------------------------------------------------------
# Checks

# The warnings index's required sections (WHAT IT DETECTS ... in the order
# COMPILERPEDIA.md lists them), by heading.
namespace eval cpt {
    variable warningSections {
        {WHAT IT DETECTS} {WHY IT MATTERS} {RECOMMENDED PRACTICE} {EVIDENCE}
        {LEGITIMATE EXCEPTIONS}
    }
}

proc cpt::Check {options} {
    variable generated
    variable warningSections
    set problems [compilerpedia::validate]
    # The generated file is what generate writes.
    lassign [Generate] text stale
    foreach id $stale {
        lappend problems "notes/stdlib.notes: $id documents no current standard-library entry"
    }
    if {![file exists $generated] || [ReadFile $generated] ne $text} {
        lappend problems "compilerpedia/generated/stdlib.topic is not what tools/compilerpedia.tcl generate writes: regenerate it"
    }
    # Every intrinsic has a note: a summary of what it does.
    foreach name [core::native::names] {
        if {[PublicNative $name] && ![dict exists [Notes] stdlib.$name]} {
            lappend problems "notes/stdlib.notes: the intrinsic $name has no note (its summary)"
        }
    }
    # Coverage of the inventory.
    set topicCodes [dict create]
    foreach id [compilerpedia::topics] {
        foreach code [dict get [compilerpedia::topic $id] code] {
            dict lappend topicCodes $code $id
        }
    }
    foreach entry [Inventory] {
        if {[Documenting $entry $topicCodes] eq ""} {
            lappend problems "undocumented [lindex $entry 1] [lindex $entry 0] (found in [lindex $entry 2])"
        }
    }
    # Every warning topic explains itself and shows the rule both ways.
    foreach code [dict keys $::hir::warnings::passes] {
        set ids [expr {[dict exists $topicCodes $code] ? [dict get $topicCodes $code] : {}}]
        foreach id $ids {
            set topic [compilerpedia::topic $id]
            if {"warnings" ni [dict get $topic index]} {
                lappend problems "$id: the topic of warning $code is not in the warnings index"
            }
            set headings [lmap section [dict get $topic body] {string toupper [lindex $section 0]}]
            foreach heading $warningSections {
                if {$heading ni $headings} {
                    lappend problems "$id: warning $code has no \"== $heading\" section"
                }
            }
            set warns 0
            set silent 0
            foreach example [dict get $topic examples] {
                if {$code in [dict get $example warn]} { incr warns }
                if {$code in [dict get $example nowarn]} { incr silent }
            }
            if {!$warns || !$silent} {
                lappend problems "$id: warning $code needs an example that warns (@warn $code) and one that does not (@nowarn $code)"
            }
            if {"CORE SEMANTIC $code" ni [dict get $topic code]} {
                lappend problems "$id: warning $code also documents CORE SEMANTIC $code (its code under -warnings error)"
            }
        }
    }
    # Every matcher is exercised: a rejected example of its topic that its
    # pattern is about (CheckExample verifies the help line names the topic).
    foreach id [compilerpedia::topics] {
        set topic [compilerpedia::topic $id]
        if {[dict get $topic match] eq ""} continue
        set rejected [llength [lmap e [dict get $topic examples] {expr {[dict get $e kind] eq "reject" ? 1 : [continue]}}]]
        if {!$rejected} {
            lappend problems "$id: has diagnostic matchers but no rejected example exercising them"
        }
    }
    set count 0
    if {[dict get $options -examples]} {
        lassign [Examples * [dict get $options -backends]] exampleProblems count
        lappend problems {*}$exampleProblems
    }
    return [list $problems $count]
}

proc cpt::Report {problems count format what} {
    if {$format eq "data"} {
        puts [list problems $problems examples $count topics [llength [compilerpedia::topics]]]
    } else {
        foreach problem $problems {
            puts $problem
        }
        puts "$what: [llength [compilerpedia::topics]] topics, $count examples run, [llength $problems] problems"
    }
    exit [expr {$problems ne ""}]
}

set command [lindex $argv 0]
set arguments [lrange $argv 1 end]
switch -- $command {
    generate {
        lassign [cpt::Generate] text stale
        cpt::WriteFile $cpt::generated $text
        foreach id $stale {
            puts stderr "warning: notes/stdlib.notes: $id documents no current standard-library entry"
        }
        puts "wrote [file join compilerpedia generated stdlib.topic]"
    }
    check {
        set options [cpt::Options $arguments [dict create -examples 1 -backends [cpt::AvailableBackends] -format text]]
        lassign [cpt::Check $options] problems count
        cpt::Report $problems $count [dict get $options -format] check
    }
    examples {
        set options [cpt::Options $arguments [dict create -match * -backends [cpt::AvailableBackends] -format text]]
        lassign [cpt::Examples [dict get $options -match] [dict get $options -backends]] problems count
        cpt::Report $problems $count [dict get $options -format] examples
    }
    inventory {
        set options [cpt::Options $arguments [dict create -undocumented 0]]
        set topicCodes [dict create]
        foreach id [compilerpedia::topics] {
            foreach code [dict get [compilerpedia::topic $id] code] {
                dict lappend topicCodes $code $id
            }
        }
        foreach entry [cpt::Inventory] {
            set ids [cpt::Documenting $entry $topicCodes]
            if {[dict get $options -undocumented] && $ids ne ""} continue
            puts [format "%-46s %-8s %-28s %s" [lindex $entry 0] [lindex $entry 1] [lindex $entry 2] [expr {$ids eq "" ? "UNDOCUMENTED" : [join $ids {, }]}]]
        }
    }
    default {
        puts stderr "usage: tclsh9.0 tools/compilerpedia.tcl generate|check|examples|inventory ?options? (COMPILERPEDIA.md)"
        exit 2
    }
}
