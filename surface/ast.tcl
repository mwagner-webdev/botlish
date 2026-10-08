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
#              imports (the file header's import and typeimport nodes in written
#              order; never statements of `body`, never walked by Children)
#   import     namespace (the imported namespace's whole path, "abi::x86_64"),
#              namespaceSpan -- `import NAMESPACE` (IMPORTS.md): a direct
#              dependency on exactly that namespace
#   typeimport namespace (the type's namespace path), namespaceSpan, name (the
#              type's own name), nameSpan -- `import type NAMESPACE::Name`:
#              exactly one short type name
#   suite      body (statements)                 an indented block
#   int        text (canonical decimal digits)
#   string     value (the decoded text)
#   char       text (canonical decimal codepoint of the one Unicode scalar
#              value the literal decoded to -- UnicodeChar, never String;
#              see UNICODE-CHAR-LITERALS.md)
#   bool       value (true | false)
#   unit
#   name       name
#   qualname   namespace, name, namespaceSpan, nameSpan  (NAMESPACE::NAME)
#   list       items (expressions)
#   anonstruct init (a fieldinits node)   { x: a, y: b }: an anonymous struct
#              value (STRUCTS.md)
#   namedstruct namespace ("" or the module namespace), name, nameSpan
#              (covers "NAMESPACE::NAME"), init (a fieldinits node)
#              Name { x: a, y: b }: a named struct construction
#   fieldinits fields ({name nameSpan value} dicts in written order) -- the
#              one shared field-initializer payload of anonstruct and
#              namedstruct
#   project    receiver, name, nameSpan   receiver.name: a field projection
#   call       callee, args, flags ({name NAME span SPAN} dicts, the call's
#              supplied flags in written order -- `f(x, :quiet)`; SPAN covers
#              ":quiet"; empty if none -- FLAGS.md)
#   methodcall receiver, name, nameSpan, args, flags   receiver.name(args): method-call
#              sugar (METHOD-SUGAR.md), the surface spelling of the ordinary
#              call name(receiver, args). Only the parser and the printer
#              know it by this name: lowering turns it into an ordinary call
#   unary      op (-), opSpan, operand
#   not        opSpan, operand
#   binary     op (+ - * == != < <= > >=), opSpan, left, right
#   logical    op (and | or), opSpan, left, right
#   bind       name, nameSpan, value (an expression or an if)
#   destructure  pattern, value (like a bind's) -- "{a, b: c} = value"
#              (STRUCT-DESTRUCTURING.md). pattern is {span SPAN fields
#              {FIELD...}}, a FIELD {name nameSpan span local localSpan nested
#              shorthand}: the struct field read (name: the LEFT name), the
#              binding made (local: the RIGHT name; the field's own name for
#              the shorthand) or, instead of a binding, a nested pattern the
#              field's value is destructured by (local ""). Only the parser
#              and the printer know it by this name: lowering turns it into
#              a hygienic temporary bind and ordinary projection binds.
#   function   name, nameSpan, params ({NAME SPAN TYPE TYPESPAN} tuples --
#              TYPE is "" and TYPESPAN is "" for an untyped parameter),
#              flags ({name NAME span SPAN} dicts: the declared flags in
#              written, canonical order -- `fn f(x, flags :a, :b)`; empty if
#              none; they follow the ordinary params -- FLAGS.md),
#              contexts ({name nameSpan type typeSpan} dicts: the declared
#              context parameters in written order -- `fn f(x, context io:
#              LinuxIO)`; empty if none; the last section -- CONTEXTS.md),
#              paramsSpan (from "(" to the end of the body: the function
#              literal), errors ({NAME SPAN} pairs, from the function's own
#              "errors E1, E2" clause, empty if none), proves (the proof
#              clauses, REFINEMENT-VALUES.md: a list of {outcome true|normal
#              param NAME paramSpan SPAN type TYPE typeSpan SPAN span SPAN}
#              dicts, at most one, empty if none; `normal` after `-> unit`, a
#              validator), body (suite),
#              nomethod (1 for `nomethod fn NAME(...)`, else 0), nomethodSpan
#              (the modifier word's span, or "") -- a property of the one
#              declaration: its author's declaration that it is never the
#              callee of method syntax (WARNINGS-METHOD-ELIGIBLE.md),
#              resume ("" or {type TYPE typeSpan SPAN span SPAN}: the
#              function's `resume TYPE` clause, COROUTINES.md -- the last
#              entry of its parameter list, never a parameter)
#   if         condition, then (suite), else (suite or ""). An "elif" clause
#              is not a node kind of its own (ELIF.md): the parser makes it an
#              ordinary `if` node (extra field `elif 1`) standing alone in a
#              synthetic else suite (extra field `elif 1`) of the previous
#              clause, spanning from its "elif" keyword to the end of the
#              chain -- the AST of `else:` + a nested `if`, plus the markers
#              formatAst needs to print it back as `elif`
#   loop       elementName, elementNameSpan, iterable (an expression, or ""
#              for the plain form), countName, countNameSpan, countStart,
#              countEnd (an expression, or "" unless this is the counted
#              form), direction (up | down, "" unless counted), endKind
#              (exclusive | inclusive, "" unless counted), clauses, body
#              (suite). `clauses` lists every iteration clause in written
#              order as dicts {kind (list | count) name nameSpan iterable
#              start end direction endKind}: none for a plain "loop:", one
#              for a single-domain loop, two or more for a lockstep loop
#              ("loop x in xs and i from 0 to n:", COLLECTING-LOOPS.md).
#              For a single-clause loop the per-form fields above mirror
#              that clause (exactly one of {iterable, countStart} is set);
#              for a lockstep loop they are all empty and `clauses` is the
#              whole description. "loop x in EXPR:" is a List traversal
#              binding x fresh each iteration; "loop i from START to END:"
#              an ascending traversal of START <= i < END, "from START
#              through END" of START <= i <= END, "down from START to END"
#              of START >= i > END and "down from START through END" of
#              START >= i >= END (START is always the value iteration
#              begins at: core/ir.tcl's `countloop`, R2A3-COUNTED-LOOPS-
#              FINAL-SOURCE.md, COLLECTING-LOOPS.md); plain "loop:" (no
#              clause) repeats until break
#   return     value (an expression, an if, or "")
#   break      value (an expression, an if, or "")
#   continue
#   typedecl   name, nameSpan, form, and then, for form `domain`: parent,
#              parentSpan, domain -- a top-level bounded-integer-refinement
#              declaration (surface/parser.tcl's TypeDecl; see
#              hir/sourcetypes.tcl for what it means). `domain` is {kind
#              interval lo LO loSpan .. hi HI hiSpan .. span ..} or {kind
#              exact values {V...} spans {SPAN...} span ..}, LO/HI/V decimal
#              text (a leading "-" allowed). For form `refined` ("refined
#              type NAME = CARRIER", REFINEMENT-VALUES.md): refinedSpan (the
#              modifier word), carrier (a surface::parser::TypeExpr result)
#              and carrierSpan -- a nominal refinement of the carrier type.
#   structdecl name, nameSpan, fields ({name nameSpan type typeSpan} dicts in
#              declared order; TYPE as surface::parser::TypeExpr returns it),
#              opaque (1 for `opaque struct NAME:`, else 0), opaqueSpan (the
#              modifier word's span, or ""), context (1 for `context struct
#              NAME:`, else 0) and contextSpan likewise (CONTEXTS.md)
#              -- a top-level nominal struct declaration ("struct NAME:"
#              followed by its indented "field: Type" lines; STRUCTS.md).
#              A declaration like typedecl: no runtime meaning, no binding.
#              `opaque` is a property of the one declaration (the declaring
#              module alone constructs and inspects its representation,
#              OPAQUE-STRUCTS.md), not a separate declaration kind; the
#              owner is not in the AST (the cached AST is importer- and
#              path-neutral): the loader supplies the module's namespace when
#              it lowers the declaration (surface/lower.tcl's StructDeclOf).
#   traitdecl  name, nameSpan, requirements ({name nameSpan params paramsSpan
#              resultType resultTypeSpan errors span} dicts in written order;
#              params are the function node's {NAME SPAN TYPE TYPESPAN}
#              tuples, errors {NAME SPAN} pairs) -- a top-level trait
#              declaration ("trait NAME:" followed by its indented
#              signature-only "fn ..." requirement lines; TRAITS.md). A
#              declaration like structdecl: no runtime meaning, no binding;
#              the owner (the declaring module) is supplied by the loader.
#              `context` (0|1) and `contextSpan`: the `context` modifier
#              (`context trait IO:`, CONTEXT-TRAITS.md), a property of the
#              one declaration kind, never a separate kind.
#   errordecl  name, nameSpan -- a top-level named-error declaration
#              ("error NAME", surface/parser.tcl's ErrorDecl; see
#              hir/errordecls.tcl for what it means). No runtime meaning,
#              exactly like typedecl.
#   with       form (context), formSpan, value -- "with context EXPR": a
#              declaration-like statement installing EXPR's value as the
#              execution-environment context of its type for the rest of
#              the scope (CONTEXTS.md); `form` leaves room for later `with`
#              declarations
#   fail       name, nameSpan -- "fail NAME": produces the named error's
#              completion (EXPLICIT-ERROR-COMPLETIONS.md).
#   yield      value -- "yield VALUE" (COROUTINES.md): sends VALUE outward,
#              suspends the coroutine, evaluates to the resume message
#   coroutinebind  pattern, value -- "coroutine {step: s, first: f} = CALL"
#              (COROUTINES.md): pattern is destructure-shaped ({span fields},
#              each field {name nameSpan local localSpan nested shorthand span},
#              name step or first), value the call that starts the coroutine
#              (a call, methodcall or handledcall node; anything else is the
#              HIR's COROUTINE-RHS-NOT-YIELDING). Only the parser and the
#              printer know it by this name: lowering turns it into the
#              construction and the eager start (surface/lower.tcl)
#   handledcall  call (a `call` or `methodcall` node), handlers (a list of {name nameSpan
#              body} dicts, one per "on NAME:" clause in written order;
#              body a suite) -- "CALL: on NAME: ... on NAME: ...". Only a
#              bare call expression may be handled this way (item 9).
#   error      a statement that could not be parsed (recovering parses only)
#
# Node ids
# --------
# `id` names a node by its place in the program's structure rather than by
# position, so it survives edits elsewhere (for tooling and incremental use).
# A statement's id is its parent's id, "/", and a key:
#
#   NAME()     function NAME          NAME=      binding of NAME
#   if loop return break continue destructure     KIND       any other
#   coroutine (a coroutine binding)
#                                                 expression statement
#
# the Nth statement with the same key among its siblings adding "#N" (N > 1).
# Inner nodes add their role: then, else, cond, value, callee, receiver, argN, itemN,
# left, right, operand; a destructure's value is "value" and its field N is
# "fieldN" (the field name read "fieldN/name", the binding it makes
# "fieldN/binding", a nested pattern's field M "fieldN/fieldM"); a parameter is NAME()/(PARAM)
# and a flag declaration NAME()/flag(FLAG); a call's supplied flag is ID/flag(FLAG). A top-level function
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
    if {[dict exists $program imports]} {
        dict set program imports [lmap import [dict get $program imports] {
            if {[dict get $import kind] eq "import"} {
                dict set import id "import([dict get $import namespace])"
            } else {
                dict set import id "import-type([dict get $import namespace]::[dict get $import name])"
            }
            set import
        }]
    }
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
            coroutinebind { set key coroutine }
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
        anonstruct - namedstruct {
            set init [dict get $node init]
            dict set init id $id/init
            set fields {}
            set index 1
            foreach field [dict get $init fields] {
                dict set field value [Ids [dict get $field value] $id/field$index]
                lappend fields $field
                incr index
            }
            dict set init fields $fields
            dict set node init $init
        }
        project {
            dict set node receiver [Ids [dict get $node receiver] $id/receiver]
        }
        methodcall {
            dict set node receiver [Ids [dict get $node receiver] $id/receiver]
            set args {}
            set index 1
            foreach arg [dict get $node args] {
                lappend args [Ids $arg $id/arg$index]
                incr index
            }
            dict set node args $args
        }
        binary - logical {
            dict set node left [Ids [dict get $node left] $id/left]
            dict set node right [Ids [dict get $node right] $id/right]
        }
        with - yield {
            dict set node value [Ids [dict get $node value] $id/value]
        }
        bind - return - break - destructure - coroutinebind {
            if {[dict get $node value] ne ""} {
                dict set node value [Ids [dict get $node value] $id/value]
            }
            if {[dict get $node kind] in {destructure coroutinebind}} {
                dict set node pattern [PatternIds [dict get $node pattern] $id]
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
            if {[dict get $node iterable] ne ""} {
                dict set node iterable [Ids [dict get $node iterable] $id/iterable]
            }
            if {[dict get $node countStart] ne ""} {
                dict set node countStart [Ids [dict get $node countStart] $id/start]
                dict set node countEnd [Ids [dict get $node countEnd] $id/end]
            }
            if {[llength [dict get $node clauses]] > 1} {
                set clauses {}
                set index 1
                foreach clause [dict get $node clauses] {
                    foreach field {iterable start end} {
                        if {[dict get $clause $field] ne ""} {
                            dict set clause $field [Ids [dict get $clause $field] $id/clause$index/$field]
                        }
                    }
                    lappend clauses $clause
                    incr index
                }
                dict set node clauses $clauses
            }
            dict set node body [Suite [dict get $node body] $id]
        }
        handledcall {
            dict set node call [Ids [dict get $node call] $id/call]
            set handlers {}
            set index 1
            foreach handler [dict get $node handlers] {
                dict set handler body [Suite [dict get $handler body] $id/on$index]
                lappend handlers $handler
                incr index
            }
            dict set node handlers $handlers
        }
    }
    return $node
}

