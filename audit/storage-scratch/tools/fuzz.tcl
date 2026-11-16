# fuzz.tcl -- compiler-managed scratch storage against the reference
# interpreter (STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md, "Independent
# and mutation-testing evidence").
#
#   tclsh9.0 audit/storage-scratch/tools/fuzz.tcl ?-seeds 1-5? ?-count 20?
#       ?-modes {plain stress growth}? ?-keep DIR?
#
# For each seed, a generator of its own (no compiler code: a grammar of
# ordinary Botlish over Strings) writes COUNT programs that build Strings in
# every shape the storage-use plan reasons about -- temporaries, helpers
# that return a String, a struct or a List holding one, errors whose payload
# holds one (handled, or let through an intermediate function), recursion,
# closures, loops left by `continue`, nested loops, Strings kept in a
# vector that outlives their loop or carried by a fold -- and folds every
# String it keeps into the program's value, so a String read after its
# storage was released changes the value (or fails: released storage is
# poisoned under GC stress).
#
# Each program runs on interp (the oracle) and natively with scratch
# storage, in each mode:
#
#   plain   the defaults;
#   stress  BOTLISH_NATIVE_GC_STRESS=1: a collection at every allocation
#           (scratch placements included), released storage poisoned;
#   growth  BOTLISH_NATIVE_SCRATCH_CHUNK=48: every few Strings a new chunk,
#           growth and replacement on every path.
#
# A program passes when every mode's outcome equals interp's and the
# allocation report (stress mode) counts no stale root and no protocol
# error. It also counts what the plan selected and emitted and what ran in
# scratch storage, so a run that placed nothing is visible. Exit status 1
# on any failure or any program that does not compile (a generator bug).
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -seeds 1-5 -count 20 -modes {plain stress growth} -keep ""]
foreach {k v} $argv {
    if {![dict exists $options $k]} {
        error "unknown option $k"
    }
    dict set options $k $v
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

proc Seeds {spec} {
    if {[regexp {^(\d+)-(\d+)$} $spec -> a b]} {
        set result {}
        for {set i $a} {$i <= $b} {incr i} {
            lappend result $i
        }
        return $result
    }
    return [split $spec ,]
}

# ---------------------------------------------------------------------------
# The generator

proc R {n} {
    return [expr {int(rand() * $n)}]
}

proc Pick {list} {
    return [lindex $list [R [llength $list]]]
}

proc Lit {} {
    return "\"[Pick {a bb ccc x- -yz q! {} {mid } long-text-piece}]\""
}

# An Int expression over the Int variables INTS, DEPTH deep at most.
proc IntExpr {ints strs depth} {
    set choice [R [expr {$depth > 0 ? 5 : 2}]]
    switch -- $choice {
        0 { return [Pick $ints] }
        1 { return [R 7] }
        2 { return "std::str::length([StrExpr $ints $strs [expr {$depth - 1}]])" }
        3 { return "[Pick $ints] + [IntExpr $ints $strs [expr {$depth - 1}]]" }
        default { return "([Pick $ints]).mod(5)" }
    }
}

# A String expression over INTS and the String variables STRS, calling
# the helpers generated so far.
proc StrExpr {ints strs depth} {
    global helpers
    set forms {lit int var}
    if {$depth > 0} {
        lappend forms concat concat int
        foreach h $helpers {
            lassign $h name kind
            if {$kind in {str box rec wrap ident boxer}} {
                lappend forms [list call $name $kind]
            }
        }
    }
    set f [Pick $forms]
    switch -- [lindex $f 0] {
        lit { return [Lit] }
        int { return "std::int::to_string([IntExpr $ints $strs 0])" }
        var {
            if {$strs eq {}} { return [Lit] }
            return [Pick $strs]
        }
        concat {
            return "[StrExpr $ints $strs [expr {$depth - 1}]].concat([StrExpr $ints $strs [expr {$depth - 1}]])"
        }
        call {
            lassign $f - name kind
            switch -- $kind {
                str { return "$name\([IntExpr $ints {} 0])" }
                box - boxer { return "$name\([IntExpr $ints {} 0]).label" }
                rec { return "$name\(([Pick $ints]).mod(4))" }
                wrap { return "$name\([StrExpr $ints $strs [expr {$depth - 1}]], [IntExpr $ints {} 0]).label" }
                ident { return "$name\([StrExpr $ints $strs [expr {$depth - 1}]])" }
            }
        }
    }
}

# One helper of kind KIND named NAME (it may call the helpers before it).
proc Helper {name kind} {
    set ints {i}
    set strs {}
    set lines {}
    # A few temporaries first.
    for {set k 0} {$k < [R 3]} {incr k} {
        set v t$k
        lappend lines "    $v = [StrExpr $ints $strs 2]"
        lappend strs $v
    }
    switch -- $kind {
        str {
            return [concat [list "fn $name\(i: int) -> str:"] $lines [list "    [StrExpr $ints $strs 2]"]]
        }
        box {
            return [concat [list "fn $name\(i: int) -> Box:"] $lines \
                [list "    Box {label: [StrExpr $ints $strs 2], n: [IntExpr $ints $strs 1]}"]]
        }
        list {
            return [concat [list "fn $name\(i: int) -> List\[str\]:"] $lines \
                [list "    \[[StrExpr $ints $strs 1], [StrExpr $ints $strs 1]\]"]]
        }
        fail {
            set s [StrExpr $ints $strs 2]
            return [concat [list "fn $name\(i: int) -> int errors Bad:"] $lines [list \
                "    m = $s" \
                "    if i.mod(3) == 0:" \
                "        fail Bad {text: m.concat(\"!\"), n: i}" \
                "    std::str::length(m)"]]
        }
        pass {
            global helpers
            set fails [lmap h $helpers {if {[lindex $h 1] eq "fail"} {lindex $h 0} else continue}]
            set callee [Pick $fails]
            return [concat [list "fn $name\(i: int) -> int errors Bad:"] $lines \
                [list "    $callee\(i + 1) + [IntExpr $ints $strs 1]"]]
        }
        wrap {
            # A struct around a String it is given (the caller's String
            # escapes with the result).
            return [list "fn $name\(s: str, i: int) -> Box:" "    Box {label: s, n: i}"]
        }
        ident {
            # A String it is given, or a new one.
            return [list "fn $name\(s: str) -> str:" \
                "    if std::str::length(s) > 3:" "        s" "    else:" "        s.concat(\"+\")"]
        }
        failp {
            # A failure whose payload is a String it is given.
            return [list "fn $name\(s: str, i: int) -> int errors Bad:" \
                "    if i.mod(2) == 0:" "        fail Bad {text: s, n: i}" "    std::str::length(s)"]
        }
        relay {
            # A fresh String into a function that may fail with it: the
            # error passes through.
            global helpers
            set callee [Pick [lmap h $helpers {if {[lindex $h 1] eq "failp"} {lindex $h 0} else continue}]]
            return [concat [list "fn $name\(i: int) -> int errors Bad:"] $lines \
                [list "    $callee\(std::int::to_string(i).concat([StrExpr $ints $strs 1]), i) + 1"]]
        }
        boxer {
            # A struct a callee builds around a fresh String, returned: the
            # String escapes this function with the result.
            global helpers
            set callee [Pick [lmap h $helpers {if {[lindex $h 1] eq "wrap"} {lindex $h 0} else continue}]]
            return [concat [list "fn $name\(i: int) -> Box:"] $lines \
                [list "    $callee\(std::int::to_string(i * 3).concat([StrExpr $ints $strs 1]), i)"]]
        }
        rec {
            return [list "fn $name\(i: int) -> str:" \
                "    here = std::int::to_string(i).concat(\"r\")" \
                "    if i <= 0:" \
                "        here" \
                "    else:" \
                "        $name\(i - 1).concat(here)"]
        }
        loop {
            return [concat [list "fn $name\(i: int) -> int:" \
                "    fold j from 0 to i.mod(6) with intermediate a 0:" \
                "        s = [StrExpr {i j} {} 2]" \
                "        if j == 2:" \
                "            continue" \
                "        a + std::str::length(s)"]]
        }
        sum {
            global helpers
            set lists [lmap h $helpers {if {[lindex $h 1] eq "list"} {lindex $h 0} else continue}]
            return [list "fn $name\(i: int) -> int:" \
                "    fold x in [Pick $lists](i) with intermediate a 0:" \
                "        a + std::str::length(x.concat(\"+\"))"]
        }
    }
}

# A statement of the main loop's body (I the induction variable).
proc Statement {ints strsVar} {
    upvar 1 $strsVar strs
    global helpers counter
    set v v[incr counter]
    set fails [lmap h $helpers {if {[lindex $h 1] in {fail pass relay}} {lindex $h 0} else continue}]
    set kinds [lmap h $helpers {lindex $h 1}]
    set choices {bind bind keep carry}
    if {$fails ne {}} { lappend choices handle handle }
    if {"loop" in $kinds || "sum" in $kinds} { lappend choices intcall }
    lappend choices continue closure nested
    # Every expression is generated over the variables bound so far; V is
    # bound after it (no forward reference).
    switch -- [Pick $choices] {
        bind {
            set lines [list "        $v = [StrExpr $ints $strs 3]"]
            lappend strs $v
        }
        keep {
            set lines [list "        kept.push([StrExpr $ints $strs 2])"]
        }
        carry {
            set lines [list "        last$v = [StrExpr $ints $strs 2]" "        kept.push(last$v)"]
        }
        handle {
            set f [Pick $fails]
            set lines [list "        n$v = $f\([IntExpr $ints $strs 1]):" \
                "            on Bad {text, n}:" \
                "                kept.push(text)" \
                "                n" \
                "        $v = std::int::to_string(n$v)"]
            lappend strs $v
        }
        intcall {
            set names [lmap h $helpers {if {[lindex $h 1] in {loop sum}} {lindex $h 0} else continue}]
            set lines [list "        $v = std::int::to_string([Pick $names]\([IntExpr $ints $strs 0]))"]
            lappend strs $v
        }
        continue {
            set lines [list "        if i.mod(7) == 4:" "            continue"]
        }
        closure {
            set c c$v
            set lines [list "        $c = [StrExpr $ints $strs 1]" \
                "        fn f$v\(k: int) -> str:" \
                "            $c.concat(std::int::to_string(k))" \
                "        $v = f$v\(i).concat(f$v\(1))"]
            lappend strs $c $v
        }
        nested {
            set lines [list "        w$v = fold j from 0 to 3 with intermediate b 0:" \
                "            s = [StrExpr {i j} $strs 2]" \
                "            b + std::str::length(s)" \
                "        $v = std::int::to_string(w$v)"]
            lappend strs $v
        }
    }
    return $lines
}

proc Program {} {
    global helpers counter
    set helpers {}
    set counter 0
    set lines [list "import std::int" "import std::str" "import std::list" "import std::mutable_vector" "" \
        "struct Box:" "    label: str" "    n: int" "" "error Bad:" "    text: str" "    n: int" ""]
    set plan {str box list fail wrap ident failp relay boxer boxer}
    for {set k 0} {$k < 2 + [R 5]} {incr k} {
        lappend plan [Pick {str str box list fail pass rec loop sum wrap ident failp relay boxer}]
    }
    set k 0
    foreach kind $plan {
        set have [lmap h $helpers {lindex $h 1}]
        if {$kind eq "pass" && "fail" ni $have} { set kind fail }
        if {$kind eq "sum" && "list" ni $have} { set kind list }
        if {$kind eq "relay" && "failp" ni $have} { set kind failp }
        if {$kind eq "boxer" && "wrap" ni $have} { set kind wrap }
        set name h[incr k]
        lappend lines {*}[Helper $name $kind] ""
        lappend helpers [list $name $kind]
    }
    lappend lines "fn through(f: Fn{args: \[int\], return: Box}, i: int) -> Box:" "    f(i)" "" \
        "fn main(n: int) -> str:" \
        "    kept = std::mutable_vector::from_list(\[\"start\"\])" \
        "    total = fold i from 0 to n with intermediate acc 0:"
    set strs {}
    set body {}
    for {set s 0} {$s < 2 + [R 5]} {incr s} {
        lappend body {*}[Statement {i acc} strs]
    }
    # Every program keeps a String that left a helper inside a struct --
    # through a direct call and through a call of a function value no
    # specialization makes exact (the canonical function runs) -- and one
    # that left a helper inside an error payload.
    set boxers [lmap h $helpers {if {[lindex $h 1] eq "boxer"} {lindex $h 0} else continue}]
    set relays [lmap h $helpers {if {[lindex $h 1] eq "relay"} {lindex $h 0} else continue}]
    lappend body "        kept.push([Pick $boxers]\(i).label)" \
        "        chosen = if i.mod(2) == 0:" "            [lindex $boxers 0]" "        else:" "            [lindex $boxers end]" \
        "        kept.push(through(chosen, i).label)" \
        "        relayed = [Pick $relays]\(i):" \
        "            on Bad {text, n}:" \
        "                kept.push(text)" \
        "                n"
    lappend lines {*}$body "        acc + [IntExpr {i acc} $strs 2]"
    lappend lines \
        "    text = fold k from 0 to std::mutable_vector::length(kept) with intermediate out \"\":" \
        "        item = std::mutable_vector::at(kept, k):" \
        "            on IndexNotFound:" \
        "                \"?\"" \
        "        out.concat(item).concat(\"|\")" \
        "    std::int::to_string(total).concat(\":\").concat(text)" "" \
        "main([expr {12 + [R 20]}])"
    return [join $lines \n]\n
}

# ---------------------------------------------------------------------------
# The runs

proc Mode {mode script} {
    switch -- $mode {
        plain { set env {} }
        stress { set env {BOTLISH_NATIVE_GC_STRESS 1} }
        growth { set env {BOTLISH_NATIVE_SCRATCH_CHUNK 48} }
    }
    return [uplevel 1 [list withEnvironment $env $script]]
}

set failures 0
set invalid 0
set programs 0
set totals [dict create selected 0 emitted 0 scratch 0 heapOn 0 heapOff 0]
foreach seed [Seeds [dict get $options -seeds]] {
    expr {srand($seed)}
    for {set c 0} {$c < [dict get $options -count]} {incr c} {
        set text [Program]
        incr programs
        if {[dict get $options -keep] ne ""} {
            file mkdir [dict get $options -keep]
            set f [open [file join [dict get $options -keep] s$seed-$c.bot] w]
            puts -nonewline $f $text
            close $f
        }
        if {[catch {surface::compile $text -warnings off} hir]} {
            incr invalid
            puts "seed $seed program $c: does not compile: [lindex [split $hir \n] 0]"
            continue
        }
        set oracle [outcomeUnderHir interp $hir]
        set bad {}
        foreach mode [dict get $options -modes] {
            if {[catch {Mode $mode {outcomeUnderHir cranelift $hir}} got]} {
                set got "the native run failed: [lindex [split $got \n] 0]"
            }
            if {$got ne $oracle} {
                lappend bad "$mode: $got"
            }
        }
        if {[catch {withEnvironment {BOTLISH_NATIVE_GC_STRESS 1} {native::allocationReport $hir summary}} report]} {
            lappend bad "the allocation report failed: [lindex [split $report \n] 0]"
            set report [dict create total [dict create allocations 0]]
        }
        set s [dict getdef $report scratch {}]
        if {[dict getdef $s staleRoots 0] || [dict getdef $s protocolErrors 0]} {
            lappend bad "stale roots [dict getdef $s staleRoots 0], protocol errors [dict getdef $s protocolErrors 0]"
        }
        set lowered [native::lowered $hir]
        set plan [dict get $lowered storagePlan plan]
        foreach id [hir::storageplan::units $plan] {
            dict for {site d} [dict get [hir::storageplan::unit $plan $id] sites] {
                if {[dict get $d status] eq "selected"} { dict incr totals selected }
            }
        }
        dict for {id sites} [dict get $lowered storagePlan emitted] {
            dict for {site st} $sites {
                if {[dict get $st status] eq "emitted"} { dict incr totals emitted }
            }
        }
        dict incr totals scratch [dict getdef $s allocations 0]
        catch {
            dict incr totals heapOn [dict get [native::allocationReport $hir summary] total allocations]
            dict incr totals heapOff [dict get [native::allocationReport $hir summary 1 -scratch-opt 0] total allocations]
        }
        if {$bad ne {}} {
            incr failures
            puts "seed $seed program $c: FAIL (oracle $oracle)"
            foreach b $bad { puts "    $b" }
            puts "--- the program:\n$text---"
        }
    }
}
puts "programs $programs, failures $failures, invalid $invalid"
puts "sites selected [dict get $totals selected], emitted [dict get $totals emitted]; Strings in scratch storage [dict get $totals scratch]; heap allocations [dict get $totals heapOff] without scratch storage, [dict get $totals heapOn] with it"
exit [expr {$failures || $invalid ? 1 : 0}]
