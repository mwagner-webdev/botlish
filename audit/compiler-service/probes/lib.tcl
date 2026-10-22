# lib.tcl -- the census's probe library (COMPILER-SERVICE-CENSUS.md).
#
# Experimental, audit-only code. It is NOT a compiler service: it is the
# smallest amount of glue needed to ask the existing front end the questions
# the census asks (diagnostics as data, a position query, an in-memory source
# overlay), so the answers are measured rather than presumed. Nothing in the
# compiler calls it, and it changes no compiler procedure permanently: the
# overlay below wraps two procedures only for the duration of one analysis
# and restores them.
#
#   source audit/compiler-service/probes/lib.tcl
#   cs::load ROOT                       load core, hir, surface, the Tcl compiler
#   cs::analyze PATH ?-text T? ?-overlay {PATH TEXT ...}? ?-target T?
#       => {status ok|syntax|loader|semantic hir H ast A diagnostics {D ...}
#           files {FILEID PATH ...} texts {PATH TEXT ...}}
#   cs::query RESULT PATH LINE COLUMN   the semantic facts at a position
#   cs::offsetOf TEXT LINE COLUMN       compiler offset of a 1-based line/column
#
# A structured diagnostic D is {severity S code C message M file F line L
# column C endLine L2 endColumn C2} -- located from the HIR origin when the
# compiler gave one, else parsed back out of the message text (a loader
# diagnostic: COMPILER-SERVICE-CENSUS.md records that as a gap).

namespace eval cs {
    variable root ""
    variable overlay [dict create]
}

proc cs::load {root} {
    set ::cs::root $root
    uplevel #0 [list source [file join $root compiler compiler.tcl]]
    uplevel #0 [list source [file join $root surface surface.tcl]]
    if {[info commands ::compilerpedia::topicForDiagnostic] eq ""} {
        uplevel #0 [list source [file join $root compilerpedia compilerpedia.tcl]]
    }
    InstallOverlayHooks
}

# --- source overlay ---------------------------------------------------------
#
# The loader reads module text with core::ReadFile and asks the filesystem
# whether a candidate module exists with `file exists`/`file isfile`
# (surface/modules.tcl). An overlay maps normalized paths to text; a path
# mapped to "\x00DELETED" is a deleted file.
#
# The two wrappers are installed once, by cs::load, and pass through while
# no overlay is in force. They are never renamed per analysis: renaming a
# command Tcl compiles inline (`file` is a compiled ensemble) invalidates
# every compiled procedure in the interpreter, and the next build would pay
# for recompiling the compiler (measured: about 35 ms on a one-line program,
# COMPILER-SERVICE-CENSUS.md, "Performance results").

proc cs::Normal {path} { return [file normalize $path] }

proc cs::InstallOverlayHooks {} {
    if {[info commands ::cs::RealReadFile] ne ""} {
        return
    }
    rename ::core::ReadFile ::cs::RealReadFile
    proc ::core::ReadFile {path} {
        if {[dict size $::cs::overlay]} {
            set n [::cs::Normal $path]
            if {[dict exists $::cs::overlay $n]} {
                set text [dict get $::cs::overlay $n]
                if {$text eq "\x00DELETED"} {
                    error "couldn't open \"$path\": no such file or directory" "" {POSIX ENOENT}
                }
                return $text
            }
        }
        return [::cs::RealReadFile $path]
    }
    rename ::file ::cs::RealFile
    proc ::file {sub args} {
        if {[dict size $::cs::overlay] && $sub in {exists isfile} && [llength $args] == 1} {
            set n [::cs::Normal [lindex $args 0]]
            if {[dict exists $::cs::overlay $n]} {
                return [expr {[dict get $::cs::overlay $n] ne "\x00DELETED"}]
            }
        }
        return [uplevel 1 [list ::cs::RealFile $sub {*}$args]]
    }
}

proc cs::withOverlay {overlay script} {
    set saved $::cs::overlay
    set normal [dict create]
    dict for {path text} $overlay {
        dict set normal [Normal $path] $text
    }
    set ::cs::overlay $normal
    try {
        return [uplevel 1 $script]
    } finally {
        set ::cs::overlay $saved
    }
}

# --- analysis ---------------------------------------------------------------

