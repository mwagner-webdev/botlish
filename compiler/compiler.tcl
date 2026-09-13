# compiler.tcl -- compiles core IR to Tcl procedures.
#
#   source compiler/compiler.tcl       ;# also loads core
#   core::useBackend compile
#
# The compiler is a second implementation of the same semantics as the
# interpreter in core/evaluator.tcl. It shares the runtime (values, natives,
# environments, call boundary) but none of the interpreter's evaluation
# machinery.
#
# Translation scheme
# ------------------
# * A compilation unit (the expressions given to evalProgram or evalIn) becomes
#   a Tcl proc taking the environment it runs in: `proc unitN {base} {...}`.
# * Each block node becomes a Tcl proc `proc blockN {captured argv} {...}`;
#   the Block value carries its name as CODE (see core/block.tcl).
# * if branches and loop bodies are inline, so they compile into the same
#   proc as Tcl `if` and `while 1`.
# * Expressions are flattened into sequential Tcl commands in evaluation
#   order; each intermediate result is held in a temporary `tN`.
# * Control flow uses Tcl completion codes:
#     break / continue   -> Tcl `break` / `continue` inside a compiled loop of
#                           the same proc; otherwise `return -code break|continue`
#                           (rejected by the call or program boundary)
#     return             -> Tcl `return` in a block proc; `return -code return`
#                           at unit level (rejected by the program boundary)
#   Break values are stored in the loop's result temporary before `break`.
#
# Name resolution and storage
# ---------------------------
# Every name is resolved statically to its scope. A scope is *materialized*
# as a runtime environment frame iff it contains a block node: only then can
# a closure capture it, and only then can its bindings or refinements be
# observed (core::blockEnv). Such scopes declare their names on entry and read
# and write through core::env, which checks use-before-binding at run time.
#
# Scopes without a block node never escape their proc, so their bindings are
# plain Tcl local variables `vN`. Evaluation order within them is exactly the
# textual order the compiler walks, so use-before-binding and duplicate
# bindings are decided statically and compiled into the corresponding error.
#
# The unit's own top scope is the environment it is run in; names not bound
# by any nested scope are looked up there dynamically (this is how root
# natives and program-level bindings are reached).
#
# Refinements are only observable through materialized scopes, so a branch
# installs them only when it is materialized, using the same metadata rules
# as the interpreter (core::refine::factsFromCall).

source [file join [file dirname [file dirname [file normalize [info script]]]] core core.tcl]

namespace eval core::compiler {
    variable nextId 0
    # EXPRS -> dict {name UNIT-PROC source SOURCE}
    variable cache [dict create]
    # Proc sources generated for the unit being compiled.
    variable pending {}
}

namespace eval core::compiler::code {}

# ---------------------------------------------------------------------------
# Backend entry points

# Runs EXPRS in the existing environment ENV. Returns a completion.
proc core::compiler::runSequence {exprs env} {
    set unit [compileUnit $exprs]
    set status [catch {$unit $env} result options]
    return [core::completion::fromTclCode $status $result $options]
}

# Compiles EXPRS (once) and returns the name of the unit proc.
proc core::compiler::compileUnit {exprs} {
    variable cache
    if {![dict exists $cache $exprs]} {
        lassign [GenerateUnit $exprs] name code
        # The procs are defined only after the whole unit compiled cleanly.
        namespace eval ::core::compiler::code $code
        dict set cache $exprs [dict create name ::core::compiler::code::$name code $code]
    }
    return [dict get $cache $exprs name]
}

# The generated Tcl code for EXPRS, for inspection.
proc core::compiler::generatedCode {exprs} {
    variable cache
    compileUnit $exprs
    return [dict get $cache $exprs code]
}

# ---------------------------------------------------------------------------
# Compilation context
#
# A context describes the proc being generated:
#   lines    generated commands
#   indent   current indentation depth
#   scopes   SCOPE-ID -> scope dict
#   order    scope ids, outermost first
#   loops    result temporaries of the enclosing compiled loops, innermost last
#   inBlock  1 inside a block proc, 0 at unit level
#
# A scope dict:
#   kind          top | local
#   materialized  1 if the scope is a runtime frame
#   frame         Tcl variable holding the frame (materialized scopes)
#   names         names bound in the scope (locals only)
#   locals        NAME -> Tcl variable (non-materialized scopes)
#   init          names whose bind has completed (non-materialized scopes)