# PATTERN (a destructuring pattern) with an id on every field: the Nth field
# of a pattern whose parent has id PARENT is PARENT/fieldN, so a nested
# pattern's fields are PARENT/fieldN/fieldM.
proc surface::ast::PatternIds {pattern parent} {
    set fields {}
    set index 1
    foreach field [dict get $pattern fields] {
        dict set field id $parent/field$index
        if {[dict get $field nested] ne ""} {
            dict set field nested [PatternIds [dict get $field nested] $parent/field$index]
        }
        lappend fields $field
        incr index
    }
    dict set pattern fields $fields
    return $pattern
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
        anonstruct - namedstruct {
            return [lmap field [dict get $node init fields] {dict get $field value}]
        }
        project            { return [list [dict get $node receiver]] }
        methodcall         { return [concat [list [dict get $node receiver]] [dict get $node args]] }
        binary - logical   { return [list [dict get $node left] [dict get $node right]] }
        bind - return - break - destructure - coroutinebind {
            return [expr {[dict get $node value] eq "" ? {} : [list [dict get $node value]]}]
        }
        with - yield       { return [list [dict get $node value]] }
        function           { return [list [dict get $node body]] }
        loop {
            if {[llength [dict get $node clauses]] > 1} {
                set children {}
                foreach clause [dict get $node clauses] {
                    foreach field {iterable start end} {
                        if {[dict get $clause $field] ne ""} {
                            lappend children [dict get $clause $field]
                        }
                    }
                }
                return [concat $children [list [dict get $node body]]]
            }
            if {[dict get $node iterable] ne ""} {
                return [list [dict get $node iterable] [dict get $node body]]
            }
            if {[dict get $node countStart] ne ""} {
                return [list [dict get $node countStart] [dict get $node countEnd] [dict get $node body]]
            }
            return [list [dict get $node body]]
        }
        if {
            set children [list [dict get $node condition] [dict get $node then]]
            if {[dict get $node else] ne ""} {
                lappend children [dict get $node else]
            }
            return $children
        }
        handledcall {
            set children [list [dict get $node call]]
            foreach handler [dict get $node handlers] {
                lappend children [dict get $handler body]
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
    if {[dict get $ast kind] eq "program" && [dict exists $ast imports]} {
        foreach import [dict get $ast imports] {
            if {[dict get $import kind] eq "import"} {
                lappend lines "(import [dict get $import namespace])[surface::ast::At $import $show]"
            } else {
                lappend lines "(import-type [dict get $import namespace]::[dict get $import name])[surface::ast::At $import $show]"
            }
        }
    }
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
        char    { return "(char [dict get $node text])$at" }
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
            foreach flag [dict get $node flags] {
                lappend parts :[dict get $flag name]
            }
            return "([::join $parts { }])$at"
        }
        methodcall {
            set parts [list methodcall [Expr [dict get $node receiver] $show] [dict get $node name]]
            foreach arg [dict get $node args] {
                lappend parts [Expr $arg $show]
            }
            foreach flag [dict get $node flags] {
                lappend parts :[dict get $flag name]
            }
            return "([::join $parts { }])$at"
        }
        anonstruct {
            return "([::join [concat struct [FieldsText $node $show]] { }])$at"
        }
        namedstruct {
            set name [dict get $node name]
            if {[dict get $node namespace] ne ""} {
                set name "[dict get $node namespace]::$name"
            }
            return "([::join [concat struct $name [FieldsText $node $show]] { }])$at"
        }
        project {
            return "(project [Expr [dict get $node receiver] $show] [dict get $node name])$at"
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
        destructure {
            return "(destructure [PatternText [dict get $node pattern] $show] [Expr [dict get $node value] $show])$at"
        }
        coroutinebind {
            return "(coroutine [PatternText [dict get $node pattern] $show] [Expr [dict get $node value] $show])$at"
        }
        yield {
            return "(yield [Expr [dict get $node value] $show])$at"
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

# The "(NAME EXPR)" pairs of a struct node's field initializers.
proc surface::ast::FieldsText {node show} {
    return [lmap field [dict get $node init fields] {
        format {(%s %s)} [dict get $field name] [Expr [dict get $field value] $show]
    }]
}

proc surface::ast::Body {suite indent show linesVar} {
    upvar 1 $linesVar lines
    foreach statement [dict get $suite body] {
        Statement $statement $indent $show lines
    }
}

# Lines of the if NODE, its first line starting with PREFIX. An else suite
# the parser made for an "elif" clause (ELIF.md) is printed as "elif" and its
# chain continued, not as an "else" holding a nested if.
proc surface::ast::If {node prefix indent show linesVar} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    set keyword if
    while 1 {
        lappend lines "$pad${prefix}$keyword [Expr [dict get $node condition] $show][At $node $show]"
        Body [dict get $node then] [expr {$indent + 1}] $show lines
        set else [dict get $node else]
        if {$else eq ""} {
            return
        }
        if {[dict exists $else elif]} {
            set node [lindex [dict get $else body] 0]
            set prefix ""
            set keyword elif
            continue
        }
        lappend lines "${pad}else[At $else $show]"
        Body $else [expr {$indent + 1}] $show lines
        return
    }
}

proc surface::ast::DomainText {domain} {
    if {[dict get $domain kind] eq "interval"} {
        return "[dict get $domain lo]..[dict get $domain hi]"
    }
    return "\{[join [dict get $domain values] {, }]\}"
}

# TYPE (a surface::parser::TypeExpr result: a bare name string, or a
# {NAME ARG} pair for an applied type) as canonical source text, e.g.
# "List[Small]" or "List[List[Small]]". Mirrors hir::types::show's own
# bracket notation for a *resolved* applied type (MINIMAL-APPLIED-LIST-
# TYPES.md), but over the raw, possibly-unresolvable surface syntax --
# surface/ast.tcl has no dependency on hir/*.tcl, so this is its own tiny
# formatter, not a call into hir::types::show.
proc surface::ast::showType {type} {
    if {[llength $type] == 1} {
        return $type
    }
    lassign $type name arg
    if {$name eq "fn"} {
        # A structural function type (surface::parser::FnType): its
        # canonical source spelling, fields in canonical order.
        return [format {%s{args: [%s], return: %s, errors: [%s]}} \
            [expr {[dict exists $arg kind] ? "Coroutine" : "Fn"}] \
            [join [lmap t [dict get $arg args] {showType $t}] {, }] \
            [showType [dict get $arg return]] [join [dict get $arg errors] {, }]]
    }
    return "$name\[[showType $arg]\]"
}

proc surface::ast::Statement {node indent show linesVar} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    set at [At $node $show]
    switch -- [dict get $node kind] {
        typedecl {
            if {[dict exists $node form] && [dict get $node form] eq "refined"} {
                lappend lines "${pad}refined type [dict get $node name] = [showType [dict get $node carrier]]$at"
                return
            }
            lappend lines "${pad}type [dict get $node name] = [dict get $node parent] in [DomainText [dict get $node domain]]$at"
            return
        }
        errordecl {
            lappend lines "${pad}error [dict get $node name]$at"
            return
        }
        traitdecl {
            set modifier [expr {[dict exists $node context] && [dict get $node context] ? "context " : ""}]
            lappend lines "${pad}${modifier}trait [dict get $node name]$at"
            foreach r [dict get $node requirements] {
                set params [lmap pair [dict get $r params] {
                    lassign $pair name _ type
                    expr {$type eq "" ? $name : "$name:[showType $type]"}
                }]
                set line "${pad}    fn [dict get $r name] ([join $params { }])"
                if {[dict get $r resultType] ne ""} {
                    append line " -> [showType [dict get $r resultType]]"
                }
                if {[dict get $r errors] ne {}} {
                    append line " errors [join [lmap pair [dict get $r errors] {lindex $pair 0}] {, }]"
                }
                lappend lines $line
            }
            return
        }
        structdecl {
            set modifier [expr {[dict exists $node opaque] && [dict get $node opaque] ? "opaque " : ""}]
            if {[dict exists $node context] && [dict get $node context]} {
                append modifier "context "
            }
            lappend lines "${pad}${modifier}struct [dict get $node name]$at"
            foreach field [dict get $node fields] {
                lappend lines "${pad}    [dict get $field name]: [showType [dict get $field type]]"
            }
            return
        }
        fail {
            lappend lines "${pad}fail [dict get $node name]$at"
            return
        }
        function {
            set params [lmap pair [dict get $node params] {
                lassign $pair name _ type
                expr {$type eq "" ? $name : "$name:[showType $type]"}
            }]
            # Explicit join, not a bare "($params)" interpolation: a typed
            # parameter's label can now contain "[" "]" (an applied type,
            # e.g. "List[Small]"), and Tcl's own list-to-string conversion
            # would brace-quote such an element for eval-safety, which
            # "(x:List[Small] y)" does not need (join, unlike bare
            # interpolation of a list value, never adds that quoting).
            if {[dict get $node flags] ne {}} {
                lappend params flags {*}[lmap flag [dict get $node flags] {string cat : [dict get $flag name]}]
            }
            if {[dict exists $node contexts] && [dict get $node contexts] ne {}} {
                lappend params context {*}[lmap c [dict get $node contexts] {
                    string cat [dict get $c name] : [showType [dict get $c type]]
                }]
            }
            if {[dict exists $node resume] && [dict get $node resume] ne ""} {
                lappend params resume [showType [dict get $node resume type]]
            }
            set modifier [expr {[dict exists $node nomethod] && [dict get $node nomethod] ? "nomethod " : ""}]
            set line "${pad}${modifier}fn [dict get $node name] ([join $params { }])"
            if {[dict exists $node proves]} {
                foreach clause [dict get $node proves] {
                    append line " proves [dict get $clause param]: [showType [dict get $clause type]]"
                }
            }
            if {[dict get $node errors] ne {}} {
                append line " errors [join [lmap pair [dict get $node errors] {lindex $pair 0}] {, }]"
            }
            lappend lines "$line$at"
            Body [dict get $node body] [expr {$indent + 1}] $show lines
            return
        }
        handledcall {
            HandledCall $node $indent $show lines
            return
        }
        if {
            If $node "" $indent $show lines
            return
        }
        loop {
            if {[llength [dict get $node clauses]] > 0} {
                lappend lines "${pad}loop [join [lmap clause [dict get $node clauses] {Clause $clause $show}] { and }]$at"
            } else {
                lappend lines "${pad}loop$at"
            }
            Body [dict get $node body] [expr {$indent + 1}] $show lines
            return
        }
        with {
            lappend lines "${pad}with [dict get $node form]$at [Expr [dict get $node value] $show]"
            return
        }
        bind - return - break - destructure - coroutinebind {
            set value [dict get $node value]
            set prefix [switch -- [dict get $node kind] {
                bind { expr {"bind [dict get $node name]$at = "} }
                destructure { expr {"destructure [PatternText [dict get $node pattern] $show]$at = "} }
                coroutinebind { expr {"coroutine [PatternText [dict get $node pattern] $show]$at = "} }
                default { expr {"[dict get $node kind]$at "} }
            }]
            if {$value ne "" && [dict get $value kind] eq "if"} {
                If $value $prefix $indent $show lines
                return
            }
            if {$value ne "" && [dict get $value kind] eq "handledcall"} {
                HandledCall $value $indent $show lines $prefix
                return
            }
        }
    }
    lappend lines "$pad[Expr $node $show]"
}

# Source text of the destructuring PATTERN, as written: "{a, b: c, d: {e}}"
# (with -spans, each field entry is followed by its @LINE:COLUMN-...).
proc surface::ast::PatternText {pattern show} {
    set parts {}
    foreach field [dict get $pattern fields] {
        if {[dict get $field nested] ne ""} {
            set text "[dict get $field name]: [PatternText [dict get $field nested] $show]"
        } elseif {[dict get $field shorthand]} {
            set text [dict get $field name]
        } else {
            set text "[dict get $field name]: [dict get $field local]"
        }
        lappend parts "$text[At $field $show]"
    }
    return "\{[::join $parts {, }]\}"
}

# Source text of one loop iteration CLAUSE (see the `loop` node above).
proc surface::ast::Clause {clause show} {
    set name [dict get $clause name]
    if {[dict get $clause kind] eq "list"} {
        return "$name in [Expr [dict get $clause iterable] $show]"
    }
    set from [expr {[dict get $clause direction] eq "down" ? "down from" : "from"}]
    set word [expr {[dict get $clause endKind] eq "inclusive" ? "through" : "to"}]
    return "$name $from [Expr [dict get $clause start] $show] $word [Expr [dict get $clause end] $show]"
}

# Lines of the handled-call NODE ("CALL: on NAME: ... on NAME: ..."), its
# first line starting with PREFIX (mirrors If's own PREFIX convention).
proc surface::ast::HandledCall {node indent show linesVar {prefix ""}} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    lappend lines "$pad${prefix}[Expr [dict get $node call] $show]:[At $node $show]"
    foreach handler [dict get $node handlers] {
        lappend lines "[string repeat {    } [expr {$indent + 1}]]on [dict get $handler name]:"
        Body [dict get $handler body] [expr {$indent + 2}] $show lines
    }
}
