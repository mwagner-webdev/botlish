# lower.tcl -- surface AST to HIR.
#
#   surface::lowerToHir AST ?-strict 1|0? ?-warnings default|off|error?
#                       ?-warning-channel CHAN?       => HIR program
#
# The frontend says what was written and where; HIR says what it means.
# Lowering restates the AST as HIR syntax nodes (hir/syntax.tcl) and hands
# them to hir::buildSyntax, which does all semantic work: lexical resolution,
# binding identity, duplicate and use-before-binding checks, captures, types,
# refinements, call targets and control targets. Nothing here looks a name up.
#
# Names the frontend introduces itself (operators, list, true, false, unit)
# are root references: they denote the root binding whatever the program
# binds (hir/hygiene.tcl). A program may bind `list` without changing what
# [1, 2] means.
#
# Rules (root references marked ^):
#
#   42                    const 42
#   "text"                const str text
#   'A'                   const UnicodeChar 65        never String (see
#                         UNICODE-CHAR-LITERALS.md)
#   true / false / unit   ^true / ^false / ^unit
#   x                     ref x
#   mod::x                ref "mod::x"          module-qualified; see
#                         surface/modules.tcl for how "mod::x" is bound
#   E::C                  the same `ref "E::C"` (qualified {E C}): when E
#                         names an enum type visible here, hir::resolve makes
#                         it the case C of that enum, the constant
#                         `const enum {ID C}` (ENUMS.md); nothing here knows
#                         which qualifier is a type
#   [a, b]                call ^list a b
#   {x: a, y: b}          struct {} (x a) (y b)      written order is evaluation
#                         order; an anonymous struct value (STRUCTS.md)
#   Name {x: a, y: b}     struct Name (x a) (y b)    the same payload applied
#                         to the declared struct Name
#   e.name                project e name             a static field projection
#   f(a, b)               call f a b            (every call here is marked
#                         `written FORM`: function for this one, method,
#                         list and operator for the rules below -- how a call
#                         was spelled, for diagnostics only)
#   e.name(a, b)          call (project e name) a b, marked `method`: the
#                         method-call sugar (METHOD-SUGAR.md). Written as the
#                         field-value call it has always been (callee
#                         `e.name`) plus the marker; hir::resolve decides,
#                         from the lexical scope alone, whether `name` is a
#                         visible function and the call is `name(e, a, b)`
#   a OP b                call ^OP a b              OP: + - * == < <= > >=
#   a != b                if (call ^== a b) {^false} {^true}
#   -a                    call ^- (const 0) a
#   not a                 if a {^false} {^true}
#   a and b               if a {if b {^true} {^false}} {^false}
#   a or b                if a {^true} {if b {^true} {^false}}
#   x = e                 bind x e
#   {a, b: c} = e         bind tmp e; bind a (project tmp a); bind c (project
#                         tmp b); ^unit    struct destructuring (STRUCT-
#                         DESTRUCTURING.md): tmp is a hygienic temporary, the
#                         source is evaluated once into it, the rest is
#                         ordinary projections and bindings, and the final
#                         `^unit` is the statement's own value -- the generated
#                         bindings are implementation details and none of them
#                         is its result (Sequence splices the statements in; a
#                         nested pattern binds a further temporary)
#   fn f(a, b): body      bind f (block (a b) body...)
#   exported c fn f(a: T):  the same block marked `exported c`: a C export
#                         of a native library (NATIVE-LIBRARY-MILESTONE-1.md;
#                         hir/exports.tcl checks and lists them)
#   nomethod fn f(a, b):  the same block marked `nomethod 1`: its author
#                         declares that it is never the callee of method
#                         syntax (WARNINGS-METHOD-ELIGIBLE.md)
#   fn p(x: T) -> bool proves x: R:   the same block carrying `proofs`
#                         ({outcome true param x paramOrigin .. type R
#                         typeOrigin ..}): a proof contract, resolved and
#                         validated by hir::resolve (REFINEMENT-VALUES.md);
#                         `-> unit proves x: R` (a validator) has outcome
#                         `normal`
#   fn f(a, flags :x, :y): body   the same block carrying `flags` ({x ORIGIN}
#                         {y ORIGIN}) beside its ordinary params; flags are a
#                         separate parameter category (FLAGS.md), made
#                         Bool bindings by hir::resolve
#   fn f(a, context io: T): body   the same block carrying `contextParams`
#                         ({io ORIGIN T TYPEORIGIN}): not parameters; hir::resolve
#                         binds io at the start of the body to the installed
#                         context of T (CONTEXTS.md)
#   with context e        bind tmp e; call ^context#install (ref tmp)
#                         (CONTEXTS.md): the value, then the explicit
#                         installation of it; tmp is a hygienic temporary
#                         (context#START), Sequence splices both in
#   f(a, :x)              call f a, carrying `flags` ({x ORIGIN}): names, not
#                         expressions (FLAGS.md); a method call likewise
#   if c: t else: e       if c {t...} {e...}    inline branches; a missing
#                         else is an empty branch (value unit)
#   if c: t elif c2: t2 else: e   if c {t...} {if c2 {t2...} {e...}}
#                         nothing here: the parser already built the nested
#                         shape (an elif clause is an `if` alone in the
#                         previous clause's else suite, ELIF.md), so the `if`
#                         rule below lowers it, and the clause's own origins
#                         (the `elif` keyword through the end of the chain)
#                         come from its AST node
#   loop: body            loop {body...}        inline body
#   loop x in e: body     listloop e {x} {body...}  element binding traversal
#                         of a List (see core/ir.tcl's `listloop`)
#   loop i from a to b: body   countloop a b {i} {body...}  (also through, and
#                         down from; core/ir.tcl's `countloop`)
#   loop x in e and i from a to b: body   lockloop {domains} {body...}
#                         (lockstep; core/ir.tcl's `lockloop`)
#   yield e               call ^coroutine#yield e      (COROUTINES.md: an
#                         internal root native, typed by hir/coroutines.tcl)
#   coroutine {step: s, first: f} = g(a, b)
#                         bind coroutine#N#arg1 a; bind coroutine#N#arg2 b;
#                         bind s (call ^coroutine#create (block {} (call g
#                         (ref coroutine#N#arg1) (ref coroutine#N#arg2))));
#                         bind f (call ^coroutine#start (ref s)); ^unit
#                         -- the arguments are evaluated first, in order,
#                         into hygienic temporaries (a constant stays in
#                         place); create wraps the call in a zero-argument
#                         thunk without running it; start runs it eagerly to
#                         its first outward boundary. Handlers on the right
#                         side handle the start call. An omitted step binds
#                         the handle to the temporary coroutine#N, an
#                         omitted first discards start's value. See
#                         CoroutineBind
#   fn f(a, resume T): body   the block carrying `resume {T ORIGIN}`: the
#                         function's declared resume protocol (COROUTINES.md),
#                         not a parameter; resolved by hir::resolve
#   return / return e     return ^unit / return e
#   break / break e       break / break e
#   continue              continue
#
# `not`, `and`, `or` and `!=` are conditions, not calls: `and` and `or`
# evaluate their right operand only when needed, and every operand must be a
# Boolean (NOT-BOOLEAN otherwise), so their value is always a Boolean. As the
# condition of an `if`, the compilers lower these `if`s straight to branches
# (hir/condition.tcl, BRANCH-FORM-BOOLEAN-LOWERING.md); HIR keeps no other
# form of them.
#
# Origins: every syntax node gets {file f1 node ID start .. end .. line ..
# column .. endLine .. endColumn ..} from the AST node it comes from (ID is
# the node's structural id, ast.tcl); nodes a rule adds get the id with a
# role (ID/op for an operator's callee, ID/then for a branch it adds, ...).

