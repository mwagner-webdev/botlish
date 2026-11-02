# stdlib/web.bot: emailish? (P3: the "." and "@" tests read characters through
# a guarded char_is?; P4: its nested `false` tree is one conjunction and
# domain?'s on-sight rejections leave the loop) and uri_query_value? /
# uri_escape_text (unchanged code, probed as a control). The emailish?
# probes cover every rejection and acceptance path of the grammar: empty
# and missing parts, every position of "@" and ".", doubled and leading
# dots, label characters, TLD length and letters, non-ASCII letters (Tcl's
# alnum/alpha classes) and the local part's punctuation set.
program stdlib/web.bot

each emailish-accept {{std::web::emailish?("a@b.co")} {std::web::emailish?("first.last@example.com")} {std::web::emailish?("x_y%z+w-v@sub.domain.org")} {std::web::emailish?("a@b-c.de")} {std::web::emailish?("é@b.co")} {std::web::emailish?("a@é.co")} {std::web::emailish?("a@b.co.uk")} {std::web::emailish?(".a@b.co")} {std::web::emailish?("a.@b.co")}}
# The classes as UnicodeChars (UNICODECHAR-CLASSIFIERS.md): a CJK label and
# TLD, a Unicode decimal digit (Nd) in a label and in the TLD, a modifier
# letter (Lm) in the local part, a Roman numeral (Nl, neither class) as the
# TLD.
each emailish-char-classes {{std::web::emailish?("café@例え.テスト")} {std::web::emailish?("a@b٣.co")} {std::web::emailish?("a@b.co٣")} {std::web::emailish?("ʰ@b.co")} {std::web::emailish?("a@b.ⅫⅫ")}}
each emailish-reject-shape {{std::web::emailish?("")} {std::web::emailish?("@")} {std::web::emailish?("a")} {std::web::emailish?("a@")} {std::web::emailish?("@b.co")} {std::web::emailish?("ab.co")} {std::web::emailish?("a@b")} {std::web::emailish?("a@b.")} {std::web::emailish?("a@@b.co")} {std::web::emailish?("a b@c.de")}}
each emailish-reject-dots {{std::web::emailish?("a@.b.co")} {std::web::emailish?("a@b..co")} {std::web::emailish?("a@..co")} {std::web::emailish?("a@b.c")} {std::web::emailish?("a@b.c0")} {std::web::emailish?("a@b.co.")} {std::web::emailish?("a@-.co")} {std::web::emailish?("a@b_c.de")} {std::web::emailish?("a@b.c-o")}}
each emailish-unicode {{std::web::emailish?("ü@ö.äü")} {std::web::emailish?("東京@例え.テスト")} {std::web::emailish?("a@b.ü")} {std::web::emailish?("😀@b.co")} {std::web::emailish?("a@b.😀😀")}}
each uri-query-value {{std::web::uri_query_value?("")} {std::web::uri_query_value?("abc")} {std::web::uri_query_value?("a%20b")} {std::web::uri_query_value?("a%2")} {std::web::uri_query_value?("a%2g")} {std::web::uri_query_value?("a%ab")} {std::web::uri_query_value?("a b")} {std::web::uri_query_value?("-._~")} {std::web::uri_query_value?("é")}}
each uri-escape {{std::web::uri_escape_text("")} {std::web::uri_escape_text("a b&c")} {std::web::uri_escape_text("-._~")} {std::web::uri_escape_text("é東😀")} {std::web::uri_escape_text("100%")}}

# Long inputs: valid_from? recurses once per character or escape; its two
# rejections are one exit after P4, and its self-calls must stay in tail
# position (a 40,000-character value runs in constant stack on every backend).
probe uri-query-value-long {fn grow(s: str, n: int) -> str:
    if n <= 0:
        return s
    grow(std::str::concat(s, "a%41b"), n - 1)
long = grow("", 8000)
[std::str::length(long), std::web::uri_query_value?(long), std::web::uri_query_value?(std::str::concat(long, "%4")), std::web::uri_escape_text(std::str::concat(long, "é")) == std::str::concat(long, "%C3%A9")]}
probe emailish-long {fn grow(s: str, n: int) -> str:
    if n <= 0:
        return s
    grow(std::str::concat(s, "ab.cd"), n - 1)
local = grow("x", 2000)
[std::web::emailish?(std::str::concat(local, "@example.org")), std::web::emailish?(std::str::concat("me@", std::str::concat(local, "e"))), std::web::emailish?(std::str::concat(local, "@x..org"))]}
