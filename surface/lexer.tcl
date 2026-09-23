# lexer.tcl -- indentation-sensitive tokenizer for Botlish source.
#
#   surface::lex SOURCE ?FILENAME?          => list of tokens; raises the first
#                                              syntax error
#   surface::lexer::tokenize SOURCE FILE    => {tokens TOKENS diagnostics DIAGS}
#
# A token is a dict {kind text value span}:
#
#   IDENT     [A-Za-z_][A-Za-z0-9_]*, not a keyword        value: the name
#   INT       decimal digits, no leading zeros              value: the digits
#   STRING    "..." on one line; escapes \\ \" \n \r \t     value: decoded text
#   keywords  fn if else loop return break continue true false unit and or not
#             namespace type (kind is the word itself)
#   operators ( ) [ ] { } , : :: = == != < <= > >= + - * -> ..
#             (kind is the text itself)
#   NEWLINE   end of a logical line
#   INDENT    the next logical line is indented deeper
#   DEDENT    one indentation level ends
#   EOF
#
# Layout rules:
#
# * Indentation is counted in spaces; a tab in indentation is an error. Any
#   deeper indentation opens a level; a shallower one must return exactly to
#   an enclosing level.
# * Blank lines and comment-only lines produce no tokens and do not affect
#   indentation. Comments run from # (outside strings) to the end of line.
# * Inside ( ) and [ ], physical newlines and indentation are ignored.
# * At the end of input, the last logical line is terminated and every open
#   level is closed.
#
# Errors never stop tokenizing. Each is recorded as a diagnostic (ast.tcl)
# and the lexer recovers locally, so a parser can still see the rest:
#
#   tab in indentation         the tab counts as one column
#   inconsistent dedent        the line joins the enclosing level it passed
#   unexpected character       skipped
#   "?" after a name           skipped
#   invalid integer            an INT of its digits (leading zeros dropped)
#   unterminated string        the string ends at the end of line
#   invalid escape             the escaped character is kept
#   unmatched ")" or "]"       skipped
#   mismatched ")" or "]"      closes the open bracket
#   bracket never closed       closed by a zero-width token at the end of
#                              input, or before a line that starts like a
#                              statement (see UnclosedBefore)

namespace eval surface::lexer {
    variable keywords {fn if else loop return break continue true false unit and or not namespace type}
    # Longest operators first ("::" before ":", so a module-qualified name
    # like web::uri_escape does not lex as ":" ":"). "{" and "}" are not
    # ordinary block syntax (Botlish blocks are ":" + indentation): they
    # denote only a type declaration's finite integer-set domain
    # (surface/parser.tcl's Domain), a context-sensitive meaning decided by
    # the parser, not the lexer -- the lexer just hands back a token.
    variable operators [list == != <= >= :: -> ( ) \[ \] \{ \} , : = < > + - *]
}

proc surface::lex {source {filename <input>}} {
    set result [surface::lexer::tokenize $source $filename]
    foreach diagnostic [dict get $result diagnostics] {
        surface::raise $diagnostic
    }
    return [dict get $result tokens]
}

