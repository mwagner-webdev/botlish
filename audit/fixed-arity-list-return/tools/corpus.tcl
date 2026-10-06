# corpus.tcl -- observational audit of FIXED-ARITY-LIST-RETURN over the
# corpus (WARNINGS-FIXED-ARITY-LIST-RETURN.md, "Corpus findings"). Compiles
# every program of examples/stdlib, examples/surface (minus the deliberate
# rejections), bench/*.bot and lib/*.bot with warnings on (collected, not
# emitted) and reports, at the commit it runs on:
#
#   * every distinct finding with the source line of each exit, the element
#     types at each position (informational: the warning never reads them),
#     and its HAND classification (the table below; a finding missing from the
#     table is printed UNCLASSIFIED and makes the tool exit non-zero);
#   * the list-annotated functions of the corpus (which must all be silent);
#   * the near misses: silent functions with a literal exit of arity >= 2,
#     with the reason they are silent;
#   * for each finding classified "annotate", a scratch copy with `-> list`
#     added to its declaration: it must compile, lose the finding, and (for an
#     entry program) produce the same value; for each finding classified
#     "convert" that has a curated conversion below, the converted scratch
#     copy must compile, lose its findings, and produce the same value;
#   * the historical list-form CSV scanners (supplementary, not corpus).
#
# The corpus itself is never edited.
#
#   tclsh9.0 audit/fixed-arity-list-return/tools/corpus.tcl ?-root DIR?
#
# -root audits another checkout (e.g. a worktree of a later commit) with this
# checkout's tools.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set auditRoot $root
foreach {option value} $argv {
    switch -- $option {
        -root { set auditRoot [file normalize $value] }
        default { error "unknown option $option" }
    }
}
source [file join $auditRoot surface surface.tcl]

set programs [concat \
    [lsort [glob -directory [file join $auditRoot examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples surface] *.bot]] \
    [lsort [glob -directory [file join $auditRoot bench] *.bot]] \
    [lsort [glob -directory [file join $auditRoot lib] *.bot]]]

