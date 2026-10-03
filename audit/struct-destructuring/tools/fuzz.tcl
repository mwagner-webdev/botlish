#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized equivalence check of struct destructuring
# (STRUCT-DESTRUCTURING.md).
#
#   tclsh9.0 audit/struct-destructuring/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1? ?-backends LIST?
#
# Each program is generated once as a random struct value and a random
# destructuring pattern over it, and printed twice:
#
#   A   with the destructuring syntax:           {a, f: b, u: {c}} = source
#   B   with the explicit ordinary spelling:     t0 = source
#                                                a = t0.a
#                                                b = t0.f
#                                                t1 = t0.u
#                                                c = t1.c
#                                                unit
#
# The explicit spelling is the oracle (the feature's own definition: evaluate
# the source once, then named projections, then ordinary bindings, then the
# statement's own value, `unit`: a destructuring statement evaluates to unit,
# never to the last field read): on every
# backend the two spellings must produce the identical outcome -- value (with
# runtime evidence), error code (messages carry source locations, which are
# removed) and the log the program kept of its own evaluation order. Within
# one spelling every backend must also agree with the others.
#
# The structs are random in:
#
#   shape        2..6 fields per struct; Int, String, List and nested struct
#                fields (nesting up to three levels (deeper anonymous struct types are widened to a bare `struct` by the type system, rejecting the explicit spelling too)); each struct is a declared
#                named struct or an anonymous one (a named struct holds named
#                structs); the written (construction) order is shuffled
#                against the declaration order
#   source       a struct literal written in place, a call returning the
#                struct, or a binding that is destructured and still used
#   pattern      a random non-empty subset of the fields at every level, in a
#                random order, each field shorthand or renamed, a struct field
#                bound whole or destructured in turn
#   context      a function body, an if/else branch, an elif chain, a
#                collecting loop, a nested function capturing the bindings,
#                a helper function
#   position     the destructure is followed by a result expression listing
#                the bindings (its own value is discarded), or it is the LAST
#                statement of its body -- the function body, the branch, the
#                collecting loop's iteration, a nested function -- so that its
#                value is observable and must be unit (the oracle's final
#                `unit`); the body's value is then returned beside the log
#   effects      field values are `probe(log, id, v)` calls, so the source's
#                evaluation (once, in the written order) is part of the outcome
#
# The run also generates NEGATIVE programs, each a valid program with exactly
# one defect:
#
#   missing-field        a requested field the struct does not have (at any
#                        nesting level)
#   non-struct-source    the source is an Int, String, List or unit
#   nested-non-struct    a non-struct field is destructured further
#   unproven-shape       the source is an untyped parameter whose struct type
#                        the function cannot prove
#   duplicate-source     the same field selected twice
#   duplicate-destination two bindings of one name
#   list-pattern         `[a, b] = source`, or a List pattern nested in a
#                        struct pattern
#   rest-binding         `{a, ...rest}`
#   empty-pattern        `{}`
#
# A negative program that is accepted, or that is rejected differently from its
# explicit spelling (the first five have one), or by something other than the
# diagnostic the defect names (the rest), is a "negative escape".
#
# Every program is seeded individually, so any failure replays with
# `-seed S -n 1 -dump 1`. The run ends with a summary line
# "destructuring-fuzz programs N values V errors E negatives M equivalence-
# disagreements D negative-escapes X backend-disagreements B"; the exit status
# is 1 if D, X or B is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 100
set seed0 1
set dump 0
set backends {interp compile cranelift-generic cranelift}
while {[lindex $args 0] in {-n -seed -dump -backends}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }
proc shuffle {list} {
    set result {}
    while {[llength $list]} {
        set i [expr {int(rand() * [llength $list])}]
        lappend result [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $result
}

# ---------------------------------------------------------------------------
# Schemas. A struct schema is {name NAME named 0|1 fields {FIELD...}}; a FIELD
# is {name KIND CHILD}: KIND int | str | list | struct, CHILD the schema of a
# struct field. Field names are globally unique in a program (f1, f2, ...), so
# a shorthand binding never collides with another binding.

proc newName {prefix} {
    return $prefix[incr ::counter($prefix)]
}

proc genSchema {depth named} {
    set count [rnd 2 6]
    set fields {}
    for {set i 0} {$i < $count} {incr i} {
        set kind [pick {int int int str list}]
        set child {}
        if {$depth < 2 && [chance [expr {$depth == 0 ? 0.35 : 0.2}]]} {
            set kind struct
            set child [genSchema [expr {$depth + 1}] [expr {$named ? 1 : [chance 0.3]}]]
        }
        lappend fields [list [newName f] $kind $child]
    }
    return [list [newName S] $named $fields]
}

proc schemaName {s} { return [lindex $s 0] }
proc schemaNamed {s} { return [lindex $s 1] }
proc schemaFields {s} { return [lindex $s 2] }

# The struct declarations (children first) of every named struct in SCHEMA.
proc declarations {s} {
    set lines {}
    foreach field [schemaFields $s] {
        lassign $field name kind child
        if {$kind eq "struct"} {
            lappend lines {*}[declarations $child]
        }
    }
    if {[schemaNamed $s]} {
        lappend lines "struct [schemaName $s]:"
        foreach field [schemaFields $s] {
            lassign $field name kind child
            switch -- $kind {
                int { set type int }
                str { set type str }
                list { set type List\[int\] }
                struct { set type [schemaName $child] }
            }
            lappend lines "    $name: $type"
        }
    }
    return $lines
}

# The source text of a value of schema S. Field values are probe calls (Int),
# literals and lists; the fields are written in a shuffled order.
proc valueText {s} {
    set parts {}
    foreach field [shuffle [schemaFields $s]] {
        lassign $field name kind child
        switch -- $kind {
            int {
                if {[chance 0.7]} {
                    set v "probe(log, [rnd 1 9], n + [rnd 0 9])"
                } else {
                    set v [rnd 0 30]
                }
            }
            str { set v "\"[pick {x yz Hello abc}]\"" }
            list { set v "\[n, [rnd 0 9]\]" }
            struct { set v [valueText $child] }
        }
        lappend parts "$name: $v"
    }
    set body "\{[join $parts {, }]\}"
    return [expr {[schemaNamed $s] ? "[schemaName $s] $body" : $body}]
}

# ---------------------------------------------------------------------------
# Patterns. A pattern is a list of ENTRY: {field local shorthand nested}; nested
# is "" or a pattern (then local is ""). genPattern returns {PATTERN BOUND...}:
# the bound names are in written order.

proc genPattern {s} {
    set fields [schemaFields $s]
    set count [rnd 1 [llength $fields]]
    set chosen [lrange [shuffle $fields] 0 [expr {$count - 1}]]
    set entries {}
    set bound {}
    foreach field $chosen {
        lassign $field name kind child
        if {$kind eq "struct" && [chance 0.45]} {
            lassign [genPattern $child] nested innerBound
            lappend entries [list $name "" 0 $nested]
            lappend bound {*}$innerBound
        } elseif {[chance 0.5]} {
            lappend entries [list $name $name 1 {}]
            lappend bound $name
        } else {
            set local [newName v]
            lappend entries [list $name $local 0 {}]
            lappend bound $local
        }
    }
    return [list $entries $bound]
}

proc patternText {entries} {
    set parts {}
    foreach entry $entries {
        lassign $entry name local shorthand nested
        if {$nested ne ""} {
            lappend parts "$name: [patternText $nested]"
        } elseif {$shorthand} {
            lappend parts $name
        } else {
            lappend parts "$name: $local"
        }
    }
    return "\{[join $parts {, }]\}"
}

# The explicit lines for PATTERN read from the struct bound to TEMP:
# `local = TEMP.field`, and `tmp2 = TEMP.field` for a nested pattern.
proc explicitLines {entries temp} {
    set lines {}
    foreach entry $entries {
        lassign $entry name local shorthand nested
        if {$nested ne ""} {
            set inner [newName t_]
            lappend lines "$inner = $temp.$name"
            lappend lines {*}[explicitLines $nested $inner]
        } else {
            lappend lines "$local = $temp.$name"
        }
    }
    return $lines
}

# ---------------------------------------------------------------------------
# Programs. A "case" is a dict with the schema, the pattern, the bound names,
# the source form and the context. blockLines renders the statements that
# bind the names, in either spelling.

proc blockLines {case style} {
    dict with case {}
    set lines {}
    set source [dict get $case sourceText]
    switch -- $form {
        direct { set expr $source }
        call { set expr "make(log, n)" }
        bound {
            lappend lines "s = $source"
            set expr s
        }
    }
    if {$style eq "destructured"} {
        lappend lines "[patternText $pattern] = $expr"
    } else {
        set ::counter(t_) 0
        set temp [newName t_]
        lappend lines "$temp = $expr"
        lappend lines {*}[explicitLines $pattern $temp]
        lappend lines unit
    }
    return $lines
}

proc resultText {case} {
    dict with case {}
    set items $bound
    if {$form eq "bound"} {
        lappend items "s.[lindex [lindex [schemaFields $schema] 0] 0]"
    }
    lappend items "mutable_array::get(log, 0, 0)"
    return "\[[join $items {, }]\]"
}

proc indent {lines n} {
    set pad [string repeat "    " $n]
    return [lmap line $lines {expr {$line eq "" ? "" : "$pad$line"}}]
}

proc program {case style} {
    dict with case {}
    set lines [declarations $schema]
    lappend lines "fn probe(log: MutableArray\[int\], id: int, v: int) -> int:"
    lappend lines "    if mutable_array::capacity(log) > 0:"
    lappend lines "        k = mutable_array::at(log, 0)"
    lappend lines "        mutable_array::set(log, 0, k * 10 + id)"
    lappend lines "    v"
    set rootType [expr {[schemaNamed $schema] ? " -> [schemaName $schema]" : ""}]
    if {$form eq "call"} {
        lappend lines "fn make(log: MutableArray\[int\], n: int)$rootType:"
        lappend lines "    [dict get $case sourceText]"
    }
    set block [blockLines $case $style]
    set result [resultText $case]
    if {$position eq "last"} {
        # The destructure is the last statement of its body: the body's value
        # (unit) is returned beside the log, which keeps the evaluation order
        # observable.
        set evidence "mutable_array::get(log, 0, 0)"
        switch -- $context {
            plain {
                lappend lines "fn body(log: MutableArray\[int\], n: int):"
                lappend lines {*}[indent $block 1]
                set run [list "log = mutable_array::create(1, 0)" "r = body(log, n)" "\[r, $evidence\]"]
            }
            branch {
                set run [list "log = mutable_array::create(1, 0)" \
                    "r = if n > 2:" {*}[indent $block 1] \
                    "else:" "    unit" "\[r, $evidence\]"]
            }
            elif {
                set run [list "log = mutable_array::create(1, 0)" \
                    "r = if n == 0:" "    unit" \
                    "elif n > 2:" {*}[indent $block 1] \
                    "else:" "    unit" "\[r, $evidence\]"]
            }
            loop {
                set run [list "log = mutable_array::create(1, 0)" \
                    "xs = loop i from 0 to 2:" {*}[indent $block 1] \
                    "\[xs, $evidence\]"]
            }
            closure {
                set run [list "log = mutable_array::create(1, 0)" \
                    "fn inner():" {*}[indent $block 1] \
                    "\[inner(), $evidence\]"]
            }
            helper {
                # A destructure last in a branch last in a collecting loop.
                set run [list "log = mutable_array::create(1, 0)" \
                    "xs = loop i from 0 to 3:" \
                    "    if i > 0:" {*}[indent $block 2] \
                    "    else:" "        unit" \
                    "\[xs, $evidence\]"]
            }
        }
        lappend lines "fn run(n: int):"
        lappend lines {*}[indent $run 1]
        lappend lines "\[run(3), run(0), run(7)\]"
        return [join $lines \n]
    }
    switch -- $context {
        plain {
            set run [list "log = mutable_array::create(1, 0)" {*}$block $result]
        }
        branch {
            set run [list "log = mutable_array::create(1, 0)" \
                "r = if n > 2:" {*}[indent [concat $block [list $result]] 1] \
                "else:" "    \[0\]" "r"]
        }
        elif {
            set run [list "log = mutable_array::create(1, 0)" \
                "r = if n == 0:" "    \[100\]" \
                "elif n > 2:" {*}[indent [concat $block [list $result]] 1] \
                "else:" "    \[0\]" "r"]
        }
        loop {
            set run [list "log = mutable_array::create(1, 0)" \
                "xs = loop i from 0 to 2:" {*}[indent [concat $block [list "\[i, [string range $result 1 end-1]\]"]] 1] \
                "xs"]
        }
        closure {
            set run [list "log = mutable_array::create(1, 0)" {*}$block \
                "fn grab():" "    $result" "grab()"]
        }
        helper {
            lappend lines "fn helper(log: MutableArray\[int\], n: int):"
            lappend lines {*}[indent [concat $block [list $result]] 1]
            set run [list "log = mutable_array::create(1, 0)" "helper(log, n)"]
        }
    }
    lappend lines "fn run(n: int):"
    lappend lines {*}[indent $run 1]
    lappend lines "\[run(3), run(0), run(7)\]"
    return [join $lines \n]
}

proc genCase {} {
    array unset ::counter
    set named [chance 0.5]
    set schema [genSchema 0 $named]
    lassign [genPattern $schema] pattern bound
    set form [pick {direct direct call bound}]
    set context [pick {plain plain branch elif loop closure helper}]
    set position [pick {after after last last}]
    return [dict create schema $schema pattern $pattern bound $bound form $form context $context \
        position $position sourceText [valueText $schema]]
}

# ---------------------------------------------------------------------------
# Running

proc stripLocations {message} {
    set message [regsub -all {[^ ]*\.bot:[0-9]+:[0-9]+} $message {t.bot:L:C}]
    set message [regsub -all {at [0-9]+:[0-9]+\)} $message {at L:C)}]
    return [regsub -all {\(at [0-9]+:[0-9]+\)} $message {(at L:C)}]
}

