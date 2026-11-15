//go:build !windows

// The clock of bench/bench.tcl's Go reference programs everywhere but
// Windows (best.go): Go's monotonic clock, which counts nanoseconds on Linux
// and macOS.

package main

import "time"

type clockStamp = time.Time

func clockNow() clockStamp {
	return time.Now()
}

func microsSince(t0 clockStamp) float64 {
	return float64(time.Since(t0)) / float64(time.Microsecond)
}
