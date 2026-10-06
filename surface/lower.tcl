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
#   nomethod fn f(a, b):  the same block marked `nomethod 1`: its author
#                         declares that it is never the callee of method
#                         syntax (WARNINGS-METHOD-ELIGIBLE.md)
#   fn p(x: T) -> bool proves x: R:   the same block carrying `proofs`
#                         ({outcome true param x paramOrigin .. type R
#                         typeOrigin ..}): a proof contract, resolved and
#                         validated by hir::resolve (REFINEMENT-VALUES.md)
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
#   return / return e     return ^unit / return e
#   break / break e       break / break e
#   continue              continue
#
# `not`, `and`, `or` and `!=` are conditions, not calls: `and` and `or`
# evaluate their right operand only when needed, and every operand must be a
# Boolean (NOT-BOOLEAN otherwise), so their value is always a Boolean.
#
# Origins: every syntax node gets {file f1 node ID start .. end .. line ..
# column .. endLine .. endColumn ..} from the AST node it comes from (ID is
# the node's structural id, ast.tcl); nodes a rule adds get the id with a
# role (ID/op for an operator's callee, ID/then for a branch it adds, ...).

namespace eval surface::lower {}

proc surface::lowerToHir {ast args} {
    set options [dict create -strict 1 -warnings [hir::warnings::defaultMode] -warning-channel stderr]
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
    set hir [surface::modules::BuildProgram $ast [dict get $options -strict]]
    return [surface::lower::Finish $hir [dict get $options -strict] \
        [dict get $options -warnings] [dict get $options -warning-channel]]
}

# STATEMENTS split into {EXECUTABLE DECLS ERRORDECLS STRUCTDECLS}: EXECUTABLE keeps
# every statement with runtime meaning, in order (ready for Sequence);
# DECLS is the type declarations among them (surface/parser.tcl's
# `typedecl` nodes), converted to the plain dicts hir::buildSyntax's
# -type-decls option takes (see hir/sourcetypes.tcl); ERRORDECLS likewise
# for named-error declarations (`errordecl` nodes, hir/errordecls.tcl's
# -error-decls); STRUCTDECLS likewise for struct declarations (`structdecl`
# nodes, hir/structs.tcl's -struct-decls; STRUCTS.md); structs and types are
# tagged with NAMESPACE (the declaring module's, "" for the entry program):
# it makes their identity `NAMESPACE::Name` (IMPORTS.md). No kind of declaration
# is lowered to an hir/syntax.tcl node: compile-time-only metadata (spec
# items 21-22/109: no bind, no runtime value, no NIR).
proc surface::lower::SplitTypeDecls {statements {namespace ""}} {
    set executable {}
    set decls {}
    set errorDecls {}
    set structDecls {}
    foreach statement $statements {
        switch -- [dict get $statement kind] {
            typedecl   { lappend decls [TypeDeclOf $statement $namespace] }
            errordecl  { lappend errorDecls [ErrorDeclOf $statement] }
            structdecl { lappend structDecls [StructDeclOf $statement $namespace] }
            default    { lappend executable $statement }
        }
    }
    return [list $executable $decls $errorDecls $structDecls]
}

# The declaration dict of a `structdecl` node declared in module NAMESPACE (""
# for the entry program). `namespace` is the representation owner of an
# opaque struct (OPAQUE-STRUCTS.md): supplied here, by the loader's canonical
# module identity, never read from the (cached, importer-neutral) AST. `opaque`
# is the declaration's own modifier.
proc surface::lower::StructDeclOf {node namespace} {
    return [dict create name [dict get $node name] nameSpan [dict get $node nameSpan] \
        namespace $namespace fields [dict get $node fields] span [dict get $node span] \
        opaque [expr {[dict exists $node opaque] ? [dict get $node opaque] : 0}] \
        context [expr {[dict exists $node context] ? [dict get $node context] : 0}]]
}

# The declaration dict of a `typedecl` node declared in module NAMESPACE (""
# for the entry program). `namespace` is the declaring module, supplied here
# by the loader's canonical module identity (never read from the cached,
# importer-neutral AST): for a refinement it is also the type's owner, the
# one module that may mint it (REFINEMENT-VALUES.md).
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

proc surface::lower::ErrorDeclOf {node} {
    return [dict create name [dict get $node name] nameSpan [dict get $node nameSpan]]
}

