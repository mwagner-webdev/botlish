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
    variable flags {unbound deferred duplicate unreachable move}
    # TypeDecls' own result from the current Program call, for Program to
    # store as the returned HIR's `sourceTypes` field.
    variable lastTypeDecls {}
    # ErrorDecls' own result from the current Program call, for Program to
    # store as the returned HIR's `errorDecls` field.
    variable lastErrorDecls {}
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
    # Struct declarations (hir::format::TypeDecl's "struct ..." lines) come
    # after the integer-domain types their fields may name.
    set structEntries {}
    foreach entry $rest {
        lassign $entry indent content number
        if {$indent != 0 || [string range $content 0 6] ne "struct "} { break }
        lappend structEntries [StructDeclLine $content $number]
        set rest [lrange $rest 1 end]
    }
    if {$structEntries ne ""} {
        if {$decls eq ""} {
            # Struct declarations alone still make this text a program of
            # its own: no source type of an earlier compilation stays
            # registered (hir::sourcetypes::apply's rule for a compilation
            # that declares only structs).
            hir::sourcetypes::Reset
        }
        # Skeletons first, then the field types (which may name any struct
        # of the text, itself included).
        set skeleton [lmap entry $structEntries {
            dict set entry fields [concat {*}[lmap {fname ftype} [dict get $entry fields] {list $fname any}]]
        }]
        hir::structs::applyEntries $skeleton
        set final {}
        foreach entry $structEntries {
            set number [dict get $entry line]
            set fields [concat {*}[lmap {fname ftype} [dict get $entry fields] {
                list $fname [ParseType $ftype $number]
            }]]
            dict unset entry names
            dict unset entry line
            dict set entry fields $fields
            lappend final $entry
        }
        hir::structs::applyEntries $final
        lappend registered {*}$final
    }
    # Trait declarations (hir::format::TraitDecl's "trait ..." lines) and the
    # trait-polymorphic functions a monomorphized program replaced
    # (TRAITS.md): their requirement types may name the structs above.
    variable lastTraits
    variable lastTraitFunctions
    set lastTraits {}
    set lastTraitFunctions {}
    set traitLines {}
    foreach entry $rest {
        lassign $entry indent content number
        if {$indent != 0 || [string range $content 0 5] ne "trait "} { break }
        lappend traitLines $entry
        set rest [lrange $rest 1 end]
    }
    if {$traitLines ne ""} {
        # Names first (a requirement names its own trait), then the lines.
        hir::traits::applyEntries [lmap entry $traitLines {
            regexp {^trait (\S+) } [lindex $entry 1] -> id
            dict create id $id name $id namespace "" requirements {}
        }]
        set lastTraits [lmap entry $traitLines {TraitLine [lindex $entry 1] [lindex $entry 2]}]
        hir::traits::applyEntries $lastTraits
    }
    foreach entry $rest {
        lassign $entry indent content number
        if {$indent != 0 || [string range $content 0 7] ne "traitfn "} { break }
        if {![regexp {^traitfn (\S+) \((.*)\) -> (.+) clones \((.*)\)$} $content -> fname paramsText resultText clonesText]} {
            Fail $number "expected \"traitfn NAME (P: T, ...) -> R clones (C, ...)\""
        }
        set params {}
        if {$paramsText ne ""} {
            foreach item [SplitTop $paramsText ", "] {
                if {![regexp {^(\S+): (.+)$} $item -> p t]} {
                    Fail $number "expected \"PARAM: TYPE\", got \"$item\""
                }
                lappend params $p [ParseType $t $number]
            }
        }
        set clones {}
        foreach c [expr {$clonesText eq "" ? {} : [split [string map {", " \x01} $clonesText] \x01]}] {
            lappend clones $c {}
        }
        dict set lastTraitFunctions $fname [dict create params $params \
            result [expr {$resultText eq "-" ? "" : [ParseType $resultText $number]}] clones $clones]
        set rest [lrange $rest 1 end]
    }
    variable lastTypeDecls
    set lastTypeDecls $registered
    return $rest
}

