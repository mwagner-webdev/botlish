# legacy-parity.tcl MODE OUTDIR -- writes the NIR of fourteen probe programs under the policy MODE (base: no option, for the baseline tree; legacy: -struct-policy legacy) so the two trees can be compared with cmp. Observation only.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source /home/user/botlish/tests/transport-shapes.tcl
interp recursionlimit {} 2000000
set mode [lindex $argv 0]
set outdir [lindex $argv 1]
file mkdir $outdir
set opts [expr {$mode eq "legacy" ? {-struct-policy legacy} : {}}]
set progs [list a1 [chainArg 2 9 10] a2 [chainArg 4 3 10] a3 [chainArg 8 4 10] r1 [chainRet 8 2 10] r2 [chainRet 6 3 10] l1 [lateFrontier 6 5 10] m1 [mixed 4 3 6 10] b1 [branchy 8 6 10 5] c1 [selfTail 4 10] c2 [selfTail 5 10] n1 [nestedChainRet 2 1 10] n2 [nestedChainArg 4 3 10] d1 [chainArg 2 12 10] d2 [chainRet 4 6 10]]
foreach {name src} $progs {
    set f [open $outdir/$name.bot w]; puts $f $src; close $f
    set hir [surface::readProgramFile $outdir/$name.bot]
    set g [open $outdir/$name.nir w]; puts -nonewline $g [dict get [native::lowered $hir {*}$opts] text]; close $g
}
