# macos-mutate.tcl -- the macOS mode of audit/icy-tower/mutate.tcl
# (`-macos 1`; ICY-TOWER-MACOS-MILESTONE-1.md, "Mutation testing"): the
# mutants of audit/icy-tower/macos-mutants.txt, each built into a private
# tree and met by the detector its `??` line names. Sourced by mutate.tcl,
# which reads the options; its mutants file format, parser and conventions
# are mutate.tcl's (audit/golden/tools/tree.tcl's readMutants).

namespace eval icymacos {}

# NAME -> {DETECTOR REGEX} of the mutants file PATH.
proc icymacos::readDetectors {path} {
    set detectors [dict create]
    set name ""
    foreach line [split [goldentools::readFile $path] \n] {
        if {[regexp {^@@ (\S+) } $line -> name]} continue
        if {[regexp {^\?\? (\S+) ?(.*)$} $line -> detector regex] && $name ne ""} {
            dict set detectors $name [list $detector $regex]
        }
    }
    return $detectors
}

# Runs CMD (a list) with the environment variables of the dict ENV set, from
# directory CWD when given: {STATUS OUTPUT}, standard error with standard
# output.
proc icymacos::run {cmd {env {}} {cwd ""}} {
    set saved [dict create]
    dict for {k v} $env {
        dict set saved $k [expr {[info exists ::env($k)] ? [list $::env($k)] : {}}]
        set ::env($k) $v
    }
    set here [pwd]
    try {
        if {$cwd ne ""} { cd $cwd }
        set status [catch {exec {*}$cmd 2>@1} output options]
        if {$status} {
            set code [dict get $options -errorcode]
            set status [expr {[lindex $code 0] eq "CHILDSTATUS" ? [lindex $code 2] : 1}]
        }
        return [list $status $output]
    } finally {
        cd $here
        dict for {k old} $saved {
            if {[llength $old]} { set ::env($k) [lindex $old 0] } else { unset ::env($k) }
        }
    }
}

# A private tree for mutant NAME under WORK: examples/games/icy-tower and
# tests/platform/sdl3-static-macos.sh copied (TEXTS, path -> text, replace
# their files), the repository's tools/ and generated/ linked. Its root.
proc icymacos::tree {work name root texts} {
    set tree [file join $work t-$name]
    file mkdir [file join $tree examples games] [file join $tree tests platform]
    file copy [file join $root examples games icy-tower] [file join $tree examples games icy-tower]
    file copy [file join $root tests platform sdl3-static-macos.sh] [file join $tree tests platform sdl3-static-macos.sh]
    foreach d {tools generated} {
        file link -symbolic [file join $tree $d] [file join $root $d]
    }
    dict for {path text} $texts {
        goldentools::writeFile [file join $tree $path] $text
    }
    file attributes [file join $tree examples games icy-tower build-macos.sh] -permissions 0755
    return $tree
}

# build-macos.sh of TREE into OUT with the stage STAGE and the binding
# BINDING (and ENV's other variables): {STATUS OUTPUT}.
proc icymacos::build {ctx tree out binding stage {env {}}} {
    set env [dict merge [dict create ICY_TOWER_BOTLISH [dict get $ctx app] ICY_TOWER_BINDING_FROM $binding \
        ICY_TOWER_SDL3_PREFIX [dict get $ctx prefix] ICY_TOWER_STAGE $stage] $env]
    run [list bash [file join $tree examples games icy-tower build-macos.sh] $out] $env [dict get $ctx work]
}

