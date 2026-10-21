# binary-header.tcl -- what a native program object or executable file is,
# read from its header: for the tests (tests/helpers.tcl) and the macOS
# port's platform checks (tests/platform/native-status.tcl, aot-facts.tcl).
# Needs core::cabi (core/core.tcl) for hostBinaryHeader.

# {FORMAT ARCHITECTURE KIND} of the object or executable file PATH, read from
# its first bytes: FORMAT elf (64-bit little-endian), macho (64-bit, one
# architecture), coff (a COFF object: Windows') or pe (a PE image: a Windows
# executable or DLL), ARCHITECTURE x86_64, aarch64 (ELF's name) or arm64
# (Mach-O's and COFF's), KIND relocatable, executable or shared (ELF; a PIE
# is shared), object or execute (Mach-O), object (COFF), executable or dll
# (PE); {unknown HEX {}} for anything else.
proc binaryHeader {path} {
    set channel [open $path rb]
    set bytes [read $channel 32]
    close $channel
    if {[string range $bytes 0 1] eq "MZ"} {
        return [peHeader $path]
    }
    # A COFF object's IMAGE_FILE_HEADER is the file's first bytes: Machine
    # (AMD64 0x8664, ARM64 0xaa64), the section count, a timestamp, the
    # symbol table, and SizeOfOptionalHeader, 0 in an object.
    if {[binary scan $bytes susu machine sections] == 2 && $machine in {34404 43620}
            && [binary scan $bytes @16su optional] == 1 && $optional == 0} {
        return [list coff [expr {$machine == 0x8664 ? "x86_64" : "arm64"}] object]
    }
    if {[string range $bytes 0 3] eq "\x7fELF"} {
        binary scan $bytes @4cc@16susu class data type machine
        set arch [expr {$machine == 62 ? "x86_64" : $machine == 183 ? "aarch64" : "machine$machine"}]
        set kind [expr {$type == 1 ? "relocatable" : $type == 2 ? "executable" : $type == 3 ? "shared" : "type$type"}]
        return [list [expr {$class == 2 && $data == 1 ? "elf" : "elf$class-$data"}] $arch $kind]
    }
    if {[binary scan $bytes iuiuiuiu magic cpu - type] == 4 && $magic == 0xfeedfacf} {
        set arch [expr {$cpu == 0x0100000c ? "arm64" : $cpu == 0x01000007 ? "x86_64" : "cpu$cpu"}]
        set kind [expr {$type == 1 ? "object" : $type == 2 ? "execute" : "type$type"}]
        return [list macho $arch $kind]
    }
    return [list unknown [binary encode hex [string range $bytes 0 3]] {}]
}

# The PE image PATH (an MZ file): its "PE\0\0" signature at e_lfanew, then
# the COFF file header's Machine and Characteristics (IMAGE_FILE_DLL,
# 0x2000, tells a DLL from an executable).
proc peHeader {path} {
    set channel [open $path rb]
    try {
        set dos [read $channel 64]
        if {[binary scan $dos @60iu offset] != 1} {
            return [list unknown [binary encode hex [string range $dos 0 3]] {}]
        }
        seek $channel $offset
        set header [read $channel 24]
    } finally {
        close $channel
    }
    if {[string range $header 0 3] ne "PE\0\0" || [binary scan $header @4su@22su machine characteristics] != 2} {
        return [list unknown [binary encode hex [string range $dos 0 3]] {}]
    }
    set arch [expr {$machine == 0x8664 ? "x86_64" : $machine == 0xaa64 ? "arm64" : "machine$machine"}]
    return [list pe $arch [expr {$characteristics & 0x2000 ? "dll" : "executable"}]]
}

# The PE image PATH's facts, read from its headers: a dict {subsystem N
# imports {DLL ...}}, N the optional header's Subsystem (3: the Windows
# console, 2: the GUI) and DLL every DLL its import directory names, in
# order -- what `dumpbin /dependents` lists, read without a tool. Errors for
# a file that is no PE32+ image.
proc peFacts {path} {
    set channel [open $path rb]
    try {
        set bytes [read $channel]
    } finally {
        close $channel
    }
    binary scan $bytes @60iu pe
    if {[string range $bytes $pe [expr {$pe + 3}]] ne "PE\0\0"} {
        error "$path: not a PE image"
    }
    binary scan $bytes @[expr {$pe + 6}]su@[expr {$pe + 20}]su sections optionalSize
    set optional [expr {$pe + 24}]
    binary scan $bytes @${optional}su magic
    if {$magic != 0x20b} {
        error "$path: not a PE32+ image (optional header magic [format 0x%x $magic])"
    }
    binary scan $bytes @[expr {$optional + 68}]su subsystem
    # The data directories follow the PE32+ optional header's 112 fixed
    # bytes; the second (index 1) is the import directory.
    binary scan $bytes @[expr {$optional + 112 + 8}]iuiu importRva importSize
    set table [expr {$optional + $optionalSize}]
    set ranges {}
    for {set i 0} {$i < $sections} {incr i} {
        binary scan $bytes @[expr {$table + 40 * $i + 8}]iuiuiuiu virtualSize virtualAddress rawSize rawPointer
        lappend ranges [list $virtualAddress [expr {max($virtualSize, $rawSize)}] $rawPointer]
    }
    set offsetOf {apply {{ranges rva} {
        foreach range $ranges {
            lassign $range va size raw
            if {$rva >= $va && $rva < $va + $size} { return [expr {$rva - $va + $raw}] }
        }
        error "RVA [format 0x%x $rva] is in no section"
    }}}
    set imports {}
    if {$importRva != 0} {
        set at [{*}$offsetOf $ranges $importRva]
        # IMAGE_IMPORT_DESCRIPTOR: 20 bytes, its Name RVA at 12; an
        # all-zero one ends the table.
        while {[binary scan $bytes @[expr {$at + 12}]iu nameRva] == 1 && $nameRva != 0} {
            set name [{*}$offsetOf $ranges $nameRva]
            set end [string first \0 $bytes $name]
            lappend imports [string range $bytes $name [expr {$end - 1}]]
            incr at 20
        }
    }
    return [dict create subsystem $subsystem imports $imports]
}