namespace eval surface::lower {
    # The loader's diagnostics of the static intrinsics of the file being
    # lowered (STATIC-COMPILE.md): AST node id of a `static` node -> the
    # {kind message span} dicts of the qualified references in its body the
    # file may not make (surface/modules.tcl's CollectAndLoad), set by the
    # loader around the file's lowering. Empty for a file without any.
    variable staticDeferred [dict create]
    # The qualified references of the file being lowered whose loader error
    # depends on syntax recovery (surface/modules.tcl's DependentReference,
    # SYNTAX-RECOVERY-MILESTONE-1.md): span start -> 1. Each is lowered as a
    # hole: what it names is not known. Empty outside such a compilation.
    variable dependentRefs [dict create]
}

proc surface::lowerToHir {ast args} {
    # -target NAME: the C ABI target (C-ABI-TYPES.md), the host's when "";
    # its architecture also picks architecture-specific modules
    # (surface/modules.tcl's ModuleFile).
    # -root DIR: the application root its imports may name modules of
    # (surface/modules.tcl, "Application modules"; a program file's is its
    # directory), "" for none: program text has no file of its own.
    set options [dict create -strict 1 -warnings [hir::warnings::defaultMode] -warning-channel stderr \
        -target "" -root ""]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::lowerToHir: unknown option \"$option\""
        }
        dict set options $option $value
    }
    if {[dict get $ast kind] ne "program"} {
        error "surface::lowerToHir: expected a program node"
    }
    if {[dict exists $ast diagnostics]} {
        foreach diagnostic [dict get $ast diagnostics] {
            surface::raise $diagnostic
        }
    }
    # The same path a program file takes (surface/modules.tcl): the file's
    # imports are validated, the modules they name are loaded and compiled
    # alongside it, and a qualified reference with no import is rejected --
    # for program text exactly as for a file.
    set hir [surface::modules::BuildProgram $ast [dict get $options -strict] [dict get $options -target] \
        [dict get $options -root]]
    return [surface::lower::Finish $hir [dict get $options -strict] \
        [dict get $options -warnings] [dict get $options -warning-channel]]
}

# STATEMENTS split into {EXECUTABLE DECLS ERRORDECLS STRUCTDECLS TRAITDECLS}: EXECUTABLE keeps
# every statement with runtime meaning, in order (ready for Sequence);
# DECLS is the type declarations among them (surface/parser.tcl's
# `typedecl` nodes, `enumdecl` nodes as `kind enum` entries and `layoutdecl`
# nodes as `kind layout` entries), converted to the plain dicts hir::buildSyntax's
# -type-decls option takes (see hir/sourcetypes.tcl); ERRORDECLS likewise
# for named-error declarations (`errordecl` nodes, hir/errordecls.tcl's
# -error-decls); STRUCTDECLS likewise for struct declarations (`structdecl`
# nodes, hir/structs.tcl's -struct-decls; STRUCTS.md), TRAITDECLS for trait
# declarations (`traitdecl`, hir/traits.tcl's -trait-decls; TRAITS.md); structs,
# traits and types are
# tagged with NAMESPACE (the declaring module's, "" for the entry program):
# it makes their identity `NAMESPACE::Name` (IMPORTS.md). No kind of declaration
# is lowered to an hir/syntax.tcl node: compile-time-only metadata (spec
# items 21-22/109: no bind, no runtime value, no NIR).
proc surface::lower::SplitTypeDecls {statements {namespace ""}} {
    set executable {}
    set decls {}
    set errorDecls {}
    set structDecls {}
    set traitDecls {}
    set externDecls {}
    set linkDecls {}
    foreach statement $statements {
        switch -- [dict get $statement kind] {
            typedecl   { lappend decls [TypeDeclOf $statement $namespace] }
            enumdecl   { lappend decls [EnumDeclOf $statement $namespace] }
            layoutdecl { lappend decls [LayoutDeclOf $statement $namespace] }
            errordecl  { lappend errorDecls [ErrorDeclOf $statement $namespace] }
            structdecl { lappend structDecls [StructDeclOf $statement $namespace] }
            traitdecl  { lappend traitDecls [TraitDeclOf $statement $namespace] }
            externfn   { lappend externDecls [ExternDeclOf $statement $namespace] }
            externlib  { lappend linkDecls [LinkDeclOf $statement $namespace] }
            default    { lappend executable $statement }
        }
    }
    return [list $executable $decls $errorDecls $structDecls $traitDecls $externDecls $linkDecls]
}

# The declaration dict of an `externfn` node declared in module NAMESPACE (""
# for the entry program), for hir::buildSyntax's -foreign-decls (C-FFI.md):
# the AST's fields, with `namespace` -- the declaring module, the loader's
# canonical identity, never read from the (cached, importer-neutral) AST --
# and `origin`, the declaration's HIR origin (file f1: the loader repoints a
# module's at its own file, surface::modules::RemapDecls).
proc surface::lower::ExternDeclOf {node namespace} {
    return [dict create name [dict get $node name] nameSpan [dict get $node nameSpan] \
        namespace $namespace symbol [dict get $node symbol] symbolSpan [dict get $node symbolSpan] \
        params [dict get $node params] variadic [dict getdef $node variadic 0] \
        variadicSpan [dict getdef $node variadicSpan ""] resultType [dict get $node resultType] \
        resultTypeSpan [dict get $node resultTypeSpan] provenance [dict get $node provenance] \
        provenanceSpan [dict get $node provenanceSpan] span [dict get $node span] \
        origin [OriginOf $node]]
}

