# tokens.tcl -- the token IR: one specified, validated form of everything the
# lexer and the parser say about a text's tokens (SYNTAX-HIGHLIGHTING-
# MILESTONE-1.md, "The token IR").
#
#   surface::syntaxTokens SOURCE ?FILE?     the IR of SOURCE's recovering parse
#   surface::tokens::fromLexed LEXED SOURCE ?WORDS?
#                                           the IR of a lexer result
#                                           (surface::lexer::tokenize)
#   surface::tokens::toLexed IR SOURCE FILE the lexer result the IR stands for
#   surface::tokens::validate IR SOURCE     raises {SURFACE TOKEN-IR} on a
#                                           malformed IR
#   surface::tokens::classes IR             the highlight classes of the text
#
# The IR is the seam between the front end's syntax and anything else that
# reads a text's tokens: the highlighting of the command line's excerpts and
# of the language server reads only the IR, and a lexer written in another
# language (in Botlish: the rationale is BOTLISH-LEXER-RATIONALE.md) would
# only have to produce it. It holds everything the parser reads of a lexer's
# result: `toLexed` rebuilds that result exactly (tests/syntax-
# highlighting.test checks it over every Botlish file of the repository). It
# holds no syntax tree: that level is the AST's (surface/ast.tcl), which no
# IR specifies.
#
# Version 1, a dict:
#
#   version      1
#   length       the text's length (Unicode scalar values of the normalized
#                text; every offset below counts them, END exclusive)
#   tokens       {KIND START END VALUE} for each token, in order: KIND one of
#                `kinds` (an identifier IDENT, a literal INT HEX DECIMAL
#                STRING CHAR, a keyword or an operator as its own text, the
#                layout NEWLINE INDENT DEDENT, and EOF, last). A token's text
#                is the source's [START, END) -- a NEWLINE's "\n", or nothing
#                at the end of the text; a layout token or a closer the lexer
#                inserted is empty. VALUE: an IDENT's name, an INT's
#                canonical digits, a HEX's decimal digits, a STRING's decoded
#                text, a CHAR's codepoint (decimal), a DECIMAL's text with a
#                lowercase exponent marker, a keyword's own text; "" for
#                every other kind
#   comments     {START END} for each comment, in order: its "#" to the end of
#                its line, the newline excluded
#   diagnostics  {START END MESSAGE ROLES} for each lexical diagnostic, in
#                the lexer's order; ROLES says how the parser's recovery
#                weighs it, a subset of `roles` (surface/lexer.tcl's header)
#   synthetic    the offset of each closer the lexer inserted for a bracket
#                never closed, in the lexer's order
#   words        the indices (in `tokens`) of the identifiers a parse read as
#                contextual words (surface::parser::words), ascending; empty
#                for an IR made from a lexer's result alone
#
# Lines and columns are not in the IR: they follow from the offsets and the
# text (a line ends at "\n"), and toLexed derives them.

namespace eval surface::tokens {
    variable version 1
    # The lexer's keywords and operators are its own lists
    # (surface::lexer), "." and ".." beside them.
    variable layout {NEWLINE INDENT DEDENT EOF}
    variable literals {IDENT INT HEX DECIMAL STRING CHAR}
    variable roles {structural skipped indentation unclosed}
    # The highlight classes (classes), in no order: a keyword, a contextual
    # word (an identifier the parser read as a word of the syntax), a
    # constant keyword (true, false, unit), a number, a string, a character,
    # a comment, an operator or punctuation, and any other identifier.
    variable classNames {keyword word constant number string char comment operator identifier}
    variable constants {true false unit}
}

# Every token kind of version 1.
proc surface::tokens::kinds {} {
    variable layout
    variable literals
    return [list {*}$literals {*}$::surface::lexer::keywords {*}$::surface::lexer::operators . .. {*}$layout]
}

# The IR of SOURCE (the normalized text of FILE): its tokens as the lexer
# reads them, with the identifiers its recovering parse read as contextual
# words. Lexical and syntax errors leave an IR all the same (recovery).
proc surface::syntaxTokens {source {file <input>}} {
    set lexed [surface::lexer::tokenize $source $file]
    set program [surface::parseTokens [dict get $lexed tokens] -recover 1]
    return [surface::tokens::fromLexed $lexed $source [dict get $program words]]
}

# The IR of LEXED, the lexer's result for SOURCE; WORDS the indices of the
# tokens a parse read as contextual words.
proc surface::tokens::fromLexed {lexed source {words {}}} {
    variable version
    variable roles
    set tokens [lmap token [dict get $lexed tokens] {
        set span [dict get $token span]
        list [dict get $token kind] [dict get $span start] [dict get $span end] [dict get $token value]
    }]
    set diagnostics {}
    set index 0
    foreach diagnostic [dict get $lexed diagnostics] {
        set these {}
        foreach role $roles {
            if {$index in [dict get $lexed $role]} {
                lappend these $role
            }
        }
        lappend diagnostics [list [dict get $diagnostic start] [dict get $diagnostic end] \
            [dict get $diagnostic message] $these]
        incr index
    }
    return [dict create version $version length [string length $source] tokens $tokens \
        comments [dict get $lexed comments] diagnostics $diagnostics \
        synthetic [dict get $lexed synthetic] words [lsort -integer -unique $words]]
}

