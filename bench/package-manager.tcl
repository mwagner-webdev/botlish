# package-manager.tcl -- the package manager's costs
# (PACKAGE-MANAGER-MILESTONE-1.md, "Tests and performance").
#
#   tclsh9.0 bench/package-manager.tcl ?-runs N?
#
# Measures, each the median of N runs (default 5) in a private temporary
# directory: reading and validating a botlish.json (in process), SHA-256
# throughput, packing the SDL3 binding package (62 files), a fresh `add` of
# sdlkit (with its nested SDL3 binding) from a local repository, a repeated
# `install` of that unchanged tree, `verify` of it with and without its
# artifacts, and main.tcl's start-up without a package command (the
# compiler's own path, which the package manager must not slow down). The
# commands run as main.tcl, in child processes, as a user runs them.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root pm pm.tcl]
set runs 5
foreach {option value} $argv {
    switch -- $option {
        -runs { set runs $value }
        default { puts stderr "usage: tclsh9.0 bench/package-manager.tcl ?-runs N?"; exit 2 }
    }
}
set main [file join $root main.tcl]
set work [file tempdir botlish-pm-bench]

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

# Milliseconds of SCRIPT, the median of N runs; SETUP runs before each.
proc measure {n script {setup ""}} {
    set times {}
    for {set i 0} {$i < $n} {incr i} {
        uplevel 1 $setup
        set t [clock microseconds]
        uplevel 1 $script
        lappend times [expr {([clock microseconds] - $t) / 1000.0}]
    }
    return [format %.1f [median $times]]
}

proc run {args} {
    exec [info nameofexecutable] $::main {*}$args
}

try {
    set rows {}
    # A descriptor, in process.
    set bytes [encoding convertto utf-8 {{"schema": 1, "name": "sdlkit", "version": "0.1.0", "dependencies": {"sdl3": "0.1", "web": "0.4"}, "lock": {"sdl3": "0.1.0", "web": "0.4.2"}}}]
    pm::descriptor::fromBytes $bytes artifact warm
    set t [clock microseconds]
    for {set i 0} {$i < 1000} {incr i} {
        pm::descriptor::fromBytes $bytes artifact x
    }
    lappend rows "read and validate a botlish.json (in process)" [format "%.3f ms" [expr {([clock microseconds] - $t) / 1000.0 / 1000}]]
    set data [string repeat "0123456789abcdef" 65536]
    set ms [measure 3 {pm::sha256::hex $data}]
    lappend rows "SHA-256 of 1 MiB (in process)" "$ms ms ([format %.2f [expr {1000.0 / $ms}]] MiB/s)"
    # The repository: sdlkit and the SDL3 binding.
    set repo [file join $work repo]
    exec [info nameofexecutable] [file join $root tools package-repository.tcl] $repo sdlkit sdl3
    # Packing the binding package (staged once).
    set stage [file join $work sdl3]
    file mkdir $stage
    file copy [file join $root packages sdl3 botlish.json] $stage
    file copy [file join $root generated c sdl3 linux-x86_64 sdl3] [file join $stage sdl3]
    set out [file join $work out]
    lappend rows "package pack: the SDL3 binding (62 files, 474 KB)" \
        "[measure $runs {run package pack $stage -out $out -force}] ms"
    # A fresh add of sdlkit and its binding.
    set app [file join $work app]
    lappend rows "add sdlkit from a repository (2 instances, fresh project)" \
        "[measure $runs {run add sdlkit -project $app -repository $repo} {file delete -force $app; file mkdir $app}] ms"
    lappend rows "install, unchanged tree (warm: no artifact read)" \
        "[measure $runs {run install -project $app}] ms"
    lappend rows "verify, against the installation record" \
        "[measure $runs {run verify -project $app}] ms"
    lappend rows "verify, against the artifacts (-repository)" \
        "[measure $runs {run verify -project $app -repository $repo}] ms"
    set clone [file join $work clone]
    lappend rows "install into a fresh copy of the project (offline)" \
        "[measure $runs {run install -project $clone -repository $repo} {file delete -force $clone; file mkdir $clone; file copy [file join $app botlish.json] $clone}] ms"
    # The compiler's own start-up path.
    lappend rows "main.tcl with no arguments (usage; no package command)" "[measure $runs {run}] ms"
    lappend rows "main.tcl -version (loads the compiler)" "[measure $runs {run -version}] ms"
    foreach {what value} $rows {
        puts [format "%-58s %s" $what $value]
    }
} finally {
    file delete -force $work
}
