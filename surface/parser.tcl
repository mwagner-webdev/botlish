# parser.tcl -- Botlish source to surface AST (ast.tcl).
#
#   surface::parse SOURCE ?FILENAME? ?-recover 1?     => program node
#
# Recursive descent over the tokens of lexer.tcl. The grammar, with layout
# already turned into NEWLINE / INDENT / DEDENT tokens:
#
#   program      = [ namespaceDecl ] { importDecl } { NEWLINE | topStatement } EOF
#   namespaceDecl = "namespace" path NEWLINE
#   path         = IDENT { "::" IDENT }  -- a namespace: one or more segments
#   importDecl   = "import" path NEWLINE            -- a namespace import
#                | "import" "type" path NEWLINE     -- a type import: the path's
#                                                      last segment is a type name,
#                                                      so it has at least two
#                  -- the file header: after the namespace declaration, before
#                     anything else (IMPORTS.md). "import" is contextual, not a
#                     keyword: it starts an import only when immediately
#                     followed by a name or by "type", which no other
#                     construct allows, so `import` stays an ordinary name.
#   topStatement = typeDecl | structDecl | errorDecl | statement
#   statement    = simple NEWLINE | valued | function | if | loop
#   simple       = binding | destructure | return | break | continue | fail
#                | expression
#   valued       = IDENT "=" (if|loop|handledExpr)
#                | "return" (if|loop|handledExpr)
#   handledExpr  = expression [ handlers ]     -- handlers only after a bare
#                                                  call expression (item 9)
#   handlers     = ":" NEWLINE INDENT { "on" IDENT ":" suite } DEDENT
#   function     = "fn" IDENT "(" [ paramList ] ")"
#                  [ "->" IDENT ] [ "errors" IDENT { "," IDENT } ] ":" suite
#   paramList    = [ param { "," param } ] [ "," flagSection ] [ "," ]
#                  -- sections in canonical order: ordinary parameters, then
#                  flags (ParamSections)
#   param        = IDENT [ ":" IDENT ]
#   flagSection  = "flags" flagDecl { "," flagDecl }   -- FLAGS.md; "flags" is
#                  contextual: `flags :name` only (an ordinary name otherwise)
#   flagDecl     = ":" IDENT                          -- the name glued to ":"
#   if           = "if" expression ":" suite
#                  { "elif" expression ":" suite } [ "else" ":" suite ]
#   loop         = "loop" [ clause { "and" clause } ] ":" suite
#   clause       = IDENT "in" operand
#                | IDENT [ "down" ] "from" operand ( "to" | "through" ) operand
#                -- operand is an expression without a top-level "and"
#   suite        = NEWLINE INDENT { NEWLINE | statement } DEDENT
#   binding      = IDENT "=" expression
#   destructure  = "{" destructureField { "," destructureField } [ "," ] "}"
#                  "=" valueOrHandled      -- STRUCT-DESTRUCTURING.md
#   destructureField = IDENT | IDENT ":" IDENT | IDENT ":" "{" ... "}"
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
#   structDecl   = "struct" IDENT ":" NEWLINE INDENT structField { structField } DEDENT
#   structField  = IDENT ":" typeExpr NEWLINE
#
# A structDecl (STRUCTS.md) declares a nominal struct type: like a typeDecl
# it is a declaration, never a value binding, legal only at a program's or
# module's own top level, and its fields always carry an explicit type. A
# struct needs at least one field: Botlish has no explicit empty-block
# syntax (every suite is an INDENT of statements), and none is invented for
# a zero-field struct.
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
# `loop`'s numeric forms ("from A to B", "from A through B", "down from B
# to A", "down from B through A") and its lockstep composition with "and"
# extend this same one-token-of-lookahead dispatch (see Loop below):
# "from"/"down"/"to"/"through"/"by" are recognized the same contextual way,
# never added to the lexer's keyword table, so none of them are reserved
# anywhere outside a loop header. "type" itself is different: it *is* a
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
#   postfix      = primary { "(" [ callArgs ] ")" | "." IDENT [ "(" [ callArgs ] ")" ] }
#   callArgs     = [ expression { "," expression } ] [ "," flag { "," flag } ] [ "," ]
#                  -- a flag (":" IDENT, glued) is only valid in this position
#                  and only after every ordinary argument (FLAGS.md)
#   arguments    = expression { "," expression } [ "," ]       -- list literals
#   primary      = INT | STRING | CHAR | "true" | "false" | "unit"
#                | IDENT { "::" IDENT } [ fieldInits ]
#                  -- "a::b::c": member c of namespace a::b (every segment
#                     but the last is the namespace path)
#                | fieldInits
#                | "[" [ arguments ] "]" | "(" expression ")"
#   fieldInits   = "{" [ fieldInit { "," fieldInit } [ "," ] ] "}"
#   fieldInit    = IDENT ":" expression
#
# One field-initializer payload (fieldInits) serves two constructs
# (STRUCTS.md): standing alone, "{ x: a, y: b }" is an anonymous struct
# value; after a (possibly module-qualified) type name, "Person { x: a, y: b
# }" applies the same payload to the named struct's declared schema. "{"
# in expression position can only start fieldInits (it is otherwise only
# ever a type declaration's domain or a function type's fields, both parsed
# by dedicated grammar), and "NAME {" can only mean a named construction:
# no existing expression is ever followed by "{". Field names are ordinary
# identifiers: no keyword, computed key, string or integer key. "x.name" is
# a field projection, resolved statically by HIR. "x.name(args)" -- a "."
# IDENT immediately followed by an argument list -- is a method call
# (METHOD-SUGAR.md): the surface spelling of the ordinary call
# "name(x, args)", decided by HIR resolution, never here. "(x.name)(args)" is
# not one: the parenthesized projection is a field value being called.
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
    set imports [Imports p]
    set body [Statements p {EOF}]
    set end [dict get [Peek p] span]
    return [surface::ast::node program [surface::ast::cover $start $end] body $body \
        namespace $namespaceName namespaceSpan $namespaceSpan imports $imports]
}

