# syntax.tcl -- unresolved HIR input: what hir::buildSyntax consumes.
#
#   set x [hir::syntax::bindNode $origin x [hir::syntax::constNode $origin 10]]
#   set h [hir::buildSyntax [list $x ...]]
#
# A syntax node states what was written, where, before any name is
# resolved. It is the one input of HIR resolution: core IR becomes syntax
# with hir::syntax::fromIR (origins {ir PATH}), and frontends construct it
# directly with their own origins (surface/lower.tcl: source spans).
#
# A node is a dict {kind origin ...}:
#
#   const     literal (the words of core IR's const after `const`)
#   ref       name, root (1: denotes the root binding NAME whatever local
#             bindings are called; see hygiene.tcl)
#   bind      name, value
#   block     params ({NAME ORIGIN} pairs), body (nodes), paramTypes
#             (one raw type-name string per param, "" for an untyped
#             parameter -- surface/parser.tcl's "x: T" annotation, unresolved
#             until hir/resolve.tcl normalizes it into declaredParamTypes;
#             see this file's blockNode), flags (optional: {NAME ORIGIN}
#             pairs, the function's declared flag section in declaration
#             order -- FLAGS.md; absent or empty for a function without
#             flags), nomethod (optional, 1: `nomethod fn`, the function's author
#             declares that it is never the callee of method syntax --
#             WARNINGS-METHOD-ELIGIBLE.md; absent for every other block),
#             contextParams (optional: {NAME ORIGIN TYPE TYPEORIGIN} tuples,
#             the function's context parameter section -- CONTEXTS.md;
#             absent for a function without one)
#   call      callee, args, flags (optional: {NAME ORIGIN} pairs, the flags
#             the call supplies, in written order -- FLAGS.md), written
#             (optional, see below)
#   if        condition, thenOrigin, thenBody, elseOrigin, elseBody
#   loop      bodyOrigin, body
#   listloop  iterable, elementName, elementOrigin, bodyOrigin, body -- the
#             surface "loop x in EXPR:" form (core IR's `listloop`): iterable
#             is evaluated in the *enclosing* scope, exactly like `if`'s
#             condition; elementName/elementOrigin/bodyOrigin/body describe
#             the per-iteration element binding and body, exactly like a
#             one-parameter block's own params/body (see hir/resolve.tcl)
#   countloop start, end, countName, countOrigin, bodyOrigin, body -- the
#             surface "loop i from START to END:" ascending counted-loop
#             form (core IR's `countloop`, R2A3-COUNTED-LOOPS-FINAL-SOURCE.
#             md): start/end are evaluated once, in the *enclosing* scope,
#             left to right, exactly like listloop's iterable;
#             countName/countOrigin/bodyOrigin/body describe the
#             per-iteration immutable induction binding and body, exactly
#             like listloop's own elementName/elementOrigin/bodyOrigin/body.
#             direction (up | down) and endKind (exclusive | inclusive)
#             record which of the four numeric forms was written (COLLECTING-
#             LOOPS.md): `start` is always where iteration begins and `end`
#             the limit, so "down from B to A" is start B / end A
#   lockloop  domains, bodyOrigin, body -- the surface lockstep form "loop x
#             in xs and i from 0 to n:": every domain advances together, one
#             position per body execution. domains is a list of dicts in
#             written order, {kind list name origin iterable} or {kind count
#             name origin start end direction endKind}, each binding its own
#             per-iteration name; the operand expressions are evaluated once,
#             in the enclosing scope, before the first iteration
#   struct    type, fields -- STRUCTS.md. TYPE is "" for an anonymous struct
#             value { x: a, y: b }, or for a named construction `Name { ... }`
#             a dict {name NAME namespace NS origin ORIGIN} (an as-written,
#             unresolved struct type name, NS "" when unqualified:
#             hir/resolve.tcl resolves it against the struct declarations
#             visible from the code's own namespace) or {id ID} (an
#             already-resolved declaration identity, core IR's own spelling).
#             FIELDS is a list of {name nameOrigin origin value} dicts in
#             WRITTEN order, which is evaluation order: one shared
#             field-initializer payload for both forms.
#   project   receiver, name, nameOrigin -- `receiver.name`: a statically
#             resolved field projection (STRUCTS.md)
#
# A `call` node may carry `method 1`: it was written `receiver.name(args)`
# (METHOD-SUGAR.md). Its callee is then the `project` node of `receiver.name`
# and ARGS exclude the receiver; hir::resolve::Expr turns it into the
# ordinary call `name(receiver, args)` when `name` is visible from the call,
# and otherwise leaves the call of the field value it has always been.
#
# Every `call` node a source frontend builds also carries `written FORM`: how
# the call was spelled, which no later stage can recover once the sugar and
# the operators are lowered to ordinary calls (WARNINGS-METHOD-ELIGIBLE.md):
#
#   function   `f(a, b)`: a call the programmer wrote in functional form
#   method     `a.f(b)`: method-call sugar (also carries `method 1`)
#   list       `[a, b]`: a list literal, lowered to a call of `list`
#   operator   `a + b`, `a == b`, `-a`: an operator, lowered to a call of the
#              root native of that name (`a != b`'s inner `==` too)
#
# A call that came from core IR carries no `written` field. The marker is
# written in every compilation mode and read by diagnostics only: no analysis,
# lowering or backend consults it.
#   return    value
#   break     value (node or "")
#   continue
#   ok        value
#   error     value
#   fail      name (a declared error's name)
#   handle    call (a `call` node), handlers (a list of {name nameSpan
#             origin body} dicts, one per "on NAME:" clause, in written
#             order -- name/nameSpan for diagnostics, origin for the
#             handler body's own branch scope, body a list of nodes,
#             exactly like an `if` branch's body)
#
# `block`'s own node also takes an optional `declaredErrors` field: a list
# of {name nameSpan} pairs, one per name of a function's own "errors E1,
# E2:" clause (surface/parser.tcl), unresolved until hir/resolve.tcl
# validates each name against the program's own declared errors
# (hir::errordecls) -- exactly parallel to `declaredResult`/paramTypes'
# own deferred-resolution treatment (EXPLICIT-ERROR-COMPLETIONS.md).
#
# Constructors (constNode, refNode, rootRef, bindNode, blockNode, callNode,
# ifNode, loopNode, returnNode, breakNode, continueNode, okNode, errorNode,
# failNode, handleNode) take the origin first and check shapes, raising
# {CORE MALFORMED} as core IR does.

