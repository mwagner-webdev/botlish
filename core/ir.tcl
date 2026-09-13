# ir.tcl -- core IR syntax: node shapes, literals and static checks.
#
# IR nodes are Tcl lists whose first element is the operation name:
#
#   (const LITERAL)             (const TYPE LITERAL)   TYPE: int str list
#   (bind NAME EXPR)
#   (ref NAME)
#   (block PARAMS BODY...)
#   (call CALLEE ARG...)
#   (if CONDITION THEN-BLOCK ELSE-BLOCK)
#   (loop BODY-BLOCK)
#   (return EXPR)
#   (break)                     (break EXPR)
#   (continue)
#   (ok EXPR)
#   (error-value EXPR)
#
# THEN-BLOCK, ELSE-BLOCK and BODY-BLOCK must be syntactic (block {} ...) nodes:
# their bodies are lexically part of the enclosing code.
#
# This file knows syntax only; it does not evaluate anything.

namespace eval core::ir {}

proc core::ir::op {node} {
    if {[catch {llength $node} length] || $length == 0} {
        core::malformed "an IR node must be a non-empty list" $node
    }
    return [lindex $node 0]
}

proc core::ir::blockParams {node} { return [lindex $node 1] }
proc core::ir::blockBody {node}   { return [lrange $node 2 end] }

proc core::ir::ExpectLength {node min max usage} {
    set n [llength $node]
    if {$n < $min || ($max ne "*" && $n > $max)} {
        core::malformed "expected $usage" $node
    }
}

proc core::ir::CheckName {name node} {
    if {$name eq ""} {
        core::malformed "a name must be a non-empty string" $node
    }
}

proc core::ir::CheckParams {params node} {
    if {[catch {llength $params}]} {
        core::malformed "block parameters must be a list" $node
    }
    set seen {}
    foreach param $params {
        CheckName $param $node
        if {$param in $seen} {
            core::semanticError DUPLICATE \
                "duplicate binding \"$param\" in the same lexical scope (block parameters)"
        }
        lappend seen $param
    }
}

# A body that is lexically part of its owner: (block {} EXPR...)
proc core::ir::CheckInlineBlock {blockNode owner role} {
    if {[catch {llength $blockNode} n] || $n == 0 || [lindex $blockNode 0] ne "block"} {
        core::malformed "$role of [lindex $owner 0] must be a (block {} ...) node" $owner
    }
    CheckShape $blockNode
    if {[llength [blockParams $blockNode]] != 0} {
        core::malformed "$role of [lindex $owner 0] must be a block without parameters" $owner
    }
}

# Validates the shape of one node (not of its sub-expressions).
proc core::ir::CheckShape {node} {
    set op [op $node]
    switch -- $op {
        const {
            ExpectLength $node 2 3 "(const LITERAL) or (const TYPE LITERAL)"
            if {[llength $node] == 3} {
                lassign $node _ type text
                switch -- $type {
                    int {
                        if {![core::value::isCanonicalInt $text]} {
                            core::malformed "not a canonical integer literal" $node
                        }
                    }
                    str {}
                    list {
                        if {[catch {llength $text}]} {
                            core::malformed "list literal must be a Tcl list" $node
                        }
                    }
                    default {
                        core::malformed "unknown literal type \"$type\"" $node
                    }
                }
            }
        }
        bind {
            ExpectLength $node 3 3 "(bind NAME EXPR)"
            CheckName [lindex $node 1] $node
        }
        ref {
            ExpectLength $node 2 2 "(ref NAME)"
            CheckName [lindex $node 1] $node
        }
        block {
            ExpectLength $node 2 * "(block PARAMS BODY...)"
            CheckParams [lindex $node 1] $node
        }
        call {
            ExpectLength $node 2 * "(call CALLEE ARG...)"
        }
        if {
            ExpectLength $node 4 4 "(if CONDITION THEN-BLOCK ELSE-BLOCK)"
            CheckInlineBlock [lindex $node 2] $node "then branch"
            CheckInlineBlock [lindex $node 3] $node "else branch"
        }
        loop {
            ExpectLength $node 2 2 "(loop BODY-BLOCK)"
            CheckInlineBlock [lindex $node 1] $node "body"
        }
        return {
            ExpectLength $node 2 2 "(return EXPR)"
        }
        break {
            ExpectLength $node 1 2 "(break) or (break EXPR)"
        }
        continue {
            ExpectLength $node 1 1 "(continue)"
        }
        ok {
            ExpectLength $node 2 2 "(ok EXPR)"
        }
        error-value {
            ExpectLength $node 2 2 "(error-value EXPR)"
        }
        default {
            core::malformed "unknown operation \"$op\"" $node
        }
    }
}

