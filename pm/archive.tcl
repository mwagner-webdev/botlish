# archive.tcl -- the .botpkg archive, format version 1 (BOTPKG-FORMAT.md,
# the normative specification; PACKAGE-MANAGER-MILESTONE-1.md).
#
#   pm::archive::bytes FILES            the archive of FILES (a dict PATH ->
#                                       BYTES), deterministically
#   pm::archive::read PATH ?LIMITS?     every file of a fully validated
#                                       archive: {files {PATH BYTES ...}
#                                       descriptor TEXT size N}
#   pm::archive::descriptorBytes PATH ?LIMITS?   only its botlish.json (the
#                                       structure validated, one entry
#                                       decompressed: for catalogs)
#   pm::archive::pathProblem PATH       "" when PATH is a portable archive
#                                       path, else why not
#
# A .botpkg is a ZIP file in a restricted profile, which this file both
# writes and enforces on read. Its reader trusts nothing in the archive:
# every structural field is checked against the profile, every name against
# the path rules, every size against the limits, before anything is
# decompressed; decompression is streamed and stops at the declared size;
# every file's CRC-32 and size are checked. The reader never touches the
# file system beyond reading the archive: it returns bytes, and the
# installer writes them only under a staging directory it made
# (pm/install.tcl). A failure is {PM ARCHIVE REASON} with a message naming
# the archive and the entry.
#
# The profile (every multi-byte field little-endian, as ZIP's):
#
#   * the file is local headers and their data, back to back from offset 0
#     in the central directory's order, then the central directory, then the
#     22-byte end record: no gap, no prefix, no archive comment, no ZIP64, no
#     multi-disk fields;
#   * entries are regular files only, in strictly increasing byte order of
#     their names (so no name repeats), at least one, botlish.json among
#     them; directories are implied by the paths and have no entries;
#   * each entry: version needed 20, flags 0x0800 (UTF-8 names; nothing
#     else: no encryption, no data descriptor), method 0 (stored) or 8
#     (deflate), time 0 and date 0x0021 (1980-01-01 00:00), no extra field,
#     no comment, disk 0, internal attributes 0, version made by 0x0314
#     (Unix, 2.0), external attributes 0x81A40000 (a regular file, mode
#     0644: no executable, link or device entry), local header fields equal
#     to the central ones;
#   * stored: compressed size = size; deflate: a raw deflate stream, and a
#     file over 64 KiB at most 256 times its compressed size.

namespace eval pm::archive {
    # The limits a reader enforces (BOTPKG-FORMAT.md, "Limits"); a caller
    # may pass lower ones.
    variable limits [dict create \
        archive [expr {256 * 1024 * 1024}] \
        entries 10000 \
        entry [expr {64 * 1024 * 1024}] \
        total [expr {256 * 1024 * 1024}] \
        ratio 256 \
        ratioFloor 65536 \
        path 1024 \
        component 255 \
        depth 32]
    variable time 0
    variable date 0x0021
    variable flags 0x0800
    variable madeBy 0x0314
    variable external 0x81A40000
    # Windows device names, which no component may be (with any extension).
    variable devices {con prn aux nul com0 com1 com2 com3 com4 com5 com6 com7 com8 com9
        lpt0 lpt1 lpt2 lpt3 lpt4 lpt5 lpt6 lpt7 lpt8 lpt9}
}

proc pm::archive::Fail {reason label message} {
    return -code error -errorcode [list PM ARCHIVE $reason] "$label: $message"
}

# ---------------------------------------------------------------------------
# Paths

# "" when PATH is a portable archive path, else why not: "/"-separated
# components of [A-Za-z0-9_][A-Za-z0-9_.+-]* (no hidden file, no "." or "..",
# no backslash, no drive, no space), none ending in ".", none a Windows
# device name, at most LIMITS' depth, component and path lengths.
proc pm::archive::pathProblem {path {given ""}} {
    variable devices
    set limits [Effective $given]
    if {$path eq ""} {
        return "an empty path"
    }
    if {[string length $path] > [dict get $limits path]} {
        return "a path longer than [dict get $limits path] bytes"
    }
    set components [split $path /]
    if {[llength $components] > [dict get $limits depth]} {
        return "a path deeper than [dict get $limits depth] directories"
    }
    foreach component $components {
        if {$component eq ""} {
            return "an empty path component (a leading, doubled or trailing \"/\")"
        }
        if {![regexp {^[A-Za-z0-9_][A-Za-z0-9_.+-]*$} $component]} {
            if {$component in {. ..}} {
                return "a \"$component\" path component"
            }
            if {[string index $component 0] eq "."} {
                return "a hidden path component \"$component\" (no entry name starts with \".\")"
            }
            return "the path component \"$component\" is not portable (A-Z, a-z, 0-9 and _ . + -, not starting with . + or -)"
        }
        if {[string length $component] > [dict get $limits component]} {
            return "a path component longer than [dict get $limits component] bytes"
        }
        if {[string index $component end] eq "."} {
            return "the path component \"$component\" ends with \".\", which Windows drops"
        }
        set base [string tolower [lindex [split $component .] 0]]
        if {$base in $devices} {
            return "the path component \"$component\" is a Windows device name"
        }
    }
    return ""
}

