#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated payload-error programs against an independent model
# (ERROR-PAYLOADS.md).
#
#   tclsh9.0 audit/error-payloads/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                                ?-backends LIST? ?-gc-stress 0|1?
#
# Each program declares three to five errors: payload-free ones, payloads of
# one to three fields drawn from a pool whose names have fixed types (Ints, a
# String, a Bool, an enum, a struct, a nested struct, a List), always one
# *twin* -- a second error with exactly the first one's fields -- and every
# other program an affine error whose payload owns a coroutine. One raiser
# fails each error for one value of its selector `k` with a payload computed
# from `v`; errors reach a handler directly, through one or two declaring
# functions, through a generic `call(f, k, v)` (specialized), through a
# handled call that handles one other error itself, or translated
# by a handler that fails another payload error built from what it
# received. The driver is a List of 4..10 operations, each a function that
# makes one such call and observes what its handler received:
#
#   ignore      `on E:`                  the error's tag only
#   whole       `on E d:`                the whole payload, or one projection
#   fields      `on E {f, g: r}`         some fields, renamed or not, in any
#                                        order (partial destructuring)
#   nested      `on E {box: {n}}`, `{pair: {a, b: {n: m}}}`
#   translated  `on T {code, origin}`    a payload built by another handler
#   affine      the coroutine payload ignored (released), bound whole,
#               destructured and resumed, or partially destructured (the
#               stream released), directly or through a declaring function
#
# and each handler answers a List starting with its error's tag ("E1"...), so
# a handler run for the wrong identity shows. Handlers of one call are
# written in a random order.
#
# The model shares no code with the compiler or a runtime: a raised error is
# the pair (ErrorIdentity, PayloadValue), PayloadValue a pure named product of
# model values (ownership of the coroutine field is the one non-value: the
# model only knows a stream was moved into the payload, and that every
# coroutine the program makes is released by the end). Handler selection
# compares the identity only; a destructuring is projection by name. A value
# renders as the backends show it: an anonymous struct's fields sorted, a
# named struct's in declaration order.
#
# A third of the programs carry one fault and the diagnostic the model
# predicts: a missing payload (MISSING-ERROR-PAYLOAD), a payload on a
# payload-free error (UNEXPECTED-ERROR-PAYLOAD), a missing, unknown,
# duplicate or ill-typed payload field (MISSING-FIELD, UNKNOWN-FIELD,
# DUPLICATE-FIELD, TYPE), an unknown destructured field (UNKNOWN-FIELD), an
# Int field destructured as a struct (NOT-A-STRUCT), a stream used after it
# moved into a payload (USE-AFTER-MOVE), an unhandled declared error and a
# handler for the twin instead of the error raised (UNHANDLED-ERROR). A
# faulty program is compiled with -strict 0 and must report the predicted
# kind; a sound one must compile with no diagnostic at all.
#
# Every accepted program's value is compared on every backend of BACKENDS
# with the model's; the Tcl backends also report how many coroutines are
# still alive (0), and the native one how many it released (all of them)
# and swept (none). With -gc-stress 1 the native run is repeated with a
# collection at every allocation site.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 40 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]

proc LiveCoroutines {} {
    return [core::value::int [llength [info commands {::core::coroutines::co[0-9]*}]]]
}
if {"test_fz_live" ni [core::native::names]} {
    core::registerNative test_fz_live -arity 0 -impl LiveCoroutines
}

# ---------------------------------------------------------------------------
# Deterministic choices

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

