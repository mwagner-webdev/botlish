# parser.tcl -- Botlish source to surface AST (ast.tcl).
#
#   surface::parse SOURCE ?FILENAME? ?-recover 1?     => program node
#
# Recursive descent over the tokens of lexer.tcl. The grammar, with layout
# already turned into NEWLINE / INDENT / DEDENT tokens:
#
#   program      = [ namespaceDecl ] { NEWLINE | topStatement } EOF
#   namespaceDecl = "namespace" IDENT NEWLINE
#   topStatement = typeDecl | errorDecl | statement
#   statement    = simple NEWLINE | valued | function | if | loop
#   simple       = binding | return | break | continue | fail | expression
#   valued       = IDENT "=" (if|loop|handledExpr)
#                | "return" (if|loop|handledExpr)
#   handledExpr  = expression [ handlers ]     -- handlers only after a bare
#                                                  call expression (item 9)
#   handlers     = ":" NEWLINE INDENT { "on" IDENT ":" suite } DEDENT
#   function     = "fn" IDENT "(" [ param { "," param } [ "," ] ] ")"
#                  [ "->" IDENT ] [ "errors" IDENT { "," IDENT } ] ":" suite
#   param        = IDENT [ ":" IDENT ]
#   if           = "if" expression ":" suite [ "else" ":" suite ]
#   loop         = "loop" [ IDENT ( "in" expression | "from" expression "to" expression ) ] ":" suite
#   suite        = NEWLINE INDENT { NEWLINE | statement } DEDENT
#   binding      = IDENT "=" expression
#   return       = "return" [ expression ]
#   break        = "break"          -- PAYLOAD-FREE-BREAK.md: never a value,
#                                       in any loop kind, at the surface
#                                       level ("break EXPR" is a syntax
#                                       error, not merely rejected later)
#   continue     = "continue"
#   fail         = "fail" IDENT
#
#   typeDecl     = "type" IDENT "=" IDENT "in" domain NEWLINE
#   domain       = signedInt ".." signedInt
#                | "{" signedInt { "," signedInt } [ "," ] "}"
#   signedInt    = [ "-" ] INT
#
#   errorDecl    = "error" IDENT NEWLINE
#
# A handled call (EXPLICIT-ERROR-COMPLETIONS.md) is a bare call expression
# immediately followed by ":" and an indented block of "on NAME:" handlers,
# in exactly the same "statement value" position an if/loop value is (the
# right side of "=", or the value of "return"; not "break", which is never
# valued -- PAYLOAD-FREE-BREAK.md) -- ValueOrHandled
# (surface/parser.tcl) parses an ordinary expression first and only then
# checks for a trailing ":", so no new expression-grammar ambiguity is
# introduced (a `:` after any other expression shape remains a plain syntax
# error, exactly as before this feature). An error declaration is a
# declaration, not a statement with runtime meaning, exactly like typeDecl
# above -- legal only at a program's or module's own top level.
#
# A typeDecl is a declaration, not a statement with runtime meaning (see
# surface/ast.tcl's `typedecl` node and hir/sourcetypes.tcl): it is only
# legal directly at a program's or module's own top level, never nested in
# a function/if/loop suite -- Statement rejects it there, using Parser
# state's own `topLevel` flag (set/cleared around Suite, below). The "in"
# of a domain is not a reserved word: it is recognized contextually,
# immediately after a typeDecl's parent type name, exactly the way "->"
# result-type parsing here is contextual (allowFunctionResult) rather than
# a global keyword reservation -- `loop`'s own "in" (an element-binding
# List traversal, "loop x in EXPR:") reuses this identical contextual
# recognition, immediately after the loop variable's name (Loop, below).
# `loop`'s ascending counted form ("loop i from START to END:", R2A3-
# COUNTED-LOOPS-FINAL-SOURCE.md) extends this same one-token-of-lookahead
# dispatch: "from"/"to" (and the reserved-for-later "down"/"through"/"by")
# are recognized the same contextual way, never added to the lexer's
# keyword table, so none of them are reserved anywhere outside a loop
# header. "type" itself is different: it *is* a
# reserved keyword (lexer.tcl), since auditing the existing corpus (see
# SOURCE-DEFINED-INTEGER-DOMAINS.md) found no program using "type" or "in"
# as an ordinary name.
#
#   expression   = disjunction
#   disjunction  = conjunction { "or" conjunction }
#   conjunction  = inversion { "and" inversion }
#   inversion    = "not" inversion | comparison
#   comparison   = additive [ ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) additive ]
#   additive     = multiplicative { ( "+" | "-" ) multiplicative }
#   multiplicative = unary { "*" unary }
#   unary        = "-" unary | postfix
#   postfix      = primary { "(" [ arguments ] ")" }
#   arguments    = expression { "," expression } [ "," ]
#   primary      = INT | STRING | CHAR | "true" | "false" | "unit"
#                | IDENT [ "::" IDENT ]
#                | "[" [ arguments ] "]" | "(" expression ")"
#
# An if (or a loop, including "loop x in EXPR:") is a value where a
# statement's value ends the statement: the right side of a binding, or the
# value of return (`x = if c:` or `x = loop c in EXPR:`, each followed by
# its suite(s)) -- never a nested expression (e.g. a call argument), and
# never break's own value, since break has none (PAYLOAD-FREE-BREAK.md).
# Binary arithmetic, and and or are left-associative; comparisons do not
# chain.
#
# Without -recover, the first syntax error (lexical or grammatical) is raised
# ({SURFACE SYNTAX DIAGNOSTIC}). With -recover 1 parsing always returns a
# program: a statement that fails to parse becomes an `error` node, parsing
# resumes after the line (and any block indented under it), and the
# program's `diagnostics` lists every lexical and syntax error in source
# order.
#
# Parser state is a dict {tokens pos last recover diagnostics}: LAST is the
# span of the last consumed token that is not layout, used to end node spans.

