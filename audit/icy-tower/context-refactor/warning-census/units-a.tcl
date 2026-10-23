# units-a.tcl -- the compilation units of partition A of the warning
# candidate's repository census (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md,
# section 11): every Botlish program and library module outside
# tests/*.test, each as one program the front end compiles.
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/units-a.tcl WORK
#
# WORK is an existing, private, empty directory (mktemp -d) that receives the
# loader programs and the staged application directories; the caller removes
# it. Prints one unit per line, tab-separated:
#
#   ID  SET  LABEL  ENTRY  TARGET  EXPECT  MAP
#
# SET is stdlib, examples, bench, golden, generated or audit; LABEL the
# repository-relative name of what the unit covers; ENTRY the program file
# to compile (absolute: in the checkout, or a loader or staged copy in
# WORK); TARGET the compilation target (-target); EXPECT `ok`, or
# `invalid:WHY` for a program that is deliberately rejected (it is
# compiled, and its outcome reported, but it is no evidence); MAP a Tcl
# dict from an absolute path in WORK to the repository path (or
# REV:PATH) it is a copy of, so that reports name repository files.
#
# The units:
#
#   stdlib     a one-line loader `import NS` / `0` per module of stdlib/,
#              the way audit/refactor/tools/sweep.tcl builds them (an
#              architecture file stdlib/P.ARCH.bot loaded as P under
#              linux-ARCH), for the module's platform's target (darwin:
#              macos-aarch64, windows: windows-x86_64; the host's,
#              linux-x86_64, otherwise);
#   examples   every entry program of examples/ (a file no sibling
#              imports), compiled in place for its platform's target
#              (surface::modules::PlatformTarget); the C-binding demos of
#              examples/ffi/bindgen/ staged with their profile's generated
#              binding (tools/c-bindgen.tcl stage's copy); Icy Tower's
#              main, golden and headless programs twice, the working tree
#              and the baseline (6df89a8e, the vertical slice before the
#              census), each staged with the SDL3 binding;
#   bench      bench/*.bot;
#   golden     tests/golden/*.bot (every one a suite: no golden suite
#              imports an application module);
#   generated  a loader per module of every generated/c/PROFILE/TARGET/
#              binding, the binding copied into a private application root,
#              compiled for TARGET;
#   audit      every .bot program under audit/ (a file no sibling imports),
#              in place, except the corpora that are applications assembled
#              by a tool, which are assembled here the same way: the
#              hash-table experiment (driver as main.bot, implementation
#              as table.bot, key module as keys.bot: audit/hash-table/
#              tools/lib.tcl's ht::app), the traits principal program
#              (program/principal.bot with program/lib/ as its application
#              root), the compiler-service export probe (exports.bot beside
#              json/json_tokens.bot) and the Icy Tower context variants
#              (each staged over the working tree with the SDL3 binding).
#              The diagnostic-recovery corpus and the reproducers whose
#              header expects a front-end rejection are deliberately
#              invalid. audit/machine-code-proof-loss/out/profiles/*.bot
#              are directories, not files.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]
source [file join $root surface surface.tcl]

set work [file normalize [lindex $argv 0]]
if {$work eq "" || ![file isdirectory $work]} {
    puts stderr "usage: tclsh9.0 units-a.tcl WORK (an existing private directory)"
    exit 2
}
set baseRev 6df89a8e
set hostTarget linux-x86_64

proc ReadText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}
proc WriteText {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}
proc Rel {path} {
    set path [file normalize $path]
    if {[string first $::root/ $path] == 0} {
        return [string range $path [string length $::root/] end]
    }
    return $path
}

set units {}
set counter 0
proc Unit {set label entry target {expect ok} {map {}}} {
    incr ::counter
    lappend ::units [list [format u%04d $::counter] $set $label [file normalize $entry] $target $expect $map]
}

# The target a program at PATH is compiled for: its platform's, else the
# host's. surface::modules::PlatformTarget names the platform's target of
# the host's architecture (macos-x86_64 on this host); the macOS platform
# is compiled for macos-aarch64 instead, the one macOS target the native
# backend runs (MACOS-AARCH64-MILESTONE-*.md).
proc TargetOf {path} {
    set t [surface::modules::PlatformTarget [ReadText $path]]
    if {[string match macos-* $t]} { return macos-aarch64 }
    return [expr {$t eq "" ? $::hostTarget : $t}]
}

