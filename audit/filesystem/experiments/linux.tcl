#!/usr/bin/env tclsh9.0
# linux.tcl -- the path-representation experiment on real Linux directories
# (WINDOWS-X86-64-MILESTONE-7.md, section 3).
#
#   tclsh9.0 audit/filesystem/experiments/linux.tcl ?-backend B?
#
# Makes a scratch directory (`file tempdir`) of fixture entries -- ordinary
# text, NFC and NFD spellings, bytes that are not UTF-8, the U+FFFD spelling
# a lossy decoding of those bytes produces, a newline, a symbolic link, a
# dangling one and a subdirectory -- each file holding its own index, then
# runs linux/designs.bot on it natively and prints, per entry, what each
# design's way of naming it again reached. Fixture names that Tcl cannot
# spell (non-UTF-8 bytes) are made by linux/make.bot through the raw
# syscalls. Removes the directory afterwards.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set backend cranelift
foreach {option value} $argv {
    switch -- $option {
        -backend { set backend $value }
        default { error "unknown option $option" }
    }
}

set dir [file tempdir botlish-fs-experiment-]
proc put {path text} {
    set f [open $path wb]
    puts -nonewline $f $text
    close $f
}
put [file join $dir plain.txt] 0
put [file join $dir é-nfc] 1
put [file join $dir é-nfd] 2
put [file join $dir ��x] 4
put [file join $dir a\nb] 5
file mkdir [file join $dir sub]
exec ln -s plain.txt [file join $dir link]
exec ln -s missing [file join $dir dangling]
# The non-UTF-8 name: bytes FF FE 78 ("x"), through the raw syscalls.
set out [exec tclsh9.0 [file join $root main.tcl] -warnings off -backend $backend \
    -argv make -argv $dir [file join $here linux make.bot] 2>@1]
puts "fixture: $out"
puts "ls -b: [exec ls -b $dir]"
set result [exec tclsh9.0 [file join $root main.tcl] -warnings off -backend $backend \
    -argv designs -argv $dir [file join $here linux designs.bot] 2>@1]
puts "columns: \[A strict text, what A's text opened, A' lossy text, what A''s text opened, what the native name opened\]"
puts $result
exec rm -rf $dir
