# read.tcl -- reading HIR text: the inverse of hir::format.
#
#   set h [hir::parse $text]
#   set h [hir::readFile examples/hir/02-closures.hir]
#
# HIR text is exactly what hir::format prints (with or without -origins),
# optionally with comment lines starting with # and blank lines. It states
# the semantic facts explicitly: binding ids, scopes, types, captures,
# refinements, call targets and flags. Parsing rebuilds a complete HIR
# program from them (including what the text implies but does not print:
# binding kinds and types, scope structure, closures, root symbols,
# diagnostics, origins), so it can be lowered, formatted or compiled.
#
# Parsing checks the text is well-formed and internally consistent (ids
# declared once, references to visible bindings, a block's type naming the
# block), but not that the facts are what analysis of the program derives:
# compare with hir::format [hir::build [hir::lower $h]] for that.
#
# Names and literals must be single Tcl list words without the characters
# ( ) , or whitespace inside names; ordinary IR names are.

namespace eval hir::read {
    variable flags {unbound before-binding deferred duplicate unreachable}
    # TypeDecls' own result from the current Program call, for Program to
    # store as the returned HIR's `sourceTypes` field.
    variable lastTypeDecls {}
}

# The HIR program described by TEXT.
proc hir::parse {text} {
    return [hir::read::Program $text]
}

# The HIR program in file PATH, after loading the libraries it requires
# ("# requires: NAME" comments, as for .ir files).
proc hir::readFile {path} {
    foreach name [core::programFileRequires $path] {
        core::loadLibrary $name
    }
    return [hir::parse [core::ReadFile $path]]
}

proc hir::read::Fail {line message} {
    throw [list HIR PARSE] "HIR text line $line: $message"
}

# Lines as {INDENT CONTENT LINE-NUMBER}, without comments and blank lines.
proc hir::read::Lines {text} {
    set lines {}
    set number 0
    foreach line [split $text \n] {
        incr number
        set line [string trimright $line]
        set content [string trimleft $line]
        if {$content eq "" || [string index $content 0] eq "#"} {
            continue
        }
        set spaces [expr {[string length $line] - [string length $content]}]
        if {$spaces % 4} {
            Fail $number "indentation must be a multiple of four spaces"
        }
        lappend lines [list [expr {$spaces / 4}] $content $number]
    }
    return $lines
}

# Consumes LINES' own leading "type NAME parent PARENT domain ..." lines
# (hir::format::TypeDecl's own text -- see format.tcl), re-registering each
# through the exact same hir::sourcetypes::apply path a fresh source compile
# uses, so a type a serialized HIR names ("declares Small", ": int[Small]")
# resolves identically whether this HIR came straight from surface source or
# was read back from text with no source in sight (item 55-56's round trip).
# Returns LINES with those consumed.
proc hir::read::TypeDecls {lines} {
    set decls {}
    set rest $lines
    foreach entry $lines {
        lassign $entry indent content number
        if {$indent != 0} { break }
        set decl [TypeDeclLine $content $number]
        if {$decl eq ""} { break }
        lappend decls $decl
        set rest [lrange $rest 1 end]
    }
    set registered {}
    if {$decls ne ""} {
        set registered [hir::sourcetypes::apply $decls]
    }
    variable lastTypeDecls
    set lastTypeDecls $registered
    return $rest
}

# The surface/lower.tcl-shaped decl dict for one "type ..." HIR text line
# (NUMBER only for a synthetic span: HIR text has no file/column of its
# own), or "" if CONTENT is not a type-declaration line.
proc hir::read::TypeDeclLine {content number} {
    set span [dict create file <hir-text> line $number column 1]
    if {[regexp {^type (\S+) parent (\S+) domain interval (-?[0-9]+) (-?[0-9]+)$} $content \
            -> name parent lo hi]} {
        set domain [dict create kind interval lo $lo loSpan $span hi $hi hiSpan $span span $span]
    } elseif {[regexp {^type (\S+) parent (\S+) domain exact (.+)$} $content -> name parent valuesText]} {
        set values [split $valuesText]
        set spans [lrepeat [llength $values] $span]
        set domain [dict create kind exact values $values spans $spans span $span]
    } else {
        return ""
    }
    return [dict create name $name nameSpan $span parent $parent parentSpan $span \
        domain $domain domainSpan $span]
}

