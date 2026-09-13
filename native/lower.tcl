# lower.tcl -- native lowering: semantic HIR to NIR, the native backend IR.
#
#   set nir [native::lower::program $hir]      ;# dict: text functions ...
#   puts [dict get $nir text]
#
# Pipeline:
#
#   HIR --native::lower--> NIR (text) --botlish-native--> Cranelift IR --> machine code
#
# This layer decides *what* native code does; the Rust backend
# (native/src/codegen) decides only how to express it in Cranelift IR. It
# does no semantic analysis of its own. Everything it knows comes from HIR
# and from the shared analyses in hir/aot.tcl:
#
#   known call targets, static types        HIR (types.tcl)
#   which operand needs which kind check    hir::aot::analyze blockers
#                                           (class representation) and
#                                           known-error facts
#   self tail calls                         hir::aot::selfTailCalls (the same
#                                           criterion the Tcl compiler uses)
#   references needing an init check        hir::aot::unprovenReferences
#   blocks that need no environment         hir::aot::StaticBlocks
#
# NIR
# ---
# A NIR program is a list of functions over numbered registers (%0, %1, ...)
# holding tagged Botlish values. It has no semantic concepts (no names to
# resolve, no types, no traits): only representation-level operations.
#
#   native "NAME" arity=N|* params="KIND..." impl=OP
#       A native used as a value: what a call chosen at run time checks and
#       performs (from the native registry).
#   func F "NAME" params=N env=0|1 regs=R pnames="P ..." captures=K
#       Function F. Registers %0..%N-1 hold the arguments on entry. env=1:
#       the function also receives its closure, holding K captures.
#   %d = int DIGITS | str "TEXT" | bool true|false | unit
#   %d = native NAME           a native callable value
#   %d = fnvalue F             the closure of environment-free function F
#   %d = self                  the running closure (env=1)
#   %d = capture I             capture I of the running closure (env=1)
#   %d = move %s
#   %d = cell                  a fresh binding cell, not yet bound
#   cellset %c %v              binds the cell
#   %d = cellget %c            reads a cell proven bound
#   %d = cellcheck %c "NAME"   reads a cell; UNBOUND if not bound yet
#   %d = closure F %c...       a closure of F capturing the values %c...
#   guard KIND %v "CONTEXT"    TYPE error unless %v has kind KIND
#   guardbool %v               NOT-BOOLEAN error unless %v is a Boolean
#   %d = op OP %a...           a known operation whose operands have the
#                              kinds it requires (see Ops below)
#   %d = call F %a...          direct call of environment-free F
#   %d = callenv F %k %a...    direct call of F with closure %k
#   %d = callvalue %f %a...    call of a callable chosen at run time
#   tail %a...                 self tail call: rebind %0.. and restart
#   tailenv %k %a...           the same, with closure %k
#   br %c LTHEN LELSE          %c is a Boolean
#   jump L / label L / ret %v
#   raise KIND "MESSAGE"       a semantic error HIR found statically
#   unreachable                HIR proved no normal completion reaches here
#
# Every instruction may end with @ExprId (its HIR expression).
#
# Values and bindings
# -------------------
# A local binding is a register, unless some reference to it cannot be
# proven bound when it runs (a forward reference from a closure): then it is
# a *cell* created when its scope is entered, and closures capture the cell.
# Closures capture every other binding by value, which is sound because a
# proven reference's binding is bound before the closure is created. A
# closure refers to its own function binding through `self`. A binding bound
# to an environment-free function is not captured at all: its value is the
# function's constant closure (fnvalue).
#
# Unsupported constructs raise {NATIVE UNSUPPORTED} with the source location
# and HIR node (see Unsupported).

namespace eval native::lower {
    # Native name -> how native code performs it: {op OP} (after the
    # parameter kind checks the registry declares), or a special form. The
    # identity of an implementation is necessarily by native; everything
    # else (arity, parameter kinds, runtime needs) comes from the registry.
    variable natives [dict create \
        +            {op iadd} \
        -            {op isub} \
        *            {op imul} \
        <            {op ilt} \
        <=           {op ile} \
        >            {op igt} \
        >=           {op ige} \
        ==           {equality} \
        eq           {op streq} \
        list         {op listnew} \
        length       {op strlen} \
        substring    {op substr} \
        lowercase    {op strlower} \
        concat       {op strcat} \
        list_length  {op listlen} \
        list_get     {op listget} \
        list_append  {op listappend} \
        integer?     {op isint} \
        string?      {op isstr} \
        list?        {op islist} \
        ok?          {op isok} \
        error?       {op iserror} \
        result-value {op resultvalue} \
        result-error {op resulterror}]
    # State of the program being lowered.
    variable hir {}
    variable guards {}
    variable knownErrors {}
    variable selfTail {}
    variable unproven {}
    variable cells {}
    variable envless {}
    variable functionIds {}
    variable captureLists {}
    variable pending {}
    variable usedNatives {}
}