# The lexer's result (surface::lexer::tokenize) that IR, made from SOURCE (the
# normalized text of FILE), stands for: tokens and diagnostics with their
# spans' lines and columns, and the recovery's index lists.
proc surface::tokens::toLexed {ir source file} {
    variable roles
    set starts [LineStarts $source]
    set tokens [lmap token [dict get $ir tokens] {
        lassign $token kind start end value
        dict create kind $kind text [string range $source $start [expr {$end - 1}]] \
            value $value span [Span $file $starts $start $end]
    }]
    set result [dict create tokens $tokens diagnostics {}]
    foreach role $roles {
        dict set result $role {}
    }
    dict set result synthetic [dict get $ir synthetic]
    set index 0
    foreach diagnostic [dict get $ir diagnostics] {
        lassign $diagnostic start end message these
        dict lappend result diagnostics [surface::diagnostic [Span $file $starts $start $end] $message]
        foreach role $these {
            dict lappend result $role $index
        }
        incr index
    }
    dict set result comments [dict get $ir comments]
    # The lexer's key order (surface::lexer::tokenize), so that the two
    # results compare equal as values.
    return [dict create tokens [dict get $result tokens] diagnostics [dict get $result diagnostics] \
        structural [dict get $result structural] skipped [dict get $result skipped] \
        synthetic [dict get $result synthetic] indentation [dict get $result indentation] \
        unclosed [dict get $result unclosed] comments [dict get $result comments]]
}

# The offset of each line's start in TEXT, line 1 first.
proc surface::tokens::LineStarts {text} {
    set starts {0}
    set i 0
    while {[set i [string first \n $text $i]] >= 0} {
        incr i
        lappend starts $i
    }
    return $starts
}

# The span of [START, END) in FILE, STARTS its text's line starts: located by
# START, as the lexer locates every token and diagnostic (its end on the same
# line: no token or lexical diagnostic crosses a line).
proc surface::tokens::Span {file starts start end} {
    set line [lsearch -integer -bisect $starts $start]
    set lineStart [lindex $starts $line]
    incr line
    return [surface::ast::span $file $start $end $line [expr {$start - $lineStart + 1}] \
        $line [expr {$end - $lineStart + 1}]]
}

# Raises {SURFACE TOKEN-IR} with MESSAGE.
proc surface::tokens::Problem {message} {
    return -code error -level 2 -errorcode {SURFACE TOKEN-IR} "token IR: $message"
}

