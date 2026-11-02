# profile.tcl -- binding profiles (C-BINDGEN.md, "Profiles").
#
# A profile is a development-time description of one C library's binding:
# where its headers come from and how they are preprocessed (a header
# profile in the archaeology's format, C-HEADER-ARCHAEOLOGY.md "Profiles"),
# which Botlish targets it is generated for, the native linker's library
# names, the explicit API selection policy, the binding author's foreign
# contracts, the signatures of macro APIs that are to be thunked, and
# whether compiler evidence is gathered. tools/c-bindgen/profiles/NAME.tcl
# evaluates to the profile's dict; nothing here is read by the compiler.
#
#   name         the profile's name, also the binding's root namespace
#   description  one line
#   headers      the header profile: library, source ({url URL tag TAG
#                commit COMMIT}, {local DIR} relative to the repository, or
#                {toolchain FILE version {MACRO VALUE ...}}: the target
#                toolchain's own headers, the directory of its include
#                search list that holds FILE -- MinGW-w64's, which a cross
#                installation provides -- pinned by the bodies of its
#                version macros as the translation unit defines them),
#                includeDirs, defines, undefines, flags, public, private
#                (globs of headers under the source root that are never
#                public: a toolchain's C runtime beside its platform API),
#                bundled, entry; optional targetDefines {TARGET-GLOB
#                {DEFINE ...}}
#   targets      the Botlish targets (core/cabi.tcl's names) it supports
#   modules      {stripPrefix PREFIX}: a header's module is its file stem
#                without PREFIX, lowercased
#   libraries    rules {headers GLOBS targets GLOBS names {LIB ...}}: each
#                module declares the names of every rule matching its
#                header and the target, in rule order (the linker's -lNAME);
#                or {targets GLOBS symbols {LIB ...}}: each bound function's
#                library is the first of LIBs whose library file (the
#                toolchain's -print-file-name=libLIB.a) defines its link
#                symbol, a module declaring the libraries of its functions
#                (Windows import libraries, C-BINDGEN-LAYOUTS.md)
#   exclude      explicit deny patterns (string match) of API names
#   contracts    {FUNCTION {PARAM FACTS ... result FACTS}}: the binding
#                author's foreign contracts (C-FFI.md, "Contracts")
#   groups       {{functions {F ...} facts {PARAM FACTS ...}} ...}: one
#                contract stated for an explicit list of functions
#   representations
#                {{functions {F ...} raw {POSITION ...}} ...}: the C float
#                and double positions (a parameter's C name, or result) of
#                an explicit list of functions that the binding writes raw,
#                std::ffi::c::RawFloat and std::ffi::c::RawDouble, instead of
#                the default std::ffi::c::Float and std::ffi::c::Double
#                (RAW-C-FLOAT-FFI-MILESTONE-1.md): the same C ABI, which the
#                headers alone decide, with every bit pattern carried and
#                none admitted. A function, parameter or position that is no
#                C float or double is a stale policy (an error)
#   thunks       {NAME {C PROTOTYPE}}: the signature of a function-like
#                macro API the binding thunks (a macro has none)
#   stubs        thunk | unsupported: what a table-redirected API name
#                becomes (default thunk)
#   evidence     none | llvm: whether clang's optimized IR of the shim is
#                read for nocapture/readonly/writeonly/returned facts
#   output       where the generated bindings are committed, relative to
#                the repository: OUTPUT/TARGET/ (default generated/c/NAME)

namespace eval ::cbind::profile {
    variable dir [file join [file dirname [file normalize [info script]]] profiles]
    variable keys {name description headers targets modules libraries exclude contracts
        groups representations thunks stubs evidence output}
    variable headerKeys {library source includeDirs defines undefines flags public private bundled
        internal entry description targetDefines}
}

# The names of the profiles (profiles/*.tcl), sorted.
proc ::cbind::profile::names {} {
    variable dir
    return [lsort [lmap p [glob -nocomplain -directory $dir *.tcl] {file rootname [file tail $p]}]]
}

# The validated profile NAME (or the profile file PATH when NAME names one).
proc ::cbind::profile::load {name} {
    variable dir
    set path [expr {[file exists $name] && [file isfile $name] ? $name : [file join $dir $name.tcl]}]
    if {![file exists $path]} {
        error "c-bindgen: no profile \"$name\" (known: [join [names] {, }])"
    }
    set profile [apply [list {} [list source $path]]]
    dict set profile path [file normalize $path]
    return [Validate $profile]
}