# ---------------------------------------------------------------------------
# Entry point

# The NIR of the program-mode HIR program HIR. Returns a dict:
#   text        the NIR program
#   functions   list of dicts {id name block envless selfTail calls}
#   analysis    the hir::aot analysis it was lowered from
proc native::lower::program {hirProgram} {
    variable hir
    variable guards
    variable knownErrors
    variable selfTail
    variable unproven
    variable cells
    variable envless
    variable functionIds
    variable captureLists
    variable pending
    variable usedNatives

    if {[hir::mode $hirProgram] ne "program"} {
        throw {NATIVE UNSUPPORTED sequence-mode} \
            "native lowering: only program-mode HIR can be compiled (sequence mode runs in an unknown environment)"
    }
    set hir $hirProgram
    set analysis [hir::aot::analyze $hir]
    set selfTail [hir::aot::selfTailCalls $hir]
    set unproven [hir::aot::unprovenReferences $hir]
    CollectChecks $analysis
    set cells [CellBindings]
    set envless [EnvlessBlocks]
    set functionIds [dict create program 0]
    set captureLists [dict create]
    set usedNatives {}
    set next 1
    foreach e [hir::walk $hir] {
        if {[hir::kind $hir $e] eq "block" && [hir::get $hir $e reachable]} {
            dict set functionIds $e $next
            incr next
            if {$e ni $envless} {
                dict set captureLists $e [CaptureList $e]
            }
        }
    }

    set functions {}
    set texts {}
    set pending [list program]
    set done {}
    while {$pending ne ""} {
        set pending [lassign $pending region]
        if {$region in $done} {
            continue
        }
        lappend done $region
        lassign [Function $region] text info
        lappend texts $text
        lappend functions $info
    }
    set header [list "nir 1"]
    foreach name [lsort $usedNatives] {
        set meta [core::native::metadata $name]
        set kinds [lmap type [dict get $meta paramTypes] {
            expr {$type eq "any" ? "any" : [core::type::base $type]}
        }]
        lappend header "native [Quote $name] arity=[dict get $meta arity] params=[Quote $kinds] impl=[NativeImpl $name]"
    }
    # Functions in id order.
    set order [lsort -integer -indices [lmap info $functions {dict get $info id}]]
    set texts [lmap i $order {lindex $texts $i}]
    set functions [lmap i $order {lindex $functions $i}]
    set text "[join $header \n]\n\n[join $texts \n\n]\n"
    return [dict create text $text functions $functions analysis $analysis]
}

# ---------------------------------------------------------------------------
# Program facts (from HIR and hir::aot)

# guards: {OPERATION OPERAND} -> required type, for every representation
# blocker; knownErrors: {OPERATION OPERAND} -> error kind.
proc native::lower::CollectChecks {analysis} {
    variable guards
    variable knownErrors
    set guards [dict create]
    set knownErrors [dict create]
    dict for {id region} [dict get $analysis regions] {
        foreach blocker [dict get $region blockers] {
            switch -- [dict get $blocker class] {
                representation {
                    if {[dict get $blocker kind] eq "UnprovenRefinement"} {
                        Unsupported [dict get $blocker expr] "refinement evidence" \
                            "the operation needs [core::type::show [dict get $blocker requires]]; named types and evidence are not supported natively"
                    }
                    dict set guards [list [dict get $blocker operation] [dict get $blocker expr]] \
                        [dict get $blocker requires]
                }
                semantic {
                    set kind [dict get $blocker kind]
                    if {$kind in {DynamicBinding UnresolvedControl}} {
                        Unsupported [dict get $blocker expr] $kind [dict get $blocker message]
                    }
                }
            }
        }
        foreach fact [dict get $region facts] {
            if {[dict get $fact kind] eq "known-error" && [dict exists $fact operand]} {
                dict set knownErrors [list [dict get $fact expr] [dict get $fact operand]] \
                    [dict get $fact error]
            }
        }
    }
}

