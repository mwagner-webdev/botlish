# injection.tcl -- restricted context injection
# (RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md).
#
#   inject context Storage, Clock:        the block's code may use exactly
#       BODY                              Storage and Clock
#   inject no context:                    ... and no context at all
#       BODY
#
# Installing a context makes an implementation available to the program;
# injecting it grants a computation permission to use it. An inject block is
# a computation that receives the authority explicitly injected into it, not
# all the authority its creator happens to possess. Nothing about
# installation or selection changes: a context is installed once, at the
# entry program's top level; a context trait's implementation is selected
# once per program (CONTEXTS.md, CONTEXT-TRAITS.md); an inject block only
# narrows which of the contexts already available its code may use. It is a
# static restriction: no runtime representation, permission table, context
# copy or alternate selection exists, on any backend.
#
# Representation. The block is the ordinary `if true:` block (surface/
# lower.tcl's `inject` case: the form an accepted static block takes),
# carrying the restriction as one field of the `if` expression:
#
#   if expr   injects   the injected context identities (context structs or
#                       context traits), in written order
#
# Every analysis and backend reads the block as what it is -- code that
# runs once, right there, scoping what it binds -- and only this file and
# hir/contexts.tcl read `injects`.
#
# The rules (an inject block R, its injected set I(R), the function O whose
# code R is part of, "" at top level):
#
#   grant      R is a use of I(R) by O: O requires every context of I(R)
#              (hir::contexts::Requirements' grants), so a function that
#              injects a context requires it, its callers derive the
#              requirement as for any other use, and an enclosing inject
#              block must have injected it. At top level each injected
#              context must be installed (a context trait: implemented by
#              exactly one installed context) where the block runs:
#              MISSING-CONTEXT, AMBIGUOUS-CONTEXT-IMPLEMENTATION.
#   calls      every call of R's code -- a call, a method-style call, a
#              coroutine construction (a call of its thunk), the operation of
#              an ordinary trait as the selected implementation graph binds it
#              -- requires only contexts of I(R): the callee's transitive
#              requirement (hir::contexts::Requirements, the existing
#              analysis; never a second reachability) must be a subset of
#              I(R). CONTEXT-NOT-INJECTED otherwise, with the requirement's
#              chain. A context trait injected grants its operations through
#              the implementation the program selected; it does not grant
#              the implementing context's other functions.
#   nesting    an inject block in R's code injects a subset of I(R): a
#              computation grants only authority it was given
#              (CONTEXT-NOT-INJECTED at the inner block).
#   bindings   R's code never refers to a context parameter of an enclosing
#              function whose context I(R) lacks (a context parameter is the
#              enclosing computation's authority, CONTEXT-NOT-INJECTED), nor
#              calls a function that does (Captures: a nested function
#              defined outside R reading its enclosing function's context
#              parameter uses that context).
#   direct     a call of R's code to a designated direct module is mediated
#              (DIRECT-MODULES.md) only by an injected context of the calling
#              module: a context the enclosing function declares but R does
#              not inject mediates nothing inside R (CONTEXT-NOT-INJECTED). A
#              direct module's own raw authority is acknowledged at its
#              boundary and is not context authority.
#   retained   R never resumes a coroutine whose retained authority is not
#              within I(R) (CONTEXT-RETAINED-AUTHORITY; below).
#
# Retained authority. A coroutine fixes its context providers when it is
# constructed (COROUTINES.md, "Context interaction"): its construction is a
# call of its thunk, checked where it is made, and a resume selects nothing.
# Its handle type does not say what it retained, so a handle constructed by
# privileged code and resumed inside R would run privileged code inside R.
# A static provenance analysis closes this (Provenance): every value that
# may hold a coroutine handle carries a set of *origins* --
#
#   {auth IDS C}          a handle constructed (by construction call C) with
#                         the requirement IDS (its thunk's transitive
#                         requirement); a handle also carries the origins of
#                         the handles its own code resumes
#   {p BLOCK I}           whatever the caller passed as BLOCK's parameter I
#                         (substituted at each call)
#   {foreign WHY ...}     a handle whose construction is unknown here: moved
#                         out of an installed context's state (installed by
#                         anyone), a handler's affine payload
#
# -- and every function gets two summaries over the requirement graph's
# nodes (the same edges, Targets): the origins of the handles it may resume
# (directly, through its callees with their parameters substituted, through
# a call of a function value, which may resume what it is passed) and the
# origins that may leave it (its result, and what it moves into its place
# parameters). A resume in R, or a call in R whose callee may resume, is
# accepted only when every origin is {auth IDS C} with IDS a subset of I(R).
# The rule is sound because no other channel can carry a handle into a
# computation: a coroutine never yields, returns or is resumed with an
# affine value (COROUTINE-CONTRACT), a closure never captures one
# (AFFINE-CAPTURE-UNSUPPORTED), `any` never holds one
# (AFFINE-ERASURE-UNSUPPORTED) and no module binding is one -- what is left
# is construction, arguments, results, places, installed context state and
# error payloads, each of which the analysis follows or treats as foreign.
# It is conservative: an origin it cannot follow rejects a resume, never
# accepts it. Moving a handle without resuming it (adopting it into an event
# loop, handing it back) is no use of its authority and is accepted.
#
# The monomorphized program (hir::traits::monomorphize) is the checked
# program with every trait resolved: injections are judged as written, in
# the checked build, and the monomorphized one only carries the field.

