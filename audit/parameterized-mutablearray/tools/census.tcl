#!/usr/bin/env tclsh9.0
# census.tcl -- PARAMETERIZED-MUTABLEARRAY.md's corpus-wide MutableArray
# census. Observation only: it runs against whatever tree it is started in
# (pwd is the root), so the same script measured the parent commit ("before")
# and this milestone's tree ("after").
#
#   (cd TREE && tclsh9.0 audit/parameterized-mutablearray/tools/census.tcl OUTFILE)
#
# Programs: bench/*.bot, examples/stdlib/*.bot, examples/surface/*.bot and
# every lib/*.bot module they load (a source location is counted once).
#
# Sections (semantic types of the source HIR, i.e. before specialization):
#   constructors   every call of mutable_array_allocate / mutarray::from_list /
#                  mutarray::create and its static result type
#   functions      every named function whose result type is a MutableArray
#                  (the raw kind or an applied MutableArray[T])
#   lists          every expression typed List[<MutableArray>], and every
#                  list_get call with the type of its result
#   requirements   every argument position that requires a MutableArray (a
#                  native's registered parameter type, or a user function's
#                  trusted/checked parameter type) with the argument's static
#                  type: "proven" when it is a MutableArray (raw or applied),
#                  else a checked boundary
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
proc T {hir e} { hir::types::show [hir::typeOf $hir $e] }
proc resultOf {hir e} { string trim [lindex [split [T $hir $e] >] end] }
proc isMA {t} { expr {$t eq "mutarray" || [string match {MutableArray\[*} $t]} }
proc isMAList {t} { expr {$t eq "List\[mutarray\]" || [string match {List\[MutableArray\[*} $t]} }
proc calleeName {hir e} {
    lassign [hir::get $hir $e target] kind t
    switch -- $kind {
        native { return [list native [dict get [hir::symbol $hir $t] name]] }
        block  { return [list block $t] }
    }
    return {}
}

set ctors [dict create]; set funcs [dict create]; set lists [dict create]
set gets [dict create]; set reqs [dict create]
foreach path $programs {
    if {[catch {surface::readProgramFile $path -strict 0} hir]} { puts stderr "[rel $path]: $hir"; continue }
    # named functions
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding declaredBy] eq ""} continue
        set value [hir::get $hir [dict get $binding declaredBy] value]
        if {[hir::kind $hir $value] ne "block"} continue
        set origin [hir::get $hir $value origin]
        if {[lindex $origin 0] ne "file"} continue
        set key "[siteKey $hir $value] [dict get $binding name]"
        set r [resultOf $hir $value]
        if {[isMA $r]} { dict set funcs $key $r }
    }
    dict for {e node} [dict get $hir exprs] {
        if {![hir::get $hir $e reachable]} continue
        set key [siteKey $hir $e]
        if {$key eq ""} continue
        set kind [dict get $node kind]
        set t [T $hir $e]
        if {[isMAList $t]} { dict set lists $key "$kind : $t" }
        if {$kind ne "call"} continue
        set callee [calleeName $hir $e]
        if {$callee eq ""} continue
        lassign $callee ck cn
        set args [hir::get $hir $e args]
        if {$ck eq "native"} {
            if {$cn eq "mutable_array_allocate"} { dict set ctors $key "native mutable_array_allocate -> $t" }
            if {$cn eq "list_get"} { dict set gets $key "list_get(list: [T $hir [lindex $args 0]]) -> $t" }
            set meta [core::native::metadata $cn]
            set ptypes [dict get $meta paramTypes]
            foreach a $args p $ptypes i [lseq [llength $args]] {
                if {$p ne "mutarray"} continue
                set at [T $hir $a]
                dict set reqs "$key arg[expr {$i+1}]" "native $cn requires mutarray: [expr {[isMA $at] ? {proven} : "checked boundary ($at)"}]"
            }
        } else {
            set sig [hir::signatures::of $hir $cn]
            set label ""
            dict for {b binding} [dict get $hir bindings] {
                if {[dict get $binding declaredBy] ne "" && [hir::get $hir [dict get $binding declaredBy] value] eq $cn} { set label [dict get $binding name] }
            }
            if {$label in {mutarray::from_list mutarray::create}} { dict set ctors $key "$label -> $t" }
            foreach a $args p [dict get $sig params] i [lseq [llength $args]] {
                if {$p eq ""} continue
                if {[hir::types::show [hir::signatures::paramType $p]] ne "mutarray"} continue
                set at [T $hir $a]
                dict set reqs "$key arg[expr {$i+1}]" "fn $label param [dict get $p name] requires mutarray: [expr {[isMA $at] ? {proven} : "checked boundary ($at)"}]"
            }
        }
    }
}
set out [open $outfile w]
fconfigure $out -encoding utf-8
proc emit {out title d} {
    puts $out "## $title"
    foreach k [lsort -dictionary [dict keys $d]] { puts $out "$k | [dict get $d $k]" }
    puts $out "# [dict size $d]"
    puts $out ""
}
emit $out "constructors (MutableArray constructor call sites and their static result type)" $ctors
emit $out "functions returning a MutableArray (semantic result type)" $funcs
emit $out "expressions typed List of MutableArray" $lists
emit $out "list_get call sites (list argument type -> result type)" $gets
set proven 0; set boundary 0
dict for {k v} $reqs { if {[string match *proven $v]} {incr proven} else {incr boundary} }
emit $out "MutableArray requirement sites (argument type vs required mutarray)" $reqs
puts $out "# requirement sites proven statically: $proven"
puts $out "# requirement sites still a checked boundary: $boundary"
set narrowed 0
dict for {k v} $gets { if {[regexp {\-> (mutarray|MutableArray\[.*\])$} $v]} { incr narrowed } }
puts $out "# list_get sites whose result is a MutableArray: $narrowed of [dict size $gets]"
close $out