# Local bindings that are cells: some reference to them cannot be proven
# bound when it runs.
proc native::lower::CellBindings {} {
    variable hir
    variable unproven
    set result [dict create]
    dict for {ref b} $unproven {
        if {[dict get [hir::binding $hir $b] kind] eq "local"} {
            dict set result $b 1
        }
    }
    return $result
}

# Blocks compiled as environment-free functions: hir::aot's static blocks
# (every captured binding is bound to a block needing no environment), minus
# those capturing a cell, to a greatest fixpoint.
proc native::lower::EnvlessBlocks {} {
    variable hir
    variable cells
    set envless [hir::aot::StaticBlocks $hir]
    set changed 1
    while {$changed} {
        set changed 0
        foreach e $envless {
            foreach b [hir::get $hir $e captures] {
                if {[dict exists $cells $b] || [hir::aot::BoundBlock $hir $b] ni $envless} {
                    set envless [lsearch -all -inline -not -exact $envless $e]
                    set changed 1
                    break
                }
            }
        }
    }
    return $envless
}

# The bindings closure E stores, in order: its captures, except bindings
# whose value is an environment-free function's constant closure and E's own
# function binding (read through self).
proc native::lower::CaptureList {e} {
    variable hir
    set result {}
    foreach b [hir::get $hir $e captures] {
        switch -- [BindingAccess $b $e] {
            fnvalue - self {}
            default { lappend result $b }
        }
    }
    return $result
}

# How code in the function of block E (or "program") reaches binding B from
# an enclosing invocation: fnvalue, cell, self or value.
proc native::lower::BindingAccess {b e} {
    variable hir
    variable cells
    variable envless
    if {[dict exists $cells $b]} {
        return cell
    }
    set bound [hir::aot::BoundBlock $hir $b]
    if {$bound ne "" && $bound in $envless} {
        return fnvalue
    }
    if {$bound ne "" && $bound eq $e} {
        return self
    }
    return value
}

proc native::lower::FunctionId {region} {
    variable functionIds
    return [dict get $functionIds $region]
}

# ---------------------------------------------------------------------------
# Functions

# Lowers the function of REGION ("program" or a block ExprId). Returns
# {TEXT INFO}.
proc native::lower::Function {region} {
    variable hir
    variable envless
    variable selfTail
    variable captureLists
    set fn [dict create region $region lines {} nreg 0 nlabel 0 \
        locals [dict create] loops [dict create] broken [dict create] calls {}]
    if {$region eq "program"} {
        set name <program>
        set params {}
        set env 0
        set scope [hir::top $hir]
        set body [hir::roots $hir]
    } else {
        set name [hir::aot::BlockName $hir $region]
        set params [hir::get $hir $region params]
        set env [expr {$region ni $envless}]
        set scope [hir::get $hir $region bodyScope]
        set body [hir::get $hir $region body]
    }
    foreach b $params {
        dict set fn locals $b [list reg [NewReg fn]]
    }
    EnterScope fn $scope
    set result [Sequence fn $body]
    if {$result ne "never"} {
        Emit fn "ret $result"
    }
    set pnames [lmap b $params {dict get [hir::binding $hir $b] name}]
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    # pnames: the parameter names as block error messages show them.
    set head "func [FunctionId $region] [Quote $name] params=[llength $params] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures]"
    if {$region ne "program"} {
        append head " @$region"
    }
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap {call block} $selfTail {if {$block ne $region} continue; set call}]]
    set info [dict create id [FunctionId $region] name $name block $region \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls]]
    return [list $text $info]
}

proc native::lower::NewReg {fnVar} {
    upvar 1 $fnVar fn
    set r [dict get $fn nreg]
    dict incr fn nreg
    return %$r
}

proc native::lower::NewLabel {fnVar} {
    upvar 1 $fnVar fn
    set l [dict get $fn nlabel]
    dict incr fn nlabel
    return L$l
}

proc native::lower::Emit {fnVar line {e ""}} {
    upvar 1 $fnVar fn
    if {$e ne ""} {
        append line " @$e"
    }
    dict lappend fn lines "    $line"
}

