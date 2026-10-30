# raven-package.tcl -- install the Raven package (packages/raven;
# RAVEN-BINDINGS.md, "The package").
#
#   tclsh9.0 tools/raven-package.tcl install APP ?-target T?
#       copy the package into APP/.bot_modules/raven, stage the committed
#       generated binding of target T (the host's by default) beside it,
#       and build the event bridge's archive there
#
# The package is one module tree: the hand-written wrapper, `raven`
# (raven.bot), and the GENERATED binding of the target, `raven::core`,
# `raven::window`, ... (generated/c/raven/TARGET/raven/, staged as the
# package's raven/ directory, never edited). The wrapper links the bridge
# (native/raven_bridge.c) from the archive this builds beside it
# (`extern c library "raven_bridge" static at "native/libraven_bridge.a"`,
# resolved from the package instance's directory:
# NATIVE-LINK-PLAN-MILESTONE-1.md); the binding links Raven itself, the
# shared libraven.so, by the linker's -L (tests/cffi/raven.tcl builds the
# pinned release). The bridge is compiled against the pinned Raven's own
# headers (tools/c-bindgen.tcl fetch raven), with the host's C compiler (CC,
# default cc) and ar -- never by the compiler.
#
# Sourced, it defines ravenPackage::install (tests/raven.test).
namespace eval ravenPackage {
    variable here [file dirname [file normalize [info script]]]
    variable repo [file dirname $here]
    variable package [file join $repo packages raven]
}

proc ravenPackage::cc {} {
    if {[info exists ::env(CC)] && $::env(CC) ne ""} {
        return $::env(CC)
    }
    return cc
}

# The host's Botlish target (core/cabi.tcl's names): the generated binding
# a package installed here links.
proc ravenPackage::hostTarget {} {
    set machine $::tcl_platform(machine)
    if {$::tcl_platform(os) ne "Linux"} {
        error "raven-package: Raven's binding is generated for Linux only (RAVEN-BINDINGS.md, \"Targets\")"
    }
    switch -- $machine {
        x86_64 - amd64 { return linux-x86_64 }
        aarch64 - arm64 { return linux-aarch64 }
    }
    error "raven-package: no Raven binding for the machine $machine"
}

# The directory of the pinned Raven's headers (the fetched checkout's
# include/).
proc ravenPackage::includeDir {} {
    variable repo
    set fetched [exec [info nameofexecutable] [file join $repo tools c-bindgen.tcl] fetch raven]
    return [file join [lindex [split [string trim $fetched] \n] end] include]
}

# Installs the package into APP's .bot_modules and builds its archive; the
# installed package's directory.
proc ravenPackage::install {app {target ""}} {
    variable repo
    variable package
    if {$target eq ""} { set target [hostTarget] }
    set binding [file join $repo generated c raven $target raven]
    if {![file isdirectory $binding]} {
        error "raven-package: no generated Raven binding for $target ($binding)"
    }
    set into [file join $app .bot_modules raven]
    file delete -force $into
    file mkdir [file join $into native]
    foreach file {raven.bot README.md native/raven_bridge.c} {
        file copy [file join $package $file] [file join $into $file]
    }
    file copy $binding [file join $into raven]
    set object [file join $into native raven_bridge.o]
    exec [cc] -std=c11 -O2 -Wall -Wextra -Werror -fPIC -pthread -I[includeDir] \
        -c [file join $into native raven_bridge.c] -o $object
    exec ar rcs [file join $into native libraven_bridge.a] $object
    file delete $object
    return $into
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    set usage "usage: tclsh9.0 tools/raven-package.tcl install APP ?-target T?"
    if {[lindex $::argv 0] ne "install" || [llength $::argv] ni {2 4}
            || ([llength $::argv] == 4 && [lindex $::argv 2] ne "-target")} {
        puts stderr $usage
        exit 2
    }
    puts [ravenPackage::install [file normalize [lindex $::argv 1]] [lindex $::argv 3]]
}
