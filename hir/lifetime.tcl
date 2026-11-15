# lifetime.tcl -- storage lifetime facts: identity confinement, ordinary-value
# liveness and suspension-aware liveness, per specialization instance
# (STORAGE-LIFETIME-FACTS-MILESTONE-1.md).
#
#   set facts [hir::lifetime::analyze $hir ?-spec SPEC? ?-specialize 0|1?]
#   hir::lifetime::units $facts                -> InstanceIds analyzed
#   hir::lifetime::unit $facts $id             -> one unit's facts (below)
#   hir::lifetime::verdict $facts $id $site $region -> confined|escapes|unknown
#   hir::lifetime::report $facts               -> the fact report, as text
#
# What it is. A backend-independent analysis of analyzed HIR that answers,
# for every specialization instance the program uses (hir/specialize.tcl):
#
#   * identity confinement -- for every object-producing expression (a
#     struct or List construction, a String or other heap-kind native
#     result, a closure that captures, a coroutine, a loop's collected List,
#     the fresh part of a call's result), whether the object it makes may be
#     observed outside a region: the activation, each enclosing loop's
#     iteration, the non-suspending segment it is made in. Three outcomes:
#     `confined` (proven: no path lets it reach a place observable beyond
#     the region), `escapes` (a path the HIR contains lets it reach one:
#     returned, failed with, yielded, carried to the next iteration, stored
#     into context state or into a value that outlives the region) and
#     `unknown` (it reaches something the analysis does not follow: a call
#     through a function value, a C call without a no-escape contract, a
#     message to a coroutine whose code may keep it). Every outcome other
#     than `confined` carries its reasons.
#   * ordinary-value liveness -- for every binding and every pending
#     intermediate result (an operand evaluated and waiting for its
#     consumer), at every program point, whether some path still reads it.
#   * suspension liveness -- for every suspension point (a yield, a call of a
#     function that may yield), the bindings and pending operands needed
#     after the coroutine resumes, and the objects that must stay valid
#     while it is suspended (held by those values, by a suspended callee or
#     by a child coroutine's handle).
#
# What it is not. It changes nothing: no HIR field, no lowering, no backend
# reads it. It decides no representation and applies no width, transport or
# profitability policy: a thousand-field struct is as confined as a pair, a
# String of unknown length as a scalar. It is computed on demand from the
# HIR and the specialization analysis, stored nowhere (no registry, no
# process state), so it is deterministic and isolated between compilations
# by construction.
#
# The model
# ---------
# A *unit* is one used specialization instance: a block's body (or the
# program's top level) under the instance's facts -- its reachable set, its
# call targets (an exact callable parameter makes a call through it direct)
# and its types. Per unit:
#
#   1. A control-flow graph in Botlish's evaluation order (hir::children's):
#      one node per operation, after its operands; a branch and a join per
#      `if`; per loop its operands once, a head, a per-iteration node that
#      binds its clause bindings, the body, and a back edge that replaces a
#      fold's intermediate or appends to a used collecting loop's List;
#      `break` to the loop's exit, `continue` to its head, `return` and
#      `fail` to the unit's exits. A `handle` protects exactly its own call
#      (argument evaluation is not protected), so that call has an
#      exceptional edge to each handler; every other error edge leaves the
#      unit, where nothing of it is read. A call has an error edge when its
#      type-level errors (calleeErrors) or an erased callable may raise
#      (hir::completions::erasureFacts and mayLetErasedThrough: the affine
#      analysis's own rule). Undeclared run-time failures are terminal: no
#      edge. Dead code (outside the instance's reachable set) has no node.
#   2. Variables: every local binding, parameter, capture, loop clause
#      binding, fold intermediate and handler payload; every pending
#      intermediate result that is not a constant (`t:E`, the value of
#      expression E); and a used collecting loop's accumulator (`a:L`). A
#      reference reads its binding at its consumer (bindings are immutable;
#      a mutable collection's logical copies are explicit after
#      hir::mutvec's elaboration). Constants and static functions (a block
#      capturing nothing that is not itself static) need no storage and are
#      no variables.
#   3. Liveness: a backward dataflow over the CFG, one bit per variable.
#   4. Containment: an Andersen-style inclusion analysis. Abstract objects
#      are the unit's producer sites, one per parameter and capture (the
#      caller's objects), the received resume message (y), the installed
#      contexts (CTX) and the module-retained values (MOD). pts(V) is what
#      variable V may be; C(O) what object O may contain (one set per
#      object, field-insensitive). A native's result may be a fresh object
#      that contains, or may be, any object its operands reach (a String
#      result too: a construction plan or a substring region may keep its
#      operands); a mutating collection operation adds its operands to the
#      place it mutates (hir::mutvec::PlaceArgument); an exact call applies
#      its callee unit's summary (which parameters reach its result, which
#      escape, which are stored into which, whether its result is fresh);
#      a call through a function value lets every operand escape (unknown).
#   5. Escape: everything a sink reaches (reach = pts, then C closure):
#      returned or the unit's last value, failed with, yielded, installed or
#      stored in a context, retained by a module binding, stored into a
#      caller-owned value (a parameter's or capture's object), or given to
#      what the analysis does not follow.
#
# Summaries are computed over the call graph's strongly connected
# components, callees first; a recursive component iterates to its least
# fixpoint (summaries only grow, over finite sets). No budget decides a
# fact: an internal guard against non-termination raises, never answers.
#
# The walks that build the CFG follow the program's nesting and carry the
# depth guard (core/deep.tcl; audit/depth-safe-nesting/census.tsv).

namespace eval hir::lifetime {
    # Natives that keep an argument somewhere no result or place shows, by
    # name and why: the category its escape is reported under.
    variable retaining [dict create \
        context#install context \
        affine#register_cleanup runtime]
    # Kinds whose values hold no object (an immediate word in every
    # backend that has objects). An Int that does not fit a word is a
    # runtime service's storage (BigInt limbs), outside these facts.
    variable scalarKinds {int bool unit UnicodeChar cptr rawfloat32 rawfloat64}
}

# ---------------------------------------------------------------------------
# Entry point

proc hir::lifetime::analyze {hir args} {
    hir::activate $hir
    set options [hir::Options hir::lifetime::analyze {-spec "" -specialize 1} $args]
    set spec [dict get $options -spec]
    if {$spec eq ""} {
        set spec [hir::specialize::analyze $hir -specialize [dict get $options -specialize]]
    }
    set env [Environment $hir $spec]
    set units {}
    set graphs [dict create]
    foreach id [dict get $spec used] {
        if {![dict exists $spec instances $id]} continue
        set g [BuildUnit $hir $env $id]
        dict set graphs $id $g
        lappend units $id
    }
    # Callees a unit's calls name that are not among the used instances
    # (an instance only a dormant caller reaches): built too, so every
    # exact call has a summary.
    set work $units
    while {[llength $work]} {
        set work [lassign $work id]
        foreach callee [dict get $graphs $id callees] {
            if {![dict exists $graphs $callee] && [dict exists $spec instances $callee]} {
                dict set graphs $callee [BuildUnit $hir $env $callee]
                lappend units $callee
                lappend work $callee
            }
        }
    }
    set summaries [Summaries $hir $graphs $units]
    set facts [dict create units {} order $units stats [dict create]]
    foreach id $units {
        set g [dict get $graphs $id]
        dict set facts units $id [Facts $hir $g $summaries]
    }
    dict set facts summaries $summaries
    return $facts
}

proc hir::lifetime::units {facts} {
    return [dict get $facts order]
}

proc hir::lifetime::unit {facts id} {
    return [dict get $facts units $id]
}

proc hir::lifetime::verdict {facts id site region} {
    return [dict get $facts units $id verdicts $site $region verdict]
}

# What every unit's build needs of the whole program: the static bindings,
# the erasure facts that decide error edges, the specialization analysis.
proc hir::lifetime::Environment {hir spec} {
    lassign [hir::completions::erasureFacts $hir] erased transparent
    return [dict create spec $spec statics [StaticBindings $hir] erased $erased \
        transparent $transparent]
}

# The bindings whose value needs no storage: bound once to a block that
# captures nothing but other such bindings (a top-level function), by a
# fixpoint over the program's binds.
proc hir::lifetime::StaticBindings {hir} {
    set candidates [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "bind" || [dict get $node binding] eq ""} continue
        set v [dict get $node value]
        if {$v eq "" || ![dict exists $hir exprs $v] || [dict get $hir exprs $v kind] ne "block"} continue
        set b [dict get $node binding]
        if {[dict get $hir bindings $b declaredBy] ne $e} continue
        dict set candidates $b [dict get $hir exprs $v captures]
    }
    set static [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        dict for {b captures} $candidates {
            if {[dict exists $static $b]} continue
            set ok 1
            foreach c $captures {
                if {![dict exists $static $c]} {
                    set ok 0
                    break
                }
            }
            if {$ok} {
                dict set static $b 1
                set changed 1
            }
        }
    }
    return $static
}

# ---------------------------------------------------------------------------
# The control-flow graph of one unit

proc hir::lifetime::BuildUnit {hir env id} {
    set spec [dict get $env spec]
    set inst [dict get $spec instances $id]
    set block [dict get $inst block]
    set reachable [dict create]
    foreach e [dict getdef $inst reachable {}] {
        dict set reachable $e 1
    }
    set g [dict create id $id block $block label [Label $hir $spec $id] spec $spec \
        calls [dict getdef $inst calls {}] overlay [dict getdef $inst overlay {}] \
        reachable $reachable statics [dict get $env statics] erased [dict get $env erased] \
        transparent [dict get $env transparent] \
        next 0 nodes [dict create] cons {} producers [dict create] loops [dict create] \
        loopStack {} exprNodes [dict create] callees {} params {} captures {} \
        indeg [dict create] handled "" yields 0]
    set entry [NewNode g entry $block {} {}]
    dict set g entryNode $entry
    set exit [NewNode g exit $block {} {}]
    set exitx [NewNode g exitx $block {} {}]
    dict set g exitNode $exit
    dict set g exitxNode $exitx
    if {$block eq "program"} {
        set body [dict get $hir roots]
        dict set g unitScope [dict get $hir top]
    } else {
        set bnode [dict get $hir exprs $block]
        set body [dict get $bnode body]
        set defs {}
        set keys [dict getdef $inst args {}]
        set i 0
        foreach b [dict get $bnode params] {
            lappend defs b:$b
            dict lappend g params $b
            set key [lindex $keys $i]
            if {$key eq "" || [Holds $key]} {
                # The caller's object: it stands for everything the caller
                # passed, contents included.
                Con g alloc b:$b p:$b
                Con g containobj p:$b p:$b
            }
            incr i
        }
        foreach b [dict get $bnode captures] {
            if {[dict exists [dict get $g statics] $b]} continue
            lappend defs b:$b
            dict lappend g captures $b
            set type [dict getdef [dict getdef $inst seeds {}] $b ""]
            if {$type eq "" || [Holds $type]} {
                Con g alloc b:$b p:$b
                Con g containobj p:$b p:$b
            }
        }
        dict set g nodes $entry defs $defs
        dict set g unitScope [dict get $bnode bodyScope]
    }
    # A context's, a module's and a received message's objects stand for
    # everything they hold.
    Con g containobj CTX CTX
    Con g containobj MOD MOD
    Con g containobj y y
    lassign [Seq $hir g $body $entry 1] out val
    if {$out ne ""} {
        set r [NewNode g result $block [list $val] {} $out]
        Con g sink result $val $block "the unit's value"
        Edge g $r $exit
    }
    return $g
}

