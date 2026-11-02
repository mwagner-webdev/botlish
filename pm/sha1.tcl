# sha1.tcl -- SHA-1 (FIPS 180-4), for one purpose only: computing Git
# object identities (a blob's, a tree's) when a provenance record's source
# tree is checked against the files it names (pm/release.tcl;
# PACKAGE-MANAGER-MILESTONE-3.md, "Provenance"). It is never an integrity
# digest of the package manager's own: artifacts, records and native files
# are SHA-256's (pm/sha256.tcl). SHA-1 is Git's default object format, whose
# collision weakness is Git's to address (SHA-256 repositories); a check of
# a SHA-1 Git identity is exactly as strong as that identity.
#
#   pm::sha1::hex BYTES      the lowercase hexadecimal digest of BYTES
#
# Two implementations of the one algorithm, as pm/sha256.tcl's: the host
# system's own tool at a fixed system path (GNU coreutils' sha1sum, Perl's
# shasum -a 1 on macOS, certutil.exe on Windows), checked against FIPS
# 180-4's known answers before its first use and fed the exact bytes on its
# standard input, and the portable Tcl implementation below for small
# inputs and wherever there is no tool. BOTLISH_PM_SHA1 (environment only)
# forces `tcl` or `tool`.

namespace eval pm::sha1 {
    variable H0 {0x67452301 0xEFCDAB89 0x98BADCFE 0x10325476 0xC3D2E1F0}
    variable threshold 4096
    variable tool ""
}

# Generates pm::sha1::Compress STATE BLOCKS: STATE (the five words) after
# the 64-byte blocks of BLOCKS.
proc pm::sha1::Generate {} {
    set rotl {((%1$s << %2$d) | (%1$s >> (32 - %2$d)))}
    set schedule ""
    for {set t 16} {$t < 80} {incr t} {
        set x "(\$w[expr {$t - 3}] ^ \$w[expr {$t - 8}] ^ \$w[expr {$t - 14}] ^ \$w[expr {$t - 16}])"
        append schedule "            set x \[expr {$x}\]\n"
        append schedule "            set w$t \[expr {([format $rotl {$x} 1]) & 0xffffffff}\]\n"
    }
    set rounds ""
    set v {a b c d e}
    for {set t 0} {$t < 80} {incr t} {
        lassign [lmap name $v {string cat \$ $name}] A B C D E
        if {$t < 20} {
            set f "(($B & $C) | ((~$B) & $D))"
            set k 0x5A827999
        } elseif {$t < 40} {
            set f "($B ^ $C ^ $D)"
            set k 0x6ED9EBA1
        } elseif {$t < 60} {
            set f "(($B & $C) | ($B & $D) | ($C & $D))"
            set k 0x8F1BBCDC
        } else {
            set f "($B ^ $C ^ $D)"
            set k 0xCA62C1D6
        }
        # temp = rotl(a, 5) + f + e + k + w; e = d; d = c; c = rotl(b, 30);
        # b = a; a = temp -- by renaming: the new a takes e's variable, and
        # b's variable gets rotl(b, 30).
        append rounds "            set [lindex $v 4] \[expr {([format $rotl $A 5] + $f + $E + $k + \$w$t) & 0xffffffff}\]\n"
        append rounds "            set [lindex $v 1] \[expr {[format $rotl $B 30] & 0xffffffff}\]\n"
        set v [list [lindex $v 4] [lindex $v 0] [lindex $v 1] [lindex $v 2] [lindex $v 3]]
    }
    set template {
        lassign $state h0 h1 h2 h3 h4
        set length [string length $blocks]
        for {set offset 0} {$offset < $length} {incr offset 64} {
            binary scan $blocks @${offset}Iu16 words
            lassign $words w0 w1 w2 w3 w4 w5 w6 w7 w8 w9 w10 w11 w12 w13 w14 w15
@SCHEDULE@
            set a $h0; set b $h1; set c $h2; set d $h3; set e $h4
@ROUNDS@
            set h0 [expr {($h0 + $@A@) & 0xffffffff}]
            set h1 [expr {($h1 + $@B@) & 0xffffffff}]
            set h2 [expr {($h2 + $@C@) & 0xffffffff}]
            set h3 [expr {($h3 + $@D@) & 0xffffffff}]
            set h4 [expr {($h4 + $@E@) & 0xffffffff}]
        }
        return [list $h0 $h1 $h2 $h3 $h4]
    }
    proc ::pm::sha1::Compress {state blocks} [string map [list @SCHEDULE@ $schedule @ROUNDS@ $rounds \
        @A@ [lindex $v 0] @B@ [lindex $v 1] @C@ [lindex $v 2] @D@ [lindex $v 3] @E@ [lindex $v 4]] $template]
}
pm::sha1::Generate

