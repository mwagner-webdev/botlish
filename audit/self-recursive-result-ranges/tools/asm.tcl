#!/usr/bin/env tclsh9.0
# asm.tcl -- NIR, GC-root report and disassembly of a program's Botlish-
# generated code with the recursive-result-range analysis on or off
# (SELF-RECURSIVE-RESULT-RANGES.md). Observation only.
#
#   tclsh9.0 audit/self-recursive-result-ranges/tools/asm.tcl PROGRAM.bot OPT OUTPREFIX
#
# Writes OUTPREFIX.nir, OUTPREFIX.asm (objdump -dr on the unlinked object,
# symbols labelled with the function names) and OUTPREFIX.roots. Prints the
# machine-code bytes per function (native::codeSize).
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv path opt prefix
set hir [surface::readProgramFile $path]
set options [list -recursive-result-range-opt $opt]
proc W {path content} {
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
}
set nir [native::nir $hir {*}$options]
W $prefix.nir $nir
W $prefix.roots [native::roots $hir {*}$options]
set obj $prefix.o
native::object $hir $obj {*}$options
set pipe [open |[list objdump -dr --no-show-raw-insn -M intel $obj] r]
set text [read $pipe]
close $pipe
set funcs [dict create]
foreach line [split $nir \n] {
    if {[regexp {^func (\d+) "([^"]*)" .*?instance="([^"]*)"} $line -> id name inst]} {
        dict set funcs $id "$name<$inst>"
    } elseif {[regexp {^func (\d+) "([^"]*)"} $line -> id name]} {
        dict set funcs $id $name
    }
}
set out {}
foreach line [split $text \n] {
    if {[regexp {^([0-9a-f]+) <(botlish_(?:fn|entry)_(\d+))>:$} $line -> addr sym id]} {
        set label [expr {[dict exists $funcs $id] ? [dict get $funcs $id] : "fn$id"}]
        append out "$addr <$sym: $label>:\n"
        continue
    }
    append out "[string map [list $obj [file tail $obj]] $line]\n"
}
W $prefix.asm $out
file delete $obj
puts [native::codeSize $hir {*}$options]