namespace eval hir::syntax {}

proc hir::syntax::Node {kind origin args} {
    return [dict create kind $kind origin $origin {*}$args]
}

proc hir::syntax::constNode {origin args} {
    core::ir::checkShape [list const {*}$args]
    return [Node const $origin literal $args]
}

proc hir::syntax::refNode {origin name} {
    core::ir::checkShape [list ref $name]
    return [Node ref $origin name $name root 0]
}

# A reference to the root binding NAME (a native, true, false or unit) that
# no local binding can shadow. Program mode only.
proc hir::syntax::rootRef {origin name} {
    if {$name ni [hir::resolve::RootNames]} {
        core::malformed "\"$name\" is not a root name" [list ref $name]
    }
    return [Node ref $origin name $name root 1]
}

proc hir::syntax::bindNode {origin name value} {
    core::ir::checkShape [list bind $name {}]
    return [Node bind $origin name $name value $value]
}

# PARAMS: {NAME ORIGIN} pairs. Duplicate names are a DUPLICATE diagnostic of
# the built HIR, not a construction error. PARAMTYPES, if given, is one raw
# type-name string per param ("" for untyped); defaults to all-"" (every
# param untyped) when omitted, so every existing caller (fromIR, and any
# hand-built syntax that predates parameter typing) is unaffected.
proc hir::syntax::blockNode {origin params body {declaredResult {}} {paramTypes {}} {declaredErrors {}} {flags {}}} {
    foreach param $params {
        if {[llength $param] != 2 || [lindex $param 0] eq ""} {
            core::malformed "block parameters must be {NAME ORIGIN} pairs" [list block $params]
        }
    }
    if {$paramTypes eq {}} {
        set paramTypes [lrepeat [llength $params] {}]
    } elseif {[llength $paramTypes] != [llength $params]} {
        core::malformed "block paramTypes must have one entry per parameter" [list block $params $paramTypes]
    }
    foreach flag $flags {
        if {[llength $flag] != 2 || [lindex $flag 0] eq ""} {
            core::malformed "block flags must be {NAME ORIGIN} pairs" [list block $params $flags]
        }
    }
    return [Node block $origin params $params body $body declaredResult $declaredResult \
        paramTypes $paramTypes declaredErrors $declaredErrors flags $flags]
}