# The declaration dict of an `externlib` node declared in module NAMESPACE,
# for hir::buildSyntax's -link-decls (C-FFI.md, NATIVE-LINK-PLAN-
# MILESTONE-1.md): {link library|framework name NAME linkage default|static
# path PATH base "" namespace NS span SPAN nameSpan SPAN pathSpan SPAN
# origin ORIGIN}. BASE, the directory a relative PATH is resolved from, is
# the loader's (surface::modules::LinkDecls: the application root), never
# read from the (cached, importer-neutral) AST.
proc surface::lower::LinkDeclOf {node namespace} {
    return [dict create link [dict get $node link] name [dict get $node dependency] \
        linkage [dict get $node linkage] path [dict get $node path] base "" namespace $namespace \
        span [dict get $node span] nameSpan [dict get $node dependencySpan] pathSpan [dict get $node pathSpan] \
        origin [OriginOf $node]]
}

# The declaration dict of an `enumdecl` node declared in module NAMESPACE (""
# for the entry program): a `kind enum` entry of hir::buildSyntax's
# -type-decls (ENUMS.md; hir::sourcetypes::apply hands it to hir/enums.tcl).
# `namespace` is the loader's canonical module identity, never read from the
# (cached, importer-neutral) AST: it makes the enum's identity
# `NAMESPACE::Name`.
proc surface::lower::EnumDeclOf {node namespace} {
    return [dict create kind enum name [dict get $node name] nameSpan [dict get $node nameSpan] \
        namespace $namespace cases [dict get $node cases] span [dict get $node span]]
}

# The declaration dict of a `layoutdecl` node declared in module NAMESPACE (""
# for the entry program): a `kind layout` entry of hir::buildSyntax's
# -type-decls (BINARY-LAYOUT.md; hir::sourcetypes::apply hands it to
# hir/layouts.tcl). `namespace` is the loader's canonical module identity,
# never read from the (cached, importer-neutral) AST: it makes the layout's
# identity `NAMESPACE::Name`.
proc surface::lower::LayoutDeclOf {node namespace} {
    set decl [dict create kind layout name [dict get $node name] nameSpan [dict get $node nameSpan] \
        namespace $namespace size [dict get $node size] sizeSpan [dict get $node sizeSpan] \
        align [dict get $node align] alignSpan [dict get $node alignSpan] \
        fields [dict get $node fields] span [dict get $node span]]
    if {[dict exists $node union] && [dict get $node union]} {
        # A union layout (LAYOUT-UNIONS.md): its fields are its
        # alternatives, each at offset 0.
        dict set decl union 1
    }
    return $decl
}

# The declaration dict of a `traitdecl` node declared in module NAMESPACE (""
# for the entry program), for hir::buildSyntax's -trait-decls (TRAITS.md).
# `namespace` -- the trait's owner, the one module that defines its
# requirement set -- is the loader's canonical module identity, never read
# from the (cached, importer-neutral) AST.
proc surface::lower::TraitDeclOf {node namespace} {
    return [dict create name [dict get $node name] nameSpan [dict get $node nameSpan] \
        namespace $namespace requirements [dict get $node requirements] span [dict get $node span] \
        context [dict getdef $node context 0]]
}

# The declaration dict of a `structdecl` node declared in module NAMESPACE (""
# for the entry program). `namespace` is the representation owner of an
# opaque struct (OPAQUE-STRUCTS.md): supplied here, by the loader's canonical
# module identity, never read from the (cached, importer-neutral) AST. `opaque`
# is the declaration's own modifier.
proc surface::lower::StructDeclOf {node namespace} {
    set decl [dict create name [dict get $node name] nameSpan [dict get $node nameSpan] \
        namespace $namespace fields [dict get $node fields] span [dict get $node span] \
        opaque [dict getdef $node opaque 0] \
        context [dict getdef $node context 0]]
    if {[dict exists $node slots]} {
        # A parameterized struct's type slots (TRAIT-CONSTRAINED-IMPRINTED-
        # TYPES.md), as written: hir/structs.tcl resolves their traits.
        dict set decl slots [dict get $node slots]
    }
    if {[dict getdef $node resource 0]} {
        # A resource struct (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-
        # MILESTONE-1.md): hir/structs.tcl checks the declaration.
        dict set decl resource 1
        dict set decl resourceSpan [dict get $node resourceSpan]
    }
    return $decl
}

# The declaration dict of a `typedecl` node declared in module NAMESPACE (""
# for the entry program). `namespace` is the declaring module, supplied here
# by the loader's canonical module identity (never read from the cached,
# importer-neutral AST): for a refinement it is also the type's owner, the
# one module that may mint it (REFINEMENT-VALUES.md).
# CALL (a lowered `call` node) with the explicit imprints of the call or
# methodcall NODE that wrote it, if any (C-ABI-TYPES.md, "Imprinting").
proc surface::lower::Imprinted {call node} {
    if {![dict exists $node imprints]} {
        return $call
    }
    set origins {}
    set i 0
    foreach span [dict get $node imprintSpans] {
        lappend origins [Origin $span [dict get $node id]/imprint$i]
        incr i
    }
    return [hir::syntax::withImprint $call [dict get $node imprints] $origins]
}

proc surface::lower::TypeDeclOf {node {namespace ""}} {
    if {[dict exists $node form] && [dict get $node form] eq "refined"} {
        return [dict create kind refined \
            name [dict get $node name] nameSpan [dict get $node nameSpan] namespace $namespace \
            carrier [dict get $node carrier] carrierSpan [dict get $node carrierSpan] \
            span [dict get $node span]]
    }
    return [dict create \
        name [dict get $node name] nameSpan [dict get $node nameSpan] namespace $namespace \
        parent [dict get $node parent] parentSpan [dict get $node parentSpan] \
        domain [dict get $node domain] domainSpan [dict get $node domain span]]
}

# The declaration dict of an `errordecl` node declared in module NAMESPACE
# ("" for the entry program): its name, and its payload FIELDS
# (ERROR-PAYLOADS.md; {name nameSpan type typeSpan} dicts, empty for a
# payload-free error) with the namespace their type names resolve in. The
# error's name stays program-global (hir/errordecls.tcl); NAMESPACE only
# scopes the payload's field types, exactly as a struct's.
proc surface::lower::ErrorDeclOf {node {namespace ""}} {
    return [dict create name [dict get $node name] nameSpan [dict get $node nameSpan] \
        namespace $namespace span [dict get $node span] \
        fields [dict getdef $node fields {}]]
}

