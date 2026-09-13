# compiler.tcl -- compiles HIR to Tcl procedures.
#
#   source compiler/compiler.tcl       ;# also loads core and hir
#   core::useBackend compile
#
# The compiler is a second implementation of the same semantics as the
# interpreter in core/evaluator.tcl. It shares the runtime (values, natives,
# environments, call boundary) but none of the interpreter's evaluation
# machinery.
#
# It does no semantic analysis of its own. Each unit is first built into HIR
# (hir/), which owns
#
#   lexical resolution and binding identity   (which binding a name denotes,
#                                             whether it is bound yet,
#                                             duplicate binds)
#   static types, flow facts, refinements     (the type of every expression)
#   captures and closures of scopes
#   known call targets                        ({native SYMBOL} / {block EXPR})
#   statically decided type tests
#   control targets of return/break/continue
#
# and the compiler decides only how to run it in Tcl:
#
#   frames        which scopes become runtime frames, Tcl variables for the rest
#   representation  boxed values or bare integers/Booleans
#   intrinsics    inline Tcl for known natives, kind checks, constant folding
#   calls         direct proc calls for known blocks, the generic call boundary
#   control flow  Tcl completion codes
#
# Translation scheme
# ------------------
# * A compilation unit becomes a Tcl proc taking the environment it runs in:
#   `proc unitN {base} {...}`. A unit is compiled in one of two modes:
#     sequence  run in an arbitrary environment (core::evalIn)
#     program   run as a checked program in a fresh program scope over a
#               fresh root (core::evalProgram); root bindings are then known
#               constants and program-level bindings are statically typed
# * Each block expression becomes `proc blockN {captured argv} {...}`; the
#   Block value carries its name as CODE (see core/block.tcl).
# * if branches and loop bodies are inline: Tcl `if` and `while 1`.
# * Expressions become sequential Tcl commands in evaluation order.
# * Control flow uses Tcl completion codes:
#     break / continue   -> Tcl `break` / `continue` inside a compiled loop of
#                           the same proc; otherwise `return -code break|continue`
#                           (rejected by the call or program boundary)
#     return             -> Tcl `return` in a block proc; `return -code return`
#                           at unit level (rejected by the program boundary)
#
# Operands and representations
# ----------------------------
# Compiling an expression yields an *operand* {REPR WORD TYPE}:
#   REPR  box   WORD evaluates to a runtime value ({int 5}, {str a}, ...)
#         int   WORD evaluates to a bare canonical integer
#         bool  WORD evaluates to 1 or 0
#   TYPE  its static type: the HIR type of the expression, or never when the
#         compiler found that evaluation cannot complete normally
# Unboxed representations never escape: values are boxed whenever they are
# stored in a frame, passed to a call, returned or broken out of a loop.
#
# Storage
# -------
# A scope is *materialized* as a runtime frame iff a block is created in it
# (HIR scope closures): only then can a closure capture it or its bindings or
# refinements be observed. Such scopes declare their names on entry and access
# them through core::env (run-time use-before-binding checks). Other scopes
# keep bindings in Tcl variables (or propagate them as constants).
#
# Type-directed code
# ------------------
# * Calls of known natives with an intrinsic (+ - * < <= > >= == eq list
#   ok? error?) compile to inline Tcl. Arguments not statically of the
#   required kind are first checked with core::value::expect, which raises
#   exactly the error the native would.
# * Type tests decided by HIR fold to constants; other type tests compile to
#   inline membership checks. An if with a constant condition compiles only
#   the branch that runs.
# * In program mode, calls whose HIR target is a block of matching arity call
#   its proc directly. (Checked programs cannot produce escaping break/continue
#   codes, so the generic boundary would be a no-op.)

source [file join [file dirname [file dirname [file normalize [info script]]]] hir hir.tcl]

namespace eval core::compiler {
    variable nextId 0
    # {MODE EXPRS} -> dict {name UNIT-PROC code CODE types PROGRAM-TYPES
    #                       bindings BINDINGS hir HIR}
    variable cache [dict create]
    # State of the unit being compiled.
    variable hir {}
    variable pending {}
    variable bindLog {}
    # Block ExprId -> proc name.
    variable blockProcs [dict create]
    # Program mode: block ExprIds whose procs never touch their captured
    # environment (EnvlessBlocks), and calls compiled as loops
    # (SelfTailCalls).
    variable envless {}
    variable selfTailCalls {}
    # If conditions whose callee value CompileIf needs (InstallsRefinements).
    variable refining {}
    # Native name -> intrinsic generator.
    variable intrinsics [dict create \
        +        {IntrinsicArith +} \
        -        {IntrinsicArith -} \
        *        {IntrinsicArith *} \
        <        {IntrinsicCompare <} \
        <=       {IntrinsicCompare <=} \
        >        {IntrinsicCompare >} \
        >=       {IntrinsicCompare >=} \
        ==       IntrinsicValueEqual \
        eq       IntrinsicStringEqual \
        list     IntrinsicList \
        ok?      {IntrinsicResultIs ok} \
        error?   {IntrinsicResultIs error}]
}

namespace eval core::compiler::code {}

# ---------------------------------------------------------------------------
# Backend entry points

# Runs EXPRS in the existing environment ENV. Returns a completion.
proc core::compiler::runSequence {exprs env} {
    return [Run [compileUnit sequence $exprs] $env]
}

