# recover.tcl -- syntax-error-tolerant analysis: what of a malformed program
# the source still establishes (SYNTAX-RECOVERY-MILESTONE-1.md).
#
#   surface::recover::apply AST SOURCE   => AST, malformed statements as holes
#
# A recovering parse (surface::parse -recover 1) returns an AST for any text:
# a statement it could not parse is an `error` node, and the lexer's recovery
# has skipped characters, ended a string at its line's end, closed a bracket
# nobody closed, or joined a line to an indentation level it does not match.
# Its `damage` record says where (surface::parser::Damage). Analyzing that AST
# as it stands would analyze text nobody wrote: `x = f(` is `x = f()` to the
# parser, and an error node has no meaning at all. So before the program is
# lowered, every *malformed* statement -- the innermost statement containing
# a damaged position -- is replaced by a `hole` node:
#
#   hole   span, at (the first damaged offset in it), name and nameSpan (a name
#          the statement certainly binds, or ""), valueSpan (where its value
#          was written), binds (1 if it may bind names other than NAME in its
#          scope), types (1 if it may declare a type-level name of its file:
#          a struct, type, error, enum, layout or trait), externs (1 if it
#          may declare an `extern c fn`, whose name its whole file sees),
#          installs (1 if it may install a context: `with context`, at the
#          top level)
#
# What a hole keeps is what its *valid prefix* establishes: the tokens before
# its first damaged position, which the parser read as written. Every
# completion of a prefix the parser accepted is a statement of the form the
# prefix decided -- `x = ...` binds x and nothing else, `fn f(...` declares
# f, `return ...`, `if ...` and an expression statement bind nothing visible
# after them -- so that much is known; everything from the damaged position
# on is unknown, and is never lowered. A prefix too short to decide the form,
# or a region that swallowed following lines (the parser resumes after the
# line it failed on, which may be the next statement's), may bind any name.
#
# Layout damage (a tab in indentation, an inconsistent dedent) is a guess
# about which block a line belongs to: every top-level statement from the
# last one written at column 1 before it to the next one at column 1 after it
# is malformed. The file header (its imports and `direct module`) is damaged
# when a construct of it failed or a lexical problem lies in it; a damaged
# import is dropped (`recovered header 1` on the program: what the file may
# name is not known).
#
# The program node gets `recovered {header H values V functions F types T
# externs X installs I holes N}`: the header is damaged; a top-level hole may
# bind value names nobody can list, declare a function (one of those names,
# or the one its `fn NAME` prefix states), declare a type-level name, declare
# an extern, install a context; N top-level statements are holes. The loader reads them
# (a reference into
# a module whose members are not known is not reported as unknown:
# surface/modules.tcl), and lowering turns each hole into HIR syntax holes
# (surface/lower.tcl's Hole, hir/syntax.tcl's holeNode). Nothing here guesses
# what a malformed statement meant.

namespace eval surface::recover {
    # Contextual words that start a declaration when the next token is right
    # (surface/parser.tcl's Statement), and the type-level declarations.
    variable declarationWords {enum layout trait union refined opaque context extern}
    variable functionModifiers {nomethod}
}

