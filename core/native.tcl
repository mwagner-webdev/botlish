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
#   moduleFn        "" or {NAMESPACE NAME}: the native (Cranelift) backend
#                   may use the ordinary cross-file Botlish function
#                   NAMESPACE::NAME (surface/modules.tcl) as this native's
#                   *executable* implementation, instead of requiring an
#                   entry in its own op whitelist (native/lower.tcl's
#                   `natives`) or a -native-body -- see native/prepare.tcl's
#                   native::prepareHir. impl (run by interp/compile, and
#                   by the reference contract check) stays authoritative for
#                   every other backend and for any semantics -- such as
#                   attaching evidence for an opaque refined result type --
#                   that ordinary Botlish cannot itself express (only a
#                   trusted native impl may do that: see core/type.tcl); the
#                   native keeps its own registered -result-type for the
#                   call's static type on every backend, moduleFn or not
#                   (a call's nativeResultOverride, native/prepare.tcl), and
#                   its own paramTypes check, under its own name, before
#                   the module function runs (hir::aot::VisitCall, native/
#                   lower.tcl's BridgedCheckedNative). A native's
#                   module function sees only its own module's other
#                   definitions and ordinary root natives; it captures
#                   nothing from the call site (an ordinary top-level
#                   function, no different from any other module export).
#   nativeBody      "" or a (block PARAMS BODY...) core IR node, with
#                   PARAMS matching arity, expressing the same operation as
#                   impl in ordinary Botlish over other natives: an
#                   *authoritative-for-native-compilation* implementation
#                   the native (Cranelift) backend may use instead of
#                   requiring an entry in its own op whitelist
#                   (native/lower.tcl's `natives`) -- see native/prepare.tcl's
#                   native::prepareHir. impl (run by interp/compile, and by
#                   the reference contract check) stays authoritative for
#                   every other backend and for any semantics -- such as
#                   attaching evidence for an opaque refined result type --
#                   that ordinary Botlish cannot itself express (only a
#                   trusted native impl may do that: see core/type.tcl).
#                   A native's body sees only other root bindings (other
#                   natives); it captures nothing from its call site.
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
#   errors          the declared errors (core::native::declareError) a call
#                   of this native may complete with -- {} for every native
#                   but `argv` (core/process.tcl). The impl signals one with
#                   core::native::failDeclared, and core::native::invoke turns
#                   that into an ordinary propagate-error completion, exactly
#                   like a Botlish `fail NAME` (EXPLICIT-ERROR-COMPLETIONS.md).
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
# Refinement rules are flat lists of ARG-INDEX TYPE pairs, e.g. {0 int}
# ("argument 0 is an int") or {0 {refined str {Emailish}}}. The evaluator
# never special-cases a native by name; it only consults this metadata (see
# refine.tcl).
#
# Declared types are a *contract*. After every call the reference runtime
# asserts that each argument satisfied its parameter type and that the
# result satisfies the result type, so a native cannot claim to return, say,
# a UriQueryValue while returning a plain string. Types are accepted in any
# form type.tcl understands and stored in canonical form.

namespace eval core::native {
    variable registry [dict create]
    # ALIAS -> CANONICAL: a second source-level spelling for an already-
    # registered native, denoting the exact same registry entry (semantic
    # predicate identity), not a second registration. See `alias` below.
    variable aliases [dict create]
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
    #   evidence             reads or attaches refinement evidence
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
    #   raw-syscall          executes a raw Linux x86-64 kernel transition
    #                        (the `syscall` instruction) with unknown effects
    #                        (core/linuxabi.tcl; LINUX-X86-64-SYSCALL.md)
    variable runtimeTags {bigint string-alloc list-alloc result-alloc char-index
        range-check structural-equality evidence mutarray-alloc mutarray-mutate hash set-alloc
        process-argv raw-syscall}
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
        -native-body {} -module-fn {} -context-free 0 -errors {} -bounds {}]
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
    set nativeBody [dict get $options -native-body]
    if {$nativeBody ne ""} {
        if {[lindex $nativeBody 0] ne "block" || [llength [core::ir::blockParams $nativeBody]] != $arity} {
            error "core::native::register: -native-body of \"$name\" must be a (block PARAMS BODY...)\
                node with $arity parameter(s)"
        }
    }
    variable builtinErrors
    set errors [lsort -unique [dict get $options -errors]]
    foreach error $errors {
        if {![dict exists $builtinErrors $error]} {
            error "core::native::register: -errors of \"$name\" names \"$error\", which is not a declared builtin error"
        }
    }
    set bounds [dict get $options -bounds]
    if {$bounds ne "" && ![ValidBounds $bounds $arity $errors]} {
        error "core::native::register: bad -bounds \"$bounds\" for \"$name\" (with -errors {$errors})"
    }
    set moduleFn [dict get $options -module-fn]
    if {$moduleFn ne "" && [llength $moduleFn] != 2} {
        error "core::native::register: -module-fn of \"$name\" must be a {NAMESPACE NAME} pair"
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
        resultShape $shape resultRange $range nativeBody $nativeBody moduleFn $moduleFn \
        contextFree [dict get $options -context-free] errors $errors bounds $bounds]
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
        mutarray-element - mutarray-freeze { return [expr {$length == 2 && $count ne ""}] }
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
    return [expr {[string first :: $name] > 0 && [dict exists $registry $name]}]
}

