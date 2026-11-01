# callbacks.tcl -- synchronous C callbacks (C-CALLBACK-MILESTONE-1.md).
#
#   callback c fn decide(value: std::ffi::c::Int) -> std::ffi::c::Int:
#       if value > 0:
#           return 1
#       0
#
#   cb = std::ffi::c::callback(decide)   # std::ffi::c::FnPtr[Fn{args: [std::ffi::c::Int], return: std::ffi::c::Int}]
#   bcf::decide_all(cb, 10)              # an extern c fn whose FnPtr parameter is noescape
#
# `callback c fn` declares an ordinary Botlish function -- Botlish callers
# call it exactly as any other function -- that C may also call, through
# the C function pointer `std::ffi::c::callback(NAME)` makes of it: the
# address of a C ABI entry point the native backend emits for it (an entry
# trampoline in the target's C calling convention), whose calls run the
# function's generic instance in the Botlish execution environment that is
# suspended in a foreign call at that moment. Its C signature is read from
# its declaration, never from how Botlish code calls it, so the declaration
# states every boundary type, each one whose conversion from or to C is
# total -- a C callback has no error channel (CALLBACK-SIGNATURE):
#
#   * a parameter is a C integer scalar (std::ffi::c::Int ...), C _Bool
#     (std::ffi::c::Bool, Botlish's bool), a raw C floating value
#     (std::ffi::c::RawFloat, std::ffi::c::RawDouble: every bit pattern) or
#     a C pointer (std::ffi::c::Ptr[T], std::ffi::c::FnPtr[F]) -- never the
#     finite Float64 of std::ffi::c::Float or std::ffi::c::Double, whose
#     admission of a NaN or an infinity would fail before the body runs;
#   * the result is one of those, a Float64 (C double: every Float64 is
#     one; never C float, whose narrowing can overflow), or unit (void);
#   * no declared errors, flags, context parameters, variadic parameter or
#     resume clause;
#   * a top-level function of the entry program or of a module
#     (CALLBACK-PLACEMENT);
#   * environment-free: it captures no value, requires no context and never
#     suspends (CALLBACK-ENVIRONMENT) -- C gives it no environment, no
#     context and no coroutine, and no Botlish error or suspension crosses a
#     C frame. The completion analysis holds the body to its empty errors
#     (through erased callables too), so only a run-time failure can end a
#     callback abnormally, and that ends the process (the runtime's
#     fail-closed boundary, runtime/callback.rs).
#
# `std::ffi::c::callback(NAME)` is the one way to a callback's pointer: its
# argument is a reference, by name, to a `callback c fn` (a value of any
# other kind -- a Botlish function value, a closure, a parameter -- is
# CALLBACK-REFERENCE), and it is only called, never taken as a value. Its
# result is a std::ffi::c::FnPtr of exactly the declaration's C signature
# (hir::types::ShapeResult's `callback-pointer`), affine like every C
# pointer. Nothing converts a Botlish Fn into a FnPtr implicitly.
#
# The pointer selects no execution environment and grants no authority: C
# may call it only during a foreign call whose contract says C may call
# back and does not keep the pointer -- a std::ffi::c::FnPtr parameter
# declared noescape -- and the runtime refuses any other call, on any other
# thread or stack, before Botlish code runs. Handing it to a parameter whose
# contract may retain it (captures, or nothing stated) is the existing
# direct edge (hir/direct.tcl): retention is an authority, not a lifetime
# this milestone manages.
#
# The Tcl backends describe callbacks (they parse, check and call them as
# ordinary functions) but have no machine for C to call: making a pointer
# there is NATIVE-ONLY at run time (core/cabi.tcl).

namespace eval hir::callbacks {}

