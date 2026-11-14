# rlf.tcl -- the author's side and the acceptance of the Rust link fixture
# (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md). Runs on Linux
# (x86-64, AArch64) and on macOS AArch64 with tclsh9.0; every native step is
# the host's own toolchain (cargo, cc, ld, nm), every package step a Botlish
# compiler given as COMPILER (a command: "tclsh9.0 /path/main.tcl", the
# single executable, Botlish.app's botlish).
#
#   unit -target T -out DIR [-features default|plain] [-notify weakdef|weakref|strong]
#        [-localize 1|0] [-exports PATTERNS] [-toolchain NAME] [-work DIR]
#       cargo-build the fixture (audit/rust-archive-link/fixture) for T, the
#       host's target, and localize it (tools/rust-unit.tcl): DIR/libbotlish_rlf.a
#       and DIR/UNIT.txt (what was built, by which tools, its SHA-256)
#   provider -target T -out DIR
#       the provider package's archive, DIR/librlf_provider.a
#   stage -compiler COMPILER -out DIR TARGET UNITDIR PROVIDERDIR ...
#       the packages `rlf` and `rlf_provider` for every TARGET: native add
#       (each declared C function a -symbol), native audit, package pack --
#       twice, the two artifacts compared byte for byte; DIR/repo holds them
#   consumer -compiler COMPILER -repository DIR -dir APP -target T [-report FILE]
#       a clean consumer project made with the package manager only (add,
#       verify, native plan), its two programs compiled to executables, run,
#       their values compared, their symbols inspected
#   app -dir APP -unit ARCHIVE -provider ARCHIVE
#       a hand-assembled application (the controls': no package manager)
#   control -compiler COMPILER -dir APP -program P [-linker L]
#       compile P in APP: {built 0|1 value V message M}
#   inspect -target T EXECUTABLE ?provided 0|1?
#       the symbol checks of a consumer executable (below)
#   controls -compiler COMPILER -work DIR [-linkers {rustc system}] [-skew TOOLCHAIN]
#       the negative controls and variants (Variants, below), each linked by
#       each linker and run: DIR/CONTROLS.txt, and whether every
#       expectation held
#
# The consumer's programs and the texts they must produce are the same on
# every target (consumer/; `expected`, below): the ENOSYS a refused post
# carries is the target's own, checked by the program against the unit's
# report of it, not spelled here.
namespace eval rlf {
    variable here [file dirname [file normalize [info script]]]
    variable audit [file dirname $here]
    variable root [file dirname [file dirname $audit]]
    variable expected {
        basic {version 1; pushes 1, 2, 3; sum 60; describe [store 1: 3 of 3 values, sum 60, 3 distinct, most 10×1]; full -3; panic -99; after 60; held yes; destroy 0; stale -2; cycles 100; live 0; allocator balanced; allocations counted; notify refused-enosys}
        provided {version 1; pushes 1, 2, 3; sum 60; describe [store 1: 3 of 3 values, sum 60, 3 distinct, most 10×1]; full -3; panic -99; after 60; held yes; destroy 0; stale -2; cycles 100; live 0; allocator balanced; allocations counted; notify accepted 5; provider posts 5 total 10}
    }
}
source [file join $rlf::root tools rust-unit.tcl]

proc rlf::Log {text} {
    puts stderr "rlf: $text"
}

proc rlf::Read {path} {
    set f [open $path rb]
    set data [read $f]
    close $f
    return $data
}

proc rlf::Write {path text} {
    file mkdir [file dirname $path]
    set f [open $path wb]
    puts -nonewline $f $text
    close $f
}

proc rlf::Sha256 {path} {
    if {[auto_execok sha256sum] ne ""} {
        return [lindex [exec sha256sum $path] 0]
    }
    return [lindex [exec shasum -a 256 $path] 0]
}

# The first line of a tool's version output, or "none".
proc rlf::ToolVersion {args} {
    if {[catch {exec {*}$args 2>@1} out]} {
        return "none"
    }
    return [string trim [lindex [split $out \n] 0]]
}