proc Shuffle {list} {
    set out {}
    while {$list ne {}} {
        set i [Rand [llength $list]]
        lappend out [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $out
}

# ---------------------------------------------------------------------------
# The model
#
# A model value: {int N} | {str S} | {bool B} | {case C} (of enum Kind) |
# {box N} | {pair A N} | {list VALUES} | {payload {FIELD VALUE ...}} (an
# anonymous struct, a whole payload) | {tag T} (a handler's tag String).

proc Render {v} {
    switch -- [lindex $v 0] {
        int  { return [lindex $v 1] }
        str - tag { return "\"[lindex $v 1]\"" }
        bool { return [expr {[lindex $v 1] ? "true" : "false"}] }
        case { return "Kind::[lindex $v 1]" }
        box  { return "Box {n: [lindex $v 1]}" }
        pair { return "Pair {a: [lindex $v 1], b: Box {n: [lindex $v 2]}}" }
        list { return "\[[join [lmap x [lindex $v 1] {Render $x}] {, }]\]" }
        payload {
            set fields [lindex $v 1]
            return "{[join [lmap f [lsort [dict keys $fields]] {string cat $f ": " [Render [dict get $fields $f]]}] {, }]}"
        }
    }
    error "Render: $v"
}

# The field pool: NAME -> its declared type, and how the raiser computes it
# from v: {TYPE SOURCE}; the model's value of field NAME for v (FieldValue).
set ::fieldPool {
    code   {int "v * 2 + 1"}
    at     {int "v + 7"}
    uri    {str "\"/p\""}
    flag   {bool "v > 4"}
    kind   {Kind "Kind::B"}
    box    {Box "Box {n: v}"}
    pair   {Pair "Pair {a: v, b: Box {n: v + 1}}"}
    items  {List[int] "[v, 9]"}
}

proc FieldValue {name v} {
    switch -- $name {
        code  { return [list int [expr {$v * 2 + 1}]] }
        at    { return [list int [expr {$v + 7}]] }
        uri   { return {str /p} }
        flag  { return [list bool [expr {$v > 4}]] }
        kind  { return {case B} }
        box   { return [list box $v] }
        pair  { return [list pair $v [expr {$v + 1}]] }
        items { return [list list [list [list int $v] {int 9}]] }
    }
}

proc FieldType {name} {
    return [lindex [dict get $::fieldPool $name] 0]
}

proc FieldSource {name} {
    return [lindex [dict get $::fieldPool $name] 1]
}

# The model payload of error ERR (its declared fields) for v.
proc Payload {state err v} {
    set fields [dict create]
    foreach f [dict get $state errors $err] {
        dict set fields $f [FieldValue $f $v]
    }
    return $fields
}

# ---------------------------------------------------------------------------
# Declarations

# STATE: errors (NAME -> fields, in declaration order; {} payload-free; the
# raiser's errors E1.. in selector order k = 1..), twin (the twin's name),
# affine (1 if the program has the affine error), fault, lines (the driver's
# operation functions), ops (their names), expected (model observations).

proc Errors {} {
    set names [Shuffle [dict keys $::fieldPool]]
    set errors [dict create]
    set count [expr {2 + [Rand 3]}]
    for {set i 1} {$i <= $count} {incr i} {
        if {$i > 1 && [Rand 3] == 0} {
            dict set errors E$i {}
            continue
        }
        set n [expr {1 + [Rand 3]}]
        dict set errors E$i [lrange [Shuffle $names] 0 [expr {$n - 1}]]
    }
    if {[dict get $errors E1] eq {}} {
        dict set errors E1 [list [Pick $names]]
    }
    # The twin: exactly E1's fields, another identity.
    dict set errors E[expr {$count + 1}] [dict get $errors E1]
    return $errors
}

proc ErrorDecl {name fields} {
    if {$fields eq {}} {
        return "error $name\n\n"
    }
    set text "error $name:\n"
    foreach f $fields {
        append text "    $f: [FieldType $f]\n"
    }
    return "$text\n"
}

# The payload construction of error NAME (FIELDS) in written order ORDER.
proc Construction {name fields order} {
    if {$fields eq {}} {
        return "fail $name"
    }
    return "fail $name {[join [lmap f $order {string cat $f ": " [FieldSource $f]}] {, }]}"
}

proc Declarations {stateVar} {
    upvar 1 $stateVar state
    set errors [dict get $state errors]
    set names [dict keys $errors]
    set text "import list\nimport str\n"
    if {[dict get $state affine]} {
        append text "import coroutine\n"
    }
    append text "\nenum Kind:\n    A,\n    B,\n\nstruct Box:\n    n: int\n\nstruct Pair:\n    a: int\n    b: Box\n\n"
    foreach name [Shuffle $names] {
        set decl [ErrorDecl $name [dict get $errors $name]]
        if {[dict get $state fault] eq "duplicate-decl-field" && $name eq "E1"} {
            set f [lindex [dict get $errors E1] 0]
            set decl [string map [list "error E1:\n" "error E1:\n    $f: [FieldType $f]\n"] $decl]
        }
        append text $decl
    }
    append text "error T:\n    code: int\n    origin: str\n\n"
    if {[dict get $state affine]} {
        append text "struct Message:\n    value: int\n\nstruct Event:\n    value: int\n\n"
        append text "error AffE:\n    stream: Coroutine{args: \[Message\], return: Event}\n    bytesRead: int\n\n"
        append text "fn worker(seed: int, resume Message) -> Event:\n    message = yield Event {value: seed}\n    Event {value: message.value}\n\n"
        append text "fn make(seed: int) -> Coroutine{args: \[Message\], return: Event}:\n    coroutine {step} = worker(seed)\n    step\n\n"
        set payloadA "{stream: s, bytesRead: v}"
        if {[dict get $state fault] eq "use-after-move"} {
            set payloadA "{stream: s, bytesRead: use(s)}"
        }
        append text "fn use(s: Coroutine{args: \[Message\], return: Event}) -> int:\n    e = s(Message {value: 2})\n    e.value\n\n"
        append text "fn raiseA(k: int, v: int) -> int errors AffE:\n    s = make(v)\n    if k == 1:\n        fail AffE $payloadA\n    e = s(Message {value: v})\n    e.value\n\n"
        append text "fn midA(k: int, v: int) -> int errors AffE:\n    raiseA(k, v) + 1\n\n"
    }
    # The raiser: error Ek for k == k, else v.
    set all [join $names {, }]
    append text "fn raise(k: int, v: int) -> int errors $all:\n"
    set k 0
    foreach name $names {
        incr k
        set fields [dict get $errors $name]
        set line [Construction $name $fields [Shuffle $fields]]
        switch -- [dict get $state fault] {
            missing-payload {
                if {$name eq "E1"} { set line "fail E1" }
            }
            unexpected-payload {
                if {$fields eq {} && ![dict exists $state faultDone]} {
                    set line "fail $name {code: v}"
                    dict set state faultDone 1
                }
            }
            missing-field {
                if {$name eq "E1"} { set line [Construction E1 $fields [lrange $fields 1 end]] }
            }
            unknown-field {
                if {$name eq "E1"} { set line [string map [list "fail E1 \{" "fail E1 \{bogus: 1, "] [Construction E1 $fields $fields]] }
            }
            duplicate-field {
                if {$name eq "E1"} { set line [Construction E1 $fields [concat $fields [lrange $fields 0 0]]] }
            }
            wrong-type {
                if {$name eq "E1"} {
                    set f [lindex $fields 0]
                    set bad [expr {[FieldType $f] eq "str" ? "v" : "\"oops\""}]
                    set line "fail E1 {[join [lmap g $fields {expr {$g eq $f ? "$g: $bad" : "$g: [FieldSource $g]"}}] {, }]}"
                }
            }
        }
        append text "    if k == $k:\n        $line\n"
    }
    append text "    v\n\n"
    append text "fn mid(k: int, v: int) -> int errors $all:\n    raise(k, v) + 1\n\n"
    append text "fn mid2(k: int, v: int) -> int errors $all:\n    mid(k, v) * 2\n\n"
    append text "fn call(f, k, v):\n    f(k, v)\n\n"
    append text "fn generic(k: int, v: int) -> int errors $all:\n    call(raise, k, v)\n\n"
    # A handled call that handles one error itself and lets every other one
    # pass through it, identity and payload unchanged.
    append text "fn partial(k: int, v: int) -> int errors $all:\n    raise(k, v):\n        on [dict get $state local]:\n            v + 100\n\n"
    append text "fn only1(k: int, v: int) -> int errors E1:\n    if k == 1:\n        [Construction E1 [dict get $errors E1] [dict get $errors E1]]\n    v\n\n"
    # A translation: every error of raise becomes T.
    append text "fn translate(k: int, v: int) -> int errors T:\n    raise(k, v):\n"
    set k 0
    foreach name [Shuffle $names] {
        set fields [dict get $errors $name]
        set code [expr {[lsearch -exact $names $name] + 1}]
        if {$fields ne {} && [Rand 2]} {
            set f [lindex $fields 0]
            append text "        on $name {$f}:\n            fail T {code: $code, origin: \"$name\"}\n"
        } else {
            append text "        on $name:\n            fail T {origin: \"$name\", code: $code}\n"
        }
    }
    append text "\n"
    return $text
}

# ---------------------------------------------------------------------------
# Operations: each a function `opN(zero: int)` answering one observation.

# The receive form and the answer of a handler of ERR (FIELDS) whose payload
# is the model value PAYLOAD (a dict): {RECEIVE BODY MODEL}.
proc Receive {stateVar err fields payload} {
    upvar 1 $stateVar state
    set tag [list tag $err]
    if {$fields eq {} || [Rand 5] == 0} {
        return [list "" "return \[\"$err\"\]" [list list [list $tag]]]
    }
    switch -- [Rand 4] {
        0 {
            # Whole binding: the payload, or one projection.
            if {[Rand 2]} {
                return [list " d" "return \[\"$err\", d\]" [list list [list $tag [list payload $payload]]]]
            }
            set f [Pick $fields]
            return [list " d" "return \[\"$err\", d.$f\]" [list list [list $tag [dict get $payload $f]]]]
        }
        1 - 2 {
            # Some fields, renamed or not, in any order.
            set chosen [lrange [Shuffle $fields] 0 [Rand [llength $fields]]]
            set parts {}
            set answers {}
            set models [list $tag]
            foreach f $chosen {
                if {[Rand 2]} {
                    lappend parts "$f: r_$f"
                    lappend answers r_$f
                } else {
                    lappend parts $f
                    lappend answers $f
                }
                lappend models [dict get $payload $f]
            }
            if {[dict get $state fault] eq "unknown-destructured" && ![dict exists $state faultDone]} {
                lappend parts nosuch
                dict set state faultDone 1
            }
            return [list " {[join $parts {, }]}" "return \[\"$err\", [join $answers {, }]\]" [list list $models]]
        }
        3 {
            # Nested destructuring of a struct field, or a plain field.
            if {"pair" in $fields} {
                set p [dict get $payload pair]
                return [list " {pair: {a, b: {n: m}}}" "return \[\"$err\", a, m\]" \
                    [list list [list $tag [list int [lindex $p 1]] [list int [lindex $p 2]]]]]
            }
            if {"box" in $fields} {
                return [list " {box: {n}}" "return \[\"$err\", n\]" \
                    [list list [list $tag [list int [lindex [dict get $payload box] 1]]]]]
            }
            if {[dict get $state fault] eq "nested-shape" && ![dict exists $state faultDone]
                    && [set ints [lmap f $fields {expr {[FieldType $f] eq "int" ? $f : [continue]}}]] ne {}} {
                dict set state faultDone 1
                return [list " {[lindex $ints 0]: {n}}" "return \[\"$err\", n\]" {list {}}]
            }
            set f [Pick $fields]
            return [list " {$f}" "return \[\"$err\", $f\]" [list list [list $tag [dict get $payload $f]]]]
        }
    }
}

proc Operation {stateVar} {
    upvar 1 $stateVar state
    set n [llength [dict get $state ops]]
    set name op$n
    set errors [dict get $state errors]
    set names [dict keys $errors]
    set v [Rand 10]
    if {[dict get $state affine] && [Rand 3] == 0} {
        return [AffineOperation state $name $v]
    }
    set k [Rand [expr {[llength $names] + 1}]]
    set path [Pick {raise raise mid mid2 generic partial translate}]
    if {[dict get $state fault] eq "wrong-nominal" && ![dict exists $state faultDone]} {
        set path only1
    }
    set text "fn $name\(zero: int):\n    r = $path\(zero + $k, zero + $v):\n"
    # The model: what the call raises, or its value.
    set raised ""
    if {$k >= 1 && $k <= [llength $names]} {
        set raised [lindex $names [expr {$k - 1}]]
    }
    if {$path eq "only1" && $raised ne "E1"} {
        set raised ""
    }
    set local 0
    if {$path eq "partial" && $raised eq [dict get $state local]} {
        # Handled inside `partial`: its value.
        set raised ""
        set local 1
    }
    set result ""
    if {$path eq "translate"} {
        if {$raised ne ""} {
            set code [expr {[lsearch -exact $names $raised] + 1}]
            set result [list list [list {tag T} [list int $code] [list str $raised]]]
        }
        append text "        on T {code, origin}:\n            return \[\"T\", code, origin\]\n"
    } elseif {$path eq "only1"} {
        # The fault: the twin's handler instead of E1's.
        set twin [lindex $names end]
        append text "        on $twin:\n            return \[\"$twin\"\]\n"
        dict set state faultDone 1
    } else {
        set handled [Shuffle $names]
        # Any path, `generic`'s untyped callable parameter included (the
        # completion analysis charges what the callable passed through it
        # may raise: STATIC-COMPLETION-PROOFS.md, "Precision and the
        # erased-callable contract") -- except `partial`, where the error it
        # handles itself is no fault.
        if {[dict get $state fault] eq "unhandled" && ![dict exists $state faultDone]
                && !($path eq "partial" && [lindex $handled 0] eq [dict get $state local])} {
            set handled [lrange $handled 1 end]
            dict set state faultDone 1
            dict set state faultPath $path
        }
        foreach err $handled {
            set fields [dict get $errors $err]
            set payload [Payload $state $err $v]
            lassign [Receive state $err $fields $payload] receive body model
            append text "        on $err$receive:\n            $body\n"
            if {$err eq $raised} {
                set result $model
            }
        }
    }
    if {$result eq ""} {
        # The call completed: its value.
        set value $v
        switch -- $path {
            mid { incr value }
            mid2 { set value [expr {($v + 1) * 2}] }
            partial { if {$local} { set value [expr {$v + 100}] } }
        }
        set result [list int $value]
    }
    append text "    r\n\n"
    dict lappend state lines $text
    dict lappend state ops $name
    dict lappend state expected $result
}

# An operation on the affine error: the stream ignored, bound whole,
# destructured and resumed, or partially destructured.
proc AffineOperation {stateVar name v} {
    upvar 1 $stateVar state
    set k [Rand 2]
    set path [Pick {raiseA midA}]
    set text "fn $name\(zero: int):\n    r = $path\(zero + $k, zero + $v):\n"
    switch -- [Rand 4] {
        0 {
            append text "        on AffE:\n            return \[\"AffE\"\]\n"
            set model [list list {{tag AffE}}]
        }
        1 {
            append text "        on AffE d:\n            return \[\"AffE\", d.bytesRead\]\n"
            set model [list list [list {tag AffE} [list int $v]]]
        }
        2 {
            append text "        on AffE {stream, bytesRead: b}:\n            e = stream(Message {value: 100})\n            return \[\"AffE\", e.value + b\]\n"
            set model [list list [list {tag AffE} [list int [expr {100 + $v}]]]]
        }
        3 {
            append text "        on AffE {bytesRead}:\n            return \[\"AffE\", bytesRead\]\n"
            set model [list list [list {tag AffE} [list int $v]]]
        }
    }
    append text "    r\n\n"
    if {$k == 0} {
        set model [list int [expr {$path eq "midA" ? $v + 1 : $v}]]
    }
    dict lappend state lines $text
    dict lappend state ops $name
    dict lappend state expected $model
}

# The faults and the diagnostic each predicts.
set ::faults {
    missing-payload MISSING-ERROR-PAYLOAD
    unexpected-payload UNEXPECTED-ERROR-PAYLOAD
    missing-field MISSING-FIELD
    unknown-field UNKNOWN-FIELD
    duplicate-field DUPLICATE-FIELD
    duplicate-decl-field DUPLICATE-FIELD
    wrong-type TYPE
    unknown-destructured UNKNOWN-FIELD
    nested-shape NOT-A-STRUCT
    use-after-move USE-AFTER-MOVE
    unhandled UNHANDLED-ERROR
    wrong-nominal UNHANDLED-ERROR
}

# The program text of generation NUMBER and the model's expectation: {value
# RENDERED} or {error KIND}.
proc Program {number} {
    set state [dict create errors [Errors] affine [expr {$number % 2}] fault "" \
        lines {} ops {} expected {}]
    dict set state local [Pick [dict keys [dict get $state errors]]]
    if {[Rand 3] == 0} {
        set fault [Pick [dict keys $::faults]]
        set fields [dict get $state errors E1]
        # A fault applies only where its subject exists.
        set applicable [switch -- $fault {
            unexpected-payload { expr {{} in [dict values [dict get $state errors]]} }
            missing-field - duplicate-field { expr {[llength $fields] >= 2 || $fault eq "duplicate-field"} }
            use-after-move { dict get $state affine }
            nested-shape { expr {[lsearch -exact [lmap f [dict keys $::fieldPool] {FieldType $f}] int] >= 0} }
            default { expr 1 }
        }]
        if {$applicable} {
            dict set state fault $fault
        }
    }
    set count [expr {4 + [Rand 7]}]
    for {set i 0} {$i < $count} {incr i} {
        Operation state
    }
    if {[dict get $state fault] in {unknown-destructured nested-shape unhandled wrong-nominal}
            && ![dict exists $state faultDone]} {
        # The operations offered no place for it: a sound program after all.
        dict set state fault ""
    }
    set text [Declarations state]
    append text [join [dict get $state lines] ""]
    set observed [lmap op [dict get $state ops] {string cat $op "(zero)"}]
    append text "fn drive(zero: int):\n    \[[join $observed {, }], test_fz_live()\]\n\ndrive(0)\n"
    set where [expr {[dict exists $state faultPath] ? "[dict get $state fault]/[dict get $state faultPath]" : ""}]
    if {[dict get $state fault] ne ""} {
        return [list $text [list error [dict get $::faults [dict get $state fault]]] [dict get $state affine] $where]
    }
    set expected [concat [dict get $state expected] [list {int 0}]]
    return [list $text [list value [Render [list list $expected]]] [dict get $state affine] $where]
}

# ---------------------------------------------------------------------------

proc Run {} {
    global options
    set backends [dict get $options -backends]
    set accepted 0
    set rejected 0
    set codes [dict create]
    set disagreements 0
    set observations 0
    set faultPaths [dict create]
    set nativeOk [expr {$::tcl_platform(os) eq "Linux" && $::tcl_platform(machine) in {x86_64 amd64}}]
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set number [expr {[dict get $options -seed] + $p}]
        set ::seedState [expr {$number * 7919 + 17}]
        lassign [Program $number] text expect affine where
        if {$where ne ""} {
            dict incr faultPaths $where
        }
        if {[dict get $options -dump]} {
            puts "--- program $number\n$text--- expect $expect"
        }
        set problem ""
        if {[lindex $expect 0] eq "error"} {
            if {[catch {surface::compile $text -strict 0 -warnings off} hir errOptions]} {
                # A declaration error is raised at once, even with -strict 0.
                if {[lindex [dict get $errOptions -errorcode] end] eq [lindex $expect 1]} {
                    incr rejected
                    dict incr codes [lindex $expect 1]
                } else {
                    set problem "rejected outside HIR: $hir\noracle expects [lindex $expect 1]"
                }
            } else {
                set kinds [lsort -unique [lmap d [hir::diagnostics $hir] {dict get $d kind}]]
                if {[lindex $expect 1] ni $kinds} {
                    set problem "diagnostics {$kinds}; oracle expects [lindex $expect 1]"
                } else {
                    incr rejected
                    dict incr codes [lindex $expect 1]
                }
            }
        } elseif {[catch {surface::compile $text -warnings off} hir errOptions]} {
            set problem "rejected: [dict get $errOptions -errorcode] $hir"
        } else {
            foreach b $backends {
                if {$b in {interp compile}} {
                    set o [lrange [outcomeUnderHir $b $hir] 0 1]
                } else {
                    # The live-coroutine probe is a Tcl-runtime one: natively
                    # the counters below say the same.
                    set native [surface::compile [string map {"test_fz_live()" 0} $text] -warnings off]
                    set o [lrange [outcomeUnderHir $b $native] 0 1]
                }
                if {$o ne $expect} {
                    set problem "$b gives $o, oracle $expect"
                    break
                }
            }
            if {$problem eq "" && $affine && $nativeOk && "cranelift" in $backends} {
                set native [surface::compile [string map {"test_fz_live()" 0} $text] -warnings off]
                set report [native::allocationReport $native summary]
                if {[dict exists $report coroutines]} {
                    set c [dict get $report coroutines]
                    set made [expr {[dict get $c stacksMapped] + [dict get $c stacksReused]}]
                    if {[dict get $c sweptSuspended] != 0 || [dict get $c released] != $made} {
                        set problem "native coroutines: $c (every one released, none swept, expected)"
                    }
                }
            }
            if {$problem eq "" && [dict get $options -gc-stress] && $nativeOk} {
                set native [surface::compile [string map {"test_fz_live()" 0} $text] -warnings off]
                set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                try {
                    set o [lrange [outcomeUnderHir cranelift $native] 0 1]
                } finally {
                    unset ::env(BOTLISH_NATIVE_GC_STRESS)
                }
                if {$o ne $expect} {
                    set problem "cranelift under GC stress gives $o, oracle $expect"
                }
            }
            if {$problem eq ""} {
                incr accepted
                incr observations [regexp -all {\], } [lindex $expect 1]]
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n$problem\n--- program\n$text"
        }
    }
    puts "accepted $accepted rejected $rejected ([join [lmap {c n} [lsort -stride 2 [dict get $codes]] {string cat "$c $n"}] {, }])"
    puts "unhandled faults by path: [join [lmap {c n} [lsort -stride 2 $faultPaths] {string cat "[lindex [split $c /] 1] $n"}] {, }]"
    puts "programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

set status [Run]
exit [expr {$status > 0 ? 1 : 0}]
