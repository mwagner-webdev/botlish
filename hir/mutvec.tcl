# mutvec.tcl -- the places and logical copies of the mutable collections:
# MutableVector[T] (MUTABLE-VECTOR.md) and MutableArray[T] (MUTABLE-ARRAY.md).
#
# Both are mutable VALUES -- a growable one and its fixed-length sibling --
# with one runtime representation (core/mutvec.tcl and core/mutarray.tcl;
# natively MutVecObj and MutArrayObj): a *header* -- the identity of one
# logical value, mutated in place by push/pop/take/swap/clear or set/swap/
# copy -- over a copy-on-write *backing*. A mutation therefore never stores a
# new value back into its receiver: the receiver must be a *place* (a
# binding, or a struct field reached from one) that owns its header, and the
# compiler keeps every place's header owned by that place alone. Everything
# below is the same for the two kinds; only the operations differ (the `ops`
# table), and "collection" means either:
#
#   receivers   the first argument of a mutating operation must be a place
#               path: a reference to a local, parameter or context parameter
#               of the same function, or a chain of field projections from
#               one (`v.push(x)`, `state.queue.pop()`, `io.output.push(t)`),
#               whose binding's own static type makes the path a
#               MutableVector[T] or MutableArray[T] (a binding of type `any`
#               narrowed by a kind test is not a place: bind the narrowed
#               value to a name). Anything else -- a call's result, a List
#               element, a captured binding, a module binding -- would mutate
#               a header nothing keeps (a lost update) or one some other
#               place owns: MUTABLE-PLACE-RECEIVER. The bindings at the root
#               of a receiver path are the *place roots*.
#   captures    a nested function may not refer to a place root: it would
#               observe (and could not mutate) a binding its enclosing
#               function changes (MUTABLE-PLACE-CAPTURE). Bindings stay
#               bindings: no source construct rebinds one.
#
# and, for collection-bearing values of *unrestricted* type (an affine
# collection is never copied -- ordinary affinity moves it, hir/affine.tcl),
# the elaboration (Elaborate, after hir::check, before every backend) writes
# out the logical copies as `mutable_vector#share(VALUE, "DESCRIPTOR")` -- a
# new header over the same backing (core/mutvec.tcl, core/mutarray.tcl),
# O(1):
#
#   read-out    a value use of a place path (anything but a collection
#               operation's receiver, an argument a native only observes --
#               its ownership role says so, core/native.tcl -- a field
#               projection continuing the path, a discarded statement, or
#               the function's result) is shared:
#               what leaves the place is a logical copy, so the place may
#               later mutate its own header. A function's result (its final
#               value, a `return`'s value) moves its own place's header out
#               instead: the place dies with the invocation, and no other
#               place ever got that header (every other value use is a
#               read-out, and no nested function may refer to a place root);
#   entry       a place root's initial value is shared unless it is fresh (a
#               constructor's result, a share, a struct literal of fresh fields,
#               a call of a function whose every result is fresh -- one of
#               these, or a place root of its own: FreshFunctions): a local
#               binding's value, a parameter on entry, a loop variable per
#               iteration, a handler's payload binding, a context
#               installation's value.
#
# A share descriptor ("h" a collection header; "s"N"."(SLOT"."D)*N a struct
# whose listed slots are shared) is type-directed through struct fields only:
# a collection inside a List, an array or a vector is never a place (an
# element is never mutated in place), so it needs no copy until something
# extracts it into a place -- whose entry shares it.
#
# The other elaborations: a loop over an unrestricted collection iterates an
# immutable snapshot (`#to_list`), while a loop over an affine one consumes
# it (hir/affine.tcl: the domain moves into the loop and each iteration takes
# the first element out); the operations that drop affine elements carry the
# element drop descriptor -- a vector's `clear` and `swap`
# (`mutable_vector#clear_drop`, `#swap_drop`), an array's `swap`, `set` and
# `generate` (`mutable_array#swap_drop`, `#set_drop`, `#generate_drop`) -- so
# that the elements a clear removes or a set displaces, the replacement a
# failed operation was given and the elements a failed construction made are
# released by the static drop glue.
#
# Nothing of this exists at run time beyond the headers themselves: no owner,
# no moved flag, no ownership count (the backing's shared count is the
# copy-on-write implementation detail of the native runtime).

namespace eval hir::mutvec {
    # The collection operations, by native: what each does to its receiver
    # (observe it, or mutate its header in place) -- derived from the
    # registry (OpKind), cached.
    variable opKinds [dict create]
    # The function blocks whose every result is fresh (FreshFunctions), for
    # the elaboration under way.
    variable freshFunctions [dict create]
    # The parent map of the elaboration under way's current HIR.
    variable currentParent {}
    # The named structs ShareDescriptor is inside of, outermost first.
    variable shareVisiting {}
}

