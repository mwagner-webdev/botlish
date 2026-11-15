# persist.tcl -- the suspension facts of hir/lifetime.tcl against the C
# backend's frame persistence (STORAGE-LIFETIME-FACTS-MILESTONE-1.md,
# "Differential comparison with C Persist").
#
#   tclsh9.0 audit/storage-lifetime/tools/persist.tcl ?-quiet 0|1? FILE.bot...
#
# For each FILE the C backend compiles (ccompile::program), and for each
# yielding function's frame its manifest lists (coroutine_frames: the C
# variables Persist made frame fields, `suspension_values`), compares them
# with the HIR facts of the same instance:
#
#   * every value the HIR analysis says must survive one of the function's
#     suspension points needs a persistent C representation: a parameter
#     (always a frame field: the frame is the calling convention), a
#     binding's own variable (v_NAME_N for binding bN), a fold
#     intermediate's (acc<k>), a counted loop's position and count binding
#     (its counter, i<k>). A required value
#     without one is a VIOLATION (C would lose it; or the analysis is
#     wrong) -- the tool exits 1;
#   * every persistent C variable no required value explains is EXTRA:
#     Persist's line-order approximation keeping a binding no path reads
#     after a resume (p18's x), or a lowering temporary of C's own (a join
#     j<k>, a constant loop bound hi<k>, a call result r<k>), which the
#     HIR has no binding for.
#
# A pending operand (a value evaluated before a suspending call and consumed
# after it) is held by a C temporary of a result (r<k>, n<k>): as many must
# be frame fields as one suspension point has pending operands. Prints one
# line per frame and a total.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -quiet 0]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {[dict exists $options $a]} {
        dict set options $a [lindex $argv [incr i]]
    } else {
        lappend files $a
    }
}
set argv {}
source [file join $root surface surface.tcl]
source [file join $root ccompile ccompile.tcl]
source [file join $root lsp json.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

# The plain Tcl value of a typed JSON value (lsp/json.tcl's): objects as
# dicts, arrays as lists, scalars as their text.
proc Plain {value} {
    lassign $value type payload
    switch -- $type {
        obj {
            set result [dict create]
            foreach {k v} $payload {
                dict set result $k [Plain $v]
            }
            return $result
        }
        arr { return [lmap v $payload {Plain $v}] }
        default { return $payload }
    }
}

# The C names that represent HIR variable V of unit U: {kind NAMES} where
# kind is param (always a field), binding, fold, position, bound.
proc Represent {hir u v} {
    set id [string range $v 2 end]
    switch -- [string index $v 0] {
        b {
            # A fold intermediate is the fold's acc<k>; a counted loop's
            # count binding is its counter i<k>, as its position is.
            foreach loop [dict get $u loops] {
                if {[dict getdef [dict get $hir exprs $loop] foldBinding ""] eq $id} {
                    return [list fold {}]
                }
                if {[dict getdef [dict get $hir exprs $loop] countBinding ""] eq $id} {
                    return [list counter $loop]
                }
            }
            # A function's parameter is always a frame field.
            set block [dict get $u block]
            if {$block ne "program" && $id in [dict get $hir exprs $block params]} {
                return [list param {}]
            }
            set name [ccompile::Sanitize [dict get $hir bindings $id name]]
            set n [string range $id 1 end]
            return [list binding [list v_${name}_$n]]
        }
        s { return [list counter $id] }
        a { return [list accumulator {}] }
    }
    return [list other {}]
}

set violations 0
set extras 0
set frames 0
set pendingTotal 0
foreach file $files {
    set name [file rootname [file tail $file]]
    if {[catch {surface::readProgramFile $file -warnings off} hir]} {
        puts "$name: does not compile: [lindex [split $hir \n] 0]"
        continue
    }
    if {[catch {ccompile::program $hir -prefix [ccompile::PrefixOf $file] -source [file tail $file]} out]} {
        if {![dict get $options -quiet]} {
            puts "$name: C UNSUPPORTED"
        }
        continue
    }
    set manifest ""
    dict for {fname text} [dict get $out files] {
        if {[string match *.runtime.json $fname]} {
            set manifest [Plain [lsp::json::parse $text]]
        }
    }
    set facts [hir::lifetime::analyze $hir]
    foreach frame [dict getdef $manifest coroutine_frames {}] {
        if {[dict get $frame role] ne "frame" || ![regexp {\((i[0-9]+)\)$} [dict get $frame of] -> id]} continue
        if {![dict exists $facts units $id]} {
            puts "$name: [dict get $frame of]: no unit $id"
            incr violations
            continue
        }
        incr frames
        set u [hir::lifetime::unit $facts $id]
        set fields [dict get $frame suspension_values]
        # What the HIR requires across the function's suspension points.
        set required {}
        set pending 0
        foreach s [dict get $u suspensions] {
            foreach v [concat [dict get $s bindings] [dict get $s positions] [dict get $s accumulators]] {
                if {$v ni $required} {
                    lappend required $v
                }
            }
            incr pending [llength [dict get $s pending]]
        }
        incr pendingTotal $pending
        set used {}
        set problems {}
        set accs [lsearch -all -inline -regexp $fields {^acc[0-9]+$}]
        set counters [lsearch -all -inline -regexp $fields {^i[0-9]+$}]
        set folds 0
        set loopsCounted {}
        foreach v $required {
            lassign [Represent $hir $u $v] kind names
            switch -- $kind {
                param { }
                binding {
                    set found [lsearch -inline -exact $fields [lindex $names 0]]
                    if {$found eq ""} {
                        lappend problems "[dict get $u vars $v] ([lindex $names 0]) is live across a suspension but not a frame field"
                    } else {
                        lappend used $found
                    }
                }
                fold { incr folds }
                counter {
                    if {$names ni $loopsCounted} {
                        lappend loopsCounted $names
                    }
                }
                default {
                    lappend problems "[dict get $u vars $v]: no C representation known"
                }
            }
        }
        if {$folds > [llength $accs]} {
            lappend problems "$folds fold intermediates live across a suspension, [llength $accs] acc fields"
        }
        set positions [llength $loopsCounted]
        if {$positions > [llength $counters]} {
            lappend problems "$positions counted loops' positions live across a suspension, [llength $counters] counter fields"
        }
        lappend used {*}[lrange $accs 0 [expr {$folds - 1}]] {*}[lrange $counters 0 [expr {$positions - 1}]]
        # A pending operand is a C temporary of a result (r<k>, n<k>).
        set temps [lsearch -all -inline -regexp $fields {^[rn][0-9]+$}]
        set maxPending 0
        foreach s [dict get $u suspensions] {
            set maxPending [expr {max($maxPending, [llength [dict get $s pending]])}]
        }
        if {$maxPending > [llength $temps]} {
            lappend problems "$maxPending pending operands live across a suspension, [llength $temps] result temporaries"
        }
        lappend used {*}[lrange $temps 0 [expr {$maxPending - 1}]]
        set extra [lmap f $fields {if {$f in $used} continue; set f}]
        incr violations [llength $problems]
        incr extras [llength $extra]
        set text "$name: [dict get $frame of]: HIR requires [llength $required]"
        append text " ([join [lmap v $required {dict get $u vars $v}] {, }])"
        append text "; C keeps [llength $fields] ([join $fields {, }])"
        if {$pending} {
            append text "; $pending pending operands (result temporaries)"
        }
        if {$extra ne {}} {
            append text "; extra: [join $extra {, }]"
        }
        puts $text
        foreach p $problems {
            puts "  VIOLATION: $p"
        }
    }
}
puts "frames $frames, violations $violations, extra fields $extras, pending operands $pendingTotal"
exit [expr {$violations > 0}]
