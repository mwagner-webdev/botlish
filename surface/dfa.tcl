# dfa.tcl -- declared finite-state recognizers (DFA-COROUTINE-MILESTONE-2.md):
# the meaning of `class` and `dfa` declarations, their checks, and their
# lowering to ordinary coroutine functions.
#
#   surface::dfa::expand STATEMENTS ?-own NS? ?-imports NSS? ?-registry REG?
#                        ?-open 0|1?
#       => {statements STATEMENTS registry REG referenceErrors ENTRIES
#           missingImport SPAN}
#   surface::dfa::Nodes NODE        => the syntax nodes of an expanded
#                                      `dfadecl` or `classdecl` (surface/lower.tcl)
#   surface::dfa::describe MODEL    => a recognizer's effective table, as text
#
# The parser reads the declarations (surface/parser.tcl's ClassDecl and
# DfaDecl); this file decides what they mean. The loader calls `expand` on
# each file once the modules it imports are loaded (surface/modules.tcl's
# CollectAndLoad), handing it what those modules declared (REG: namespace ->
# its classes and recognizers); `expand` annotates each declaration with its
# analysis -- or its diagnostics -- and surface/lower.tcl lowers it.
#
# A recognizer is an ordinary coroutine function (std::dfa, stdlib/dfa.bot):
#
#   nomethod fn NAME(first: int, resume std::dfa::Symbol) -> int errors E
#
# constructed with the token's first symbol and resumed with one
# std::dfa::Symbol per further symbol (code -1: the end of the input, never a
# symbol). Each yield answers 0 (taken, send the next); its completion returns
# how many of the actual symbols it was supplied are not part of the token
# (`accept` 0, `accept before N` N); a symbol no transition takes fails
# std::dfa::UnrecognizedInput, the end where nothing accepts
# std::dfa::UnexpectedEnd. E is exactly the errors a run can raise.
#
# The model (section 4 of the report). A recognizer is (S, Q, q0, d): S its
# alphabet, Q its states (and the anonymous states of its sequences), q0 the
# first, d(q, s) the action of state q on s for EVERY Int s -- a symbol, the
# end -1, or any value outside the alphabet. Symbol sets are finite unions of
# closed intervals and every set operation is exact interval arithmetic, so
# d is computed exactly: the *effective table*, one partition of the whole
# Int line per entered state. Actions: consume and continue in a state;
# accept leaving N unread; reject (implicitly: every symbol a state lists no
# transition for); call an earlier recognizer and continue (or accept with
# it). Every check reads the declaration or the effective table, never the
# generated code.
#
# Bounded lookahead. `accept before N` completes leaving the last N actual
# symbols supplied unread; the end of the input is never counted. N is
# bounded by what the recognizer has consumed (Bounds): in a state every path
# to which consumes at least K symbols, a transition on a symbol may leave
# N <= K unread (the token keeps at least that symbol's predecessor... at
# least one symbol), at the end N < K or N = 0 (a token is empty only when no
# symbol was supplied at all). So a recognizer never hands back a symbol it
# was not given, a token is never empty unless its input is, and every
# recognizer has a static maximum unread count -- the bound a driver's buffer
# needs. A call passes its callee's unread symbols on only through `then
# accept`: continuing in a state, the caller can reconsider the current
# symbol (or the end) but holds no earlier one (CallLookahead).
#
# The lowering (section 8). Each recognizer becomes three ordinary functions
# whose names no source can spell (a `#`), all `nomethod`:
#
#   NAME#run(state, c, resume std::dfa::Symbol) -> int   one step and the rest
#       next = dfa#transition(state, c, TABLE)    -- the whole table, one call
#       target = if next < N: next else: <complete, call or reject>
#       m = yield 0
#       NAME#run(target, m.code)                  -- a self tail call: a loop
#   NAME#state(code) -> str, NAME#recognizer(code) -> str
#       a rejection's payload (only for a recognizer with several)
#   NAME(first, resume std::dfa::Symbol) -> int     the recognizer itself
#
# dfa#transition (core/dfa.tcl) is the compact form of the effective table:
# one internal root native call whose constant operand is the table, so the
# front end sees a handful of nodes per recognizer instead of a decision tree
# per state, and native lowering chooses the dispatch (a multiway branch or a
# table load: native/lower.tcl's DfaTransition). NAME#run's result is an Int:
# -2 (completed, every symbol taken), c (completed with the current symbol c
# unread, or at the end -- c is -1 -- with nothing unread: what a caller can
# reconsider), or -2 - U (completed with U unread, which only `then accept`
# passes on). `lowering tree` (below) writes the decision tree instead, for
# measurements only.

namespace eval surface::dfa {
    # The Int line beyond every symbol: segment bounds, never emitted.
    variable MIN -1000000000000000000000
    variable MAX 1000000000000000000000
    variable END -1
    # compact (the default): the effective table as one dfa#transition call;
    # tree: as nested `if`s over the state and the symbol, the exploration's
    # lowering, kept to measure the two against each other
    # (bench/dfa.tcl). A front-end input: surface::cache::Key holds it.
    variable lowering compact
    # The std::dfa declarations a recognizer is written in terms of.
    variable symbolType std::dfa::Symbol
    variable unrecognized std::dfa::UnrecognizedInput
    variable unexpectedEnd std::dfa::UnexpectedEnd
    variable protocolNamespace std::dfa
}

# ---------------------------------------------------------------------------
# Interval sets: sorted, disjoint, non-adjacent closed intervals {lo hi}.

proc surface::dfa::Norm {intervals} {
    set sorted [lsort -command {apply {{a b} {
        set d [expr {[lindex $a 0] - [lindex $b 0]}]
        expr {$d < 0 ? -1 : ($d > 0 ? 1 : 0)}
    }}} [lmap i $intervals {if {[lindex $i 0] > [lindex $i 1]} continue; set i}]]
    set out {}
    foreach i $sorted {
        lassign $i lo hi
        if {[llength $out] && $lo <= [lindex $out end 1] + 1} {
            if {$hi > [lindex $out end 1]} {
                lset out end 1 $hi
            }
        } else {
            lappend out [list $lo $hi]
        }
    }
    return $out
}

proc surface::dfa::Union {a b} { return [Norm [concat $a $b]] }

proc surface::dfa::Inter {a b} {
    set out {}
    foreach x $a {
        lassign $x alo ahi
        foreach y $b {
            lassign $y blo bhi
            set lo [expr {max($alo, $blo)}]
            set hi [expr {min($ahi, $bhi)}]
            if {$lo <= $hi} {
                lappend out [list $lo $hi]
            }
        }
    }
    return [Norm $out]
}

proc surface::dfa::Minus {a b} {
    set out $a
    foreach y $b {
        lassign $y blo bhi
        set next {}
        foreach x $out {
            lassign $x lo hi
            if {$bhi < $lo || $blo > $hi} {
                lappend next $x
                continue
            }
            if {$lo < $blo} {
                lappend next [list $lo [expr {$blo - 1}]]
            }
            if {$hi > $bhi} {
                lappend next [list [expr {$bhi + 1}] $hi]
            }
        }
        set out $next
    }
    return [Norm $out]
}

proc surface::dfa::Universe {} {
    variable MIN
    variable MAX
    return [list [list $MIN $MAX]]
}

# The symbols of ALPHABET (bytes, ascii, unicode); the end is not one of them.
proc surface::dfa::AlphabetSet {alphabet} {
    switch -- $alphabet {
        ascii { return {{0 127}} }
        bytes { return {{0 255}} }
    }
    return {{0 55295} {57344 1114111}}
}

proc surface::dfa::AlphabetHull {alphabet} {
    return [dict get {ascii {0 127} bytes {0 255} unicode {0 1114111}} $alphabet]
}

# How symbol S of ALPHABET is shown in a message.
proc surface::dfa::Sym {s alphabet} {
    variable END
    if {$s == $END} {
        return end
    }
    if {$s >= 0x21 && $s <= 0x7E && $s != 0x27 && $s != 0x5C} {
        return '[format %c $s]'
    }
    switch -- $s {
        32 { return "' '" }
        39 { return {'\''} }
        92 { return {'\\'} }
        10 { return {'\n'} }
        13 { return {'\r'} }
        9 { return {'\t'} }
    }
    if {$s < 0 || $s > 0x10FFFF} {
        return $s
    }
    if {$alphabet eq "bytes"} {
        return [format 0x%02X $s]
    }
    return [format U+%04X $s]
}

