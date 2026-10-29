// Rust equivalent of bench/uri-steady.bot: steady-state percent-escaping of
// a small fixed corpus (plain unreserved ASCII, ASCII that needs escaping,
// multi-byte UTF-8, a mixed string), summing each result's length.
//
// Invoked by bench/bench.tcl; see fib.rs for the --runs/value/best_us
// protocol shared by all equivalents.
//
// uri_escape_text is stdlib/web.bot's std::web::uri_escape_text: every
// scalar above 127 becomes the %XX escapes of its UTF-8 bytes, an RFC 3986
// unreserved ASCII character (letters, digits, - . _ ~) is kept, every
// other ASCII character becomes its own %XX, uppercase hex, appended to a
// fresh String per call. A result's length is its count of Unicode scalar
// values, as std::str::length counts (every escaped result is ASCII, so it
// is also its byte length). repeat_uri recurses 2,000 deep as the Botlish
// driver does.
use std::hint::black_box;
use std::time::Instant;

const HEX_DIGITS: &[u8; 16] = b"0123456789ABCDEF";

fn is_unreserved(b: u8) -> bool {
    b.is_ascii_alphanumeric() || matches!(b, b'-' | b'.' | b'_' | b'~')
}

fn push_pct(out: &mut String, b: u8) {
    out.push('%');
    out.push(HEX_DIGITS[(b >> 4) as usize] as char);
    out.push(HEX_DIGITS[(b & 15) as usize] as char);
}

fn uri_escape_text(s: &str) -> String {
    let mut out = String::new();
    for c in s.chars() {
        if (c as u32) > 127 {
            let mut buf = [0u8; 4];
            for &b in c.encode_utf8(&mut buf).as_bytes() {
                push_pct(&mut out, b);
            }
        } else if is_unreserved(c as u8) {
            out.push(c);
        } else {
            push_pct(&mut out, c as u8);
        }
    }
    out
}

fn repeat_uri(corpus: &[&str], i: i64, total: i64, acc: i64) -> i64 {
    if i >= total {
        return acc;
    }
    let text = corpus[(i as usize) % corpus.len()];
    let escaped = uri_escape_text(text);
    repeat_uri(corpus, i + 1, total, acc + escaped.chars().count() as i64)
}

fn main() {
    let mut runs: u32 = 5;
    let mut positional = Vec::new();
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg == "--runs" {
            runs = args.next().expect("--runs needs a value").parse().expect("--runs must be an integer");
        } else {
            positional.push(arg);
        }
    }
    let total: i64 = positional.get(0).map(|s| s.parse().expect("total must be an integer")).unwrap_or(2000);
    let corpus = ["abcXYZ012", "a b+c?", "café", "hello 世界?"];

    repeat_uri(black_box(&corpus), 0, black_box(total), 0); // untimed warmup
    let mut best = f64::MAX;
    let mut value = 0;
    for _ in 0..runs {
        let t0 = Instant::now();
        value = repeat_uri(black_box(&corpus), 0, black_box(total), 0);
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: {}", value);
    println!("best_us: {:.3}", best);
}