# Runs checked EXPRS as a program in the fresh program scope ENV.
proc core::compiler::runProgram {exprs env} {
    return [Run [compileUnit program $exprs] $env]
}

proc core::compiler::Run {unit env} {
    set status [catch {$unit $env} result options]
    return [core::completion::fromTclCode $status $result $options]
}

# Compiles EXPRS (once per mode) and returns the name of the unit proc.
proc core::compiler::compileUnit {mode exprs} {
    variable cache
    set key [list $mode $exprs]
    if {![dict exists $cache $key]} {
        set unit [GenerateUnit $mode $exprs]
        # The procs are defined only after the whole unit compiled cleanly.
        namespace eval ::core::compiler::code [dict get $unit code]
        dict set unit name ::core::compiler::code::[dict get $unit name]
        dict set cache $key $unit
    }
    return [dict get $cache $key name]
}

proc core::compiler::Cached {mode exprs field} {
    variable cache
    compileUnit $mode $exprs
    return [dict get $cache [list $mode $exprs] $field]
}

# Compiles and runs the program-mode HIR program HIR as a checked program,
# as core::evalProgram does for its lowered IR. Returns the value. The HIR is
# trusted: it may come from hir::parse rather than hir::build.
proc core::compiler::evalHir {hir} {
    if {[hir::mode $hir] ne "program"} {
        error "core::compiler::evalHir: expected a program-mode HIR"
    }
    set exprs [hir::lower $hir]
    foreach expr $exprs {
        core::ir::check $expr
    }
    set unit [GenerateUnit program $exprs $hir]
    namespace eval ::core::compiler::code [dict get $unit code]
    set names {}
    foreach b [dict get $hir scopes [hir::top $hir] bindings] {
        if {[dict get $hir bindings $b kind] eq "local"} {
            lappend names [dict get $hir bindings $b name]
        }
    }
    set mark [core::env::mark]
    set env [core::env::child [core::rootEnv]]
    core::env::declare $env $names
    set value ""
    try {
        set completion [Run ::core::compiler::code::[dict get $unit name] $env]
        set value [core::completion::atProgramBoundary $completion]
    } finally {
        core::releaseProgram $mark $value
    }
    return $value
}

# The generated Tcl code for EXPRS, for inspection.
proc core::compiler::generatedCode {exprs {mode program}} {
    return [Cached $mode $exprs code]
}

# The HIR the unit for EXPRS was compiled from.
proc core::compiler::unitHir {exprs {mode program}} {
    return [Cached $mode $exprs hir]
}

# Inferred static types of the program-level bindings of EXPRS: NAME -> TYPE.
proc core::compiler::programTypes {exprs} {
    return [Cached program $exprs types]
}

# Every binding compiled for the program EXPRS, at any depth, with its
# inferred static type: a list of {NAME TYPE} in compilation order. Types
# include branch refinements and flow facts known where the bind occurs.
proc core::compiler::bindingTypes {exprs} {
    return [Cached program $exprs bindings]
}

# ---------------------------------------------------------------------------
# HIR access (the unit being compiled)

proc core::compiler::N {e key} {
    variable hir
    return [dict get $hir exprs $e $key]
}

proc core::compiler::Kind {e} {
    variable hir
    return [dict get $hir exprs $e kind]
}

proc core::compiler::Type {e} {
    variable hir
    return [hir::typeOf $hir $e]
}

proc core::compiler::B {b key} {
    variable hir
    return [dict get $hir bindings $b $key]
}

proc core::compiler::S {s key} {
    variable hir
    return [dict get $hir scopes $s $key]
}

proc core::compiler::Lower {e} {
    variable hir
    return [hir::lower::expr $hir $e]
}

# The proc a block expression compiles to.
proc core::compiler::BlockProc {e} {
    variable blockProcs
    if {![dict exists $blockProcs $e]} {
        dict set blockProcs $e ::core::compiler::code::block[NewId]
    }
    return [dict get $blockProcs $e]
}

# ---------------------------------------------------------------------------
# Unit facts (program mode), derived from HIR; they decide representation
# only.
#
# Envless blocks. A call whose HIR target is block T, through a `ref` callee,
# needs the callee value only for T's captured environment: HIR resolved the
# target, and a reference whose type names the block is bound whenever it
# runs (its bind preceded, on every path, the code that typed it). If T's
# proc never reads its environment, the call can skip the lookup and pass no
# environment. A block is envless when
#   * it creates no closures in its own invocation (no materialized scope
#     of its own, no frames to link), and
#   * every reference in its invocation to a binding from outside it is the
#     callee of such a call of an envless block of matching arity.
# Computed as a greatest fixpoint, so self and mutual recursion qualify.
# Block values are still created with their environment: generic calls,
# core::blockEnv and refinement probes see exactly what they saw before.

