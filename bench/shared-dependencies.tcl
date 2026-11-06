# shared-dependencies.tcl -- the costs of the application's one dependency
# graph (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/shared-dependencies.tcl ?-root DIR? ?-repeat N? ?-scenarios NAMES?
#
# Synthetic package universes, written as ordinary .botpkg artifacts into a
# repository, then, for each scenario, in a child process of the checkout
# ROOT (this one by default; another checkout -- main before this milestone
# -- for a baseline):
#
#   install   `install` of a fresh application from botlish.json (as
#             main.tcl runs it: pm::cli::main, the package manager loaded
#             included; resolution, every artifact read and validated, the
#             tree written), its wall time and the process's peak resident
#             memory;
#   again     `main.tcl install` once more (nothing to do: the record says
#             everything is installed exactly so);
#   instances the package directories the installation holds;
#   compile   the front end over the installed tree (surface::readProgramFile
#             of a program importing every dependency of the application).
#
# Scenarios (N packages each):
#
#   wide     the application over N independent packages
#   shared   the application over N packages that all depend on one
#   chain    a chain of N packages, each over the next
#   diamond  N/2 layers of two packages, each over both of the next layer's
#            (2^(N/2) dependency paths to the last layer)
#   subgraph four packages over the same chain of N-4
#   conflict-early, conflict-late   wide's N packages, the first (or last)
#            of them locking another release of a shared one
#
# The median of REPEAT runs is printed (milliseconds; memory in MiB). A
# scenario the checkout refuses (a limit, a conflict) prints its error.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname $here]
set options [dict create -root $checkout -repeat 3 -scenarios {wide shared chain diamond subgraph conflict-early conflict-late} -n {}]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set root [file normalize [dict get $options -root]]
source [file join $checkout pm pm.tcl]

set scratch [file tempdir botlish-bench-shared]

proc writeBytes {path bytes} {
    file mkdir [file dirname $path]
    set channel [open $path wb]
    puts -nonewline $channel $bytes
    close $channel
}

# Writes the release NAME 1.0.0 (or VERSION) over DEPS (NAME -> lock) into
# REPO.
proc release {repo name deps {version 1.0.0}} {
    set requests [concat {*}[lmap {d v} $deps {list $d [join [lrange [split $v .] 0 1] .]}]]
    set descriptor [dict create schema 1 name $name version $version dependencies $requests lock $deps sources {}]
    set body ""
    foreach dep [lsort [dict keys $deps]] { append body "import $dep\n" }
    if {[dict size $deps]} {
        set value [join [lmap d [lsort [dict keys $deps]] {string cat $d "::v()"}] { + }]
    } else {
        set value 1
    }
    append body "\nfn v() -> int:\n    $value\n"
    writeBytes [file join $repo $name-$version.botpkg] [pm::archive::bytes [dict create \
        botlish.json [pm::descriptor::encode $descriptor 0] $name.bot [encoding convertto utf-8 $body]]]
}

# The universe of SCENARIO with N packages: writes REPO, returns the
# application's dependencies (NAME -> lock).
proc scenario {scenario n repo} {
    set app [dict create]
    switch -- $scenario {
        wide {
            for {set i 0} {$i < $n} {incr i} {
                release $repo p$i {}
                dict set app p$i 1.0.0
            }
        }
        shared {
            release $repo base {}
            for {set i 0} {$i < $n} {incr i} {
                release $repo p$i {base 1.0.0}
                dict set app p$i 1.0.0
            }
        }
        chain {
            for {set i [expr {$n - 1}]} {$i >= 0} {incr i -1} {
                if {$i == $n - 1} {
                    release $repo c$i {}
                } else {
                    release $repo c$i [list c[expr {$i + 1}] 1.0.0]
                }
            }
            dict set app c0 1.0.0
        }
        diamond {
            set layers [expr {$n / 2}]
            for {set l [expr {$layers - 1}]} {$l >= 0} {incr l -1} {
                foreach side {a b} {
                    if {$l == $layers - 1} {
                        release $repo d${l}$side {}
                    } else {
                        set next [expr {$l + 1}]
                        release $repo d${l}$side [list d${next}a 1.0.0 d${next}b 1.0.0]
                    }
                }
            }
            dict set app d0a 1.0.0
            dict set app d0b 1.0.0
        }
        subgraph {
            set m [expr {$n - 4}]
            for {set i [expr {$m - 1}]} {$i >= 0} {incr i -1} {
                if {$i == $m - 1} {
                    release $repo s$i {}
                } else {
                    release $repo s$i [list s[expr {$i + 1}] 1.0.0]
                }
            }
            foreach top {t0 t1 t2 t3} {
                release $repo $top {s0 1.0.0}
                dict set app $top 1.0.0
            }
        }
        conflict-early - conflict-late {
            release $repo base {}
            release $repo base {} 2.0.0
            set odd [expr {$scenario eq "conflict-early" ? 0 : $n - 1}]
            for {set i 0} {$i < $n} {incr i} {
                set lock 1.0.0
                if {$i == $odd} { set lock 2.0.0 }
                release $repo p[format %04d $i] [list base $lock]
                dict set app p[format %04d $i] 1.0.0
            }
        }
    }
    return $app
}

