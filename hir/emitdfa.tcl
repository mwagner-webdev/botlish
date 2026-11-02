# emitdfa.tcl -- declared recognizers stepped over sets of symbols, for the
# emission checker (EMISSION-CLAIMS-MILESTONE-1.md, "One DFA outcome model";
# hir/emission.tcl).
#
# The input is no declaration and no effective table: it is each
# recognizer's compiled table, which surface/dfa.tcl's Lower attaches to the
# recognizer's function (`recognizer`, hir::syntax::withRecognizer) beside
# the code it generated from the same table -- per state number a row
# {DEFAULT SEGS}, SEGS {LO HI CODE}, and the leaves the codes above the
# states stand for. A symbol set is partitioned exactly as the compiled
# dispatch partitions a symbol (core::dfa::Lookup: a value no segment holds,
# a bignum included, takes the row's default), and what each code means is
# core/dfa.tcl's one statement of it (core::dfa::Outcome, Resume, Unread):
# Lower compiles it for one symbol, StepBase and Complete apply it to sets.
#
# A composite state is {STACK KEY STATE ?OBLIGATIONS?}: recognizer KEY
# ({NS NAME}) in STATE, called from the frames of STACK ({KEY THEN}...,
# outermost first), or `done` (the outermost recognizer completed with
# nothing unread). OBLIGATIONS ({DEPTH KEY HELPER CALL}...) are boundary
# obligations (Step): the frame at DEPTH holds the token a helper claims to
# have emitted whole, so the next symbol must end it.

namespace eval hir::emission {
    # KEY -> {block numbers states rows leafOf n alphabet qualified
    # stateOrigins suspends fingerprint} (LoadRecognizers).
    variable recognizers [dict create]
    # qualified text -> KEY
    variable byQualified [dict create]
    # block ExprId -> KEY
    variable recognizerOf [dict create]
}

# Indexes the recognizers of HIR: every block carrying a recognizer table.
proc hir::emission::LoadRecognizers {hir} {
    variable recognizers
    variable byQualified
    variable recognizerOf
    set recognizers [dict create]
    set byQualified [dict create]
    set recognizerOf [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![dict exists $node recognizer]} continue
        set r [dict get $node recognizer]
        set key [dict get $r key]
        if {[dict exists $recognizers $key]} continue
        set states [dict create]
        dict for {q i} [dict get $r numbers] {
            dict set states $i $q
        }
        set n [dict size [dict get $r numbers]]
        set leafOf [dict create]
        set code $n
        foreach leaf [dict get $r leaves] {
            dict set leafOf $code $leaf
            incr code
        }
        dict set recognizers $key [dict create block $e numbers [dict get $r numbers] states $states \
            rows [dict get $r rows] leafOf $leafOf n $n alphabet [dict get $r alphabet] \
            qualified [dict get $r qualified] stateOrigins [dict get $r stateOrigins] \
            suspends [dict get $r suspends] \
            fingerprint [Digest [list [dict get $r alphabet] [dict get $r rows] [dict get $r leaves]]]]
        dict set byQualified [dict get $r qualified] $key
        dict set recognizerOf $e $key
    }
}

# A checksum of TEXT (hir::interchange's kind: crc32 and adler32 of its
# UTF-8).
proc hir::emission::Digest {text} {
    set bytes [encoding convertto utf-8 $text]
    return [format %08x%08x [zlib crc32 $bytes] [zlib adler32 $bytes]]
}

# The fingerprint of recognizer KEY and of every recognizer it calls,
# transitively: what a certificate's statement depends on of its grammar.
proc hir::emission::DeepFingerprint {key} {
    variable recognizers
    set seen [dict create]
    set work [list $key]
    while {[llength $work]} {
        set work [lassign $work k]
        if {[dict exists $seen $k]} continue
        if {![dict exists $recognizers $k]} {
            dict set seen $k missing
            continue
        }
        dict set seen $k [dict get $recognizers $k fingerprint]
        dict for {code leaf} [dict get $recognizers $k leafOf] {
            if {[lindex $leaf 0] eq "call"} {
                lappend work [lindex $leaf 1]
            }
        }
    }
    return [Digest [lsort -stride 2 -index 0 $seen]]
}

# 1 if recognizer KEY and every recognizer it calls have their tables.
proc hir::emission::Complete? {key} {
    variable recognizers
    set seen [dict create]
    set work [list $key]
    while {[llength $work]} {
        set work [lassign $work k]
        if {[dict exists $seen $k]} continue
        if {![dict exists $recognizers $k]} { return 0 }
        dict set seen $k 1
        dict for {code leaf} [dict get $recognizers $k leafOf] {
            if {[lindex $leaf 0] eq "call"} {
                lappend work [lindex $leaf 1]
            }
        }
    }
    return 1
}

