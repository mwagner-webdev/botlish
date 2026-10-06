# contexts.tcl -- static execution-environment contexts (CONTEXTS.md).
#
# A context is an ordinary Botlish value of a struct type declared
#
#     context struct T:            (or `opaque context struct T:`)
#
# which may be installed into the current execution environment and may
# satisfy a function's context dependency. Nothing else: `context` is a
# property of the struct declaration (hir/structs.tcl's `isContext`),
# independent of opacity, and implies no mutability, lifetime, reference
# semantics or privilege.
#
# A context is identified by the canonical identity of its context-struct type
# (the struct declaration identity, e.g. "linux::io::LinuxIO"), and nothing
# else: no name, qualifier, string key or registration id. There is at most one
# installed value per type.
#
# Three source forms, and the two explicit HIR operations they become
# (internal root natives, core/contexts.tcl):
#
#   with context EXPR             call ^context#install EXPR          (an install)
#                                 entry program, top level only
#   fn f(x, context io: T): ...   bind io (call ^context#load "T")    (a load)
#                                 at the start of f's body: `io` is an
#                                 ordinary immutable local; f's call arity
#                                 and parameters are unchanged
#
# A call never mentions a context: `f(x)` calls the f above. What a function
# needs is computed here, from the call graph:
#
#   direct(B)     the context types block B's own region loads (its context
#                 parameters; nested blocks are their own regions)
#   required(B)   direct(B) united with required(E) for every block E that B's
#                 region calls -- the transitive requirement, a least fixed
#                 point (recursive and mutually recursive groups converge)
#
# Only `direct` is written in source; an intermediate function that merely
# calls something needing a context repeats nothing. `reason` keeps, for every
# (B, T) of required(B), why: `direct`, or the first call (breadth-first, so
# the shortest chain, in source order) through which T arrived -- the chain a
# MISSING-CONTEXT diagnostic prints, and what tooling can ask ("why does f
# require T?").
#
# Verification walks the program's top-level code in evaluation order (module
# sections first, then the entry program), tracking the installed set: every
# call there must find required(callee) installed (MISSING-CONTEXT, with the
# chain); `with context EXPR` evaluates EXPR against the set installed so far
# and then adds EXPR's type, which must be exactly one context struct
# (NOT-A-CONTEXT, CONTEXT-TYPE-NOT-EXACT) not yet installed (DUPLICATE-CONTEXT).
# A context is therefore available from its `with context` line onward, never
# earlier, and never to its own constructor. Unreachable code and functions
# that are never called require nothing.
#
# Calls the call graph cannot see. Every call edge used here is exact by
# construction: the callee is a block literal, or a reference to an immutable
# binding that denotes one (a function, an alias of one, a module function), or
# a native whose executable body is a module function. A function value that
# could reach an unknown call -- a parameter, a struct field, a list element --
# would hide its requirement, so a function whose requirement is not empty may
# not become a value at all: a reference to it (or its literal) may only be
# called or bound to another name in statement position, and anything else is
# CONTEXT-FUNCTION-VALUE. Every indirect call therefore calls only context-free
# functions, and needs nothing. (This is the first milestone's frontier: no
# context effects in function types.)
#
# Where an install may be written: the entry program's top-level scope, as a
# statement (CONTEXT-INSTALLATION-UNSUPPORTED anywhere else: a function, a loop,
# a branch, a handler, a module, an expression).
#
# What HIR keeps, after hir::check:
#   block expr   contextParams    {{name NAME context ID} ...} as declared
#                                 (set by resolution)
#                directContexts   sorted context identities (the region's loads)
#                requiredContexts sorted context identities (transitive)
#   hir          contexts         {blocks BLOCKS installs INSTALLS reasons
#                                 REASONS}: BLOCKS the analysed blocks, INSTALLS
#                                 {CALLEXPR ID} in program order, REASONS
#                                 block -> ID -> direct | {call CALLEXPR CALLEE}
# (hir::contexts::explain and ::of read them back).

namespace eval hir::contexts {}

proc hir::contexts::LoadNative {} { return [core::contexts::loadNative] }
proc hir::contexts::InstallNative {} { return [core::contexts::installNative] }

# ---------------------------------------------------------------------------
# Resolution (called by hir/resolve.tcl's block case)

