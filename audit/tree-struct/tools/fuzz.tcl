#!/usr/bin/env tclsh9.0
# fuzz.tcl -- tree struct values and std::tree::walk against an independent
# model (TREE-STRUCT-MILESTONE-1.md, "Oracle and fuzzing").
#
#   tclsh9.0 audit/tree-struct/tools/fuzz.tcl ?-n N? ?-seed S?
#       ?-backends LIST? ?-interp-every N? ?-gc-stress 0|1?
#       ?-payloads KINDS? ?-deep N? ?-dump 1?
#
# Each program declares one tree struct -- a plain one with a str payload, or
# a parameterized `T[P]` applied to the payload kind (int, str or List[int])
# -- and builds a random tree and variants of it, biased toward what
# equality, hashing and traversal must get right:
#
#   shapes      a random tree, a unary chain (-deep nodes deep), a broad
#               root, a balanced tree, a tree holding repeated equal
#               subtrees, leaves with empty child Lists everywhere
#   same        the same tree rebuilt another way: nested construction, and
#               assembly from a vector in postorder (another allocation
#               order)
#   different   one payload changed (at a random node, or the deepest
#               leaf), two unequal siblings swapped, a child inserted, a
#               child removed
#
# and observes, for every tree, its preorder (DepthFirst) and breadth-first
# ids through std::tree::walk; for every pair, ==; for every tree, its exact
# public hash and its table hash under the fixed test key {1 2} (through a
# privileged fixture module); and the trees as MutableMap keys: how many are
# distinct and the index of the first equal one. The model is
# audit/tree-struct/tools/oracle.py (its own preorder, breadth-first order and
# equality; the Hashable oracle's struct encoding for the exact hashes).
# Every backend must give exactly its observations.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 20 -seed 1 -backends {interp compile cranelift-generic cranelift} -interp-every 3 \
    -gc-stress 0 -payloads {int str list plain} -deep 400 -dump 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set ::oracle [file join $root audit tree-struct tools oracle.py]
set ::key {1 2}

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {items} {
    return [lindex $items [Rand [llength $items]]]
}

# ---------------------------------------------------------------------------
# Trees: {ID {KID ...}}, ids fresh unless copied.

proc Fresh {} {
    return [incr ::ids]
}

proc Leaf {} {
    return [list [Fresh] {}]
}

proc RandomTree {budget depth} {
    set kids {}
    if {$depth < 7} {
        set n [Pick {0 0 1 1 2 2 3 4}]
        for {set i 0} {$i < $n && $budget > 0} {incr i} {
            incr budget -1
            lappend kids [RandomTree [expr {$budget / 2}] [expr {$depth + 1}]]
        }
    }
    return [list [Fresh] $kids]
}

proc Chain {n} {
    set t [Leaf]
    for {set i 0} {$i < $n} {incr i} {
        set t [list [Fresh] [list $t]]
    }
    return $t
}

proc Broad {n} {
    set kids {}
    for {set i 0} {$i < $n} {incr i} {
        lappend kids [Leaf]
    }
    return [list [Fresh] $kids]
}

proc Balanced {d} {
    if {$d == 0} {
        return [Leaf]
    }
    return [list [Fresh] [list [Balanced [expr {$d - 1}]] [Balanced [expr {$d - 1}]] [Balanced [expr {$d - 1}]]]]
}

# A tree holding a subtree twice (equal occurrences).
proc Repeated {} {
    set sub [RandomTree 4 3]
    return [list [Fresh] [list $sub [Leaf] $sub [list [Fresh] [list $sub]]]]
}

proc Base {deep} {
    switch -- [Rand 6] {
        0 { return [Chain [expr {1 + [Rand $deep]}]] }
        1 { return [Broad [expr {1 + [Rand 40]}]] }
        2 { return [Balanced [expr {1 + [Rand 3]}]] }
        3 { return [Repeated] }
        default { return [RandomTree 20 0] }
    }
}

# The node paths of TREE ({} the root, {I ...} child indices), in preorder.
proc Paths {tree {path {}}} {
    set stack [list [list $tree $path]]
    set out {}
    while {[llength $stack]} {
        lassign [lpop stack] t p
        lappend out $p
        set kids [lindex $t 1]
        for {set i [expr {[llength $kids] - 1}]} {$i >= 0} {incr i -1} {
            lappend stack [list [lindex $kids $i] [concat $p $i]]
        }
    }
    return $out
}

