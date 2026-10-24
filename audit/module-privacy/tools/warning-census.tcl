#!/usr/bin/env tclsh9.0
# warning-census.tcl -- the repository census of CONTEXT-RESOURCE-ESCAPE
# (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md, section 26): the warning
# the compiler now emits, over every program the warning candidate's census
# (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, section 11;
# audit/icy-tower/context-refactor/warning-census/) compiled, set beside
# that census's instrument and its classification.
#
#   tclsh9.0 audit/module-privacy/tools/warning-census.tcl ?-out DIR?
#       ?-jobs N? ?-parts a,b? ?-n N? ?-seed S? ?-raw-out FILE? ?-raw-in FILE?
#
# -raw-out FILE keeps the scanners' raw output (and the unit labels) in
# FILE; -raw-in FILE reads them instead of scanning, for the comparison
# alone.
#
# The units are the earlier census's, built by its own tools, unchanged:
# partition A by units-a.tcl (libraries, examples -- the Icy Tower baseline
# 6df89a8e and the working tree --, benchmarks, golden suites, generated
# bindings, audit programs) plus the two Icy Tower context variants the
# brief names, opaque-values (Design A) and canvas, staged as their
# README says, beside the pure modules of commit 4be79514 they were written
# against (units-a.tcl stages them over the working tree, where they no
# longer compile: they call hud::int_text, which
# NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md removed), partition B by extract-tests.tcl over the test
# files census-b.tcl selects (this milestone's two test files among them:
# their programs warn and are rejected on purpose) and extract-fuzz.tcl over
# its six fuzzers (-n N -seed S, default 30 and 1). Each unit is scanned by
# that census's own scanner (scan.tcl, scan-b.tcl: the instrument,
# escape-candidates.tcl, compiles it with -warnings off), with two execution
# traces added on HIR procedures (never a renamed or redefined command):
#
#   * on hir::warnings::run, leaving: the warning policy `default` applied
#     to the HIR the compilation just finished -- exactly the front end's
#     last step under -warnings default (surface::lower::Finish), on the
#     same HIR -- and every CONTEXT-RESOURCE-ESCAPE warning recorded (WARN);
#   * on hir::resourceescape::Note, entering, during that run: every
#     crossing the warning counted (CROSS), with its consuming unit, its
#     source location and its manner.
#
# Then every warning crossing is matched with the instrument's sites of the
# same unit (same file and line) and with the earlier census's
# classification of that location (partition-a.tsv, partition-b.tsv), and
# every earlier SUSPICIOUS or LEGITIMATE site is looked up among the
# crossings. Writes DIR (default: audit/module-privacy/census/):
#
#   warnings.tsv    one row per warning (a declaration at its location, once
#                   whatever number of units reported it): partition,
#                   declaration, module, rules, consumers, location, units
#   crossings.tsv   one row per crossing location: partition, declaration,
#                   consumer, location, how, instrument site (bucket and
#                   rules, or none), earlier classification
#   sites.tsv       one row per earlier census site: partition, location,
#                   bucket, rules, classification, warned (the declaration)
#                   or `-`
#   units.tsv       one row per unit: partition, id, label (partition A's
#                   unit label, partition B's sources), outcome, error code,
#                   CONTEXT-RESOURCE-ESCAPE warnings, and the earlier
#                   census's outcome of the unit with the same label (`new`
#                   for a unit it did not have)
#   summary.txt     the totals the report quotes
#
# Every scratch file is in a private `file tempdir` directory, removed at
# the end. Nothing runs a program.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. ..]]
set censusDir [file join $root audit icy-tower context-refactor warning-census]

# ---------------------------------------------------------------------------
# Scanner mode: one process scans units with a census scanner, the traces
# installed first.
#
#   warning-census.tcl -scan a UNITS -shard I/N
#   warning-census.tcl -scan b -work DIR CAPTURE-DIR...

