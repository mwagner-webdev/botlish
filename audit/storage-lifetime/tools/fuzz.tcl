# fuzz.tcl -- hir/lifetime.tcl against its independent oracle
# (STORAGE-LIFETIME-FACTS-MILESTONE-1.md, "Independent oracle").
#
#   tclsh9.0 audit/storage-lifetime/tools/fuzz.tcl ?-seeds 1-5? ?-count 40?
#       ?-strings 0|1? ?-keep DIR?
#
# For each seed, audit/storage-lifetime/tools/oracle.py writes COUNT
# programs and the facts its own model predicts (no compiler code: the
# model is the generator's statement language's). This harness compiles
# each program, runs hir::lifetime::analyze and compares, per program:
#
#   * every yield of `worker`: the bindings and fold positions the analysis
#     says are live across it must include the oracle's (a missing one is
#     UNSOUND: a value needed after the resume, called dead); one more is
#     imprecision, counted;
#   * every producer of `worker` and `make`, per region (activation, each
#     enclosing fold's iteration, segment): the analysis may say
#     `confined` only where the oracle does (confined where the oracle
#     says escapes is UNSOUND); escapes or unknown where the oracle says
#     confined is imprecision, counted.
#
# With -strings 0 the programs hold Ints only (the C backend compiles them)
# and the C differential (persist.tcl) runs over them too. Exit status 1 on
# any unsound result, any program that does not compile, or any C
# violation. The programs are deleted unless -keep DIR names where to put
# them.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -seeds 1-5 -count 40 -strings 1 -keep ""]
foreach {k v} $argv {
    if {![dict exists $options $k]} {
        error "unknown option $k"
    }
    dict set options $k $v
}
set argv {}
source [file join $root surface surface.tcl]
source [file join $root lsp json.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

proc Plain {value} {
    lassign $value type payload
    switch -- $type {
        obj {
            set result [dict create]
            foreach {k v} $payload {
                dict set result $k [Plain $v]
            }
            return $result
        }
        arr { return [lmap v $payload {Plain $v}] }
        default { return $payload }
    }
}

proc Seeds {spec} {
    if {[regexp {^(\d+)-(\d+)$} $spec -> a b]} {
        set result {}
        for {set i $a} {$i <= $b} {incr i} {
            lappend result $i
        }
        return $result
    }
    return [split $spec ,]
}

proc Line {hir e} {
    set origin [dict get $hir exprs $e origin]
    return [dict getdef $origin line 0]
}

# The unit of FACTS for the function NAME (its first instance).
proc UnitOf {facts name} {
    foreach id [hir::lifetime::units $facts] {
        if {[string match "$name<*" [dict get $facts units $id label]]} {
            return $id
        }
    }
    return ""
}

set dir [dict get $options -keep]
if {$dir eq ""} {
    set dir [file tempdir]
    set cleanup 1
} else {
    file mkdir $dir
    set cleanup 0
}
set totals [dict create programs 0 invalid 0 suspensions 0 unsound 0 livePrecise 0 liveExtra 0 \
    verdicts 0 verdictPrecise 0 verdictImprecise 0 missingProducer 0]
set failures {}
foreach seed [Seeds [dict get $options -seeds]] {
    set strings [dict get $options -strings]
    exec python3 -I [file join $here oracle.py] generate $seed [dict get $options -count] $dir --strings $strings
    for {set k 0} {$k < [dict get $options -count]} {incr k} {
        set name g${seed}_$k
        set file [file join $dir $name.bot]
        set f [open [file join $dir $name.json] r]
        set expected [Plain [lsp::json::parse [read $f]]]
        close $f
        dict incr totals programs
        if {[catch {surface::readProgramFile $file -warnings off} hir]} {
            dict incr totals invalid
            lappend failures "$name: does not compile: [lindex [split $hir \n] 0]"
            continue
        }
        set facts [hir::lifetime::analyze $hir]
        # Suspensions of worker.
        set w [UnitOf $facts worker]
        set wu [hir::lifetime::unit $facts $w]
        set byLine [dict create]
        foreach s [dict get $wu suspensions] {
            if {[dict get $s kind] ne "yield"} continue
            set live {}
            foreach v [dict get $s bindings] {
                lappend live [hir::semantic::SourceName $hir [string range $v 2 end]]
            }
            foreach v [dict get $s positions] {
                lappend live pos@[Line $hir [string range $v 2 end]]
            }
            dict set byLine [Line $hir [dict get $s expr]] [lsort $live]
        }
        foreach s [dict get $expected suspensions] {
            dict incr totals suspensions
            set line [dict get $s line]
            set want [lsort [dict get $s live]]
            if {![dict exists $byLine $line]} {
                dict incr totals unsound
                lappend failures "$name:$line: the oracle's yield has no suspension in the analysis"
                continue
            }
            set got [dict get $byLine $line]
            set missing [lmap x $want {if {$x in $got} continue; set x}]
            set extra [lmap x $got {if {$x in $want} continue; set x}]
            if {$missing ne {}} {
                dict incr totals unsound
                lappend failures "$name:$line: UNSOUND: live across the yield but not in the analysis: $missing (oracle $want, analysis $got)"
            } elseif {$extra ne {}} {
                dict incr totals liveExtra
            } else {
                dict incr totals livePrecise
            }
        }
        # Producers of worker and make.
        dict for {fn list} [dict get $expected producers] {
            set id [UnitOf $facts $fn]
            if {$id eq ""} {
                if {$list ne {}} {
                    lappend failures "$name: no unit for $fn"
                    dict incr totals unsound
                }
                continue
            }
            set u [hir::lifetime::unit $facts $id]
            foreach p $list {
                set line [dict get $p line]
                set kind [dict get $p kind]
                set site ""
                dict for {s info} [dict get $u producers] {
                    if {[Line $hir [dict get $info expr]] == $line && [dict get $info kind] eq $kind} {
                        set site $s
                        break
                    }
                }
                if {$site eq ""} {
                    dict incr totals missingProducer
                    dict incr totals unsound
                    lappend failures "$name:$line: the oracle's $kind producer of $fn is not one of the analysis's"
                    continue
                }
                dict for {region want} [dict get $p verdicts] {
                    dict incr totals verdicts
                    set key $region
                    if {[string match iteration@* $region]} {
                        set key ""
                        foreach r [dict keys [dict get $u verdicts $site]] {
                            if {[lindex $r 0] eq "iteration" && "iteration@[Line $hir [lindex $r 1]]" eq $region} {
                                set key $r
                            }
                        }
                    }
                    if {$key eq "" || ![dict exists $u verdicts $site $key]} {
                        dict incr totals unsound
                        lappend failures "$name:$line: $fn's $kind producer has no verdict for $region"
                        continue
                    }
                    set got [dict get $u verdicts $site $key verdict]
                    if {$got eq "confined" && $want eq "escapes"} {
                        dict incr totals unsound
                        lappend failures "$name:$line: UNSOUND: $fn's $kind producer is confined to $region by the analysis, escapes by the oracle"
                    } elseif {$got eq $want} {
                        dict incr totals verdictPrecise
                    } else {
                        dict incr totals verdictImprecise
                        if {[info exists ::env(BOTLISH_LIFETIME_FUZZ_VERBOSE)]} {
                            puts "$name:$line: imprecise: $fn's $kind producer: $region oracle $want, analysis $got"
                        }
                    }
                }
            }
        }
    }
}
set cviolations 0
if {![dict get $options -strings]} {
    set files [glob -directory $dir *.bot]
    if {[catch {exec tclsh9.0 [file join $here persist.tcl] -quiet 1 {*}$files} out]} {
        set cviolations 1
        lappend failures "C differential: [lindex [split $out \n] end]"
        foreach line [split $out \n] {
            if {[string match *VIOLATION* $line]} {
                lappend failures $line
            }
        }
    }
    puts "C differential: [lindex [split $out \n] end]"
}
if {$cleanup} {
    file delete -force $dir
}
foreach f $failures {
    puts $f
}
puts [join [lmap {k v} $totals {string cat "$k $v"}] ", "]
exit [expr {[dict get $totals unsound] > 0 || [dict get $totals invalid] > 0 || $cviolations}]
