# overlay.tcl -- can analysis read unsaved editor text instead of the disk,
# without changing the compiler? (COMPILER-SERVICE-CENSUS.md, "Source-overlay
# and revision model")
#
#   tclsh9.0 audit/compiler-service/probes/overlay.tcl
#
# The front end acquires source text in exactly two ways: core::ReadFile (the
# entry file, every module file) and `file exists`/`file isfile` (which
# candidate module files exist: surface/modules.tcl's ResolveModule,
# ApplicationFile, HasModule, ModuleFile, ArchModuleFiles, LoadNamespace).
# lib.tcl's cs::withOverlay substitutes both for one analysis. If those are
# really the only two, a workspace that exists only in memory must analyze
# exactly like the same files on disk; and each overlay case below must see
# the buffer, never the disk.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $here lib.tcl]
cs::load $root

set dir [file normalize [file tempdir]]
proc put {rel text} {
    global dir
    file mkdir [file dirname [file join $dir $rel]]
    set ch [open [file join $dir $rel] w]
    fconfigure $ch -encoding utf-8 -translation lf
    puts -nonewline $ch $text
    close $ch
}
proc at {rel} { global dir; return [file join $dir $rel] }

set mainText "import util\nimport std::list\n\nx = util::f(2)\n\[x + 1, std::list::get(\[1, 2\], 5, 0)\]\n"
set utilText "fn f(n: int) -> int:\n    n * 10\n"
put app/main.bot $mainText
put app/util.bot $utilText

set failures 0
proc expect {label actual expected} {
    global failures
    if {$actual eq $expected} {
        puts [format "ok    %-58s %s" $label $actual]
    } else {
        incr failures
        puts [format "FAIL  %-58s %s (expected %s)" $label $actual $expected]
    }
}

proc summary {r} {
    set d [lmap x [dict get $r diagnostics] {
        string cat [lindex [dict get $x code] end] @[file tail [dict get $x file]]:[dict get $x line]
    }]
    set value ""
    if {[dict get $r status] eq "ok"} {
        set hir [dict get $r hir]
        hir::activate $hir
        if {[catch {core::value::show [core::compiler::evalHir $hir] 1} value]} {
            set value "run-time error"
        }
    }
    return [list [dict get $r status] $d $value]
}

# 0. Baseline from disk.
set disk [summary [cs::analyze [at app/main.bot]]]
# (std::list::get's explicit spelling earns a METHOD-ELIGIBLE warning: warnings
# travel with the analysis like errors.)
expect "disk baseline" $disk {ok METHOD-ELIGIBLE@main.bot:5 {[21, 0]}}

# 1. A workspace that exists only in memory (another directory, never
#    written): every read must go through the overlay.
set ghost [file join $dir ghost]
set r [cs::analyze [file join $ghost main.bot] -overlay [list \
    [file join $ghost main.bot] $mainText [file join $ghost util.bot] $utilText]]
expect "memory-only workspace = disk" [summary $r] $disk
expect "  ...and nothing was created on disk" [file exists $ghost] 0
set f [lmap {id e} [dict get $r files] {file tail [dict get $e path]}]
expect "  ...its files are the buffers' paths" $f {main.bot util.bot list.bot}

# 2. Unsaved entry buffer differs from disk (an error on disk, fixed in the
#    editor; and the reverse).
put app/broken.bot "import util\nutil::f(\"no\")\n"
expect "disk entry with an error" [lindex [summary [cs::analyze [at app/broken.bot]]] 1] {TYPE@broken.bot:2}
expect "unsaved fix of that entry" [summary [cs::analyze [at app/broken.bot] -text "import util\nutil::f(1)\n"]] {ok {} 10}

# 3. An imported module overridden by its unsaved buffer: the dependent sees
#    the buffer's interface.
set r [cs::analyze [at app/main.bot] -overlay [list [at app/util.bot] "fn f(n: str) -> int:\n    1\n"]]
expect "imported module's unsaved buffer changes its interface" [lindex [summary $r] 1] {TYPE@main.bot:4}
expect "  ...disk unchanged afterwards" [summary [cs::analyze [at app/main.bot]]] $disk

# 4. Versions of one file, alternated: v1, v2, v1 (the loader's parse cache
#    is keyed by path and text, so it cannot serve v1's AST for v2).
set v2 "fn f(n: int) -> int:\n    n * 100\n"
set a [summary [cs::analyze [at app/main.bot] -overlay [list [at app/util.bot] $utilText]]]
set b [summary [cs::analyze [at app/main.bot] -overlay [list [at app/util.bot] $v2]]]
set c [summary [cs::analyze [at app/main.bot] -overlay [list [at app/util.bot] $utilText]]]
expect "version 1 of util" $a $disk
expect "version 2 of util" $b {ok METHOD-ELIGIBLE@main.bot:5 {[201, 0]}}
expect "version 1 again" $c $disk

# 5. A module created in the editor, never saved.
set r [cs::analyze [at app/main.bot] -overlay [list \
    [at app/main.bot] "import fresh\nfresh::g()\n" [at app/fresh.bot] "fn g() -> int:\n    7\n"]]
expect "module that exists only as a buffer" [summary $r] {ok {} 7}
expect "  ...not on disk" [file exists [at app/fresh.bot]] 0

# 6. A module deleted in the editor but still on disk.
set r [cs::analyze [at app/main.bot] -overlay [list [at app/util.bot] "\x00DELETED"]]
expect "module deleted in the editor" [lindex [summary $r] 1] {UNKNOWN-NAMESPACE@main.bot:1}

# 7. An unsaved application file that would be a standard namespace
#    (std/list.bot beside an `import std::list`): RESERVED-NAMESPACE, as on
#    disk (STD-NAMESPACE.md); an application list.bot is another namespace.
set r [cs::analyze [at app/main.bot] -overlay [list [at app/std/list.bot] "fn get() -> int:\n    1\n"]]
expect "unsaved app file that would be a standard namespace" [lindex [summary $r] 1] {RESERVED-NAMESPACE@main.bot:2}

# 8. A standard-library module overridden (an edit of stdlib/ in the editor):
#    the mechanism applies to it as to any file.
set r [cs::analyze [at app/main.bot] -overlay [list [file join $root stdlib list.bot] \
    "fn get(xs, index, default):\n    99\n"]]
expect "stdlib module buffer" [lindex [summary $r] 2] {[21, 99]}

# 9. A syntax error in an imported module's buffer: no HIR at all (the loader
#    parses modules without recovery).
set r [cs::analyze [at app/main.bot] -overlay [list [at app/util.bot] "fn f(n: int) -> int:\n    n *\n"]]
expect "syntax error inside an imported module's buffer" [lrange [summary $r] 0 1] {loader SYNTAX@util.bot:2}

file delete -force $dir
puts "overlay: $failures failures"
exit [expr {$failures > 0}]
