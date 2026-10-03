# flags.tcl -- flag parameters: the semantic callable interface (FLAGS.md).
#
# A function may declare a *flag section* after its ordinary parameters
# (`fn open(path, flags :append, :cloexec)`). A flag is an immutable Bool
# parameter whose value is false unless its name is written at the call site
# (`open(p, :append)`). Flags are a parameter category of their own, not
# ordinary Bool arguments: a function's interface is
#
#     ordinary parameters + accepted flag names (declaration order)
#
# and a call's flag argument is a statically known *set of names*, never an
# expression.
#
# What HIR keeps (the semantic facts, independent of any physical transport):
#
#   block expr   flags      the declared flag names, in declaration order
#   binding      flagIface  {flags NAMES ordinary N} of a binding that denotes
#                           a declared function (also of an alias of one,
#                           `g = f`): the callee's interface, resolved
#                           statically at every call
#   call expr    flagVector {{NAME 0|1}...}, one entry per flag the callee
#                           declares, in declaration order: 1 if the call
#                           supplied it. Present only on calls of a function
#                           with flags (or a call that supplied one)
#
# Physical transport (internal, replaceable, NOT the language ABI): today the
# declared flags are the LAST parameters of the block, one `bool`-typed
# parameter each (their bindings are the ordinary Bool locals the body reads),
# and a call's `args` end with one Bool constant per declared flag -- `true`
# for a supplied flag, `false` for an omitted one -- in the same order. Every
# downstream pass therefore sees an ordinary call of ordinary Bool parameters
# (so constant flags are exact-value facts of a closed call like any other
# constant argument); a later lowering may transport the flags differently
# (a bitfield, nothing at all for a flag no callee reads) by reading
# `flags` / `flagVector` instead of the trailing arguments. Nothing outside
# this file and hir/resolve.tcl's block and call cases knows the layout;
# semantic meaning never depends on it.
#
# Static rules, all decided while resolving a call (the callee's interface is
# the declaration the called name denotes):
#
#   UNKNOWN-FLAG           the callee does not accept a supplied flag
#   DUPLICATE-FLAG         a flag is supplied twice in one call
#   FLAG-CALLEE-UNKNOWN    a flag is supplied to a callee whose declaration
#                          is not statically known (a parameter, a field, ...)
#   ARITY                  a call of a function with flags passes the wrong
#                          number of ordinary arguments (counted without the
#                          flags)
#   FLAG-FUNCTION-VALUE    a function with flags is used as a value other
#                          than as a callee or as the whole right side of an
#                          alias binding: its flag interface would be lost
#   DUPLICATE-FLAG-DECLARATION / FLAG-BINDING-COLLISION   at the declaration
#                          (hir/resolve.tcl's block case)

namespace eval hir::flags {}

# The Bool type of a flag parameter, as a type annotation.
proc hir::flags::BoolTypeExpr {} {
    return bool
}

# The interface {flags NAMES ordinary N} (ordinary N or "*" when unknown) the
# callee expression CALLEE (a resolved expression) denotes, or "" when it is
# not a statically known function: a reference to a binding that denotes a
# declared function, an alias of one, or a root native (no flags, unknown
# arity).
proc hir::flags::InterfaceOf {hir callee} {
    set node [dict get $hir exprs $callee]
    if {[dict get $node kind] ne "ref" || ![dict exists $node binding]} {
        return ""
    }
    set b [dict get $node binding]
    if {$b eq ""} {
        return ""
    }
    set binding [dict get $hir bindings $b]
    if {[dict exists $binding flagIface]} {
        return [dict get $binding flagIface]
    }
    if {[dict get $binding kind] eq "root" && [dict get $binding symbol] ne ""
            && [dict get $hir symbols [dict get $binding symbol] kind] eq "native"} {
        return [dict create flags {} ordinary *]
    }
    return ""
}

# Records the interface of the function binding B declared by the block
# syntax node BLOCK (before the block is resolved, so the body can call
# itself with flags).
proc hir::flags::DeclareFunction {hirVar b block} {
    upvar 1 $hirVar hir
    set flags [lmap flag [expr {[dict exists $block flags] ? [dict get $block flags] : {}}] {lindex $flag 0}]
    dict set hir bindings $b flagIface [dict create flags $flags ordinary [llength [dict get $block params]]]
}

# Records that binding B (just established by `B = VALUE`) is an alias of the
# function VALUE denotes, if VALUE is a reference to one.
proc hir::flags::DeclareAlias {hirVar b value} {
    upvar 1 $hirVar hir
    set iface [InterfaceOf $hir $value]
    if {$iface ne "" && [dict get [dict get $hir bindings [dict get [dict get $hir exprs $value] binding]] kind] ne "root"} {
        dict set hir bindings $b flagIface $iface
        dict set hir flagAllowed $value 1
    }
}

# Notes that reference E (just resolved) denotes a function that has flags,
# for the escape check (CheckValues).
proc hir::flags::NoteRef {hirVar e} {
    upvar 1 $hirVar hir
    set b [dict get $hir exprs $e binding]
    if {$b ne "" && [dict exists $hir bindings $b flagIface]
            && [dict get $hir bindings $b flagIface flags] ne {}} {
        dict lappend hir flagRefs $e
    }
}

