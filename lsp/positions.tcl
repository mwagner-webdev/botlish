# positions.tcl -- source coordinates at the language server's boundary
# (LSP-MILESTONE-1.md, "Coordinates").
#
#   lsp::positions::lineStarts TEXT              each line's first offset
#   lsp::positions::toLsp TEXT STARTS OFFSET ENCODING    => {LINE CHARACTER}
#   lsp::positions::fromLsp TEXT STARTS LINE CHARACTER ENCODING   => OFFSET or ""
#   lsp::positions::units TEXT ENCODING          TEXT's length in code units
#
# The compiler counts Unicode scalar values of the normalized text a revision
# analyzed (surface::source::normalize: every "\r\n" and lone "\r" is "\n"):
# 0-based offsets, 1-based lines and columns. The protocol counts 0-based
# lines and, within a line, code units of the negotiated position encoding:
# UTF-16 (every client's, and the default) or UTF-32 (one unit per scalar
# value, the compiler's own count). Conversion happens here and only here,
# always against one exact normalized text: the text the revision analyzed
# (for what the compiler reports) or the text the client's position was
# taken in (for what it asks).
#
# The protocol counts "\n", "\r\n" and "\r" each as one line end, so a
# position's line in the client's text is its line in the normalized text,
# and its character is the same within it: the line's text is identical.
# TEXT here is always normalized.

namespace eval lsp::positions {}

proc lsp::positions::lineStarts {text} {
    set starts [list 0]
    set at 0
    while {[set at [string first \n $text $at]] >= 0} {
        incr at
        lappend starts $at
    }
    return $starts
}

# The number of ENCODING code units of TEXT: one per scalar value in UTF-32;
# in UTF-16, two for each scalar value outside the Basic Multilingual Plane
# (a surrogate pair), one for every other.
proc lsp::positions::units {text encoding} {
    set n [string length $text]
    if {$encoding eq "utf-16"} {
        incr n [regexp -all {[\U00010000-\U0010FFFF]} $text]
    }
    return $n
}

# The 0-based line of OFFSET in the text whose line starts are STARTS.
proc lsp::positions::lineOf {starts offset} {
    set low 0
    set high [expr {[llength $starts] - 1}]
    while {$low < $high} {
        set mid [expr {($low + $high + 1) / 2}]
        if {[lindex $starts $mid] <= $offset} {
            set low $mid
        } else {
            set high [expr {$mid - 1}]
        }
    }
    return $low
}

# The protocol position {LINE CHARACTER} of the scalar offset OFFSET of TEXT
# (an offset past the text is its end).
proc lsp::positions::toLsp {text starts offset encoding} {
    set length [string length $text]
    if {$offset > $length} {
        set offset $length
    }
    if {$offset < 0} {
        set offset 0
    }
    set line [lineOf $starts $offset]
    set start [lindex $starts $line]
    return [list $line [units [string range $text $start [expr {$offset - 1}]] $encoding]]
}

# The scalar offset of the protocol position LINE, CHARACTER in TEXT, or ""
# when LINE is not a line of TEXT. A character past the line's end is its end
# (as the protocol says); a character inside a surrogate pair is the scalar
# value the pair encodes.
proc lsp::positions::fromLsp {text starts line character encoding} {
    if {$line < 0 || $line >= [llength $starts] || $character < 0} {
        return ""
    }
    set start [lindex $starts $line]
    if {$line + 1 < [llength $starts]} {
        set end [expr {[lindex $starts [expr {$line + 1}]] - 1}]
    } else {
        set end [string length $text]
    }
    set lineText [string range $text $start [expr {$end - 1}]]
    if {$encoding ne "utf-16" || ![regexp {[\U00010000-\U0010FFFF]} $lineText]} {
        return [expr {$start + min($character, $end - $start)}]
    }
    set units 0
    set i 0
    foreach c [split $lineText ""] {
        set width [expr {[scan $c %c] > 0xFFFF ? 2 : 1}]
        if {$units + $width > $character} {
            break
        }
        incr units $width
        incr i
    }
    return [expr {$start + $i}]
}
