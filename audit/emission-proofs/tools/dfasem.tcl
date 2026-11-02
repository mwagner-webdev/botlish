# dfasem.tcl -- the run semantics of declared recognizers as the modular
# emission checker reads them (MODULAR-EMISSION-PROOFS-MILESTONE-1.md, "DFA
# semantics").
#
#   source audit/emission-proofs/tools/dfasem.tcl  (after intset.tcl)
#   dfasem::load ENTRY            the recognizers of the program at ENTRY
#   dfasem::Step C X              what composite state C does with IntSet X
#
# The input is not the declaration and not the effective table: it is
# surface/dfa.tcl's Codes -- the table the lowering compiles into one
# dfa#transition call per recognizer (core/dfa.tcl's format: per state
# number a row {DEFAULT SEGS}, SEGS {LO HI CODE}) and the leaves its codes
# stand for. So the checker partitions a symbol set exactly as the
# compiled recognizer's dispatch does, including the default code every
# value outside the row's segments gets (a value past the alphabet, a
# bignum, the end where nothing accepts it).
#
# What a code *means* is stated once here, in LeafMeaning and Complete,
# next to the arm of surface::dfa::Lower that compiles it (the comments name
# the arm). That is the one piece of run semantics the prototype states
# beside the lowering; tools/conformance.tcl checks the two agree by running
# the lowered recognizers, and the report's section 11 says how a production
# version states it once for both.
#
#   code < N (a state number)  consume, continue in that state
#   taken          complete; every symbol taken          (run: return -2)
#   returnc        complete; the current symbol, or the end, unread
#                                                         (run: return c)
#   more K         complete; K symbols unread             (run: return -2-K)
#   call KEY THEN  run KEY from its start on the symbol; then, by what KEY
#                  returns: THEN accept -> return it; -2 -> continue in
#                  THEN, waiting; c or -1 -> run THEN on it (reconsider);
#                  -2-K -> run THEN on -2-K, which no row holds: THEN's
#                  default, a rejection (DFA-CALL-LOOKAHEAD forbids it)
#   reject R S     fail (UnrecognizedInput, or UnexpectedEnd at the end)
#
# The outermost recognizer's result is the number of unread symbols
# (Lower's recognizer function: -2 and -1 are 0, c >= 0 is 1, -2-K is K).
#
# A composite state is {STACK KEY STATE ?OBLIGATIONS?}: recognizer KEY in
# STATE, called from the frames of STACK ({KEY THEN}..., outermost first),
# or `done` (the outermost recognizer completed with nothing unread).
# OBLIGATIONS ({DEPTH KEY HELPER CALL}...) are boundary obligations
# (Step): the frame at DEPTH holds the token a helper claims to have
# emitted whole, so the next symbol must end it.

namespace eval dfasem {
    variable END -1
    # {NS NAME} -> {numbers states rows leaves codes n alphabet qualified
    # nameSpan stateSpans} (Load).
    variable recognizers [dict create]
    # qualified text -> {NS NAME}
    variable byQualified [dict create]
}

# ---------------------------------------------------------------------------
# Loading: surface/dfa.tcl's models, in the loader's order

# {NS PATH}... of the entry ENTRY ("" its NS) and every application module it
# imports, directly or not (surface/modules.tcl's rule: ROOT/A/B.bot for
# A::B; a standard namespace declares no recognizer an emitter claims).
proc dfasem::ApplicationFiles {entry} {
    set root [file dirname [file normalize $entry]]
    set files [dict create "" [file normalize $entry]]
    set work [list [file normalize $entry]]
    while {[llength $work]} {
        set work [lassign $work path]
        set ast [surface::parse [core::ReadFile $path] $path]
        foreach i [dict get $ast imports] {
            set ns [dict get $i namespace]
            if {[string match std::* $ns] || [dict exists $files $ns]} continue
            set file [file join $root {*}[split [string map {:: /} $ns] /]].bot
            if {[file exists $file]} {
                dict set files $ns $file
                lappend work $file
            }
        }
    }
    return $files
}

