# value-transfer.tcl -- the performance report of SENDABILITY-AND-VALUE-
# COPY-MILESTONE-1.md: what std::transfer::encode and decode cost, per
# workload, natively (cranelift) and on the Tcl compiler (compile).
#
#   tclsh9.0 bench/value-transfer.tcl ?-runs N? ?-backends LIST? ?-scale F?
#
# For every workload a program builds the value once and then encodes it
# (or decodes its bytes) K times in a fold whose result depends on every
# copy; the same program with K = 0 is the baseline. The cost of one
# operation is (time(K) - time(0)) / K: the value's construction and the
# process are the baseline's too. Natively the time is native::measure's
# best of N runs in one process (compilation excluded), and the allocations
# per operation native::allocationReport's difference of the two programs'
# counts; on the Tcl compiler the best of N runs of a unit compiled once
# (core::compiler::compileHir, then evalUnit). Throughput is the
# encoding's size over the time. Times are a shared container's: compare
# them with each other, never as absolutes.

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
set options [dict create -runs 3 -backends {cranelift compile} -scale 1.0]
foreach {k v} $argv {
    if {![dict exists $options $k]} {
        puts stderr "unknown option $k"
        exit 2
    }
    dict set options $k $v
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
cd $root
# (tcltest, which the helpers load, reads argv.)
set argv {}
set argc 0
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set prelude {import std::transfer
import std::abi::bytes
import std::byte
import std::str
import std::int
import std::list
import std::mutable_vector
import std::mutable_map
import std::mutable_set

fn size(data: std::abi::bytes::Bytes) -> int:
    std::abi::bytes::length(data).value

struct Message:
    id: int
    sender: str
    tags: List[str]
    payload: std::abi::bytes::Bytes

tree struct Node:
    label: str
    kids: List[Node]

fn tree(depth: int) -> Node:
    if depth == 0:
        return Node {label: "leaf", kids: []}
    Node {label: std::int::to_string(depth), kids: [tree(depth - 1), tree(depth - 1)]}
}

# NAME TYPE BUILD OBSERVE K-native K-tcl: the value (BUILD, an expression),
# what a decoded copy is observed by (an Int expression of `c`), and the
# operations per measurement on each kind of backend.
set workloads {
    int          int                 {42}                                                 {c}                                   200000 2000
    big-int      int                 {-123456789012345678901234567890123456789}           {c.mod(7)}                            100000 2000
    string-12    str                 {"héllo, wörld"}                                     {std::str::length(c)}                 200000 2000
    bytes-64     std::abi::bytes::Bytes {xs = loop i from 0 to 64:\n    std::byte::from_int(i)\nstd::abi::bytes::from_list(xs)} {size(c)} 100000 1000
    bytes-4k     std::abi::bytes::Bytes {xs = loop i from 0 to 4096:\n    std::byte::from_int(i.mod(256))\nstd::abi::bytes::from_list(xs)} {size(c)} 20000 200
    bytes-1m     std::abi::bytes::Bytes {xs = loop i from 0 to 1048576:\n    std::byte::from_int(i.mod(256))\nstd::abi::bytes::from_list(xs)} {size(c)} 100 2
    ints-1000    {List[int]}         {loop i from 0 to 1000:\n    i * 7919}               {std::list::length(c)}                2000 20
    strings-1000 {List[str]}         {loop i from 0 to 1000:\n    std::int::to_string(i)} {std::list::length(c)}                2000 20
    nested-100x10 {List[List[str]]}  {loop i from 0 to 100:\n    loop j from 0 to 10:\n        std::int::to_string(i * j)} {std::list::length(c)} 2000 20
    tree-d10     Node                {tree(10)}                                           {std::list::length(c.kids)}           500 5
    chain-10000  Node                {fold i from 0 to 10000 with intermediate acc Node {label: "x", kids: []}:\n    Node {label: "x", kids: [acc]}} {std::list::length(c.kids)} 50 2
    vector-1000  MutableVector[int]  {xs = loop i from 0 to 1000:\n    i\nstd::mutable_vector::from_list(xs)} {std::mutable_vector::length(c)} 2000 20
    map-1000     {std::mutable_map::MutableMap[str, int]} {fold i from 0 to 1000 with intermediate m std::mutable_map::create[str, int]():\n    m.set(std::int::to_string(i), i)\n    m} {std::mutable_map::length(c)} 200 3
    set-1000     std::mutable_set::MutableSet[int] {fold i from 0 to 1000 with intermediate s std::mutable_set::create[int]():\n    s.add(i)\n    s} {std::mutable_set::length(c)} 200 3
    message      Message             {xs = loop i from 0 to 256:\n    std::byte::from_int(i.mod(256))\nMessage {id: 7, sender: "worker-3", tags: ["urgent", "batch"], payload: std::abi::bytes::from_list(xs)}} {c.id} 50000 1000
    shared-100x1000 {List[List[int]]} {fold i from 0 to 100 with intermediate acc []:\n    acc.append(shared)} {std::list::length(c)} 50 1
}

# The source of workload W's program: encode (MODE encode) or decode it K
# times.
proc program {mode type build observe k} {
    global prelude
    set text "$prelude\nshared = loop i from 0 to 1000:\n    i\n"
    append text "fn build() -> $type:\n[indent "    " $build]\n"
    append text "value = build()\ndata = std::transfer::encode(value)\n"
    if {$mode eq "encode"} {
        append text "fold i from 0 to $k with intermediate acc 0:\n    acc + size(std::transfer::encode(value))\n"
    } elseif {$mode eq "decode"} {
        append text "fn copy(d: std::abi::bytes::Bytes) -> int:\n    c = std::transfer::decode\[$type\](d):\n"
        foreach e {TransferMalformed TransferVersion TransferTypeMismatch TransferInvalidValue TransferLimit} {
            append text "        on $e:\n            return -1\n"
        }
        append text "    $observe\n\nfold i from 0 to $k with intermediate acc 0:\n    acc + copy(data)\n"
    } else {
        append text "size(data)\n"
    }
    return $text
}

proc indent {pad text} {
    return [join [lmap line [split [string map {\\n \n} $text] \n] {string cat $pad $line}] \n]
}

proc hirOf {text} {
    return [surface::compile $text bench.bot -warnings off]
}

# The best time of RUNS runs of HIR on BACKEND, in microseconds.
proc bestTime {backend hir runs} {
    if {$backend eq "compile"} {
        # Compiled once; the first run also compiles the unit's Tcl
        # procedures to bytecode, which the best of the later ones leaves out.
        set unit [core::compiler::compileHir $hir]
        set best ""
        for {set r 0} {$r <= $runs} {incr r} {
            set t [lindex [time {core::compiler::evalUnit $unit}] 0]
            if {$best eq "" || $t < $best} { set best $t }
        }
        return $best
    }
    lassign [native::measure $hir $runs {*}[expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]] lower compile best collections value
    return $best
}

# {ALLOCATIONS BYTES PEAK}: HIR's allocation count, allocated bytes and peak
# live heap bytes, natively.
proc allocations {hir} {
    set report [native::allocationReport $hir summary]
    set total [dict get $report total]
    return [list [dict get $total allocations] [dict get $total allocatedBytes] [dict get $total peakLiveBytes]]
}

set runs [dict get $options -runs]
set scale [dict get $options -scale]
puts [format "%-16s %-17s %8s %12s %12s %10s %10s %18s %12s" workload backend bytes "encode us" "decode us" "enc MB/s" "dec MB/s" "dec allocs/bytes" "dec peak +B"]
foreach {name type build observe kNative kTcl} $workloads {
    set size ""
    foreach backend [dict get $options -backends] {
        set k [expr {max(1, int(($backend eq "compile" ? $kTcl : $kNative) * $scale))}]
        if {$size eq ""} {
            set size [string trim [core::value::show [core::compiler::evalHir [hirOf [program size $type $build $observe 0]]]]]
        }
        set row {}
        foreach mode {encode decode} {
            set t0 [bestTime $backend [hirOf [program $mode $type $build $observe 0]] $runs]
            set tk [bestTime $backend [hirOf [program $mode $type $build $observe $k]] $runs]
            dict set row $mode [expr {double($tk - $t0) / $k}]
        }
        set allocs -
        set peak -
        if {$backend ne "compile"} {
            lassign [allocations [hirOf [program decode $type $build $observe 0]]] a0 b0 p0
            lassign [allocations [hirOf [program decode $type $build $observe 1]]] a1 b1 p1
            set allocs "[expr {$a1 - $a0}]/[expr {$b1 - $b0}]"
            set peak [expr {$p1 - $p0}]
        }
        set enc [dict get $row encode]
        set dec [dict get $row decode]
        puts [format "%-16s %-17s %8s %12.2f %12.2f %10.1f %10.1f %18s %12s" $name $backend $size $enc $dec \
            [expr {$enc > 0 ? $size / $enc : 0}] [expr {$dec > 0 ? $size / $dec : 0}] $allocs $peak]
        flush stdout
    }
}