# Checks that IR is a well-formed version 1 IR of SOURCE (the normalized
# text): the format above, every offset inside the text and in order, each
# token's text what its kind says, each word an identifier the parser reads
# as one. Raises {SURFACE TOKEN-IR} at the first problem.
proc surface::tokens::validate {ir source} {
    variable version
    variable roles
    foreach key {version length tokens comments diagnostics synthetic words} {
        if {![dict exists $ir $key]} {
            Problem "no `$key`"
        }
    }
    if {[dict get $ir version] != $version} {
        Problem "version [dict get $ir version], not $version"
    }
    set length [string length $source]
    if {[dict get $ir length] != $length} {
        Problem "length [dict get $ir length] for a text of $length"
    }
    set kinds [kinds]
    set fixed [list {*}$::surface::lexer::keywords {*}$::surface::lexer::operators . ..]
    set synthetic [dict get $ir synthetic]
    set count [llength [dict get $ir tokens]]
    set previous 0
    set index 0
    foreach token [dict get $ir tokens] {
        if {[llength $token] != 4} {
            Problem "token $index is not {KIND START END VALUE}: $token"
        }
        lassign $token kind start end value
        if {$kind ni $kinds} {
            Problem "token $index has no kind of version $version: \"$kind\""
        }
        if {![string is entier -strict $start] || ![string is entier -strict $end]
                || $start < $previous || $end < $start || $end > $length} {
            Problem "token $index ($kind) at \[$start, $end) is out of order or outside the text"
        }
        set previous $start
        set text [string range $source $start [expr {$end - 1}]]
        if {$kind eq "EOF" && ($index != $count - 1 || $start != $length || $end != $length)} {
            Problem "EOF is not the last token, at the end of the text"
        }
        if {$kind ne "EOF" && $index == $count - 1} {
            Problem "the last token is not EOF"
        }
        switch -- $kind {
            INDENT - DEDENT - EOF {
                set ok [expr {$start == $end}]
            }
            NEWLINE {
                set ok [expr {$text eq "\n" || ($start == $end && $end == $length)}]
            }
            IDENT {
                set ok [expr {[regexp {^[A-Za-z_][A-Za-z0-9_]*\??$} $text] && $value eq $text
                    && $text ni $::surface::lexer::keywords}]
            }
            INT {
                set ok [expr {[regexp {^[0-9][A-Za-z0-9_]*$} $text] && [regexp {^(0|[1-9][0-9]*)$} $value]}]
            }
            HEX {
                set ok [expr {[regexp {^0[xX][0-9A-Fa-f][A-Za-z0-9_]*$} $text] && [regexp {^(0|[1-9][0-9]*)$} $value]}]
            }
            DECIMAL {
                set ok [expr {[regexp {^[0-9]+\.[0-9]} $text] && $value eq [string tolower $value]
                    && [string equal -nocase -length [string length $value] $value $text]}]
            }
            STRING {
                set ok [expr {[string index $text 0] eq "\""}]
            }
            CHAR {
                set ok [expr {[string index $text 0] eq "'" && [regexp {^(0|[1-9][0-9]*)$} $value]}]
            }
            default {
                # A keyword is its own text and value; an operator its own
                # text, or a closer the lexer inserted (empty, at one of the
                # synthetic offsets).
                if {$kind in $::surface::lexer::keywords} {
                    set ok [expr {$value eq $kind && $text eq $kind}]
                } else {
                    set ok [expr {$value eq "" && ($text eq $kind
                        || ($start == $end && $kind in {) \] \}} && $start in $synthetic))}]
                }
            }
        }
        if {!$ok} {
            Problem "token $index ($kind \"$value\") does not match its text \"$text\" at \[$start, $end)"
        }
        incr index
    }
    set previous 0
    foreach comment [dict get $ir comments] {
        lassign $comment start end
        if {[llength $comment] != 2 || $start < $previous || $end < $start || $end > $length
                || [string index $source $start] ne "#"
                || [string first \n [string range $source $start [expr {$end - 1}]]] >= 0
                || ($end < $length && [string index $source $end] ne "\n")} {
            Problem "comment \[$start, $end) is not a \"#\" to the end of its line, in order"
        }
        set previous $end
    }
    foreach diagnostic [dict get $ir diagnostics] {
        if {[llength $diagnostic] != 4} {
            Problem "diagnostic is not {START END MESSAGE ROLES}: $diagnostic"
        }
        lassign $diagnostic start end message these
        if {$start < 0 || $end < $start || $end > $length || $message eq ""} {
            Problem "diagnostic \[$start, $end) \"$message\" is outside the text or says nothing"
        }
        foreach role $these {
            if {$role ni $roles} {
                Problem "diagnostic \"$message\" has an unknown role \"$role\""
            }
        }
    }
    set closers [lmap token [dict get $ir tokens] {
        lassign $token kind start end
        if {$start != $end || $kind ni {) \] \}}} continue
        set start
    }]
    foreach offset $synthetic {
        if {$offset ni $closers} {
            Problem "synthetic offset $offset holds no inserted closer"
        }
    }
    set words [dict get $ir words]
    if {$words ne [lsort -integer -unique $words]} {
        Problem "words are not ascending token indices"
    }
    foreach word $words {
        if {![string is entier -strict $word] || $word < 0 || $word >= $count} {
            Problem "word $word is no token index"
        }
        lassign [lindex [dict get $ir tokens] $word] kind start end value
        if {$kind ne "IDENT" || $value ni $::surface::parser::words} {
            Problem "word $word (\"$value\") is no identifier the parser reads as a contextual word"
        }
    }
}

# The highlight classes of IR's text: {START END CLASS} for each token that
# has text and each comment, ordered by START; CLASS one of `classNames`. The
# one classification every highlighter reads (the command line's excerpts,
# the language server's semantic tokens; the editor grammars are checked
# against it).
proc surface::tokens::classes {ir} {
    variable constants
    set words [dict create]
    foreach word [dict get $ir words] {
        dict set words $word 1
    }
    set items {}
    set index -1
    foreach token [dict get $ir tokens] {
        incr index
        lassign $token kind start end
        if {$start == $end} {
            continue
        }
        switch -- $kind {
            NEWLINE { continue }
            IDENT {
                if {[dict exists $words $index]} {
                    set class word
                } else {
                    set class identifier
                }
            }
            INT - HEX - DECIMAL { set class number }
            STRING { set class string }
            CHAR { set class char }
            default {
                if {$kind in $constants} {
                    set class constant
                } elseif {$kind in $::surface::lexer::keywords} {
                    set class keyword
                } else {
                    set class operator
                }
            }
        }
        lappend items [list $start $end $class]
    }
    foreach comment [dict get $ir comments] {
        lappend items [list {*}$comment comment]
    }
    return [lsort -integer -index 0 $items]
}