proc hir::emission::HasRecognizer {key} {
    variable recognizers
    return [dict exists $recognizers $key]
}

proc hir::emission::Rec {key field args} {
    variable recognizers
    return [dict get $recognizers $key $field {*}$args]
}

proc hir::emission::KeyText {key} {
    variable recognizers
    if {[dict exists $recognizers $key]} {
        return [dict get $recognizers $key qualified]
    }
    lassign $key ns name
    if {$ns eq ""} { return $name }
    return ${ns}::$name
}

proc hir::emission::StartState {key} {
    return [Rec $key states 0]
}

proc hir::emission::Initial {key} {
    return [list {} $key [StartState $key]]
}

# The composite state C without its obligations.
proc hir::emission::Base {c} {
    if {$c eq "done"} { return done }
    return [lrange $c 0 2]
}

proc hir::emission::Obligations {c} {
    if {$c eq "done"} { return {} }
    return [lindex $c 3]
}

# ---------------------------------------------------------------------------
# One row, as dfa#transition dispatches it

# {Y CODE}...: IntSet X partitioned by the row of state Q of KEY: each
# segment's code for its part, the row's default for the rest.
proc hir::emission::Partition {key q x} {
    set i [dict get [Rec $key numbers] $q]
    lassign [lindex [Rec $key rows] $i] default segs
    set out {}
    set rest $x
    foreach seg $segs {
        lassign $seg lo hi code
        set y [hir::intset::inter $rest [list [list $lo $hi]]]
        if {$y ne {}} {
            lappend out $y $code
            set rest [hir::intset::minus $rest $y]
        }
    }
    if {$rest ne {}} {
        lappend out $rest $default
    }
    return $out
}

# The leaf CODE of KEY stands for: {state N} for a state number, else the
# leaf of surface::dfa::Codes (core::dfa::Outcome reads both).
proc hir::emission::LeafOf {key code} {
    if {$code < [Rec $key n]} {
        return [list state $code]
    }
    return [dict get [Rec $key leafOf] $code]
}

# ---------------------------------------------------------------------------
# The composite step

# {Y RESULT MINDEPTH}...: what composite C does with the IntSet X (X holds
# the end, -1, only alone: Emit and Finish never mix it with symbols).
# RESULT is a composite state, `done`, or {violation KIND KEY STATE N} (KIND
# reject, beyond, after, lookahead, boundary); MINDEPTH the shallowest frame
# depth still open during the step (-1: the outermost completed). A boundary
# obligation on the frame at DEPTH holds when that frame completes during
# the step (MINDEPTH < DEPTH); otherwise the frame took the symbol, and the
# helper's token would absorb it.
proc hir::emission::Step {c x} {
    set obligations [Obligations $c]
    set out {}
    foreach r [StepBase [Base $c] $x] {
        lassign $r y result md
        if {$result ne "done" && [lindex $result 0] ne "violation"} {
            set broken ""
            foreach o $obligations {
                lassign $o depth okey helper call
                if {$md >= $depth} {
                    set broken $o
                    break
                }
            }
            if {$broken ne ""} {
                lassign $broken depth okey helper call
                lappend out [list $y [list violation boundary $okey $helper $call] $md]
                continue
            }
        }
        lappend out $r
    }
    return $out
}

proc hir::emission::StepBase {c x} {
    variable byQualified
    if {$c eq "done"} {
        return [list [list $x [list violation after "" "" 0] -1]]
    }
    lassign $c stack key q
    set depth [llength $stack]
    set out {}
    foreach {y code} [Partition $key $q $x] {
        set outcome [core::dfa::Outcome [LeafOf $key $code]]
        switch -- [lindex $outcome 0] {
            consume {
                lappend out [list $y [list $stack $key [Rec $key states [lindex $outcome 1]]] $depth]
            }
            complete {
                lappend out {*}[Complete $stack $key $q $y [lindex $outcome 1] $depth]
            }
            call {
                # The callee's run on the symbol, from its start.
                lassign $outcome - callee then
                set inner [concat $stack [list [list $key $then]]]
                foreach r [StepBase [list $inner $callee [StartState $callee]] $y] {
                    lassign $r y2 result md
                    if {$md > $depth} { set md $depth }
                    lappend out [list $y2 $result $md]
                }
            }
            reject {
                lassign $outcome - r s
                set rkey [dict getdef $byQualified $r $key]
                lappend out [list $y [list violation reject $rkey $s 0] $depth]
            }
        }
    }
    return $out
}