# {NS NAME} -> analyzed model (surface::dfa::expand's dfaModel) of every
# recognizer of the program at ENTRY, each file expanded after the files it
# imports (surface/modules.tcl's ExpandDfas).
proc dfasem::Models {entry} {
    set asts [dict create]
    dict for {ns path} [ApplicationFiles $entry] {
        set ast [surface::parse [core::ReadFile $path] $path]
        foreach s [dict get $ast body] {
            if {[dict get $s kind] in {classdecl dfadecl}} {
                dict set asts $ns $ast
                break
            }
        }
    }
    set order {}
    set seen [dict create]
    dict for {ns -} $asts {
        Visit $asts $ns seen order
    }
    set registry [dict create]
    set models [dict create]
    foreach ns $order {
        set ast [dict get $asts $ns]
        set imports [lmap i [dict get $ast imports] {dict get $i namespace}]
        set result [surface::dfa::expand [dict get $ast body] -own $ns -imports $imports -registry $registry]
        set registry [dict get $result registry]
        foreach s [dict get $result statements] {
            if {[dict exists $s dfaModel]} {
                dict set models [list $ns [dict get $s name]] [dict get $s dfaModel]
            }
        }
    }
    return $models
}

proc dfasem::Visit {asts ns seenVar orderVar} {
    upvar 1 $seenVar seen $orderVar order
    if {[dict exists $seen $ns]} return
    dict set seen $ns 1
    foreach i [dict get $asts $ns imports] {
        set dep [dict get $i namespace]
        if {[dict exists $asts $dep]} {
            Visit $asts $dep seen order
        }
    }
    lappend order $ns
}

# Loads the recognizers of the program at ENTRY: each one's Codes (the
# lowering's table and leaves). Returns their keys.
proc dfasem::load {entry} {
    variable recognizers
    variable byQualified
    set recognizers [dict create]
    set byQualified [dict create]
    dict for {key d} [Models $entry] {
        set codes [surface::dfa::Codes $d]
        set states [dict create]
        dict for {q i} [dict get $codes numbers] {
            dict set states $i $q
        }
        set leafOf [dict create]
        dict for {leaf code} [dict get $codes codeOf] {
            dict set leafOf $code $leaf
        }
        set spans [dict create]
        dict for {q node} [dict get $d states] {
            if {[dict exists $node nameSpan]} {
                dict set spans $q [dict get $node nameSpan]
            }
        }
        dict set recognizers $key [dict create numbers [dict get $codes numbers] states $states \
            rows [dict get $codes rows] leafOf $leafOf n [dict size [dict get $codes numbers]] \
            alphabet [dict get $d alphabet] qualified [dict get $d qualified] \
            nameSpan [dict get $d nameSpan] stateSpans $spans \
            fingerprint [Fingerprint $codes [dict get $d alphabet]]]
        dict set byQualified [dict get $d qualified] $key
    }
    return [dict keys $recognizers]
}

# A recognizer's semantic fingerprint: its compiled table and leaves (what
# runs), never its spelling. A certificate records it with each callee's.
proc dfasem::Fingerprint {codes alphabet} {
    return [Digest [list $alphabet [dict get $codes rows] [dict get $codes leaves]]]
}

# A checksum of TEXT (hir::interchange's: crc32 and adler32 of its UTF-8).
proc dfasem::Digest {text} {
    set bytes [encoding convertto utf-8 $text]
    return [format %08x%08x [zlib crc32 $bytes] [zlib adler32 $bytes]]
}

# The fingerprint of KEY and of every recognizer it calls, transitively.
proc dfasem::DeepFingerprint {key} {
    variable recognizers
    set seen [dict create]
    set work [list $key]
    while {[llength $work]} {
        set work [lassign $work k]
        if {[dict exists $seen $k]} continue
        dict set seen $k [dict get $recognizers $k fingerprint]
        dict for {code leaf} [dict get $recognizers $k leafOf] {
            if {[lindex $leaf 0] eq "call"} {
                lappend work [lindex $leaf 1]
            }
        }
    }
    return [Digest [lsort -stride 2 -index 0 $seen]]
}

proc dfasem::Has {key} {
    variable recognizers
    return [dict exists $recognizers $key]
}

proc dfasem::Get {key field args} {
    variable recognizers
    return [dict get $recognizers $key $field {*}$args]
}

proc dfasem::KeyOfQualified {text} {
    variable byQualified
    return [dict getdef $byQualified $text ""]
}

proc dfasem::KeyText {key} {
    lassign $key ns name
    if {$ns eq ""} { return $name }
    return ${ns}::$name
}

proc dfasem::Start {key} {
    return [Get $key states 0]
}

proc dfasem::Initial {key} {
    return [list {} $key [Start $key]]
}

# The composite state C without its obligations.
proc dfasem::Base {c} {
    if {$c eq "done"} { return done }
    return [lrange $c 0 2]
}

proc dfasem::Obligations {c} {
    if {$c eq "done"} { return {} }
    return [lindex $c 3]
}

