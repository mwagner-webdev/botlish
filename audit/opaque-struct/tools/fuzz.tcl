#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized check of `opaque struct` (OPAQUE-STRUCTS.md):
# a struct whose representation belongs to the module that declares it.
#
#   tclsh9.0 audit/opaque-struct/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1? ?-backends LIST?
#
# Each program (seeded individually; a failure replays with `-seed S -n 1`)
# writes a small module `fzoK` into a scratch library:
#
#   Pt       x, y: int                      ordinary or opaque (random)
#   Outer    inner: Inner, n: int           Inner is always an ordinary struct
#   Gadget   cb, hook: Fn{int -> int}, tag  `cb` is also a module function
#   owner functions: make_Pt, get_x, get_y, sum (a destructuring), make_Outer,
#   count, inner_value, make_Gadget, cb, run (the field-value call (g.hook)(t))
#
# VALID programs are random mixes of consumer checks, each written twice -- once
# with qualified calls and once with method calls -- against that module:
#
#   accessor    fzoK::get_x(fzoK::make_Pt(a, b))       vs  make_Pt(a, b).get_x()
#   pass        a value through the consumer's own function, typed fzoK::Pt
#   holder      a consumer struct H holding the value, read back and accessed
#   list/eq     the value in a list, == between values, hash equality
#   nested      Outer/Inner accessors of the owner
#   gadget      the owner's field-value call; `g.cb()` as a method call (opaque
#               only: on an ordinary struct the field makes it ambiguous)
#   direct      only when Pt is ordinary: construction, projection and
#               destructuring from outside, exactly as before opaque existed
#
# The two spellings must agree on every backend, the backends with each other,
# and the value must equal an independent Tcl oracle's. The user-facing text of
# a `Pt` value (core::value::show) must be `<opaque fzoK::Pt>` when Pt is opaque
# and its full representation when it is not, on every backend.
#
# NEGATIVE programs rotate through the shapes an unauthorized consumer must be
# refused, each against an opaque module with its expected diagnostic kind, and
# against the ORDINARY twin (the same module and consumer with `opaque`
# removed), whose outcome is the control -- accepted (or the ordinary
# diagnostic) -- so a rejection can only be the opacity check:
#
#   ctor              fzoK::Pt {x: a, y: b}                OPAQUE-CONSTRUCTION
#   ctor-bad          wrong or unknown fields              OPAQUE-CONSTRUCTION only
#   project           make_Pt(a, b).x + 1                  OPAQUE-REPRESENTATION
#   project-guess     make_Pt(a, b).zzz                    OPAQUE-REPRESENTATION
#                     (the ordinary twin: UNKNOWN-FIELD)
#   destructure       {x} = make_Pt(a, b)                  OPAQUE-REPRESENTATION
#   destructure-rename {y: why} = p
#   nested            {inner: {v: w}} = o
#   nested-partial    {n} = o
#   inner-through     o.inner
#   field-value-call  (g.hook)(3)
#   method-hidden     g.hook(3), no function `hook` visible
#   through-holder    h.p.x, h a consumer struct holding the value
#   holder-module     another module's struct holding the value reads h.p.x
#   instance-bypass   fn peek(x): x.x -- called with the value
#   child-forge       a child module constructs its parent's struct
#   parent-forge      a parent module constructs its child's struct
#   no-fallout        `if x.x:` -- only the opacity diagnostic, not a type error
#                     (the ordinary twin: TYPE)
#
# A real hidden field, a guessed one and a destructuring of either must give the
# very same diagnostic (message-leaks counts a difference).
#
# For the construction and projection shapes the set of diagnostic kinds of the
# unauthorized program (compiled non-strictly) must be exactly the one opacity
# kind: no missing-field, unknown-field, duplicate-field or type diagnostic
# that would describe the hidden representation.
#
# The run ends with "opaque-struct-fuzz programs N values V negatives M
# twins T differential-disagreements D oracle-disagreements O negative-escapes X
# twin-escapes W diagnostic-set-escapes S print-disagreements P message-leaks L
# backend-disagreements B"; the exit status is 1 if any of D O X W S P L B is
# not zero. audit/opaque-struct/tools/mutate.tcl runs this fuzzer against copies of
# the tree with each opacity check disabled in turn: every mutant must be
# killed.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 60
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
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# A scratch library: a copy of lib/ plus the modules generated below.
set scratch [file join [file tempdir opaque-struct-fuzz]]
file copy -force [file join $root lib] [file join $scratch lib]
set ::libraryDir [file join $scratch lib]
set ::core::libraryDir $::libraryDir
set programDir [file join $scratch programs]
file mkdir $programDir
set counter 0

