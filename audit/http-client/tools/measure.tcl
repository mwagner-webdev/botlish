# measure.tcl -- the http package's measurements (HTTP-CLIENT-PACKAGE-
# MILESTONE-1.md, "Measurements"): audit/http-client/bench/bench.bot
# built with the released unit (no test feature), run against the test
# peers (tests/http/server.py: Python's asyncio, ssl and h2), nghttpd (C)
# serving a 64 MiB file and Python's http.server serving the same file,
# with curl (libcurl, OpenSSL, nghttp2) on the same peers as a baseline.
#
#   tclsh9.0 audit/http-client/tools/measure.tcl ?-runs N?
#
# Prints a table of medians over N runs (default 3). Needs the http
# package's native files (tests/cffi/http.tcl), python3 with h2, openssl,
# nghttpd and curl.

set root [file normalize [file join [file dirname [info script]] .. .. ..]]
set opts [dict create -runs 3]
foreach {k v} $argv { dict set opts $k $v }
set argv {}
package require tcltest
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests cffi http.tcl]

set dir [file tempdir http-measure]
set pids {}
proc cleanup {} {
    foreach p $::pids { catch {exec kill $p} }
    file delete -force $::dir
}

proc peer {args} {
    set log [file join $::dir peer-[llength $::pids].log]
    set pid [exec python3 -I [file join $::root tests http server.py] --port 0 {*}$args > $log 2>/dev/null &]
    lappend ::pids $pid
    for {set i 0} {$i < 100} {incr i} {
        after 100
        if {[regexp {ready (\d+)} [readFile $log] -> port]} { return $port }
    }
    error "peer did not start"
}

proc freePort {} {
    exec python3 -I -c {import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()}
}

proc median {values} {
    set s [lsort -real $values]
    lindex $s [expr {[llength $s] / 2}]
}

proc timed {script} {
    set t [clock microseconds]
    uplevel 1 $script
    expr {[clock microseconds] - $t}
}