proc surface::dfa::SetText {set alphabet {limit 6}} {
    variable MIN
    variable MAX
    set parts {}
    foreach i $set {
        lassign $i lo hi
        if {$lo == $MIN || $hi == $MAX} {
            lappend parts "every value outside the alphabet"
        } elseif {$lo == $hi} {
            lappend parts [Sym $lo $alphabet]
        } else {
            lappend parts "[Sym $lo $alphabet]..[Sym $hi $alphabet]"
        }
    }
    if {[llength $parts] > $limit} {
        set parts [list {*}[lrange $parts 0 [expr {$limit - 1}]] "... ([llength $parts] ranges)"]
    }
    return [join $parts " "]
}

# ---------------------------------------------------------------------------
# Diagnostics. Each is {kind KIND message TEXT span SPAN related {{TEXT
# SPAN}...}}: a compiler diagnostic of kind KIND (DFA-...) at SPAN, the
# further locations it is about in RELATED. They are reported as resolution
# diagnostics of the declaration's own unit (surface/lower.tcl lowers a
# rejected declaration to holes carrying them, hir/resolve.tcl's
# ResolveHole), so code that uses a rejected recognizer is dependent and
# says nothing more (DIAGNOSTIC-RECOVERY.md).

proc surface::dfa::Diag {kind span message {related {}}} {
    variable diagnostics
    lappend diagnostics [dict create kind $kind span $span message $message related $related]
}

# ---------------------------------------------------------------------------
# Classes

# The class item ITEM's {NS NAME} key in the file of namespace OWN: a bare
# name is the file's own (OWN), a qualified one its namespace's.
proc surface::dfa::ClassKey {item own} {
    if {[dict get $item namespace] eq ""} {
        return [list $own [dict get $item name]]
    }
    return [list [dict get $item namespace] [dict get $item name]]
}

proc surface::dfa::KeyText {key} {
    lassign $key ns name
    if {$ns eq ""} {
        return $name
    }
    return ${ns}::$name
}

# A *class value*: {set S any A anyExcept M chars C}, the symbols S and, when
# A, every symbol of the alphabet but M -- `any` is the alphabet of whichever
# recognizer reads the class, so a class is resolved without one and made
# concrete where it is used (UseSet). C are the values of S written as
# character literals (a bytes recognizer must not take one for a byte).

proc surface::dfa::EmptyValue {} {
    return [dict create set {} any 0 anyExcept {} chars {}]
}

proc surface::dfa::ValueUnion {a b} {
    set any [expr {[dict get $a any] || [dict get $b any]}]
    if {[dict get $a any] && [dict get $b any]} {
        set except [Inter [dict get $a anyExcept] [dict get $b anyExcept]]
    } elseif {[dict get $a any]} {
        set except [Minus [dict get $a anyExcept] [dict get $b set]]
    } elseif {[dict get $b any]} {
        set except [Minus [dict get $b anyExcept] [dict get $a set]]
    } else {
        set except {}
    }
    return [dict create set [Union [dict get $a set] [dict get $b set]] any $any anyExcept $except \
        chars [Union [dict get $a chars] [dict get $b chars]]]
}

# Class value V without the symbols X (an interval set).
proc surface::dfa::ValueMinus {v x} {
    dict set v set [Minus [dict get $v set] $x]
    dict set v chars [Minus [dict get $v chars] $x]
    if {[dict get $v any]} {
        dict set v anyExcept [Union [dict get $v anyExcept] $x]
    }
    return $v
}

# The class value of ITEMS (no `end`, no sequence) in context CTX, LOCAL the
# recognizer's own classes (name -> info) or {} for the file's; "" (and the
# diagnostics) when an item does not resolve, "dependent" when one names a
# class that has diagnostics of its own. Every value is checked against the
# widest alphabet (unicode's hull) here; the recognizer's own alphabet is
# checked where the value is used (UseSet).
proc surface::dfa::ItemsSet {ctx items local} {
    set value [EmptyValue]
    set failed 0
    set dependent 0
    foreach item $items {
        set span [dict get $item span]
        switch -- [dict get $item kind] {
            sym {
                set lo [dict get $item lo]
                set hi [dict get $item hi]
                if {$hi < $lo} {
                    Diag DFA-EMPTY-RANGE $span "the range [dict get $item text] is empty: its end is below its start"
                    set failed 1
                    continue
                }
                if {$lo < 0 || $hi > 0x10FFFF} {
                    Diag DFA-ALPHABET $span "[dict get $item text] is outside every alphabet: a symbol is a byte (0..255), an ASCII code (0..127) or a Unicode scalar value (0..0x10FFFF)"
                    set failed 1
                    continue
                }
                set chars {}
                if {[dict get $item loKind] eq "char" || [dict get $item hiKind] eq "char"} {
                    set chars [list [list $lo $hi]]
                }
                set value [ValueUnion $value [dict create set [list [list $lo $hi]] any 0 anyExcept {} chars $chars]]
            }
            any {
                set value [ValueUnion $value [dict create set {} any 1 anyExcept {} chars {}]]
            }
            class {
                set info [ClassInfo $ctx $item $local]
                if {$info eq "dependent"} {
                    set dependent 1
                    continue
                }
                if {$info eq ""} {
                    set failed 1
                    continue
                }
                set value [ValueUnion $value [dict filter $info key set any anyExcept chars]]
            }
        }
    }
    if {$failed} {
        return ""
    }
    if {$dependent} {
        return dependent
    }
    return $value
}

# The info {span SPAN failed 0|1 set .. any .. anyExcept .. chars ..} of the
# class ITEM names, "" (and a diagnostic) when it names none, or "dependent"
# when the class it names has diagnostics of its own (or a malformed
# statement of the file may declare it, or its namespace is not imported:
# the loader reports that, MISSING-IMPORT).
proc surface::dfa::ClassInfo {ctx item local} {
    set name [dict get $item name]
    set span [dict get $item span]
    if {[dict get $item namespace] eq "" && [dict exists $local $name]} {
        set info [dict get $local $name]
    } else {
        set key [ClassKey $item [dict get $ctx own]]
        lassign $key ns
        set registry [dict get $ctx registry]
        if {$ns ne [dict get $ctx own] && $ns ni [dict get $ctx imports]} {
            variable references
            lappend references [list $ns [KeyText $key] $span class]
            return "dependent"
        }
        if {![dict exists $registry $ns classes $name]} {
            if {$ns eq [dict get $ctx own] && [dict get $ctx open]} {
                return "dependent"
            }
            if {$ns eq [dict get $ctx own] && [dict exists $ctx later $name]} {
                Diag DFA-UNKNOWN-CLASS $span "class $name is used before its declaration: a class is used only after it is declared" \
                    [list [list "class $name" [dict get $ctx later $name]]]
                return ""
            }
            Diag DFA-UNKNOWN-CLASS $span "unknown class [KeyText $key]"
            return ""
        }
        set info [dict get $registry $ns classes $name]
    }
    if {[dict get $info failed]} {
        return "dependent"
    }
    return $info
}

# The class declaration NODE resolved in CTX, LOCAL as ItemsSet's: its info
# (ClassInfo), `failed 1` when it does not resolve.
proc surface::dfa::ResolveClass {ctx node local} {
    set info [dict create span [dict get $node nameSpan] failed 1 set {} any 0 anyExcept {} chars {}]
    set items [ItemsSet $ctx [dict get $node items] $local]
    set except [ItemsSet $ctx [dict get $node except] $local]
    if {$items eq "" || $except eq ""} {
        return $info
    }
    if {$items eq "dependent" || $except eq "dependent"} {
        dict set info dependent 1
        return $info
    }
    if {[dict get $except any]} {
        Diag DFA-EMPTY-RANGE [dict get $node nameSpan] "class [dict get $node name] holds no symbol: it excepts `any`, the whole alphabet"
        return $info
    }
    set value [ValueMinus $items [dict get $except set]]
    if {![llength [dict get $value set]] && ![dict get $value any]} {
        Diag DFA-EMPTY-RANGE [dict get $node nameSpan] "class [dict get $node name] holds no symbol: everything it names, it also excepts"
        return $info
    }
    return [dict merge $info $value [dict create failed 0]]
}