namespace eval surface::parser {
    variable comparisons {== != < <= > >=}
}

proc surface::parse {source args} {
    set filename <input>
    if {[llength $args] % 2} {
        set args [lassign $args filename]
    }
    set options [dict create -recover 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::parse: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set recover [dict get $options -recover]
    set lexed [surface::lexer::tokenize $source $filename]
    if {!$recover} {
        foreach diagnostic [dict get $lexed diagnostics] {
            surface::raise $diagnostic
        }
    }
    set program [surface::parseTokens [dict get $lexed tokens] -recover $recover]
    set all [concat [dict get $lexed diagnostics] [dict get $program diagnostics]]
    set decorated [lmap diagnostic $all {list [dict get $diagnostic start] $diagnostic}]
    dict set program diagnostics [lmap entry [lsort -integer -index 0 $decorated] {lindex $entry 1}]
    return [surface::ast::assignIds $program]
}

# The program node of TOKENS (without ids); -recover as for surface::parse.
proc surface::parseTokens {tokens args} {
    set options [dict create -recover 0]
    foreach {option value} $args {
        dict set options $option $value
    }
    set p [dict create tokens $tokens pos 0 last [dict get [lindex $tokens 0] span] \
        recover [dict get $options -recover] diagnostics {} topLevel 1]
    set program [surface::parser::Program p]
    dict set program diagnostics [dict get $p diagnostics]
    return $program
}

# ---------------------------------------------------------------------------
# Token access

proc surface::parser::Peek {pVar {ahead 0}} {
    upvar 1 $pVar p
    set tokens [dict get $p tokens]
    set i [expr {min([dict get $p pos] + $ahead, [llength $tokens] - 1)}]
    return [lindex $tokens $i]
}

proc surface::parser::Kind {pVar {ahead 0}} {
    upvar 1 $pVar p
    return [dict get [Peek p $ahead] kind]
}

proc surface::parser::Advance {pVar} {
    upvar 1 $pVar p
    set token [Peek p]
    if {[dict get $token kind] ne "EOF"} {
        dict incr p pos
    }
    if {[dict get $token kind] ni {NEWLINE INDENT DEDENT EOF}} {
        dict set p last [dict get $token span]
    }
    return $token
}

# How TOKEN is named in messages.
proc surface::parser::Describe {token} {
    switch -- [dict get $token kind] {
        NEWLINE { return "end of line" }
        INDENT  { return "indentation" }
        DEDENT  { return "end of block" }
        EOF     { return "end of file" }
        IDENT   { return "name \"[dict get $token text]\"" }
        INT     { return "integer [dict get $token text]" }
        STRING  { return "string [dict get $token text]" }
        CHAR    { return "character [dict get $token text]" }
        default { return "\"[dict get $token text]\"" }
    }
}

proc surface::parser::Fail {token message} {
    surface::syntaxError [dict get $token span] $message
}

# Consumes a token of KIND, or fails with "expected WHAT, found ...".
proc surface::parser::Expect {pVar kind what} {
    upvar 1 $pVar p
    set token [Peek p]
    if {[dict get $token kind] ne $kind} {
        Fail $token "expected $what, found [Describe $token]"
    }
    return [Advance p]
}

# The span from START (a span) to the last consumed token.
proc surface::parser::SpanFrom {pVar start} {
    upvar 1 $pVar p
    return [surface::ast::cover $start [dict get $p last]]
}

# ---------------------------------------------------------------------------
# Statements and recovery

proc surface::parser::Program {pVar} {
    upvar 1 $pVar p
    set start [dict get [Peek p] span]
    set namespaceName ""
    set namespaceSpan ""
    while {[Kind p] eq "NEWLINE"} {
        Advance p
    }
    if {[Kind p] eq "namespace"} {
        lassign [NamespaceDecl p] namespaceName namespaceSpan
    }
    set body [Statements p {EOF}]
    set end [dict get [Peek p] span]
    return [surface::ast::node program [surface::ast::cover $start $end] body $body \
        namespace $namespaceName namespaceSpan $namespaceSpan]
}

# "namespace" IDENT NEWLINE, as the very first statement of a file (a
# declaration, not an ordinary statement: it introduces no HIR node -- see
# surface/modules.tcl). Returns {NAME SPAN}.
proc surface::parser::NamespaceDecl {pVar} {
    upvar 1 $pVar p
    Advance p
    set name [Expect p IDENT "a namespace name after \"namespace\""]
    set token [Peek p]
    if {[dict get $token kind] ne "NEWLINE"} {
        Fail $token "expected end of line, found [Describe $token]"
    }
    Advance p
    return [list [dict get $name value] [dict get $name span]]
}

# Statements up to a token of a kind in STOP (not consumed).
proc surface::parser::Statements {pVar stop} {
    upvar 1 $pVar p
    set body {}
    while {[Kind p] ni $stop} {
        if {[Kind p] eq "NEWLINE"} {
            Advance p
            continue
        }
        set token [Peek p]
        if {![catch {Statement p} statement options]} {
            lappend body $statement
            continue
        }
        if {![dict get $p recover] || [lrange [dict get $options -errorcode] 0 1] ne {SURFACE SYNTAX}} {
            return -options $options $statement
        }
        dict lappend p diagnostics [lindex [dict get $options -errorcode] 2]
        set before [dict get $p pos]
        Synchronize p
        if {[dict get $p pos] == $before && [Kind p] ni [concat $stop EOF]} {
            Advance p
        }
        set end [expr {[dict get $p last start] >= [dict get $token span start]
            ? [dict get $p last] : [dict get $token span]}]
        lappend body [surface::ast::node error [surface::ast::cover [dict get $token span] $end]]
    }
    return $body
}

# Skips to the start of the next statement: past the end of the current line
# and any block indented under it, or to the end of the enclosing block.
proc surface::parser::Synchronize {pVar} {
    upvar 1 $pVar p
    while 1 {
        switch -- [Kind p] {
            EOF - DEDENT {
                return
            }
            NEWLINE {
                Advance p
                if {[Kind p] eq "INDENT"} {
                    SkipBlock p
                }
                return
            }
            INDENT {
                SkipBlock p
                return
            }
            default {
                Advance p
            }
        }
    }
}

# Skips an INDENT and everything up to its matching DEDENT.
proc surface::parser::SkipBlock {pVar} {
    upvar 1 $pVar p
    set depth 0
    while {[Kind p] ne "EOF"} {
        switch -- [Kind p] {
            INDENT { incr depth }
            DEDENT { incr depth -1 }
        }
        Advance p
        if {$depth == 0} {
            return
        }
    }
}

proc surface::parser::Statement {pVar} {
    upvar 1 $pVar p
    set token [Peek p]
    switch -- [dict get $token kind] {
        fn     { return [Function p] }
        if     { return [If p] }
        loop   { return [Loop p] }
        type {
            if {![dict get $p topLevel]} {
                Fail $token "a type declaration is only allowed at the top level of a module, not nested in a function/if/loop"
            }
            return [TypeDecl p]
        }
        error {
            if {![dict get $p topLevel]} {
                Fail $token "an error declaration is only allowed at the top level of a module, not nested in a function/if/loop"
            }
            return [ErrorDecl p]
        }
        INDENT { Fail $token "unexpected indentation" }
        else   { Fail $token "\"else\" without a matching \"if\"" }
        namespace { Fail $token "a \"namespace\" declaration must be the first statement in the file" }
    }
    set statement [Simple p]
    if {[dict get $statement kind] eq "handledcall"} {
        # The handler suite(s) already ended the line.
        return $statement
    }
    if {[dict get $statement kind] in {bind return}
            && [dict get $statement value] ne ""
            && [dict get $statement value kind] in {if loop handledcall}} {
        # The if's (or loop's, or the handler suite's) suite(s) already
        # ended the line. break is deliberately excluded here (unlike
        # bind/return): PAYLOAD-FREE-BREAK.md -- break never has a value, so
        # its own Simple case above already ends the statement, before this
        # check ever runs.
        return $statement
    }
    set next [Peek p]
    if {[dict get $next kind] ne "NEWLINE"} {
        if {[dict get $next kind] eq "=" && [dict get $statement kind] ne "bind"} {
            Fail $next "only a name can be bound with \"=\""
        }
        Fail $next "expected end of line, found [Describe $next]"
    }
    Advance p
    return $statement
}

proc surface::parser::Simple {pVar} {
    upvar 1 $pVar p
    set token [Peek p]
    set start [dict get $token span]
    switch -- [dict get $token kind] {
        IDENT {
            if {[Kind p 1] eq "="} {
                Advance p
                Advance p
                set value [ValueOrHandled p]
                return [surface::ast::node bind [SpanFrom p $start] \
                    name [dict get $token value] nameSpan $start value $value]
            }
        }
        return {
            Advance p
            set value ""
            if {[Kind p] ni {NEWLINE DEDENT EOF}} {
                set value [ValueOrHandled p]
            }
            return [surface::ast::node return [SpanFrom p $start] value $value]
        }
        break {
            # PAYLOAD-FREE-BREAK.md: break never carries a value, in any
            # loop kind, at the surface level -- unlike return, nothing
            # after "break" is ever parsed as an expression (so a would-be
            # payload's side effects, including a call, are never even
            # attempted; see that report's "payload expression must never
            # execute"). This is the sole enforcement point for the
            # language-level rule; nothing below the parser (HIR, core IR)
            # needs its own copy of it for ordinary Botlish programs, since
            # no valid parse can ever produce a break AST node with a value.
            Advance p
            if {[Kind p] ni {NEWLINE DEDENT EOF}} {
                Fail [Peek p] "\"break\" does not take a value, found [Describe [Peek p]]"
            }
            return [surface::ast::node break [SpanFrom p $start] value ""]
        }
        continue {
            Advance p
            return [surface::ast::node continue $start]
        }
        fail {
            Advance p
            set name [Expect p IDENT "an error name after \"fail\""]
            return [surface::ast::node fail [SpanFrom p $start] \
                name [dict get $name value] nameSpan [dict get $name span]]
        }
    }
    return [ValueOrHandled p]
}

# A statement's value: an if, a loop, a handled call, or a plain expression
# (EXPLICIT-ERROR-COMPLETIONS.md item 34: a bare handled-call expression-
# statement falls out of this same shared path with no extra grammar).
proc surface::parser::ValueOrHandled {pVar} {
    upvar 1 $pVar p
    if {[Kind p] in {if loop}} {
        return [Value p]
    }
    set expr [Expression p]
    if {[Kind p] eq ":" && [dict get $expr kind] eq "call"} {
        return [HandledCall p $expr]
    }
    return $expr
}

# The handler suite(s) of CALL: ":" NEWLINE INDENT { "on" IDENT ":" suite }
# DEDENT (EXPLICIT-ERROR-COMPLETIONS.md items 9/13). Handlers are restricted
# to a direct call expression (CALL), per item 9's first-implementation
# scope.
proc surface::parser::HandledCall {pVar call} {
    upvar 1 $pVar p
    set start [dict get $call span]
    Advance p
    set token [Peek p]
    if {[dict get $token kind] ne "NEWLINE"} {
        Fail $token "expected a new line and an indented block of \"on\" handlers after \":\", found [Describe $token]"
    }
    Advance p
    set indentToken [Peek p]
    if {[dict get $indentToken kind] ne "INDENT"} {
        Fail $indentToken "expected an indented block of \"on\" handlers, found [Describe $indentToken]"
    }
    Advance p
    set handlers {}
    while {[Kind p] ne "DEDENT"} {
        if {[Kind p] eq "NEWLINE"} {
            Advance p
            continue
        }
        set onToken [Peek p]
        if {[dict get $onToken kind] ne "on"} {
            Fail $onToken "expected \"on\" (a handler for a declared error), found [Describe $onToken]"
        }
        Advance p
        set name [Expect p IDENT "an error name after \"on\""]
        set body [Suite p "the error name"]
        lappend handlers [dict create name [dict get $name value] nameSpan [dict get $name span] body $body]
    }
    Advance p
    if {$handlers eq {}} {
        Fail [Peek p] "a handled call needs at least one \"on\" handler"
    }
    return [surface::ast::node handledcall [SpanFrom p $start] call $call handlers $handlers]
}

# A statement's value: an if, a loop, or an expression.
proc surface::parser::Value {pVar} {
    upvar 1 $pVar p
    if {[Kind p] eq "if"} {
        return [If p]
    }
    if {[Kind p] eq "loop"} {
        return [Loop p]
    }
    return [Expression p]
}

# TypeName [ "[" TypeExpr "]" ] -- a possibly-applied type expression
# (MINIMAL-APPLIED-LIST-TYPES.md). A bare name (no "[...]") is returned as
# the plain name string, exactly as before this feature (so every existing
# bare-type-name consumer -- surface::ast::showType, hir::resolve, and every
# test that reads a param/result type as a plain string -- is unaffected);
# an applied type is a {NAME ARG} pair, ARG itself a TypeExpr, recursively
# representable ("List[List[Small]]" needs no separate grammar). The parser
# is generic over the head name: it does not know "List" is special. Only
# one type argument is ever parsed (no "A[X, Y]"): resolution (hir::resolve
# ::ResolveTypeExpr) decides whether a name is a registered constructor and
# checks its own arity against however many arguments this grammar can ever
# produce (one), so "List[A, B]" is already a syntax error here, and a
# constructor of higher arity would need no grammar change, only another
# constructor-side arity number.
#
# "Fn" is the one head name the parser does know: it introduces a
# structural function type (STRUCTURAL-FUNCTION-TYPES.md), whose named
# fields are dedicated grammar (FnType), never an applied type argument --
# so "Fn[...]" (a positional function type) and a bare "Fn" are syntax
# errors here, each with its own message.
proc surface::parser::TypeExpr {pVar what} {
    upvar 1 $pVar p
    set token [Expect p IDENT $what]
    set name [dict get $token value]
    if {$name eq "Fn"} {
        return [FnType p $token]
    }
    if {[Kind p] ne "\["} {
        return $name
    }
    Advance p
    set arg [TypeExpr p "a type argument after \"\["]
    Expect p \] "\"\]\" after the type argument"
    return [list $name $arg]
}

