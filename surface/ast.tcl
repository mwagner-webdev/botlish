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
# Every node is a dict with `kind`, `span` and `id` plus per-kind fields:
#
#   program    body (statements), diagnostics (syntax errors, see below),
#              namespace (the declared module namespace name, or "" for an
#              ordinary/entry program -- see surface/modules.tcl)
#   suite      body (statements)                 an indented block
#   int        text (canonical decimal digits)
#   string     value (the decoded text)
#   bool       value (true | false)
#   unit
#   name       name
#   qualname   namespace, name, namespaceSpan, nameSpan  (NAMESPACE::NAME)
#   list       items (expressions)
#   call       callee, args
#   unary      op (-), opSpan, operand
#   not        opSpan, operand
#   binary     op (+ - * == != < <= > >=), opSpan, left, right
#   logical    op (and | or), opSpan, left, right
#   bind       name, nameSpan, value (an expression or an if)
#   function   name, nameSpan, params ({NAME SPAN} pairs), paramsSpan (from
#              "(" to the end of the body: the function literal), body (suite)
#   if         condition, then (suite), else (suite or "")
#   loop       body (suite)
#   return     value (an expression, an if, or "")
#   break      value (an expression, an if, or "")
#   continue
#   typedecl   name, nameSpan, parent, parentSpan, domain -- a top-level
#              bounded-integer-refinement declaration (surface/parser.tcl's
#              TypeDecl; see hir/sourcetypes.tcl for what it means). `domain`
#              is {kind interval lo LO loSpan .. hi HI hiSpan .. span ..} or
#              {kind exact values {V...} spans {SPAN...} span ..}, LO/HI/V
#              decimal text (a leading "-" allowed).
#   error      a statement that could not be parsed (recovering parses only)
#
# Node ids
# --------
# `id` names a node by its place in the program's structure rather than by
# position, so it survives edits elsewhere (for tooling and incremental use).
# A statement's id is its parent's id, "/", and a key:
#
#   NAME()     function NAME          NAME=      binding of NAME
#   if loop return break continue     KIND       any other expression statement
#
# the Nth statement with the same key among its siblings adding "#N" (N > 1).
# Inner nodes add their role: then, else, cond, value, callee, argN, itemN,
# left, right, operand; a parameter is NAME()/(PARAM). A top-level function
# fib is "fib()"; the x + y in make_adder's inner add is
# "make_adder()/add()/binary". Editing one function body changes no id outside
# it; adding a statement changes only the ids of later siblings with its key.
#
# Diagnostics
# -----------
# A diagnostic is a dict {file line column start end message}. surface::raise
# throws one as {SURFACE SYNTAX DIAGNOSTIC} with the message
# "FILE:LINE:COLUMN: TEXT".

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

proc surface::diagnostic {span message} {
    return [dict create file [dict get $span file] line [dict get $span line] \
        column [dict get $span column] start [dict get $span start] \
        end [dict get $span end] message $message]
}

proc surface::raise {diagnostic} {
    throw [list SURFACE SYNTAX $diagnostic] \
        "[dict get $diagnostic file]:[dict get $diagnostic line]:[dict get $diagnostic column]: [dict get $diagnostic message]"
}

proc surface::syntaxError {span message} {
    surface::raise [surface::diagnostic $span $message]
}

# ---------------------------------------------------------------------------
# Node ids

# PROGRAM with an id on every node.
proc surface::ast::assignIds {program} {
    dict set program id ""
    dict set program body [Statements [dict get $program body] ""]
    return $program
}

proc surface::ast::Child {parent role} {
    return [expr {$parent eq "" ? $role : "$parent/$role"}]
}

proc surface::ast::Statements {statements parent} {
    set counts [dict create]
    set result {}
    foreach statement $statements {
        switch -- [dict get $statement kind] {
            function { set key "[dict get $statement name]()" }
            bind     { set key "[dict get $statement name]=" }
            default  { set key [dict get $statement kind] }
        }
        dict incr counts $key
        set n [dict get $counts $key]
        if {$n > 1} {
            append key #$n
        }
        lappend result [Ids $statement [Child $parent $key]]
    }
    return $result
}

