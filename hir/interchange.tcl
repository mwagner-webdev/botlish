# interchange.tcl -- the HIR interchange format (HIR-INTERCHANGE.md).
#
#   hir::interchange::encode HIR ?-trait-source 0|1?    the format's text of HIR
#   hir::interchange::decode TEXT ?-target T?           the HIR it holds, activated
#   hir::interchange::writeFile PATH HIR ?-trait-source 0|1?
#   hir::interchange::readFile PATH ?-target T?
#   hir::interchange::fingerprint                       this front end's identity
#
# A fully analyzed HIR -- the front end's output, what every backend starts
# from -- written so that another process, or this one later, can lower and
# run it exactly as if it had just been built: the same core IR, the same Tcl
# code, the same NIR, the same outcomes (audit/hir-interchange/tools/
# roundtrip.tcl checks it over the golden corpus, in a fresh process).
#
# That is possible because a HIR is self-contained: it holds every analysis
# fact its backends read (side tables included: semantic instances,
# coroutine protocols, completion verdicts, ...), and its `declarations` side
# table holds the registry state its build left behind (COMPILATION-
# ISOLATION.md), which decode installs. Unlike hir::format's text -- a
# readable rendering for debugging and tests, which does not carry module
# sections or the side tables -- the format is the HIR value itself.
#
# Text:
#
#   botlish-hir-interchange VERSION
#   compiler FINGERPRINT requires LIBRARIES hir HIR
#
# the second line a Tcl dict (it may span many lines): FINGERPRINT the front
# end that built the HIR (fingerprint), LIBRARIES the Tcl libraries
# core::loadLibrary had loaded (natives a `# requires:` program file calls),
# HIR the HIR without its `traitSource` (the checked source build of a trait
# program, kept for warnings and the context-trait summary; half the size),
# unless -trait-source 1 keeps it.
#
# A HIR's representation is the front end's own, so the format is valid for
# the front end that built it only: decode refuses another one's text
# ({HIR INTERCHANGE COMPILER}). The backends may differ: they read a HIR.
#
# A HIR is also its target's (hir::cabi::targetOf: the compilation target,
# when the build depended on it -- std::ffi::c's scalars, a platform or an
# architecture-specific module). The text carries it inside the HIR, and a
# decoded HIR keeps it, and its target's facts, whoever reads it: nothing is
# reinterpreted for the reader's target. decode -target T is a compilation
# for T (main.tcl passes its -target, or the host's): it refuses a HIR built
# for another target ({HIR INTERCHANGE TARGET}, hir::cabi::TargetMismatch),
# however much the two share (linux-aarch64 and macos-aarch64 share an
# architecture and a pointer width, not plain char's signedness), and
# accepts a HIR that is every target's. Without -target nothing is checked
# (the HIR stays its own target's: the native driver refuses to run one built
# for another host).

namespace eval hir::interchange {
    variable version 1
    variable magic botlish-hir-interchange
    # The front end's identity, computed on first use.
    variable fingerprint ""
}

# This compiler's front end's identity (Fingerprint of the tree it was loaded
# from), computed once.
proc hir::interchange::fingerprint {} {
    variable fingerprint
    if {$fingerprint eq ""} {
        set fingerprint [Fingerprint [file dirname $::hir::home]]
    }
    return $fingerprint
}

# The identity of the front end in the tree ROOT: a checksum of every Tcl
# source file that can change the HIR it builds -- core (the registered types
# and natives, the evaluator the front end shares), hir, surface, and any Tcl
# library in stdlib (core::loadLibrary) -- with their names and sizes, and the Tcl version. The
# backends (compiler, native) are not in it: they read a HIR, never shape it,
# and a HIR built by an unchanged front end is the HIR they would see from a
# fresh build (HIR-INTERCHANGE.md, "Validity").
proc hir::interchange::Fingerprint {root} {
    set lines [list [list tcl [info patchlevel]]]
    set total 0
    foreach dir {core hir surface stdlib} {
        foreach path [lsort [glob -nocomplain -directory [file join $root $dir] -types f *.tcl]] {
            set f [open $path rb]
            set bytes [read $f]
            close $f
            incr total [string length $bytes]
            lappend lines [list $dir/[file tail $path] [string length $bytes] \
                [zlib crc32 $bytes] [zlib adler32 $bytes]]
        }
    }
    set digest [encoding convertto utf-8 [join $lines \n]]
    return [format %08x%08x-%d [zlib crc32 $digest] [zlib adler32 $digest] $total]
}

