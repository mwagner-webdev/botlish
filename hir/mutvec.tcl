# mutvec.tcl -- MutableVector[T] places and logical copies (MUTABLE-VECTOR.md).
#
# A MutableVector is a growable mutable VALUE. Its runtime representation
# (core/mutvec.tcl, native MutVecObj) is a *header* -- the identity of one
# logical vector value, mutated in place by push/pop/take/swap/clear -- over
# a copy-on-write *backing*. A mutation therefore never stores a new value
# back into its receiver: the receiver must be a *place* (a binding, or a
# struct field reached from one) that owns its header, and the compiler keeps
# every place's header owned by that place alone:
#
#   receivers   the first argument of a mutating operation must be a place
#               path: a reference to a local, parameter or context parameter
#               of the same function, or a chain of field projections from
#               one (`v.push(x)`, `state.queue.pop()`, `io.output.push(t)`),
#               of static type MutableVector[T]. Anything else -- a call's
#               result, a List element, a captured binding, a module
#               binding -- would mutate a header nothing keeps (a lost
#               update) or one some other place owns:
#               MUTABLE-VECTOR-RECEIVER. The bindings at the root of a
#               receiver path are the *place roots*.
#   captures    a nested function may not refer to a place root: it would
#               observe (and could not mutate) a binding its enclosing
#               function changes (MUTABLE-VECTOR-CAPTURE). Bindings stay
#               bindings: no source construct rebinds one.
#
# and, for vector-bearing values of *unrestricted* type (an affine vector is
# never copied -- ordinary affinity moves it, hir/affine.tcl), the
# elaboration (Elaborate, after hir::check, before every backend) writes out
# the logical copies as `mutable_vector#share(VALUE, "DESCRIPTOR")` -- a new
# header over the same backing (core/mutvec.tcl), O(1):
#
#   read-out    a value use of a place path (anything but a vector
#               operation's receiver, a field projection continuing the path,
#               a discarded statement, or the function's result) is shared:
#               what leaves the place is a logical copy, so the place may
#               later mutate its own header. A function's result (its final
#               value, a `return`'s value) moves its own place's header out
#               instead: the place dies with the invocation, and no other
#               place ever got that header (every other value use is a
#               read-out, and no nested function may refer to a place root);
#   entry       a place root's initial value is shared unless it is fresh (a
#               from_list result, a share, a struct literal of fresh fields,
#               a call of a function whose every result is fresh -- one of
#               these, or a place root of its own: FreshFunctions): a local
#               binding's value, a parameter on entry, a loop variable per
#               iteration, a context installation's value.
#
# A share descriptor ("h" a vector header; "s"N"."(SLOT"."D)*N a struct whose
# listed slots are shared) is type-directed through struct fields only: a
# vector inside a List is never a place (List elements are immutable), so it
# is never mutated in place and needs no copy until something extracts it
# into a place -- whose entry shares it.
#
# The other elaborations: a loop over an unrestricted vector iterates an
# immutable snapshot (`mutable_vector#to_list`), while a loop over an affine
# vector consumes it (hir/affine.tcl: the domain moves into the loop and each
# iteration takes the first element out); `clear` and `swap` of an affine
# vector carry the element drop descriptor (`mutable_vector#clear_drop`,
# `#swap_drop`), so that the elements a clear removes, and the replacement a
# failed swap was given, are released by the static drop glue.
#
# Nothing of this exists at run time beyond the headers themselves: no owner,
# no moved flag, no ownership count (the backing's shared count is the
# copy-on-write implementation detail of the native runtime).

