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
# A file's namespace is its path; nothing in the file declares it. A file
# that is *loaded* (imported, or named by the native module bridge) is a
# module: a namespace containing ordinary function definitions, immutable
# value bindings, type, struct and error declarations (surface/parser.tcl's
# `typedecl` -- hir/sourcetypes.tcl; SOURCE-DEFINED-INTEGER-DOMAINS.md). It
# has no executable top-level statements or mutable bindings. The file given
# to compileProgramFile is the entry program, an ordinary program in no
# namespace: its own definitions are plain names and its types keep their
# bare names.
#
# Namespace <-> file: deterministic and search-free. Namespace NAME maps to
# exactly one path, $::core::libraryDir/NAME.bot (the same directory as the
# existing Tcl library convention, lib/NAME.tcl -- see core/core.tcl): the
# file's path *is* its namespace, so there is nothing to disagree with, and
# there is no `namespace` declaration (the parser rejects one with a
# message saying so). A nested namespace (NAME of several "::"-separated
# segments, `abi::x86_64`) maps one directory per leading segment:
# $::core::libraryDir/abi/x86_64.bot. Nesting is a naming path only:
# `abi::x86_64` and `abi` are two unrelated modules (neither loads, contains
# or sees the other implicitly), each its own file. There is no search path,
# so "two files define namespace NAME" cannot arise: NAME has only ever one
# candidate file. A missing file is a clear diagnostic (Error, below), never
# silently ignored or guessed at.
#
# Reference syntax (needs the file's `import mod`, or `import a::b`): mod::name, or a::b::name for a nested namespace a::b
# (surface/parser.tcl's qualname primary: every segment but the last is the
# namespace path).
# surface/lower.tcl lowers it to a `ref` node spelled "mod::name" (for
# display only) carrying an extra `qualified {mod name}` field. No syntax
# resolves or aliases a namespace to another name (no `import X as Y`, no
# `from X import y`, no re-export): the qualified spelling is the only
# spelling, so provenance is always mechanically recoverable, exactly the
# property README.md wants of `::` (definition/provenance qualification, as
# opposed to `.`'s value access).
#
# Dependencies are declared, never discovered (IMPORTS.md): a file's header
# (after its `namespace` declaration) lists `import NAMESPACE` -- a direct,
# exact dependency on that namespace, authorizing its qualified `NAMESPACE::
# name` references and making its functions candidates for method-call
# sugar -- and `import type NAMESPACE::Type`, one type's short name. The
# imports are the only thing that loads a module: CollectAndLoad (below)
# validates the header (existence, duplicates, type-name collisions),
# loads each imported module (recursively, through that module's own header),
# and rejects every qualified reference whose namespace the file itself does
# not import exactly (MISSING-IMPORT: an imported parent, child or
# dependency of the namespace never counts), before any body is resolved.
# A namespace that is being loaded when it is imported again is a dependency
# cycle (Error CYCLE); one already fully loaded is simply reused (each module
# is parsed and resolved at most once per program, regardless of how many
# files import it). A namespace exists if it has a module file or compiler
# intrinsics (`str`, `linux::abi`), so an intrinsics-only namespace is
# importable with no file. The result of the header, per file, is its
# import environment (NewState's `imports`: the dependency graph), handed to
# hir::buildSyntax as -imports; the AST (cached, importer-neutral) keeps the
# header only as `program.imports`.
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
# very same plain name with no collision, same-module code
# resolves its own earlier siblings (and itself, for recursion) exactly as it
# would in a single ordinary file -- in source order: a module function may
# not call a later one, and same-module mutual recursion is rejected like any
# other (STRICT-REFERENCE-DETERMINISM.md) --
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
# imports, subtree imports, re-exports, mutable module bindings, lazy
# initialization, separate/incremental compilation, a search path, package
# versioning. A namespace's dependency graph must be acyclic (Error CYCLE);
# a function's own recursion inside its module is unaffected -- it was never a
# *module* dependency to begin with. Within one module, definitions are
# established in source order (hir/resolve.tcl): the module's own section is
# resolved completely before any section or program that names it, so a
# qualified reference always names an established binding of another unit.