# The tail both surface::lowerToHir and surface::modules::compileProgramFile
# (surface/modules.tcl) share: with STRICT 1, raise every diagnostic the
# compilation reports (hir/recovery.tcl: the independent ones, not what
# depends on a resolution failure) as one semantic error, each with its source
# location and the first one's kind; otherwise return HIR as built,
# diagnostics and all. A program with no diagnostics then gets the
# compilation's warning policy applied (hir::warnings::run: WARNINGS is
# default, off or error, or "" for the environment's default mode; CHANNEL
# receives emitted warnings): the last thing
# the frontend does, before any backend sees the HIR.
proc surface::lower::Finish {hir strict {warnings ""} {channel stderr}} {
    if {$strict && [dict exists $hir syntaxRecovery]} {
        # A program with syntax errors analyzed past them
        # (SYNTAX-RECOVERY-MILESTONE-1.md): every syntax diagnostic, then
        # every independent semantic one.
        core::raiseDiagnostics [concat [dict get $hir syntaxRecovery diagnostics] \
            [hir::recovery::entries $hir [hir::recovery::reported $hir] 1]]
    }
    if {$strict && [hir::diagnostics $hir] ne ""} {
        hir::recovery::raise $hir [hir::recovery::reported $hir] 1
    }
    return [hir::warnings::run $hir $warnings $channel]
}

# "FILE:LINE:COLUMN" of a source ORIGIN in HIR, or the origin itself.
proc surface::originLocation {hir origin} {
    return [hir::originLocation $hir $origin]
}

# ExprIds of HIR whose origin is the AST node ID, in pre-order.
proc surface::hirExprs {hir id} {
    set result {}
    foreach e [hir::walk $hir] {
        set origin [hir::get $hir $e origin]
        if {[lindex $origin 0] eq "file" && [dict get [lrange $origin 2 end] node] eq $id} {
            lappend result $e
        }
    }
    return $result
}

# The HIR origin of source SPAN for AST node id ID.
proc surface::lower::Origin {span id} {
    return [list file f1 node $id start [dict get $span start] end [dict get $span end] \
        line [dict get $span line] column [dict get $span column] \
        endLine [dict get $span endLine] endColumn [dict get $span endColumn]]
}

proc surface::lower::OriginOf {node {role ""}} {
    set id [dict get $node id]
    if {$role ne ""} {
        set id $id/$role
    }
    return [Origin [dict get $node span] $id]
}

# The field-initializer dicts of the struct AST node NODE, in written order:
# the one payload an anonymous struct value and a named construction share.
# A field's origin is its whole initializer (name through value).
proc surface::lower::FieldInits {node} {
    set index 0
    return [lmap field [dict get $node init fields] {
        incr index
        set fieldSpan [surface::ast::cover [dict get $field nameSpan] [dict get [dict get $field value] span]]
        dict create name [dict get $field name] \
            nameOrigin [Origin [dict get $field nameSpan] [dict get $node id]/field$index/name] \
            origin [Origin $fieldSpan [dict get $node id]/field$index] \
            value [Node [dict get $field value]]
    }]
}

# The syntax nodes of the statements NODES, in order. A struct destructuring
# is the one statement that lowers to several nodes (Destructure), spliced in
# place.
proc surface::lower::Sequence {nodes} {
    set result {}
    foreach node $nodes {
        if {[dict get $node kind] eq "destructure"} {
            lappend result {*}[Destructure $node]
        } elseif {[dict get $node kind] eq "coroutinebind"} {
            lappend result {*}[CoroutineBind $node]
        } elseif {[dict get $node kind] eq "hole"} {
            lappend result {*}[Hole $node]
        } elseif {[dict get $node kind] in {dfadecl classdecl}} {
            # A declared recognizer or symbol class (DFA-COROUTINE-
            # MILESTONE-2.md): the functions it lowers to, or its
            # diagnostics (surface/dfa.tcl; the loader analyzed it).
            lappend result {*}[surface::dfa::Nodes $node]
        } elseif {[dict get $node kind] eq "with"} {
            # `with context EXPR` (CONTEXTS.md): the value bound to a hygienic
            # temporary, then the explicit installation of it (placement,
            # type, duplicates and order: hir/contexts.tcl).
            lappend result {*}[hir::syntax::contextInstallNodes [OriginOf $node] \
                "context#[dict get $node span start]" [Node [dict get $node value]]]
        } else {
            lappend result [Node $node]
        }
    }
    return $result
}

# The syntax nodes of a malformed statement (surface/recover.tcl's `hole`,
# SYNTAX-RECOVERY-MILESTONE-1.md): what its valid prefix establishes and
# nothing else. A statement that certainly binds NAME (`x = ...`, `fn x(...`)
# is the binding of NAME to a hole where its value was written; a statement
# that may bind other names, or binds none, is a hole of its own (`binds`
# says which).
proc surface::lower::Hole {node} {
    set result {}
    if {[dict get $node name] ne ""} {
        # (The binding's origin is its name, where the source declares it:
        # the malformed statement has no declaration node of its own.)
        lappend result [hir::syntax::bindNode [Origin [dict get $node nameSpan] [dict get $node id]] [dict get $node name] \
            [hir::syntax::holeNode [Origin [dict get $node valueSpan] [dict get $node id]/value] 0]]
    }
    if {[dict get $node binds] || [dict get $node name] eq "" || [dict get $node installs]} {
        lappend result [hir::syntax::holeNode [OriginOf $node] [dict get $node binds] [dict get $node installs]]
    }
    return $result
}

