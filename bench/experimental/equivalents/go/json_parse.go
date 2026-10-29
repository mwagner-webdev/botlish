// Go equivalent of bench/experimental/json-parse.bot: validating a JSON
// document the way examples/dfa/json/json.bot's validate_text does over
// json_lex.bot's RFC 8259 recognizers -- a hand-written validator of the same
// algorithm, not encoding/json (the value is the validator's own count of
// tokens and symbols).
//
// Invoked by bench/bench.tcl; see bench/equivalents/go/fib.go for the
// --runs/value/best_us protocol shared by every equivalent: one untimed warmup
// run, then N timed runs, each building the document's chunks afresh as one
// Botlish program run does. The printed value has core::value::show's
// "[a, b, ...]" shape.
//
// Mapping. The document is the same slice of chunks (the first "[" and one
// piece, COPIES-1 more pieces, then "{}]"), never concatenated: symbols
// iterates its Unicode scalar values (runes) across the chunks, then -1 (the
// end of the input) for ever, as json.bot's scalars coroutine does. The
// declared recognizers become one state machine, recognizer, fed one symbol
// at a time: json_token's dispatch on the first symbol, json_string (with
// json_escape's escapes, \uXXXX included, and the unescaped range 0x20-0x21,
// 0x23-0x5B, 0x5D-0x10FFFF), the json_number DFA and json_literal, a `call D
// then S` being a jump into D's states and back to S. A number or literal ends
// before a symbol of after_value (whitespace , ] }), left unread, or at the
// end of the input, and rejects anything else. The driver is validate_text's:
// it skips whitespace, keeps the current symbol (the recognizers' one symbol
// of lookahead), hands a token the symbols it takes, bounds a token's length
// (max_token) and feeds each token's kind, read from its first symbol, to
// structure: json.bot's grammar of RFC 8259 values with its explicit stack of
// expectations, bounded by max_depth. An invalid document is an error, which
// the value reports as json-parse.bot's handlers do ([-2] Lexical, [-3]
// Truncated, [-4] Structure, [-5] TooDeep, [-6] TokenTooLong).
//
// expect: [1444, 3984]
package main