namespace eval hir::injection {}

# ---------------------------------------------------------------------------
# Resolution (hir/resolve.tcl's `if` case)

# The canonical context identities of an inject block's ENTRIES ({TYPEEXPR
# ORIGIN} pairs in written order), resolved in module namespace NS for the
# block E. Diagnoses, at the entry:
#   TYPE                         the type does not resolve
#   NOT-A-CONTEXT                neither a context struct nor a context trait
#   DUPLICATE-INJECTED-CONTEXT   the same context twice
proc hir::injection::Resolve {hirVar e entries ns} {
    upvar 1 $hirVar hir
    set ids {}
    foreach entry $entries {
        lassign $entry typeExpr origin
        if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} type]} {
            hir::DiagnoseAt hir TYPE \
                [format {unknown or invalid type %s injected by this inject block: %s} \
                    [hir::resolve::ShowTypeExpr $typeExpr] $type] $e $origin
            continue
        }
        if {[hir::traits::IsContextTraitType $type]} {
            set id [lindex $type 1]
        } elseif {[lindex $type 0] eq "nstruct" && [hir::structs::isContext [lindex $type 1]]} {
            set id [lindex $type 1]
        } else {
            set what [if {[hir::types::IsTrait $type]} {
                string cat "a trait, an abstraction over values"
            } else {
                string cat "not a context"
            }]
            hir::DiagnoseAt hir NOT-A-CONTEXT \
                [format {inject: %s is %s (an inject block injects contexts: a type declared "context struct" or "context trait")} \
                    [hir::types::show $type] $what] $e $origin
            continue
        }
        if {$id in $ids} {
            hir::DiagnoseAt hir DUPLICATE-INJECTED-CONTEXT \
                "inject: $id is injected twice by this inject block (an inject block names each context it injects once)" \
                $e $origin
            continue
        }
        lappend ids $id
    }
    return $ids
}

# ---------------------------------------------------------------------------
# Queries

# 1 if expression E (of HIR) is an inject block.
proc hir::injection::isInject {hir e} {
    return [expr {[dict get $hir exprs $e kind] eq "if" && [dict exists $hir exprs $e injects]}]
}

# The context identities inject block E injects.
proc hir::injection::injects {hir e} {
    return [dict get $hir exprs $e injects]
}

# The reachable inject blocks of HIR, in expression order.
proc hir::injection::Blocks {hir} {
    set result {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "if" && [dict exists $node injects] && [dict get $node reachable]} {
            lappend result $e
        }
    }
    return $result
}

# 1 if the restriction is judged in this build: the program as written,
# never the monomorphized one (header).
proc hir::injection::Judged {hir} {
    return [expr {![hir::traits::Planning] && ![dict exists $hir traitSource]}]
}

# The grants of HIR's inject blocks, for hir::contexts::Requirements: OWNER
# (WALK's owner map) block -> {ID BLOCK ...}, the contexts each function's own
# inject blocks inject (an inject block is a use of what it injects), the
# first block granting each. "" (top level) is not a function: a top-level
# block's injection is checked where it runs (Available).
proc hir::injection::Grants {hir owner} {
    set grants [dict create]
    if {![Judged $hir]} {
        return $grants
    }
    foreach r [Blocks $hir] {
        set o [dict get $owner $r]
        if {$o eq ""} continue
        foreach id [injects $hir $r] {
            if {![dict exists $grants $o $id]} {
                dict set grants $o $id $r
            }
        }
    }
    return $grants
}

# "injects no context" / "injects only A, B": what inject block R grants,
# for messages.
proc hir::injection::What {hir r} {
    set ids [injects $hir $r]
    if {$ids eq {}} {
        return "injects no context"
    }
    return "injects only [join $ids {, }]"
}

proc hir::injection::Where {hir r} {
    return [hir::originLocation $hir [dict get $hir exprs $r origin]]
}

# ---------------------------------------------------------------------------
# Verification (hir::CheckOnce, after hir::direct::verify)

