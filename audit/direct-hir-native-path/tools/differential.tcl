#!/usr/bin/env tclsh9.0
# differential.tcl -- one native pipeline's full observable output for a set
# of programs, written to files so two pipelines (or two trees) can be diffed.
# Observation only. Runs against the tree named by -root (default: the tree
# this file lives in).
#
#   tclsh9.0 differential.tcl [-root TREE] -mode relift|direct -out DIR FILE.bot
#
# One process per program (differential.sh does the loop): native::lower's
# module-static slot table used to leak across compilations in one process
# (fixed in this milestone), so a shared process makes NIR depend on history.
#
#   -mode relift   the pre-milestone production route:
#                    surface HIR -> hir::lower -> native::buildProgramHir -> NIR
#                  (only exists in trees that still have native::buildProgramHir,
#                  i.e. the parent of the direct-HIR milestone; run it with -root)
#   -mode direct   the milestone's production route:
#                    surface HIR -> NIR                (native::nir / native::object)
#                  where the HIR is first made native-ready by native::prepareHir
#                  (a no-op unless the program calls a native with a module
#                  implementation or native body); the semantic/AOT numbers are
#                  those of the prepared HIR, i.e. what is actually compiled.
#
# Per program P it writes DIR/P.nir (the full NIR text), DIR/P.canon (the NIR
# canonicalized: @eN tags dropped, function ids replaced by function name and
# instance, function bodies sorted), DIR/P.asm (objdump of the unlinked
# object, function symbols relabeled) and one line of DIR/summary.txt:
#
#   semantic requests/trivial/hits/instances/used/walks/rounds/recursive
#   codegen used instances, AOT closed/guarded/open
#   NIR functions, lines, guards, call/callvalue counts, code bytes,
#   canonical/asm digests
#
# The "semantic" numbers are always those of the HIR the pipeline compiles
# (for -mode relift that is the relifted HIR's own analysis, for -mode direct
# the front end's), so they show whether the round trip re-ran the analysis.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set mode direct
set out ""
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -mode { set mode [lindex $argv [incr i]] }
        -out  { set out [file normalize [lindex $argv [incr i]]] }
        default { lappend files [lindex $argv $i] }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
file mkdir $out

proc W {path content} {
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
}

proc Digest {text} {
    binary scan [encoding convertto utf-8 $text] c* bytes
    set h 1469598103934665603
    foreach b $bytes {
        set h [expr {(($h ^ ($b & 0xff)) * 1099511628211) & 0xFFFFFFFFFFFFFFFF}]
    }
    return [format %016x $h]
}

# NAME-of-id for the program's declared errors (native/lower.tcl numbers them
# in hir::errorDecls order, from 1): the NIR ids depend on which declarations
# a pipeline's HIR carries, so the canonical form spells the names.
proc Canonical {nir errors} {
    set fnName [dict create]
    set blocks {}
    set current {}
    foreach line [split $nir \n] {
        if {[regexp {^func ([0-9]+) "([^"]*)".*instance="([^"]*)"} $line -> id name instance]} {
            dict set fnName $id "$name<$instance>"
        }
        if {[regexp {^func } $line]} {
            if {$current ne ""} { lappend blocks $current }
            set current {}
        }
        lappend current $line
    }
    if {$current ne ""} { lappend blocks $current }
    set canon {}
    foreach block $blocks {
        set text {}
        foreach line $block {
            set line [regsub -all { @e[0-9]+} $line {}]
            if {[regexp {^(\s+)faildeclared ([0-9]+) ("[^"]*")(.*)$} $line -> ws id name payload]} {
                # (PAYLOAD: a payload's shape and field registers,
                # ERROR-PAYLOADS.md.)
                set line "${ws}faildeclared $name$payload"
            } elseif {[regexp {^(.*declarederroreq) ([0-9]+)$} $line -> pre id]} {
                set line "$pre [lindex $errors [expr {$id - 1}]]"
            }
            set line [regsub {^func [0-9]+ } $line {func }]
            if {[regexp {(call|callmulti|fnvalue|closure|tail) ([0-9]+)( |$)} $line -> op id]
                    && [dict exists $fnName $id]} {
                regsub {(call|callmulti|fnvalue|closure|tail) [0-9]+( |$)} $line \
                    "\\1 <[dict get $fnName $id]>\\2" line
            }
            append text $line \n
        }
        lappend canon $text
    }
    return [join [lsort $canon] \n]
}

proc Asm {hir path} {
    native::object $hir $path
    set pipe [open |[list objdump -dr --no-show-raw-insn -M intel $path] r]
    set text [read $pipe]
    close $pipe
    return [string map [list $path OBJ] $text]
}

proc Build {mode surface} {
    switch -- $mode {
        relift { return [native::buildProgramHir [hir::lower $surface]] }
        direct { return [native::prepareHir $surface] }
    }
    error "unknown mode $mode"
}

set summary {}
foreach path $files {
    set name [file rootname [file tail $path]]
    if {[catch {set surface [surface::readProgramFile $path]; Build $mode $surface} hir]} {
        lappend summary "$name REJECTED [lindex [split $hir \n] 0]"
        continue
    }
    set row [dict create]
    set sem [dict get $hir semantic]
    foreach key {requests trivial hits walks rounds} { dict set row $key [dict get $sem $key] }
    dict set row instances [dict size [dict get $sem instances]]
    dict set row used [llength [dict get $sem used]]
    set recursive 0
    dict for {k v} [dict get $sem declinedCount] { dict set row declined-$k $v }
    set spec [hir::specialize::analyze $hir]
    set regions [hir::specialize::regions $hir $spec]
    set counts [dict create closed 0 guarded 0 open 0]
    foreach id [dict get $spec used] { dict incr counts [dict get [dict get $regions $id] status] }
    dict set row codegen [llength [dict get $spec used]]
    dict set row aot "[dict get $counts closed]/[dict get $counts guarded]/[dict get $counts open]"
    if {[catch {native::nir $hir} nir]} {
        lappend summary "$name UNSUPPORTED [lindex [split $nir \n] 0]"
        continue
    }
    set canon [Canonical $nir [hir::errorDecls $hir]]
    W [file join $out $name.nir] $nir
    W [file join $out $name.canon] $canon
    dict set row functions [regexp -all -line {^func } $nir]
    dict set row lines [llength [split $nir \n]]
    dict set row guards [regexp -all -line {^\s+guard(bool)? } $nir]
    dict set row calls [regexp -all -line {^\s+\S+ = call \d} $nir]
    dict set row callvalues [regexp -all {\ycallvalue\y} $nir]
    dict set row canon [Digest $canon]
    # Runtime results: the Tcl reference interpreter on the lowered Core IR
    # against this pipeline's native code, on the very HIR that was compiled.
    foreach {label run} {interp {core::evalProgram [hir::lower $surface]} native {native::evalHir $hir}} {
        if {[catch $run value options]} {
            dict set row $label "error:[Digest [dict get $options -errorcode]]"
        } else {
            dict set row $label [Digest [core::value::show $value]]
        }
    }
    if {[catch {native::codeSize $hir} size]} { set size {? {}} }
    dict set row bytes [lindex $size 0]
    set obj [file join $out $name.o]
    if {[catch {Asm $hir $obj} asm]} {
        dict set row asm ERROR
    } else {
        W [file join $out $name.asm] $asm
        dict set row asm [Digest $asm]
    }
    file delete -force $obj
    lappend summary "$name $row"
}
W [file join $out summary-[file rootname [file tail [lindex $files 0]]].txt] "[join $summary \n]\n"
