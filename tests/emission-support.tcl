# emission-support.tcl -- what the emission-claim tests and audit tools share
# (EMISSION-CLAIMS-MILESTONE-1.md):
#
#   emit::workspace ?NAME TEXT ...?   a private application directory: the
#                                     JSON workload's modules
#                                     (examples/dfa/json) and the files given
#   emit::compile PATH ?OPTIONS?      the lenient HIR of a program file
#                                     (its claims' diagnostics in it)
#   emit::results HIR ?FILES?         {NAME VERDICT KINDS}... of the claims
#                                     declared in FILES (main.bot)
#   emit::reference DIR               the reference interpreter's model of
#                                     every recognizer of DIR's files
#   emit::judge MODEL KEY OUTCOME SYMBOLS   ok | {invalid REASON}
#   emit::strip TEXT                  TEXT without its emission claims
#   emit::conformance DIR COUNT SEED  {CASES MISMATCHES}: the checker's
#                                     recognizer step against the reference
#                                     interpreter
#
#   source tests/emission-support.tcl   (after tests/helpers.tcl)
#
# The judge is tests/dfa-support.tcl's reference interpreter (dfaref::),
# which reads the declarations themselves -- nothing of surface/dfa.tcl,
# nothing of the checker: a complete run must be exactly one token with
# nothing unread, a failed or truncated one a viable prefix.

if {[info commands ::dfaref::run] eq ""} {
    source [file join $::projectRoot tests dfa-support.tcl]
}

namespace eval emit {
    variable jsonDir [file join $::projectRoot examples dfa json]
    # Where workspaces are made (workspace): "" until the first one.
    variable base ""
    variable counter 0
    variable scratches {}
}

