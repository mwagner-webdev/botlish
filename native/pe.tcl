# pe.tcl -- the facts of a Windows x86-64 DLL and of its import library, as
# a native library's link made them, read from their bytes
# (WINDOWS-X86-64-MILESTONE-8.md, "Validating the artifacts").
#
#   native::pe::facts PATH
#       a dict: machine N (the COFF header's Machine), dll 0|1
#       (IMAGE_FILE_DLL), pe32plus 0|1, dllCharacteristics N, subsystem N,
#       entry RVA (AddressOfEntryPoint), sections {{NAME CHARACTERISTICS}
#       ...}, exportName NAME (the export directory's DLL name), exports
#       {NAME ...} (every name of the export name table, in its order),
#       exportFunctions N (NumberOfFunctions: entries by name or by ordinal
#       only), forwarders {NAME ...} (exports that forward to another DLL),
#       imports {DLL ...} (the import directory's, then the delay-load
#       directory's), functions {DLL {NAME ...} ...} (imported by name;
#       #ORDINAL by ordinal), tls 0|1 (a TLS directory), tlsCallbacks
#       {RVA ...} (its AddressOfCallBacks array, as image-relative
#       addresses), imageBase N
#
#   native::pe::importLibrary PATH
#       the import library PATH (a COFF archive, `!<arch>\n`): a dict
#       {imports {{SYMBOL DLL TYPE} ...} objects N}, one element per short
#       import object (Microsoft PE/COFF, "Import Library Format"): the
#       symbol it defines, the DLL it names and its type (code, data,
#       const), and how many members are full COFF objects (the import
#       descriptor, the null descriptor and thunk data link.exe writes)
#
# Nothing is run and nothing is loaded: every fact is the PE/COFF
# specification's, read from the file. A file that is not a PE32+ image (or
# an import library), or whose tables point outside it, is {NATIVE LIBRARY
# PE} naming where. The checks native::library makes of these facts are its
# own (`ValidateDll`); this file only reads.

namespace eval native::pe {}

proc native::pe::Fail {path message} {
    return -code error -errorcode {NATIVE LIBRARY PE} "native::library: $path: $message"
}

proc native::pe::U {data offset width path} {
    set offset [expr {$offset}]
    if {$offset < 0 || $offset + $width > [string length $data]} {
        Fail $path "truncated: a $width-byte field at offset $offset of [string length $data] bytes"
    }
    binary scan $data @${offset}[dict get {1 cu 2 su 4 iu 8 wu} $width] value
    return $value
}

proc native::pe::CString {data offset path} {
    set end [string first \x00 $data $offset]
    if {$offset < 0 || $end < 0} {
        Fail $path "a string at offset $offset is not terminated"
    }
    return [string range $data $offset [expr {$end - 1}]]
}

proc native::pe::Read {path} {
    set channel [open $path rb]
    try {
        return [read $channel]
    } finally {
        close $channel
    }
}

# The file offset of image-relative address RVA in the sections TABLE
# ({VA SIZE RAW} each).
proc native::pe::Offset {table rva path} {
    foreach section $table {
        lassign $section va size raw
        if {$rva >= $va && $rva < $va + $size} {
            return [expr {$raw + $rva - $va}]
        }
    }
    Fail $path "the address [format 0x%x $rva] is in no section"
}