# A fresh application over APP (NAME -> lock): its directory.
proc application {dir app} {
    file mkdir $dir
    set requests [concat {*}[lmap {d v} $app {list $d [list str [join [lrange [split $v .] 0 1] .]]}]]
    set locks [concat {*}[lmap {d v} $app {list $d [list str $v]}]]
    writeBytes [file join $dir botlish.json] [pm::json::encode [list obj [list schema {num 1} \
        dependencies [list obj $requests] lock [list obj $locks]]]]
    set main ""
    foreach name [lsort [dict keys $app]] { append main "import $name\n" }
    append main "\n[join [lmap n [lsort [dict keys $app]] {string cat $n "::v()"}] { + }]\n"
    writeBytes [file join $dir main.bot] [encoding convertto utf-8 $main]
    return $dir
}

# The child process's measurement of COMMAND in ROOT: {ms MS rss MIB status
# S out OUT}.
proc measure {script} {
    set probe [file join $::scratch probe-[incr ::probes].tcl]
    writeBytes $probe [encoding convertto utf-8 $script]
    set status 0
    if {[catch {exec [info nameofexecutable] $probe 2>@1} out]} { set status 1 }
    set result [dict create status $status out $out ms "" rss ""]
    regexp {MS ([0-9.]+)} $out -> ms
    regexp {RSS ([0-9]+)} $out -> rss
    if {[info exists ms]} { dict set result ms $ms }
    if {[info exists rss]} { dict set result rss [format %.1f [expr {$rss / 1024.0}]] }
    return $result
}

# The package command ARGS of the checkout ROOT, run as main.tcl runs it
# (pm::cli::main) in the measuring process: its time, and the process's
# peak resident memory.
proc pmScript {root args} {
    return [string map [list @ROOT $root @ARGS [list $args]] {
        set start [clock microseconds]
        source [file join @ROOT pm pm.tcl]
        set status [pm::cli::main @ARGS botlish]
        puts "MS [format %.1f [expr {([clock microseconds] - $start) / 1000.0}]]"
        set f [open /proc/self/status]; set s [read $f]; close $f
        regexp {VmHWM:\s+([0-9]+)} $s -> rss
        puts "RSS $rss"
        exit $status
    }]
}

proc compileScript {root app} {
    return [string map [list @ROOT $root @APP $app] {
        source [file join @ROOT surface surface.tcl]
        set start [clock microseconds]
        surface::readProgramFile [file join @APP main.bot] -warnings off -cache ""
        puts "MS [format %.1f [expr {([clock microseconds] - $start) / 1000.0}]]"
        set f [open /proc/self/status]; set s [read $f]; close $f
        regexp {VmHWM:\s+([0-9]+)} $s -> rss
        puts "RSS $rss"
    }]
}

proc median {values} {
    set values [lsort -real [lmap v $values {if {$v eq ""} continue; set v}]]
    if {$values eq ""} { return - }
    return [lindex $values [expr {[llength $values] / 2}]]
}

set sizes [dict create wide {10 100 300} shared {10 100 300} chain {10 30 100} diamond {8 16 20} \
    subgraph {10 30 100} conflict-early {100} conflict-late {100}]
if {[dict get $options -n] ne ""} {
    dict for {s -} $sizes { dict set sizes $s [dict get $options -n] }
}
puts "checkout: $root"
puts [format "%-15s %5s %10s %9s %10s %9s %10s %9s  %s" scenario N install(ms) pm(MiB) again(ms) instances compile(ms) fe(MiB) note]
foreach scenario [dict get $options -scenarios] {
    foreach n [dict get $sizes $scenario] {
        set repo [file join $scratch $scenario-$n repo]
        set app [scenario $scenario $n $repo]
        set installs {}; set pmRss {}; set agains {}; set compiles {}; set rss {}; set note ""; set instances -
        for {set r 0} {$r < [dict get $options -repeat]} {incr r} {
            set dir [application [file join $scratch $scenario-$n app-$r] $app]
            set m [measure [pmScript $root install -project $dir -repository $repo]]
            if {[dict get $m status] != 0} {
                set note "refused: [string range [lindex [split [string trim [dict get $m out]] \n] 0] 0 110]"
                lappend installs [dict get $m ms]
                break
            }
            lappend installs [dict get $m ms]
            lappend pmRss [dict get $m rss]
            lappend agains [dict get [measure [pmScript $root install -project $dir]] ms]
            set instances [llength [split [string trim [exec find [file join $dir .bot_modules] -name botlish.json]] \n]]
            set c [measure [compileScript $root $dir]]
            lappend compiles [dict get $c ms]
            lappend rss [dict get $c rss]
            file delete -force $dir
        }
        puts [format "%-15s %5d %10s %9s %10s %9s %10s %9s  %s" $scenario $n [median $installs] [median $pmRss] [median $agains] $instances \
            [median $compiles] [median $rss] $note]
        flush stdout
        file delete -force [file join $scratch $scenario-$n]
    }
}
file delete -force $scratch