# Splits "FILE:LINE:COLUMN: MESSAGE" (how the loader and the strict
# boundaries locate a diagnostic in its text) into a location dict.
proc cs::LocatedText {message} {
    if {[regexp {^(.*?):([0-9]+):([0-9]+): (.*)$} $message -> file line column rest]} {
        return [dict create file $file line $line column $column endLine $line endColumn $column message $rest located text]
    }
    return [dict create file "" line 0 column 0 endLine 0 endColumn 0 message $message located none]
}

proc cs::OriginFields {hir origin} {
    if {[lindex $origin 0] ne "file"} {
        return [dict create file "" line 0 column 0 endLine 0 endColumn 0 located none]
    }
    set f [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
    set o [lrange $origin 2 end]
    return [dict create file $f line [dict get $o line] column [dict get $o column] \
        endLine [dict get $o endLine] endColumn [dict get $o endColumn] \
        start [dict get $o start] end [dict get $o end] located origin]
}

# Analyzes the program file PATH (its text: -text, else the overlay's, else
# the file's) leniently: the strict boundaries are not raised, so a program
# with semantic errors still has a HIR. Syntax errors (no HIR is built past
# a recovered parse's diagnostics) and loader errors (raised, with no HIR)
# are reported as such.
proc cs::analyze {path args} {
    set options [dict create -text "" -overlay {} -target "" -warnings default]
    foreach {k v} $args { dict set options $k $v }
    set overlay [dict get $options -overlay]
    if {[dict get $options -text] ne ""} {
        dict set overlay $path [dict get $options -text]
    }
    return [cs::withOverlay $overlay [list cs::Analyze $path $options]]
}

proc cs::Analyze {path options} {
    set text [core::ReadFile $path]
    set result [dict create status ok hir "" ast "" diagnostics {} files {} texts [dict create $path $text]]
    set ast [surface::parse $text $path -recover 1]
    dict set result ast $ast
    if {[dict get $ast diagnostics] ne ""} {
        dict set result status syntax
        foreach d [dict get $ast diagnostics] {
            dict lappend result diagnostics [dict create severity error code {SURFACE SYNTAX} \
                message [dict get $d message] file [dict get $d file] line [dict get $d line] \
                column [dict get $d column] endLine [dict getdef $d endLine [dict get $d line]] \
                endColumn [dict getdef $d endColumn [dict get $d column]] located syntax]
        }
        return $result
    }
    set target [hir::cabi::ResolveTarget [dict get $options -target]]
    set root [file dirname [file normalize $path]]
    set ::surface::modules::reads [dict create]
    if {[catch {
        set hir [surface::modules::BuildProgram $ast 0 $target $root]
        set hir [surface::lower::Finish $hir 0 [dict get $options -warnings] ""]
    } message opts]} {
        dict set result status loader
        set entries [dict getdef $opts -diagnostics [list [dict create errorcode [dict get $opts -errorcode] message $message]]]
        foreach entry $entries {
            set code [dict get $entry errorcode]
            if {[lrange $code 0 1] eq {SURFACE SYNTAX} && [llength $code] == 3} {
                # A module file's syntax error (the loader parses modules
                # without recovery): the error code carries the diagnostic.
                set d [lindex $code 2]
                set loc [dict create file [dict get $d file] line [dict get $d line] \
                    column [dict get $d column] endLine [dict get $d line] \
                    endColumn [dict get $d column] message [dict get $d message] located syntax]
                set code {SURFACE SYNTAX}
            } else {
                set loc [LocatedText [dict get $entry message]]
                set code [lrange $code 0 2]
            }
            dict lappend result diagnostics [dict merge $loc [dict create severity error code $code]]
        }
        dict set result errorinfo [dict get $opts -errorinfo]
        return $result
    }
    dict set result hir $hir
    dict set result files [dict get $hir files]
    dict for {path text} $::surface::modules::reads {
        dict set result texts $path $text
    }
    foreach d [hir::recovery::reported $hir] {
        set origin [if {[dict exists $d origin]} {dict get $d origin} else {hir::get $hir [dict get $d expr] origin}]
        dict lappend result diagnostics [dict merge [OriginFields $hir $origin] [dict create \
            severity error code [list CORE SEMANTIC [dict get $d kind]] message [dict get $d message] \
            expr [dict getdef $d expr ""]]]
    }
    if {[dict get $result diagnostics] ne ""} {
        dict set result status semantic
    }
    foreach w [dict getdef $hir warnings {}] {
        set primary [dict get $w primary]
        dict lappend result diagnostics [dict merge [OriginFields $hir $primary] [dict create \
            severity warning code [dict get $w code] message [dict get $w message]]]
    }
    return $result
}

# --- positions --------------------------------------------------------------

# The compiler's offset of 1-based LINE and COLUMN in TEXT: the lexer counts
# both in Tcl characters (Unicode scalar values) after newline translation.
proc cs::offsetOf {text line column} {
    set offset 0
    for {set l 1} {$l < $line} {incr l} {
        set nl [string first \n $text $offset]
        if {$nl < 0} { return -1 }
        set offset [expr {$nl + 1}]
    }
    return [expr {$offset + $column - 1}]
}

# The FileId of PATH in HIR, or "".
proc cs::FileIdOf {hir path} {
    set n [file normalize $path]
    dict for {f entry} [dict get $hir files] {
        if {[file normalize [dict get $entry path]] eq $n} { return $f }
    }
    return ""
}

# The innermost expression of HIR whose source origin in file F contains
# OFFSET (start <= OFFSET < end; an empty node at OFFSET too), or "".
proc cs::exprAt {hir f offset} {
    set best ""
    set bestWidth ""
    dict for {e node} [dict get $hir exprs] {
        set origin [dict get $node origin]
        if {[lindex $origin 0] ne "file" || [lindex $origin 1] ne $f} continue
        set o [lrange $origin 2 end]
        set s [dict get $o start]
        set x [dict get $o end]
        if {$offset < $s || $offset > $x || ($offset == $x && $x > $s)} continue
        set width [expr {$x - $s}]
        if {$best eq "" || $width < $bestWidth} {
            set best $e
            set bestWidth $width
        }
    }
    return $best
}

# Every ref expression of HIR resolved to binding B.
proc cs::refsTo {hir b} {
    set result {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && [dict getdef $node binding ""] eq $b} {
            lappend result $e
        }
    }
    return $result
}