# TYPE and FIELDS as this file's header describes `struct`.
proc hir::syntax::structNode {origin type fields} {
    foreach field $fields {
        if {[catch {dict get $field name; dict get $field nameOrigin; dict get $field origin; dict get $field value}]} {
            core::malformed "struct fields must be {name nameOrigin origin value} dicts" [list struct $fields]
        }
    }
    return [Node struct $origin type $type fields $fields]
}

proc hir::syntax::projectNode {origin receiver name nameOrigin} {
    core::ir::checkShape [list project {} $name]
    return [Node project $origin receiver $receiver name $name nameOrigin $nameOrigin]
}

proc hir::syntax::callNode {origin callee args} {
    return [Node call $origin callee $callee args $args]
}

# CALL (a `call` node) supplying the flags FLAGS, {NAME ORIGIN} pairs in
# written order (FLAGS.md). Flags are names, not expressions: they are not
# part of the call's `args`, and each call spelling states a statically
# known set.
proc hir::syntax::withFlags {call flags} {
    foreach flag $flags {
        if {[llength $flag] != 2 || [lindex $flag 0] eq ""} {
            core::malformed "call flags must be {NAME ORIGIN} pairs" [list call $flags]
        }
    }
    if {$flags ne {}} {
        dict set call flags $flags
    }
    return $call
}

# `receiver.name(args...)` (METHOD-SUGAR.md): a call of the field projection
# `receiver.name` marked as method-call sugar. NAMEORIGIN locates `name`.
# The projection's own origin spans the receiver through the name. It is
# written with method sugar (`written method`).
proc hir::syntax::methodCallNode {origin receiver name nameOrigin args} {
    set projectOrigin $origin
    if {[dict exists $projectOrigin node]} {
        dict set projectOrigin node [dict get $projectOrigin node]/callee
    }
    dict set projectOrigin end [dict get $nameOrigin end]
    dict set projectOrigin endLine [dict get $nameOrigin endLine]
    dict set projectOrigin endColumn [dict get $nameOrigin endColumn]
    set callee [projectNode $projectOrigin $receiver $name $nameOrigin]
    set call [withWritten [callNode $origin $callee {*}$args] method]
    dict set call method 1
    return $call
}

# CALL (a `call` node) marked as written in spelling FORM (function | method
# | list | operator, see this file's header).
proc hir::syntax::withWritten {call form} {
    if {$form ni {function method list operator}} {
        core::malformed "a call's written form must be function, method, list or operator" [list call $form]
    }
    dict set call written $form
    return $call
}

# BLOCK (a `block` node) declared `nomethod` by its author.
proc hir::syntax::withNoMethod {block} {
    dict set block nomethod 1
    return $block
}

