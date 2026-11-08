# bench.tcl -- what recording loop clause binding types costs the front end
# (LOOP-CLAUSE-BINDING-TYPE-CORRECTNESS-MILESTONE-1.md, section M).
#
#   tclsh9.0 audit/loop-binding-types/tools/bench.tcl ?-root DIR? ?-runs N?
#       ?-scale K? ?-markdown 1?
#
# Compiles each workload with the front end of the checkout DIR (default
# this one), each run in a fresh process (-strict 0, warnings off, no
# cache), and reports per workload the median front-end time of N runs, the
# HIR interchange text's size (what the front-end cache and the language
# server's worker store), the binding table's records (bindings with a
# recorded type), the semantic instances analyzed and the loop clause
# entries their snapshots hold, and the time of a front-end cache hit in a
# fresh process (median of N). The workloads: K generated functions of each
# loop kind (a list loop, three nested loops, a counted loop, a three-clause
# lockstep loop), K generic functions each called with four element types
# (4K semantic instances), and the repository's real iteration-heavy
# programs (the 2048 engine's and Icy Tower's suites, the collection and
# fold golden suites).

# The child: one compilation of PATH with FRONT's front end; MODE "build"
# (no cache) or "hit" (through the cache CACHE, which must hold it).
if {[lindex $argv 0] eq "-child"} {
    lassign $argv - front path mode cache
    cd $front
    set ::argv {}
    source [file join $front core core.tcl]
    source [file join $front surface surface.tcl]
    interp recursionlimit {} 100000
    set target [surface::modules::PlatformTarget [core::ReadFile $path]]
    set start [clock microseconds]
    set hir [surface::readProgramFile $path -strict 0 -warnings off -cache $cache -target $target]
    set us [expr {[clock microseconds] - $start}]
    set recorded 0
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding type] ne ""} {
            incr recorded
        }
    }
    set instances 0
    set snapshot 0
    if {[dict exists $hir semantic instances]} {
        dict for {id inst} [dict get $hir semantic instances] {
            incr instances
            if {![dict exists $inst snapshot bindings]} continue
            dict for {b t} [dict get $inst snapshot bindings] {
                if {[dict get $hir bindings $b kind] eq "param"} {
                    incr snapshot
                }
            }
        }
    }
    set bytes [string length [encoding convertto utf-8 [hir::interchange::encode $hir]]]
    puts [list RESULT $us $bytes $recorded $instances $snapshot]
    exit 0
}

set options [dict create -root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]] \
    -runs 5 -scale 100 -markdown 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

set front [file normalize [dict get $options -root]]
set runs [dict get $options -runs]
set k [dict get $options -scale]
set dir [file tempdir botlish-loop-binding-bench]

proc write {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    return $path
}

# The generated workloads, NAME -> PATH.
set workloads [dict create]
set listloops "import std::list\n\n"
set nested "import std::list\n\n"
set counted "import std::list\n\n"
set lockstep "import std::list\nimport std::str\n\n"
set generic "import std::list\n\nstruct Holder:\n    n: int\n\n"
set calls(list) {}
set calls(nested) {}
set calls(counted) {}
set calls(lockstep) {}
set calls(generic) {}
for {set i 0} {$i < $k} {incr i} {
    append listloops "fn f$i\(xs: List\[int\]) -> List\[int\]:\n    loop x in xs:\n        x + $i\n\n"
    append calls(list) "a$i = f$i\(\[1, 2, 3\])\n"
    append nested "fn f$i\(rows: List\[List\[int\]\]) -> List\[List\[List\[int\]\]\]:\n    loop row in rows:\n        loop cell in row:\n            loop c from 0 to cell:\n                c + $i\n\n"
    append calls(nested) "a$i = f$i\(\[\[1, 2\], \[3\]\])\n"
    append counted "fn f$i\(n: int) -> List\[int\]:\n    loop c from 0 to n:\n        c * $i\n\n"
    append calls(counted) "a$i = f$i\(3)\n"
    append lockstep "fn f$i\(xs: List\[int\]) -> List\[int\]:\n    words = loop v in xs:\n        \"w\"\n    loop x in xs and w in words and j from 0 to std::list::length(xs):\n        x + j + std::str::length(w) + $i\n\n"
    append calls(lockstep) "a$i = f$i\(\[1, 2\])\n"
    append generic "fn g$i\(xs):\n    loop x in xs:\n        x\n\n"
    append calls(generic) "a$i = g$i\(\[1\])\nb$i = g$i\(\[\"s\"\])\nc$i = g$i\(\[\[1\]\])\nd$i = g$i\(\[Holder {n: $i}\])\n"
}
dict set workloads "list loops ($k)" [write [file join $dir listloops.bot] "$listloops$calls(list)0\n"]
dict set workloads "nested loops ($k x 3)" [write [file join $dir nested.bot] "$nested$calls(nested)0\n"]
dict set workloads "counted loops ($k)" [write [file join $dir counted.bot] "$counted$calls(counted)0\n"]
dict set workloads "lockstep loops ($k x 3 clauses)" [write [file join $dir lockstep.bot] "$lockstep$calls(lockstep)0\n"]
dict set workloads "generic loops ($k x 4 instances)" [write [file join $dir generic.bot] "$generic$calls(generic)0\n"]
foreach {name path} {
    "2048 engine suite" examples/games/2048/golden.bot
    "Icy Tower suite" examples/games/icy-tower/golden.bot
    "collection-iteration.bot" tests/golden/collection-iteration.bot
    "fold-loops.bot" tests/golden/fold-loops.bot
    "mutable-vector.bot" tests/golden/mutable-vector.bot
} {
    if {[file exists [file join $front $path]]} {
        dict set workloads $name [file join $front $path]
    }
}

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

proc child {front path mode cache} {
    set out [exec [info nameofexecutable] [info script] -child $front $path $mode $cache 2>@stderr]
    foreach line [split $out \n] {
        if {[lindex $line 0] eq "RESULT"} {
            return [lrange $line 1 end]
        }
    }
    error "no result for $path: $out"
}

set env(LANG) C.utf8
set env(LC_ALL) C.utf8
set rows {}
try {
    dict for {name path} $workloads {
        set times {}
        for {set r 0} {$r < $runs} {incr r} {
            lassign [child $front $path build ""] us bytes recorded instances snapshot
            lappend times $us
        }
        set cache [file join $dir cache-[file rootname [file tail $path]]]
        file delete -force $cache
        child $front $path build $cache
        set hits {}
        for {set r 0} {$r < $runs} {incr r} {
            lappend hits [lindex [child $front $path hit $cache] 0]
        }
        lappend rows [list $name [expr {[median $times] / 1000.0}] $bytes $recorded $instances $snapshot \
            [expr {[median $hits] / 1000.0}]]
        puts stderr "measured $name"
    }
} finally {
    file delete -force $dir
}
if {[dict get $options -markdown]} {
    puts "| workload | front end (ms) | interchange (bytes) | recorded bindings | instances | snapshot loop entries | cache hit (ms) |"
    puts "|---|---:|---:|---:|---:|---:|---:|"
    foreach row $rows {
        lassign $row name ms bytes recorded instances snapshot hit
        puts [format "| %s | %.0f | %d | %d | %d | %d | %.0f |" $name $ms $bytes $recorded $instances $snapshot $hit]
    }
} else {
    foreach row $rows {
        puts $row
    }
}