# The syntax bind nodes that establish the context parameters of block syntax
# NODE (resolved as ExprId E in module namespace NS), to be resolved first in
# its body: one `bind NAME (call ^context#load "ID")` per valid entry, in
# written order, ID the canonical identity of the declared context type.
# Records the block's `contextParams`. Diagnoses, at the entry's own spelling:
#   CONTEXT-BINDING-COLLISION   NAME is an ordinary parameter or a flag of the
#                               block, or a second context parameter's name
#   TYPE                        the type does not resolve
#   NOT-A-CONTEXT               the type is not a `context struct`
#   DUPLICATE-CONTEXT-PARAMETER the same context type twice (one type, one
#                               value: the local names do not matter)
# BODYSCOPE already holds the parameter and flag bindings.
proc hir::contexts::DeclareParams {hirVar e node bodyScope ns} {
    upvar 1 $hirVar hir
    if {![dict exists $node contextParams]} {
        return {}
    }
    set binds {}
    set records {}
    set seenNames [dict create]
    set seenTypes [dict create]
    foreach entry [dict get $node contextParams] {
        lassign $entry name origin typeExpr typeOrigin
        if {[dict exists $hir scopes $bodyScope names $name] || [dict exists $seenNames $name]} {
            set what [expr {[dict exists $seenNames $name] ? "another context parameter"
                : "a parameter or flag of the same function"}]
            hir::DiagnoseAt hir CONTEXT-BINDING-COLLISION \
                "context parameter \"$name\" has the name of $what: context parameters are ordinary locals of the function and share its one namespace" \
                $e $origin
            continue
        }
        dict set seenNames $name 1
        if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} type]} {
            hir::DiagnoseAt hir TYPE \
                [format {unknown or invalid type %s for context parameter "%s": %s} \
                    [hir::resolve::ShowTypeExpr $typeExpr] $name $type] $e $typeOrigin
            set id ""
        } elseif {[lindex $type 0] ne "nstruct" || ![hir::structs::isContext [lindex $type 1]]} {
            hir::DiagnoseAt hir NOT-A-CONTEXT \
                [format {context parameter "%s": %s is not a context (only a value of a type declared "context struct" can be a context)} \
                    $name [hir::types::show $type]] $e $typeOrigin
            set id ""
        } else {
            set id [lindex $type 1]
            if {[dict exists $seenTypes $id]} {
                hir::DiagnoseAt hir DUPLICATE-CONTEXT-PARAMETER \
                    [format {context %s is declared twice (as "%s" and "%s"): a function receives at most one value of each context type, whatever the local names} \
                        $id [dict get $seenTypes $id] $name] $e $typeOrigin
                continue
            }
            dict set seenTypes $id $name
        }
        lappend records [dict create name $name context $id]
        lappend binds [hir::syntax::bindNode $origin $name \
            [hir::syntax::callNode $origin [hir::syntax::rootRef $origin [LoadNative]] \
                [hir::syntax::constNode $origin str $id]]]
    }
    dict set hir exprs $e contextParams $records
    return $binds
}

# ---------------------------------------------------------------------------
# Queries

# The native name call E (of HIR) calls through a root reference, or "".
proc hir::contexts::NativeCallee {hir e} {
    if {[hir::kind $hir $e] ne "call"} {
        return ""
    }
    set callee [hir::get $hir $e callee]
    if {[hir::kind $hir $callee] ne "ref"} {
        return ""
    }
    set b [hir::get $hir $callee binding]
    if {$b eq "" || [dict get $hir bindings $b kind] ne "root"} {
        return ""
    }
    return [dict get $hir bindings $b name]
}

# 1 if E is a context load (`context#load("ID")`).
proc hir::contexts::isLoad {hir e} {
    return [expr {[NativeCallee $hir $e] eq [LoadNative]}]
}

# 1 if E is a context installation (`context#install(VALUE)`).
proc hir::contexts::isInstall {hir e} {
    return [expr {[NativeCallee $hir $e] eq [InstallNative]}]
}

# The context identity context load E reads ("" when it is not a load or its
# key is not a literal).
proc hir::contexts::loadId {hir e} {
    if {![isLoad $hir $e]} {
        return ""
    }
    set args [hir::get $hir $e args]
    if {[llength $args] != 1 || [hir::kind $hir [lindex $args 0]] ne "const"} {
        return ""
    }
    return [lindex [hir::get $hir [lindex $args 0] literal] end]
}

