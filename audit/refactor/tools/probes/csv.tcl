# The four CSV programs (P3): the unquoted, field and record scanners read
# characters with str::char_at under a str::length bound; the quoted scanner
# tests for a quote the same way and appends the quote's own text (the
# input's slice it already holds) for a doubled quote. Probed per scanner on
# boundary, empty, ordinary and quoted inputs, and end to end. The
# scanners' error contract gains IndexNotFound (str::char_at's own error for
# an index outside the String) where peek's LowerUnderrun was: identical for
# every index the scan reaches (0 up), different only for a negative one,
# which no caller passes -- shown by the one `differs` probe per program.
# An out-of-range index is hidden from the analysis (`dyn`, 0 at run time):
# with a constant one the compiler may decide the failure statically
# (KNOWN-ERROR), a fact about the probe's constants, not the scanner.
foreach program {examples/stdlib/csv.bot examples/stdlib/csv_chunked.bot examples/stdlib/csv_geometric.bot examples/stdlib/csv_records.bot} {
    program $program
    each scan_unquoted {{scan_unquoted("", 0, 0)} {scan_unquoted("abc", 0, 0)} {scan_unquoted("ab,c", 0, 0)} {scan_unquoted("ab\nc", 1, 1)} {scan_unquoted("a,b", 0, 3)} {scan_unquoted("a,b", 2, 2)} {scan_unquoted("é,ü", 0, 0)} {dyn = hash("probe") - hash("probe")
scan_unquoted("x", 0, 5 + dyn)}}
    each scan_quoted {{scan_quoted("a\"", 0, "")} {scan_quoted("a\"\"b\",", 0, "")} {scan_quoted("\"", 0, "pre")} {scan_quoted("\"\"\"", 0, "")} {scan_quoted("x,\"y", 0, "")} {scan_quoted("é\"", 0, "")}}
    each scan_field {{scan_field("", 0)} {scan_field("abc", 0)} {scan_field("\"a,b\",c", 0)} {scan_field("a,\"b\"", 2)} {scan_field("\"\"", 0)} {scan_field("\"\"\"\"", 0)}}
    each end-to-end {{csv_parse("")} {csv_parse("x")} {csv_parse("a,b,c")} {csv_parse("a,b\nc,d\n")} {csv_parse("a,,c")} {csv_parse(",")} {csv_parse("a,")} {csv_parse(",a")} {csv_parse("a\n\nb")} {csv_parse("name,note\nAlice,\"hello, world\"\nBob,\"said \"\"hello\"\"\"")} {csv_parse("\"\"\"\",x\"\"y")} {csv_parse("\"\"")} {csv_parse("a,\"\",b")} {csv_parse("\"line 1\nline 2\",x\ny,z")} {csv_parse("a\r\nb")} {csv_parse("ä,\"ö,ü\"")} {csv_parse("🙂,x\ny,🙃")}}
    differs negative-index {dyn = hash("probe") - hash("probe")
scan_unquoted("a,b", 0, dyn - 1)} {the out-of-String index error is str::char_at's IndexNotFound, no longer peek's LowerUnderrun}
}

program examples/stdlib/csv.bot
each scan_record {{scan_record("", 0, [])} {scan_record("a,b\nc", 0, [])} {scan_record("a,b", 0, ["z"])} {scan_record("a\"x,y", 0, [])} {scan_record("\"q\"z,w\n", 0, [])} {scan_record("a,b,", 0, [])}}

foreach program {examples/stdlib/csv_geometric.bot examples/stdlib/csv_records.bot} {
    program $program
    each records {{csv_parse("h1,h2\n1,2\n3,4\n")} {csv_parse("\"a\"b,c\n")}}
}

program examples/stdlib/csv_records.bot
each csv_records {{list::length(csv_records(""))} {list::length(csv_records("name,age\n"))} {ht_get(list::at(csv_records("name,age,city\nAlice,31,Berlin\n"), 0), "city")} {ht_get(list::at(csv_records("name,note\nAlice,\"hello, world\"\nBob,\"said \"\"hi\"\"\"\n"), 1), "note")} {ht_size(list::at(csv_records("a,b,c\nx,y\n"), 0))} {ht_get(list::at(csv_records_presized("é,city\nvalue1,München\n"), 0), "é")}}

program examples/stdlib/csv_chunked.bot
each scan_record {{r = scan_record("", 0, chunked_new())
[r.fields, r.stop]} {r = scan_record("a,b\nc", 0, chunked_new())
[r.fields, r.stop]} {r = scan_record("a\"x,y", 0, chunked_new())
[r.fields, r.stop]} {r = scan_record("\"q\"z,w\n", 0, chunked_new())
[r.fields, r.stop]} {r = scan_record("a,b,", 0, chunked_new())
[r.fields, r.stop]}}

foreach program {examples/stdlib/csv_geometric.bot examples/stdlib/csv_records.bot} {
    program $program
    each scan_record {{scan_record("", 0)} {scan_record("a,b\nc", 0)} {scan_record("a\"x,y", 0)} {scan_record("\"q\"z,w\n", 0)} {scan_record("a,b,", 0)} {dyn = hash("probe") - hash("probe")
scan_record("a,b", 4 + dyn)}}
}
