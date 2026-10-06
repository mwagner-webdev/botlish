# fuzz.tcl -- focused fuzzer for PROVES-NAMING and the global warning modes
# (WARNINGS-PROVES-NAMING.md, "Fuzzing").
#
#   tclsh9.0 audit/proves-naming/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED?
#   tclsh9.0 audit/proves-naming/tools/fuzz.tcl -show SEED
#     (prints the program SEED generates, its module, its prediction and the
#     renamed program)
#
# Each seed generates a program (fuzz.bot) and sometimes a module (pnm.bot,
# in a private library directory) of functions whose naming facts are *known
# by construction*. Every function gets a unique stem (its index is part of
# it), and a name drawn from a pool that is conforming or violating by
# construction:
#
#   predicate   a proves function, one `v: str` parameter, `-> bool`;
#               sometimes with flags, sometimes fallible (`errors Bad`)
#                 conforming  STEM?
#                 violating   STEM, is_STEM, validate_STEM, validate
#   validator   a proves function, one `v: str` parameter, `-> unit`;
#               fallible (`errors Bad`, one guarded fail) or infallible
#                 conforming  validate_STEM, validate, validate_ (the empty-
#                             suffix sharp edge)
#                 violating   check_STEM, STEM, STEM?, Validate_STEM,
#                             VALIDATE_STEM, validateSTEM, validator_STEM
#   twin        a function of either shape *without* proves, named from
#               either pool (always silent: the scope guard)
#   wrong shape a proves function with two or three ordinary parameters,
#               bool or unit, named from either pool (always silent)
#
# Each function is placed at the top level, nested in a wrapper function
# (sometimes a closure over the wrapper's parameter), in the module (proving
# the module's own refinement; called qualified), or -- the hygiene case --
# nested in a wrapper after an earlier reference to a top-level non-proves
# function of the *same* name, so hygiene renames the nested binding (NAME#N)
# and only its written name can be checked. The bare `validate` and
# `validate_` are used at most once per program (the module included: a
# method call `s.validate()` with both `validate` and `pnm::validate` visible
# is ambiguous), so names are collision-free by construction. `x?y` does not lex (R2A2), so it
# is not generated.
#
# Every call is written so that no other warning code can fire: one-argument
# calls (functional or method syntax, a flag where the function has one),
# method syntax for the wrong-shape functions, one fail per validator, one
# exit per predicate. A driver per function calls it twice and uses the proof
# where the shape makes one (a predicate's true edge, a validator's normal
# completion), so the renamed program must still type-check. About a third of
# the programs are silent by construction (every proves function in shape is
# named conformingly).
#
# The oracle is the construction: a proves function of one ordinary
# parameter (flags do not count) and result bool or unit whose name was drawn
# from the violating pool is predicted as {FILE LINE COL NAME KIND}, the
# anchor its `fn`. For every program it checks
#
#   default   compiles; the PROVES-NAMING warnings are exactly the prediction
#             (a missed or mislocated one fails; an unpredicted one is
#             printed as EXTRA and counted, and the summary must show 0; a
#             function reported twice fails); any other code fails
#   off       compiles; no warning, no pass ran (stats counter, execution
#             trace on the pass), and the HIR equals default's without its
#             side table
#   error     rejected with {CORE SEMANTIC PROVES-NAMING} iff a warning is
#             predicted; compiles otherwise
#
# and the rename law: every predicted function and all its call sites are
# renamed mechanically -- a predicate f -> f?, a validator f -> validate_f
# (the canonical mechanical rewrite; the bare `validate` would conform too,
# which is why the message never suggests a name) -- and the renamed program
# must compile with no diagnostic and no warning of any code, have the
# identical native IR (specialized and generic) up to the labels of the
# renamed functions (NIR names a function by its spelling, `func N "NAME"`:
# each renamed function's label must change from exactly its old name to
# exactly its new one, and nothing else may differ), and evaluate to the
# identical value on the reference interpreter. A law failure is a fuzzer
# failure.
#
# Exits non-zero on any failure.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set show ""
if {[lindex $argv 0] eq "-show"} {
    set show [lindex $argv 1]
    set argv {}
}
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 300}]
set first [expr {[llength $argv] > 1 ? [lindex $argv 1] : 1}]

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc chance {p} {
    return [expr {rand() < $p}]
}

proc census {key {n 1}} {
    dict incr ::census $key $n
}

set ::stems {email path query token host port user mail}

