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
	best := float64(1<<63 - 1)
	var value result
	for i := 0; i < runs; i++ {
		t0 := time.Now()
		value = runOnce()
		dt := float64(time.Since(t0)) / float64(time.Microsecond)
		if dt < best {
			best = dt
		}
	}

	fmt.Printf("value: [%d, %d, %q, %t, %t]\n", value.selectedA, value.selectedB, value.first, value.probe, value.untouchedByA)
	fmt.Printf("best_us: %.3f\n", best)
}
