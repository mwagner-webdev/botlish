# elf.tcl -- the facts of an ELF64 little-endian shared object a native
# library's link made, read from its bytes
# (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, "Android ELF validation").
#
#   native::elf::facts PATH
#       a dict: machine N (e_machine), type dyn|exec|rel|other, loads
#       {{offset O vaddr V filesz F memsz M align A flags X} ...} (every
#       PT_LOAD), needed {NAME...} (DT_NEEDED), soname S, textrel 0|1
#       (DT_TEXTREL, or DF_TEXTREL in DT_FLAGS), verneed {LIBRARY {VERSION...}
#       ...}, exports {NAME...} (defined global or weak function and object
#       symbols of .dynsym), interpreter PATH (PT_INTERP), stackExec 0|1
#       (PT_GNU_STACK with PF_X, or no PT_GNU_STACK at all)
#
# Nothing is run and nothing is loaded: every fact is the System V gABI's and
# the GNU symbol versioning extension's, read from the file. A file that is
# not an ELF64 little-endian object, or whose tables point outside it, is
# {NATIVE LIBRARY ELF} naming where. The checks a target makes of these
# facts are native::library's (`ValidateShared`); this file only reads.

namespace eval native::elf {}

proc native::elf::Fail {path message} {
    return -code error -errorcode {NATIVE LIBRARY ELF} "native::library: $path: $message"
}

proc native::elf::U {data offset width path} {
    if {$offset < 0 || $offset + $width > [string length $data]} {
        Fail $path "truncated: a $width-byte field at offset $offset of [string length $data] bytes"
    }
    binary scan $data @${offset}[dict get {1 cu 2 su 4 iu 8 wu} $width] value
    return $value
}

proc native::elf::CString {data offset path} {
    set end [string first \x00 $data $offset]
    if {$offset < 0 || $end < 0} {
        Fail $path "a string at offset $offset is not terminated"
    }
    return [string range $data $offset [expr {$end - 1}]]
}

proc native::elf::facts {path} {
    set channel [open $path rb]
    set data [read $channel]
    close $channel
    if {[string range $data 0 3] ne "\x7fELF"} {
        Fail $path "not an ELF file"
    }
    if {[U $data 4 1 $path] != 2 || [U $data 5 1 $path] != 1} {
        Fail $path "not a 64-bit little-endian ELF file"
    }
    set type [dict getdef {1 rel 2 exec 3 dyn} [U $data 16 2 $path] other]
    set machine [U $data 18 2 $path]
    set phoff [U $data 32 8 $path]
    set shoff [U $data 40 8 $path]
    set phentsize [U $data 54 2 $path]
    set phnum [U $data 56 2 $path]
    set shentsize [U $data 58 2 $path]
    set shnum [U $data 60 2 $path]

    set loads {}
    set dynamic ""
    set interpreter ""
    set stackExec 1
    for {set i 0} {$i < $phnum} {incr i} {
        set at [expr {$phoff + $i * $phentsize}]
        set ptype [U $data $at 4 $path]
        set flags [U $data [expr {$at + 4}] 4 $path]
        set offset [U $data [expr {$at + 8}] 8 $path]
        set vaddr [U $data [expr {$at + 16}] 8 $path]
        set filesz [U $data [expr {$at + 32}] 8 $path]
        set memsz [U $data [expr {$at + 40}] 8 $path]
        set align [U $data [expr {$at + 48}] 8 $path]
        switch -- $ptype {
            1 { lappend loads [dict create offset $offset vaddr $vaddr filesz $filesz memsz $memsz align $align flags $flags] }
            2 { set dynamic [list $offset $filesz] }
            3 { set interpreter [CString $data $offset $path] }
            1685382481 { set stackExec [expr {($flags & 1) != 0}] }
        }
    }

    # Section headers: .dynsym, its string table and the version tables.
    set sections {}
    for {set i 0} {$i < $shnum} {incr i} {
        set at [expr {$shoff + $i * $shentsize}]
        lappend sections [dict create type [U $data [expr {$at + 4}] 4 $path] \
            offset [U $data [expr {$at + 24}] 8 $path] size [U $data [expr {$at + 32}] 8 $path] \
            link [U $data [expr {$at + 40}] 4 $path] entsize [U $data [expr {$at + 56}] 8 $path]]
    }

    set needed {}
    set soname ""
    set textrel 0
    set verneed {}
    set exports {}
    if {$dynamic ne ""} {
        lassign $dynamic offset size
        set strtab ""
        foreach s $sections {
            if {[dict get $s type] == 6} {
                set strtab [lindex $sections [dict get $s link]]
            }
        }
        if {$strtab eq ""} {
            Fail $path "a dynamic segment without a dynamic section's string table"
        }
        set strings [dict get $strtab offset]
        for {set at $offset} {$at + 16 <= $offset + $size} {incr at 16} {
            set tag [U $data $at 8 $path]
            set value [U $data [expr {$at + 8}] 8 $path]
            switch -- $tag {
                0 break
                1 { lappend needed [CString $data [expr {$strings + $value}] $path] }
                14 { set soname [CString $data [expr {$strings + $value}] $path] }
                22 { set textrel 1 }
                30 { if {$value & 4} { set textrel 1 } }
            }
        }
    }
    foreach s $sections {
        switch -- [dict get $s type] {
            11 {
                # .dynsym: Elf64_Sym {name u32, info u8, other u8, shndx u16, value, size}.
                set names [dict get [lindex $sections [dict get $s link]] offset]
                set count [expr {[dict get $s size] / 24}]
                for {set i 1} {$i < $count} {incr i} {
                    set at [expr {[dict get $s offset] + $i * 24}]
                    set info [U $data [expr {$at + 4}] 1 $path]
                    set shndx [U $data [expr {$at + 6}] 2 $path]
                    set bind [expr {$info >> 4}]
                    set kind [expr {$info & 15}]
                    if {$shndx != 0 && $bind in {1 2} && $kind in {1 2}} {
                        lappend exports [CString $data [expr {$names + [U $data $at 4 $path]}] $path]
                    }
                }
            }
            1879048190 {
                # SHT_GNU_verneed: Elf64_Verneed {version u16, cnt u16, file u32, aux u32, next u32}.
                set names [dict get [lindex $sections [dict get $s link]] offset]
                set at [dict get $s offset]
                while 1 {
                    set count [U $data [expr {$at + 2}] 2 $path]
                    set file [CString $data [expr {$names + [U $data [expr {$at + 4}] 4 $path]}] $path]
                    set aux [expr {$at + [U $data [expr {$at + 8}] 4 $path]}]
                    set versions {}
                    for {set i 0} {$i < $count} {incr i} {
                        lappend versions [CString $data [expr {$names + [U $data [expr {$aux + 8}] 4 $path]}] $path]
                        set aux [expr {$aux + [U $data [expr {$aux + 12}] 4 $path]}]
                    }
                    lappend verneed $file $versions
                    set next [U $data [expr {$at + 12}] 4 $path]
                    if {$next == 0} break
                    incr at $next
                }
            }
        }
    }
    return [dict create machine $machine type $type loads $loads needed $needed soname $soname \
        textrel $textrel verneed $verneed exports [lsort -unique $exports] interpreter $interpreter \
        stackExec $stackExec]
}
