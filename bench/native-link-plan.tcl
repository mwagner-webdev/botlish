# native-link-plan.tcl -- what the native link plan costs
# (NATIVE-LINK-PLAN-MILESTONE-1.md, "Link time and executable size").
#
#   tclsh9.0 bench/native-link-plan.tcl ?-runs N? ?-linkers "rustc system"?
#
# Builds the C fixture of tests/native-link-plan.test (a static archive and a
# shared library of one name) with the host's C toolchain in a temporary
# directory, then measures, as medians of N runs:
#
#   * the front end: a program with no link declaration, with 50 ordinary
#     ones and with 50 static ones (25 with archive paths) -- the cost of
#     parsing, merging and recording the plan;
#   * the driver's resolution (botlish-native link-plan, NIR already
#     written): an archive declared at a path, one found on the -L path, and
#     one found nowhere (the refusal, after asking the C driver and GNU ld
#     for the toolchain's own directories);
#   * the link, per linker: the program linked with the shared library
#     (`extern c library`) and with the archive (`static at`): wall time,
#     the executable's size and dynamic libraries, and its run's wall time
#     (startup, the shared library's loading included).
#
# Prints a Markdown table per part. Linux and macOS (ldd / otool -L).

source [file join [file dirname [file dirname [file normalize [info script]]]] tests ctoolchain.tcl]
set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set options [dict create -runs 5 -linkers {rustc system}]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set runs [dict get $options -runs]
set work [file tempdir botlish-link-plan-bench]

proc write {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    return $path
}

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

# Median milliseconds of SCRIPT, run in the caller.
proc timed {script} {
    global runs
    set times {}
    for {set i 0} {$i < $runs} {incr i} {
        set t [clock microseconds]
        uplevel 1 $script
        lappend times [expr {([clock microseconds] - $t) / 1000.0}]
    }
    return [format %.1f [median $times]]
}

proc dynamic {exe} {
    if {$::tcl_platform(os) eq "Darwin"} {
        set lines [lrange [split [exec otool -L $exe] \n] 1 end]
    } else {
        set lines [split [exec ldd $exe] \n]
    }
    return [llength $lines]
}

try {
    set fixture [file join $work fixture]
    file mkdir $fixture [file join $work shared]
    write [file join $work src nlp.c] "int nlp_tag(void) { return 1; }\nint nlp_add(int a, int b) { return a + b; }\n"
    ctool::staticLibrary $fixture nlp [file join $work src nlp.c]
    set shared [lindex [ctool::sharedLibrary [file join $work shared] nlp [file join $work src nlp.c]] 0]
    set binding "import std::ffi::c\nextern c fn add named \"nlp_add\"(a: std::ffi::c::Int, b: std::ffi::c::Int) -> std::ffi::c::Int\n"

    puts "## Front end (median of $runs, ms: parse, load, build, check)\n"
    puts "| program | ms |"
    puts "|---|---:|"
    set none [write [file join $work fe none.bot] "1 + 1\n"]
    set ordinary ""
    set static ""
    for {set i 0} {$i < 50} {incr i} {
        append ordinary "extern c library \"lib$i\"\n"
        if {$i % 2} {
            append static "extern c library \"lib$i\" static\n"
        } else {
            append static "extern c library \"lib$i\" static at \"native/lib$i.a\"\n"
        }
    }
    write [file join $work fe ordinary.bot] "${ordinary}1 + 1\n"
    write [file join $work fe static.bot] "${static}1 + 1\n"
    foreach name {none ordinary static} {
        set path [file join $work fe $name.bot]
        puts "| $name ([expr {$name eq "none" ? 0 : 50}] declarations) | [timed {surface::readProgramFile $path -warnings off -cache ""}] |"
    }

    puts "\n## The driver's resolution (median of $runs, ms: botlish-native link-plan)\n"
    puts "| archive | ms | result |"
    puts "|---|---:|---|"
    set app [file join $work app]
    file mkdir [file join $app native]
    file copy [file join $fixture [ctool::staticName nlp]] [file join $app native]
    foreach {case declaration dirs} [list \
            declared "extern c library \"nlp\" static at \"native/[ctool::staticName nlp]\"" {} \
            "on the -L path" "extern c library \"nlp\" static" [list $fixture] \
            "nowhere (refused)" "extern c library \"nlpnone\" static" {}] {
        write [file join $app main.bot] "${binding}$declaration\nadd(1, 2)\n"
        set hir [surface::readProgramFile [file join $app main.bot] -warnings off -cache ""]
        set nir [native::nir $hir]
        set result ""
        set ms [timed {
            native::withLinkDirs $dirs {
                set result [lindex [native::Driver link-plan $nir] 0]
            }
        }]
        puts "| $case | $ms | [lrange $result 0 1] |"
    }

    foreach linker [dict get $options -linkers] {
        puts "\n## The link, $linker linker (median of $runs)\n"
        puts "| declaration | link ms | executable bytes | dynamic libraries | startup ms |"
        puts "|---|---:|---:|---:|---:|"
        foreach {case declaration dirs} [list \
                "extern c library (shared)" "extern c library \"nlp\"" [list [file dirname $shared]] \
                "static at (archive)" "extern c library \"nlp\" static at \"native/[ctool::staticName nlp]\"" {}] {
            write [file join $app main.bot] "${binding}$declaration\nadd(1, 2)\n"
            set hir [surface::readProgramFile [file join $app main.bot] -warnings off -cache ""]
            set exe ""
            set ::env(BOTLISH_NATIVE_LINKER) $linker
            set ms [timed {
                native::withLinkDirs $dirs {
                    set exe [native::executable $hir [file join $work out-$linker]]
                }
            }]
            unset ::env(BOTLISH_NATIVE_LINKER)
            # The executable's whole run (it adds two numbers): its start,
            # the shared library's loading included.
            set libraryPath [list LD_LIBRARY_PATH [file dirname $shared] DYLD_LIBRARY_PATH [file dirname $shared]]
            set startup [timed {exec env {*}[lmap {k v} $libraryPath {string cat $k=$v}] $exe}]
            puts "| $case | $ms | [file size $exe] | [dynamic $exe] | $startup |"
        }
    }
} finally {
    file delete -force $work
}
