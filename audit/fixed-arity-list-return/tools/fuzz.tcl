# fuzz.tcl -- focused fuzzer for FIXED-ARITY-LIST-RETURN and the global warning
# modes (WARNINGS-FIXED-ARITY-LIST-RETURN.md, "Fuzzing").
#
#   tclsh9.0 audit/fixed-arity-list-return/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED?
#
# Each seed generates a program of one to three functions g0..g2 (parameters
# x, a, b) whose exits are *known by construction*. A function is guards
# (`if x == K:` / `return EXIT`), statements that are not exits, and a final
# statement:
#
#   literal         [e1, ..., eN], N in 0..3, elements from a pool of unknown
#                   and known values of mixed types (never consulted)
#   alias           r = [..] at the top of the body, `return r`; or a chain
#                   s = r, `return s`
#   self-call       gF(x - 1, a, b) (a base guard `if x <= 0: return [..]`
#                   comes first, so every run terminates); an aliased self-call
#                   hF(x - 1, a, b) with hF = gF
#   mismatches      [a].append(b) (computed, method sugar), a.helper(b) (an
#                   ordinary call of a list-returning helper), {q0: a, q1: b}
#                   (struct), a (parameter), bare `return`, `return unit`,
#                   final `unit`, a final destructuring statement, a final
#                   binding `s = r`, an else-less final `if` (literal + the
#                   unit fall-through)
#   not exits       `fail Bad`, a dead branch (`if 1 == 2`), a range-
#                   unreachable branch (`if x < 0:` / `if x > 5:`) holding any
#                   exit, a nested function (its exits are its own: predicted
#                   on their own)
#   annotations     `-> list` (always silent) on functions whose exits are all
#                   list-typed; `-> any` (no effect on the prediction)
#   self-calls only every exit a self-call (one variant with a literal behind
#                   a range-unreachable branch): silent
#
# About a third of the programs contain only silent functions. Method syntax
# is used for every call that would otherwise be METHOD-ELIGIBLE, so the only
# other codes that can appear are SAME-RETURN-VALUE (a repeated exact value)
# and SAME-FAILURE (`fail Bad` from two or more exits of one function). The
# fails are known by construction too, so the oracle predicts SAME-FAILURE
# exactly (WARNINGS-SAME-FAILURE.md): every `fail Bad` of a function is a
# reachable exit, and two or more are one group, anchored at the first.
#
# The oracle is independent of the compiler: from how each function was built
# it knows its value exits (dead and range-unreachable ones are not exits) and
# predicts warn or silent, and for a warning the anchor (first exit) and the
# note lines (the other exits), as line:column. For every program it checks
#
#   default   compiles; the FIXED-ARITY-LIST-RETURN warnings are exactly the
#             predicted functions with the predicted anchor and notes (a missed
#             or mislocated prediction is a failure; an unpredicted warning is
#             printed as EXTRA and counted, and the summary must show 0); the
#             SAME-FAILURE warnings likewise
#   off       compiles; no warning, no pass ran (stats counter, execution
#             trace on the pass), and the HIR equals default's without its
#             side table
#   error     rejected iff default had any warning, with the code of the
#             sort-first one (so with {CORE SEMANTIC FIXED-ARITY-LIST-RETURN}
#             whenever that is a predicted warning); a predicted warning (of
#             either code) is always a rejection
#   conversion  THE CONVERSION LAW (the weakened analogue of METHOD-ELIGIBLE's
#             round-trip law). Every predicted function is converted: each
#             literal exit [e0, ..., eN-1] (and each alias initializer that an
#             exit reads) becomes {p0: e0, ..., pN-1: eN-1}; a range-
#             unreachable exit of it is conformed to the same N-field struct
#             (the type checker joins it, see below); `-> any` is dropped (a
#             projection is resolved statically, never on `any`); self-calls
#             are unchanged. Each generated caller's positional reads
#             r.at(k) become r.pk. The converted program must compile (no
#             diagnostics) with no FIXED-ARITY-LIST-RETURN warning left, and
#             every driver run must give the same value as the original's,
#             except a run in which the original raised IndexNotFound (an
#             out-of-range positional read: list::at is fallible, r.pk is
#             total, so a converted program may legally complete there). Every
#             generated read has a constant index below N, so that excluded
#             set is empty by construction; it is counted, and the summary
#             must show 0.
#
# Exits non-zero on any failure.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

