# compiler.tcl -- compiles core IR to Tcl procedures, guided by static types.
#
#   source compiler/compiler.tcl       ;# also loads core
#   core::useBackend compile
#
# The compiler is a second implementation of the same semantics as the
# interpreter in core/evaluator.tcl. It shares the runtime (values, natives,
# environments, call boundary) but none of the interpreter's evaluation
# machinery. Static types (types.tcl) let it replace generic runtime
# operations with specialized Tcl code whenever that is indistinguishable.
#
# Translation scheme
# ------------------
# * A compilation unit becomes a Tcl proc taking the environment it runs in:
#   `proc unitN {base} {...}`. A unit is compiled in one of two modes:
#     sequence  run in an arbitrary environment (core::evalIn)
#     program   run as a checked program in a fresh program scope over a
#               fresh root (core::evalProgram); root bindings are then known
#               constants and program-level bindings are statically typed
# * Each block node becomes `proc blockN {captured argv} {...}`; the Block
#   value carries its name as CODE (see core/block.tcl).
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
# Compiling an expression yields an *operand* {REPR WORD TYPE KEY}:
#   REPR  box   WORD evaluates to a runtime value ({int 5}, {str a}, ...)
#         int   WORD evaluates to a bare canonical integer (TYPE is int)
#         bool  WORD evaluates to 1 or 0 (TYPE is bool)
#   TYPE  its static type
#   KEY   the binding it was read from, if any, so facts learned about the
#         value can be attached to the binding
# Unboxed representations never escape: values are boxed whenever they are
# stored in a frame, passed to a call, returned or broken out of a loop.
#
# Name resolution and storage
# ---------------------------
# Every name is resolved statically. A scope is *materialized* as a runtime
# frame iff it contains a block node: only then can a closure capture it or
# its bindings or refinements be observed. Such scopes declare their names
# on entry and access them through core::env (run-time use-before-binding
# checks). Other scopes keep bindings in Tcl variables (or propagate them as
# constants); use-before-binding and duplicates are decided statically there.
#
# Type-directed code
# ------------------
# * Calls of known natives with an intrinsic (+ - * < <= > >= == eq list
#   integer? string? list? ok? error?) compile to inline Tcl. Arguments of
#   unknown type are first checked with core::value::expect, which raises
#   exactly the error the native would; the check then becomes a fact.
# * Predicates on arguments of known kind fold to constants; an if with a
#   constant condition compiles only the branch that runs.
# * In program mode, calls of a Block whose proc and arity are statically
#   known call the proc directly. (Checked programs cannot produce escaping
#   break/continue codes, so the generic boundary would be a no-op.)
# * Block result types are inferred, iterating to a fixpoint for a block
#   that calls itself through the binding it is bound to.
#
# Facts are scoped like the control flow that proves them: facts learned in
# a branch or loop body are dropped at its end; facts learned in a sequence
# hold for the rest of it; closures inherit the facts known where they are
# created (their captured bindings cannot change afterwards).

source [file join [file dirname [file dirname [file normalize [info script]]]] core core.tcl]
source [file join [file dirname [file normalize [info script]]] types.tcl]

namespace eval core::compiler {
    variable nextId 0
    # {MODE EXPRS} -> dict {name UNIT-PROC code CODE types PROGRAM-TYPES}
    variable cache [dict create]
    # Proc sources generated for the unit being compiled.
    variable pending {}
    # {NAME TYPE} for every bind compiled into the unit, in compilation order.
    variable bindLog {}
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
        lassign [GenerateUnit $mode $exprs] name code types bindings
        # The procs are defined only after the whole unit compiled cleanly.
        namespace eval ::core::compiler::code $code
        dict set cache $key [dict create name ::core::compiler::code::$name \
            code $code types $types bindings $bindings]
    }
    return [dict get $cache $key name]
}

# The generated Tcl code for EXPRS, for inspection.
proc core::compiler::generatedCode {exprs {mode program}} {
    variable cache
    compileUnit $mode $exprs
    return [dict get $cache [list $mode $exprs] code]
}

# Inferred static types of the program-level bindings of EXPRS: NAME -> TYPE.
proc core::compiler::programTypes {exprs} {
    variable cache
    compileUnit program $exprs
    return [dict get $cache [list program $exprs] types]
}

# Every binding compiled for the program EXPRS, at any depth, with its
# inferred static type: a list of {NAME TYPE} in compilation order. Types
# include branch refinements and flow facts known where the bind occurs.
proc core::compiler::bindingTypes {exprs} {
    variable cache
    compileUnit program $exprs
    return [dict get $cache [list program $exprs] bindings]
}

