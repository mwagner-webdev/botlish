#!/usr/bin/env tclsh9.0
# fuzz.tcl -- std::mutable_map and std::mutable_set against an independent
# model (ORDERED-MUTABLE-MAP-SET.md, "Fuzzing").
#
#   tclsh9.0 audit/mutable-map/tools/fuzz.tcl ?-n N? ?-seed S? ?-ops N?
#       ?-backends LIST? ?-gc-stress 0|1? ?-keys KINDS? ?-dump 1?
#       ?-keyed 0|1? ?-profile PROFILE? ?-sugar N? ?-interp-every N?
#
# Each program is one long, stateful operation sequence over several
# collections -- MutableMap[K, int] and MutableSet[K] variables, some of them
# logical copies of others (`b = a`) -- of one key kind K:
#
#   int        an Int (ids from a small range)
#   collide    an Int of the public hash's collision corpus
#              (audit/hashable/data/int-collide-1024.txt: all on one home
#              slot under the public hash, so ordinary keys to the table)
#   kcollide   an Int of audit/mutable-map/data/keyed-collide.txt, all on
#              one home slot (of every index up to 1024 slots) under the
#              table hash's hidden key {1 2}, which every run of such a
#              program installs: genuine collisions of the table's own hash
#   str        its decimal text
#   enum       a case of an 8-case enum
#   struct     P {id: ID, name: "nID"}
#   nested     Q {inner: P {...}, tags: [ID, 7]}
#   list       [ID, 3]
#
# Every key is built where it is used, from its integer id (so equal keys are
# built independently), and the construction is injective in the id: two keys
# are equal exactly when their ids are, which is all the model needs to know
# of Botlish equality. The operations: set a new or an existing key, at
# (hit, miss), contains, remove (hit, miss), length, clear, iterate, copy,
# fill (a loop inserting a run of fresh keys: growth), drain (a loop removing
# most keys: compaction and the index shrinking), and bump (a loop over a
# collection that mutates it in its body: replace, insert, remove and growth
# during iteration). The biases favour what breaks tables: copies mutated in
# turn around growth, removal and compaction, re-insertion after removal,
# long histories of one key pool. Each observation is an Int the program
# pushes; the program's result is the List of them.
#
# The model is audit/mutable-map/tools/oracle.py (Python dicts and an ordered
# set model; it never hashes). Every backend must give exactly the model's
# observations; with -keyed 1 every program also runs on every backend under
# two fixed hidden keys (core::hashing::useTableHashKey, forwarded to the
# native driver), which must give the same observations -- the hidden key
# changes placement, never an observation. With -gc-stress 1 each program
# runs once more on cranelift with a collection at every allocation site.
#
# The reference interpreter (`interp`) is two orders of magnitude slower
# than the compiled backends on these programs, so it runs every
# -interp-every'th program (0: never, 1: every one); every other backend
# runs every program. The hidden keys' runs leave it out (the compiled Tcl
# backend runs the same Tcl table hash). Every -sugar'th program writes its
# collection calls with method syntax, the others qualified (Call, below).
#
# Profiles: `small` (the default: 8 to 30 keys, every backend), `large`
# (hundreds of keys and long fills: use -backends with the native backends).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 20 -seed 1 -ops 120 -backends {interp compile cranelift-generic cranelift} \
    -gc-stress 0 -keys {int str enum struct nested list collide kcollide} -dump 0 -keyed 1 -profile small \
    -sugar 4 -interp-every 3]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set ::oracle [file join $root audit mutable-map tools oracle.py]
set ::corpus [string trim [core::ReadFile [file join $root audit hashable data int-collide-1024.txt]]]
set ::kcorpus [string trim [core::ReadFile [file join $root audit mutable-map data keyed-collide.txt]]]

# ---------------------------------------------------------------------------
# Deterministic choices

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {items} {
    return [lindex $items [Rand [llength $items]]]
}

