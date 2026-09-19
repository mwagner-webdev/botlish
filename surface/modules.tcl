# modules.tcl -- one-file/one-namespace cross-file resolution.
#
#   surface::modules::compileProgramFile PATH ?-strict 0|1?   => HIR
#   surface::modules::LoadNamespaces NAMESPACES ?-start-file N?
#       => {sections SECTIONS files FILES functions NAMESPACE->{FUNCTION-NAME ...}}
#
# The model (v0, deliberately small -- see AGENTS.md's milestone notes):
#
#   one source file  =  one module  =  one namespace  =  one compilation/
#                                                         dependency unit
#
# A file that starts with a `namespace NAME` declaration (parser.tcl's
# NamespaceDecl; surface::ast's `program` node carries it as its own
# `namespace`/`namespaceSpan` fields, never a body statement) is a module: a
# namespace containing ordinary function definitions and immutable value bindings.
# It has no executable top-level statements or mutable bindings. Every other .bot
# file (no `namespace`
# declaration) is an ordinary/entry program, exactly as before this
# milestone; loading one that makes no qualified reference costs nothing
# extra.
#
# Namespace <-> file: deterministic and search-free. Namespace NAME maps to
# exactly one path, $::core::libraryDir/NAME.bot (the same directory as the
# existing Tcl library convention, lib/NAME.tcl -- see core/core.tcl), and
# that file must itself declare `namespace NAME`. There is no search path,
# so "two files define namespace NAME" cannot arise: NAME has only ever one
# candidate file. A mismatched declaration, or a missing file, is a clear
# diagnostic (Error, below), never silently ignored or guessed at.
#
# Reference syntax: mod::name (surface/parser.tcl's qualname primary).
# surface/lower.tcl lowers it to a `ref` node spelled "mod::name" (for
# display only) carrying an extra `qualified {mod name}` field. No syntax
# resolves or aliases a namespace to another name (no `import X as Y`, no
# `from X import y`, no re-export): the qualified spelling is the only
# spelling, so provenance is always mechanically recoverable, exactly the
# property README.md wants of `::` (definition/provenance qualification, as
# opposed to `.`'s value access).
#
# Dependency discovery is implicit: nothing declares "this file needs
# module X" (no `import` statement of any kind -- see AGENTS.md's "imports
# may be boring": here they need not exist at all). The set of namespaces a
# file needs is exactly the set its own mod::name references name,
# discovered by walking its AST (QualifiedRefs); loading a namespace loads
# its own dependencies the same way, recursively. A namespace already being
# loaded when it is asked for again is a dependency cycle (Error CYCLE); one
# already fully loaded is simply reused (each module is parsed and resolved
# at most once per program, regardless of how many files reference it).
#
# Compiling once, without leaking unqualified names across files: every
# module's own statements are lowered to ordinary hir/syntax.tcl nodes (the
# same shape surface/lower.tcl produces for any file, origins repointed at
# the module's own FileId -- RemapFile), kept as their own SECTION (a
# {namespace NS nodes STATEMENTS origin ORIGIN} dict -- never a call/block
# wrapper: hir::lower's core IR is purely name/lexical-scope based, like
# the rest of this engine, so a binding made inside a block's own call
# invocation is unreachable from any sibling top-level code once that call
# returns -- only its return VALUE ever escapes, never a binding by name).
# Every module's section (dependencies first) is collected ahead of the
# referencing program's own statements, into ONE hir::buildSyntax call
# (its -modules option) that resolves them all together:
# hir::resolve::program gives each section its own "program"-kind scope, a
# sibling of the referencing code's own top scope (hir::resolve::
# ProgramSection) -- so two different namespaces can freely define the
# very same plain name with no collision, same-module code (including
# same-module mutual recursion, e.g. the existing is_even/is_odd pattern)
# resolves its own siblings exactly as it would in a single ordinary file,
# and hir::resolve::Expr's `block` case is never involved at all. A
# module-qualified reference elsewhere in the program resolves, not
# through ordinary lexical lookup but directly against HIR's own `modules`
# table (hir::resolve::ResolveQualifiedRef) -- to that one BindingId,
# immune to shadowing by any local named like the namespace or the symbol.
# hir::hygiene::qualifyModules then renames every binding a section
# declares (and every bare or qualified reference to it alike) to its
# qualified spelling, so lowered core IR -- and so the interpreter, the
# Tcl compiler, and native lowering alike -- see one, collision-free name
# for it everywhere, never confusing two different namespaces' same-named
# definitions. The result is compiled once by every later stage (types,
# specialize, native lowering) and referenced by every call site, never
# re-lowered or re-inlined per call site (contrast bench/refined-checks.ir's
# old -native-body, native/native.tcl, which pasted a copy of its callee's
# body into each call site's own IR -- see NATIVE-URI-ESCAPE.md \167 7).
# An envless module function uses the existing direct-call path. A module
# function that reads a retained module value uses the existing closure and
# hidden-environment machinery, still by its resolved BindingId: no
# module-specific call form or runtime namespace lookup is introduced.
#
# What this deliberately leaves out (see AGENTS.md's milestone notes for
# the full rationale): namespace aliasing/renaming, wildcard or selective
# imports, re-exports, mutable module bindings, lazy initialization,
# separate/incremental compilation, a search path, package versioning. A
# namespace's dependency graph must be acyclic (Error CYCLE);
# ordinary same-module recursion (including mutual recursion) is unaffected
# -- it was never a *module* dependency to begin with.

