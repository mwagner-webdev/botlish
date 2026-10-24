# bench/macos-app.tcl -- the macOS application's sizes and startup times
# (MACOS-AARCH64-MILESTONE-9.md, "Bundle and download sizes" and "Startup and
# build performance").
#
#   tclsh9.0 bench/macos-app.tcl ?-runs N? APP ?DOWNLOAD.zip?
#
# Sizes: each part of APP (Tcl.framework, the launcher, the compiler
# archive, the driver, the runtime archive), the whole bundle, and the
# download archive when given. Times, the best of N runs (default 7) of
# each, in milliseconds, each run in a fresh process with HOME and PATH
# only:
#
#   process     the launcher exiting before Tcl: a copy without its framework
#   tcl         + loading Tcl.framework and Tcl_Init: a copy without its
#               compiler archive (the launcher exits after Tcl_Init)
#   mount       + mounting the archive: a copy whose archive has no main.tcl
#   -version    + single/main.tcl and main.tcl answering -version
#   -help       Compilerpedia's overview
#   check       -check of a small program (the front end)
#   service     the language server: initialize, a document's diagnostics,
#               shutdown (one session, its analysis worker started)
#   driver      the native driver's own start (botlish-native target ...)
#   jit         a native run of a small program (cranelift)
#   executable  -emit-native-executable of the same program, warm: the
#               front end, Cranelift and the host's link
#   moved       -version from a fresh copy of the bundle, first and second
#               runs (a moved application's first start)
#
# The phases are differences of these: Tcl's load and initialization is
# tcl - process, the archive's mount mount - tcl, the compiler's startup
# -version - mount, the native compilation jit - check, the object and the
# host's link executable - jit. Needs Apple's developer tools (the link).

set runs 7
set args $argv
if {[lindex $args 0] eq "-runs"} {
    set runs [lindex $args 1]
    set args [lrange $args 2 end]
}
lassign $args app download
if {$app eq "" || ![file isdirectory [file join $app Contents]]} {
    puts stderr "usage: tclsh9.0 bench/macos-app.tcl ?-runs N? APP ?DOWNLOAD.zip?"
    exit 2
}
set app [file normalize $app]
set work [file tempdir botlish-measure]
set home [file join $work home]
file mkdir $home

proc size {path} {
    if {[file isfile $path]} { return [file size $path] }
    set total 0
    foreach entry [concat [glob -nocomplain -directory $path *] [glob -nocomplain -directory $path -types hidden *]] {
        if {[file tail $entry] in {. ..} || [file type $entry] eq "link"} continue
        incr total [size $entry]
    }
    return $total
}
proc mb {bytes} { format %.2f [expr {$bytes / 1048576.0}] }

# The best of $runs runs of COMMAND (a list), in ms; failures allowed when
# FAILS.
proc best {command {fails 0}} {
    global runs home
    set best ""
    for {set i 0} {$i < $runs} {incr i} {
        set t [clock microseconds]
        set status [catch {exec env -i HOME=$home PATH=/usr/bin:/bin {*}$command >/dev/null 2>/dev/null}]
        set ms [expr {([clock microseconds] - $t) / 1000.0}]
        if {$status && !$fails} { error "failed: $command" }
        if {$best eq "" || $ms < $best} { set best $ms }
    }
    return [format %.1f $best]
}
proc copyApp {name} {
    global app work
    set dir [file join $work $name]
    file mkdir $dir
    exec cp -R $app $dir
    return [file join $dir Botlish.app]
}

set c [file join $app Contents]
puts "== sizes (MB)"
foreach {label path} [list \
        Tcl.framework [file join $c Frameworks Tcl.framework] \
        "launcher (MacOS/botlish)" [file join $c MacOS botlish] \
        "compiler archive (Resources/botlish.zip)" [file join $c Resources botlish.zip] \
        "native driver (MacOS/botlish-native)" [file join $c MacOS botlish-native] \
        "runtime archive (Resources/libbotlish_runtime.a)" [file join $c Resources libbotlish_runtime.a] \
        Botlish.app $app] {
    puts [format "   %-50s %8s" $label [mb [size $path]]]
}
if {$download ne ""} {
    puts [format "   %-50s %8s" "download ([file tail $download])" [mb [file size $download]]]
}

