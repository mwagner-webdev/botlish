# ir.tcl -- core IR syntax: node shapes, literals and static checks.
#
# IR nodes are Tcl lists whose first element is the operation name:
#
#   (const LITERAL)             (const TYPE LITERAL)   TYPE: int str list
#                                                        UnicodeChar enum
#   (bind NAME EXPR)
#   (ref NAME)
#   (block PARAMS BODY...)
#   (call CALLEE ARG...)
#   (if CONDITION THEN-BLOCK ELSE-BLOCK)
#   (loop BODY-BLOCK)
#   (listloop LIST-EXPR ELEMENT-BLOCK)
#   (countloop START-EXPR END-EXPR ELEMENT-BLOCK)
#   (countloop START-EXPR END-EXPR ELEMENT-BLOCK DIRECTION ENDKIND)
#   (lockloop (DOMAIN...) ELEMENTS-BLOCK)   (lockloop ... REJECTED-MESSAGE)
#   (return EXPR)
#   (break)                     (break EXPR)
#                               PAYLOAD-FREE-BREAK.md: no valid Botlish
#                               source program can ever lower to "(break
#                               EXPR)" (surface/parser.tcl rejects any
#                               break payload at parse time, in every loop
#                               kind) -- but this core-IR shape itself is
#                               deliberately kept: raw core-IR text below
#                               the surface parser (e.g. bench/loop-
#                               count.ir, lifted to HIR by hir::build's
#                               fromIR) still legitimately uses it, with
#                               its full pre-milestone "overrides a plain
#                               loop/countloop's own result, discarding
#                               whatever was in flight" semantics, both to
#                               keep that canonical benchmark's behavior
#                               and generated code stable and as the
#                               substrate the future `leave VALUE`
#                               construct is expected to lower to. See
#                               hir/resolve.tcl's own break case for the
#                               full "two-tier" design this implements.
#   (continue)
#   (struct HEAD NAME EXPR ...)   (project EXPR NAME)
#   (ok EXPR)
#   (error-value EXPR)
#   (fail NAME)   (fail NAME PAYLOAD-EXPR)
#   (handle CALL-EXPR NAME1 HANDLER-BLOCK1 NAME2 HANDLER-BLOCK2 ...)
#
# THEN-BLOCK, ELSE-BLOCK and BODY-BLOCK must be syntactic (block {} ...) nodes:
# their bodies are lexically part of the enclosing code.
#
# (fail NAME): completes with `propagate-error(errorId(NAME))` (core/
# completion.tcl) -- an alternate, named completion edge of the enclosing
# function, never an ordinary value (EXPLICIT-ERROR-COMPLETIONS.md).
# (fail NAME PAYLOAD-EXPR) evaluates PAYLOAD-EXPR first and completes with
# `propagate-error(errorId(NAME, PAYLOAD))`: the error identity and the
# payload value it carries (ERROR-PAYLOADS.md); a PAYLOAD-EXPR that does not
# complete normally completes the fail the same way, and no error is raised. Whether
# NAME is a declared error the enclosing function may actually produce is a
# HIR-level static obligation (hir/errorsets.tcl), not something this file
# checks: exactly like `return`/`break`/`continue`, this file only checks
# shape, never target legality.
#
# (handle CALL-EXPR NAME1 HANDLER-BLOCK1 ...): CALL-EXPR must be a syntactic
# (call ...) node. Evaluates CALL-EXPR; if it completes normally, `handle`
# completes the same way. If it completes with `propagate-error(errorId(N))`
# and N is one of NAME1, NAME2, ..., the matching HANDLER-BLOCK (a syntactic
# (block {} ...) node, lexically part of the enclosing code exactly like an
# `if` branch or a loop body -- so a `return`/`break`/`continue` inside it
# affects the surrounding callable/loop, not a new one) runs instead, and
# `handle` completes however that block's body does. A HANDLER-BLOCK may have
# one parameter, (block {P} ...): P is bound, in the handler's own scope, to
# the payload the error carries (ERROR-PAYLOADS.md). Selection compares the
# error's name only, never its payload. Any other completion
# (including a propagate-error whose name matches none of NAME1, NAME2, ...)
# passes through unchanged.
#
# (struct HEAD NAME1 EXPR1 NAME2 EXPR2 ...): builds a struct value (STRUCTS.md).
# The EXPRs are evaluated strictly in WRITTEN order (the order of the NAMEs
# here, never a canonical layout order); only when every one has completed
# normally is the struct built, so no partially initialized value is ever
# observable. HEAD is {} for an anonymous struct value -- its shape is the
# set of NAMEs (an anonymous struct's identity is its field set, never the
# order they were written in) -- or {ID FIELD ...} for a named struct
# construction: ID is the declaration identity (a program-unique
# "Name" / "namespace::Name") and FIELD... the declared slot order, which
# the written NAMEs must match exactly (same set, no duplicate, none
# missing -- a mismatch is a static error in HIR; here it is a semantic
# error, STRUCT). The runtime value carries its shape, so equality and
# display never consult a declaration.
#
# (project EXPR NAME): the value of field NAME of the struct value of EXPR. A
# struct's field set is fixed, so a well-typed projection cannot fail; here
# a receiver that is not a struct, or has no such field, is an invalid
# program (TYPE).
#
# (listloop LIST-EXPR ELEMENT-BLOCK): the surface `loop x in EXPR:` form
# (see surface/parser.tcl) -- the *returning* iterable loop (RETURNING-
# ITERABLE-LOOPS.md), Botlish's fundamental collection-transformation
# primitive (it replaces map/filter/filter_map). LIST-EXPR is evaluated
# once, in the enclosing scope. ELEMENT-BLOCK must be a syntactic (block
# (ELEM) BODY...) node with exactly one parameter -- otherwise exactly like
# BODY-BLOCK above, lexically part of the enclosing code (not a callable
# boundary: `return` inside it still returns from the enclosing function),
# and, like a loop body, a valid target for `break`/`continue`. Iterates
# LIST-EXPR's elements left to right, binding ELEM fresh (immutable) each
# iteration. An iteration whose body completes with an ordinary value
# contributes that value to the result, built in order; `continue`
# contributes nothing for that iteration; a valueless `break` ends the loop
# immediately, the List collected so far (the accumulated prefix) becoming
# the *whole* listloop's result -- unlike a plain `loop`, a listloop has
# exactly one stable result type (List[R]), so `break` with a value is
# rejected at the HIR level (hir/resolve.tcl's LISTLOOP-BREAK-VALUE
# diagnostic) rather than given override semantics. If the list is
# exhausted without a `break`, the result is the List of every iteration's
# contributed value, in that order (empty for an empty LIST-EXPR).
#
# (countloop START-EXPR END-EXPR ELEMENT-BLOCK ?DIRECTION ENDKIND?): the
# surface numeric loops "loop i from A to B:", "from A through B:", "down
# from B to A:" and "down from B through A:" (COLLECTING-LOOPS.md). DIRECTION
# is `up` or `down`, ENDKIND `to` or `through`; both default to the original
# `up to` form when omitted. START-EXPR and END-EXPR are each evaluated
# exactly once, in the enclosing scope, left to right, before any iteration
# -- exactly like listloop's own LIST-EXPR. ELEMENT-BLOCK must be a
# syntactic (block (I) BODY...) node with exactly one parameter, exactly like
# listloop's own (not a callable boundary: `return` inside it still returns
# from the enclosing function; a valid target for `break`/`continue`). I is
# bound fresh (immutable), starting at START and stepping by exactly one
# (+1 for `up`, -1 for `down`), for as long as it stays on the near side of
# END as ordinary Int values (core::value::compare):
#
#     up   to       START <= I <  END
#     up   through  START <= I <= END
#     down to       START >= I >  END
#     down through  START >= I >= END
#
# The inclusive forms are *not* END+1 / END-1 arithmetic: the loop simply
# tests I against END with <= / >=, so no Int outside the endpoints is ever
# formed. A domain that is empty under that test runs the body zero times.
# Like listloop, a countloop is a *collecting* loop: an iteration whose body
# completes with an ordinary value contributes it to the result List, in
# order; `continue` contributes nothing; a bare `break` ends the loop with
# the List collected so far; exhaustion completes with the whole List (empty
# for an empty domain). `break` with a value is rejected at HIR (hir/resolve.
# tcl's LISTLOOP-BREAK-VALUE), exactly as for listloop.
#
# (lockloop (DOMAIN...) (block (P1 ... Pn) BODY...)): the lockstep loop "loop
# x in xs and i from 0 to n:". Each DOMAIN is (list LIST-EXPR) or (count
# START-EXPR END-EXPR DIRECTION ENDKIND) (DIRECTION/ENDKIND as above), and the
# block binds one parameter per DOMAIN, in order. All domain operand
# expressions are evaluated once, left to right, in the enclosing scope;
# then body iteration k (k = 0, 1, ...) runs with each Pj bound to the k-th
# element of its domain (the k-th list item, or the k-th Int of its numeric
# domain). The loop's result is collected exactly like a countloop's. All
# domains MUST have the same number of elements: that is a compile-time proof
# obligation discharged by HIR (hir/lockstep.tcl) -- there is no runtime
# length check and no shortest-wins rule here, and the interpreter treats a
# violation as an internal compiler error. The optional trailing string marks
# a loop whose obligation HIR rejected (only a -strict 0 lowering produces it):
# evaluating it raises that diagnostic unconditionally, before anything runs.
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