proc hir::injection::verify {hirVar} {
    upvar 1 $hirVar hir
    if {![Judged $hir]} {
        return
    }
    set blocks [Blocks $hir]
    if {$blocks eq {}} {
        return
    }
    set walk [hir::contexts::Walk $hir]
    lassign $walk owner parent rootOf calls fns
    set graph [dict getdef $hir implementations {}]
    set analysis [hir::contexts::Requirements $hir $walk $graph]
    set required [dict get $analysis required]
    set reasons [dict get $analysis reasons]
    set regionRoot [dict get $analysis regionRoot]
    set nodes [dict get $analysis nodes]
    # Each inject block's subtree (every expression of its code, nested
    # functions included) and the innermost block of every expression in
    # one: outer blocks first (larger subtrees), inner ones overwrite.
    set subtree [dict create]
    foreach r $blocks {
        dict set subtree $r [Subtree $hir $r]
    }
    set innermost [dict create]
    foreach r [lsort -command [list hir::injection::Larger $subtree] $blocks] {
        foreach e [dict keys [dict get $subtree $r]] {
            dict set innermost $e $r
        }
    }
    # The enclosing inject block of each one, of the same function's code.
    set enclosing [dict create]
    foreach r $blocks {
        set p [lindex [dict get $parent $r] 0]
        dict set enclosing $r ""
        while {$p ne ""} {
            if {[dict exists $subtree $p] && $p ne $r} {
                if {[dict get $owner $p] eq [dict get $owner $r]} {
                    dict set enclosing $r $p
                }
                break
            }
            set p [lindex [dict get $parent $p] 0]
        }
    }
    set installed [InstalledAt $hir]
    set captures [Captures $hir $owner $nodes [dict get $analysis edges]]
    set provenance [Provenance $hir $walk $analysis $graph]
    # The contexts each rejected call was reported missing: a coroutine
    # constructed by a rejected construction retains them, and a later
    # resume of it restates that rejection (never reported again).
    set rejected [dict create]
    set retainedChecks {}
    foreach r $blocks {
        set o [dict get $owner $r]
        set ids [injects $hir $r]
        set outer [dict get $enclosing $r]
        set available {}
        if {$o eq ""} {
            set root [dict get $rootOf $r]
            set available [dict get $installed $root]
        }
        if {$outer ne ""} {
            # nesting: a subset of what the enclosing block injects.
            foreach id $ids {
                if {$id ni [injects $hir $outer]} {
                    hir::Diagnose hir CONTEXT-NOT-INJECTED \
                        "this inject block injects $id, which the enclosing inject block (at [Where $hir $outer]) does not inject: a computation grants only authority it was given (the enclosing block [What $hir $outer])" $r
                }
            }
        } elseif {$o eq ""} {
            # grant, at top level: installed where the block runs.
            Available hir $r $ids $available
        }
        set inside [dict get $subtree $r]
        foreach e [dict keys $inside] {
            if {[dict get $innermost $e] ne $r} continue
            switch -- [hir::kind $hir $e] {
                ref {
                    CheckBinding hir $r $e $inside
                }
                call {
                    if {[dict get $owner $e] ne $o || ![hir::get $hir $e reachable]} continue
                    if {[hir::contexts::isLoad $hir $e] || [hir::contexts::isInstall $hir $e]} continue
                    set missing [CheckCall hir $r $e $o $ids $available $required $reasons \
                        $regionRoot $graph $captures $inside]
                    if {$missing ne {}} {
                        dict set rejected $e $missing
                    }
                    lappend retainedChecks [list $r $e $ids]
                }
            }
        }
        CheckDirect hir $r $o $ids $inside $innermost
    }
    foreach check $retainedChecks {
        lassign $check r e ids
        CheckRetained hir $r $e $ids $rejected $provenance
    }
}

# A dict of every expression of E's subtree (E included), nested functions'
# code included, in evaluation (pre-)order.
proc hir::injection::Subtree {hir e} {
    set result [dict create]
    set stack [list $e]
    while {$stack ne {}} {
        set x [lindex $stack end]
        set stack [lrange $stack 0 end-1]
        dict set result $x 1
        lappend stack {*}[lreverse [hir::children $hir $x]]
    }
    return $result
}

proc hir::injection::Larger {subtree a b} {
    set x [dict size [dict get $subtree $a]]
    set y [dict size [dict get $subtree $b]]
    return [expr {$x > $y ? -1 : ($x < $y ? 1 : 0)}]
}

# Root expression -> the context structs installed before it runs, in
# installation order (an installation is a root statement: hir/contexts.tcl).
proc hir::injection::InstalledAt {hir} {
    set byRoot [dict create]
    foreach pair [dict getdef $hir contexts installs {}] {
        lassign $pair c id
        dict set byRoot $c $id
    }
    set result [dict create]
    set so {}
    foreach r [dict get $hir roots] {
        dict set result $r $so
        if {[dict exists $byRoot $r]} {
            lappend so [dict get $byRoot $r]
        }
    }
    return $result
}

