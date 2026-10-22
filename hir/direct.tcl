# direct.tcl -- direct modules and their mediation by module-owned contexts
# (DIRECT-MODULES.md).
#
#   hir::direct::verify HIRVAR       the module directness check, part of
#                                    hir::CheckOnce (after contexts)
#   hir::direct::summary HIR         text summary (main.tcl -direct)
#   hir::direct::explain HIR NS      why unit NS is (or is not) direct
#
# "Direct" means raw, ambient authority that has not yet been converted into
# an explicit capability represented by a context. The trust unit is the
# module -- the file-derived unit of hir::buildSyntax's -module-decls, the
# entry program ("") included: there is no root-module special case.
#
# Designation. A module is *designated direct* when
#
#   * its source file starts with `direct module` (moduleDecls' `direct`), or
#   * it is an intrinsic namespace the compiler declares direct
#     (core::native::declareDirectNamespace: the raw syscall transports
#     std::linux::abi::x86_64 and std::linux::abi::aarch64) -- the trusted provider's
#     equivalent declaration.
#
# Nothing else designates one: never a namespace's name, path or library.
#
# Direct edges. A call in unit U whose target belongs to a designated-direct
# unit D other than U is a direct edge of U. The target is the call's exact
# target (hir::contexts::Callee: a block, through aliases; else a native) and
# its unit the section the block is defined in (or the native's namespace,
# core::native::namespaceOf). Module granular, deliberately: every callable
# of D is direct, none exempt. A trait operation calls whatever its witness
# provides, so it is an edge into D when D may provide it: when D declares a
# top-level function of the requirement's name (conformance looks only in a
# witness's owner namespace, so only then can D's implementation run -- a
# context trait's implementation too, CONTEXT-TRAITS.md). A call of an
# extern c fn whose contract may retain a pointer (an escape captures or
# unknown: core::cabi::RetainingParameters) is itself an authority source, a
# direct edge of U whatever unit declares the function, U included (C-FFI.md,
# "direct"); declaring one designates nothing, and a noescape C call is an
# ordinary call. Calls in unreachable code count: they still name the
# authority.
#
# Discharge. A direct edge is *mediated* when the function containing the
# call requires a context declared by U itself: a context struct
# (CONTEXTS.md) or a context trait (CONTEXT-TRAITS.md) of U, in its context
# section; the owner is the declaring module (hir::structs::owner,
# hir::traits::owner), never a spelling. Nothing else mediates: not a context
# of another module, not a caller's context (a context-free helper's direct
# call is undischarged however it is called), and never top-level code. A
# nested function is its own function; only a coroutine construction's thunk,
# whose body runs at the construction, belongs to the function around it.
# Whether a context holds "enough" authority is the module author's policy,
# never checked.
#
# The module result. U is *inferred direct* when one of its edges is
# undischarged (or U is an intrinsically direct namespace). It must agree with
# the declaration:
#
#   inferred  declared
#   no        no         an ordinary module (contextualized, if it has edges)
#   yes       no         DIRECT, at each function's first undischarged edge
#   yes       yes        a deliberate direct module
#   no        yes        STALE-DIRECT-MODULE, at the marker
#
# A caller's edge into D reads D's *designation* only, never D's inference:
# directness stops at a successful contextualization boundary, an unmarked
# module whose own inference fails reports its own diagnostic and nothing
# downstream, and every fact a diagnostic reads is local to its function or a
# file header -- so one static block's rejection never changes another's
# DIRECT diagnostic (STATIC-COMPILE.md's dependency analysis needs no channel
# for it).
#
# Callable values. A function of a designated-direct module is called, or
# bound to another name as a statement (an alias, whose own calls are edges
# again): in a module that is not declared direct, any other use of it --
# passing, returning, storing, capturing it as a value -- is
# DIRECT-CALLABLE-VALUE, since a call through an unknown function value could
# not be seen as an edge. A direct module may hand its own callables out: it
# declared that it exposes raw authority.
#
# Programs past the source boundary (core IR text, HIR text: no moduleDecls)
# are not judged, and neither is the monomorphized build: directness is a
# property of the program as written, decided on the checked build, whose
# summary hir::BuildFull copies (a trait plan's placeholder of never-executed
# code must not make a module look stale).
#
# What HIR keeps (`direct`): {units {NS UNIT ...} intrinsic {NS ...}}, UNIT
# {declared 0|1 marker ORIGIN provided 0|1 inferred 0|1 status STATUS edges
# {EDGE ...}}, STATUS one of ordinary contextualized direct provided
# unacknowledged stale, EDGE {function NAME origin ORIGIN target D callee
# NAME via call|trait discharged CONTEXT foreign {{CONTEXT OWNER} ...}} (discharged ""
# when undischarged). No lowering or backend reads it: there is no runtime
# direct bit.