proc native::lower::EmitLabel {fnVar label} {
    upvar 1 $fnVar fn
    dict lappend fn lines "  label $label"
}

# Emits "%d = RHS" and returns %d.
proc native::lower::Assign {fnVar rhs {e ""}} {
    upvar 1 $fnVar fn
    set r [NewReg fn]
    Emit fn "$r = $rhs" $e
    return $r
}

# Enters HIR scope S: creates the cells of its cell bindings.
proc native::lower::EnterScope {fnVar s} {
    upvar 1 $fnVar fn
    variable hir
    variable cells
    foreach b [dict get $hir scopes $s bindings] {
        if {[dict get [hir::binding $hir $b] kind] eq "local" && [dict exists $cells $b]} {
            dict set fn locals $b [list cell [Assign fn cell]]
        }
    }
}

# ---------------------------------------------------------------------------
# Expressions
#
# Each procedure emits the instructions evaluating an expression and returns
# the register holding its value, or "never" if evaluation cannot complete
# normally (the instructions then end in a terminator).

proc native::lower::Sequence {fnVar exprs} {
    upvar 1 $fnVar fn
    if {$exprs eq ""} {
        return [Assign fn unit]
    }
    foreach e $exprs {
        set result [Expr fn $e]
        if {$result eq "never"} {
            break
        }
    }
    return $result
}

proc native::lower::Expr {fnVar e} {
    upvar 1 $fnVar fn
    variable hir
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const    { set result [Const fn $e $node] }
        ref      { set result [Ref fn $e $node] }
        bind     { set result [Bind fn $e $node] }
        block    { set result [Closure fn $e] }
        call     { set result [Call fn $e $node] }
        if       { set result [If fn $e $node] }
        loop     { set result [Loop fn $e $node] }
        return {
            set value [Expr fn [dict get $node value]]
            if {$value ne "never"} {
                Emit fn "ret $value" $e
            }
            set result never
        }
        break {
            set value ""
            if {[dict get $node value] ne ""} {
                set value [Expr fn [dict get $node value]]
            }
            if {$value ne "never"} {
                lassign [dict get $fn loops [dict get $node target]] head exit resultReg
                if {$value eq ""} {
                    set value [Assign fn unit]
                }
                Emit fn "$resultReg = move $value" $e
                Emit fn "jump $exit" $e
                dict set fn broken [dict get $node target] 1
            }
            set result never
        }
        continue {
            lassign [dict get $fn loops [dict get $node target]] head
            Emit fn "jump $head" $e
            set result never
        }
        ok - error {
            set value [Expr fn [dict get $node value]]
            if {$value eq "never"} {
                return never
            }
            set result [Assign fn "op [expr {[dict get $node kind] eq "ok" ? "mkok" : "mkerror"}] $value" $e]
        }
        default {
            throw {NATIVE INVALID-HIR} "native lowering: unknown HIR expression kind \"[dict get $node kind]\" ($e)"
        }
    }
    if {$result ne "never" && [hir::typeOf $hir $e] eq "never"} {
        # HIR proved that no normal completion reaches past E.
        Emit fn unreachable $e
        return never
    }
    return $result
}

proc native::lower::Const {fnVar e node} {
    upvar 1 $fnVar fn
    set value [dict get $node value]
    switch -- [core::value::kind $value] {
        int  { return [Assign fn "int [core::value::intOf $value]" $e] }
        str  { return [Assign fn "str [Quote [core::value::strOf $value]]" $e] }
        list {
            # (const list {...}): a list of literal elements.
            set items [lmap item [core::value::items $value] {
                if {[core::value::kind $item] eq "int"} {
                    Assign fn "int [core::value::intOf $item]" $e
                } else {
                    Assign fn "str [Quote [core::value::strOf $item]]" $e
                }
            }]
            return [Assign fn "op listnew [join $items { }]" $e]
        }
    }
    throw {NATIVE INVALID-HIR} "native lowering: unexpected constant [core::value::show $value] ($e)"
}