proc surface::recover::apply {ast source} {
    if {![dict exists $ast damage]} {
        return $ast
    }
    set damage [dict get $ast damage]
    set file [dict get $ast span file]
    set tokens [dict get $damage tokens]
    set synthetic [dict get $damage synthetic]
    # Statements, with their nesting depth, and the containers holding them.
    set statements {}
    set containers {}
    Collect $ast 0 statements containers
    set body [dict get $ast body]
    set firstStart [if {$body eq ""} {string length $source} else {dict get [lindex $body 0] span start}]
    set header 0
    # Damaged positions: id -> the first damaged offset of a malformed
    # statement; inserted holes for damage between statements.
    set malformed [dict create]
    set inserted [dict create]
    set points {}
    foreach region [dict get $damage failed] {
        if {[dict get $region header]} {
            set header 1
            continue
        }
        # The statement the parser failed on holds its region's start; its
        # diagnostic may point past the statement's own span (past blanks at
        # the end of its line, at the end of the file), where no statement
        # holds it.
        set at [dict get $region at]
        set byStart [Innermost $statements [dict get $region start]]
        set byAt [Innermost $statements $at]
        set container [Innermost $containers [dict get $region start]]
        if {$byStart ne "" && ($byAt eq "" || [dict get $byStart depth] > [dict get $byAt depth])
                && ($container eq "" || [dict get $byStart depth] >= [dict get $container depth])} {
            set id [dict get $byStart id]
            if {![dict exists $malformed $id] || $at < [dict get $malformed $id]} {
                dict set malformed $id $at
            }
            continue
        }
        lappend points $at
    }
    lappend points {*}[dict get $damage lexical]
    foreach at [lsort -integer -unique $points] {
        set statement [Innermost $statements $at]
        set container [Innermost $containers $at]
        if {$statement ne "" && ($container eq "" || [dict get $statement depth] >= [dict get $container depth])} {
            set id [dict get $statement id]
            if {![dict exists $malformed $id] || $at < [dict get $malformed $id]} {
                dict set malformed $id $at
            }
            continue
        }
        if {[InHeader $ast $at $firstStart]} {
            set header 1
            continue
        }
        if {$container eq ""} {
            set container [dict create id "" depth 0]
        }
        dict lappend inserted [dict get $container id] $at
    }
    # Layout damage: the top-level statements around it (above).
    foreach at [dict get $damage indentation] {
        if {[InHeader $ast $at $firstStart]} {
            set header 1
            continue
        }
        foreach {statement from} [LayoutRegion $body $at] {
            set id [dict get $statement id]
            if {![dict exists $malformed $id] || $from < [dict get $malformed $id]} {
                dict set malformed $id $from
            }
        }
    }
    set state [dict create source $source tokens $tokens synthetic $synthetic malformed $malformed \
        inserted $inserted values 0 functions 0 types 0 externs 0 installs 0 file $file]
    set ast [Rebuild $ast state 1]
    if {$header} {
        # An import the damage reached is not one the file makes.
        dict set ast imports [lmap import [dict get $ast imports] {
            if {[Damaged $damage [dict get $import span]]} continue
            set import
        }]
    }
    set holes [llength [lmap statement [dict get $ast body] {
        if {[dict get $statement kind] ne "hole"} continue
        set statement
    }]]
    dict set ast recovered [dict create header $header values [dict get $state values] \
        functions [dict get $state functions] types [dict get $state types] \
        externs [dict get $state externs] installs [dict get $state installs] holes $holes]
    # The tokens were for the prefixes; the recovered tree does not carry them.
    dict unset ast damage tokens
    dict unset ast damage synthetic
    return $ast
}

# 1 if the span SPAN holds a damaged position of DAMAGE.
proc surface::recover::Damaged {damage span} {
    foreach at [concat [dict get $damage lexical] [lmap r [dict get $damage failed] {dict get $r at}]] {
        if {$at >= [dict get $span start] && $at <= [dict get $span end]} {
            return 1
        }
    }
    return 0
}

# 1 if offset AT, in no statement, is in the file header of AST: inside one
# of its imports, or before its first statement (FIRSTSTART) and no later
# than the end of its last import or `direct module`.
proc surface::recover::InHeader {ast at firstStart} {
    set last -1
    foreach import [dict get $ast imports] {
        if {$at >= [dict get $import span start] && $at <= [dict get $import span end]} {
            return 1
        }
        set last [expr {max($last, [dict get $import span end])}]
    }
    if {[dict get $ast direct] ne ""} {
        set last [expr {max($last, [dict get $ast direct end])}]
    }
    return [expr {$at < $firstStart && $at <= $last}]
}