# The detector DETECTOR on the build of TREE (with BINDING) for NAME:
# {VERDICT TEXT}, VERDICT one of pass (the detector held), fail (it failed:
# TEXT says why), blocked (the environment did not let it run), unbuilt
# (the mutant did not build, which a detector other than the build cannot
# judge).
proc icymacos::detect {ctx name detector tree binding} {
    set work [dict get $ctx work]
    set out [file join $work o-$name]
    set stage [file join $work "s-$name" "Stäged Gäme"]
    lassign [build $ctx $tree $out $binding $stage] status output
    if {$detector eq "build"} {
        return [expr {$status ? [list fail $output] : [list pass ""]}]
    }
    if {$status} {
        return [list unbuilt [string range $output end-600 end]]
    }
    set exe [file join $out icy-tower]
    switch -glob -- $detector {
        abi {
            lassign [run [list python3 -I [file join [dict get $ctx root] audit icy-tower tools abi-check.py] \
                [file join $stage .bot_modules sdl3] [file join [dict get $ctx sdlsrc] include] [file join $work abi-$name] \
                [file join $tree examples games icy-tower]]] status output
            set failures [join [lsearch -all -inline [split $output \n] FAIL*] \n]
            return [expr {$status ? [list fail $failures] : [list pass ""]}]
        }
        output {
            lassign [run [list $exe --help]] status help
            set problems {}
            if {![string match "usage: icy-tower*" [lindex [split $help \n] 0]]} {
                lappend problems "the usage was not printed (--help: [string range $help 0 200])"
            }
            lassign [run [list $exe --frames 10] {SDL_VIDEO_DRIVER nosuch}] status report
            if {[string first "Icy Tower: SDL_Init failed: nosuch not available" $report] < 0} {
                lappend problems "SDL_Init failed was not reported (status $status: [string range $report 0 200])"
            }
            return [expr {[llength $problems] ? [list fail [join $problems \n]] : [list pass ""]}]
        }
        session:* {
            set cases [split [string range $detector 8 end] ,]
            set probe $exe
            if {[llength [lsearch -all -inline -regexp $cases {^(cocoa|autopilot|trace-.*)$}]]} {
                lassign [build $ctx $tree [file join $work p-$name] $binding [file join $work "sp-$name" "Stäged Pröbe"] \
                    [dict create ICY_TOWER_SDL3_ARCHIVE [dict get $ctx traced]]] status output
                if {$status} { return [list unbuilt [string range $output end-600 end]] }
                set probe [file join $work p-$name icy-tower]
            }
            set results [file join $work session-$name]
            run [list python3 -I [file join [dict get $ctx root] audit icy-tower tools macos-session.py] run --exe $exe \
                --probe $probe --worker [dict get $ctx worker] --helper [dict get $ctx helper] \
                --reference [file join [dict get $ctx root] audit icy-tower trace-reference.txt] --out $results --only [join $cases ,]]
            # Each case's class and its failing checks' texts, read as JSON.
            lassign [run [list python3 -I -c {
import json, sys
cases = {c["name"]: c for c in json.load(open(sys.argv[1]))}
for name in sys.argv[2:]:
    c = cases.get(name)
    if c is None:
        print("case %s NONE" % name)
        continue
    print("case %s %s" % (name, c["class"]))
    for check in c["checks"]:
        if not check["ok"]:
            print("  " + check["text"].replace("\n", " "))
} [file join $results results.json] {*}$cases]] status summary
            set failed {}
            set blocked {}
            foreach line [split $summary \n] {
                if {![regexp {^case (\S+) (\S+)$} $line -> c class]} continue
                if {$class eq "ENVIRONMENT-BLOCKED"} { lappend blocked $c }
                if {$class in {FAILED NONE}} { lappend failed $c }
            }
            set texts [join [lsearch -all -inline [split $summary \n] "  *"] \n]
            if {[llength $failed]} { return [list fail "FAILED: [join $failed {, }]\n$texts"] }
            if {[llength $blocked]} { return [list blocked "ENVIRONMENT-BLOCKED: [join $blocked {, }]"] }
            return [list pass ""]
        }
        relocate {
            set moved [file join $work "m-$name" "Möved Äpp"]
            file mkdir [file dirname $moved]
            file rename $stage $moved
            file delete [file join $moved main-macos]
            set elsewhere [file join $work "e-$name"]
            file mkdir $elsewhere
            lassign [run [list [file join [dict get $ctx app] Contents MacOS botlish] -warnings error -native-startup main-thread \
                -emit-native-executable [file join $moved main-macos.bot]] {} $elsewhere] status output
            if {$status} { return [list fail $output] }
            lassign [run [list [file join $moved main-macos] --headless --frames 60 --seed 7]] status output
            return [expr {$status ? [list fail $output] : [list pass ""]}]
        }
        failed-build {
            set before [exec shasum -a 256 $exe]
            set empty [file join $work empty-$name]
            file mkdir $empty
            exec clang -c -x c /dev/null -o [file join $empty empty.o]
            exec ar rcs [file join $empty libempty.a] [file join $empty empty.o] 2>@1
            lassign [build $ctx $tree $out $binding $stage [dict create ICY_TOWER_SDL3_ARCHIVE [file join $empty libempty.a]]] status output
            set problems {}
            if {$status == 0} { lappend problems "exit status 0: a build that could not link reported success" }
            if {[exec shasum -a 256 $exe] ne $before} { lappend problems "the previous executable was replaced" }
            if {![regexp {OUTDIR is unchanged} $output]} { lappend problems "no report of the failed compilation" }
            return [expr {[llength $problems] ? [list fail [join $problems \n]] : [list pass ""]}]
        }
        default { error "unknown detector $detector" }
    }
}