# The context identity installation E installs, as verification decided it
# ("" when unknown).
proc hir::contexts::installId {hir e} {
    if {[dict exists $hir exprs $e context]} {
        return [dict get $hir exprs $e context]
    }
    return ""
}

# The sorted direct / required context identities of block E ({} if none or
# not analysed).
proc hir::contexts::direct {hir e} {
    if {[dict exists $hir exprs $e directContexts]} {
        return [dict get $hir exprs $e directContexts]
    }
    return {}
}

proc hir::contexts::required {hir e} {
    if {[dict exists $hir exprs $e requiredContexts]} {
        return [dict get $hir exprs $e requiredContexts]
    }
    return {}
}

# The block ExprId binding B denotes -- the function it is bound to, through
# aliases (`g = f`) -- or "". Bindings are immutable, so a call through B
# always calls that block.
proc hir::contexts::Denotes {hir b {seen {}}} {
    if {$b eq "" || $b in $seen || ![dict exists $hir bindings $b]} {
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
    set value [hir::get $hir $by value]
    switch -- [hir::kind $hir $value] {
        block { return $value }
        ref   { return [Denotes $hir [hir::get $hir $value binding] [concat $seen [list $b]]] }
    }
    return ""
}

# The block a call E calls, statically and exactly, or "".
proc hir::contexts::Callee {hir e} {
    set callee [hir::get $hir $e callee]
    switch -- [hir::kind $hir $callee] {
        block { return $callee }
        ref   { return [Denotes $hir [hir::get $hir $callee binding]] }
    }
    lassign [hir::get $hir $e target] kind target
    if {$kind eq "block"} {
        return $target
    }
    return ""
}

# The display name of block E: the name of the function it is bound to, as
# written (a module function qualified), or "the function at LOCATION".
proc hir::contexts::BlockName {hir e} {
    foreach {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] ne "local"} continue
        set by [dict get $binding declaredBy]
        if {$by ne "" && [dict exists $hir exprs $by] && [hir::kind $hir $by] eq "bind"
                && [hir::get $hir $by value] eq $e} {
            if {[dict exists $binding spelling] && ![hir::isModuleBinding $hir $b]} {
                return [dict get $binding spelling]
            }
            return [dict get $binding name]
        }
    }
    return "the function at [hir::originLocation $hir [hir::get $hir $e origin]]"
}

# ---------------------------------------------------------------------------
# Regions and parents

# One walk over HIR: {OWNER PARENT ROOTOF CALLS BLOCKS}. OWNER maps every
# ExprId to its innermost enclosing block ("" at top level); PARENT maps it to
# {PARENT-EXPR ROLE} where ROLE is `seq LAST` for an element of a body or of the
# program roots (LAST 1 for the final one), `callee`, or `operand`; ROOTOF maps
# a top-level ExprId (owner "") to the root it belongs to. CALLS maps an owner
# ("" for the top level) to its region's call ExprIds in pre-order; BLOCKS lists
# every block in pre-order.
proc hir::contexts::Walk {hir} {
    set owner [dict create]
    set parent [dict create]
    set rootOf [dict create]
    set calls [dict create]
    set blocks {}
    set roots [dict get $hir roots]
    set n [llength $roots]
    set i 0
    set stack {}
    foreach r $roots {
        incr i
        dict set parent $r [list "" [list seq [expr {$i == $n}]]]
        lappend stack [list $r "" $r]
    }
    set stack [lreverse $stack]
    while {$stack ne ""} {
        lassign [lindex $stack end] e o root
        set stack [lrange $stack 0 end-1]
        dict set owner $e $o
        if {$o eq ""} {
            dict set rootOf $e $root
        }
        set node [dict get $hir exprs $e]
        set kind [dict get $node kind]
        if {$kind eq "call"} {
            dict lappend calls $o $e
        }
        set inner $o
        if {$kind eq "block"} {
            lappend blocks $e
            set inner $e
        }
        set children {}
        switch -- $kind {
            block {
                foreach body [list [dict get $node body]] {
                    set m [llength $body]
                    set j 0
                    foreach c $body {
                        incr j
                        lappend children [list $c [list seq [expr {$j == $m}]]]
                    }
                }
            }
            if {
                lappend children [list [dict get $node condition] operand]
                foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
                    set m [llength $body]
                    set j 0
                    foreach c $body {
                        incr j
                        lappend children [list $c [list seq [expr {$j == $m}]]]
                    }
                }
            }
            loop - listloop - countloop - lockloop {
                foreach c [hir::children $hir $e] {
                    if {$c in [dict get $node body]} {
                        # A loop body's last value may be collected
                        # (COLLECTING-LOOPS.md): observed.
                        lappend children [list $c [list seq [expr {$c eq [lindex [dict get $node body] end]}]]]
                    } else {
                        lappend children [list $c operand]
                    }
                }
            }
            handle {
                lappend children [list [dict get $node call] operand]
                foreach body [dict get $node handlerBodies] {
                    set m [llength $body]
                    set j 0
                    foreach c $body {
                        incr j
                        lappend children [list $c [list seq [expr {$j == $m}]]]
                    }
                }
            }
            call {
                lappend children [list [dict get $node callee] callee]
                foreach a [dict get $node args] {
                    lappend children [list $a operand]
                }
            }
            default {
                foreach c [hir::children $hir $e] {
                    lappend children [list $c operand]
                }
            }
        }
        set push {}
        foreach pair $children {
            lassign $pair c role
            dict set parent $c [list $e $role]
            lappend push [list $c $inner $root]
        }
        lappend stack {*}[lreverse $push]
    }
    return [list $owner $parent $rootOf $calls $blocks]
}