# grant, at top level: every context IDS of top-level inject block R names
# is available where R runs (AVAILABLE the context structs installed
# there): a context struct installed, a context trait implemented by
# exactly one installed context. (A call of the block's code needing one
# that is not installed is MISSING-CONTEXT's, never also
# CONTEXT-NOT-INJECTED: CheckCall.) Returns the identities that are not.
proc hir::injection::Available {hirVar r ids available} {
    upvar 1 $hirVar hir
    set unavailable {}
    foreach id $ids {
        if {![hir::contexts::isTrait $id]} {
            if {$id ni $available} {
                lappend unavailable $id
                hir::Diagnose hir MISSING-CONTEXT \
                    "$id is injected by this inject block but is not installed here (install it with \"with context EXPR\" before the block: an inject block grants a context that is already installed, it never installs one)" $r
            }
            continue
        }
        set providers [lmap w $available {
            if {[dict get [hir::contexts::satisfiesTrait $w $id] ok]} {set w} else {continue}
        }]
        if {[llength $providers] == 0} {
            lappend unavailable $id
            hir::Diagnose hir MISSING-CONTEXT \
                "$id is injected by this inject block, but no installed context implements it (install one with \"with context EXPR\" before the block)" $r
        } elseif {[llength $providers] > 1} {
            hir::Diagnose hir AMBIGUOUS-CONTEXT-IMPLEMENTATION \
                "$id is injected by this inject block, and more than one installed context implements it:\n[join [lmap w $providers {string cat "    " $w}] \n]\nno installed context is preferred over another: install exactly one context implementing $id where this block runs" $r
        }
    }
    return $unavailable
}

# The context identity binding B is the context parameter of -- a local
# bound to `context#load("ID")` (hir/contexts.tcl's DeclareParams) -- and its
# declaring bind expression, as {ID BIND}, or "".
proc hir::injection::ContextBinding {hir b} {
    if {$b eq "" || ![dict exists $hir bindings $b]} {
        return ""
    }
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] ne "local"} {
        return ""
    }
    set by [dict get $binding declaredBy]
    if {$by eq "" || ![dict exists $hir exprs $by] || [hir::kind $hir $by] ne "bind"} {
        return ""
    }
    set id [hir::contexts::loadId $hir [hir::get $hir $by value]]
    if {$id eq ""} {
        return ""
    }
    return [list $id $by]
}

# bindings: reference E in inject block R's code (INSIDE its subtree) to a
# context parameter declared outside R needs R to inject that context.
proc hir::injection::CheckBinding {hirVar r e inside} {
    upvar 1 $hirVar hir
    set found [ContextBinding $hir [hir::get $hir $e binding]]
    if {$found eq ""} {
        return
    }
    lassign $found id by
    if {[dict exists $inside $by] || $id in [injects $hir $r]} {
        return
    }
    set name [hir::semantic::RefName $hir $e]
    hir::Diagnose hir CONTEXT-NOT-INJECTED \
        "\"$name\" is the context parameter of [hir::contexts::BlockName $hir [OwnerBlock $hir $by]] for $id, which this inject block does not inject (it [What $hir $r]): code in an inject block uses only the contexts the block injects, never its creator's" $e
}

# The block whose body declares bind expression BY.
proc hir::injection::OwnerBlock {hir by} {
    return [dict get $hir scopes [dict get $hir exprs $by scope] invocation]
}

# calls: call C of inject block R's code (function O's; IDS what R injects;
# AVAILABLE the installed context structs at a top-level block) requires
# only injected contexts. Returns the identities it reported missing.
proc hir::injection::CheckCall {hirVar r c o ids available required reasons regionRoot graph captures inside} {
    upvar 1 $hirVar hir
    set targets {}
    foreach ctx [Contexts $hir $o $regionRoot $graph] {
        foreach t [hir::contexts::Targets $hir $graph $regionRoot $ctx $c] {
            if {$t ni $targets} {
                lappend targets $t
            }
        }
    }
    set reported {}
    hir::CheckingCall $c {
        foreach t $targets {
            if {![dict exists $required $t]} continue
            foreach id [dict get $required $t] {
                if {$id in $ids || $id in $reported} continue
                if {$o eq "" && ![Provided $id $available]} {
                    # Not installed where the call runs: its MISSING-CONTEXT
                    # (hir::contexts::Obligations) says so.
                    continue
                }
                lappend reported $id
                hir::Diagnose hir CONTEXT-NOT-INJECTED \
                    "$id is required by this call, but the enclosing inject block (at [Where $hir $r]) [What $hir $r]: a computation in an inject block uses only the contexts the block injects, whatever its creator can use:\n[join [hir::contexts::ChainLines $hir $t $id $reasons] \n]" $c
            }
            foreach use [dict getdef $captures $t {}] {
                lassign $use id by ref
                if {$id in $ids || $id in $reported || [dict exists $inside $ref] || [dict exists $inside $by]} continue
                lappend reported $id
                hir::Diagnose hir CONTEXT-NOT-INJECTED \
                    "$id is used by this call, but the enclosing inject block (at [Where $hir $r]) [What $hir $r]: [hir::contexts::NodeName $hir $t] reads \"[hir::semantic::RefName $hir $ref]\" (at [hir::originLocation $hir [dict get $hir exprs $ref origin]]), the context parameter of [hir::contexts::BlockName $hir [OwnerBlock $hir $by]] for $id" $c
            }
        }
    }
    return $reported
}

