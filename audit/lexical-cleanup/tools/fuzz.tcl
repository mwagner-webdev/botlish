# fuzz.tcl -- random programs against an independent model of scope-bound
# release (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md).
#
#   tclsh9.0 audit/lexical-cleanup/tools/fuzz.tcl ?-n N? ?-seed S?
#                                                 ?-backends LIST? ?-keep DIR?
#
# Each program is a few functions over tests/resources/handle.bot's Handle (a
# resource whose cleanup logs its number): bindings of Handles, notes,
# discarded Handles, explicit releases, moves to a new binding, moves into a
# function that owns the value to its end, nested blocks, ifs, counted loops
# with continue and break, early returns, a declared error raised and
# propagated through calls, and coroutines that hold Handles across yields
# and are completed or abandoned where their handle's scope ends. main runs
# each function on a few arguments, handling the error, and returns the Log.
#
# The model (Model, below) interprets the generated program's own tree with
# the rules stated once: a binding's Handle is released where its sequence
# ends or where an exit leaves it, the scope's in reverse acquisition order;
# a move makes the new owner's scope responsible; a moved-in parameter is
# released at its function's end; an abandoned coroutine releases what its
# suspended frames own, innermost first. It shares no code with the
# compiler. Every backend must give the model's Log: a disagreement prints
# the program and both Logs. The last line is "programs N disagreements D".

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 25 -seed 1 -backends {interp compile cranelift-generic cranelift} -keep ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]

expr {srand([dict get $options -seed])}
proc rnd {n} { expr {int(rand() * $n)} }
proc chance {p} { expr {rand() < $p} }

# ---------------------------------------------------------------------------
# The generator. A statement is a dict {kind ...}; a body a list of them.
# Every function is fn fI(n: int, context log: handle::Log) -> int errors
# Boom; the generator tracks, per sequence, the Handle bindings it owns (an
# explicit release or a move only ever takes one of the current sequence, so
# no value is moved on some paths only).

proc fresh {what} {
    return "$what[incr ::counter($what)]"
}

proc newId {} {
    return [incr ::nextId]
}

# A body for function FN at DEPTH: STATEMENTS, LOOP 1 inside a loop body.
proc genBody {fn depth inLoop {count ""}} {
    if {$count eq ""} {
        set count [expr {1 + [rnd 5]}]
    }
    set body {}
    set owned {}
    for {set k 0} {$k < $count} {incr k} {
        set r [rnd 100]
        if {$r < 22} {
            set name [fresh h]
            lappend body [dict create kind open name $name id [newId]]
            lappend owned $name
        } elseif {$r < 32} {
            lappend body [dict create kind note id [newId]]
        } elseif {$r < 37} {
            lappend body [dict create kind discard id [newId]]
        } elseif {$r < 43 && $owned ne {}} {
            set i [rnd [llength $owned]]
            set name [lindex $owned $i]
            set owned [lreplace $owned $i $i]
            lappend body [dict create kind close name $name]
        } elseif {$r < 50 && $owned ne {}} {
            set i [rnd [llength $owned]]
            set name [lindex $owned $i]
            set owned [lreplace $owned $i $i]
            set to [fresh k]
            lappend body [dict create kind move name $name to $to]
            lappend owned $to
        } elseif {$r < 55 && $owned ne {}} {
            set i [rnd [llength $owned]]
            set name [lindex $owned $i]
            set owned [lreplace $owned $i $i]
            lappend body [dict create kind sink name $name id [newId]]
        } elseif {$r < 63 && $depth < 3} {
            set node [dict create kind if op [lindex {> ==} [rnd 2]] t [rnd 4] then [genBody $fn [expr {$depth + 1}] $inLoop]]
            if {[chance 0.5]} {
                dict set node else [genBody $fn [expr {$depth + 1}] $inLoop]
            }
            lappend body $node
        } elseif {$r < 69 && $depth < 3} {
            set var [fresh i]
            set loopBody [genBody $fn [expr {$depth + 1}] 1]
            if {[chance 0.6]} {
                # A guarded continue or break somewhere in the body.
                set exit [dict create kind if op == var $var t [rnd 3] then [list [dict create kind [lindex {continue break} [rnd 2]]]]]
                set at [rnd [expr {[llength $loopBody] + 1}]]
                set loopBody [linsert $loopBody $at $exit]
            }
            lappend body [dict create kind loop var $var count [expr {1 + [rnd 3]}] body $loopBody]
        } elseif {$r < 74 && $depth < 3} {
            lappend body [dict create kind block body [genBody $fn [expr {$depth + 1}] $inLoop]]
        } elseif {$r < 79} {
            lappend body [dict create kind if op == t [rnd 4] then [list [dict create kind return value [rnd 10]]]]
        } elseif {$r < 84} {
            lappend body [dict create kind if op == t [rnd 4] then [list [dict create kind fail]]]
        } elseif {$r < 92 && $fn > 0} {
            lappend body [dict create kind call fn [rnd $fn]]
        } elseif {$r < 100 && $::coroutineNames ne {}} {
            lappend body [dict create kind coro gen [lindex $::coroutineNames [rnd [llength $::coroutineNames]]] resumes [rnd 4]]
        } else {
            lappend body [dict create kind note id [newId]]
        }
    }
    return $body
}

