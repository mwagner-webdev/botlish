# filesystem.tcl -- what paths and synchronous file I/O cost natively
# (WINDOWS-X86-64-MILESTONE-7.md, "Performance").
#
#   tclsh9.0 bench/filesystem.tcl ?-runs N? ?-scale F? ?-compile-only TARGET?
#       ?-root DIR | -baseline-rev REV?
#
# Measured on the host's own platform -- std::linux::fs (raw syscalls) on
# Linux, std::windows::fs (kernel32's wide functions) on Windows,
# std::darwin::fs (libSystem) on macOS -- in a fresh directory of the
# temporary directory. Each row is a program that runs its operation in a
# loop of N iterations, reported per iteration beside the same loop without
# the operation and their difference (bench/darwin-io.tcl's method). The
# loop runs RUNS times inside ONE process (best of RUNS: `botlish-native
# bench` on Linux; on Windows and macOS the program calls C, so it is an
# executable repeating the run itself, BOTLISH_NATIVE_RUNS), so neither
# compilation, linking nor process start is in a row. Every operation is
# idempotent (the same files are replaced, opened and listed each run).
#
#   validate + native    PLATFORM::path::validate of a 40-character text and
#                        its native path (UTF-8 bytes, or UTF-16 units)
#   concat (text)        a validated path joined with a component
#   join (native)        a native path joined with a native name
#   text (native)        a native name's String (strict UTF-8 / UTF-16)
#   display (native)     the same name for people (lossy where it has no text)
#   ... 256 mixed        validate + native, text and concat of a 256-character
#                        text of mixed widths (a, é, 中, 😀, ...: a quarter of
#                        them astral; UTF16-BYTE-STORAGE-MILESTONE-1.md)
#   encode/decode 40     std::abi::bytes::encode_utf16le of a 40-character
#                        text and decode_utf16le of its bytes: the platform-
#                        free primitives (n/a in a tree without them)
#   open + close         open(Read) and close of an existing file
#   write_file 64 B      create-or-replace a file with 64 bytes (open, write,
#                        close)
#   read_file 64 B       open, read to the end, close
#   portable write 64 B  the same write_file through std::io::fs::FilePath (a
#                        clone per witness: it must cost what the direct
#                        call costs)
#   write_file 1 MiB     and read_file 1 MiB: per MiB
#   entries (100)        a 100-entry directory listed: per entry
#   reopen (100)         listed, and every entry read back through its
#                        native name: per entry
#
# -scale F multiplies every N (smaller for a quick look). Prints a table;
# the report quotes it. -root DIR measures another checkout's compiler and
# standard library -- the tree before a change, a git worktree -- with this
# checkout's driver unless DIR has its own build (the driver runs any older
# program): before and after on one machine. -baseline-rev REV does both: REV
# in a temporary worktree (bench/baseline-tree.tcl), then this tree, and a
# table of the two differences and their ratio. -compile-only TARGET (linux-x86_64, windows-x86_64,
# macos-aarch64) only compiles every program for TARGET's platform and runs
# none: a check, on any host, of the programs another host will run.

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]

set runs 5
set scale 1.0
set compileOnly ""
set treeRoot $root
set baselineRev ""
foreach {option value} $argv {
    switch -- $option {
        -runs { set runs $value }
        -scale { set scale $value }
        -compile-only { set compileOnly $value }
        -root { set treeRoot [file normalize $value] }
        -baseline-rev { set baselineRev $value }
        default { error "unknown option $option" }
    }
}
if {$baselineRev ne ""} {
    source [file join $here baseline-tree.tcl]
    set args [baselineTree::childArgs [dict create -runs $runs -scale $scale]]
    set tree [baselineTree::add $root $baselineRev]
    try {
        set before [baselineTree::run [info script] -root $tree {*}$args]
        set after [baselineTree::run [info script] {*}$args]
    } finally {
        baselineTree::remove $root $tree
    }
    # The rows of a run's table: LABEL -> {DIFFERENCE UNIT}.
    proc rowsOf {text} {
        set rows [dict create]
        foreach line [lrange [split $text \n] 2 end] {
            set label [string trim [string range $line 0 21]]
            set rest [string range $line 22 end]
            if {$label eq "" || [llength $rest] < 3} continue
            dict set rows $label [list [lindex $rest 2] [lindex $rest 3]]
        }
        return $rows
    }
    set b [rowsOf $before]
    set a [rowsOf $after]
    puts "\nbefore: $baselineRev; after: this tree (difference per operation)"
    puts [format "%-22s %12s %12s %12s" "" before after after/before]
    dict for {label value} $a {
        lassign $value now unit
        set was [lindex [dict getdef $b $label {n/a ""}] 0]
        puts [format "%-22s %12s %12s %12s %s" $label $was $now [baselineTree::ratio $was $now] $unit]
    }
    exit 0
}
if {![info exists ::env(BOTLISH_NATIVE_BIN)]
        && ![file exists [file join $treeRoot native target release botlish-native]]
        && ![file exists [file join $treeRoot native target release botlish-native.exe]]} {
    set own [file join $root native target release botlish-native]
    if {$::tcl_platform(platform) eq "windows"} { append own .exe }
    set ::env(BOTLISH_NATIVE_BIN) $own
}
source [file join $treeRoot surface surface.tcl]
source [file join $treeRoot native native.tcl]
set hasCodec [expr {![catch {core::native::metadata std::byte_store::encode_utf16le}]}]

