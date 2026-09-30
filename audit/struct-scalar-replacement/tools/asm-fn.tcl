#!/usr/bin/env tclsh9.0
# asm-fn.tcl PROGRAM.bot FUNCTION ?OPTION...? -- prints the NIR and the
# machine code (objdump -dr, Intel syntax, relocations shown so runtime-helper
# calls such as rt_struct_new are visible by name) of every NIR function named
# FUNCTION in PROGRAM, under the given native::lower options (e.g.
# `-struct-opt 0` for the structs milestone's lowering). Observation only.
#
#   (cd TREE && tclsh9.0 audit/struct-scalar-replacement/tools/asm-fn.tcl examples/stdlib/csv.bot scan_unquoted -struct-opt 0)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000
lassign $argv path name
set opts [lrange $argv 2 end]
set hir [native::prepareHir [surface::readProgramFile $path]]
set nir [dict get [native::lowered $hir {*}$opts] text]
set ids {}
set lines [split $nir \n]
set i 0
foreach line $lines {
    if {[regexp "^func (\\d+) \"$name\"" $line -> id]} {
        lappend ids $id
        set block {}
        foreach l [lrange $lines $i end] { lappend block $l; if {$l eq "end"} break }
        puts "=== NIR (function $id)\n[join $block \n]"
    }
    incr i
}
set obj [file join [pwd] asm-fn-[pid].o]
native::object $hir $obj {*}$opts
set pipe [open |[list objdump -dr --no-show-raw-insn -M intel $obj] r]
set text [read $pipe]; close $pipe
file delete -force $obj
foreach id $ids {
    set printing 0
    puts "=== machine code (function $id)"
    foreach line [split $text \n] {
        if {[regexp {^[0-9a-f]+ <botlish_(?:fn|entry)_(\d+)>:} $line -> fid]} {
            set printing [expr {$fid == $id}]
        }
        if {$printing} { puts $line }
    }
}
