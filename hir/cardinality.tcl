# cardinality.tcl -- collecting-loop output-length facts
# (RETURNING-ITERABLE-LOOPS.md items 15-19, 51-52; COLLECTING-LOOPS.md extends
# them to the numeric and lockstep loops, which build their result List
# exactly like a listloop) and iteration-domain cardinality (bottom of file).
#
#   hir::cardinality::analyze $hir     -> dict: listloop ExprId -> exact|max
#   hir::cardinality::of $hir $e       -> exact|max, for one listloop E
#
# The smallest representation compatible with the milestone's own explicit
# scoping ("if the current fact framework cannot yet express relational
# collection length without a disproportionate new system, STOP AND REPORT
# that limitation before inventing one... a narrowly scoped metadata
# representation is preferable to a general theorem engine"): this is not a
# relational fact system, and it is deliberately independent of hir/range.
# tcl's own per-specialization-instance argument-fact machinery (Range,
# narrowing rounds, call-site seeding) -- a listloop's cardinality needs
# none of that. It depends on exactly one already-resolved HIR fact:
# hir/resolve.tcl's own `target` field on every break/continue node (the
# ExprId of the loop it lexically targets, resolved once, purely
# syntactically, independent of reachability analysis or types).
#
#   exact   no break/continue anywhere in the loop's own body targets it:
#           every normal completion of the loop produces a List of exactly
#           the iterable's own length (item 15's ExactLengthOf(input)).
#   max     a break or continue targeting this loop is reachable in its own
#           body (a nested loop's own break/continue targets *that* inner
#           loop instead, via the same lexical resolution hir/resolve.tcl
#           already performs, and so does not count here): output length
#           <= input length on every normal completion (items 16/17/19's
#           MaxLengthOf(input)).
#
# return/Error are nonlocal completions (item 17): a listloop execution that
# ends in one of them does not "normally produce a List" at all, so neither
# ever weakens exact into max here -- only an actually reachable break/
# continue does, which is exactly what scanning for a matching `target`
# field (independent of return/error/reachability) already captures. This
# module does no path-sensitive counting (item 20 of the milestone this
# followed, "do not attempt path-sensitive counting in this milestone"): a
# break/continue on a provably-dead path still downgrades exact to max,
# exactly like hir/aot.tcl's own "discarded" fact is similarly a syntactic,
# not path-sensitive, approximation.
namespace eval hir::cardinality {}

proc hir::cardinality::analyze {hir} {
    set result [dict create]
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] in {listloop countloop lockloop}} {
            dict set result $id exact
        }
    }
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] in {break continue}} {
            set target [dict get $node target]
            if {$target ne "" && [dict exists $result $target]} {
                dict set result $target max
            }
        }
    }
    return $result
}

# exact | max for one collecting loop E (listloop, countloop or lockloop: all
# three build their result List the same way).
proc hir::cardinality::of {hir e} {
    if {[dict get $hir exprs $e kind] ni {listloop countloop lockloop}} {
        error "hir::cardinality::of: $e is not a collecting loop"
    }
    return [dict get [analyze $hir] $e]
}

proc hir::cardinality::of_loop {hir e} {
    return [of $hir $e]
}

# 1 if no break or continue targets the collecting loop E (`exact`, of
# alone): the same syntactic fact, found in E's own body (a nested
# function's body cannot target E) rather than in the whole program.
proc hir::cardinality::Exact {hir e} {
    set work [hir::children $hir $e]
    while {$work ne {}} {
        set work [lassign $work x]
        set node [dict get $hir exprs $x]
        switch -- [dict get $node kind] {
            break - continue {
                if {[dict get $node target] eq $e} {
                    return 0
                }
            }
            block {
                continue
            }
        }
        lappend work {*}[hir::children $hir $x]
    }
    return 1
}

# ---------------------------------------------------------------------------
# Iteration-domain cardinality (COLLECTING-LOOPS.md)
#
# An *iteration domain* is one clause of a collecting loop: the List a
# `loop x in xs:` walks, or the Int interval a `loop i from a to b:` /
# `through` / `down from` visits. Every domain has a cardinality -- how many
# times it advances -- and that cardinality is a compile-time proof concept
# only: no runtime object, no source-visible count.
#
# The exact cardinality of each domain, as mathematics (no machine-width
# arithmetic, no `end + 1`):
#
#   x in L                     length(L)
#   i from a to b              max(b - a,     0)
#   i from a through b         max(b - a + 1, 0)
#   i down from b to a         max(b - a,     0)
#   i down from b through a    max(b - a + 1, 0)
#
# (with `start` = the first-written operand: a for `from`, b for `down
# from`, so the formulas above read  max(end - start + 1, 0)  for `up` and
# max(start - end + 1, 0) for `down`, plus the exclusive variants.)
#
# Proof representation. A cardinality is kept as a *linear form* over
# symbolic atoms,
#
#     FORM = {CONST {ATOM COEFF ATOM COEFF ...}}       (atoms sorted)
#
# and `max(F, 0)` is folded into the form: a form that is provably >= 0
# stays itself, a constant clamps to a constant, anything else becomes the
# single nonnegative atom {max F}. Two cardinalities are then
#
#   equal      iff their normalized forms are identical;
#   unequal    iff they differ by a nonzero constant (both are >= 0, so a
#              constant gap is a real gap);
#   unknown    otherwise.
#
# Atoms name immutable values, never mutable state, so equal atoms really
# are the same value (the same single-assignment argument hir/exactvalue.tcl
# relies on):
#
#   {len KEY}   the length of one List value (KEY identifies the value,
#               ValueKey: {b B} for a parameter / loop binding B, {p KEY
#               FIELD} for a field path, {e E} for the defining expression E
#               an alias chain ends at), always >= 0 -- also the length of
#               a MutableVector nothing can change (IterationLength); or the
#               length a loop domain over a MutableVector something can
#               change had when that one loop evaluated its iterable
#               expression E: KEY is then {o E}, the occurrence itself,
#               never its binding, path or definition (IterationLength)
#   {cap KEY}   the capacity of one MutableArray value (KEY as for len),
#               always >= 0 and fixed at allocation (STDLIB-NAMESPACES.md's
#               indexed-access proof is its one consumer besides lockstep)
#   {slen KEY}  the length (Unicode scalar values) of one String value (KEY
#               as for len), always >= 0 (the slice proof of
#               STDLIB-NAMESPACES.md)
#   {max FORM}  max(FORM, 0), always >= 0
#   {v B}       the Int bound to binding B (a parameter, loop variable ...)
#   {e E}       the Int value of the single expression E that no rule above
#               folds; only ever equal to itself
#
# Facts reused rather than reinvented: hir/exactvalue.tcl (exact Ints and
# exact List literals, followed through immutable bindings), the `+ - *`,
# `std::list::length` and `std::mutable_array::capacity` natives (and
# `std::mutable_array::allocate`'s capacity operand), and this file's own exact/max output-length
# fact for collecting loops (a `ys = loop x in xs: ...` without
# break/continue has exactly length(xs) elements). No relational List-length
# inference is added.
#
#   hir::cardinality::domains HIR E        -> the domain dicts of loop E
#   hir::cardinality::of_domain HIR D      -> cardinality FORM of domain D
#   hir::cardinality::compare F1 F2        -> equal | unequal | unknown
#   hir::cardinality::show HIR F           -> source-like text of F

