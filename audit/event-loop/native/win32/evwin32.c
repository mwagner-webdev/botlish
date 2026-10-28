/* evwin32.c -- the Win32 probe of EVENT-LOOP-EXPLORATION.md (Experiments B
 * and C). A self-contained C program: the adapter a Botlish Windows driver
 * would call (the same scalar interface as evn.c: block, take, post, wake)
 * and a C stand-in for evloop's turn that drives it through the scenarios
 * below. Build and run on Windows with MSVC (native/win32/README.md);
 * this sandbox can only cross-compile it with MinGW-w64 and run it under
 * Wine, which is no authority for Windows (AGENTS.md): every Windows claim
 * in the report is marked untested unless a Windows run is recorded.
 *
 *   wait      MsgWaitForMultipleObjectsEx over the wakeup event, a socket's
 *             WSAEventSelect event and the thread's message queue
 *             (QS_ALLINPUT): one wait for posts, sockets and window
 *             messages (SDL's windows included: they are this thread's);
 *   contain   the window procedure copies a message into a record and
 *             answers at once from a policy table the program set
 *             beforehand -- WM_CLOSE (0: the window stays, the program is
 *             told), WM_GETMINMAXINFO (a minimum size), WM_QUERYENDSESSION
 *             (allow) -- and never calls back into the program;
 *   cross     a SendMessage from another thread runs the window procedure
 *             on the window's thread, inside that thread's pump (Windows
 *             marshals it): the containment needs no locking of its own;
 *   modal     a modal loop (here MessageBoxW, closed by a helper thread)
 *             holds the thread inside DispatchMessage. With the pump on a
 *             host fiber ("inverted"), a 10 ms WM_TIMER inside the modal
 *             loop switches to the loop fiber for a turn; without it, no
 *             turn runs until the modal loop ends.
 *
 * Output: one "key value" line per measurement, then "ok" or "FAIL ...".
 */
#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _MSC_VER
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "user32.lib")
#endif

/* EVW_SDL3: SDL3 in the same process and on the same thread. SDL's windows
 * are this thread's, so the one MsgWaitForMultipleObjectsEx (QS_ALLINPUT)
 * wakes for them and the one pump dispatches their messages to SDL's
 * window procedure; SDL's filter copies each event into a record (the
 * wakeup protocol, evsdl.c's mode 1), and SDL_PumpEvents runs once per pump
 * for what SDL does besides window messages. A producer thread's
 * SDL_PushEvent wakes the wait through evw_post's event. */
#ifdef EVW_SDL3
#include <SDL3/SDL.h>
#endif

typedef struct { int slot, gen; long long a, b; } evw_record;
typedef struct { evw_record items[4096]; int head, count, max; } evw_ring;

static int ring_push(evw_ring *r, evw_record rec) {
    if (r->count == 4096) return -1;
    r->items[(r->head + r->count) % 4096] = rec;
    r->count++;
    if (r->count > r->max) r->max = r->count;
    return 0;
}
static int ring_pop(evw_ring *r, evw_record *out) {
    if (r->count == 0) return -1;
    *out = r->items[r->head];
    r->head = (r->head + 1) % 4096;
    r->count--;
    return 0;
}

enum { SLOT_POST = 1, SLOT_MSG = 2, SLOT_CLOSE = 3, SLOT_SOCKET = 4, SLOT_MODAL = 5, SLOT_ENDSESSION = 6, SLOT_SDL = 7 };
#define WM_EVW_POST (WM_APP + 1)
#define MODAL_TIMER 77

static struct {
    HANDLE wake;                 /* auto-reset: set by evw_post on the empty -> non-empty edge */
    HWND msgwin, appwin;
    CRITICAL_SECTION lock;
    evw_ring ring, posted;
    DWORD loop_thread;
    LPVOID loop_fiber, host_fiber;
    int inverted, quota, modal_depth, turns_in_modal, wndproc_foreign;
    long long deadline;          /* the loop's deadline while the host fiber pumps */
    SOCKET listener, conn;
    HANDLE sock_event;
    int min_w, min_h;            /* policy: WM_GETMINMAXINFO */
    int allow_end;               /* policy: WM_QUERYENDSESSION */
} W;

static long long evw_now(void) {
    static LARGE_INTEGER freq;
    LARGE_INTEGER t;
    if (!freq.QuadPart) QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&t);
    return (long long)(t.QuadPart * 1000000 / freq.QuadPart);
}

static void push_local(int slot, long long a, long long b) {
    evw_record rec = { slot, 1, a, b };
    ring_push(&W.ring, rec);
}

