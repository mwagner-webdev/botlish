# check.tcl -- EVENT-LOOP-EXPLORATION.md's executable evidence.
#
#   tclsh9.0 audit/event-loop/tools/check.tcl ?-only GLOB? ?-parts sim|static|native|all?
#                                             ?-backends LIST? ?-out DIR?
#
# sim     every a-*.bot program (the deterministic driver) compiled once
#         under -warnings error and run on every backend: the outcomes must
#         be identical, then each scenario's claims are checked on the trace;
# static  programs that must be REJECTED by the compiler (driver selection,
#         capabilities, ownership), each with its expected diagnostic kinds;
# native  the C adapters built (cc, ar) and the b-*.bot programs run on the
#         native backends against real epoll/eventfd/sockets/threads (and
#         SDL3 when tests/cffi/sdl3.tcl has built it), with their claims.
#
# Prints one line per scenario and claim, writes each scenario's trace to
# -out DIR (default: a temporary directory, printed), and exits 1 when any
# claim fails.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set ::src [file join $root audit event-loop src]
cd $root
set options [dict create -only * -parts all -backends {interp compile cranelift-generic cranelift} -out ""]
foreach {k v} $argv {
    if {![dict exists $options $k]} { puts stderr "unknown option $k"; exit 2 }
    dict set options $k $v
}
# tests/helpers.tcl configures tcltest from argv: give it none.
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
set ::only [dict get $options -only]
set ::backends [dict get $options -backends]
set ::outDir [dict get $options -out]
if {$::outDir eq ""} { set ::outDir [file tempdir evloop] }
file mkdir $::outDir
set parts [dict get $options -parts]
if {$parts eq "all"} { set parts {sim static native} }

set ::failures 0
set ::claims 0
proc claim {scenario text ok {detail ""}} {
    incr ::claims
    if {$ok} {
        puts [format "  ok    %-18s %s" $scenario $text]
    } else {
        incr ::failures
        puts [format "  FAIL  %-18s %s %s" $scenario $text $detail]
    }
}

# The strings of a Botlish List[str] as core::value::show prints it.
proc strings {shown} {
    set out {}
    foreach {- s} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} $shown] {
        lappend out [subst -nocommands -novariables $s]
    }
    return $out
}

# Lines of TRACE matching the regexp RE (with its groups), as lists.
proc matches {trace re} {
    set out {}
    foreach line $trace {
        set m [regexp -inline -- $re $line]
        if {$m ne ""} { lappend out $m }
    }
    return $out
}
proc turnOf {line} { regexp {^t=(\d+):} $line -> t; return $t }
proc first {trace re} {
    set m [matches $trace $re]
    if {$m eq ""} { return "" }
    return [lindex $m 0]
}

# Compile FILE once (warnings are errors) and run it on every backend.
# Returns the trace (a list of lines); the outcomes must agree.
proc simRun {name} {
    set path [file join $::src $name.bot]
    set started [clock milliseconds]
    if {[catch {surface::readProgramFile $path -warnings error} hir options]} {
        claim $name "compiles (-warnings error)" 0 [string range $hir 0 400]
        return ""
    }
    set outcomes {}
    foreach b $::backends {
        set o [outcomeUnderHir $b $hir]
        lappend outcomes [lrange $o 0 1]
    }
    set distinct [lsort -unique $outcomes]
    claim $name "same outcome on [llength $::backends] backends" [expr {[llength $distinct] == 1}] \
        [join [lmap o $outcomes {string range $o 0 200}] " | "]
    set outcome [lindex $outcomes end]
    if {[lindex $outcome 0] ne "value"} {
        claim $name "runs" 0 [string range $outcome 0 400]
        return ""
    }
    set trace [strings [lindex $outcome 1]]
    set f [open [file join $::outDir $name.trace] w]
    puts $f [join $trace \n]
    close $f
    puts [format "        %-18s %d trace lines, %.1f s" $name [llength $trace] [expr {([clock milliseconds] - $started) / 1000.0}]]
    return $trace
}

source [file join $here claims.tcl]

if {"sim" in $parts} {
    puts "== sim (deterministic driver, backends: $::backends)"
    foreach name [lsort [glob -tails -directory $::src a-*.bot]] {
        set name [file rootname $name]
        if {![string match $::only $name]} continue
        set trace [simRun $name]
        if {$trace eq ""} continue
        set ::traces($name) $trace
        if {[info commands claims::$name] ne ""} {
            claims::$name $trace
        }
    }
    if {[string match $::only a-compose] || $::only eq "*"} {
        claims::composition
    }
}

if {"static" in $parts} {
    puts "== static (programs the compiler must reject)"
    source [file join $here static.tcl]
}

if {"native" in $parts} {
    puts "== native (real adapters)"
    source [file join $here native.tcl]
}

puts "[expr {$::claims - $::failures}]/$::claims claims hold; traces in $::outDir"
exit [expr {$::failures > 0}]