proc ::cbind::profile::Validate {p} {
    variable keys
    variable headerKeys
    foreach k [dict keys $p] {
        if {$k ni $keys && $k ne "path"} {
            error "c-bindgen: profile [dict get $p path]: unknown key \"$k\" (known: [join $keys {, }])"
        }
    }
    foreach k {name headers targets} {
        if {![dict exists $p $k]} {
            error "c-bindgen: profile [dict get $p path]: no \"$k\""
        }
    }
    set defaults [dict create description "" modules {stripPrefix ""} libraries {} exclude {} \
        contracts {} groups {} representations {} thunks {} stubs thunk evidence none]
    set p [dict merge $defaults $p]
    if {![dict exists $p output]} { dict set p output generated/c/[dict get $p name] }
    if {![regexp {^[a-z][a-z0-9_]*$} [dict get $p name]]} {
        error "c-bindgen: profile name \"[dict get $p name]\" is no Botlish namespace (lowercase letters, digits, _)"
    }
    set h [dict get $p headers]
    foreach k [dict keys $h] {
        if {$k ni $headerKeys} {
            error "c-bindgen: profile [dict get $p name]: unknown header key \"$k\""
        }
    }
    set h [dict merge [dict create includeDirs {} defines {} undefines {} flags {} bundled {} \
        private {} targetDefines {}] $h]
    foreach k {library source public entry} {
        if {![dict exists $h $k]} {
            error "c-bindgen: profile [dict get $p name]: the header profile has no \"$k\""
        }
    }
    set source [dict get $h source]
    if {[dict exists $source toolchain] && (![dict exists $source version] || ![llength [dict get $source version]] || [llength [dict get $source version]] % 2)} {
        error "c-bindgen: profile [dict get $p name]: a toolchain source pins its headers by version {MACRO VALUE ...}"
    }
    dict set p headers $h
    foreach t [dict get $p targets] {
        if {![core::cabi::isTarget $t]} {
            error "c-bindgen: profile [dict get $p name]: unknown target \"$t\" (known: [join [core::cabi::targetNames] {, }])"
        }
    }
    if {[dict get $p stubs] ni {thunk unsupported}} {
        error "c-bindgen: profile [dict get $p name]: stubs is thunk or unsupported, not \"[dict get $p stubs]\""
    }
    if {[dict get $p evidence] ni {none llvm}} {
        error "c-bindgen: profile [dict get $p name]: evidence is none or llvm, not \"[dict get $p evidence]\""
    }
    foreach rule [dict get $p libraries] {
        foreach k [dict keys $rule] {
            if {$k ni {headers targets names symbols}} {
                error "c-bindgen: profile [dict get $p name]: a library rule has an unknown key \"$k\""
            }
        }
        if {[dict exists $rule symbols] == [dict exists $rule names]} {
            error "c-bindgen: profile [dict get $p name]: a library rule names its libraries by header (names) or by symbol (symbols), one of the two"
        }
        if {[dict exists $rule symbols] && [dict exists $rule headers]} {
            error "c-bindgen: profile [dict get $p name]: a symbol library rule applies to every header (no headers key)"
        }
        foreach n [expr {[dict exists $rule names] ? [dict get $rule names] : [dict get $rule symbols]}] {
            if {![regexp {^[A-Za-z0-9_][A-Za-z0-9_+.-]*$} $n]} {
                error "c-bindgen: profile [dict get $p name]: \"$n\" is no linker library name"
            }
        }
    }
    foreach group [dict get $p groups] {
        foreach k [dict keys $group] {
            if {$k ni {name functions facts}} {
                error "c-bindgen: profile [dict get $p name]: a contract group has an unknown key \"$k\""
            }
        }
    }
    foreach rule [dict get $p representations] {
        foreach k [dict keys $rule] {
            if {$k ni {name functions raw}} {
                error "c-bindgen: profile [dict get $p name]: a representation rule has an unknown key \"$k\" (known: name, functions, raw)"
            }
        }
        if {![dict exists $rule functions] || ![dict exists $rule raw] || ![llength [dict get $rule functions]]
                || ![llength [dict get $rule raw]]} {
            error "c-bindgen: profile [dict get $p name]: a representation rule names its functions and the positions they write raw"
        }
    }
    return $p
}

# The header profile of P for TARGET: its defines with the target's own.
proc ::cbind::profile::headersFor {p target} {
    set h [dict get $p headers]
    set defines [dict get $h defines]
    foreach {pattern extra} [dict get $h targetDefines] {
        if {[string match $pattern $target]} { lappend defines {*}$extra }
    }
    dict set h defines $defines
    if {![dict exists $h description]} { dict set h description [dict get $p description] }
    return [dict remove $h targetDefines]
}