# {ok HIR}, or {error CODE MESSAGE} for a compile-time rejection (the CODE of a
# syntax error includes the diagnostic's stable `code`, when it has one).
proc compileOrError {source} {
    # Through a file: the programs call library modules (mutable_array::create).
    set file destructuring-fuzz-[pid].bot
    set path [makeFile $source $file]
    set failed [catch {surface::readProgramFile $path} hir options]
    removeFile $file
    if {$failed} {
        set code [dict get $options -errorcode]
        if {[lindex $code 1] eq "SYNTAX"} {
            set diagnostic [lindex $code 2]
            set code [list SURFACE SYNTAX [expr {[dict exists $diagnostic code] ? [dict get $diagnostic code] : ""}]]
        }
        return [list error $code [stripLocations $hir]]
    }
    return [list ok $hir]
}

proc outcomeOf {backend source} {
    set compiled [compileOrError $source]
    if {[lindex $compiled 0] eq "error"} {
        return $compiled
    }
    set outcome [outcomeUnderHir $backend [lindex $compiled 1]]
    if {[lindex $outcome 0] eq "error"} {
        lset outcome 2 [stripLocations [lindex $outcome 2]]
    }
    return $outcome
}

proc outcomesOf {source} {
    set compiled [compileOrError $source]
    if {[lindex $compiled 0] eq "error"} {
        return [lmap b $::backends {set compiled}]
    }
    return [lmap b $::backends {outcomeOf $b $source}]
}

