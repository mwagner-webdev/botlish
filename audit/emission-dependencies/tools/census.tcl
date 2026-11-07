# census.tcl -- the binding and signature dependency census of emission
# claims (EMISSION-BINDING-AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md):
# every case of audit/emission-dependencies/census/cases.txt compiled
#
#   * leniently, with a fresh certificate memo (the default) and with the
#     memo off: each claim's verdict, its certificate, the functions its
#     certificate depends on, what a rejecting compilation reports;
#   * strictly: accepted, or the kind it raises;
#   * through HIR interchange (encode, then decode in this process, which
#     verifies the text's claims again), with the memo on and off;
#   * run, where the case says so: its files with every emission claim
#     erased (emit::strip), on every backend, the claim's trace judged by
#     the reference interpreter (tests/dfa-support.tcl) -- a certified claim
#     whose run is invalid is a false certificate;
#
# and every sequence of it compiled in one process with the memo kept, as
# the compiler service does across revisions.
#
#   tclsh9.0 audit/emission-dependencies/tools/census.tcl ?-only NAMES?
#       ?-backends LIST? ?-out FILE?
#
# Exits 1 when an observation differs from what the case records
# (`observed`, a sequence step, a run's judgment): the record is the
# census's account of the compiler at its commit, and a change is to be
# looked at and recorded. A false certificate the record already states is
# reported, prominently, but is no difference.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-only "" -backends {interp compile cranelift-generic cranelift} -out ""} $argv]
set argv {}
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root tests emission-support.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval census {
    variable root $::root
    variable lines {}
    variable differences 0
    variable falseCerts {}
    variable open {}
    variable base [file tempdir]
    variable counter 0
}

proc census::out {line} {
    variable lines
    lappend lines $line
    puts $line
}

proc census::Differ {what} {
    variable differences
    incr differences
    out "**DIFFERENT:** $what"
}

# The cases and sequences of PATH: {cases DICT order NAMES sequences LIST}.
# A case: {name N description D section S class C observed V appropriate V
# strict K recover 0|1 run {INDEX JUDGMENT} files {NAME TEXT ...}}; a
# sequence: {name N description D steps {{CASE VERDICTS REUSE ?run {I J}?}...}}.
proc census::Parse {path} {
    set cases [dict create]
    set order {}
    set sequences {}
    set lines [split [emit::readText $path] \n]
    set i 0
    while {$i < [llength $lines]} {
        set line [lindex $lines $i]
        incr i
        if {[regexp {^@@sequence (\S+) (.*)$} $line -> name description]} {
            set steps {}
            while {[set line [lindex $lines $i]] ne "@@end"} {
                incr i
                if {[regexp {^step (\S+) (.+) (fresh|reused)$} $line -> c verdicts reuse]} {
                    lappend steps [dict create case $c verdicts $verdicts reuse $reuse]
                } elseif {[regexp {^run (\d+) (ok|invalid)$} $line -> index judgment]} {
                    lset steps end [dict replace [lindex $steps end] run [list $index $judgment]]
                } elseif {[string trim $line] ne ""} {
                    error "$path: unknown sequence line: $line"
                }
            }
            incr i
            lappend sequences [dict create name $name description $description steps $steps]
            continue
        }
        if {![regexp {^@@ (\S+) (.*)$} $line -> name description]} {
            continue
        }
        set case [dict create name $name description $description section "" class "" observed {} \
            appropriate {} strict "" recover 0 run {} files {}]
        set file ""
        set text {}
        while {[set line [lindex $lines $i]] ne "@@end"} {
            incr i
            if {[regexp {^--- (\S+)$} $line -> next]} {
                if {$file ne ""} {
                    dict lappend case files $file [join $text \n]\n
                }
                set file $next
                set text {}
                continue
            }
            if {$file ne ""} {
                lappend text $line
                continue
            }
            switch -regexp -matchvar m -- $line {
                {^section (.+)$} { dict set case section [lindex $m 1] }
                {^class (\S)$} { dict set case class [lindex $m 1] }
                {^observed (.+)$} { dict set case observed [lindex $m 1] }
                {^appropriate (.+)$} { dict set case appropriate [lindex $m 1] }
                {^strict (\S+)$} { dict set case strict [lindex $m 1] }
                {^recover$} { dict set case recover 1 }
                {^run (\d+) (ok|invalid)$} { dict set case run [list [lindex $m 1] [lindex $m 2]] }
                default { error "$path: unknown line in $name: $line" }
            }
        }
        incr i
        # The file text ends where @@end begins: drop the blank lines before it.
        dict lappend case files $file [string trimright [join $text \n] \n]\n
        dict set cases $name $case
        lappend order $name
    }
    return [dict create cases $cases order $order sequences $sequences]
}