# "" when the sorted list of PATHS has no two paths equal ignoring ASCII case
# and no path that is also a directory of another (ignoring case), else the
# problem.
proc pm::archive::CollisionProblem {paths} {
    set files [dict create]
    set dirs [dict create]
    foreach path $paths {
        set folded [string tolower $path]
        if {[dict exists $files $folded]} {
            return "the paths \"[dict get $files $folded]\" and \"$path\" differ only in letter case: one file on a case-insensitive file system"
        }
        dict set files $folded $path
        set prefix ""
        foreach component [lrange [split $folded /] 0 end-1] {
            append prefix $component
            dict set dirs $prefix $path
            append prefix /
        }
    }
    dict for {folded path} $files {
        if {[dict exists $dirs $folded]} {
            return "\"$path\" is a file and also a directory of \"[dict get $dirs $folded]\""
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Writing

# The deterministic archive of FILES (dict PATH -> BYTES): entries sorted by
# path, every field fixed by the profile, each file deflated (level 9) when
# that is smaller and within the ratio rule, else stored.
proc pm::archive::bytes {files} {
    variable time
    variable date
    variable flags
    variable madeBy
    variable external
    variable limits
    set paths [lsort [dict keys $files]]
    if {$paths eq ""} {
        error "pm::archive::bytes: no files"
    }
    foreach path $paths {
        if {[set problem [pathProblem $path]] ne ""} {
            error "pm::archive::bytes: $path: $problem"
        }
    }
    if {[set problem [CollisionProblem $paths]] ne ""} {
        error "pm::archive::bytes: $problem"
    }
    set body ""
    set central ""
    foreach path $paths {
        set data [dict get $files $path]
        set size [string length $data]
        set crc [expr {[zlib crc32 $data] & 0xffffffff}]
        set method 0
        set stored $data
        if {$size > 0} {
            set deflated [zlib deflate $data 9]
            set csize [string length $deflated]
            if {$csize < $size && ($size <= [dict get $limits ratioFloor]
                    || $size <= [dict get $limits ratio] * $csize)} {
                set method 8
                set stored $deflated
            }
        }
        set csize [string length $stored]
        set name [encoding convertto utf-8 $path]
        set offset [string length $body]
        append body [binary format "i s s s s s i i i s s" 0x04034b50 20 $flags $method $time $date \
            $crc $csize $size [string length $name] 0] $name $stored
        append central [binary format "i s s s s s s i i i s s s" 0x02014b50 $madeBy 20 $flags $method $time $date \
            $crc $csize $size [string length $name] 0 0] \
            [binary format "s s i i" 0 0 $external $offset] $name
    }
    set count [llength $paths]
    set end [binary format "i s s s s i i s" 0x06054b50 0 0 $count $count \
        [string length $central] [string length $body] 0]
    return "$body$central$end"
}

# ---------------------------------------------------------------------------
# Reading

# The structure of the archive bytes DATA: a list of entry dicts {name
# method crc csize size data} (data the stored bytes), every structural rule
# of the profile checked. LABEL names the archive in errors.
proc pm::archive::Structure {data label limits} {
    variable time
    variable date
    variable flags
    variable madeBy
    variable external
    set length [string length $data]
    if {$length > [dict get $limits archive]} {
        Fail LIMIT $label "the archive is $length bytes, over the limit of [dict get $limits archive]"
    }
    if {$length < 22} {
        Fail FORMAT $label "not a .botpkg archive (too short for a ZIP end record)"
    }
    binary scan $data "@[expr {$length - 22}] iu su su su su iu iu su" sig disk cdDisk diskEntries entries cdSize cdOffset commentLength
    if {$sig != 0x06054b50} {
        if {[string first "PK\x05\x06" $data] >= 0} {
            Fail FORMAT $label "the ZIP end record is not the archive's last 22 bytes (an archive comment or trailing data, which the profile forbids)"
        }
        Fail FORMAT $label "not a .botpkg archive (no ZIP end record)"
    }
    if {$disk != 0 || $cdDisk != 0 || $diskEntries != $entries} {
        Fail FORMAT $label "a multi-disk archive"
    }
    if {$commentLength != 0} {
        Fail FORMAT $label "an archive comment"
    }
    if {$entries == 0xffff || $cdSize == 0xffffffff || $cdOffset == 0xffffffff} {
        Fail FORMAT $label "a ZIP64 archive"
    }
    if {$entries == 0} {
        Fail FORMAT $label "an archive with no entries"
    }
    if {$entries > [dict get $limits entries]} {
        Fail LIMIT $label "$entries entries, over the limit of [dict get $limits entries]"
    }
    if {$cdOffset + $cdSize != $length - 22} {
        Fail FORMAT $label "the central directory does not end where the end record begins (data between them, or sizes that do not add up)"
    }
    set entryList {}
    set at $cdOffset
    set expected 0
    set previous ""
    set total 0
    for {set i 0} {$i < $entries} {incr i} {
        if {$at + 46 > $cdOffset + $cdSize} {
            Fail FORMAT $label "the central directory is shorter than its $entries entries"
        }
        binary scan $data "@$at iu su su su su su su iu iu iu su su su su su iu iu" sig made needed eflags method etime edate \
            crc csize size nameLength extraLength commentLength diskStart internal attributes offset
        if {$sig != 0x02014b50} {
            Fail FORMAT $label "a malformed central directory entry ([expr {$i + 1}])"
        }
        set name [string range $data [expr {$at + 46}] [expr {$at + 45 + $nameLength}]]
        if {[string length $name] != $nameLength || $at + 46 + $nameLength > $cdOffset + $cdSize} {
            Fail FORMAT $label "a central directory entry's name runs past the directory"
        }
        set shown [EntryLabel $name]
        if {$extraLength != 0 || $commentLength != 0} {
            Fail FORMAT $label "entry $shown has an extra field or a comment, which the profile forbids"
        }
        if {$eflags & 0x41} {
            Fail FORMAT $label "entry $shown is encrypted"
        }
        if {$eflags & 0x08} {
            Fail FORMAT $label "entry $shown uses a data descriptor, which the profile forbids"
        }
        if {$eflags != $flags} {
            Fail FORMAT $label "entry $shown has general purpose flags [format 0x%04x $eflags], the profile's are 0x0800"
        }
        if {$method ni {0 8}} {
            Fail FORMAT $label "entry $shown uses compression method $method (the profile has 0, stored, and 8, deflate)"
        }
        if {$made != $madeBy || $needed != 20} {
            Fail FORMAT $label "entry $shown has version fields [format 0x%04x $made]/$needed (the profile's are 0x0314/20)"
        }
        if {$etime != $time || $edate != $date} {
            Fail FORMAT $label "entry $shown has a time stamp, which the profile fixes at 1980-01-01 00:00"
        }
        if {$diskStart != 0 || $internal != 0} {
            Fail FORMAT $label "entry $shown has disk or internal attribute fields"
        }
        if {$attributes != $external} {
            set type [expr {($attributes >> 28) & 0xf}]
            switch -- $type {
                10 { Fail ENTRY $label "entry $shown is a symbolic link" }
                4 { Fail ENTRY $label "entry $shown is a directory entry (directories are implied by paths)" }
                8 { Fail ENTRY $label "entry $shown has a file mode other than 0644 (no executable or special bits)" }
                default { Fail ENTRY $label "entry $shown is not a regular file (external attributes [format 0x%08x $attributes])" }
            }
        }
        if {[catch {encoding convertfrom -profile strict utf-8 $name} path]} {
            Fail PATH $label "an entry name that is not UTF-8"
        }
        if {[set problem [pathProblem $path $limits]] ne ""} {
            Fail PATH $label "entry $shown: $problem"
        }
        if {$i > 0 && [string compare $previous $path] >= 0} {
            if {$previous eq $path} {
                Fail PATH $label "entry $shown appears twice"
            }
            Fail FORMAT $label "entries are not in increasing order of their names ($previous before $path)"
        }
        set previous $path
        if {$method == 0 && $csize != $size} {
            Fail FORMAT $label "stored entry $shown has a compressed size different from its size"
        }
        if {$method == 8 && $csize == 0} {
            Fail FORMAT $label "deflated entry $shown has no data"
        }
        if {$size > [dict get $limits entry]} {
            Fail LIMIT $label "entry $shown is $size bytes, over the limit of [dict get $limits entry]"
        }
        if {$method == 8 && $size > [dict get $limits ratioFloor] && $size > [dict get $limits ratio] * $csize} {
            Fail LIMIT $label "entry $shown would expand $csize bytes to $size, more than [dict get $limits ratio] times"
        }
        incr total $size
        if {$total > [dict get $limits total]} {
            Fail LIMIT $label "the files total more than [dict get $limits total] bytes"
        }
        if {$offset != $expected} {
            Fail FORMAT $label "entry $shown's local header is not where the previous entry ends (a gap, an overlap or entries out of order)"
        }
        # The local header, which must repeat the central entry.
        if {$offset + 30 > $cdOffset} {
            Fail FORMAT $label "entry $shown's local header runs into the central directory"
        }
        binary scan $data "@$offset iu su su su su su iu iu iu su su" lsig lneeded lflags lmethod ltime ldate lcrc lcsize lsize lnameLength lextraLength
        set lname [string range $data [expr {$offset + 30}] [expr {$offset + 29 + $lnameLength}]]
        if {$lsig != 0x04034b50 || $lneeded != $needed || $lflags != $eflags || $lmethod != $method
                || $ltime != $etime || $ldate != $edate || $lcrc != $crc || $lcsize != $csize
                || $lsize != $size || $lextraLength != 0 || $lname ne $name} {
            Fail FORMAT $label "entry $shown's local header differs from its central directory entry"
        }
        set start [expr {$offset + 30 + $nameLength}]
        set end [expr {$start + $csize}]
        if {$end > $cdOffset} {
            Fail FORMAT $label "entry $shown's data runs into the central directory"
        }
        lappend entryList [dict create name $path method $method crc $crc csize $csize size $size start $start]
        set expected $end
        incr at [expr {46 + $nameLength}]
    }
    if {$at != $cdOffset + $cdSize} {
        Fail FORMAT $label "the central directory has bytes after its $entries entries"
    }
    if {$expected != $cdOffset} {
        Fail FORMAT $label "data between the last entry and the central directory"
    }
    if {[set problem [CollisionProblem [lmap e $entryList {dict get $e name}]]] ne ""} {
        Fail PATH $label $problem
    }
    if {"botlish.json" ni [lmap e $entryList {dict get $e name}]} {
        Fail FORMAT $label "no botlish.json at the archive's root: every package artifact has one"
    }
    return $entryList
}

proc pm::archive::EntryLabel {name} {
    if {[regexp {^[\x20-\x7e]*$} $name]} {
        return "\"$name\""
    }
    return "\"[binary encode hex $name]\" (hex)"
}

# The bytes of ENTRY of the archive DATA: decompressed (streamed, never past
# the declared size), size and CRC-32 checked.
proc pm::archive::Extract {data entry label} {
    set stored [string range $data [dict get $entry start] [expr {[dict get $entry start] + [dict get $entry csize] - 1}]]
    set size [dict get $entry size]
    set shown [EntryLabel [dict get $entry name]]
    if {[dict get $entry method] == 0} {
        set out $stored
    } else {
        set stream [zlib stream inflate]
        set out ""
        try {
            if {[catch {
                $stream put -finalize $stored
                while {[set chunk [$stream get 65536]] ne ""} {
                    append out $chunk
                    if {[string length $out] > $size} break
                }
                set ended [$stream eof]
            } message]} {
                Fail CONTENT $label "entry $shown is not valid deflate data ($message)"
            }
        } finally {
            $stream close
        }
        if {[string length $out] > $size} {
            Fail CONTENT $label "entry $shown decompresses to more than its declared $size bytes (decompression stopped after [string length $out])"
        }
        if {!$ended} {
            Fail CONTENT $label "entry $shown's deflate data is truncated"
        }
    }
    if {[string length $out] != $size} {
        Fail CONTENT $label "entry $shown is [string length $out] bytes, its header says $size"
    }
    if {([zlib crc32 $out] & 0xffffffff) != [dict get $entry crc]} {
        Fail CONTENT $label "entry $shown fails its CRC-32 check (the archive is damaged or altered)"
    }
    return $out
}

proc pm::archive::ReadFile {path label limits} {
    if {![file isfile $path]} {
        Fail MISSING $label "no such archive file"
    }
    if {[file size $path] > [dict get $limits archive]} {
        Fail LIMIT $label "the archive is [file size $path] bytes, over the limit of [dict get $limits archive]"
    }
    set channel [open $path rb]
    try {
        return [::read $channel]
    } finally {
        close $channel
    }
}

proc pm::archive::Effective {given} {
    variable limits
    return [dict merge $limits $given]
}

# Every file of the archive at PATH, fully validated.
proc pm::archive::read {path {given ""}} {
    set limits [Effective $given]
    set data [ReadFile $path $path $limits]
    return [fromBytes $data $path $given]
}

proc pm::archive::fromBytes {data label {given ""}} {
    set limits [Effective $given]
    set entries [Structure $data $label $limits]
    set files {}
    foreach entry $entries {
        lappend files [dict get $entry name] [Extract $data $entry $label]
    }
    return [dict create files $files descriptor [dict get $files botlish.json] size [string length $data]]
}

# The botlish.json bytes of the archive at PATH, the structure validated.
proc pm::archive::descriptorBytes {path {given ""}} {
    set limits [Effective $given]
    set data [ReadFile $path $path $limits]
    foreach entry [Structure $data $path $limits] {
        if {[dict get $entry name] eq "botlish.json"} {
            return [Extract $data $entry $path]
        }
    }
}
