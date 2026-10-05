# corpus.tcl -- observational audit of METHOD-ELIGIBLE over the frozen corpus
# (WARNINGS-METHOD-ELIGIBLE.md, "Corpus findings"). Compiles every program of
# examples/stdlib, examples/surface (minus the deliberate rejections),
# bench/*.bot and lib/*.bot with warnings on (collected, not emitted),
# classifies the findings per distinct (callee, receiver-form) pattern, and
# *checks the round-trip law on every distinct pattern*: the call is respelled
# with method sugar in a scratch copy, and the respelled program must compile,
# lose exactly that one warning, and have the same HIR text, core IR and NIR
# (specialized and generic). The corpus itself is never edited.
#
#   tclsh9.0 audit/method-eligible/tools/corpus.tcl ?-roundtrip 1|0? ?-whole 1|0?
#
# -whole 1 additionally respells *every* eligible call of each program (last
# call first, recompiling after each, so nested calls are rewritten inside
# out) and requires the fully respelled program to have no METHOD-ELIGIBLE
# warning left and the original's NIR.
#
# Output: the report on stdout (the committed copy is corpus-audit.txt).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join [file dirname [file normalize [info script]]] rewrite.tcl]

set roundtrip 1
set whole 1
set only ""
foreach {option value} $argv {
    switch -- $option {
        -roundtrip { set roundtrip $value }
        -whole { set whole $value }
        -only { set only $value }
        default { error "unknown option $option" }
    }
}

set programs [concat \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $root examples surface] *.bot]] \
    [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root lib] *.bot]]]

if {$only ne ""} {
    set programs [lmap p $programs {if {![string match $only $p]} continue; set p}]
}

set scratch [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] method-eligible-audit-[pid]]
file mkdir $scratch
set libCopy [file join $scratch lib]
file copy [file join $root lib] $libCopy
set realLib $::core::libraryDir

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

proc compilePath {path} {
    return [surface::readProgramFile $path -warnings default -warning-channel ""]
}

proc eligible {hir} {
    return [lmap w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "METHOD-ELIGIBLE"} continue
        set w
    }]
}

proc nirOf {hir args} {
    if {[catch {native::lower::program $hir {*}$args} result options]} {
        return [list error [dict get $options -errorcode]]
    }
    return [dict get $result text]
}

# "hir-format at ..." naming the first differing line of two HIR texts.
proc FirstDifference {a b} {
    set a [split $a \n]
    set b [split $b \n]
    foreach x $a y $b {
        if {$x ne $y} {
            return "hir-format at \"[string trim $x]\" vs \"[string trim $y]\""
        }
    }
    return "hir-format (length [llength $a] vs [llength $b])"
}

# What identifies HIR as a program: its HIR text, core IR, and NIR (specialized
# and generic). Computed right after HIR is compiled -- the struct, error and
# type registries these read are those of the *current* compilation.
proc fingerprint {hir} {
    return [dict create format [hir::format $hir] lower [hir::lower $hir] \
        nir [nirOf $hir] nirGeneric [nirOf $hir -specialize 0]]
}

# The fingerprint of the program at PATH compiled now: the baseline of a round
# trip is compiled right before the respelled program, because the registries
# the fingerprint reads (declared errors, structs) are process-global and keep
# what earlier compilations loaded.
proc freshFingerprint {path} {
    return [fingerprint [compilePath $path]]
}

# "" if the fingerprints A and B are the same program; else what differs.
proc samePrograms {a b} {
    set diffs {}
    if {[dict get $a format] ne [dict get $b format]} {
        lappend diffs [FirstDifference [dict get $a format] [dict get $b format]]
    }
    if {[dict get $a lower] ne [dict get $b lower]} {lappend diffs core-ir}
    if {[dict get $a nir] ne [dict get $b nir]} {lappend diffs nir}
    if {[dict get $a nirGeneric] ne [dict get $b nirGeneric]} {lappend diffs nir-generic}
    return $diffs
}

