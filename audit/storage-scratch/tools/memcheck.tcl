# memcheck.tcl -- standalone executables of the census workloads under
# valgrind's memcheck, scratch storage on, plain and under GC stress
# (STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md, section 20).
#
#   tclsh9.0 audit/storage-scratch/tools/memcheck.tcl ?CASE ...?
#
# CASE is a census case's prefix (default p01 p04 p05 p13 p14). Memcheck
# reports invalid reads and writes of freed or unallocated memory -- the
# managed heap's objects are system allocations, so a swept object read
# through a lost root is one -- and invalid or mismatched frees. It sees
# scratch chunks as ordinary allocated memory: a read of *released* scratch
# storage is invisible to it (the poisoning of tests/scratch-storage.test
# and fuzz.tcl is that instrument), so its findings are kept apart from the
# functional evidence. Exit status 1 when memcheck reports an error or an
# executable fails.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set cases $argv
if {$cases eq {}} {
    set cases {p01 p04 p05 p13 p14}
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
if {[catch {exec valgrind --version} version]} {
    puts "memcheck: valgrind is not installed"
    exit 1
}
puts "# [string trim $version]"
set work [file tempdir]
set failures 0
foreach c $cases {
    set path [lindex [glob [file join $root audit storage-static-reuse cases $c-*.bot]] 0]
    set hir [surface::readProgramFile $path -warnings off]
    set exe [native::executable $hir [file join $work $c]]
    foreach stress {0 1} {
        set environment [if {$stress} {list BOTLISH_NATIVE_GC_STRESS 1} else {list BOTLISH_NATIVE_GC_STRESS ""}]
        set status 0
        set out [withEnvironment $environment {
            if {[catch {exec valgrind --error-exitcode=99 --leak-check=no $exe 2>@1} out opts]} {
                set status [lindex [dict get $opts -errorcode] end]
            }
            set out
        }]
        regexp -line {ERROR SUMMARY: (\d+) errors} $out -> errors
        puts "[file rootname [file tail $path]] gc-stress=$stress status=$status memcheck errors=$errors"
        if {$status != 0 || $errors != 0} {
            incr failures
            puts [string range $out 0 4000]
        }
    }
}
file delete -force $work
exit [expr {$failures > 0}]
