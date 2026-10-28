# The Win32 probe (EVENT-LOOP-EXPLORATION.md, Experiments B and C)

`evwin32.c` is a self-contained C program: the Win32 adapter a Botlish
Windows driver would bind (the same scalar interface as `../evn.c`: block,
take, post, wake) and a C stand-in for `evloop`'s turn that drives it through
the scenarios in its header comment (cross-thread posts, `PostMessage`,
cross-thread `SendMessage(WM_CLOSE)` contained by policy, a `WSAEventSelect`
socket, and a modal loop with and without the pump on a host fiber).

**Status.** Compiled with MinGW-w64 (x86_64-w64-mingw32-gcc 13) in the
Linux sandbox, with and without `-DEVW_SDL3`, and run under Wine 9.0 with
Xvfb as a development aid. Wine is no authority for Windows (AGENTS.md); the
report marks every Windows result "untested on Windows" until a Windows run
of the commands below is recorded.

## Build and run on Windows (MSVC)

From a Developer PowerShell for VS (x64):

```powershell
cl /O2 /W4 audit\event-loop\native\win32\evwin32.c ws2_32.lib user32.lib /Fe:evwin32.exe
.\evwin32.exe direct
.\evwin32.exe inverted
```

With SDL3 (the DLL and import library `tests/cffi/sdl3.tcl` builds on
Windows; the headers of the pinned SDL3 source):

```powershell
cl /O2 /W4 /DEVW_SDL3 /I <sdl3>\include audit\event-loop\native\win32\evwin32.c ws2_32.lib user32.lib <sdl3>\SDL3.lib /Fe:evwin32-sdl.exe
.\evwin32-sdl.exe inverted
```

Each run prints one `key value` line per measurement and `ok` or `FAIL`.
What a run on Windows must show (the claims; `ok` checks the first four):

* `posts 200`, `messages 200`: every cross-thread post and posted message
  arrives (one `MsgWaitForMultipleObjectsEx` waits for both);
* `wm_close_contained 1 window_still_exists 1`: a cross-thread
  `SendMessage(WM_CLOSE)` was answered by the C policy (0) and became a
  record; the window was not destroyed behind the program's back;
* `wndproc_on_foreign_thread 0`: Windows ran the window procedure on the
  window's own thread (cross-thread sends are marshaled into its pump);
* `direct`: `turns_during_modal` is 0 or 1 -- a modal loop on the loop's own
  stack blocks every turn; `inverted`: `timer_turns_in_modal` > 5 -- with
  the pump on a host fiber, the modal loop's `WM_TIMER` gives the loop
  turns, and posts and messages keep arriving (latency bounded by the 10 ms
  timer);
* with `EVW_SDL3`: `sdl_events 200` with low latency -- SDL3's window
  messages and a producer thread's events share the one wait.

## Sandbox evidence (Wine 9.0 + Xvfb, development aid only)

```
mode direct;   posts 200 max_latency_us 2409660; messages 200 max_latency_us 2411458;
               wm_close_contained 1 window_still_exists 1; socket_records 3;
               turns 91 turns_during_modal 1 timer_turns_in_modal 0 modal_ms 2412;
               wndproc_on_foreign_thread 0; ok
mode inverted; posts 200 max_latency_us 52273; messages 200 max_latency_us 52718;
               wm_close_contained 1 window_still_exists 1; socket_records 3;
               turns 136 turns_during_modal 35 timer_turns_in_modal 33 modal_ms 2412;
               wndproc_on_foreign_thread 0; ok
```

(`modal_ms` is 2.4 s, not the 0.4 s the helper thread intends: under Wine
the helper's `FindWindowW` finds the message box late. Latencies near 50 ms
are Wine's timer granularity under Xvfb, not a property of the design.)

To reproduce in the sandbox:

```sh
x86_64-w64-mingw32-gcc -O2 -Wall -Wno-array-bounds audit/event-loop/native/win32/evwin32.c -o evwin32.exe -lws2_32 -luser32
WINEPREFIX=$(mktemp -d) WINEDEBUG=-all xvfb-run -a wine evwin32.exe inverted
```