namespace eval hir::mutvec {
    # The vector operations: receiver-taking natives and what they do to it.
    variable ops [dict create \
        mutable_vector::length      observe \
        mutable_vector::empty?      observe \
        mutable_vector::at          observe \
        mutable_vector#to_list      observe \
        mutable_vector::push        mutate \
        mutable_vector::pop         mutate \
        mutable_vector::take        mutate \
        mutable_vector::swap        mutate \
        mutable_vector::clear       mutate \
        mutable_vector#take_front   mutate \
        mutable_vector#clear_drop   mutate \
        mutable_vector#swap_drop    mutate]
    # The function blocks whose every result is fresh (FreshFunctions), for
    # the elaboration under way.
    variable freshFunctions [dict create]
}

proc hir::mutvec::ShareNative {} { return mutable_vector#share }
proc hir::mutvec::ConsumeNative {} { return mutable_vector#consume }
proc hir::mutvec::ToListNative {} { return mutable_vector#to_list }

# The vector operation call E is (observe | mutate), or "".
proc hir::mutvec::OpKind {hir e} {
    variable ops
    set name [hir::affine::NativeName $hir $e]
    if {$name ne "" && [dict exists $ops $name]} {
        return [dict get $ops $name]
    }
    return ""
}

# 1 if any interned type of HIR mentions a MutableVector: a program without
# one pays nothing for this file.
proc hir::mutvec::Used {hir} {
    dict for {t type} [dict get $hir types] {
        if {[string first mutvec $type] >= 0 || [string first mutable_vector $type] >= 0} {
            return 1
        }
    }
    return 0
}

# The place path of receiver expression E: {BINDING {FIELD...}} (a reference
# with zero or more field projections on it), or "" when E is not one.
proc hir::mutvec::Path {hir e} {
    set fields {}
    while {[dict get $hir exprs $e kind] eq "project"} {
        set fields [linsert $fields 0 [dict get $hir exprs $e name]]
        set e [dict get $hir exprs $e receiver]
    }
    if {[dict get $hir exprs $e kind] ne "ref" || [dict get $hir exprs $e binding] eq ""} {
        return ""
    }
    return [list [dict get $hir exprs $e binding] $fields]
}

# The place path text of call E's receiver for HIR text (`b17`,
# `b17.events`), or "".
proc hir::mutvec::PlaceText {hir e} {
    if {[OpKind $hir $e] ne "mutate"} {
        return ""
    }
    set path [Path $hir [lindex [dict get $hir exprs $e args] 0]]
    if {$path eq ""} {
        return ""
    }
    return [join [concat [lindex $path 0] [lindex $path 1]] .]
}

# 1 if binding B's value is a context parameter's load (CONTEXTS.md): the
# place is the installed context itself.
proc hir::mutvec::IsContextParam {hir b} {
    set by [dict get $hir bindings $b declaredBy]
    return [expr {$by ne "" && [dict exists $hir exprs $by]
        && [hir::contexts::isLoad $hir [dict get $hir exprs $by value]]}]
}

# ---------------------------------------------------------------------------
# Verification (hir::check): receivers and captures

proc hir::mutvec::verify {hirVar} {
    upvar 1 $hirVar hir
    dict set hir mutvec [dict create roots {}]
    if {![Used $hir]} {
        return
    }
    set roots [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
        if {[OpKind $hir $e] ne "mutate"} continue
        set receiver [lindex [dict get $node args] 0]
        if {$receiver eq ""} continue
        set problem [ReceiverProblem $hir $e $receiver]
        if {$problem ne ""} {
            hir::Diagnose hir MUTABLE-VECTOR-RECEIVER $problem $receiver
            continue
        }
        dict set roots [lindex [Path $hir $receiver] 0] 1
    }
    # A nested function may not refer to a place root.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || ![dict exists $roots [dict get $node binding]]} continue
        set b [dict get $node binding]
        set refScope [dict get $node scope]
        set bindingScope [dict get $hir bindings $b scope]
        if {[dict get $hir scopes $refScope invocation] ne [dict get $hir scopes $bindingScope invocation]} {
            hir::Diagnose hir MUTABLE-VECTOR-CAPTURE \
                "`[dict get $node name]` is a MutableVector place (its function mutates it in place), which a nested function cannot capture: the nested function would observe a binding that changes, and a vector is a value, not a shared reference (pass it as an argument: the callee gets its own logical copy)" $e
        }
    }
    dict set hir mutvec roots [lsort -dictionary [dict keys $roots]]
}

# Why receiver R of mutating call E is not a place, or "".
proc hir::mutvec::ReceiverProblem {hir e r} {
    set op [hir::affine::NativeName $hir $e]
    set what "the receiver of $op"
    set path [Path $hir $r]
    if {$path eq ""} {
        return "$what is not a place: it is a temporary value, so the updated vector would be lost (a MutableVector is a value; bind it to a name, mutate the name, and use the name afterwards)"
    }
    set type [hir::typeOf $hir $r]
    if {![hir::types::IsMutVec $type] && $type ne "mutvec"} {
        return "$what must be statically a MutableVector\[T\] place, not a value of type [hir::types::show $type] (a mutation needs the element type and the place it updates)"
    }
    lassign $path b fields
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] ni {local param} || [hir::isModuleBinding $hir $b]} {
        return "$what is `[dict get $binding name]`, which is not a local binding, a parameter or a context parameter of this function: only those are places a vector can be mutated in (a module binding is shared by every user of the module)"
    }
    if {[hir::affine::IsDestructureTemp $hir $b]} {
        return "$what is not a place"
    }
    set refScope [dict get $hir exprs $r scope]
    while {[dict get $hir exprs $r kind] eq "project"} {
        set r [dict get $hir exprs $r receiver]
    }
    set refScope [dict get $hir exprs $r scope]
    if {[dict get $hir scopes $refScope invocation] ne [dict get $hir scopes [dict get $binding scope] invocation]} {
        return "$what is `[dict get $binding name]`, a binding of an enclosing function: a nested function cannot mutate a vector it captured (a vector is a value; pass it in and return the result)"
    }
    return ""
}

# ---------------------------------------------------------------------------
# Share descriptors

# The share descriptor of a value of static TYPE, or "" when a logical copy
# of it shares no header: "h" an unrestricted vector, "s"N"."(SLOT"."D)*N a
# struct whose listed layout slots hold vector-bearing values. An affine
# type is never copied (it moves).
proc hir::mutvec::ShareDescriptor {type} {
    if {[hir::types::IsAffine $type]} {
        return ""
    }
    if {[hir::types::IsMutVec $type] || $type eq "mutvec"} {
        return h
    }
    if {[hir::types::IsStructLike $type]} {
        set parts {}
        set n 0
        set slot 0
        foreach name [hir::types::StructLayout $type] {
            set d [ShareDescriptor [hir::types::StructField $type $name]]
            if {$d ne ""} {
                append parts "$slot.$d"
                incr n
            }
            incr slot
        }
        if {$n == 0} {
            return ""
        }
        return "s$n.$parts"
    }
    return ""
}

# ---------------------------------------------------------------------------
# Elaboration (after hir::check; hir::buildSyntax)

proc hir::mutvec::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    variable freshFunctions
    set freshFunctions [dict create]
    if {[hir::mode $hir] ne "program" || ![Used $hir]} {
        return
    }
    set roots [expr {[dict exists $hir mutvec roots] ? [dict get $hir mutvec roots] : {}}]
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    # Affine clear/swap carry the element drop descriptor.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        set name [hir::affine::NativeName $hir $e]
        if {$name ni {mutable_vector::clear mutable_vector::swap}} continue
        set vector [hir::typeOf $hir [lindex [dict get $node args] 0]]
        if {![hir::types::IsMutVec $vector] || ![hir::types::IsAffine $vector]} continue
        set d [hir::affine::Descriptor $hir [lindex $vector 1]]
        Retarget hir $e [expr {$name eq "mutable_vector::clear" ? "mutable_vector#clear_drop" : "mutable_vector#swap_drop"}]
        dict set hir exprs $e args [concat [dict get $hir exprs $e args] [list [NewConst hir $d $e]]]
    }
    # A loop over an unrestricted vector iterates a snapshot.
    set wraps {}
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            listloop {
                set operands [list [dict get $node iterable]]
            }
            lockloop {
                set operands [lmap d [dict get $node domains] {
                    if {[dict get $d kind] ne "list"} continue
                    dict get $d iterable
                }]
            }
            default continue
        }
        foreach it $operands {
            set type [hir::typeOf $hir $it]
            if {([hir::types::IsMutVec $type] || $type eq "mutvec") && ![hir::types::IsAffine $type]} {
                lappend wraps [list $it [ToListNative] {}]
            }
        }
    }
    Apply hir $wraps
    # A context parameter is a view of the installed context, a place every
    # function sharing it may mutate: its vector-bearing paths are read out
    # by copy wherever they are read, mutated here or not.
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] eq "local" && $b ni $roots && [IsContextParam $hir $b]
                && [ShareDescriptor [hir::affine::BindingType $hir $b]] ne ""} {
            lappend roots $b
        }
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    set rootSet [dict create]
    foreach b $roots {
        dict set rootSet $b 1
    }
    set freshFunctions [FreshFunctions $hir $parent $blocks $rootSet]
    if {$roots eq {}} {
        Installations hir
        set freshFunctions [dict create]
        return
    }
    # Read-outs.
    set wraps {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ni {ref project} || ![dict get $node reachable]} continue
        set path [Path $hir $e]
        if {$path eq "" || ![dict exists $rootSet [lindex $path 0]]} continue
        set d [ShareDescriptor [hir::typeOf $hir $e]]
        if {$d eq "" || ![dict exists $parent $e]} continue
        lassign [dict get $parent $e] p role
        if {$role eq "seq 0" || $role eq "callee"} continue
        if {[OwnResult $hir $parent $e [lindex $path 0]]} {
            # The function's result moves its own place's header out.
            continue
        }
        if {$p ne ""} {
            set pnode [dict get $hir exprs $p]
            if {[dict get $pnode kind] eq "project"} continue
            if {[dict get $pnode kind] eq "call" && [OpKind $hir $p] ne ""
                    && [lindex [dict get $pnode args] 0] eq $e} continue
            if {[dict get $pnode kind] eq "bind" && [dict get $pnode binding] in $roots} {
                # The entry share below covers it.
                continue
            }
        }
        lappend wraps [list $e [ShareNative] $d]
    }
    Apply hir $wraps
    # Entries.
    set wraps {}
    foreach b $roots {
        set binding [dict get $hir bindings $b]
        set d [ShareDescriptor [hir::affine::BindingType $hir $b]]
        if {$d eq ""} continue
        if {[dict get $binding kind] eq "local"} {
            if {[IsContextParam $hir $b]} continue
            set by [dict get $binding declaredBy]
            if {$by eq "" || ![dict exists $hir exprs $by]} continue
            set value [dict get $hir exprs $by value]
            if {![Fresh $hir $value]} {
                lappend wraps [list $value [ShareNative] $d]
            }
        } else {
            EntryRename hir $b $d
        }
    }
    Apply hir $wraps
    Installations hir
    set freshFunctions [dict create]
}

