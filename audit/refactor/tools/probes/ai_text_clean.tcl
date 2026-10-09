# ai_text_clean.bot (P3): clean_char's comparisons read the character
# (str::char_at of its one-character text) instead of comparing one-character
# Strings; cleaner_emoji takes that character. clean_char's contract (one
# character's text, or "" past the end -> its cleaned text) is unchanged, so
# it is probed directly over its whole documented domain, and clean_ai_text
# over texts mixing every class.
program examples/stdlib/ai_text_clean.bot

probe clean_char-empty {clean_char("")}
each clean_char-ascii {{clean_char("a")} {clean_char("-")} {clean_char("'")} {clean_char("\"")} {clean_char(".")} {clean_char(" ")} {clean_char("\n")}}
each clean_char-targets {{clean_char("–")} {clean_char("—")} {clean_char("‘")} {clean_char("’")} {clean_char("“")} {clean_char("”")} {clean_char("…")}}
each clean_char-emoji {{clean_char("😀")} {clean_char("😂")} {clean_char("🙂")} {clean_char("😍")} {clean_char("🔥")} {clean_char("🚀")} {clean_char("✅")} {clean_char("❌")} {clean_char("🎉")} {clean_char("🤖")} {clean_char("👍")} {clean_char("💡")}}
each clean_char-near-misses {{clean_char("é")} {clean_char("東")} {clean_char("😎")} {clean_char("‐")} {clean_char("„")} {clean_char("‚")}}
probe clean_ai_text-empty {clean_ai_text("")}
probe clean_ai_text-ascii {clean_ai_text("The model generated this sentence.")}
probe clean_ai_text-punctuation {clean_ai_text("“Here’s the result—it’s concise, readable…and ready to use.”")}
probe clean_ai_text-emoji {clean_ai_text("🤖 “Here’s the 東京 report—it’s ready…” 🚀 Grüße from München. 😀😂🙂😍🔥🚀✅❌🎉🤖👍💡")}
each clean_ai_text-adjacent {{clean_ai_text("a🤖b")} {clean_ai_text("é🤖ü")} {clean_ai_text("🤖")} {clean_ai_text("––")} {clean_ai_text("……")}}
