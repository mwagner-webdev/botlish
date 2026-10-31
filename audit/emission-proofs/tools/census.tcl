# census.tcl -- the modular census (MODULAR-EMISSION-PROOFS-MILESTONE-1.md,
# section 14), in two parts:
#
#   modular   every case of audit/emission-proofs/census/cases.txt: programs
#             written to expose unsound or caller-dependent reasoning,
#             checked by the modular checker and by the exploratory one;
#             every claim's concrete truth searched for (tools/concrete.tcl:
#             a run that completes with an invalid trace or yields a
#             non-viable prefix), for proven claims too -- a counterexample
#             to a proven claim is a false proof, and fails the census
#   original  the exploratory milestone's 31 mistakes
#             (audit/emitter/census/cases.txt) applied alone to the JSON
#             emitters, check_all.bot checked by the modular checker: does
#             it reject (accept) what the exploratory checker rejected
#             (accepted)?
#
#   tclsh9.0 audit/emission-proofs/tools/census.tcl ?-part modular|original|all?
#       ?-only NAME? ?-out FILE?
#
# Exits 1 on a false proof, a verdict that differs from its case's
# expectation, or a case that does not apply.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-part all -only "" -out ""} $argv]
set argv {}
source [file join $here concrete.tcl]
source [file join $here workspace.tcl]
source [file join $here modcheck.tcl]
source [file join [file dirname [file dirname $here]] emitter tools emitcheck.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

proc readText {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The modular cases: {NAME DESCRIPTION EXPECT ORIGINAL FILES}.
proc ModularCases {path} {
    set cases {}
    set lines [split [readText $path] \n]
    set i 0
    while {$i < [llength $lines]} {
        set line [lindex $lines $i]
        incr i
        if {![regexp {^@@ (\S+) (.*)$} $line -> name description] || $name eq "end"} continue
        set expect [dict create]
        set original [dict create]
        set files [dict create]
        set file ""
        while {$i < [llength $lines]} {
            set l [lindex $lines $i]
            incr i
            if {$l eq "@@end"} break
            if {$file eq "" && [regexp {^expect (\S+) (\S+)$} $l -> fn v]} {
                dict set expect $fn $v
            } elseif {$file eq "" && [regexp {^original (\S+) (\S+)$} $l -> fn v]} {
                dict set original $fn $v
            } elseif {[regexp {^--- (\S+)$} $l -> file]} {
                dict set files $file {}
            } elseif {$file ne ""} {
                dict lappend files $file $l
            }
        }
        dict for {f ls} $files {
            dict set files $f [join $ls \n]\n
        }
        lappend cases [list $name $description $expect $original $files]
    }
    return $cases
}

# The exploratory checker's verdict per claim of the program at PATH:
# short function name -> proved | rejected | unused.
proc Original {path} {
    set r [emitcheck::check $path]
    set out [dict create]
    foreach e [dict get $r emitters] {
        dict set out [namespace tail [dict get $e name]] proved
    }
    foreach d [dict get $r diagnostics] {
        if {[dict get $d kind] eq "EMIT-UNUSED"} {
            regexp {^(\S+) is not called} [dict get $d message] -> fn
            dict set out [namespace tail $fn] unused
            continue
        }
        foreach rel [dict get $d related] {
            if {[regexp {^checking (\S+)'s claim} [lindex $rel 0] -> fn]} {
                dict set out [namespace tail $fn] rejected
            }
        }
        # (A diagnostic at the claimed function itself names no claim.)
        if {[dict get $d kind] in {EMIT-INCOMPLETE EMIT-TERMINAL-VALUE}} {
            foreach e [dict get $r emitters] {
                if {[dict get $e location] eq [dict get $d location]} {
                    dict set out [namespace tail [dict get $e name]] rejected
                }
            }
        }
    }
    return $out
}

# The modular verdicts of the program at PATH: short name -> verdict, and
# each claim's result.
proc Modular {path} {
    set r [modcheck::check $path -witness 1]
    set out [dict create]
    set results [dict create]
    foreach c [dict get $r claims] {
        set fn [namespace tail [dict get $c name]]
        set v [dict get $c verdict]
        # (A function with several claims: the weakest verdict.)
        if {[dict exists $out $fn] && [dict get $out $fn] ne "proven"} continue
        dict set out $fn $v
        dict set results $fn $c
    }
    return [list $out $results $r]
}

# A counterexample to a proven claim (a false proof), or "".
proc FalseProof {claimResult} {
    foreach c $::modcheck::claims {
        if {[dict get $c name] eq [dict get $claimResult name]} {
            return [concrete::witness $c]
        }
    }
    return ""
}

set report {}
set failures 0
proc out {line} {
    global report
    lappend report $line
}

if {[dict get $options -part] in {modular all}} {
    out "## Modular cases"
    out ""
    out "| case | claim | modular | observed facts | exploratory | concrete truth | finding |"
    out "|---|---|---|---|---|---|---|"
    set counts [dict create]
    foreach case [ModularCases [file join [file dirname $here] census cases.txt]] {
        lassign $case name description expect original files
        if {[dict get $options -only] ne "" && $name ne [dict get $options -only]} continue
        set dir [epws::scratch {*}$files]
        set path [file join $dir main.bot]
        if {[catch {Modular $path} m]} {
            out "| $name | | (error) | | | [string map {| /} [lindex [split $m \n] 0]] |"
            incr failures
            continue
        }
        lassign $m verdicts results raw
        if {[catch {Original $path} originals]} {
            set originals [dict create]
        }
        # The same engine with the program's own call facts: when it also
        # proves a claim the declaration does not support, the exploratory
        # checker's proof came from its callers; when it does not, from a
        # rule of the exploratory checker's own.
        set observed [dict create]
        if {![catch {modcheck::check $path -witness 0 -facts observed} o]} {
            foreach c [dict get $o claims] {
                dict set observed [namespace tail [dict get $c name]] [dict get $c verdict]
            }
        }
        dict for {fn want} $expect {
            set got [dict getdef $verdicts $fn missing]
            set orig [dict getdef $originals $fn "not reported"]
            set truth "no counterexample found"
            if {$got eq "disproven"} {
                set w [dict get $results $fn witness]
                set truth "false for ([lindex $w 0])"
            } elseif {$got eq "proven"} {
                set w [FalseProof [dict get $results $fn]]
                if {$w ne ""} {
                    set truth "FALSE PROOF: ([lindex $w 0]) [lindex $w 1]"
                    incr failures
                }
            }
            set finding ""
            if {$orig eq "proved" && [string match "false*" $truth]} {
                if {[dict getdef $observed $fn ""] eq "proven"} {
                    set finding "exploratory false proof: caller facts"
                } else {
                    set finding "exploratory false proof: unsound rule"
                }
            } elseif {$orig eq "unused"} {
                set finding "exploratory had no facts"
            } elseif {($orig eq "proved") != ($got eq "proven")} {
                set finding "verdicts differ"
            } else {
                set finding "agree"
            }
            dict incr counts $finding
            set mark ""
            if {$got ne $want} {
                set mark " **(expected $want)**"
                incr failures
            }
            if {[dict exists $original $fn] && [dict get $original $fn] ne $orig} {
                append mark " **(exploratory expected [dict get $original $fn])**"
                incr failures
            }
            out "| `$name` | `$fn` | $got$mark | [dict getdef $observed $fn -] | $orig | $truth | $finding |"
        }
    }
    out ""
    out "| finding | claims |"
    out "|---|---:|"
    dict for {k v} $counts {
        out "| $k | $v |"
    }
}

# ---------------------------------------------------------------------------
# The exploratory census, checked by the modular checker

proc OriginalCases {path} {
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

if {[dict get $options -part] in {original all}} {
    out ""
    out "## The exploratory census under the modular checker"
    out ""
    out "| case | exploratory | modular kinds | modular verdicts of failing claims | agrees |"
    out "|---|---|---|---|---|"
    set agree 0
    set total 0
    foreach case [OriginalCases [file join [file dirname [file dirname $here]] emitter census cases.txt]] {
        lassign $case name file expect description old new
        if {[dict get $options -only] ne "" && $name ne [dict get $options -only]} continue
        set dir [epws::scratch]
        set path [file join $dir $file]
        set text [readText $path]
        set at [string first $old $text]
        if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
            out "| `$name` | $expect | (does not apply) | | |"
            incr failures
            continue
        }
        writeText $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
        if {[catch {modcheck::check [file join $dir check_all.bot] -witness 1} r]} {
            out "| `$name` | $expect | (error: [string map {| /} [lindex [split $r \n] 0]]) | | |"
            incr failures
            continue
        }
        set kinds {}
        set failing {}
        foreach c [dict get $r claims] {
            foreach d [dict get $c diagnostics] {
                lappend kinds [dict get $d kind]
            }
            if {[dict get $c verdict] ne "proven"} {
                set v [dict get $c verdict]
                if {$v eq "disproven"} { append v " ([lindex [dict get $c witness] 0])" }
                lappend failing "[namespace tail [dict get $c name]]: $v"
            }
        }
        set kinds [lsort -unique $kinds]
        set rejected [expr {$kinds ne {}}]
        set want [expr {$expect ne "accepted"}]
        incr total
        set ok [expr {$rejected == $want}]
        if {$ok} { incr agree } else { incr failures }
        set shown accepted
        if {$kinds ne {}} { set shown [join $kinds ", "] }
        if {[llength $failing] > 4} {
            set failing [list {*}[lrange $failing 0 3] "[expr {[llength $failing] - 4}] more"]
        }
        out "| `$name` | $expect | $shown | [join $failing {; }] | [expr {$ok ? "yes" : "**no**"}] |"
    }
    out ""
    out "$agree of $total cases: the modular checker rejects exactly the cases the exploratory one rejected."
}

set text [join $report \n]
if {[dict get $options -out] ne ""} {
    writeText [dict get $options -out] "$text\n"
}
puts $text
exit [expr {$failures > 0}]