namespace eval surface::modules {
    # Module ASTs by {PATH SOURCE}: surface::parse is a pure function of a
    # file's text and path, so a module whose file still has exactly the
    # text it had is not lexed and parsed again by the next compilation in
    # the same process (a test file, a batch driver). Keyed by the text
    # itself, never by a timestamp, so it cannot go stale; a file that does
    # not parse raises and is never stored. Cleared whole past 64 entries.
    variable parsed [dict create]
}

# The AST of the module file PATH (see `parsed` above).
proc surface::modules::ParseModule {path} {
    variable parsed
    set source [core::ReadFile $path]
    set key [list $path $source]
    if {[dict exists $parsed $key]} {
        return [dict get $parsed $key]
    }
    set ast [surface::parse $source $path]
    if {[dict size $parsed] >= 64} {
        set parsed [dict create]
    }
    dict set parsed $key $ast
    return $ast
}

# The one deterministic path namespace NAME maps to. No search path: this
# is the only file that can ever define NAME. A nested NAME (`abi::x86_64`)
# is one directory per leading segment (lib/abi/x86_64.bot): never a "::" in
# a file name.
proc surface::modules::ModulePath {name} {
    set segments [split [string map {:: \x00} $name] \x00]
    foreach segment $segments {
        if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $segment]} {
            error "surface::modules: invalid namespace name \"$name\""
        }
    }
    return [file join $::core::libraryDir {*}[lrange $segments 0 end-1] [lindex $segments end].bot]
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

# {NAMESPACE NAME SPAN KIND} of every mod::name reference in AST (a program
# node, or any node -- used both for a whole file and, recursively, isn't
# needed below this), in source order. KIND is value (an expression
# `ns::name`), struct (a construction `ns::Name {...}`) or type (a qualified
# type annotation `ns::Name`: a struct or a source-defined `type`).
proc surface::modules::QualifiedRefs {ast} {
    set found {}
    QualifiedRefsWalk $ast found
    return $found
}

proc surface::modules::QualifiedRefsWalk {node foundVar} {
    upvar 1 $foundVar found
    switch -- [dict get $node kind] {
        qualname {
            lappend found [list [dict get $node namespace] [dict get $node name] [dict get $node span] value]
            return
        }
        namedstruct {
            # NAMESPACE::Struct { ... }: a reference to the struct type
            # (STRUCTS.md); its field values may hold more references.
            if {[dict get $node namespace] ne ""} {
                lappend found [list [dict get $node namespace] [dict get $node name] \
                    [dict get $node nameSpan] struct]
            }
        }
        function {
            # Qualified struct types in parameter and result annotations.
            foreach param [dict get $node params] {
                TypeRefs [lindex $param 2] [lindex $param 3] found
            }
            TypeRefs [dict get $node resultType] [dict get $node resultTypeSpan] found
            if {[dict exists $node proves]} {
                foreach clause [dict get $node proves] {
                    TypeRefs [dict get $clause type] [dict get $clause typeSpan] found
                }
            }
        }
        typedecl {
            # A refinement's carrier (REFINEMENT-VALUES.md) may be a
            # qualified type of another module.
            if {[dict exists $node form] && [dict get $node form] eq "refined"} {
                TypeRefs [dict get $node carrier] [dict get $node carrierSpan] found
            }
        }
        structdecl {
            foreach field [dict get $node fields] {
                TypeRefs [dict get $field type] [dict get $field typeSpan] found
            }
        }
        traitdecl {
            # A requirement's parameter and result types (TRAITS.md).
            foreach r [dict get $node requirements] {
                foreach param [dict get $r params] {
                    TypeRefs [lindex $param 2] [lindex $param 3] found
                }
                TypeRefs [dict get $r resultType] [dict get $r resultTypeSpan] found
            }
        }
    }
    foreach child [surface::ast::Children $node] {
        QualifiedRefsWalk $child found
    }
}

# The import header (`import NS` lines, one per line, sorted) a program whose
# text is SOURCE needs for the qualified references it makes itself and does
# not already import -- exactly the namespaces it names, never an ancestor or
# a dependency of them. For source *generators* (fuzzers, benchmark drivers
# that assemble a program from fragments): `[ImportHeader $text]$text` is
# the program with its dependencies declared, and the same text a person
# would write. "" if nothing is missing. "" too if SOURCE does not parse.
proc surface::modules::ImportHeader {source} {
    if {[catch {surface::parse $source} ast]} {
        # Not a program: nothing to declare (the compile reports the syntax error).
        return ""
    }
    set own ""
    set have [lmap import [dict get $ast imports] {
        if {[dict get $import kind] ne "import"} continue
        dict get $import namespace
    }]
    set needed {}
    foreach ref [QualifiedRefs $ast] {
        set ns [lindex $ref 0]
        if {$ns ne $own && $ns ni $have && $ns ni $needed} {
            lappend needed $ns
        }
    }
    return [join [lmap ns [lsort $needed] {string cat "import " $ns "\n"}] ""]
}

