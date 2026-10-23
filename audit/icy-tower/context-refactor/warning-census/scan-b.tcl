# scan-b.tcl -- applies the warning candidate's measuring instrument,
# audit/icy-tower/context-refactor/tools/escape-candidates.tcl, to partition
# B's captured programs (extract-tests.tcl's and extract-fuzz.tcl's output
# directories), once per distinct program.
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/scan-b.tcl \
#       -work DIR CAPTURE-DIR... > RAW.tsv
#
# DIR is an existing, private, empty directory for the private standard
# libraries some programs need; the caller removes it. Each CAPTURE-DIR is
# named after its set (a test file's stem, or a fuzzer's directory name
# under f/: the parent directory's name `f` marks a fuzzer).
#
# A program is the set of files captured for it (lib/, a private library
# overlay, included) and its target; captures with equal programs are one
# unit, with every test (or fuzzer index) that compiled it. The target is
# the capture's own -target when the test or fuzzer gave one, else the
# platform an import of any of its files names
# (surface::modules::PlatformTarget: darwin -> macos-aarch64, windows ->
# windows-x86_64), else the host's. A program with a lib/ overlay is compiled
# with $::core::libraryDir set to a copy of stdlib/ with the overlay on top,
# as the test's withPrivateLibrary had it. Both test fixtures
# (core::cabi::installTestFixture, installBorrowFixture) are installed, as
# the test files and fuzzers that import ffi_fixture install them.
#
# The instrument is sourced, not copied: escape::Program compiles each unit
# (front end only, -warnings off, no cache, -target) and returns its sites
# and statuses; an execution trace on surface::readProgramFile keeps the HIR
# it built for the module facts (hir::activate first). Output,
# tab-separated, a location's file spelled SET:ID/PATH (the first capture
# of the unit; a private library's file SET:ID/lib/PATH, stdlib/'s
# repository-relative):
#
#   UNIT  UID  SET  SOURCES  ENTRY  TARGET  EXPECT  ok|error  SECONDS
#         ERRORCODE  MESSAGE(first line)
#   SITE  UID  BUCKET  LOCATION  FROM  TO  RULES  WHAT
#   MOD   UID  NS  STATUS  CONTEXTS  PTR-FUNCTIONS  VIEW-FUNCTIONS
#
# SOURCES: the tests (TEST [CONSTRAINTS]) or FUZZER:SEED:INDEX that
# compiled the program, `;`-separated. EXPECT: the test's own compilation
# outcome (ok, `diagnostics K: KINDS`, `error KIND`, `not compiled ...`) or
# the fuzzer model's verdict. A MOD line per module the unit compiled that
# declares a context or has a function whose signature holds a C address
# (ptr) or a native view or edit (view): NAME(p) a parameter, NAME(r) the
# result.

set scanHere [file dirname [file normalize [info script]]]
set scanRoot [file normalize [file join $scanHere .. .. .. ..]]
set scanArgs $argv
set argv {}
set argc 0
# Defines escape::* (and, with no files, prints an empty "totals:" line to
# stdout: dropped by the reader, which reads UNIT/SITE/MOD lines only).
source [file join $scanHere .. tools escape-candidates.tcl]
core::cabi::installTestFixture
core::cabi::installBorrowFixture

namespace eval scan {
    variable hir ""
    variable realLib $::core::libraryDir
}
proc scan::Capture {command code result op} {
    variable hir
    if {$code == 0} {
        set hir $result
    }
}
trace add execution surface::readProgramFile leave ::scan::Capture