proc surface::ast::Suite {suite id} {
    dict set suite id $id
    dict set suite body [Statements [dict get $suite body] $id]
    return $suite
}

# NODE and its descendants with ids, NODE's id being ID.
proc surface::ast::Ids {node id} {
    dict set node id $id
    switch -- [dict get $node kind] {
        list {
            set items {}
            set index 1
            foreach item [dict get $node items] {
                lappend items [Ids $item $id/item$index]
                incr index
            }
            dict set node items $items
        }
        call {
            dict set node callee [Ids [dict get $node callee] $id/callee]
            set args {}
            set index 1
            foreach arg [dict get $node args] {
                lappend args [Ids $arg $id/arg$index]
                incr index
            }
            dict set node args $args
        }
        unary - not {
            dict set node operand [Ids [dict get $node operand] $id/operand]
        }
        binary - logical {
            dict set node left [Ids [dict get $node left] $id/left]
            dict set node right [Ids [dict get $node right] $id/right]
        }
        bind - return - break {
            if {[dict get $node value] ne ""} {
                dict set node value [Ids [dict get $node value] $id/value]
            }
        }
        function {
            dict set node body [Suite [dict get $node body] $id]
        }
        if {
            dict set node condition [Ids [dict get $node condition] $id/cond]
            dict set node then [Suite [dict get $node then] $id/then]
            if {[dict get $node else] ne ""} {
                dict set node else [Suite [dict get $node else] $id/else]
            }
        }
        loop {
            dict set node body [Suite [dict get $node body] $id]
        }
    }
    return $node
}

# NODE, the node with id ID in the tree AST, or "".
proc surface::findNode {ast id} {
    if {[dict get $ast id] eq $id} {
        return $ast
    }
    foreach child [surface::ast::Children $ast] {
        set found [surface::findNode $child $id]
        if {$found ne ""} {
            return $found
        }
    }
    return ""
}

proc surface::ast::Children {node} {
    switch -- [dict get $node kind] {
        program - suite    { return [dict get $node body] }
        list               { return [dict get $node items] }
        call               { return [concat [list [dict get $node callee]] [dict get $node args]] }
        unary - not        { return [list [dict get $node operand]] }
        binary - logical   { return [list [dict get $node left] [dict get $node right]] }
        bind - return - break {
            return [expr {[dict get $node value] eq "" ? {} : [list [dict get $node value]]}]
        }
        function           { return [list [dict get $node body]] }
        loop               { return [list [dict get $node body]] }
        if {
            set children [list [dict get $node condition] [dict get $node then]]
            if {[dict get $node else] ne ""} {
                lappend children [dict get $node else]
            }
            return $children
        }
    }
    return {}
}

# ---------------------------------------------------------------------------
# Formatting, for debugging and tests.
#
#   surface::formatAst AST ?-spans 1? ?-ids 1?
#
# Expressions are S-expressions; statements with suites span several lines,
# their suite indented by four spaces:
#
#   (bind x (int 10))
#   fn add (a b)
#       (binary + (name a) (name b))
#   bind y = if (name flag)
#       (int 1)
#   else
#       (int 2)
#
# With -spans 1 every node is followed by @LINE:COLUMN-ENDLINE:ENDCOLUMN;
# with -ids 1 by its id in angle brackets. Syntax errors of a recovering parse
# are listed after the statements as "! LINE:COLUMN MESSAGE".