# Namespaces a .bot file imports, as {NS ...} (an `import type NS::T` gives NS).
proc Imports {path} {
    set out {}
    foreach line [split [ReadText $path] \n] {
        if {[regexp {^import\s+type\s+(?:::)?(\S+)::[A-Za-z_][A-Za-z0-9_]*\s*$} $line -> ns]} {
            lappend out $ns
        } elseif {[regexp {^import\s+(?:::)?([A-Za-z_][A-Za-z0-9_:]*)} $line -> ns]} {
            lappend out $ns
        }
    }
    return $out
}

# The .bot files of DIRS (recursively) that are entry programs: those no
# .bot file of their directory or an ancestor directory (within TOP) imports
# as an application module.
proc EntryPrograms {top} {
    set files [lsort [exec find $top -type f -name *.bot]]
    set modules [dict create]
    foreach f $files {
        set dir [file dirname $f]
        foreach ns [Imports $f] {
            if {[string match std::* $ns]} continue
            set p [file normalize [file join $dir {*}[split [string map {:: /} $ns] /]].bot]
            dict set modules $p 1
        }
    }
    return [lmap f $files { if {[dict exists $modules [file normalize $f]]} continue; file normalize $f }]
}

# Copies every file of application directory APP into INTO and returns the
# map entries {INTO/F REPO-PATH ...} (REVPREFIX before the path: "REV:").
proc CopyApp {app into {revprefix ""}} {
    file mkdir $into
    set map {}
    foreach f [glob -nocomplain -type f -directory $app *] {
        file copy -force $f $into
        lappend map [file join $into [file tail $f]] $revprefix[Rel $f]
    }
    return $map
}

# Copies the generated binding of PROFILE/TARGET into INTO (as
# tools/c-bindgen.tcl stage does); returns the map entry for its directory.
proc StageBinding {profile target into} {
    set src [file join $::root generated c $profile $target $profile]
    file delete -force [file join $into $profile]
    file copy -force $src [file join $into $profile]
    return [list [file join $into $profile] [Rel $src]]
}

# ---------------------------------------------------------------------------
# stdlib: one loader per module

