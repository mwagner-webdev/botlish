#!/usr/bin/env tclsh9.0
# probe.tcl -- COMPREHENSIVE-GENERATED-CODE-AUDIT.md's per-workload fact and
# code dump. Non-production inspection helper: it only calls existing
# hir::*/native::* entry points and the botlish-native CLI; it changes no
# compiler or runtime behavior.
#
#   tclsh9.0 audit/comprehensive-generated-code/tools/probe.tcl PROGRAM.{bot,ir} OUTDIR ?LOWER-OPTIONS...?
#
# LOWER-OPTIONS are native::lower::program options (e.g. -specialize 0,
# -tiny-leaf-inline-opt 0) applied to the NIR/asm/size/alloc outputs.
#
# Writes into OUTDIR:
#   completion.txt  every call/handle node the static completion proof
#                   (hir/completions.tcl) stamped: callee, declared errors,
#                   effectiveErrors, mayReturnNormally, resultRangeFact --
#                   i.e. the facts proven BEFORE specialization/lowering
#   spec.txt        hir::specialize instances: key types, generic flag,
#                   result type, and each instance's direct-call targets
#   params.txt      per used instance: each parameter's view type (what the
#                   instance's own region inference seeded it with) and the
#                   hir::range entry Range lowering consults
#   callfacts.txt   every reachable exact call: argument view types/ranges,
#                   successful-result type/range, chosen callee instance
#   nir.txt         native::nir text
#   asm.txt         objdump -dr of native::object (unlinked; runtime helpers
#                   are relocations)
#   roots.txt       native::roots (GC root/safepoint report per function)
#   effects.txt     botlish-native call-effects (per-call may_error/may_gc)
#   summary.txt     per NIR function: name/instance/regs/machine bytes and
#                   mechanically counted NIR ops (guards, calls, listget...);
#                   total bytes; allocation summary (native::allocationReport)

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

if {[llength $argv] < 2} {
    puts stderr "usage: probe.tcl PROGRAM.{bot,ir} OUTDIR ?LOWER-OPTIONS...?"
    exit 2
}
set argv [lassign $argv path outdir]
set lowerOptions $argv
file mkdir $outdir
interp recursionlimit {} 20000

proc W {outdir name content} {
    set f [open [file join $outdir $name] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
}

if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    set hir [native::buildProgramHir [core::loadProgramFile $path]]
}
set diagnostics [hir::diagnostics $hir]

proc Where {hir e} {
    if {[catch {hir::aot::Location $hir [hir::get $hir $e origin]} loc] || $loc eq ""
            || ![dict exists $loc file]} {
        return "?"
    }
    return "[file tail [dict get $loc file]]:[dict get $loc line]"
}

proc CalleeName {hir node} {
    lassign [dict get $node target] kind target
    switch -- $kind {
        block  { return [hir::aot::BlockName $hir $target] }
        native { return "native [dict get [hir::symbol $hir $target] name]" }
    }
    return "?$kind"
}

# ---------------------------------------------------------------------------
# completion.txt: facts proven by hir/completions.tcl, stamped on HIR nodes

set out "diagnostics: [llength $diagnostics]\n"
foreach d $diagnostics { append out "  $d\n" }
append out "\n"
foreach e [lsort -dictionary [dict keys [dict get $hir exprs]]] {
    set node [dict get $hir exprs $e]
    if {![dict exists $node effectiveErrors]} continue
    set kind [dict get $node kind]
    set callNode $node
    if {$kind eq "handle"} {
        set callNode [dict get $hir exprs [dict get $node call]]
    }
    set callee [CalleeName $hir $callNode]
    set declared {}
    lassign [dict get $callNode target] tk tt
    if {$tk eq "block"} { set declared [hir::get $hir $tt declaredErrors] }
    set rr [expr {[dict exists $node resultRangeFact] ? [hir::range::show [dict get $node resultRangeFact]] : "-"}]
    append out "$e ($kind) [Where $hir $e] -> $callee\n"
    append out "  declaredErrors={$declared} effectiveErrors={[dict get $node effectiveErrors]} mayReturnNormally=[dict get $node mayReturnNormally] resultRangeFact=$rr\n"
}
W $outdir completion.txt $out

