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
#               iteration, a context installation's value.
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
            hir::Diagnose hir MUTABLE-PLACE-RECEIVER $problem $receiver
            continue
        }
        dict set roots [lindex [Path $hir $receiver] 0] [Kind [hir::typeOf $hir $receiver]]
    }
    # A nested function may not refer to a place root.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || ![dict exists $roots [dict get $node binding]]} continue
        set b [dict get $node binding]
        set refScope [dict get $node scope]
        set bindingScope [dict get $hir bindings $b scope]
        if {[dict get $hir scopes $refScope invocation] ne [dict get $hir scopes $bindingScope invocation]} {
            set kind [dict get $roots $b]
            set what [KindName $kind]
            hir::Diagnose hir MUTABLE-PLACE-CAPTURE \
                "`[dict get $node name]` is a $what place (its function mutates it in place), which a nested function cannot capture: the nested function would observe a binding that changes, and a $kind is a value, not a shared reference (pass it as an argument: the callee gets its own logical copy)" $e
        }
    }
    dict set hir mutvec roots [lsort -dictionary [dict keys $roots]]
}

# Why receiver R of mutating call E is not a place, or "".
proc hir::mutvec::ReceiverProblem {hir e r} {
    set op [hir::affine::NativeName $hir $e]
    set what "the receiver of $op"
    set kind [expr {[string match mutable_array* $op] ? "array" : "vector"}]
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
    if {[dict get $binding kind] ni {local param} || [hir::isModuleBinding $hir $b]} {
        return "$what is `[dict get $binding name]`, which is not a local binding, a parameter or a context parameter of this function: only those are places a $kind can be mutated in (a module binding is shared by every user of the module)"
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
        return "$what is `[join [concat [list [dict get $binding name]] $fields] .]`, whose binding is not statically a $name\[T\] place (its type is [hir::types::show [expr {$pathType eq "" ? "any" : $pathType}]]): only a binding of a collection type owns a header it may mutate (bind the narrowed value to a name first -- `copy = [dict get $binding name]` -- and mutate that)"
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
        return "$what is `[dict get $binding name]`, a binding of an enclosing function: a nested function cannot mutate $a $kind it captured ($a $kind is a value; pass it in and return the result)"
    }
    return ""
}

# ---------------------------------------------------------------------------
# Share descriptors