# Where the call of warning W of HIR lives: {PATH START END}.
proc callSite {hir w} {
    set origin [dict get $w primary]
    set fields [lrange $origin 2 end]
    return [list [dict get [hir::sourceFile $hir [lindex $origin 1]] path] \
        [dict get $fields start] [dict get $fields end]]
}

# The program ENTRY with the call of warning W of HIR respelled with method
# sugar, compiled (a scratch copy: the call may be in the entry program or in
# a library module). Returns {HIR FINGERPRINT}, or raises.
proc respelled {entry hir w} {
    global root scratch libCopy realLib
    lassign [callSite $hir $w] path start end
    set member [MemberOf [dict get $w data functionName]]
    set text [readText $path]
    set new [me::sugarCall $text $path $start $end $member]
    set entryRun $entry
    if {[string first $realLib/ $path] == 0} {
        # A library module: respell its copy in the scratch library.
        writeText [file join $libCopy [string range $path [string length $realLib/] end]] $new
    } else {
        set entryRun [file join $scratch entry-[file tail $entry]]
        writeText $entryRun $new
    }
    set ::core::libraryDir $libCopy
    try {
        set hir [compilePath $entryRun]
        return [list $hir [fingerprint $hir]]
    } finally {
        set ::core::libraryDir $realLib
        # Restore the scratch library copy.
        if {[string first $realLib/ $path] == 0} {
            file copy -force $path [file join $libCopy [string range $path [string length $realLib/] end]]
        }
    }
}

# Like respelled, but the respelling stays in the scratch tree (the entry
# program is ENTRYRUN, a scratch file; modules come from the scratch library),
# so the next call can be respelled on top of it.
proc respelledPersistent {entryRun hir w} {
    global libCopy realLib
    lassign [callSite $hir $w] path start end
    set member [MemberOf [dict get $w data functionName]]
    writeText $path [me::sugarCall [readText $path] $path $start $end $member]
    set ::core::libraryDir $libCopy
    try {
        set hir [compilePath $entryRun]
        return [list $hir [fingerprint $hir]]
    } finally {
        set ::core::libraryDir $realLib
    }
}

proc MemberOf {name} {
    set i [string last :: $name]
    return [expr {$i < 0 ? $name : [string range $name [expr {$i + 2}] end]}]
}

# ---------------------------------------------------------------------------
# Classification

# The block ExprId of the declared function CALLEE-TARGET ({block E}), or "".
proc calleeBlock {target} {
    return [expr {[lindex $target 0] eq "block" ? [lindex $target 1] : ""}]
}

# 1 if the function BLOCK calls its own parameter number INDEX (0-based).
proc callsParameter {hir block index} {
    set params [dict get $hir exprs $block params]
    if {$index >= [llength $params]} {
        return 0
    }
    set b [lindex $params $index]
    set stack [dict get $hir exprs $block body]
    while {$stack ne ""} {
        set e [lindex $stack end]
        set stack [lrange $stack 0 end-1]
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] eq "call"} {
            set callee [dict get $hir exprs [dict get $node callee]]
            if {[dict get $callee kind] eq "ref" && [dict get $callee binding] eq $b} {
                return 1
            }
        }
        lappend stack {*}[hir::children $hir $e]
    }
    return 0
}

# The category of the call E (a finding) of HIR with callee facts CALLEE.
proc categoryOf {hir e callee} {
    set node [dict get $hir exprs $e]
    set second [dict get $hir exprs [lindex [dict get $node args] 1]]
    if {[dict get $second kind] eq "struct"} {
        return "config object"
    }
    set block [calleeBlock [dict get $callee target]]
    if {$block ne "" && [callsParameter $hir $block 1]} {
        return "predicate/mapper"
    }
    if {[dict get $second kind] eq "ref" && [dict get $second binding] ne ""} {
        set b [dict get $hir bindings [dict get $second binding]]
        if {[dict get $b declaredBy] ne "" && [dict get $hir exprs [dict get $b declaredBy] kind] eq "bind"
                && [dict get $hir exprs [dict get $hir exprs [dict get $b declaredBy] value] kind] eq "block"} {
            return "predicate/mapper"
        }
    }
    return "subject-first helper"
}