namespace eval hir::direct {}

# 1 if unit NS is designated direct in HIR (header): declared `direct module`
# or an intrinsically direct namespace.
proc hir::direct::Designated {hir ns} {
    if {[core::native::isDirectNamespace $ns]} {
        return 1
    }
    return [expr {[dict exists $hir moduleDecls $ns direct] && [dict get $hir moduleDecls $ns direct]}]
}

# The unit ("" for the entry program, a namespace for a module section) whose
# code scope S belongs to: the "program"-kind scope it is nested in. MEMO
# (scope -> unit) and SECTIONS (section scope -> namespace) are the caller's.
proc hir::direct::UnitOfScope {hir s memoVar sections} {
    upvar 1 $memoVar memo
    set path {}
    set unit ""
    while {$s ne ""} {
        if {[dict exists $memo $s]} {
            set unit [dict get $memo $s]
            break
        }
        lappend path $s
        if {[dict exists $sections $s]} {
            set unit [dict get $sections $s]
            break
        }
        set scope [dict get $hir scopes $s]
        if {[dict get $scope kind] eq "program"} {
            set unit ""
            break
        }
        set s [dict get $scope parent]
    }
    foreach p $path {
        dict set memo $p $unit
    }
    return $unit
}

# The display name of block B: the name of the function it is bound to, as
# written (hir::semantic::SourceName), found among the bindings of the scope
# its literal is in; "the function at LOCATION" for an anonymous one, "" for
# top-level code (B ""). NAMES is the caller's memo.
proc hir::direct::FunctionName {hir namesVar b} {
    upvar 1 $namesVar names
    if {$b eq ""} {
        return ""
    }
    if {[dict exists $names $b]} {
        return [dict get $names $b]
    }
    set name "the function at [hir::originLocation $hir [hir::get $hir $b origin]]"
    foreach binding [dict get $hir scopes [hir::get $hir $b scope] bindings] {
        set by [dict get $hir bindings $binding declaredBy]
        if {$by ne "" && [dict exists $hir exprs $by] && [hir::kind $hir $by] eq "bind"
                && [hir::get $hir $by value] eq $b} {
            set name [hir::semantic::SourceName $hir $binding]
            break
        }
    }
    dict set names $b $name
    return $name
}

# "module \"NS\"" or "the entry program".
proc hir::direct::UnitPhrase {ns} {
    return [expr {$ns eq "" ? "the entry program" : "module \"$ns\""}]
}

