#!/usr/bin/env tclsh9.0
# fuzz.tcl -- immutable maps and their identity against an independent model
# (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md, "Fuzzing").
#
#   tclsh9.0 audit/value-identity/tools/fuzz.tcl ?-n N? ?-seed S?
#       ?-backends LIST? ?-interp-every N? ?-gc-stress 0|1? ?-keys KINDS?
#       ?-values KINDS? ?-maps N? ?-dump 1?
#
# Each program builds several MutableMap[K, V]s through random histories and
# freezes each into an ImmutableMap, biased toward the cases identity must
# get right:
#
#   same content, another order       the target associations inserted in
#                                     another order, or reordered (a
#                                     candidate validated, then installed)
#   same content, another history     a reserved capacity, junk keys added
#                                     and removed (dead entries, compaction),
#                                     values set wrong then replaced, a
#                                     clear midway, a run of fresh keys then
#                                     drained (growth and shrinking)
#   another content, same length      one value changed, one key replaced
#   another content, other length     one key more or fewer
#   derived                           a frozen map reordered by a validated
#                                     candidate (`reordered`): equal to its
#                                     source, in the candidate's order
#
# and observes every frozen map's length and iteration (key and value ids),
# the pairwise equality of the maps and of their public hashes, each map's
# exact public hash and table hash (under the fixed test key {1 2}, through
# a privileged fixture module), and the maps used as keys: the number of
# distinct maps in a MutableMap keyed by them and in a MutableSet of them,
# and for each map the index of the first map equal to it (found as a key).
#
# Key kinds K: int (small ids), collide (Ints of the public hash's collision
# corpus), str (decimal text), struct (P {id, name}), list ([id, 3]) and imap
# (the ImmutableMap[int, int] {i: 2i, i + 1: i + 5}, built in an order that
# depends on i: keys whose own equality is an identity's). Value kinds V:
# int, str, list and imap. Every key and value is built from an Int id by an
# injective construction, so two are equal exactly when their ids are, which
# is all the model needs to know of equality.
#
# The model is audit/value-identity/tools/oracle.py: Python dicts, mapping
# equality, and the Hashable oracle's encoding for the exact hashes. Every
# backend must give exactly its observations.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 20 -seed 1 -backends {interp compile cranelift-generic cranelift} -interp-every 3 \
    -gc-stress 0 -keys {int collide str struct list imap} -values {int str list imap} -maps 6 -dump 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set ::oracle [file join $root audit value-identity tools oracle.py]
set ::corpus [string trim [core::ReadFile [file join $root audit hashable data int-collide-1024.txt]]]
set ::key {1 2}

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {items} {
    return [lindex $items [Rand [llength $items]]]
}

# A fresh top-level name: a program binds every name once.
proc U {name} {
    return "${name}[incr ::uniq]"
}

proc Shuffle {items} {
    set out {}
    while {[llength $items]} {
        set i [Rand [llength $items]]
        lappend out [lindex $items $i]
        set items [lreplace $items $i $i]
    }
    return $out
}

# ---------------------------------------------------------------------------
# Kinds: the Botlish type, the construction from an Int expression, the id
# read back.

proc KeyType {kind} {
    return [dict get {int int collide int str str struct P list List[int] imap {std::immutable_map::ImmutableMap[int, int]}} $kind]
}

proc ValueType {kind} {
    return [dict get {int int str str list List[int] imap {std::immutable_map::ImmutableMap[int, int]}} $kind]
}

