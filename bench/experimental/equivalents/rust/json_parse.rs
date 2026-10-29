// Rust equivalent of bench/experimental/json-parse.bot: validating a JSON
// document handed over in chunks -- examples/dfa/json/json.bot's
// validate_text over json_lex.bot's RFC 8259 recognizers -- here with a
// hand-written validator.
//
// Invoked by bench/bench.tcl; see bench/equivalents/rust/fib.rs for the
// --runs/value/best_us protocol shared by every equivalent. Every run builds
// the chunk list (one per object: "[" + PIECE, COPIES-1 more PIECEs, then
// "{}]"; the text is never concatenated) and validates it, as one run of the
// Botlish program does. The value is json::Summary's [tokens, symbols] -- the
// tokens validated and the Unicode scalar values read -- printed as
// core::value::show renders a Botlish List of Int, or the program's error
// code ([-2] Lexical ... [-6] TokenTooLong) for an invalid document.
//
// How the Botlish structure maps: json.bot's three layers are its three
// coroutines -- the symbols across the chunks (here a flat_map over the
// chunks' chars), one recognizer per token (json_lex's declared DFAs, here
// hand-written state machines over the same states: json_token's dispatch on
// the first symbol, json_string with json_escape's escapes including \uXXXX
// and the unescaped classes 0x20-0x21, 0x23-0x5B, 0x5D-0x10FFFF, json_number,
// json_literal), and the structure (RFC 8259's value grammar with an
// explicit stack of expectations, bounded by MAX_DEPTH). The driver is
// validate_text's: whitespace (space, \n, \r, \t) is skipped between tokens;
// a number or literal ends before a symbol that may follow a value
// (whitespace , ] }) -- which stays the current symbol, the next token's
// first -- or at the end of the input, and any other symbol there is
// rejected; a token is handed at most MAX_TOKEN symbols (TokenTooLong).
use std::fmt;
use std::hint::black_box;
use std::time::Instant;

const COPIES: usize = 20;
const MAX_DEPTH: usize = 64;
const MAX_TOKEN: usize = 100000;

const PIECE: &str = "{\"id\": 12, \"name\": \"café \\\"bot\\\"\", \"tags\": [\"a\", \"b\\n\", \"\\u00e9\\ud83d\\ude00\"], \"pos\": [-1.5, 2e3, 0.25E-2, 0], \"ok\": true, \"off\": false, \"next\": null, \"nested\": {\"x\": [[], {}], \"y\": [1, [2, [3]]]}},\n";

#[derive(Clone, Copy, PartialEq, Eq)]
enum Kind {
    BeginObject,
    EndObject,
    BeginArray,
    EndArray,
    NameSeparator,
    ValueSeparator,
    String,
    Number,
    Literal,
    End,
}

impl Kind {
    fn value_start(self) -> bool {
        matches!(self, Kind::String | Kind::Number | Kind::Literal | Kind::BeginObject | Kind::BeginArray)
    }
}

struct Summary {
    tokens: i64,
    symbols: i64,
}

/// json.bot's errors: where, and (for a symbol a recognizer rejects or an
/// end inside a token) which recognizer.
enum JsonError {
    Lexical { at: usize, recognizer: &'static str, symbol: i64 },
    Truncated { at: usize, recognizer: &'static str },
    Structure { at: usize, expected: &'static str },
    TooDeep { limit: usize },
    TokenTooLong { at: usize, limit: usize },
}

impl JsonError {
    /// What json-parse.bot's handlers make of it.
    fn code(&self) -> i64 {
        match self {
            JsonError::Lexical { .. } => -2,
            JsonError::Truncated { .. } => -3,
            JsonError::Structure { .. } => -4,
            JsonError::TooDeep { .. } => -5,
            JsonError::TokenTooLong { .. } => -6,
        }
    }
}

impl fmt::Display for JsonError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            JsonError::Lexical { at, recognizer, symbol } => write!(f, "Lexical at {}: {} rejects {}", at, recognizer, symbol),
            JsonError::Truncated { at, recognizer } => write!(f, "Truncated at {}: the input ends inside {}", at, recognizer),
            JsonError::Structure { at, expected } => write!(f, "Structure at {}: expected {}", at, expected),
            JsonError::TooDeep { limit } => write!(f, "TooDeep: more than {} levels", limit),
            JsonError::TokenTooLong { at, limit } => write!(f, "TokenTooLong at {}: more than {} symbols", at, limit),
        }
    }
}