set launcher [file join $c MacOS botlish]
set program [file join $work small.bot]
set f [open $program w]; puts $f "fn twice(n: int) -> int:\n    2 * n\n\n\[twice(21), 1 + 1\]"; close $f
set noFramework [copyApp no-framework]
file delete -force [file join $noFramework Contents Frameworks Tcl.framework]
set noArchive [copyApp no-archive]
file delete [file join $noArchive Contents Resources botlish.zip]
set noMain [copyApp no-main]
exec sh -c {cd "$1/Contents/Resources" && zip -q -d botlish.zip main.tcl} - $noMain

puts "== startup (ms, best of $runs)"
set times [dict create]
dict set times process [best [list [file join $noFramework Contents MacOS botlish] -version] 1]
dict set times tcl [best [list [file join $noArchive Contents MacOS botlish] -version] 1]
dict set times mount [best [list [file join $noMain Contents MacOS botlish] -version] 1]
dict set times -version [best [list $launcher -version]]
dict set times -help [best [list $launcher -help]]
dict set times check [best [list $launcher -check $program]]
set session [file join $work session.sh]
set f [open $session w]
puts $f {frame() { printf 'Content-Length: %d\r\n\r\n%s' "$(printf %s "$1" | LC_ALL=C wc -c | tr -d ' ')" "$1"; }
{
  frame '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}'
  frame '{"jsonrpc":"2.0","method":"initialized","params":{}}'
  frame "{\"jsonrpc\":\"2.0\",\"method\":\"textDocument/didOpen\",\"params\":{\"textDocument\":{\"uri\":\"file:///tmp/m.bot\",\"languageId\":\"botlish\",\"version\":1,\"text\":\"1 + 1\\n\"}}}"
  frame '{"jsonrpc":"2.0","id":2,"method":"shutdown"}'
  frame '{"jsonrpc":"2.0","method":"exit"}'
} | "$1" -lsp -lsp-scheduler sync}
close $f
dict set times service [best [list /bin/bash $session $launcher]]
dict set times driver [best [list [file join $c MacOS botlish-native] target aarch64-apple-darwin]]
dict set times jit [best [list $launcher -backend cranelift $program]]
dict set times executable [best [list $launcher -warnings off -emit-native-executable $program]]
foreach {name ms} $times {
    puts [format "   %-12s %8s" $name $ms]
}
puts [format "   %-12s %8.1f   (tcl - process: loading Tcl.framework, Tcl_Init)" "  tcl" [expr {[dict get $times tcl] - [dict get $times process]}]]
puts [format "   %-12s %8.1f   (mount - tcl: mounting the compiler archive)" "  mount" [expr {[dict get $times mount] - [dict get $times tcl]}]]
puts [format "   %-12s %8.1f   (-version - mount: single/main.tcl, main.tcl)" "  compiler" [expr {[dict get $times -version] - [dict get $times mount]}]]
puts [format "   %-12s %8.1f   (jit - check: lowering, the driver, Cranelift, the run)" "  native" [expr {[dict get $times jit] - [dict get $times check]}]]
puts [format "   %-12s %8.1f   (executable - jit: the object and the host's link, less the run)" "  link" [expr {[dict get $times executable] - [dict get $times jit]}]]

puts "== a moved application's first and second -version (ms)"
set runs 1
for {set i 0} {$i < 3} {incr i} {
    set moved [copyApp moved-$i]
    set first [best [list [file join $moved Contents MacOS botlish] -version]]
    set second [best [list [file join $moved Contents MacOS botlish] -version]]
    puts "   copy $i: first $first, second $second"
}
file delete -force $work