proc hir::mutvec::ShareNative {} { return mutable_vector#share }
proc hir::mutvec::ConsumeNative {} { return mutable_vector#consume }
proc hir::mutvec::ToListNative {} { return mutable_vector#to_list }
# The Core IR consume mark and the snapshot of a collection of KIND (vector,
# array).
proc hir::mutvec::ConsumeNativeOf {kind} {
    return [expr {$kind eq "array" ? "mutable_array#consume" : "mutable_vector#consume"}]
}
proc hir::mutvec::ToListNativeOf {kind} {
    return [expr {$kind eq "array" ? "mutable_array#to_list" : "mutable_vector#to_list"}]
}

# The collection kind of static TYPE: vector (MutableVector[T] or the bare
# kind), array (MutableArray[T] or the raw kind), or "".
proc hir::mutvec::Kind {type} {
    if {[hir::types::IsMutVec $type] || $type eq "mutvec"} {
        return vector
    }
    if {[hir::types::IsMutArray $type] || $type eq "mutarray"} {
        return array
    }
    return ""
}

# The source-level name of collection KIND, for diagnostics.
proc hir::mutvec::KindName {kind} {
    return [expr {$kind eq "array" ? "MutableArray" : "MutableVector"}]
}

# The collection operation call E is (observe | mutate), or "": a native
# whose first parameter is a MutableVector or MutableArray receiver, read
# from its registration (core/native.tcl), never its name -- its receiver's
# ownership role `place` mutates the header in place, `observe` and
# `copy-out` read it; a receiver it consumes (`move`, a consuming loop's
# domain) is not an operation on a place.
proc hir::mutvec::OpKind {hir e} {
    set name [hir::affine::NativeName $hir $e]
    if {$name eq ""} {
        return ""
    }
    return [NativeOpKind $name]
}

# The mutable collection native NAME operates on, by its registration (never
# its name, STD-NAMESPACE.md): "vector" or "array" when its receiver -- or,
# for a constructor, its result -- is a MutableVector or a MutableArray, else
# "".
proc hir::mutvec::CollectionOf {name} {
    set meta [core::native::metadata $name]
    foreach type [list [lindex [dict get $meta paramTypes] 0] [dict get $meta resultType]] {
        switch -- [core::type::base $type] {
            mutvec { return vector }
            mutarray { return array }
        }
    }
    return ""
}

proc hir::mutvec::NativeOpKind {name} {
    variable opKinds
    if {![dict exists $opKinds $name]} {
        set kind ""
        set receiver [lindex [dict get [core::native::metadata $name] paramTypes] 0]
        if {$receiver ne "" && [core::type::base $receiver] in {mutvec mutarray}} {
            switch -- [core::native::ownershipRole $name 0] {
                place { set kind mutate }
                observe - copy-out { set kind observe }
            }
        }
        dict set opKinds $name $kind
    }
    return [dict get $opKinds $name]
}

# 1 if native NAME constructs a new collection header nothing else refers
# to: its registration allocates one (-runtime mutvec-alloc or
# mutarray-alloc) and its result is a MutableVector or MutableArray.
proc hir::mutvec::Constructor {name} {
    if {$name eq ""} {
        return 0
    }
    set meta [core::native::metadata $name]
    return [expr {[core::type::base [dict get $meta resultType]] in {mutvec mutarray}
        && ("mutvec-alloc" in [dict get $meta runtime] || "mutarray-alloc" in [dict get $meta runtime])}]
}

# 1 if any interned type of HIR mentions a mutable collection: a program
# without one pays nothing for this file.
proc hir::mutvec::Used {hir} {
    dict for {t type} [dict get $hir types] {
        if {[string first mutvec $type] >= 0 || [string first mutable_vector $type] >= 0
                || [string first mutarray $type] >= 0 || [string first mutable_array $type] >= 0} {
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
# Place parameters (PLACE-PARAMETERS.md)
#
# A function's parameter declared `place m: T` is the caller's place itself:
# the caller passes a place path of its own (a receiver, exactly as a
# collection operation's), no copy is made on either side, and every
# mutation the function makes through `m` -- a collection operation on a
# path of it, or a call passing it (or a path of it) on to another place
# parameter -- is the caller's place's. To the caller the call is a
# mutation of that place; to the function the parameter is a place it does
# not own, like a context parameter's: never moved out, never copied on
# entry, read out by copy, returned by copy. The type is statically a
# collection or a struct whose fields hold collections (ShareDescriptor):
# only a collection's header changes in place, so the mutations a place
# parameter can make are exactly the headers its type holds. Nothing of
# this exists at run time: a header was always passed by reference, and the
# copies this file writes are what made a parameter the callee's own.

# The indices of the place parameters of the function call E calls
# directly (its target block's `places`), or {}.
proc hir::mutvec::PlaceIndices {hir e} {
    lassign [dict get $hir exprs $e target] kind block
    if {$kind ne "block" || ![dict exists $hir exprs $block]} {
        return {}
    }
    return [dict getdef $hir exprs $block places {}]
}

# 1 if binding B is a place parameter of its function.
proc hir::mutvec::IsPlaceParam {hir b} {
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] ne "param"} {
        return 0
    }
    set f [dict get $hir scopes [dict get $binding scope] owner]
    if {$f eq "" || ![dict exists $hir exprs $f] || [dict get $hir exprs $f kind] ne "block"} {
        return 0
    }
    set places [dict getdef $hir exprs $f places {}]
    return [expr {$places ne {} && [lsearch -exact [dict get $hir exprs $f params] $b] in $places}]
}

# The block with place parameters binding B names -- a function binding,
# bound once to a block that declares some (PlaceIndices) -- or "".
proc hir::mutvec::PlaceFunctionOf {hir b} {
    if {$b eq "" || ![dict exists $hir bindings $b]} {
        return ""
    }
    set by [dict get $hir bindings $b declaredBy]
    if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"} {
        return ""
    }
    set value [dict get $hir exprs $by value]
    if {[dict get $hir exprs $value kind] ne "block" || [dict getdef $hir exprs $value places {}] eq {}} {
        return ""
    }
    return $value
}

# 1 if place paths P and Q ({BINDING {FIELD...}}) may hold one header: the
# same binding, and one path a prefix of the other (a struct and a field of
# it, or the same field).
proc hir::mutvec::Overlap {p q} {
    lassign $p a fa
    lassign $q b fb
    if {$a ne $b} {
        return 0
    }
    set n [expr {min([llength $fa], [llength $fb])}]
    return [expr {[lrange $fa 0 [expr {$n - 1}]] eq [lrange $fb 0 [expr {$n - 1}]]}]
}

# The source name of function block F, for diagnostics.
proc hir::mutvec::FunctionName {hir f} {
    return [hir::signatures::Name $hir $f]
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
    set callees [dict create]
    # A place parameter's declared type holds what the function mutates: a
    # collection, or a struct holding collections. Every one is a place root
    # of its function.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || [dict getdef $node places {}] eq {}} continue
        foreach index [dict get $node places] {
            set b [lindex [dict get $node params] $index]
            set problem [PlaceParamProblem $hir $e $index]
            if {$problem ne ""} {
                hir::DiagnoseAt hir TYPE $problem $e [dict get $hir bindings $b origin]
                continue
            }
            dict set roots $b place
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        dict set callees [dict get $node callee] 1
        if {![dict get $node reachable]} continue
        set places [PlaceIndices $hir $e]
        if {$places ne {}} {
            # A call of a function with place parameters mutates the place
            # each one is given, which is a place path of this function's,
            # given once.
            set given {}
            foreach index $places {
                set arg [lindex [dict get $node args] $index]
                if {$arg eq ""} continue
                set problem [PlaceArgumentProblem $hir $e $index $arg]
                if {$problem eq ""} {
                    set path [Path $hir $arg]
                    foreach {q other} $given {
                        if {[Overlap $path $q]} {
                            set problem "[PlaceArgumentWhat $hir $e $index] is `[PathText $hir $path]`, which the same call also gives [PlaceArgumentWhat $hir $e $other 0] as `[PathText $hir $q]`: one place can be updated through one parameter only (two parameters naming it would each see the other's updates, as if one were a reference)"
                            break
                        }
                    }
                }
                if {$problem ne ""} {
                    # The call's own problem: its callee's place parameter is
                    # given no place of this function (hir::CheckingCall).
                    hir::CheckingCall $e {hir::Diagnose hir MUTABLE-PLACE-RECEIVER $problem $arg}
                    continue
                }
                lappend given $path $index
                dict set roots [lindex $path 0] place
            }
            continue
        }
        if {[hir::affine::ElementPlace $hir $e]} {
            # An element place (core/native.tcl's elementPlace) reaches into
            # the installed context's storage: its receiver is a context
            # place (hir::affine::ContextPlace), never a collection of the
            # function's own, whose elements are read with at and moved
            # with take, pop or swap.
            set receiver [lindex [dict get $node args] 0]
            if {$receiver ne "" && ![hir::affine::ContextPlace $hir $receiver]} {
                set native [hir::affine::NativeName $hir $e]
                hir::CheckingCall $e {hir::Diagnose hir MUTABLE-PLACE-RECEIVER \
                    "the receiver of $native is not a place of an installed context: an element place reaches a collection the installed context owns, through a context parameter (`context c: T`, then `c.member.[namespace tail $native](i)`); read an element of any other collection with at, and move one out with take, pop or swap" $receiver}
            }
            continue
        }
        if {[OpKind $hir $e] ne "mutate"} continue
        set receiver [lindex [dict get $node args] 0]
        if {$receiver eq ""} continue
        set problem [ReceiverProblem $hir $e $receiver]
        if {$problem ne ""} {
            # The call's own problem: its mutating callee is given no place.
            hir::CheckingCall $e {hir::Diagnose hir MUTABLE-PLACE-RECEIVER $problem $receiver}
            continue
        }
        set root [lindex [Path $hir $receiver] 0]
        if {![dict exists $roots $root]} {
            dict set roots $root [Kind [hir::typeOf $hir $receiver]]
        }
    }
    # A mutating operation is only ever called: as a value, it would mutate
    # whatever header a call through the value passes it -- a place no
    # receiver check sees, whose copies and captures were never written out
    # for it -- so a reference to one is a callee or nothing. The same holds
    # for a function with a place parameter.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || ![dict get $node reachable] || [dict exists $callees $e]} continue
        set problem [OperationValueProblem $hir $e]
        if {$problem ne ""} {
            hir::Diagnose hir MUTABLE-PLACE-RECEIVER $problem $e
        }
    }
    # A nested function may not refer to a place root.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || ![dict exists $roots [dict get $node binding]]} continue
        set b [dict get $node binding]
        set refScope [dict get $node scope]
        set bindingScope [dict get $hir bindings $b scope]
        if {[dict get $hir scopes $refScope invocation] ne [dict get $hir scopes $bindingScope invocation]} {
            set kind [dict get $roots $b]
            if {$kind eq "place"} {
                hir::Diagnose hir MUTABLE-PLACE-CAPTURE \
                    "`[hir::semantic::RefName $hir $e]` is a place its function updates in place (a place parameter, or a place it gives to one), which a nested function cannot capture: the nested function would observe a binding that changes, and a collection is a value, not a shared reference (pass it as an argument: the callee gets its own logical copy)" $e
                continue
            }
            set what [KindName $kind]
            hir::Diagnose hir MUTABLE-PLACE-CAPTURE \
                "`[hir::semantic::RefName $hir $e]` is a $what place (its function mutates it in place), which a nested function cannot capture: the nested function would observe a binding that changes, and a $kind is a value, not a shared reference (pass it as an argument: the callee gets its own logical copy)" $e
        }
    }
    dict set hir mutvec roots [lsort -dictionary [dict keys $roots]]
}

# The text of place path PATH ({BINDING {FIELD...}}) as written.
proc hir::mutvec::PathText {hir path} {
    lassign $path b fields
    return [join [concat [list [hir::semantic::SourceName $hir $b]] $fields] .]
}

# "the argument for place parameter NAME of FUNCTION" (ARTICLE 1) or "place
# parameter NAME" (0), of call E's argument INDEX.
proc hir::mutvec::PlaceArgumentWhat {hir e index {article 1}} {
    set f [lindex [dict get $hir exprs $e target] 1]
    set b [lindex [dict get $hir exprs $f params] $index]
    set name [hir::semantic::SourceName $hir $b]
    if {!$article} {
        return "place parameter \"$name\""
    }
    return "the argument for place parameter \"$name\" of [FunctionName $hir $f]"
}

# Why the place parameter at INDEX of function block F may not be one, or
# "": its declared type must hold a mutable collection (a header a mutation
# changes in place) and be unrestricted.
proc hir::mutvec::PlaceParamProblem {hir f index} {
    set b [lindex [dict get $hir exprs $f params] $index]
    set name [hir::semantic::SourceName $hir $b]
    set type [lindex [dict getdef $hir exprs $f declaredParamTypes {}] $index]
    set what "place parameter \"$name\" of [FunctionName $hir $f]"
    if {$type eq {}} {
        return "$what needs a declared type: a place is a mutable collection, or a struct holding some, and its declaration says which"
    }
    if {[hir::types::IsAffine $type]} {
        return "$what has the affine type [hir::types::show $type]: a place parameter of an affine type is not supported (its caller would keep owning a value the function could move out of it)"
    }
    if {[ShareDescriptor $type] eq ""} {
        return "$what has the type [hir::types::show $type], which holds no mutable collection: only a MutableVector, a MutableArray or a struct whose fields hold one changes in place (pass the value as an ordinary parameter)"
    }
    return ""
}

# Why argument R (index INDEX) of call E, a call of a function whose
# parameter INDEX is a place parameter, is not a place of this function,
# or "": the same rules as a collection operation's receiver
# (ReceiverProblem), for a value whose type holds collections.
proc hir::mutvec::PlaceArgumentProblem {hir e index r} {
    set what [PlaceArgumentWhat $hir $e $index]
    set path [Path $hir $r]
    if {$path eq ""} {
        return "$what is not a place: it is a temporary value, so the update the function makes would be lost (bind the value to a name, pass the name, and use the name afterwards)"
    }
    lassign $path b fields
    set binding [dict get $hir bindings $b]
    set shown [hir::semantic::SourceName $hir $b]
    if {[dict get $binding kind] ni {local param} || [hir::isModuleBinding $hir $b]} {
        return "$what is `$shown`, which is not a local binding, a parameter or a context parameter of this function: only those are places a function can update (a module binding is shared by every user of the module)"
    }
    set pathType [hir::affine::BindingType $hir $b]
    foreach field $fields {
        if {![hir::types::IsStructLike $pathType]} {
            set pathType ""
            break
        }
        set pathType [hir::types::StructField $pathType $field]
    }
    if {$pathType eq "" || [ShareDescriptor $pathType] eq ""} {
        return "$what is `[PathText $hir $path]`, whose binding is not statically a place holding a mutable collection (its type is [hir::types::show [if {$pathType eq ""} {string cat "any"} else {set pathType}]]): only a binding of such a type owns the headers the function updates (bind the value to a name of its type first and pass that)"
    }
    if {[hir::affine::IsDestructureTemp $hir $b]} {
        return "$what is not a place"
    }
    while {[dict get $hir exprs $r kind] eq "project"} {
        set r [dict get $hir exprs $r receiver]
    }
    set refScope [dict get $hir exprs $r scope]
    if {[dict get $hir scopes $refScope invocation] ne [dict get $hir scopes [dict get $binding scope] invocation]} {
        return "$what is `$shown`, a binding of an enclosing function: a nested function cannot update a place it captured (a collection is a value; pass it in and return the result)"
    }
    return ""
}

# Why reference E, used as a value (not a call's callee), may not be one, or
# "": it denotes a collection operation that mutates its receiver in place
# (OpKind). Every guarantee of a place -- the receiver check, the copies a
# read-out or an entry gets, the capture rule -- is made at a call that
# names the operation; a call through a function value names none, so it
# would mutate the header of whatever its caller passes: a copy whose
# update is lost, or a place's own header behind its copies' back.
proc hir::mutvec::OperationValueProblem {hir e} {
    set b [dict get $hir exprs $e binding]
    set f [PlaceFunctionOf $hir $b]
    if {$f ne ""} {
        set name [FunctionName $hir $f]
        set param [hir::semantic::SourceName $hir [lindex [dict get $hir exprs $f params] [lindex [dict get $hir exprs $f places] 0]]]
        return "$name has a place parameter (\"$param\"), so it can only be called, never used as a value: a call through a function value has no argument this check can see as the caller's place, and would update whatever its caller passes -- a copy, whose update is lost, or a place's own header (call it with a place of yours, or wrap it in a function that takes the value and returns it)"
    }
    if {$b eq "" || [dict get $hir bindings $b kind] ne "root"} {
        return ""
    }
    set symbol [dict get $hir bindings $b symbol]
    if {$symbol eq "" || [dict get $hir symbols $symbol kind] ne "native"} {
        return ""
    }
    set op [dict get $hir bindings $b name]
    if {[NativeOpKind $op] ne "mutate"} {
        return ""
    }
    set meta [core::native::metadata $op]
    set receiver [lindex [dict get $meta paramTypes] 0]
    set kind [expr {[core::type::base $receiver] eq "mutarray" ? "array" : "vector"}]
    set name [KindName $kind]
    # The call on a place, spelled the way the operation can be called: a
    # nomethod operation only as a function.
    set call [expr {[dict get $meta nomethod] ? "${op}(v, ...)" : "v.[namespace tail $op](...)"}]
    return "$op mutates its receiver in place, so it can only be called, never used as a value: a call through a function value has no receiver this check can see, and would update whatever $name its caller passes -- a copy, whose update is lost, or a place's own header (call it on a place, `$call`, or wrap it in a function of your own that takes the $kind and returns it)"
}

# Why receiver R of mutating call E is not a place, or "".
proc hir::mutvec::ReceiverProblem {hir e r} {
    set op [hir::affine::NativeName $hir $e]
    set what "the receiver of $op"
    set kind vector
    if {[CollectionOf $op] eq "array"} {
        set kind array
    }
    set name [KindName $kind]
    set path [Path $hir $r]
    if {$path eq ""} {
        return "$what is not a place: it is a temporary value, so the updated $kind would be lost (a $name is a value; bind it to a name, mutate the name, and use the name afterwards)"
    }
    set type [hir::typeOf $hir $r]
    if {[Kind $type] ne $kind && ([Kind $type] ne "" || ![MayHoldVector $type])} {
        return "$what must be statically a $name\[T\] place, not a value of type [hir::types::show $type] (a mutation needs the element type and the place it updates)"
    }
    lassign $path b fields
    set binding [dict get $hir bindings $b]
    set shown [hir::semantic::SourceName $hir $b]
    if {[dict get $binding kind] ni {local param} || [hir::isModuleBinding $hir $b]} {
        return "$what is `$shown`, which is not a local binding, a parameter or a context parameter of this function: only those are places a $kind can be mutated in (a module binding is shared by every user of the module)"
    }
    set pathType [hir::affine::BindingType $hir $b]
    foreach field $fields {
        if {![hir::types::IsStructLike $pathType]} {
            set pathType ""
            break
        }
        set pathType [hir::types::StructField $pathType $field]
    }
    if {[Kind $pathType] ne $kind && ([Kind $pathType] ne "" || ![MayHoldVector $pathType])} {
        # The place is what its binding statically holds: a binding of
        # another known type cannot be one. (A binding of a type too
        # imprecise to say -- a generic function's parameter -- is a place
        # whose entry copy is dynamic: HeldDescriptor.)
        return "$what is `[join [concat [list $shown] $fields] .]`, whose binding is not statically a $name\[T\] place (its type is [hir::types::show [if {$pathType eq ""} {string cat "any"} else {set pathType}]]): only a binding of a collection type owns a header it may mutate (bind the narrowed value to a name first -- `copy = $shown` -- and mutate that)"
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
        set a [expr {[string match {[aeiou]*} $kind] ? "an" : "a"}]
        return "$what is `$shown`, a binding of an enclosing function: a nested function cannot mutate $a $kind it captured ($a $kind is a value; pass it in and return the result)"
    }
    return ""
}

# ---------------------------------------------------------------------------
# Share descriptors

# The share descriptor of a value of static TYPE, or "" when a logical copy
# of it shares no header: "h" an unrestricted collection (a vector or an
# array header), "s"N"."(SLOT"."D)*N a struct whose listed layout slots hold
# collection-bearing values. An affine collection is never copied (it
# moves); an affine struct's unrestricted collection slots are -- a struct
# holding a coroutine or a C pointer beside a MutableVector[str] moves
# whole, and its vector is still a value: the copy at a place's entry gives
# the place a header of its own, as for an unrestricted struct (the
# descriptor lists those slots only; the affine ones move with the struct).
#
# A slot whose type is too imprecise to say but may hold a header
# (MayHoldVector: `any`, a generic position, a struct of such) is listed
# with "d", a copy of whatever it holds at run time, like a whole value of
# such a type (HeldDescriptor): a copy gives every slot its own headers,
# which the last uses per path rely on (ReadsPath). A struct whose only
# such slots are imprecise has no static descriptor ("": the "d" of the
# whole value copies the same).
#
# A named struct may name itself, directly or through other structs
# (STRUCTS.md, `struct-named-recursive-declaration`). The walk goes through
# struct fields only, so a struct it meets again inside itself is one no
# finite value has -- each would hold a smaller one of the same type, without
# end -- and a descriptor is only ever applied to a value: that inner
# occurrence shares nothing. (A struct that holds itself in a List, an array
# or a vector is not walked into there: an element is never a place.)
proc hir::mutvec::ShareDescriptor {type} {
    if {[hir::types::IsAffine $type] && ![hir::types::IsStructLike $type]} {
        return ""
    }
    if {[Kind $type] ne ""} {
        return h
    }
    if {[hir::types::IsStructLike $type]} {
        variable shareVisiting
        if {[hir::types::IsNamedStruct $type]} {
            set id [lindex $type 1]
        } else {
            set id ""
        }
        if {$id ne ""} {
            if {$id in $shareVisiting} {
                return ""
            }
            lappend shareVisiting $id
        }
        try {
            set parts {}
            set n 0
            set dynamic 0
            set slot 0
            foreach name [hir::types::StructLayout $type] {
                set field [hir::types::StructField $type $name]
                set d [ShareDescriptor $field]
                if {$d eq "" && ![hir::types::IsAffine $field] && [MayHoldVector $field]
                        && !([hir::types::IsNamedStruct $field] && [lindex $field 1] in $shareVisiting)} {
                    set d d
                    incr dynamic
                }
                if {$d ne ""} {
                    append parts "$slot.$d"
                    incr n
                }
                incr slot
            }
        } finally {
            if {$id ne ""} {
                set shareVisiting [lrange $shareVisiting 0 end-1]
            }
        }
        if {$n == $dynamic} {
            return ""
        }
        return "s$n.$parts"
    }
    return ""
}

# The share descriptor of a value of static TYPE held under the copy
# convention (below): ShareDescriptor's, or "d" -- a copy of whatever the
# value is at run time -- when TYPE is too imprecise to say but may hold a
# collection header (MayHoldVector: a generic function's parameter); "" when
# no copy is ever needed.
proc hir::mutvec::HeldDescriptor {type} {
    set d [ShareDescriptor $type]
    if {$d eq "" && ![hir::types::IsAffine $type] && [MayHoldVector $type]} {
        return d
    }
    return $d
}

# ---------------------------------------------------------------------------
# Elaboration (after hir::check; hir::buildSyntax)

proc hir::mutvec::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    variable freshFunctions
    variable currentParent
    set freshFunctions [dict create]
    if {[hir::mode $hir] ne "program" || ![Used $hir]} {
        return
    }
    set roots [dict getdef $hir mutvec roots {}]
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    set currentParent $parent
    # The operations that drop affine elements carry the element drop
    # descriptor: their registration's -drop-form (core/native.tcl) names the
    # dropping form and the argument whose type holds the element type (a
    # collection, or the call itself).
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        set name [hir::affine::NativeName $hir $e]
        if {$name eq "" || [dict get [core::native::metadata $name] dropForm] eq ""} continue
        lassign [dict get [core::native::metadata $name] dropForm] form at
        set collection [hir::typeOf $hir [if {$at eq "result"} {set e} else {lindex [dict get $node args] $at}]]
        if {[Kind $collection] eq "" || [llength $collection] != 2 || ![hir::types::IsAffine $collection]} continue
        set d [hir::affine::Descriptor $hir [lindex $collection 1]]
        if {$d eq ""} {
            # Affine elements that own nothing (C pointers, C-ABI-TYPES.md):
            # nothing to drop, so the ordinary form is the operation.
            continue
        }
        Retarget hir $e $form
        dict set hir exprs $e args [concat [dict get $hir exprs $e args] [list [NewConst hir $d $e]]]
    }
    # A loop over an unrestricted collection iterates a snapshot.
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
            set kind [Kind $type]
            if {$kind ne "" && ![hir::types::IsAffine $type]} {
                lappend wraps [list $it [ToListNativeOf $kind] {}]
            }
        }
    }
    Apply hir $wraps
    # A context parameter is a view of the installed context, a place every
    # function sharing it may mutate: its vector-bearing paths are read out
    # by copy wherever they are read, mutated here or not.
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] eq "local" && $b ni $roots && [IsContextParam $hir $b]
                && [HeldDescriptor [hir::affine::BindingType $hir $b]] ne ""} {
            lappend roots $b
        }
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    set currentParent $parent
    set rootSet [dict create]
    foreach b $roots {
        dict set rootSet $b 1
    }
    # The copy convention (below, "Last uses and consumed parameters"): the
    # bindings that own their header as exclusively as a place root does --
    # the consumed parameters of directly called functions and the locals
    # whose last use hands their header on -- join the roots.
    variable convention
    set convention [Convention $hir $parent $blocks $rootSet]
    foreach b [concat [dict keys [dict get $convention consumed]] [dict keys [dict get $convention demanded]]] {
        if {![dict exists $rootSet $b]} {
            dict set rootSet $b 1
            lappend roots $b
        }
    }
    dict set convention held $rootSet
    dict set convention observed [ObservedOnly $hir $parent $rootSet]
    set freshFunctions [FreshFunctions $hir $parent $blocks $rootSet]
    if {$roots eq {}} {
        Installations hir
        set freshFunctions [dict create]
        set convention [dict create]
        set currentParent {}
        return
    }
    # Read-outs.
    set wraps {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ni {ref project} || ![dict get $node reachable]} continue
        set path [Path $hir $e]
        if {$path eq "" || ![dict exists $rootSet [lindex $path 0]]} continue
        set d [HeldDescriptor [hir::typeOf $hir $e]]
        if {$d eq "" || ![dict exists $parent $e]} continue
        lassign [dict get $parent $e] p role
        if {$role eq "seq 0" || $role eq "callee"} continue
        if {[OwnResult $hir $parent $e [lindex $path 0]]} {
            # The function's result moves its own place's header out.
            continue
        }
        if {[Moved $hir $parent $e]} {
            # Its path's last use: nothing reads its header after this, so
            # the value moves on uncopied.
            continue
        }
        if {$p ne ""} {
            set pnode [dict get $hir exprs $p]
            if {[dict get $pnode kind] eq "project"} continue
            if {[dict get $pnode kind] eq "call" && [ByReference $hir $p $e]
                    && ([PlaceArgument $hir $p $e] || (![WrittenLater $hir $p $e] && ![PlaceOverlap $hir $p $e]))} {
                # The callee only reads it (or, a place, mutates it in
                # place) when it runs, while this function waits -- and no
                # later argument of the call writes it before that.
                continue
            }
            if {[dict get $pnode kind] eq "bind" && [dict get $pnode binding] in $roots} {
                # The entry share below covers it.
                continue
            }
        }
        lappend wraps [list $e [ShareNative] $d]
    }
    Apply hir $wraps
    # Entries.
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    set currentParent $parent
    dict set convention uses [UseMap $hir $parent]
    # With the read-outs written, a result whose collection fields are now
    # copies (a held binding's path read before its last use) is fresh too.
    set freshFunctions [FreshFunctions $hir $parent $blocks $rootSet]
    set wraps {}
    foreach b $roots {
        set binding [dict get $hir bindings $b]
        set d [HeldDescriptor [hir::affine::BindingType $hir $b]]
        if {$d eq ""} continue
        if {[dict get $binding kind] eq "local"} {
            if {[IsContextParam $hir $b]} continue
            set by [dict get $binding declaredBy]
            if {$by eq "" || ![dict exists $hir exprs $by]} continue
            set value [dict get $hir exprs $by value]
            if {![Fresh $hir $value] && ![Moved $hir $parent $value]} {
                lappend wraps [list $value [ShareNative] $d]
            }
        } elseif {![dict exists $convention consumed $b] && ![IsPlaceParam $hir $b]} {
            # (A place parameter is the caller's place itself: no entry copy.)
            EntryRename hir $b $d
        }
    }
    Apply hir $wraps
    # The arguments of consumed parameters: each call hands the callee a
    # header no one else holds -- a new one, the last use of a binding that
    # owns its own, or a copy.
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    set currentParent $parent
    dict set convention uses [UseMap $hir $parent]
    set wraps {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
        set target [ConventionTarget $hir $e]
        if {$target eq ""} continue
        foreach arg [dict get $node args] param [dict get $hir exprs $target params] {
            if {$arg eq "" || $param eq "" || ![dict exists $convention consumed $param]} continue
            if {[Fresh $hir $arg] || [Moved $hir $parent $arg]} continue
            set d [ShareDescriptor [hir::typeOf $hir $arg]]
            if {$d eq ""} {
                set d [HeldDescriptor [hir::affine::BindingType $hir $param]]
            }
            if {$d ne ""} {
                lappend wraps [list $arg [ShareNative] $d]
            }
        }
    }
    Apply hir $wraps
    Installations hir
    set freshFunctions [dict create]
    set convention [dict create]
    set currentParent {}
}

