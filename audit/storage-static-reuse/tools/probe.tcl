# probe.tcl -- the probe corpus of STORAGE-STATIC-REUSE-CENSUS-1.md: what
# the compiler and its backends do today with each program of
# audit/storage-static-reuse/cases/, recorded without changing anything.
#
#   tclsh9.0 audit/storage-static-reuse/tools/probe.tcl ?-cases GLOB?
#       ?-out DIR? ?-c 0|1?
#
# For each case it records, into DIR (default results/):
#
#   * the outcome on interp, compile, cranelift and cranelift-unfused (the
#     native backend with coroutine fusion off), and whether they agree;
#   * the native allocation report of one run (native::allocationReport,
#     summary and sites: every allocating instruction with its source
#     location, count and bytes), on cranelift and, for a program with
#     coroutines, cranelift-unfused;
#   * the native struct census (hir/escape.tcl's classes) and the fold
#     slots, counted by class;
#   * HIR facts: the blocks hir::coroutines says may yield, the affine
#     analysis's release table (which bindings are released after which
#     statement), its exit releases, and the coroutine thunks;
#   * the C backend (-emit-c): C UNSUPPORTED with its diagnostics, or the
#     generated program built with gcc -O2 and the reference Int provider,
#     run, compared with the other backends; its coroutine_frames manifest
#     entries; and each coroutine type's sizeof/_Alignof on the host.
#
# Writes probes.md (the summary table) and probes/CASE.txt (the detail), and
# nothing else. Every path printed is the case's own name, so a run is
# reproducible byte for byte on the same toolchain (timings are not
# recorded here: tools/measure.tcl measures).
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set options [dict merge [list -cases * -out [file join $audit results] -c 1] $argv]
set argv {}
source [file join [file dirname [file dirname $audit]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]
source [file join $::projectRoot ccompile ccompile.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

set outDir [dict get $options -out]
file mkdir [file join $outDir probes]
set work [file tempdir]

proc readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# CASE's text with every host path of it mapped to its name (a case's own
# file), to the checkout-relative path (a standard-library module) or out
# (the scratch directory).
proc Clean {text path} {
    return [string map [list [file dirname $path]/ "" $::projectRoot/ "" $::work/ "" $::work ""] $text]
}

# The outcome of HIR on BACKEND, as one short line.
proc Outcome {backend hir} {
    set o [outcomeUnderHir $backend $hir]
    if {[lindex $o 0] eq "value"} {
        return "value [lindex $o 1]"
    }
    return "error [lindex $o 1]"
}

# The nonzero kinds of an allocation report's byKind, as "Kind count/bytes".
proc Kinds {report} {
    set out {}
    dict for {kind d} [dict get $report byKind] {
        if {[dict get $d allocations] > 0} {
            lappend out "$kind [dict get $d allocations]/[dict get $d allocatedBytes]B"
        }
    }
    return [join $out ", "]
}

# The allocation summary and sites of HIR on the native backend (fusion
# FUSED 1 or 0): {summary LINE sites LINES} or {error TEXT}.
proc Allocations {hir fused path} {
    # Under BOTLISH_NATIVE_GC_STRESS=1 the collector runs before every
    # allocation, so the peak is what is reachable at the worst allocation
    # point (precise roots: the native stack maps), not the default
    # collector's 1 MB threshold.
    # (A program that calls C runs as a linked executable, whose counters
    # the summary reports but which has no per-site report.)
    set script {
        set summary [native::allocationReport $hir summary]
        if {[catch {native::allocationReport $hir sites} sites]} {
            set sites [dict create sites {}]
        }
        set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        try {
            set stress [native::allocationReport $hir summary]
        } finally {
            unset ::env(BOTLISH_NATIVE_GC_STRESS)
        }
    }
    if {$fused} {
        set status [catch $script message]
    } else {
        set status [catch [list withoutCoroutineFusion $script] message]
    }
    if {$status} {
        return [list error [Clean $message $path]]
    }
    set t [dict get $summary total]
    set gc [dict get $summary gc]
    set line "allocations [dict get $t allocations], bytes [dict get $t allocatedBytes],\
        peak live [dict get $t peakLiveObjects] objects/[dict get $t peakLiveBytes]B,\
        gc cycles [dict get $gc cycles], peak reachable (GC stress)\
        [dict get $stress total peakLiveObjects] objects/[dict get $stress total peakLiveBytes]B; [Kinds $summary]"
    set lines {}
    # The counters beside the heap's: MutableVector growth (a Rust buffer,
    # outside byKind), coroutine stacks mapped and reused, construction.
    foreach part {mutableVector coroutines construction copies} {
        if {[dict exists $summary $part]} {
            set nonzero [lmap {k v} [dict get $summary $part] {if {$v ne "0" && $v ne ""} {string cat "$k $v"} else continue}]
            if {$nonzero ne ""} {
                lappend lines "counters $part: [join $nonzero {, }]"
            }
        }
    }
    foreach s [dict get $sites sites] {
        set loc [dict getdef $s location {}]
        set where [if {$loc eq ""} {string cat ?} else {
            string cat [file tail [dict get $loc file]]:[dict get $loc line]:[dict get $loc column] " " [dict getdef $loc node ""]
        }]
        lappend lines "[dict get $s func] [dict get $s operation] [dict get $s objectKind]\
            x[dict get $s allocations] [dict get $s allocatedBytes]B at $where"
    }
    return [list summary $line sites $lines]
}

# The struct census of HIR by class, and the fold slots by status.
proc Structs {hir path} {
    if {[catch {native::structCensus $hir} census]} {
        return "census error: [Clean $census $path]"
    }
    set classes [dict create]
    foreach c $census {
        dict incr classes [dict get $c class]
    }
    set slots [dict create]
    if {![catch {native::foldSlots $hir} folds]} {
        foreach f $folds {
            dict incr slots [dict get $f status]
        }
    }
    return "structs {$classes} fold slots {$slots}"
}

# The name of binding B of HIR (as the source spells it, when known).
proc BindingName {hir b} {
    if {[dict exists $hir bindings $b]} {
        return [hir::semantic::SourceName $hir $b]
    }
    return $b
}

# The HIR facts of HIR: lines.
proc HirFacts {hir} {
    set lines {}
    set yielding [lsort -dictionary [dict keys [dict getdef $hir coroutines mayYield {}]]]
    set names {}
    foreach b $yielding {
        lappend names [hir::signatures::Name $hir $b]
    }
    lappend lines "may yield: [if {$names eq ""} {string cat none} else {join $names {, }}]"
    set thunks [dict getdef $hir coroutines thunks {}]
    lappend lines "coroutine thunks: [dict size $thunks]"
    set releases [dict getdef $hir affine releases {}]
    set rel {}
    dict for {stmt bs} $releases {
        lappend rel "after $stmt: [join [lmap b $bs {BindingName $hir $b}] {, }]"
    }
    lappend lines "affine releases (after a statement): [if {$rel eq ""} {string cat none} else {join $rel {; }}]"
    set exits [dict getdef $hir affine exits {}]
    set ex {}
    dict for {x bs} $exits {
        lappend ex "at $x: [join [lmap b $bs {BindingName $hir [lindex $b 0]}] {, }]"
    }
    lappend lines "affine exit releases: [if {$ex eq ""} {string cat none} else {join $ex {; }}]"
    return $lines
}

# The C backend's result for the program file PATH (HIR built from it):
# {status unsupported lines LINES} or {status emitted outcome LINE frames
# LINES sizes LINES services LIST}.
proc CBackend {hir path reference} {
    set prefix [string map {- _} [file rootname [file tail $path]]]
    if {[catch {ccompile::program $hir -prefix $prefix -source [file tail $path]} out options]} {
        set lines {}
        foreach d [dict getdef $options -diagnostics {}] {
            lappend lines [Clean [dict getdef $d message $d] $path]
        }
        if {$lines eq ""} {
            set lines [list [Clean $out $path]]
        }
        return [list status unsupported lines $lines]
    }
    set dir [file join $::work c-$prefix]
    file mkdir $dir
    ccompile::write $out $dir
    set exe [file join $dir $prefix.exe]
    set command [list gcc -std=c11 -O2 -DBOTLISH_PROGRAM=$prefix "-DBOTLISH_PROGRAM_HEADER=\"$prefix.h\"" \
        -I $dir -I [file join $::projectRoot ccompile] \
        [file join $::projectRoot examples c-freestanding harness host_main.c] \
        [file join $dir $prefix.c] [file join $dir ${prefix}_display.c] \
        [file join $::projectRoot examples c-freestanding providers botlish_rt_v1_int_arena.c] -o $exe]
    if {[catch {exec {*}$command 2>@1} message]} {
        return [list status emitted outcome "build failed: [Clean $message $path]" frames {} sizes {} services {}]
    }
    catch {exec $exe 2>@1} ran
    set ran [string trim $ran]
    set agrees [expr {$ran eq "value: [string range $reference 6 end]" ? "agrees" : "DIFFERS from $reference"}]
    set manifest [file join $dir $prefix.runtime.json]
    set text [readFile $manifest]
    set frames [regexp -all -inline -line {^\s*\{"type": .*\}} $text]
    set frames [lmap f $frames {string trim [string trimright [string trim $f] ,]}]
    set sizes {}
    set types [lmap f $frames {lindex [regexp -inline {"type": "([^"]*)"} $f] 1}]
    if {$types ne ""} {
        set probe [file join $dir sizes.c]
        set f [open $probe w]
        puts $f "#include <stdio.h>\n#include \"$prefix.h\"\nint main(void)\n\{"
        foreach t $types {
            puts $f "    printf(\"%s %zu %zu\\n\", \"$t\", sizeof($t), _Alignof($t));"
        }
        puts $f "    return 0;\n\}"
        close $f
        exec gcc -std=c11 -I $dir $probe -o [file join $dir sizes]
        set sizes [split [string trim [exec [file join $dir sizes]]] \n]
    }
    set services [lsort -unique [concat [dict get $out services] [dict get $out display]]]
    return [list status emitted outcome "$ran ($agrees)" frames $frames sizes $sizes services $services]
}

set summary {}
lappend summary "# Probe results" "" \
    "Generated by \`tclsh9.0 audit/storage-static-reuse/tools/probe.tcl\` (STORAGE-STATIC-REUSE-CENSUS-1.md, section 14)." \
    "Native: one run, \`native::allocationReport\` (the Botlish managed heap only). C: gcc -O2, the reference Int provider, the hosted harness." "" \
    "| case | interp / compile / cranelift / unfused | native allocations (fused) | native allocations (unfused) | C backend |" \
    "|---|---|---|---|---|"
foreach path [lsort [glob -directory [file join $audit cases] "[dict get $options -cases].bot"]] {
    set name [file rootname [file tail $path]]
    puts stderr "probe: $name"
    set detail [list "# $name" ""]
    if {[catch {surface::readProgramFile $path -warnings off} hir options2]} {
        set why [Clean $hir $path]
        lappend detail "front end: rejected" {*}[lmap l [split $why \n] {string cat "  " $l}]
        lappend summary "| $name | rejected by the front end ([lindex [dict get $options2 -errorcode] end]) | - | - | - |"
        writeFile [file join $outDir probes $name.txt] [join $detail \n]\n
        continue
    }
    set outcomes [dict create]
    foreach backend {interp compile cranelift cranelift-unfused} {
        dict set outcomes $backend [Clean [Outcome $backend $hir] $path]
    }
    set distinct [lsort -unique [dict values $outcomes]]
    if {[llength $distinct] == 1} {
        set agree "all agree: [lindex $distinct 0]"
    } else {
        set groups {}
        foreach o $distinct {
            set who [lmap {b x} $outcomes {if {$x eq $o} {set b} else continue}]
            lappend groups "[join $who {, }]: $o"
        }
        set agree [join $groups "; "]
    }
    lappend detail "## Outcomes" ""
    dict for {b o} $outcomes {
        lappend detail "* $b: $o"
    }
    lappend detail "" "## HIR facts" ""
    foreach l [HirFacts $hir] {
        lappend detail "* $l"
    }
    lappend detail "* native representation: [Structs $hir $path]"
    set coroutines [expr {[dict size [dict getdef $hir coroutines thunks {}]] > 0}]
    set alloc(1) [Allocations $hir 1 $path]
    set alloc(0) [if {$coroutines} {Allocations $hir 0 $path} else {list summary "(no coroutine: as fused)" sites {}}]
    foreach fused {1 0} {
        set label [if {$fused} {string cat "fused (default)"} else {string cat "coroutine fusion off"}]
        lappend detail "" "## Native allocations, $label" ""
        if {[lindex $alloc($fused) 0] eq "error"} {
            lappend detail "error: [lindex $alloc($fused) 1]"
            continue
        }
        lappend detail [dict get $alloc($fused) summary]
        foreach s [dict get $alloc($fused) sites] {
            lappend detail "* $s"
        }
    }
    set c "-"
    if {[dict get $options -c]} {
        set ref [dict get $outcomes interp]
        set cb [CBackend $hir $path $ref]
        lappend detail "" "## C backend" ""
        if {[dict get $cb status] eq "unsupported"} {
            set c "C UNSUPPORTED"
            foreach l [dict get $cb lines] {
                lappend detail "* $l"
            }
        } else {
            set c "emitted; [dict get $cb outcome]"
            lappend detail "* run: [dict get $cb outcome]"
            lappend detail "* runtime services: [if {[dict get $cb services] eq ""} {string cat none} else {join [dict get $cb services] {, }}]"
            foreach fr [dict get $cb frames] {
                lappend detail "* frame: $fr"
            }
            foreach s [dict get $cb sizes] {
                lappend detail "* host sizeof/_Alignof: $s"
            }
            if {[dict get $cb frames] ne ""} {
                append c "; [llength [dict get $cb frames]] coroutine types"
            }
        }
    }
    set short {}
    foreach fused {1 0} {
        if {[lindex $alloc($fused) 0] eq "error"} {
            lappend short "error"
        } else {
            set s [dict get $alloc($fused) summary]
            if {[regexp {^allocations (\d+), bytes (\d+), peak live .* peak reachable \(GC stress\) (\d+) objects/(\d+)B} $s -> a b po pb]} {
                set s "$a allocs / ${b}B; reachable peak $po / ${pb}B"
            }
            lappend short $s
        }
    }
    lappend summary "| $name | $agree | [lindex $short 0] | [lindex $short 1] | $c |"
    writeFile [file join $outDir probes $name.txt] [join $detail \n]\n
}
writeFile [file join $outDir probes.md] [join $summary \n]\n
file delete -force $work
puts stderr "probe: wrote [file join $outDir probes.md]"