# Appends the qualified type names ("ns::Name") TYPE (a surface::
# parser::TypeExpr result) mentions, each located at SPAN.
proc surface::modules::TypeRefs {type span foundVar} {
    upvar 1 $foundVar found
    if {$type eq ""} {
        return
    }
    if {[llength $type] == 1} {
        # Split at the last "::": the namespace may itself be nested
        # ("abi::x86_64::Register64" is Register64 of abi::x86_64).
        if {[regexp {^((?:[A-Za-z_][A-Za-z0-9_]*::)*[A-Za-z_][A-Za-z0-9_]*)::([A-Za-z_][A-Za-z0-9_]*)$} $type -> namespaceName name]} {
            lappend found [list $namespaceName $name $span type]
        }
        return
    }
    lassign $type head arg
    if {$head eq "fn"} {
        foreach t [dict get $arg args] { TypeRefs $t $span found }
        TypeRefs [dict get $arg return] $span found
        return
    }
    TypeRefs $arg $span found
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

# FLAGS ({NAME ORIGIN} pairs, FLAGS.md) with every origin repointed at FILEID.
proc surface::modules::RemapFlags {flags fileId} {
    return [lmap flag $flags {
        lassign $flag name origin
        list $name [RemapOrigin $origin $fileId]
    }]
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
            dict set node flags [RemapFlags [expr {[dict exists $node flags] ? [dict get $node flags] : {}}] $fileId]
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
            # paramTypes carries no origin of its own (plain type-name
            # strings, resolved later by hir/resolve.tcl): nothing to remap.
        }
        call {
            dict set node flags [RemapFlags [expr {[dict exists $node flags] ? [dict get $node flags] : {}}] $fileId]
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
        listloop {
            dict set node iterable [RemapFile [dict get $node iterable] $fileId]
            dict set node elementOrigin [RemapOrigin [dict get $node elementOrigin] $fileId]
            dict set node bodyOrigin [RemapOrigin [dict get $node bodyOrigin] $fileId]
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
        }
        countloop {
            dict set node start [RemapFile [dict get $node start] $fileId]
            dict set node end [RemapFile [dict get $node end] $fileId]
            dict set node countOrigin [RemapOrigin [dict get $node countOrigin] $fileId]
            dict set node bodyOrigin [RemapOrigin [dict get $node bodyOrigin] $fileId]
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
        }
        lockloop {
            set domains {}
            foreach domain [dict get $node domains] {
                dict set domain origin [RemapOrigin [dict get $domain origin] $fileId]
                foreach operand {iterable start end} {
                    if {[dict exists $domain $operand]} {
                        dict set domain $operand [RemapFile [dict get $domain $operand] $fileId]
                    }
                }
                lappend domains $domain
            }
            dict set node domains $domains
            dict set node bodyOrigin [RemapOrigin [dict get $node bodyOrigin] $fileId]
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
        }
        handle {
            dict set node call [RemapFile [dict get $node call] $fileId]
            set handlers {}
            foreach handler [dict get $node handlers] {
                dict set handler origin [RemapOrigin [dict get $handler origin] $fileId]
                dict set handler body [lmap child [dict get $handler body] {RemapFile $child $fileId}]
                lappend handlers $handler
            }
            dict set node handlers $handlers
        }
        struct {
            set fields {}
            foreach field [dict get $node fields] {
                dict set field origin [RemapOrigin [dict get $field origin] $fileId]
                dict set field nameOrigin [RemapOrigin [dict get $field nameOrigin] $fileId]
                dict set field value [RemapFile [dict get $field value] $fileId]
                lappend fields $field
            }
            dict set node fields $fields
            if {[dict get $node type] ne "" && [dict exists $node type origin]} {
                dict set node type origin [RemapOrigin [dict get $node type origin] $fileId]
            }
        }
        project {
            dict set node receiver [RemapFile [dict get $node receiver] $fileId]
            dict set node nameOrigin [RemapOrigin [dict get $node nameOrigin] $fileId]
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
    set ast [ParseModule $path]
    foreach statement [dict get $ast body] {
        if {[dict get $statement kind] eq "destructure"} {
            # Not a missing feature of destructuring: a module binding is a
            # context-free, provably immutable value (hir/modulebinding.tcl),
            # and no struct value or field projection is one, so neither the
            # explicit spelling nor this one could ever be accepted here.
            Error INVALID-TOPLEVEL [dict get $statement span] \
                "module \"$name\" ($path): a struct destructuring is not allowed at module top level (module bindings are context-free immutable values, and a struct value is not one: MODULE-BINDINGS.md); destructure inside a function"
        }
        if {[dict get $statement kind] eq "with"} {
            # `with context EXPR` (CONTEXTS.md): installation exists only in
            # the entry program's top-level scope -- its own diagnostic, the
            # one HIR gives an installation anywhere else.
            Error CONTEXT-INSTALLATION-UNSUPPORTED [dict get $statement span] \
                "context installation is currently supported only in the entry program's top-level scope, as a statement (this one is inside a module: \"$name\", $path)"
        }
        if {[dict get $statement kind] ni {function bind typedecl errordecl structdecl traitdecl}} {
            Error INVALID-TOPLEVEL [dict get $statement span] \
                "module \"$name\" ($path): only function definitions, immutable bindings, type declarations, struct declarations, trait declarations and error declarations are allowed at module top level, found a \"[dict get $statement kind]\" statement"
        }
    }
    CheckNativeMembers $ast $name "module \"$name\" ($path)"
    dict set state stack [concat [dict get $state stack] [list $name]]
    set fileId f[dict get $state nextFile]
    dict set state files $fileId $path
    dict incr state nextFile
    CollectAndLoad state $ast $name
    set functionNames [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] in {typedecl errordecl structdecl traitdecl}} continue
        dict get $statement name
    }]
    dict set state loaded $name $functionNames
    # The struct types the module declares (STRUCTS.md): a separate name
    # space from its definitions, named from other code as `NAME::Struct`.
    dict set state loadedStructs $name [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "structdecl"} continue
        dict get $statement name
    }]
    # The source-defined types (`type`) and errors it declares: a type is a
    # member of the namespace, `NAME::Type` (hir/sourcetypes.tcl), what
    # `import type NAME::Type` names; errors stay program-global names.
    dict set state loadedTypes $name [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "typedecl"} continue
        dict get $statement name
    }]
    dict set state loadedErrors $name [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "errordecl"} continue
        dict get $statement name
    }]
    # The traits it declares (TRAITS.md): type-level members of the
    # namespace like its types, named `NAME::Trait` and importable with
    # `import type`.
    dict set state loadedTraits $name [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "traitdecl"} continue
        dict get $statement name
    }]
    lassign [surface::lower::SplitTypeDecls [dict get $ast body] $name] executable decls errorDecls structDecls traitDecls
    dict set state typeDecls [concat [dict get $state typeDecls] $decls]
    dict set state errorDecls [concat [dict get $state errorDecls] $errorDecls]
    dict set state structDecls [concat [dict get $state structDecls] $structDecls]
    dict set state traitDecls [concat [dict get $state traitDecls] $traitDecls]
    set statements [lmap node [surface::lower::Sequence $executable] {RemapFile $node $fileId}]
    set origin [RemapOrigin [surface::lower::Origin [dict get $ast span] "namespace"] $fileId]
    set section [dict create namespace $name nodes $statements origin $origin \
        imports [dict get $state imports $name]]
    dict set state sections [concat [dict get $state sections] [list $section]]
    dict set state stack [lrange [dict get $state stack] 0 end-1]
}