# ---------------------------------------------------------------------------
# Last uses and consumed parameters
#
# The logical copies above keep every place's header its own. Two refinements
# keep that guarantee with fewer copies -- an optimization only: no copy they
# omit could have been observed.
#
#   last use    a read-out of a place path that is its path's *last use* --
#               no use of the root that may read a header at that path can
#               run after it, on any path (NoLaterUse): neither the path
#               itself, nor a prefix of it (the root, an enclosing struct
#               field), nor an extension of it holding a header -- moves the
#               header on uncopied: nothing reads it there again. Uses of
#               disjoint paths do not count (`t.vals`, `t.count` after
#               `t.keys`; `t.count` after `t`): each struct field of a held
#               binding owns its headers alone, and an Int field holds
#               none. So does an entry whose value is such a last use. (A
#               context parameter is never moved: the installed context
#               outlives the function.)
#   consumed    a parameter of a function every call of which is a direct
#               call (DirectOnly: its binding is only ever a callee) is
#               *consumed* when the function needs to own its header: the
#               parameter is a place root (it mutates it), or its last use
#               hands the header to a position that needs an exclusive one.
#               The *caller* then hands it an exclusive header -- a new one,
#               the last use of a binding that owns its own, or a copy --
#               and the callee makes no entry copy. A builder threaded
#               through calls (`grown = grow(storage, n)`, `append(storage,
#               n, x)`) is then mutated in place, never detached per call.
#   demanded    a local whose last use hands its header to such a position
#               is held like a place root (its entry is exclusive, its other
#               value uses copy), so that last use needs no copy either.
#   observed    a parameter of a directly called function that only reads
#               its collection (ObservedOnly: never stores, returns, captures
#               or mutates it) is given a place's header uncopied: the callee
#               reads it while the caller -- the one function that could
#               mutate the place -- waits. (Not a context parameter's: other
#               functions sharing the context may mutate it meanwhile.) Like
#               a native's observing argument or a collection operation's
#               receiver, it is read when the call runs, after the call's
#               later arguments: one that would move its header on counts it
#               as a later use, and one that writes it in place makes it a
#               copy (ByReference, WrittenLater).
#
# The positions needing an exclusive header are a place root's entry, a
# consumed parameter's argument, and the result of a function whose call
# sits in one of them (its result is *demanded*: a parameter it returns is
# then consumed, which makes the function's result fresh), and each
# collection-bearing field of a struct literal in one of them (a literal is
# fresh when its fields are: `T {keys: keys, count: n}` returned by a
# function whose result is demanded consumes `keys`). The three sets grow
# together to their least fixed point (Convention).

