# gate.tcl -- the warning gate (REFACTOR-WARNINGS-CLEAN.md, item 12): the
# shipped stdlib, libraries, examples and benchmarks compile clean under
# Botlish's own warnings, except exactly the findings the manifest
# (audit/refactor/manifest.txt) lists, each with its named obstruction.
#
#   tclsh9.0 audit/refactor/tools/gate.tcl ?-root DIR? ?-manifest FILE?
#
# -root DIR gates another tree's examples/, bench/ and lib/ (and its
# audit/refactor/manifest.txt unless -manifest is given) with this checkout's
# compiler.
#
# The corpus and the units are sweep.tcl's: every corpus program compiled
# standalone, and a one-line loader program `import NS` for every library
# module. The gate fails (exit status 1) on
#
#   * a corpus program the manifest does not list, or a listed path that is
#     not a corpus program (a new program must be added, by hand, with its
#     expected warnings: the manifest only grows at a re-audit);
#   * a unit whose compile outcome is not the manifest's (a program listed
#     `rejected CODE` or `fails CODE` must fail with exactly that code, and
#     every other program must compile);
#   * any difference between a unit's observed warnings and its expected
#     ones -- the manifest entries of every file the unit compiled (its own
#     and its modules'), compared as {CODE FILE LINE COL} records: a new
#     warning anywhere, a missing one, or one whose location drifted;
#   * a manifest entry that no unit observes (a closed finding must leave
#     the manifest: it only shrinks on proof);
#   * a unit whose expected set is empty that does not compile under
#     `-warnings error` (a clean program passes strict mode).
#
# Manifest format (line-oriented; `#` starts a comment line):
#
#   program PATH                       a corpus program compiled with warnings on
#   rejected PATH CODE...              a program that must fail with CODE
#                                      (examples/surface/09 and 10)
#   fails PATH CODE... -- OBSTRUCTION  a library module that must fail
#                                      standalone with CODE, for the named
#                                      reason (it is verified through its
#                                      loader instead)
#     CODE LINE:COL TAG -- OBSTRUCTION an expected finding anchored in the
#                                      PATH above (TAG: H1, H2 or none)

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set root $checkout
set manifestPath ""
foreach {option value} $argv {
    switch -- $option {
        -root { set root [file normalize $value] }
        -manifest { set manifestPath [file normalize $value] }
        default { error "unknown option $option" }
    }
}
if {$manifestPath eq ""} {
    set manifestPath [file join $root audit refactor manifest.txt]
}
# The compiler is this checkout's; the corpus, its library modules and the
# manifest are ROOT's (-root runs the gate over another tree, e.g. a scratch
# copy with a planted warning).
source [file join $checkout surface surface.tcl]
set ::core::libraryDir [file join $root lib]
set ::refactorSweepLibrary 1
source [file join $here sweep.tcl]

# ---------------------------------------------------------------------------
# The manifest