# The tail both surface::lowerToHir and surface::modules::compileProgramFile
# (surface/modules.tcl) share: with STRICT 1, raise the first HIR diagnostic
# as a semantic error (with its source location); otherwise return HIR as
# built, diagnostics and all. A program with no diagnostics then gets the
# compilation's warning policy applied (hir::warnings::run: WARNINGS is
# default, off or error, or "" for the environment's default mode; CHANNEL
# receives emitted warnings): the last thing
# the frontend does, before any backend sees the HIR.
proc surface::lower::Finish {hir strict {warnings ""} {channel stderr}} {
    if {$strict} {
        foreach diagnostic [hir::diagnostics $hir] {
            set origin [expr {[dict exists $diagnostic origin] ? [dict get $diagnostic origin]
                : [hir::get $hir [dict get $diagnostic expr] origin]}]
            core::semanticError [dict get $diagnostic kind] \
                "[surface::originLocation $hir $origin]: [dict get $diagnostic message]"
        }
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
            if {[core::native::isQualifiedNative $qualifiedName]} {
                # A root native whose registered name is itself qualified
                # (linux::abi::syscall, core/linuxabi.tcl): a root
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
            return [hir::syntax::withFlags [hir::syntax::withWritten [hir::syntax::callNode $origin \
                [Node [dict get $node callee]] {*}[Sequence [dict get $node args]]] function] [Flags $node]]
        }
        methodcall {
            return [hir::syntax::withFlags [hir::syntax::methodCallNode $origin [Node [dict get $node receiver]] \
                [dict get $node name] [Origin [dict get $node nameSpan] [dict get $node id]/method] \
                {*}[Sequence [dict get $node args]]] [Flags $node]]
        }
        anonstruct {
            return [hir::syntax::structNode $origin "" [FieldInits $node]]
        }
        namedstruct {
            set type [dict create name [dict get $node name] namespace [dict get $node namespace] \
                origin [Origin [dict get $node nameSpan] [dict get $node id]/type]]
            return [hir::syntax::structNode $origin $type [FieldInits $node]]
        }
        project {
            return [hir::syntax::projectNode $origin [Node [dict get $node receiver]] \
                [dict get $node name] [Origin [dict get $node nameSpan] [dict get $node id]/field]]
        }
        binary {
            set op [dict get $node op]
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            if {$op eq "!="} {
                set equal [hir::syntax::withWritten [hir::syntax::callNode $origin \
                    [hir::syntax::rootRef $opOrigin ==] \
                    [Node [dict get $node left]] [Node [dict get $node right]]] operator]
                return [Branch $origin $equal [list [Bool $opOrigin false]] [list [Bool $opOrigin true]]]
            }
            return [hir::syntax::withWritten [hir::syntax::callNode $origin [hir::syntax::rootRef $opOrigin $op] \
                [Node [dict get $node left]] [Node [dict get $node right]]] operator]
        }
        unary {
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            return [hir::syntax::withWritten [hir::syntax::callNode $origin [hir::syntax::rootRef $opOrigin -] \
                [hir::syntax::constNode $opOrigin 0] [Node [dict get $node operand]]] operator]
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
            if {[dict exists $node proves] && [dict get $node proves] ne {}} {
                set block [hir::syntax::withProofs $block [lmap clause [dict get $node proves] {
                    set param [dict get $clause param]
                    dict create outcome [dict get $clause outcome] param $param \
                        paramOrigin [Origin [dict get $clause paramSpan] "[dict get $node id]/proves($param)"] \
                        type [dict get $clause type] \
                        typeOrigin [Origin [dict get $clause typeSpan] "[dict get $node id]/proves($param)/type"]
                }]]
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
            return [hir::syntax::failNode $origin [dict get $node name]]
        }
        handledcall {
            set handlers [lmap handler [dict get $node handlers] {
                dict create name [dict get $handler name] nameSpan [dict get $handler nameSpan] \
                    origin [OriginOf [dict get $handler body]] \
                    body [Sequence [dict get [dict get $handler body] body]]
            }]
            return [hir::syntax::handleNode $origin [Node [dict get $node call]] $handlers]
        }
    }
    error "surface::lowerToHir: cannot lower a \"[dict get $node kind]\" node"
}