# 1 if context ID is available among the installed context structs
# AVAILABLE (a context trait: implemented by one of them).
proc hir::injection::Provided {id available} {
    if {![hir::contexts::isTrait $id]} {
        return [expr {$id in $available}]
    }
    foreach w $available {
        if {[dict get [hir::contexts::satisfiesTrait $w $id] ok]} {
            return 1
        }
    }
    return 0
}

# The requirement-graph contexts in which code of function O runs: "" (the
# program as written) and every specialization of the trait-polymorphic
# function whose region O is in (hir::contexts::Requirements).
proc hir::injection::Contexts {hir o regionRoot graph} {
    set result [list ""]
    if {$o eq ""} {
        return $result
    }
    set root [dict get $regionRoot $o]
    dict for {k info} [dict getdef $graph clones {}] {
        if {[dict get $info function] eq $root} {
            lappend result $k
        }
    }
    return $result
}

# The context parameters each requirement-graph node uses through a nested
# function's capture, transitively over EDGES: node -> {{ID BIND REF} ...},
# REF a reference in some function's code to the context parameter declared
# by BIND in another (an enclosing) function. A context parameter is the
# authority of the computation that receives it; a nested function that
# reads its enclosing function's uses it, which the requirement (its own
# loads) does not say.
proc hir::injection::Captures {hir owner nodes edges} {
    set own [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || ![dict get $node reachable]} continue
        set found [ContextBinding $hir [dict get $node binding]]
        if {$found eq ""} continue
        lassign $found id by
        set o [dict get $owner $e]
        if {$o eq "" || [OwnerBlock $hir $by] eq $o} continue
        dict lappend own $o [list $id $by $e]
    }
    set uses [dict create]
    foreach n $nodes {
        dict set uses $n [lsort -unique [dict getdef $own [lindex $n end] {}]]
    }
    if {[dict size $own] == 0} {
        return $uses
    }
    set changed 1
    while {$changed} {
        set changed 0
        foreach n $nodes {
            set have [dict get $uses $n]
            set next $have
            foreach edge [dict get $edges $n] {
                lassign $edge c target
                if {[dict exists $uses $target]} {
                    lappend next {*}[dict get $uses $target]
                }
            }
            set next [lsort -unique $next]
            if {$next ne $have} {
                dict set uses $n $next
                set changed 1
            }
        }
    }
    return $uses
}

# direct: a call of inject block R's code (function O's) to a designated
# direct module is mediated only by a context R injects (hir/direct.tcl's
# Discharge: the calling module's own context in the mediating function's
# section).
proc hir::injection::CheckDirect {hirVar r o ids inside innermost} {
    upvar 1 $hirVar hir
    if {![dict exists $hir moduleDecls] || [hir::mode $hir] ne "program"} {
        return
    }
    set decls [dict get $hir moduleDecls]
    set sections [dict create]
    if {[dict exists $hir modules]} {
        dict for {ns scope} [dict get $hir modules] {
            dict set sections $scope $ns
        }
    }
    set memo [dict create]
    set thunks [dict create]
    set create [core::coroutines::createNative]
    dict for {c node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call" && [hir::coroutines::NativeOf $hir $c] eq $create} {
            set thunk [lindex [dict get $node args] 0]
            if {$thunk ne "" && [hir::kind $hir $thunk] eq "block"} {
                dict set thunks $thunk $c
            }
        }
    }
    foreach c [dict keys $inside] {
        if {[dict get $innermost $c] ne $r || [hir::kind $hir $c] ne "call" || ![hir::get $hir $c reachable]} continue
        set b [hir::direct::Mediator $hir [hir::direct::Owner $hir $c] $thunks]
        if {$b ne $o} continue
        set node [dict get $hir exprs $c]
        set unit [hir::direct::UnitOfScope $hir [dict get $node scope] memo $sections]
        if {![dict exists $decls $unit] || [dict get $decls $unit direct]} {
            # (A direct module's own raw authority is acknowledged at its
            # boundary: no context mediates it.)
            continue
        }
        set targets [hir::direct::Targets $hir $c $node $unit memo $sections]
        if {$targets eq {}} continue
        lassign [hir::direct::Discharge $hir $b $unit] discharged
        if {$discharged eq ""} {
            # Unmediated: hir::direct::verify's DIRECT.
            continue
        }
        set mediating {}
        foreach record [dict get $hir exprs $b contextParams] {
            set id [dict get $record context]
            set ownerNs [if {[dict exists $record trait]} {hir::traits::owner $id} else {hir::structs::owner $id}]
            if {$ownerNs eq $unit} {
                lappend mediating $id
            }
        }
        set granted 0
        foreach id $mediating {
            if {$id in $ids} {
                set granted 1
            }
        }
        if {$granted} continue
        lassign [lindex $targets 0] d callee
        lassign $callee how what
        set name [if {$how eq "block"} {hir::contexts::BlockName $hir $what} else {core::native::displayName $what}]
        hir::Diagnose hir CONTEXT-NOT-INJECTED \
            "this call reaches $name of the direct module $d, whose authority [hir::contexts::BlockName $hir $b] mediates through its context [join $mediating { or }]; the enclosing inject block (at [Where $hir $r]) [What $hir $r], so nothing mediates the raw authority here (DIRECT-MODULES.md)" $c
    }
}