# The statement lists of NODE and what holds them: STATEMENTSVAR gets {id
# start end depth} of every statement (an element of a program's or suite's
# body), CONTAINERSVAR of every suite, DEPTH the nesting of NODE.
proc surface::recover::Collect {node depth statementsVar containersVar} {
    upvar 1 $statementsVar statements $containersVar containers
    switch -- [dict get $node kind] {
        program - suite {
            if {[dict get $node kind] eq "suite"} {
                lappend containers [dict create id [dict get $node id] start [dict get $node span start] \
                    end [dict get $node span end] depth $depth]
            }
            foreach statement [dict get $node body] {
                lappend statements [dict create id [dict get $statement id] \
                    start [dict get $statement span start] end [dict get $statement span end] depth [expr {$depth + 1}]]
                foreach child [Suites $statement] {
                    Collect $child [expr {$depth + 2}] statements containers
                }
            }
        }
    }
}

# The suites a statement (or a statement's value) holds, outermost first.
proc surface::recover::Suites {node} {
    if {$node eq ""} {
        return {}
    }
    switch -- [dict get $node kind] {
        function - static - loop {
            return [list [dict get $node body]]
        }
        if {
            set suites [list [dict get $node then]]
            if {[dict get $node else] ne ""} {
                lappend suites [dict get $node else]
            }
            return $suites
        }
        handledcall {
            return [lmap handler [dict get $node handlers] {dict get $handler body}]
        }
        bind - return - destructure - coroutinebind - with {
            return [Suites [dict get $node value]]
        }
    }
    return {}
}

# The innermost of ITEMS ({id start end depth} dicts) holding offset AT, or "".
proc surface::recover::Innermost {items at} {
    set best ""
    foreach item $items {
        if {$at >= [dict get $item start] && $at <= [dict get $item end]
                && ($best eq "" || [dict get $item depth] > [dict get $best depth])} {
            set best $item
        }
    }
    return $best
}

# The top-level statements of BODY a layout diagnostic at AT makes malformed,
# each with its first damaged offset: {STATEMENT FROM ...}. From the last
# statement starting at column 1 at or before AT (its block may have lost the
# line) to the next one starting at column 1 after AT, exclusive.
proc surface::recover::LayoutRegion {body at} {
    set last -1
    set index 0
    foreach statement $body {
        if {[dict get $statement span start] <= $at} {
            set last $index
        }
        incr index
    }
    set first $last
    while {$first > 0 && [dict get [lindex $body $first] span column] != 1} {
        incr first -1
    }
    set result {}
    for {set i [expr {max($first, 0)}]} {$i < [llength $body]} {incr i} {
        set statement [lindex $body $i]
        set start [dict get $statement span start]
        if {$start > $at && [dict get $statement span column] == 1} {
            break
        }
        lappend result $statement [expr {max($start, $at)}]
    }
    return $result
}

# NODE with its malformed statements replaced by holes (STATEVAR: apply's).
proc surface::recover::Rebuild {node stateVar topLevel} {
    upvar 1 $stateVar state
    if {$node eq ""} {
        return ""
    }
    switch -- [dict get $node kind] {
        program - suite {
            set inserted [dict getdef [dict get $state inserted] [if {[dict get $node kind] eq "program"} {list} else {dict get $node id}] {}]
            set body {}
            set index 0
            foreach statement [dict get $node body] {
                foreach at $inserted {
                    if {$at < [dict get $statement span start]} {
                        lappend body [InsertedHole $node $at $index state $topLevel]
                        incr index
                    }
                }
                set inserted [lmap at $inserted {if {$at >= [dict get $statement span start]} {set at} else continue}]
                if {[dict exists $state malformed [dict get $statement id]]} {
                    lappend body [Hole $statement [dict get $state malformed [dict get $statement id]] state $topLevel]
                } elseif {[dict get $statement kind] eq "error"} {
                    # A statement the parser could not read that no damage
                    # located: nothing of it is known, not even its form.
                    lappend body [Hole $statement [dict get $statement span start] state $topLevel]
                } else {
                    lappend body [Rebuild $statement state 0]
                }
                incr index
            }
            foreach at $inserted {
                lappend body [InsertedHole $node $at $index state $topLevel]
                incr index
            }
            dict set node body $body
        }
        function - static - loop {
            dict set node body [Rebuild [dict get $node body] state 0]
        }
        if {
            dict set node then [Rebuild [dict get $node then] state 0]
            dict set node else [Rebuild [dict get $node else] state 0]
        }
        handledcall {
            dict set node handlers [lmap handler [dict get $node handlers] {
                dict set handler body [Rebuild [dict get $handler body] state 0]
                set handler
            }]
        }
        bind - return - destructure - coroutinebind - with {
            dict set node value [Rebuild [dict get $node value] state 0]
        }
    }
    return $node
}

