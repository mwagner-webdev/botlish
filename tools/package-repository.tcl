# package-repository.tcl -- pack this repository's packages into a local
# package repository: the author's side (PACKAGE-MANAGER-MILESTONE-1.md,
# -2.md, and -3.md, "Real-package migration").
#
#   tclsh9.0 tools/package-repository.tcl ?-force? ?-release? OUT ?NAME...?
#
# writes OUT/NAME-VERSION.botpkg for each named package (default: every
# package of packages/) and, for a native package, its provenance record
# OUT/NAME-VERSION.provenance.json, and prints each release's identity. A
# release is immutable: an OUT that already holds a different
# NAME-VERSION.botpkg is refused (EXISTS: raise the version), unless -force
# says this local file may be overwritten.
#
# A release once made is recorded in packages/RELEASES.tsv (name, version,
# the artifact's SHA-256): one version, one artifact, on every machine. A
# build of a recorded version whose bytes differ is a *candidate*, never
# the release -- a rebuild that did not reproduce it (another toolchain, an
# input left unpinned): the tool says so and names `botlish package compare`.
# With -release (the publishing path: tools/package-build/author.sh's
# container, whose builds reproduce the recorded releases) such a candidate
# is an error, and its file is renamed NAME-VERSION.candidate-DIGEST.botpkg
# so that nothing can take it for the release. A consumer then installs them
# with the ordinary commands -- `botlish add sdlkit -repository OUT` -- and
# nothing package-specific runs on the consumer's side: no compiler, no
# script.
#
# Since PM-3 this file holds only what is genuinely each package's own: how
# its native files are *built* (CMake, the cross compilers, the binding
# generator's thunks) and what its author *states* about them (which
# dependencies the system provides, what is opened at run time, licenses).
# Everything else is the package manager's generic authoring workflow, run
# as any author runs it (`main.tcl` is `botlish` in a checkout):
#
#   botlish package stage DIR -target T -modules|-headers|-files SRC
#   botlish native add FILE -target T -name N ...      (facts read from the file)
#   botlish native require NAME -target T -origin system|-runtime ...
#   botlish native audit DIR
#   botlish package pack DIR -out OUT -evidence EVIDENCE.json
#
# A release directory starts as a copy of packages/NAME (the package's own
# files: its module, documentation and an authoring botlish.json with no
# native metadata) in a temporary stage; the commands above write every
# target's files and metadata into it; the pack audits it and writes the
# artifact and its provenance record. The evidence file (sources, builds,
# toolchains, generator outputs) is written here, from what this script ran,
# with every host path replaced by a named root ($CACHE, $BOTLISH, $BUILD).

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
source [file join $root pm pm.tcl]

proc usage {} {
    puts stderr "usage: tclsh9.0 tools/package-repository.tcl ?-force? ?-release? OUT ?NAME...?"
    exit 2
}

set out ""
set names {}
set force 0
set release 0
foreach arg $argv {
    if {$arg eq "-force"} {
        set force 1
    } elseif {$arg eq "-release"} {
        set release 1
    } elseif {[string match -* $arg]} {
        usage
    } elseif {$out eq ""} {
        set out [file normalize $arg]
    } else {
        lappend names $arg
    }
}
if {$out eq ""} usage
if {$names eq ""} {
    set names {sdl3 sdlkit raven event_loop_linux boringssl http process_linux}
}

namespace eval author {
    variable root $::root
    # The release being prepared: its directory and the evidence gathered.
    variable dir ""
    variable evidence ""
    variable stage ""
}

# ---------------------------------------------------------------------------
# The generic workflow, as an author runs it

# Runs `botlish ARGS` (main.tcl in this checkout): the package manager's own
# commands, nothing of this script's. Its output is shown on standard error
# (this script's standard output is the releases' identities).
proc author::botlish {args} {
    variable root
    if {[catch {exec [info nameofexecutable] [file join $root main.tcl] {*}$args 2>@1} output]} {
        error "botlish [join $args]:\n$output"
    }
    puts stderr [lindex [split $output \n] 0]
    return $output
}

# ---------------------------------------------------------------------------
# Builds (the author's own toolchains; nothing here reaches a consumer)

# The GNU compiler of TARGET's architecture: the host's cc for the host's
# target, else ARCH-linux-gnu-gcc (Debian's cross compilers).
proc author::cc {target} {
    if {$target eq [pm::target::host]} {
        if {[info exists ::env(CC)] && $::env(CC) ne ""} { return $::env(CC) }
        return cc
    }
    set arch [dict get [pm::target::facts $target] arch]
    set compiler $arch-linux-gnu-gcc
    if {[auto_execok $compiler] eq ""} {
        error "no C compiler for $target: $compiler is not installed (Debian: gcc-$arch-linux-gnu)"
    }
    return $compiler
}

proc author::ar {target} {
    if {$target eq [pm::target::host]} { return ar }
    set tool [dict get [pm::target::facts $target] arch]-linux-gnu-ar
    if {[auto_execok $tool] eq ""} { return ar }
    return $tool
}