#   tclsh9.0 audit/fixed-arity-list-return/tools/fuzz.tcl -show SEED
#     prints the program SEED generates, its prediction and its conversion.
set show ""
if {[lindex $argv 0] eq "-show"} {
    set show [lindex $argv 1]
    set argv {}
}
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 300}]
set first [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc chance {p} {
    return [expr {rand() < $p}]
}

# Element texts: unknown and known values of several types. Elements are never
# consulted by the warning.
set ::elements {a b x 7 {"s"} {[b]} {a + 1} {[]}}

proc elements {n} {
    set result {}
    for {set i 0} {$i < $n} {incr i} {
        lappend result [pick $::elements]
    }
    return $result
}

# A literal of N elements: {NORMAL CONVERTED} texts.
proc literal {n} {
    set els [elements $n]
    set fields {}
    set i 0
    foreach e $els {
        lappend fields "p$i: $e"
        incr i
    }
    return [list "\[[join $els {, }]\]" [expr {$n == 0 ? "\[\]" : "\{[join $fields {, }]\}"}]]
}

# The N-field struct a range-unreachable exit is conformed to.
proc conformed {n} {
    set fields {}
    for {set i 0} {$i < $n} {incr i} {
        lappend fields "p$i: a"
    }
    return "\{[join $fields {, }]\}"
}

# A function under construction lives in the array F (upvar'd):
#   F(lines)    items, each {LINE} or {conv NORMAL CONVERTED} or
#               {range NORMAL} (a range-unreachable exit: conformed when the
#               function is converted)
#   F(exits)    {LINE COLUMN KIND ARITY} of every value exit, source order
#               (KIND: lit, alias, self, unit, other)
#   F(top)      binding lines placed at the top of the body

# One value exit EXIT of function F at relative LINE-INDEX of its lines,
# column COLUMN: a dict {text conv kind arity bindings}.
proc exitValue {f mode n nameVar} {
    upvar 1 $nameVar names
    switch -- $mode {
        lit {
            lassign [literal $n] text conv
            return [dict create text $text conv $conv kind lit arity $n bindings {}]
        }
        alias {
            set r "r[incr names]"
            lassign [literal $n] text conv
            set bindings [list [list conv "    $r = $text" "    $r = $conv"]]
            set name $r
            if {[chance 0.4]} {
                set s "s[incr names]"
                lappend bindings [list "    $s = $r"]
                set name $s
            }
            return [dict create text $name conv $name kind alias arity $n bindings $bindings]
        }
        self {
            return [dict create text "g$f\(x - 1, a, b)" conv "g$f\(x - 1, a, b)" kind self arity "" bindings {}]
        }
        aliasself {
            return [dict create text "h$f\(x - 1, a, b)" conv "h$f\(x - 1, a, b)" kind self arity "" \
                bindings [list [list "    h$f = g$f"]]]
        }
        computed { return [dict create text {[a].append(b)} conv {[a].append(b)} kind other arity "" bindings {}] }
        call     { return [dict create text {a.helper(b)} conv {a.helper(b)} kind other arity "" bindings {}] }
        struct   { return [dict create text {{q0: a, q1: b}} conv {{q0: a, q1: b}} kind other arity "" bindings {}] }
        param {
            set p [pick {a b}]
            return [dict create text $p conv $p kind other arity "" bindings {}]
        }
        unitval  { return [dict create text unit conv unit kind unit arity "" bindings {}] }
    }
    error "unknown exit mode $mode"
}

# Generates function F (an integer). QUIET forces at least one mismatch.
# Returns a dict: lines (items), exits, annotation, fails, selfs, nested
# {LINE COL NOTES...} predictions of its nested function, arity N.
proc genFunction {f quiet} {
    set names 0
    if {[chance 0.08]} {
        # Self-calls only (one variant behind a range-unreachable literal,
        # which pruning removes): no N to state, silent.
        set K [expr {1 + int(rand() * 4)}]
        set body [list [list "fn g$f\(x, a, b):"]]
        if {[chance 0.5]} {
            lappend body [list "    if x < 0:"] [list "        if x > 5:"] [list "            return \[a, b\]"]
        }
        lappend body [list "    if x == $K:"] [list "        return g$f\(x - 1, a, b)"] [list "    g$f\(x - 1, a, b)"]
        set last [expr {[llength $body] - 1}]
        return [dict create lines $body exits [list [list [expr {$last - 1}] 9 self ""] [list $last 5 self ""]] \
            annotation "" fails 0 failSites {} nested {}]
    }
    set n [pick {2 2 2 3 3 1}]
    set annotation [pick {"" "" "" "" "" " -> list" " -> any"}]
    set listOnly [expr {$annotation eq " -> list"}]
    # The pool of exit modes: matching exits (warn-ish) and mismatches.
    set matching {lit lit lit alias self aliasself}
    set mismatching [expr {$listOnly ? {computed otherlit} : {computed call struct param unitret unitval otherlit}}]
    set aimWarn [expr {!$quiet && [chance 0.7]}]
    set hasSelf [chance 0.4]
    set body {}
    set exits {}
    set bindings {}
    set fails 0
    set failSites {}
    set nestedWarn {}
    # The base guard (self-recursion terminates there).
    if {$hasSelf} {
        set v [exitValue $f lit $n names]
        lappend body [list "    if x <= 0:"] [list conv "        return [dict get $v text]" "        return [dict get $v conv]"]
        lappend exits [list [expr {[llength $body] - 1}] 9 lit $n]
    }
    set paths [expr {int(rand() * 4)}]
    set mismatchPlaced 0
    for {set k 0} {$k < $paths} {incr k} {
        set kind [pick {guard guard guard fail dead range nested}]
        set K [expr {1 + int(rand() * 4)}]
        switch -- $kind {
            guard {
                set mode [pick $matching]
                if {(!$aimWarn && [chance 0.5]) || ($quiet && !$mismatchPlaced)} {
                    set mode [pick $mismatching]
                    set mismatchPlaced 1
                }
                if {$mode in {self aliasself} && !$hasSelf} {
                    set mode lit
                }
                lappend body [list "    if x == $K:"]
                switch -- $mode {
                    unitret {
                        lappend body [list "        return[pick {{} { unit}}]"]
                        lappend exits [list [expr {[llength $body] - 1}] 9 unit ""]
                        continue
                    }
                    otherlit {
                        set m [pick [lsearch -all -inline -not -exact {0 1 2 3} $n]]
                        set v [exitValue $f lit $m names]
                    }
                    default {
                        set v [exitValue $f $mode $n names]
                    }
                }
                lappend bindings {*}[dict get $v bindings]
                lappend body [list conv "        return [dict get $v text]" "        return [dict get $v conv]"]
                lappend exits [list [expr {[llength $body] - 1}] 9 [dict get $v kind] [dict get $v arity]]
            }
            fail {
                lappend body [list "    if x == 7:"] [list "        fail Bad"]
                lappend failSites [list [expr {[llength $body] - 1}] 9]
                set fails 1
            }
            dead {
                set m [pick {0 1 2 3}]
                lassign [literal $m] text
                set what [expr {$listOnly ? $text : [pick [list $text {a.helper(b)} {} unit]]}]
                lappend body [list "    if 1 == 2:"] [list "        return[expr {$what eq {} ? {} : " $what"}]"]
            }
            range {
                # Range-unreachable: never an exit. A mismatching one makes the
                # pruning decide the outcome.
                set m [pick {1 2 3}]
                lassign [literal $m] text
                set what [expr {$listOnly ? $text : [pick [list $text $text {} {{q0: a, q1: b}}]]}]
                lappend body [list "    if x < 0:"] [list "        if x > 5:"] \
                    [list range "            return[expr {$what eq {} ? {} : " $what"}]"]
            }
            nested {
                # A nested function: its exits are its own.
                set warns [expr {!$quiet && [chance 0.6]}]
                set start [llength $body]
                lappend body [list "    fn inner$f$k\(y):"] [list "        if y == 1:"]
                if {$warns} {
                    lappend body [list nested "            return \[y, a\]" "            return \{p0: y, p1: a\}"] \
                        [list nested "        \[a, y\]" "        \{p0: a, p1: y\}"]
                    lappend nestedWarn [list [expr {$start + 2}] 13 [list [list [expr {$start + 3}] 9]]]
                } else {
                    lappend body [list "            return \[y, a\]"] [list "        \[a\]"]
                }
            }
        }
    }
    # The final statement.
    set finalKind [pick {expr expr expr expr ifelse elseless fail}]
    if {$quiet && !$mismatchPlaced} {
        set finalKind [pick {mismatch elseless}]
    } elseif {!$aimWarn && [chance 0.4]} {
        set finalKind [pick {mismatch elseless mismatch}]
    }
    if {$listOnly && $finalKind in {mismatch elseless}} {
        set finalKind otherlit
    }
    switch -- $finalKind {
        expr {
            set mode [pick $matching]
            if {$mode in {self aliasself} && !$hasSelf} {
                set mode lit
            }
            set v [exitValue $f $mode $n names]
            lappend bindings {*}[dict get $v bindings]
            lappend body [list conv "    [dict get $v text]" "    [dict get $v conv]"]
            lappend exits [list [expr {[llength $body] - 1}] 5 [dict get $v kind] [dict get $v arity]]
        }
        otherlit {
            set m [pick [lsearch -all -inline -not -exact {0 1 2 3} $n]]
            set v [exitValue $f lit $m names]
            lappend body [list conv "    [dict get $v text]" "    [dict get $v conv]"]
            lappend exits [list [expr {[llength $body] - 1}] 5 lit $m]
        }
        ifelse {
            set K [expr {1 + int(rand() * 4)}]
            lappend body [list "    if x == $K:"]
            foreach role {then else} {
                if {$role eq "else"} {
                    lappend body [list "    else:"]
                }
                # Mostly N; sometimes the other stated arity (mixed arity).
                set v [exitValue $f lit [expr {[chance 0.75] ? $n : ($n == 2 ? 3 : 2)}] names]
                lappend body [list conv "        [dict get $v text]" "        [dict get $v conv]"]
                lappend exits [list [expr {[llength $body] - 1}] 9 lit [dict get $v arity]]
            }
        }
        elseless {
            set K [expr {1 + int(rand() * 4)}]
            set v [exitValue $f lit $n names]
            lappend body [list "    if x == $K:"] [list conv "        [dict get $v text]" "        [dict get $v conv]"]
            lappend exits [list [expr {[llength $body] - 1}] 9 lit $n]
            # The fall-through: a unit exit (never located by a warning).
            lappend exits [list [expr {[llength $body] - 2}] 5 unit ""]
        }
        fail {
            lappend body [list "    fail Bad"]
            lappend failSites [list [expr {[llength $body] - 1}] 5]
            set fails 1
        }
        mismatch {
            switch -- [pick {computed call struct param unitval destructure finalbind}] {
                computed { lappend body [list "    \[a\].append(b)"] }
                call     { lappend body [list "    a.helper(b)"] }
                struct   { lappend body [list "    \{q0: a, q1: b\}"] }
                param    { lappend body [list "    [pick {a b}]"] }
                unitval  { lappend body [list "    unit"] }
                destructure { lappend body [list "    \{q0\} = \{q0: a\}"] }
                finalbind {
                    set r "r[incr names]"
                    lassign [literal $n] text conv
                    lappend bindings [list conv "    $r = $text" "    $r = $conv"]
                    lappend body [list "    t$f = $r"]
                }
            }
            lappend exits [list [expr {[llength $body] - 1}] 5 other ""]
        }
    }
    # One `hF = gF` however many aliased self-calls use it.
    set unique {}
    foreach item $bindings {
        if {$item ni $unique} {
            lappend unique $item
        }
    }
    set bindings $unique
    set header "fn g$f\(x, a, b)$annotation[expr {$fails ? { errors Bad} : {}}]:"
    # Lines: header, bindings, body. Exit line indexes shift by the bindings.
    set shift [expr {1 + [llength $bindings]}]
    set lines [concat [list [list conv $header [string map {" -> any" ""} $header]]] $bindings $body]
    set exits [lmap e $exits {lset e 0 [expr {[lindex $e 0] + $shift}]; set e}]
    set failSites [lmap e $failSites {lset e 0 [expr {[lindex $e 0] + $shift}]; set e}]
    set nestedWarn [lmap w $nestedWarn {
        lassign $w line col notes
        list [expr {$line + $shift}] $col [lmap o $notes {list [expr {[lindex $o 0] + $shift}] [lindex $o 1]}]
    }]
    return [dict create lines $lines exits $exits annotation $annotation fails $fails \
        failSites $failSites nested $nestedWarn]
}

# The oracle: {LINE COL NOTES ARITY} for a function that warns (absolute
# lines from BASE), "" for a silent one.
proc predict {fn base} {
    if {[dict get $fn annotation] eq " -> list"} {
        return ""
    }
    set arity ""
    foreach exit [dict get $fn exits] {
        lassign $exit line col kind n
        switch -- $kind {
            self {}
            lit - alias {
                if {$n < 2 || ($arity ne "" && $n != $arity)} {
                    return ""
                }
                set arity $n
            }
            default {
                return ""
            }
        }
    }
    if {$arity eq ""} {
        return ""
    }
    set located [lmap e [dict get $fn exits] {list [expr {$base + [lindex $e 0] + 1}] [lindex $e 1]}]
    return [list {*}[lindex $located 0] [lrange $located 1 end] $arity]
}

# The SAME-FAILURE oracle: {LINE COL NOTES} for a function failing `Bad` from
# two or more exits (absolute lines from BASE), "" otherwise.
proc predictFailures {fn base} {
    set located [lmap e [dict get $fn failSites] {list [expr {$base + [lindex $e 0] + 1}] [lindex $e 1]}]
    if {[llength $located] < 2} {
        return ""
    }
    return [list {*}[lindex $located 0] [lrange $located 1 end]]
}

# Renders ITEMS for the original program (CONVERT 0), the converted program's
# copy of a converted function (CONVERT 1: each conv item's converted text,
# range-unreachable exits conformed to ARITY fields), or of an unconverted one
# (CONVERT nested: only its nested function, when that is predicted, is
# converted).
proc render {items convert arity} {
    return [lmap item $items {
        switch -- [lindex $item 0] {
            conv  { lindex $item [expr {$convert eq "1" ? 2 : 1}] }
            nested { lindex $item [expr {$convert eq "0" ? 1 : 2}] }
            range {
                set text [lindex $item 1]
                if {$convert eq "1"} {
                    regsub {return.*$} $text "return [conformed $arity]" text
                }
                set text
            }
            default { lindex $item 0 }
        }
    }]
}

# {SOURCE CONVERTED PREDICTED DRIVERS FAILURES}: PREDICTED (FIXED-ARITY-LIST-
# RETURN) and FAILURES (SAME-FAILURE) lists of {LINE COL NOTES}.
proc generate {seed} {
    expr {srand($seed)}
    set quiet [expr {rand() < 0.33}]
    set header [list "import list" "error Bad" "fn helper(p, q):" [expr {$quiet ? "    \[p\]" : "    \[p, q\]"}]]
    set predicted {}
    set failures {}
    if {!$quiet} {
        lappend predicted [list 4 5 {}]
    }
    set original $header
    set converted [list "import list" "error Bad" "fn helper(p, q):" [expr {$quiet ? "    \[p\]" : "    \{p0: p, p1: q\}"}]]
    set drivers {}
    set callers {}
    set convertedCallers {}
    set functions [expr {1 + int(rand() * 3)}]
    for {set f 0} {$f < $functions} {incr f} {
        set fn [genFunction $f $quiet]
        set base [llength $original]
        set p [predict $fn $base]
        set pf [predictFailures $fn $base]
        if {$pf ne ""} {
            lappend failures $pf
        }
        foreach w [dict get $fn nested] {
            lassign $w line col notes
            lappend predicted [list [expr {$base + $line + 1}] $col \
                [lmap o $notes {list [expr {$base + [lindex $o 0] + 1}] [lindex $o 1]}]]
        }
        set convert [expr {$p ne ""}]
        set arity [lindex $p 3]
        lappend original {*}[render [dict get $fn lines] 0 $arity]
        if {$convert} {
            lappend converted {*}[render [dict get $fn lines] 1 $arity]
            lappend predicted [lrange $p 0 2]
            # A caller reading the result positionally, and two drivers.
            set errors [expr {[dict get $fn fails] ? "IndexNotFound, Bad" : "IndexNotFound"}]
            set last [expr {$arity - 1}]
            lappend callers "fn use$f\(x) -> any errors $errors:" "    r = x.g$f\(1, 2)" \
                "    \{k0: r.at(0), k1: r.at($last)\}"
            lappend convertedCallers "fn use$f\(x) -> any errors $errors:" "    r = x.g$f\(1, 2)" \
                "    \{k0: r.p0, k1: r.p$last\}"
            # The driver runs the caller for every guard value (so no call is
            # a statically known failure, which the compiler rejects even when
            # handled), collecting the values.
            set v "v$f"
            lappend drivers $v
            set lines [list "$v = loop k in ks:" "    w = use$f\(k):" "        on IndexNotFound:" \
                "            \"index-not-found\""]
            if {[dict get $fn fails]} {
                lappend lines "        on Bad:" "            \"bad\""
            }
            lappend lines "    w"
            lappend callers {*}$lines
            lappend convertedCallers {*}$lines
        } else {
            # Not converted: the same text (a `-> list` or silent function),
            # but for a predicted nested function.
            lappend converted {*}[render [dict get $fn lines] nested ""]
        }
    }
    set result [expr {$drivers eq "" ? "0" : "\{[join [lmap v $drivers {string cat $v ": " $v}] {, }]\}"}]
    lappend original "ks = \[0, 1, 2, 3, 4, 7\]" {*}$callers $result
    lappend converted "ks = \[0, 1, 2, 3, 4, 7\]" {*}$convertedCallers $result
    return [list [join $original \n] [join $converted \n] [lsort -dictionary $predicted] [llength $drivers] \
        [lsort -dictionary $failures]]
}

proc compileMode {source mode} {
    return [surface::compile $source fuzz.bot -warnings $mode -warning-channel ""]
}

# {LINE COL NOTES} of each CODE warning of HIR.
proc fixedOf {hir {code FIXED-ARITY-LIST-RETURN}} {
    set result {}
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne $code} continue
        set at [lrange [dict get $w primary] 2 end]
        set notes [lmap o [dict get $w secondary] {
            set fields [lrange $o 2 end]
            list [dict get $fields line] [dict get $fields column]
        }]
        lappend result [list [dict get $at line] [dict get $at column] $notes]
    }
    return [lsort -dictionary $result]
}

proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v]} {
        return [list error $v]
    }
    return $v
}

if {$show ne ""} {
    lassign [generate $show] source converted predicted drivers failures
    puts "$source\n--- predicted (line col notes):\n[join $predicted \n]\n--- predicted SAME-FAILURE:\n[join $failures \n]\n--- converted:\n$converted"
    exit 0
}

set failures 0
set extras 0
set warned 0
set clean 0
set conversions 0
set convertible 0
set excluded 0
set rejectedFixed 0
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    lassign [generate $seed] source converted predicted driverCount predictedFailures
    set problems {}
    if {[catch {compileMode $source default} hir options]} {
        lappend problems "default mode did not compile: $hir"
    } else {
        set actual [fixedOf $hir]
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] ni {FIXED-ARITY-LIST-RETURN SAME-RETURN-VALUE SAME-FAILURE}} {
                lappend problems "unexpected code [dict get $w code]"
            }
        }
        foreach p $predicted {
            if {$p ni $actual} {
                lappend problems "MISSED predicted warning $p (actual: $actual)"
            }
        }
        if {[llength $actual] != [llength [lsort -unique $actual]]} {
            lappend problems "a function was reported more than once: $actual"
        }
        foreach a $actual {
            if {$a ni $predicted} {
                puts "EXTRA seed $seed: warning $a is not predicted:\n$source"
                incr extras
            }
        }
        # SAME-FAILURE: the construction-known fails, exactly.
        set actualFailures [fixedOf $hir SAME-FAILURE]
        foreach p $predictedFailures {
            if {$p ni $actualFailures} {
                lappend problems "MISSED predicted SAME-FAILURE $p (actual: $actualFailures)"
            }
        }
        if {[llength $actualFailures] != [llength [lsort -unique $actualFailures]]} {
            lappend problems "a failure group was reported more than once: $actualFailures"
        }
        foreach a $actualFailures {
            if {$a ni $predictedFailures} {
                puts "EXTRA seed $seed: SAME-FAILURE $a is not predicted:\n$source"
                incr extras
            }
        }
        # off: compiles, silently, runs no warning pass.
        hir::warnings::resetStats
        set ::passCalls 0
        trace add execution hir::warnings::FixedArityListReturn enter {apply {{args} {incr ::passCalls}}}
        try {
            set offFailed [catch {compileMode $source off} off]
        } finally {
            trace remove execution hir::warnings::FixedArityListReturn enter {apply {{args} {incr ::passCalls}}}
        }
        if {$offFailed} {
            lappend problems "off mode did not compile: $off"
        } elseif {[hir::warnings::of $off] ne "" || [hir::warnings::stats] ne "" || $::passCalls != 0} {
            lappend problems "off mode ran or reported warnings"
        } elseif {$off ne [dict remove $hir warnings]} {
            lappend problems "HIR differs between off and default"
        }
        # error: rejected iff default warned, with the sort-first code.
        set all [hir::warnings::of $hir]
        set rejected [catch {compileMode $source error} message options]
        if {$rejected} {
            set expected [expr {$all eq "" ? "" : [list CORE SEMANTIC [dict get [lindex $all 0] code]]}]
            if {[dict get $options -errorcode] ne $expected} {
                lappend problems "error mode rejected with [dict get $options -errorcode] (expected $expected): $message"
            }
            if {[dict get $options -errorcode] eq {CORE SEMANTIC FIXED-ARITY-LIST-RETURN}} {
                incr rejectedFixed
            }
        } elseif {$all ne ""} {
            lappend problems "error mode accepted a program with warnings"
        }
        if {($predicted ne "" || $predictedFailures ne "") && !$rejected} {
            lappend problems "error mode accepted a program with a predicted warning"
        }
        # The conversion law.
        if {$predicted ne ""} {
            incr convertible
            if {[catch {compileMode $converted default} chir]} {
                lappend problems "CONVERSION does not compile: $chir\n--- converted:\n$converted"
            } else {
                set left [fixedOf $chir]
                if {$left ne ""} {
                    lappend problems "CONVERSION leaves warnings: $left"
                }
                set before [valueOf $hir]
                set after [valueOf $chir]
                if {[string match *index-not-found* $before]} {
                    incr excluded
                } elseif {$before ne $after} {
                    lappend problems "CONVERSION changes the value: $before -> $after\n--- converted:\n$converted"
                } else {
                    incr conversions
                }
            }
        }
        if {$actual eq ""} { incr clean } else { incr warned }
    }
    if {$problems ne ""} {
        incr failures
        puts "FAIL seed $seed:\n[join $problems \n]\n--- source:\n$source"
    }
}
puts "seeds $seeds (from $first): $warned with warnings, $clean without; failures $failures; extra warnings $extras; conversions $conversions of $convertible; excluded runs $excluded"
exit [expr {$failures > 0 || $extras > 0}]
