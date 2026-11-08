# census.tcl -- every mutation of a collection place in the repository's
# Botlish programs, classified by the construct that owns the place's root
# binding (CONSTRUCT-BINDING-MUTATION-CENSUS-1.md, section 11).
#
#   tclsh9.0 audit/construct-binding-mutation/tools/census.tcl \
#       ?-out FILE.tsv? ?-shard I/N? ?-programs FILES? ?-root DIR?
#
# A *mutation* is what hir::mutvec::verify judges (hir/mutvec.tcl): a call of
# a native whose receiver role is `place` (its receiver path is the
# destination) or an argument given to a function's place parameter (that
# argument's path is the destination). Nothing is identified by a function's
# name: the registry's roles and the callee's `places` decide.
#
# Each program is compiled by the ordinary front end; the census reads the
# checked HIR the program had right before the loop protocol's elaboration
# (hir::iteration::Elaborate) -- the program as written, every check run --
# which this process records by wrapping that one procedure. The wrapper is
# this tool's own: it changes no compilation, and nothing else loads it.
#
# For every mutation site it records
#
#   category   the root binding's owner: loop-element (with the iterated
#              kind), lockstep-element, count, fold-intermediate,
#              handler-payload, destructured-field (statement or handler
#              pattern), context-parameter, place-parameter, a local of a
#              loop body, of a handler body, of a function, of the top
#              level
#   dead       1 when the mutated path's state is never read again: the
#              mutation's receiver (or place argument) is its path's last
#              use (hir::mutvec::NoLaterUse, the analysis the copy
#              convention's moves rely on; a binding of a loop's iteration
#              is done with at the iteration's end)
#   used       1 when the mutating call's own value is used (pop's element,
#              a place function's result), i.e. it is no discarded statement
#   result     1 when some reference to the root is a result of the root's
#              construct: the value a loop iteration collects or a fold
#              carries, a handler's value, a function's result
#   reads      references to the root that are no mutation's destination
#   exit       for a fold intermediate: 1 when a `continue` or bare `break`
#              of that fold can run after the mutation in the same
#              iteration, carrying the unmutated intermediate (FoldExitAfter)
#
# Output: one TSV row per distinct site (by source location; a site in a
# module several programs load is listed once), then a summary on stdout.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set root $checkout
set out ""
set shard 1/1
set programs {}
foreach {option value} [expr {[info exists ::cbmLibrary] ? {} : $argv}] {
    switch -- $option {
        -out { set out $value }
        -shard { set shard $value }
        -programs { set programs $value }
        -root { set root [file normalize $value] }
        default { error "unknown option $option" }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
unset -nocomplain env(BOTLISH_HIR_CACHE)
source [file join $checkout examples stdlib corpus.tcl]
interp recursionlimit {} 1000000

namespace eval cbm {
    variable checked ""
    variable sites [dict create]
}

# The wrapper: the checked HIR, recorded before the loop protocol's
# elaboration rewrites MutableMap and MutableSet loops.
# (Renamed within its own namespace, whose procedures it calls unqualified.)
rename ::hir::iteration::Elaborate ::hir::iteration::CensusElaborate
proc ::hir::iteration::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    set ::cbm::checked $hir
    CensusElaborate hir
}

# The programs of the census: every .bot file the repository tracks, minus
# the generated C bindings (which the generator writes, and which are
# modules of extern declarations) and this census's own corpus, plus a
# one-line loader per standard library module.
proc cbm::Programs {root} {
    set files [split [string trim [exec git -C $root ls-files *.bot]] \n]
    set result {}
    foreach f $files {
        if {[string match generated/* $f] || [string match tools/c-bindgen/fixture/expected/* $f]} continue
        # (This census's own reproducers are its subject, not usage.)
        if {[string match audit/construct-binding-mutation/* $f]} continue
        if {[string match stdlib/* $f]} continue
        lappend result $f
    }
    foreach f $files {
        if {![string match stdlib/* $f]} continue
        lappend result loader:$f
    }
    return $result
}

proc cbm::Location {hir e} {
    set origin [dict get $hir exprs $e origin]
    if {[lindex $origin 0] ne "file"} {
        return ""
    }
    set path [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
    variable rootDir
    if {[string first $rootDir/ $path] == 0} {
        set path [string range $path [string length $rootDir/] end]
    } elseif {[string first $::core::libraryDir/ $path] == 0} {
        set path stdlib/[string range $path [string length $::core::libraryDir/] end]
    }
    set fields [lrange $origin 2 end]
    return "$path:[dict get $fields line]:[dict get $fields column]"
}

# The construct that declares binding B, as a category word.
proc cbm::Category {hir parent b} {
    set binding [dict get $hir bindings $b]
    set kind [dict get $binding kind]
    set scope [dict get $binding scope]
    set owner [dict get $hir scopes $scope owner]
    if {$kind eq "param"} {
        if {$owner eq "" || ![dict exists $hir exprs $owner]} {
            return param-unknown
        }
        set node [dict get $hir exprs $owner]
        if {[dict getdef $node foldBinding ""] eq $b} {
            return fold-intermediate
        }
        switch -- [dict get $node kind] {
            block {
                if {[hir::mutvec::IsPlaceParam $hir $b]} {
                    return place-parameter
                }
                return value-parameter
            }
            listloop {
                return loop-element:[IterKind $hir [dict get $node iterable]]
            }
            countloop {
                return count
            }
            lockloop {
                foreach d [dict get $node domains] {
                    if {[dict get $d binding] eq $b} {
                        if {[dict get $d kind] eq "list"} {
                            return lockstep-element:[IterKind $hir [dict get $d iterable]]
                        }
                        return lockstep-count
                    }
                }
                return lockstep-unknown
            }
            handle {
                if {[string match destructure#* [dict get $binding name]]} {
                    return handler-pattern-temp
                }
                return handler-payload
            }
        }
        return param-of-[dict get $node kind]
    }
    if {$kind ne "local"} {
        return $kind
    }
    if {[hir::mutvec::IsContextParam $hir $b]} {
        return context-parameter
    }
    set by [dict get $binding declaredBy]
    if {$by ne "" && [dict exists $hir exprs $by]} {
        set value [dict get $hir exprs $by value]
        set v [dict get $hir exprs $value]
        if {[dict get $v kind] eq "project"} {
            set r [dict get $hir exprs [dict get $v receiver]]
            if {[dict get $r kind] eq "ref" && [dict get $r binding] ne ""
                    && [string match destructure#* [dict get $hir bindings [dict get $r binding] name]]} {
                set temp [dict get $hir bindings [dict get $r binding]]
                if {[dict get $temp kind] eq "param"} {
                    return destructured-field:handler
                }
                return destructured-field:statement
            }
        }
    }
    # The nearest enclosing construct of the binding statement.
    set x $by
    for {set i 0} {$i < 4096 && $x ne "" && [dict exists $parent $x]} {incr i} {
        set x [lindex [dict get $parent $x] 0]
        if {$x eq ""} break
        switch -- [dict get $hir exprs $x kind] {
            listloop - countloop - lockloop - loop {
                if {[dict exists $hir exprs $x foldBinding] && [dict get $hir exprs $x foldBinding] ne ""} {
                    return local:fold-body
                }
                return local:loop-body
            }
            handle {
                # (Only a handler body's statements, not the handled call.)
                return local:handler-body
            }
            block {
                return local:function
            }
        }
    }
    return local:top-level
}

proc cbm::IterKind {hir it} {
    set type [hir::typeOf $hir $it]
    while {[lindex $type 0] in {srefined refined}} {
        # (A refinement is knowledge about its base: List[T]{length: N}.)
        set type [lindex $type end]
    }
    switch -- [lindex $type 0] {
        list { return List }
        mutvec { return MutableVector }
        mutarray { return MutableArray }
        nstruct { return [lindex [split [lindex $type 1] :] end] }
    }
    return [lindex $type 0]
}

# 1 if expression E is the final statement of the body of the construct
# that owns binding B's scope (a loop iteration's collected or carried
# value, a handler's value, a function's result), through `if` branches.
proc cbm::IsConstructResult {hir parent e b} {
    set x $e
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} {
            return 0
        }
        lassign [dict get $parent $x] p role
        if {$p eq ""} {
            return [expr {$role eq "seq 1"}]
        }
        set kind [dict get $hir exprs $p kind]
        switch -- $kind {
            if {
                if {$role ne "seq 1"} { return 0 }
                set x $p
                continue
            }
            return { return 1 }
            block - listloop - countloop - lockloop - loop - handle {
                return [expr {$role eq "seq 1"}]
            }
            struct - project {
                # A struct literal holding it, or a field of it (the field
                # still carries the root's state), itself a result.
                set x $p
                continue
            }
            call {
                # A share or a List literal's element is still the value.
                if {[hir::affine::NativeName $hir $p] in {mutable_vector#share list}} {
                    set x $p
                    continue
                }
                return 0
            }
            default { return 0 }
        }
    }
    return 0
}

# For a mutation E of fold intermediate B (the parameter of loop L's
# iteration): 1 if a `continue` or bare `break` of L can run after E in
# the same iteration -- a statement after the one holding E, in any
# enclosing sequence up to L's body -- which carries the iteration's
# starting intermediate, not the mutated copy (FOLD-LOOPS-MILESTONE-1.md,
# rules 5 and 6).
proc cbm::FoldExitAfter {hir parent e b} {
    set loop [dict get $hir scopes [dict get $hir bindings $b scope] owner]
    set x $e
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} {
            return 0
        }
        set p [lindex [dict get $parent $x] 0]
        if {$p eq ""} {
            return 0
        }
        set sequence [hir::coroutines::SequenceOf $hir $p $x]
        if {$sequence ne ""} {
            set at [lsearch -exact $sequence $x]
            foreach s [lrange $sequence [expr {$at + 1}] end] {
                if {[ExitsTo $hir $s $loop]} {
                    return 1
                }
            }
        }
        if {$p eq $loop} {
            return 0
        }
        set x $p
    }
    return 0
}

# 1 if expression S holds a `continue` or `break` targeting loop L (not in
# a nested function).
proc cbm::ExitsTo {hir s loop} {
    set work [list $s]
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        set node [dict get $hir exprs $x]
        switch -- [dict get $node kind] {
            block { continue }
            break - continue {
                if {[dict get $node target] eq $loop} {
                    return 1
                }
            }
        }
        lappend work {*}[hir::children $hir $x]
    }
    return 0
}

proc cbm::Analyze {hir program} {
    variable sites
    # Every mutation destination.
    set dests {}
    set destRefs [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
        set places [hir::mutvec::PlaceIndices $hir $e]
        if {$places ne {}} {
            set callee [hir::signatures::Name $hir [lindex [dict get $node target] 1]]
            foreach index $places {
                set arg [lindex [dict get $node args] $index]
                if {$arg eq ""} continue
                lappend dests [list $e $arg place-argument:$callee]
            }
            continue
        }
        if {[hir::affine::ElementPlace $hir $e]} continue
        if {[hir::mutvec::OpKind $hir $e] ne "mutate"} continue
        set receiver [lindex [dict get $node args] 0]
        if {$receiver eq ""} continue
        lappend dests [list $e $receiver op:[hir::affine::NativeName $hir $e]]
    }
    if {$dests eq {}} {
        return
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    set ::hir::mutvec::convention [dict create uses [hir::mutvec::UseMap $hir $parent]]
    # The reachable references of every binding, once.
    set refsOf [dict create]
    dict for {x xn} [dict get $hir exprs] {
        if {[dict get $xn kind] ne "ref" || [dict get $xn binding] eq "" || ![dict get $xn reachable]} continue
        dict lappend refsOf [dict get $xn binding] $x
    }
    foreach d $dests {
        lassign $d e arg mechanism
        set r $arg
        while {[dict get $hir exprs $r kind] eq "project"} {
            set r [dict get $hir exprs $r receiver]
        }
        dict set destRefs $r 1
    }
    foreach d $dests {
        lassign $d e arg mechanism
        set path [hir::mutvec::Path $hir $arg]
        if {$path eq ""} continue
        set b [lindex $path 0]
        set at [Location $hir $arg]
        if {$at eq "" || [dict exists $sites $at]} {
            if {$at ne ""} {
                dict lappend sites $at programs $program
            }
            continue
        }
        set category [Category $hir $parent $b]
        set dead [hir::mutvec::NoLaterUse $hir $parent $arg $b]
        lassign [dict get $parent $e] p role
        set type [hir::typeOf $hir $e]
        set used [expr {$role ne "seq 0" && $type ni {unit never}}]
        set reads 0
        set result 0
        foreach x [dict getdef $refsOf $b {}] {
            if {![dict exists $destRefs $x]} {
                incr reads
            }
            if {[IsConstructResult $hir $parent $x $b]} {
                set result 1
            }
        }
        set exit 0
        if {$category eq "fold-intermediate"} {
            set exit [FoldExitAfter $hir $parent $e $b]
        }
        set name [hir::semantic::SourceName $hir $b]
        set text [hir::mutvec::PathText $hir $path]
        dict set sites $at [dict create category $category name $name path $text mechanism $mechanism \
            dead $dead used $used result $result reads $reads exit $exit programs [list $program]]
    }
}

set rootDir $root
set ::cbm::rootDir $root
if {[info exists ::cbmLibrary]} {
    # (test-census.tcl: the procedures only.)
    return
}
if {$programs eq {}} {
    set programs [cbm::Programs $root]
}
lassign [split $shard /] si sn
set compiled 0
set rejected {}
set n 0
foreach program $programs {
    incr n
    if {($n - 1) % $sn != $si - 1} continue
    set ::cbm::checked ""
    if {[string match loader:* $program]} {
        set module [file rootname [string range $program [string length loader:stdlib/] end]]
        set ns std::[string map {/ ::} $module]
        # (An architecture-specific module, P.ARCH.bot, is loaded as P.)
        regsub {\.(x86_64|aarch64)$} $ns {} ns
        set text "import $ns\n0\n"
        set code [catch {corpus::compile $text loader.bot -warnings off} hir options]
    } else {
        set code [catch {surface::readProgramFile [file join $root $program] -warnings off} hir options]
    }
    if {$code} {
        lappend rejected $program [dict getdef $options -errorcode ?]
        continue
    }
    incr compiled
    if {$::cbm::checked eq ""} continue
    if {[catch {cbm::Analyze $::cbm::checked $program} message]} {
        puts stderr "analysis failed for $program: $message"
    }
}

set rows {}
dict for {at site} $::cbm::sites {
    dict with site {
        lappend rows [join [list $at $category $name $path $mechanism $dead $used $result $reads $exit [llength [lsort -unique $programs]] [lindex [lsort $programs] 0]] \t]
    }
}
set header [join {site category root path mechanism dead used result reads exit programs first} \t]
if {$out ne ""} {
    set f [open $out w]
    puts $f $header
    foreach row [lsort $rows] {
        puts $f $row
    }
    close $f
}
puts "programs: [expr {($n + $sn - 1) / $sn}] in shard, compiled $compiled, rejected [expr {[llength $rejected] / 2}]"
foreach {p c} $rejected {
    puts "  rejected $p ($c)"
}
puts "sites: [llength $rows]"
