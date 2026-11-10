# repro.tcl -- the two accepted-program soundness failures of
# EMISSION-BINDING-AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md
# (sections 13.3, 13.4, 15.3), reproduced with what the emission checker
# (hir/emission.tcl) decides on the way, for
# EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-MILESTONE-1.md:
#
#   * identity (N1, N2, N3, N5, and the sequence N4a then N4b in one
#     process): for every claim, its block, the binding that declares it
#     (its scope and the lexical path of enclosing functions), its bare name,
#     the block `byName` holds for the name, whether the name is ambiguous,
#     the memo and certificate-table key, whether the certificate was reused
#     or proved, the functions its certificate depends on with the
#     fingerprint recorded and the fingerprints of the claim's own block and
#     of the name's `byName` block -- with the memo on, then off;
#   * feasibility (F1, F2, F3, F4, and a known-false parameterless `if`):
#     every `Facts` call (the condition, the outcome, the size of the walk's
#     environment, hir::range's paths with each pair's known outcome, and
#     what `Facts` returned), every `if` the walk evaluated (the states it
#     returned), and the claim's exits, verdict and certificate;
#
# then, for each case, the strict outcome, and the run of the program with
# its claims erased on every backend, its trace judged by the reference
# interpreter (tests/dfa-support.tcl): a certified claim whose run is
# invalid is a FALSE CERTIFICATE.
#
#   tclsh9.0 audit/emission-identity/tools/repro.tcl ?-backends LIST? ?-out FILE?
#
# The programs are the census's (audit/emission-dependencies/census/
# cases.txt) and three of this milestone's own (below). A research
# instrument: it reads the checker's variables and traces its procedures
# (`trace add execution`, never a renamed command), and nothing in
# compilation loads it.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-backends {interp compile cranelift-generic cranelift} -out ""} $argv]
set argv {}
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root tests emission-support.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval repro {
    variable lines {}
    variable base [file tempdir]
    variable counter 0
    variable facts {}
    variable ifs {}
    variable falseCerts {}
}

# Which compiler ROOT is, for a report: its revision (and whether hir/ is
# modified), or a copy that is no checkout.
proc repro::Tree {root} {
    if {[catch {exec git -C $root rev-parse --short HEAD} rev] || [catch {exec git -C $root status --porcelain -- hir} dirty]} {
        return "on a copy of a tree that is no checkout ($root)"
    }
    return "at $rev[expr {$dirty eq "" ? "" : " with hir/ modified"}]"
}

proc repro::out {line} {
    variable lines
    lappend lines $line
    puts $line
}

# The single-file cases of the census: NAME -> main.bot's text.
proc repro::Cases {path} {
    set out [dict create]
    set name ""
    set text {}
    set inFile 0
    foreach line [split [emit::readText $path] \n] {
        if {[regexp {^@@ (\S+) } $line -> n]} {
            set name $n
            set text {}
            set inFile 0
            continue
        }
        if {$name eq ""} continue
        if {$line eq "@@end"} {
            dict set out $name "[string trimright [join $text \n] \n]\n"
            set name ""
            continue
        }
        if {$line eq "--- main.bot"} {
            set inFile 1
            continue
        }
        if {$inFile} {
            lappend text $line
        }
    }
    return $out
}

proc repro::Directory {text} {
    variable base
    variable counter
    set dir [file join $base case[incr counter]]
    file mkdir $dir
    emit::writeText [file join $dir main.bot] $text
    return $dir
}

# The lexical path of the function block B: the names of the functions
# whose bodies hold its declaration, outermost first, then its own.
proc repro::LexicalPath {hir b} {
    set path {}
    set s [dict get $hir exprs $b scope]
    while {$s ne ""} {
        set owner [dict get $hir scopes $s owner]
        if {$owner ne "" && [dict get $hir exprs $owner kind] eq "block"} {
            set n [dict getdef $::hir::emission::names $owner ""]
            if {$n ne ""} {
                set path [linsert $path 0 $n]
            }
        } elseif {$owner ne ""} {
            set path [linsert $path 0 [dict get $hir exprs $owner kind]]
        }
        set s [dict get $hir scopes $s parent]
    }
    return [join [concat $path [list [dict getdef $::hir::emission::names $b ?]]] /]
}

