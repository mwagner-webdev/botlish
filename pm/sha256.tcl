# sha256.tcl -- SHA-256 (FIPS 180-4) for package artifact digests
# (PACKAGE-MANAGER-MILESTONE-1.md, "Integrity"; PACKAGE-MANAGER-MILESTONE-2.md,
# "Hashing").
#
#   pm::sha256::hex BYTES      the lowercase hexadecimal digest of BYTES
#   pm::sha256::file PATH      the digest of the file PATH's bytes
#   pm::sha256::backend        "tool PATH" or "tcl", and why
#
# Two implementations of the one algorithm:
#
#   * the host system's own SHA-256 tool, at a fixed system path -- GNU
#     coreutils' sha256sum (/usr/bin, /bin) on Linux, Perl's shasum
#     (/usr/bin) on macOS, certutil.exe (%SystemRoot%\System32) on Windows:
#     an established, trusted implementation the operating system ships
#     (OpenSSL's command line is deliberately not used: it is no part of a
#     distribution's contract). Never found on PATH, where any directory
#     could hold a program of that name that lies about digests. It is
#     started once per digest with the exact bytes on its standard input
#     (certutil, which reads only files, gets a private temporary copy), so
#     the bytes hashed are the bytes the package manager validated, never a
#     file read again later. Before its first use in a process it must
#     reproduce FIPS 180-4's known answers (Probe); a tool that does not, or
#     fails, is not used again in the process;
#   * the portable implementation below, in Tcl, for small inputs (where
#     starting a process costs more than hashing) and wherever no tool is
#     available. It hashes about 0.8 MiB/s.
#
# BOTLISH_PM_SHA256 (environment only) forces one: `tcl`, or `tool` (an
# error where there is none: for the tests and benchmarks that must measure
# one). The two are checked against each other and against independent
# vectors (tests/package-manager.test, pm-sha256-*).

namespace eval pm::sha256 {
    variable K {
        0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5 0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
        0xd807aa98 0x12835b01 0x243185be 0x550c7dc3 0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
        0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc 0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
        0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7 0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
        0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13 0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
        0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3 0xd192e819 0xd6990624 0xf40e3585 0x106aa070
        0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5 0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
        0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208 0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2
    }
    variable H0 {
        0x6a09e667 0xbb67ae85 0x3c6ef372 0xa54ff53a 0x510e527f 0x9b05688c 0x1f83d9ab 0x5be0cd19
    }
}

# Generates pm::sha256::Compress STATE BLOCKS: STATE (the eight words) after
# the 64-byte blocks of the byte string BLOCKS.
proc pm::sha256::Generate {} {
    variable K
    # rotr(x, n) of a 32-bit x, in the low 32 bits only: the bits above are
    # left unmasked, since every use is masked once at the end of a sum or
    # an exclusive or, and the low 32 bits of either depend only on the low
    # 32 bits of the operands (every intermediate stays below 2^62).
    set rotr {((%1$s >> %2$d) | (%1$s << (32 - %2$d)))}
    set schedule ""
    for {set t 16} {$t < 64} {incr t} {
        set x15 "\$w[expr {$t - 15}]"
        set x2 "\$w[expr {$t - 2}]"
        set s0 "([format $rotr $x15 7] ^ [format $rotr $x15 18] ^ ($x15 >> 3))"
        set s1 "([format $rotr $x2 17] ^ [format $rotr $x2 19] ^ ($x2 >> 10))"
        append schedule "            set w$t \[expr {($s1 + \$w[expr {$t - 7}] + $s0 + \$w[expr {$t - 16}]) & 0xffffffff}\]\n"
    }
    # The rounds rename instead of shifting: the eight working variables
    # keep their values, and each round's roles (a..h) are the variables of
    # the previous round's rotated by one, so a round assigns only its two
    # new values (FIPS 180-4's a and e). After 64 rounds the roles are back
    # where they started.
    set rounds ""
    set v {a b c d e f g h}
    for {set t 0} {$t < 64} {incr t} {
        lassign [lmap name $v {string cat \$ $name}] A B C D E F G H
        set S1 "([format $rotr $E 6] ^ [format $rotr $E 11] ^ [format $rotr $E 25])"
        set S0 "([format $rotr $A 2] ^ [format $rotr $A 13] ^ [format $rotr $A 22])"
        set ch "(($E & $F) ^ (~$E & $G))"
        set maj "(($A & $B) ^ ($A & $C) ^ ($B & $C))"
        append rounds "            set t1 \[expr {$H + $S1 + $ch + [lindex $K $t] + \$w$t}\]\n"
        append rounds "            set [lindex $v 3] \[expr {($D + \$t1) & 0xffffffff}\]\n"
        append rounds "            set [lindex $v 7] \[expr {(\$t1 + $S0 + $maj) & 0xffffffff}\]\n"
        set v [list [lindex $v 7] [lindex $v 0] [lindex $v 1] [lindex $v 2] [lindex $v 3] [lindex $v 4] [lindex $v 5] [lindex $v 6]]
    }
    set template {
        lassign $state h0 h1 h2 h3 h4 h5 h6 h7
        set length [string length $blocks]
        for {set offset 0} {$offset < $length} {incr offset 64} {
            binary scan $blocks @${offset}Iu16 words
            lassign $words w0 w1 w2 w3 w4 w5 w6 w7 w8 w9 w10 w11 w12 w13 w14 w15
@SCHEDULE@
            set a $h0; set b $h1; set c $h2; set d $h3
            set e $h4; set f $h5; set g $h6; set h $h7
@ROUNDS@
            set h0 [expr {($h0 + $a) & 0xffffffff}]
            set h1 [expr {($h1 + $b) & 0xffffffff}]
            set h2 [expr {($h2 + $c) & 0xffffffff}]
            set h3 [expr {($h3 + $d) & 0xffffffff}]
            set h4 [expr {($h4 + $e) & 0xffffffff}]
            set h5 [expr {($h5 + $f) & 0xffffffff}]
            set h6 [expr {($h6 + $g) & 0xffffffff}]
            set h7 [expr {($h7 + $h) & 0xffffffff}]
        }
        return [list $h0 $h1 $h2 $h3 $h4 $h5 $h6 $h7]
    }
    proc ::pm::sha256::Compress {state blocks} [string map [list @SCHEDULE@ $schedule @ROUNDS@ $rounds] $template]
}
pm::sha256::Generate

