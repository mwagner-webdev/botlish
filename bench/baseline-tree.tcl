# baseline-tree.tcl -- a benchmark's "before": the same benchmark run on a
# temporary git worktree of another revision (UTF16-BYTE-STORAGE-MILESTONE-1.md,
# "Performance"). Sourced by bench/utf16-bytes.tcl and bench/filesystem.tcl
# for their -baseline-rev REV: the benchmark runs twice, as a child process
# each time -- once with -root WORKTREE (REV's compiler and standard library,
# this checkout's driver: it runs any older program) and once on this tree --
# on the same machine, one after the other, and compares the rows.

namespace eval baselineTree {}

# A detached worktree of REV (a commit, or a branch or tag of origin, fetched
# when this clone lacks it: CI's clones are shallow) in a fresh temporary
# directory: its path.
proc baselineTree::add {root rev} {
    if {[catch {exec git -C $root rev-parse --verify --quiet "$rev^{commit}"} commit]} {
        exec git -C $root fetch --quiet --depth 1 origin $rev
        set commit [exec git -C $root rev-parse FETCH_HEAD]
    }
    set tree [file join [file tempdir botlish-baseline-] tree]
    exec git -C $root worktree add --quiet --detach $tree $commit
    puts stderr "baseline: revision $rev ($commit) in $tree"
    return $tree
}

proc baselineTree::remove {root tree} {
    catch {exec git -C $root worktree remove --force $tree}
    file delete -force [file dirname $tree]
    catch {exec git -C $root worktree prune}
}

# The standard output of SCRIPT run with ARGS in a child tclsh (its standard
# error passed through), echoed as it is read.
proc baselineTree::run {script args} {
    set pipe [open |[list [info nameofexecutable] $script {*}$args 2>@stderr] r]
    fconfigure $pipe -encoding utf-8 -translation auto
    set out ""
    while {[gets $pipe line] >= 0} {
        puts $line
        flush stdout
        append out $line\n
    }
    close $pipe
    return $out
}

# OPTIONS (a dict of -option value) without -baseline-rev and -root, as an
# argument list.
proc baselineTree::childArgs {options} {
    set args {}
    dict for {option value} $options {
        if {$option in {-baseline-rev -root}} continue
        lappend args $option $value
    }
    return $args
}

# "after/before" of two numbers (text: "n/a" when either is not one or
# BEFORE is not positive).
proc baselineTree::ratio {before after} {
    if {![string is double -strict $before] || ![string is double -strict $after] || $before <= 0} {
        return n/a
    }
    return [format %.3f [expr {$after / $before}]]
}
