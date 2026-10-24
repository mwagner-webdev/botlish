# dfa-support.tcl -- what the declared-recognizer tests share
# (DFA-COROUTINE-MILESTONE-2.md, "Static-guarantee testing"):
#
#   * dfaref::, a reference interpreter of `class` and `dfa` declarations,
#     read straight from the parsed source: every symbol tested against
#     every item by direct comparison, sequences followed symbol by symbol,
#     a call run as a nested recognizer over the same input -- no interval
#     arithmetic, no effective table, nothing of surface/dfa.tcl. It is the
#     oracle the compiled recognizers are compared with;
#   * dfatest::, model-based cases, generated driver programs, and running
#     a program of several files on every backend from a private directory.
#
#   source tests/dfa-support.tcl   (after tests/helpers.tcl)

namespace eval dfaref {}
namespace eval dfatest {
    variable natives {cranelift-generic cranelift cranelift-unfused}
}

# BACKENDS minus the native ones on a host without native coroutines
# (tests/helpers.tcl's nativeCoroutines: a recognizer is a coroutine, and
# the native backend refuses one there, while the Tcl backends run them
# everywhere).
proc dfatest::hosted {backends} {
    variable natives
    if {[testConstraint nativeCoroutines]} {
        return $backends
    }
    return [lmap b $backends {
        if {$b in $natives} continue
        set b
    }]
}

set ::dfatest::backends [dfatest::hosted {interp compile cranelift-generic cranelift cranelift-unfused}]

# ---------------------------------------------------------------------------
# The reference interpreter

# The declarations of the program whose files are FILES ({NAMESPACE PATH}
# ...; "" the entry program): {classes {NS {NAME NODE}} dfas {NS {NAME NODE}}}.
proc dfaref::load {files} {
    set model [dict create classes [dict create] dfas [dict create]]
    foreach {ns path} $files {
        set ast [surface::parse [core::ReadFile $path] $path]
        dict set model classes $ns [dict create]
        dict set model dfas $ns [dict create]
        foreach s [dict get $ast body] {
            switch -- [dict get $s kind] {
                classdecl { dict set model classes $ns [dict get $s name] $s }
                dfadecl { dict set model dfas $ns [dict get $s name] $s }
            }
        }
    }
    return $model
}

# 1 if X is a symbol of ALPHABET.
proc dfaref::InAlphabet {x alphabet} {
    switch -- $alphabet {
        ascii { return [expr {$x >= 0 && $x <= 127}] }
        bytes { return [expr {$x >= 0 && $x <= 255}] }
        unicode { return [expr {$x >= 0 && $x <= 0x10FFFF && !($x >= 0xD800 && $x <= 0xDFFF)}] }
    }
    error "unknown alphabet $alphabet"
}

# 1 if the class NAME (written in namespace NS, with recognizer D's local
# classes first when D is given) holds symbol X of ALPHABET.
proc dfaref::ClassHolds {model ns d qualifier name x alphabet} {
    if {$qualifier eq "" && $d ne ""} {
        foreach c [dict get $d classes] {
            if {[dict get $c name] eq $name} {
                return [DeclHolds $model $ns $d $c $x $alphabet]
            }
        }
    }
    set where [if {$qualifier eq ""} {set ns} else {set qualifier}]
    set c [dict get $model classes $where $name]
    # A file's class reads the classes of its own file.
    return [DeclHolds $model $where "" $c $x $alphabet]
}

proc dfaref::DeclHolds {model ns d c x alphabet} {
    return [expr {[ItemsHold $model $ns $d [dict get $c items] $x $alphabet]
        && ![ItemsHold $model $ns $d [dict get $c except] $x $alphabet]}]
}

# 1 if one of ITEMS holds X (-1: the end of the input).
proc dfaref::ItemsHold {model ns d items x alphabet} {
    foreach item $items {
        switch -- [dict get $item kind] {
            end {
                if {$x == -1} {
                    return 1
                }
            }
            any {
                if {[InAlphabet $x $alphabet]} {
                    return 1
                }
            }
            sym {
                if {[InAlphabet $x $alphabet] && $x >= [dict get $item lo] && $x <= [dict get $item hi]} {
                    return 1
                }
            }
            class {
                if {[InAlphabet $x $alphabet]
                        && [ClassHolds $model $ns $d [dict get $item namespace] [dict get $item name] $x $alphabet]} {
                    return 1
                }
            }
        }
    }
    return 0
}