# ---------------------------------------------------------------------------
# Compilation context
#
# A context describes the proc being generated:
#   lines        generated commands
#   indent       current indentation depth
#   scopes       SCOPE-ID -> scope dict
#   order        scope ids, outermost first
#   loops        result variables of enclosing compiled loops, innermost last
#   breakTypes   loop result variable -> type of the values broken with
#   inBlock      1 inside a block proc, 0 at unit level
#   returnType   lub of the values returned from the current block proc
#   program      1 when compiling in program mode
#   types        BINDING-KEY -> static type of the binding
#   facts        BINDING-KEY -> narrowed type proven on the current path
#
# A scope dict:
#   kind          top | local
#   materialized  1 if the scope is a runtime frame
#   frame         Tcl variable holding the frame (materialized scopes)
#   names         names bound in the scope (for top: program mode only)
#   locals        NAME -> {REPR WORD} (non-materialized scopes)
#   init          names whose (first) bind has been compiled
#   constants     NAME -> value (top scope in program mode: the root)

proc core::compiler::NewId {} {
    variable nextId
    return [incr nextId]
}

proc core::compiler::NewContext {inBlock program} {
    return [dict create lines {} indent 1 scopes {} order {} loops {} breakTypes {} \
        inBlock $inBlock returnType never program $program types {} facts {}]
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
    set names $extraNames
    foreach name [core::ir::scopeBindNames $exprs] {
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

proc core::compiler::MarkBound {ctxVar id name} {
    upvar 1 $ctxVar ctx
    set init [dict get $ctx scopes $id init]
    lappend init $name
    dict set ctx scopes $id init $init
}

# ---------------------------------------------------------------------------
# Operands

proc core::compiler::Op {repr word type {key ""}} {
    return [list $repr $word $type $key]
}

proc core::compiler::OpType {op} { return [lindex $op 2] }
proc core::compiler::OpKey {op}  { return [lindex $op 3] }

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

# Current static type of the binding KEY.
proc core::compiler::KeyType {ctx key} {
    if {[dict exists $ctx facts $key]} {
        return [dict get $ctx facts $key]
    }
    if {[dict exists $ctx types $key]} {
        return [dict get $ctx types $key]
    }
    return any
}

# Records that the value of OP has type TYPE on the current path.
proc core::compiler::LearnFact {ctxVar op type} {
    upvar 1 $ctxVar ctx
    set key [OpKey $op]
    if {$key ne ""} {
        dict set ctx facts $key [core::types::narrow [KeyType $ctx $key] $type]
    }
}

# ---------------------------------------------------------------------------
# Units and blocks

# Returns {UNIT-PROC-NAME CODE PROGRAM-TYPES BINDINGS}.
proc core::compiler::GenerateUnit {mode exprs} {
    variable pending
    variable bindLog
    set pending {}
    set bindLog {}
    set program [expr {$mode eq "program"}]
    set ctx [NewContext 0 $program]
    set top [dict create kind top materialized 1 frame base init {}]
    if {$program} {
        set constants [dict create true [core::value::true] false [core::value::false] \
            unit [core::value::unit]]
        foreach name [core::native::names] {
            dict set constants $name [core::value::native $name]
        }
        dict set top names [core::ir::scopeBindNames $exprs]
        dict set top constants $constants
    }
    PushScope ctx top $top
    set result [CompileSequence ctx $exprs]
    Emit ctx "return [BoxWord $result]"
    set name unit[NewId]
    lappend pending [ProcSource $name {base} $ctx]

    set types [dict create]
    dict for {key type} [dict get $ctx types] {
        if {[string match top:* $key]} {
            dict set types [string range $key 4 end] $type
        }
    }
    return [list $name [join $pending \n\n] $types $bindLog]
}

proc core::compiler::ProcSource {name params ctx} {
    return "proc $name [list $params] {\n[join [dict get $ctx lines] \n]\n}"
}

# Compiles a block node. SELF-KEY/PROC-NAME are given when the block is the
# value of a binding: calls through that binding inside the body are then
# typed with the block's own (inferred) result type.
proc core::compiler::CompileBlock {ctxVar node {selfKey ""} {procName ""}} {
    upvar 1 $ctxVar outer
    variable pending
    variable bindLog
    set params [core::ir::blockParams $node]
    set arity [llength $params]
    if {$procName eq ""} {
        set procName ::core::compiler::code::block[NewId]
    }

    # Result type inference. Without self-reference one pass suffices. With
    # it, assume a result type, compile, and repeat with the inferred type
    # until it is stable (sound by induction over calls); give up with any.
    set assumed never
    set attempts [expr {$selfKey eq "" ? 1 : 3}]
    for {set attempt 1} {$attempt <= $attempts} {incr attempt} {
        if {$attempt == $attempts && $attempts > 1} {
            set assumed any
        }
        set saved [list $pending $bindLog]
        lassign [CompileBlockBody outer $node $procName $selfKey $assumed] resultType source
        if {$selfKey eq "" || $resultType eq $assumed || $assumed eq "any"} {
            break
        }
        lassign $saved pending bindLog
        set assumed $resultType
    }
    lappend pending $source

    set type [list block $procName $arity $resultType]
    set t [NewTemp]
    Emit outer "set $t \[core::value::block [Word $params] [Word [core::ir::blockBody $node]] [CurrentFrameExpr $outer] [Word $procName]\]"
    return [Op box "\$$t" $type]
}

# One compilation of a block body. Returns {RESULT-TYPE PROC-SOURCE}.
proc core::compiler::CompileBlockBody {outerVar node procName selfKey assumed} {
    upvar 1 $outerVar outer
    set params [core::ir::blockParams $node]
    set body [core::ir::blockBody $node]

    set ctx [NewContext 1 [dict get $outer program]]
    dict set ctx types [dict get $outer types]
    dict set ctx facts [dict get $outer facts]
    if {$selfKey ne ""} {
        dict set ctx types $selfKey [list block $procName [llength $params] $assumed]
    }

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
            dict set ctx scopes $scopeId locals $param [list box "\$$var"]
        }
        MarkBound ctx $scopeId $param
        incr index
    }
    DeclareScope ctx $scopeId $body
    set result [CompileSequence ctx $body]
    if {[OpType $result] ne "never"} {
        Emit ctx "return [BoxWord $result]"
    }
    set resultType [core::types::lub [OpType $result] [dict get $ctx returnType]]
    return [list $resultType [ProcSource [namespace tail $procName] {captured argv} $ctx]]
}