# ---------------------------------------------------------------------------
# One row, as dfa#transition dispatches it

# {Y CODE}...: IntSet X partitioned by the row of state Q of KEY: each
# segment's code for its part, the row's default for the rest.
proc dfasem::Partition {key q x} {
    set i [dict get [Get $key numbers] $q]
    lassign [lindex [Get $key rows] $i] default segs
    set out {}
    set rest $x
    foreach seg $segs {
        lassign $seg lo hi code
        set y [intset::inter $rest [list [list $lo $hi]]]
        if {$y ne {}} {
            lappend out $y $code
            set rest [intset::minus $rest $y]
        }
    }
    if {$rest ne {}} {
        lappend out $rest $default
    }
    return $out
}

# What CODE of KEY means: {state S}, or its leaf (taken, returnc, {more K},
# {call KEY THEN}, {reject R S}).
proc dfasem::LeafMeaning {key code} {
    if {$code < [Get $key n]} {
        return [list state [Get $key states $code]]
    }
    return [dict get [Get $key leafOf] $code]
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
proc dfasem::Step {c x} {
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

proc dfasem::StepBase {c x} {
    variable END
    if {$c eq "done"} {
        return [list [list $x [list violation after "" "" 0] -1]]
    }
    lassign $c stack key q
    set depth [llength $stack]
    set out {}
    foreach {y code} [Partition $key $q $x] {
        set leaf [LeafMeaning $key $code]
        switch -- [lindex $leaf 0] {
            state {
                lappend out [list $y [list $stack $key [lindex $leaf 1]] $depth]
            }
            taken {
                lappend out {*}[Complete $stack $key $q $y taken $depth]
            }
            returnc {
                lappend out {*}[Complete $stack $key $q $y current $depth]
            }
            more {
                lappend out {*}[Complete $stack $key $q $y [list more [lindex $leaf 1]] $depth]
            }
            call {
                # Lower's call arm: the callee's run on the symbol, from its
                # start.
                lassign $leaf - callee then
                set inner [concat $stack [list [list $key $then]]]
                foreach r [StepBase [list $inner $callee [Start $callee]] $y] {
                    lassign $r y2 result md
                    lappend out [list $y2 $result [expr {min($md, $depth)}]]
                }
            }
            reject {
                lassign $leaf - r s
                set rkey [KeyOfQualified $r]
                if {$rkey eq ""} { set rkey $key }
                lappend out [list $y [list violation reject $rkey $s 0] $depth]
            }
            default {
                error "dfasem: unknown leaf $leaf of [KeyText $key]"
            }
        }
    }
    return $out
}

# Recognizer KEY in state Q (the frame at DEPTH, called from STACK)
# completed on Y with result CLASS (taken, current, {more K}): what its
# caller -- or, outermost, the token -- does with it.
proc dfasem::Complete {stack key q y class depth} {
    variable END
    set out {}
    # The end and the symbols separately: `current` means the end
    # reconsidered, or a symbol left unread.
    set endPart [intset::inter $y [intset::point $END]]
    set symPart [intset::minus $y [intset::point $END]]
    foreach part [list $endPart $symPart] atEnd {1 0} {
        if {$part eq {}} continue
        if {$stack eq {}} {
            # The recognizer function's result: -2 or -1 is nothing unread.
            set unread [switch -- [lindex $class 0] {
                taken { expr 0 }
                current { expr {$atEnd ? 0 : 1} }
                more { lindex $class 1 }
            }]
            if {$unread == 0} {
                lappend out [list $part done -1]
            } else {
                lappend out [list $part [list violation beyond $key $q $unread] -1]
            }
            continue
        }
        lassign [lindex $stack end] ckey then
        set rest [lrange $stack 0 end-1]
        if {$then eq "accept"} {
            # `then accept`: the caller returns the callee's result.
            lappend out {*}[Complete $rest $ckey $q $part $class [expr {$depth - 1}]]
            continue
        }
        switch -- [lindex $class 0] {
            taken {
                # -2: continue in THEN, which waits for the next symbol.
                lappend out [list $part [list $rest $ckey $then] [expr {$depth - 1}]]
            }
            current {
                # c or -1: THEN reconsiders it at once.
                foreach r [StepBase [list $rest $ckey $then] $part] {
                    lassign $r y2 result md
                    lappend out [list $y2 $result [expr {min($md, $depth - 1)}]]
                }
            }
            more {
                # -2-K: no row holds it (DFA-CALL-LOOKAHEAD forbids it).
                lappend out [list $part [list violation lookahead $ckey $then [lindex $class 1]] [expr {$depth - 1}]]
            }
        }
    }
    return $out
}

# ---------------------------------------------------------------------------
# Queries

# The depth of recognizer KEY's innermost frame in composite C, or -1.
proc dfasem::FrameDepth {c key} {
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

# 1 if the frame of KEY at DEPTH in C is in KEY's start state (it has
# consumed nothing yet).
proc dfasem::FrameFresh {c key depth} {
    if {$c eq "done"} { return 0 }
    lassign $c stack k q
    return [expr {$depth == [llength $stack] && $k eq $key && $q eq [Start $key]}]
}

# The symbols composite C takes without completing or failing, and those it
# completes on: {TAKES COMPLETES} (IntSets, the end excluded).
proc dfasem::Expected {c} {
    variable END
    set takes {}
    set completes {}
    set all [intset::minus [intset::universe] [intset::point $END]]
    foreach r [StepBase [Base $c] $all] {
        lassign $r y result
        if {$result eq "done"} {
            set completes [intset::union $completes $y]
        } elseif {[lindex $result 0] ne "violation"} {
            set takes [intset::union $takes $y]
        }
    }
    return [list $takes $completes]
}

# 1 if composite C accepts the end with nothing unread.
proc dfasem::AcceptsEnd {c} {
    variable END
    foreach r [StepBase [Base $c] [intset::point $END]] {
        if {[lindex $r 1] ne "done"} {
            return 0
        }
    }
    return 1
}

# The boundary of a token whose exit states are EXITS: the symbols every
# exit ends the token before (an outermost completion leaving that one
# symbol unread), or "self" when every exit completed on its own last
# symbol (`done`): the boundary summary a certificate exposes.
proc dfasem::Follow {exits} {
    variable END
    set open [lmap c $exits {if {$c eq "done"} continue; set c}]
    if {$open eq {}} {
        return self
    }
    set follow [intset::minus [intset::universe] [intset::point $END]]
    foreach c $open {
        set here {}
        foreach r [StepBase [Base $c] $follow] {
            lassign $r y result
            if {[lindex $result 0] eq "violation" && [lindex $result 1] eq "beyond" && [lindex $result 4] == 1} {
                set here [intset::union $here $y]
            }
        }
        set follow [intset::inter $follow $here]
    }
    return $follow
}

# ---------------------------------------------------------------------------
# Composition by a certificate's language

# What a call of a helper certified to emit one token of recognizer K does
# from caller state C, read from K alone, never from the helper's code: the
# product of K's automaton (restricted to the states the certificate says the
# helper passes through, VISITSK, and ends in, EXITSK) with the caller's.
# Returns {EXITS VISITS FAILS VIOLATIONS}: the caller's states where the
# helper may return, every caller state it may be in between its symbols,
# those where it may fail (the certificate's FAILSK), and {Y VIOLATION
# STATE} for symbols of K's tokens the caller's state does not take.
proc dfasem::LangApply {k exitsK visitsK failsK c} {
    variable END
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
    set symbols [intset::minus [intset::universe] [intset::point $END]]
    set start [list [Initial $k] $c]
    set seen [dict create $start 1]
    set work [list $start]
    set exits {}
    set visits {}
    set violations {}
    while {[llength $work]} {
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
    return [list [lsort -unique $exits] [lsort -unique $visits] [lsort -unique $fails] $violations]
}

# Caller state C with the obligations OBLIGATIONS of a certificate's exit
# state added: each moved to the innermost frame of its recognizer in C (a
# token the caller's own parse does not delegate to that recognizer is no
# token of the caller's, so it carries no obligation there).
proc dfasem::Reattach {c obligations} {
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

proc dfasem::StateText {c} {
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

proc dfasem::StateLocation {key q} {
    if {$key eq "" || ![Has $key] || ![dict exists [Get $key stateSpans] $q]} {
        return ""
    }
    return [surface::ast::location [dict get [Get $key stateSpans] $q]]
}

# The text of IntSet X of ALPHABET: its symbols, and its values outside the
# alphabet as one phrase.
proc dfasem::SetText {x alphabet} {
    set hull [surface::dfa::AlphabetHull $alphabet]
    set inside [intset::inter $x [list $hull]]
    set parts {}
    if {$inside ne {}} {
        lappend parts [surface::dfa::SetText $inside $alphabet]
    }
    if {[intset::minus $x [list $hull]] ne {}} {
        lappend parts "values outside the alphabet ($alphabet)"
    }
    return [join $parts " and "]
}