fn whitespace(c: char) -> bool {
    matches!(c, ' ' | '\n' | '\r' | '\t')
}

/// FOLLOW(value): the symbols that may come right after a number or literal.
fn after_value(c: char) -> bool {
    whitespace(c) || matches!(c, ',' | ']' | '}')
}

fn unescaped(c: char) -> bool {
    matches!(c as u32, 0x20..=0x21 | 0x23..=0x5B | 0x5D..=0x10FFFF)
}

fn rejected(at: usize, recognizer: &'static str, symbol: Option<char>) -> JsonError {
    match symbol {
        Some(c) => JsonError::Lexical { at, recognizer, symbol: c as i64 },
        None => JsonError::Truncated { at, recognizer },
    }
}

// ---------------------------------------------------------------------------
// The structure: RFC 8259's JSON-text = ws value ws over tokens, its control
// state a stack of what the document expects next, innermost last.

#[derive(Clone, Copy, PartialEq, Eq)]
enum Expect {
    DocumentEnd,
    Value,
    ArrayFirst,
    ArrayNext,
    ObjectFirst,
    ObjectNext,
    Key,
    Colon,
}

impl Expect {
    fn text(self) -> &'static str {
        match self {
            Expect::DocumentEnd => "the end of the input",
            Expect::Value => "a value",
            Expect::ArrayFirst => "a value or ]",
            Expect::ArrayNext => ", or ]",
            Expect::ObjectFirst => "a string or }",
            Expect::ObjectNext => ", or }",
            Expect::Key => "a string",
            Expect::Colon => "a name separator",
        }
    }
}

struct Structure {
    stack: Vec<Expect>,
    max_depth: usize,
}

impl Structure {
    fn new(max_depth: usize) -> Structure {
        Structure { stack: vec![Expect::DocumentEnd, Expect::Value], max_depth }
    }

    /// The next token, of KIND at offset AT: Ok when the grammar allows it
    /// there (the End token, when it closes a complete value).
    fn feed(&mut self, kind: Kind, at: usize) -> Result<(), JsonError> {
        let Some(e) = self.stack.pop() else {
            return Err(JsonError::Structure { at, expected: "nothing" });
        };
        let unexpected = || JsonError::Structure { at, expected: e.text() };
        match e {
            Expect::DocumentEnd => {
                if kind != Kind::End {
                    return Err(unexpected());
                }
            }
            // A closing bracket where a container may end.
            Expect::ArrayFirst if kind == Kind::EndArray => {}
            Expect::ObjectFirst if kind == Kind::EndObject => {}
            Expect::ArrayNext | Expect::ObjectNext => {
                if (e == Expect::ArrayNext && kind == Kind::EndArray) || (e == Expect::ObjectNext && kind == Kind::EndObject) {
                    return Ok(());
                }
                if kind != Kind::ValueSeparator {
                    return Err(unexpected());
                }
                if e == Expect::ArrayNext {
                    self.stack.extend([Expect::ArrayNext, Expect::Value]);
                } else {
                    self.stack.extend([Expect::ObjectNext, Expect::Value, Expect::Colon, Expect::Key]);
                }
            }
            Expect::Colon => {
                if kind != Kind::NameSeparator {
                    return Err(unexpected());
                }
            }
            Expect::Key | Expect::ObjectFirst => {
                if kind != Kind::String {
                    return Err(unexpected());
                }
                if e == Expect::ObjectFirst {
                    self.stack.extend([Expect::ObjectNext, Expect::Value, Expect::Colon]);
                }
            }
            Expect::Value | Expect::ArrayFirst => {
                if !kind.value_start() {
                    return Err(unexpected());
                }
                if e == Expect::ArrayFirst {
                    self.stack.push(Expect::ArrayNext);
                }
                if kind == Kind::BeginArray {
                    self.stack.push(Expect::ArrayFirst);
                }
                if kind == Kind::BeginObject {
                    self.stack.push(Expect::ObjectFirst);
                }
                // Below the document's end, one entry per open container.
                if self.stack.len() > self.max_depth + 1 {
                    return Err(JsonError::TooDeep { limit: self.max_depth });
                }
            }
        }
        Ok(())
    }
}