# The share descriptor of a value of static TYPE, or "" when a logical copy
# of it shares no header: "h" an unrestricted collection (a vector or an
# array header), "s"N"."(SLOT"."D)*N a struct whose listed layout slots hold
# collection-bearing values. An affine type is never copied (it moves).
proc hir::mutvec::ShareDescriptor {type} {
    if {[hir::types::IsAffine $type]} {
        return ""
    }
    if {[Kind $type] ne ""} {
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
    set roots [expr {[dict exists $hir mutvec roots] ? [dict get $hir mutvec roots] : {}}]
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
        set collection [hir::typeOf $hir [expr {$at eq "result" ? $e : [lindex [dict get $node args] $at]}]]
        if {[Kind $collection] eq "" || [llength $collection] != 2 || ![hir::types::IsAffine $collection]} continue
        set d [hir::affine::Descriptor $hir [lindex $collection 1]]
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
                && [ShareDescriptor [hir::affine::BindingType $hir $b]] ne ""} {
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
            # The root's last use: nothing reads its header after this, so
            # the value moves on uncopied.
            continue
        }
        if {$p ne ""} {
            set pnode [dict get $hir exprs $p]
            if {[dict get $pnode kind] eq "project"} continue
            if {[dict get $pnode kind] eq "call" && ![IsContextParam $hir [lindex $path 0]]
                    && [ObservedArgument $hir $p $e]} {
                # The callee only reads it, while this function waits.
                continue
            }
            if {[dict get $pnode kind] eq "call" && [OpKind $hir $p] ne ""
                    && [lindex [dict get $pnode args] 0] eq $e} continue
            if {[dict get $pnode kind] eq "call" && [Observed $hir $p $e]} continue
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
        } elseif {![dict exists $convention consumed $b]} {
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
#   last use    a read-out of a place root that is its root's *last use* --
#               no reference to the root can run after it, on any path
#               (NoLaterUse) -- moves the header on uncopied: nothing reads
#               the root again. So does an entry whose value is such a last
#               use. (A context parameter is never moved: the installed
#               context outlives the function.)
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
#               functions sharing the context may mutate it meanwhile.)
#
# The positions needing an exclusive header are a place root's entry, a
# consumed parameter's argument, and the result of a function whose call
# sits in one of them (its result is *demanded*: a parameter it returns is
# then consumed, which makes the function's result fresh). The three sets
# grow together to their least fixed point (Convention).

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
            set path [expr {[dict get $node kind] in {ref project} ? [Path $hir $v] : ""}]
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
            || [IsContextParam $hir $b] || [hir::affine::IsDestructureTemp $hir $b]} {
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

# BindingId -> the set (dict) of the expressions of HIR (parent map PARENT)
# that contain a reference to it, the reference included.
proc hir::mutvec::UseMap {hir parent} {
    set uses [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} continue
        set b [dict get $node binding]
        set x $e
        for {set i 0} {$i < 4096} {incr i} {
            dict set uses $b $x 1
            if {![dict exists $parent $x]} break
            set x [lindex [dict get $parent $x] 0]
            if {$x eq ""} break
        }
    }
    return $uses
}

# 1 if expression S (evaluated) may read binding B.
proc hir::mutvec::Reads {s b} {
    variable convention
    return [dict exists $convention uses $b $s]
}

# 1 if path expression E (a reference to binding B, or a projection chain
# from one) is B's last use: no reference to B can run after E, on any path
# -- the statements after E in each enclosing sequence up to B's own, the
# operands after E's in each enclosing expression, the branches after a
# condition, the handlers after a handled call, and every iteration after
# this one of a loop B is not bound inside. A statement that never completes
# (a `return`, a `fail`, a `break`) ends the walk: nothing after it runs. A
# reference from a nested function is never a last use.
proc hir::mutvec::NoLaterUse {hir parent e b} {
    set home [dict get $hir scopes [dict get $hir bindings $b scope] invocation]
    if {[dict get $hir scopes [dict get $hir exprs $e scope] invocation] ne $home} {
        return 0
    }
    set x $e
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $x]} {
            return 0
        }
        set p [lindex [dict get $parent $x] 0]
        if {$p eq ""} {
            return [expr {[LaterIn $hir [dict get $hir roots] $x $b] != 0}]
        }
        set node [dict get $hir exprs $p]
        set kind [dict get $node kind]
        set sequence [hir::coroutines::SequenceOf $hir $p $x]
        if {$sequence ne ""} {
            switch -- [LaterIn $hir $sequence $x $b] {
                0 { return 0 }
                2 { return 1 }
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
                    if {[Reads $s $b]} {
                        return 0
                    }
                }
            }
            handle {
                foreach body [dict get $node handlerBodies] {
                    foreach s $body {
                        if {[Reads $s $b]} {
                            return 0
                        }
                    }
                }
            }
            default {
                set children [hir::children $hir $p]
                set at [lsearch -exact $children $x]
                foreach c [lrange $children [expr {$at + 1}] end] {
                    if {[Reads $c $b]} {
                        return 0
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

# What may read binding B after statement X of SEQUENCE: 0 a later statement
# may; 2 none can, because a later statement never completes before any
# does; 1 none does.
proc hir::mutvec::LaterIn {hir sequence x b} {
    set at [lsearch -exact $sequence $x]
    if {$at < 0} {
        return 0
    }
    if {[hir::typeOf $hir $x] eq "never"} {
        return 2
    }
    foreach s [lrange $sequence [expr {$at + 1}] end] {
        if {[Reads $s $b]} {
            return 0
        }
        if {[hir::typeOf $hir $s] eq "never"} {
            return 2
        }
    }
    return 1
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
# parameter) at that binding's last use: E's value moves on uncopied.
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
    if {[IsContextParam $hir $b] || ![dict exists $convention held $b]} {
        return 0
    }
    return [NoLaterUse $hir $parent $e $b]
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
        set d [ShareDescriptor [hir::typeOf $hir $value]]
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
                    # (A field that is the last use of a binding holding its
                    # own header moves that header into the struct.)
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
# collection header (a MutableVector's or a MutableArray's): TYPE is one, or
# is imprecise where one could be -- `any`, an untyped (generic) position, a
# trait view, a struct field of such a type. A generic function's own body
# is typed this way (its instances are not), so `fn same(x): x` may return
# the collection it was given. A List, set, array or vector element, a
# Result payload or a callable is never a place (extracting one into a place
# is an entry, which copies): those do not count.
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
    if {[Kind $type] ne ""} {
        return 1
    }
    return [expr {[lindex $type 0] ni {int str bool unit UnicodeChar never list immutableSet block native fn coroutine result}}]
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
        if {$native in [list [ToListNativeOf vector] [ToListNativeOf array]]} {
            set type [expr {[llength $type] == 2 && [Kind $type] ne "" ? [hir::types::MakeList [lindex $type 1]] : "list"}]
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
            set flags [list [expr {[string match mutable_array* $name] ? "array" : "vector"}]=$kind]
            set place [PlaceText $hir $e]
            if {$place ne ""} {
                lappend flags place=$place
            }
            if {$name in {mutable_vector::pop mutable_vector::take mutable_vector::swap
                    mutable_vector#swap_drop mutable_vector#take_front mutable_array::swap
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