# Context installations: the installed value is the entry of the context's
# places (a context parameter's field paths).
proc hir::mutvec::Installations {hirVar} {
    upvar 1 $hirVar hir
    set wraps {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![hir::contexts::isInstall $hir $e]} continue
        set value [lindex [dict get $node args] 0]
        if {$value eq ""} continue
        set d [ShareDescriptor [hir::typeOf $hir $value]]
        if {$d ne "" && ![Fresh $hir $value]} {
            lappend wraps [list $value [ShareNative] $d]
        }
    }
    Apply hir $wraps
}

# 1 if the value of E is a vector-bearing value nothing else refers to: a
# new vector, a logical copy, or a struct literal of such.
proc hir::mutvec::Fresh {hir e} {
    variable freshFunctions
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        call {
            if {[hir::affine::NativeName $hir $e] in [list mutable_vector::from_list [ShareNative]]} {
                return 1
            }
            set target [hir::contexts::Callee $hir $e]
            return [expr {$target ne "" && [dict exists $freshFunctions $target]}]
        }
        struct {
            foreach f [dict get $node fields] {
                set type [hir::typeOf $hir $f]
                if {([ShareDescriptor $type] ne "" || [MayHoldVector $type]) && ![Fresh $hir $f]} {
                    return 0
                }
            }
            return 1
        }
    }
    return 0
}

