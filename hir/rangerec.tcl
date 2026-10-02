# rangerec.tcl -- bounded successful-result Ranges for closed, direct,
# self-recursive Int instances (SELF-RECURSIVE-RESULT-RANGES.md).
#
#   set analysis [hir::range::analyze $hir $spec ?callFactsOpt? ?narrowOpt?
#                     ?captureOpt? ?recursiveOpt? ?recursiveLimit?]
#   dict get $analysis recursive      -> InstanceId -> audit record (below)
#
# Part of hir::range (same namespace, same Range lattice, same transfer
# functions); it is a separate file only because range.tcl is already large.
# It adds no second result table: a solved instance's successful-result
# Range is stored in exactly the place every other instance's is
# (calleeResults, and the `result` of the instance's entry in
# `instances`), so every consumer asks one question -- "what is this
# instance's successful result Range?" -- however the answer was derived.
#
# The problem
# -----------
# hir::range's interprocedural result summaries are a widening fixpoint. For
# a self-recursive instance the summary is read by the instance's own self
# calls, so the first round reads "unknown" and the summary can only ever
# be unknown: `fib` with entry n in [0,22] had result [-inf,+inf] although
# every actual result is a small positive Int.
#
# The theorem
# -----------
# Let F be a closed instance (hir::specialize::InstanceClosed; the
# authoritative proof -- nothing here asks a second openness question) with
# an Int parameter p such that
#
#   (1) p's *external* entry Range E -- the join of the argument Ranges every
#       OTHER instance's reachable exact calls pass -- is finite, and
#       at most `limit` integers wide;
#   (2) at every measure state k reachable from E, every self call the
#       range analysis reaches passes a p-argument whose Range is finite
#       and entirely below k.
#
# Then one abstract summary S(k) per state k, computed in dependency order
# with the SAME transfer functions as ordinary analysis (the only changes
# are the two below), is a post-fixpoint of the abstract transformer
#
#     S(k) = Walk_F(p := {k}, every other parameter := its entry Range,
#                   self call with p-argument Range A  :=  join { S(j) | j in A })
#
# which reads only S(j), j < k. A successful run of F at p = k returns a
# value in S(k): by induction on the finite derivation of that run, each
# self call it makes returns a value in S(j) for its (smaller) actual j,
# and F's other (non-self) calls return values in their own already-sound
# summaries. Soundness needs no termination argument; strict decrease is
# what makes the single-pass table *well defined* (no S(j) with j >= k is
# ever read, so no iteration, hence no widening, is needed) -- and, of
# course, what rejects `f(n)` and `f(n + 1)`.
#
# The two changes to the ordinary walk, both active only inside this solver
# (ctx key `rec`): (a) a self call is answered from the state table rather
# than from calleeResults (RecursiveCall); (b) an `if` whose condition is a
# direct native comparison that the point-valued measure decides outright
# takes only the live branch (RecursiveDecided -> ComparisonOutcome, the
# very theorem native lowering already uses for dead-branch elimination),
# so base cases are found by ordinary condition analysis, never recognized
# by name or shape.
#
# State domain (spec #62-63). The solver does not assume the measure stays
# inside E: states are explored from E downward along the proven-decreasing
# self calls (a worklist closure), each discovered state memoized exactly
# once ("two branches reaching the same measure state share its summary").
# A state is *analyzed* at most twice: once to discover which smaller
# states its self calls need (their result is a placeholder, flagged
# incomplete, and nothing is judged from placeholder-derived ranges), once
# again when all of them are in the table. The total number of distinct
# states is bounded by `limit` (budget); beyond it the solve is abandoned.
#
# Where it runs
# -------------
# analyze runs the ordinary fixpoint (Fixpoint) first, unchanged. Its
# converged entry Ranges are FROZEN as the solver's input (parameters other
# than the measure use them; the external entry of the measure is read from
# the callers' final reachable calls). Solved summaries are PINNED (never
# widened, joined or poisoned), and the fixpoint is re-run once with them so
# callers consume the improved result through the ordinary machinery. A
# pass is therefore: sound inputs -> sound summaries -> sound re-run; the
# re-run's entries are never used to justify the summaries they were
# produced with. The summaries may be re-derived once from the re-run's
# (possibly narrower) entries (maxRecursivePasses), each step sound by the
# same argument, then the chain stops: no unbounded caller -> result ->
# caller loop exists. Widening cannot poison the solve because the solve
# never reads calleeResults of the instance it solves.
#
# Audit record (analysis `recursive`, InstanceId -> dict):
#   status    solved | rejected
#   reason    "" or a tag: open-instance mutual-recursion no-external-entry
#             no-int-measure unbounded-entry state-budget nondecreasing-call
#             unknown-recursive-arg-range multiple-measures
#             unsupported-result
#   detail    one-line human text
#   measure   parameter index / name; entry (the ordinary entry Ranges);
#   external  the measure's external entry Range
#   states    {state Range ...} the memoized table (solved only)
#   result    the pinned Range; resultBefore/entryBefore: ordinary analysis
#   calls     {exprId text Range ...}: each reached self call's measure
#             argument (join over states)

