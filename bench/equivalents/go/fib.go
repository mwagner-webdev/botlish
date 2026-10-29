package main

import (
    "fmt"
    "os"
    "strconv"
    "time"
)

func fib(n int64) int64 {
    if n < 2 {
        return n
    }
    return fib(n-1) + fib(n-2)
}

func parseArgs() (int, []string) {
    runs := 5
    var positional []string
    for i := 1; i < len(os.Args); i++ {
        if os.Args[i] == "--runs" {
            i++
            if i >= len(os.Args) {
                panic("--runs needs a value")
            }
            v, err := strconv.Atoi(os.Args[i])
            if err != nil {
                panic("--runs must be an integer")
            }
            runs = v
            continue
        }
        positional = append(positional, os.Args[i])
    }
    return runs, positional
}

func main() {
    runs, positional := parseArgs()
    n := int64(22)
    if len(positional) > 0 {
        v, err := strconv.ParseInt(positional[0], 10, 64)
        if err != nil {
            panic("n must be an integer")
        }
        n = v
    }

    fib(n)
    var value int64
    best := bestMicros(runs, func() {
        value = fib(n)
    })

    fmt.Printf("value: %d\n", value)
    fmt.Printf("best_us: %.3f\n", best)
}

// bestMicros runs WORK RUNS times and returns its best time in
// microseconds. Where the monotonic clock is fine (nanoseconds on Linux) a
// timed run is one call, as in every equivalent. On Windows Go's clock is
// the kernel's interrupt time, which advances in steps of up to 15.6 ms, so
// a call shorter than a step would read as no time at all: there each timed
// run repeats WORK until at least 50 steps have passed and counts the
// average call.
func bestMicros(runs int, work func()) float64 {
    step := clockStep()
    best := -1.0
    for i := 0; i < runs; i++ {
        calls := 0
        t0 := time.Now()
        elapsed := time.Duration(0)
        for calls == 0 || (step > time.Microsecond && elapsed < 50*step) {
            work()
            calls++
            elapsed = time.Since(t0)
        }
        us := float64(elapsed) / float64(time.Microsecond) / float64(calls)
        if best < 0 || us < best {
            best = us
        }
    }
    return best
}

// clockStep is the smallest advance of the monotonic clock seen between
// two readings.
func clockStep() time.Duration {
    smallest := time.Duration(-1)
    for i := 0; i < 3; i++ {
        t0 := time.Now()
        d := time.Since(t0)
        for d == 0 {
            d = time.Since(t0)
        }
        if smallest < 0 || d < smallest {
            smallest = d
        }
    }
    return smallest
}