# ---------------------------------------------------------------------------
# Key kinds: the Botlish type, a key built from a literal id, from an Int
# expression, and the id of a key value (tag).

proc KeyType {kind} {
    switch -- $kind {
        int - collide - kcollide { return int }
        str { return str }
        enum { return Color }
        struct { return P }
        nested { return Q }
        list { return List\[int\] }
    }
}

proc KeyLiteral {kind id} {
    switch -- $kind {
        int - collide - kcollide { return $id }
        str { return "\"$id\"" }
        enum { return "Color::C$id" }
        struct { return "P {id: $id, name: \"n$id\"}" }
        nested { return "Q {inner: P {id: $id, name: \"n$id\"}, tags: \[$id, 7\]}" }
        list { return "\[$id, 3\]" }
    }
}

proc Declarations {kind} {
    set t [KeyType $kind]
    set text "import std::list\nimport std::str\nimport std::int\nimport std::mutable_map\nimport std::mutable_set\nimport std::mutable_vector\n\n"
    append text "struct P:\n    id: int\n    name: str\n\nstruct Q:\n    inner: P\n    tags: List\[int\]\n\n"
    append text "enum Color:\n    [join [lmap i {0 1 2 3 4 5 6 7} {string cat C$i}] {, }]\n\n"
    append text "fn color(i: int) -> Color:\n"
    foreach i {0 1 2 3 4 5 6} {
        append text "    if i == $i:\n        return Color::C$i\n"
    }
    append text "    Color::C7\n\n"
    append text "fn tag(x: $t) -> int:\n"
    switch -- $kind {
        int - collide - kcollide { append text "    x\n" }
        str { append text "    n = std::int::from_string(x):\n        on InvalidIntegerText:\n            -1\n    n\n" }
        enum {
            foreach i {0 1 2 3 4 5 6 7} {
                append text "    if x == Color::C$i:\n        return $i\n"
            }
            append text "    -1\n"
        }
        struct { append text "    x.id\n" }
        nested { append text "    x.inner.id\n" }
        list { append text "    n = std::list::at(x, 0):\n        on IndexNotFound:\n            -1\n    n\n" }
    }
    append text "\nfn key(i: int) -> $t:\n"
    switch -- $kind {
        int - collide - kcollide { append text "    i\n" }
        str { append text "    std::int::to_string(i)\n" }
        enum { append text "    color(i)\n" }
        struct { append text "    P {id: i, name: std::str::concat(\"n\", std::int::to_string(i))}\n" }
        nested { append text "    Q {inner: P {id: i, name: std::str::concat(\"n\", std::int::to_string(i))}, tags: \[i, 7\]}\n" }
        list { append text "    \[i, 3\]\n" }
    }
    append text "\nfn bit(b: bool) -> int:\n    if b:\n        return 1\n    0\n\n"
    append text "fn obs_map(place out: MutableVector\[int\], m: std::mutable_map::MutableMap\[$t, int\]) -> unit:\n    out.push(-9)\n    loop e in m:\n        out.push(tag(e.key))\n        out.push(e.value)\n    unit\n\n"
    append text "fn obs_set(place out: MutableVector\[int\], s: std::mutable_set::MutableSet\[$t\]) -> unit:\n    out.push(-9)\n    loop x in s:\n        out.push(tag(x))\n    unit\n\n"
    append text "fn fill_map(place m: std::mutable_map::MutableMap\[$t, int\], a: int, b: int, step: int, x: int) -> unit:\n    loop k from a to b:\n        if (k - a).mod(step) != 0:\n            continue\n        m.set(key(k), x + k)\n    unit\n\n"
    append text "fn fill_set(place s: std::mutable_set::MutableSet\[$t\], a: int, b: int, step: int) -> unit:\n    loop k from a to b:\n        if (k - a).mod(step) != 0:\n            continue\n        s.add(key(k))\n    unit\n\n"
    append text "fn drain_map(place m: std::mutable_map::MutableMap\[$t, int\], a: int, b: int, step: int) -> unit:\n    loop k from a to b:\n        if (k - a).mod(step) != 0:\n            continue\n        r = [Call map remove m "key(k)"]:\n            on std::mutable_map::KeyNotFound:\n                -1\n    unit\n\n"
    append text "fn drain_set(place s: std::mutable_set::MutableSet\[$t\], a: int, b: int, step: int) -> unit:\n    loop k from a to b:\n        if (k - a).mod(step) != 0:\n            continue\n        [Call set remove s "key(k)"]\n    unit\n\n"
    append text "fn bump_map(place out: MutableVector\[int\], place m: std::mutable_map::MutableMap\[$t, int\], offset: int) -> unit:\n    loop e in m:\n        out.push(tag(e.key))\n        m.set(e.key, e.value + 1)\n        m.set(key(tag(e.key) + offset), e.value)\n    unit\n\n"
    append text "fn bump_set(place out: MutableVector\[int\], place s: std::mutable_set::MutableSet\[$t\], offset: int) -> unit:\n    loop x in s:\n        out.push(tag(x))\n        [Call set remove s x]\n        s.add(key(tag(x) + offset))\n    unit\n\n"
    return $text
}