namespace eval hir::range {
    # The explicit state budget: the most measure states one solve may
    # create. Each state is one local range walk of the instance, so
    # compile time is linear in this. Exposed as the audit/native option
    # -recursive-range-limit (never source syntax).
    variable maxRecursiveRangeStates 128
    # How many times the solved summaries may be re-derived from the
    # re-run's own entries (see "Where it runs").
    variable maxRecursivePasses 2
}

# ---------------------------------------------------------------------------
# Entry point

proc hir::range::analyze {hir spec {callFactsOpt 1} {narrowOpt 1} {captureOpt 1} {recursiveOpt 1} {recursiveLimit ""}} {
    variable maxRecursiveRangeStates
    variable maxRecursivePasses
    if {$recursiveLimit eq ""} {
        set recursiveLimit $maxRecursiveRangeStates
    }
    set analysis [Fixpoint $hir $spec $callFactsOpt $narrowOpt $captureOpt [dict create]]
    set records [dict create]
    set first $analysis
    # Result summaries are part of call facts: -call-facts-opt 0 has none.
    if {$callFactsOpt && $recursiveOpt} {
        set pinned [dict create]
        set inputs [SolveInputs $analysis]
        for {set pass 1} {$pass <= $maxRecursivePasses} {incr pass} {
            lassign [SolveRecursive $hir $spec $analysis $recursiveLimit] found records
            if {$found eq $pinned} {
                break
            }
            set pinned $found
            set analysis [Fixpoint $hir $spec $callFactsOpt $narrowOpt $captureOpt $pinned]
            # The solve is a pure function of its inputs: when the re-run
            # left them unchanged a second solve would reproduce the same
            # summaries, so the chain has converged.
            set next [SolveInputs $analysis]
            if {$next eq $inputs} {
                break
            }
            set inputs $next
        }
        # An unfinished chain (pass budget exhausted while the summaries
        # were still changing) is still sound: every link is.
    }
    # Audit: ordinary (pre-solve) facts next to the final ones.
    dict for {id record} $records {
        dict set records $id entryBefore [dict get $first instances $id params]
        dict set records $id resultBefore [dict get $first instances $id result]
        dict set records $id entryAfter [dict get $analysis instances $id params]
        dict set records $id resultAfter [dict get $analysis instances $id result]
    }
    return [dict create instances [dict get $analysis instances] induction [dict get $analysis induction] \
        recursive $records]
}

# The callee summaries the per-state walks read. calleeResults holds the
# summaries an exact call expression's Range reads in the ordinary
# analysis: since Fixpoint's result narrowing (GENERIC-PREDICATE-PROOF-
# LOSS.md, fix 3) they are narrowed together with the entries when that
# pass converges, and otherwise the ASCENDING phase's widened ones (e.g.
# weight<int> -> [2,+inf] while its post-narrowing result is [2,11]). The
# solver reads each other instance's result under the final, narrowed
# entries (Fixpoint's finalOutcomes: the very `result` instances reports)
# when that is tighter -- both are sound, so their intersection is. Even
# after a converged result narrowing the intersection can be strictly
# tighter: RangeNarrow only fills infinite sides and does not carry exact
# value sets, so a summary that is finite but loose (g(x) = bit_and(x, 255)
# called with 1 and 3: summary [0, 255], result [1, 3] {1,3}) keeps its
# bounds. A pinned instance keeps its pinned summary.
proc hir::range::RefinedResults {st} {
    set refined [dict get $st calleeResults]
    foreach id [dict get $st ids] {
        if {[dict exists $st pinned $id] || ![dict exists $refined $id]} continue
        set r [dict get $st finalOutcomes $id result]
        if {$r ne "never"} {
            dict set refined $id [intersect [dict get $refined $id] $r]
        }
    }
    return $refined
}

