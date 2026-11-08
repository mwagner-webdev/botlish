# census.tcl -- the CSV emitters' mutation census
# (CSV-EMISSION-VALIDATION-MILESTONE-1.md, section 12).
#
#   tclsh9.0 audit/csv-emission/tools/census.tcl ?-only NAME? ?-out FILE?
#       ?-backend B? ?-length L? ?-show 1?
#
# (-show 1 prints the oracle's every failure, for a mutant's diagnosis.)
#
# Each mutation of audit/csv-emission/census/mutants.txt is applied alone to
# a private copy of examples/dfa/csv. Then:
#
#   1. static: every emitter module compiled (claims.tcl): which claims the
#      compiler rejects, and their diagnostic kinds;
#   2. runs: the mutated emitters, their claims removed (a claim is erased:
#      the same code runs), on the ordinary examples (a small realistic
#      table: names, a comma, a quoted nickname -- ASCII, no control) and on
#      the adversarial inputs (every corpus value as a field and as a
#      record's field, every kind; every string of length 0..L over
#      {a , " CR LF}), on one backend (compile by default);
#   3. every trace judged by the declared recognizer (the reference
#      interpreter: grammar), every outcome by oracle.py (no Botlish:
#      expected completion or failure, reference serialization, strict
#      parse, csv module round trip, final value).
#
# The census computes each mutation's class (mutants.txt's header) from
# those facts and fails when it is not the one stated, when a stated kind is
# not reported, when a block does not apply -- and above all when a claim
# the compiler certified has an invalid trace (a false proof).