proc core::ir::checkShape {node} {
    CheckShape $node
}

# ---------------------------------------------------------------------------
# Literals
#
# (const LITERAL): text in canonical decimal integer form (0, 42, -7; no
# leading zeros, no "+", no "-0") is an int; anything else is a str.
# (const int LITERAL), (const str LITERAL) force the type.
# (const list {E...}) builds a list; each element follows the untyped rule.

proc core::ir::InferLiteral {text} {
    if {[core::value::isCanonicalInt $text]} {
        return [core::value::int $text]
    }
    return [core::value::str $text]
}

proc core::ir::literalValue {node} {
    if {[llength $node] == 2} {
        return [InferLiteral [lindex $node 1]]
    }
    lassign $node _ type text
    switch -- $type {
        int  { return [core::value::int $text] }
        str  { return [core::value::str $text] }
        list {
            set items {}
            foreach element $text {
                lappend items [InferLiteral $element]
            }
            return [core::value::listOf $items]
        }
    }
}

# ---------------------------------------------------------------------------
# Scope structure
#
# A scope is the sequence of a program, a block body, an if branch or a loop
# body. The names a scope binds are those of every `bind` evaluated in it,
# i.e. reachable from its expressions without entering a nested scope
# (block nodes, if branches, loop bodies). The condition of an `if` belongs
# to the enclosing scope.

proc core::ir::scopeBindNames {exprs} {
    set names {}
    foreach expr $exprs {
        CollectBindNames $expr names
    }
    return $names
}

proc core::ir::CollectBindNames {node namesVar} {
    upvar 1 $namesVar names
    switch -- [op $node] {
        bind {
            CollectBindNames [lindex $node 2] names
            if {[lindex $node 1] ni $names} {
                lappend names [lindex $node 1]
            }
        }
        call {
            foreach expr [lrange $node 1 end] {
                CollectBindNames $expr names
            }
        }
        if {
            CollectBindNames [lindex $node 1] names
        }
        return - ok - error-value {
            CollectBindNames [lindex $node 1] names
        }
        break {
            if {[llength $node] == 2} {
                CollectBindNames [lindex $node 1] names
            }
        }
    }
}

# True if a block node occurs anywhere within EXPRS (at any depth).
proc core::ir::containsBlock {exprs} {
    foreach expr $exprs {
        switch -- [op $expr] {
            block {
                return 1
            }
            const - ref - continue {}
            if {
                if {[containsBlock [list [lindex $expr 1]]]
                    || [containsBlock [blockBody [lindex $expr 2]]]
                    || [containsBlock [blockBody [lindex $expr 3]]]} {
                    return 1
                }
            }
            loop {
                if {[containsBlock [blockBody [lindex $expr 1]]]} {
                    return 1
                }
            }
            bind {
                if {[containsBlock [list [lindex $expr 2]]]} {
                    return 1
                }
            }
            default {
                if {[containsBlock [lrange $expr 1 end]]} {
                    return 1
                }
            }
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Static check of a whole expression tree.
#
# Besides shapes, verifies lexical placement of control operators:
#   return   must be inside a block (callable) body
#   break    must be inside a loop body, without an intervening block node
#   continue likewise
# Bodies of if branches and loops are inline and do not reset the context;
# every other block node starts a new callable context outside any loop.

proc core::ir::check {node {context {callable 0 loop 0}}} {
    CheckShape $node
    switch -- [op $node] {
        const - ref {}
        bind - ok - error-value {
            check [lindex $node end] $context
        }
        return {
            if {![dict get $context callable]} {
                core::semanticError RETURN-OUTSIDE-CALLABLE \
                    "return outside callable invocation"
            }
            check [lindex $node 1] $context
        }
        break {
            if {![dict get $context loop]} {
                core::semanticError BREAK-OUTSIDE-LOOP "break outside lexical loop"
            }
            if {[llength $node] == 2} {
                check [lindex $node 1] $context
            }
        }
        continue {
            if {![dict get $context loop]} {
                core::semanticError CONTINUE-OUTSIDE-LOOP "continue outside lexical loop"
            }
        }
        block {
            foreach expr [blockBody $node] {
                check $expr {callable 1 loop 0}
            }
        }
        call {
            foreach expr [lrange $node 1 end] {
                check $expr $context
            }
        }
        if {
            check [lindex $node 1] $context
            foreach branch [lrange $node 2 3] {
                foreach expr [blockBody $branch] {
                    check $expr $context
                }
            }
        }
        loop {
            set inner [dict replace $context loop 1]
            foreach expr [blockBody [lindex $node 1]] {
                check $expr $inner
            }
        }
    }
    return
}