# Everything the solve of each self-recursive instance reads from ANALYSIS
# (Fixpoint's result): its converged entry Ranges and capture facts, its
# external entry, and the callee summaries of every other instance. Equal
# inputs give equal summaries, so an unchanged re-run needs no second solve.
proc hir::range::SolveInputs {analysis} {
    set st [dict get $analysis state]
    set refined [RefinedResults $st]
    set inputs [dict create]
    foreach id [dict get $st ids] {
        if {![dict get $st selfRecursiveOf $id] || [dict get $st blockOf $id] eq "program"} continue
        set block [dict get $st blockOf $id]
        # Only the summaries of the instances ID's own region calls are read.
        set others {}
        foreach callee [lsort -unique [dict values [dict get $st instanceCallsOf $id]]] {
            if {$callee ne $id && [dict exists $refined $callee]} {
                dict set others $callee [dict get $refined $callee]
            }
        }
        dict set inputs $id [list [dict get $st narrowed $id] \
            [expr {[dict exists $st narrowedCaptures $block] ? [dict get $st narrowedCaptures $block] : {}}] \
            [ExternalEntry $st $id] $others]
    }
    return $inputs
}

# {PinnedDict RecordsDict}: solve every closed self-recursive instance of the
# ordinary analysis ANALYSIS (Fixpoint's result, with its `state`).
proc hir::range::SolveRecursive {hir spec analysis limit} {
    set st [dict get $analysis state]
    set pinned [dict create]
    set records [dict create]
    set refined [RefinedResults $st]
    dict set st refinedResults $refined
    set graph [dict create]
    foreach id [dict get $st ids] {
        dict set graph $id [lsort -unique [dict values [dict get $st instanceCallsOf $id]]]
    }
    foreach id [dict get $st ids] {
        if {![dict get $st selfRecursiveOf $id] || [dict get $st blockOf $id] eq "program"} {
            continue
        }
        set record [SolveInstance $hir $spec $st $graph $id $limit]
        dict set records $id $record
        if {[dict get $record status] eq "solved"} {
            dict set pinned $id [dict get $record result]
        }
    }
    return [list $pinned $records]
}

# Arbitrary-precision numeric sort (`lsort -integer` is limited to 64 bits).
proc hir::range::SortInts {values {direction -increasing}} {
    return [lsort -unique $direction -command {apply {{a b} {expr {$a < $b ? -1 : ($a > $b)}}}} $values]
}

proc hir::range::Rejected {reason detail {extra {}}} {
    return [dict merge $extra [dict create status rejected reason $reason detail $detail]]
}

# Whether instance ID reaches itself through some OTHER instance.
proc hir::range::MutuallyRecursive {graph id} {
    set seen [dict create]
    set todo {}
    foreach t [dict get $graph $id] {
        if {$t ne $id} {
            lappend todo $t
        }
    }
    while {$todo ne {}} {
        set t [lindex $todo end]
        set todo [lrange $todo 0 end-1]
        if {$t eq $id} {
            return 1
        }
        if {[dict exists $seen $t]} continue
        dict set seen $t 1
        lappend todo {*}[dict get $graph $t]
    }
    return 0
}

# The join, per parameter, of the argument Ranges of every reachable exact
# call to ID from another instance (the instance's *external* entry), or ""
# if there is none.
proc hir::range::ExternalEntry {st id} {
    set entry ""
    foreach caller [dict get $st ids] {
        if {$caller eq $id} continue
        foreach pair [dict get $st finalOutcomes $caller calls] {
            lassign $pair target argRanges
            if {$target ne $id} continue
            if {$entry eq ""} {
                set entry $argRanges
            } else {
                set entry [lmap a $entry r $argRanges {join $a $r}]
            }
        }
    }
    return $entry
}

