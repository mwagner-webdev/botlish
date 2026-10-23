# extract-tests.tcl -- the Botlish programs a Tcl test file compiles, captured
# as files, for partition B of the warning candidate's repository census
# (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, section 11; partition-b.md here).
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/extract-tests.tcl \
#       -out DIR ?-platform OS:MACHINE? TESTFILE
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/extract-tests.tcl \
#       -out DIR -aot-facts tests/platform/aot-facts.tcl
#
# DIR is an existing, private, empty directory (mktemp -d); the caller removes
# it. Run one test file per process.
#
# A test file's programs are built by its own helpers (`app`, `bcfApp`,
# `writeModules`, `makeFile`, `withPrivateLibrary`, string maps of templates,
# loops ...), so they are captured where they enter the front end rather
# than read out of the file's text: the file is sourced with
#
#   * tcltest's `test` replaced by one that runs every test's -setup, -body
#     and -cleanup (each caught), whatever its constraints -- a test
#     constrained off on this host still embeds its programs -- and
#     `cleanupTests` by a no-op;
#   * execution traces on surface::compile and surface::readProgramFile (the
#     front end's two source entry points; the outermost call only): each call
#     is recorded with its options, and the program it compiled is copied into
#     DIR/programs/N/ -- program text as main.bot (or the name it was given);
#     a program file with every file the compilation loaded from its
#     application directory (the HIR's `files`), or, when the compilation
#     failed, the application directory's .bot files; and, when the test runs
#     under withPrivateLibrary, the files of the private standard library that
#     differ from stdlib/ under lib/ (the scanner rebuilds the library from
#     stdlib/ and them);
#   * the backends stubbed, so that a body goes on to the programs it builds
#     after a run: the engines (core::evalProgram, the Tcl compiler's run
#     entry points, native::evalHir) raise a run-time error, {CORE SEMANTIC
#     STUB}, which outcomeUnderHir and the files' own outcome helpers catch
#     like any run-time error; native::executable, native::nir and the other
#     native entry points, and the executable runners, return a dummy value.
#     No program runs, no native code is generated;
#   * `exec` refused inside a test (it runs the file's top level -- fixture
#     builds -- unchanged); a refused `exec` of main.tcl with a .bot argument
#     is recorded as a `subprocess` capture of that program's directory.
#
# The real front end runs, so that a body continues past its compilations
# and so that each capture carries the test's own outcome: ok, `diagnostics
# K: KINDS` (a -strict 0 compilation with diagnostics), or `error KIND`.
# Bodies may still stop early (a dummy value where a real one was needed):
# DIR/tests.tsv records each test's status and capture count.
#
# Output:
#
#   DIR/captures.tsv  N  TEST  CONSTRAINTS  KIND  ENTRY  OPTIONS  LIBRARY
#                     OUTCOME  SOURCE
#     KIND text, file, subprocess or repo (a program file of the repository
#     itself, partition A's: not copied); ENTRY the entry file in
#     DIR/programs/N (the repository path for repo); LIBRARY 1 when a private
#     library overlay was captured; SOURCE the path the test compiled.
#   DIR/tests.tsv     TEST  CONSTRAINTS  STATUS  CAPTURES  MILLISECONDS
#   DIR/counters.tsv  NAME  VALUE: the file's integer globals named
#                     *Counter at the end (::appCounter: application
#                     directories built), for coverage
#
# -platform OS:MACHINE sets ::tcl_platform(os) and (machine) before the file
# is sourced (Darwin:arm64, "Windows NT:amd64"), so that the host target
# (core::cabi::hostTarget), the default target of a compilation without
# -target, is the one the file's host-only tests are written for: what
# darwin-io.test and windows-io.test compile on macOS and Windows. Only the
# front end runs, so nothing but the target depends on it (AGENTS.md sets
# ::tcl_platform(machine) the same way for the AArch64 transport under
# qemu-user).
#
# -aot-facts reads tests/platform/aot-facts.tcl, a script (not a tcltest
# file) that builds executables: its programs are program text in braced
# `set NAME {...}` literals and three strings built in cCalls; they are
# extracted from the script's text, never by running it.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]

set options [dict create -out "" -aot-facts "" -platform ""]
set file ""
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {[dict exists $options $a]} {
        dict set options $a [lindex $argv [incr i]]
    } else {
        set file $a
    }
}
set out [file normalize [dict get $options -out]]
if {$out eq "" || ![file isdirectory $out]} {
    error "-out DIR: an existing directory"
}
file mkdir [file join $out programs] [file join $out tmp]