# Raises DUPLICATE-NATIVE if the module AST (the file of namespace NAME) defines
# (a function or an immutable binding) a member NAME::MEMBER that is a
# compiler/runtime-provided intrinsic: a root native registered under that
# qualified name (core::native::isQualifiedNative -- list::at, str::concat,
# mutable_array::set, linux::abi::syscall, ...). Every reference spelled
# NAME::MEMBER denotes the native (surface/lower.tcl), so such a definition
# could never be named, would silently not replace the intrinsic, and
# Botlish has no overloading for it to coexist as. The protection is per
# member, not per namespace: NAME's module may define any other member
# (lib/list.bot's list::get beside the intrinsic list::at). WHO describes the
# module for the message. An entry program is no namespace (NAME ""): its
# definitions are plain names, which can never be spelled with "::".
proc surface::modules::CheckNativeMembers {ast name who} {
    if {$name eq ""} {
        return
    }
    foreach statement [dict get $ast body] {
        if {[dict get $statement kind] in {function bind}
                && [core::native::isQualifiedNative "${name}::[dict get $statement name]"]} {
            set member [dict get $statement name]
            Error DUPLICATE-NATIVE [dict get $statement span] \
                "$who cannot define \"$member\": ${name}::$member is a compiler-provided intrinsic (a root native registered under that qualified name), which every reference of that spelling denotes; it cannot be redefined or overloaded (other members of namespace \"$name\" are unaffected)"
        }
    }
}

