# lower.tcl -- surface AST to HIR.
#
#   surface::lowerToHir AST ?-strict 1|0?     => HIR program
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
#   f(a, b)               call f a b
#   a OP b                call ^OP a b              OP: + - * == < <= > >=
#   a != b                if (call ^== a b) {^false} {^true}
#   -a                    call ^- (const 0) a
#   not a                 if a {^false} {^true}
#   a and b               if a {if b {^true} {^false}} {^false}
#   a or b                if a {^true} {if b {^true} {^false}}
#   x = e                 bind x e
#   fn f(a, b): body      bind f (block (a b) body...)
#   if c: t else: e       if c {t...} {e...}    inline branches; a missing
#                         else is an empty branch (value unit)
#   loop: body            loop {body...}        inline body
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
    set options [dict create -strict 1]
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
    lassign [surface::lower::SplitTypeDecls [dict get $ast body]] executable decls
    set nodes [surface::lower::Sequence $executable]
    set hir [hir::buildSyntax $nodes -strict 0 \
        -origin [surface::lower::Origin [dict get $ast span] ""] \
        -files [dict create f1 [dict get $ast span file]] \
        -type-decls $decls]
    return [surface::lower::Finish $hir [dict get $options -strict]]
}

# STATEMENTS split into {EXECUTABLE DECLS}: EXECUTABLE keeps every statement
# with runtime meaning, in order (ready for Sequence); DECLS is the type
# declarations among them (surface/parser.tcl's `typedecl` nodes), converted
# to the plain dicts hir::buildSyntax's -type-decls option takes (see
# hir/sourcetypes.tcl) -- a type declaration is compile-time-only metadata,
# never lowered to an hir/syntax.tcl node (spec items 21-22: no bind, no
# runtime value, no NIR).
proc surface::lower::SplitTypeDecls {statements} {
    set executable {}
    set decls {}
    foreach statement $statements {
        if {[dict get $statement kind] eq "typedecl"} {
            lappend decls [TypeDeclOf $statement]
        } else {
            lappend executable $statement
        }
    }
    return [list $executable $decls]
}

proc surface::lower::TypeDeclOf {node} {
    return [dict create \
        name [dict get $node name] nameSpan [dict get $node nameSpan] \
        parent [dict get $node parent] parentSpan [dict get $node parentSpan] \
        domain [dict get $node domain] domainSpan [dict get $node domain span]]
}

# The tail both surface::lowerToHir and surface::modules::compileProgramFile
# (surface/modules.tcl) share: with STRICT 1, raise the first HIR diagnostic
# as a semantic error (with its source location); otherwise return HIR as
# built, diagnostics and all.
proc surface::lower::Finish {hir strict} {
    if {$strict} {
        foreach diagnostic [hir::diagnostics $hir] {
            core::semanticError [dict get $diagnostic kind] \
                "[surface::originLocation $hir [hir::get $hir [dict get $diagnostic expr] origin]]: [dict get $diagnostic message]"
        }
    }
    return $hir
}

# "FILE:LINE:COLUMN" of a source ORIGIN in HIR, or the origin itself.
proc surface::originLocation {hir origin} {
    if {[lindex $origin 0] ne "file"} {
        return $origin
    }
    set path [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
    set fields [lrange $origin 2 end]
    return "$path:[dict get $fields line]:[dict get $fields column]"
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

proc surface::lower::Sequence {nodes} {
    return [lmap node $nodes {Node $node}]
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
            set ref [hir::syntax::refNode $origin "[dict get $node namespace]::[dict get $node name]"]
            dict set ref qualified [list [dict get $node namespace] [dict get $node name]]
            return $ref
        }
        list {
            return [hir::syntax::callNode $origin \
                [hir::syntax::rootRef [OriginOf $node list] list] \
                {*}[Sequence [dict get $node items]]]
        }
        call {
            return [hir::syntax::callNode $origin [Node [dict get $node callee]] \
                {*}[Sequence [dict get $node args]]]
        }
        binary {
            set op [dict get $node op]
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            if {$op eq "!="} {
                set equal [hir::syntax::callNode $origin \
                    [hir::syntax::rootRef $opOrigin ==] \
                    [Node [dict get $node left]] [Node [dict get $node right]]]
                return [Branch $origin $equal [list [Bool $opOrigin false]] [list [Bool $opOrigin true]]]
            }
            return [hir::syntax::callNode $origin [hir::syntax::rootRef $opOrigin $op] \
                [Node [dict get $node left]] [Node [dict get $node right]]]
        }
        unary {
            set opOrigin [Origin [dict get $node opSpan] [dict get $node id]/op]
            return [hir::syntax::callNode $origin [hir::syntax::rootRef $opOrigin -] \
                [hir::syntax::constNode $opOrigin 0] [Node [dict get $node operand]]]
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
            set block [hir::syntax::blockNode \
                [Origin [dict get $node paramsSpan] [dict get $node id]/block] \
                $params [Sequence [dict get $node body body]] [dict get $node resultType] $paramTypes]
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
            if {[dict get $node value] eq ""} {
                return [hir::syntax::breakNode $origin]
            }
            return [hir::syntax::breakNode $origin [Node [dict get $node value]]]
        }
        continue {
            return [hir::syntax::continueNode $origin]
        }
    }
    error "surface::lowerToHir: cannot lower a \"[dict get $node kind]\" node"
}
