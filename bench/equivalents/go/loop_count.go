package main

import (
    "fmt"
    "os"
    "strconv"
    "time"
)

func work(i int64) int64 {
    for {
        a := i * 3
        b := a + 7
        if b >= 0 {
            return b - a
        }
    }
}

func drive(i int64, total int64) int64 {
    if i <= 0 {
        return total
    }
    return drive(i-1, total+work(i))
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
    i0 := int64(500)
    total0 := int64(0)
    if len(positional) > 0 {
        v, err := strconv.ParseInt(positional[0], 10, 64)
        if err != nil {
            panic("i must be an integer")
        }
        i0 = v
    }
    if len(positional) > 1 {
        v, err := strconv.ParseInt(positional[1], 10, 64)
        if err != nil {
            panic("total must be an integer")
        }
        total0 = v
    }

    drive(i0, total0)
    best := float64(1<<63 - 1)
    var value int64
    for i := 0; i < runs; i++ {
        t0 := time.Now()
        value = drive(i0, total0)
        dt := float64(time.Since(t0)) / float64(time.Microsecond)
        if dt < best {
            best = dt
        }
    }

    fmt.Printf("value: %d\n", value)
    fmt.Printf("best_us: %.3f\n", best)
}