proc native::lower::Ref {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable unproven
    set b [dict get $node binding]
    set name [dict get $node name]
    if {$b eq ""} {
        Emit fn "raise UNBOUND [Quote "unbound name \"$name\""]" $e
        return never
    }
    set binding [hir::binding $hir $b]
    switch -- [dict get $binding kind] {
        root {
            return [RootValue fn $e $binding]
        }
        ambient {
            Unsupported $e "ambient binding" "\"$name\" is looked up in an unknown environment"
        }
    }
    if {[dict get $node init] eq "no"} {
        Emit fn "raise UNBOUND [Quote "name \"$name\" used before its binding"]" $e
        return never
    }
    set access [Access fn $b]
    lassign $access how where
    switch -- $how {
        reg     { return $where }
        fnvalue { return [Assign fn "fnvalue $where" $e] }
        self    { return [Assign fn self $e] }
        cell {
            if {[dict exists $unproven $e]} {
                return [Assign fn "cellcheck $where [Quote [dict get $binding name]]" $e]
            }
            return [Assign fn "cellget $where" $e]
        }
    }
    throw {NATIVE BUG} "native lowering: bad access $access for $b ($e)"
}

# {reg %r} (a register holding the binding's value), {cell %c} (a register
# holding its cell), {fnvalue F} or {self}: how the current function reaches
# binding B, emitting a capture load if needed.
proc native::lower::Access {fnVar b} {
    upvar 1 $fnVar fn
    variable hir
    variable captureLists
    if {[dict exists $fn locals $b]} {
        return [dict get $fn locals $b]
    }
    set region [dict get $fn region]
    set access [BindingAccess $b [expr {$region eq "program" ? "" : $region}]]
    switch -- $access {
        fnvalue {
            return [list fnvalue [FunctionId [hir::aot::BoundBlock $hir $b]]]
        }
        self {
            return [list self]
        }
    }
    if {$region eq "program" || ![dict exists $captureLists $region]} {
        throw {NATIVE BUG} "native lowering: binding $b is not reachable from $region"
    }
    set index [lsearch -exact [dict get $captureLists $region] $b]
    if {$index < 0} {
        throw {NATIVE BUG} "native lowering: $region does not capture $b"
    }
    # Loaded at each use: a use may sit in a branch that does not dominate
    # later uses.
    set r [Assign fn "capture $index"]
    return [list [expr {$access eq "cell" ? "cell" : "reg"}] $r]
}

proc native::lower::RootValue {fnVar e binding} {
    upvar 1 $fnVar fn
    variable natives
    variable usedNatives
    set value [dict get $binding value]
    switch -- [core::value::kind $value] {
        bool   { return [Assign fn "bool [lindex $value 1]" $e] }
        unit   { return [Assign fn unit $e] }
        native {
            set name [core::value::nativeName $value]
            if {![dict exists $natives $name]} {
                Unsupported $e "native $name" "the native \"$name\" has no native implementation"
            }
            if {$name ni $usedNatives} {
                lappend usedNatives $name
            }
            return [Assign fn "native [Quote $name]" $e]
        }
    }
    throw {NATIVE INVALID-HIR} "native lowering: unexpected root value [core::value::show $value] ($e)"
}

proc native::lower::Bind {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    set value [Expr fn [dict get $node value]]
    if {$value eq "never"} {
        return never
    }
    set b [dict get $node binding]
    set name [dict get $node name]
    if {[dict get [hir::binding $hir $b] kind] eq "ambient"} {
        Unsupported $e "ambient binding" "\"$name\" is bound in an unknown environment"
    }
    if {[dict get $node duplicate]} {
        Emit fn "raise DUPLICATE [Quote "duplicate binding \"$name\" in the same lexical scope"]" $e
        return never
    }
    if {[dict exists $fn locals $b] && [lindex [dict get $fn locals $b] 0] eq "cell"} {
        Emit fn "cellset [lindex [dict get $fn locals $b] 1] $value" $e
    } else {
        dict set fn locals $b [list reg $value]
    }
    return $value
}

# Creation of the Block value of block expression E.
proc native::lower::Closure {fnVar e} {
    upvar 1 $fnVar fn
    variable envless
    variable captureLists
    variable pending
    lappend pending $e
    if {$e in $envless} {
        return [Assign fn "fnvalue [FunctionId $e]" $e]
    }
    set values {}
    foreach b [dict get $captureLists $e] {
        lassign [Access fn $b] how where
        switch -- $how {
            reg - cell { lappend values $where }
            fnvalue    { lappend values [Assign fn "fnvalue $where"] }
            self       { lappend values [Assign fn self] }
        }
    }
    return [Assign fn [string trimright "closure [FunctionId $e] [join $values { }]"] $e]
}

# ---------------------------------------------------------------------------
# Calls