# The flag section of a block syntax node's declared flags, bound as
# parameters of the block: for each declared flag (in declaration order) a
# `bool` parameter binding in BODYSCOPE. Returns {BINDINGS TYPES}. A flag
# name declared twice, or equal to an ordinary parameter, is diagnosed at the
# flag's own spelling (the binding is still made, so the parameter list keeps
# its shape; the name keeps denoting the first binding, like DUPLICATE).
proc hir::flags::Declare {hirVar e node bodyScope ns} {
    upvar 1 $hirVar hir
    set bindings {}
    set types {}
    set seen {}
    set boolType [hir::resolve::ResolveTypeExpr [BoolTypeExpr] $ns]
    foreach flag [expr {[dict exists $node flags] ? [dict get $node flags] : {}}] {
        lassign $flag name origin
        set first ""
        if {[dict exists $hir scopes $bodyScope names $name]} {
            set first [dict get $hir scopes $bodyScope names $name]
        }
        set b [hir::resolve::NewBinding hir $name param $bodyScope $origin]
        if {$first ne ""} {
            dict set hir scopes $bodyScope names $name $first
            if {$name in $seen} {
                hir::DiagnoseAt hir DUPLICATE-FLAG-DECLARATION \
                    "flag :$name is declared more than once in the same flag section" $e $origin
            } else {
                hir::DiagnoseAt hir FLAG-BINDING-COLLISION \
                    "flag :$name binds the local name \"$name\", which is already a parameter of this function: ordinary parameters and flags share one local namespace" $e $origin
            }
        }
        lappend seen $name
        lappend bindings $b
        lappend types $boolType
    }
    return [list $bindings $types]
}

# Resolves the flag part of call E written with syntax NODE, after its callee
# and ordinary arguments are resolved: validates the supplied flags against
# the callee's interface and appends the callee's flag arguments (see the
# header). A callee with no known interface is only an error if flags were
# supplied.
proc hir::flags::ResolveCall {hirVar e node ctx} {
    upvar 1 $hirVar hir
    set callee [dict get $hir exprs $e callee]
    if {[dict get $hir exprs $callee kind] eq "ref"} {
        dict set hir flagAllowed $callee 1
    }
    set supplied [expr {[dict exists $node flags] ? [dict get $node flags] : {}}]
    set iface [InterfaceOf $hir $callee]
    if {$iface eq ""} {
        if {$supplied ne {}} {
            lassign [lindex $supplied 0] name origin
            hir::DiagnoseAt hir FLAG-CALLEE-UNKNOWN \
                "cannot supply flag :$name: the callee is not a function whose declaration is statically known (flags can only be supplied to a call of a declared function, or of a name bound to one)" $e $origin
        }
        return
    }
    set declared [dict get $iface flags]
    set calleeName [CalleeName $hir $e $callee]
    set valid 1
    set seen {}
    foreach flag $supplied {
        lassign $flag name origin
        if {$name in $seen} {
            hir::DiagnoseAt hir DUPLICATE-FLAG "flag :$name was supplied more than once" $e $origin
            set valid 0
        } elseif {$name ni $declared} {
            if {$declared eq {}} {
                set accepted "it declares no flags"
            } else {
                set accepted "accepted flags: [join [lmap n $declared {string cat : $n}] {, }]"
            }
            hir::DiagnoseAt hir UNKNOWN-FLAG \
                "function $calleeName does not accept flag :$name ($accepted)" $e $origin
            set valid 0
        }
        lappend seen $name
    }
    if {$declared eq {}} {
        return
    }
    set args [dict get $hir exprs $e args]
    set ordinary [dict get $iface ordinary]
    if {$ordinary ne "*" && [llength $args] != $ordinary} {
        hir::Diagnose hir ARITY \
            "function $calleeName takes $ordinary ordinary argument(s) and the flags [join [lmap n $declared {string cat : $n}] {, }], got [llength $args] ordinary argument(s)" $e
        return
    }
    set vector {}
    foreach name $declared {
        set index [lsearch -exact $seen $name]
        set origin [dict get $hir exprs $e origin]
        if {$index >= 0} {
            set origin [lindex [lindex $supplied $index] 1]
        } elseif {[dict exists $origin node]} {
            dict set origin node "[dict get $origin node]/flag($name)"
        }
        set value [expr {$index >= 0 ? "true" : "false"}]
        lappend args [hir::resolve::Expr hir [hir::syntax::rootRef $origin $value] $ctx]
        lappend vector [list $name [expr {$index >= 0}]]
    }
    dict set hir exprs $e args $args
    dict set hir exprs $e flagVector $vector
}

# How a diagnostic names the callee of call E: the called name as written.
proc hir::flags::CalleeName {hir e callee} {
    return [dict get $hir exprs $callee name]
}

# After resolution: a function with flags may only be referenced as a callee
# or as the whole right side of an alias binding (hir::flags::DeclareAlias);
# any other use would let it reach a call that cannot see its flag interface.
proc hir::flags::CheckValues {hirVar} {
    upvar 1 $hirVar hir
    if {![dict exists $hir flagRefs]} {
        return
    }
    foreach e [dict get $hir flagRefs] {
        if {[dict exists $hir flagAllowed $e]} {
            continue
        }
        set name [dict get $hir exprs $e name]
        set b [dict get $hir exprs $e binding]
        set flags [join [lmap n [dict get $hir bindings $b flagIface flags] {string cat : $n}] {, }]
        hir::Diagnose hir FLAG-FUNCTION-VALUE \
            "function $name declares flags ($flags), so it can only be called directly or bound to another name (g = $name): it cannot be passed, returned or stored as a value, which would lose its flag interface" $e
    }
    dict unset hir flagRefs
    dict unset hir flagAllowed
}