# Diagnoses every `callback c fn` of HIRVAR's program and every use of the
# pointer operation (a native whose result shape is `callback-pointer`).
proc hir::callbacks::verify {hirVar} {
    upvar 1 $hirVar hir
    if {[hir::mode $hir] ne "program"} {
        return
    }
    if {[hir::traits::Planning] || [dict exists $hir traitSource]} {
        # The monomorphized program: judged as written.
        return
    }
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call"} {
            dict set callees [dict get $node callee] 1
        }
    }
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            block {
                if {![dict exists $node callback]} continue
                foreach problem [Problems $hir $e] {
                    lassign $problem kind message
                    hir::Diagnose hir $kind $message $e
                }
            }
            call {
                set name [PointerNative $hir $node]
                if {$name eq ""} continue
                if {[dict exists $node reachable] && ![dict get $node reachable]} continue
                set problem [ReferenceProblem $hir [lindex [dict get $node args] 0]]
                if {$problem ne ""} {
                    hir::Diagnose hir CALLBACK-REFERENCE "[core::native::displayName $name]: $problem" $e
                }
            }
            ref {
                if {[dict exists $callees $e]} continue
                if {[dict exists $node reachable] && ![dict get $node reachable]} continue
                set name [RefNative $hir $node]
                if {$name eq "" || ![IsPointerNative $name]} continue
                hir::Diagnose hir CALLBACK-REFERENCE \
                    "[core::native::displayName $name] can only be called directly, with a callback c fn by name: a function value of it would make a C function pointer of whatever it is given at run time, which nothing could check is a callback" $e
            }
        }
    }
}

# 1 if native NAME makes a callback's C function pointer: its result shape
# is `callback-pointer` (registration metadata, never its name).
proc hir::callbacks::IsPointerNative {name} {
    return [expr {[lindex [dict get [core::native::metadata $name] resultShape] 0] eq "callback-pointer"}]
}

# The native a `ref` NODE names, or "".
proc hir::callbacks::RefNative {hir node} {
    set b [dict get $node binding]
    if {$b eq ""} {
        return ""
    }
    set binding [hir::binding $hir $b]
    if {[dict get $binding kind] ne "root" || ![core::native::exists [dict get $binding name]]} {
        return ""
    }
    return [dict get $binding name]
}

# The pointer native call NODE calls, or "".
proc hir::callbacks::PointerNative {hir node} {
    lassign [dict get $node target] kind y
    if {$kind ne "native"} {
        return ""
    }
    set name [dict get [hir::symbol $hir $y] name]
    if {![core::native::exists $name] || ![IsPointerNative $name]} {
        return ""
    }
    return $name
}

# The block of the `callback c fn` the expression ARG names by reference,
# or "" when ARG is no such reference.
proc hir::callbacks::Referenced {hir arg} {
    if {$arg eq "" || ![dict exists $hir exprs $arg] || [hir::kind $hir $arg] ne "ref"} {
        return ""
    }
    set b [hir::get $hir $arg binding]
    if {$b eq ""} {
        return ""
    }
    set block [hir::aot::BoundBlock $hir $b]
    if {$block eq "" || ![dict exists $hir exprs $block callback]} {
        return ""
    }
    return $block
}

# Why the pointer operation's argument ARG is not a callback's name, or "".
proc hir::callbacks::ReferenceProblem {hir arg} {
    if {[Referenced $hir $arg] ne ""} {
        return ""
    }
    set what "its argument"
    if {$arg ne "" && [hir::kind $hir $arg] eq "ref"} {
        set what "\"[hir::semantic::RefName $hir $arg]\""
    }
    return "$what is not a callback c fn named directly; a C function pointer is made only of a top-level function declared \"callback c fn NAME(...) -> T:\", by its name, whose C signature its declaration states (a Botlish function value, a closure or a parameter is no C function)"
}

# The block ExprIds of HIR's `callback c fn`s, in program order: the
# top-level ones (a nested one is CALLBACK-PLACEMENT, and none).
proc hir::callbacks::Declarations {hir} {
    set found {}
    foreach e [dict get $hir roots] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "bind"} continue
        set value [dict get $node value]
        if {[dict exists $hir exprs $value callback]} {
            lappend found $value
        }
    }
    return $found
}

# The callback records of HIR's valid `callback c fn`s, in program order:
# one dict each (see Record). A declaration with a problem has none.
proc hir::callbacks::of {hir} {
    set records {}
    foreach e [Declarations $hir] {
        if {![llength [Problems $hir $e]]} {
            lappend records [Record $hir $e]
        }
    }
    return $records
}