proc core::compiler::NewId {} {
    variable nextId
    return [incr nextId]
}

proc core::compiler::NewContext {inBlock} {
    return [dict create lines {} indent 1 scopes {} order {} loops {} inBlock $inBlock]
}

proc core::compiler::Emit {ctxVar line} {
    upvar 1 $ctxVar ctx
    dict lappend ctx lines "[string repeat {    } [dict get $ctx indent]]$line"
}

proc core::compiler::Indent {ctxVar delta} {
    upvar 1 $ctxVar ctx
    dict incr ctx indent $delta
}

proc core::compiler::NewTemp {} {
    return t[NewId]
}

# A literal Tcl word denoting VALUE.
proc core::compiler::Word {value} {
    return [list $value]
}

proc core::compiler::FrameVar {scopeId} {
    if {$scopeId eq "top"} {
        return base
    }
    return f$scopeId
}

proc core::compiler::PushScope {ctxVar scopeId scope} {
    upvar 1 $ctxVar ctx
    dict set ctx scopes $scopeId $scope
    dict lappend ctx order $scopeId
}

proc core::compiler::PopScope {ctxVar} {
    upvar 1 $ctxVar ctx
    set order [dict get $ctx order]
    dict unset ctx scopes [lindex $order end]
    dict set ctx order [lrange $order 0 end-1]
}

proc core::compiler::InnermostScopeId {ctx} {
    return [lindex [dict get $ctx order] end]
}

# Opens a local scope for EXPRS (extra names, e.g. parameters, in EXTRA).
# Emits frame creation under PARENT-FRAME-EXPR when the scope is materialized.
# Returns the scope id.
proc core::compiler::OpenScope {ctxVar exprs parentFrameExpr {extraNames {}}} {
    upvar 1 $ctxVar ctx
    set id [NewId]
    set bodyNames [core::ir::scopeBindNames $exprs]
    set names $extraNames
    foreach name $bodyNames {
        if {$name ni $names} {
            lappend names $name
        }
    }
    set materialized [core::ir::containsBlock $exprs]
    set frame [FrameVar $id]
    if {$materialized} {
        Emit ctx "set $frame \[core::env::child $parentFrameExpr\]"
    }
    PushScope ctx $id [dict create kind local materialized $materialized \
        frame $frame names $names locals {} init {}]
    return $id
}

proc core::compiler::DeclareScope {ctxVar id exprs} {
    upvar 1 $ctxVar ctx
    if {[dict get $ctx scopes $id materialized]} {
        set names [core::ir::scopeBindNames $exprs]
        if {$names ne ""} {
            Emit ctx "core::env::declare \$[FrameVar $id] [Word $names]"
        }
    }
}

# Tcl expression for the frame of the innermost materialized scope.
proc core::compiler::CurrentFrameExpr {ctx} {
    foreach id [lreverse [dict get $ctx order]] {
        if {[dict get $ctx scopes $id materialized]} {
            return "\$[FrameVar $id]"
        }
    }
    error "core::compiler: no materialized scope"
}

# ---------------------------------------------------------------------------
# Units and blocks

# Returns {UNIT-PROC-NAME CODE}; CODE defines the unit proc and its block procs.
proc core::compiler::GenerateUnit {exprs} {
    variable pending
    set pending {}
    set ctx [NewContext 0]
    PushScope ctx top [dict create kind top materialized 1 frame base]
    set result [CompileSequence ctx $exprs]
    Emit ctx "return $result"
    set name unit[NewId]
    lappend pending [ProcSource $name {base} $ctx]
    return [list $name [join $pending \n\n]]
}

proc core::compiler::ProcSource {name params ctx} {
    return "proc $name [list $params] {\n[join [dict get $ctx lines] \n]\n}"
}

