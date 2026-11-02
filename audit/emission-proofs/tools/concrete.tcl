# concrete.tcl -- running emitters for real, and judging their traces with
# an independent recognizer (MODULAR-EMISSION-PROOFS-MILESTONE-1.md,
# "Correctness evidence").
#
#   source audit/emission-proofs/tools/concrete.tcl   (sources tests/helpers.tcl)
#   concrete::traces DIR ENTRY FN TYPES TUPLES ?-backend B?
#       => {ARGS OUTCOME SYMBOLS}... : each argument tuple's run
#   concrete::judge FILES KEY OUTCOME SYMBOLS
#       => ok | {invalid REASON}
#   concrete::witness CLAIM   => "" or the first argument tuple whose run
#                                violates the claim (modcheck's verdict
#                                `disproven`)
#
# A run is a generated program beside the emitter's module: the function
# called inside a coroutine root that catches every error it declares
# (completing with -3, `failed`) and completes with -1 (`complete`); the
# consumer collects the symbols. Argument values come from lists the
# compiler cannot see through (a list loop's elements), so a call that
# always fails for one constant is still compiled.
#
# The judge is tests/dfa-support.tcl's reference interpreter (dfaref::),
# which reads the declarations themselves -- nothing of surface/dfa.tcl's
# model, nothing of the checker: a complete run must be exactly one token
# with nothing unread, a failed or truncated one a viable prefix.