set programs 0
set values 0
set errors 0
set negatives 0
set equivalenceDisagreements 0
set negativeEscapes 0
set backendDisagreements 0

# ---------------------------------------------------------------------------
# Negative programs: a valid base with one defect. Returns {DESTRUCTURED
# EXPLICIT EXPECTATION}: EXPLICIT is the explicit spelling the destructured
# program must be rejected exactly as ("" if there is none), EXPECTATION the
# diagnostic a defect with no explicit spelling must produce.

# A plain-context program from CASE with the pattern text and explicit lines
# overridden.
proc defective {case patternText explicitLines sourceText} {
    set lines [declarations [dict get $case schema]]
    lappend lines "fn probe(log: MutableArray\[int\], id: int, v: int) -> int:"
    lappend lines "    if mutable_array::capacity(log) > 0:"
    lappend lines "        k = mutable_array::at(log, 0)"
    lappend lines "        mutable_array::set(log, 0, k * 10 + id)"
    lappend lines "    v"
    set d [lines $lines "$patternText = $sourceText" $case]
    set e ""
    if {$explicitLines ne ""} {
        set e [lines $lines "t_1 = $sourceText\n[join $explicitLines \n]" $case]
    }
    return [list $d $e]
}

proc lines {declLines statements case} {
    set run [list "log = mutable_array::create(1, 0)" {*}[split $statements \n] "mutable_array::get(log, 0, 0)"]
    set all $declLines
    lappend all "fn run(n: int):"
    lappend all {*}[indent $run 1]
    lappend all "\[run(3), run(0)\]"
    return [join $all \n]
}

