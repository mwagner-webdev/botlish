# test-census.tcl -- the DISCARDED-MUTATION facts of every program one Tcl
# test file compiles (WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md, section
# 11): a source string of a test, a file it writes, a golden suite it runs.
#
#   tclsh9.0 audit/discarded-mutation/tools/test-census.tcl \
#       OUT.tsv tests/X.test ?TCLTEST-OPTION...?
#
# The test file runs as it always does (its results are its own; this tool
# only listens): every whole build of a source program (hir::BuildFull)
# that checked it without a diagnostic is analyzed (hir::discarded::findings
# of its checked source), whatever the compilation's warning policy -- the
# test suite compiles most programs with warnings off. A finding is keyed by
# its program's file name, line, column and reason, so a template a test
# compiles many times is one row with its count.
#
# The hook replaces hir::BuildFull by a wrapper: a test that reads that
# procedure's body (static-economics.test's se-property-plan-gate) fails
# under this tool, and only under it.

set ::dmcOut [lindex $argv 0]
set ::dmcTest [file normalize [lindex $argv 1]]
set argv [lrange $argv 2 end]
set argc [llength $argv]
set ::dmcRows [dict create]

proc dmcInstall {} {
    if {[info commands ::hir::BuildFull] eq ""} return
    if {[string first dmcListen [info body ::hir::BuildFull]] >= 0} return
    catch {rename ::hir::CensusBuildFull {}}
    rename ::hir::BuildFull ::hir::CensusBuildFull
    proc ::hir::BuildFull {nodes options given halt checkedVar {seeds {}}} {
        upvar 1 $checkedVar checked
        set hir [CensusBuildFull $nodes $options $given $halt checked $seeds]
        if {$checked} {
            ::dmcListen $hir
        }
        return $hir
    }
}

proc dmcListen {hir} {
    if {[dict get $hir diagnostics] ne ""} return
    set source [dict getdef $hir traitSource [dict getdef $hir checkedSource ""]]
    if {$source eq ""} return
    if {[catch {hir::discarded::findings $source} findings]} {
        dict incr ::dmcRows "ANALYSIS-FAILED\t[string range [string map {\n { } \t { }} $findings] 0 160]"
        return
    }
    foreach f $findings {
        if {[dict get $f reason] eq "dead"} {
            set e [dict get $f call]
        } else {
            set e [dict get $f exit]
        }
        set location [hir::originLocation $source [dict get $source exprs $e origin]]
        regexp {^(.*):(\d+):(\d+)$} $location -> path line col
        dict incr ::dmcRows "[file tail $path]:$line:$col\t[dict get $f reason]\t[hir::semantic::SourceName $source [dict get $f binding]]"
    }
}

proc dmcWrite {} {
    set f [open $::dmcOut w]
    dict for {key n} $::dmcRows {
        puts $f "[file tail $::dmcTest]\t$key\t$n"
    }
    close $f
}

dmcInstall
rename ::source ::dmcRealSource
proc ::source {args} {
    set code [catch {uplevel 1 [list ::dmcRealSource {*}$args]} result options]
    ::dmcInstall
    return -options $options $result
}
trace add execution exit enter {apply {args {::dmcWrite}}}
set argv0 $::dmcTest
::source $::dmcTest
dmcWrite
