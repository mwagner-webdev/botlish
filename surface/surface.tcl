# surface.tcl -- the Botlish source frontend.
#
#   source surface/surface.tcl              ;# also loads hir and core
#
#   surface::lex SOURCE ?FILENAME?          tokens                (lexer.tcl)
#   surface::parse SOURCE ?FILENAME? ?-recover 1?      surface AST (parser.tcl)
#   surface::formatAst AST ?-spans 1? ?-ids 1?         readable AST (ast.tcl)
#   surface::findNode AST ID                the node with a structural id
#   surface::lowerToHir AST ?-strict 1|0?   HIR                   (lower.tcl)
#   surface::hirExprs HIR ID                HIR expressions from AST node ID
#   surface::compile SOURCE ?FILENAME? ?-strict 1|0?   parse + lowerToHir
#   surface::readProgramFile PATH ?-strict 1|0?        compile a .bot file
#
# Pipeline:
#
#   source --lex--> tokens --parse--> surface AST --lowerToHir--> HIR syntax
#     --hir::buildSyntax--> HIR
#     HIR --hir::lower--> core IR --> interpreter
#     HIR --core::compiler::evalHir--> Tcl compiler
#
# Parsing never runs semantic analysis, so the AST of a program with
# semantic errors can still be inspected; with -recover 1, so can the AST of
# a program with syntax errors (its `diagnostics` lists them all). Syntax
# errors raise {SURFACE SYNTAX DIAGNOSTIC}; semantic errors found by HIR
# raise {CORE SEMANTIC KIND} with "FILE:LINE:COLUMN: " before the message
# (with -strict 0 they stay HIR diagnostics and are raised at run time).

if {[info commands ::hir::build] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] hir hir.tcl]
}

namespace eval surface {
    variable home [file dirname [file normalize [info script]]]
}

proc surface::compile {source args} {
    set filename <input>
    if {[llength $args] % 2} {
        set args [lassign $args filename]
    }
    return [surface::lowerToHir [surface::parse $source $filename] {*}$args]
}

# The HIR of the source file PATH, after loading the libraries it names in
# "# requires: NAME" comments (as for .ir and .hir files).
proc surface::readProgramFile {path args} {
    foreach name [core::programFileRequires $path] {
        core::loadLibrary $name
    }
    return [surface::compile [core::ReadFile $path] $path {*}$args]
}

apply {{dir} {
    foreach name {ast lexer parser lower} {
        uplevel #0 [list source [file join $dir $name.tcl]]
    }
}} $surface::home