# The class value VALUE as the symbols of recognizer D's alphabet, "" (and a
# diagnostic at SPAN, about WHAT) when it names a value outside the
# alphabet, a character a bytes recognizer must not take for a byte, or no
# symbol of it; RELATED the locations the diagnostic also names (the class a
# class item is).
proc surface::dfa::UseSet {d value span what {related {}}} {
    set alphabet [dict get $d alphabet]
    if {$alphabet eq "bytes"} {
        set bad [Inter [dict get $value chars] {{128 1114111}}]
        if {[llength $bad]} {
            Diag DFA-BYTE-CHARACTER $span "$what holds [SetText $bad unicode], written as characters, not bytes: a bytes recognizer reads UTF-8 code units, so only ASCII characters name one byte (write the bytes as numbers, or recognize over unicode)" $related
            return ""
        }
    }
    lassign [AlphabetHull $alphabet] hlo hhi
    set outside [Minus [dict get $value set] [list [list $hlo $hhi]]]
    if {[llength $outside]} {
        Diag DFA-ALPHABET $span "$what holds [SetText $outside unicode], outside the alphabet of [dict get $d name] ($alphabet: [Sym $hlo $alphabet]..[Sym $hhi $alphabet])" $related
        return ""
    }
    set result [Inter [dict get $value set] [AlphabetSet $alphabet]]
    if {[dict get $value any]} {
        set result [Union $result [Minus [AlphabetSet $alphabet] [dict get $value anyExcept]]]
    }
    if {![llength $result]} {
        if {[llength [dict get $value set]]} {
            Diag DFA-ALPHABET $span "$what holds no symbol of $alphabet: U+D800..U+DFFF are surrogate code points, never characters" $related
        } else {
            Diag DFA-EMPTY-RANGE $span "$what holds no symbol of $alphabet: everything it names, it also excepts" $related
        }
        return ""
    }
    return $result
}

# ---------------------------------------------------------------------------
# Recognizers: resolution

proc surface::dfa::Qualified {own name} {
    if {$own eq ""} {
        return $name
    }
    return ${own}::$name
}

# The location of transition T for a diagnostic: its symbols.
proc surface::dfa::TransitionSpan {t} {
    return [dict get $t itemsSpan]
}

# The dfa declaration NODE of the file of namespace OWN resolved in CTX: a
# recognizer D {name qualified own alphabet nameSpan span id classes states
# stateOrder ...} whose every transition has its symbol set `set` (and
# sequences their anonymous states, named STATE"PREFIX"), `failed 1` when a
# diagnostic was reported, `dependent 1` when it reads a class or calls a
# recognizer that has diagnostics of its own.
proc surface::dfa::ResolveDfa {ctx node} {
    variable END
    set own [dict get $ctx own]
    set name [dict get $node name]
    set d [dict create name $name qualified [Qualified $own $name] own $own \
        alphabet [dict get $node alphabet] nameSpan [dict get $node nameSpan] span [dict get $node span] \
        id [dict get $node id] failed 0 dependent 0 states [dict create] stateOrder {} callees [dict create]]
    set before [llength $::surface::dfa::diagnostics]
    if {[dict get $node alphabet] ni {ascii bytes unicode}} {
        Diag DFA-ALPHABET [dict get $node alphabetSpan] "unknown alphabet \"[dict get $node alphabet]\": a recognizer reads bytes (0..255), unicode (Unicode scalar values) or ascii (0..127, the same symbols in both)"
        dict set d failed 1
        return $d
    }
    # Its own classes, in order: each may use the earlier ones and the file's.
    set local [dict create]
    set localState [dict create]
    foreach c [dict get $node classes] {
        set cname [dict get $c name]
        if {[dict exists $local $cname]} {
            Diag DFA-DUPLICATE [dict get $c nameSpan] "class $cname is declared twice in $name" \
                [list [list "first declared" [dict get $local $cname span]]]
            continue
        }
        set info [ResolveClass $ctx $c $local]
        if {[dict exists $info dependent]} {
            dict set d dependent 1
        }
        dict set local $cname $info
    }
    # The states, their names first (a transition may name a later state).
    set states [dict create]
    set order {}
    foreach st [dict get $node states] {
        set sname [dict get $st name]
        if {[dict exists $states $sname]} {
            Diag DFA-DUPLICATE [dict get $st nameSpan] "state $sname is declared twice in $name" \
                [list [list "first declared" [dict get $states $sname nameSpan]]]
            continue
        }
        dict set states $sname [dict create nameSpan [dict get $st nameSpan] span [dict get $st span] \
            anon 0 transitions {} written [dict get $st transitions]]
        lappend order $sname
    }
    set out [dict create]
    set outOrder {}
    foreach sname $order {
        set st [dict get $states $sname]
        set ts {}
        # Anonymous states of this state's sequences: name -> transitions.
        set extra [dict create]
        foreach t [dict get $st written] {
            set items [dict get $t items]
            set itemsSpan [surface::ast::cover [dict get [lindex $items 0] span] [dict get [lindex $items end] span]]
            set base [dict create action [dict get $t action] span [dict get $t span] itemsSpan $itemsSpan \
                text [surface::ast::DfaItemsText $items] actionText [surface::ast::DfaActionText $t] \
                state $sname written 1]
            foreach field {target targetSpan unread unreadSpan callee calleeSpan then thenSpan} {
                if {[dict exists $t $field]} {
                    dict set base $field [dict get $t $field]
                }
            }
            if {[dict get [lindex $items 0] kind] eq "seq"} {
                set seq [lindex $items 0]
                set symbols [dict get $seq symbols]
                set value [dict create set {} any 0 anyExcept {} chars {}]
                set bad 0
                foreach s $symbols {
                    set v [dict create set [list [list $s $s]] any 0 anyExcept {} chars [list [list $s $s]]]
                    if {[UseSet $d $v [dict get $seq span] "the sequence [dict get $seq text]"] eq ""} {
                        set bad 1
                        break
                    }
                }
                if {$bad} {
                    continue
                }
                # One anonymous state per symbol after the first; a
                # sequence sharing a prefix with another of the state shares
                # its states (a trie), so "true" and "trap" are deterministic.
                set from $sname
                set read ""
                set n [llength $symbols]
                for {set k 0} {$k < $n} {incr k} {
                    set s [lindex $symbols $k]
                    append read [format %c $s]
                    set step [dict merge $base [dict create set [list [list $s $s]] anon [expr {$k > 0}] sequence 1]]
                    if {$k < $n - 1} {
                        set next "$sname\"$read\""
                        dict set step action goto
                        dict set step target $next
                        dict set step actionText "-> (\"$read\")"
                        foreach field {unread unreadSpan callee calleeSpan then thenSpan targetSpan} {
                            dict unset step $field
                        }
                        dict set step targetSpan [dict get $seq span]
                        dict set step prefix 1
                    }
                    if {$k == 0} {
                        set list $ts
                    } else {
                        set list [dict getdef $extra $from {}]
                    }
                    # A prefix step already made by an earlier sequence of the
                    # state is that step.
                    set shared 0
                    if {[dict exists $step prefix]} {
                        foreach other $list {
                            if {[dict exists $other prefix] && [dict get $other set] eq [dict get $step set]
                                    && [dict get $other target] eq [dict get $step target]} {
                                set shared 1
                            }
                        }
                    }
                    if {!$shared} {
                        if {$k == 0} {
                            lappend ts $step
                        } else {
                            dict lappend extra $from $step
                        }
                    }
                    if {$k < $n - 1} {
                        set from $next
                    }
                }
                continue
            }
            # Ordinary items: each made the alphabet's symbols where it is
            # written (a class's problem with this alphabet is reported here,
            # at its use, with the class's declaration related).
            set set {}
            set ok 1
            set hasEnd 0
            foreach item $items {
                switch -- [dict get $item kind] {
                    end {
                        set hasEnd 1
                        continue
                    }
                    sym - any {
                        set value [ItemsSet $ctx [list $item] $local]
                        set related {}
                        set what [dict get [dict create sym [dict getdef $item text ""] any any] [dict get $item kind]]
                    }
                    class {
                        set what "class [KeyText [list [dict get $item namespace] [dict get $item name]]]"
                        set related {}
                        set value [ClassInfo $ctx $item $local]
                        if {$value ni {"" dependent}} {
                            set related [list [list $what [dict get $value span]]]
                        }
                    }
                }
                if {$value eq ""} {
                    set ok 0
                    continue
                }
                if {$value eq "dependent"} {
                    dict set d dependent 1
                    set ok 0
                    continue
                }
                set concrete [UseSet $d $value [dict get $item span] $what $related]
                if {$concrete eq ""} {
                    set ok 0
                    continue
                }
                set set [Union $set $concrete]
            }
            if {!$ok} {
                continue
            }
            if {$hasEnd} {
                if {[dict get $t action] in {goto call}} {
                    Diag DFA-END-CONSUMED $itemsSpan "the end of the input cannot be consumed: `end` may only accept or reject (\"end -> accept\", \"end -> accept before N\", \"end -> reject\")"
                    continue
                }
                set set [Union $set [list [list $END $END]]]
            }
            lappend ts [dict merge $base [dict create set $set anon 0]]
        }
        dict set out $sname [dict create nameSpan [dict get $st nameSpan] span [dict get $st span] anon 0 transitions $ts]
        lappend outOrder $sname
        foreach anonName [dict keys $extra] {
            set steps [dict get $extra $anonName]
            dict set out $anonName [dict create nameSpan [dict get [lindex $steps 0] itemsSpan] \
                span [dict get [lindex $steps 0] itemsSpan] anon 1 transitions $steps]
            lappend outOrder $anonName
        }
    }
    dict set d states $out
    dict set d stateOrder $outOrder
    dict set d localClasses $local
    set d [ResolveNames $ctx $d]
    CheckDeterminism $d
    if {[llength $::surface::dfa::diagnostics] > $before} {
        dict set d failed 1
    }
    return $d
}

