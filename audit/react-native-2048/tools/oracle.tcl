# oracle.tcl -- the 2048 oracle of BOTLISH-REACT-NATIVE-2048-PACKAGE-
# MILESTONE-1.md: the snapshots the Botlish interpreter computes for a seed
# and a sequence of moves, from examples/react-native/2048/game.bot and the
# unchanged engine (examples/games/2048/game2048.bot), one per line -- the
# new game's, then one per move. Every other run (the host harness, the
# Android self-test, the hook, the played UI) is compared with it.
#
#   tclsh9.0 audit/react-native-2048/tools/oracle.tcl SEED DIRECTIONS ?BACKEND?
#
# DIRECTIONS is a string of 0 (left), 1 (right), 2 (up), 3 (down); BACKEND
# is interp (the default) or another backend main.tcl runs.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
lassign $argv seed directions backend
if {$backend eq ""} { set backend interp }
if {![string is entier -strict $seed] || ![regexp {^[0-3]*$} $directions]} {
    puts stderr "usage: oracle.tcl SEED DIRECTIONS ?BACKEND?"
    exit 2
}
set dir [file tempdir]
try {
    file copy [file join $root examples react-native 2048 game.bot] $dir
    file copy [file join $root examples games 2048 game2048.bot] $dir
    set list [join [split $directions ""] ", "]
    set f [open [file join $dir oracle.bot] w]
    puts $f [string map [list @SEED@ $seed @DIRECTIONS@ $list] {import std::list
import game

fn play(seed: int, directions: List[int]) -> List[str] errors game::InvalidSnapshot, game::InvalidDirection:
    start = game::new_game(seed)
    fold d in directions with intermediate acc [start]:
        acc.append(acc.get(std::list::length(acc) - 1, start).move(d))

states = play(@SEED@, [@DIRECTIONS@]):
    on game::InvalidSnapshot:
        ["invalid snapshot"]
    on game::InvalidDirection:
        ["invalid direction"]
states}]
    close $f
    set out [exec [info nameofexecutable] [file join $root main.tcl] -warnings off -backend $backend [file join $dir oracle.bot] 2>@stderr]
    if {![regexp {value: (\[.*\])} $out -> value]} {
        puts stderr "oracle: no value in the run's output:\n$out"
        exit 1
    }
    foreach {- s} [regexp -all -inline {"([^"]*)"} $value] {
        puts $s
    }
} finally {
    file delete -force $dir
}
