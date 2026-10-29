#!/usr/bin/env python3
# Python equivalent of bench/experimental/json-parse.bot: validating a JSON
# document with examples/dfa/json's algorithm -- json_lex.bot's RFC 8259
# lexical grammar (the declared recognizers json_token, json_string,
# json_escape, json_number, json_literal) and json.bot's validate_text driver
# with its structural layer (an explicit stack of expectations, MAX_DEPTH 64)
# -- written by hand. Python's json module is not used: the value is the
# validator's own count, and the comparison is the same algorithm.
#
# How the Botlish structure maps here:
#
#   scalars      the document's chunks (one per object; never concatenated),
#                iterated scalar value by scalar value across chunk
#                boundaries, then -1 (the end of the input) forever
#   recognizers  one function per token kind, fed the token's first symbol
#                and reading one symbol at a time exactly as the DFA does:
#                punctuation; a string with every escape (\" \\ \/ \b \f \n
#                \r \t \uXXXX) and unescaped 0x20-0x21, 0x23-0x5B,
#                0x5D-0x10FFFF; a number per json_number's states; true,
#                false and null. A number or literal ends before a symbol of
#                after_value (whitespace , ] }), left unread as the next
#                token's first, or at the end; any other symbol is rejected
#                there. The driver counts the symbols and bounds a token's
#                length (MAX_TOKEN) at the same reads as json.bot
#   structure    class Structure: json.bot's structure coroutine, one token
#                per call, its stack of what the document expects next
#
# Any error (Lexical, Truncated, Structure, TooDeep, TokenTooLong) raises.
# The value is [tokens, symbols]: the tokens validated and the Unicode scalar
# values read.
#
# Invoked by bench/bench.tcl; see bench/equivalents/python/fib.py for the
# --runs/value/best_us protocol shared by every equivalent: one untimed
# warmup run of the whole workload, then N timed runs, each building the
# chunk list from scratch and validating it, as one Botlish program run does.
# The printed value has core::value::show's "[a, b]" shape.
#
# expect: [1444, 3984]
import sys
import time
from itertools import chain

COPIES = 20
PIECE = "{\"id\": 12, \"name\": \"café \\\"bot\\\"\", \"tags\": [\"a\", \"b\\n\", \"\\u00e9\\ud83d\\ude00\"], \"pos\": [-1.5, 2e3, 0.25E-2, 0], \"ok\": true, \"off\": false, \"next\": null, \"nested\": {\"x\": [[], {}], \"y\": [1, [2, [3]]]}},\n"

MAX_DEPTH = 64
MAX_TOKEN = 100000

END_OF_INPUT = -1


class JsonError(Exception):
    pass


class Lexical(JsonError):
    """A symbol no token takes, or that continues a token wrongly."""


class Truncated(JsonError):
    """The end of the input inside a token."""


class StructureError(JsonError):
    """A token the structure does not allow there."""


class TooDeep(JsonError):
    pass


class TokenTooLong(JsonError):
    pass


# Token kinds (json.bot's enum Kind).
BEGIN_OBJECT = 0
END_OBJECT = 1
BEGIN_ARRAY = 2
END_ARRAY = 3
NAME_SEPARATOR = 4
VALUE_SEPARATOR = 5
STRING = 6
NUMBER = 7
LITERAL = 8
END = 9

PUNCTUATION = {
    ord("{"): BEGIN_OBJECT,
    ord("}"): END_OBJECT,
    ord("["): BEGIN_ARRAY,
    ord("]"): END_ARRAY,
    ord(":"): NAME_SEPARATOR,
    ord(","): VALUE_SEPARATOR,
}
VALUE_START = (STRING, NUMBER, LITERAL, BEGIN_OBJECT, BEGIN_ARRAY)

WHITESPACE = frozenset(map(ord, " \t\n\r"))
# FOLLOW(value): the symbols that may come right after a number or literal.
AFTER_VALUE = WHITESPACE | frozenset(map(ord, ",]}"))
DIGITS = frozenset(range(ord("0"), ord("9") + 1))
HEX = DIGITS | frozenset(map(ord, "abcdefABCDEF"))
SIMPLE_ESCAPES = frozenset(map(ord, "\"\\/bfnrt"))
QUOTE = ord('"')
BACKSLASH = ord("\\")
MINUS = ord("-")
PLUS = ord("+")
ZERO = ord("0")
POINT = ord(".")
EXPONENT = frozenset(map(ord, "eE"))
SIGN = frozenset((PLUS, MINUS))
U = ord("u")
# A literal's first symbol and the rest of its word.
LITERAL_TAILS = {
    ord("t"): tuple(map(ord, "rue")),
    ord("f"): tuple(map(ord, "alse")),
    ord("n"): tuple(map(ord, "ull")),
}

