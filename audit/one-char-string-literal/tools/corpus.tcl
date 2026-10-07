# corpus.tcl -- observational audit of ONE-CHAR-STRING-LITERAL over the corpus
# (WARNINGS-ONE-CHAR-STRING-LITERAL.md, "Corpus findings and the API-
# deficiency catalog"). Compiles every program of examples/stdlib,
# examples/surface, examples/refinement, bench/*.bot and lib/*.bot with
# warnings on (collected, not emitted) and reports, at the commit it runs on:
#
#   * every distinct finding (a library module's finding once, with every
#     corpus program that loaded the module), with its value, its source line,
#     its enclosing function and its CONSUMER -- what the literal's value flows
#     into, read from the HIR by this tool (the warning itself never looks):
#     the other operand of `==` and its static type, the callee and argument
#     position of a call (and the parameter's declared type), the list a list
#     element builds and what that list's binding is passed to;
#   * an independent false-positive check: the source token at each finding's
#     anchor, lexed by the lexer's own String procedure, must be a String
#     literal whose value is the warning's and is exactly one character
#     (str::length); a finding that is not is a FALSE POSITIVE;
#   * the spelling law's corpus level, per finding: the literal rewritten to
#     its character spelling in a scratch copy (the corpus is never edited),
#     clauses 1 and 2 on a probe (the spelling lexes; its exact value is the
#     UnicodeChar of the same code point; a UnicodeChar parameter takes it),
#     and the rewritten program -- for a module, every corpus program that
#     loads it -- compiled and evaluated against the original: rejected
#     statically, failing at run time, a changed value, or the same value;
#   * the classification of every finding:
#       convert-now      the rewrite keeps every probe's value AND the
#                        consumer accepts the character type statically (the
#                        other operand of `==` is a UnicodeChar, a parameter
#                        declares UnicodeChar): a rewrite that merely compiles
#                        proves nothing, because `==` of a String and a
#                        UnicodeChar type-checks and is false, and a native's
#                        str parameter is checked only at run time;
#       API-deficiency   the consumer takes a String: catalogued per distinct
#                        consumer (the table the future API/autofix work
#                        starts from);
#       deliberate       a String by the author's judgment (the HAND table
#                        below, with its reason);
#     a finding no rule classifies is printed UNCLASSIFIED and makes the tool
#     exit non-zero.
#
#   tclsh9.0 audit/one-char-string-literal/tools/corpus.tcl ?-root DIR?
#
# -root audits another checkout (e.g. a worktree of a later commit) with this
# checkout's tools. Every program the audit evaluates -- the originals and
# each rewrite -- runs in a child process (this script with -evaluate LIBDIR
# PATH) under a time limit: a rewrite can remove a loop's only exit (a
# comparison with a String that can no longer be true), and such a program is
# recorded as `diverges`.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set auditRoot $root
set evaluate ""
set timeLimit 60
while {$argv ne ""} {
    set argv [lassign $argv option]
    switch -- $option {
        -root { set argv [lassign $argv value]; set auditRoot [file normalize $value] }
        -evaluate { set argv [lassign $argv libraryDir evaluate] }
        default { error "unknown option $option" }
    }
}
source [file join $auditRoot surface surface.tcl]
source [file join $auditRoot native native.tcl]

# The child: compile PATH (warnings off) with LIBDIR as the library directory
# and print its outcome: `rejected KIND`, `value TEXT` (on the reference
# interpreter, or natively when the interpreter cannot run it -- a bench
# workload deeper than its stack), or `runtime KIND`.
if {$evaluate ne ""} {
    set ::core::libraryDir $libraryDir
    if {[catch {surface::readProgramFile $evaluate -warnings off -warning-channel ""} hir options]} {
        puts [list rejected [lindex [dict get $options -errorcode] end]]
    } elseif {![catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v]} {
        puts [list value $v]
    } elseif {[catch {native::evalHir $hir} v options]} {
        puts [list runtime [lindex [dict get $options -errorcode] end]]
    } else {
        puts [list value [core::formatValue $v]]
    }
    exit 0
}

set programs [concat \
    [lsort [glob -directory [file join $auditRoot examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples surface] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples refinement] *.bot]] \
    [lsort [glob -directory [file join $auditRoot bench] *.bot]] \
    [lsort [glob -directory [file join $auditRoot lib] *.bot]]]

