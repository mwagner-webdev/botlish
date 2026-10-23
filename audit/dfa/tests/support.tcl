# support.tcl -- what the DFA prototype's tests share (DFA-COROUTINE-
# EXPLORATION.md, "Correctness"): a simulator of the declared recognizers,
# model-based cases, generated driver programs, and running Botlish
# programs on every backend from a private application directory.
#
#   source audit/dfa/tests/support.tcl   (after tests/helpers.tcl)

namespace eval dfatest {
    variable root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
    variable json [file join $root audit dfa json]
    variable backends {interp compile cranelift-generic cranelift cranelift-unfused}
}
source [file join $dfatest::root audit dfa tools dfa.tcl]
# Programs run under main.tcl's recursion limit (core/core.tcl): the Tcl
# backends evaluate a Botlish call as nested Tcl evaluations.
core::useProgramRecursionLimit

# The analyzed model of the .dfa file PATH (it must have no diagnostics).
proc dfatest::model {path} {
    set result [dfa::compileFile $path]
    if {[llength [dict get $result diagnostics]]} {
        error "diagnostics in $path: [lmap e [dict get $result diagnostics] {dict get $e message}]"
    }
    return [dict get $result model]
}

# The effective action of state Q of recognizer R on symbol C.
proc dfatest::Action {model r q c} {
    foreach seg [dict get $model dfas $r effective $q] {
        lassign $seg set a
        foreach i $set {
            if {$c >= [lindex $i 0] && $c <= [lindex $i 1]} {
                return $a
            }
        }
    }
    error "no action for $c in $r.$q"
}

# What the declared recognizer R does with SYMBOLS from index I, run as its
# declaration says (no generated code involved):
#   {accept CONSUMED TOOK}     CONSUMED symbols from I are its token
#   {unrecognized STATE AT}    {end STATE AT}    (AT: the symbol's index)
#   {suspended}                it needs more symbols than there are
proc dfatest::simulate {model r symbols {i 0}} {
    set q [lindex [dict get $model dfas $r stateOrder] 0]
    set start $i
    while 1 {
        if {$i >= [llength $symbols]} {
            return suspended
        }
        set c [lindex $symbols $i]
        set a [Action $model $r $q $c]
        switch -- [lindex $a 0] {
            goto {
                set q [lindex $a 1]
                incr i
            }
            accept {
                if {$c == -1} {
                    return [list accept [expr {$i - $start}] 0]
                }
                return [list accept [expr {$i + 1 - $start}] 1]
            }
            before {
                return [list accept [expr {$i - $start}] 0]
            }
            reject {
                set state [lindex $a 1]
                if {[string first . $state] < 0} {
                    set state $r.$state
                }
                return [list [expr {$c == -1 ? "end" : "unrecognized"}] $state $i]
            }
            call {
                lassign $a - callee - then
                set out [simulate $model $callee $symbols $i]
                if {[lindex $out 0] ne "accept"} {
                    return $out
                }
                lassign $out - consumed took
                if {$then eq "accept"} {
                    return [list accept [expr {$i + $consumed - $start}] $took]
                }
                incr i $consumed
                set q $then
            }
            default {
                error "unknown action $a"
            }
        }
    }
}

# A symbol of SET (an interval list) that a case should use: its first, its
# last and, for a wide interval, one inside.
proc dfatest::Representatives {set alphabet} {
    set hull [dfa::AlphabetSet $alphabet]
    set out {}
    foreach i [dfa::Inter $set [concat {{-1 -1}} $hull]] {
        lassign $i lo hi
        lappend out $lo
        if {$hi != $lo} {
            lappend out $hi
        }
        if {$hi - $lo > 2} {
            lappend out [expr {($lo + $hi) / 2}]
        }
    }
    return $out
}

# The shortest symbols that take recognizer R from its start to each entered
# state: {STATE SYMBOLS}. A call is passed through by its callee's shortest
# accepted token starting with the symbol.
proc dfatest::Paths {model r} {
    set d [dict get $model dfas $r]
    set start [lindex [dict get $d stateOrder] 0]
    set paths [dict create $start {}]
    set work [list $start]
    while {[llength $work]} {
        set work [lassign $work q]
        foreach seg [dict get $d effective $q] {
            lassign $seg set a
            if {[lindex $a 0] ni {goto call}} {
                continue
            }
            foreach c [Representatives $set [dict get $d alphabet]] {
                if {[lindex $a 0] eq "goto"} {
                    set next [lindex $a 1]
                    set step [list $c]
                } else {
                    lassign $a - callee - next
                    if {$next eq "accept"} {
                        break
                    }
                    set step [Completion $model $callee $c]
                    if {$step eq ""} {
                        continue
                    }
                }
                if {![dict exists $paths $next]} {
                    dict set paths $next [concat [dict get $paths $q] $step]
                    lappend work $next
                }
                break
            }
        }
    }
    return $paths
}

