# fuzz.tcl -- random syntax errors in real programs, analyzed by the compiler
# service with syntax recovery (SYNTAX-RECOVERY-MILESTONE-1.md, "Tests").
#
#   tclsh9.0 audit/syntax-recovery/tools/fuzz.tcl ?-seed S? ?-cases N? ?-queries N?
#
# Each case takes a file of the corpus -- an example program, an application
# module of one, a golden suite -- and damages its text the way editing does:
# cut it off (typing at its end), cut a line short (an unfinished
# expression), delete a few characters, insert a bracket, an operator, a
# keyword, a quote, a tab or a line break, or cut two or three lines short.
# The damaged text is an unsaved buffer of a service workspace (nothing is
# written), and the program that reads it is analyzed. A case whose text
# still parses is skipped. The properties, for every other case:
#
#   analysis   the analysis returns a revision: recovery never fails with an
#              internal error, whatever the damage
#   syntax     its outcome is `syntax`, its errors start with its syntax
#              errors, and the damaged file's are exactly the ones a strict
#              parse of its text reports (message, line, column, in order)
#   recovered  the revision records no compiler failure; its semantics are
#              partial -- a HIR was built past the syntax errors -- unless a
#              loader error (a module that does not exist) or an error a
#              declaration raises (an unknown type in a struct's field, which
#              stops any compilation) stopped the build: those are counted
#   located    no semantic diagnostic it reports lies in malformed text (a
#              hole): what nobody could read is never checked
#   refused    no backend accepts its HIR (hir::recovery::runnable)
#   queries    service::at answers at -queries positions of the damaged file
#              without an internal error
#   transfer   service::export and service::import keep its outcome,
#              semantics and diagnostics
#
# Any violation prints the case (seed, file, damage) and the script exits 1.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root service service.tcl]
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8
unset -nocomplain ::env(BOTLISH_HIR_CACHE)

set options [dict create -seed 1 -cases 120 -queries 15]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}

# The corpus: {ENTRY FILE}, FILE the damaged file (ENTRY or a module it
# imports), relative to the repository.
set corpus {
    {examples/surface/01-arithmetic.bot examples/surface/01-arithmetic.bot}
    {examples/stdlib/csv.bot examples/stdlib/csv.bot}
    {examples/games/2048/demo.bot examples/games/2048/demo_play.bot}
    {examples/games/2048/demo.bot examples/games/2048/game2048.bot}
    {examples/games/2048/bench.bot examples/games/2048/bench.bot}
    {examples/games/icy-tower/headless.bot examples/games/icy-tower/hud.bot}
    {examples/games/icy-tower/headless.bot examples/games/icy-tower/tower.bot}
    {tests/golden/branch-form-boolean.bot tests/golden/branch-form-boolean.bot}
    {tests/golden/structs-and-enums.bot tests/golden/structs-and-enums.bot}
}
foreach extra [lsort [glob -directory [file join $root examples surface] *.bot]] {
    set rel [string range $extra [string length $root/] end]
    if {[lsearch -exact -index 0 $corpus $rel] < 0} {
        lappend corpus [list $rel $rel]
    }
}