namespace eval surface::modules {}

# The one deterministic path namespace NAME maps to. No search path: this
# is the only file that can ever define NAME.
proc surface::modules::ModulePath {name} {
    if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $name]} {
        error "surface::modules: invalid namespace name \"$name\""
    }
    return [file join $::core::libraryDir $name.bot]
}

# Raises {SURFACE MODULE KIND} "LOCATION: MESSAGE" (or just MESSAGE if SPAN
# is "", for callers with no source span -- e.g. the native backend's
# module-native bridge, native/native.tcl).
proc surface::modules::Error {kind span message} {
    if {$span eq ""} {
        throw [list SURFACE MODULE $kind] $message
    }
    throw [list SURFACE MODULE $kind] "[surface::ast::location $span]: $message"
}

# {NAMESPACE NAME SPAN} of every mod::name reference in AST (a program node,
# or any node -- used both for a whole file and, recursively, isn't needed
# below this), in source order.
proc surface::modules::QualifiedRefs {ast} {
    set found {}
    QualifiedRefsWalk $ast found
    return $found
}

proc surface::modules::QualifiedRefsWalk {node foundVar} {
    upvar 1 $foundVar found
    if {[dict get $node kind] eq "qualname"} {
        lappend found [list [dict get $node namespace] [dict get $node name] [dict get $node span]]
        return
    }
    foreach child [surface::ast::Children $node] {
        QualifiedRefsWalk $child found
    }
}

# ORIGIN (an hir/syntax.tcl node's or block-parameter's origin) repointed at
# FILEID: every surface-produced origin is {file F node ... }, always F=f1
# (surface/lower.tcl's Origin hard-codes f1, since ordinary single-file
# lowering never needs more than one file); this is the only place that
# changes, so a module's diagnostics and source locations still point at
# its own file, never at the file that happened to reference it.
proc surface::modules::RemapOrigin {origin fileId} {
    dict set origin file $fileId
    return $origin
}

# NODE (an hir/syntax.tcl node, as surface::lower::Sequence produces) with
# every origin in its subtree repointed at FILEID.
proc surface::modules::RemapFile {node fileId} {
    dict set node origin [RemapOrigin [dict get $node origin] $fileId]
    switch -- [dict get $node kind] {
        bind {
            dict set node value [RemapFile [dict get $node value] $fileId]
        }
        block {
            set params {}
            foreach param [dict get $node params] {
                lassign $param name origin
                lappend params [list $name [RemapOrigin $origin $fileId]]
            }
            dict set node params $params
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
        }
        call {
            dict set node callee [RemapFile [dict get $node callee] $fileId]
            dict set node args [lmap child [dict get $node args] {RemapFile $child $fileId}]
        }
        if {
            dict set node condition [RemapFile [dict get $node condition] $fileId]
            dict set node thenOrigin [RemapOrigin [dict get $node thenOrigin] $fileId]
            dict set node thenBody [lmap child [dict get $node thenBody] {RemapFile $child $fileId}]
            dict set node elseOrigin [RemapOrigin [dict get $node elseOrigin] $fileId]
            dict set node elseBody [lmap child [dict get $node elseBody] {RemapFile $child $fileId}]
        }
        loop {
            dict set node bodyOrigin [RemapOrigin [dict get $node bodyOrigin] $fileId]
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
        }
        return - ok - error {
            dict set node value [RemapFile [dict get $node value] $fileId]
        }
        break {
            if {[dict get $node value] ne ""} {
                dict set node value [RemapFile [dict get $node value] $fileId]
            }
        }
    }
    return $node
}

