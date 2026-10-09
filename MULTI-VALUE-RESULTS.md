# Multi-value results: name the parts

> If a result carries more than one value, name the parts.

A Botlish function that produces several separately meaningful values returns
a **struct value**, whose parts have names, not a **List** whose parts have
positions. This is not a new rule. It is the design the language already has,
written down in one place:

| intent | the language's answer | where it is decided |
|---|---|---|
| a sequence of values, of any length | `List` | README section 1, MINIMAL-APPLIED-LIST-TYPES.md |
| a fixed set of separately meaningful parts | a struct value (`{field: f, index: i}`, or a declared `struct`) | STRUCTS.md |
| consume selected parts of a result | struct destructuring, `{field, index} = r` | STRUCT-DESTRUCTURING.md |
| consume a List by position | **not offered**: `[a, b] = r` is the `LIST-DESTRUCTURING` error | STRUCT-DESTRUCTURING.md |

Struct values have named parts and destructure; Lists deliberately do not.
STRUCT-DESTRUCTURING.md states it as language policy ("Lists are intentionally
not destructured positionally. APIs returning heterogeneous values should
prefer struct values with named fields"), and the compiler's own diagnostic for
`[a, b] = value` says the same thing:

```
LIST-DESTRUCTURING: positional List destructuring is not supported; use a struct
value with named fields instead (a List is for a sequence of values; have the
function return a struct, e.g. `result = get_result()` then
`{value, error} = result`)
```

There is no tuple type, and no List pattern will be added to make a list of
two things behave like one.

## The idiom

```botlish
fn scan_quoted(text, index, field) errors LowerUnderrun:
    character = peek(text, index)
    if character == "\"":
        if peek(text, index + 1) == "\"":
            return scan_quoted(text, index + 2, str::concat(field, "\""))

        return {field: field, index: index + 1}

    scan_quoted(text, index + 1, str::concat(field, character))
```

and its callers read the parts by name:

```botlish
scanned = scan_quoted(text, start, "")
more = append_field(fields, scanned.field)
scan_rest(text, scanned.index, more)
```

or destructure them (`{field, index} = scan_quoted(text, start, "")`). This is
exactly the conversion STRUCTS.md made of the corpus's CSV scanners (the scan
pairs `[field, index]` and `[fields, stop]`, the hash-table rehash triple, the
test-selection entity): the struct form kept the per-part types the positional
pair had erased (`scan_field(...)` went from `list` to
`struct{field: str, index: int}`, and `csv_parse` from `list` to
`List[List[str]]`; TYPED-MUTARRAY-BUILDER-REFACTOR.md had traced the lost
types to the pair).

What changes for a caller, in Botlish as it is:

* **A field read is total and checked.** `r.index` cannot fail at run time,
  and a field the result does not have is a compile-time `UNKNOWN-FIELD`. A
  positional read `list::at(r, 1)` is fallible (`IndexNotFound`, which its
  caller must declare or handle) and checked only at run time.
* **The parts keep their own types**: a struct type has one type per field; a
  List has one element type, the join of everything in it.
* **Destructuring** binds the parts in one statement, by name.

## When the result really is a list

Some functions return a fixed number of values that *are* a sequence: the
check results a sample program prints and compares with its `# expect:` line,
a pair of coordinates the caller treats as a vector, a row. The author says so
at the declaration, with a result type:

```botlish
fn sample() -> list errors LowerUnderrun:
    [clean_ai_text("hello"), clean_ai_text("AI—generated")]

fn coords(dx: int, dy: int) -> List[int]:
    [dx, dy]
```

The annotation is an ordinary declared result type: the checker must prove
the function's result satisfies it (`hir::range::verifyDeclaredResults`;
`function result does not prove declared type ...` otherwise; applied List
types are MINIMAL-APPLIED-LIST-TYPES.md's), and every caller sees it. `-> list` is `List[any]`, always provable for a function whose
exits are lists; `-> List[T]` needs the elements proven to be `T`. The
corpus's own sample functions (`examples/stdlib/*.bot`'s `sample` and
`sample_checks`) are declared this way (REFACTOR-WARNINGS-CLEAN.md).

## The warning that points here

`FIXED-ARITY-LIST-RETURN` (WARNINGS-FIXED-ARITY-LIST-RETURN.md, README section
23) reports a function whose every reachable value exit is a written list
literal of the same arity N >= 2: the positional multi-value result this
document describes. It states the shape and names the language's preferred
form:

```
f.bot:10:13: warning: a 2-element list is returned from all 3 value exits; a struct value names the parts (FIXED-ARITY-LIST-RETURN)
```

It prescribes nothing, suggests no field names (naming is the author's: is it
`field`/`index` or `text`/`stop`?), and is silent for a function declared
`-> list` / `-> List[T]`, which is how an author records "this result really
is a list". It invents no preference: the preference is the destructuring
design above.