proc writeModule {name content} {
    set path [file join $::libraryDir {*}[split $name /]].bot
    file mkdir [file dirname $path]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $content
    close $channel
}

proc writeProgram {source} {
    set path [file join $::programDir p[incr ::counter].bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $source
    close $channel
    return $path
}

# {ok HIR} or {error KIND MESSAGE}.
proc compileSource {source {strict 1}} {
    if {[catch {surface::readProgramFile [writeProgram $source] -strict $strict -warnings off} hir options]} {
        set code [dict get $options -errorcode]
        set kind [expr {[lindex $code 1] eq "SYNTAX" ? "SYNTAX" : [lindex $code end]}]
        return [list error $kind [regsub -all {[^ ]*\.bot:[0-9]+:[0-9]+} $hir {t.bot:L:C}]]
    }
    return [list ok $hir]
}

# "accepted" or the kind of the first rejection of SOURCE.
proc outcomeKind {source} {
    set compiled [compileSource $source]
    return [expr {[lindex $compiled 0] eq "ok" ? "accepted" : [lindex $compiled 1]}]
}

# The sorted unique diagnostic kinds of SOURCE compiled non-strictly, or the
# error kind if it does not even build.
proc diagnosticKinds {source} {
    set compiled [compileSource $source 0]
    if {[lindex $compiled 0] eq "error"} {
        return [list build-error [lindex $compiled 1]]
    }
    return [lsort -unique [lmap d [hir::diagnostics [lindex $compiled 1]] {dict get $d kind}]]
}

proc outcomesOf {source} {
    set compiled [compileSource $source]
    if {[lindex $compiled 0] eq "error"} {
        return [lmap b $::backends {list error [lindex $compiled 1] [lindex $compiled 2]}]
    }
    return [lmap b $::backends {
        set outcome [outcomeUnderHir $b [lindex $compiled 1]]
        list [lindex $outcome 0] [lindex $outcome 1]
    }]
}

# The user-facing text of the value of SOURCE on every backend: a list of one
# text per backend.
proc shownOnEach {source} {
    set compiled [compileSource $source]
    if {[lindex $compiled 0] eq "error"} {
        return [lmap b $::backends {list error [lindex $compiled 1]}]
    }
    set hir [lindex $compiled 1]
    return [lmap b $::backends {
        set saved [core::useBackend]
        try {
            if {$b in {cranelift cranelift-generic}} {
                set value [native::evalHir $hir {*}[expr {$b eq "cranelift-generic" ? {-specialize 0} : {}}]]
            } else {
                core::useBackend $b
                set value [core::evalProgram [hir::lower $hir]]
            }
            core::value::show $value 1
        } finally {
            core::useBackend $saved
        }
    }]
}

# ---------------------------------------------------------------------------
# The generated module

# The source of module `M` (a namespace name), its structs opaque or ordinary.
proc moduleSource {opaque} {
    set mod [expr {$opaque ? "opaque " : ""}]
    return "struct Inner:
    v: int

${mod}struct Pt:
    x: int
    y: int

${mod}struct Outer:
    inner: Inner
    n: int

${mod}struct Gadget:
    cb: Fn{args: \[int\], return: int, errors: \[\]}
    hook: Fn{args: \[int\], return: int, errors: \[\]}
    tag: int

fn twice(k: int) -> int:
    k + k

fn make_Pt(x: int, y: int) -> Pt:
    Pt {x: x, y: y}

fn get_x(p: Pt):
    p.x

fn get_y(p: Pt):
    p.y

fn sum(p: Pt):
    {x, y} = p
    x + y

fn make_Outer(v: int, n: int) -> Outer:
    Outer {inner: Inner {v: v}, n: n}

fn count(o: Outer):
    o.n

fn inner_value(o: Outer):
    o.inner.v

fn make_Gadget(tag: int) -> Gadget:
    Gadget {cb: twice, hook: twice, tag: tag}

fn cb(g: Gadget) -> int:
    100

fn run(g: Gadget):
    (g.hook)(g.tag)
"
}

# ---------------------------------------------------------------------------
# Valid programs. A check is {FREE METHOD EXPECTED}; M is the module namespace.

proc genChecks {M opaque} {
    set kinds {accessor accessor-y pass holder list-length eq hash nested-count nested-inner gadget-run}
    if {$opaque} { lappend kinds gadget-method }
    if {!$opaque} { lappend kinds direct-construct direct-destructure }
    set checks {}
    foreach _ [lrepeat [rnd 3 7] x] {
        set a [rnd -20 99]
        set b [rnd -20 99]
        set c [rnd -20 99]
        set d [rnd -20 99]
        switch -- [pick $kinds] {
            accessor {
                lappend checks [list "${M}::get_x(${M}::make_Pt($a, $b))" "${M}::make_Pt($a, $b).get_x()" $a]
            }
            accessor-y {
                lappend checks [list "${M}::sum(${M}::make_Pt($a, $b))" "${M}::make_Pt($a, $b).sum()" [expr {$a + $b}]]
            }
            pass {
                lappend checks [list "${M}::get_y(id_pt(${M}::make_Pt($a, $b)))" "id_pt(${M}::make_Pt($a, $b)).get_y()" $b]
            }
            holder {
                lappend checks [list "${M}::get_x(through(H {p: ${M}::make_Pt($a, $b)}))" "through(H {p: ${M}::make_Pt($a, $b)}).get_x()" $a]
            }
            list-length {
                set k [rnd 1 3]
                set items [lrepeat $k "${M}::make_Pt($a, $b)"]
                lappend checks [list "list::length(\[[join $items {, }]\])" "\[[join $items {, }]\].length()" $k]
            }
            eq {
                lappend checks [list "${M}::make_Pt($a, $b) == ${M}::make_Pt($c, $d)" "${M}::make_Pt($a, $b) == ${M}::make_Pt($c, $d)" \
                    [expr {$a == $c && $b == $d ? "true" : "false"}]]
            }
            hash {
                lappend checks [list "hash(${M}::make_Pt($a, $b)) == hash(${M}::make_Pt($a, $b))" "hash(${M}::make_Pt($a, $b)) == hash(${M}::make_Pt($a, $b))" true]
            }
            nested-count {
                lappend checks [list "${M}::count(${M}::make_Outer($a, $b))" "${M}::make_Outer($a, $b).count()" $b]
            }
            nested-inner {
                lappend checks [list "${M}::inner_value(${M}::make_Outer($a, $b))" "${M}::make_Outer($a, $b).inner_value()" $a]
            }
            gadget-run {
                lappend checks [list "${M}::run(${M}::make_Gadget($a))" "${M}::make_Gadget($a).run()" [expr {$a * 2}]]
            }
            gadget-method {
                # The hidden function-valued field `cb` is no method candidate:
                # g.cb() is the module function `cb`, on an opaque struct only.
                lappend checks [list "${M}::cb(${M}::make_Gadget($a))" "${M}::make_Gadget($a).cb()" 100]
            }
            direct-construct {
                lappend checks [list "${M}::Pt {x: $a, y: $b}.x" "${M}::Pt {x: $a, y: $b}.x" $a]
            }
            direct-destructure {
                lappend checks [list "dx(${M}::make_Pt($a, $b))" "dx(${M}::make_Pt($a, $b))" $b]
            }
        }
    }
    return $checks
}

proc consumerDefinitions {M opaque} {
    set defs "struct H:
    p: ${M}::Pt

fn id_pt(p: ${M}::Pt) -> ${M}::Pt:
    p

fn through(h: H) -> ${M}::Pt:
    h.p
"
    if {!$opaque} {
        # Only an ordinary struct's fields are open to the consumer.
        append defs "
fn dx(p: ${M}::Pt):
    {y} = p
    y
"
    }
    return $defs
}

# {FREE-SOURCE METHOD-SOURCE EXPECTED SHOWN-SOURCE SHOWN-EXPECTED} of one program;
# writes the module it uses.
proc genValid {k} {
    set opaque [expr {rand() < 0.6}]
    set M fzo$k
    writeModule $M [moduleSource $opaque]
    set checks [genChecks $M $opaque]
    set head "import $M\nimport list\n"
    set defs [consumerDefinitions $M $opaque]
    set free [lmap c $checks {lindex $c 0}]
    set method [lmap c $checks {lindex $c 1}]
    set want [lmap c $checks {lindex $c 2}]
    set a [rnd -9 9]
    set b [rnd -9 9]
    set shown [expr {$opaque ? "<opaque ${M}::Pt>" : "${M}::Pt {x: $a, y: $b}"}]
    return [list "$head$defs\n\[[join $free {, }]\]\n" "$head$defs\n\[[join $method {, }]\]\n" "\[[join $want {, }]\]" \
        "import $M\n${M}::make_Pt($a, $b)\n" $shown $opaque]
}

# ---------------------------------------------------------------------------
# Negative programs. A shape gives {SOURCE KIND TWIN-KIND DIAGNOSTICS}, with
# the module `fzoK` (and any extra modules) already written for the opaque
# variant (OPAQUE 1) or the ordinary twin (OPAQUE 0). KIND is the opacity
# diagnostic the opaque variant must raise, TWIN-KIND the twin's outcome
# ("accepted", or the ordinary diagnostic), DIAGNOSTICS the exact set of
# diagnostic kinds of the opaque variant compiled non-strictly (or "" for no
# such check); a fifth element, when given, is a word no diagnostic of the
# opaque variant may contain (a word of the hidden representation).

set ::shapes {ctor ctor-bad project project-guess destructure destructure-rename nested nested-partial
    inner-through field-value-call method-hidden through-holder holder-module instance-bypass
    child-forge parent-forge no-fallout}

proc negativeProgram {shape k opaque} {
    set result [NegativeProgram $shape $k $opaque]
    return [expr {[llength $result] == 4 ? [linsert $result end ""] : $result}]
}

proc NegativeProgram {shape k opaque} {
    set M fzo$k
    writeModule $M [moduleSource $opaque]
    set mod [expr {$opaque ? "opaque " : ""}]
    set a [rnd 0 99]
    set b [rnd 0 99]
    set h "import $M\n"
    switch -- $shape {
        ctor {
            return [list "$h${M}::Pt {x: $a, y: $b}\n" OPAQUE-CONSTRUCTION accepted {OPAQUE-CONSTRUCTION}]
        }
        ctor-bad {
            set literal [pick [list "${M}::Pt {x: \"s\", z: 1}" "${M}::Pt {x: $a}" "${M}::Pt {x: $a, x: $b, y: 1}" "${M}::Pt {guess: $a}" "${M}::Pt {x: $a, y: $b, extra: 1}"]]
            return [list "$h$literal\n" OPAQUE-CONSTRUCTION skip {OPAQUE-CONSTRUCTION}]
        }
        project {
            return [list "$h${M}::make_Pt($a, $b).x + 1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        project-guess {
            return [list "$h${M}::make_Pt($a, $b).[pick {zzz guess y_ real_one}]\n" OPAQUE-REPRESENTATION UNKNOWN-FIELD {OPAQUE-REPRESENTATION}]
        }
        destructure {
            return [list "${h}{x} = ${M}::make_Pt($a, $b)\nx + 1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        destructure-rename {
            return [list "${h}p = ${M}::make_Pt($a, $b)\n{y: why} = p\nwhy + 1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        nested {
            # (`w` is `any`, so the inner `v` is also an unproven projection:
            # the existing, name-independent consequence of the rejected one.)
            return [list "${h}o = ${M}::make_Outer($a, $b)\n{inner: {v: w}} = o\nw + 1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION UNPROVEN-FIELD}]
        }
        nested-partial {
            return [list "${h}o = ${M}::make_Outer($a, $b)\n{n} = o\nn + 1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        inner-through {
            return [list "${h}o = ${M}::make_Outer($a, $b)\ni = o.inner\ni.v + 1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION UNPROVEN-FIELD}]
        }
        field-value-call {
            return [list "${h}g = ${M}::make_Gadget($a)\n(g.hook)($b)\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        method-hidden {
            return [list "${h}g = ${M}::make_Gadget($a)\ng.hook($b)\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        through-holder {
            return [list "${h}struct H:\n    p: ${M}::Pt\nh = H {p: ${M}::make_Pt($a, $b)}\nh.p.x + 1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        holder-module {
            writeModule fzh${k} "import $M\n\nstruct HH:\n    p: ${M}::Pt\n\nfn bad(h: HH):\n    h.p.x\n"
            return [list "import fzh${k}\n1\n" OPAQUE-REPRESENTATION accepted {OPAQUE-REPRESENTATION}]
        }
        instance-bypass {
            return [list "${h}fn peek(q):\n    q.x\npeek(${M}::make_Pt($a, $b))\n" OPAQUE-REPRESENTATION accepted ""]
        }
        child-forge {
            writeModule ${M}/kid "import $M\n\nfn forge():\n    ${M}::Pt {x: 1, y: 2}\n"
            return [list "import ${M}::kid\n1\n" OPAQUE-CONSTRUCTION accepted {OPAQUE-CONSTRUCTION}]
        }
        parent-forge {
            writeModule fzp${k} "import fzp${k}::kid\n\nfn forge():\n    fzp${k}::kid::Kid {k: 1}\n"
            writeModule fzp${k}/kid "${mod}struct Kid:\n    k: int\n"
            return [list "import fzp${k}\n1\n" OPAQUE-CONSTRUCTION accepted {OPAQUE-CONSTRUCTION}]
        }
        no-fallout {
            # The hidden field x.x is an int in the owner. Passed to a bool
            # parameter, an ordinary struct's field is the TYPE error naming
            # int; here the rejected access is typed as an unknown field is,
            # so no diagnostic of the program ever names the hidden type.
            return [list "${h}fn f(b: bool):\n    b\nx = ${M}::make_Pt($a, $b)\nf(x.x)\n" OPAQUE-REPRESENTATION TYPE {OPAQUE-REPRESENTATION TYPE} int]
        }
    }
    error "unknown shape $shape"
}

# ---------------------------------------------------------------------------

set programs 0
set values 0
set negatives 0
set twins 0
set differentialDisagreements 0
set oracleDisagreements 0
set negativeEscapes 0
set twinEscapes 0
set diagnosticSetEscapes 0
set printDisagreements 0
set messageLeaks 0
set backendDisagreements 0

try {
    for {set k 0} {$k < $n} {incr k} {
        set seed [expr {$seed0 + $k}]
        expr {srand($seed)}
        lassign [genValid $k] free method want shownSource shownWant opaque
        if {$dump} {
            puts "---- seed $seed (Pt opaque: $opaque)\n$method\n-- free --\n$free\n-- expect: $want"
        }
        incr programs
        set a [outcomesOf $method]
        set b [outcomesOf $free]
        if {[llength [lsort -unique $a]] != 1 || [llength [lsort -unique $b]] != 1} {
            incr backendDisagreements
            puts "BACKEND DISAGREEMENT seed $seed"
            foreach backend $backends x $a y $b { puts "  $backend: method $x / free $y" }
        } elseif {[lindex $a 0] ne [lindex $b 0]} {
            incr differentialDisagreements
            puts "DIFFERENTIAL DISAGREEMENT seed $seed: method [lindex $a 0] free [lindex $b 0]"
        } elseif {[lindex $a 0] ne [list value $want]} {
            incr oracleDisagreements
            puts "ORACLE DISAGREEMENT seed $seed: expected $want, got [lindex $a 0]\n$method"
        } else {
            incr values
        }

        # The printed text of the value: nominal when opaque, full otherwise.
        set shown [shownOnEach $shownSource]
        if {[lsort -unique $shown] ne [list $shownWant]} {
            incr printDisagreements
            puts "PRINT DISAGREEMENT seed $seed: expected $shownWant, got $shown"
        }

        # The negative shape of this round, against the opaque module and its
        # ordinary twin.
        set shape [lindex $::shapes [expr {$k % [llength $::shapes]}]]
        set negSeed [expr {$seed * 7919}]
        expr {srand($negSeed)}
        lassign [negativeProgram $shape $k 1] source kind twinKind diagnostics forbidden
        if {$dump} {
            puts "-- negative ($shape, expect $kind, twin $twinKind)\n$source"
        }
        incr negatives
        set got [outcomeKind $source]
        if {$got ne $kind} {
            incr negativeEscapes
            puts "NEGATIVE ESCAPE seed $seed ($shape): expected $kind, got $got\n$source"
        }
        if {$diagnostics ne ""} {
            set set [diagnosticKinds $source]
            if {$set ne $diagnostics} {
                incr diagnosticSetEscapes
                puts "DIAGNOSTIC SET ESCAPE seed $seed ($shape): expected $diagnostics, got $set\n$source"
            }
        }
        if {$forbidden ne ""} {
            # No diagnostic of the unauthorized program may name FORBIDDEN (a
            # word of the hidden representation).
            set compiled [compileSource $source 0]
            foreach d [expr {[lindex $compiled 0] eq "ok" ? [hir::diagnostics [lindex $compiled 1]] : {}}] {
                if {[regexp "\\y${forbidden}\\y" [dict get $d message]]} {
                    incr diagnosticSetEscapes
                    puts "REPRESENTATION LEAK seed $seed ($shape): a diagnostic names \"$forbidden\": [dict get $d message]"
                }
            }
        }
        # A field that exists and one that does not (or a destructuring of
        # either) are indistinguishable: the very same diagnostic.
        if {$shape in {project project-guess destructure}} {
            set M fzo$k
            set real [compileSource "import $M\nq = ${M}::make_Pt(1, 2)\nq.x\n"]
            set guess [compileSource "import $M\nq = ${M}::make_Pt(1, 2)\nq.[pick {zzz guess y_ nothing_here}]\n"]
            set realD [compileSource "import $M\nq = ${M}::make_Pt(1, 2)\n{y} = q\ny\n"]
            set guessD [compileSource "import $M\nq = ${M}::make_Pt(1, 2)\n{[pick {zzz guess}]} = q\n1\n"]
            if {$real ne $guess || [lindex $real 2] ne [lindex $realD 2] || [lindex $real 2] ne [lindex $guessD 2]} {
                incr messageLeaks
                puts "MESSAGE LEAK seed $seed: a real field, a guessed field and a destructuring differ:\n  $real\n  $guess\n  $realD\n  $guessD"
            }
        }
        if {$twinKind ne "skip"} {
            expr {srand($negSeed)}
            lassign [negativeProgram $shape [expr {$k + 1000000}] 0] twinSource _ _ _ _
            incr twins
            set twinGot [outcomeKind $twinSource]
            if {$twinGot ne $twinKind} {
                incr twinEscapes
                puts "TWIN ESCAPE seed $seed ($shape): the ordinary struct gave $twinGot, expected $twinKind\n$twinSource"
            }
        }
    }
} finally {
    file delete -force $scratch
}

puts "opaque-struct-fuzz programs $programs values $values negatives $negatives twins $twins differential-disagreements $differentialDisagreements oracle-disagreements $oracleDisagreements negative-escapes $negativeEscapes twin-escapes $twinEscapes diagnostic-set-escapes $diagnosticSetEscapes print-disagreements $printDisagreements message-leaks $messageLeaks backend-disagreements $backendDisagreements"
exit [expr {$differentialDisagreements || $oracleDisagreements || $negativeEscapes || $twinEscapes || $diagnosticSetEscapes || $printDisagreements || $messageLeaks || $backendDisagreements}]