# BLOCK (a `block` node) with the context parameter section CONTEXTPARAMS
# (CONTEXTS.md): {NAME ORIGIN TYPE TYPEORIGIN} tuples in written order, TYPE
# the as-written type expression of the required context. They are not
# parameters: hir/resolve.tcl binds each NAME, at the start of the body, to
# the installed context of TYPE's resolved identity (an explicit
# context#load), and the block's `params` (its call arity) are unchanged.
proc hir::syntax::withContextParams {block contextParams} {
    foreach entry $contextParams {
        if {[llength $entry] != 4 || [lindex $entry 0] eq ""} {
            core::malformed "block context parameters must be {NAME ORIGIN TYPE TYPEORIGIN} tuples" [list block $contextParams]
        }
    }
    if {$contextParams ne {}} {
        dict set block contextParams $contextParams
    }
    return $block
}

# `with context VALUE` (CONTEXTS.md): two statements --
#
#     bind TEMP VALUE                      evaluate the value, in order
#     call ^context#install (ref TEMP)     install it as the context of its
#                                          inferred context-struct type
#
# TEMP is a hygienic temporary (its name contains "#", which source cannot
# spell), so the installation reads an ordinary local: the install is an
# explicit call of the internal root native context#install (core/
# contexts.tcl) that hir/contexts.tcl finds by native identity, infers the
# type of and verifies, and a native backend can consume the value's fields
# without building the object (hir/escape.tcl counts the install as a
# structural use). Returns the two nodes.
proc hir::syntax::contextInstallNodes {origin temp value} {
    set bind [bindNode $origin $temp $value]
    set call [callNode $origin [rootRef $origin [core::contexts::installNative]] [refNode $origin $temp]]
    return [list $bind $call]
}

proc hir::syntax::ifNode {origin condition thenOrigin thenBody elseOrigin elseBody} {
    return [Node if $origin condition $condition thenOrigin $thenOrigin thenBody $thenBody \
        elseOrigin $elseOrigin elseBody $elseBody]
}

proc hir::syntax::loopNode {origin bodyOrigin body} {
    return [Node loop $origin bodyOrigin $bodyOrigin body $body]
}

proc hir::syntax::listLoopNode {origin iterable elementName elementOrigin bodyOrigin body} {
    return [Node listloop $origin iterable $iterable elementName $elementName \
        elementOrigin $elementOrigin bodyOrigin $bodyOrigin body $body]
}

# DIRECTION is up | down and ENDKIND exclusive | inclusive; START is the value
# iteration begins at and END the limit (see the countloop entry above).
proc hir::syntax::countLoopNode {origin start end countName countOrigin bodyOrigin body
        {direction up} {endKind exclusive}} {
    if {$direction eq ""} {
        set direction up
    }
    if {$endKind eq ""} {
        set endKind exclusive
    }
    return [Node countloop $origin start $start end $end countName $countName \
        countOrigin $countOrigin bodyOrigin $bodyOrigin body $body \
        direction $direction endKind $endKind]
}

# DOMAINS: one dict per iteration clause, in written order --
#   {kind list  name N origin O iterable EXPR}
#   {kind count name N origin O start EXPR end EXPR direction D endKind K}
proc hir::syntax::lockLoopNode {origin domains bodyOrigin body} {
    return [Node lockloop $origin domains $domains bodyOrigin $bodyOrigin body $body]
}

proc hir::syntax::returnNode {origin value} {
    return [Node return $origin value $value]
}

proc hir::syntax::breakNode {origin {value ""}} {
    return [Node break $origin value $value]
}

proc hir::syntax::continueNode {origin} {
    return [Node continue $origin]
}

proc hir::syntax::okNode {origin value} {
    return [Node ok $origin value $value]
}

proc hir::syntax::errorNode {origin value} {
    return [Node error $origin value $value]
}

proc hir::syntax::failNode {origin name} {
    core::ir::checkShape [list fail $name]
    return [Node fail $origin name $name]
}

# HANDLERS: a list of {name nameSpan origin body} dicts, as this file's own
# header describes. CALL must itself be a `call` node (checked by
# hir::resolve::Expr, which needs the resolved ExprId to check the kind of
# -- this constructor only checks the unresolved syntax shape, mirroring
# core::ir::checkShape's own (call ...) requirement for core IR's `handle`).
proc hir::syntax::handleNode {origin call handlers} {
    if {[dict get $call kind] ne "call"} {
        core::malformed "the handled expression of \"handle\" must be a call" [list handle $call]
    }
    return [Node handle $origin call $call handlers $handlers]
}

