# callgraph.tcl -- the mid-end's procedure call graph and its strongly
# connected components (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md,
# section 5): which procedures a port would have to write as mutually
# recursive groups, and which procedures a front-end build and native
# lowering actually run.
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/callgraph.tcl OUTDIR
#       -frontend "FILE.bot ..." ?-native "FILE.bot ..."?
#
# Two graphs over the procedures of ::hir (and, as callees only, ::core,
# ::surface):
#
# * static: an edge P -> Q when Q's name appears in P's body at a command
#   position (after a newline, `;`, `[` or `{`, or as the first word after
#   `tailcall` or `[list`), resolved as Tcl resolves a command name in P's
#   namespace (NS::NAME, then ::NAME). An over-approximation: a word after
#   `{` in a data list, or a callback built otherwise, may be miscounted
#   either way.
# * dynamic: an edge P -> Q when a call of Q ran while P was the innermost
#   active ::hir procedure, recorded by a counting wrapper around every
#   ::hir and ::core procedure (timing.tcl's renaming, no execution trace)
#   while the -frontend programs are compiled (surface::readProgramFile) and
#   the -native programs lowered to NIR (native::nir, specialized). An
#   under-approximation: only paths those programs exercise.
#
# Writes OUTDIR/procs.tsv (one row per ::hir procedure: name, file, body
# lines, frontend calls, native calls, static SCC id and size, dynamic SCC
# id and size), OUTDIR/sccs.txt (every SCC of more than one procedure or a
# self-loop, both graphs, members by file) and OUTDIR/summary.txt.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname [file dirname $here]]]]
set out [file normalize [lindex $argv 0]]
set options [dict create -frontend {} -native {}]
foreach {option value} [lrange $argv 1 end] {
    if {![dict exists $options $option]} { error "callgraph.tcl: unknown option $option" }
    dict set options $option $value
}
file mkdir $out
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]

# Warm: load whatever a compilation loads lazily before enumerating.
set scratch [file tempdir callgraph]
set warm [file join $scratch warm.bot]
set channel [open $warm w]; puts $channel "x = 1\nx"; close $channel
surface::readProgramFile $warm -warnings off -cache ""
native::nir [surface::readProgramFile $warm -warnings off -cache ""]

proc allNamespaces {ns} {
    set result [list $ns]
    foreach child [namespace children $ns] {
        lappend result {*}[allNamespaces $child]
    }
    return $result
}
proc procsUnder {root} {
    set result {}
    foreach ns [allNamespaces $root] {
        foreach p [info procs ${ns}::*] {
            lappend result [namespace which -command $p]
        }
    }
    return [lsort $result]
}
set hirProcs [procsUnder ::hir]
set calleeProcs [concat $hirProcs [procsUnder ::core] [procsUnder ::surface]]
set known [dict create]
foreach p $calleeProcs { dict set known $p 1 }

# File of each ::hir procedure: every one is defined at a file's top level as
# `proc hir::NS::NAME {`.
set fileOf [dict create]
foreach file [glob -directory [file join $checkout hir] *.tcl] {
    set channel [open $file]; set text [read $channel]; close $channel
    foreach {- name} [regexp -all -inline -line {^proc\s+(\S+)\s} $text] {
        dict set fileOf ::[string trimleft $name :] [file tail $file]
    }
}