# The surface examples that are deliberate rejections (their own headers say
# so): expected not to compile.
set deliberateRejections {examples/surface/09-mutual-recursion.bot examples/surface/10-duplicate-binding.bot}

# HAND classification: deliberate String usage, per {FILE FUNCTION}: the
# one-character literals there are Strings by the author's judgment, with the
# reason. Every other finding is classified by the rules above.
set deliberate {
    {examples/stdlib/string_replace.bot sample} {test data of a substring replacement: needles and replacements of 0, 1, 2 and 3 characters ("x", "aa", "abc", "") in one call list -- a one-character needle or replacement is the length-1 case of a String argument}
    {examples/stdlib/string_reverse.bot sample} {test inputs of a String reversal of 0, 1, 3, 4 and 3 non-ASCII characters -- "a" is the length-1 boundary case of a String argument}
    {examples/stdlib/ai_text_clean.bot clean_char} {replacement texts: clean_char maps a character to "" (a removed emoji), "..." (an ellipsis) or a one-character normalization -- results of 0, 1 and 3 characters, so its result is a String of variable length; the comparisons beside them are catalogued separately}
}
# The comparisons in clean_char are not deliberate: only its returned
# replacement texts are (the classification below skips its `==` consumers).

# API-deficiency catalog rows: CONSUMER-PATTERN -> {ROW WHAT}: a finding's
# consumer key (consumerKey below) is matched against each glob pattern in
# order; ROW names the catalog row, WHAT says which API would let the literal
# be a character.
set apiRows {
    {== str-substring:*} {"== against a one-character String sliced by a peek/char_at helper (str::substring)"
        "the helper returns a one-character String (or \"\" past the end); str::char_at returns a UnicodeChar but fails outside the String, where the helper returns \"\""}
    {== str-param:*} {"== against a str parameter or a String-typed binding"
        "the parameter is declared or inferred str: its callers pass one-character Strings sliced from text"}
    {== any-param:*} {"== against an untyped parameter that receives one-character Strings"
        "the callers pass str::substring slices (peek, a first-character slice); the comparison would hold for a UnicodeChar only if the callers changed too"}
    {call str::concat:*} {"str::concat argument"
        "str::concat takes two Strings: there is no append of a UnicodeChar to a String"}
    {list-element immutable_set::from_list:*} {"element of a List[str] made an ImmutableSet[str], queried with one-character Strings"
        "the set is queried (immutable_set::contains) with one-character String slices; a set of UnicodeChars needs the scanner to read characters (str::char_at)"}
    {list-element bind:*hex_digits} {"element of a List[str] table indexed (list::at) and concatenated (str::concat)"
        "the digits are appended to output text with str::concat: no append of a UnicodeChar"}
}

proc readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

proc writeText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
}

proc rel {path} {
    return [string map [list $::auditRoot/ {}] $path]
}

proc compilePath {path mode} {
    return [surface::readProgramFile $path -warnings $mode -warning-channel ""]
}

proc pathOf {hir origin} {
    return [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
}

proc stringSpelling {text} {
    return "\"[string map [list \\ \\\\ \" \\\" \n \\n \t \\t \r \\r] $text]\""
}

proc charSpelling {ch} {
    return "'[string map [list \\ \\\\ ' \\' \n \\n \t \\t \r \\r] $ch]'"
}

# The outcome of the program PATH with LIBDIR as its library directory, in a
# child process under the time limit: {rejected KIND}, {value TEXT},
# {runtime KIND} or {diverges}.
proc evaluate {libraryDir path} {
    if {[catch {exec timeout $::timeLimit [info nameofexecutable] [info script] -root $::auditRoot \
            -evaluate $libraryDir $path 2>@1} out options]} {
        if {[lindex [dict get $options -errorcode] 0] eq "CHILDSTATUS" && [lindex [dict get $options -errorcode] 2] == 124} {
            return diverges
        }
        return [list runtime [string range $out 0 80]]
    }
    return [lindex [split [string trim $out] \n] end]
}

# The value of a probe program, compiled in process (only the character
# probes use this: they are tiny and terminate).
proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v options]} {
        return [list error [dict get $options -errorcode]]
    }
    return [list value $v]
}