proc hir::read::Program {text} {
    set lines [Lines $text]
    if {$lines eq ""} {
        Fail 0 "empty HIR text"
    }
    set lines [TypeDecls $lines]
    if {$lines eq ""} {
        Fail 0 "empty HIR text"
    }
    lassign [lindex $lines 0] indent header number
    if {$indent != 0 || ![regexp {^(program|ambient) (s[0-9]+)(?: binds (.*))?$} $header -> kind top binds]} {
        Fail $number "expected a header \"program SCOPE ?binds ...?\" or \"ambient SCOPE\""
    }
    set mode [expr {$kind eq "program" ? "program" : "sequence"}]
    set hir [hir::Empty $mode]
    dict set hir lines $lines
    dict set hir pos 1
    if {$mode eq "program"} {
        set root [expr {$top eq "s2" ? "s1" : "s0"}]
        NewScope hir $root root "" "" "" {builtin root} $number
        NewScope hir $top program $root "" "" {ir {}} $number
    } else {
        NewScope hir $top ambient "" "" "" {host environment} $number
    }
    Declare hir $top $binds local $number
    dict set hir top $top

    set roots {}
    set index 0
    while {[dict get $hir pos] < [llength $lines]} {
        lappend roots [Expr hir 0 $top [list $index] ""]
        incr index
    }
    dict set hir roots $roots
    dict unset hir lines
    dict unset hir pos
    variable lastTypeDecls
    dict set hir sourceTypes $lastTypeDecls
    Finish hir
    return $hir
}

proc hir::read::NewScope {hirVar s kind parent invocation owner origin number} {
    upvar 1 $hirVar hir
    if {[dict exists $hir scopes $s]} {
        Fail $number "scope $s is defined twice"
    }
    dict set hir scopes $s [dict create id $s kind $kind parent $parent \
        invocation $invocation owner $owner origin $origin \
        names [dict create] bindings {} closures {} refinements {}]
}

# {ID NAME ...} from "b1 x, b2 y".
proc hir::read::BindingList {text number} {
    set result {}
    if {$text eq ""} {
        return $result
    }
    foreach item [split [string map {", " \x01} $text] \x01] {
        if {![regexp {^(b[0-9]+) (\S+)$} $item -> b name]} {
            Fail $number "expected \"BINDING NAME\", got \"$item\""
        }
        lappend result $b $name
    }
    return $result
}

# {ID NAME TYPE ...} from "b1 x:Small, b2 y" (hir::format::ParamList's own
# format) -- TYPE is "" for an untyped parameter.
proc hir::read::ParamList {text number} {
    set result {}
    if {$text eq ""} {
        return $result
    }
    foreach item [split [string map {", " \x01} $text] \x01] {
        if {![regexp {^(b[0-9]+) ([^: ]+)(?::([^: ]+))?$} $item -> b name type]} {
            Fail $number "expected \"BINDING NAME[:TYPE]\", got \"$item\""
        }
        lappend result $b $name $type
    }
    return $result
}

proc hir::read::NewBinding {hirVar b name kind s origin number} {
    upvar 1 $hirVar hir
    if {[dict exists $hir bindings $b]} {
        Fail $number "binding $b is declared twice"
    }
    dict set hir bindings $b [dict create id $b name $name kind $kind scope $s \
        declaredBy "" origin $origin type "" symbol "" value ""]
    dict set hir scopes $s names $name $b
    dict set hir scopes $s bindings [concat [dict get $hir scopes $s bindings] [list $b]]
}

proc hir::read::Declare {hirVar s text kind number} {
    upvar 1 $hirVar hir
    foreach {b name} [BindingList $text $number] {
        NewBinding hir $b $name $kind $s [list declared $s] $number
    }
}

proc hir::read::Symbol {hirVar kind name} {
    upvar 1 $hirVar hir
    dict for {y symbol} [dict get $hir symbols] {
        if {[dict get $symbol kind] eq $kind && [dict get $symbol name] eq $name} {
            return $y
        }
    }
    set y y[expr {[dict size [dict get $hir symbols]] + 1}]
    set provenance [expr {$kind eq "native" ? [list core native $name] : [list core root $name]}]
    dict set hir symbols $y [dict create id $y kind $kind name $name provenance $provenance]
    return $y
}