proc author::strip {target} {
    if {$target eq [pm::target::host]} { return strip }
    return [dict get [pm::target::facts $target] arch]-linux-gnu-strip
}

# The first line of a tool's version, for the evidence ("" when it has none).
proc author::version {args} {
    if {[catch {exec {*}$args 2>@1} text]} {
        return ""
    }
    return [string trim [lindex [split $text \n] 0]]
}

# The installed version of the Debian packages NAMES, as "NAME VERSION; ...".
proc author::debs {names} {
    set out {}
    foreach name $names {
        if {![catch {exec dpkg-query -W -f {${Version}} $name 2>/dev/null} version] && $version ne ""} {
            lappend out "$name $version"
        }
    }
    return [join $out {; }]
}

# TEXT with this machine's directories replaced by named roots: a record is
# published, and a path of the author's machine says nothing to anyone else.
proc author::rooted {text} {
    variable root
    variable stage
    set cache ""
    catch {
        source [file join $root tests cffi raven.tcl]
        set cache [cffi::RavenCacheDir]
    }
    set map {}
    if {$stage ne ""} { lappend map $stage \$BUILD }
    if {$cache ne ""} { lappend map $cache \$CACHE }
    lappend map $root \$BOTLISH [file normalize ~] \$HOME
    return [string map $map $text]
}

# Compiles the C files SOURCES with FLAGS into the archive ARCHIVE for TARGET.
proc author::archive {target sources flags archive} {
    file mkdir [file dirname $archive]
    set objects {}
    foreach source $sources {
        set object [file join [file dirname $archive] [file rootname [file tail $source]].o]
        exec [cc $target] {*}$flags -c $source -o $object
        lappend objects $object
    }
    file delete $archive
    exec [ar $target] rcs $archive {*}$objects
    file delete {*}$objects
    return $archive
}

# A stripped copy of the library FROM (its bytes, never a link) at TO.
proc author::stripped {target from to} {
    file mkdir [file dirname $to]
    file delete $to
    pm::WriteNew $to [pm::ReadBytes $from]
    exec [strip $target] --strip-unneeded $to
    return $to
}

# This checkout's source revision (BOTLISH_SOURCE_REVISION where the tree is
# no Git checkout: tools/package-build/author.sh's container).
proc author::revision {} {
    variable root
    if {[info exists ::env(BOTLISH_SOURCE_REVISION)] && $::env(BOTLISH_SOURCE_REVISION) ne ""} {
        return $::env(BOTLISH_SOURCE_REVISION)
    }
    return [version git -C $root rev-parse HEAD]
}

# The directory of a committed generated binding.
proc author::binding {profile target} {
    variable root
    set binding [file join $root generated c $profile $target $profile]
    if {![file isdirectory $binding]} {
        error "no committed $profile binding for $target ($binding)"
    }
    return $binding
}

# The pinned Raven's checkout (tools/c-bindgen.tcl fetch raven).
proc author::ravenSource {} {
    variable root
    set fetched [exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] fetch raven]
    return [lindex [split [string trim $fetched] \n] end]
}

# The Git identity of the checkout DIR (the author's git, on the author's
# side): {commit C tree T}; the record's check recomputes the tree from the
# files, without git.
proc author::gitIdentity {dir {tag ""}} {
    set identity [dict create object-format sha1 commit [exec git -C $dir rev-parse HEAD] tree [exec git -C $dir rev-parse HEAD^{tree}]]
    if {$tag ne ""} {
        dict set identity tag $tag
        if {![catch {exec git -C $dir rev-parse refs/tags/$tag 2>/dev/null} object] && $object ne [dict get $identity commit]} {
            dict set identity tag-object $object
        }
    }
    return $identity
}

# The libX11 a cross build of Raven's X11 platform links, per target: the
# Debian packages of that architecture (Ubuntu 24.04's, from
# ports.ubuntu.com), pinned by SHA-256 -- the values of the archive's index
# (noble-updates for libX11, noble for the protocol headers), whose
# signature was checked against the Ubuntu archive key when they were
# recorded (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, "The desktop build").
# The ports pool drops a superseded version, and Ubuntu's snapshot service
# keeps no ports archive: a pin that cannot be fetched fails, naming it,
# and is never replaced by another version. Only the author's build reads
# them: a link-time stand-in for the target system's libX11.so.6, never
# packed.
namespace eval author {
    variable x11Packages {
        linux-aarch64 {
            pool/main/libx/libx11/libx11-6_1.8.7-1ubuntu0.1_arm64.deb
            57f0bee78ea23caa31520a565fb12fcbea1ee5ecfd4f2055f12dd0ac3698f439
            pool/main/libx/libx11/libx11-dev_1.8.7-1ubuntu0.1_arm64.deb
            c67aedaed249c629628c24e717c5b550a066e246c678aa98098002ed0a8017e9
            pool/main/x/xorgproto/x11proto-dev_2023.2-1_all.deb
            3bf13a2ffb79ecd4014d438936014e5863f79eb59ebf76e8f43356271c90e7ce
        }
    }
}

