# census-b.tcl -- partition B of the warning candidate's repository census
# (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, section 11; partition-b.md here),
# end to end: the Botlish programs embedded in the Tcl test files and the
# fuzzers' generated programs, run through the measuring instrument
# (../tools/escape-candidates.tcl) and classified.
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/census-b.tcl \
#       ?-out DIR? ?-n N? ?-seed S? ?-keep 0|1?
#
# Writes DIR/partition-b.tsv and DIR/partition-b-units.tsv (default DIR:
# this directory) and prints every stage's summary. Stages, each tool in a
# process of its own, one after another (no backend runs anywhere):
#
#   1. extract-tests.tcl on every test file where contexts meet C pointers,
#      native views or edits, extern C functions or direct modules: a file of
#      tests/*.test or tests/platform/* holding `context struct` or `context
#      trait` and one of `ffi::c::Ptr`, `FnPtr`, `NativeView`, `NativeEdit`,
#      `extern c fn`, `direct module`, plus tests/contexts.test,
#      context-traits.test, direct-modules.test, c-ffi.test, c-abi-types.test,
#      native-view.test, native-edit.test, c-pointer-borrowing.test,
#      windows-io.test and darwin-io.test. darwin-io.test and windows-io.test
#      run twice, the second time with -platform (their host-only tests'
#      programs, compiled for the host they are written for);
#      tests/platform/aot-facts.tcl, a script, through -aot-facts;
#   2. extract-fuzz.tcl on the six fuzzers (N programs each, seed S;
#      default 30 and 1);
#   3. coverage-b.tcl on every test file (WORK/cov-STEM.txt);
#   4. scan-b.tcl over the test captures (WORK/raw-t.tsv) and over the
#      fuzzers' (WORK/raw-f.tsv);
#   5. classify-b.tcl.
#
# WORK is a private `file tempdir` directory, removed at the end unless
# -keep 1 (then its path is printed).

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]
set options [dict create -out $here -n 30 -seed 1 -keep 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set out [file normalize [dict get $options -out]]
set tclsh [info nameofexecutable]

proc ReadText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc Run {args} {
    set start [clock milliseconds]
    if {[catch {exec $::tclsh {*}$args 2>@1} output]} {
        puts "FAILED: $args\n$output"
        exit 1
    }
    puts "  ([format %.0f [expr {([clock milliseconds] - $start) / 1000.0}]] s) [lrange $args 0 end]"
    return $output
}

# The test files.
set named {contexts context-traits direct-modules c-ffi c-abi-types native-view native-edit
    c-pointer-borrowing windows-io darwin-io}
set files [lmap n $named {file join $root tests $n.test}]
foreach path [lsort [concat [glob -directory [file join $root tests] *.test] \
        [glob -nocomplain -directory [file join $root tests platform] *]]] {
    if {![file isfile $path]} continue
    set text [ReadText $path]
    if {[regexp {context struct|context trait} $text]
            && [regexp {ffi::c::Ptr|FnPtr|NativeView|NativeEdit|extern c fn|direct module} $text]
            && $path ni $files} {
        lappend files $path
    }
}
set fuzzers {direct-modules c-ffi c-abi-types context-traits native-view native-edit}

set work [file tempdir botlish-census-b-]
file mkdir [file join $work t] [file join $work f]
puts "== 1. capture ([llength $files] files)"
foreach path $files {
    set stem [file rootname [file tail $path]]
    if {[file extension $path] ne ".test"} {
        if {$stem ne "aot-facts"} { error "$path: not a tcltest file, no extraction for it" }
        file mkdir [file join $work t $stem]
        Run [file join $here extract-tests.tcl] -out [file join $work t $stem] -aot-facts $path
        continue
    }
    file mkdir [file join $work t $stem]
    Run [file join $here extract-tests.tcl] -out [file join $work t $stem] $path
    set platform [dict getdef {darwin-io {macos Darwin:arm64} windows-io {windows {Windows NT:amd64}}} $stem {}]
    if {$platform ne {}} {
        lassign $platform name spec
        file mkdir [file join $work t $stem@$name]
        Run [file join $here extract-tests.tcl] -out [file join $work t $stem@$name] -platform $spec $path
    }
}
puts "== 2. fuzzers"
foreach fuzzer $fuzzers {
    file mkdir [file join $work f $fuzzer]
    Run [file join $here extract-fuzz.tcl] -out [file join $work f $fuzzer] -n [dict get $options -n] \
        -seed [dict get $options -seed] [file join $root audit $fuzzer tools fuzz.tcl]
}
puts "== 3. coverage"
foreach path $files {
    if {[file extension $path] ne ".test"} continue
    set stem [file rootname [file tail $path]]
    set dirs [glob -directory [file join $work t] -type d $stem $stem@*]
    set report [Run [file join $here coverage-b.tcl] $path {*}[lsort $dirs]]
    set f [open [file join $work cov-$stem.txt] w]
    puts $f $report
    close $f
    puts "    $stem: [lindex [split [string trim $report] \n] end]"
}
puts "== 4. scan"
file mkdir [file join $work lib-t] [file join $work lib-f]
foreach {kind lib} {t lib-t f lib-f} {
    set dirs [lsort [glob -directory [file join $work $kind] -type d *]]
    set raw [Run [file join $here scan-b.tcl] -work [file join $work $lib] {*}$dirs]
    set f [open [file join $work raw-$kind.tsv] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $raw
    close $f
}
puts "== 5. classify"
puts [Run [file join $here classify-b.tcl] -work $work -out $out]
if {[dict get $options -keep]} {
    puts "kept: $work"
} else {
    file delete -force $work
}
