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
#             see this file's blockNode)
#   call      callee, args
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
proc hir::syntax::blockNode {origin params body {declaredResult {}} {paramTypes {}} {declaredErrors {}}} {
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
    return [Node block $origin params $params body $body declaredResult $declaredResult \
        paramTypes $paramTypes declaredErrors $declaredErrors]
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
