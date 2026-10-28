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
# Namespace <-> file: deterministic and search-free (STD-NAMESPACE.md). Every
# namespace path is resolved from the namespace root, and its first segment
# says whose it is -- its *origin*, which is never part of its identity:
#
#   std::NAME   the standard library's: the compiler-owned root namespace std
#               is the directory $::core::libraryDir (stdlib/ beside core/:
#               core/core.tcl), so std::NAME is exactly the path
#               $::core::libraryDir/NAME.bot, or compiler intrinsics of
#               std::NAME (StandardNamespace, ModulePath);
#   NAME        the application's: the module ROOT/NAME.bot under the
#               program's application root, the directory of its entry file
#               ("Application modules", below).
#
# The file's path *is* its namespace, so there is nothing to disagree with,
# and there is no `namespace` declaration (the parser rejects one with a
# message saying so). A nested namespace (NAME of several "::"-separated
# segments, `std::abi::x86_64`) maps one directory per leading segment:
# $::core::libraryDir/abi/x86_64.bot. Nesting is a naming path only:
# `std::abi::x86_64` and `std::abi` are two unrelated modules (neither loads,
# contains or sees the other implicitly), each its own file. A path names one
# origin and has only ever one candidate file there, so "two files define
# namespace NAME" cannot arise, adding a file elsewhere never changes what an
# import resolves to, and nothing falls back from one origin to another (a
# missing application `list` is never std::list). A missing file is a clear
# diagnostic (Error, below), never silently ignored or guessed at.
#
# Rooted paths (STD-NAMESPACE.md, "Rooted paths"). A leading "::" names the
# namespace root explicitly: `import ::std::list`, `::std::list::at(xs, 0)`,
# `x: ::std::abi::U8Value`, `on ::std::list::NotFound:`. Every path is
# resolved from the root, so the parser records the canonical path
# (`std::list`) and, on an import, a qualified value or a construction, a
# `rooted` flag, which only the loader reads (CheckRef: a rooted qualifier is
# always a namespace, never a type of the file). The root marker is never
# part of an identity: `::std::list::at` and `std::list::at` are one callee,
# one HIR, one cache entry's worth of program.
#
# Architecture-specific modules (LINUX-SYSCALL-TRANSPORTS.md). A namespace
# whose source differs by machine architecture -- std::linux::sys, the Linux
# syscall numbers and register conventions -- has no NAME.bot but one file
# per architecture instead, NAME.ARCH.bot (stdlib/linux/sys.x86_64.bot,
# stdlib/linux/sys.aarch64.bot; ARCH one of core::cabi::architectures), and the
# compilation target's architecture (the same -target, the host's by
# default, that std::ffi::c's widths follow) picks the one that defines NAME
# (ModuleFile). Still one file per namespace per compilation, still no
# search: a namespace segment cannot contain a dot, so NAME.ARCH.bot is never
# another namespace's file, and the qualified spelling stays the only one
# (std::linux::sys::write is defined by exactly the target's file). A namespace
# with both kinds of file is AMBIGUOUS-MODULE; one with no file for the
# target's architecture is UNSUPPORTED-ARCHITECTURE (and, on a host that is
# no known target, UNKNOWN-TARGET: compile with -target). The selection is by
# architecture only, never by operating system: the module's own namespace
# says which OS it is for (below).
#
# Platform namespaces. The target table designates the standard namespace
# trees that are an operating system's platform interface
# (core::cabi::platformOf): `std::linux` and every namespace under it
# (std::linux::sys, std::linux::io, std::linux::path, the syscall transports
# std::linux::abi::x86_64 and std::linux::abi::aarch64) are Linux's,
# `std::darwin`'s tree macOS's and `std::windows`'s Windows'. Nothing is
# inferred from a spelling: a module that happens to be named like an
# operating system (an application's `windows`) is no platform's. Importing one is UNSUPPORTED-PLATFORM
# when the compilation target's operating system is another one
# (std::linux::sys for macos-aarch64 never becomes stdlib/linux/sys.aarch64.bot just
# because both are AArch64), and UNKNOWN-TARGET on a host that is no known
# target (PlatformCheck, before any file is chosen). Nothing is mapped or
# substituted: a Linux module is never another system's. An architecture-
# specific namespace outside a platform (std::abi::aarch64, a demo::arch) stays
# available to every operating system of its architecture, and an
# application module is the application's whatever its name.
#
# Target dependence. A build reads the target in exactly three places: an
# architecture-specific module's file (ModuleFile), a platform namespace's
# check (PlatformCheck) and std::ffi::c's scalars (hir::cabi::NamespaceTypeDecls).
# The loader records whether any of them ran (STATE's `targetRead`), and the
# HIR records the target only then (BuildProgram: its `target`, "" for a
# program whose HIR is the same for every target), so a HIR built for one
# target is never taken for another's (hir::cabi::targetOf: the native
# driver's host check, the interchange's -target check).
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
# intrinsics (`str`, `std::linux::abi::x86_64`), so an intrinsics-only namespace is
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
    # The root namespace of the standard library (STD-NAMESPACE.md): `std`
    # and every namespace under it are the compiler's, never an
    # application's, and std itself names no module.
    variable standardRoot std
    # Program file ASTs by {PATH SOURCE} (Parse): surface::parse is a pure
    # function of a file's text and path, so a file that still has exactly
    # the text it had -- a module, or an entry program a caller parsed first
    # (main.tcl, the compiler service) -- is not lexed and parsed again by
    # the next compilation in the same process (a test file, a batch
    # driver). Keyed by the text itself, never by a timestamp, so it cannot
    # go stale; a file that does not parse is never stored. One entry per
    # file (`parsedKeys`: PATH -> its key), cleared whole past 64 entries.
    variable parsed [dict create]
    variable parsedKeys [dict create]
    # The module files read since the last compileProgramFile began: PATH ->
    # the text read. The front-end cache keeps these as the entry's
    # dependencies (surface/cache.tcl): the texts the HIR was built from,
    # never what the files hold by the time it is kept.
    variable reads [dict create]
}

# The AST of the module file PATH (see `parsed` above); its syntax errors
# raised as surface::parse raises them -- or, when RECOVERVAR names the
# loader's state of a syntax-recovering compilation, kept there (its
# `syntaxEntries`) and the malformed statements made holes
# (surface/recover.tcl, SYNTAX-RECOVERY-MILESTONE-1.md).
proc surface::modules::ParseModule {path {stateVar ""}} {
    variable reads
    set source [surface::source::text $path]
    dict set reads $path $source
    set ast [Parse $path $source]
    if {[dict get $ast diagnostics] ne ""} {
        if {$stateVar eq ""} {
            surface::raiseSyntax [dict get $ast diagnostics]
        }
        upvar 1 $stateVar state
        dict set state syntaxEntries [concat [dict get $state syntaxEntries] \
            [surface::syntaxEntries [dict get $ast diagnostics]]]
        set ast [surface::recover::apply $ast $source]
    }
    return $ast
}

# The AST of the program file PATH whose text is SOURCE, parsed with recovery
# (surface::parse -recover 1: its `diagnostics` lists every syntax error),
# from `parsed` when it holds it. A file with no syntax error has the AST a
# strict parse returns.
proc surface::modules::Parse {path source} {
    variable parsed
    set key [list $path $source]
    if {[dict exists $parsed $key]} {
        return [dict get $parsed $key]
    }
    set ast [surface::parse $source $path -recover 1]
    if {[dict get $ast diagnostics] eq ""} {
        # One AST per file: a file's newer text replaces its older one,
        # which a long-running caller that analyzes after every edit (the
        # language server) would otherwise keep, an AST per edit, up to
        # the bound.
        variable parsedKeys
        if {[dict exists $parsedKeys $path]} {
            dict unset parsed [dict get $parsedKeys $path]
        }
        if {[dict size $parsed] >= 64} {
            set parsed [dict create]
            set parsedKeys [dict create]
        }
        dict set parsed $key $ast
        dict set parsedKeys $path $key
    }
    return $ast
}

# 1 if the canonical namespace NS is a standard namespace: a namespace under
# the standard library's root (std::list, std::abi::x86_64). The root itself
# is no namespace (no module, no members).
proc surface::modules::StandardNamespace {ns} {
    variable standardRoot
    return [string match ${standardRoot}::* $ns]
}

# 1 if the canonical namespace NS is reserved to the standard library: the
# root std or a namespace under it, which no application module can be.
proc surface::modules::ReservedNamespace {ns} {
    variable standardRoot
    return [expr {$ns eq $standardRoot || [StandardNamespace $ns]}]
}

# The standard library's path for the standard namespace NAME, in
# $::core::libraryDir, the directory of the namespace std: std::list is
# stdlib/list.bot, and a nested NAME (`std::abi::x86_64`) is one directory
# per leading segment below std (stdlib/abi/x86_64.bot): never a "::" in a
# file name. "" for a namespace outside the standard library, which has no
# file there.
proc surface::modules::ModulePath {name} {
    variable standardRoot
    if {![StandardNamespace $name]} {
        return ""
    }
    return [NamespaceFile $::core::libraryDir [string range $name [string length ${standardRoot}::] end]]
}

# 1 if the file PATH is inside the standard library's directory: never an
# application module, even under an application root that contains it.
proc surface::modules::InStandardLibrary {path} {
    set library [file normalize $::core::libraryDir]
    return [expr {[string first $library/ [file normalize $path]] == 0}]
}

# The path of namespace NAME's file under the directory DIR (ModulePath's
# mapping, for any root).
proc surface::modules::NamespaceFile {dir name} {
    set segments [split [string map {:: \x00} $name] \x00]
    foreach segment $segments {
        if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $segment]} {
            error "surface::modules: invalid namespace name \"$name\""
        }
    }
    return [file join $dir {*}[lrange $segments 0 end-1] [lindex $segments end].bot]
}

# Application modules (IMPORTS.md, "Application modules") and package
# modules (BOT-MODULES-MILESTONE-1.md). A program file's *application root*
# is the directory of its entry file (compileProgramFile; STATE's `root`, ""
# for program text with no file of its own unless the caller names one).
#
# Every module file has an *owning scope* (Scope): the application (scope
# ""), the standard library (#std), or one installed *package instance*;
# program text with no application root is in none of them (#text). A
# package is installed under the immediate `.bot_modules` directory of its
# owner -- the application's root, or another package's directory:
#
#   ROOT/.bot_modules/NAME/                 the application's package NAME
#   ROOT/.bot_modules/NAME/.bot_modules/D/  package NAME's own package D
#
# The installed directory structure is the whole of it: no manifest, no
# version, no registry. A package instance is identified by its place in
# the program's logical dependency tree (Instance): the application's
# package NAME is the instance NAME, that package's package D the instance
# NAME/D, and so on -- never by an absolute path, a version or a load order,
# so equivalent builds give it the same identity, wherever the application
# lives.
#
# A namespace NAME an import of a file in scope S names is, by its first
# segment HEAD and nothing else (no search, no fallback, no precedence):
#
#   * std::NAME: the standard namespace -- $::core::libraryDir/NAME.bot (or
#     its architecture-specific files, ModuleFile below), or compiler
#     intrinsics of std::NAME -- for every file alike. S's own file
#     DIR/std/NAME.bot is never one, nor is an installed DIR/.bot_modules/std:
#     either makes the import RESERVED-NAMESPACE;
#   * std itself: no namespace (the root of the standard library);
#   * HEAD the name of a package installed in S (S's DIR/.bot_modules/HEAD is
#     a directory): that package's module PKG/NAME.bot (PKG/HEAD.bot for
#     HEAD itself, PKG/HEAD/a.bot for HEAD::a). The package claims its whole
#     root namespace in S: when S has a file of its own that would be NAME,
#     the import is MODULE-COLLISION, naming both, never a silent choice;
#   * otherwise, in the application: the application module ROOT/NAME.bot
#     (nested: ROOT/a/b.bot for a::b), one namespace like any module, loaded
#     once; else no namespace (UNKNOWN-NAMESPACE, which names the standard
#     namespace std::NAME when there is one: the hint of a missing `std::`,
#     never a fallback to it);
#   * otherwise, in a package instance whose directory's name is ROOTNAME:
#     its own module PKG/NAME.bot when HEAD is ROOTNAME (a package's own
#     modules are its root namespace's: ROOTNAME and ROOTNAME::...), else no
#     namespace. A package never sees its consumer's modules or packages, a
#     sibling's or an ancestor's: nothing is looked up above S.
#
# A standard-library module, and program text with no application root,
# imports standard namespaces only. The entry file itself is not a module
# (importing it is SELF-IMPORT, or CYCLE from a module). A namespace outside
# std with compiler intrinsics exists only in a test process that registers
# one (core::cabi::installTestFixture's ffi_fixture, a test's cbtest): a
# module file of its name beside it is MODULE-COLLISION. Nothing reads the
# shell's working directory, an environment variable or a parent directory,
# and nothing searches: each path has one candidate file.
#
# Identity (BOT-MODULES-MILESTONE-1.md, "Semantic identity"). A module's
# canonical identity -- the one every later stage keys it by (its section,
# its types, structs, enums, errors, traits, layouts and contexts, its
# bindings' qualified names, privacy and directness) -- is its namespace for
# the application's and the standard library's modules, and for a package
# instance's module the instance followed by its namespace below the root
# (Identity): the application's package sdl3's module sdl3::video is
# sdl3::video, as written, and package physics's own package geometry's
# module geometry::shapes is physics/geometry::shapes -- which no source
# can spell, and which never meets rendering/geometry::shapes. The loader
# names a file's own namespace and the namespaces it imports by their
# identities in everything it hands on (the import environment, and every
# qualified spelling of the file: RewriteQualified), so no stage after it
# ever sees a spelling.

# The owning scope of the file of module KEY ("" for the entry program) of
# STATE's program: "" (the application), #std (the standard library), #text
# (program text with no application root) or a package instance.
proc surface::modules::Scope {state key} {
    if {$key eq ""} {
        return [expr {[dict get $state root] eq "" ? "#text" : ""}]
    }
    return [dict get $state scopeOf $key]
}