proc core::compiler::CompileBlock {ctxVar node} {
    upvar 1 $ctxVar outer
    variable pending
    set params [core::ir::blockParams $node]
    set body [core::ir::blockBody $node]
    set name block[NewId]

    set ctx [NewContext 1]
    # Enclosing scopes are all materialized (each contains this block node).
    # Rebuild their frame variables from the captured frame's parent chain.
    set previous ""
    foreach id [lreverse [dict get $outer order]] {
        set frame [FrameVar $id]
        if {$previous eq ""} {
            Emit ctx "set $frame \$captured"
        } else {
            Emit ctx "set $frame \[core::env::parent \$$previous\]"
        }
        set previous $frame
    }
    foreach id [dict get $outer order] {
        PushScope ctx $id [dict get $outer scopes $id]
    }

    set scopeId [OpenScope ctx $body {$captured} $params]
    set frame [FrameVar $scopeId]
    set index 0
    foreach param $params {
        if {[dict get $ctx scopes $scopeId materialized]} {
            Emit ctx "core::env::define \$$frame [Word $param] \[lindex \$argv $index\]"
        } else {
            set var v[NewId]
            Emit ctx "set $var \[lindex \$argv $index\]"
            dict set ctx scopes $scopeId locals $param $var
            dict set ctx scopes $scopeId init [concat [dict get $ctx scopes $scopeId init] [list $param]]
        }
        incr index
    }
    DeclareScope ctx $scopeId $body
    set result [CompileSequence ctx $body]
    Emit ctx "return $result"
    lappend pending [ProcSource $name {captured argv} $ctx]

    set t [NewTemp]
    Emit outer "set $t \[core::value::block [Word $params] [Word $body] [CurrentFrameExpr $outer] [Word ::core::compiler::code::$name]\]"
    return "\$$t"
}

# ---------------------------------------------------------------------------
# Expressions
#
# Each Compile* procedure emits the commands that evaluate a node and returns
# an operand: a Tcl word (a variable reference or a literal) for its value.

proc core::compiler::CompileSequence {ctxVar exprs} {
    upvar 1 $ctxVar ctx
    set result [Word [core::value::unit]]
    foreach expr $exprs {
        set result [CompileExpr ctx $expr]
    }
    return $result
}

proc core::compiler::CompileExpr {ctxVar node} {
    upvar 1 $ctxVar ctx
    core::ir::checkShape $node
    switch -- [core::ir::op $node] {
        const {
            return [Word [core::ir::literalValue $node]]
        }
        ref {
            return [CompileRef ctx [lindex $node 1]]
        }
        bind {
            return [CompileBind ctx [lindex $node 1] [lindex $node 2]]
        }
        block {
            return [CompileBlock ctx $node]
        }
        call {
            return [CompileCall ctx $node]
        }
        if {
            return [CompileIf ctx $node]
        }
        loop {
            return [CompileLoop ctx $node]
        }
        return {
            set value [CompileExpr ctx [lindex $node 1]]
            if {[dict get $ctx inBlock]} {
                Emit ctx "return $value"
            } else {
                Emit ctx "return -code return $value"
            }
            return [Word [core::value::unit]]
        }
        break {
            set value [Word [core::value::unit]]
            if {[llength $node] == 2} {
                set value [CompileExpr ctx [lindex $node 1]]
            }
            set loops [dict get $ctx loops]
            if {$loops ne ""} {
                Emit ctx "set [lindex $loops end] $value"
                Emit ctx "break"
            } else {
                Emit ctx "return -code break $value"
            }
            return [Word [core::value::unit]]
        }
        continue {
            if {[dict get $ctx loops] ne ""} {
                Emit ctx "continue"
            } else {
                Emit ctx "return -code continue"
            }
            return [Word [core::value::unit]]
        }
        ok - error-value {
            set value [CompileExpr ctx [lindex $node 1]]
            set constructor [expr {[core::ir::op $node] eq "ok" ? "ok" : "err"}]
            set t [NewTemp]
            Emit ctx "set $t \[core::value::$constructor $value\]"
            return "\$$t"
        }
    }
}