# A name for a function of SHAPE (predicate validator) and CONFORMING (1 0)
# with stem STEM. `validate` and `validate_` are taken at most once per
# program, module included (USEDVAR: a dict of the bare names taken): a
# method-syntax call of a name both the program and the imported module
# define is ambiguous.
proc nameFor {shape conforming stem usedVar} {
    upvar 1 $usedVar used
    if {$shape eq "predicate"} {
        if {$conforming} {
            return $stem?
        }
        set pool [list $stem is_$stem validate_$stem]
        if {![dict exists $used validate]} {
            lappend pool validate
        }
    } else {
        if {$conforming} {
            set pool [list validate_$stem validate_$stem validate_$stem]
            foreach bare {validate validate_} {
                if {![dict exists $used $bare]} {
                    lappend pool $bare
                }
            }
        } else {
            set pool [list check_$stem $stem $stem? Validate_$stem VALIDATE_$stem validate$stem validator_$stem]
        }
    }
    set name [pick $pool]
    if {$name in {validate validate_}} {
        dict set used $name 1
    }
    return $name
}

# The mechanical rename of a reported function of SHAPE named NAME.
proc renamed {shape name} {
    return [expr {$shape eq "predicate" ? "$name?" : "validate_$name"}]
}

# Generates the program of SEED. Returns a dict:
#   main      entry lines (with %N<i>% name placeholders)
#   module    module lines ("" without a module)
#   names     i -> name as generated
#   renames   i -> the renamed name (predicted functions only)
#   labels    {OLD NEW} NIR label pairs of the renamed functions
#   predicted sorted {FILE LINE COL NAME KIND}
proc generate {seed} {
    expr {srand($seed)}
    set quiet [expr {rand() < 0.33}]
    set names [dict create]
    set renames [dict create]
    set labels {}
    set predicted {}
    set used [dict create]
    # Each function: {i placement shape role lines driver}, lines and driver
    # templates.
    set top {}
    set wrappers {}
    set moduleFns {}
    set drivers {}
    set calls {}
    set count [expr {2 + int(rand() * 6)}]
    set useModule [chance 0.4]
    for {set i 0} {$i < $count} {incr i} {
        set stem [pick $::stems]$i
        set role [pick {proves proves proves twin wrong}]
        set shape [pick {predicate validator}]
        if {[info exists ::env(PN_FUZZ_PREDICATES_ONLY)]} { set shape predicate }
        set placement [pick {top top nested closure hygiene module}]
        if {$placement eq "module" && !$useModule} {
            set placement top
        }
        if {$role ne "proves" && $placement eq "hygiene"} {
            set placement nested
        }
        set conforming [expr {$quiet || [chance 0.5]}]
        if {$role eq "proves"} {
            set name [nameFor $shape $conforming $stem used]
        } else {
            set name [nameFor $shape [chance 0.5] $stem used]
        }
        dict set names $i $name
        set N "%N$i%"
        set R [expr {$placement eq "module" ? "M" : "E"}]
        set err [expr {$placement eq "module" ? "MBad" : "Bad"}]
        set need [expr {$placement eq "module" ? "pnm::needM" : "needE"}]
        set callee [expr {$placement eq "module" ? "pnm::$N" : $N}]
        set flags [expr {$role eq "proves" && $shape eq "predicate" && [chance 0.25]}]
        set fallible [expr {$role eq "proves" && ($shape eq "validator" ? [chance 0.7] : [chance 0.2])}]
        set ind [expr {$placement in {nested closure hygiene} ? "    " : ""}]
        set key [expr {$placement eq "closure" ? "s" : "\"k$i\""}]
        # The declaration.
        set decl {}
        switch -- $role {
            proves {
                set params [expr {$flags ? "v: str, flags :strict" : "v: str"}]
                set result [expr {$shape eq "predicate" ? "bool" : "unit"}]
                set errors [expr {$fallible ? " errors $err" : ""}]
                lappend decl "${ind}fn $N\($params) -> $result proves v: $R$errors:"
                if {$fallible} {
                    # One guarded fail: a predicate fails on the empty
                    # string, a validator on its key.
                    set bad [expr {$shape eq "validator" ? $key : "\"\""}]
                    lappend decl "$ind    if v == $bad:" "$ind        fail $err"
                }
                if {$shape eq "predicate"} {
                    lappend decl [expr {$flags ? "$ind    strict or v == $key" : "$ind    v == $key"}]
                } else {
                    lappend decl "$ind    unit"
                }
                census [expr {$conforming ? "conforming" : "violating"}]$shape
                if {!$conforming} {
                    dict set renames $i [renamed $shape $name]
                    set label [expr {$placement eq "module" ? "pnm::" : ""}]
                    lappend labels [list $label$name $label[renamed $shape $name]]
                }
            }
            twin {
                if {$shape eq "predicate"} {
                    lappend decl "${ind}fn $N\(v: str) -> bool:" "$ind    v == $key"
                } else {
                    lappend decl "${ind}fn $N\(v: str) -> unit:" "$ind    unit"
                }
                census twin$shape
            }
            wrong {
                set arity [pick {2 2 3}]
                set params [join [lrange {a b c} 0 [expr {$arity - 1}]] ": str, "]
                set result [expr {$shape eq "predicate" ? "bool" : "unit"}]
                lappend decl "${ind}fn $N\($params: str) -> $result proves [pick [lrange {a b c} 0 [expr {$arity - 1}]]]: $R:"
                lappend decl [expr {$shape eq "predicate" ? "$ind    a == b" : "$ind    unit"}]
                census wrong$shape
            }
        }
        # The use: a body that calls the function on s and returns an int,
        # using the proof where there is one.
        set arg [expr {$flags && [chance 0.5] ? "s, :strict" : "s"}]
        set call [expr {$placement ne "module" && [chance 0.4]
            ? "s.$N\([expr {$arg eq "s" ? "" : ":strict"}])" : "$callee\($arg)"}]
        set use {}
        switch -- $role/$shape {
            proves/predicate {
                if {$fallible} {
                    lappend use "r = $call:" "    on $err:" "        false" "if r:" "    $need\(s)" "else:" "    0"
                } else {
                    lappend use "if $call:" "    $need\(s)" "else:" "    0"
                }
            }
            proves/validator {
                if {$fallible} {
                    lappend use "$call:" "    on $err:" "        return 0" "$need\(s)"
                } else {
                    lappend use "$call" "$need\(s)"
                }
            }
            twin/predicate {
                lappend use "if $call:" "    1" "else:" "    0"
            }
            twin/validator {
                lappend use "$call" "3"
            }
            wrong/predicate - wrong/validator {
                set rest [lrange [list {"x"} {"y"}] 0 [expr {$arity - 2}]]
                # Method syntax: a functional call of a two-parameter
                # function is METHOD-ELIGIBLE (a module member's too, pnm
                # being imported).
                set wcall "s.$N\([join $rest {, }])"
                if {$shape eq "predicate"} {
                    lappend use "if $wcall:" "    1" "else:" "    0"
                } else {
                    lappend use "$wcall" "4"
                }
            }
        }
        set predictedHere [expr {$role eq "proves" && !$conforming}]
        switch -- $placement {
            top {
                lappend top $decl
                lappend drivers [list d$i [concat [list "fn d$i\(s: str) -> int:"] [lmap l $use {string cat "    " $l}]]]
                set anchorFile fuzz.bot
            }
            module {
                lappend moduleFns $decl
                lappend drivers [list d$i [concat [list "fn d$i\(s: str) -> int:"] [lmap l $use {string cat "    " $l}]]]
                set anchorFile pnm.bot
                census module
            }
            nested - closure {
                lappend wrappers [list w$i [concat [list "fn w$i\(s: str) -> int:"] $decl [lmap l $use {string cat "    " $l}]]]
                set anchorFile fuzz.bot
                census $placement
            }
            hygiene {
                # A top-level non-proves function of the same name, referenced
                # before the nested declaration: hygiene renames the nested
                # binding NAME#N.
                set j "t$i"
                dict set names $j $name
                set T "%N$j%"
                if {$shape eq "predicate"} {
                    lappend top [list "fn $T\(v: str) -> bool:" "    v == \"t\""]
                    set early "early = $T\(s)"
                } else {
                    lappend top [list "fn $T\(v: str) -> unit:" "    unit"]
                    set early "early = $T\(s)"
                }
                lappend wrappers [list w$i [concat [list "fn w$i\(s: str) -> int:" "    $early"] $decl [lmap l $use {string cat "    " $l}]]]
                set anchorFile fuzz.bot
                census hygiene
            }
        }
        if {$predictedHere} {
            lappend calls [list $i $anchorFile [expr {$ind eq "" ? 1 : 5}] $name $shape]
        }
    }
    # Layout. The anchor line of each predicted function is found by its
    # declaration line in the rendered text (its placeholder is unique on
    # its `fn` line).
    set main {}
    if {$moduleFns ne ""} {
        lappend main "import pnm"
    }
    lappend main "refined type E = str" "error Bad" "fn needE(v: E) -> int:" "    1"
    foreach decl $top {
        lappend main {*}$decl
    }
    set results {}
    foreach w $wrappers {
        lappend main {*}[lindex $w 1]
        lappend results "[lindex $w 0]\(\"k[string range [lindex $w 0] 1 end]\")" "[lindex $w 0]\(\"x\")" "[lindex $w 0]\(\"\")"
    }
    foreach d $drivers {
        lappend main {*}[lindex $d 1]
        lappend results "[lindex $d 0]\(\"k[string range [lindex $d 0] 1 end]\")" "[lindex $d 0]\(\"x\")" "[lindex $d 0]\(\"\")"
    }
    lappend main "\[[join $results {, }]\]"
    set module {}
    if {$moduleFns ne ""} {
        lappend module "refined type M = str" "error MBad" "fn needM(v: M) -> int:" "    2"
        foreach decl $moduleFns {
            lappend module {*}$decl
        }
    }
    foreach c $calls {
        lassign $c i file col name shape
        set lines [expr {$file eq "pnm.bot" ? $module : $main}]
        set line [lsearch -glob $lines "*fn %N$i%(*"]
        lappend predicted [list $file [expr {$line + 1}] $col $name $shape]
    }
    if {$predicted eq ""} {
        census silentPrograms
    }
    return [dict create main $main module $module names $names renames $renames labels $labels \
        predicted [lsort -dictionary $predicted]]
}

