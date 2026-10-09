# native.tcl -- registry of native (Tcl-backed) callables.
#
# A native callable value is {native NAME}; everything else about it lives
# in the registry:
#
#   name            source-level name
#   impl            Tcl command prefix; called with the argument values,
#                   must return a runtime value
#   arity           exact argument count, or * for any
#   refinesTrue     facts proven when the callable returns true
#   refinesFalse    facts proven when the callable returns false
#   paramTypes      types (type.tcl) the implementation *requires* of each
#                   argument (any = no requirement); a call that returns
#                   proves its arguments had these types. "" = unknown.
#   resultType      type of every result, or any
#   testsType       "" or a type T: the native is a *type test*, a pure
#                   one-argument predicate returning exactly whether its
#                   argument is a value of T (core::type::acceptsValue).
#                   Its parameter type must be any or a primitive kind P,
#                   with T a subtype of P; the runtime itself rejects
#                   arguments not of kind P (with core::value::expect's
#                   TYPE error) before calling the implementation. A type
#                   test refines its argument to T when it returns true.
#                   Knowing this, a compiler may decide the call from static
#                   types or replace it with an inline membership test.
#   nomethod        0 | 1 (default 0): the native's author declares that its
#                   receiver spelling reads badly, so `x.name(...)` never
#                   denotes it (WARNINGS-METHOD-ELIGIBLE.md): method sugar skips it as a
#                   candidate, and a method-style call whose only visible
#                   function of that name is a nomethod one is the
#                   NOMETHOD-CALL resolution error. Ordinary calls are
#                   unaffected, and so are its type, completion and code.
#                   Interface metadata of the callable, like arity: no
#                   shipped native sets it.
#   errors          the declared errors (core::native::declareError) a call
#                   of this native may complete with -- {} for every native
#                   but `argv` (core/process.tcl). The impl signals one with
#                   core::native::failDeclared, and core::native::invoke turns
#                   that into an ordinary propagate-error completion, exactly
#                   like a Botlish `fail NAME` (EXPLICIT-ERROR-COMPLETIONS.md).
#   completion      0 | 1 (default 0): the impl returns a *completion*, not a
#                   value -- normal, or the propagate-error of a program's own
#                   declared error that Botlish code it ran to a boundary of
#                   its own completed with (core/coroutines.tcl: a coroutine
#                   segment). Which errors are possible is not the native's
#                   (they are the program's): static typing charges them to
#                   the call (hir/coroutines.tcl), and compiled code always
#                   calls such a native through the generic call boundary.
#   errorsFrom      "" or the index K of a callable argument whose contract's
#                   declared errors a call of the native may complete with:
#                   the native calls it (mutable_array::generate's factory),
#                   and the first failing call's propagate-error is the
#                   native's own completion. Static typing charges the
#                   callable's contract errors to the call (hir/types.tcl's
#                   calleeErrors); such a native is a -completion native.
#   ownership       what the operation does, statically, with each argument
#                   it is given (OWNERSHIP ROLES below), one role per
#                   parameter (for a native of arity *, the roles of its
#                   leading arguments, the last one repeating for every
#                   further argument), or "" (every argument is `erase`). The
#                   ownership discipline (hir/affine.tcl) reads these roles,
#                   never a native's name, to decide whether an affine
#                   argument moves, stays owned, or is rejected; they are
#                   compile-time semantics only (no runtime check exists).
#   resultLength    "" or the length of the collection the native returns,
#                   for static analyses that track lengths and capacities
#                   (hir/cardinality.tcl), read by registration, never by
#                   name:
#                     int K           the Int argument K (allocate's capacity)
#                     list K          the length of List argument K
#   dropForm        "" or {NAME AT}: the operation's element-dropping variant
#                   NAME, which takes the element drop descriptor as an extra
#                   last argument, so that the elements the operation removes,
#                   displaces or fails to place are released by the static
#                   drop glue (hir/mutvec.tcl writes it for an operation whose
#                   element type is affine). AT is the argument whose static
#                   type holds the element type (a collection), or `result`
#                   (the call's own type, a constructor's).
#   bounds          "" or the bounds checks behind a native's argument-
#                   dependent errors (STDLIB-NAMESPACES.md), stated once here
#                   so static analyses (hir/completions.tcl) read them by
#                   registration, never by name:
#                     index FAMILY C I  IndexNotFound unless the Int
#                                     argument I designates an element of
#                                     sequence argument C (0 <= I < N)
#                     slices SLICE...  each SLICE {FAMILY C START END},
#                                     checked in order by checkSlice:
#                                     LowerUnderrun/UpperOverrun unless 0 <=
#                                     START <= END <= N
#                   FAMILY is the kind of sequence argument C (list,
#                   mutarray or str; N its length or capacity); START and
#                   END are each an argument index, {const K} or {sum A B}
#                   (the sum of arguments A and B). A native with bounds
#                   declares exactly the errors they produce.
#   runtime         what a native implementation of the operation needs from
#                   a runtime, beyond bare machine operations on values of
#                   known kinds (a sorted list of tags from runtimeTags
#                   below). Pure metadata for static analysis (hir/aot.tcl):
#                   the operation is fully known, but lowering it to native
#                   code needs these helpers. It never changes semantics.
#   resultShape     "" or how the result is built from the arguments, for
#                   static analyses that track what aggregates contain
#                   (hir/types.tcl, aggregate facts). Pure metadata, like
#                   runtime; the result type still states the contract:
#                     elements        a list of the arguments, in order
#                     element L I     the element of list argument L at the
#                                     index given by Int argument I
#                     append L V      a list of list argument L's elements
#                                     followed by argument V
#                     immutable-set L an ImmutableSet of list argument L's
#                                     element type (MINIMAL-IMMUTABLE-SET.md)
#                     mutarray-element A  argument A is a MutableArray[T]:
#                                     the result is a T (PARAMETERIZED-
#                                     MUTABLEARRAY.md); a raw `mutarray`
#                                     argument keeps the declared result
#                     mutvec-from-list L  argument L is a List[T]: the
#                                     result is a MutableVector[T]
#                                     (MUTABLE-VECTOR.md)
#                     mutvec-element V    argument V is a MutableVector[T]:
#                                     the result is a T
#                     mutvec-to-list V    argument V is a MutableVector[T]:
#                                     the result is a List[T]
#                     same A          the result has argument A's own
#                                     static type (mutable_vector#share)
#                     mutarray-create V   argument V is a T: the result
#                                     is a MutableArray[T] (MUTABLE-ARRAY.md)
#                     mutarray-from-list L  argument L is a List[T]: the
#                                     result is a MutableArray[T]
#                     mutarray-generate F argument F is a callable whose
#                                     contract returns T: the result is a
#                                     MutableArray[T]
#                     mutarray-freeze A   argument A is a MutableArray[T]:
#                                     the result is a List[T]; a raw
#                                     `mutarray` argument keeps the declared
#                                     result
#                     named-struct ID   the result is a struct of the
#                                     named declaration ID ("abi::x86_64::
#                                     Register64"), resolved lazily in the
#                                     compiling program's struct registry
#                                     (hir/structs.tcl); the declared
#                                     result type when ID is not declared
#                     context-struct I  the result is a struct of the named
#                                     declaration whose identity is argument
#                                     I's String literal (context#load,
#                                     core/contexts.tcl; CONTEXTS.md)
#                     typed NAME LO HI  every element is an Int in LO..HI (a
#                                     fixed fact about the native itself, not
#                                     derived from this call's own arguments);
#                                     additionally NAME-typed iff NAME
#                                     currently resolves, in the compiling
#                                     program's own source-defined-type
#                                     registry, to a type whose domain
#                                     provably admits every value in LO..HI
#                                     (hir::range::ProvesType) -- never merely
#                                     because NAME resolves at all
#                                     (SYMBOLIC-TYPE-IDENTITY.md)
#   resultRange     "" (nothing known) or a fact about every Int result, for
#                   hir/range.tcl's representation analysis. Pure metadata,
#                   like runtime and resultShape: a guarantee the
#                   implementation actually upholds, never a guess from the
#                   native's name.
#                     nonneg          the result is always >= 0
#                     collection-length   the result is always a String or
#                                     List length: >= 0 and, by the runtime's
#                                     own enforced construction limit
#                                     (native/src/runtime/ops.rs), also <=
#                                     hir::range's small-Int maximum -- never
#                                     merely assumed (see MAX_COLLECTION_LENGTH
#                                     there)
#
# OWNERSHIP ROLES (-ownership; AFFINE-VALUES.md, MUTABLE-ARRAY.md). Each role
# says what the operation does with the argument's value, so the one question
# the ownership discipline asks of an affine argument -- does it move, stay
# owned, or would it be duplicated or lost? -- is answered from metadata:
#
#   observe    read only; nothing of it is retained. An affine argument stays
#              owned by its source, which must be an owner (a binding or a
#              place path): a temporary is AFFINE-TEMPORARY-UNSUPPORTED.
#   place      the receiver place, mutated in place (push, set, swap, a
#              copy's destination, a drain step); its owner keeps owning it.
#   move       moved once into the operation: stored in its result or in its
#              receiver (push's element, swap's replacement, from_list's
#              List, a consuming loop's domain).
#   element    a List literal's element (`list`): moved into the List when
#              the List's type is affine, else an erasure.
#   repeat     logically duplicated: the operation places one value in many
#              slots (create's value). An affine argument is rejected
#              (AFFINE-DUPLICATION-UNSUPPORTED): there would be several
#              owners. An unrestricted one is copied logically, never deeply.
#   factory    a callable invoked once per element the operation makes
#              (generate's factory): each call's result moves into its own
#              slot. The callable itself is only called, never stored; an
#              affine callable (which could be called only once) is rejected.
#   copy-out   a container whose elements the operation reads out while it
#              keeps owning them (at, freeze, a copy's source, a snapshot):
#              an affine container is rejected (AFFINE-ELEMENT-COPY-OUT, or
#              AFFINE-LIST-OPERATION-UNSUPPORTED for a List).
#   equality   compared or hashed: an affine argument is rejected
#              (AFFINE-EQUALITY-UNSUPPORTED).
#   resume     a coroutine handle resumed behind its owner (consume and
#              replace: the owner keeps owning it).
#   message    a resume message: moved into the coroutine.
#   release    a release the compiler wrote (coroutine#release, affine#drop):
#              never a use to check.
#   erase      (the default) the argument becomes an untyped value the
#              operation may keep or copy: an affine argument is rejected
#              (AFFINE-ERASURE-UNSUPPORTED).
#
# Refinement rules are flat lists of ARG-INDEX TYPE pairs, e.g. {0 int}
# ("argument 0 is an int") or {0 {refined int {Byte}}}. The evaluator never
# special-cases a native by name; it only consults this metadata (see
# refine.tcl). (A Botlish function's own refinement rules are its proof
# contract, `proves`, REFINEMENT-VALUES.md -- the same shape, from source.)
#
# Declared types are a *contract*. After every call the reference runtime
# asserts that each argument satisfied its parameter type and that the
# result satisfies the result type, so a native cannot claim to return, say,
# a Byte while returning 300. Types are accepted in any form type.tcl
# understands and stored in canonical form.

