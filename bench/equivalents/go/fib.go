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
    best := float64(1<<63 - 1)
    var value int64
    for i := 0; i < runs; i++ {
        t0 := time.Now()
        value = fib(n)
        dt := float64(time.Since(t0)) / float64(time.Microsecond)
        if dt < best {
            best = dt
        }
    }

    fmt.Printf("value: %d\n", value)
    fmt.Printf("best_us: %.3f\n", best)
}
