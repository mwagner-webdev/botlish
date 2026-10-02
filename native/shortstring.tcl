# shortstring.tcl -- the short-String planner (SHORT-STRING.md).
#
# A *representation* decision, in the same family as native/rawabi.tcl: a
# Botlish String the compiler already proves is small may be carried
# physically as ONE i64 instead of a materialized, tagged String object. Three
# regimes, chosen per position by the proof alone (never by profitability):
#
#   known ASCII, at most 8 characters   -> "packed ASCII" (tier `ascii`)
#       byte i of the word is 0x80 | c for the character c at index i and 0
#       past the end. The high bit of every byte is a *presence* flag (the
#       otherwise-unused eighth bit of an ASCII byte), so the length is
#       (71 - clz(w)) >> 3 from the word alone, the empty String is 0, NUL is
#       a present 0x80, the form is canonical (equality is word equality) and
#       unpacking to a String's bytes is `w & 0x7F7F7F7F7F7F7F7F` -- one AND,
#       one 8-byte store.
#   at most 1 character, possibly Unicode -> "ShortString1" (tier `short`)
#       one signed i64: -1 the empty String, 0..0x10FFFF the one Unicode
#       scalar value (U+0000 is 0, never Empty); materialized by UTF-8
#       encoding.
#   anything else                       -> the ordinary tagged String
#
# A one-character ASCII String is therefore packed (it is known ASCII); only
# a value that may be non-ASCII is a scalar. There is no interned table of
# materialized Strings: materializing a value the compiler knows statically
# (a literal) is a `str` constant, any other materialization allocates.
#
# The semantic type stays `String`. Neither tier is a source type, a Char or
# an Int; each is an internal physical kind (`asciiregs=` / `shortregs=` in
# NIR), distinct from RawInt and from each other even though all are an i64.
#
# What one Botlish "character" is (settled by reading the runtime, not
# assumed): a Unicode scalar value. A String is a Rust `str` natively
# (StrObj::chars counts scalars) and a Tcl 9 string in the reference
# interpreter (`string length` counts code points, astral ones included);
# `length` and `substring` index by it. Surrogates (U+D800..U+DFFF) cannot be
# part of a String, so they are not in the representation's domain; a lone
# surrogate literal is simply not eligible. Not a byte, not a grapheme
# cluster. One non-ASCII character ("ä", "€", "λ", "猫", an emoji scalar) is
# one scalar and a ShortString1; a multi-character String that is not proven
# ASCII stays tagged.
#
# Layering (frontend proof -> NIR physical contract -> backend):
#
#   1. PROOF. `Fact` answers "how many characters can this String have, and is
#      it ASCII?" by *composing* facts the repository already has; it adds no
#      inference engine beyond the small product lattice below. The existing
#      facts it reads:
#        * a String literal's own text (a `const`: its length and whether it
#          is ASCII are read off the text), through immutable local aliases
#          (the one `bind` of a single-assignment binding);
#        * hir::range::ConditionOutcome / the instance view's `reachable`
#          flags -- a branch the existing analyses prove dead contributes
#          nothing (so a dead long-String branch never forces a conversion);
#        * hir::induction::ClassifyArg -- the existing `index + K` step
#          classifier traversal.tcl already uses to recognize `peek`'s
#          `substring(text, index, index + 1)`: a `substring(t, i, i + K)`
#          with K 0 or 1 has exactly K characters on success;
#        * hir::exact::IntOf for a `substring(t, 0, 1)`-shaped constant slice;
#        * the specialization's call-target map and closedness
#          (InstanceClosed): a closed instance's parameter is bounded by the
#          join of its callers' arguments, a result by the join of its exits.
#      Whatever is not provable is `over` and stays an ordinary tagged String
#      (a missed opportunity, not an error). ASCII-ness has exactly one
#      source: a literal's text (a slice of a String says nothing about its
#      source's alphabet here).
#
#   2. PHYSICAL PLAN. The selection is *categorical*: proven ASCII with length
#      <= 8 => packed ASCII; else proven length <= 1 => ShortString1; else
#      tagged. There is no profitability score, no use count, no transport
#      distance, no demand suppression (the planner stays small and linear so a
#      later, struct-style frontier heuristic can sit on top of the same
#      facts: eligible + benefit - materialization cost). The plan is one
#      authoritative result per codegen instance, stored once and read by the
#      callee's lowering and by every exact caller.
#
#   3. BACKEND. native/lower.tcl emits NIR with explicit `asciiregs=` /
#      `shortregs=`, `asciiparams=`/`shortparams=`, `asciiresult=`/
#      `shortresult=`, `asciilit`/`shortlit`, the conversion ops and the scalar
#      ops; native/src/nir.rs validates caller/callee agreement; Cranelift
#      lowers each kind to an i64 that is never a GC root.
#
# The fact lattice (what a value's character count and alphabet can be):
#
#   never                 no value (dead code, or an expression that cannot
#                         complete)
#   {lo hi asc known}     lo..hi characters (hi <= 8), asc 1 when every
#                         possible character is proven ASCII, `known` the
#                         scalar value when exactly one character with a
#                         known value (else "")
#   over:WHY              not representable: more than 8 characters, more than
#                         one character not proven ASCII, or unknown (WHY:
#                         long, unicode, unknown, not-string, open-instance,
#                         disabled)
#
# The tier of a fact: `ascii` when asc and hi <= 8, else `short` when hi <= 1,
# else none. Join is the usual least upper bound (min lo, max hi, asc and,
# known kept when equal); a join that no tier can represent is `over`, which
# absorbs (its first reason wins). The lattice is finite, so the fixpoints
# below terminate.
#
# Parameters. Instance I's parameter K is a short position iff I is closed
# (every invocation is a direct, exact call the specialization saw -- so no
# dynamic caller can hand the entry a tagged String it does not expect), the
# key type is `str`, and the join over every reachable call site's argument has
# a tier. A *result* is a short position iff the instance is closed and the
# join of its reachable successful exits has a tier. Both facts are least
# fixpoints from `never` over the call graph, so recursion is handled with no
# special case. A result fact is valid for an open instance too (it describes
# the instance's own exits): an open instance's *callers* may use it to keep a
# local value short, converting at the call (tagged -> short), but its ABI
# stays tagged.

