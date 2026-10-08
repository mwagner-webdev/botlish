# corpus.tcl -- observational audit of MANY-BOOLEAN-ARGUMENTS over the corpus
# (WARNINGS-MANY-BOOLEAN-ARGUMENTS.md, "Corpus census and findings").
# Compiles every program of examples/stdlib, examples/surface,
# examples/refinement, examples/io, examples/abi, examples/linux, bench/*.bot
# and lib/*.bot, and a one-line loader program (`import NS`) for every library
# module (lib/**/*.bot, the subdirectory modules included, whether or not a
# corpus program loads them), with warnings on (collected, not emitted), and
# reports, at the commit it runs on:
#
#   * every distinct finding (a library module's finding once), with its
#     callee, literal count and positions, its enclosing function, an
#     independent false-positive check -- the source text at each counted
#     argument's span must be exactly the token `true` or `false`, and the
#     callee's signature, read through hir::signatures::of (the checker's
#     declared/inferred report), must have at least two ordinary parameters
#     of type bool and one of another type -- and its classification:
#       convert-now      every call site of the callee passes a literal at
#                        every bool position (the conversion law must then be
#                        verified in a scratch copy: this tool has no
#                        automatic corpus rewrite, so such a finding fails the
#                        tool until it is recorded by hand),
#       computed-caller  some call site passes a computed or bound bool,
#       deliberate       (by hand; none is recorded);
#   * THE CENSUS (the deliverable whatever the findings): every function
#     declaration with at least two ordinary parameters the checker proves
#     bool (declared or TRUSTED inferred: hir::signatures::entryTypes) -- its
#     subject-parameter count and, per call site, the literal / computed /
#     binding / parameter breakdown at its bool positions; the same for every
#     declaration with at least two ordinary parameters that are bool by a
#     declaration, a trusted contract or only a CHECKED contract (an untyped
#     parameter used as a condition: what the warning would see if checked
#     contracts counted -- the yield caveat measured); every function that
#     already declares flags, with its call sites; and every native whose
#     registry parameter types include bool (the stdlib-design pressure list).
#
#   tclsh9.0 audit/many-boolean-arguments/tools/corpus.tcl ?-root DIR?
#
# -root audits another checkout (e.g. a worktree of a later commit) with this
# checkout's tools. The corpus is never edited.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set auditRoot $root
while {$argv ne ""} {
    set argv [lassign $argv option]
    switch -- $option {
        -root { set argv [lassign $argv value]; set auditRoot [file normalize $value] }
        default { error "unknown option $option" }
    }
}
source [file join $auditRoot surface surface.tcl]

proc readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

proc writeText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
}

proc rel {path} {
    return [string map [list $::auditRoot/ {}] $path]
}

# The relative location "FILE:LINE:COL" of ORIGIN in HIR ("" when it has no
# file).
proc where {hir origin} {
    if {[lindex $origin 0] ne "file"} {
        return ""
    }
    return [rel [hir::originLocation $hir $origin]]
}

proc pathOf {hir origin} {
    return [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
}

# The source text of ORIGIN's span.
proc spanText {hir origin} {
    set path [pathOf $hir $origin]
    if {![dict exists $::texts $path]} {
        dict set ::texts $path [readText $path]
    }
    set fields [lrange $origin 2 end]
    return [string range [dict get $::texts $path] [dict get $fields start] [expr {[dict get $fields end] - 1}]]
}

set programs [concat \
    [lsort [glob -directory [file join $auditRoot examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples surface] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples refinement] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples io] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples abi] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples linux] *.bot]] \
    [lsort [glob -directory [file join $auditRoot bench] *.bot]] \
    [lsort [glob -directory [file join $auditRoot lib] *.bot]]]