# The library names of a module of HEADER (a source-relative path) on
# TARGET, in rule order, each once.
proc ::cbind::profile::librariesOf {p header target} {
    set names {}
    foreach rule [dict get $p libraries] {
        if {[dict exists $rule symbols]} continue
        set headers [expr {[dict exists $rule headers] ? [dict get $rule headers] : "*"}]
        set targets [expr {[dict exists $rule targets] ? [dict get $rule targets] : "*"}]
        set hit 0
        foreach g $headers { if {[string match $g $header]} { set hit 1 } }
        if {!$hit} continue
        set hit 0
        foreach g $targets { if {[string match $g $target]} { set hit 1 } }
        if {!$hit} continue
        foreach n [dict get $rule names] {
            if {$n ni $names} { lappend names $n }
        }
    }
    return $names
}

# The libraries P's symbol rules search for a bound function's link symbol
# on TARGET, in order, each once ({} when no symbol rule applies).
proc ::cbind::profile::symbolLibraries {p target} {
    set names {}
    foreach rule [dict get $p libraries] {
        if {![dict exists $rule symbols]} continue
        set targets [expr {[dict exists $rule targets] ? [dict get $rule targets] : "*"}]
        set hit 0
        foreach g $targets { if {[string match $g $target]} { set hit 1 } }
        if {!$hit} continue
        foreach n [dict get $rule symbols] {
            if {$n ni $names} { lappend names $n }
        }
    }
    return $names
}

# The name the command line gives P: its file's stem for a profile of the
# profiles directory (the fixture's file is fixture.tcl, its name bgf), else
# its file's path relative to the repository.
proc ::cbind::profile::cliName {p} {
    variable dir
    set path [dict get $p path]
    if {[file dirname $path] eq [file normalize $dir]} {
        return [file rootname [file tail $path]]
    }
    return [::chdr::relPath $::chdr::repoDir $path]
}

# 1 if API NAME is excluded by P's explicit deny patterns.
proc ::cbind::profile::excluded {p name} {
    foreach pattern [dict get $p exclude] {
        if {[string match $pattern $name]} { return 1 }
    }
    return 0
}

# Where P's bindings for TARGET are committed.
proc ::cbind::profile::outputDir {p target} {
    return [file join $::chdr::repoDir [dict get $p output] $target]
}

# The source root of P's headers: a fetched, pinned checkout, a local
# directory of the repository, or (a toolchain source) the directory of
# TARGET's toolchain's include search list holding the source's file (P's
# first target by default).
proc ::cbind::profile::sourceRoot {p {fetch 0} {target ""}} {
    set h [dict get $p headers]
    set source [dict get $h source]
    if {[dict exists $source local]} {
        return [file normalize [file join $::chdr::repoDir [dict get $source local]]]
    }
    if {[dict exists $source toolchain]} {
        if {$target eq ""} { set target [lindex [dict get $p targets] 0] }
        set config [::chdr::toolchain::configFor $target]
        lassign [::chdr::toolchain::searchDirs $config [dict create includeDirs {} defines {} undefines {} \
            flags [dict get $h flags]]] ok dirs stderr
        foreach d $dirs {
            if {[file exists [file join $d [dict get $source toolchain]]]} {
                return [file dirname [file normalize [file join $d .x]]]
            }
        }
        error "c-bindgen: the $target toolchain ([lindex [dict get $config cc] 0] --target=[dict get $config target]) searches no directory holding [dict get $source toolchain] ([join $dirs {, }]): install the target's headers (for windows-x86_64-gnu, Debian and Ubuntu's mingw-w64-x86-64-dev)"
    }
    set dir [file join [::chdr::sourcesDir] [dict get $h library]]
    if {$fetch || ![file isdirectory $dir]} {
        if {!$fetch} {
            error "c-bindgen: no [dict get $h library] sources at $dir (run tools/c-bindgen.tcl fetch [dict get $p name])"
        }
        ::chdr::fetch [dict get $h library] $source
    }
    set revision [exec git -C $dir rev-parse HEAD]
    if {$revision ne [dict get $source commit]} {
        error "c-bindgen: $dir is at $revision, the profile pins [dict get $source commit]"
    }
    # Symbolic links resolved, so that preprocessor paths match.
    return [file dirname [file normalize [file join $dir .x]]]
}