# All the (path, schema) pairs of a pattern's levels: {ENTRIES SCHEMA} for the
# top pattern and every nested one.
proc levels {entries schema} {
    set result [list [list $entries $schema]]
    foreach entry $entries {
        lassign $entry name local shorthand nested
        if {$nested ne ""} {
            foreach field [schemaFields $schema] {
                if {[lindex $field 0] eq $name} {
                    lappend result {*}[levels $nested [lindex $field 2]]
                }
            }
        }
    }
    return $result
}

# PATTERN with ENTRY appended at the level of the Nth pattern (by `levels`
# order), in a copy.
proc addEntryAt {entries index entry} {
    set counter 0
    return [addEntryWalk $entries $entry $index counter]
}
proc addEntryWalk {entries entry index counterVar} {
    upvar 1 $counterVar counter
    set here $counter
    incr counter
    set result {}
    foreach e $entries {
        lassign $e name local shorthand nested
        if {$nested ne ""} {
            set nested [addEntryWalk $nested $entry $index counter]
        }
        lappend result [list $name $local $shorthand $nested]
    }
    if {$here == $index} {
        lappend result $entry
    }
    return $result
}

proc negative {kind case} {
    set schema [dict get $case schema]
    set pattern [dict get $case pattern]
    set source [dict get $case sourceText]
    switch -- $kind {
        missing-field {
            set all [levels $pattern $schema]
            set index [rnd 0 [expr {[llength $all] - 1}]]
            set entry [list zz_missing zz_missing 1 {}]
            set bad [addEntryAt $pattern $index $entry]
            set ::counter(t_) 1
            set e [explicitLines $bad t_1]
            return [concat [defective $case [patternText $bad] $e $source] {{}}]
        }
        non-struct-source {
            set bad [pick {n {"text"} {[n, 1]} unit {mutable_array::create(1, 0)}}]
            set ::counter(t_) 1
            return [concat [defective $case [patternText $pattern] [explicitLines $pattern t_1] $bad] {{}}]
        }
        nested-non-struct {
            # A leaf entry that is not a struct field becomes a nested pattern.
            set all [levels $pattern $schema]
            set candidates {}
            foreach level $all {
                lassign $level entries sub
                foreach entry $entries {
                    lassign $entry name local shorthand nested
                    foreach field [schemaFields $sub] {
                        if {[lindex $field 0] eq $name && [lindex $field 1] ne "struct" && $nested eq ""} {
                            lappend candidates [list $entries $name]
                        }
                    }
                }
            }
            if {$candidates eq {}} {
                return [negative non-struct-source $case]
            }
            lassign [pick $candidates] entries name
            set bad [replaceLeaf $pattern $name {{zz_inner zz_inner 1 {}}}]
            set ::counter(t_) 1
            return [concat [defective $case [patternText $bad] [explicitLines $bad t_1] $source] {{}}]
        }
        unproven-shape {
            set lines [declarations $schema]
            lappend lines "fn probe(log: MutableArray\[int\], id: int, v: int) -> int:"
            lappend lines "    v"
            lappend lines "fn first(x):"
            lappend lines "    [patternText $pattern] = x"
            lappend lines "    [lindex [dict get $case bound] 0]"
            lappend lines "first(7)"
            set e [declarations $schema]
            lappend e "fn probe(log: MutableArray\[int\], id: int, v: int) -> int:"
            lappend e "    v"
            lappend e "fn first(x):"
            lappend e "    t_1 = x"
            set ::counter(t_) 1
            lappend e {*}[indent [explicitLines $pattern t_1] 1]
            lappend e "    [lindex [dict get $case bound] 0]"
            lappend e "first(7)"
            return [list [join $lines \n] [join $e \n] {}]
        }
        duplicate-source {
            set first [lindex $pattern 0]
            lassign $first name local shorthand nested
            set dup [list $name zz_dup 0 {}]
            set bad [linsert $pattern [rnd 1 [llength $pattern]] $dup]
            return [concat [defective $case [patternText $bad] {} $source] {{DUPLICATE-FIELD}}]
        }
        duplicate-destination {
            # Two root fields bound to one name.
            set fields [schemaFields $schema]
            set bad [list [list [lindex $fields 0 0] zz_same 0 {}] [list [lindex $fields 1 0] zz_same 0 {}]]
            set ::counter(t_) 1
            return [concat [defective $case [patternText $bad] [explicitLines $bad t_1] $source] {{}}]
        }
        list-pattern {
            if {[chance 0.5]} {
                return [concat [defective $case "\[a, b\]" {} $source] {{LIST-DESTRUCTURING}}]
            }
            set first [lindex [schemaFields $schema] 0]
            set bad "\{[lindex $first 0]: \[a, b\]\}"
            return [concat [defective $case $bad {} $source] {{LIST-DESTRUCTURING}}]
        }
        rest-binding {
            set text [patternText $pattern]
            set bad "[string range $text 0 end-1], ...rest\}"
            return [concat [defective $case $bad {} $source] {{rest/spread}}]
        }
        empty-pattern {
            return [concat [defective $case "\{\}" {} $source] {{at least one field}}]
        }
    }
}

