# applied.tcl -- the local, exact check of parameterized applications past
# the applied-type bound (APPLIED-TYPE-BOUND-PRECISION-MILESTONE-1.md).
#
# The type lattice keeps applications finite: an application nested
# directly in another's argument is one application deeper, and past
# hir::types::appliedDepth of them the arguments are `any`
# (hir::types::MakeApplied). That cut is a description of the value, made
# for joins, fixpoints, instance keys and memo keys; it is no source type,
# and two things it must never do:
#
#   * reject a value the declaration admits. A part of a cut application is
#     cut one application earlier than a value of that part standing on its
#     own: Box {value: V} with V a Box six deep is Box^7, whose argument,
#     read back as the field's declared type, comes out Box^5[any] while V
#     itself is Box^6[int] -- a TYPE error from seven Boxes on, whatever
#     the program. A construction's field types are therefore derived from
#     what establishes its slots -- its own field values, or its written
#     application at its own top (hir::resolve::ResolveAppliedConstruction)
#     -- never extracted from its bounded type (VerifyStruct).
#   * accept what a written type says is wrong. Box^1000 {"x"} against a
#     written Box^1000[int] has the same bounded type as the declaration,
#     so the bounded check passes; the exact check below compares the
#     value's *evidence* with the *exact* written type and finds the String
#     where the Int is declared, and reports it at the deepest field it
#     reaches (Locate).
#
# Precision is forgotten globally and cashed out locally: every HIR type
# stays the bounded one (no HIR type, instance key, join or memo key holds
# an exact application), and the exact terms below exist only while one
# check runs.
#
# Evidence (this file's terms, never a HIR type)
# ----------------------------------------------
#   {app ID ARGS CANON CUT SRC EST}
#        an exact application of parameterized struct ID: ARGS one evidence
#        per slot, CANON its canonical (bounded) type, CUT 1 when the bound
#        cut CANON, SRC the construction that built it ("" for a written
#        type), EST the field of SRC that established each slot ("" where
#        none did: an explicit application).
#   {named ID FIELDS}
#        a construction of the non-parameterized struct ID whose fields
#        (FIELDS: name -> evidence) hold evidence that says more than their
#        types: read by a projection only (a named struct is nominal, its
#        fields checked against their declared types where it is built).
#   {either EVS T}
#        an `if` whose branches end in different evidence EVS: its value is
#        one of theirs, T its (bounded) join. Only admission reads the
#        members (Accept: every one is held to the position); anything else
#        sees the bounded join.
#   {type T H}
#        what is known is the canonical type T. H is the knowledge horizon:
#        "" when T is exact (the bound cut nothing in it), else the number
#        of applications below T's top that are known (appliedDepth for a
#        type the HIR holds at its own top, one less for each argument read
#        out of it).
#
# Where evidence comes from: what the program constructs -- a named
# parameterized construction (from its field values or its written
# application), an immutable local alias of a value with evidence, a field
# projection of one -- and, as the expected side of a check, a written type
# the resolver recorded exactly where the bound cut it (Written*: a
# parameter's, a result's, an explicit construction's application, a struct
# declaration's field). A declaration is never evidence of the values in
# its position (a parameter read in its body is its bounded type): not every
# way into a position is checked exactly, so reading the exact declaration
# back would recover a precision no check proved.
#
# The exact check only ever adds a rejection: an exact mismatch of two
# applications whose bounded types agree. Everything else -- the subtype or
# Range proof, a refinement, a trait -- stays the bounded check of the
# value's own HIR type against the position's own canonical type, so an
# accepted program's types and everything a backend reads are what the
# bounded types say.
#
# Every walk of an exact term follows the source's nesting and is a loop
# over an explicit stack (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md:
# nesting is never Tcl's limit), and no exact term is ever given a string
# representation (a 1000-deep term's nested string reps are quadratic):
# only bounded parts are compared as strings.

namespace eval hir::applied {
    # The evidence of the expressions met during one verification pass
    # (Pass): {CONTEXT E} -> evidence. CONTEXT is the semantic view the
    # pass checks (hir/semantic.tcl), so an instance's types never answer
    # for the program's.
    variable memo ""
    # 1 while a pass is open (Pass): outside one, Of answers without a memo.
    variable inPass 0
    # Counters of the exact machinery (bench, tests): Count, Stats.
    variable stats [dict create]
    # The aliases and branches one evidence query follows at most (TypedOf):
    # a determinism guard, hir/exactvalue.tcl's maxSteps.
    variable maxSteps 64
}

proc hir::applied::Count {name {n 1}} {
    variable stats
    dict incr stats $name $n
}

proc hir::applied::Stats {} {
    variable stats
    return $stats
}

proc hir::applied::ResetStats {} {
    variable stats
    set stats [dict create]
}

# Runs SCRIPT in the caller's frame with a fresh evidence memo: every Of
# inside answers each expression once.
proc hir::applied::Pass {script} {
    variable memo
    variable inPass
    set saved [list $memo $inPass]
    set memo [dict create]
    set inPass 1
    try {
        uplevel 1 $script
    } finally {
        lassign $saved memo inPass
    }
}

# ---------------------------------------------------------------------------
# The bound

# 1 if the bound cut the canonical type TYPE's application spine: an
# application nested appliedDepth or more applications deep (through
# applications directly in arguments) whose arguments are all `any` -- the
# form MakeApplied gives every application it cuts. (A genuine Box^7[any]
# has the same form and is treated the same: its exact evidence, where the
# program has one, then says what it is.)
proc hir::applied::Cut {type} {
    if {[string first nstruct $type] < 0} {
        return 0
    }
    set limit $::hir::types::appliedDepth
    set stack [list [list $type 0]]
    while {[llength $stack]} {
        lassign [lindex $stack end] t n
        set stack [lreplace $stack[set stack {}] end end]
        if {![hir::types::IsAppliedStruct $t]} {
            continue
        }
        set args [lindex $t 2]
        if {$n >= $limit && [lsearch -exact -not $args any] < 0} {
            return 1
        }
        foreach a $args {
            if {[hir::types::IsAppliedStruct $a]} {
                lappend stack [list $a [expr {$n + 1}]]
            }
        }
    }
    return 0
}

# TYPE (canonical) cut H applications below its top: what is known of it
# when only H levels are (a canonical type read H levels deep into a cut
# one). H "" is TYPE itself.
proc hir::applied::Truncate {type h} {
    if {$h eq "" || ![hir::types::IsAppliedStruct $type]} {
        return $type
    }
    set depth $::hir::types::appliedDepth
    if {$h >= $depth} {
        return $type
    }
    set nesting [expr {$depth - ($h < 0 ? 0 : $h)}]
    return [hir::types::MakeApplied [lindex $type 1] [lindex $type 2] 0 $nesting]
}

# ---------------------------------------------------------------------------
# Evidence terms

# The evidence of a value whose canonical type TYPE is all that is known.
proc hir::applied::Leaf {type {horizon auto}} {
    if {$horizon eq "auto"} {
        set horizon [if {[Cut $type]} {set ::hir::types::appliedDepth} else {string cat ""}]
    }
    return [list type $type $horizon]
}

# The exact application of ID to the evidence ARGS. CANON is its canonical
# type when the caller knows it (a construction's HIR type), else derived.
proc hir::applied::App {id args {canon ""} {src ""} {est ""}} {
    Count apps
    if {$canon eq ""} {
        set canon [hir::types::MakeApplied $id [lmap a $args {Canonical $a}]]
    }
    return [list app $id $args $canon [Cut $canon] $src $est]
}