proc surface::formatAst {ast args} {
    set options [dict create -spans 0 -ids 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "surface::formatAst: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set show [list [dict get $options -spans] [dict get $options -ids]]
    set lines {}
    if {[dict get $ast kind] in {program suite}} {
        foreach statement [dict get $ast body] {
            surface::ast::Statement $statement 0 $show lines
        }
    } else {
        surface::ast::Statement $ast 0 $show lines
    }
    if {[dict exists $ast diagnostics]} {
        foreach diagnostic [dict get $ast diagnostics] {
            lappend lines "! [dict get $diagnostic line]:[dict get $diagnostic column] [dict get $diagnostic message]"
        }
    }
    return [::join $lines \n]
}

proc surface::ast::At {node show} {
    lassign $show spans ids
    set text ""
    if {$spans} {
        set s [dict get $node span]
        append text " @[dict get $s line]:[dict get $s column]-[dict get $s endLine]:[dict get $s endColumn]"
    }
    if {$ids && [dict exists $node id]} {
        append text " <[dict get $node id]>"
    }
    return $text
}

proc surface::ast::Quote {text} {
    return "\"[string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t] $text]\""
}

proc surface::ast::Expr {node show} {
    set at [At $node $show]
    switch -- [dict get $node kind] {
        int     { return "(int [dict get $node text])$at" }
        string  { return "(str [Quote [dict get $node value]])$at" }
        bool    { return "(bool [dict get $node value])$at" }
        unit    { return "(unit)$at" }
        name    { return "(name [dict get $node name])$at" }
        qualname { return "(qualname [dict get $node namespace]::[dict get $node name])$at" }
        error   { return "(error)$at" }
        list {
            return "([::join [concat list [lmap item [dict get $node items] {Expr $item $show}]] { }])$at"
        }
        call {
            set parts [list call [Expr [dict get $node callee] $show]]
            foreach arg [dict get $node args] {
                lappend parts [Expr $arg $show]
            }
            return "([::join $parts { }])$at"
        }
        unary {
            return "(unary [dict get $node op] [Expr [dict get $node operand] $show])$at"
        }
        not {
            return "(not [Expr [dict get $node operand] $show])$at"
        }
        binary - logical {
            return "([dict get $node kind] [dict get $node op] [Expr [dict get $node left] $show] [Expr [dict get $node right] $show])$at"
        }
        bind {
            return "(bind [dict get $node name] [Expr [dict get $node value] $show])$at"
        }
        return - break {
            if {[dict get $node value] eq ""} {
                return "([dict get $node kind])$at"
            }
            return "([dict get $node kind] [Expr [dict get $node value] $show])$at"
        }
        continue { return "(continue)$at" }
    }
    error "surface::ast: not an expression node: [dict get $node kind]"
}

proc surface::ast::Body {suite indent show linesVar} {
    upvar 1 $linesVar lines
    foreach statement [dict get $suite body] {
        Statement $statement $indent $show lines
    }
}

# Lines of the if NODE, its first line starting with PREFIX.
proc surface::ast::If {node prefix indent show linesVar} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    lappend lines "$pad${prefix}if [Expr [dict get $node condition] $show][At $node $show]"
    Body [dict get $node then] [expr {$indent + 1}] $show lines
    if {[dict get $node else] ne ""} {
        lappend lines "${pad}else[At [dict get $node else] $show]"
        Body [dict get $node else] [expr {$indent + 1}] $show lines
    }
}

proc surface::ast::DomainText {domain} {
    if {[dict get $domain kind] eq "interval"} {
        return "[dict get $domain lo]..[dict get $domain hi]"
    }
    return "\{[join [dict get $domain values] {, }]\}"
}

proc surface::ast::Statement {node indent show linesVar} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    set at [At $node $show]
    switch -- [dict get $node kind] {
        typedecl {
            lappend lines "${pad}type [dict get $node name] = [dict get $node parent] in [DomainText [dict get $node domain]]$at"
            return
        }
        function {
            set params [lmap pair [dict get $node params] {lindex $pair 0}]
            lappend lines "${pad}fn [dict get $node name] ($params)$at"
            Body [dict get $node body] [expr {$indent + 1}] $show lines
            return
        }
        if {
            If $node "" $indent $show lines
            return
        }
        loop {
            lappend lines "${pad}loop$at"
            Body [dict get $node body] [expr {$indent + 1}] $show lines
            return
        }
        bind - return - break {
            set value [dict get $node value]
            if {$value ne "" && [dict get $value kind] eq "if"} {
                set prefix [expr {[dict get $node kind] eq "bind"
                    ? "bind [dict get $node name]$at = " : "[dict get $node kind]$at "}]
                If $value $prefix $indent $show lines
                return
            }
        }
    }
    lappend lines "$pad[Expr $node $show]"
}