# D with every goto target checked and every call's callee resolved (`key`:
# {NS NAME} of the callee in REG, `info` its info).
proc surface::dfa::ResolveNames {ctx d} {
    set registry [dict get $ctx registry]
    set own [dict get $ctx own]
    foreach q [dict get $d stateOrder] {
        set kept {}
        foreach t [dict get $d states $q transitions] {
            set good 1
            switch -- [dict get $t action] {
                goto {
                    if {![dict exists $d states [dict get $t target]]} {
                        Diag DFA-UNKNOWN-STATE [dict get $t targetSpan] "unknown state [dict get $t target] in [dict get $d name]"
                        set good 0
                    }
                }
                call {
                    lassign [dict get $t callee] ns cname rooted
                    set span [dict get $t calleeSpan]
                    set key [list [if {$ns eq ""} {set own} else {set ns}] $cname]
                    set keyNs [lindex $key 0]
                    if {$ns eq "" && $cname eq [dict get $d name]} {
                        Diag DFA-RECURSIVE-CALL $span "[dict get $d name] calls itself: a recognizer that calls itself needs a stack of unbounded depth, which no finite-state recognizer has (write the nesting in ordinary code with an explicit, bounded stack)"
                        set good 0
                    } elseif {$keyNs ne $own && $keyNs ni [dict get $ctx imports]} {
                        variable references
                        lappend references [list $keyNs [KeyText $key] $span dfa]
                        dict set d dependent 1
                        set good 0
                    } elseif {![dict exists $registry $keyNs dfas $cname]} {
                        if {$keyNs eq $own && [dict get $ctx open]} {
                            dict set d dependent 1
                        } elseif {$keyNs eq $own && [dict exists $ctx laterDfas $cname]} {
                            Diag DFA-UNKNOWN-DFA $span "[dict get $d name] calls $cname, which is declared after it: a recognizer calls only recognizers declared before it (so no call can recur)" \
                                [list [list "dfa $cname" [dict get $ctx laterDfas $cname]]]
                        } else {
                            Diag DFA-UNKNOWN-DFA $span "unknown recognizer [KeyText $key]"
                        }
                        set good 0
                    } else {
                        set info [dict get $registry $keyNs dfas $cname]
                        if {[dict get $info failed]} {
                            # The callee has diagnostics of its own: this
                            # recognizer is not analyzed further.
                            dict set d dependent 1
                            set good 0
                        } elseif {[dict get $info alphabet] ni [list ascii [dict get $d alphabet]]} {
                            Diag DFA-CALL-ALPHABET $span "[dict get $d name] reads [dict get $d alphabet] but [KeyText $key] reads [dict get $info alphabet]: a call hands the callee the caller's symbols, so the callee reads the same alphabet or ascii (whose symbols mean the same in every alphabet)" \
                                [list [list "dfa [KeyText $key]" [dict get $info nameSpan]]]
                            set good 0
                        } else {
                            dict set t key $key
                            dict set t info $info
                            dict set d callees $key $info
                        }
                    }
                    if {$good && [dict get $t then] ne "accept" && ![dict exists $d states [dict get $t then]]} {
                        Diag DFA-UNKNOWN-STATE [dict get $t thenSpan] "unknown state [dict get $t then] in [dict get $d name]"
                        set good 0
                    }
                }
            }
            if {$good} {
                lappend kept $t
            }
        }
        dict set d states $q transitions $kept
    }
    return $d
}

# Determinism: within each state, transitions claim disjoint symbols.
proc surface::dfa::CheckDeterminism {d} {
    set alphabet [dict get $d alphabet]
    foreach name [dict get $d stateOrder] {
        set ts [dict get $d states $name transitions]
        set n [llength $ts]
        for {set i 0} {$i < $n} {incr i} {
            for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
                set a [lindex $ts $i]
                set b [lindex $ts $j]
                set both [Inter [dict get $a set] [dict get $b set]]
                if {[llength $both]} {
                    set where [StateText $d $name]
                    Diag DFA-AMBIGUOUS-TRANSITION [TransitionSpan $b] \
                        "two transitions of $where claim [SetText $both $alphabet]: a recognizer takes at most one transition per symbol" \
                        [list [list "[dict get $a text] -> [ActionWords $a]" [TransitionSpan $a]] \
                            [list "[dict get $b text] -> [ActionWords $b]" [TransitionSpan $b]]]
                }
            }
        }
    }
}

# How state Q of D is named in a message (an anonymous state by its
# sequence's prefix).
proc surface::dfa::StateText {d q} {
    if {[dict get $d states $q anon]} {
        return "the state after [string range $q [string first \" $q] end] in [dict get $d name]"
    }
    return "state $q in [dict get $d name]"
}

proc surface::dfa::ActionWords {t} {
    return [string trimleft [dict get $t actionText] "-> "]
}

# ---------------------------------------------------------------------------
# Recognizers: the effective table and the checks that read it

# The effective partition of state Q of D: a list of {SET ACTION} covering
# the whole Int line. ACTION is
#
#   {goto S}            consume, continue in S
#   {accept N}          complete, the last N actual symbols supplied unread
#   {reject R S}        fail: the state S of recognizer R (qualified)
#   {call KEY then T}   hand the symbol to the recognizer KEY, then continue
#                       in T (or complete with it: T is accept)
#
# A call's symbols the callee rejects at once are that rejection: its start
# state's (the callee never completes before its first symbol: Bounds).
# Written transitions record their segments in RESOLVEDVAR ("Q/K" -> segs).
proc surface::dfa::Effective {d q resolvedVar} {
    upvar 1 $resolvedVar resolved
    set out {}
    set covered {}
    set ts [dict get $d states $q transitions]
    for {set k 0} {$k < [llength $ts]} {incr k} {
        set t [lindex $ts $k]
        set x [dict get $t set]
        set covered [Union $covered $x]
        set segs {}
        switch -- [dict get $t action] {
            goto { lappend segs [list $x [list goto [dict get $t target]]] }
            accept { lappend segs [list $x [list accept [dict get $t unread]]] }
            reject { lappend segs [list $x [list reject [dict get $d qualified] $q]] }
            call {
                set info [dict get $t info]
                foreach seg [dict get $info startPart] {
                    lassign $seg set a
                    set y [Inter $x $set]
                    if {![llength $y]} {
                        continue
                    }
                    if {[lindex $a 0] eq "takes"} {
                        lappend segs [list $y [list call [dict get $t key] then [dict get $t then]]]
                    } else {
                        lappend segs [list $y $a]
                    }
                }
            }
        }
        dict set resolved $q/$k $segs
        lappend out {*}$segs
    }
    set rest [Minus [Universe] $covered]
    if {[llength $rest]} {
        lappend out [list $rest [list reject [dict get $d qualified] $q implicit]]
    }
    return $out
}

# The info of the recognizer KEY ({NS NAME}) recognizer D calls.
proc surface::dfa::CalleeOf {d key} {
    return [dict get $d callees $key]
}