proc icymacos::main {root here options names} {
    foreach k {-app -binding -prefix -helper} {
        if {[dict get $options $k] eq ""} { error "mutate.tcl -macos 1 needs $k" }
    }
    set work [file tempdir botlish-icy-tower-macos-mutate]
    set ctx [dict create root $root work $work app [file normalize [dict get $options -app]] \
        binding [file normalize [dict get $options -binding]] prefix [file normalize [dict get $options -prefix]] \
        helper [file normalize [dict get $options -helper]]]
    set fetched [exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] fetch sdl3]
    dict set ctx sdlsrc [lindex [split [string trim $fetched] \n] end]
    set exit 0
    try {
        # Shared by every run: the traced archive (the probe builds) and the
        # unmutated game's worker build (the session's worker case).
        set traced [file join $work traced libSDL3.a]
        file mkdir [file dirname $traced]
        exec bash [file join $root audit icy-tower tools traced-archive.sh] [file join [dict get $ctx prefix] lib libSDL3.a] $traced
        dict set ctx traced $traced
        set mutants [goldentools::readMutants [file join $here macos-mutants.txt]]
        set detectors [readDetectors [file join $here macos-mutants.txt]]
        set baseline [tree $work baseline $root {}]
        lassign [build $ctx $baseline [file join $work worker-out] [dict get $ctx binding] [file join $work "worker stage"]] status output
        if {$status} { error "the unmutated game does not build:\n$output" }
        set worker [file join $work worker-out icy-tower-worker]
        set wstage [file join $work "worker stage"]
        file delete [file join $wstage main-macos]
        exec [file join [dict get $ctx app] Contents MacOS botlish] -warnings error -emit-native-executable [file join $wstage main-macos.bot]
        file rename [file join $wstage main-macos] $worker
        dict set ctx worker $worker
        # The baseline: every detector the mutants use holds for the unmutated game.
        set used [lsort -unique [lmap {n d} $detectors {lindex $d 0}]]
        foreach detector $used {
            lassign [detect $ctx baseline-[string map {: - , -} $detector] $detector $baseline [dict get $ctx binding]] verdict text
            puts [format "%-28s %s" "baseline $detector" $verdict]
            if {$verdict ne "pass"} {
                puts "   [string range $text 0 1500]"
                set exit 1
            }
        }
        set killed 0
        set total 0
        foreach {name description edits} $mutants {
            if {$names ne {} && $name ni $names} continue
            incr total
            if {![dict exists $detectors $name]} {
                puts [format "%-28s NO DETECTOR (a ?? line)" $name]
                set exit 1
                continue
            }
            lassign [dict get $detectors $name] detector regex
            set texts [dict create]
            set bindingEdits {}
            set applied 1
            foreach {file old new} $edits {
                if {[string match @binding/* $file]} {
                    lappend bindingEdits [string range $file 9 end] $old $new
                    continue
                }
                if {![dict exists $texts $file]} { dict set texts $file [goldentools::readFile [file join $root $file]] }
                set text [dict get $texts $file]
                set first [string first $old $text]
                if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} { set applied 0; break }
                dict set texts $file [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
            }
            set binding [dict get $ctx binding]
            if {$applied && [llength $bindingEdits]} {
                set binding [file join $work b-$name]
                file copy [dict get $ctx binding] $binding
                foreach {file old new} $bindingEdits {
                    set path [file join $binding macos-aarch64 $file]
                    set text [goldentools::readFile $path]
                    set first [string first $old $text]
                    if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} { set applied 0; break }
                    goldentools::writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
                }
            }
            if {!$applied} {
                puts [format "%-28s NOT APPLIED (its text does not occur exactly once)" $name]
                set exit 1
                continue
            }
            set t0 [clock seconds]
            lassign [detect $ctx $name $detector [tree $work $name $root $texts] $binding] verdict text
            set seconds [expr {[clock seconds] - $t0}]
            if {$verdict eq "fail" && [regexp -- $regex $text]} {
                incr killed
                set why [lindex [lsearch -all -inline -regexp [split $text \n] $regex] 0]
                puts [format "%-28s killed by %s (%d s): %s" $name $detector $seconds [string range [string trim $why] 0 160]]
            } elseif {$verdict eq "fail"} {
                puts [format "%-28s FAILED FOR ANOTHER REASON (%s; wanted /%s/): %s" $name $detector $regex [string range $text 0 400]]
                set exit 1
            } elseif {$verdict eq "blocked"} {
                puts [format "%-28s BLOCKED, not killed (%s): %s" $name $detector $text]
                set exit 1
            } elseif {$verdict eq "unbuilt"} {
                puts [format "%-28s DID NOT BUILD, not killed (%s): %s" $name $detector [string range $text 0 400]]
                set exit 1
            } else {
                puts [format "%-28s SURVIVED (%s)" $name $detector]
                set exit 1
            }
        }
        puts "$killed of $total mutants killed"
    } finally {
        file delete -force $work
    }
    return $exit
}