namespace eval hir::cardinality {
    variable maxSteps 96
}

# ---- linear forms ----------------------------------------------------------

proc hir::cardinality::FormConst {c} { return [list $c {}] }
proc hir::cardinality::FormAtom {atom} { return [list 0 [list $atom 1]] }

proc hir::cardinality::FormAdd {a b {sign 1}} {
    lassign $a ca ta
    lassign $b cb tb
    set terms [dict create {*}$ta]
    dict for {atom coeff} $tb {
        set n [dict getdef $terms $atom 0]
        set n [expr {$n + $sign * $coeff}]
        if {$n == 0} {
            dict unset terms $atom
        } else {
            dict set terms $atom $n
        }
    }
    set sorted {}
    foreach atom [lsort [dict keys $terms]] {
        lappend sorted $atom [dict get $terms $atom]
    }
    return [list [expr {$ca + $sign * $cb}] $sorted]
}

proc hir::cardinality::FormScale {a k} {
    lassign $a c terms
    if {$k == 0} {
        return [FormConst 0]
    }
    set scaled {}
    foreach {atom coeff} $terms {
        lappend scaled $atom [expr {$coeff * $k}]
    }
    return [list [expr {$c * $k}] $scaled]
}

proc hir::cardinality::IsConst {a} { return [expr {[lindex $a 1] eq ""}] }

# True if FORM is provably >= 0: a nonnegative constant plus positive
# multiples of atoms that are themselves always nonnegative.
proc hir::cardinality::NonNeg {a} {
    lassign $a c terms
    if {$c < 0} {
        return 0
    }
    foreach {atom coeff} $terms {
        if {[lindex $atom 0] ni {len cap slen max} || $coeff < 0} {
            return 0
        }
    }
    return 1
}

# max(FORM, 0), folded back into a form (see above).
proc hir::cardinality::Clamp {a} {
    if {[IsConst $a]} {
        return [FormConst [expr {max([lindex $a 0], 0)}]]
    }
    if {[NonNeg $a]} {
        return $a
    }
    return [FormAtom [list max $a]]
}

# ---- symbolic evaluation of immutable values --------------------------------

# Follows aliases from expression E: a `ref` to a single-assignment local
# binding continues at that binding's one `bind` value. Returns {expr D} for
# the first non-alias expression reached, or {binding B} for a binding with
# no defining expression (a parameter, a loop variable, a root name).
proc hir::cardinality::Chase {hir e stepsVar} {
    variable maxSteps
    upvar 1 $stepsVar steps
    while 1 {
        incr steps
        set node [dict get $hir exprs $e]
        if {$steps > $maxSteps || [dict get $node kind] ne "ref"} {
            return [list expr $e]
        }
        set b [dict get $node binding]
        if {$b eq ""} {
            return [list expr $e]
        }
        set binding [dict get $hir bindings $b]
        if {[dict get $binding kind] ne "local"} {
            return [list binding $b]
        }
        set declaration [dict get $binding declaredBy]
        if {$declaration eq ""} {
            return [list binding $b]
        }
        set bind [dict get $hir exprs $declaration]
        if {[dict get $bind kind] ne "bind" || [dict get $bind duplicate]} {
            return [list binding $b]
        }
        set e [dict get $bind value]
    }
}

# The key of the value of expression E in a size atom ({len KEY}, {cap
# KEY}, {slen KEY}): {b B} when E's alias chain (Chase) ends at a binding B
# with no defining expression (a parameter, a loop variable, a root name);
# {p KEY FIELD} when it ends at a projection E'.FIELD, KEY the key of the
# projection's receiver; else {e D}, the expression D it ends at, which
# names only itself. A field path names one value however often it is
# written: its root is a single-assignment binding (or one expression
# evaluated once per binding of its alias), and a struct's fields are
# immutable, so `t.slots` written twice is one MutableArray -- whose
# capacity is fixed, even when it is mutated in place through that field
# place (MUTABLE-ARRAY.md) -- and `b.cells` written twice one List. That is
# what lets a guard or a reduction on `t.slots.capacity()` prove the read
# `t.slots.at(i)` and the write `t.slots.set(i, v)`: the write has no
# local-alias form, a local `s = t.slots` being a logical copy. A key names
# one value, not one length: a field (or binding) holding a MutableVector
# holds one vector whose length a push changes in place, so a size form
# measures a vector by its key only where nothing can change it
# (IterationLength).
proc hir::cardinality::ValueKey {hir e stepsVar} {
    upvar 1 $stepsVar steps
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [list b $id]
    }
    set node [dict get $hir exprs $id]
    if {[dict get $node kind] eq "project"} {
        return [list p [ValueKey $hir [dict get $node receiver] steps] [dict get $node name]]
    }
    return [list e $id]
}

proc hir::cardinality::NativeName {hir node} {
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    lassign [dict get $node target] kind target
    if {$kind ne "native"} {
        return ""
    }
    return [dict get [hir::symbol $hir $target] name]
}

# The linear form of the Int expression E.
proc hir::cardinality::IntForm {hir e stepsVar} {
    upvar 1 $stepsVar steps
    set exact [hir::exact::IntOf $hir $e]
    if {$exact ne ""} {
        return [FormConst $exact]
    }
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [FormAtom [list v $id]]
    }
    set node [dict get $hir exprs $id]
    set name [NativeName $hir $node]
    if {$name eq ""} {
        set args {}
    } else {
        set args [dict get $node args]
    }
    if {$name in {+ -} && [llength $args] == 2} {
        set x [IntForm $hir [lindex $args 0] steps]
        set y [IntForm $hir [lindex $args 1] steps]
        return [FormAdd $x $y [expr {$name eq "+" ? 1 : -1}]]
    }
    if {$name eq "*" && [llength $args] == 2} {
        set x [IntForm $hir [lindex $args 0] steps]
        set y [IntForm $hir [lindex $args 1] steps]
        if {[IsConst $x]} {
            return [FormScale $y [lindex $x 0]]
        }
        if {[IsConst $y]} {
            return [FormScale $x [lindex $y 0]]
        }
    }
    if {$name eq "std::list::length" && [llength $args] == 1} {
        return [ListLength $hir [lindex $args 0] steps]
    }
    if {$name eq "std::mutable_array::capacity" && [llength $args] == 1} {
        return [Capacity $hir [lindex $args 0] steps]
    }
    if {$name eq "std::mutable_vector::length" && [llength $args] == 1} {
        return [VectorLength $hir [lindex $args 0] steps]
    }
    if {$name eq "std::str::length" && [llength $args] == 1} {
        return [StrLength $hir [lindex $args 0] steps]
    }
    return [FormAtom [list e $id]]
}