# 1 if the value of expression E (a reference to, or the literal of, a
# function) is used as a value: anything but the callee of a call, a
# statement whose value is discarded (a non-final statement of a body), or the
# whole value of a binding that is itself such a statement (`g = f`, `fn
# f(): ...`: the new binding denotes the same function, and its own uses are
# checked the same way). Deliberately syntactic: a function that flows
# through an `if`, a block's or the program's final statement (its result), a
# loop body's final statement (an iteration value), an argument, a field or a
# list is a value.
proc hir::contexts::Observed {hir parent e} {
    lassign [dict get $parent $e] p role
    if {$role eq "callee"} {
        return 0
    }
    if {$role eq "seq 0"} {
        return 0
    }
    if {$p ne "" && $role eq "operand" && [hir::kind $hir $p] eq "bind"} {
        return [expr {[lindex [dict get $parent $p] 1] ne "seq 0"}]
    }
    return 1
}

# ---------------------------------------------------------------------------
# Verification (hir::check)

proc hir::contexts::verify {hirVar} {
    upvar 1 $hirVar hir
    lassign [Walk $hir] owner parent rootOf calls blocks
    # Direct requirements and call edges per block region.
    set direct [dict create]
    set edges [dict create]
    foreach b $blocks {
        dict set direct $b {}
        dict set edges $b {}
    }
    dict for {o list} $calls {
        foreach c $list {
            if {![hir::get $hir $c reachable]} {
                continue
            }
            if {[isLoad $hir $c]} {
                if {$o ne ""} {
                    set id [loadId $hir $c]
                    if {$id ne "" && $id ni [dict get $direct $o]} {
                        dict lappend direct $o $id
                    }
                }
                continue
            }
            if {$o eq ""} {
                continue
            }
            set target [Callee $hir $c]
            if {$target ne ""} {
                dict lappend edges $o [list $c $target]
            }
        }
    }
    # The transitive requirement: breadth-first rounds over the previous
    # round's sets, so each reason is a shortest chain and the result is the
    # least fixed point (a recursive group converges).
    set required [dict create]
    set reasons [dict create]
    foreach b $blocks {
        dict set required $b [lsort [dict get $direct $b]]
        foreach id [dict get $direct $b] {
            dict set reasons $b $id direct
        }
    }
    set changed 1
    while {$changed} {
        set changed 0
        set previous $required
        foreach b $blocks {
            foreach edge [dict get $edges $b] {
                lassign $edge c target
                if {![dict exists $previous $target]} continue
                foreach id [dict get $previous $target] {
                    if {$id ni [dict get $required $b]} {
                        dict set required $b [lsort [concat [dict get $required $b] [list $id]]]
                        dict set reasons $b $id [list call $c $target]
                        set changed 1
                    }
                }
            }
        }
    }
    foreach b $blocks {
        dict set hir exprs $b directContexts [lsort [dict get $direct $b]]
        dict set hir exprs $b requiredContexts [dict get $required $b]
    }
    # No function that needs a context may become a value.
    CheckValues hir $parent $required
    # Top-level code, in evaluation order.
    set installed {}
    set installs {}
    set topCalls [expr {[dict exists $calls ""] ? [dict get $calls ""] : {}}]
    # The calls of each root's region, in pre-order.
    set callsOfRoot [dict create]
    foreach c $topCalls {
        dict lappend callsOfRoot [dict get $rootOf $c] $c
    }
    set top [dict get $hir top]
    foreach c [concat {*}[dict values $calls]] {
        if {[isInstall $hir $c] && [dict get $owner $c] ne ""} {
            Unsupported hir $c [Where $hir $c [dict get $owner $c]]
        }
    }
    foreach r [dict get $hir roots] {
        if {![dict exists $callsOfRoot $r]} continue
        set pending {}
        foreach c [dict get $callsOfRoot $r] {
            if {![hir::get $hir $c reachable]} continue
            if {[isInstall $hir $c]} {
                if {$c ne $r || [hir::get $hir $c scope] ne $top || [hir::mode $hir] ne "program"} {
                    Unsupported hir $c [Where $hir $c ""]
                } else {
                    set pending $c
                }
                continue
            }
            if {[isLoad $hir $c]} continue
            set target [Callee $hir $c]
            if {$target eq "" || ![dict exists $required $target]} continue
            foreach id [dict get $required $target] {
                if {$id ni $installed} {
                    Missing hir $c $target $id $reasons
                }
            }
        }
        if {$pending ne ""} {
            # The installed value's own calls (the rest of this root) were
            # checked above against the set installed so far: a context is
            # not visible to its own constructor. Now its type.
            set id [InstalledType hir $pending $installed]
            if {$id ne ""} {
                lappend installed $id
                lappend installs [list $pending $id]
                dict set hir exprs $pending context $id
            }
        }
    }
    dict set hir contexts [dict create blocks $blocks installs $installs reasons $reasons]
}

