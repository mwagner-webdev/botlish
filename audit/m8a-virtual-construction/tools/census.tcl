#!/usr/bin/env tclsh9.0
# census.tcl -- M8.a virtual-construction census
# (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md). Observation only: reads what
# native::lower::program and hir::construction already compute, with their
# defaults; changes no compiler or runtime behavior.
#
#   tclsh9.0 audit/m8a-virtual-construction/tools/census.tcl PROGRAM OUTDIR
#
# PROGRAM is a .bot file (modules resolved), a .ir file (web library
# loaded, like bench/refined-checks.ir), or corpus:NAME (an
# examples/stdlib program with its own trailing demo driver). Writes into
# OUTDIR:
#   analysis.txt   hir::construction::explain: plan results, plan
#                  parameters, plan locals, per instance
#   sites.txt      every reachable construction site / plan-producing
#                  expression: instance, location, family, operation,
#                  disposition (virtual | materialized) and the barrier
#                  reason for a materialization, then totals per reason
#   functions.txt  per emitted NIR function, virtual construction off and
#                  on: instance key, machine-code bytes, guards, eager
#                  strcat/listappend ops, construct plan/flat ops,
#                  plan registers, plan result
#   alloc.txt      native::allocationReport summary, off and on: totals,
#                  per kind, copies, construction counters
#   products.txt   the H2 census: every function exit that is a literal
#                  fixed-length List construction ("return [x, y]"), its
#                  inferred result type and element types, how each exact
#                  caller consumes it, and whether it looks like a future
#                  struct
#   summary.txt    totals

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 1000000

namespace eval m8a {}

proc m8a::load {path} {
    global root
    if {[string match corpus:* $path]} {
        return [surface::readProgramFile [corpus::path [string range $path 7 end]]]
    }
    if {[file extension $path] eq ".bot"} {
        return [surface::readProgramFile $path]
    }
    core::loadLibrary web
    return [native::buildProgramHir [core::loadProgramFile $path]]
}