# The direct targets of call C (written in unit UNIT): a list of {UNIT-D
# CALLEE VIA} for every designated-direct unit other than UNIT whose callable
# C may run (header, "Direct edges"); CALLEE is {block E}, {native NAME} or
# {text TEXT}. MEMO, SECTIONS as for UnitOfScope.
proc hir::direct::Targets {hir c node unit memoVar sections} {
    upvar 1 $memoVar memo
    if {[dict exists $node traitCall]} {
        set record [dict get $node traitCall]
        set trait [dict get $record trait]
        set requirement [dict get $record requirement]
        if {[hir::traits::isIntrinsic $trait]} {
            # An intrinsic trait's operation (HASHABLE-AND-KEYED-HASH.md) runs
            # the implementation's own native for every witness, never a
            # module's function: no module is its target.
            return {}
        }
        # A trait operation may run the implementation of any witness: a
        # top-level function of the requirement's name in the witness's owner
        # module (conformance looks nowhere else, TRAITS.md and
        # CONTEXT-TRAITS.md) -- so an edge into each designated unit that
        # declares one. Read from the declarations alone, never from the
        # program's selection or reachability.
        set found {}
        foreach d [dict keys [dict get $hir moduleDecls]] {
            if {$d eq $unit || ![Designated $hir $d]} continue
            set info [hir::traits::ImplInfo $d $requirement]
            if {$info ne "" && [dict get $info kind] eq "block"} {
                lappend found [list $d [list text "[if {$d eq ""} {set requirement} else {string cat "${d}::$requirement"}] (an implementation of $trait's $requirement)"] trait]
            }
        }
        return $found
    }
    set target [hir::contexts::Callee $hir $c]
    if {$target ne ""} {
        set d [UnitOfScope $hir [hir::get $hir $target scope] memo $sections]
        if {$d eq $unit || ![Designated $hir $d]} {
            return {}
        }
        return [list [list $d [list block $target] call]]
    }
    lassign [dict get $node target] kind y
    if {$kind ne "native"} {
        return {}
    }
    set name [dict get [hir::symbol $hir $y] name]
    if {[core::native::isExtern $name] && [core::native::exists $name]} {
        # A C function whose contract lets it keep a pointer past the call
        # (an escape captures or unknown: hir::borrow::retaining) is itself
        # an authority source, called from any unit, its declaring one
        # included (C-FFI.md, "direct"). A noescape one is an ordinary call:
        # foreign is not direct.
        set retains [core::cabi::RetainingParameters [dict get [core::native::metadata $name] foreign]]
        set reasons [lmap r $retains {
            lassign $r index pname escape
            format {parameter "%s": escape %s} $pname $escape
        }]
        # A pointer passed as a trailing argument of a variadic C function
        # (VARIADICS-VERTICAL-SLICE-1.md) has no contract at all, so its
        # escape is unknown: C may keep it.
        set position [llength [dict get [core::native::metadata $name] foreign params]]
        set pointers {}
        foreach how [dict getdef $node cvarargs {}] {
            incr position
            if {[dict getdef $how promoted ""] eq "ptr"} {
                lappend pointers $position
            }
        }
        if {$pointers ne {}} {
            lappend reasons [format {argument%s %s: %s passed as a trailing argument, whose escape no contract states} \
                [expr {[llength $pointers] == 1 ? "" : "s"}] [join $pointers {, }] \
                [expr {[llength $pointers] == 1 ? "a pointer" : "pointers"}]]
        }
        if {$reasons ne {}} {
            return [list [list [core::native::namespaceOf $name] \
                [list text "[core::native::displayName $name], a C function whose contract lets it retain pointer authority past the call ([join $reasons {; }])"] foreign]]
        }
    }
    set d [core::native::namespaceOf $name]
    if {$d eq "" || $d eq $unit || ![Designated $hir $d]} {
        return {}
    }
    return [list [list $d [list native $name] call]]
}

# The function whose context section mediates code whose innermost enclosing
# block is O ("" at top level): O itself, or -- for a coroutine construction's
# thunk (THUNKS: block -> its construction call), which runs where it is
# constructed -- the function around the construction.
proc hir::direct::Mediator {hir o thunks} {
    while {$o ne "" && [dict exists $thunks $o]} {
        set o [Owner $hir [dict get $thunks $o]]
    }
    return $o
}

# The innermost block whose invocation expression E runs in, "" at top level.
proc hir::direct::Owner {hir e} {
    return [dict get $hir scopes [dict get $hir exprs $e scope] invocation]
}