set target [expr {$compileOnly ne "" ? $compileOnly : [core::cabi::hostTarget]}]
switch -glob -- $target {
    linux-* { set platform linux }
    windows-* { set platform windows }
    macos-* { set platform darwin }
    default { error "no filesystem platform for host $target" }
}
set scratch [file tempdir botlish-fs-bench-]
set dir [file join $scratch d]
file mkdir $dir
set f [open [file join $dir small.txt] wb]; puts -nonewline $f [string repeat x 64]; close $f
file mkdir [file join $dir hundred]
for {set i 0} {$i < 100} {incr i} {
    set f [open [file join $dir hundred f$i] wb]; puts -nonewline $f $i; close $f
}
set dirText [file nativename [file normalize $dir]]

proc literal {text} {
    return "\"[string map {\\ \\\\ \" \\\"} $text]\""
}

set prelude "import std::abi
import std::abi::bytes
import std::int
import std::io::fs
import std::io::path
import std::list
import std::str
import std::$platform\::fs
import std::$platform\::path

fn bytes_of(text: str) -> std::abi::bytes::Bytes:
    std::abi::bytes::from_list(text.encode_utf8())

fn portable_write(p: std::io::fs::FilePath, data: std::abi::bytes::Bytes) errors std::io::fs::FileError:
    p.write_file(data)

fn reread(dir: std::$platform\::fs::NativePath) -> int errors std::io::fs::FileError, std::io::path::NotAPath:
    sizes = loop e in dir.entries():
        std::abi::bytes::length(dir.join(e.name).read_file()).value
    sizes.length()
"

# The program: SETUP (indented four spaces), then a loop of N iterations of
# BODY, its value discarded.
proc program {setup body n} {
    set inner [expr {$body eq "0" ? "0" : "$body\n        0"}]
    return "$::prelude
fn f() -> int errors std::io::fs::FileError, std::io::path::NotAPath, std::io::path::NotText[expr {$::hasCodec ? ", InvalidUtf16" : ""}]:
    root = [literal $::dirText]
    std::$::platform\::path::validate(root)
    nroot = root.native()
$setup
    xs = loop i from 0 to $n:
        $inner
    std::list::length(xs)

with context std::$::platform\::fs::create()
f():
    on std::io::fs::FileError:
        -1
    on std::io::path::NotAPath:
        -2
    on std::io::path::NotText:
        -3
[expr {$::hasCodec ? "    on InvalidUtf16:\n        -4\n" : ""}]"
}