namespace eval hir::mutvec {
    # The convention of the elaboration under way: consumed (parameter
    # BindingId -> 1), demanded (local BindingId -> 1), direct (function
    # block -> 1), uses (BindingId -> {ExprId -> 1}: every expression
    # containing a reference to the binding), held (BindingId -> 1: the
    # place roots, consumed parameters and demanded locals), observed
    # (BindingId -> 1: ObservedOnly).
    variable convention [dict create]
}

# The convention of HIR (parent map PARENT, function blocks BLOCKS) whose
# place roots are ROOTSET.
proc hir::mutvec::Convention {hir parent blocks rootSet} {
    variable convention
    set direct [DirectOnly $hir $parent $blocks]
    set convention [dict create consumed {} demanded {} direct $direct uses [UseMap $hir $parent] \
        captured [Captured $hir]]
    # Seeds: the place-root parameters of directly called functions own
    # their header by the caller's copy instead of an entry copy.
    dict for {b _} $rootSet {
        if {[dict get $hir bindings $b kind] eq "param" && [Eligible $hir $b]} {
            dict set convention consumed $b 1
        }
    }
    set demandedResults [dict create]
    for {set pass 0} {$pass < 256} {incr pass} {
        set changed 0
        foreach v [ExclusivePositions $hir $rootSet $demandedResults] {
            set node [dict get $hir exprs $v]
            if {[dict get $node kind] eq "call"} {
                set target [ConventionTarget $hir $v]
                if {$target ne "" && ![dict exists $demandedResults $target]} {
                    dict set demandedResults $target 1
                    set changed 1
                }
                continue
            }
            if {[dict get $node kind] in {ref project}} {
                set path [Path $hir $v]
            } else {
                set path ""
            }
            if {$path eq ""} continue
            set b [lindex $path 0]
            if {[dict exists $rootSet $b] || [dict exists $convention consumed $b]
                    || [dict exists $convention demanded $b]} continue
            if {![Eligible $hir $b] || ![NoLaterUse $hir $parent $v $b]} continue
            if {[dict get $hir bindings $b kind] eq "param"} {
                dict set convention consumed $b 1
            } else {
                dict set convention demanded $b 1
            }
            set changed 1
        }
        if {!$changed} break
    }
    return $convention
}