# ---------------------------------------------------------------------------
# spec.txt / params.txt / callfacts.txt: what specialization and hir::range
# hand to native lowering

set specOpt [expr {[lsearch -exact $lowerOptions -specialize] >= 0
    ? [lindex $lowerOptions [expr {[lsearch -exact $lowerOptions -specialize] + 1}]] : 1}]
set spec [hir::specialize::analyze $hir -specialize $specOpt]
set ranges [hir::range::analyze $hir $spec]

set out {}
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    append out "$id [hir::specialize::label $spec $id]: generic=[dict get $inst generic] key={[lmap t [dict get $inst args] {hir::types::show $t}]} result=[hir::types::show [dict get $inst result]]\n"
    foreach {ce target} [dict get $inst calls] {
        append out "    call $ce [Where $hir $ce] -> $target [hir::specialize::label $spec $target]\n"
    }
    if {[dict get $inst values] ne ""} {
        append out "    materializes Block values: [dict get $inst values]\n"
    }
}
W $outdir spec.txt $out

set out {}
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set block [dict get $inst block]
    append out "$id [hir::specialize::label $spec $id]\n"
    if {$block eq "program"} continue
    set view [hir::specialize::view $hir $spec $id]
    set declaredTypes [hir::get $hir $block declaredParamTypes]
    set pr [dict get [dict get $ranges instances $id] params]
    foreach b [hir::get $hir $block params] r $pr d $declaredTypes {
        set name [dict get [hir::binding $hir $b] name]
        # The instance's own view type of the parameter, as seen by the
        # first reachable ref to it (region inference seeds it from the
        # instance key, not the declaration).
        set seen "-"
        foreach e [dict get [dict get $spec context] exprs $block] {
            if {[hir::kind $view $e] eq "ref" && [hir::get $view $e binding] eq $b} {
                set seen [hir::types::show [hir::typeOf $view $e]]
                break
            }
        }
        append out "    param $name: declared=[expr {$d eq {} ? {-} : [hir::types::show $d]}] first-ref-view-type=$seen entry-range=[hir::range::show $r]\n"
    }
    append out "    result range: [hir::range::show [dict get [dict get $ranges instances $id] result]]\n"
}
W $outdir params.txt $out

set out {}
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set view [hir::specialize::view $hir $spec $id]
    foreach {e target} [dict get $inst calls] {
        if {![hir::get $view $e reachable]} continue
        append out "[hir::specialize::label $spec $id] $e [Where $hir $e] -> [hir::specialize::label $spec $target]\n"
        set i 0
        foreach a [hir::get $view $e args] {
            append out "    arg$i: type [hir::types::show [hir::typeOf $view $a]], range [hir::range::show [hir::range::of $ranges $id $a]]\n"
            incr i
        }
        set node [dict get $hir exprs $e]
        set ee [expr {[dict exists $node effectiveErrors] ? "{[dict get $node effectiveErrors]}" : "(not stamped)"}]
        append out "    result: type [hir::types::show [hir::typeOf $view $e]], range [hir::range::show [hir::range::of $ranges $id $e]]; semantic effectiveErrors $ee\n"
    }
}
W $outdir callfacts.txt $out

# ---------------------------------------------------------------------------
# NIR, asm, roots, effects, sizes, allocations

set lowered [native::lower::program $hir {*}$lowerOptions]
set nirText [dict get $lowered text]
W $outdir nir.txt $nirText