try {
    # The application: the released unit, the provider, the driver.
    set t0 [clock milliseconds]
    httppkg::App $dir 0
    file copy [file join $root audit http-client bench bench.bot] $dir
    set checkMs [timed {surface::readProgramFile [file join $dir bench.bot] -warnings error -cache ""}]
    set ::env(BOTLISH_NATIVE_LINKER) system
    set buildUs [timed {
        set hir [surface::readProgramFile [file join $dir bench.bot] -warnings error -cache ""]
        set exe [native::executable $hir [file join $dir bench]]
    }]
    set rows {}
    lappend rows [list "front end, a program importing http (no cache)" [format %.1f [expr {$checkMs / 1e6}]] s]
    lappend rows [list "front end + code generation + system link" [format %.1f [expr {$buildUs / 1e6}]] s]
    lappend rows [list "executable size (bench, not stripped)" [file size $exe] bytes]
    set stripped [file join $dir bench.stripped]
    exec strip -o $stripped $exe
    lappend rows [list "executable size, stripped" [file size $stripped] bytes]
    set unit [file join [httppkg::CacheDir] units release-[httppkg::Host] libbotlish_http.a]
    lappend rows [list "libbotlish_http.a (the unit)" [file size $unit] bytes]
    set provider [file join [httppkg::CacheDir] provider-archives [httppkg::ProviderId]-[httppkg::Host] libbotlish_boringssl.a]
    lappend rows [list "libbotlish_boringssl.a (the provider)" [file size $provider] bytes]

    # The peers.
    exec sh [file join $root tests http pki.sh] [file join $dir pki] 2>/dev/null
    set ca [file join $dir pki ca.pem]
    set plain [peer]
    set tls [peer --tls [file join $dir pki good.pem] [file join $dir pki good.key]]
    set big [file join $dir www big.bin]
    file mkdir [file dirname $big]
    exec head -c 67108864 /dev/urandom > $big
    set ng [freePort]
    lappend pids [exec nghttpd -d [file dirname $big] $ng [file join $dir pki good.key] [file join $dir pki good.pem] > /dev/null 2>@1 &]
    set hs [freePort]
    lappend pids [exec python3 -I -m http.server $hs --bind 127.0.0.1 --directory [file dirname $big] > /dev/null 2>@1 &]
    after 1000

    proc bench {args} {
        set out [exec $::exe {*}$args]
        set d [dict create]
        foreach line [split $out \n] {
            if {[llength $line] == 3} { dict set d [lindex $line 0] [lindex $line 1] }
            if {[string match error* $line]} { error "bench $args: $line" }
        }
        return $d
    }
    set runs [dict get $opts -runs]

    # Latency: sequential GETs of 6 bytes on a warm connection.
    foreach {label url anchors} [list "HTTP/1.1, plaintext" http://127.0.0.1:$plain/hello "" "HTTP/2, TLS" https://localhost:$tls/hello $ca] {
        set us {}; set calls {}
        for {set r 0} {$r < $runs} {incr r} {
            set d [bench latency $url $anchors 200]
            lappend us [expr {[dict get $d latency_total_us] / 200.0}]
            lappend calls [expr {[dict get $d calls_total] / 200.0}]
        }
        set curlUs {}
        for {set r 0} {$r < $runs} {incr r} {
            set urls [lrepeat 201 $url]
            set flags [expr {$anchors eq "" ? {} : [list --http2 --cacert $anchors]}]
            set t [timed {exec curl -s -o /dev/null {*}$flags {*}$urls}]
            lappend curlUs [expr {$t / 201.0}]
        }
        lappend rows [list "latency, $label: one GET, warm connection" [format %.0f [median $us]] us]
        lappend rows [list "  curl on the same peer (201 URLs, one process)" [format %.0f [median $curlUs]] us]
        lappend rows [list "  guarded C calls per request" [format %.1f [median $calls]] calls]
    }
    # Cold: a new client per GET (connect, handshake, request).
    foreach {label url anchors} [list "HTTP/1.1, plaintext" http://127.0.0.1:$plain/hello "" "HTTP/2, TLS (handshake)" https://localhost:$tls/hello $ca] {
        set us {}
        for {set r 0} {$r < $runs} {incr r} {
            set d [bench cold $url $anchors 20]
            lappend us [expr {[dict get $d cold_total_us] / 20.0}]
        }
        lappend rows [list "cold request, $label: new client" [format %.0f [median $us]] us]
    }
    # Throughput: 64 MiB.
    foreach {label url anchors curlFlags} [list "HTTP/2, TLS, nghttpd" https://localhost:$ng/big.bin $ca [list --http2 --cacert $ca] \
            "HTTP/1.0, plaintext, Python http.server" http://127.0.0.1:$hs/big.bin "" {}] {
        set mbs {}; set chunks {}; set calls {}; set growth {}; set held {}
        for {set r 0} {$r < $runs} {incr r} {
            set d [bench stream $url $anchors]
            if {[dict get $d stream_bytes] != 67108864} { error "stream $label: [dict get $d stream_bytes] bytes" }
            lappend mbs [expr {67108864 / 1048576.0 / ([dict get $d stream_us] / 1e6)}]
            lappend chunks [dict get $d stream_chunks]
            lappend calls [expr {double([dict get $d stream_calls]) / [dict get $d stream_chunks]}]
            lappend growth [dict get $d stream_peak_growth]
            lappend held [dict get $d stream_max_held]
        }
        set curlMbs {}
        for {set r 0} {$r < $runs} {incr r} {
            set t [timed {exec curl -s -o /dev/null {*}$curlFlags $url}]
            lappend curlMbs [expr {67108864 / 1048576.0 / ($t / 1e6)}]
        }
        lappend rows [list "download 64 MiB, $label" [format %.0f [median $mbs]] MiB/s]
        lappend rows [list "  curl, the same URL (to /dev/null)" [format %.0f [median $curlMbs]] MiB/s]
        lappend rows [list "  chunks the program read" [median $chunks] chunks]
        lappend rows [list "  guarded C calls per chunk" [format %.2f [median $calls]] calls]
        lappend rows [list "  peak memory growth while 64 MiB passed" [median $growth] KiB]
        lappend rows [list "  most bytes held natively" [median $held] bytes]
    }
    # A slow consumer: nghttpd's 64 MiB over HTTP/2, read with a 2 ms pause
    # after every chunk (4,096 chunks: about 9 s).
    set slowUrl https://localhost:$ng/big.bin
    set d [bench stream $slowUrl $ca 2000]
    lappend rows [list "slow consumer (2 ms per chunk), 64 MiB over HTTP/2: peak memory growth" [dict get $d stream_peak_growth] KiB]
    lappend rows [list "  most bytes held natively" [dict get $d stream_max_held] bytes]
    lappend rows [list "  its throughput" [format %.1f [expr {67108864 / 1048576.0 / ([dict get $d stream_us] / 1e6)}]] MiB/s]
    # Upload: 16 MiB to the Python peer's /echo, by write size.
    foreach {label url anchors} [list "HTTP/1.1, plaintext" http://127.0.0.1:$plain/echo "" "HTTP/2, TLS" https://localhost:$tls/echo $ca] {
        foreach chunk {1024 16384 65536 1048576} {
            set mbs {}; set calls {}
            for {set r 0} {$r < $runs} {incr r} {
                set d [bench upload $url $anchors 16777216 $chunk]
                if {[dict get $d upload_echoed] != 16777216} { error "upload: [dict get $d upload_echoed]" }
                lappend mbs [expr {2 * 16.0 / ([dict get $d upload_us] / 1e6)}]
                lappend calls [expr {double([dict get $d upload_calls]) / (16777216 / $chunk)}]
            }
            lappend rows [list "upload 16 MiB and read it back, $label, writes of $chunk bytes" [format %.0f [median $mbs]] MiB/s]
            lappend rows [list "  guarded C calls per write" [format %.2f [median $calls]] calls]
        }
    }
    # The boundary's costs, with the test unit (its allocation counter):
    # tests/http/client.bot's `costs` scenario, per request and per chunk.
    set tdir [file join $dir test]
    file mkdir $tdir
    httppkg::App $tdir 1
    foreach f {client.bot probe.bot} { file copy [file join $root tests http $f] $tdir }
    set thir [surface::readProgramFile [file join $tdir client.bot] -warnings off -cache ""]
    set client [native::executable $thir [file join $tdir client]]
    proc costs {client args} {
        set out [exec $client costs {*}$args]
        set lines {}
        foreach {- line} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} $out] { lappend lines $line }
        return $lines
    }
    foreach {label url anchors big} [list "HTTP/1.1, plaintext" http://127.0.0.1:$plain/hello "" "http://127.0.0.1:$plain/stream?n=256&size=4096" \
            "HTTP/2, TLS" https://localhost:$tls/hello [readFile $ca] "https://localhost:$tls/stream?n=256&size=4096"] {
        set lines [costs $client $url $anchors 100 $big]
        foreach line [lrange $lines 0 1] {
            set fields [lrange $line 2 end]
            set per [lindex $line 1]
            set what [expr {[lindex $line 0] eq "requests" ? "per request" : "per 4 KiB chunk"}]
            set text {}
            foreach {k v} $fields { lappend text "$k [format %.1f [expr {double($v) / $per}]]" }
            lappend rows [list "$label, $what (test unit)" [join $text {, }] ""]
        }
    }
    # Concurrent HTTP/2 streams: 64 requests of 16 KiB at once, one client.
    set us {}
    for {set r 0} {$r < $runs} {incr r} {
        set t [timed {exec $client concurrent "https://localhost:$tls/stream?n=4&size=4096" [readFile $ca] 64}]
        lappend us $t
    }
    lappend rows [list "64 concurrent HTTP/2 requests of 16 KiB on one connection (whole process)" [format %.0f [expr {[median $us] / 1000.0}]] ms]
    puts "| measurement | value | unit |"
    puts "|---|---:|---|"
    foreach row $rows {
        lassign $row what value unit
        puts "| $what | $value | $unit |"
    }
} finally {
    cleanup
}