# Unit ID's name for people: the specialization label of a named function;
# a coroutine's thunk or another anonymous block by what it is and where it
# is written (never an expression id, which an edit elsewhere changes).
proc hir::lifetime::Label {hir spec id} {
    set inst [dict get $spec instances $id]
    set block [dict get $inst block]
    if {$block eq "program" || [dict get $inst name] ne ""} {
        return [hir::specialize::label $spec $id]
    }
    if {[dict exists $hir coroutines thunks $block]} {
        set what "the coroutine"
        set call [dict getdef [dict get $hir coroutines thunks $block] call ""]
        if {$call ne "" && [dict exists $hir exprs $call]} {
            set what "the coroutine of [string map {{call of } {}} [What $hir $call]]"
        }
        return "$what constructed at [Origin $hir $block]"
    }
    return "the closure at [Origin $hir $block]"
}

# A new CFG node: KIND, the expression E it stands for, the variables it
# USES and DEFS; linked from node FROM when given. Returns its id.
proc hir::lifetime::NewNode {gVar kind e uses defs {from ""}} {
    upvar 1 $gVar g
    set n [dict get $g next]
    dict set g next [expr {$n + 1}]
    set uses [lmap v $uses {if {[Tracked $v]} {set v} else continue}]
    set defs [lmap v $defs {if {[Tracked $v]} {set v} else continue}]
    dict set g nodes $n [dict create kind $kind expr $e uses $uses defs $defs succ {} exc {} \
        loops [dict get $g loopStack]]
    if {$e ne "" && $e ne "program"} {
        dict lappend g exprNodes $e $n
    }
    if {$from ne ""} {
        Edge g $from $n
    }
    return $n
}

# 1 if V names a variable liveness tracks: a binding, a pending result, an
# accumulator or a loop's position (not "" and not a module-retained
# value).
proc hir::lifetime::Tracked {v} {
    return [expr {$v ne "" && [string index $v 0] in {b t a s}}]
}

proc hir::lifetime::Edge {gVar from to} {
    upvar 1 $gVar g
    dict set g nodes $from succ [concat [dict get $g nodes $from succ] [list $to]]
    dict set g indeg $to 1
}

proc hir::lifetime::ExcEdge {gVar from to} {
    upvar 1 $gVar g
    dict set g nodes $from exc [concat [dict get $g nodes $from exc] [list $to]]
    dict set g indeg $to 1
}

# Appends a containment constraint (Solve has the forms).
proc hir::lifetime::Con {gVar args} {
    upvar 1 $gVar g
    dict lappend g cons $args
}

# Registers expression E as a producer site of kind KIND made at node N.
proc hir::lifetime::Producer {hir gVar e kind n} {
    upvar 1 $gVar g
    dict set g producers o:$e [dict create expr $e kind $kind node $n \
        loops [dict get $g loopStack] origin [Origin $hir $e] what [What $hir $e]]
}

# 1 if expression E does not run in the unit: outside the instance's
# reachable set (or, without one, no normal completion reaches it).
proc hir::lifetime::Dead {hir g e} {
    if {[dict size [dict get $g reachable]]} {
        return [expr {![dict exists [dict get $g reachable] $e]}]
    }
    return [expr {![dict get $hir exprs $e reachable]}]
}

# The static type of expression E in the unit: the instance's overlay, else
# the semantic HIR's.
proc hir::lifetime::TypeOf {hir g e} {
    if {[dict exists [dict get $g overlay] $e]} {
        set t [lindex [dict get $g overlay $e] 0]
        if {$t ne ""} {
            return $t
        }
    }
    return [hir::typeOf $hir $e]
}

# 1 if a value of static type TYPE may be, or hold, an object.
proc hir::lifetime::Holds {type} {
    variable scalarKinds
    if {$type in {never unit}} {
        return 0
    }
    set kind [hir::types::kindOf $type]
    if {$kind in $scalarKinds} {
        return 0
    }
    if {$kind eq "enum" && [catch {hir::enums::IsPayloadFree $type} free] == 0 && $free} {
        return 0
    }
    return 1
}

# 1 if a value of TYPE needs a variable at all (unit and never need none).
proc hir::lifetime::Valued {type} {
    return [expr {$type ni {never unit}}]
}

# The producer kind of an object of static TYPE, for reports.
proc hir::lifetime::KindOf {type} {
    set kind [hir::types::kindOf $type]
    switch -- $kind {
        "" { return value }
        block - native { return closure }
        default { return $kind }
    }
}

# The producer kind of a call's fresh result: its type's; `payload` when
# only an error payload a handler binds can hold one; `fresh` when only a
# place of the caller's can (a callee pushing into a place parameter).
proc hir::lifetime::ResultKind {type holds {err ""}} {
    if {$holds} {
        return [KindOf $type]
    }
    if {$err ne ""} {
        return payload
    }
    return fresh
}

# The value variable of reference NODE in the unit, or "" when the value
# needs no storage here (a root, a static function, an unresolved name).
proc hir::lifetime::RefValue {hir g node} {
    set b [dict get $node binding]
    if {$b eq "" || ![dict exists $hir bindings $b]} {
        return ""
    }
    if {[dict get $hir bindings $b kind] eq "root"} {
        return ""
    }
    if {[dict exists [dict get $g statics] $b]} {
        return ""
    }
    if {[dict get $g block] ne "program" && [hir::isModuleBinding $hir $b]} {
        return m:$b
    }
    return b:$b
}

# The call target of call E in the unit: {native NAME}, {block E} or "".
proc hir::lifetime::Target {hir g e} {
    set node [dict get $hir exprs $e]
    if {[dict exists [dict get $g overlay] $e]} {
        set over [lindex [dict get $g overlay $e] 3]
        if {$over ne ""} {
            return $over
        }
    }
    set target [dict get $node target]
    lassign $target kind id
    if {$kind eq "native"} {
        return [list native [dict get $hir symbols $id name]]
    }
    if {$kind eq "block"} {
        return $target
    }
    return ""
}

# 1 if the block ExprId F needs its closure value at a call (it captures a
# binding that is not static).
proc hir::lifetime::Capturing {hir g f} {
    foreach b [dict get $hir exprs $f captures] {
        if {![dict exists [dict get $g statics] $b]} {
            return 1
        }
    }
    return 0
}

