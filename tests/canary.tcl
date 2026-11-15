# canary.tcl -- the canary: the test files and golden suites likeliest to
# fail, run before everything else (CI-RUNS.md, "The canary").
#
#   tclsh9.0 tests/canary.tcl ?-host TARGET? ?-base REV? ?-worktree 0|1?
#                             ?-budget SECONDS? ?-list 0|1?
#                             ?-toolchain auto|NAME? ?-toolchain-changed auto|1?
#                             ?-history 0|1?
#                             ?-backends LIST? ?-golden-backends LIST? ?-gc-stress 0|1?
#
# It selects, in this order, while their estimated time fits in -budget
# seconds (default 600; 0 for no limit):
#
#   1. the test files (tests/*.test) and golden suites (tests/golden/*.bot)
#      that the commits since the merge base of HEAD and REV (-base, default
#      origin/main, else main) add or change -- with -worktree 1 also those
#      the working tree adds or changes -- the smallest first: a test is
#      likeliest to fail where it was not written, and right after it was;
#   2. when the toolchain changed, the items that declare themselves
#      toolchain-sensitive (`# canary: toolchain -- REASON`, below), the
#      smallest first. The toolchain changed when the push changes one of the
#      repository's own statements of it (rust-toolchain.toml, the setup
#      scripts, native/Cargo.lock: canary::toolchainSources), or when this
#      run's (-toolchain: auto, the default, asks rustc in the checkout; ""
#      for none) is not the one tests/canary.tsv records for HOST, the
#      newest green run's on main; -toolchain-changed 1 says it changed
#      whatever the records say (the scheduled run against the newest
#      stable Rust, toolchain-canary.yml). It says so first;
#   3. the items whose `# canary: covers PATTERN...` lines match a path the
#      push adds or changes, the smallest first: AGENTS.md's "if you change
#      X, run Y", stated by Y;
#   4. unless -history 0, the history entries of tests/canary.tsv for HOST
#      (-host, default this host's target, core::cabi::hostTarget): the files
#      and suites that failed in recent CI runs there, the most failing
#      commits first.
#
# An item declares itself in its leading comment lines (before its first
# line of code), one declaration a line:
#
#   # canary: toolchain -- REASON
#   # canary: covers PATTERN...
#
# PATTERN is a path relative to the root in `string match` syntax (`*`
# crosses directories). The declarations are properties of the files, not a
# list of the canary's: the canary orders, it never skips.
#
# An item's estimate is its seconds in tests/canary.tsv's durations (a Tcl
# test file on one backend, a golden suite on all four, linux-x86_64), else
# one from its size. -list 1 prints the selection; otherwise it runs
# tests/platform/tier.tcl on it with -backends (default interp: one pass of
# each Tcl test file), -golden-backends and -gc-stress, and exits with its
# status (0 when nothing is selected). The selection also goes to
# $GITHUB_STEP_SUMMARY when that is set.
#
# Sourced, it defines the procedures only: tests/local.tcl runs the
# likeliest-to-fail first with them (canary::priority).

