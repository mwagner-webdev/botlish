# lower.tcl -- surface AST to HIR.
#
#   surface::lowerToHir AST ?-strict 1|0?     => HIR program
#
# The frontend says what was written and where; HIR says what it means.
# Lowering therefore only restates syntax in the shape HIR is built from and
# hands it to hir::build, which does all semantic work: lexical resolution,
# binding identity, duplicate and use-before-binding checks, captures, types,
# refinements, call targets and control targets. Nothing here looks a name up.
#
# hir::build consumes unresolved expression trees in core IR notation (there
# is no other HIR constructor). Each tree node records the span it came from,
# keyed by its path, and is passed as hir::build -origins, so every HIR
# expression, scope and binding has a {file f1 start .. end .. line ..
# column .. endLine .. endColumn ..} origin; f1 is the source file (-files).
#
# Rules (SPAN of the source node unless stated):
#
#   42                    const 42
#   "text"                const str text
#   true / false / unit   ref true / ref false / ref unit   (root bindings)
#   x                     ref x
#   [a, b]                call (ref list) a b               callee @ the list
#   f(a, b)               call f a b
#   a OP b                call (ref OP) a b                 callee @ the operator
#   -a                    call (ref -) (const 0) a          callee, 0 @ the "-"
#   x = e                 bind x e
#   fn f(a, b): body      bind f (block {a b} body...)      block @ "(" .. end
#   if c: t else: e       if c (block {} t...) (block {} e...)
#                         inline branches; a missing else is an empty branch
#                         (value unit) @ the end of the if
#   loop: body            loop (block {} body...)           inline body
#   return / return e     return (ref unit) / return e
#   break / break e       break / break e
#   continue              continue

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
    set origins [dict create {} [surface::lower::Origin [dict get $ast span]]]
    set exprs {}
    set index 0
    foreach statement [dict get $ast body] {
        lappend exprs [surface::lower::Node $statement [list $index] origins]
        incr index
    }
    set hir [hir::build $exprs -strict 0 -origins $origins \
        -files [dict create f1 [dict get $ast span file]]]
    if {[dict get $options -strict]} {
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

# The HIR origin of source SPAN.
proc surface::lower::Origin {span} {
    return [list file f1 start [dict get $span start] end [dict get $span end] \
        line [dict get $span line] column [dict get $span column] \
        endLine [dict get $span endLine] endColumn [dict get $span endColumn]]
}

proc surface::lower::Record {originsVar path span} {
    upvar 1 $originsVar origins
    dict set origins $path [Origin $span]
}

# The tree for NODE at PATH; records origins.
proc surface::lower::Node {node path originsVar} {
    upvar 1 $originsVar origins
    set span [dict get $node span]
    Record origins $path $span
    switch -- [dict get $node kind] {
        int {
            return [list const [dict get $node text]]
        }
        string {
            return [list const str [dict get $node value]]
        }
        bool {
            return [list ref [dict get $node value]]
        }
        unit {
            return [list ref unit]
        }
        name {
            return [list ref [dict get $node name]]
        }
        list {
            Record origins [concat $path 1] $span
            return [list call [list ref list] {*}[Args [dict get $node items] $path 2 origins]]
        }
        call {
            return [list call [Node [dict get $node callee] [concat $path 1] origins] \
                {*}[Args [dict get $node args] $path 2 origins]]
        }
        binary {
            Record origins [concat $path 1] [dict get $node opSpan]
            return [list call [list ref [dict get $node op]] \
                {*}[Args [list [dict get $node left] [dict get $node right]] $path 2 origins]]
        }
        unary {
            Record origins [concat $path 1] [dict get $node opSpan]
            Record origins [concat $path 2] [dict get $node opSpan]
            return [list call [list ref -] [list const 0] \
                [Node [dict get $node operand] [concat $path 3] origins]]
        }
        bind {
            return [list bind [dict get $node name] \
                [Node [dict get $node value] [concat $path 2] origins]]
        }
        function {
            set block [concat $path 2]
            Record origins $block [dict get $node paramsSpan]
            set names {}
            set index 0
            foreach param [dict get $node params] {
                lassign $param name paramSpan
                lappend names $name
                Record origins [concat $block 1 $index] $paramSpan
                incr index
            }
            return [list bind [dict get $node name] \
                [list block $names {*}[Suite [dict get $node body] $block origins]]]
        }
        if {
            set condition [Node [dict get $node condition] [concat $path 1] origins]
            set then [Suite [dict get $node then] [concat $path 2] origins]
            Record origins [concat $path 2] [dict get $node then span]
            if {[dict get $node else] eq ""} {
                set else {}
                Record origins [concat $path 3] [surface::ast::endOf $span]
            } else {
                set else [Suite [dict get $node else] [concat $path 3] origins]
                Record origins [concat $path 3] [dict get $node else span]
            }
            return [list if $condition [list block {} {*}$then] [list block {} {*}$else]]
        }
        loop {
            set body [concat $path 1]
            Record origins $body [dict get $node body span]
            return [list loop [list block {} {*}[Suite [dict get $node body] $body origins]]]
        }
        return {
            if {[dict get $node value] eq ""} {
                Record origins [concat $path 1] $span
                return [list return [list ref unit]]
            }
            return [list return [Node [dict get $node value] [concat $path 1] origins]]
        }
        break {
            if {[dict get $node value] eq ""} {
                return [list break]
            }
            return [list break [Node [dict get $node value] [concat $path 1] origins]]
        }
        continue {
            return [list continue]
        }
    }
    error "surface::lowerToHir: unknown node kind \"[dict get $node kind]\""
}

# Trees for the expressions NODES, at PATH from index FIRST on.
proc surface::lower::Args {nodes path first originsVar} {
    upvar 1 $originsVar origins
    set result {}
    set index $first
    foreach node $nodes {
        lappend result [Node $node [concat $path $index] origins]
        incr index
    }
    return $result
}

# Body trees of SUITE, the statements of the (block ...) node at PATH.
proc surface::lower::Suite {suite path originsVar} {
    upvar 1 $originsVar origins
    return [Args [dict get $suite body] $path 2 origins]
}