# "Fn" "{" fnField { "," fnField } [ "," ] "}", after the "Fn" token FN:
#
#   fnField = "args" ":" "[" [ TypeExpr { "," TypeExpr } [ "," ] ] "]"
#           | "return" ":" TypeExpr
#           | "errors" ":" "[" [ IDENT { "," IDENT } [ "," ] ] "]"
#
# A structural function type's call contract (STRUCTURAL-FUNCTION-TYPES.md).
# Fields are named, so they may come in any order; each at most once.
# "args" and "return" are required; an omitted "errors" means errors: []
# -- exactly what an omitted "errors" clause means on a "fn" declaration (no
# declared error may escape), never "unchecked errors". Newlines inside the
# braces are free (the lexer treats "{" like "(" and "["). Returns the
# TypeExpr {fn FIELDS}, FIELDS a dict {args {TYPEEXPR...} return TYPEEXPR
# errors {NAME...}} in canonical field order: "fn" is a keyword, so this
# pair can never be mistaken for an applied type {NAME ARG}. Adding a field
# later (the planned `context`) is one more case below.
proc surface::parser::FnType {pVar fn} {
    upvar 1 $pVar p
    set usage "Fn{args: \[...\], return: ..., errors: \[...\]}"
    if {[Kind p] eq "\["} {
        Fail [Peek p] "a function type has named fields, not positional type arguments: write $usage"
    }
    if {[Kind p] ne "\{"} {
        Fail [Peek p] "expected \"\{\" after \"Fn\" (a function type is written $usage), found [Describe [Peek p]]"
    }
    set open [Advance p]
    set fields [dict create]
    while {[Kind p] ne "\}"} {
        set token [Peek p]
        switch -- [dict get $token kind] {
            IDENT - return - errors {
                set field [expr {[dict get $token kind] eq "IDENT" ? [dict get $token value] : [dict get $token kind]}]
            }
            default {
                Fail $token "expected a field name (args, return or errors) in the function type, found [Describe $token]"
            }
        }
        if {$field ni {args return errors}} {
            if {$field in {target targets}} {
                Fail $token "a function type cannot name its target: \"$field\" is not a field (a function type describes only the call contract: args, return, errors)"
            }
            if {$field eq "context"} {
                Fail $token "the function type field \"context\" is not supported yet (fields: args, return, errors)"
            }
            Fail $token "unknown field \"$field\" in the function type (fields: args, return, errors)"
        }
        if {[dict exists $fields $field]} {
            Fail $token "duplicate field \"$field\" in the function type"
        }
        Advance p
        if {[Kind p] ne ":"} {
            Fail [Peek p] "expected \":\" after the function type field \"$field\", found [Describe [Peek p]]"
        }
        Advance p
        switch -- $field {
            args {
                dict set fields args [FnList p args {
                    TypeExpr p "a parameter type in the \"args\" list"
                }]
            }
            return {
                dict set fields return [TypeExpr p "a type after \"return:\""]
            }
            errors {
                set names [FnList p errors {
                    set name [Expect p IDENT "an error name in the \"errors\" list"]
                    if {[Kind p] eq "\["} {
                        Fail [Peek p] "the \"errors\" list names declared errors, not types: expected \",\" or \"\]\" after the error name \"[dict get $name value]\""
                    }
                    list [dict get $name value] $name
                }]
                set seen {}
                foreach pair $names {
                    lassign $pair name nameToken
                    if {$name in $seen} {
                        Fail $nameToken "duplicate error \"$name\" in the function type's \"errors\" list"
                    }
                    lappend seen $name
                }
                dict set fields errors $seen
            }
        }
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne "\}"} {
            Fail [Peek p] "expected \",\" or \"\}\" after the function type field \"$field\", found [Describe [Peek p]]"
        }
    }
    set close [Peek p]
    foreach required {args return} {
        if {![dict exists $fields $required]} {
            Fail $close "the function type is missing its \"$required\" field ($usage)"
        }
    }
    Advance p
    if {![dict exists $fields errors]} {
        dict set fields errors {}
    }
    return [list fn [dict create args [dict get $fields args] return [dict get $fields return] \
        errors [dict get $fields errors]]]
}

