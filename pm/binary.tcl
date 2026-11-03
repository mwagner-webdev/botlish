# binary.tcl -- native file inspection without execution
# (PACKAGE-MANAGER-MILESTONE-2.md, "Native verification").
#
#   pm::binary::inspect BYTES ?LABEL?    what the bytes are: a dict with
#                                        `kind` and the kind's facts
#
# Kinds and their facts:
#
#   elf       class 32|64, endian le|be, type rel|program|dyn|other, machine N,
#             osabi N, interpreter PATH, soname S, needed {S...},
#             runpath {P...}, rpath {P...}, verneed {LIBRARY {VERSION...}},
#             verdef {VERSION...}, symbols {NAME...} (defined dynamic ones)
#   macho     cputype N, filetype object|execute|dylib|bundle|other,
#             id NAME (LC_ID_DYLIB), needed {NAME...} (every LC_*_DYLIB),
#             rpath {P...}, signed 0|1 (LC_CODE_SIGNATURE), platform N,
#             minos X.Y.Z, symbols {NAME...} (defined external)
#   fat       slices {{cputype N macho FACTS} ...}
#   pe        machine N, dll 0|1, executable 0|1, needed {DLL...} (imports
#             and delay-load imports), name DLL (its export directory's),
#             symbols {NAME...} (exported)
#   coff      machine N (an object file)
#   archive   members {{name N kind K ...facts} ...}: an `ar` archive;
#             each member's kind is elf, macho, coff, import (a short import
#             object: machine N, dll DLL, symbol S), bitcode, symbols (the
#             archive's index), names (GNU's long-name table) or unknown;
#             `index` {SYMBOL...} from a GNU or BSD symbol index
#   thin      a thin archive (it holds no members, only paths)
#   script    a GNU linker script
#   tbd       an Apple text-based stub (.tbd)
#   unknown   anything else (reason R)
#
# Nothing is executed and nothing is loaded: every fact is read from the
# bytes by its format's specification (System V gABI and the GNU symbol
# versioning extension for ELF; Apple's <mach-o/loader.h> and <mach-o/fat.h>;
# Microsoft's PE/COFF specification; ar(5) with GNU's and BSD's index and
# long-name members). A malformed field is {PM BINARY} naming the file and
# where; nothing is guessed. This is the package manager's own reader so
# that it runs where the package manager does (the single-file compiler
# without its native backend); the native driver's archive check
# (codegen/aot.rs's check_static_archive) still judges every archive again
# when a program links it.

namespace eval pm::binary {
    # Bounds on what one inspection reads, against hostile files.
    variable maxCommands 4096
    variable maxSymbols 2000000
    variable maxMembers 100000
}

proc pm::binary::Fail {label message} {
    return -code error -errorcode {PM BINARY} "$label: $message"
}

# Little-endian (or, ENDIAN be, big-endian) unsigned integers of WIDTH bytes
# at OFFSET of DATA; a read past the end fails.
proc pm::binary::U {data offset width label {endian le}} {
    if {$offset < 0 || $offset + $width > [string length $data]} {
        Fail $label "truncated (a $width-byte field at offset $offset of [string length $data] bytes)"
    }
    set code [dict get {1 cu 2 su 4 iu 8 wu} $width]
    if {$endian eq "be"} {
        set code [string toupper [string index $code 0]][string index $code 1]
        if {$width == 1} { set code cu }
    }
    binary scan $data @[expr {$offset}]$code value
    return $value
}

# The NUL-terminated string at OFFSET of DATA (at most LIMIT bytes).
proc pm::binary::CString {data offset label {limit 4096}} {
    if {$offset < 0 || $offset >= [string length $data]} {
        Fail $label "a string offset $offset outside the file"
    }
    # (A bounded slice first: searching the whole file for every string
    # would make reading a large library quadratic.)
    set chunk [string range $data $offset [expr {$offset + $limit}]]
    set end [string first \x00 $chunk]
    if {$end < 0} {
        Fail $label "an unterminated string at offset $offset"
    }
    return [string range $chunk 0 [expr {$end - 1}]]
}