# 1 if SCOPE is a package instance's.
proc surface::modules::IsPackageScope {scope} {
    return [expr {$scope ni {"" #std #text}}]
}

# 1 if SCOPE has a module tree and packages of its own: the application's
# and every package instance's.
proc surface::modules::HasOwnTree {scope} {
    return [expr {$scope ni {#std #text}}]
}

# The directory of SCOPE (one with a module tree) in STATE's program: the
# application root, or the package instance's directory.
proc surface::modules::ScopeDir {state scope} {
    if {$scope eq ""} {
        return [dict get $state root]
    }
    return [dict get $state packages $scope dir]
}

# The root namespace of package instance SCOPE: its directory's name, the
# instance's last segment.
proc surface::modules::PackageName {scope} {
    return [lindex [split $scope /] end]
}

# The first segment of the namespace NAME.
proc surface::modules::Head {name} {
    set cut [string first :: $name]
    if {$cut < 0} {
        return $name
    }
    return [string range $name 0 [expr {$cut - 1}]]
}

# The canonical identity of the module whose namespace in its own scope
# SCOPE is NAME (header, "Identity"): NAME itself for the application's,
# the standard library's and program text's, and for a package instance's
# the instance followed by NAME below its root segment (sdl3/helper::util for
# helper::util of the instance sdl3/helper; helper's root module is
# sdl3/helper).
proc surface::modules::Identity {scope name} {
    if {![IsPackageScope $scope]} {
        return $name
    }
    return $scope[string range $name [string length [Head $name]] end]
}

# A description of SCOPE for a message.
proc surface::modules::ScopeText {state scope} {
    switch -- $scope {
        ""    { return "the application ([dict get $state root])" }
        #std  { return "the standard library" }
        #text { return "program text with no application root" }
    }
    return "package [PackageName $scope] (instance $scope, at [ScopeDir $state $scope])"
}

# The probes the loader made since the last compileProgramFile began: PATH ->
# file or directory. The front-end cache keeps them as the entry's
# dependencies (surface/cache.tcl): resolution is a function of what they
# answered, so a file or a package directory appearing or disappearing at
# one of them changes what a build would do.
namespace eval surface::modules {
    variable probes [dict create]
}

# The source provider's answer for PATH (surface/source.tcl): 1 if a source
# file (KIND file) or a directory (KIND directory) is there; recorded in
# `probes`.
proc surface::modules::Probe {kind path} {
    variable probes
    dict set probes $path $kind
    if {$kind eq "directory"} {
        return [surface::source::directory $path]
    }
    return [surface::source::exists $path]
}

# The directory of the package NAME installed in SCOPE (DIR/.bot_modules/NAME).
proc surface::modules::PackageDir {state scope name} {
    return [file join [ScopeDir $state $scope] .bot_modules $name]
}

# 1 if a package NAME is installed in SCOPE (one with a module tree): its
# directory exists.
proc surface::modules::Installed {state scope name} {
    return [Probe directory [PackageDir $state $scope $name]]
}

# The package instance NAME installed in SCOPE, recorded in STATE's
# `packages` (instance -> {name NAME parent SCOPE dir DIR}) the first time it
# is named. Its identity is SCOPE/NAME, or NAME in the application.
proc surface::modules::Instance {stateVar scope name} {
    upvar 1 $stateVar state
    # (Never expr's ?: over a name: `nan` and `inf` read as numbers there.)
    if {$scope eq ""} {
        set instance $name
    } else {
        set instance $scope/$name
    }
    if {![dict exists $state packages $instance]} {
        dict set state packages $instance [dict create name $name parent $scope \
            dir [file normalize [PackageDir $state $scope $name]]]
    }
    return $instance
}

# The file DIR/NAME.bot (nested: DIR/a/b.bot) of SCOPE's own module tree
# when there is one outside the standard library's directory (a tree inside
# stdlib/ never makes a standard module another scope's), else "".
proc surface::modules::OwnFile {state scope name} {
    set path [NamespaceFile [ScopeDir $state $scope] $name]
    if {![Probe file $path] || [InStandardLibrary $path]} {
        return ""
    }
    return $path
}

# Where the namespace NAME (canonical, as written), imported by the file of
# module KEY, is, without raising: a dict
#
#   path       its module file, or "" (intrinsics only, or none at all)
#   identity   the module's canonical identity (NAME when there is no file)
#   scope      the module's owning scope ("" when there is no file)
#   problem    "" or {KIND MESSAGE}: why the import is an error
#
# by the rules of the header (Locate is the rule; ResolveModule raises its
# problem, NamespaceExistsFor asks whether it names anything). A package
# instance named for the first time is recorded in STATE.
proc surface::modules::Locate {stateVar key name} {
    upvar 1 $stateVar state
    variable standardRoot
    set scope [Scope $state $key]
    set result [dict create path "" identity $name scope "" problem ""]
    if {[StandardNamespace $name]} {
        if {$scope eq ""} {
            # (A package's own modules are its root namespace's, which is
            # never std: its DIR/std/NAME.bot is no module of anything.)
            set shadow [OwnFile $state $scope $name]
            if {$shadow ne ""} {
                if {[NamespaceExists $name]} {
                    set standard "it names the standard library's [StandardFiles $name]"
                } else {
                    set standard "the standard library has no such namespace"
                }
                dict set result problem [list RESERVED-NAMESPACE "application file $shadow would be the namespace \"$name\", but $standardRoot and every namespace under it belong to the standard library: an application module is never a standard namespace, and `import $name` never chooses between the two ($standard); move or rename the application file out of the application's $standardRoot/ directory"]
                return $result
            }
        }
        if {[HasOwnTree $scope]} {
            if {[Installed $state $scope $standardRoot]} {
                dict set result problem [list RESERVED-NAMESPACE "[ScopeText $state $scope] has an installed package directory [PackageDir $state $scope $standardRoot], but $standardRoot and every namespace under it belong to the standard library: no package is ever named $standardRoot, and `import $name` never chooses between the two; remove or rename the package directory"]
                return $result
            }
        }
        dict set result scope #std
        return $result
    }
    if {![HasOwnTree $scope]} {
        # A standard-library module, or program text with no application
        # root: there is no module tree to import from.
        return $result
    }
    set head [Head $name]
    if {[IsPackageScope $scope] && $head eq [PackageName $scope]} {
        # The package's own module tree: its root namespace.
        if {[Installed $state $scope $head]} {
            dict set result problem [list MODULE-COLLISION "namespace \"$name\" is the root namespace of [ScopeText $state $scope] itself, and the package has a package of that name installed too ([PackageDir $state $scope $head]): a package's own modules and a package it installs never share a root namespace, and `import $name` never chooses between them; rename or remove the installed package"]
            return $result
        }
        set owner $scope
        set path [OwnFile $state $scope $name]
    } elseif {[Installed $state $scope $head]} {
        # A package installed in this scope claims its whole root namespace.
        set owner [Instance state $scope $head]
        set path [OwnFile $state $owner $name]
        if {![IsPackageScope $scope]} {
            set own [OwnFile $state $scope $name]
            if {$own ne "" && [file normalize $own] ne [dict get $state entry]} {
                # (The entry file is in no namespace: it is no module, and
                # competes with none.)
                if {$path eq ""} {
                    set theirs "which has no module \"$name\""
                } else {
                    set theirs "whose module is $path"
                }
                dict set result problem [list MODULE-COLLISION "application file $own would be the namespace \"$name\", but \"$head\" is the root namespace of the package installed at [ScopeDir $state $owner] ($theirs): an installed package claims its root namespace, and `import $name` never chooses between an application module and a package's; rename or move the application file, or remove the package"]
                return $result
            }
        }
    } elseif {[IsPackageScope $scope]} {
        # Neither the package's own namespace nor a package it installs.
        return $result
    } else {
        set owner ""
        set path [OwnFile $state "" $name]
    }
    if {$path eq ""} {
        return $result
    }
    if {[IntrinsicMembers $name] ne ""} {
        if {$owner eq ""} {
            dict set result problem [list MODULE-COLLISION "application module $path has the name of the intrinsic namespace \"$name\" (compiler intrinsics registered in this process), which `import $name` names: an intrinsic namespace is never replaced by an application file, and never silently chosen over one; rename the application module"]
        } else {
            dict set result problem [list MODULE-COLLISION "module $path of [ScopeText $state $owner] has the name of the intrinsic namespace \"$name\" (compiler intrinsics registered in this process), which `import $name` names: an intrinsic namespace is never replaced by a package's module, and never silently chosen over one"]
        }
        return $result
    }
    dict set result path $path
    dict set result identity [Identity $owner $name]
    dict set result scope $owner
    return $result
}

# The module file the namespace NAME (canonical), imported at SPAN by the
# file of module KEY, denotes (Locate): a dict {path P identity ID scope S}
# -- its standard-library file, an application module file or a package's,
# or path "" for a namespace with no file (intrinsics only, or none at all).
# Raises RESERVED-NAMESPACE, MODULE-COLLISION, SELF-IMPORT and CYCLE as the
# rules above say.
proc surface::modules::ResolveModule {stateVar key name span} {
    upvar 1 $stateVar state
    variable standardRoot
    if {$name eq $standardRoot} {
        Error UNKNOWN-NAMESPACE $span "\"$standardRoot\" is the root of the standard library, not a namespace: it has no module and no members; import one of the standard namespaces under it (`import ${standardRoot}::list`; `-help stdlib` lists them)"
    }
    set found [Locate state $key $name]
    if {[dict get $found problem] ne ""} {
        lassign [dict get $found problem] kind message
        Error $kind $span $message
    }
    if {[StandardNamespace $name]} {
        if {[NamespaceExists $name]} {
            PlatformCheck state $name $span
        }
        if {[HasModule $name]} {
            dict set found path [ModuleFile $name [dict get $state target] $span]
        }
        return $found
    }
    set path [dict get $found path]
    if {$path ne "" && [file normalize $path] eq [dict get $state entry]} {
        if {$key eq ""} {
            Error SELF-IMPORT $span "\"$name\" names this program's own entry file ($path): an entry program is in no namespace and is not a module, so it cannot be imported"
        }
        set chain [concat [list "$path (the entry program)"] [dict get $state stack] [list $name]]
        Error CYCLE $span "module dependency cycle: [join $chain { -> }] (an entry program is not a module and cannot be imported)"
    }
    return $found
}

# 1 if NS (canonical, as written) names a namespace for the file of module
# KEY of STATE's program: a standard namespace (NamespaceExists), an
# intrinsic namespace, or a module of the file's own tree or of a package
# installed in its scope (Locate).
proc surface::modules::NamespaceExistsFor {stateVar key ns} {
    upvar 1 $stateVar state
    if {[ReservedNamespace $ns]} {
        return [NamespaceExists $ns]
    }
    if {[NamespaceExists $ns]} {
        return 1
    }
    set found [Locate state $key $ns]
    return [expr {[dict get $found path] ne "" || [dict get $found problem] ne ""}]
}

# The UNKNOWN-NAMESPACE explanation of NS (canonical) for the file of module
# KEY of STATE's program: where it looked, and the standard namespace of that
# name when NS is missing its std:: (a hint, never a fallback).
proc surface::modules::NoSuchNamespace {stateVar key ns} {
    upvar 1 $stateVar state
    variable standardRoot
    if {[StandardNamespace $ns]} {
        return "the standard library has no such module file [ModulePath $ns] and no intrinsics of that namespace"
    }
    set hint ""
    if {[NamespaceExists ${standardRoot}::$ns]} {
        set hint "; the standard library's namespace of that name is ${standardRoot}::$ns (`import ${standardRoot}::$ns`): standard namespaces are named from the root std, and a namespace outside it is never looked up there"
    }
    set scope [Scope $state $key]
    if {[HasOwnTree $scope]} {
        set head [Head $ns]
        if {[IsPackageScope $scope] && $head ne [PackageName $scope] && ![Installed $state $scope $head]} {
            set stray [NamespaceFile [ScopeDir $state $scope] $ns]
            set note ""
            if {[surface::source::exists $stray]} {
                set note "; $stray is in the package's directory, but outside its root namespace \"[PackageName $scope]\", so it is no module"
            }
            return "[ScopeText $state $scope] has no package \"$head\" installed (no directory [PackageDir $state $scope $head]), and its own modules are its root namespace's, [PackageName $scope] and [PackageName $scope]::...: a package's modules see its own namespace, its own installed packages and the standard library, never its consumer's modules or packages$note$hint"
        }
        if {[Installed $state $scope $head]} {
            set instance [Instance state $scope $head]
            return "the package \"$head\" installed at [ScopeDir $state $instance] has no module \"$ns\" (no such module file [NamespaceFile [ScopeDir $state $instance] $ns])$hint"
        }
        set path [NamespaceFile [ScopeDir $state $scope] $ns]
        if {[surface::source::exists $path] && [InStandardLibrary $path]} {
            # An application root inside stdlib/ (OwnFile).
            return "$path is in the standard library's directory, so it is the standard namespace ${standardRoot}::$ns (`import ${standardRoot}::$ns`), never an application module"
        }
        if {[IsPackageScope $scope]} {
            return "[ScopeText $state $scope] has no module file $path$hint"
        }
        return "no such module file $path (an application's own modules are the files beside its entry program)$hint"
    }
    if {$key ne "" && $scope eq "#std"} {
        return "a standard-library module imports standard namespaces only (std::...)$hint"
    }
    return "this program has no application root (it was compiled from text, not from a file beside its modules), so it has no application modules$hint"
}

# The operating system whose platform the standard namespace NAME belongs
# to, or "": the target table's designation (core::cabi::platformOf) --
# `std::linux`, `std::linux::sys` and `std::linux::abi::x86_64` are Linux's
# (header, "Platform namespaces").
proc surface::modules::PlatformOf {name} {
    return [core::cabi::platformOf $name]
}

# Checks that the standard namespace NAME, imported at SPAN, is available to
# STATE's compilation target: a platform namespace (PlatformOf) only to a
# target of its operating system -- UNSUPPORTED-PLATFORM for another
# system's target, UNKNOWN-TARGET for a host that is no known target. A
# platform namespace makes the build target-dependent (`targetRead`).
proc surface::modules::PlatformCheck {stateVar name span} {
    upvar 1 $stateVar state
    set os [PlatformOf $name]
    if {$os eq ""} {
        return
    }
    set target [dict get $state target]
    set system [core::cabi::systemName $os]
    if {$target eq ""} {
        Error UNKNOWN-TARGET $span "namespace \"$name\" belongs to the $system platform, and this host ($::tcl_platform(os) $::tcl_platform(machine)) is none of the known targets; compile with -target ([join [core::cabi::targetNames] {, }])"
    }
    set meta [core::cabi::target $target]
    if {[dict get $meta os] ne $os} {
        Error UNSUPPORTED-PLATFORM $span "namespace \"$name\" belongs to the $system platform (the standard namespace [PlatformRoot $os] and every namespace under it), which is unavailable for target $target ([core::cabi::systemName [dict get $meta os]] on [dict get $meta arch]): a $system module is never chosen for, mapped to or substituted on another operating system, whatever the architecture; compile for a $system target (-target $os-[dict get $meta arch]) or import no $system namespace"
    }
    dict set state targetRead 1
}

# DECLS (surface/lower.tcl's LinkDeclOf dicts) of unit NAMESPACE ("" the
# entry program), checked and placed (NATIVE-LINK-PLAN-MILESTONE-1.md):
#
#   * a static archive's path is resolved from the application root, the
#     entry file's directory, whichever unit declares it: an imported
#     application module's path means what it would in the entry program,
#     and nothing depends on the working directory. The root is the
#     declaration's BASE, kept beside the path as written and joined only
#     where the program is linked (the driver: codegen/aot.rs). A
#     standard-library module's BASE is "" (its files never see the
#     application, and it names no archive of the compiler's own), as is
#     every unit's of a program compiled from text, which has no root;
#   * a framework is Apple's: UNSUPPORTED-PLATFORM for a target whose linker
#     has none (core::cabi::linksFrameworks), and a build that declares one
#     depends on its target (`targetRead`), so its HIR is the macOS
#     target's.
proc surface::modules::LinkDecls {stateVar decls namespace} {
    upvar 1 $stateVar state
    set base [dict get $state root]
    if {$namespace ne "" && [StandardNamespace $namespace]} {
        set base ""
    }
    return [lmap decl $decls {
        if {[dict get $decl link] eq "framework"} {
            FrameworkCheck state $decl
        }
        if {[dict get $decl path] ne ""} {
            dict set decl base $base
        }
        set decl
    }]
}

# Checks that the framework declaration DECL (a LinkDeclOf dict) is one the
# compilation's target links (LinkDecls).
proc surface::modules::FrameworkCheck {stateVar decl} {
    upvar 1 $stateVar state
    set span [dict get $decl nameSpan]
    set target [dict get $state target]
    set name [dict get $decl name]
    if {$target eq ""} {
        Error UNKNOWN-TARGET $span "framework \"$name\" is an Apple framework, linked for a macOS target only, and this host ($::tcl_platform(os) $::tcl_platform(machine)) is none of the known targets; compile with -target ([join [core::cabi::targetNames] {, }])"
    }
    if {![core::cabi::linksFrameworks $target]} {
        set meta [core::cabi::target $target]
        Error UNSUPPORTED-PLATFORM $span "framework \"$name\" (`extern c framework`) is an Apple framework, which only macOS's linker links, and this compilation is for target $target ([core::cabi::systemName [dict get $meta os]] on [dict get $meta arch]): a framework is never mapped to a library or linked for another operating system; compile for a macOS target (-target macos-[dict get $meta arch]) or declare no framework"
    }
    dict set state targetRead 1
}

# The platform root namespace of the operating system OS (core::cabi's
# `platforms`: std::linux for linux).
proc surface::modules::PlatformRoot {os} {
    dict for {root system} $::core::cabi::platforms {
        if {$system eq $os} {
            return $root
        }
    }
    return $os
}

# The C ABI target a tool on this host compiles the program text SOURCE for
# when it runs programs of every platform (the golden runner, the warning
# gate): "" -- the host's -- unless SOURCE's header imports a platform
# namespace (PlatformOf) of another operating system than the host's, and
# then that system's target of this host's architecture
# (core::cabi::systemTarget: a Linux program on an arm64 Mac is compiled for
# linux-aarch64, and runs there on the Tcl backends only). A compilation's
# own target is always its -target or the host's: the compiler never calls
# this. Text that does not parse is the host's (its compilation reports why).
proc surface::modules::PlatformTarget {source} {
    set host [core::cabi::hostTarget]
    if {$host eq ""} {
        set hostOs ""
    } else {
        set hostOs [dict get [core::cabi::target $host] os]
    }
    if {[lsort -unique [concat [dict values $::core::cabi::platforms] [list $hostOs]]] eq [list $hostOs]} {
        # Every platform is the host's own: nothing to read.
        return ""
    }
    if {[catch {surface::parse $source} ast]} {
        return ""
    }
    foreach import [dict get $ast imports] {
        set os [PlatformOf [dict get $import namespace]]
        if {$os ne "" && $os ne $hostOs} {
            return [core::cabi::systemTarget $os]
        }
    }
    return ""
}

# The path of the standard namespace NAME's architecture-specific module file
# for architecture ARCH: ModulePath with ARCH before the extension
# (stdlib/linux/sys.x86_64.bot for std::linux::sys); "" outside the standard
# library.
proc surface::modules::ArchModulePath {name arch} {
    set path [ModulePath $name]
    if {$path eq ""} {
        return ""
    }
    return "[file rootname $path].$arch.bot"
}

# The standard namespace NAME's architecture-specific module files that
# exist, as {ARCH PATH ...} in architecture order. Each candidate is one
# fixed path per known architecture: no search.
proc surface::modules::ArchModuleFiles {name} {
    set files {}
    if {![StandardNamespace $name]} {
        return $files
    }
    foreach arch [core::cabi::architectures] {
        set path [ArchModulePath $name $arch]
        if {[surface::source::exists $path]} {
            lappend files $arch $path
        }
    }
    return $files
}

# 1 if the standard namespace NAME has a module source: its file, or
# architecture-specific files (whether or not one is the compilation
# target's). 0 for every namespace outside the standard library.
proc surface::modules::HasModule {name} {
    set path [ModulePath $name]
    return [expr {($path ne "" && [surface::source::exists $path]) || [ArchModuleFiles $name] ne ""}]
}

# The standard library's files of the standard namespace NAME, for a
# message: its module file, its architecture-specific files, or "compiler
# intrinsics" for a namespace with none.
proc surface::modules::StandardFiles {name} {
    set path [ModulePath $name]
    if {$path ne "" && [surface::source::exists $path]} {
        return $path
    }
    set files [dict values [ArchModuleFiles $name]]
    if {$files eq ""} {
        return "compiler intrinsics"
    }
    return [join $files {, }]
}

# The module file that defines namespace NAME when compiling for C ABI
# target TARGET (core/cabi.tcl; "" when the host is none of the known ones):
# ModulePath when it exists, else the architecture-specific file of TARGET's
# architecture. USEDATSPAN locates the errors: AMBIGUOUS-MODULE for both
# kinds of file, UNKNOWN-TARGET for an architecture-specific namespace
# without a known target, UNSUPPORTED-ARCHITECTURE for no file of TARGET's
# architecture, UNKNOWN-NAMESPACE for none at all.
proc surface::modules::ModuleFile {name target usedAtSpan} {
    if {![StandardNamespace $name]} {
        Error UNKNOWN-NAMESPACE $usedAtSpan "unknown namespace \"$name\": the standard library's namespaces are under std (a module of the standard library is std::NAME)"
    }
    set path [ModulePath $name]
    set archFiles [ArchModuleFiles $name]
    if {[surface::source::exists $path]} {
        if {$archFiles ne ""} {
            Error AMBIGUOUS-MODULE $usedAtSpan "namespace \"$name\" has both a module file $path and architecture-specific module files ([join [dict values $archFiles] {, }]): a namespace is either the same on every architecture or specific to each, never both"
        }
        return $path
    }
    if {$archFiles eq ""} {
        Error UNKNOWN-NAMESPACE $usedAtSpan "unknown namespace \"$name\": no such module file $path"
    }
    if {$target eq ""} {
        Error UNKNOWN-TARGET $usedAtSpan "namespace \"$name\" is architecture-specific (its files are [join [dict values $archFiles] {, }]), and this host ($::tcl_platform(os) $::tcl_platform(machine)) is none of the known targets; compile with -target ([join [core::cabi::targetNames] {, }])"
    }
    set arch [dict get [core::cabi::target $target] arch]
    if {![dict exists $archFiles $arch]} {
        Error UNSUPPORTED-ARCHITECTURE $usedAtSpan "namespace \"$name\" has no module for the $arch architecture of target $target: it is architecture-specific, and its files are [join [dict values $archFiles] {, }] (no [ArchModulePath $name $arch])"
    }
    return [dict get $archFiles $arch]
}

# Raises {SURFACE MODULE KIND} "LOCATION: MESSAGE" (or just MESSAGE if SPAN
# is "", for callers with no source span -- e.g. the native backend's
# module-native bridge, native/native.tcl), as one diagnostic of
# core::raiseDiagnostics whose `location` is SPAN itself: the span the text
# names, as data (COMPILER-SERVICE-MILESTONE-1.md). RELATED, if given, is
# the span of the one further place the diagnostic is about.
proc surface::modules::Error {kind span message {related ""}} {
    set entry [dict create errorcode [list SURFACE MODULE $kind] message $message \
        summary $message location $span related [if {$related eq ""} {list} else {list $related}]]
    if {$span ne ""} {
        dict set entry message "[surface::ast::location $span]: $message"
    }
    core::raiseDiagnostics [list $entry]
}

# {NAMESPACE NAME SPAN KIND ROOTED} of every mod::name reference in AST (a
# program node, or any node), in source order. KIND is value (an expression
# `ns::name`), struct (a construction `ns::Name {...}`), type (a qualified
# type annotation `ns::Name`: a struct or a source-defined `type`, wherever a
# type is written -- a parameter, a result, a context parameter, a variadic
# parameter, a resume clause, a struct, layout or error payload field, a
# refinement's carrier, a trait requirement, an extern's C type, an imprint)
# or error (a qualified error `ns::Name` in a `fail`, an `on` handler, an
# `errors` clause or a function type's `errors` list: ERROR-PAYLOADS.md,
# "Module-qualified error identity"). NAMESPACE is the canonical path;
# ROOTED is 1 for a value or a construction written from the root
# (`::std::list::at`), whose qualifier is always a namespace (CheckRef). A
# type or an error name is a namespace member however it is spelled, and
# the parser keeps it canonical (STD-NAMESPACE.md): its ROOTED is 0.
#
# QualifiedRefs and RewriteQualified are one traversal (Walk): the places
# whose qualified spellings the loader checks are exactly the places whose
# spellings it rewrites to identities.
proc surface::modules::QualifiedRefs {ast} {
    variable walk
    set saved $walk
    set walk [dict create found {} map {} rewriting 0]
    try {
        Walk $ast
        return [dict get $walk found]
    } finally {
        set walk $saved
    }
}

# AST (a node) with every qualified spelling whose namespace MAP (written
# namespace -> canonical identity: CheckImports' names of the file) maps
# replaced by its identity: `geometry::area(p)` in a module of package
# physics, whose installed geometry is the instance physics/geometry, is
# `physics/geometry::area(p)` (header, "Identity"). A namespace MAP does not
# name -- one the file may not name, which CheckRef reports -- is left as
# written; so is a case qualifier `NS::Enum` whose namespace NS MAP names
# (MapNamespace).
proc surface::modules::RewriteQualified {ast map} {
    variable walk
    set saved $walk
    set walk [dict create found {} map $map rewriting [expr {[dict size $map] > 0}]]
    try {
        return [Walk $ast]
    } finally {
        set walk $saved
    }
}

namespace eval surface::modules {
    # The traversal in progress (QualifiedRefs, RewriteQualified): the
    # references found, the map spellings are rewritten by, and whether it
    # rewrites anything (a walk that only finds references builds no node).
    variable walk [dict create found {} map {} rewriting 0]
}

# The identity MAP gives the written namespace NS: NS's own entry, else, for
# a case qualifier NS = PREFIX::Enum, PREFIX's entry followed by ::Enum; NS
# itself when MAP names neither.
proc surface::modules::MapNamespace {ns map} {
    if {[dict size $map] == 0} {
        return $ns
    }
    if {[dict exists $map $ns]} {
        return [dict get $map $ns]
    }
    set cut [string last :: $ns]
    if {$cut > 0} {
        set prefix [string range $ns 0 [expr {$cut - 1}]]
        if {[dict exists $map $prefix]} {
            return [dict get $map $prefix][string range $ns $cut end]
        }
    }
    return $ns
}

# Records the reference {NS NAME SPAN KIND ROOTED} of the traversal in
# progress, and returns the namespace NS is written as after it.
proc surface::modules::Ref {ns name span kind rooted} {
    variable walk
    dict lappend walk found [list $ns $name $span $kind $rooted]
    return [MapNamespace $ns [dict get $walk map]]
}

# NODE after the traversal in progress: its qualified references recorded,
# and rewritten, in source order.
proc surface::modules::Walk {node} {
    if {[dict exists $node imprints]} {
        # A call's explicit imprints (C-ABI-TYPES.md) name types like any
        # annotation.
        Put node imprints [lmap type [dict get $node imprints] span [dict get $node imprintSpans] {
            TypeRefs $type $span
        }]
    }
    switch -- [dict get $node kind] {
        qualname {
            Put node namespace [Ref [dict get $node namespace] [dict get $node name] [dict get $node span] value \
                [dict getdef $node rooted 0]]
            return $node
        }
        fail {
            Put node name [ErrorRef [dict get $node name] [dict get $node nameSpan]]
        }
        handledcall {
            Put node handlers [lmap handler [dict get $node handlers] {
                dict set handler name [ErrorRef [dict get $handler name] [dict get $handler nameSpan]]
            }]
        }
        namedstruct {
            # NAMESPACE::Struct { ... }: a reference to the struct type
            # (STRUCTS.md); its field values may hold more references.
            if {[dict get $node namespace] ne ""} {
                Put node namespace [Ref [dict get $node namespace] [dict get $node name] \
                    [dict get $node nameSpan] struct [dict getdef $node rooted 0]]
            }
            if {[dict exists $node typeArg]} {
                # NAME[TYPE] { ... } (BINARY-LAYOUT.md): `LayoutStruct[geo::
                # Pair] {...}` names the layout geo::Pair.
                Put node typeArg [TypeRefs [dict get $node typeArg] [dict get $node typeArgSpan]]
            }
            if {[dict exists $node typeArgs]} {
                # Pair[geo::Point, int] { ... } (TRAIT-CONSTRAINED-IMPRINTED-
                # TYPES.md): every argument's references.
                Put node typeArgs [lmap t [dict get $node typeArgs] span [dict get $node typeArgSpans] {
                    TypeRefs $t $span
                }]
            }
        }
        function {
            # Qualified struct types in parameter and result annotations,
            # qualified errors in the `errors` clause.
            Put node errors [lmap pair [dict get $node errors] {
                lreplace $pair 0 0 [ErrorRef {*}$pair]
            }]
            Put node params [lmap param [dict get $node params] {
                lreplace $param 2 2 [TypeRefs [lindex $param 2] [lindex $param 3]]
            }]
            Put node resultType [TypeRefs [dict get $node resultType] [dict get $node resultTypeSpan]]
            if {[dict exists $node proves]} {
                Put node proves [lmap clause [dict get $node proves] {
                    dict set clause type [TypeRefs [dict get $clause type] [dict get $clause typeSpan]]
                }]
            }
            # A context parameter's type (CONTEXTS.md), the variadic
            # parameter's List type (VARIADICS-VERTICAL-SLICE-1.md) and the
            # resume clause's message type (COROUTINES.md).
            Put node contexts [lmap c [dict getdef $node contexts {}] {
                dict set c type [TypeRefs [dict get $c type] [dict get $c typeSpan]]
            }]
            foreach clause {variadic resume} {
                if {[dict getdef $node $clause ""] ne ""} {
                    Put node $clause type [TypeRefs [dict get $node $clause type] [dict get $node $clause typeSpan]]
                }
            }
        }
        typedecl {
            # A refinement's carrier (REFINEMENT-VALUES.md) may be a
            # qualified type of another module.
            if {[dict exists $node form] && [dict get $node form] eq "refined"} {
                Put node carrier [TypeRefs [dict get $node carrier] [dict get $node carrierSpan]]
            }
        }
        structdecl - layoutdecl - errordecl {
            # A layout field's type (BINARY-LAYOUT.md) is a qualified
            # integer domain or a qualified nested layout like a struct
            # field's type, and so is an error's payload field's
            # (ERROR-PAYLOADS.md).
            if {[dict exists $node fields]} {
                Put node fields [lmap field [dict get $node fields] {
                    dict set field type [TypeRefs [dict get $field type] [dict get $field typeSpan]]
                }]
            }
            # A type slot's trait (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md) may
            # be another module's: `K satisfies ui::Printable`.
            if {[dict exists $node slots]} {
                Put node slots [lmap slot [dict get $node slots] {
                    if {[dict get $slot trait] ne ""} {
                        dict set slot trait [TypeRefs [dict get $slot trait] [dict get $slot traitSpan]]
                    }
                    set slot
                }]
            }
        }
        externfn {
            # An extern declaration's C types (C-FFI.md): `std::ffi::c::Ptr[...]`
            # and every qualified pointee name their namespaces.
            Put node params [lmap param [dict get $node params] {
                dict set param type [TypeRefs [dict get $param type] [dict get $param typeSpan]]
            }]
            Put node resultType [TypeRefs [dict get $node resultType] [dict get $node resultTypeSpan]]
        }
        traitdecl {
            # A requirement's parameter and result types (TRAITS.md).
            Put node requirements [lmap r [dict get $node requirements] {
                dict set r params [lmap param [dict get $r params] {
                    lreplace $param 2 2 [TypeRefs [lindex $param 2] [lindex $param 3]]
                }]
                dict set r resultType [TypeRefs [dict get $r resultType] [dict get $r resultTypeSpan]]
                dict set r errors [lmap pair [dict get $r errors] {
                    lreplace $pair 0 0 [ErrorRef {*}$pair]
                }]
            }]
        }
        classdecl - dfadecl {
            # A declared recognizer's qualified classes and callees
            # (DFA-COROUTINE-MILESTONE-2.md): surface/dfa.tcl checks and
            # reports them itself, so they are rewritten, never recorded.
            set node [DfaRewrite $node]
        }
    }
    variable walk
    if {[dict get $walk rewriting]} {
        return [surface::ast::MapChildren $node surface::modules::Walk]
    }
    foreach child [surface::ast::Children $node] {
        Walk $child
    }
    return $node
}

# NODE's KEY ... set to VALUE (`dict set`) when the traversal in progress
# rewrites (Walk); a walk that only finds references leaves it as it is.
proc surface::modules::Put {nodeVar args} {
    variable walk
    if {[dict get $walk rewriting]} {
        upvar 1 $nodeVar node
        dict set node {*}$args
    }
}

# The class or recognizer declaration NODE with its qualified class items
# and callees rewritten by the traversal in progress (Walk).
proc surface::modules::DfaRewrite {node} {
    variable walk
    set map [dict get $walk map]
    if {[dict size $map] == 0} {
        return $node
    }
    if {[dict get $node kind] eq "classdecl"} {
        foreach field {items except} {
            dict set node $field [DfaItemsRewrite [dict get $node $field] $map]
        }
        return $node
    }
    dict set node classes [lmap c [dict get $node classes] {DfaRewrite $c}]
    dict set node states [lmap state [dict get $node states] {
        dict set state transitions [lmap t [dict get $state transitions] {
            dict set t items [DfaItemsRewrite [dict get $t items] $map]
            if {[dict exists $t callee] && [lindex [dict get $t callee] 0] ne ""} {
                dict set t callee [lreplace [dict get $t callee] 0 0 [MapNamespace [lindex [dict get $t callee] 0] $map]]
            }
            set t
        }]
    }]
    return $node
}

proc surface::modules::DfaItemsRewrite {items map} {
    return [lmap item $items {
        if {[dict get $item kind] eq "class" && [dict get $item namespace] ne ""} {
            dict set item namespace [MapNamespace [dict get $item namespace] $map]
        }
        set item
    }]
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

# The error spelling SPELLING (located at SPAN) after the traversal in
# progress: when qualified (`ns::Name`, `a::b::Name`) its reference
# {NAMESPACE NAME SPAN error} recorded, and its namespace rewritten.
proc surface::modules::ErrorRef {spelling span} {
    set cut [string last :: $spelling]
    if {$cut > 0} {
        set name [string range $spelling [expr {$cut + 2}] end]
        return [Ref [string range $spelling 0 [expr {$cut - 1}]] $name $span error 0]::$name
    }
    return $spelling
}

# TYPE (a surface::parser::TypeExpr result) after the traversal in
# progress: every qualified type name ("ns::Name") it mentions recorded,
# each located at SPAN, and rewritten -- and the qualified errors of a
# function type's `errors` list.
proc surface::modules::TypeRefs {type span} {
    if {$type eq ""} {
        return $type
    }
    if {[llength $type] == 1} {
        # Split at the last "::": the namespace may itself be nested
        # ("std::abi::x86_64::Register64" is Register64 of std::abi::x86_64).
        if {[regexp {^((?:[A-Za-z_][A-Za-z0-9_]*::)*[A-Za-z_][A-Za-z0-9_]*)::([A-Za-z_][A-Za-z0-9_]*)$} $type -> namespaceName name]} {
            return [Ref $namespaceName $name $span type 0]::$name
        }
        return $type
    }
    if {[llength $type] == 3 && [lindex $type 0] eq "array"} {
        # A fixed array representation (FIXED-LAYOUT-ARRAYS.md): its
        # element's references (the extent is a number).
        return [lreplace $type 2 2 [TypeRefs [lindex $type 2] $span]]
    }
    if {[llength $type] in {3 4} && [lindex $type 0] eq "refine"} {
        # A scalar refinement (DECIMAL-ROUNDED-MILESTONE-1.md): the refined
        # name's reference (the parameters are numbers) -- of an applied
        # type, the base's references (LIST-CARDINALITY-REFINEMENTS.md).
        if {[llength $type] == 4} {
            return [lreplace $type 3 3 [TypeRefs [lindex $type 3] $span]]
        }
        return [lreplace $type 1 1 [TypeRefs [lindex $type 1] $span]]
    }
    if {[llength $type] == 3 && [lindex $type 0] eq "apply"} {
        # NAME[A, B, ...] (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): the
        # constructor's reference and every argument's.
        set head [TypeRefs [lindex $type 1] $span]
        return [list apply $head [lmap t [lindex $type 2] {TypeRefs $t $span}]]
    }
    lassign $type head arg
    if {$head eq "fn"} {
        dict set arg args [lmap t [dict get $arg args] {TypeRefs $t $span}]
        dict set arg return [TypeRefs [dict get $arg return] $span]
        dict set arg errors [lmap error [dict get $arg errors] {ErrorRef $error $span}]
        return [list $head $arg]
    }
    # A qualified type constructor (`std::ffi::c::Ptr[...]`, C-ABI-TYPES.md) is a
    # reference to its namespace too.
    set type [lreplace $type 0 0 [TypeRefs $head $span]]
    return [lreplace $type 1 1 [TypeRefs $arg $span]]
}

# ORIGIN (an hir/syntax.tcl node's or block-parameter's origin) repointed at
# FILEID: every surface-produced origin is {file F node ... }, always F=f1
# (surface/lower.tcl's Origin hard-codes f1, since ordinary single-file
# lowering never needs more than one file); this is the only place that
# changes, so a module's diagnostics and source locations still point at
# its own file, never at the file that happened to reference it.
proc surface::modules::RemapOrigin {origin fileId} {
    if {$origin eq ""} {
        return ""
    }
    dict set origin file $fileId
    return $origin
}

# DECLS (surface/lower.tcl's ExternDeclOf or LinkDeclOf dicts) with their
# origins repointed at FILEID.
proc surface::modules::RemapDecls {decls fileId} {
    return [lmap decl $decls {dict set decl origin [RemapOrigin [dict get $decl origin] $fileId]}]
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
            dict set node flags [RemapFlags [dict getdef $node flags {}] $fileId]
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
            # The clauses that carry origins: context parameters (their
            # loads are nodes at the parameter's origin), proof clauses and
            # the resume clause.
            if {[dict exists $node contextParams]} {
                dict set node contextParams [lmap c [dict get $node contextParams] {
                    lassign $c name origin type typeOrigin
                    list $name [RemapOrigin $origin $fileId] $type [RemapOrigin $typeOrigin $fileId]
                }]
            }
            if {[dict exists $node proofs]} {
                dict set node proofs [lmap clause [dict get $node proofs] {
                    dict set clause paramOrigin [RemapOrigin [dict get $clause paramOrigin] $fileId]
                    dict set clause typeOrigin [RemapOrigin [dict get $clause typeOrigin] $fileId]
                    set clause
                }]
            }
            if {[dict exists $node resume]} {
                lassign [dict get $node resume] type origin
                dict set node resume [list $type [RemapOrigin $origin $fileId]]
            }
            if {[dict exists $node variadic]} {
                dict set node variadic [RemapOrigin [dict get $node variadic] $fileId]
            }
            # paramTypes carries no origin of its own (plain type-name
            # strings, resolved later by hir/resolve.tcl): nothing to remap.
        }
        call {
            dict set node flags [RemapFlags [dict getdef $node flags {}] $fileId]
            dict set node callee [RemapFile [dict get $node callee] $fileId]
            dict set node args [lmap child [dict get $node args] {RemapFile $child $fileId}]
            if {[dict exists $node imprintOrigins]} {
                dict set node imprintOrigins [lmap o [dict get $node imprintOrigins] {RemapOrigin $o $fileId}]
            }
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
            if {[dict exists $node indices]} {
                dict set node indices [lmap index [dict get $node indices] {
                    list [lindex $index 0] [RemapOrigin [lindex $index 1] $fileId]
                }]
            }
        }
        return - ok - error {
            dict set node value [RemapFile [dict get $node value] $fileId]
        }
        break - fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                dict set node value [RemapFile [dict get $node value] $fileId]
            }
        }
        static {
            # STATIC-COMPILE.md: the site's own origins locate its body, and
            # so which diagnostics are its (hir/static.tcl).
            dict set node operationOrigin [RemapOrigin [dict get $node operationOrigin] $fileId]
            dict set node bodyOrigin [RemapOrigin [dict get $node bodyOrigin] $fileId]
            dict set node body [lmap child [dict get $node body] {RemapFile $child $fileId}]
            dict set node deferred [lmap d [dict get $node deferred] {
                dict set d origin [RemapOrigin [dict get $d origin] $fileId]
                set d
            }]
        }
    }
    return $node
}

# Loads namespace NAME (and, recursively, everything it depends on) into
# STATE if not already loaded, raising Error CYCLE if NAME is already being
# loaded (found on STATE's own "stack"). USEDATSPAN is the span of the
# reference that asked for it, for diagnostics ("" if none -- a
# non-source-driven load, e.g. the native backend's bridge).
#
# NAME is the module's canonical identity; SCOPE its owning scope and
# SPELLING its namespace as its own files spell it (ResolveModule's; for a
# caller that names a namespace directly, the standard library's or the
# application's by NAME).
proc surface::modules::LoadNamespace {stateVar name usedAtSpan {path ""} {scope ""} {spelling ""}} {
    upvar 1 $stateVar state
    if {[dict exists $state loaded $name]} {
        return
    }
    if {$name in [dict get $state stack]} {
        set chain [concat [dict get $state stack] [list $name]]
        Error CYCLE $usedAtSpan "module dependency cycle: [join $chain { -> }]"
    }
    if {$scope eq ""} {
        set scope [expr {[StandardNamespace $name] ? "#std" : ""}]
    }
    if {$spelling eq ""} {
        set spelling $name
    }
    # PATH: the file ResolveModule chose; the standard library's for the
    # compilation target by default (ModuleFile).
    if {$path eq ""} {
        set path [ModuleFile $name [dict get $state target] $usedAtSpan]
    }
    if {![surface::source::exists $path]} {
        Error UNKNOWN-NAMESPACE $usedAtSpan "unknown namespace \"$name\": no such module file $path"
    }
    # A package's module is its instance's place in the dependency tree, so
    # an installation whose directories lead back into themselves (a
    # symbolic link to an ancestor package) would be an endless chain of
    # instances: the same module of the same physical package directory
    # being loaded while it is loaded is a cycle, whatever its instance.
    set physical ""
    if {[IsPackageScope $scope]} {
        set physical [list [RealDirectory [ScopeDir $state $scope]] $spelling]
        set at [lsearch -exact [dict get $state physical] $physical]
        if {$at >= 0} {
            set chain [concat [lrange [dict get $state stack] $at end] [list $name]]
            Error CYCLE $usedAtSpan "module dependency cycle through package directories: [join $chain { -> }] (the module \"$spelling\" of the package directory [lindex $physical 0] imports itself again through an installation of that directory inside itself, a symbolic link: a package instance is its place in the dependency tree, so such a chain never ends)"
        }
    }
    dict set state scopeOf $name $scope
    dict set state spellingOf $name $spelling
    if {$scope ne "#std"} {
        # An application's or a package's module: never the standard
        # library's (CheckInternal).
        dict set state application $name 1
    } elseif {$path in [dict values [ArchModuleFiles $name]]} {
        # The target's architecture chose the file (ModuleFile).
        dict set state targetRead 1
    }
    if {[dict get $state recover]} {
        set ast [ParseModule $path state]
    } else {
        set ast [ParseModule $path]
    }
    foreach statement [dict get $ast body] {
        if {[dict get $statement kind] eq "hole"} {
            # A malformed statement (surface/recover.tcl): what it is, the
            # loader does not know either.
            continue
        }
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
        if {[dict get $statement kind] ni {function bind typedecl errordecl structdecl enumdecl traitdecl layoutdecl externfn externlib classdecl dfadecl}} {
            Error INVALID-TOPLEVEL [dict get $statement span] \
                "module \"$name\" ($path): only function definitions, immutable bindings, type declarations, struct declarations, enum declarations, layout declarations, trait declarations, error declarations, extern declarations and class and dfa declarations are allowed at module top level, found a \"[dict get $statement kind]\" statement"
        }
    }
    CheckNativeMembers $ast $name "module \"$name\" ($path)"
    dict set state stack [concat [dict get $state stack] [list $name]]
    dict lappend state physical $physical
    set fileId f[dict get $state nextFile]
    dict set state files $fileId $path
    dict incr state nextFile
    Recovered state $ast $name $fileId
    set ast [CollectAndLoad state $ast $name]
    set functionNames [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] in {typedecl errordecl structdecl enumdecl traitdecl layoutdecl externlib classdecl}} continue
        if {[dict get $statement kind] eq "dfadecl" && [dict exists $statement dfaDuplicate]} continue
        if {[dict get $statement kind] eq "hole" && [dict get $statement name] eq ""} continue
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
    # `import type NAME::Type` names; so is an error, `NAME::Error`
    # (hir/errordecls.tcl), named qualified from outside the module.
    dict set state loadedTypes $name [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "typedecl"} continue
        dict get $statement name
    }]
    # The enums it declares (ENUMS.md): nominal types of the namespace like
    # its structs, named `NAME::Enum`, importable with `import type` like its
    # types; a case is `NAME::Enum::Case` (EnumQualifier).
    dict set state loadedEnums $name [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "enumdecl"} continue
        dict get $statement name
    }]
    # The layouts it declares (BINARY-LAYOUT.md): members of the namespace
    # named `NAME::Layout` like its structs -- in a type position
    # (`LayoutStruct[NAME::Layout]`, a layout field's type) and as the layout
    # operand of a binary operation (`std::binary::parse(NAME::Layout, data)`),
    # never imported with `import type` (a layout is not a type).
    dict set state loadedLayouts $name [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "layoutdecl"} continue
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
    lassign [surface::lower::SplitTypeDecls [dict get $ast body] $name] executable decls errorDecls structDecls traitDecls \
        externDecls linkDecls
    # The namespace's intrinsic types (C-ABI-TYPES.md): std::ffi::c's C integer
    # scalars, declared for the compilation's C target as if the module
    # declared them itself.
    if {[hir::cabi::HasNamespaceTypes $name]} {
        # (Checked before the declarations are made: they need the target.)
        if {[dict get $state target] eq ""} {
            Error UNKNOWN-TARGET $usedAtSpan "namespace \"$name\" needs a C ABI target, and this host ($::tcl_platform(os) $::tcl_platform(machine)) is none of the known ones; compile with -target ([join [core::cabi::targetNames] {, }])"
        }
        dict set state targetRead 1
    }
    set intrinsic [hir::cabi::NamespaceTypeDecls $name [dict get $state target] [dict get $ast span]]
    if {$intrinsic ne ""} {
        set decls [concat $intrinsic $decls]
        dict set state loadedTypes $name [concat [lmap d $intrinsic {dict get $d name}] [dict get $state loadedTypes $name]]
    }
    dict set state typeDecls [concat [dict get $state typeDecls] $decls]
    dict set state errorDecls [concat [dict get $state errorDecls] $errorDecls]
    dict set state structDecls [concat [dict get $state structDecls] $structDecls]
    dict set state traitDecls [concat [dict get $state traitDecls] $traitDecls]
    dict set state externDecls [concat [dict get $state externDecls] [RemapDecls $externDecls $fileId]]
    dict set state linkDecls [concat [dict get $state linkDecls] [RemapDecls [LinkDecls state $linkDecls $name] $fileId]]
    set statements [lmap node [LowerStatements $state $name $executable] {RemapFile $node $fileId}]
    set origin [RemapOrigin [surface::lower::Origin [dict get $ast span] "namespace"] $fileId]
    set section [dict create namespace $name nodes $statements origin $origin \
        imports [dict get $state imports $name]]
    # The module's declaration (DIRECT-MODULES.md): `direct module`, if the
    # file is declared direct -- {direct 0|1 origin ORIGIN-OF-THE-MARKER}.
    dict set state moduleDecls $name [ModuleDecl $ast $fileId]
    dict set state sections [concat [dict get $state sections] [list $section]]
    dict set state stack [lrange [dict get $state stack] 0 end-1]
    dict set state physical [lrange [dict get $state physical] 0 end-1]
}