import (
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

const copies = 20

// The text of json-parse.bot's piece: one object with every token kind.
const piece = `{"id": 12, "name": "café \"bot\"", "tags": ["a", "b\n", "\u00e9\ud83d\ude00"], "pos": [-1.5, 2e3, 0.25E-2, 0], "ok": true, "off": false, "next": null, "nested": {"x": [[], {}], "y": [1, [2, [3]]]}},` + "\n"

func chunks(n int) []string {
	body := make([]string, 0, n+1)
	for i := 0; i < n; i++ {
		if i == 0 {
			body = append(body, "["+piece)
		} else {
			body = append(body, piece)
		}
	}
	return append(body, "{}]")
}

// ---------------------------------------------------------------------------
// Errors (json.bot's), with the value json-parse.bot reports for each

type jsonError struct {
	code int // -2 Lexical, -3 Truncated, -4 Structure, -5 TooDeep, -6 TokenTooLong
	at   int
	what string
}

func (e *jsonError) Error() string {
	return e.what + " at " + strconv.Itoa(e.at)
}

// What a recognizer fails with: a symbol it has no transition for, or the
// end of the input inside a token.
var (
	errUnrecognized  = errors.New("UnrecognizedInput")
	errUnexpectedEnd = errors.New("UnexpectedEnd")
)

func lexical(err error, at int) error {
	if err == errUnexpectedEnd {
		return &jsonError{-3, at, "Truncated"}
	}
	return &jsonError{-2, at, "Lexical"}
}

// ---------------------------------------------------------------------------
// The symbols: the scalar values of the chunks, then -1 for ever

type symbols struct {
	chunks []string
	ci, bi int
}

func (s *symbols) next() rune {
	for s.ci < len(s.chunks) {
		chunk := s.chunks[s.ci]
		if s.bi < len(chunk) {
			if b := chunk[s.bi]; b < utf8.RuneSelf {
				s.bi++
				return rune(b)
			}
			r, size := utf8.DecodeRuneInString(chunk[s.bi:])
			s.bi += size
			return r
		}
		s.ci++
		s.bi = 0
	}
	return -1
}

// ---------------------------------------------------------------------------
// The recognizers (json_lex.bot)

// Recognizer states: json_lex.bot's recognizers composed as json_token
// composes them.
const (
	stringBody = iota // json_string's body
	escapeKind        // json_escape's kind (after the backslash)
	escapeU1          // json_escape's u1 .. u4
	escapeU2
	escapeU3
	escapeU4
	numberMinus // json_number's states
	numberZero
	numberInteger
	numberPoint
	numberFraction
	numberExponent
	numberExponentSign
	numberExponentDigits
	literalWord // json_literal inside true, false or null
	literalEnd  // json_literal's word_end
)

// What a recognizer answers to a symbol.
const (
	needMore = iota // it took the symbol and needs the next one (0)
	tookLast        // it completed taking the symbol (nothing left unread)
	leftOne         // it completed before the symbol (left unread: 1)
)

type recognizer struct {
	state int
	word  string // literalWord: the rest of the literal
}

func isDigit(c rune) bool { return c >= '0' && c <= '9' }

func isHex(c rune) bool {
	return isDigit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

// afterValue is json_lex's class after_value: what may follow a number or
// a literal (whitespace, a value separator, the end of an array or object).
func afterValue(c rune) bool {
	return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == ',' || c == ']' || c == '}'
}

func reject(c rune) (int, error) {
	if c == -1 {
		return 0, errUnexpectedEnd
	}
	return 0, errUnrecognized
}

// start is json_token's start state on the token's first symbol C (not
// whitespace, not the end).
func (r *recognizer) start(c rune) (int, error) {
	switch {
	case c == '{' || c == '}' || c == '[' || c == ']' || c == ':' || c == ',':
		return tookLast, nil
	case c == '"':
		r.state = stringBody
	case c == '-':
		r.state = numberMinus
	case c == '0':
		r.state = numberZero
	case c >= '1' && c <= '9':
		r.state = numberInteger
	case c == 't':
		r.state, r.word = literalWord, "rue"
	case c == 'f':
		r.state, r.word = literalWord, "alse"
	case c == 'n':
		r.state, r.word = literalWord, "ull"
	default:
		return reject(c)
	}
	return needMore, nil
}

// endOfNumber: a number or literal that may end here ends before a symbol
// of after_value, or at the end of the input.
func endOfNumber(c rune) (int, error) {
	if c == -1 {
		return tookLast, nil
	}
	if afterValue(c) {
		return leftOne, nil
	}
	return 0, errUnrecognized
}

// feed hands the recognizer the token's next symbol C (-1: the end).
func (r *recognizer) feed(c rune) (int, error) {
	switch r.state {
	case stringBody:
		switch {
		case c == '"':
			return tookLast, nil
		case c == '\\':
			r.state = escapeKind
		case c >= 0x20 && c <= 0x10FFFF: // unescaped: '"' and '\' are above
		default:
			return reject(c)
		}
	case escapeKind:
		switch c {
		case '"', '\\', '/', 'b', 'f', 'n', 'r', 't':
			r.state = stringBody
		case 'u':
			r.state = escapeU1
		default:
			return reject(c)
		}
	case escapeU1, escapeU2, escapeU3:
		if !isHex(c) {
			return reject(c)
		}
		r.state++
	case escapeU4:
		if !isHex(c) {
			return reject(c)
		}
		r.state = stringBody
	case numberMinus:
		switch {
		case c == '0':
			r.state = numberZero
		case c >= '1' && c <= '9':
			r.state = numberInteger
		default:
			return reject(c)
		}
	case numberZero, numberInteger, numberFraction:
		switch {
		case isDigit(c) && r.state != numberZero:
		case c == '.' && r.state != numberFraction:
			r.state = numberPoint
		case c == 'e' || c == 'E':
			r.state = numberExponent
		default:
			return endOfNumber(c)
		}
	case numberPoint:
		if !isDigit(c) {
			return reject(c)
		}
		r.state = numberFraction
	case numberExponent:
		switch {
		case c == '+' || c == '-':
			r.state = numberExponentSign
		case isDigit(c):
			r.state = numberExponentDigits
		default:
			return reject(c)
		}
	case numberExponentSign:
		if !isDigit(c) {
			return reject(c)
		}
		r.state = numberExponentDigits
	case numberExponentDigits:
		if !isDigit(c) {
			return endOfNumber(c)
		}
	case literalWord:
		if c != rune(r.word[0]) {
			return reject(c)
		}
		r.word = r.word[1:]
		if r.word == "" {
			r.state = literalEnd
		}
	case literalEnd:
		return endOfNumber(c)
	}
	return needMore, nil
}

// ---------------------------------------------------------------------------
// The structure (json.bot's structure)

type tokenKind int

const (
	beginObject tokenKind = iota
	endObject
	beginArray
	endArray
	nameSeparator
	valueSeparator
	stringToken
	numberToken
	literalToken
	endToken
)

// kindOf is the kind of the token whose first symbol is C.
func kindOf(c rune) tokenKind {
	switch c {
	case '{':
		return beginObject
	case '}':
		return endObject
	case '[':
		return beginArray
	case ']':
		return endArray
	case ':':
		return nameSeparator
	case ',':
		return valueSeparator
	case '"':
		return stringToken
	case 't', 'f', 'n':
		return literalToken
	}
	return numberToken
}

func valueStart(k tokenKind) bool {
	return k == stringToken || k == numberToken || k == literalToken || k == beginObject || k == beginArray
}

// What the structure expects next (the top of its stack).
const (
	expectDocumentEnd = iota
	expectValue
	expectArrayFirst
	expectArrayNext
	expectObjectFirst
	expectObjectNext
	expectKey
	expectColon
)

var expectedText = [...]string{
	"the end of the input", "a value", "a value or ]", ", or ]",
	"a string or }", ", or }", "a string", "a name separator",
}

type lexeme struct {
	kind       tokenKind
	start, end int
}

// structure is RFC 8259's JSON-text = ws value ws over tokens: its control
// state is the stack of what the document expects next, innermost last.
type structure struct {
	maxDepth int
	stack    []int
}

func newStructure(maxDepth int) *structure {
	return &structure{maxDepth: maxDepth, stack: []int{expectDocumentEnd, expectValue}}
}

func (s *structure) push(e int) { s.stack = append(s.stack, e) }

func structureError(t lexeme, expected string) error {
	return &jsonError{-4, t.start, "Structure (expected " + expected + ")"}
}

// feed hands the structure the next token: true when the End token closes a
// complete value, an error at the first token the grammar does not allow.
func (s *structure) feed(t lexeme) (bool, error) {
	n := len(s.stack)
	if n == 0 {
		return false, structureError(t, "nothing")
	}
	e := s.stack[n-1]
	s.stack = s.stack[:n-1]
	if e == expectDocumentEnd {
		if t.kind == endToken {
			return true, nil
		}
		return false, structureError(t, expectedText[e])
	}
	// A closing bracket where a container may end.
	if e == expectArrayFirst && t.kind == endArray || e == expectObjectFirst && t.kind == endObject {
		return false, nil
	}
	if e == expectArrayNext || e == expectObjectNext {
		if e == expectArrayNext && t.kind == endArray || e == expectObjectNext && t.kind == endObject {
			return false, nil
		}
		if t.kind != valueSeparator {
			return false, structureError(t, expectedText[e])
		}
		if e == expectArrayNext {
			s.push(expectArrayNext)
			s.push(expectValue)
		} else {
			s.push(expectObjectNext)
			s.push(expectValue)
			s.push(expectColon)
			s.push(expectKey)
		}
		return false, nil
	}
	if e == expectColon {
		if t.kind != nameSeparator {
			return false, structureError(t, expectedText[e])
		}
		return false, nil
	}
	if e == expectKey || e == expectObjectFirst {
		if t.kind != stringToken {
			return false, structureError(t, expectedText[e])
		}
		if e == expectObjectFirst {
			s.push(expectObjectNext)
			s.push(expectValue)
			s.push(expectColon)
		}
		return false, nil
	}
	// e is a value or the first value of an array.
	if !valueStart(t.kind) {
		return false, structureError(t, expectedText[e])
	}
	if e == expectArrayFirst {
		s.push(expectArrayNext)
	}
	if t.kind == beginArray {
		s.push(expectArrayFirst)
	}
	if t.kind == beginObject {
		s.push(expectObjectFirst)
	}
	// Below the document's end, one entry per open container.
	if len(s.stack) > s.maxDepth+1 {
		return false, &jsonError{-5, t.start, "TooDeep"}
	}
	return false, nil
}

// ---------------------------------------------------------------------------
// The driver (json.bot's validate_text)

type summary struct{ tokens, symbols int }

func whitespace(c rune) bool {
	return c == ' ' || c == '\n' || c == '\r' || c == '\t'
}

// validateText validates the JSON text that CHUNKS hold, split anywhere: the
// number of tokens and of symbols, or the first error.
func validateText(chunks []string, maxDepth, maxToken int) (summary, error) {
	src := symbols{chunks: chunks}
	parse := newStructure(maxDepth)
	pos := 0          // the offset of the current symbol
	cur := src.next() // the current symbol (-1: the end of the input)
	tokens := 0
	for {
		start := pos
		c := cur
		if c == -1 {
			if _, err := parse.feed(lexeme{endToken, start, start}); err != nil {
				return summary{}, err
			}
			break
		}
		if whitespace(c) {
			pos = start + 1
			cur = src.next()
			continue
		}
		var r recognizer
		answer, err := r.start(c)
		if err != nil {
			return summary{}, lexical(err, start)
		}
		for answer == needMore {
			// It took the current symbol: hand it the next.
			p := pos + 1
			pos = p
			cur = src.next()
			if p-start >= maxToken {
				return summary{}, &jsonError{-6, start, "TokenTooLong"}
			}
			if answer, err = r.feed(cur); err != nil {
				return summary{}, lexical(err, p)
			}
		}
		// Completed taking the current symbol too (unless that was the end),
		// or leaving it unread: then it is the next token's first.
		if answer == tookLast && cur != -1 {
			pos++
			cur = src.next()
		}
		if _, err := parse.feed(lexeme{kindOf(c), start, pos}); err != nil {
			return summary{}, err
		}
		tokens++
	}
	return summary{tokens, pos}, nil
}

func runOnce() []int {
	s, err := validateText(chunks(copies), 64, 100000)
	if err != nil {
		var je *jsonError
		if errors.As(err, &je) {
			return []int{je.code}
		}
		return []int{-1}
	}
	return []int{s.tokens, s.symbols}
}

func show(values []int) string {
	parts := make([]string, len(values))
	for i, v := range values {
		parts[i] = strconv.Itoa(v)
	}
	return "[" + strings.Join(parts, ", ") + "]"
}

func parseArgs() int {
	runs := 5
	for i := 1; i < len(os.Args); i++ {
		if os.Args[i] != "--runs" {
			panic("unexpected argument " + os.Args[i])
		}
		i++
		if i >= len(os.Args) {
			panic("--runs needs a value")
		}
		v, err := strconv.Atoi(os.Args[i])
		if err != nil {
			panic("--runs must be an integer")
		}
		runs = v
	}
	return runs
}

func main() {
	runs := parseArgs()

	value := runOnce()
	best := float64(1<<63 - 1)
	for i := 0; i < runs; i++ {
		t0 := time.Now()
		value = runOnce()
		dt := float64(time.Since(t0)) / float64(time.Microsecond)
		if dt < best {
			best = dt
		}
	}

	fmt.Printf("value: %s\n", show(value))
	fmt.Printf("best_us: %.3f\n", best)
}
