# lower.tcl -- writes the NIR of audit/windows-stack-guard/programs/*.bot
# beside them (NAME.nir), with this checkout's front end, and the
# huge-frame recursion's NIR (3000 live Strings per frame: about 24 KiB,
# Cranelift's probe loop), so that drivers of different revisions run the
# same programs (tools/before-after.tcl).
#
#   tclsh9.0 audit/windows-stack-guard/tools/lower.tcl

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set argv {}
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
set programs [file join $root audit windows-stack-guard programs]
foreach source [lsort [glob -directory $programs *.bot]] {
    set hir [surface::readProgramFile $source -warnings off -cache ""]
    set out [file rootname $source].nir
    set f [open $out w]
    fconfigure $f -translation lf -encoding utf-8
    puts -nonewline $f [native::nir $hir]
    close $f
    puts "wrote $out"
}
set n 3000
set lines [list "nir 1" "" "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"" \
    "    %0 = call 1" "    ret %0" "end" \
    "func 1 \"huge_recurse\" params=0 env=0 regs=[expr {$n + 3}] pnames=\"\" captures=0 rawregs=\"\""]
set all {}
for {set i 0} {$i < $n} {incr i} {
    lappend lines "    %$i = str \"x\""
    lappend all %$i
}
lappend lines "    %$n = op listnew [join $all]" "    %[expr {$n + 1}] = call 1" \
    "    %[expr {$n + 2}] = op listlen %$n" "    ret %[expr {$n + 2}]" "end"
set f [open [file join $programs huge-frame.nir] w]
fconfigure $f -translation lf
puts $f [join $lines \n]
close $f
puts "wrote [file join $programs huge-frame.nir]"