# The declaring binding of function block B: {BINDING SCOPE}.
proc repro::Declaring {hir b} {
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "bind" && [dict get $node value] eq $b} {
            set binding [dict get $node binding]
            return [list $binding [dict get $hir bindings $binding scope]]
        }
    }
    return {"" ""}
}

# The identity facts of every claim of HIR (just verified).
proc repro::Identity {hir} {
    set ::hir::emission::hir $hir
    set reused [dict getdef $::hir::emission::stats reusedClaims {}]
    set ambiguous [expr {[info exists ::hir::emission::ambiguous] ? $::hir::emission::ambiguous : {}}]
    set i 0
    foreach r [hir::emission::claims $hir] {
        incr i
        set b [dict get $r block]
        set name [dict getdef $::hir::emission::names $b ""]
        lassign [Declaring $hir $b] binding scope
        set first [dict getdef $::hir::emission::byName $name ""]
        set id [list $name [dict get $r recognizer]]
        set fp [hir::emission::FunctionFingerprint $b]
        out "  - claim $i: block `$b` (declared by binding `$binding` in scope `$scope`; lexical path `[LexicalPath $hir $b]`), name `$name`; byName($name) = `$first`; ambiguous: [expr {[dict exists $ambiguous $name] ? "yes" : "no"}]"
        out "    memo / certificate-table key `$id`; verdict **[dict get $r verdict]**[expr {[dict exists $r certificate] ? " (certificate)" : ""}]"
        out "    own fingerprint `$fp`; fingerprint of byName($name) `[expr {$first eq "" ? "-" : [hir::emission::FunctionFingerprint $first]}]`"
        if {[dict exists $r certificate]} {
            set deps [dict get $r certificate depends functions]
            out "    certificate depends on functions: [join [lmap {n f} $deps {string cat "`$n` `$f`"}] {, }]"
        }
    }
    out "  - reused from the memo in this compilation: [expr {$reused eq {} ? "none" : [join [lmap x $reused {string cat `$x`}] {, }]}]"
    set ::hir::emission::hir ""
}

proc repro::Verdicts {hir} {
    return [lmap r [hir::emission::claims $hir] {
        set v [dict get $r verdict]
        if {[dict exists $r certificate]} { append v + }
        set v
    }]
}

proc repro::Strict {dir} {
    set saved $::hir::emission::memo
    set ::hir::emission::memo [dict create]
    set out accepted
    if {[catch {surface::readProgramFile [file join $dir main.bot] -warnings off} message options]} {
        set out [lindex [dict get $options -errorcode] end]
    }
    set ::hir::emission::memo $saved
    return $out
}

# The run of TEXT, claims erased, on every backend: its traces and the
# judgment of the trace (the program's value, a List of symbols) against
# RECOGNIZER.
proc repro::Run {text recognizer} {
    set dir [Directory [emit::strip $text]]
    set model [emit::reference $dir]
    set key [list "" $recognizer]
    set traces {}
    set judgments {}
    foreach backend [dict get $::options -backends] {
        set result [exec [info nameofexecutable] [file join $::root main.tcl] -backend $backend \
            [file join $dir main.bot] 2>@1]
        if {![regexp {value: \[([^\]]*)\]} $result -> items]} {
            lappend traces "(no trace)"
            lappend judgments invalid
            continue
        }
        set symbols [lmap x [split $items ,] {string trim $x}]
        lappend traces $symbols
        lappend judgments [lindex [emit::judge $model $key complete $symbols] 0]
    }
    return [list [lsort -unique $traces] [lsort -unique $judgments]]
}

proc repro::RunLine {name text verdicts index {recognizer digit_token}} {
    variable falseCerts
    lassign [Run $text $recognizer] traces judgments
    set line "  - run, claims erased ([join [dict get $::options -backends] {, }]): trace [join [lmap t $traces {string cat \[[join $t {, }]\]}] { / }], judged [join $judgments /]"
    if {"invalid" in $judgments && [lindex $verdicts [expr {$index - 1}]] eq "proven+"} {
        append line " -- **FALSE CERTIFICATE**"
        lappend falseCerts $name
    }
    out $line
}

# ---------------------------------------------------------------------------
# The traces of the feasibility cases