# The shortest token recognizer R accepts that starts with C and consumes
# its last symbol (so that the caller continues after it), or "".
proc dfatest::Completion {model r c} {
    set alphabet [dict get $model dfas $r alphabet]
    set frontier [list [list $c]]
    for {set depth 0} {$depth < 12} {incr depth} {
        set next {}
        foreach w $frontier {
            set out [simulate $model $r $w]
            if {[lindex $out 0] eq "accept" && [lindex $out 2] && [lindex $out 1] == [llength $w]} {
                return $w
            }
            if {$out ne "suspended"} {
                continue
            }
            foreach s [Candidates $model $r] {
                lappend next [concat $w $s]
            }
        }
        set frontier [lrange $next 0 400]
    }
    return ""
}

# Every representative symbol of every state of R and of the recognizers R
# calls: the branching of a search for one of R's tokens.
proc dfatest::Candidates {model r} {
    set d [dict get $model dfas $r]
    set out {}
    foreach q [dict get $d entered] {
        foreach seg [dict get $d effective $q] {
            lassign $seg set a
            if {[lindex $a 0] eq "reject"} {
                continue
            }
            lappend out {*}[lmap c [Representatives $set [dict get $d alphabet]] {expr {$c == -1 ? [continue] : $c}}]
            if {[lindex $a 0] eq "call"} {
                lappend out {*}[Candidates $model [lindex $a 1]]
            }
        }
    }
    return [lsort -unique -integer $out]
}

# A small spread of symbols of ALPHABET for searches.
proc dfatest::Alphabet0 {alphabet} {
    set out {34 35 47 48 49 92 98 102 110 114 116 117 65 97 100 68 56 67 99}
    if {$alphabet eq "bytes"} {
        lappend out 128 160 191 194 224 237 240 244
    }
    return $out
}

# Model-based cases of recognizer R: for every entered state, every symbol
# class of its table (each class's representatives, and a value outside the
# alphabet), each followed by the end of the input; and COUNT random
# sequences (seed SEED).
proc dfatest::cases {model r {count 40} {seed 1}} {
    set d [dict get $model dfas $r]
    set alphabet [dict get $d alphabet]
    set paths [Paths $model $r]
    set cases {}
    foreach q [dict get $d entered] {
        if {![dict exists $paths $q]} {
            continue
        }
        set prefix [dict get $paths $q]
        set reps {}
        foreach seg [dict get $d effective $q] {
            lappend reps {*}[Representatives [lindex $seg 0] $alphabet]
        }
        lappend reps [expr {[lindex [dfa::AlphabetHull $alphabet] 1] + 1}] -7
        foreach c [lsort -unique -integer $reps] {
            lappend cases [concat $prefix $c -1]
        }
    }
    expr {srand($seed)}
    set pool [lsort -unique -integer [concat [Alphabet0 $alphabet] 32 44 45 46 43 101 69 93 125 58 9 10 13 0 31 127]]
    for {set k 0} {$k < $count} {incr k} {
        set w {}
        set n [expr {1 + int(rand() * 10)}]
        for {set j 0} {$j < $n} {incr j} {
            lappend w [lindex $pool [expr {int(rand() * [llength $pool])}]]
        }
        lappend w -1
        # Start most of them at a valid prefix so they get somewhere.
        set q [lindex [dict get $d entered] [expr {int(rand() * [llength [dict get $d entered]])}]]
        if {[dict exists $paths $q] && rand() < 0.7} {
            set w [concat [dict get $paths $q] $w]
        }
        lappend cases $w
    }
    return $cases
}

# The outcome text a generated driver returns for SIMULATE's outcome.
proc dfatest::OutcomeText {out} {
    switch -- [lindex $out 0] {
        accept { return "accept [lindex $out 1] [expr {[lindex $out 2] ? "took" : "left"}]" }
        unrecognized { return "unrecognized [lindex $out 1] [lindex $out 2]" }
        end { return "end [lindex $out 1] [lindex $out 2]" }
        default { return $out }
    }
}