# "[" [ ITEM { "," ITEM } [ "," ] ] "]" for function type field FIELD, each
# ITEM parsed by the script ITEM (in the caller's frame, with p visible).
# Returns the items' values.
proc surface::parser::FnList {pVar field item} {
    upvar 1 $pVar p
    if {[Kind p] ne "\["} {
        set what [expr {$field eq "args" ? "a list of parameter types" : "a list of declared error names"}]
        Fail [Peek p] "the \"$field\" field of a function type must be $what in \"\[...\]\", found [Describe [Peek p]]"
    }
    Advance p
    set items {}
    while {[Kind p] ne "\]"} {
        lappend items [eval $item]
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne "\]"} {
            Fail [Peek p] "expected \",\" or \"\]\" in the \"$field\" list, found [Describe [Peek p]]"
        }
    }
    Advance p
    return $items
}

proc surface::parser::Function {pVar} {
    upvar 1 $pVar p
    dict set p allowFunctionResult 1
    set start [dict get [Advance p] span]
    set name [Expect p IDENT "a function name after \"fn\""]
    set open [Expect p ( "\"(\" after the function name"]
    set params {}
    while {[Kind p] ne ")"} {
        set param [Expect p IDENT "a parameter name"]
        set type ""
        set typeSpan ""
        if {[Kind p] eq ":"} {
            Advance p
            set typeStart [dict get [Peek p] span]
            set type [TypeExpr p "a parameter type after \":\""]
            set typeSpan [SpanFrom p $typeStart]
        }
        lappend params [list [dict get $param value] [dict get $param span] $type $typeSpan]
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne ")"} {
            Fail [Peek p] "expected \",\" or \")\" in the parameter list, found [Describe [Peek p]]"
        }
    }
    Advance p
    set body [Suite p "the parameter list"]
    return [surface::ast::node function [SpanFrom p $start] \
        name [dict get $name value] nameSpan [dict get $name span] \
        params $params paramsSpan [SpanFrom p [dict get $open span]] \
        resultType [dict get $body resultType] resultTypeSpan [dict get $body resultTypeSpan] \
        errors [dict get $body errors] body $body]
}