# 1 if E is in result position (Results) of the function whose body it is
# in, and ROOT -- the place root of E's path -- is a local or parameter of
# that function (not a context parameter: the installed context outlives
# the call). Returning E then moves the place's header out of a place that
# dies with the invocation.
proc hir::mutvec::OwnResult {hir parent e root} {
    if {[IsContextParam $hir $root] || ![IsResult $hir $parent $e]} {
        return 0
    }
    set bindingScope [dict get $hir bindings $root scope]
    set scope [dict get $hir exprs $e scope]
    return [expr {[dict get $hir scopes $bindingScope invocation] eq [dict get $hir scopes $scope invocation]}]
}

# 1 if E's value is the result of the function whose body it is in: the
# body's final statement or a `return`'s value, directly or as the final
# statement of a branch of an `if` that is.
proc hir::mutvec::IsResult {hir parent e} {
    set x $e
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} {
            return 0
        }
        lassign [dict get $parent $x] p role
        if {$p eq ""} {
            return 0
        }
        switch -- [dict get $hir exprs $p kind] {
            return {
                return 1
            }
            block {
                return [expr {$role eq "seq 1"}]
            }
            if {
                if {$role ne "seq 1"} {
                    return 0
                }
                set x $p
            }
            default {
                return 0
            }
        }
    }
    return 0
}