# A coroutine function: straight-line opens and notes around yields (its
# handles are its own frame's), completing with 0.
proc genCoroutine {name} {
    set body {}
    set yields 0
    set count [expr {2 + [rnd 5]}]
    for {set k 0} {$k < $count} {incr k} {
        set r [rnd 100]
        if {$r < 35} {
            lappend body [dict create kind open name [fresh h] id [newId]]
        } elseif {$r < 70} {
            lappend body [dict create kind yield]
            incr yields
        } elseif {$r < 85 && [llength $body] > 0} {
            lappend body [dict create kind block body [list [dict create kind open name [fresh h] id [newId]] [dict create kind yield] [dict create kind note id [newId]]]]
            incr yields
        } else {
            lappend body [dict create kind note id [newId]]
        }
    }
    if {$yields == 0} {
        lappend body [dict create kind yield]
    }
    return [dict create name $name body $body]
}

# ---------------------------------------------------------------------------
# Printing

proc indent {level} { string repeat "    " $level }

proc printBody {body level} {
    set out ""
    foreach s $body {
        append out [printStmt $s $level]
    }
    if {$body eq {} || [dict get [lindex $body end] kind] in {discard open move}} {
        # A body's last value is never a Handle: a loop would collect it, an
        # if would yield it -- the model releases a discarded one at once.
        # (A binding statement's value is its value. A nested loop whose body
        # ends with a binding also meets a native lowering defect older than
        # resources -- invalid NIR for a scalar-replaced struct's binding
        # collected by an inner loop; LEXICAL-RESOURCE-CLEANUP-EXPLORATION-
        # MILESTONE-1.md, "Findings" -- which this keeps out of the way.)
        append out "[indent $level]unit\n"
    }
    return $out
}

proc printStmt {s level} {
    set p [indent $level]
    switch -- [dict get $s kind] {
        open { return "$p[dict get $s name] = handle::open([dict get $s id])\n" }
        note { return "${p}handle::note([dict get $s id])\n" }
        discard { return "${p}handle::open([dict get $s id])\n" }
        close { return "${p}handle::close([dict get $s name])\n" }
        move { return "$p[dict get $s to] = [dict get $s name]\n" }
        sink { return "${p}sink([dict get $s name], [dict get $s id])\n" }
        if {
            set left [expr {[dict exists $s var] ? [dict get $s var] : "n"}]
            set out "${p}if $left [dict get $s op] [dict get $s t]:\n[printBody [dict get $s then] [expr {$level + 1}]]"
            if {[dict exists $s else]} {
                append out "${p}else:\n[printBody [dict get $s else] [expr {$level + 1}]]"
            }
            return $out
        }
        loop { return "${p}loop [dict get $s var] from 0 to [dict get $s count]:\n[printBody [dict get $s body] [expr {$level + 1}]]" }
        block { return "${p}if true:\n[printBody [dict get $s body] [expr {$level + 1}]]" }
        return { return "${p}return [dict get $s value]\n" }
        fail { return "${p}fail Boom\n" }
        continue { return "${p}continue\n" }
        break { return "${p}break\n" }
        call { return "${p}f[dict get $s fn](n - 1)\n" }
        yield { return "${p}yield 1\n" }
        coro {
            set c [fresh c]
            set out "${p}if true:\n"
            append out "$p    coroutine \{step: $c\} = [dict get $s gen]()\n"
            for {set r 0} {$r < [dict get $s resumes]} {incr r} {
                append out "$p    if not std::coroutine::done?($c):\n$p        ${c}(Go \{n: $r\})\n"
            }
            append out "$p    unit\n"
            return $out
        }
    }
    error "printStmt: [dict get $s kind]"
}

