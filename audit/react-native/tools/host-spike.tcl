# host-spike.tcl -- the census's host-side end-to-end probe
# (REACT-NATIVE-TARGET-CENSUS.md, "Empirical results"): Botlish functions
# called from JavaScript through React Native's own C++ TurboModule layer,
# on this machine, with no Android or iOS toolchain.
#
#   tclsh9.0 audit/react-native/tools/host-spike.tcl -work DIR \
#       -react-native-project DIR -hermes-src DIR -hermes-build DIR \
#       -folly DIR ?-gc-stress 1? ?-stack-kib N?
#
#   -react-native-project  a React Native 0.88 project or library with its
#                          node_modules installed (react-native and
#                          @react-native-community/cli): Codegen runs from
#                          there and ReactCommon's sources come from there
#   -hermes-src, -hermes-build  a Hermes checkout at the tag React Native
#                          pins (sdks/hermes-engine/version.properties) and
#                          its CMake build of the hermesvm target
#   -folly                 a folly checkout at React Native's pinned version
#                          (headers only: react/bridging includes
#                          folly/dynamic.h); glog's headers and library come
#                          from the system
#   -gc-stress 1           runs both probes under BOTLISH_NATIVE_GC_STRESS=1
#   -stack-kib N           runs them with an N KiB main-thread stack (the JS
#                          thread's: 512 is an iOS release build's)
#
# Steps: the compiler builds the probe's Botlish library for the host
# (main.tcl -emit-native-library rnprobe: NATIVE-LIBRARY-MILESTONE-1.md);
# rnpackage.tcl generates the package from its manifest and header (running
# Codegen); the generated adapter, ReactCommon's TurboModule sources and
# host/host_main.cpp are compiled and linked with Hermes and the library's
# archive; host/probe.js runs. Then
# the asynchronous probe: host/NativeBotlishAsync.ts joins the package's
# specs, Codegen runs again, and host/host_async.cpp (Promise methods on a
# Botlish worker thread) runs host/async.js.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. ..]]
set opts [dict create -gc-stress 0 -stack-kib 0]
foreach {option value} $argv {
    dict set opts $option $value
}
foreach required {-work -react-native-project -hermes-src -hermes-build -folly} {
    if {![dict exists $opts $required]} {
        puts stderr "missing $required"
        exit 2
    }
    if {$required ne "-work"} {
        dict set opts $required [file normalize [dict get $opts $required]]
    }
}
set work [file normalize [dict get $opts -work]]
file mkdir $work
set project [dict get $opts -react-native-project]
set rn [file join $project node_modules react-native ReactCommon]
set hermesSrc [dict get $opts -hermes-src]
set hermesBuild [dict get $opts -hermes-build]
set tclsh [info nameofexecutable]

proc run {args} {
    if {[lindex $args 0] eq "-cd"} {
        set args [lassign $args - dir]
        set here [pwd]
        cd $dir
        try {
            return [run {*}$args]
        } finally {
            cd $here
        }
    }
    puts "+ [join $args { }]"
    exec {*}$args >@stdout 2>@stderr
}

set lib [file join $work botlish]
set pkg [file join $work "generated package"]
file delete -force $lib
run $tclsh [file join $root main.tcl] -warnings off -emit-native-library rnprobe -out $lib \
    [file join $root audit react-native probe rnprobe.bot]
file delete -force $pkg
run $tclsh [file join $here rnpackage.tcl] -o $pkg \
    -manifest [file join $lib rnprobe.manifest.json] -header [file join $lib rnprobe.h] \
    -name react-native-botlish-probe -codegen-project $project

set generated [file join $pkg android generated jni]
set includes [list -I[file join $pkg cpp] -I[file join $pkg botlish] -I$generated \
    -I[file join $generated react renderer components BotlishProbeSpec] \
    -I$rn -I[file join $rn jsi] -I[file join $rn callinvoker] -I[file join $rn react nativemodule core] \
    -I[file join $hermesSrc API] -I[file join $hermesSrc public] -I[file join $hermesBuild include] \
    -I[dict get $opts -folly] -DFOLLY_NO_CONFIG=1 -DFOLLY_MOBILE=1 -DFOLLY_HAVE_PTHREAD=1 \
    -DFOLLY_CFG_NO_COROUTINES=1 -DFOLLY_HAVE_CLOCK_GETTIME=1]
set sources [list [file join $pkg cpp BotlishProbeModule.cpp] [file join $root audit react-native host host_main.cpp]]
foreach f {TurboModule TurboModuleBinding TurboModuleWithJSIBindings} {
    lappend sources [file join $rn react nativemodule core ReactCommon $f.cpp]
}
lappend sources [file join $rn react bridging LongLivedObject.cpp] [file join $rn react utils jsi-utils.cpp]
proc compile {includes source object} {
    run clang++ -std=c++20 -O1 -g -fno-omit-frame-pointer {*}$includes \
        -DMODULE_HEADER="BotlishProbeModule.h" -DMODULE_CLASS=BotlishProbeModule -c $source -o $object
    return $object
}
# The library's archive and the system libraries its manifest names.
source [file join $root lsp json.tcl]
set f [open [file join $lib rnprobe.manifest.json]]
set systemLibraries [lmap l [lsp::json::elements [lsp::json::get [lsp::json::parse [read $f]] link]] {
    lsp::json::text $l
}]
close $f
proc link {out objects} {
    global lib hermesBuild systemLibraries
    run clang++ -o $out {*}$objects [file join $lib librnprobe.a] \
        -L[file join $hermesBuild lib] -lhermesvm [file join $hermesBuild jsi libjsi.a] \
        -Wl,-rpath,[file join $hermesBuild lib] -lglog {*}$systemLibraries
}
set objects {}
set n 0
foreach source $sources {
    lappend objects [compile $includes $source [file join $work obj[incr n].o]]
}
set probe [file join $work host_probe]
link $probe $objects

# The asynchronous probe's spec, beside the generated ones.
set async [file join $work async-codegen]
file copy -force [file join $root audit react-native host NativeBotlishAsync.ts] [file join $pkg src]
file delete -force $async
run -cd $project npx --no-install @react-native-community/cli codegen --source library \
    --path $pkg --platform android --outputPath $async
set asyncIncludes [lmap i $includes {
    string map [list $generated [file join $async jni]] $i
}]
set asyncProbe [file join $work host_async]
link $asyncProbe [list {*}[lrange $objects 2 end] \
    [compile $asyncIncludes [file join $root audit react-native host host_async.cpp] [file join $work async.o]]]

if {[dict get $opts -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}
set script [list $probe [file join $root audit react-native host probe.js]]
if {[dict get $opts -stack-kib]} {
    set script [list sh -c "ulimit -s [dict get $opts -stack-kib] && exec \"\$0\" \"\$1\"" {*}$script]
}
run {*}$script
set script [list $asyncProbe [file join $root audit react-native host async.js]]
if {[dict get $opts -stack-kib]} {
    set script [list sh -c "ulimit -s [dict get $opts -stack-kib] && exec \"\$0\" \"\$1\"" {*}$script]
}
run {*}$script