proc dfaref::Name {ns name} {
    if {$ns eq ""} {
        return $name
    }
    return ${ns}::$name
}

# What recognizer NAME of namespace NS does with INPUTS (a list of symbols,
# -1 the end of the input) from index I: {accept NEXT FURTHEST} -- its token
# is INPUTS I..NEXT-1, FURTHEST one past the furthest input it read (the end
# not counted) -- or {unrecognized R S AT}, {end R S AT}, {suspended
# FURTHEST WHERE}, WHERE the state it waits in (with the callers' states
# around a callee's: what identifies the configuration).
proc dfaref::run {model ns name inputs i} {
    set d [dict get $model dfas $ns $name]
    set alphabet [dict get $d alphabet]
    set qualified [Name $ns $name]
    set q [dict get [lindex [dict get $d states] 0] name]
    set furthest $i
    # The sequences of state Q still matching, and how many symbols they
    # read (a trie: sequences sharing a prefix share its symbols).
    set candidates {}
    set k 0
    while 1 {
        if {$i >= [llength $inputs]} {
            if {$candidates ne {}} {
                set first [dict get [lindex [dict get [lindex $candidates 0] items] 0] symbols]
                return [list suspended $furthest [list $qualified "$q\"[join [lmap c [lrange $first 0 $k-1] {format %c $c}] {}]\""]]
            }
            return [list suspended $furthest [list $qualified $q]]
        }
        set x [lindex $inputs $i]
        if {$x != -1 && $i + 1 > $furthest} {
            set furthest [expr {$i + 1}]
        }
        set t ""
        if {$candidates ne {}} {
            set first [dict get [lindex [dict get [lindex $candidates 0] items] 0] symbols]
            set where "$q\"[join [lmap c [lrange $first 0 $k-1] {format %c $c}] {}]\""
            set next {}
            foreach c $candidates {
                set symbols [dict get [lindex [dict get $c items] 0] symbols]
                if {[InAlphabet $x $alphabet] && [lindex $symbols $k] eq $x} {
                    lappend next $c
                }
            }
            if {$next eq {}} {
                if {$x == -1} {
                    return [list end $qualified $where $i]
                }
                return [list unrecognized $qualified $where $i]
            }
            incr k
            set done [lmap c $next {expr {[llength [dict get [lindex [dict get $c items] 0] symbols]] == $k ? $c : [continue]}}]
            if {$done eq {}} {
                set candidates $next
                incr i
                continue
            }
            if {[llength $next] > 1} {
                error "ambiguous: a sequence of $qualified.$q is a prefix of another"
            }
            set t [lindex $done 0]
            set candidates {}
        } else {
            set matches {}
            set sequences {}
            foreach st [dict get $d states] {
                if {[dict get $st name] ne $q} {
                    continue
                }
                foreach candidate [dict get $st transitions] {
                    set items [dict get $candidate items]
                    if {[dict get [lindex $items 0] kind] eq "seq"} {
                        if {[InAlphabet $x $alphabet] && [lindex [dict get [lindex $items 0] symbols] 0] == $x} {
                            lappend sequences $candidate
                        }
                    } elseif {[ItemsHold $model $ns $d $items $x $alphabet]} {
                        lappend matches $candidate
                    }
                }
            }
            if {[llength $matches] + ([llength $sequences] > 0) > 1 || [llength $matches] > 1} {
                error "ambiguous: two transitions of $qualified.$q hold $x"
            }
            if {$sequences ne {}} {
                set short [lmap c $sequences {expr {[llength [dict get [lindex [dict get $c items] 0] symbols]] == 1 ? $c : [continue]}}]
                if {$short ne {}} {
                    if {[llength $sequences] > 1} {
                        error "ambiguous: a sequence of $qualified.$q is a prefix of another"
                    }
                    set t [lindex $short 0]
                } else {
                    set candidates $sequences
                    set k 1
                    incr i
                    continue
                }
            } elseif {$matches ne {}} {
                set t [lindex $matches 0]
            } else {
                if {$x == -1} {
                    return [list end $qualified $q $i]
                }
                return [list unrecognized $qualified $q $i]
            }
        }
        switch -- [dict get $t action] {
            goto {
                set q [dict get $t target]
                incr i
            }
            accept {
                set n [dict get $t unread]
                if {$x == -1} {
                    return [list accept [expr {$i - $n}] $furthest]
                }
                return [list accept [expr {$i + 1 - $n}] $furthest]
            }
            reject {
                return [list end $qualified $q $i]
            }
            call {
                lassign [dict get $t callee] cns cname
                if {$cns eq ""} {
                    set cns $ns
                }
                set out [run $model $cns $cname $inputs $i]
                if {[lindex $out 0] eq "suspended"} {
                    return [list suspended [expr {max($furthest, [lindex $out 1])}] \
                        [list $qualified $q [dict get $t then] {*}[lindex $out 2]]]
                }
                if {[lindex $out 0] ne "accept"} {
                    return $out
                }
                lassign $out - next calleeFurthest
                set furthest [expr {max($furthest, $calleeFurthest)}]
                if {[dict get $t then] eq "accept"} {
                    return [list accept $next $furthest]
                }
                # The caller reconsiders what the callee left: from NEXT on.
                set q [dict get $t then]
                set i $next
            }
        }
    }
}