# "error" IDENT NEWLINE -- a top-level named-error declaration (see this
# file's own header, and hir/errordecls.tcl for what it means). Only legal
# directly at a program's or module's own top level, exactly like a
# typeDecl (Statement rejects it elsewhere, using the same `topLevel` flag).
proc surface::parser::ErrorDecl {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set name [Expect p IDENT "an error name after \"error\""]
    set node [surface::ast::node errordecl [SpanFrom p $start] \
        name [dict get $name value] nameSpan [dict get $name span]]
    set next [Peek p]
    if {[dict get $next kind] ne "NEWLINE"} {
        Fail $next "expected end of line, found [Describe $next]"
    }
    Advance p
    return $node
}

# "type" IDENT "=" IDENT "in" domain NEWLINE -- a top-level type declaration
# (see this file's own header, and hir/sourcetypes.tcl for what it means).
# "in" is not a keyword: it is the ordinary IDENT expected right here, by
# spelling, immediately after the parent type name (deliberately, so "in"
# stays free for ordinary use everywhere else -- see #49 in
# SOURCE-DEFINED-INTEGER-DOMAINS.md).
proc surface::parser::TypeDecl {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set name [Expect p IDENT "a type name after \"type\""]
    Expect p = "\"=\" after the type name"
    set parent [Expect p IDENT "a parent type name"]
    set inToken [Peek p]
    if {[dict get $inToken kind] ne "IDENT" || [dict get $inToken value] ne "in"} {
        Fail $inToken "expected \"in\" after the parent type name, found [Describe $inToken]"
    }
    Advance p
    set domain [Domain p]
    set node [surface::ast::node typedecl [SpanFrom p $start] \
        name [dict get $name value] nameSpan [dict get $name span] \
        parent [dict get $parent value] parentSpan [dict get $parent span] \
        domain $domain]
    set next [Peek p]
    if {[dict get $next kind] ne "NEWLINE"} {
        Fail $next "expected end of line, found [Describe $next]"
    }
    Advance p
    return $node
}