proc hir::applied::IsApp {ev} {
    return [expr {[lindex $ev 0] eq "app"}]
}

# The canonical type of evidence EV.
proc hir::applied::Canonical {ev} {
    switch -- [lindex $ev 0] {
        app {
            return [lindex $ev 3]
        }
        named {
            return [list nstruct [lindex $ev 1]]
        }
        either {
            return [lindex $ev 2]
        }
    }
    return [lindex $ev 1]
}

# 1 if EV says more than its canonical type: an exact application the
# bound cut.
proc hir::applied::Deep {ev} {
    switch -- [lindex $ev 0] {
        app {
            return [lindex $ev 4]
        }
        named {
            return 1
        }
        either {
            foreach member [lindex $ev 1] {
                if {[Deep $member]} {
                    return 1
                }
            }
        }
    }
    return 0
}

# The evidence of field NAME of a value of evidence EV, or "": an exact
# application's declared field (FieldExpected), a named construction's field
# value.
proc hir::applied::FieldOf {ev name} {
    switch -- [lindex $ev 0] {
        app {
            if {[lindex $ev 4] && [hir::structs::declared [lindex $ev 1]]} {
                return [FieldExpected [lindex $ev 1] [lindex $ev 2] $name]
            }
        }
        named {
            return [dict getdef [lindex $ev 2] $name ""]
        }
    }
    return ""
}

# The parts of EV an application's slots hold: {ID ARGS} for an exact
# application or a known canonical application (its arguments known one
# level less far), else "".
proc hir::applied::Parts {ev} {
    if {[lindex $ev 0] eq "app"} {
        return [list [lindex $ev 1] [lindex $ev 2]]
    }
    if {[lindex $ev 0] in {named either}} {
        return ""
    }
    set t [lindex $ev 1]
    if {![hir::types::IsAppliedStruct $t]} {
        return ""
    }
    set h [lindex $ev 2]
    if {$h ne "" && $h <= 0} {
        # (At the horizon only the application's head is known: its
        # arguments are the bound's.)
        return ""
    }
    set inner [if {$h eq ""} {string cat ""} else {expr {$h - 1}}]
    return [list [lindex $t 1] [lmap a [lindex $t 2] {list type $a $inner}]]
}

# The written form of evidence EV, the bounded parts shown as
# hir::types::show shows them (an exact term in full: it is what the
# program wrote or built).
proc hir::applied::Show {ev} {
    # Post-order over an explicit stack: {EV 0} expands, {EV 1} assembles.
    set stack [list [list $ev 0]]
    set out {}
    while {[llength $stack]} {
        lassign [lindex $stack end] x phase
        set stack [lreplace $stack[set stack {}] end end]
        if {[lindex $x 0] ne "app"} {
            lappend out [hir::types::show [Canonical $x]]
            continue
        }
        if {$phase == 0} {
            lappend stack [list $x 1]
            foreach a [lreverse [lindex $x 2]] {
                lappend stack [list $a 0]
            }
            continue
        }
        set n [llength [lindex $x 2]]
        set parts [lrange $out end-[expr {$n - 1}] end]
        set out [lreplace $out[set out {}] end-[expr {$n - 1}] end]
        lappend out "[hir::structs::display [lindex $x 1]]\[[join $parts {, }]\]"
    }
    return [lindex $out 0]
}

# ---------------------------------------------------------------------------
# Comparison

# "" when the evidence A and B describe the same type as far as either is
# known -- an application's slots are invariant (TRAIT-CONSTRAINED-
# IMPRINTED-TYPES.md: a slot is never converted, widened or narrowed) --
# else the first difference, {A' B' TRAIL}: the parts that differ and the
# applications above them (Trail). Bounded parts are compared as far as
# both are known (Truncate at the nearer horizon): where the program gave
# no exact evidence the comparison is the bounded one, as before; it never
# reads past a horizon.
proc hir::applied::Equal {a b} {
    Count compares
    set stack [list [list $a $b ""]]
    while {[llength $stack]} {
        lassign [lindex $stack end] x y trail
        set stack [lreplace $stack[set stack {}] end end]
        if {[lindex $x 0] eq "app" && [lindex $y 0] eq "app"} {
            if {[lindex $x 1] ne [lindex $y 1]} {
                return [list $x $y $trail]
            }
            if {![lindex $x 4] && ![lindex $y 4] && [lindex $x 3] eq [lindex $y 3]} {
                # (Neither cut: their canonical types are exact, and equal.
                # Unequal ones are walked on, to the part that differs.)
                continue
            }
            set px [list [lindex $x 1] [lindex $x 2]]
            set py [list [lindex $y 1] [lindex $y 2]]
        } else {
            set px [Parts $x]
            set py [Parts $y]
            if {$px eq "" || $py eq "" || ([lindex $x 0] ne "app" && [lindex $y 0] ne "app")} {
                set hx [Horizon $x]
                set hy [Horizon $y]
                if {$hx eq ""} {
                    set h $hy
                } elseif {$hy eq ""} {
                    set h $hx
                } else {
                    set h [expr {min($hx, $hy)}]
                }
                if {[Truncate [Canonical $x] $h] ne [Truncate [Canonical $y] $h]} {
                    return [list $x $y $trail]
                }
                continue
            }
            # An exact application against a canonical one known to some
            # horizon: slot by slot, each as far as it is known.
            if {[lindex $px 0] ne [lindex $py 0]} {
                return [list $x $y $trail]
            }
        }
        # Slots pushed last-first, so the first slot is compared first. The
        # trail is a cons list ({PREVIOUS X Y SLOT}): nothing is copied per
        # level, and no exact term is ever given a string form.
        set slot [llength [lindex $px 1]]
        foreach p [lreverse [lindex $px 1]] q [lreverse [lindex $py 1]] {
            incr slot -1
            lappend stack [list $p $q [list $trail $x $y $slot]]
        }
    }
    return ""
}

# The applications above a difference (Equal's TRAIL), outermost first:
# {X Y SLOT} each, X and Y the value's and the expected application, SLOT
# the argument the difference is in.
proc hir::applied::Trail {trail} {
    set entries {}
    while {$trail ne ""} {
        lassign $trail trail x y slot
        lappend entries [list $x $y $slot]
    }
    return [lreverse $entries]
}

# The horizon of EV: "" for an exact term (an application is exact through
# its own spine; its bounded leaves have their own).
proc hir::applied::Horizon {ev} {
    switch -- [lindex $ev 0] {
        app {
            return ""
        }
        either - named {
            # (Known as its bounded type is.)
            return [if {[Cut [Canonical $ev]]} {set ::hir::types::appliedDepth} else {string cat ""}]
        }
    }
    return [lindex $ev 2]
}

# "" when the value of evidence V is admissible, as far as exact evidence
# goes, where the evidence E is expected; else the first difference
# (Equal's). Only two applications of one declaration are compared here:
# the subtype and Range proofs of everything else are the bounded check's
# (hir::range::ProvesValueAcceptedBy), which the caller makes first.
proc hir::applied::Accept {v e} {
    if {[lindex $v 0] eq "either"} {
        # (The value is one of the branches': each is held to E.)
        foreach member [lindex $v 1] {
            set difference [Accept $member $e]
            if {$difference ne ""} {
                return $difference
            }
        }
        return ""
    }
    if {![Deep $v] && ![Deep $e]} {
        # (No exact term on either side: the bounded check said all.)
        return ""
    }
    set pv [Parts $v]
    set pe [Parts $e]
    if {$pv eq "" || $pe eq "" || [lindex $pv 0] ne [lindex $pe 0]} {
        return ""
    }
    Count accepts
    return [Equal $v $e]
}

