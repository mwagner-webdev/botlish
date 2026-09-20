package main

import (
    "fmt"
    "os"
    "strconv"
    "time"
)

func sumRefined(n int64, acc int64) int64 {
    if n == 0 {
        return acc
    }
    step := func(x int64) int64 { return x + n }
    return sumRefined(n-1, step(acc))
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
    n0 := int64(400)
    acc0 := int64(0)
    if len(positional) > 0 {
        v, err := strconv.ParseInt(positional[0], 10, 64)
        if err != nil {
            panic("n must be an integer")
        }
        n0 = v
    }
    if len(positional) > 1 {
        v, err := strconv.ParseInt(positional[1], 10, 64)
        if err != nil {
            panic("acc must be an integer")
        }
        acc0 = v
    }

    sumRefined(n0, acc0)
    best := float64(1<<63 - 1)
    var value int64
    for i := 0; i < runs; i++ {
        t0 := time.Now()
        value = sumRefined(n0, acc0)
        dt := float64(time.Since(t0)) / float64(time.Microsecond)
        if dt < best {
            best = dt
        }
    }

    fmt.Printf("value: %d\n", value)
    fmt.Printf("best_us: %.3f\n", best)
}