# A private directory holding the files FILES (NAME TEXT ...), each through
# FILTER (a command prefix taking the text) when one is given.
proc census::Directory {files {filter {}}} {
    variable base
    variable counter
    set dir [file join $base case[incr counter]]
    file mkdir $dir
    foreach {name text} $files {
        if {$filter ne {}} {
            set text [{*}$filter $text]
        }
        emit::writeText [file join $dir $name] $text
    }
    return $dir
}

# The lenient HIR of CASE's main.bot in DIR (the memo as it is).
proc census::Lenient {case dir} {
    set extra {}
    if {[dict get $case recover]} {
        set extra {-recover-syntax 1}
    }
    return [surface::readProgramFile [file join $dir main.bot] -warnings off -strict 0 {*}$extra]
}

# Each claim's verdict, `+` when its record holds a certificate.
proc census::Verdicts {hir} {
    return [lmap r [hir::emission::claims $hir] {
        set v [dict get $r verdict]
        if {[dict exists $r certificate]} { append v + }
        set v
    }]
}

proc census::Depends {hir} {
    set out {}
    foreach r [hir::emission::claims $hir] {
        if {[dict exists $r certificate]} {
            lappend out [join [dict keys [dict get $r certificate depends functions]] ,]
        } else {
            lappend out -
        }
    }
    return $out
}

# The strict outcome of CASE in DIR: accepted, or the kind it raises.
proc census::Strict {case dir} {
    set ::hir::emission::memo [dict create]
    if {[catch {surface::readProgramFile [file join $dir main.bot] -warnings off} message options]} {
        set code [dict get $options -errorcode]
        if {[lindex $code 1] eq "SYNTAX"} {
            return SYNTAX
        }
        return [lindex $code end]
    }
    return accepted
}

# HIR interchange of HIR, decoded in this process with the memo on (as it is)
# and off: kept or refused (CODE).
proc census::Interchange {hir} {
    set out {}
    foreach memo {1 0} {
        set ::hir::emission::useMemo $memo
        if {[catch {hir::interchange::decode [hir::interchange::encode $hir]} message options]} {
            lappend out "refused ([lindex [dict get $options -errorcode] end])"
        } else {
            lappend out kept
        }
    }
    set ::hir::emission::useMemo 1
    return [join $out " / "]
}

# The run of CASE's files, claims erased, on every backend: {BACKEND SYMBOLS
# JUDGMENT}..., the trace judged against the recognizer of RECORD.
proc census::Run {case record} {
    set dir [Directory [dict get $case files] emit::strip]
    set model [emit::reference $dir]
    set key [list "" [dict get $record recognizer]]
    set out {}
    foreach backend [dict get $::options -backends] {
        set result [exec [info nameofexecutable] [file join $::root main.tcl] -backend $backend \
            [file join $dir main.bot] 2>@1]
        if {![regexp {value: \[([^\]]*)\]} $result -> items]} {
            lappend out [list $backend {} [list invalid "no trace: $result"]]
            continue
        }
        set symbols [lmap x [split $items ,] {string trim $x}]
        lappend out [list $backend $symbols [emit::judge $model $key complete $symbols]]
    }
    return $out
}

# The judgment of RUNS (Run's): ok when every backend's trace is valid.
proc census::Judgment {runs} {
    foreach r $runs {
        if {[lindex $r 2] ne "ok"} { return invalid }
    }
    return ok
}

proc census::RunText {runs} {
    set traces [lsort -unique [lmap r $runs {lindex $r 1}]]
    set judgments [lsort -unique [lmap r $runs {lindex [lindex $r 2] 0}]]
    return "[join [lmap r $runs {lindex $r 0}] ,]: trace [join $traces { / }], [join $judgments /]"
}

proc census::CheckCase {case} {
    variable falseCerts
    variable open
    set name [dict get $case name]
    set dir [Directory [dict get $case files]]
    set ::hir::emission::memo [dict create]
    set ::hir::emission::useMemo 1
    set hir [Lenient $case $dir]
    set verdicts [Verdicts $hir]
    set depends [Depends $hir]
    set reported [lsort -unique [lmap d [hir::recovery::reported $hir] {dict get $d kind}]]
    set ::hir::emission::memo [dict create]
    set ::hir::emission::useMemo 0
    set off [Verdicts [Lenient $case $dir]]
    set ::hir::emission::useMemo 1
    set ::hir::emission::memo [dict create]
    set hir [Lenient $case $dir]
    set interchange [Interchange $hir]
    set strict [Strict $case $dir]
    set run ""
    if {[dict get $case run] ne {}} {
        lassign [dict get $case run] index judgment
        set record [lindex [hir::emission::claims $hir] [expr {$index - 1}]]
        set runs [Run $case $record]
        set run [RunText $runs]
        if {[Judgment $runs] ne $judgment} {
            Differ "$name: its run is [Judgment $runs], recorded $judgment"
        }
        if {[Judgment $runs] eq "invalid" && [lindex $verdicts [expr {$index - 1}]] eq "proven+"} {
            lappend falseCerts "$name (claim $index): $run"
        }
    }
    if {$verdicts ne [dict get $case observed]} {
        Differ "$name: verdicts $verdicts, recorded [dict get $case observed]"
    }
    if {$strict ne [dict get $case strict]} {
        Differ "$name: strict $strict, recorded [dict get $case strict]"
    }
    if {[dict get $case appropriate] ne [dict get $case observed]} {
        lappend open "$name ([dict get $case class]): [dict get $case observed] -> [dict get $case appropriate]"
    }
    set note ""
    if {$off ne $verdicts} { set note "memo off: $off" }
    if {$run ne ""} { set note [string trim "$note; run $run" "; "] }
    out "| `$name` | [dict get $case class] | [join $verdicts { }] | [join [dict get $case appropriate] { }] | $strict | [join $reported { }] | [join $depends { }] | $interchange | $note |"
}