namespace eval core::native {
    variable registry [dict create]
    # NAME -> 1: the registered natives that are the predicates of
    # source-declared types, not compiler intrinsics (markSource).
    variable sourceNatives [dict create]
    # Runtime requirement tags (-runtime):
    #   bigint               arbitrary-precision integer arithmetic or
    #                        comparison (a small-integer fast path still needs
    #                        an overflow check and a big-integer fallback)
    #   string-alloc         allocates a new string
    #   list-alloc           allocates a new list
    #   result-alloc         allocates a new Result
    #   char-index           counts or indexes a string by character, not byte
    #   range-check          may raise RANGE for an index outside a value
    #   structural-equality  compares values of any kinds structurally
    #   mutarray-alloc       allocates a new MutableArray, or a List by
    #                        finalizing one (mutable_array::freeze)
    #   mutarray-mutate      mutates a MutableArray's slots in place
    #                        (mutable_array::set, mutable_array::copy)
    #   hash                 computes a semantic hash of a value, recursing
    #                        into any List/Result payload the way
    #                        structural-equality does (core/hashing.tcl) --
    #                        bootstrap native, candidate for stdlib
    #                        replacement: see core/hashing.tcl's header
    #   set-alloc            allocates a new ImmutableSet (core/immutableset.tcl)
    #   process-argv         reads the process argument snapshot of the run
    #                        (core/process.tcl; ARGV.md)
    #   bytestore-alloc      allocates a new owned byte storage (core/bytestore.tcl;
    #                        ABI-BYTES.md)
    #   raw-address          produces the machine address of an owned byte
    #                        storage's payload (abi::x86_64::from_bytes; native
    #                        only, ABI-BYTES.md)
    #   mutvec-alloc         allocates a new MutableVector header
    #                        (core/mutvec.tcl; MUTABLE-VECTOR.md)
    #   mutvec-mutate        mutates a MutableVector header in place (push,
    #                        pop, take, swap, clear)
    #   raw-syscall          executes a raw Linux x86-64 kernel transition
    #                        (the `syscall` instruction) with unknown effects
    #                        (core/linuxabi.tcl; LINUX-X86-64-SYSCALL.md)
    variable runtimeTags {bigint string-alloc list-alloc result-alloc char-index
        range-check structural-equality mutarray-alloc mutarray-mutate hash set-alloc
        process-argv raw-syscall bytestore-alloc raw-address mutvec-alloc mutvec-mutate}
    # The -ownership roles (OWNERSHIP ROLES above).
    variable ownershipRoles {observe place move element repeat factory copy-out equality resume message release erase}
    # NAME -> 1: the errors the runtime itself declares, visible in every
    # program like a root native and never part of a program's own `error`
    # declarations (hir/errordecls.tcl). Only a native's -errors may name one;
    # native/lower.tcl's ErrorId gives each a fixed NIR id from its index.
    variable builtinErrors [dict create]
}

