# generate.tcl -- one profile on one target, from headers to files
# (C-BINDGEN.md, "Pipeline").
#
#   ::cbind::generate::run PROFILE TARGET OPTIONS
#
#   header profile + target  ->  the C toolchain for the target (clang --target)
#   -> preprocess, parse, macro probe   (tools/cheader/pipeline.tcl)
#   -> candidates                       (model.tcl: classify every API name)
#   -> ABI probe, symbol probe          (probe.tcl: the compiler's facts)
#   -> signatures, contracts, constants (model.tcl)
#   -> the shim, compiled once to check every thunk; its LLVM IR read for
#      evidence when the profile asks (probe.tcl)
#   -> files                            (emit.tcl, report.tcl)
#
# Each stage's result is plain data (the -dump option writes them all), and
# nothing here parses C or emits Botlish itself.

namespace eval ::cbind::generate {}

# The profile's header profile for TARGET with absolute include
# directories, as the toolchain adapter takes it.
# The revision of RUN's headers: a pinned checkout's commit; for a toolchain
# source, its version macros (the profile's `version`), each of which the
# translation unit must define with exactly the pinned body -- headers of
# another version are not the profile's, the way a checkout at another
# commit is not.
proc ::cbind::generate::Revision {profile run} {
    set source [dict get $profile headers source]
    if {![dict exists $source toolchain]} { return [dict get $run revision] }
    set defined [dict create]
    foreach m [dict get $run macros] {
        if {![dict get [lindex $m 2] undefined]} { dict set defined [lindex $m 1] [dict get [lindex $m 2] body] }
    }
    set out {}
    dict for {macro value} [dict get $source version] {
        if {![dict exists $defined $macro]} {
            error "c-bindgen: the toolchain's headers define no $macro (the profile [dict get $profile name] pins $macro $value)"
        }
        if {[dict get $defined $macro] ne $value} {
            error "c-bindgen: the toolchain's headers are another version: $macro is [dict get $defined $macro], the profile [dict get $profile name] pins $value"
        }
        lappend out "$macro=$value"
    }
    return "[dict get $profile headers library] [join $out { }]"
}

proc ::cbind::generate::ToolProfile {hprofile sourceRoot} {
    set abs {}
    foreach d [dict get $hprofile includeDirs] { lappend abs [file join $sourceRoot $d] }
    return [dict replace $hprofile includeDirs $abs]
}