proc hir::range::SolveInstance {hir spec st graph id limit} {
    set block [dict get $st blockOf $id]
    set params [dict get $st paramsOf $id]
    set narrowed [dict get $st narrowed $id]
    if {[dict exists $st open $id]} {
        return [Rejected open-instance "callers are not all known (InstanceClosed does not hold)"]
    }
    if {[MutuallyRecursive $graph $id]} {
        return [Rejected mutual-recursion "the instance reaches itself through another instance"]
    }
    set external [ExternalEntry $st $id]
    if {$external eq ""} {
        return [Rejected no-external-entry "no reachable exact call from another instance"]
    }
    set argTypes [dict get $spec instances $id args]
    set candidates {}
    set sawInt 0
    set i 0
    foreach b $params {
        set type [lindex $argTypes $i]
        if {![catch {core::type::base $type} base] && $base eq "int"} {
            set sawInt 1
            lappend candidates $i
        }
        incr i
    }
    if {!$sawInt} {
        return [Rejected no-int-measure "no Int parameter"]
    }
    set finite {}
    foreach i $candidates {
        set r [lindex $external $i]
        if {[dict get $r min] ne "-inf" && [dict get $r max] ne "+inf"} {
            lappend finite $i
        }
    }
    if {$finite eq ""} {
        return [Rejected unbounded-entry "no Int parameter has a finite external entry Range" \
            [dict create external $external entry $narrowed]]
    }
    set failures {}
    foreach i $finite {
        set r [lindex $external $i]
        set record [SolveMeasure $hir $st $id $block $params $narrowed $i $r $limit]
        dict set record external $external
        dict set record entry $narrowed
        if {[dict get $record status] eq "solved"} {
            return $record
        }
        lappend failures $record
    }
    set first [lindex $failures 0]
    if {[llength $failures] > 1} {
        set tags [lmap f $failures {dict get $f reason}]
        if {[lsort -unique $tags] eq "nondecreasing-call"} {
            dict set first reason multiple-measures
            dict set first detail "no single Int parameter decreases in every reachable self call"
        }
    }
    return $first
}