# The value expressions of HIR that need an exclusive header (Convention):
# the entry values of the place roots of ROOTSET and of the demanded locals,
# the arguments of consumed parameters, and the results of the functions of
# DEMANDEDRESULTS.
proc hir::mutvec::ExclusivePositions {hir rootSet demandedResults} {
    variable convention
    set result {}
    foreach b [concat [dict keys $rootSet] [dict keys [dict get $convention demanded]]] {
        set binding [dict get $hir bindings $b]
        if {[dict get $binding kind] ne "local" || [IsContextParam $hir $b]} continue
        set by [dict get $binding declaredBy]
        if {$by ne "" && [dict exists $hir exprs $by] && [dict get $hir exprs $by kind] eq "bind"} {
            lappend result [dict get $hir exprs $by value]
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
        set target [ConventionTarget $hir $e]
        if {$target eq ""} continue
        foreach arg [dict get $node args] param [dict get $hir exprs $target params] {
            if {$arg ne "" && $param ne "" && [dict exists $convention consumed $param]} {
                lappend result $arg
            }
        }
    }
    dict for {f _} $demandedResults {
        lappend result {*}[Results $hir $f]
    }
    # A struct literal in such a position gives an exclusive value only when
    # each of its collection-bearing fields does (Fresh): those fields are
    # exclusive positions too, through nested literals.
    set work $result
    set result {}
    while {$work ne {}} {
        set v [lindex $work end]
        set work [lrange $work 0 end-1]
        lappend result $v
        if {[dict get $hir exprs $v kind] ne "struct"} continue
        foreach f [dict get $hir exprs $v fields] {
            set type [hir::typeOf $hir $f]
            if {[ShareDescriptor $type] ne "" || [MayHoldVector $type]} {
                lappend work $f
            }
        }
    }
    return $result
}

# The function block call E calls directly when that function is one every
# call of which is direct (DirectOnly), or "".
proc hir::mutvec::ConventionTarget {hir e} {
    variable convention
    lassign [dict get $hir exprs $e target] kind block
    if {$kind ne "block" || ![dict exists $convention direct $block]} {
        return ""
    }
    return $block
}

# The function blocks of BLOCKS every reference to whose binding is the
# callee of a direct call of the block: each call site is known, so the
# callers can take over its parameters' copies.
proc hir::mutvec::DirectOnly {hir parent blocks} {
    set binders [dict create]
    foreach f $blocks {
        if {![dict exists $parent $f]} continue
        set p [lindex [dict get $parent $f] 0]
        if {$p ne "" && [dict get $hir exprs $p kind] eq "bind" && [dict get $hir exprs $p value] eq $f
                && ![dict get $hir exprs $p duplicate]} {
            dict set binders [dict get $hir exprs $p binding] $f
        }
    }
    set direct $binders
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref"} continue
        set b [dict get $node binding]
        if {$b eq "" || ![dict exists $direct $b]} continue
        set f [dict get $direct $b]
        set ok 0
        if {[dict exists $parent $e]} {
            lassign [dict get $parent $e] p role
            set ok [expr {$p ne "" && $role eq "callee" && [dict get $hir exprs $p target] eq [list block $f]}]
        }
        if {!$ok} {
            dict unset direct $b
        }
    }
    set result [dict create]
    dict for {b f} $direct {
        dict set result $f 1
    }
    return $result
}

# 1 if binding B may be held under the convention: a local or a parameter
# (of a directly called function) of a collection-bearing unrestricted type,
# never a module binding, a context parameter or a destructuring temporary,
# referred to only from its own function (a closure that captures it reads
# it whenever it runs).
proc hir::mutvec::Eligible {hir b} {
    variable convention
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] ni {local param} || [hir::isModuleBinding $hir $b]
            || [IsContextParam $hir $b] || [hir::affine::IsDestructureTemp $hir $b]
            || [IsPlaceParam $hir $b]} {
        return 0
    }
    if {[HeldDescriptor [hir::affine::BindingType $hir $b]] eq ""} {
        return 0
    }
    if {[dict get $binding kind] eq "param"} {
        set f [dict get $hir scopes [dict get $binding scope] owner]
        if {$f eq "" || ![dict exists $hir exprs $f] || [dict get $hir exprs $f kind] ne "block"
                || ![dict exists $convention direct $f]} {
            return 0
        }
    }
    return [expr {![dict exists $convention captured $b]}]
}

# The set (dict) of the bindings of HIR referred to from another invocation
# than their own (a nested function's reference: a capture). Computed once
# per convention: Eligible asks it of every binding on every pass.
proc hir::mutvec::Captured {hir} {
    set captured [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref"} continue
        set b [dict get $node binding]
        if {$b eq "" || [dict exists $captured $b] || ![dict exists $hir bindings $b]} continue
        set home [dict get $hir scopes [dict get $hir bindings $b scope] invocation]
        if {[dict get $hir scopes [dict get $node scope] invocation] ne $home} {
            dict set captured $b 1
        }
    }
    return $captured
}

# BindingId -> ExprId -> PATH -> HOLDS: for every expression of HIR (parent
# map PARENT) that contains a reference to the binding, the reference
# included, the paths those references read (UsePath: the field names of the
# projections continuing the reference, outermost last; {} the binding
# itself), each with HOLDS 1 when the value read may hold a collection
# header in a struct field (MayHoldVector of the chain's static type), 0
# when it cannot (an Int field, a List).
proc hir::mutvec::UseMap {hir parent} {
    set uses [dict create]
    set holding [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} continue
        set b [dict get $node binding]
        lassign [UsePath $hir $parent $e] fields top
        set holds 1
        if {$fields ne {}} {
            set type [hir::typeOf $hir $top]
            if {![dict exists $holding $type]} {
                dict set holding $type [MayHoldVector $type]
            }
            set holds [dict get $holding $type]
        }
        set x $e
        for {set i 0} {$i < 4096} {incr i} {
            if {!$holds && [dict exists $uses $b $x $fields]} {
                # (Another reference reads the same path: 1 wins.)
            } else {
                dict set uses $b $x $fields $holds
            }
            if {![dict exists $parent $x]} break
            set x [lindex [dict get $parent $x] 0]
            if {$x eq ""} break
        }
    }
    return $uses
}

