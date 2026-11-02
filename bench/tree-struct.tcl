# tree-struct.tcl -- the performance report of tree structs and
# std::tree::walk (TREE-STRUCT-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/tree-struct.tcl ?-shapes LIST? ?-sizes LIST? ?-modes LIST?
#       ?-decls LIST? ?-runs R? ?-passes P? ?-out FILE? ?-allocations 0|1?
#
# One Botlish program per declaration -- `tree struct Node` (tree) and the
# same declaration as an ordinary recursive `struct Node` (plain, the
# closest pre-milestone representation: the very same values, compared,
# hashed and traversed by the host's recursion or by hand) -- compiled and
# lowered once; then one native (cranelift) run per shape, size and mode,
# argv MODE SHAPE N PASSES, the best of R runs in one process. Each row's
# per-node time is a difference of two runs, (T[1 + P] - T[1]) / (P N), so
# building the trees compared cancels:
#
#   build       a tree of N nodes built (the chain bottom-up through a
#               vector, the others by construction)
#   eq-equal    == of two equal trees built separately
#   eq-early    == of trees whose roots differ (per comparison, not node)
#   eq-late     == of trees that differ only at the last node compared
#   hash        the public hash
#   table-hash  the keyed table hash (a fixture module of a private copy of
#               the standard library, as the standard library's own hash
#               structures call it)
#   dfs, bfs    std::tree::walk in preorder / breadth-first order, per node
#               handed over (tree only)
#   manual-dfs  a hand-written preorder over an explicit vector stack: the
#               traversal a program could write before the milestone
#
# Shapes: chain (a unary chain N deep), balanced (a complete ternary tree of
# about N nodes), wide (a root with N - 1 leaf children).
#
# Rows (TSV) to stdout and -out:
#
#   decl shape n mode passes best-us per-node-ns checksum
#
# -allocations 1 adds, for every mode, the managed allocations and the peak
# live bytes of three passes against one (native::allocationReport), per
# node: rows MODE-allocations and MODE-peak.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set options [dict create -shapes {chain balanced wide} -sizes {1024 65536} \
    -modes {build eq-equal eq-early eq-late hash table-hash dfs bfs manual-dfs} -decls {tree plain} \
    -runs 3 -passes 5 -out "" -allocations 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "bench/tree-struct.tcl: unknown option $option" }
    dict set options $option $value
}

