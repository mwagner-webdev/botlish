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
	best := float64(1<<63 - 1)
	var value result
	for i := 0; i < runs; i++ {
		t0 := time.Now()
		value = runOnce(candidates)
		dt := float64(time.Since(t0)) / float64(time.Microsecond)
		if dt < best {
			best = dt
		}
	}

	fmt.Printf("value: [%d, %d, %s, %d]\n", value.candidates, value.invalid, quoted(value.firstInvalid), value.valid)
	fmt.Printf("best_us: %.3f\n", best)
}
