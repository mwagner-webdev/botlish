# editor-grammars.tcl -- the editor grammars, generated from the compiler's
# own word lists (SYNTAX-HIGHLIGHTING-MILESTONE-1.md, "Editor grammars").
#
#   tclsh9.0 tools/editor-grammars.tcl generate    write both grammars
#   tclsh9.0 tools/editor-grammars.tcl check       exit 1 when a committed
#                                                  grammar is not what
#                                                  generation writes
#
# Writes editors/vscode/syntaxes/botlish.tmLanguage.json (a TextMate grammar,
# VS Code's) and editors/neovim/syntax/botlish.vim (Vim's and Neovim's
# syntax). An editor grammar is a set of regular expressions: it highlights
# what a text's lines show, before any analysis and in a hover's code, and
# the language server's semantic tokens refine it (service::tokens). What it
# must not do is disagree with the compiler about a word: so its keywords,
# its constants and its word operators are the lexer's (surface::lexer::
# keywords: each placed in exactly one group below, or generation fails),
# and every contextual word the parser reads (surface::parser::words) is
# highlighted by at least one of the patterns below, where the grammar can
# recognize it, or generation fails. A pattern may name only those words.
# tests/syntax-highlighting.test runs `check` and tokenizes a fixture with
# each grammar against the token IR's classes (surface::tokens::classes).

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root surface surface.tcl]
source [file join $root lsp json.tcl]

