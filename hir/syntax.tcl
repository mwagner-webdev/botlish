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
#   block     params ({NAME ORIGIN} pairs), body (nodes)
#   call      callee, args
#   if        condition, thenOrigin, thenBody, elseOrigin, elseBody
#   loop      bodyOrigin, body
#   return    value
#   break     value (node or "")
#   continue
#   ok        value
#   error     value
#
# Constructors (constNode, refNode, rootRef, bindNode, blockNode, callNode,
# ifNode, loopNode, returnNode, breakNode, continueNode, okNode, errorNode)
# take the origin first and check shapes, raising {CORE MALFORMED} as core
# IR does.

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
# the built HIR, not a construction error.
proc hir::syntax::blockNode {origin params body} {
    foreach param $params {
        if {[llength $param] != 2 || [lindex $param 0] eq ""} {
            core::malformed "block parameters must be {NAME ORIGIN} pairs" [list block $params]
        }
    }
    return [Node block $origin params $params body $body]
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
        if {
            CollectBindNames [dict get $node condition] names
        }
        return - ok - error {
            CollectBindNames [dict get $node value] names
        }
        break {
            if {[dict get $node value] ne ""} {
                CollectBindNames [dict get $node value] names
            }
        }
    }
}
