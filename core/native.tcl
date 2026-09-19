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
#                   `natives`) or a -native-body -- see native/native.tcl's
#                   module-native bridge. impl (run by interp/compile, and
#                   by the reference contract check) stays authoritative for
#                   every other backend and for any semantics -- such as
#                   attaching evidence for an opaque refined result type --
#                   that ordinary Botlish cannot itself express (only a
#                   trusted native impl may do that: see core/type.tcl); the
#                   native keeps its own registered -result-type for the
#                   call's static type on every backend, moduleFn or not
#                   (hir/hir.tcl's -native-result-overrides). A native's
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
#                   (native/lower.tcl's `natives`) -- see native/native.tcl's
#                   ExpandNativeBodies. impl (run by interp/compile, and by
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
    #                        finalizing one (mutable_array_freeze)
    #   mutarray-mutate      mutates a MutableArray's slots in place
    #                        (mutable_array_set, mutable_array_copy)
    #   hash                 computes a semantic hash of a value, recursing
    #                        into any List/Result payload the way
    #                        structural-equality does (core/hashing.tcl) --
    #                        bootstrap native, candidate for stdlib
    #                        replacement: see core/hashing.tcl's header
    variable runtimeTags {bigint string-alloc list-alloc result-alloc char-index
        range-check structural-equality evidence mutarray-alloc mutarray-mutate hash}
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
        -native-body {} -module-fn {} -context-free 0]
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
        contextFree [dict get $options -context-free]]
    return [core::value::native $name]
}

# 1 if SHAPE is a valid -result-shape for a native taking COUNT arguments
# ("" for any number).
proc core::native::ValidShape {shape count} {
    if {[catch {llength $shape} length]} {
        return 0
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
    }
    return 0
}

proc core::native::CanonicalType {name option type} {
    if {[catch {core::type::normalize $type} canonical]} {
        error "core::native::register: $option of \"$name\": $canonical"
    }
    return $canonical
}

proc core::native::names {} {
    variable registry
    return [dict keys $registry]
}

proc core::native::metadata {name} {
    variable registry
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
    set result [{*}[dict get $meta impl] {*}$argValues]
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