# The intrinsic members of namespace NS: the compiler-provided qualified
# root natives that live directly in it (core::native::qualifiedMembers),
# which no source module can define and which exist without any module file.
proc surface::modules::IntrinsicMembers {ns} {
    return [core::native::qualifiedMembers $ns]
}

# 1 if NS names a real namespace: a source module file ($libraryDir/NS.bot)
# or a namespace of compiler-provided intrinsics (`str`, `linux::abi`). A
# bare prefix of either (`linux` of `linux::abi`) is not one: namespaces are
# exact, never trees.
proc surface::modules::NamespaceExists {ns} {
    return [expr {[file exists [ModulePath $ns]] || [IntrinsicMembers $ns] ne ""}]
}

# 1 if SHORT cannot be bound by a type import because it already names a
# built-in type (a primitive, `Int`, `any`, a type constructor like `List`,
# or a type the compiler registers itself): a file's own type names and
# its type imports must never silently shadow, or be shadowed by, one.
proc surface::modules::IsBuiltinTypeName {short} {
    return [expr {$short in {Int any never Fn} || [dict exists $::hir::types::constructors $short]
        || [core::type::isBuiltinName $short]}]
}

# The namespaces a file imports, spelled for the "not imported" hint: a
# parent or child of NS among IMPORTED explains that imports are exact.
proc surface::modules::RelatedImport {ns imported} {
    foreach other $imported {
        if {[string first ${other}:: $ns] == 0 || [string first ${ns}:: $other] == 0} {
            return $other
        }
    }
    return ""
}