# The binding B referred to as NAME from scope S: a declared binding visible
# from S, or a root / ambient binding created on first reference.
proc hir::read::Referenced {hirVar b name s number} {
    upvar 1 $hirVar hir
    if {[dict exists $hir bindings $b]} {
        set binding [dict get $hir bindings $b]
        if {[dict get $binding name] ne $name} {
            Fail $number "binding $b is named \"[dict get $binding name]\", not \"$name\""
        }
        if {![hir::scopeWithin $hir $s [dict get $binding scope]]} {
            Fail $number "binding $b is not visible here"
        }
        return
    }
    set top [dict get $hir top]
    if {[dict get $hir mode] eq "sequence"} {
        NewBinding hir $b $name ambient $top {host environment} $number
        return
    }
    if {$name ni [hir::resolve::RootNames]} {
        Fail $number "binding $b ($name) is not declared and is not a root name"
    }
    set root [dict get $hir scopes $top parent]
    NewBinding hir $b $name root $root {builtin root} $number
    if {$name in {true false unit}} {
        dict set hir bindings $b symbol [Symbol hir constant $name]
        dict set hir bindings $b value [core::value::$name]
    } else {
        dict set hir bindings $b symbol [Symbol hir native $name]
        dict set hir bindings $b value [core::value::native $name]
    }
}

# The type form shown as TEXT (hir::types::show).
proc hir::read::ParseType {text number} {
    set text [string trim $text]
    if {[regexp {^native (\S+)$} $text -> name]} {
        return [list native $name]
    }
    if {[regexp {^block\((e[0-9]+)\)/([0-9]+) -> (.+)$} $text -> e arity result]} {
        return [list block $e $arity [ParseType $result $number]]
    }
    if {[regexp {^List\[(.+)\]$} $text -> inner]} {
        # hir::types::show's own applied-type notation (MINIMAL-APPLIED-
        # LIST-TYPES.md): always exactly "List[" + show(ELEM) + "]", so the
        # greedy (.+) correctly spans a nested "List[List[...]]" too -- it
        # can only ever stop at the final "]", the one this format always
        # closes with.
        return [list list [ParseType $inner $number]]
    }
    if {[regexp {^ImmutableSet\[(.+)\]$} $text -> inner]} {
        # The same applied-type notation, for ImmutableSet[T] (MINIMAL-
        # IMMUTABLE-SET.md) -- distinguished from List[T] above only by the
        # literal head word, which can never collide since "List" and
        # "ImmutableSet" are different constructor names.
        return [list immutableSet [ParseType $inner $number]]
    }
    if {[regexp {^([a-z]+)\[([^\]]*)\]$} $text -> base names]} {
        set text [list refined $base [split $names ,]]
    }
    if {$text eq "never"} {
        return never
    }
    if {[catch {core::type::normalize $text} type]} {
        Fail $number "bad type \"$text\": $type"
    }
    return $type
}

proc hir::read::Peek {hir} {
    set pos [dict get $hir pos]
    if {$pos >= [llength [dict get $hir lines]]} {
        return ""
    }
    return [lindex [dict get $hir lines] $pos]
}

# The expression line at the current position, which must be at LEVEL:
# {id kind head type flags origin number}.
proc hir::read::TakeExprLine {hirVar level} {
    upvar 1 $hirVar hir
    variable flags
    set line [Peek $hir]
    if {$line eq ""} {
        Fail end "expected an expression at indentation level $level"
    }
    lassign $line indent content number
    if {$indent != $level} {
        Fail $number "expected an expression at indentation level $level"
    }
    dict incr hir pos
    if {[catch {llength $content}]} {
        Fail $number "not a list of words"
    }
    set separator [lsearch -exact -all $content :]
    if {$separator eq "" || ![regexp {^e[0-9]+$} [lindex $content 0]]} {
        Fail $number "expected \"EXPR KIND ... : TYPE\""
    }
    set separator [lindex $separator end]
    set tail [lrange $content $separator+1 end]
    set origin ""
    set at [lsearch -glob $tail @*]
    if {$at >= 0} {
        set origin [list [string range [lindex $tail $at] 1 end] [lindex $tail $at+1]]
        set tail [lrange $tail 0 $at-1]
    }
    set found {}
    while {[llength $tail] > 1 && [lindex $tail end] in $flags} {
        set found [linsert $found 0 [lindex $tail end]]
        set tail [lrange $tail 0 end-1]
    }
    return [dict create id [lindex $content 0] kind [lindex $content 1] \
        head [lrange $content 2 $separator-1] type [ParseType [join $tail " "] $number] \
        flags $found origin $origin number $number]
}