namespace eval canary {
    variable root [file dirname [file dirname [file normalize [info script]]]]
    # Seconds per byte of an item without a measured duration: a Tcl test
    # file's, the median of tests/canary.tsv's durations (0.00022 when they
    # were first measured, 2026-11-04); a golden suite's on four backends,
    # the corpus's 2,160 s over its 3.4 MB (AGENTS.md, "Running the tests
    # locally", an empty cache).
    variable perByte {tcl 0.0002 golden 0.0006}
    # The repository's own statements of the toolchain every build uses: a
    # push that changes one changes the toolchain as a new rustc does
    # (MAIN-CI-FAILURES-2026-11-13.md, C1). Paths relative to the root,
    # `string match` patterns.
    variable toolchainSources {
        rust-toolchain.toml tools/rust-toolchain.sh native/Cargo.lock
        .devcontainer/setup.sh tests/platform/setup-macos.sh tests/platform/setup-windows.ps1
        .github/actions/build-native/* .github/actions/setup-macos/* .github/actions/setup-windows/*
    }
}

# The records of tests/canary.tsv: a dict with `history`, a list of
# {item hosts commits last reason} in the file's order, `toolchains`, a dict
# host -> the Rust toolchain of the newest green run on main there
# (rustc-RELEASE-COMMIT, canary::toolchain's form), `durations`, a dict
# item -> seconds, and `costs`, a dict host -> item -> seconds (an item's
# seconds in that host's acceptance tier: tests/platform/tier.tcl's shards).
proc canary::records {{path ""}} {
    variable root
    if {$path eq ""} { set path [file join $root tests canary.tsv] }
    set history {}
    set toolchains [dict create]
    set durations [dict create]
    set costs [dict create]
    if {![file exists $path]} { return [dict create history {} toolchains {} durations {} costs {}] }
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set n 0
    foreach line [split [::read $f] \n] {
        incr n
        if {[string trim $line] eq "" || [string index $line 0] eq "#"} continue
        set fields [split $line \t]
        switch -- [lindex $fields 0] {
            history {
                if {[llength $fields] != 6 || ![string is integer -strict [lindex $fields 3]]} {
                    close $f
                    error "$path:$n: a history line is: history ITEM HOSTS COMMITS LAST REASON"
                }
                lappend history [lrange $fields 1 end]
            }
            toolchain {
                if {[llength $fields] != 3 || ![string match rustc-?* [lindex $fields 2]]} {
                    close $f
                    error "$path:$n: a toolchain line is: toolchain HOST rustc-RELEASE-COMMIT"
                }
                dict set toolchains [lindex $fields 1] [lindex $fields 2]
            }
            duration {
                if {[llength $fields] != 3 || ![string is double -strict [lindex $fields 2]]} {
                    close $f
                    error "$path:$n: a duration line is: duration ITEM SECONDS"
                }
                dict set durations [lindex $fields 1] [lindex $fields 2]
            }
            cost {
                if {[llength $fields] != 4 || ![string is double -strict [lindex $fields 3]]} {
                    close $f
                    error "$path:$n: a cost line is: cost HOST ITEM SECONDS"
                }
                dict set costs [lindex $fields 1] [lindex $fields 2] [lindex $fields 3]
            }
            default {
                close $f
                error "$path:$n: not a history, toolchain, duration or cost line"
            }
        }
    }
    close $f
    return [dict create history $history toolchains $toolchains durations $durations costs $costs]
}

# The items' declarations: a dict item -> {toolchain REASON covers PATTERNS}
# of every test file and golden suite that declares something in its
# leading comment lines (the file's head, above), REASON "" for an item that
# is not toolchain-sensitive. A malformed `# canary:` line is an error naming
# it.
proc canary::headers {{root ""}} {
    if {$root eq ""} { set root $::canary::root }
    set items [concat \
        [lmap f [glob -nocomplain -tails -directory [file join $root tests] *.test] {file join tests $f}] \
        [lmap f [glob -nocomplain -tails -directory [file join $root tests golden] *.bot] {file join tests golden $f}]]
    set out [dict create]
    foreach item [lsort $items] {
        set f [open [file join $root $item] r]
        fconfigure $f -encoding utf-8
        set toolchain ""
        set covers {}
        set n 0
        while {[gets $f line] >= 0} {
            incr n
            set line [string trimright $line \r]
            if {[string trim $line] eq ""} continue
            if {[string index $line 0] ne "#"} break
            if {![regexp {^#\s*canary:\s*(.*)$} $line -> body]} continue
            if {[regexp {^toolchain\s+--\s+(\S.*)$} $body -> reason]} {
                set toolchain [string trim $reason]
            } elseif {[regexp {^covers\s+(\S.*)$} $body -> patterns]} {
                lappend covers {*}[regexp -all -inline {\S+} $patterns]
            } else {
                close $f
                error "$item:$n: a canary line is `# canary: toolchain -- REASON` or `# canary: covers PATTERN...`"
            }
        }
        close $f
        if {$toolchain ne "" || $covers ne {}} {
            dict set out $item [dict create toolchain $toolchain covers $covers]
        }
    }
    return $out
}

# This checkout's Rust toolchain in the form tools/ci/history.py records
# (rustc-RELEASE-COMMIT, the commit's first 12 digits: the build-native
# action's name for it), "" when rustc does not answer. Asked in the root,
# where rust-toolchain.toml applies; never installs one (RUSTUP_AUTO_INSTALL).
proc canary::toolchain {{root ""}} {
    if {$root eq ""} { set root $::canary::root }
    if {[auto_execok rustc] eq ""} { return "" }
    set here [pwd]
    set saved [array get ::env RUSTUP_AUTO_INSTALL]
    set ::env(RUSTUP_AUTO_INSTALL) 0
    try {
        cd $root
        set info [exec rustc -vV 2>@1]
    } on error {} {
        return ""
    } finally {
        cd $here
        unset ::env(RUSTUP_AUTO_INSTALL)
        array set ::env $saved
    }
    if {![regexp -line {^release: (\S+)} $info -> release] || ![regexp -line {^commit-hash: ([0-9a-f]+)} $info -> commit]} {
        return ""
    }
    return "rustc-$release-[string range $commit 0 11]"
}

# Why the toolchain differs from the newest green run's on HOST, "" when it
# does not: the push changes one of the repository's statements of it
# (toolchainSources), or CURRENT (this run's, canary::toolchain's form) is
# not the one the records hold for HOST. Without a record, or with CURRENT
# unknown, only the first can tell.
proc canary::ToolchainChange {changed records host current} {
    variable toolchainSources
    set reasons {}
    set sources {}
    foreach path $changed {
        foreach pattern $toolchainSources {
            if {[string match $pattern $path]} { lappend sources $path; break }
        }
    }
    if {$sources ne {}} { lappend reasons "the push changes [join $sources {, }]" }
    set recorded [dict getdef [dict getdef $records toolchains {}] $host ""]
    if {$current ne "" && $recorded ne "" && $current ne $recorded} {
        lappend reasons "$current is not $recorded, the newest green run's on main"
    }
    return [join $reasons "; "]
}

# Whether PATH (relative to the repository root) is something the canary
# runs: a test file directly in tests/, or a golden suite directly in
# tests/golden/.
proc canary::IsItem {path} {
    set parts [file split $path]
    return [expr {([llength $parts] == 2 && [lindex $parts 0] eq "tests" && [string match *.test [lindex $parts 1]])
        || ([llength $parts] == 3 && [lrange $parts 0 1] eq {tests golden} && [string match *.bot [lindex $parts 2]])}]
}

proc canary::Estimate {item durations root} {
    variable perByte
    if {[dict exists $durations $item]} { return [dict get $durations $item] }
    set kind [expr {[string match *.bot $item] ? "golden" : "tcl"}]
    set size [expr {[file exists [file join $root $item]] ? [file size [file join $root $item]] : 0}]
    return [expr {round($size * [dict get $perByte $kind] * 10) / 10.0}]
}

# The selection: a list of {item reason seconds}, in the order to run, and
# the items left out for the budget, {item reason seconds} too.
#   changed    paths (relative to the root) the push adds or changes
#   records    canary::records' result
#   host       the target whose history entries apply
#   budget     seconds (0: no limit)
#   root       the repository root (an item must exist there)
#   extra      a dict of: toolchain, why the toolchain changed ("" when it
#              did not: canary::ToolchainChange); headers, the items'
#              declarations (default canary::headers of the root); history,
#              0 to leave the history out (default 1)
proc canary::select {changed records host budget {root ""} {extra {}}} {
    if {$root eq ""} { set root $::canary::root }
    set durations [dict get $records durations]
    set headers [if {[dict exists $extra headers]} {dict get $extra headers} else {headers $root}]
    set why [dict getdef $extra toolchain ""]
    set candidates {}
    set seen [dict create]
    set fresh {}
    foreach path [lsort -unique $changed] {
        if {![IsItem $path] || ![file isfile [file join $root $path]]} continue
        lappend fresh [list $path "changed" [Estimate $path $durations $root]]
    }
    foreach entry [lsort -real -index 2 $fresh] {
        lappend candidates $entry
        dict set seen [lindex $entry 0] 1
    }
    # The toolchain-sensitive items when the toolchain changed; then the
    # items whose covers lines match a changed path. Each the smallest
    # first, by name among equals.
    set sensitive {}
    set covered {}
    foreach item [lsort [dict keys $headers]] {
        if {[dict exists $seen $item] || ![file isfile [file join $root $item]]} continue
        set decl [dict get $headers $item]
        set seconds [Estimate $item $durations $root]
        if {$why ne "" && [dict get $decl toolchain] ne ""} {
            lappend sensitive [list $item "toolchain-sensitive: [dict get $decl toolchain]" $seconds]
            continue
        }
        set hit ""
        foreach path [lsort -unique $changed] {
            foreach pattern [dict get $decl covers] {
                if {[string match $pattern $path]} { set hit $path; break }
            }
            if {$hit ne ""} break
        }
        if {$hit ne ""} { lappend covered [list $item "covers $hit" $seconds] }
    }
    foreach entry [concat [lsort -real -index 2 $sensitive] [lsort -real -index 2 $covered]] {
        lappend candidates $entry
        dict set seen [lindex $entry 0] 1
    }
    set past {}
    if {[dict getdef $extra history 1]} {
        foreach entry [dict get $records history] {
            lassign $entry item hosts commits last reason
            if {[dict exists $seen $item] || ![file isfile [file join $root $item]]} continue
            if {"*" ni [split $hosts ,] && $host ni [split $hosts ,]} continue
            set times [expr {$commits == 1 ? "1 commit" : "$commits commits"}]
            lappend past [list $item "failed in $times of main, last $last: $reason" \
                [Estimate $item $durations $root] $commits]
            dict set seen $item 1
        }
    }
    # The most failing commits first, the cheaper first among equals.
    foreach entry [lsort -integer -decreasing -index 3 [lsort -real -index 2 $past]] {
        lappend candidates [lrange $entry 0 2]
    }
    set chosen {}
    set left {}
    set total 0.0
    foreach entry $candidates {
        set seconds [lindex $entry 2]
        if {$budget > 0 && $total + $seconds > $budget} {
            lappend left $entry
            continue
        }
        set total [expr {$total + $seconds}]
        lappend chosen $entry
    }
    return [list $chosen $left]
}

# git's output without its warnings (a line-ending notice, for one).
proc canary::Git {root args} {
    set out [exec git -C $root {*}$args 2>@1]
    return [join [lsearch -all -inline -not -regexp [split $out \n] {^(warning|hint): }] \n]
}

# The commit the push is compared with: the merge base of HEAD and BASE
# (default origin/main, else main), "" when nothing resolves. A BASE given
# that this history does not hold (a force push, too shallow a clone) falls
# back to HEAD's parent: the last commit's changes at least.
proc canary::MergeBase {root base} {
    set candidates [expr {$base ne "" ? [list $base HEAD~1] : {origin/main main}}]
    foreach rev $candidates {
        if {[catch {Git $root rev-parse --verify -q "$rev^{commit}"} sha]} continue
        if {![catch {Git $root merge-base HEAD $sha} mb]} { return [string trim $mb] }
        # No merge base in a shallow history: the revision itself.
        return [string trim $sha]
    }
    return ""
}

# The paths the commits since BASE's merge base with HEAD add, change or
# rename to (deleted ones left out), and with WORKTREE the working tree's
# (staged, unstaged and untracked under tests/) too; {} outside a git
# checkout.
proc canary::changed {root base worktree} {
    if {[auto_execok git] eq "" || [catch {Git $root rev-parse --git-dir}]} { return {} }
    set paths {}
    set mb [MergeBase $root $base]
    if {$mb ne ""} {
        lappend paths {*}[split [Git $root diff --name-only --diff-filter=AMR $mb HEAD] \n]
    }
    if {$worktree} {
        lappend paths {*}[split [Git $root diff --name-only --diff-filter=AMR HEAD] \n]
        lappend paths {*}[split [Git $root ls-files --others --exclude-standard -- tests] \n]
    }
    return [lsearch -all -inline -not -exact [lsort -unique $paths] ""]
}

proc canary::hostTarget {} {
    variable root
    if {[namespace which -command ::core::cabi::hostTarget] eq ""} {
        source [file join $root core core.tcl]
    }
    return [::core::cabi::hostTarget]
}

# The local run's order (tests/local.tcl): the selection with no budget for
# this host and this checkout's working tree (and its toolchain), as items.
proc canary::priority {{host ""}} {
    variable root
    if {$host eq ""} { set host [hostTarget] }
    set changed [changed $root "" 1]
    set records [records]
    set why [ToolchainChange $changed $records $host [toolchain $root]]
    lassign [select $changed $records $host 0 $root [dict create toolchain $why]] chosen
    return [lmap entry $chosen {lindex $entry 0}]
}

proc canary::Main {argv} {
    variable root
    set options [dict create -host "" -base "" -worktree 0 -budget 600 -list 0 \
        -toolchain auto -toolchain-changed auto -history 1 \
        -backends interp -golden-backends interp,compile,cranelift-generic,cranelift -gc-stress 0]
    foreach {option value} $argv {
        if {![dict exists $options $option]
                || ($option eq "-toolchain-changed" && $value ni {auto 1})
                || ($option eq "-history" && $value ni {0 1})} {
            puts stderr "usage: tclsh9.0 tests/canary.tcl ?-host TARGET? ?-base REV? ?-worktree 0|1? ?-budget SECONDS? ?-list 0|1? ?-toolchain auto|NAME? ?-toolchain-changed auto|1? ?-history 0|1? ?-backends LIST? ?-golden-backends LIST? ?-gc-stress 0|1?"
            return 2
        }
        dict set options $option $value
    }
    set host [dict get $options -host]
    if {$host eq ""} { set host [hostTarget] }
    set budget [dict get $options -budget]
    set changed [changed $root [dict get $options -base] [dict get $options -worktree]]
    set records [records]
    set current [dict get $options -toolchain]
    if {$current eq "auto"} { set current [toolchain $root] }
    set recorded [dict getdef [dict get $records toolchains] $host ""]
    set why [ToolchainChange $changed $records $host $current]
    if {$why eq "" && [dict get $options -toolchain-changed] eq "1"} {
        set under [if {$current eq ""} {set _ unknown} else {set current}]
        set why "asked for the toolchain under test, $under (-toolchain-changed 1)"
    }
    set lines {}
    if {$why ne ""} {
        # First, and as an annotation of the run where there is one.
        lappend lines "TOOLCHAIN CHANGED on $host: $why. The toolchain-sensitive items run first."
        if {[info exists ::env(GITHUB_ACTIONS)] && $::env(GITHUB_ACTIONS) eq "true"} {
            puts "::warning title=Toolchain changed on ${host}::[string map {\n { } % %25} $why]"
        }
    } elseif {$current eq ""} {
        lappend lines "toolchain on $host: unknown (rustc did not answer)"
    } elseif {$recorded eq ""} {
        lappend lines "toolchain on $host: $current (tests/canary.tsv records none for $host)"
    } else {
        lappend lines "toolchain on $host: $current, the newest green run's on main"
    }
    lassign [select $changed $records $host $budget $root \
        [dict create toolchain $why history [dict get $options -history]]] chosen left
    set total [tcl::mathop::+ 0 {*}[lmap e $chosen {lindex $e 2}]]
    lappend lines [format "canary on %s: %d items, about %.0f s of a %s s budget" $host [llength $chosen] $total $budget]
    foreach entry $chosen {
        lassign $entry item reason seconds
        lappend lines [format "  %-48s %7.1f s  %s" $item $seconds $reason]
    }
    foreach entry $left {
        lassign $entry item reason seconds
        lappend lines [format "  (left out: over budget) %-24s %7.1f s  %s" $item $seconds $reason]
    }
    puts [join $lines \n]
    flush stdout
    if {[info exists ::env(GITHUB_STEP_SUMMARY)] && $::env(GITHUB_STEP_SUMMARY) ne ""} {
        set f [open $::env(GITHUB_STEP_SUMMARY) a]
        fconfigure $f -encoding utf-8
        puts $f "### Canary ($host)\n\n```\n[join $lines \n]\n```\n"
        close $f
    }
    if {[dict get $options -list] || $chosen eq {}} { return 0 }
    set command [list [info nameofexecutable] [file join $root tests platform tier.tcl] \
        -backends [dict get $options -backends] -golden-backends [dict get $options -golden-backends] \
        -gc-stress [dict get $options -gc-stress] {*}[lmap e $chosen {lindex $e 0}]]
    if {[catch {exec {*}$command >@ stdout 2>@ stderr} message details]} {
        set code [dict get $details -errorcode]
        return [expr {[lindex $code 0] eq "CHILDSTATUS" ? [lindex $code end] : 1}]
    }
    return 0
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    exit [canary::Main $argv]
}
