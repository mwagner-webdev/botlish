package main

import (
    "fmt"
    "os"
    "strconv"
    "strings"
    "time"
    "unicode"
)

func tclAlpha(r rune) bool {
    return unicode.IsLetter(r)
}

func tclAlnum(r rune) bool {
    return unicode.IsLetter(r) || unicode.IsDigit(r)
}

func isLocalChar(r rune) bool {
    return tclAlnum(r) || strings.ContainsRune("._%+-", r)
}

func isLabelChar(r rune) bool {
    return tclAlnum(r) || r == '-'
}

func emailish(s string) bool {
    runes := []rune(s)
    n := len(runes)
    i := 0
    localStart := i
    for i < n && isLocalChar(runes[i]) {
        i++
    }
    if i == localStart {
        return false
    }
    if i >= n || runes[i] != '@' {
        return false
    }
    i++

    for {
        labelStart := i
        for i < n && isLabelChar(runes[i]) {
            i++
        }
        if i == labelStart {
            return false
        }
        if i >= n || runes[i] != '.' {
            return false
        }
        i++

        j := i
        for j < n && tclAlpha(runes[j]) {
            j++
        }
        if j == n && j-i >= 2 {
            return true
        }
        // Continue scanning the next domain label.
        i = j
    }
}

type UriQueryValue string

func uriQueryValue(q UriQueryValue) bool {
    return true
}

func uriEscape(s string) UriQueryValue {
    var out strings.Builder
    for _, r := range s {
        if (r >= 'A' && r <= 'Z') || (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') || r == '.' || r == '_' || r == '~' || r == '-' {
            out.WriteRune(r)
        } else {
            for _, b := range []byte(string(r)) {
                fmt.Fprintf(&out, "%%%02X", b)
            }
        }
    }
    return UriQueryValue(out.String())
}

func check(n int64, acc int64, s string, q UriQueryValue) int64 {
    if n <= 0 {
        return acc
    }
    var hit int64
    if emailish(s) {
        if emailish(s) {
            if uriQueryValue(q) {
                hit = 1
            } else {
                hit = 0
            }
        } else {
            hit = 0
        }
    } else {
        hit = 0
    }
    return check(n-1, acc+hit, s, q)
}

func runOnce(n0 int64, s1 string, s2 string, rawQ string) [2]int64 {
    q := uriEscape(rawQ)
    return [2]int64{check(n0, 0, s1, q), check(n0, 0, s2, q)}
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
    s1 := "café@例え.テスト"
    s2 := "not-an-email"
    rawQ := "a b"
    if len(positional) > 0 {
        v, err := strconv.ParseInt(positional[0], 10, 64)
        if err != nil {
            panic("n must be an integer")
        }
        n0 = v
    }
    if len(positional) > 1 {
        s1 = positional[1]
    }
    if len(positional) > 2 {
        s2 = positional[2]
    }
    if len(positional) > 3 {
        rawQ = positional[3]
    }

    runOnce(n0, s1, s2, rawQ)
    best := float64(1<<63 - 1)
    var value [2]int64
    for i := 0; i < runs; i++ {
        t0 := time.Now()
        value = runOnce(n0, s1, s2, rawQ)
        dt := float64(time.Since(t0)) / float64(time.Microsecond)
        if dt < best {
            best = dt
        }
    }

    fmt.Printf("value: [%d, %d]\n", value[0], value[1])
    fmt.Printf("best_us: %.3f\n", best)
}
