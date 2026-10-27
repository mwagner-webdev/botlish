#!/usr/bin/env tclsh9.0
# proofs.tcl -- the relational proof of reorder against an independent
# model and against the programs' own runs (PROVEN-COLLECTION-REORDERING.md,
# "The proof fuzzer").
#
#   tclsh9.0 audit/collection-reorder/tools/proofs.tcl ?-n N? ?-seed S?
#       ?-stmts N? ?-depth N? ?-run 0|1? ?-backend B? ?-dump 1?
#
# Each program is one function body of random statements over two maps (m1,
# m2: place parameters), an order parameter (p1) and the locals it binds:
# orders taken (`o = m.order()`), validated (`o = m.validate_order(c):`
# with a handler that returns, falls back to an order, to a candidate, to a
# new set, or changes the map first), copied, built by a helper, chosen by
# an `if`; map copies; boxes (`Box {m: ..., o: ...}`) and their copies;
# membership changes (set, remove, clear, add, a place call over a map or a
# box); reads (length, contains, a value call, a loop); `if` statements,
# early returns and loops; and the sites -- `m.reorder(o)` of a map or box
# field, `o.reorder(o2)` of a set.
#
# Three verdicts per site:
#
#   compiler   whether the compiler reports REORDER-NOT-PROVEN there
#   model      proof_model.py's, from the generator's own statement tree and
#              the documented rules (never the HIR): the two must agree
#              exactly, site by site
#   runs       with -run 1 (the default), the program again with a
#              membership assertion before every site and the rejected
#              sites' reorders left out, run (-backend, default compile)
#              under twelve inputs (both Booleans, three List lengths): a
#              site the compiler admits must never reach its reorder with
#              an order whose members differ from the collection's
#              (UNSOUND)
#
# Every membership change in the programs really changes the members (new
# keys come from a counter), so the runs observe what the proof must rule
# out. Exit status 1 on any disagreement or unsound site.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -stmts 14 -depth 2 -run 1 -backend compile -dump 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "proofs.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
set ::model [file join $root audit collection-reorder tools proof_model.py]

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {items} {
    return [lindex $items [Rand [llength $items]]]
}

proc Name {prefix} {
    return $prefix[incr ::nameCounter]
}

# ---------------------------------------------------------------------------
# Generation. SCOPE is a dict: maps (map places: m1, a local copy, a box's
# field wN.m), orders (order places), boxes. A statement is {LINES AST
# SCOPE'}: its source lines (unindented), its model statement, the scope
# after it.

proc Indent {lines} {
    return [lmap l $lines {string cat "    " $l}]
}

proc Site {} {
    return [incr ::siteCounter]
}

# An order-valued expression: {TEXT AST}.
proc OrderExpr {scope} {
    if {[Rand 2] == 0} {
        set x [Pick [dict get $scope maps]]
        return [list "$x.order()" [dict create k order src $x]]
    }
    set o [Pick [dict get $scope orders]]
    return [list $o [dict create k var v $o]]
}