/* Any thread. */
int evw_post(int slot, int gen, long long a, long long b) {
    evw_record rec = { slot, gen, a, b };
    EnterCriticalSection(&W.lock);
    int was_empty = W.posted.count == 0;
    int rc = ring_push(&W.posted, rec);
    LeaveCriticalSection(&W.lock);
    if (rc == 0 && was_empty) SetEvent(W.wake);
    return rc;
}

static void drain_posted(void) {
    evw_record rec;
    EnterCriticalSection(&W.lock);
    while (W.ring.count < 4096 && ring_pop(&W.posted, &rec) == 0) ring_push(&W.ring, rec);
    LeaveCriticalSection(&W.lock);
}

static void poll_socket(void);

/* The containment: copy, answer from the policy, never call the program. */
static LRESULT CALLBACK wndproc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    if (GetCurrentThreadId() != W.loop_thread) W.wndproc_foreign++;
    switch (msg) {
    case WM_EVW_POST:
        push_local(SLOT_MSG, (long long)wp, (long long)lp);
        return 0;
    case WM_CLOSE:
        push_local(SLOT_CLOSE, 0, evw_now());
        return 0;                          /* policy: the window stays; the program decides */
    case WM_GETMINMAXINFO: {
        MINMAXINFO *mm = (MINMAXINFO *)lp;
        mm->ptMinTrackSize.x = W.min_w;
        mm->ptMinTrackSize.y = W.min_h;
        return 0;
    }
    case WM_QUERYENDSESSION:
        push_local(SLOT_ENDSESSION, 0, evw_now());
        return W.allow_end;
    case WM_ENTERSIZEMOVE:
    case WM_ENTERMENULOOP:
        W.modal_depth++;
        SetTimer(W.msgwin, MODAL_TIMER, 10, NULL);
        return 0;
    case WM_EXITSIZEMOVE:
    case WM_EXITMENULOOP:
        if (--W.modal_depth == 0) KillTimer(W.msgwin, MODAL_TIMER);
        return 0;
    case WM_TIMER:
        if (wp == MODAL_TIMER && W.inverted && GetCurrentFiber() == W.host_fiber) {
            /* Inside a modal loop on the host fiber: the modal loop waits
             * for messages only (our wakeup event cannot end its wait), so
             * collect what the wait would have -- posts, the socket -- and
             * give the loop a turn. Posts wait at most this timer's 10 ms. */
            drain_posted();
            poll_socket();
            W.turns_in_modal++;
            SwitchToFiber(W.loop_fiber);
        }
        return 0;
    }
    return DefWindowProcW(hwnd, msg, wp, lp);
}

static void poll_socket(void) {
    WSANETWORKEVENTS ne;
    if (W.sock_event == NULL || WSAEnumNetworkEvents(W.listener, W.sock_event, &ne) != 0) return;
    if (ne.lNetworkEvents & FD_ACCEPT) {
        W.conn = accept(W.listener, NULL, NULL);
        push_local(SLOT_SOCKET, 1, evw_now());
        if (W.conn != INVALID_SOCKET) WSAEventSelect(W.conn, W.sock_event, FD_READ | FD_CLOSE);
    }
    if (W.conn != INVALID_SOCKET && WSAEnumNetworkEvents(W.conn, W.sock_event, &ne) == 0) {
        if (ne.lNetworkEvents & FD_READ) {
            char buf[256];
            int n = recv(W.conn, buf, sizeof buf, 0);
            if (n > 0) push_local(SLOT_SOCKET, 2, n);
        }
        if (ne.lNetworkEvents & FD_CLOSE) push_local(SLOT_SOCKET, 3, 0);
    }
}

/* One wait and one bounded pump: what evn_block is on Linux. */
static int wait_and_pump(long long deadline) {
    drain_posted();
    DWORD timeout = INFINITE;
    if (W.ring.count > 0) timeout = 0;
    else if (deadline >= 0) {
        long long left = deadline - evw_now();
        timeout = left <= 0 ? 0 : (DWORD)((left + 999) / 1000);
    }
    HANDLE handles[2] = { W.wake, W.sock_event };
    DWORD n = W.sock_event ? 2 : 1;
    /* Alertable: a modal request queued as an APC (main) runs here, on the
     * fiber that pumps. */
    MsgWaitForMultipleObjectsEx(n, handles, timeout, QS_ALLINPUT, MWMO_INPUTAVAILABLE | MWMO_ALERTABLE);
    MSG m;
    for (int i = 0; i < W.quota && PeekMessageW(&m, NULL, 0, 0, PM_REMOVE); i++) {
        TranslateMessage(&m);
        DispatchMessageW(&m);           /* may enter a modal loop (WM_SYSCOMMAND) */
    }
    poll_socket();
#ifdef EVW_SDL3
    SDL_PumpEvents();
#endif
    drain_posted();
    return W.ring.count;
}