# The length, in Unicode scalar values, of the String value of expression
# E, as a (nonnegative) form: the exact length of an exactly known String
# (hir/exactvalue.tcl: a literal, followed through immutable bindings); the
# sum of the operands' lengths for `std::str::concat`; the operand's length for
# `std::str::lowercase` (a simple, one-to-one case mapping); END - START for a
# `std::str::substring(s, START, END)` that returned; else the atom {slen KEY},
# keyed like `len` (ValueKey) -- a String is immutable, so equal keys are
# equal lengths.
proc hir::cardinality::StrLength {hir e stepsVar} {
    upvar 1 $stepsVar steps
    set fact [hir::exact::Of $hir $e]
    if {[lindex $fact 0] eq "val" && [core::value::kind [lindex $fact 1]] eq "str"} {
        return [FormConst [string length [core::value::strOf [lindex $fact 1]]]]
    }
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [FormAtom [list slen [list b $id]]]
    }
    set node [dict get $hir exprs $id]
    set name [NativeName $hir $node]
    if {$name eq ""} {
        set args {}
    } else {
        set args [dict get $node args]
    }
    switch -- $name/[llength $args] {
        std::str::concat/2 {
            return [FormAdd [StrLength $hir [lindex $args 0] steps] [StrLength $hir [lindex $args 1] steps]]
        }
        std::str::lowercase/1 {
            return [StrLength $hir [lindex $args 0] steps]
        }
        std::str::substring/3 {
            return [FormAdd [IntForm $hir [lindex $args 2] steps] [IntForm $hir [lindex $args 1] steps] -1]
        }
    }
    return [FormAtom [list slen [ValueKey $hir $id steps]]]
}

# The capacity of the MutableArray value of expression E, as a (nonnegative)
# form: the allocation's own capacity operand when E is (an alias of) a
# `std::mutable_array::allocate` call -- an allocation that returns has exactly
# that capacity -- or of one of the library's intrinsic container
# operations hir/containers.tcl registers (its `create` rule: the capacity
# operand; its `from-list` rule: the List's length), else the atom
# {cap KEY}, keyed like `len` (ValueKey: a field path too). A MutableArray's
# capacity is fixed at allocation and never changes (core/mutarray.tcl), and
# an immutable binding holds one array for its whole lifetime, so equal
# atoms are the same capacity even though the array's *contents* mutate.
proc hir::cardinality::Capacity {hir e stepsVar} {
    upvar 1 $stepsVar steps
    lassign [Chase $hir $e steps] kind id
    if {$kind eq "binding"} {
        return [FormAtom [list cap [list b $id]]]
    }
    set node [dict get $hir exprs $id]
    # An array constructor makes as many slots as its registration's
    # -result-length says (core/native.tcl): its Int capacity argument
    # (allocate, create, generate) or the length of its List argument
    # (from_list).
    set name [NativeName $hir $node]
    if {$name ne ""} {
        set length [dict get [core::native::metadata $name] resultLength]
        set args [dict get $node args]
        if {[lindex $length 0] in {int list} && [lindex $length 1] < [llength $args]} {
            lassign $length how index
            set arg [lindex $args $index]
            if {$how eq "int"} {
                return [IntForm $hir $arg steps]
            }
            return [ListLength $hir $arg steps]
        }
    }
    return [FormAtom [list cap [ValueKey $hir $id steps]]]
}

# The length of the List value of expression E, as a (nonnegative) form.
# E's value is a List wherever its length is read -- an operand a List
# native takes (std::list::length, std::list::at, a slice, an array's construction
# from a List), which fails on anything else, or the iterable of a loop
# that requires one -- or a MutableArray a loop walks, whose length is
# fixed too, or a MutableVector nothing can change (IterationLength), so
# the length of one is its key's (ValueKey).
#
# The exact length a value's static type states (List[T]{length: N},
# LIST-CARDINALITY-REFINEMENTS.md) is the constant N: the type of the
# expression the alias chain ends at, or the declared type of the binding it
# ends at (DefinedLength) -- both describe every value of the key, wherever
# it is read, so every form of one value agrees. That is the one source of
# a constant length: a List literal, std::list::append's result and a copy of a
# fixed array (std::binary::load, std::binary::read: -result-length) state theirs in
# their types (hir::types::MintLength), so no case here repeats them. What
# stays here is what no type states: an exact value (hir::exact), and a
# collecting loop's length symbolic in its domain's (`len` atoms). A
# refinement only a guard proves of one read (the narrowed static type of a
# `ref` inside `if std::list::length(xs) == 4:`) is that read's own
# (TypedLength), which a proof adds beside this form (hir/completions.tcl's
# sizes), as it adds the size a branch proved (ctx.sizes).
proc hir::cardinality::ListLength {hir e stepsVar} {
    upvar 1 $stepsVar steps
    set fact [hir::exact::ListOf $hir $e]
    if {$fact ne ""} {
        return [FormConst [hir::exact::Length $fact]]
    }
    lassign [Chase $hir $e steps] kind id
    set n [DefinedLength $hir $kind $id]
    if {$n ne ""} {
        return [FormConst $n]
    }
    if {$kind eq "binding"} {
        return [FormAtom [list len [list b $id]]]
    }
    set node [dict get $hir exprs $id]
    switch -- [dict get $node kind] {
        listloop - countloop - lockloop {
            if {[of_loop $hir $id] eq "exact"} {
                set domains [domains $hir $id]
                return [of_domain $hir [lindex $domains 0] steps]
            }
        }
    }
    return [FormAtom [list len [ValueKey $hir $id steps]]]
}