# ---------------------------------------------------------------------------
# The audit

set findings [dict create]     ;# location -> {pattern ...}
set patterns [dict create]     ;# {callee form} -> dict count/category/params/sample/entry
set oneParam [dict create]     ;# callee -> {count forms}
set failed {}
set compiled 0
set hirOf [dict create]
foreach path $programs {
    if {[catch {compilePath $path} hir options]} {
        lappend failed [list [file tail $path] [dict get $options -errorcode]]
        continue
    }
    incr compiled
    dict set hirOf $path $hir
    foreach w [eligible $hir] {
        set where [hir::originLocation $hir [dict get $w primary]]
        if {[dict exists $findings $where]} {
            continue
        }
        set data [dict get $w data]
        set e [dict get $data call]
        set node [dict get $hir exprs $e]
        set callee [hir::warnings::NamedCallee $hir $node]
        set pattern [list [dict get $data functionName] [dict get $data receiverForm]]
        set category [categoryOf $hir $e $callee]
        dict set findings $where [list $pattern $category]
        if {![dict exists $patterns $pattern]} {
            dict set patterns $pattern [dict create count 0 category $category \
                params [dict get $data paramCount] sample $where entry $path w $w hir $hir]
        }
        dict set patterns $pattern count [expr {[dict get $patterns $pattern count] + 1}]
    }
    # One-parameter callees of written calls: never findings.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict exists $node written]
                || [dict get $node written form] ne "function" || ![dict get $node reachable]
                || [lindex [dict get $node origin] 0] ne "file"} continue
        set callee [hir::warnings::NamedCallee $hir $node]
        if {$callee ne "" && [dict get $callee params] == 1} {
            set where [hir::originLocation $hir [dict get $node origin]]
            dict set oneParam [dict get $callee shown] [dict create sample $where]
            dict set seenOne $where [dict get $callee shown]
        }
    }
}
set oneCounts [dict create]
if {[info exists seenOne]} {
    dict for {where name} $seenOne {
        dict incr oneCounts $name
    }
}

proc rel {s} {
    global root
    return [string map [list $root/ {}] $s]
}

puts "# METHOD-ELIGIBLE corpus audit (observational; the corpus is not edited)"
puts ""
puts "programs compiled: $compiled of [llength $programs]"
foreach f $failed {
    puts "did not compile standalone: [lindex $f 0] ([lindex $f 1])"
}
puts "distinct METHOD-ELIGIBLE findings (locations): [dict size $findings]"
puts "distinct (callee, receiver-form) patterns: [dict size $patterns]"
puts ""

# Totals per category.
set totals [dict create]
dict for {where info} $findings {
    dict incr totals [lindex $info 1]
}
puts "## Findings per category"
foreach category {subject-first\ helper predicate/mapper config\ object} {
    puts "[format %-24s $category] [expr {[dict exists $totals $category] ? [dict get $totals $category] : 0}]"
}
puts ""

# Patterns.
puts "## Patterns (callee, receiver form) -- count, parameters, category, round trip"
set roundFailures 0
set roundChecked 0
foreach pattern [lsort -dictionary [dict keys $patterns]] {
    set info [dict get $patterns $pattern]
    set result "not checked"
    if {$roundtrip} {
        set w [dict get $info w]
        set hir [dict get $info hir]
        set before [llength [eligible $hir]]
        if {[catch {respelled [dict get $info entry] $hir $w} outcome options]} {
            set result "FAIL (does not compile: [string range $outcome 0 150])"
            incr roundFailures
        } else {
            lassign $outcome hir1 fp1
            set problems {}
            if {[llength [eligible $hir1]] != $before - 1} {
                lappend problems "warnings [llength [eligible $hir1]] != $before - 1"
            }
            lappend problems {*}[samePrograms [freshFingerprint [dict get $info entry]] $fp1]
            if {$problems eq ""} {
                set result "ok"
            } else {
                set result "FAIL ([join $problems {, }])"
                incr roundFailures
            }
        }
        incr roundChecked
    }
    puts [format "%-34s %-15s %4d  params %d  %-20s %s   (e.g. %s)" [lindex $pattern 0] [lindex $pattern 1] \
        [dict get $info count] [dict get $info params] [dict get $info category] $result [rel [dict get $info sample]]]
}
puts ""
puts "round trips checked: $roundChecked; failures (false positives): $roundFailures"
puts ""