# ---- static graph
proc resolve {ns word} {
    if {[string match ::* $word]} {
        set candidates [list $word]
    } else {
        set candidates [list ${ns}::$word ::$word]
    }
    foreach c $candidates {
        if {[dict exists $::known $c]} { return $c }
    }
    return ""
}
set static [dict create]
foreach p $hirProcs {
    set ns [namespace qualifiers $p]
    set body [info body $p]
    set callees [dict create]
    foreach {- word} [regexp -all -inline {(?:^|[\n;\[\{]|tailcall\s+|\[list\s+)\s*([A-Za-z_:][A-Za-z0-9_:]*)} $body] {
        set q [resolve $ns $word]
        if {$q ne ""} { dict set callees $q 1 }
    }
    dict set static $p [dict keys $callees]
}

# ---- dynamic graph
namespace eval cg {
    variable stack {}
    variable edges [dict create]
    variable calls [dict create]
    variable phase frontend
}
proc cg::wrap {procs} {
    foreach p $procs {
        set original ${p}__cg
        rename $p $original
        # Every completion code passes through unchanged (a procedure may
        # return -code continue or break to its caller's loop).
        proc $p args [string map [list @P@ [list $p] @O@ [list $original]] {
            ::cg::Enter @P@
            set code [catch {uplevel 1 [list @O@ {*}$args]} result options]
            set ::cg::stack [lrange $::cg::stack 0 end-1]
            dict incr options -level
            return -options $options $result
        }]
    }
}
proc cg::Enter {p} {
    variable stack
    variable edges
    variable calls
    variable phase
    dict incr calls [list $phase $p]
    set caller [lindex $stack end]
    if {$caller ne ""} {
        dict incr edges [list $caller $p]
    }
    if {[string match ::hir::* $p]} {
        lappend stack $p
    } else {
        lappend stack [lindex $stack end]
    }
}
# Wrap only the procedures the census needs; core's and surface's are
# callees (their outgoing edges are not recorded: the stack keeps the hir
# caller across them).
cg::wrap [concat $hirProcs [procsUnder ::core]]

set failures {}
foreach file [dict get $options -frontend] {
    set cg::phase frontend
    if {[catch {surface::readProgramFile [file normalize $file] -warnings default -warning-channel "" -cache ""} message]} {
        lappend failures [list frontend $file [lindex [split $message \n] 0]]
    }
}
foreach file [dict get $options -native] {
    set cg::phase frontend
    if {[catch {surface::readProgramFile [file normalize $file] -warnings off -cache ""} hir]} {
        lappend failures [list native-frontend $file [lindex [split $hir \n] 0]]
        continue
    }
    set cg::phase native
    if {[catch {native::nir $hir} message]} {
        lappend failures [list native $file [lindex [split $message \n] 0]]
    }
}
set dynamic [dict create]
foreach p $hirProcs { dict set dynamic $p {} }
dict for {edge n} $cg::edges {
    lassign $edge from to
    if {[dict exists $dynamic $from]} {
        dict lappend dynamic $from $to
    }
}

# ---- Tarjan's SCCs, iterative (the graph is deep), over GRAPH restricted to
# the nodes NODES.
proc sccs {graph nodes} {
    set inSet [dict create]
    foreach n $nodes { dict set inSet $n 1 }
    set index 0
    set idx [dict create]; set low [dict create]; set onStack [dict create]
    set stack {}; set result {}
    foreach root $nodes {
        if {[dict exists $idx $root]} continue
        set work [list [list $root 0]]
        while {[llength $work]} {
            lassign [lindex $work end] v i
            if {$i == 0} {
                dict set idx $v $index; dict set low $v $index; incr index
                lappend stack $v; dict set onStack $v 1
            }
            set succ [lsearch -all -inline -not -exact [lsort -unique [dict getdef $graph $v {}]] ""]
            set succ [lmap s $succ { expr {[dict exists $inSet $s] ? $s : [continue]} }]
            if {$i < [llength $succ]} {
                lset work end 1 [expr {$i + 1}]
                set w [lindex $succ $i]
                if {![dict exists $idx $w]} {
                    lappend work [list $w 0]
                } elseif {[dict exists $onStack $w]} {
                    dict set low $v [expr {min([dict get $low $v], [dict get $idx $w])}]
                }
                continue
            }
            set work [lrange $work 0 end-1]
            if {[llength $work]} {
                set parent [lindex $work end 0]
                dict set low $parent [expr {min([dict get $low $parent], [dict get $low $v])}]
            }
            if {[dict get $low $v] == [dict get $idx $v]} {
                set comp {}
                while 1 {
                    set w [lindex $stack end]; set stack [lrange $stack 0 end-1]
                    dict unset onStack $w
                    lappend comp $w
                    if {$w eq $v} break
                }
                lappend result $comp
            }
        }
    }
    return $result
}

proc componentTable {graph nodes} {
    set table [dict create]
    set id 0
    foreach comp [lsort -command {apply {{a b} {expr {[llength $b] - [llength $a]}}}} [sccs $graph $nodes]] {
        incr id
        foreach n $comp { dict set table $n [list $id [llength $comp]] }
    }
    return $table
}

set frontendProcs {}
set nativeProcs {}
dict for {key n} $cg::calls {
    lassign $key phase p
    if {![string match ::hir::* $p]} continue
    if {$phase eq "frontend"} { lappend frontendProcs $p } else { lappend nativeProcs $p }
}
set frontendProcs [lsort -unique $frontendProcs]
set nativeProcs [lsort -unique $nativeProcs]

set staticAll [componentTable $static $hirProcs]
set staticFront [componentTable $static $frontendProcs]
set dynFront [componentTable $dynamic $frontendProcs]

set channel [open [file join $out procs.tsv] w]
puts $channel "proc\tfile\tbodyLines\tfrontendCalls\tnativeCalls\tstaticScc\tstaticSccSize\tstaticFrontendScc\tstaticFrontendSccSize\tdynamicScc\tdynamicSccSize"
foreach p $hirProcs {
    set lines [llength [split [info body ${p}__cg] \n]]
    lassign [dict getdef $staticAll $p {- 1}] sa san
    lassign [dict getdef $staticFront $p {- 0}] sf sfn
    lassign [dict getdef $dynFront $p {- 0}] df dfn
    puts $channel [join [list [string range $p 2 end] [dict getdef $fileOf $p ?] $lines \
        [dict getdef $cg::calls [list frontend $p] 0] [dict getdef $cg::calls [list native $p] 0] \
        $sa $san $sf $sfn $df $dfn] \t]
}
close $channel

proc selfLoop {graph p} { expr {$p in [dict getdef $graph $p {}]} }
proc describe {channel title graph table} {
    puts $channel "== $title"
    set byId [dict create]
    dict for {p entry} $table { dict lappend byId [lindex $entry 0] $p }
    set nontrivial 0; set inCycles 0; set selfOnly 0
    dict for {id members} $byId {
        if {[llength $members] > 1} {
            incr nontrivial; incr inCycles [llength $members]
            set files [dict create]
            foreach m $members { dict lappend files [dict getdef $::fileOf $m ?] [namespace tail $m] }
            puts $channel "scc $id: [llength $members] procedures"
            dict for {f ms} $files {
                puts $channel "    $f ([llength $ms]): [join [lsort $ms] { }]"
            }
        } elseif {[selfLoop $graph [lindex $members 0]]} {
            incr selfOnly
        }
    }
    puts $channel "-- $title: [dict size $table] procedures, $nontrivial SCCs of 2 or more holding $inCycles procedures, $selfOnly further self-recursive procedures"
    return [list $nontrivial $inCycles $selfOnly]
}
set channel [open [file join $out sccs.txt] w]
set sAll [describe $channel "static, every ::hir procedure" $static $staticAll]
set sFront [describe $channel "static, the procedures a front-end build ran" $static $staticFront]
set dFront [describe $channel "dynamic, the procedures a front-end build ran" $dynamic $dynFront]
close $channel

# Core and surface procedures the mid-end calls (dynamic, front end), by
# namespace.
set coreCalls [dict create]
set coreSites [dict create]
dict for {edge n} $cg::edges {
    lassign $edge from to
    if {[string match ::hir::* $to]} continue
    set ns [namespace qualifiers $to]
    dict incr coreCalls $ns $n
    dict set coreSites $ns $to 1
}

set channel [open [file join $out summary.txt] w]
puts $channel "hir procedures: [llength $hirProcs]"
puts $channel "ran in a front-end build: [llength $frontendProcs]"
puts $channel "ran in native lowering: [llength $nativeProcs]"
puts $channel "ran in both: [llength [lmap p $frontendProcs { expr {$p in $nativeProcs ? $p : [continue]} }]]"
puts $channel "ran in native lowering only: [llength [lmap p $nativeProcs { expr {$p ni $frontendProcs ? $p : [continue]} }]]"
puts $channel "static, all hir: SCCs>=2 [lindex $sAll 0], procedures in them [lindex $sAll 1], self-recursive only [lindex $sAll 2]"
puts $channel "static, front-end procedures: SCCs>=2 [lindex $sFront 0], procedures in them [lindex $sFront 1], self-recursive only [lindex $sFront 2]"
puts $channel "dynamic, front-end procedures: SCCs>=2 [lindex $dFront 0], procedures in them [lindex $dFront 1], self-recursive only [lindex $dFront 2]"
puts $channel "core/surface procedures the mid-end called (dynamic, both phases), by namespace: distinct procedures, calls"
foreach ns [lsort [dict keys $coreCalls]] {
    puts $channel "    $ns [dict size [dict get $coreSites $ns]] [dict get $coreCalls $ns]"
}
puts $channel "failures: [llength $failures]"
foreach f $failures { puts $channel "    $f" }
close $channel
file delete -force $scratch
puts "callgraph.tcl: wrote $out"