# A dict: programs -> PATH -> {status S code C}, entries -> list of
# {CODE FILE LINE COL TAG OBSTRUCTION}.
proc readManifest {path} {
    set programs [dict create]
    set entries {}
    set current ""
    set n 0
    foreach line [split [refactor::sweep::readText $path] \n] {
        incr n
        if {[regexp {^\s*(#.*)?$} $line]} continue
        if {[regexp {^(?:program|rejected|fails)\s+(\S+)} $line -> program] && [dict exists $programs $program]} {
            error "$path:$n: $program is listed twice"
        }
        if {[regexp {^program\s+(\S+)\s*$} $line -> program]} {
            set current $program
            dict set programs $program [dict create status ok code {}]
        } elseif {[regexp {^rejected\s+(\S+)\s+(.+?)\s*$} $line -> program code]} {
            set current $program
            dict set programs $program [dict create status rejected code $code]
        } elseif {[regexp {^fails\s+(\S+)\s+(.+?)\s+--\s+(.+)$} $line -> program code why]} {
            set current $program
            dict set programs $program [dict create status fails code $code why $why]
        } elseif {[regexp {^\s+([A-Z-]+)\s+(\d+):(\d+)\s+(H1|H2|none)\s+--\s+(.+)$} $line -> code l c tag why]} {
            if {$current eq ""} {
                error "$path:$n: a finding before any program"
            }
            lappend entries [list $code $current $l $c $tag $why]
        } else {
            error "$path:$n: unreadable manifest line: $line"
        }
    }
    return [dict create programs $programs entries $entries]
}

# ---------------------------------------------------------------------------
# The gate

set manifest [readManifest $manifestPath]
set listed [dict get $manifest programs]
set entries [dict get $manifest entries]
set failures {}
proc fail {message} {
    lappend ::failures $message
}

# The corpus and the manifest name the same programs.
set corpus [refactor::sweep::programs $root]
foreach program $corpus {
    if {![dict exists $listed $program]} {
        fail "corpus program not in the manifest: $program"
    }
}
dict for {program info} $listed {
    if {$program ni $corpus} {
        fail "manifest program is not a corpus program: $program"
    }
}

# Expected records per file.
set expectedByFile [dict create]
foreach e $entries {
    lassign $e code file line column
    dict lappend expectedByFile $file [list $code $file $line $column]
}

set units [refactor::sweep::observe $root default]
set observedEntries [dict create]
set strict 0
set strictUnits {}
set warned 0
dict for {unit outcome} $units {
    set program [expr {[string match "import *" $unit] ? "" : $unit}]
    set want [expr {$program ne "" && [dict exists $listed $program] ? [dict get $listed $program] : [dict create status ok code {}]}]
    if {[lindex $outcome 0] ne "ok"} {
        set code [lindex $outcome 1]
        if {[dict get $want status] eq "ok"} {
            fail "$unit does not compile: [join $code { }]: [string range [lindex $outcome 2] 0 200]"
        } elseif {[dict get $want code] ne [join $code { }]} {
            fail "$unit fails with [join $code { }], the manifest says [dict get $want code]"
        }
        continue
    }
    if {[dict get $want status] ne "ok"} {
        fail "$unit compiles, the manifest says it [dict get $want status] with [dict get $want code]"
        continue
    }
    lassign $outcome _ records files
    set observed [lsort [lmap r $records {
        lassign $r code location
        regexp {^(.*):(\d+):(\d+)$} $location -> file line column
        list $code $file $line $column
    }]]
    set expected {}
    foreach file $files {
        if {[dict exists $expectedByFile $file]} {
            lappend expected {*}[dict get $expectedByFile $file]
        }
    }
    set expected [lsort $expected]
    foreach r $observed {
        dict set observedEntries $r 1
    }
    if {$observed ne $expected} {
        set extra [lmap r $observed {expr {$r in $expected ? [continue] : $r}}]
        set missing [lmap r $expected {expr {$r in $observed ? [continue] : $r}}]
        foreach r $extra {
            fail "$unit: unexpected warning [lindex $r 0] at [lindex $r 1]:[lindex $r 2]:[lindex $r 3]"
        }
        foreach r $missing {
            fail "$unit: expected warning [lindex $r 0] at [lindex $r 1]:[lindex $r 2]:[lindex $r 3] not observed"
        }
        if {$extra eq "" && $missing eq ""} {
            fail "$unit: warning multiset differs (a duplicate record)"
        }
    }
    if {$expected eq {}} {
        lappend strictUnits $unit
    } else {
        incr warned
    }
}

# Stale entries.
foreach e $entries {
    lassign $e code file line column
    if {![dict exists $observedEntries [list $code $file $line $column]]} {
        fail "manifest entry not observed by any unit: $code at $file:$line:$column"
    }
}

# Strict mode for every unit with an empty expected set.
set strictFailures 0
foreach unit $strictUnits {
    if {[string match "import *" $unit]} {
        set scratch [file tempdir refactor-gate]
        set path [file join $scratch load.bot]
        refactor::sweep::writeText $path "$unit\n0\n"
    } else {
        set scratch ""
        set path [file join $root $unit]
    }
    set result [refactor::sweep::Compile $root $path error]
    if {$scratch ne ""} {
        file delete -force $scratch
    }
    if {[lindex $result 0] ne "ok"} {
        incr strictFailures
        fail "$unit fails under -warnings error: [join [lindex $result 1] { }]"
    } else {
        incr strict
    }
}

set programsOk [llength [lmap p $corpus {expr {[dict exists $listed $p] && [dict get $listed $p status] eq "ok" ? $p : [continue]}}]]
puts "warning gate: [llength $corpus] corpus programs, [llength [refactor::sweep::modules $root]] library loaders; [llength $entries] manifest entries"
puts "  units passing -warnings error: $strict ([llength [lmap u $strictUnits {expr {[string match {import *} $u] ? [continue] : $u}}]] programs, [llength [lmap u $strictUnits {expr {[string match {import *} $u] ? $u : [continue]}}]] loaders); units carrying manifest entries: $warned"
if {$failures ne {}} {
    puts "GATE FAILED: [llength $failures] problem(s)"
    foreach f $failures {
        puts "  $f"
    }
    exit 1
}
puts "gate passed: the observed warnings are exactly the manifest"