# ---------------------------------------------------------------------------
# Expected types

# The evidence of the declared type of field NAME of parameterized struct
# ID applied to the evidence ARGS: the declaration's field type (its exact
# written form where the bound cut it, hir::structs::exactFieldType) with
# each slot replaced by its argument. Each part that is no application of a
# slot-mentioning declaration is the bounded substitution's canonical type.
proc hir::applied::FieldExpected {id args name} {
    set written [hir::structs::exactFieldType $id $name]
    if {$written ne ""} {
        # (A written field type the bound cut mentions no slot: Written.)
        return $written
    }
    set declared [hir::structs::fieldType $id $name]
    if {$declared eq ""} {
        return ""
    }
    set binding [dict create]
    set canonical [dict create]
    foreach slot [hir::structs::slots $id] a $args {
        if {$a eq ""} {
            continue
        }
        dict set binding $slot $a
        dict set canonical $slot [Canonical $a]
    }
    return [Substitute $declared $binding $canonical]
}

# DECLARED (a declaration's bounded field type, its slots imprint
# variables) with each slot of BINDING replaced by its evidence. The
# declared type is the declaration's own (bounded) term, so this recursion
# is as deep as the declaration writes its field type, never the program's
# nesting.
proc hir::applied::Substitute {declared binding canonical} {
    if {[hir::types::IsImprint $declared] && [dict exists $binding [lindex $declared 1]]} {
        return [dict get $binding [lindex $declared 1]]
    }
    if {[hir::types::IsAppliedStruct $declared] && [Mentions $declared $binding]} {
        return [App [lindex $declared 1] [lmap a [lindex $declared 2] {Substitute $a $binding $canonical}]]
    }
    return [Leaf [hir::types::canonical [hir::imprint::Substitute $declared $canonical]]]
}

# 1 if the bounded type TYPE mentions one of BINDING's variables.
proc hir::applied::Mentions {type binding} {
    foreach o [hir::imprint::Occurrences $type] {
        if {[dict exists $binding [lindex $o 0]]} {
            return 1
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Evidence of values

# The evidence of expression E's value in the view HIR is (hirVar), read
# from what the program constructs (the header). Answers each expression
# once per pass.
proc hir::applied::Of {hirVar e} {
    upvar 1 $hirVar hir
    variable memo
    variable inPass
    set context [dict getdef $hir semanticContext generic]
    if {!$inPass} {
        set saved $memo
        set memo [dict create]
    }
    try {
        # Post-order over an explicit stack: an expression is answered once
        # the expressions its evidence reads are.
        set stack [list [list $e 0]]
        set open [dict create]
        while {[llength $stack]} {
            lassign [lindex $stack end] x phase
            set key [list $context $x]
            if {[dict exists $memo $key]} {
                set stack [lreplace $stack[set stack {}] end end]
                continue
            }
            if {$phase == 0} {
                if {[dict exists $open $x]} {
                    # (Met again before it is answered: no evidence.)
                    set stack [lreplace $stack[set stack {}] end end]
                    dict set memo $key [Leaf [hir::typeOf $hir $x]]
                    continue
                }
                dict set open $x 1
                lset stack end 1 1
                foreach need [Needs $hir $x] {
                    if {![dict exists $memo [list $context $need]]} {
                        lappend stack [list $need 0]
                    }
                }
                continue
            }
            set stack [lreplace $stack[set stack {}] end end]
            dict unset open $x
            dict set memo $key [Build hir $x $context]
        }
        return [dict get $memo [list $context $e]]
    } finally {
        if {!$inPass} {
            set memo $saved
        }
    }
}

# The expressions whose evidence the evidence of E reads.
proc hir::applied::Needs {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        struct {
            if {[Constructs $hir $e $node] || [NamedConstruction $node]} {
                return [dict get $node fields]
            }
        }
        ref {
            set value [AliasValue $hir $node]
            if {$value ne ""} {
                return [list $value]
            }
        }
        project {
            return [list [dict get $node receiver]]
        }
        if {
            return [Branches $hir $node]
        }
    }
    return {}
}

# 1 if E (NODE) is a construction of a parameterized struct (typed as an
# application): the construction whose evidence can say more than its type
# -- where the bound cut it; an uncut one's evidence is its type, kept as an
# application so that a difference is located at its field (Locate).
proc hir::applied::Constructs {hir e node} {
    if {![dict get $node named] || [dict getdef $node structId ""] eq ""
            || [dict exists $node opaqueDenied] || [dict exists $node payloadOf]
            || [dict exists $node casePayloadOf]
            || ![hir::structs::isParameterized [dict get $node structId]]} {
        return 0
    }
    return [hir::types::IsAppliedStruct [hir::typeOf $hir $e]]
}

# 1 if NODE is a construction of a named struct with no type slots: its
# evidence is its fields' (a projection out of it reads one).
proc hir::applied::NamedConstruction {node} {
    return [expr {[dict get $node named] && [dict getdef $node structId ""] ne ""
        && ![dict exists $node opaqueDenied] && ![dict exists $node payloadOf]
        && ![dict exists $node casePayloadOf]
        && [hir::structs::declared [dict get $node structId]]
        && ![hir::structs::isParameterized [dict get $node structId]]}]
}

# The evidence {named ID FIELDS} of the named construction NODE, its fields'
# evidence read by FIELD (a command prefix taking the field's ExprId), when a
# field's evidence says more than its type, else "".
proc hir::applied::Named {node field} {
    set fields [dict create]
    set deep 0
    foreach name [dict get $node names] value [dict get $node fields] {
        if {[dict exists $fields $name]} {
            continue
        }
        set ev [{*}$field $value]
        dict set fields $name $ev
        if {[Deep $ev]} {
            set deep 1
        }
    }
    if {!$deep} {
        return ""
    }
    return [list named [dict get $node structId] $fields]
}

# The value expression an immutable local binding read by the ref NODE is
# bound to (its one `bind`), or "".
proc hir::applied::AliasValue {hir node} {
    set b [dict getdef $node binding ""]
    if {$b eq "" || ![dict exists $hir bindings $b]} {
        return ""
    }
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] ne "local" || [dict getdef $binding declaredBy ""] eq ""} {
        return ""
    }
    set bind [dict get $hir exprs [dict get $binding declaredBy]]
    if {[dict get $bind kind] ne "bind" || [dict get $bind duplicate]} {
        return ""
    }
    return [dict get $bind value]
}

# The evidence of E, the evidence of the expressions it reads being in the
# memo.
proc hir::applied::Build {hirVar e context} {
    upvar 1 $hirVar hir
    variable memo
    set node [dict get $hir exprs $e]
    set type [hir::typeOf $hir $e]
    switch -- [dict get $node kind] {
        struct {
            if {[NamedConstruction $node]} {
                set ev [Named $node [list apply {{memo context e} {dict get $memo [list $context $e]}} $memo $context]]
                if {$ev ne ""} {
                    return $ev
                }
                return [Leaf $type]
            }
            if {![Constructs $hir $e $node]} {
                return [Leaf $type]
            }
            set fields [dict create]
            foreach name [dict get $node names] field [dict get $node fields] {
                if {![dict exists $fields $name]} {
                    dict set fields $name [dict get $memo [list $context $field]]
                }
            }
            set ev [Constructed $e $node $type $fields]
            if {$ev eq ""} {
                return [Leaf $type]
            }
            return $ev
        }
        ref {
            set value [AliasValue $hir $node]
            if {$value ne ""} {
                set ev [dict get $memo [list $context $value]]
                if {[Canonical $ev] eq $type} {
                    return $ev
                }
            }
        }
        project {
            set receiver [dict get $memo [list $context [dict get $node receiver]]]
            set ev [FieldOf $receiver [dict get $node name]]
            if {$ev ne "" && [Canonical $ev] eq $type} {
                return $ev
            }
        }
        if {
            set branches [Branches $hir $node]
            if {$branches ne ""} {
                return [Join $hir $e [lmap b $branches {dict get $memo [list $context $b]}]]
            }
        }
    }
    return [Leaf $type]
}

