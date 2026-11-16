# oracle.tcl -- the 2048 oracle of RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-
# MILESTONE-1.md: the snapshots the Botlish interpreter computes with the
# package game2048_play (examples/games/2048/game2048_play.bot over the
# unchanged engine) for a seed and a sequence of moves, one per line -- the
# new game's, then one per move. The SDL3 application's runs (its "2048:
# new" and "2048: move D SNAPSHOT" lines, on Linux and on Android) are
# compared with it, as the React Native application's are with
# audit/react-native-2048/tools/oracle.tcl.
#
#   tclsh9.0 audit/android-sdl3-2048/tools/oracle.tcl SEED DIRECTIONS ?BACKEND?
#   tclsh9.0 audit/android-sdl3-2048/tools/oracle.tcl -from SNAPSHOT DIRECTIONS ?BACKEND?
#
# -from starts from a snapshot (checked by game2048_play, as a restored
# save is) instead of a new game.
#
# DIRECTIONS is a string of 0 (left), 1 (right), 2 (up), 3 (down); BACKEND
# is interp (the default) or another backend main.tcl runs.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set from ""
if {[lindex $argv 0] eq "-from"} {
    set from [lindex $argv 1]
    set argv [list 0 {*}[lrange $argv 2 end]]
}
lassign $argv seed directions backend
if {$backend eq ""} { set backend interp }
if {![string is entier -strict $seed] || ![regexp {^[0-3]*$} $directions] || ![regexp {^[0-9/ ]*$} $from]} {
    puts stderr "usage: oracle.tcl SEED DIRECTIONS ?BACKEND?"
    exit 2
}
set dir [file tempdir]
try {
    file copy [file join $root examples games 2048 game2048.bot] $dir
    file copy [file join $root examples games 2048 game2048_play.bot] $dir
    set list [join [split $directions ""] ", "]
    set f [open [file join $dir oracle.bot] w]
    set start [expr {$from eq "" ? "game2048_play::start(seed)" : "game2048_play::played(\"$from\")"}]
    puts $f [string map [list @SEED@ $seed @DIRECTIONS@ $list @START@ $start] {import std::list
import game2048_play

fn play(seed: int, directions: List[int]) -> List[str] errors game2048_play::InvalidDirection, game2048_play::InvalidSnapshot:
    start = @START@
    games = fold d in directions with intermediate acc [start]:
        acc.append(acc.get(std::list::length(acc) - 1, start).moved(game2048_play::direction(d)))
    loop g in games:
        game2048_play::snapshot(g)

states = play(@SEED@, [@DIRECTIONS@]):
    on game2048_play::InvalidDirection:
        ["invalid direction"]
    on game2048_play::InvalidSnapshot:
        ["invalid snapshot"]
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