# Validates the file header of AST (its `import` and `typeimport` nodes,
# IMPORTS.md), loading what each import depends on into STATE, and returns
# the file's import environment, a dict
#
#   namespaces  {NS ...}       the directly imported namespaces, in written order
#   types       {SHORT CANONICAL ...}   the type imports: SHORT is the one local
#                              type name, CANONICAL the qualified identity
#                              `NS::Name` of the type it denotes
#
# which is everything later stages know about the header: the AST itself
# stays importer-neutral (it is cached by surface::modules::ParseModule and
# shared). KEY is the namespace this file is the module of ("" for an entry
# program); OWN the namespace it declares ("" if none). Every failure is a
# located diagnostic raised from here, before any body is resolved:
#
#   UNKNOWN-NAMESPACE    the imported namespace names no module file and no
#                        intrinsics (nothing is looked up later)
#   DUPLICATE-IMPORT     the same namespace, or the same type, imported twice
#   SELF-IMPORT          a file imports the namespace it itself belongs to
#   UNKNOWN-SYMBOL       `import type NS::T`: NS has no type T
#   NOT-A-TYPE           `import type NS::T`: T exists but is not a source type
#   TYPE-IMPORT-COLLISION  a type import's short name is another type import's
#                        short name, a type this file declares, or a built-in
# and CYCLE from loading the imported module.
proc surface::modules::CheckImports {stateVar ast own} {
    upvar 1 $stateVar state
    set namespaces {}
    set nsSpans [dict create]
    set types [dict create]
    set typeSpans [dict create]
    set local [dict create]
    foreach statement [dict get $ast body] {
        if {[dict get $statement kind] in {typedecl structdecl traitdecl} && ![dict exists $local [dict get $statement name]]} {
            dict set local [dict get $statement name] [dict get $statement nameSpan]
        }
    }
    foreach import [dict get $ast imports] {
        set ns [dict get $import namespace]
        set span [dict get $import namespaceSpan]
        if {[dict get $import kind] eq "import"} {
            if {[dict exists $nsSpans $ns]} {
                Error DUPLICATE-IMPORT $span "namespace \"$ns\" is already imported (first imported at [surface::ast::location [dict get $nsSpans $ns]])"
            }
            if {$ns eq $own} {
                Error SELF-IMPORT $span "a file of namespace \"$ns\" cannot import its own namespace: a module is inside its namespace and needs no import to name its own members"
            }
            if {![NamespaceExists $ns]} {
                Error UNKNOWN-NAMESPACE $span "unknown namespace \"$ns\": no such module file [ModulePath $ns] and no intrinsics of that namespace"
            }
            if {[file exists [ModulePath $ns]]} {
                LoadNamespace state $ns $span
            }
            dict set nsSpans $ns $span
            lappend namespaces $ns
            continue
        }
        # import type NS::Name
        set name [dict get $import name]
        set nameSpan [dict get $import nameSpan]
        set canonical "${ns}::$name"
        if {[dict exists $typeSpans $canonical]} {
            Error DUPLICATE-IMPORT [dict get $import span] "type \"$canonical\" is already imported (first imported at [surface::ast::location [dict get $typeSpans $canonical]])"
        }
        if {$ns eq $own} {
            Error SELF-IMPORT [dict get $import span] "a file of namespace \"$ns\" cannot import a type of its own namespace: its own type \"$name\" is already usable by that name"
        }
        if {![NamespaceExists $ns]} {
            Error UNKNOWN-NAMESPACE $span "unknown namespace \"$ns\": no such module file [ModulePath $ns] and no intrinsics of that namespace (in \"import type $canonical\")"
        }
        set hasFile [file exists [ModulePath $ns]]
        if {$hasFile} {
            LoadNamespace state $ns $span
        }
        set typeNames [expr {$hasFile ? [concat [dict get $state loadedTypes $ns] [dict get $state loadedTraits $ns]] : {}}]
        if {$name ni $typeNames} {
            set functions [expr {$hasFile ? [dict get $state loaded $ns] : {}}]
            set structs [expr {$hasFile ? [dict get $state loadedStructs $ns] : {}}]
            set errors [expr {$hasFile ? [dict get $state loadedErrors $ns] : {}}]
            if {$name in $functions || $name in [IntrinsicMembers $ns]} {
                Error NOT-A-TYPE $nameSpan "\"$canonical\" exists, but is not a type (it is a function or value of namespace \"$ns\"): `import type` imports source-defined types only; use it as $canonical after `import $ns`"
            }
            if {$name in $structs} {
                Error NOT-A-TYPE $nameSpan "\"$canonical\" is a struct, not a source-defined `type`: `import type` imports `type` declarations only; spell the struct $canonical after `import $ns`"
            }
            if {$name in $errors} {
                Error NOT-A-TYPE $nameSpan "\"$canonical\" is an error declaration, not a type"
            }
            Error UNKNOWN-SYMBOL $nameSpan "namespace \"$ns\" has no type \"$name\" (its types: [expr {$typeNames eq "" ? "none" : [join [lsort $typeNames] {, }]}])"
        }
        if {[dict exists $local $name]} {
            Error TYPE-IMPORT-COLLISION $nameSpan "`import type $canonical` binds the type name \"$name\", which this file also declares itself (at [surface::ast::location [dict get $local $name]]); an imported type never shadows or is shadowed by a local one: drop the import and spell the imported type $canonical (after `import $ns`)"
        }
        if {[IsBuiltinTypeName $name]} {
            Error TYPE-IMPORT-COLLISION $nameSpan "`import type $canonical` binds the type name \"$name\", which is a built-in type; spell the imported type $canonical (after `import $ns`) instead"
        }
        if {[dict exists $types $name]} {
            Error TYPE-IMPORT-COLLISION $nameSpan "`import type $canonical` and `import type [dict get $types $name]` (at [surface::ast::location [dict get $typeSpans [dict get $types $name]]]) both bind the type name \"$name\"; there is no precedence and no renaming: import at most one and spell the other fully qualified (after `import $ns`)"
        }
        dict set types $name $canonical
        dict set typeSpans $canonical [dict get $import span]
    }
    return [dict create namespaces $namespaces types $types]
}