set parsed [census::Parse [file join $root audit emission-dependencies census cases.txt]]
set cases [dict get $parsed cases]
set only [dict get $options -only]
census::out "# Binding and signature dependency census"
census::out ""
census::out "Generated by \`tclsh9.0 audit/emission-dependencies/tools/census.tcl\` (backends: [join [dict get $options -backends] {, }])."
census::out "Columns: the case, its class (the report's section 19), each claim's verdict compiled leniently with a fresh memo (\`+\`: a certificate), the appropriate verdict, the strict outcome, what a rejecting compilation reports, the functions each certificate depends on, HIR interchange decoded with the memo on / off, and notes (the verdicts with the memo off where they differ; the run of the program with its claims erased)."
set section ""
foreach name [dict get $parsed order] {
    if {$only ne "" && $name ni $only} continue
    set case [dict get $cases $name]
    if {[dict get $case section] ne $section} {
        set section [dict get $case section]
        census::out ""
        census::out "## $section"
        census::out ""
        census::out "| case | class | verdicts | appropriate | strict | reported | depends | interchange | notes |"
        census::out "|---|---|---|---|---|---|---|---|---|"
    }
    census::CheckCase $case
}
if {$only eq ""} {
    census::out ""
    census::out "## Sequences (one process, the memo kept)"
    foreach sequence [dict get $parsed sequences] {
        census::out ""
        census::out "**[dict get $sequence name]**: [dict get $sequence description]"
        census::out ""
        census::out "| step | verdicts | reuse | depends | run |"
        census::out "|---|---|---|---|---|"
        set ::hir::emission::memo [dict create]
        set ::hir::emission::useMemo 1
        foreach step [dict get $sequence steps] {
            set case [dict get $cases [dict get $step case]]
            set dir [census::Directory [dict get $case files]]
            set hir [census::Lenient $case $dir]
            set verdicts [census::Verdicts $hir]
            set reuse [expr {[dict getdef $::hir::emission::stats reusedClaims {}] ne {} ? "reused" : "fresh"}]
            set run ""
            if {[dict exists $step run]} {
                lassign [dict get $step run] index judgment
                set runs [census::Run $case [lindex [hir::emission::claims $hir] [expr {$index - 1}]]]
                set run [census::RunText $runs]
                if {[census::Judgment $runs] ne $judgment} {
                    census::Differ "[dict get $sequence name] [dict get $step case]: its run is [census::Judgment $runs], recorded $judgment"
                }
                if {[census::Judgment $runs] eq "invalid" && [lindex $verdicts [expr {$index - 1}]] eq "proven+"} {
                    lappend census::falseCerts "sequence [dict get $sequence name], step [dict get $step case] (claim $index): $run"
                }
            }
            if {$verdicts ne [dict get $step verdicts] || $reuse ne [dict get $step reuse]} {
                census::Differ "[dict get $sequence name] [dict get $step case]: $verdicts $reuse, recorded [dict get $step verdicts] [dict get $step reuse]"
            }
            census::out "| `[dict get $step case]` | [join $verdicts { }] | $reuse | [join [census::Depends $hir] { }] | $run |"
        }
    }
}
census::out ""
census::out "## Summary"
census::out ""
census::out "False certificates (a certified claim whose run is invalid): [llength $census::falseCerts]"
foreach f $census::falseCerts {
    census::out "* **FALSE CERTIFICATE** $f"
}
census::out ""
census::out "Open cases (the verdict observed is not the appropriate one): [llength $census::open]"
foreach o $census::open {
    census::out "* $o"
}
census::out ""
census::out "Differences from the record: $census::differences"
if {[dict get $options -out] ne ""} {
    emit::writeText [dict get $options -out] "[join $census::lines \n]\n"
}
file delete -force $census::base
exit [expr {$census::differences > 0}]
