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
#              order; never statements of `body`, never walked by Children),
#              direct (the span of the file's `direct module` declaration,
#              its first construct, or "": DIRECT-MODULES.md)
#   import     namespace (the imported namespace's whole path, "std::abi::x86_64"),
#              namespaceSpan, rooted (1 for a path written from the root,
#              `import ::std::list`, STD-NAMESPACE.md; the namespace is the
#              canonical path either way) -- `import NAMESPACE` (IMPORTS.md):
#              a direct dependency on exactly that namespace
#   typeimport namespace (the type's namespace path), namespaceSpan, name (the
#              type's own name), nameSpan, rooted -- `import type NAMESPACE::Name`:
#              exactly one short type name
#   suite      body (statements)                 an indented block
#   int        text (canonical decimal digits)
#   decimal    text (the decimal number a decimal literal spells, exactly as
#              written but with a lowercase exponent marker: `1.50`, `2.5e-3`;
#              its type is decided by lowering, FLOAT64-MILESTONE-1.md)
#   string     value (the decoded text)
#   char       text (canonical decimal codepoint of the one Unicode scalar
#              value the literal decoded to -- UnicodeChar, never String;
#              see UNICODE-CHAR-LITERALS.md)
#   bool       value (true | false)
#   unit
#   name       name
#   qualname   namespace, name, namespaceSpan, nameSpan, rooted (NAMESPACE::NAME;
#              rooted 1 for ::NAMESPACE::NAME, whose NAMESPACE is a namespace
#              path from the root, never a type qualifier; a type name or an
#              error name written rooted is kept canonical, with no flag:
#              STD-NAMESPACE.md)
#   list       items (expressions)
#   anonstruct init (a fieldinits node)   { x: a, y: b }: an anonymous struct
#              value (STRUCTS.md)
#   namedstruct namespace ("" or the module namespace), name, nameSpan
#              (covers "NAMESPACE::NAME"), init (a fieldinits node)
#              Name { x: a, y: b }: a named struct construction; with
#              typeArg (a surface::parser::TypeExpr result) and typeArgSpan,
#              the construction of an applied type: NAME[TYPE] { ... }
#              (BINARY-LAYOUT.md, `LayoutStruct[Pair] {...}`; NAME is then
#              the bare constructor name); with typeArgs and typeArgSpans
#              (lists) instead, one of several type arguments,
#              Pair[int, str] { ... } (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md)
#   fieldinits fields ({name nameSpan value} dicts in written order) -- the
#              one shared field-initializer payload of anonstruct and
#              namedstruct
#   project    receiver, name, nameSpan   receiver.name: a field projection
#   call       callee, args, flags ({name NAME span SPAN} dicts, the call's
#              supplied flags in written order -- `f(x, :quiet)`; SPAN covers
#              ":quiet"; empty if none -- FLAGS.md); optionally imprints,
#              imprintSpans: the explicit imprints `f[T, ...](...)`, type
#              expressions in written order (C-ABI-TYPES.md, "Imprinting")
#   methodcall receiver, name, nameSpan, args, flags, ?imprints, imprintSpans?
#              receiver.name(args): method-call
#              sugar (METHOD-SUGAR.md), the surface spelling of the ordinary
#              call name(receiver, args). Only the parser and the printer
#              know it by this name: lowering turns it into an ordinary call
#   unary      op (-), opSpan, operand
#   not        opSpan, operand
#   binary     op (+ - * == != < <= > >=), opSpan, left, right
#   logical    op (and | or), opSpan, left, right
#   bind       name, nameSpan, value (an expression, an if or a loop)
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
#              LinuxIO)`; empty if none -- CONTEXTS.md), variadic ("" or
#              {name nameSpan type typeSpan span}: the variadic parameter,
#              `variadic xs: List[int]`, the last binding of the list --
#              VARIADICS-VERTICAL-SLICE-1.md),
#              paramsSpan (from "(" to the end of the body: the function
#              literal), resultType (the "-> TYPE" result annotation as
#              surface::parser::TypeExpr returns it, "" if none) and
#              resultTypeSpan, errors ({NAME SPAN} pairs, from the function's own
#              "errors E1, E2" clause, empty if none), proves (the proof
#              clauses, REFINEMENT-VALUES.md: a list of {outcome true|normal
#              param NAME paramSpan SPAN type TYPE typeSpan SPAN span SPAN}
#              dicts, at most one, empty if none; `normal` after `-> unit`, a
#              validator), body (suite),
#              nomethod (1 for `nomethod fn NAME(...)`, else 0), nomethodSpan,
#              exported (the foreign ABI of `exported c fn NAME(...)`: c;
#              "" for an ordinary function), exportedSpan, callback (the
#              foreign ABI of `callback c fn NAME(...)`: c; ""),
#              callbackSpan
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
#   return     value (an expression, an if, a loop, or "")
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
#              NAME:`, else 0) and contextSpan likewise (CONTEXTS.md), and
#              for a parameterized struct only, slots ({name nameSpan trait
#              traitSpan} dicts in written order, TRAIT the spelled trait of
#              `satisfies` or "": TRAIT-CONSTRAINED-IMPRINTED-TYPES.md),
#              and for a struct with an `identity` clause only, identity
#              ({form formSpan fields fieldSpans span}: REPRESENTATION-
#              INDEPENDENT-VALUE-IDENTITY.md)
#              -- a top-level nominal struct declaration ("struct NAME:"
#              followed by its indented "field: Type" lines; STRUCTS.md).
#              A declaration like typedecl: no runtime meaning, no binding.
#              `opaque` is a property of the one declaration (the declaring
#              module alone constructs and inspects its representation,
#              OPAQUE-STRUCTS.md), not a separate declaration kind; the
#              owner is not in the AST (the cached AST is importer- and
#              path-neutral): the loader supplies the module's namespace when
#              it lowers the declaration (surface/lower.tcl's StructDeclOf).
#   layoutdecl name, nameSpan, size, sizeSpan, align, alignSpan, fields
#              (and `union 1` for a union layout, LAYOUT-UNIONS.md: its
#              fields are its alternatives, each at offset 0)
#              ({name nameSpan type typeSpan offset offsetSpan} dicts in
#              written order; TYPE as surface::parser::TypeExpr returns it,
#              SIZE/ALIGN/OFFSET decimal text) -- a top-level fixed binary
#              layout ("layout NAME:" with its indented `size`, `align` and
#              `field NAME: TYPE at OFFSET` lines; BINARY-LAYOUT.md). A
#              declaration like structdecl: no runtime meaning, no binding;
#              the owner (the declaring module) is supplied by the loader.
#   enumdecl   name, nameSpan, cases ({name nameSpan} dicts in declaration
#              order) -- a top-level enum declaration ("enum NAME:" followed
#              by its indented, comma-separated payload-free cases; ENUMS.md).
#              A declaration like structdecl: no runtime meaning, no binding;
#              the owner (the declaring module) is supplied by the loader.
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
#   errordecl  name, nameSpan, fields -- a top-level named-error declaration
#              ("error NAME", surface/parser.tcl's ErrorDecl; see
#              hir/errordecls.tcl for what it means). FIELDS is its payload
#              (ERROR-PAYLOADS.md): one {name nameSpan type typeSpan} dict per
#              declared payload field, in written order, exactly a
#              structdecl's; empty for a payload-free error. No runtime
#              meaning, exactly like typedecl.
#   externlib  link (library | framework), dependency (its name: an externlib
#              has no `name`, being no member), dependencySpan, linkage (default |
#              static), linkageSpan, path, pathSpan -- "extern c library NAME
#              [static [at PATH]]" (C-FFI.md) or "extern c framework NAME"
#              (NATIVE-LINK-PLAN-MILESTONE-1.md): a native dependency the
#              program's link plan names (-lNAME, a static archive, -framework
#              NAME); PATH "" unless written; no runtime meaning, no binding,
#              associated with no declaration
#   externfn   name, nameSpan, symbol (the `named` link symbol, "" for the
#              name itself), symbolSpan, params ({name nameSpan type typeSpan
#              access escape factsSpan} dicts in written order: access read |
#              write | "", escape declared-noescape | proven-noescape |
#              captures | "", "" an unstated fact), paramsSpan, variadic
#              (1 when the list ends with the bare word `variadic`, C's
#              `...` -- VARIADICS-VERTICAL-SLICE-1.md) and variadicSpan,
#              resultType,
#              resultTypeSpan, provenance (independent | {alias PARAM} |
#              ""), provenanceSpan -- "extern c fn NAME(...) -> T" (C-FFI.md):
#              a C ABI declaration with no body. A declaration like
#              structdecl: no runtime meaning; the loader supplies its module
#   with       form (context), formSpan, value -- "with context EXPR": a
#              declaration-like statement installing EXPR's value as the
#              execution-environment context of its type for the rest of
#              the scope (CONTEXTS.md); `form` leaves room for later `with`
#              declarations
#   static     operation (the static operation's name: "compile"),
#              operationSpan, staticSpan (the "static" word), body (a suite)
#              -- "static compile:" followed by an indented block
#              (STATIC-COMPILE.md): a static intrinsic, a compiler-directed
#              syntactic operation on the captured block. The body is parsed
#              syntax, never text; it is a statement or the value of a
#              binding, return or destructuring (like an if)
#   fail       name, nameSpan, payload -- "fail NAME": produces the named
#              error's completion (EXPLICIT-ERROR-COMPLETIONS.md). PAYLOAD is
#              "" or, for "fail NAME {field: value, ...}", the anonstruct
#              node of its field initializers (ERROR-PAYLOADS.md).
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
#   handledcall  call (a `call` or `methodcall` node, or a `binary` node of an
#              arithmetic operator + - * /), handlers (a list of {name nameSpan
#              body binding bindingSpan pattern} dicts, one per "on NAME:"
#              clause in written order; body a suite; binding the name the
#              whole payload is bound to in "on NAME details:", else "";
#              pattern the destructuring pattern of "on NAME {a, b: c}:", else
#              "" -- ERROR-PAYLOADS.md) -- "CALL: on NAME: ... on NAME: ...".
#              Only a bare call expression may be handled this way (item 9).
#   error      a statement that could not be parsed (recovering parses only)
#
# Every named top-level declaration -- function, bind, typedecl, errordecl,
# structdecl, enumdecl, traitdecl, layoutdecl, externfn -- may also carry
# `private` (1 for `private DECLARATION`) and `privateSpan` (the modifier
# word's span; the node's span then starts there): the declaration is
# accessible only to code of its own module
# (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md). Absent on every other
# node and on a public declaration. A property of the one declaration, like
# `opaque` and `nomethod`, never a node kind of its own; the loader collects
# it into the module's declaration record (surface/modules.tcl's ModuleDecl).
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
# A diagnostic is a dict {file line column start end endLine endColumn
# message}: the span of what is wrong, as a span records it (a zero-width
# span is a position where something is missing), and the message, last
# (an error code's last element is its text). surface::raise throws one
# as {SURFACE SYNTAX DIAGNOSTIC} with the message "FILE:LINE:COLUMN: TEXT".

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
        end [dict get $span end] endLine [dict get $span endLine] \
        endColumn [dict get $span endColumn] message $message]
}