// ---------------------------------------------------------------------------
// The tokens: json_lex's recognizers over the driver's one-symbol buffer.

/// validate_text's driver state: the source and its current symbol (None:
/// the end of the input) at offset `at`.
struct Lexer<I: Iterator<Item = char>> {
    src: I,
    at: usize,
    cur: Option<char>,
    max_token: usize,
}

#[derive(Clone, Copy)]
enum Number {
    Minus,
    Zero,
    Integer,
    Point,
    Fraction,
    Exponent,
    ExponentSign,
    ExponentDigits,
}

impl<I: Iterator<Item = char>> Lexer<I> {
    /// The current symbol was taken: read the next.
    fn advance(&mut self) {
        self.at += 1;
        self.cur = self.src.next();
    }

    /// Hand the token that started at START its next symbol.
    fn next_of(&mut self, start: usize) -> Result<Option<char>, JsonError> {
        self.advance();
        if self.at - start >= self.max_token {
            return Err(JsonError::TokenTooLong { at: start, limit: self.max_token });
        }
        Ok(self.cur)
    }

    /// json_string after its opening quote; leaves the symbol after the
    /// closing quote current.
    fn string(&mut self, start: usize) -> Result<(), JsonError> {
        loop {
            match self.next_of(start)? {
                Some('"') => break,
                Some('\\') => self.escape(start)?,
                Some(c) if unescaped(c) => {}
                other => return Err(rejected(self.at, "json_string", other)),
            }
        }
        self.advance();
        Ok(())
    }

    /// json_escape after its backslash.
    fn escape(&mut self, start: usize) -> Result<(), JsonError> {
        match self.next_of(start)? {
            Some('"' | '\\' | '/' | 'b' | 'f' | 'n' | 'r' | 't') => Ok(()),
            Some('u') => {
                for _ in 0..4 {
                    match self.next_of(start)? {
                        Some(c) if c.is_ascii_hexdigit() => {}
                        other => return Err(rejected(self.at, "json_escape", other)),
                    }
                }
                Ok(())
            }
            other => Err(rejected(self.at, "json_escape", other)),
        }
    }

    /// json_number after its first symbol FIRST ('-' or a digit); leaves the
    /// symbol after it current (accept before), or the end.
    fn number(&mut self, first: char, start: usize) -> Result<(), JsonError> {
        let mut state = match first {
            '-' => Number::Minus,
            '0' => Number::Zero,
            _ => Number::Integer,
        };
        loop {
            let x = self.next_of(start)?;
            state = match (state, x) {
                (Number::Minus, Some('0')) => Number::Zero,
                (Number::Minus, Some('1'..='9')) => Number::Integer,
                (Number::Integer, Some('0'..='9')) => Number::Integer,
                (Number::Zero | Number::Integer, Some('.')) => Number::Point,
                (Number::Point | Number::Fraction, Some('0'..='9')) => Number::Fraction,
                (Number::Zero | Number::Integer | Number::Fraction, Some('e' | 'E')) => Number::Exponent,
                (Number::Exponent, Some('+' | '-')) => Number::ExponentSign,
                (Number::Exponent | Number::ExponentSign | Number::ExponentDigits, Some('0'..='9')) => Number::ExponentDigits,
                (Number::Zero | Number::Integer | Number::Fraction | Number::ExponentDigits, Some(c)) if after_value(c) => return Ok(()),
                (Number::Zero | Number::Integer | Number::Fraction | Number::ExponentDigits, None) => return Ok(()),
                (_, other) => return Err(rejected(self.at, "json_number", other)),
            };
        }
    }

