# census.tcl -- the typed coroutine source census
# (EMISSION-TYPED-COROUTINE-SOURCE-CENSUS-MILESTONE-1.md).
#
#   tclsh9.0 audit/typed-coroutine-sources/tools/census.tcl ?-cases GLOB?
#       ?-backends B? ?-out DIR? ?-external 0|1?
#
# For every program of audit/typed-coroutine-sources/cases (and, with
# -external 1, the repository's own consumers listed below, analyzed only),
# it records what the compiler decided -- never what a run suggests:
#
#   per coroutine construction (each coroutine#create of the HIR):
#     root      the root function (hir::coroutines::Name)
#     declared  the root's declared result ("" when it has none)
#     R         the root's own result type: the join of its returns
#     Y         the join of the static types of every reachable yield the
#               coroutine can reach (hir::coroutines::YieldTypes), its own
#               and its callees': what the yields send ("-" when none)
#     O         the handle's outward type (hir::types::CoroutineOutward of
#               the construction's type): what `first` and every resume
#               return -- the one type the language gives both channels
#     Yr        the join of hir::range's facts of every yield's value, over
#               every analyzed instance of the yielding function
#     first     the static type and range of the construction's first value
#               (coroutine#start)
#
#   per program: its error diagnostics (kinds), and its outcome on every
#   backend (interp, compile, cranelift-generic, cranelift and
#   cranelift-unfused, the general coroutine runtime: tests/helpers.tcl's
#   outcomeUnderHir), which must agree.
#
# Each case states what it expects in its leading comments:
#
#   # case: ONE LINE        what it probes
#   # class: CLASS          the census's taxonomy (the report's section 15):
#                           intended, narrowing, rejected-correct,
#                           rejected-precision, unsupported
#   # expect: OBSERVATION   precise (O = Y, and the first value's range is
#                           the yields' range, for every construction),
#                           widened (Y is a strict subtype of O somewhere),
#                           facts-widened (O = Y, the yields' values are
#                           bounded and the first value's are not), no-yield,
#                           none (no construction), or rejected CODE...
#                           (exactly these error kinds)
#   # value: V              (optional) the value every backend must produce
#   # analyze-only          (optional) compile and record, never run
#
# and the tool checks the observation (and V) against it. Exits 1 on a
# mismatch or a backend disagreement. Writes DIR/matrix.tsv (one row per
# construction, or per program when it has none) and DIR/census.txt.

set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set options [dict merge [list -cases * -backends {interp compile cranelift-generic cranelift cranelift-unfused} \
    -out [file join $audit results] -external 1] $argv]
