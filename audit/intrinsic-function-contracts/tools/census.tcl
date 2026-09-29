#!/usr/bin/env tclsh9.0
# census.tcl -- INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md's corpus-wide
# body-inference census (spec item 58): every parameter of every function
# of every canonical source program -- bench/*.bot, examples/stdlib/*.bot,
# examples/surface/*.bot -- and of every lib/*.bot module those programs
# load, each function counted once (keyed by its source file and line), as
# the ordinary surface pipeline infers it (surface::readProgramFile, the
# HIR `main.tcl` lowers). Observation only.
#
#   tclsh9.0 audit/intrinsic-function-contracts/tools/census.tcl OUTDIR
#
# writes OUTDIR/census.txt (totals, grouped) and OUTDIR/params.txt (every
# parameter with its inferred contract and provenance).
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outdir

proc rel {path} {
    set root [pwd]
    if {[string first "$root/" $path] == 0} {
        return [string range $path [string length "$root/"] end]
    }
    return $path
}

set programs [concat \
    [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $root examples surface] *.bot]]]

set seen [dict create]
set rows {}
set conflicts {}
set failed {}
foreach path $programs {
    if {[catch {surface::readProgramFile $path -strict 0} hir]} {
        lappend failed "[rel $path]: $hir"
        continue
    }
    foreach d [hir::diagnostics $hir] {
        set msg [dict get $d message]
        if {[string match "cannot infer a sound type for parameter*" $msg]} {
            lappend conflicts "[rel $path]: $msg"
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block"} continue
        set origin [dict get $node origin]
        if {[lindex $origin 0] ne "file"} continue
        set fields [lrange $origin 2 end]
        set file [rel [dict get [hir::sourceFile $hir [lindex $origin 1]] path]]
        set key "$file:[dict get $fields line]"
        if {[dict exists $seen $key]} continue
        dict set seen $key 1
        set sig [hir::signatures::of $hir $e]
        set name [hir::signatures::Name $hir $e]
        set notes [dict get $node paramNotes]
        foreach p [dict get $sig params] note $notes {
            set source [dict get $p source]
            set t [hir::signatures::paramType $p]
            if {$source eq "declared"} {
                set class declared
            } elseif {$source eq "inferred" && [dict get $p trusted] ne ""} {
                set class [expr {[hir::types::IsFn [dict get $p trusted]] ? "structural Fn" : "narrowed (trusted)"}]
            } elseif {$source eq "inferred"} {
                set class "narrowed (checked)"
            } elseif {[lindex $note 0] eq "relational"} {
                set class "any: relational callable constraint (needs a type variable)"
            } elseif {[lindex $note 0] ne ""} {
                set class "any: called, but [lindex $note 0]"
            } else {
                set class "any: no requirement"
            }
            lappend rows [list $key $name [dict get $p name] $class [hir::types::show $t] \
                [hir::signatures::explain $hir $p] $note [rel $path]]
        }
    }
}

set L {}
lappend L "tree: [exec git -C $root rev-parse HEAD] (plus any uncommitted working-tree changes)"
lappend L "programs: [llength $programs] ([llength $failed] not compiled: [join $failed {; }])"
lappend L "functions (distinct source definitions): [dict size $seen]"
set untyped [lsearch -all -inline -not -index 3 $rows declared]
lappend L "parameters: [llength $rows] ([expr {[llength $rows] - [llength $untyped]}] declared, [llength $untyped] untyped and inspected)"
lappend L ""
set byClass [dict create]
foreach r $untyped { dict incr byClass [lindex $r 3] }
lappend L "untyped parameters by outcome:"
foreach k [lsort [dict keys $byClass]] { lappend L [format "  %-62s %4d" $k [dict get $byClass $k]] }
lappend L [format "  %-62s %4d" "conflicting requirements (compile-time error)" [llength $conflicts]]
lappend L ""
set byType [dict create]
foreach r $untyped {
    if {[string match "narrowed*" [lindex $r 3]] || [lindex $r 3] eq "structural Fn"} {
        dict incr byType [lindex $r 4]
    }
}
lappend L "narrowed parameters by inferred type:"
foreach k [lsort [dict keys $byType]] { lappend L [format "  %-62s %4d" $k [dict get $byType $k]] }
lappend L ""
lappend L "conflicts:"
foreach c $conflicts { lappend L "  $c" }
if {$conflicts eq {}} { lappend L "  (none)" }

set f [open [file join $outdir census.txt] w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f

set P {}
foreach r [lsort -index 0 -dictionary $rows] {
    lassign $r key name param class type why note program
    lappend P "$key ${name}(${param}): $type  -- $class   (first seen in $program)"
    foreach w $why { lappend P "        $w" }
    if {$note ne ""} { lappend P "        note: $note" }
}
set f [open [file join $outdir params.txt] w]
fconfigure $f -encoding utf-8
puts $f [join $P \n]
close $f
puts "wrote $outdir/census.txt $outdir/params.txt"