# ---------------------------------------------------------------------------
# Expressions
#
# Each Compile* procedure emits the commands that evaluate a node and returns
# its operand.

proc core::compiler::CompileSequence {ctxVar exprs} {
    upvar 1 $ctxVar ctx
    set result [Op box unit unit]
    foreach expr $exprs {
        set result [CompileExpr ctx $expr]
        if {[OpType $result] eq "never"} {
            # The rest of the sequence cannot run.
            break
        }
    }
    return $result
}

proc core::compiler::CompileExpr {ctxVar node} {
    upvar 1 $ctxVar ctx
    core::ir::checkShape $node
    switch -- [core::ir::op $node] {
        const {
            set value [core::ir::literalValue $node]
            if {[core::value::kind $value] eq "int"} {
                return [Op int [Word [core::value::intOf $value]] int]
            }
            return [Op box [Word $value] [core::types::ofValue $value]]
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
            if {[OpType $value] eq "never"} {
                return $value
            }
            if {[dict get $ctx inBlock]} {
                dict set ctx returnType [core::types::lub [dict get $ctx returnType] [OpType $value]]
                Emit ctx "return [BoxWord $value]"
            } else {
                Emit ctx "return -code return [BoxWord $value]"
            }
            return [Never]
        }
        break {
            set value [Op box unit unit]
            if {[llength $node] == 2} {
                set value [CompileExpr ctx [lindex $node 1]]
                if {[OpType $value] eq "never"} {
                    return $value
                }
            }
            set loops [dict get $ctx loops]
            if {$loops ne ""} {
                set var [lindex $loops end]
                dict set ctx breakTypes $var \
                    [core::types::lub [dict get $ctx breakTypes $var] [OpType $value]]
                Emit ctx "set $var [BoxWord $value]"
                Emit ctx "break"
            } else {
                Emit ctx "return -code break [BoxWord $value]"
            }
            return [Never]
        }
        continue {
            if {[dict get $ctx loops] ne ""} {
                Emit ctx "continue"
            } else {
                Emit ctx "return -code continue"
            }
            return [Never]
        }
        ok - error-value {
            set value [CompileExpr ctx [lindex $node 1]]
            if {[OpType $value] eq "never"} {
                return $value
            }
            set tag [expr {[core::ir::op $node] eq "ok" ? "ok" : "error"}]
            set t [NewTemp]
            Emit ctx "set $t \[list result $tag [BoxWord $value]\]"
            return [Op box "\$$t" result]
        }
    }
}