# The padding of a message of LENGTH bytes (FIPS 180-4, 5.1.1).
proc pm::sha256::Padding {length} {
    set zeros [expr {(55 - $length) % 64}]
    if {$zeros < 0} { incr zeros 64 }
    return "\x80[string repeat \x00 $zeros][binary format W [expr {$length * 8}]]"
}

proc pm::sha256::Hex {state} {
    return [binary encode hex [binary format Iu8 $state]]
}

proc pm::sha256::hex {bytes} {
    variable threshold
    if {[string length $bytes] >= $threshold || [Forced] eq "tool"} {
        set tool [Tool]
        if {$tool ne ""} {
            if {![catch {ToolHex $tool $bytes} digest]} {
                return $digest
            }
            Disable "it failed: $digest"
        }
    }
    return [TclHex $bytes]
}

proc pm::sha256::TclHex {bytes} {
    variable H0
    set state [Compress $H0 "$bytes[Padding [string length $bytes]]"]
    return [Hex $state]
}

# The digest of the file PATH: the tool's when there is one, else read in
# chunks (a large file is never held whole).
proc pm::sha256::file {path} {
    variable threshold
    if {[::file size $path] >= $threshold || [Forced] eq "tool"} {
        set tool [Tool]
        if {$tool ne ""} {
            if {![catch {ToolFile $tool $path} digest]} {
                return $digest
            }
            Disable "it failed: $digest"
        }
    }
    return [TclFile $path]
}

# ---------------------------------------------------------------------------
# The system's tool

namespace eval pm::sha256 {
    # Below this many bytes the Tcl implementation is faster than starting
    # a process (bench/package-manager.tcl measures both).
    variable threshold 4096
    # "" before the first use; then {KIND PATH}, or {none REASON}.
    variable tool ""
}

proc pm::sha256::Forced {} {
    if {[info exists ::env(BOTLISH_PM_SHA256)]} {
        return $::env(BOTLISH_PM_SHA256)
    }
    return ""
}

# The candidates of this platform: {KIND PATH} each, in order.
proc pm::sha256::Candidates {} {
    if {$::tcl_platform(platform) eq "windows"} {
        set root C:/Windows
        if {[info exists ::env(SystemRoot)] && [regexp {^[A-Za-z]:[\\/][^;]*$} $::env(SystemRoot)]} {
            set root [::file normalize $::env(SystemRoot)]
        }
        return [list [list certutil [::file join $root System32 certutil.exe]]]
    }
    return [list {sha256sum /usr/bin/sha256sum} {sha256sum /bin/sha256sum} {shasum /usr/bin/shasum}]
}