# The exact length every value of what an alias chain ends at (Chase's KIND
# and ID) has by its type, or "": an expression whose static type states it,
# a parameter whose declared (or trusted inferred) type does
# (hir::signatures::entryTypes), a loop variable over a List whose element
# type does. A value's static type is a fact of every value it describes
# (hir/types.tcl), and a declared parameter type of every argument the
# function is ever called with (hir::range::VerifyCall admits none other).
proc hir::cardinality::DefinedLength {hir kind id} {
    if {$kind eq "expr"} {
        return [hir::types::LengthOf [hir::typeOf $hir $id]]
    }
    set binding [dict get $hir bindings $id]
    if {[dict get $binding kind] ne "param"} {
        return ""
    }
    set scope [dict get $hir scopes [dict get $binding scope]]
    set owner [dict get $scope owner]
    if {$owner eq "" || ![dict exists $hir exprs $owner]} {
        return ""
    }
    set node [dict get $hir exprs $owner]
    switch -- [dict get $node kind] {
        block {
            set index [lsearch -exact [dict get $node params] $id]
            if {$index < 0} {
                return ""
            }
            return [hir::types::LengthOf [lindex [hir::signatures::entryTypes $hir $owner] $index]]
        }
        listloop {
            if {[dict get $node elementBinding] eq $id} {
                return [hir::types::LengthOf [hir::types::elementOf [hir::typeOf $hir [dict get $node iterable]]]]
            }
        }
        lockloop {
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list" && [dict get $domain binding] eq $id} {
                    return [hir::types::LengthOf [hir::types::elementOf [hir::typeOf $hir [dict get $domain iterable]]]]
                }
            }
        }
    }
    return ""
}

# The exact length the static type of the read E itself states -- a guard's
# refinement of one `ref` included (hir/refine.tcl) -- or "".
proc hir::cardinality::TypedLength {hir e} {
    return [hir::types::LengthOf [hir::typeOf $hir $e]]
}

# The number of elements the list domain over the iterable expression E
# visits: the length E's value has when its loop evaluates E, once. A loop
# walks a List -- an iterable of any static type but MutableVector and
# MutableArray must be one when the loop runs (its TYPE check, on every
# backend) -- or the snapshot (or, affine, the consumption) of a
# MutableArray or MutableVector (MUTABLE-VECTOR.md, MUTABLE-ARRAY.md). A
# List's length never changes (it is immutable), nor does a MutableArray's
# (its capacity, fixed at allocation), so a binding, field path or
# definition that names one names one length: ListLength's, keyed by it.
#
# A MutableVector's length does change, in place, while its binding, path
# or member stays the same: through a mutating operation (hir::mutvec::
# OpKind) that may change a length (Resizes: one registered -keeps-length,
# a swap, never does) whose receiver is a place holding it -- a binding or
# a field path of the function itself (MUTABLE-PLACE-RECEIVER; an operation
# that mutates is only ever called, never a value) -- or a callee's through
# its own context parameter, the installed context every function
# requiring it shares. Nothing else reaches it: a vector is a value, so an
# alias, a struct field or a callee's parameter given it holds a logical
# copy no mutation of the original changes (hir::mutvec's elaboration), and
# a nested function cannot mutate a place it captured.
#
# So a vector keeps its key's length (ListLength) when its key is not
# rooted at a context parameter and no place its value was copied through
# on its way from the key's definition (KeyPlaces: `w` and `v` for `w =
# v`) is a receiver that resizes, anywhere in the program (Mutations): its
# value is then that definition's, unchanged, wherever it is evaluated. A
# copy pushed elsewhere (`u = v; u.push(x)`) changes neither. Otherwise it
# is measured by its place (hir::mutvec::Path: a binding and a field path
# from it), which no mutation of another place changes: a place nothing
# resizes keeps one length, the atom {len {pl B FIELD...}}, wherever it is
# evaluated -- unless its root is a context parameter, whose member
# another function may grow (a local copy of a member, `items =
# log.items`, is no such place). The evaluations of any other place have
# the length the vector has at that evaluation, which each shares with
# every evaluation of the same place no mutation can come between
# (Evaluation): the atom {len {o R}}, R the first of those evaluations in
# evaluation order, equal to no other's. Two loops over such a vector with
# a push between them have unrelated lengths, as do the vector and a List
# an earlier loop collected over it; two with nothing that can mutate it
# between them -- built with pushes, then walked twice -- have one. An
# evaluation with no such class (no place, or a mutation before it in its
# own statement) has its own atom, {len {o E}}. (Two clauses of one
# lockstep loop over one place, `loop a in v and c in v`, are one class
# unless a site runs before or between them: a lockstep loop evaluates its
# domains once, in written order, before its first iteration, and the
# sites of its body run after them.)
proc hir::cardinality::IterationLength {hir e stepsVar} {
    upvar 1 $stepsVar steps
    if {[hir::types::kindOf [hir::typeOf $hir $e]] ne "mutvec"} {
        return [ListLength $hir $e steps]
    }
    set key [CompleteKey $hir $e]
    if {$key ne "" && ![ContextRooted $hir $key] && [KeyPlaces $hir $e chain]} {
        set resized 0
        foreach place $chain {
            if {[Mutated $hir $place]} {
                set resized 1
                break
            }
        }
        if {!$resized} {
            return [FormAtom [list len $key]]
        }
    }
    set place [hir::mutvec::Path $hir $e]
    if {$place eq ""} {
        return [FormAtom [list len [list o $e]]]
    }
    set root [lindex $place 0]
    set context [ContextRooted $hir [list b $root]]
    if {!$context && ![Mutated $hir $place]} {
        return [FormAtom [list len [list pl {*}$place]]]
    }
    if {$context} {
        set contextIds [list [ContextIdOf $hir $root]]
    } else {
        set contextIds {}
    }
    set first [Evaluation $hir $e $place $contextIds]
    if {$first eq ""} {
        set first $e
    }
    return [FormAtom [list len [list o $first]]]
}

# The length of the MutableVector value of expression E, as a form, where a
# length read (std::mutable_vector::length) and an element read
# (std::mutable_vector::at) must agree on it: IterationLength's stable
# lengths, and only those -- the length of the vector its key defines when
# no place it was copied through is resized anywhere in the program, or of
# its place when nothing resizes that place (Mutated: neither a resizing
# operation on it nor a call giving a place parameter a place whose path
# overlaps it), its root never a context parameter. Every other evaluation
# is an atom of its own, {vlen {o E}}, equal to no other form: two reads of
# a vector something may push into between them prove nothing about each
# other (an epoch of a loop's iterable, IterationLength's {len {o R}}, is
# not claimed here). A vector is a value: an alias, a struct field or a
# callee's parameter given it holds a logical copy no mutation of the
# original changes (hir/mutvec.tcl), a callee given it by reference only
# reads it while its caller waits, and a nested function cannot mutate a
# place it captured -- so a place nothing resizes has one length wherever
# it is read.
proc hir::cardinality::VectorLength {hir e stepsVar} {
    upvar 1 $stepsVar steps
    set key [CompleteKey $hir $e]
    if {$key ne "" && ![ContextRooted $hir $key] && [KeyPlaces $hir $e chain]} {
        set resized 0
        foreach place $chain {
            if {[Mutated $hir $place]} {
                set resized 1
                break
            }
        }
        if {!$resized} {
            return [FormAtom [list len $key]]
        }
    }
    set place [hir::mutvec::Path $hir $e]
    if {$place ne "" && ![ContextRooted $hir [list b [lindex $place 0]]] && ![Mutated $hir $place]} {
        return [FormAtom [list len [list pl {*}$place]]]
    }
    return [FormAtom [list vlen [list o $e]]]
}