proc core::native::register {name args} {
    variable registry
    if {$name eq ""} {
        error "core::native::register: empty name"
    }
    if {[dict exists $registry $name]} {
        error "core::native::register: native \"$name\" is already registered"
    }
    if {[llength $args] % 2} {
        error "core::native::register: options must be -option value pairs"
    }
    set options [dict create -impl "" -arity "" -refines-true {} -refines-false {} \
        -param-types "" -result-type any -tests-type "" -runtime {} -result-shape {} -result-range {} \
        -context-free 0 -errors {} -bounds {} -nomethod 0 -completion 0 -ownership {} -errors-from {} \
        -result-length {} -drop-form {}]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "core::native::register: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set impl [dict get $options -impl]
    if {$impl eq ""} {
        error "core::native::register: -impl is required for \"$name\""
    }
    set arity [dict get $options -arity]
    if {$arity ne "*" && !([string is digit -strict $arity])} {
        error "core::native::register: -arity must be a non-negative integer or *"
    }
    if {[dict get $options -context-free] ni {0 1}} {
        error "core::native::register: -context-free of \"$name\" must be 0 or 1"
    }
    if {[dict get $options -nomethod] ni {0 1}} {
        error "core::native::register: -nomethod of \"$name\" must be 0 or 1"
    }
    if {[dict get $options -completion] ni {0 1}} {
        error "core::native::register: -completion of \"$name\" must be 0 or 1"
    }
    set testsType [dict get $options -tests-type]
    if {$testsType ne ""} {
        set testsType [CanonicalType $name -tests-type $testsType]
        if {$arity ne "1"} {
            error "core::native::register: a -tests-type native must have -arity 1"
        }
        if {[dict get $options -param-types] eq ""} {
            dict set options -param-types any
        }
        set param [CanonicalType $name -param-types [lindex [dict get $options -param-types] 0]]
        if {$param ne "any" && [llength $param] != 1} {
            error "core::native::register: the parameter type of -tests-type native \"$name\" must be any or a primitive kind"
        }
        if {![core::type::subtype $testsType $param]} {
            error "core::native::register: -tests-type [core::type::show $testsType] of \"$name\" is not a subtype of its parameter type $param"
        }
        if {[dict get $options -result-type] ni {any bool}} {
            error "core::native::register: a -tests-type native returns bool"
        }
        dict set options -result-type bool
        # A type test refines its argument to the type when it returns true.
        set rules [dict get $options -refines-true]
        if {![dict exists $rules 0]} {
            dict set options -refines-true [concat $rules [list 0 $testsType]]
        }
    }
    foreach option {-refines-true -refines-false} {
        set rules [dict get $options $option]
        if {[llength $rules] % 2} {
            error "core::native::register: $option must be ARG-INDEX TYPE pairs"
        }
        set canonical {}
        foreach {index type} $rules {
            if {![string is digit -strict $index]} {
                error "core::native::register: bad $option argument index \"$index\""
            }
            lappend canonical $index [CanonicalType $name $option $type]
        }
        dict set options $option $canonical
    }
    set paramTypes {}
    foreach type [dict get $options -param-types] {
        lappend paramTypes [CanonicalType $name -param-types $type]
    }
    if {$arity ne "*" && $paramTypes ne "" && [llength $paramTypes] != $arity} {
        error "core::native::register: -param-types of \"$name\" must list $arity type(s)"
    }
    variable runtimeTags
    foreach tag [dict get $options -runtime] {
        if {$tag ni $runtimeTags} {
            error "core::native::register: unknown -runtime tag \"$tag\" for \"$name\" (known: $runtimeTags)"
        }
    }
    set shape [dict get $options -result-shape]
    set count [expr {$arity eq "*" ? "" : $arity}]
    if {![ValidShape $shape $count]} {
        error "core::native::register: bad -result-shape \"$shape\" for \"$name\""
    }
    set range [dict get $options -result-range]
    if {$range ni {{} nonneg collection-length}} {
        error "core::native::register: bad -result-range \"$range\" for \"$name\""
    }
    variable builtinErrors
    set errors [lsort -unique [dict get $options -errors]]
    foreach error $errors {
        if {![dict exists $builtinErrors $error]} {
            error "core::native::register: -errors of \"$name\" names \"$error\", which is not a declared builtin error"
        }
    }
    variable ownershipRoles
    set ownership [dict get $options -ownership]
    foreach role $ownership {
        if {$role ni $ownershipRoles} {
            error "core::native::register: unknown -ownership role \"$role\" for \"$name\" (known: $ownershipRoles)"
        }
    }
    if {$ownership ne "" && ($arity eq "*" ? [llength $ownership] == 0 : [llength $ownership] != $arity)} {
        error "core::native::register: -ownership of \"$name\" must list [expr {$arity eq "*" ? "its leading" : $arity}] role(s)"
    }
    set errorsFrom [dict get $options -errors-from]
    if {$errorsFrom ne "" && (![string is digit -strict $errorsFrom] || $arity eq "*" || $errorsFrom >= $arity
            || ![dict get $options -completion])} {
        error "core::native::register: -errors-from of \"$name\" must be the index of an argument of a -completion native"
    }
    set length [dict get $options -result-length]
    if {$length ne "" && ([llength $length] != 2 || [lindex $length 0] ni {int list}
            || ![string is digit -strict [lindex $length 1]] || $arity eq "*" || [lindex $length 1] >= $arity)} {
        error "core::native::register: bad -result-length \"$length\" for \"$name\""
    }
    set dropForm [dict get $options -drop-form]
    if {$dropForm ne "" && ([llength $dropForm] != 2 || !([lindex $dropForm 1] eq "result"
            || ([string is digit -strict [lindex $dropForm 1]] && $arity ne "*" && [lindex $dropForm 1] < $arity)))} {
        error "core::native::register: bad -drop-form \"$dropForm\" for \"$name\""
    }
    set bounds [dict get $options -bounds]
    if {$bounds ne "" && ![ValidBounds $bounds $arity $errors]} {
        error "core::native::register: bad -bounds \"$bounds\" for \"$name\" (with -errors {$errors})"
    }
    dict set registry $name [dict create \
        name $name \
        impl $impl \
        arity $arity \
        refinesTrue [dict get $options -refines-true] \
        refinesFalse [dict get $options -refines-false] \
        paramTypes $paramTypes \
        resultType [CanonicalType $name -result-type [dict get $options -result-type]] \
        testsType $testsType \
        runtime [lsort -unique [dict get $options -runtime]] \
        resultShape $shape resultRange $range \
        contextFree [dict get $options -context-free] errors $errors bounds $bounds \
        nomethod [dict get $options -nomethod] completion [dict get $options -completion] \
        ownership $ownership errorsFrom $errorsFrom resultLength $length dropForm $dropForm]
    return [core::value::native $name]
}