# ---------------------------------------------------------------------------
# Retained authority

# retained: call C of inject block R's code, which may resume coroutines of
# the origins PROVENANCE records for it, resumes only coroutines whose
# retained authority is within IDS. REJECTED: call -> the contexts its
# requirement check reported missing -- C's own (the same cause, said once)
# and a construction's, whose coroutine retains them (a dependent report).
proc hir::injection::CheckRetained {hirVar r c ids rejected provenance} {
    upvar 1 $hirVar hir
    set origins [dict getdef $provenance resumes $c {}]
    if {$origins eq {}} {
        return
    }
    set missing [dict getdef $rejected $c {}]
    set excess {}
    set unknown {}
    foreach origin $origins {
        switch -- [lindex $origin 0] {
            auth {
                set site [lindex $origin 2]
                set dependent [dict getdef $rejected $site {}]
                foreach id [lindex $origin 1] {
                    if {$id ni $ids && $id ni $missing && $id ni $dependent && $id ni $excess} {
                        lappend excess $id
                    }
                }
            }
            p {
                lassign $origin - block index
                set params [hir::get $hir $block params]
                set name [dict get $hir bindings [lindex $params $index] name]
                set text "parameter \"$name\" of [hir::contexts::BlockName $hir $block], which its caller constructed"
                if {$text ni $unknown} {
                    lappend unknown $text
                }
            }
            foreign {
                set text [ForeignText $origin]
                if {$text ni $unknown} {
                    lappend unknown $text
                }
            }
        }
    }
    if {$excess eq {} && $unknown eq {}} {
        return
    }
    set lines {}
    if {$excess ne {}} {
        lappend lines "it may resume a coroutine that retains [join [lsort $excess] {, }] (the contexts its construction provided)"
    }
    if {$unknown ne {}} {
        lappend lines "it may resume a coroutine whose retained authority cannot be proven: [join $unknown {; }]"
    }
    hir::CheckingCall $c {
        hir::Diagnose hir CONTEXT-RETAINED-AUTHORITY \
            "this call runs coroutine code with authority the enclosing inject block (at [Where $hir $r]) does not grant (it [What $hir $r]): [join $lines {; }]. A coroutine keeps the contexts it was constructed with, so resuming one runs its creator's authority: resume inside an inject block only coroutines constructed within the injected contexts" $c
    }
}

proc hir::injection::ForeignText {origin} {
    switch -- [lindex $origin 1] {
        context { return "one moved out of the installed context [lindex $origin 2], where any code using that context may have put it" }
        payload { return "one received in the payload of error [lindex $origin 2]" }
    }
    return "one of unknown construction"
}

# The provenance analysis (header, "Retained authority") of HIR (WALK
# hir::contexts::Walk's result, ANALYSIS hir::contexts::Requirements', GRAPH
# the selected implementation graph): {resumes CALL -> ORIGINS resume NODE ->
# ORIGINS out NODE -> ORIGINS bind BINDING -> ORIGINS}: the origins of the
# coroutines each call may resume, and the summaries and binding origins
# they come from.
proc hir::injection::Provenance {hir walk analysis graph} {
    lassign $walk owner parent rootOf calls fns
    set state [dict create bind [dict create] resume [dict create] out [dict create] \
        calls [dict create] changed 1 hir $hir graph $graph \
        regionRoot [dict get $analysis regionRoot] required [dict get $analysis required]]
    set nodes [concat [list ""] [dict get $analysis nodes]]
    set rounds 0
    while {[dict get $state changed]} {
        dict set state changed 0
        dict set state calls [dict create]
        incr rounds
        if {$rounds > 200} {
            error "hir::injection::Provenance: the provenance analysis does not settle"
        }
        foreach n $nodes {
            NodeFlow state $n
        }
    }
    return [dict create resumes [dict get $state calls] resume [dict get $state resume] \
        out [dict get $state out] bind [dict get $state bind]]
}

# One evaluation of requirement-graph node N's code ("" the top level).
proc hir::injection::NodeFlow {stateVar n} {
    upvar 1 $stateVar state
    set hir [dict get $state hir]
    if {$n eq ""} {
        set body [dict get $hir roots]
        set ctx ""
        set block ""
    } else {
        set block [lindex $n end]
        set ctx [if {[llength $n] == 2} {lindex $n 0} else {string cat ""}]
        set body [hir::get $hir $block body]
    }
    dict set state node $n
    dict set state ctx $ctx
    set result [Seq state $body]
    if {$n eq ""} {
        return
    }
    set out $result
    foreach b [hir::get $hir $block params] {
        # What the function moved into its place parameters leaves it too.
        lappend out {*}[dict getdef $state bind $b {}]
    }
    Grow state out $n $out
}

