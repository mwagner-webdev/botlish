# core.tcl -- loads the reference evaluator.
#
#   source core/core.tcl
#   core::formatValue [core::eval {call {ref +} {const 1} {const 2}}]   ;# => 3
#
# Optional Tcl libraries in the standard library's directory (stdlib/NAME.tcl,
# named by a program file's "# requires: NAME" comment) are not loaded by
# default:
#
#   core::loadLibrary web

if {[package vcompare [info tclversion] 9.0] < 0} {
    error "Botlish's Tcl reference implementation requires Tcl 9.x for Unicode\
        scalar-value string semantics (found Tcl [info patchlevel]); Tcl 8.x\
        represents supplementary-plane characters as surrogate pairs, which\
        disagrees with Botlish's String semantics and the other backends."
}
package require Tcl 9.0

namespace eval core {
    variable home [file dirname [file normalize [info script]]]
    # The standard library's root: the directory of the compiler-owned
    # namespace std (STD-NAMESPACE.md), stdlib/ beside core/ in this
    # distribution -- the checkout, or the packed tree of the single
    # executable (//zipfs:/app/botlish/stdlib). std::list is
    # $libraryDir/list.bot, std::abi::x86_64 $libraryDir/abi/x86_64.bot
    # (surface/modules.tcl). It follows from where the compiler itself is,
    # never from the working directory, the application or the environment;
    # a test points it at a private copy (tests/helpers.tcl's
    # withPrivateLibrary).
    variable libraryDir [file join [file dirname $home] stdlib]
    variable loadedLibraries {}
    # The Tcl recursion limit an entry point runs Botlish programs under
    # (core::useProgramRecursionLimit): main.tcl, and so the single
    # executable, and tests/golden/run.tcl. The Tcl backends evaluate a
    # Botlish call as nested Tcl evaluations (the interpreter about seven per
    # call, the Tcl compiler one), so tclsh's default of 1000 ends an
    # ordinary interpreted recursion about 140 calls deep
    # (2048-ENGINE-WORKLOAD.md, S22). Under this limit the interpreter runs
    # about 14,000 nested calls and the compiler about 99,000; deeper still
    # fails as before, with TCL LIMIT STACK (on the interpreter only after
    # about a minute: Tcl unwinds an error through its nested try/finally
    # bodies in quadratic time). Tcl 9's non-recursive engine
    # does not grow the C stack for these evaluations, so the limit bounds a
    # count, not native memory. The same number as the front end's floor
    # (hir::recursionFloor).
    variable programRecursionLimit 100000
}

# Raises this interpreter's recursion limit to programRecursionLimit (above);
# an embedder's higher limit is kept.
proc core::useProgramRecursionLimit {} {
    variable programRecursionLimit
    if {[interp recursionlimit {}] < $programRecursionLimit} {
        interp recursionlimit {} $programRecursionLimit
    }
}

apply {{dir} {
    foreach file {
        errors value completion env ir type regex
        block native callable refine runtime evaluator
        primitives predicates scalarbits unicodechar float strings tclcompat lists immutableset mutarray hashing process linuxabi bytestore binary decimal listlength inttext contexts coroutines affine mutvec cabi programfile dfa
    } {
        uplevel #0 [list source [file join $dir $file.tcl]]
    }
}} $core::home

# Loads the optional library stdlib/NAME.tcl once. Libraries register types and
# natives globally; root environments created afterwards include them.
proc core::loadLibrary {name} {
    variable libraryDir
    variable loadedLibraries
    if {![regexp {^[A-Za-z0-9_-]+$} $name]} {
        error "core::loadLibrary: invalid library name \"$name\""
    }
    if {$name in $loadedLibraries} {
        return
    }
    set path [file join $libraryDir $name.tcl]
    if {![file exists $path]} {
        error "core::loadLibrary: no library \"$name\" in $libraryDir"
    }
    uplevel #0 [list source $path]
    lappend loadedLibraries $name
    return
}

package provide core 0.1
