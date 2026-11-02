// Go equivalent of bench/lex-strategy.bot: a strict-vs-relaxed
// identifier-character classifier, chosen as a function value at an if/else
// join and then applied to every character of each token, plus a universal
// "is every character of this token alphanumeric?" query.
//
// Invoked by bench/bench.tcl; see fib.go for the --runs/value/best_us
// protocol shared by all equivalents. The printed value's shape matches
// core::value::show's rendering of a Botlish List (strings double-quoted).
//
// Mapping: chooseClassifier returns one of two functions, as the Botlish
// program's two branches return std::str::is_tcl_alnum or
// lenient_ident_char?; classify collects the per-character flags into a
// slice (the Botlish collecting loop) and countTrue counts them. The Botlish
// chars_of is a recursive accumulator only because the language has no
// String-to-characters conversion; []rune(s) is Go's own spelling of it.
// tclAlnum is Tcl 9's [:alnum:]: a Unicode letter or a decimal digit (Nd).
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
	"unicode"
)

func tclAlnum(r rune) bool {
	return unicode.IsLetter(r) || unicode.IsDigit(r)
}

func lenientIdentChar(r rune) bool {
	return tclAlnum(r) || r == '_' || r == '-'
}

func chooseClassifier(strictMode bool) func(rune) bool {
	if strictMode {
		return tclAlnum
	}
	return lenientIdentChar
}

func charsOf(s string) []rune {
	return []rune(s)
}

func classify(token string, strictMode bool) []bool {
	classifier := chooseClassifier(strictMode)
	chars := charsOf(token)
	flags := make([]bool, 0, len(chars))
	for _, c := range chars {
		flags = append(flags, classifier(c))
	}
	return flags
}

func countTrue(flags []bool) int {
	n := 0
	for _, flag := range flags {
		if flag {
			n++
		}
	}
	return n
}

func validChars(token string, strictMode bool) int {
	return countTrue(classify(token, strictMode))
}

func fullyAlnum(token string) bool {
	for _, c := range charsOf(token) {
		if !tclAlnum(c) {
			return false
		}
	}
	return true
}

func totalValid(tokens []string, strictMode bool) int {
	total := 0
	for _, token := range tokens {
		total += validChars(token, strictMode)
	}
	return total
}

type result struct {
	strictTotal, relaxedTotal, alnumOnly int
	firstAlnum                           string
}

func runOnce(tokens []string) result {
	var alnumOnlyTokens []string
	for _, token := range tokens {
		if fullyAlnum(token) {
			alnumOnlyTokens = append(alnumOnlyTokens, token)
		}
	}
	firstAlnum := ""
	if len(alnumOnlyTokens) > 0 {
		firstAlnum = alnumOnlyTokens[0]
	}
	return result{totalValid(tokens, true), totalValid(tokens, false), len(alnumOnlyTokens), firstAlnum}
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
	tokens := []string{"emailish?", "scan_while", "local-part", "tld-check", "x_1", "9bad-name", "café", "is_tcl_alpha"}

	runOnce(tokens)
	var value result
	best := bestMicros(runs, func() {
		value = runOnce(tokens)
	})

	fmt.Printf("value: [%d, %d, %d, %s]\n", value.strictTotal, value.relaxedTotal, value.alnumOnly, quoted(value.firstAlnum))
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