# Every reference to (or literal of) a function whose requirement is not
# empty must be a call or an alias binding in statement position.
proc hir::contexts::CheckValues {hirVar parent required} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        set kind [dict get $node kind]
        if {$kind eq "ref"} {
            set target [Denotes $hir [dict get $node binding]]
        } elseif {$kind eq "block"} {
            set target $e
        } else {
            continue
        }
        if {$target eq "" || ![dict exists $required $target] || [dict get $required $target] eq {}} {
            continue
        }
        if {![dict exists $parent $e] || ![Observed $hir $parent $e]} {
            continue
        }
        set name [BlockName $hir $target]
        hir::Diagnose hir CONTEXT-FUNCTION-VALUE \
            [::format {function %s requires context %s, so it can only be called (or bound to another name as a statement): it cannot be passed, returned or stored as a value, because a call through an unknown function value could not prove that context installed} \
                $name [join [dict get $required $target] {, }]] $e
    }
}

# Where installation C (owner block OWNER, "" at top level) is, for the
# CONTEXT-INSTALLATION-UNSUPPORTED message.
proc hir::contexts::Where {hir c owner} {
    if {$owner ne ""} {
        return "inside a function"
    }
    if {[hir::mode $hir] ne "program"} {
        return "in a host environment sequence"
    }
    set s [hir::get $hir $c scope]
    if {[hir::isModuleScope $hir $s]} {
        return "inside a module"
    }
    switch -- [dict get $hir scopes $s kind] {
        branch { return "inside an if branch or error handler" }
        loop   { return "inside a loop" }
    }
    return "inside an expression"
}

proc hir::contexts::Unsupported {hirVar c where} {
    upvar 1 $hirVar hir
    hir::Diagnose hir CONTEXT-INSTALLATION-UNSUPPORTED \
        "context installation is currently supported only in the entry program's top-level scope, as a statement (this one is $where)" $c
}