# The repository: EMISSION_PROOFS_ROOT when set (mutate.tcl runs a copy of
# these tools from a temporary directory), else the one these tools are in.
if {[info exists ::env(EMISSION_PROOFS_ROOT)]} {
    set ::emissionProofsRoot $::env(EMISSION_PROOFS_ROOT)
} else {
    set ::emissionProofsRoot [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
}
if {[info commands ::tcltest::test] eq ""} {
    source [file join $::emissionProofsRoot tests helpers.tcl]
}
if {[info commands ::dfaref::run] eq ""} {
    source [file join $::projectRoot tests dfa-support.tcl]
}

namespace eval concrete {
    variable limit 400
    variable maxTuples 120
    variable counter 0
}

# The source spelling of HIR type TYPE for a driver, or "" when the driver
# cannot write its values.
proc concrete::Spelling {type} {
    if {$type in {int str bool}} { return $type }
    if {[lindex $type 0] eq "refined" && [lindex $type 1] eq "int"} {
        return [lindex $type 2]
    }
    if {$type eq {list int}} { return "List\[int\]" }
    return ""
}

proc concrete::Literal {type v} {
    switch -- $type {
        str {
            set out "\""
            foreach ch [split $v ""] {
                switch -- $ch {
                    "\"" - "\\" { append out \\$ch }
                    "\n" { append out "\\n" }
                    "\r" { append out "\\r" }
                    "\t" { append out "\\t" }
                    default { append out $ch }
                }
            }
            return "$out\""
        }
        bool { return [expr {$v ? "true" : "false"}] }
    }
    if {$type eq {list int}} {
        return "\[[join $v {, }]\]"
    }
    return $v
}

# The traces of FN (its name as the entry program sees it: NS::NAME) for
# each argument tuple of TUPLES, its parameters of HIR types TYPES and its
# declared errors ERRORS, run in a program beside ENTRY (in its directory).
proc concrete::traces {entry fn types errors tuples args} {
    variable limit
    variable counter
    set options [dict merge {-backend compile -imports {}} $args]
    set dir [file dirname [file normalize $entry]]
    set ns [namespace qualifiers $fn]
    set spellings [lmap t $types {Spelling $t}]
    if {"" in $spellings} {
        return ""
    }
    set params [lmap t $spellings i [lsearch -all $types *] {string cat a$i ": " $t}]
    set names [lmap i [lsearch -all $types *] {string cat a$i}]
    set text ""
    if {$ns ne ""} { append text "import $ns\n" }
    foreach i [dict get $options -imports] { append text "import $i\n" }
    append text "import std::coroutine\n\n"
    set call "${fn}([join $names {, }])"
    append text "fn src([join $params {, }]) -> int:\n"
    if {$errors eq {}} {
        append text "    $call\n"
    } else {
        append text "    $call:\n"
        foreach e $errors {
            append text "        on $e:\n            return -3\n"
        }
    }
    append text "    -1\n\n"
    append text "fn trace([join $params {, }]) -> List\[int\]:\n"
    append text "    coroutine {step, first} = src([join $names {, }])\n"
    append text "    loop k from 0 to $limit:\n"
    append text "        if k == 0:\n            first\n"
    append text "        elif std::coroutine::done?(step):\n            -9\n"
    append text "        else:\n            step()\n\n"
    foreach t $spellings type $types i [lsearch -all $types *] {
        append text "fn cases${i}() -> List\[$t\]{length: [llength $tuples]}:\n    \[[join [lmap tuple $tuples {Literal $type [lindex $tuple $i]}] {, }]\]\n\n"
    }
    if {$names eq {}} {
        append text "loop k from 0 to [llength $tuples]:\n    trace()\n"
    } else {
        set domains [join [lmap n $names i [lsearch -all $names *] {string cat "$n in cases${i}()"}] " and "]
        append text "loop $domains:\n    trace([join $names {, }])\n"
    }
    set file [file join $dir "concrete_[pid]_[incr counter].bot"]
    set f [open $file w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    set code [catch {
        set hir [surface::readProgramFile $file -warnings off]
        set outcome [outcomeUnderHir [dict get $options -backend] $hir]
    } msg]
    file delete $file
    if {$code} {
        return -code error "concrete: $fn: $msg"
    }
    if {[lindex $outcome 0] ne "value"} {
        return -code error "concrete: $fn: [lindex $outcome 2]"
    }
    set value [lindex [string map {\[ \{ \] \} , ""} [lindex $outcome 1]] 0]
    set out {}
    foreach tuple $tuples run $value {
        set end [lsearch -exact $run -9]
        if {$end < 0} {
            lappend out [list $tuple truncated $run]
            continue
        }
        set terminal [lindex $run [expr {$end - 1}]]
        set symbols [lrange $run 0 [expr {$end - 2}]]
        lappend out [list $tuple [expr {$terminal == -1 ? "complete" : "failed"}] $symbols]
    }
    return $out
}

# ok, or {invalid REASON}: what the reference interpreter says of a run of an
# emitter claiming recognizer KEY ({NS NAME}) of the program whose files
# are FILES ({NS PATH}...).
proc concrete::judge {model key outcome symbols} {
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

# Candidate values of HIR type TYPE for function block B (with the Int
# constants of its code and its callees', and their neighbors).
proc concrete::Candidates {type constants} {
    set ints {0 1 -1 2 7 8 9 10 15 16 31 32 33 34 47 48 49 57 58 92 127 128 255 256 999 -999
        65535 65536 1114111 1114112 2147483648 9223372036854775808 -9223372036854775809
        1000000000000000000000000}
    foreach k $constants {
        lappend ints $k [expr {$k - 1}] [expr {$k + 1}]
    }
    set ints [lsort -unique -command {apply {{a b} {expr {abs($a) < abs($b) ? -1 : (abs($a) > abs($b) ? 1 : ($a < $b ? -1 : ($a > $b)))}}}} $ints]
    switch -- $type {
        int { return $ints }
        str {
            return [list "" a "\"" "\\" "\n" "\x01" "\x1f" / "\x7f" "é" "😀" "\ud7ff" "\uffff" "a\"b\\c\td" \
                [string repeat "xé😀\"" 50]]
        }
        bool { return {1 0} }
    }
    if {$type eq {list int}} {
        return [list {} {0} {97} {34} {-1} {55296} {1114112} {97 0 128512} {92 10 1}]
    }
    if {[lindex $type 0] eq "refined"} {
        set facts [intset::OfType $type]
        return [lmap k $ints {if {[intset::inter $facts [intset::point $k]] eq {}} continue; set k}]
    }
    return {}
}

# Every Int constant in block B and the blocks it calls.
proc concrete::Constants {hir b} {
    set out {}
    set seen [dict create]
    set work [list $b]
    while {[llength $work]} {
        set work [lassign $work x]
        if {[dict exists $seen $x]} continue
        dict set seen $x 1
        set stack [dict get $hir exprs $x body]
        while {[llength $stack]} {
            set stack [lassign $stack e]
            set node [dict get $hir exprs $e]
            switch -- [dict get $node kind] {
                const {
                    set v [dict get $node value]
                    if {[core::value::kind $v] eq "int"} {
                        lappend out [core::value::intOf $v]
                    }
                }
                call {
                    lassign [dict get $node target] tk t
                    if {$tk eq "block"} { lappend work $t }
                }
            }
            if {[dict get $node kind] ne "block"} {
                lappend stack {*}[hir::children $hir $e]
            }
        }
    }
    return [lsort -unique $out]
}

# The first argument tuple (of a bounded set of candidates) whose run of
# CLAIM's function completes with an invalid trace or yields a non-viable
# prefix: {ARGS REASON}, or "".
proc concrete::witness {claim} {
    variable maxTuples
    set hir $::modcheck::hir
    set b [dict get $claim block]
    set node [dict get $hir exprs $b]
    set types [dict get $node declaredParamTypes]
    if {"" in $types} { return "" }
    set constants [Constants $hir $b]
    set lists [lmap t $types {Candidates $t $constants}]
    foreach l $lists {
        if {$l eq {}} { return "" }
    }
    # The cartesian product, sampled down to maxTuples.
    set tuples {{}}
    foreach l $lists {
        set next {}
        foreach t $tuples {
            foreach v $l {
                lappend next [concat $t [list $v]]
            }
        }
        set tuples $next
    }
    if {[llength $tuples] > $maxTuples} {
        set step [expr {double([llength $tuples]) / $maxTuples}]
        set sample {}
        for {set i 0} {$i < $maxTuples} {incr i} {
            lappend sample [lindex $tuples [expr {int($i * $step)}]]
        }
        set tuples $sample
    }
    set entry $::modcheck::entryPath
    set errors [dict get $node declaredErrors]
    set fn [dict get $claim name]
    set copy ""
    if {[string first :: $fn] < 0} {
        # A function of the entry program: run from a module copy of its
        # declarations (the entry's own errors qualified by that module).
        lassign [EntryModule $entry] copy mod declared
        set fn ${mod}::$fn
        set errors [lmap e $errors {if {$e in $declared} {string cat ${mod}::$e} else {set e}}]
    }
    set code [catch {traces $entry $fn $types $errors $tuples} runs]
    if {$copy ne ""} { file delete $copy }
    if {$code} {
        return ""
    }
    if {$runs eq ""} { return "" }
    set files [dfasem::ApplicationFiles $entry]
    set model [dfaref::load [concat {*}[lmap {ns p} $files {list $ns $p}]]]
    foreach run $runs {
        lassign $run tuple outcome symbols
        set verdict [judge $model [dict get $claim key] $outcome $symbols]
        if {$verdict ne "ok"} {
            return [list [ArgsText $types $tuple] [lindex $verdict 1]]
        }
    }
    return ""
}

# A module copy of the entry program ENTRY's declarations (its leading
# imports and declarations, up to its first top-level expression):
# {PATH MODULE ERRORS}, ERRORS the errors it declares.
proc concrete::EntryModule {entry} {
    variable counter
    set mod "concrete_entry_[pid]_[incr counter]"
    set lines {}
    set declared {}
    set decl {^(import|fn|private|nomethod|error|struct|enum|type|refined|class|dfa|context|layout|union|extern|exported|trait|#|direct|$)}
    foreach line [split [core::ReadFile $entry] \n] {
        if {[regexp {^\S} $line] && ![regexp $decl $line]} break
        if {[regexp {^error\s+([A-Za-z_][A-Za-z0-9_]*)} $line -> name]} {
            lappend declared $name
        }
        lappend lines $line
    }
    set path [file join [file dirname $entry] $mod.bot]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f [join $lines \n]
    close $f
    return [list $path $mod $declared]
}

proc concrete::ArgsText {types tuple} {
    return "[join [lmap t $types v $tuple {Literal $t $v}] {, }]"
}
