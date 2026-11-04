# bench.tcl -- the CSV emitters' native cost (CSV-EMISSION-VALIDATION-
# MILESTONE-1.md, section 16).
#
#   tclsh9.0 audit/csv-emission/tools/bench.tcl ?-runs N? ?-rounds R?
#       ?-short ROWS? ?-large ROWS? ?-width CHUNKS? ?-nwidth NCHUNKS?
#       ?-shapes LIST? ?-out FILE?
#
# Natively (cranelift), every variant serializing the same table and
# folding the output into a checksum (no output stored but where the
# variant's point is storage):
#
#   certified    the always-quoted UTF-8 byte document (sources::
#                bytes_document_source), its claims certified, fused
#   unclaimed    the same modules with every claim removed (a claim is
#                erased: this is the same code, measured again)
#   validated    certified, each byte also fed to document3_bytes at run
#                time as it is emitted (design A: what a static proof saves)
#   general      certified, coroutine fusion off: the general coroutine
#                runtime (a handle that crosses a call is kept there)
#   scalar       the always-quoted document over scalar values (no UTF-8
#                encoding work)
#   selective    the selective document over scalar values (the decision
#                scan, then each field quoted or not)
#   buffered     a conventional serializer: no coroutine, no claim -- the
#                same policy and guard, pushing the bytes into a
#                MutableVector, then the checksum over it
#
# on three shapes: `short` (many short records: ROWS rows of three fields of
# 3-30 characters, quotation marks, commas and a CRLF among them),
# `large-ascii` (a few very large records: ROWS rows whose fields are CHUNKS
# copies of a 35-character ASCII chunk) and `large` (the same with a mixed
# chunk, non-ASCII included, and NCHUNKS copies). A time is the best of RUNS
# in-process runs, the median over ROUNDS (interleaved); per output symbol.
#
# The non-ASCII shape is smaller on purpose: std::str::char_at locates
# character I of a non-ASCII String by decoding from its start (native
# runtime/ops.rs's char_at_index), so a loop over one field's characters is
# quadratic in the field's length -- in every variant, claimed or not.
#
# Resources per variant (short shape): allocations and coroutine objects
# (native::allocationReport), machine code bytes, the fused NIR's
# recognizer work (table loads and switches: the guards' -- the program's
# own run-time check, present with or without claims -- and any
# dfa#transition) and branches, the front end's time and the emission
# check's share of it.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-runs 5 -rounds 3 -short 20000 -large 6 -width 2000 -nwidth 200 -shapes {short large-ascii large} -out ""} $argv]
set argv {}
source [file join [file dirname [file dirname [file dirname $here]]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]
source [file join $::projectRoot tests emission-support.tcl]
source [file join $here run.tcl]

set runs [dict get $options -runs]
# Every compilation checks its claims afresh (the in-process certificate
# memo would let later variants reuse the first one's certificates).
set ::hir::emission::useMemo 0
set rounds [dict get $options -rounds]

proc readText {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The table, made by the program itself (no literal input).
set dataText {
fn short_rows(n: int) -> List[csv_common::Row]:
    loop i from 0 to n:
        id = std::int::to_string(i)
        if i.mod(3) == 0:
            csv_common::Row {a: id, b: "Ada \"the Countess\" Lovelace", c: "notes, with a comma\r\nand a line"}
        elif i.mod(3) == 1:
            csv_common::Row {a: id, b: "plain value", c: "ok"}
        else:
            csv_common::Row {a: id, b: "", c: "a, b and c"}

fn chunk(k: int) -> str:
    fold i from 0 to k with intermediate acc "":
        acc.concat("café, \"quoted\" naïve € \U1F600 x\r\n")

fn large_rows(n: int, width: int) -> List[csv_common::Row]:
    big = chunk(width)
    loop i from 0 to n:
        csv_common::Row {a: std::int::to_string(i), b: big, c: big}

fn ascii_chunk(k: int) -> str:
    fold i from 0 to k with intermediate acc "":
        acc.concat("cafe, \"quoted\" naive EUR :-) xyzw\r\n")

fn large_ascii_rows(n: int, width: int) -> List[csv_common::Row]:
    big = ascii_chunk(width)
    loop i from 0 to n:
        csv_common::Row {a: std::int::to_string(i), b: big, c: big}

fn mix(h: int, c: int) -> int:
    (h * 31 + c + 1).mod(2147483647)
}
set dataText [string map [list {\u00e9} \u00e9 {\u00ef} \u00ef {\u20ac} \u20ac {\U1F600} \U1F600] $dataText]

# The consumer of SOURCE (a sources:: root), folding into {digest, count}.
proc digestOf {source args} {
    return "fn run(header: csv_common::Row, rows: List\[csv_common::Row\]) -> List\[int\] errors csv_common::UnsupportedCSVCharacter, selective_emit::QuotingDecision:
    coroutine {step, first} = sources::$source\(header, rows)
    state = std::mutable_array::create(3, 0)
    state.set(2, first)
    loop:
        if std::coroutine::done?(step):
            break
        state.set(0, mix(state.at(0), state.at(2)))
        state.set(1, state.at(1) + 1)
        state.set(2, step())
    \[state.at(0), state.at(1)\]
"
}

set validatedText {fn run(header: csv_common::Row, rows: List[csv_common::Row]) -> List[int] errors csv_common::UnsupportedCSVCharacter, selective_emit::QuotingDecision, sinks::Invalid:
    d = sinks::validated_bytes(header, rows)
    [d.digest, d.symbols]
}

# The conventional serializer: the same policy and guard, no coroutine.
set bufferedText {fn push_utf8(place out: MutableVector[int], v: int):
    if v < 128:
        out.push(v)
    elif v < 2048:
        out.push(192 + v.shift_right(6))
        out.push(128 + v.mod(64))
    elif v < 65536:
        out.push(224 + v.shift_right(12))
        out.push(128 + v.shift_right(6).mod(64))
        out.push(128 + v.mod(64))
    else:
        out.push(240 + v.shift_right(18))
        out.push(128 + v.shift_right(12).mod(64))
        out.push(128 + v.shift_right(6).mod(64))
        out.push(128 + v.mod(64))

fn push_field(place out: MutableVector[int], value: str) errors csv_common::UnsupportedCSVCharacter:
    out.push(34)
    loop i from 0 to value.length():
        c = value.char_at(i).scalar_value()
        if c == 34:
            out.push(34)
            out.push(34)
        else:
            csv_utf8::quoted_char(c):
                on std::dfa::UnrecognizedInput:
                    fail csv_common::UnsupportedCSVCharacter {at: i, value: c}
                on std::dfa::UnexpectedEnd:
                    fail csv_common::UnsupportedCSVCharacter {at: i, value: c}
            push_utf8(out, c)
        continue
    out.push(34)

fn push_row(place out: MutableVector[int], r: csv_common::Row) errors csv_common::UnsupportedCSVCharacter:
    push_field(out, r.a)
    out.push(44)
    push_field(out, r.b)
    out.push(44)
    push_field(out, r.c)
    out.push(13)
    out.push(10)

fn run(header: csv_common::Row, rows: List[csv_common::Row]) -> List[int] errors csv_common::UnsupportedCSVCharacter, selective_emit::QuotingDecision:
    out = std::mutable_vector::from_list([0])
    out.clear()
    push_row(out, header)
    loop r in rows:
        push_row(out, r)
        continue
    h = std::mutable_array::create(1, 0)
    loop b in out:
        h.set(0, mix(h.at(0), b))
        continue
    [h.at(0), out.length()]
}

set imports "import std::dfa\nimport std::coroutine\nimport std::mutable_vector\nimport std::mutable_array\nimport std::int\nimport std::str\nimport std::char\nimport std::list\nimport csv_common\nimport csv_utf8\nimport selective_emit\nimport sources\nimport sinks\n"

# VARIANT -> {RUN-TEXT STRIP FUSED}
set variants [dict create \
    certified [list [digestOf bytes_document_source] 0 1] \
    unclaimed [list [digestOf bytes_document_source] 1 1] \
    validated [list $validatedText 0 1] \
    general [list [digestOf bytes_document_source] 0 0] \
    scalar [list [digestOf utf8_document_source] 0 1] \
    selective [list [digestOf selective_document_source] 0 1] \
    buffered [list $bufferedText 0 1]]

proc program {variant shape} {
    lassign [dict get $::variants $variant] runText
    switch -- $shape {
        short { set rows "short_rows([dict get $::options -short])" }
        large-ascii { set rows "large_ascii_rows([dict get $::options -large], [dict get $::options -width])" }
        large { set rows "large_rows([dict get $::options -large], [dict get $::options -nwidth])" }
    }
    return "$::imports$::dataText\n$runText\nheader = csv_common::Row {a: \"id\", b: \"name\", c: \"note\"}\nrows = $rows\nrun(header, rows):\n    on csv_common::UnsupportedCSVCharacter:\n        \[-1\]\n    on selective_emit::QuotingDecision:\n        \[-2\]\n    on sinks::Invalid:\n        \[-3\]\n"
}

# {HIR FRONT-MS CHECK-MS DIR} of VARIANT on SHAPE (DIR removed by the caller).
proc compile {variant shape} {
    lassign [dict get $::variants $variant] runText strip
    set dir [csvrun::Workspace]
    if {$strip} {
        foreach path [glob -directory $dir *.bot] {
            writeText $path [emit::strip [readText $path]]
        }
    }
    set text [program $variant $shape]
    if {$variant ne "validated"} {
        set text [string map {", sinks::Invalid" "" "    on sinks::Invalid:\n        \[-3\]\n" ""} $text]
        set text [string map {"import sinks\n" ""} $text]
    }
    writeText [file join $dir main.bot] $text
    set ::hir::emission::stats {}
    set t0 [clock microseconds]
    set hir [surface::readProgramFile [file join $dir main.bot] -warnings off]
    set front [expr {([clock microseconds] - $t0) / 1000.0}]
    set check [expr {[dict getdef $::hir::emission::stats checkMicroseconds 0] / 1000.0}]
    return [list $hir $front $check $dir]
}

proc fused? {variant} {
    return [lindex [dict get $::variants $variant] 2]
}

proc measure {variant hir} {
    if {[fused? $variant]} {
        return [native::measure $hir $::runs]
    }
    return [withoutCoroutineFusion {native::measure $hir $::runs}]
}

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

set report "# CSV emitters: native cost\n\n"
append report "Generated by audit/csv-emission/tools/bench.tcl -runs $runs -rounds $rounds -short [dict get $options -short] -large [dict get $options -large] -width [dict get $options -width] -nwidth [dict get $options -nwidth] on [exec uname -m] ([string trim [lindex [split [exec grep -m1 {model name} /proc/cpuinfo] :] 1]]).\n"
append report "Best of $runs in-process runs, median over $rounds rounds; ns per output symbol (a byte, or a scalar value for scalar and selective).\n\n"
append report "| variant | shape | symbols | ns/symbol (median) | ns/symbol (min) | MB/s | checksum |\n|---|---|---:|---:|---:|---:|---|\n"
puts -nonewline $report
set compiled [dict create]
foreach shape [dict get $options -shapes] {
    foreach variant [dict keys $variants] {
        dict set compiled $variant,$shape [compile $variant $shape]
    }
    set times [dict create]
    set values [dict create]
    for {set r 0} {$r < $rounds} {incr r} {
        foreach variant [dict keys $variants] {
            set hir [lindex [dict get $compiled $variant,$shape] 0]
            lassign [measure $variant $hir] lower compileUs best collections value
            dict lappend times $variant $best
            dict set values $variant $value
        }
    }
    set checks [dict create]
    foreach variant [dict keys $variants] {
        set value [dict get $values $variant]
        # The driver's tagged value: list {{int DIGEST} {int SYMBOLS}}.
        set digest [lindex $value 1 0 1]
        set symbols [lindex $value 1 1 1]
        set med [median [dict get $times $variant]]
        set min [tcl::mathfunc::min {*}[dict get $times $variant]]
        set row "| $variant | $shape | $symbols | [format %.2f [expr {$med * 1000.0 / $symbols}]] | [format %.2f [expr {$min * 1000.0 / $symbols}]] | [format %.1f [expr {$symbols / $med}]] | $digest |"
        append report $row\n
        puts $row
    }
}

set section "\n## Resources (short shape)\n\n| variant | allocations | coroutine objects | code bytes | NIR table loads | NIR switches | dfa#transition | NIR branches | front end ms | emission check ms |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
append report $section
puts -nonewline $section
foreach variant [dict keys $variants] {
    lassign [dict get $compiled $variant,short] hir front check dir
    if {[fused? $variant]} {
        set alloc [native::allocationReport $hir summary]
        set size [lindex [lindex [native::Driver size [native::nir $hir]] 0] 1]
        set nir [native::fusedNir $hir]
    } else {
        set alloc [withoutCoroutineFusion {native::allocationReport $hir summary}]
        set size [withoutCoroutineFusion {lindex [lindex [native::Driver size [native::nir $hir]] 0] 1}]
        set nir [withoutCoroutineFusion {native::nir $hir}]
    }
    set all 0
    dict for {kind info} [dict get $alloc byKind] {
        incr all [dict get $info allocations]
    }
    set coroutines [expr {[dict exists $alloc byKind Coroutine] ? [dict get $alloc byKind Coroutine allocations] : 0}]
    set row "| $variant | $all | $coroutines | $size | [regexp -all {op rtabload} $nir] | [regexp -all -line {^\s*switch } $nir] | [regexp -all {dfa#transition} $nir] | [regexp -all -line {^\s*br } $nir] | [format %.0f $front] | [format %.0f $check] |"
    append report $row\n
    puts $row
}
foreach key [dict keys $compiled] {
    file delete -force [lindex [dict get $compiled $key] 3]
}
set fusedEqual [expr {[native::fusedNir [lindex [dict get $compiled certified,short] 0]] eq [native::fusedNir [lindex [dict get $compiled unclaimed,short] 0]]}]
set line "\nThe certified and unclaimed programs' fused NIR are [expr {$fusedEqual ? "identical" : "DIFFERENT"}] (a claim is erased).\n"
append report $line
puts $line
if {[dict get $options -out] ne ""} {
    writeText [dict get $options -out] $report
}