# The member names of the qualified root natives that live directly in
# namespace NS (`list` -> at append length; `linux::abi` -> syscall), sorted:
# the intrinsic members of NS, which no module source may define
# (surface/modules.tcl's DUPLICATE-NATIVE) and which a reference
# NS::MEMBER always denotes. Empty for a namespace with none.
proc core::native::qualifiedMembers {ns} {
    variable registry
    set members {}
    foreach name [dict keys $registry] {
        if {[string first ${ns}:: $name] == 0} {
            set member [string range $name [string length ${ns}::] end]
            if {$member ne "" && [string first :: $member] < 0} {
                lappend members $member
            }
        }
    }
    return [lsort $members]
}

# Declares ALIASNAME a second, purely compile-time spelling of the already-
# registered native CANONICALNAME: every root reference to ALIASNAME (surface
# source, raw core IR, or the Tcl interpreter's own root environment) resolves
# to the identical BindingId/SymbolId/runtime value CANONICALNAME's own
# references do (hir/resolve.tcl's RootBinding, core::rootEnv below) -- never
# a second registry entry, a runtime Block/wrapper value, or a second
# specialization instance. ALIASNAME is never itself a key of `registry`;
# `metadata`/`invoke`/etc. only ever look up CANONICALNAME.
proc core::native::alias {aliasName canonicalName} {
    variable registry
    variable aliases
    if {![dict exists $registry $canonicalName]} {
        error "core::native::alias: unknown native \"$canonicalName\""
    }
    if {[dict exists $registry $aliasName] || [dict exists $aliases $aliasName]} {
        error "core::native::alias: \"$aliasName\" is already registered"
    }
    dict set aliases $aliasName $canonicalName
}

proc core::native::isAlias {name} {
    variable aliases
    return [dict exists $aliases $name]
}

# NAME's own registered identity: NAME itself if it is a registered native,
# the native it aliases if NAME is an alias, or NAME unchanged otherwise (an
# unknown name -- callers that care already check `names`/`isAlias`/`aliasNames`).
proc core::native::canonicalName {name} {
    variable aliases
    if {[dict exists $aliases $name]} {
        return [dict get $aliases $name]
    }
    return $name
}

proc core::native::aliasNames {} {
    variable aliases
    return [dict keys $aliases]
}

# Flat ALIAS CANONICAL ALIAS CANONICAL ... pairs, for core::rootEnv.
proc core::native::aliasPairs {} {
    variable aliases
    set pairs {}
    dict for {alias canonical} $aliases {
        lappend pairs $alias $canonical
    }
    return $pairs
}

# Removes a previously registered native NAME. Only hir/sourcetypes.tcl uses
# this, to undo the root constructor/predicate natives it registers for a
# source-declared type at the start of the next compilation (see
# SOURCE-DEFINED-INTEGER-DOMAINS.md's "Compilation isolation") -- ordinary
# (compiler-registered, process-lifetime) natives are never unregistered.
proc core::native::unregister {name} {
    variable registry
    dict unset registry $name
}

proc core::native::metadata {name} {
    variable registry
    variable aliases
    if {[dict exists $aliases $name]} {
        set name [dict get $aliases $name]
    }
    if {![dict exists $registry $name]} {
        error "core::native: no native named \"$name\""
    }
    return [dict get $registry $name]
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
