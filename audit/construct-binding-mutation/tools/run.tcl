# run.tcl -- the reproducer corpus of CONSTRUCT-BINDING-MUTATION-CENSUS-1.md
# (audit/construct-binding-mutation/corpus/): every program, compiled by the
# ordinary front end and run on every backend.
#
#   tclsh9.0 audit/construct-binding-mutation/tools/run.tcl \
#       ?-backends LIST? ?-alloc 0|1? ?FILE...?
#
# A program's leading comments state what it shows:
#
#   # expect: VALUE                    its value, on every backend
#   # expect-diagnostics: CODE@L:C ... it is rejected with exactly these
#                                      diagnostics, in this order
#   # alloc: KIND FIELD N ...          the native backend's allocation report
#                                      (native::allocationReport summary):
#                                      for KIND (mutableVector, mutableArray)
#                                      each FIELD is N
#
# Exit status 1 on any mismatch (a backend disagreeing included).

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set backends {interp compile cranelift-generic cranelift}
set alloc 1
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    switch -- $a {
        -backends { set backends [lindex $argv [incr i]] }
        -alloc { set alloc [lindex $argv [incr i]] }
        default { lappend files [file normalize $a] }
    }
}
if {$files eq {}} {
    set files [lsort [glob -directory [file join [file dirname $here] corpus] *.bot]]
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
unset -nocomplain env(BOTLISH_HIR_CACHE)
source [file join $checkout examples stdlib corpus.tcl]
interp recursionlimit {} 1000000

proc Outcome {backend hir} {
    if {[catch {corpus::run $backend $hir} value options]} {
        if {$backend eq "cranelift-generic" && [dict get $options -errorcode] eq "NATIVE UNSUPPORTED struct-shape"} {
            # (cranelift-generic has no slot for a projection only a
            # semantic instance proves: cranelift stands in, as in
            # tests/helpers.tcl's outcomeUnder.)
            return [Outcome cranelift $hir]
        }
        return [list error [dict get $options -errorcode]]
    }
    return [list value [core::value::show $value 1]]
}

set failures 0
foreach file $files {
    set text [core::ReadFile $file]
    set name [file tail $file]
    set problems {}
    set shown ""
    if {[catch {surface::readProgramFile $file -warnings off} hir options]} {
        set got [lmap d [dict getdef $options -diagnostics [list [dict create errorcode [dict get $options -errorcode]]]] {
            set l [dict getdef $d location {}]
            string cat [lindex [dict get $d errorcode] end] @ [dict getdef $l line ?] : [dict getdef $l column ?]
        }]
        if {![regexp -line {^#\s*expect-diagnostics:\s*(.*)$} $text -> want]} {
            lappend problems "rejected: $got"
        } elseif {$got ne [string trim $want]} {
            lappend problems "diagnostics $got, expected $want"
        }
        set shown "rejected: $got"
    } else {
        if {![regexp -line {^#\s*expect:\s*(.*)$} $text -> want]} {
            lappend problems "compiles, but states no # expect:"
        }
        set outcomes {}
        foreach backend $backends {
            set o [Outcome $backend $hir]
            lappend outcomes $o
            if {[info exists want] && $o ne [list value $want]} {
                lappend problems "$backend: $o"
            }
        }
        set shown [lindex $outcomes 0]
        if {$alloc && "cranelift" in $backends && [regexp -line {^#\s*alloc:\s*(.*)$} $text -> spec]} {
            set report [native::allocationReport $hir summary]
            set kind [lindex $spec 0]
            foreach {field n} [lrange $spec 1 end] {
                set have [dict getdef $report $kind $field ?]
                if {$have ne $n} {
                    lappend problems "alloc $kind $field $have, expected $n"
                }
            }
            append shown "  alloc [dict getdef $report $kind {}]"
        }
    }
    unset -nocomplain want
    if {$problems eq {}} {
        puts [format "ok    %-36s %s" $name $shown]
    } else {
        incr failures
        puts [format "FAIL  %-36s %s" $name [join $problems {; }]]
    }
}
puts "programs: [llength $files]; failures: $failures"
exit [expr {$failures > 0}]