proc scan::Read {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc scan::Files {dir} {
    set result {}
    set queue [list $dir]
    while {$queue ne {}} {
        set queue [lassign $queue d]
        foreach entry [lsort [glob -nocomplain -directory $d *]] {
            if {[file isdirectory $entry]} {
                lappend queue $entry
            } else {
                lappend result [string range $entry [string length $dir/] end]
            }
        }
    }
    return [lsort $result]
}

proc scan::Clean {text} {
    return [string map {\t { } \n { }} $text]
}

proc scan::Kinds {types} {
    set kinds {}
    foreach t $types {
        if {$t eq ""} continue
        if {[escape::Holds $t carry]} { lappend kinds ptr }
        if {[escape::Holds $t view]} { lappend kinds view }
    }
    return [lsort -unique $kinds]
}

proc scan::Modules {hir} {
    hir::activate $hir
    set lines {}
    set status [dict create]
    if {[dict exists $hir direct units]} {
        dict for {ns u} [dict get $hir direct units] {
            dict set status $ns [dict get $u status]
        }
    }
    set contexts [dict create]
    foreach entry [hir::sourceTypes $hir] {
        if {![dict exists $entry id]} continue
        set eid [dict get $entry id]
        set i [string last :: $eid]
        set ns [expr {$i < 0 ? "" : [string range $eid 0 [expr {$i - 1}]]}]
        if {[dict exists $entry context] && [dict get $entry context]} {
            dict lappend contexts $ns [string range $eid [expr {$i < 0 ? 0 : $i + 2}] end]
        }
    }
    set scopes [dict getdef $hir modules {}]
    foreach {ns scope} [concat [list entry ""] $scopes] {
        if {$ns eq "entry"} {
            set bindings {}
            if {[dict exists $hir top] && [dict exists $hir scopes [dict get $hir top] bindings]} {
                set bindings [dict get $hir scopes [dict get $hir top] bindings]
            }
        } else {
            set bindings [dict get $hir scopes $scope bindings]
        }
        set ptrFns {}
        set viewFns {}
        foreach b $bindings {
            set by [dict get $hir bindings $b declaredBy]
            if {$by eq "" || ![dict exists $hir exprs $by value]} continue
            set v [dict get $hir exprs $by value]
            if {$v eq "" || [dict get $hir exprs $v kind] ne "block"} continue
            set type [hir::typeOf $hir $v]
            set name [hir::semantic::CallableName $hir $v]
            set marks {}
            foreach {kinds where} [list [Kinds [list [lindex $type 3]]] r [Kinds [dict getdef [lindex $type 4] args {}]] p] {
                foreach k $kinds { dict lappend marks $k $where }
            }
            if {[dict exists $marks ptr]} { lappend ptrFns "$name\([join [dict get $marks ptr] ,]\)" }
            if {[dict exists $marks view]} { lappend viewFns "$name\([join [dict get $marks view] ,]\)" }
        }
        set key [expr {$ns eq "entry" ? "" : $ns}]
        set cs [dict getdef $contexts $key {}]
        if {$cs eq {} && $ptrFns eq {} && $viewFns eq {}} continue
        lappend lines [join [list $ns [dict getdef $status $key ""] [join $cs ,] [join $ptrFns " "] [join $viewFns " "]] \t]
    }
    return $lines
}

# The private library of overlay directory LIB: a copy of stdlib/ with LIB's
# files on top, made once per distinct overlay under WORK.
proc scan::Library {work lib key} {
    variable realLib
    variable libraries
    if {[info exists libraries($key)]} {
        return $libraries($key)
    }
    set dir [file join $work lib[array size libraries]]
    file mkdir $dir
    foreach entry [glob -nocomplain -directory $realLib *] {
        file copy -force $entry $dir
    }
    foreach rel [Files $lib] {
        file mkdir [file dirname [file join $dir $rel]]
        file copy -force [file join $lib $rel] [file join $dir $rel]
    }
    set libraries($key) $dir
    return $dir
}

set work ""
set dirs {}
for {set i 0} {$i < [llength $scanArgs]} {incr i} {
    set a [lindex $scanArgs $i]
    if {$a eq "-work"} {
        set work [file normalize [lindex $scanArgs [incr i]]]
    } else {
        lappend dirs [file normalize $a]
    }
}
if {$work eq "" || ![file isdirectory $work]} {
    error "-work DIR: an existing directory"
}

# The distinct programs, in capture order.
set units [dict create]
foreach dir $dirs {
    set set [file tail $dir]
    set f [open [file join $dir captures.tsv] r]
    fconfigure $f -encoding utf-8
    set lines [split [string trimright [read $f] \n] \n]
    close $f
    foreach line $lines {
        if {$line eq ""} continue
        lassign [split $line \t] id test constraints kind entry options library outcome source
        if {$kind eq "repo"} {
            puts [join [list REPO $set:$id [scan::Clean $test] $entry [scan::Clean $outcome]] \t]
            continue
        }
        set progDir [file join $dir programs $id]
        set files [scan::Files $progDir]
        set target ""
        set o [lsearch -exact $options -target]
        if {$o >= 0} {
            set target [lindex $options [expr {$o + 1}]]
        }
        if {$target eq ""} {
            foreach rel $files {
                if {[file extension $rel] ne ".bot" || [string match lib/* $rel]} continue
                set t [surface::modules::PlatformTarget [scan::Read [file join $progDir $rel]]]
                if {$t ne ""} {
                    set target $t
                    break
                }
            }
        }
        set key [list $target [file tail $entry]]
        foreach rel $files {
            lappend key $rel [scan::Read [file join $progDir $rel]]
        }
        set label [expr {$kind eq "fuzz" ? $test : ($constraints eq "" ? $test : "$test \[$constraints\]")}]
        if {[dict exists $units $key]} {
            set known [dict get $units $key]
            if {$label ni [dict get $known sources]} { dict lappend known sources $label }
            if {$outcome ni [dict get $known expects]} { dict lappend known expects $outcome }
            dict set units $key $known
            continue
        }
        dict set units $key [dict create uid $set:$id set $set dir $progDir entry [file join $dir $entry] \
            target $target sources [list $label] expects [list $outcome] lib [file isdirectory [file join $progDir lib]]]
    }
}

fconfigure stdout -buffering line
dict for {key unit} $units {
    dict with unit {}
    set saved $::core::libraryDir
    set map [list $dir/ "$uid/" $::scanRoot/ ""]
    if {$lib} {
        set ::core::libraryDir [scan::Library $work [file join $dir lib] [lrange $key 2 end]]
        set map [linsert $map 0 $::core::libraryDir/ "$uid/lib/"]
    }
    set scan::hir ""
    set start [clock milliseconds]
    set failed [catch {escape::Program $entry $target} result options]
    set seconds [format %.1f [expr {([clock milliseconds] - $start) / 1000.0}]]
    set ::core::libraryDir $saved
    set head [list $uid $set [scan::Clean [join $sources {; }]] [string range $entry [string length $dir/] end] \
        $target [scan::Clean [join $expects {; }]]]
    if {$failed} {
        set message [string map $map [lindex [split $result \n] 0]]
        puts [join [list UNIT {*}$head error $seconds [dict getdef $options -errorcode ""] [scan::Clean $message]] \t]
        continue
    }
    lassign $result hits status
    puts [join [list UNIT {*}$head ok $seconds "" ""] \t]
    foreach hit $hits {
        lassign $hit bucket where v u rules what
        set where [string map $map $where]
        puts [join [list SITE $uid $bucket $where $v $u [join $rules ,] $what] \t]
    }
    if {$scan::hir ne ""} {
        if {[catch {scan::Modules $scan::hir} lines]} {
            puts [join [list MODERROR $uid [scan::Clean [lindex [split $lines \n] 0]]] \t]
        } else {
            foreach l $lines { puts "MOD\t$uid\t$l" }
        }
    }
}