# The library modules, as namespaces (lib/abi/bytes.bot -> abi::bytes).
set modules {}
foreach path [lsort [concat [glob -directory [file join $auditRoot lib] *.bot] \
        [glob -nocomplain -directory [file join $auditRoot lib] */*.bot]]] {
    set relative [string range [file rootname [rel $path]] 4 end]
    lappend modules [string map {/ ::} $relative]
}

set deliberateRejections {examples/surface/09-mutual-recursion.bot examples/surface/10-duplicate-binding.bot}

# The deliberate classification by hand, per {FILE FUNCTION}: none.
set deliberate {}

# ---------------------------------------------------------------------------
# Per compiled program

# The declared function of the written call NODE: {BLOCK NAME} (through
# aliases, as the resolver's candidate identity follows them), or "".
proc declaredCallee {hir node} {
    set callee [dict get $hir exprs [dict get $node callee]]
    if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} {
        return ""
    }
    set identity [hir::resolve::CandidateIdentity hir [dict get $callee binding]]
    if {![string match binding:* $identity]} {
        return ""
    }
    set b [string range $identity 8 end]
    set d [dict get $hir bindings $b declaredBy]
    if {$d eq "" || ![dict exists $hir exprs $d] || [dict get $hir exprs $d kind] ne "bind"} {
        return ""
    }
    set block [dict get $hir exprs $d value]
    if {[dict get $hir exprs $block kind] ne "block"} {
        return ""
    }
    return [list $block [hir::warnings::WrittenName $hir $b] $d]
}

# The class of argument E: literal (a written true/false), binding (a read of
# a local), parameter (a read of a parameter) or computed (anything else).
proc argClass {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""} {
        set binding [dict get $hir bindings [dict get $node binding]]
        if {[dict get $binding kind] eq "root"} {
            return [expr {[dict get $binding name] in {true false} ? "literal" : "computed"}]
        }
        return [expr {[dict get $binding kind] eq "param" ? "parameter" : "binding"}]
    }
    return computed
}

# The per-parameter view of BLOCK: {KIND...} per ordinary parameter, KIND
# bool (declared bool), trusted (trusted inferred bool), checked (only a
# checked bool contract) or other.
proc paramKinds {hir block} {
    set fn [dict get $hir exprs $block]
    set flags [expr {[dict exists $fn flags] ? [dict get $fn flags] : {}}]
    set ordinary [expr {[llength [dict get $fn params]] - [llength $flags]}]
    set kinds {}
    foreach param [lrange [dict get [hir::signatures::of $hir $block] params] 0 [expr {$ordinary - 1}]] {
        if {[dict get $param declared] eq "bool"} {
            lappend kinds bool
        } elseif {[dict get $param declared] eq "" && [dict get $param trusted] eq "bool"} {
            lappend kinds trusted
        } elseif {[dict get $param declared] eq "" && [dict get $param trusted] eq "" && [dict get $param checked] eq "bool"} {
            lappend kinds checked
        } else {
            lappend kinds other
        }
    }
    return $kinds
}

proc inCorpus {path} {
    return [string match $::auditRoot/* $path]
}

proc audit {hir program} {
    # Declarations.
    set decls [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "bind" || [dict get $node duplicate]} continue
        set block [dict get $node value]
        if {[dict get $hir exprs $block kind] ne "block"} continue
        set at [where $hir [dict get $node origin]]
        if {$at eq "" || ![inCorpus [pathOf $hir [dict get $node origin]]]} continue
        set kinds [paramKinds $hir $block]
        set proven [llength [lsearch -all -regexp $kinds {^(bool|trusted)$}]]
        set boolish [llength [lsearch -all -regexp $kinds {^(bool|trusted|checked)$}]]
        set fn [dict get $hir exprs $block]
        set flags [expr {[dict exists $fn flags] ? [dict get $fn flags] : {}}]
        if {$boolish >= 1 || $flags ne ""} {
            set name [hir::warnings::WrittenName $hir [dict get $node binding]]
            if {![dict exists $::census $at]} {
                dict set ::census $at [dict create name $name kinds $kinds flags $flags \
                    subjects [llength [lsearch -all $kinds other]] sites [dict create] programs {}]
            }
            dict set ::census $at programs [lsort -unique [concat [dict get $::census $at programs] [list $program]]]
            dict set decls $block $at
        }
    }
    # Call sites of the census's declarations, and the findings.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict exists $node written]
                || [dict get $node written form] ni {function method}} continue
        set callee [declaredCallee $hir $node]
        if {$callee eq ""} continue
        lassign $callee block name
        if {![dict exists $decls $block]} continue
        set at [dict get $decls $block]
        set site [where $hir [dict get $node origin]]
        if {$site eq ""} continue
        set kinds [dict get $::census $at kinds]
        set classes {}
        set args [dict get $node args]
        foreach kind $kinds a [lrange $args 0 [expr {[llength $kinds] - 1}]] {
            lappend classes [expr {$kind eq "other" || $a eq "" ? "-" : [argClass $hir $a]}]
        }
        set flagVector [expr {[dict exists $node flagVector] ? [dict get $node flagVector] : {}}]
        dict set ::census $at sites $site [dict create classes $classes reachable [dict get $node reachable] \
            flags $flagVector]
    }
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "MANY-BOOLEAN-ARGUMENTS"} continue
        set at [where $hir [dict get $w primary]]
        if {[dict exists $::findings $at]} {
            dict set ::findings $at programs [lsort -unique [concat [dict get $::findings $at programs] [list $program]]]
            continue
        }
        set call [dict get $hir exprs [dict get $w data call]]
        # The independent false-positive check: the counted arguments' source
        # text, and the callee's signature as the checker reports it.
        set problems {}
        foreach p [dict get $w data positions] {
            set text [spanText $hir [dict get $hir exprs [lindex [dict get $call args] [expr {$p - 1}]] origin]]
            if {$text ni {true false}} {
                lappend problems "argument $p is `$text`"
            }
        }
        set target [dict get $w data callee]
        if {[lindex $target 0] eq "block"} {
            set kinds [paramKinds $hir [lindex $target 1]]
            set proven [llength [lsearch -all -regexp $kinds {^(bool|trusted)$}]]
            if {$proven < 2 || [llength $kinds] - $proven < 1} {
                lappend problems "the signature is $kinds"
            }
        }
        dict set ::findings $at [dict create callee [dict get $w data calleeName] target $target \
            literals [dict get $w data literals] positions [dict get $w data positions] \
            problems $problems programs [list $program]]
    }
}

# ---------------------------------------------------------------------------
# The audit

if {[catch {string trim [exec git -C $auditRoot rev-parse HEAD]} commit]} {
    set commit "unknown (not a git checkout)"
    set dirty ""
} else {
    set dirty [string trim [exec git -C $auditRoot status --porcelain -- examples bench lib]]
}
puts "# MANY-BOOLEAN-ARGUMENTS corpus audit: tclsh9.0 audit/many-boolean-arguments/tools/corpus.tcl"
puts "# commit $commit (corpus paths [expr {$dirty eq "" ? "clean" : "MODIFIED: $dirty"}])"
puts ""

set ::texts [dict create]
set ::census [dict create]
set ::findings [dict create]
set failed {}
set compiled 0
set scratch [file tempdir many-boolean-arguments-corpus]
foreach path $programs {
    if {[catch {surface::readProgramFile $path -warnings default -warning-channel ""} hir options]} {
        set why [lindex [dict get $options -errorcode] end]
        lappend failed [list [rel $path] [expr {[rel $path] in $deliberateRejections ? "deliberate rejection ($why)" : $why}]]
        continue
    }
    incr compiled
    audit $hir [rel $path]
}
set loaded 0
foreach ns $modules {
    set path [file join $scratch load-[string map {:: -} $ns].bot]
    writeText $path "import $ns\n0\n"
    if {[catch {surface::readProgramFile $path -warnings default -warning-channel ""} hir options]} {
        lappend failed [list "import $ns" [lindex [dict get $options -errorcode] end]]
        continue
    }
    incr loaded
    audit $hir "import $ns"
}
file delete -force $scratch

puts "## Programs"
puts ""
puts "[llength $programs] corpus programs, $compiled compiled with warnings on; [llength $modules] library modules loaded by a one-line program, $loaded loaded."
foreach f $failed {
    puts "  did not compile: [lindex $f 0]: [lindex $f 1]"
}
puts ""

# Natives whose registry parameter types include bool.
set nativeBools {}
foreach name [lsort [core::native::names]] {
    set types [dict get [core::native::metadata $name] paramTypes]
    set n [llength [lsearch -all -exact $types bool]]
    if {$n >= 1} {
        lappend nativeBools [list $name $n $types]
    }
}

proc table {title filter} {
    puts "## $title"
    puts ""
    set rows 0
    foreach at [lsort -dictionary [dict keys $::census]] {
        set entry [dict get $::census $at]
        if {![apply [list {entry} $filter] $entry]} continue
        incr rows
        set kinds [dict get $entry kinds]
        puts "* `[dict get $entry name]` at $at: ordinary parameters [join $kinds {, }]; subjects [dict get $entry subjects]; flags [expr {[dict get $entry flags] eq "" ? "none" : [join [lmap f [dict get $entry flags] {string cat : $f}] {, }]}]"
        set tally [dict create]
        dict for {site info} [dict get $entry sites] {
            set classes [lmap c [dict get $info classes] {if {$c eq "-"} continue; set c}]
            set key [expr {$classes eq "" ? "no bool position" : [join $classes /]}]
            puts "    - call at $site: [expr {$classes eq "" ? "-" : [join $classes {, }]}][expr {[dict get $info reachable] ? "" : " (structurally unreachable)"}][expr {[dict get $info flags] eq "" ? "" : "; flag vector [dict get $info flags]"}]"
        }
        if {[dict size [dict get $entry sites]] == 0} {
            puts "    - no call site in the corpus"
        }
    }
    if {$rows == 0} {
        puts "(none)"
    }
    puts ""
    return $rows
}

set provenRows [table "Census: functions with two or more ordinary parameters the checker proves bool (declared or trusted inferred)" {
    expr {[llength [lsearch -all -regexp [dict get $entry kinds] {^(bool|trusted)$}]] >= 2}
}]
set boolishRows [table "Census: functions with two or more ordinary parameters that are bool by declaration, trusted contract or CHECKED contract only (the yield caveat: what checked contracts would add)" {
    expr {[llength [lsearch -all -regexp [dict get $entry kinds] {^(bool|trusted|checked)$}]] >= 2}
}]
set flagRows [table "Census: functions that already declare flags (the idiom), with their call sites' flag vectors" {
    expr {[dict get $entry flags] ne ""}
}]
set oneRows [table "Census: functions with exactly one ordinary parameter that is bool by declaration, trusted or checked contract (below the gate)" {
    expr {[llength [lsearch -all -regexp [dict get $entry kinds] {^(bool|trusted|checked)$}]] == 1}
}]

puts "## Natives whose registry parameter types include bool (the stdlib-design pressure list)"
puts ""
if {$nativeBools eq ""} {
    puts "(none: no registered native declares a bool parameter; [llength [core::native::names]] natives)"
}
foreach row $nativeBools {
    puts "* [lindex $row 0]: [lindex $row 1] bool of [lindex $row 2]"
}
puts ""

puts "## Findings"
puts ""
set falsePositives 0
set unverified 0
set classes [dict create]
foreach at [lsort -dictionary [dict keys $::findings]] {
    set f [dict get $::findings $at]
    if {[dict get $f problems] ne ""} {
        incr falsePositives
        puts "FALSE POSITIVE $at: [join [dict get $f problems] {; }]"
    }
    # Classification: convert-now when every census call site of the callee
    # passes a literal at every bool position.
    set class computed-caller
    foreach key [dict keys $::census] {
        set entry [dict get $::census $key]
        if {[dict get $entry name] ne [dict get $f callee]} continue
        set class convert-now
        dict for {site info} [dict get $entry sites] {
            foreach k [dict get $entry kinds] c [dict get $info classes] {
                if {$k in {bool trusted} && $c ne "literal"} {
                    set class computed-caller
                }
            }
        }
    }
    if {$class eq "convert-now"} {
        incr unverified
    }
    dict incr classes $class
    puts "* $at: `[dict get $f callee]`, [dict get $f literals] literals at [join [dict get $f positions] {, }]; $class; loaded by [join [dict get $f programs] {, }]"
}
if {[dict size $::findings] == 0} {
    puts "(none)"
}
puts ""
puts "## Summary"
puts ""
puts "findings [dict size $::findings] (convert-now [expr {[dict exists $classes convert-now] ? [dict get $classes convert-now] : 0}], computed-caller [expr {[dict exists $classes computed-caller] ? [dict get $classes computed-caller] : 0}], deliberate 0); false positives $falsePositives; census: $provenRows functions with 2+ proven-bool ordinary parameters, $boolishRows with 2+ bool-ish (checked contracts included), $oneRows with exactly one bool-ish, $flagRows declaring flags; natives with a bool parameter [llength $nativeBools]"
if {$unverified} {
    puts "CONVERT-NOW FINDINGS: $unverified -- the conversion law must be verified for each in a scratch copy and recorded"
}
exit [expr {$falsePositives > 0 || $unverified > 0}]