# The outcome text of a compiled run (dfatest::Driver) for the reference's
# outcome OUT of a run from index 0: `accept LENGTH UNREAD`, `unrecognized
# R S AT`, `end R S AT`, `suspended`.
proc dfaref::text {out} {
    switch -- [lindex $out 0] {
        accept {
            lassign $out - next furthest
            return "accept $next [expr {$furthest - $next}]"
        }
        unrecognized - end { return [join $out " "] }
        suspended { return suspended }
    }
}

# ---------------------------------------------------------------------------
# Cases

# The symbols worth trying for recognizer NAME of NS and those it calls:
# every bound of every symbol item (and one past each), a member of each
# class's items, the alphabet's ends and one past, -2 and a large value.
proc dfatest::Interesting {model ns name {seen {}}} {
    set d [dict get $model dfas $ns $name]
    set out {-2 -1 0 1000000000000000000000}
    switch -- [dict get $d alphabet] {
        ascii { lappend out 127 128 }
        bytes { lappend out 127 128 255 256 }
        unicode { lappend out 0xD7FF 0xD800 0xDFFF 0xE000 0x10FFFF 0x110000 }
    }
    set items {}
    foreach c [dict get $d classes] {
        lappend items {*}[dict get $c items] {*}[dict get $c except]
    }
    dict for {cname c} [dict get $model classes $ns] {
        lappend items {*}[dict get $c items] {*}[dict get $c except]
    }
    foreach st [dict get $d states] {
        foreach t [dict get $st transitions] {
            lappend items {*}[dict get $t items]
            if {[dict get $t action] eq "call"} {
                lassign [dict get $t callee] cns cname
                if {$cns eq ""} {
                    set cns $ns
                }
                if {"$cns/$cname" ni $seen} {
                    lappend seen $cns/$cname
                    lappend out {*}[Interesting $model $cns $cname $seen]
                }
            }
        }
    }
    foreach item $items {
        switch -- [dict get $item kind] {
            sym {
                lappend out [dict get $item lo] [dict get $item hi] [expr {[dict get $item lo] - 1}] \
                    [expr {[dict get $item hi] + 1}] [expr {([dict get $item lo] + [dict get $item hi]) / 2}]
            }
            seq { lappend out {*}[dict get $item symbols] }
        }
    }
    foreach qualifier [lsort -unique [lmap item $items {if {[dict get $item kind] eq "class"} {dict get $item namespace} else continue}]] {
        if {$qualifier ne "" && [dict exists $model classes $qualifier]} {
            dict for {cname c} [dict get $model classes $qualifier] {
                foreach item [concat [dict get $c items] [dict get $c except]] {
                    if {[dict get $item kind] eq "sym"} {
                        lappend out [dict get $item lo] [dict get $item hi] [expr {[dict get $item hi] + 1}]
                    }
                }
            }
        }
    }
    return [lsort -unique -command {apply {{a b} {expr {$a < $b ? -1 : ($a > $b ? 1 : 0)}}}} [lmap x $out {expr {$x}}]]
}