# The evidence of the construction E (NODE) of a parameterized struct whose
# bounded type TYPE the bound cut, from the evidence of its field values
# FIELDS (name -> evidence), or "" (a conflict: the construction's check
# reports it). Evidence is what was constructed: an explicit application's
# written arguments are what the fields are held to (VerifyConstruction),
# never evidence of them -- a field value the program gives no evidence of
# is checked against them only as far as its bounded type goes -- so a slot
# its fields establish is what they hold; one they do not (a phantom slot, a
# slot only an empty List holds: Bag[int] {items: []}) is its written
# argument, exactly where the resolver recorded it: no value contradicts it.
proc hir::applied::Constructed {e node type fields} {
    set id [dict get $node structId]
    set bound [Bind $id $fields]
    if {[lindex $bound 0] ne "ok"} {
        return ""
    }
    lassign $bound - binding establishers
    set written [if {[dict exists $node structArgs]} {WrittenArgs $node} else {string cat ""}]
    set args {}
    set est {}
    foreach slot [hir::structs::slots $id] a $written {
        if {[dict exists $binding $slot]} {
            lappend args [dict get $binding $slot]
            lappend est [dict get $establishers $slot]
        } elseif {$a ne ""} {
            # (No field value says what the slot is -- a phantom slot, an
            # empty List's element: its written argument is all there is,
            # and no value it holds can contradict it.)
            lappend args $a
            lappend est ""
        } else {
            return ""
        }
    }
    return [App $id $args $type $e $est]
}

# The evidence of the written arguments of the explicit construction NODE:
# the exact written ones (exactStructArgs) where the bound cut them, else
# its bounded ones, each at its own top.
proc hir::applied::WrittenArgs {node} {
    if {[dict exists $node exactStructArgs]} {
        return [lmap a [dict get $node exactStructArgs] {Decode $a}]
    }
    return [lmap a [dict get $node structArgs] {Leaf $a}]
}

# The slot binding the field values of a construction of ID establish, from
# their evidence FIELDS (name -> evidence), exactly as the bounded inference
# establishes them (hir::types::InferApplication: in field order, an
# application's argument establishing the variable it holds, the first
# establishing field binding it, every later one held to it -- now exactly,
# as far as each is known): {ok BINDING ESTABLISHERS} or
# {conflict SLOT FIELD PRIOR EV DIFFERENCE INDEX}.
proc hir::applied::Bind {id fields} {
    set pairs {}
    set index 0
    foreach name [hir::structs::names $id] {
        incr index
        set declared [hir::structs::fieldType $id $name]
        if {$declared eq "" || ![dict exists $fields $name] || ![hir::imprint::Mentions $declared]} {
            continue
        }
        lappend pairs [list $name $declared [dict get $fields $name] $index]
    }
    return [BindPairs $pairs]
}

# Bind's walk over PAIRS -- {LABEL DECLARED EVIDENCE INDEX} each, in order
# (a construction's fields, a call's arguments) -- from the binding BINDING
# (variable -> evidence: a call's explicit imprints): {ok BINDING
# ESTABLISHERS} or {conflict SLOT LABEL PRIOR EV DIFFERENCE INDEX}. A
# variable of RIGID (an enclosing function's) is never established here.
proc hir::applied::BindPairs {pairs {binding {}} {rigid {}}} {
    set establishers [dict create]
    foreach slot [dict keys $binding] {
        dict set establishers $slot ""
    }
    foreach pair $pairs {
        lassign $pair name declared ev index
        set stack [list [list $declared $ev]]
        while {[llength $stack]} {
            lassign [lindex $stack end] d v
            set stack [lreplace $stack[set stack {}] end end]
            if {[hir::types::IsImprint $d]} {
                set slot [lindex $d 1]
                if {$slot in $rigid} {
                    continue
                }
                set v [Established $v]
                if {![dict exists $binding $slot] || [Canonical [dict get $binding $slot]] eq "never"} {
                    dict set binding $slot $v
                    dict set establishers $slot $name
                    continue
                }
                if {[Canonical $v] eq "never"} {
                    continue
                }
                set prior [dict get $binding $slot]
                set difference [Equal $prior $v]
                if {$difference ne ""} {
                    return [list conflict $slot $name $prior $v $difference $index]
                }
                continue
            }
            set pv [Parts $v]
            if {[hir::types::IsAppliedStruct $d] && $pv ne "" && [lindex $pv 0] eq [lindex $d 1]} {
                foreach dp [lreverse [lindex $d 2]] vp [lreverse [lindex $pv 1]] {
                    lappend stack [list $dp $vp]
                }
                continue
            }
            if {![hir::imprint::Mentions $d]} {
                continue
            }
            # A part that holds a variable inside no application (a List of
            # it, a function type): the bounded match, as inference makes
            # it (its form mismatches are inference's diagnostic).
            set canonical [dict create]
            dict for {slot ev} $binding {
                dict set canonical $slot [Canonical $ev]
            }
            set before [dict keys $canonical]
            if {[hir::imprint::MatchInner $d [Canonical $v] canonical $index] ne ""} {
                continue
            }
            dict for {slot t} $canonical {
                if {$slot ni $before} {
                    dict set binding $slot [Established [Leaf $t]]
                    dict set establishers $slot $name
                }
            }
        }
    }
    return [list ok $binding $establishers]
}

# EV as a slot's argument: an established variable is the type a
# declaration could state (InferApplication's Presentable, MatchInner's
# ForgetInferred) -- of a bounded part; an exact application is one.
proc hir::applied::Established {ev} {
    if {[lindex $ev 0] ne "type"} {
        return $ev
    }
    lassign $ev - t h
    set shown [hir::types::Presentable [hir::types::ForgetInferred $t]]
    if {$shown eq $t} {
        return $ev
    }
    return [list type $shown $h]
}

# ---------------------------------------------------------------------------
# Written types (the expected side)

# The evidence of the written type TYPEEXPR (syntax, as
# hir::resolve::ResolveTypeExpr reads it) when its application spine is
# deeper than the bound and it mentions no imprint variable, else "": the
# exact form the resolver records beside the bounded one. Its leaves --
# every part that is no application -- are ResolveTypeExpr's own (bounded)
# answers; the application spine is resolved here, one application at a
# time, with ResolveApplied's checks on each.
proc hir::applied::Written {typeExpr ns} {
    if {[Application $typeExpr $ns] eq ""} {
        return ""
    }
    # Post-order: {EXPR 0} expands an application, {EXPR 1} assembles it.
    set stack [list [list $typeExpr 0]]
    set out {}
    while {[llength $stack]} {
        lassign [lindex $stack end] t phase
        set stack [lreplace $stack[set stack {}] end end]
        set application [Application $t $ns]
        if {$application eq ""} {
            if {[catch {hir::resolve::ResolveTypeExpr $t $ns 0} type]} {
                # (An imprint variable, or what the bounded resolution
                # reported: no exact form.)
                return ""
            }
            lappend out [Leaf $type]
            continue
        }
        lassign $application id arguments
        if {$phase == 0} {
            lappend stack [list $t 1]
            foreach a [lreverse $arguments] {
                lappend stack [list $a 0]
            }
            continue
        }
        set n [llength $arguments]
        set args [lrange $out end-[expr {$n - 1}] end]
        set out [lreplace $out[set out {}] end-[expr {$n - 1}] end]
        if {$n != [llength [hir::structs::slots $id]]} {
            return ""
        }
        lappend out [App $id $args]
    }
    set ev [lindex $out 0]
    if {![Deep $ev]} {
        return ""
    }
    return $ev
}

