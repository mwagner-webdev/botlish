# ast.tcl -- source spans, syntax diagnostics and the surface AST.
#
# The surface AST records what the programmer wrote and where. It holds no
# semantic facts: no binding ids, scopes, captures or types (those are HIR's).
#
# Span
# ----
# A span is a dict
#
#   file start end line column endLine endColumn
#
# START and END are character offsets into the source (END exclusive); LINE
# and COLUMN (1-based) locate START, ENDLINE and ENDCOLUMN locate END.
#
# Nodes
# -----
# Every node is a dict with `kind` and `span` plus per-kind fields:
#
#   program    body (statements)
#   suite      body (statements)                 an indented block
#   int        text (canonical decimal digits)
#   string     value (the decoded text)
#   bool       value (true | false)
#   unit
#   name       name
#   list       items (expressions)
#   call       callee, args
#   unary      op (-), opSpan, operand
#   binary     op (+ - * == < <= > >=), opSpan, left, right
#   bind       name, nameSpan, value
#   function   name, nameSpan, params ({NAME SPAN} pairs), paramsSpan (from
#              "(" to the end of the body: the function literal), body (suite)
#   if         condition, then (suite), else (suite or "")
#   loop       body (suite)
#   return     value (expression or "")
#   break      value (expression or "")
#   continue
#
# Syntax errors
# -------------
# surface::syntaxError raises {SURFACE SYNTAX DIAGNOSTIC} with the message
# "FILE:LINE:COLUMN: TEXT"; DIAGNOSTIC is a dict {file line column start end
# message} for tools.

namespace eval surface::ast {}

proc surface::ast::span {file start end line column endLine endColumn} {
    return [dict create file $file start $start end $end line $line column $column \
        endLine $endLine endColumn $endColumn]
}

# The span from the start of FIRST to the end of LAST.
proc surface::ast::cover {first last} {
    return [dict replace $first end [dict get $last end] \
        endLine [dict get $last endLine] endColumn [dict get $last endColumn]]
}

# A zero-width span at the end of SPAN.
proc surface::ast::endOf {span} {
    return [dict replace $span start [dict get $span end] \
        line [dict get $span endLine] column [dict get $span endColumn]]
}

proc surface::ast::node {kind span args} {
    return [dict create kind $kind span $span {*}$args]
}

proc surface::ast::kind {node} { return [dict get $node kind] }
proc surface::ast::spanOf {node} { return [dict get $node span] }

# "FILE:LINE:COLUMN" of SPAN.
proc surface::ast::location {span} {
    return "[dict get $span file]:[dict get $span line]:[dict get $span column]"
}

proc surface::syntaxError {span message} {
    set diagnostic [dict create file [dict get $span file] line [dict get $span line] \
        column [dict get $span column] start [dict get $span start] \
        end [dict get $span end] message $message]
    throw [list SURFACE SYNTAX $diagnostic] "[surface::ast::location $span]: $message"
}

# ---------------------------------------------------------------------------
# Formatting, for debugging and tests.
#
#   surface::formatAst AST ?-spans 1?
#
# Expressions are S-expressions; statements with suites span several lines,
# their suite indented by four spaces:
#
#   (bind x (int 10))
#   fn add (a b)
#       (binary + (name a) (name b))
#   if (name flag)
#       (int 1)
#   else
#       (int 2)
#
# With -spans 1 every node is followed by @LINE:COLUMN-ENDLINE:ENDCOLUMN.

proc surface::formatAst {ast args} {
    set options [dict create -spans 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::formatAst: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set spans [dict get $options -spans]
    set lines {}
    if {[dict get $ast kind] in {program suite}} {
        foreach statement [dict get $ast body] {
            surface::ast::Statement $statement 0 $spans lines
        }
    } else {
        surface::ast::Statement $ast 0 $spans lines
    }
    return [::join $lines \n]
}

proc surface::ast::At {node spans} {
    if {!$spans} {
        return ""
    }
    set s [dict get $node span]
    return " @[dict get $s line]:[dict get $s column]-[dict get $s endLine]:[dict get $s endColumn]"
}

proc surface::ast::Quote {text} {
    return "\"[string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t] $text]\""
}

proc surface::ast::Expr {node spans} {
    set at [At $node $spans]
    switch -- [dict get $node kind] {
        int     { return "(int [dict get $node text])$at" }
        string  { return "(str [Quote [dict get $node value]])$at" }
        bool    { return "(bool [dict get $node value])$at" }
        unit    { return "(unit)$at" }
        name    { return "(name [dict get $node name])$at" }
        list {
            return "([::join [concat list [lmap item [dict get $node items] {Expr $item $spans}]] { }])$at"
        }
        call {
            set parts [list call [Expr [dict get $node callee] $spans]]
            foreach arg [dict get $node args] {
                lappend parts [Expr $arg $spans]
            }
            return "([::join $parts { }])$at"
        }
        unary {
            return "(unary [dict get $node op] [Expr [dict get $node operand] $spans])$at"
        }
        binary {
            return "(binary [dict get $node op] [Expr [dict get $node left] $spans] [Expr [dict get $node right] $spans])$at"
        }
        bind {
            return "(bind [dict get $node name] [Expr [dict get $node value] $spans])$at"
        }
        return - break {
            if {[dict get $node value] eq ""} {
                return "([dict get $node kind])$at"
            }
            return "([dict get $node kind] [Expr [dict get $node value] $spans])$at"
        }
        continue { return "(continue)$at" }
    }
    error "surface::ast: not an expression node: [dict get $node kind]"
}

proc surface::ast::Suite {suite indent spans linesVar} {
    upvar 1 $linesVar lines
    foreach statement [dict get $suite body] {
        Statement $statement $indent $spans lines
    }
}

proc surface::ast::Statement {node indent spans linesVar} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    set inner [expr {$indent + 1}]
    set at [At $node $spans]
    switch -- [dict get $node kind] {
        function {
            set params [lmap pair [dict get $node params] {lindex $pair 0}]
            lappend lines "${pad}fn [dict get $node name] ($params)$at"
            Suite [dict get $node body] $inner $spans lines
        }
        if {
            lappend lines "${pad}if [Expr [dict get $node condition] $spans]$at"
            Suite [dict get $node then] $inner $spans lines
            if {[dict get $node else] ne ""} {
                lappend lines "${pad}else[At [dict get $node else] $spans]"
                Suite [dict get $node else] $inner $spans lines
            }
        }
        loop {
            lappend lines "${pad}loop$at"
            Suite [dict get $node body] $inner $spans lines
        }
        default {
            lappend lines "$pad[Expr $node $spans]"
        }
    }
}