proc printProgram {functions coroutines calls} {
    set out "import handle\nimport std::coroutine\n\nerror Boom\n\nstruct Go:\n    n: int\n\n"
    append out "fn sink(h: handle::Handle, id: int, context log: handle::Log):\n    handle::note(id)\n\n"
    foreach c $coroutines {
        append out "fn [dict get $c name](context log: handle::Log, resume Go) -> int:\n[printBody [dict get $c body] 1]    0\n\n"
    }
    set i 0
    foreach f $functions {
        append out "fn f${i}(n: int, context log: handle::Log) -> int errors Boom:\n[printBody $f 1]    0\n\n"
        incr i
    }
    append out "fn main(context log: handle::Log) -> List\[int\] errors IndexNotFound:\n"
    foreach {fn arg marker} $calls {
        append out "    f${fn}($arg):\n        on Boom:\n            handle::note($marker)\n            0\n"
    }
    append out "    handle::closed()\n\nwith context handle::create()\nmain():\n    on IndexNotFound:\n        \[\]\n"
    return $out
}

# ---------------------------------------------------------------------------
# The model. A frame is a list of scopes, each a list of {NAME ID} in
# acquisition order. Exits are Tcl return codes: 2 return, 3 break, 4
# continue, 5 fail.

proc logAppend {id} { lappend ::log $id }

# Release what SCOPE owns, the last acquired first.
proc releaseScope {scope} {
    foreach entry [lreverse $scope] {
        logAppend [lindex $entry 1]
    }
}

# Runs BODY as a new sequence in the frame; returns normally or with an exit
# code, the sequence's own Handles released either way.
proc runSeq {body env} {
    upvar 1 $env vars
    set scope {}
    set code 0
    foreach s $body {
        set code [catch {runStmt $s vars scope} result]
        if {$code != 0} break
    }
    releaseScope $scope
    if {$code == 1} {
        return -code error -errorinfo $::errorInfo $result
    }
    return -code $code $result
}

proc take {scopeVar name} {
    upvar 1 $scopeVar scope
    set i [lsearch -index 0 $scope $name]
    if {$i < 0} { error "model: $name not owned by its sequence" }
    set entry [lindex $scope $i]
    set scope [lreplace $scope $i $i]
    return [lindex $entry 1]
}

proc runStmt {s varsName scopeVar} {
    upvar 1 $varsName vars $scopeVar scope
    switch -- [dict get $s kind] {
        open { lappend scope [list [dict get $s name] [dict get $s id]] }
        note { logAppend [dict get $s id] }
        discard { logAppend [dict get $s id] }
        close { logAppend [take scope [dict get $s name]] }
        move { lappend scope [list [dict get $s to] [take scope [dict get $s name]]] }
        sink {
            set id [take scope [dict get $s name]]
            logAppend [dict get $s id]
            logAppend $id
        }
        if {
            set left [expr {[dict exists $s var] ? $vars([dict get $s var]) : $vars(n)}]
            set code 0
            if {[expr "$left [dict get $s op] [dict get $s t]"]} {
                set code [catch {runSeq [dict get $s then] vars} result]
            } elseif {[dict exists $s else]} {
                set code [catch {runSeq [dict get $s else] vars} result]
            }
            if {$code != 0} {
                return -code $code $result
            }
        }
        loop {
            for {set i 0} {$i < [dict get $s count]} {incr i} {
                set vars([dict get $s var]) $i
                set code [catch {runSeq [dict get $s body] vars} result]
                if {$code == 3} break
                if {$code == 4} continue
                if {$code != 0} {
                    return -code $code $result
                }
            }
        }
        block {
            set code [catch {runSeq [dict get $s body] vars} result]
            if {$code != 0} {
                return -code $code $result
            }
        }
        return { return -code 2 [dict get $s value] }
        fail { return -code 5 Boom }
        continue { return -code 4 }
        break { return -code 3 }
        call {
            set code [catch {runFunction [dict get $s fn] [expr {$vars(n) - 1}]} result]
            if {$code == 5} {
                return -code 5 $result
            }
        }
        coro {
            runCoroutine [dict get $s gen] [dict get $s resumes]
        }
        default { error "model: [dict get $s kind]" }
    }
    return
}