proc m8a::W {outdir name text} {
    set f [open [file join $outdir $name] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

proc m8a::Loc {location} {
    if {[dict exists $location line]} {
        return "[file tail [dict get $location file]]:[dict get $location line]:[dict get $location column]"
    }
    return $location
}

# Per-NIR-function rows of the lowering under OPT.
proc m8a::functions {hir opt} {
    set lowered [native::lower::program $hir -virtual-construction-opt $opt]
    lassign [native::codeSize $hir -virtual-construction-opt $opt] total perFunction
    set text [dict get $lowered text]
    set rows {}
    set i 0
    set chunks {}
    set current ""
    foreach line [split $text \n] {
        if {[string match "func *" $line]} {
            set current $line
        } elseif {$current ne "" && $line eq "end"} {
            lappend chunks $current
            set current ""
        } elseif {$current ne ""} {
            append current \n $line
        }
    }
    foreach chunk $chunks {
        regexp {^func (\d+) "([^"]*)"[^\n]*instance="([^"]*)"} $chunk -> id name key
        set planregs [expr {[regexp {planregs="([^"]*)"} $chunk -> regs] ? [llength $regs] : 0}]
        lappend rows [format "%-28s %-22s %6s bytes  guards=%-2d strcat=%-2d listappend=%-2d construct(plan)=%-2d construct(flat)=%-2d planregs=%-2d planresult=%d" \
            "$id $name" "<$key>" [lindex $perFunction $i] \
            [regexp -all -line {^\s+guard(bool)? } $chunk] \
            [regexp -all {op strcat } $chunk] [regexp -all {op listappend } $chunk] \
            [regexp -all {= construct \w+ plan } $chunk] [regexp -all {= construct \w+ flat } $chunk] \
            $planregs [regexp {planresult=1} $chunk]]
        incr i
    }
    return [list $total $rows]
}

proc m8a::alloc {hir opt} {
    set r [native::allocationReport $hir summary 1 -virtual-construction-opt $opt]
    set by [dict get $r byKind]
    set lines [list "virtual-construction-opt $opt"]
    lappend lines "  total allocations [dict get $r total allocations], allocated bytes [dict get $r total allocatedBytes]"
    foreach kind {String List StringPlan ListPlan Block ImmutableSet MutableArray Result} {
        set n [dict get $by $kind allocations]
        if {$n} {
            lappend lines [format "  %-12s %8d objects %10d bytes" $kind $n [dict get $by $kind allocatedBytes]]
        }
    }
    lappend lines "  copies: stringBytes [dict get $r copies stringBytes], listElements [dict get $r copies listElements]"
    lappend lines "  construction: [dict get $r construction]"
    return [join $lines \n]
}

# The H2 product-shaped List census (see the file header).
proc m8a::products {hir} {
    set lowered [native::lower::program $hir]
    set spec [dict get $lowered specialization]
    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    set escape [hir::escape::analyze $hir $spec]
    set lines {}
    set seen [dict create]
    # callers: InstanceId -> {caller call-expr}
    set callers [dict create]
    foreach id [dict get $spec used] {
        dict for {e callee} [dict get $spec instances $id calls] {
            dict lappend callers $callee [list $id $e]
        }
    }
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program"} {
            continue
        }
        set view [hir::specialize::view $hir $spec $id]
        foreach exit [hir::escape::Exits $view $context $instance $id $block $selfTails] {
            if {[hir::kind $view $exit] ne "call"} {
                continue
            }
            lassign [hir::get $view $exit target] tk target
            if {$tk ne "native" || [dict get [hir::symbol $view $target] name] ne "list"} {
                continue
            }
            set args [hir::get $view $exit args]
            set elems [lmap a $args {hir::types::show [hir::typeOf $view $a]}]
            set site [Loc [hir::aot::Location $view [hir::get $view $exit origin]]]
            set label [hir::specialize::label $spec $id]
            set resultType [dict get $instance result]
            set result [hir::types::show $resultType]
            set elem [expr {[lindex $resultType 0] eq "list" && [llength $resultType] >= 2
                ? [hir::types::show [lindex $resultType 1]] : "?"}]
            set shape [expr {[lindex $resultType 0] eq "list" && [llength $resultType] == 3
                ? "\[[join [lmap t [lindex $resultType 2] {hir::types::show $t}] {, }]\]" : "none"}]
            set broad [expr {[llength [lsort -unique $elems]] > 1 ? "yes: element theorem $elem (the lub of distinct field types)" : "no: element theorem $elem"}]
            set access {}
            set fixedOnly 1
            foreach a [Consumers $hir $spec $callers $selfTails $id 3 fixedOnly] {
                lappend access $a
            }
            set companion [expr {[hir::escape::wants $escape $id] ? "yes (escape.tcl scalar-replacement companion: no List is allocated for exact callers)" : "no"}]
            set candidate [expr {$fixedOnly && $access ne "" ? "likely future struct (every exact caller reads fixed positions)" : "unclear"}]
            lappend lines "$label  $site"
            lappend lines "    construction:       \[[join [lmap a $args {expr {"_"}}] {, }]\] ([llength $args] elements)"
            lappend lines "    instance result:    $result"
            lappend lines "    positional shape:   $shape (pre-existing specialization-only aggregate fact, hir/types.tcl)"
            lappend lines "    element types:      [join $elems {, }]"
            lappend lines "    broadens:           $broad"
            lappend lines "    scalar-replaced:    $companion"
            foreach a [lsort -unique $access] {
                lappend lines "    caller access:      $a"
            }
            lappend lines "    verdict:            $candidate"
        }
    }
    if {$lines eq ""} {
        return "no fixed-length List construction is returned by any used instance\n"
    }
    return "[join $lines \n]\n"
}

# How every exact caller of instance ID consumes its result; a caller that
# only forwards it (returns it) is followed to its own callers, DEPTH
# levels deep.
proc m8a::Consumers {hir spec callers selfTails id depth fixedVar} {
    upvar 1 $fixedVar fixed
    set result {}
    if {![dict exists $callers $id]} {
        return $result
    }
    foreach site [dict get $callers $id] {
        lassign $site caller callExpr
        if {$caller eq $id && [dict exists $selfTails $callExpr]} {
            continue
        }
        set access [CallerAccess $hir $spec $caller $callExpr fixed]
        if {[string match *forwards* $access] && $depth > 0} {
            set before $fixed
            set fixed 1
            set inner [Consumers $hir $spec $callers $selfTails $caller [expr {$depth - 1}] fixed]
            if {$inner eq ""} {
                set fixed 0
            }
            set fixed [expr {$fixed && $before}]
            foreach a $inner {
                lappend result "$access -> $a"
            }
            if {$inner eq ""} {
                lappend result $access
            }
            continue
        }
        lappend result $access
    }
    return $result
}

# How caller CALLER consumes the call CALLEXPR's List result.
proc m8a::CallerAccess {hir spec caller callExpr fixedVar} {
    upvar 1 $fixedVar fixed
    set view [hir::specialize::view $hir $spec $caller]
    set block [dict get $spec instances $caller block]
    set region [expr {$block eq "program" ? "program" : $block}]
    set exprs [dict get $spec context exprs $region]
    set parent ""
    foreach e $exprs {
        if {$callExpr in [hir::children $view $e] && [hir::kind $view $e] ne "block"} {
            set parent $e
            break
        }
    }
    set who [hir::specialize::label $spec $caller]
    if {$parent eq "" || [hir::kind $view $parent] eq "return"} {
        return "$who: forwards it as its own result"
    }
    if {[hir::kind $view $parent] ne "bind"} {
        set fixed 0
        return "$who: consumed by [hir::kind $view $parent] (not bound)"
    }
    set b [hir::get $view $parent binding]
    set positions {}
    foreach e $exprs {
        if {[hir::kind $view $e] ne "ref" || [hir::get $view $e binding] ne $b} {
            continue
        }
        set use ""
        foreach p $exprs {
            if {[hir::kind $view $p] eq "call" && [lindex [hir::get $view $p args] 0] eq $e} {
                lassign [hir::get $view $p target] tk t
                if {$tk eq "native" && [dict get [hir::symbol $view $t] name] eq "list_get"} {
                    set idx [lindex [hir::get $view $p args] 1]
                    if {[hir::kind $view $idx] eq "const"} {
                        set use "list_get(_, [core::value::show [hir::get $view $idx value]])"
                    }
                }
            }
        }
        if {$use eq ""} {
            set fixed 0
            set use "other use"
        }
        lappend positions $use
    }
    return "$who: bound as [dict get [hir::binding $view $b] name], read as [join [lsort -unique $positions] {, }]"
}

lassign $argv path outdir
file mkdir $outdir
set hir [m8a::load $path]
set lowered [native::lower::program $hir]
set spec [dict get $lowered specialization]
set analysis [dict get $lowered construction]

m8a::W $outdir analysis.txt "[hir::construction::explain $hir $spec $analysis]\n"

set records [hir::construction::audit $hir $spec $analysis]
set lines {}
set reasons [dict create]
foreach r $records {
    lappend lines [format "%-26s %-26s %-4s %-20s %-12s %s" [dict get $r instance] [m8a::Loc [dict get $r location]] \
        [dict get $r family] [dict get $r operation] [dict get $r disposition] [dict get $r reason]]
    set key [expr {[dict get $r disposition] eq "virtual" ? "(virtual)" : [dict get $r reason]}]
    dict incr reasons $key
}
lappend lines "" "totals by disposition / barrier reason:"
dict for {k n} $reasons {
    lappend lines [format "  %4d  %s" $n $k]
}
m8a::W $outdir sites.txt "[join $lines \n]\n"

set out {}
foreach opt {0 1} {
    lassign [m8a::functions $hir $opt] total rows
    lappend out "virtual-construction-opt $opt: $total machine-code bytes, [llength $rows] NIR functions" {*}$rows ""
}
m8a::W $outdir functions.txt [join $out \n]

m8a::W $outdir alloc.txt "[m8a::alloc $hir 0]\n\n[m8a::alloc $hir 1]\n"
m8a::W $outdir products.txt [m8a::products $hir]

set summary {}
lappend summary "program: $path"
lappend summary "value (on):  [core::value::show [native::evalHir $hir -virtual-construction-opt 1] 1]"
lappend summary "value (off): [core::value::show [native::evalHir $hir -virtual-construction-opt 0] 1]"
lappend summary "used instances: [llength [dict get $spec used]]"
lappend summary "plan results: [dict size [dict get $analysis results]], instances with plan parameters: [dict size [dict get $analysis params]], instances with plan locals: [dict size [dict get $analysis locals]]"
set virtualCount [expr {[dict exists $reasons "(virtual)"] ? [dict get $reasons "(virtual)"] : 0}]
lappend summary "construction sites/plan sources: [llength $records] ($virtualCount virtual)"
m8a::W $outdir summary.txt "[join $summary \n]\n"
puts [join $summary \n]
