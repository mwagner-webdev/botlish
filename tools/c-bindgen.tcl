# c-bindgen.tcl -- the C binding generator (C-BINDGEN.md): ordinary Botlish
# source (`extern c library`, `extern c fn`, opaque pointee types, typed
# constants) and C thunks, generated from real C headers by the installed C
# compiler and the C header library (tools/cheader/). A development tool:
# ordinary Botlish compilation never runs it, needs no header, no
# preprocessor and no C compiler, and compiles a generated binding exactly
# like a hand-written one.
#
#   tclsh9.0 tools/c-bindgen.tcl profiles
#   tclsh9.0 tools/c-bindgen.tcl fetch PROFILE
#   tclsh9.0 tools/c-bindgen.tcl generate PROFILE ?-target T|all? ?-out DIR? ?-timing 1?
#   tclsh9.0 tools/c-bindgen.tcl check PROFILE ?-target T|all|committed? ?-dir DIR?
#   tclsh9.0 tools/c-bindgen.tcl report PROFILE ?-target T? ?-why NAME? ?-status S? ?-reason R?
#   tclsh9.0 tools/c-bindgen.tcl build PROFILE ?-target T? -out DIR
#   tclsh9.0 tools/c-bindgen.tcl stage PROFILE ?-target T? -app DIR -into DIR ?-package 1?
#   tclsh9.0 tools/c-bindgen.tcl run PROFILE ?-target T? PROGRAM.bot ?MAIN.TCL OPTIONS...?
#   tclsh9.0 tools/c-bindgen.tcl diff PROFILE ?-targets {A B}?
#
# generate writes OUTPUT/TARGET/ (the profile's output, generated/c/PROFILE
# by default): the binding modules, shim.c, manifest.txt, report.txt and
# report.tsv. check regenerates into memory and compares, byte for byte,
# with what is committed (exit 1 on any difference). report answers "why
# was NAME not generated?" from the committed report.tsv. build compiles
# the shim into its static library; stage copies an application's files
# and a binding into one application root (with -package 1, the binding
# installed as the application's package, INTO/.bot_modules/PROFILE:
# BOT-MODULES-MILESTONE-1.md); run stages a program with the
# binding, builds the shim and runs main.tcl on it -- the program is
# compiled by the ordinary compiler, from ordinary modules.

source [file join [file dirname [file normalize [info script]]] c-bindgen lib.tcl]
set repo $::cbind::repo

proc Usage {} {
    puts stderr "usage: tclsh9.0 tools/c-bindgen.tcl profiles|fetch|generate|check|report|build|stage|run|diff PROFILE ?options? (C-BINDGEN.md)"
    exit 2
}

proc Options {args defaults} {
    set options $defaults
    set rest {}
    while {[llength $args]} {
        set args [lassign $args k]
        if {[dict exists $defaults $k]} {
            if {![llength $args]} { error "c-bindgen: $k needs a value" }
            set args [lassign $args v]
            dict set options $k $v
        } else {
            lappend rest $k
        }
    }
    return [list $options $rest]
}

# The targets an option -target names for PROFILE: one, all of the
# profile's, or the committed ones (those with a directory under its
# output). The default is the host's when the profile has it, else the
# profile's first.
proc Targets {profile value} {
    if {$value eq "all"} { return [dict get $profile targets] }
    if {$value eq "committed"} {
        return [lmap t [dict get $profile targets] {
            expr {[file isdirectory [::cbind::profile::outputDir $profile $t]] ? $t : [continue]}
        }]
    }
    if {$value ne ""} { return [list $value] }
    set host [core::cabi::hostTarget]
    if {$host in [dict get $profile targets]} { return [list $host] }
    return [list [lindex [dict get $profile targets] 0]]
}

proc Generate {name args} {
    lassign [Options $args {-target "" -out "" -bool 1 -evidence "" -timing 0 -fetch 0}] o rest
    if {$rest ne ""} { error "c-bindgen generate: unexpected [join $rest { }]" }
    set profile [::cbind::profile::load $name]
    set failed 0
    foreach target [Targets $profile [dict get $o -target]] {
        set t0 [clock milliseconds]
        if {[catch {::cbind::generate::run $profile $target [dict create bool [dict get $o -bool] \
                evidence [dict get $o -evidence] fetch [dict get $o -fetch]]} result options]} {
            # One target that cannot be generated here (no target sysroot)
            # does not stop the others.
            puts stderr "[dict get $profile name] $target: FAILED: [lindex [split $result \n] 0]"
            if {[llength [split $result \n]] > 1} { puts stderr [join [lrange [split $result \n] 1 12] \n] }
            set failed 1
            continue
        }
        set dir [expr {[dict get $o -out] ne "" ? [file join [dict get $o -out] $target] : [::cbind::profile::outputDir $profile $target]}]
        ::cbind::generate::write [dict get $result files] $dir [dict get $profile name]
        set c [::cbind::report::counts [dict get $result model]]
        puts "[dict get $profile name] $target: [dict get $c direct] direct, [dict get $c alias] alias, [dict get $c thunk] thunk, [dict get $c unsupported] unsupported, [dict get $c constants] constants -> $dir ([expr {[clock milliseconds] - $t0}] ms)"
        if {[dict get $o -timing]} {
            dict for {k v} [dict get $result timing] { puts "  $k $v s" }
        }
    }
    if {$failed} { exit 1 }
}