proc driver {decl} {
    return [string map [list @DECL@ [expr {$decl eq "tree" ? "tree struct" : "struct"}]] {import std::coroutine
import std::int
import std::list
import std::mutable_array
import std::mutable_vector
import std::tree
import std::hashfix

@DECL@ Node:
    value: int
    children: List[Node]

nomethod fn leaf(v: int) -> Node:
    Node {value: v, children: []}

nomethod fn arg(args: List[str], i: int) -> int:
    text = std::list::at(args, i):
        on IndexNotFound:
            return 0
    n = std::int::from_string(text):
        on InvalidIntegerText:
            return 0
    n

nomethod fn bit(b: bool) -> int:
    if b:
        return 1
    0

# A chain N deep: the leaf LAST under roots 1..N.
nomethod fn chain(n: int, last: int) -> Node:
    acc = std::mutable_vector::from_list([leaf(last)])
    loop i from 1 to n:
        below = acc.pop():
            on IndexNotFound:
                leaf(0)
        acc.push(Node {value: i, children: [below]})
    acc.at(0):
        on IndexNotFound:
            leaf(0)

# A complete ternary tree D levels deep, its last node in preorder LAST.
nomethod fn balanced(d: int, v: int, last: int, rightmost: bool) -> Node:
    if d == 0:
        if rightmost:
            return leaf(last)
        return leaf(v)
    Node {value: v, children: [balanced(d - 1, 3 * v + 1, last, false), balanced(d - 1, 3 * v + 2, last, false), balanced(d - 1, 3 * v + 3, last, rightmost)]}

# The depth of the smallest complete ternary tree of at least N nodes.
nomethod fn levels(n: int) -> int:
    acc = std::mutable_array::create(2, 1)
    found = loop d from 0 to 30:
        nodes = acc.at(1):
            on IndexNotFound:
                0
        if nodes >= n:
            break
        width = acc.at(0):
            on IndexNotFound:
                0
        acc.set(0, 3 * width):
            on IndexNotFound:
                unit
        acc.set(1, nodes + 3 * width):
            on IndexNotFound:
                unit
        d
    std::list::length(found)

# A root with N - 1 leaves, the last one LAST.
nomethod fn wide(n: int, last: int) -> Node:
    kids = loop i from 1 to n:
        if i == n - 1:
            leaf(last)
        else:
            leaf(i)
    Node {value: 0, children: kids}

nomethod fn shaped(shape: int, n: int, last: int) -> Node:
    if shape == 0:
        return chain(n, last)
    if shape == 1:
        return balanced(levels(n), 0, last, true)
    wide(n, last)

nomethod fn eq_passes(a: Node, b: Node, passes: int) -> int:
    hits = loop k from 0 to passes:
        if not (a == b):
            continue
        k
    passes + std::list::length(hits)

nomethod fn hash_passes(a: Node, passes: int) -> int:
    hs = loop k from 0 to passes:
        hash(a)
    std::list::length(hs)

nomethod fn table_passes(a: Node, passes: int) -> int:
    hs = loop k from 0 to passes:
        std::hashfix::keyed(a)
    std::list::length(hs)

nomethod fn build_passes(shape: int, n: int, passes: int) -> int:
    ts = loop k from 0 to passes:
        shaped(shape, n, k).value
    std::list::length(ts)

nomethod fn manual_dfs(root: Node) -> int:
    stack = std::mutable_vector::from_list([root])
    seen = std::mutable_array::create(1, 0)
    loop:
        if std::mutable_vector::empty?(stack):
            break
        node = stack.pop():
            on IndexNotFound:
                root
        c = seen.at(0):
            on IndexNotFound:
                0
        seen.set(0, c + 1):
            on IndexNotFound:
                unit
        kids = node.children
        loop i down from std::list::length(kids) - 1 through 0:
            kid = kids.at(i):
                on IndexNotFound:
                    node
            stack.push(kid)
    seen.at(0):
        on IndexNotFound:
            0

nomethod fn manual_passes(a: Node, passes: int) -> int:
    counts = loop k from 0 to passes:
        manual_dfs(a)
    std::list::length(counts)

@WALK@

nomethod fn run(mode: int, shape: int, n: int, passes: int) -> int:
    if mode == 0:
        return build_passes(shape, n, passes)
    a = shaped(shape, n, 7)
    if mode == 1:
        return eq_passes(a, shaped(shape, n, 7), passes)
    if mode == 2:
        return eq_passes(a, Node {value: 99, children: a.children}, passes)
    if mode == 3:
        return eq_passes(a, shaped(shape, n, 8), passes)
    if mode == 4:
        return hash_passes(a, passes)
    if mode == 5:
        return table_passes(a, passes)
    if mode == 8:
        return manual_passes(a, passes)
    walked(mode, a, passes)

args = argv():
    on InvalidArgumentEncoding:
        []
run(arg(args, 1), arg(args, 2), arg(args, 3), arg(args, 4))
}]
}

# The walk modes exist for the tree declaration only.
set walkTree {nomethod fn walk_count(root: Node, order: std::tree::Order) -> int:
    seen = std::mutable_array::create(1, 1)
    coroutine {step, first} = std::tree::walk(root, order)
    loop:
        if std::coroutine::done?(step):
            break
        node = step()
        c = seen.at(0):
            on IndexNotFound:
                0
        seen.set(0, c + 1):
            on IndexNotFound:
                unit
    seen.at(0):
        on IndexNotFound:
            0

nomethod fn walked(mode: int, a: Node, passes: int) -> int:
    order = if mode == 6:
        std::tree::Order::DepthFirst
    else:
        std::tree::Order::BreadthFirst
    counts = loop k from 0 to passes:
        walk_count(a, order)
    std::list::length(counts)
}
set walkPlain {nomethod fn walked(mode: int, a: Node, passes: int) -> int:
    0
}