proc author::x11Sysroot {target} {
    variable x11Packages
    if {![dict exists $x11Packages $target]} {
        error "no libX11 packages are pinned for $target: Raven's desktop build for it cannot be linked"
    }
    set packages [dict get $x11Packages $target]
    set key [string range [pm::sha256::hex [join $packages \n]] 0 11]
    set dir [file join [cffi::RavenCacheDir] raven-cross x11-$target-$key]
    if {[file isfile [file join $dir complete]]} {
        return $dir
    }
    file delete -force $dir
    file mkdir [file join $dir debs]
    foreach {path sha} $packages {
        set deb [file join $dir debs [file tail $path]]
        set url https://ports.ubuntu.com/ubuntu-ports/$path
        if {[catch {exec curl -fsSL --retry 3 -o $deb $url} message]} {
            file delete -force $dir
            error "[file tail $path]: not available from $url ($message): the pinned package may have been withdrawn from the pool; it is never replaced by another version (check a preserved copy against the pin, or pin a new version deliberately)"
        }
        set got [pm::sha256::hex [pm::ReadBytes $deb]]
        if {$got ne $sha} {
            file delete -force $dir
            error "[file tail $path]: sha256 $got, not the pinned $sha (a changed or substituted package: check it, and only then update the pin)"
        }
        exec dpkg-deb -x $deb [file join $dir root]
    }
    pm::WriteNew [file join $dir complete] ""
    return $dir
}

# The CMake flags Raven's cross build adds to the desktop configuration's.
# CMAKE_SKIP_RPATH: CMake otherwise records the build tree's library
# directories as the library's RUNPATH -- here the cache path of the pinned
# libX11, a path of the build machine, with an empty entry (the current
# directory) after it. It made raven 0.3.1's AArch64 library differ between
# machines and search the current directory at run time
# (PACKAGE-MANAGER-MILESTONE-3.md, "Reproducibility").
proc author::crossFlags {target} {
    set arch [dict get [pm::target::facts $target] arch]
    return [list -DCMAKE_SKIP_RPATH=ON -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=$arch]
}