# Evaluates expression E from node CUR; USED is 0 when its value is
# discarded. Returns {OUT VALUE NODE}: the node after E's normal completion
# ("" if it never completes normally), the variable holding its value ("" if
# none) and E's own node ("" if it has none).
proc hir::lifetime::Eval {hir gVar e cur used} {
    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}
    upvar 1 $gVar g
    if {$cur eq "" || [Dead $hir $g $e]} {
        return [list "" "" ""]
    }
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const {
            return [list $cur "" ""]
        }
        ref {
            return [list $cur [RefValue $hir $g $node] ""]
        }
        bind {
            lassign [Eval $hir g [dict get $node value] $cur 1] out val
            if {$out eq ""} {
                return [list "" "" ""]
            }
            set b [dict get $node binding]
            if {$b eq "" || [dict exists [dict get $g statics] $b]} {
                return [list $out "" ""]
            }
            set var b:$b
            set n [NewNode g bind $e [list $val] [list $var] $out]
            Con g copy $var $val
            if {[dict get $g block] eq "program" && [hir::isModuleBinding $hir $b]} {
                Con g sink module $var $e "retained by the module binding [hir::semantic::SourceName $hir $b]"
            }
            set value ""
            if {[Valued [TypeOf $hir $g $e]]} {
                set value $var
            }
            return [list $n $value $n]
        }
        block {
            set uses {}
            foreach b [dict get $node captures] {
                if {[dict exists [dict get $g statics] $b]} continue
                set v [RefValue $hir $g [dict create binding $b]]
                if {$v ne ""} {
                    lappend uses $v
                }
            }
            if {$uses eq {}} {
                return [list $cur "" ""]
            }
            set n [NewNode g closure $e $uses [list t:$e] $cur]
            Producer $hir g $e closure $n
            Con g alloc t:$e o:$e
            foreach v $uses {
                Con g contain o:$e $v
            }
            return [list $n t:$e $n]
        }
        call {
            return [Call $hir g $e $node $cur $used]
        }
        if {
            lassign [Eval $hir g [dict get $node condition] $cur 1] out cval
            if {$out eq ""} {
                return [list "" "" ""]
            }
            set branch [NewNode g branch $e [list $cval] {} $out]
            set def ""
            if {$used && [Valued [TypeOf $hir $g $e]]} {
                set def t:$e
            }
            set ends {}
            foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
                lassign [Seq $hir g $body $branch $used] bout bval
                if {$bout eq ""} continue
                set phi [NewNode g phi $e [list $bval] [list $def] $bout]
                Con g copy $def $bval
                lappend ends $phi
            }
            if {$ends eq {}} {
                return [list "" "" ""]
            }
            set join [NewNode g join $e {} {}]
            foreach end $ends {
                Edge g $end $join
            }
            return [list $join $def $join]
        }
        loop - listloop - countloop - lockloop {
            return [Loop $hir g $e $node $cur $used]
        }
        return {
            set v [dict get $node value]
            set val ""
            set out $cur
            if {$v ne ""} {
                lassign [Eval $hir g $v $cur 1] out val
                if {$out eq ""} {
                    return [list "" "" ""]
                }
            }
            set n [NewNode g return $e [list $val] {} $out]
            Con g sink result $val $e "returned"
            Edge g $n [dict get $g exitNode]
            return [list "" "" $n]
        }
        break {
            set loop [dict get $node target]
            set v [dict get $node value]
            set val ""
            set out $cur
            if {$v ne ""} {
                lassign [Eval $hir g $v $cur 1] out val
                if {$out eq ""} {
                    return [list "" "" ""]
                }
            }
            if {![dict exists $g loops $loop]} {
                return [list "" "" ""]
            }
            set frame [dict get $g loops $loop]
            set res [dict get $frame result]
            if {$v eq ""} {
                set val [dict get $frame carried]
            }
            set n [NewNode g break $e [list $val] [list $res] $out]
            Con g copy $res $val
            Edge g $n [dict get $frame exit]
            return [list "" "" $n]
        }
        continue {
            set loop [dict get $node target]
            if {![dict exists $g loops $loop]} {
                return [list "" "" ""]
            }
            set n [NewNode g continue $e {} {} $cur]
            Edge g $n [dict get $g loops $loop head]
            return [list "" "" $n]
        }
        struct {
            set vals {}
            set out $cur
            foreach f [dict get $node fields] {
                lassign [Eval $hir g $f $out 1] out v
                if {$out eq ""} {
                    return [list "" "" ""]
                }
                lappend vals $v
            }
            set n [NewNode g struct $e $vals [list t:$e] $out]
            Producer $hir g $e struct $n
            Con g alloc t:$e o:$e
            foreach v $vals {
                Con g contain o:$e $v
            }
            return [list $n t:$e $n]
        }
        project {
            lassign [Eval $hir g [dict get $node receiver] $cur 1] out rv
            if {$out eq ""} {
                return [list "" "" ""]
            }
            set def ""
            if {[Valued [TypeOf $hir $g $e]]} {
                set def t:$e
            }
            set n [NewNode g project $e [list $rv] [list $def] $out]
            if {[Holds [TypeOf $hir $g $e]]} {
                Con g load $def $rv
            }
            return [list $n $def $n]
        }
        ok - error {
            lassign [Eval $hir g [dict get $node value] $cur 1] out v
            if {$out eq ""} {
                return [list "" "" ""]
            }
            set n [NewNode g wrap $e [list $v] [list t:$e] $out]
            Producer $hir g $e result $n
            Con g alloc t:$e o:$e
            Con g contain o:$e $v
            return [list $n t:$e $n]
        }
        fail {
            set val ""
            set out $cur
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                lassign [Eval $hir g [dict get $node value] $cur 1] out val
                if {$out eq ""} {
                    return [list "" "" ""]
                }
            }
            set n [NewNode g fail $e [list $val] {} $out]
            Con g sink error $val $e "the payload of [dict get $node name]"
            Edge g $n [dict get $g exitxNode]
            return [list "" "" $n]
        }
        handle {
            return [Handle $hir g $e $node $cur $used]
        }
    }
    error "hir::lifetime: unknown expression kind [dict get $node kind] ($e)"
}

# Evaluates the statements LIST in order from node CUR; USED is 0 when the
# sequence's value is discarded. Returns {OUT VALUE}.
proc hir::lifetime::Seq {hir gVar list cur used} {
    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}
    upvar 1 $gVar g
    set value ""
    set last [expr {[llength $list] - 1}]
    set i 0
    foreach s $list {
        lassign [Eval $hir g $s $cur [expr {$used && $i == $last}]] cur value
        if {$cur eq ""} {
            return [list "" ""]
        }
        incr i
    }
    return [list $cur $value]
}

# A call (Eval's case): its callee when its value is needed, its arguments
# in order, then its node; the containment its target implies.
proc hir::lifetime::Call {hir gVar e node cur used} {
    upvar 1 $gVar g
    set target [Target $hir $g $e]
    lassign $target tkind tid
    set out $cur
    set calleeVal ""
    set evalCallee 1
    if {$tkind eq "native"} {
        set evalCallee 0
    } elseif {$tkind eq "block" && ![Capturing $hir $g $tid]} {
        set evalCallee 0
    }
    if {$evalCallee} {
        lassign [Eval $hir g [dict get $node callee] $out 1] out calleeVal
        if {$out eq ""} {
            return [list "" "" ""]
        }
    }
    set vals {}
    set argExprs [dict get $node args]
    foreach a $argExprs {
        lassign [Eval $hir g $a $out 1] out v
        if {$out eq ""} {
            return [list "" "" ""]
        }
        lappend vals $v
    }
    set type [TypeOf $hir $g $e]
    set def ""
    if {[Valued $type]} {
        set def t:$e
    }
    set n [NewNode g call $e [concat [list $calleeVal] $vals] [list $def] $out]
    set holds [Holds $type]
    set res [if {$holds} {set def} else {string cat ""}]
    # Error edges (the affine analysis's rule): a declared error, or one an
    # erased callable lets through.
    set names [dict getdef $node calleeErrors {}]
    if {[dict get $g erased] ne {} && [hir::completions::mayLetErasedThrough $hir $e [dict get $g transparent]]} {
        set names [lsort -unique [concat $names [dict get $g erased]]]
    }
    if {[dict get $g handled] eq $e} {
        # A handled call: what its handlers do not handle leaves the unit.
        set names [lmap name $names {
            if {$name in [dict get $g handledNames]} continue
            set name
        }]
    }
    if {$names ne {}} {
        dict set g nodes $n errors $names
        ExcEdge g $n [dict get $g exitxNode]
    }
    # The error value a handler of this call binds ("" when none does).
    set err ""
    if {[dict get $g handled] eq $e} {
        set err x:$e
    }
    if {$tkind eq "native"} {
        NativeCall $hir g $e $n $tid $argExprs $vals $res $err $holds $type
    } elseif {$tkind eq "block"} {
        set callee [dict getdef [dict get $g calls] $e ""]
        if {$callee eq ""} {
            set callee [hir::specialize::genericInstance $hir [dict get $g spec] $tid]
        }
        if {$callee eq ""} {
            UnknownCall $hir g $e $n $calleeVal $vals $res $err $holds $type
        } else {
            if {$callee ni [dict get $g callees]} {
                dict lappend g callees $callee
            }
            # The fresh part of the call: every object the callee made that
            # it returns, fails with or leaves in a place of the caller's,
            # nested ones too (kept as a producer only where one lands).
            Producer $hir g $e [ResultKind $type $holds $err] $n
            Con g containobj o:$e o:$e
            Con g call $e $callee $tid $vals $calleeVal $res $err [KindOf $type]
            if {[hir::coroutines::MayYield $hir $tid]} {
                dict set g nodes $n suspends [list call $tid $vals]
            }
        }
    } else {
        UnknownCall $hir g $e $n $calleeVal $vals $res $err $holds $type
    }
    if {$type eq "never"} {
        return [list "" "" $n]
    }
    return [list $n $def $n]
}

# The containment of a call of native NAME (Call's case).
proc hir::lifetime::NativeCall {hir gVar e n name argExprs vals res err holds type} {
    upvar 1 $gVar g
    variable retaining
    set what [string cat "an argument of " $name]
    switch -- $name {
        coroutine#yield {
            foreach v $vals {
                Con g sink yield $v $e "yielded to the resumer"
            }
            if {$res ne ""} {
                Con g alloc $res y
            }
            dict set g yields 1
            dict set g nodes $n suspends [list yield "" $vals]
            return
        }
        coroutine#create {
            Producer $hir g $e coroutine $n
            if {$res ne ""} {
                Con g alloc $res o:$e
            }
            set thunk [lindex $argExprs 0]
            foreach v $vals {
                Con g contain o:$e $v
            }
            if {$thunk ne "" && [dict get $hir exprs $thunk kind] eq "block"} {
                set unit [dict getdef [dict get $g calls] $thunk ""]
                if {$unit eq ""} {
                    set unit [hir::specialize::genericInstance $hir [dict get $g spec] $thunk]
                }
                if {$unit ne ""} {
                    if {$unit ni [dict get $g callees]} {
                        dict lappend g callees $unit
                    }
                    Con g thunk $e $unit $thunk [lindex $vals 0] o:$e
                }
            }
            return
        }
        coroutine#start - coroutine#resume {
            set h [lindex $vals 0]
            set msgs [lrange $vals 1 end]
            foreach v $msgs {
                Con g store $h $v
            }
            set thunk [hir::coroutines::thunkOfHandle $hir [lindex $argExprs 0]]
            set unit ""
            if {$thunk ne ""} {
                set unit [dict getdef [dict get $g calls] $thunk ""]
                if {$unit eq ""} {
                    set unit [hir::specialize::genericInstance $hir [dict get $g spec] $thunk]
                }
            }
            if {$unit ne "" && $unit ni [dict get $g callees]} {
                dict lappend g callees $unit
            }
            foreach v $msgs {
                Con g message $e $unit $v
            }
            if {$holds} {
                Producer $hir g $e [KindOf $type] $n
                Con g alloc $res o:$e
                Con g containobj o:$e o:$e
                Con g loadreach $res $h
            }
            return
        }
        coroutine#release - coroutine#abandon - std::coroutine::done? {
            return
        }
        context#load {
            if {$res ne ""} {
                Con g alloc $res CTX
            }
            return
        }
        mutable_vector#share {
            # A logical copy: a new header over the same backing; its
            # elements are the source's (copy-on-write keeps them apart).
            if {$holds} {
                Producer $hir g $e [KindOf $type] $n
                Con g alloc $res o:$e
                Con g containload o:$e [lindex $vals 0]
            }
            return
        }
    }
    if {[dict exists $retaining $name]} {
        foreach v $vals {
            Con g sink [dict get $retaining $name] $v $e "kept by $name"
        }
    }
    set meta [core::native::metadata $name]
    # Only operands that may hold an object carry one.
    set objVals [lmap a $argExprs v $vals {
        if {[Holds [TypeOf $hir $g $a]]} {set v} else {string cat ""}
    }]
    if {[dict get $meta foreign] ne "" || [dict get $meta extern] ne ""} {
        # A C call: byte storage it borrows is exposed for exactly this call
        # (hir/borrow.tcl); any other object given to C is not followed.
        set borrowed [lmap t [dict getdef [dict get $hir exprs $e] borrows {}] {lindex $t 0}]
        set i 0
        foreach v $objVals {
            if {$i ni $borrowed} {
                Con g sink foreign $v $e "passed to the C function $name"
            }
            incr i
        }
    }
    # A place the call mutates in place gets the other operands.
    set i 0
    foreach a $argExprs v $vals {
        if {[hir::mutvec::PlaceArgument $hir $e $a]} {
            set path [hir::mutvec::Path $hir $a]
            if {$path ne ""} {
                set root [RefValue $hir $g [dict create binding [lindex $path 0]]]
                if {$root ne ""} {
                    foreach other $objVals {
                        if {$other ne $v} {
                            Con g storereach $root $other
                        }
                    }
                }
            }
        }
        incr i
    }
    if {!$holds} {
        return
    }
    set shape [dict get $meta resultShape]
    if {[lindex $shape 0] in {element mutvec-element mutarray-element}} {
        # By its registration, an element of operand K: no new object.
        Con g load $res [lindex $objVals [lindex $shape 1]]
        return
    }
    Producer $hir g $e [KindOf $type] $n
    Con g alloc $res o:$e
    if {$name eq "list"} {
        # A List literal holds exactly its operands.
        foreach v $objVals {
            Con g contain o:$e $v
        }
        return
    }
    # Anything else may be, or hold, any object its operands reach, and
    # fresh objects of its own.
    Con g containobj o:$e o:$e
    set kind [KindOf $type]
    foreach v $objVals {
        # The result may be an object its operands reach -- only one of its
        # own kind: a MutableVector is never a String it holds.
        Con g reachcopy $res $v $kind
        Con g containreach o:$e $v
    }
}