# TREE with the node at PATH replaced by the result of SCRIPT on it (NODE).
proc Edit {tree path script} {
    if {$path eq {}} {
        set node $tree
        return [uplevel 1 [list apply [list node $script] $tree]]
    }
    set i [lindex $path 0]
    set kids [lindex $tree 1]
    lset kids $i [uplevel 1 [list Edit [lindex $kids $i] [lrange $path 1 end] $script]]
    return [list [lindex $tree 0] $kids]
}

proc Depth {path} {
    return [llength $path]
}

proc Variant {tree} {
    set paths [Paths $tree]
    switch -- [Rand 5] {
        0 {
            # One payload changed, at a random node.
            return [Edit $tree [Pick $paths] {list [incr ::ids] [lindex $node 1]}]
        }
        1 {
            # The deepest leaf's payload changed.
            set deepest {}
            foreach p $paths {
                if {[llength $p] >= [llength $deepest]} { set deepest $p }
            }
            return [Edit $tree $deepest {list [incr ::ids] [lindex $node 1]}]
        }
        2 {
            # Two siblings swapped (the first two of a node with two or more).
            foreach p [lsort -command {apply {{a b} {expr {[Rand 3] - 1}}}} $paths] {
                set node [Lookup $tree $p]
                if {[llength [lindex $node 1]] >= 2} {
                    return [Edit $tree $p {
                        set kids [lindex $node 1]
                        list [lindex $node 0] [concat [list [lindex $kids 1] [lindex $kids 0]] [lrange $kids 2 end]]
                    }]
                }
            }
            return [Edit $tree {} {list [lindex $node 0] [concat [lindex $node 1] [list [list [incr ::ids] {}]]]}]
        }
        3 {
            # A child inserted.
            return [Edit $tree [Pick $paths] {list [lindex $node 0] [concat [list [list [incr ::ids] {}]] [lindex $node 1]]}]
        }
        default {
            # A child removed (or, at a leaf, one added).
            set p [Pick $paths]
            return [Edit $tree $p {
                set kids [lindex $node 1]
                if {[llength $kids] == 0} {
                    list [lindex $node 0] [list [list [incr ::ids] {}]]
                } else {
                    list [lindex $node 0] [lreplace $kids end end]
                }
            }]
        }
    }
}

proc Lookup {tree path} {
    foreach i $path {
        set tree [lindex $tree 1 $i]
    }
    return $tree
}

# ---------------------------------------------------------------------------
# Botlish text

proc PayloadType {kind} {
    return [dict get {int int str str list List[int] plain str} $kind]
}

proc PayloadOf {kind} {
    return [dict get {int {3 * id} str {"n".concat(std::int::to_string(id))} list {[id, id + 1]} plain {"n".concat(std::int::to_string(id))}} $kind]
}