# signedInt ".." signedInt | "{" signedInt { "," signedInt } [ "," ] "}"
proc surface::parser::Domain {pVar} {
    upvar 1 $pVar p
    if {[Kind p] eq "\{"} {
        return [ExactDomain p]
    }
    set start [dict get [Peek p] span]
    set lo [SignedInt p]
    if {[Kind p] ne ".."} {
        Fail [Peek p] "expected \"..\" or \"\{\" in a type declaration's domain, found [Describe [Peek p]]"
    }
    Advance p
    set hi [SignedInt p]
    return [dict create kind interval \
        lo [lindex $lo 0] loSpan [lindex $lo 1] \
        hi [lindex $hi 0] hiSpan [lindex $hi 1] \
        span [surface::ast::cover $start [dict get $p last]]]
}

proc surface::parser::ExactDomain {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set values {}
    set spans {}
    while {[Kind p] ne "\}"} {
        lassign [SignedInt p] value span
        lappend values $value
        lappend spans $span
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne "\}"} {
            Fail [Peek p] "expected \",\" or \"\}\" in the type domain, found [Describe [Peek p]]"
        }
    }
    if {$values eq ""} {
        Fail [Peek p] "a type declaration's finite domain must not be empty"
    }
    Advance p
    return [dict create kind exact values $values spans $spans \
        span [surface::ast::cover $start [dict get $p last]]]
}

# The decimal text and span of an optionally negative integer literal, as
# {TEXT SPAN}. Only a literal: no arithmetic, no named constant, no call --
# a type declaration's domain is dedicated grammar, not an ordinary
# expression (see this file's own header).
proc surface::parser::SignedInt {pVar} {
    upvar 1 $pVar p
    set start [dict get [Peek p] span]
    set negative 0
    if {[Kind p] eq "-"} {
        Advance p
        set negative 1
    }
    set token [Expect p INT "an integer literal"]
    set text [dict get $token value]
    if {$negative && $text ne "0"} {
        set text -$text
    }
    return [list $text [SpanFrom p $start]]
}

proc surface::parser::If {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set condition [Expression p]
    set then [Suite p "the \"if\" condition"]
    set else ""
    if {[Kind p] eq "else"} {
        Advance p
        set else [Suite p "\"else\""]
    }
    return [surface::ast::node if [SpanFrom p $start] \
        condition $condition then $then else $else]
}