# Solve instance ID for measure parameter index M with external entry Range
# R: the memoized state table. Returns a record (status solved|rejected).
proc hir::range::SolveMeasure {hir st id block params narrowed m r limit} {
    set lo [dict get $r min]
    set hi [dict get $r max]
    set name [dict get [hir::binding [dict get $st viewOf $id] [lindex $params $m]] name]
    set base [dict create measure $m measureName $name lo $lo hi $hi]
    # The starting states: the external entry's tracked exact value set when
    # it has one (calls with sparse literal arguments start from just those
    # states), else every integer of its interval.
    set starts [ExactOf $r]
    if {$starts eq ""} {
        if {$hi - $lo + 1 > $limit} {
            return [Rejected state-budget "measure $name: [expr {$hi - $lo + 1}] entry states exceed the budget $limit" $base]
        }
        for {set k $lo} {$k <= $hi} {set k [expr {$k + 1}]} {
            lappend starts $k
        }
    }
    if {[llength $starts] > $limit} {
        return [Rejected state-budget "measure $name: [llength $starts] entry states exceed the budget $limit" $base]
    }
    set view [dict get $st viewOf $id]
    set calls [dict get $st instanceCallsOf $id]
    set monotone [dict get $st monotoneOf $id]
    set calleeResults [dict get $st refinedResults]
    set captureSeed [expr {[dict get $st captureOpt] && [dict exists $st narrowedCaptures $block]
        ? [dict get $st narrowedCaptures $block] : {}}]
    set table [dict create]
    set seen [dict create]
    set stack {}
    # Not `incr` anywhere here: states are arbitrary-precision Ints
    # (AGENTS.md: compiled incr wraps at the i64 boundary).
    foreach k [SortInts $starts -decreasing] {
        lappend stack $k
        dict set seen $k 1
    }
    set callRanges [dict create]
    set analyses 0
    set maxAnalyses [expr {4 * $limit + 8}]
    # Predictive budget abort (a compile-time economy, never a soundness
    # matter: rejecting is always the sound fallback). The ordinary entry
    # Range of the measure is a post-fixpoint over every self-call argument,
    # so its finite lower bound FLOOR is below every state the closure can
    # contain, and a chain whose steps are at most MAXSTEP and that is
    # currently at LOWEST still has at least (LOWEST - FLOOR) / MAXSTEP
    # states to visit before it can reach FLOOR. When even that lower
    # estimate overruns the budget the solve is abandoned after a couple of
    # walks instead of after `limit` of them (loop-count's 2000-state
    # `drive` chain would otherwise cost `limit` walks to be rejected). The
    # estimate can only mispredict a chain that stops above FLOOR; that
    # loses a bound, not soundness.
    set floor [dict get [lindex $narrowed $m] min]
    set maxStep 1
    set lowest $hi
    foreach k $starts {
        if {$k < $lowest} { set lowest $k }
    }
    while {$stack ne {}} {
        set k [lindex $stack end]
        if {[dict exists $table $k]} {
            set stack [lrange $stack 0 end-1]
            continue
        }
        if {[incr analyses] > $maxAnalyses} {
            return [Rejected state-budget "more than $maxAnalyses state walks" $base]
        }
        set assumed [lreplace $narrowed $m $m [point $k]]
        set outcome [AnalyzeInstance $view $id $calls $block $params $assumed $monotone $calleeResults \
            $captureSeed [dict create measure $m state $k table $table limit $limit]]
        set fail [dict get $outcome recFail]
        if {$fail ne {}} {
            lassign $fail reason detail
            return [Rejected $reason "state $name=$k: $detail" $base]
        }
        set needs [dict get $outcome recNeeds]
        foreach pair [dict get $outcome recCalls] {
            set a [lindex $pair 1]
            if {[dict get $a min] ne "-inf" && $k - [dict get $a min] > $maxStep} {
                set maxStep [expr {$k - [dict get $a min]}]
            }
        }
        foreach j $needs {
            if {$j < $lowest} { set lowest $j }
        }
        if {$floor ne "-inf" && $lowest > $floor} {
            set remaining [expr {($lowest - $floor + $maxStep - 1) / $maxStep}]
            if {[dict size $seen] + $remaining > $limit} {
                return [Rejected state-budget "measure $name: at least [expr {[dict size $seen] + $remaining}] states predicted from $lowest down to the entry floor $floor (budget $limit)" $base]
            }
        }
        if {$needs ne {}} {
            foreach j [SortInts $needs -decreasing] {
                if {![dict exists $seen $j]} {
                    dict set seen $j 1
                    if {[dict size $seen] > $limit} {
                        return [Rejected state-budget "more than $limit measure states" $base]
                    }
                }
                lappend stack $j
            }
            continue
        }
        dict set table $k [dict get $outcome result]
        foreach pair [dict get $outcome recCalls] {
            lassign $pair e a
            if {[dict exists $callRanges $e]} {
                dict set callRanges $e [join [dict get $callRanges $e] $a]
            } else {
                dict set callRanges $e $a
            }
        }
        set stack [lrange $stack 0 end-1]
    }
    set result never
    foreach k [SortInts [dict keys $table]] {
        set result [join $result [dict get $table $k]]
    }
    if {$result eq "never" || [dict get $result min] eq "-inf" || [dict get $result max] eq "+inf"} {
        return [Rejected unsupported-result "the successful-result Range is [show $result]" \
            [dict merge $base [dict create states $table]]]
    }
    set callText {}
    dict for {e a} $callRanges {
        set args [hir::get $view $e args]
        lappend callText $e [hir::induction::ShortExpr $view [lindex $args $m]] $a
    }
    return [dict merge $base [dict create status solved reason {} detail "" states $table \
        result $result calls $callText]]
}

# ---------------------------------------------------------------------------
# The two state-mode transfer changes (see the header)

proc hir::range::RecFail {ctxVar reason detail} {
    upvar 1 $ctxVar ctx
    if {[dict get $ctx recFail] eq {}} {
        dict set ctx recFail [list $reason $detail]
    }
}