# The `traits` entry hir::format::TraitDecl's line CONTENT states.
proc hir::read::TraitLine {content number} {
    if {![regexp {^trait (\S+)( context)? owner (\S+) requires (.+)$} $content -> id context owner reqsText]} {
        Fail $number "expected \"trait ID ?context? owner NS requires REQ ; ...\""
    }
    set requirements {}
    foreach text [split [string map {" ; " \x01} $reqsText] \x01] {
        set errorsText ""
        set i [TopIndex $text " errors "]
        if {$i >= 0} {
            set errorsText [string range $text [expr {$i + 8}] end]
            set text [string range $text 0 [expr {$i - 1}]]
        }
        set resultText ""
        set i [TopIndex $text " -> "]
        if {$i >= 0} {
            set resultText [string range $text [expr {$i + 4}] end]
            set text [string range $text 0 [expr {$i - 1}]]
        }
        if {![regexp {^([^(\s]+)\((.*)\)$} $text -> name paramsText]} {
            Fail $number "bad trait requirement \"$text\""
        }
        set params {}
        foreach item [expr {$paramsText eq "" ? {} : [SplitTop $paramsText ", "]}] {
            if {![regexp {^(\S+): (.+)$} $item -> p t]} {
                Fail $number "expected \"PARAM: TYPE\" in a trait requirement, got \"$item\""
            }
            set type [ParseType $t $number]
            lappend params [dict create name $p type $type self [expr {$type eq [list trait $id]}]]
        }
        set result ""
        if {$resultText ne ""} {
            set type [ParseType $resultText $number]
            set result [dict create type $type self [expr {$type eq [list trait $id]}]]
        }
        set errors [expr {$errorsText eq "" ? {} : [lsort -unique [split [string map {", " \x01} $errorsText] \x01]]}]
        lappend requirements [dict create name $name nameSpan "" span "" params $params result $result errors $errors]
    }
    return [dict create id $id name [lindex [split [string map {:: \x01} $id] \x01] end] \
        namespace [expr {$owner eq "-" ? "" : $owner}] requirements $requirements \
        context [expr {$context ne ""}]]
}

# The struct sourceTypes entry "struct ID name NAME ns NS fields F: T, ..."
# (hir::format::TypeDecl) states; field types are read with the structs
# registered skeleton-first, so a field may name any struct of the text.
proc hir::read::StructDeclLine {content number} {
    if {![regexp {^struct (\S+) name (\S+) ns (\S+) (opaque )?(context )?fields (.*)$} $content -> id name ns opaqueWord contextWord fieldsText]} {
        Fail $number "expected \"struct ID name NAME ns NS \[opaque\] \[context\] fields FIELD: TYPE, ...\""
    }
    set ns [expr {$ns eq "-" ? "" : $ns}]
    # Skeleton: every struct line of the text must be known before any field
    # type is parsed, so register the names of all of them first.
    set names {}
    set rawFields {}
    foreach item [SplitTop $fieldsText ", "] {
        if {![regexp {^(\S+): (.+)$} $item -> fname ftype]} {
            Fail $number "expected \"FIELD: TYPE\" in a struct declaration, got \"$item\""
        }
        lappend names $fname
        lappend rawFields $fname $ftype
    }
    set decl [dict create kind struct name $name id $id namespace $ns opaque [expr {$opaqueWord ne ""}] \
        fields $rawFields names $names line $number]
    if {$contextWord ne ""} {
        dict set decl context 1
    }
    return $decl
}

# The surface/lower.tcl-shaped decl dict for one "type ..." HIR text line
# (NUMBER only for a synthetic span: HIR text has no file/column of its
# own), or "" if CONTENT is not a type-declaration line.
proc hir::read::TypeDeclLine {content number} {
    set span [dict create file <hir-text> line $number column 1]
    if {[regexp {^refined type (\S+) carrier (.+) owner (\S+)$} $content -> name carrier owner]} {
        # A refinement type (hir::format::TypeDecl): registered from its
        # canonical identity, resolved carrier text and owner, in printed
        # (dependency) order, by hir::sourcetypes::RegisterRefinement.
        return [dict create kind refined resolved 1 name $name namespace [expr {$owner eq "-" ? "" : $owner}] \
            nameSpan $span carrier $carrier carrierSpan $span span $span line $number]
    }
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
    # NAME is the type's identity as printed (`abi::U8Value` for a module's
    # type), so the declaration reads back with no namespace of its own.
    return [dict create name $name namespace "" nameSpan $span parent $parent parentSpan $span \
        domain $domain domainSpan $span]
}

# Consumes LINES' own leading "error NAME" lines (hir::format's own text),
# re-registering each through hir::errordecls::apply exactly as TypeDecls
# does for "type ..." lines, so a serialized HIR's own "errors E1, E2" /
# "fail E1" / "on E1" text resolves identically whether it came straight
# from surface source or was read back from text with no source in sight.
proc hir::read::ErrorDecls {lines} {
    set decls {}
    set rest $lines
    foreach entry $lines {
        lassign $entry indent content number
        if {$indent != 0} { break }
        if {![regexp {^error (\S+)$} $content -> name]} { break }
        lappend decls [dict create name $name \
            nameSpan [dict create file <hir-text> line $number column 1]]
        set rest [lrange $rest 1 end]
    }
    set registered {}
    if {$decls ne ""} {
        set registered [hir::errordecls::apply $decls]
    }
    variable lastErrorDecls
    set lastErrorDecls $registered
    return $rest
}

proc hir::read::Program {text} {
    set lines [Lines $text]
    if {$lines eq ""} {
        Fail 0 "empty HIR text"
    }
    set lines [TypeDecls $lines]
    set lines [ErrorDecls $lines]
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
    variable lastErrorDecls
    dict set hir errorDecls $lastErrorDecls
    variable lastTraits
    variable lastTraitFunctions
    if {$lastTraits ne {}} {
        dict set hir traits $lastTraits
    }
    if {$lastTraitFunctions ne {}} {
        dict set hir traitFunctions $lastTraitFunctions
    }
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
    # Split at top level only: a structural function type annotation
    # (Fn{args: [A, B], ...}) contains ", " and ":" of its own.
    foreach item [SplitTop $text ", "] {
        if {![regexp {^(b[0-9]+) ([^: ]+)(?::(.+))?$} $item -> b name type]} {
            Fail $number "expected \"BINDING NAME[:TYPE]\", got \"$item\""
        }
        lappend result $b $name $type
    }
    return $result
}

# TEXT split at every occurrence of SEP outside brackets ( ) [ ] { }.
proc hir::read::SplitTop {text sep} {
    set parts {}
    set depth 0
    set start 0
    set n [string length $text]
    set k [string length $sep]
    for {set i 0} {$i < $n} {incr i} {
        set c [string index $text $i]
        if {$c in {( [ \{}} {
            incr depth
        } elseif {$c in {) ] \}}} {
            incr depth -1
        } elseif {$depth == 0 && [string range $text $i [expr {$i + $k - 1}]] eq $sep} {
            lappend parts [string range $text $start [expr {$i - 1}]]
            set start [expr {$i + $k}]
            incr i [expr {$k - 1}]
        }
    }
    lappend parts [string range $text $start end]
    return $parts
}

# The index of the first occurrence of NEEDLE in TEXT outside brackets, or
# -1.
proc hir::read::TopIndex {text needle} {
    set depth 0
    set n [string length $text]
    set k [string length $needle]
    for {set i 0} {$i < $n} {incr i} {
        set c [string index $text $i]
        if {$c in {( [ \{}} {
            incr depth
        } elseif {$c in {) ] \}}} {
            incr depth -1
        } elseif {$depth == 0 && [string range $text $i [expr {$i + $k - 1}]] eq $needle} {
            return $i
        }
    }
    return -1
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
        # Always the four-element form here: a typed block's contract is
        # restored from its own node once the whole text is read
        # (CanonicalBlockTypes), since hir::types::show never prints it.
        return [list block $e $arity [ParseType $result $number]]
    }
    if {[regexp {^Fn\{(.*)\}$} $text -> inner]} {
        # hir::types::show's structural function type notation
        # (STRUCTURAL-FUNCTION-TYPES.md): exactly the three fields, in
        # canonical order.
        set fields [SplitTop $inner ", "]
        if {[llength $fields] != 3
                || ![regexp {^args: \[(.*)\]$} [lindex $fields 0] -> argsText]
                || ![regexp {^return: (.+)$} [lindex $fields 1] -> returnText]
                || ![regexp {^errors: \[(.*)\]$} [lindex $fields 2] -> errorsText]} {
            Fail $number "bad structural function type \"$text\": expected \"Fn{args: \[...\], return: ..., errors: \[...\]}\""
        }
        set argTypes [expr {$argsText eq "" ? {} : [lmap t [SplitTop $argsText ", "] {ParseType $t $number}]}]
        set errors [expr {$errorsText eq "" ? {} : [SplitTop $errorsText ", "]}]
        return [hir::types::MakeFn $argTypes [ParseType $returnText $number] $errors]
    }
    if {[regexp {^Coroutine\{(.*)\}$} $text -> inner]} {
        # hir::types::show's coroutine handle type notation (AFFINE-
        # VALUES.md): the callable contract, the three fields of Fn{...}.
        set fields [SplitTop $inner ", "]
        if {[llength $fields] != 3
                || ![regexp {^args: \[(.*)\]$} [lindex $fields 0] -> argsText]
                || ![regexp {^return: (.+)$} [lindex $fields 1] -> returnText]
                || ![regexp {^errors: \[(.*)\]$} [lindex $fields 2] -> errorsText]} {
            Fail $number "bad coroutine type \"$text\": expected \"Coroutine{args: \[...\], return: ..., errors: \[...\]}\""
        }
        set argTypes [expr {$argsText eq "" ? {} : [lmap t [SplitTop $argsText ", "] {ParseType $t $number}]}]
        set errors [expr {$errorsText eq "" ? {} : [SplitTop $errorsText ", "]}]
        return [hir::types::MakeCoroutineType $argTypes [ParseType $returnText $number] $errors]
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
    if {[regexp {^MutableArray\[(.+)\]$} $text -> inner]} {
        # PARAMETERIZED-MUTABLEARRAY.md: hir::types::show's own notation.
        return [list mutarray [ParseType $inner $number]]
    }
    if {[regexp {^struct\{(.*)\}$} $text -> inner]} {
        # hir::types::show's anonymous struct notation (STRUCTS.md): the
        # fields in canonical order.
        set fields [dict create]
        if {$inner ne ""} {
            foreach item [SplitTop $inner ", "] {
                if {![regexp {^(\S+): (.+)$} $item -> fname ftype]} {
                    Fail $number "bad struct field \"$item\" in \"$text\": expected \"NAME: TYPE\""
                }
                dict set fields $fname [ParseType $ftype $number]
            }
        }
        return [hir::types::MakeStruct $fields 0]
    }
    if {[hir::structs::declared $text]} {
        return [list nstruct $text]
    }
    if {[hir::traits::declared $text]} {
        # A trait constraint (TRAITS.md): only a trait declaration or a
        # trait function's source signature prints one.
        return [list trait $text]
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
    while {[llength $tail] > 1 && ([lindex $tail end] in $flags
            || [string match release=* [lindex $tail end]]
            || [string match exit-release=* [lindex $tail end]]
            || [string match error-release=* [lindex $tail end]]
            || [string match consumed=* [lindex $tail end]])} {
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
            || ![regexp "^$role (s\[0-9\]+)(.*)\$" $content -> s rest]} {
        Fail [expr {$line eq "" ? "end" : $number}] "expected \"$role SCOPE ...\" at indentation level $level"
    }
    # " refines " first: a branch may both bind locals and carry facts
    # (Tcl's regexp matching prefers the first quantifier's greediness, so a
    # single pattern for both optional parts would read the facts as binds).
    set binds ""
    set refines ""
    set i [string first " refines " $rest]
    if {$i >= 0} {
        set refines [string range $rest [expr {$i + 9}] end]
        set rest [string range $rest 0 [expr {$i - 1}]]
    }
    if {[regexp {^ binds (.*)$} $rest -> binds]} {
    } elseif {$rest ne ""} {
        Fail $number "expected \"$role SCOPE ?binds ...? ?refines ...?\""
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

# A handler header "on NAME SCOPE ?binds ...?" at LEVEL (hir::format::Expr's
# own "handle" text, EXPLICIT-ERROR-COMPLETIONS.md) -- mirrors TakeBranchLine,
# without the "refines" part a handler body has no equivalent of.
proc hir::read::TakeHandlerLine {hirVar level} {
    upvar 1 $hirVar hir
    set line [Peek $hir]
    lassign $line indent content number
    if {$line eq "" || $indent != $level
            || ![regexp {^on (\S+) (s[0-9]+)(?: binds (.*))?$} $content -> name s binds]} {
        Fail [expr {$line eq "" ? "end" : $number}] "expected \"on NAME SCOPE ...\" at indentation level $level"
    }
    dict incr hir pos
    if {![hir::errordecls::isDeclared $name]} {
        Fail $number "unknown error \"$name\": no \"error $name\" declaration is visible"
    }
    return [list $name $s $binds $number]
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
    if {"move" in $flags} {
        # A move of an affine value (AFFINE-VALUES.md), as printed.
        dict set hir exprs $e affineMove 1
    }
    set release [lsearch -inline -glob $flags release=*]
    if {$release ne ""} {
        # The affine values released after this statement (AFFINE-VALUES.md),
        # as printed.
        dict set hir exprs $e affineRelease [split [string range $release 8 end] ,]
    }
    set release [lsearch -inline -glob $flags exit-release=*]
    if {$release ne ""} {
        # The affine values this exit releases as it leaves.
        dict set hir exprs $e affineExitRelease [split [string range $release 13 end] ,]
    }
    set release [lsearch -inline -glob $flags error-release=*]
    if {$release ne ""} {
        # The affine values released when this call propagates a declared
        # error: NAME=ITEM,ITEM;...
        set byName [dict create]
        foreach group [split [string range $release 14 end] {;}] {
            set at [string first = $group]
            dict set byName [string range $group 0 $at-1] [split [string range $group $at+1 end] ,]
        }
        dict set hir exprs $e affineErrorRelease $byName
    }
    set consumed [lsearch -inline -glob $flags consumed=*]
    if {$consumed ne ""} {
        # A destructuring temporary's moved-out affine fields, recorded on
        # its binding once the binding exists (TakeBind).
        dict set hir exprs $e affineConsumed [split [string range $consumed 9 end] ,]
    }
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
                SetField hir $e init yes
                hir::Diagnose hir UNBOUND "unbound name \"$name\"" $e
            } else {
                Referenced hir $b $name $s $number
                SetField hir $e binding $b
                SetField hir $e init [expr {"deferred" in $flags ? "deferred" : "yes"}]
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
            if {[dict exists $hir exprs [dict get $hir exprs $e value] nomethod]} {
                dict set hir bindings $b nomethod 1
            }
            set duplicate [expr {"duplicate" in $flags}]
            SetField hir $e duplicate $duplicate
            if {$duplicate} {
                hir::Diagnose hir DUPLICATE "duplicate binding \"$name\" in the same lexical scope" $e
            }
        }
        block {
            if {![BlockHeader $head body params captures staticRefs declared errorsText binds nomethod contexts provesText cloneText resumeText]} {
                Fail $number "expected \"block SCOPE (PARAMS) captures (BINDINGS) ?staticRefs (BINDINGS)? ?nomethod? ?contexts (IDS) requires (IDS)? ?declares ...? ?proves BINDING NAME: TYPE? ?errors ...? ?binds ...?\""
            }
            if {$nomethod} {
                SetField hir $e nomethod 1
            }
            if {$contexts ne ""} {
                SetField hir $e directContexts [lindex $contexts 0]
                SetField hir $e requiredContexts [lindex $contexts 1]
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
            SetField hir $e staticRefs [dict keys [BindingList $staticRefs $number]]
            SetField hir $e resultType [hir::types::intern hir [lindex $type 3]]
            set declaredType {}
            if {$declared ne {}} { set declaredType [ParseType $declared $number] }
            SetField hir $e declaredResult $declaredType
            # The proof contract (REFINEMENT-VALUES.md), as printed: one
            # "BINDING NAME: TYPE" clause naming one of the block's params.
            # Its outcome is the declared result's, exactly as
            # hir::resolve::ResolveProofs derived it: `declares unit` is a
            # validator (a normal completion proves), anything else a
            # predicate (a true result proves).
            set proofs {}
            if {$provesText ne ""} {
                if {![regexp {^(b[0-9]+) (\S+): (.+)$} $provesText -> provenBinding provenName provenType]
                        || [lsearch -exact $paramIds $provenBinding] < 0} {
                    Fail $number "expected \"proves BINDING NAME: TYPE\" naming a parameter of the block"
                }
                lappend proofs [dict create outcome [expr {$declaredType eq "unit" ? "normal" : 1}] \
                    param [lsearch -exact $paramIds $provenBinding] \
                    binding $provenBinding fact [ParseType $provenType $number]]
            }
            SetField hir $e proofs $proofs
            # A declared coroutine resume protocol (COROUTINES.md), and the
            # derived effect as printed.
            SetField hir $e declaredResume [expr {$resumeText eq "" ? "" : [ParseType $resumeText $number]}]
            if {$effectText ne ""} {
                SetField hir $e coroutineEffect $effectText
            }
            if {[dict exists $cloneText views]} {
                SetField hir $e traitClone [dict get $hir bindings [lindex $paramIds 0] name]
                foreach item [expr {[dict get $cloneText views] eq "" ? {} : [split [string map {", " \x01} [dict get $cloneText views]] \x01]}] {
                    if {![regexp {^(b[0-9]+) \S+: (\S+)$} $item -> vb vtrait] || [lsearch -exact $paramIds $vb] < 0} {
                        Fail $number "expected \"BINDING NAME: TRAIT\" in a clone's views"
                    }
                    dict set hir bindings $vb view [hir::types::MakeView $vtrait \
                        [lindex $declaredParamTypes [lsearch -exact $paramIds $vb]]]
                }
            }
            if {[dict exists $cloneText selection]} {
                SetField hir $e contextClone [dict get $cloneText selection]
            }
            if {[dict exists $cloneText result]} {
                SetField hir $e traitResult [list trait [dict get $cloneText result]]
            }
            set declaredErrors {}
            if {$errorsText ne {}} {
                foreach name [split [string map {", " \x01} $errorsText] \x01] {
                    if {$name eq ""} { continue }
                    if {![hir::errordecls::isDeclared $name]} {
                        Fail $number "unknown error \"$name\": no \"error $name\" declaration is visible"
                    }
                    lappend declaredErrors $name
                }
                set declaredErrors [lsort -unique $declaredErrors]
            }
            SetField hir $e declaredErrors $declaredErrors
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
            if {![regexp {^(?:native\((.+?)\)|block\((e[0-9]+)\)|(generic))(?: = (true|false))?(?: installs (\S+))?(?: (trait|contexttrait) (\S+)\.(\S+) witness (.+))?$} $head -> native target generic known installs traitWord traitId requirement witnessText]} {
                Fail $number "expected \"call native(NAME)|block(EXPR)|generic ?= true|false? ?installs ID? ?trait|contexttrait TRAIT.OP witness TYPE?\""
            }
            if {$traitId ne ""} {
                # A trait operation resolved to its implementation
                # (TRAITS.md): the requirement's contract for the witness; a
                # context-trait operation (CONTEXT-TRAITS.md) resolved to the
                # selected context's implementation.
                set witness [ParseType $witnessText $number]
                set req [hir::traits::requirement $traitId $requirement]
                if {$req eq ""} {
                    Fail $number "trait $traitId has no requirement \"$requirement\""
                }
                if {$traitWord eq "contexttrait"} {
                    SetField hir $e traitImpl [dict create trait $traitId requirement $requirement \
                        witness $witness contract [hir::traits::RequiredFn $req ""] context 1]
                } else {
                    SetField hir $e traitImpl [dict create trait $traitId requirement $requirement \
                        witness $witness contract [hir::traits::RequiredFn $req $witness]]
                }
            }
            # The context a verified installation installs (CONTEXTS.md), as
            # printed: native lowering assigns its fixed slot from it.
            if {$installs ne ""} {
                SetField hir $e context $installs
            }
            if {$native ne ""} {
                SetField hir $e target [list native [Symbol hir native $native]]
            } elseif {$target ne ""} {
                SetField hir $e target [list block $target]
            } else {
                SetField hir $e target ""
            }
            SetField hir $e known [expr {$known eq "" ? "" : $known eq "true"}]
            # Not re-derived from the text (this file's own header: parsing
            # trusts what analysis already concluded, it does not repeat
            # the analysis) -- hir::errorsets::verify is never run directly
            # on a hir::read-built HIR (only hir::build's own fresh
            # re-inference, after hir::lower, does that); empty is always a
            # safe, if conservative, placeholder.
            SetField hir $e calleeErrors {}
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
        countloop {
            if {![regexp {^(s[0-9]+) \((b[0-9]+) (\S+)\)(?: (up|down) (exclusive|inclusive))?(?: binds (.*))?$} \
                    $head -> body countId countName direction endKind binds]} {
                Fail $number "expected \"countloop SCOPE (COUNTBINDING NAME) ?DIRECTION ENDKIND? ?binds ...?\""
            }
            SetField hir $e direction [expr {$direction eq "" ? "up" : $direction}]
            SetField hir $e endKind [expr {$endKind eq "" ? "exclusive" : $endKind}]
            NewScope hir $body loop $s [dict get $hir scopes $s invocation] $e [list ir [concat $path 3]] $number
            NewBinding hir $countId $countName param $body [list ir [concat $path 3 1 0]] $number
            Declare hir $body $binds local $number
            SetField hir $e bodyScope $body
            SetField hir $e countBinding $countId
            SetField hir $e start [Expr hir $inner $s [concat $path 1] $block]
            SetField hir $e end [Expr hir $inner $s [concat $path 2] $block]
            set ids {}
            set index 2
            while {[AtLevel $hir $inner]} {
                lappend ids [Expr hir $inner $body [concat $path 3 $index] $block]
                incr index
            }
            SetField hir $e body $ids
        }
        lockloop {
            if {![regexp {^(s[0-9]+)((?: \(b[0-9]+ \S+ (?:list|count (?:up|down) (?:exclusive|inclusive))\))+)(?: binds (.*))?$} \
                    $head -> body groups binds]} {
                Fail $number "expected \"lockloop SCOPE (BINDING NAME list|count DIR KIND)... ?binds ...?\""
            }
            NewScope hir $body loop $s [dict get $hir scopes $s invocation] $e [list ir [concat $path 2]] $number
            set domains {}
            set index 0
            foreach {group bindingId name kindWord direction endKind} \
                    [regexp -all -inline {\((b[0-9]+) (\S+) (list|count)(?: (up|down) (exclusive|inclusive))?\)} $groups] {
                NewBinding hir $bindingId $name param $body [list ir [concat $path 2 1 $index]] $number
                if {$kindWord eq "list"} {
                    lappend domains [dict create kind list binding $bindingId]
                } else {
                    lappend domains [dict create kind count binding $bindingId \
                        direction $direction endKind $endKind]
                }
                incr index
            }
            Declare hir $body $binds local $number
            SetField hir $e bodyScope $body
            set index 0
            set resolved {}
            foreach domain $domains {
                set dpath [concat $path 1 $index]
                if {[dict get $domain kind] eq "list"} {
                    dict set domain iterable [Expr hir $inner $s [concat $dpath 1] $block]
                } else {
                    dict set domain start [Expr hir $inner $s [concat $dpath 1] $block]
                    dict set domain end [Expr hir $inner $s [concat $dpath 2] $block]
                }
                lappend resolved $domain
                incr index
            }
            SetField hir $e domains $resolved
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
        struct {
            if {![regexp {^(\S+) \((.*)\)$} $head -> who namesText]} {
                Fail $number "expected \"struct (anon|ID) (FIELD, ...)\""
            }
            set names [expr {$namesText eq "" ? {} : [split [string map {", " \x01} $namesText] \x01]}]
            set named [expr {$who ne "anon"}]
            set id ""
            if {$named} {
                if {![hir::structs::declared $who]} {
                    Fail $number "unknown struct type \"$who\": no such struct declaration is in this text"
                }
                set id $who
            }
            set layout [expr {$named ? [hir::structs::names $id] : [lsort -unique $names]}]
            SetField hir $e named $named
            SetField hir $e structId $id
            SetField hir $e names $names
            SetField hir $e layout $layout
            SetField hir $e slots [lmap name $names {lsearch -exact $layout $name}]
            set ids {}
            set origins {}
            set index 0
            while {[AtLevel $hir $inner] && $index < [llength $names]} {
                set fieldPath [concat $path [expr {3 + 2 * $index}]]
                lappend ids [Expr hir $inner $s $fieldPath $block]
                lappend origins [list ir $fieldPath]
                incr index
            }
            if {[llength $ids] != [llength $names]} {
                Fail $number "a struct with fields ($namesText) needs one child line per field"
            }
            SetField hir $e fields $ids
            SetField hir $e fieldOrigins $origins
            SetField hir $e nameOrigins $origins
        }
        project {
            if {$head eq ""} {
                Fail $number "expected \"project FIELD\""
            }
            SetField hir $e name $head
            SetField hir $e nameOrigin [list ir [concat $path 2]]
            SetField hir $e receiver [Expr hir $inner $s [concat $path 1] $block]
        }
        fail {
            if {$head eq "" || ![hir::errordecls::isDeclared $head]} {
                Fail $number "unknown error \"$head\": no \"error $head\" declaration is visible"
            }
            SetField hir $e name $head
        }
        handle {
            if {$head ne ""} {
                Fail $number "expected \"handle : TYPE\""
            }
            SetField hir $e call [Expr hir $inner $s [concat $path 1] $block]
            set names {}
            set scopes {}
            set bodies {}
            set index 2
            while {[AtLevel $hir $inner]} {
                lassign [TakeHandlerLine hir $inner] name branch binds headerNumber
                NewScope hir $branch branch $s [dict get $hir scopes $s invocation] $e \
                    [list ir [concat $path $index]] $headerNumber
                Declare hir $branch $binds local $headerNumber
                lappend names $name
                lappend scopes $branch
                set ids {}
                set bodyIndex 2
                while {[AtLevel $hir [expr {$inner + 1}]]} {
                    lappend ids [Expr hir [expr {$inner + 1}] $branch [concat $path $index $bodyIndex] $block]
                    incr bodyIndex
                }
                lappend bodies $ids
                incr index
            }
            SetField hir $e handlerNames $names
            SetField hir $e handlerScopes $scopes
            SetField hir $e handlerBodies $bodies
            # Not re-derived either (see the `calleeErrors` comment above).
            SetField hir $e handlerTypes [lrepeat [llength $names] any]
        }
        default {
            Fail $number "unknown expression kind \"$kind\""
        }
    }
    return $e
}

# Derives what the text implies: which bind declares each binding, binding
# types, and id counters past every id in use.
# Parses a block line's HEAD ("SCOPE (PARAMS) captures (BINDINGS)
# ?staticRefs (BINDINGS)? ?nomethod? ?declares TYPE? ?errors E1, E2? ?binds ...?")
# into the named variables; 0 if malformed. The optional parts are found
# outside brackets, so a declared type may itself contain spaces, ", " or
# the word "errors" (a structural function type's own "errors: [...]").
proc hir::read::BlockHeader {head bodyVar paramsVar capturesVar staticRefsVar declaredVar errorsVar bindsVar {nomethodVar ""} {contextsVar ""} {provesVar ""} {cloneVar ""} {resumeVar ""}} {
    foreach var {bodyVar paramsVar capturesVar staticRefsVar declaredVar errorsVar bindsVar} {
        upvar 1 [set $var] [string range $var 0 end-3]
    }
    if {$nomethodVar ne ""} {
        upvar 1 $nomethodVar nomethod
    }
    if {$contextsVar ne ""} {
        upvar 1 $contextsVar contexts
    }
    set nomethod 0
    set contexts ""
    set staticRefs ""
    set declared ""
    set errors ""
    set binds ""
    if {![regexp {^(s[0-9]+) \((.*?)\) captures \((.*?)\)(.*)$} $head -> body params captures rest]} {
        return 0
    }
    regexp {^ staticRefs \((.*?)\)(.*)$} $rest -> staticRefs rest
    if {[regexp {^ nomethod(.*)$} $rest -> after]} {
        set nomethod 1
        set rest $after
    }
    # A trait clone's parameter views and a declared trait result
    # (TRAITS.md), as hir::format prints them.
    if {$cloneVar ne ""} {
        upvar 1 $cloneVar clone
        set clone ""
        if {[regexp {^ clone \((.*?)\)(.*)$} $rest -> views after]} {
            dict set clone views $views
            set rest $after
        }
        if {[regexp {^ contextclone \((.*?)\)(.*)$} $rest -> selection after]} {
            set pairs {}
            foreach item [split [string map {", " \x01} $selection] \x01] {
                if {![regexp {^([^=]+)=(.+)$} $item -> c w]} {
                    error "expected \"TRAIT=CONTEXT\" in a clone's context selection, got \"$item\""
                }
                lappend pairs $c $w
            }
            dict set clone selection $pairs
            set rest $after
        }
        if {[regexp {^ traitresult (\S+)(.*)$} $rest -> id after]} {
            dict set clone result $id
            set rest $after
        }
    }
    # The context requirements (CONTEXTS.md): {DIRECT REQUIRED}, as printed
    # (hir::check recomputes the same facts from the loads and calls).
    if {[regexp {^ contexts \((.*?)\) requires \((.*?)\)(.*)$} $rest -> direct required after]} {
        set contexts [list [lmap id [split $direct ,] {string trim $id}] [lmap id [split $required ,] {string trim $id}]]
        set rest $after
    }
    set i [TopIndex $rest " binds "]
    if {$i >= 0} {
        set binds [string range $rest [expr {$i + 7}] end]
        set rest [string range $rest 0 [expr {$i - 1}]]
    }
    # The coroutine effect (COROUTINES.md): derived (hir::check recomputes
    # it), kept as printed.
    if {$resumeVar ne ""} {
        upvar 1 $resumeVar resume
        upvar 1 effectText effectText
        set resume ""
        set effectText ""
    }
    set i [TopIndex $rest " coroutine-effect "]
    if {$i >= 0} {
        if {$resumeVar ne "" && [regexp {^ coroutine-effect \((.*)\)$} [string range $rest $i end] -> effectText]} {}
        set rest [string range $rest 0 [expr {$i - 1}]]
    }
    set i [TopIndex $rest " resume "]
    if {$i >= 0 && $resumeVar ne ""} {
        set resume [string range $rest [expr {$i + 8}] end]
        set rest [string range $rest 0 [expr {$i - 1}]]
        set j [TopIndex $resume " errors "]
        if {$j >= 0} {
            set rest "$rest[string range $resume $j end]"
            set resume [string range $resume 0 [expr {$j - 1}]]
        }
    }
    set i [TopIndex $rest " errors "]
    if {$i >= 0} {
        set errors [string range $rest [expr {$i + 8}] end]
        set rest [string range $rest 0 [expr {$i - 1}]]
    }
    if {$provesVar ne ""} {
        upvar 1 $provesVar proves
        set proves ""
        set i [TopIndex $rest " proves "]
        if {$i >= 0} {
            set proves [string range $rest [expr {$i + 8}] end]
            set rest [string range $rest 0 [expr {$i - 1}]]
        }
    }
    if {[string match " declares ?*" $rest]} {
        set declared [string range $rest 10 end]
    } elseif {$rest ne ""} {
        return 0
    }
    return 1
}

# TYPE with every exact block type in it in canonical form
# (hir::types::blockType: a typed block's contract restored from its own,
# already-read node) -- ParseType can only ever produce the four-element
# form, since the contract is never printed.
proc hir::read::CanonicalType {hir type} {
    if {[hir::types::IsExactBlock $type]} {
        lassign $type _ e arity result
        set result [CanonicalType $hir $result]
        if {[dict exists $hir exprs $e] && [dict get $hir exprs $e kind] eq "block"} {
            return [hir::types::blockType $hir $e $arity $result]
        }
        return [lreplace $type 3 3 $result]
    }
    if {[hir::types::IsList $type]} {
        set out [lreplace $type 1 1 [CanonicalType $hir [lindex $type 1]]]
        if {[llength $type] == 3} {
            set out [lreplace $out 2 2 [lmap p [lindex $type 2] {CanonicalType $hir $p}]]
        }
        return $out
    }
    if {[hir::types::IsSet $type] || [hir::types::IsMutArray $type]} {
        return [lreplace $type 1 1 [CanonicalType $hir [lindex $type 1]]]
    }
    if {[hir::types::IsFn $type]} {
        return [hir::types::MakeFn [hir::types::FnArgs $type] \
            [CanonicalType $hir [hir::types::FnReturn $type]] [hir::types::FnErrors $type]]
    }
    if {[hir::types::IsStruct $type]} {
        set fields [dict create]
        dict for {name t} [lindex $type 1] {
            dict set fields $name [CanonicalType $hir $t]
        }
        return [hir::types::MakeStruct $fields 0]
    }
    return $type
}

proc hir::read::CanonicalBlockTypes {hirVar} {
    upvar 1 $hirVar hir
    set types [dict create]
    set typeIds [dict create]
    dict for {t type} [dict get $hir types] {
        set type [CanonicalType $hir $type]
        dict set types $t $type
        if {![dict exists $typeIds $type]} {
            dict set typeIds $type $t
        }
    }
    dict set hir types $types
    dict set hir typeIds $typeIds
}

proc hir::read::Finish {hirVar} {
    upvar 1 $hirVar hir
    CanonicalBlockTypes hir
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
    # Text is a serialized HIR, and a HIR never contains a reference to a
    # binding established after it (hir/resolve.tcl): a text that does is
    # not the HIR of any program.
    foreach f [hir::refcheck::forwardRefs $hir] {
        throw [list HIR PARSE] "HIR text: expression [dict get $f ref] refers to \"[dict get $f name]\" ([dict get $f binding]), which is not established until [dict get $f bind]: forward references are not allowed"
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