# Adds ORIGINS to state table TABLE's entry KEY, noting a change.
proc hir::injection::Grow {stateVar table key origins} {
    upvar 1 $stateVar state
    if {$origins eq {}} {
        return
    }
    set have [dict getdef $state $table $key {}]
    set next [lsort -unique [concat $have $origins]]
    if {$next ne $have} {
        dict set state $table $key $next
        dict set state changed 1
    }
}

# The origins of the last of the statements BODY (each evaluated).
proc hir::injection::Seq {stateVar body} {
    upvar 1 $stateVar state
    set result {}
    foreach e $body {
        set result [Tau state $e]
    }
    return $result
}

# 1 if a value of TYPE cannot hold a coroutine handle: a definite type
# that is not affine. `any` and an unknown type might, and so might a
# structural function type: an untyped parameter of a generic function is
# typed by its uses in the program as written -- `any`, or the Fn contract
# its calls prove -- and the monomorphization specializes the function for
# a coroutine argument (AFFINE-VALUES.md: Fn and Coroutine share one
# callable contract). A trait view is its witness's.
proc hir::injection::HandleFree {type} {
    if {$type in {"" any poison}} {
        return 0
    }
    if {[hir::types::IsAffine $type] || [hir::types::IsTrait $type] || [hir::types::IsFn $type]} {
        return 0
    }
    if {$type eq "never" || [hir::types::IsImprint $type]} {
        return 1
    }
    return [expr {[hir::types::kindOf $type] ni {"" any}}]
}

# The origins of the value of expression E (code of the node being
# evaluated), its sub-expressions evaluated for what they bind and resume.
proc hir::injection::Tau {stateVar e} {
    upvar 1 $stateVar state
    set hir [dict get $state hir]
    set node [dict get $hir exprs $e]
    set result {}
    switch -- [dict get $node kind] {
        const - block - continue {
            # (A function literal is its own node: never evaluated here.)
            return {}
        }
        ref {
            set b [dict get $node binding]
            if {$b eq "" || ![dict exists $hir bindings $b]} {
                return {}
            }
            set binding [dict get $hir bindings $b]
            switch -- [dict get $binding kind] {
                root - ambient { return {} }
            }
            set found [ContextBinding $hir $b]
            if {$found ne "" && [hir::contexts::isTrait [lindex $found 0]]} {
                # A context-trait binding is no value: it holds nothing.
                return {}
            }
            set result [dict getdef $state bind $b {}]
            if {[dict get $binding kind] eq "param"} {
                set index [ParamIndex $hir $b]
                if {$index ne ""} {
                    lappend result [list p {*}$index]
                }
            }
        }
        bind {
            set value [Tau state [dict get $node value]]
            Grow state bind [dict get $node binding] $value
            return {}
        }
        call {
            set result [Call state $e $node]
        }
        if {
            Tau state [dict get $node condition]
            set result [concat [Seq state [dict get $node thenBody]] [Seq state [dict get $node elseBody]]]
        }
        loop - listloop - countloop - lockloop {
            set operands {}
            foreach c [hir::children $hir $e] {
                if {$c ni [dict get $node body]} {
                    lappend operands {*}[Tau state $c]
                }
            }
            set last [Seq state [dict get $node body]]
            foreach field {elementBinding countBinding} {
                if {[dict exists $node $field] && [dict get $node $field] ne ""} {
                    Grow state bind [dict get $node $field] $operands
                }
            }
            if {[dict exists $node domains]} {
                foreach domain [dict get $node domains] {
                    if {[dict exists $domain binding]} {
                        Grow state bind [dict get $domain binding] $operands
                    }
                }
            }
            if {[dict exists $node foldBinding] && [dict get $node foldBinding] ne ""} {
                Grow state bind [dict get $node foldBinding] [concat $operands $last]
                lappend last {*}[dict getdef $state bind [dict get $node foldBinding] {}]
            }
            set result [concat $last $operands]
        }
        handle {
            set result [Tau state [dict get $node call]]
            foreach b [dict get $node handlerPayloads] name [dict get $node handlerNames] body [dict get $node handlerBodies] {
                if {$b ne ""} {
                    Grow state bind $b [list [list foreign payload $name]]
                }
                lappend result {*}[Seq state $body]
            }
        }
        return {
            if {[dict get $node value] ne ""} {
                set n [dict get $state node]
                if {$n ne ""} {
                    Grow state out $n [Tau state [dict get $node value]]
                } else {
                    Tau state [dict get $node value]
                }
            }
            return {}
        }
        default {
            foreach c [hir::children $hir $e] {
                lappend result {*}[Tau state $c]
            }
        }
    }
    if {$result eq {} || [HandleFree [hir::typeOf $hir $e]]} {
        return {}
    }
    return [lsort -unique $result]
}

# {BLOCK INDEX} when parameter binding B is the INDEX-th ordinary parameter
# of function BLOCK, else "".
proc hir::injection::ParamIndex {hir b} {
    set scope [dict get $hir bindings $b scope]
    set block [dict get $hir scopes $scope invocation]
    if {$block eq "" || ![dict exists $hir exprs $block] || [hir::kind $hir $block] ne "block"} {
        return ""
    }
    set index [lsearch -exact [hir::get $hir $block params] $b]
    if {$index < 0} {
        return ""
    }
    return [list $block $index]
}