set funcs [dict create]
set current ""
foreach line [split $nirText \n] {
    if {[regexp {^func (\d+) "([^"]*)" params=(\d+) env=(\d+) regs=(\d+) .*?instance="([^"]*)"} $line -> id name np envFlag regs inst]} {
        set current $id
        dict set funcs $id [dict create name $name instance $inst regs $regs params $np env $envFlag counts [dict create]]
        continue
    }
    if {$line eq "end"} { set current ""; continue }
    if {$current eq ""} continue
    set l [string trim $line]
    set key ""
    if {[regexp {^guard(bool)? } $l]} { set key guard }
    if {[regexp {= op (\w+)} $l -> op]} { set key "op:$op" }
    if {[regexp {= (call|callenv|callvalue|callmulti|callenvmulti) } $l -> c]} { set key $c }
    if {[regexp {^(tail|tailenv|fail|reraise|pusherrorexit|poperrorexit|raise|unreachable|cleardeclarederror) ?} $l -> k]} { set key $k }
    if {[regexp {= declarederroreq } $l]} { set key declarederroreq }
    if {[regexp {= (closure|capture|cell|cellget|cellcheck|fnvalue) ?} $l -> k]} { set key $k }
    if {[regexp {^br } $l]} { set key br }
    if {$key ne ""} {
        set counts [dict get $funcs $current counts]
        dict incr counts $key
        dict set funcs $current counts $counts
    }
}

set objPath [file join $outdir program.o]
if {[catch {native::object $hir $objPath {*}$lowerOptions} err]} {
    W $outdir asm.txt "ERROR: $err\n"
} else {
    set pipe [open |[list objdump -dr --no-show-raw-insn -M intel $objPath] r]
    set asm [read $pipe]
    close $pipe
    set asm [string map [list $objPath program.o] $asm]
    set labelled {}
    foreach line [split $asm \n] {
        if {[regexp {^([0-9a-f]+) <botlish_(fn|entry)_(\d+)>:$} $line -> addr kind id] && [dict exists $funcs $id]} {
            append labelled "$line  ;; [dict get $funcs $id name]<[dict get $funcs $id instance]>\n"
        } else {
            append labelled "$line\n"
        }
    }
    W $outdir asm.txt $labelled
    file delete -force $objPath
}

if {[catch {native::roots $hir {*}$lowerOptions} rootsText]} { set rootsText "ERROR: $rootsText" }
W $outdir roots.txt $rootsText

set effectsText ""
catch {set effectsText [join [native::Driver calls $nirText] \n]}
W $outdir effects.txt $effectsText

if {[catch {native::codeSize $hir {*}$lowerOptions} size]} { set size {? {}} }
lassign $size total perFunction

set alloc ""
if {[catch {native::allocationReport $hir sites 1 {*}$lowerOptions} report]} {
    set alloc "ERROR: $report"
} else {
    set t [dict get $report total]
    set alloc "allocations=[dict get $t allocations] bytes=[dict get $t allocatedBytes]"
    foreach kind {String List MutableArray BigInt Result Block Cell Native} {
        set k [dict get $report byKind $kind]
        if {[dict get $k allocations]} { append alloc " $kind=[dict get $k allocations]" }
    }
    set static [dict get $report static]
    append alloc " static=[dict get $static allocations]"
    append alloc "\n  sites:"
    foreach s [dict get $report sites] {
        set loc [dict get $s location]
        set where [expr {[dict exists $loc file] ? "[file tail [dict get $loc file]]:[dict get $loc line]" : "func [dict get $s func]"}]
        append alloc "\n    $where [dict get $s operation] x[dict get $s allocations]"
    }
}

set out "source: $path\nlower options: $lowerOptions\nstatic diagnostics: [llength $diagnostics]\n"
append out "NIR functions: [dict size $funcs]; machine code bytes: $total\n"
append out "allocation (one run): $alloc\n\n"
set i 0
foreach id [lsort -integer [dict keys $funcs]] {
    set f [dict get $funcs $id]
    set bytes [lindex $perFunction $i]
    incr i
    append out [format "%3d %-40s regs=%-3s params=%s env=%s bytes=%-5s %s\n" $id \
        "[dict get $f name]<[dict get $f instance]>" [dict get $f regs] [dict get $f params] [dict get $f env] $bytes \
        [join [lmap {k v} [dict get $f counts] {list $k=$v}] { }]]
}
W $outdir summary.txt $out
puts "wrote $outdir ($total bytes, [dict size $funcs] functions)"
