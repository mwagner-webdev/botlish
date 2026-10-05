# rewrite.tcl -- the mechanical method-sugar rewrite the METHOD-ELIGIBLE audits
# use to *check* the round-trip law (WARNINGS-METHOD-ELIGIBLE.md). It is an
# audit tool, never a fixit: the compiler prints no rewrite and carries none.
#
#   me::sugarCall TEXT FILE START END MEMBER   => TEXT with the call written
#                                                 f(R, rest...) at [START, END)
#                                                 respelled R.MEMBER(rest...)
#   me::findCall TEXT FILE START END           => the surface `call` AST node
#
# The call is located by the span its warning carries (a half-open character
# range of TEXT); the receiver and the remaining arguments are cut out of TEXT
# by the spans of the parser's own AST, so nothing here reads a call's
# spelling: it moves one argument's text behind a dot.

namespace eval me {}

proc me::findCall {text file start end} {
    set ast [surface::parse $text $file]
    set found ""
    foreach statement [dict get $ast body] {
        set found [FindIn $statement $start $end]
        if {$found ne ""} {
            return $found
        }
    }
    error "no call at $start..$end in $file"
}

proc me::FindIn {node start end} {
    if {[dict get $node kind] eq "call"
            && [dict get $node span start] == $start && [dict get $node span end] == $end} {
        return $node
    }
    foreach child [surface::ast::Children $node] {
        set found [FindIn $child $start $end]
        if {$found ne ""} {
            return $found
        }
    }
    return ""
}

proc me::sugarCall {text file start end member} {
    set call [findCall $text $file $start $end]
    set receiver [lindex [dict get $call args] 0]
    set rStart [dict get $receiver span start]
    set rEnd [dict get $receiver span end]
    set receiverText [string range $text $rStart [expr {$rEnd - 1}]]
    # After the receiver (and any parentheses that wrapped it) comes the
    # comma that separates it from the remaining arguments.
    set i $rEnd
    while {[string index $text $i] ne ","} {
        incr i
        if {$i >= $end} {
            error "no argument separator after the receiver of the call at $start..$end"
        }
    }
    set rest [string trimleft [string range $text [expr {$i + 1}] [expr {$end - 2}]]]
    return [string cat [string range $text 0 [expr {$start - 1}]] \
        $receiverText . $member ( $rest ) [string range $text $end end]]
}