# The key of expression E (ValueKey), followed to the end of its alias
# chains with a step budget of its own, or "" when the budget ran out
# first: a key cut short names a point of a chain another expression's key
# may pass beyond, so two such keys can differ for one value.
proc hir::cardinality::CompleteKey {hir e} {
    variable maxSteps
    set steps 0
    set key [ValueKey $hir $e steps]
    if {$steps > $maxSteps} {
        return ""
    }
    return $key
}

# The places E's value was read from on its way from its key's definition
# (ValueKey's walk, under CompleteKey's budget): each binding the alias
# chains pass, as a place path (hir::mutvec::Path's {BINDING {FIELD...}})
# with the fields the value lies at in it -- `b.v`, with `b = a`, passes
# {b {v}} and {a {v}}. Stores them in PLACESVAR and returns 1, or returns 0
# when the walk ran out of steps.
proc hir::cardinality::KeyPlaces {hir e placesVar} {
    variable maxSteps
    upvar 1 $placesVar places
    set places {}
    set fields {}
    set steps 0
    while 1 {
        while 1 {
            incr steps
            if {$steps > $maxSteps} {
                return 0
            }
            set node [dict get $hir exprs $e]
            if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} {
                break
            }
            set b [dict get $node binding]
            lappend places [list $b $fields]
            set binding [dict get $hir bindings $b]
            set declaration [dict get $binding declaredBy]
            if {[dict get $binding kind] ne "local" || $declaration eq ""} {
                return 1
            }
            set bind [dict get $hir exprs $declaration]
            if {[dict get $bind kind] ne "bind" || [dict get $bind duplicate]} {
                return 1
            }
            set e [dict get $bind value]
        }
        if {[dict get $node kind] ne "project"} {
            return 1
        }
        set fields [linsert $fields 0 [dict get $node name]]
        set e [dict get $node receiver]
    }
}

# 1 if value key KEY (ValueKey) is rooted at a context parameter: the load
# of an installed context (hir::contexts::isLoad), or a binding bound to
# one.
proc hir::cardinality::ContextRooted {hir key} {
    while {[lindex $key 0] eq "p"} {
        set key [lindex $key 1]
    }
    lassign $key how what
    if {$how eq "e"} {
        return [hir::contexts::isLoad $hir $what]
    }
    set by [dict get $hir bindings $what declaredBy]
    return [expr {$by ne "" && [dict exists $hir exprs $by] && [dict get $hir exprs $by kind] eq "bind"
        && [hir::contexts::isLoad $hir [dict get $hir exprs $by value]]}]
}

# 1 if call C is a mutating collection operation (hir::mutvec::OpKind) that
# may change its receiver's length: every one but those registered
# -keeps-length (core/native.tcl), which only replace elements.
proc hir::cardinality::Resizes {hir c} {
    if {[hir::mutvec::OpKind $hir $c] ne "mutate"} {
        return 0
    }
    return [expr {![dict get [core::native::metadata [hir::affine::NativeName $hir $c]] keepsLength]}]
}

# The places call C may change a collection's length in: the receiver of a
# collection operation that Resizes, and every place a call of a function
# with place parameters gives one (PLACE-PARAMETERS.md: the function may
# push into or clear any collection under the place's path), as
# hir::mutvec::Path paths (a receiver that is no place, a temporary,
# changes no place's length).
proc hir::cardinality::ResizedPlaces {hir c} {
    set args [dict get $hir exprs $c args]
    set result {}
    if {[Resizes $hir $c]} {
        set receiver [lindex $args 0]
        if {$receiver ne ""} {
            set place [hir::mutvec::Path $hir $receiver]
            if {$place ne ""} {
                lappend result $place
            }
        }
        return $result
    }
    foreach index [hir::mutvec::PlaceIndices $hir $c] {
        set arg [lindex $args $index]
        if {$arg eq ""} continue
        set place [hir::mutvec::Path $hir $arg]
        if {$place ne ""} {
            lappend result $place
        }
    }
    return $result
}

# The operations of HIR that may change a collection's length
# (ResizedPlaces), grouped by the place they change: {PLACE {CALL ...}
# ...}, PLACE a hir::mutvec::Path. Reachable or not: a mutation counts
# wherever it is written.
proc hir::cardinality::Mutations {hir} {
    variable cache
    Memo $hir
    if {![dict exists $cache mutations]} {
        set mutations [dict create]
        dict for {c node} [dict get $hir exprs] {
            if {[dict get $node kind] ne "call"} continue
            foreach place [ResizedPlaces $hir $c] {
                dict lappend mutations $place $c
            }
        }
        dict set cache mutations $mutations
    }
    return [dict get $cache mutations]
}

# 1 if some operation of HIR may change the length of the collection at
# place PLACE (Mutations): one changing PLACE itself, or a place whose path
# overlaps it -- a struct holding it given to a place parameter
# (hir::mutvec::Overlap).
proc hir::cardinality::Mutated {hir place} {
    if {[dict exists [Mutations $hir] $place]} {
        return 1
    }
    foreach q [dict keys [Mutations $hir]] {
        if {[hir::mutvec::Overlap $q $place]} {
            return 1
        }
    }
    return 0
}

