# sha256.tcl -- SHA-256 (FIPS 180-4) in Tcl, for package artifact digests
# (PACKAGE-MANAGER-MILESTONE-1.md, "Integrity").
#
#   pm::sha256::hex BYTES      the lowercase hexadecimal digest of BYTES
#   pm::sha256::file PATH      the digest of the file PATH's bytes
#
# The package manager must run wherever the compiler does -- the single-file
# compiler included, with no tcllib, no `sha256sum` and no native backend --
# so the digest is computed here, in Tcl. The 64 rounds and the message
# schedule are generated once, unrolled, as one procedure body (Compress), so
# Tcl's bytecode compiler keeps every working variable in a local slot. It
# hashes about 0.8 MB/s on a 2026 x86-64 container; an artifact is hashed
# compressed, once per acquisition. Checked against FIPS 180-4's
# test vectors and `sha256sum` (tests/package-manager.test, pm-sha256-*).

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
    variable H0
    set state [Compress $H0 "$bytes[Padding [string length $bytes]]"]
    return [Hex $state]
}

# The digest of the file PATH, read in chunks (a large file is never held
# whole).
proc pm::sha256::file {path} {
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