namespace eval grammars {
    variable root $::root
    # The lexer's keywords, by what they are to a highlighter.
    variable groups {
        control {if elif else loop return break continue fail yield on}
        declaration {fn type struct error errors}
        operatorWord {and or not}
        constant {true false unit}
    }
    # The scopes (TextMate) and highlight groups (Vim) of each role.
    variable scopes {
        contextual keyword.other.contextual.botlish
        control keyword.control.botlish
        declaration keyword.other.botlish
        operatorWord keyword.operator.word.botlish
        constant constant.language.botlish
        number constant.numeric.integer.botlish
        functionName entity.name.function.botlish
        typeName entity.name.type.botlish
    }
    # The contextual patterns: WORDS the words a pattern highlights,
    # TEXTMATE its TextMate rule (a `match` whose CAPTURES are the groups it
    # highlights, each a role; or a region, `begin`/`end` with its own
    # `patterns`), VIM its Vim patterns, each {PREFIX WORDS SUFFIX}: one of
    # WORDS ("|"-separated) as a contextual word where PREFIX (magic, a
    # lookbehind) is before it and SUFFIX (a lookahead) after it -- never
    # \zs after a prefix, whose start another item (a keyword, an operator)
    # may claim first. Each is written to match the word only where
    # the grammar reads it (surface/parser.tcl's At* predicates): a name of
    # the same spelling stays a name.
    variable contextual {
        {words {direct module}
         textmate {match {^\s*(direct)\s+(module)\b} captures {1 contextual 2 contextual}}
         vim {{{^\s*} direct {\s\+module\>}} {{^\s*direct\s\+} module {}}}}
        {words {import}
         textmate {match {^\s*(import)\b(?=\s+(?:type\b|::|[A-Za-z_]))} captures {1 contextual}}
         vim {{{^\s*} import {\s\+\(type\>\|::\|\h\)}}}}
        {words {private}
         textmate {match {^\s*(private)\s+(?=[A-Za-z_])} captures {1 contextual}}
         vim {{{^\s*} private {\s\+\h}}}}
        {words {opaque context tree resource nomethod cleanup refined thread}
         textmate {match {\b(opaque|context|tree|resource|nomethod|cleanup|refined|thread)\s+(?=(?:opaque|context|tree|resource|nomethod|cleanup|refined|thread|exported|callback|struct|trait|fn|type)\b)} captures {1 contextual}}
         vim {{{} opaque|context|tree|resource|nomethod|cleanup|refined|thread {\s\+\(opaque\|context\|tree\|resource\|nomethod\|cleanup\|refined\|thread\|exported\|callback\|struct\|trait\|fn\|type\)\>}}}}
        {words {exported callback c}
         textmate {match {\b(exported|callback)\s+(c)\s+(?=fn\b)} captures {1 contextual 2 contextual}}
         vim {{{} exported|callback {\s\+c\s\+fn\>}} {{\<\(exported\|callback\)\s\+} c {\s\+fn\>}}}}
        {words {enum}
         textmate {match {^\s*(?:private\s+)?(enum)\s+(?=[A-Za-z_])} captures {1 contextual}}
         vim {{{^\s*\(private\s\+\)\=} enum {\s\+\h}}}}
        {words {union layout}
         textmate {match {^\s*(?:private\s+)?(?:(union)\s+)?(layout)\s+(?=[A-Za-z_])} captures {1 contextual 2 contextual}}
         vim {{{^\s*\(private\s\+\)\=} union {\s\+layout\>}} {{^\s*\(private\s\+\)\=\(union\s\+\)\=} layout {\s\+\h}}}}
        {words {trait}
         textmate {match {\b(trait)\s+(?=[A-Za-z_]\w*\s*:)} captures {1 contextual}}
         vim {{{} trait {\s\+\h\w*\s*:}}}}
        {words {dfa over}
         textmate {match {^\s*(dfa)\s+[A-Za-z_]\w*\s+(over)\b} captures {1 contextual 2 contextual}}
         vim {{{^\s*} dfa {\s\+\h\w*\s\+over\>}} {{^\s*dfa\s\+\h\w*\s\+} over {}}}}
        {words {class any except}
         textmate {begin {^\s*(class)\s+(?=[A-Za-z_]\w*\s*=)} beginCaptures {1 contextual} end {$}
                   patterns {{match {\b(any|except)\b} captures {1 contextual}}}}
         vim {{{^\s*} class {\s\+\h\w*\s*=}} {{^\s*class\s\+\h\w*\s*=.*} any|except {}}}}
        {words {accept reject call before}
         textmate {match {->\s*(accept|reject|call)\b(?:\s+(before)\b)?} captures {1 contextual 2 contextual}}
         vim {{{->\s*} accept|reject|call {}} {{->\s*accept\s\+} before {}}}}
        {words {then accept}
         textmate {match {(?<=[\w:]\s)(then)\b(?:\s+(accept)\b)?(?=\s*(?:#.*)?$|\s+[A-Za-z_])} captures {1 contextual 2 contextual}}
         vim {{{->\s*call\s\+\h[[:alnum:]_:]*\s\+} then {}} {{->\s*call\s\+\h[[:alnum:]_:]*\s\+then\s\+} accept {}}}}
        {words {any end}
         textmate {match {(?:^\s+|,\s*)(any|end)\b(?=\s*(?:,|->))} captures {1 contextual}}
         vim {{{\(^\s\+\|,\s*\)} any|end {\s*\(,\|->\)}}}}
        {words {extern c library framework}
         textmate {match {^\s*(?:private\s+)?(extern)\s+(c)\b(?:\s+(library|framework)\b)?} captures {1 contextual 2 contextual 3 contextual}}
         vim {{{^\s*\(private\s\+\)\=} extern {\s\+c\>}} {{^\s*\(private\s\+\)\=extern\s\+} c {}} {{^\s*\(private\s\+\)\=extern\s\+c\s\+} library|framework {}}}}
        {words {static at}
         textmate {match {(?<=")\s+(static)\b(?:\s+(at)\b)?} captures {1 contextual 2 contextual}}
         vim {{{"\s\+} static {}} {{"\s\+static\s\+} at {}}}}
        {words {named}
         textmate {match {\b(named)\s*(?=")} captures {1 contextual}}
         vim {{{} named {\s*"}}}}
        {words {read write noescape captures proven}
         textmate {match {(?<=[\w\]]\s)(read|write|noescape|captures|proven)\b(?=(?:\s+(?:read|write|noescape|captures|proven)\b)*\s*[,)])} captures {1 contextual}}
         vim {{{\(\w\|]\)\s} read|write|noescape|captures|proven {\(\s\+\(read\|write\|noescape\|captures\|proven\)\>\)*\s*[,)]}}}}
        {words {variadic}
         textmate {match {(?<=[(,])\s*(variadic)\b(?=\s*\)|\s+[A-Za-z_]\w*\s*:)} captures {1 contextual}}
         vim {{{[(,]\s*} variadic {\(\s*)\|\s\+\h\w*\s*:\)}}}}
        {words {independent alias}
         textmate {match {(?<=\S)\s+(?:(independent)|(alias)\s+[A-Za-z_]\w*)\s*$} captures {1 contextual 2 contextual}}
         vim {{{\S\s\+} independent {\s*$}} {{\S\s\+} alias {\s\+\h\w*\s*$}}}}
        {words {place context resume}
         textmate {match {(?<=[(,])\s*(place|context|resume)\s+(?=[A-Za-z_])} captures {1 contextual}}
         vim {{{[(,]\s*} place|context|resume {\s\+\h}}}}
        {words {flags}
         textmate {match {(?<=[(,])\s*(flags)\s+(?=:)} captures {1 contextual}}
         vim {{{[(,]\s*} flags {\s\+:}}}}
        {words {proves}
         textmate {match {\b(proves)\s+(?=[A-Za-z_]\w*\s*:)} captures {1 contextual}}
         vim {{{} proves {\s\+\h\w*\s*:}}}}
        {words {emits}
         textmate {match {\b(emits)\s+(?=[A-Za-z_:][\w:]*\s*[,:])} captures {1 contextual}}
         vim {{{} emits {\s\+[[:alpha:]_:][[:alnum:]_:]*\s*[,:]}}}}
        {words {with context}
         textmate {match {^\s*(with)\s+(context)\b} captures {1 contextual 2 contextual}}
         vim {{{^\s*} with {\s\+context\>}} {{^\s*with\s\+} context {}}}}
        {words {inject no context}
         textmate {match {\b(inject)\s+(?:(no)\s+)?(context)\b} captures {1 contextual 2 contextual 3 contextual}}
         vim {{{} inject {\s\+\(no\s\+\)\=context\>}} {{\<inject\s\+} no {\s\+context\>}} {{\<inject\s\+\(no\s\+\)\=} context {}}}}
        {words {static compile}
         textmate {match {\b(static)\s+(compile)\s*(?=:)} captures {1 contextual 2 contextual}}
         vim {{{} static {\s\+compile\s*:}} {{\<static\s\+} compile {\s*:}}}}
        {words {match}
         textmate {match {^\s*(?:[A-Za-z_]\w*\s*=\s*|return\s+)?(match)\s+(?=[^\s=.].*:\s*(?:#.*)?$)} captures {1 contextual}}
         vim {{{^\s*\(\h\w*\s*=\s*\|return\s\+\)\=} match {\s\+[^ \t=.].*:\s*\(#.*\)\=$}}}}
        {words {case}
         textmate {match {^\s+(case)\s+(?=(?:::)?[A-Za-z_]\w*::)} captures {1 contextual}}
         vim {{{^\s\+} case {\s\+\(::\)\=\h\w*::}}}}
        {words {coroutine}
         textmate {match {\b(coroutine)\s*(?=\{)} captures {1 contextual}}
         vim {{{} coroutine {\s*\%x7b}}}}
        {words {fold in from down to through with intermediate}
         textmate {begin {\b(?:(loop)|(fold))\s+(?=[A-Za-z_]\w*\s+(?:in|from|down)\b|with\b)} beginCaptures {1 control 2 contextual}
                   end {(?=:\s*(?:#.*)?$)}
                   patterns {{match {\b(in|from|down|to|through|with|intermediate)\b} captures {1 contextual}}}}
         vim {{{} fold {\s\+\(\h\w*\s\+\(in\|from\|down\)\>\|with\>\)}}
              {{\<\(loop\|fold\|and\)\s\+\h\w*\s\+} in|from|down {}}
              {{\<\(loop\|fold\|and\)\s\+\h\w*\s\+down\s\+} from {}}
              {{\<\(loop\|fold\)\s.*\s} to|through {\s.*:\s*\(#.*\)\=$}}
              {{\<fold\>.*\s} with {\s\+intermediate\>}}
              {{\<fold\>.*\swith\s\+} intermediate {}}}}
        {words {in}
         textmate {match {^\s*(?:(private)\s+)?(type)\s+([A-Za-z_]\w*)\s*=\s*[A-Za-z_][\w:]*\s+(in)\b} captures {1 contextual 2 declaration 3 typeName 4 contextual}}
         vim {{{^\s*\(private\s\+\)\=type\s\+\h\w*\s*=\s*\h[[:alnum:]_:]*\s\+} in {}}}}
        {words {identity}
         textmate {match {^\s+(identity)\s+(?=[A-Za-z_])} captures {1 contextual}}
         vim {{{^\s\+} identity {\s\+\h}}}}
        {words {sendable as}
         textmate {begin {^\s+(sendable)\s+(?=[A-Za-z_])} beginCaptures {1 contextual} end {$}
                   patterns {{match {\b(as)\s+(?=[A-Za-z_])} captures {1 contextual}}}}
         vim {{{^\s\+} sendable {\s\+\h}} {{^\s\+sendable\>.*} as {\s\+\h}}}}
        {words {satisfies}
         textmate {match {(?<=\w)\s+(satisfies)\s+(?=[A-Za-z_])} captures {1 contextual}}
         vim {{{\w\s\+} satisfies {\s\+\h}}}}
        {words {size align}
         textmate {match {^\s+(size|align)\s+(?=\d)} captures {1 contextual}}
         vim {{{^\s\+} size|align {\s\+\d}}}}
        {words {field alternative at}
         textmate {match {^\s+(field|alternative)\s+(?=[A-Za-z_]\w*\s*:)|\s(at)\s+(?=\d+\s*(?:#.*)?$)} captures {1 contextual 2 contextual}}
         vim {{{^\s\+} field|alternative {\s\+\h\w*\s*:}} {{\s} at {\s\+\d\+\s*\(#.*\)\=$}}}}
        {words {array of}
         textmate {match {\b(array)\s+(\d+)\s+(of)\b} captures {1 contextual 2 number 3 contextual}}
         vim {{{} array {\s\+\d\+\s\+of\>}} {{\<array\s\+\d\+\s\+} of {}}}}
    }
}

# The roles' keywords, checked against the lexer's: every keyword in exactly
# one group.
proc grammars::Keywords {} {
    variable groups
    set placed {}
    dict for {group words} $groups {
        lappend placed {*}$words
    }
    if {[lsort $placed] ne [lsort -unique $placed]} {
        error "a keyword is placed in two groups"
    }
    if {[lsort $placed] ne [lsort $::surface::lexer::keywords]} {
        error "the keyword groups are not the lexer's keywords: placed [lsort $placed], the lexer's [lsort $::surface::lexer::keywords]"
    }
    return $groups
}

# The contextual patterns, checked: their words are the parser's, all of them.
proc grammars::Contextual {} {
    variable contextual
    set covered {}
    foreach entry $contextual {
        foreach word [dict get $entry words] {
            if {$word ni $::surface::parser::words} {
                error "a pattern names \"$word\", no contextual word of the parser (surface::parser::words)"
            }
            lappend covered $word
        }
    }
    set missing [lmap word $::surface::parser::words {
        if {$word in $covered} continue
        set word
    }]
    if {$missing ne ""} {
        error "no pattern highlights the parser's contextual words [join $missing {, }]: add one (tools/editor-grammars.tcl)"
    }
    return $contextual
}

# ---------------------------------------------------------------------------
# TextMate

proc grammars::Scope {role} {
    variable scopes
    return [dict get $scopes $role]
}

proc grammars::Captures {captures} {
    set members {}
    dict for {index role} $captures {
        lappend members $index [lsp::json::obj name [lsp::json::str [Scope $role]]]
    }
    return [list obj $members]
}

proc grammars::Rule {rule} {
    if {[dict exists $rule match]} {
        return [lsp::json::obj match [lsp::json::str [dict get $rule match]] \
            captures [Captures [dict get $rule captures]]]
    }
    return [lsp::json::obj begin [lsp::json::str [dict get $rule begin]] \
        beginCaptures [Captures [dict get $rule beginCaptures]] \
        end [lsp::json::str [dict get $rule end]] \
        patterns [lsp::json::arrayOf [concat [lmap r [dict get $rule patterns] {Rule $r}] \
            [list [lsp::json::obj include {str #literals}] [lsp::json::obj include {str #keywords}] \
                [lsp::json::obj include {str #operators}]]]]]
}

proc grammars::Words {words} {
    return "\\b(?:[join $words |])\\b(?!\\?)"
}

proc grammars::TextMate {} {
    set groups [Keywords]
    set contextual [Contextual]
    set literals [lsp::json::arrayOf [list \
        [lsp::json::obj name {str comment.line.number-sign.botlish} match {str {#.*$}}] \
        [lsp::json::obj name {str string.quoted.double.botlish} begin {str {"}} end {str {"|$}} \
            patterns [lsp::json::arrayOf [list \
                [lsp::json::obj name {str constant.character.escape.botlish} match {str {\\[\\"nrt]}}] \
                [lsp::json::obj name {str invalid.illegal.escape.botlish} match {str {\\.}}]]]] \
        [lsp::json::obj name {str string.quoted.single.botlish} match {str {'(?:\\[\\'nrt]|[^'\\])*'}}] \
        [lsp::json::obj name {str constant.numeric.decimal.botlish} match {str {\b\d+\.\d+(?:[eE][+-]?\d+)?\b}}] \
        [lsp::json::obj name {str constant.numeric.hex.botlish} match {str {\b0[xX][0-9A-Fa-f]+\b}}] \
        [lsp::json::obj name {str constant.numeric.integer.botlish} match {str {\b\d+\b}}] \
        [lsp::json::obj name [lsp::json::str [Scope constant]] match [lsp::json::str [Words [dict get $groups constant]]]]]]
    set keywords [lsp::json::arrayOf [list \
        [lsp::json::obj match {str {\b(fn)\s+([A-Za-z_]\w*\??)}} captures [lsp::json::obj \
            1 [lsp::json::obj name [lsp::json::str [Scope declaration]]] \
            2 [lsp::json::obj name [lsp::json::str [Scope functionName]]]]] \
        [lsp::json::obj match {str {\b(struct|type|error)\s+([A-Za-z_]\w*)\b(?!\s*::)}} captures [lsp::json::obj \
            1 [lsp::json::obj name [lsp::json::str [Scope declaration]]] \
            2 [lsp::json::obj name [lsp::json::str [Scope typeName]]]]] \
        [lsp::json::obj name [lsp::json::str [Scope control]] match [lsp::json::str [Words [dict get $groups control]]]] \
        [lsp::json::obj name [lsp::json::str [Scope declaration]] match [lsp::json::str [Words [dict get $groups declaration]]]] \
        [lsp::json::obj name [lsp::json::str [Scope operatorWord]] match [lsp::json::str [Words [dict get $groups operatorWord]]]]]]
    set operators [lsp::json::arrayOf [list \
        [lsp::json::obj name {str keyword.operator.botlish} match {str {->|::|==|!=|<=|>=|\.\.|[-+*/<>=.]}}] \
        [lsp::json::obj name {str punctuation.separator.botlish} match {str {[,:]}}]]]
    return [lsp::json::obj \
        information_for_contributors [lsp::json::arrayOf [list \
            {str {Generated by tools/editor-grammars.tcl from the compiler's word lists: do not edit.}} \
            {str {Regenerate with: tclsh9.0 tools/editor-grammars.tcl generate}}]] \
        name {str Botlish} scopeName {str source.botlish} \
        fileTypes [lsp::json::arrayOf {{str bot}}] \
        patterns [lsp::json::arrayOf [list {obj {include {str #literals}}} {obj {include {str #contextual}}} \
            {obj {include {str #keywords}}} {obj {include {str #operators}}}]] \
        repository [lsp::json::obj \
            literals [lsp::json::obj patterns $literals] \
            contextual [lsp::json::obj patterns [lsp::json::arrayOf [lmap entry $contextual {Rule [dict get $entry textmate]}]]] \
            keywords [lsp::json::obj patterns $keywords] \
            operators [lsp::json::obj patterns $operators]]]
}

# VALUE (a typed JSON value) as indented JSON text.
proc grammars::Json {value {indent ""}} {
    lassign $value type payload
    set inner "$indent  "
    switch -- $type {
        obj {
            if {$payload eq {}} {
                return "{}"
            }
            set members {}
            foreach {key member} $payload {
                lappend members "$inner[lsp::json::write [lsp::json::str $key]]: [Json $member $inner]"
            }
            return "\{\n[join $members ",\n"]\n$indent\}"
        }
        arr {
            if {$payload eq {}} {
                return "\[\]"
            }
            return "\[\n[join [lmap item $payload {string cat $inner [Json $item $inner]}] ",\n"]\n$indent\]"
        }
        default {
            return [lsp::json::write $value]
        }
    }
}

# ---------------------------------------------------------------------------
# Vim

proc grammars::Vim {} {
    set groups [Keywords]
    set contextual [Contextual]
    set lines {
        {" Vim syntax file for Botlish (Vim and Neovim).}
        {" Generated by tools/editor-grammars.tcl from the compiler's word lists:}
        {" do not edit. Regenerate with: tclsh9.0 tools/editor-grammars.tcl generate}
        {}
        {if exists('b:current_syntax')}
        {  finish}
        {endif}
        {}
        {" A name may end in one "?" (even?): a keyword's spelling with one is a name.}
        {syn iskeyword @,48-57,_,192-255,?}
        {}
    }
    foreach {group name} {control botlishControl declaration botlishDeclaration operatorWord botlishOperatorWord constant botlishConstant} {
        lappend lines "syn keyword $name [join [dict get $groups $group]]"
    }
    lappend lines ""
    lappend lines {" The contextual words, where the parser reads them as words.}
    foreach entry $contextual {
        foreach pattern [dict get $entry vim] {
            lappend lines "syn match botlishContextual [VimString [VimPattern {*}$pattern]]"
        }
    }
    lappend lines "" \
        {syn match botlishFunction "\(\<fn\s\+\)\@<=\h\w*?\="} \
        {syn match botlishType "\(\<\(struct\|type\|error\)\s\+\)\@<=\h\w*\>\(\s*::\)\@!"} \
        {syn match botlishNumber "\<\d\+\.\d\+\([eE][+-]\=\d\+\)\=\>"} \
        {syn match botlishNumber "\<0[xX]\x\+\>"} \
        {syn match botlishNumber "\<\d\+\>"} \
        {syn match botlishOperator "->\|::\|==\|!=\|<=\|>=\|\.\.\|[-+*/<>=.]"} \
        {syn match botlishEscape "\\[\\"nrt]" contained} \
        {syn region botlishString start=+"+ skip=+\\\\\|\\"+ end=+"\|$+ contains=botlishEscape} \
        {syn match botlishChar "'\(\\[\\'nrt]\|[^'\\]\)*'"} \
        {syn match botlishComment "#.*$"} \
        "" \
        {hi def link botlishControl Statement} \
        {hi def link botlishDeclaration Keyword} \
        {hi def link botlishOperatorWord Keyword} \
        {hi def link botlishContextual Keyword} \
        {hi def link botlishConstant Constant} \
        {hi def link botlishNumber Number} \
        {hi def link botlishString String} \
        {hi def link botlishChar Character} \
        {hi def link botlishEscape SpecialChar} \
        {hi def link botlishComment Comment} \
        {hi def link botlishOperator Operator} \
        {hi def link botlishFunction Function} \
        {hi def link botlishType Type} \
        "" \
        {let b:current_syntax = 'botlish'}
    return "[join $lines \n]\n"
}

# A Vim pattern (magic) of one of WORDS ("|"-separated), with PREFIX before
# it as a lookbehind and SUFFIX after it as a lookahead ("" for none).
proc grammars::VimPattern {prefix words suffix} {
    set pattern "\\<\\([join [split $words |] {\|}]\\)\\>"
    if {$prefix ne ""} {
        set pattern "\\($prefix\\)\\@<=$pattern"
    }
    if {$suffix ne ""} {
        append pattern "\\($suffix\\)\\@="
    }
    return $pattern
}

# PATTERN as a :syn match pattern argument: delimited by a character it does
# not hold.
proc grammars::VimString {pattern} {
    foreach delimiter [list "\"" + ! ~ @ ;] {
        if {[string first $delimiter $pattern] < 0} {
            return "$delimiter$pattern$delimiter"
        }
    }
    error "no delimiter for Vim pattern $pattern"
}

# ---------------------------------------------------------------------------

# The highlight classes of the grammars' fixture (editors/vscode/test/
# fixtures/sample.bot: every lexical class, every contextual word where the
# parser reads it, and names of the same spellings), as the token IR says
# (surface::tokens::classes), a name the grammars mark as declared (Declared)
# classed `declared`: {LINE CHARACTER LENGTH CLASS} each, LINE and
# CHARACTER 0-based, CHARACTER and LENGTH in UTF-16 code units (a JavaScript
# string's indices). What the editor grammars' tests tokenize the fixture
# against (editors/vscode/test/grammar.test.js, tests/syntax-highlighting.test).
proc grammars::FixtureClasses {} {
    variable root
    set path [file join $root editors vscode test fixtures sample.bot]
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [surface::source::normalize [read $channel]]
    close $channel
    set starts [surface::tokens::LineStarts $text]
    set declared [Declared $text sample.bot]
    set items {}
    foreach item [surface::tokens::classes [surface::syntaxTokens $text sample.bot]] {
        lassign $item start end class
        if {$class eq "identifier" && $start in $declared} {
            set class declared
        }
        set line [lsearch -integer -bisect $starts $start]
        set lineStart [lindex $starts $line]
        set before [string range $text $lineStart [expr {$start - 1}]]
        set token [string range $text $start [expr {$end - 1}]]
        lappend items [lsp::json::arrayOf [list [lsp::json::int $line] \
            [lsp::json::int [Units $before]] [lsp::json::int [Units $token]] [lsp::json::str $class]]]
    }
    return [lsp::json::arrayOf $items]
}

# The names the editor grammars mark as declared (TextMate's entity.name.
# function and entity.name.type, Vim's botlishFunction and botlishType): the
# offsets at which the syntax tree of TEXT has the name of a declaration that
# `fn`, `struct`, `type` or `error` introduces -- a function (an extern's and
# a trait's requirement's included), a struct, a type (a refinement's
# included), an error. A grammar that marks a name anywhere else (`std` in
# `import type std::ffi::c::Int`) disagrees with the parser.
proc grammars::Declared {text file} {
    set offsets {}
    DeclaredIn [surface::parse $text $file] offsets
    return [lsort -integer -unique $offsets]
}

proc grammars::DeclaredIn {node offsetsVar} {
    upvar 1 $offsetsVar offsets
    if {![dict exists $node kind]} {
        return
    }
    set named {}
    if {[dict get $node kind] in {function externfn structdecl typedecl errordecl}} {
        lappend named $node
    }
    lappend named {*}[dict getdef $node requirements {}]
    foreach item $named {
        if {[dict getdef $item nameSpan ""] ne ""} {
            lappend offsets [dict get $item nameSpan start]
        }
    }
    foreach child [surface::ast::Children $node] {
        DeclaredIn $child offsets
    }
}

# TEXT's length in UTF-16 code units.
proc grammars::Units {text} {
    return [expr {[string length $text] + [regexp -all {[\U00010000-\U0010FFFF]} $text]}]
}

proc grammars::Outputs {} {
    variable root
    return [list \
        [file join $root editors vscode syntaxes botlish.tmLanguage.json] "[Json [TextMate]]\n" \
        [file join $root editors neovim syntax botlish.vim] [Vim] \
        [file join $root editors vscode test fixtures sample.classes.json] \
            "[join [lmap item [lindex [FixtureClasses] 1] {lsp::json::write $item}] \n]\n"]
}

proc grammars::main {argv} {
    set command [lindex $argv 0]
    switch -- $command {
        generate {
            foreach {path text} [Outputs] {
                file mkdir [file dirname $path]
                set channel [open $path w]
                fconfigure $channel -encoding utf-8 -translation lf
                puts -nonewline $channel $text
                close $channel
                puts "wrote $path"
            }
            return 0
        }
        check {
            set stale 0
            foreach {path text} [Outputs] {
                set committed ""
                if {[file exists $path]} {
                    set channel [open $path]
                    fconfigure $channel -encoding utf-8
                    set committed [read $channel]
                    close $channel
                }
                if {$committed ne $text} {
                    puts "stale: $path (regenerate: tclsh9.0 tools/editor-grammars.tcl generate)"
                    set stale 1
                }
            }
            return $stale
        }
        default {
            puts stderr "usage: tclsh9.0 tools/editor-grammars.tcl generate|check"
            return 2
        }
    }
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    exit [grammars::main $argv]
}
