# discarded.tcl -- the facts of the DISCARDED-MUTATION warning
# (WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md; CONSTRUCT-BINDING-MUTATION-
# CENSUS-1.md, sections 16 and 17).
#
#   hir::discarded::findings HIR    the program's discarded mutations
#
# A *mutation* is what hir::mutvec::verify judges one (hir/mutvec.tcl): a
# call of a native whose receiver role is `place` -- its receiver path is the
# mutation's *destination* -- or a call of a function with place parameters,
# each place argument's path a destination. Nothing is identified by a name:
# the registry's roles (hir::mutvec::OpKind) and the callee's `places` decide.
# Only calls the program wrote count (`written`, form function or method:
# both spellings are one call node).
#
# Two facts, each a proof over the checked program as written -- never a
# guess about intent:
#
#   dead       (B1) the mutation changes local storage whose new state no
#              code can read afterwards, on any path, and the call has
#              nothing else to show for itself:
#                * every destination is a place that dies with its scope
#                  (Dying: a local, a loop or lockstep element, a fold
#                  intermediate, a handler payload -- never a place
#                  parameter or a context parameter, whose state outlives
#                  the call), and is its path's last use
#                  (hir::mutvec::NoLaterUse: the analysis the copy
#                  convention's moves rely on -- every later statement,
#                  operand, branch, handler and later iteration of a loop
#                  the binding outlives);
#                * the call's own value is discarded (ValueDiscarded: unit,
#                  a discarded statement, or the value of a construct that is
#                  itself discarded -- an `if`, a handled call, a collecting
#                  loop's iteration); a destructive read whose element is
#                  used is no dead mutation;
#                * the operation has no other effect: a collection operation
#                  (whose only effect is its receiver's), or a call of a
#                  *confined* function (Confined: everything it can reach
#                  touches only its own places and its place parameters);
#                * nothing affine is involved (no destination or argument of
#                  an affine type): releasing or moving an affine value can
#                  run a resource's cleanup, whose timing is the program's.
#              Its failure is still the program's: a `set` out of range
#              fails whether or not its result is read. The fact says the
#              modified state is unused, never that the call may be
#              deleted.
#   fold-exit  (B2) a `continue` or bare `break` of a fold, every path to
#              which, in its iteration, has mutated the fold's intermediate
#              (ExitWalk: a must-fact over the iteration). The exit carries
#              the intermediate the iteration started with
#              (FOLD-LOOPS-MILESTONE-1.md, rules 5 and 6): every execution
#              of it discards a mutation. "Every path" rather than "some
#              path" keeps the fact independent of path feasibility, which
#              no analysis here decides: a mutation under one condition and
#              an exit under another may never run together. The mutations
#              reported with it are those some path to it runs.
#
# A mutation a fold-exit fact reports is not reported again as dead (the
# exit says why). Facts inside a function are kept only where the completion
# analysis's walk reaches them (hir::completions::reachedExprs, which prunes
# branches its range facts prove infeasible): that can only remove one.
#
# The program as written: the checked build before the elaborations
# (hir::BuildFull's `checkedSource`; a trait program's `traitSource`), where
# a fold's intermediate is its own binding and no loop over a MutableMap has
# been rewritten into a counted loop with `continue`s of its own. Nothing
# here changes HIR or reads anything a backend reads.

namespace eval hir::discarded {
    # The runtime requirement tags (core/native.tcl's runtimeTags) of a
    # native that computes a value and touches nothing outside its
    # arguments: allocation, arithmetic, comparison, hashing, range checks.
    # Not raw-syscall (effects unknown), raw-address (exposes an address to
    # foreign code), process-argv (the process's state), and not the
    # mutation tags, which a collection operation (hir::mutvec::OpKind)
    # carries for its receiver.
    variable valueTags {bigint string-alloc list-alloc result-alloc char-index range-check
        structural-equality mutarray-alloc hash set-alloc bytestore-alloc mutvec-alloc
        float-alloc table-hash}
    # The natives the elaborations introduce (hir/mutvec.tcl): a HIR that
    # refers to one has been elaborated, and is no program as written.
    variable elaborationNatives {mutable_vector#share mutable_vector#to_list mutable_vector#consume
        mutable_array#to_list mutable_array#consume}
    # Per analysis: native name -> 1 if confined (NativeConfined).
    variable nativeMemo [dict create]
}

# The program as written that HIR's warnings are about: its checked build
# before the elaborations, or "" when HIR is elaborated without one (a HIR
# read from interchange text, which carries its warnings already).
proc hir::discarded::Source {hir} {
    if {[dict exists $hir checkedSource]} {
        return [dict get $hir checkedSource]
    }
    # (Every native has a root binding in every HIR: a reference to one the
    # elaborations write is what tells an elaborated program.)
    variable elaborationNatives
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref"} continue
        set b [dict get $node binding]
        if {$b ne "" && [dict get $hir bindings $b kind] eq "root"
                && [dict get $hir bindings $b name] in $elaborationNatives} {
            return ""
        }
    }
    return $hir
}