proc native::lower::Call {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable selfTail
    variable envless
    variable unproven
    lassign [dict get $node target] targetKind target
    set calleeExpr [dict get $node callee]
    set argExprs [dict get $node args]

    # The callee is evaluated first. A reference to a root native or to an
    # environment-free function needs no code (it cannot fail).
    set callee ""
    set skipCallee [expr {[hir::kind $hir $calleeExpr] eq "ref" && ![dict exists $unproven $calleeExpr]
        && (($targetKind eq "native" && [dict get [hir::binding $hir [hir::get $hir $calleeExpr binding]] kind] eq "root")
            || ($targetKind eq "block" && $target in $envless && [hir::get $hir $calleeExpr init] ne "no"))}]
    if {!$skipCallee} {
        set callee [Expr fn $calleeExpr]
        if {$callee eq "never"} {
            return never
        }
    }
    set argRegs {}
    foreach arg $argExprs {
        set r [Expr fn $arg]
        if {$r eq "never"} {
            return never
        }
        lappend argRegs $r
    }

    switch -- $targetKind {
        native {
            set name [dict get [hir::symbol $hir $target] name]
            return [NativeCall fn $e $node $name $argRegs]
        }
        block {
            set params [hir::get $hir $target params]
            if {[llength $params] != [llength $argRegs]} {
                set pnames [lmap b $params {dict get [hir::binding $hir $b] name}]
                Emit fn "raise ARITY [Quote "block ([join $pnames { }]) expects [llength $params] argument(s), got [llength $argRegs]"]" $e
                return never
            }
            dict lappend fn calls [list direct [FunctionId $target] [dict exists $selfTail $e]]
            if {[dict exists $selfTail $e] && [dict get $fn region] eq $target} {
                if {$target in $envless} {
                    Emit fn [string trimright "tail [join $argRegs { }]"] $e
                } else {
                    Emit fn [string trimright "tailenv $callee [join $argRegs { }]"] $e
                }
                return never
            }
            if {$target in $envless} {
                return [Assign fn [string trimright "call [FunctionId $target] [join $argRegs { }]"] $e]
            }
            return [Assign fn [string trimright "callenv [FunctionId $target] $callee [join $argRegs { }]"] $e]
        }
    }
    dict lappend fn calls [list value]
    return [Assign fn [string trimright "callvalue $callee [join $argRegs { }]"] $e]
}

proc native::lower::NativeCall {fnVar e node name argRegs} {
    upvar 1 $fnVar fn
    variable hir
    variable natives
    variable guards
    variable knownErrors
    set meta [core::native::metadata $name]
    set arity [dict get $meta arity]
    if {$arity ne "*" && $arity != [llength $argRegs]} {
        Emit fn "raise ARITY [Quote "$name expects $arity argument(s), got [llength $argRegs]"]" $e
        return never
    }
    if {![dict exists $natives $name]} {
        Unsupported $e "native $name" "the native \"$name\" has no native implementation"
    }
    dict lappend fn calls [list native $name]
    if {[dict get $node known] ne ""} {
        # A type test HIR decided: the arguments ran, nothing else does.
        return [Assign fn "bool [expr {[dict get $node known] ? "true" : "false"}]" $e]
    }
    set testsType [dict get $meta testsType]
    if {$testsType ne "" && [llength $testsType] > 1 && $name ni {ok? error?}} {
        Unsupported $e "native $name" "type tests of named types need evidence, which is not supported natively"
    }
    set argExprs [dict get $node args]
    foreach arg $argExprs r $argRegs type [dict get $meta paramTypes] {
        if {$type in {"" any}} {
            continue
        }
        set key [list $e $arg]
        if {[dict exists $guards $key]} {
            Emit fn "guard [core::type::base [dict get $guards $key]] $r [Quote $name]" $e
        } elseif {[dict exists $knownErrors $key]} {
            # Statically of another kind: the check always fails.
            Emit fn "guard [core::type::base $type] $r [Quote $name]" $e
        } elseif {![core::type::subtype [hir::types::semantic [hir::typeOf $hir $arg]] $type]
                  && [hir::typeOf $hir $arg] ne "never"} {
            throw {NATIVE BUG} "native lowering: hir::aot reports no check for argument $arg of $name ($e)"
        }
    }
    set impl [dict get $natives $name]
    if {[lindex $impl 0] eq "equality"} {
        lassign $argExprs a b
        set ka [hir::types::kindOf [hir::typeOf $hir $a]]
        set kb [hir::types::kindOf [hir::typeOf $hir $b]]
        set op veq
        if {$ka eq $kb && $ka eq "int"} {
            set op ieq
        } elseif {$ka eq $kb && $ka eq "str"} {
            set op streq
        }
        return [Assign fn "op $op [join $argRegs { }]" $e]
    }
    return [Assign fn [string trimright "op [lindex $impl 1] [join $argRegs { }]"] $e]
}

