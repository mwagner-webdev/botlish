// Go equivalent of bench/test-selection.bot: "which test groups are
// affected by this set of changed files?" -- a named record per test group,
// a closure factory over a set of changed paths, and the selection, search
// and exclusion queries the Botlish program makes with it.
//
// Invoked by bench/bench.tcl; see fib.go for the --runs/value/best_us
// protocol shared by all equivalents. The printed value's shape matches
// core::value::show's rendering of a Botlish List (strings double-quoted,
// Bools true/false).
//
// Mapping: Test is the Botlish struct, makeChanged returns a closure over a
// map used as a set (std::immutable_set), affected is "any" over a test's
// dependencies, selectAffected the returning-loop selection, firstAffected
// the std::list::find with its NotFound fallback, and untouchedByA the
// std::list::none? query. The test list and both changed-file sets are
// built inside each timed run, as the Botlish program builds them on every
// run.
package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

type Test struct {
	name         string
	dependencies []string
}

func makeChanged(changed []string) func(string) bool {
	changedSet := make(map[string]struct{}, len(changed))
	for _, path := range changed {
		changedSet[path] = struct{}{}
	}
	return func(path string) bool {
		_, ok := changedSet[path]
		return ok
	}
}

func affected(test Test, changed func(string) bool) bool {
	for _, dep := range test.dependencies {
		if changed(dep) {
			return true
		}
	}
	return false
}

func selectAffected(tests []Test, changed func(string) bool) []Test {
	var selected []Test
	for _, test := range tests {
		if affected(test, changed) {
			selected = append(selected, test)
		}
	}
	return selected
}

func firstAffected(tests []Test, changed func(string) bool) string {
	for _, test := range tests {
		if affected(test, changed) {
			return test.name
		}
	}
	return Test{name: "<none>"}.name
}

type result struct {
	selectedA, selectedB int
	first                string
	probe, untouchedByA  bool
}

func runOnce() result {
	tests := []Test{
		{"parser-tests", []string{"src/parser.bot", "src/ast.bot"}},
		{"lexer-tests", []string{"src/lexer.bot", "src/token.bot"}},
		{"resolve-tests", []string{"hir/resolve.tcl", "hir/hir.tcl"}},
		{"types-tests", []string{"hir/types.tcl", "hir/hir.tcl"}},
		{"specialize-tests", []string{"hir/specialize.tcl", "hir/range.tcl"}},
		{"native-lower-tests", []string{"native/lower.tcl", "native/native.tcl"}},
		{"compile-tests", []string{"compiler/compiler.tcl"}},
		{"web-tests", []string{"stdlib/web.bot", "stdlib/byte.bot"}},
		{"ascii-tests", []string{"stdlib/ascii.bot"}},
		{"list-tests", []string{"stdlib/list.bot"}},
		{"byte-tests", []string{"stdlib/byte.bot", "core/scalarbits.tcl"}},
		{"char-tests", []string{"stdlib/char.bot", "core/unicodechar.tcl"}},
		{"docs-tests", []string{"README.md", "AGENTS.md"}},
		{"bench-tests", []string{"bench/bench.tcl"}},
	}
	changedA := makeChanged([]string{"stdlib/web.bot", "hir/hir.tcl"})
	changedB := makeChanged([]string{"README.md"})
	probe := changedA("stdlib/web.bot")
	selectedA := selectAffected(tests, changedA)
	selectedB := selectAffected(tests, changedB)
	untouchedByA := true
	for _, dep := range []string{"README.md", "AGENTS.md"} {
		if changedA(dep) {
			untouchedByA = false
			break
		}
	}
	return result{len(selectedA), len(selectedB), firstAffected(tests, changedA), probe, untouchedByA}
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

	runOnce()
	var value result
	best := bestMicros(runs, func() {
		value = runOnce()
	})

	fmt.Printf("value: [%d, %d, %q, %t, %t]\n", value.selectedA, value.selectedB, value.first, value.probe, value.untouchedByA)
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