namespace eval native::shortstr {
    variable Enabled 0
    variable AsciiPack 1
    variable Hir ""
    variable Spec ""
    variable Ranges ""
    # id -> view, id -> {e 1...} live set, id -> {{callExpr target}...}
    variable Views
    variable LiveSet
    variable LiveCalls
    variable Exits
    variable Closed
    # "id,k" -> fact (closed str-keyed parameters), id -> fact (results)
    variable PFact
    variable RFact
    variable Memo
    variable RegionExprs
    variable Rounds 0
    variable Plan {}
    variable maxScalar 1114111
    variable Labels
}

# ---------------------------------------------------------------------------
# The fact lattice

proc native::shortstr::Over {f} {
    return [expr {[string range $f 0 3] eq "over"}]
}

# The fact with LO..HI characters, ASC (1: all ASCII) and KNOWN (the scalar of
# a one-character value, else ""), normalized: a bound no tier can represent
# is `over`.
proc native::shortstr::Mk {lo hi asc known} {
    if {$hi > 8} {
        return over:long
    }
    if {$hi > 1 && !$asc} {
        return over:unicode
    }
    if {!($lo == 1 && $hi == 1)} {
        set known ""
    }
    return [list $lo $hi $asc $known]
}

# The tier of fact F: `ascii` (proven ASCII, at most 8 characters), `short`
# (at most one character, possibly non-ASCII) or "" (not representable).
proc native::shortstr::Tier {f} {
    if {$f eq "never" || [Over $f]} {
        return ""
    }
    variable AsciiPack
    lassign $f lo hi asc known
    if {$asc && $AsciiPack} {
        return ascii
    }
    return [expr {$hi <= 1 ? "short" : ""}]
}

# 1 if fact F has a tier (and so can be carried as a scalar).
proc native::shortstr::Ok {f} {
    return [expr {[Tier $f] ne ""}]
}

proc native::shortstr::Join {a b} {
    if {$a eq "never"} { return $b }
    if {$b eq "never"} { return $a }
    if {[Over $a]} { return $a }
    if {[Over $b]} { return $b }
    if {$a eq $b} { return $a }
    lassign $a alo ahi aasc aknown
    lassign $b blo bhi basc bknown
    set known [expr {$aknown ne "" && $aknown eq $bknown ? $aknown : ""}]
    return [Mk [expr {min($alo, $blo)}] [expr {max($ahi, $bhi)}] [expr {$aasc && $basc}] $known]
}

# The fact of a String literal's text.
proc native::shortstr::Literal {text} {
    variable maxScalar
    set n [string length $text]
    if {$n > 8} {
        return over:long
    }
    set asc 1
    foreach ch [split $text ""] {
        scan $ch %c cp
        if {$cp < 0 || $cp > $maxScalar || ($cp >= 0xD800 && $cp <= 0xDFFF)} {
            return over:unknown
        }
        if {$cp >= 0x80} {
            set asc 0
        }
    }
    set known ""
    if {$n == 1} {
        scan $text %c known
    }
    return [Mk $n $n $asc $known]
}

# A human reading of a fact for the audit.
proc native::shortstr::Describe {f} {
    switch -glob -- $f {
        never   { return "no value" }
        over:long      { return "more than 8 characters" }
        over:unicode   { return "more than one character and not proven ASCII" }
        over:open-instance { return "unknown (open instance: callers not all known)" }
        over:not-string { return "not a String position" }
        over:disabled  { return "disabled" }
        over:*  { return "unknown length" }
    }
    lassign $f lo hi asc known
    set out "length \[$lo,$hi\], [expr {$asc ? "ASCII" : "not proven ASCII"}]"
    if {$known ne ""} {
        append out [format ", exactly U+%04X" $known]
    }
    return $out
}

# The reason code of an unrepresentable fact ("" for a representable one).
proc native::shortstr::Reason {f} {
    switch -glob -- $f {
        never { return no-value }
        over:long { return length-gt-8 }
        over:unicode { return not-ascii-multi }
        over:open-instance { return open-instance }
        over:not-string { return not-string }
        over:disabled { return disabled }
        over:* { return unknown-length }
    }
    return [expr {[Tier $f] eq "" ? "length-gt-1" : ""}]
}

# ---------------------------------------------------------------------------
# Plan

