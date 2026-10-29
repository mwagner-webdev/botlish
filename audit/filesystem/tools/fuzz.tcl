#!/usr/bin/env tclsh9.0
# fuzz.tcl -- random paths and names against independent models
# (WINDOWS-X86-64-MILESTONE-7.md, "Fuzzing").
#
#   tclsh9.0 audit/filesystem/tools/fuzz.tcl ?-n N? ?-seed S? ?-parts LIST?
#       ?-backends LIST? ?-gc-stress 0|1? ?-verbose 0|1?
#
# Parts (-parts, default every part this host can run):
#
#   windows   N random (base, component) pairs drawn from Win32's syntax --
#             drive designators (letters and "1:"), "\" and "/", UNC and
#             device prefixes, \\?\ and \??\, ".", "..", trailing periods
#             and spaces, ":", non-ASCII and astral characters -- and N
#             random UTF-16 code-unit sequences (unpaired surrogates among
#             them). This script computes, by its own reading of the rules
#             the report states (never the library's code), each base's
#             PathKind, each concat's result or refusal, and each unit
#             sequence's text (none when it holds an unpaired surrogate) and
#             display (U+FFFD for each unpaired surrogate); one program
#             compiled for windows-x86_64 computes them with
#             std::windows::path::concat, std::windows::fs::join of the
#             native paths, std::windows::fs::kind, text and display, on the
#             Tcl backends (pure: no host needed).
#   linux     the same for LinuxPath's concat and NativePath's join (bytes:
#             random byte strings, some not UTF-8), compiled for the host's
#             Linux target (any host).
#   files     (Linux native hosts) N random file names -- 1 to 12 bytes of
#             1..255 but "/", "." and ".." excluded, many not UTF-8 -- made
#             by one program through std::linux::fs in a fresh directory,
#             each holding its own index; the program lists the directory
#             and reads every listed entry back through its native name. The
#             listing must be exactly the names made, each reaching its own
#             contents: the lossless round trip, on -backends (default the
#             native ones), with BOTLISH_NATIVE_GC_STRESS=1 under -gc-stress 1.
#
# The last line is "cases N disagreements D" (mutate.tcl reads it); the exit
# status is 1 when D > 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 200 -seed 1 -parts "" -backends {cranelift-generic cranelift} -gc-stress 0 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
expr {srand([dict get $options -seed])}

set linuxHost [expr {$::tcl_platform(os) eq "Linux" && ![catch {native::binary}]}]
set parts [dict get $options -parts]
if {$parts eq ""} {
    set parts {windows linux}
    if {$linuxHost} { lappend parts files }
}
set n [dict get $options -n]
set scratch [file tempdir botlish-fs-fuzz-]
set cases 0
set disagreements 0

proc rand {n} { expr {int(rand() * $n)} }
proc pick {list} { lindex $list [rand [llength $list]] }

# TEXT as a Botlish String literal (no character needs more than these two
# escapes; a raw U+0000 never occurs here).
proc literal {text} {
    return "\"[string map {\\ \\\\ \" \\\"} $text]\""
}

# The HIR of program TEXT compiled for TARGET.
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

proc outcome {backend hir} {
    if {[catch {
        switch -- $backend {
            interp {
                core::useBackend interp
                core::evalProgram [hir::lower $hir]
            }
            compile { core::compiler::evalHir $hir }
            cranelift-generic { native::evalHir $hir -specialize 0 }
            cranelift { native::evalHir $hir }
        }
    } result opts]} {
        return [list error "[lindex [dict get $opts -errorcode] end]: [string range $result 0 300]"]
    }
    return [list value [tclValue $result]]
}

proc tclValue {v} {
    switch -- [core::value::kind $v] {
        list { return [lmap item [core::value::items $v] {tclValue $item}] }
        int { return [core::value::intOf $v] }
        str { return [core::value::strOf $v] }
    }
    return [core::value::show $v]
}

proc report {part index expected got {detail ""}} {
    incr ::disagreements
    puts "$part case $index: expected [list $expected], got [list $got]$detail"
}

# ---------------------------------------------------------------------------
# The Windows model

proc sep? {c verbatim} {
    expr {$c eq "\\" || ($c eq "/" && !$verbatim)}
}

