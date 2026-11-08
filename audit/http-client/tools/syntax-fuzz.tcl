# syntax-fuzz.tcl -- the http package's URI parser and request-header
# constructor (packages/http/http.bot's `uri` and `header`) against
# independent statements of their rules (tests/http/uri_oracle.py: Python's
# ipaddress and RFC 3986; tests/http/header_oracle.py: RFC 9110's token and
# the documented field-value rule; both written apart from the package's
# code); HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "Fuzzing".
#
#   tclsh9.0 audit/http-client/tools/syntax-fuzz.tcl ?-seed S? ?-count N? ?-headers N? ?-client EXE?
#
# Generates N URIs from seed S -- a grammar of valid parts (schemes in any
# case, DNS names, IPv4 and IPv6 literals, ports, paths, queries,
# fragments, escapes) and corruptions of them (bad escapes, user
# information, zone identifiers, controls, non-ASCII, empty and oversized
# labels and ports, other schemes) -- and N header fields (default: N) --
# tokens and non-tokens, every name the client owns in any case, values
# with controls, DEL, tabs and spaces at either end or inside, non-ASCII
# text -- runs each through the test client (tests/http/client.bot's
# `parse-many` and `headers-many`, built as tests/http-client.test builds
# it, or EXE) and through its oracle, and prints every disagreement. Exit
# status 1 when there is one.
#
# Needs the http package's native files (tests/cffi/http.tcl) and python3.

set root [file normalize [file join [file dirname [info script]] .. .. ..]]
set opts [dict create -seed 1 -count 2000 -headers "" -client ""]
foreach {k v} $argv {
    if {![dict exists $opts $k]} { puts stderr "unknown option $k"; exit 2 }
    dict set opts $k $v
}
expr {srand([dict get $opts -seed])}

proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc chance {p} { expr {rand() < $p} }

proc label {} {
    set chars abcdefghijklmnopqrstuvwxyz0123456789
    set n [expr {1 + int(rand() * 12)}]
    set s ""
    for {set i 0} {$i < $n} {incr i} { append s [string index $chars [expr {int(rand() * 36)}]] }
    if {[chance 0.1]} { set s [string toupper $s] }
    if {[chance 0.05]} { set s -$s }
    if {[chance 0.05]} { append s - }
    if {[chance 0.05]} { set s [string repeat a 64] }
    if {[chance 0.05]} { set s a_b }
    return $s
}

proc host {} {
    switch [pick {dns dns dns dns dns dns ipv4 ipv4 ipv6 ipv6 bad}] {
        dns {
            set labels {}
            for {set i 0} {$i < 1 + int(rand() * 4)} {incr i} { lappend labels [label] }
            set h [join $labels .]
            if {[chance 0.05]} { append h . }
            if {[chance 0.03]} { set h $h..x }
            return $h
        }
        ipv4 {
            set parts {}
            set n [expr {[chance 0.9] ? 4 : 3}]
            for {set i 0} {$i < $n} {incr i} { lappend parts [pick {0 1 9 10 127 192 255 256 01 300}] }
            return [join $parts .]
        }
        ipv6 {
            set forms {::1 :: 2001:db8::1 fe80::1 ::ffff:1.2.3.4 2001:db8:0:0:0:0:0:1 1:2:3:4:5:6:7:8 1::2::3 g::1 ::1%25eth0 FE80::A 12345::1 ::1.2.3}
            return "\[[pick $forms]\]"
        }
        bad { return [pick {"" "a b" "xé" "h%41" "\[::1" "::1" "a\tb" "h@" "*"}] }
    }
}