if {[lindex $argv 0] eq "-scan"} {
    set part [lindex $argv 1]
    set scanArgv [lrange $argv 2 end]
    set argv {}
    set argc 0
    source [file join $root surface surface.tcl]
    namespace eval wc {
        variable active 0
        variable crossings {}
    }
    # The location PATH:LINE:COLUMN of ORIGIN in HIR, mapped the way the
    # scanner maps its own (a staged copy back to the repository).
    proc wc::Where {hir origin} {
        set location [hir::originLocation $hir $origin]
        if {$::wcPart eq "a"} {
            return [census::MapLocation $::map $location]
        }
        return [string map $::map $location]
    }
    proc wc::Unit {} {
        return [expr {$::wcPart eq "a" ? $::id : $::uid}]
    }
    proc wc::Clean {text} {
        return [string map {\t { } \n { }} $text]
    }
    proc wc::Note {command op} {
        variable active
        variable crossings
        if {!$active} return
        lassign $command - - key v hir origin how
        lappend crossings [list $key $v [Where $hir $origin] $how]
    }
    proc wc::Leave {command code result op} {
        variable active
        variable crossings
        if {$code != 0 || $active} return
        lassign $command - - mode
        if {[hir::warnings::Mode [expr {$mode eq "" ? [hir::warnings::defaultMode] : $mode}]] ne "off"} return
        set active 1
        set crossings {}
        try {
            set warned [hir::warnings::run $result default ""]
            set source [dict getdef $result traitSource $result]
            foreach w [dict getdef $warned warnings {}] {
                if {[dict get $w code] ne "CONTEXT-RESOURCE-ESCAPE"} continue
                set data [dict get $w data]
                puts [join [list WARN [Unit] [dict get $data declaration] [dict get $data module] \
                    [join [dict get $data rules] ,] \
                    [join [lmap c [dict get $data consumers] {
                        lassign $c v n
                        string cat [dict getdef {"" entry} $v $v] : $n
                    }] ,] [Where $source [dict get $w primary]]] \t]
            }
            foreach c $crossings {
                lassign $c key v where how
                if {[string match binding:* $key]} {
                    set declaration [hir::semantic::SourceName $source [string range $key 8 end]]
                } else {
                    set declaration [string range $key 7 end]
                }
                puts [join [list CROSS [Unit] $declaration [dict getdef {"" entry} $v $v] $where $how] \t]
            }
        } on error {message} {
            puts [join [list WERROR [Unit] [Clean [lindex [split $message \n] 0]]] \t]
        } finally {
            set active 0
            set crossings {}
        }
    }
    trace add execution hir::warnings::run leave ::wc::Leave
    if {[info commands hir::resourceescape::Note] ne ""} {
        # (A tree without the warning -- an earlier revision, for a
        # comparison of the units' outcomes -- has nothing to trace.)
        trace add execution hir::resourceescape::Note enter ::wc::Note
    }
    set ::wcPart $part
    set argv $scanArgv
    set argc [llength $argv]
    fconfigure stdout -buffering line
    source [file join $censusDir [expr {$part eq "a" ? "scan.tcl" : "scan-b.tcl"}]]
    exit 0
}

# ---------------------------------------------------------------------------
# Driver mode.