# The leaf entries of PATTERN (entries with no nested pattern), at any depth.
proc flatLeaves {entries} {
    set result {}
    foreach entry $entries {
        lassign $entry name local shorthand nested
        if {$nested ne ""} {
            lappend result {*}[flatLeaves $nested]
        } else {
            lappend result $entry
        }
    }
    return $result
}

# PATTERN with the leaf entry of field NAME replaced by a nested pattern NESTED.
proc replaceLeaf {entries name nestedPattern} {
    set done 0
    return [replaceLeafWalk $entries $name $nestedPattern done]
}
proc replaceLeafWalk {entries name nestedPattern doneVar} {
    upvar 1 $doneVar done
    set result {}
    foreach entry $entries {
        lassign $entry n local shorthand nested
        if {$nested ne ""} {
            set nested [replaceLeafWalk $nested $name $nestedPattern done]
            lappend result [list $n $local $shorthand $nested]
        } elseif {$n eq $name && !$done} {
            set done 1
            lappend result [list $n "" 0 $nestedPattern]
        } else {
            lappend result $entry
        }
    }
    return $result
}

set negativeKinds {missing-field non-struct-source nested-non-struct unproven-shape duplicate-source
    duplicate-destination list-pattern rest-binding empty-pattern}

for {set k 0} {$k < $n} {incr k} {
    set seed [expr {$seed0 + $k}]
    expr {srand($seed)}
    set case [genCase]
    set sourceA [program $case destructured]
    set sourceB [program $case explicit]
    if {$dump} {
        puts "---- seed $seed ([dict get $case form], [dict get $case context], [dict get $case position])\n$sourceA\n-- explicit --\n$sourceB"
    }
    incr programs
    set outcomesA [outcomesOf $sourceA]
    set outcomesB [outcomesOf $sourceB]
    if {$outcomesA ne $outcomesB} {
        incr equivalenceDisagreements
        puts "EQUIVALENCE DISAGREEMENT seed $seed"
        foreach backend $backends a $outcomesA b $outcomesB {
            if {$a ne $b} {
                puts "  $backend: destructured [string range $a 0 300]\n  $backend: explicit     [string range $b 0 300]"
            }
        }
    }
    if {[llength [lsort -unique $outcomesA]] > 1} {
        incr backendDisagreements
        puts "BACKEND DISAGREEMENT seed $seed"
        foreach backend $backends a $outcomesA {
            puts "  $backend: [string range $a 0 300]"
        }
    }
    if {[lindex $outcomesA 0 0] eq "value"} {
        incr values
    } else {
        incr errors
        puts "note: seed $seed is an error outcome on both spellings: [string range [lindex $outcomesA 0] 0 400]"
    }

    # One negative program per generated program.
    set kind [lindex $negativeKinds [expr {$k % [llength $negativeKinds]}]]
    lassign [negative $kind $case] badSource explicitSource expectation
    incr negatives
    if {$dump} {
        puts "-- negative $kind --\n$badSource"
        if {$explicitSource ne ""} {
            puts "-- negative $kind (explicit) --\n$explicitSource"
        }
    }
    set negA [outcomesOf $badSource]
    if {$dump} {
        puts "-- negative $kind outcome: [string range [lindex $negA 0] 0 260]"
    }
    set escape ""
    if {[lindex $negA 0 0] eq "value"} {
        set escape "accepted a $kind defect and produced a value"
    } elseif {[llength [lsort -unique $negA]] > 1} {
        set escape "$kind: the backends disagree on the rejection: [string range $negA 0 300]"
    } elseif {$expectation ne ""} {
        if {[string first $expectation [lindex $negA 0 2]] < 0 && [string first $expectation [lindex $negA 0 1]] < 0} {
            set escape "rejected a $kind defect, but not with \"$expectation\": [string range [lindex $negA 0] 0 300]"
        }
    } elseif {$explicitSource ne ""} {
        set negB [outcomesOf $explicitSource]
        if {$negA ne $negB} {
            set escape "$kind: the destructured spelling is rejected differently from the explicit spelling: [string range [lindex $negA 0] 0 250] / [string range [lindex $negB 0] 0 250]"
        }
    } else {
        set escape "$kind: the generator gave no explicit spelling and no expectation"
    }
    if {$escape ne ""} {
        incr negativeEscapes
        puts "NEGATIVE ESCAPE seed $seed ($kind): $escape"
    }
}
puts "destructuring-fuzz programs $programs values $values errors $errors negatives $negatives equivalence-disagreements $equivalenceDisagreements negative-escapes $negativeEscapes backend-disagreements $backendDisagreements"
exit [expr {$equivalenceDisagreements || $negativeEscapes || $backendDisagreements ? 1 : 0}]