# Like CheckInlineBlock, for a handler's HANDLER-BLOCK: no parameter, or
# exactly one -- the binding the selected error's payload is bound to
# (ERROR-PAYLOADS.md).
proc core::ir::CheckHandlerBlock {blockNode owner role} {
    if {[catch {llength $blockNode} n] || $n == 0 || [lindex $blockNode 0] ne "block"} {
        core::malformed "$role of [lindex $owner 0] must be a (block {} ...) node" $owner
    }
    CheckShape $blockNode
    if {[llength [blockParams $blockNode]] > 1} {
        core::malformed "$role of [lindex $owner 0] must be a block with no parameter or one (its payload)" $owner
    }
}

# Like CheckInlineBlock, for a listloop's ELEMENT-BLOCK: lexically part of
# its owner exactly the same way, but with exactly one parameter (the
# per-iteration element binding) rather than none.
proc core::ir::CheckElementBlock {blockNode owner role} {
    if {[catch {llength $blockNode} n] || $n == 0 || [lindex $blockNode 0] ne "block"} {
        core::malformed "$role of [lindex $owner 0] must be a (block (ELEM) ...) node" $owner
    }
    CheckShape $blockNode
    if {[llength [blockParams $blockNode]] != 1} {
        core::malformed "$role of [lindex $owner 0] must be a block with exactly one parameter" $owner
    }
}

