/*
 * botlish_rt_v1.h -- the Botlish C runtime-service interface, version 1.
 *
 * C-COMPILE-FREESTANDING-MILESTONE-1.md. A program the C backend generates
 * (main.tcl -emit-c) implements in portable C what portable C can implement
 * correctly, and calls the services declared here for the rest. The program
 * itself never defines these symbols: a *provider* does -- a target
 * runtime, a package, or the application's own C -- and a program whose
 * provider is missing compiles but does not link (the linker names the
 * missing symbol; PROGRAM.runtime.json names its service).
 *
 * This header is the contract: the types, the symbols and what each
 * service must do. It is freestanding C11 (stdint.h, stdbool.h, stddef.h
 * only) and has no hosted-library dependency. The generated program's
 * header includes it; a provider includes it to implement it.
 *
 * Versioning. Every symbol carries the interface version (botlish_rt_v1_).
 * A later, incompatible interface is botlish_rt_v2_ with its own header, so
 * a program and a provider of different versions fail to link rather than
 * disagree. BOTLISH_RT_V1 is the version this header describes; the
 * manifest's "runtime_abi" names it too.
 *
 * Services are independent: a program requires exactly the services its
 * generated code calls, and a provider may implement any subset (a program
 * that needs a missing one does not link). There is no initialization
 * service and no global runtime object.
 *
 * Status. Every fallible service returns botlish_rt_v1_status: 0 on
 * success (the result written), BOTLISH_RT_V1_LIMIT when the provider's
 * resources (its storage) cannot hold the result. A service never returns
 * a wrong result: it computes the exact one or reports LIMIT. Any other
 * value is a provider fault. The generated program turns a nonzero status
 * into its own terminal status (C RUNTIME LIMIT / C RUNTIME FAULT), which
 * no Botlish handler catches: running out of storage is outside the
 * language's semantics, exactly as on every other backend.
 */
#ifndef BOTLISH_RT_V1_H
#define BOTLISH_RT_V1_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define BOTLISH_RT_V1 1

typedef int botlish_rt_v1_status;
#define BOTLISH_RT_V1_OK 0
#define BOTLISH_RT_V1_LIMIT 1

/*
 * Int: Botlish's arbitrary-precision integer.
 *
 * The generated program carries every Int whose range the compiler has not
 * proven to fit int64_t as a botlish_rt_v1_int: the value itself in
 * `small` while it fits int64_t (big == NULL), else a provider-owned
 * number `big` (small then unspecified). The generated code adds,
 * subtracts, multiplies, compares and reduces small values inline, with
 * portable overflow checks, and calls a service only when an operand is big
 * or the exact result does not fit int64_t. So a provider is needed to
 * *link* such a program, and is called only when its values grow.
 *
 * Normalization (an obligation of every service that returns an Int): a
 * result that fits int64_t is returned small (big == NULL). The generated
 * code relies on it: it reads `small` of an Int the compiler proved fits
 * int64_t without calling anything.
 *
 * Ownership and lifetime. A big number is immutable and owned by the
 * provider. The generated code never frees, copies the contents of, or
 * inspects one; it copies the botlish_rt_v1_int (the pointer) freely and
 * passes it back to services. A provider must keep every big number it
 * returned valid for as long as the program may use it: until the program's
 * entry function returns, at least (an arena the embedding resets between
 * runs is a valid strategy; so is never freeing). A service never retains
 * or modifies its operands.
 *
 * Operands may be small or big in any combination.
 */
typedef struct botlish_rt_v1_bignum botlish_rt_v1_bignum; /* provider-defined */

typedef struct botlish_rt_v1_int {
    int64_t small;
    const botlish_rt_v1_bignum *big;
} botlish_rt_v1_int;

/* service int.add: *result = a + b. */
botlish_rt_v1_status botlish_rt_v1_int_add(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result);

/* service int.sub: *result = a - b. */
botlish_rt_v1_status botlish_rt_v1_int_sub(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result);

/* service int.mul: *result = a * b. */
botlish_rt_v1_status botlish_rt_v1_int_mul(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result);

/* service int.mod: *result = the Euclidean remainder of a by b,
 * 0 <= *result < |b|. The caller guarantees b != 0 (the generated code
 * raises Botlish's own division-by-zero error before calling). */
botlish_rt_v1_status botlish_rt_v1_int_mod(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result);

/* service int.compare: -1, 0 or 1 as a < b, a == b, a > b. Total: it never
 * fails and needs no storage. */
int botlish_rt_v1_int_compare(botlish_rt_v1_int a, botlish_rt_v1_int b);

/* service int.from_decimal: *result = the integer the LENGTH bytes at
 * DIGITS spell: an optional '-' and one or more ASCII decimal digits, the
 * canonical text of an Int (the compiler only passes literals of its own
 * program). Used for integer literals outside int64_t. */
botlish_rt_v1_status botlish_rt_v1_int_from_decimal(const char *digits, size_t length,
    botlish_rt_v1_int *result);

/* service int.to_decimal: writes the canonical decimal text of a big VALUE
 * (an optional '-', digits, no leading zero) into BUFFER, at most CAPACITY
 * bytes, no terminator, and returns its full length (which may exceed
 * CAPACITY: the caller then has a truncated text and knows its size). Total.
 * Used only by the optional display support (PROGRAM_display.c), never by
 * the program itself; it is called with big values only. */
size_t botlish_rt_v1_int_to_decimal(botlish_rt_v1_int value, char *buffer, size_t capacity);

#endif /* BOTLISH_RT_V1_H */
