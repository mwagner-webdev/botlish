# check-unicode-parity.tcl -- cross-language differential check for
# web::Emailish's Unicode-aware grammar (NATIVE-TCL-UNICODE.md): runs the
# same corpus of email-shaped strings through
#
#   Tcl      core::regex::matches against emailRegex below (the reference
#            grammar, formerly lib/web.tcl's validator)
#   Botlish  web::emailish? (lib/web.bot, the proof-producing predicate of
#            the refinement web::Emailish, REFINEMENT-VALUES.md) on
#            interp/compile/cranelift-generic/cranelift
#   Python   bench/equivalents/python/refined_checks.py's emailish()
#   Rust     bench/equivalents/rust/refined_checks.rs's emailish() (via the
#            already-built benchmark binary, run once per string with n=1
#            so its own check(1, 0, s, q) result is exactly emailish(s))
#
# and reports any disagreement. This is the spec's "hard acceptance
# criterion" cross-language check (spec item 29), kept as a runnable script
# rather than only prose in NATIVE-TCL-UNICODE.md.
#
#   tclsh9.0 bench/check-unicode-parity.tcl

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000

set emailRegex [core::regex::create {
    seq
    {repeat {set {class alnum} {char .} {char _} {char %} {char +} {char -}} 1 inf}
    {lit @}
    {repeat {seq {repeat {set {class alnum} {char -}} 1 inf} {lit .}} 1 inf}
    {repeat {class alpha} 2 inf}
}]

set corpus {
    someone@example.com
    not-an-email
    a@b.co
    a@b.c
    a.b_c%d+e-f@sub.example.com
    @example.com
    a@
    a@.com
    a@b..com
    a@b.com.
    a@b.c1
    café@example.com
    user@例え.テスト
    user@example.co日
    a@b.cD
    {}
    a@b٠.com
    a@例え.Ⅰ
    café@例え.テスト
}

proc tclReference {s} {
    return [expr {[core::regex::matches $::emailRegex [core::value::str $s]] ? "true" : "false"}]
}

proc emailishUnder {backend s} {
    set source "import web\nweb::emailish?(\"[string map {\\ \\\\ \" \\\"} $s]\")\n"
    set hir [surface::compile $source -warnings off]
    if {$backend in {cranelift cranelift-generic}} {
        set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
        return [core::value::show [native::evalHir $hir {*}$options]]
    }
    set saved [core::useBackend]
    core::useBackend $backend
    try {
        return [core::value::show [expr {$backend eq "compile" ? [core::compiler::evalHir $hir]
            : [core::evalProgram [hir::lower $hir]]}]]
    } finally {
        core::useBackend $saved
    }
}

proc pythonBatch {corpus} {
    set script {
import sys, importlib.util
spec = importlib.util.spec_from_file_location("refined_checks", sys.argv[1])
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
for s in sys.argv[2:]:
    print("true" if m.emailish(s) else "false")
    }
    set pyFile [file join $::root bench equivalents python refined_checks.py]
    set out [exec python3 -c $script $pyFile {*}$corpus]
    return [split $out "\n"]
}

proc rustBatch {corpus} {
    set bin [file join [file normalize /tmp] botlish-unicode-parity-check-bin]
    if {![file exists $bin]} {
        exec rustc -O [file join $::root bench equivalents rust refined_checks.rs] -o $bin
    }
    set results {}
    foreach s $corpus {
        set out [exec $bin --runs 1 1 $s not-an-email {a b}]
        regexp {value: \[(\d+),} $out -> hit
        lappend results [expr {$hit ? "true" : "false"}]
    }
    return $results
}

puts "Building/loading reference implementations..."
set pyResults [pythonBatch $corpus]
set rustResults [rustBatch $corpus]

set backends {interp compile cranelift-generic cranelift}
set mismatches 0
set i 0
foreach s $corpus {
    set tcl [tclReference $s]
    set row [dict create tcl $tcl]
    foreach b $backends {
        dict set row $b [emailishUnder $b $s]
    }
    dict set row python [lindex $pyResults $i]
    dict set row rust [lindex $rustResults $i]
    set values [dict values $row]
    set agree [expr {[llength [lsort -unique $values]] == 1}]
    set label [expr {[string length $s] == 0 ? {<empty>} : $s}]
    puts [format "%-2s %-35s %s" [expr {$agree ? "OK" : "!!"}] $label $row]
    if {!$agree} {
        incr mismatches
    }
    incr i
}

if {$mismatches > 0} {
    puts "\n$mismatches mismatch(es) found."
    exit 1
} else {
    puts "\nAll [llength $corpus] cases agree across Tcl/interp/compile/cranelift-generic/cranelift/Python/Rust."
    exit 0
}
