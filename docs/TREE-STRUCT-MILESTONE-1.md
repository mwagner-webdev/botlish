# Tree structs: minimal recursive value trees (milestone 1)

> `tree struct` permits recursive structure without introducing recursive
> reference semantics. The recursive fields describe what the value means;
> how the runtimes hold the recursion is representation.

## 1. Result

Botlish can now define a finite recursive ordered tree as an ordinary
immutable value, pass and return it, extract subtrees, compare and hash it
coherently, use it wherever its payload makes it Equatable or Hashable, and
traverse it generically in preorder DFS or BFS, while no program can observe
or depend on the physical indirection used to represent recursion:

```botlish
import std::coroutine
import std::tree

tree struct FileTree:
    path: str
    children: List[FileTree]

src = FileTree {path: "/src", children: [FileTree {path: "/src/main.bot", children: []}]}
root = FileTree {path: "/", children: [src, FileTree {path: "/README.md", children: []}]}

coroutine {step, first} = std::tree::walk(root, std::tree::Order::BreadthFirst)
# first.path == "/"; each step() is the next FileTree, "/src", "/README.md",
# "/src/main.bot"; std::coroutine::done?(step) once the last is handed over.
```

* **One declaration modifier, one shape.** `tree struct NAME[SLOTS]:` is an
  ordinary struct declaration with exactly one recursive field -- the *child
  field*, of type exactly `List[Self]` (Self the declaration applied to its
  own slots in order) -- and no other mention of itself. Every other
  recursive shape is a specific diagnostic (TREE-STRUCT-SHAPE), and so are
  the combinations a tree cannot have (TREE-STRUCT-COMBINATION: opaque,
  context, an identity clause) and an affine tree (AFFINE-CONTAINER-
  UNSUPPORTED, now also through an application such as `Node[Coroutine...]`).
* **A value, structurally.** Construction, field access, destructuring,
  binding, arguments, results, List storage and module privacy are the
  ordinary struct operations, unchanged. `==` compares the declaration,
  every field and the children in order; the public hash and the keyed
  table hash read the same, in order. Two trees built through different
  histories but equal as trees are equal and hash equally (bit for bit what
  the same values hash to as an ordinary struct: the independent Hashable
  oracle checks it).
* **No depth limit from the host.** Equality, both hashes and the printer of
  a tree walk its topology with work stacks of their own in both runtimes.
  A chain a million nodes deep compares, hashes and is walked natively on a
  1 MiB worker stack; a 60,000-deep chain compares on the Tcl compiler,
  where the same value declared as an ordinary struct stops with TCL LIMIT
  STACK (and natively, at 100,000 deep on a 2 MiB stack, NATIVE LIMIT
  STACK).
* **Totality by the payload.** `Node[T]` is Equatable / Hashable exactly
  when its fields other than the child field are: `Node[int]`,
  `Node[List[int]]` and a tree holding an ImmutableMap are Hashable (MutableMap
  keys, set members), `Node[MutableVector[int]]` and a tree of functions are
  neither, and the reason names the payload field.
* **`std::tree::walk(root, order)`** is an ordinary coroutine, written in
  ordinary Botlish (stdlib/tree.bot), handing over every node -- each
  subtree value, root first, of the tree's own type -- in
  `std::tree::Order::DepthFirst` (preorder) or `BreadthFirst` order. No
  children callback: the declaration names the child field. Depth-first
  keeps an explicit stack (O(depth x widest child count)), breadth-first a
  queue whose visited prefix is dropped as it grows (O(widest level)).
* **Every backend, the same meaning.** The interpreter, the Tcl compiler,
  cranelift-generic and cranelift agree on every test, the golden suite,
  the fuzzer's model, and standalone executables (the program descriptor
  carries each tree shape's child slot).

Three pre-existing gaps were found on the way and are closed (sections 3,
12, 20): coroutine constructions ignored the semantic instance of their root
call, the generic-liveness analysis did not see calls inside a coroutine
construction, and the program-boundary scan of a Tcl result recursed. One is
reported and left open: an application of an ordinary parameterized struct
to an affine type is treated as unrestricted.

## 2. Starting problem