# D analyzed: `effective` (state -> partition), `entered` (the states that
# hold a state number: the start, and every state a consuming transition or
# a call continues in), `distance` (state -> the fewest symbols any path to
# it consumes), and the facts its callers and drivers read (Export). Reports
# the checks of section 4 that read the effective table.
proc surface::dfa::Analyze {d} {
    variable END
    set alphabet [dict get $d alphabet]
    set resolved [dict create]
    set effective [dict create]
    foreach q [dict get $d stateOrder] {
        dict set effective $q [Effective $d $q resolved]
    }
    set start [lindex [dict get $d stateOrder] 0]
    # Entered states.
    set entered [list $start]
    set work [list $start]
    while {[llength $work]} {
        set work [lassign $work q]
        foreach seg [dict get $effective $q] {
            set a [lindex $seg 1]
            set next ""
            if {[lindex $a 0] eq "goto"} {
                set next [lindex $a 1]
            } elseif {[lindex $a 0] eq "call" && [lindex $a 3] ne "accept"} {
                set next [lindex $a 3]
            }
            if {$next ne "" && $next ni $entered} {
                lappend entered $next
                lappend work $next
            }
        }
    }
    # Written reachability: every state a written transition names, from the
    # start.
    set reached [list $start]
    set work [list $start]
    while {[llength $work]} {
        set work [lassign $work q]
        foreach t [dict get $d states $q transitions] {
            foreach next [list [dict getdef $t target ""] [dict getdef $t then ""]] {
                if {$next ne "" && $next ne "accept" && $next ni $reached && [dict exists $d states $next]} {
                    lappend reached $next
                    lappend work $next
                }
            }
        }
    }
    foreach q [dict get $d stateOrder] {
        if {$q ni $reached && ![dict get $d states $q anon]} {
            Diag DFA-UNREACHABLE-STATE [dict get $d states $q nameSpan] \
                "state $q of [dict get $d name] is never reached: no transition from the start state leads to it"
        }
    }
    # Acceptance: which states can still lead to a completion.
    set canAccept [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        foreach q [dict get $d stateOrder] {
            if {[dict exists $canAccept $q]} {
                continue
            }
            foreach seg [dict get $effective $q] {
                set a [lindex $seg 1]
                set yes 0
                switch -- [lindex $a 0] {
                    accept { set yes 1 }
                    goto { set yes [dict exists $canAccept [lindex $a 1]] }
                    call {
                        set yes [expr {[lindex $a 3] eq "accept" || [dict exists $canAccept [lindex $a 3]]}]
                    }
                }
                if {$yes} {
                    dict set canAccept $q 1
                    set changed 1
                    break
                }
            }
        }
    }
    foreach q [dict get $d stateOrder] {
        if {$q in $reached && ![dict exists $canAccept $q]} {
            if {$q eq $start} {
                set what "[dict get $d name] accepts no input at all"
            } else {
                set what "from [StateText $d $q] no input is ever accepted"
            }
            Diag DFA-NO-ACCEPT [dict get $d states $q nameSpan] \
                "$what: every path from it ends in a rejection (add the transition that accepts, or remove the state)"
        }
    }
    # Calls that can only reject.
    foreach q [dict get $d stateOrder] {
        set ts [dict get $d states $q transitions]
        for {set k 0} {$k < [llength $ts]} {incr k} {
            set t [lindex $ts $k]
            if {[dict get $t action] ne "call"} {
                continue
            }
            set segs [dict getdef $resolved $q/$k {}]
            if {[llength $segs] && [llength [lmap s $segs {expr {[lindex $s 1 0] eq "reject" ? [continue] : $s}}]] == 0} {
                Diag DFA-DEAD-TRANSITION [TransitionSpan $t] \
                    "this transition of [StateText $d $q] can never succeed: [KeyText [dict get $t key]] rejects every symbol it hands over ([SetText [dict get $t set] $alphabet])" \
                    [list [list "dfa [KeyText [dict get $t key]]" [dict get $t info nameSpan]]]
            }
        }
    }
    # A state that completes before a symbol says what the end means.
    foreach q [dict get $d stateOrder] {
        set before 0
        set saysEnd 0
        foreach t [dict get $d states $q transitions] {
            if {[dict get $t action] eq "accept" && [dict get $t unread] > 0
                    && [llength [Minus [dict get $t set] [list [list $END $END]]]]} {
                set before 1
            }
            if {[llength [Inter [dict get $t set] [list [list $END $END]]]]} {
                set saysEnd 1
            }
        }
        if {$before && !$saysEnd} {
            Diag DFA-MISSING-END [dict get $d states $q nameSpan] \
                "[StateText $d $q] accepts before a symbol but does not say what the end of the input means: write \"end -> accept\" (the input may end here), \"end -> accept before N\" or \"end -> reject\""
        }
    }
    # The fewest symbols a path to each entered state consumes: a consuming
    # transition one, a call its callee's shortest token.
    set distance [dict create $start 0]
    set changed 1
    while {$changed} {
        set changed 0
        foreach q $entered {
            if {![dict exists $distance $q]} {
                continue
            }
            set k [dict get $distance $q]
            foreach seg [dict get $effective $q] {
                set a [lindex $seg 1]
                switch -- [lindex $a 0] {
                    goto { set next [lindex $a 1]; set w 1 }
                    call {
                        if {[lindex $a 3] eq "accept"} {
                            continue
                        }
                        set next [lindex $a 3]
                        set w [dict get [CalleeOf $d [lindex $a 1]] minTake]
                    }
                    default { continue }
                }
                if {![dict exists $distance $next] || $k + $w < [dict get $distance $next]} {
                    dict set distance $next [expr {$k + $w}]
                    set changed 1
                }
            }
        }
    }
    dict set d effective $effective
    dict set d entered $entered
    dict set d distance $distance
    dict set d reached $reached
    Bounds $d
    CallLookahead $d
    return [Facts $d]
}

# Bounded lookahead: every `accept before N` of an entered state Q has been
# supplied enough symbols (the header's rule). DISTANCE(Q) is the fewest
# symbols any path to Q consumes: on a symbol, N <= DISTANCE(Q) keeps the
# symbol before... keeps at least the first symbol of the token; at the end
# (never counted), N < DISTANCE(Q), or N = 0.
proc surface::dfa::Bounds {d} {
    variable END
    foreach q [dict get $d entered] {
        set k [dict get $d distance $q]
        foreach t [dict get $d states $q transitions] {
            if {[dict get $t action] ne "accept" || [dict get $t unread] == 0} {
                continue
            }
            set n [dict get $t unread]
            set onSymbol [llength [Minus [dict get $t set] [list [list $END $END]]]]
            set atEnd [llength [Inter [dict get $t set] [list [list $END $END]]]]
            set span [if {[dict get $t unreadSpan] ne ""} {dict get $t unreadSpan} else {dict get $t span}]
            if {$onSymbol && $n > $k} {
                Diag DFA-UNREAD-BEYOND-INPUT $span \
                    "\"accept before $n\" leaves $n symbols unread, but [StateText $d $q] is reached after consuming as few as $k: a recognizer gives back only symbols of its own input, and its token keeps at least one, so on a symbol it leaves at most $k unread here"
            } elseif {$atEnd && $n >= $k} {
                Diag DFA-UNREAD-BEYOND-INPUT $span \
                    "\"end -> accept before $n\" leaves $n symbols unread, but [StateText $d $q] is reached after consuming as few as $k: the end of the input is no symbol, and a token keeps at least one, so at the end it leaves at most [expr {max(0, $k - 1)}] unread here"
            }
        }
    }
}

# A call that continues in a state reconsiders what its callee left unread
# in that state, and the caller holds only the current symbol (or the end):
# its callee may leave nothing else unread. `then accept` passes any count
# on.
proc surface::dfa::CallLookahead {d} {
    foreach q [dict get $d entered] {
        foreach t [dict get $d states $q transitions] {
            if {[dict get $t action] ne "call" || [dict get $t then] eq "accept"} {
                continue
            }
            set info [dict get $t info]
            if {![dict get $info reconsider]} {
                Diag DFA-CALL-LOOKAHEAD [dict get $t calleeSpan] \
                    "[KeyText [dict get $t key]] can complete leaving [dict get $info leavesText] unread, but \"then [dict get $t then]\" can reconsider only the symbol it completes on (or the end): a recognizer keeps no input; write \"call [KeyText [dict get $t key]] then accept\", which passes the unread symbols on to the caller" \
                    [list [list "dfa [KeyText [dict get $t key]]" [dict get $info nameSpan]]]
            }
        }
    }
}