# The exact written forms (Encode's) of the written types TYPEEXPRS whose
# resolved (bounded) types TYPES the bound cut, one per type ("" for the
# others), or "" when none has one: what the resolver records beside a
# parameter list, a result type or a call's explicit imprints.
proc hir::applied::WrittenList {typeExprs types ns} {
    set result {}
    set any 0
    foreach t $typeExprs type $types {
        set x ""
        if {$t ne {} && $type ne {} && [Cut $type]} {
            set ev [Written $t $ns]
            if {$ev ne ""} {
                set x [Encode $ev]
                set any 1
            }
        }
        lappend result $x
    }
    if {$any} {
        return $result
    }
    return ""
}

# {ID ARGUMENTS} when the written type TYPEEXPR is an application of a
# parameterized struct -- NAME[A, ...] ({apply NAME ARGS}) or NAME[A]
# ({NAME A}), as hir::resolve::ResolveTypeExpr reads them -- else "".
proc hir::applied::Application {typeExpr ns} {
    if {[hir::resolve::IsApplyTypeExpr $typeExpr]} {
        set id [hir::structs::lookup [lindex $typeExpr 1] $ns]
        set arguments [lindex $typeExpr 2]
    } elseif {[llength $typeExpr] == 2} {
        lassign $typeExpr name arg
        if {$name eq "fn" || [dict exists $::hir::types::constructors $name]} {
            return ""
        }
        set id [hir::structs::lookup $name $ns]
        set arguments [list $arg]
    } else {
        return ""
    }
    if {$id eq "" || ![hir::structs::isParameterized $id]} {
        return ""
    }
    return [list $id $arguments]
}

# EV in the flat form a HIR field holds it in: a list of nodes, the root
# first -- {a ID {CHILD...}} an application (children by index), {t TYPE H}
# a bounded part. Flat, so its string form is as long as the term, never
# quadratic.
proc hir::applied::Encode {ev} {
    set nodes {}
    set stack [list [list $ev -1 -1]]
    while {[llength $stack]} {
        lassign [lindex $stack end] x parent slot
        set stack [lreplace $stack[set stack {}] end end]
        set index [llength $nodes]
        if {[lindex $x 0] eq "app"} {
            lappend nodes [list a [lindex $x 1] [lrepeat [llength [lindex $x 2]] -1]]
            set i 0
            foreach a [lindex $x 2] {
                lappend stack [list $a $index $i]
                incr i
            }
        } else {
            lappend nodes [list t [lindex $x 1] [lindex $x 2]]
        }
        if {$parent >= 0} {
            set p [lindex $nodes $parent]
            lset p 2 $slot $index
            lset nodes $parent $p
        }
    }
    return $nodes
}

# The evidence of the flat form NODES (Encode's).
proc hir::applied::Decode {nodes} {
    set built [lrepeat [llength $nodes] ""]
    for {set i [expr {[llength $nodes] - 1}]} {$i >= 0} {incr i -1} {
        set node [lindex $nodes $i]
        if {[lindex $node 0] eq "a"} {
            lset built $i [App [lindex $node 1] [lmap c [lindex $node 2] {lindex $built $c}]]
        } else {
            lset built $i [list type [lindex $node 1] [lindex $node 2]]
        }
    }
    return [lindex $built 0]
}

# ---------------------------------------------------------------------------
# Reporting a difference

# Where the difference DIFFERENCE (Equal's, of the evidence of value
# expression E against an expected type) is reported: at the field of the
# deepest construction inside E whose slot the difference passes through,
# {CONSTRUCTION NAME EXPECTED} -- EXPECTED the expected application at that
# construction (an evidence) -- or "" (report at E itself). A construction
# reached through an alias is not inside E: its definition is no part of
# this use.
proc hir::applied::Locate {hir e difference} {
    set inside ""
    foreach entry [lreverse [Trail [lindex $difference 2]]] {
        lassign $entry v x slot
        if {[lindex $v 0] ne "app" || [lindex $v 5] eq "" || [lindex $v 6 $slot] eq ""} {
            continue
        }
        if {$inside eq ""} {
            set inside [Constructions $hir $e]
        }
        if {[dict exists $inside [lindex $v 5]]} {
            return [list [lindex $v 5] [lindex $v 6 $slot] $x]
        }
    }
    return ""
}

# The constructions inside expression E's own syntax (no alias followed, no
# nested function entered), as a set.
proc hir::applied::Constructions {hir e} {
    set set [dict create]
    set stack [list $e]
    while {[llength $stack]} {
        set x [lindex $stack end]
        set stack [lreplace $stack[set stack {}] end end]
        set node [dict get $hir exprs $x]
        if {[dict get $node kind] eq "block"} {
            continue
        }
        if {[dict get $node kind] eq "struct"} {
            dict set set $x 1
        }
        lappend stack {*}[hir::children $hir $x]
    }
    return $set
}

# ---------------------------------------------------------------------------
# The checks

# Checks the named construction E (NODE) of a parameterized struct whose
# bounded type TYPE the bound cut (hir::range::VerifyStruct's case): each
# field value against its declared field type with the slots the
# construction itself establishes -- its written application at its own
# top, or the evidence of its field values, every later establishing field
# held to the first exactly (Bind) -- never against the arguments its
# bounded type keeps, which are cut one application earlier than the value
# standing in the field.
proc hir::applied::VerifyConstruction {hirVar ranges e node type} {
    upvar 1 $hirVar hir
    set id [dict get $node structId]
    set matched {}
    if {[dict exists $node structArgs]} {
        set args [WrittenArgs $node]
    } else {
        set fields [dict create]
        foreach name [dict get $node names] field [dict get $node fields] {
            if {![dict exists $fields $name]} {
                dict set fields $name [Of hir $field]
            }
        }
        set bound [Bind $id $fields]
        if {[lindex $bound 0] eq "conflict"} {
            lassign $bound - slot name prior ev - index
            Count conflicts
            hir::Diagnose hir IMPRINT [ConflictMessage $id $slot $name $prior $ev $index] $e
            return
        }
        lassign $bound - binding
        set args {}
        foreach slot [hir::structs::slots $id] {
            if {![dict exists $binding $slot]} {
                # (Not established: inference's diagnostic.)
                return
            }
            lappend args [dict get $binding $slot]
        }
        # (A field the binding was read from was compared exactly there.)
        foreach name [dict keys $fields] {
            if {[hir::imprint::Mentions [hir::structs::fieldType $id $name]]} {
                lappend matched $name
            }
        }
    }
    set shown ""
    foreach name [dict get $node names] field [dict get $node fields] origin [dict get $node fieldOrigins] {
        set expected [FieldExpected $id $args $name]
        if {$expected eq ""} {
            continue
        }
        set valueType [hir::typeOf $hir $field]
        if {$valueType eq "never" || ![hir::get $hir $field reachable]} {
            continue
        }
        set declared [Canonical $expected]
        set valueRange [dict getdef $ranges $field [hir::range::unknown]]
        if {![hir::range::ProvesValueAcceptedBy $valueType $valueRange $declared]} {
            if {$shown eq ""} {
                set shown [Show [App $id $args $type]]
            }
            hir::DiagnoseAt hir TYPE [format \
                {field "%s" of struct %s cannot be proven to satisfy its declared type %s (value type: %s%s)%s} \
                $name $shown [Show $expected] \
                [hir::types::show [hir::range::ShownArgType $valueType $declared]] \
                [hir::range::FactsClause $valueType $declared $valueRange] \
                [hir::range::MismatchClause $valueType $declared]] $field $origin
            continue
        }
        if {$name in $matched && [hir::structs::exactFieldType $id $name] eq ""} {
            continue
        }
        Expect hir $ranges $field [Of hir $field] $expected \
            [list field $name [App $id $args $type] $origin]
    }
}