# The span of syntax DIAGNOSTIC (surface::diagnostic): where it starts and
# ends, in the shape of any other span.
proc surface::diagnosticSpan {diagnostic} {
    return [surface::ast::span [dict get $diagnostic file] [dict get $diagnostic start] \
        [dict get $diagnostic end] [dict get $diagnostic line] [dict get $diagnostic column] \
        [dict get $diagnostic endLine] [dict get $diagnostic endColumn]]
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
    if {$parent eq ""} {
        return $role
    }
    return "$parent/$role"
}

proc surface::ast::Statements {statements parent} {
    set counts [dict create]
    set result {}
    foreach statement $statements {
        switch -- [dict get $statement kind] {
            function { set key "[dict get $statement name]()" }
            classdecl { set key "class([dict get $statement name])" }
            dfadecl  { set key "dfa([dict get $statement name])" }
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
            } elseif {[llength [dict get $node clauses]] == 1} {
                # The one clause the per-form fields mirror: the same operand
                # nodes, ids included.
                set clause [lindex [dict get $node clauses] 0]
                foreach {field mirror} {iterable iterable start countStart end countEnd} {
                    if {[dict get $clause $field] ne ""} {
                        dict set clause $field [dict get $node $mirror]
                    }
                }
                dict set node clauses [list $clause]
            }
            dict set node body [Suite [dict get $node body] $id]
        }
        handledcall {
            dict set node call [Ids [dict get $node call] $id/call]
            set handlers {}
            set index 1
            foreach handler [dict get $node handlers] {
                dict set handler body [Suite [dict get $handler body] $id/on$index]
                if {[dict exists $handler pattern] && [dict get $handler pattern] ne ""} {
                    dict set handler pattern [PatternIds [dict get $handler pattern] $id/on$index/payload]
                }
                lappend handlers $handler
                incr index
            }
            dict set node handlers $handlers
        }
        fail {
            if {[dict exists $node payload] && [dict get $node payload] ne ""} {
                dict set node payload [Ids [dict get $node payload] $id/payload]
            }
        }
        static {
            dict set node body [Suite [dict get $node body] $id]
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
            if {[dict get $node value] eq ""} {
                return {}
            }
            return [list [dict get $node value]]
        }
        with - yield       { return [list [dict get $node value]] }
        function - static  { return [list [dict get $node body]] }
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
        fail {
            if {[dict exists $node payload] && [dict get $node payload] ne ""} {
                return [list [dict get $node payload]]
            }
        }
    }
    return {}
}