static void CALLBACK host_main(LPVOID unused) {
    (void)unused;
    for (;;) {
        wait_and_pump(W.deadline);
        SwitchToFiber(W.loop_fiber);
    }
}

/* The loop's wait. Inverted: the pump runs on the host fiber, so a modal
 * loop entered inside it still lets the loop have turns. */
int evw_block(long long deadline) {
    if (!W.inverted) return wait_and_pump(deadline);
    W.deadline = deadline;
    SwitchToFiber(W.host_fiber);
    return W.ring.count;
}

int evw_take(evw_record *out) { return ring_pop(&W.ring, out); }

int evw_open(int inverted) {
    InitializeCriticalSection(&W.lock);
    W.wake = CreateEventW(NULL, FALSE, FALSE, NULL);
    W.loop_thread = GetCurrentThreadId();
    W.quota = 64;
    W.min_w = 320;
    W.min_h = 240;
    W.allow_end = TRUE;
    W.listener = INVALID_SOCKET;
    W.conn = INVALID_SOCKET;
    WNDCLASSW wc = { 0 };
    wc.lpfnWndProc = wndproc;
    wc.hInstance = GetModuleHandleW(NULL);
    wc.lpszClassName = L"evwin32";
    RegisterClassW(&wc);
    W.msgwin = CreateWindowExW(0, L"evwin32", L"evw-msg", 0, 0, 0, 0, 0, HWND_MESSAGE, NULL, wc.hInstance, NULL);
    W.appwin = CreateWindowExW(0, L"evwin32", L"evw-app", WS_OVERLAPPEDWINDOW, 0, 0, 400, 300, NULL, NULL, wc.hInstance, NULL);
    W.inverted = inverted;
    if (inverted) {
        W.loop_fiber = ConvertThreadToFiber(NULL);
        W.host_fiber = CreateFiber(1 << 20, host_main, NULL);
    }
    return W.msgwin && W.appwin && W.wake ? 0 : -1;
}

/* ---------------------------------------------------------------------
 * Scenario threads */

static DWORD WINAPI poster(LPVOID p) {
    (void)p;
    for (int i = 0; i < 200; i++) {
        Sleep(1 + (i % 3));
        evw_post(SLOT_POST, 1, i, evw_now());
    }
    return 0;
}

static DWORD WINAPI messenger(LPVOID p) {
    (void)p;
    for (int i = 0; i < 200; i++) {
        Sleep(1 + (i % 2));
        PostMessageW(W.msgwin, WM_EVW_POST, (WPARAM)i, (LPARAM)evw_now());
    }
    return 0;
}

static DWORD WINAPI closer(LPVOID p) {
    (void)p;
    Sleep(50);
    /* Synchronous, cross-thread: runs wndproc on the window's thread, inside
     * its pump, and returns WM_CLOSE's answer (the policy's 0). */
    SendMessageW(W.appwin, WM_CLOSE, 0, 0);
    return 0;
}

static DWORD WINAPI dialog_closer(LPVOID p) {
    (void)p;
    Sleep(400);
    HWND box = FindWindowW(NULL, L"evw-modal");
    if (box) PostMessageW(box, WM_CLOSE, 0, 0);
    return 0;
}

static DWORD WINAPI client(LPVOID p) {
    int port = (int)(intptr_t)p;
    Sleep(30);
    SOCKET s = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in a = { 0 };
    a.sin_family = AF_INET;
    a.sin_port = htons((u_short)port);
    a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (connect(s, (struct sockaddr *)&a, sizeof a) == 0) {
        send(s, "2 1\n", 4, 0);
        Sleep(20);
        closesocket(s);
    }
    return 0;
}

static int listen_socket(void) {
    WSADATA wsa;
    WSAStartup(MAKEWORD(2, 2), &wsa);
    W.listener = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in a = { 0 };
    a.sin_family = AF_INET;
    a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    bind(W.listener, (struct sockaddr *)&a, sizeof a);
    listen(W.listener, 4);
    int len = sizeof a;
    getsockname(W.listener, (struct sockaddr *)&a, &len);
    W.sock_event = WSACreateEvent();
    WSAEventSelect(W.listener, W.sock_event, FD_ACCEPT);
    return ntohs(a.sin_port);
}

/* A modal operation requested by the loop: run on the host fiber (inverted)
 * or on the loop's own stack (not inverted, where it blocks every turn). */
static int modal_requested;
static void run_modal(void) {
    CreateThread(NULL, 0, dialog_closer, NULL, 0, NULL);
    SetTimer(W.msgwin, MODAL_TIMER, 10, NULL);
    W.modal_depth++;
    MessageBoxW(NULL, L"modal loop probe", L"evw-modal", MB_OK);
    W.modal_depth--;
    KillTimer(W.msgwin, MODAL_TIMER);
    push_local(SLOT_MODAL, 1, evw_now());
}