# {DISCHARGED FOREIGN} for a direct call of unit UNIT in function B: the
# first context requirement of B's context section that UNIT declares itself
# -- a context struct or a context trait -- ("" if none), and B's context
# requirements declared by other modules, which do not mediate ({ID OWNER}
# pairs).
proc hir::direct::Discharge {hir b unit} {
    if {$b eq "" || ![dict exists $hir exprs $b contextParams]} {
        return [list "" {}]
    }
    set discharged ""
    set foreign {}
    foreach record [dict get $hir exprs $b contextParams] {
        set id [dict get $record context]
        if {$id eq ""} continue
        if {[dict exists $record trait]} {
            set owner [hir::traits::owner $id]
        } else {
            set owner [hir::structs::owner $id]
        }
        if {$owner ne $unit} {
            lappend foreign [list $id $owner]
        } elseif {$discharged eq ""} {
            set discharged $id
        }
    }
    return [list $discharged $foreign]
}

proc hir::direct::verify {hirVar} {
    upvar 1 $hirVar hir
    if {![dict exists $hir moduleDecls] || [hir::mode $hir] ne "program"} {
        # Past the source boundary: no module declarations to judge.
        return
    }
    if {[hir::traits::Planning] || [dict exists $hir traitSource]} {
        # The monomorphized program: judged as written (header).
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
    set create [core::coroutines::createNative]
    # One pass over the program, in expression order: every call's direct
    # targets, the thunks of coroutine constructions, and the callee
    # positions (a reference there is a call, never a value).
    set found {}
    set thunks [dict create]
    set callees [dict create]
    dict for {c node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        dict set callees [dict get $node callee] 1
        if {[hir::coroutines::NativeOf $hir $c] eq $create} {
            set thunk [lindex [dict get $node args] 0]
            if {$thunk ne "" && [hir::kind $hir $thunk] eq "block"} {
                dict set thunks $thunk $c
            }
        }
        set unit [UnitOfScope $hir [dict get $node scope] memo $sections]
        if {![dict exists $decls $unit]} continue
        set targets [Targets $hir $c $node $unit memo $sections]
        if {$targets ne {}} {
            lappend found [list $c $unit $targets]
        }
    }
    # The edges, per unit.
    set edges [dict create]
    set intrinsic [dict create]
    set names [dict create]
    foreach item $found {
        lassign $item c unit targets
        set b [Mediator $hir [Owner $hir $c] $thunks]
        lassign [Discharge $hir $b $unit] discharged foreign
        foreach t $targets {
            lassign $t d callee via
            if {[core::native::isDirectNamespace $d]} {
                dict set intrinsic $d 1
            }
            lassign $callee how what
            if {$how eq "block"} {
                set callee [FunctionName $hir names $what]
            } else {
                set callee $what
            }
            dict lappend edges $unit [dict create call $c block $b \
                function [FunctionName $hir names $b] origin [hir::get $hir $c origin] \
                target $d callee $callee via $via discharged $discharged foreign $foreign]
        }
    }
    set units [dict create]
    dict for {unit decl} $decls {
        set list [dict getdef $edges $unit {}]
        set undischarged [lmap edge $list {if {[dict get $edge discharged] eq ""} {set edge} else {continue}}]
        set provided [core::native::isDirectNamespace $unit]
        set marker [dict get $decl direct]
        set inferred [expr {$undischarged ne {} || $provided}]
        set declared [expr {$marker || $provided}]
        if {$provided} {
            set status provided
        } elseif {$inferred && $declared} {
            set status direct
        } elseif {$inferred} {
            set status unacknowledged
            Unacknowledged hir $unit $undischarged
        } elseif {$marker} {
            set status stale
            hir::DiagnoseAt hir STALE-DIRECT-MODULE \
                [StaleMessage $unit $list] "" [dict get $decl origin]
        } elseif {$list ne {}} {
            set status contextualized
        } else {
            set status ordinary
        }
        dict set units $unit [dict create declared $declared marker [dict get $decl origin] \
            provided $provided inferred $inferred status $status \
            edges [lmap edge $list {dict remove $edge call block}]]
    }
    CheckValues hir $callees $sections memo
    dict set hir direct [dict create units $units intrinsic [lsort [dict keys $intrinsic]]]
}

# DIRECT for unit UNIT's undischarged EDGES: one diagnostic per function, at
# its first undischarged direct call, the function's other ones as related
# locations.
proc hir::direct::Unacknowledged {hirVar unit undischarged} {
    upvar 1 $hirVar hir
    set byFunction [dict create]
    foreach edge $undischarged {
        dict lappend byFunction [dict get $edge block] $edge
    }
    dict for {b list} $byFunction {
        # (Source order within the function: its file's offsets.)
        set list [lsort -command hir::direct::SourceOrder $list]
        set first [lindex $list 0]
        set related {}
        foreach edge [lrange $list 1 end] {
            if {[dict get $edge call] ne [dict get $first call]} {
                lappend related [dict get $edge origin]
            }
        }
        hir::Diagnose hir DIRECT [UnacknowledgedMessage $unit $first [llength $related]] \
            [dict get $first call] $related
    }
}

proc hir::direct::SourceOrder {a b} {
    set x [dict get $a origin]
    set y [dict get $b origin]
    set i [dict getdef $x start 0]
    set j [dict getdef $y start 0]
    return [expr {$i < $j ? -1 : ($i > $j ? 1 : 0)}]
}

proc hir::direct::UnacknowledgedMessage {unit edge more} {
    set who [UnitPhrase $unit]
    if {$unit eq ""} {
        set owner "the entry program"
    } else {
        set owner "\"$unit\""
    }
    set d [dict get $edge target]
    switch -- [dict get $edge via] {
        trait { set via "a trait operation that may run [dict get $edge callee], a callable of the direct module \"$d\"" }
        foreign { set via [dict get $edge callee] }
        default { set via "[dict get $edge callee], a callable of the direct module \"$d\"" }
    }
    if {[dict get $edge function] eq ""} {
        set message "$who uses direct authority in its top-level code: it calls $via, and top-level code has no context, so the call is never mediated; move it into a function that requires a context defined by $owner, or declare the module direct with `direct module` as its first line"
    } else {
        set fn [dict get $edge function]
        set message "$who uses direct authority: function \"$fn\" calls $via, without a context defined by $owner"
        set notes {}
        foreach f [dict get $edge foreign] {
            lassign $f id from
            lappend notes "$id, a context defined by [UnitPhrase $from]"
        }
        if {$notes ne {}} {
            append message " (\"$fn\" requires [join $notes { and }], but a context mediates direct authority only in the module that defines it: a context declared by $owner itself)"
        }
        append message "; require one of this module's own contexts (\"context NAME: T\", T a context struct or context trait declared by $owner) in \"$fn\", the function that makes the direct call, or declare the module direct with `direct module` as its first line"
    }
    if {$more > 0} {
        append message " ($more more undischarged direct call[expr {$more == 1 ? "" : "s"}] in the same [expr {[dict get $edge function] eq "" ? "top-level code" : "function"}], at the related locations)"
    }
    return $message
}

proc hir::direct::StaleMessage {unit edges} {
    set who [UnitPhrase $unit]
    if {$unit eq ""} {
        set owner "the entry program"
    } else {
        set owner "\"$unit\""
    }
    if {$edges eq {}} {
        return "`direct module` is unnecessary: $who makes no call into a direct module, so it exposes no direct authority; remove the declaration (it must state exactly what the compiler infers)"
    }
    return "`direct module` is unnecessary: all direct authority in $who is mediated by contexts defined by $owner (every call into a direct module is in a function requiring one of them); remove the declaration (it must state exactly what the compiler infers)"
}

# The designated-direct unit whose callable binding B denotes -- a root
# native of an intrinsic direct namespace, or a function (through aliases) of
# a designated unit -- else "-". MEMO, SECTIONS as for UnitOfScope.
proc hir::direct::DenotedUnit {hir b memoVar sections} {
    upvar 1 $memoVar memo
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "root"} {
        set y [dict get $binding symbol]
        if {$y eq "" || ![dict exists $hir symbols $y] || [dict get $hir symbols $y kind] ne "native"} {
            return -
        }
        set d [core::native::namespaceOf [dict get $hir symbols $y name]]
        if {$d eq ""} {
            return -
        }
    } else {
        set target [hir::contexts::Denotes $hir $b]
        if {$target eq ""} {
            return -
        }
        set d [UnitOfScope $hir [hir::get $hir $target scope] memo $sections]
    }
    if {[Designated $hir $d]} {
        return $d
    }
    return "-"
}

