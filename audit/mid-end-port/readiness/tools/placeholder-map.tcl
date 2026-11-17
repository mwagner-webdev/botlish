# placeholder-map.tcl -- the reduced reproducer of a quadratic step in
# native lowering (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section
# 12): native::lower::Program numbers the functions it lowered by applying
# one `string map` whose map holds a placeholder per function
# (native::lower::Placeholder: \x01KEY\x02) to every function's text and
# info, so the work is the program's text times its function count. This
# times that step alone for N synthetic functions of about 1 KB each, a few
# placeholders in each (the 32- and 64-pass synthetic programs lower 1,163
# and 2,288 functions into 1,272 and 2,528 KB of NIR).
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/placeholder-map.tcl ?N ...?
set sizes [expr {$argc ? $argv : {1163 2288}}]
set open [format %c 1]
set close [format %c 2]
foreach n $sizes {
    set map {}
    for {set i 0} {$i < $n} {incr i} { lappend map "${open}i$i:canonical$close" $i }
    set texts {}
    for {set i 0} {$i < $n} {incr i} {
        lappend texts "[string repeat {  r12 = op add r3 r4 ;} 30] call ${open}i[expr {$i * 7 % $n}]:canonical$close r1 r2\n"
    }
    set t0 [clock microseconds]
    foreach t $texts { string map $map $t }
    puts [format "%5d functions, %4d KB of text: %.2f s" $n [expr {[string length [join $texts {}]] / 1024}] [expr {([clock microseconds] - $t0) / 1e6}]]
}