proc pm::binary::inspect {data {label "the file"}} {
    set head [string range $data 0 7]
    if {[string range $head 0 3] eq "\x7fELF"} {
        return [Elf $data $label]
    }
    if {$head eq "!<arch>\n"} {
        return [Archive $data $label]
    }
    if {$head eq "!<thin>\n"} {
        return [dict create kind thin]
    }
    set magic [string range $data 0 3]
    if {$magic in [list "\xcf\xfa\xed\xfe" "\xce\xfa\xed\xfe"]} {
        return [MachO $data $label]
    }
    if {$magic in [list "\xca\xfe\xba\xbe" "\xca\xfe\xba\xbf"]} {
        set count [U $data 4 4 $label be]
        if {$count > 0 && $count < 64} {
            return [Fat $data $label]
        }
    }
    if {[string range $data 0 1] eq "MZ"} {
        return [Pe $data $label]
    }
    if {[string range $data 0 3] eq "BC\xc0\xde" || [string range $data 0 3] eq "\xde\xc0\x17\x0b"} {
        return [dict create kind bitcode]
    }
    set text [string range $data 0 255]
    if {[string match "--- !tapi-tbd*" $text] || [string match "---*tbd-version*" $text]
            || [string match "*\ninstall-name:*" $text]} {
        return [dict create kind tbd]
    }
    if {[regexp {^\s*(/\*[^*]*\*/\s*)?(GROUP|INPUT|OUTPUT_FORMAT|SEARCH_DIR)\s*\(} $text]} {
        return [dict create kind script]
    }
    set coff [CoffObject $data $label]
    if {$coff ne ""} {
        return $coff
    }
    return [dict create kind unknown reason "no known native file format"]
}

# ---------------------------------------------------------------------------
# ELF

proc pm::binary::Elf {data label} {
    variable maxSymbols
    set class [U $data 4 1 $label]
    set order [U $data 5 1 $label]
    set osabi [U $data 7 1 $label]
    set endian [expr {$order == 2 ? "be" : "le"}]
    set type [U $data 16 2 $label $endian]
    set machine [U $data 18 2 $label $endian]
    set typeName [dict getdef {1 rel 2 program 3 dyn} $type other]
    set facts [dict create kind elf class [expr {$class == 2 ? 64 : 32}] endian $endian type $typeName \
        machine $machine osabi $osabi interpreter "" soname "" needed {} runpath {} rpath {} \
        verneed {} verdef {} symbols {}]
    if {$class != 2 || $endian ne "le"} {
        # No target of the compiler's is 32-bit or big-endian: the identity
        # facts suffice to refuse it.
        return $facts
    }
    set phoff [U $data 32 8 $label]
    set shoff [U $data 40 8 $label]
    set phentsize [U $data 54 2 $label]
    set phnum [U $data 56 2 $label]
    set shentsize [U $data 58 2 $label]
    set shnum [U $data 60 2 $label]
    # Program headers: the loadable segments (to map addresses to file
    # offsets), the interpreter and the dynamic segment.
    set loads {}
    set dynamic ""
    for {set i 0} {$i < $phnum} {incr i} {
        set at [expr {$phoff + $i * $phentsize}]
        set ptype [U $data $at 4 $label]
        set offset [U $data [expr {$at + 8}] 8 $label]
        set vaddr [U $data [expr {$at + 16}] 8 $label]
        set filesz [U $data [expr {$at + 32}] 8 $label]
        switch -- $ptype {
            1 { lappend loads [list $vaddr $offset $filesz] }
            2 { set dynamic [list $offset $filesz] }
            3 { dict set facts interpreter [CString $data $offset $label] }
        }
    }
    if {$dynamic ne ""} {
        lassign $dynamic dynOffset dynSize
        set entries {}
        set strtab ""
        for {set at $dynOffset} {$at + 16 <= $dynOffset + $dynSize} {incr at 16} {
            set tag [U $data $at 8 $label]
            set value [U $data [expr {$at + 8}] 8 $label]
            if {$tag == 0} break
            lappend entries $tag $value
            if {$tag == 5} {
                set strtab [Offset $loads $value $label]
            }
        }
        if {$strtab eq "" && $entries ne ""} {
            Fail $label "a dynamic section without a string table (DT_STRTAB)"
        }
        set verneed ""
        set verneedNum 0
        set verdef ""
        set verdefNum 0
        foreach {tag value} $entries {
            switch -- $tag {
                1  { dict lappend facts needed [CString $data [expr {$strtab + $value}] $label] }
                14 { dict set facts soname [CString $data [expr {$strtab + $value}] $label] }
                15 { dict set facts rpath [split [CString $data [expr {$strtab + $value}] $label] :] }
                29 { dict set facts runpath [split [CString $data [expr {$strtab + $value}] $label] :] }
                1879048190 { set verneed [Offset $loads $value $label] }
                1879048191 { set verneedNum $value }
                1879048188 { set verdef [Offset $loads $value $label] }
                1879048189 { set verdefNum $value }
            }
        }
        # GNU symbol versioning: what each needed library must define
        # (GLIBC_2.34, ...) and what this one defines.
        set at $verneed
        for {set i 0} {$verneed ne "" && $i < $verneedNum && $i < 256} {incr i} {
            set count [U $data [expr {$at + 2}] 2 $label]
            set file [CString $data [expr {$strtab + [U $data [expr {$at + 4}] 4 $label]}] $label]
            set aux [expr {$at + [U $data [expr {$at + 8}] 4 $label]}]
            set versions {}
            for {set j 0} {$j < $count && $j < 1024} {incr j} {
                lappend versions [CString $data [expr {$strtab + [U $data [expr {$aux + 8}] 4 $label]}] $label]
                set next [U $data [expr {$aux + 12}] 4 $label]
                if {$next == 0} break
                incr aux $next
            }
            dict set facts verneed $file [lsort -unique [concat [dict getdef [dict get $facts verneed] $file {}] $versions]]
            set next [U $data [expr {$at + 12}] 4 $label]
            if {$next == 0} break
            incr at $next
        }
        set at $verdef
        for {set i 0} {$verdef ne "" && $i < $verdefNum && $i < 4096} {incr i} {
            set aux [expr {$at + [U $data [expr {$at + 12}] 4 $label]}]
            dict lappend facts verdef [CString $data [expr {$strtab + [U $data $aux 4 $label]}] $label]
            set next [U $data [expr {$at + 16}] 4 $label]
            if {$next == 0} break
            incr at $next
        }
    }
    # Defined dynamic symbols (a shared library's exports), from the section
    # table's SHT_DYNSYM.
    if {$shoff > 0 && $shentsize == 64} {
        for {set i 0} {$i < $shnum} {incr i} {
            set at [expr {$shoff + $i * 64}]
            if {[U $data [expr {$at + 4}] 4 $label] != 11} continue
            set offset [U $data [expr {$at + 24}] 8 $label]
            set size [U $data [expr {$at + 32}] 8 $label]
            set link [U $data [expr {$at + 40}] 4 $label]
            set strOffset [U $data [expr {$shoff + $link * 64 + 24}] 8 $label]
            set symbols {}
            set n [expr {$size / 24}]
            if {$n > $maxSymbols} {
                Fail $label "more than $maxSymbols dynamic symbols"
            }
            for {set k 1} {$k < $n} {incr k} {
                set sym [expr {$offset + $k * 24}]
                set info [U $data [expr {$sym + 4}] 1 $label]
                set shndx [U $data [expr {$sym + 6}] 2 $label]
                if {$shndx == 0 || ($info >> 4) ni {1 2}} continue
                lappend symbols [CString $data [expr {$strOffset + [U $data $sym 4 $label]}] $label]
            }
            dict set facts symbols [lsort -unique $symbols]
        }
    }
    return $facts
}

# The file offset of the virtual address ADDRESS in the loadable segments
# LOADS.
proc pm::binary::Offset {loads address label} {
    foreach load $loads {
        lassign $load vaddr offset size
        if {$address >= $vaddr && $address < $vaddr + $size} {
            return [expr {$offset + $address - $vaddr}]
        }
    }
    Fail $label "the address [format 0x%x $address] is in no loadable segment"
}

# ---------------------------------------------------------------------------
# Mach-O

proc pm::binary::MachO {data label} {
    variable maxCommands
    set magic [U $data 0 4 $label]
    set cputype [U $data 4 4 $label]
    set filetype [U $data 12 4 $label]
    set ncmds [U $data 16 4 $label]
    set facts [dict create kind macho bits [expr {$magic == 0xfeedfacf ? 64 : 32}] cputype $cputype \
        filetype [dict getdef {1 object 2 execute 6 dylib 8 bundle} $filetype other] \
        id "" needed {} rpath {} signed 0 platform 0 minos "" symbols {}]
    if {$magic != 0xfeedfacf} {
        return $facts
    }
    if {$ncmds > $maxCommands} {
        Fail $label "$ncmds load commands"
    }
    set at 32
    for {set i 0} {$i < $ncmds} {incr i} {
        set cmd [U $data $at 4 $label]
        set size [U $data [expr {$at + 4}] 4 $label]
        if {$size < 8} {
            Fail $label "a load command of $size bytes"
        }
        switch -- $cmd {
            13 { dict set facts id [CString $data [expr {$at + [U $data [expr {$at + 8}] 4 $label]}] $label] }
            12 - 2147483672 - 2147483679 - 32 - 2147483683 {
                dict lappend facts needed [CString $data [expr {$at + [U $data [expr {$at + 8}] 4 $label]}] $label]
            }
            2147483676 { dict lappend facts rpath [CString $data [expr {$at + [U $data [expr {$at + 8}] 4 $label]}] $label] }
            29 { dict set facts signed 1 }
            50 {
                dict set facts platform [U $data [expr {$at + 8}] 4 $label]
                set v [U $data [expr {$at + 12}] 4 $label]
                dict set facts minos "[expr {$v >> 16}].[expr {($v >> 8) & 0xff}].[expr {$v & 0xff}]"
            }
            2 {
                set symoff [U $data [expr {$at + 8}] 4 $label]
                set nsyms [U $data [expr {$at + 12}] 4 $label]
                set stroff [U $data [expr {$at + 16}] 4 $label]
                set symbols {}
                for {set k 0} {$k < $nsyms && $k < 2000000} {incr k} {
                    set sym [expr {$symoff + $k * 16}]
                    set type [U $data [expr {$sym + 4}] 1 $label]
                    if {($type & 0xe0) != 0 || ($type & 0x0e) != 0x0e || ($type & 0x01) == 0} continue
                    set name [CString $data [expr {$stroff + [U $data $sym 4 $label]}] $label]
                    # C symbols carry a leading underscore on Apple targets.
                    if {[string index $name 0] eq "_"} {
                        set name [string range $name 1 end]
                    }
                    lappend symbols $name
                }
                dict set facts symbols [lsort -unique $symbols]
            }
        }
        incr at $size
    }
    return $facts
}

proc pm::binary::Fat {data label} {
    set magic [U $data 0 4 $label be]
    set count [U $data 4 4 $label be]
    set wide [expr {$magic == 0xcafebabf}]
    set slices {}
    for {set i 0} {$i < $count} {incr i} {
        if {$wide} {
            set at [expr {8 + $i * 32}]
            set offset [U $data [expr {$at + 8}] 8 $label be]
            set size [U $data [expr {$at + 16}] 8 $label be]
        } else {
            set at [expr {8 + $i * 20}]
            set offset [U $data [expr {$at + 8}] 4 $label be]
            set size [U $data [expr {$at + 12}] 4 $label be]
        }
        set cputype [U $data $at 4 $label be]
        if {$offset + $size > [string length $data]} {
            Fail $label "a universal slice outside the file"
        }
        set slice [string range $data $offset [expr {$offset + $size - 1}]]
        lappend slices [dict create cputype $cputype facts [inspect $slice "$label (slice [format 0x%x $cputype])"]]
    }
    return [dict create kind fat slices $slices]
}

# ---------------------------------------------------------------------------
# PE/COFF

proc pm::binary::Pe {data label} {
    set lfanew [U $data 0x3c 4 $label]
    if {[string range $data $lfanew [expr {$lfanew + 3}]] ne "PE\x00\x00"} {
        return [dict create kind unknown reason "an MZ header without a PE signature"]
    }
    set coff [expr {$lfanew + 4}]
    set machine [U $data $coff 2 $label]
    set sections [U $data [expr {$coff + 2}] 2 $label]
    set optSize [U $data [expr {$coff + 16}] 2 $label]
    set characteristics [U $data [expr {$coff + 18}] 2 $label]
    set opt [expr {$coff + 20}]
    set facts [dict create kind pe machine $machine dll [expr {($characteristics & 0x2000) != 0}] \
        executable [expr {($characteristics & 0x0002) != 0}] needed {} name "" symbols {} pe32plus 0]
    if {$optSize == 0} {
        return $facts
    }
    set optMagic [U $data $opt 2 $label]
    if {$optMagic == 0x20b} {
        dict set facts pe32plus 1
        set ndirs [U $data [expr {$opt + 108}] 4 $label]
        set dirs [expr {$opt + 112}]
    } else {
        set ndirs [U $data [expr {$opt + 92}] 4 $label]
        set dirs [expr {$opt + 96}]
    }
    set table {}
    set sectionTable [expr {$opt + $optSize}]
    for {set i 0} {$i < $sections} {incr i} {
        set at [expr {$sectionTable + $i * 40}]
        set vsize [U $data [expr {$at + 8}] 4 $label]
        set va [U $data [expr {$at + 12}] 4 $label]
        set rawSize [U $data [expr {$at + 16}] 4 $label]
        set raw [U $data [expr {$at + 20}] 4 $label]
        lappend table [list $va [expr {max($vsize, $rawSize)}] $raw]
    }
    set rva {apply {{table rva label} {
        foreach section $table {
            lassign $section va size raw
            if {$rva >= $va && $rva < $va + $size} {
                return [expr {$raw + $rva - $va}]
            }
        }
        pm::binary::Fail $label "the RVA [format 0x%x $rva] is in no section"
    }}}
    set needed {}
    # Imports (directory 1) and delay-load imports (directory 13).
    foreach {index stride nameAt} {1 20 12 13 32 4} {
        if {$index >= $ndirs} continue
        set dirRva [U $data [expr {$dirs + $index * 8}] 4 $label]
        if {$dirRva == 0} continue
        set at [{*}$rva $table $dirRva $label]
        for {set k 0} {$k < 4096} {incr k} {
            set nameRva [U $data [expr {$at + $nameAt}] 4 $label]
            if {$nameRva == 0} break
            lappend needed [CString $data [{*}$rva $table $nameRva $label] $label]
            incr at $stride
        }
    }
    dict set facts needed $needed
    if {$ndirs > 0} {
        set exportRva [U $data $dirs 4 $label]
        if {$exportRva != 0} {
            set at [{*}$rva $table $exportRva $label]
            dict set facts name [CString $data [{*}$rva $table [U $data [expr {$at + 12}] 4 $label] $label] $label]
            set count [U $data [expr {$at + 24}] 4 $label]
            set names [{*}$rva $table [U $data [expr {$at + 32}] 4 $label] $label]
            set symbols {}
            for {set k 0} {$k < $count && $k < 1000000} {incr k} {
                lappend symbols [CString $data [{*}$rva $table [U $data [expr {$names + 4 * $k}] 4 $label] $label] $label]
            }
            dict set facts symbols [lsort -unique $symbols]
        }
    }
    return $facts
}

# A COFF object or import object at the start of DATA, or "" when DATA is
# not plausibly one.
proc pm::binary::CoffObject {data label} {
    if {[string length $data] < 20} {
        return ""
    }
    binary scan $data susu first second
    if {$first == 0 && $second == 0xffff} {
        binary scan $data @4su version
        binary scan $data @6su machine
        if {$version == 0} {
            # A short import object: a DLL's symbol, as MSVC's import
            # libraries (and llvm-dlltool's) hold them.
            binary scan $data @12iu dataSize
            set symbol [CString $data 20 $label]
            set dll [CString $data [expr {20 + [string length $symbol] + 1}] $label]
            return [dict create kind import machine $machine dll $dll symbol $symbol]
        }
        # An extended ("bigobj") COFF object.
        return [dict create kind coff machine $machine sections {}]
    }
    set machine $first
    # (x86-64, ARM64, i386, ARMv7: compared as numbers.)
    if {[lsearch -exact -integer {34404 43620 332 452} $machine] < 0} {
        return ""
    }
    binary scan $data @2su count
    binary scan $data @16su optSize
    if {$optSize != 0 || $count > 4096 || 20 + 40 * $count > [string length $data]} {
        return ""
    }
    set sections {}
    for {set i 0} {$i < $count} {incr i} {
        set at [expr {20 + 40 * $i}]
        set name [string trimright [string range $data $at [expr {$at + 7}]] \x00]
        binary scan $data @[expr {$at + 16}]iuiu rawSize raw
        lappend sections [list $name $raw $rawSize]
    }
    set facts [dict create kind coff machine $machine sections [lmap s $sections {lindex $s 0}]]
    # A long-format import object (MinGW's dlltool, MSVC's import
    # descriptor): its .idata$7 or .idata$6 names the DLL.
    foreach section $sections {
        lassign $section name raw rawSize
        if {$name in {.idata$7 .idata$6} && $rawSize > 0 && $raw + $rawSize <= [string length $data]} {
            set text [string range $data $raw [expr {$raw + $rawSize - 1}]]
            if {[regexp -nocase {([A-Za-z0-9_.+-]+\.dll)} $text -> dll]} {
                dict set facts dll $dll
            }
        }
    }
    return $facts
}

# ---------------------------------------------------------------------------
# ar archives

proc pm::binary::Archive {data label} {
    variable maxMembers
    set members {}
    set index {}
    set names ""
    set at 8
    set length [string length $data]
    while {$at < $length} {
        if {$at + 60 > $length} {
            Fail $label "a truncated member header at offset $at"
        }
        set header [string range $data $at [expr {$at + 59}]]
        if {[string range $header 58 59] ne "`\n"} {
            Fail $label "a member header without its terminator at offset $at"
        }
        set rawName [string trimright [string range $header 0 15] " "]
        set sizeText [string trim [string range $header 48 57]]
        if {![string is digit -strict $sizeText]} {
            Fail $label "a member size \"$sizeText\" at offset $at"
        }
        set size [scan $sizeText %lld]
        set start [expr {$at + 60}]
        if {$start + $size > $length} {
            Fail $label "a member running past the end of the archive (offset $at)"
        }
        set body [string range $data $start [expr {$start + $size - 1}]]
        set name $rawName
        if {$rawName in {/ /SYM64/}} {
            lappend members [dict create name $rawName kind symbols]
            if {$rawName eq "/" && [string length $body] >= 4} {
                # GNU's index: a big-endian count, offsets, names.
                set count [U $body 0 4 $label be]
                set strings [expr {4 + 4 * $count}]
                set position $strings
                for {set i 0} {$i < $count && $position < [string length $body]} {incr i} {
                    set symbol [CString $body $position $label]
                    lappend index $symbol
                    incr position [expr {[string length $symbol] + 1}]
                }
            }
        } elseif {$rawName eq "//"} {
            set names $body
            lappend members [dict create name // kind names]
        } else {
            if {[regexp {^/([0-9]+)$} $rawName -> offset]} {
                set end [string first "/\n" $names $offset]
                if {$end < 0} {
                    Fail $label "a long member name outside the name table"
                }
                set name [string range $names $offset [expr {$end - 1}]]
            } elseif {[regexp {^#1/([0-9]+)$} $rawName -> nameLength]} {
                set name [string trimright [string range $body 0 [expr {$nameLength - 1}]] \x00]
                set body [string range $body $nameLength end]
            } else {
                set name [string trimright $name /]
            }
            if {$name in {__.SYMDEF {__.SYMDEF SORTED} __.SYMDEF_64 {__.SYMDEF_64 SORTED}}} {
                lappend members [dict create name $name kind symbols]
            } else {
                set facts [inspect $body "${label}($name)"]
                lappend members [dict merge $facts [dict create name $name]]
            }
        }
        if {[llength $members] > $maxMembers} {
            Fail $label "more than $maxMembers members"
        }
        set at [expr {$start + $size + ($size % 2)}]
    }
    return [dict create kind archive members $members index [lsort -unique $index]]
}

# ---------------------------------------------------------------------------
# Descriptions

# A short description of the facts FACTS ("ELF x86-64 shared library",
# "Mach-O arm64 dynamic library", "PE x86-64 DLL", "ar archive of 12 ELF
# x86-64 objects", ...).
proc pm::binary::describe {facts} {
    set machines {62 x86-64 183 AArch64 3 i386 40 ARM}
    switch -- [dict get $facts kind] {
        elf {
            set what [dict getdef {rel object program executable dyn {shared object} other file} [dict get $facts type] file]
            if {[dict get $facts class] != 64 || [dict get $facts endian] ne "le"} {
                return "ELF [dict get $facts class]-bit [dict get $facts endian] $what (machine [dict get $facts machine])"
            }
            return "ELF [dict getdef $machines [dict get $facts machine] "machine [dict get $facts machine]"] $what"
        }
        macho {
            set cpu [dict getdef {16777223 x86_64 16777228 arm64} [dict get $facts cputype] [format "cputype 0x%x" [dict get $facts cputype]]]
            return "Mach-O $cpu [dict get {object object execute executable dylib {dynamic library} bundle bundle other file} [dict get $facts filetype]]"
        }
        fat {
            return "universal Mach-O ([join [lmap s [dict get $facts slices] {describe [dict get $s facts]}] {, }])"
        }
        pe {
            set cpu [dict getdef {34404 x86-64 43620 ARM64 332 i386} [dict get $facts machine] [format "machine 0x%x" [dict get $facts machine]]]
            return "PE $cpu [expr {[dict get $facts dll] ? {DLL} : {executable}}]"
        }
        coff {
            return "COFF [dict getdef {34404 x86-64 43620 ARM64 332 i386} [dict get $facts machine] machine] object"
        }
        import { return "an import object of [dict get $facts dll]" }
        archive {
            set kinds [dict create]
            foreach member [dict get $facts members] {
                set kind [dict get $member kind]
                if {$kind in {symbols names}} continue
                dict incr kinds [describe $member]
            }
            if {[dict size $kinds] == 0} {
                return "an ar archive with no object"
            }
            return "an ar archive of [join [lmap {k n} $kinds {string cat "$n $k"}] {, }]"
        }
        thin { return "a thin ar archive (members by path only)" }
        script { return "a GNU linker script" }
        tbd { return "an Apple text-based stub (.tbd)" }
        bitcode { return "LLVM bitcode" }
    }
    return "an unknown file ([dict getdef $facts reason {no known format}])"
}

# The sections of a 64-bit little-endian ELF file DATA, for provenance and
# the comparison of release candidates (PACKAGE-MANAGER-MILESTONE-3.md):
# {sections {{name N type T offset O size S} ...} buildid HEX comment
# {TEXT...}} -- the section table by name (SHT_NOBITS sections have no file
# bytes: size 0), the GNU build ID (NT_GNU_BUILD_ID) and the strings of
# .comment (the producing compilers' identities). Read, never run.
proc pm::binary::elfSections {data {label "the file"}} {
    variable maxCommands
    if {[string range $data 0 3] ne "\x7fELF" || [U $data 4 1 $label] != 2 || [U $data 5 1 $label] != 1} {
        Fail $label "not a 64-bit little-endian ELF file"
    }
    set shoff [U $data 40 8 $label]
    set shentsize [U $data 58 2 $label]
    set shnum [U $data 60 2 $label]
    set shstrndx [U $data 62 2 $label]
    set result [dict create sections {} buildid "" comment {}]
    if {$shoff == 0 || $shentsize != 64 || $shnum == 0} {
        return $result
    }
    if {$shnum > $maxCommands} {
        Fail $label "more than $maxCommands sections"
    }
    if {$shstrndx >= $shnum} {
        Fail $label "a section-name table index $shstrndx outside the $shnum sections"
    }
    set names [U $data [expr {$shoff + $shstrndx * 64 + 24}] 8 $label]
    set sections {}
    for {set i 0} {$i < $shnum} {incr i} {
        set at [expr {$shoff + $i * 64}]
        set nameOffset [U $data $at 4 $label]
        set type [U $data [expr {$at + 4}] 4 $label]
        set offset [U $data [expr {$at + 24}] 8 $label]
        set size [U $data [expr {$at + 32}] 8 $label]
        set name [expr {$i == 0 ? "" : [CString $data [expr {$names + $nameOffset}] $label 256]}]
        if {$type == 8} {
            set size 0
        } elseif {$offset + $size > [string length $data]} {
            Fail $label "the section $name ends past the end of the file"
        }
        lappend sections [dict create name $name type $type offset $offset size $size]
        if {$name eq ".comment"} {
            foreach text [split [string range $data $offset [expr {$offset + $size - 1}]] \x00] {
                if {$text ne ""} { dict lappend result comment $text }
            }
        }
        if {$type == 7 && $size >= 16} {
            # Notes: namesz, descsz, type, name (4-aligned), desc.
            set note $offset
            while {$note + 12 <= $offset + $size} {
                set namesz [U $data $note 4 $label]
                set descsz [U $data [expr {$note + 4}] 4 $label]
                set ntype [U $data [expr {$note + 8}] 4 $label]
                set nameAt [expr {$note + 12}]
                set descAt [expr {$nameAt + (($namesz + 3) & ~3)}]
                if {$descAt + $descsz > $offset + $size} break
                if {$ntype == 3 && [string range $data $nameAt [expr {$nameAt + 3}]] eq "GNU\x00"} {
                    dict set result buildid [binary encode hex [string range $data $descAt [expr {$descAt + $descsz - 1}]]]
                }
                set note [expr {$descAt + (($descsz + 3) & ~3)}]
            }
        }
    }
    dict set result sections $sections
    return $result
}