# Validates the imports of AST (CheckImports), and that every qualified
# reference AST makes is authorized and names a real member. The sequence per
# reference is the one the language specifies: is the reference's namespace
# the file's own, or imported *exactly* (an imported parent or child never
# counts)? If so, does that namespace have the member? A reference into a
# namespace that is not imported is MISSING-IMPORT even when the member
# exists (`str::concat` without `import str`); one into a namespace that does
# not exist at all is UNKNOWN-NAMESPACE (no import could repair it); an
# authorized reference to a member the namespace lacks is UNKNOWN-SYMBOL.
#
# Imports are the only thing that loads a module: a qualified reference never
# loads anything. KEY is the module namespace of AST ("" for an entry
# program); the file's import environment is recorded in STATE's `imports`
# under KEY, for hir::buildSyntax's -imports and the module's own section.
proc surface::modules::CollectAndLoad {stateVar ast {key ""}} {
    upvar 1 $stateVar state
    set own $key
    set env [CheckImports state $ast $own]
    dict set state imports $key $env
    set imported [dict get $env namespaces]
    foreach ref [QualifiedRefs $ast] {
        lassign $ref namespaceName symbolName span refKind
        if {$namespaceName eq $own && $own ne ""
                && $refKind in {value} && [core::native::isQualifiedNative "${namespaceName}::$symbolName"]} {
            # A reference to an intrinsic of the file's own namespace
            # (lib/list.bot's own list::at): no import, nothing to load.
            continue
        }
        if {$namespaceName eq $own && $own ne "" && $key ne ""} {
            # Own namespace: members of the module being compiled need no
            # import (the HIR resolver checks the member is established).
            continue
        }
        if {$namespaceName ni $imported} {
            if {![NamespaceExists $namespaceName]} {
                Error UNKNOWN-NAMESPACE $span "unknown namespace \"$namespaceName\": no such module file [ModulePath $namespaceName] and no intrinsics of that namespace"
            }
            set note ""
            set related [RelatedImport $namespaceName $imported]
            if {$related ne ""} {
                set note " (imports are exact: `import $related` does not import \"$namespaceName\")"
            }
            Error MISSING-IMPORT $span "namespace \"$namespaceName\" is not imported; add `import $namespaceName` to use `${namespaceName}::$symbolName`$note"
        }
        set natives [IntrinsicMembers $namespaceName]
        if {$refKind eq "value" && [core::native::isQualifiedNative "${namespaceName}::$symbolName"]} {
            # A root native registered under a qualified name
            # (linux::abi::syscall, str::concat): no module file defines it,
            # so nothing more is loaded (surface/lower.tcl lowers it to a
            # root reference).
            continue
        }
        if {![file exists [ModulePath $namespaceName]]} {
            # A namespace whose only members are intrinsics (str): there is
            # no module file, so an unknown member is reported against the
            # intrinsics, not as a missing file.
            Error UNKNOWN-SYMBOL $span \
                "namespace \"$namespaceName\" has no [expr {$refKind eq "value" ? "definition" : "type"}] \"$symbolName\" (its members are the intrinsics: [join $natives {, }])"
        }
        # The import loaded the module.
        if {$refKind in {struct type}} {
            set structNames [dict get $state loadedStructs $namespaceName]
            set typeNames [expr {$refKind eq "type" ? [concat [dict get $state loadedTypes $namespaceName] [dict get $state loadedTraits $namespaceName]] : {}}]
            if {$symbolName ni $structNames && $symbolName ni $typeNames} {
                set declared [lsort [concat $structNames $typeNames]]
                Error UNKNOWN-SYMBOL $span \
                    "namespace \"$namespaceName\" has no [expr {$refKind eq "type" ? "type" : "struct"}] \"$symbolName\" (it declares: [expr {$declared eq "" ? "no types" : [join $declared {, }]}])"
            }
            continue
        }
        set functionNames [dict get $state loaded $namespaceName]
        if {$symbolName ni $functionNames
                && !([string index $symbolName end] eq "?"
                    && [string range $symbolName 0 end-1] in [dict get $state loadedTypes $namespaceName])} {
            Error UNKNOWN-SYMBOL $span \
                "namespace \"$namespaceName\" has no definition \"$symbolName\" (it defines: [join [lsort [concat $functionNames $natives]] {, }])"
        }
    }
}