# Struct destructuring (STRUCT-DESTRUCTURING.md): `{a, b: c} = value` is
#
#     tmp = value           the source, evaluated here, once
#     a = tmp.a             one ordinary static projection per requested
#     c = tmp.b             field, bound under its local name
#     unit                  the statement's value
#
# in written order. The final `unit` is the destructuring's own result by rule:
# a destructuring statement introduces bindings and evaluates to unit, so where
# its value is observable (the last statement of a body, a collecting loop's
# iteration, a branch) it is unit, not the last generated binding's value (the
# last field read), which is an implementation detail. Where the value is
# discarded (a destructure followed by another statement) it is an ordinary
# discarded `unit`, which costs nothing. `tmp` is a hygienic temporary: its name contains "#", which
# source can never spell, so it cannot collide with or capture a user name, and
# no user-visible binding denotes it. A nested pattern `{u: {x, y}}` binds a
# further temporary to `tmp.u` and destructures that the same way. The result is
# plain bind / project / ref / unit syntax: HIR, its analyses, core IR and every
# backend see exactly what the explicit spelling (with its final `unit`) gives
# them (the field-access rules, including every diagnostic, are the ordinary
# projection's), and none of them knows destructuring exists.
#
# Origins: each projection and each binding carries its own field of the
# pattern -- the projection spans the entry and its name origin is the field
# name read (where UNKNOWN-FIELD, NOT-A-STRUCT and UNPROVEN-FIELD point), the
# bind's origin is the binding made (where DUPLICATE points). The final unit
# originates at the whole statement.
proc surface::lower::Destructure {node} {
    set pattern [dict get $node pattern]
    set temp [TempName $pattern]
    set source [hir::syntax::bindNode [Origin [dict get $pattern span] [dict get $node id]/pattern] \
        $temp [Node [dict get $node value]]]
    set result [hir::syntax::rootRef [OriginOf $node unit] unit]
    return [concat [list $source] [Projections $pattern $temp] [list $result]]
}

# The handler syntax dicts of handled call NODE (hir/syntax.tcl's handleNode):
# what each "on NAME" receives of the error's payload is its `payload`
# binding (ERROR-PAYLOADS.md) -- the name written in `on NAME details:`, or
# for `on NAME {a, b: c}:` the pattern's hygienic temporary, whose ordinary
# projection binds (Projections, exactly a destructuring statement's) open
# the handler body. Nothing else of a handler is payload-specific: selection
# stays the error name alone.
proc surface::lower::Handlers {node} {
    return [lmap handler [dict get $node handlers] {
        set suite [dict get $handler body]
        set body [Sequence [dict get $suite body]]
        set payload ""
        if {[dict exists $handler binding] && [dict get $handler binding] ne ""} {
            set payload [dict create name [dict get $handler binding] \
                origin [Origin [dict get $handler bindingSpan] [dict get $suite id]/payload]]
        } elseif {[dict exists $handler pattern] && [dict get $handler pattern] ne ""} {
            set pattern [dict get $handler pattern]
            set temp [TempName $pattern]
            set payload [dict create name $temp \
                origin [Origin [dict get $pattern span] [dict get $suite id]/payload]]
            set body [concat [Projections $pattern $temp] $body]
        }
        dict create name [dict get $handler name] nameSpan [dict get $handler nameSpan] \
            origin [OriginOf $suite] body $body payload $payload
    }]
}

# The hygienic temporary of the pattern PATTERN: unique per pattern in a file.
proc surface::lower::TempName {pattern} {
    return "destructure#[dict get $pattern span start]"
}

# The binds of the fields of PATTERN, each reading the struct bound to TEMP.
proc surface::lower::Projections {pattern temp} {
    set nodes {}
    foreach field [dict get $pattern fields] {
        set id [dict get $field id]
        set origin [Origin [dict get $field span] $id]
        set read [hir::syntax::projectNode $origin [hir::syntax::refNode $origin $temp] \
            [dict get $field name] [Origin [dict get $field nameSpan] $id/name]]
        if {[dict get $field nested] ne ""} {
            set inner [dict get $field nested]
            set innerTemp [TempName $inner]
            lappend nodes [hir::syntax::bindNode $origin $innerTemp $read]
            lappend nodes {*}[Projections $inner $innerTemp]
        } else {
            lappend nodes [hir::syntax::bindNode [Origin [dict get $field localSpan] $id/binding] \
                [dict get $field local] $read]
        }
    }
    return $nodes
}

# A coroutine binding (COROUTINES.md): `coroutine {step: s, first: f} =
# CALL` is
#
#     coroutine#N#arg1 = A1        each argument of CALL that is not a
#     ...                          literal, in written order (a method call's
#                                  receiver first): evaluated here, before
#                                  the coroutine exists, exactly as an
#                                  ordinary call evaluates them
#     s = coroutine#create(THUNK)  THUNK: a zero-argument block whose body is
#                                  CALL over those temporaries; nothing runs
#     f = coroutine#start(s)       the eager start: runs CALL to its first
#                                  outward boundary (yield, return or an
#                                  unhandled fail); CALL's handlers, if any,
#                                  handle this call
#     unit                         the statement's own value
#
# N is the statement's start offset, and `#` makes every temporary hygienic
# (source cannot spell it). An omitted `step` binds the handle to
# coroutine#N, an omitted `first` leaves start's value unbound. No two-field
# value is ever built. What the right side calls -- that it is a function
# that may yield, and its protocol -- is HIR's to check
# (hir/coroutines.tcl); a right side that is not a call becomes the thunk's
# whole body, which HIR rejects (COROUTINE-RHS-NOT-YIELDING).
proc surface::lower::CoroutineBind {node} {
    set origin [OriginOf $node]
    set value [dict get $node value]
    set handlers {}
    set call $value
    if {[dict get $value kind] eq "handledcall"} {
        set call [dict get $value call]
        set handlers [Handlers $value]
    }
    set n [dict get $node span start]
    set pre {}
    set index 0
    # The value of argument AST node ARG inside the thunk: the node itself for
    # a literal, else a reference to the temporary it is evaluated into here.
    set argument {{arg} {
        upvar 1 pre pre index index n n
        if {[dict get $arg kind] in {int string char bool unit}} {
            return [surface::lower::Node $arg]
        }
        incr index
        set temp "coroutine#$n#arg$index"
        set argOrigin [surface::lower::OriginOf $arg]
        lappend pre [hir::syntax::bindNode $argOrigin $temp [surface::lower::Node $arg]]
        return [hir::syntax::refNode $argOrigin $temp]
    }}
    switch -- [dict get $call kind] {
        call {
            set callee [Node [dict get $call callee]]
            set args [lmap arg [dict get $call args] {apply $argument $arg}]
            set inner [hir::syntax::withFlags [hir::syntax::callNode [OriginOf $call] $callee {*}$args] \
                [Flags $call]]
        }
        methodcall {
            set receiver [apply $argument [dict get $call receiver]]
            set args [lmap arg [dict get $call args] {apply $argument $arg}]
            set inner [hir::syntax::withFlags [hir::syntax::methodCallNode [OriginOf $call] $receiver \
                [dict get $call name] [Origin [dict get $call nameSpan] [dict get $call id]/method] \
                {*}$args] [Flags $call]]
        }
        default {
            set inner [Node $call]
        }
    }
    set thunk [hir::syntax::blockNode [OriginOf $node thunk] {} [list $inner]]
    set step ""
    set first ""
    foreach field [dict get $node pattern fields] {
        set fieldOrigin [Origin [dict get $field localSpan] [dict get $field id]/binding]
        dict set field origin $fieldOrigin
        set [dict get $field name] $field
    }
    if {$step ne ""} {
        set handle [dict get $step local]
        set handleOrigin [dict get $step origin]
    } else {
        set handle "coroutine#$n"
        set handleOrigin $origin
    }
    set create [hir::syntax::bindNode $handleOrigin $handle \
        [hir::syntax::callNode $origin [hir::syntax::rootRef $origin [core::coroutines::createNative]] $thunk]]
    set start [hir::syntax::callNode $origin [hir::syntax::rootRef $origin [core::coroutines::startNative]] \
        [hir::syntax::refNode $origin $handle]]
    if {$handlers ne {}} {
        set start [hir::syntax::handleNode [OriginOf $value] $start $handlers]
    }
    if {$first ne ""} {
        set start [hir::syntax::bindNode [dict get $first origin] [dict get $first local] $start]
    }
    return [concat $pre [list $create $start [hir::syntax::rootRef [OriginOf $node unit] unit]]]
}