# nomethod candidates: callees whose receiver reading would mislead. This is a
# human judgement recorded here for the future warning-driven refactor, never
# applied (the corpus is frozen and nothing is marked `nomethod`); the tool
# only counts how often each curated callee is a finding.
set nomethodCandidates {
    mutable_array::copy {the receiver would be the *destination* of a five-parameter copy (`dst.copy(at, src, from, n)` reads as copying dst)}
    bit_and             {symmetric operands: neither is the subject (`a.bit_and(b)`)}
    bit_or              {symmetric operands: neither is the subject (`a.bit_or(b)`)}
    bit_xor             {symmetric operands: neither is the subject (`a.bit_xor(b)`)}
}
puts "## nomethod candidates (recorded for the deferred refactor; not applied)"
foreach {callee reason} $nomethodCandidates {
    set count 0
    dict for {pattern info} $patterns {
        if {[lindex $pattern 0] eq $callee} {
            incr count [dict get $info count]
        }
    }
    puts "[format %-24s $callee] $count finding(s): $reason"
}
puts ""

# One-parameter callees.
puts "## One-parameter callees of written calls (excluded by rule 2; listed for completeness)"
foreach name [lsort -dictionary [dict keys $oneCounts]] {
    puts "[format %-34s $name] [dict get $oneCounts $name] call(s)"
}
puts ""

# Whole-program respelling.
set wholeFailures 0
if {$whole} {
    puts "## Whole-program respelling (every eligible call respelled, last first)"
    foreach path $programs {
        if {![dict exists $hirOf $path]} continue
        set hir [dict get $hirOf $path]
        set n [llength [eligible $hir]]
        if {$n == 0} continue
        # The entry program runs from a scratch copy over the scratch library.
        set entryRun [file join $scratch whole-[file tail $path]]
        writeText $entryRun [readText $path]
        set ::core::libraryDir $libCopy
        try {
            set current [compilePath $entryRun]
        } finally {
            set ::core::libraryDir $realLib
        }
        set currentFp ""
        # Respell one call at a time: always the last warning in source order,
        # so a call is respelled before the calls its receiver contains.
        set steps 0
        set status ok
        while {[llength [eligible $current]] > 0 && $steps < 500} {
            set last [lindex [eligible $current] end]
            if {[catch {respelledPersistent $entryRun $current $last} outcome options]} {
                set status "FAIL (step $steps does not compile: [string range $outcome 0 120])"
                break
            }
            lassign $outcome current currentFp
            incr steps
        }
        if {$status eq "ok"} {
            if {[llength [eligible $current]] > 0} {
                set status "FAIL ([llength [eligible $current]] warnings left)"
            } else {
                set diffs [samePrograms [freshFingerprint $path] $currentFp]
                if {$diffs ne ""} {
                    set status "FAIL ([join $diffs {, }])"
                }
            }
        }
        if {$status ne "ok"} { incr wholeFailures }
        puts "[format %-40s [rel $path]] $n warning(s), $steps step(s): $status"
        # Restore the scratch tree.
        file delete -force $libCopy
        file copy [file join $root lib] $libCopy
    }
    puts ""
    puts "whole-program failures: $wholeFailures"
}
file delete -force $scratch
exit [expr {$roundFailures + $wholeFailures > 0}]