proc Declarations {kk vk} {
    set kt [KeyType $kk]
    set vt [ValueType $vk]
    set text "import std::list
import std::int
import std::mutable_map
import std::mutable_set
import std::mutable_vector
import std::immutable_map
import std::hashfix

struct P:
    id: int
    name: str

fn small(i: int) -> std::immutable_map::ImmutableMap\[int, int\]:
    m = std::mutable_map::create\[int, int\]()
    if i.mod(2) == 0:
        m.set(i, 2 * i)
        m.set(i + 1, i + 5)
    else:
        m.set(i + 1, i + 5)
        m.set(i, 2 * i)
    m.freeze()

fn smallTag(m: std::immutable_map::ImmutableMap\[int, int\]) -> int:
    ks = loop e in m:
        e.key
    a = std::list::at(ks, 0):
        on IndexNotFound:
            0
    b = std::list::at(ks, 1):
        on IndexNotFound:
            0
    if a < b:
        return a
    b

fn observations() -> MutableVector\[int\]:
    v = std::mutable_vector::from_list(\[0\])
    x = v.pop():
        on IndexNotFound:
            0
    v

fn bit(b: bool) -> int:
    if b:
        return 1
    0

fn textTag(s: str) -> int:
    n = std::int::from_string(s):
        on InvalidIntegerText:
            -1
    n

"
    append text [Builder key ktag $kk $kt]
    append text [Builder val vtag $vk $vt]
    append text "
fn freezeWith(m: std::mutable_map::MutableMap\[$kt, $vt\]) -> std::immutable_map::ImmutableMap\[$kt, $vt\]:
    m.freeze()

fn observe(place obs: MutableVector\[int\], f: std::immutable_map::ImmutableMap\[$kt, $vt\]) -> unit:
    obs.push(f.length())
    loop e in f:
        obs.push(ktag(e.key))
        obs.push(vtag(e.value))
    unit

"
    return $text
}

# The constructor NAME(i) -> TYPE and reader TAG(x) -> int of KIND.
proc Builder {name tag kind type} {
    switch -- $kind {
        int - collide {
            return "fn $name\(i: int) -> int:\n    i\n\nfn $tag\(x: int) -> int:\n    x\n\n"
        }
        str {
            return "fn $name\(i: int) -> str:\n    std::int::to_string(i)\n\nfn $tag\(x: str) -> int:\n    textTag(x)\n\n"
        }
        struct {
            return "fn $name\(i: int) -> P:\n    P {id: i, name: std::int::to_string(i)}\n\nfn $tag\(x: P) -> int:\n    x.id\n\n"
        }
        list {
            if {$name eq "key"} {
                return "fn $name\(i: int) -> List\[int\]:\n    \[i, 3\]\n\nfn $tag\(x: List\[int\]) -> int:\n    v = std::list::at(x, 0):\n        on IndexNotFound:\n            -1\n    v\n\n"
            }
            return "fn $name\(i: int) -> List\[int\]:\n    \[i, i + 1\]\n\nfn $tag\(x: List\[int\]) -> int:\n    v = std::list::at(x, 0):\n        on IndexNotFound:\n            -1\n    v\n\n"
        }
        imap {
            return "fn $name\(i: int) -> std::immutable_map::ImmutableMap\[int, int\]:\n    small(i)\n\nfn $tag\(x: std::immutable_map::ImmutableMap\[int, int\]) -> int:\n    smallTag(x)\n\n"
        }
    }
}

# ---------------------------------------------------------------------------
# Programs

# A history (ops, the model's) of a MutableMap ending with the associations
# TARGET (a dict, id -> value id, in its order), from the key pool POOL.
proc History {target pool} {
    set ops {}
    set keys [dict keys $target]
    if {[Rand 3] == 0} {
        # Junk first: keys of the pool no target holds, set and removed.
        foreach k [lrange [Shuffle $pool] 0 [Rand 6]] {
            if {[dict exists $target $k]} continue
            lappend ops [list set $k [expr {[Rand 50] + 100}]]
        }
    }
    if {[Rand 4] == 0} {
        # A run of fresh keys (growth), drained later.
        for {set i 0} {$i < 20 + [Rand 40]} {incr i} {
            lappend ops [list set [expr {100000 + $i}] $i]
        }
    }
    if {[Rand 4] == 0} {
        lappend ops [list clear]
    }
    set order [expr {[Rand 3] == 0 ? $keys : [Shuffle $keys]}]
    foreach k $order {
        if {[Rand 4] == 0} {
            # A wrong value first, replaced in place.
            lappend ops [list set $k [expr {[dict get $target $k] + 1000}]]
        }
        lappend ops [list set $k [dict get $target $k]]
    }
    # Remove every key the target lacks (junk, the run), in a random order.
    set present [dict create]
    foreach op $ops {
        switch -- [lindex $op 0] {
            set { dict set present [lindex $op 1] 1 }
            clear { set present [dict create] }
        }
    }
    foreach k [Shuffle [dict keys $present]] {
        if {![dict exists $target $k]} {
            lappend ops [list remove $k]
        }
    }
    # Keys set twice above are already in order; a reorder may install any.
    if {[Rand 3] == 0 && [llength $keys] > 1} {
        lappend ops [list reorder [Shuffle $keys]]
    }
    return $ops
}

