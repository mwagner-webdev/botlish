# lexer.tcl -- indentation-sensitive tokenizer for Botlish source.
#
#   surface::lex SOURCE ?FILENAME?      => list of tokens
#
# A token is a dict {kind text value span}:
#
#   IDENT     [A-Za-z_][A-Za-z0-9_]*, not a keyword        value: the name
#   INT       decimal digits, no leading zeros              value: the digits
#   STRING    "..." on one line; escapes \\ \" \n \r \t     value: decoded text
#   keywords  fn if else loop return break continue true false unit
#             (kind is the word itself)
#   operators ( ) [ ] , : = == < <= > >= + - *   (kind is the text itself)
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
# The lexer stops at the first error (surface::syntaxError). Every token and
# error carries a full span, so error recovery (skipping to the next line and
# reporting several diagnostics) can later be added here and in the parser
# without changing the token format.

namespace eval surface::lexer {
    variable keywords {fn if else loop return break continue true false unit}
    # Longest operators first.
    variable operators {== <= >= ( ) [ ] , : = < > + - *}
}

proc surface::lex {source {filename <input>}} {
    return [surface::lexer::tokenize $source $filename]
}

proc surface::lexer::tokenize {source file} {
    variable keywords
    variable operators
    set n [string length $source]
    set tokens {}
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
                Fail $file $tab $line $lineStart 1 "tab used for indentation"
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
                    Fail $file $j $line $lineStart 0 \
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
                    Fail $file $i $line $lineStart 1 "unexpected carriage return"
                }
                incr i
            }
            "\n" {
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
                lappend tokens [String $source $i $file $line $lineStart]
                set i [dict get [lindex $tokens end] span end]
            }
            {[0-9]} {
                set j $i
                while {$j < $n && [string index $source $j] in {0 1 2 3 4 5 6 7 8 9}} {
                    incr j
                }
                set text [string range $source $i $j-1]
                if {$j < $n && [regexp {[A-Za-z_]} [string index $source $j]]} {
                    Fail $file $i $line $lineStart [expr {$j - $i + 1}] "invalid integer literal"
                }
                if {[string length $text] > 1 && [string index $text 0] eq "0"} {
                    Fail $file $i $line $lineStart [string length $text] \
                        "invalid integer literal \"$text\": leading zeros are not allowed"
                }
                lappend tokens [Token INT $text $text [Span $file $i $j $line $lineStart]]
                set i $j
            }
            {[A-Za-z_]} {
                set j $i
                while {$j < $n && [regexp {[A-Za-z0-9_]} [string index $source $j]]} {
                    incr j
                }
                set text [string range $source $i $j-1]
                if {[string index $source $j] eq "?"} {
                    Fail $file $j $line $lineStart 1 "\"?\" is reserved and cannot be part of a name"
                }
                set kind [expr {$text in $keywords ? $text : "IDENT"}]
                lappend tokens [Token $kind $text $text [Span $file $i $j $line $lineStart]]
                set i $j
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
                    Fail $file $i $line $lineStart 1 "unexpected character $what"
                }
                set j [expr {$i + [string length $found]}]
                set span [Span $file $i $j $line $lineStart]
                switch -- $found {
                    ( - [ {
                        lappend brackets [list $found $span]
                    }
                    ) - ] {
                        set opener [expr {$found eq ")" ? "(" : "\["}]
                        if {$brackets eq ""} {
                            surface::syntaxError $span "unmatched \"$found\""
                        }
                        if {[lindex $brackets end 0] ne $opener} {
                            surface::syntaxError $span \
                                "\"$found\" does not match \"[lindex $brackets end 0]\" opened at [surface::ast::location [lindex $brackets end 1]]"
                        }
                        set brackets [lrange $brackets 0 end-1]
                    }
                }
                lappend tokens [Token $found $found "" $span]
                set i $j
            }
        }
    }

    if {$brackets ne ""} {
        surface::syntaxError [lindex $brackets end 1] "\"[lindex $brackets end 0]\" is never closed"
    }
    set here [Span $file $n $n $line $lineStart]
    if {$tokens ne "" && [dict get [lindex $tokens end] kind] ni {NEWLINE INDENT DEDENT}} {
        lappend tokens [Token NEWLINE "" "" $here]
    }
    foreach level [lrange $indents 1 end] {
        lappend tokens [Token DEDENT "" "" $here]
    }
    lappend tokens [Token EOF "" "" $here]
    return $tokens
}

proc surface::lexer::Token {kind text value span} {
    return [dict create kind $kind text $text value $value span $span]
}

# The span of offsets START..END on the line starting at LINESTART.
proc surface::lexer::Span {file start end line lineStart} {
    return [surface::ast::span $file $start $end $line [expr {$start - $lineStart + 1}] \
        $line [expr {$end - $lineStart + 1}]]
}

proc surface::lexer::Fail {file start line lineStart length message} {
    surface::syntaxError [Span $file $start [expr {$start + $length}] $line $lineStart] $message
}

# The STRING token starting at the quote at offset START.
proc surface::lexer::String {source start file line lineStart} {
    set n [string length $source]
    set i [expr {$start + 1}]
    set value ""
    while 1 {
        if {$i >= $n || [string index $source $i] in {"\n" "\r"}} {
            Fail $file $start $line $lineStart [expr {$i - $start}] "unterminated string"
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
                        Fail $file $start $line $lineStart [expr {$i + 1 - $start}] "unterminated string"
                    }
                    Fail $file $i $line $lineStart 2 "invalid escape \"\\$e\" in string"
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