# The syntax of the core IR NODE at IR PATH (a list of indices). Checks
# shapes exactly as core IR does (malformed IR raises {CORE MALFORMED},
# duplicate parameters {CORE SEMANTIC DUPLICATE}).
proc hir::syntax::fromIR {node path} {
    core::ir::checkShape $node
    set origin [list ir $path]
    switch -- [core::ir::op $node] {
        const {
            return [Node const $origin literal [lrange $node 1 end]]
        }
        ref {
            return [Node ref $origin name [lindex $node 1] root 0]
        }
        bind {
            return [Node bind $origin name [lindex $node 1] \
                value [fromIR [lindex $node 2] [concat $path 2]]]
        }
        block {
            set params {}
            set index 0
            foreach name [core::ir::blockParams $node] {
                lappend params [list $name [list ir [concat $path 1 $index]]]
                incr index
            }
            return [Node block $origin params $params \
                body [Sequence [core::ir::blockBody $node] $path 2]]
        }
        call {
            return [Node call $origin callee [fromIR [lindex $node 1] [concat $path 1]] \
                args [Sequence [lrange $node 2 end] $path 2]]
        }
        if {
            return [Node if $origin condition [fromIR [lindex $node 1] [concat $path 1]] \
                thenOrigin [list ir [concat $path 2]] \
                thenBody [Sequence [core::ir::blockBody [lindex $node 2]] [concat $path 2] 2] \
                elseOrigin [list ir [concat $path 3]] \
                elseBody [Sequence [core::ir::blockBody [lindex $node 3]] [concat $path 3] 2]]
        }
        loop {
            return [Node loop $origin bodyOrigin [list ir [concat $path 1]] \
                body [Sequence [core::ir::blockBody [lindex $node 1]] [concat $path 1] 2]]
        }
        listloop {
            return [Node listloop $origin \
                iterable [fromIR [lindex $node 1] [concat $path 1]] \
                elementName [lindex [core::ir::blockParams [lindex $node 2]] 0] \
                elementOrigin [list ir [concat $path 2 1 0]] \
                bodyOrigin [list ir [concat $path 2]] \
                body [Sequence [core::ir::blockBody [lindex $node 2]] [concat $path 2] 2]]
        }
        countloop {
            lassign [core::ir::countOptions $node] direction endKind
            return [Node countloop $origin \
                start [fromIR [lindex $node 1] [concat $path 1]] \
                end [fromIR [lindex $node 2] [concat $path 2]] \
                countName [lindex [core::ir::blockParams [lindex $node 3]] 0] \
                countOrigin [list ir [concat $path 3 1 0]] \
                bodyOrigin [list ir [concat $path 3]] \
                body [Sequence [core::ir::blockBody [lindex $node 3]] [concat $path 3] 2] \
                direction $direction endKind $endKind]
        }
        lockloop {
            set names [core::ir::blockParams [lindex $node 2]]
            set domains {}
            set index 0
            foreach domain [lindex $node 1] name $names {
                set dpath [concat $path 1 $index]
                set norigin [list ir [concat $path 2 1 $index]]
                if {[lindex $domain 0] eq "list"} {
                    lappend domains [dict create kind list name $name origin $norigin \
                        iterable [fromIR [lindex $domain 1] [concat $dpath 1]]]
                } else {
                    lassign [core::ir::countOptions [list countloop {} {} {} \
                        [lindex $domain 3] [lindex $domain 4]]] direction endKind
                    lappend domains [dict create kind count name $name origin $norigin \
                        start [fromIR [lindex $domain 1] [concat $dpath 1]] \
                        end [fromIR [lindex $domain 2] [concat $dpath 2]] \
                        direction $direction endKind $endKind]
                }
                incr index
            }
            return [Node lockloop $origin domains $domains \
                bodyOrigin [list ir [concat $path 2]] \
                body [Sequence [core::ir::blockBody [lindex $node 2]] [concat $path 2] 2]]
        }
        struct {
            # (struct HEAD NAME EXPR ...): HEAD is {} (anonymous) or {ID
            # FIELD...} (named: declaration identity, then the declared slot
            # order, which only the evaluator needs).
            set head [lindex $node 1]
            set type [expr {$head eq "" ? "" : [dict create id [lindex $head 0]]}]
            set fields {}
            set index 2
            foreach {name value} [lrange $node 2 end] {
                lappend fields [dict create name $name nameOrigin [list ir [concat $path $index]] \
                    origin [list ir [concat $path $index]] \
                    value [fromIR $value [concat $path [expr {$index + 1}]]]]
                incr index 2
            }
            return [Node struct $origin type $type fields $fields]
        }
        project {
            return [Node project $origin receiver [fromIR [lindex $node 1] [concat $path 1]] \
                name [lindex $node 2] nameOrigin [list ir [concat $path 2]]]
        }
        return - ok {
            return [Node [core::ir::op $node] $origin value [fromIR [lindex $node 1] [concat $path 1]]]
        }
        error-value {
            return [Node error $origin value [fromIR [lindex $node 1] [concat $path 1]]]
        }
        break {
            set value ""
            if {[llength $node] == 2} {
                set value [fromIR [lindex $node 1] [concat $path 1]]
            }
            return [Node break $origin value $value]
        }
        continue {
            return [Node continue $origin]
        }
        fail {
            return [Node fail $origin name [lindex $node 1]]
        }
        handle {
            set handlers {}
            set index 2
            foreach {name handlerBlock} [lrange $node 2 end] {
                lappend handlers [dict create name $name nameSpan "" \
                    origin [list ir [concat $path $index]] \
                    body [Sequence [core::ir::blockBody $handlerBlock] [concat $path $index] 2]]
                incr index 2
            }
            return [Node handle $origin call [fromIR [lindex $node 1] [concat $path 1]] handlers $handlers]
        }
    }
}