Botlish already accepted recursive struct declarations (STRUCTS.md: "a
struct may name a struct declared later, itself, or a cycle"), so

```botlish
struct Node:
    value: int
    children: List[Node]
```

was an ordinary type with ordinary values -- immutable, with no node
identity. What it did not have:

* **No depth guarantee.** Equality, both hashes and the printer recursed on
  the host: core::value::equal, core::hashing::Encode and core::value::show
  are Tcl procedures nested per level (twice per tree level: the struct and
  its child List), and the native `equal`, `walk` (hashing) and `show_into`
  Rust functions likewise. Measured before this milestone (the same
  programs, declared `struct`):

  | operation, chain depth | Tcl compile backend (limit 100,000 nested evaluations) | native, 1 GiB worker stack | native, 2 MiB stack |
  |---|---|---|---|
  | `==`, 100,000 | TCL LIMIT STACK | ok | NATIVE LIMIT STACK |
  | `==`, 60,000 | TCL LIMIT STACK | ok | -- |
  | `hash`, 100,000 | TCL LIMIT STACK | ok | -- |
  | `==`, 3,000,000 | -- | ok (7.6 s) | -- |
  | `hash`, 3,000,000 | -- | NATIVE LIMIT STACK | -- |

  A native library runs on its caller's stack, so the 2 MiB column is a
  realistic host, not a contrived one.
* **No generic traversal.** Visiting a tree meant writing a recursive
  function per type (recursion again) or an explicit stack by hand; a
  generic one needs the child field, which no declaration named.
* **No designated shape.** Any recursion was accepted -- a field of Self, a
  map of Self, mutual recursion -- so nothing could promise depth-unbounded
  operations or a traversal for "recursive structs" in general.

## 3. Architecture census

| Concern | Where it lives | What this milestone did |
|---|---|---|
| declaration syntax | surface/parser.tcl `structModifiers`, `StructDecl` | `tree` joins `opaque`, `context` as a contextual modifier (`tree 1`, `treeSpan` on the node, only when written) |
| declaration semantics | hir/structs.tcl `apply`, the registry | `ValidateTree` after every field type of the batch is resolved; the registry's and the sourceTypes entry's `tree FIELD` |
| totality (Equatable, Hashable) | hir/types.tcl `Totality` | the child field skipped explicitly for a tree struct |
| HIR text | hir/format.tcl `TypeDecl`, hir/read.tcl `StructDeclLine` | `tree FIELD` printed and read back (checked to be a field) |
| interchange, isolation | hir/interchange.tcl (the HIR dict), hir/declarations.tcl (the registry wholesale) | nothing to add: the entry and the registry carry `tree` |
| Tcl runtime equality, hash, display | core/value.tcl, core/hashing.tcl | a tree test installed by the registry (`setTreeTest`), `TreeEqual`, `TreeShow`, `TreeEncode` |
| native shape metadata | NIR `shape ... tree="F"` (nir.rs), `ShapeInfo::tree`, program descriptor (format 3) | the child slot, by field name in NIR, by slot at run time |
| native equality, hash, display | ops.rs `equal`, `walk` and the `CanonicalSink`s, show.rs | `tree_equal`, `tree_walk` (with the sinks' `open_nested`/`close_nested`), `tree_show` |
| generic child access | (none) | core/tree.tcl's internal `std::tree::children`, `-result-shape tree-children`; native `structget` or `treechildren` |
| traversal | (none) | stdlib/tree.bot: `Order`, `walk` |
| typing a construction | hir/coroutines.tcl `ShapeResult` (coroutine-create), `Outward` | the root call's semantic instance's outward type (`InstanceOutward`, `hir::semantic::ConstructionOutward`) |
| generic liveness | hir/structs.tcl `GenericLive` | a call inside a coroutine construction's thunk is the constructing block's |

Two facts shaped the design more than any other:

* **The value runtime already had the right representation** (section 4):
  nothing about a tree's storage needed to change, only how three walks
  traverse it.
* **A coroutine constructed from an untyped function yielded `any`.**
  `coroutine {step, first} = gen(x)` typed the handle from `gen`'s generic
  analysis even when the call `gen(x)` had a semantic instance (an ordinary
  call `gen(x)` was typed by it: OPPORTUNISTIC-SEMANTIC-INSTANCES.md), and
  from a declared result `-> T` with the imprint variable left rigid. A
  generic walk could therefore not hand over nodes of the tree's own type.
  The fix is general (section 12): a construction is typed by its root
  call's instance exactly as a call is.

## 4. Chosen representation and alternatives

Three representations were weighed.

* **A. Direct recursive heap nodes (chosen).** A tree is what an ordinary
  struct value already is: natively a struct object whose child field is a
  List object holding its children's struct objects; in the Tcl runtimes a
  `{struct SHAPE VALUES}` value whose child slot is a `{list ITEMS}` of
  them. Nothing in it is observable: struct values are immutable, there is
  no address, identity or parent link a program can read, and a subtree is
  the value the List holds. Construction allocates one struct and one List
  per node (measured: section 18); the native collector's mark phase is
  already an explicit work list (heap.rs), so GC tracing of a deep tree
  never recursed; extracting a subtree is a field read, O(1), with no copy.
  The Tcl and native runtimes hold the same shape, so parity is the shape's.
* **B. An arena-backed tree** (one buffer of nodes, children as index
  ranges). Compact, BFS-friendly construction and cheap traversal, but a
  subtree value would be `{arena, root index}`: either a copy on extraction
  (O(subtree)) or an arena shared between values whose equality and hash
  must then ignore indices, offsets and capacities -- a representation that
  is much easier to leak than to hide. It needs a new runtime kind in both
  runtimes (tracing, equality, hashing, printing, the descriptor, the Tcl
  value form), and construction from ordinary struct syntax would have to
  re-pack children into the parent's arena (O(subtree) per construction:
  O(n^2) for a chain built bottom-up). None of the measurements below shows
  a cost the arena would recover that justifies that.
* **C. Something the value runtime already suggests.** The Tcl runtime's
  values are immutable nested lists and the native List is an immutable
  `Value` array: both are A already. Interning or hash-consing equal
  subtrees (DAG sharing) would make equality O(1) for shared subtrees, but
  it is an optimization with its own costs (a global table, hashing every
  construction) and nothing in this milestone needs it.

**Decision: A**, with the depth problem solved where it actually was -- in
the three walks over the value -- not in the storage. The representation is
pinned as non-semantic by tests and mutants: trees built bottom-up by
recursion, child by child through `std::list::append`, and level by level
from the leaves through a vector compare equal, hash equally under both
hashes and walk alike (`ts-representation-independence`); the mutants
`native-equality-reads-addresses` and `native-hash-reads-addresses` (equality
or a hash reading object addresses, the only physical fact this
representation has) are killed.

## 5. Source syntax

```botlish
tree struct Node:
    value: int
    children: List[Node]

tree struct Node[T]:                    # the existing parameterized-struct syntax
    value: T
    children: List[Node[T]]

private tree struct Outline:            # module privacy: an ordinary declaration
    title: str
    sections: List[Outline]
```

`tree` is contextual (surface/parser.tcl): a modifier only in the words
before `struct`, like `opaque` and `context`; a variable, function, field or
struct named `tree` is ordinary (`ts-decl-tree-is-contextual`). A tree struct
is constructed, projected and destructured with the ordinary struct syntax.
No tree builder, no special literal.

## 6. Recursive-shape validation

hir/structs.tcl's `ValidateTree`, run once every field type of the batch is
resolved (a field may reach other declarations' fields):

* exactly one field whose type is exactly `List[Self]`: none, or a second, is
  TREE-STRUCT-SHAPE ("has no recursive field", "has a second recursive
  field");
* no other occurrence of the declaration in any field type, found by
  `TreeOccurrence`, which names how: Self itself (`child: Node`), nested
  deeper (`List[List[Node]]`), inside a MutableVector, MutableArray,
  ImmutableSet, function or coroutine type, as an argument of another type
  constructor (`std::immutable_map::ImmutableMap[str, Node]`), another
  application of a parameterized declaration (`List[Node[int]]` in
  `Node[T]`), or reached again through another declaration's fields (mutual
  recursion, directly or through an ordinary struct);
* an unapplied `List[Node]` inside `Node[T]` is the ordinary arity error
  (TYPE).

Every message ends with the rule: "a tree struct has exactly one recursive
field, of type List[Node]". An `Optional[Self]` has no spelling (Botlish has
no Optional type) and an alias has no type-level spelling either: the
accepted form is mechanically the declaration's own text. The boundary is
intentional: what a tree struct promises -- depth-unbounded equality,
hashing, printing and traversal over one ordered child edge -- holds for
this shape, and a general recursive type remains an ordinary `struct`'s.

## 7. Value semantics

A tree's value is the finite rooted ordered tree its fields describe:

| semantic | representation (never observed) |
|---|---|
| the declaration identity | the struct object, its shape number |
| every other field's value | the field slots |
| the number of children and their order | the child List object |
| each child's complete recursive value | the children's objects, their addresses |

Two independently constructed trees with the same ordered value are equal.
A tree has no node identity: two equal subtrees are two occurrences of the
value (compared, hashed and visited twice; `ts-repeated-subtrees`), whether
or not they happen to be one object. Values are built only from children
that already exist, so every tree is finite and acyclic by construction.

## 8. Equality and hash integration

Equality and both hashes of a tree are exactly an ordinary struct's -- the
same comparisons in the same order, the same canonical input byte for byte
-- computed without the host's recursion:

* **Equality** (core/value.tcl `TreeEqual`, ops.rs `tree_equal`): a stack
  of frames "slots I.. of two nodes" and "child pairs I.. of two equal-length
  child Lists", run in the recursive comparison's order: slot by slot, the
  child List's length before its elements, each child completely before the
  next slot. The first unequal pair answers false; a refusal (EQUALITY, a
  payload with no equality) propagates as it did.
* **Public hash** (FNV-1a; a nested value is its sub-hash): the post-order
  fold of every node's input (Tcl `TreeEncodePublic`, native `tree_walk`
  over the `Fnv` sink, whose `open_nested`/`close_nested` keep the enclosing
  states on a heap vector).