namespace eval extract {
    variable out $::out
    variable root $::root
    variable test "(top level)"
    variable constraints ""
    variable n 0
    variable depth 0
    variable inTests 0
    variable captures 0
    variable realLib [file join $::root stdlib]
}

proc extract::Append {name fields} {
    variable out
    set f [open [file join $out $name] a]
    fconfigure $f -encoding utf-8 -translation lf
    puts $f [join [lmap x $fields {string map {\t { } \n { }} $x}] \t]
    close $f
}

proc extract::Write {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

proc extract::Read {path} {
    set f [open $path r]
    fconfigure $f -translation binary
    set data [read $f]
    close $f
    return $data
}

# 1 if PATH is DIR or below it.
proc extract::Under {path dir} {
    return [expr {$path eq $dir || [string first $dir/ $path] == 0}]
}

# Copies into TO/lib the files of the private library DIR that are not
# stdlib/'s own (new or changed); 1 if there were any.
proc extract::Overlay {dir to} {
    variable realLib
    set any 0
    set queue [list $dir]
    while {$queue ne {}} {
        set queue [lassign $queue d]
        foreach entry [glob -nocomplain -directory $d *] {
            if {[file isdirectory $entry]} {
                lappend queue $entry
                continue
            }
            set rel [string range $entry [string length $dir/] end]
            set real [file join $realLib $rel]
            if {[file exists $real] && [file size $real] == [file size $entry]
                    && [Read $real] eq [Read $entry]} continue
            file mkdir [file dirname [file join $to lib $rel]]
            file copy -force $entry [file join $to lib $rel]
            set any 1
        }
    }
    return $any
}

# The .bot files below DIR (relative paths).
proc extract::BotFiles {dir {recursive 1}} {
    set result {}
    set queue [list $dir]
    while {$queue ne {}} {
        set queue [lassign $queue d]
        foreach entry [glob -nocomplain -directory $d *] {
            if {[file isdirectory $entry]} {
                if {$recursive} { lappend queue $entry }
            } elseif {[file extension $entry] eq ".bot"} {
                lappend result [string range $entry [string length $dir/] end]
            }
        }
    }
    return $result
}

proc extract::Outcome {code result} {
    if {$code != 0} {
        return "error [lindex $::errorCode end]"
    }
    if {[catch {hir::diagnostics $result} ds] || $ds eq {}} {
        return ok
    }
    set kinds [lsort -unique [lmap d $ds {dict get $d kind}]]
    return "diagnostics [llength $ds]: [join $kinds ,]"
}

proc extract::Library {to} {
    variable realLib
    if {[file normalize $::core::libraryDir] eq $realLib} {
        return 0
    }
    return [Overlay [file normalize $::core::libraryDir] $to]
}

proc extract::Enter {command op} {
    variable depth
    incr depth
}

proc extract::LeaveText {command code result op} {
    variable depth
    variable n
    variable out
    variable test
    variable constraints
    variable captures
    incr depth -1
    if {$depth > 0} return
    set rest [lrange $command 2 end]
    set name main.bot
    if {[llength $rest] % 2} {
        set rest [lassign $rest filename]
        if {[file extension $filename] eq ".bot" && [file tail $filename] eq $filename} {
            set name $filename
        }
    }
    set id [incr n]
    set dir [file join $out programs $id]
    Write [file join $dir $name] [lindex $command 1]
    set library [Library $dir]
    incr captures
    Append captures.tsv [list $id $test $constraints text programs/$id/$name $rest $library [Outcome $code $result] <text>]
}

proc extract::LeaveFile {command code result op} {
    variable depth
    variable n
    variable out
    variable test
    variable constraints
    variable captures
    variable root
    incr depth -1
    if {$depth > 0} return
    set path [file normalize [lindex $command 1]]
    set rest [lrange $command 2 end]
    set id [incr n]
    incr captures
    if {[Under $path $root] && ![Under $path $out]} {
        Append captures.tsv [list $id $test $constraints repo [string range $path [string length $root/] end] $rest 0 [Outcome $code $result] $path]
        return
    }
    set dir [file join $out programs $id]
    set app [file dirname $path]
    set copied {}
    if {$code == 0 && ![catch {dict get $result files} files]} {
        dict for {f entry} $files {
            set p [file normalize [dict get $entry path]]
            if {[Under $p $app]} {
                lappend copied [string range $p [string length $app/] end]
            }
        }
    } elseif {$app eq [file join $out tmp]} {
        # A program file written into tcltest's temporary directory itself
        # (makeFile): its sibling .bot files, not the application directories
        # beside it.
        set copied [BotFiles $app 0]
    } else {
        set copied [BotFiles $app]
    }
    set tail [file tail $path]
    if {$tail ni $copied && [file exists $path]} {
        lappend copied $tail
    }
    foreach rel [lsort -unique $copied] {
        file mkdir [file dirname [file join $dir $rel]]
        file copy -force [file join $app $rel] [file join $dir $rel]
    }
    set library [Library $dir]
    Append captures.tsv [list $id $test $constraints file programs/$id/$tail $rest $library [Outcome $code $result] $path]
}

proc extract::Traces {} {
    foreach {command leave} {::surface::compile LeaveText ::surface::readProgramFile LeaveFile} {
        if {[info commands $command] eq ""} continue
        set have [trace info execution $command]
        if {[lsearch -exact $have [list enter ::extract::Enter]] < 0} {
            trace add execution $command enter ::extract::Enter
        }
        if {[lsearch -exact $have [list leave ::extract::$leave]] < 0} {
            trace add execution $command leave ::extract::$leave
        }
    }
}

# The backends, stubbed, never a run: an engine (the interpreter, the Tcl
# compiler, the native driver) raises a run-time error {CORE SEMANTIC
# STUB}, which the test helpers that run programs (outcomeUnderHir, the
# files' own *Outcome procs) catch and report as an outcome like any other,
# so that a body goes on; the other native entry points and the executable
# runners return a dummy value.
set extract::stubs {
    ::runStandalone {return ""}
    ::runBare {return ""}
    ::runExecutable {return [list "" ""]}
    ::native::evalHir {return -code error -errorcode {CORE SEMANTIC STUB} "backend stubbed by extract-tests.tcl"}
    ::native::executable {return [file join $::extract::out tmp stub-executable]}
    ::native::executableFile {return [file join $::extract::out tmp stub-executable]}
    ::native::nir {return ""}
    ::native::lowered {return ""}
    ::native::clif {return ""}
    ::native::vcode {return ""}
    ::native::roots {return ""}
    ::native::measure {return ""}
    ::native::allocationReport {return ""}
    ::native::structCensus {return ""}
    ::native::transportCensus {return ""}
    ::native::assertAllocations {return ""}
    ::native::assertAllocationsAtMost {return ""}
    ::native::assertBytesAtMost {return ""}
    ::native::assertKindAllocations {return ""}
    ::native::codeSize {return 0}
    ::native::object {return ""}
    ::native::report {return ""}
    ::native::Driver {return ""}
    ::core::evalProgram {return -code error -errorcode {CORE SEMANTIC STUB} "backend stubbed by extract-tests.tcl"}
    ::core::compiler::runSequence {return -code error -errorcode {CORE SEMANTIC STUB} "backend stubbed by extract-tests.tcl"}
    ::core::compiler::runProgram {return -code error -errorcode {CORE SEMANTIC STUB} "backend stubbed by extract-tests.tcl"}
    ::core::compiler::compileUnit {return ""}
    ::core::compiler::compileHir {return ""}
    ::core::compiler::runUnit {return -code error -errorcode {CORE SEMANTIC STUB} "backend stubbed by extract-tests.tcl"}
    ::core::compiler::evalHir {return -code error -errorcode {CORE SEMANTIC STUB} "backend stubbed by extract-tests.tcl"}
    ::core::compiler::evalUnit {return -code error -errorcode {CORE SEMANTIC STUB} "backend stubbed by extract-tests.tcl"}
    ::core::compiler::generatedCode {return ""}
}

proc extract::Stubs {} {
    variable stubs
    foreach {command body} $stubs {
        if {[info commands $command] eq ""} continue
        if {[info args $command] eq "args" && [info body $command] eq $body} continue
        proc $command args $body
    }
}

proc extract::Ensure {} {
    Traces
    Stubs
}

# exec: unchanged at the top level (fixture builds), refused inside a test.
rename ::exec ::extract::RealExec
proc ::exec args {
    if {!$::extract::inTests} {
        return [uplevel 1 [list ::extract::RealExec {*}$args]]
    }
    if {[lsearch -glob $args *main.tcl] >= 0} {
        foreach a $args {
            if {[file extension $a] eq ".bot" && [file exists $a]} {
                set path [file normalize $a]
                set id [incr ::extract::n]
                incr ::extract::captures
                set dir [file join $::extract::out programs $id]
                set app [file dirname $path]
                foreach rel [::extract::BotFiles $app] {
                    file mkdir [file dirname [file join $dir $rel]]
                    file copy -force [file join $app $rel] [file join $dir $rel]
                }
                ::extract::Append captures.tsv [list $id $::extract::test $::extract::constraints subprocess \
                    programs/$id/[file tail $path] [lrange $args 1 end] 0 "not compiled (main.tcl subprocess)" $path]
            }
        }
    }
    error "exec refused by extract-tests.tcl"
}

proc extract::AotFacts {path} {
    variable out
    variable n
    set text [Read $path]
    set programs {}
    # Braced program literals at the top level.
    foreach name {program coroutineProgram downProgram coroutineOverflowProgram benchProgram errorProgram} {
        set start [string first "\nset $name \x7b" $text]
        if {$start < 0} {
            error "aot-facts: no program $name"
        }
        incr start
        set end [expr {[string first \x7b $text $start] + 1}]
        while {![info complete [string range $text $start $end]] || [string index $text $end] ne "\x7d"} {
            incr end
        }
        set value [lindex [string range $text $start $end] 2]
        lappend programs $name [string map {DEPTH 100000} $value]
    }
    # cCalls: decls, the call program, the missing library, the undefined
    # symbol (windowsCCalls builds the same texts).
    if {![regexp {\n    set decls ("[^\n]*")\n} $text -> declsWord]} {
        error "aot-facts: no decls"
    }
    set decls [subst -nocommands -novariables [string range $declsWord 1 end-1]]
    lappend programs c-call "$decls\n\[labs(-42), widen(-1, 65535, 7)\]\n"
    lappend programs missing "import std::ffi::c\n\nextern c library \"botlish_aot_facts_missing\"\n\n1 + 1\n"
    lappend programs undefined "$decls\nextern c fn nope named \"botlish_aot_facts_nope\"(x: std::ffi::c::Int) -> std::ffi::c::Int\n\nnope(1)\n"
    foreach {name value} $programs {
        set id [incr n]
        Write [file join $out programs $id main.bot] $value
        Append captures.tsv [list $id aot-facts:$name "" text programs/$id/main.bot {} 0 "not compiled (extracted)" <text>]
    }
}

if {[dict get $options -aot-facts] ne ""} {
    extract::AotFacts [file normalize [dict get $options -aot-facts]]
    exit 0
}

package require tcltest 2.5
tcltest::configure -tmpdir [file join $out tmp] -verbose {}

proc ::tcltest::cleanupTests args {}

proc ::tcltest::test {name description args} {
    set options [dict create -constraints "" -setup "" -body "" -cleanup ""]
    if {[string match -* [lindex $args 0]]} {
        foreach {key value} $args { dict set options $key $value }
    } elseif {[llength $args] == 3} {
        dict set options -constraints [lindex $args 0]
        dict set options -body [lindex $args 1]
    } else {
        dict set options -body [lindex $args 0]
    }
    set ::extract::test $name
    set ::extract::constraints [dict get $options -constraints]
    set ::extract::inTests 1
    set ::extract::captures 0
    ::extract::Ensure
    set start [clock milliseconds]
    set status ok
    foreach part {-setup -body -cleanup} {
        if {[catch {uplevel 1 [dict get $options $part]} message]} {
            if {$status eq "ok"} {
                set status "$part: [lindex [split $message \n] 0]"
            }
        }
        ::extract::Ensure
    }
    ::extract::Append tests.tsv [list $name [dict get $options -constraints] $status \
        $::extract::captures [expr {[clock milliseconds] - $start}]]
    set ::extract::test "(top level)"
    set ::extract::constraints ""
    set ::extract::inTests 0
    return
}

# Traces and stubs again after every `source`: the test file sources the
# compiler, the front end and the native driver itself, which redefines them.
proc extract::AfterSource {command code result op} {
    catch {Ensure}
}
trace add execution source leave ::extract::AfterSource

if {[dict get $options -platform] ne ""} {
    lassign [split [dict get $options -platform] :] os machine
    set ::tcl_platform(os) $os
    set ::tcl_platform(machine) $machine
}
set argv {}
set argc 0
info script [file normalize $file]
source [file normalize $file]
# The application counters of the file's own helpers (::appCounter and the
# like): how many application directories the bodies built, for coverage.
foreach v [lsort [info globals *Counter]] {
    if {[string is integer -strict [set ::$v]]} {
        extract::Append counters.tsv [list $v [set ::$v]]
    }
}
exit 0