# A call this unit cannot resolve to a callee: every operand and the callee
# value may be kept by what runs (unknown); the result is fresh.
proc hir::lifetime::UnknownCall {hir gVar e n calleeVal vals res err holds type} {
    upvar 1 $gVar g
    foreach v [concat [list $calleeVal] $vals] {
        Con g sink unknown $v $e "passed to a call through a function value"
    }
    if {$holds || $err ne ""} {
        Producer $hir g $e [ResultKind $type $holds $err] $n
        Con g alloc $res o:$e
        Con g alloc $err o:$e
        Con g containobj o:$e o:$e
    }
}

# A handle (Eval's case): its call, whose exceptional edge reaches each
# handler, and the join of the call's value and every handler's.
proc hir::lifetime::Handle {hir gVar e node cur used} {
    upvar 1 $gVar g
    set call [dict get $node call]
    set outer [dict get $g handled]
    set outerNames [dict getdef $g handledNames {}]
    dict set g handled $call
    dict set g handledNames [dict get $node handlerNames]
    lassign [Eval $hir g $call $cur 1] cout cval cnode
    dict set g handled $outer
    dict set g handledNames $outerNames
    if {$cnode eq ""} {
        return [list "" "" ""]
    }
    set def ""
    if {$used && [Valued [TypeOf $hir $g $e]]} {
        set def t:$e
    }
    set ends {}
    if {$cout ne ""} {
        set phi [NewNode g phi $e [list $cval] [list $def] $cout]
        Con g copy $def $cval
        lappend ends $phi
    }
    set payloads [dict getdef $node handlerPayloads {}]
    set index 0
    foreach name [dict get $node handlerNames] body [dict get $node handlerBodies] {
        set payload [lindex $payloads $index]
        set defs {}
        if {$payload ne ""} {
            set defs [list b:$payload]
        }
        set h [NewNode g handler $e {} $defs]
        dict set g nodes $h handles $name
        ExcEdge g $cnode $h
        if {$payload ne ""} {
            Con g copy b:$payload x:$call
        }
        lassign [Seq $hir g $body $h $used] hout hval
        if {$hout ne ""} {
            set phi [NewNode g phi $e [list $hval] [list $def] $hout]
            Con g copy $def $hval
            lappend ends $phi
        }
        incr index
    }
    if {$ends eq {}} {
        return [list "" "" ""]
    }
    set join [NewNode g join $e {} {}]
    foreach end $ends {
        Edge g $end $join
    }
    return [list $join $def $join]
}

# A loop of any kind (Eval's case).
proc hir::lifetime::Loop {hir gVar e node cur used} {
    upvar 1 $gVar g
    set kind [dict get $node kind]
    switch -- $kind {
        listloop { set operands [list [dict get $node iterable]] }
        countloop { set operands [list [dict get $node start] [dict get $node end]] }
        lockloop { set operands [hir::loopOperands $node] }
        default { set operands {} }
    }
    set out $cur
    set vals {}
    foreach o $operands {
        lassign [Eval $hir g $o $out 1] out v
        if {$out eq ""} {
            return [list "" "" ""]
        }
        lappend vals $v
    }
    set fold [hir::isFold $hir $e]
    set carried ""
    set acc ""
    if {$fold} {
        lassign [Eval $hir g [dict get $node foldInitial] $out 1] out ival
        if {$out eq ""} {
            return [list "" "" ""]
        }
        set carried b:[dict get $node foldBinding]
        set out [NewNode g foldinit $e [list $ival] [list $carried] $out]
        Con g copy $carried $ival
    } elseif {$used && [Valued [TypeOf $hir $g $e]]} {
        set acc a:$e
        set carried $acc
        set out [NewNode g accinit $e {} [list $acc] $out]
        Producer $hir g $e list $out
        Con g alloc $acc o:$e
    }
    set result ""
    if {$used && [Valued [TypeOf $hir $g $e]]} {
        set result t:$e
    }
    # A loop over a domain keeps its position (an index, a counter) from
    # one iteration to the next: a value of the loop's own, no binding's.
    set position ""
    if {$kind ne "loop"} {
        set position s:$e
        set out [NewNode g start $e {} [list $position] $out]
    }
    set head [NewNode g head $e {} {} $out]
    set exit [NewNode g loopexit $e {} {}]
    dict set g loops $e [dict create head $head exit $exit carried $carried result $result \
        fold $fold acc $acc kind $kind]
    # The operands an iteration reads again: the iterables, the ends.
    set persistent {}
    switch -- $kind {
        listloop { set persistent $vals }
        countloop { set persistent [list [lindex $vals 1]] }
        lockloop {
            set i 0
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    lappend persistent [lindex $vals $i]
                    incr i
                } else {
                    lappend persistent [lindex $vals [expr {$i + 1}]]
                    incr i 2
                }
            }
        }
    }
    set iterFrom $head
    if {$kind ne "loop"} {
        set test [NewNode g test $e [concat $persistent [list $position]] {} $head]
        set done [NewNode g done $e [list $carried] [list $result] $test]
        Con g copy $result $carried
        Edge g $done $exit
        set iterFrom $test
    }
    dict set g loopStack [concat [dict get $g loopStack] [list $e]]
    set clause {}
    foreach b [hir::loopClauseBindings $node] {
        lappend clause b:$b
    }
    set iter [NewNode g iter $e {} [concat $clause [list $position]] $iterFrom]
    switch -- $kind {
        listloop {
            Con g load b:[dict get $node elementBinding] [lindex $vals 0]
        }
        lockloop {
            set i 0
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    Con g load b:[dict get $domain binding] [lindex $vals $i]
                    incr i
                } else {
                    incr i 2
                }
            }
        }
    }
    lassign [Seq $hir g [dict get $node body] $iter [expr {$fold || $acc ne ""}]] bout bval
    if {$bout ne ""} {
        if {$fold} {
            set next [NewNode g foldnext $e [list $bval] [list $carried] $bout]
            Con g copy $carried $bval
            Edge g $next $head
        } elseif {$acc ne ""} {
            set next [NewNode g collect $e [list $bval $acc] [list $acc] $bout]
            Con g store $acc $bval
            Edge g $next $head
        } else {
            set next [NewNode g backedge $e {} {} $bout]
            Edge g $next $head
        }
    }
    dict set g loopStack [lrange [dict get $g loopStack] 0 end-1]
    if {![dict exists $g indeg $exit]} {
        return [list "" "" ""]
    }
    return [list $exit $result $exit]
}

# ---------------------------------------------------------------------------
# Containment: the inclusion constraints of one unit, solved
#
# Constraint forms (Con), V a variable, O an object, "" no value:
#   alloc V O          pts(V) has O
#   copy D S           pts(D) >= pts(S)
#   reachcopy D S K    pts(D) >= reach(pts(S)), those of kind K ("" any)
#   load D S           pts(D) >= C(o) for o in pts(S)
#   loadreach D S      pts(D) >= reach(C(o)) for o in pts(S)
#   contain O S        C(O) >= pts(S)
#   containreach O S   C(O) >= reach(pts(S))
#   containload O S    C(O) >= reach(C(o)) for o in pts(S)
#   store D S          C(o) >= pts(S) for o in pts(D)
#   storereach D S     C(o) >= reach(pts(S)) for o in pts(D)
#   sink CAT S E TEXT  everything reach(pts(S)) escapes, for category CAT
#   call E U F VALS CV RES ERR K  an exact call of unit U (block F), its
#                      result of kind K
#   thunk E U F CV O   a coroutine construction of thunk unit U
#   message E U V      V sent to a coroutine of thunk unit U ("" unknown)

# The objects variable V may be (a dict object -> 1).
proc hir::lifetime::PtsOf {pts v} {
    if {$v eq ""} {
        return {}
    }
    if {[string match m:* $v]} {
        return {MOD 1}
    }
    return [dict getdef $pts $v {}]
}

# The closure of the objects SET under containment.
proc hir::lifetime::Reach {contents set} {
    set result $set
    set work [dict keys $set]
    while {[llength $work]} {
        set work [lassign $work o]
        dict for {c -} [dict getdef $contents $o {}] {
            if {![dict exists $result $c]} {
                dict set result $c 1
                lappend work $c
            }
        }
    }
    return $result
}

# The union of the contents of the objects in SET.
proc hir::lifetime::Contents {contents set} {
    set result {}
    dict for {o -} $set {
        set result [dict merge $result [dict getdef $contents $o {}]]
    }
    return $result
}

# Adds SET to entry KEY of the dict variable TABLEVAR; 1 if it grew.
proc hir::lifetime::Add {tableVar key set} {
    upvar 1 $tableVar table
    if {$key eq "" || [dict size $set] == 0} {
        return 0
    }
    set old [dict getdef $table $key {}]
    set new [dict merge $old $set]
    if {[dict size $new] == [dict size $old]} {
        return 0
    }
    dict set table $key $new
    return 1
}