# The exact layer of a check whose bounded part passed: the value expression
# E, of evidence V, where the evidence EXPECTED is required. Reports the
# first exact difference of two applications the bounded check could not
# see (Accept) -- at the field of the deepest construction inside E the
# difference passes through (Locate), else as SITE says: {field NAME
# STRUCT-EVIDENCE ORIGIN}, {argument PARAMETER-NAME}, {result BLOCK}. 1 if it
# reported.
proc hir::applied::Expect {hirVar ranges e v expected site} {
    upvar 1 $hirVar hir
    set difference [Accept $v $expected]
    if {$difference eq ""} {
        return 0
    }
    Count differences
    set at [Locate $hir $e $difference]
    if {$at ne ""} {
        lassign $at construction name application
        set node [dict get $hir exprs $construction]
        set i [lsearch -exact [dict get $node names] $name]
        set field [lindex [dict get $node fields] $i]
        set origin [lindex [dict get $node fieldOrigins] $i]
        set parts [Parts $application]
        set fieldExpected [FieldExpected [lindex $parts 0] [lindex $parts 1] $name]
        set fieldEv [Of hir $field]
        set valueType [Canonical $fieldEv]
        set declared [Canonical $fieldExpected]
        hir::DiagnoseAt hir TYPE [format \
            {field "%s" of struct %s cannot be proven to satisfy its declared type %s (value type: %s%s)%s} \
            $name [Show $application] [Show $fieldExpected] [Show $fieldEv] \
            [hir::range::FactsClause $valueType $declared [dict getdef $ranges $field [hir::range::unknown]]] \
            [Clause $fieldEv $fieldExpected]] $field $origin
        return 1
    }
    set clause [Clause $v $expected]
    switch -- [lindex $site 0] {
        field {
            lassign $site - name application origin
            hir::DiagnoseAt hir TYPE [format \
                {field "%s" of struct %s cannot be proven to satisfy its declared type %s (value type: %s)%s} \
                $name [Show $application] [Show $expected] [Show $v] $clause] $e $origin
        }
        argument {
            hir::Diagnose hir TYPE [format \
                {argument for parameter "%s" cannot be proven to satisfy %s (argument type: %s)%s} \
                [lindex $site 1] [Show $expected] [Show $v] $clause] $e
        }
        result {
            hir::Diagnose hir TYPE [format {function result does not prove declared type %s (value type: %s)%s} \
                [Show $expected] [Show $v] $clause] [lindex $site 1]
        }
    }
    return 1
}

# The reason two applications of one declaration, the evidence V and the
# expected E, differ: MismatchClause's wording for applications, each slot
# shown exactly.
proc hir::applied::Clause {v e} {
    set pv [Parts $v]
    set pe [Parts $e]
    if {$pv eq "" || $pe eq "" || [lindex $pv 0] ne [lindex $pe 0]} {
        return [hir::range::MismatchClause [Canonical $v] [Canonical $e]]
    }
    set id [lindex $pe 0]
    set slots {}
    foreach slot [hir::structs::slots $id] a [lindex $pv 1] d [lindex $pe 1] {
        if {[Equal $a $d] ne ""} {
            lappend slots "$slot is [Show $a], not [Show $d]"
        }
    }
    if {$slots eq {}} {
        return ""
    }
    return [format {; %s and %s are distinct applications of %s (%s): an application is a type of its own for each argument of each slot, and no slot is converted, widened or narrowed} \
        [Show $v] [Show $e] [hir::structs::display $id] [::join $slots {, }]]
}

# ---------------------------------------------------------------------------
# Typing (hir::types)
#
# A projection of a value whose bounded type the bound cut reads the field's
# type out of the cut arguments -- one application earlier than the field's
# own value is cut, and `any` after appliedDepth projections, where
# x.value.value... of a Box 1000 deep was UNPROVEN-FIELD. While a typing walk
# runs, the evidence of each construction the bound cut is kept in its
# typing context (ctx's `applied`: ExprId -> evidence, only where the
# evidence says more than the type), and a projection of a value with
# evidence has the canonical type of the field's evidence: the type of the
# field value the program constructed. The context is the walk's own
# (hir::types::NewContext), so evidence never outlives the types it was
# read from.

# Records the evidence of the named construction E, just typed TYPE, in the
# typing context (ctxVar): Typed's case of a construction.
proc hir::applied::TypedConstruction {hirVar ctxVar e type} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {![hir::types::IsAppliedStruct $type] || ![Cut $type]} {
        if {[dict exists $ctx applied $e]} {
            dict unset ctx applied $e
        }
        return
    }
    set node [dict get $hir exprs $e]
    set fields [dict create]
    foreach name [dict get $node names] field [dict get $node fields] {
        if {![dict exists $fields $name]} {
            dict set fields $name [TypedOf $hir $ctx $field]
        }
    }
    set ev [Constructed $e $node $type $fields]
    if {$ev ne "" && [Deep $ev]} {
        dict set ctx applied $e $ev
    } elseif {[dict exists $ctx applied $e]} {
        dict unset ctx applied $e
    }
}

# The evidence of the already-typed expression E in the typing context CTX:
# a construction's (recorded as it was typed), an immutable alias's value's,
# an `if`'s when both branches end in the same evidence (one that never
# completes says nothing) -- followed at most maxSteps aliases and branches,
# a determinism guard like hir/exactvalue.tcl's: past it, the bounded type.
proc hir::applied::TypedOf {hir ctx e {steps 0}} {
    variable maxSteps
    while {$steps < $maxSteps} {
        incr steps
        if {[dict exists $ctx applied $e]} {
            return [dict get $ctx applied $e]
        }
        set node [dict get $hir exprs $e]
        switch -- [dict get $node kind] {
            ref {
                set value [AliasValue $hir $node]
                if {$value eq ""} {
                    break
                }
                set e $value
                continue
            }
            if {
                set branches [Branches $hir $node]
                if {$branches eq ""} {
                    break
                }
                set evs [lmap b $branches {TypedOf $hir $ctx $b $steps}]
                return [Join $hir $e $evs]
            }
        }
        break
    }
    return [Leaf [hir::typeOf $hir $e]]
}

# The expressions whose values the `if` NODE completes with, one per branch
# (each branch's last expression), or "" when a branch has none.
proc hir::applied::Branches {hir node} {
    set branches {}
    foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
        if {$body eq ""} {
            return ""
        }
        lappend branches [lindex $body end]
    }
    return $branches
}