# PathKind of S (the report's table).
proc winKind {s} {
    if {[string range $s 0 3] in [list "\\\\?\\" "\\??\\"]} { return Verbatim }
    set a [string index $s 0]; set b [string index $s 1]; set c [string index $s 2]; set d [string index $s 3]
    if {[sep? $a 0] && [sep? $b 0]} {
        if {$c in {. ?} && ([string length $s] == 3 || [sep? $d 0])} { return Device }
        return Unc
    }
    if {[sep? $a 0]} { return RootRelative }
    if {$b eq ":"} {
        if {[sep? $c 0]} { return DriveAbsolute }
        return DriveRelative
    }
    return Relative
}

# The components of S split on its separators.
proc winSegments {s verbatim} {
    set out {}
    set cur ""
    foreach c [split $s ""] {
        if {[sep? $c $verbatim]} {
            lappend out $cur
            set cur ""
        } else {
            append cur $c
        }
    }
    lappend out $cur
    return $out
}

# concat(BASE, COMP) by Win32's syntax, or NotAPath.
proc winConcat {base comp} {
    if {$comp eq "" || [winKind $comp] ne "Relative"} { return NotAPath }
    set kind [winKind $base]
    set verbatim [expr {$kind eq "Verbatim"}]
    if {$verbatim} {
        if {[string first / $comp] >= 0} { return NotAPath }
        foreach seg [winSegments $comp 1] {
            if {$seg in {"" . ..}} { return NotAPath }
        }
    } else {
        foreach seg [winSegments $comp 0] {
            if {$seg ni {"" . ..} && [string index $seg end] in {. " "}} { return NotAPath }
        }
    }
    if {[sep? [string index $base end] $verbatim] || ($kind eq "DriveRelative" && [string length $base] == 2)} {
        return $base$comp
    }
    return "$base\\$comp"
}

# Segments joined by random separators: "." and ".." whole segments, empty
# ones (a doubled separator), trailing periods and spaces, ":" past a
# drive, non-ASCII and astral characters.
proc randomWinSegments {count} {
    set out ""
    for {set i 0} {$i < $count} {incr i} {
        if {$i > 0} { append out [pick [list \\ \\ /]] }
        append out [pick [list a b . .. x. "y " é 𝄞 ab:c "" a.b]]
    }
    return $out
}

proc randomWinBase {} {
    set prefix [pick [list "" "C:" "C:\\" "C:/" "\\" "/" "\\\\s\\t" "//s/t" "\\\\?\\C:\\" "\\??\\C:\\" \
        "\\\\.\\" "//./" "//?/" "\\\\?\\" "1:" "\\\\?\\UNC\\s\\t" "z:"]]
    set s $prefix[randomWinSegments [rand 4]]
    if {$s eq ""} { set s a }
    return $s
}

proc randomWinComponent {} {
    set prefix [pick [list "" "" "" "" "" "\\" "/" "C:" "1:" "\\\\s\\t"]]
    return $prefix[randomWinSegments [expr {1 + [rand 3]}]]
}

# UTF-16 units: mostly ASCII and BMP, some astral pairs, some lone
# surrogates.
proc randomUnits {} {
    set units {}
    for {set i [expr {1 + [rand 8]}]} {$i > 0} {incr i -1} {
        switch [rand 6] {
            0 { lappend units [expr {55296 + [rand 1024]}] }
            1 { lappend units [expr {56320 + [rand 1024]}] }
            2 { lappend units [expr {55296 + [rand 1024]}] [expr {56320 + [rand 1024]}] }
            3 { lappend units [expr {160 + [rand 55000]}] }
            default { lappend units [expr {33 + [rand 90]}] }
        }
    }
    return $units
}

# The text of UNITS (a list of scalars) or {} when one is unpaired; and the
# display (U+FFFD for each unpaired surrogate).
proc unitsDecode {units} {
    set scalars {}
    set shown {}
    set ok 1
    for {set i 0} {$i < [llength $units]} {incr i} {
        set u [lindex $units $i]
        set next [lindex $units [expr {$i + 1}]]
        if {$u >= 55296 && $u < 56320 && $next ne "" && $next >= 56320 && $next < 57344} {
            set s [expr {65536 + (($u - 55296) << 10) + ($next - 56320)}]
            lappend scalars $s; lappend shown $s
            incr i
        } elseif {$u >= 55296 && $u < 57344} {
            set ok 0
            lappend shown 65533
        } else {
            lappend scalars $u; lappend shown $u
        }
    }
    set text [join [lmap s $scalars {format %c $s}] ""]
    set display [join [lmap s $shown {format %c $s}] ""]
    return [list $ok $text $display]
}