proc core::compiler::EnvlessBlocks {} {
    variable hir
    set blocks {}
    set callOf [dict create]
    set regionRefs [dict create]
    foreach e [hir::walk $hir] {
        switch -- [Kind $e] {
            block {
                lappend blocks $e
                dict set regionRefs $e {}
            }
            call {
                dict set callOf [N $e callee] $e
            }
        }
    }
    set disqualified {}
    foreach e [hir::walk $hir] {
        set invocation [S [N $e scope] invocation]
        if {$invocation eq ""} {
            continue
        }
        if {[Kind $e] eq "block"} {
            lappend disqualified $invocation
        } elseif {[Kind $e] eq "ref"} {
            set b [N $e binding]
            if {$b eq ""} {
                # An unbound name is looked up (and fails) at run time.
                lappend disqualified $invocation
            } elseif {[B $b kind] ne "root" && [S [B $b scope] invocation] ne $invocation} {
                dict lappend regionRefs $invocation $e
            }
        }
    }
    set envless $blocks
    foreach e [lsort -unique $disqualified] {
        set envless [lsearch -all -inline -exact -not $envless $e]
    }
    set changed 1
    while {$changed} {
        set changed 0
        foreach e $envless {
            foreach ref [dict get $regionRefs $e] {
                if {![SkippableCallee $ref $callOf $envless]} {
                    set envless [lsearch -all -inline -exact -not $envless $e]
                    set changed 1
                    break
                }
            }
        }
    }
    return $envless
}

# 1 if REF is the callee of a call to an envless block of matching arity.
proc core::compiler::SkippableCallee {ref callOf envless} {
    if {![dict exists $callOf $ref]} {
        return 0
    }
    return [expr {[DirectEnvlessTarget [dict get $callOf $ref] $envless] ne ""}]
}

# The envless block call E directly calls through a `ref` callee, or "".
proc core::compiler::DirectEnvlessTarget {e envless} {
    lassign [N $e target] kind target
    if {$kind ne "block" || $target ni $envless || [Kind [N $e callee]] ne "ref"
            || [InstallsRefinements $e]
            || [llength [N $target params]] != [llength [N $e args]]} {
        return ""
    }
    return $target
}

# 1 if call E is the condition of an if with a materialized branch, where
# CompileIf installs refinements using the callee value.
proc core::compiler::InstallsRefinements {e} {
    variable refining
    return [dict exists $refining $e]
}

# Call ExprId -> 1 for InstallsRefinements.
proc core::compiler::RefiningConditions {} {
    variable hir
    set result [dict create]
    foreach e [hir::walk $hir] {
        if {[Kind $e] eq "if" && [Kind [N $e condition]] eq "call"
                && ([S [N $e thenScope] closures] ne "" || [S [N $e elseScope] closures] ne "")} {
            dict set result [N $e condition] 1
        }
    }
    return $result
}

# Self tail calls: calls whose HIR target is the block they occur in, with
# matching arity, in tail position of that block (its body's value or a
# return's value, through if branches), and not inside a loop of that block.
# Such a call is the last thing its invocation does, so its proc rebinds
# the parameters and starts over instead of nesting a Tcl call.
proc core::compiler::SelfTailCalls {} {
    variable hir
    set result {}
    foreach e [hir::walk $hir] {
        switch -- [Kind $e] {
            block {
                if {[N $e body] ne ""} {
                    TailCallsInto [lindex [N $e body] end] $e result
                }
            }
            return {
                if {[N $e target] ne ""} {
                    TailCallsInto [N $e value] [N $e target] result
                }
            }
        }
    }
    return $result
}

proc core::compiler::TailCallsInto {e block resultVar} {
    upvar 1 $resultVar result
    switch -- [Kind $e] {
        call {
            lassign [N $e target] kind target
            if {$kind eq "block" && $target eq $block
                    && [llength [N $block params]] == [llength [N $e args]]
                    && ![InLoopOf $e $block]} {
                lappend result $e
            }
        }
        if {
            foreach role {thenBody elseBody} {
                if {[N $e $role] ne ""} {
                    TailCallsInto [lindex [N $e $role] end] $block result
                }
            }
        }
    }
}