* **Table hash** (SipHash-1-3; a nested value inline): the pre-order stream
  of the same input (Tcl `TreeEncodeTable`, native `tree_walk` over `Sip`,
  where opening and closing a nested value write nothing).

The hash input is "declaration identity, the field count, each slot's name
and value in order, the child List as a List of nested values" -- the struct
encoding HASHABLE-AND-KEYED-HASH.md already specifies, so nothing new is
specified and the independent Hashable oracle (audit/hashable/tools/oracle.py)
computes a tree's hashes unchanged. A tree's hash is its plain struct's
(`ts-printing-same-as-struct`, the Rust test `tree_walks_are_the_struct_walks`).
No user code runs inside equality or hashing; no `identity` clause is
allowed on a tree (one obvious meaning: TREE-STRUCT-COMBINATION).

A payload with its own representation-independent identity composes through
the ordinary machinery: a tree whose `attrs: ImmutableMap[str, int]` were
built in different orders is equal and equally hashed
(`ts-identity-payload`).

## 9. Equatable / Hashable totality

`hir::types::Totality` (the one walk behind HashClass, IsHashable,
IsEqualityTotal, Equatable and Hashable) skips exactly a tree struct's child
field: the child values have the same application and add no independent
requirement, so a tree application is total exactly when its other fields
are. (The walk's `seen` guard already treated a revisited struct as total;
the explicit skip makes the rule the declaration's, and the mutant that walks
the child field as an independent requirement -- infinitely -- is killed.)

| application | Equatable | Hashable |
|---|---|---|
| `Node[int]`, `Node[List[int]]`, `Node[str]` | yes | yes |
| a tree with an `ImmutableMap[str, int]` field | yes | yes |
| `Node[Fn{...}]` | no | no (TRAIT-NOT-SATISFIED names field "label", never the child field) |
| `Node[MutableVector[int]]` | no | no |
| `Node[any]` | not known | not known |

## 10. Runtime representation

