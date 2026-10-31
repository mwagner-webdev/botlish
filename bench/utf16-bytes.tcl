# utf16-bytes.tcl -- what UTF-16 conversion and Windows path operations cost,
# operation by operation (UTF16-BYTE-STORAGE-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/utf16-bytes.tcl ?-root DIR | -baseline-rev REV? ?-runs N?
#       ?-scale F? ?-lengths LIST? ?-alphabets LIST? ?-groups LIST?
#
# Every row is a program that runs one operation in a loop of N iterations,
# timed as bench/filesystem.tcl times its rows: best of RUNS runs inside one
# process (no compilation, link or process start in a row), per iteration,
# minus the same program (its setup included) with an empty loop. Inputs
# are texts of LENGTH characters (-lengths, default 8 40 256 4096) of an
# alphabet (-alphabets):
#
#   ascii   "abcdefgh..." (one UTF-16 unit per character)
#   mixed   a, é, 中, 😀, b, ü, x, 𝄞 repeated: two of every eight characters
#           astral (a surrogate pair each), so LENGTH * 5/4 units
#
# A path of LENGTH characters is "C:\" and 7-character components joined by
# "\". Groups (-groups, default every one this host can run):
#
#   codec    std::abi::bytes::encode_utf16le and decode_utf16le alone (and
#            decode_utf8 of the same text's UTF-8, the existing primitive, as
#            the reference): any host
#   windows  std::windows::path and std::windows::fs's pure operations --
#            validate + native, from_text, text, display (of a valid name, and
#            lossy: the name and an unpaired surrogate), units, kind, concat
#            (a path of LENGTH joined with "component.txt"), join (the native
#            paths of the same) -- and the temporary Win32 buffer (a path's
#            units, or bytes, and the two-byte NUL) built two ways: from a
#            List[int] of units by milestone 7's formulation (one byte at a
#            time, then std::abi::bytes::from_list) and from UTF-16LE Bytes by
#            this milestone's (std::abi::bytes::join of the bytes and a NUL).
#            None of them calls Windows. Two rows time the path syntax
#            alone, on List[int] units computed before the loop: `kind_of`
#            of the path and `joinable?` of "component.txt" under it --
#            std::windows::fs's private functions, copied verbatim from the
#            measured tree's stdlib/windows/fs.bot into the program (this
#            milestone did not change them), so syntax and conversion are
#            told apart. The programs call no C (none holds a foreign
#            declaration: refused otherwise), so the driver's `bench` runs
#            their NIR without its link plan, like the codec group's: on
#            Windows as compiled; on Linux compiled for windows-x86_64 and run
#            with the host's target line (a local experiment: the module's
#            own code on a Linux CPU, under the Linux calling convention).
#            Elsewhere the group is skipped.
#
# -root DIR measures another checkout's compiler and standard library (the
# tree before a change: a git worktree), with this checkout's driver unless
# DIR has its own build (BOTLISH_NATIVE_BIN overrides both): the driver runs
# any older program, its operations being a superset. A row whose operation
# DIR does not have (the codec before this milestone) prints "n/a".
# -baseline-rev REV measures REV (in a temporary worktree,
# bench/baseline-tree.tcl) and then this tree, on the same machine, and ends
# with a table of both and their ratio (how CI compares: the tier item
# utf16-bench).

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
set options [dict create -root $root -runs 5 -scale 1.0 -lengths {8 40 256 4096} \
    -alphabets {ascii mixed} -groups "" -baseline-rev ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
if {[dict get $options -baseline-rev] ne ""} {
    source [file join $here baseline-tree.tcl]
    set args [baselineTree::childArgs $options]
    set tree [baselineTree::add $root [dict get $options -baseline-rev]]
    try {
        set before [baselineTree::run [info script] -root $tree {*}$args]
        set after [baselineTree::run [info script] {*}$args]
    } finally {
        baselineTree::remove $root $tree
    }
    # The rows of a run's table: KEY (group, operation, chars, alphabet) ->
    # its ns per operation.
    proc rowsOf {text} {
        set rows [dict create]
        foreach line [split $text \n] {
            set fields [lmap f [lrange [split $line |] 1 end-1] {string trim $f}]
            if {[llength $fields] == 5 && [lindex $fields 0] in {codec windows}} {
                dict set rows [lrange $fields 0 3] [lindex $fields 4]
            }
        }
        return $rows
    }
    set b [rowsOf $before]
    set a [rowsOf $after]
    puts "\nbefore: [dict get $options -baseline-rev]; after: this tree"
    puts "| group   | operation                          | chars | alpha | before ns    | after ns     | after/before |"
    puts "|---------|------------------------------------|------:|-------|-------------:|-------------:|-------------:|"
    dict for {key value} $a {
        lassign $key group operation chars alphabet
        set was [dict getdef $b $key n/a]
        puts [format "| %-7s | %-34s | %5s | %-5s | %12s | %12s | %12s |" $group $operation $chars $alphabet \
            $was $value [baselineTree::ratio $was $value]]
    }
    exit 0
}
set treeRoot [file normalize [dict get $options -root]]
if {![info exists ::env(BOTLISH_NATIVE_BIN)]
        && ![file exists [file join $treeRoot native target release botlish-native]]
        && ![file exists [file join $treeRoot native target release botlish-native.exe]]} {
    set own [file join $root native target release botlish-native]
    if {$::tcl_platform(platform) eq "windows"} { append own .exe }
    set ::env(BOTLISH_NATIVE_BIN) $own
}
source [file join $treeRoot surface surface.tcl]
source [file join $treeRoot native native.tcl]

set runs [dict get $options -runs]
set scale [dict get $options -scale]
set host [core::cabi::hostTarget]
set hasCodec [expr {![catch {core::native::metadata std::byte_store::encode_utf16le}]}]
set groups [dict get $options -groups]
if {$groups eq ""} {
    set groups {codec windows}
}
switch -glob -- $host {
    windows-* { set windowsMode native }
    linux-* { set windowsMode swap }
    default { set windowsMode "" }
}
set scratch [file tempdir botlish-utf16-bench-]

proc literal {text} {
    return "\"[string map {\\ \\\\ \" \\\"} $text]\""
}

# A text of LENGTH characters of ALPHABET.
proc textOf {length alphabet} {
    set cycle [expr {$alphabet eq "ascii" ? {a b c d e f g h} : {a é 中 😀 b ü x 𝄞}}]
    set out ""
    for {set i 0} {$i < $length} {incr i} {
        append out [lindex $cycle [expr {$i % 8}]]
    }
    return $out
}

# A path of LENGTH characters (at least 4): "C:\" and 7-character
# components of ALPHABET joined by "\".
proc pathOf {length alphabet} {
    set out "C:\\"
    set component [textOf 7 $alphabet]
    while {[string length $out] < $length} {
        if {[string index $out end] ne "\\"} {
            append out "\\"
        }
        append out [string range $component 0 [expr {$length - [string length $out] - 1}]]
    }
    if {[string index $out end] eq "\\"} {
        set out [string range $out 0 end-1]x
    }
    return $out
}

# The UTF-16 code units of TEXT.
proc unitsOf {text} {
    set units {}
    foreach c [split $text ""] {
        scan $c %c s
        if {$s < 65536} {
            lappend units $s
        } else {
            set v [expr {$s - 65536}]
            lappend units [expr {55296 + ($v >> 10)}] [expr {56320 + ($v & 1023)}]
        }
    }
    return $units
}

set prelude "import std::abi
import std::abi::bytes
import std::io::path
import std::list
import std::byte
import std::str
import type std::byte::Byte
"
set windowsImports "import std::windows::fs
import std::windows::path
"
# Milestone 7's Win32 buffer, verbatim (stdlib/windows/fs.bot's `wide`
# before this milestone): UNITS' little-endian bytes and a two-byte NUL.
set helpers "
fn unit_at(us: List\[int\], i: int) -> int:
    us.at(i):
        on IndexNotFound:
            0

fn low_byte(u: int) -> Byte:
    u.mod(256)

fn high_byte(u: int) -> Byte:
    u.shift_right(8).mod(256)

fn wide_of_units(units: List\[int\]) -> std::abi::bytes::Bytes:
    bytes = loop i from 0 to 2 * units.length() + 2:
        u = units.unit_at(i.shift_right(1))
        if i.mod(2) == 0:
            u.low_byte()
        else:
            u.high_byte()
    std::abi::bytes::from_list(bytes)
"
# std::windows::fs's private path-syntax functions, verbatim from the
# measured tree (and PathKind): each `private fn NAME(` block to the next
# line that is neither indented nor blank, without `private`.
proc syntaxHelpers {} {
    set lines [split [core::ReadFile [file join $::treeRoot stdlib windows fs.bot]] \n]
    set out {}
    foreach name {separator? kind_of segments rewritten? holds_slash? verbatim_name? win32_name? joinable? ends_separated?} {
        set start [lsearch -glob $lines "private fn $name\\(*"]
        if {$start < 0} {
            error "no private fn $name in the measured tree's std::windows::fs"
        }
        set block [list [string range [lindex $lines $start] [string length "private "] end]]
        foreach line [lrange $lines [expr {$start + 1}] end] {
            if {$line ne "" && ![string match " *" $line]} break
            lappend block $line
        }
        lappend out [string trimright [join $block \n]]
    }
    set start [lsearch -exact $lines "enum PathKind:"]
    set enum {}
    foreach line [lrange $lines $start end] {
        if {$line eq ""} break
        lappend enum $line
    }
    return "\n[join $enum \n]\n\n[join $out \n\n]\n"
}

set codecHelpers "
fn wide_of_bytes(data: std::abi::bytes::Bytes) -> std::abi::bytes::Bytes:
    std::abi::bytes::join(\[data, std::abi::bytes::from_list(\[std::byte::from_int(0), std::byte::from_int(0)\])\])
"

# The program: SETUP (indented four spaces), then a loop of N iterations of
# BODY, its value discarded.
proc program {windows setup body n} {
    set imports $::prelude
    set extra $::helpers
    if {$windows} {
        append imports $::windowsImports
        append extra [syntaxHelpers]
    }
    if {$::hasCodec} {
        append extra $::codecHelpers
    }
    set errors "std::io::path::NotAPath, std::io::path::NotText, InvalidUtf8"
    if {$::hasCodec} {
        append errors ", InvalidUtf16"
    }
    set inner [expr {$body eq "" ? "0" : "$body\n        0"}]
    return "$imports$extra
fn f() -> int errors $errors:
$setup
    xs = loop i from 0 to $n:
        $inner
    std::list::length(xs)

f():
    on std::io::path::NotAPath:
        -2
    on std::io::path::NotText:
        -3
    on InvalidUtf8:
        -4
[expr {$::hasCodec ? "    on InvalidUtf16:\n        -5\n" : ""}]"
}

# The host's NIR target line (compiled for the host).
proc hostTargetLine {} {
    set hir [build "0\n" $::host]
    set nir [native::nir $hir]
    return [lsearch -inline [split $nir \n] {target *}]
}

proc build {text target} {
    set dir [file join $::scratch p[incr ::programs]]
    file mkdir $dir
    set f [open [file join $dir main.bot] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    return [surface::readProgramFile [file join $dir main.bot] -warnings off -cache "" -target $target]
}
set programs 0

# The best time (microseconds) of one run of program TEXT; WINDOWS: it
# imports std::windows (compiled for windows-x86_64).
proc best {windows text} {
    set target [expr {$windows ? "windows-x86_64" : $::host}]
    set hir [build $text $target]
    set resultPath [file join $::scratch result]
    file delete $resultPath
    set nir [native::nir $hir]
    if {$windows} {
        # No foreign declaration may be left (the program would call
        # Windows), so the link plan (kernel32) is dropped; on Linux the
        # host's target line replaces windows-x86_64's.
        if {[lsearch -glob [split $nir \n] {foreign *}] >= 0} {
            error "a windows row calls C: the driver's bench cannot run it"
        }
        set lines {}
        foreach line [split $nir \n] {
            if {[string match {link *} $line]} continue
            if {$::windowsMode eq "swap" && [string match {target *} $line]} { set line $::targetLine }
            lappend lines $line
        }
        set nir [join $lines \n]
    }
    set nirPath [file join $::scratch program.nir]
    set channel [open $nirPath w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $nir
    close $channel
    exec [native::binary] bench $::runs $nirPath --result $resultPath
    set lines [split [core::ReadFile $resultPath] \n]
    set times [lsearch -inline $lines {times *}]
    if {$times eq ""} {
        error "no timing:\n[join $lines \n]"
    }
    set values [lsearch -inline $lines {value *}]
    if {[regexp {^value \{int -} $values]} {
        error "the program failed ($values):\n$text"
    }
    return [expr {[tcl::mathfunc::min {*}[lrange $times 1 end]] / 1000.0}]
}

# Iterations for a text of LENGTH characters.
proc iterations {length} {
    return [expr {max(50, int($::scale * 400000 / ($length + 16)))}]
}

proc row {group label length alphabet setup body {needsCodec 0}} {
    set windows [expr {$group eq "windows"}]
    if {$needsCodec && !$::hasCodec} {
        puts [format "| %-7s | %-34s | %5d | %-5s | %12s |" $group $label $length $alphabet n/a]
        return
    }
    set n [iterations $length]
    set empty [expr {1000.0 * [best $windows [program $windows $setup "" $n]] / $n}]
    set t [expr {1000.0 * [best $windows [program $windows $setup $body $n]] / $n}]
    set d [expr {$t - $empty}]
    puts [format "| %-7s | %-34s | %5d | %-5s | %12.1f |" $group $label $length $alphabet $d]
    flush stdout
}

set revision ""
catch {set revision [string range [exec git -C $treeRoot rev-parse HEAD] 0 9]}
puts "bench/utf16-bytes.tcl: $host, tree $treeRoot ($revision), best of $runs runs, ns per operation"
if {"windows" in $groups && $windowsMode eq "swap"} {
    set targetLine [hostTargetLine]
    puts "windows rows: compiled for windows-x86_64, run on this $host CPU (local experiment)"
}
puts "| group   | operation                          | chars | alpha | ns/op        |"
puts "|---------|------------------------------------|------:|-------|-------------:|"

foreach length [dict get $options -lengths] {
    foreach alphabet [dict get $options -alphabets] {
        set t [textOf $length $alphabet]
        set lt [literal $t]
        if {"codec" in $groups} {
            row codec "encode_utf16le" $length $alphabet "    t = $lt" \
                "std::abi::bytes::encode_utf16le(t)" 1
            row codec "decode_utf16le" $length $alphabet "    d = std::abi::bytes::encode_utf16le($lt)" \
                "std::abi::bytes::decode_utf16le(d)" 1
            row codec "decode_utf8 (reference)" $length $alphabet "    d = std::abi::bytes::from_list($lt.encode_utf8())" \
                "std::abi::bytes::decode_utf8(d)"
        }
        if {"windows" in $groups && $windowsMode ne ""} {
            set p [pathOf [expr {max($length, 4)}] $alphabet]
            set lp [literal $p]
            set lone "\[[join [concat [unitsOf $t] 55296] {, }]\]"
            row windows "validate + native" $length $alphabet "    t = $lt" \
                "std::windows::path::validate(t)\n        t.native()"
            row windows "from_text" $length $alphabet "    t = $lt" \
                "std::windows::fs::from_text(t)"
            row windows "text" $length $alphabet "    n = std::windows::fs::from_text($lt)" \
                "n.text()"
            row windows "display" $length $alphabet "    n = std::windows::fs::from_text($lt)" \
                "n.display()"
            row windows "display (lossy: + D800)" $length $alphabet "    n = std::windows::fs::from_units($lone)" \
                "n.display()"
            row windows "units" $length $alphabet "    n = std::windows::fs::from_text($lt)" \
                "n.units()"
            row windows "kind" $length $alphabet "    n = std::windows::fs::from_text($lp)" \
                "n.kind()"
            row windows "concat (text)" $length $alphabet "    b = $lp\n    std::windows::path::validate(b)" \
                "std::windows::path::concat(b, \"component.txt\")"
            row windows "join (native)" $length $alphabet "    nb = std::windows::fs::from_text($lp)\n    leaf = std::windows::fs::from_text(\"component.txt\")" \
                "nb.join(leaf)"
            set lu "\[[join [unitsOf $p] {, }]\]"
            set cu "\[[join [unitsOf component.txt] {, }]\]"
            row windows "syntax: kind_of (path units)" $length $alphabet "    us = $lu" \
                "us.kind_of()"
            row windows "syntax: joinable? (component)" $length $alphabet "    us = $lu\n    cu = $cu\n    k = us.kind_of()" \
                "k.joinable?(cu)"
            row windows "Win32 buffer from List\[int\] (M7)" $length $alphabet "    us = std::windows::fs::from_text($lt).units()" \
                "wide_of_units(us)"
            row windows "Win32 buffer from Bytes (this)" $length $alphabet "    d = std::abi::bytes::encode_utf16le($lt)" \
                "wide_of_bytes(d)" 1
        }
    }
}
if {"windows" in $groups && $windowsMode eq ""} {
    puts "windows rows: skipped (no Windows and no Linux host to run them on)"
}

if {$::tcl_platform(platform) eq "unix"} {
    exec rm -rf -- $scratch
} else {
    file delete -force $scratch
}