# The final order of OPS's keys (the model's rules), for a later reorder.
proc Order {ops} {
    set d [dict create]
    foreach op $ops {
        switch -- [lindex $op 0] {
            set { dict set d [lindex $op 1] 1 }
            remove { dict unset d [lindex $op 1] }
            clear { set d [dict create] }
            reorder {
                set d [dict create]
                foreach k [lindex $op 1] { dict set d $k 1 }
            }
        }
    }
    return [dict keys $d]
}

# The Botlish statements of map variable VAR's history OPS (VAR a
# MutableMap[KT, VT]).
proc Statements {var ops kt vt capacity} {
    if {$capacity ne ""} {
        set text "$var = std::mutable_map::with_capacity\[$kt, $vt\]($capacity)\n"
    } else {
        set text "$var = std::mutable_map::create\[$kt, $vt\]()\n"
    }
    foreach op $ops {
        switch -- [lindex $op 0] {
            set { append text "$var.set(key([lindex $op 1]), val([lindex $op 2]))\n" }
            remove { append text "[U r] = $var.remove(key([lindex $op 1])):\n    on std::mutable_map::KeyNotFound:\n        val(0)\n" }
            clear { append text "$var.clear()\n" }
            reorder {
                set c [U c]
                set o [U o]
                append text "$c = std::mutable_set::create\[$kt\]()\n"
                foreach k [lindex $op 1] {
                    append text "[U added] = $c.add(key($k))\n"
                }
                append text "$o = $var.validate_order($c):\n    on std::mutable_map::OrderMismatch:\n        $var.order()\n$var.reorder($o)\n"
            }
        }
    }
    return $text
}

proc Ids {kk n} {
    if {$kk eq "collide"} {
        return [lrange [Shuffle [lrange $::corpus 0 63]] 0 [expr {$n - 1}]]
    }
    set ids {}
    for {set i 0} {$i < $n} {incr i} {
        lappend ids [expr {$i * 3 + 1}]
    }
    return $ids
}

# {SOURCE PROGRAM}: a Botlish program and the model's description of it.
proc Program {kk vk mapsN} {
    set kt [KeyType $kk]
    set vt [ValueType $vk]
    set pool [Ids $kk [expr {6 + [Rand 20]}]]
    set base [dict create]
    foreach k [lrange [Shuffle $pool] 0 [expr {[Rand [llength $pool]]}]] {
        dict set base $k [expr {[Rand 40] + 1}]
    }
    set maps {}
    set text [Declarations $kk $vk]
    append text "obs = observations()\n"
    for {set m 0} {$m < $mapsN} {incr m} {
        set target $base
        switch -- [expr {$m == 0 ? 0 : [Rand 10]}] {
            7 {
                # Another value for one key (same length).
                if {[dict size $target]} {
                    set k [Pick [dict keys $target]]
                    dict set target $k [expr {[dict get $target $k] + 1}]
                }
            }
            8 {
                # One key fewer, or one more.
                if {[dict size $target] && [Rand 2]} {
                    dict unset target [Pick [dict keys $target]]
                } else {
                    foreach k $pool {
                        if {![dict exists $target $k]} {
                            dict set target $k 7
                            break
                        }
                    }
                }
            }
            9 {
                # One key replaced by another (same length).
                if {[dict size $target]} {
                    set gone [Pick [dict keys $target]]
                    foreach k $pool {
                        if {![dict exists $target $k]} {
                            set v [dict get $target $gone]
                            dict unset target $gone
                            dict set target $k $v
                            break
                        }
                    }
                }
            }
        }
        set ops [History $target $pool]
        set capacity [expr {[Rand 4] == 0 ? 50 + [Rand 2000] : ""}]
        append text [Statements m$m $ops $kt $vt $capacity]
        append text "f$m = freezeWith(m$m)\n"
        lappend maps [dict create capacity [expr {$capacity eq "" ? "null" : $capacity}] ops $ops]
    }
    # A derived map: a frozen one reordered by a validated candidate.
    set from [Rand $mapsN]
    set order [Shuffle [Order [dict get [lindex $maps $from] ops]]]
    set c [U c]
    set o [U o]
    append text "$c = std::mutable_set::create\[$kt\]()\n"
    foreach k $order {
        append text "[U added] = $c.add(key($k))\n"
    }
    append text "$o = f$from.validate_order($c):\n    on std::immutable_map::OrderMismatch:\n        f$from.order()\nf$mapsN = f$from.reordered($o)\n"
    lappend maps [dict create capacity null ops [concat [dict get [lindex $maps $from] ops] [list [list reorder $order]]]]
    set n [expr {$mapsN + 1}]
    # Observations (oracle.py's, in its order).
    for {set i 0} {$i < $n} {incr i} {
        append text "obs.observe(f$i)\n"
    }
    for {set i 0} {$i < $n} {incr i} {
        for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
            append text "obs.push(bit(f$i == f$j))\n"
            append text "obs.push(bit(hash(f$i) == hash(f$j)))\n"
        }
    }
    for {set i 0} {$i < $n} {incr i} {
        append text "obs.push(hash(f$i))\nobs.push(std::hashfix::keyed(f$i))\n"
    }
    append text "km = std::mutable_map::create\[std::immutable_map::ImmutableMap\[$kt, $vt\], int\]()\n"
    append text "ks = std::mutable_set::create\[std::immutable_map::ImmutableMap\[$kt, $vt\]\]()\n"
    for {set i 0} {$i < $n} {incr i} {
        append text "if not km.contains(f$i):\n    km.set(f$i, $i)\n[U added] = ks.add(f$i)\n"
    }
    append text "obs.push(km.length())\nobs.push(ks.length())\n"
    for {set i 0} {$i < $n} {incr i} {
        set first [U first]
        append text "$first = km.at(f$i):\n    on std::mutable_map::KeyNotFound:\n        -1\nobs.push($first)\n"
    }
    append text "loop x in obs:\n    x\n"
    set program [dict create keys $kk values $vk maps $maps]
    return [list $text $program]
}