# ---------------------------------------------------------------------------
# Programs

# A call of collection operation OP on V (a WHAT: map or set) with the
# argument text ARGS: method syntax when the program is sugared, else the
# qualified call (a program importing both collections pays the exact
# method-call decision for every method name both define -- length,
# contains, remove, clear: ORDERED-MUTABLE-MAP-SET.md, "Limitations" -- so
# most programs spell the calls qualified, and every -sugar'th one with
# method syntax).
proc Call {what op v {args_ ""}} {
    if {$::sugared} {
        return "$v.$op\($args_)"
    }
    if {$args_ eq ""} {
        return "std::mutable_$what\::$op\($v)"
    }
    return "std::mutable_$what\::$op\($v, $args_)"
}

# One program: {SOURCE OPS} -- the Botlish source and the model's operations.
proc Program {kind count opsN profile} {
    # The key pool: ids.
    switch -- $kind {
        enum { set pool {0 1 2 3 4 5 6 7} }
        collide { set pool [lrange $::corpus 0 [expr {$count - 1}]] }
        kcollide { set pool [lrange $::kcorpus 0 [expr {$count - 1}]] }
        default {
            set pool {}
            for {set i 0} {$i < $count} {incr i} {
                lappend pool [expr {$i * 3 + 1}]
            }
        }
    }
    set t [KeyType $kind]
    set src [Declarations $kind]
    append src "out = std::mutable_vector::from_list(\[0\])\n"
    set ops {}
    set vars {}
    set n 0
    # Two collections to start: a map and a set.
    foreach {v what} {m0 map s0 set} {
        if {$what eq "map"} {
            append src "$v = std::mutable_map::create\[$t, int\]()\n"
        } else {
            append src "$v = std::mutable_set::create\[$t\]()\n"
        }
        lappend ops [list new $v $what]
        dict set vars $v $what
    }
    set fillBase 100000
    for {set step 0} {$step < $opsN} {incr step} {
        set v [Pick [dict keys $vars]]
        set what [dict get $vars $v]
        set id [Pick $pool]
        set k [KeyLiteral $kind $id]
        set r [Rand 100]
        incr n
        if {$r < 30} {
            if {$what eq "map"} {
                set x [expr {$step * 10 + [Rand 10]}]
                append src "[Call map set $v "$k, $x"]\n"
                lappend ops [list set $v $id $x]
            } else {
                append src "out.push(bit([Call set add $v $k]))\n"
                lappend ops [list add $v $id]
            }
        } elseif {$r < 45} {
            if {$what eq "map"} {
                append src "r$n = [Call map at $v $k]:\n    on std::mutable_map::KeyNotFound:\n        -1\nout.push(r$n)\n"
                lappend ops [list at $v $id]
            } else {
                append src "out.push(bit([Call set contains $v $k]))\n"
                lappend ops [list contains $v $id]
            }
        } elseif {$r < 52} {
            append src "out.push(bit([Call $what contains $v $k]))\n"
            lappend ops [list contains $v $id]
        } elseif {$r < 67} {
            if {$what eq "map"} {
                append src "r$n = [Call map remove $v $k]:\n    on std::mutable_map::KeyNotFound:\n        -1\nout.push(r$n)\n"
            } else {
                append src "out.push(bit([Call set remove $v $k]))\n"
            }
            lappend ops [list remove $v $id]
        } elseif {$r < 72} {
            append src "out.push([Call $what length $v])\n"
            lappend ops [list length $v]
        } elseif {$r < 74} {
            append src "[Call $what clear $v]\n"
            lappend ops [list clear $v]
        } elseif {$r < 82} {
            append src "obs_$what\(out, $v)\n"
            lappend ops [list iterate $v]
        } elseif {$r < 88 && [dict size $vars] < 7} {
            set w "c$n"
            append src "$w = $v\n"
            lappend ops [list copy $v $w]
            dict set vars $w $what
        } elseif {$r < 93 && $kind ne "enum"} {
            # A fill: a run of fresh keys (growth through several rebuilds).
            set len [expr {$profile eq "large" ? 40 + [Rand 400] : 5 + [Rand 40]}]
            set a [expr {$fillBase + [Rand 7]}]
            set stride [expr {1 + [Rand 3]}]
            set b [expr {$a + $len * $stride}]
            incr fillBase 10000
            if {$what eq "map"} {
                set x [Rand 1000]
                append src "fill_map($v, $a, $b, $stride, $x)\n"
                lappend ops [list fill $v $a $b $stride $x]
            } else {
                append src "fill_set($v, $a, $b, $stride)\n"
                lappend ops [list fill $v $a $b $stride]
            }
        } elseif {$r < 97 && $kind ne "enum"} {
            # A drain: most of the last fills' keys removed (compaction).
            set a [expr {$fillBase - 10000 * (1 + [Rand 3])}]
            if {$a < 100000} {
                set a 100000
            }
            set b [expr {$a + 10000}]
            append src "drain_$what\($v, $a, $b, 1)\n"
            lappend ops [list drain $v $a $b 1]
        } elseif {$kind ni {enum collide kcollide}} {
            # A loop that mutates its collection: the snapshot.
            set offset [expr {1000000 + 1000000 * [Rand 3]}]
            append src "bump_$what\(out, $v, $offset)\n"
            lappend ops [list bump $v $offset]
        } else {
            append src "out.push([Call $what length $v])\n"
            lappend ops [list length $v]
        }
    }
    # The final state of every collection.
    dict for {v what} $vars {
        append src "out.push([Call $what length $v])\nobs_$what\(out, $v)\n"
        lappend ops [list length $v] [list iterate $v]
    }
    append src "result = loop x in out:\n    x\nresult\n"
    return [list $src $ops]
}