# The discarded mutations of HIR (the program as written: Source), in no
# particular order: a list of dicts
#
#   reason dead call E dests {ARG...} binding B
#   reason fold-exit exit X fold F binding B mutations {E...}
proc hir::discarded::findings {hir} {
    set hir [Source $hir]
    if {$hir eq ""} {
        return {}
    }
    return [Findings $hir]
}

# findings of HIR, a program as written (Source's answer).
proc hir::discarded::Findings {hir} {
    if {[hir::mode $hir] ne "program" || ![hir::mutvec::Used $hir]} {
        return {}
    }
    set sites [Sites $hir]
    if {$sites eq {}} {
        return {}
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    # The use map NoLaterUse reads (ReadsPath), in the convention variable
    # the elaboration under way would otherwise hold: kept and given back.
    set saved $::hir::mutvec::convention
    set ::hir::mutvec::convention [dict create uses [hir::mutvec::UseMap $hir $parent]]
    try {
        set result [Analyze $hir $owner $parent $sites]
    } finally {
        set ::hir::mutvec::convention $saved
    }
    return $result
}

# The mutation sites of HIR: call ExprId -> list of destination ExprIds
# (place paths), for every reachable call the program wrote that mutates.
proc hir::discarded::Sites {hir} {
    set sites [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]
                || ![dict exists $node written] || [dict get $node written form] ni {function method}} {
            continue
        }
        set places [hir::mutvec::PlaceIndices $hir $e]
        if {$places ne {}} {
            set dests {}
            foreach index $places {
                set arg [lindex [dict get $node args] $index]
                if {$arg ne ""} {
                    lappend dests $arg
                }
            }
            if {$dests ne {}} {
                dict set sites $e $dests
            }
            continue
        }
        if {[hir::mutvec::OpKind $hir $e] ne "mutate"} continue
        set receiver [lindex [dict get $node args] 0]
        if {$receiver ne ""} {
            dict set sites $e [list $receiver]
        }
    }
    return $sites
}

proc hir::discarded::Analyze {hir owner parent sites} {
    variable nativeMemo
    set nativeMemo [dict create]
    # Each destination's root binding; the sites of each binding.
    set roots [dict create]
    set sitesOf [dict create]
    dict for {e dests} $sites {
        foreach d $dests {
            set path [hir::mutvec::Path $hir $d]
            if {$path eq ""} continue
            dict set roots $d [lindex $path 0]
            dict lappend sitesOf [lindex $path 0] $e
        }
    }
    set reached [dict create]
    set findings {}
    # B2: the exits of every fold whose intermediate some site mutates.
    set reported [dict create]
    dict for {f node} [dict get $hir exprs] {
        if {![dict exists $node foldBinding] || ![dict get $node reachable]} continue
        set b [dict get $node foldBinding]
        if {![dict exists $sitesOf $b]} continue
        set mutations [dict create]
        foreach e [dict get $sitesOf $b] {
            dict set mutations $e 1
        }
        set exits [dict create]
        set state [dict create any 0 may {}]
        ExitSequence $hir $f $mutations [dict get $node body] state exits
        dict for {x ran} $exits {
            if {![Reached $hir $owner $parent $x reached]} continue
            set ran [lmap e $ran {
                if {![Reached $hir $owner $parent $e reached]} continue
                set e
            }]
            if {$ran eq {}} continue
            foreach e $ran {
                dict set reported $e 1
            }
            lappend findings [dict create reason fold-exit exit $x fold $f binding $b mutations $ran]
        }
    }
    # B1: every site whose destinations all die unread.
    set confined [dict create]
    dict for {e dests} $sites {
        if {[dict exists $reported $e]} continue
        set binding ""
        set dead 1
        foreach d $dests {
            if {![dict exists $roots $d] || ![Dying $hir [dict get $roots $d]]
                    || ![hir::mutvec::NoLaterUse $hir $parent $d [dict get $roots $d]]} {
                set dead 0
                break
            }
            if {$binding eq ""} {
                set binding [dict get $roots $d]
            }
        }
        if {!$dead || ![ValueDiscarded $hir $parent $e] || [InvolvesAffine $hir $e]} continue
        if {[hir::mutvec::PlaceIndices $hir $e] ne {}} {
            set f [lindex [dict get $hir exprs $e target] 1]
            if {![dict exists $confined $f]} {
                set confined [dict merge $confined [ConfinedBlocks $hir $f]]
            }
            if {![dict get $confined $f]} continue
        }
        if {![Reached $hir $owner $parent $e reached]} continue
        lappend findings [dict create reason dead call $e dests $dests binding $binding]
    }
    return $findings
}