# A branch header "then|else SCOPE ?binds ...? ?refines ...?" at LEVEL.
proc hir::read::TakeBranchLine {hirVar level role} {
    upvar 1 $hirVar hir
    set line [Peek $hir]
    lassign $line indent content number
    if {$line eq "" || $indent != $level
            || ![regexp "^$role (s\[0-9\]+)(?: binds (.*?))?(?: refines (.*))?\$" $content -> s binds refines]} {
        Fail [expr {$line eq "" ? "end" : $number}] "expected \"$role SCOPE ...\" at indentation level $level"
    }
    dict incr hir pos
    set facts {}
    if {$refines ne ""} {
        foreach item [split [string map {", " \x01} $refines] \x01] {
            if {![regexp {^(b[0-9]+) (\S+) : (.+)$} $item -> b name type]} {
                Fail $number "expected \"BINDING NAME : TYPE\", got \"$item\""
            }
            lappend facts $b $name [ParseType $type $number]
        }
    }
    return [list $s $binds $facts $number]
}

# True if the next line is at indentation LEVEL.
proc hir::read::AtLevel {hir level} {
    set line [Peek $hir]
    return [expr {$line ne "" && [lindex $line 0] == $level}]
}

proc hir::read::SetField {hirVar e key value} {
    upvar 1 $hirVar hir
    dict set hir exprs $e $key $value
}