proc windowsPart {} {
    global n
    set pairs {}
    for {set i 0} {$i < $n} {incr i} {
        lappend pairs [list [randomWinBase] [randomWinComponent]]
    }
    set unitCases {}
    for {set i 0} {$i < $n} {incr i} {
        lappend unitCases [randomUnits]
    }
    set calls [join [lmap p $pairs {string cat "pair([literal [lindex $p 0]], [literal [lindex $p 1]])"}] ",\n        "]
    set ucalls [join [lmap u $unitCases {string cat "units(\[[join $u {, }]\])"}] ",\n        "]
    set text "import std::io::path
import std::list
import std::str
import std::windows::fs
import std::windows::path

fn kind_name(k: std::windows::fs::PathKind) -> str:
    if k == std::windows::fs::PathKind::Relative:
        \"Relative\"
    elif k == std::windows::fs::PathKind::DriveRelative:
        \"DriveRelative\"
    elif k == std::windows::fs::PathKind::DriveAbsolute:
        \"DriveAbsolute\"
    elif k == std::windows::fs::PathKind::RootRelative:
        \"RootRelative\"
    elif k == std::windows::fs::PathKind::Unc:
        \"Unc\"
    elif k == std::windows::fs::PathKind::Device:
        \"Device\"
    else:
        \"Verbatim\"

fn joined_text(base: str, part: str) -> str:
    std::windows::path::validate(base):
        on std::io::path::NotAPath:
            return \"invalid\"
    r = std::windows::path::concat(base, part):
        on std::io::path::NotAPath:
            return \"NotAPath\"
    r

fn native_joined(base: str, part: str) -> str:
    b = std::windows::fs::from_text(base):
        on std::io::path::NotAPath:
            return \"invalid\"
    c = std::windows::fs::from_text(part):
        on std::io::path::NotAPath:
            return \"NotAPath\"
    j = std::windows::fs::join(b, c):
        on std::io::path::NotAPath:
            return \"NotAPath\"
    std::windows::fs::text(j):
        on std::io::path::NotText:
            return \"NotText\"

fn pair(base: str, part: str) -> List\[str\]:
    b = std::windows::fs::from_text(base):
        on std::io::path::NotAPath:
            return \[\"invalid\"\]
    \[kind_name(std::windows::fs::kind(b)), joined_text(base, part), native_joined(base, part)\]

fn units(us: List\[int\]) -> List\[any\]:
    p = std::windows::fs::from_units(us):
        on std::io::path::NotAPath:
            return \[\"NotAPath\"\]
    t = std::windows::fs::text(p):
        on std::io::path::NotText:
            return \[0, std::windows::fs::display(p)\]
    back = std::windows::fs::from_text(t):
        on std::io::path::NotAPath:
            return \[\"round trip refused\"\]
    \[1, t, std::windows::fs::units(back) == us, std::windows::fs::display(p)\]

\[\[$calls\],
    \[$ucalls\]\]
"
    if {[catch {build $text windows-x86_64} hir]} {
        report windows program compiles $hir
        if {[dict get $::options -verbose]} { puts $text }
        return
    }
    foreach backend {interp compile} {
        lassign [outcome $backend $hir] kind value
        if {$kind ne "value"} {
            report windows $backend value $value
            continue
        }
        lassign $value got gotUnits
        foreach p $pairs g $got {
            incr ::cases
            lassign $p base comp
            set want [winConcat $base $comp]
            set expected [list [winKind $base] $want $want]
            if {$g ne $expected} {
                report windows "[list $base $comp] ($backend)" $expected $g
            }
        }
        foreach u $unitCases g $gotUnits {
            incr ::cases
            lassign [unitsDecode $u] ok text display
            set expected [expr {$ok ? [list 1 $text 1 $display] : [list 0 $display]}]
            set g [lmap x $g {expr {$x eq "true" ? 1 : $x}}]
            if {$g ne $expected} {
                report windows "units [list $u] ($backend)" $expected $g
            }
        }
    }
}

# ---------------------------------------------------------------------------
# The Linux model

proc linuxConcat {base comp} {
    if {$comp eq "" || [string first \u0000 $comp] >= 0 || [string index $comp 0] eq "/"} { return NotAPath }
    if {[string index $base end] eq "/"} { return $base$comp }
    return "$base/$comp"
}

proc randomLinux {} {
    set s [pick [list "" "" "/" "." ".." "a/"]]
    for {set i [rand 4]} {$i > 0} {incr i -1} {
        append s [pick [list a b . .. / // é 𝄞 "x y" \\]]
    }
    return $s
}

# Random bytes, some sequences not UTF-8.
proc randomBytes {} {
    set out {}
    for {set i [expr {1 + [rand 8]}]} {$i > 0} {incr i -1} {
        switch [rand 4] {
            0 { lappend out [expr {128 + [rand 128]}] }
            1 { lappend out 195 [expr {128 + [rand 64]}] }
            default { lappend out [expr {32 + [rand 95]}] }
        }
    }
    return $out
}

# Whether BYTES are UTF-8 (strict: Tcl 9's strict profile), and the string.
proc bytesDecode {bytes} {
    set raw [binary format c* $bytes]
    if {[catch {encoding convertfrom -profile strict utf-8 $raw} text]} {
        return [list 0 ""]
    }
    return [list 1 $text]
}

proc linuxPart {} {
    global n
    set pairs {}
    for {set i 0} {$i < $n} {incr i} {
        set base [randomLinux]
        if {$base eq ""} { set base a }
        lappend pairs [list $base [randomLinux]]
    }
    set byteCases {}
    for {set i 0} {$i < $n} {incr i} {
        lappend byteCases [randomBytes]
    }
    set calls [join [lmap p $pairs {string cat "pair([literal [lindex $p 0]], [literal [lindex $p 1]])"}] ",\n        "]
    set bcalls [join [lmap b $byteCases {string cat "bytes(\[[join $b {, }]\])"}] ",\n        "]
    set text "import std::byte
import std::io::path
import std::linux::fs
import std::linux::path
import std::list
import std::str

fn joined_text(base: str, part: str) -> str:
    std::linux::path::validate(base):
        on std::io::path::NotAPath:
            return \"invalid\"
    r = std::linux::path::concat(base, part):
        on std::io::path::NotAPath:
            return \"NotAPath\"
    r

fn native_joined(base: str, part: str) -> str:
    b = std::linux::fs::from_text(base):
        on std::io::path::NotAPath:
            return \"invalid\"
    c = std::linux::fs::from_text(part):
        on std::io::path::NotAPath:
            return \"NotAPath\"
    j = std::linux::fs::join(b, c):
        on std::io::path::NotAPath:
            return \"NotAPath\"
    std::linux::fs::text(j):
        on std::io::path::NotText:
            return \"NotText\"

fn pair(base: str, part: str) -> List\[str\]:
    \[joined_text(base, part), native_joined(base, part)\]

fn byte_list(xs: List\[int\]) -> List\[std::byte::Byte\]:
    loop x in xs:
        std::byte::from_int(x):
            on std::byte::BelowRange:
                0
            on std::byte::AboveRange:
                0

fn bytes(xs: List\[int\]) -> List\[any\]:
    p = std::linux::fs::from_bytes(byte_list(xs)):
        on std::io::path::NotAPath:
            return \[\"NotAPath\"\]
    t = std::linux::fs::text(p):
        on std::io::path::NotText:
            return \[0\]
    back = std::linux::fs::from_text(t):
        on std::io::path::NotAPath:
            return \[\"round trip refused\"\]
    \[1, t, std::linux::fs::bytes(back) == std::linux::fs::bytes(p)\]

\[\[$calls\],
    \[$bcalls\]\]
"
    if {[catch {build $text linux-x86_64} hir]} {
        report linux program compiles $hir
        if {[dict get $::options -verbose]} { puts $text }
        return
    }
    foreach backend {interp compile} {
        lassign [outcome $backend $hir] kind value
        if {$kind ne "value"} {
            report linux $backend value $value
            continue
        }
        lassign $value got gotBytes
        foreach p $pairs g $got {
            incr ::cases
            lassign $p base comp
            set want [linuxConcat $base $comp]
            if {$g ne [list $want $want]} {
                report linux "[list $base $comp] ($backend)" [list $want $want] $g
            }
        }
        foreach b $byteCases g $gotBytes {
            incr ::cases
            lassign [bytesDecode $b] ok text
            set expected [expr {$ok ? [list 1 $text 1] : [list 0]}]
            set g [lmap x $g {expr {$x eq "true" ? 1 : $x}}]
            if {$g ne $expected} {
                report linux "bytes [list $b] ($backend)" $expected $g
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Files on Linux

proc randomName {} {
    while 1 {
        set out {}
        for {set i [expr {1 + [rand 12]}]} {$i > 0} {incr i -1} {
            set b [expr {1 + [rand 255]}]
            if {$b == 47} continue
            lappend out $b
        }
        if {$out ne {} && $out ne {46} && $out ne {46 46}} {
            return $out
        }
    }
}

proc filesPart {} {
    global n
    set names {}
    while {[llength $names] < $n} {
        set name [randomName]
        if {$name ni $names} { lappend names $name }
    }
    set dir [file join $::scratch files[incr ::programs]]
    file mkdir $dir
    set made [join [lmap name $names {string cat "\[[join $name {, }]\]"}] ",\n        "]
    set text "import std::abi
import std::abi::bytes
import std::byte
import std::int
import std::io::fs
import std::io::path
import std::linux::fs
import std::list
import std::str

fn byte_list(xs: List\[int\]) -> List\[std::byte::Byte\]:
    loop x in xs:
        std::byte::from_int(x):
            on std::byte::BelowRange:
                0
            on std::byte::AboveRange:
                0

fn main() -> List\[any\] errors std::io::fs::FileError, std::io::path::NotAPath:
    dir = std::linux::fs::from_text([literal $dir])
    names = \[
        $made,
    \]
    made = loop i from 0 to names.length():
        name = names.at(i):
            on IndexNotFound:
                \[120\]
        dir.join(std::linux::fs::from_bytes(byte_list(name))).write_file(std::abi::bytes::from_list(i.to_string().encode_utf8()))
    loop e in dir.entries():
        back = std::abi::bytes::decode_utf8(dir.join(e.name).read_file()):
            on InvalidUtf8:
                \"?\"
        \[e.name.bytes(), back\]

with context std::linux::fs::create()
main():
    on std::io::fs::FileError failed:
        \[\"FileError\", failed.code\]
    on std::io::path::NotAPath:
        \[\"NotAPath\"\]
"
    if {[catch {build $text linux-x86_64} hir]} {
        report files program compiles $hir
        return
    }
    set expected [lsort [lmap name $names {list $name [lsearch -exact $names $name]}]]
    foreach backend [dict get $::options -backends] {
        # A fresh, empty directory (rm: names Tcl's strict encoding cannot
        # spell).
        exec rm -rf -- $dir
        file mkdir $dir
        if {[dict get $::options -gc-stress]} {
            set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        }
        lassign [outcome $backend $hir] kind value
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
        incr ::cases [llength $names]
        if {$kind ne "value"} {
            report files $backend value $value
            continue
        }
        if {[lindex $value 0] in {FileError NotAPath}} {
            # The program's own failure (main's handlers), not a listing.
            report files $backend "[llength $expected] names" $value
            continue
        }
        set got [lsort [lmap entry $value {list [lindex $entry 0] [lindex $entry 1]}]]
        if {$got ne $expected} {
            set missing [lmap e $expected {if {$e in $got} continue; set e}]
            set extra [lmap e $got {if {$e in $expected} continue; set e}]
            report files $backend "[llength $expected] names" "[llength $got] names" " (missing [lrange $missing 0 4], extra [lrange $extra 0 4])"
        }
    }
}

foreach part $parts {
    switch -- $part {
        windows { windowsPart }
        linux { linuxPart }
        files {
            if {!$linuxHost} {
                puts "files: skipped (needs a Linux host with the native backend)"
                continue
            }
            filesPart
        }
        default { error "unknown part $part" }
    }
}
# rm on Unix: the files part's names need not be text, and Tcl's strict
# encoding cannot spell them.
if {$::tcl_platform(platform) eq "unix"} {
    exec rm -rf -- $scratch
} else {
    file delete -force $scratch
}
puts "cases $cases disagreements $disagreements"
exit [expr {$disagreements > 0}]