Unchanged storage (section 4); added metadata only:

* **Tcl**: `core::value::setTreeTest hir::structs::RuntimeTree` -- a named
  struct identity's child slot, or "" -- installed beside the identity and
  opacity tests. Core IR text has no declarations, as before.
* **Native**: NIR `shape N named "Node" tree="children" fields="value
  children"`; `ShapeInfo::tree: Option<usize>`; the program descriptor
  (executables, native libraries) records it (format 2 -> 3), so a standalone
  executable compares a 300,000-deep chain on a 1 MiB stack (`ts-executable`;
  the mutant `native-descriptor-drops-tree` is killed).

The program-boundary scan of a Tcl program's value for blocks
(`core::value::containsBlock`) is now a work list too: it recursed per level
and stopped a deep tree result.

## 11. Subtree semantics

`t.children.at(0)`, a destructured `{children: kids} = t`, and every node a
walk hands over is the subtree value: equal to an independently built tree,
unchanged by building another tree around it, never a handle into its parent
(`ts-subtree-is-a-value`, `ts-walk-yields-subtrees`). Natively it is the
child's object, shared as every immutable value is; no operation on it can
reach its parent or change anything another value sees. Nothing like
`TreeEntry`, `NodeRef`, `TreeCursor` or `TreeHandle` exists.

## 12. DFS/BFS traversal

```botlish
enum Order:                  # std::tree::Order
    DepthFirst,
    BreadthFirst,

nomethod fn walk(root, order: Order)   # std::tree::walk
```

`walk` is an ordinary coroutine (COROUTINES.md): the first segment hands over
the first node, each resume the next, and the last node is its result
(`std::coroutine::done?` is true once it is handed over). A tree has at least
one node, so nothing is ever "exhausted":

```botlish
coroutine {step, first} = std::tree::walk(root, std::tree::Order::BreadthFirst)
use(first)
loop:
    if std::coroutine::done?(step):
        break
    use(step())
```

(Coroutines are not iterators in Botlish -- no `loop x in coroutine` -- so the
consumer is this loop.)

* **DepthFirst is preorder**: a node, then each child's subtree, first to
  last. For A(B(D, E), C): A B D E C.
* **BreadthFirst** hands over every node at depth N before any at depth N +
  1, each parent's children in order: A B C D E.
* No visited set, no cycle detection: a tree is a tree by construction.