# The text of LINES with every placeholder %N<i>% replaced by NAMES's name i.
proc render {lines names} {
    set map {}
    dict for {i name} $names {
        lappend map "%N$i%" $name
    }
    return [string map $map [join $lines \n]]
}

# Writes the module text MODULE (or removes the module) in the private
# library directory.
proc writeModule {module} {
    set path [file join $::core::libraryDir pnm.bot]
    if {$module eq ""} {
        file delete -force $path
        return
    }
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $module
    close $channel
}

proc compileMode {source mode} {
    return [surface::compile $source fuzz.bot -warnings $mode -warning-channel ""]
}

# {FILE LINE COL NAME KIND} of each PROVES-NAMING warning of HIR.
proc namingOf {hir} {
    set result {}
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "PROVES-NAMING"} continue
        set at [lrange [dict get $w primary] 2 end]
        set file [file tail [lindex [split [hir::originLocation $hir [dict get $w primary]] :] 0]]
        lappend result [list $file [dict get $at line] [dict get $at column] \
            [dict get $w data functionName] [dict get $w data kind]]
    }
    return [lsort -dictionary $result]
}

proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v]} {
        return [list error $v]
    }
    return $v
}

# NIR text with every function label replaced by its position: the labels
# of BEFORE's and AFTER's functions as {OLD NEW} pairs where they differ,
# and whether everything else is identical.
proc nirDiff {before after} {
    set strip {func ([0-9]+) "([^"]*)"}
    set a [regsub -all -line $strip $before {func \1 "-"}]
    set b [regsub -all -line $strip $after {func \1 "-"}]
    set la [regexp -all -inline -line $strip $before]
    set lb [regexp -all -inline -line $strip $after]
    set pairs {}
    foreach {- ia na} $la {- ib nb} $lb {
        if {$na ne $nb} {
            lappend pairs [list [regsub {<.*>$} $na {}] [regsub {<.*>$} $nb {}]]
        }
    }
    return [list [expr {$a eq $b}] [lsort -unique $pairs]]
}