# The Range of a self call e with argument Ranges ARGRANGES while the solver
# walks measure state k: the join of the memoized summaries of the states
# its measure argument can select. Records the missing smaller states
# (recNeeds) and, until they are summarized, answers a placeholder that is
# never judged (recIncomplete).
proc hir::range::RecursiveCall {hirVar ctxVar e argRanges} {
    upvar 1 $hirVar hir $ctxVar ctx
    set rec [dict get $ctx rec]
    set m [dict get $rec measure]
    set k [dict get $rec state]
    set limit [dict get $rec limit]
    set a [lindex $argRanges $m]
    if {[IsEmpty $a]} {
        return never
    }
    dict lappend ctx recCalls [list $e $a]
    set incomplete [dict get $ctx recIncomplete]
    set placeholder [ConstrainType $hir $e [unknown]]
    set mn [dict get $a min]
    set mx [dict get $a max]
    if {$mn eq "-inf" || $mx eq "+inf"} {
        if {!$incomplete} {
            RecFail ctx unknown-recursive-arg-range "self call $e: measure argument [show $a]"
        }
        return $placeholder
    }
    if {$mx >= $k} {
        if {!$incomplete} {
            RecFail ctx nondecreasing-call "self call $e: measure argument [show $a] is not below $k"
        }
        return $placeholder
    }
    if {$mx - $mn + 1 > $limit} {
        RecFail ctx state-budget "self call $e: measure argument [show $a] spans more than $limit states"
        return $placeholder
    }
    set table [dict get $rec table]
    set result never
    set missing {}
    for {set j $mn} {$j <= $mx} {set j [expr {$j + 1}]} {
        if {[dict exists $table $j]} {
            set result [join $result [dict get $table $j]]
        } else {
            lappend missing $j
        }
    }
    if {$missing ne {}} {
        dict set ctx recNeeds [concat [dict get $ctx recNeeds] $missing]
        dict set ctx recIncomplete 1
        return $placeholder
    }
    return [ConstrainType $hir $e $result]
}

# 1 | 0 | "": whether condition CONDITION (already walked: its operands'
# Ranges are in ctx exprs) is decided by the Ranges alone at this measure
# state -- ConditionOutcome's own range-decided-branch theorem.
proc hir::range::RecursiveDecided {hir ctx condition} {
    set node [hir::node $hir $condition]
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native"} {
        return ""
    }
    set args [dict get $node args]
    if {[llength $args] != 2} {
        return ""
    }
    set exprs [dict get $ctx exprs]
    lassign $args ea eb
    set ra [expr {[dict exists $exprs $ea] ? [dict get $exprs $ea] : [unknown]}]
    set rb [expr {[dict exists $exprs $eb] ? [dict get $exprs $eb] : [unknown]}]
    return [ComparisonOutcome [dict get [hir::symbol $hir $target] name] $ra $rb]
}

# ---------------------------------------------------------------------------
# Audit output (SELF-RECURSIVE-RESULT-RANGES.md; also native/explain-native
# .tcl's recursive-ranges.txt). One paragraph per self-recursive instance: the
# proof (or the rejection tag) next to the ordinary facts. TRACE 1 also
# prints the memoized state table.
proc hir::range::explainRecursive {spec analysis {trace 0}} {
    set lines {}
    dict for {id r} [dict get $analysis recursive] {
        lappend lines "instance [hir::specialize::label $spec $id]"
        if {[dict get $r status] ne "solved"} {
            lappend lines "  recursive result: rejected ([dict get $r reason]): [dict get $r detail]"
            if {[dict exists $r entry]} {
                lappend lines "  entry (ordinary): [::join [lmap x [dict get $r entry] {show $x}] {, }]"
            }
            if {[dict exists $r resultBefore]} {
                lappend lines "  result (ordinary): [show [dict get $r resultBefore]]"
            }
            continue
        }
        lappend lines "  measure parameter: [dict get $r measureName]"
        lappend lines "  entry: [::join [lmap x [dict get $r entryBefore] {show $x}] {, }]  (after: [::join [lmap x [dict get $r entryAfter] {show $x}] {, }])"
        lappend lines "  external entry: [::join [lmap x [dict get $r external] {show $x}] {, }]"
        lappend lines "  state count: [dict size [dict get $r states]]"
        lappend lines "  self calls:"
        foreach {e text a} [dict get $r calls] {
            lappend lines "    $e  $text  : [show $a]"
        }
        lappend lines "  decrease: proven (every reached self call's measure argument is entirely below its state)"
        lappend lines "  result: [show [dict get $r resultBefore]] -> [show [dict get $r result]]"
        lappend lines "  fits small Int: [fitsSmall [dict get $r result]]"
        if {$trace} {
            foreach k [SortInts [dict keys [dict get $r states]]] {
                lappend lines "    [dict get $r measureName]=$k -> [show [dict get [dict get $r states] $k]]"
            }
        }
    }
    return [::join $lines \n]
}