proc segment {} {
    set good {a b c x1 ~u - . .. %20 %2F %c3%a9 : @ ! $ & ' ( ) * + , ; =}
    set bad {%zz % %4 é " " "\[" "\]" "|" "\{" "^" "\\"}
    set pieces [concat $good $good $good $good $bad]
    set s ""
    for {set i 0} {$i < int(rand() * 4)} {incr i} { append s [pick $pieces] }
    return $s
}

proc uri {} {
    set scheme [pick {http https http https http https HTTP Https hTtP ftp ws "" h1 "1http"}]
    set u "$scheme"
    append u [pick {:// :// :// :// :// :// :// :// :/ : //}]
    if {[chance 0.05]} { append u "user@" }
    if {[chance 0.02]} { append u "user:pw@" }
    append u [host]
    if {[chance 0.4]} { append u : [pick {80 443 8080 1 65535 80 443 8080 0 65536 99999 "" 0443 -1 x}] }
    for {set i 0} {$i < int(rand() * 4)} {incr i} { append u / [segment] }
    if {[chance 0.3]} { append u ? [segment] [pick {"" =1 &x=y ?/ %41}] }
    if {[chance 0.2]} { append u # [segment] }
    if {[chance 0.02]} { append u "\x01" }
    return $u
}

proc client {} {
    set given [dict get $::opts -client]
    if {$given ne ""} { return $given }
    set ::argv {}
    package require tcltest
    source [file join $::root tests helpers.tcl]
    source [file join $::root surface surface.tcl]
    source [file join $::root native native.tcl]
    source [file join $::root tests cffi http.tcl]
    if {![cffi::httpBuilt]} { puts stderr "syntax-fuzz: the http package's native files are not built (tclsh9.0 tests/cffi/http.tcl)"; exit 2 }
    set dir [file tempdir syntax-fuzz]
    httppkg::App $dir 1
    foreach f {client.bot probe.bot} { file copy [file join $::root tests http $f] $dir }
    set hir [surface::readProgramFile [file join $dir client.bot] -warnings off -cache ""]
    return [native::executable $hir [file join $dir client]]
}

# The lines of the client's value (a List[str]) for the NUL-separated
# arguments in ARGSFILE, read through the driver protocol
# (BOTLISH_NATIVE_RESULT: an executable prints only what its program
# writes, PROGRAM-OUTPUT-MILESTONE-1.md). One run of the client: xargs is
# told to fail rather than split the batch, and the lines are counted.
proc clientLines {exe argsFile count} {
    set result [file join [file dirname $exe] result.txt]
    file delete $result
    exec xargs -0 -x -a $argsFile env BOTLISH_NATIVE_RESULT=$result $exe
    set f [open $result r]
    fconfigure $f -encoding utf-8
    set lines [split [string trimright [read $f] \n] \n]
    close $f
    set value ""
    foreach line $lines {
        if {[lindex $line 0] eq "value"} { set value [lindex $line 1] }
        if {[lindex $line 0] eq "error"} { error "the client failed: $line" }
    }
    if {[lindex $value 0] ne "list"} { error "the client wrote no List: $lines" }
    set out [lmap item [lindex $value 1] { lindex $item 1 }]
    if {[llength $out] != $count} { error "the client reported [llength $out] lines for $count" }
    return $out
}

set exe [client]
set uris {}
for {set i 0} {$i < [dict get $opts -count]} {incr i} { lappend uris [uri] }
set disagreements 0
set valid 0
set batch 200
for {set i 0} {$i < [llength $uris]} {incr i $batch} {
    set chunk [lrange $uris $i [expr {$i + $batch - 1}]]
    set argsFile [file join [file dirname $exe] uris.args]
    set f [open $argsFile wb]
    puts -nonewline $f [encoding convertto utf-8 [join [concat [list parse-many] $chunk] \0]]
    close $f
    set mine [lrange [clientLines $exe $argsFile [expr {[llength $chunk] + 1}]] 0 end-1]
    set f [open $argsFile wb]
    puts -nonewline $f [encoding convertto utf-8 [join $chunk \0]]
    close $f
    set theirs [split [string trimright [exec xargs -0 -a $argsFile python3 -I [file join $root tests http uri_oracle.py]] \n] \n]
    foreach u $chunk m $mine t $theirs {
        if {$m ne "invalid"} { incr valid }
        if {$m ne $t} {
            incr disagreements
            puts "DISAGREE [list $u]\n  package: $m\n  oracle:  $t"
        }
    }
}
puts "syntax-fuzz: seed [dict get $opts -seed], [llength $uris] URIs ($valid valid), $disagreements disagreement(s)"

# Header fields.
proc fieldName {} {
    set owned {connection keep-alive proxy-connection transfer-encoding upgrade te host content-length}
    switch [pick {token token token token owned bad}] {
        token {
            set chars "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&'*+-.^_`|~"
            set n [expr {1 + int(rand() * 16)}]
            set s ""
            for {set i 0} {$i < $n} {incr i} { append s [string index $chars [expr {int(rand() * [string length $chars])}]] }
            return $s
        }
        owned {
            set s [pick $owned]
            if {[chance 0.5]} { set s [string toupper $s] }
            return $s
        }
        bad { return [pick {"" "a b" "x:y" "x(y)" "x\"y" "na\u00efve" "x/y" "x@y" "x\ty" "x,y" "\{x\}" "x=y"}] }
    }
}

proc fieldValue {} {
    set pieces {a b z 0 9 - _ . , ; = / "\\" "\"" " " "\t" "\x01" "\x1f" "\x7f" "\r" "\n" "\u00e9" "\u2713" "\U0001F600" Bearer token123}
    set s ""
    for {set i 0} {$i < int(rand() * 8)} {incr i} { append s [pick $pieces] }
    return $s
}

set count [dict get $opts -headers]
if {$count eq ""} { set count [dict get $opts -count] }
set fields {}
for {set i 0} {$i < $count} {incr i} { lappend fields [fieldName] [fieldValue] }
set fieldDisagreements 0
set accepted 0
set batch 200
for {set i 0} {$i < [llength $fields]} {incr i [expr {2 * $batch}]} {
    set chunk [lrange $fields $i [expr {$i + 2 * $batch - 1}]]
    # Through a file of NUL-separated arguments: a field such as "|" or a
    # trailing "&" is redirection syntax to exec.
    set argsFile [file join [file dirname $exe] fields.args]
    set f [open $argsFile wb]
    puts -nonewline $f [encoding convertto utf-8 [join [concat [list headers-many] $chunk] \0]]
    close $f
    set mine [lrange [clientLines $exe $argsFile [expr {[llength $chunk] / 2 + 1}]] 0 end-1]
    set f [open $argsFile wb]
    puts -nonewline $f [encoding convertto utf-8 [join $chunk \0]]
    close $f
    set theirs [split [string trimright [exec xargs -0 -a $argsFile python3 -I [file join $root tests http header_oracle.py]] \n] \n]
    foreach {name value} $chunk m $mine t $theirs {
        if {[string match accepted* $m]} { incr accepted }
        if {$m ne $t} {
            incr fieldDisagreements
            puts "DISAGREE [list $name $value]\n  package: $m\n  oracle:  $t"
        }
    }
}
puts "syntax-fuzz: seed [dict get $opts -seed], $count header fields ($accepted accepted), $fieldDisagreements disagreement(s)"
exit [expr {$disagreements + $fieldDisagreements > 0}]