# The expressions whose value function block F returns (IsResult): its
# body's final statement and every `return` value of its own invocation,
# each `if` among them replaced by its branches' final statements.
proc hir::mutvec::Results {hir f} {
    set body [dict get $hir exprs $f body]
    set work {}
    if {$body ne {}} {
        lappend work [lindex $body end]
    }
    set stack [list {*}$body]
    while {$stack ne {}} {
        set x [lindex $stack end]
        set stack [lrange $stack 0 end-1]
        set node [dict get $hir exprs $x]
        if {[dict get $node kind] eq "block"} continue
        if {[dict get $node kind] eq "return" && [dict exists $node value] && [dict get $node value] ne ""} {
            lappend work [dict get $node value]
        }
        lappend stack {*}[hir::children $hir $x]
    }
    set results {}
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        set node [dict get $hir exprs $x]
        switch -- [dict get $node kind] {
            if {
                foreach field {thenBody elseBody} {
                    if {[dict get $node $field] ne {}} {
                        lappend work [lindex [dict get $node $field] end]
                    }
                }
            }
            return {
                # (its value is among the work already)
            }
            default {
                lappend results $x
            }
        }
    }
    return $results
}

# 1 if a value of static TYPE may be, or hold in a struct field, a
# MutableVector header: TYPE is one, or is imprecise where one could be --
# `any`, an untyped (generic) position, a trait view, a struct field of such
# a type. A generic function's own body is typed this way (its instances
# are not), so `fn same(x): x` may return the vector it was given. A List,
# set or array element, a Result payload or a callable is never a place
# (extracting one into a place is an entry, which copies): those do not
# count.
proc hir::mutvec::MayHoldVector {type {seen {}}} {
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[MayHoldVector $t $seen]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$id in $seen} {
            return 0
        }
        foreach {name t} [hir::structs::fieldTypes $id] {
            if {[MayHoldVector $t [concat $seen [list $id]]]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsMutVec $type]} {
        return 1
    }
    return [expr {[lindex $type 0] ni {int str bool unit UnicodeChar never list immutableSet mutarray block native fn coroutine result}}]
}