proc native::pe::facts {path} {
    set data [Read $path]
    if {[string range $data 0 1] ne "MZ"} {
        Fail $path "not a PE image (no MZ header)"
    }
    set lfanew [U $data 0x3c 4 $path]
    if {[string range $data $lfanew [expr {$lfanew + 3}]] ne "PE\x00\x00"} {
        Fail $path "no PE signature at [format 0x%x $lfanew]"
    }
    set coff [expr {$lfanew + 4}]
    set machine [U $data $coff 2 $path]
    set count [U $data [expr {$coff + 2}] 2 $path]
    set optSize [U $data [expr {$coff + 16}] 2 $path]
    set characteristics [U $data [expr {$coff + 18}] 2 $path]
    set opt [expr {$coff + 20}]
    if {$optSize < 112 || [U $data $opt 2 $path] != 0x20b} {
        Fail $path "not a PE32+ image"
    }
    set entry [U $data [expr {$opt + 16}] 4 $path]
    set imageBase [U $data [expr {$opt + 24}] 8 $path]
    set subsystem [U $data [expr {$opt + 68}] 2 $path]
    set dllCharacteristics [U $data [expr {$opt + 70}] 2 $path]
    set ndirs [U $data [expr {$opt + 108}] 4 $path]
    set dirs [expr {$opt + 112}]
    set directory {apply {{data dirs ndirs index path} {
        if {$index >= $ndirs} { return {0 0} }
        list [native::pe::U $data [expr {$dirs + 8 * $index}] 4 $path] [native::pe::U $data [expr {$dirs + 8 * $index + 4}] 4 $path]
    }}}
    set table {}
    set sections {}
    set sectionTable [expr {$opt + $optSize}]
    for {set i 0} {$i < $count} {incr i} {
        set at [expr {$sectionTable + 40 * $i}]
        set name [string trimright [string range $data $at [expr {$at + 7}]] \x00]
        set vsize [U $data [expr {$at + 8}] 4 $path]
        set va [U $data [expr {$at + 12}] 4 $path]
        set rawSize [U $data [expr {$at + 16}] 4 $path]
        set raw [U $data [expr {$at + 20}] 4 $path]
        lappend table [list $va [expr {max($vsize, $rawSize)}] $raw]
        lappend sections [list $name [U $data [expr {$at + 36}] 4 $path]]
    }

    # Exports (directory 0): the DLL's name, the name table (sorted by the
    # linker, which the loader's binary search needs), the address table's
    # size, and every address inside the export directory: a forwarder.
    set exportName ""
    set exports {}
    set exportFunctions 0
    set forwarders {}
    lassign [{*}$directory $data $dirs $ndirs 0 $path] exportRva exportSize
    if {$exportRva != 0} {
        set at [Offset $table $exportRva $path]
        set exportName [CString $data [Offset $table [U $data [expr {$at + 12}] 4 $path] $path] $path]
        set exportFunctions [U $data [expr {$at + 20}] 4 $path]
        set names [U $data [expr {$at + 24}] 4 $path]
        set addresses [Offset $table [U $data [expr {$at + 28}] 4 $path] $path]
        set nameTable [U $data [expr {$at + 32}] 4 $path]
        set ordinals [U $data [expr {$at + 36}] 4 $path]
        if {$names > 0} {
            set nameTable [Offset $table $nameTable $path]
            set ordinals [Offset $table $ordinals $path]
        }
        for {set k 0} {$k < $names && $k < 1000000} {incr k} {
            set name [CString $data [Offset $table [U $data [expr {$nameTable + 4 * $k}] 4 $path] $path] $path]
            lappend exports $name
            set ordinal [U $data [expr {$ordinals + 2 * $k}] 2 $path]
            set target [U $data [expr {$addresses + 4 * $ordinal}] 4 $path]
            if {$target >= $exportRva && $target < $exportRva + $exportSize} {
                lappend forwarders $name
            }
        }
    }

    # Imports (directory 1: 20-byte descriptors, the name at 12, the lookup
    # table at 0 or the address table at 16) and delay-load imports
    # (directory 13: 32-byte descriptors, the name at 4, the name table at
    # 16).
    set imports {}
    set functions [dict create]
    foreach {index stride nameAt lookupAt fallbackAt} {1 20 12 0 16 13 32 4 16 16} {
        lassign [{*}$directory $data $dirs $ndirs $index $path] dirRva
        if {$dirRva == 0} continue
        set at [Offset $table $dirRva $path]
        for {set k 0} {$k < 4096} {incr k} {
            set nameRva [U $data [expr {$at + $nameAt}] 4 $path]
            if {$nameRva == 0} break
            set dll [CString $data [Offset $table $nameRva $path] $path]
            lappend imports $dll
            set lookup [U $data [expr {$at + $lookupAt}] 4 $path]
            if {$lookup == 0} {
                set lookup [U $data [expr {$at + $fallbackAt}] 4 $path]
            }
            set names {}
            if {$lookup != 0} {
                set entry [Offset $table $lookup $path]
                for {set n 0} {$n < 100000} {incr n} {
                    set value [U $data $entry 8 $path]
                    if {$value == 0} break
                    if {$value >> 63} {
                        lappend names "#[expr {$value & 0xffff}]"
                    } else {
                        lappend names [CString $data [expr {[Offset $table [expr {$value & 0x7fffffff}] $path] + 2}] $path]
                    }
                    incr entry 8
                }
            }
            dict lappend functions $dll {*}$names
            incr at $stride
        }
    }

    # TLS (directory 9): IMAGE_TLS_DIRECTORY64, AddressOfCallBacks at 24, a
    # virtual address (the image base added) of a null-terminated array of
    # callback addresses.
    set tls 0
    set callbacks {}
    lassign [{*}$directory $data $dirs $ndirs 9 $path] tlsRva
    if {$tlsRva != 0} {
        set tls 1
        set at [Offset $table $tlsRva $path]
        set array [U $data [expr {$at + 24}] 8 $path]
        if {$array != 0} {
            set entry [Offset $table [expr {$array - $imageBase}] $path]
            for {set n 0} {$n < 1024} {incr n} {
                set callback [U $data $entry 8 $path]
                if {$callback == 0} break
                lappend callbacks [expr {$callback - $imageBase}]
                incr entry 8
            }
        }
    }
    return [dict create machine $machine dll [expr {($characteristics & 0x2000) != 0}] pe32plus 1 \
        dllCharacteristics $dllCharacteristics subsystem $subsystem entry $entry sections $sections \
        exportName $exportName exports $exports exportFunctions $exportFunctions forwarders $forwarders \
        imports $imports functions $functions tls $tls tlsCallbacks $callbacks imageBase $imageBase]
}