# ExprId -> parent ExprId, for HIR.
proc parents {hir} {
    set parent [dict create]
    dict for {e node} [dict get $hir exprs] {
        foreach c [hir::children $hir $e] {
            dict set parent $c $e
        }
    }
    return $parent
}

# The name of the function whose body holds E ("top" outside any), the
# written spelling.
proc enclosingFunction {hir parent e} {
    while {[dict exists $parent $e]} {
        set e [dict get $parent $e]
        if {[dict get $hir exprs $e kind] eq "block"} {
            dict for {b node} [dict get $hir exprs] {
                if {[dict get $node kind] eq "bind" && [dict get $node value] eq $e} {
                    return [hir::warnings::WrittenName $hir [dict get $node binding]]
                }
            }
            return "<function>"
        }
    }
    return top
}

# A short description of expression E as a consumer's operand: its kind and,
# for a call, its callee; for a reference, whether it reads a parameter.
proc operand {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        ref {
            set b [dict get $node binding]
            if {$b ne "" && [dict get $hir bindings $b kind] eq "param"} {
                return "param:[dict get $node name]"
            }
            if {$b ne "" && [dict get $hir bindings $b kind] eq "local"} {
                set d [dict get $hir bindings $b declaredBy]
                if {$d eq "" || ![dict exists $hir exprs $d] || [dict get $hir exprs $d kind] ne "bind"} {
                    return "ref:[dict get $node name]"
                }
                set init [dict get $hir exprs [dict get $hir exprs $d value]]
                if {[dict get $init kind] eq "call"} {
                    return "bind-of-call:[CalleeName $hir $init]"
                }
            }
            return "ref:[dict get $node name]"
        }
        call {
            return "call:[CalleeName $hir $node]"
        }
    }
    return [dict get $node kind]
}

proc CalleeName {hir node} {
    set callee [dict get $hir exprs [dict get $node callee]]
    return [expr {[dict get $callee kind] eq "ref" ? [dict get $callee name] : [dict get $callee kind]}]
}

# 1 if the user function the call NODE calls returns a str::substring slice
# (its body's last expression is one): a peek/char_at helper.
proc SlicingHelper {hir node} {
    set target [dict get $node target]
    if {[lindex $target 0] ne "block"} {
        return 0
    }
    set body [dict get $hir exprs [lindex $target 1] body]
    set last [dict get $hir exprs [lindex $body end]]
    return [expr {[dict get $last kind] eq "call" && [CalleeName $hir $last] eq "str::substring"}]
}

# The consumer of the literal at SITE: {KEY TYPE DETAIL}, KEY the catalog
# key, TYPE the static type its value meets ("" when none applies).
proc consumerOf {hir parent site} {
    set p [dict get $parent $site]
    set pnode [dict get $hir exprs $p]
    switch -- [dict get $pnode kind] {
        call {
            set name [CalleeName $hir $pnode]
            if {$name eq "=="} {
                set other [lindex [lmap a [dict get $pnode args] {if {$a eq $site} continue; set a}] 0]
                set type [hir::types::show [hir::typeOf $hir $other]]
                set onode [dict get $hir exprs $other]
                set shape [operand $hir $other]
                if {[dict get $onode kind] eq "call" && [SlicingHelper $hir $onode]} {
                    return [list "== str-substring:[CalleeName $hir $onode]()" $type $shape]
                }
                if {[dict get $onode kind] eq "ref" && [string match bind-of-call:* $shape]} {
                    set init [dict get $hir exprs [dict get $hir exprs [dict get $hir bindings [dict get $onode binding] declaredBy] value]]
                    if {[CalleeName $hir $init] eq "str::substring" || [SlicingHelper $hir $init]} {
                        return [list "== str-substring:[dict get $onode name]" $type $shape]
                    }
                }
                if {$type eq "str" || [string match "str*" $type]} {
                    return [list "== str-param:$shape" $type $shape]
                }
                return [list "== any-param:$shape" $type $shape]
            }
            if {$name eq "list"} {
                # A list element: what the list is.
                set q [dict get $parent $p]
                set qnode [dict get $hir exprs $q]
                switch -- [dict get $qnode kind] {
                    call { return [list "list-element [CalleeName $hir $qnode]:arg[lsearch [dict get $qnode args] $p]" [hir::types::show [hir::typeOf $hir $p]] ""] }
                    bind { return [list "list-element bind:[dict get $qnode name]" [hir::types::show [hir::typeOf $hir $p]] ""] }
                }
                return [list "list-element [dict get $qnode kind]" [hir::types::show [hir::typeOf $hir $p]] ""]
            }
            set index [lsearch [dict get $pnode args] $site]
            set type ""
            set target [dict get $pnode target]
            if {[lindex $target 0] eq "native"} {
                set native [dict get $hir symbols [lindex $target 1] name]
                set types [dict get [core::native::metadata $native] paramTypes]
                set type [lindex $types $index]
            } elseif {[lindex $target 0] eq "block"} {
                set block [dict get $hir exprs [lindex $target 1]]
                set declared [expr {[dict exists $block declaredParamTypes] ? [lindex [dict get $block declaredParamTypes] $index] : ""}]
                set type [expr {$declared eq "" ? "untyped" : [hir::types::show $declared]}]
            }
            return [list "call $name:arg$index" $type ""]
        }
        return {
            return [list "return" [hir::types::show [hir::typeOf $hir $p]] ""]
        }
    }
    return [list [dict get $pnode kind] "" ""]
}

