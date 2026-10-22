# isolation.tcl -- do analyses of unrelated programs in one process stay
# independent? (COMPILER-SERVICE-CENSUS.md, "State and lifetime model")
#
#   tclsh9.0 audit/compiler-service/probes/isolation.tcl ?-native 1?
#
# COMPILATION-ISOLATION.md establishes that a HIR's *backends* see its own
# declarations (hir::activate). A compiler service asks more of a retained
# HIR: diagnostics, position queries, hover types and runs, in any order,
# interleaved with other programs' analyses, failed ones and Compilerpedia
# lookups. This probe measures that directly.
#
# The workspace: three application directories whose programs share module
# and declaration names but not definitions (appA/geo.bot and appB/geo.bot
# are two versions of "the same" module; appC adds a transitive dependency),
# and four failing programs (a semantic error, an invalid declaration that
# fails while the registries are being written, a syntax error, an unknown
# import). Each program's facts are first computed in a fresh process of its
# own (the baseline), then in one process in several orders. Every fact must
# equal its baseline.
#
# Facts per program: the analysis status and structured diagnostics; the
# position queries (kind, type, definition, references) at fixed source
# markers, computed both on the retained HIR as it is and after
# hir::activate; hir::format's text; the core IR hir::lower makes; the
# outcome on interp and compile (and cranelift with -native 1); a checksum
# of the HIR interchange encoding.
#
# It runs every sequence twice: activating each retained HIR before querying
# it (what a service must do; the exit status is this pass's) and querying it
# as it is. -control noactivate disables hir::activate, the positive control.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $here lib.tcl]

set options [dict create -native 0 -single "" -workspace "" -control ""]
foreach {k v} $argv { dict set options $k $v }
# -control noactivate: the positive control. hir::activate does nothing, so
# a retained HIR's lowering and runs read whatever the last build registered;
# the probe must then report differences (it does: the census records how
# many), or it could not detect a leak at all.

# --- the workspace ----------------------------------------------------------

set programs {
    appA/main.bot {import geo

struct Shape:
    w: int
    h: int

fn helper(s: Shape) -> int:
    s.w * s.h

fn pass(n: geo::Small) -> int:
    n

p = geo::make(3)
[helper(Shape {w: 2, h: 5}), geo::norm(p), geo::bound(4), pass(5)]
}
    appA/geo.bot {struct Point:
    x: int
    y: int

type Small = Int in 0..10

fn make(n: int) -> Point:
    Point {x: n, y: n + 1}

fn norm(p: Point) -> int:
    p.x + p.y

fn bound(n: Small) -> int:
    n + 1
}
    appB/main.bot {import geo

struct Shape:
    r: int

fn helper(s: Shape) -> int:
    s.r * 3

fn pass(n: geo::Small) -> int:
    n

p = geo::make(3)
[helper(Shape {r: 7}), geo::norm(p), geo::bound(150), pass(150)]
}
    appB/geo.bot {struct Point:
    x: int
    y: int
    z: int

type Small = Int in 100..200

fn make(n: int) -> Point:
    Point {x: n, y: n, z: n}

fn norm(p: Point) -> int:
    p.x * p.y * p.z

fn bound(n: Small) -> int:
    n * 2
}
    appC/main.bot {import geo

geo::twice(geo::norm(geo::make(5)))
}
    appC/geo.bot {import util

struct Point:
    x: int

fn make(n: int) -> Point:
    Point {x: n}

fn norm(p: Point) -> int:
    p.x

fn twice(n: int) -> int:
    util::double(n)
}
    appC/util.bot {fn double(n: int) -> int:
    n * 2
}
    failSemantic/main.bot {struct Shape:
    w: int

fn helper(s: Shape) -> int:
    s.w + nosuch

helper(Shape {w: "x"})
}
    failDecl/main.bot {type Small = Int in 5..1
struct Q:
    v: int

1
}
    failSyntax/main.bot {struct Shape:
    w: int

fn helper(s: Shape) -> int:
    s.w +

1
}
    failImport/main.bot {import nosuchmodule

1
}
}