# The cases (input lists) of recognizer NAME of NS for seed SEED:
#
# * every interesting symbol alone and followed by the end;
# * the frontier: a shortest input reaching each configuration the
#   reference can wait in (breadth first, inputs of at most DEPTH symbols),
#   followed by every interesting symbol, and by the end -- every transition
#   of every reachable state, the lookahead's completions included -- at
#   most FRONTIER of them, a seeded sample when there are more;
# * COUNT random walks that prefer a symbol that keeps the run alive (the
#   reference says which), each ended by the end of the input, a random
#   symbol, a random symbol and the end, or nothing (still waiting).
proc dfatest::cases {model ns name {count 60} {seed 1} {frontier 400} {depth 12}} {
    set pool [Interesting $model $ns $name]
    set cases {}
    foreach x $pool {
        lappend cases [list $x] [list $x -1]
    }
    expr {srand($seed)}
    # Breadth first over configurations.
    set seen [dict create]
    set queue [list {}]
    set edges {}
    while {[llength $queue] > 0} {
        set next {}
        foreach prefix $queue {
            lappend edges [concat $prefix -1]
            foreach x $pool {
                if {$x == -1} continue
                set w [concat $prefix $x]
                lappend edges $w
                set out [dfaref::run $model $ns $name $w 0]
                if {[lindex $out 0] ne "suspended" || [llength $w] >= $depth} continue
                set key [lindex $out 2]
                if {[dict exists $seen $key]} continue
                dict set seen $key 1
                lappend next $w
            }
        }
        set queue $next
    }
    set edges [lrange $edges 1 end]
    while {[llength $edges] > $frontier} {
        set edges [lreplace $edges [set k [expr {int(rand() * [llength $edges])}]] $k]
    }
    lappend cases {*}$edges
    for {set n 0} {$n < $count} {incr n} {
        set w {}
        set length [expr {1 + int(rand() * 12)}]
        for {set k 0} {$k < $length} {incr k} {
            # Try a few symbols; keep one the run survives, when there is one.
            set pick [lindex $pool [expr {int(rand() * [llength $pool])}]]
            for {set tries 0} {$tries < 6} {incr tries} {
                set x [lindex $pool [expr {int(rand() * [llength $pool])}]]
                if {$x == -1} continue
                set out [dfaref::run $model $ns $name [concat $w $x] 0]
                if {[lindex $out 0] eq "suspended"} {
                    set pick $x
                    break
                }
            }
            lappend w $pick
            if {[lindex [dfaref::run $model $ns $name $w 0] 0] ne "suspended"} {
                break
            }
        }
        set r [expr {rand()}]
        set x [lindex $pool [expr {int(rand() * [llength $pool])}]]
        if {$r < 0.4} {
            lappend w -1
        } elseif {$r < 0.7} {
            lappend w $x
        } elseif {$r < 0.9} {
            lappend w $x -1
        }
        lappend cases $w
    }
    return [lsort -unique $cases]
}

# ---------------------------------------------------------------------------
# Programs

# A Botlish driver function `run_R(symbols)` of recognizer R (QUALIFIED its
# spelling: `R` or `NS::R`): it constructs R with the first symbol, resumes
# it with the rest, and returns the outcome text dfaref::text gives.
proc dfatest::Driver {r qualified} {
    return [string map [list @R@ $r @Q@ $qualified] {
fn run_@R@(symbols: List[int]) -> str errors IndexNotFound:
    n = std::list::length(symbols)
    coroutine {step, first} = @Q@(std::list::at(symbols, 0)):
        on std::dfa::UnrecognizedInput {recognizer, state}:
            return std::str::concat(std::str::concat(std::str::concat(std::str::concat("unrecognized ", recognizer), " "), state), " 0")
        on std::dfa::UnexpectedEnd {recognizer, state}:
            return std::str::concat(std::str::concat(std::str::concat(std::str::concat("end ", recognizer), " "), state), " 0")
    i = std::mutable_array::create(1, 0)
    unread = std::mutable_array::create(1, first)
    loop:
        if std::coroutine::done?(step):
            break
        std::mutable_array::set(i, 0, std::mutable_array::at(i, 0) + 1)
        at = std::mutable_array::at(i, 0)
        if at >= n:
            return "suspended"
        a = step(std::dfa::Symbol {code: std::list::at(symbols, at)}):
            on std::dfa::UnrecognizedInput {recognizer, state}:
                return std::str::concat(std::str::concat(std::str::concat(std::str::concat(std::str::concat("unrecognized ", recognizer), " "), state), " "), std::int::to_string(at))
            on std::dfa::UnexpectedEnd {recognizer, state}:
                return std::str::concat(std::str::concat(std::str::concat(std::str::concat(std::str::concat("end ", recognizer), " "), state), " "), std::int::to_string(at))
        std::mutable_array::set(unread, 0, a)
    last = std::mutable_array::at(i, 0)
    supplied = if std::list::at(symbols, last) == -1:
        last
    else:
        last + 1
    u = std::mutable_array::at(unread, 0)
    std::str::concat(std::str::concat(std::str::concat("accept ", std::int::to_string(supplied - u)), " "), std::int::to_string(u))
}]
}