proc Statement {scope depth} {
    set maps [dict get $scope maps]
    set orders [dict get $scope orders]
    set boxes [dict get $scope boxes]
    set x [Pick $maps]
    set o [Pick $orders]
    set r [Rand 100]
    if {$r < 12} {
        set d [Name o]
        dict lappend scope orders $d
        dict set scope origin $d $x
        return [list [list "$d = $x.order()"] [dict create k order dst $d src $x] $scope]
    }
    if {$r < 22} {
        set d [Name o]
        dict lappend scope orders $d
        switch -- [Rand 5] {
            0 { set h [list "return unit"]; set hast [dict create k return] }
            1 { set h [list "$x.order()"]; set hast [dict create k expr e [dict create k order src $x]] }
            2 {
                set c [Pick $orders]
                set h [list $c]
                set hast [dict create k expr e [dict create k var v $c]]
            }
            3 { set h [list "std::mutable_set::create\[int\]()"]; set hast [dict create k expr e [dict create k new]] }
            4 {
                set h [list "touch($x, c)" "$x.order()"]
                set hast [dict create k kills place $x e [dict create k order src $x]]
            }
        }
        dict set scope origin $d $x
        set lines [concat [list "$d = $x.validate_order($o):" "    on std::mutable_map::OrderMismatch:"] [Indent [Indent $h]]]
        return [list $lines [dict create k validate dst $d map $x cand $o h $hast] $scope]
    }
    if {$r < 28} {
        set d [Name o]
        dict lappend scope orders $d
        if {[dict exists $scope origin $o]} {
            dict set scope origin $d [dict get $scope origin $o]
        }
        return [list [list "$d = $o"] [dict create k copyo dst $d src $o] $scope]
    }
    if {$r < 32} {
        set d [Name mc]
        dict lappend scope maps $d
        return [list [list "$d = $x"] [dict create k copym dst $d src $x] $scope]
    }
    if {$r < 36} {
        set d [Name w]
        dict lappend scope boxes $d
        dict lappend scope maps $d.m
        dict lappend scope orders $d.o
        return [list [list "$d = Box {m: $x, o: $o}"] [dict create k box dst $d m $x o $o] $scope]
    }
    if {$r < 38 && $boxes ne {}} {
        set src [Pick $boxes]
        set d [Name w]
        dict lappend scope boxes $d
        dict lappend scope maps $d.m
        dict lappend scope orders $d.o
        return [list [list "$d = $src"] [dict create k copyw dst $d src $src] $scope]
    }
    if {$r < 48} {
        # A membership change of a map.
        set n [Name r]
        switch -- [Rand 4] {
            0 { set lines [list "$x.set(fresh(c), 7)"] }
            1 { set lines [list "$n = $x.remove(1):" "    on std::mutable_map::KeyNotFound:" "        0"] }
            2 { set lines [list "$x.clear()"] }
            3 { set lines [list "touch($x, c)"] }
        }
        return [list $lines [dict create k kill place $x] $scope]
    }
    if {$r < 55} {
        # A membership change of an order.
        set n [Name r]
        switch -- [Rand 3] {
            0 { set lines [list "$o.add(fresh(c))"] }
            1 { set lines [list "$n = $o.remove(1)"] }
            2 { set lines [list "$o.clear()"] }
        }
        return [list $lines [dict create k kill place $o] $scope]
    }
    if {$r < 57 && $boxes ne {}} {
        set w [Pick $boxes]
        return [list [list "bump($w, c)"] [dict create k kill place $w] $scope]
    }
    if {$r < 63} {
        set n [Name r]
        switch -- [Rand 4] {
            0 { set lines [list "$n = $x.length()"] }
            1 { set lines [list "$n = $o.contains(2)"] }
            2 { set lines [list "$n = look($x)"] }
            3 { set lines [list "$n = loop e in $x:" "    e.key"] }
        }
        return [list $lines [dict create k read] $scope]
    }
    if {$r < 78} {
        # (Mostly an order taken from this map: the sites a proof can admit.)
        set mine [lmap q $orders {if {[dict getdef $scope origin $q ""] ne $x} continue; set q}]
        if {$mine ne {} && [Rand 3] > 0} {
            set o [Pick $mine]
        }
        set site [Site]
        return [list [list "out.push($site * 10 + same($x, $o))" "$x.reorder($o)  # site $site"] \
            [dict create k reorder site $site place $x order $o] $scope]
    }
    if {$r < 82} {
        set site [Site]
        set o2 [Pick $orders]
        return [list [list "out.push($site * 10 + same_set($o, $o2))" "$o.reorder($o2)  # site $site"] \
            [dict create k reorder site $site place $o order $o2] $scope]
    }
    if {$r < 85} {
        set d [Name o]
        dict lappend scope orders $d
        return [list [list "$d = helper($x)"] [dict create k helper dst $d] $scope]
    }
    if {$r < 89} {
        set d [Name o]
        lassign [OrderExpr $scope] t1 a1
        lassign [OrderExpr $scope] t2 a2
        dict lappend scope orders $d
        return [list [list "$d = if b2:" "    $t1" "else:" "    $t2"] [dict create k ifv dst $d then $a1 else $a2] $scope]
    }
    if {$depth > 0 && $r < 94} {
        lassign [Block $scope [expr {$depth - 1}] [expr {1 + [Rand 4]}]] l1 a1
        lassign [Block $scope [expr {$depth - 1}] [expr {1 + [Rand 4]}]] l2 a2
        return [list [concat [list "if b1:"] [Indent $l1] [list "else:"] [Indent $l2]] [dict create k if then $a1 else $a2] $scope]
    }
    if {$depth > 0 && $r < 96} {
        lassign [Block $scope [expr {$depth - 1}] [expr {1 + [Rand 3]}]] l1 a1
        return [list [concat [list "if b2:"] [Indent $l1] [list "    return unit"]] [dict create k early body $a1] $scope]
    }
    if {$depth > 0} {
        lassign [Block $scope [expr {$depth - 1}] [expr {1 + [Rand 4]}]] l1 a1
        return [list [concat [list "loop x in xs:"] [Indent $l1] [list "    unit"]] [dict create k loop body $a1] $scope]
    }
    set n [Name r]
    return [list [list "$n = $x.length()"] [dict create k read] $scope]
}

