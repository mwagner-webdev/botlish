# Botlish as freestanding C

`main.tcl -emit-c` writes a Botlish program as freestanding C11
(C-COMPILE-FREESTANDING-MILESTONE-1.md, and `-help backend.c`). This
directory holds what a *target* supplies around such a program -- none of it
is part of the compiler or of the generated C:

| file | what it is |
|---|---|
| `harness/host_main.c` | a hosted test harness: runs the program, prints `value: TEXT` or `error: MESSAGE (CODE)` |
| `harness/linux_start.c` | a freestanding startup with no C library: `_start`, the `write` and `exit` system calls (x86-64, AArch64, RISC-V 64, s390x, ARMv7, i386) and the memory functions the C toolchain requires; with `-DBOTLISH_START_ENTRY=NAME` it calls `int NAME(void)` instead of running one program |
| `harness/two_apps.c` | two generated programs in one executable, hosted (`-DTWO_APPS_HOSTED`) or through `linux_start.c`: runs them interleaved and checks every run of each gives its first run's value (C-CONTEXTS-FREESTANDING-MILESTONE-1.md) |
| `providers/botlish_rt_v1_int_arena.c` | a provider of the Int runtime services (`botlish_rt_v1.h`): arbitrary-precision arithmetic in a static arena, no allocation |
| `programs/traffic.bot` | a program that needs no runtime service |
| `programs/factorial.bot` | a program that needs `int.mul` |
| `contexts/` | an application whose dependencies are contexts: `shop.bot` needs a `payment::Payment` (a context trait); `terminal.bot`, its implementation, needs a `clock::Clock`, which `simclock.bot` and `rtc.bot` implement; `store_bench.bot` and `store_field.bot` install it two ways. No runtime service |
| `demo.sh` | the demonstrations: a no-libc build, a link error naming the missing service, the same program linked with the provider, both shop configurations in one no-libc executable |

    examples/c-freestanding/demo.sh OUT