# A new private directory holding the JSON workload's modules and the
# files FILES (NAME TEXT ...). Under tcltest's temporary directory when a
# test runs, else under a `file tempdir` directory; removed by cleanup.
proc emit::workspace {args} {
    variable jsonDir
    variable counter
    variable scratches
    variable base
    if {$base eq ""} {
        if {[info exists ::argv0] && [string match *.test [file tail $::argv0]]} {
            # A test file: its tcltest temporary directory (-tmpdir).
            set base [::tcltest::temporaryDirectory]
        } else {
            # A tool: a private directory of its own, never the working
            # directory.
            set base [file tempdir]
        }
    }
    set dir [file join $base emit-[pid]-[incr counter]]
    file delete -force $dir
    file mkdir $dir
    lappend scratches $dir
    foreach path [glob -directory $jsonDir *.bot] {
        file copy -force $path [file join $dir [file tail $path]]
    }
    foreach {name text} $args {
        set f [open [file join $dir $name] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $text
        close $f
    }
    return $dir
}

proc emit::cleanup {} {
    variable scratches
    variable base
    foreach dir $scratches {
        file delete -force $dir
    }
    set scratches {}
    if {$base ne "" && [string match *.test [file tail $::argv0]] == 0} {
        file delete -force $base
        set base ""
    }
}

proc emit::readText {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc emit::writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The lenient HIR of the program at PATH: its diagnostics in it, never
# raised.
proc emit::compile {path args} {
    return [surface::readProgramFile $path -warnings off -strict 0 {*}$args]
}

# {NAME VERDICT KINDS}... of the claims of HIR declared in FILES (file
# names; every file when FILES is *), in order: NAME the function's name
# without its namespace, VERDICT hir::emission's, KINDS the sorted kinds of
# the diagnostics anchored at the claimed function.
proc emit::results {hir {files main.bot}} {
    set out {}
    foreach r [hir::emission::claims $hir] {
        set origin [dict get $r origin]
        if {$files ne "*"} {
            if {[lindex $origin 0] ne "file"} continue
            set path [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
            if {[file tail $path] ni $files} continue
        }
        set b [dict get $r block]
        set kinds [lsort -unique [lmap d [dict get $hir diagnostics] {
            if {[dict getdef $d expr ""] ne $b || ![string match EMIT-* [dict get $d kind]]} continue
            dict get $d kind
        }]]
        lappend out [list [namespace tail [dict get $r function]] [dict get $r verdict] $kinds]
    }
    return $out
}

# The reference interpreter's model of every recognizer of the .bot files
# of DIR (MAIN the entry program's file).
proc emit::reference {dir {main main.bot}} {
    set files {}
    foreach path [glob -directory $dir *.bot] {
        set name [file rootname [file tail $path]]
        if {[file tail $path] eq $main} {
            lappend files "" $path
        } else {
            lappend files $name $path
        }
    }
    return [dfaref::load $files]
}

# ok, or {invalid REASON}: what the reference interpreter says of a run of
# an emitter claiming recognizer KEY ({NS NAME}) of MODEL, OUTCOME complete,
# failed or truncated, SYMBOLS its trace.
proc emit::judge {model key outcome symbols} {
    lassign $key ns name
    set n [llength $symbols]
    if {$outcome eq "complete"} {
        set r [dfaref::run $model $ns $name [concat $symbols -1] 0]
        if {[lindex $r 0] eq "accept" && [lindex $r 1] == $n} {
            return ok
        }
        return [list invalid "completes with [list $symbols], which is not one token: [dfaref::text $r]"]
    }
    if {$n == 0} { return ok }
    set r [dfaref::run $model $ns $name $symbols 0]
    if {[lindex $r 0] eq "suspended" || ([lindex $r 0] eq "accept" && [lindex $r 1] == $n)} {
        return ok
    }
    return [list invalid "yields [list $symbols] before it fails, which is no prefix of a token: [dfaref::text $r]"]
}

# TEXT with every function header's emission claims removed (a claim is
# erased: the program is the same code without it).
proc emit::strip {text} {
    return [regsub -all -line {^(\s*(?:(?:private|nomethod)\s+)*fn\s[^\n]*?) emits [A-Za-z0-9_:, ]*[A-Za-z0-9_](:\s*)$} $text {\1\2}]
}

# ---------------------------------------------------------------------------
# The checker's recognizer semantics against the reference interpreter

# The checker's outcome for INPUTS (symbols, -1 the end) from recognizer
# KEY, stepped one symbol at a time, in dfaref::text's form.
proc emit::stepOutcome {key inputs} {
    set c [hir::emission::Initial $key]
    set i 0
    foreach x $inputs {
        set r [hir::emission::Step $c [hir::intset::point $x]]
        if {[llength $r] != 1} {
            return "nondeterministic at $i"
        }
        lassign [lindex $r 0] y result
        if {$result eq "done"} {
            if {$x == -1} {
                return "accept $i 0"
            }
            return "accept [expr {$i + 1}] 0"
        }
        if {[lindex $result 0] eq "violation"} {
            lassign $result - kind rkey q n
            switch -- $kind {
                beyond {
                    if {$x == -1} {
                        return "accept [expr {$i - $n}] $n"
                    }
                    return "accept [expr {$i + 1 - $n}] $n"
                }
                reject {
                    set what [expr {$x == -1 ? "end" : "unrecognized"}]
                    return "$what [hir::emission::KeyText $rkey] $q $i"
                }
                default {
                    return "$kind $i"
                }
            }
        }
        set c $result
        incr i
    }
    return suspended
}

# {CASES MISMATCHES}: every case dfatest::cases makes (COUNT walks, SEED) for
# every recognizer of the program DIR/main.bot, the reference interpreter's
# outcome against the checker's step (hir/emitdfa.tcl over core/dfa.tcl's
# outcome model, from the tables the HIR carries).
proc emit::conformance {dir count seed} {
    set hir [emit::compile [file join $dir main.bot]]
    hir::emission::LoadRecognizers $hir
    set model [emit::reference $dir]
    set cases 0
    set mismatches {}
    dict for {key r} $::hir::emission::recognizers {
        lassign $key ns name
        foreach input [dfatest::cases $model $ns $name $count $seed] {
            incr cases
            set ref [dfaref::text [dfaref::run $model $ns $name $input 0]]
            set got [emit::stepOutcome $key $input]
            if {$ref ne $got} {
                lappend mismatches [list $key $input $ref $got]
            }
        }
    }
    return [list $cases $mismatches]
}