# Position markers: PROGRAM -> {LABEL NEEDLE OCCURRENCE SHIFT}: the query is
# made at the SHIFT-th character of the OCCURRENCE-th NEEDLE in the program.
set markers {
    appA/main.bot {
        helper-call {helper(Shape} 0 0
        shape-field {s.w} 0 2
        geo-make {geo::make} 0 6
        p-use {norm(p)} 0 5
        bound-call {geo::bound} 0 6
        refined-param {    n} 0 4
    }
    appB/main.bot {
        helper-call {helper(Shape} 0 0
        shape-field {s.r} 0 2
        geo-make {geo::make} 0 6
        p-use {norm(p)} 0 5
        bound-call {geo::bound} 0 6
        refined-param {    n} 0 4
    }
    appC/main.bot {
        twice {geo::twice} 0 6
        make {geo::make} 0 6
    }
    failSemantic/main.bot {
        nosuch {nosuch} 0 0
        field {s.w} 0 2
        bad-arg {"x"} 0 0
    }
    failDecl/main.bot {}
    failSyntax/main.bot {
        shape {helper(s: Shape)} 0 10
    }
    failImport/main.bot {}
}

proc MakeWorkspace {dir} {
    global programs
    foreach {rel text} $programs {
        file mkdir [file dirname [file join $dir $rel]]
        set ch [open [file join $dir $rel] w]
        fconfigure $ch -encoding utf-8 -translation lf
        puts -nonewline $ch $text
        close $ch
    }
}

# --- facts ------------------------------------------------------------------

proc Relative {dir value} {
    return [string map [list "$dir/" "" $::root/ "ROOT/"] $value]
}

proc MarkerPosition {text needle occurrence shift} {
    set at -1
    for {set i 0} {$i <= $occurrence} {incr i} {
        set at [string first $needle $text [expr {$at + 1}]]
    }
    set at [expr {$at + $shift}]
    set before [string range $text 0 [expr {$at - 1}]]
    set line [expr {[regexp -all \n $before] + 1}]
    set column [expr {$at - ([string last \n $before] + 1) + 1}]
    return [list $line $column]
}

proc QueryFacts {result path rel} {
    global markers programs
    set out {}
    set text [dict get $programs $rel]
    foreach {label needle occurrence shift} [dict get $markers $rel] {
        lassign [MarkerPosition $text $needle $occurrence $shift] line column
        set q [cs::query $result $path $line $column]
        set kept [dict create]
        foreach k {kind type sourceName bindingKind} {
            if {[dict exists $q $k]} { dict set kept $k [dict get $q $k] }
        }
        if {[dict exists $q definition]} {
            set d [dict get $q definition]
            dict set kept definition "[dict get $d file]:[dict get $d line]:[dict get $d column]"
        }
        if {[dict exists $q references]} {
            dict set kept references [lmap r [dict get $q references] {
                string cat [dict get $r file]:[dict get $r line]:[dict get $r column]
            }]
        }
        dict set kept diagnostics [lmap d [dict get $q diagnostics] {dict get $d message}]
        dict set kept topics [dict get $q topics]
        lappend out $label $kept
    }
    return $out
}

proc Run {hir backend} {
    if {[catch {
        switch -- $backend {
            interp { set v [core::evalProgram [hir::lower $hir]] }
            compile { set v [core::compiler::evalHir $hir] }
            cranelift { set v [native::evalHir $hir] }
        }
        core::value::show $v 1
    } value opts]} {
        return [list error [dict get $opts -errorcode]]
    }
    return [list ok $value]
}

# Facts of the analysis RESULT of program REL. PHASE is "retained" for a
# HIR analyzed earlier (queried before any activation) or "fresh".
proc Facts {dir rel result} {
    set path [file join $dir $rel]
    set facts [dict create status [dict get $result status]]
    dict set facts diagnostics [lmap d [dict get $result diagnostics] {
        list [dict get $d code] [dict get $d line] [dict get $d column] [dict get $d message]
    }]
    set hir [dict get $result hir]
    if {$hir ne "" && $::activateFirst} {
        # The service discipline: activate the revision before any query.
        hir::activate $hir
    }
    dict set facts queries [QueryFacts $result $path $rel]
    if {$hir ne ""} {
        hir::activate $hir
        dict set facts queriesActivated [QueryFacts $result $path $rel]
        dict set facts format [zlib crc32 [encoding convertto utf-8 [hir::format $hir]]]
        if {[dict get $result status] eq "ok"} {
            dict set facts coreIr [zlib crc32 [encoding convertto utf-8 [hir::lower $hir]]]
            dict set facts interp [Run $hir interp]
            dict set facts compile [Run $hir compile]
            if {[dict get $::options -native]} {
                dict set facts cranelift [Run $hir cranelift]
            }
        }
        set encoded [hir::interchange::encode $hir]
        dict set facts interchange [zlib crc32 [encoding convertto utf-8 $encoded]]
    }
    return [Relative $dir $facts]
}

proc Analyze {dir rel} {
    return [cs::analyze [file join $dir $rel] -warnings off]
}

# --- main -------------------------------------------------------------------

cs::load $root
if {[dict get $options -native]} {
    uplevel #0 [list source [file join $root native native.tcl]]
}
set order {appA/main.bot appB/main.bot appC/main.bot failSemantic/main.bot
    failDecl/main.bot failSyntax/main.bot failImport/main.bot}

set ::activateFirst 1
if {[dict get $options -control] eq "noactivate"} {
    proc ::hir::activate {hir} {}
}

if {[dict get $options -single] ne ""} {
    # A baseline: one program, alone in this process.
    set dir [dict get $options -workspace]
    set rel [dict get $options -single]
    puts [Facts $dir $rel [Analyze $dir $rel]]
    exit 0
}

set dir [file normalize [file tempdir]]
MakeWorkspace $dir
set baseline [dict create]
foreach rel $order {
    set facts [exec [info nameofexecutable] [info script] -single $rel -workspace $dir \
        -native [dict get $options -native]]
    dict set baseline $rel $facts
}

set failures 0
set checks 0
# Pass 1 activates every retained HIR before querying it (what a service
# must do); pass 2 queries a retained HIR as it is, the way a caller that
# treated a HIR as a self-contained value would.
proc Check {label rel script} {
    global baseline failures checks
    incr checks
    if {[catch {uplevel 1 $script} facts opts]} {
        incr failures
        puts "FAILS: $label ($rel): [lindex [split $facts \n] 0]"
        return
    }
    set expected [dict get $baseline $rel]
    if {$facts eq $expected} {
        return
    }
    incr failures
    puts "DIFFERS: $label ($rel)"
    dict for {k v} $expected {
        if {![dict exists $facts $k]} {
            puts "   $k: missing"
        } elseif {[dict get $facts $k] ne $v} {
            puts "   $k:\n      baseline [string range $v 0 400]\n      here     [string range [dict get $facts $k] 0 400]"
        }
    }
}

set passFailures {}
foreach ::activateFirst {1 0} {
    set before $failures
    puts "--- pass: activate before querying = $::activateFirst"
    # 1. Sequential, then each earlier analysis queried again after the others
    #    (retained HIRs, no rebuild).
    set results [dict create]
    foreach rel $order {
        set r [Analyze $dir $rel]
        dict set results $rel $r
        Check "sequential" $rel {Facts $dir $rel $r}
    }
    foreach rel [lreverse $order] {
        Check "retained, queried again after all others (reverse order)" $rel {Facts $dir $rel [dict get $results $rel]}
    }

    # 2. Alternating A and B, rebuilt each time, Compilerpedia lookups between.
    foreach rel {appA/main.bot appB/main.bot appA/main.bot appB/main.bot appC/main.bot appA/main.bot} {
        compilerpedia::lookup "bounds proof"
        compilerpedia::topicForDiagnostic {CORE SEMANTIC TYPE} "argument for parameter"
        Check "alternating rebuilds with Compilerpedia between" $rel {Facts $dir $rel [Analyze $dir $rel]}
    }

    # 3. Interleaved queries on two retained HIRs, no rebuild between.
    set rA [dict get $results appA/main.bot]
    set rB [dict get $results appB/main.bot]
    for {set i 0} {$i < 3} {incr i} {
        Check "interleaved retained queries" appA/main.bot {Facts $dir appA/main.bot $rA}
        Check "interleaved retained queries" appB/main.bot {Facts $dir appB/main.bot $rB}
    }

    # 4. Failure orders: each failing program between two analyses of A, and A's
    #    retained HIR queried right after a failure.
    foreach fail {failSemantic/main.bot failDecl/main.bot failSyntax/main.bot failImport/main.bot} {
        set r [Analyze $dir appA/main.bot]
        Check "success before $fail" appA/main.bot {Facts $dir appA/main.bot $r}
        Check "$fail after success" $fail {Facts $dir $fail [Analyze $dir $fail]}
        Check "retained A after $fail" appA/main.bot {Facts $dir appA/main.bot $r}
        Check "A rebuilt after $fail" appA/main.bot {Facts $dir appA/main.bot [Analyze $dir appA/main.bot]}
    }

    lappend passFailures [expr {$failures - $before}]
}
set ::activateFirst 1
# 5. Retained queries WITHOUT any activation in between: the hover type of a
#    struct-typed expression of A read right after B's build, compared with
#    the same read after activating A.
set r1 [Analyze $dir appA/main.bot]
set r2 [Analyze $dir appB/main.bot]
incr checks
if {[catch {QueryFacts $r1 [file join $dir appA/main.bot] appA/main.bot} rawA]} {
    set rawA "error: $rawA"
}
hir::activate [dict get $r1 hir]
set activatedA [QueryFacts $r1 [file join $dir appA/main.bot] appA/main.bot]
if {$rawA ne $activatedA} {
    incr failures
    puts "DIFFERS: A's queries read after B's build without activation\n   raw       [string range $rawA 0 300]\n   activated [string range $activatedA 0 300]"
}
# The same after a failed declaration build (which empties the registries of
# A's types) with no activation between.
incr checks
catch {Analyze $dir failDecl/main.bot}
if {[catch {QueryFacts $r1 [file join $dir appA/main.bot] appA/main.bot} rawA]} {
    set rawA "error: $rawA"
}
if {$rawA ne $activatedA} {
    incr failures
    puts "DIFFERS: A's queries read after a failed build without activation\n   raw       [string range $rawA 0 300]\n   activated [string range $activatedA 0 300]"
}

puts "isolation: $checks checks, $failures differences (activate-first pass: [lindex $passFailures 0], raw pass: [lindex $passFailures 1]; activation switches: $::hir::declarations::switches)"
file delete -force $dir
# The exit status is the service discipline's: activate-first must agree with
# every baseline. The raw pass's differences are the census's finding
# (hir::types::show reads the registries), reported above, not a failure.
exit [expr {[lindex $passFailures 0] > 0}]