# "in" (a List-traversal loop, "loop x in EXPR:") and "from"/"to" (an
# ascending counted loop, "loop i from START to END:") are both recognized
# contextually, exactly like TypeDecl's own "in" (see this file's header
# comment) -- neither is a lexer keyword, so a program is free to use "from",
# "to", "down", "through" or "by" as an ordinary name anywhere else. Which
# form applies is decided by a single token of lookahead right after the
# loop variable's own name: "in" or "from" dispatch to the corresponding
# form; "down" is the reserved (not yet implemented) descending form (spec
# item 22); anything else is a malformed header. "through" (an inclusive
# end, item 23) and "by" (an explicit step, item 24) are recognized the same
# contextual way, immediately after the counted form's start/end
# expressions, and rejected with a "reserved, not implemented yet"
# diagnostic rather than silently parsed as "to" or accepted and ignored.
proc surface::parser::Loop {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set elementName ""
    set elementNameSpan ""
    set iterable ""
    set countName ""
    set countNameSpan ""
    set countStart ""
    set countEnd ""
    if {[Kind p] eq "IDENT"} {
        set nameToken [Advance p]
        set name [dict get $nameToken value]
        set nameSpan [dict get $nameToken span]
        set dispatch [Peek p]
        set dispatchWord [expr {[dict get $dispatch kind] eq "IDENT" ? [dict get $dispatch value] : ""}]
        switch -- $dispatchWord {
            in {
                set elementName $name
                set elementNameSpan $nameSpan
                Advance p
                set iterable [Expression p]
            }
            from {
                set countName $name
                set countNameSpan $nameSpan
                Advance p
                set startToken [Peek p]
                if {[dict get $startToken kind] eq "IDENT" && [dict get $startToken value] eq "to"} {
                    Fail $startToken "expected an expression (the loop's start value)\
                        after \"from\", found [Describe $startToken]"
                }
                set countStart [Expression p]
                set toToken [Peek p]
                set toWord [expr {[dict get $toToken kind] eq "IDENT" ? [dict get $toToken value] : ""}]
                if {$toWord eq "through"} {
                    Fail $toToken "\"through\" (an inclusive loop end) is reserved for a future\
                        counted-loop form; \"to\" (exclusive) is the only supported end keyword"
                }
                if {$toWord ne "to"} {
                    Fail $toToken "expected \"to\" after the loop start value, found [Describe $toToken]"
                }
                Advance p
                set countEnd [Expression p]
                set afterToken [Peek p]
                set afterWord [expr {
                    [dict get $afterToken kind] eq "IDENT" ? [dict get $afterToken value] : ""
                }]
                if {$afterWord eq "by"} {
                    Fail $afterToken "\"by\" (an explicit step) is reserved for a future counted-loop\
                        form; a counted loop always steps by 1"
                }
            }
            down {
                Fail $dispatch "\"down from\" (a descending loop) is reserved for a future counted-loop\
                    form; use \"from START to END\" (ascending) instead"
            }
            default {
                Fail $dispatch "expected \"in\" or \"from\" after the loop variable, found [Describe $dispatch]"
            }
        }
    }
    set body [Suite p "\"loop\""]
    return [surface::ast::node loop [SpanFrom p $start] \
        elementName $elementName elementNameSpan $elementNameSpan iterable $iterable \
        countName $countName countNameSpan $countNameSpan countStart $countStart countEnd $countEnd \
        body $body]
}

# ":" NEWLINE INDENT statements DEDENT, after AFTER (for messages).
proc surface::parser::Suite {pVar after} {
    upvar 1 $pVar p
    set resultType {}
    set resultTypeSpan {}
    set allowResult [expr {[dict exists $p allowFunctionResult] && [dict get $p allowFunctionResult]}]
    dict set p allowFunctionResult 0
    if {$allowResult && [Kind p] eq {->}} {
        Advance p
        set typeStart [dict get [Peek p] span]
        set resultType [TypeExpr p {a result type after ->}]
        set resultTypeSpan [SpanFrom p $typeStart]
    }
    # A function's own "errors E1, E2" declaration (EXPLICIT-ERROR-
    # COMPLETIONS.md items 3/109): the single-line canonical spelling,
    # gated by the identical ALLOWRESULT flag as "->" just above -- it is
    # legal in exactly the same one position, right after an optional
    # result type and before the final ":".
    set errors {}
    if {$allowResult && [Kind p] eq {errors}} {
        Advance p
        while 1 {
            set nameToken [Expect p IDENT "an error name after \"errors\""]
            lappend errors [list [dict get $nameToken value] [dict get $nameToken span]]
            if {[Kind p] ne ","} {
                break
            }
            Advance p
        }
    }
    Expect p : "\":\" after $after"
    set token [Peek p]
    if {[dict get $token kind] ne "NEWLINE"} {
        Fail $token "expected a new line and an indented block after \":\", found [Describe $token]"
    }
    Advance p
    set token [Peek p]
    if {[dict get $token kind] ne "INDENT"} {
        Fail $token "expected an indented block, found [Describe $token]"
    }
    Advance p
    set start [dict get [Peek p] span]
    set savedTopLevel [dict get $p topLevel]
    dict set p topLevel 0
    set body [Statements p {DEDENT EOF}]
    dict set p topLevel $savedTopLevel
    if {[Kind p] eq "DEDENT"} {
        Advance p
    }
    if {$body eq ""} {
        # Every statement of the block was skipped by recovery.
        return [surface::ast::node suite $start body {} resultType $resultType resultTypeSpan $resultTypeSpan \
            errors $errors]
    }
    return [surface::ast::node suite [SpanFrom p $start] body $body resultType $resultType \
        resultTypeSpan $resultTypeSpan errors $errors]
}