proc core::compiler::CompileRef {ctxVar name} {
    upvar 1 $ctxVar ctx
    set t [NewTemp]
    foreach id [lreverse [dict get $ctx order]] {
        set scope [dict get $ctx scopes $id]
        set key $id:$name
        if {[dict get $scope kind] eq "top"} {
            if {[dict get $ctx program]} {
                if {$name in [dict get $scope names]} {
                    Emit ctx "set $t \[core::env::lookupLocal \$base [Word $name]\]"
                    return [Op box "\$$t" [KeyType $ctx $key] $key]
                }
                if {[dict exists $scope constants $name]} {
                    set value [dict get $scope constants $name]
                    return [Op box [Word $value] [core::types::ofValue $value]]
                }
            }
            Emit ctx "set $t \[core::env::lookup \$[dict get $scope frame] [Word $name]\]"
            return [Op box "\$$t" any]
        }
        if {$name ni [dict get $scope names]} {
            continue
        }
        if {[dict get $scope materialized]} {
            Emit ctx "set $t \[core::env::lookupLocal \$[dict get $scope frame] [Word $name]\]"
            return [Op box "\$$t" [KeyType $ctx $key] $key]
        }
        if {$name in [dict get $scope init]} {
            lassign [dict get $scope locals $name] repr word
            return [Op $repr $word [KeyType $ctx $key] $key]
        }
        Emit ctx "core::env::usedBeforeBinding [Word $name]"
        return [Never]
    }
    error "core::compiler: no top scope"
}

proc core::compiler::CompileBind {ctxVar name valueNode} {
    upvar 1 $ctxVar ctx
    set id [InnermostScopeId $ctx]
    set scope [dict get $ctx scopes $id]
    set key $id:$name
    # Only the first bind of a name gives the binding its type; any later
    # bind of it in the same scope fails with a duplicate-binding error.
    set first [expr {$name ni [dict get $scope init]}]
    set typed [expr {$first && ([dict get $scope kind] ne "top" || [dict get $ctx program])}]

    if {[core::ir::op $valueNode] eq "block" && $typed} {
        core::ir::checkShape $valueNode
        set value [CompileBlock ctx $valueNode $key]
    } else {
        set value [CompileExpr ctx $valueNode]
    }
    if {[OpType $value] eq "never"} {
        return $value
    }
    if {$typed} {
        dict set ctx types $key [OpType $value]
    }
    variable bindLog
    lappend bindLog [list $name [OpType $value]]

    if {[dict get $scope materialized]} {
        if {$first} {
            MarkBound ctx $id $name
        }
        Emit ctx "core::env::define \$[dict get $scope frame] [Word $name] [BoxWord $value]"
    } elseif {!$first} {
        Emit ctx "core::env::duplicateBinding [Word $name]"
        return [Never]
    } else {
        lassign $value repr word
        if {![IsLiteral $word] && ![regexp {^\$[tv][0-9]+$} $word]} {
            set var v[NewId]
            Emit ctx "set $var $word"
            set word "\$$var"
        }
        dict set ctx scopes $id locals $name [list $repr $word]
        MarkBound ctx $id $name
    }
    return [lreplace $value 3 3 $key]
}

# CALLEE-VAR and ARGS-VAR, if given, receive the operands of callee and argOps.
proc core::compiler::CompileCall {ctxVar node {calleeVar ""} {argsVar ""}} {
    upvar 1 $ctxVar ctx
    if {$calleeVar ne ""} {
        upvar 1 $calleeVar callee $argsVar argOps
    }
    set callee [CompileExpr ctx [lindex $node 1]]
    if {[OpType $callee] eq "never"} {
        return $callee
    }
    set argOps {}
    foreach argNode [lrange $node 2 end] {
        set arg [CompileExpr ctx $argNode]
        if {[OpType $arg] eq "never"} {
            return $arg
        }
        lappend argOps $arg
    }

    set calleeType [OpType $callee]
    set resultType any
    switch -- [lindex $calleeType 0] {
        native {
            if {[llength $calleeType] == 2} {
                set name [lindex $calleeType 1]
                set result [CompileNativeCall ctx $callee $name $argOps]
                if {$result ne ""} {
                    return $result
                }
            }
        }
        block {
            if {[llength $calleeType] == 4} {
                lassign $calleeType _ procName arity blockResult
                if {$arity == [llength $argOps]} {
                    set resultType $blockResult
                    if {[dict get $ctx program]} {
                        set t [NewTemp]
                        Emit ctx "set $t \[$procName \[lindex [BoxWord $callee] 3\] \[list [BoxWords $argOps]\]\]"
                        return [Op box "\$$t" $resultType]
                    }
                }
            }
        }
    }
    return [GenericCall ctx $callee $argOps $resultType]
}