# The evidence of the `if` E whose branches end in the evidence EVS: the
# branches' when every branch that completes has the same (Equal), else
# {either MEMBERS TYPE} -- its value is one of theirs, each held to a
# position it is admitted to (Accept) -- with E's bounded type.
proc hir::applied::Join {hir e evs} {
    set type [hir::typeOf $hir $e]
    set members {}
    set joined ""
    set same 1
    foreach ev $evs {
        if {[Canonical $ev] eq "never"} {
            continue
        }
        lappend members $ev
        if {$joined eq ""} {
            set joined $ev
        } elseif {[Equal $joined $ev] ne ""} {
            set same 0
        }
    }
    if {$joined eq ""} {
        return [Leaf $type]
    }
    if {$same && [Canonical $joined] eq $type} {
        return $joined
    }
    # (Different evidence: the value is one of the members'.)
    return [list either $members $type]
}

# The type of the projection E of field NAME out of the receiver expression
# RECEIVER, whose type the bound cut, in the typing context ctxVar: the
# canonical type of the field's evidence, recorded for a further projection
# -- or "" when the receiver has no evidence (the bounded field type stays).
proc hir::applied::TypedProjection {hirVar ctxVar e receiver name} {
    upvar 1 $hirVar hir $ctxVar ctx
    set fev [FieldOf [TypedOf $hir $ctx $receiver] $name]
    if {$fev eq ""} {
        return ""
    }
    Count projections
    if {[Deep $fev]} {
        dict set ctx applied $e $fev
    } elseif {[dict exists $ctx applied $e]} {
        dict unset ctx applied $e
    }
    return [Canonical $fev]
}

# Records the evidence of the construction E (NODE) of a struct with no type
# slots, in the typing context ctxVar, when a field's says more than its
# type.
proc hir::applied::TypedNamed {hirVar ctxVar e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {![NamedConstruction $node]} {
        return
    }
    set ev [Named $node [list hir::applied::TypedOf $hir $ctx]]
    if {$ev ne ""} {
        dict set ctx applied $e $ev
    } elseif {[dict exists $ctx applied $e]} {
        dict unset ctx applied $e
    }
}

# The exact layer of the checks of call E (NODE) of block TARGET, whose
# arguments' bounded checks hir::range::VerifyCallChecks made against the
# parameter types DECLARED (the call's, imprinted): where an argument's
# evidence, the callee's written parameter type or the call's written
# imprint says more than a bounded type, the imprint variables are bound
# from the arguments' evidence exactly (BindPairs: an argument establishing a
# variable another established differently is the IMPRINT it is, however
# deep the difference) and each argument the bounded check admitted is held
# to its parameter's exact type (Expect).
proc hir::applied::VerifyArguments {hirVar ranges e node target declared} {
    upvar 1 $hirVar hir
    set args [dict get $node args]
    set targetNode [dict get $hir exprs $target]
    set exactParams [dict getdef $targetNode exactParamTypes {}]
    set exactImprint [dict getdef $node exactImprint {}]
    set deep [expr {$exactParams ne {} || $exactImprint ne {}}]
    foreach arg $args {
        if {$arg ne "" && [Cut [hir::typeOf $hir $arg]]} {
            # (Only the evidence of a value the bound cut says more.)
            set deep 1
            break
        }
    }
    if {!$deep} {
        return
    }
    set evs [lmap arg $args {if {$arg eq ""} {list type any ""} else {Of hir $arg}}]
    Count calls
    # The imprint variables, bound exactly.
    set sig [hir::imprint::Signature $hir [hir::typeOf $hir [dict get $node callee]]]
    set binding [dict create]
    set canonical [dict create]
    if {$sig ne ""} {
        set explicit [dict getdef $node imprint ""]
        if {$explicit ne ""} {
            foreach name [dict get $sig vars] type $explicit x [if {$exactImprint ne {}} {set exactImprint} else {lrepeat [llength $explicit] ""}] {
                dict set binding $name [if {$x ne ""} {Decode $x} else {Leaf $type}]
            }
        } else {
            set pairs {}
            set index 0
            foreach param [dict get $sig params] ev $evs arg $args {
                incr index
                if {$param eq "" || $arg eq "" || ![hir::imprint::Mentions $param] || [dict exists $hir poisoned $arg]} {
                    continue
                }
                lappend pairs [list $index $param $ev $index]
            }
            set bound [BindPairs $pairs {} [dict getdef $sig enclosing {}]]
            if {[lindex $bound 0] eq "conflict"} {
                lassign $bound - slot - prior ev - index
                Count conflicts
                hir::Diagnose hir IMPRINT [format {%s: imprint variable %s is %s by an earlier argument but %s by argument %d} \
                    [hir::imprint::CalleeName $hir $node] [hir::imprint::Shown $slot] [Show $prior] [Show $ev] $index] $e
                return
            }
            set binding [lindex $bound 1]
        }
        dict for {name ev} $binding {
            dict set canonical $name [Canonical $ev]
        }
    }
    set params [dict get $targetNode params]
    set i 0
    foreach arg $args ev $evs param $params type $declared {
        set x [lindex $exactParams $i]
        set sigParam [if {$sig ne ""} {lindex [dict get $sig params] $i} else {string cat ""}]
        incr i
        if {$type eq {} || $arg eq "" || [dict exists $hir poisoned $arg]
                || [hir::signatures::inferredTrusted $hir $target [expr {$i - 1}]]} {
            continue
        }
        set range [dict getdef $ranges $arg [hir::range::unknown]]
        if {![hir::range::ProvesValueAcceptedBy [hir::typeOf $hir $arg] $range $type]} {
            # (The bounded check's diagnostic.)
            continue
        }
        if {$x ne ""} {
            set expected [Decode $x]
        } elseif {$sigParam ne "" && [dict size $binding] && [hir::imprint::Mentions $sigParam]} {
            set expected [Substitute $sigParam $binding $canonical]
        } else {
            set expected [Leaf $type]
        }
        if {[Expect hir $ranges $arg $ev $expected [list argument [hir::semantic::SourceName $hir $param]]]
                && ![dict exists $hir semanticContext]} {
            dict set hir violatedDeclared $param $arg
        }
    }
}

# The exact layer of block E's declared result check, whose bounded part
# passed: where the written result type or an exit's evidence says more
# than a bounded type, each exit's value is held to the declared result
# exactly (Expect).
proc hir::applied::VerifyResult {hirVar e node} {
    upvar 1 $hirVar hir
    set x [dict getdef $node exactResult ""]
    set expected [if {$x ne ""} {Decode $x} else {Leaf [dict get $node declaredResult]}]
    foreach exit [hir::warnings::Exits $hir $e] {
        set value [lindex $exit 1]
        set ev [Of hir $value]
        if {$x eq "" && ![Deep $ev]} {
            continue
        }
        Count results
        if {[Expect hir {} $value $ev $expected [list result $e]]} {
            return
        }
    }
}

# The slot binding the field values of the construction E of ID establish
# from their evidence in the typing context CTX, when some field's evidence
# says more than its type: {ok BINDING} (slot -> canonical type) or
# {conflict MESSAGE}, else "" -- inference's own answer where a bounded one
# read a variable out of a cut argument (hir::types::InferApplication).
proc hir::applied::TypedBinding {hir ctx e id} {
    set node [dict get $hir exprs $e]
    set fields [dict create]
    set deep 0
    foreach name [dict get $node names] field [dict get $node fields] {
        if {[dict exists $fields $name]} {
            continue
        }
        set ev [TypedOf $hir $ctx $field]
        dict set fields $name $ev
        if {[Deep $ev]} {
            set deep 1
        }
    }
    if {!$deep} {
        return ""
    }
    set bound [Bind $id $fields]
    if {[lindex $bound 0] ne "ok"} {
        lassign $bound - slot name prior ev - index
        return [list conflict [ConflictMessage $id $slot $name $prior $ev $index]]
    }
    set binding [dict create]
    dict for {slot ev} [lindex $bound 1] {
        dict set binding $slot [Canonical $ev]
    }
    return [list ok $binding]
}