# The function blocks of BLOCKS whose every result (Results) cannot hold a
# vector (MayHoldVector), or is fresh: a new vector, a share, a struct
# literal of fresh fields, a call of such a function, or a place path from a
# place root (ROOTSET) of the function's own -- moved out, not shared
# (OwnResult). The
# greatest such set: a recursive call is fresh when every result of the
# recursion is (each value it can return traces back to a fresh one).
proc hir::mutvec::FreshFunctions {hir parent blocks rootSet} {
    variable freshFunctions
    set freshFunctions [dict create]
    foreach f $blocks {
        dict set freshFunctions $f [Results $hir $f]
    }
    set changed 1
    while {$changed} {
        set changed 0
        dict for {f results} $freshFunctions {
            foreach x $results {
                set type [hir::typeOf $hir $x]
                if {[Fresh $hir $x] || ([ShareDescriptor $type] eq "" && ![MayHoldVector $type])} continue
                set path [expr {[dict get $hir exprs $x kind] in {ref project} ? [Path $hir $x] : ""}]
                if {$path ne "" && [dict exists $rootSet [lindex $path 0]] && [OwnResult $hir $parent $x [lindex $path 0]]} continue
                dict unset freshFunctions $f
                set changed 1
                break
            }
        }
    }
    return $freshFunctions
}

# Applies WRAPS ({EXPR NATIVE DESCRIPTOR} triples): each EXPR replaced, in its
# parent, by a call of NATIVE on it (and the descriptor String, if any).
proc hir::mutvec::Apply {hirVar wraps} {
    upvar 1 $hirVar hir
    if {$wraps eq {}} {
        return
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    foreach w $wraps {
        lassign $w e native d
        set args [list $e]
        if {$d ne ""} {
            lappend args [NewConst hir $d $e]
        }
        set type [hir::typeOf $hir $e]
        if {$native eq [ToListNative]} {
            set type [expr {[hir::types::IsMutVec $type] ? [hir::types::MakeList [lindex $type 1]] : "list"}]
        }
        set call [NewCall hir $native $args $type $e]
        set p [lindex [dict get $parent $e] 0]
        if {$p eq ""} {
            dict set hir roots [lmap r [dict get $hir roots] {expr {$r eq $e ? $call : $r}}]
        } else {
            ReplaceChild hir $p $e $call
        }
    }
}

# The binding of root native NAME.
proc hir::mutvec::NativeBinding {hir name} {
    set root [dict get $hir scopes [dict get $hir top] parent]
    return [dict get $hir scopes $root names $name]
}

# A new const String node DESCRIPTOR, placed like expression AT.
proc hir::mutvec::NewConst {hirVar text at} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $at]
    set c [hir::NewId hir expr]
    set origin [dict get $node origin]
    set literal [hir::syntax::constNode $origin str $text]
    dict set hir exprs $c [dict merge $literal [dict create id $c \
        scope [dict get $node scope] type [hir::types::intern hir str] reachable [dict get $node reachable] \
        value [core::value::str $text]]]
    return $c
}

# A new call of root native NAME on ARGS, of static TYPE, placed like AT.
proc hir::mutvec::NewCall {hirVar name args type at} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $at]
    set b [NativeBinding $hir $name]
    set y [dict get $hir bindings $b symbol]
    set r [hir::NewId hir expr]
    dict set hir exprs $r [dict create id $r kind ref origin [dict get $node origin] \
        scope [dict get $node scope] type [hir::types::intern hir [list native $name]] \
        reachable [dict get $node reachable] name $name binding $b init yes]
    set c [hir::NewId hir expr]
    dict set hir exprs $c [dict create id $c kind call origin [dict get $node origin] \
        scope [dict get $node scope] type [hir::types::intern hir $type] \
        reachable [dict get $node reachable] callee $r args $args target [list native $y] known ""]
    return $c
}

# Makes call E a call of root native NAME (same arguments).
proc hir::mutvec::Retarget {hirVar e name} {
    upvar 1 $hirVar hir
    set b [NativeBinding $hir $name]
    set y [dict get $hir bindings $b symbol]
    set callee [dict get $hir exprs $e callee]
    dict set hir exprs $callee name $name
    dict set hir exprs $callee binding $b
    dict set hir exprs $callee type [hir::types::intern hir [list native $name]]
    dict set hir exprs $e target [list native $y]
    if {[dict exists $hir semantic instances]} {
        dict for {id inst} [dict get $hir semantic instances] {
            if {[dict exists $inst snapshot exprs $e]} {
                dict set hir semantic instances $id snapshot exprs $e target [list native $y]
            }
            if {[dict exists $inst snapshot exprs $callee type]} {
                dict set hir semantic instances $id snapshot exprs $callee type [list native $name]
            }
        }
    }
}