proc surface::lexer::tokenize {source file} {
    variable keywords
    variable operators
    set n [string length $source]
    set tokens {}
    set diagnostics {}
    set i 0
    set line 1
    set lineStart 0
    set indents {0}
    set brackets {}
    set atLineStart 1

    while 1 {
        if {$atLineStart && $brackets eq ""} {
            set atLineStart 0
            # Leading whitespace of a physical line outside brackets.
            set j $i
            set tab -1
            while {$j < $n && [string index $source $j] in {" " "\t"}} {
                if {$tab < 0 && [string index $source $j] eq "\t"} {
                    set tab $j
                }
                incr j
            }
            set c [string index $source $j]
            if {$j >= $n} {
                set i $j
                break
            }
            if {$c eq "#" || $c eq "\n" || ($c eq "\r" && [string index $source $j+1] eq "\n")} {
                # Blank or comment-only: skip to the end of line.
                set i $j
                while {$i < $n && [string index $source $i] ne "\n"} {
                    incr i
                }
                if {$i >= $n} {
                    break
                }
                incr i
                incr line
                set lineStart $i
                set atLineStart 1
                continue
            }
            if {$tab >= 0} {
                Report diagnostics $file $tab $line $lineStart 1 "tab used for indentation"
            }
            set width [expr {$j - $i}]
            set here [Span $file $j $j $line $lineStart]
            if {$width > [lindex $indents end]} {
                lappend indents $width
                lappend tokens [Token INDENT "" "" $here]
            } else {
                while {$width < [lindex $indents end]} {
                    set indents [lrange $indents 0 end-1]
                    lappend tokens [Token DEDENT "" "" $here]
                }
                if {$width != [lindex $indents end]} {
                    Report diagnostics $file $j $line $lineStart 0 \
                        "inconsistent dedent: indentation does not match any enclosing level"
                }
            }
            set i $j
        }

        if {$i >= $n} {
            break
        }
        set c [string index $source $i]
        switch -glob -- $c {
            " " - "\t" {
                incr i
            }
            "\r" {
                if {[string index $source $i+1] ne "\n"} {
                    Report diagnostics $file $i $line $lineStart 1 "unexpected carriage return"
                }
                incr i
            }
            "\n" {
                if {$brackets ne "" && [UnclosedBefore $source [expr {$i + 1}] [lindex $brackets 0 2]]} {
                    set here [Span $file $i $i $line $lineStart]
                    foreach bracket [lreverse $brackets] {
                        lassign $bracket opener span
                        lappend diagnostics [surface::diagnostic $span "\"$opener\" is never closed"]
                        lappend tokens [Token [Closer $opener] "" "" $here]
                    }
                    set brackets {}
                }
                if {$brackets eq ""} {
                    if {$tokens ne "" && [dict get [lindex $tokens end] kind] ni {NEWLINE INDENT DEDENT}} {
                        lappend tokens [Token NEWLINE "\n" "" [Span $file $i [expr {$i + 1}] $line $lineStart]]
                    }
                    set atLineStart 1
                }
                incr i
                incr line
                set lineStart $i
            }
            "#" {
                while {$i < $n && [string index $source $i] ne "\n"} {
                    incr i
                }
            }
            {"} {
                lappend tokens [String $source $i $file $line $lineStart diagnostics]
                set i [dict get [lindex $tokens end] span end]
            }
            {[0-9]} {
                set j $i
                while {$j < $n && [string index $source $j] in {0 1 2 3 4 5 6 7 8 9}} {
                    incr j
                }
                set digits [string range $source $i $j-1]
                set end $j
                while {$end < $n && [regexp {[A-Za-z0-9_]} [string index $source $end]]} {
                    incr end
                }
                if {$end > $j} {
                    Report diagnostics $file $i $line $lineStart [expr {$end - $i}] "invalid integer literal"
                } elseif {[string length $digits] > 1 && [string index $digits 0] eq "0"} {
                    Report diagnostics $file $i $line $lineStart [string length $digits] \
                        "invalid integer literal \"$digits\": leading zeros are not allowed"
                }
                set value [string trimleft $digits 0]
                if {$value eq ""} {
                    set value 0
                }
                lappend tokens [Token INT [string range $source $i $end-1] $value \
                    [Span $file $i $end $line $lineStart]]
                set i $end
            }
            {.} {
                if {[string index $source $i+1] eq "."} {
                    lappend tokens [Token .. .. "" [Span $file $i [expr {$i + 2}] $line $lineStart]]
                    incr i 2
                } else {
                    Report diagnostics $file $i $line $lineStart 1 "unexpected character \".\""
                    incr i
                }
            }
            {[A-Za-z_]} {
                set j $i
                while {$j < $n && [regexp {[A-Za-z0-9_]} [string index $source $j]]} {
                    incr j
                }
                set text [string range $source $i $j-1]
                set kind [expr {$text in $keywords ? $text : "IDENT"}]
                lappend tokens [Token $kind $text $text [Span $file $i $j $line $lineStart]]
                set i $j
                if {[string index $source $i] eq "?"} {
                    Report diagnostics $file $i $line $lineStart 1 "\"?\" is reserved and cannot be part of a name"
                    incr i
                }
            }
            default {
                set found ""
                foreach op $operators {
                    if {[string equal $op [string range $source $i [expr {$i + [string length $op] - 1}]]]} {
                        set found $op
                        break
                    }
                }
                if {$found eq ""} {
                    set what [expr {[string is print $c] ? "\"$c\"" : [format "U+%04X" [scan $c %c]]}]
                    Report diagnostics $file $i $line $lineStart 1 "unexpected character $what"
                    incr i
                    continue
                }
                set j [expr {$i + [string length $found]}]
                set span [Span $file $i $j $line $lineStart]
                set i $j
                switch -- $found {
                    ( - [ - \{ {
                        lappend brackets [list $found $span [lindex $indents end]]
                    }
                    ) - ] - \} {
                        set opener [dict get {) ( ] [ \} \{} $found]
                        if {$brackets eq ""} {
                            lappend diagnostics [surface::diagnostic $span "unmatched \"$found\""]
                            continue
                        }
                        if {[lindex $brackets end 0] ne $opener} {
                            lappend diagnostics [surface::diagnostic $span \
                                "\"$found\" does not match \"[lindex $brackets end 0]\" opened at [surface::ast::location [lindex $brackets end 1]]"]
                        }
                        set brackets [lrange $brackets 0 end-1]
                    }
                }
                lappend tokens [Token $found $found "" $span]
            }
        }
    }

    set here [Span $file $n $n $line $lineStart]
    foreach bracket [lreverse $brackets] {
        lassign $bracket opener span
        lappend diagnostics [surface::diagnostic $span "\"$opener\" is never closed"]
        lappend tokens [Token [Closer $opener] "" "" $here]
    }
    if {$tokens ne "" && [dict get [lindex $tokens end] kind] ni {NEWLINE INDENT DEDENT}} {
        lappend tokens [Token NEWLINE "" "" $here]
    }
    foreach level [lrange $indents 1 end] {
        lappend tokens [Token DEDENT "" "" $here]
    }
    lappend tokens [Token EOF "" "" $here]
    return [dict create tokens $tokens diagnostics $diagnostics]
}

