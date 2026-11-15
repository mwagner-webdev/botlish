# bench.tcl -- the front-end costs of STDLIB-ENCODE-UTF8-RESULT-TYPE-
# STABILITY-MILESTONE-1.md, section N, for one checkout.
#
#   tclsh9.0 audit/encode-utf8-type-stability/tools/bench.tcl ?-root DIR? ?-runs N?
#
# Compiles each program below with the compiler of checkout DIR (default:
# this one), in one process, N times after one warm-up (default 7), and
# prints a Markdown table: the fastest and the median front-end time, the
# modules the compilation loaded, the source types it declared, the static
# types it interned, the size of its HIR interchange text, the semantic
# instances its analysis made, and the time of a front-end cache miss
# (compile and store) and of a hit (read back) in a fresh cache directory.
# The programs are generated into a temporary directory (the synthetic ones)
# or read from this checkout (the examples), so two runs compare one input.
set here [file dirname [file normalize [info script]]]
set repo [file dirname [file dirname [file dirname $here]]]
set root $repo
set runs 7
foreach {option value} $argv {
    switch -- $option {
        -root { set root [file normalize $value] }
        -runs { set runs $value }
        default { puts stderr "usage: bench.tcl ?-root DIR? ?-runs N?"; exit 2 }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set dir [file tempdir botlish-eut-bench]

proc Write {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The synthetic programs: NAME -> entry file.
set programs [dict create]
Write [file join $dir str-call main.bot] "import std::str\n\n\"héllo\".encode_utf8()\n"
dict set programs str-call [file join $dir str-call main.bot]
Write [file join $dir str-nocall main.bot] "import std::str\n\nstd::str::length(\"héllo\")\n"
dict set programs str-nocall [file join $dir str-nocall main.bot]
Write [file join $dir str-byte main.bot] "import std::str\nimport std::byte\n\n\"héllo\".encode_utf8()\n"
dict set programs str-byte [file join $dir str-byte main.bot]
# 20 application modules, each importing std::str and the previous one.
set previous ""
for {set i 1} {$i <= 20} {incr i} {
    set text "import std::str\n"
    if {$previous ne ""} {
        append text "import $previous\n"
    }
    append text "\nfn bytes(s: str):\n    s.encode_utf8()\n"
    if {$previous ne ""} {
        append text "\nfn chain(s: str):\n    \[bytes(s), $previous\::bytes(s)\]\n"
    }
    Write [file join $dir modules m$i.bot] $text
    set previous m$i
}
Write [file join $dir modules main.bot] "import m20\n\nm20::chain(\"ab\")\n"
dict set programs modules-20 [file join $dir modules main.bot]
# 10 untyped helpers, each called with six argument types: 60 instances.
set text "import std::str\nimport std::list\n\n"
for {set i 1} {$i <= 10} {incr i} {
    append text "fn h$i\(s, x):\n    \[std::list::length(s.encode_utf8()), x\]\n\n"
}
set calls {}
foreach arg {1 {"t"} true {[1]} 1.5 {'c'}} {
    for {set i 1} {$i <= 10} {incr i} {
        lappend calls "h$i\(\"ab\", $arg)"
    }
}
append text "\[[join $calls {, }]\]\n"
Write [file join $dir instances main.bot] $text
dict set programs instances-60 [file join $dir instances main.bot]
dict set programs csv_records [file join $repo examples stdlib csv_records.bot]
dict set programs dfa-json [file join $repo examples dfa json json.bot]

proc Median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

proc Ms {microseconds} {
    return [format %.1f [expr {$microseconds / 1000.0}]]
}

puts "Compiler: $root ($runs runs after a warm-up)\n"
puts "| program | fastest ms | median ms | modules | source types | interned types | interchange bytes | instances | cache miss ms | cache hit ms |"
puts "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
dict for {name path} $programs {
    set hir [surface::readProgramFile $path -warnings off -cache ""]
    set times {}
    for {set i 0} {$i < $runs} {incr i} {
        set t0 [clock microseconds]
        set hir [surface::readProgramFile $path -warnings off -cache ""]
        lappend times [expr {[clock microseconds] - $t0}]
    }
    set modules [dict size [dict getdef $hir modules {}]]
    set types [llength [dict get $hir sourceTypes]]
    set interned [dict size [dict get $hir types]]
    set bytes [string length [encoding convertto utf-8 [hir::interchange::encode $hir]]]
    set instances [dict size [dict getdef $hir semantic instances {}]]
    set cache [file join $dir cache-$name]
    set t0 [clock microseconds]
    surface::readProgramFile $path -warnings off -cache $cache
    set miss [expr {[clock microseconds] - $t0}]
    set t0 [clock microseconds]
    surface::readProgramFile $path -warnings off -cache $cache
    set hit [expr {[clock microseconds] - $t0}]
    puts "| $name | [Ms [lindex [lsort -integer $times] 0]] | [Ms [Median $times]] | $modules | $types | $interned | $bytes | $instances | [Ms $miss] | [Ms $hit] |"
}
file delete -force $dir