proc pm::sha1::Padding {length} {
    set zeros [expr {(55 - $length) % 64}]
    if {$zeros < 0} { incr zeros 64 }
    return "\x80[string repeat \x00 $zeros][binary format W [expr {$length * 8}]]"
}

proc pm::sha1::TclHex {bytes} {
    variable H0
    return [binary encode hex [binary format Iu5 [Compress $H0 "$bytes[Padding [string length $bytes]]"]]]
}

proc pm::sha1::Forced {} {
    if {[info exists ::env(BOTLISH_PM_SHA1)]} {
        return $::env(BOTLISH_PM_SHA1)
    }
    return ""
}

proc pm::sha1::hex {bytes} {
    variable threshold
    if {[string length $bytes] >= $threshold || [Forced] eq "tool"} {
        set tool [Tool]
        if {$tool ne ""} {
            if {![catch {ToolHex $tool $bytes} digest]} {
                return $digest
            }
            variable tool
            set tool [list none "it failed: $digest"]
            if {[Forced] eq "tool"} {
                return -code error -errorcode {PM SHA1} "BOTLISH_PM_SHA1=tool, and the tool failed: $digest"
            }
        }
    }
    return [TclHex $bytes]
}

proc pm::sha1::Candidates {} {
    if {$::tcl_platform(platform) eq "windows"} {
        set root C:/Windows
        if {[info exists ::env(SystemRoot)] && [regexp {^[A-Za-z]:[\\/][^;]*$} $::env(SystemRoot)]} {
            set root [::file normalize $::env(SystemRoot)]
        }
        return [list [list certutil [::file join $root System32 certutil.exe]]]
    }
    return [list {sha1sum /usr/bin/sha1sum} {sha1sum /bin/sha1sum} {shasum /usr/bin/shasum}]
}

proc pm::sha1::Tool {} {
    variable tool
    if {[Forced] eq "tcl"} {
        return ""
    }
    if {$tool eq ""} {
        set tool [list none "no SHA-1 tool at the system's fixed paths"]
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
        if {[Forced] eq "tool"} {
            return -code error -errorcode {PM SHA1} "BOTLISH_PM_SHA1=tool, and there is none: [lindex $tool 1]"
        }
        return ""
    }
    return $tool
}

# "" when the tool CANDIDATE reproduces FIPS 180-4's known answers (and one
# digest the Tcl implementation computes), else what differed.
proc pm::sha1::Probe {candidate} {
    set vectors [list abc a9993e364706816aba3e25717850c26c9cd0d89d \
        "" da39a3ee5e6b4b0d3255bfef95601890afd80709 \
        abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq 84983e441c3bd26ebaae4aa1f95129e5e54670f1]
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

proc pm::sha1::ToolHex {candidate bytes} {
    lassign $candidate kind path
    if {$kind eq "certutil"} {
        set dir [::file tempdir botlish-sha1]
        try {
            set copy [::file join $dir input]
            pm::WriteNew $copy $bytes
            set output [exec $path -hashfile [::file nativename $copy] SHA1]
            set lines [split [string map {"\r" ""} $output] \n]
            set output [string map {" " ""} [lindex $lines 1]]
        } finally {
            ::file delete -force $dir
        }
    } else {
        set command [list $path]
        if {$kind eq "shasum"} {
            lappend command -a 1
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
    }
    set digest [string tolower [lindex [split [string trim $output]] 0]]
    if {![regexp {^[0-9a-f]{40}$} $digest]} {
        error "$path printed no SHA-1 digest"
    }
    return $digest
}
