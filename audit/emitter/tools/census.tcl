# census.tcl -- the emitter mistake census (EMITTER-COROUTINE-EXPLORATION.md,
# "Correctness"): every case of audit/emitter/census/cases.txt applied alone
# to the emitter modules, then
#
#   static    what the emission checker reports for check_all.bot (its
#             diagnostic kinds), held to the case's EXPECT;
#   observed  check_all.bot run on the interpreter: each probe's output
#             against the unmutated program's, and a changed one against
#             the oracle (tools/oracle.py: valid or invalid JSON);
#
# and the case's category, from both:
#
#   1 static    the checker rejects it
#   2 dynamic   accepted, with a check at run time that fails instead of
#               completing with invalid output (a guard)
#   3 failure   accepted: the mistake (or bad data) makes the emitter fail,
#               never complete with invalid output
#   4 outside   the guarantee does not cover it (a wrong value, a JSON
#               text's structure, a non-terminating emitter)
#
#   tclsh9.0 audit/emitter/tools/census.tcl ?-only NAME? ?-out FILE?
#
# Exits 1 when a case's static verdict differs from its EXPECT or a case
# does not apply.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -out ""]
foreach {option value} $argv {
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root audit emitter tools workspace.tcl]
source [file join $root audit emitter tools emitcheck.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

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

# The cases: {NAME FILE EXPECT DESCRIPTION OLD NEW}.
proc Cases {path} {
    set cases {}
    set lines [split [readText $path] \n]
    set i 0
    while {$i < [llength $lines]} {
        set line [lindex $lines $i]
        incr i
        if {![string match "@@ *" $line]} continue
        regexp {^@@ (\S+) (\S+) (\S+) (.*)$} $line -> name file expect description
        set old {}
        set new {}
        set mode ""
        while {$i < [llength $lines]} {
            set l [lindex $lines $i]
            incr i
            switch -- $l {
                <<<< { set mode old; continue }
                ==== { set mode new; continue }
                >>>> { break }
            }
            lappend $mode $l
        }
        lappend cases [list $name $file $expect $description [join $old \n] [join $new \n]]
    }
    return $cases
}

# The probes of check_all.bot (its value, a List of Lists of Int) and how
# the oracle reads each: unicode, bytes, or "" (not JSON: a digest, a
# prefix, the protocol after the end).
set probeKinds {unicode unicode unicode unicode unicode unicode unicode unicode bytes unicode
    unicode unicode "" "" "" unicode unicode unicode unicode}

proc Probes {dir} {
    set hir [surface::readProgramFile [file join $dir check_all.bot] -warnings off]
    set outcome [outcomeUnderHir compile $hir]
    if {[lindex $outcome 0] ne "value"} {
        return [list error [lrange $outcome 0 2]]
    }
    set text [lindex $outcome 1]
    set lists [regexp -all -inline {\[[-0-9, ]*\]} [string range $text 1 end-1]]
    # check_all.bot's handlers: one List of one negative Int per error.
    set errors {[-2] IndexNotFound [-3] sinks::Invalid [-4] number_emit::NotCanonical [-5] string_emit::NotAScalar}
    if {[llength $lists] == 1 && [dict exists $errors [lindex $lists 0]]} {
        return [list error [list fails [dict get $errors [lindex $lists 0]]]]
    }
    return [list value $lists]
}

proc Oracle {lines} {
    set f [open "|python3 -I [list [file join $::root audit emitter tools oracle.py]]" r+]
    fconfigure $f -encoding utf-8
    puts -nonewline $f [join $lines \n]\n
    close $f write
    set out [split [string trim [read $f]] \n]
    close $f
    return $out
}

proc Codes {probe} {
    set codes [string map {" " ""} [string range $probe 1 end-1]]
    if {$codes eq ""} {
        return -
    }
    return $codes
}

set cases [Cases [file join $root audit emitter census cases.txt]]
set base [Probes [emitws::scratch]]
if {[lindex $base 0] ne "value"} {
    puts stderr "the unmutated check_all.bot does not run: $base"
    exit 1
}
set baseProbes [lindex $base 1]

set rows {}
set failures 0
foreach c $cases {
    lassign $c name file expect description old new
    if {[dict get $options -only] ne "" && $name ne [dict get $options -only]} continue
    set dir [emitws::scratch]
    set path [file join $dir $file]
    set text [readText $path]
    set at [string first $old $text]
    if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
        puts "$name: the text to replace does not occur exactly once in $file"
        incr failures
        continue
    }
    writeText $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    # Static: the checker (a front-end rejection is the compiler's own).
    if {[catch {emitcheck::check [file join $dir check_all.bot]} result]} {
        set static "compile error: [lindex [split $result \n] 0]"
        set kinds compile
    } else {
        set kinds [lsort -unique [lmap d [dict get $result diagnostics] {dict get $d kind}]]
        set static [expr {$kinds eq {} ? "accepted" : [join $kinds ,]}]
        set first [lindex [dict get $result diagnostics] 0]
    }
    # EXPECT's kinds must all be reported (a mistake may also break the
    # claims of the emitters that call the one it is in); `accepted`, none.
    if {$expect eq "accepted"} {
        set ok [expr {$kinds eq {}}]
    } else {
        set ok 1
        foreach k [split $expect ,] {
            if {$k ni $kinds} {
                set ok 0
            }
        }
    }
    if {!$ok} {
        incr failures
    }
    # Observed.
    if {[string match vacuous* $description]} {
        set observed "not run (never completes)"
    } else {
        set run [Probes $dir]
        if {[lindex $run 0] ne "value"} {
            set observed "fails: [lindex $run 1 1]"
        } else {
            set changed {}
            set lines {}
            foreach p [lindex $run 1] b $baseProbes k $probeKinds i [lsearch -all [lindex $run 1] *] {
                if {$p eq $b || $k eq ""} continue
                lappend changed $i
                lappend lines "$k [Codes $p]"
            }
            if {$changed eq {}} {
                set observed "unchanged"
            } else {
                set verdicts [Oracle $lines]
                set invalid [lmap i $changed v $verdicts {if {[string match invalid* $v]} {set i} else continue}]
                if {$invalid ne {}} {
                    set observed "invalid output (probes [join $invalid {, }])"
                } else {
                    set observed "valid, changed (probes [join $changed {, }])"
                }
            }
        }
    }
    # The category.
    # (An accepted case's description says which: dynamic -- a check at
    # run time the claim relies on fails; failure -- the mistake makes the
    # emitter fail; semantic, structure, vacuous -- outside the guarantee.)
    if {$kinds ne {}} {
        set category "1 static"
    } elseif {[regexp {^(semantic|structure|vacuous)} $description]} {
        set category "4 outside"
    } elseif {[string match dynamic* $description]} {
        set category "2 dynamic"
    } elseif {[string match failure* $description]} {
        set category "3 failure"
    } else {
        set category "? unclassified"
    }
    file delete -force $dir
    lappend rows [list $name $description $static $observed $category [expr {$ok ? "" : " (expected $expect)"}]]
    puts "$name: $static; $observed; $category[expr {$ok ? "" : " -- EXPECTED $expect"}]"
}

if {[dict get $options -out] ne ""} {
    set md "# The emitter mistake census\n\n"
    append md "Generated by `audit/emitter/tools/census.tcl` from `audit/emitter/census/cases.txt`\n"
    append md "(EMITTER-COROUTINE-EXPLORATION.md, \"Correctness\"). Each case is applied alone to\n"
    append md "the emitter modules; *static* is what the emission checker reports for\n"
    append md "`check_all.bot`, *observed* what the program's probes produce on the Tcl\n"
    append md "compiler (against the unmutated program and the oracle).\n\n"
    append md "| case | mistake | static | observed | category |\n|---|---|---|---|---|\n"
    foreach r $rows {
        lassign $r name description static observed category note
        append md "| `$name` | [string map {| \\|} $description] | $static$note | $observed | $category |\n"
    }
    set counts [dict create]
    foreach r $rows {
        dict incr counts [lindex $r 4]
    }
    append md "\n| category | cases |\n|---|---:|\n"
    foreach k [lsort [dict keys $counts]] {
        append md "| $k | [dict get $counts $k] |\n"
    }
    writeText [dict get $options -out] $md
}
exit [expr {$failures > 0}]