# Recognizer KEY in state Q (the frame at DEPTH, called from STACK)
# completed on Y with CLASS (taken, current, {more K}): what its caller --
# or, outermost, the token -- does with it (core::dfa::Resume, Unread).
proc hir::emission::Complete {stack key q y class depth} {
    variable END
    set out {}
    # The end and the symbols separately: `current` means the end
    # reconsidered, or a symbol left unread.
    set endPart [hir::intset::inter $y [hir::intset::point $END]]
    set symPart [hir::intset::minus $y [hir::intset::point $END]]
    foreach part [list $endPart $symPart] atEnd {1 0} {
        if {$part eq {}} continue
        if {$stack eq {}} {
            set unread [core::dfa::Unread $class $atEnd]
            if {$unread == 0} {
                lappend out [list $part done -1]
            } else {
                lappend out [list $part [list violation beyond $key $q $unread] -1]
            }
            continue
        }
        lassign [lindex $stack end] ckey then
        set rest [lrange $stack 0 end-1]
        set action [core::dfa::Resume $then $class]
        switch -- [lindex $action 0] {
            propagate {
                lappend out {*}[Complete $rest $ckey $q $part $class [expr {$depth - 1}]]
            }
            wait {
                lappend out [list $part [list $rest $ckey [lindex $action 1]] [expr {$depth - 1}]]
            }
            reconsider {
                foreach r [StepBase [list $rest $ckey [lindex $action 1]] $part] {
                    lassign $r y2 result md
                    if {$md > $depth - 1} { set md [expr {$depth - 1}] }
                    lappend out [list $y2 $result $md]
                }
            }
            reject {
                lappend out [list $part [list violation lookahead $ckey $then [lindex $class 1]] [expr {$depth - 1}]]
            }
        }
    }
    return $out
}

# ---------------------------------------------------------------------------
# Queries

# The depth of recognizer KEY's innermost frame in composite C, or -1.
proc hir::emission::FrameDepth {c key} {
    if {$c eq "done"} { return -1 }
    lassign $c stack k
    if {$k eq $key} { return [llength $stack] }
    for {set i [expr {[llength $stack] - 1}]} {$i >= 0} {incr i -1} {
        if {[lindex $stack $i 0] eq $key} {
            return $i
        }
    }
    return -1
}

# Every symbol (the end excluded).
proc hir::emission::Symbols {} {
    variable END
    return [hir::intset::minus [hir::intset::universe] [hir::intset::point $END]]
}

# The symbols composite C takes without completing or failing, and those it
# completes on: {TAKES COMPLETES} (IntSets, the end excluded).
proc hir::emission::Expected {c} {
    set takes {}
    set completes {}
    foreach r [StepBase [Base $c] [Symbols]] {
        lassign $r y result
        if {$result eq "done"} {
            set completes [hir::intset::union $completes $y]
        } elseif {[lindex $result 0] ne "violation"} {
            set takes [hir::intset::union $takes $y]
        }
    }
    return [list $takes $completes]
}

# The boundary of a token whose exit states are EXITS: the symbols every
# exit ends the token before (an outermost completion leaving that one
# symbol unread), or "self" when every exit completed on its own last
# symbol (`done`): the boundary summary a certificate exposes.
proc hir::emission::Follow {exits} {
    set open [lmap c $exits {if {$c eq "done"} continue; set c}]
    if {$open eq {}} {
        return self
    }
    set follow [Symbols]
    foreach c $open {
        set here {}
        foreach r [StepBase [Base $c] $follow] {
            lassign $r y result
            if {[lindex $result 0] eq "violation" && [lindex $result 1] eq "beyond" && [lindex $result 4] == 1} {
                set here [hir::intset::union $here $y]
            }
        }
        set follow [hir::intset::inter $follow $here]
    }
    return $follow
}

# The symbols a non-suspending recognizer KEY's first step completes on,
# whatever it leaves unread: what a normal completion of a call of it (a
# guard) proves of its argument.
proc hir::emission::GuardSet {key} {
    set completes {}
    foreach r [StepBase [Initial $key] [Symbols]] {
        lassign $r y result
        if {$result eq "done" || ([lindex $result 0] eq "violation" && [lindex $result 1] eq "beyond")} {
            set completes [hir::intset::union $completes $y]
        }
    }
    return $completes
}

# ---------------------------------------------------------------------------
# Composition by a certificate's language

