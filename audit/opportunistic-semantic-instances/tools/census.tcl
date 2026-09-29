#!/usr/bin/env tclsh9.0
# census.tcl -- the semantic-instance census of the frozen canonical corpus
# (bench/*.bot and examples/stdlib/*.bot: the 17 programs), and its
# relationship to codegen instances. Observation only: it runs against
# whatever tree it is started in (pwd is the root).
#
#   (cd TREE && tclsh9.0 audit/opportunistic-semantic-instances/tools/census.tcl OUTFILE [-off])
#
# Two HIRs per program, both built the way the pipelines build them:
#   * the surface HIR (surface::readProgramFile -strict 0): validity, results;
#   * the relifted native HIR (native::buildProgramHir of hir::lower of it),
#     the one hir::specialize and native/lower.tcl compile: codegen mapping.
#
# Sections per program: every used semantic instance (function, entry types,
# result, status, the program's own calls that use it), the codegen instance
# (hir::specialize::KeyType projection) it maps to and whether that
# instance is emitted as a function in the lowered NIR. Totals at the end.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outfile flag
if {$flag eq "-off"} {
    set hir::semantic::enabled 0
}

set programs [concat \
    [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]

proc typeList {hir types} {
    join [lmap t $types {hir::semantic::ShowType $hir $t}] {, }
}

# Strongly connected components (as a list of instance-id lists with more
# than one member or a self edge) of the instance call graph.
proc cyclic {edges ids} {
    # Tarjan
    set index 0
    set stack {}
    array set idx {}
    array set low {}
    array set on {}
    set result {}
    proc visit {v} {
        upvar edges edges idx idx low low on on stack stack index index result result
        set idx($v) $index
        set low($v) $index
        incr index
        lappend stack $v
        set on($v) 1
        if {[dict exists $edges $v]} {
            foreach w [dict get $edges $v] {
                if {![info exists idx($w)]} {
                    visit $w
                    if {$low($w) < $low($v)} { set low($v) $low($w) }
                } elseif {$on($w) && $idx($w) < $low($v)} {
                    set low($v) $idx($w)
                }
            }
        }
        if {$low($v) == $idx($v)} {
            set comp {}
            while 1 {
                set w [lindex $stack end]
                set stack [lrange $stack 0 end-1]
                set on($w) 0
                lappend comp $w
                if {$w eq $v} break
            }
            if {[llength $comp] > 1 || ($v in [expr {[dict exists $edges $v] ? [dict get $edges $v] : {}}])} {
                lappend result $comp
            }
        }
    }
    foreach v $ids {
        if {![info exists idx($v)]} { visit $v }
    }
    return $result
}

set L {}
array set T {}
foreach k {programs requests trivial hits walks rounds unique used valid invalid analyzed declined \
        recursive multi maxPer instancesWithCodegen shared inlined newCode declinedNoEnv declinedBudget codegenUsed codegenEmitted stateBytes maxPasses noSite sharedCodegen} {
    set T($k) 0
}
set perFunction {}
foreach path $programs {
    set name [file tail $path]
    set surfaceHir [surface::readProgramFile $path -strict 0]
    set nativeHir [native::buildProgramHir [hir::lower $surfaceHir]]
    incr T(programs)
    lappend L "" "== $name"
    foreach {label h} [list surface $surfaceHir native $nativeHir] {
        if {![dict exists $h semantic]} { continue }
        set s [dict get $h semantic]
        if {$label eq "surface"} {
            set rows [hir::semantic::census $h]
            foreach k {requests trivial hits walks} { incr T($k) [dict get $s $k] }
            incr T(rounds) [dict get $s rounds]
            incr T(unique) [dict size [dict get $s instances]]
            # Size of the retained analysis state: the text length of the
            # instance table (snapshots included), keys, calls and
            # environments -- never a cloned HIR.
            incr T(stateBytes) [expr {[string length [dict get $s instances]] + [string length [dict get $s keys]] \
                + [string length [dict get $s calls]] + [string length [dict get $s envs]]}]
            incr T(used) [llength $rows]
            dict for {reason n} [dict get $s declinedCount] {
                incr T(declined) $n
                if {$reason eq "no-env"} { incr T(declinedNoEnv) $n } else { incr T(declinedBudget) $n }
            }
            set byBlock [dict create]
            set edges [dict create]
            foreach row $rows {
                incr T([dict get $row status])
                if {[dict get $row passes] > $T(maxPasses)} { set T(maxPasses) [dict get $row passes] }
                dict lappend byBlock [dict get $row block] [dict get $row id]
                lappend L [format "  %s<%s> -> %s  \[%s\]  passes=%d  program-calls=%d" \
                    [dict get $row name] [typeList $h [dict get $row args]] \
                    [hir::semantic::ShowType $h [dict get $row result]] [dict get $row status] \
                    [dict get $row passes] \
                    [llength [lmap c [dict get $row calls] {expr {[lindex $c 0] eq "generic" ? $c : [continue]}}]]]
            }
            dict for {key callee} [dict get $s calls] {
                lassign $key caller e
                if {$caller ne "generic"} { dict lappend edges $caller $callee }
            }
            set cyc [cyclic $edges [lmap r $rows {dict get $r id}]]
            set members [lsort -unique [concat {*}$cyc]]
            incr T(recursive) [llength $members]
            if {$members ne {}} {
                lappend L "  recursive/SCC participants: [join $members { }]"
            }
            dict for {block ids} $byBlock {
                if {[llength $ids] > 1} {
                    incr T(multi)
                    lappend perFunction [list $name [hir::signatures::Name $h $block] [llength $ids]]
                }
                if {[llength $ids] > $T(maxPer)} { set T(maxPer) [llength $ids] }
            }
        } else {
            # Codegen relationship on the relifted HIR. A semantic instance
            # has no codegen identity of its own: it runs through the codegen
            # instance that hir::specialize chose for the CALLS that
            # requested it (specialize records call ExprId -> callee
            # instance). That instance is emitted iff the lowered NIR has a
            # function for it; otherwise its calls were inlined away or the
            # instance is not used by codegen at all.
            set spec [hir::specialize::analyze $nativeHir]
            set nir [dict get [native::lower::program $nativeHir] text]
            set emitted [dict create]
            set funcs 0
            foreach line [split $nir \n] {
                if {[regexp {^func \d+ "([^"]*)" .* instance="([^"]*)"} $line -> fname inst]} {
                    dict set emitted "$fname<$inst>" 1
                    incr funcs
                }
            }
            set targets [dict create]
            foreach id [dict get $spec used] {
                dict for {e target} [dict get [dict get $spec instances $id] calls] {
                    dict lappend targets $e $target
                }
            }
            set rows [hir::semantic::census $h]
            lappend L "  -- codegen relationship ([llength [dict get $spec used]] used codegen instances, $funcs emitted functions)"
            set mapped [dict create]
            foreach row $rows {
                set labels {}
                foreach key [dict get $row calls] {
                    lassign $key caller e
                    if {[dict exists $targets $e]} {
                        foreach t [dict get $targets $e] {
                            set lab [hir::specialize::label $spec $t]
                            if {$lab ni $labels} { lappend labels $lab }
                        }
                    }
                }
                # A block called only from another semantic instance's body
                # is reached through that caller's calls as well (same table).
                if {$labels eq {}} {
                    set cg "none (no used codegen call site: caller unused by codegen, or call folded away)"
                    incr T(noSite)
                } else {
                    set emit {}
                    foreach lab $labels { if {[dict exists $emitted $lab]} { lappend emit $lab } }
                    if {$emit eq {}} {
                        set cg "[join $labels { | }] (not emitted: inlined)"
                        incr T(inlined)
                    } else {
                        set cg [join $emit { | }]
                        foreach lab $emit { dict lappend mapped $lab [dict get $row id] }
                    }
                }
                lappend L [format "     %s<%s> => %s" [dict get $row name] [typeList $h [dict get $row args]] $cg]
            }
            dict for {cg ids} $mapped {
                incr T(instancesWithCodegen)
                if {[llength $ids] > 1} { incr T(shared) [llength $ids]; incr T(sharedCodegen) }
            }
            incr T(codegenUsed) [llength [dict get $spec used]]
            incr T(codegenEmitted) $funcs
        }
    }
}
lappend L "" "# totals over $T(programs) programs"
foreach k {requests trivial hits walks rounds unique used valid invalid analyzed declined declinedNoEnv declinedBudget recursive multi maxPer maxPasses instancesWithCodegen shared sharedCodegen inlined noSite codegenUsed codegenEmitted stateBytes} {
    lappend L [format "#   %-24s %d" $k $T($k)]
}
lappend L "# functions with more than one semantic instance:"
foreach f $perFunction { lappend L "#   [join $f { }]" }
set f [open $outfile w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $outfile"