# True if the physical line starting at offset START cannot continue an
# expression inside brackets: it is indented no deeper than INDENT (the level
# of the line that opened them) and starts like a statement (a statement
# keyword, or a binding). Brackets still open there are never closed.
proc surface::lexer::UnclosedBefore {source start indent} {
    set line [string range $source $start [expr {$start + 200}]]
    if {![regexp {^( *)(\S.*)?} $line -> spaces rest] || $rest eq ""} {
        return 0
    }
    return [expr {[string length $spaces] <= $indent
        && [regexp {^(?:(?:fn|if|else|loop|return|break|continue)\M|[A-Za-z_][A-Za-z0-9_]*[ \t]*=(?!=))} $rest]}]
}

proc surface::lexer::Token {kind text value span} {
    return [dict create kind $kind text $text value $value span $span]
}

# The closing bracket for OPENER ("(", "[" or "{").
proc surface::lexer::Closer {opener} {
    return [dict get {( ) [ \] \{ \}} $opener]
}

# The span of offsets START..END on the line starting at LINESTART.
proc surface::lexer::Span {file start end line lineStart} {
    return [surface::ast::span $file $start $end $line [expr {$start - $lineStart + 1}] \
        $line [expr {$end - $lineStart + 1}]]
}

proc surface::lexer::Report {diagnosticsVar file start line lineStart length message} {
    upvar 1 $diagnosticsVar diagnostics
    lappend diagnostics [surface::diagnostic \
        [Span $file $start [expr {$start + $length}] $line $lineStart] $message]
}

# The STRING token starting at the quote at offset START.
proc surface::lexer::String {source start file line lineStart diagnosticsVar} {
    upvar 1 $diagnosticsVar diagnostics
    set n [string length $source]
    set i [expr {$start + 1}]
    set value ""
    while 1 {
        if {$i >= $n || [string index $source $i] eq "\n"
                || ([string index $source $i] eq "\r" && [string index $source $i+1] eq "\n")} {
            Report diagnostics $file $start $line $lineStart [expr {$i - $start}] "unterminated string"
            break
        }
        set c [string index $source $i]
        if {$c eq "\""} {
            incr i
            break
        }
        if {$c eq "\\"} {
            set e [string index $source $i+1]
            switch -- $e {
                \\ { append value \\ }
                \" { append value \" }
                n  { append value \n }
                r  { append value \r }
                t  { append value \t }
                default {
                    if {$e eq "" || $e eq "\n"} {
                        incr i
                        continue
                    }
                    Report diagnostics $file $i $line $lineStart 2 "invalid escape \"\\$e\" in string"
                    append value $e
                }
            }
            incr i 2
            continue
        }
        append value $c
        incr i
    }
    return [Token STRING [string range $source $start $i-1] $value \
        [Span $file $start $i $line $lineStart]]
}