# What a call of a helper certified to emit one token of recognizer K does
# from caller state C, read from K alone, never from the helper's code: the
# product of K's automaton (restricted to the states the certificate says the
# helper passes through, VISITSK, and ends in, EXITSK) with the caller's.
# Returns {EXITS VISITS FAILS VIOLATIONS COMPLETE}: the caller's states
# where the helper may return, every caller state it may be in between its
# symbols, those where it may fail (the certificate's FAILSK), {Y VIOLATION
# STATE} for symbols of K's tokens the caller's state does not take, and 0
# when the product exceeded maxProduct (nothing it found is then a fact).
proc hir::emission::LangApply {k exitsK visitsK failsK c} {
    variable maxProduct
    set allowed [dict create]
    foreach s [concat $visitsK $exitsK] {
        dict set allowed [Base $s] 1
    }
    # An exit's open boundary obligations (the certificate's own helpers'
    # tokens still waiting for the symbol that ends them), by base state.
    set isExit [dict create]
    foreach s $exitsK {
        dict set isExit [Base $s] [lsort -unique [concat [dict getdef $isExit [Base $s] {}] [Obligations $s]]]
    }
    set failing [dict create]
    foreach s $failsK {
        dict set failing [Base $s] 1
    }
    set fails {}
    set symbols [Symbols]
    set start [list [Initial $k] $c]
    set seen [dict create $start 1]
    set work [list $start]
    set exits {}
    set visits {}
    set violations {}
    while {[llength $work]} {
        if {[dict size $seen] > $maxProduct} {
            return [list {} {} {} {} 0]
        }
        set work [lassign $work pair]
        lassign $pair kq cq
        lappend visits $cq
        if {[dict exists $failing $kq]} {
            lappend fails $cq
        }
        if {[dict exists $isExit $kq]} {
            lappend exits [Reattach $cq [dict get $isExit $kq]]
        }
        if {$kq eq "done"} continue
        foreach r [StepBase $kq $symbols] {
            lassign $r y k2
            if {$k2 ne "done" && [lindex $k2 0] eq "violation"} continue
            if {![dict exists $allowed $k2]} continue
            foreach r2 [Step $cq $y] {
                lassign $r2 y2 c2
                if {$c2 ne "done" && [lindex $c2 0] eq "violation"} {
                    lappend violations [list $y2 $c2 $cq]
                    continue
                }
                set next [list $k2 $c2]
                if {![dict exists $seen $next]} {
                    dict set seen $next 1
                    lappend work $next
                }
            }
        }
    }
    return [list [lsort -unique $exits] [lsort -unique $visits] [lsort -unique $fails] $violations 1]
}

# Caller state C with the obligations OBLIGATIONS of a certificate's exit
# state added: each moved to the innermost frame of its recognizer in C (a
# token the caller's own parse does not delegate to that recognizer is no
# token of the caller's, so it carries no obligation there).
proc hir::emission::Reattach {c obligations} {
    if {$c eq "done" || $obligations eq {}} { return $c }
    set out [Obligations $c]
    foreach o $obligations {
        lassign $o d key helper call
        set nd [FrameDepth $c $key]
        if {$nd >= 0} {
            lappend out [list $nd $key $helper $call]
        }
    }
    if {$out eq {}} { return [Base $c] }
    return [list {*}[Base $c] [lsort -unique $out]]
}

# ---------------------------------------------------------------------------
# Text

proc hir::emission::StateText {c} {
    if {$c eq "done"} {
        return "the complete token"
    }
    lassign $c stack key q
    set text "state $q of [KeyText $key]"
    foreach frame [lreverse $stack] {
        lassign $frame k then
        append text " (called by [KeyText $k], then $then)"
    }
    return $text
}

# The origin of state Q of recognizer KEY's declaration, or "".
proc hir::emission::StateOrigin {key q} {
    variable recognizers
    if {![dict exists $recognizers $key] || ![dict exists $recognizers $key stateOrigins $q]} {
        return ""
    }
    return [dict get $recognizers $key stateOrigins $q]
}

# The text of IntSet X of ALPHABET: its symbols, and its values outside the
# alphabet as one phrase.
proc hir::emission::SetText {x alphabet {limit 6}} {
    set hull [core::dfa::AlphabetHull $alphabet]
    set inside [hir::intset::inter $x [list $hull]]
    set parts {}
    if {$inside ne {}} {
        set items [lmap i $inside {
            lassign $i lo hi
            if {$lo == $hi} {
                core::dfa::SymbolText $lo $alphabet
            } else {
                string cat [core::dfa::SymbolText $lo $alphabet] .. [core::dfa::SymbolText $hi $alphabet]
            }
        }]
        if {[llength $items] > $limit} {
            set items [list {*}[lrange $items 0 [expr {$limit - 1}]] "... ([llength $items] ranges)"]
        }
        lappend parts [join $items " "]
    }
    if {[hir::intset::minus $x [list $hull]] ne {}} {
        lappend parts "values outside the alphabet ($alphabet)"
    }
    return [join $parts " and "]
}