set ::libraryDir [file tempdir proves-naming-fuzz]
foreach entry [glob -nocomplain -directory $::core::libraryDir *] {
    file copy -force $entry $::libraryDir
}
set ::core::libraryDir $::libraryDir

if {$show ne ""} {
    set g [generate $show]
    puts "[render [dict get $g main] [dict get $g names]]"
    if {[dict get $g module] ne ""} {
        puts "--- pnm.bot:\n[render [dict get $g module] [dict get $g names]]"
    }
    puts "--- predicted (file line col name kind):\n[join [dict get $g predicted] \n]"
    puts "--- renames: [dict get $g renames]"
    file delete -force $::libraryDir
    exit 0
}

set ::census [dict create]
set failures 0
set extras 0
set warned 0
set clean 0
set renamedFunctions 0
set predictedTotal 0
set lawFailures 0
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    set g [generate $seed]
    set names [dict get $g names]
    set predicted [dict get $g predicted]
    incr predictedTotal [llength $predicted]
    set source [render [dict get $g main] $names]
    writeModule [render [dict get $g module] $names]
    set problems {}
    if {[catch {compileMode $source default} hir options]} {
        lappend problems "default mode did not compile: $hir"
    } else {
        foreach w [hir::warnings::of $hir] {
            if {[dict get $w code] ne "PROVES-NAMING"} {
                lappend problems "unexpected code [dict get $w code]: [dict get $w message]"
            }
        }
        set actual [namingOf $hir]
        foreach p $predicted {
            if {$p ni $actual} {
                lappend problems "MISSED predicted warning $p (actual: $actual)"
            }
        }
        if {[llength $actual] != [llength [lsort -unique $actual]]} {
            lappend problems "a function was reported more than once: $actual"
        }
        foreach a $actual {
            if {$a ni $predicted} {
                puts "EXTRA seed $seed: warning $a is not predicted:\n$source"
                incr extras
            }
        }
        # off: compiles, silently, runs no warning pass, same HIR.
        hir::warnings::resetStats
        set ::passCalls 0
        trace add execution hir::warnings::ProvesNaming enter {apply {{args} {incr ::passCalls}}}
        try {
            set offFailed [catch {compileMode $source off} off]
        } finally {
            trace remove execution hir::warnings::ProvesNaming enter {apply {{args} {incr ::passCalls}}}
        }
        if {$offFailed} {
            lappend problems "off mode did not compile: $off"
        } elseif {[hir::warnings::of $off] ne "" || [hir::warnings::stats] ne "" || $::passCalls != 0} {
            lappend problems "off mode ran or reported warnings"
        } elseif {$off ne [dict remove $hir warnings]} {
            lappend problems "HIR differs between off and default"
        }
        # error: rejected with this code iff a warning is predicted.
        set rejected [catch {compileMode $source error} message options]
        if {$rejected} {
            if {$predicted eq ""} {
                lappend problems "error mode rejected a program with no predicted warning: $message"
            } elseif {[dict get $options -errorcode] ne {CORE SEMANTIC PROVES-NAMING}} {
                lappend problems "error mode rejected with [dict get $options -errorcode]: $message"
            }
        } elseif {$predicted ne ""} {
            lappend problems "error mode accepted a program with a predicted warning"
        }
        # The rename law.
        if {$predicted ne ""} {
            set newNames [dict merge $names [dict get $g renames]]
            set renamedSource [render [dict get $g main] $newNames]
            writeModule [render [dict get $g module] $newNames]
            set law {}
            if {[catch {compileMode $renamedSource default} rhir]} {
                lappend law "the renamed program does not compile: $rhir"
            } else {
                if {[hir::diagnostics $rhir] ne "" || [hir::warnings::of $rhir] ne ""} {
                    lappend law "the renamed program has diagnostics or warnings: [hir::diagnostics $rhir] [lmap w [hir::warnings::of $rhir] {dict get $w message}]"
                }
                foreach options {{} {-specialize 0}} {
                    lassign [nirDiff [native::nir $hir {*}$options] [native::nir $rhir {*}$options]] same pairs
                    if {!$same} {
                        lappend law "native IR ($options) differs beyond function labels"
                    }
                    set expected [lsort -unique [dict get $g labels]]
                    if {$pairs ne $expected} {
                        lappend law "native IR ($options) labels changed $pairs, expected $expected"
                    }
                }
                set before [valueOf $hir]
                set after [valueOf $rhir]
                if {$before ne $after} {
                    lappend law "values differ: $before vs $after"
                }
            }
            incr renamedFunctions [dict size [dict get $g renames]]
            if {$law ne ""} {
                incr lawFailures
                lappend problems "RENAME LAW: [join $law {; }]\n--- renamed:\n$renamedSource"
            }
        }
        if {$actual eq ""} { incr clean } else { incr warned }
    }
    if {$problems ne ""} {
        incr failures
        set module [render [dict get $g module] $names]
        puts "FAIL seed $seed:\n[join $problems \n]\n--- source:\n$source[expr {$module eq "" ? "" : "\n--- pnm.bot:\n$module"}]"
    }
}
file delete -force $::libraryDir
set c $::census
proc get {c key} {
    return [expr {[dict exists $c $key] ? [dict get $c $key] : 0}]
}
puts "seeds $seeds (from $first): $warned with warnings, $clean without; failures $failures; extra warnings $extras; renames $renamedFunctions of $predictedTotal; law failures $lawFailures; predicates [get $c conformingpredicate] conforming / [get $c violatingpredicate] violating, validators [get $c conformingvalidator] conforming / [get $c violatingvalidator] violating, twins [expr {[get $c twinpredicate] + [get $c twinvalidator]}], wrong shapes [expr {[get $c wrongpredicate] + [get $c wrongvalidator]}], nested [get $c nested], closures [get $c closure], hygiene [get $c hygiene], module [get $c module], only-silent programs [get $c silentPrograms]"
exit [expr {$failures > 0 || $extras > 0}]