# ---------------------------------------------------------------------------
# The audit

set commit [string trim [exec git -C $auditRoot rev-parse HEAD]]
set dirty [string trim [exec git -C $auditRoot status --porcelain -- examples bench lib]]
puts "# ONE-CHAR-STRING-LITERAL corpus audit: tclsh9.0 audit/one-char-string-literal/tools/corpus.tcl"
puts "# commit $commit (corpus paths [expr {$dirty eq "" ? "clean" : "MODIFIED: $dirty"}])"
puts ""

set findings [dict create]     ;# relative primary location -> record
set failed {}
set compiled 0
set values [dict create]       ;# program -> its value
set loads [dict create]        ;# relative file -> programs that compiled it
foreach path $programs {
    if {[catch {compilePath $path default} hir options]} {
        lappend failed [list [rel $path] [dict get $options -errorcode]]
        continue
    }
    incr compiled
    dict for {f file} [dict get $hir files] {
        dict lappend loads [rel [dict get $file path]] $path
    }
    set parent ""
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "ONE-CHAR-STRING-LITERAL"} continue
        set where [rel [hir::originLocation $hir [dict get $w primary]]]
        if {[dict exists $findings $where]} continue
        if {$parent eq ""} {
            set parent [parents $hir]
        }
        set site [dict get $w data site]
        set origin [dict get $w primary]
        set fields [lrange $origin 2 end]
        set file [rel [pathOf $hir $origin]]
        set text [core::value::strOf [dict get $w data value]]
        # The independent check: the token at the anchor, lexed afresh.
        set lines [split [readText [pathOf $hir $origin]] \n]
        set line [lindex $lines [expr {[dict get $fields line] - 1}]]
        set diagnostics {}
        set token [surface::lexer::String $line [expr {[dict get $fields column] - 1}] f 1 0 diagnostics]
        set genuine [expr {[string index $line [expr {[dict get $fields column] - 1}]] eq "\""
            && $diagnostics eq "" && [dict get $token value] eq $text && [string length $text] == 1}]
        lassign [consumerOf $hir $parent $site] key type detail
        dict set findings $where [dict create file $file line [dict get $fields line] col [dict get $fields column] \
            text $text spelling [dict get $token text] source [string trim $line] function [enclosingFunction $hir $parent $site] \
            consumer $key type $type detail $detail genuine $genuine]
    }
}

puts "compiled $compiled of [llength $programs] programs"
foreach f $failed {
    lassign $f path code
    puts "  not compiled: $path ($code)[expr {$path in $deliberateRejections ? " -- a deliberate rejection" : ""}]"
}
puts ""