# Plans every used instance of SPEC (hir::specialize::analyze result) given
# RANGES (hir::range::analyze result). ENABLED 0 plans everything `value`
# (reason `disabled`) and makes every fact `over:disabled`: the previous
# physical String behavior. Returns a dict InstanceId -> {params {KIND...}
# result KIND paramReasons {R...} resultReason R closed 0|1 paramFacts {F...}
# resultFact F}, KIND `value` | `short`, R "" for a short position, else
# open-instance, not-string, no-value, length-gt-1, unknown-length,
# construction-plan, dynamic-entry, disabled. CONSTRUCTION is the
# hir::construction analysis: a parameter or result it already carries as a
# virtual-construction plan keeps that representation (`construction-plan`),
# so two virtualizations never claim one position. The facts are also queryable per expression
# afterwards (`fact`).
proc native::shortstr::plan {hir spec ranges enabled {blockEscape 1} {construction {}} {asciiPack 1}} {
    variable Enabled
    variable AsciiPack
    variable Hir
    variable Spec
    variable Ranges
    variable Views
    variable LiveSet
    variable LiveCalls
    variable Exits
    variable Closed
    variable PFact
    variable RFact
    variable Memo
    variable Labels
    variable RegionExprs
    variable Rounds
    set Rounds 0
    set Enabled $enabled
    set AsciiPack $asciiPack
    set Hir $hir
    set Spec $spec
    set Ranges $ranges
    array unset Views
    array unset LiveSet
    array unset LiveCalls
    array unset Exits
    array unset Closed
    array unset PFact
    array unset RFact
    array unset Memo
    array unset Labels
    array unset RegionExprs
    array set Memo {}
    set closed [dict get $spec closed]
    set statics [dict get [dict get $spec context] statics]
    set plan [dict create]
    if {!$enabled} {
        foreach id [dict get $spec used] {
            set instance [dict get $spec instances $id]
            set n [llength [dict get $instance args]]
            dict set plan $id [dict create params [lrepeat $n value] result value \
                paramReasons [lrepeat $n disabled] resultReason disabled closed 0 \
                paramFacts [lrepeat $n over:disabled] resultFact over:disabled]
        }
        variable Plan
        set Plan $plan
        return $plan
    }
    # Closedness, exactly as rawabi.tcl reads it.
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set isClosed [dict exists $closed $id]
        set block [dict get $instance block]
        if {$isClosed && !$blockEscape && [dict get $instance generic] && $block ne "program"
                && $block ni $statics} {
            set isClosed 0
        }
        set Closed($id) $isClosed
    }
    # Candidate positions start at `never` (no caller / no exit seen yet).
    set order {}
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        if {[dict get $instance block] eq "program"} continue
        lappend order $id
        set k 0
        foreach key [dict get $instance args] {
            if {$Closed($id) && $key eq "str"} {
                set PFact($id,$k) never
            }
            incr k
        }
        if {[hir::types::kindOf [dict get $instance result]] eq "str"} {
            set RFact($id) never
        }
        View $id
    }
    # Chaotic iteration to the least fixpoint: facts only ever move up the
    # five-point lattice, so this terminates.
    set changed 1
    while {$changed} {
        set changed 0
        incr Rounds
        array unset Memo
        array set Memo {}
        foreach id $order {
            if {[info exists RFact($id)]} {
                set f never
                foreach e [ExitsOf $id] {
                    set f [Join $f [Fact $id $e]]
                }
                set f [Join $RFact($id) $f]
                if {$f ne $RFact($id)} {
                    set RFact($id) $f
                    set changed 1
                }
            }
        }
        foreach id [dict get $spec used] {
            foreach pair [CallsOf $id] {
                lassign $pair e target
                if {![info exists Closed($target)] || !$Closed($target)} continue
                set node [hir::node [View $id] $e]
                set args [dict get $node args]
                set params [hir::get [View $target] [dict get $spec instances $target block] params]
                if {[llength $args] != [llength $params]} continue
                set k 0
                foreach a $args {
                    if {[info exists PFact($target,$k)]} {
                        set f [Join $PFact($target,$k) [Fact $id $a]]
                        if {$f ne $PFact($target,$k)} {
                            set PFact($target,$k) $f
                            set changed 1
                        }
                    }
                    incr k
                }
            }
        }
    }
    array unset Memo
    array set Memo {}
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program"} {
            dict set plan $id [dict create params {} result value paramReasons {} \
                resultReason dynamic-entry closed $Closed($id) paramFacts {} resultFact over:unknown]
            continue
        }
        set kinds {}
        set reasons {}
        set facts {}
        set k 0
        foreach key [dict get $instance args] {
            if {$key ne "str"} {
                lappend kinds value
                lappend reasons not-string
                lappend facts over:not-string
            } elseif {!$Closed($id)} {
                lappend kinds value
                lappend reasons open-instance
                lappend facts over:open-instance
            } else {
                set f $PFact($id,$k)
                lappend facts $f
                set tier [Tier $f]
                if {$tier ne "" && $construction ne "" && [hir::construction::paramFamily $construction $id $k] ne ""} {
                    lappend kinds value
                    lappend reasons construction-plan
                } elseif {$tier ne ""} {
                    lappend kinds $tier
                    lappend reasons ""
                } else {
                    lappend kinds value
                    lappend reasons [Reason $f]
                }
            }
            incr k
        }
        if {![info exists RFact($id)]} {
            set resultKind value
            set resultReason not-string
            set resultFact over:not-string
        } else {
            set resultFact $RFact($id)
            if {![Ok $resultFact]} {
                set resultKind value
                set resultReason [Reason $resultFact]
            } elseif {!$Closed($id)} {
                set resultKind value
                set resultReason open-instance
            } elseif {$construction ne "" && [hir::construction::resultFamily $construction $id] ne ""} {
                set resultKind value
                set resultReason construction-plan
            } else {
                set resultKind [Tier $resultFact]
                set resultReason ""
            }
        }
        dict set plan $id [dict create params $kinds result $resultKind paramReasons $reasons \
            resultReason $resultReason closed $Closed($id) paramFacts $facts resultFact $resultFact]
    }
    variable Plan
    set Plan $plan
    return $plan
}