# A hole for damage at AT between the statements of CONTAINER (a line whose
# every character the lexer skipped): it may have been any statement.
proc surface::recover::InsertedHole {container at index stateVar topLevel} {
    upvar 1 $stateVar state
    set span [Span [dict get $state source] [dict get $state file] $at $at]
    foreach flag {values functions types externs installs} {
        dict set state $flag [expr {[dict get $state $flag] || $topLevel}]
    }
    set id [expr {[dict get $container id] eq "" ? "hole@$at" : "[dict get $container id]/hole@$at"}]
    return [dict create kind hole id $id span $span at $at name "" nameSpan "" valueSpan "" \
        binds 1 types $topLevel externs $topLevel installs $topLevel]
}

# The hole of malformed STATEMENT, first damaged at AT (STATEVAR: apply's;
# TOPLEVEL 1 for a statement of the program's own body).
proc surface::recover::Hole {statement at stateVar topLevel} {
    upvar 1 $stateVar state
    variable declarationWords
    variable functionModifiers
    set span [dict get $statement span]
    set start [dict get $span start]
    # The valid prefix: the real tokens before AT.
    set prefix {}
    set after {}
    set tokens [dict get $state tokens]
    for {set index [FirstAt $tokens $start]} {$index < [llength $tokens]} {incr index} {
        set token [lindex $tokens $index]
        set s [dict get $token span start]
        set e [dict get $token span end]
        if {$s < $start} continue
        if {$s > [dict get $span end]} break
        if {[dict get $token kind] in {NEWLINE INDENT DEDENT EOF}} continue
        if {$s == $e && $s in [dict get $state synthetic]} continue
        if {$e <= $at} {
            lappend prefix $token
        } else {
            lappend after $token
        }
    }
    set name ""
    set nameSpan ""
    set valueFrom ""
    set function 0
    set binds 0
    set types 0
    set externs 0
    set installs 0
    # ANY: the prefix does not decide the statement's form at all.
    set any 0
    set kinds [lmap t $prefix {dict get $t kind}]
    set texts [lmap t $prefix {dict get $t text}]
    set i 0
    while {[lindex $kinds $i] eq "IDENT" && [lindex $texts $i] in $functionModifiers} {
        incr i
    }
    if {$prefix eq ""} {
        set any 1
    } elseif {[lindex $kinds $i] eq "fn"} {
        if {[lindex $kinds $i+1] eq "IDENT"} {
            set name [dict get [lindex $prefix $i+1] value]
            set nameSpan [dict get [lindex $prefix $i+1] span]
            set valueFrom [expr {$i + 2}]
            set function 1
        } else {
            set binds 1
        }
    } elseif {[lindex $kinds 0] eq "IDENT" && [lindex $kinds 1] eq "="} {
        set name [dict get [lindex $prefix 0] value]
        set nameSpan [dict get [lindex $prefix 0] span]
        set valueFrom 2
    } elseif {[lindex $kinds 0] in {return break continue fail yield if elif else loop}} {
        # Binds nothing outside its own blocks.
    } elseif {[lindex $kinds 0] in {type struct error}} {
        set types $topLevel
    } elseif {[lindex $kinds 0] eq "IDENT"} {
        set word [lindex $texts 0]
        if {[llength $prefix] == 1} {
            set any 1
        } elseif {$word in $declarationWords && [lindex $kinds 1] in {IDENT type struct}} {
            set types $topLevel
            if {$word eq "extern"} {
                set binds 1
                set externs $topLevel
            }
        } elseif {$word eq "coroutine" && [lindex $kinds 1] eq "\{"} {
            set binds 1
        } elseif {$word eq "with" && [lindex $texts 1] eq "context"} {
            set installs $topLevel
        }
        # Otherwise an expression statement (`f(`, `x.`, `a +`), a `with`
        # or `static` statement: nothing it binds is visible after it.
    } elseif {[lindex $kinds 0] in {INT DECIMAL STRING CHAR ( \[ - true false unit not ::}} {
        # An expression statement.
    } elseif {[lindex $kinds 0] eq "\{"} {
        # A struct destructuring, or an anonymous struct value.
        set binds 1
    } else {
        set any 1
    }
    if {$any || [Swallows $statement $at $after $state]} {
        set binds 1
        set types [expr {$types || $topLevel}]
        set externs [expr {$externs || $topLevel}]
        set installs [expr {$installs || $topLevel}]
    }
    set valueSpan ""
    if {$name ne ""} {
        # The value: everything after the name (and `=`), from its first
        # token, or from the damage when nothing was written there.
        set from [if {$valueFrom < [llength $prefix]} {dict get [lindex $prefix $valueFrom] span start} else {set at}]
        set to [expr {max([dict get $span end], $from)}]
        set valueSpan [Span [dict get $state source] [dict get $state file] $from $to]
    }
    if {$topLevel} {
        dict set state values [expr {[dict get $state values] || $binds}]
        dict set state functions [expr {[dict get $state functions] || $binds || $function}]
        dict set state types [expr {[dict get $state types] || $types}]
        dict set state externs [expr {[dict get $state externs] || $externs}]
        dict set state installs [expr {[dict get $state installs] || $installs}]
    }
    return [dict create kind hole id [dict get $statement id] span $span at $at \
        name $name nameSpan $nameSpan valueSpan $valueSpan binds $binds types $types \
        externs $externs installs $installs]
}

# The index of the first of TOKENS (in source order) that starts at or after
# OFFSET: a bisection, so that a hole reads its own tokens and not the
# file's.
proc surface::recover::FirstAt {tokens offset} {
    set low 0
    set high [llength $tokens]
    while {$low < $high} {
        set middle [expr {($low + $high) / 2}]
        if {[dict get [lindex $tokens $middle] span start] < $offset} {
            set low [expr {$middle + 1}]
        } else {
            set high $middle
        }
    }
    return $low
}

# 1 if the malformed STATEMENT's text after its damage at AT (AFTER, its
# real tokens) holds a line that starts no deeper than the statement itself:
# a following statement the parser skipped with it (an `elif` or `else` only
# continues it).
proc surface::recover::Swallows {statement at after state} {
    set column [dict get $statement span column]
    set line [dict get $statement span line]
    set previous $line
    foreach token $after {
        set tokenLine [dict get $token span line]
        if {$tokenLine != $previous && $tokenLine > $line} {
            # The first token of a line.
            if {[dict get $token span column] <= $column && [dict get $token kind] ni {elif else}} {
                return 1
            }
        }
        set previous $tokenLine
    }
    return 0
}

# A span of SOURCE (file FILE) from offset FROM to TO.
proc surface::recover::Span {source file from to} {
    lassign [Position $source $from] line column
    lassign [Position $source $to] endLine endColumn
    return [dict create file $file start $from end $to line $line column $column \
        endLine $endLine endColumn $endColumn]
}

# {LINE COLUMN} of offset AT of SOURCE, 1-based.
proc surface::recover::Position {source at} {
    set before [string range $source 0 [expr {$at - 1}]]
    set line [expr {[regexp -all \n $before] + 1}]
    set lineStart [expr {[string last \n $before] + 1}]
    return [list $line [expr {$at - $lineStart + 1}]]
}