proc native::pe::importLibrary {path} {
    set data [Read $path]
    if {[string range $data 0 7] ne "!<arch>\n"} {
        Fail $path "not an archive"
    }
    set at 8
    set imports {}
    set objects 0
    while {$at + 60 <= [string length $data]} {
        set header [string range $data $at [expr {$at + 59}]]
        set name [string trimright [string range $header 0 15]]
        set size [string trim [string range $header 48 57]]
        if {![string is integer -strict $size] || [string range $header 58 59] ne "`\n"} {
            Fail $path "a malformed member header at offset $at"
        }
        set start [expr {$at + 60}]
        if {$start + $size > [string length $data]} {
            Fail $path "member $name runs past the end of the archive"
        }
        # The linker members ("/" twice) and the long-name member ("//")
        # index the others; every other member is an object.
        if {$name ni {/ //}} {
            if {[U $data $start 2 $path] == 0 && [U $data [expr {$start + 2}] 2 $path] == 0xffff} {
                # IMPORT_OBJECT_HEADER: Sig1 0, Sig2 0xFFFF, Version, Machine,
                # TimeDateStamp, SizeOfData, Ordinal/Hint, and the type in
                # the low two bits of the 16 bits at 18; then the symbol and
                # the DLL, each NUL-terminated.
                set type [dict getdef {0 code 1 data 2 const} [expr {[U $data [expr {$start + 18}] 2 $path] & 3}] other]
                set symbol [CString $data [expr {$start + 20}] $path]
                set dll [CString $data [expr {$start + 21 + [string length $symbol]}] $path]
                lappend imports [list $symbol $dll $type]
            } else {
                incr objects
            }
        }
        set at [expr {$start + $size + ($size % 2)}]
    }
    return [dict create imports $imports objects $objects]
}
