# corpus.tcl -- observational audit of PROVES-NAMING over the corpus
# (WARNINGS-PROVES-NAMING.md, "Corpus findings"). Compiles every program of
# examples/stdlib, examples/surface, examples/refinement, bench/*.bot and
# lib/*.bot with warnings on (collected, not emitted) and reports, at the
# commit it runs on:
#
#   * every distinct finding (a library module's finding is reported once,
#     with the first program that loaded it), with its declaration line and
#     its HAND classification (the table below; a finding missing from the
#     table is printed UNCLASSIFIED and makes the tool exit non-zero);
#   * the census of every proves-fitted function the corpus compiles (module
#     functions included, once each): its written name, its ordinary
#     parameter count, its declared result, its shape (predicate, validator
#     or out of shape) and whether its name follows the shape's convention --
#     read from the HIR directly, independently of the pass, and checked
#     against the pass's findings;
#   * for each finding classified `rename` or `bare-validate`, the rename
#     check in a scratch copy: the curated rename below applied to a copy of
#     the library, and a probe program compiled against both copies must
#     compile, lose the finding and keep the probe's value. A `collision`
#     finding (the conventional name is already taken) is reported, not
#     checked.
#
# The corpus itself is never edited (the scratch copy lives in a temporary
# directory and is removed).
#
#   tclsh9.0 audit/proves-naming/tools/corpus.tcl ?-root DIR?
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
    [lsort [glob -directory [file join $auditRoot examples refinement] *.bot]] \
    [lsort [glob -directory [file join $auditRoot bench] *.bot]] \
    [lsort [glob -directory [file join $auditRoot lib] *.bot]]]

# The surface examples that are deliberate rejections (their own headers say
# so): expected not to compile.
set deliberate {examples/surface/09-mutual-recursion.bot examples/surface/10-duplicate-binding.bot}

# HAND classification, per distinct (file, function): {CATEGORY WHY}.
#   rename         a rename candidate: the conventional name is free and the
#                  author would take it
#   bare-validate  a module validator whose right response is the bare
#                  `validate` export (path::validate), not validate_NAME
#   collision      the conventional name is already taken by another
#                  definition: the author must resolve a real conflict
# A finding the author would neither rename nor justify is a false positive
# and a warning-design issue; none may be listed here as such -- the rule
# changes instead.
set classified {}

# Curated renames for `rename` and `bare-validate` findings: FILE -> {OLD
# NEW} (the function's written name and its conventional one; every whole-
# word occurrence in FILE is renamed), and a probe program calling it.
set renames {}
set probes {}

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