# The target's user label prefix (__USER_LABEL_PREFIX__) from the
# predefined macros TEXT.
proc ::cbind::generate::LabelPrefix {text} {
    if {[regexp -line {^#define __USER_LABEL_PREFIX__ ?(\S*)$} $text -> prefix]} {
        return $prefix
    }
    return ""
}

# For a Linux target that is not the host, with no sysroot and the system
# headers in use: some directory clang searches must be the target's own
# (one naming its triple: Debian's and Ubuntu's cross C library, which clang
# finds through the GCC cross installation, /usr/TRIPLE/include). Without
# one, clang would read the host's /usr/include as the target's headers --
# another architecture's bits/, or, where they happen to compile, the
# host's declarations under the target's name.
proc ::cbind::generate::CheckCrossHeaders {target config tool hprofile} {
    if {$target eq "windows-x86_64" && "-nostdlibinc" ni [dict get $hprofile flags]
            && "-nostdinc" ni [dict get $hprofile flags]} {
        # MSVC's headers, which clang finds for its MSVC target by itself on
        # a Windows host with Visual Studio's C++ tools: the Windows SDK's
        # Universal CRT (Windows Kits\10\Include\VERSION\ucrt) among the
        # directories it searches. Elsewhere it has none, and no other C
        # library's headers stand in for MSVC's.
        set triple [dict get $config target]
        lassign [::chdr::toolchain::searchDirs $config $tool] ok dirs stderr
        if {$ok && [lsearch -glob -nocase $dirs */ucrt] >= 0} { return }
        error "c-bindgen: [lindex [dict get $config cc] 0] --target=$triple searches no directory of MSVC's C headers ([join $dirs {, }]): windows-x86_64 is MSVC's ABI and toolchain, generated on Windows with Visual Studio's C++ tools and the Windows SDK installed (clang finds their headers itself)"
    }
    if {[string match windows-* $target] && "-nostdlibinc" ni [dict get $hprofile flags]
            && "-nostdinc" ni [dict get $hprofile flags] && [dict get $config sysroot] eq ""} {
        # MinGW-w64's headers, where clang finds them for its mingw32 target
        # (/usr/TRIPLE/include): never the host's /usr/include.
        set triple [dict get $config target]
        lassign [::chdr::toolchain::searchDirs $config $tool] ok dirs stderr
        if {$ok && [lsearch -glob $dirs *$triple*] >= 0} { return }
        error "c-bindgen: [lindex [dict get $config cc] 0] --target=$triple searches no directory of $target's C headers ([join $dirs {, }]): install MinGW-w64's (Debian and Ubuntu: mingw-w64-x86-64-dev), or set BOTLISH_C_SYSROOT_[string map {- _} $target] (or BOTLISH_C_SYSROOT) to a sysroot"
    }
    if {![string match linux-* $target] || $target eq [core::cabi::hostTarget]
            || [dict get $config sysroot] ne "" || "-nostdlibinc" in [dict get $hprofile flags]
            || "-nostdinc" in [dict get $hprofile flags]} {
        return
    }
    set triple [dict get $config target]
    lassign [::chdr::toolchain::searchDirs $config $tool] ok dirs stderr
    if {!$ok} {
        error "c-bindgen: [dict get $config cc] does not list its include directories for $target:\n[string range $stderr 0 2000]"
    }
    if {[lsearch -glob $dirs *$triple*] >= 0} { return }
    set var BOTLISH_C_SYSROOT_[string map {- _} $target]
    error "c-bindgen: $target is not this host's target: [lindex [dict get $config cc] 0] --target=$triple searches no directory of $target's C library headers ([join $dirs {, }]), so it would read the host's as the target's. Install the target's cross C library where clang finds it (Debian and Ubuntu: gcc-$triple, which brings libc6-dev for that architecture), or set $var (or BOTLISH_C_SYSROOT) to a sysroot"
}

proc ::cbind::generate::Seconds {t0} {
    return [format %.3f [expr {([clock microseconds] - $t0) / 1e6}]]
}

# Generates PROFILE (a name or a loaded profile) for TARGET. OPTIONS:
# bool 0|1 (whether C _Bool maps to std::ffi::c::Bool), evidence (overrides the
# profile's), fetch 0|1. Returns {files FILES model MODEL timing TIMING}.
proc ::cbind::generate::run {profile target {options {}}} {
    set options [dict merge {bool 1 fetch 0 evidence ""} $options]
    if {[llength $profile] == 1} { set profile [::cbind::profile::load $profile] }
    if {$target ni [dict get $profile targets]} {
        error "c-bindgen: profile [dict get $profile name] is not generated for $target (its targets: [join [dict get $profile targets] {, }])"
    }
    if {[dict get $options evidence] ne ""} { dict set profile evidence [dict get $options evidence] }
    set timing [dict create]
    set hprofile [::cbind::profile::headersFor $profile $target]
    set config [::chdr::toolchain::configFor $target]
    set sourceRoot [::cbind::profile::sourceRoot $profile [dict get $options fetch] $target]
    set tool [ToolProfile $hprofile $sourceRoot]
    # A target's own system headers, or none: never the host's. Off a Mac,
    # clang for an Apple target would fall back to the host's /usr/include
    # and preprocess Linux's headers as if they were the SDK's.
    if {[string match macos-* $target] && $::tcl_platform(os) ne "Darwin"
            && [dict get $config sysroot] eq "" && "-nostdlibinc" ni [dict get $hprofile flags]} {
        error "c-bindgen: $target needs the macOS SDK's headers: generate on a Mac, or set BOTLISH_C_SYSROOT_[string map {- _} $target] (or BOTLISH_C_SYSROOT) to an SDK directory; the host's own headers are never a target's"
    }
    CheckCrossHeaders $target $config $tool $hprofile

    set t0 [clock microseconds]
    set run [::chdr::pipeline::run $hprofile $sourceRoot $config [dict get $profile name]]
    if {![dict get $run ok]} {
        error "c-bindgen: preprocessing [dict get $profile name] for $target failed:\n[string range [dict get $run stderr] 0 3000]"
    }
    set revision [Revision $profile $run]
    dict set timing preprocess [format %.3f [dict get $run timing preprocess]]
    dict set timing parse [format %.3f [dict get $run timing parse]]
    dict set timing macros [format %.3f [expr {[dict get $run timing macroPreprocess] + [dict get $run timing probe]}]]
    set prefix [LabelPrefix [dict get $run predefined]]

    set t0 [clock microseconds]
    set model [::cbind::model::candidates $profile $target $run $options]

    # The records' field types raise typedef and enum questions of their own
    # (records.tcl): one ABI probe asks them all.
    dict set model requests values [concat [dict get $model requests values] [::cbind::records::requests $model]]
    dict set timing model [Seconds $t0]

    set t0 [clock microseconds]
    set requests [dict get $model requests]
    set values [::cbind::probe::values $config $tool [dict get $requests values]]
    set symbols [::cbind::probe::symbols $config $tool [dict get $requests symbols] $prefix]
    set prototypes [::cbind::probe::prototypes $config $tool [dict get $requests prototypes]]
    dict set timing probes [Seconds $t0]

    set t0 [clock microseconds]
    set model [::cbind::model::resolve $model [dict create values $values symbols $symbols prototypes $prototypes prefix $prefix]]
    dict set model profile $profile
    dict set model target $target
    dict set model run [dict create revision $revision command [dict get $run command] \
        tokens [dict get $run tokens] bytes [string length [dict get $run text]]]
    dict set model toolchain [::chdr::toolchain::describe $config]
    dict set model sourceRoot $sourceRoot
    dict set model labelPrefix $prefix
    set symbolLibs [::cbind::profile::symbolLibraries $profile $target]
    dict set model symbolLibraries $symbolLibs
    if {[llength $symbolLibs]} {
        set model [ImportLibraries $model $config $tool $symbolLibs]
    }
    dict set timing mapping [Seconds $t0]

    # The records: their layout probe (sizeof, _Alignof, offsetof, each
    # member's sizeof, in a translation unit of its own whose member and type
    # names no later macro rewrites), then classification, names and order.
    set t0 [clock microseconds]
    set ::cbind::records::allMacros [dict create]
    foreach m [dict get $run macros] {
        if {![dict get [lindex $m 2] undefined]} { dict set ::cbind::records::allMacros [lindex $m 1] 1 }
    }
    lassign [::cbind::records::probeEntries $model] entries undefs
    set extra ""
    foreach u $undefs { append extra "#undef $u\n" }
    set layoutFacts [::cbind::probe::values $config $tool $entries $extra]
    # The anonymous members' own layouts (sizeof, alignment, their members'
    # offsets), which no C expression asks: clang's record layouts of the
    # records that hold them (probe.tcl's anonymous).
    set owners [::cbind::records::anonymousOwners $model $layoutFacts]
    if {[llength $owners]} {
        lassign [::cbind::probe::anonymous $config $tool $owners $extra] ok blocks message
        dict set layoutFacts anon:layouts [expr {$ok ? [list ok $blocks] : [list error $message]}]
    }
    set model [::cbind::records::resolve $model $layoutFacts]
    dict set model layoutUndefs $undefs
    dict set timing layouts [Seconds $t0]

    set t0 [clock microseconds]
    set model [Thunks $model $config $tool]
    dict set timing shim [Seconds $t0]

    set t0 [clock microseconds]
    set files [::cbind::emit::files $model]
    dict set model files $files
    dict set files report.tsv [::cbind::report::tsv $model]
    if {[dict exists $model layouts] && [dict size [dict get $model layouts]]} {
        dict set files layouts.tsv [::cbind::report::layoutsTsv $model]
    }
    set emitSeconds [Seconds $t0]

    # Every emitted layout checked by the compiler: layouts-check.c asserts
    # the numbers the generated Botlish text states (verify.tcl), compiled
    # here with the target's toolchain; a disagreement stops generation.
    set t0 [clock microseconds]
    set check [::cbind::verify::source $files $profile $target [dict get $model layoutUndefs]]
    if {$check ne ""} {
        dict set files layouts-check.c $check
        lassign [::chdr::toolchain::compile $config $tool $check {-w}] ok stderr
        if {!$ok} {
            error "c-bindgen: the generated layouts disagree with the C compiler (layouts-check.c):\n[string range $stderr 0 3000]"
        }
        # The synthetic layouts' own sizes and alignments, which no C
        # expression asks: against clang's record layouts (verify.tcl).
        set problems [::cbind::verify::anonymous $files [dict get $profile name] $config $tool]
        if {[llength $problems]} {
            error "c-bindgen: the generated layouts disagree with the C compiler's record layouts:\n[join $problems \n]"
        }
    }
    dict set timing verification [Seconds $t0]
    set t0 [clock microseconds]
    dict set files report.txt [::cbind::report::text $model]
    dict set files manifest.txt [::cbind::report::manifest $model $files]
    dict set timing emit [format %.3f [expr {$emitSeconds + [Seconds $t0]}]]
    return [dict create files $files model $model timing $timing]
}

# MODEL with each bound function's library: for a profile whose libraries
# are found by symbol (Windows import libraries), the first library of LIBS
# whose file (the toolchain's -print-file-name) defines the function's link
# symbol, as the toolchain's nm reads it; a function none of them defines
# is unsupported (no-import-library). `inventory` keeps each library's
# defined symbols (the shim's references are attributed from it, Thunks).
proc ::cbind::generate::ImportLibraries {model config tool libs} {
    set owners [dict create]
    set files [dict create]
    foreach lib $libs {
        set path [::chdr::toolchain::libraryFile $config $tool $lib]
        if {$path eq ""} {
            error "c-bindgen: the [dict get $model target] toolchain has no library file for -l$lib (its -print-file-name=lib$lib.a): install the target's import libraries"
        }
        lassign [::chdr::toolchain::symbolsOf $config $path defined] ok symbols stderr
        if {!$ok} { error "c-bindgen: the symbols of $path: [string range $stderr 0 2000]" }
        foreach sym $symbols { dict lappend owners $sym $lib }
        dict set files $lib [file tail $path]
    }
    set out {}
    foreach e [dict get $model apis] {
        if {[dict get $e kind] in {direct alias}} {
            set sym [dict get $e symbol]
            if {![dict exists $owners $sym]} {
                dict set e kind unsupported
                dict set e blockers [list [list no-import-library "no import library the profile searches ([join $libs {, }]) defines $sym"]]
            } else {
                set found [dict get $owners $sym]
                dict set e library [lindex $found 0]
                dict set e libraryAlso [lrange $found 1 end]
            }
        }
        lappend out $e
    }
    dict set model apis $out
    dict set model libraryOwners $owners
    dict set model libraryFiles $files
    return $model
}

# The libraries of LIBS (in order) whose symbols the symbol list REFS
# references, attributed as ImportLibraries does: {LIBRARIES UNRESOLVED}.
proc ::cbind::generate::ReferencedLibraries {model refs} {
    set owners [dict get $model libraryOwners]
    set used {}
    set unresolved {}
    foreach sym $refs {
        if {[dict exists $owners $sym]} {
            set lib [lindex [dict get $owners $sym] 0]
            if {$lib ni $used} { lappend used $lib }
        } else {
            lappend unresolved $sym
        }
    }
    set ordered [lmap l [dict get $model symbolLibraries] {expr {$l in $used ? $l : [continue]}}]
    return [list $ordered $unresolved]
}

# The thunks of MODEL, checked: the shim is compiled once (one translation
# unit, every thunk); a thunk the compiler rejects becomes unsupported with
# its message and the rest is compiled again. With evidence llvm, the
# shim's -O2 LLVM IR gives each thunk's parameter attributes, which become
# proven contract facts (ApplyContracts again, beside the manual ones).
proc ::cbind::generate::Thunks {model config tool} {
    dict set model evidenceProducer ""
    for {set round 0} {$round < 20} {incr round} {
        set thunks [ThunkEntries $model]
        if {![llength $thunks]} { return $model }
        set ::cbind::emit::model $model
        set ::cbind::emit::ns [dict get $model profile name]
        set shim [::cbind::emit::Shim $thunks]
        set dir [file tempdir]
        set path [file join $dir shim.c]
        ::chdr::writeFile $path $shim
        lassign [::chdr::toolchain::object $config $tool $path [file join $dir shim.o] \
            {-Werror=incompatible-pointer-types -Werror=int-conversion -Werror=implicit-function-declaration -Werror=return-type}] ok stderr command
        if {$ok && [llength [dict get $model symbolLibraries]]} {
            # The libraries the shim's own references need (its thunks call
            # the APIs): attributed like every bound function's.
            lassign [::chdr::toolchain::symbolsOf $config [file join $dir shim.o] undefined] nmOk refs nmErr
            if {!$nmOk} { error "c-bindgen: the shim object's symbols: [string range $nmErr 0 2000]" }
            lassign [ReferencedLibraries $model $refs] shimLibs unresolved
            dict set model shimLibraries $shimLibs
            dict set model shimUnresolved $unresolved
        }
        file delete -force $dir
        if {$ok} break
        set lines [dict create]
        set n 0
        set current ""
        foreach line [split $shim \n] {
            incr n
            foreach e $thunks {
                if {[string first "[dict get $e symbol](" $line] >= 0 && [string index [string trimright $line] end] eq "\{"} {
                    set current [dict get $e name]
                }
            }
            if {$current ne ""} { dict set lines $n $current }
        }
        set blame [::cbind::probe::Blame [string map [list $path probe.c] $stderr] $lines]
        if {![dict size $blame]} {
            error "c-bindgen: the shim does not compile, and no thunk is to blame:\n[string range $stderr 0 3000]"
        }
        set out {}
        foreach e [dict get $model apis] {
            if {[dict exists $blame [dict get $e name]] && [dict get $e kind] eq "thunk"} {
                dict set e kind unsupported
                dict set e blockers [list [list thunk-rejected "the C compiler rejects the thunk: [dict get $blame [dict get $e name]]"]]
            }
            lappend out $e
        }
        dict set model apis $out
    }
    set evidence [dict create]
    set producer ""
    if {[dict get $model profile evidence] eq "llvm"} {
        set syms [lmap e [ThunkEntries $model] {dict get $e symbol}]
        lassign [::cbind::probe::evidence $config $tool $shim $syms] ok message evidence producer
        if {!$ok} {
            error "c-bindgen: the shim's LLVM IR (evidence llvm) failed: [string range $message 0 2000]"
        }
    }
    dict set model evidenceProducer $producer
    set out {}
    foreach e [dict get $model apis] {
        if {[dict get $e kind] eq "thunk" && [dict exists $evidence [dict get $e symbol]]} {
            set manual [dict get $model manual]
            set m [expr {[dict exists $manual [dict get $e name]] ? [dict get $manual [dict get $e name]] : {}}]
            set e [::cbind::model::ApplyContracts $e $m [dict get $evidence [dict get $e symbol]]]
        }
        lappend out $e
    }
    dict set model apis $out
    return $model
}

proc ::cbind::generate::ThunkEntries {model} {
    set out {}
    foreach e [dict get $model apis] {
        if {[dict get $e kind] eq "thunk"} { lappend out $e }
    }
    return $out
}

# Writes FILES under DIR, removing the generated files of an earlier run
# that this one no longer produces (the binding modules, the shim and the
# records; nothing else in DIR is touched).
proc ::cbind::generate::write {files dir ns} {
    file mkdir $dir
    foreach old [Existing $dir $ns] {
        if {![dict exists $files $old]} { file delete [file join $dir $old] }
    }
    dict for {path text} $files {
        ::chdr::writeFile [file join $dir $path] $text
    }
}

# The generated files present under DIR (relative paths), sorted.
proc ::cbind::generate::Existing {dir ns} {
    set out {}
    foreach f {shim.c manifest.txt report.txt report.tsv layouts.tsv layouts-check.c} {
        if {[file exists [file join $dir $f]]} { lappend out $f }
    }
    set stack [list $ns]
    while {[llength $stack]} {
        set stack [lassign $stack rel]
        set abs [file join $dir $rel]
        if {![file isdirectory $abs]} continue
        foreach f [lsort [glob -nocomplain -directory $abs -tails *]] {
            if {[file isdirectory [file join $abs $f]]} {
                lappend stack $rel/$f
            } elseif {[string match *.bot $f]} {
                lappend out $rel/$f
            }
        }
    }
    return [lsort $out]
}

# The differences between FILES and what DIR holds: a list of
# {PATH STATUS DETAIL}, STATUS added, removed or changed (DETAIL the first
# differing lines).
proc ::cbind::generate::compare {files dir ns} {
    set out {}
    set existing [Existing $dir $ns]
    foreach path [lsort [dict keys $files]] {
        set abs [file join $dir $path]
        if {![file exists $abs]} {
            lappend out [list $path missing "not committed (generate writes it)"]
            continue
        }
        set old [::chdr::readFile $abs]
        set new [dict get $files $path]
        if {$old ne $new} {
            lappend out [list $path changed [FirstDifference $old $new]]
        }
    }
    foreach path $existing {
        if {![dict exists $files $path]} {
            lappend out [list $path stale "committed, but generation no longer produces it"]
        }
    }
    return $out
}

proc ::cbind::generate::FirstDifference {old new} {
    set a [split $old \n]
    set b [split $new \n]
    set n [expr {max([llength $a], [llength $b])}]
    set shown {}
    for {set i 0} {$i < $n && [llength $shown] < 6} {incr i} {
        set x [lindex $a $i]
        set y [lindex $b $i]
        if {$x ne $y} {
            lappend shown "line [expr {$i + 1}]:\n      committed: $x\n      generated: $y"
        }
    }
    return [join $shown "\n    "]
}

# The coverage change between the committed report.tsv in DIR and the
# generated RESULT's: one line per name whose status or reason changed
# (~), that appeared (+) or disappeared (-).
proc ::cbind::generate::coverageChange {dir result} {
    set path [file join $dir report.tsv]
    if {![file exists $path]} { return {} }
    set old [readTsv [::chdr::readFile $path]]
    set new [readTsv [dict get $result files report.tsv]]
    set lines {}
    dict for {key row} $new {
        if {![dict exists $old $key]} {
            lappend lines "+ $key: [lindex $row 2] [lindex $row 4]"
        } elseif {[lrange [dict get $old $key] 2 end] ne [lrange $row 2 end]} {
            lappend lines "~ $key: [lindex [dict get $old $key] 2] [lindex [dict get $old $key] 4] -> [lindex $row 2] [lindex $row 4]"
        }
    }
    dict for {key row} $old {
        if {![dict exists $new $key]} { lappend lines "- $key: was [lindex $row 2] [lindex $row 4]" }
    }
    return $lines
}

# The rows of a report.tsv TEXT: "KIND NAME" -> row.
proc ::cbind::generate::readTsv {text} {
    set out [dict create]
    foreach line [lrange [split [string trimright $text \n] \n] 1 end] {
        set row [split $line \t]
        dict set out "[lindex $row 0] [lindex $row 1]" $row
    }
    return $out
}

# Compiles the shim.c of the generated binding in DIR (PROFILE/TARGET's
# committed one by default) into its static library lib<shim_library>.a in
# OUT, with the target's toolchain; returns OUT, or "" when the binding has
# no shim.
proc ::cbind::generate::buildShim {profile target out {dir ""}} {
    if {$dir eq ""} { set dir [::cbind::profile::outputDir $profile $target] }
    set shimPath [file join $dir shim.c]
    if {![file exists $shimPath]} { return "" }
    if {$out eq ""} { error "c-bindgen build: -out DIR is required" }
    set manifest [::chdr::readFile [file join $dir manifest.txt]]
    if {![regexp -line {^shim_library (\S+)$} $manifest -> name]} {
        error "c-bindgen build: no shim_library in [file join $dir manifest.txt]"
    }
    set sourceRoot [::cbind::profile::sourceRoot $profile 0 $target]
    set hprofile [::cbind::profile::headersFor $profile $target]
    set tool [ToolProfile $hprofile $sourceRoot]
    set config [::chdr::toolchain::configFor $target]
    file mkdir $out
    set obj [file join $out $name.o]
    lassign [::chdr::toolchain::object $config $tool $shimPath $obj {-O2 -fPIC -w}] ok stderr
    if {!$ok} { error "c-bindgen build: the shim does not compile:\n$stderr" }
    set archive [file join $out lib$name.a]
    lassign [::chdr::toolchain::archive $config [list $obj] $archive] ok stderr
    if {!$ok} { error "c-bindgen build: ar failed: $stderr" }
    file delete $obj
    return $out
}

# Copies the files of application APP (a directory, or a program file and
# the application modules beside it) and the generated binding in DIR
# (PROFILE/TARGET's committed one by default) into INTO: one application
# root, which the ordinary compiler compiles. With PACKAGE 1 the binding is
# installed as the application's package instead (INTO/.bot_modules/NS/NS/,
# NS the profile's namespace: BOT-MODULES-MILESTONE-1.md), its own scope
# beside the application's modules rather than files of the application.
proc ::cbind::generate::stage {profile target app into {dir ""} {package 0}} {
    if {$dir eq ""} { set dir [::cbind::profile::outputDir $profile $target] }
    if {![file isdirectory [file join $dir [dict get $profile name]]]} {
        error "c-bindgen stage: no generated binding in $dir (run generate)"
    }
    file mkdir $into
    if {$app ne ""} {
        set appDir [expr {[file isdirectory $app] ? $app : [file dirname $app]}]
        foreach f [glob -nocomplain -directory $appDir *] {
            file copy -force $f $into
        }
    }
    set ns [dict get $profile name]
    if {$package} {
        set into [file join $into .bot_modules $ns]
        file delete -force $into
        file mkdir $into
    }
    file delete -force [file join $into $ns]
    file copy -force [file join $dir $ns] [file join $into $ns]
}
