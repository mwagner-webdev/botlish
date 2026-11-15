// The timing every Go reference program of bench/bench.tcl shares
// (bench/equivalents/go/*.go, bench/experimental/equivalents/go/*.go): the
// timed loop, here, and the clock it reads, clock_windows.go on Windows and
// clock_other.go everywhere else. bench.tcl copies a program, this file and
// its platform's clock file into a private directory and builds them there:
// go build takes named files from one directory only, and applies no build
// constraint to them, so the platform's file is chosen by bench.tcl.

package main

// bestMicros runs WORK RUNS times, one call per timed run -- as every other
// column of bench.tcl is timed: the Botlish backends and the Rust and Python
// reference programs -- and returns the fastest run in microseconds.
func bestMicros(runs int, work func()) float64 {
	best := -1.0
	for i := 0; i < runs; i++ {
		t0 := clockNow()
		work()
		us := microsSince(t0)
		if best < 0 || us < best {
			best = us
		}
	}
	return best
}