# DIRECT-CALLABLE-VALUE: every reference, in a unit not declared direct, to a
# callable of another designated-direct unit that uses it as a value (header).
# CALLEES: the callee positions of the program's calls, never a value.
proc hir::direct::CheckValues {hirVar callees sections memoVar} {
    upvar 1 $hirVar hir
    upvar 1 $memoVar memo
    set candidates {}
    # Binding -> the designated-direct unit whose callable it denotes, or "-".
    set denoted [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq "" || ![dict exists $hir bindings $b]} continue
        if {![dict exists $denoted $b]} {
            dict set denoted $b [DenotedUnit $hir $b memo $sections]
        }
        set d [dict get $denoted $b]
        if {$d eq "-"} continue
        set unit [UnitOfScope $hir [dict get $node scope] memo $sections]
        if {$d eq $unit || ![dict exists $hir moduleDecls $unit] || [Designated $hir $unit]} continue
        lappend candidates [list $e $d $unit]
    }
    if {$candidates eq {}} {
        return
    }
    set parent [lindex [hir::contexts::Walk $hir] 1]
    foreach candidate $candidates {
        lassign $candidate e d unit
        if {![dict exists $parent $e] || ![hir::contexts::Observed $hir $parent $e]} continue
        set name [hir::semantic::RefName $hir $e]
        hir::Diagnose hir DIRECT-CALLABLE-VALUE \
            "$name is a callable of the direct module \"$d\": [UnitPhrase $unit], which is not declared direct, may only call it (or bind it to another name as a statement), never pass, return, store or capture it as a value -- a call through an unknown function value would carry direct authority past this module's context boundary unseen (DIRECT-MODULES.md)" $e
    }
}