# The physical kind per parameter position of the first N of instance ID's
# canonical function: `ascii` (packed ASCII), `short` (ShortString1) or ""
# (an ordinary tagged value). Positions beyond the plan's list (a hidden
# trailing parameter) are tagged.
proc native::shortstr::params {plan id n} {
    set out {}
    set kinds [expr {[dict exists $plan $id] ? [dict get $plan $id params] : {}}]
    for {set i 0} {$i < $n} {incr i} {
        set k [lindex $kinds $i]
        lappend out [expr {$k in {ascii short} ? $k : ""}]
    }
    return $out
}

# The physical kind of instance ID's successful result: `ascii`, `short` or "".
proc native::shortstr::result {plan id} {
    if {![dict exists $plan $id]} {
        return ""
    }
    set k [dict get $plan $id result]
    return [expr {$k in {ascii short} ? $k : ""}]
}

# 1 if instance ID's canonical function has any short-String position.
proc native::shortstr::uses {plan id} {
    if {![dict exists $plan $id]} {
        return 0
    }
    foreach k [concat [list [dict get $plan $id result]] [dict get $plan $id params]] {
        if {$k in {ascii short}} {
            return 1
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Views, liveness, exits

proc native::shortstr::View {id} {
    variable Views
    variable Hir
    variable Spec
    if {![info exists Views($id)]} {
        set Views($id) [hir::specialize::view $Hir $Spec $id]
    }
    return $Views($id)
}

# The live expression set of instance ID (a dict e -> 1): every reachable
# expression of its own region, minus anything beneath a branch the existing
# range analysis decides is dead. The same facts lowering uses to emit only
# the chosen branch (no new reachability analysis).
proc native::shortstr::Live {id} {
    variable LiveSet
    variable LiveCalls
    variable Spec
    if {![info exists LiveSet($id)]} {
        set instance [dict get $Spec instances $id]
        set h [View $id]
        set live [dict create]
        set block [dict get $instance block]
        if {$block eq "program"} {
            set body [hir::roots $h]
        } else {
            set body [hir::get $h $block body]
        }
        foreach e $body {
            LiveWalk $id $h $e live
        }
        set LiveSet($id) $live
        set calls {}
        foreach {e target} [dict get $instance calls] {
            if {[dict exists $live $e]} {
                lappend calls [list $e $target]
            }
        }
        set LiveCalls($id) $calls
    }
    return $LiveSet($id)
}

proc native::shortstr::CallsOf {id} {
    variable LiveCalls
    Live $id
    return $LiveCalls($id)
}

proc native::shortstr::LiveWalk {id h e liveVar} {
    upvar 1 $liveVar live
    variable Ranges
    if {![hir::get $h $e reachable]} {
        return
    }
    dict set live $e 1
    set node [hir::node $h $e]
    switch -- [dict get $node kind] {
        const - ref - continue - fail - block { }
        bind {
            set value [dict get $node value]
            if {[hir::kind $h $value] ne "block"} {
                LiveWalk $id $h $value live
            }
        }
        call {
            if {[hir::kind $h [dict get $node callee]] ne "ref"} {
                LiveWalk $id $h [dict get $node callee] live
            }
            foreach a [dict get $node args] {
                LiveWalk $id $h $a live
            }
        }
        if {
            set condition [dict get $node condition]
            LiveWalk $id $h $condition live
            set outcome [hir::range::ConditionOutcome $h $Ranges $id $condition]
            if {$outcome ne ""} {
                foreach e2 [dict get $node [expr {$outcome ? "thenBody" : "elseBody"}]] {
                    LiveWalk $id $h $e2 live
                }
            } else {
                foreach role {thenBody elseBody} {
                    set body [dict get $node $role]
                    if {$body ne "" && ![hir::get $h [lindex $body 0] reachable]} continue
                    foreach e2 $body {
                        LiveWalk $id $h $e2 live
                    }
                }
            }
        }
        handle {
            LiveWalk $id $h [dict get $node call] live
            foreach body [dict get $node handlerBodies] {
                foreach e2 $body {
                    LiveWalk $id $h $e2 live
                }
            }
        }
        default {
            foreach c [hir::children $h $e] {
                LiveWalk $id $h $c live
            }
        }
    }
}

# The live exit expressions of instance ID: every reachable `return` of its
# region and its trailing value (hir::escape::Exits, the repository's one
# definition of a function's successful exits, a self-tail back edge
# excluded), restricted to the live set.
proc native::shortstr::ExitsOf {id} {
    variable Exits
    variable Spec
    if {![info exists Exits($id)]} {
        set instance [dict get $Spec instances $id]
        set block [dict get $instance block]
        set context [dict get $Spec context]
        set live [Live $id]
        set exits {}
        foreach e [hir::escape::Exits [View $id] $context $instance $id $block [dict get $context selfTails]] {
            if {[dict exists $live $e]} {
                lappend exits $e
            }
        }
        set Exits($id) $exits
    }
    return $Exits($id)
}

# ---------------------------------------------------------------------------
# The proof: the fact of expression E of instance ID

proc native::shortstr::Fact {id e} {
    variable Memo
    if {[info exists Memo($id,$e)]} {
        return $Memo($id,$e)
    }
    # A cycle through a binding is impossible (a binding's value cannot
    # refer to itself), but a result/parameter fact reads other facts, so
    # guard against re-entry anyway: the in-progress value is the least one.
    set Memo($id,$e) never
    set f [FactUncached $id $e]
    set Memo($id,$e) $f
    return $f
}

proc native::shortstr::FactUncached {id e} {
    variable Spec
    variable Ranges
    variable PFact
    variable RFact
    variable Closed
    set h [View $id]
    if {![hir::get $h $e reachable]} {
        return never
    }
    set type [hir::typeOf $h $e]
    if {$type eq "never"} {
        return never
    }
    if {[hir::types::kindOf $type] ne "str"} {
        return over:not-string
    }
    set instance [dict get $Spec instances $id]
    set node [hir::node $h $e]
    switch -- [dict get $node kind] {
        const {
            set value [dict get $node value]
            if {[core::value::kind $value] ne "str"} {
                return over:not-string
            }
            return [Literal [core::value::strOf $value]]
        }
        ref {
            set b [dict get $node binding]
            if {$b eq ""} {
                return over:unknown
            }
            set binding [hir::binding $h $b]
            switch -- [dict get $binding kind] {
                param {
                    set block [dict get $instance block]
                    if {$block eq "program"} {
                        return over:unknown
                    }
                    set k [lsearch -exact [hir::get $h $block params] $b]
                    if {$k < 0} {
                        return over:unknown
                    }
                    if {[info exists PFact($id,$k)]} {
                        return $PFact($id,$k)
                    }
                    return [expr {$Closed($id) ? "over:unknown" : "over:open-instance"}]
                }
                local {
                    set declaration [dict get $binding declaredBy]
                    if {$declaration eq "" || [hir::isModuleBinding $h $b]} {
                        return over:unknown
                    }
                    if {[hir::kind $h $declaration] ne "bind" || [hir::get $h $declaration duplicate]} {
                        return over:unknown
                    }
                    # Only a binding of this instance's own region: a value
                    # captured from an enclosing function is another
                    # instance's, and says nothing here.
                    if {![InRegion $id $declaration]} {
                        return over:unknown
                    }
                    set value [hir::get $h $declaration value]
                    if {[hir::kind $h $value] eq "block"} {
                        return over:not-string
                    }
                    return [Fact $id $value]
                }
            }
            return over:unknown
        }
        bind {
            if {[dict get $node duplicate]} {
                return over:unknown
            }
            set value [dict get $node value]
            if {[hir::kind $h $value] eq "block"} {
                return over:not-string
            }
            return [Fact $id $value]
        }
        if {
            set outcome [hir::range::ConditionOutcome $h $Ranges $id [dict get $node condition]]
            if {$outcome ne ""} {
                return [LastFact $id [dict get $node [expr {$outcome ? "thenBody" : "elseBody"}]]]
            }
            set f never
            foreach role {thenBody elseBody} {
                set body [dict get $node $role]
                if {$body eq ""} {
                    return over:unknown
                }
                if {![hir::get $h [lindex $body 0] reachable]} continue
                set f [Join $f [LastFact $id $body]]
            }
            return $f
        }
        call {
            return [CallFact $id $h $e $node]
        }
    }
    return over:unknown
}

# The fact of the value of statement list BODY (its last expression).
proc native::shortstr::LastFact {id body} {
    if {$body eq ""} {
        return over:unknown
    }
    return [Fact $id [lindex $body end]]
}

# 1 if expression E (a `bind`) belongs to instance ID's own region.
proc native::shortstr::InRegion {id e} {
    variable Spec
    variable RegionExprs
    set context [dict get $Spec context]
    set block [dict get [dict get $Spec instances $id] block]
    if {![info exists RegionExprs($block)]} {
        set RegionExprs($block) [dict create]
        foreach x [dict get $context exprs $block] {
            dict set RegionExprs($block) $x 1
        }
    }
    return [dict exists $RegionExprs($block) $e]
}

proc native::shortstr::CallFact {id h e node} {
    variable Spec
    variable RFact
    lassign [dict get $node target] kind target
    if {$kind eq "native"} {
        set name [dict get [hir::symbol $h $target] name]
        if {$name eq "substring" && [llength [dict get $node args]] == 3} {
            return [SubstringFact $h [dict get $node args]]
        }
        return over:unknown
    }
    if {$kind eq "block"} {
        set calls [dict get $Spec instances $id calls]
        if {![dict exists $calls $e]} {
            return over:unknown
        }
        set callee [dict get $calls $e]
        if {[info exists RFact($callee)]} {
            return $RFact($callee)
        }
    }
    return over:unknown
}

# `substring(text, start, end)` on success has exactly end - start
# characters. The existing facts that bound that difference: both operands
# exact Ints (hir::exact), or `end` a step of the very binding `start`
# refers to (hir::induction::ClassifyArg: identity, or `start + K`).
proc native::shortstr::SubstringFact {h argExprs} {
    lassign $argExprs text start end
    set from [hir::exact::IntOf $h $start]
    set to [hir::exact::IntOf $h $end]
    if {$from ne "" && $to ne ""} {
        return [WidthFact [expr {$to - $from}]]
    }
    if {[hir::kind $h $start] eq "ref"} {
        set b [hir::get $h $start binding]
        if {$b ne "" && [dict get [hir::binding $h $b] kind] in {param local}} {
            set c [hir::induction::ClassifyArg $h $end $b]
            if {$c eq "identity"} {
                return [Mk 0 0 1 ""]
            }
            if {[lindex $c 0] eq "step"} {
                return [WidthFact [lindex $c 1]]
            }
        }
    }
    return over:unknown
}

proc native::shortstr::WidthFact {w} {
    if {$w == 0} {
        return [Mk 0 0 1 ""]
    }
    if {$w == 1} {
        return [Mk 1 1 0 ""]
    }
    if {$w < 0} {
        return over:unknown
    }
    return [expr {$w > 8 ? "over:long" : "over:unicode"}]
}

# ---------------------------------------------------------------------------
# Queries for lowering (valid after `plan`)

# The fact of expression E of instance ID.
proc native::shortstr::fact {id e} {
    variable Enabled
    if {!$Enabled} {
        return over:disabled
    }
    return [Fact $id $e]
}

# The tier of String expression E of instance ID: `ascii`, `short` or ""
# (not representable as a scalar).
proc native::shortstr::tier {id e} {
    return [Tier [fact $id $e]]
}

# 1 if E is a String the compiler proved small (a tier) and can complete:
# lowering may carry it as a scalar.
proc native::shortstr::ok {id e} {
    return [Ok [fact $id $e]]
}

# {kind value} of E's *statically known* one-character scalar, or "" when it
# is only known at run time.
proc native::shortstr::known {id e} {
    set f [fact $id $e]
    if {![Over $f] && $f ne "never" && [lindex $f 3] ne ""} {
        return [list one [lindex $f 3]]
    }
    return ""
}

# ---------------------------------------------------------------------------
# Audit: explanations and censuses (observation only: nothing here changes a
# plan or a lowering). Valid after `plan`.

# {WHAT TEXT} classification helpers ------------------------------------------

# The live local `bind` expressions of instance ID that bind a String.
proc native::shortstr::StringBinds {id} {
    variable Spec
    set h [View $id]
    set binds {}
    foreach e [dict keys [Live $id]] {
        if {[hir::kind $h $e] ne "bind" || [hir::get $h $e duplicate]} continue
        set b [hir::get $h $e binding]
        if {$b eq "" || [dict get [hir::binding $h $b] kind] ne "local" || [hir::isModuleBinding $h $b]} continue
        set value [hir::get $h $e value]
        if {[hir::kind $h $value] eq "block"} continue
        if {[hir::types::kindOf [hir::typeOf $h $e]] ne "str"} continue
        lappend binds $e
    }
    return [lsort -command [list apply {{a b} {expr {[string range $a 1 end] - [string range $b 1 end]}}}] $binds]
}

proc native::shortstr::Label {id} {
    variable Spec
    variable Labels
    if {![info exists Labels($id)]} {
        set Labels($id) [hir::specialize::label $Spec $id]
    }
    return $Labels($id)
}

# How the value of String expression E (instance ID) is produced.
proc native::shortstr::Production {id e} {
    variable Spec
    set h [View $id]
    switch -- [hir::kind $h $e] {
        const {
            set f [fact $id $e]
            if {$f eq "never" || [Over $f]} {
                return "String literal"
            }
            lassign $f lo hi asc known
            if {$hi == 0} {
                return "empty literal"
            }
            if {$known ne ""} {
                return [format "one-character literal U+%04X" $known]
            }
            return "String literal"
        }
        ref {
            set b [hir::get $h $e binding]
            if {$b ne "" && [dict get [hir::binding $h $b] kind] eq "param"} {
                return "parameter [dict get [hir::binding $h $b] name]"
            }
            return "alias of [expr {$b eq "" ? "?" : [dict get [hir::binding $h $b] name]}]"
        }
        bind { return [Production $id [hir::get $h $e value]] }
        if { return "branch join" }
        call {
            lassign [hir::get $h $e target] kind target
            if {$kind eq "native"} {
                return "native [dict get [hir::symbol $h $target] name]"
            }
            set calls [dict get $Spec instances $id calls]
            if {[dict exists $calls $e]} {
                return "result of [Label [dict get $calls $e]]"
            }
            return "call"
        }
    }
    return "[hir::kind $h $e]"
}

# Walks instance ID's live expressions recording, for every String binding,
# how each of its uses consumes it. USES is a dict binding -> list of labels.
proc native::shortstr::UseWalk {id e ctx usesVar} {
    upvar 1 $usesVar uses
    variable Spec
    variable Plan
    set h [View $id]
    if {![dict exists [Live $id] $e]} {
        return
    }
    set node [hir::node $h $e]
    switch -- [dict get $node kind] {
        ref {
            set b [dict get $node binding]
            if {$b ne "" && [dict get [hir::binding $h $b] kind] in {local param}} {
                dict lappend uses $b $ctx
            }
        }
        bind {
            set value [dict get $node value]
            if {[hir::kind $h $value] eq "block"} return
            set name [dict get $node name]
            UseWalk $id $value "alias $name" uses
        }
        call {
            lassign [dict get $node target] kind target
            set args [dict get $node args]
            if {[hir::kind $h [dict get $node callee]] ne "ref"} {
                UseWalk $id [dict get $node callee] "callee -> materialize" uses
            }
            if {$kind eq "native"} {
                set name [dict get [hir::symbol $h $target] name]
                set allOk 1
                foreach a $args {
                    if {![Ok [fact $id $a]]} { set allOk 0 }
                }
                foreach a $args {
                    if {$name eq "length" && [llength $args] == 1 && $allOk} {
                        UseWalk $id $a "length -> scalar" uses
                    } elseif {$name eq "==" && [llength $args] == 2 && $allOk} {
                        UseWalk $id $a "equality -> scalar" uses
                    } elseif {$name eq "==" && [llength $args] == 2} {
                        UseWalk $id $a "equality with an unrestricted String -> materialize" uses
                    } elseif {$name eq "substring"} {
                        UseWalk $id $a "substring -> materialize" uses
                    } else {
                        UseWalk $id $a "$name -> materialize" uses
                    }
                }
            } else {
                set calls [dict get $Spec instances $id calls]
                set callee [expr {[dict exists $calls $e] ? [dict get $calls $e] : ""}]
                set k 0
                foreach a $args {
                    if {$callee ne "" && [dict exists $Plan $callee]
                            && [lindex [dict get $Plan $callee params] $k] in {short ascii}} {
                        UseWalk $id $a "argument $k of [Label $callee] -> scalar" uses
                    } else {
                        UseWalk $id $a "argument $k of [expr {$callee eq "" ? "a dynamic call" : [Label $callee]}] -> materialize" uses
                    }
                    incr k
                }
            }
        }
        if {
            UseWalk $id [dict get $node condition] "condition -> materialize" uses
            foreach role {thenBody elseBody} {
                set body [dict get $node $role]
                if {$body eq ""} continue
                foreach x [lrange $body 0 end-1] {
                    UseWalk $id $x "discarded" uses
                }
                UseWalk $id [lindex $body end] $ctx uses
            }
        }
        return {
            set value [dict get $node value]
            if {$value ne ""} {
                set block [dict get [dict get $Spec instances $id] block]
                set short [expr {[dict exists $Plan $id] && [dict get $Plan $id result] in {short ascii}}]
                UseWalk $id $value [expr {$short ? "return -> scalar" : "return -> materialize"}] uses
            }
        }
        struct {
            foreach f [dict get $node fields] {
                UseWalk $id $f "struct field -> materialize" uses
            }
        }
        default {
            foreach c [hir::children $h $e] {
                UseWalk $id $c "[dict get $node kind] -> materialize" uses
            }
        }
    }
}

proc native::shortstr::UsesOf {id} {
    variable Spec
    variable Plan
    set h [View $id]
    set instance [dict get $Spec instances $id]
    set block [dict get $instance block]
    set uses [dict create]
    set short [expr {[dict exists $Plan $id] && [dict get $Plan $id result] in {short ascii}}]
    set body [expr {$block eq "program" ? [hir::roots $h] : [hir::get $h $block body]}]
    set n [llength $body]
    set i 0
    foreach e $body {
        incr i
        if {$i < $n} {
            UseWalk $id $e discarded uses
        } else {
            UseWalk $id $e [expr {$block eq "program" ? "program value -> materialize" : $short ? "return -> scalar" : "return -> materialize"}] uses
        }
    }
    return $uses
}

# One instance's audit paragraph.
proc native::shortstr::explain {id} {
    variable Spec
    variable Plan
    set instance [dict get $Spec instances $id]
    set block [dict get $instance block]
    set h [View $id]
    set p [dict get $Plan $id]
    set out "instance [Label $id]\n  closed: [expr {[dict get $p closed] ? "yes" : "no"}]\n"
    if {$block eq "program"} {
        append out "  entry: runtime (tagged)\n"
    } else {
        set uses [UsesOf $id]
        append out "  params:\n"
        foreach b [hir::get $h $block params] key [dict get $instance args] kind [dict get $p params] \
                reason [dict get $p paramReasons] fact [dict get $p paramFacts] {
            set name [dict get [hir::binding $h $b] name]
            append out "    $name:\n"
            append out "      semantic type: [expr {$key eq "str" ? "String" : [hir::specialize::ShowKey $key]}]\n"
            if {$key eq "str"} {
                append out "      proven character length: [FactRange $fact]\n"
                append out "      proven ASCII: [FactAscii $fact]\n"
                append out "      eligible representation: [TierName [Tier $fact]]\n"
            }
            append out "      ABI [expr {$kind in {short ascii} ? [TierName $kind] : "tagged ($reason)"}]\n"
            if {$key eq "str" && [dict exists $uses $b]} {
                append out "      uses:\n"
                foreach u [lsort -unique [dict get $uses $b]] {
                    append out "        [UseText $u [Ok $fact]]\n"
                }
            }
        }
        append out "  result:\n"
        set fact [dict get $p resultFact]
        append out "    semantic type: [expr {[hir::types::kindOf [dict get $instance result]] eq "str" ? "String" : [hir::types::show [dict get $instance result]]}]\n"
        if {[hir::types::kindOf [dict get $instance result]] eq "str"} {
            append out "    proven character length: [FactRange $fact]\n"
            append out "    proven ASCII: [FactAscii $fact]\n"
            append out "    eligible representation: [TierName [Tier $fact]]\n"
        }
        append out "    ABI [expr {[dict get $p result] in {short ascii} ? [TierName [dict get $p result]] : "tagged ([dict get $p resultReason])"}]\n"
    }
    set binds [StringBinds $id]
    if {$binds ne ""} {
        set uses [UsesOf $id]
        append out "  values:\n"
        foreach e $binds {
            set b [hir::get $h $e binding]
            set name [hir::get $h $e name]
            set f [fact $id $e]
            append out "    $name ($e):\n"
            append out "      semantic type: String\n"
            append out "      proven character length: [FactRange $f]\n"
            append out "      proven ASCII: [FactAscii $f]\n"
            append out "      eligible representation: [expr {[Ok $f] ? [TierName [Tier $f]] : "tagged ([Describe $f])"}]\n"
            if {[Ok $f]} {
                append out "      physical representation: [TierName [Tier $f]] (local)\n"
                append out "      production: [Production $id [hir::get $h $e value]]\n"
            } else {
                append out "      physical representation: tagged String ([Reason $f])\n"
            }
            set ulist [expr {[dict exists $uses $b] ? [dict get $uses $b] : {}}]
            if {$ulist ne ""} {
                append out "      uses:\n"
                foreach u [lsort -unique $ulist] {
                    append out "        [UseText $u [Ok $f]]\n"
                }
            }
        }
    }
    return $out
}

# A use label: for a value that stays a tagged String the scalar/materialize
# distinction does not exist (it is simply a tagged use).
proc native::shortstr::UseText {use eligible} {
    if {$eligible} {
        return $use
    }
    return [string map {" -> materialize" "" " -> scalar" ""} $use]
}

proc native::shortstr::FactRange {f} {
    if {$f eq "never"} {
        return "none (no value)"
    }
    if {[Over $f]} {
        return "unproven ([Describe $f])"
    }
    lassign $f lo hi asc known
    return "\[$lo,$hi\]"
}

proc native::shortstr::FactAscii {f} {
    if {$f eq "never" || [Over $f]} {
        return "unknown"
    }
    return [expr {[lindex $f 2] ? "yes" : "no"}]
}

# The name of a tier (`ascii`, `short`) in the audit text.
proc native::shortstr::TierName {tier} {
    switch -- $tier {
        ascii { return "packed ASCII" }
        short { return "ShortString1" }
    }
    return "tagged String"
}

proc native::shortstr::explainAll {} {
    variable Spec
    set out ""
    foreach id [dict get $Spec used] {
        append out [explain $id] "\n"
    }
    return $out
}

# The virtualization census of the planned program: String values/positions
# examined, proven length <= 1, and the plan's parameter/result positions.
# (Local values virtualized are counted by lowering: the `short` statistics
# of each function.) Returns a dict.
proc native::shortstr::census {} {
    variable Spec
    variable Plan
    variable Rounds
    set c [dict create rounds $Rounds instances 0 positionsExamined 0 positionsProven 0 localsExamined 0 localsProven 0 \
        paramPositions 0 paramSelected 0 resultPositions 0 resultSelected 0 anyAbi 0 \
        exactEmpty 0 exactOne 0 exactOneUnknown 0 runtimeEmptyOrOne 0 asciiMulti 0 tierAscii 0 tierShort 0 \
        paramAscii 0 paramShort 0 resultAscii 0 resultShort 0 reasons {}]
    foreach id [dict get $Spec used] {
        set instance [dict get $Spec instances $id]
        if {[dict get $instance block] eq "program"} {
            set h [View $id]
        }
        dict incr c instances
        set p [dict get $Plan $id]
        set any 0
        foreach key [dict get $instance args] kind [dict get $p params] fact [dict get $p paramFacts] \
                reason [dict get $p paramReasons] {
            if {$key ne "str"} continue
            dict incr c positionsExamined
            dict incr c paramPositions
            if {[Ok $fact]} { dict incr c positionsProven }
            if {$kind in {short ascii}} {
                dict incr c paramSelected
                dict incr c param[string totitle $kind]
                set any 1
                Classify c $fact
            } else {
                CountReason c $reason
            }
        }
        if {[dict get $instance block] ne "program"
                && [hir::types::kindOf [dict get $instance result]] eq "str"} {
            dict incr c positionsExamined
            dict incr c resultPositions
            set fact [dict get $p resultFact]
            if {[Ok $fact]} { dict incr c positionsProven }
            if {[dict get $p result] in {short ascii}} {
                dict incr c resultSelected
                dict incr c result[string totitle [dict get $p result]]
                set any 1
                Classify c $fact
            } else {
                CountReason c [dict get $p resultReason]
            }
        }
        if {$any} { dict incr c anyAbi }
        foreach e [StringBinds $id] {
            dict incr c localsExamined
            dict incr c positionsExamined
            set f [fact $id $e]
            if {[Ok $f]} {
                dict incr c localsProven
                dict incr c positionsProven
                Classify c $f
            }
        }
    }
    return $c
}

proc native::shortstr::Classify {cVar fact} {
    upvar 1 $cVar c
    if {$fact eq "never" || [Over $fact]} return
    lassign $fact lo hi asc known
    dict incr c tier[string totitle [Tier $fact]]
    if {$hi == 0} {
        dict incr c exactEmpty
    } elseif {$known ne ""} {
        dict incr c exactOne
    } elseif {$lo == 1 && $hi == 1} {
        dict incr c exactOneUnknown
    } elseif {$hi == 1} {
        dict incr c runtimeEmptyOrOne
    } else {
        dict incr c asciiMulti
    }
}

proc native::shortstr::CountReason {cVar reason} {
    upvar 1 $cVar c
    if {$reason eq ""} return
    set r [dict get $c reasons]
    dict incr r $reason
    dict set c reasons $r
}