# libraven.so.0 of Raven's desktop configuration (X11 and Vulkan) built for
# TARGET, and the build's description for the evidence.
proc author::libraven {target} {
    variable root
    source [file join $root tests cffi raven.tcl]
    set configuration [cffi::RavenConfiguration desktop]
    set base {-DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_SHARED=ON -DRAVEN_BUILD_EXAMPLES=OFF -DRAVEN_BUILD_TESTS=OFF -DRAVEN_BUILD_TOOLS=OFF}
    set flags [concat $base [dict get $configuration flags] [list -DRAVEN_VULKAN_INCLUDE_DIR=\$VULKAN_HEADERS/include]]
    if {$target eq [pm::target::host]} {
        set build [dict create library [file join [cffi::ravenBuild desktop] libraven.so.0] flags $flags \
            compiler [version [cc $target] --version] inputs {}]
        return $build
    }
    # Another architecture: Raven's own CMake build with its GNU cross
    # compiler, the desktop configuration's flags and pinned Vulkan headers,
    # and the target's libX11 (x11Sysroot), cached by a stamp as
    # tests/cffi/raven.tcl caches its builds.
    set commit [dict get [cffi::RavenSource] commit]
    set build [file join [cffi::RavenCacheDir] raven-cross $target-$commit-desktop-[string range [dict get $configuration vulkan] 0 11]]
    set stamp "target $target\ncross [crossFlags $target]\n[cffi::RavenStamp $configuration]"
    set library [file join $build libraven.so.0]
    set stampFile [file join $build botlish-raven-configuration]
    set arch [dict get [pm::target::facts $target] arch]
    set sysroot [file join [x11Sysroot $target] root]
    if {![file isfile $stampFile] || [pm::ReadBytes $stampFile] ne $stamp || ![file exists $library]} {
        file delete -force $build
        file mkdir $build
        exec cmake -S [ravenSource] -B $build -GNinja {*}$base \
            {*}[dict get $configuration flags] -DRAVEN_VULKAN_INCLUDE_DIR=[file join [cffi::VulkanHeaders] include] \
            -DX11_X11_INCLUDE_PATH=[file join $sysroot usr include] \
            -DX11_X11_LIB=[file join $sysroot usr lib $arch-linux-gnu libX11.so] \
            {*}[crossFlags $target] -DCMAKE_C_COMPILER=[cc $target] >@stderr 2>@stderr
        exec ninja -C $build raven >@stderr 2>@stderr
        pm::WriteNew $stampFile $stamp
    }
    variable x11Packages
    set inputs {}
    foreach {path sha} [dict get $x11Packages $target] {
        lappend inputs [dict create name [file tail $path] sha256 $sha source https://ports.ubuntu.com/ubuntu-ports/$path]
    }
    return [dict create library $library compiler [version [cc $target] --version] inputs $inputs \
        flags [concat $flags [crossFlags $target] [list -DCMAKE_C_COMPILER=[cc $target] \
            "-DX11_X11_INCLUDE_PATH=\$X11_SYSROOT/usr/include" "-DX11_X11_LIB=\$X11_SYSROOT/usr/lib/$arch-linux-gnu/libX11.so"]]]
}

# ---------------------------------------------------------------------------
# The evidence: what this script ran, stated by the author

proc author::upstream {name repository identity directory} {
    variable evidence
    dict lappend evidence sources [dict create name $name role upstream repository $repository git $identity directory $directory]
}

proc author::build {name targets outputs sources configuration toolchain flags steps {inputs {}}} {
    variable evidence
    set build [dict create name $name targets $targets outputs $outputs sources $sources configuration $configuration \
        toolchain $toolchain flags [lmap flag $flags {rooted $flag}] steps [lmap step $steps {rooted $step}]]
    if {[info exists ::env(BOTLISH_AUTHOR_IMAGE)] && $::env(BOTLISH_AUTHOR_IMAGE) ne ""} {
        dict set build image $::env(BOTLISH_AUTHOR_IMAGE)
    }
    set environment [dict create]
    foreach name {CC CFLAGS LDFLAGS SOURCE_DATE_EPOCH} {
        if {[info exists ::env($name)] && $::env($name) ne ""} {
            dict set environment $name [rooted $::env($name)]
        }
    }
    if {$environment ne ""} { dict set build environment $environment }
    if {$inputs ne ""} { dict set build inputs $inputs }
    dict lappend evidence builds $build
}

proc author::generator {name version inputs outputs} {
    variable evidence
    dict lappend evidence generators [dict create name $name version $version inputs $inputs outputs $outputs]
}

# The evidence as the JSON text pm::release::readEvidence reads.
proc author::evidenceText {name version} {
    variable evidence
    set S {apply {{text} {list str $text}}}
    set value [list obj [list evidence {num 1} package [list obj [list name [list str $name] version [list str $version]]]]]
    set members [lindex $value 1]
    foreach key {sources builds generators} {
        set items {}
        foreach item [dict getdef $evidence $key {}] {
            set fields {}
            dict for {k v} $item {
                switch -- $k {
                    git - toolchain - environment {
                        lappend fields $k [list obj [concat {*}[lmap kk [dict keys $v] {list $kk [list str [dict get $v $kk]]}]]]
                    }
                    targets - outputs - sources - flags - steps {
                        lappend fields $k [list arr [lmap x $v {list str $x}]]
                    }
                    inputs {
                        if {$key eq "generators"} {
                            lappend fields $k [list arr [lmap x $v {list str $x}]]
                        } else {
                            lappend fields $k [list arr [lmap x $v {list obj [concat {*}[lmap kk [dict keys $x] {list $kk [list str [dict get $x $kk]]}]]}]]
                        }
                    }
                    default { lappend fields $k [list str $v] }
                }
            }
            lappend items [list obj $fields]
        }
        lappend members $key [list arr $items]
    }
    return [pm::json::encode [list obj $members]]
}

# ---------------------------------------------------------------------------
# The recipes: each package's builds and statements

proc author::sdl3 {dir targets} {
    variable root
    variable stage
    source [file join $root tests cffi sdl3.tcl]
    set revision [revision]
    # The pinned SDL3 (tools/c-bindgen/profiles/sdl3.tcl): its sources, which
    # the binding generator's thunk build reads, and its headless build
    # (tests/cffi/sdl3.tcl), both made here when they are not yet.
    set fetched [exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] fetch sdl3 2>@stderr]
    set checkout [lindex [split [string trim $fetched] \n] end]
    if {[cffi::sdl3Dir] eq ""} {
        exec [info nameofexecutable] [file join $root tests cffi sdl3.tcl] >@stderr 2>@stderr
    }
    regexp {release-[0-9.]+} [pm::ReadBytes [file join $root tools c-bindgen profiles sdl3.tcl]] tag
    upstream sdl3 https://github.com/libsdl-org/SDL [gitIdentity $checkout $tag] $checkout
    foreach target $targets {
        set binding [binding sdl3 $target]
        botlish package stage $dir -target $target -modules $binding
        generator "botlish c-bindgen sdl3 $target" "$revision" [list "\$BOTLISH/generated/c/sdl3/$target (committed)"] [list targets/$target/sdl3/]
        # The thunk archive, built for the target by the binding generator.
        set built [file join $stage shim-$target]
        exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] build sdl3 -target $target -out $built
        set archives [lsort [glob -directory $built *.a]]
        if {$target eq "linux-x86_64"} {
            # The pinned SDL3, built headless (tests/cffi/sdl3.tcl), stripped.
            if {[cffi::sdl3Dir] eq ""} {
                error "no SDL3 shared library for $target: run tclsh9.0 tests/cffi/sdl3.tcl"
            }
            set library [stripped $target [file join [cffi::sdl3Dir] libSDL3.so.0] [file join $stage sdl3-$target libSDL3.so.0]]
            botlish native add $library -target $target -name SDL3 -symbol SDL_GetVersion -symbol SDL_Init -package $dir
            build "sdl3 $target" [list $target] [list targets/$target/native/libSDL3.so.0] {sdl3} headless \
                [dict create cc [version [cc $target] --version] cmake [version cmake --version] ninja [version ninja --version] \
                    strip [version [strip $target] --version]] \
                [list -GNinja -DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_TESTS=OFF \
                    -DSDL_EXAMPLES=OFF -DSDL_INSTALL=OFF -DSDL_UNIX_CONSOLE_BUILD=ON -DSDL_X11=OFF -DSDL_WAYLAND=OFF] \
                [list "tclsh9.0 \$BOTLISH/tests/cffi/sdl3.tcl (cmake, ninja SDL3-shared)" "[strip $target] --strip-unneeded libSDL3.so.0"]
        }
        botlish native require SDL3 -target $target -origin system -identity libSDL3.so.0 -version 3 -pkg-config sdl3 -package $dir
        foreach archive $archives {
            # The generator names its archive libNAME.a, NAME the binding's
            # extern c library: the author's knowledge, stated here.
            regexp {^lib(.*)\.a$} [file tail $archive] -> name
            botlish native add $archive -target $target -name $name -package $dir
            build "sdl3 thunks $target" [list $target] [list targets/$target/native/[file tail $archive]] {sdl3} thunks \
                [dict create cc "[version clang --version] (--target, tools/cheader's toolchain)"] {} \
                [list "tclsh9.0 \$BOTLISH/tools/c-bindgen.tcl build sdl3 -target $target"]
        }
    }
}