foreach path [lsort [concat [glob -directory [file join $root stdlib] *.bot] \
        [glob -directory [file join $root stdlib] */*.bot]]] {
    set rel [string range [file rootname [Rel $path]] 7 end]
    if {[regexp {^(.*)\.([A-Za-z0-9_]+)$} $rel -> base arch]} {
        set ns std::[string map {/ ::} $base]
        set target linux-$arch
    } else {
        set ns std::[string map {/ ::} $rel]
        set target ""
    }
    set loader [file join $work stdlib load-[string map {:: - / -} $rel].bot]
    WriteText $loader "import $ns\n0\n"
    if {$target eq ""} { set target [TargetOf $loader] }
    Unit stdlib "[Rel $path] (import $ns)" $loader $target
}

# ---------------------------------------------------------------------------
# examples

set icyFiles {main.bot golden.bot headless.bot}
foreach f [EntryPrograms [file join $root examples]] {
    set rel [Rel $f]
    if {[string match examples/games/icy-tower/* $rel]} continue
    if {[string match examples/ffi/bindgen/* $rel]} continue
    set expect ok
    if {$rel in {examples/surface/09-mutual-recursion.bot examples/surface/10-duplicate-binding.bot}} {
        set expect "invalid:deliberate rejection (audit/refactor/tools/sweep.tcl's rejections)"
    }
    Unit examples $rel $f [TargetOf $f] $expect
}
foreach {dir profile} {sdl3 sdl3 sha256 boringssl tcl tcl} {
    set app [file join $root examples ffi bindgen $dir]
    set into [file join $work bindgen-$dir]
    set map [CopyApp $app $into]
    lappend map {*}[StageBinding $profile $hostTarget $into]
    Unit examples "[Rel $app]/demo.bot (staged with generated/c/$profile/$hostTarget)" \
        [file join $into demo.bot] $hostTarget ok $map
}
# Icy Tower: the working tree and the baseline, staged with the SDL3 binding.
set icy [file join $root examples games icy-tower]
set into [file join $work icy-wt]
set map [CopyApp $icy $into]
lappend map {*}[StageBinding sdl3 $hostTarget $into]
foreach f $icyFiles {
    Unit examples "examples/games/icy-tower/$f (working tree, staged with sdl3)" [file join $into $f] $hostTarget ok $map
}
set base [file join $work icy-base-src]
file mkdir $base
foreach f [split [exec git -C $root ls-tree --name-only $baseRev examples/games/icy-tower/] \n] {
    WriteText [file join $base [file tail $f]] [exec git -C $root show $baseRev:$f]
}
set into [file join $work icy-base]
set map {}
file mkdir $into
foreach f [glob -type f -directory $base *] {
    file copy -force $f $into
    lappend map [file join $into [file tail $f]] $baseRev:examples/games/icy-tower/[file tail $f]
}
lappend map {*}[StageBinding sdl3 $hostTarget $into]
foreach f $icyFiles {
    Unit examples "$baseRev:examples/games/icy-tower/$f (baseline, staged with sdl3)" [file join $into $f] $hostTarget ok $map
}

# ---------------------------------------------------------------------------
# bench, golden

foreach f [lsort [glob -directory [file join $root bench] *.bot]] {
    Unit bench [Rel $f] $f [TargetOf $f]
}
foreach f [lsort [glob -directory [file join $root tests golden] *.bot]] {
    Unit golden [Rel $f] $f [TargetOf $f]
}

# ---------------------------------------------------------------------------
# generated bindings: a loader per module, per profile and target

foreach profileDir [lsort [glob -type d -directory [file join $root generated c] *]] {
    set profile [file tail $profileDir]
    foreach targetDir [lsort [glob -type d -directory $profileDir *]] {
        set target [file tail $targetDir]
        set app [file join $work gen-$profile-$target]
        file mkdir $app
        set map [StageBinding $profile $target $app]
        foreach m [lsort [exec find [file join $app $profile] -type f -name *.bot]] {
            set rel [string range [file rootname $m] [string length $app/] end]
            set ns [string map {/ ::} $rel]
            set loader [file join $app load-[string map {/ -} $rel].bot]
            WriteText $loader "import $ns\n0\n"
            Unit generated "generated/c/$profile/$target/$rel.bot (import $ns)" $loader $target ok $map
        }
    }
}

# ---------------------------------------------------------------------------
# audit corpora

set assembled {
    audit/hash-table/ audit/traits/principal/ audit/icy-tower/context-refactor/variants/
    audit/compiler-service/probes/export/
}
foreach f [EntryPrograms [file join $root audit]] {
    set rel [Rel $f]
    set skip 0
    foreach prefix $assembled {
        if {[string match $prefix* $rel]} { set skip 1 }
    }
    if {$skip} continue
    set expect ok
    if {[string match audit/diagnostic-recovery/corpus/* $rel]} {
        set expect "invalid:diagnostic-recovery corpus (deliberately invalid programs)"
    } elseif {[string match audit/icy-tower/context-refactor/repro/* $rel]} {
        # The reproducer's own expectation: rejected by the front end when
        # its interp expectation is diagnostic codes other than NATIVE-ONLY
        # (a run-time refusal).
        foreach line [split [ReadText $f] \n] {
            if {[regexp {^# expect interp: (.*)$} $line -> e]} {
                set e [string trim $e]
                if {![string match value:* $e] && $e ne "NATIVE-ONLY"} {
                    set expect "invalid:reproducer expects $e"
                }
            }
        }
    }
    Unit audit $rel $f [TargetOf $f] $expect
}

# The hash-table experiment: every implementation with bench.bot (keys
# int; str for a str-keyed one), every driver with lp (keys int; hashes.bot
# with listmap, as check-hash.tcl does), and the point and str key modules
# with bench.bot and lp.
proc HtTypedDriver {text type} {
    set out {}
    foreach line [split $text \n] {
        if {[regexp {^(nomethod )?fn } $line]} {
            foreach {name t} [list ks "List\[$type\]" qs "List\[$type\]" ms "List\[$type\]" vs "List\[int\]" t table::Table] {
                regsub -all "(\\(|, )${name}(,|\\))" $line "\\1${name}: ${t}\\2" line
            }
        }
        lappend out $line
    }
    return [join $out \n]
}
proc HtApp {driver impl keys} {
    set ht [file join $::root audit hash-table]
    set dir [file join $::work ht [file rootname $driver]-$impl-$keys]
    file mkdir $dir
    set implPath [file join $ht impl $impl.bot]
    set text [ReadText [file join $ht drivers $driver]]
    set label "audit/hash-table/drivers/$driver + impl/$impl.bot as table + drivers/keys_$keys.bot as keys"
    if {[regexp -line {^# key-type: (\S+)$} [ReadText $implPath] -> keyType]} {
        set text [HtTypedDriver $text $keyType]
        append label " (driver typed for $keyType keys, as ht::typedDriver)"
    }
    WriteText [file join $dir main.bot] $text
    file copy -force $implPath [file join $dir table.bot]
    file copy -force [file join $ht drivers keys_$keys.bot] [file join $dir keys.bot]
    set map [list [file join $dir main.bot] audit/hash-table/drivers/$driver \
        [file join $dir table.bot] audit/hash-table/impl/$impl.bot \
        [file join $dir keys.bot] audit/hash-table/drivers/keys_$keys.bot]
    Unit audit $label [file join $dir main.bot] $::hostTarget ok $map
}
foreach implPath [lsort [glob -directory [file join $root audit hash-table impl] *.bot]] {
    set impl [file rootname [file tail $implPath]]
    HtApp bench.bot $impl [expr {$impl eq "lpstr" ? "str" : "int"}]
}
foreach driver {bfs.bot freq.bot memo.bot memo2.bot trace.bot} {
    HtApp $driver lp int
}
HtApp hashes.bot listmap int
HtApp bench.bot lp point
HtApp bench.bot lp str

# The traits principal program: program/lib/ is its application root.
set src [file join $root audit traits principal program]
set into [file join $work traits-principal]
set map [CopyApp [file join $src lib] $into]
file mkdir [file join $into ui]
file copy -force [file join $src lib ui named.bot] [file join $into ui named.bot]
lappend map [file join $into ui named.bot] audit/traits/principal/program/lib/ui/named.bot
file copy -force [file join $src principal.bot] [file join $into principal.bot]
lappend map [file join $into principal.bot] audit/traits/principal/program/principal.bot
Unit audit "audit/traits/principal/program/principal.bot (lib/ as its application root)" \
    [file join $into principal.bot] $hostTarget ok $map

# The compiler-service export probe: exports.bot beside json/json_tokens.bot.
set into [file join $work cs-export]
set map [CopyApp [file join $root audit compiler-service probes export] $into]
file copy -force [file join $root audit compiler-service probes json json_tokens.bot] $into
lappend map [file join $into json_tokens.bot] audit/compiler-service/probes/json/json_tokens.bot
Unit audit "audit/compiler-service/probes/export/exports.bot (beside json/json_tokens.bot)" \
    [file join $into exports.bot] $hostTarget ok $map

# The Icy Tower context variants, each over the working tree.
set variants [file join $root audit icy-tower context-refactor variants]
foreach {name files entries} {
    ids {sdl.bot} {main.bot}
    opaque-values {main.bot render.bot sdl.bot} {main.bot}
    canvas {render.bot canvas-test.bot} {main.bot canvas-test.bot}
} {
    set into [file join $work variant-$name]
    set map [CopyApp $icy $into]
    foreach f $files {
        file copy -force [file join $variants $name $f] [file join $into $f]
        dict set map [file join $into $f] audit/icy-tower/context-refactor/variants/$name/$f
    }
    lappend map {*}[StageBinding sdl3 $hostTarget $into]
    foreach e $entries {
        Unit audit "audit/icy-tower/context-refactor/variants/$name: $e (over the working tree, staged with sdl3)" \
            [file join $into $e] $hostTarget ok $map
    }
}

foreach u $units {
    puts [join $u \t]
}