# The initial loader state of a program whose own root file is FILES (a dict
# FileId -> path; {} for a caller with no file of its own) and whose module
# files start at FileId f(NEXTFILE): the one constructor of the state
# LoadNamespace/CollectAndLoad thread through, so every caller (this file's
# own entry points, examples/stdlib/corpus.tcl's text-based compile) carries
# every table -- loaded definitions, loaded struct types, sections and the
# three kinds of declaration -- without a copy of the list to keep in sync.
# `imports` is the dependency graph: NAMESPACE (or "" for the entry program)
# -> that file's import environment (CheckImports).
proc surface::modules::NewState {files nextFile} {
    return [dict create files $files nextFile $nextFile \
        loaded [dict create] loadedStructs [dict create] loadedTypes [dict create] \
        loadedErrors [dict create] loadedTraits [dict create] imports [dict create] stack {} sections {} \
        typeDecls {} errorDecls {} structDecls {} traitDecls {}]
}

# {sections SECTIONS files FILES functions NAMESPACE->{FUNCTION-NAME ...}
# imports NAMESPACE->ENV ...} for NAMESPACES and everything they
# transitively import -- the general module loader's entry point for a
# caller with no source AST of its own (it names the namespaces directly,
# not via source syntax). SECTIONS is ready for hir::buildSyntax's
# -modules; FILES is ready to merge into its -files; imports (the import
# environments of every loaded module) into its -imports. FileIds start at
# f(START), so a caller that reserves f1 for its own root file can pass
# -start-file 2 (as surface::modules::compileProgramFile does); the default,
# 1, suits a caller with no file of its own.
proc surface::modules::LoadNamespaces {namespaces args} {
    set options [dict create -start-file 1]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::modules::LoadNamespaces: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set state [NewState [dict create] [dict get $options -start-file]]
    foreach name $namespaces {
        LoadNamespace state $name ""
    }
    return [dict create sections [dict get $state sections] files [dict get $state files] \
        functions [dict get $state loaded] typeDecls [dict get $state typeDecls] \
        errorDecls [dict get $state errorDecls] structDecls [dict get $state structDecls] \
        traitDecls [dict get $state traitDecls] imports [dict get $state imports]]
}

# The HIR of the entry program AST (a `program` node whose file is FILE ... in
# every origin), after loading -- and compiling once, alongside it -- every
# module its imports name, transitively. Shared by compileProgramFile and by
# callers that compile source text instead of a file (examples/stdlib/
# corpus.tcl). Returns HIR before the frontend's finishing steps
# (surface::lower::Finish).
proc surface::modules::BuildProgram {ast strict} {
    set state [NewState [dict create f1 [dict get $ast span file]] 2]
    CollectAndLoad state $ast ""
    lassign [surface::lower::SplitTypeDecls [dict get $ast body]] executable ownDecls ownErrorDecls ownStructDecls ownTraitDecls
    set decls [concat [dict get $state typeDecls] $ownDecls]
    set errorDecls [concat [dict get $state errorDecls] $ownErrorDecls]
    set structDecls [concat [dict get $state structDecls] $ownStructDecls]
    set traitDecls [concat [dict get $state traitDecls] $ownTraitDecls]
    return [hir::buildSyntax [surface::lower::Sequence $executable] -strict 0 \
        -halt-on-resolution-errors $strict \
        -origin [surface::lower::Origin [dict get $ast span] ""] \
        -files [dict get $state files] -modules [dict get $state sections] \
        -imports [dict get $state imports] \
        -type-decls $decls -error-decls $errorDecls -struct-decls $structDecls -trait-decls $traitDecls]
}

# The HIR of the .bot program file PATH, after loading (and compiling once,
# alongside it) every module its imports name, transitively.
# -strict as surface::lowerToHir's.
proc surface::modules::compileProgramFile {path args} {
    set options [dict create -strict 1 -warnings [hir::warnings::defaultMode] -warning-channel stderr]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::modules::compileProgramFile: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set ast [surface::parse [core::ReadFile $path] $path]
    set hir [BuildProgram $ast [dict get $options -strict]]
    return [surface::lower::Finish $hir [dict get $options -strict] \
        [dict get $options -warnings] [dict get $options -warning-channel]]
}