# The path reference R (in parent map PARENT) reads: {FIELDS TOP}, FIELDS
# the names of the field projections continuing R (`t.keys.at(i)` reads
# `t` {keys}), TOP the outermost expression of that chain.
proc hir::mutvec::UsePath {hir parent r} {
    set fields {}
    set x $r
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} break
        set p [lindex [dict get $parent $x] 0]
        if {$p eq "" || [dict get $hir exprs $p kind] ne "project" || [dict get $hir exprs $p receiver] ne $x} break
        lappend fields [dict get $hir exprs $p name]
        set x $p
    }
    return [list $fields $x]
}

# 1 if expression S (evaluated) may read a collection header at binding B's
# path FIELDS ({} B itself): S refers to B by a path that is a prefix of
# FIELDS (B itself, an enclosing struct field, or FIELDS itself), or by an
# extension of FIELDS whose value may hold a header. A path disjoint from
# FIELDS -- a sibling field, `t.count` or `t.vals` beside `t.keys` -- reads
# none of FIELDS' headers: each struct field of a binding the elaboration
# holds owns the headers it holds alone (its entry is exclusive, and no
# copy of one field's header ever lands in another field). Nor does an
# extension that holds none (`t.count` beside `t` itself): it reads a part
# of an immutable struct that no header mutation can change.
proc hir::mutvec::ReadsPath {s b fields} {
    variable convention
    if {![dict exists $convention uses $b $s]} {
        return 0
    }
    set n [llength $fields]
    dict for {q holds} [dict get $convention uses $b $s] {
        set m [llength $q]
        if {$m <= $n} {
            if {[lrange $fields 0 [expr {$m - 1}]] eq $q} {
                return 1
            }
        } elseif {$holds && [lrange $q 0 [expr {$n - 1}]] eq $fields} {
            return 1
        }
    }
    return 0
}

# 1 if path expression E (a reference to binding B, or a projection chain
# from one: B's path P) is the last use of P's headers: no use of B that may
# read one of them (ReadsPath: P itself, a prefix of P such as B itself, or
# an extension of P that may hold a header) can run after E, on any path --
# the statements after E in each enclosing sequence up to B's own, the
# operands after E's in each enclosing expression (call arguments left to
# right, struct literal fields in written order), the earlier arguments of
# an enclosing call that it reads by reference when it runs (ByReference),
# the branches after a condition, the handlers after a handled call, and
# every iteration after this one of a loop B is not bound inside. Uses of
# paths disjoint from P (a sibling field) do not count: they read other
# headers. A statement that never completes skips the rest of its sequence:
# one that leaves the function (a `return`, a `fail`) ends the walk --
# nothing after it runs -- while a `break` goes on after its loop and a
# `continue` with the loop's next iteration (Leaves), unless B is bound
# inside that loop. A reference from a nested function is never a last use.
proc hir::mutvec::NoLaterUse {hir parent e b} {
    set home [dict get $hir scopes [dict get $hir bindings $b scope] invocation]
    if {[dict get $hir scopes [dict get $hir exprs $e scope] invocation] ne $home} {
        return 0
    }
    set path [Path $hir $e]
    if {$path ne "" && [lindex $path 0] eq $b} {
        set fields [lindex $path 1]
    } else {
        set fields {}
    }
    set x $e
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} {
            return 0
        }
        set p [lindex [dict get $parent $x] 0]
        if {$p eq ""} {
            return [expr {[lindex [LaterIn $hir [dict get $hir roots] $x $b $fields] 0] in {1 2}}]
        }
        set node [dict get $hir exprs $p]
        set kind [dict get $node kind]
        set sequence [hir::coroutines::SequenceOf $hir $p $x]
        if {$sequence ne ""} {
            set later [LaterIn $hir $sequence $x $b $fields]
            switch -- [lindex $later 0] {
                0 { return 0 }
                2 { return 1 }
                loop {
                    # The rest of the sequence is skipped for loop L: a
                    # `continue` runs its next iteration, a `break` what
                    # follows it. A binding of L's iteration is done with.
                    lassign $later - loop kinds
                    if {[BoundInside $hir $parent $b $loop]} {
                        return 1
                    }
                    if {"continue" in $kinds} {
                        return 0
                    }
                    set x $loop
                    continue
                }
            }
            switch -- $kind {
                block {
                    # The end of B's function body: the function returns.
                    return 1
                }
                loop - listloop - countloop - lockloop {
                    # The next iteration runs the body again: only a binding
                    # of this iteration is done with.
                    return [BoundInside $hir $parent $b $p]
                }
            }
            # (An if's branch or a handler body: what follows the if or the
            # handle runs next.)
            set x $p
            continue
        }
        # X is an operand of P.
        switch -- $kind {
            return {
                return 1
            }
            break - continue - block {
                return 0
            }
            if {
                foreach s [concat [dict get $node thenBody] [dict get $node elseBody]] {
                    if {[ReadsPath $s $b $fields]} {
                        return 0
                    }
                }
            }
            handle {
                foreach body [dict get $node handlerBodies] {
                    foreach s $body {
                        if {[ReadsPath $s $b $fields]} {
                            return 0
                        }
                    }
                }
            }
            default {
                set children [hir::children $hir $p]
                set at [lsearch -exact $children $x]
                foreach c [lrange $children [expr {$at + 1}] end] {
                    if {[ReadsPath $c $b $fields]} {
                        return 0
                    }
                }
                if {$kind eq "call"} {
                    # An earlier argument handed over by reference is read
                    # when the call runs, after this operand (ByReference).
                    foreach a [dict get $node args] {
                        if {$a eq $x} break
                        if {[ByReference $hir $p $a] && [ReadsPath $a $b $fields]} {
                            return 0
                        }
                    }
                }
                if {$kind in {loop listloop countloop lockloop}} {
                    # (The body ran after the operand only once it was
                    # checked above: an operand runs once.)
                }
            }
        }
        set x $p
    }
    return 0
}

# What may read binding B's path FIELDS (ReadsPath) after statement X of
# SEQUENCE: 0 a later statement may; 1 none does (what follows the sequence
# runs next); otherwise X or a later statement never completes before any
# does, and the rest of the sequence is skipped -- 2 for good (nothing of
# the function runs after it), or {loop L KINDS} when it goes on at loop L
# (Leaves).
proc hir::mutvec::LaterIn {hir sequence x b fields} {
    set at [lsearch -exact $sequence $x]
    if {$at < 0} {
        return 0
    }
    if {[hir::typeOf $hir $x] eq "never"} {
        return [Leaves $hir $x]
    }
    foreach s [lrange $sequence [expr {$at + 1}] end] {
        if {[ReadsPath $s $b $fields]} {
            return 0
        }
        if {[hir::typeOf $hir $s] eq "never"} {
            return [Leaves $hir $s]
        }
    }
    return 1
}

# Where the function goes on after statement S, which never completes: 2
# nowhere (S returns, fails, or calls what never returns), or {loop L
# KINDS} when a `break` or `continue` of S (not of a loop inside S) leaves
# for loop L -- after L, or with L's next iteration -- KINDS the sorted
# kinds that do; 0 (anywhere) if such exits name two loops.
proc hir::mutvec::Leaves {hir s} {
    set inner [dict create]
    set exits {}
    set work [list $s]
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        set node [dict get $hir exprs $x]
        switch -- [dict get $node kind] {
            block {
                # A nested function: its exits are its own.
                continue
            }
            loop - listloop - countloop - lockloop {
                dict set inner $x 1
            }
            break - continue {
                lappend exits [dict get $node kind] [dict get $node target]
            }
        }
        lappend work {*}[hir::children $hir $x]
    }
    set loops {}
    set kinds {}
    foreach {kind target} $exits {
        if {[dict exists $inner $target]} continue
        if {$target ni $loops} {
            lappend loops $target
        }
        if {$kind ni $kinds} {
            lappend kinds $kind
        }
    }
    switch -- [llength $loops] {
        0 { return 2 }
        1 { return [list loop [lindex $loops 0] [lsort $kinds]] }
    }
    return 0
}

# 1 if binding B is bound inside loop P's body (a binding of one iteration:
# the loop's own element or count binding, or a binding statement in its
# body).
proc hir::mutvec::BoundInside {hir parent b p} {
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "param"} {
        return [expr {[dict get $hir scopes [dict get $binding scope] owner] eq $p}]
    }
    set x [dict get $binding declaredBy]
    for {set i 0} {$i < 4096 && $x ne "" && [dict exists $parent $x]} {incr i} {
        set x [lindex [dict get $parent $x] 0]
        if {$x eq $p} {
            return 1
        }
    }
    return 0
}

# 1 if E is a place path from a binding the elaboration holds exclusively
# (a place root, a consumed parameter, a demanded local; never a context
# parameter) at the last use of its path (NoLaterUse): E's value moves on
# uncopied.
proc hir::mutvec::Moved {hir parent e} {
    variable convention
    if {$convention eq {} || [dict get $hir exprs $e kind] ni {ref project}} {
        return 0
    }
    set path [Path $hir $e]
    if {$path eq ""} {
        return 0
    }
    set b [lindex $path 0]
    if {[IsContextParam $hir $b] || [IsPlaceParam $hir $b] || ![dict exists $convention held $b]} {
        # (A context parameter or a place parameter is never moved: the
        # installed context, the caller's place, outlives the function.)
        return 0
    }
    return [NoLaterUse $hir $parent $e $b]
}