#ifdef EVW_SDL3
static bool SDLCALL sdl_filter(void *userdata, SDL_Event *e) {
    (void)userdata;
    if (e->type == SDL_EVENT_USER) {
        evw_post(SLOT_SDL, 1, e->user.code, (long long)(intptr_t)e->user.data1);
        return false;
    }
    return true;
}

static int SDLCALL sdl_producer(void *p) {
    (void)p;
    for (int i = 0; i < 200; i++) {
        SDL_Delay(1 + (i % 3));
        SDL_Event e = { 0 };
        e.type = SDL_EVENT_USER;
        e.user.code = i;
        e.user.data1 = (void *)(intptr_t)evw_now();
        SDL_PushEvent(&e);
    }
    return 0;
}
#endif

int main(int argc, char **argv) {
    int inverted = argc > 1 && strcmp(argv[1], "inverted") == 0;
    if (evw_open(inverted) != 0) { puts("FAIL open"); return 1; }
#ifdef EVW_SDL3
    if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS)) { puts("FAIL SDL_Init"); return 1; }
    SDL_Window *sdlwin = SDL_CreateWindow("evw-sdl", 320, 240, SDL_WINDOW_HIDDEN);
    SDL_SetEventFilter(sdl_filter, NULL);
    SDL_CreateThread(sdl_producer, "evw-sdl-producer", NULL);
    int sdl_events = 0;
    long long max_sdl = 0;
#endif
    int port = listen_socket();
    CreateThread(NULL, 0, poster, NULL, 0, NULL);
    CreateThread(NULL, 0, messenger, NULL, 0, NULL);
    CreateThread(NULL, 0, closer, NULL, 0, NULL);
    CreateThread(NULL, 0, client, (LPVOID)(intptr_t)port, 0, NULL);
    long long start = evw_now(), modal_start = 0, modal_end = 0, max_post = 0, max_msg = 0;
    int posts = 0, msgs = 0, closes = 0, sockets = 0, turns = 0, turns_during_modal = 0;
    while (evw_now() - start < 3000000 && !(posts == 200 && msgs == 200 && modal_end)) {
        evw_block(evw_now() + 20000);
        turns++;
        if (modal_start && !modal_end) turns_during_modal++;
        evw_record r;
        while (evw_take(&r) == 0) {
            long long lag = evw_now() - r.b;
            switch (r.slot) {
            case SLOT_POST: posts++; if (lag > max_post) max_post = lag; break;
            case SLOT_MSG: msgs++; if (lag > max_msg) max_msg = lag; break;
            case SLOT_CLOSE: closes++; break;
            case SLOT_SOCKET: sockets++; break;
            case SLOT_MODAL: modal_end = evw_now(); break;
#ifdef EVW_SDL3
            case SLOT_SDL: sdl_events++; if (lag > max_sdl) max_sdl = lag; break;
#endif
            }
        }
        if (!modal_requested && evw_now() - start > 100000) {
            modal_requested = 1;
            modal_start = evw_now();
            if (inverted) {
                /* The request runs on the host fiber at its next pump: the
                 * host fiber's next iteration calls run_modal. Simplest
                 * form for the probe: post a message the host dispatches. */
                QueueUserAPC((PAPCFUNC)(void *)run_modal, GetCurrentThread(), 0);
            } else {
                run_modal();
            }
        }
    }
    printf("mode %s\n", inverted ? "inverted" : "direct");
    printf("posts %d max_latency_us %lld\n", posts, max_post);
    printf("messages %d max_latency_us %lld\n", msgs, max_msg);
    printf("wm_close_contained %d window_still_exists %d\n", closes, IsWindow(W.appwin) ? 1 : 0);
    printf("socket_records %d\n", sockets);
    printf("turns %d turns_during_modal %d timer_turns_in_modal %d modal_ms %lld\n", turns, turns_during_modal, W.turns_in_modal, (modal_end - modal_start) / 1000);
    printf("wndproc_on_foreign_thread %d\n", W.wndproc_foreign);
#ifdef EVW_SDL3
    printf("sdl_events %d max_latency_us %lld window %d\n", sdl_events, max_sdl, sdlwin != NULL);
#endif
    int ok = posts == 200 && msgs == 200 && closes == 1 && IsWindow(W.appwin) && W.wndproc_foreign == 0;
    if (inverted) ok = ok && W.turns_in_modal > 5;
    else ok = ok && turns_during_modal <= 1;
    puts(ok ? "ok" : "FAIL");
    return ok ? 0 : 1;
}
