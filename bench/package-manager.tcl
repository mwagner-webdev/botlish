# package-manager.tcl -- the package manager's costs
# (PACKAGE-MANAGER-MILESTONE-1.md, "Tests and performance";
# PACKAGE-MANAGER-MILESTONE-2.md, "Performance").
#
#   tclsh9.0 bench/package-manager.tcl ?-runs N? ?-repository DIR?
#
# Measures, each the median of N runs (default 5) in a private temporary
# directory: reading and validating a botlish.json (in process); SHA-256
# throughput of both backends (the system's tool and the Tcl one) on a
# small, a native-sized and a large input, and the tool's start-up; packing
# the SDL3 package (two targets' bindings, thunk archives and the bundled
# libSDL3); a fresh `add` of sdlkit (its nested SDL3 package, the host's
# target view derived); a repeated `install` of that unchanged tree (views
# reused); preparing a second target's view, and preparing it again
# (reused); `verify` of it; `native plan`; a pure-Botlish package's add and
# install, which take no native step; and main.tcl's start-up without a
# package command (the compiler's own path, which the package manager must
# not slow down). The commands run as main.tcl, in child processes, as a
# user runs them. The repository is packed by tools/package-repository.tcl
# (which needs both targets' toolchains), or given (-repository DIR).

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root pm pm.tcl]
set runs 5
set given ""
foreach {option value} $argv {
    switch -- $option {
        -runs { set runs $value }
        -repository { set given [file normalize $value] }
        default { puts stderr "usage: tclsh9.0 bench/package-manager.tcl ?-runs N? ?-repository DIR?"; exit 2 }
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

proc hashWith {backend bytes} {
    set saved [array get ::env BOTLISH_PM_SHA256]
    set ::env(BOTLISH_PM_SHA256) $backend
    try {
        return [pm::sha256::hex $bytes]
    } finally {
        unset ::env(BOTLISH_PM_SHA256)
        array set ::env $saved
    }
}

try {
    set rows {}
    set bytes [encoding convertto utf-8 {{"schema": 1, "name": "sdlkit", "version": "0.1.0", "dependencies": {"sdl3": "0.1", "web": "0.4"}, "lock": {"sdl3": "0.1.0", "web": "0.4.2"}}}]
    pm::descriptor::fromBytes $bytes artifact warm
    set t [clock microseconds]
    for {set i 0} {$i < 1000} {incr i} {
        pm::descriptor::fromBytes $bytes artifact x
    }
    lappend rows "read and validate a botlish.json (in process)" [format "%.3f ms" [expr {([clock microseconds] - $t) / 1000.0 / 1000}]]
    # SHA-256: both backends, three sizes.
    lappend rows "SHA-256 backend for large inputs here" [join [pm::sha256::backend] ": "]
    foreach {label size} {"4 KiB" 4096 "1 MiB" 1048576 "16 MiB" 16777216 "64 MiB" 67108864} {
        set data [string repeat "0123456789abcdef" [expr {$size / 16}]]
        foreach backend {tcl tool} {
            if {$backend eq "tcl" && $size > 1048576} continue
            if {$backend eq "tool" && [lindex [pm::sha256::backend] 0] ne "tool"} continue
            set n [expr {$size > 1048576 ? 3 : $runs}]
            set ms [measure $n {hashWith $backend $data}]
            lappend rows "SHA-256 of $label, $backend" "$ms ms ([format %.1f [expr {$size / 1048576.0 / ($ms / 1000.0)}]] MiB/s)"
        }
    }
    # The repository: sdlkit and the SDL3 package (two targets).
    if {$given ne ""} {
        set repo $given
    } else {
        set repo [file join $work repo]
        exec [info nameofexecutable] [file join $root tools package-repository.tcl] $repo sdlkit sdl3
    }
    set artifact [file join $repo sdl3-0.2.0.botpkg]
    lappend rows "the SDL3 release: one artifact, two targets" "[format %.1f [expr {[file size $artifact] / 1048576.0}]] MiB packed"
    lappend rows "SHA-256 of the SDL3 artifact (in process, auto)" "[measure $runs {pm::sha256::file $artifact}] ms"
    lappend rows "package inspect of the SDL3 artifact (full validation)" "[measure $runs {run package inspect $artifact}] ms"
    # A fresh add of sdlkit, its SDL3 package and the host's view.
    set app [file join $work app]
    lappend rows "add sdlkit (2 instances, host view derived; fresh project)" \
        "[measure $runs {run add sdlkit -project $app -repository $repo} {file delete -force $app; file mkdir $app}] ms"
    lappend rows "install, unchanged tree and view (reused)" \
        "[measure $runs {run install -project $app}] ms"
    lappend rows "install -target linux-aarch64 (second view derived)" \
        "[measure $runs {run install -project $app -target linux-aarch64} {catch {run install -project $app -drop-target linux-aarch64}}] ms"
    lappend rows "install -target linux-aarch64 again (both reused)" \
        "[measure $runs {run install -project $app -target linux-aarch64}] ms"
    lappend rows "verify, against the record and views" \
        "[measure $runs {run verify -project $app}] ms"
    lappend rows "verify -target linux-x86_64 (native plan verified again)" \
        "[measure $runs {run verify -project $app -target linux-x86_64}] ms"
    lappend rows "native plan (host)" "[measure $runs {run native plan -project $app}] ms"
    set clone [file join $work clone]
    lappend rows "install into a fresh copy of the project (offline)" \
        "[measure $runs {run install -project $clone -repository $repo} {file delete -force $clone; file mkdir $clone; file copy [file join $app botlish.json] $clone}] ms"
    # A pure-Botlish package: no target, no view, no native step.
    set pure [file join $work pure]
    file mkdir $pure
    set f [open [file join $pure botlish.json] w]
    puts $f {{"schema": 1, "name": "web", "version": "1.0.0"}}
    close $f
    set f [open [file join $pure web.bot] w]
    puts $f "fn hello() -> str:\n    \"hello\""
    close $f
    set pureRepo [file join $work pure-repo]
    run package pack $pure -out $pureRepo
    set papp [file join $work papp]
    lappend rows "add a pure-Botlish package (fresh project)" \
        "[measure $runs {run add web -project $papp -repository $pureRepo} {file delete -force $papp; file mkdir $papp}] ms"
    lappend rows "install, unchanged pure-Botlish tree" "[measure $runs {run install -project $papp}] ms"
    # The compiler's own start-up path.
    lappend rows "main.tcl with no arguments (usage; no package command)" "[measure $runs {run}] ms"
    lappend rows "main.tcl -version (loads the compiler)" "[measure $runs {run -version}] ms"
    foreach {what value} $rows {
        puts [format "%-60s %s" $what $value]
    }
} finally {
    file delete -force $work
}