# A Botlish driver function `run_R(symbols)` for recognizer R of module
# MODULE: it constructs R with the first symbol, resumes it with the rest,
# and returns OutcomeText's text.
proc dfatest::Driver {module r} {
    # Qualified calls only: method syntax with several imported candidates
    # would cost the whole-program trial builds of METHOD-SUGAR.md.
    return [string map [list @R@ $r @M@ $module] {
fn run_@R@(symbols: List[int]) -> str errors IndexNotFound:
    n = std::list::length(symbols)
    coroutine {step, first} = @M@::@R@(std::list::at(symbols, 0)):
        on dfa::UnrecognizedInput {state}:
            return std::str::concat(std::str::concat("unrecognized ", state), " 0")
        on dfa::UnexpectedEnd {state}:
            return std::str::concat(std::str::concat("end ", state), " 0")
    i = std::mutable_array::create(1, 0)
    took = std::mutable_array::create(1, first)
    loop:
        if std::coroutine::done?(step):
            break
        std::mutable_array::set(i, 0, std::mutable_array::at(i, 0) + 1)
        at = std::mutable_array::at(i, 0)
        if at >= n:
            return "suspended"
        a = step(dfa::Symbol {code: std::list::at(symbols, at)}):
            on dfa::UnrecognizedInput {state}:
                return std::str::concat(std::str::concat(std::str::concat("unrecognized ", state), " "), std::int::to_string(at))
            on dfa::UnexpectedEnd {state}:
                return std::str::concat(std::str::concat(std::str::concat("end ", state), " "), std::int::to_string(at))
        std::mutable_array::set(took, 0, a)
    consumed = std::mutable_array::at(i, 0)
    if std::mutable_array::at(took, 0):
        return std::str::concat(std::str::concat("accept ", std::int::to_string(consumed + 1)), " took")
    std::str::concat(std::str::concat("accept ", std::int::to_string(consumed)), " left")
}]
}

# A program running every case of CASES ({R SYMBOLS} pairs): its value is
# the List of outcome texts, the cases grouped by recognizer in the order
# of their first case (ordered: dfatest::order).
proc dfatest::program {module cases} {
    set text "import dfa\nimport $module\nimport std::coroutine\nimport std::mutable_array\nimport std::list\nimport std::str\nimport std::int\n"
    set rs [order $cases]
    foreach r $rs {
        append text [Driver $module $r]
    }
    foreach r $rs {
        append text "\nfn cases_$r\() -> List\[str\] errors IndexNotFound:\n    loop w in \[\n"
        foreach c $cases {
            if {[lindex $c 0] eq $r} {
                append text "        \[[join [lindex $c 1] {, }]\],\n"
            }
        }
        append text "    \]:\n        run_$r\(w)\n"
    }
    append text "\nfn all() -> List\[List\[str\]\] errors IndexNotFound:\n    \[[join [lmap r $rs {string cat cases_$r ()}] {, }]\]\n"
    append text "\nall():\n    on IndexNotFound:\n        \[\]\n"
    return $text
}

# CASES in the order dfatest::program runs them.
proc dfatest::order {cases} {
    return [lsort -unique [lmap c $cases {lindex $c 0}]]
}

proc dfatest::ordered {cases} {
    set out {}
    foreach r [order $cases] {
        foreach c $cases {
            if {[lindex $c 0] eq $r} {
                lappend out $c
            }
        }
    }
    return $out
}

# A private copy of the JSON application directory (json_lex.bot, dfa.bot,
# json.bot), with the extra files FILES ({NAME TEXT}...): its path.
proc dfatest::workspace {args} {
    variable json
    set dir [file tempdir dfa-test]
    foreach name {dfa.bot json_lex.bot json.bot} {
        file copy [file join $json $name] [file join $dir $name]
    }
    foreach {name text} $args {
        dfa::WriteText [file join $dir $name] $text
    }
    return $dir
}

# The outcome of the program file PATH on each of BACKENDS: {BACKEND
# OUTCOME ...} in outcomeUnderHir's shape (the test log dropped).
proc dfatest::outcomes {path {which ""}} {
    variable backends
    if {$which eq ""} {
        set which $backends
    }
    set hir [surface::readProgramFile $path -warnings off]
    set out {}
    foreach b $which {
        lappend out $b [lrange [outcomeUnderHir $b $hir] 0 end-1]
    }
    return $out
}

# The one outcome every backend of OUTCOMES agrees on, or an error naming
# them all.
proc dfatest::agreed {outcomes} {
    set distinct [lsort -unique [dict values $outcomes]]
    if {[llength $distinct] != 1} {
        error "backends disagree: $outcomes"
    }
    return [lindex $distinct 0]
}

# The value of a Botlish List-of-str outcome {value TEXT}: its elements.
proc dfatest::strings {outcome} {
    if {[lindex $outcome 0] ne "value"} {
        error "not a value: $outcome"
    }
    set text [string range [lindex $outcome 1] 1 end-1]
    set out {}
    foreach item [regexp -all -inline {"(?:[^"\\]|\\.)*"} $text] {
        lappend out [string map {\\\\ \\ \\\" \"} [string range $item 1 end-1]]
    }
    return $out
}