set argv {}
source [file join [file dirname [file dirname $audit]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval census {
    variable failures 0
    variable lines {}
    variable rows {}
}

proc census::out {line} {
    variable lines
    lappend lines $line
    puts $line
    flush stdout
}

proc census::Header {path} {
    set meta [dict create case "" class "" expect "" value "" analyze 0]
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    foreach line [split $text \n] {
        if {![string match "#*" $line]} break
        if {[regexp {^# (case|class|expect|value): (.*)$} $line -> key rest]} {
            dict set meta $key [string trim $rest]
        } elseif {[string trim $line] eq "# analyze-only"} {
            dict set meta analyze 1
        }
    }
    return $meta
}

proc census::Show {type} {
    if {$type eq ""} { return "" }
    return [hir::types::show $type]
}

# The instances of SPEC whose block is BLOCK ("program" for top-level code).
proc census::InstancesOf {spec block} {
    set ids {}
    foreach id [dict get $spec used] {
        if {[dict get $spec instances $id block] eq $block} {
            lappend ids $id
        }
    }
    return $ids
}

# The function block whose code holds expression E ("program" at the top).
proc census::BlockOfExpr {hir e} {
    set scope [dict get $hir exprs $e scope]
    set b [dict get $hir scopes $scope invocation]
    if {$b eq ""} { return program }
    return $b
}

proc census::RangeOf {hir spec analysis e} {
    set r ""
    foreach id [InstancesOf $spec [BlockOfExpr $hir $e]] {
        set one [hir::range::of $analysis $id $e]
        set r [expr {$r eq "" ? $one : [hir::range::join $r $one]}]
    }
    if {$r eq ""} { return "?" }
    return [hir::range::show $r]
}

# The construction facts of HIR, one dict per coroutine#create, in source
# order (ExprId order).
proc census::Constructions {hir spec analysis} {
    set result {}
    set thunks [lsort -command {apply {{a b} {
        expr {[string range $a 1 end] - [string range $b 1 end]}}}} [hir::coroutines::thunks $hir]]
    foreach thunk $thunks {
        set info [dict get $hir coroutines thunks $thunk]
        set root [dict get $info root]
        set create [dict get $info create]
        set row [dict create root ? declared "" R "" Y - O "" Yr - first "" firstRange ""]
        if {$root ne ""} {
            set block [hir::coroutines::BlockOf $root]
            dict set row root [hir::coroutines::Name $hir $root]
            dict set row declared [Show [dict get $hir exprs $block declaredResult]]
            if {[dict get $hir exprs $block resultType] ne ""} {
                dict set row R [Show [hir::type $hir [dict get $hir exprs $block resultType]]]
            }
            set y ""
            set yr ""
            foreach {yield type} [hir::coroutines::YieldTypes $hir $root 1] {
                set y [expr {$y eq "" ? $type : [hir::types::lub $y $type]}]
                if {$analysis ne ""} {
                    set value [lindex [dict get $hir exprs $yield args] 0]
                    set yblock [dict get $hir coroutines yields $yield]
                    foreach id [InstancesOf $spec $yblock] {
                        set one [hir::range::of $analysis $id $value]
                        set yr [expr {$yr eq "" ? $one : [hir::range::join $yr $one]}]
                    }
                }
            }
            if {$y ne ""} {
                dict set row Y [Show $y]
                dict set row Yraw $y
            }
            if {$yr ne ""} { dict set row Yr [hir::range::show $yr] }
        }
        set handle [hir::typeOf $hir $create]
        if {[hir::types::IsCoroutine $handle]} {
            dict set row O [Show [hir::types::CoroutineOutward $handle]]
            dict set row Oraw [hir::types::CoroutineOutward $handle]
        }
        # The construction's start call: the bind after the handle's bind.
        foreach e [hir::walk $hir] {
            if {[hir::coroutines::NativeOf $hir $e] ne [core::coroutines::startNative]} continue
            if {[hir::coroutines::thunkOfHandle $hir [lindex [dict get $hir exprs $e args] 0]] ne $thunk} continue
            dict set row first [Show [hir::typeOf $hir $e]]
            if {$analysis ne ""} {
                dict set row firstRange [RangeOf $hir $spec $analysis $e]
            }
        }
        lappend result $row
    }
    return $result
}

proc census::Observation {diags constructions} {
    if {$diags ne {}} {
        return [list rejected {*}$diags]
    }
    if {$constructions eq {}} {
        return none
    }
    set widened 0
    set facts 0
    set yields 0
    foreach c $constructions {
        if {[dict get $c Y] eq "-"} continue
        incr yields
        if {[dict get $c Y] ne [dict get $c O]
                && [hir::types::subtype [dict get $c Yraw] [dict get $c Oraw]]} {
            # The yields send values of a strict subtype of what every
            # segment returns (an outward type narrower than the generic
            # yields' join -- a semantic instance's -- is no widening).
            set widened 1
        } elseif {[dict get $c Yr] ni {- ? {[-∞, +∞]}} && [dict get $c firstRange] eq {[-∞, +∞]}} {
            # The yields' values are bounded, the first value is not: range
            # facts stopped at the coroutine boundary.
            set facts 1
        }
    }
    if {$yields == 0} { return no-yield }
    if {$widened} { return widened }
    return [expr {$facts ? "facts-widened" : "precise"}]
}

proc census::Case {path label {analyzeOnly 0}} {
    variable failures
    variable rows
    set meta [Header $path]
    if {$analyzeOnly} {
        dict set meta analyze 1
    }
    set analysis ""
    set spec ""
    set codes {}
    set constructions {}
    if {[catch {surface::readProgramFile $path -warnings off -strict 0} hir opts]} {
        set codes [list [lindex [dict get $opts -errorcode] end]]
        set hir ""
    } else {
        set codes [lsort -unique [lmap d [hir::diagnostics $hir] {dict get $d kind}]]
        if {$codes eq {}} {
            set spec [hir::specialize::analyze $hir]
            set analysis [hir::range::analyze $hir $spec]
        }
        set constructions [Constructions $hir $spec $analysis]
    }
    set observed [Observation $codes $constructions]
    # Runs: every backend, identical outcomes.
    set outcome ""
    set agree "-"
    if {$codes eq {} && ![dict get $meta analyze]} {
        set outcomes {}
        foreach b [dict get $::options -backends] {
            lappend outcomes $b [lrange [outcomeUnderHir $b $hir] 0 end-1]
        }
        set distinct [lsort -unique [dict values $outcomes]]
        if {[llength $distinct] == 1} {
            set agree yes
            set outcome [lindex $distinct 0]
        } else {
            set agree NO
            set outcome $outcomes
        }
    }
    set problems {}
    if {[dict get $meta expect] ne "" && [dict get $meta expect] ne $observed} {
        lappend problems "expected [dict get $meta expect], observed $observed"
    }
    if {$agree eq "NO"} {
        lappend problems "backends disagree: $outcome"
    }
    if {[dict get $meta value] ne "" && $agree eq "yes"} {
        set got [lindex $outcome 1]
        if {[lindex $outcome 0] ne "value" || $got ne [dict get $meta value]} {
            lappend problems "expected value [dict get $meta value], got $outcome"
        }
    }
    set verdict [expr {$problems eq {} ? "ok" : "MISMATCH"}]
    if {$problems ne {}} { incr failures }
    out "$label: [dict get $meta class] / $observed / $verdict"
    out "    [dict get $meta case]"
    foreach c $constructions {
        out [format "    %s: declared %s, R %s, Y %s, O %s, Yr %s; first %s %s" \
            [dict get $c root] [expr {[dict get $c declared] eq "" ? "-" : [dict get $c declared]}] \
            [dict get $c R] [dict get $c Y] [dict get $c O] [dict get $c Yr] [dict get $c first] [dict get $c firstRange]]
    }
    if {$outcome ne ""} { out "    run ($agree): $outcome" }
    foreach p $problems { out "    !! $p" }
    if {$constructions eq {}} {
        set constructions [list [dict create root - declared - R - Y - O - Yr - first - firstRange -]]
    }
    foreach c $constructions {
        lappend rows [list $label [dict get $meta class] $observed $verdict [dict get $c root] \
            [dict get $c declared] [dict get $c R] [dict get $c Y] [dict get $c O] [dict get $c Yr] \
            [dict get $c first] [dict get $c firstRange] $agree]
    }
}

# The repository's own consumers whose types the report cites (analyzed,
# never run: some write files).
set external {
    examples/dfa/csv/export.bot
    examples/dfa/csv/sinks.bot
    examples/dfa/json/sinks.bot
}

foreach path [lsort [glob -directory [file join $audit cases] [dict get $options -cases].bot]] {
    census::Case $path [file rootname [file tail $path]]
}
if {[dict get $options -external]} {
    foreach rel $external {
        set path [file join $::projectRoot $rel]
        census::Case $path $rel 1
    }
}

file mkdir [dict get $options -out]
set f [open [file join [dict get $options -out] matrix.tsv] w]
fconfigure $f -encoding utf-8
puts $f [join {case class observed verdict root declared R Y O Yrange first firstRange backends} \t]
foreach row $census::rows { puts $f [join $row \t] }
close $f
set f [open [file join [dict get $options -out] census.txt] w]
fconfigure $f -encoding utf-8
puts $f [join $census::lines \n]
close $f
census::out "[llength $census::rows] rows, $census::failures mismatches"
exit [expr {$census::failures ? 1 : 0}]