# Replaces child OLD of expression P by NEW.
proc hir::mutvec::ReplaceChild {hirVar p old new} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $p]
    foreach field {value callee condition iterable start end receiver call} {
        if {[dict exists $node $field] && [dict get $node $field] eq $old} {
            dict set hir exprs $p $field $new
            return
        }
    }
    foreach field {args fields body thenBody elseBody} {
        if {[dict exists $node $field]} {
            set list [dict get $node $field]
            set i [lsearch -exact $list $old]
            if {$i >= 0} {
                dict set hir exprs $p $field [lreplace $list $i $i $new]
                return
            }
        }
    }
    if {[dict exists $node handlerBodies]} {
        set bodies [dict get $node handlerBodies]
        set k 0
        foreach body $bodies {
            set i [lsearch -exact $body $old]
            if {$i >= 0} {
                lset bodies $k [lreplace $body $i $i $new]
                dict set hir exprs $p handlerBodies $bodies
                return
            }
            incr k
        }
    }
    if {[dict exists $node domains]} {
        set domains [dict get $node domains]
        set k 0
        foreach d $domains {
            foreach field {iterable start end} {
                if {[dict exists $d $field] && [dict get $d $field] eq $old} {
                    dict set d $field $new
                    lset domains $k $d
                    dict set hir exprs $p domains $domains
                    return
                }
            }
            incr k
        }
    }
    error "hir::mutvec::ReplaceChild: $old is not a child of $p"
}

# The entry of place root B, a parameter (of a function, or a loop's
# per-iteration variable): B becomes a local bound, as the body's first
# statement, to a logical copy (share descriptor D) of a new parameter that
# takes B's place -- so the place owns the header it mutates.
proc hir::mutvec::EntryRename {hirVar b d} {
    upvar 1 $hirVar hir
    set binding [dict get $hir bindings $b]
    set s [dict get $binding scope]
    set e [dict get $hir scopes $s owner]
    if {$e eq "" || ![dict exists $hir exprs $e]} {
        return
    }
    set node [dict get $hir exprs $e]
    set name [dict get $binding name]
    # The parameter's static type (declared, or inferred), recorded on both
    # bindings: the new parameter receives it, the local keeps it.
    set type [hir::affine::BindingType $hir $b]
    set t [hir::types::intern hir $type]
    dict set binding type $t
    dict set hir bindings $b type $t
    # The new parameter.
    set p [hir::NewId hir binding]
    set pname "$name#entry"
    dict set hir bindings $p [dict merge $binding [dict create id $p name $pname kind param declaredBy ""]]
    if {[dict exists $hir bindings $p spelling]} {
        dict unset hir bindings $p spelling
    }
    dict set hir scopes $s names $pname $p
    set bindings [dict get $hir scopes $s bindings]
    set i [lsearch -exact $bindings $b]
    dict set hir scopes $s bindings [linsert $bindings $i $p]
    switch -- [dict get $node kind] {
        block {
            dict set hir exprs $e params [lmap x [dict get $node params] {expr {$x eq $b ? $p : $x}}]
        }
        listloop {
            dict set hir exprs $e elementBinding $p
        }
        lockloop {
            dict set hir exprs $e domains [lmap dom [dict get $node domains] {
                if {[dict get $dom binding] eq $b} {
                    dict set dom binding $p
                }
                set dom
            }]
        }
        default {
            return
        }
    }
    # The body's first statement: `NAME = share(NAME#entry)`.
    set body [dict get $node body]
    set at [expr {$body ne {} ? [lindex $body 0] : $e}]
    set atNode [dict get $hir exprs $at]
    set r [hir::NewId hir expr]
    dict set hir exprs $r [dict create id $r kind ref origin [dict get $atNode origin] scope $s \
        type [hir::types::intern hir $type] reachable 1 name $pname binding $p init yes]
    set c [NewCall hir [ShareNative] [list $r] $type $r]
    dict set hir exprs $c args [list $r [NewConst hir $d $r]]
    set n [hir::NewId hir expr]
    dict set hir exprs $n [dict create id $n kind bind origin [dict get $atNode origin] scope $s \
        type [hir::types::intern hir $type] reachable 1 name $name binding $b value $c duplicate 0]
    dict set hir bindings $b kind local
    dict set hir bindings $b declaredBy $n
    dict set hir exprs $e body [linsert $body 0 $n]
}

