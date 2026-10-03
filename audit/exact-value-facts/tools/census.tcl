#!/usr/bin/env tclsh9.0
# census.tcl -- EXACT-VALUE-FACTS.md's corpus-wide census. Observation only:
# it runs against whatever tree it is started in, so the same script
# measured the parent commit ("before", where hir::exact does not exist) and
# this milestone's tree ("after").
#
#   tclsh9.0 audit/exact-value-facts/tools/census.tcl OUTFILE
#
# Programs: bench/*.bot, examples/stdlib/*.bot, examples/surface/*.bot and
# every lib/*.bot module they load (a source location is counted once).
# One line per `list::at` / `list::length` call site, in source order:
#
#   SITE | native | sem=SEMANTIC-TYPE | inst=VIEW TYPES{RANGE FACTS} | idx=.. list=..
#
# where SEMANTIC-TYPE is the source HIR's type of the call, VIEW TYPES/RANGE
# FACTS are the sorted distinct types/ranges the used specialization
# instances give it, and (after only) idx/list are hir::exact's exact
# selector/aggregate answers on the semantic HIR.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outfile

proc rel {path} {
    set root [pwd]
    if {[string first "$root/" $path] == 0} { return [string range $path [string length "$root/"] end] }
    return $path
}
set havExact [expr {[info commands hir::exact::Of] ne ""}]
set programs [concat \
    [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $root examples surface] *.bot]]]

proc siteKey {hir e} {
    set origin [hir::get $hir $e origin]
    if {[lindex $origin 0] ne "file"} { return "" }
    set f [lrange $origin 2 end]
    return "[rel [dict get [hir::sourceFile $hir [lindex $origin 1]] path]]:[dict get $f line]:[dict get $f column]"
}
proc natName {hir e} {
    if {[hir::kind $hir $e] ne "call"} { return "" }
    lassign [hir::get $hir $e target] k t
    if {$k ne "native"} { return "" }
    return [dict get [hir::symbol $hir $t] name]
}

set sites [dict create]      ;# key -> dict
set consts [dict create]     ;# key -> kind (exact constants tracked)
set lists [dict create]      ;# key -> 1 (known exact lists tracked)
foreach path $programs {
    if {[catch {surface::readProgramFile $path -strict 0} hir]} { puts stderr "[rel $path]: $hir"; continue }
    set spec [hir::specialize::analyze $hir]
    set an [hir::range::analyze $hir $spec]
    # semantic pass
    dict for {e node} [dict get $hir exprs] {
        set n [natName $hir $e]
        if {$n ni {list::at list::length}} continue
        set key [siteKey $hir $e]
        if {$key eq ""} continue
        if {![dict exists $sites $key]} {
            set rec [dict create native $n sem [hir::types::show [hir::typeOf $hir $e]] insts {} idx {} list {}]
            if {$havExact} {
                set args [hir::get $hir $e args]
                set lf [hir::exact::ListOf $hir [lindex $args 0]]
                dict set rec list [expr {$lf eq "" ? "-" : "n=[hir::exact::Length $lf]"}]
                if {$n eq "list::at"} {
                    set iv [hir::exact::IntOf $hir [lindex $args 1]]
                    set how [expr {[hir::kind $hir [lindex $args 1]] eq "const" ? "lit" : "derived"}]
                    dict set rec idx [expr {$iv eq "" ? "-" : "${iv}($how)"}]
                }
            }
            dict set sites $key $rec
        }
    }
    if {$havExact} {
        dict for {e node} [dict get $hir exprs] {
            set key [siteKey $hir $e]
            if {$key eq "" || [dict exists $consts $key] || ![hir::get $hir $e reachable]} continue
            set f [hir::exact::Of $hir $e]
            if {$f eq ""} continue
            switch -- [lindex $f 0] {
                int - val { dict set consts $key [lindex $f 0] }
                list { dict set lists $key 1 }
            }
        }
    }
    # instance views
    foreach id [dict get $spec used] {
        set view [hir::specialize::view $hir $spec $id]
        dict for {e r0} [dict get $an instances $id exprs] {
            set n [natName $view $e]
            if {$n ni {list::at list::length}} continue
            set key [siteKey $hir $e]
            if {$key eq "" || ![dict exists $sites $key]} continue
            set t [hir::types::show [hir::typeOf $view $e]]
            set r [hir::range::show [hir::range::of $an $id $e]]
            set rec [dict get $sites $key]
            dict lappend rec insts "$t {$r}"
            dict set sites $key $rec
        }
    }
}
set out [open $outfile w]
fconfigure $out -encoding utf-8
foreach key [lsort -dictionary [dict keys $sites]] {
    set rec [dict get $sites $key]
    set insts [lsort -unique [dict get $rec insts]]
    puts $out "$key | [dict get $rec native] | sem=[dict get $rec sem] | inst=[join $insts {; }] | idx=[dict get $rec idx] list=[dict get $rec list]"
}
puts $out "# sites: [dict size $sites]"
puts $out "# exact constants tracked (source locations): [dict size $consts]"
puts $out "# known exact lists tracked (source locations): [dict size $lists]"
close $out