set options [dict create -out [file join $root audit module-privacy census] -jobs 4 -parts a,b -n 30 -seed 1 \
    -raw-out "" -raw-in ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set out [file normalize [dict get $options -out]]
set parts [split [dict get $options -parts] ,]
set jobs [dict get $options -jobs]
set tclsh [info nameofexecutable]

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
proc Run {args} {
    set start [clock milliseconds]
    if {[catch {exec $::tclsh {*}$args 2>@1} output]} {
        puts "FAILED: [lrange $args 0 2]\n[string range $output 0 4000]"
        exit 1
    }
    puts "  ([format %.0f [expr {([clock milliseconds] - $start) / 1000.0}]] s) [file tail [lindex $args 0]] [lrange $args 1 3]"
    return $output
}
# Runs COMMANDS (argument lists of tclsh9.0) JOBS at a time; returns their
# outputs in order.
proc Parallel {commands} {
    global jobs tclsh
    set outputs [lrepeat [llength $commands] ""]
    set running [dict create]
    set next 0
    set done 0
    set ::pending 0
    while {$done < [llength $commands]} {
        while {[dict size $running] < $jobs && $next < [llength $commands]} {
            set f [open "|[list $tclsh {*}[lindex $commands $next] 2>@1]" r]
            fconfigure $f -encoding utf-8 -blocking 0
            dict set running $f $next
            set ::buffer($f) ""
            fileevent $f readable [list Collect $f]
            incr next
        }
        vwait ::pending
        foreach f [dict keys $running] {
            if {[info exists ::finished($f)]} {
                lset outputs [dict get $running $f] $::buffer($f)
                dict unset running $f
                unset ::finished($f) ::buffer($f)
                incr done
            }
        }
    }
    return $outputs
}
proc Collect {f} {
    append ::buffer($f) [read $f]
    if {[eof $f]} {
        fconfigure $f -blocking 1
        if {[catch {close $f} message]} {
            append ::buffer($f) "\nSCANFAILED [string map {\n { }} [string range $message 0 300]]"
        }
        set ::finished($f) 1
        incr ::pending
    }
}

set work [file tempdir botlish-warning-census-]
set raw [dict create]
set labels [dict create]
try {
    if {[dict get $options -raw-in] ne ""} {
        lassign [ReadText [dict get $options -raw-in]] raw labels
        set parts [dict keys $raw]
    }
    if {"a" in $parts && [dict get $options -raw-in] eq ""} {
        puts "== partition A: units"
        file mkdir [file join $work a]
        set units [Run [file join $censusDir units-a.tcl] [file join $work a]]
        # The context variants beside 4be79514's game (the header).
        set base 4be79514
        set extra {}
        set n [llength [split [string trim $units] \n]]
        foreach {name entries} {opaque-values {main.bot} canvas {main.bot canvas-test.bot golden.bot golden-check-draws.bot}} {
            set app [file join $work a variant-$base-$name-app]
            set stage [file join $work a variant-$base-$name]
            file mkdir $app
            set map {}
            foreach rel [split [string trim [exec git -C $root ls-tree --name-only $base examples/games/icy-tower/]] \n] {
                if {[file extension $rel] ne ".bot"} continue
                WriteText [file join $app [file tail $rel]] [exec git -C $root show $base:$rel]
                lappend map [file join $stage [file tail $rel]] $base:$rel
            }
            set variant [file join $root audit icy-tower context-refactor variants $name]
            foreach f [lsort [glob -directory $variant *.bot]] {
                file copy -force $f [file join $app [file tail $f]]
                dict set map [file join $stage [file tail $f]] audit/icy-tower/context-refactor/variants/$name/[file tail $f]
            }
            exec $tclsh [file join $root tools c-bindgen.tcl] stage sdl3 -target linux-x86_64 -app $app -into $stage
            lappend map [file join $stage sdl3] generated/c/sdl3/linux-x86_64/sdl3
            foreach e $entries {
                set expect ok
                if {$e eq "golden-check-draws.bot"} {
                    set expect "invalid:the variant's rejected test (CONTEXT-FUNCTION-VALUE, variants/canvas/NOTES.md)"
                }
                incr n
                lappend extra [join [list [format u%04d $n] audit \
                    "audit/icy-tower/context-refactor/variants/$name: $e (beside $base's game, staged with sdl3)" \
                    [file join $stage $e] linux-x86_64 $expect $map] \t]
            }
        }
        set units "[string trimright $units \n]\n[join $extra \n]"
        set unitsFile [file join $work units-a.tsv]
        WriteText $unitsFile "[string trimright $units \n]\n"
        set labels [dict create]
        foreach line [split [string trim $units] \n] {
            set cells [split $line \t]
            dict set labels [list a [lindex $cells 0]] [lindex $cells 2]
        }
        puts "  [llength [split [string trim $units] \n]] units; scanning in $jobs shards"
        set commands {}
        for {set i 1} {$i <= $jobs} {incr i} {
            lappend commands [list [info script] -scan a $unitsFile -shard $i/$jobs]
        }
        set start [clock milliseconds]
        dict set raw a [join [Parallel $commands] \n]
        puts "  ([format %.0f [expr {([clock milliseconds] - $start) / 1000.0}]] s) scanned"
    }
    if {"b" in $parts && [dict get $options -raw-in] eq ""} {
        puts "== partition B: captures (census-b.tcl's stages 1 and 2)"
        # census-b.tcl's selection of test files, unchanged.
        set named {contexts context-traits direct-modules c-ffi c-abi-types native-view native-edit
            c-pointer-borrowing windows-io darwin-io}
        set files [lmap n $named {file join $root tests $n.test}]
        foreach path [lsort [concat [glob -directory [file join $root tests] *.test] \
                [glob -nocomplain -directory [file join $root tests platform] *]]] {
            if {![file isfile $path]} continue
            set text [ReadText $path]
            if {[regexp {context struct|context trait} $text]
                    && [regexp {ffi::c::Ptr|FnPtr|NativeView|NativeEdit|extern c fn|direct module} $text]
                    && $path ni $files} {
                lappend files $path
            }
        }
        set fuzzers {direct-modules c-ffi c-abi-types context-traits native-view native-edit}
        file mkdir [file join $work t] [file join $work f]
        set commands {}
        foreach path $files {
            set stem [file rootname [file tail $path]]
            if {[file extension $path] ne ".test"} {
                if {$stem ne "aot-facts"} { error "$path: not a tcltest file" }
                file mkdir [file join $work t $stem]
                lappend commands [list [file join $censusDir extract-tests.tcl] -out [file join $work t $stem] -aot-facts $path]
                continue
            }
            file mkdir [file join $work t $stem]
            lappend commands [list [file join $censusDir extract-tests.tcl] -out [file join $work t $stem] $path]
            set platform [dict getdef {darwin-io {macos Darwin:arm64} windows-io {windows {Windows NT:amd64}}} $stem {}]
            if {$platform ne {}} {
                lassign $platform name spec
                file mkdir [file join $work t $stem@$name]
                lappend commands [list [file join $censusDir extract-tests.tcl] -out [file join $work t $stem@$name] \
                    -platform $spec $path]
            }
        }
        foreach fuzzer $fuzzers {
            file mkdir [file join $work f $fuzzer]
            lappend commands [list [file join $censusDir extract-fuzz.tcl] -out [file join $work f $fuzzer] \
                -n [dict get $options -n] -seed [dict get $options -seed] [file join $root audit $fuzzer tools fuzz.tcl]]
        }
        set start [clock milliseconds]
        set outputs [Parallel $commands]
        foreach output $outputs command $commands {
            if {[string match *SCANFAILED* $output]} {
                puts "FAILED: $command\n[string range $output end-2000 end]"
                exit 1
            }
        }
        puts "  ([format %.0f [expr {([clock milliseconds] - $start) / 1000.0}]] s) [llength $files] test files, [llength $fuzzers] fuzzers captured"
        set commands {}
        foreach {kind lib} {t lib-t f lib-f} {
            file mkdir [file join $work $lib]
            set dirs [lsort [glob -directory [file join $work $kind] -type d *]]
            lappend commands [list [info script] -scan b -work [file join $work $lib] {*}$dirs]
        }
        set start [clock milliseconds]
        dict set raw b [join [Parallel $commands] \n]
        puts "  ([format %.0f [expr {([clock milliseconds] - $start) / 1000.0}]] s) scanned"
    }
} finally {
    file delete -force $work
}
if {[dict get $options -raw-out] ne ""} {
    WriteText [dict get $options -raw-out] [list $raw $labels]
}

# ---------------------------------------------------------------------------
# The earlier classification, by location.

set earlier [dict create]
foreach {part file} {a partition-a.tsv b partition-b.tsv} {
    set lines [lrange [split [string trimright [ReadText [file join $censusDir $file]] \n] \n] 1 end]
    foreach line $lines {
        set cells [split $line \t]
        if {$part eq "a"} {
            lassign $cells bucket location from to rules what class
        } else {
            lassign $cells source bucket location from to rules what class
        }
        dict lappend earlier $part [list $location $bucket $rules $class $from]
    }
}

# File:line of LOCATION, the key crossings and sites are matched by.
proc LineOf {location} {
    if {[regexp {^(.*):(\d+):(\d+)$} $location -> path line column]} {
        return $path:$line
    }
    return $location
}

set warnings [dict create]
set crossings [dict create]
set unitRows {}
set unitWarnings [dict create]
set siteLines [dict create]
set instrumentSites [dict create]
set errors {}
dict for {part text} $raw {
    foreach line [split $text \n] {
        set cells [split $line \t]
        switch -- [lindex $cells 0] {
            UNIT {
                if {$part eq "a"} {
                    lassign $cells - id outcome seconds code message
                    set label [dict getdef $labels [list a $id] $id]
                } else {
                    lassign $cells - id set sources entry target expect outcome seconds code message
                    set label $sources
                }
                if {[lrange $code 0 1] eq {SURFACE SYNTAX}} {
                    # (A syntax error's code carries its location: the
                    # scan's private directory.)
                    set code {SURFACE SYNTAX}
                }
                lappend unitRows [list $part $id $outcome $code $label]
            }
            WARN {
                lassign $cells - id declaration module rules consumers location
                set key [list $part $declaration $location]
                if {![dict exists $warnings $key]} {
                    dict set warnings $key [dict create module $module rules $rules consumers $consumers units {}]
                }
                dict with warnings $key { lappend units $id }
                dict incr unitWarnings [list $part $id]
            }
            CROSS {
                lassign $cells - id declaration consumer location how
                set key [list $part $location]
                if {![dict exists $crossings $key]} {
                    dict set crossings $key [dict create declaration $declaration consumer $consumer how $how units {}]
                }
                dict with crossings $key { lappend units $id }
            }
            SITE {
                lassign $cells - id bucket location from to rules what
                dict lappend siteLines [list $part [LineOf $location]] [list $bucket $rules $what $location]
                dict set instrumentSites [list $part $location $rules] $bucket
            }
            WERROR - SCANFAILED - MODERROR {
                lappend errors $line
            }
        }
    }
}

# ---------------------------------------------------------------------------
# The files.

set rows [list [join {partition declaration module rules consumers location units} \t]]
foreach key [lsort [dict keys $warnings]] {
    lassign $key part declaration location
    set w [dict get $warnings $key]
    lappend rows [join [list $part $declaration [dict get $w module] [dict get $w rules] \
        [dict get $w consumers] $location [llength [lsort -unique [dict get $w units]]]] \t]
}
WriteText [file join $out warnings.tsv] "[join $rows \n]\n"

set earlierByLine [dict create]
dict for {part list} $earlier {
    foreach e $list {
        dict lappend earlierByLine [list $part [LineOf [lindex $e 0]]] $e
    }
}
set rows [list [join {partition declaration consumer location how instrument earlier} \t]]
set crossLines [dict create]
foreach key [lsort [dict keys $crossings]] {
    lassign $key part location
    set c [dict get $crossings $key]
    dict lappend crossLines [list $part [LineOf $location]] [dict get $c declaration]
    set instrument [lmap s [dict getdef $siteLines [list $part [LineOf $location]] {}] {
        string cat [lindex $s 0] ( [lindex $s 1] )
    }]
    set before [lmap e [dict getdef $earlierByLine [list $part [LineOf $location]] {}] {lindex $e 3}]
    lappend rows [join [list $part [dict get $c declaration] [dict get $c consumer] $location [dict get $c how] \
        [if {$instrument eq {}} {string cat none} else {join [lsort -unique $instrument] ,}] \
        [if {$before eq {}} {string cat none} else {join [lsort -unique $before] ,}]] \t]
}
WriteText [file join $out crossings.tsv] "[join $rows \n]\n"

set rows [list [join {partition location bucket rules classification warned} \t]]
set tally [dict create]
dict for {part list} $earlier {
    if {$part ni $parts} continue
    foreach e $list {
        lassign $e location bucket rules class
        set warned [lsort -unique [dict getdef $crossLines [list $part [LineOf $location]] {}]]
        set mark [if {$warned eq {}} {string cat -} else {join $warned ,}]
        lappend rows [join [list $part $location $bucket $rules $class $mark] \t]
        dict incr tally [list $part $class [expr {$warned eq {} ? "not-warned" : "warned"}]]
    }
}
WriteText [file join $out sites.tsv] "[join $rows \n]\n"

# The earlier census's unit outcomes, by label (A) and sources (B).
set before [dict create]
foreach {part file column outcomeColumn} {a partition-a-units.tsv 2 5 b partition-b-units.tsv 1 5} {
    foreach line [lrange [split [string trimright [ReadText [file join $censusDir $file]] \n] \n] 1 end] {
        set cells [split $line \t]
        dict set before [list $part [lindex $cells $column]] [lindex $cells $outcomeColumn]
    }
}
# Partition B's units are distinct programs, and one test compiles many:
# they are compared per set (a test file or a fuzzer), not per unit.
set beforeSets [dict create]
foreach line [lrange [split [string trimright [ReadText [file join $censusDir partition-b-units.tsv]] \n] \n] 1 end] {
    set cells [split $line \t]
    dict incr beforeSets [list [lindex $cells 0] units]
    if {[lindex $cells 5] eq "ok"} { dict incr beforeSets [list [lindex $cells 0] ok] }
}
set rows [list [join {partition id label outcome errorcode warnings earlier} \t]]
foreach u [lsort -dictionary -index 1 [lsort -index 0 $unitRows]] {
    lassign $u part id outcome code label
    set was [expr {$part eq "a" ? [dict getdef $before [list $part $label] new] : "-"}]
    lappend rows [join [list $part $id $label $outcome $code [dict getdef $unitWarnings [list $part $id] 0] $was] \t]
}
WriteText [file join $out units.tsv] "[join $rows \n]\n"

# ---------------------------------------------------------------------------
# The summary.

set summary {}
foreach part $parts {
    set mine [lsearch -all -inline -index 0 $unitRows $part]
    set ok [llength [lsearch -all -inline -index 2 $mine ok]]
    set privacy [llength [lsearch -all -inline -regexp -index 3 $mine {PRIVATE-}]]
    set warnedUnits 0
    foreach u $mine {
        if {[dict getdef $unitWarnings [list $part [lindex $u 1]] 0] > 0} { incr warnedUnits }
    }
    set ws [lmap k [dict keys $warnings] {expr {[lindex $k 0] eq $part ? $k : [continue]}}]
    set cs [lmap k [dict keys $crossings] {expr {[lindex $k 0] eq $part ? $k : [continue]}}]
    lappend summary "partition $part: units [llength $mine], compiled $ok, rejected [expr {[llength $mine] - $ok}] (PRIVATE-* [set privacy]); units with a warning $warnedUnits; warnings [llength $ws] (distinct declarations at distinct locations); crossing locations [llength $cs]"
    set buckets [dict create]
    dict for {key bucket} $instrumentSites {
        if {[lindex $key 0] eq $part} { dict incr buckets $bucket }
    }
    lappend summary "  the instrument's sites (location and rules), by bucket: [if {[dict size $buckets]} {set buckets} else {string cat none}]"
    foreach k [lsort $ws] {
        set w [dict get $warnings $k]
        lappend summary "  warning [lindex $k 1] ([dict get $w rules]) at [lindex $k 2]: consumers [dict get $w consumers]; [llength [lsort -unique [dict get $w units]]] unit(s)"
    }
    foreach class {SUSPICIOUS LEGITIMATE UNDECIDABLE} {
        set w [dict getdef $tally [list $part $class warned] 0]
        set n [dict getdef $tally [list $part $class not-warned] 0]
        if {$w + $n == 0} continue
        lappend summary "  earlier $class sites: [expr {$w + $n}], warned $w, not warned $n"
    }
    if {$part eq "a"} {
        set changed {}
        set fresh 0
        foreach u $mine {
            lassign $u - id outcome code label
            set was [dict getdef $before [list $part $label] new]
            if {$was eq "new"} {
                incr fresh
            } elseif {$was ne $outcome} {
                lappend changed "$label: $was -> $outcome $code"
            }
        }
        lappend summary "  units the earlier census did not have: $fresh; units whose outcome changed: [llength $changed]"
        foreach c $changed { lappend summary "    $c" }
    } else {
        set now [dict create]
        foreach u $mine {
            lassign $u - id outcome code label
            set set [lindex [split $id :] 0]
            dict incr now [list $set units]
            if {$outcome eq "ok"} { dict incr now [list $set ok] }
        }
        set sets [lsort -unique [concat [lmap k [dict keys $now] {lindex $k 0}] [lmap k [dict keys $beforeSets] {lindex $k 0}]]]
        lappend summary "  per set, units (compiled) before -> now:"
        foreach set $sets {
            set b "[dict getdef $beforeSets [list $set units] 0] ([dict getdef $beforeSets [list $set ok] 0])"
            set n "[dict getdef $now [list $set units] 0] ([dict getdef $now [list $set ok] 0])"
            set mark [if {$b eq $n} {list} else {string cat "  *"}]
            lappend summary "    $set: $b -> $n$mark"
        }
        set privacy [dict create]
        foreach u $mine {
            lassign $u - id outcome code
            if {[string match *PRIVATE-* $code]} { dict incr privacy [lindex [split $id :] 0] }
        }
        lappend summary "  PRIVATE-* rejections by set: [if {[dict size $privacy]} {set privacy} else {string cat none}]"
    }
    set unmatched 0
    foreach k $cs {
        if {![dict exists $earlierByLine [list $part [LineOf [lindex $k 1]]]]} { incr unmatched }
    }
    lappend summary "  crossing locations the earlier census did not classify: $unmatched"
}
lappend summary "scanner errors: [llength $errors]"
foreach e $errors { lappend summary "  $e" }
WriteText [file join $out summary.txt] "[join $summary \n]\n"
puts [join $summary \n]