proc Declarations {kind} {
    set p [PayloadType $kind]
    if {$kind eq "plain"} {
        set decl "tree struct T:\n    id: int\n    payload: str\n    kids: List\[T\]\n"
        set t T
    } else {
        set decl "tree struct T\[P\]:\n    id: int\n    payload: P\n    kids: List\[T\[P\]\]\n"
        set t "T\[$p\]"
    }
    return [list "import std::coroutine
import std::int
import std::mutable_map
import std::mutable_vector
import std::str
import std::tree
import std::hashfix

$decl
nomethod fn n(id: int, kids: List\[$t\]) -> $t:
    T {id: id, payload: [PayloadOf $kind], kids: kids}

# The node ID with the last K nodes of ST as its children (postorder
# assembly).
nomethod fn gather(place st: MutableVector\[$t\], k: int, id: int) -> unit:
    total = std::mutable_vector::length(st)
    kids = loop j from total - k to total:
        st.at(j):
            on IndexNotFound:
                n(0, \[\])
    loop j from 0 to k:
        dropped = st.pop():
            on IndexNotFound:
                n(0, \[\])
    st.push(n(id, kids))

nomethod fn chain(depth: int, first: int) -> $t:
    acc = std::mutable_vector::from_list(\[n(first, \[\])\])
    loop i from 1 through depth:
        below = acc.pop():
            on IndexNotFound:
                n(0, \[\])
        acc.push(n(first + i, \[below\]))
    acc.at(0):
        on IndexNotFound:
            n(0, \[\])

nomethod fn record(place obs: MutableVector\[int\], t: $t, order: std::tree::Order) -> unit:
    coroutine {step, first} = std::tree::walk(t, order)
    obs.push(first.id)
    loop:
        if std::coroutine::done?(step):
            break
        obs.push(step().id)

nomethod fn bit(b: bool) -> int:
    if b:
        return 1
    0

obs = std::mutable_vector::from_list(\[0\])
obs.clear()
" $t]
}

# A nested construction expression of TREE (the chain helper for a unary
# chain built by Chain, whose ids are consecutive from its leaf up).
proc Nested {tree} {
    # Iterative: postorder over a stack, each node's text from its kids'.
    set texts [dict create]
    set stack [list [list $tree 0]]
    set done {}
    while {[llength $stack]} {
        lassign [lpop stack] t expanded
        if {!$expanded} {
            lappend stack [list $t 1]
            foreach kid [lreverse [lindex $t 1]] {
                lappend stack [list $kid 0]
            }
            continue
        }
        set kids [lmap kid [lindex $t 1] {lpop done}]
        lappend done "n([lindex $t 0], \[[join [lreverse $kids] {, }]\])"
    }
    return [lindex $done 0]
}

# 1 if TREE is a unary chain with consecutive ids from its leaf up: {FIRST
# DEPTH}, else "".
proc ChainOf {tree} {
    set ids {}
    set t $tree
    while 1 {
        lappend ids [lindex $t 0]
        set kids [lindex $t 1]
        if {[llength $kids] == 0} break
        if {[llength $kids] != 1} { return "" }
        set t [lindex $kids 0]
    }
    set ids [lreverse $ids]
    for {set i 0} {$i < [llength $ids]} {incr i} {
        if {[lindex $ids $i] != [lindex $ids 0] + $i} { return "" }
    }
    return [list [lindex $ids 0] [expr {[llength $ids] - 1}]]
}

# Statements binding NAME to TREE, built HOW: nested (a construction
# expression; a deep chain through the chain helper) or assembled (postorder
# assembly through a vector).
proc Build {name tree how type} {
    set chain [ChainOf $tree]
    if {$chain ne "" && [lindex $chain 1] > 30} {
        return "$name = chain([lindex $chain 1], [lindex $chain 0])\n"
    }
    if {$how eq "nested" && [MaxDepth $tree] <= 30} {
        return "$name = [Nested $tree]\n"
    }
    set st "st_$name"
    set text "$st = std::mutable_vector::from_list(\[n(0, \[\])\])\n$st.clear()\n"
    set stack [list [list $tree 0]]
    while {[llength $stack]} {
        lassign [lpop stack] t expanded
        if {!$expanded} {
            lappend stack [list $t 1]
            foreach kid [lreverse [lindex $t 1]] {
                lappend stack [list $kid 0]
            }
            continue
        }
        append text "gather($st, [llength [lindex $t 1]], [lindex $t 0])\n"
    }
    append text "$name = $st.at(0):\n    on IndexNotFound:\n        n(0, \[\])\n"
    return $text
}

proc MaxDepth {tree} {
    set deepest 0
    foreach p [Paths $tree] {
        set deepest [expr {max($deepest, [llength $p])}]
    }
    return $deepest
}

proc Json {tree} {
    # Iterative, as Nested.
    set stack [list [list $tree 0]]
    set done {}
    while {[llength $stack]} {
        lassign [lpop stack] t expanded
        if {!$expanded} {
            lappend stack [list $t 1]
            foreach kid [lreverse [lindex $t 1]] {
                lappend stack [list $kid 0]
            }
            continue
        }
        set kids [lmap kid [lindex $t 1] {lpop done}]
        lappend done "{\"id\": [lindex $t 0], \"kids\": \[[join [lreverse $kids] {, }]\]}"
    }
    return [lindex $done 0]
}

proc Program {kind deep} {
    set ::ids 0
    set base [Base $deep]
    set trees [list $base $base]
    set hows {nested assembled}
    for {set i [Rand 4]} {$i >= 0} {incr i -1} {
        set v [Variant $base]
        lappend trees $v
        lappend hows [Pick {nested assembled}]
    }
    # Sometimes a variant of a variant, and the base once more.
    if {[Rand 2]} {
        lappend trees [Variant [lindex $trees end]]
        lappend hows nested
    }
    lappend trees $base
    lappend hows [Pick {nested assembled}]
    lassign [Declarations $kind] text type
    set i 0
    foreach t $trees how $hows {
        append text [Build t$i $t $how $type]
        incr i
    }
    set n [llength $trees]
    for {set i 0} {$i < $n} {incr i} {
        append text "obs.push(-1)\nrecord(obs, t$i, std::tree::Order::DepthFirst)\nobs.push(-2)\nrecord(obs, t$i, std::tree::Order::BreadthFirst)\n"
    }
    for {set i 0} {$i < $n} {incr i} {
        for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
            append text "obs.push(bit(t$i == t$j))\n"
        }
    }
    for {set i 0} {$i < $n} {incr i} {
        append text "obs.push(hash(t$i))\nobs.push(std::hashfix::keyed(t$i))\n"
    }
    append text "km = std::mutable_map::create\[$type, int\]()\n"
    for {set i 0} {$i < $n} {incr i} {
        append text "if not km.contains(t$i):\n    km.set(t$i, $i)\n"
    }
    append text "obs.push(std::mutable_map::length(km))\n"
    for {set i 0} {$i < $n} {incr i} {
        append text "first$i = km.at(t$i):\n    on std::mutable_map::KeyNotFound:\n        -1\nobs.push(first$i)\n"
    }
    append text "loop x in obs:\n    x\n"
    set declaration T
    set payload [expr {$kind eq "plain" ? "str" : $kind}]
    set json "{\"declaration\": \"$declaration\", \"payload\": \"$payload\", \"trees\": \[[join [lmap t $trees {Json $t}] {, }]\]}"
    return [list $text $json [llength $trees]]
}