# ---------------------------------------------------------------------------
# Tooling

# Why unit NS of HIR is (or is not) direct: its declaration, inference and
# status, and every direct edge with what mediates it. "" when HIR was not
# judged or has no such unit.
proc hir::direct::explain {hir ns} {
    if {![dict exists $hir direct units $ns]} {
        return ""
    }
    set u [dict get $hir direct units $ns]
    set lines [list "[expr {$ns eq "" ? "entry program" : "module $ns"}]: [dict get $u status] (declared [expr {[dict get $u declared] ? "direct" : "ordinary"}][expr {[dict get $u provided] ? " by the compiler" : ""}], inferred [expr {[dict get $u inferred] ? "direct" : "ordinary"}])"]
    foreach edge [dict get $u edges] {
        if {[dict get $edge function] eq ""} {
            set fn "top-level code"
        } else {
            set fn [dict get $edge function]
        }
        set how [expr {[dict get $edge discharged] ne "" ? "mediated by [dict get $edge discharged]" : "undischarged"}]
        set what [expr {[dict get $edge via] eq "foreign" ? "a retaining C call" : "direct module [dict get $edge target]"}]
        lappend lines "    $fn -> [dict get $edge callee] ($what, [hir::originLocation $hir [dict get $edge origin]]): $how"
    }
    return [join $lines \n]
}

# A text summary of HIR's module directness (main.tcl -direct): every unit's
# explanation, entry program last, then the intrinsic direct namespaces it
# calls.
proc hir::direct::summary {hir} {
    if {![dict exists $hir direct]} {
        return ""
    }
    set lines {}
    dict for {ns _} [dict get $hir direct units] {
        lappend lines [explain $hir $ns]
    }
    foreach ns [dict get $hir direct intrinsic] {
        lappend lines "intrinsic $ns: provided direct by the compiler"
    }
    return [join $lines \n]
}