# The directory DIR with every symbolic link in it resolved, its last
# component's included (file normalize resolves all but the last).
proc surface::modules::RealDirectory {dir} {
    return [file dirname [file normalize [file join $dir .bot-real]]]
}

# Records, in STATE, the FileId of the file AST of module NAME ("" for the
# entry program) and what syntax recovery left unknown about it
# (surface/recover.tcl's `recovered`: its header, value and type-level names
# its malformed top-level statements may make), which CheckRef and
# BuildProgram read (SYNTAX-RECOVERY-MILESTONE-1.md).
proc surface::modules::Recovered {stateVar ast name fileId} {
    upvar 1 $stateVar state
    dict set state fileOf $name $fileId
    if {[dict exists $ast recovered]} {
        dict set state open $name [dict get $ast recovered]
    }
}

# 1 if the reference error of KIND that CheckRef found for REF ({NAMESPACE
# NAME SPAN KIND ROOTED}) in the file of module KEY depends on source nobody
# wrote (SYNTAX-RECOVERY-MILESTONE-1.md): the file's header is malformed (an
# import it may make is not known), or the member is missing from a module
# whose malformed top-level statements may declare it.
proc surface::modules::DependentReference {state key ref kind} {
    if {![dict get $state recover]} {
        return 0
    }
    if {[dict exists $state open $key] && [dict get $state open $key header]} {
        return 1
    }
    # (The module the reference's namespace denotes, by its identity.)
    set ns [IdentityOf $state $key [lindex $ref 0]]
    if {$kind eq "UNKNOWN-SYMBOL" && [dict exists $state open $ns]} {
        set open [dict get $state open $ns]
        return [expr {[dict get $open values] || [dict get $open types]}]
    }
    return 0
}

