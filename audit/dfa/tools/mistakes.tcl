# mistakes.tcl -- the mistake census of the declared recognizers
# (DFA-COROUTINE-MILESTONE-2.md, "Static guarantees"; first written for the
# exploration's prototype, DFA-COROUTINE-EXPLORATION.md): realistic mistakes
# in examples/dfa/json/json_lex.bot, each applied alone, and what catches it.
#
#   tclsh9.0 audit/dfa/tools/mistakes.tcl ?-suite DIR? ?-fuzz N? ?-only NAME?
#       ?-out FILE?
#
# For every mistake below: if the compiler reports a diagnostic for the
# mutated module (compiled as the one import of an entry program), the
# mistake is caught statically (its codes are listed); otherwise the
# mutated json_lex.bot goes into a private application directory and the
# differential run (differential.tcl: JSONTestSuite's test_parsing in DIR,
# N generated cases, the strict oracle) decides whether the tests catch it.
# A mistake neither catches survives. Each mistake's text must occur exactly
# once in json_lex.bot (the census fails otherwise: update the mistake).
# The mistakes are mistakes.txt.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -suite "" -fuzz 2000 -only "" -out ""]
foreach {option value} $argv {
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

proc readText {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The diagnostic codes (their last words) of the program whose entry is
# main.bot in DIR: {} when it compiles.
proc codesOf {dir} {
    if {![catch {surface::readProgramFile [file join $dir main.bot] -warnings off} message options]} {
        return {}
    }
    set entries [dict getdef $options -diagnostics [list [dict create errorcode [dict get $options -errorcode]]]]
    return [lsort -unique [lmap e $entries {lindex [dict getdef $e shown [dict get $e errorcode]] end}]]
}

# {NAME KIND DESCRIPTION OLD NEW} of mistakes.txt (the format of the
# repository's mutants.txt files).
proc readMistakes {path} {
    set out {}
    set mode ""
    foreach line [split [readText $path] \n] {
        switch -- $mode {
            "" {
                if {[regexp {^@@ (\S+) (\S+) (.*)$} $line -> name kind description]} {
                    set old {}
                    set new {}
                } elseif {$line eq "<<<<"} {
                    set mode old
                }
            }
            old {
                if {$line eq "===="} {
                    set mode new
                } else {
                    lappend old $line
                }
            }
            new {
                if {$line eq ">>>>"} {
                    lappend out [list $name $kind $description [join $old \n] [join $new \n]]
                    set mode ""
                } else {
                    lappend new $line
                }
            }
        }
    }
    return $out
}
set mistakes [concat {*}[readMistakes [file join $root audit dfa tools mistakes.txt]]]

set source [readText [file join $root examples dfa json json_lex.bot]]
set rows {}
set counts [dict create]
foreach {name kind description old new} $mistakes {
    if {[dict get $options -only] ne "" && ![string match [dict get $options -only] $name]} {
        continue
    }
    set n 0
    for {set at [string first $old $source]} {$at >= 0} {set at [string first $old $source [expr {$at + 1}]]} {
        incr n
    }
    if {$n != 1} {
        puts stderr "mistake $name: its text occurs $n times in json_lex.bot"
        exit 1
    }
    set mutated [string map [list $old $new] $source]
    set dir [file tempdir dfa-mistake]
    try {
        writeText [file join $dir json_lex.bot] $mutated
        writeText [file join $dir main.bot] "import json_lex\n\n0\n"
        set codes [codesOf $dir]
        if {[llength $codes]} {
            set verdict "static"
            set detail [join $codes ", "]
        } else {
            set command [list tclsh9.0 [file join $root audit dfa tools differential.tcl] -app $dir -fuzz [dict get $options -fuzz] -seed 1 -out [file join $dir report.md]]
            if {[dict get $options -suite] ne ""} {
                lappend command -suite [dict get $options -suite]
            }
            set status [catch {exec {*}$command 2>@1} output]
            set report [readText [file join $dir report.md]]
            regexp {Disagreements with the oracle or the suite: (\d+)} $report -> disagree
            regexp {Whole and chunked runs that disagree: (\d+)} $report -> split
            if {$disagree || $split} {
                set verdict "tests"
                set first ""
                regexp {Disagreements with the oracle or the suite: \d+\n  ([^\n]*)} $report -> first
                set detail "$disagree disagreements (first: [string range $first 0 90])"
            } else {
                set verdict "survived"
                set detail ""
            }
        }
    } finally {
        file delete -force $dir
    }
    dict incr counts "$kind $verdict"
    lappend rows [list $name $kind $verdict $description $detail]
    puts "$name: $verdict $detail"
}

set report "# DFA mistake census (declared recognizers)\n\nGenerated by audit/dfa/tools/mistakes.tcl[expr {[dict get $options -suite] eq "" ? "" : " -suite JSONTestSuite/test_parsing"}] -fuzz [dict get $options -fuzz]: each mistake applied alone to examples/dfa/json/json_lex.bot.\n\n"
append report "| mistake | kind | caught by | what | detail |\n|---|---|---|---|---|\n"
foreach row $rows {
    lassign $row name kind verdict description detail
    append report "| $name | $kind | $verdict | [string map {| \\|} $description] | [string map {| \\|} $detail] |\n"
}
append report "\n| kind | caught by | mistakes |\n|---|---|---:|\n"
foreach key [lsort [dict keys $counts]] {
    append report "| [lindex $key 0] | [lindex $key 1] | [dict get $counts $key] |\n"
}
if {[dict get $options -out] eq ""} {
    puts -nonewline $report
} else {
    writeText [dict get $options -out] $report
}