# A block of COUNT statements: {LINES ASTS}.
proc Block {scope depth count} {
    set lines {}
    set asts {}
    for {set i 0} {$i < $count} {incr i} {
        lassign [Statement $scope $depth] l a scope
        lappend lines {*}$l
        lappend asts $a
    }
    return [list $lines $asts]
}

set ::prelude {import std::list
import std::mutable_map
import std::mutable_set
import std::mutable_vector
import std::mutable_array

struct Box:
    m: std::mutable_map::MutableMap[int, int]
    o: std::mutable_set::MutableSet[int]

fn fresh(place c: MutableArray[int]) -> int:
    n = c.at(0):
        on IndexNotFound:
            0
    c.set(0, n + 1):
        on IndexNotFound:
            unit
    100 + n

fn touch(place m: std::mutable_map::MutableMap[int, int], place c: MutableArray[int]) -> unit:
    m.set(fresh(c), 1)

fn bump(place w: Box, place c: MutableArray[int]) -> unit:
    w.m.set(fresh(c), 1)
    w.o.add(fresh(c))
    unit

fn look(m: std::mutable_map::MutableMap[int, int]) -> int:
    m.length()

fn helper(m: std::mutable_map::MutableMap[int, int]) -> std::mutable_set::MutableSet[int]:
    m.order()

fn same(m: std::mutable_map::MutableMap[int, int], o: std::mutable_set::MutableSet[int]) -> int:
    if m.length() != o.length():
        return 0
    bad = loop x in o:
        if m.contains(x):
            continue
        x
    if std::list::length(bad) == 0:
        return 1
    0

fn same_set(s: std::mutable_set::MutableSet[int], o: std::mutable_set::MutableSet[int]) -> int:
    if s.length() != o.length():
        return 0
    bad = loop x in o:
        if s.contains(x):
            continue
        x
    if std::list::length(bad) == 0:
        return 1
    0

fn map_of(xs: List[int]) -> std::mutable_map::MutableMap[int, int]:
    m = std::mutable_map::create[int, int]()
    loop x in xs:
        m.set(x, x)
    m

fn set_of(xs: List[int]) -> std::mutable_set::MutableSet[int]:
    s = std::mutable_set::create[int]()
    loop x in xs:
        s.add(x)
    s

}

set ::driver {
out = std::mutable_vector::from_list([0])
loop b1 in [true, false]:
    loop b2 in [true, false]:
        loop xs in [[], [1], [1, 2]]:
            m1 = map_of([1, 2, 3])
            m2 = map_of([1, 2, 3])
            p1 = set_of([3, 2, 1])
            c = std::mutable_array::create(1, 0)
            f(m1, m2, p1, xs, b1, b2, out, c)
result = loop x in out:
    x
result
}

# The program of body LINES: the prelude, f, the driver.
proc Source {lines} {
    return "$::prelude[join [concat [list "fn f(place m1: std::mutable_map::MutableMap\[int, int\], place m2: std::mutable_map::MutableMap\[int, int\], p1: std::mutable_set::MutableSet\[int\], xs: List\[int\], b1: bool, b2: bool, place out: MutableVector\[int\], place c: MutableArray\[int\]) -> unit:"] [Indent $lines] [list "    unit"]] \n]\n$::driver"
}

# JSON of model node NODE (a dict with `k`): a statement, a handler or an
# expression. Which fields hold statement lists, which nodes, is the
# generator's: the encoder follows it, never a guess.
proc Json {node} {
    set parts {}
    dict for {key v} $node {
        set kind [dict get $node k]
        if {$key in {body} || ($kind eq "if" && $key in {then else})} {
            set text "\[[join [lmap item $v {Json $item}] {, }]\]"
        } elseif {$key in {h e} || ($kind eq "ifv" && $key in {then else})} {
            set text [Json $v]
        } elseif {$key eq "site"} {
            set text $v
        } else {
            set text "\"$v\""
        }
        lappend parts "\"$key\": $text"
    }
    return "{[join $parts {, }]}"
}

# The statement list ASTS as JSON (an array of statements).
proc ProgramJson {asts} {
    return "\[[join [lmap a $asts {Json $a}] {, }]\]"
}