# The first evaluation (an iterable expression) of the MutableVector place
# PLACE that no site can separate from the evaluation E, or "" when E has
# no such class: no quiet run holds it (Epoch). CONTEXT is {} for a place
# of the function's own, or {ID} for a member of the installed context ID
# its root, a context parameter, loads.
#
# The evaluations of one invocation (a function body, or the top-level
# code) run in a statically known order: a body is a sequence of
# statements, each run once per run of the body. A *site* is what can
# change the vector's length between two evaluations: an operation of the
# same invocation that may resize its receiver (Resizes) whose receiver is
# PLACE -- one of another place, a copy keyed like it included, changes
# only that place -- and, for a context member, also every call that may
# run code changing it (ContextSite: a callee that requires the context,
# a coroutine segment, a yield, after which the resumer runs before the
# body goes on). A nested function cannot mutate a place it captured, and
# running it is a call here. An evaluation of PLACE sees the
# vector its invocation last left: one length from one site to the next.
# So two evaluations in one *quiet run* of a body -- consecutive statements
# none of which holds a site -- see one length, however deep each sits in
# its statement (a loop body, a branch), as long as both run in that one
# run of the body: each statement of the run runs once in it, and a value
# of an evaluation in a loop's body never outlives the iteration it was
# made in. An evaluation in a statement that holds a site lies in one of
# the statement's bodies or in its operands -- a loop's domains, a call's
# arguments -- which run once, in evaluation order: before every site of
# the statement, it belongs to the quiet run before the statement, else to
# none. In a body, its classes are the body's, except that the first run
# of a body that runs at most once per run of the statement (a branch, a
# handler), entered with no site before it, continues the statement's run
# (Epoch).
proc hir::cardinality::Evaluation {hir e place context} {
    variable cache
    Memo $hir
    set inv [dict get $hir scopes [dict get $hir exprs $e scope] invocation]
    set id [list $inv $place $context]
    if {![dict exists $cache evaluations $id]} {
        set layout [Layout $hir $inv]
        set sites {}
        foreach c [dict get $layout calls] {
            set site 0
            foreach q [ResizedPlaces $hir $c] {
                if {[hir::mutvec::Overlap $q $place]} {
                    set site 1
                    break
                }
            }
            if {$site} {
                lappend sites $c
                continue
            }
            if {$context ne {} && [ContextSite $hir $c [lindex $context 0]]} {
                lappend sites $c
            }
        }
        set first [dict create]
        set classes [dict create]
        foreach o [dict get $layout iterables] {
            if {[hir::types::kindOf [hir::typeOf $hir $o]] ne "mutvec" || [hir::mutvec::Path $hir $o] ne $place} continue
            set epoch [Epoch $layout $sites $o]
            if {$epoch eq ""} continue
            if {![dict exists $first $epoch]} {
                dict set first $epoch $o
            }
            dict set classes $o [dict get $first $epoch]
        }
        dict set cache evaluations $id $classes
    }
    set classes [dict get $cache evaluations $id]
    return [dict getdef $classes $e ""]
}

# 1 if call C, in an invocation reading a member of the installed context
# ID through its context parameter, may run code that changes that member
# before C returns: a function whose own context parameter is that same
# installed value (MUTABLE-PLACE-RECEIVER confines every other mutation to
# the place's own function), or a coroutine body or a resumer that may run
# one. That is (CallReach):
#
#   - a native whose registration runs Botlish code (-completion: a
#     coroutine segment, a callable argument), or a yield (the resumer runs
#     before it returns);
#   - a trait operation: its implementation is bound only in the
#     monomorphized program (hir::traits), so it may be anything;
#   - a call of a block (hir::contexts::Callee: a function, an alias of one,
#     the thunk a coroutine construction runs) whose run may (Reaching): one
#     that loads ID itself -- requires it -- or makes such a call;
#   - a call of a coroutine handle (a resume), or a call through a function
#     value given an affine argument: the function is context-free and never
#     yields (no other function becomes a value: CONTEXT-FUNCTION-VALUE,
#     UNWRAPPED-YIELD), but it may resume a coroutine handle the argument
#     carries.
#
# Nothing else reaches the installed value: a context is obtained only
# through a context parameter (CONTEXTS.md), and a context value passed or
# stored is a copy (an ordinary parameter's place shares its entry), or
# captured, which is no place.
proc hir::cardinality::ContextSite {hir c id} {
    set reach [CallReach $hir $c $id 0]
    if {[lindex $reach 0] eq "block"} {
        return [dict exists [Reaching $hir $id] [lindex $reach 1]]
    }
    return $reach
}

# How call C may reach the installed context ID's members (ContextSite; ID
# "" when the place's root does not tell which context it loads: any): 1
# (it may), 0 (it cannot), or {block B}, the block it runs, which may if B's
# run may (Reaching). With LOADS 1 a load of ID (or of a context it cannot
# tell apart) may: C is then in a function that requires ID.
proc hir::cardinality::CallReach {hir c id loads} {
    set node [dict get $hir exprs $c]
    if {[dict exists $node traitCall]} {
        return 1
    }
    set callee [hir::contexts::Callee $hir $c]
    lassign [dict get $node target] kind target
    if {$kind eq "native"} {
        if {[catch {core::native::metadata [dict get [hir::symbol $hir $target] name]} meta]
                || [dict get $meta completion] || [dict exists $hir coroutines yields $c]} {
            return 1
        }
        if {$loads && [hir::contexts::isLoad $hir $c]} {
            # (ID or the load's own identity "": one it cannot tell, any.)
            set loaded [hir::contexts::loadId $hir $c]
            if {$id eq "" || $loaded eq "" || $loaded eq $id} {
                return 1
            }
        }
        if {$callee eq ""} {
            return 0
        }
    }
    if {$callee ne ""} {
        return [list block $callee]
    }
    # Through a value: a coroutine handle called resumes it (before
    # hir::coroutines::ElaborateResumes makes the call coroutine#resume),
    # and an affine argument may carry one the function resumes.
    foreach operand [concat [list [dict get $node callee]] [dict get $node args]] {
        if {[hir::types::IsAffine [hir::typeOf $hir $operand]]} {
            return 1
        }
    }
    return 0
}

# The blocks of HIR whose run may change a member of the installed context
# ID (ContextSite), as a dict: the least fixed point over exact call edges
# of the blocks that load ID or make a call that may (CallReach), memoized
# per pass.
proc hir::cardinality::Reaching {hir id} {
    variable cache
    Memo $hir
    if {![dict exists $cache reaching $id]} {
        set reaching [dict create]
        set callers [dict create]
        dict for {b node} [dict get $hir exprs] {
            if {[dict get $node kind] ne "block"} continue
            foreach c [dict get [Layout $hir $b] calls] {
                set reach [CallReach $hir $c $id 1]
                if {[lindex $reach 0] eq "block"} {
                    dict lappend callers [lindex $reach 1] $b
                } elseif {$reach} {
                    dict set reaching $b 1
                }
            }
        }
        set work [dict keys $reaching]
        while {$work ne {}} {
            set work [lassign $work b]
            if {![dict exists $callers $b]} continue
            foreach caller [dict get $callers $b] {
                if {![dict exists $reaching $caller]} {
                    dict set reaching $caller 1
                    lappend work $caller
                }
            }
        }
        dict set cache reaching $id $reaching
    }
    return [dict get $cache reaching $id]
}

# The context identity binding B, a context parameter, loads ("" when it
# cannot tell).
proc hir::cardinality::ContextIdOf {hir b} {
    set by [dict get $hir bindings $b declaredBy]
    return [hir::contexts::loadId $hir [dict get $hir exprs $by value]]
}

