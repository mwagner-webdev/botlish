# lib/web.bot: emailish? (P3: the "." and "@" tests read characters through
# a guarded char_is?; P4: its nested `false` tree is one conjunction and
# domain?'s on-sight rejections leave the loop) and uri_query_value? /
# uri_escape_text (unchanged code, probed as a control). The emailish?
# probes cover every rejection and acceptance path of the grammar: empty
# and missing parts, every position of "@" and ".", doubled and leading
# dots, label characters, TLD length and letters, non-ASCII letters (Tcl's
# alnum/alpha classes) and the local part's punctuation set.
program lib/web.bot

each emailish-accept {{web::emailish?("a@b.co")} {web::emailish?("first.last@example.com")} {web::emailish?("x_y%z+w-v@sub.domain.org")} {web::emailish?("a@b-c.de")} {web::emailish?("é@b.co")} {web::emailish?("a@é.co")} {web::emailish?("a@b.co.uk")} {web::emailish?(".a@b.co")} {web::emailish?("a.@b.co")}}
each emailish-reject-shape {{web::emailish?("")} {web::emailish?("@")} {web::emailish?("a")} {web::emailish?("a@")} {web::emailish?("@b.co")} {web::emailish?("ab.co")} {web::emailish?("a@b")} {web::emailish?("a@b.")} {web::emailish?("a@@b.co")} {web::emailish?("a b@c.de")}}
each emailish-reject-dots {{web::emailish?("a@.b.co")} {web::emailish?("a@b..co")} {web::emailish?("a@..co")} {web::emailish?("a@b.c")} {web::emailish?("a@b.c0")} {web::emailish?("a@b.co.")} {web::emailish?("a@-.co")} {web::emailish?("a@b_c.de")} {web::emailish?("a@b.c-o")}}
each emailish-unicode {{web::emailish?("ü@ö.äü")} {web::emailish?("東京@例え.テスト")} {web::emailish?("a@b.ü")} {web::emailish?("😀@b.co")} {web::emailish?("a@b.😀😀")}}
each uri-query-value {{web::uri_query_value?("")} {web::uri_query_value?("abc")} {web::uri_query_value?("a%20b")} {web::uri_query_value?("a%2")} {web::uri_query_value?("a%2g")} {web::uri_query_value?("a%ab")} {web::uri_query_value?("a b")} {web::uri_query_value?("-._~")} {web::uri_query_value?("é")}}
each uri-escape {{web::uri_escape_text("")} {web::uri_escape_text("a b&c")} {web::uri_escape_text("-._~")} {web::uri_escape_text("é東😀")} {web::uri_escape_text("100%")}}

# Long inputs: valid_from? recurses once per character or escape; its two
# rejections are one exit after P4, and its self-calls must stay in tail
# position (a 40,000-character value runs in constant stack on every backend).
probe uri-query-value-long {fn grow(s: str, n: int) -> str:
    if n <= 0:
        return s
    grow(str::concat(s, "a%41b"), n - 1)
long = grow("", 8000)
[str::length(long), web::uri_query_value?(long), web::uri_query_value?(str::concat(long, "%4")), web::uri_escape_text(str::concat(long, "é")) == str::concat(long, "%C3%A9")]}
probe emailish-long {fn grow(s: str, n: int) -> str:
    if n <= 0:
        return s
    grow(str::concat(s, "ab.cd"), n - 1)
local = grow("x", 2000)
[web::emailish?(str::concat(local, "@example.org")), web::emailish?(str::concat("me@", str::concat(local, "e"))), web::emailish?(str::concat(local, "@x..org"))]}