# The COFF object PATH's sections, symbols and relocations, read from its
# headers and tables: a dict {sections {NAME ...} symbols {{NAME SECTION
# CLASS} ...} relocations {{SECTION TYPE SYMBOL} ...}}, SECTION a symbol's
# 1-based section number (0: undefined, an import), CLASS its storage class
# (2: external, 3: static), TYPE an IMAGE_REL_AMD64_* name (ADDR64, REL32,
# ...) -- what `dumpbin /symbols /relocations` lists, read without a tool.
proc coffFacts {path} {
    set channel [open $path rb]
    try {
        set bytes [read $channel]
    } finally {
        close $channel
    }
    binary scan $bytes susuiuiuiususu machine count - symbolTable symbolCount optionalSize -
    set strings [expr {$symbolTable + 18 * $symbolCount}]
    set nameOf {apply {{bytes strings field} {
        # An 8-byte name: inline, or /N (a section) or four zero bytes and an
        # offset (a symbol) into the string table.
        if {[string range $field 0 3] eq "\0\0\0\0"} {
            binary scan $field @4iu offset
        } elseif {[string index $field 0] eq "/"} {
            set offset [string trimright [string range $field 1 end] \0]
        } else {
            return [string trimright $field \0]
        }
        set at [expr {$strings + $offset}]
        return [string range $bytes $at [expr {[string first \0 $bytes $at] - 1}]]
    }}}
    set amd64 {0 ABSOLUTE 1 ADDR64 2 ADDR32 3 ADDR32NB 4 REL32 5 REL32_1 6 REL32_2 7 REL32_3 8 REL32_4
        9 REL32_5 10 SECTION 11 SECREL 12 SECREL7 13 TOKEN 14 SREL32 15 PAIR 16 SSPAN32}
    set symbols {}
    set names {}
    for {set i 0} {$i < $symbolCount} {incr i} {
        set at [expr {$symbolTable + 18 * $i}]
        binary scan $bytes @[expr {$at + 12}]sx2cucu section class aux
        set name [{*}$nameOf $bytes $strings [string range $bytes $at [expr {$at + 7}]]]
        lappend symbols [list $name $section $class]
        lappend names $name
        for {set a 0} {$a < $aux} {incr a} { lappend names "" }
        incr i $aux
    }
    set sections {}
    set relocations {}
    for {set i 0} {$i < $count} {incr i} {
        set at [expr {20 + $optionalSize + 40 * $i}]
        set name [{*}$nameOf $bytes $strings [string range $bytes $at [expr {$at + 7}]]]
        lappend sections $name
        binary scan $bytes @[expr {$at + 24}]iu@[expr {$at + 32}]su relocTable relocCount
        for {set r 0} {$r < $relocCount} {incr r} {
            binary scan $bytes @[expr {$relocTable + 10 * $r + 4}]iusu index type
            lappend relocations [list $name [dict getdef $amd64 $type TYPE$type] [lindex $names $index]]
        }
    }
    return [dict create sections $sections symbols $symbols relocations $relocations]
}

# What binaryHeader reports for this host's native program objects (KIND
# object) or standalone executables (KIND executable): the host target's
# object format and architecture.
proc hostBinaryHeader {kind} {
    switch -- [core::cabi::hostTarget] {
        linux-x86_64 { return [list elf x86_64 [expr {$kind eq "object" ? "relocatable" : "shared"}]] }
        linux-aarch64 { return [list elf aarch64 [expr {$kind eq "object" ? "relocatable" : "shared"}]] }
        macos-aarch64 { return [list macho arm64 [expr {$kind eq "object" ? "object" : "execute"}]] }
        windows-x86_64 { return [list [expr {$kind eq "object" ? "coff" : "pe"}] x86_64 [expr {$kind eq "object" ? "object" : "executable"}]] }
        default { return {} }
    }
}