proc namingOf {hir} {
    return [lmap w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "PROVES-NAMING"} continue
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

# The census entry of the function declared by the bind node NODE, read from
# the HIR and the declaration's own source line, independently of the pass:
# {NAME ORDINARY RESULT SHAPE CONFORMS}.
proc censusEntry {hir node} {
    set fn [dict get $hir exprs [dict get $node value]]
    # The written name is the identifier after `fn` on the declaration line.
    regexp {^fn ([A-Za-z_][A-Za-z0-9_]*\??)\(} [lineOf $hir [dict get $node origin]] -> name
    set flags [expr {[dict exists $fn flags] ? [llength [dict get $fn flags]] : 0}]
    set ordinary [expr {[llength [dict get $fn params]] - $flags}]
    set result [hir::types::show [dict get $fn declaredResult]]
    set shape "out of shape"
    if {$ordinary == 1 && $result eq "bool"} {
        set shape predicate
    } elseif {$ordinary == 1 && $result eq "unit"} {
        set shape validator
    }
    switch -- $shape {
        predicate { set conforms [string match {*\?} $name] }
        validator { set conforms [expr {$name eq "validate" || [string match validate_* $name]}] }
        default { set conforms - }
    }
    return [list $name $ordinary $result $shape $conforms]
}

# ---------------------------------------------------------------------------
# The audit

set commit [string trim [exec git -C $auditRoot rev-parse HEAD]]
set dirty [string trim [exec git -C $auditRoot status --porcelain -- examples bench lib]]
puts "# PROVES-NAMING corpus audit: tclsh9.0 audit/proves-naming/tools/corpus.tcl"
puts "# commit $commit (corpus paths [expr {$dirty eq "" ? "clean" : "MODIFIED: $dirty"}])"
puts ""

set findings [dict create]     ;# primary location -> record
set failed {}
set compiled 0
set census [dict create]       ;# declaration location -> census entry + entry program
set mismatches 0
foreach path $programs {
    if {[catch {compilePath $path} hir options]} {
        lappend failed [list [rel $path] [dict get $options -errorcode]]
        continue
    }
    incr compiled
    set reported [dict create]
    foreach w [namingOf $hir] {
        set where [rel [hir::originLocation $hir [dict get $w primary]]]
        dict set reported $where 1
        if {[dict exists $findings $where]} continue
        dict set findings $where [dict create file [rel [pathOf $hir [dict get $w primary]]] \
            name [dict get $w data functionName] kind [dict get $w data kind] \
            message [dict get $w message] line [lineOf $hir [dict get $w primary]] entry [rel $path]]
    }
    # The census: every proves-fitted function this program compiles.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "bind"} continue
        set fn [dict get $hir exprs [dict get $node value]]
        if {[dict get $fn kind] ne "block" || ![dict exists $fn proofs] || [dict get $fn proofs] eq ""} continue
        set where [rel [hir::originLocation $hir [dict get $node origin]]]
        set entry [censusEntry $hir $node]
        # The census and the pass must agree: a declaration in shape whose
        # name does not conform is a finding, and nothing else is.
        set expected [expr {[lindex $entry 4] eq "0"}]
        if {$expected != [dict exists $reported $where]} {
            incr mismatches
            puts "MISMATCH: $where: census $entry, reported [dict exists $reported $where]"
        }
        if {[dict exists $census $where]} continue
        dict set census $where [list {*}$entry [rel $path]]
    }
}

puts "compiled $compiled of [llength $programs] programs"
foreach f $failed {
    lassign $f path code
    puts "  not compiled: $path ($code)[expr {$path in $deliberate ? " -- a deliberate rejection" : ""}]"
}
puts ""

set unclassified 0
set categories [dict create]
puts "## Findings: [dict size $findings] distinct"
set i 0
foreach where [lsort -dictionary [dict keys $findings]] {
    set f [dict get $findings $where]
    set key [list [dict get $f file] [dict get $f name]]
    puts "[incr i]. $where: [dict get $f message] (first seen compiling [dict get $f entry])"
    puts "     $where: [dict get $f line]"
    if {[dict exists $classified $key]} {
        lassign [dict get $classified $key] category why
        dict incr categories $category
        puts "     HAND: $category -- $why"
    } else {
        incr unclassified
        puts "     HAND: UNCLASSIFIED"
    }
}
puts ""
puts "## Categories"
foreach category {rename bare-validate collision} {
    puts "  $category: [expr {[dict exists $categories $category] ? [dict get $categories $category] : 0}]"
}
puts "  false positives: 0 by construction of the table (an unclassified finding fails the tool: $unclassified unclassified)"
puts ""

puts "## Census of proves-fitted functions (each declaration once; read from the HIR and its declaration line)"
set shapes [dict create]
foreach where [lsort -dictionary [dict keys $census]] {
    lassign [dict get $census $where] name ordinary result shape conforms entry
    dict incr shapes "$shape [expr {$conforms eq "1" ? "conforming" : $conforms eq "0" ? "violating" : "-"}]"
    puts "  $where: `$name`: $ordinary ordinary parameter(s), -> $result: $shape, [expr {$conforms eq "1" ? "name conforms" : $conforms eq "0" ? "name VIOLATES" : "no convention"}] (first seen compiling $entry)"
}
puts "  total: [dict size $census] proves-fitted function(s): [join [lmap {k v} $shapes {string cat "$v $k"}] {, }]"
puts "  census and findings agree: [expr {$mismatches == 0 ? "yes" : "NO ($mismatches mismatches)"}]"
puts ""

# The rename check, in a scratch copy of the library.
puts "## Rename check (scratch copy of the library; the corpus is not edited)"
if {$renames eq ""} {
    puts "  no finding to rename"
}
foreach {file pair} $renames {
    lassign $pair old new
    set scratch [file tempdir proves-naming-corpus]
    set lib [file join $scratch lib]
    file copy [file join $auditRoot lib] $lib
    set path [file join $scratch $file]
    set text [readText $path]
    set renamedText [regsub -all "(?:^|(?!\[A-Za-z0-9_:\]))\\m[string map {? \\?} $old](?!\[A-Za-z0-9_?\])" $text $new]
    writeText $path $renamedText
    set probe [dict get $probes $file]
    set saved $::core::libraryDir
    set before [surface::compile $probe probe.bot -warnings default -warning-channel ""]
    set ::core::libraryDir $lib
    try {
        set failedRename [catch {surface::compile [string map [list $old $new] $probe] probe.bot -warnings default -warning-channel ""} after]
    } finally {
        set ::core::libraryDir $saved
    }
    if {$failedRename} {
        puts "  $file: the renamed copy does not compile: $after"
        incr unclassified
    } else {
        set v0 [valueOf $before]
        set v1 [valueOf $after]
        set holds [expr {[namingOf $after] eq "" && [namingOf $before] ne "" && $v0 eq $v1 && [lindex $v0 0] ne "error"}]
        puts "  $file: `$old` -> `$new`: [expr {$holds ? "rename holds (compiles, finding gone, same value $v0)" : "RENAME CHECK FAILED ($v0 vs $v1)"}]"
        if {!$holds} {
            incr unclassified
        }
    }
    file delete -force $scratch
}
exit [expr {$unclassified > 0 || $mismatches > 0}]