set inserts [list ( ) \[ \] \{ \} : + = \" ' , . "fn " "if " "return " "\n" "\t" "    " \$ "import " "->"]

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

# TEXT damaged one way: {KIND TEXT}.
proc damage {text} {
    global inserts
    set lines [split $text \n]
    set kind [pick {truncate cut-line cut-line delete insert insert several}]
    switch -- $kind {
        truncate {
            set at [expr {int(rand() * [string length $text])}]
            return [list "truncate at $at" [string range $text 0 $at-1]]
        }
        cut-line - several {
            set n [expr {$kind eq "several" ? 2 + int(rand() * 2) : 1}]
            set cut {}
            for {set k 0} {$k < $n} {incr k} {
                set l [expr {int(rand() * [llength $lines])}]
                set line [lindex $lines $l]
                set content [string trimleft $line]
                if {$content eq "" || [string match #* $content]} continue
                set indent [expr {[string length $line] - [string length $content]}]
                set c [expr {$indent + 1 + int(rand() * max(1, [string length $content] - 1))}]
                lset lines $l [string range $line 0 $c-1]
                lappend cut "[expr {$l + 1}]:[expr {$c + 1}]"
            }
            return [list "cut-line [join $cut ,]" [join $lines \n]]
        }
        delete {
            set at [expr {int(rand() * [string length $text])}]
            set n [expr {1 + int(rand() * 8)}]
            return [list "delete $n at $at" [string replace $text $at [expr {$at + $n - 1}]]]
        }
        insert {
            set at [expr {int(rand() * ([string length $text] + 1))}]
            set what [pick $inserts]
            return [list "insert [list $what] at $at" "[string range $text 0 $at-1]$what[string range $text $at end]"]
        }
    }
}

# The strict parse's diagnostics of TEXT as {LINE COLUMN MESSAGE} (none: {}).
proc strict {text path} {
    if {![catch {surface::parse $text $path}]} {
        return {}
    }
    catch {surface::parse $text $path} - details
    return [lmap entry [dict get $details -diagnostics] {
        list [dict get $entry location line] [dict get $entry location column] [dict get $entry summary]
    }]
}


set failures 0
set counts [dict create skipped 0 partial 0 loader 0 declaration 0 cases 0]
proc fail {case property detail} {
    global failures
    incr failures
    puts "FAIL $property: $case\n    $detail"
}

for {set i 0} {$i < [dict get $options -cases]} {incr i} {
    lassign [pick $corpus] entryRel fileRel
    set entry [file join $root $entryRel]
    set path [file join $root $fileRel]
    set original [surface::source::text $path]
    lassign [damage $original] how text
    set case "seed [dict get $options -seed] case $i: $fileRel ($how)"
    set expected [strict $text $path]
    if {$expected eq ""} {
        dict incr counts skipped
        continue
    }
    dict incr counts cases
    set ws [service::workspace -warnings off -cache ""]
    service::setDocument $ws $path $text
    if {[catch {service::analyze $ws $entry} rev details]} {
        fail $case analysis [dict get $details -errorinfo]
        service::closeWorkspace $ws
        continue
    }
    set info [service::revision $rev]
    set errors [service::diagnostics $rev -severity error]
    # syntax
    if {[dict get $info outcome] ne "syntax"} {
        fail $case syntax "outcome [dict get $info outcome]"
    }
    set seenOther 0
    set mine {}
    foreach entryError $errors {
        set syntax [expr {[dict get $entryError code] eq {SURFACE SYNTAX}}]
        if {$syntax && $seenOther} {
            fail $case syntax "a syntax error after a semantic one: [dict get $entryError message]"
        }
        if {!$syntax} {
            set seenOther 1
        } elseif {[dict getdef $entryError file ""] eq $path} {
            lappend mine [list [dict get $entryError line] [dict get $entryError column] [dict get $entryError message]]
        }
    }
    if {$mine ne $expected} {
        fail $case syntax "reported [list $mine], a strict parse [list $expected]"
    }
    # recovered
    set loaderError [expr {[lsearch -glob [lmap e $errors {dict get $e code}] {SURFACE MODULE *}] >= 0}]
    if {[dict get $info failure] ne ""} {
        fail $case recovered "the compiler failed: [dict get $info failure errorinfo]"
    } elseif {[dict get $info semantics] eq "partial"} {
        dict incr counts partial
    } elseif {$loaderError} {
        dict incr counts loader
    } else {
        dict incr counts declaration
    }
    set hir [service::hir $rev]
    if {$hir ne ""} {
        # located
        set holes {}
        foreach e [hir::walk $hir] {
            if {[dict exists $hir exprs $e hole]} {
                set origin [dict get $hir exprs $e origin]
                if {[dict exists $origin file] && [dict exists $origin start]} {
                    lappend holes [list [dict get $origin file] [dict get $origin start] [dict get $origin end]]
                }
            }
        }
        foreach entryError $errors {
            if {[dict get $entryError code] eq {SURFACE SYNTAX} || ![dict exists $entryError start]} continue
            foreach hole $holes {
                lassign $hole file start end
                if {$file eq [dict get $entryError file] && [dict get $entryError start] >= $start && [dict get $entryError start] < $end} {
                    fail $case located "[dict get $entryError message] lies in malformed text ($start..$end)"
                }
            }
        }
        # refused
        if {![catch {hir::recovery::runnable $hir}]} {
            fail $case refused "a backend would accept the recovered HIR"
        }
    }
    # queries
    set lines [split $text \n]
    for {set q 0} {$q < [dict get $options -queries]} {incr q} {
        set l [expr {int(rand() * [llength $lines])}]
        set column [expr {1 + int(rand() * max(1, [string length [lindex $lines $l]]))}]
        if {[catch {service::at $rev $path [expr {$l + 1}] $column} answer details]
                && [lindex [dict get $details -errorcode] 0] ne "SERVICE"} {
            fail $case queries "line [expr {$l + 1}] column $column: [dict get $details -errorinfo]"
        }
    }
    # transfer
    if {[catch {
        set copy [service::import $ws [service::export $rev]]
        set copied [service::revision $copy]
        if {[dict get $copied outcome] ne [dict get $info outcome] || [dict get $copied semantics] ne [dict get $info semantics]
                || [lmap e [service::diagnostics $copy] {dict get $e message}] ne [lmap e [service::diagnostics $rev] {dict get $e message}]} {
            fail $case transfer "the imported revision differs"
        }
        service::release $copy
    } message details]} {
        fail $case transfer [dict get $details -errorinfo]
    }
    service::release $rev
    service::closeWorkspace $ws
}

puts "seed [dict get $options -seed]: [dict get $counts cases] damaged programs analyzed ([dict get $counts partial] partial, [dict get $counts loader] stopped by a loader error, [dict get $counts declaration] by a declaration's error), [dict get $counts skipped] still parsing (skipped); $failures failures"
exit [expr {$failures > 0}]