**Implementation** (stdlib/tree.bot): one function whose every yield is its
own; a MutableVector of pending nodes used as a stack (children pushed last
to first) or as a queue (a head position; when at least half of a queue of
64 or more is visited, the unvisited rest is moved to the front, so each node
moves at most once per halving). The child field is read by the internal
`std::tree::children` (core/tree.tcl; `declareInternalMember`: a program reads
a tree's children as its field). Statically its argument must be proven a
tree struct's value where it runs (`TreeChildrenProblem`): an unknown type is
UNPROVEN-FIELD, curable by semantic instances like a projection; a value of
another type is TREE-OPERAND, reported at the user's call as "call to
std::tree::walk with root : int ... is invalid: a tree's children are taken
of a value of a tree struct, but this value's type is int". Its result type
is the tree's child field type for the application (`-result-shape
tree-children`). Native code reads the slot the static type names
(`structget`), and only where no static type names one -- cranelift-generic
compiles `walk`'s generic body once -- the runtime reads the slot the value's
shape records (`treechildren`, `rt_tree_children`).

**Typing the nodes.** `walk` is untyped in `root`, so its nodes are typed by
the call's semantic instance. Two pre-existing gaps had to close for that:

* **Constructions ignored instances.** hir/coroutines.tcl's
  `coroutine-create` typed the handle from the root's generic analysis. Now
  a semantic instance records its *outward* type (its result joined with
  what its own yields send, under its entry types:
  `hir::semantic::Outward`), and a construction whose root call has an
  instance takes it (`hir::coroutines::InstanceOutward`, joined with the
  generic types of any other function's yields the coroutine reaches, and
  only where it refines the generic outward type). Outside an inference run
  (hir/specialize.tcl's codegen typing) the instance the run left in HIR
  answers, as `GenericResult` does for ordinary calls. A declared result
  stays the outward type. This is general: any coroutine constructed from an
  untyped function now yields what its instance proves
  (`ts-generic-construction-typed`).
* **Generic liveness did not see thunks.** `hir::structs::GenericLive`
  decides whether an unproven projection's function can run generically; it
  treated a coroutine construction's thunk as a block of its own that nothing
  calls, so a function reached only as a coroutine's root was never live,
  its unproven projections were never reported, and native lowering then
  failed with NATIVE UNSUPPORTED struct-shape on a program the front end had
  accepted (reproduced before the change: a `gen(t)` projecting `t.x`,
  constructed from an escaping untyped function). A thunk takes no argument
  and runs exactly when its constructing block does, so its call is now that
  block's. Callback lambdas keep their old treatment (they run through
  instances).

**Measured costs** (section 18): DFS O(n) time and O(depth x widest child
count) auxiliary nodes; BFS O(n) time and O(widest level) auxiliary nodes.

## 13. HIR / NIR / interchange

* HIR `sourceTypes` struct entry: `tree FIELD`, present only for a tree
  struct; the registry entry likewise (`hir::structs::treeField`,
  `RuntimeTree`). Tree-ness is never inferred from a recursive field.
* HIR text: `struct Node name Node ns - tree children fields value: int,
  children: List[Node]` (with slots: `... slots [T] tree kids fields ...`),
  read back and checked (`ts-hir-text`, `ts-hir-text-unknown-tree-field`).
* Interchange carries the HIR dict and the declarations registry: a tree read
  back after another compilation declared `Node` as an ordinary struct still
  walks and compares as a tree on every backend (`ts-interchange`); so does a
  HIR run after such a compilation (`ts-compilation-isolation`).
* NIR: `tree="FIELD"` on the shape (`ts-nir-shape`); the program descriptor,
  format 3.

## 14. Diagnostics

| kind | when |
|---|---|
| TREE-STRUCT-SHAPE | no `List[Self]` field; a second one; Self as a field; nested deeper; inside another container, map, set, function or coroutine type; another application of the declaration; mutual recursion |
| TREE-STRUCT-COMBINATION | `opaque tree struct`, `tree context struct`, an `identity` clause on a tree struct |
| AFFINE-CONTAINER-UNSUPPORTED | a tree struct with an affine field; a tree struct applied to an affine type (a construction, a declared type) |
| TREE-OPERAND | std::tree::walk of a value of a known type that is no tree struct's (seen by a program as its call's TYPE) |
| UNPROVEN-FIELD | std::tree::walk of a value whose tree type is not known where the walk may run generically |
| SYNTAX | `tree tree struct` (duplicate modifier) |

None names a runtime representation. Every kind is classified in
tests/static-compile.test's census (declarations; TREE-OPERAND as
`stdlib-internal`) and has a Compilerpedia topic with rejected examples
(compilerpedia/topics/trees.topic: `concept.tree-structs`,
`error.tree-struct-shape`, `error.tree-struct-combination`,
`error.tree-operand`).

**Why opaque trees are rejected.** `walk` takes any tree apart into its
subtrees, which for an opaque struct only its owning module may do
(OPAQUE-STRUCTS.md). Rather than give the walk an authority check, an owner
who wants a hidden tree wraps a tree struct in an opaque struct of its own.

## 15. Deep/wide-tree evidence

| test | backends | what |
|---|---|---|
| `ts-deep-chain` | all four | a 20,000-deep chain (twenty times the test harness's recursion limit): built, `==` true and false near the leaf, both hashes, DFS and BFS digests |
| `ts-deep-chain-print` | all four | a 3,000-deep chain printed (94,922 characters, identical everywhere) |
| `ts-deep-native` | cranelift, 1 MiB worker stack | a 1,000,000-deep chain: `==`, hashes, both walks |
| `ts-executable` | standalone executable, 1 MiB stack | a 300,000-deep chain compared |
| Rust `deep_trees_need_no_host_stack` | a 256 KiB thread | a 200,000-deep chain: `==`, both hashes, `show` |
| `ts-wide` | compile, cranelift-generic, cranelift | a root with 30,000 children of one child each: order, `==`, hashes, both walks (the BFS queue compacts) |
| `ts-wide-interp` | all four | a 2,000-child root |

Before/after on the same programs (section 2's table, re-run with `tree
struct`): the 100,000-deep chain on a 2 MiB native stack and the 60,000-deep
chain on the Tcl compiler now compare and hash (`[true, true]`).

## 16. Oracle/fuzzing

audit/tree-struct/tools/oracle.py is an independent model written from the
rules: its own iterative preorder, breadth-first order and structural
equality, and the exact hashes through the Hashable oracle
(audit/hashable/tools/oracle.py, imported by path, never copied: a tree's
canonical input is its struct's). Its selftest reproduces the milestone's
pinned public hashes from the struct encoding alone.

audit/tree-struct/tools/fuzz.tcl generates programs over one declaration (a
plain tree with a str payload, or `T[P]` applied to int, str or List[int]):
a random base tree biased toward unary chains (up to `-deep` nodes), broad
roots, balanced trees, repeated equal subtrees and empty child Lists; the
same tree rebuilt another way (nested construction, and postorder assembly
through a vector); variants with one payload changed (a random node or the
deepest leaf), two siblings swapped, a child inserted or removed. Each
program observes every tree's preorder and breadth-first ids through
`std::tree::walk`, every pair's `==`, every tree's exact public and table
hash (fixed key {1 2}, privileged fixture module), and the trees as
MutableMap keys (the distinct count, each tree's first equal index).

Runs on the final tree (`-n 12` per seed; the interpreter every third
program, the three other backends always):

| seed | programs | observations | backend runs | disagreements |
|---|---:|---:|---:|---:|
| 1 | 12 | 3,890 | 40 | 0 |
| 2 | 12 | 4,748 | 40 | 0 |
| 3 | 12 | 5,852 | 40 | 0 |
| 4, `-gc-stress 1` (compile, cranelift, and cranelift under BOTLISH_NATIVE_GC_STRESS=1) | 8 | 4,715 | 24 | 0 |

Every observation is checked exactly: every walk's sequence, every pair's
`==`, every exact public and table hash, every MutableMap answer.

## 17. Mutation testing

audit/tree-struct/tools/mutate.tcl (value-identity's harness: a private copy
per job, native mutants rebuilt there) runs tests/tree-struct.test and the
fuzzer against each mutant of audit/tree-struct/tools/mutants.txt -- every
family the brief names: child order ignored in equality and in hash (Tcl and
native); children ignored; children compared by backing identity; equality
or a hash reading object addresses (this representation's analog of a node
index); the declaration identity omitted from a hash; public and keyed hash
disagreeing structurally (Tcl and native); Equatable or Hashable admitted
regardless of the payload; the child field walked as an infinite totality
recursion, or treated as unknown; DFS walking breadth-first and BFS
depth-first; sibling order reversed in either; the root omitted or
duplicated; leaves skipped; BFS compaction losing a node; HIR text dropping
the designation or the child field; the program descriptor and the NIR shape
dropping the tree slot; the Tcl tree test not installed; equality replaced by
reference identity; the native printer reversing children; the declaration
checks admitting a second recursive field, a field of Self, mutual
recursion, an opaque tree or an affine application; unproven children
accepted; thunks invisible to generic liveness again; constructions typed
generically again, or by the instance's result only; the children's result
typed List[any].

**Result: 42 mutants, 42 killed** (every mutant applies to the final
sources). The run (`-jobs 3`, plus the last six native mutants in a second
copy to share the serial native rebuilds) first left three survivors, each
of which taught something and was answered in the tests or the mutant:

* `totality-child-infinite` survived as first written: dropping the last
  entry of `seen` was equivalent, because the application is added to
  `seen` by the later `Components` call anyway. Rewritten to walk the child
  field with the outer `seen` (the real infinite recursion), it is killed by
  every test that types a tree.
* `construction-outward-result-only` (a construction typed by the instance's
  result alone, without its yields) survived because every generator in the
  tests yielded and returned one type. `ts-generic-construction-typed` now
  also constructs a generator that yields a `List[Node]` and returns `[]`
  (`List[never]`), which kills it.
* `native-show-children-reversed` survived because a test reads native
  results through `tcl_value` and the Tcl printer; only an executable prints
  its own result with the native printer. `ts-executable` now prints a tree,
  which kills it.

What killed the others (the first detector to fail, the test file): the Tcl
and native equality, hash and printer mutants by `ts-equality`,
`ts-hash-oracle`, `ts-hash-pinned`, `ts-printing-same-as-struct`,
`ts-representation-independence` and the deep and wide tests (a backend
disagreeing with the others fails `sourceAgree`); the address-reading
mutants by `ts-representation-independence` and `ts-hash-coherent`; the
descriptor's and the NIR shape's by `ts-executable`, `ts-nir-shape` and
`ts-deep-native` (a dropped tree slot sends a deep chain back to the host's
recursion, NATIVE LIMIT STACK on a 1 MiB stack); the totality mutants by
`ts-totality-refused`, `ts-totality-walk` and `ts-totality-witnesses`; the
traversal mutants by `ts-walk-orders`, `ts-walk-levels`, `ts-wide` and the
filesystem specimen; the HIR text mutants by `ts-hir-text`; the declaration
mutants by `ts-decl-shapes-rejected`, `ts-decl-combinations` and
`ts-decl-affine`; the liveness and typing mutants by `ts-walk-generic-caller`
and every walk test. No mutant needed the fuzzer to be killed: the test file
caught every one first, and the fuzzer is the second detector.

The three trait-constrained-types mutants that quote `ApplicationProblem`'s
callers were updated to the refactored `ApplicationIssue` (the same rules)
and are killed (`audit/trait-constrained-types/tools/mutate.tcl -only` the
three).

## 18. Performance

`tclsh9.0 bench/tree-struct.tcl` (native cranelift; best of 3 runs; per-node
times are differences of runs with 1 and 1 + P passes, so building the trees
compared cancels). "plain" is the same declaration as an ordinary recursive
struct: the very same values, compared and hashed by the host's recursion,
traversed by hand -- the closest pre-milestone representation.

Run on a 4-core Linux x86-64 container, the benchmark at a higher
priority than a mutation run that occupied the other cores (so single-
thread timings, but noisy: differences under about 20% are within
run-to-run variation). Per-node nanoseconds at N = 65,536 (the 1,024 runs
agree within noise: no per-node cost grows with N), managed allocations
per node from the allocation report, and the peak live bytes per node of a
one-pass run:

| shape | mode | tree ns/node | plain ns/node | tree allocations/node | tree peak bytes/node |
|---|---|---:|---:|---:|---:|
| chain | build | 180 | 175 | 2.000 | 80 |
| chain | eq-equal | 29 | 54 | 0 | 160 (two trees) |
| chain | eq-late | 21 | 38 | 0 | 160 |
| chain | hash | 60 | 49 | 0 | 80 |
| chain | table-hash | 91 | 117 | 0 | 80 |
| chain | dfs (walk) | 21 | -- | 0.0001 | 80 |
| chain | bfs (walk) | 50 | -- | 0.047 | 82 |
| chain | manual-dfs | 6 | 14 | 0.0000 | 80 |
| balanced | build | 246 | 249 | 2.703 | 108 |
| balanced | eq-equal | 57 | 56 | 0 | 216 |
| balanced | eq-late | 40 | 56 | 0 | 216 |
| balanced | hash | 85 | 78 | 0 | 108 |
| balanced | table-hash | 135 | 120 | 0 | 108 |
| balanced | dfs (walk) | 38 | -- | 0.0001 | 108 |
| balanced | bfs (walk) | 112 | -- | 0.0006 | 127 |
| balanced | manual-dfs | 39 | 63 | 0.0000 | 108 |
| wide | build | 172 | 186 | 2.000 | 88 |
| wide | eq-equal | 7 | 12 | 0 | 168 |
| wide | eq-late | 29 | 28 | 0 | 168 |
| wide | hash | 30 | 57 | 0 | 88 |
| wide | table-hash | 73 | 91 | 0 | 88 |
| wide | dfs (walk) | 23 | -- | 0.0001 | 88 |
| wide | bfs (walk) | 84 | -- | 0.0005 | 96 |
| wide | manual-dfs | 19 | 23 | 0.0000 | 88 |

(The raw rows, both sizes and every mode, are bench/tree-struct.tcl's
output; `eq-early` -- trees whose roots differ -- is one comparison of a
constant cost, below the run-to-run noise of building the trees it is a
difference from at both sizes, so its per-comparison column is noise and
left out.)

What the numbers establish:

* **No accidental O(n^2).** Every per-node cost is flat from 1,024 to 65,536
  nodes; the deep chain's equality and hashes run at the same per-node cost
  as the balanced and wide trees'.
* **The iterative walks cost what recursion cost.** Tree and plain equality
  and hashes are within noise of each other (the tree is faster in most rows:
  no Rust frame per level); equality and both hashes allocate nothing on the
  managed heap (their work stacks are Rust vectors, a few words per level).
* **Traversal allocates per walk, not per node.** A depth-first walk makes a
  handful of allocations however large the tree (the pending vector and its
  growth: 0.0001 per node at 65,536), a breadth-first walk a few per
  compaction (0.0005 per node on the balanced and wide trees, 0.047 on a
  chain, whose queue is one node long and compacts never: those are the
  vector's own). The coroutine costs about 15-30 ns per node over a
  hand-written loop (manual-dfs), the price of handing each node over
  through a resume.
* **Auxiliary memory is the frontier.** The walks' peak live bytes exceed
  the tree's own (build) by at most the pending vector: none for a chain's
  depth-first walk, the widest level for breadth-first (8 bytes per wide
  child), O(depth x widest child count) for depth-first.
* **Construction** is two allocations per node (the struct and its child
  List), as for an ordinary struct, and no slower: there is no packing,
  arena or copy to amortize. Nothing measured suggests that an arena (section
  4, B) would pay for its representation risk at these sizes.

## 19. Regression/CI

* **`tclsh9.0 tests/local.tcl`** on the milestone's tree (every Tcl test file
  on interp and compile, every golden suite on all four backends, 4 jobs):
  595 of 601 items passed; the 6 failures were three census pins that list
  every qualified native, every `nomethod` native and every stdlib module
  using the typed MutableArray API, each run on both passes
  (linux-syscall.test's `linux-syscall-native-registered` and
  method-eligible.test's `me-nomethod-native-default-off` now list
  `std::tree::children`; mutable-array-type.test's `mat-fence-1` led to
  stdlib/tree.bot keeping its queue head in a one-element MutableVector
  instead). All three pass after the fix. Directly affected suites, also run
  on their own: coroutines.test (81), semantic-instances.test (80),
  structs.test (89), hashable.test (48), value-identity.test (33),
  opaque-struct.test (141), stdlib-namespaces.test (74), std-namespace.test
  (36): all pass.
* **tests/tree-struct.test**: 44 tests, all pass (under `tests/local.tcl`, 16
  of them are deferred to their golden ports).
* **tests/golden/tree-struct.bot**: 19 tests, 19/19 on interp, compile,
  cranelift-generic and cranelift; `audit/golden/tools/perturb.tcl`: 19 of
  19 fail when their verdict is inverted and when their expectation is
  altered; `tests/golden.test` with the suite agrees with the manifest
  (regenerated by `audit/golden/migration/merge.tcl` from the census and
  fragment rows; `-check 1` clean).
* **Rust**: `cargo test --release --lib` -- `tree_walks_are_the_struct_walks`,
  `tree_children_reads_the_recorded_slot`, `deep_trees_need_no_host_stack`
  (a 200,000-deep chain on a 256 KiB thread), `a_tree_shape_names_its_child_field`
  and the descriptor round trip (`program::tests`, format 3 with a tree
  shape).
* **The warning gate** (`audit/refactor/tools/gate.tcl`) passes: stdlib/tree.bot
  is warning-clean through its loader, and listed as a module an entry
  program cannot compile (it names the internal std::tree::children).
  **Compilerpedia** (`tools/compilerpedia.tcl check`): 1,112 topics, 681
  examples, 0 problems.
* **Static decisions.** Typing a construction by its root call's instance is
  a cross-function fact. tests/static-economics.test and
  tests/static-compile.test pass; a reproducer whose blocks' verdicts depend
  on instance-typed constructions (an accepted construction from an untyped
  generator, a rejected walk of an Int, an accepted walk, an unrelated
  rejection) gives the same outcomes under the batched and the sequential
  scheduler (`[2, -2, -1, 3]`). The golden suites' batched-against-sequential
  comparison is CI's (static-decisions.yml): dispatch it on the branch before
  the change merges.
* **CI not run here**: the macOS, Windows, Linux arm64, GC-stress and
  static-decisions workflows; push the branch and dispatch them.

## 20. Explicit limitations

* **One shape.** Exactly one `List[Self]` child edge: no binary
  `left`/`right` fields (a binary node's children are its List's first and
  second elements), no `Optional[Self]`, maps or sets of Self, multiple
  recursive fields, recursive enums or mutual recursion. A general recursive
  type is an ordinary `struct`, whose deep values still compare, hash and
  print by the host's recursion (unchanged by this milestone).
* **No opaque trees** (section 14), no tree identity clause, no affine trees.
* **No persistent update, zipper, cursor, diffing, pruning callbacks,
  postorder or best-first modes, parallel traversal, filesystem scanning.**
  A future `fs::tree(...) -> FileTree` needs no reference-bearing node model:
  `ts-filesystem-specimen` builds and walks the exact shape.
* **Equality of equal shared subtrees is O(size), not O(1).** Nothing
  interns subtrees; two occurrences of one object are compared node by node.
* **A deep tree handed back from the native driver to Tcl** (a program's
  *result* value, `tcl_value` in show.rs) is still converted recursively and
  quoted level by level; a program prints or returns a deep tree's root, and
  the tests compare deep trees inside the program. Not observable from
  Botlish.
* **Open finding, outside this milestone's shape:** `hir::types::IsAffine`
  of an ordinary parameterized struct's application ignores its arguments,
  so `Pair[Coroutine...]` is treated as unrestricted. A tree struct's
  application is checked directly (`ApplicationProblem`); ordinary
  parameterized structs are not, and should be (AFFINE-VALUES.md's
  discipline applies to applications).
* **Coroutine construction typing** takes the root instance's own yields;
  yields in other functions the coroutine reaches keep their generic types.
  `walk` yields only in itself. And it needs an instance: a call whose
  generic result is `never` -- a generator that never returns, `loop: yield
  x` -- gets none (hir::semantic::Call answers it with the generic result
  before requesting one), so such a construction still yields `any` from an
  untyped function. Typing it means creating instances for yielding calls
  whose result is `never`; not needed by `walk`, not done here.

## 21. Recommendation for the next feature

**First, a soundness fix this milestone found: affine applications of
ordinary parameterized structs.** `hir::types::IsAffine` of `Pair[T]`
applied to a coroutine handle reads the declaration only (its fields are
the unrestricted slot T), so a value holding a handle through a slot is
treated as unrestricted: copyable, never released by its owner. Tree structs
now refuse such an application (`ApplicationProblem`); every other
parameterized struct still accepts it. The fix is small and local -- an
application's affinity is its fields' under the application's arguments,
`AppliedFieldTypes` -- and its harnesses exist (the affine fuzzer and
mutants, trait-constrained-types'). It should come before any new feature.

**The next feature: depth-unbounded walks for every value, not only for
trees.** The evidence:

* The iterative walks cost what the recursive ones did (section 18: within
  noise, faster in most rows, nothing allocated) and are byte-for-byte the
  same encoding and the same order (the oracle, the pinned hashes and
  `tree_walks_are_the_struct_walks` show it), so making them the only walks
  changes no observable answer.
* The depth failures they remove are not specific to trees. The same chain
  declared as an ordinary recursive struct still stops at 100,000 deep on a
  2 MiB native stack and at 60,000 deep on the Tcl compiler (section 2), and
  so would a List nested as deep, a Result chain or a struct nested in its
  own fields' Lists through two declarations -- any value whose shape no
  tree struct describes. A native library runs on its caller's stack, where
  2 MiB is ordinary.
* Three more recursive walks over values remain, found while making these
  depth-safe: the native driver's conversion of a result to its Tcl value
  (`tcl_value`), the Tcl printer's `show` of a nested List, and the native
  `equal`/`walk` of non-tree composites. They are the same three walks with
  the same work-stack structure; the tree versions are their template.

Generalizing them -- equality, both hashes, the printer and the result
conversion over any composite value, with a work stack -- would make "a
value's depth is bounded by memory, never by the host" a property of the
language rather than of one declaration form, and leave `tree struct` what
it should be: the designation of the one shape that has a child field, a
generic traversal and depth-unbounded construction idioms.

What the evidence does not support yet: a consumption form for coroutines
(every consumer of `walk` here writes the same `first` / `done?` / `step()`
loop, but COROUTINES.md's "a coroutine is not an iterator" is a deliberate
decision this milestone gives no new reason to revisit), wider tree shapes
(`left`/`right`, `Optional[Self]`: no test, workload or specimen needed one),
and an arena representation (section 18 shows no cost it would recover).

## Files

| file | what |
|---|---|
| surface/parser.tcl, surface/ast.tcl, surface/lower.tcl | the `tree` modifier |
| hir/structs.tcl | ValidateTree, TreeOccurrence, the registry's tree field, RuntimeTree, affine applications, TreeChildrenProblem, GenericLive's thunks |
| hir/types.tcl | Totality's child-field skip, the `tree-children` result shape |
| hir/format.tcl, hir/read.tcl | HIR text |
| hir/coroutines.tcl, hir/semantic.tcl | constructions typed by their root call's instance |
| core/value.tcl, core/hashing.tcl | TreeEqual, TreeShow, TreeEncode, the tree test, containsBlock |
| core/tree.tcl, core/native.tcl, core/core.tcl | std::tree::children |
| stdlib/tree.bot | Order, walk |
| native/lower.tcl | NIR `tree=`, `structget`/`treechildren` |
| native/src/nir.rs, runtime/vm.rs, runtime/program.rs | shape metadata, descriptor format 3 |
| native/src/runtime/ops.rs, runtime/show.rs, codegen/clif.rs | tree_equal, tree_walk, tree_show, rt_tree_children |
| tests/tree-struct.test, tests/golden/tree-struct.bot | the tests and their golden port |
| audit/tree-struct/tools/ | oracle, fuzzer, mutation harness and mutants |
| bench/tree-struct.tcl | the performance report |
| compilerpedia/topics/trees.topic | the reference |
