# evidence.tcl -- regenerates the principal vertical program's evidence
# under audit/traits/principal/ (TRAITS.md, "Evidence").
#
#   tclsh9.0 audit/traits/tools/evidence.tcl ?-outdir DIR?
#
# The program is TRAITS.md's principal vertical test: trait Named in
# ui::named, an entry-program struct Person and an opaque services::Service,
# each with its own `name`, and
#
#   fn describe(value: Named) -> str:
#       value.name()
#
# called with both, beside a hand-written concrete function of the same
# body (`describe_person(value: Person)`) for comparison. Written files:
#
#   program/          the entry program and the two library modules
#   traits.txt        main.tcl -traits: traits, conformances, specializations
#   hir.txt           the monomorphized HIR every backend compiles (HIR text)
#   nir.txt           the program's NIR (native::nir, -tiny-leaf-inline-opt 0
#                     so the calls under study stay visible)
#   clif.txt          Cranelift IR of describe<...>, describe_person and the
#                     implementations
#   asm.txt           objdump of the unlinked object (native::object), symbol
#                     labels as the scalar audit writes them
#   comparison.txt    NIR and machine-code bytes of describe<Person> vs
#                     describe_person; allocation reports of a trait loop vs
#                     a concrete loop
#
# The library is written into a temporary copy of lib/ (never the real one).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set outdir [file join $root audit traits principal]
foreach {option value} $argv {
    switch -- $option {
        -outdir { set outdir $value }
        default { error "unknown option $option" }
    }
}

proc W {path content} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $content
    close $f
}

set modules {
ui/named.bot {trait Named:
    fn name(value: Named) -> str
}
services.bot {import str

opaque struct Service:
    internal_name: str

fn make_service() -> Service:
    Service {internal_name: "db"}

fn name(value: Service) -> str:
    str::concat("svc:", value.internal_name)
}
}

set entry {import ui::named
import services
import type ui::named::Named

struct Person:
    value: str

fn name(value: Person) -> str:
    value.value

fn describe(value: Named) -> str:
    value.name()

fn describe_person(value: Person) -> str:
    value.name()

[describe(Person {value: "Alice"}), describe(services::make_service()), describe_person(Person {value: "Bob"})]
}

# One loop calling `describe` (trait) or `name` (concrete) 50 times.
proc loopProgram {call} {
    return "import ui::named\nimport services\nimport type ui::named::Named\n\nstruct Person:\n    value: str\n\nfn name(value: Person) -> str:\n    value.value\n\nfn describe(value: Named) -> str:\n    value.name()\n\nfn run(p: Person, n: int, acc: int) -> int:\n    if n == 0:\n        return acc\n    v = $call\n    run(p, n - 1, acc + 1)\n\nrun(Person {value: \"a\"}, 50, 0)\n"
}

# NIR function id -> name.
proc NirNames {nir} {
    set out [dict create]
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)"} $line -> id name]} {
            dict set out $id $name
        }
    }
    return $out
}

# The NIR text of function NAME (header to "end"), expression origins removed.
proc NirFunction {nir name} {
    set out {}
    set inside 0
    foreach line [split $nir \n] {
        if {[string match "func *" $line]} {
            set inside [string match "func * \"$name\" *" $line]
        }
        if {$inside} {
            lappend out [regsub -all { ?@e[0-9]+} $line ""]
            if {$line eq "end"} {
                set inside 0
            }
        }
    }
    return [join $out \n]
}

set library [file tempdir botlish-trait-evidence]
try {
    foreach entryPath [glob -directory $::core::libraryDir *] {
        file copy -force $entryPath $library
    }
    set ::core::libraryDir $library
    foreach {path text} $modules {
        W [file join $library $path] $text
        W [file join $outdir program lib $path] $text
    }
    W [file join $outdir program principal.bot] $entry

    set hir [surface::compile $entry principal.bot -warnings off]
    set value [core::value::show [native::evalHir $hir] 1]
    W [file join $outdir traits.txt] "[hir::traits::report $hir]\n"
    W [file join $outdir hir.txt] "[hir::format $hir]\n"

    set nir [native::nir $hir -tiny-leaf-inline-opt 0]
    W [file join $outdir nir.txt] "[regsub -all { ?@e[0-9]+} $nir {}]\n"
    set names [NirNames $nir]

    set clif [native::clif $hir -tiny-leaf-inline-opt 0]
    set wanted {describe<Person> describe<services::Service> describe_person name services::name}
    set clifOut {}
    set keep 0
    foreach line [split $clif \n] {
        if {[regexp {^; function \d+ "([^"]*)"} $line -> fname]} {
            set keep [expr {$fname in $wanted}]
            if {$keep && $clifOut ne {}} {
                lappend clifOut ""
            }
        }
        if {$keep} {
            lappend clifOut $line
            if {$line eq "\}"} {
                set keep 0
            }
        }
    }
    W [file join $outdir clif.txt] "[join $clifOut \n]\n"

    set obj [file join $library principal.o]
    native::object $hir $obj
    set pipe [open |[list objdump -dr --no-show-raw-insn -M intel $obj] r]
    set asm [read $pipe]
    close $pipe
    set asm [string map [list $obj principal.o] $asm]
    set labeled {}
    foreach line [split $asm \n] {
        if {[regexp {botlish_(?:fn|entry)_(\d+)} $line -> id] && [dict exists $names $id]} {
            set line [regsub {(botlish_(?:fn|entry)_\d+)} $line "\\1 ([dict get $names $id])"]
        }
        lappend labeled $line
    }
    W [file join $outdir asm.txt] "; principal.bot: native::object (Cranelift, specialize=1), objdump -dr --no-show-raw-insn -M intel\n[join $labeled \n]\n"

    lassign [native::codeSize $hir] total perFunction
    set sizes "total $total\n"
    set id 0
    foreach bytes $perFunction {
        append sizes "[expr {[dict exists $names $id] ? [dict get $names $id] : "fn$id"}]: $bytes\n"
        incr id
    }
    set comparison "principal.bot runs to $value on the native backend.\n\n"
    append comparison "== NIR (-tiny-leaf-inline-opt 0)\n\n"
    foreach fname {describe<Person> describe<services::Service> describe_person} {
        append comparison "[NirFunction $nir $fname]\n\n"
    }
    set a [lrange [split [NirFunction $nir describe<Person>] \n] 1 end]
    set b [lrange [split [NirFunction $nir describe_person] \n] 1 end]
    append comparison "describe<Person> body identical to describe_person body: [expr {$a eq $b}]\n\n"
    append comparison "== Machine code bytes per function (native::codeSize, specialize=1, default options)\n\n$sizes\n"
    append comparison "== Allocation (native::allocationReport summary; 50 calls in a loop)\n\n"
    foreach {label call} {trait describe(p) concrete name(p)} {
        set report [native::allocationReport [surface::compile [loopProgram $call] loop.bot -warnings off] summary]
        append comparison "$label ($call): allocations [dict get $report total allocations], bytes [dict get $report total allocatedBytes]\n"
    }
    W [file join $outdir comparison.txt] $comparison
} finally {
    file delete -force $library
}
puts "wrote $outdir"