# What the structure expects next (the top of its stack).
EXPECT_DOCUMENT_END = 0
EXPECT_VALUE = 1
EXPECT_ARRAY_FIRST = 2
EXPECT_ARRAY_NEXT = 3
EXPECT_OBJECT_FIRST = 4
EXPECT_OBJECT_NEXT = 5
EXPECT_KEY = 6
EXPECT_COLON = 7

EXPECTED_TEXT = (
    "the end of the input",
    "a value",
    "a value or ]",
    ", or ]",
    "a string or }",
    ", or }",
    "a string",
    "a name separator",
)


class Structure:
    """RFC 8259's JSON-text = ws value ws, over tokens: json.bot's structure."""

    def __init__(self, max_depth):
        self.max_depth = max_depth
        self.stack = [EXPECT_DOCUMENT_END, EXPECT_VALUE]

    # The next token; True when the End token closes a complete value.
    def token(self, kind, at):
        stack = self.stack
        if not stack:
            raise StructureError(at, "nothing")
        e = stack.pop()
        if e == EXPECT_DOCUMENT_END:
            if kind == END:
                return True
            raise StructureError(at, EXPECTED_TEXT[e])
        # A closing bracket where a container may end.
        if e == EXPECT_ARRAY_FIRST and kind == END_ARRAY:
            return False
        if e == EXPECT_OBJECT_FIRST and kind == END_OBJECT:
            return False
        if e == EXPECT_ARRAY_NEXT or e == EXPECT_OBJECT_NEXT:
            if e == EXPECT_ARRAY_NEXT and kind == END_ARRAY:
                return False
            if e == EXPECT_OBJECT_NEXT and kind == END_OBJECT:
                return False
            if kind != VALUE_SEPARATOR:
                raise StructureError(at, EXPECTED_TEXT[e])
            if e == EXPECT_ARRAY_NEXT:
                stack.append(EXPECT_ARRAY_NEXT)
                stack.append(EXPECT_VALUE)
            else:
                stack.append(EXPECT_OBJECT_NEXT)
                stack.append(EXPECT_VALUE)
                stack.append(EXPECT_COLON)
                stack.append(EXPECT_KEY)
            return False
        if e == EXPECT_COLON:
            if kind != NAME_SEPARATOR:
                raise StructureError(at, EXPECTED_TEXT[e])
            return False
        if e == EXPECT_KEY or e == EXPECT_OBJECT_FIRST:
            if kind != STRING:
                raise StructureError(at, EXPECTED_TEXT[e])
            if e == EXPECT_OBJECT_FIRST:
                stack.append(EXPECT_OBJECT_NEXT)
                stack.append(EXPECT_VALUE)
                stack.append(EXPECT_COLON)
            return False
        # e is a value or the first value of an array.
        if kind not in VALUE_START:
            raise StructureError(at, EXPECTED_TEXT[e])
        if e == EXPECT_ARRAY_FIRST:
            stack.append(EXPECT_ARRAY_NEXT)
        if kind == BEGIN_ARRAY:
            stack.append(EXPECT_ARRAY_FIRST)
        if kind == BEGIN_OBJECT:
            stack.append(EXPECT_OBJECT_FIRST)
        # Below the document's end, one entry per open container.
        if len(stack) > self.max_depth + 1:
            raise TooDeep(self.max_depth)
        return False


class Cursor:
    """The driver's input buffer: the current symbol and its offset."""

    def __init__(self, chunks, max_token):
        # The scalar values of the chunks, one at a time across chunk
        # boundaries (the text is never concatenated).
        self.source = map(ord, chain.from_iterable(chunks))
        self.pos = 0
        self.c = next(self.source, END_OF_INPUT)
        self.start = 0
        self.max_token = max_token

    # Between tokens: the current symbol is consumed; read the next.
    def advance(self):
        self.pos += 1
        self.c = next(self.source, END_OF_INPUT)

    # Inside a token: the recognizer took the current symbol; hand it the
    # next (the driver bounds the token's length here).
    def take(self):
        self.pos += 1
        c = self.c = next(self.source, END_OF_INPUT)
        if self.pos - self.start >= self.max_token:
            raise TokenTooLong(self.start, self.max_token)
        return c

    # The recognizer rejects the current symbol (or the end of the input).
    def reject(self, recognizer):
        if self.c == END_OF_INPUT:
            raise Truncated(self.pos, recognizer)
        raise Lexical(self.pos, recognizer, self.c)


