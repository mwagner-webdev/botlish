// Go equivalent of bench/fib.bot: naive recursive Fibonacci.
//
// Invoked by bench/bench.tcl, with the protocol every equivalent shares:
// "--runs N" (default 5) among the program's own arguments; one untimed
// call, then N timed calls; printed, "value: V" and "best_us: F", the
// fastest call in microseconds. Every Go equivalent is built with the timing
// in bench/equivalents/go/clock (bestMicros: clock/best.go says how).
package main

import (
    "fmt"
    "os"
    "strconv"
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