# ---------------------------------------------------------------------------
# Expressions

proc surface::parser::Expression {pVar} {
    upvar 1 $pVar p
    return [Logical p or Conjunction]
}

proc surface::parser::Conjunction {pVar} {
    upvar 1 $pVar p
    return [Logical p and Inversion]
}

# OPERAND { OP OPERAND }, left-associative.
proc surface::parser::Logical {pVar op operand} {
    upvar 1 $pVar p
    set left [$operand p]
    while {[Kind p] eq $op} {
        set token [Advance p]
        set right [$operand p]
        set left [surface::ast::node logical \
            [surface::ast::cover [dict get $left span] [dict get $right span]] \
            op $op opSpan [dict get $token span] left $left right $right]
    }
    return $left
}

proc surface::parser::Inversion {pVar} {
    upvar 1 $pVar p
    if {[Kind p] eq "not"} {
        set op [Advance p]
        set operand [Inversion p]
        return [surface::ast::node not \
            [surface::ast::cover [dict get $op span] [dict get $operand span]] \
            opSpan [dict get $op span] operand $operand]
    }
    return [Comparison p]
}

proc surface::parser::Comparison {pVar} {
    upvar 1 $pVar p
    variable comparisons
    set left [Additive p]
    if {[Kind p] in $comparisons} {
        set op [Advance p]
        set right [Additive p]
        set left [Binary $op $left $right]
        if {[Kind p] in $comparisons} {
            Fail [Peek p] "comparison chaining is not supported"
        }
    }
    return $left
}

proc surface::parser::Binary {op left right} {
    return [surface::ast::node binary \
        [surface::ast::cover [dict get $left span] [dict get $right span]] \
        op [dict get $op kind] opSpan [dict get $op span] left $left right $right]
}

proc surface::parser::Additive {pVar} {
    upvar 1 $pVar p
    set left [Multiplicative p]
    while {[Kind p] in {+ -}} {
        set op [Advance p]
        set left [Binary $op $left [Multiplicative p]]
    }
    return $left
}

proc surface::parser::Multiplicative {pVar} {
    upvar 1 $pVar p
    set left [Unary p]
    while {[Kind p] eq "*"} {
        set op [Advance p]
        set left [Binary $op $left [Unary p]]
    }
    return $left
}

proc surface::parser::Unary {pVar} {
    upvar 1 $pVar p
    if {[Kind p] eq "-"} {
        set op [Advance p]
        set operand [Unary p]
        return [surface::ast::node unary \
            [surface::ast::cover [dict get $op span] [dict get $operand span]] \
            op - opSpan [dict get $op span] operand $operand]
    }
    return [Postfix p]
}

proc surface::parser::Postfix {pVar} {
    upvar 1 $pVar p
    set expr [Primary p]
    while {[Kind p] eq "("} {
        Advance p
        set args [Arguments p ) "argument list"]
        set expr [surface::ast::node call [SpanFrom p [dict get $expr span]] \
            callee $expr args $args]
    }
    return $expr
}

# Expressions separated by commas up to CLOSE (consumed), trailing comma
# allowed.
proc surface::parser::Arguments {pVar close what} {
    upvar 1 $pVar p
    set items {}
    while {[Kind p] ne $close} {
        lappend items [Expression p]
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne $close} {
            Fail [Peek p] "expected \",\" or \"$close\" in the $what, found [Describe [Peek p]]"
        }
    }
    Advance p
    return $items
}

proc surface::parser::Primary {pVar} {
    upvar 1 $pVar p
    set token [Peek p]
    set span [dict get $token span]
    switch -- [dict get $token kind] {
        INT {
            Advance p
            return [surface::ast::node int $span text [dict get $token value]]
        }
        STRING {
            Advance p
            return [surface::ast::node string $span value [dict get $token value]]
        }
        CHAR {
            Advance p
            return [surface::ast::node char $span text [dict get $token value]]
        }
        true - false {
            Advance p
            return [surface::ast::node bool $span value [dict get $token kind]]
        }
        unit {
            Advance p
            return [surface::ast::node unit $span]
        }
        IDENT {
            Advance p
            if {[Kind p] eq "::"} {
                Advance p
                set member [Expect p IDENT "a name after \"::\""]
                return [surface::ast::node qualname [SpanFrom p $span] \
                    namespace [dict get $token value] namespaceSpan $span \
                    name [dict get $member value] nameSpan [dict get $member span]]
            }
            return [surface::ast::node name $span name [dict get $token value]]
        }
        [ {
            Advance p
            set items [Arguments p \] "list"]
            return [surface::ast::node list [SpanFrom p $span] items $items]
        }
        ( {
            Advance p
            set expr [Expression p]
            Expect p ) "\")\""
            return $expr
        }
        if {
            Fail $token "an \"if\" value must be the whole right side of \"=\" or \"return\""
        }
    }
    Fail $token "expected an expression, found [Describe $token]"
}
