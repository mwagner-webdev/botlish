# audit/actor/experiments -- why std::actor needs std::actor::recover

SAME-THREAD-ACTORS-MILESTONE-1.md, section 4.3. A contextless actor can only
communicate through its own coroutine protocol, so a generic library that
mediates typed messages for it must either carry them typed through a
generic protocol or a generic store, or carry them erased and recover them.
Each program here is one of those routes, and the compiler rejects each, as
it should. Nothing loads them; they are evidence.

| program | route | rejected with |
|---|---|---|
| `erased-result.bot` | an `any` payload returned as M | TYPE |
| `erased-argument.bot` | an `any` payload passed as M | TYPE |
| `erased-struct.bot` | an `any` payload passed as a concrete struct | TYPE |
| `generic-resume.bot` | `resume Delivery[M]` | TYPE (unknown or invalid resume type) |
| `helper-resume.bot` | a generic helper returning its yield's value as M | COROUTINE-RESUME-CONFLICT, TYPE |
| `coroutine-place.bot` | a library coroutine holding a place of the application's context | MUTABLE-PLACE-RECEIVER |

    for f in audit/actor/experiments/*.bot; do tclsh9.0 main.tcl -check -warnings off $f; done
