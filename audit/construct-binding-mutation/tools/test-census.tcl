# test-census.tcl -- census.tcl's analysis inside one Tcl test file: every
# program the test file compiles through the front end (a source string of
# a test, a file it writes) is analyzed right after its checks, and the
# mutation sites are written to OUT.tsv (CONSTRUCT-BINDING-MUTATION-CENSUS-1.md,
# section 11).
#
#   tclsh9.0 audit/construct-binding-mutation/tools/test-census.tcl \
#       OUT.tsv tests/X.test ?TCLTEST-OPTION...?
#
# The test file runs as it always does (its results are its own; this tool
# only listens). A program's sites are keyed by their location, category,
# root binding and mechanism, so a template a test compiles many times is
# one row with its count.

set here [file dirname [file normalize [info script]]]
namespace eval cbm {}
set ::cbm::outFile [lindex $argv 0]
set ::cbm::testFile [file normalize [lindex $argv 1]]
set argv [lrange $argv 2 end]
set argc [llength $argv]
set ::cbmLibrary 1
source [file join $here census.tcl]
set ::cbm::rootDir [file dirname [file dirname [file dirname $here]]]

namespace eval cbm {
    variable testSites [dict create]
}

# The hook: every checked program is analyzed where the loop protocol's
# elaboration begins. A test file sources the compiler again, which
# redefines the procedure: `source` reinstalls the hook after every file.
proc cbm::Install {} {
    if {[info commands ::hir::iteration::Elaborate] eq ""} return
    if {[string first cbm:: [info body ::hir::iteration::Elaborate]] >= 0} return
    catch {rename ::hir::iteration::CensusElaborate {}}
    rename ::hir::iteration::Elaborate ::hir::iteration::CensusElaborate
    proc ::hir::iteration::Elaborate {hirVar} {
        upvar 1 $hirVar hir
        ::cbm::Listen $hir
        CensusElaborate hir
    }
}

proc cbm::Listen {hir} {
    variable sites
    variable testSites
    set sites [dict create]
    if {[dict get $hir diagnostics] ne ""} {
        # A rejected program (a test compiling leniently): what the census
        # asks of a program the compiler accepts does not apply.
        return
    }
    if {[catch {Analyze $hir program} message]} {
        dict incr testSites "ANALYSIS-FAILED\t[string range [string map {\n { } \t { }} $message] 0 120]"
        return
    }
    dict for {at site} $sites {
        dict with site {
            set key [join [list $at $category $name $path $mechanism $dead $used $result $reads $exit] \t]
        }
        dict incr testSites $key
    }
}

proc cbm::Write {} {
    variable testSites
    variable outFile
    variable testFile
    set f [open $outFile w]
    dict for {key n} $testSites {
        puts $f "[file tail $testFile]\t$key\t$n"
    }
    close $f
}

cbm::Install
rename ::source ::cbm::RealSource
proc ::source {args} {
    set code [catch {uplevel 1 [list ::cbm::RealSource {*}$args]} result options]
    ::cbm::Install
    return -options $options $result
}
trace add execution exit enter {apply {args {::cbm::Write}}}
set argv0 $::cbm::testFile
::source $::cbm::testFile
cbm::Write