# NODE with each of its child nodes (Children's, in Children's order)
# replaced by the result of calling the command prefix CMD on it. Children and
# MapChildren are one traversal: keep them in step (tests/bot-modules.test's
# bm-ast-map-children-parity checks them over the corpus).
proc surface::ast::MapChildren {node cmd} {
    switch -- [dict get $node kind] {
        program - suite {
            dict set node body [lmap child [dict get $node body] {{*}$cmd $child}]
        }
        list {
            dict set node items [lmap child [dict get $node items] {{*}$cmd $child}]
        }
        call {
            dict set node callee [{*}$cmd [dict get $node callee]]
            dict set node args [lmap child [dict get $node args] {{*}$cmd $child}]
        }
        unary - not {
            dict set node operand [{*}$cmd [dict get $node operand]]
        }
        anonstruct - namedstruct {
            dict set node init fields [lmap field [dict get $node init fields] {
                dict set field value [{*}$cmd [dict get $field value]]
            }]
        }
        project {
            dict set node receiver [{*}$cmd [dict get $node receiver]]
        }
        methodcall {
            dict set node receiver [{*}$cmd [dict get $node receiver]]
            dict set node args [lmap child [dict get $node args] {{*}$cmd $child}]
        }
        binary - logical {
            dict set node left [{*}$cmd [dict get $node left]]
            dict set node right [{*}$cmd [dict get $node right]]
        }
        bind - return - break - destructure - coroutinebind {
            if {[dict get $node value] ne ""} {
                dict set node value [{*}$cmd [dict get $node value]]
            }
        }
        with - yield {
            dict set node value [{*}$cmd [dict get $node value]]
        }
        function - static {
            dict set node body [{*}$cmd [dict get $node body]]
        }
        loop {
            if {[llength [dict get $node clauses]] > 1} {
                dict set node clauses [lmap clause [dict get $node clauses] {
                    foreach field {iterable start end} {
                        if {[dict get $clause $field] ne ""} {
                            dict set clause $field [{*}$cmd [dict get $clause $field]]
                        }
                    }
                    set clause
                }]
            } elseif {[dict get $node iterable] ne ""} {
                dict set node iterable [{*}$cmd [dict get $node iterable]]
            } elseif {[dict get $node countStart] ne ""} {
                dict set node countStart [{*}$cmd [dict get $node countStart]]
                dict set node countEnd [{*}$cmd [dict get $node countEnd]]
            }
            dict set node body [{*}$cmd [dict get $node body]]
        }
        if {
            dict set node condition [{*}$cmd [dict get $node condition]]
            dict set node then [{*}$cmd [dict get $node then]]
            if {[dict get $node else] ne ""} {
                dict set node else [{*}$cmd [dict get $node else]]
            }
        }
        handledcall {
            dict set node call [{*}$cmd [dict get $node call]]
            dict set node handlers [lmap handler [dict get $node handlers] {
                dict set handler body [{*}$cmd [dict get $handler body]]
            }]
        }
        fail {
            if {[dict exists $node payload] && [dict get $node payload] ne ""} {
                dict set node payload [{*}$cmd [dict get $node payload]]
            }
        }
    }
    return $node
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
    if {[dict get $ast kind] eq "program" && [dict exists $ast direct] && [dict get $ast direct] ne ""} {
        # The module modifier (DIRECT-MODULES.md), first like in the file.
        lappend lines "(direct-module)[surface::ast::At [dict create span [dict get $ast direct]] $show]"
    }
    if {[dict get $ast kind] eq "program" && [dict exists $ast imports]} {
        foreach import [dict get $ast imports] {
            set root [surface::ast::Root $import]
            if {[dict get $import kind] eq "import"} {
                lappend lines "(import $root[dict get $import namespace])[surface::ast::At $import $show]"
            } else {
                lappend lines "(import-type $root[dict get $import namespace]::[dict get $import name])[surface::ast::At $import $show]"
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

# "::" for a node whose namespace path was written rooted (`::std::list`,
# STD-NAMESPACE.md), else "".
proc surface::ast::Root {node} {
    if {[dict getdef $node rooted 0]} {
        return ::
    }
    return ""
}

proc surface::ast::Quote {text} {
    return "\"[string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t] $text]\""
}

proc surface::ast::Expr {node show} {
    set at [At $node $show]
    switch -- [dict get $node kind] {
        int     { return "(int [dict get $node text])$at" }
        decimal { return "(decimal [dict get $node text])$at" }
        char    { return "(char [dict get $node text])$at" }
        string  { return "(str [Quote [dict get $node value]])$at" }
        bool    { return "(bool [dict get $node value])$at" }
        unit    { return "(unit)$at" }
        name    { return "(name [dict get $node name])$at" }
        qualname { return "(qualname [Root $node][dict get $node namespace]::[dict get $node name])$at" }
        error   { return "(error)$at" }
        list {
            return "([::join [concat list [lmap item [dict get $node items] {Expr $item $show}]] { }])$at"
        }
        call {
            set parts [list call [Expr [dict get $node callee] $show][ImprintsText $node]]
            foreach arg [dict get $node args] {
                lappend parts [Expr $arg $show]
            }
            foreach flag [dict get $node flags] {
                lappend parts :[dict get $flag name]
            }
            return "([::join $parts { }])$at"
        }
        methodcall {
            set parts [list methodcall [Expr [dict get $node receiver] $show] [dict get $node name][ImprintsText $node]]
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
                set name "[Root $node][dict get $node namespace]::$name"
            }
            if {[dict exists $node typeArg]} {
                append name "\[[showType [dict get $node typeArg]]\]"
            }
            if {[dict exists $node typeArgs]} {
                append name "\[[::join [lmap t [dict get $node typeArgs] {showType $t}] {, }]\]"
            }
            return "([::join [concat struct $name [FieldsText $node $show]] { }])$at"
        }
        project {
            if {[dict exists $node indices]} {
                set indices [join [lmap index [dict get $node indices] {string cat \[ [dict get $index value] \]}] {}]
                return "(project [Expr [dict get $node receiver] $show] [dict get $node name]$indices)$at"
            }
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
# The explicit imprints of call NODE as written ("[T, U]"), or "".
proc surface::ast::ImprintsText {node} {
    if {![dict exists $node imprints]} {
        return ""
    }
    return "\[[::join [lmap t [dict get $node imprints] {showType $t}] {, }]\]"
}

proc surface::ast::showType {type} {
    if {[llength $type] == 1} {
        return $type
    }
    if {[llength $type] == 3 && [lindex $type 0] eq "array"} {
        # A fixed array representation (surface::parser::ArrayTypeExpr,
        # FIXED-LAYOUT-ARRAYS.md).
        return "array [lindex $type 1] of [showType [lindex $type 2]]"
    }
    if {[llength $type] in {3 4} && [lindex $type 0] eq "refine"} {
        # A scalar refinement (surface::parser::ScalarRefinement,
        # DECIMAL-ROUNDED-MILESTONE-1.md), its parameters as written -- of
        # an applied type, after it (LIST-CARDINALITY-REFINEMENTS.md).
        set head [lindex $type 1]
        if {[llength $type] == 4} {
            set head [showType [lindex $type 3]]
        }
        return "$head{[join [lmap field [lindex $type 2] {join $field {: }}] {, }]}"
    }
    if {[llength $type] == 3 && [lindex $type 0] eq "apply"} {
        # An application of several type arguments (surface::parser::
        # TypeExpr, TRAIT-CONSTRAINED-IMPRINTED-TYPES.md).
        return "[lindex $type 1]\[[join [lmap t [lindex $type 2] {showType $t}] {, }]\]"
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
    set first [llength $lines]
    StatementLines $node $indent $show lines
    if {[dict getdef $node private 0] && [llength $lines] > $first} {
        # `private` (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md) is
        # written first, before every other modifier of the declaration.
        set pad [string repeat {    } $indent]
        set line [lindex $lines $first]
        lset lines $first "${pad}private [string range $line [string length $pad] end]"
    }
}

proc surface::ast::StatementLines {node indent show linesVar} {
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
            if {[dict exists $node fields] && [dict get $node fields] ne {}} {
                lappend lines "${pad}error [dict get $node name]:$at"
                foreach field [dict get $node fields] {
                    lappend lines "${pad}    [dict get $field name]: [showType [dict get $field type]]"
                }
                return
            }
            lappend lines "${pad}error [dict get $node name]$at"
            return
        }
        classdecl {
            lappend lines "${pad}[DfaClassText $node]$at"
            return
        }
        dfadecl {
            lappend lines "${pad}dfa [dict get $node name] over [dict get $node alphabet]$at"
            foreach c [dict get $node classes] {
                lappend lines "${pad}    [DfaClassText $c]"
            }
            foreach state [dict get $node states] {
                lappend lines "${pad}    [dict get $state name]:"
                foreach t [dict get $state transitions] {
                    lappend lines "${pad}        [DfaItemsText [dict get $t items]] -> [DfaActionText $t]"
                }
            }
            return
        }
        enumdecl {
            lappend lines "${pad}enum [dict get $node name]$at"
            foreach case [dict get $node cases] {
                lappend lines "${pad}    [dict get $case name],"
            }
            return
        }
        layoutdecl {
            set union [expr {[dict exists $node union] && [dict get $node union]}]
            lappend lines "${pad}[expr {$union ? "union layout" : "layout"}] [dict get $node name]$at"
            lappend lines "${pad}    size [dict get $node size]"
            lappend lines "${pad}    align [dict get $node align]"
            foreach field [dict get $node fields] {
                if {$union} {
                    lappend lines "${pad}    alternative [dict get $field name]: [showType [dict get $field type]]"
                } else {
                    lappend lines "${pad}    field [dict get $field name]: [showType [dict get $field type]] at [dict get $field offset]"
                }
            }
            return
        }
        traitdecl {
            set modifier [expr {[dict exists $node context] && [dict get $node context] ? "context " : ""}]
            lappend lines "${pad}${modifier}trait [dict get $node name]$at"
            foreach r [dict get $node requirements] {
                set params [lmap pair [dict get $r params] {
                    lassign $pair name _ type
                    if {$type eq ""} {set name} else {string cat "$name:[showType $type]"}
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
        externlib {
            set line "${pad}extern c [dict get $node link] [Quote [dict get $node dependency]]"
            if {[dict get $node linkage] eq "static"} {
                append line " static"
            }
            if {[dict get $node path] ne ""} {
                append line " at [Quote [dict get $node path]]"
            }
            lappend lines $line$at
            return
        }
        externfn {
            set line "${pad}extern c fn [dict get $node name]"
            if {[dict get $node symbol] ne ""} {
                append line " named [Quote [dict get $node symbol]]"
            }
            set params [lmap param [dict get $node params] {
                set text "[dict get $param name]: [showType [dict get $param type]]"
                if {[dict get $param access] ne ""} {
                    append text " [dict get $param access]"
                }
                switch -- [dict get $param escape] {
                    declared-noescape { append text " noescape" }
                    proven-noescape { append text " proven noescape" }
                    captures { append text " captures" }
                }
                set text
            }]
            if {[dict getdef $node variadic 0]} {
                lappend params variadic
            }
            append line "([join $params {, }]) -> [showType [dict get $node resultType]]"
            switch -- [lindex [dict get $node provenance] 0] {
                independent { append line " independent" }
                alias { append line " alias [lindex [dict get $node provenance] 1]" }
            }
            lappend lines "$line$at"
            return
        }
        structdecl {
            set modifier [expr {[dict exists $node opaque] && [dict get $node opaque] ? "opaque " : ""}]
            if {[dict exists $node context] && [dict get $node context]} {
                append modifier "context "
            }
            set slots ""
            if {[dict exists $node slots]} {
                set slots "\[[join [lmap slot [dict get $node slots] {
                    if {[dict get $slot trait] eq ""} {
                        dict get $slot name
                    } else {
                        string cat [dict get $slot name] " satisfies " [dict get $slot trait]
                    }
                }] {, }]\]"
            }
            lappend lines "${pad}${modifier}struct [dict get $node name]$slots$at"
            foreach field [dict get $node fields] {
                lappend lines "${pad}    [dict get $field name]: [showType [dict get $field type]]"
            }
            if {[dict exists $node identity]} {
                set identity [dict get $node identity]
                lappend lines "${pad}    identity [dict get $identity form]([join [dict get $identity fields] {, }])"
            }
            return
        }
        fail {
            if {[dict exists $node payload] && [dict get $node payload] ne ""} {
                lappend lines "${pad}fail [dict get $node name] [Expr [dict get $node payload] $show]$at"
            } else {
                lappend lines "${pad}fail [dict get $node name]$at"
            }
            return
        }
        function {
            set params [lmap pair [dict get $node params] {
                lassign $pair name _ type _ place
                if {$place ne ""} {
                    set name "place $name"
                }
                if {$type eq ""} {set name} else {string cat "$name:[showType $type]"}
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
            if {[dict exists $node variadic] && [dict get $node variadic] ne ""} {
                lappend params variadic "[dict get $node variadic name]:[showType [dict get $node variadic type]]"
            }
            if {[dict exists $node resume] && [dict get $node resume] ne ""} {
                lappend params resume [showType [dict get $node resume type]]
            }
            set modifier [expr {[dict exists $node nomethod] && [dict get $node nomethod] ? "nomethod " : ""}]
            if {[dict getdef $node exported ""] ne ""} {
                append modifier "exported [dict get $node exported] "
            }
            if {[dict getdef $node callback ""] ne ""} {
                append modifier "callback [dict get $node callback] "
            }
            set line "${pad}${modifier}fn [dict get $node name] ([join $params { }])"
            if {[dict exists $node resultType] && [dict get $node resultType] ne ""} {
                append line " -> [showType [dict get $node resultType]]"
            }
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
            Loop $node "" $indent $show lines
            return
        }
        with {
            lappend lines "${pad}with [dict get $node form]$at [Expr [dict get $node value] $show]"
            return
        }
        static {
            StaticIntrinsic $node "" $indent $show lines
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
            if {$value ne "" && [dict get $value kind] eq "loop"} {
                Loop $value $prefix $indent $show lines
                return
            }
            if {$value ne "" && [dict get $value kind] eq "handledcall"} {
                HandledCall $value $indent $show lines $prefix
                return
            }
            if {$value ne "" && [dict get $value kind] eq "static"} {
                StaticIntrinsic $value $prefix $indent $show lines
                return
            }
        }
    }
    lappend lines "$pad[Expr $node $show]"
}

# Lines of the static intrinsic NODE ("static OPERATION" and its captured
# block, STATIC-COMPILE.md), its first line starting with PREFIX.
# The source text of a dfa or class declaration's items (surface/parser.tcl's
# DfaItems), a class declaration, and a transition's action, as written.
proc surface::ast::DfaItemsText {items} {
    return [join [lmap item $items {
        switch -- [dict get $item kind] {
            sym - seq { dict get $item text }
            any - end { dict get $item kind }
            class {
                set name [dict get $item name]
                if {[dict get $item namespace] ne ""} {
                    set name [dict get $item namespace]::$name
                }
                string cat [expr {[dict get $item rooted] ? "::" : ""}] $name
            }
        }
    }] " "]
}

proc surface::ast::DfaClassText {node} {
    set text "class [dict get $node name] = [DfaItemsText [dict get $node items]]"
    if {[dict get $node except] ne {}} {
        append text " except [DfaItemsText [dict get $node except]]"
    }
    return $text
}

proc surface::ast::DfaActionText {t} {
    switch -- [dict get $t action] {
        goto { return [dict get $t target] }
        reject { return reject }
        accept {
            switch -- [dict get $t unread] {
                0 { return accept }
                1 { return "accept before" }
                default { return "accept before [dict get $t unread]" }
            }
        }
        call {
            lassign [dict get $t callee] ns name rooted
            set callee [if {$ns eq ""} {set name} else {string cat $ns :: $name}]
            return "call [expr {$rooted ? "::" : ""}]$callee then [dict get $t then]"
        }
    }
}

proc surface::ast::StaticIntrinsic {node prefix indent show linesVar} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    lappend lines "$pad${prefix}static [dict get $node operation][At $node $show]"
    Body [dict get $node body] [expr {$indent + 1}] $show lines
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

# Lines of the loop NODE, its first line starting with PREFIX (mirrors If's
# own PREFIX convention): a collecting loop is a value where an if is, the
# right side of "=", "return" or a destructuring (COLLECTING-LOOPS.md), and
# prints as its statement form does after the prefix.
proc surface::ast::Loop {node prefix indent show linesVar} {
    upvar 1 $linesVar lines
    set pad [string repeat {    } $indent]
    set header loop
    if {[llength [dict get $node clauses]] > 0} {
        append header " [join [lmap clause [dict get $node clauses] {Clause $clause $show}] { and }]"
    }
    lappend lines "$pad$prefix$header[At $node $show]"
    Body [dict get $node body] [expr {$indent + 1}] $show lines
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
        set receive ""
        if {[dict exists $handler binding] && [dict get $handler binding] ne ""} {
            set receive " [dict get $handler binding]"
        } elseif {[dict exists $handler pattern] && [dict get $handler pattern] ne ""} {
            set receive " [PatternText [dict get $handler pattern] $show]"
        }
        lappend lines "[string repeat {    } [expr {$indent + 1}]]on [dict get $handler name]$receive:"
        Body [dict get $handler body] [expr {$indent + 2}] $show lines
    }
}
