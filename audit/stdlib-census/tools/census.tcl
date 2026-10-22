# census.tcl -- the machine-readable inventory of the standard library
# (STD-NAMESPACE.md, "The census").
#
#   tclsh9.0 audit/stdlib-census/tools/census.tcl ?-root CHECKOUT? ?-out FILE?
#
# Loads the front end of CHECKOUT (this checkout by default), and writes one
# tab-separated row per standard-library entity: every namespace, every
# member a module file declares and every native the registry holds. The
# columns:
#
#   name       the canonical name a program spells (`std::list::at`), or the
#              registered name of a root primitive or an internal native
#   kind       namespace, function, binding, type, refined-type, struct,
#              opaque-struct, context-struct, enum, enum-case, error, trait,
#              context-trait, layout, union-layout, extern-fn, intrinsic,
#              intrinsic-type, c-scalar-type, builtin-error, builtin-enum
#   namespace  the namespace the entity is a member of ("" for the root)
#   role       api (program-visible standard library), primitive (a root
#              language primitive, not in any namespace), internal (a native
#              no source can spell: `#` names and core-IR-only accessors),
#              builtin (a runtime error or enum every program sees),
#              demo (a demonstration module), std-internal (a member of an
#              internal namespace, core::native::declareInternalNamespace,
#              or that namespace: only standard-library modules may name it)
#   origin     source (a module file), intrinsic (a registered native or a
#              compiler-declared type), source+intrinsic (a namespace with
#              both)
#   location   the defining file and line for a source declaration; the
#              file registering a native (found by its literal registration)
#   platform   the operating system whose platform namespace it is in
#              (core::cabi::platformOf), or ""
#   arch       the architecture of an architecture-specific module file, or ""
#   direct     1 for a namespace designated direct (`direct module`, or
#              core::native::declareDirectNamespace), else ""
#
# Rows are sorted by name, then kind, so two runs over the same tree are
# byte-identical and a diff of two censuses is the migration.

set options [dict create -root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]] -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        puts stderr "census.tcl: unknown option \"$option\""
        exit 2
    }
    dict set options $option $value
}
set root [file normalize [dict get $options -root]]
source [file join $root surface surface.tcl]
set library $::core::libraryDir

# The namespace of standard-library NAMESPACE as a program spells it. Before
# STD-NAMESPACE.md a module's namespace was its path under lib/; after it,
# the stdlib directory is namespace std's own.
proc Spelled {relative} {
    if {[file tail $::library] eq "stdlib"} {
        return "std::$relative"
    }
    return $relative
}

proc Rel {path} {
    set prefix "$::root/"
    if {[string first $prefix $path] == 0} {
        return [string range $path [string length $prefix] end]
    }
    return $path
}

proc Platform {ns} {
    return [core::cabi::platformOf $ns]
}

set rows {}
proc Row {name kind ns role origin location {arch ""} {direct ""}} {
    lappend ::rows [list $name $kind $ns $role $origin $location [Platform [expr {$ns eq "" ? $name : $ns}]] $arch $direct]
}

# Every module file of the library: {NAMESPACE PATH ARCH}.
proc ModuleFiles {dir prefix} {
    set found {}
    foreach path [lsort [glob -nocomplain -directory $dir -types f *.bot]] {
        set base [file rootname [file tail $path]]
        set arch ""
        if {[regexp {^(.*)\.([A-Za-z0-9_]+)$} $base -> stem a]} {
            set base $stem
            set arch $a
        }
        lappend found [list [join [concat $prefix [list $base]] ::] $path $arch]
    }
    foreach sub [lsort [glob -nocomplain -directory $dir -types d *]] {
        lappend found {*}[ModuleFiles $sub [concat $prefix [list [file tail $sub]]]]
    }
    return $found
}

# The file registering native NAME, by its literal registration.
proc RegisteredIn {name} {
    foreach path [lsort [concat [glob -directory [file join $::root core] *.tcl] \
            [glob -directory [file join $::root hir] *.tcl]]] {
        set text [core::ReadFile $path]
        set lines [split $text \n]
        set n 0
        foreach line $lines {
            incr n
            if {[regexp {core::native::register\s+(\S+)} $line -> registered] && $registered eq $name} {
                return "[Rel $path]:$n"
            }
        }
    }
    return ""
}

set moduleNamespaces [dict create]
foreach entry [ModuleFiles $library {}] {
    lassign $entry relative path arch
    set ns [Spelled $relative]
    dict lappend moduleNamespaces $ns [list $path $arch]
}

