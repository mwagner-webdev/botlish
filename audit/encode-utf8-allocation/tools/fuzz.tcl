#!/usr/bin/env tclsh9.0
# fuzz.tcl -- differential fuzzer for lib/web.bot's character-reading
# uri_escape_text and uri_query_value? (ENCODE-UTF8-ALLOCATION-RESEARCH.md).
#
#   tclsh9.0 audit/encode-utf8-allocation/tools/fuzz.tcl ?-seed N? ?-rounds N? ?-batch N? ?-backends LIST?
#
# Each round draws BATCH random strings over an alphabet chosen to hit every
# branch of both functions: RFC 3986 unreserved characters, '%', uppercase
# and lowercase hex digits (so "%XX" triplets valid and invalid, truncated
# at the end), reserved ASCII, ASCII controls, and 2-, 3- and 4-byte scalars
# including every UTF-8 width boundary. One program per round computes, for
# every string T, [uri_escape_text(T), uri_query_value?(T),
# uri_query_value?(uri_escape_text(T))]; every backend must print exactly
# what the independent oracle below computes from T's UTF-8 bytes (Tcl's own
# `encoding convertto`, sharing no code with the library or the compiler).
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set seed [clock milliseconds]
set rounds 20
set batch 40
set backends {interp compile cranelift-generic cranelift}
foreach {option value} $argv {
    switch -- $option {
        -seed { set seed $value }
        -rounds { set rounds $value }
        -batch { set batch $value }
        -backends { set backends $value }
        default { error "unknown option $option" }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
expr {srand($seed)}

set alphabet [concat [split "aZ09-._~" ""] [lrepeat 4 %] [split "0123456789ABCDEFabcdef" ""] \
    [split " &=+?/#@:!*'()\[\]" ""] \
    [lmap c {0x01 0x09 0x0A 0x7F 0x80 0xE9 0x7FF 0x800 0x4E16 0xFFFD 0xFFFF 0x10000 0x1F600 0x10FFFF} {format %c $c}]]

proc pick {} {
    global alphabet
    return [lindex $alphabet [expr {int(rand() * [llength $alphabet])}]]
}

proc hexish {} {
    if {rand() < 0.8} {
        return [lindex {0 1 2 3 4 5 6 7 8 9 A B C D E F} [expr {int(rand() * 16)}]]
    }
    return [lindex {/ : @ G a f g} [expr {int(rand() * 7)}]]
}

proc randomText {} {
    set n [expr {int(rand() * 9)}]
    set t ""
    for {set i 0} {$i < $n} {incr i} {
        # Bias toward "%XX" triplets so acceptance is common, with digits
        # that are mostly valid and sometimes just outside the uppercase hex
        # range on either side ('/' ':' '@' 'G' and lowercase).
        if {rand() < 0.2} {
            append t % [hexish] [hexish]
        } else {
            append t [pick]
        }
    }
    return $t
}

proc oracleEscape {s} {
    set out ""
    foreach byte [split [encoding convertto utf-8 $s] ""] {
        if {[regexp {^[A-Za-z0-9._~-]$} $byte]} {
            append out $byte
        } else {
            scan $byte %c code
            append out [format %%%02X $code]
        }
    }
    return $out
}

proc oracleQueryValue {s} {
    set bytes [split [encoding convertto utf-8 $s] ""]
    set n [llength $bytes]
    for {set i 0} {$i < $n} {incr i} {
        set b [lindex $bytes $i]
        if {$b eq "%"} {
            if {$i + 2 >= $n || ![regexp {^[0-9A-F]$} [lindex $bytes $i+1]]
                    || ![regexp {^[0-9A-F]$} [lindex $bytes $i+2]]} {
                return false
            }
            incr i 2
        } elseif {![regexp {^[A-Za-z0-9._~-]$} $b]} {
            return false
        }
    }
    return true
}

# S as a Botlish string literal: the quote, the backslash, tab, newline and
# carriage return escaped; every other character (other controls included)
# written as itself.
proc literal {s} {
    set out "\""
    foreach c [split $s ""] {
        scan $c %c code
        if {$c eq "\"" || $c eq "\\"} {
            append out \\$c
        } elseif {$c in [list \t \n \r]} {
            append out [string map [list \t {\t} \n {\n} \r {\r}] $c]
        } else {
            append out $c
        }
    }
    return "$out\""
}

proc showStr {s} {
    return "\"[string map {\\ \\\\ \" \\\"} $s]\""
}

set checked 0
set accepted 0
for {set r 0} {$r < $rounds} {incr r} {
    set texts [lmap _ [lrepeat $batch x] {randomText}]
    set program "import web\n\ntexts = \[[join [lmap t $texts {literal $t}] {, }]\]\nloop t in texts:\n    \[web::uri_escape_text(t), web::uri_query_value?(t), web::uri_query_value?(web::uri_escape_text(t))\]\n"
    set want "\[[join [lmap t $texts {
        set q [oracleQueryValue $t]
        if {$q} { incr accepted }
        format {[%s, %s, true]} [showStr [oracleEscape $t]] $q
    }] {, }]\]"
    if {[catch {surface::compile $program -warnings off} hir]} {
        puts "seed $seed round $r: compile error: $hir\n$program"
        exit 1
    }
    foreach backend $backends {
        if {$backend in {interp compile}} {
            core::useBackend $backend
            set status [catch {core::evalProgram [hir::lower $hir]} v]
        } else {
            set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
            set status [catch {native::evalHir $hir {*}$options} v]
        }
        set got [expr {$status ? "error: $v" : [core::value::show $v 1 1]}]
        if {$got ne $want} {
            puts "seed $seed round $r: $backend disagrees with the oracle\nprogram:\n$program\nwant: $want\ngot:  $got"
            exit 1
        }
    }
    incr checked $batch
}
puts "seed $seed: $checked strings x [llength $backends] backends agree with the oracle ($accepted accepted as query values)"
