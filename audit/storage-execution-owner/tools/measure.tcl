# measure.tcl -- per-unit allocation evidence for STORAGE-EXECUTION-OWNER-
# CENSUS-1.md (sections 19 and 23): what each unit of work (a job, a
# request, a round trip) of the owner probes and of the census's workloads
# still allocates today, by kind and from the system allocator.
#
#   tclsh9.0 audit/storage-execution-owner/tools/measure.tcl
#       ?-sizes {N1 N2}? ?-valgrind 0|1? ?-out FILE?
#
# Per workload, at N1 and N2 units, natively (cranelift, scratch storage on,
# as compiled by default): managed-heap allocations by kind
# (native::allocationReport), scratch placements, coroutine stacks mapped
# and reused; and with -valgrind 1 (the default) every system-allocator call
# of a standalone executable (valgrind's total heap usage). Per unit is the
# difference over N2 - N1 units, so startup and one-time reservations
# cancel. Writes FILE (default audit/storage-execution-owner/results/
# measurements.md).
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set root [file dirname [file dirname $audit]]
set options [dict create -sizes {500 1000} -valgrind 1 -out [file join $audit results measurements.md]]
foreach {k v} $argv {
    if {![dict exists $options $k]} { error "unknown option $k" }
    dict set options $k $v
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
set work [file tempdir]
set probes [file join $audit probes]
set cases [file join $root audit storage-static-reuse cases]

# name -> {file old new unit}
set workloads [list \
    e01 [list $probes/e01-sequential-owner.bot {drive(1000)} {drive(@N@)} "job (two resumptions)"] \
    e03 [list $probes/e03-independent-coroutines.bot {fold i from 0 to 1000 with} {fold i from 0 to @N@ with} "pair of coroutines"] \
    e04 [list $probes/e04-resumption.bot {drive(1000)} {drive(@N@)} "coroutine (five segments)"] \
    e05 [list $probes/e05-actor-messages.bot {main(200):} {main(@N@):} "round trip between two actors"] \
    e07 [list $probes/e07-http-worker.bot {drive(1000)} {drive(@N@)} "request to a persistent worker"] \
    e09 [list $probes/e09-abandonment.bot {drive(1000)} {drive(@N@)} "abandoned coroutine"] \
    e10 [list $probes/e10-declared-failure.bot {drive(1000):} {drive(@N@):} "check and job (some fail)"] \
    e13 [list $probes/e13-nested-owners.bot {drive(1000)} {drive(@N@)} "parent with a child"] \
    p01 [list $cases/p01-sequential-temps.bot {fold i from 0 to 1000 with} {fold i from 0 to @N@ with} "call (four temporaries)"] \
    p04 [list $cases/p04-loop-reuse.bot {work(1000)} {work(@N@)} "iteration"] \
    p12 [list $cases/p12-actor-messages.bot {main(200):} {main(@N@):} "round trip between two actors"] \
    p13 [list $cases/p13-request-handler.bot {fold i from 0 to 200 with} {fold i from 0 to @N@ with} "request (a function call)"] \
    p14 [list $cases/p14-errors-early-exit.bot {fold i from 0 to 1000 with} {fold i from 0 to @N@ with} "unit (some fail)"]]

proc Program {name file old new size} {
    set f [open $file r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    if {[string first $old $text] < 0} {
        error "measure: $name has no \"$old\""
    }
    set text [string map [list $old [string map [list @N@ $size] $new]] $text]
    # (None of these workloads imports an application module.)
    set path [file join $::work $name-$size.bot]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    return $path
}

# {kind-dict scratch stacksMapped stacksReused heap system} of one size.
proc Point {name file old new size} {
    set path [Program $name $file $old $new $size]
    set hir [surface::readProgramFile $path -warnings off]
    set r [native::allocationReport $hir summary 1]
    set kinds [dict create]
    dict for {k v} [dict get $r byKind] {
        if {[dict get $v allocations] > 0} {
            dict set kinds $k [dict get $v allocations]
        }
    }
    set co [dict getdef $r coroutines {}]
    set system ""
    if {[dict get $::options -valgrind]} {
        set exe [native::executable $hir [file join $::work $name-$size]]
        catch {exec valgrind --leak-check=no $exe 2>@1} out
        if {[regexp {total heap usage: ([0-9,]+) allocs} $out -> n]} {
            set system [string map {, {}} $n]
        }
    }
    return [list $kinds [dict getdef [dict getdef $r scratch {}] allocations 0] \
        [dict getdef $co stacksMapped 0] [dict getdef $co stacksReused 0] \
        [dict get $r total allocations] $system]
}

proc Rate {a b d} {
    if {$a eq "" || $b eq ""} { return "-" }
    set x [expr {($b - $a) / double($d)}]
    return [format %.2f $x]
}

lassign [dict get $options -sizes] n1 n2
set version [expr {[dict get $options -valgrind] ? [string trim [exec valgrind --version]] : "valgrind not run"}]
set lines [list "# Per-unit allocations of the execution-owner probes and the census workloads" "" \
    "Generated by \`tclsh9.0 audit/storage-execution-owner/tools/measure.tcl\` (STORAGE-EXECUTION-OWNER-CENSUS-1.md; $version). The native backend (cranelift) as compiled by default (scratch storage on, coroutine fusion on). Per unit: the difference between N = $n1 and N = $n2 units over [expr {$n2 - $n1}]. Managed-heap counts are native::allocationReport's; system allocations are valgrind's total heap usage of a standalone executable (every malloc, managed-heap objects included: a String is one block, a struct two)." "" \
    "| workload | unit | managed-heap allocations | by kind | scratch placements | coroutine stacks mapped / reused | system allocations |" \
    "|---|---|---:|---|---:|---:|---:|"]
foreach {name spec} $workloads {
    lassign $spec file old new unit
    puts stderr "measure: $name"
    lassign [Point $name $file $old $new $n1] k1 s1 m1 u1 h1 y1
    lassign [Point $name $file $old $new $n2] k2 s2 m2 u2 h2 y2
    set d [expr {$n2 - $n1}]
    set byKind {}
    dict for {k v} $k2 {
        set rate [Rate [dict getdef $k1 $k 0] $v $d]
        if {$rate ne "0.00"} {
            lappend byKind "$k $rate"
        }
    }
    lappend lines "| $name | $unit | [Rate $h1 $h2 $d] | [join $byKind {, }] | [Rate $s1 $s2 $d] | [Rate $m1 $m2 $d] / [Rate $u1 $u2 $d] | [Rate $y1 $y2 $d] |"
}
set f [open [dict get $options -out] w]
fconfigure $f -encoding utf-8 -translation lf
puts $f [join $lines \n]
close $f
file delete -force $work
puts stderr "measure: wrote [string map [list $root/ {}] [dict get $options -out]]"