# 1 if BOUNDS is a valid -bounds for a native of ARITY declaring exactly
# ERRORS (sorted).
proc core::native::ValidBounds {bounds arity errors} {
    if {[catch {llength $bounds}] || ![string is digit -strict $arity]} {
        return 0
    }
    set arg [list {a} [list expr "\[string is digit -strict \$a\] && \$a < $arity"]]
    switch -- [lindex $bounds 0] {
        index {
            if {[llength $bounds] != 4 || $errors ne {IndexNotFound}} {
                return 0
            }
            lassign $bounds _ family c i
            return [expr {$family in {list mutarray str} && [apply $arg $c] && [apply $arg $i]}]
        }
        slices {
            if {[llength $bounds] < 2 || $errors ne {LowerUnderrun UpperOverrun}} {
                return 0
            }
            foreach slice [lrange $bounds 1 end] {
                if {[catch {llength $slice} n] || $n != 4} {
                    return 0
                }
                lassign $slice family c start end
                if {$family ni {list mutarray str} || ![apply $arg $c]} {
                    return 0
                }
                foreach operand [list $start $end] {
                    if {[catch {llength $operand} n]} {
                        return 0
                    }
                    switch -- [lindex $operand 0]/$n {
                        const/2 { set ok [string is entier -strict [lindex $operand 1]] }
                        sum/3   { set ok [expr {[apply $arg [lindex $operand 1]] && [apply $arg [lindex $operand 2]]}] }
                        default { set ok [expr {$n == 1 && [apply $arg $operand]}] }
                    }
                    if {!$ok} {
                        return 0
                    }
                }
            }
            return 1
        }
    }
    return 0
}