    /// json_literal after its first symbol FIRST ('t', 'f' or 'n'); leaves
    /// the symbol after it current, or the end.
    fn literal(&mut self, first: char, start: usize) -> Result<(), JsonError> {
        let rest = match first {
            't' => "rue",
            'f' => "alse",
            _ => "ull",
        };
        for want in rest.chars() {
            match self.next_of(start)? {
                Some(c) if c == want => {}
                other => return Err(rejected(self.at, "json_literal", other)),
            }
        }
        match self.next_of(start)? {
            Some(c) if after_value(c) => Ok(()),
            None => Ok(()),
            other => Err(rejected(self.at, "json_literal", other)),
        }
    }
}

/// Validates the JSON text that CHUNKS hold, split anywhere: the number of
/// tokens and of symbols, or the first error.
fn validate_text(chunks: &[&str], max_depth: usize, max_token: usize) -> Result<Summary, JsonError> {
    let mut lx = Lexer { src: chunks.iter().flat_map(|chunk| chunk.chars()), at: 0, cur: None, max_token };
    lx.cur = lx.src.next();
    let mut parse = Structure::new(max_depth);
    let mut tokens = 0;
    loop {
        let start = lx.at;
        let Some(c) = lx.cur else {
            parse.feed(Kind::End, start)?;
            break;
        };
        if whitespace(c) {
            lx.advance();
            continue;
        }
        // json_token: which token it is is what its first symbol says.
        let kind = match c {
            '{' | '}' | '[' | ']' | ':' | ',' => {
                lx.advance();
                match c {
                    '{' => Kind::BeginObject,
                    '}' => Kind::EndObject,
                    '[' => Kind::BeginArray,
                    ']' => Kind::EndArray,
                    ':' => Kind::NameSeparator,
                    _ => Kind::ValueSeparator,
                }
            }
            '"' => {
                lx.string(start)?;
                Kind::String
            }
            '-' | '0'..='9' => {
                lx.number(c, start)?;
                Kind::Number
            }
            't' | 'f' | 'n' => {
                lx.literal(c, start)?;
                Kind::Literal
            }
            _ => return Err(JsonError::Lexical { at: start, recognizer: "json_token", symbol: c as i64 }),
        };
        parse.feed(kind, start)?;
        tokens += 1;
    }
    Ok(Summary { tokens, symbols: lx.at as i64 })
}

/// The document as json-parse.bot's chunks(n) builds it: never concatenated.
fn run_once(copies: usize, piece: &str, max_depth: usize, max_token: usize) -> Vec<i64> {
    let first = format!("[{}", piece);
    let mut chunks: Vec<&str> = Vec::with_capacity(copies + 1);
    for i in 0..copies {
        chunks.push(if i == 0 { &first } else { piece });
    }
    chunks.push("{}]");
    match validate_text(&chunks, max_depth, max_token) {
        Ok(summary) => vec![summary.tokens, summary.symbols],
        Err(e) => {
            eprintln!("{}", e);
            vec![e.code()]
        }
    }
}

fn show(values: &[i64]) -> String {
    let items: Vec<String> = values.iter().map(|v| v.to_string()).collect();
    format!("[{}]", items.join(", "))
}

fn main() {
    let mut runs: u32 = 5;
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg == "--runs" {
            runs = args.next().expect("--runs needs a value").parse().expect("--runs must be an integer");
        }
    }

    run_once(black_box(COPIES), black_box(PIECE), black_box(MAX_DEPTH), black_box(MAX_TOKEN)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = Vec::new();
    for _ in 0..runs {
        let t0 = Instant::now();
        // black_box on the inputs stops the optimizer from noticing the run
        // is loop-invariant and hoisting it out after the first one.
        value = run_once(black_box(COPIES), black_box(PIECE), black_box(MAX_DEPTH), black_box(MAX_TOKEN));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: {}", show(&value));
    println!("best_us: {:.3}", best);
}