# The host's compilation target (the only one a unit is built for here).
proc rlf::HostTarget {} {
    set os [string tolower $::tcl_platform(os)]
    set machine $::tcl_platform(machine)
    if {$os eq "darwin" && $machine in {arm64 aarch64}} { return macos-aarch64 }
    if {$os eq "linux" && $machine in {x86_64 amd64}} { return linux-x86_64 }
    if {$os eq "linux" && $machine in {aarch64 arm64}} { return linux-aarch64 }
    error "rlf: no target for $os $machine"
}

proc rlf::CheckHost {target} {
    if {$target ne [HostTarget]} {
        error "rlf: units are built for the host's target only ([HostTarget]), not $target"
    }
}

# The C functions a module declares: the NAMEs of its `extern c fn NAME(`
# lines.
proc rlf::DeclaredNames {module} {
    set out {}
    foreach {- name} [regexp -all -inline -line {^(?:private )?extern c fn ([A-Za-z_][A-Za-z0-9_]*)\(} [Read $module]] {
        lappend out $name
    }
    return [lsort -unique $out]
}

# Build the fixture for TARGET into OUT (see the header).
proc rlf::Unit {target out options} {
    variable audit
    variable root
    CheckHost $target
    set features [dict get $options -features]
    set notify [dict get $options -notify]
    set localize [dict get $options -localize]
    set toolchain [dict get $options -toolchain]
    set crate [file join $audit fixture]
    file mkdir $out
    set out [file normalize $out]
    set work [dict get $options -work]
    if {$work eq ""} { set work [file join $out work] }
    set work [file normalize $work]
    set targetDir [file join $work cargo]
    file delete -force $targetDir
    set home [expr {[info exists ::env(CARGO_HOME)] && $::env(CARGO_HOME) ne "" ? $::env(CARGO_HOME) : [file join [file home] .cargo]}]
    # Paths mapped out of the archive (panic locations, file symbols): the
    # crate, the cargo home, the build directory, the checkout.
    set remap [list --remap-path-prefix=$crate=/botlish_rlf --remap-path-prefix=$home=/cargo \
        --remap-path-prefix=$targetDir=/target --remap-path-prefix=[file normalize $root]=/botlish]
    set cflags "-ffile-prefix-map=$crate=/botlish_rlf -ffile-prefix-map=$targetDir=/target"
    set env [dict create CARGO_TARGET_DIR $targetDir RUSTFLAGS [join $remap " "] CFLAGS $cflags \
        SOURCE_DATE_EPOCH 0 CARGO_INCREMENTAL 0 RLF_NOTIFY $notify ZERO_AR_DATE 1]
    set cargo [list cargo]
    if {$toolchain ne ""} { lappend cargo +$toolchain }
    lappend cargo build --release --locked --manifest-path [file join $crate Cargo.toml]
    if {$features eq "plain"} {
        lappend cargo --no-default-features
    }
    Log "unit $target ($features, $notify, localize $localize): [join $cargo]"
    rustunit::WithEnv $env {
        exec {*}$cargo >@stderr 2>@stderr
    }
    set raw [file join $targetDir release libbotlish_rlf.a]
    set unit [file join $out libbotlish_rlf.a]
    file delete -force $unit
    set exports {}
    if {$localize} {
        set exports [rustunit::Localize $target $raw $unit [dict get $options -exports] $work]
    } else {
        file copy $raw $unit
    }
    set rustc [ToolVersion rustc {*}[expr {$toolchain ne "" ? [list +$toolchain] : {}}] --version]
    set record [dict create target $target features $features notify $notify localized $localize exports $exports \
        sha256 [Sha256 $unit] size [file size $unit] rustc $rustc cargo [ToolVersion {*}[lrange $cargo 0 [expr {$toolchain ne "" ? 1 : 0}]] --version] \
        cc [ToolVersion cc --version]]
    if {[rustunit::Format $target] eq "macho"} {
        dict set record ld [ToolVersion ld -v]
        dict set record sdk [ToolVersion xcrun --show-sdk-version]
    } else {
        dict set record ld [ToolVersion ld --version]
    }
    Write [file join $out UNIT.txt] "$record\n"
    Log "unit $target: [dict get $record sha256] ([llength $exports] exports)"
    return $unit
}

# The provider package's archive for TARGET in OUT.
proc rlf::Provider {target out} {
    variable audit
    CheckHost $target
    file mkdir $out
    set out [file normalize $out]
    set object [file join $out rlf_provider.o]
    set archive [file join $out librlf_provider.a]
    file delete -force $object $archive
    exec cc -O2 -fPIC -Wall -Wextra -Werror -c [file join $audit provider rlf_provider.c] -o $object
    rustunit::WithEnv {ZERO_AR_DATE 1} {
        if {[rustunit::Format $target] eq "macho"} {
            exec libtool -static -D -o $archive $object
        } else {
            exec ar rcsD $archive $object
        }
    }
    file delete $object
    Write [file join $out PROVIDER.txt] "[dict create target $target sha256 [Sha256 $archive] cc [ToolVersion cc --version]]\n"
    return $archive
}

# Run the Botlish compiler COMPILER (a command list) with ARGS in DIR:
# {code OUTPUT}.
proc rlf::Botlish {compiler dir args} {
    set saved [pwd]
    cd $dir
    try {
        set code [catch {exec {*}$compiler {*}$args 2>@1} out]
    } finally {
        cd $saved
    }
    return [list $code $out]
}

proc rlf::Must {compiler dir args} {
    lassign [Botlish $compiler $dir {*}$args] code out
    if {$code} {
        error "rlf: [join $args] failed in $dir:\n$out"
    }
    return $out
}

# The packages for TARGETS ({TARGET UNITDIR PROVIDERDIR} ...) in OUT/repo.
proc rlf::Stage {compiler out targets} {
    variable audit
    set out [file normalize $out]
    set stage [file join $out stage]
    file delete -force $stage [file join $out repo] [file join $out pack-a] [file join $out pack-b]
    file mkdir $stage [file join $out repo]
    set report {}
    foreach {pkg library archiveName} {rlf botlish_rlf libbotlish_rlf.a rlf_provider rlf_provider librlf_provider.a} {
        set dir [file join $stage $pkg]
        file copy [file join $audit packages $pkg] $dir
        set module [file join $dir $pkg.bot]
        set symbols {}
        foreach s [DeclaredNames $module] { lappend symbols -symbol $s }
        foreach {target unitDir providerDir} $targets {
            set from [expr {$pkg eq "rlf" ? $unitDir : $providerDir}]
            set archive [file normalize [file join $from $archiveName]]
            lappend report "$pkg $target: [Must $compiler $dir native add $archive -target $target -name $library -license MIT {*}$symbols]"
        }
        lappend report "$pkg audit:\n[Must $compiler $dir native audit .]"
        foreach side {a b} {
            file mkdir [file join $out pack-$side]
            lappend report "$pkg pack $side: [Must $compiler $dir package pack . -out [file join $out pack-$side]]"
        }
        set a [file join $out pack-a $pkg-0.1.0.botpkg]
        set b [file join $out pack-b $pkg-0.1.0.botpkg]
        if {[Read $a] ne [Read $b]} {
            error "rlf: two packs of $pkg differ ([Sha256 $a], [Sha256 $b])"
        }
        file copy $a [file join $out repo]
        lappend report "$pkg-0.1.0.botpkg [Sha256 $a] (packed twice, identical)"
    }
    Write [file join $out STAGE.txt] [join $report \n]\n
    return [file join $out repo]
}

# Run the executable EXE with the driver's result protocol: {status VALUE
# STDERR}.
proc rlf::RunExecutable {exe} {
    set result [file join [file dirname $exe] [file tail $exe].result]
    file delete -force $result
    set saved [expr {[info exists ::env(BOTLISH_NATIVE_RESULT)] ? $::env(BOTLISH_NATIVE_RESULT) : ""}]
    set ::env(BOTLISH_NATIVE_RESULT) $result
    try {
        set code [catch {exec $exe 2>@1} out]
    } finally {
        if {$saved eq ""} { unset ::env(BOTLISH_NATIVE_RESULT) } else { set ::env(BOTLISH_NATIVE_RESULT) $saved }
    }
    set value ""
    if {[file exists $result]} {
        set f [open $result r]
        fconfigure $f -encoding utf-8
        set text [read $f]
        close $f
        foreach line [split $text \n] {
            if {[string match "value *" $line]} {
                set value [lindex [lindex [string range $line 6 end] 0] 1]
            }
        }
    }
    return [list $code $value $out]
}

# Symbol lines of FILE (nm, POSIX output): {NAME TYPE} pairs, Apple's
# leading underscore dropped on Mach-O.
proc rlf::Symbols {format file} {
    set out {}
    foreach line [split [exec nm -P $file 2>/dev/null] \n] {
        set fields [regexp -inline -all {\S+} $line]
        if {[llength $fields] < 2 || [string match *: [lindex $fields 0]]} continue
        lassign $fields name type
        if {$format eq "macho" && [string index $name 0] eq "_"} {
            set name [string range $name 1 end]
        }
        lappend out $name $type
    }
    return $out
}

# The symbol checks of a consumer executable EXE of TARGET (PROVIDED: its
# program links the provider): a dict of facts and a list of failures.
#   personality  global definitions of rust_eh_personality: exactly one, the
#                Botlish runtime's (the unit's is local)
#   allocator    global definitions of __rust_alloc (any mangling): exactly
#                one, the runtime's shim (the unit's counting allocator is
#                local: its LIVE counter is a local data symbol)
#   post         the definition of rlfp_post: one, global -- weak (the
#                unit's fallback) without the provider, strong with it
#   crate        global symbols of the unit's own crate (botlish_rlf's
#                mangled paths): none, every one localized
proc rlf::Inspect {target exe provided} {
    set format [rustunit::Format $target]
    set facts [dict create personality 0 allocator 0 post {} counting {} crate 0]
    set failures {}
    foreach {name type} [Symbols $format $exe] {
        if {$type in {U u w v}} continue
        set global [expr {![string is lower $type]}]
        if {$name eq "rust_eh_personality" && $global} { dict incr facts personality }
        if {[regexp {___rust_alloc$|^__rust_alloc$|^__rustc::__rust_alloc$} $name] && $global} { dict incr facts allocator }
        if {$name eq "rlfp_post"} { dict lappend facts post $type }
        if {[string match *botlish_rlf*counting*LIVE* $name]} { dict lappend facts counting $type }
        if {[string match *11botlish_rlf* $name] && $global} { dict incr facts crate }
    }
    if {[dict get $facts personality] != 1} { lappend failures "[dict get $facts personality] global rust_eh_personality" }
    if {[dict get $facts allocator] != 1} { lappend failures "[dict get $facts allocator] global __rust_alloc" }
    if {[llength [dict get $facts post]] != 1} { lappend failures "rlfp_post defined [llength [dict get $facts post]] times" }
    # (A linker that keeps no local symbol leaves the counter unnamed: only
    # a global one is a failure.)
    foreach t [dict get $facts counting] {
        if {![string is lower $t]} { lappend failures "the unit's counting allocator state is global ($t)" }
    }
    if {[dict get $facts crate] != 0} { lappend failures "[dict get $facts crate] global symbols of the unit's crate" }
    set post [lindex [dict get $facts post] 0]
    if {$provided && $post ne "T"} { lappend failures "rlfp_post is $post with the provider (its strong definition expected)" }
    if {!$provided && $post ni {W T}} { lappend failures "rlfp_post is $post without the provider" }
    return [list $facts $failures]
}

# A clean consumer project in APP from REPOSITORY with the package manager
# only, for TARGET (the host's); its programs compiled, run and inspected.
proc rlf::Consumer {compiler repository app target reportFile} {
    variable audit
    variable expected
    set app [file normalize $app]
    file delete -force $app
    file mkdir $app
    set report {}
    set failures {}
    lappend report "consumer $app for $target"
    foreach name {rlf rlf_provider} {
        lappend report "add $name: [Must $compiler $app add $name -repository $repository -target $target]"
    }
    lappend report "verify: [Must $compiler $app verify -repository $repository]"
    lappend report "native plan:\n[Must $compiler $app native plan -target $target]"
    foreach f {rlfchecks.bot basic.bot provided.bot} {
        file copy [file join $audit consumer $f] $app
    }
    foreach program {basic provided} {
        lassign [Botlish $compiler $app -warnings error -emit-native-executable $program.bot] code out
        lappend report "$program compile ($code): $out"
        if {$code} {
            lappend failures "$program did not compile: $out"
            continue
        }
        set exe [file join $app $program]
        if {![file exists $exe] && [file exists $exe.exe]} { set exe $exe.exe }
        lassign [RunExecutable $exe] status value stderr
        lappend report "$program run: status $status, value {$value}, output {$stderr}"
        if {$status != 0} { lappend failures "$program exited $status: $stderr" }
        if {$value ne [dict get $expected $program]} {
            lappend failures "$program value {$value}, expected {[dict get $expected $program]}"
        }
        lassign [Inspect $target $exe [expr {$program eq "provided"}]] facts problems
        lappend report "$program symbols: $facts"
        foreach p $problems { lappend failures "$program: $p" }
        lappend report "$program sha256 [Sha256 $exe] size [file size $exe]"
    }
    lappend report [expr {$failures eq "" ? "CONSUMER PASSED" : "CONSUMER FAILED:\n  [join $failures "\n  "]"}]
    if {$reportFile ne ""} { Write $reportFile [join $report \n]\n }
    puts [join $report \n]
    return [expr {$failures eq ""}]
}

# A hand-assembled application in APP: the packages' modules and the given
# archives in .bot_modules, the consumer's programs beside them.
proc rlf::App {app unit provider} {
    variable audit
    set app [file normalize $app]
    file delete -force $app
    foreach {pkg archive name} [list rlf $unit libbotlish_rlf.a rlf_provider $provider librlf_provider.a] {
        set dir [file join $app .bot_modules $pkg]
        file mkdir [file join $dir native]
        file copy [file join $audit packages $pkg $pkg.bot] $dir
        file copy [file normalize $archive] [file join $dir native $name]
    }
    foreach f {rlfchecks.bot basic.bot provided.bot} {
        file copy [file join $audit consumer $f] $app
    }
    return $app
}

# Compile PROGRAM in APP with LINKER ("" the compiler's default): {built
# 0|1 value V status S message M}.
proc rlf::Control {compiler app program linker} {
    set saved [expr {[info exists ::env(BOTLISH_NATIVE_LINKER)] ? $::env(BOTLISH_NATIVE_LINKER) : "\x00"}]
    if {$linker ne ""} { set ::env(BOTLISH_NATIVE_LINKER) $linker }
    try {
        file delete -force [file join $app $program] [file join $app $program.exe]
        lassign [Botlish $compiler $app -warnings off -emit-native-executable $program.bot] code out
    } finally {
        if {$saved eq "\x00"} { unset -nocomplain ::env(BOTLISH_NATIVE_LINKER) } else { set ::env(BOTLISH_NATIVE_LINKER) $saved }
    }
    set result [dict create built [expr {!$code}] value "" status "" message [string trim $out]]
    if {!$code} {
        lassign [RunExecutable [file join $app $program]] status value stderr
        dict set result status $status
        dict set result value $value
    }
    return $result
}

# The negative controls and the variants (HTTP-MACOS-RUST-ARCHIVE-LINK-
# FEASIBILITY-MILESTONE-1.md, "Negative tests"): each a unit built and
# localized (or not) one way, linked by each linker into a hand-assembled
# application (no package manager: the question is the linker's) and run.
# VARIANT: {name features notify localize exports toolchain}.
proc rlf::Variants {skew} {
    set variants {
        localized       default weakdef 1 {rlf_* rlfp_post} ""
        unlocalized     default weakdef 0 {}                ""
        unlocalized-plain plain weakdef 0 {}                ""
        missing-export  default weakdef 1 {rlf_[a-r]* rlf_[t-z]* rlfp_post} ""
        weakref         default weakref 1 {rlf_*}           ""
        strong          default strong  1 {rlf_*}           ""
    }
    if {$skew ne ""} {
        lappend variants skew-localized default weakdef 1 {rlf_* rlfp_post} $skew \
            skew-unlocalized-plain plain weakdef 0 {} $skew
    }
    return $variants
}

# What each control must do, per object format: {VARIANT PROGRAM LINKER}
# -> {built 0|1, and either a word of the link's failure or a word of the
# program's value}; "" for no expectation (recorded only). Established on
# ELF first (the report's "Negative tests"), then on Mach-O by CI.
proc rlf::ControlExpected {format variant program linker} {
    set e {}
    switch -glob -- $variant {
        localized - skew-localized {
            set e [list 1 [expr {$program eq "provided" ? "notify accepted 5" : "notify refused-enosys"}]]
        }
        missing-export { set e {0 rlf_sum} }
        strong { set e [expr {$program eq "provided" ? {1 {notify accepted 5}} : {0 rlfp_post}}] }
    }
    if {$format eq "elf"} {
        switch -- $variant {
            unlocalized {
                set e [expr {$linker eq "rustc" ? {0 {duplicate symbol}} : {1 {allocator unbalanced}}}]
            }
            unlocalized-plain {
                set e [list 1 [expr {$program eq "provided" ? "notify accepted 5" : "notify refused-enosys"}]]
            }
            weakref {
                set e [list 1 [expr {$program eq "provided" ? "notify accepted 5" : "notify refused-enosys"}]]
            }
            skew-unlocalized-plain { set e {0 rust_eh_personality} }
        }
    }
    return $e
}

# Build every variant for TARGET in WORK and run its controls with COMPILER
# under LINKERS: a report (REPORT) and whether every expectation held.
proc rlf::Controls {compiler target work linkers skew reportFile} {
    set work [file normalize $work]
    file mkdir $work
    set provider [Provider $target [file join $work provider]]
    set format [rustunit::Format $target]
    set report {}
    set failures {}
    foreach {name features notify localize exports toolchain} [Variants $skew] {
        set dir [file join $work $name]
        set options [dict create -features $features -notify $notify -localize $localize -exports $exports \
            -toolchain $toolchain -work [file join $dir work]]
        if {[catch {Unit $target [file join $dir unit] $options} unit]} {
            lappend report "$name: the unit did not build: $unit"
            lappend failures "$name: the unit did not build"
            continue
        }
        set record [string trim [Read [file join $dir unit UNIT.txt]]]
        lappend report "$name: [dict get $record rustc]; localized [dict get $record localized]; sha256 [dict get $record sha256]; surface [rustunit::Defined $format $unit]"
        set app [App [file join $dir app] $unit $provider]
        foreach program {basic provided} {
            foreach linker $linkers {
                set r [Control $compiler $app $program $linker]
                set built [dict get $r built]
                set value [dict get $r value]
                set message [dict get $r message]
                set excerpt [join [lrange [lmap l [split $message \n] {expr {[regexp -nocase {error|duplicate|undefined|symbol} $l] && ![string match "*native link failed*" $l] ? [string trim $l] : [continue]}}] 0 5] " | "]
                set expect [ControlExpected $format $name $program $linker]
                set verdict recorded
                if {$expect ne ""} {
                    lassign $expect wantBuilt word
                    set seen [expr {$built ? $value : $message}]
                    if {$built == $wantBuilt && [string first $word $seen] >= 0} {
                        set verdict "as expected"
                    } else {
                        set verdict "UNEXPECTED (expected built $wantBuilt with \"$word\")"
                        lappend failures "$name $program $linker"
                    }
                }
                set what [expr {$built ? "built, status [dict get $r status], value {$value}" : "not built: $excerpt"}]
                lappend report "  $program, linker [expr {$linker eq "" ? "default" : $linker}]: $what -- $verdict"
            }
        }
    }
    lappend report [expr {$failures eq "" ? "CONTROLS PASSED" : "CONTROLS FAILED: [join $failures {; }]"}]
    Write $reportFile [join $report \n]\n
    puts [join $report \n]
    return [expr {$failures eq ""}]
}

proc rlf::Options {defaults args} {
    set opts $defaults
    set positional {}
    for {set i 0} {$i < [llength $args]} {incr i} {
        set a [lindex $args $i]
        if {[string match -* $a] && [dict exists $defaults $a]} {
            dict set opts $a [lindex $args [incr i]]
        } elseif {[string match -* $a]} {
            error "rlf: unknown option $a"
        } else {
            lappend positional $a
        }
    }
    return [list $opts $positional]
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    set command [lindex $::argv 0]
    set rest [lrange $::argv 1 end]
    switch -- $command {
        unit {
            lassign [rlf::Options {-target "" -out "" -features default -notify weakdef -localize 1 -exports {rlf_* rlfp_post} -toolchain "" -work ""} {*}$rest] o
            set target [expr {[dict get $o -target] eq "" ? [rlf::HostTarget] : [dict get $o -target]}]
            puts [rlf::Unit $target [dict get $o -out] $o]
        }
        provider {
            lassign [rlf::Options {-target "" -out ""} {*}$rest] o
            set target [expr {[dict get $o -target] eq "" ? [rlf::HostTarget] : [dict get $o -target]}]
            puts [rlf::Provider $target [dict get $o -out]]
        }
        stage {
            lassign [rlf::Options {-compiler "" -out ""} {*}$rest] o targets
            puts [rlf::Stage [dict get $o -compiler] [dict get $o -out] $targets]
        }
        consumer {
            lassign [rlf::Options {-compiler "" -repository "" -dir "" -target "" -report ""} {*}$rest] o
            set target [expr {[dict get $o -target] eq "" ? [rlf::HostTarget] : [dict get $o -target]}]
            exit [expr {![rlf::Consumer [dict get $o -compiler] [file normalize [dict get $o -repository]] [dict get $o -dir] $target [dict get $o -report]]}]
        }
        app {
            lassign [rlf::Options {-dir "" -unit "" -provider ""} {*}$rest] o
            puts [rlf::App [dict get $o -dir] [dict get $o -unit] [dict get $o -provider]]
        }
        control {
            lassign [rlf::Options {-compiler "" -dir "" -program basic -linker ""} {*}$rest] o
            puts [rlf::Control [dict get $o -compiler] [file normalize [dict get $o -dir]] [dict get $o -program] [dict get $o -linker]]
        }
        controls {
            lassign [rlf::Options {-compiler "" -target "" -work "" -linkers {rustc system} -skew "" -report ""} {*}$rest] o
            set target [expr {[dict get $o -target] eq "" ? [rlf::HostTarget] : [dict get $o -target]}]
            set report [expr {[dict get $o -report] eq "" ? [file join [dict get $o -work] CONTROLS.txt] : [dict get $o -report]}]
            exit [expr {![rlf::Controls [dict get $o -compiler] $target [dict get $o -work] [dict get $o -linkers] [dict get $o -skew] $report]}]
        }
        inspect {
            lassign [rlf::Options {-target ""} {*}$rest] o positional
            set target [expr {[dict get $o -target] eq "" ? [rlf::HostTarget] : [dict get $o -target]}]
            lassign [rlf::Inspect $target [lindex $positional 0] [expr {[lindex $positional 1] eq "1"}]] facts failures
            puts $facts
            if {$failures ne ""} { puts "FAILED: [join $failures {; }]"; exit 1 }
        }
        default {
            puts stderr "usage: tclsh9.0 audit/rust-archive-link/tools/rlf.tcl unit|provider|stage|consumer|app|control|inspect ..."
            exit 2
        }
    }
}