# The C type of the declared Botlish type DECLARED at a callback's POSITION
# (param or result) -- the type its C function pointer's signature names --
# or {} with the reason it has none: {TYPE ""} or {"" REASON}.
proc hir::callbacks::CType {declared position} {
    if {$declared eq "unit"} {
        if {$position eq "result"} {
            return [list unit ""]
        }
        return [list "" "unit is no C parameter type"]
    }
    if {[core::type::cabiScalar $declared] ne "" || $declared eq "bool"
            || [hir::cabi::IsRawFloating $declared]
            || [hir::types::IsCPtr $declared] || [hir::types::IsCFnPtr $declared]} {
        if {[hir::types::IsImprint $declared]} {
            return [list "" "an imprint variable has no one C ABI"]
        }
        return [list $declared ""]
    }
    if {$declared eq "Float64"} {
        if {$position eq "result"} {
            # Every Float64 is a C double, exactly: the conversion out is
            # total.
            return [list [hir::cabi::FloatingType Double] ""]
        }
        return [list "" "a Float64 parameter would be C's double admitted as a finite number, and C may pass a NaN or an infinity, which has no Float64 -- the callback would fail before its body runs, with no error channel to C; declare [hir::cabi::RawDoubleName] (every double, its bits) and admit it explicitly (std::ffi::c::raw)"]
    }
    return [list "" "[hir::types::showValue $declared] has no total C form (a callback's C types are the C integer scalars, [hir::cabi::BoolName], [hir::cabi::RawFloatName], [hir::cabi::RawDoubleName], [hir::cabi::PtrName]\[...\], [hir::cabi::FnPtrName]\[...\], and for the result also Float64 as C's double, or unit)"]
}

# The bind of block E (an ExprId), or "" when E is no bind's value.
proc hir::callbacks::BindOf {hir e} {
    dict for {b node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "bind" && [dict get $node value] eq $e} {
            return $b
        }
    }
    return ""
}

# The function's name: its written name, without its module.
proc hir::callbacks::ShortName {hir bind} {
    return [namespace tail [hir::semantic::SourceName $hir [dict get $hir exprs $bind binding]]]
}

# What keeps block E from being a C callback: a list of {KIND MESSAGE}.
proc hir::callbacks::Problems {hir e} {
    set node [dict get $hir exprs $e]
    set bind [BindOf $hir $e]
    set problems {}
    set scopes [list [dict get $hir top]]
    if {[dict exists $hir modules]} {
        lappend scopes {*}[dict values [dict get $hir modules]]
    }
    if {$bind eq "" || $bind ni [dict get $hir roots]
            || [dict get $hir bindings [dict get $hir exprs $bind binding] scope] ni $scopes} {
        set what [if {$bind eq ""} {string cat "this function"} else {string cat "\"[ShortName $hir $bind]\""}]
        return [list [list CALLBACK-PLACEMENT "$what is not a top-level function of a program or module: a C callback is a top-level declaration, whose entry point C calls with no enclosing function"]]
    }
    set what "callback c fn \"[ShortName $hir $bind]\""
    foreach b [dict get $node params] declared [dict get $node declaredParamTypes] {
        set param [dict get $hir bindings $b name]
        if {$declared eq {}} {
            lappend problems [list CALLBACK-SIGNATURE "$what: parameter \"$param\" has no declared type; a C callback declares every parameter's C type, since its C ABI is read from the declaration alone"]
            continue
        }
        lassign [CType $declared param] - why
        if {$why ne ""} {
            lappend problems [list CALLBACK-SIGNATURE "$what: parameter \"$param\" is declared [hir::types::presented $declared]: $why"]
        }
    }
    set result [dict get $node declaredResult]
    if {$result eq {}} {
        lappend problems [list CALLBACK-SIGNATURE "$what declares no result type; a C callback declares its result's C type (-> unit for void), since its C ABI is read from the declaration alone"]
    } else {
        lassign [CType $result result] - why
        if {$why ne ""} {
            lappend problems [list CALLBACK-SIGNATURE "$what: the result is declared [hir::types::presented $result]: $why"]
        }
    }
    if {[dict getdef $node declaredErrors {}] ne {}} {
        lappend problems [list CALLBACK-SIGNATURE "$what declares errors ([join [dict get $node declaredErrors] {, }]); a C callback has no error channel to its C caller -- handle every error in the body"]
    }
    if {[dict getdef $node flags {}] ne {}} {
        lappend problems [list CALLBACK-SIGNATURE "$what declares flags; a C callback's parameters are its C signature's"]
    }
    if {[dict exists $node contextParams]} {
        lappend problems [list CALLBACK-SIGNATURE "$what declares context parameters; C gives a callback no installed context"]
    }
    if {[dict exists $node variadic]} {
        lappend problems [list CALLBACK-SIGNATURE "$what is variadic; a C callback has a fixed C signature (a variadic C function pointer has no type)"]
    }
    if {[dict getdef $node declaredResume {}] ne {}} {
        lappend problems [list CALLBACK-SIGNATURE "$what declares a resume clause; a C callback is never a coroutine body"]
    }
    # A function referring to other top-level functions captures their
    # bindings, and needs no environment when they need none either
    # (hir::aot::StaticBlocks): what it must not capture is a value.
    set values {}
    if {[dict get $node captures] ne {}} {
        set statics [hir::aot::StaticBlocks $hir]
        foreach b [dict get $node captures] {
            if {[hir::aot::BoundBlock $hir $b] ni $statics} {
                lappend values [hir::semantic::SourceName $hir $b]
            }
        }
    }
    if {$values ne {}} {
        lappend problems [list CALLBACK-ENVIRONMENT "$what captures [join $values {, }]; a C callback is environment-free: C calls it through a bare machine address, which carries no closure (a top-level value it reads belongs in a module, where it is a module static)"]
    }
    set required [hir::contexts::required $hir $e]
    if {$required ne {}} {
        lappend problems [list CALLBACK-ENVIRONMENT "$what requires the context[expr {[llength $required] > 1 ? "s" : ""}] [join $required {, }]; a C call gives a callback no context, and a function pointer is no authority to install one"]
    }
    if {[hir::coroutines::MayYield $hir $e]} {
        lappend problems [list CALLBACK-ENVIRONMENT "$what may suspend (it yields, or calls a function that does); a C callback runs to completion: no suspension crosses a C frame"]
    }
    return $problems
}