# The {NAME ORIGIN} flag pairs of the function declaration or call AST node
# NODE (FLAGS.md), in written order, each originating at its ":name" spelling.
# A function's flags are its declared flag section; a call's are the flags it
# supplies. Flags have no expression of their own: nothing is evaluated.
proc surface::lower::Flags {node} {
    return [lmap flag [dict get $node flags] {
        set name [dict get $flag name]
        list $name [Origin [dict get $flag span] "[dict get $node id]/flag($name)"]
    }]
}

# if CONDITION {THEN...} {ELSE...}, with branches originating at ORIGIN.
proc surface::lower::Branch {origin condition then else} {
    return [hir::syntax::ifNode $origin $condition $origin $then $origin $else]
}

# A Boolean constant as a root reference.
proc surface::lower::Bool {origin value} {
    return [hir::syntax::rootRef $origin $value]
}

# Literal typing (FLOAT64-MILESTONE-1.md): the `const` literal {TYPE TEXT} a
# decimal literal spelling the exact decimal number DECIMAL (the lexer's
# DECIMAL token value) denotes, or a Tcl error (BOTLISH LITERAL) saying why it
# denotes no value. The one place the type of a decimal literal is decided --
# the parser asks it too, to reject a literal where it is written -- so a
# later rule (a decimal type, a type taken from context) changes this
# procedure, not the lexer, the parser or the syntax tree, which keep the
# exact decimal. Today's rule: a decimal literal is the Float64 nearest its
# decimal number (ties to even); one whose magnitude rounds beyond Float64's
# largest finite number is no value (a number too small to be distinguished
# from zero rounds to zero, like any result). The const node keeps the exact
# decimal (Node's `decimal` case): a decimal constant expression where a
# DecimalRounded type is expected is made a DecimalRounded one from it
# during type inference, the one later decision (hir/decimal.tcl,
# DECIMAL-ROUNDED-MILESTONE-1.md). The range check applies to such a literal
# too: no available representation of either type holds a number beyond
# binary64's range.
proc surface::lower::DecimalConstant {decimal} {
    set made [core::float::Parse Float64 $decimal]
    if {[lindex $made 0] ne "ok"} {
        return -code error -errorcode {BOTLISH LITERAL} \
            "the decimal literal $decimal is outside the range of Float64 (its largest finite number is [core::float::text [core::float::largest Float64]])"
    }
    return [list Float64 [core::float::text [lindex $made 1]]]
}