# The declaration record of the file AST (FileId FILEID) for hir::buildSyntax's
# -module-decls (DIRECT-MODULES.md): {direct 1 origin ORIGIN} when the file
# starts with `direct module` (ORIGIN the marker's), {direct 0 origin ""}
# otherwise. A namespace's directness is its declaration's: never its name,
# path or library.
#
# It also records the file's `private` declarations
# (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md): `private {CATEGORY
# {NAME {kind KIND origin ORIGIN} ...} ...}` (hir/privacy.tcl: the one fact
# every access check reads, CATEGORY its member namespace, ORIGIN its
# name's), and `declarations {CATEGORY {NAME ORIGIN ...}}`, where each of
# its type-level declarations and errors is named (what a declaration's
# PRIVATE-TYPE-ESCAPE is located at).
proc surface::modules::ModuleDecl {ast fileId} {
    set span [dict getdef $ast direct ""]
    if {$span eq ""} {
        set decl [dict create direct 0 origin ""]
    } else {
        set decl [dict create direct 1 origin [RemapOrigin [surface::lower::Origin $span "direct-module"] $fileId]]
    }
    set private [dict create]
    set declarations [dict create]
    foreach statement [dict get $ast body] {
        set kind [dict get $statement kind]
        if {$kind ni {function bind externfn hole typedecl structdecl enumdecl traitdecl layoutdecl errordecl}
                || [dict get $statement name] eq ""} {
            continue
        }
        set category [hir::privacy::Category $kind]
        set name [dict get $statement name]
        set origin [RemapOrigin [surface::lower::Origin [dict get $statement nameSpan] "declaration"] $fileId]
        if {$category ne "values" && ![dict exists $declarations $category $name]} {
            dict set declarations $category $name $origin
        }
        if {[dict getdef $statement private 0]} {
            dict set private $category $name [dict create kind $kind origin $origin]
        }
    }
    dict set decl private $private
    dict set decl declarations $declarations
    return $decl
}