# The objects of SET that a value of producer kind KIND may be: those of
# that kind, and those whose kind is not known (a caller's, a context's, a
# fresh result of no fixed kind). `value`, `payload` and `fresh` are no
# fixed kind.
proc hir::lifetime::OfKind {kinds set kind} {
    if {$kind in {value payload fresh}} {
        return $set
    }
    set result {}
    dict for {o -} $set {
        set k [dict getdef $kinds $o ""]
        if {$k eq "" || $k in {value payload fresh} || $k eq $kind} {
            dict set result $o 1
        }
    }
    return $result
}

# The empty summary: what a callee no fixpoint round has analyzed yet
# contributes (a least fixpoint starts from nothing).
proc hir::lifetime::EmptySummary {} {
    return [dict create resultParams {} escParams {} stores {} freshInto {} fresh 0 \
        global {} capResult 0 capEscape {} msg {} params {} name ""]
}

# Solves unit G's constraints under SUMMARIES. Returns {PTS CONTENTS}.
proc hir::lifetime::Solve {g summaries} {
    set pts [dict create]
    set contents [dict create]
    set cons [dict get $g cons]
    # The kind of each producer's object (others -- a caller's, a
    # context's, a message -- may be of any kind).
    set kinds [dict create]
    dict for {site p} [dict get $g producers] {
        dict set kinds $site [dict get $p kind]
    }
    set changed 1
    set rounds 0
    while {$changed} {
        if {[incr rounds] > 100000} {
            error "hir::lifetime: internal: no fixpoint for unit [dict get $g id]"
        }
        set changed 0
        foreach con $cons {
            set rest [lassign $con form]
            switch -- $form {
                alloc {
                    lassign $rest v o
                    if {$v ne "" && [Add pts $v [dict create $o 1]]} { set changed 1 }
                }
                copy {
                    lassign $rest d s
                    if {[Add pts $d [PtsOf $pts $s]]} { set changed 1 }
                }
                reachcopy {
                    lassign $rest d s kind
                    if {$d ne ""} {
                        set r [Reach $contents [PtsOf $pts $s]]
                        if {$kind ne ""} {
                            set r [OfKind $kinds $r $kind]
                        }
                        if {[Add pts $d $r]} { set changed 1 }
                    }
                }
                load {
                    lassign $rest d s
                    if {$d ne "" && [Add pts $d [Contents $contents [PtsOf $pts $s]]]} { set changed 1 }
                }
                loadreach {
                    lassign $rest d s
                    if {$d ne "" && [Add pts $d [Reach $contents [Contents $contents [PtsOf $pts $s]]]]} { set changed 1 }
                }
                contain {
                    lassign $rest o s
                    if {[Add contents $o [PtsOf $pts $s]]} { set changed 1 }
                }
                containreach {
                    lassign $rest o s
                    if {[Add contents $o [Reach $contents [PtsOf $pts $s]]]} { set changed 1 }
                }
                containload {
                    lassign $rest o s
                    if {[Add contents $o [Reach $contents [Contents $contents [PtsOf $pts $s]]]]} { set changed 1 }
                }
                store - storereach {
                    lassign $rest d s
                    set what [PtsOf $pts $s]
                    if {$form eq "storereach"} {
                        set what [Reach $contents $what]
                    }
                    dict for {o -} [PtsOf $pts $d] {
                        if {[Add contents $o $what]} { set changed 1 }
                    }
                }
                containobj {
                    lassign $rest o obj
                    if {[Add contents $o [dict create $obj 1]]} { set changed 1 }
                }
                storeobj {
                    lassign $rest d obj
                    dict for {o -} [PtsOf $pts $d] {
                        if {[Add contents $o [dict create $obj 1]]} { set changed 1 }
                    }
                }
                call {
                    lassign $rest e unit f vals cv res err kind
                    set s [dict getdef $summaries $unit [EmptySummary]]
                    set i 0
                    foreach v $vals {
                        if {$i in [dict get $s resultParams]} {
                            set r [Reach $contents [PtsOf $pts $v]]
                            if {[Add pts $res [OfKind $kinds $r $kind]]} { set changed 1 }
                            if {[Add pts $err $r]} { set changed 1 }
                        }
                        incr i
                    }
                    if {[dict get $s fresh]} {
                        if {[Add pts $res [dict create o:$e 1]]} { set changed 1 }
                        if {[Add pts $err [dict create o:$e 1]]} { set changed 1 }
                    }
                    foreach o [dict get $s global] {
                        if {[Add pts $res [dict create $o 1]]} { set changed 1 }
                        if {[Add pts $err [dict create $o 1]]} { set changed 1 }
                    }
                    if {[dict get $s capResult] && $cv ne ""} {
                        set r [Reach $contents [PtsOf $pts $cv]]
                        if {[Add pts $res [OfKind $kinds $r $kind]]} { set changed 1 }
                        if {[Add pts $err $r]} { set changed 1 }
                    }
                    foreach pair [dict get $s stores] {
                        lassign $pair from into
                        set what [Reach $contents [PtsOf $pts [lindex $vals $from]]]
                        dict for {o -} [PtsOf $pts [lindex $vals $into]] {
                            if {[Add contents $o $what]} { set changed 1 }
                        }
                    }
                    foreach into [dict get $s freshInto] {
                        dict for {o -} [PtsOf $pts [lindex $vals $into]] {
                            if {[Add contents $o [dict create o:$e 1]]} { set changed 1 }
                        }
                    }
                }
                thunk - message - sink {
                    # (Escapes only: Escapes reads them after the fixpoint.)
                }
                default {
                    error "hir::lifetime: unknown constraint $form"
                }
            }
        }
    }
    return [list $pts $contents]
}

# The categories that are definite escapes (a path the HIR holds), and the
# ones the analysis does not follow (unknown).
proc hir::lifetime::Definite {category} {
    return [expr {$category ni {unknown foreign message}}]
}

# Records REASON for every object of SET in the escape table ESCVAR.
proc hir::lifetime::Escape {escVar set reason} {
    upvar 1 $escVar esc
    set key [list [dict get $reason category] [dict get $reason at] [dict get $reason detail]]
    dict for {o -} $set {
        if {![dict exists $esc $o $key]} {
            dict set esc $o $key $reason
        }
    }
}

proc hir::lifetime::Reason {category at detail {definite ""}} {
    if {$definite eq ""} {
        set definite [Definite $category]
    }
    return [dict create category $category definite $definite at $at detail $detail]
}

# The escape table of unit G: object -> {key -> reason}, everything a sink
# reaches, what a caller-owned object or a context or module value holds,
# and what callees and coroutines are summarized to keep. CHANNELS limits it
# to the sinks of those categories ("" all), for the summaries.
proc hir::lifetime::Escapes {hir g summaries pts contents {exclude {}}} {
    set esc [dict create]
    foreach con [dict get $g cons] {
        set rest [lassign $con form]
        switch -- $form {
            sink {
                lassign $rest category s at detail
                if {$category in $exclude} continue
                Escape esc [Reach $contents [PtsOf $pts $s]] [Reason $category $at $detail]
            }
            call {
                lassign $rest e unit f vals cv res err
                set s [dict getdef $summaries $unit [EmptySummary]]
                set i 0
                foreach v $vals {
                    if {[dict exists $s escParams $i]} {
                        set why [dict get $s escParams $i]
                        Escape esc [Reach $contents [PtsOf $pts $v]] [Reason callee $e \
                            "through [dict get $s name]'s parameter [lindex [dict get $s params] $i]: [dict get $why detail]" \
                            [dict get $why definite]]
                    }
                    incr i
                }
                if {[dict size [dict get $s capEscape]] && $cv ne ""} {
                    set why [dict get $s capEscape]
                    Escape esc [Reach $contents [PtsOf $pts $cv]] [Reason callee $e \
                        "through what [dict get $s name] captures: [dict get $why detail]" [dict get $why definite]]
                }
            }
            thunk {
                lassign $rest e unit f cv o
                set s [dict getdef $summaries $unit [EmptySummary]]
                if {[dict size [dict get $s capEscape]] && $cv ne ""} {
                    set why [dict get $s capEscape]
                    Escape esc [Reach $contents [PtsOf $pts $cv]] [Reason callee $e \
                        "through the coroutine's code: [dict get $why detail]" [dict get $why definite]]
                }
            }
            message {
                if {"message" in $exclude} continue
                lassign $rest e unit v
                if {$unit eq ""} {
                    Escape esc [Reach $contents [PtsOf $pts $v]] [Reason message $e \
                        "sent to a coroutine whose code is not known here"]
                } else {
                    set s [dict getdef $summaries $unit [EmptySummary]]
                    if {[dict size [dict get $s msg]]} {
                        Escape esc [Reach $contents [PtsOf $pts $v]] [Reason message $e \
                            "sent to a coroutine whose code may keep it: [dict get $s msg detail]"]
                    }
                }
            }
        }
    }
    if {"context" ni $exclude} {
        Escape esc [Reach $contents {CTX 1}] [Reason context "" "context-owned state (installed for the run)"]
    }
    if {"module" ni $exclude} {
        Escape esc [Reach $contents {MOD 1}] [Reason module "" "a module-retained value"]
    }
    if {"caller" ni $exclude} {
        foreach b [concat [dict get $g params] [dict get $g captures]] {
            set held [Reach $contents [Contents $contents [dict create p:$b 1]]]
            Escape esc $held [Reason caller "" "stored into a value the caller owns ([hir::semantic::SourceName $hir $b])"]
        }
    }
    return $esc
}