# The context identity installation C installs, after checking it against the
# INSTALLED set ("" if it is rejected).
proc hir::contexts::InstalledType {hirVar c installed} {
    upvar 1 $hirVar hir
    set arg [lindex [hir::get $hir $c args] 0]
    set type [hir::typeOf $hir $arg]
    if {$type eq "never"} {
        # The value never completes: nothing is installed.
        return ""
    }
    if {[lindex $type 0] eq "nstruct"} {
        set id [lindex $type 1]
        if {![hir::structs::isContext $id]} {
            hir::Diagnose hir NOT-A-CONTEXT \
                "with context: $id is not a context (only a value of a type declared \"context struct\" can be installed)" $c
            return ""
        }
        if {$id in $installed} {
            hir::Diagnose hir DUPLICATE-CONTEXT "$id is already installed in this scope" $c
            return ""
        }
        return $id
    }
    set kind [hir::types::kindOf $type]
    if {$kind ne "" && $kind ne "struct"} {
        hir::Diagnose hir NOT-A-CONTEXT \
            "with context: a value of type [hir::types::show $type] is not a context (only a value of a type declared \"context struct\" can be installed)" $c
        return ""
    }
    hir::Diagnose hir CONTEXT-TYPE-NOT-EXACT \
        "with context: the installed value must have one exact context-struct type, but its type is [hir::types::show $type]" $c
    return ""
}

# Diagnoses top-level call C of block TARGET, which requires context ID that
# is not installed, with the chain that requires it.
proc hir::contexts::Missing {hirVar c target id reasons} {
    upvar 1 $hirVar hir
    hir::Diagnose hir MISSING-CONTEXT \
        "$id is required by this call but is not installed here (install it with \"with context EXPR\" before the call):\n[Chain $hir $target $id $reasons]" $c
}

# The requirement chain of context ID from block B, one line per function:
#
#     a
#      -> b
#      -> linux::io::write
#         directly requires linux::io::LinuxIO
proc hir::contexts::Chain {hir b id reasons} {
    set lines {}
    set seen {}
    set first 1
    while {$b ne "" && $b ni $seen} {
        lappend seen $b
        lappend lines [expr {$first ? "    [BlockName $hir $b]" : "     -> [BlockName $hir $b]"}]
        set first 0
        set reason [dict get $reasons $b $id]
        if {$reason eq "direct"} {
            lappend lines "        directly requires $id"
            break
        }
        set b [lindex $reason 2]
    }
    return [join $lines \n]
}

# ---------------------------------------------------------------------------
# Tooling

# The requirement record of block E: {direct IDS required IDS}.
proc hir::contexts::of {hir e} {
    return [dict create direct [direct $hir $e] required [required $hir $e]]
}

# Why block E requires context ID: its chain, as MISSING-CONTEXT prints it, or
# "" when it does not.
proc hir::contexts::explain {hir e id} {
    if {![dict exists $hir contexts reasons $e $id]} {
        return ""
    }
    return [Chain $hir $e $id [dict get $hir contexts reasons]]
}

# A text summary of the program's contexts (hir::contexts::summary), for -contexts and audits:
#
#   contextstruct ID [opaque]
#   contextinstall eN ID
#   contextparam eB NAME ID
#   function NAME eB direct-contexts (IDS) required-contexts (IDS)
#
# (functions with an empty requirement are omitted).
proc hir::contexts::summary {hir} {
    set lines {}
    foreach entry [hir::sourceTypes $hir] {
        if {[dict exists $entry kind] && [dict get $entry kind] eq "struct"
                && [dict exists $entry context] && [dict get $entry context]} {
            lappend lines "contextstruct [dict get $entry id][expr {[dict get $entry opaque] ? " opaque" : ""}]"
        }
    }
    if {![dict exists $hir contexts]} {
        return [join $lines \n]
    }
    foreach pair [dict get $hir contexts installs] {
        lassign $pair c id
        lappend lines "contextinstall $c $id"
    }
    foreach b [dict get $hir contexts blocks] {
        if {[dict exists $hir exprs $b contextParams]} {
            foreach record [dict get $hir exprs $b contextParams] {
                lappend lines "contextparam $b [dict get $record name] [dict get $record context]"
            }
        }
    }
    foreach b [dict get $hir contexts blocks] {
        if {[required $hir $b] eq {}} continue
        lappend lines "function [BlockName $hir $b] $b direct-contexts ([join [direct $hir $b] {, }]) required-contexts ([join [required $hir $b] {, }])"
    }
    return [join $lines \n]
}