proc repro::FactsEnter {cmd op} {
    variable pending
    lassign $cmd - condition outcome
    set hir $::hir::emission::hir
    set paths [hir::range::Paths $hir $condition $outcome]
    set shown [lmap p $paths {
        lmap pair $p {
            lassign $pair c o
            set k [hir::types::KnownOutcome $hir $c]
            string cat "$c=$o" [expr {$k eq {} ? " (unknown)" : " (known $k)"}]
        }
    }]
    set pending [list $condition $outcome [dict size $::hir::emission::env] $shown]
}

proc repro::FactsLeave {cmd code result op} {
    variable pending
    variable facts
    lassign $pending condition outcome size shown
    lappend facts "Facts($condition, $outcome): environment of $size binding(s); paths [join [lmap p $shown {string cat \{[join $p {, }]\}}] {; }]; returned `$result`"
}

proc repro::IfLeave {cmd code result op} {
    variable ifs
    lassign $cmd - e
    lassign $result states value
    lappend ifs "EvalIf($e) -> [expr {$states eq {} ? "no states: the walk ends at the if" : "states [join $states {, }]"}]"
}

proc repro::Feasibility {name text} {
    variable facts
    variable ifs
    set facts {}
    set ifs {}
    set dir [Directory $text]
    set ::hir::emission::memo [dict create]
    set ::hir::emission::useMemo 1
    trace add execution ::hir::emission::Facts enter repro::FactsEnter
    trace add execution ::hir::emission::Facts leave repro::FactsLeave
    trace add execution ::hir::emission::EvalIf leave repro::IfLeave
    set hir [emit::compile [file join $dir main.bot]]
    trace remove execution ::hir::emission::Facts enter repro::FactsEnter
    trace remove execution ::hir::emission::Facts leave repro::FactsLeave
    trace remove execution ::hir::emission::EvalIf leave repro::IfLeave
    set verdicts [Verdicts $hir]
    out ""
    out "### $name"
    out ""
    foreach f $facts { out "  - $f" }
    foreach i $ifs { out "  - $i" }
    foreach r [hir::emission::claims $hir] {
        set line "  - claim `[dict get $r function]`: **[dict get $r verdict]**"
        if {[dict exists $r certificate]} {
            append line ", certificate exits `[dict get $r certificate exits]`"
        }
        out $line
    }
    out "  - strict: [Strict $dir]"
    return [list $verdicts $dir]
}

# ---------------------------------------------------------------------------

set cases [repro::Cases [file join $root audit emission-dependencies census cases.txt]]
# This milestone's own: a parameterless `if` decided false whose dead branch
# is invalid (the established treatment of unreachable code keeps it out);
# one whose two branches both yield a digit (certifiable); an `if` reached
# after a preceding yield (the empty environment is what the walk has
# between a parameterless function's entry and its first binding).
set digit "import std::coroutine\nimport std::dfa\n\nclass digit = '0'..'9'\n\ndfa digit_token over ascii:\n    start:\n        digit -> accept\n\n"
set run "fn run() -> List\[int\]:\n    coroutine {step, first} = emitter()\n    last = step()\n    if std::coroutine::done?(step):\n        \[first\]\n    else:\n        \[first, -9\]\n\nrun()\n"
dict set cases P1 "${digit}fn emitter() -> int emits digit_token:\n    if false:\n        yield 65\n    else:\n        yield 49\n    0\n\n${run}"
dict set cases P2 "${digit}fn flip() -> bool:\n    true\n\nfn emitter() -> int emits digit_token:\n    if flip():\n        yield 49\n    else:\n        yield 50\n    0\n\n${run}"
dict set cases P3 "${digit}fn flip() -> bool:\n    true\n\nfn emitter() -> int emits digit_token:\n    if flip():\n        yield 49\n    0\n\n${run}"