# 1 if projection P (in parent map PARENT) is a step of a vector operation's
# receiver place path: its chain of enclosing projections ends at the first
# argument of a MutableVector operation (hir/affine.tcl's Consumer).
proc hir::mutvec::InReceiverPath {hir parent p} {
    set x $p
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} {
            return 0
        }
        set q [lindex [dict get $parent $x] 0]
        if {$q eq ""} {
            return 0
        }
        set node [dict get $hir exprs $q]
        if {[dict get $node kind] eq "project" && [dict get $node receiver] eq $x} {
            set x $q
            continue
        }
        return [expr {[dict get $node kind] eq "call" && [OpKind $hir $q] ne ""
            && [lindex [dict get $node args] 0] eq $x}]
    }
    return 0
}

# 1 if E is a listloop consuming an affine MutableVector (hir/affine.tcl).
proc hir::mutvec::IsConsumingLoop {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "listloop"} {
        return 0
    }
    set iterable [dict get $node iterable]
    if {[hir::affine::NativeName $hir $iterable] eq [ConsumeNative]} {
        # Marked in Core IR (hir/lower.tcl): HIR built from it lost the
        # element type that made the loop consuming.
        return 1
    }
    set type [hir::typeOf $hir $iterable]
    return [expr {[hir::types::IsMutVec $type] && [hir::types::IsAffine $type]}]
}

# The descriptor String argument of call E if E is an internal operation the
# elaboration gave one (mutable_vector#share, #clear_drop, #swap_drop), else
# {}: a synthesized const, never a written literal (hir/warnings.tcl).
proc hir::mutvec::DescriptorArgs {hir e} {
    if {[dict get $hir exprs $e kind] ne "call"} {
        return {}
    }
    switch -- [hir::affine::NativeName $hir $e] {
        mutable_vector#share - mutable_vector#clear_drop {
            return [lrange [dict get $hir exprs $e args] 1 1]
        }
        mutable_vector#swap_drop {
            return [lrange [dict get $hir exprs $e args] 3 3]
        }
    }
    return {}
}

# The HIR text evidence of expression E (hir/format.tcl; derived facts, which
# hir/read.tcl accepts and the analyses recompute):
#
#   vector=observe            a non-consuming vector operation (length,
#                             empty?, at, the snapshot of a loop)
#   vector=mutate place=PATH  a mutation of the receiver place PATH (its root
#                             binding, then its fields: b17.events)
#   move-out                  the operation moves an affine element out of
#                             the vector (pop, take, swap's displaced one)
#   consuming                 a loop consuming an affine vector
#
# An affine element moved in is its argument's `move` flag; a drop is the
# `release=`/`exit-release=`/`error-release=` of the owner.
proc hir::mutvec::Evidence {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        call {
            set kind [OpKind $hir $e]
            if {$kind eq ""} {
                return {}
            }
            set flags [list vector=$kind]
            set place [PlaceText $hir $e]
            if {$place ne ""} {
                lappend flags place=$place
            }
            if {[hir::affine::NativeName $hir $e] in {mutable_vector::pop mutable_vector::take mutable_vector::swap
                    mutable_vector#swap_drop mutable_vector#take_front}
                    && [hir::types::IsAffine [hir::typeOf $hir $e]]} {
                lappend flags move-out
            }
            return $flags
        }
        listloop {
            if {[IsConsumingLoop $hir $e]} {
                return {consuming}
            }
        }
    }
    return {}
}
