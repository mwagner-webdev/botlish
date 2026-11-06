# http.tcl -- the http and boringssl packages' native files for the tests
# (tests/http-client.test; HTTP-CLIENT-PACKAGE-MILESTONE-1.md).
#
#   tclsh9.0 tests/cffi/http.tcl        build them (once): the pinned
#                                        BoringSSL provider and its renamed
#                                        archives, the released unit and the
#                                        test unit; print the units
#   source tests/cffi/http.tcl           cffi::httpBuilt: 1 when all of
#                                        them are in the cache
#
# The builds are tools/http-package.tcl's (the release recipe's own), in
# Botlish's cache (http-package/), never the repository. They need cargo
# and rustc (1.95+), cmake, ninja, a C and C++ compiler, git and the
# network (crates.io, boringssl.googlesource.com) the first time. Test
# infrastructure: the compiler and runtime never build or need it, and a
# package consumer installs the released artifacts instead.
namespace eval cffi {
    variable httpHere [file dirname [file normalize [info script]]]
}
source [file join [file dirname [file dirname $::cffi::httpHere]] tools http-package.tcl]

# 1 when the provider's archives and both units exist for the host.
proc cffi::httpBuilt {} {
    if {[catch {httppkg::Host} target]} { return 0 }
    set id [httppkg::ProviderId]
    set dir [httppkg::CacheDir]
    foreach f [list [file join $dir provider-archives $id-$target STAMP] \
            [file join $dir units release-$target libbotlish_http.a] \
            [file join $dir units testing-$target libbotlish_http.a]] {
        if {![file exists $f]} { return 0 }
    }
    return 1
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    httppkg::ProviderArchives
    puts [httppkg::Unit "" 0]
    puts [httppkg::Unit "" 1]
}