# Source declarations.
dict for {ns files} $moduleNamespaces {
    foreach file $files {
        lassign $file path arch
        if {$arch ne "" && $arch ne "x86_64"} {
            # One architecture's file stands for the namespace's surface
            # (lst-linux-sys-same-surface keeps them identical).
            continue
        }
        set ast [surface::parse [core::ReadFile $path] $path]
        set role api
        if {[string match *mathish $ns]} {
            set role demo
        }
        foreach statement [dict get $ast body] {
            if {![dict exists $statement name]} {
                continue
            }
            set name "${ns}::[dict get $statement name]"
            set location "[Rel $path]:[dict get $statement span line]"
            switch -- [dict get $statement kind] {
                function { set kind function }
                bind { set kind binding }
                typedecl {
                    set kind [expr {[dict get $statement form] eq "refined" ? "refined-type" : "type"}]
                }
                structdecl {
                    set kind struct
                    if {[dict get $statement opaque]} { set kind opaque-struct }
                    if {[dict get $statement context]} { set kind context-struct }
                }
                enumdecl {
                    set kind enum
                    foreach case [dict get $statement cases] {
                        Row "${name}::[dict get $case name]" enum-case $name $role source $location $arch
                    }
                }
                errordecl { set kind error }
                traitdecl {
                    set kind [expr {[dict get $statement context] ? "context-trait" : "trait"}]
                }
                layoutdecl {
                    set kind [expr {[dict getdef $statement union 0] ? "union-layout" : "layout"}]
                }
                externfn { set kind extern-fn }
                default { set kind [dict get $statement kind] }
            }
            Row $name $kind $ns $role source $location $arch
        }
    }
}

# The role of a member of namespace NS: std-internal for an internal
# namespace's (a front end that has the notion), else api.
proc Visibility {ns} {
    if {[info commands ::core::native::isInternalNamespace] ne ""
            && [core::native::isInternalNamespace $ns]} {
        return std-internal
    }
    return api
}

# Registered natives.
set nativeNamespaces [dict create]
foreach name [lsort [core::native::names]] {
    set ns [core::native::namespaceOf $name]
    if {[string first # $name] >= 0 || [regexp {[a-z]-[a-z]} $name]} {
        Row $name intrinsic "" internal intrinsic [RegisteredIn $name]
        continue
    }
    if {$ns eq ""} {
        Row $name intrinsic "" primitive intrinsic [RegisteredIn $name]
        continue
    }
    dict set nativeNamespaces $ns 1
    Row $name intrinsic $ns [Visibility $ns] intrinsic [RegisteredIn $name]
}

# Compiler-declared types of ffi::c (C-ABI-TYPES.md).
set cns $::core::cabi::namespace
foreach t $::hir::cabi::intrinsicTypes {
    Row "${cns}::$t" intrinsic-type $cns api intrinsic hir/cabi.tcl
}
foreach t [core::cabi::scalarNames] {
    Row "${cns}::$t" c-scalar-type $cns api intrinsic core/cabi.tcl
}
dict set nativeNamespaces $cns 1

# Runtime builtins every program sees, in no namespace.
foreach e [core::native::builtinErrorNames] {
    Row $e builtin-error "" builtin intrinsic core/native.tcl
}
foreach e [core::native::builtinEnums] {
    Row $e builtin-enum "" builtin intrinsic core/native.tcl
}

# Namespaces.
foreach ns [lsort -unique [concat [dict keys $moduleNamespaces] [dict keys $nativeNamespaces]]] {
    set hasSource [dict exists $moduleNamespaces $ns]
    set hasNative [dict exists $nativeNamespaces $ns]
    set origin [expr {$hasSource && $hasNative ? "source+intrinsic" : ($hasSource ? "source" : "intrinsic")}]
    set location ""
    set arch ""
    set direct ""
    if {$hasSource} {
        set paths {}
        set archs {}
        foreach file [dict get $moduleNamespaces $ns] {
            lassign $file path a
            lappend paths [Rel $path]
            if {$a ne ""} {
                lappend archs $a
            }
            if {[dict getdef [surface::parse [core::ReadFile $path] $path] direct ""] ne ""} {
                set direct 1
            }
        }
        set location [join $paths ,]
        set arch [join $archs ,]
    }
    if {[core::native::isDirectNamespace $ns]} {
        set direct 1
    }
    Row $ns namespace "" [expr {[string match *mathish $ns] ? "demo" : [Visibility $ns]}] $origin $location $arch $direct
}

set out [list [join {name kind namespace role origin location platform arch direct} \t]]
foreach row [lsort -index 0 [lsort -index 1 $rows]] {
    lappend out [join $row \t]
}
set text "[join $out \n]\n"
if {[dict get $options -out] eq ""} {
    puts -nonewline $text
} else {
    set ch [open [dict get $options -out] w]
    fconfigure $ch -encoding utf-8 -translation lf
    puts -nonewline $ch $text
    close $ch
}