# The binding a place argument A writes through -- a reference, or a
# projection chain from one -- or "".
proc hir::injection::PlaceRoot {hir a} {
    while {[hir::kind $hir $a] eq "project"} {
        set a [hir::get $hir $a receiver]
    }
    if {[hir::kind $hir $a] ne "ref"} {
        return ""
    }
    return [hir::get $hir $a binding]
}

# The origins of call E's value (NODE its expression), recording the origins
# of what it may resume.
proc hir::injection::Call {stateVar e node} {
    upvar 1 $stateVar state
    set hir [dict get $state hir]
    set native [hir::contexts::NativeCallee $hir $e]
    set args [dict get $node args]
    if {$native eq [hir::contexts::LoadNative]} {
        # An installed context's state: whatever anyone using the context
        # put there.
        return [list [list foreign context [hir::contexts::loadId $hir $e]]]
    }
    set argOrigins {}
    foreach a $args {
        lappend argOrigins [Tau state $a]
    }
    set all [concat {*}$argOrigins]
    set resumes {}
    set result {}
    set targets [hir::contexts::Targets $hir [dict get $state graph] [dict get $state regionRoot] \
        [dict get $state ctx] $e]
    if {$native eq [core::coroutines::createNative]} {
        # A construction: the handle carries what its code needs -- its
        # thunk's requirement -- and what its code resumes; its eager first
        # segment resumes that much right here.
        foreach t $targets {
            set inner [dict getdef $state resume $t {}]
            lappend resumes {*}$inner
            lappend result [list auth [dict getdef $state required $t {}] $e] {*}$inner
        }
    } elseif {$targets ne {}} {
        # A call of functions (a native whose executable body is a module
        # function included): their summaries, their parameters' origins
        # the arguments'. What they move into a place parameter is the
        # caller's place's.
        foreach t $targets {
            set block [lindex $t end]
            lappend resumes {*}[Subst $block [dict getdef $state resume $t {}] $argOrigins]
            lappend result {*}[Subst $block [dict getdef $state out $t {}] $argOrigins]
            set moved [concat $all $result]
            foreach index [dict getdef $hir exprs $block places {}] {
                set b [PlaceRoot $hir [lindex $args $index]]
                if {$b ne "" && $moved ne {}} {
                    Grow state bind $b $moved
                }
            }
        }
    } elseif {$native eq [core::coroutines::resumeNative]} {
        # A resume of a handle binding (hir/resolve.tcl's CoroutineResume):
        # it runs the handle's coroutine code. (Its message and its result
        # are unrestricted: COROUTINE-CONTRACT.)
        set resumes $all
    } elseif {$native ne ""} {
        # Any other native: its value is made of its arguments; it runs no
        # coroutine (a native's callable arguments are function values, and
        # it passes them no handle). A collection mutation moves its other
        # arguments into its receiver's place.
        set result $all
        if {[hir::mutvec::OpKind $hir $e] eq "mutate" && $all ne {} && $args ne {}} {
            set b [PlaceRoot $hir [lindex $args 0]]
            if {$b ne ""} {
                Grow state bind $b $all
            }
        }
    } else {
        # A call through a value -- a coroutine handle (a resume), a
        # function value, a context-trait operation, a trait operation the
        # graph binds nothing to -- may resume the callee and whatever it is
        # passed.
        set calleeOrigins [Tau state [dict get $node callee]]
        set resumes [concat $calleeOrigins $all]
        set result $all
    }
    if {$resumes ne {}} {
        set resumes [lsort -unique $resumes]
        set n [dict get $state node]
        if {$n ne ""} {
            Grow state resume $n $resumes
        }
        set have [dict getdef $state calls $e {}]
        dict set state calls $e [lsort -unique [concat $have $resumes]]
    }
    return $result
}

# ORIGINS of a summary of function BLOCK with its parameters' origins
# replaced by the call's ARGORIGINS (a list, positional).
proc hir::injection::Subst {block origins argOrigins} {
    set result {}
    foreach origin $origins {
        if {[lindex $origin 0] eq "p" && [lindex $origin 1] eq $block} {
            set index [lindex $origin 2]
            if {$index < [llength $argOrigins]} {
                lappend result {*}[lindex $argOrigins $index]
            } else {
                lappend result [list foreign unknown]
            }
            continue
        }
        lappend result $origin
    }
    return $result
}

# ---------------------------------------------------------------------------
# Tooling

# The inject blocks of HIR for hir::contexts::summary (-contexts):
#   contextinject eN (IDS)
proc hir::injection::summary {hir} {
    set source [dict getdef $hir traitSource $hir]
    return [lmap r [Blocks $source] {
        string cat "contextinject $r ([join [injects $source $r] {, }])"
    }]
}
