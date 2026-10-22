# coords.tcl -- which coordinates do the compiler's source positions count?
# (COMPILER-SERVICE-CENSUS.md, "Source coordinates")
#
#   tclsh9.0 audit/compiler-service/probes/coords.tcl
#
# Writes programs with non-ASCII text before a queried identifier on the same
# line (a BMP character, an astral one, a combining sequence), and one with
# CRLF line endings, reads them through the ordinary front end, and prints,
# for the identifier, the compiler's column and offset beside the UTF-8 byte,
# UTF-16 code unit and Unicode scalar counts. It also checks the identifier
# rule (ASCII only) and what an in-memory buffer with "\r\n" does compared
# with the same text read from disk.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root audit compiler-service probes lib.tcl]
cs::load $root
set dir [file tempdir]

proc utf16len {s} {
    set n 0
    foreach ch [split $s ""] {
        incr n [expr {[scan $ch %c] > 0xFFFF ? 2 : 1}]
    }
    return $n
}

proc write {path text {translation lf}} {
    set ch [open $path w]
    fconfigure $ch -encoding utf-8 -translation $translation
    puts -nonewline $ch $text
    close $ch
}

# Each case: a label and a prefix written before `target` on line 2.
set cases [list \
    ascii      {x = "ab" ; } \
    bmp        "x = \"éé\" ; " \
    astral     "x = \"\U0001F600\" ; " \
    combining  "x = \"é\" ; " \
]
puts [format "%-10s %-8s %-8s %-10s %-10s %-10s" case compiler offset utf8-byte utf16-unit scalar]
foreach {label prefix} $cases {
    # A comment with the same text on line 1 too: offsets must count it.
    set line1 "# [string range $prefix 4 end]\n"
    # `target` is referenced inside a list after the prefix's string.
    set line2 "target = 1\n"
    set line3 "y = \[[string range $prefix 4 end-3], target\]\n"
    set text "$line1$line2$line3"
    set path [file join $dir $label.bot]
    write $path $text
    set r [cs::analyze $path]
    # Find the `target` reference on line 3 by structure, not by column.
    set hir [dict get $r hir]
    set found ""
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && [dict get $node name] eq "target"} { set found $e }
    }
    set o [lrange [hir::get $hir $found origin] 2 end]
    set before [string range $line3 0 [expr {[string first target $line3] - 1}]]
    puts [format "%-10s %-8s %-8s %-10s %-10s %-10s" $label "col [dict get $o column]" \
        [dict get $o start] \
        "col [expr {[string length [encoding convertto utf-8 $before]] + 1}]" \
        "col [expr {[utf16len $before] + 1}]" "col [expr {[string length $before] + 1}]"]
}

# CRLF on disk: core::ReadFile translates line endings, so offsets count one
# character per line ending.
set crlf [file join $dir crlf.bot]
write $crlf "target = 1\ny = \[target\]\ny\n" crlf
proc targetRef {r} {
    set hir [dict get $r hir]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && [dict get $node name] eq "target"} {
            set o [lrange [dict get $node origin] 2 end]
            return "line [dict get $o line] column [dict get $o column] offset [dict get $o start]"
        }
    }
}
set r [cs::analyze $crlf]
puts "crlf on disk : status [dict get $r status], `target` at [targetRef $r]"
# The same text as an in-memory buffer (an editor's), with its \r\n intact.
set r [cs::analyze $crlf -text "target = 1\r\ny = \[target\]\r\ny\r\n"]
puts "crlf buffer  : status [dict get $r status], `target` at [targetRef $r]"
# A lone CR line ending: Tcl's input translation (auto) reads it as a newline
# from disk; the lexer, given the raw text, rejects it.
set cr [file join $dir cr.bot]
write $cr "target = 1\ry = \[target\]\ry\r" binary
set r [cs::analyze $cr]
puts "lone CR disk : status [dict get $r status], `target` at [targetRef $r]"
set r [cs::analyze $cr -text "target = 1\ry = \[target\]\ry\r"]
puts "lone CR buf  : status [dict get $r status]"
foreach d [dict get $r diagnostics] { puts "   [dict get $d line]:[dict get $d column] [dict get $d message]" }

# A non-ASCII identifier.
set r [cs::analyze [file join $dir ident.bot] -text "café = 1\ncafé\n"]
puts "non-ASCII identifier: status [dict get $r status]"
foreach d [dict get $r diagnostics] { puts "   [dict get $d line]:[dict get $d column] [dict get $d message]" }
file delete -force $dir