# 1 unless the completion analysis's walk of the function holding E proves
# E unreachable (REACHEDVAR caches each function's walk). Top-level code
# has no such walk: its structural reachability is the HIR's. (The walk
# records a handled call as its `handle`, whose call it evaluates in place.)
proc hir::discarded::Reached {hir owner parent e reachedVar} {
    upvar 1 $reachedVar reached
    set block [dict getdef $owner $e ""]
    if {$block eq ""} {
        return 1
    }
    if {![dict exists $reached $block]} {
        dict set reached $block [hir::completions::reachedExprs $hir $block]
    }
    set p [lindex [dict getdef $parent $e {}] 0]
    if {$p ne "" && [dict get $hir exprs $p kind] eq "handle" && [dict get $hir exprs $p call] eq $e} {
        set e $p
    }
    return [dict exists $reached $block $e]
}

# 1 if binding B is a place that dies with its scope: a local of a function,
# a construct or the entry program's top level (never a context parameter:
# the installed context outlives the function), a loop or lockstep element,
# a fold's intermediate or a handler's payload. A function's parameter is
# not: a place parameter is the caller's place, and a value parameter is
# never mutated (NONPLACE-PARAMETER-MUTATION).
proc hir::discarded::Dying {hir b} {
    set binding [dict get $hir bindings $b]
    switch -- [dict get $binding kind] {
        local {
            return [expr {![hir::mutvec::IsContextParam $hir $b]}]
        }
        param {
            set owner [dict get $hir scopes [dict get $binding scope] owner]
            if {$owner eq "" || ![dict exists $hir exprs $owner]} {
                return 0
            }
            set node [dict get $hir exprs $owner]
            if {[dict getdef $node foldBinding ""] eq $b} {
                return 1
            }
            return [expr {[dict get $node kind] in {listloop lockloop handle}}]
        }
    }
    return 0
}

# 1 if the value of call E is discarded: unit (it says nothing), or a
# discarded statement's, or the value of a construct whose own value is
# discarded -- an `if` it ends a branch of, a handled call, a collecting
# loop whose iteration it ends (the List it collects). Never a function's
# result, the program's value, a fold's next intermediate, a binding's
# value or an operand.
proc hir::discarded::ValueDiscarded {hir parent e} {
    set type [hir::typeOf $hir $e]
    if {$type eq "never"} {
        return 0
    }
    if {[hir::types::kindOf $type] eq "unit"} {
        return 1
    }
    set x $e
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} {
            return 0
        }
        lassign [dict get $parent $x] p role
        if {$role eq "seq 0"} {
            return 1
        }
        if {$p eq ""} {
            # The entry program's last statement: its value.
            return 0
        }
        set node [dict get $hir exprs $p]
        switch -- [dict get $node kind] {
            if - handle {
                # (A branch's or a handler's last statement, or the handled
                # call: the construct's value.)
                if {$role eq "seq 1" || ([dict get $node kind] eq "handle" && [dict get $node call] eq $x)} {
                    set x $p
                    continue
                }
                return 0
            }
            loop - listloop - countloop - lockloop {
                if {$role ne "seq 1" || [dict exists $node foldBinding]} {
                    return 0
                }
                set x $p
                continue
            }
        }
        return 0
    }
    return 0
}