# 1 if callback block E's declared types are a C signature: every
# parameter's and the result's declared, each with its C type (CType). What
# its pointer's type needs; the declaration's other problems are its own.
proc hir::callbacks::Typed {hir e} {
    set node [dict get $hir exprs $e]
    foreach declared [dict get $node declaredParamTypes] {
        if {$declared eq {} || [lindex [CType $declared param] 1] ne ""} {
            return 0
        }
    }
    set result [dict get $node declaredResult]
    return [expr {$result ne {} && [lindex [CType $result result] 1] eq ""}]
}

# The C signature type of valid callback block E: the canonical function
# type FnPtr's argument holds, {fn {args ... return R errors {}}}.
proc hir::callbacks::Signature {hir e} {
    set node [dict get $hir exprs $e]
    set args [lmap declared [dict get $node declaredParamTypes] {lindex [CType $declared param] 0}]
    set result [lindex [CType [dict get $node declaredResult] result] 0]
    return [hir::types::MakeFn $args $result {}]
}

# The type of std::ffi::c::callback(NAME) for valid callback block E.
proc hir::callbacks::PointerType {hir e} {
    return [list cfnptr [Signature $hir $e]]
}

# The callback record of block E: a dict
#
#   name     its qualified name (the module's namespace, then its name)
#   block    E
#   params   the C ABI classes of its parameters (hir::foreign::AbiClass)
#   result   the C ABI class of its result (void for unit)
#   type     its pointer's type, std::ffi::c::FnPtr[...]
#   origin   the declaration's origin
proc hir::callbacks::Record {hir e} {
    set bind [BindOf $hir $e]
    set signature [Signature $hir $e]
    return [dict create name [hir::semantic::SourceName $hir [dict get $hir exprs $bind binding]] block $e \
        params [lmap t [hir::types::FnArgs $signature] {hir::foreign::AbiClass $t}] \
        result [hir::foreign::AbiClass [hir::types::FnReturn $signature]] \
        type [list cfnptr $signature] origin [dict get $hir exprs $bind origin]]
}