# The model's description of PROGRAM as JSON.
proc Json {program} {
    set maps {}
    foreach m [dict get $program maps] {
        set ops {}
        foreach op [dict get $m ops] {
            switch -- [lindex $op 0] {
                set { lappend ops "\[\"set\", [lindex $op 1], [lindex $op 2]\]" }
                remove { lappend ops "\[\"remove\", [lindex $op 1]\]" }
                clear { lappend ops "\[\"clear\"\]" }
                reorder { lappend ops "\[\"reorder\", \[[join [lindex $op 1] {, }]\]\]" }
            }
        }
        lappend maps "{\"capacity\": [dict get $m capacity], \"ops\": \[[join $ops {, }]\]}"
    }
    return "{\"keys\": \"[dict get $program keys]\", \"values\": \"[dict get $program values]\", \"maps\": \[[join $maps {, }]\]}"
}

proc Expected {program} {
    set out [exec python3 -I $::oracle run {*}$::key << [Json $program]]
    return "\[[join [split [string trim $out] \n] {, }]\]"
}

# ---------------------------------------------------------------------------
# The run

set seedState [dict get $options -seed]
set uniq 0
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
        set kk [Pick [dict get $options -keys]]
        set vk [Pick [dict get $options -values]]
        lassign [Program $kk $vk [expr {2 + [Rand [dict get $options -maps]]}]] text program
        if {[dict get $options -dump]} {
            puts "---- program $p ($kk -> $vk)\n$text"
        }
        set expected [Expected $program]
        incr observations [llength [split $expected ,]]
        if {[catch {surface::compile $text fuzz.bot -warnings off} hir]} {
            puts "program $p ($kk -> $vk): does not compile: $hir"
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
                puts "program $p ($kk -> $vk) DISAGREES on $backend:\n  got      [lrange $outcome 0 1]\n  expected $expected"
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
                puts "program $p ($kk -> $vk) DISAGREES under GC stress:\n  got      [lrange $outcome 0 1]\n  expected $expected"
                incr failures
            }
        }
        incr programs
    }
    core::hashing::useTableHashKey ""
}
puts "value-identity fuzz: seed [dict get $options -seed]: $programs programs, $observations observations, $runs backend runs, $failures disagreements"
exit [expr {$failures > 0}]