# {DIRECTION ENDKIND} of a (countloop ...) node -- "up exclusive" unless the
# optional trailing `up|down to|through` words say otherwise -- as the HIR
# spelling (up|down, exclusive|inclusive).
proc core::ir::countOptions {node} {
    if {[llength $node] == 4} {
        return {up exclusive}
    }
    set direction [lindex $node 4]
    set word [lindex $node 5]
    if {$direction ni {up down}} {
        core::malformed "a counted loop's DIRECTION must be up or down" $node
    }
    if {$word ni {to through}} {
        core::malformed "a counted loop's ENDKIND must be to or through" $node
    }
    return [list $direction [expr {$word eq "through" ? "inclusive" : "exclusive"}]]
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
                    UnicodeChar {
                        if {![core::value::isValidScalar $text]} {
                            core::malformed "not a Unicode scalar value" $node
                        }
                    }
                    enum {
                        # {ID CASE}: an enum case value (ENUMS.md), its
                        # declaration identity and its case's name.
                        if {[catch {llength $text} n] || $n != 2
                                || ![regexp {^[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*$} [lindex $text 0]]
                                || ![regexp {^[A-Za-z_][A-Za-z0-9_]*$} [lindex $text 1]]} {
                            core::malformed "an enum literal is {ENUM-ID CASE}" $node
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
        listloop {
            ExpectLength $node 3 3 "(listloop LIST-EXPR ELEMENT-BLOCK)"
            CheckElementBlock [lindex $node 2] $node "body"
        }
        countloop {
            if {[llength $node] != 4 && [llength $node] != 6} {
                core::malformed "(countloop START-EXPR END-EXPR ELEMENT-BLOCK ?DIRECTION ENDKIND?)" $node
            }
            CheckElementBlock [lindex $node 3] $node "body"
            countOptions $node
        }
        lockloop {
            ExpectLength $node 3 4 "(lockloop (DOMAIN...) ELEMENTS-BLOCK ?REJECTED?)"
            set domains [lindex $node 1]
            if {[catch {llength $domains} n] || $n < 2} {
                core::malformed "(lockloop ...) needs at least two domains" $node
            }
            foreach domain $domains {
                switch -- [lindex $domain 0] {
                    list {
                        if {[llength $domain] != 2} {
                            core::malformed "a lockstep list domain is (list LIST-EXPR)" $node
                        }
                    }
                    count {
                        if {[llength $domain] != 5} {
                            core::malformed "a lockstep count domain is (count START END DIRECTION ENDKIND)" $node
                        }
                        countOptions [list countloop {} {} {} [lindex $domain 3] [lindex $domain 4]]
                    }
                    default {
                        core::malformed "a lockstep domain is (list EXPR) or (count START END DIRECTION ENDKIND)" $node
                    }
                }
            }
            set block [lindex $node 2]
            if {[catch {llength $block} n] || $n == 0 || [lindex $block 0] ne "block"} {
                core::malformed "the body of lockloop must be a (block (P...) ...) node" $node
            }
            CheckShape $block
            if {[llength [blockParams $block]] != [llength $domains]} {
                core::malformed "the body block of lockloop needs exactly one parameter per domain" $node
            }
        }
        struct {
            ExpectLength $node 2 * "(struct HEAD NAME EXPR ...)"
            if {[llength $node] % 2 != 0} {
                core::malformed "(struct HEAD NAME EXPR ...) needs an EXPR for every NAME" $node
            }
            set head [lindex $node 1]
            if {[catch {llength $head}]} {
                core::malformed "the HEAD of (struct ...) must be {} or {ID FIELD ...}" $node
            }
            if {$head ne ""} {
                CheckName [lindex $head 0] $node
                set declared {}
                foreach field [lrange $head 1 end] {
                    CheckName $field $node
                    if {$field in $declared} {
                        core::semanticError DUPLICATE "duplicate field \"$field\" in struct [lindex $head 0]"
                    }
                    lappend declared $field
                }
            }
            set seen {}
            foreach {name value} [lrange $node 2 end] {
                CheckName $name $node
                if {$name in $seen} {
                    core::semanticError DUPLICATE "duplicate field \"$name\" in a struct initializer"
                }
                lappend seen $name
            }
        }
        project {
            ExpectLength $node 3 3 "(project EXPR NAME)"
            CheckName [lindex $node 2] $node
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
        fail {
            ExpectLength $node 2 3 "(fail NAME) or (fail NAME PAYLOAD-EXPR)"
            CheckName [lindex $node 1] $node
            if {[llength $node] == 3} {
                CheckShape [lindex $node 2]
            }
        }
        handle {
            ExpectLength $node 3 * "(handle CALL-EXPR NAME HANDLER-BLOCK ...)"
            if {[llength $node] % 2 != 0} {
                core::malformed "(handle CALL-EXPR NAME HANDLER-BLOCK ...) needs a HANDLER-BLOCK for every NAME" $node
            }
            set call [lindex $node 1]
            if {[catch {llength $call} n] || $n == 0 || [lindex $call 0] ne "call"} {
                core::malformed "the first argument of (handle ...) must be a (call ...) node" $node
            }
            CheckShape $call
            set seen {}
            foreach {name handlerBlock} [lrange $node 2 end] {
                CheckName $name $node
                if {$name in $seen} {
                    core::semanticError DUPLICATE \
                        "duplicate \"on $name\" handler in the same handled call"
                }
                lappend seen $name
                CheckHandlerBlock $handlerBlock $node "handler body for \"$name\""
            }
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
# (const enum {ID CASE}) is the case CASE of the enum declared as ID
# (ENUMS.md): a value, like a literal, never a lookup.  Core IR does not
# check that ID declares CASE -- HIR resolution did (hir/enums.tcl).


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
        UnicodeChar { return [core::value::char $text] }
        enum { return [core::value::enumValue [lindex $text 0] [lindex $text 1]] }
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
        struct {
            foreach {name expr} [lrange $node 2 end] {
                CollectBindNames $expr names
            }
        }
        project {
            CollectBindNames [lindex $node 1] names
        }
        if {
            CollectBindNames [lindex $node 1] names
        }
        listloop {
            CollectBindNames [lindex $node 1] names
        }
        countloop {
            CollectBindNames [lindex $node 1] names
            CollectBindNames [lindex $node 2] names
        }
        lockloop {
            foreach domain [lindex $node 1] {
                foreach operand [lrange $domain 1 [expr {[lindex $domain 0] eq "list" ? 1 : 2}]] {
                    CollectBindNames $operand names
                }
            }
        }
        return - ok - error-value {
            CollectBindNames [lindex $node 1] names
        }
        break {
            if {[llength $node] == 2} {
                CollectBindNames [lindex $node 1] names
            }
        }
        handle {
            CollectBindNames [lindex $node 1] names
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
            listloop {
                if {[containsBlock [list [lindex $expr 1]]]
                    || [containsBlock [blockBody [lindex $expr 2]]]} {
                    return 1
                }
            }
            countloop {
                if {[containsBlock [list [lindex $expr 1] [lindex $expr 2]]]
                    || [containsBlock [blockBody [lindex $expr 3]]]} {
                    return 1
                }
            }
            lockloop {
                foreach domain [lindex $expr 1] {
                    foreach operand [lrange $domain 1 [expr {[lindex $domain 0] eq "list" ? 1 : 2}]] {
                        if {[containsBlock [list $operand]]} {
                            return 1
                        }
                    }
                }
                if {[containsBlock [blockBody [lindex $expr 2]]]} {
                    return 1
                }
            }
            bind {
                if {[containsBlock [list [lindex $expr 2]]]} {
                    return 1
                }
            }
            fail {
                if {[llength $expr] == 3 && [containsBlock [list [lindex $expr 2]]]} {
                    return 1
                }
            }
            struct {
                foreach {name value} [lrange $expr 2 end] {
                    if {[containsBlock [list $value]]} {
                        return 1
                    }
                }
            }
            project {
                if {[containsBlock [list [lindex $expr 1]]]} {
                    return 1
                }
            }
            handle {
                if {[containsBlock [list [lindex $expr 1]]]} {
                    return 1
                }
                foreach {name handlerBlock} [lrange $expr 2 end] {
                    if {[containsBlock [blockBody $handlerBlock]]} {
                        return 1
                    }
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
        listloop {
            check [lindex $node 1] $context
            set inner [dict replace $context loop 1]
            foreach expr [blockBody [lindex $node 2]] {
                check $expr $inner
            }
        }
        countloop {
            check [lindex $node 1] $context
            check [lindex $node 2] $context
            set inner [dict replace $context loop 1]
            foreach expr [blockBody [lindex $node 3]] {
                check $expr $inner
            }
        }
        lockloop {
            foreach domain [lindex $node 1] {
                foreach operand [lrange $domain 1 [expr {[lindex $domain 0] eq "list" ? 1 : 2}]] {
                    check $operand $context
                }
            }
            set inner [dict replace $context loop 1]
            foreach expr [blockBody [lindex $node 2]] {
                check $expr $inner
            }
        }
        fail {
            if {[llength $node] == 3} {
                check [lindex $node 2] $context
            }
        }
        struct {
            foreach {name value} [lrange $node 2 end] {
                check $value $context
            }
        }
        project {
            check [lindex $node 1] $context
        }
        handle {
            check [lindex $node 1] $context
            foreach {name handlerBlock} [lrange $node 2 end] {
                foreach expr [blockBody $handlerBlock] {
                    check $expr $context
                }
            }
        }
    }
    return
}
