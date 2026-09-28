# Native implementations attached to resolved HIR. Unlike the raw-IR bridge,
# this preserves source locations, declared contracts, module identities and
# lexical shadowing. Shared by executable emission and direct HIR/JIT APIs.
proc native::prepareHir {hir} {
    set targets {}
    set namespaces {}
    set overrides {}
    set bodies {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref"} {
            set b [dict get $node binding]
            if {$b eq "" || [dict get $hir bindings $b kind] ne "root"} continue
            set value [dict get $hir bindings $b value]
            if {[core::value::kind $value] ne "native"} continue
            set name [core::value::nativeName $value]
            set module [dict get [core::native::metadata $name] moduleFn]
            if {$module ne "" && ![dict exists $hir moduleNativeTargets $name]} {
                dict set targets $name $module
                lappend namespaces [lindex $module 0]
            }
        } elseif {[dict get $node kind] eq "call"} {
            lassign [dict get $node target] kind symbol
            if {$kind ne "native"} continue
            set name [dict get $hir symbols $symbol name]
            set meta [core::native::metadata $name]
            if {[dict get $meta moduleFn] ne "" || [dict get $meta nativeBody] ne ""} {
                dict set overrides $e [dict get $meta resultType]
            }
            if {[dict get $meta nativeBody] ne "" && [dict get $node known] eq ""} {
                dict set bodies $e [dict get $meta nativeBody]
            }
        }
    }
    if {$targets eq "" && $bodies eq ""} { return $hir }

    set root [dict get $hir scopes [dict get $hir top] parent]
    set oldRoots [dict get $hir roots]
    set moved {}
    set roots {}
    set nextFile 1
    foreach f [dict keys [dict get $hir files]] {
        if {[regexp {^f([0-9]+)$} $f -> n]} { set nextFile [expr {max($nextFile, $n + 1)}] }
    }
    set loaded [surface::modules::LoadNamespaces [lsort -unique $namespaces] -start-file $nextFile]
    set types [hir::sourcetypes::apply [dict get $loaded typeDecls]]
    set errors [hir::errordecls::apply [dict get $loaded errorDecls]]
    set sourceTypes [hir::sourceTypes $hir]
    foreach type $types { if {$type ni $sourceTypes} { lappend sourceTypes $type } }
    dict set hir sourceTypes $sourceTypes
    dict set hir errorDecls [lsort -unique [concat [hir::errorDecls $hir] $errors]]
    dict for {f path} [dict get $loaded files] {
        dict set hir files $f [dict create id $f path $path]
    }

    # Resolution expects the as-written names in namespace scopes. Restore
    # them temporarily, then run ordinary hygiene once after adding sections.
    if {[dict exists $hir modules]} {
        dict for {ns scope} [dict get $hir modules] {
            foreach b [dict get $hir scopes $scope bindings] {
                set name [dict get $hir bindings $b name]
                hir::hygiene::RenameTo hir $b [string range $name [string length ${ns}::] end]
            }
        }
    }
    dict set hir bound {}
    foreach section [dict get $loaded sections] {
        set ns [dict get $section namespace]
        if {[dict exists $hir modules $ns]} {
            # Keep existing dependencies ahead of new module initialization.
            foreach e $oldRoots {
                if {[hir::get $hir $e scope] eq [dict get $hir modules $ns]} {
                    lappend roots $e
                    lappend moved $e
                }
            }
        } else {
            lappend roots {*}[hir::resolve::ProgramSection hir $root $ns \
                [dict get $section nodes] [dict get $section origin]]
        }
    }
    dict for {e body} $bodies {
        set syntax [hir::syntax::fromIR $body {}]
        dict set syntax origin [hir::get $hir $e origin]
        set ctx [dict create scope $root callable "" loop "" blocks {} errors {}]
        set callee [hir::resolve::Expr hir $syntax $ctx]
        dict set hir exprs $e callee $callee
    }
    dict unset hir bound
    dict set hir roots [concat $roots [lmap e $oldRoots {if {$e in $moved} continue; set e}]]
    hir::hygiene::apply hir
    set prior [expr {[dict exists $hir moduleNativeTargets] ? [dict get $hir moduleNativeTargets] : {}}]
    set triples {}
    dict for {name module} $targets { lappend triples $name {*}$module }
    hir::ResolveModuleNativeTargets hir $triples
    if {$prior ne ""} {
        dict set hir moduleNativeTargets [dict merge $prior [dict get $hir moduleNativeTargets]]
    }
    dict for {e type} $overrides { dict set hir exprs $e nativeResultOverride $type }
    hir::types::infer hir
    hir::range::verifyDeclaredResults hir
    hir::range::verifyDeclaredParams hir
    hir::callables::verify hir
    hir::errorsets::verify hir
    hir::modulebinding::validate hir
    return $hir
}