# The source of a program whose value is the List of the outcome texts of
# CASES ({R QUALIFIED SYMBOLS}...) in order. IMPORTS are the namespaces the
# recognizers are in (beside the standard ones the drivers use); PRELUDE
# is source written before the drivers (an entry program's declarations).
proc dfatest::program {imports cases {prelude ""}} {
    set text "import std::dfa\nimport std::coroutine\nimport std::mutable_array\nimport std::list\nimport std::str\nimport std::int\n"
    foreach ns $imports {
        append text "import $ns\n"
    }
    append text \n$prelude\n
    set rs {}
    foreach c $cases {
        lassign $c r qualified
        if {[dict exists $rs $r]} continue
        dict set rs $r $qualified
        append text [Driver $r $qualified]
    }
    # The cases are data: groups of at most 50 cases of one recognizer, each
    # a List literal its driver's returning loop runs (a function per case
    # makes the program's size, and its front end's cost, grow per case).
    set groups {}
    set g 0
    set pending {}
    set current ""
    foreach c [concat $cases [list {"" "" {}}]] {
        lassign $c r qualified symbols
        if {[llength $pending] > 0 && ($r ne $current || [llength $pending] == 50)} {
            append text "\nfn cases$g\() -> List\[List\[int\]\]:\n    \[[join $pending {, }]\]\n"
            append text "\nfn group$g\() -> List\[str\] errors IndexNotFound:\n    loop symbols in cases$g\():\n        run_$current\(symbols)\n"
            lappend groups "group$g\()"
            incr g
            set pending {}
        }
        set current $r
        lappend pending "\[[join $symbols {, }]\]"
    }
    append text "\nfn all() -> List\[List\[str\]\] errors IndexNotFound:\n    \[[join $groups {, }]\]\n"
    append text "\nall():\n    on IndexNotFound:\n        \[\]\n"
    return $text
}

# A private directory holding FILES ({NAME TEXT}...): its path.
proc dfatest::workspace {args} {
    set dir [makeDirectory dfa-[pid]-[incr ::dfatest::counter]]
    foreach {name text} $args {
        set f [open [file join $dir $name] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $text
        close $f
    }
    return $dir
}
set ::dfatest::counter 0

# The outcome of the program file PATH on each of BACKENDS that runs on
# this host (hosted): {BACKEND OUTCOME ...} in outcomeUnderHir's shape (the
# test log dropped).
proc dfatest::outcomes {path {which ""}} {
    variable backends
    if {$which eq ""} {
        set which $backends
    }
    set which [hosted $which]
    if {$which eq ""} {
        error "no backend runs here: a test of native code carries nativeCoroutines"
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

# The strings of a Botlish List-of-Lists-of-str outcome {value TEXT}, flat.
proc dfatest::strings {outcome} {
    if {[lindex $outcome 0] ne "value"} {
        error "not a value: $outcome"
    }
    set out {}
    foreach item [regexp -all -inline {"(?:[^"\\]|\\.)*"} [lindex $outcome 1]] {
        lappend out [string map {\\\\ \\ \\\" \"} [string range $item 1 end-1]]
    }
    return $out
}

# Every case of CASES ({R QUALIFIED SYMBOLS}...) of the program main.bot
# written in directory DIR (beside its modules MODULES, the namespaces it
# imports; PRELUDE the entry program's own declarations) run on every
# backend; the cases whose outcome differs from the reference's, as
# {SYMBOLS COMPILED REFERENCE} (none: {}).
proc dfatest::compare {dir modules cases {prelude ""}} {
    set path [file join $dir main.bot]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f [program $modules $cases $prelude]
    close $f
    set reffiles [list "" $path]
    foreach ns $modules {
        lappend reffiles $ns [file join $dir [string map {:: /} $ns].bot]
    }
    set model [dfaref::load $reffiles]
    set got [strings [agreed [outcomes $path]]]
    set bad {}
    foreach c $cases text $got {
        lassign $c r qualified symbols
        set ns [if {[string first :: $qualified] >= 0} {namespace qualifiers $qualified} else {string cat ""}]
        set want [dfaref::text [dfaref::run $model $ns $r $symbols 0]]
        if {$text ne $want} {
            lappend bad [list $symbols $text $want]
        }
    }
    return $bad
}