# D with the facts a caller, a driver and the lowering read: errors (the
# std::dfa errors a run can raise), returns (what its run function's result
# can be: taken -2, unread1 the current symbol, endc -1 at the end with
# nothing unread, more -2-U), maxUnread, minTake (the fewest symbols its
# token holds once it was handed a symbol: what a call consumes),
# reconsider (a caller continuing in a state can reconsider what it leaves),
# startPart (its start state's partition: takes, or the rejection).
proc surface::dfa::Facts {d} {
    variable END
    variable unrecognized
    variable unexpectedEnd
    set errors [list $unrecognized]
    set endFails 0
    set returns {}
    set maxUnread 0
    set leaves {}
    set start [lindex [dict get $d entered] 0]
    set minTake ""
    foreach q [dict get $d entered] {
        set k [dict get $d distance $q]
        foreach seg [dict get $d effective $q] {
            lassign $seg s a
            set isEnd [expr {[llength [Inter $s [list [list $END $END]]]] > 0}]
            set onSymbol [expr {[llength [Minus $s [list [list $END $END]]]] > 0}]
            switch -- [lindex $a 0] {
                reject {
                    if {$isEnd} {
                        set endFails 1
                    }
                }
                accept {
                    set n [lindex $a 1]
                    set maxUnread [expr {max($maxUnread, $n)}]
                    if {$onSymbol} {
                        lappend returns [lindex {taken unread1 more} [expr {min($n, 2)}]]
                        if {$n > 1} {
                            lappend leaves "$n symbols"
                        }
                        set take [expr {$k + 1 - $n}]
                        if {$minTake eq "" || $take < $minTake} {
                            set minTake $take
                        }
                    }
                    if {$isEnd} {
                        lappend returns [lindex {endc more} [expr {$n > 0}]]
                        if {$n > 0} {
                            lappend leaves "$n at the end of the input"
                        }
                        # (A callee never sees the end in its start state's
                        # first segment: it is handed a symbol first.)
                        if {$q ne $start || $k > 0} {
                            set take [expr {$k - $n}]
                            if {$minTake eq "" || $take < $minTake} {
                                set minTake $take
                            }
                        }
                    }
                }
                call {
                    set info [CalleeOf $d [lindex $a 1]]
                    if {$unexpectedEnd in [dict get $info errors]} {
                        set endFails 1
                    }
                    if {[lindex $a 3] eq "accept"} {
                        lappend returns {*}[dict get $info returns]
                        set maxUnread [expr {max($maxUnread, [dict get $info maxUnread])}]
                        if {![dict get $info reconsider]} {
                            lappend leaves [dict get $info leavesText]
                        }
                        set take [expr {$k + [dict get $info minTake]}]
                        if {$minTake eq "" || $take < $minTake} {
                            set minTake $take
                        }
                    }
                }
            }
        }
    }
    if {$endFails} {
        lappend errors $unexpectedEnd
    }
    if {$minTake eq "" || $minTake < 1} {
        # (Only a recognizer that accepts nothing has no completion; one that
        # completes on the end in its first state is handed a symbol before
        # it, as a callee.)
        set minTake 1
    }
    set returns [lsort -unique $returns]
    set startPart {}
    foreach seg [dict get $d effective $start] {
        lassign $seg s a
        if {[lindex $a 0] eq "reject"} {
            lappend startPart $seg
        } else {
            lappend startPart [list $s takes]
        }
    }
    dict set d errors $errors
    dict set d returns $returns
    dict set d maxUnread $maxUnread
    dict set d minTake $minTake
    dict set d reconsider [expr {"more" ni $returns}]
    dict set d leavesText [join [lsort -unique $leaves] ", or "]
    dict set d startPart $startPart
    return $d
}

# What a recognizer's callers read of it, kept in the registry.
proc surface::dfa::Export {d} {
    if {[dict get $d failed] || [dict get $d dependent]} {
        return [dict create failed 1 alphabet [dict get $d alphabet] nameSpan [dict get $d nameSpan]]
    }
    return [dict create failed 0 qualified [dict get $d qualified] own [dict get $d own] name [dict get $d name] \
        alphabet [dict get $d alphabet] nameSpan [dict get $d nameSpan] \
        errors [dict get $d errors] returns [dict get $d returns] maxUnread [dict get $d maxUnread] \
        minTake [dict get $d minTake] reconsider [dict get $d reconsider] leavesText [dict get $d leavesText] \
        startPart [dict get $d startPart]]
}

# ---------------------------------------------------------------------------
# The file's declarations