proc hir::syntax::Sequence {nodes path first} {
    set result {}
    set index $first
    foreach node $nodes {
        lappend result [fromIR $node [concat $path $index]]
        incr index
    }
    return $result
}

# Names bound by `bind` nodes among NODES without entering a nested scope
# (blocks, if branches, loop bodies), in order: core::ir::scopeBindNames for
# syntax.
proc hir::syntax::scopeBindNames {nodes} {
    set names {}
    foreach node $nodes {
        CollectBindNames $node names
    }
    return $names
}

proc hir::syntax::CollectBindNames {node namesVar} {
    upvar 1 $namesVar names
    switch -- [dict get $node kind] {
        bind {
            CollectBindNames [dict get $node value] names
            if {[dict get $node name] ni $names} {
                lappend names [dict get $node name]
            }
        }
        call {
            CollectBindNames [dict get $node callee] names
            foreach arg [dict get $node args] {
                CollectBindNames $arg names
            }
        }
        struct {
            foreach field [dict get $node fields] {
                CollectBindNames [dict get $field value] names
            }
        }
        project {
            CollectBindNames [dict get $node receiver] names
        }
        if {
            CollectBindNames [dict get $node condition] names
        }
        listloop {
            CollectBindNames [dict get $node iterable] names
        }
        countloop {
            CollectBindNames [dict get $node start] names
            CollectBindNames [dict get $node end] names
        }
        lockloop {
            foreach domain [dict get $node domains] {
                foreach field {iterable start end} {
                    if {[dict exists $domain $field]} {
                        CollectBindNames [dict get $domain $field] names
                    }
                }
            }
        }
        return - ok - error {
            CollectBindNames [dict get $node value] names
        }
        break {
            if {[dict get $node value] ne ""} {
                CollectBindNames [dict get $node value] names
            }
        }
        handle {
            CollectBindNames [dict get $node call] names
        }
    }
}