proc core::compiler::BoxWords {ops} {
    return [join [lmap op $ops {BoxWord $op}] { }]
}

proc core::compiler::GenericCall {ctxVar callee argOps resultType} {
    upvar 1 $ctxVar ctx
    set t [NewTemp]
    Emit ctx "set $t \[core::runtime::callValue [BoxWord $callee] \[list [BoxWords $argOps]\]\]"
    return [Op box "\$$t" $resultType]
}

# A call of the native NAME, in order of preference:
#   1. a type test decided by the argument's static type (a constant)
#   2. an intrinsic
#   3. a type test as an inline membership check
#   4. a generic call typed by the native's signature
# Returns the operand.
proc core::compiler::CompileNativeCall {ctxVar callee name argOps} {
    upvar 1 $ctxVar ctx
    variable intrinsics
    set meta [core::native::metadata $name]
    set arity [dict get $meta arity]
    if {$arity ne "*" && $arity != [llength $argOps]} {
        return [GenericCall ctx $callee $argOps any]
    }
    set testsType [dict get $meta testsType]
    if {$testsType ne ""} {
        set param [lindex [dict get $meta paramTypes] 0]
        set folded [FoldTypeTest [lindex $argOps 0] $testsType $param]
        if {$folded ne ""} {
            return $folded
        }
    }
    if {[dict exists $intrinsics $name]} {
        set result [{*}[dict get $intrinsics $name] ctx $name $argOps]
        if {$result ne ""} {
            return $result
        }
    }
    if {$testsType ne ""} {
        return [InlineTypeTest ctx $name [lindex $argOps 0] $testsType $param]
    }
    lassign [core::types::nativeSignature $name] paramTypes resultType
    set result [GenericCall ctx $callee $argOps $resultType]
    # The call returned, so every argument had its required kind.
    foreach arg $argOps paramType $paramTypes {
        if {$paramType ne ""} {
            LearnFact ctx $arg $paramType
        }
    }
    return $result
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
        set argKind [core::types::kindOf [OpType $arg]]
        if {$argKind ne "" && $argKind ne $kind} {
            return ""
        }
    }
    set words {}
    foreach arg $argOps {
        if {[core::types::kindOf [OpType $arg]] ne $kind} {
            Emit ctx "core::value::expect $kind [BoxWord $arg] [Word $name]"
            LearnFact ctx $arg $kind
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
    set ka [core::types::kindOf [OpType $a]]
    set kb [core::types::kindOf [OpType $b]]
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

# ---------------------------------------------------------------------------
# Type tests
#
# A native declared with -tests-type T (see core/native.tcl) returns exactly
# core::type::acceptsValue T ARG, after the runtime has rejected arguments
# not of its parameter kind P. The runtime verifies this contract in the
# reference implementation, so the compiler may rely on it.

# The semantic type (core/type.tcl) an operand's static type implies.
proc core::compiler::SemanticType {type} {
    if {$type eq "never"} {
        return any
    }
    if {[llength $type] > 1 && [lindex $type 0] in {native block}} {
        return [lindex $type 0]
    }
    return $type
}

# A constant operand if the argument's static type decides the test of
# TESTS-TYPE (with parameter type PARAM); otherwise "".
proc core::compiler::FoldTypeTest {arg testsType param} {
    set type [SemanticType [OpType $arg]]
    if {$type eq "any" || ![core::type::subtype $type $param]} {
        # Unknown, or the call raises the parameter kind error at run time.
        return ""
    }
    if {[core::type::subtype $type $testsType]} {
        return [Op bool 1 bool]
    }
    if {[core::type::base $type] ne [core::type::base $testsType]} {
        return [Op bool 0 bool]
    }
    return ""
}

# Inline code for the type test: the parameter kind check, then membership.
proc core::compiler::InlineTypeTest {ctxVar name arg testsType param} {
    upvar 1 $ctxVar ctx
    set word [BoxWord $arg]
    if {$param ne "any" && [core::types::kindOf [OpType $arg]] ne $param} {
        Emit ctx "core::value::expect $param $word [Word $name]"
        LearnFact ctx $arg $param
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

proc core::compiler::IntrinsicResultIs {tag ctxVar name argOps} {
    upvar 1 $ctxVar ctx
    set arg [lindex $argOps 0]
    set argKind [core::types::kindOf [OpType $arg]]
    if {$argKind ne "" && $argKind ne "result"} {
        return [Op bool 0 bool]
    }
    set word [BoxWord $arg]
    set t [NewTemp]
    Emit ctx "set $t \[expr {\[lindex $word 0\] eq {result} && \[lindex $word 1\] eq {$tag}}\]"
    return [Op bool "\$$t" bool]
}

# ---------------------------------------------------------------------------
# Control flow

proc core::compiler::CompileIf {ctxVar node} {
    upvar 1 $ctxVar ctx
    set condition [lindex $node 1]
    set refining [core::refine::isRefiningCondition $condition]
    if {$refining} {
        set test [CompileCall ctx $condition callee argOps]
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
        LearnFact ctx $test bool
        set outcome "\$$outcome"
    }

    # Refinement facts of the predicate, per outcome: {OPERAND TYPE ...}.
    set branchFacts [dict create 1 {} 0 {}]
    if {$refining && [lindex [OpType $callee] 0] eq "native" && [llength [OpType $callee]] == 2} {
        foreach branchOutcome {1 0} {
            set rules [core::native::refinementRules [lindex [OpType $callee] 1] $branchOutcome]
            foreach {index fact} $rules {
                if {$index < [llength $argOps]} {
                    dict lappend branchFacts $branchOutcome [lindex $argOps $index] $fact
                }
            }
        }
    }

    set outcomes {1 0}
    if {[IsLiteral $outcome]} {
        set outcomes [list $outcome]
    }
    set parentFrame [CurrentFrameExpr $ctx]
    set compiled [dict create]
    foreach branchOutcome $outcomes {
        set savedLines [dict get $ctx lines]
        set savedFacts [dict get $ctx facts]
        dict set ctx lines {}
        if {[llength $outcomes] == 2} {
            Indent ctx 1
        }
        foreach {arg type} [dict get $branchFacts $branchOutcome] {
            LearnFact ctx $arg $type
        }
        set body [core::ir::blockBody [lindex $node [expr {$branchOutcome ? 2 : 3}]]]
        set id [OpenScope ctx $body $parentFrame]
        DeclareScope ctx $id $body
        if {$refining && [dict get $ctx scopes $id materialized]} {
            Emit ctx "core::refine::install \$[FrameVar $id] \[core::refine::factsFromCall [BoxWord $callee] [Word [lrange $condition 2 end]] $parentFrame $branchOutcome\]"
        }
        set value [CompileSequence ctx $body]
        PopScope ctx
        if {[llength $outcomes] == 2} {
            Indent ctx -1
        }
        dict set compiled $branchOutcome [list [dict get $ctx lines] $value]
        dict set ctx lines $savedLines
        dict set ctx facts $savedFacts
    }

    if {[llength $outcomes] == 1} {
        lassign [dict get $compiled $outcome] lines value
        foreach line $lines {
            dict lappend ctx lines $line
        }
        return [lreplace $value 3 3 ""]
    }

    # Common representation of the branch values.
    set type never
    set reprs {}
    dict for {branchOutcome entry} $compiled {
        set value [lindex $entry 1]
        set type [core::types::lub $type [OpType $value]]
        if {[OpType $value] ne "never"} {
            lappend reprs [lindex $value 0]
        }
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
    return [Op $repr "\$$result" $type]
}

proc core::compiler::CompileLoop {ctxVar node} {
    upvar 1 $ctxVar ctx
    set body [core::ir::blockBody [lindex $node 1]]
    set result [NewTemp]
    set parentFrame [CurrentFrameExpr $ctx]
    set savedFacts [dict get $ctx facts]
    Emit ctx "while 1 \{"
    Indent ctx 1
    set id [OpenScope ctx $body $parentFrame]
    DeclareScope ctx $id $body
    dict lappend ctx loops $result
    dict set ctx breakTypes $result never
    CompileSequence ctx $body
    dict set ctx loops [lrange [dict get $ctx loops] 0 end-1]
    set type [dict get $ctx breakTypes $result]
    PopScope ctx
    Indent ctx -1
    Emit ctx "\}"
    dict set ctx facts $savedFacts
    return [Op box "\$$result" $type]
}

core::registerBackend compile core::compiler::runSequence core::compiler::runProgram
