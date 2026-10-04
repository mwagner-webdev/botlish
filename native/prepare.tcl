# native::prepareHir -- native implementations attached to resolved HIR.
#
# The one place native compilation touches HIR before lowering. A program that
# calls a native carrying a -module-fn (currently uriEscape, whose executable
# implementation is the ordinary Botlish function web::uri_escape_text) or a
# -native-body (a validator predicate such as emailish?) needs that
# implementation in the program: the owning module sections are loaded and
# resolved on top of the given HIR, each such call gets its callee (a body) or
# its reference a target (a module function) by *resolved binding identity*
# and the result type the native itself declares (nativeResultOverride), and
# the HIR is checked again (hir::check) because it gained code.
#
# It also makes a -strict 0 HIR safe to compile: a declared parameter type the
# program's own call cannot prove (`violatedDeclared`, recorded by
# hir::range::VerifyCall) must not be assumed by the callee's native code, so
# the declaration is dropped and the HIR re-checked -- the callee then guards
# what its own body needs and the call fails at run time as it does in the
# interpreter (this is hir::check's recovery for inferred contracts, applied
# to declared ones for native only; the relift used to hide the case because
# core IR has no declared types). A strict HIR never has such a violation.
#
# Input: program-mode HIR as a front end built it (analyzed). Output: the same
# HIR when nothing needs preparing (no work, no re-analysis); otherwise HIR
# with the implementations attached / the contracts recovered, analyzed again.
# It is idempotent, keeps source locations, declared contracts, module
# identities and lexical shadowing, and is shared by every native entry point
# (native::lowered calls it). It replaced the old raw-IR bridge
# (ExpandNativeBodies/ModuleNativeBridge over Core IR text, name-based and
# pre-resolution), which is gone (DIRECT-HIR-NATIVE-PATH.md).
proc native::prepareHir {hir} {
    return [RecoverDeclaredContracts [AttachNatives $hir]]
}

# native::prepareHir's second step: see its header.
proc native::RecoverDeclaredContracts {hir} {
    if {![dict exists $hir violatedDeclared]} {
        return $hir
    }
    set demote [dict keys [dict get $hir violatedDeclared]]
    set diagnostics [dict get $hir diagnostics]
    dict unset hir violatedDeclared
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![dict exists $node declaredParamTypes]} continue
        set declared [dict get $node declaredParamTypes]
        set changed 0
        set index 0
        foreach b [dict get $node params] {
            if {$b in $demote && [lindex $declared $index] ne {}} {
                lset declared $index {}
                set changed 1
            }
            incr index
        }
        if {$changed} { dict set hir exprs $e declaredParamTypes $declared }
    }
    hir::check hir
    # The violations stay diagnosed (a -strict 0 HIR keeps them); the re-check
    # sees no declared type to break.
    dict set hir diagnostics $diagnostics
    dict unset hir violatedDeclared
    return $hir
}

# native::prepareHir's first step: attaches the native implementations.
proc native::AttachNatives {hir} {
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
            # Every call of such a native gets its body, including one HIR
            # already proved redundant (`known`): giving the *other* calls a
            # body block changes what the re-check can prove (a validator
            # call is a refinement source only while its callee is the
            # native), so a call left native could lose its `known` fact and
            # then have no implementation at all.
            if {[dict get $meta nativeBody] ne ""} {
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
    # The newly loaded modules' own import environments join the program's
    # (hir/imports.tcl), for their method calls and type names.
    hir::imports::apply [dict merge [hir::imports::current] [dict get $loaded imports]]
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
    # The resolver's diagnostic-only index of later bindings (hir/resolve.tcl)
    # is dropped when a resolution finishes, exactly as hir::resolve::program
    # does.
    dict unset hir laterIndex
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
    hir::check hir
    return $hir
}