proc author::raven {dir targets} {
    variable root
    variable stage
    source [file join $root tests cffi raven.tcl]
    set checkout [ravenSource]
    set pinned [cffi::RavenSource]
    source [file join $root tests cffi raven.tcl]
    set vulkan [cffi::VulkanHeaders]
    upstream raven https://github.com/oscar-soirey/Raven [gitIdentity $checkout [dict get $pinned tag]] $checkout
    upstream vulkan-headers https://github.com/KhronosGroup/Vulkan-Headers.git [gitIdentity $vulkan v1.3.290] $vulkan
    set revision [revision]
    # Raven's license and the notices its terms require to travel with the
    # library (its own NOTICE, the third-party components it compiles in:
    # THIRD_PARTY.md), staged as common files.
    set notices {}
    foreach path {LICENSE NOTICE THIRD_PARTY.md third_party/stb/LICENSE third_party/roboto/LICENSE third_party/roboto-mono/LICENSE} {
        set as licenses/raven[expr {[file dirname $path] eq "." ? "" : "/[file dirname $path]"}]
        botlish package stage $dir -files [file join $checkout {*}[split $path /]] -as $as
        lappend notices licenses/raven/$path
    }
    set noticeOptions [concat {*}[lmap notice $notices {list -notice $notice}]]
    foreach target $targets {
        botlish package stage $dir -target $target -modules [binding raven $target]
        generator "botlish c-bindgen raven $target" "$revision" [list "\$BOTLISH/generated/c/raven/$target (committed)"] [list targets/$target/raven/]
        # The event bridge, built for the target against the pinned headers.
        set flags [list -std=c11 -O2 -Wall -Wextra -Werror -fPIC -pthread -I[file join $checkout include]]
        set bridge [archive $target [list [file join $dir native raven_bridge.c]] $flags [file join $stage bridge-$target libraven_bridge.a]]
        botlish native add $bridge -target $target -name raven_bridge -package $dir
        build "raven bridge $target" [list $target] [list targets/$target/native/libraven_bridge.a] {raven} bridge \
            [dict create cc [version [cc $target] --version] ar [version [ar $target] --version]] \
            [lmap flag $flags {string map [list [file join $checkout include] \$RAVEN/include] $flag}] \
            [list "[cc $target] -c native/raven_bridge.c" "[ar $target] rcs libraven_bridge.a raven_bridge.o"]
        # Raven's desktop build (X11 and Vulkan; it runs headless too).
        set built [libraven $target]
        set library [stripped $target [dict get $built library] [file join $stage raven-$target libraven.so.0]]
        botlish native add $library -target $target -name raven -symbol Rinit_ex -symbol Rvulkan_get_instance \
            -license "Apache-2.0 AND OFL-1.1 AND (MIT OR Unlicense)" {*}$noticeOptions -package $dir
        build "raven desktop $target" [list $target] [list targets/$target/native/libraven.so.0] {raven vulkan-headers} desktop \
            [dict create cc [dict get $built compiler] cmake [version cmake --version] ninja [version ninja --version] \
                strip [version [strip $target] --version] packages [debs [expr {$target eq [pm::target::host]
                    ? {gcc-13 libc6-dev libx11-dev binutils} : {gcc-13-aarch64-linux-gnu libc6-dev-arm64-cross binutils-aarch64-linux-gnu}}]]] \
            [dict get $built flags] [list "cmake -GNinja" "ninja raven" "[strip $target] --strip-unneeded libraven.so.0"] [dict get $built inputs]
        # What the library needs that the system provides (its loader
        # dependency), and what it opens only at run time.
        botlish native require X11 -target $target -origin system -identity libX11.so.6 -symbol XOpenDisplay -package $dir
        botlish native require vulkan -target $target -runtime capability -capability desktop -identity libvulkan.so.1 -loaded-by raven \
            -purpose "the Vulkan loader, opened by Raven's renderer when a program starts raven::desktop(); a headless program never opens it" -package $dir
        botlish native require vulkan-driver -target $target -runtime capability -capability desktop -kind facility -loaded-by raven \
            -purpose "a Vulkan driver (a GPU's, or Mesa's lavapipe) the loader finds, able to present to an X11 window: no file a package can name" -package $dir
        botlish native require x11-display -target $target -runtime capability -capability desktop -kind facility \
            -purpose "an X11 display (DISPLAY): an X server or Xvfb, for raven::desktop() windows" -package $dir
        botlish native require x11-xcb -target $target -runtime optional -identity libX11-xcb.so.1 -loaded-by raven \
            -purpose "opened by the renderer only for a Vulkan driver that presents through XCB alone" -package $dir
        botlish native require dbus -target $target -runtime capability -capability accessibility -identity libdbus-1.so.3 -loaded-by raven \
            -purpose "D-Bus, opened by Raven's AT-SPI accessibility bridge when a program enables accessibility" -package $dir
    }
}