# The facts at LINE:COLUMN of PATH in an analysis RESULT (cs::analyze).
proc cs::query {result path line column} {
    set facts [dict create status [dict get $result status]]
    set text [dict get $result texts $path]
    set offset [offsetOf $text $line $column]
    dict set facts offset $offset
    # Diagnostics are available whatever the status.
    set here {}
    foreach d [dict get $result diagnostics] {
        if {[file normalize [dict get $d file]] ne [file normalize $path]} continue
        # Inside the diagnostic's range (a point diagnostic: its line, from
        # its column on).
        set before [expr {$line < [dict get $d line] || ($line == [dict get $d line] && $column < [dict get $d column])}]
        set after [expr {$line > [dict get $d endLine] || ($line == [dict get $d endLine] && $column > [dict get $d endColumn]
            && [dict get $d endColumn] > [dict get $d column])}]
        if {$before || $after} continue
        lappend here $d
    }
    dict set facts diagnostics $here
    dict set facts topics [lsort -unique [lmap d $here {
        # The same lookup main.tcl's help lines make: the code and the text.
        set t [compilerpedia::topicForDiagnostic [dict get $d code] [dict get $d message]]
        if {$t eq ""} continue
        set t
    }]]
    set hir [dict get $result hir]
    if {$hir eq ""} {
        # Syntax: the recovered AST is all there is.
        return $facts
    }
    set f [FileIdOf $hir $path]
    set e [exprAt $hir $f $offset]
    if {$e eq ""} {
        return $facts
    }
    set node [hir::node $hir $e]
    dict set facts expr $e
    dict set facts kind [dict get $node kind]
    dict set facts node [dict get [lrange [dict get $node origin] 2 end] node]
    dict set facts type [hir::types::show [hir::typeOf $hir $e]]
    if {[dict get $node kind] in {ref bind}} {
        set b [dict getdef $node binding ""]
        dict set facts name [dict getdef $node name ""]
        dict set facts binding $b
        if {$b ne ""} {
            set binding [hir::binding $hir $b]
            dict set facts bindingKind [dict get $binding kind]
            dict set facts sourceName [hir::semantic::SourceName $hir $b]
            dict set facts definition [OriginFields $hir [dict get $binding origin]]
            dict set facts references [lmap r [refsTo $hir $b] {
                OriginFields $hir [hir::get $hir $r origin]
            }]
        }
    }
    return $facts
}