# The spelling law at corpus level, per finding: clauses 1-2 on a probe, the
# rewritten program(s) against the original(s).
set scratch [file tempdir one-char-string-literal-corpus]
set libraryDir $::core::libraryDir
set characters [dict create]
proc characterClauses {ch} {
    if {[dict exists $::characters $ch]} {
        return [dict get $::characters $ch]
    }
    set spelling [charSpelling $ch]
    set problem ""
    if {[catch {surface::compile "x = $spelling\nx" probe.bot -warnings off} probe]} {
        set problem "does not lex or parse: $probe"
    } else {
        set consts [lmap {e node} [dict get $probe exprs] {if {[dict get $node kind] ne "const"} continue; set e}]
        set fact [hir::exact::Of $probe [lindex $consts 0]]
        if {$fact ne [list val [list UnicodeChar [scan $ch %c]]]} {
            set problem "exact value $fact"
        } elseif {[catch {surface::compile "import char\nfn code(c: UnicodeChar) -> int:\n    char::scalar_value(c)\ncode($spelling)" probe.bot -warnings off} typed]
                || [valueOf $typed] ne [list value [scan $ch %c]]} {
            set problem "a UnicodeChar parameter does not take it"
        }
    }
    dict set ::characters $ch $problem
    return $problem
}

set originals [dict create]
proc originalValue {path} {
    if {![dict exists $::originals $path]} {
        dict set ::originals $path [evaluate $::libraryDir $path]
    }
    return [dict get $::originals $path]
}

# The rewrite's outcome against the original's: rejected KIND, runtime KIND,
# diverges, changed or same.
proc compare {before after} {
    switch -- [lindex $after 0] {
        rejected - runtime { return [list [lindex $after 0] [lindex $after 1]] }
        diverges { return [list diverges ""] }
    }
    return [list [expr {$after eq $before ? "same" : "changed"}] ""]
}