# 1 if place path A, an argument of call P, is handed over by reference --
# uncopied although it may not be its path's last use -- because the call
# reads it (or mutates it, a place) when it runs: the argument of a
# parameter that only observes (ObservedArgument; never a context
# parameter's path: other functions sharing the context may mutate it
# meanwhile), a native argument whose ownership role does not keep it
# (Observed), or a collection operation's receiver. The call runs after
# its later arguments: a later argument that moved A's header on into a
# mutating callee (NoLaterUse counts A as a later use) or wrote it in place
# (WrittenLater) would change what the call reads.
proc hir::mutvec::ByReference {hir p a} {
    if {[dict get $hir exprs $a kind] ni {ref project}} {
        return 0
    }
    set path [Path $hir $a]
    if {$path eq ""} {
        return 0
    }
    if {[OpKind $hir $p] ne "" && [lindex [dict get $hir exprs $p args] 0] eq $a} {
        return 1
    }
    if {[PlaceArgument $hir $p $a]} {
        # (The argument for a place parameter: the caller's place itself.)
        return 1
    }
    if {[Observed $hir $p $a]} {
        return 1
    }
    return [expr {![IsContextParam $hir [lindex $path 0]] && [ObservedArgument $hir $p $a]}]
}

# 1 if argument A of call P is a place the call mutates in place: the
# receiver of a mutating collection operation, or a native argument whose
# ownership role is `place`. A place is never copied for its call (the
# update would be lost); what a later argument does to it first is what
# the mutation sees.
proc hir::mutvec::PlaceArgument {hir p a} {
    set index [lsearch -exact [dict get $hir exprs $p args] $a]
    if {$index == 0 && [OpKind $hir $p] eq "mutate"} {
        return 1
    }
    if {$index >= 0 && $index in [PlaceIndices $hir $p]} {
        return 1
    }
    set name [hir::affine::NativeName $hir $p]
    return [expr {$name ne "" && $index >= 0 && [core::native::ownershipRole $name $index] eq "place"}]
}

# 1 if call P gives a place argument (PlaceArgument) other than A whose
# path overlaps A's (Overlap): the call updates, while it runs, a header A
# would be read by reference from -- so A must be its copy.
proc hir::mutvec::PlaceOverlap {hir p a} {
    set path [Path $hir $a]
    if {$path eq ""} {
        return 0
    }
    foreach arg [dict get $hir exprs $p args] {
        if {$arg eq "" || $arg eq $a || ![PlaceArgument $hir $p $arg]} continue
        set q [Path $hir $arg]
        if {$q ne "" && [Overlap $q $path]} {
            return 1
        }
    }
    return 0
}

# 1 if a later argument of call P than place path A (its root B) may write
# the header A holds before P runs: it mutates a place path of B that A's
# path is a prefix of (the same path, or a collection inside A), or -- A
# being a context parameter's path, which every function sharing the
# context may mutate in place -- it calls anything that may run code (a
# function, or a native given a callable).
proc hir::mutvec::WrittenLater {hir p a} {
    lassign [Path $hir $a] b fields
    set n [llength $fields]
    set context [IsContextParam $hir $b]
    set args [dict get $hir exprs $p args]
    set work [lrange $args [expr {[lsearch -exact $args $a] + 1}] end]
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        if {$x eq "" || ![dict exists $hir exprs $x]} continue
        if {[dict get $hir exprs $x kind] eq "call"} {
            if {$context && [MayRunCode $hir $x]} {
                return 1
            }
            foreach arg [dict get $hir exprs $x args] {
                if {$arg eq "" || ![PlaceArgument $hir $x $arg]} continue
                set q [Path $hir $arg]
                if {$q ne "" && [Overlap $q [list $b $fields]]} {
                    # (A place A's path is a prefix of, or one the call
                    # mutates a field of: a place parameter's update may
                    # reach any header under its path.)
                    return 1
                }
            }
        }
        lappend work {*}[hir::children $hir $x]
    }
    return 0
}

# 1 if call E may run Botlish code: a call of anything but a native, of a
# native that calls an argument (its ownership role says so: factory,
# resume) or is given one that may be a callable, or a yield (one of the
# coroutine analysis's yield sites): it suspends the coroutine, and its
# resumer runs until it resumes it.
proc hir::mutvec::MayRunCode {hir e} {
    set name [hir::affine::NativeName $hir $e]
    if {$name eq "" || [dict exists $hir coroutines yields $e]} {
        return 1
    }
    set index 0
    foreach arg [dict get $hir exprs $e args] {
        if {[core::native::ownershipRole $name $index] in {factory resume}
                || ($arg ne "" && [lindex [hir::typeOf $hir $arg] 0] in {fn block native coroutine any})} {
            return 1
        }
        incr index
    }
    return 0
}

# 1 if E is an argument of call P whose parameter only observes it
# (ObservedOnly): the callee reads the header during the call, while the
# caller -- the one function that could mutate its place -- waits.
proc hir::mutvec::ObservedArgument {hir p e} {
    variable convention
    set target [ConventionTarget $hir $p]
    if {$target eq "" || ![dict exists $convention observed]} {
        return 0
    }
    set index [lsearch -exact [dict get $hir exprs $p args] $e]
    set param [lindex [dict get $hir exprs $target params] $index]
    return [expr {$index >= 0 && $param ne "" && [dict exists $convention observed $param]}]
}

# The bindings (dict) that only observe the collection header they hold: the
# parameters of directly called functions (and the locals of any function)
# of a collection-bearing type, mutated nowhere (not in ROOTSET), referred
# to only from their own function, and whose every value use is an
# observation -- a native argument whose ownership role reads it, a
# collection operation's receiver, a projection whose own uses observe, an
# argument of a parameter that only observes, the value of a binding that
# copies it (a place root's entry) or only observes it, a discarded
# statement. Never returned, stored, captured or passed anywhere that could
# keep it: the greatest such set.
proc hir::mutvec::ObservedOnly {hir parent rootSet} {
    variable convention
    set candidates [dict create]
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] ni {local param} || [dict exists $rootSet $b]} continue
        if {[hir::isModuleBinding $hir $b] || [IsContextParam $hir $b]} continue
        if {[HeldDescriptor [hir::affine::BindingType $hir $b]] eq ""} continue
        if {[dict get $binding kind] eq "param"} {
            set f [dict get $hir scopes [dict get $binding scope] owner]
            if {$f eq "" || ![dict exists $convention direct $f]} continue
        }
        dict set candidates $b {}
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || ![dict exists $candidates [dict get $node binding]]} continue
        set b [dict get $node binding]
        if {[dict get $hir scopes [dict get $node scope] invocation]
                ne [dict get $hir scopes [dict get $hir bindings $b scope] invocation]} {
            # (Captured: a closure reads it whenever it runs.)
            dict set candidates $b escapes
            continue
        }
        dict lappend candidates $b $e
    }
    set observed [dict create]
    dict for {b refs} $candidates {
        if {$refs ne "escapes"} {
            dict set observed $b $refs
        }
    }
    for {set pass 0} {$pass < 256} {incr pass} {
        set changed 0
        dict for {b refs} $observed {
            foreach r $refs {
                if {[Escapes $hir $parent $r $observed $rootSet]} {
                    dict unset observed $b
                    set changed 1
                    break
                }
            }
        }
        if {!$changed} break
    }
    set result [dict create]
    dict for {b refs} $observed {
        dict set result $b 1
    }
    return $result
}

# 1 if the value of path expression E may be kept beyond an observation
# (ObservedOnly, given the bindings OBSERVED still assumed to observe only).
proc hir::mutvec::Escapes {hir parent e observed rootSet} {
    if {![dict exists $parent $e]} {
        return 1
    }
    lassign [dict get $parent $e] p role
    if {$role eq "seq 0"} {
        return 0
    }
    if {$p eq ""} {
        return 1
    }
    set node [dict get $hir exprs $p]
    switch -- [dict get $node kind] {
        project {
            if {[HeldDescriptor [hir::typeOf $hir $p]] eq ""} {
                # (A field that holds no collection header.)
                return 0
            }
            return [Escapes $hir $parent $p $observed $rootSet]
        }
        call {
            if {$role eq "callee"} {
                return 1
            }
            if {[hir::affine::NativeName $hir $p] ne ""} {
                return [expr {!([Observed $hir $p $e]
                    || ([OpKind $hir $p] ne "" && [lindex [dict get $node args] 0] eq $e))}]
            }
            set target [ConventionTarget $hir $p]
            if {$target eq ""} {
                return 1
            }
            set index [lsearch -exact [dict get $node args] $e]
            set param [lindex [dict get $hir exprs $target params] $index]
            return [expr {$param eq "" || ![dict exists $observed $param]}]
        }
        bind {
            set l [dict get $node binding]
            return [expr {![dict exists $observed $l] && ![dict exists $rootSet $l]}]
        }
    }
    return 1
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
        set d [HeldDescriptor [hir::typeOf $hir $value]]
        if {$d ne "" && ![Fresh $hir $value]} {
            lappend wraps [list $value [ShareNative] $d]
        }
    }
    Apply hir $wraps
}