# Reads the expression at LEVEL evaluated in scope S, at IR PATH, inside the
# block BLOCK ("" at unit level). Returns its ExprId.
proc hir::read::Expr {hirVar level s path block} {
    upvar 1 $hirVar hir
    set line [TakeExprLine hir $level]
    set e [dict get $line id]
    set kind [dict get $line kind]
    set head [join [dict get $line head] " "]
    set number [dict get $line number]
    set flags [dict get $line flags]
    if {[dict exists $hir exprs $e]} {
        Fail $number "expression $e is defined twice"
    }
    if {[dict get $line origin] ne "" && [dict get $line origin] ne [list ir $path]} {
        Fail $number "origin [dict get $line origin] does not match its position (ir $path)"
    }
    dict set hir exprs $e [dict create id $e kind $kind origin [list ir $path] scope $s \
        type [hir::types::intern hir [dict get $line type]] \
        reachable [expr {"unreachable" ni $flags}]]
    set inner [expr {$level + 1}]

    switch -- $kind {
        const {
            set literal [dict get $line head]
            if {[catch {core::ir::literalValue [list const {*}$literal]} value]} {
                Fail $number "bad literal \"$literal\""
            }
            SetField hir $e literal $literal
            SetField hir $e value $value
        }
        ref {
            if {![regexp {^(b[0-9]+|\?) (\S+)$} $head -> b name]} {
                Fail $number "expected \"ref BINDING NAME\""
            }
            SetField hir $e name $name
            if {$b eq "?"} {
                SetField hir $e binding ""
                SetField hir $e init no
                hir::Diagnose hir UNBOUND "unbound name \"$name\"" $e
            } else {
                Referenced hir $b $name $s $number
                SetField hir $e binding $b
                set init yes
                if {"before-binding" in $flags} {
                    set init no
                    hir::Diagnose hir UNBOUND "name \"$name\" used before its binding" $e
                } elseif {"deferred" in $flags} {
                    set init deferred
                }
                SetField hir $e init $init
            }
        }
        bind {
            if {![regexp {^(b[0-9]+) (\S+)$} $head -> b name]} {
                Fail $number "expected \"bind BINDING NAME\""
            }
            SetField hir $e name $name
            Referenced hir $b $name $s $number
            SetField hir $e binding $b
            SetField hir $e value [Expr hir $inner $s [concat $path 2] $block]
            set duplicate [expr {"duplicate" in $flags}]
            SetField hir $e duplicate $duplicate
            if {$duplicate} {
                hir::Diagnose hir DUPLICATE "duplicate binding \"$name\" in the same lexical scope" $e
            }
        }
        block {
            if {![regexp {^(s[0-9]+) \((.*?)\) captures \((.*?)\)(?: declares (\S+))?(?: binds (.*))?$} \
                    $head -> body params captures declared binds]} {
                Fail $number "expected \"block SCOPE (PARAMS) captures (BINDINGS) ?binds ...?\""
            }
            NewScope hir $body block $s $e $e [list ir $path] $number
            set paramIds {}
            set declaredParamTypes {}
            set index 0
            foreach {b name typeText} [ParamList $params $number] {
                NewBinding hir $b $name param $body [list ir [concat $path 1 $index]] $number
                lappend paramIds $b
                lappend declaredParamTypes [expr {$typeText eq {} ? {} : [ParseType $typeText $number]}]
                incr index
            }
            Declare hir $body $binds local $number
            hir::resolve::AddClosure hir $s $e
            set type [hir::typeOf $hir $e]
            if {[lindex $type 0] ne "block" || [lindex $type 1] ne $e || [lindex $type 2] != [llength $paramIds]} {
                Fail $number "the type of block $e must be block($e)/[llength $paramIds] -> RESULT"
            }
            SetField hir $e bodyScope $body
            SetField hir $e params $paramIds
            SetField hir $e declaredParamTypes $declaredParamTypes
            SetField hir $e captures [dict keys [BindingList $captures $number]]
            SetField hir $e resultType [hir::types::intern hir [lindex $type 3]]
            set declaredType {}
            if {$declared ne {}} { set declaredType [ParseType $declared $number] }
            SetField hir $e declaredResult $declaredType
            SetField hir $e inferredResultType [hir::types::intern hir [lindex $type 3]]
            set ids {}
            set index 2
            while {[AtLevel $hir $inner]} {
                lappend ids [Expr hir $inner $body [concat $path $index] $e]
                incr index
            }
            SetField hir $e body $ids
        }
        call {
            if {![regexp {^(?:native\((.+)\)|block\((e[0-9]+)\)|(generic))(?: = (true|false))?$} $head -> native target generic known]} {
                Fail $number "expected \"call native(NAME)|block(EXPR)|generic ?= true|false?\""
            }
            if {$native ne ""} {
                SetField hir $e target [list native [Symbol hir native $native]]
            } elseif {$target ne ""} {
                SetField hir $e target [list block $target]
            } else {
                SetField hir $e target ""
            }
            SetField hir $e known [expr {$known eq "" ? "" : $known eq "true"}]
            SetField hir $e callee [Expr hir $inner $s [concat $path 1] $block]
            set args {}
            set index 2
            while {[AtLevel $hir $inner]} {
                lappend args [Expr hir $inner $s [concat $path $index] $block]
                incr index
            }
            SetField hir $e args $args
        }
        if {
            if {$head ne ""} {
                Fail $number "expected \"if : TYPE\""
            }
            SetField hir $e condition [Expr hir $inner $s [concat $path 1] $block]
            set refinements [dict create 1 {} 0 {}]
            set invocation [dict get $hir scopes $s invocation]
            foreach {role index outcome} {then 2 1 else 3 0} {
                lassign [TakeBranchLine hir $inner $role] branch binds facts headerNumber
                NewScope hir $branch branch $s $invocation $e [list ir [concat $path $index]] $headerNumber
                dict set hir scopes $branch outcome $outcome
                Declare hir $branch $binds local $headerNumber
                set pairs {}
                foreach {b name fact} $facts {
                    Referenced hir $b $name $s $headerNumber
                    lappend pairs $b $fact
                }
                dict set refinements $outcome $pairs
                dict set hir scopes $branch refinements $pairs
                SetField hir $e ${role}Scope $branch
                set ids {}
                set bodyIndex 2
                while {[AtLevel $hir [expr {$inner + 1}]]} {
                    lappend ids [Expr hir [expr {$inner + 1}] $branch [concat $path $index $bodyIndex] $block]
                    incr bodyIndex
                }
                SetField hir $e ${role}Body $ids
            }
            SetField hir $e refinements $refinements
        }
        loop {
            if {![regexp {^(s[0-9]+)(?: binds (.*))?$} $head -> body binds]} {
                Fail $number "expected \"loop SCOPE ?binds ...?\""
            }
            NewScope hir $body loop $s [dict get $hir scopes $s invocation] $e [list ir [concat $path 1]] $number
            Declare hir $body $binds local $number
            SetField hir $e bodyScope $body
            set ids {}
            set index 2
            while {[AtLevel $hir $inner]} {
                lappend ids [Expr hir $inner $body [concat $path 1 $index] $block]
                incr index
            }
            SetField hir $e body $ids
        }
        listloop {
            if {![regexp {^(s[0-9]+) \((b[0-9]+) (\S+)\)(?: binds (.*))?$} \
                    $head -> body elemId elemName binds]} {
                Fail $number "expected \"listloop SCOPE (ELEMBINDING NAME) ?binds ...?\""
            }
            NewScope hir $body loop $s [dict get $hir scopes $s invocation] $e [list ir [concat $path 2]] $number
            NewBinding hir $elemId $elemName param $body [list ir [concat $path 2 1 0]] $number
            Declare hir $body $binds local $number
            SetField hir $e bodyScope $body
            SetField hir $e elementBinding $elemId
            SetField hir $e iterable [Expr hir $inner $s [concat $path 1] $block]
            set ids {}
            set index 2
            while {[AtLevel $hir $inner]} {
                lappend ids [Expr hir $inner $body [concat $path 2 $index] $block]
                incr index
            }
            SetField hir $e body $ids
        }
        return - break - continue {
            if {![regexp {^-> (e[0-9]+|\?)$} $head -> target]} {
                Fail $number "expected \"$kind -> EXPR\""
            }
            set target [expr {$target eq "?" ? "" : $target}]
            SetField hir $e target $target
            set value ""
            if {$kind eq "return" || ($kind eq "break" && [AtLevel $hir $inner])} {
                set value [Expr hir $inner $s [concat $path 1] $block]
            }
            if {$kind ne "continue"} {
                SetField hir $e value $value
            }
            if {$target eq ""} {
                switch -- $kind {
                    return   { hir::Diagnose hir RETURN-OUTSIDE-CALLABLE "return outside callable invocation" $e }
                    break    { hir::Diagnose hir BREAK-OUTSIDE-LOOP "break outside lexical loop" $e }
                    continue { hir::Diagnose hir CONTINUE-OUTSIDE-LOOP "continue outside lexical loop" $e }
                }
            }
        }
        ok - error {
            if {$head ne ""} {
                Fail $number "expected \"$kind : TYPE\""
            }
            SetField hir $e value [Expr hir $inner $s [concat $path 1] $block]
        }
        default {
            Fail $number "unknown expression kind \"$kind\""
        }
    }
    return $e
}

# Derives what the text implies: which bind declares each binding, binding
# types, and id counters past every id in use.
proc hir::read::Finish {hirVar} {
    upvar 1 $hirVar hir
    foreach e [hir::walk $hir] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] ne "bind" || [dict get $node duplicate]} {
            continue
        }
        set b [dict get $node binding]
        if {[dict get $hir bindings $b kind] ne "local" || [dict get $hir bindings $b declaredBy] ne ""} {
            continue
        }
        dict set hir bindings $b declaredBy $e
        dict set hir bindings $b origin [dict get $node origin]
        if {[hir::typeOf $hir $e] ne "never"} {
            dict set hir bindings $b type [dict get $node type]
        }
    }
    foreach {table kind} {exprs expr scopes scope bindings binding symbols symbol types type} {
        set max 0
        foreach id [dict keys [dict get $hir $table]] {
            regexp {([0-9]+)$} $id -> n
            set max [expr {max($max, $n)}]
        }
        dict set hir counters $kind $max
    }
}