proc runFunction {i n} {
    array set vars [list n $n]
    set code [catch {runSeq [lindex $::functions $i] vars} result]
    if {$code == 5} {
        return -code 5 $result
    }
    if {$code != 0 && $code != 2} {
        return -code error "model: exit $code out of f$i: $result\n$::errorInfo"
    }
    return
}

# A coroutine started and resumed while it is not done, at most RESUMES
# times; then its handle's scope ends: completed, or abandoned (its frame's
# scopes released innermost first). The coroutine's body is straight-line
# with at most one nested block, so its frame is modeled directly: a list of
# open scopes, the innermost last.
proc runCoroutine {name resumes} {
    foreach c $::coroutineList {
        if {[dict get $c name] eq $name} {
            set body [dict get $c body]
        }
    }
    # The steps: flatten into events, with scope pushes and pops.
    set events {}
    foreach s $body {
        if {[dict get $s kind] eq "block"} {
            lappend events push
            foreach inner [dict get $s body] { lappend events $inner }
            lappend events pop
        } else {
            lappend events $s
        }
    }
    set scopes [list {}]
    set budget [expr {$resumes + 1}]
    set done 1
    foreach ev $events {
        if {$ev eq "push"} {
            lappend scopes {}
            continue
        }
        if {$ev eq "pop"} {
            releaseScope [lindex $scopes end]
            set scopes [lrange $scopes 0 end-1]
            continue
        }
        switch -- [dict get $ev kind] {
            open {
                set top [lindex $scopes end]
                lappend top [list [dict get $ev name] [dict get $ev id]]
                lset scopes end $top
            }
            note { logAppend [dict get $ev id] }
            yield {
                incr budget -1
                if {$budget == 0} {
                    set done 0
                    break
                }
            }
        }
    }
    # Completed: its last scope (the body's) is released at its end; abandoned
    # at the caller's scope end: every open scope, innermost first.
    foreach scope [lreverse $scopes] {
        releaseScope $scope
    }
}

proc model {functions coroutines calls} {
    set ::functions $functions
    set ::coroutineList $coroutines
    set ::log {}
    foreach {fn arg marker} $calls {
        set code [catch {runFunction $fn $arg} result]
        if {$code == 5} {
            logAppend $marker
        } elseif {$code != 0} {
            error "model: $result\n$::errorInfo"
        }
    }
    return $::log
}

# ---------------------------------------------------------------------------

set n [dict get $options -n]
set disagreements 0
set dir [file tempdir botlish-lexical-cleanup-fuzz]
file copy [file join $root tests resources handle.bot] [file join $dir handle.bot]
try {
    for {set p 0} {$p < $n} {incr p} {
        array unset ::counter
        set ::nextId 100
        set ::coroutineNames {}
        set coroutines {}
        set k [rnd 3]
        for {set c 0} {$c < $k} {incr c} {
            set name "gen$c"
            lappend coroutines [genCoroutine $name]
            lappend ::coroutineNames $name
        }
        set functions {}
        set count [expr {2 + [rnd 3]}]
        for {set i 0} {$i < $count} {incr i} {
            lappend functions [genBody $i 0 0 [expr {2 + [rnd 5]}]]
        }
        set calls {}
        for {set i 0} {$i < $count} {incr i} {
            foreach arg [lrange [lsort -unique [list [rnd 4] [rnd 4] [rnd 4]]] 0 1] {
                lappend calls $i $arg [expr {90000 + $i * 10 + $arg}]
            }
        }
        set text [printProgram $functions $coroutines $calls]
        set path [file join $dir p$p.bot]
        set f [open $path w]
        puts -nonewline $f $text
        close $f
        set expected "\[[join [model $functions $coroutines $calls] {, }]\]"
        if {[catch {surface::readProgramFile $path -warnings off} hir]} {
            incr disagreements
            puts "== program $p does not compile: [lindex [split $hir \n] 0]\n$text"
            continue
        }
        foreach backend [dict get $options -backends] {
            set outcome [outcomeUnderHir $backend $hir]
            if {[lindex $outcome 0] ne "value" || [lindex $outcome 1] ne $expected} {
                incr disagreements
                puts "== program $p on $backend: [string range [lrange $outcome 0 1] 0 600]\n   model: $expected\n$text"
                break
            }
        }
        if {[dict get $options -keep] ne ""} {
            file mkdir [dict get $options -keep]
            file copy -force $path [dict get $options -keep]
        }
    }
} finally {
    file delete -force $dir
}
puts "programs $n disagreements $disagreements"
exit [expr {$disagreements > 0}]