# 1 if the next tokens start an import declaration: the contextual word
# "import" followed by a name or by "type" (never a valid continuation of an
# expression, so an ordinary variable called `import` is unaffected).
proc surface::parser::AtImport {pVar} {
    upvar 1 $pVar p
    set token [Peek p]
    return [expr {[dict get $token kind] eq "IDENT" && [dict get $token text] eq "import"
        && [Kind p 1] in {IDENT type}}]
}

# The import declarations of the file header, in written order: a list of
# `import` and `typeimport` nodes (surface/ast.tcl). Blank lines between
# them are fine; the first token that does not start an import ends the
# header. A malformed import is a syntax error like any other (recovered per
# declaration in a recovering parse).
proc surface::parser::Imports {pVar} {
    upvar 1 $pVar p
    set imports {}
    while 1 {
        while {[Kind p] eq "NEWLINE"} {
            Advance p
        }
        if {![AtImport p]} {
            return $imports
        }
        set token [Peek p]
        if {![catch {Import p} import options]} {
            lappend imports $import
            continue
        }
        if {![dict get $p recover] || [lrange [dict get $options -errorcode] 0 1] ne {SURFACE SYNTAX}} {
            return -options $options $import
        }
        dict lappend p diagnostics [lindex [dict get $options -errorcode] 2]
        set before [dict get $p pos]
        Synchronize p
        if {[dict get $p pos] == $before} {
            Advance p
        }
    }
}

# "import" [ "type" ] PATH NEWLINE: a namespace import, or a type import whose
# PATH ends in the type's name (IMPORTS.md). Returns an `import` node
# {namespace PATH namespaceSpan}, or a `typeimport` node {namespace NS name T
# nameSpan namespaceSpan} (NS the path before the last "::"). No alias ("as"),
# wildcard or selective form exists: each is a specific syntax error.
proc surface::parser::Import {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set isType 0
    if {[Kind p] eq "type"} {
        Advance p
        set isType 1
    }
    set first [Expect p IDENT [expr {$isType ? "a qualified type name (NAMESPACE::Type) after \"import type\"" : "a namespace name after \"import\""}]]
    set segments [list [dict get $first value]]
    set spans [list [dict get $first span]]
    while {[Kind p] eq "::"} {
        Advance p
        if {[Kind p] eq "*"} {
            Fail [Peek p] "wildcard imports do not exist: import the exact namespace (\"import [join $segments ::]\") and refer to its members as [join $segments ::]::name"
        }
        set segment [Expect p IDENT [expr {$isType ? "a type name after \"::\"" : "a namespace name after \"::\""}]]
        lappend segments [dict get $segment value]
        lappend spans [dict get $segment span]
    }
    set token [Peek p]
    if {[dict get $token kind] eq "IDENT" && [dict get $token text] eq "as"} {
        Fail $token "import aliases do not exist: refer to the imported [expr {$isType ? "type" : "namespace"}] by its full name"
    }
    if {[dict get $token kind] ne "NEWLINE" && [dict get $token kind] ne "EOF"} {
        Fail $token "expected end of line, found [Describe $token]"
    }
    if {[dict get $token kind] eq "NEWLINE"} {
        Advance p
    }
    set span [surface::ast::cover $start [lindex $spans end]]
    if {$isType} {
        if {[llength $segments] < 2} {
            Fail [dict create span [lindex $spans 0]] \
                "a type import needs a qualified name NAMESPACE::Type (found just \"[lindex $segments 0]\")"
        }
        return [surface::ast::node typeimport $span \
            namespace [join [lrange $segments 0 end-1] ::] \
            namespaceSpan [surface::ast::cover [lindex $spans 0] [lindex $spans end-1]] \
            name [lindex $segments end] nameSpan [lindex $spans end]]
    }
    return [surface::ast::node import $span namespace [join $segments ::] \
        namespaceSpan [surface::ast::cover [lindex $spans 0] [lindex $spans end]]]
}