# The syntax node of AST NODE.
proc surface::lower::Node {node} {
    set origin [OriginOf $node]
    switch -- [dict get $node kind] {
        int {
            return [hir::syntax::constNode $origin [dict get $node text]]
        }
        string {
            return [hir::syntax::constNode $origin str [dict get $node value]]
        }
        char {
            return [hir::syntax::constNode $origin UnicodeChar [dict get $node text]]
        }
        decimal {
            # The Float64 DecimalConstant decides, carrying the exact decimal
            # the literal spells: where a DecimalRounded type is expected,
            # the front end makes the literal that decimal instead
            # (hir/decimal.tcl, DECIMAL-ROUNDED-MILESTONE-1.md).
            return [hir::syntax::withDecimal \
                [hir::syntax::constNode $origin {*}[DecimalConstant [dict get $node text]]] \
                [dict get $node text]]
        }
        bool {
            return [hir::syntax::rootRef $origin [dict get $node value]]
        }
        unit {
            return [hir::syntax::rootRef $origin unit]
        }
        name {
            return [hir::syntax::refNode $origin [dict get $node name]]
        }
        qualname {
            # A module-qualified reference: not an ordinary lexical name at
            # all (see hir/resolve.tcl's ResolveQualifiedRef, which reads
            # the extra `qualified` field below directly rather than
            # walking scopes) -- it resolves straight to NAMESPACE's own
            # module section scope (surface/modules.tcl), immune to
            # any local binding named NAMESPACE or NAME. The "NAMESPACE::
            # NAME" spelling is kept as the node's ordinary `name` too,
            # purely for display (hir::format, diagnostics): no local
            # binding can ever spell "::", so it is never ambiguous with an
            # ordinary reference even where shown together.
            set qualifiedName "[dict get $node namespace]::[dict get $node name]"
            if {[dict exists $::surface::lower::dependentRefs [dict get $node span start]]} {
                return [hir::syntax::holeNode $origin 0]
            }
            if {[core::native::isQualifiedNative $qualifiedName]} {
                # A root native whose registered name is itself qualified
                # (std::linux::abi::x86_64::syscall, core/linuxabi.tcl): a root
                # reference, exactly like a bare `argv` -- there is no
                # module file behind it (surface/modules.tcl's
                # CollectAndLoad skips it the same way), and since no local
                # binding can spell "::" it can never be shadowed.
                return [hir::syntax::rootRef $origin $qualifiedName]
            }
            set ref [hir::syntax::refNode $origin $qualifiedName]
            dict set ref qualified [list [dict get $node namespace] [dict get $node name]]
            return $ref
        }
        list {
            return [hir::syntax::withWritten [hir::syntax::callNode $origin \
                [hir::syntax::rootRef [OriginOf $node list] list] \
                {*}[Sequence [dict get $node items]]] list]
        }
        call {
            return [Imprinted [hir::syntax::withFlags [hir::syntax::withWritten [hir::syntax::callNode $origin \
                [Node [dict get $node callee]] {*}[Sequence [dict get $node args]]] function] [Flags $node]] $node]
        }
        methodcall {
            return [Imprinted [hir::syntax::withFlags [hir::syntax::methodCallNode $origin [Node [dict get $node receiver]] \
                [dict get $node name] [Origin [dict get $node nameSpan] [dict get $node id]/method] \
                {*}[Sequence [dict get $node args]]] [Flags $node]] $node]
        }
        anonstruct {
            return [hir::syntax::structNode $origin "" [FieldInits $node]]
        }
        namedstruct {
            if {[dict get $node namespace] ne ""
                    && [dict exists $::surface::lower::dependentRefs [dict get $node nameSpan start]]} {
                # (A construction of a type nobody can say exists:
                # dependentRefs, above.)
                return [hir::syntax::holeNode $origin 0]
            }
            set type [dict create name [dict get $node name] namespace [dict get $node namespace] \
                origin [Origin [dict get $node nameSpan] [dict get $node id]/type]]
            if {[dict exists $node typeArg]} {
                # NAME[TYPE] { ... } (BINARY-LAYOUT.md): the construction of
                # an applied type, its argument as written (resolved by
                # hir/resolve.tcl's ResolveStruct).
                dict set type typeArg [dict get $node typeArg]
                dict set type typeArgOrigin [Origin [dict get $node typeArgSpan] [dict get $node id]/typearg]
            }
            if {[dict exists $node typeArgs]} {
                # NAME[A, B, ...] { ... }: a parameterized struct's
                # construction (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md), one
                # argument per slot, as written.
                dict set type typeArgs [dict get $node typeArgs]
                set i 0
                dict set type typeArgOrigins [lmap span [dict get $node typeArgSpans] {
                    Origin $span [dict get $node id]/typearg[incr i]
                }]
            }
            return [hir::syntax::structNode $origin $type [FieldInits $node]]
        }
        project {
            set project [hir::syntax::projectNode $origin [Node [dict get $node receiver]] \
                [dict get $node name] [Origin [dict get $node nameSpan] [dict get $node id]/field]]
            if {[dict exists $node indices]} {
                # Static element indices (FIXED-LAYOUT-ARRAYS.md), each with
                # its origin: a layout field designator's (hir/resolve.tcl).
                set i 0
                dict set project indices [lmap index [dict get $node indices] {
                    set origin [Origin [dict get $index span] [dict get $node id]/index[incr i]]
                    list [dict get $index value] $origin
                }]
            }
            return $project
        }
        binary {
            set op [dict get $node op]
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            if {$op eq "!="} {
                set equal [hir::syntax::withOperator [hir::syntax::withWritten [hir::syntax::callNode $origin \
                    [hir::syntax::rootRef $opOrigin ==] \
                    [Node [dict get $node left]] [Node [dict get $node right]]] operator] ==]
                return [Branch $origin $equal [list [Bool $opOrigin false]] [list [Bool $opOrigin true]]]
            }
            set call [hir::syntax::withWritten [hir::syntax::callNode $origin [hir::syntax::rootRef $opOrigin $op] \
                [Node [dict get $node left]] [Node [dict get $node right]]] operator]
            # An operator: its operands' static types select the operation
            # (hir/operators.tcl). `==` is the language's one equality
            # unless a DecimalRounded operand selects DecimalRounded's
            # (hir/decimal.tcl).
            return [hir::syntax::withOperator $call $op]
        }
        unary {
            # -X is 0 - X for an Int; a floating-point operand selects its
            # type's negation instead (hir/operators.tcl), and the 0 goes.
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            return [hir::syntax::withOperator [hir::syntax::withWritten [hir::syntax::callNode $origin \
                [hir::syntax::rootRef $opOrigin -] \
                [hir::syntax::constNode $opOrigin 0] [Node [dict get $node operand]]] operator] neg]
        }
        not {
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            return [Branch $origin [Node [dict get $node operand]] \
                [list [Bool $opOrigin false]] [list [Bool $opOrigin true]]]
        }
        logical {
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            set right [dict get $node right]
            set rightOrigin [OriginOf $right test]
            set test [Branch $rightOrigin [Node $right] \
                [list [Bool $rightOrigin true]] [list [Bool $rightOrigin false]]]
            if {[dict get $node op] eq "and"} {
                return [Branch $origin [Node [dict get $node left]] \
                    [list $test] [list [Bool $opOrigin false]]]
            }
            return [Branch $origin [Node [dict get $node left]] \
                [list [Bool $opOrigin true]] [list $test]]
        }
        bind {
            return [hir::syntax::bindNode $origin [dict get $node name] \
                [Node [dict get $node value]]]
        }
        function {
            set params [lmap param [dict get $node params] {
                lassign $param name span
                list $name [Origin $span "[dict get $node id]/($name)"]
            }]
            set paramTypes [lmap param [dict get $node params] {lindex $param 2}]
            set variadic [dict getdef $node variadic ""]
            if {$variadic ne ""} {
                # The variadic parameter (VARIADICS-VERTICAL-SLICE-1.md) is
                # the block's last ordinary parameter, bound to a List: each
                # call collects its trailing arguments into one
                # (hir/variadic.tcl), so the body and every backend see an
                # ordinary List parameter.
                set name [dict get $variadic name]
                lappend params [list $name [Origin [dict get $variadic nameSpan] "[dict get $node id]/($name)"]]
                lappend paramTypes [dict get $variadic type]
            }
            set errors [lmap pair [dict get $node errors] {
                lassign $pair errName errSpan
                list $errName [Origin $errSpan "[dict get $node id]/errors($errName)"]
            }]
            set block [hir::syntax::blockNode \
                [Origin [dict get $node paramsSpan] [dict get $node id]/block] \
                $params [Sequence [dict get $node body body]] [dict get $node resultType] $paramTypes $errors \
                [Flags $node]]
            if {[dict exists $node nomethod] && [dict get $node nomethod]} {
                set block [hir::syntax::withNoMethod $block]
            }
            if {[dict getdef $node cleanup 0]} {
                set block [hir::syntax::withCleanup $block]
            }
            if {[dict getdef $node exported ""] ne ""} {
                set block [hir::syntax::withExported $block [dict get $node exported]]
            }
            if {$variadic ne ""} {
                set block [hir::syntax::withVariadic $block \
                    [Origin [dict get $variadic span] "[dict get $node id]/variadic"]]
            }
            # Place parameters (PLACE-PARAMETERS.md): each one's index and its
            # marker's origin.
            set places {}
            set index -1
            foreach param [dict get $node params] {
                incr index
                if {[llength $param] > 4} {
                    lappend places $index [Origin [lindex $param 4] "[dict get $node id]/place([lindex $param 0])"]
                }
            }
            if {$places ne {}} {
                set block [hir::syntax::withPlaces $block $places]
            }
            if {[dict exists $node proves] && [dict get $node proves] ne {}} {
                set block [hir::syntax::withProofs $block [lmap clause [dict get $node proves] {
                    set param [dict get $clause param]
                    dict create outcome [dict get $clause outcome] param $param \
                        paramOrigin [Origin [dict get $clause paramSpan] "[dict get $node id]/proves($param)"] \
                        type [dict get $clause type] \
                        typeOrigin [Origin [dict get $clause typeSpan] "[dict get $node id]/proves($param)/type"]
                }]]
            }
            if {[dict exists $node resume] && [dict get $node resume] ne ""} {
                set block [hir::syntax::withResume $block [dict get $node resume type] \
                    [Origin [dict get $node resume typeSpan] "[dict get $node id]/resume"]]
            }
            if {[dict exists $node contexts]} {
                set block [hir::syntax::withContextParams $block [lmap c [dict get $node contexts] {
                    set name [dict get $c name]
                    list $name [Origin [dict get $c nameSpan] "[dict get $node id]/context($name)"] \
                        [dict get $c type] [Origin [dict get $c typeSpan] "[dict get $node id]/context($name)/type"]
                }]]
            }
            return [hir::syntax::bindNode $origin [dict get $node name] $block]
        }
        if {
            set then [dict get $node then]
            set else [dict get $node else]
            if {$else eq ""} {
                set elseOrigin [Origin [surface::ast::endOf [dict get $node span]] [dict get $node id]/else]
                set elseBody {}
            } else {
                set elseOrigin [OriginOf $else]
                set elseBody [Sequence [dict get $else body]]
            }
            return [hir::syntax::ifNode $origin [Node [dict get $node condition]] \
                [OriginOf $then] [Sequence [dict get $then body]] $elseOrigin $elseBody]
        }
        loop {
            set body [dict get $node body]
            if {[llength [dict get $node clauses]] > 1} {
                set domains {}
                foreach clause [dict get $node clauses] {
                    set name [dict get $clause name]
                    set nameOrigin [Origin [dict get $clause nameSpan] "[dict get $node id]/($name)"]
                    if {[dict get $clause kind] eq "list"} {
                        lappend domains [dict create kind list name $name origin $nameOrigin \
                            iterable [Node [dict get $clause iterable]]]
                    } else {
                        lappend domains [dict create kind count name $name origin $nameOrigin \
                            start [Node [dict get $clause start]] end [Node [dict get $clause end]] \
                            direction [dict get $clause direction] endKind [dict get $clause endKind]]
                    }
                }
                return [hir::syntax::lockLoopNode $origin $domains \
                    [Origin [dict get $body span] [dict get $body id]/body] \
                    [Sequence [dict get $body body]]]
            }
            if {[dict get $node iterable] ne ""} {
                return [hir::syntax::listLoopNode $origin \
                    [Node [dict get $node iterable]] \
                    [dict get $node elementName] \
                    [Origin [dict get $node elementNameSpan] "[dict get $node id]/([dict get $node elementName])"] \
                    [Origin [dict get $body span] [dict get $body id]/body] \
                    [Sequence [dict get $body body]]]
            }
            if {[dict get $node countStart] ne ""} {
                return [hir::syntax::countLoopNode $origin \
                    [Node [dict get $node countStart]] \
                    [Node [dict get $node countEnd]] \
                    [dict get $node countName] \
                    [Origin [dict get $node countNameSpan] "[dict get $node id]/([dict get $node countName])"] \
                    [Origin [dict get $body span] [dict get $body id]/body] \
                    [Sequence [dict get $body body]] \
                    [dict get $node direction] [dict get $node endKind]]
            }
            return [hir::syntax::loopNode $origin \
                [Origin [dict get $body span] [dict get $body id]/body] \
                [Sequence [dict get $body body]]]
        }
        return {
            if {[dict get $node value] eq ""} {
                return [hir::syntax::returnNode $origin [hir::syntax::rootRef $origin unit]]
            }
            return [hir::syntax::returnNode $origin [Node [dict get $node value]]]
        }
        break {
            # PAYLOAD-FREE-BREAK.md: the parser guarantees value is always
            # "" here -- break's own Simple case (surface/parser.tcl)
            # rejects any value at parse time, in every loop kind, so this
            # never has anything else to lower.
            return [hir::syntax::breakNode $origin]
        }
        continue {
            return [hir::syntax::continueNode $origin]
        }
        fail {
            # ERROR-PAYLOADS.md: a payload is the struct construction of its
            # field initializers, checked (hir/resolve.tcl, hir/range.tcl)
            # against the error's declared payload -- PAYLOADOF -- exactly as
            # a named construction is against its declaration.
            set payload ""
            if {[dict exists $node payload] && [dict get $node payload] ne ""} {
                set init [dict get $node payload]
                set payload [hir::syntax::structNode [OriginOf $init] "" [FieldInits $init]]
                dict set payload payloadOf [dict get $node name]
            }
            return [hir::syntax::failNode $origin [dict get $node name] $payload]
        }
        yield {
            return [hir::syntax::callNode $origin \
                [hir::syntax::rootRef $origin [core::coroutines::yieldNative]] [Node [dict get $node value]]]
        }
        handledcall {
            return [hir::syntax::handleNode $origin [Node [dict get $node call]] [Handlers $node]]
        }
        static {
            # `static compile:` (STATIC-COMPILE.md): the captured block stays
            # syntax -- the same nodes it would lower to anywhere, with their
            # own origins -- under a `static` node that hir/static.tcl
            # replaces by its decided form before resolution.
            variable staticDeferred
            set body [dict get $node body]
            set deferred {}
            if {[dict exists $staticDeferred [dict get $node id]]} {
                set deferred [lmap d [dict get $staticDeferred [dict get $node id]] {
                    dict create kind [dict get $d kind] message [dict get $d message] \
                        origin [Origin [dict get $d span] [dict get $node id]/deferred]
                }]
            }
            return [hir::syntax::staticNode $origin [dict get $node operation] \
                [Origin [dict get $node operationSpan] [dict get $node id]/operation] \
                [Origin [dict get $body span] [dict get $body id]/body] \
                [Sequence [dict get $body body]] $deferred]
        }
    }
    error "surface::lowerToHir: cannot lower a \"[dict get $node kind]\" node"
}