# The summary of unit G (pts, contents solved): what its callers' analyses
# need to know of a call.
proc hir::lifetime::Summary {hir g summaries pts contents} {
    set s [EmptySummary]
    set name [dict get $g label]
    dict set s name $name
    set params [dict get $g params]
    dict set s params [lmap b $params {hir::semantic::SourceName $hir $b}]
    set results {}
    foreach con [dict get $g cons] {
        set rest [lassign $con form]
        if {$form eq "sink" && [lindex $rest 0] in {result error}} {
            set results [dict merge $results [Reach $contents [PtsOf $pts [lindex $rest 1]]]]
        }
    }
    set i 0
    foreach b $params {
        if {[dict exists $results p:$b]} {
            dict lappend s resultParams $i
        }
        incr i
    }
    foreach b [dict get $g captures] {
        if {[dict exists $results p:$b]} {
            dict set s capResult 1
        }
    }
    dict for {o -} $results {
        if {[string match o:* $o] || $o eq "y"} {
            dict set s fresh 1
        } elseif {$o in {CTX MOD}} {
            dict lappend s global $o
        }
    }
    # Escapes other than through the result: the callers' own concern.
    set esc [Escapes $hir $g $summaries $pts $contents {result error caller}]
    set i 0
    foreach b $params {
        if {[dict exists $esc p:$b]} {
            dict set s escParams $i [Strongest [dict values [dict get $esc p:$b]]]
        }
        incr i
    }
    set capReasons {}
    foreach b [dict get $g captures] {
        if {[dict exists $esc p:$b]} {
            lappend capReasons {*}[dict values [dict get $esc p:$b]]
        }
    }
    if {$capReasons ne {}} {
        dict set s capEscape [Strongest $capReasons]
    }
    # Stores into a caller's place parameter.
    set i 0
    foreach b $params {
        set held [Reach $contents [Contents $contents [dict create p:$b 1]]]
        set j 0
        foreach c $params {
            if {$j != $i && [dict exists $held p:$c]} {
                dict lappend s stores [list $j $i]
            }
            incr j
        }
        dict for {o -} $held {
            if {[string match o:* $o] || $o eq "y"} {
                dict lappend s freshInto $i
                break
            }
        }
        incr i
    }
    # A resume message: kept when the received value reaches anything but
    # the unit's own locals, here or in a callee it is suspended in.
    set all [Escapes $hir $g $summaries $pts $contents]
    if {[dict exists $all y]} {
        dict set s msg [Strongest [dict values [dict get $all y]]]
    } else {
        foreach n [dict keys [dict get $g nodes]] {
            set node [dict get $g nodes $n]
            if {[dict exists $node suspends] && [lindex [dict get $node suspends] 0] eq "call"} {
                set callee [dict getdef [dict get $g calls] [dict get $node expr] ""]
                if {$callee eq ""} {
                    set callee [hir::specialize::genericInstance $hir [dict get $g spec] [lindex [dict get $node suspends] 1]]
                }
                set cs [dict getdef $summaries $callee [EmptySummary]]
                if {[dict size [dict get $cs msg]]} {
                    dict set s msg [dict get $cs msg]
                    break
                }
            }
        }
    }
    return $s
}

# The reason to report of REASONS: a definite one first, else the first.
proc hir::lifetime::Strongest {reasons} {
    foreach r $reasons {
        if {[dict get $r definite]} {
            return $r
        }
    }
    return [lindex $reasons 0]
}

# The summaries of every unit, callees first; a recursive component of the
# call graph is iterated to its least fixpoint.
proc hir::lifetime::Summaries {hir graphs units} {
    set summaries [dict create]
    foreach component [Components $graphs $units] {
        set rounds 0
        while 1 {
            if {[incr rounds] > 10000} {
                error "hir::lifetime: internal: no summary fixpoint for {$component}"
            }
            set changed 0
            foreach id $component {
                set g [dict get $graphs $id]
                lassign [Solve $g $summaries] pts contents
                set s [Summary $hir $g $summaries $pts $contents]
                if {![dict exists $summaries $id] || [dict get $summaries $id] ne $s} {
                    dict set summaries $id $s
                    set changed 1
                }
            }
            if {!$changed || [llength $component] == 1 && ![SelfCalling $graphs [lindex $component 0]]} {
                break
            }
        }
    }
    return $summaries
}

proc hir::lifetime::SelfCalling {graphs id} {
    return [expr {$id in [dict get $graphs $id callees]}]
}