# Loads namespace NAME (and, recursively, everything it depends on) into
# STATE if not already loaded, raising Error CYCLE if NAME is already being
# loaded (found on STATE's own "stack"). USEDATSPAN is the span of the
# reference that asked for it, for diagnostics ("" if none -- a
# non-source-driven load, e.g. the native backend's bridge).
proc surface::modules::LoadNamespace {stateVar name usedAtSpan} {
    upvar 1 $stateVar state
    if {[dict exists $state loaded $name]} {
        return
    }
    if {$name in [dict get $state stack]} {
        set chain [concat [dict get $state stack] [list $name]]
        Error CYCLE $usedAtSpan "module dependency cycle: [join $chain { -> }]"
    }
    set path [ModulePath $name]
    if {![file exists $path]} {
        Error UNKNOWN-NAMESPACE $usedAtSpan "unknown namespace \"$name\": no such module file $path"
    }
    set ast [surface::parse [core::ReadFile $path] $path]
    if {[dict get $ast namespace] ne $name} {
        if {[dict get $ast namespace] eq ""} {
            Error NAMESPACE-MISMATCH [dict get $ast span] \
                "$path must start with \"namespace $name\" to be loaded as namespace \"$name\" (found no namespace declaration)"
        }
        Error NAMESPACE-MISMATCH [dict get $ast namespaceSpan] \
            "$path declares \"namespace [dict get $ast namespace]\", but only namespace \"$name\" can load from this path"
    }
    foreach statement [dict get $ast body] {
        if {[dict get $statement kind] ni {function bind}} {
            Error INVALID-TOPLEVEL [dict get $statement span] \
                "module \"$name\" ($path): only function definitions and immutable bindings are allowed at module top level, found a \"[dict get $statement kind]\" statement"
        }
    }
    dict set state stack [concat [dict get $state stack] [list $name]]
    set fileId f[dict get $state nextFile]
    dict set state files $fileId $path
    dict incr state nextFile
    CollectAndLoad state $ast
    set functionNames [lmap statement [dict get $ast body] {dict get $statement name}]
    dict set state loaded $name $functionNames
    set statements [lmap node [surface::lower::Sequence [dict get $ast body]] {RemapFile $node $fileId}]
    set origin [RemapOrigin [surface::lower::Origin [dict get $ast span] "namespace"] $fileId]
    set section [dict create namespace $name nodes $statements origin $origin]
    dict set state sections [concat [dict get $state sections] [list $section]]
    dict set state stack [lrange [dict get $state stack] 0 end-1]
}

# Loads every namespace AST's own qualified references name (recursively),
# and validates each reference names a definition that namespace actually
# has (Error UNKNOWN-SYMBOL otherwise) -- distinct from an unknown
# namespace entirely (Error UNKNOWN-NAMESPACE, raised by LoadNamespace).
proc surface::modules::CollectAndLoad {stateVar ast} {
    upvar 1 $stateVar state
    foreach ref [QualifiedRefs $ast] {
        lassign $ref namespaceName symbolName span
        LoadNamespace state $namespaceName $span
        set functionNames [dict get $state loaded $namespaceName]
        if {$symbolName ni $functionNames} {
            Error UNKNOWN-SYMBOL $span \
                "namespace \"$namespaceName\" has no definition \"$symbolName\" (it defines: [join [lsort $functionNames] {, }])"
        }
    }
}

# {sections SECTIONS files FILES functions NAMESPACE->{FUNCTION-NAME ...}}
# for NAMESPACES and everything they transitively depend on -- the general
# module loader's entry point for a caller with no source AST of its own
# (native/native.tcl's module-native bridge: it names the namespaces a
# native's registered -module-fn needs directly, not via source syntax).
# SECTIONS is ready for hir::buildSyntax's -modules; FILES is ready to
# merge into its -files. FileIds start at f(START), so a caller that
# reserves f1 for its own root file can pass -start-file 2 (as
# surface::modules::compileProgramFile does); the default, 1, suits a
# caller with no file of its own.
proc surface::modules::LoadNamespaces {namespaces args} {
    set options [dict create -start-file 1]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::modules::LoadNamespaces: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set state [dict create files [dict create] nextFile [dict get $options -start-file] \
        loaded [dict create] stack {} sections {}]
    foreach name $namespaces {
        LoadNamespace state $name ""
    }
    return [dict create sections [dict get $state sections] files [dict get $state files] \
        functions [dict get $state loaded]]
}

# The HIR of the .bot program file PATH, after loading (and compiling once,
# alongside it) every module its qualified references need, transitively.
# -strict as surface::lowerToHir's.
proc surface::modules::compileProgramFile {path args} {
    set options [dict create -strict 1]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::modules::compileProgramFile: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set ast [surface::parse [core::ReadFile $path] $path]
    set state [dict create files [dict create f1 [dict get $ast span file]] nextFile 2 \
        loaded [dict create] stack {} sections {}]
    CollectAndLoad state $ast
    set hir [hir::buildSyntax [surface::lower::Sequence [dict get $ast body]] -strict 0 \
        -origin [surface::lower::Origin [dict get $ast span] ""] \
        -files [dict get $state files] -modules [dict get $state sections]]
    return [surface::lower::Finish $hir [dict get $options -strict]]
}