proc core::compiler::CompileRef {ctxVar name} {
    upvar 1 $ctxVar ctx
    set t [NewTemp]
    foreach id [lreverse [dict get $ctx order]] {
        set scope [dict get $ctx scopes $id]
        if {[dict get $scope kind] eq "top"} {
            Emit ctx "set $t \[core::env::lookup \$[dict get $scope frame] [Word $name]\]"
            return "\$$t"
        }
        if {$name ni [dict get $scope names]} {
            continue
        }
        if {[dict get $scope materialized]} {
            Emit ctx "set $t \[core::env::lookupLocal \$[dict get $scope frame] [Word $name]\]"
            return "\$$t"
        }
        if {$name in [dict get $scope init]} {
            return "\$[dict get $scope locals $name]"
        }
        Emit ctx "core::env::usedBeforeBinding [Word $name]"
        return [Word [core::value::unit]]
    }
    error "core::compiler: no top scope"
}

proc core::compiler::CompileBind {ctxVar name valueNode} {
    upvar 1 $ctxVar ctx
    set value [CompileExpr ctx $valueNode]
    set id [InnermostScopeId $ctx]
    set scope [dict get $ctx scopes $id]
    if {[dict get $scope materialized]} {
        Emit ctx "core::env::define \$[dict get $scope frame] [Word $name] $value"
    } elseif {$name in [dict get $scope init]} {
        Emit ctx "core::env::duplicateBinding [Word $name]"
    } else {
        set var v[NewId]
        Emit ctx "set $var $value"
        dict set ctx scopes $id locals $name $var
        dict set ctx scopes $id init [concat [dict get $scope init] [list $name]]
    }
    return $value
}

# CALLEE-VAR, if given, receives the callee's operand.
proc core::compiler::CompileCall {ctxVar node {calleeVar ""}} {
    upvar 1 $ctxVar ctx
    if {$calleeVar ne ""} {
        upvar 1 $calleeVar callee
    }
    set callee [CompileExpr ctx [lindex $node 1]]
    set args {}
    foreach argNode [lrange $node 2 end] {
        lappend args [CompileExpr ctx $argNode]
    }
    set t [NewTemp]
    Emit ctx "set $t \[core::runtime::callValue $callee \[list [join $args { }]\]\]"
    return "\$$t"
}

proc core::compiler::CompileIf {ctxVar node} {
    upvar 1 $ctxVar ctx
    set condition [lindex $node 1]
    set refining [core::refine::isRefiningCondition $condition]
    if {$refining} {
        set test [CompileCall ctx $condition callee]
    } else {
        set test [CompileExpr ctx $condition]
    }
    set outcome [NewTemp]
    set result [NewTemp]
    set parentFrame [CurrentFrameExpr $ctx]
    Emit ctx "set $outcome \[core::runtime::conditionOutcome $test\]"
    Emit ctx "if {\$$outcome} \{"
    foreach branchIndex {2 3} branchOutcome {1 0} {
        if {$branchOutcome == 0} {
            Emit ctx "\} else \{"
        }
        Indent ctx 1
        set body [core::ir::blockBody [lindex $node $branchIndex]]
        set id [OpenScope ctx $body $parentFrame]
        DeclareScope ctx $id $body
        if {$refining && [dict get $ctx scopes $id materialized]} {
            set argNodes [lrange $condition 2 end]
            Emit ctx "core::refine::install \$[FrameVar $id] \[core::refine::factsFromCall $callee [Word $argNodes] $parentFrame $branchOutcome\]"
        }
        set value [CompileSequence ctx $body]
        Emit ctx "set $result $value"
        PopScope ctx
        Indent ctx -1
    }
    Emit ctx "\}"
    return "\$$result"
}

proc core::compiler::CompileLoop {ctxVar node} {
    upvar 1 $ctxVar ctx
    set body [core::ir::blockBody [lindex $node 1]]
    set result [NewTemp]
    set parentFrame [CurrentFrameExpr $ctx]
    Emit ctx "while 1 \{"
    Indent ctx 1
    set id [OpenScope ctx $body $parentFrame]
    DeclareScope ctx $id $body
    dict lappend ctx loops $result
    CompileSequence ctx $body
    dict set ctx loops [lrange [dict get $ctx loops] 0 end-1]
    PopScope ctx
    Indent ctx -1
    Emit ctx "\}"
    return "\$$result"
}

core::registerBackend compile core::compiler::runSequence