set modes {build 0 eq-equal 1 eq-early 2 eq-late 3 hash 4 table-hash 5 dfs 6 bfs 7 manual-dfs 8}
set shapes {chain 0 balanced 1 wide 2}

# The fixture module that may call the private table hash, in a private copy
# of the standard library.
set library [file tempdir botlish-ts-bench]
foreach entry [glob -directory $::core::libraryDir *] {
    file copy $entry $library
}
set f [open [file join $library hashfix.bot] w]
puts -nonewline $f "import std::table_hash\n\nfn keyed(x: Hashable) -> int:\n    std::table_hash::of(x)\n"
close $f
set ::core::libraryDir $library

proc argvOf {args} {
    return [lmap a [linsert $args 0 bench] {encoding convertto utf-8 $a}]
}

# The best time (microseconds) and value of a native run with ARGS.
proc timed {text args} {
    core::process::withArgv [argvOf {*}$args] {
        set lines [native::Driver bench $text [dict get $::options -runs]]
    }
    set value [native::Outcome $lines]
    set best ""
    foreach n [lrange [lsearch -inline $lines {times *}] 1 end] {
        if {$best eq "" || $n < $best} { set best $n }
    }
    if {[lindex $value 0] ne "int"} {
        error "bench/tree-struct.tcl: a run ended with [core::formatValue $value]"
    }
    return [list [expr {$best / 1000.0}] [lindex $value 1]]
}

proc report {hir args} {
    core::process::withArgv [argvOf {*}$args] {
        set report [native::allocationReport $hir summary]
    }
    return [list [dict get $report total allocations] [dict get $report total peakLiveBytes]]
}

set out ""
if {[dict get $options -out] ne ""} {
    set out [open [dict get $options -out] w]
}
proc row {fields} {
    puts [join $fields \t]
    flush stdout
    if {$::out ne ""} {
        puts $::out [join $fields \t]
        flush $::out
    }
}

set passes [dict get $options -passes]
try {
    foreach decl [dict get $options -decls] {
        set source [string map [list @WALK@ [expr {$decl eq "tree" ? $walkTree : $walkPlain}]] [driver $decl]]
        set hir [surface::compile $source bench.bot -warnings off]
        set text [native::nir $hir]
        foreach shape [dict get $options -shapes] {
            foreach n [dict get $options -sizes] {
                foreach mode [dict get $options -modes] {
                    if {$decl ne "tree" && $mode in {dfs bfs}} continue
                    set m [dict get $modes $mode]
                    set s [dict get $shapes $shape]
                    lassign [timed $text $m $s $n 1] t1 sum
                    lassign [timed $text $m $s $n [expr {1 + $passes}]] t2
                    set units [expr {$mode eq "eq-early" ? $passes : $passes * $n}]
                    row [list $decl $shape $n $mode $passes [format %.1f $t1] [format %.2f [expr {($t2 - $t1) * 1000.0 / $units}]] $sum]
                    if {[dict get $options -allocations]} {
                        lassign [report $hir $m $s $n 1] a1 p1
                        lassign [report $hir $m $s $n 3] a3 p3
                        set per [expr {$mode eq "eq-early" ? 2 : 2 * $n}]
                        row [list $decl $shape $n $mode-allocations 2 [expr {$a3 - $a1}] [format %.4f [expr {($a3 - $a1) / double($per)}]] -]
                        row [list $decl $shape $n $mode-peak 1 $p1 [format %.1f [expr {$p1 / double($n)}]] -]
                    }
                }
            }
        }
    }
} finally {
    file delete -force $library
    if {$out ne ""} {
        close $out
    }
}
