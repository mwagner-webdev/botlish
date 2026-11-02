# census.tcl -- the emission-claim census under the compiler
# (EMISSION-CLAIMS-MILESTONE-1.md, "Differential and generated-program
# evidence"), in two parts:
#
#   modular   every case of audit/emission-claims/census/cases.txt (the
#             modular prototype's census, its directives now the clause):
#             programs written to expose unsound or caller-dependent
#             reasoning, each claim checked by the compiler and its concrete
#             truth searched for (tools/witness.tcl), for proven claims too
#             -- a counterexample to a certified claim is a false proof,
#             and fails the census
#   mistakes  the exploratory milestone's 31 mistakes
#             (audit/emission-claims/census/mistakes.txt) applied alone to
#             examples/dfa/json's emitters, emit_probes.bot compiled: does
#             the compiler reject (accept) what the exploratory checker
#             rejected (accepted)?
#
#   tclsh9.0 audit/emission-claims/tools/census.tcl ?-part modular|mistakes|all?
#       ?-only NAME? ?-out FILE?
#
# Exits 1 on a false proof, a verdict that differs from its case's
# expectation, or a case that does not apply.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-part all -only "" -out ""} $argv]
set argv {}
source [file join $here witness.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval census {
    variable root [file dirname $::here]
    variable failures 0
    variable lines {}
}

proc census::out {line} {
    variable lines
    lappend lines $line
    puts $line
}

# The cases of PATH: {NAME DESCRIPTION EXPECT PROTOTYPE ORIGINAL FILES}.
proc census::Cases {path} {
    set cases {}
    set lines [split [emit::readText $path] \n]
    set i 0
    while {$i < [llength $lines]} {
        set line [lindex $lines $i]
        incr i
        if {![regexp {^@@ (\S+) (.*)$} $line -> name description] || $name eq "end"} continue
        set expect [dict create]
        set prototype [dict create]
        set original [dict create]
        set files [dict create]
        set file ""
        while {$i < [llength $lines]} {
            set l [lindex $lines $i]
            incr i
            if {$l eq "@@end"} break
            if {$file eq "" && [regexp {^expect (\S+) (\S+)$} $l -> fn v]} {
                dict set expect $fn $v
            } elseif {$file eq "" && [regexp {^prototype (\S+) (\S+)$} $l -> fn v]} {
                dict set prototype $fn $v
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
        lappend cases [list $name $description $expect $prototype $original $files]
    }
    return $cases
}

proc census::Modular {} {
    variable root
    variable failures
    out "## The modular census"
    out ""
    out "| case | claim | compiler | prototype | exploratory | concrete truth | finding |"
    out "|---|---|---|---|---|---|---|"
    set findings [dict create]
    foreach case [Cases [file join $root census cases.txt]] {
        lassign $case name description expect prototype original files
        if {[dict get $::options -only] ne "" && $name ne [dict get $::options -only]} continue
        set dir [emit::workspace {*}$files]
        set entry [file join $dir main.bot]
        set hir [emit::compile $entry]
        foreach r [hir::emission::claims $hir] {
            set fn [namespace tail [dict get $r function]]
            set origin [dict get $r origin]
            set path [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
            if {[file tail $path] ni [dict keys $files]} continue
            set verdict [dict get $r verdict]
            set w [emitw::witness $dir $entry $hir $r]
            if {$w eq ""} {
                set truth "no counterexample found"
            } else {
                set truth "false for ([lindex $w 0])"
            }
            set finding ""
            if {$verdict eq "proven" && $w ne ""} {
                set finding "**FALSE PROOF**"
                incr failures
            } elseif {$verdict eq "proven"} {
                set finding "certified"
            } elseif {$w ne ""} {
                set finding "rejected, disproven by a run"
            } else {
                set finding "not certified, no counterexample found"
            }
            set mark ""
            if {[dict exists $expect $fn] && [dict get $expect $fn] ne $verdict} {
                set mark " **(expected [dict get $expect $fn])**"
                incr failures
            }
            dict incr findings $finding
            out "| `$name` | `$fn` | $verdict$mark | [dict getdef $prototype $fn -] | [dict getdef $original $fn -] | $truth | $finding |"
        }
    }
    out ""
    out "| finding | claims |"
    out "|---|---:|"
    dict for {f n} $findings {
        out "| $f | $n |"
    }
    out ""
}

# The mistakes of PATH: {NAME FILE EXPECT DESCRIPTION OLD NEW}.
proc census::Mistakes {path} {
    set cases {}
    set text [emit::readText $path]
    foreach {- name file expect description body} [regexp -all -inline -line {^@@ (\S+) (\S+) (\S+) ([^\n]*)\n((?:(?!^@@ )[^\n]*\n?)*)} $text] {
        if {![regexp {<<<<\n(.*?)\n====\n(.*?)\n>>>>} $body -> old new]} continue
        lappend cases [list $name $file $expect $description $old $new]
    }
    return $cases
}

proc census::MistakesPart {} {
    variable root
    variable failures
    out "## The exploratory census's mistakes"
    out ""
    out "| mistake | file | exploratory | compiler (claims of emit_probes.bot not proven, their kinds) | agrees |"
    out "|---|---|---|---|---|"
    set agree 0
    set total 0
    foreach case [Mistakes [file join $root census mistakes.txt]] {
        lassign $case name file expect description old new
        if {[dict get $::options -only] ne "" && $name ne [dict get $::options -only]} continue
        incr total
        set dir [emit::workspace]
        set path [file join $dir $file]
        set text [emit::readText $path]
        set n 0
        set at 0
        while {[set k [string first $old $text $at]] >= 0} {
            incr n
            set at [expr {$k + 1}]
        }
        if {$n != 1} {
            out "| `$name` | $file | $expect | **does not apply** | no |"
            incr failures
            continue
        }
        set k [string first $old $text]
        emit::writeText $path [string replace $text $k [expr {$k + [string length $old] - 1}] $new]
        if {[catch {emit::compile [file join $dir emit_probes.bot]} hir]} {
            set kinds [list "compile error: [string range $hir 0 80]"]
            set rejected 1
        } else {
            set kinds [lsort -unique [lmap d [dict get $hir diagnostics] {
                if {![string match EMIT-* [dict get $d kind]]} continue
                dict get $d kind
            }]]
            set rejected [expr {[llength [lmap r [hir::emission::claims $hir] {if {[dict get $r verdict] eq "proven"} continue; set r}]] > 0}]
        }
        if {$expect eq "accepted"} {
            set ok [expr {!$rejected}]
        } else {
            set ok $rejected
            foreach k [split $expect ,] {
                if {$k ni $kinds} { set ok 0 }
            }
        }
        if {$ok} { incr agree } else { incr failures }
        set got [expr {$rejected ? "rejected: [join $kinds {, }]" : "accepted"}]
        out "| `$name` | $file | $expect | $got | [expr {$ok ? "yes" : "**no**"}] |"
    }
    out ""
    out "$agree of $total decided as the exploratory checker decided."
    out ""
}

set part [dict get $options -part]
if {$part in {modular all}} {
    census::Modular
}
if {$part in {mistakes all}} {
    census::MistakesPart
}
if {[dict get $options -out] ne ""} {
    emit::writeText [dict get $options -out] "# Emission claims: the census\n\n[join $::census::lines \n]\n"
}
emit::cleanup
exit [expr {$::census::failures > 0}]