# HAND classification, per distinct (file, function, arity): {CATEGORY WHY}.
#   convert   a multi-value result whose parts deserve names: the refactor
#             would turn it into a struct value
#   annotate  a genuine fixed-shape list: the author would declare `-> list`
# A finding the author would do neither for is a false positive (item 16's
# bar); none may be listed here as such -- the shape rule changes instead.
set classified {
    {examples/stdlib/csv_chunked.bot chunked_new 3} {convert
        {the ChunkedBuilder state [completedChunks, currentChunk, filled]: the file's own header names the three parts, which callers read back with list::at(builder, 0/1/2)}}
    {examples/stdlib/csv_chunked.bot chunked_append 3} {convert
        {the same builder state, returned from both of its exits}}
    {examples/stdlib/ai_text_clean.bot sample 6} {annotate
        {the sample's list of check results: printed as the program's value and compared with the file's `# expect: [...]` list; never destructured or read positionally}}
    {examples/stdlib/csv_records.bot sample_checks 7} {annotate
        {the sample's observation vector (`# expect: [2, "Alice", ...]`), heterogeneous by element type but a list of check outcomes, never read by position}}
    {examples/stdlib/hashtable.bot sample_checks 6} {annotate
        {the sample's observation vector (`# expect: [true, true, ...]`), consumed whole}}
    {examples/stdlib/string_replace.bot sample 5} {annotate
        {the sample's list of results (`# expect: ["abc", ...]`)}}
    {examples/stdlib/string_reverse.bot sample 5} {annotate
        {the sample's list of results (`# expect: ["", "a", ...]`)}}
    {examples/surface/13-hygiene.bot pair 2} {annotate
        {the example is about the list-literal syntax itself (a parameter named `list` does not change what `[a, b]` means): its result is deliberately a list}}
}

# Curated conversions for "convert" findings: FILE -> {OLD NEW ...} exact text
# replacements (each OLD must occur exactly once), the mechanical refactor a
# programmer acting on the finding would make.
set conversions {
    examples/stdlib/csv_chunked.bot {
        {    [[], mutable_array::allocate(chunk_size()), 0]}
        {    {completed: [], current: mutable_array::allocate(chunk_size()), filled: 0}}
        {        return [more, fresh, 1]}
        {        return {completed: more, current: fresh, filled: 1}}
        {    [completed, current, filled + 1]}
        {    {completed: completed, current: current, filled: filled + 1}}
        {fn chunked_append(builder, value) errors IndexNotFound:
    completed = list::at(builder, 0)
    current = list::at(builder, 1)
    filled = list::at(builder, 2)}
        {fn chunked_append(builder, value) errors IndexNotFound:
    completed = builder.completed
    current = builder.current
    filled = builder.filled}
        {fn chunked_finish(builder) errors IndexNotFound, LowerUnderrun, UpperOverrun:
    completed = list::at(builder, 0)
    current = list::at(builder, 1)
    filled = list::at(builder, 2)}
        {fn chunked_finish(builder) errors IndexNotFound, LowerUnderrun, UpperOverrun:
    completed = builder.completed
    current = builder.current
    filled = builder.filled}
    }
}

proc readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

proc writeText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
}

proc rel {path} {
    return [string map [list $::auditRoot/ {}] $path]
}

proc compilePath {path} {
    return [surface::readProgramFile $path -warnings default -warning-channel ""]
}

proc fixedOf {hir} {
    return [lmap w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "FIXED-ARITY-LIST-RETURN"} continue
        set w
    }]
}

proc pathOf {hir origin} {
    return [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
}

proc lineOf {hir origin} {
    set lines [split [readText [pathOf $hir $origin]] \n]
    return [string trim [lindex $lines [expr {[dict get [lrange $origin 2 end] line] - 1}]]]
}

proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v]} {
        return [list error $v]
    }
    return $v
}

# The written list literal an exit SITE of HIR produces (through an alias to
# its initializer), or "" for a self-call.
proc literalOf {hir site} {
    set node [dict get $hir exprs $site]
    set v [expr {[dict get $node kind] eq "return" ? [dict get $node value] : $site}]
    if {[dict get $hir exprs $v kind] eq "ref"} {
        set root [hir::exact::AliasRoot $hir $v]
        set v [dict get $hir exprs [dict get $hir bindings $root declaredBy] value]
    }
    set node [dict get $hir exprs $v]
    if {[dict get $node kind] eq "call" && [dict exists $node written] && [dict get $node written form] eq "list"} {
        return $v
    }
    return ""
}

# The static element types at each position across the literal exits of
# warning W: "same-element" when every position has one shared type,
# "heterogeneous" when positions differ, with the types.
proc elementTypes {hir w} {
    set positions {}
    foreach site [dict get $w data sites] {
        set literal [literalOf $hir $site]
        if {$literal eq ""} continue
        set i 0
        foreach arg [dict get $hir exprs $literal args] {
            dict lappend positions $i [hir::types::show [hir::typeOf $hir $arg]]
            incr i
        }
    }
    set shown [lmap {i types} $positions {join [lsort -unique $types] |}]
    set kind [expr {[llength [lsort -unique $shown]] == 1 ? "same-element" : "heterogeneous"}]
    return "$kind \[[join $shown {, }]\]"
}

# ---------------------------------------------------------------------------
# The audit

set commit [string trim [exec git -C $auditRoot rev-parse HEAD]]
set dirty [string trim [exec git -C $auditRoot status --porcelain -- examples bench lib]]
puts "# FIXED-ARITY-LIST-RETURN corpus audit: tclsh9.0 audit/fixed-arity-list-return/tools/corpus.tcl"
puts "# commit $commit (corpus paths [expr {$dirty eq "" ? "clean" : "MODIFIED: $dirty"}])"
puts ""

set findings [dict create]     ;# primary location -> record
set failed {}
set compiled 0
set annotated [dict create]    ;# location -> name
set nearMisses [dict create]   ;# location -> {name reason}
set entryOf [dict create]      ;# file -> an entry program that compiles it
foreach path $programs {
    if {[catch {compilePath $path} hir options]} {
        lappend failed [list [rel $path] [dict get $options -errorcode]]
        continue
    }
    incr compiled
    foreach w [fixedOf $hir] {
        set where [rel [hir::originLocation $hir [dict get $w primary]]]
        if {[dict exists $findings $where]} continue
        set file [rel [pathOf $hir [dict get $w primary]]]
        if {![dict exists $entryOf $file]} {
            dict set entryOf $file $path
        }
        dict set findings $where [dict create file $file name [dict get $w data functionName] \
            arity [dict get $w data arity] exits [dict get $w data exits] \
            selfCalls [llength [dict get $w data selfCalls]] types [elementTypes $hir $w] \
            lines [lmap o [list [dict get $w primary] {*}[dict get $w secondary]] {
                list [rel [hir::originLocation $hir $o]] [lineOf $hir $o]
            }] entry [rel $path]]
    }
    # Annotated list functions and near misses, from the pass's own pieces.
    set warned [lmap w [fixedOf $hir] {dict get $w data function}]
    set selves [dict create]
    set names [hir::warnings::BlockNames $hir]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "bind" && [dict get $hir exprs [dict get $node value] kind] eq "block"} {
            dict set selves [dict get $node value] [dict get $node binding]
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || [lindex [dict get $node origin] 0] ne "file"} continue
        set where [rel [hir::originLocation $hir [dict get $node origin]]]
        set name [expr {[dict exists $names $e] ? [dict get $names $e] : "?"}]
        if {[hir::warnings::DeclaresListResult $hir $e]} {
            dict set annotated $where [list $name [expr {$e in $warned}]]
            continue
        }
        if {$e in $warned || [dict exists $nearMisses $where]} continue
        set self [expr {[dict exists $selves $e] ? [dict get $selves $e] : ""}]
        set shapes [lmap exit [hir::warnings::ShapeExits $hir $e] {
            hir::warnings::ExitShape $hir [lindex $exit 1] $self
        }]
        set lits [lmap s $shapes {if {[lindex $s 0] ni {list alias}} continue; lindex $s 1}]
        if {$lits eq "" || [lindex [lsort -integer $lits] end] < 2} continue
        set reasons {}
        foreach s $shapes {
            switch -- [lindex $s 0] {
                unit { lappend reasons "a unit exit" }
                other { lappend reasons "a non-literal exit" }
            }
        }
        if {[llength [lsort -unique $lits]] > 1} {
            lappend reasons "arities [join [lsort -unique -integer $lits] /]"
        }
        if {[lsearch -exact $lits 1] >= 0 || [lsearch -exact $lits 0] >= 0} {
            lappend reasons "a 0- or 1-element exit"
        }
        if {$reasons eq ""} {
            lappend reasons "every literal exit range-unreachable"
        }
        dict set nearMisses $where [list $name [join [lsort -unique $reasons] ", "]]
    }
}

# Findings, with their classification.
set n 0
set unclassified 0
set categories [dict create]
foreach where [lsort -dictionary [dict keys $findings]] {
    set f [dict get $findings $where]
    incr n
    set key [list [dict get $f file] [dict get $f name] [dict get $f arity]]
    set category UNCLASSIFIED
    set why ""
    if {[dict exists $classified $key]} {
        lassign [dict get $classified $key] category why
    } else {
        incr unclassified
    }
    dict lappend categories $category $where
    puts "$n. $where: `[dict get $f name]`: a [dict get $f arity]-element list from [dict get $f exits] exit(s)\
        ([dict get $f selfCalls] self-call(s); first seen compiling [dict get $f entry])"
    foreach line [dict get $f lines] {
        puts "     [lindex $line 0]: [lindex $line 1]"
    }
    puts "     element types (informational): [dict get $f types]"
    puts "     HAND: $category -- $why"
}
puts ""
puts "programs compiled: $compiled of [llength $programs]"
foreach f $failed {
    puts "did not compile standalone: [lindex $f 0] ([lindex $f 1])"
}
puts "distinct FIXED-ARITY-LIST-RETURN findings: $n"
foreach category {convert annotate UNCLASSIFIED} {
    set list [expr {[dict exists $categories $category] ? [dict get $categories $category] : {}}]
    puts "  $category: [llength $list]"
}
set single 0
foreach where [dict keys $findings] {
    if {[dict get $findings $where exits] == 1} { incr single }
}
puts "  of which single-exit: $single"
puts "  false positives (author would neither convert nor annotate): 0 by the hand review above"

puts ""
puts "list-annotated functions in the corpus (must be silent): [dict size $annotated]"
set loud 0
foreach where [lsort -dictionary [dict keys $annotated]] {
    lassign [dict get $annotated $where] name warned
    puts "  $where `$name`[expr {$warned ? " -- WARNED (a bug)" : ""}]"
    incr loud $warned
}

puts ""
puts "near misses (silent, with a literal exit of arity >= 2): [dict size $nearMisses]"
foreach where [lsort -dictionary [dict keys $nearMisses]] {
    lassign [dict get $nearMisses $where] name reason
    puts "  $where `$name`: $reason"
}

# ---------------------------------------------------------------------------
# Scratch verification of the classifications

set scratch [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] fixed-arity-audit-[pid]]
file mkdir $scratch
set verifyFailures 0
puts ""
puts "annotation check (`-> list` added in a scratch copy):"
foreach where [lsort -dictionary [dict keys $findings]] {
    set f [dict get $findings $where]
    set key [list [dict get $f file] [dict get $f name] [dict get $f arity]]
    if {![dict exists $classified $key] || [lindex [dict get $classified $key] 0] ne "annotate"} continue
    set path [file join $auditRoot [dict get $f file]]
    if {[string match lib/* [dict get $f file]]} {
        puts "  $where: a library module (not checked)"
        continue
    }
    set text [readText $path]
    set lines [split $text \n]
    set name [dict get $f name]
    set index [lsearch -regexp $lines "^\\s*fn [string map {? \\?} $name]\\("]
    set header [lindex $lines $index]
    if {[regexp {^(.*\))( errors .*:|:)$} $header -> head tail]} {
        lset lines $index "$head -> list$tail"
    }
    set copy [file join $scratch [file tail $path]]
    writeText $copy [join $lines \n]
    set before [valueOf [compilePath $path]]
    if {[catch {compilePath $copy} hir]} {
        puts "  $where: `[lindex $lines $index]` does NOT compile: $hir"
        incr verifyFailures
        continue
    }
    set left [lmap w [fixedOf $hir] {if {[dict get $w data functionName] ne $name} continue; set w}]
    set after [valueOf $hir]
    set ok [expr {$left eq "" && $before eq $after}]
    puts "  $where: `[string trim [lindex $lines $index]]` compiles, finding [expr {$left eq "" ? "gone" : "STILL THERE"}],\
        value [expr {$before eq $after ? "identical" : "DIFFERS"}]"
    if {!$ok} { incr verifyFailures }
}

puts ""
puts "conversion check (curated struct conversions in a scratch copy):"
dict for {file patches} $conversions {
    set path [file join $auditRoot $file]
    set text [readText $path]
    set applied 1
    foreach {old new} $patches {
        set at [string first $old $text]
        if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
            puts "  $file: a conversion patch does not apply exactly once (the file changed?)"
            set applied 0
            incr verifyFailures
            break
        }
        set text [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    }
    if {!$applied} continue
    set copy [file join $scratch [file tail $path]]
    writeText $copy $text
    set original [compilePath $path]
    set before [valueOf $original]
    if {[catch {compilePath $copy} hir]} {
        puts "  $file: the converted program does NOT compile: $hir"
        incr verifyFailures
        continue
    }
    set after [valueOf $hir]
    set left [llength [lmap w [fixedOf $hir] {if {[string match *[file tail $path]* [hir::originLocation $hir [dict get $w primary]]]} {set w} else continue}]]
    puts "  $file: converted program compiles; FIXED-ARITY-LIST-RETURN findings in it: [llength [fixedOf $original]] -> $left;\
        value [expr {$before eq $after ? "identical" : "DIFFERS"}] ($after)"
    if {$before ne $after || $left != 0} { incr verifyFailures }
}
file delete -force $scratch

# ---------------------------------------------------------------------------
# Supplementary: the historical list-form CSV scanners (not corpus). The
# scanners of audit/strict-reference-determinism/experiment/csv_records-A-
# callee-first.bot, written before STRUCTS.md converted them, extracted with
# the error declarations today's compiler requires added and stand-ins for the
# builder helpers they call.

set historical [file join $auditRoot audit strict-reference-determinism experiment csv_records-A-callee-first.bot]
if {[file exists $historical]} {
    set lines [split [readText $historical] \n]
    set from [lsearch -regexp $lines {^fn peek\(}]
    set to [lsearch -regexp $lines {^fn scan_records\(}]
    set scanners [lmap line [lrange $lines $from [expr {$to - 1}]] {
        regsub {^(fn [a-z_]+\([^)]*\)):$} $line {\1 errors LowerUnderrun, UpperOverrun, IndexNotFound:}
    }]
    set source [join [concat {
        "import list"
        "import str"
        "fn geo_new(value):"
        "    {only: value}"
        "fn geo_append(fields, count, value):"
        "    fields"
        "fn geo_finish(fields, count):"
        "    fields"
    } $scanners] \n]
    puts ""
    puts "supplementary: the historical list-form scanners ([rel $historical], before the STRUCTS.md conversion):"
    if {[catch {surface::compile $source historical.bot -warnings default -warning-channel ""} hir]} {
        puts "  does not compile: $hir"
    } else {
        set silentNames {}
        foreach w [fixedOf $hir] {
            puts "  `[dict get $w data functionName]`: a [dict get $w data arity]-element list from [dict get $w data exits] exits ([llength [dict get $w data selfCalls]] self-calls), anchored at [hir::originLocation $hir [dict get $w primary]]"
        }
        set warnedNames [lmap w [fixedOf $hir] {dict get $w data functionName}]
        foreach name {peek scan_unquoted scan_quoted scan_field scan_record_rest scan_record} {
            if {$name ni $warnedNames} { lappend silentNames $name }
        }
        puts "  silent: [join $silentNames {, }] (scan_field and scan_record return the result of another list-returning function: a helper chain, which v1 does not follow)"
    }
}

exit [expr {$unclassified > 0 || $loud > 0 || $verifyFailures > 0}]