# The site lines of SOURCE: site -> line.
proc SiteLines {source} {
    set result [dict create]
    set n 0
    foreach line [split $source \n] {
        incr n
        if {[regexp {# site ([0-9]+)$} $line -> site]} {
            dict set result $site $n
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# The run

set seedState [dict get $options -seed]
set disagreements 0
set unsound 0
set failures 0
set sites 0
set admitted 0
set observed 0
set start [clock milliseconds]
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set ::nameCounter 0
    set ::siteCounter 0
    set scope [dict create maps {m1 m2} orders {p1} boxes {} origin {}]
    lassign [Block $scope [dict get $options -depth] [dict get $options -stmts]] lines asts
    set source [Source $lines]
    set siteLines [SiteLines $source]
    set lineSites [dict create]
    dict for {site line} $siteLines {
        dict set lineSites $line $site
    }
    incr sites [dict size $siteLines]
    if {[dict get $options -dump]} {
        puts "---- program $p\n$source"
    }
    # The compiler's verdicts.
    set rejected {}
    set others {}
    if {[catch {surface::compile $source -warnings off} hir opts]} {
        foreach d [dict getdef $opts -diagnostics [list [dict create errorcode [dict get $opts -errorcode] message $hir]]] {
            set kind [lindex [dict get $d errorcode] end]
            set line ""
            regexp {^[^:]*:([0-9]+):} [dict get $d message] -> line
            if {$kind eq "REORDER-NOT-PROVEN" && [dict exists $lineSites $line]} {
                lappend rejected [dict get $lineSites $line]
            } else {
                lappend others "$kind: [string range [dict get $d message] 0 200]"
            }
        }
    }
    if {$others ne {}} {
        incr failures
        puts "program $p (seed [dict get $options -seed]): does not compile but for unproven reorders: [lindex $others 0]"
        set path [file join [file tempdir] proofs-$p.bot]
        set f [open $path w]
        puts -nonewline $f $source
        close $f
        puts "  program written to $path"
        continue
    }
    set rejected [lsort -integer -unique $rejected]
    # The model's.
    set predicted [lsort -integer -unique [string map {"\[" "" "\]" "" "," " "} [exec python3 -I $::model << [ProgramJson $asts]]]]
    if {$predicted ne $rejected} {
        incr disagreements
        puts "program $p (seed [dict get $options -seed]): the compiler rejects sites {$rejected}, the model {$predicted}"
        set path [file join [file tempdir] proofs-$p.bot]
        set f [open $path w]
        puts -nonewline $f $source
        close $f
        puts "  program written to $path"
    }
    incr admitted [expr {[dict size $siteLines] - [llength $rejected]}]
    if {![dict get $options -run]} continue
    # The runs: the rejected sites' reorders left out, every assertion kept.
    set runLines {}
    foreach line [split $source \n] {
        if {[regexp {^(\s*)\S.*# site ([0-9]+)$} $line -> indent site] && $site in $rejected} {
            lappend runLines "${indent}unit"
        } else {
            lappend runLines $line
        }
    }
    set runSource [join $runLines \n]
    if {[catch {surface::compile $runSource -warnings off} runHir opts]} {
        incr failures
        puts "program $p: the run variant does not compile: [string range $runHir 0 300]"
        continue
    }
    set outcome [outcomeUnderHir [dict get $options -backend] $runHir]
    if {[lindex $outcome 0] ne "value"} {
        incr failures
        puts "program $p: the run variant fails: [lrange $outcome 0 2]"
        continue
    }
    foreach v [lrange [string map {"\[" "" "\]" "" "," " "} [lindex $outcome 1]] 1 end] {
        incr observed
        set site [expr {$v / 10}]
        if {$v % 10 == 0 && $site ni $rejected} {
            incr unsound
            puts "program $p (seed [dict get $options -seed]): UNSOUND: site $site was admitted, and a run reached it with an order whose members differ"
            set path [file join [file tempdir] proofs-unsound-$p.bot]
            set f [open $path w]
            puts -nonewline $f $source
            close $f
            puts "  program written to $path"
            break
        }
    }
}
set seconds [expr {([clock milliseconds] - $start) / 1000.0}]
puts [format "%d programs, %d sites (%d admitted), %d observations, %d disagreements, %d unsound, %d failures (%.1f s)" \
    [dict get $options -n] $sites $admitted $observed $disagreements $unsound $failures $seconds]
exit [expr {$disagreements + $unsound + $failures > 0}]