# The class of evaluation O (Evaluation) among the sites SITES of LAYOUT's
# invocation: {SEQUENCE RUN}, the quiet run RUN (the number of statements
# before it that hold a site) of the body SEQUENCE, or "" for none.
#
# O lies in a statement of each body on its path, outermost first. Where
# that statement holds no site, O is in the statement's run. Where it holds
# one and O is one of its operands, O is in the run before it if every site
# of the statement runs after O, else in none. Where it holds one and O is
# in one of its bodies, O's class is that body's: a loop's body runs again
# after its own sites, so each of its runs is its own. A body that runs at
# most once per run of its statement -- an if's branch, a handler -- is
# different: entered with no site of the statement before it (none in the
# condition or the handled call, none in an earlier operand; the other
# branch and the other handlers never run before it), its first run
# continues the run its statement is in. So an evaluation in a branch before
# the branch's own push shares the length of the evaluations before the if.
proc hir::cardinality::Epoch {layout sites o} {
    if {![dict exists $layout path $o]} {
        return ""
    }
    set path [dict get $layout path $o]
    set depth [llength $path]
    set pre [dict get $layout pre $o]
    set post [dict get $layout post $o]
    # The class the first run of O's current body continues, or "".
    set continued ""
    for {set l 0} {$l < $depth} {incr l} {
        lassign [lindex $path $l] sequence index
        set prefix [lrange $path 0 $l-1]
        set noisy [dict create]
        set here {}
        foreach s $sites {
            set at [dict get $layout path $s]
            if {[llength $at] <= $l || [lrange $at 0 $l-1] ne $prefix} continue
            lassign [lindex $at $l] other i
            if {$other ne $sequence} continue
            if {$i < $index} {
                dict set noisy $i 1
            } elseif {$i == $index} {
                lappend here $s
            }
        }
        set run [dict size $noisy]
        if {$run == 0 && $continued ne ""} {
            set class $continued
        } else {
            set class [list $sequence $run]
        }
        if {$here eq {}} {
            return $class
        }
        if {$l < $depth - 1} {
            # O is in a body of its statement.
            set body [lindex $path [expr {$l + 1}] 0]
            set continued ""
            if {[OnceBody $body]} {
                set continued $class
                foreach s $here {
                    set at [dict get $layout path $s]
                    if {[llength $at] > $l + 1} {
                        set other [lindex $at [expr {$l + 1}] 0]
                        if {$other eq $body || [Alternatives $body $other]} continue
                    }
                    if {![RunsAfter $layout $s $pre $post]} {
                        set continued ""
                        break
                    }
                }
            }
            continue
        }
        # O is an operand of a statement that holds a site.
        foreach s $here {
            if {![RunsAfter $layout $s $pre $post]} {
                return ""
            }
        }
        return $class
    }
    return ""
}

# 1 if body SEQUENCE (Layout) runs at most once per run of its statement:
# an if's branch or a handler's body.
proc hir::cardinality::OnceBody {sequence} {
    set part [lindex $sequence 1]
    return [expr {$part in {then else} || [string match handler* $part]}]
}

# 1 if bodies A and B (Layout) never both run in one run of their owner:
# the two branches of one if, or two handlers of one handled call.
proc hir::cardinality::Alternatives {a b} {
    lassign $a owner x
    lassign $b other y
    if {$owner ne $other || $x eq $y} {
        return 0
    }
    return [expr {([lsort [list $x $y]] eq {else then})
        || ([string match handler* $x] && [string match handler* $y])}]
}

# 1 if site S runs after the evaluation whose subtree spans LAYOUT's
# pre-order indices PRE..POST: later in evaluation order, or a call that
# evaluation is an operand of.
proc hir::cardinality::RunsAfter {layout s pre post} {
    set sPre [dict get $layout pre $s]
    return [expr {$sPre > $post || ($sPre < $pre && [dict get $layout post $s] >= $post)}]
}

# The evaluation-order layout of invocation INV (a block ExprId, or "" for
# the top-level code), not entering nested functions: {pre {E N ...} post
# {E N ...} path {E PATH ...} calls CALLS iterables ITERABLES}, every
# expression's pre-order index (pre), the last index of its subtree
# (post) and its PATH, the {SEQUENCE INDEX} statements of the bodies it
# lies in, outermost first (SEQUENCE {OWNER BODY}: the invocation's body,
# an if's then or else body, a loop's body, a handler's body; `program`
# for the top-level code); and its calls and loop domains' iterables, in
# evaluation order.
proc hir::cardinality::Layout {hir inv} {
    variable cache
    if {![dict exists $cache layouts $inv]} {
        set layout [dict create pre {} post {} path {} calls {} iterables {}]
        set n 0
        if {$inv eq ""} {
            LayoutBody $hir layout n program [dict get $hir roots] {}
        } else {
            LayoutBody $hir layout n [list $inv body] [dict get $hir exprs $inv body] {}
        }
        dict set cache layouts $inv $layout
    }
    return [dict get $cache layouts $inv]
}

proc hir::cardinality::LayoutBody {hir layoutVar nVar sequence body path} {
    upvar 1 $layoutVar layout $nVar n
    set index 0
    foreach s $body {
        LayoutNode $hir layout n $s [linsert $path end [list $sequence $index]]
        incr index
    }
}

proc hir::cardinality::LayoutNode {hir layoutVar nVar e path} {
    upvar 1 $layoutVar layout $nVar n
    dict set layout pre $e $n
    dict set layout path $e $path
    incr n
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        block {}
        if {
            LayoutNode $hir layout n [dict get $node condition] $path
            LayoutBody $hir layout n [list $e then] [dict get $node thenBody] $path
            LayoutBody $hir layout n [list $e else] [dict get $node elseBody] $path
        }
        loop {
            LayoutBody $hir layout n [list $e body] [dict get $node body] $path
        }
        listloop {
            dict lappend layout iterables [dict get $node iterable]
            LayoutNode $hir layout n [dict get $node iterable] $path
            LayoutBody $hir layout n [list $e body] [dict get $node body] $path
        }
        countloop {
            LayoutNode $hir layout n [dict get $node start] $path
            LayoutNode $hir layout n [dict get $node end] $path
            LayoutBody $hir layout n [list $e body] [dict get $node body] $path
        }
        lockloop {
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    dict lappend layout iterables [dict get $domain iterable]
                }
            }
            foreach operand [hir::loopOperands $node] {
                LayoutNode $hir layout n $operand $path
            }
            LayoutBody $hir layout n [list $e body] [dict get $node body] $path
        }
        handle {
            LayoutNode $hir layout n [dict get $node call] $path
            set k 0
            foreach body [dict get $node handlerBodies] {
                LayoutBody $hir layout n [list $e handler$k] $body $path
                incr k
            }
        }
        default {
            if {[dict get $node kind] eq "call"} {
                dict lappend layout calls $e
            }
            foreach child [hir::children $hir $e] {
                LayoutNode $hir layout n $child $path
            }
        }
    }
    dict set layout post $e [expr {$n - 1}]
}

# The memo of the vector-length analysis (Mutations, Evaluation, Layout)
# for one HIR, cleared by resetCache at the start of each pass that reads
# sizes (hir/lockstep.tcl's verify, hir::completions::resetCache) and
# whenever it is asked about a HIR of another shape (Memo).
namespace eval hir::cardinality {
    variable cache [dict create]
    variable stamp ""
}