proc Check {name args} {
    lassign [Options $args {-target all -dir "" -bool 1}] o rest
    set profile [::cbind::profile::load $name]
    set failed 0
    foreach target [Targets $profile [dict get $o -target]] {
        set dir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $target] : [::cbind::profile::outputDir $profile $target]}]
        set result [::cbind::generate::run $profile $target [dict create bool [dict get $o -bool]]]
        set diffs [::cbind::generate::compare [dict get $result files] $dir [dict get $profile name]]
        if {![llength $diffs]} {
            puts "[dict get $profile name] $target: current ([dict size [dict get $result files]] files in $dir)"
            continue
        }
        set failed 1
        puts "[dict get $profile name] $target: STALE ([llength $diffs] file(s) differ from what generation produces; run generate)"
        foreach d $diffs {
            lassign $d path status detail
            puts "  $status $path"
            if {$detail ne ""} { puts "    $detail" }
        }
        set lines [::cbind::generate::coverageChange $dir $result]
        if {[llength $lines]} {
            puts "  coverage change ([llength $lines] name(s)):"
            foreach l [lrange $lines 0 60] { puts "    $l" }
            if {[llength $lines] > 61} { puts "    ... [expr {[llength $lines] - 61}] more" }
        }
    }
    exit $failed
}



proc Report {name args} {
    lassign [Options $args {-target "" -why "" -status "" -reason "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    set dir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $target] : [::cbind::profile::outputDir $profile $target]}]
    set path [file join $dir report.tsv]
    if {![file exists $path]} { error "c-bindgen report: no $path (run generate)" }
    set rows [::cbind::generate::readTsv [::chdr::readFile $path]]
    if {[dict get $o -why] ne ""} {
        set found 0
        # A typedef naming a C record (its detail is the record's key) also
        # explains the record: its layout, or why it has none.
        set names [list [dict get $o -why]]
        dict for {key row} $rows {
            lassign $row kind n status module reason detail
            if {$kind eq "typedef" && $n eq [dict get $o -why] && [regexp {^(struct|union) \S+$} $detail]} { lappend names $detail }
        }
        dict for {key row} $rows {
            lassign $row kind n status module reason detail
            if {$n ni $names || ($n ne [dict get $o -why] && $kind ne "record")} continue
            set found 1
            switch -- $status {
                direct - alias - thunk - constant - scalar - opaque - callback - pointer - layout-direct {
                    puts "$kind $n: generated ($status[expr {$module ne "" ? " in $module" : ""}]): $reason; $detail"
                }
                default {
                    puts "$kind $n: not generated ($status): $reason"
                    foreach d [split $detail ";"] { puts "  [string trim $d]" }
                }
            }
        }
        if {!$found} { puts "[dict get $o -why]: not a public name of [dict get $profile name] on $target (no row in $path)" }
        return
    }
    if {[dict get $o -status] ne "" || [dict get $o -reason] ne ""} {
        dict for {key row} $rows {
            lassign $row kind n status module reason detail
            if {[dict get $o -status] ne "" && $status ne [dict get $o -status]} continue
            if {[dict get $o -reason] ne "" && [lsearch -exact [split $reason ,] [dict get $o -reason]] < 0} continue
            puts "$kind $n\t$status\t$reason\t$detail"
        }
        return
    }
    puts -nonewline [::chdr::readFile [file join $dir report.txt]]
}

# Compiles the committed shim.c of PROFILE/TARGET into its static library
# lib<shim_library>.a in DIR; prints DIR ("" when the binding has no shim).
proc Build {name args} {
    lassign [Options $args {-target "" -out "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    set lib [::cbind::generate::buildShim $profile $target [dict get $o -out] [dict get $o -dir]]
    puts $lib
}


# Copies the files of application APP (a directory, or a program file and
# the application modules beside it) and the binding of PROFILE/TARGET into
# INTO: one application root, compiled by the ordinary compiler -- with
# -package 1, the binding installed as its package (.bot_modules/PROFILE).
proc Stage {name args} {
    lassign [Options $args {-target "" -app "" -into "" -dir "" -package 0}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    ::cbind::generate::stage $profile $target [dict get $o -app] [dict get $o -into] [dict get $o -dir] \
        [dict get $o -package]
    puts [dict get $o -into]
}


# Runs PROGRAM against the generated binding of PROFILE/TARGET: stages
# PROGRAM's directory and the binding in a private application root, builds
# the shim there, and runs main.tcl with -L for it and any -L given.
proc Run {name args} {
    lassign [Options $args {-target "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set target [lindex [Targets $profile [dict get $o -target]] 0]
    set program [lindex $rest 0]
    set mainArgs [lrange $rest 1 end]
    if {$program eq ""} { error "c-bindgen run: no program" }
    set root [file tempdir]
    try {
        ::cbind::generate::stage $profile $target $program $root [dict get $o -dir]
        set lib [::cbind::generate::buildShim $profile $target [file join $root .shim] [dict get $o -dir]]
        set extra {}
        if {$lib ne ""} { lappend extra -L $lib }
        set status [catch {exec [info nameofexecutable] [file join $::repo main.tcl] {*}$extra {*}$mainArgs \
            [file join $root [file tail $program]] >@stdout 2>@stderr} message]
        if {$status} { puts stderr $message; exit 1 }
    } finally {
        file delete -force $root
    }
}

proc Fetch {name args} {
    set profile [::cbind::profile::load $name]
    puts [::cbind::profile::sourceRoot $profile 1]
}

# The differences between two targets' generated bindings of PROFILE:
# names whose status or meaning differ, and names only one target has.
proc Diff {name args} {
    lassign [Options $args {-targets "" -dir ""}] o rest
    set profile [::cbind::profile::load $name]
    set targets [split [string map {, " "} [dict get $o -targets]]]
    set targets [lsearch -all -inline -not -exact $targets ""]
    if {$targets eq ""} { set targets [Targets $profile committed] }
    set base [lindex $targets 0]
    set baseDir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $base] : [::cbind::profile::outputDir $profile $base]}]
    set baseRows [::cbind::generate::readTsv [::chdr::readFile [file join $baseDir report.tsv]]]
    foreach other [lrange $targets 1 end] {
        set dir [expr {[dict get $o -dir] ne "" ? [file join [dict get $o -dir] $other] : [::cbind::profile::outputDir $profile $other]}]
        set rows [::cbind::generate::readTsv [::chdr::readFile [file join $dir report.tsv]]]
        set lines {}
        dict for {key row} $baseRows {
            if {![dict exists $rows $key]} {
                lappend lines "only on $base: $key ([lindex $row 2] [lindex $row 4])"
            } elseif {[lrange [dict get $rows $key] 2 end] ne [lrange $row 2 end]} {
                set r [dict get $rows $key]
                lappend lines "differs: $key: $base [lindex $row 2] [lindex $row 4] [lindex $row 5] | $other [lindex $r 2] [lindex $r 4] [lindex $r 5]"
            }
        }
        dict for {key row} $rows {
            if {![dict exists $baseRows $key]} { lappend lines "only on $other: $key ([lindex $row 2] [lindex $row 4])" }
        }
        puts "[dict get $profile name]: $base vs $other: [llength $lines] difference(s)"
        foreach l $lines { puts "  $l" }
        # Files compared with each one's own target name spelled away (it is
        # in every banner).
        set fileDiff {}
        set files [lsort -unique [concat [::cbind::generate::Existing $baseDir [dict get $profile name]] \
            [::cbind::generate::Existing $dir [dict get $profile name]]]]
        foreach f $files {
            if {$f in {manifest.txt report.txt report.tsv}} continue
            set a [expr {[file exists [file join $baseDir $f]] ? [string map [list $base TARGET] [::chdr::readFile [file join $baseDir $f]]] : ""}]
            set b [expr {[file exists [file join $dir $f]] ? [string map [list $other TARGET] [::chdr::readFile [file join $dir $f]]] : ""}]
            if {$a ne $b} { lappend fileDiff $f }
        }
        puts "  generated files differing beyond their target name: [llength $fileDiff][expr {[llength $fileDiff] ? " ([join $fileDiff {, }])" : ""}]"
    }
}

set command [lindex $argv 0]
switch -- $command {
    profiles { puts [join [::cbind::profile::names] \n] }
    fetch { Fetch {*}[lrange $argv 1 end] }
    generate { Generate {*}[lrange $argv 1 end] }
    check { Check {*}[lrange $argv 1 end] }
    report { Report {*}[lrange $argv 1 end] }
    build { Build {*}[lrange $argv 1 end] }
    stage { Stage {*}[lrange $argv 1 end] }
    run { Run {*}[lrange $argv 1 end] }
    diff { Diff {*}[lrange $argv 1 end] }
    default { Usage }
}
