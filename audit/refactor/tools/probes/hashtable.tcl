# hashtable.bot and csv_records.bot's embedded table (P4): ht_find_insert's
# two `return index` exits are one condition (the probed slot ends the
# search: it is empty with no earlier tombstone, or it holds the key), and
# ht_delete's early `return table` is the guard inverted around the
# deletion. Probed through inserts, replacements, deletions, reinsertion
# into tombstones, growth and lookups of present and absent keys.
foreach program {examples/stdlib/hashtable.bot examples/stdlib/csv_records.bot} {
    program $program
    probe insert-replace {t = ht_set(ht_set(ht_set(ht_new(), "a", 1), "b", 2), "a", 3)
[ht_get(t, "a"), ht_get(t, "b"), ht_get(t, "c"), ht_size(t), ht_contains(t, "b")]}
    probe grow {fn fill(t, i, n) errors IndexNotFound:
    if i >= n:
        return t
    fill(ht_set(t, i, i * i), i + 1, n)
t = fill(ht_new(), 0, 40)
[ht_size(t), ht_get(t, 0), ht_get(t, 17), ht_get(t, 39), ht_get(t, 40), ht_capacity(t)]}
}
program examples/stdlib/hashtable.bot
probe delete-reinsert {t1 = ht_set(ht_set(ht_set(ht_new(), "a", 1), "b", 2), "c", 3)
t2 = ht_delete(t1, "b")
t3 = ht_delete(t2, "zz")
t4 = ht_set(t3, "b", 20)
t5 = ht_set(t4, "d", 4)
[ht_get(t2, "b"), ht_size(t3), ht_tombstones(t3), ht_get(t4, "b"), ht_size(t5), ht_tombstones(t5), ht_contains(t5, "a"), ht_get(t5, "d")]}
probe delete-all {fn fill(t, i, n) errors IndexNotFound:
    if i >= n:
        return t
    fill(ht_set(t, i, i), i + 1, n)
fn drop(t, i, n) errors IndexNotFound:
    if i >= n:
        return t
    drop(ht_delete(t, i), i + 1, n)
t = drop(fill(ht_new(), 0, 12), 0, 12)
u = fill(t, 100, 106)
[ht_size(t), ht_tombstones(t), ht_size(u), ht_get(u, 103), ht_get(u, 3)]}