proc author::event_loop_linux {dir targets} {
    variable stage
    foreach target $targets {
        set flags {-O2 -Wall -Wextra -Werror -fPIC -pthread}
        set adapter [archive $target [list [file join $dir native event_loop_linux.c]] $flags [file join $stage evl-$target libevent_loop_linux.a]]
        botlish native add $adapter -target $target -name event_loop_linux -package $dir
        build "event loop adapter $target" [list $target] [list targets/$target/native/libevent_loop_linux.a] {} adapter \
            [dict create cc [version [cc $target] --version] ar [version [ar $target] --version]] $flags \
            [list "[cc $target] -c native/event_loop_linux.c" "[ar $target] rcs libevent_loop_linux.a event_loop_linux.o"]
        # The public header, for consumers' own C (native plan -include).
        botlish package stage $dir -target $target -headers [file join $::root packages event_loop_linux native botlish_event_loop.h]
    }
    # The release's header is each target's include/ (above), not a common
    # file beside the adapter's source.
    file delete [file join $dir native botlish_event_loop.h]
}

# The process package (PROCESS-LINUX-PACKAGE-MILESTONE-1.md): its C adapter
# compiled with the flags every build of it uses (tools/process-linux.tcl's
# archiveFlags), without PL_TESTING (the released archive has no probe and
# no fault bit); the project's license as its notice. Linux x86-64 only: the
# package's one target, so its metadata names no other (another target is
# UNSUPPORTED to the package manager, never a guess).
proc author::process_linux {dir targets} {
    variable root
    variable stage
    source [file join $root tools process-linux.tcl]
    botlish package stage $dir -files [file join $root LICENSE] -as licenses/process_linux
    foreach target $targets {
        set flags $::processLinux::archiveFlags
        set adapter [archive $target [list [file join $dir native process_linux.c]] $flags [file join $stage pl-$target libprocess_linux.a]]
        botlish native add $adapter -target $target -name process_linux -license MIT -notice licenses/process_linux/LICENSE -package $dir
        build "process adapter $target" [list $target] [list targets/$target/native/libprocess_linux.a] {} adapter \
            [dict create cc [version [cc $target] --version] ar [version [ar $target] --version]] $flags \
            [list "[cc $target] -c native/process_linux.c" "[ar $target] rcs libprocess_linux.a process_linux.o"]
    }
}

# The BoringSSL provider (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "The
# provider"): the pinned release built by tools/http-package.tcl (upstream's
# CMake, unpatched, unprefixed), its two archives' members in one archive
# of its own name with the identity member; BoringSSL's license staged as a notice;
# libstdc++ (libssl is C++) stated as the system's.
proc author::boringssl {dir targets} {
    variable root
    source [file join $root tools http-package.tcl]
    set pin [httppkg::Pin]
    set commit [dict get $pin commit]
    set src [file join [httppkg::CacheDir] src boringssl-$commit]
    foreach target $targets {
        set archives [httppkg::ProviderArchives $target]
        if {![file isdirectory [file join $src .git]]} {
            error "the BoringSSL checkout is missing ($src)"
        }
        if {![file exists [file join $dir licenses boringssl LICENSE]]} {
            upstream boringssl [dict get $pin url] [gitIdentity $src [dict get $pin tag]] $src
            botlish package stage $dir -files [file join $src LICENSE] -as licenses/boringssl
        }
        set provider [httppkg::Provider $target]
        set record [pm::ReadBytes [file join $provider PROVENANCE]]
        botlish native add [file join $archives libbotlish_boringssl.a] -target $target \
            -name botlish_boringssl -license Apache-2.0 -notice licenses/boringssl/LICENSE -package $dir
        build "boringssl $target" [list $target] [list targets/$target/native/libbotlish_boringssl.a] \
            {boringssl} release \
            [dict create cc [dict get $record compiler] cxx [dict get $record cxx] cmake [dict get $record cmake] ninja [version ninja --version] ar [version ar --version]] \
            [concat [dict get $pin cmake] {-GNinja -ffile-prefix-map=$SRC=/boringssl}] \
            [list "cmake -GNinja" "ninja crypto ssl" "cc -c native/identity.c -DBOTLISH_BORINGSSL_ID=[httppkg::ProviderId]" \
                "ar qcsD libbotlish_boringssl.a (libcrypto.a's and libssl.a's members, identity.o)"]
        botlish native require stdc++ -target $target -origin system -identity libstdc++.so.6 -symbol __cxa_begin_catch -package $dir
    }
}