set here [file dirname [file normalize [info script]]]
set options [dict merge {-only "" -out "" -backend compile -length 3 -show 0} $argv]
set argv {}
source [file join [file dirname [file dirname [file dirname $here]]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]
source [file join $here run.tcl]
source [file join $here claims.tcl]
source [file join $::projectRoot tests emission-support.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval census {
    variable failures 0
    variable lines {}
    variable original $::csvrun::csvDir
}

proc census::out {line} {
    variable lines
    lappend lines $line
    puts $line
    flush stdout
}

proc census::codes {s} {
    return [lmap ch [split $s ""] {scan $ch %c}]
}

# {NAME FILE EXPECT CLASS DESCRIPTION BLOCKS}..., BLOCKS {OLD NEW}...
proc census::Mutants {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    set out {}
    foreach chunk [lrange [split [string map [list "\n@@ " \x01] $text] \x01] 1 end] {
        set head [lindex [split $chunk \n] 0]
        regexp {^(\S+) (\S+) (\S+) (\S+) (.*)$} $head -> name file expect class description
        set blocks [regexp -all -inline {<<<<\n(.*?)\n====\n(.*?)\n>>>>} $chunk]
        set pairs {}
        foreach {- old new} $blocks {
            lappend pairs [list $old $new]
        }
        lappend out [list $name $file $expect $class $description $pairs]
    }
    return $out
}

proc census::Read {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}

proc census::Write {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The ordinary examples: a table a program might really export.
proc census::Ordinary {} {
    set header [list [codes id] [codes name] [codes comment]]
    set rows [list \
        [list [codes 1] [codes "Ada Lovelace"] [codes "First program, 1843"]] \
        [list [codes 2] [codes "Grace \"Amazing Grace\" Hopper"] [codes COBOL]] \
        [list [codes 3] [codes "Alan Turing"] {}] \
        [list [codes 4] [codes "Edsger W. Dijkstra"] [codes "Go To Statement Considered Harmful"]]]
    set cases {}
    foreach kind {strict_document utf8_document bytes_document selective_document selective_strict_document} {
        lappend cases [list $kind [concat [list $header] $rows]]
    }
    lappend cases [list bytes_unterminated $rows]
    foreach row $rows {
        foreach f $row {
            foreach kind {strict_field utf8_field bytes_field selective_field} {
                lappend cases [list $kind $f]
            }
        }
    }
    return $cases
}

# The adversarial inputs: every corpus value as a field of every kind and as
# the middle field of a record of every document kind.
proc census::Adversarial {} {
    set cases {}
    set header [list [codes id] [codes value] [codes note]]
    dict for {name text} [csvrun::values] {
        set c [codes $text]
        foreach kind {strict_field utf8_field bytes_field selective_field} {
            lappend cases [list $kind $c]
        }
        lappend cases [list bytes_from_bytes [csvrun::Utf8 $c]]
        foreach kind {strict_document utf8_document bytes_document selective_document selective_strict_document} {
            lappend cases [list $kind [list $header [list [codes $name] $c [codes "\"$name\""]]]]
        }
        lappend cases [list bytes_unterminated [list [list [codes $name] $c {}] [list $c {} $c]]]
    }
    return $cases
}

# {INVALID ORACLE-FAILURES}: the traces the recognizer rejects, and the
# oracle's failures as {CHECK MESSAGE} pairs.
proc census::Judge {cases outcomes} {
    set invalid 0
    foreach c $cases o $outcomes {
        if {[csvrun::judge $c $o] ne "ok"} {
            incr invalid
        }
    }
    set dir [file tempdir]
    set path [file join $dir lines.txt]
    csvrun::write $path $cases $outcomes
    catch {exec python3 -I [file join $::here oracle.py] check $path --all} report
    file delete -force $dir
    set fails {}
    foreach line [split $report \n] {
        if {[regexp {^FAIL \S+ (\S+): (.*)$} $line -> check message]} {
            lappend fails [list $check $message]
            if {$::options ne "" && [dict get $::options -show]} {
                puts "    $line"
            }
        }
    }
    return [list $invalid $fails]
}

# What the oracle's failures say: {GUARD SEMANTIC FINAL}.
proc census::Kinds {fails} {
    set guard 0
    set semantic 0
    set final 0
    foreach f $fails {
        lassign $f check message
        if {$check eq "expected" && [string match "guard:*" $message]} {
            incr guard
        } elseif {$check eq "expected" && [string match "final:*" $message]} {
            incr final
        } else {
            incr semantic
        }
    }
    return [list $guard $semantic $final]
}

proc census::Run {dir cases backend} {
    variable original
    set ::csvrun::csvDir $dir
    try {
        set results [csvrun::run $cases [list $backend]]
    } finally {
        set ::csvrun::csvDir $original
    }
    return [lindex $results 1]
}

proc census::RunExhaustive {dir length backend} {
    variable original
    set ::csvrun::csvDir $dir
    try {
        lassign [csvrun::exhaustive $length [list $backend]] cases results
    } finally {
        set ::csvrun::csvDir $original
    }
    return [list $cases [lindex $results 1]]
}

proc census::Mutant {mutant backend length} {
    variable original
    variable failures
    lassign $mutant name file expect class description blocks
    set dir [file join [file tempdir] csv]
    file mkdir $dir
    foreach path [glob -directory $original *.bot] {
        file copy -force $path [file join $dir [file tail $path]]
    }
    try {
        set text [Read [file join $dir $file]]
        foreach block $blocks {
            lassign $block old new
            set at [string first $old $text]
            if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
                out "| `$name` | $file | -- | -- | -- | -- | DOES NOT APPLY |"
                incr failures
                return
            }
            set at [string first $old $text]
            set text [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
        }
        Write [file join $dir $file] $text
        # 1. Static.
        set probe [file join $dir zz_census_probe.bot]
        Write $probe "import strict_emit\nimport utf8_emit\nimport selective_emit\nimport sources\n0\n"
        set rejected {}
        set kinds {}
        if {[catch {csvclaims::of $probe} claims]} {
            out "| `$name` | $file | does not compile: [lindex [split $claims \n] 0] | -- | -- | -- | FAIL |"
            incr failures
            return
        }
        foreach c $claims {
            lassign $c cfile fn recognizer verdict ks
            if {$verdict ne "proven"} {
                lappend rejected "$fn"
                lappend kinds {*}$ks
            }
        }
        file delete $probe
        set kinds [lsort -unique $kinds]
        set static [expr {$rejected eq {} ? "accepted" : "rejected"}]
        # 2. Runs, every claim removed (the same code: a claim is erased).
        foreach path [glob -directory $dir *.bot] {
            Write $path [emit::strip [Read $path]]
        }
        set ordinary [Ordinary]
        if {[catch {Run $dir $ordinary $backend} oOut]} {
            out "| `$name` | $file | [expr {$rejected eq {} ? "accepted" : "rejected: [join $kinds {, }]"}] | does not run: [lindex [split $oOut \n] 0] | -- | $class | NO |"
            incr failures
            return
        }
        lassign [Judge $ordinary $oOut] oInvalid oFails
        lassign [Kinds $oFails] oGuard oSemantic oFinal
        set adversarial [Adversarial]
        set aOut [Run $dir $adversarial $backend]
        lassign [RunExhaustive $dir $length $backend] eCases eOut
        lassign [Judge [concat $adversarial $eCases] [concat $aOut $eOut]] aInvalid aFails
        lassign [Kinds $aFails] aGuard aSemantic aFinal
        # 3. The class.
        if {$static eq "rejected"} {
            if {$oInvalid} {
                set found static
            } elseif {$aInvalid} {
                set found static-latent
            } elseif {$oSemantic + $aSemantic + $oGuard + $aGuard + $oFinal + $aFinal == 0} {
                set found unprovable
            } else {
                set found rejected-but-only-semantic
            }
        } elseif {$oInvalid || $aInvalid} {
            set found FALSE-PROOF
        } elseif {$oSemantic || $aSemantic} {
            set found semantic
        } elseif {$oGuard} {
            set found guard
        } elseif {$aGuard} {
            set found guard-latent
        } elseif {$oFinal || $aFinal} {
            set found outside
        } else {
            set found no-effect
        }
        set ok [expr {$found eq $class}]
        if {$expect eq "accepted"} {
            if {$static ne "accepted"} { set ok 0 }
        } else {
            foreach k [split $expect ,] {
                if {$k ni $kinds} { set ok 0 }
            }
        }
        if {!$ok} { incr failures }
        set runs "ordinary: $oInvalid invalid, [expr {$oSemantic}] wrong, $oGuard stopped; adversarial: $aInvalid invalid, $aSemantic wrong, $aGuard stopped"
        if {$oFinal + $aFinal} { append runs ", [expr {$oFinal + $aFinal}] wrong final values" }
        set staticText [expr {$static eq "accepted" ? "accepted" : "rejected: [join $kinds {, }] ([join [lsort -unique $rejected] {, }])"}]
        out "| `$name` | $file | $staticText | $runs | $found | $class | [expr {$ok ? "yes" : "NO"}] |"
    } finally {
        file delete -force [file dirname $dir]
    }
}

set mutants [census::Mutants [file join [file dirname $here] census mutants.txt]]
census::out "| mutant | file | compiler | runs (invalid traces, wrong outputs, guard stops) | class found | class stated | agrees |"
census::out "|---|---|---|---|---|---|---|"
set n 0
foreach m $mutants {
    if {[dict get $options -only] ne "" && [lindex $m 0] ni [dict get $options -only]} continue
    census::Mutant $m [dict get $options -backend] [dict get $options -length]
    incr n
}
census::out ""
census::out "$n mutants, [expr {$n - $census::failures}] as stated[expr {$census::failures ? ", $census::failures NOT" : ""}]."
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    fconfigure $f -encoding utf-8
    puts $f "# CSV emitters: the mutation census\n\n[join $census::lines \n]"
    close $f
}
exit [expr {$census::failures ? 1 : 0}]