proc hir::cardinality::resetCache {} {
    variable cache
    variable stamp
    set cache [dict create]
    set stamp ""
}

proc hir::cardinality::Memo {hir} {
    variable cache
    variable stamp
    set shape [list [dict size [dict get $hir exprs]] [dict size [dict get $hir bindings]] \
        [dict size [dict get $hir scopes]] [dict get $hir roots]]
    if {$shape ne $stamp} {
        set cache [dict create]
        set stamp $shape
    }
}

# ---- domains -----------------------------------------------------------------

# Loop E's iteration domains, in written order, as dicts
#   {kind list iterable EXPR}
#   {kind count start EXPR end EXPR direction D endKind K}
# (for lockloop, the node's own domains; for a single-domain loop, the one
# domain its own fields describe).
proc hir::cardinality::domains {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        listloop {
            return [list [dict create kind list iterable [dict get $node iterable]]]
        }
        countloop {
            return [list [dict create kind count start [dict get $node start] \
                end [dict get $node end] direction [dict get $node direction] \
                endKind [dict get $node endKind]]]
        }
        lockloop {
            return [dict get $node domains]
        }
    }
    error "hir::cardinality::domains: $e is not a collecting loop"
}

# The cardinality FORM of DOMAIN.
proc hir::cardinality::of_domain {hir domain {stepsVar ""}} {
    if {$stepsVar eq ""} {
        set steps 0
    } else {
        upvar 1 $stepsVar steps
    }
    if {[dict get $domain kind] eq "list"} {
        return [IterationLength $hir [dict get $domain iterable] steps]
    }
    set start [IntForm $hir [dict get $domain start] steps]
    set end [IntForm $hir [dict get $domain end] steps]
    # The elements strictly beyond START toward END, plus one for END itself
    # when the end is inclusive: max(END - START, 0) for an ascending loop,
    # max(START - END, 0) for a descending one, +1 when inclusive.
    if {[dict get $domain direction] eq "up"} {
        set span [FormAdd $end $start -1]
    } else {
        set span [FormAdd $start $end -1]
    }
    if {[dict get $domain endKind] eq "inclusive"} {
        set span [FormAdd $span [FormConst 1]]
    }
    return [Clamp $span]
}

proc hir::cardinality::compare {a b} {
    if {$a eq $b} {
        return equal
    }
    set gap [FormAdd $a $b -1]
    if {[IsConst $gap]} {
        return unequal
    }
    return unknown
}

# ---- rendering (diagnostics) --------------------------------------------------

proc hir::cardinality::show {hir form} {
    lassign $form c terms
    set parts {}
    foreach {atom coeff} $terms {
        set text [ShowAtom $hir $atom]
        if {abs($coeff) != 1} {
            set text "[expr {abs($coeff)}] * $text"
        }
        lappend parts [list [expr {$coeff < 0}] $text]
    }
    if {$c != 0 || $parts eq ""} {
        lappend parts [list [expr {$c < 0}] [expr {abs($c)}]]
    }
    set out ""
    foreach part $parts {
        lassign $part negative text
        if {$out eq ""} {
            if {$negative} {
                set out "-$text"
            } else {
                set out $text
            }
        } else {
            append out [expr {$negative ? " - " : " + "}] $text
        }
    }
    return $out
}

proc hir::cardinality::ShowAtom {hir atom} {
    lassign $atom kind what
    switch -- $kind {
        v { return [hir::semantic::SourceName $hir $what] }
        max { return "max([show $hir $what], 0)" }
        len { return "length([ShowKey $hir $what])" }
        cap { return "capacity([ShowKey $hir $what])" }
        slen { return "std::str::length([ShowKey $hir $what])" }
        e { return [ShowExpr $hir $what] }
    }
    return $atom
}

# Source-like text of a value key (ValueKey).
proc hir::cardinality::ShowKey {hir key} {
    lassign $key how what field
    switch -- $how {
        b { return [hir::semantic::SourceName $hir $what] }
        p { return "[ShowKey $hir $what].$field" }
        pl {
            # A place: its binding and field path.
            return [join [concat [list [hir::semantic::SourceName $hir $what]] $field] .]
        }
        o {
            # One evaluation of an iterable: its path and where it is
            # written, so that two loops over one vector read apart.
            set origin [dict get $hir exprs $what origin]
            set text [ShowPath $hir $what]
            set at [lrange $origin 2 end]
            if {[lindex $origin 0] eq "file" && [dict exists $at line] && [dict exists $at column]} {
                append text " at [dict get $at line]:[dict get $at column]"
            }
            return $text
        }
    }
    return [ShowExpr $hir $what]
}

# The source locations FORM's text (show) names besides its own: the origin
# of every evaluation it prints with "at LINE:COLUMN" (ShowKey's `o` keys),
# in print order -- a diagnostic's related origins (hir::Diagnose), so that
# no consumer reads them out of the message.
proc hir::cardinality::related {hir form} {
    set origins {}
    foreach {atom coeff} [lindex $form 1] {
        RelatedOfAtom $hir $atom origins
    }
    return $origins
}

proc hir::cardinality::RelatedOfAtom {hir atom originsVar} {
    upvar 1 $originsVar origins
    lassign $atom kind what
    switch -- $kind {
        max { lappend origins {*}[related $hir $what] }
        len - cap - slen { RelatedOfKey $hir $what origins }
    }
}

proc hir::cardinality::RelatedOfKey {hir key originsVar} {
    upvar 1 $originsVar origins
    lassign $key how what
    switch -- $how {
        p { RelatedOfKey $hir $what origins }
        o {
            set origin [dict get $hir exprs $what origin]
            set at [lrange $origin 2 end]
            if {[lindex $origin 0] eq "file" && [dict exists $at line] && [dict exists $at column]} {
                lappend origins $origin
            }
        }
    }
}

# Source-like text of E, a field path (`b.v`) written out.
proc hir::cardinality::ShowPath {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "project"} {
        return "[ShowPath $hir [dict get $node receiver]].[dict get $node name]"
    }
    return [ShowExpr $hir $e]
}

proc hir::cardinality::ShowExpr {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        ref {
            set b [dict get $node binding]
            if {$b eq ""} {
                return [dict get $node name]
            }
            return [hir::semantic::SourceName $hir $b]
        }
        call {
            set callee [dict get $node callee]
            if {[dict get $hir exprs $callee kind] eq "ref"} {
                set name [hir::semantic::RefName $hir $callee]
            } else {
                set name "<call>"
            }
            return "${name}(...)"
        }
        const { return [lindex [dict get $node literal] end] }
        listloop - countloop - lockloop { return "(loop result)" }
    }
    return "(expression)"
}