# The licenses of the http unit's Rust dependencies: every crate of its
# normal-dependency closure for the target (cargo metadata --locked), each
# crate's license files staged under licenses/http/crates/NAME-VERSION, and
# licenses/http/CRATES.md listing them. The SPDX expression of them all.
proc author::httpCrates {dir triple} {
    variable root
    variable stage
    set crate [file join $root packages http native]
    set json [exec cargo metadata --format-version 1 --locked --filter-platform $triple --manifest-path [file join $crate Cargo.toml] 2>@stderr]
    set meta [pm::json::decode [encoding convertto utf-8 $json] -limit [expr {16 * 1024 * 1024}]]
    set field {apply {{object key} {
        foreach {k v} [lindex $object 1] { if {$k eq $key} { return $v } }
        return {null {}}
    }}}
    set packages [dict create]
    foreach p [lindex [{*}$field $meta packages] 1] {
        dict set packages [lindex [{*}$field $p id] 1] $p
    }
    set nodes [dict create]
    foreach n [lindex [{*}$field [{*}$field $meta resolve] nodes] 1] {
        set deps {}
        foreach d [lindex [{*}$field $n deps] 1] {
            foreach k [lindex [{*}$field $d dep_kinds] 1] {
                if {[lindex [{*}$field $k kind] 0] eq "null"} {
                    lappend deps [lindex [{*}$field $d pkg] 1]
                    break
                }
            }
        }
        dict set nodes [lindex [{*}$field $n id] 1] $deps
    }
    set rootId [lindex [{*}$field [{*}$field $meta resolve] root] 1]
    set seen [dict create]
    set todo [list $rootId]
    while {[llength $todo]} {
        set todo [lassign $todo id]
        if {[dict exists $seen $id]} continue
        dict set seen $id 1
        lappend todo {*}[dict get $nodes $id]
    }
    set lines [list "# The Rust crates in libbotlish_http.a" "" \
        "The http package's native unit links these crates (its normal dependencies, as Cargo.lock resolves them for $triple). Each crate's own license files are beside this file, under crates/NAME-VERSION/." "" \
        "| crate | version | license |" "|---|---|---|"]
    set licenses {}
    foreach id [lsort [dict keys $seen]] {
        set p [dict get $packages $id]
        set name [lindex [{*}$field $p name] 1]
        set ver [lindex [{*}$field $p version] 1]
        set lic [lindex [{*}$field $p license] 1]
        lappend lines "| $name | $ver | $lic |"
        if {$lic ni $licenses} { lappend licenses $lic }
        if {$id eq $rootId} continue
        set manifest [file dirname [lindex [{*}$field $p manifest_path] 1]]
        set files [lsort [glob -nocomplain -tails -directory $manifest -types f LICENSE* LICENCE* COPYING* NOTICE* COPYRIGHT*]]
        if {$files eq ""} {
            error "crate $name $ver has no license file to ship"
        }
        foreach f $files {
            botlish package stage $dir -files [file join $manifest $f] -as licenses/http/crates/$name-$ver
        }
    }
    set summary [file join $stage http-CRATES.md]
    file delete $summary
    pm::WriteNew $summary [encoding convertto utf-8 "[join $lines \n]\n"]
    botlish package stage $dir -files $summary -as licenses/http
    file rename -force [file join $dir licenses http http-CRATES.md] [file join $dir licenses http CRATES.md]
    return [join [lmap l [lsort $licenses] {expr {[string match "* OR *" $l] || [string match "*/*" $l] ? "([string map {/ " OR "} $l])" : $l}}] " AND "]
}

# The http client (HTTP-CLIENT-PACKAGE-MILESTONE-1.md): the localized
# botlish_http unit, built by tools/http-package.tcl against the provider's
# headers in link-only mode (no BoringSSL inside it); its Rust crates'
# licenses; the project's license for the unit's own code.
proc author::http {dir targets} {
    variable root
    source [file join $root tools http-package.tcl]
    botlish package stage $dir -files [file join $root LICENSE] -as licenses/http
    set rustc [version rustc --version]
    set cargo [version cargo --version]
    foreach target $targets {
        set triple [dict get {linux-x86_64 x86_64-unknown-linux-gnu linux-aarch64 aarch64-unknown-linux-gnu} $target]
        set expression [httpCrates $dir $triple]
        set unit [httppkg::Unit $target 0]
        set notices [list -notice licenses/http/LICENSE -notice licenses/http/CRATES.md]
        botlish native add $unit -target $target -name botlish_http -license $expression {*}$notices -package $dir
        build "http unit $target" [list $target] [list targets/$target/native/libbotlish_http.a] {} release \
            [dict create rustc $rustc cargo $cargo cc [version cc --version] ld [version ld --version] objcopy [version objcopy --version]] \
            [list --locked --release "codegen-units=1" "--remap-path-prefix (crate, registry, target, checkout)" "BORING_BSSL_PATH=(empty archives: link-only)" "BOTLISH_BORINGSSL_PROVIDER=[httppkg::ProviderId]"] \
            [list "cargo build --release --locked (packages/http/native)" "ld -r --whole-archive" "objcopy --strip-debug --keep-global-symbols=bh_* (COMDAT groups renamed)" "ar rcsD libbotlish_http.a"]
    }
}