proc Expected {json} {
    set out [exec python3 -I $::oracle run {*}$::key << $json]
    return "\[[join [split [string trim $out] \n] {, }]\]"
}

# ---------------------------------------------------------------------------
# The run

set seedState [dict get $options -seed]
set fixture {import std::table_hash

fn keyed(x: Hashable) -> int:
    std::table_hash::of(x)
}
set programs 0
set observations 0
set runs 0
set failures 0
withPrivateLibrary {
    set f [open [file join $::core::libraryDir hashfix.bot] w]
    puts -nonewline $f $fixture
    close $f
    core::hashing::useTableHashKey $::key
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set kind [Pick [dict get $options -payloads]]
        lassign [Program $kind [dict get $options -deep]] text json count
        if {[dict get $options -dump]} {
            puts "---- program $p ($kind, $count trees)\n$text"
        }
        set expected [Expected $json]
        incr observations [llength [split $expected ,]]
        if {[catch {surface::compile $text fuzz.bot -warnings off} hir]} {
            puts "program $p ($kind): does not compile: [string range $hir 0 400]"
            incr failures
            continue
        }
        set backends {}
        foreach backend [dict get $options -backends] {
            set every [dict get $options -interp-every]
            if {$backend eq "interp" && ($every == 0 || $p % $every != 0)} continue
            lappend backends $backend
        }
        foreach backend $backends {
            incr runs
            set outcome [outcomeUnderHir $backend $hir]
            if {$outcome ne [list value $expected {}]} {
                puts "program $p ($kind) DISAGREES on $backend:\n  got      [string range [lrange $outcome 0 1] 0 600]\n  expected [string range $expected 0 600]"
                incr failures
            }
        }
        if {[dict get $options -gc-stress]} {
            incr runs
            set ::env(BOTLISH_NATIVE_GC_STRESS) 1
            try {
                set outcome [outcomeUnderHir cranelift $hir]
            } finally {
                unset ::env(BOTLISH_NATIVE_GC_STRESS)
            }
            if {$outcome ne [list value $expected {}]} {
                puts "program $p ($kind) DISAGREES under GC stress:\n  got      [string range [lrange $outcome 0 1] 0 600]\n  expected [string range $expected 0 600]"
                incr failures
            }
        }
        incr programs
    }
    core::hashing::useTableHashKey ""
}
puts "tree-struct fuzz: seed [dict get $options -seed]: $programs programs, $observations observations, $runs backend runs, $failures disagreements"
exit [expr {$failures > 0}]