# The tool in use ({KIND PATH}), or "" when there is none.
proc pm::sha256::Tool {} {
    variable tool
    set forced [Forced]
    if {$forced eq "tcl"} {
        return ""
    }
    if {$tool eq ""} {
        set tool [list none "no SHA-256 tool at the system's fixed paths"]
        foreach candidate [Candidates] {
            lassign $candidate kind path
            if {![::file isfile $path] || ![::file executable $path]} continue
            if {[catch {Probe $candidate} problem] || $problem ne ""} {
                set tool [list none "$path failed its known-answer test"]
                continue
            }
            set tool $candidate
            break
        }
    }
    if {[lindex $tool 0] eq "none"} {
        if {$forced eq "tool"} {
            return -code error -errorcode {PM SHA256} "BOTLISH_PM_SHA256=tool, and there is none: [lindex $tool 1]"
        }
        return ""
    }
    return $tool
}

proc pm::sha256::Disable {reason} {
    variable tool
    set tool [list none $reason]
    if {[Forced] eq "tool"} {
        return -code error -errorcode {PM SHA256} "BOTLISH_PM_SHA256=tool, and the tool $reason"
    }
}

# "" when the tool CANDIDATE reproduces FIPS 180-4's known answers (and
# one more digest the Tcl implementation computes), else what differed.
proc pm::sha256::Probe {candidate} {
    set vectors [list abc ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad \
        "" e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 \
        abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq 248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1]
    set block [string repeat "\x00\xff\x80\x7f" 300]
    lappend vectors $block [TclHex $block]
    foreach {input expected} $vectors {
        set digest [ToolHex $candidate $input]
        if {$digest ne $expected} {
            return "[lindex $candidate 1] gave $digest for a known input"
        }
    }
    return ""
}

# The tool's digest of BYTES, given on its standard input.
proc pm::sha256::ToolHex {candidate bytes} {
    lassign $candidate kind path
    if {$kind eq "certutil"} {
        set dir [::file tempdir botlish-sha256]
        try {
            set copy [::file join $dir input]
            pm::WriteNew $copy $bytes
            return [ToolFile $candidate $copy]
        } finally {
            ::file delete -force $dir
        }
    }
    set command [list $path]
    if {$kind eq "shasum"} {
        lappend command -a 256
    }
    set channel [open |[concat $command [list 2>@1]] r+]
    fconfigure $channel -translation binary -buffering full
    try {
        puts -nonewline $channel $bytes
        chan close $channel write
        set output [read $channel]
    } finally {
        catch {close $channel}
    }
    return [Parse $output $path]
}

proc pm::sha256::ToolFile {candidate path} {
    lassign $candidate kind tool
    switch -- $kind {
        sha256sum { set output [exec $tool -- $path 2>@1] }
        shasum { set output [exec $tool -a 256 -- $path 2>@1] }
        certutil {
            set output [exec $tool -hashfile [::file nativename $path] SHA256]
            # certutil prints a header line, the digest (in older Windows
            # versions spaced), and a status line.
            set lines [split [string map {"\r" ""} $output] \n]
            set output [string map {" " ""} [lindex $lines 1]]
        }
    }
    return [Parse $output $tool]
}

proc pm::sha256::Parse {output tool} {
    set digest [string tolower [lindex [split [string trim $output]] 0]]
    if {![regexp {^[0-9a-f]{64}$} $digest]} {
        error "$tool printed no SHA-256 digest"
    }
    return $digest
}

# Which implementation hashes large inputs here, and why: {tool PATH} or
# {tcl REASON}.
proc pm::sha256::backend {} {
    if {[Forced] eq "tcl"} {
        return [list tcl "BOTLISH_PM_SHA256=tcl"]
    }
    set found [Tool]
    if {$found ne ""} {
        return [list tool [lindex $found 1]]
    }
    variable tool
    return [list tcl [lindex $tool 1]]
}

# The digest of the file PATH, read in chunks (a large file is never held
# whole), in Tcl.
proc pm::sha256::TclFile {path} {
    variable H0
    set state $H0
    set length 0
    set pending ""
    set channel [open $path rb]
    try {
        while {[set chunk [read $channel 1048576]] ne ""} {
            incr length [string length $chunk]
            append pending $chunk
            set whole [expr {[string length $pending] / 64 * 64}]
            if {$whole > 0} {
                set state [Compress $state [string range $pending 0 [expr {$whole - 1}]]]
                set pending [string range $pending $whole end]
            }
        }
    } finally {
        close $channel
    }
    return [Hex [Compress $state "$pending[Padding $length]"]]
}