# The release directory of the package NAME, prepared in STAGE: packages/NAME
# copied (its own files and authoring botlish.json), then its recipe run.
# The evidence the recipe gathered is written beside it.
proc author::prepare {name stage} {
    variable root
    variable evidence
    set ::author::stage $stage
    set evidence [dict create]
    set package [file join $root packages $name]
    set dir [file join $stage $name]
    file mkdir $dir
    foreach entry [glob -nocomplain -tails -directory $package *] {
        file copy [file join $package $entry] [file join $dir $entry]
    }
    set descriptor [pm::descriptor::read [file join $dir botlish.json] pack]
    set targets [dict getdef [dict create sdl3 {linux-aarch64 linux-x86_64} raven {linux-aarch64 linux-x86_64} \
        event_loop_linux {linux-aarch64 linux-x86_64} boringssl {linux-x86_64} http {linux-x86_64} process_linux {linux-x86_64}] $name {}]
    if {$targets eq ""} {
        return [list $dir ""]
    }
    if {[info commands ::author::$name] eq ""} {
        error "packages/$name has no recipe here"
    }
    $name $dir $targets
    set path [file join $stage $name.evidence.json]
    pm::WriteNew $path [evidenceText [dict get $descriptor name] [dict get $descriptor version]]
    return [list $dir $path]
}

# The releases recorded in packages/RELEASES.tsv: {NAME VERSION} -> SHA256.
# (BOTLISH_RELEASE_LEDGER, from the environment only, names another ledger:
# for the tests of the candidate rule, tests/package-workloads.test.)
proc author::releases {} {
    variable root
    set ledger [file join $root packages RELEASES.tsv]
    if {[info exists ::env(BOTLISH_RELEASE_LEDGER)] && $::env(BOTLISH_RELEASE_LEDGER) ne ""} {
        set ledger $::env(BOTLISH_RELEASE_LEDGER)
    }
    set recorded [dict create]
    foreach line [split [pm::ReadBytes $ledger] \n] {
        if {$line eq "" || [string index $line 0] eq "#"} continue
        lassign [split $line \t] name version digest
        dict set recorded [list $name $version] $digest
    }
    return $recorded
}

# Compares the artifact just packed with the recorded release of its
# version: the release, a new release, or a candidate.
proc author::checkRelease {out descriptor release} {
    set name [dict get $descriptor name]
    set version [dict get $descriptor version]
    set path [file join $out $name-$version.botpkg]
    set digest [pm::sha256::hex [pm::ReadBytes $path]]
    set recorded [releases]
    set key [list $name $version]
    if {![dict exists $recorded $key]} {
        puts "  release: $name $version is not recorded in packages/RELEASES.tsv: a new release once it is published (record its SHA-256 there)"
        return
    }
    if {[dict get $recorded $key] eq $digest} {
        puts "  release: the recorded release of $name $version (packages/RELEASES.tsv)"
        return
    }
    set message "CANDIDATE: the recorded release of $name $version is sha256 [dict get $recorded $key], and this build is $digest: a rebuild that did not reproduce it, never the release (botlish package compare RELEASE $path explains the difference)"
    if {!$release} {
        puts "  $message"
        return
    }
    set candidate [file join $out $name-$version.candidate-[string range $digest 0 11].botpkg]
    file rename -force $path $candidate
    error "$message; renamed $candidate"
}

file mkdir $out
set status 0
foreach name $names {
    set stage [file tempdir botlish-package-repository]
    try {
        lassign [author::prepare $name $stage] dir evidence
        set pack [list package pack $dir -out $out]
        if {$evidence ne ""} {
            # The audit, as an author reads it before packing.
            author::botlish native audit $dir
            lappend pack -evidence $evidence
        }
        if {$force} { lappend pack -force }
        set output [author::botlish {*}$pack]
        puts [join [lrange [split $output \n] 0 end] \n]
        set descriptor [pm::descriptor::read [file join $dir botlish.json] pack]
        if {[pm::targets::Aware $descriptor]} {
            puts "  targets [join [lsort [dict keys [dict get $descriptor targets]]] {, }]"
        } else {
            puts "  targets: every target (no native files)"
        }
        author::checkRelease $out $descriptor $release
    } on error {message options} {
        puts stderr "$name: $message"
        set status 1
    } finally {
        file delete -force $stage
    }
}
exit $status