# The NIR operation implementing native NAME for generic calls.
proc native::lower::NativeImpl {name} {
    variable natives
    set impl [dict get $natives $name]
    return [expr {[lindex $impl 0] eq "equality" ? "veq" : [lindex $impl 1]}]
}

# ---------------------------------------------------------------------------
# Control flow

proc native::lower::If {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable guards
    variable knownErrors
    set condition [dict get $node condition]
    set test [Expr fn $condition]
    if {$test eq "never"} {
        return never
    }
    set key [list $e $condition]
    if {[dict exists $guards $key] || [dict exists $knownErrors $key]} {
        Emit fn "guardbool $test" $e
    } elseif {[hir::types::kindOf [hir::typeOf $hir $condition]] ne "bool"} {
        throw {NATIVE BUG} "native lowering: hir::aot reports no Boolean check for $condition ($e)"
    }
    set then [NewLabel fn]
    set else [NewLabel fn]
    set join [NewLabel fn]
    set result [NewReg fn]
    Emit fn "br $test $then $else" $e
    set joined 0
    foreach {label role} [list $then then $else else] {
        EmitLabel fn $label
        set saved [dict get $fn locals]
        EnterScope fn [dict get $node ${role}Scope]
        set body [dict get $node ${role}Body]
        if {$body ne "" && ![hir::get $hir [lindex $body 0] reachable]} {
            # HIR decided the condition: this branch never runs.
            Emit fn unreachable $e
            set value never
        } else {
            set value [Sequence fn $body]
        }
        dict set fn locals $saved
        if {$value ne "never"} {
            Emit fn "$result = move $value"
            Emit fn "jump $join"
            set joined 1
        }
    }
    if {!$joined} {
        return never
    }
    EmitLabel fn $join
    return $result
}

proc native::lower::Loop {fnVar e node} {
    upvar 1 $fnVar fn
    set head [NewLabel fn]
    set exit [NewLabel fn]
    set result [NewReg fn]
    Emit fn "jump $head" $e
    EmitLabel fn $head
    set saved [dict get $fn locals]
    dict set fn loops $e [list $head $exit $result]
    EnterScope fn [dict get $node bodyScope]
    set value [Sequence fn [dict get $node body]]
    if {$value ne "never"} {
        Emit fn "jump $head" $e
    }
    set used [dict exists $fn broken $e]
    dict unset fn loops $e
    dict set fn locals $saved
    if {!$used} {
        return never
    }
    EmitLabel fn $exit
    return $result
}

# ---------------------------------------------------------------------------
# Diagnostics and text

# Raises {NATIVE UNSUPPORTED} for expression E: WHAT is the unsupported
# operation, DETAIL explains.
proc native::lower::Unsupported {e what detail} {
    variable hir
    set where ""
    if {$e ne "" && [dict exists $hir exprs $e]} {
        set location [hir::aot::Location $hir [hir::get $hir $e origin]]
        if {[dict exists $location line]} {
            set where "[dict get $location file]:[dict get $location line]:[dict get $location column]: "
        } elseif {[dict exists $location ir]} {
            set where "ir {[dict get $location ir]}: "
        }
    }
    throw [list NATIVE UNSUPPORTED $what] "${where}$e: native lowering does not support $what: $detail"
}

# TEXT as a NIR string literal.
proc native::lower::Quote {text} {
    set quoted [string map {\\ \\\\ \" \\\" \n \\n \r \\r \t \\t} $text]
    if {[regexp {[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]} $quoted]} {
        set escaped ""
        foreach char [split $quoted ""] {
            scan $char %c code
            if {$code < 32 || $code == 127} {
                append escaped [format {\u{%x}} $code]
            } else {
                append escaped $char
            }
        }
        set quoted $escaped
    }
    return "\"$quoted\""
}