# "namespace" PATH NEWLINE, as the very first statement of a file (a
# declaration, not an ordinary statement: it introduces no HIR node -- see
# surface/modules.tcl). PATH is one or more IDENT segments joined by "::"
# (`namespace abi::x86_64`: a nested namespace, lib/abi/x86_64.bot). Returns
# {NAME SPAN}, NAME the whole path.
proc surface::parser::NamespaceDecl {pVar} {
    upvar 1 $pVar p
    Advance p
    set first [Expect p IDENT "a namespace name after \"namespace\""]
    set segments [list [dict get $first value]]
    set last $first
    while {[Kind p] eq "::"} {
        Advance p
        set last [Expect p IDENT "a namespace name after \"::\""]
        lappend segments [dict get $last value]
    }
    set token [Peek p]
    if {[dict get $token kind] ne "NEWLINE"} {
        Fail $token "expected end of line, found [Describe $token]"
    }
    Advance p
    return [list [join $segments ::] [surface::ast::cover [dict get $first span] [dict get $last span]]]
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
        struct {
            if {![dict get $p topLevel]} {
                Fail $token "a struct declaration is only allowed at the top level of a module, not nested in a function/if/loop"
            }
            return [StructDecl p]
        }
        INDENT { Fail $token "unexpected indentation" }
        else   { Fail $token "\"else\" without a matching \"if\"" }
        elif   { Fail $token "\"elif\" without a matching \"if\"" }
        namespace { Fail $token "a \"namespace\" declaration must be the first statement in the file" }
    }
    if {[AtImport p]} {
        Fail $token "an import must be in the file header: after the \"namespace\" declaration, before any other declaration or statement, and never inside a function, loop or branch"
    }
    set statement [Simple p]
    if {[dict get $statement kind] eq "handledcall"} {
        # The handler suite(s) already ended the line.
        return $statement
    }
    if {[dict get $statement kind] in {bind return destructure}
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
        \{ {
            # A braced pattern followed by "=" at the start of a statement
            # is a struct destructuring (STRUCT-DESTRUCTURING.md); any other
            # open brace still starts an anonymous struct value statement.
            if {[PatternAhead p]} {
                return [Destructure p]
            }
        }
        [ {
            # A bracketed group followed by "=" is the shape of a positional
            # List destructuring, which Botlish intentionally does not have:
            # a dedicated diagnostic, not "only a name can be bound".
            if {[PatternAhead p]} {
                ListDestructuringError [PatternSpan p]
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
    if {[Kind p] eq ":" && [dict get $expr kind] in {call methodcall}} {
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
    while {[Kind p] eq "::"} {
        # A module-qualified type name (STRUCTS.md): "geo::Point" names the
        # struct Point declared by module geo, "abi::x86_64::Register64" the
        # struct Register64 of the nested namespace abi::x86_64. Kept as the
        # one bare-name string, so every bare-name consumer keeps working.
        Advance p
        set member [Expect p IDENT "a type name after \"::\""]
        set name "${name}::[dict get $member value]"
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
    lassign [ParamSections p] params flags
    set body [Suite p "the parameter list"]
    return [surface::ast::node function [SpanFrom p $start] \
        name [dict get $name value] nameSpan [dict get $name span] \
        params $params flags $flags paramsSpan [SpanFrom p [dict get $open span]] \
        resultType [dict get $body resultType] resultTypeSpan [dict get $body resultTypeSpan] \
        errors [dict get $body errors] body $body]
}

# The parameter list of a function declaration, after "(", through ")":
#
#   params       = [ ordinary ] [ flagSection ]       (see paramSectionOrder)
#   ordinary     = param { "," param }
#   param        = IDENT [ ":" typeExpr ]
#   flagSection  = "flags" flagDecl { "," flagDecl }
#   flagDecl     = ":" IDENT                          -- no space after ":"
#
# optionally followed by a trailing ",". Returns {PARAMS FLAGS}: PARAMS the
# ordinary parameters {NAME SPAN TYPE TYPESPAN}, FLAGS the declared flags
# {NAME SPAN} in written order (SPAN covers ":name").
#
# The parameter list is a sequence of *sections* in one canonical order,
# paramSectionOrder: ordinary parameters, then flags. A new section is
# introduced by its marker word and runs until the next section marker or the
# closing ")"; it never swallows "the rest of the signature" -- the list is
# parsed one entry at a time and each entry knows which section it belongs
# to, so a later section (the planned `context`, `variadic`) is one more
# marker and one more rank in the order, with the same ordering diagnostic.
#
# "flags" is a contextual marker, not a keyword: it opens the flag section
# only where an entry is spelled `flags :NAME` -- the name, then a colon that
# is separated from it by space and glued to the NAME after it (FlagsMarker).
# `flags` anywhere else is an ordinary parameter name, typed or not
# (`fn f(flags)`, `fn f(flags: Int)`, `fn f(flags : Int)`).
proc surface::parser::ParamSections {pVar} {
    upvar 1 $pVar p
    variable paramSectionOrder
    set params {}
    set flags {}
    set section ordinary
    while {[Kind p] ne ")"} {
        set token [Peek p]
        if {[Kind p] eq ":" || [FlagsMarker p]} {
            if {[Kind p] ne ":"} {
                Advance p
                set markerSpan [dict get $token span]
                EnterSection p section flags $markerSpan
            } elseif {$section ne "flags"} {
                set flag [FlagEntry p]
                FailCode [dict get $flag span] MALFORMED-FLAG-SECTION \
                    "flag :[dict get $flag name] is outside a flag section: declare flags after the ordinary parameters as \"flags :[dict get $flag name]\""
            }
            lappend flags [FlagEntry p]
        } else {
            set param [Expect p IDENT "a parameter name"]
            if {$section ne "ordinary"} {
                FailCode [dict get $param span] MALFORMED-FLAG-SECTION \
                    "parameter \"[dict get $param value]\" cannot follow the $section section: a parameter list is ordinary parameters, then flags"
            }
            set type ""
            set typeSpan ""
            if {[Kind p] eq ":"} {
                Advance p
                set typeStart [dict get [Peek p] span]
                set type [TypeExpr p "a parameter type after \":\""]
                set typeSpan [SpanFrom p $typeStart]
            }
            lappend params [list [dict get $param value] [dict get $param span] $type $typeSpan]
        }
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne ")"} {
            Fail [Peek p] "expected \",\" or \")\" in the parameter list, found [Describe [Peek p]]"
        }
    }
    Advance p
    return [list $params $flags]
}

# The canonical order of a declaration's parameter sections. Only `ordinary`
# and `flags` exist; `context` and `variadic` (terminal) are planned.
namespace eval surface::parser {
    variable paramSectionOrder {ordinary flags}
}

# Moves SECTIONVAR to section NEW (marker at SPAN), or fails when NEW is not
# after the current section in paramSectionOrder (a repeated section included).
proc surface::parser::EnterSection {pVar sectionVar new span} {
    upvar 1 $pVar p $sectionVar section
    variable paramSectionOrder
    if {[lsearch -exact $paramSectionOrder $new] <= [lsearch -exact $paramSectionOrder $section]} {
        FailCode $span MALFORMED-FLAG-SECTION \
            "a \"$new\" section cannot follow the $section section: a parameter list has at most one $new section, after the ordinary parameters"
    }
    set section $new
}

# 1 if the next tokens are the flag-section marker: the name `flags` and a
# ":" that is separated from it by space and glued to the token after it --
# `flags :quiet`. (`flags: T` and `flags : T` are a typed parameter named
# flags.) What follows the glued colon is FlagEntry's to judge, so a malformed
# flag (`flags :if`, `flags :`) is a flag diagnostic, not a type error.
proc surface::parser::FlagsMarker {pVar} {
    upvar 1 $pVar p
    set name [Peek p]
    if {[dict get $name kind] ne "IDENT" || [dict get $name value] ne "flags"} {
        return 0
    }
    set colon [Peek p 1]
    set next [Peek p 2]
    return [expr {[dict get $colon kind] eq ":"
        && [dict get $colon span start] > [dict get $name span end]
        && [dict get $next span start] == [dict get $colon span end]}]
}

# One flag spelling ":" IDENT, the name glued to the colon, at ":". Returns
# {name NAME span SPAN} with SPAN covering both tokens. Shared by flag
# declarations and call-site flags.
proc surface::parser::FlagEntry {pVar} {
    upvar 1 $pVar p
    set colon [Expect p : "\":\""]
    set token [Peek p]
    if {[dict get $token kind] ne "IDENT"} {
        FailCode [dict get $colon span] MALFORMED-FLAG \
            "expected a flag name after \":\", found [Describe $token]: a flag is written :name"
    }
    if {[dict get $token span start] != [dict get $colon span end]} {
        FailCode [surface::ast::cover [dict get $colon span] [dict get $token span]] MALFORMED-FLAG \
            "a flag is written :[dict get $token value] with no space after \":\""
    }
    Advance p
    return [dict create name [dict get $token value] \
        span [surface::ast::cover [dict get $colon span] [dict get $token span]]]
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

# An if chain: "if" CONDITION ":" SUITE { "elif" CONDITION ":" SUITE }
# [ "else" ":" SUITE ] (ELIF.md).
#
# "elif" is surface syntax only. Each "elif" clause is built as an ordinary
# `if` node (marked `elif 1`) standing alone in a synthetic else suite (also
# marked `elif 1`) of the clause before it, so
#
#   if a: A elif b: B else: C
#
# parses to exactly the AST of
#
#   if a: A else: if b: B else: C
#
# up to those two markers, and ids, spans, lowering and every later pass see
# only the nested shape. A clause's own `if` node and synthetic else suite
# span from its "elif" keyword to the end of the chain; its condition and
# suite keep their own spans.
#
# An "elif" or "else" belongs to the `if` whose chain is open at the same
# indentation: the suite of an inner `if` ends (at its DEDENT) before the
# next clause keyword is looked at, so a clause keyword is always claimed by
# the innermost chain still open at its own indentation. Clauses are
# collected in a loop, not by recursion, so a long chain costs no parser
# stack depth.
proc surface::parser::If {pVar} {
    upvar 1 $pVar p
    set start [dict get [Peek p] span]
    set clauseStart $start
    set keyword if
    Advance p
    set clauses {}
    while 1 {
        set condition [Expression p]
        set then [Suite p "the \"$keyword\" condition"]
        lappend clauses [list $clauseStart $condition $then]
        if {[Kind p] ne "elif"} {
            break
        }
        set clauseStart [dict get [Advance p] span]
        set keyword elif
    }
    set else ""
    if {[Kind p] eq "else"} {
        Advance p
        set else [Suite p "\"else\""]
        if {[Kind p] eq "elif"} {
            Fail [Peek p] "\"elif\" after \"else\": an \"else\" ends the if chain"
        }
    }
    # Fold the clauses from the last to the first into right-nested ifs.
    set index [llength $clauses]
    while {$index > 0} {
        incr index -1
        lassign [lindex $clauses $index] clauseStart condition then
        set span [SpanFrom p $clauseStart]
        set node [surface::ast::node if $span condition $condition then $then else $else]
        if {$index == 0} {
            return $node
        }
        dict set node elif 1
        set else [surface::ast::node suite $span body [list $node] resultType {} \
            resultTypeSpan {} errors {} elif 1]
    }
}

# A loop header is one or more iteration clauses joined by "and":
#
#   loop x in EXPR:                                  List traversal
#   loop i from A to B:                              ascending, B exclusive
#   loop i from A through B:                         ascending, B inclusive
#   loop i down from B to A:                         descending, A exclusive
#   loop i down from B through A:                    descending, A inclusive
#   loop x in EXPR and i from 0 to N and ...:        lockstep (COLLECTING-LOOPS.md)
#
# "in", "from", "down", "to", "through" and "by" are recognized contextually,
# exactly like TypeDecl's own "in" (see this file's header comment): none is
# a lexer keyword, so a program is free to use any of them as an ordinary
# name anywhere else. Which clause form applies is decided by one token of
# lookahead right after the clause's own variable name. "and" is already the
# boolean operator's keyword, so a clause's own operand expressions are
# parsed one precedence level below it (LoopOperand): an unparenthesized
# "a and b" cannot appear inside a clause operand (parenthesize it), and
# the "and" that follows an operand always starts the next clause.
#
# "by" (an explicit step) is still recognized only to be rejected with a
# "reserved, not implemented yet" diagnostic.
#
# The node keeps every clause in `clauses` (a list of dicts; one for each
# written clause, in written order). For the one-clause forms the older
# per-form fields (elementName/iterable or countName/countStart/countEnd,
# plus direction/endKind) mirror that single clause so existing consumers
# keep working unchanged; a lockstep loop (two or more clauses) leaves them
# empty and is described by `clauses` alone.
proc surface::parser::Loop {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set clauses {}
    if {[Kind p] eq "IDENT"} {
        lappend clauses [LoopClause p]
        while {[Kind p] eq "and"} {
            Advance p
            if {[Kind p] ne "IDENT"} {
                Fail [Peek p] "expected a loop variable after \"and\", found [Describe [Peek p]]"
            }
            lappend clauses [LoopClause p]
        }
        set afterToken [Peek p]
        if {[dict get $afterToken kind] eq "IDENT" && [dict get $afterToken value] eq "by"} {
            Fail $afterToken "\"by\" (an explicit step) is reserved for a future counted-loop\
                form; a counted loop always steps by 1"
        }
    }
    set elementName ""
    set elementNameSpan ""
    set iterable ""
    set countName ""
    set countNameSpan ""
    set countStart ""
    set countEnd ""
    set direction ""
    set endKind ""
    if {[llength $clauses] == 1} {
        set clause [lindex $clauses 0]
        if {[dict get $clause kind] eq "list"} {
            set elementName [dict get $clause name]
            set elementNameSpan [dict get $clause nameSpan]
            set iterable [dict get $clause iterable]
        } else {
            set countName [dict get $clause name]
            set countNameSpan [dict get $clause nameSpan]
            set countStart [dict get $clause start]
            set countEnd [dict get $clause end]
            set direction [dict get $clause direction]
            set endKind [dict get $clause endKind]
        }
    }
    set body [Suite p "\"loop\""]
    return [surface::ast::node loop [SpanFrom p $start] \
        elementName $elementName elementNameSpan $elementNameSpan iterable $iterable \
        countName $countName countNameSpan $countNameSpan countStart $countStart countEnd $countEnd \
        direction $direction endKind $endKind clauses $clauses \
        body $body]
}

# One iteration clause, positioned at its variable's IDENT.
proc surface::parser::LoopClause {pVar} {
    upvar 1 $pVar p
    set nameToken [Advance p]
    set name [dict get $nameToken value]
    set nameSpan [dict get $nameToken span]
    set dispatch [Peek p]
    set dispatchWord [expr {[dict get $dispatch kind] eq "IDENT" ? [dict get $dispatch value] : ""}]
    switch -- $dispatchWord {
        in {
            Advance p
            return [dict create kind list name $name nameSpan $nameSpan \
                iterable [LoopOperand p] start "" end "" direction "" endKind ""]
        }
        from {
            Advance p
            return [LoopCount p $name $nameSpan up]
        }
        down {
            Advance p
            set fromToken [Peek p]
            if {[dict get $fromToken kind] ne "IDENT" || [dict get $fromToken value] ne "from"} {
                Fail $fromToken "expected \"from\" after \"down\", found [Describe $fromToken]"
            }
            Advance p
            return [LoopCount p $name $nameSpan down]
        }
        default {
            Fail $dispatch "expected \"in\", \"from\" or \"down from\" after the loop variable,\
                found [Describe $dispatch]"
        }
    }
}

# The rest of a numeric clause after its "from": FIRST ("to" | "through")
# SECOND. FIRST is where iteration begins (the low end of an ascending
# loop, the high end of a descending one); SECOND is the limit.
proc surface::parser::LoopCount {pVar name nameSpan direction} {
    upvar 1 $pVar p
    set startToken [Peek p]
    if {[dict get $startToken kind] eq "IDENT" && [dict get $startToken value] in {to through}} {
        Fail $startToken "expected an expression (the loop's start value)\
            after \"from\", found [Describe $startToken]"
    }
    set first [LoopOperand p]
    set keywordToken [Peek p]
    set word [expr {[dict get $keywordToken kind] eq "IDENT" ? [dict get $keywordToken value] : ""}]
    switch -- $word {
        to { set endKind exclusive }
        through { set endKind inclusive }
        default {
            Fail $keywordToken "expected \"to\" or \"through\" after the loop start value,\
                found [Describe $keywordToken]"
        }
    }
    Advance p
    set second [LoopOperand p]
    return [dict create kind count name $name nameSpan $nameSpan iterable "" \
        start $first end $second direction $direction endKind $endKind]
}

# An expression operand of an iteration clause: a disjunction whose
# conjunction level is skipped, so "and" is left for the clause separator.
proc surface::parser::LoopOperand {pVar} {
    upvar 1 $pVar p
    return [Logical p or Inversion]
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
    while 1 {
        switch -- [Kind p] {
            ( {
                Advance p
                lassign [CallArguments p] args flags
                set expr [surface::ast::node call [SpanFrom p [dict get $expr span]] \
                    callee $expr args $args flags $flags]
            }
            . {
                # Field projection (STRUCTS.md): "receiver.name", the name
                # known syntactically. Never a dynamic lookup.
                Advance p
                set token [Peek p]
                if {[dict get $token kind] ne "IDENT"} {
                    Fail $token "expected a field name after \".\", found [Describe $token]"
                }
                Advance p
                if {[Kind p] eq "("} {
                    # Method call (METHOD-SUGAR.md): same argument grammar
                    # as an ordinary call.
                    Advance p
                    lassign [CallArguments p] args flags
                    set expr [surface::ast::node methodcall [SpanFrom p [dict get $expr span]] \
                        receiver $expr name [dict get $token value] nameSpan [dict get $token span] \
                        args $args flags $flags]
                    continue
                }
                set expr [surface::ast::node project [SpanFrom p [dict get $expr span]] \
                    receiver $expr name [dict get $token value] nameSpan [dict get $token span]]
            }
            default {
                return $expr
            }
        }
    }
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

# The argument list of a call, after "(", through ")" (a trailing comma is
# allowed):
#
#   arguments    = { expression "," } { flag "," }
#   flag         = ":" IDENT                -- no space after ":"
#
# Returns {ARGS FLAGS}: the ordinary value arguments, and the supplied flags
# {name NAME span SPAN} in written order. Flags are not expressions: they
# only exist here, after every ordinary argument (an ordinary argument after
# a flag is an error, so the flag section stays distinguishable from a future
# variadic argument list), and which flags a call supplies is statically
# known from its spelling.
proc surface::parser::CallArguments {pVar} {
    upvar 1 $pVar p
    set args {}
    set flags {}
    while {[Kind p] ne ")"} {
        if {[Kind p] eq ":"} {
            lappend flags [FlagEntry p]
        } else {
            set arg [Expression p]
            if {$flags ne ""} {
                FailCode [dict get $arg span] ARGUMENT-AFTER-FLAG \
                    "an ordinary argument cannot follow the flag :[dict get [lindex $flags end] name]: flags come last in a call"
            }
            lappend args $arg
        }
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne ")"} {
            Fail [Peek p] "expected \",\" or \")\" in the argument list, found [Describe [Peek p]]"
        }
    }
    Advance p
    return [list $args $flags]
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
                # NAMESPACE::member, NAMESPACE possibly nested: every segment
                # but the last is the namespace path ("abi::x86_64::register64"
                # is member register64 of namespace abi::x86_64).
                set segments [list [dict get $token value]]
                set namespaceSpan $span
                Advance p
                set member [Expect p IDENT "a name after \"::\""]
                while {[Kind p] eq "::"} {
                    lappend segments [dict get $member value]
                    set namespaceSpan [surface::ast::cover $span [dict get $member span]]
                    Advance p
                    set member [Expect p IDENT "a name after \"::\""]
                }
                set namespaceName [join $segments ::]
                if {[Kind p] eq "\{"} {
                    # NAMESPACE::Struct { ... }: a named struct construction
                    # (STRUCTS.md) through module qualification.
                    set nameSpan [SpanFrom p $span]
                    set init [FieldInits p]
                    return [surface::ast::node namedstruct [SpanFrom p $span] \
                        namespace $namespaceName \
                        name [dict get $member value] nameSpan $nameSpan init $init]
                }
                return [surface::ast::node qualname [SpanFrom p $span] \
                    namespace $namespaceName namespaceSpan $namespaceSpan \
                    name [dict get $member value] nameSpan [dict get $member span]]
            }
            if {[Kind p] eq "\{"} {
                # Struct { ... }: a named struct construction (STRUCTS.md).
                set init [FieldInits p]
                return [surface::ast::node namedstruct [SpanFrom p $span] \
                    namespace "" name [dict get $token value] nameSpan $span init $init]
            }
            return [surface::ast::node name $span name [dict get $token value]]
        }
        \{ {
            # { ... }: an anonymous struct value (STRUCTS.md).
            set init [FieldInits p]
            return [surface::ast::node anonstruct [SpanFrom p $span] init $init]
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
        : {
            set name [Peek p 1]
            if {[dict get $name kind] eq "IDENT" && [dict get $name span start] == [dict get $token span end]} {
                FailCode [surface::ast::cover $span [dict get $name span]] FLAG-NOT-A-VALUE \
                    ":[dict get $name value] is a call flag, not a value: flags can only be written as the last arguments of a call, e.g. f(x, :[dict get $name value])"
            }
        }
    }
    Fail $token "expected an expression, found [Describe $token]"
}

# ---------------------------------------------------------------------------
# Struct destructuring (STRUCT-DESTRUCTURING.md)
#
#   destructure  = pattern "=" valueOrHandled
#   pattern      = "{" field { "," field } [ "," ] "}"
#   field        = IDENT | IDENT ":" IDENT | IDENT ":" pattern
#
# The left name of "source: local" is the struct field read; the right name
# is the binding created (nesting: the field's value is destructured in turn).
# A pattern is only ever recognized at the start of a statement, followed by
# "=" (PatternAhead): an anonymous struct value used as an expression
# statement, and every other use of "{" and "[", parse exactly as before.
# What is deliberately not here: "[...] =" (positional List destructuring,
# ListDestructuringError), "...rest", "name = default", "_" wildcards,
# "ref"/"&"/"mut" binding modes and an empty "{}" -- each an error with its own
# message, none a silently different construct.

# 1 if the tokens at the current position are a bracketed group ("{...}" or
# "[...]") immediately followed by "=": the shape of a destructuring pattern.
proc surface::parser::PatternAhead {pVar} {
    upvar 1 $pVar p
    return [expr {[PatternEnd p] >= 0}]
}

# The offset (from the current token) of the token that closes the bracket the
# current token opens, if "=" follows it; else -1. Brackets nest; a layout
# token inside means the group is not closed on this logical line.
proc surface::parser::PatternEnd {pVar} {
    upvar 1 $pVar p
    set depth 0
    for {set i 0} 1 {incr i} {
        switch -- [Kind p $i] {
            \{ - [ - ( {
                incr depth
            }
            \} - ] - ) {
                incr depth -1
                if {$depth == 0} {
                    return [expr {[Kind p [expr {$i + 1}]] eq "=" ? $i : -1}]
                }
            }
            NEWLINE - INDENT - DEDENT - EOF {
                return -1
            }
        }
    }
}

# The span of the bracketed group at the current token (see PatternEnd).
proc surface::parser::PatternSpan {pVar} {
    upvar 1 $pVar p
    return [surface::ast::cover [dict get [Peek p] span] [dict get [Peek p [PatternEnd p]] span]]
}

# Raises a syntax error that carries a stable diagnostic CODE, in the
# diagnostic's `code` entry and as the start of its message.
proc surface::parser::FailCode {span code message} {
    set diagnostic [surface::diagnostic $span "$code: $message"]
    dict set diagnostic code $code
    surface::raise $diagnostic
}

# "[a, b] = value" and the nested "{pair: [a, b]}": a positional List
# destructuring. Intentionally absent from the language, not unfinished: lists
# stay sequences, and several differently typed results are a struct value.
proc surface::parser::ListDestructuringError {span} {
    FailCode $span LIST-DESTRUCTURING \
        "positional List destructuring is not supported; use a struct value with named fields instead (a List is for a sequence of values; have the function return a struct, e.g. `result = get_result()` then `{value, error} = result`)"
}

# "{" field { "," field } [ "," ] "}" "=" valueOrHandled, at a "{" that
# PatternAhead accepted. Node: destructure, pattern, value.
proc surface::parser::Destructure {pVar} {
    upvar 1 $pVar p
    set start [dict get [Peek p] span]
    set pattern [Pattern p]
    Expect p = "\"=\""
    set value [ValueOrHandled p]
    return [surface::ast::node destructure [SpanFrom p $start] pattern $pattern value $value]
}

# A pattern: {span SPAN fields {FIELD...}}, each FIELD a dict
#   name nameSpan   the struct field read (the left name)
#   span            the whole entry, `name`, `name: local` or `name: {...}`
#   local localSpan the binding created (the right name; the field name for
#                   the shorthand), or "" when the field is destructured
#   nested          the pattern the field's value is destructured by, or ""
#   shorthand       1 for `name`
proc surface::parser::Pattern {pVar} {
    upvar 1 $pVar p
    set open [Expect p \{ "\"\{\""]
    set start [dict get $open span]
    set fields {}
    set seen {}
    while {[Kind p] ne "\}"} {
        set token [Peek p]
        switch -- [dict get $token kind] {
            IDENT {}
            NEWLINE - DEDENT - EOF {
                Fail $token "expected \"\}\" to close the destructuring pattern, found [Describe $token]"
            }
            .. - . {
                Fail $token "rest/spread binding is not supported in a struct destructuring: it selects fields by name only and produces no \"remaining fields\" value"
            }
            default {
                if {[regexp {^[a-z]+$} [dict get $token text]] && [dict get $token kind] eq [dict get $token text]} {
                    Fail $token "expected a field name, found the keyword \"[dict get $token text]\" (a field name is an ordinary identifier)"
                }
                Fail $token "expected a field name (an identifier) in the destructuring pattern, found [Describe $token]"
            }
        }
        Advance p
        set name [dict get $token value]
        if {$name in $seen} {
            FailCode [dict get $token span] DUPLICATE-FIELD \
                "duplicate field \"$name\" in this struct destructuring: each field may be selected only once"
        }
        lappend seen $name
        set field [dict create name $name nameSpan [dict get $token span] local "" localSpan "" \
            nested "" shorthand 0]
        switch -- [Kind p] {
            : {
                Advance p
                set target [Peek p]
                switch -- [dict get $target kind] {
                    IDENT {
                        Advance p
                        dict set field local [dict get $target value]
                        dict set field localSpan [dict get $target span]
                    }
                    \{ {
                        dict set field nested [Pattern p]
                    }
                    [ {
                        ListDestructuringError [surface::ast::cover [dict get $target span] \
                            [expr {[PatternEnd p] >= 0 ? [dict get [Peek p [PatternEnd p]] span] : [dict get $target span]}]]
                    }
                    default {
                        Fail $target "expected a binding name or a nested \"\{...\}\" pattern after \"[dict get $token value]:\", found [Describe $target]"
                    }
                }
            }
            = {
                Fail [Peek p] "a struct destructuring has no default values: field \"$name\" must exist in the struct"
            }
            , - \} {
                dict set field local $name
                dict set field localSpan [dict get $token span]
                dict set field shorthand 1
            }
            default {
                Fail [Peek p] "expected \",\", \":\" or \"\}\" after the field name \"$name\" in the destructuring pattern, found [Describe [Peek p]]"
            }
        }
        dict set field span [SpanFrom p [dict get $token span]]
        lappend fields $field
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne "\}"} {
            Fail [Peek p] "expected \",\" or \"\}\" after the destructuring field \"$name\", found [Describe [Peek p]]"
        }
    }
    Advance p
    set span [SpanFrom p $start]
    if {$fields eq {}} {
        Fail $open "a struct destructuring must select at least one field; \"\{\} = value\" binds nothing"
    }
    return [dict create span $span fields $fields]
}

# ---------------------------------------------------------------------------
# Structs (STRUCTS.md)

# "{" [ fieldInit { "," fieldInit } [ "," ] ] "}" -- the one shared
# field-initializer payload of an anonymous struct value and of a named
# struct construction. Returns a `fieldinits` node whose `fields` are
# {name nameSpan value} dicts in written order (evaluation order). Whether
# the names are unique, known or complete is semantic (hir::resolve), never
# a parse concern, so every syntactically well-formed payload parses.
proc surface::parser::FieldInits {pVar} {
    upvar 1 $pVar p
    set open [Expect p \{ "\"\{\""]
    set start [dict get $open span]
    set fields {}
    while {[Kind p] ne "\}"} {
        set token [Peek p]
        if {[dict get $token kind] ne "IDENT"} {
            if {[dict get $token kind] in {NEWLINE DEDENT EOF}} {
                Fail $token "expected \"\}\" to close the struct initializer, found [Describe $token]"
            }
            if {[regexp {^[a-z]+$} [dict get $token text]] && [dict get $token kind] eq [dict get $token text]} {
                Fail $token "expected a field name, found the keyword \"[dict get $token text]\" (a field name is an ordinary identifier)"
            }
            Fail $token "expected a field name (an identifier), found [Describe $token]"
        }
        Advance p
        if {[Kind p] ne ":"} {
            Fail [Peek p] "expected \":\" after the field name \"[dict get $token value]\", found [Describe [Peek p]]"
        }
        Advance p
        set value [Expression p]
        lappend fields [dict create name [dict get $token value] nameSpan [dict get $token span] value $value]
        if {[Kind p] eq ","} {
            Advance p
        } elseif {[Kind p] ne "\}"} {
            Fail [Peek p] "expected \",\" or \"\}\" after the value of field \"[dict get $token value]\", found [Describe [Peek p]]"
        }
    }
    Advance p
    return [surface::ast::node fieldinits [SpanFrom p $start] fields $fields]
}

# "struct" IDENT ":" NEWLINE INDENT { IDENT ":" typeExpr NEWLINE } DEDENT --
# a top-level nominal struct declaration. Every field has an explicit type
# and there are no defaults. A `structdecl` node carries `fields`, one
# {name nameSpan type typeSpan} dict per declared field in written (slot)
# order.
proc surface::parser::StructDecl {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set name [Expect p IDENT "a struct name after \"struct\""]
    set token [Peek p]
    if {[dict get $token kind] ne ":"} {
        Fail $token "expected \":\" after the struct name \"[dict get $name value]\", found [Describe $token]"
    }
    Advance p
    set token [Peek p]
    if {[dict get $token kind] ne "NEWLINE"} {
        Fail $token "expected a new line and an indented block of fields after \":\", found [Describe $token]"
    }
    Advance p
    set token [Peek p]
    if {[dict get $token kind] ne "INDENT"} {
        Fail $token "a struct declaration needs at least one \"field: Type\" line in an indented block (there is no empty-struct syntax), found [Describe $token]"
    }
    Advance p
    set fields {}
    while {[Kind p] ne "DEDENT" && [Kind p] ne "EOF"} {
        if {[Kind p] eq "NEWLINE"} {
            Advance p
            continue
        }
        set fieldToken [Peek p]
        if {[dict get $fieldToken kind] ne "IDENT"} {
            Fail $fieldToken "expected a field declaration \"name: Type\", found [Describe $fieldToken]"
        }
        Advance p
        if {[Kind p] ne ":"} {
            Fail [Peek p] "expected \":\" and a type after the field name \"[dict get $fieldToken value]\" (a struct field always has an explicit type), found [Describe [Peek p]]"
        }
        Advance p
        set typeStart [dict get [Peek p] span]
        set type [TypeExpr p "a field type after \":\""]
        set typeSpan [SpanFrom p $typeStart]
        if {[Kind p] eq "="} {
            Fail [Peek p] "a struct field cannot have a default value (every field must be given explicitly when a struct is constructed)"
        }
        set next [Peek p]
        if {[dict get $next kind] ne "NEWLINE"} {
            Fail $next "expected end of line after the field declaration, found [Describe $next]"
        }
        Advance p
        lappend fields [dict create name [dict get $fieldToken value] nameSpan [dict get $fieldToken span] \
            type $type typeSpan $typeSpan]
    }
    if {[Kind p] eq "DEDENT"} {
        Advance p
    }
    return [surface::ast::node structdecl [SpanFrom p $start] \
        name [dict get $name value] nameSpan [dict get $name span] fields $fields]
}