# 1 if SHAPE is a valid -result-shape for a native taking COUNT arguments
# ("" for any number).
proc core::native::ValidShape {shape count} {
    if {[catch {llength $shape} length]} {
        return 0
    }
    if {[lindex $shape 0] eq {named-struct}} {
        # {named-struct ID}: the result is a struct of the named declaration
        # ID (linux::abi::syscall's abi::x86_64::Register64), a fixed fact
        # about the native itself. ID is a symbolic declaration identity,
        # resolved lazily by hir::types::ShapeResult against the compiling
        # program's own struct registry (a library struct is declared by a
        # .bot module long after core bootstrap registers the native).
        return [expr {$length == 2 && [regexp {^[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*$} [lindex $shape 1]]}]
    }
    if {$shape in {coroutine-create coroutine-outward coroutine-yield}} {
        # The coroutine operations (core/coroutines.tcl, COROUTINES.md): the
        # result is typed by hir::types::ShapeResult from the program's
        # coroutine analysis (hir/coroutines.tcl) -- a handle's protocol, the
        # outward value of its segment, the resume message of a yield.
        return 1
    }
    if {$shape eq {never}} {
        # {never}: the native never completes normally
        # (context#unreachable, core/contexts.tcl).
        return 1
    }
    if {[lindex $shape 0] eq {context-struct}} {
        # {context-struct I}: the result is the installed context of the
        # context-struct declaration whose canonical identity is the String
        # literal of argument I (context#load, core/contexts.tcl): a struct of
        # that named declaration, resolved by hir::types::ShapeResult.
        return [expr {$length == 2 && [string is digit -strict [lindex $shape 1]]
            && ($count eq "" || [lindex $shape 1] < $count)}]
    }
    if {[lindex $shape 0] eq {typed}} {
        # {typed NAME LO HI}: every element of the result List is an Int
        # in LO..HI -- a semantic fact this native's own implementation
        # actually guarantees, independent of any source-defined type --
        # *and*, if the symbolic name NAME currently resolves (in whatever
        # source-defined-type registry a compiling program has loaded) to a
        # type whose own domain admits every value in LO..HI, the result is
        # additionally NAME-typed. NAME is resolved lazily by hir::types::
        # ShapeResult at type-inference time (never here at registration
        # time, since a native like str::encode_utf8 is registered once at core
        # bootstrap, long before a compiling program's own `type NAME = ...`
        # declaration -- e.g. lib/byte.bot's Byte -- has been parsed; NAME
        # is just a symbolic reference until then). Resolving the name is
        # not, by itself, proof of membership: the same spelling can denote
        # an unrelated or narrower domain in a different compiling program
        # (SYMBOLIC-TYPE-IDENTITY.md) -- ShapeResult verifies LO..HI is
        # actually admissible in whatever NAME resolves to before ever
        # narrowing the result to it, falling back to this native's own
        # plain declared -result-type otherwise. LO and HI are a fixed
        # fact about the native itself, not argument indices, so this whole
        # shape is exempt from the digit-index check below.
        if {$length != 4} { return 0 }
        lassign $shape _ name lo hi
        return [expr {[string is entier -strict $lo] && [string is entier -strict $hi] && $lo <= $hi}]
    }
    if {[lindex $shape 0] eq {element-type}} {
        # {element-type TYPE}: every element of the result List has type
        # TYPE, a fixed fact about the native itself (argv's Strings), not
        # argument indices.
        return [expr {$length == 2 && ![catch {core::type::normalize [lindex $shape 1]}]}]
    }
    set indices [lrange $shape 1 end]
    foreach index $indices {
        if {![string is digit -strict $index] || ($count ne "" && $index >= $count)} {
            return 0
        }
    }
    switch -- [lindex $shape 0] {
        ""       { return [expr {$length == 0}] }
        elements { return [expr {$length == 1}] }
        element - append { return [expr {$length == 3 && $count ne ""}] }
        immutable-set { return [expr {$length == 2}] }
        mutarray-element - mutarray-freeze - mutarray-create - mutarray-from-list - mutarray-generate {
            return [expr {$length == 2 && $count ne ""}]
        }
        mutvec-from-list - mutvec-element - mutvec-to-list - same {
            # MUTABLE-VECTOR.md (hir::types::ShapeResult): from_list's
            # List[T] -> MutableVector[T]; an element read or removal's
            # MutableVector[T] -> T; to_list's MutableVector[T] -> List[T];
            # `same A`: the result has argument A's own type (a share).
            return [expr {$length == 2 && $count ne ""}]
        }
    }
    return 0
}

proc core::native::CanonicalType {name option type} {
    if {[catch {core::type::normalize $type} canonical]} {
        error "core::native::register: $option of \"$name\": $canonical"
    }
    return $canonical
}

# Declares NAME a builtin error (see builtinErrors); declaring one twice is an
# error. Declaration order is the error's index (builtinErrorIndex).
proc core::native::declareError {name} {
    variable builtinErrors
    if {![regexp {^[A-Z][A-Za-z0-9]*$} $name]} {
        error "core::native::declareError: bad error name \"$name\""
    }
    if {[dict exists $builtinErrors $name]} {
        error "core::native::declareError: builtin error \"$name\" is already declared"
    }
    dict set builtinErrors $name [dict size $builtinErrors]
}

proc core::native::isBuiltinError {name} {
    variable builtinErrors
    return [dict exists $builtinErrors $name]
}

# The builtin error names, in declaration order.
proc core::native::builtinErrorNames {} {
    variable builtinErrors
    return [dict keys $builtinErrors]
}

# NAME's index among the builtin errors (declaration order, from 0): the one
# number native/lower.tcl and native/src/runtime/ops.rs agree on.
proc core::native::builtinErrorIndex {name} {
    variable builtinErrors
    return [dict get $builtinErrors $name]
}

# Called by a native's impl to complete with the declared builtin error NAME
# (one of its own -errors). Never returns.
proc core::native::failDeclared {name message} {
    throw [list CORE DECLARED-ERROR $name] $message
}

# The one slice rule (STDLIB-NAMESPACES.md), shared by every slicing native
# (str::substring, mutable_array::copy, mutable_array::freeze) and
# mirrored exactly by native/src/runtime/ops.rs's check_slice: the slice
# START..END (END exclusive) of a sequence of N elements is valid iff
# 0 <= START <= END <= N. Its bounds are checked in order -- START against
# 0..N, then END against START..N -- and the first bound outside its
# interval fails with the declared builtin error LowerUnderrun (below it)
# or UpperOverrun (above it). So a negative start, and an end before the
# start (an inverted slice, or a negative count), are LowerUnderrun; a
# start or an end past N is UpperOverrun. NATIVE names the operation in the
# message. START and END are Tcl integers of any size.
proc core::native::checkSlice {native start end n} {
    if {$start < 0} {
        failDeclared LowerUnderrun "$native: slice start $start is below 0"
    }
    if {$start > $n} {
        failDeclared UpperOverrun "$native: slice start $start is above the length $n"
    }
    if {$end < $start} {
        failDeclared LowerUnderrun "$native: slice end $end is below its start $start"
    }
    if {$end > $n} {
        failDeclared UpperOverrun "$native: slice end $end is above the length $n"
    }
}

# 1 if NAME is a registered native.
proc core::native::exists {name} {
    variable registry
    return [dict exists $registry $name]
}

proc core::native::names {} {
    variable registry
    return [dict keys $registry]
}

# 1 if NAME is a registered native whose name is itself namespace-qualified
# ("linux::abi::syscall", core/linuxabi.tcl): source spells it exactly like
# a module function, but it is a root native, and no module file defines it
# (surface/modules.tcl, surface/lower.tcl).
proc core::native::isQualifiedNative {name} {
    variable registry
    variable sourceNatives
    return [expr {[string first :: $name] > 0 && [dict exists $registry $name]
        && ![dict exists $sourceNatives $name]}]
}

# The member names of the qualified root natives that live directly in
# namespace NS (`list` -> at append length; `linux::abi` -> syscall), sorted:
# the intrinsic members of NS, which no module source may define
# (surface/modules.tcl's DUPLICATE-NATIVE) and which a reference
# NS::MEMBER always denotes. Empty for a namespace with none.
proc core::native::qualifiedMembers {ns} {
    variable registry
    variable sourceNatives
    set members {}
    foreach name [dict keys $registry] {
        if {[dict exists $sourceNatives $name]} continue
        if {[string first ${ns}:: $name] == 0} {
            set member [string range $name [string length ${ns}::] end]
            if {$member ne "" && [string first :: $member] < 0} {
                lappend members $member
            }
        }
    }
    return [lsort $members]
}

# Removes a previously registered native NAME. Only hir/sourcetypes.tcl uses
# this, to undo the root constructor/predicate natives it registers for a
# source-declared type at the start of the next compilation (see
# SOURCE-DEFINED-INTEGER-DOMAINS.md's "Compilation isolation") -- ordinary
# (compiler-registered, process-lifetime) natives are never unregistered.
proc core::native::unregister {name} {
    variable registry
    variable sourceNatives
    dict unset registry $name
    dict unset sourceNatives $name
}

# Marks the registered native NAME as declared by Botlish source (the
# membership predicate of a source-declared type, hir/sourcetypes.tcl) rather
# than provided by the compiler: such a native is not an *intrinsic* of its
# namespace -- it does not make the namespace exist, is not protected
# against redefinition, and is reached by a qualified reference through the
# namespace's own type, never by surface lowering's intrinsic shortcut.
proc core::native::markSource {name} {
    variable sourceNatives
    dict set sourceNatives $name 1
}

proc core::native::metadata {name} {
    variable registry
    if {![dict exists $registry $name]} {
        error "core::native: no native named \"$name\""
    }
    return [dict get $registry $name]
}

# The ownership role (OWNERSHIP ROLES) native NAME's argument INDEX has:
# its -ownership entry (for a native of arity *, the last entry repeats),
# else erase.
proc core::native::ownershipRole {name index} {
    set meta [metadata $name]
    set roles [dict get $meta ownership]
    if {$roles eq ""} {
        return erase
    }
    if {[dict get $meta arity] eq "*" && $index >= [llength $roles]} {
        return [lindex $roles end]
    }
    set role [lindex $roles $index]
    return [expr {$role eq "" ? "erase" : $role}]
}

# OUTCOME is host 1 (predicate returned true) or 0 (returned false).
proc core::native::refinementRules {name outcome} {
    set meta [metadata $name]
    return [dict get $meta [expr {$outcome ? "refinesTrue" : "refinesFalse"}]]
}

proc core::native::invoke {nativeValue argValues} {
    set name [core::value::nativeName $nativeValue]
    set meta [metadata $name]
    set arity [dict get $meta arity]
    if {$arity ne "*" && [llength $argValues] != $arity} {
        core::semanticError ARITY \
            "$name expects $arity argument(s), got [llength $argValues]"
    }
    set testsType [dict get $meta testsType]
    if {$testsType ne ""} {
        set param [lindex [dict get $meta paramTypes] 0]
        if {$param ne "any"} {
            core::value::expect $param [lindex $argValues 0] $name
        }
    }
    if {[dict get $meta completion]} {
        # A native whose implementation runs Botlish code to a boundary of
        # its own and returns that code's completion (core/coroutines.tcl:
        # a coroutine segment ends normally or with the body's own
        # propagate-error, which this call then completes with). Only a
        # normal or propagate-error completion may cross it.
        set completion [{*}[dict get $meta impl] {*}$argValues]
        if {[core::completion::kind $completion] ni {value propagate-error}} {
            throw [list CORE CONTRACT TYPE] \
                "$name: contract violation: it completed with [core::completion::show $completion]"
        }
        return $completion
    }
    set errors [dict get $meta errors]
    if {$errors ne ""} {
        # A native with declared errors completes with propagate-error when
        # its impl signals one of them (failDeclared); any other signal is
        # a contract violation of the native itself.
        try {
            set result [{*}[dict get $meta impl] {*}$argValues]
        } trap {CORE DECLARED-ERROR} {message options} {
            set error [lindex [dict get $options -errorcode] 2]
            if {$error ni $errors} {
                throw [list CORE CONTRACT TYPE] \
                    "$name: contract violation: it signalled the undeclared error \"$error\" (declared: $errors)"
            }
            return [core::completion::propagatingError [core::value::errorId $error]]
        }
    } else {
        set result [{*}[dict get $meta impl] {*}$argValues]
    }
    core::value::check $result
    if {$testsType ne ""} {
        set expected [core::value::bool [core::type::acceptsCanonical $testsType [lindex $argValues 0]]]
        if {$result ne $expected} {
            throw [list CORE CONTRACT TYPE] \
                "$name: contract violation: as a test of [core::type::show $testsType] it must return [core::value::show $expected] for [core::value::show [lindex $argValues 0] 1], returned [core::value::show $result]"
        }
    }
    # The call returned: check the contract it declared.
    set index 0
    foreach type [dict get $meta paramTypes] {
        if {$type ne "any"} {
            core::type::AssertCanonical $type [lindex $argValues $index] "$name argument $index"
        }
        incr index
    }
    if {[dict get $meta resultType] ne "any"} {
        core::type::AssertCanonical [dict get $meta resultType] $result "$name result"
    }
    return [core::completion::normal $result]
}

# The runtime's builtin errors, in their fixed index order
# (builtinErrorIndex): native/lower.tcl's ErrorId and native/src/runtime/
# error.rs's ERR_* constants are both keyed to these indices, so the order
# is declared once, here, never by whichever file happens to load first.
#   InvalidArgumentEncoding  argv() (core/process.tcl; ARGV.md)
#   IndexNotFound            list::at, mutable_array::at, mutable_array::set:
#                            the index does not designate an element
#                            (core/lists.tcl, core/mutarray.tcl;
#                            STDLIB-NAMESPACES.md)
#   LowerUnderrun            a slice bound below its interval (checkSlice)
#   UpperOverrun             a slice bound above its interval (checkSlice)
core::native::declareError InvalidArgumentEncoding
core::native::declareError IndexNotFound
core::native::declareError LowerUnderrun
core::native::declareError UpperOverrun