# 1 if argument E of native call P is one the native only reads -- its
# ownership role (core/native.tcl's -ownership) is observe, copy-out (its
# elements are read out, the collection itself is kept by nothing), place,
# equality or release: such an argument needs no logical copy of its own.
proc hir::mutvec::Observed {hir p e} {
    set name [hir::affine::NativeName $hir $p]
    if {$name eq ""} {
        return 0
    }
    set index [lsearch -exact [dict get $hir exprs $p args] $e]
    return [expr {$index >= 0 && [core::native::ownershipRole $name $index] in {observe copy-out place equality release}}]
}

# 1 if the value of E is a collection-bearing value nothing else refers to: a
# new vector or array, a logical copy, or a struct literal of such.
proc hir::mutvec::Fresh {hir e} {
    variable freshFunctions
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        call {
            set name [hir::affine::NativeName $hir $e]
            if {[Constructor $name] || $name eq [ShareNative]} {
                return 1
            }
            set target [hir::contexts::Callee $hir $e]
            return [expr {$target ne "" && [dict exists $freshFunctions $target]}]
        }
        struct {
            variable currentParent
            foreach f [dict get $node fields] {
                set type [hir::typeOf $hir $f]
                if {([ShareDescriptor $type] ne "" || [MayHoldVector $type]) && ![Fresh $hir $f]
                        && !($currentParent ne {} && [Moved $hir $currentParent $f])} {
                    # (A field that is the last use of its path in a binding
                    # holding its own headers moves that header into the
                    # struct.)
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
    if {[IsContextParam $hir $root] || [IsPlaceParam $hir $root] || ![IsResult $hir $parent $e]} {
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
# collection header (a MutableVector's or a MutableArray's): TYPE is one, or
# is imprecise where one could be -- `any`, an untyped (generic) position, a
# trait view, a struct field of such a type. A generic function's own body
# is typed this way (its instances are not), so `fn same(x): x` may return
# the collection it was given. A List, set, array or vector element, a
# Result payload or a callable is never a place (extracting one into a place
# is an entry, which copies): those do not count.
proc hir::mutvec::MayHoldVector {type {seen {}}} {
    if {[lindex $type 0] eq "refined"} {
        # A refined value has exactly its carrier's representation
        # (REFINEMENT-VALUES.md): an integer domain, a C scalar, a
        # refinement of a String hold no header.
        return [MayHoldVector [lindex $type 1] $seen]
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[MayHoldVector $t $seen]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsNamedStruct $type]} {
        # (An application's fields, its slots replaced by the arguments:
        # TRAIT-CONSTRAINED-IMPRINTED-TYPES.md.)
        if {$type in $seen} {
            return 0
        }
        foreach {name t} [hir::structs::AppliedFieldTypes $type] {
            if {[MayHoldVector $t [concat $seen [list $type]]]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsEnum $type]} {
        # An enum (ENUMS.md) holds what its case payloads hold: nothing,
        # for the payload-free cases of today.
        set id [lindex $type 1]
        if {$id in $seen} {
            return 0
        }
        foreach t [hir::enums::payloadTypes $id] {
            if {[MayHoldVector $t [concat $seen [list $id]]]} {
                return 1
            }
        }
        return 0
    }
    if {[Kind $type] ne ""} {
        return 1
    }
    return [expr {[lindex $type 0] ni {int str bool unit UnicodeChar never list immutableSet block native fn coroutine result}
        && ![core::type::isFloat [lindex $type 0]]}]
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
                if {[dict get $hir exprs $x kind] in {ref project}} {
                    set path [Path $hir $x]
                } else {
                    set path ""
                }
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
        if {$native in [list [ToListNativeOf vector] [ToListNativeOf array]]} {
            if {[llength $type] == 2 && [Kind $type] ne ""} {
                set type [hir::types::MakeList [lindex $type 1]]
            } else {
                set type "list"
            }
        }
        set call [NewCall hir $native $args $type $e]
        set p [lindex [dict get $parent $e] 0]
        if {$p eq ""} {
            dict set hir roots [lmap r [dict get $hir roots] {if {$r eq $e} {set call} else {set r}}]
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

# The entry of place root B, a parameter (of a function, a loop's
# per-iteration variable, or a handler's payload binding): B becomes a
# local bound, as the body's first statement, to a logical copy (share
# descriptor D) of a new parameter that takes B's place -- so the place owns
# the header it mutates.
proc hir::mutvec::EntryRename {hirVar b d} {
    upvar 1 $hirVar hir
    set binding [dict get $hir bindings $b]
    set s [dict get $binding scope]
    set e [dict get $hir scopes $s owner]
    if {$e eq "" || ![dict exists $hir exprs $e]} {
        return
    }
    set node [dict get $hir exprs $e]
    set kind [dict get $node kind]
    switch -- $kind {
        block - listloop - lockloop {
            set body [dict get $node body]
            set reachable 1
        }
        handle {
            # The handler whose branch scope binds B.
            set k [lsearch -exact [dict get $node handlerScopes] $s]
            if {$k < 0 || [lindex [dict get $node handlerPayloads] $k] ne $b} {
                error "hir::mutvec::EntryRename: $b is no payload binding of $e"
            }
            set body [lindex [dict get $node handlerBodies] $k]
            set reachable [expr {$body eq {} || [dict get $hir exprs [lindex $body 0] reachable]}]
        }
        default {
            error "hir::mutvec::EntryRename: no entry for a parameter of a $kind"
        }
    }
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
    switch -- $kind {
        block {
            dict set hir exprs $e params [lmap x [dict get $node params] {if {$x eq $b} {set p} else {set x}}]
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
        handle {
            dict set hir exprs $e handlerPayloads [lreplace [dict get $node handlerPayloads] $k $k $p]
        }
    }
    # The body's first statement: `NAME = share(NAME#entry)`.
    if {$body ne {}} {
        set at [lindex $body 0]
    } else {
        set at $e
    }
    set atNode [dict get $hir exprs $at]
    set r [hir::NewId hir expr]
    dict set hir exprs $r [dict create id $r kind ref origin [dict get $atNode origin] scope $s \
        type [hir::types::intern hir $type] reachable $reachable name $pname binding $p init yes]
    set c [NewCall hir [ShareNative] [list $r] $type $r]
    dict set hir exprs $c args [list $r [NewConst hir $d $r]]
    set n [hir::NewId hir expr]
    dict set hir exprs $n [dict create id $n kind bind origin [dict get $atNode origin] scope $s \
        type [hir::types::intern hir $type] reachable $reachable name $name binding $b value $c duplicate 0]
    dict set hir bindings $b kind local
    dict set hir bindings $b declaredBy $n
    if {$kind eq "handle"} {
        set bodies [dict get $hir exprs $e handlerBodies]
        lset bodies $k [linsert $body 0 $n]
        dict set hir exprs $e handlerBodies $bodies
    } else {
        dict set hir exprs $e body [linsert $body 0 $n]
    }
}

# 1 if projection P (in parent map PARENT) is a step of a collection
# operation's receiver place path: its chain of enclosing projections ends at
# the first argument of a MutableVector or MutableArray operation
# (hir/affine.tcl's Consumer).
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

# 1 if E is a listloop consuming an affine MutableVector or MutableArray
# (hir/affine.tcl).
proc hir::mutvec::IsConsumingLoop {hir e} {
    return [expr {[ConsumedKind $hir $e] ne ""}]
}

# The kind (vector, array) of the collection listloop E consumes, or "" when
# it consumes none.
proc hir::mutvec::ConsumedKind {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "listloop"} {
        return ""
    }
    set iterable [dict get $node iterable]
    switch -- [hir::affine::NativeName $hir $iterable] {
        mutable_vector#consume {
            # Marked in Core IR (hir/lower.tcl): HIR built from it lost the
            # element type that made the loop consuming.
            return vector
        }
        mutable_array#consume {
            return array
        }
    }
    set type [hir::typeOf $hir $iterable]
    if {[llength $type] == 2 && [Kind $type] ne "" && [hir::types::IsAffine $type]} {
        return [Kind $type]
    }
    return ""
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
        mutable_vector#swap_drop - mutable_array#swap_drop - mutable_array#set_drop {
            return [lrange [dict get $hir exprs $e args] 3 3]
        }
        mutable_array#generate_drop {
            return [lrange [dict get $hir exprs $e args] 2 2]
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
#   array=observe|mutate      the same for a MutableArray operation
#   move-out                  the operation moves an affine element out of
#                             the collection (pop, take, swap's displaced one)
#   consuming                 a loop consuming an affine collection
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
            set name [hir::affine::NativeName $hir $e]
            set collection vector
            if {[CollectionOf $name] eq "array"} {
                set collection array
            }
            set flags [list $collection=$kind]
            set place [PlaceText $hir $e]
            if {$place ne ""} {
                lappend flags place=$place
            }
            if {$name in {std::mutable_vector::pop std::mutable_vector::take std::mutable_vector::swap
                    mutable_vector#swap_drop mutable_vector#take_front std::mutable_array::swap
                    mutable_array#swap_drop mutable_array#take_front}
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