# The model's observations of OPS (with the leading 0 the program pushes
# first), as the rendering of a List of Ints.
proc Expected {ops} {
    set json "\[[join [lmap op $ops {
        set parts [lmap x $op {expr {[string is entier -strict $x] ? $x : "\"$x\""}}]
        string cat "\[" [join $parts ", "] "\]"
    }] {, }]\]"
    set out [exec python3 -I $::oracle << $json]
    set values [concat 0 [string map {"\[" "" "\]" "" "," ""} $out]]
    return "\[[join $values {, }]\]"
}

proc RunBackends {hir backends} {
    set result {}
    foreach backend $backends {
        set t0 [clock milliseconds]
        set outcome [outcomeUnderHir $backend $hir]
        dict incr ::timeOf $backend [expr {[clock milliseconds] - $t0}]
        if {[lindex $outcome 0] eq "value"} {
            lappend result $backend [lindex $outcome 1]
        } else {
            lappend result $backend [lrange $outcome 0 2]
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# The run

set seedState [dict get $options -seed]
set backends [dict get $options -backends]
set kinds [dict get $options -keys]
set failures 0
set programs 0
set observations 0
set operationCount 0
set runCount 0
set timeOf [dict create]
set start [clock milliseconds]
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set kind [lindex $kinds [expr {$p % [llength $kinds]}]]
    set sugar [dict get $options -sugar]
    set ::sugared [expr {$sugar > 0 && $p % $sugar == $sugar - 1}]
    set every [dict get $options -interp-every]
    set runOn [lmap b $backends {
        if {$b eq "interp" && ($every == 0 || $p % $every != 0)} continue
        set b
    }]
    set count [expr {[dict get $options -profile] eq "large" ? 50 + [Rand 300] : 8 + [Rand 23]}]
    lassign [Program $kind $count [dict get $options -ops] [dict get $options -profile]] src ops
    incr programs
    incr operationCount [llength $ops]
    set keyedOn [lmap b $runOn {if {$b eq "interp"} continue; set b}]
    incr runCount [expr {[llength $runOn] + ([dict get $options -keyed] ? 2 * [llength $keyedOn] : 0) + [dict get $options -gc-stress]}]
    if {[dict get $options -dump]} {
        puts "---- program $p ($kind)\n$src"
    }
    set expected [Expected $ops]
    incr observations [llength [split $expected ,]]
    set t0 [clock milliseconds]
    set compiled [catch {surface::compile $src -warnings off} hir options2]
    dict incr ::timeOf front-end [expr {[clock milliseconds] - $t0}]
    if {$compiled} {
        puts "program $p ($kind, sugared $::sugared): does not compile: $hir"
        incr failures
        continue
    }
    if {$kind eq "kcollide"} {
        # The colliding key in force for the first run too, so that the
        # collisions are exercised whatever -keyed says.
        core::hashing::useTableHashKey {1 2}
        try {
            set runs [list {1 2} [RunBackends $hir $runOn]]
        } finally {
            core::hashing::useTableHashKey ""
        }
    } else {
        set runs [list drawn [RunBackends $hir $runOn]]
    }
    if {[dict get $options -keyed]} {
        foreach key {{1 2} {0x9e3779b97f4a7c15 0xbf58476d1ce4e5b9}} {
            core::hashing::useTableHashKey $key
            try {
                lappend runs $key [RunBackends $hir [lmap b $runOn {if {$b eq "interp"} continue; set b}]]
            } finally {
                core::hashing::useTableHashKey ""
            }
        }
    }
    if {[dict get $options -gc-stress]} {
        set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        try {
            lappend runs gc-stress [RunBackends $hir cranelift]
        } finally {
            unset ::env(BOTLISH_NATIVE_GC_STRESS)
        }
    }
    set bad {}
    foreach {label result} $runs {
        foreach {backend value} $result {
            if {$value ne $expected} {
                lappend bad "$label/$backend: $value"
            }
        }
    }
    if {$bad ne {}} {
        incr failures
        puts "program $p ($kind, sugared $::sugared, seed [dict get $options -seed]): DISAGREES with the model"
        puts "  expected $expected"
        foreach b $bad {
            puts "  $b"
        }
        if {![dict get $options -dump]} {
            set path [file join [file tempdir] fuzz-$p.bot]
            set f [open $path w]
            puts -nonewline $f $src
            close $f
            puts "  program written to $path"
        }
    }
}
set seconds [expr {([clock milliseconds] - $start) / 1000.0}]
puts [format "%d programs, %d operations, %d observations, %d runs, %d failing (%.1f s)" \
    $programs $operationCount $observations $runCount $failures $seconds]
puts "  seconds: [join [lmap {k v} $timeOf {format "%s %.1f" $k [expr {$v / 1000.0}]}] {, }]"
exit [expr {$failures > 0}]