# json_string from its opening quote, json_escape inside it. Completes on the
# closing quote, which it takes: nothing is left unread.
def lex_string(cur):
    while True:
        c = cur.take()
        if c == QUOTE:
            return 0
        if c == BACKSLASH:
            c = cur.take()
            if c == U:
                for _ in range(4):
                    if cur.take() not in HEX:
                        cur.reject("json_escape")
            elif c not in SIMPLE_ESCAPES:
                cur.reject("json_escape")
        elif c < 0x20:  # also END_OF_INPUT; the quote and backslash are above
            cur.reject("json_string")


# The end of a number or literal: the end of the input (nothing unread) or a
# symbol that may follow a value (left unread); anything else is rejected.
def value_end(cur, c, recognizer):
    if c == END_OF_INPUT:
        return 0
    if c in AFTER_VALUE:
        return 1
    cur.reject(recognizer)


# json_number from its first symbol ('-' or a digit):
# [ minus ] int [ frac ] [ exp ], then the end of a value.
def lex_number(cur, c):
    if c == MINUS:
        c = cur.take()
        if c not in DIGITS:
            cur.reject("json_number")
    # int = zero / ( digit1-9 *DIGIT ): after a zero, no digit continues it.
    if c == ZERO:
        c = cur.take()
    else:
        c = cur.take()
        while c in DIGITS:
            c = cur.take()
    # frac = "." 1*DIGIT
    if c == POINT:
        c = cur.take()
        if c not in DIGITS:
            cur.reject("json_number")
        c = cur.take()
        while c in DIGITS:
            c = cur.take()
    # exp = ("e" / "E") [ "-" / "+" ] 1*DIGIT
    if c in EXPONENT:
        c = cur.take()
        if c in SIGN:
            c = cur.take()
        if c not in DIGITS:
            cur.reject("json_number")
        c = cur.take()
        while c in DIGITS:
            c = cur.take()
    return value_end(cur, c, "json_number")


# true, false or null from its first symbol.
def lex_literal(cur, c):
    for expected in LITERAL_TAILS[c]:
        if cur.take() != expected:
            cur.reject("json_literal")
    return value_end(cur, cur.take(), "json_literal")


def validate_text(chunks, max_depth, max_token):
    cur = Cursor(chunks, max_token)
    parse = Structure(max_depth)
    tokens = 0
    while True:
        start = cur.pos
        c = cur.c
        if c == END_OF_INPUT:
            parse.token(END, start)
            break
        if c in WHITESPACE:
            cur.advance()
            continue
        # json_token: the kind is what the first symbol says.
        cur.start = start
        kind = PUNCTUATION.get(c)
        if kind is not None:
            unread = 0
        elif c == QUOTE:
            kind = STRING
            unread = lex_string(cur)
        elif c == MINUS or c in DIGITS:
            kind = NUMBER
            unread = lex_number(cur, c)
        elif c in LITERAL_TAILS:
            kind = LITERAL
            unread = lex_literal(cur, c)
        else:
            raise Lexical(start, "json_token", c)
        # With nothing unread, the token took the current symbol too (unless
        # that was the end); with one, it is the next token's first.
        if unread == 0 and cur.c != END_OF_INPUT:
            cur.advance()
        parse.token(kind, start)
        tokens += 1
    return tokens, cur.pos


def chunks(n):
    body = ["[" + PIECE if i == 0 else PIECE for i in range(n)]
    body.append("{}]")
    return body


def run_once():
    tokens, symbols = validate_text(chunks(COPIES), MAX_DEPTH, MAX_TOKEN)
    return [tokens, symbols]


def parse_args(argv):
    runs = 5
    i = 0
    while i < len(argv):
        if argv[i] == "--runs":
            i += 1
            runs = int(argv[i])
        i += 1
    return runs


if __name__ == "__main__":
    runs = parse_args(sys.argv[1:])

    run_once()  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = run_once()
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print("value: [" + ", ".join(str(v) for v in value) + "]")
    print(f"best_us: {best:.3f}")