proc hir::interchange::encode {hir args} {
    variable version
    variable magic
    set options [hir::Options hir::interchange::encode {-trait-source 0} $args]
    if {![dict exists $hir declarations]} {
        error "hir::interchange::encode: the HIR records no declaration state (hir/declarations.tcl): it is not self-contained"
    }
    if {![dict get $options -trait-source]} {
        set hir [dict remove $hir traitSource]
    }
    return "$magic $version\n[list compiler [fingerprint] requires $::core::loadedLibraries hir [WithoutRepresentations $hir]]\n"
}

# HIR without the representation a DecimalRounded constant's `value` caches
# for the backends (left empty, so the decoded node's fields keep their order) (DECIMAL-ROUNDED-MILESTONE-1.md, "Interchange"): the
# text holds the constant's exact decimal (its `literal`) and its type, never
# the binary64 this front end chose for it, which decode chooses again
# (WithRepresentations) -- a front end with another representation strategy
# reads the same text as the same program.
proc hir::interchange::WithoutRepresentations {hir} {
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "const" && [lindex [dict get $node literal] 0] eq $::core::decimal::kind} {
            dict set hir exprs $e value ""
        }
    }
    return $hir
}

# HIR with every DecimalRounded constant's representation chosen again from
# its exact decimal (core::ir::literalValue, core::decimal::constant).
proc hir::interchange::WithRepresentations {hir} {
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "const" && [lindex [dict get $node literal] 0] eq $::core::decimal::kind} {
            dict set hir exprs $e value [core::ir::literalValue [list const {*}[dict get $node literal]]]
        }
    }
    return $hir
}

proc hir::interchange::decode {text args} {
    variable version
    variable magic
    set check [dict exists $args -target]
    set options [hir::Options hir::interchange::decode {-target ""} $args]
    set newline [string first \n $text]
    set header [string range $text 0 [expr {$newline < 0 ? "end" : $newline - 1}]]
    if {[catch {llength $header} words] || $words != 2 || [lindex $header 0] ne $magic} {
        throw {HIR INTERCHANGE FORMAT} "not HIR interchange text (it starts \"[string range $header 0 40]\")"
    }
    if {[lindex $header 1] ne $version} {
        throw {HIR INTERCHANGE FORMAT} "HIR interchange version [lindex $header 1]: this compiler reads version $version"
    }
    set body [string range $text [expr {$newline + 1}] end]
    if {[catch {dict size $body}] || ![dict exists $body compiler] || ![dict exists $body hir]
            || [catch {dict size [dict get $body hir]}]} {
        throw {HIR INTERCHANGE FORMAT} "HIR interchange text without its compiler or its HIR"
    }
    if {[dict get $body compiler] ne [fingerprint]} {
        throw {HIR INTERCHANGE COMPILER} "HIR interchange text built by another front end ([dict get $body compiler]; this one is [fingerprint])"
    }
    set hir [WithRepresentations [dict get $body hir]]
    # The link plan is what a native link is made of (NATIVE-LINK-PLAN-
    # MILESTONE-1.md): an entry this front end cannot have built -- an
    # unknown kind or linkage, a missing field -- is refused, never
    # dropped or linked some other way.
    set plans [list [dict getdef $hir links {}]]
    if {[dict exists $hir declarations foreign links]} {
        lappend plans [dict get $hir declarations foreign links]
    }
    foreach plan $plans {
        set problem [hir::foreign::LinkPlanProblem $plan]
        if {$problem ne ""} {
            throw {HIR INTERCHANGE FORMAT} "HIR interchange text with a malformed link plan: $problem"
        }
    }
    if {$check} {
        set problem [hir::cabi::TargetMismatch $hir [dict get $options -target]]
        if {$problem ne ""} {
            throw {HIR INTERCHANGE TARGET} "HIR interchange text for another target: $problem"
        }
    }
    foreach name [dict getdef $body requires {}] {
        core::loadLibrary $name
    }
    hir::activate $hir
    return $hir
}

# Files are UTF-8 with LF line ends, whatever the platform.
proc hir::interchange::writeFile {path hir args} {
    set text [encode $hir {*}$args]
    set f [open $path w]
    try {
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $text
    } finally {
        close $f
    }
    return $path
}

proc hir::interchange::readFile {path args} {
    set f [open $path r]
    try {
        fconfigure $f -encoding utf-8 -translation lf
        set text [read $f]
    } finally {
        close $f
    }
    return [decode $text {*}$args]
}