# The IMPRINT message of a construction of ID whose field NAME (the INDEX-th)
# establishes SLOT as EV where an earlier field established it as PRIOR
# (both evidence): inference's wording (hir::types::InferApplication), the
# types exact.
proc hir::applied::ConflictMessage {id slot name prior ev index} {
    return [format {the construction %s {...} cannot establish its type slots from field "%s": imprint variable %s is %s by an earlier argument but %s by field %d} \
        [hir::structs::display $id] $name [hir::imprint::Shown $slot] [Show $prior] [Show $ev] $index]
}

# ---------------------------------------------------------------------------
# Constrained slots (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md)
#
# A constrained slot's argument is judged by the trait's satisfaction; an
# intrinsic trait's witness predicate (Hashable, Equatable) is a class of
# the declaration summaries (hir/summaries.tcl), which answer an application
# from its arguments' classes -- so an exact argument's class is found
# without unfolding anything but the evidence the program wrote or built,
# where the bounded argument's `any` would satisfy nothing.

# The Totality class of OPERATION (equality, hash) of evidence EV --
# total, unknown or none -- and the part responsible for it ({CLASS PART}:
# PART "" for total): an exact application's class is its declaration
# summary's applied to its arguments' classes, the part the argument the
# summary names (hir::summaries::Contributor), else the application itself
# (its own fields); a bounded part's class is its type's.
proc hir::applied::TotalityClass {operation ev} {
    set classes {total unknown none}
    set stack [list [list $ev 0]]
    set out {}
    while {[llength $stack]} {
        lassign [lindex $stack end] x phase
        set stack [lreplace $stack[set stack {}] end end]
        if {[lindex $x 0] ne "app" || ![lindex $x 4]} {
            set level [lsearch -exact $classes [hir::types::TotalityClassOf $operation [Canonical $x]]]
            lappend out [list $level [if {$level} {list $x} else {string cat ""}]]
            continue
        }
        if {$phase == 0} {
            lappend stack [list $x 1]
            foreach a [lreverse [lindex $x 2]] {
                lappend stack [list $a 0]
            }
            continue
        }
        set n [llength [lindex $x 2]]
        set parts [lrange $out end-[expr {$n - 1}] end]
        set out [lreplace $out[set out {}] end-[expr {$n - 1}] end]
        set levels [lmap p $parts {lindex $p 0}]
        set type [list nstruct [lindex $x 1]]
        set level [hir::summaries::Level totality.$operation $type $levels]
        if {$level eq ""} {
            set level [lsearch -exact $classes [hir::types::TotalityClassOf $operation [lindex $x 3]]]
        }
        set responsible ""
        if {$level} {
            set i [hir::summaries::Contributor totality.$operation $type $levels $level]
            set responsible [if {$i ne ""} {lindex $parts $i 1} else {list $x}]
        }
        lappend out [list $level $responsible]
    }
    lassign [lindex $out 0] level responsible
    return [list [lindex $classes $level] [lindex $responsible 0]]
}

# 1 if the type evidence EV describes satisfies trait TRAIT: an intrinsic
# trait whose witnesses are Totality classes (Hashable: equality and hash
# total; Equatable: equality total) by the evidence's classes, any other by
# the ordinary satisfaction of its bounded type (an ordinary trait's
# conformance reads its witness's owner, which the bound keeps).
proc hir::applied::Satisfies {ev trait} {
    set witness ""
    if {[hir::traits::isIntrinsic $trait]} {
        set witness [dict get $::hir::traits::intrinsics $trait witness]
    }
    return [expr {[lindex [Unsatisfied $ev $trait] 0] eq ""}]
}

# {"" ""} when the type evidence EV describes satisfies trait TRAIT, else
# {REASON PART}: why not, in source terms, and the part of EV it is about.
proc hir::applied::Unsatisfied {ev trait} {
    set witness ""
    if {[hir::traits::isIntrinsic $trait]} {
        set witness [dict get $::hir::traits::intrinsics $trait witness]
    }
    switch -- $witness {
        hir::types::HashClass - hir::types::EqualityClass {
            set operations [expr {$witness eq "hir::types::HashClass" ? {equality hash} : {equality}}]
            foreach operation $operations {
                lassign [TotalityClass $operation $ev] class part
                if {$class eq "total"} {
                    continue
                }
                set why [lindex [hir::types::Totality $operation [Canonical $part]] 1]
                if {$part ne $ev} {
                    set why "it holds [Show $part]: $why"
                }
                return [list $why $part]
            }
            return {"" ""}
        }
    }
    set s [hir::traits::satisfies [Canonical $ev] $trait]
    if {[dict get $s ok]} {
        return {"" ""}
    }
    return [list [dict get $s reason] $ev]
}

# hir::structs::ApplicationIssue of the type evidence EV describes: "" or
# {KIND MESSAGE}. Where the bounded type's only issue is a constrained
# slot's TRAIT-NOT-SATISFIED and EV holds an exact application, every
# application in EV has its constrained slots judged on the evidence
# (Satisfies), its bounded parts by the bounded check.
proc hir::applied::Issue {ev} {
    set canonical [hir::structs::ApplicationIssue [Canonical $ev]]
    if {[lindex $canonical 0] ne "TRAIT-NOT-SATISFIED" || ![Deep $ev]} {
        return $canonical
    }
    Count constraints
    set stack [list $ev]
    while {[llength $stack]} {
        set x [lindex $stack end]
        set stack [lreplace $stack[set stack {}] end end]
        if {[lindex $x 0] ne "app" || ![lindex $x 4]} {
            set issue [hir::structs::ApplicationIssue [Canonical $x]]
            if {$issue ne ""} {
                return $issue
            }
            continue
        }
        set id [lindex $x 1]
        set constraints [hir::structs::slotConstraints $id]
        foreach slot [hir::structs::slots $id] arg [lindex $x 2] {
            if {[Canonical $arg] eq "never"} {
                continue
            }
            foreach trait [dict getdef $constraints $slot {}] {
                set why [lindex [Unsatisfied $arg $trait] 0]
                if {$why ne ""} {
                    return [list TRAIT-NOT-SATISFIED [format {type argument for "%s" in %s does not satisfy %s: %s} \
                        $slot [Show $x] $trait $why]]
                }
            }
        }
        lappend stack {*}[lindex $x 2]
    }
    set recursion [hir::structs::OwnedRecursion [Canonical $ev]]
    if {$recursion ne ""} {
        return $canonical
    }
    return ""
}

# ApplicationIssue of the construction E, typed TYPE (cut), on the evidence
# of its field values in the typing context CTX.
proc hir::applied::TypedIssue {hir ctx e type} {
    set node [dict get $hir exprs $e]
    set fields [dict create]
    foreach name [dict get $node names] field [dict get $node fields] {
        if {![dict exists $fields $name]} {
            dict set fields $name [TypedOf $hir $ctx $field]
        }
    }
    set ev [Constructed $e $node $type $fields]
    if {$ev eq ""} {
        return [hir::structs::ApplicationIssue $type]
    }
    return [Issue $ev]
}
