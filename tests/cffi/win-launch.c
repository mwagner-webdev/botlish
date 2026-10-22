/* win-launch.c -- test infrastructure for tests/windows-io.test on Windows
 * (WINDOWS-X86-64-MILESTONE-2.md, "Write failures"): starts a program with a
 * standard output the test chooses, so that the program's own WriteFile
 * fails the way Windows fails it -- a real handle, a real error code -- in a
 * process of its own, never the test runner's.
 *
 *   win-launch MODE FILE PROGRAM [ARG ...]
 *
 * MODE says what the program's standard output is:
 *
 *   inherit      this process's own (a control)
 *   readonly     FILE, opened for reading only: WriteFile fails with
 *                ERROR_ACCESS_DENIED
 *   closed-pipe  the write end of an anonymous pipe whose read end is
 *                closed before the program starts: WriteFile fails (the pipe
 *                is being closed)
 *   null         NULL: the process has no standard output handle
 *   invalid      INVALID_HANDLE_VALUE
 *
 * Its standard input and error are this process's. FILE is ignored ("-")
 * but by readonly. The program's command line is its arguments quoted by the
 * Microsoft C runtime's rules; its environment is this process's. Exits with
 * the program's exit code, or 125 when the launch itself failed (the reason
 * on standard error). Built by the test with MSVC's cl (tests/ctoolchain.tcl).
 */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <wchar.h>

/* ARG appended to LINE (of CAPACITY units) as one argument: quoted, a
 * quotation mark as \", the backslashes before one or before the closing
 * quote doubled. */
static void append(wchar_t *line, size_t capacity, const wchar_t *arg) {
    size_t at = wcslen(line);
    size_t backslashes = 0;
    if (at > 0 && at + 1 < capacity) {
        line[at++] = L' ';
    }
    if (at + 1 < capacity) {
        line[at++] = L'"';
    }
    for (const wchar_t *p = arg; *p && at + 4 < capacity; p++) {
        if (*p == L'\\') {
            backslashes++;
        } else {
            if (*p == L'"') {
                for (size_t i = 0; i <= backslashes && at + 4 < capacity; i++) {
                    line[at++] = L'\\';
                }
            }
            backslashes = 0;
        }
        line[at++] = *p;
    }
    for (size_t i = 0; i < backslashes && at + 2 < capacity; i++) {
        line[at++] = L'\\';
    }
    line[at++] = L'"';
    line[at] = 0;
}

/* An inheritable duplicate of HANDLE (HANDLE itself when it is no handle). */
static HANDLE inheritable(HANDLE handle) {
    HANDLE duplicate = NULL;
    if (handle == NULL || handle == INVALID_HANDLE_VALUE) {
        return handle;
    }
    if (!DuplicateHandle(GetCurrentProcess(), handle, GetCurrentProcess(), &duplicate, 0, TRUE,
                         DUPLICATE_SAME_ACCESS)) {
        return handle;
    }
    return duplicate;
}

int wmain(int argc, wchar_t **argv) {
    if (argc < 4) {
        fwprintf(stderr, L"usage: win-launch MODE FILE PROGRAM [ARG ...]\n");
        return 125;
    }
    const wchar_t *mode = argv[1];
    SECURITY_ATTRIBUTES inherit = {sizeof inherit, NULL, TRUE};
    HANDLE output;
    if (wcscmp(mode, L"inherit") == 0) {
        output = inheritable(GetStdHandle(STD_OUTPUT_HANDLE));
    } else if (wcscmp(mode, L"readonly") == 0) {
        output = CreateFileW(argv[2], GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, &inherit,
                             OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
        if (output == INVALID_HANDLE_VALUE) {
            fwprintf(stderr, L"win-launch: cannot open %ls: error %lu\n", argv[2], GetLastError());
            return 125;
        }
    } else if (wcscmp(mode, L"closed-pipe") == 0) {
        HANDLE read;
        if (!CreatePipe(&read, &output, &inherit, 0)) {
            fwprintf(stderr, L"win-launch: CreatePipe: error %lu\n", GetLastError());
            return 125;
        }
        CloseHandle(read);
    } else if (wcscmp(mode, L"null") == 0) {
        output = NULL;
    } else if (wcscmp(mode, L"invalid") == 0) {
        output = INVALID_HANDLE_VALUE;
    } else {
        fwprintf(stderr, L"win-launch: unknown mode %ls\n", mode);
        return 125;
    }
    static wchar_t line[32768];
    line[0] = 0;
    for (int i = 3; i < argc; i++) {
        append(line, sizeof line / sizeof line[0], argv[i]);
    }
    STARTUPINFOW startup;
    ZeroMemory(&startup, sizeof startup);
    startup.cb = sizeof startup;
    startup.dwFlags = STARTF_USESTDHANDLES;
    startup.hStdInput = inheritable(GetStdHandle(STD_INPUT_HANDLE));
    startup.hStdOutput = output;
    startup.hStdError = inheritable(GetStdHandle(STD_ERROR_HANDLE));
    PROCESS_INFORMATION process;
    if (!CreateProcessW(argv[3], line, NULL, NULL, TRUE, 0, NULL, NULL, &startup, &process)) {
        fwprintf(stderr, L"win-launch: CreateProcessW %ls: error %lu\n", argv[3], GetLastError());
        return 125;
    }
    CloseHandle(process.hThread);
    WaitForSingleObject(process.hProcess, INFINITE);
    DWORD code = 125;
    GetExitCodeProcess(process.hProcess, &code);
    CloseHandle(process.hProcess);
    return (int)code;
}