# The best time (microseconds) of one run of program TEXT, inside one
# process.
proc best {text} {
    set dir [file join $::scratch p[incr ::programs]]
    file mkdir $dir
    set f [open [file join $dir main.bot] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    set hir [surface::readProgramFile [file join $dir main.bot] -warnings off -cache "" -target $::target]
    if {$::compileOnly ne ""} {
        return 1.0
    }
    set resultPath [file join $::scratch result]
    file delete $resultPath
    if {$::platform eq "linux"} {
        set nirPath [file join $::scratch program.nir]
        set channel [open $nirPath w]
        fconfigure $channel -encoding utf-8 -translation lf
        puts -nonewline $channel [native::nir $hir]
        close $channel
        exec [native::binary] bench $::runs $nirPath --result $resultPath
    } else {
        set exe [native::executable $hir [file join $dir bench]]
        set saved [array get ::env BOTLISH_NATIVE_*]
        set ::env(BOTLISH_NATIVE_RESULT) $resultPath
        set ::env(BOTLISH_NATIVE_RUNS) $::runs
        try {
            exec $exe
        } finally {
            unset -nocomplain ::env(BOTLISH_NATIVE_RESULT) ::env(BOTLISH_NATIVE_RUNS)
            array set ::env $saved
        }
    }
    set lines [split [core::ReadFile $resultPath] \n]
    set times [lsearch -inline $lines {times *}]
    if {$times eq ""} {
        error "no timing:\n[join $lines \n]"
    }
    set values [lsearch -inline $lines {value *}]
    if {[string match "value -*" $values]} {
        error "the program failed ($values):\n$text"
    }
    return [expr {[tcl::mathfunc::min {*}[lrange $times 1 end]] / 1000.0}]
}
set programs 0

# "LOOP OPERATION DIFFERENCE" in ns per iteration (or per UNIT: the
# difference divided by PER).
proc row {label setup body n {per 1} {unit ns} {needsCodec 0}} {
    if {$needsCodec && !$::hasCodec} {
        puts [format "%-22s %12s %12s %12s" $label - - n/a]
        return
    }
    set n [expr {max(1, int($n * $::scale))}]
    set baseline [expr {1000.0 * [best [program $setup 0 $n]] / $n}]
    set t [expr {1000.0 * [best [program $setup $body $n]] / $n}]
    set d [expr {($t - $baseline) / $per}]
    if {$unit eq "us"} {
        puts [format "%-22s %12.1f %12.1f %12.1f us" $label [expr {$baseline / 1000}] [expr {$t / 1000}] [expr {$d / 1000}]]
    } else {
        puts [format "%-22s %12.1f %12.1f %12.1f ns" $label $baseline $t $d]
    }
}

set revision ""
catch {set revision " ([string range [exec git -C $treeRoot rev-parse HEAD] 0 9])"}
puts "bench/filesystem.tcl: $platform on $target, best of $runs runs, in $dirText, tree $treeRoot$revision"
puts [format "%-22s %12s %12s %12s" "" loop "with it" difference]
set name [string repeat a 40]
row "validate + native" "    text = [literal $name]" "std::$platform\::path::validate(text)\n        text.native()" 20000
row "concat (text)" "" "std::$platform\::path::concat(root, \"component.txt\")" 20000
row "join (native)" "    leaf = std::$platform\::fs::from_text(\"component.txt\")" "nroot.join(leaf)" 20000
row "text (native)" "    leaf = nroot.concat(\"component.txt\")" "leaf.text()" 20000
row "display (native)" "    leaf = nroot.concat(\"component.txt\")" "leaf.display()" 20000
set mixed [string range [string repeat "a\u00e9\u4e2d\U1F600b\u00fcx\U1D11E" 32] 0 255]
row "validate+native 256 mx" "    text = [literal $mixed]" "std::$platform\::path::validate(text)\n        text.native()" 2000
row "text 256 mixed" "    leaf = nroot.concat([literal $mixed])" "leaf.text()" 2000
row "concat 256 mixed" "    base = std::$platform\::path::concat(root, [literal $mixed])" "std::$platform\::path::concat(base, \"component.txt\")" 2000
row "encode_utf16le 40" "    text = [literal $name]" "std::abi::bytes::encode_utf16le(text)" 20000 1 ns 1
row "decode_utf16le 40" "    data = std::abi::bytes::encode_utf16le([literal $name])" "std::abi::bytes::decode_utf16le(data)" 20000 1 ns 1
row "open + close" "    small = nroot.concat(\"small.txt\")" "small.open(std::io::fs::OpenMode::Read).close()" 2000
row "write_file 64 B" "    out = nroot.concat(\"out.txt\")\n    data = bytes_of([literal [string repeat y 64]])" "out.write_file(data)" 2000
row "read_file 64 B" "    small = nroot.concat(\"small.txt\")" "small.read_file()" 2000
row "portable write 64 B" "    out = std::$platform\::path::concat(root, \"portable.txt\")\n    data = bytes_of([literal [string repeat y 64]])" "portable_write(out, data)" 2000
row "write_file 1 MiB" "    big = nroot.concat(\"big.bin\")\n    blocks = loop k from 0 to 16:\n        bytes_of([literal [string repeat z 65536]])\n    data = std::abi::bytes::join(blocks)" "big.write_file(data)" 50 1 us
row "read_file 1 MiB" "    big = nroot.concat(\"big.bin\")\n    blocks = loop k from 0 to 16:\n        bytes_of([literal [string repeat z 65536]])\n    big.write_file(std::abi::bytes::join(blocks))" "big.read_file()" 50 1 us
row "entries (100)" "    hundred = nroot.concat(\"hundred\")" "hundred.entries()" 200 100
row "reopen (100)" "    hundred = nroot.concat(\"hundred\")" "reread(hundred)" 50 100

if {$::tcl_platform(platform) eq "unix"} {
    exec rm -rf -- $scratch
} else {
    file delete -force $scratch
}
