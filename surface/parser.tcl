# parser.tcl -- Botlish source to surface AST (ast.tcl).
#
#   surface::parse SOURCE ?FILENAME?        => program node
#   surface::parseTokens TOKENS             => program node
#
# Recursive descent over the tokens of lexer.tcl. The grammar, with layout
# already turned into NEWLINE / INDENT / DEDENT tokens:
#
#   program      = { NEWLINE | statement } EOF
#   statement    = simple NEWLINE | function | if | loop
#   simple       = binding | return | break | continue | expression
#   function     = "fn" IDENT "(" [ IDENT { "," IDENT } [ "," ] ] ")" ":" suite
#   if           = "if" expression ":" suite [ "else" ":" suite ]
#   loop         = "loop" ":" suite
#   suite        = NEWLINE INDENT { NEWLINE | statement } DEDENT
#   binding      = IDENT "=" expression
#   return       = "return" [ expression ]
#   break        = "break" [ expression ]
#   continue     = "continue"
#   expression   = comparison
#   comparison   = additive [ ( "==" | "<" | "<=" | ">" | ">=" ) additive ]
#   additive     = multiplicative { ( "+" | "-" ) multiplicative }
#   multiplicative = unary { "*" unary }
#   unary        = "-" unary | postfix
#   postfix      = primary { "(" [ arguments ] ")" }
#   arguments    = expression { "," expression } [ "," ]
#   primary      = INT | STRING | "true" | "false" | "unit" | IDENT
#                | "[" [ arguments ] "]" | "(" expression ")"
#
# Binary arithmetic is left-associative; comparisons do not chain.
#
# Parser state is a dict {tokens pos last}: LAST is the span of the last
# consumed token that is not layout, used to end node spans.

namespace eval surface::parser {
    variable comparisons {== < <= > >=}
}

proc surface::parse {source {filename <input>}} {
    return [surface::parseTokens [surface::lex $source $filename]]
}

proc surface::parseTokens {tokens} {
    set p [dict create tokens $tokens pos 0 last [dict get [lindex $tokens 0] span]]
    return [surface::parser::Program p]
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
# Statements

proc surface::parser::Program {pVar} {
    upvar 1 $pVar p
    set start [dict get [Peek p] span]
    set body {}
    while {[Kind p] ne "EOF"} {
        if {[Kind p] eq "NEWLINE"} {
            Advance p
            continue
        }
        lappend body [Statement p]
    }
    set end [dict get [Peek p] span]
    return [surface::ast::node program [surface::ast::cover $start $end] body $body]
}

proc surface::parser::Statement {pVar} {
    upvar 1 $pVar p
    set token [Peek p]
    switch -- [dict get $token kind] {
        fn     { return [Function p] }
        if     { return [If p] }
        loop   { return [Loop p] }
        INDENT { Fail $token "unexpected indentation" }
        else   { Fail $token "\"else\" without a matching \"if\"" }
    }
    set statement [Simple p]
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
                set value [Expression p]
                return [surface::ast::node bind [SpanFrom p $start] \
                    name [dict get $token value] nameSpan $start value $value]
            }
        }
        return - break {
            Advance p
            set value ""
            if {[Kind p] ni {NEWLINE DEDENT EOF}} {
                set value [Expression p]
            }
            return [surface::ast::node [dict get $token kind] [SpanFrom p $start] value $value]
        }
        continue {
            Advance p
            return [surface::ast::node continue $start]
        }
    }
    return [Expression p]
}

proc surface::parser::Function {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set name [Expect p IDENT "a function name after \"fn\""]
    set open [Expect p ( "\"(\" after the function name"]
    set params {}
    while {[Kind p] ne ")"} {
        set param [Expect p IDENT "a parameter name"]
        lappend params [list [dict get $param value] [dict get $param span]]
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
        params $params paramsSpan [SpanFrom p [dict get $open span]] body $body]
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

proc surface::parser::Loop {pVar} {
    upvar 1 $pVar p
    set start [dict get [Advance p] span]
    set body [Suite p "\"loop\""]
    return [surface::ast::node loop [SpanFrom p $start] body $body]
}

# ":" NEWLINE INDENT statements DEDENT, after AFTER (for messages).
proc surface::parser::Suite {pVar after} {
    upvar 1 $pVar p
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
    set body {}
    while {[Kind p] ne "DEDENT"} {
        if {[Kind p] eq "NEWLINE"} {
            Advance p
            continue
        }
        lappend body [Statement p]
    }
    Advance p
    return [surface::ast::node suite [SpanFrom p $start] body $body]
}

# ---------------------------------------------------------------------------
# Expressions

proc surface::parser::Expression {pVar} {
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
    }
    Fail $token "expected an expression, found [Describe $token]"
}