# The strongly connected components of the units' call graph, callees before
# callers (Tarjan's algorithm, iteratively: the call graph is no source
# nesting, and recursion over it would follow call chains).
proc hir::lifetime::Components {graphs units} {
    set index 0
    set order [dict create]
    set low [dict create]
    set onStack [dict create]
    set stack {}
    set result {}
    foreach root $units {
        if {[dict exists $order $root]} continue
        set work [list [list $root 0]]
        while {[llength $work]} {
            lassign [lindex $work end] v i
            set work [lrange $work 0 end-1]
            if {$i == 0} {
                dict set order $v $index
                dict set low $v $index
                incr index
                lappend stack $v
                dict set onStack $v 1
            }
            set callees [lmap c [dict get $graphs $v callees] {
                if {[dict exists $graphs $c]} {set c} else continue
            }]
            set recurse 0
            while {$i < [llength $callees]} {
                set w [lindex $callees $i]
                incr i
                if {![dict exists $order $w]} {
                    lappend work [list $v $i] [list $w 0]
                    set recurse 1
                    break
                } elseif {[dict exists $onStack $w]} {
                    dict set low $v [expr {min([dict get $low $v], [dict get $order $w])}]
                }
            }
            if {$recurse} continue
            if {[dict get $low $v] == [dict get $order $v]} {
                set component {}
                while 1 {
                    set w [lindex $stack end]
                    set stack [lrange $stack 0 end-1]
                    dict unset onStack $w
                    lappend component $w
                    if {$w eq $v} break
                }
                lappend result [lsort $component]
            }
            if {[llength $work]} {
                set parent [lindex $work end 0]
                dict set low $parent [expr {min([dict get $low $parent], [dict get $low $v])}]
            }
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Liveness

# Live-in and live-out bit sets of every node of G: {VARS LIVEIN LIVEOUT},
# VARS the variables in bit order.
proc hir::lifetime::Liveness {g} {
    set vars {}
    set bit [dict create]
    set uses [dict create]
    set defs [dict create]
    set preds [dict create]
    dict for {n node} [dict get $g nodes] {
        set u 0
        foreach v [dict get $node uses] {
            if {![dict exists $bit $v]} {
                dict set bit $v [llength $vars]
                lappend vars $v
            }
            set u [expr {$u | (1 << [dict get $bit $v])}]
        }
        set d 0
        foreach v [dict get $node defs] {
            if {![dict exists $bit $v]} {
                dict set bit $v [llength $vars]
                lappend vars $v
            }
            set d [expr {$d | (1 << [dict get $bit $v])}]
        }
        dict set uses $n $u
        dict set defs $n $d
        foreach s [concat [dict get $node succ] [dict get $node exc]] {
            dict lappend preds $s $n
        }
    }
    set in [dict create]
    set out [dict create]
    # Successors before predecessors (a postorder from the entry): a
    # backward problem then needs a round per loop level only around the
    # loop's own body.
    set work [Postorder $g]
    set queued [dict create]
    foreach n $work {
        dict set in $n 0
        dict set out $n 0
        dict set queued $n 1
    }
    for {set k 0} {$k < [llength $work]} {incr k} {
        set n [lindex $work $k]
        dict unset queued $n
        set node [dict get $g nodes $n]
        set o 0
        foreach s [concat [dict get $node succ] [dict get $node exc]] {
            set o [expr {$o | [dict get $in $s]}]
        }
        dict set out $n $o
        set i [expr {[dict get $uses $n] | ($o & ~[dict get $defs $n])}]
        if {$i != [dict get $in $n]} {
            dict set in $n $i
            foreach p [dict getdef $preds $n {}] {
                if {![dict exists $queued $p]} {
                    dict set queued $p 1
                    lappend work $p
                }
            }
        }
    }
    return [list $vars $in $out $defs]
}

# The nodes of G in a postorder of a depth-first walk from the entry over
# every edge (iterative: the CFG is as deep as the program nests), then the
# nodes no walk reaches.
proc hir::lifetime::Postorder {g} {
    set nodes [dict get $g nodes]
    set seen [dict create]
    set order {}
    set entry [dict get $g entryNode]
    set stack [list [list $entry 0]]
    dict set seen $entry 1
    while {[llength $stack]} {
        lassign [lindex $stack end] n i
        set succs [concat [dict get $nodes $n succ] [dict get $nodes $n exc]]
        if {$i < [llength $succs]} {
            lset stack end 1 [expr {$i + 1}]
            set s [lindex $succs $i]
            if {![dict exists $seen $s]} {
                dict set seen $s 1
                lappend stack [list $s 0]
            }
            continue
        }
        set stack [lrange $stack 0 end-1]
        lappend order $n
    }
    foreach n [lsort -integer [dict keys $nodes]] {
        if {![dict exists $seen $n]} {
            lappend order $n
        }
    }
    return $order
}

# The variables of bit set BITS.
proc hir::lifetime::Decode {vars bits} {
    set result {}
    if {$bits == 0} {
        return $result
    }
    set text [string reverse [format %llb $bits]]
    set i [string first 1 $text]
    while {$i >= 0} {
        lappend result [lindex $vars $i]
        set i [string first 1 $text [expr {$i + 1}]]
    }
    return $result
}

# ---------------------------------------------------------------------------
# The facts of one unit

# Unit G's facts, under the final SUMMARIES: a dict
#
#   id block label        the instance
#   summary               what a call of it keeps (Summary)
#   producers             site -> {expr kind origin what loops}
#   verdicts              site -> region -> {verdict V reasons R}; regions
#                         `activation`, `iteration L` per enclosing loop L
#                         of the unit, `segment`
#   suspensions           one dict per suspension point: {expr kind origin
#                         what bindings pending accumulators positions held
#                         objects}
#   exits                 region -> list of {kind expr origin live objects}
#   coexist               site -> sites whose objects may be live when it is
#                         made (and itself, when an earlier one of it is)
#   liveness              the bit sets liveBefore and liveAfter read
#   vars                  variable -> description
proc hir::lifetime::Facts {hir g summaries} {
    lassign [Solve $g $summaries] pts contents
    set esc [Escapes $hir $g $summaries $pts $contents]
    lassign [Liveness $g] vars in out defs
    set nodes [dict get $g nodes]
    # The variables that may hold an object: the only ones the object
    # questions below need to decode.
    set holdMask 0
    set i 0
    foreach v $vars {
        if {[dict size [PtsOf $pts $v]]} {
            set holdMask [expr {$holdMask | (1 << $i)}]
        }
        incr i
    }
    # The objects anything holds: a producer no constraint gives an object
    # (a call whose callee never returns a fresh one) makes none.
    set made [dict create]
    dict for {v set} $pts {
        set made [dict merge $made $set]
    }
    set made [Reach $contents $made]
    set producers [dict create]
    dict for {site p} [dict get $g producers] {
        if {[dict exists $made $site]} {
            dict set producers $site $p
        }
    }
    set facts [dict create id [dict get $g id] block [dict get $g block] label [dict get $g label] \
        summary [dict get $summaries [dict get $g id]] producers $producers]
    # Which producers may have made an object before each node: an object
    # not made yet on any path is live nowhere (containment is flow-
    # insensitive: a value stored later is in its holder's contents
    # everywhere).
    lassign [Made $g $producers] madeBits madeIn madeOut
    # Which nodes define each variable, for the regions.
    set defNodes [dict create]
    dict for {n node} $nodes {
        foreach v [dict get $node defs] {
            dict lappend defNodes $v $n
        }
    }
    # The objects held across each suspension point.
    set suspensions {}
    set crossing [dict create]
    foreach n [lsort -integer [dict keys $nodes]] {
        set node [dict get $nodes $n]
        if {![dict exists $node suspends]} continue
        lassign [dict get $node suspends] kind callee args
        set across [Decode $vars [expr {[dict get $out $n] & ~[dict get $defs $n]}]]
        set objs {}
        foreach v $across {
            set objs [dict merge $objs [PtsOf $pts $v]]
        }
        set held {}
        if {$kind eq "call"} {
            foreach v $args {
                set held [dict merge $held [PtsOf $pts $v]]
            }
        }
        set objs [Filter [Reach $contents [dict merge $objs $held]] $madeBits [dict get $madeIn $n]]
        set crossing [dict merge $crossing $objs]
        set e [dict get $node expr]
        lappend suspensions [dict create expr $e kind $kind origin [Origin $hir $e] what [What $hir $e] \
            bindings [lsort [lmap v $across {if {[string match b:* $v]} {set v} else continue}]] \
            pending [lsort [lmap v $across {if {[string match t:* $v]} {set v} else continue}]] \
            accumulators [lsort [lmap v $across {if {[string match a:* $v]} {set v} else continue}]] \
            positions [lsort [lmap v $across {if {[string match s:* $v]} {set v} else continue}]] \
            held [lsort [lmap o [dict keys [Filter [Reach $contents $held] $madeBits [dict get $madeIn $n]]] {if {[dict exists $producers $o]} {set o} else continue}]] \
            objects [lsort [lmap o [dict keys $objs] {if {[dict exists $producers $o]} {set o} else continue}]]]
    }
    dict set facts suspensions $suspensions
    # The loops of the unit, and what flows out of an iteration of each: the
    # objects reachable from a variable some definition of which is outside
    # the loop's body (an enclosing binding, a parameter, the fold's
    # intermediate, the accumulator, the loop's own result).
    # A producer's object escapes the iteration of an enclosing loop L when
    # a variable defined outside L's body reaches it: per producer, the
    # shallowest such loop depth (loops nest: every loop at that depth and
    # deeper is left).
    set escapeDepth [dict create]
    dict for {v ns} $defNodes {
        set held [PtsOf $pts $v]
        if {[dict size $held] == 0} continue
        # The loops every definition of V is inside: the common prefix of
        # their loop stacks.
        set inside [dict get $nodes [lindex $ns 0] loops]
        foreach m [lrange $ns 1 end] {
            set inside [CommonPrefix $inside [dict get $nodes $m loops]]
        }
        dict for {o -} [Reach $contents $held] {
            if {![dict exists $producers $o]} continue
            set depth [llength [CommonPrefix [dict get $producers $o loops] $inside]]
            if {![dict exists $escapeDepth $o] || $depth < [dict get $escapeDepth $o]} {
                dict set escapeDepth $o $depth
            }
        }
    }
    set verdicts [dict create]
    dict for {site p} $producers {
        set reasons [dict values [dict getdef $esc $site {}]]
        set act [VerdictOf $reasons]
        dict set verdicts $site activation [dict create verdict $act reasons $reasons]
        set depth 0
        foreach loop [dict get $p loops] {
            incr depth
            if {$act ne "confined"} {
                dict set verdicts $site [list iteration $loop] [dict create verdict $act \
                    reasons [list [Reason inherited "" "it is not confined to the activation"]]]
            } elseif {[dict exists $escapeDepth $site] && $depth > [dict get $escapeDepth $site]} {
                dict set verdicts $site [list iteration $loop] [dict create verdict escapes \
                    reasons [list [Reason carried $loop "it reaches a value that outlives the iteration of [What $hir $loop]"]]]
            } else {
                dict set verdicts $site [list iteration $loop] [dict create verdict confined reasons {}]
            }
        }
        if {$act ne "confined"} {
            dict set verdicts $site segment [dict create verdict $act \
                reasons [list [Reason inherited "" "it is not confined to the activation"]]]
        } elseif {[dict exists $crossing $site]} {
            dict set verdicts $site segment [dict create verdict escapes \
                reasons [list [Reason suspension "" "it is live across a suspension point"]]]
        } else {
            dict set verdicts $site segment [dict create verdict confined reasons {}]
        }
    }
    dict set facts verdicts $verdicts
    # Which objects may be live when each producer makes one.
    set coexist [dict create]
    dict for {site p} $producers {
        set n [dict get $p node]
        set objs {}
        foreach v [Decode $vars [expr {([dict get $in $n] | [dict get $out $n]) & $holdMask}]] {
            set objs [dict merge $objs [PtsOf $pts $v]]
        }
        set objs [Filter [Reach $contents $objs] $madeBits [dict get $madeIn $n]]
        set earlier 0
        if {[dict exists $objs $site] && [llength [dict get $p loops]]} {
            # An earlier object of this producer (an earlier iteration's)
            # still live when it makes the next.
            set before {}
            foreach v [Decode $vars [expr {[dict get $in $n] & $holdMask}]] {
                set before [dict merge $before [PtsOf $pts $v]]
            }
            set earlier [dict exists [Reach $contents $before] $site]
        }
        set others [lsort [lmap o [dict keys $objs] {
            if {$o ne $site && [dict exists $producers $o]} {set o} else continue
        }]]
        if {$earlier} {
            lappend others $site
        }
        dict set coexist $site $others
    }
    dict set facts coexist $coexist
    # Region exits.
    set exits [dict create activation {}]
    dict for {loop frame} [dict get $g loops] {
        dict set exits [list iteration $loop] {}
    }
    foreach n [lsort -integer [dict keys $nodes]] {
        set node [dict get $nodes $n]
        set kind [dict get $node kind]
        set leaving {}
        foreach s [concat [dict get $node succ] [dict get $node exc]] {
            set common [llength [CommonPrefix [dict get $node loops] [dict get $nodes $s loops]]]
            foreach loop [lrange [dict get $node loops] $common end] {
                lappend leaving $loop $s
            }
        }
        if {$leaving eq {} && ($kind ni {return fail result call}
                || $kind eq "call" && ![dict exists $node suspends] && ![dict exists $node errors])} continue
        set e [dict get $node expr]
        set live [Decode $vars [dict get $out $n]]
        set liveObjs {}
        foreach v [Decode $vars [expr {[dict get $out $n] & $holdMask}]] {
            set liveObjs [dict merge $liveObjs [PtsOf $pts $v]]
        }
        set liveObjs [lsort [lmap o [dict keys [Filter [Reach $contents $liveObjs] $madeBits [dict get $madeOut $n]]] {
            if {[dict exists $producers $o]} {set o} else continue
        }]]
        set record [dict create kind $kind expr $e origin [Origin $hir $e] live $live objects $liveObjs]
        switch -- $kind {
            return - fail - result {
                dict lappend exits activation $record
            }
            call {
                if {[dict exists $node errors] && [dict get $g exitxNode] in [dict get $node exc]} {
                    dict set record kind error
                    dict set record errors [dict get $node errors]
                    dict set record live {}
                    dict lappend exits activation $record
                }
                if {[dict exists $node suspends]} {
                    dict set record kind suspend
                    dict set record live [Decode $vars [expr {[dict get $out $n] & ~[dict get $defs $n]}]]
                    dict lappend exits activation $record
                }
            }
        }
        # Edges that leave a loop's iteration: to the loop's head (the next
        # iteration), to its exit, or out of the unit.
        foreach {loop s} $leaving {
            set frame [dict get $g loops $loop]
            if 1 {
                set r $record
                if {$s == [dict get $frame head]} {
                    dict set r kind [if {$kind eq "continue"} {string cat continue} else {string cat next}]
                } elseif {$s == [dict get $frame exit]} {
                    dict set r kind break
                } elseif {$s == [dict get $g exitxNode]} {
                    dict set r kind [if {$kind eq "fail"} {string cat fail} else {string cat error}]
                } elseif {$s == [dict get $g exitNode]} {
                    dict set r kind return
                } else {
                    dict set r kind leave
                }
                dict lappend exits [list iteration $loop] $r
            }
        }
    }
    dict set facts exits $exits
    # Liveness before and after each expression's own node, decoded on
    # demand (liveBefore, liveAfter).
    dict set facts liveness [dict create vars $vars in $in out $out exprNodes [dict get $g exprNodes]]
    set described [dict create]
    foreach v $vars {
        dict set described $v [Describe $hir $v]
    }
    dict set facts vars $described
    dict set facts pts $pts
    dict set facts contents $contents
    dict set facts loops [dict keys [dict get $g loops]]
    dict set facts nodeCount [dict size $nodes]
    dict set facts consCount [llength [dict get $g cons]]
    return $facts
}

# The producers that may have made an object before and after each node of
# G (a forward may-analysis, one bit per producer of PRODUCERS): {BITS IN
# OUT}, BITS site -> its bit, IN and OUT node -> bit set.
proc hir::lifetime::Made {g producers} {
    set sites [dict keys $producers]
    set bit [dict create]
    set i 0
    foreach site $sites {
        dict set bit $site $i
        incr i
    }
    set gen [dict create]
    # A loop's head may be reached again after anything its body makes: its
    # producers are seeded at the head, so one pass in reverse postorder
    # settles every nesting level (an over-approximation, which only
    # filters less).
    set bodies [dict create]
    dict for {site p} $producers {
        set n [dict get $p node]
        set b [expr {1 << [dict get $bit $site]}]
        dict set gen $n [expr {[dict getdef $gen $n 0] | $b}]
        foreach loop [dict get $p loops] {
            dict set bodies $loop [expr {[dict getdef $bodies $loop 0] | $b}]
        }
    }
    dict for {loop b} $bodies {
        set head [dict get $g loops $loop head]
        dict set gen $head [expr {[dict getdef $gen $head 0] | $b}]
    }
    set nodes [dict get $g nodes]
    set in [dict create]
    set out [dict create]
    foreach n [dict keys $nodes] {
        dict set in $n 0
        dict set out $n 0
    }
    set work [lreverse [Postorder $g]]
    set queued [dict create]
    foreach n $work {
        dict set queued $n 1
    }
    set preds [dict create]
    dict for {n node} $nodes {
        foreach s [concat [dict get $node succ] [dict get $node exc]] {
            dict lappend preds $s $n
        }
    }
    for {set k 0} {$k < [llength $work]} {incr k} {
        set n [lindex $work $k]
        dict unset queued $n
        set i 0
        foreach p [dict getdef $preds $n {}] {
            set i [expr {$i | [dict get $out $p]}]
        }
        dict set in $n $i
        set o [expr {$i | [dict getdef $gen $n 0]}]
        if {$o != [dict get $out $n]} {
            dict set out $n $o
            foreach s [concat [dict get $nodes $n succ] [dict get $nodes $n exc]] {
                if {![dict exists $queued $s]} {
                    dict set queued $s 1
                    lappend work $s
                }
            }
        }
    }
    return [list $bit $in $out]
}

# The objects of SET whose producer's bit (BITS) is set in MADE, and every
# object that is no producer of this unit (a caller's, a context's: made
# before the unit ran).
proc hir::lifetime::Filter {set bits made} {
    set result {}
    dict for {o -} $set {
        if {![dict exists $bits $o] || ($made >> [dict get $bits $o]) & 1} {
            dict set result $o 1
        }
    }
    return $result
}

# The longest common prefix of the lists A and B.
proc hir::lifetime::CommonPrefix {a b} {
    set i 0
    foreach x $a y $b {
        if {$x ne $y} break
        incr i
    }
    return [lrange $a 0 [expr {$i - 1}]]
}

# The variables live before (after) expression E's own node in unit ID of
# FACTS ({} if E has no node there).
proc hir::lifetime::liveBefore {facts id e} {
    return [LiveAt $facts $id $e in]
}

proc hir::lifetime::liveAfter {facts id e} {
    return [LiveAt $facts $id $e out]
}

proc hir::lifetime::LiveAt {facts id e which} {
    set l [dict get $facts units $id liveness]
    if {![dict exists $l exprNodes $e]} {
        return {}
    }
    set n [lindex [dict get $l exprNodes $e] end]
    return [Decode [dict get $l vars] [dict get $l $which $n]]
}

proc hir::lifetime::VerdictOf {reasons} {
    if {$reasons eq {}} {
        return confined
    }
    foreach r $reasons {
        if {[dict get $r definite]} {
            return escapes
        }
    }
    return unknown
}

# ---------------------------------------------------------------------------
# Descriptions

# Where expression E is written: "LINE:COLUMN", "" if nowhere.
proc hir::lifetime::Origin {hir e} {
    if {$e eq "" || $e eq "program" || ![dict exists $hir exprs $e]} {
        return "the end"
    }
    set origin [dict get $hir exprs $e origin]
    if {[dict exists $origin line]} {
        set file ""
        if {[dict exists $origin file] && [dict exists $hir files [dict get $origin file]]} {
            set file "[file tail [dict get $hir files [dict get $origin file] path]]:"
        }
        return "$file[dict get $origin line]:[dict get $origin column]"
    }
    return ""
}

# What expression E is, in a few words: the operation, never an id.
proc hir::lifetime::What {hir e} {
    if {$e eq "program"} {
        return "the program"
    }
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        call {
            set callee [dict get $hir exprs [dict get $node callee]]
            if {[dict get $callee kind] eq "ref"} {
                set b [dict get $callee binding]
                if {$b ne "" && [dict exists $hir bindings $b]} {
                    return "call of [hir::semantic::SourceName $hir $b]"
                }
                return "call of [dict get $callee name]"
            }
            return "call of a computed function"
        }
        struct {
            set name [dict getdef $node structId ""]
            if {$name eq ""} {
                return "struct {[join [dict get $node names] {, }]}"
            }
            return "$name {[join [dict get $node names] {, }]}"
        }
        block { return closure }
        loop - listloop - countloop - lockloop {
            if {[hir::isFold $hir $e]} {
                return "fold"
            }
            return "loop"
        }
        bind { return "binding [hir::semantic::SourceName $hir [dict get $node binding]]" }
        default { return [dict get $node kind] }
    }
}

# A variable described for people: a binding by its name, a pending result
# by its expression.
proc hir::lifetime::Describe {hir v} {
    set id [string range $v 2 end]
    switch -- [string index $v 0] {
        b {
            if {[dict exists $hir bindings $id]} {
                return [hir::semantic::SourceName $hir $id]
            }
            return $v
        }
        t { return "the pending value of [What $hir $id] at [Origin $hir $id]" }
        a { return "the List [What $hir $id] at [Origin $hir $id] collects" }
        s { return "the position of the [What $hir $id] at [Origin $hir $id]" }
    }
    return $v
}

# ---------------------------------------------------------------------------
# The report

# The fact report of FACTS, as text: per unit its summary, producers and
# their verdicts per region, suspension points, region exits. Deterministic:
# no time, no path, no id that depends on anything but the HIR.
proc hir::lifetime::report {hir facts {only ""}} {
    set lines {}
    foreach id [units $facts] {
        if {$only ne "" && $id ni $only} continue
        set u [unit $facts $id]
        lappend lines "unit [dict get $u label]"
        set s [dict get $u summary]
        lappend lines "  summary: [SummaryText $s]"
        dict for {site p} [dict get $u producers] {
            lappend lines "  producer [dict get $p what] ([dict get $p kind]) at [dict get $p origin]"
            dict for {region v} [dict get $u verdicts $site] {
                set text "    [RegionText $hir $region]: [dict get $v verdict]"
                foreach r [dict get $v reasons] {
                    append text "\n      - [ReasonText $hir $r]"
                }
                lappend lines $text
            }
            set co [dict get $u coexist $site]
            if {$co ne {}} {
                lappend lines "    coexists with: [join [lmap o $co {SiteText $hir $u $o}] {; }]"
            }
        }
        foreach susp [dict get $u suspensions] {
            lappend lines "  suspension [dict get $susp kind] ([dict get $susp what]) at [dict get $susp origin]"
            lappend lines "    live bindings: [join [lmap v [dict get $susp bindings] {dict get $u vars $v}] {, }]"
            if {[dict get $susp pending] ne {}} {
                lappend lines "    pending: [join [lmap v [dict get $susp pending] {dict get $u vars $v}] {; }]"
            }
            if {[dict get $susp accumulators] ne {}} {
                lappend lines "    accumulators: [join [lmap v [dict get $susp accumulators] {dict get $u vars $v}] {; }]"
            }
            if {[dict get $susp positions] ne {}} {
                lappend lines "    loop positions: [join [lmap v [dict get $susp positions] {dict get $u vars $v}] {; }]"
            }
            if {[dict get $susp held] ne {}} {
                lappend lines "    held by the suspended callee: [join [lmap o [dict get $susp held] {SiteText $hir $u $o}] {; }]"
            }
            lappend lines "    objects kept: [join [lmap o [dict get $susp objects] {SiteText $hir $u $o}] {; }]"
        }
        dict for {region list} [dict get $u exits] {
            if {$list eq {}} continue
            lappend lines "  exits of [RegionText $hir $region]:"
            foreach x $list {
                set text "    [dict get $x kind] at [dict get $x origin]"
                if {[dict exists $x errors]} {
                    append text " ([join [dict get $x errors] {, }])"
                }
                append text ": live [join [lmap v [dict get $x live] {dict get $u vars $v}] {, }]"
                lappend lines $text
            }
        }
    }
    return [join $lines \n]
}

# The units of FACTS whose code is written in the source file PATH (the
# program's own top level included): a report about a program, without the
# standard library's units.
proc hir::lifetime::unitsIn {hir facts path} {
    set path [file normalize $path]
    set result {}
    foreach id [units $facts] {
        set block [dict get $facts units $id block]
        if {$block eq "program"} {
            lappend result $id
            continue
        }
        set origin [dict get $hir exprs $block origin]
        if {[dict exists $origin file] && [dict exists $hir files [dict get $origin file]]
                && [file normalize [dict get $hir files [dict get $origin file] path]] eq $path} {
            lappend result $id
        }
    }
    return $result
}

proc hir::lifetime::SummaryText {s} {
    set parts {}
    if {[dict get $s resultParams] ne {}} {
        lappend parts "result may hold parameters [join [lmap i [dict get $s resultParams] {lindex [dict get $s params] $i}] {, }]"
    }
    if {[dict get $s fresh]} {
        lappend parts "result may be fresh"
    }
    if {[dict get $s global] ne {}} {
        lappend parts "result may be [join [dict get $s global] {, }] state"
    }
    dict for {i why} [dict get $s escParams] {
        lappend parts "parameter [lindex [dict get $s params] $i] escapes ([dict get $why category])"
    }
    foreach pair [dict get $s stores] {
        lassign $pair from into
        lappend parts "stores [lindex [dict get $s params] $from] into [lindex [dict get $s params] $into]"
    }
    if {[dict get $s capResult]} {
        lappend parts "result may hold captures"
    }
    if {[dict size [dict get $s capEscape]]} {
        lappend parts "captures escape ([dict get $s capEscape category])"
    }
    if {[dict size [dict get $s msg]]} {
        lappend parts "a resume message may be kept"
    }
    if {$parts eq {}} {
        return "keeps nothing it is given"
    }
    return [join $parts "; "]
}

proc hir::lifetime::RegionText {hir region} {
    if {[lindex $region 0] eq "iteration"} {
        set loop [lindex $region 1]
        return "iteration of the [What $hir $loop] at [Origin $hir $loop]"
    }
    return $region
}

proc hir::lifetime::ReasonText {hir r} {
    set text "[dict get $r category]: [dict get $r detail]"
    if {[dict get $r at] ne "" && [dict get $r category] ne "carried"} {
        append text " (at [Origin $hir [dict get $r at]])"
    }
    return $text
}

proc hir::lifetime::SiteText {hir u o} {
    if {[dict exists $u producers $o]} {
        set p [dict get $u producers $o]
        return "[dict get $p what] at [dict get $p origin]"
    }
    return $o
}
