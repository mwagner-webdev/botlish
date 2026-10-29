/* botlish_event_loop.h -- the native integration ABI of Botlish's Linux
 * event-loop driver (packages/event_loop_linux; EVENT-LOOP-MILESTONE-1.md,
 * "Native integration ABI"). ABI version 1.
 *
 * A native library delivers events to a Botlish program's event loop
 * (std::event_loop) through an ENDPOINT the program created and handed to
 * it (event_loop_linux::endpoint, then endpoint_id: an int). A record is
 * four scalars: the registration tag (SLOT, GEN) the program gave the
 * library (std::event_loop::native_slot / native_generation) and two
 * 64-bit values of the library's choosing. Records are copied; nothing a
 * record carries refers to the library's memory.
 *
 * Notification, never execution: posting a record never runs Botlish code.
 * The record waits in the endpoint until the loop's own thread collects it
 * in a later turn, where the scheduler checks the registration's generation
 * (a revoked registration's records are dropped as stale) and applies its
 * delivery policy.
 *
 *   botlish_event_post(endpoint, slot, gen, a, b)    ANY thread
 *       0        queued (and the loop woken if it sleeps: never lost)
 *       -EAGAIN  the endpoint is full: its capacity of records is waiting
 *                for the loop. Backpressure: the library decides --
 *                retry later, coalesce, or drop by its own policy. The
 *                loop also stops taking from an endpoint whose records a
 *                Reliable registration has no room for, so a slow consumer
 *                reaches the producer this way.
 *       -EPIPE   the endpoint was closed (the program tore it down, or the
 *                loop was closed): stop posting.
 *       -EINVAL  no such endpoint.
 *
 *   botlish_event_wake()                             ANY thread
 *       Wake the loop without a record, so its pumps run (below). 0, or
 *       -EPIPE when no loop is open.
 *
 * Pumps, for a library with neither a thread that can post nor a
 * descriptor the loop could watch (the prepare/check protocol). Both hooks
 * run on the loop's thread, inside the driver's wait, and must not call
 * back into Botlish (nothing can) or block:
 *
 *   prepare(user, deadline) -> deadline   before the loop sleeps: return
 *       the deadline (CLOCK_MONOTONIC microseconds, botlish_event_now;
 *       -1: none) the library can live with -- never later than DEADLINE.
 *       A library that holds complete events it has not posted yet (its own
 *       buffer: readiness of its descriptor no longer describes them) must
 *       return a deadline that is not in the future, or they wait for an
 *       unrelated wakeup. The same holds for events a library has announced
 *       with botlish_event_wake() before they are where check can take them
 *       (SDL calls an event watch before it queues the event): a check that
 *       runs first finds nothing and consumes the wake, so the library
 *       counts what it announced and keeps the deadline near (at most a
 *       short poll) until check has taken it (tests/event-loop/native/sdl.c,
 *       mode 3).
 *   check(user)    after every wake: move what the library has into its
 *       endpoint (botlish_event_post), until it is empty or the endpoint
 *       refuses.
 *
 *   botlish_event_add_pump(prepare, check, user) -> pump id (>= 0), or
 *       -ENOSPC; LOOP THREAD ONLY. Either hook may be NULL.
 *   botlish_event_remove_pump(pump) -> 0, or -EINVAL; LOOP THREAD ONLY.
 *   botlish_event_now() -> the loop's clock, CLOCK_MONOTONIC microseconds.
 *
 * Callback containment: a library callback that runs on a foreign thread,
 * or synchronously inside a call a Botlish task made, copies what it needs
 * into a record and posts it; one that must answer at once answers from a
 * policy the program set beforehand. No callback runs Botlish code.
 */
#ifndef BOTLISH_EVENT_LOOP_H
#define BOTLISH_EVENT_LOOP_H

#define BOTLISH_EVENT_LOOP_ABI 1

#ifdef __cplusplus
extern "C" {
#endif

int botlish_event_post(int endpoint, int slot, int gen, long long a, long long b);
int botlish_event_wake(void);

typedef long long (*botlish_event_prepare_fn)(void *user, long long deadline);
typedef void (*botlish_event_check_fn)(void *user);

int botlish_event_add_pump(botlish_event_prepare_fn prepare, botlish_event_check_fn check, void *user);
int botlish_event_remove_pump(int pump);
long long botlish_event_now(void);

#ifdef __cplusplus
}
#endif

#endif