# Raises PRIVATE-ACCESS at SPAN when code of unit OWN ("" for the entry
# program), the file of STATE's module KEY, may not access member NAME of
# CATEGORY of namespace NS: it is private there (hir/privacy.tcl's Denied).
# The private declaration is the diagnostic's related location.
proc surface::modules::CheckPrivate {state own ns name category span} {
    set decls [dict get $state moduleDecls]
    if {![hir::privacy::Denied $decls $ns $category $name $own]} {
        return
    }
    set entry [hir::privacy::Entry $decls $ns $category $name]
    Error PRIVATE-ACCESS $span [hir::privacy::AccessMessage $ns $name [dict get $entry kind] $own] \
        [OriginSpan $state [dict get $entry origin]]
}

# The source span of ORIGIN ({file FILEID ...}) of a file STATE loaded, or "".
proc surface::modules::OriginSpan {state origin} {
    if {[lindex $origin 0] ne "file" || ![dict exists $state files [lindex $origin 1]]} {
        return ""
    }
    set fields [lrange $origin 2 end]
    set span [dict create file [dict get $state files [lindex $origin 1]]]
    foreach key {start end line column endLine endColumn} {
        dict set span $key [dict get $fields $key]
    }
    return $span
}

# Raises DUPLICATE-NATIVE if the module AST (the file of namespace NAME) defines
# (a function or an immutable binding) a member NAME::MEMBER that is a
# compiler/runtime-provided intrinsic: a root native registered under that
# qualified name (core::native::isQualifiedNative -- std::list::at, std::str::concat,
# std::mutable_array::set, std::linux::abi::x86_64::syscall, ...). Every reference spelled
# NAME::MEMBER denotes the native (surface/lower.tcl), so such a definition
# could never be named, would silently not replace the intrinsic, and
# Botlish has no overloading for it to coexist as. The protection is per
# member, not per namespace: NAME's module may define any other member
# (stdlib/list.bot's std::list::get beside the intrinsic std::list::at). WHO describes the
# module for the message. An entry program is no namespace (NAME ""): its
# definitions are plain names, which can never be spelled with "::".
proc surface::modules::CheckNativeMembers {ast name who} {
    if {$name eq ""} {
        return
    }
    foreach statement [dict get $ast body] {
        if {[dict get $statement kind] in {function bind externfn hole} && [dict get $statement name] ne ""
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
# or a namespace of compiler-provided intrinsics (`str`, `std::linux::abi::x86_64`).
# A bare prefix of either (`std::linux::abi` of `std::linux::abi::x86_64`) is not one: namespaces are
# exact, never trees.
proc surface::modules::NamespaceExists {ns} {
    return [expr {[HasModule $ns] || [IntrinsicMembers $ns] ne ""}]
}

# 1 if SHORT cannot be bound by a type import because it already names a
# built-in type (a primitive, `Int`, `any`, a type constructor like `List`,
# or a type the compiler registers itself): a file's own type names and
# its type imports must never silently shadow, or be shadowed by, one.
proc surface::modules::IsBuiltinTypeName {short} {
    return [expr {$short in {Int any never Fn} || [dict exists $::hir::types::constructors $short]
        || [core::type::isBuiltinName $short] || [core::native::isBuiltinEnum $short]
        || [hir::traits::isIntrinsicName $short]}]
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
proc surface::modules::CheckImports {stateVar ast key} {
    upvar 1 $stateVar state
    # The file's own namespace as it spells it, and its identity (KEY).
    set own [OwnSpelling $state $key]
    set namespaces {}
    set nsSpans [dict create]
    set types [dict create]
    set typeSpans [dict create]
    set local [dict create]
    # What each namespace the file may name -- its own, and each it imports
    # -- is: its canonical identity (IdentityMap).
    set names [dict create]
    if {$own ne ""} {
        dict set names $own $key
    }
    foreach statement [dict get $ast body] {
        if {[dict get $statement kind] in {typedecl structdecl enumdecl traitdecl layoutdecl} && ![dict exists $local [dict get $statement name]]} {
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
            set found [ResolveModule state $key $ns $span]
            set path [dict get $found path]
            if {$path eq "" && [IntrinsicMembers $ns] eq ""} {
                Error UNKNOWN-NAMESPACE $span "unknown namespace \"$ns\": [NoSuchNamespace state $key $ns]"
            }
            set id [dict get $found identity]
            CheckInternal $state $key $id $span
            if {$path ne ""} {
                LoadNamespace state $id $span $path [dict get $found scope] $ns
            }
            dict set nsSpans $ns $span
            dict set names $ns $id
            lappend namespaces $id
            continue
        }
        # import type NS::Name
        set name [dict get $import name]
        set nameSpan [dict get $import nameSpan]
        set written "${ns}::$name"
        if {[dict exists $typeSpans $written]} {
            Error DUPLICATE-IMPORT [dict get $import span] "type \"$written\" is already imported (first imported at [surface::ast::location [dict get $typeSpans $written]])"
        }
        if {$ns eq $own} {
            Error SELF-IMPORT [dict get $import span] "a file of namespace \"$ns\" cannot import a type of its own namespace: its own type \"$name\" is already usable by that name"
        }
        set found [ResolveModule state $key $ns $span]
        set path [dict get $found path]
        if {$path eq "" && [IntrinsicMembers $ns] eq ""} {
            Error UNKNOWN-NAMESPACE $span "unknown namespace \"$ns\": [NoSuchNamespace state $key $ns] (in \"import type $written\")"
        }
        set id [dict get $found identity]
        set canonical "${id}::$name"
        set hasFile [expr {$path ne ""}]
        if {$hasFile} {
            LoadNamespace state $id $span $path [dict get $found scope] $ns
        }
        if {$hasFile} {
            set typeNames [concat [dict get $state loadedTypes $id] [dict get $state loadedTraits $id] [dict get $state loadedEnums $id]]
        } else {
            set typeNames {}
        }
        if {$name ni $typeNames && [dict get $state recover] && [dict exists $state open $id]
                && [dict get $state open $id types]} {
            # A type a malformed declaration of the module may be
            # (SYNTAX-RECOVERY-MILESTONE-1.md): not imported, and the file's
            # resolution diagnostics are not known (BuildProgram).
            dict set state typeKeys $key 1
            continue
        }
        if {$name ni $typeNames} {
            if {$hasFile} {
                set functions [dict get $state loaded $id]
            } else {
                set functions {}
            }
            if {$hasFile} {
                set structs [dict get $state loadedStructs $id]
            } else {
                set structs {}
            }
            if {$hasFile} {
                set errors [dict get $state loadedErrors $id]
            } else {
                set errors {}
            }
            if {$name in [hir::cabi::IntrinsicTypeNames $id]} {
                Error NOT-A-TYPE $nameSpan "\"$written\" is an intrinsic type of namespace \"$ns\", not a source-defined `type`: spell it $written after `import $ns`"
            }
            if {$name in $functions || $name in [IntrinsicMembers $id]} {
                Error NOT-A-TYPE $nameSpan "\"$written\" exists, but is not a type (it is a function or value of namespace \"$ns\"): `import type` imports source-defined types only; use it as $written after `import $ns`"
            }
            if {$name in $structs} {
                Error NOT-A-TYPE $nameSpan "\"$written\" is a struct, not a source-defined `type`: `import type` imports `type` declarations only; spell the struct $written after `import $ns`"
            }
            if {$hasFile && $name in [dict get $state loadedLayouts $id]} {
                Error NOT-A-TYPE $nameSpan "\"$written\" is a layout, not a type: `import type` imports `type` declarations only; spell the layout $written after `import $ns` (its values have the type LayoutStruct\[$written\])"
            }
            if {$name in $errors} {
                Error NOT-A-TYPE $nameSpan "\"$written\" is an error declaration, not a type"
            }
            Error UNKNOWN-SYMBOL $nameSpan "namespace \"$ns\" has no type \"$name\" (its types: [if {$typeNames eq ""} {string cat "none"} else {join [lsort $typeNames] {, }}])"
        }
        CheckPrivate $state $key $id $name types $nameSpan
        if {[dict exists $local $name]} {
            Error TYPE-IMPORT-COLLISION $nameSpan "`import type $written` binds the type name \"$name\", which this file also declares itself (at [surface::ast::location [dict get $local $name]]); an imported type never shadows or is shadowed by a local one: drop the import and spell the imported type $written (after `import $ns`)"
        }
        if {[IsBuiltinTypeName $name]} {
            Error TYPE-IMPORT-COLLISION $nameSpan "`import type $written` binds the type name \"$name\", which is a built-in type; spell the imported type $written (after `import $ns`) instead"
        }
        if {[dict exists $types $name]} {
            set other [dict get $types $name]
            Error TYPE-IMPORT-COLLISION $nameSpan "`import type $written` and `import type [dict get $typeWritten $other]` (at [surface::ast::location [dict get $typeSpans [dict get $typeWritten $other]]]) both bind the type name \"$name\"; there is no precedence and no renaming: import at most one and spell the other fully qualified (after `import $ns`)"
        }
        dict set types $name $canonical
        dict set typeWritten $canonical $written
        dict set typeSpans $written [dict get $import span]
    }
    dict set state names $key $names
    return [dict create namespaces $namespaces types $types]
}

# The namespace the file of module KEY spells as its own ("" for the entry
# program): its identity, for the application's and the standard library's
# modules, and its namespace inside its package for a package's.
proc surface::modules::OwnSpelling {state key} {
    if {$key eq ""} {
        return ""
    }
    return [dict get $state spellingOf $key]
}

# The canonical identity of the namespace SPELLED as the file of module KEY
# writes it (CheckImports' map: its own namespace and every namespace it
# imports), or SPELLED itself for any other (one the file may not name, which
# CheckRef reports, or one whose spelling is its identity).
proc surface::modules::IdentityOf {state key spelled} {
    if {[dict exists $state names $key $spelled]} {
        return [dict get $state names $key $spelled]
    }
    return $spelled
}

# Validates the imports of AST (CheckImports), and that every qualified
# reference AST makes is authorized and names a real member. The sequence per
# reference is the one the language specifies: is the reference's namespace
# the file's own, or imported *exactly* (an imported parent or child never
# counts)? If so, does that namespace have the member? A reference into a
# namespace that is not imported is MISSING-IMPORT even when the member
# exists (`std::str::concat` without `import std::str`); one into a namespace that does
# not exist at all is UNKNOWN-NAMESPACE (no import could repair it); an
# authorized reference to a member the namespace lacks is UNKNOWN-SYMBOL.
#
# Imports are the only thing that loads a module: a qualified reference never
# loads anything. KEY is the module namespace of AST ("" for an entry
# program); the file's import environment is recorded in STATE's `imports`
# under KEY, for hir::buildSyntax's -imports and the module's own section.
proc surface::modules::CollectAndLoad {stateVar ast {key ""}} {
    upvar 1 $stateVar state
    set own [OwnSpelling $state $key]
    set env [CheckImports state $ast $key]
    dict set state imports $key $env
    # The namespaces the file imports, as it writes them.
    set imported [lmap import [dict get $ast imports] {
        if {[dict get $import kind] ne "import"} continue
        dict get $import namespace
    }]
    # The file as written is what its references are checked in (CheckRef
    # speaks of the namespaces the file names); everything after the loader
    # sees its qualified spellings as the identities they denote (header,
    # "Identity"), rewritten only where one differs from its spelling -- in a
    # package that installs packages of its own, or in one installed by
    # another package.
    set written $ast
    set map [dict filter [dict get $state names $key] script {spelled id} {expr {$spelled ne $id}}]
    if {[dict size $map]} {
        set ast [RewriteQualified $ast $map]
    }
    # Declared recognizers and symbol classes (DFA-COROUTINE-MILESTONE-2.md):
    # checked once the modules the file imports are loaded, against what
    # they declare, and annotated for lowering (surface/dfa.tcl).
    set ast [ExpandDfas state $ast $key [dict get $env namespaces]]
    # STATIC-COMPILE.md: a file using a static intrinsic names the error its
    # rejected blocks complete with, std::compiler::CompilerError -- an ordinary
    # namespaced declaration, so the file imports its namespace like any
    # other (no implicit import).
    set sites [StaticSites $ast]
    set compilerNs [namespace qualifiers $::hir::static::errorName]
    if {$sites ne {} && $compilerNs ni $imported && $own ne $compilerNs} {
        set site [lindex $sites 0]
        Error MISSING-IMPORT [dict get $site staticSpan] \
            "namespace \"$compilerNs\" is not imported; add `import $compilerNs` to use `static [dict get $site operation]:` (a block it rejects completes with the error $::hir::static::errorName)"
    }
    if {![dict size $map]} {
        set written $ast
    }
    foreach ref [QualifiedRefs $written] {
        set site [StaticSiteOf $sites [lindex $ref 2]]
        if {$site eq ""} {
            # Each reference is checked on its own: every one the file may
            # not make is reported, together, once the whole program is
            # loaded (RaiseReferenceErrors, DIAGNOSTIC-RECOVERY.md).
            try {
                CheckRef state $written $key $env $imported $ref
            } trap {SURFACE MODULE} {message options} {
                if {[DependentReference $state $key $ref [lindex [dict get $options -errorcode] 2]]} {
                    # Not known to be wrong (SYNTAX-RECOVERY-MILESTONE-1.md):
                    # a value or construction is lowered as a hole, and a
                    # type or error name leaves the file's resolution
                    # diagnostics unknown (BuildProgram).
                    dict set state dependentRefs $key [dict get [lindex $ref 2] start] 1
                    if {[lindex $ref 3] in {type error}} {
                        dict set state typeKeys $key 1
                    }
                    continue
                }
                # Kept whole, its location included (Error's entry).
                dict lappend state referenceErrors {*}[dict getdef $options -diagnostics \
                    [list [dict create errorcode [dict get $options -errorcode] message $message]]]
            }
            continue
        }
        # A reference inside a static intrinsic's block: the rejection is
        # that block's, not the file's (STATIC-COMPILE.md). Only this
        # loader's own located diagnostics are deferred; anything else is
        # a failure of the compiler and propagates.
        try {
            CheckRef state $written $key $env $imported $ref
        } trap {SURFACE MODULE} {message options} {
            set span [lindex $ref 2]
            set prefix "[surface::ast::location $span]: "
            if {[string first $prefix $message] == 0} {
                set message [string range $message [string length $prefix] end]
            }
            set path [list staticDeferred $key [dict get $site id]]
            set deferred [dict getdef $state {*}$path {}]
            lappend deferred [dict create kind [lindex [dict get $options -errorcode] 2] \
                message $message span $span]
            dict set state {*}$path $deferred
        }
    }
    return $ast
}

# The file AST of module KEY (OWN its namespace, IMPORTED the namespaces it
# imports) with its `class` and `dfa` declarations analyzed
# (surface::dfa::expand), against the classes and recognizers of the modules
# loaded before it (STATE's dfaRegistry, which gains the file's own). A
# qualified class or recognizer of a namespace the file does not import is
# MISSING-IMPORT, and so is a recognizer declared in a file that does not
# import std::dfa, its protocol: reported with the file's other references.
proc surface::modules::ExpandDfas {stateVar ast own imported} {
    upvar 1 $stateVar state
    set open 0
    if {[dict get $state recover] && [dict exists $state open $own]} {
        set facts [dict get $state open $own]
        set open [expr {[dict getdef $facts values 0] || [dict getdef $facts types 0] || [dict getdef $facts functions 0]}]
    }
    set result [surface::dfa::expand [dict get $ast body] -own $own -imports $imported \
        -registry [dict get $state dfaRegistry] -open $open]
    dict set state dfaRegistry [dict get $result registry]
    dict lappend state dfaNames {*}[dict get $result facts]
    if {[dict get $result missingImport] ne ""} {
        set span [dict get $result missingImport]
        set message "namespace \"$::surface::dfa::protocolNamespace\" is not imported; add `import $::surface::dfa::protocolNamespace` to declare a recognizer (it is resumed with std::dfa::Symbol and fails with std::dfa's errors)"
        dict lappend state referenceErrors [dict create errorcode [list SURFACE MODULE MISSING-IMPORT] \
            message "[surface::ast::location $span]: $message" summary $message location $span related {}]
    }
    if {[dict get $result referenceErrors] ne {}} {
        dict lappend state referenceErrors {*}[dict get $result referenceErrors]
    }
    dict set ast body [dict get $result statements]
    return $ast
}

# The file of module KEY ("" for the entry program), for a message.
proc surface::modules::FileText {state key} {
    if {$key eq ""} {
        return "the entry program"
    }
    set scope [Scope $state $key]
    if {[IsPackageScope $scope]} {
        return "the module \"[OwnSpelling $state $key]\" of [ScopeText $state $scope]"
    }
    return "the application module \"$key\""
}

# Checks the qualified reference REF ({NAMESPACE NAME SPAN KIND}, QualifiedRefs)
# of the file AST of module KEY (as CollectAndLoad's: its identity, "" for
# the entry program; ENV its import environment, IMPORTED the namespaces it
# imports as it writes them): Error unless it is authorized and names a real
# member. The reference is checked as written, and its namespace's members
# looked up by the identity the file's name for it denotes (IdentityOf).
#
# INTERNAL-NAMESPACE: code of module OWN ("" for the entry program) names
# the internal namespace NS (core::native::declareInternalNamespace;
# HASHABLE-AND-KEYED-HASH.md, "Visibility boundary") -- an import of it or a
# qualified reference into it -- without being a standard library module.
# The standard library is the modules of namespaces under std, the files
# under core::libraryDir that are no application module (LoadNamespace
# and package modules, LoadNamespace records those); the entry program is
# never one, and no application or package module can be a standard
# namespace (RESERVED-NAMESPACE).
proc surface::modules::CheckInternal {state own ns span {member ""}} {
    if {$member ne "" && [hir::iteration::IsOperation $ns $member]
            && ($own eq "" || [dict exists $state application $own])} {
        # An operation of a collection's loop protocol (hir/iteration.tcl):
        # its positions are the representation, which only the standard
        # library may see.
        Error INTERNAL-NAMESPACE $span \
            "\"${ns}::$member\" is internal to the standard library: it is an operation of the loop protocol of a collection of \"$ns\", which only its modules may name ([FileText $state $own] is not one); iterate the collection with a loop instead"
    }
    if {![core::native::isInternalNamespace $ns]} {
        return
    }
    if {$own ne "" && ![dict exists $state application $own]} {
        return
    }
    Error INTERNAL-NAMESPACE $span \
        "namespace \"$ns\" is internal to the standard library: only its modules may import it or name its members ([FileText $state $own] is not one)"
}

proc surface::modules::CheckRef {stateVar ast key env imported ref} {
    upvar 1 $stateVar state
    variable standardRoot
    lassign $ref namespaceName symbolName span refKind rooted
    # The file's own namespace as it writes it (OwnSpelling).
    set own [OwnSpelling $state $key]
    if {$namespaceName eq $standardRoot} {
        # `std::name`: the standard library's root is reserved -- no
        # namespace, no members, and never a type of the file
        # (STD-NAMESPACE.md).
        Error UNKNOWN-NAMESPACE $span "\"$standardRoot\" is the root of the standard library, not a namespace: it has no members, and a qualifier \"$standardRoot\" never names anything else (a type of this file included); \"${standardRoot}::$symbolName\" names nothing -- a standard member is NAMESPACE::name for a namespace under it (${standardRoot}::list::at)"
    }
    # A rooted qualifier (`::game::Color::Red`) is a namespace path from the
    # root: never a type the file declares or imports by its short name.
    set typeQualifier [expr {!$rooted || [string first :: $namespaceName] >= 0}]
    if {$refKind eq "value" && $typeQualifier} {
        # `Enum::Case` (ENUMS.md): a qualifier that names an enum type
        # visible in this file makes the reference a case of it, decided
        # (and the case checked) by HIR resolution -- never a namespace
        # member, and never a reason to load anything.
        set enum [EnumQualifier state $ast $key $env $namespaceName]
        if {$enum ne ""} {
            if {$namespaceName in $imported || [NamespaceExistsFor state $key $namespaceName]} {
                # (Imported or not: `std::list::length` must never mean an
                # intrinsic in one file and a case in another because
                # of an enum's name.)
                Error AMBIGUOUS-QUALIFIER $span \
                    "\"${namespaceName}::$symbolName\" is ambiguous: \"$namespaceName\" names both a namespace and the enum type $enum visible in this file (a qualifier is never resolved by precedence; rename the enum)"
            }
            # (A private enum of another module is no case qualifier there.)
            CheckPrivate $state $key {*}[hir::privacy::Member $enum] types $span
            return
        }
    }
    if {$namespaceName eq $own && $own ne ""
            && $refKind in {value} && [core::native::isQualifiedNative "${namespaceName}::$symbolName"]} {
        # A reference to an intrinsic of the file's own namespace
        # (stdlib/list.bot's own std::list::at): no import, nothing to load.
        return
    }
    if {$namespaceName eq $own && $own ne "" && $key ne ""} {
        # Own namespace: members of the module being compiled need no
        # import (the HIR resolver checks the member is established).
        return
    }
    if {$refKind eq "struct" && $typeQualifier && [EnumQualifier state $ast $key $env $namespaceName] ne ""} {
        # `Enum::Case { ... }` (ENUMS.md): a payload-free case is a
        # value, written without an initializer.
        Error NOT-A-STRUCT $span \
            "\"${namespaceName}::$symbolName\" names a case of the enum $namespaceName, not a struct: a payload-free case is written ${namespaceName}::$symbolName, without braces (payload-bearing cases are not supported)"
    }
    CheckInternal $state $key [IdentityOf $state $key $namespaceName] $span $symbolName
    if {$namespaceName ni $imported} {
        if {$refKind eq "value" && !$rooted && ![NamespaceExistsFor state $key $namespaceName]
                && ![NamespaceExists ${standardRoot}::$namespaceName]} {
            # `Struct::Case`, `int::Case`: a case qualified by a type that
            # is not an enum (ENUMS.md). Types are not namespaces. (A
            # qualifier that is a standard namespace's name without its
            # std::, `std::list::at`, is reported as the namespace it misses.)
            set other [OtherTypeQualifier state $ast $key $env $namespaceName]
            if {$other ne ""} {
                Error NOT-AN-ENUM $span \
                    "\"$namespaceName\" is $other, not an enum: only an enum type qualifies a case (\"Enum::Case\"), and a type is not a namespace, so \"${namespaceName}::$symbolName\" names nothing"
            }
        }
        if {![NamespaceExistsFor state $key $namespaceName]} {
            set cut [string last :: $namespaceName]
            if {$refKind eq "value" && $cut > 0} {
                # `ns::Enum::Case` (ENUMS.md) whose module is not
                # imported: the import is what is missing, as for any
                # member of that module.
                set prefix [string range $namespaceName 0 [expr {$cut - 1}]]
                if {$prefix ni $imported && $prefix ne $own && [NamespaceExistsFor state $key $prefix]} {
                    Error MISSING-IMPORT $span "namespace \"$prefix\" is not imported; add `import $prefix` to use `${namespaceName}::$symbolName`"
                }
            }
            set note ""
            if {$rooted} {
                set note " (a rooted qualifier is a namespace path from the root, never a type: a case of an enum this file declares or imports is written without the leading \"::\", Enum::Case)"
            } elseif {$refKind eq "value"} {
                set note " (nor is \"$namespaceName\" an enum type visible in this file: a case is written Enum::Case)"
            }
            Error UNKNOWN-NAMESPACE $span "unknown namespace \"$namespaceName\": [NoSuchNamespace state $key $namespaceName]$note"
        }
        set note ""
        set related [RelatedImport $namespaceName $imported]
        if {$related ne ""} {
            set note " (imports are exact: `import $related` does not import \"$namespaceName\")"
        }
        Error MISSING-IMPORT $span "namespace \"$namespaceName\" is not imported; add `import $namespaceName` to use `${namespaceName}::$symbolName`$note"
    }
    # What the namespace is: its canonical identity (header, "Identity").
    set id [IdentityOf $state $key $namespaceName]
    set natives [IntrinsicMembers $id]
    if {$refKind eq "value" && [core::native::isQualifiedNative "${id}::$symbolName"]} {
        # A root native registered under a qualified name
        # (std::linux::abi::x86_64::syscall, std::str::concat): no module file defines it,
        # so nothing more is loaded (surface/lower.tcl lowers it to a
        # root reference).
        return
    }
    if {![dict exists $state loaded $id]} {
        # A namespace whose only members are intrinsics (str): there is
        # no module file (the import loaded none), so an unknown member is
        # reported against the intrinsics, not as a missing file.
        Error UNKNOWN-SYMBOL $span \
            "namespace \"$namespaceName\" has no [dict get {value definition type type struct type error error} $refKind] \"$symbolName\" (its members are the intrinsics: [join $natives {, }])"
    }
    # The import loaded the module.
    if {$refKind eq "error"} {
        # A module-qualified error (ERROR-PAYLOADS.md): one the module
        # declares itself, canonically `NAMESPACE::Name`.
        set errorNames [dict get $state loadedErrors $id]
        if {$symbolName ni $errorNames} {
            Error UNKNOWN-SYMBOL $span \
                "namespace \"$namespaceName\" has no error \"$symbolName\" (it declares: [if {$errorNames eq ""} {string cat "no errors"} else {join [lsort $errorNames] {, }}])"
        }
        CheckPrivate $state $key $id $symbolName errors $span
        return
    }
    if {$symbolName in [hir::cabi::IntrinsicTypeNames $id]} {
        # std::ffi::c::Void, std::ffi::c::Ptr, std::ffi::c::FnPtr (C-ABI-TYPES.md) and
        # std::ffi::c::Bool (C _Bool, bool itself): intrinsic types of the
        # namespace, resolved by hir/cabi.tcl -- and nothing else: no value,
        # function or construction is named so.
        if {$refKind eq "type"} {
            return
        }
        if {$refKind eq "struct" && $symbolName eq "Void"} {
            Error TYPE $span [hir::cabi::VoidMessage]
        }
        if {$refKind in {value struct} && $symbolName eq "Bool"} {
            Error UNKNOWN-SYMBOL $span \
                "${namespaceName}::Bool is a type, not a value or a function: it is C _Bool's name for Botlish's bool, whose values are true and false"
        }
        if {$refKind in {value struct}} {
            Error UNKNOWN-SYMBOL $span \
                "${namespaceName}::$symbolName is a type, not a value or a function: no pointer is made from an Int or constructed from fields (pointers come from ${namespaceName}::null\[T\](), and later from C itself)"
        }
    }
    if {$refKind in {struct type}} {
        set structNames [dict get $state loadedStructs $id]
        if {$refKind eq "type"} {
            set typeNames [concat [dict get $state loadedTypes $id] [dict get $state loadedTraits $id] [dict get $state loadedEnums $id] [dict get $state loadedLayouts $id]]
        } else {
            set typeNames {}
        }
        if {$symbolName ni $structNames && $symbolName ni $typeNames} {
            set declared [lsort [concat $structNames $typeNames]]
            Error UNKNOWN-SYMBOL $span \
                "namespace \"$namespaceName\" has no [expr {$refKind eq "type" ? "type" : "struct"}] \"$symbolName\" (it declares: [if {$declared eq ""} {string cat "no types"} else {join $declared {, }}])"
        }
        CheckPrivate $state $key $id $symbolName types $span
        return
    }
    if {$symbolName in [dict get $state loadedLayouts $id]} {
        # A layout of the module (BINARY-LAYOUT.md), written where a value
        # would be: legal only as a binary operation's layout operand,
        # which HIR resolution decides (LAYOUT-NOT-A-VALUE elsewhere).
        CheckPrivate $state $key $id $symbolName types $span
        return
    }
    set functionNames [dict get $state loaded $id]
    if {$symbolName ni $functionNames} {
        Error UNKNOWN-SYMBOL $span \
            "namespace \"$namespaceName\" has no definition \"$symbolName\" (it defines: [join [lsort [concat $functionNames $natives]] {, }])"
    }
    # The member exists; whether this code may name it is the module's
    # `private` (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md).
    CheckPrivate $state $key $id $symbolName values $span
}

# The static intrinsics of AST (STATIC-COMPILE.md), outermost first in source
# order: {id operation staticSpan bodySpan} dicts.
proc surface::modules::StaticSites {ast} {
    set sites {}
    StaticSitesWalk $ast sites
    return $sites
}

proc surface::modules::StaticSitesWalk {node sitesVar} {
    upvar 1 $sitesVar sites
    if {[dict get $node kind] eq "static"} {
        lappend sites [dict create id [dict get $node id] operation [dict get $node operation] \
            staticSpan [dict get $node staticSpan] bodySpan [dict get $node body span]]
    }
    foreach child [surface::ast::Children $node] {
        StaticSitesWalk $child sites
    }
}

# The innermost of SITES (StaticSites) whose block holds SPAN, or "".
proc surface::modules::StaticSiteOf {sites span} {
    set found ""
    set best -1
    set at [dict get $span start]
    foreach site $sites {
        set body [dict get $site bodySpan]
        if {$at >= [dict get $body start] && $at <= [dict get $body end] && [dict get $body start] > $best} {
            set found $site
            set best [dict get $body start]
        }
    }
    return $found
}

# The loader's deferred diagnostics of the static intrinsics of the file of
# module KEY ("" for the entry program): AST node id -> {kind message span}
# dicts, what surface::lower::staticDeferred holds while that file is
# lowered.
proc surface::modules::StaticDeferred {state key} {
    if {[dict exists $state staticDeferred $key]} {
        return [dict get $state staticDeferred $key]
    }
    return [dict create]
}

# The syntax nodes of the executable STATEMENTS of the file of module KEY:
# surface::lower::Sequence, with that file's deferred static diagnostics.
proc surface::modules::LowerStatements {state key statements} {
    set saved $::surface::lower::staticDeferred
    set savedDependent $::surface::lower::dependentRefs
    set ::surface::lower::staticDeferred [StaticDeferred $state $key]
    set ::surface::lower::dependentRefs [dict getdef $state dependentRefs $key {}]
    try {
        return [surface::lower::Sequence $statements]
    } finally {
        set ::surface::lower::staticDeferred $saved
        set ::surface::lower::dependentRefs $savedDependent
    }
}

# The canonical identity of the enum the type spelling QUALIFIER (the part of
# a value reference `QUALIFIER::NAME` before its last `::`) denotes in the
# file AST of module OWN ("" for the entry program), whose import
# environment is ENV, or "" if it denotes none (ENUMS.md). The visibility of
# any nominal type: a bare name the file declares itself or binds with
# `import type`, or `NS::Enum` where NS is the file's own namespace or one it
# imports exactly and NS declares Enum.
proc surface::modules::EnumQualifier {stateVar ast key env qualifier} {
    upvar 1 $stateVar state
    set own [OwnSpelling $state $key]
    if {[string first :: $qualifier] < 0} {
        foreach statement [dict get $ast body] {
            if {[dict get $statement kind] eq "enumdecl" && [dict get $statement name] eq $qualifier} {
                if {$key eq ""} {
                    return $qualifier
                }
                return "${key}::$qualifier"
            }
        }
        set types [dict get $env types]
        if {[dict exists $types $qualifier]} {
            set canonical [dict get $types $qualifier]
            set i [string last :: $canonical]
            set ns [string range $canonical 0 [expr {$i - 1}]]
            set name [string range $canonical [expr {$i + 2}] end]
            if {[dict exists $state loadedEnums $ns] && $name in [dict get $state loadedEnums $ns]} {
                return $canonical
            }
        }
        if {[core::native::isBuiltinEnum $qualifier]} {
            # A builtin enum of the runtime (NonFiniteResult), visible in
            # every file like the builtin errors.
            return $qualifier
        }
        return ""
    }
    set i [string last :: $qualifier]
    set ns [string range $qualifier 0 [expr {$i - 1}]]
    set name [string range $qualifier [expr {$i + 2}] end]
    if {$ns ne "" && $ns eq $own} {
        foreach statement [dict get $ast body] {
            if {[dict get $statement kind] eq "enumdecl" && [dict get $statement name] eq $name} {
                return "${key}::$name"
            }
        }
        return ""
    }
    set id [IdentityOf $state $key $ns]
    if {$id in [dict get $env namespaces] && [dict exists $state loadedEnums $id]
            && $name in [dict get $state loadedEnums $id]} {
        return "${id}::$name"
    }
    return ""
}

# "a struct", "a trait", "a type" or "a built-in type" when the type
# spelling QUALIFIER names a visible type of that kind that is not an enum
# (in the file AST of module OWN with import environment ENV), else "": the
# qualifier of a `QUALIFIER::NAME` value reference that is a type but cannot
# qualify a case (NOT-AN-ENUM).
proc surface::modules::OtherTypeQualifier {stateVar ast key env qualifier} {
    upvar 1 $stateVar state
    if {[string first :: $qualifier] < 0} {
        foreach statement [dict get $ast body] {
            if {[dict exists $statement name] && [dict get $statement name] eq $qualifier} {
                switch -- [dict get $statement kind] {
                    structdecl { return "a struct" }
                    traitdecl  { return "a trait" }
                    typedecl   { return "a type" }
                }
            }
        }
        if {[dict exists $env types $qualifier]} {
            return "an imported type"
        }
        if {$qualifier ne "enum" && ([IsBuiltinTypeName $qualifier] || $qualifier in {int str bool unit})} {
            # (`enum` is the internal kind of every enum value, never a
            # type a program can name: no namespace of it either.)
            return "a built-in type"
        }
        return ""
    }
    set i [string last :: $qualifier]
    set ns [string range $qualifier 0 [expr {$i - 1}]]
    set name [string range $qualifier [expr {$i + 2}] end]
    set id [IdentityOf $state $key $ns]
    if {$id in [dict get $env namespaces] && [dict exists $state loadedStructs $id]} {
        if {$name in [dict get $state loadedStructs $id]} { return "a struct" }
        if {$name in [dict get $state loadedTraits $id]} { return "a trait" }
        if {$name in [dict get $state loadedTypes $id]} { return "a type" }
    }
    return ""
}

# The initial loader state of a program whose own root file is FILES (a dict
# FileId -> path; {} for a caller with no file of its own) and whose module
# files start at FileId f(NEXTFILE): the one constructor of the state
# LoadNamespace/CollectAndLoad thread through, so every caller (this file's
# own entry points, examples/stdlib/corpus.tcl's text-based compile) carries
# every table -- loaded definitions, loaded struct types, sections and the
# three kinds of declaration -- without a copy of the list to keep in sync.
# `imports` is the dependency graph: NAMESPACE (or "" for the entry program)
# -> that file's import environment (CheckImports). Every module is keyed by
# its canonical identity (header, "Identity"): `scopeOf` and `spellingOf`
# give its owning scope and the namespace its own files spell, `names` each
# file's map from the namespaces it names to their identities, `packages`
# the package instances named so far (Instance) and `physical` the loading
# stack's package directories (LoadNamespace's cycle guard).
proc surface::modules::NewState {files nextFile} {
    return [dict create files $files nextFile $nextFile \
        loaded [dict create] loadedStructs [dict create] loadedTypes [dict create] \
        loadedErrors [dict create] loadedTraits [dict create] loadedEnums [dict create] \
        loadedLayouts [dict create] imports [dict create] stack {} sections {} \
        typeDecls {} errorDecls {} structDecls {} traitDecls {} externDecls {} linkDecls {} \
        staticDeferred [dict create] \
        target "" targetRead 0 root "" entry "" application [dict create] moduleDecls [dict create] \
        referenceErrors {} recover 0 syntaxEntries {} fileOf [dict create] open [dict create] \
        dependentRefs [dict create] typeKeys [dict create] dfaRegistry [dict create] dfaNames {} \
        scopeOf [dict create] spellingOf [dict create] packages [dict create] names [dict create] \
        physical {}]
}

# Raises the qualified references of every file STATE loaded that the file
# may not make (CollectAndLoad: MISSING-IMPORT, UNKNOWN-NAMESPACE,
# UNKNOWN-SYMBOL, ...) as one error, in loading order -- each module before
# the file that imports it, each file's in source order -- the first one's
# {SURFACE MODULE KIND} (core::raiseDiagnostics). Each is independent of the
# others: one reference never decides another. Nothing if there is none.
proc surface::modules::RaiseReferenceErrors {state} {
    if {[dict get $state referenceErrors] ne {}} {
        core::raiseDiagnostics [dict get $state referenceErrors]
    }
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
    set options [dict create -start-file 1 -target ""]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::modules::LoadNamespaces: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set state [NewState [dict create] [dict get $options -start-file]]
    dict set state target [hir::cabi::ResolveTarget [dict get $options -target]]
    foreach name $namespaces {
        LoadNamespace state $name ""
    }
    RaiseReferenceErrors $state
    return [dict create sections [dict get $state sections] files [dict get $state files] \
        functions [dict get $state loaded] typeDecls [dict get $state typeDecls] \
        errorDecls [dict get $state errorDecls] structDecls [dict get $state structDecls] \
        traitDecls [dict get $state traitDecls] imports [dict get $state imports] \
        moduleDecls [dict get $state moduleDecls] externDecls [dict get $state externDecls] \
        linkDecls [dict get $state linkDecls]]
}

# The HIR of the entry program AST (a `program` node whose file is FILE ... in
# every origin), after loading -- and compiling once, alongside it -- every
# module its imports name, transitively. Shared by compileProgramFile and by
# callers that compile source text instead of a file (examples/stdlib/
# corpus.tcl). ROOT is the program's application root (the directory of its
# entry file, application modules above), "" for none. Returns HIR before
# the frontend's finishing steps (surface::lower::Finish).
#
# RECOVER 1 analyzes past syntax errors (SYNTAX-RECOVERY-MILESTONE-1.md): AST
# is the entry's recovered AST (surface/recover.tcl), every module is parsed
# with recovery, and a program with any syntax error is built with its
# malformed source as holes, its syntax diagnostics (the entry's, then each
# module's as it is parsed) and what the holes leave unknown kept in the
# HIR's `syntaxRecovery` (hir::buildSyntax's -syntax-recovery). An error of
# the loader still ends the compilation, the syntax diagnostics first.
proc surface::modules::BuildProgram {ast strict {target ""} {root ""} {recover 0}} {
    set state [NewState [dict create f1 [dict get $ast span file]] 2]
    # The C ABI target (C-ABI-TYPES.md): the host's unless given. Only a
    # file importing std::ffi::c, or an architecture-specific module (ModuleFile),
    # reads it.
    dict set state target [hir::cabi::ResolveTarget $target]
    if {$root ne ""} {
        dict set state root [file normalize $root]
        dict set state entry [file normalize [dict get $ast span file]]
    }
    dict set state recover $recover
    if {$recover && [dict get $ast diagnostics] ne ""} {
        dict set state syntaxEntries [surface::syntaxEntries [dict get $ast diagnostics]]
    }
    Recovered state $ast "" f1
    try {
        set ast [CollectAndLoad state $ast ""]
        RaiseReferenceErrors $state
    } on error {message options} {
        if {[dict get $state syntaxEntries] eq {}
                || ([lrange [dict get $options -errorcode] 0 1] ne {SURFACE MODULE} && [lindex [dict get $options -errorcode] 0] ne "POSIX")} {
            return -options $options $message
        }
        # The syntax errors first, as a compilation without recovery
        # reports one of them first.
        core::raiseDiagnostics [concat [dict get $state syntaxEntries] [dict getdef $options -diagnostics \
            [list [dict create errorcode [dict get $options -errorcode] message $message]]]]
    }
    lassign [surface::lower::SplitTypeDecls [dict get $ast body]] executable ownDecls ownErrorDecls ownStructDecls ownTraitDecls \
        ownExternDecls ownLinkDecls
    set decls [concat [dict get $state typeDecls] $ownDecls]
    set errorDecls [concat [dict get $state errorDecls] $ownErrorDecls]
    set structDecls [concat [dict get $state structDecls] $ownStructDecls]
    set traitDecls [concat [dict get $state traitDecls] $ownTraitDecls]
    # Every unit's declaration, the entry program's ("") included: the entry
    # program is a module like any other (DIRECT-MODULES.md, "No root-module
    # special case").
    set moduleDecls [dict get $state moduleDecls]
    dict set moduleDecls "" [ModuleDecl $ast f1]
    set nodes [LowerStatements $state "" $executable]
    set sections [dict get $state sections]
    set recovery {}
    if {[dict get $state syntaxEntries] ne {}} {
        lassign [Recovery $state $nodes $sections] nodes sections recovery
    }
    # A strict compilation goes on past resolution failures: what checking
    # finds independently of them is reported with them (hir/recovery.tcl).
    set hir [hir::buildSyntax $nodes -strict 0 -syntax-recovery $recovery \
        -origin [surface::lower::Origin [dict get $ast span] ""] \
        -files [dict get $state files] -modules $sections \
        -imports [dict get $state imports] -module-decls $moduleDecls \
        -type-decls $decls -error-decls $errorDecls -struct-decls $structDecls -trait-decls $traitDecls \
        -foreign-decls [concat [dict get $state externDecls] $ownExternDecls] \
        -link-decls [concat [dict get $state linkDecls] [LinkDecls state $ownLinkDecls ""]]]
    # The target the HIR was built for, when the build read it (header,
    # "Target dependence"); "" when the HIR is every target's.
    dict set hir target [if {[dict get $state targetRead]} {dict get $state target} else {string cat ""}]
    # What the recognizer declarations' names denote, for the compiler
    # service (surface/dfa.tcl's Fact): read by no backend or analysis.
    if {[dict get $state dfaNames] ne {}} {
        dict set hir dfaNames [dict get $state dfaNames]
    }
    return $hir
}

# {NODES SECTIONS RECOVERY} for a program with syntax errors, loaded into
# STATE, whose entry program lowers to NODES and its modules to SECTIONS
# (SYNTAX-RECOVERY-MILESTONE-1.md): every static intrinsic a hole (whether a
# block compiles is a question about the whole program, which is not known),
# and hir::buildSyntax's -syntax-recovery: the syntax diagnostics, and, by
# FileId, the files whose every unit depends on what nobody wrote
# (`taintedFiles`: a malformed header), whose resolution diagnostics may
# (`typeFiles`: a type-level name a malformed declaration, a malformed header
# or a reference into a module with one may make), whose method-style calls
# may (`methodFiles`: a malformed header, or an imported module whose
# malformed statements may define functions), whose unbound names may
# (`externFiles`: an extern c fn a malformed statement may declare), and the
# files with a malformed top-level statement that may declare a function
# (`openFiles`: the implementation a trait or context trait needs,
# hir/recovery.tcl).
proc surface::modules::Recovery {state nodes sections} {
    if {[hir::static::present $nodes $sections]} {
        set decisions [dict create]
        foreach site [hir::static::Sites $nodes $sections] {
            dict set decisions [dict get $site key] unknown
        }
        lassign [hir::static::Expand $nodes $sections $decisions] nodes sections
    }
    set open [dict get $state open]
    set tainted {}
    set typeFiles {}
    set methodFiles {}
    set externFiles {}
    set openFiles {}
    dict for {key fileId} [dict get $state fileOf] {
        set facts [dict getdef $open $key {header 0 values 0 functions 0 types 0 externs 0 installs 0 holes 0}]
        set header [dict get $facts header]
        if {$header} {
            lappend tainted $fileId
        }
        if {[dict get $facts functions]} {
            # (A malformed top-level statement that may declare a function:
            # the implementation conformance reads, hir/recovery.tcl.)
            lappend openFiles $fileId
        }
        if {[dict get $facts externs]} {
            lappend externFiles $fileId
        }
        set types [expr {$header || [dict exists $state typeKeys $key] || [dict get $facts types]}]
        set methods $header
        if {[dict exists $state imports $key]} {
            foreach ns [dict get $state imports $key namespaces] {
                if {[dict exists $open $ns] && [dict get $open $ns types]} {
                    set types 1
                }
                if {[dict exists $open $ns] && [dict get $open $ns values]} {
                    # (Its functions are method candidates here: IMPORTS.md.)
                    set methods 1
                }
            }
        }
        if {$types} {
            lappend typeFiles $fileId
        }
        if {$methods} {
            lappend methodFiles $fileId
        }
    }
    return [list $nodes $sections [dict create diagnostics [dict get $state syntaxEntries] \
        taintedFiles $tainted typeFiles $typeFiles methodFiles $methodFiles externFiles $externFiles \
        openFiles $openFiles]]
}

# The HIR of the .bot program file PATH, after loading (and compiling once,
# alongside it) every module its imports name, transitively: standard
# namespaces from the standard library, and the program's own application
# modules from the directory PATH is in, its application root (above).
# -strict as surface::lowerToHir's. -target NAME is the C ABI target whose
# data model std::ffi::c's integer scalars follow (C-ABI-TYPES.md; core/cabi.tcl:
# the host's when "", the default). -cache DIR reads the HIR from the
# front-end cache in DIR when it holds this compilation's, and keeps it there
# otherwise (surface/cache.tcl; "" for none, the default
# surface::cache::directory).
#
# The program's source -- PATH's text and every module file and candidate
# path the loader asks about -- comes from the source provider in force
# (surface/source.tcl: the disk, unless the caller runs the compilation in
# a snapshot of another provider, as the compiler service does), and the
# whole compilation sees one snapshot of it.
proc surface::modules::compileProgramFile {path args} {
    set options [dict create -strict 1 -warnings [hir::warnings::defaultMode] -warning-channel stderr \
        -cache [surface::cache::directory] -target "" -recover-syntax 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::modules::compileProgramFile: unknown option \"$option\""
        }
        dict set options $option $value
    }
    return [surface::source::session [list surface::modules::CompileProgramFile $path $options]]
}

proc surface::modules::CompileProgramFile {path options} {
    set source [surface::source::text $path]
    set strict [dict get $options -strict]
    set mode [dict get $options -warnings]
    if {$mode eq ""} {
        set mode [hir::warnings::defaultMode]
    }
    set mode [hir::warnings::Mode $mode]
    set channel [dict get $options -warning-channel]
    set cache [dict get $options -cache]
    set target [hir::cabi::ResolveTarget [dict get $options -target]]
    # The application root: the entry file's own directory, wherever the
    # compilation was started from.
    set root [file dirname [file normalize $path]]
    set hir [surface::cache::lookup $cache $path $source $mode $strict $target $root]
    if {$hir ne ""} {
        return [surface::cache::Replay $hir $mode $channel]
    }
    variable reads
    variable probes
    set reads [dict create]
    set probes [dict create]
    set ast [Parse $path $source]
    set recover [dict get $options -recover-syntax]
    if {[dict get $ast diagnostics] ne ""} {
        if {!$recover} {
            surface::raiseSyntax [dict get $ast diagnostics]
        }
        set ast [surface::recover::apply $ast $source]
    }
    set hir [surface::lower::Finish [BuildProgram $ast $strict $target $root $recover] $strict $mode $channel]
    if {![dict exists $hir syntaxRecovery]} {
        # (A program with syntax errors is never kept: it is no compilation.)
        surface::cache::store $cache $path $source $mode $strict $hir $reads $target $root $probes
    }
    return $hir
}
