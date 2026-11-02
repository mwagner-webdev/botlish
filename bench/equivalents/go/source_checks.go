// Go equivalent of bench/source-checks.bot: a small lint pass whose lexical
// classifiers of an identifier's leading character are held in a list of
// callables and invoked from it, then a selection of the invalid names and
// a search for the first one.
//
// Invoked by bench/bench.tcl; see fib.go for the --runs/value/best_us
// protocol shared by all equivalents. The printed value's shape matches
// core::value::show's rendering of a Botlish List (strings double-quoted).
//
// Mapping: checks is the Botlish `checks` List (two Tcl character classes
// and two ordinary functions) as a slice of functions; classifyLeading
// applies each to the first character, as `loop check in checks: check(c)`
// does, collecting a slice; the empty name short-circuits to four false
// flags before the list is consulted. tclAlpha/tclAlnum are Tcl 9's
// [:alpha:]/[:alnum:]: a Unicode letter, or a letter or decimal digit (Nd).
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
	"unicode"
	"unicode/utf8"
)

func tclAlpha(r rune) bool {
	return unicode.IsLetter(r)
}

func tclAlnum(r rune) bool {
	return unicode.IsLetter(r) || unicode.IsDigit(r)
}

func isUnderscore(r rune) bool {
	return r == '_'
}

func isHyphen(r rune) bool {
	return r == '-'
}

var checks = []func(rune) bool{tclAlpha, tclAlnum, isUnderscore, isHyphen}

func classifyLeading(name string) []bool {
	if len(name) == 0 {
		return []bool{false, false, false, false}
	}
	c, _ := utf8.DecodeRuneInString(name)
	flags := make([]bool, 0, len(checks))
	for _, check := range checks {
		flags = append(flags, check(c))
	}
	return flags
}

func validStart(name string) bool {
	flags := classifyLeading(name)
	return flags[0] || flags[2]
}

func invalidName(name string) bool {
	return !validStart(name)
}

type result struct {
	candidates, invalid int
	firstInvalid        string
	valid               int
}

func runOnce(candidates []string) result {
	var invalidNames []string
	for _, name := range candidates {
		if !validStart(name) {
			invalidNames = append(invalidNames, name)
		}
	}
	firstInvalid := "<none>"
	for _, name := range candidates {
		if invalidName(name) {
			firstInvalid = name
			break
		}
	}
	return result{len(candidates), len(invalidNames), firstInvalid, len(candidates) - len(invalidNames)}
}

func quoted(s string) string {
	return "\"" + strings.ReplaceAll(strings.ReplaceAll(s, "\\", "\\\\"), "\"", "\\\"") + "\""
}

func parseRuns() int {
	runs := 5
	for i := 1; i < len(os.Args); i++ {
		if os.Args[i] == "--runs" && i+1 < len(os.Args) {
			i++
			v, err := strconv.Atoi(os.Args[i])
			if err != nil {
				panic("--runs must be an integer")
			}
			runs = v
		}
	}
	return runs
}

func main() {
	runs := parseRuns()
	candidates := []string{
		"emailish?",
		"scan_while",
		"list_get",
		"_internal",
		"über_count",
		"2fast",
		"make_changed?",
		"_private_state",
		"9bad_name",
		"-flag",
		"is_tcl_alpha",
		"évalue",
		"-verbose",
		"",
		"x_1",
		"café_name",
	}

	runOnce(candidates)
	var value result
	best := bestMicros(runs, func() {
		value = runOnce(candidates)
	})

	fmt.Printf("value: [%d, %d, %s, %d]\n", value.candidates, value.invalid, quoted(value.firstInvalid), value.valid)
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