# STATEMENTS of a file (surface/parser.tcl's AST) with every `classdecl` and
# `dfadecl` annotated (the header's interface): `dfaModel` (an analyzed
# recognizer, Analyze) or `dfaDiagnostics` (the diagnostics it was rejected
# with) or `dfaDependent 1` (it reads a class or calls a recognizer that has
# diagnostics of its own, or a malformed statement may declare what it
# names: it says nothing more).
#
#   -own NS          the file's namespace ("" for the entry program)
#   -imports NSS     the namespaces the file imports
#   -registry REG    what the loaded modules declared: namespace ->
#                    {classes {NAME -> INFO} dfas {NAME -> INFO}}
#   -open 0|1        1 when a malformed top-level statement of the file may
#                    declare a class or a recognizer (syntax recovery)
#
# REG comes back with the file's own entries; referenceErrors are the
# loader's diagnostics of the qualified names the file may not make
# (MISSING-IMPORT); missingImport the span of the first recognizer when the
# file does not import std::dfa (the loader reports it).
proc surface::dfa::expand {statements args} {
    variable diagnostics
    variable references
    variable protocolNamespace
    set options [dict merge {-own "" -imports {} -registry {} -open 0} $args]
    set own [dict get $options -own]
    set registry [dict get $options -registry]
    dict set registry $own classes [dict create]
    dict set registry $own dfas [dict create]
    set later [dict create]
    set laterDfas [dict create]
    set any 0
    foreach s $statements {
        switch -- [dict get $s kind] {
            classdecl {
                if {![dict exists $later [dict get $s name]]} {
                    dict set later [dict get $s name] [dict get $s nameSpan]
                }
            }
            dfadecl {
                set any 1
                if {![dict exists $laterDfas [dict get $s name]]} {
                    dict set laterDfas [dict get $s name] [dict get $s nameSpan]
                }
            }
        }
    }
    set result [dict create statements $statements registry $registry referenceErrors {} missingImport ""]
    if {!$any && ![dict size $later]} {
        return $result
    }
    set references {}
    set out {}
    set seenClass [dict create]
    set seenDfa [dict create]
    foreach s $statements {
        set kind [dict get $s kind]
        if {$kind ni {classdecl dfadecl}} {
            lappend out $s
            continue
        }
        set diagnostics {}
        set ctx [dict create own $own imports [dict get $options -imports] registry $registry \
            open [dict get $options -open] later $later laterDfas $laterDfas]
        set name [dict get $s name]
        if {$kind eq "classdecl"} {
            if {[dict exists $seenClass $name]} {
                Diag DFA-DUPLICATE [dict get $s nameSpan] "class $name is declared twice" \
                    [list [list "first declared" [dict get $seenClass $name]]]
                dict set s dfaDiagnostics $diagnostics
                lappend out $s
                continue
            }
            dict set seenClass $name [dict get $s nameSpan]
            set info [ResolveClass $ctx $s {}]
            dict set registry $own classes $name $info
            if {$diagnostics ne {}} {
                dict set s dfaDiagnostics $diagnostics
            }
            lappend out $s
            continue
        }
        if {[dict exists $seenDfa $name]} {
            Diag DFA-DUPLICATE [dict get $s nameSpan] "dfa $name is declared twice" \
                [list [list "first declared" [dict get $seenDfa $name]]]
            dict set s dfaDiagnostics $diagnostics
            dict set s dfaDuplicate 1
            lappend out $s
            continue
        }
        dict set seenDfa $name [dict get $s nameSpan]
        set d [ResolveDfa $ctx $s]
        if {![dict get $d failed] && ![dict get $d dependent]} {
            set d [Analyze $d]
            if {$diagnostics ne {}} {
                dict set d failed 1
            }
        }
        dict set registry $own dfas $name [Export $d]
        if {$diagnostics ne {}} {
            dict set s dfaDiagnostics $diagnostics
        } elseif {[dict get $d dependent]} {
            dict set s dfaDependent 1
        } else {
            dict set s dfaModel $d
        }
        lappend out $s
    }
    set errors {}
    foreach ref $references {
        lassign $ref ns text span what
        set word [dict get {class class dfa recognizer} $what]
        lappend errors [dict create errorcode [list SURFACE MODULE MISSING-IMPORT] \
            message "[surface::ast::location $span]: namespace \"$ns\" is not imported; add `import $ns` to use the $word $text" \
            summary "namespace \"$ns\" is not imported; add `import $ns` to use the $word $text" \
            location $span related {}]
    }
    dict set result statements $out
    dict set result registry $registry
    dict set result referenceErrors $errors
    if {$any && $own ne $protocolNamespace && $protocolNamespace ni [dict get $options -imports]} {
        foreach s $statements {
            if {[dict get $s kind] eq "dfadecl"} {
                dict set result missingImport [dict get $s nameSpan]
                break
            }
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Lowering (the header's shape)

# The segments of PARTITION, sorted, the end a segment of its own.
proc surface::dfa::Segments {partition} {
    variable END
    set segs {}
    foreach seg $partition {
        lassign $seg set a
        foreach i $set {
            lassign $i lo hi
            if {$lo < $END && $hi >= $END} {
                lappend segs [list $lo [expr {$END - 1}] $a]
                set lo $END
            }
            if {$lo == $END && $hi > $END} {
                lappend segs [list $END $END $a]
                set lo [expr {$END + 1}]
            }
            lappend segs [list $lo $hi $a]
        }
    }
    return [lsort -command {apply {{a b} {
        set d [expr {[lindex $a 0] - [lindex $b 0]}]
        expr {$d < 0 ? -1 : ($d > 0 ? 1 : 0)}
    }}} $segs]
}

# The codes of D (the header's lowering): {numbers STATE->N leaves {LEAF...}
# rows {ROW...}} -- a state number per entered state, then one code per
# distinct leaf: the completions ({taken}, {returnc}, {more K}), the calls
# ({call KEY THEN}) and the rejections ({reject R S}), in that order, codes
# N.. in order; ROWS the table, one {DEFAULT SEGS} per entered state, SEGS
# {LO HI CODE} sorted, adjacent ones with one code merged, the default's
# dropped.
proc surface::dfa::Codes {d} {
    variable END
    set numbers [dict create]
    set k 0
    foreach q [dict get $d entered] {
        dict set numbers $q $k
        incr k
    }
    set completions {}
    set calls {}
    set rejects {}
    set leafSegs [dict create]
    set implicit [dict create]
    foreach q [dict get $d entered] {
        set segs {}
        foreach seg [Segments [dict get $d effective $q]] {
            lassign $seg lo hi a
            set isEnd [expr {$lo == $END && $hi == $END}]
            switch -- [lindex $a 0] {
                goto { set leaf [list state [dict get $numbers [lindex $a 1]]] }
                accept {
                    set n [lindex $a 1]
                    if {$isEnd && $n == 0} {
                        set leaf returnc
                    } elseif {$isEnd} {
                        set leaf [list more $n]
                    } else {
                        set leaf [lindex [list taken returnc [list more $n]] [expr {min($n, 2)}]]
                    }
                    if {$leaf ni $completions} {
                        lappend completions $leaf
                    }
                }
                call {
                    set leaf [list call [lindex $a 1] [lindex $a 3]]
                    if {$leaf ni $calls} {
                        lappend calls $leaf
                    }
                }
                reject {
                    set leaf [list reject [lindex $a 1] [lindex $a 2]]
                    if {$leaf ni $rejects} {
                        lappend rejects $leaf
                    }
                    if {[lindex $a 3] eq "implicit"} {
                        dict set implicit $q $leaf
                    }
                }
            }
            lappend segs [list $lo $hi $leaf]
        }
        dict set leafSegs $q $segs
    }
    # Completions in a canonical order: taken, returnc, then more by count.
    set ordered {}
    foreach c {taken returnc} {
        if {$c in $completions} {
            lappend ordered $c
        }
    }
    foreach c [lsort -integer -index 1 [lmap c $completions {if {[lindex $c 0] eq "more"} {set c} else continue}]] {
        lappend ordered $c
    }
    set leaves [concat $ordered $calls $rejects]
    set codeOf [dict create]
    set code [dict size $numbers]
    foreach leaf $leaves {
        dict set codeOf $leaf $code
        incr code
    }
    set rows {}
    foreach q [dict get $d entered] {
        set default [dict get $codeOf [dict get $implicit $q]]
        set out {}
        foreach seg [dict get $leafSegs $q] {
            lassign $seg lo hi leaf
            set c [if {[lindex $leaf 0] eq "state"} {lindex $leaf 1} else {dict get $codeOf $leaf}]
            if {$c == $default} {
                continue
            }
            if {[llength $out] && [lindex $out end 2] == $c && [lindex $out end 1] + 1 == $lo} {
                lset out end 1 $hi
            } else {
                lappend out [list $lo $hi $c]
            }
        }
        lappend rows [list $default $out]
    }
    return [dict create numbers $numbers leaves $leaves codeOf $codeOf rows $rows]
}

# The dfa#transition table text of ROWS (core/dfa.tcl's format).
proc surface::dfa::TableText {rows} {
    return [lmap row $rows {
        lassign $row default segs
        list $default [lmap s $segs {lindex $s 0}] [lmap s $segs {lindex $s 1}] [lmap s $segs {lindex $s 2}]
    }]
}

# Syntax-node helpers: every node a recognizer lowers to has an origin in its
# declaration (ORIGIN; the declaration's name, where its source says what
# it is).
proc surface::dfa::Int {origin n} { return [hir::syntax::constNode $origin $n] }
proc surface::dfa::Str {origin s} {
    # (A String a declaration writes, never a literal of the program: the
    # one-character warning reads only literals, hir/warnings.tcl.)
    set node [hir::syntax::constNode $origin str $s]
    dict set node synthesized dfa
    return $node
}
proc surface::dfa::Ref {origin name} { return [hir::syntax::refNode $origin $name] }
proc surface::dfa::Op {origin op a b} {
    return [hir::syntax::withOperator [hir::syntax::withWritten [hir::syntax::callNode $origin \
        [hir::syntax::rootRef $origin $op] $a $b] operator] $op]
}
proc surface::dfa::Call {origin callee args} {
    return [hir::syntax::withWritten [hir::syntax::callNode $origin $callee {*}$args] function]
}
proc surface::dfa::If {origin condition then else} {
    return [hir::syntax::ifNode $origin $condition $origin $then $origin $else]
}

# A reference to the function NAME of recognizer KEY ({NS NAME}) from the file
# of namespace OWN.
proc surface::dfa::FunctionRef {origin own key suffix} {
    lassign $key ns name
    if {$ns eq $own} {
        return [Ref $origin $name$suffix]
    }
    set ref [hir::syntax::refNode $origin ${ns}::$name$suffix]
    dict set ref qualified [list $ns $name$suffix]
    return $ref
}

# A balanced search over VALUES (code -> value text, sorted by code) on the
# Int bound to NAME, each leaf the String constant of its value.
proc surface::dfa::NameTree {origin name codes values} {
    if {[llength $codes] == 1} {
        return [list [Str $origin [lindex $values 0]]]
    }
    set mid [expr {[llength $codes] / 2}]
    return [list [If $origin [Op $origin < [Ref $origin $name] [Int $origin [lindex $codes $mid]]] \
        [NameTree $origin $name [lrange $codes 0 $mid-1] [lrange $values 0 $mid-1]] \
        [NameTree $origin $name [lrange $codes $mid end] [lrange $values $mid end]]]]
}

# The tree lowering's search over SEGS ({LO HI CODE}, the whole Int line) on
# the symbol, and over the rows on the state (the exploration's form).
proc surface::dfa::SymbolTree {origin segs} {
    if {[llength $segs] == 1} {
        return [list [Int $origin [lindex $segs 0 2]]]
    }
    set mid [expr {[llength $segs] / 2}]
    return [list [If $origin [Op $origin < [Ref $origin c] [Int $origin [lindex $segs $mid 0]]] \
        [SymbolTree $origin [lrange $segs 0 $mid-1]] [SymbolTree $origin [lrange $segs $mid end]]]]
}

proc surface::dfa::StateTree {origin rows first} {
    if {[llength $rows] == 1} {
        variable MIN
        variable MAX
        lassign [lindex $rows 0] default segs
        # The row over the whole line: its gaps are the default.
        set full {}
        set at $MIN
        foreach s $segs {
            lassign $s lo hi c
            if {$lo > $at} {
                lappend full [list $at [expr {$lo - 1}] $default]
            }
            lappend full $s
            set at [expr {$hi + 1}]
        }
        if {$at <= $MAX} {
            lappend full [list $at $MAX $default]
        }
        return [SymbolTree $origin $full]
    }
    set mid [expr {[llength $rows] / 2}]
    return [list [If $origin [Op $origin < [Ref $origin state] [Int $origin [expr {$first + $mid}]]] \
        [StateTree $origin [lrange $rows 0 $mid-1] $first] [StateTree $origin [lrange $rows $mid end] [expr {$first + $mid}]]]]
}

# The syntax nodes of an expanded declaration NODE (expand): a rejected one's
# diagnostics, as holes of its own unit; a recognizer's functions.
proc surface::dfa::Nodes {node} {
    set id [dict get $node id]
    set origin [surface::lower::Origin [dict get $node nameSpan] $id]
    if {[dict exists $node dfaDiagnostics]} {
        set holes {}
        set i 0
        foreach diag [dict get $node dfaDiagnostics] {
            set related [lmap r [dict get $diag related] {
                surface::lower::Origin [lindex $r 1] $id/related[incr i]
            }]
            set hole [hir::syntax::holeNode [surface::lower::Origin [dict get $diag span] $id/diagnostic[incr i]] 0]
            dict set hole hole report [list [dict get $diag kind] [dict get $diag message] $related]
            lappend holes $hole
        }
        if {[dict get $node kind] eq "classdecl" || [dict exists $node dfaDuplicate]} {
            return $holes
        }
        return [list [Stub $node $origin $holes]]
    }
    if {[dict exists $node dfaDependent]} {
        return [list [Stub $node $origin [list [hir::syntax::holeNode $origin 0]]]]
    }
    if {[dict get $node kind] eq "classdecl"} {
        return {}
    }
    return [Lower [dict get $node dfaModel] $origin]
}

# The recognizer NODE declares, whose body is BODY (holes): its signature is
# known, its code is not (hir/resolve.tcl's ResolveHole: its unit is
# tainted, and so is every unit that uses it).
proc surface::dfa::Stub {node origin body} {
    variable symbolType
    variable unrecognized
    variable unexpectedEnd
    set block [hir::syntax::blockNode $origin [list [list first $origin]] $body int int \
        [list [list $unrecognized $origin] [list $unexpectedEnd $origin]]]
    set block [hir::syntax::withResume [hir::syntax::withNoMethod $block] $symbolType $origin]
    return [hir::syntax::bindNode $origin [dict get $node name] $block]
}

# The functions of the analyzed recognizer D (the header's lowering).
proc surface::dfa::Lower {d origin} {
    variable symbolType
    variable unrecognized
    variable unexpectedEnd
    variable lowering
    variable END
    set name [dict get $d name]
    set own [dict get $d own]
    set codes [Codes $d]
    set n [dict size [dict get $codes numbers]]
    set errors [lmap e [dict get $d errors] {list $e $origin}]
    set run $name#run
    # Does any transition suspend (consume and continue, or call and
    # continue)?
    set suspends 0
    foreach q [dict get $d entered] {
        foreach seg [dict get $d effective $q] {
            set a [lindex $seg 1]
            if {[lindex $a 0] eq "goto" || ([lindex $a 0] eq "call" && [lindex $a 3] ne "accept")} {
                set suspends 1
            }
        }
    }
    set nodes {}
    # A rejection's payload: constants, or a search over the codes when the
    # recognizer has several.
    set rejectCodes {}
    set recognizers {}
    set states {}
    set endRejects 0
    foreach leaf [dict get $codes leaves] {
        if {[lindex $leaf 0] eq "reject"} {
            lappend rejectCodes [dict get $codes codeOf $leaf]
            lappend recognizers [lindex $leaf 1]
            lappend states [lindex $leaf 2]
        }
    }
    foreach q [dict get $d entered] {
        foreach seg [dict get $d effective $q] {
            lassign $seg s a
            if {[lindex $a 0] eq "reject" && [llength [Inter $s [list [list $END $END]]]]} {
                set endRejects 1
            }
        }
    }
    set payloads [dict create]
    foreach {field values suffix} [list recognizer $recognizers #recognizer state $states #state] {
        if {[llength [lsort -unique $values]] == 1} {
            dict set payloads $field [Str $origin [lindex $values 0]]
            continue
        }
        set block [hir::syntax::blockNode $origin [list [list code $origin]] \
            [NameTree $origin code $rejectCodes $values] str int]
        lappend nodes [hir::syntax::bindNode $origin $name$suffix [hir::syntax::withNoMethod $block]]
        dict set payloads $field [Call $origin [Ref $origin $name$suffix] [Ref $origin next]]
    }
    # The arms of the code chain: what a code at or above N does.
    set arms {}
    foreach leaf [dict get $codes leaves] {
        set code [dict get $codes codeOf $leaf]
        switch -- [lindex $leaf 0] {
            taken { set body [list [hir::syntax::returnNode $origin [Int $origin -2]]] }
            returnc { set body [list [hir::syntax::returnNode $origin [Ref $origin c]]] }
            more { set body [list [hir::syntax::returnNode $origin [Int $origin [expr {-2 - [lindex $leaf 1]}]]]] }
            call {
                lassign $leaf - key then
                set callee [Call $origin [FunctionRef $origin $own $key #run] [Int $origin 0] [Ref $origin c]]
                if {$then eq "accept"} {
                    set body [list [hir::syntax::returnNode $origin $callee]]
                } else {
                    set target [Int $origin [dict get $codes numbers $then]]
                    lassign $key ns cname
                    set info [CalleeOf $d $key]
                    if {[dict get $info returns] eq "taken"} {
                        # The callee always takes the symbol it completes
                        # on: continue in THEN, which waits for the next.
                        set body [list $callee $target]
                    } else {
                        # It may leave the current symbol (or the end): THEN
                        # reconsiders it, at once.
                        set body [list [hir::syntax::bindNode $origin r $callee] \
                            [If $origin [Op $origin == [Ref $origin r] [Int $origin -2]] [list $target] \
                                [list [hir::syntax::returnNode $origin \
                                    [Call $origin [Ref $origin $run] [Int $origin [dict get $codes numbers $then]] [Ref $origin r]]]]]]
                    }
                }
            }
            reject { continue }
        }
        lappend arms [list $code $body]
    }
    # The rejections: every remaining code.
    set reject {}
    if {$rejectCodes ne {}} {
        if {$endRejects} {
            lappend reject [If $origin [Op $origin == [Ref $origin c] [Int $origin -1]] \
                [list [hir::syntax::failNode $origin $unexpectedEnd [Payload $origin $unexpectedEnd \
                    [list recognizer [dict get $payloads recognizer] state [dict get $payloads state]]]]] {}]
        }
        lappend reject [hir::syntax::failNode $origin $unrecognized [Payload $origin $unrecognized \
            [list recognizer [dict get $payloads recognizer] state [dict get $payloads state] symbol [Ref $origin c]]]]
    }
    set chain $reject
    foreach arm [lreverse $arms] {
        lassign $arm code body
        if {$chain eq {}} {
            set chain $body
        } else {
            set chain [list [If $origin [Op $origin == [Ref $origin next] [Int $origin $code]] $body $chain]]
        }
    }
    # next: the code of the state and the symbol.
    if {$lowering eq "tree"} {
        set next [lindex [StateTree $origin [dict get $codes rows] 0] 0]
    } else {
        set next [hir::syntax::callNode $origin [hir::syntax::rootRef $origin dfa#transition] \
            [Ref $origin state] [Ref $origin c] [Str $origin [TableText [dict get $codes rows]]]]
    }
    set body [list [hir::syntax::bindNode $origin next $next]]
    if {$suspends} {
        lappend body [hir::syntax::bindNode $origin target \
            [If $origin [Op $origin < [Ref $origin next] [Int $origin $n]] [list [Ref $origin next]] $chain]]
        lappend body [hir::syntax::bindNode $origin m [hir::syntax::callNode $origin \
            [hir::syntax::rootRef $origin [core::coroutines::yieldNative]] [Int $origin 0]]]
        lappend body [Call $origin [Ref $origin $run] [Ref $origin target] \
            [hir::syntax::projectNode $origin [Ref $origin m] code $origin]]
    } else {
        lappend body {*}$chain
    }
    set block [hir::syntax::blockNode $origin [list [list state $origin] [list c $origin]] $body int {int int} $errors]
    lappend nodes [hir::syntax::bindNode $origin $run \
        [hir::syntax::withResume [hir::syntax::withNoMethod $block] $symbolType $origin]]
    # The recognizer: its result is the number of symbols left unread.
    set returns [dict get $d returns]
    set first [Call $origin [Ref $origin $run] [Int $origin 0] [Ref $origin first]]
    if {"unread1" ni $returns && "more" ni $returns} {
        set body [list $first [Int $origin 0]]
    } else {
        set rest [list [Int $origin 0]]
        if {"more" in $returns} {
            set rest [list [If $origin [Op $origin < [Ref $origin r] [Int $origin -2]] \
                [list [Op $origin - [Int $origin -2] [Ref $origin r]]] $rest]]
        }
        if {"unread1" in $returns} {
            set rest [list [If $origin [Op $origin >= [Ref $origin r] [Int $origin 0]] [list [Int $origin 1]] $rest]]
        }
        set body [list [hir::syntax::bindNode $origin r $first] {*}$rest]
    }
    set block [hir::syntax::blockNode $origin [list [list first $origin]] $body int int $errors]
    lappend nodes [hir::syntax::bindNode $origin $name \
        [hir::syntax::withResume [hir::syntax::withNoMethod $block] $symbolType $origin]]
    return $nodes
}

# The payload of error NAME with FIELDS ({FIELD VALUE ...}).
proc surface::dfa::Payload {origin name fields} {
    set inits [lmap {field value} $fields {
        dict create name $field nameOrigin $origin origin $origin value $value
    }]
    set payload [hir::syntax::structNode $origin "" $inits]
    dict set payload payloadOf $name
    return $payload
}