repro::out "# Identity and feasibility: the census's counterexamples, reproduced"
repro::out ""
repro::out "Generated by `tclsh9.0 audit/emission-identity/tools/repro.tcl` (backends: [join [dict get $options -backends] {, }]), [repro::Tree $root]."
repro::out ""
repro::out "## Function identity"
foreach name {N1 N2 N3 N5} {
    set text [dict get $cases $name]
    set dir [repro::Directory $text]
    repro::out ""
    repro::out "### $name"
    foreach memo {1 0} {
        set ::hir::emission::memo [dict create]
        set ::hir::emission::useMemo $memo
        set hir [emit::compile [file join $dir main.bot]]
        repro::out ""
        repro::out "memo [expr {$memo ? "on (empty at the start)" : "off"}]: verdicts [repro::Verdicts $hir]"
        repro::out ""
        repro::Identity $hir
    }
    set ::hir::emission::useMemo 1
    repro::out "  - strict: [repro::Strict $dir]"
    if {$name eq "N2"} {
        set ::hir::emission::memo [dict create]
        repro::RunLine N2 $text [repro::Verdicts [emit::compile [file join $dir main.bot]]] 2
    }
}

repro::out ""
repro::out "### N4a then N4b, one process, the memo kept (the compiler service's revisions)"
set ::hir::emission::memo [dict create]
set ::hir::emission::useMemo 1
foreach name {N4a N4b} {
    set text [dict get $cases $name]
    set dir [repro::Directory $text]
    set hir [emit::compile [file join $dir main.bot]]
    set verdicts [repro::Verdicts $hir]
    repro::out ""
    repro::out "$name: verdicts $verdicts"
    repro::out ""
    repro::Identity $hir
    if {$name eq "N4b"} {
        set ::hir::emission::hir $hir
        foreach r [hir::emission::claims $hir] {
            if {[dict exists $r certificate]} {
                dict for {n f} [dict get $r certificate depends functions] {
                    set blocks [lmap {b nm} $::hir::emission::names {if {$nm ne $n} continue; set b}]
                    repro::out "    `$n`: recorded `$f`; the blocks of the name now: [join [lmap b $blocks {string cat `$b` " (" [repro::LexicalPath $hir $b] ") " `[hir::emission::FunctionFingerprint $b]`}] {, }]"
                }
            }
        }
        set ::hir::emission::hir ""
    }
    repro::RunLine "sequence $name" $text $verdicts 1
}
set ::hir::emission::memo [dict create]
set dir [repro::Directory [dict get $cases N4b]]
repro::out "  - N4b strict, fresh memo: [repro::Strict $dir]"

repro::out ""
repro::out "### N6a then N6b, one process, the memo kept"
set ::hir::emission::memo [dict create]
set ::hir::emission::useMemo 1
foreach name {N6a N6b} {
    set text [dict get $cases $name]
    set dir [repro::Directory $text]
    set hir [emit::compile [file join $dir main.bot]]
    set verdicts [repro::Verdicts $hir]
    repro::out ""
    repro::out "$name: verdicts $verdicts; memoized after it: [join [lmap k [dict keys $::hir::emission::memo] {string cat `$k`}] {, }]"
    repro::out ""
    repro::Identity $hir
    set ::hir::emission::hir $hir
    foreach r [hir::emission::claims $hir] {
        if {[dict exists $r certificate]} {
            dict for {n f} [dict get $r certificate depends functions] {
                set blocks [lmap {b nm} $::hir::emission::names {if {$nm ne $n} continue; set b}]
                repro::out "    `$n`: recorded `$f`; the blocks of the name: [join [lmap b $blocks {string cat `$b` " (" [repro::LexicalPath $hir $b] ") " `[hir::emission::FunctionFingerprint $b]`}] {, }]"
            }
        }
    }
    set ::hir::emission::hir ""
    repro::RunLine "sequence $name" $text $verdicts 1 pair_token
}

repro::out ""
repro::out "## The empty environment"
foreach name {F1 F2 F3 F4 P1 P2 P3} {
    set text [dict get $cases $name]
    lassign [repro::Feasibility $name $text] verdicts dir
    if {[string match {*run()*} $text]} {
        repro::RunLine $name $text $verdicts 1
    }
}

repro::out ""
repro::out "## Summary"
repro::out ""
repro::out "False certificates (a certified claim whose run is invalid): [llength $repro::falseCerts][expr {$repro::falseCerts eq {} ? "" : " -- [join $repro::falseCerts {, }]"}]"
if {[dict get $options -out] ne ""} {
    emit::writeText [dict get $options -out] "[join $repro::lines \n]\n"
}
file delete -force $repro::base