# 1 if call E's value, a destination or an argument has an affine type: a
# move or release of an affine value is the program's (a resource's cleanup
# runs code), whatever becomes of the place.
proc hir::discarded::InvolvesAffine {hir e} {
    foreach x [concat [list $e] [dict get $hir exprs $e args]] {
        if {$x ne "" && [hir::types::IsAffine [hir::typeOf $hir $x]]} {
            return 1
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Confined functions
#
# A function is *confined* when nothing it can reach touches anything but
# its own places and the places its caller gives it: its body and,
# transitively, every function it calls by a known target is value
# computation, collection operations (whose receivers are its own places),
# calls of confined functions and calls of natives whose registration says
# they touch nothing outside their arguments (NativeConfined). Anything
# else is not: a call through a function value, a native that calls an
# argument, yields, loads a context, makes a syscall or a C call, any
# unclassified native; a function that requires a context; and one that
# holds an affine value (whose release may run a resource's cleanup).
# Divergence and failure are a confined function's own outcomes, which the
# fact never hides. Recursion is analyzed optimistically: confinement is a
# safety property (no reachable operation has an outside effect), so the
# greatest fixed point is the sound one.

# Block -> 1|0 for block F and every function it reaches.
proc hir::discarded::ConfinedBlocks {hir f} {
    set local [dict create]
    set callees [dict create]
    set work [list $f]
    while {$work ne {}} {
        set work [lassign $work g]
        if {[dict exists $local $g]} continue
        if {![dict exists $hir exprs $g] || [dict get $hir exprs $g kind] ne "block"} {
            dict set local $g 0
            continue
        }
        lassign [LocalConfinement $hir $g] verdict called
        dict set local $g $verdict
        dict set callees $g $called
        lappend work {*}$called
    }
    # The greatest fixed point: a function is confined while every function
    # it calls is.
    set changed 1
    while {$changed} {
        set changed 0
        dict for {g verdict} $local {
            if {!$verdict} continue
            foreach h [dict getdef $callees $g {}] {
                if {![dict get $local $h]} {
                    dict set local $g 0
                    set changed 1
                    break
                }
            }
        }
    }
    return $local
}

# {VERDICT CALLEES} for block G's own body: VERDICT 0 when something in it
# is not confined, CALLEES the blocks it calls by a known target.
proc hir::discarded::LocalConfinement {hir g} {
    if {[hir::contexts::required $hir $g] ne {}} {
        return [list 0 {}]
    }
    set called {}
    set affine [dict create]
    set work [dict get $hir exprs $g body]
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        set node [dict get $hir exprs $x]
        if {![dict get $node reachable]} continue
        set kind [dict get $node kind]
        if {$kind eq "block"} {
            # Creating a function runs nothing; a call of it is a call.
            continue
        }
        set type [hir::typeOf $hir $x]
        if {![dict exists $affine $type]} {
            dict set affine $type [hir::types::IsAffine $type]
        }
        if {[dict get $affine $type]} {
            return [list 0 {}]
        }
        if {$kind eq "call"} {
            lassign [dict get $node target] targetKind target
            switch -- $targetKind {
                block {
                    if {$target ni $called} {
                        lappend called $target
                    }
                }
                native {
                    if {![NativeConfined [hir::affine::NativeName $hir $x]]} {
                        return [list 0 {}]
                    }
                }
                default {
                    return [list 0 {}]
                }
            }
        }
        lappend work {*}[hir::children $hir $x]
    }
    return [list 1 $called]
}

# 1 if native NAME touches nothing outside its arguments and result, by its
# registration (core/native.tcl): it calls no argument (no factory or
# resume role), and it is context-free (it neither reads nor changes the
# execution environment), a collection operation (its effect is its
# receiver's, a place of the caller: hir::mutvec::NativeOpKind) or
# constructor (hir::mutvec::Constructor), or a native whose every runtime
# requirement is a value computation's (valueTags).
proc hir::discarded::NativeConfined {name} {
    variable nativeMemo
    variable valueTags
    if {$name eq ""} {
        return 0
    }
    if {[dict exists $nativeMemo $name]} {
        return [dict get $nativeMemo $name]
    }
    set meta [core::native::metadata $name]
    set verdict 1
    set count [llength [dict get $meta paramTypes]]
    for {set i 0} {$i < $count} {incr i} {
        if {[core::native::ownershipRole $name $i] in {factory resume}} {
            set verdict 0
            break
        }
    }
    if {$verdict && ![dict get $meta contextFree] && [hir::mutvec::NativeOpKind $name] eq ""
            && ![hir::mutvec::Constructor $name]} {
        set tags [dict get $meta runtime]
        if {$tags eq {}} {
            set verdict 0
        }
        foreach tag $tags {
            if {$tag ni $valueTags} {
                set verdict 0
                break
            }
        }
    }
    dict set nativeMemo $name $verdict
    return $verdict
}

# ---------------------------------------------------------------------------
# Fold exits (B2)
#
# The analysis of one iteration of fold F: STATE (a variable of the
# caller's, updated in place) is a dict {any A may M}, or {top 1} where no
# path arrives (after a statement that never completes; unreachable code).
# A is 1 when every path to here has mutated F's intermediate in this
# iteration (a must-fact), M the mutations (MUTATIONS: call ExprId -> 1)
# some path to here ran (a may-set). A call is counted once it completes
# (its operands first); a handler starts from the state before its handled
# call (whose mutation may not have happened); an `if` meets its branches
# (A both, M either); a loop inside the body may run its body no times, so
# it adds nothing; a nested function's body runs elsewhere. A `continue` or
# bare `break` of F (every `break` is bare, and both target the nearest
# loop: F's own exits are never inside a nested loop) reached with A 1
# records M in EXITSVAR (exit ExprId -> its mutations, sorted): every
# execution of that exit discards a mutation, and each of M is one it
# discards on the paths that run both. A is a must-fact over every path of
# the iteration's control flow, feasible or not, so no infeasible path can
# make it: a mutation under one condition and an exit under another never
# make A. The state is updated where it is held -- never a copy per
# statement -- so a straight-line body is walked in linear time; a branch
# costs one copy of M for its other side.

proc hir::discarded::Meet {a b} {
    if {[dict exists $a top]} {
        return $b
    }
    if {[dict exists $b top]} {
        return $a
    }
    set any [expr {[dict get $a any] && [dict get $b any]}]
    set may [dict get $a may]
    set other [dict get $b may]
    if {[dict size $other] > [dict size $may]} {
        lassign [list $other $may] may other
    }
    dict for {e -} $other {
        dict set may $e 1
    }
    return [dict create any $any may $may]
}

proc hir::discarded::ExitSequence {hir f mutations sequence stateVar exitsVar} {
    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}
    upvar 1 $stateVar state $exitsVar exits
    foreach s $sequence {
        if {[dict exists $state top]} {
            return
        }
        ExitWalk $hir $f $mutations $s state exits
    }
}

proc hir::discarded::ExitWalk {hir f mutations x stateVar exitsVar} {
    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}
    upvar 1 $stateVar state $exitsVar exits
    if {[dict exists $state top]} {
        return
    }
    set node [dict get $hir exprs $x]
    if {![dict get $node reachable]} {
        set state {top 1}
        return
    }
    set kind [dict get $node kind]
    switch -- $kind {
        const - ref - block {
            return
        }
        break - continue {
            if {[dict get $node target] eq $f && [dict get $state any]} {
                dict set exits $x [lsort -dictionary [dict keys [dict get $state may]]]
            }
            set state {top 1}
            return
        }
        if {
            ExitWalk $hir $f $mutations [dict get $node condition] state exits
            if {[dict exists $state top]} {
                return
            }
            set else $state
            ExitSequence $hir $f $mutations [dict get $node thenBody] state exits
            ExitSequence $hir $f $mutations [dict get $node elseBody] else exits
            set state [Meet $state $else]
            return
        }
        handle {
            set before $state
            ExitWalk $hir $f $mutations [dict get $node call] state exits
            foreach body [dict get $node handlerBodies] {
                set handler $before
                ExitSequence $hir $f $mutations $body handler exits
                set state [Meet $state $handler]
            }
            return
        }
        loop - listloop - countloop - lockloop {
            set body [dict get $node body]
            set children [hir::children $hir $x]
            foreach c [lrange $children 0 end-[llength $body]] {
                ExitWalk $hir $f $mutations $c state exits
                if {[dict exists $state top]} {
                    return
                }
            }
            if {[hir::typeOf $hir $x] eq "never"} {
                set state {top 1}
            }
            return
        }
    }
    foreach c [hir::children $hir $x] {
        ExitWalk $hir $f $mutations $c state exits
        if {[dict exists $state top]} {
            return
        }
    }
    if {$kind in {return fail}} {
        set state {top 1}
        return
    }
    if {$kind eq "call" && [dict exists $mutations $x]} {
        dict set state any 1
        dict set state may $x 1
    }
    if {[hir::typeOf $hir $x] eq "never"} {
        set state {top 1}
    }
}