set lawFailures 0
dict for {where f} $findings {
    set text [dict get $f text]
    set clause [characterClauses $text]
    if {$clause ne ""} {
        incr lawFailures
    }
    # The rewritten file, in a scratch copy: a library module in a copy of
    # the library directory, an entry program next to nothing it needs.
    set file [dict get $f file]
    set dir [file join $scratch [incr ::n]]
    file mkdir $dir
    set lines [split [readText [file join $auditRoot $file]] \n]
    set index [expr {[dict get $f line] - 1}]
    set from [expr {[dict get $f col] - 1}]
    set to [expr {$from + [string length [dict get $f spelling]] - 1}]
    lset lines $index [string replace [lindex $lines $index] $from $to [charSpelling $text]]
    set outcomes {}
    if {[string match lib/* $file]} {
        exec cp -r $libraryDir/. $dir
        writeText [file join $dir [string range $file 4 end]] [join $lines \n]
        set ::core::libraryDir $dir
        set probes [lmap p [dict get $loads $file] {if {[rel $p] eq $file} continue; set p}]
        if {$probes eq ""} {
            set probes [dict get $loads $file]
        }
        set ::core::libraryDir $libraryDir
        foreach probe $probes {
            set target [expr {[rel $probe] eq $file ? [file join $dir [string range $file 4 end]] : $probe}]
            lappend outcomes [list [rel $probe] {*}[compare [originalValue $probe] [evaluate $dir $target]]]
        }
    } else {
        set target [file join $dir [file tail $file]]
        writeText $target [join $lines \n]
        lappend outcomes [list $file {*}[compare [originalValue [file join $auditRoot $file]] [evaluate $libraryDir $target]]]
    }
    file delete -force $dir
    dict set findings $where clause $clause
    dict set findings $where outcomes $outcomes
}
file delete -force $scratch

# Classification.
set classes [dict create convert-now {} API-deficiency {} deliberate {} UNCLASSIFIED {}]
set rows [dict create]
set falsePositives 0
dict for {where f} $findings {
    if {![dict get $f genuine]} {
        incr falsePositives
    }
    set kinds [lsort -unique [lmap o [dict get $f outcomes] {lindex $o 1}]]
    set deliberateKey [list [dict get $f file] [dict get $f function]]
    set class ""
    if {[dict exists $deliberate $deliberateKey]
            && !([dict get $f function] eq "clean_char" && [string match "==*" [dict get $f consumer]])} {
        set class deliberate
        set why [dict get $deliberate $deliberateKey]
    } elseif {$kinds eq "same" && [dict get $f type] eq "UnicodeChar"} {
        set class convert-now
        set why "the consumer takes a UnicodeChar and the rewrite keeps every probe's value"
    } else {
        foreach {pattern row} $apiRows {
            if {[string match $pattern [dict get $f consumer]]} {
                set class API-deficiency
                set why [lindex $row 0]
                dict lappend rows [lindex $row 0] $where
                break
            }
        }
    }
    if {$class eq ""} {
        set class UNCLASSIFIED
        set why "no rule or table entry"
    }
    dict lappend classes $class $where
    dict set findings $where class $class
    dict set findings $where why $why
}

set total [dict size $findings]
puts "## Findings: $total distinct (a library module's finding once)"
foreach class {convert-now API-deficiency deliberate UNCLASSIFIED} {
    puts [format "%-16s %3d" $class [llength [dict get $classes $class]]]
}
puts "false positives (the token at the anchor is not a one-character String literal of the warned value): $falsePositives"
puts "spelling law clauses 1-2 (the character spelling lexes, is the UnicodeChar of the same code point, and a UnicodeChar parameter takes it): [expr {$total - $lawFailures}] of $total hold, over [dict size $characters] distinct characters"
puts ""
set byFile [dict create]
dict for {where f} $findings {
    dict incr byFile [dict get $f file]
}
puts "## Findings per file"
dict for {file n} $byFile {
    puts [format "%4d  %s" $n $file]
}
puts ""

# Rewrite outcomes per class.
puts "## The rewrite, per finding class (outcome over every probe: rejected KIND / runtime KIND / diverges / changed / same)"
foreach class {convert-now API-deficiency deliberate} {
    set tally [dict create]
    foreach where [dict get $classes $class] {
        foreach o [dict get $findings $where outcomes] {
            dict incr tally [string trim [join [lrange $o 1 2] " "]]
        }
    }
    puts "$class: [join [lmap {k v} $tally {string cat $k " " $v}] {, }]"
}
puts ""

puts "## API-deficiency catalog (one row per distinct consumer)"
foreach {pattern row} $apiRows {
    lassign $row name what
    if {![dict exists $rows $name]} continue
    set sites [dict get $rows $name]
    set callees [lsort -unique [lmap w $sites {dict get $findings $w consumer}]]
    set files [lsort -unique [lmap w $sites {dict get $findings $w file}]]
    set outcomes [dict create]
    foreach w $sites {
        foreach o [dict get $findings $w outcomes] {
            dict incr outcomes [string trim [join [lrange $o 1 2] " "]]
        }
    }
    puts "* $name -- [llength $sites] findings"
    puts "    consumers: [join $callees {; }]"
    puts "    files: [join $files {, }]"
    puts "    rewrite: [join [lmap {k v} $outcomes {string cat $k " " $v}] {, }]"
    puts "    lacks: $what"
}
puts ""

puts "## Deliberate String usage"
foreach where [dict get $classes deliberate] {
    puts "  $where [stringSpelling [dict get $findings $where text]] ([dict get $findings $where function]): [dict get $findings $where why]"
}
puts ""

if {[dict get $classes convert-now] ne ""} {
    puts "## Convert-now"
    foreach where [dict get $classes convert-now] {
        puts "  $where [stringSpelling [dict get $findings $where text]] -> [charSpelling [dict get $findings $where text]]"
    }
    puts ""
}

puts "## Every finding: location, value, function, consumer (static type), rewrite outcome(s), class"
dict for {where f} $findings {
    set outs [join [lmap o [dict get $f outcomes] {string trim [join [lrange $o 1 2] " "]}] ", "]
    puts "$where [stringSpelling [dict get $f text]] [dict get $f function] | [dict get $f consumer] ([expr {[dict get $f type] eq "" ? "-" : [dict get $f type]}]) | $outs | [dict get $f class][expr {[dict get $f clause] eq "" ? "" : " | SPELLING LAW: [dict get $f clause]"}]"
}
foreach where [dict get $classes UNCLASSIFIED] {
    puts "UNCLASSIFIED: $where ([dict get $findings $where consumer])"
}
exit [expr {[dict get $classes UNCLASSIFIED] ne "" || $falsePositives > 0 || $lawFailures > 0}]
