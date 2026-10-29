// Go equivalent of bench/uri-steady.bot: steady-state percent-escaping of a
// small fixed corpus (plain unreserved ASCII, ASCII that needs escaping,
// multi-byte UTF-8, a mixed string), summing each result's length.
//
// Invoked by bench/bench.tcl; see fib.go for the --runs/value/best_us
// protocol shared by all equivalents.
//
// uriEscapeText is stdlib/web.bot's std::web::uri_escape_text: every scalar
// above 127 becomes the %XX escapes of its UTF-8 bytes, an RFC 3986
// unreserved ASCII character (letters, digits, - . _ ~) is kept, every
// other ASCII character becomes its own %XX, uppercase hex, appended to a
// fresh string per call. A result's length is its count of Unicode scalar
// values, as std::str::length counts. repeatURI recurses 2,000 deep as the
// Botlish driver does.
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

const hexDigits = "0123456789ABCDEF"

func isUnreserved(b byte) bool {
	return (b >= 'A' && b <= 'Z') || (b >= 'a' && b <= 'z') || (b >= '0' && b <= '9') || b == '-' || b == '.' || b == '_' || b == '~'
}

func writePct(out *strings.Builder, b byte) {
	out.WriteByte('%')
	out.WriteByte(hexDigits[b>>4])
	out.WriteByte(hexDigits[b&15])
}

func uriEscapeText(s string) string {
	var out strings.Builder
	for _, r := range s {
		if r > 127 {
			var buf [4]byte
			n := utf8.EncodeRune(buf[:], r)
			for _, b := range buf[:n] {
				writePct(&out, b)
			}
		} else if isUnreserved(byte(r)) {
			out.WriteByte(byte(r))
		} else {
			writePct(&out, byte(r))
		}
	}
	return out.String()
}

func repeatURI(corpus []string, i, total, acc int64) int64 {
	if i >= total {
		return acc
	}
	text := corpus[i%int64(len(corpus))]
	escaped := uriEscapeText(text)
	return repeatURI(corpus, i+1, total, acc+int64(utf8.RuneCountInString(escaped)))
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
	total := int64(2000)
	if len(positional) > 0 {
		v, err := strconv.ParseInt(positional[0], 10, 64)
		if err != nil {
			panic("total must be an integer")
		}
		total = v
	}
	corpus := []string{"abcXYZ012", "a b+c?", "café", "hello 世界?"}

	repeatURI(corpus, 0, total, 0)
	best := float64(1<<63 - 1)
	var value int64
	for i := 0; i < runs; i++ {
		t0 := time.Now()
		value = repeatURI(corpus, 0, total, 0)
		dt := float64(time.Since(t0)) / float64(time.Microsecond)
		if dt < best {
			best = dt
		}
	}

	fmt.Printf("value: %d\n", value)
	fmt.Printf("best_us: %.3f\n", best)
}