# 1 if expression E is inside a loop body within block BLOCK's invocation.
proc core::compiler::InLoopOf {e block} {
    for {set s [N $e scope]} {$s ne "" && [S $s owner] ne $block} {set s [S $s parent]} {
        if {[S $s kind] eq "loop"} {
            return 1
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Compilation context
#
# A context describes the proc being generated:
#   lines        generated commands
#   indent       current indentation depth
#   scopes       ScopeId -> compiler scope
#   order        ScopeIds, outermost first
#   loops        loop ExprId -> result variable, for loops compiled in this proc
#   inBlock      1 inside a block proc, 0 at unit level
#   program      1 when compiling in program mode
#
# A compiler scope (how a HIR scope is stored):
#   materialized  1 if the scope is a runtime frame
#   frame         Tcl variable holding the frame (materialized scopes)
#   locals        BindingId -> {REPR WORD} (non-materialized scopes)

proc core::compiler::NewId {} {
    variable nextId
    return [incr nextId]
}

proc core::compiler::NewContext {inBlock program} {
    return [dict create lines {} indent 1 scopes {} order {} loops {} \
        inBlock $inBlock program $program]
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

# A literal Tcl word denoting the string VALUE.
proc core::compiler::Word {value} {
    return [list $value]
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

# Opens the HIR scope SCOPE-ID. Emits frame creation under PARENT-FRAME-EXPR
# when the scope is materialized.
proc core::compiler::OpenScope {ctxVar scopeId parentFrameExpr} {
    upvar 1 $ctxVar ctx
    set materialized [expr {[S $scopeId closures] ne ""}]
    set frame f$scopeId
    if {$materialized} {
        Emit ctx "set $frame \[core::env::child $parentFrameExpr\]"
    }
    PushScope ctx $scopeId [dict create materialized $materialized frame $frame locals {}]
}

# Declares a materialized scope's local bindings in its frame.
proc core::compiler::DeclareScope {ctxVar scopeId} {
    upvar 1 $ctxVar ctx
    if {[dict get $ctx scopes $scopeId materialized]} {
        set names {}
        foreach b [S $scopeId bindings] {
            if {[B $b kind] eq "local"} {
                lappend names [B $b name]
            }
        }
        if {$names ne ""} {
            Emit ctx "core::env::declare \$[dict get $ctx scopes $scopeId frame] [Word $names]"
        }
    }
}

# Tcl expression for the frame of the innermost materialized scope.
proc core::compiler::CurrentFrameExpr {ctx} {
    foreach id [lreverse [dict get $ctx order]] {
        if {[dict get $ctx scopes $id materialized]} {
            return "\$[dict get $ctx scopes $id frame]"
        }
    }
    error "core::compiler: no materialized scope"
}

# ---------------------------------------------------------------------------
# Operands

proc core::compiler::Op {repr word type} {
    return [list $repr $word $type]
}

proc core::compiler::OpType {op} { return [lindex $op 2] }

proc core::compiler::Never {} {
    return [Op box unit never]
}

# True if WORD is a literal (not a variable or command substitution).
proc core::compiler::IsLiteral {word} {
    return [expr {[string index $word 0] ni {$ [}}]
}

# The literal string a literal WORD denotes.
proc core::compiler::LiteralValue {word} {
    return [lindex $word 0]
}

# A word evaluating to the operand as a runtime value.
proc core::compiler::BoxWord {op} {
    lassign $op repr word
    switch -- $repr {
        box {
            return $word
        }
        int {
            if {[IsLiteral $word]} {
                return [Word [list int [LiteralValue $word]]]
            }
            return "\[list int $word\]"
        }
        bool {
            if {[IsLiteral $word]} {
                return [Word [core::value::bool [LiteralValue $word]]]
            }
            return "\[expr {$word ? {bool true} : {bool false}}\]"
        }
    }
}

# A word evaluating to the bare integer of an operand of type int.
proc core::compiler::IntWord {op} {
    lassign $op repr word
    if {$repr eq "int"} {
        return $word
    }
    if {[IsLiteral $word]} {
        return [Word [lindex [LiteralValue $word] 1]]
    }
    return "\[lindex $word 1\]"
}

# A word evaluating to 1/0 for an operand of type bool.
proc core::compiler::BoolWord {op} {
    lassign $op repr word
    if {$repr eq "bool"} {
        return $word
    }
    if {[IsLiteral $word]} {
        return [core::value::isTrue [LiteralValue $word]]
    }
    return "\[string equal \[lindex $word 1\] true\]"
}

# A word for OP in representation REPR.
proc core::compiler::Coerce {op repr} {
    switch -- $repr {
        box  { return [BoxWord $op] }
        int  { return [IntWord $op] }
        bool { return [BoolWord $op] }
    }
}

# ---------------------------------------------------------------------------
# Units and blocks

# Returns the unit dict {name code types bindings hir}. UNIT-HIR is the HIR
# of EXPRS, built here if not given.
proc core::compiler::GenerateUnit {mode exprs {unitHir ""}} {
    variable hir
    variable pending
    variable bindLog
    variable blockProcs
    if {$unitHir eq ""} {
        set unitHir [hir::build $exprs -mode $mode -strict 0]
    }
    set hir $unitHir
    variable envless
    variable selfTailCalls
    variable refining
    set envless {}
    set selfTailCalls {}
    set refining [RefiningConditions]
    if {$mode eq "program"} {
        set envless [EnvlessBlocks]
        set selfTailCalls [SelfTailCalls]
    }
    set pending {}
    set bindLog {}
    set blockProcs [dict create]
    set ctx [NewContext 0 [expr {$mode eq "program"}]]
    PushScope ctx [hir::top $hir] [dict create materialized 1 frame base locals {}]
    set result [CompileSequence ctx [hir::roots $hir]]
    Emit ctx "return [BoxWord $result]"
    set name unit[NewId]
    lappend pending [ProcSource $name {base} $ctx]

    set types [dict create]
    if {$mode eq "program"} {
        foreach b [S [hir::top $hir] bindings] {
            set declaredBy [B $b declaredBy]
            if {$declaredBy ne "" && [N $declaredBy reachable] && [B $b type] ne ""} {
                dict set types [B $b name] [hir::bindingType $hir $b]
            }
        }
    }
    return [dict create name $name code [join $pending \n\n] types $types \
        bindings $bindLog hir $hir]
}

proc core::compiler::ProcSource {name params ctx} {
    return "proc $name [list $params] {\n[join [dict get $ctx lines] \n]\n}"
}

proc core::compiler::CompileBlock {ctxVar e} {
    upvar 1 $ctxVar outer
    variable pending
    set procName [BlockProc $e]
    lappend pending [CompileBlockBody outer $e $procName]
    variable hir
    set t [NewTemp]
    Emit outer "set $t \[core::value::block [Word [hir::lower::params $hir $e]] [Word [hir::lower::body $hir $e]] [CurrentFrameExpr $outer] [Word $procName]\]"
    return [Op box "\$$t" [Type $e]]
}

# Returns the proc source of block expression E.
proc core::compiler::CompileBlockBody {outerVar e procName} {
    upvar 1 $outerVar outer
    variable envless
    variable selfTailCalls
    set ctx [NewContext 1 [dict get $outer program]]
    dict set ctx block $e

    # A self tail call restarts the proc body with new arguments (and, for
    # a block that reads its environment, the callee's environment).
    set looping 0
    foreach call $selfTailCalls {
        if {[S [N $call scope] invocation] eq $e} {
            set looping 1
            break
        }
    }
    if {$looping} {
        Emit ctx "while 1 \{"
        Indent ctx 1
    }

    # Enclosing scopes are all materialized (a block is created in each).
    # Rebuild their frame variables from the captured frame's parent chain,
    # unless the block never reads them.
    set previous ""
    foreach id [lreverse [dict get $outer order]] {
        if {$e in $envless} {
            break
        }
        set frame [dict get $outer scopes $id frame]
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

    set scopeId [N $e bodyScope]
    OpenScope ctx $scopeId {$captured}
    set frame [dict get $ctx scopes $scopeId frame]
    set index 0
    foreach b [N $e params] {
        if {[dict get $ctx scopes $scopeId materialized]} {
            Emit ctx "core::env::define \$$frame [Word [B $b name]] \[lindex \$argv $index\]"
        } else {
            set var v[NewId]
            Emit ctx "set $var \[lindex \$argv $index\]"
            dict set ctx scopes $scopeId locals $b [list box "\$$var"]
        }
        incr index
    }
    DeclareScope ctx $scopeId
    set result [CompileSequence ctx [N $e body]]
    if {[OpType $result] ne "never"} {
        Emit ctx "return [BoxWord $result]"
    }
    if {$looping} {
        Indent ctx -1
        Emit ctx "\}"
    }
    return [ProcSource [namespace tail $procName] {captured argv} $ctx]
}

# ---------------------------------------------------------------------------
# Expressions
#
# Each Compile* procedure emits the commands that evaluate an expression and
# returns its operand.

proc core::compiler::CompileSequence {ctxVar exprs} {
    upvar 1 $ctxVar ctx
    set result [Op box unit unit]
    foreach e $exprs {
        set result [CompileExpr ctx $e]
        if {[OpType $result] eq "never"} {
            # The rest of the sequence cannot run.
            break
        }
    }
    return $result
}

proc core::compiler::CompileExpr {ctxVar e} {
    upvar 1 $ctxVar ctx
    set op [CompileForm ctx $e]
    if {[OpType $op] ne "never"} {
        set op [lreplace $op 2 2 [Type $e]]
    }
    return $op
}

proc core::compiler::CompileForm {ctxVar e} {
    upvar 1 $ctxVar ctx
    switch -- [Kind $e] {
        const {
            set value [N $e value]
            if {[core::value::kind $value] eq "int"} {
                return [Op int [Word [core::value::intOf $value]] int]
            }
            return [Op box [Word $value] any]
        }
        ref {
            return [CompileRef ctx $e]
        }
        bind {
            return [CompileBind ctx $e]
        }
        block {
            return [CompileBlock ctx $e]
        }
        call {
            return [CompileCall ctx $e]
        }
        if {
            return [CompileIf ctx $e]
        }
        loop {
            return [CompileLoop ctx $e]
        }
        return {
            set value [CompileExpr ctx [N $e value]]
            if {[OpType $value] eq "never"} {
                return $value
            }
            if {[dict get $ctx inBlock]} {
                Emit ctx "return [BoxWord $value]"
            } else {
                Emit ctx "return -code return [BoxWord $value]"
            }
            return [Never]
        }
        break {
            set value [Op box unit unit]
            if {[N $e value] ne ""} {
                set value [CompileExpr ctx [N $e value]]
                if {[OpType $value] eq "never"} {
                    return $value
                }
            }
            set loop [N $e target]
            if {[dict exists $ctx loops $loop]} {
                set var [dict get $ctx loops $loop]
                Emit ctx "set $var [BoxWord $value]"
                Emit ctx "break"
            } else {
                Emit ctx "return -code break [BoxWord $value]"
            }
            return [Never]
        }
        continue {
            if {[dict exists $ctx loops [N $e target]]} {
                Emit ctx "continue"
            } else {
                Emit ctx "return -code continue"
            }
            return [Never]
        }
        ok - error {
            set value [CompileExpr ctx [N $e value]]
            if {[OpType $value] eq "never"} {
                return $value
            }
            set t [NewTemp]
            Emit ctx "set $t \[list result [Kind $e] [BoxWord $value]\]"
            return [Op box "\$$t" result]
        }
    }
}

proc core::compiler::CompileRef {ctxVar e} {
    upvar 1 $ctxVar ctx
    set name [N $e name]
    set b [N $e binding]
    set t [NewTemp]
    if {$b eq ""} {
        # Unbound: the lookup raises the interpreter's error.
        Emit ctx "set $t \[core::env::lookup \$base [Word $name]\]"
        return [Never]
    }
    switch -- [B $b kind] {
        root {
            return [Op box [Word [B $b value]] any]
        }
        ambient {
            Emit ctx "set $t \[core::env::lookup \$base [Word $name]\]"
            return [Op box "\$$t" any]
        }
    }
    if {[N $e init] eq "no"} {
        Emit ctx "core::env::usedBeforeBinding [Word $name]"
        return [Never]
    }
    set scope [dict get $ctx scopes [B $b scope]]
    if {[dict get $scope materialized]} {
        Emit ctx "set $t \[core::env::lookupLocal \$[dict get $scope frame] [Word $name]\]"
        return [Op box "\$$t" any]
    }
    lassign [dict get $scope locals $b] repr word
    return [Op $repr $word any]
}

proc core::compiler::CompileBind {ctxVar e} {
    upvar 1 $ctxVar ctx
    variable bindLog
    set b [N $e binding]
    set name [N $e name]
    set value [CompileExpr ctx [N $e value]]
    if {[OpType $value] eq "never"} {
        return $value
    }
    lappend bindLog [list $name [OpType $value]]

    if {[B $b kind] eq "ambient"} {
        Emit ctx "core::env::define \$base [Word $name] [BoxWord $value]"
        return $value
    }
    set scope [dict get $ctx scopes [B $b scope]]
    if {[dict get $scope materialized]} {
        # A duplicate raises here, at run time.
        Emit ctx "core::env::define \$[dict get $scope frame] [Word $name] [BoxWord $value]"
        return [expr {[N $e duplicate] ? [Never] : $value}]
    }
    if {[N $e duplicate]} {
        Emit ctx "core::env::duplicateBinding [Word $name]"
        return [Never]
    }
    lassign $value repr word
    if {![IsLiteral $word] && ![regexp {^\$[tv][0-9]+$} $word]} {
        set var v[NewId]
        Emit ctx "set $var $word"
        set word "\$$var"
    }
    dict set ctx scopes [B $b scope] locals $b [list $repr $word]
    return $value
}

# CALLEE-VAR and ARGS-VAR, if given, receive the operands of callee and argOps.
proc core::compiler::CompileCall {ctxVar e {calleeVar ""} {argsVar ""}} {
    upvar 1 $ctxVar ctx
    if {$calleeVar ne ""} {
        upvar 1 $calleeVar callee $argsVar argOps
    }
    variable envless
    variable selfTailCalls
    set envlessTarget ""
    if {[dict get $ctx program]} {
        set envlessTarget [DirectEnvlessTarget $e $envless]
    }
    if {$envlessTarget ne ""} {
        # The target ignores its environment: no need to look the callee up.
        set callee [Op box {{}} [Type [N $e callee]]]
    } else {
        set callee [CompileExpr ctx [N $e callee]]
        if {[OpType $callee] eq "never"} {
            return $callee
        }
    }
    set argOps {}
    foreach arg [N $e args] {
        set op [CompileExpr ctx $arg]
        if {[OpType $op] eq "never"} {
            return $op
        }
        lappend argOps $op
    }

    variable hir
    lassign [N $e target] targetKind targetId
    switch -- $targetKind {
        native {
            set name [dict get $hir symbols $targetId name]
            return [CompileNativeCall ctx $e $callee $name $argOps]
        }
        block {
            if {$e in $selfTailCalls && [dict exists $ctx block] && [dict get $ctx block] eq $targetId} {
                if {$envlessTarget eq ""} {
                    Emit ctx "set captured \[lindex [BoxWord $callee] 3\]"
                }
                Emit ctx "set argv \[list [BoxWords $argOps]\]"
                Emit ctx "continue"
                return [Never]
            }
            if {$envlessTarget ne ""} {
                set t [NewTemp]
                Emit ctx "set $t \[[BlockProc $targetId] {} \[list [BoxWords $argOps]\]\]"
                return [Op box "\$$t" any]
            }
            if {[dict get $ctx program]
                    && [llength [N $targetId params]] == [llength $argOps]} {
                set t [NewTemp]
                Emit ctx "set $t \[[BlockProc $targetId] \[lindex [BoxWord $callee] 3\] \[list [BoxWords $argOps]\]\]"
                return [Op box "\$$t" any]
            }
        }
    }
    return [GenericCall ctx $callee $argOps]
}

proc core::compiler::BoxWords {ops} {
    return [join [lmap op $ops {BoxWord $op}] { }]
}

proc core::compiler::GenericCall {ctxVar callee argOps} {
    upvar 1 $ctxVar ctx
    set t [NewTemp]
    Emit ctx "set $t \[core::runtime::callValue [BoxWord $callee] \[list [BoxWords $argOps]\]\]"
    return [Op box "\$$t" any]
}

# A call of the native NAME, in order of preference:
#   1. a type test HIR decided (a constant)
#   2. an intrinsic
#   3. a type test as an inline membership check
#   4. a generic call
# Returns the operand.
proc core::compiler::CompileNativeCall {ctxVar e callee name argOps} {
    upvar 1 $ctxVar ctx
    variable intrinsics
    set meta [core::native::metadata $name]
    set arity [dict get $meta arity]
    if {$arity ne "*" && $arity != [llength $argOps]} {
        return [GenericCall ctx $callee $argOps]
    }
    if {[N $e known] ne ""} {
        return [Op bool [N $e known] bool]
    }
    if {[dict exists $intrinsics $name]} {
        set result [{*}[dict get $intrinsics $name] ctx $name $argOps]
        if {$result ne ""} {
            return $result
        }
    }
    set testsType [dict get $meta testsType]
    if {$testsType ne ""} {
        set param [lindex [dict get $meta paramTypes] 0]
        return [InlineTypeTest ctx $name [lindex $argOps 0] $testsType $param]
    }
    if {$arity ne "*"} {
        return [DirectNativeCall ctx $name $meta $argOps]
    }
    return [GenericCall ctx $callee $argOps]
}

# A call of the native NAME (resolved by HIR, arity matching) without the
# runtime's dispatch: the implementation is called directly, followed by
# exactly the contract checks core::native::invoke makes after it, except
# those static types already prove. The callee is a known root constant, so
# nothing about it needs checking.
proc core::compiler::DirectNativeCall {ctxVar name meta argOps} {
    upvar 1 $ctxVar ctx
    set t [NewTemp]
    set impl [join [lmap word [dict get $meta impl] {Word $word}] { }]
    Emit ctx "set $t \[$impl [BoxWords $argOps]\]"
    set index 0
    foreach type [dict get $meta paramTypes] arg $argOps {
        if {$type ni {any ""} && ![core::type::subtype [hir::types::semantic [OpType $arg]] $type]} {
            ContractCheck ctx $type [BoxWord $arg] "$name argument $index"
        }
        incr index
    }
    set resultType [dict get $meta resultType]
    if {$resultType eq "any"} {
        Emit ctx "core::value::check \$$t"
    } else {
        ContractCheck ctx $resultType "\$$t" "$name result"
    }
    return [Op box "\$$t" any]
}

# Emits core::type::AssertCanonical's check of WORD against TYPE, inline for
# a primitive kind.
proc core::compiler::ContractCheck {ctxVar type word context} {
    upvar 1 $ctxVar ctx
    if {[llength $type] == 1} {
        Emit ctx "if \{\[lindex $word 0\] ne \"$type\"\} \{core::type::AssertCanonical $type $word [Word $context]\}"
    } else {
        Emit ctx "core::type::AssertCanonical [Word $type] $word [Word $context]"
    }
}

# ---------------------------------------------------------------------------
# Intrinsics
#
# An intrinsic emits inline code equivalent to calling the native, or returns
# "" to fall back to a generic call. Intrinsics must raise exactly the errors
# the native raises, in the same order.

# Words for ARGS as bare values of kind KIND, emitting the native's own kind
# checks for arguments whose type is not already KIND. Returns "" (emitting
# nothing) if some argument statically has another kind: the generic call
# then raises the error.
proc core::compiler::RequireKind {ctxVar name kind argOps} {
    upvar 1 $ctxVar ctx
    foreach arg $argOps {
        set argKind [hir::types::kindOf [OpType $arg]]
        if {$argKind ne "" && $argKind ne $kind} {
            return ""
        }
    }
    set words {}
    foreach arg $argOps {
        if {[hir::types::kindOf [OpType $arg]] ne $kind} {
            Emit ctx "core::value::expect $kind [BoxWord $arg] [Word $name]"
            set arg [lreplace $arg 2 2 $kind]
        }
        if {$kind eq "int"} {
            lappend words [IntWord $arg]
        } else {
            lappend words [BoxWord $arg]
        }
    }
    return $words
}

proc core::compiler::IntrinsicArith {operator ctxVar name argOps} {
    upvar 1 $ctxVar ctx
    set words [RequireKind ctx $name int $argOps]
    if {$words eq ""} {
        return ""
    }
    set t [NewTemp]
    Emit ctx "set $t \[expr {[lindex $words 0] $operator [lindex $words 1]}\]"
    return [Op int "\$$t" int]
}

proc core::compiler::IntrinsicCompare {operator ctxVar name argOps} {
    upvar 1 $ctxVar ctx
    set words [RequireKind ctx $name int $argOps]
    if {$words eq ""} {
        return ""
    }
    set t [NewTemp]
    Emit ctx "set $t \[expr {[lindex $words 0] $operator [lindex $words 1]}\]"
    return [Op bool "\$$t" bool]
}

proc core::compiler::IntrinsicValueEqual {ctxVar name argOps} {
    upvar 1 $ctxVar ctx
    lassign $argOps a b
    set ka [hir::types::kindOf [OpType $a]]
    set kb [hir::types::kindOf [OpType $b]]
    set t [NewTemp]
    if {$ka eq "" || $kb eq "" || $ka in {block native} || $kb in {block native}} {
        return ""
    }
    if {$ka ne $kb} {
        return [Op bool 0 bool]
    }
    switch -- $ka {
        int {
            Emit ctx "set $t \[expr {[IntWord $a] == [IntWord $b]}\]"
        }
        bool {
            Emit ctx "set $t \[expr {[BoolWord $a] == [BoolWord $b]}\]"
        }
        str {
            Emit ctx "set $t \[string equal \[lindex [BoxWord $a] 1\] \[lindex [BoxWord $b] 1\]\]"
        }
        unit {
            return [Op bool 1 bool]
        }
        default {
            return ""
        }
    }
    return [Op bool "\$$t" bool]
}

proc core::compiler::IntrinsicStringEqual {ctxVar name argOps} {
    upvar 1 $ctxVar ctx
    set words [RequireKind ctx $name str $argOps]
    if {$words eq ""} {
        return ""
    }
    set t [NewTemp]
    Emit ctx "set $t \[string equal \[lindex [lindex $words 0] 1\] \[lindex [lindex $words 1] 1\]\]"
    return [Op bool "\$$t" bool]
}

proc core::compiler::IntrinsicList {ctxVar name argOps} {
    upvar 1 $ctxVar ctx
    set t [NewTemp]
    Emit ctx "set $t \[list list \[list [BoxWords $argOps]\]\]"
    return [Op box "\$$t" list]
}

proc core::compiler::IntrinsicResultIs {tag ctxVar name argOps} {
    upvar 1 $ctxVar ctx
    set arg [lindex $argOps 0]
    set argKind [hir::types::kindOf [OpType $arg]]
    if {$argKind ne "" && $argKind ne "result"} {
        return [Op bool 0 bool]
    }
    set word [BoxWord $arg]
    set t [NewTemp]
    Emit ctx "set $t \[expr {\[lindex $word 0\] eq {result} && \[lindex $word 1\] eq {$tag}}\]"
    return [Op bool "\$$t" bool]
}

# A native declared with -tests-type T (see core/native.tcl) returns exactly
# core::type::acceptsValue T ARG, after the runtime has rejected arguments
# not of its parameter kind P. The runtime verifies this contract in the
# reference implementation, so the compiler may rely on it. Inline code: the
# parameter kind check, then membership.
proc core::compiler::InlineTypeTest {ctxVar name arg testsType param} {
    upvar 1 $ctxVar ctx
    set word [BoxWord $arg]
    if {$param ne "any" && [hir::types::kindOf [OpType $arg]] ne $param} {
        Emit ctx "core::value::expect $param $word [Word $name]"
    }
    if {$testsType eq $param} {
        return [Op bool 1 bool]
    }
    set t [NewTemp]
    if {[llength $testsType] == 1} {
        Emit ctx "set $t \[string equal \[lindex $word 0\] $testsType\]"
    } else {
        Emit ctx "set $t \[core::type::acceptsCanonical [Word $testsType] $word\]"
    }
    return [Op bool "\$$t" bool]
}

# ---------------------------------------------------------------------------
# Control flow

proc core::compiler::CompileIf {ctxVar e} {
    upvar 1 $ctxVar ctx
    set condition [N $e condition]
    set refining [expr {[Kind $condition] eq "call" && [Kind [N $condition callee]] eq "ref"}]
    if {$refining} {
        set test [CompileCall ctx $condition callee argOps]
        if {[OpType $test] ne "never"} {
            set test [lreplace $test 2 2 [Type $condition]]
        }
    } else {
        set test [CompileExpr ctx $condition]
    }
    if {[OpType $test] eq "never"} {
        return $test
    }
    if {[OpType $test] eq "bool"} {
        set outcome [BoolWord $test]
    } else {
        set outcome [NewTemp]
        Emit ctx "set $outcome \[core::runtime::conditionOutcome [BoxWord $test]\]"
        set outcome "\$$outcome"
    }

    set outcomes {1 0}
    if {[IsLiteral $outcome]} {
        set outcomes [list $outcome]
    }
    set parentFrame [CurrentFrameExpr $ctx]
    set compiled [dict create]
    foreach branchOutcome $outcomes {
        set role [expr {$branchOutcome ? "then" : "else"}]
        set savedLines [dict get $ctx lines]
        dict set ctx lines {}
        if {[llength $outcomes] == 2} {
            Indent ctx 1
        }
        set id [N $e ${role}Scope]
        OpenScope ctx $id $parentFrame
        DeclareScope ctx $id
        if {$refining && [dict get $ctx scopes $id materialized]} {
            # Refinements are observable in the frame: install what the
            # runtime rule proves for the callee value actually called.
            variable hir
            set argNodes [lmap arg [N $condition args] {Lower $arg}]
            Emit ctx "core::refine::install \$[dict get $ctx scopes $id frame] \[core::refine::factsFromCall [BoxWord $callee] [Word $argNodes] $parentFrame $branchOutcome\]"
        }
        set value [CompileSequence ctx [N $e ${role}Body]]
        PopScope ctx
        if {[llength $outcomes] == 2} {
            Indent ctx -1
        }
        dict set compiled $branchOutcome [list [dict get $ctx lines] $value]
        dict set ctx lines $savedLines
    }

    if {[llength $outcomes] == 1} {
        lassign [dict get $compiled $outcome] lines value
        foreach line $lines {
            dict lappend ctx lines $line
        }
        return $value
    }

    # Common representation of the branch values.
    set reprs {}
    dict for {branchOutcome entry} $compiled {
        set value [lindex $entry 1]
        if {[OpType $value] ne "never"} {
            lappend reprs [lindex $value 0]
        }
    }
    if {$reprs eq ""} {
        set never 1
    }
    set reprs [lsort -unique $reprs]
    set repr [expr {[llength $reprs] == 1 ? [lindex $reprs 0] : "box"}]

    set result [NewTemp]
    Emit ctx "if {$outcome} \{"
    foreach branchOutcome {1 0} {
        if {$branchOutcome == 0} {
            Emit ctx "\} else \{"
        }
        lassign [dict get $compiled $branchOutcome] lines value
        foreach line $lines {
            dict lappend ctx lines $line
        }
        if {[OpType $value] ne "never"} {
            Indent ctx 1
            Emit ctx "set $result [Coerce $value $repr]"
            Indent ctx -1
        }
    }
    Emit ctx "\}"
    if {[info exists never]} {
        return [Never]
    }
    return [Op $repr "\$$result" any]
}

proc core::compiler::CompileLoop {ctxVar e} {
    upvar 1 $ctxVar ctx
    set result [NewTemp]
    set parentFrame [CurrentFrameExpr $ctx]
    Emit ctx "while 1 \{"
    Indent ctx 1
    set id [N $e bodyScope]
    OpenScope ctx $id $parentFrame
    DeclareScope ctx $id
    dict set ctx loops $e $result
    CompileSequence ctx [N $e body]
    dict unset ctx loops $e
    PopScope ctx
    Indent ctx -1
    Emit ctx "\}"
    return [Op box "\$$result" any]
}

core::registerBackend compile core::compiler::runSequence core::compiler::runProgram
