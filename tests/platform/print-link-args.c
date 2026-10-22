/* print-link-args.c -- tests/platform/aot-facts.tcl's RUSTC on Windows,
 * what its two-line shell script is on Unix: runs the real rustc
 * (REAL_RUSTC) with `--print link-args` before this process's own
 * arguments, rustc's standard output into the file LINK_ARGS_FILE, and exits
 * with rustc's exit code. rustc then prints the system linker's command line
 * (link.exe's, for the MSVC toolchain) and links as it would have.
 *
 * The arguments are passed on exactly as this process's command line holds
 * them -- everything after argument zero, which is skipped by the Microsoft C
 * runtime's rule for it (quotes toggle, no escapes) -- so nothing is split or
 * quoted again. Its standard input and error are this process's. Built by
 * aot-facts.tcl with MSVC's cl (tests/ctoolchain.tcl). */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <wchar.h>

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

int wmain(void) {
    const wchar_t *line = GetCommandLineW();
    int quoted = 0;
    while (*line && (quoted || (*line != L' ' && *line != L'\t'))) {
        if (*line == L'"') {
            quoted = !quoted;
        }
        line++;
    }
    while (*line == L' ' || *line == L'\t') {
        line++;
    }
    const wchar_t *rustc = _wgetenv(L"REAL_RUSTC");
    const wchar_t *printed = _wgetenv(L"LINK_ARGS_FILE");
    if (rustc == NULL || printed == NULL) {
        fwprintf(stderr, L"print-link-args: REAL_RUSTC and LINK_ARGS_FILE must be set\n");
        return 125;
    }
    size_t size = wcslen(rustc) + wcslen(line) + 32;
    wchar_t *command = malloc(size * sizeof *command);
    if (command == NULL) {
        return 125;
    }
    swprintf(command, size, L"\"%ls\" --print link-args %ls", rustc, line);
    SECURITY_ATTRIBUTES inherit = {sizeof inherit, NULL, TRUE};
    HANDLE output = CreateFileW(printed, GENERIC_WRITE, FILE_SHARE_READ, &inherit, CREATE_ALWAYS,
                                FILE_ATTRIBUTE_NORMAL, NULL);
    if (output == INVALID_HANDLE_VALUE) {
        fwprintf(stderr, L"print-link-args: cannot create %ls: error %lu\n", printed, GetLastError());
        return 125;
    }
    STARTUPINFOW startup;
    ZeroMemory(&startup, sizeof startup);
    startup.cb = sizeof startup;
    startup.dwFlags = STARTF_USESTDHANDLES;
    startup.hStdInput = inheritable(GetStdHandle(STD_INPUT_HANDLE));
    startup.hStdOutput = output;
    startup.hStdError = inheritable(GetStdHandle(STD_ERROR_HANDLE));
    PROCESS_INFORMATION process;
    if (!CreateProcessW(NULL, command, NULL, NULL, TRUE, 0, NULL, NULL, &startup, &process)) {
        fwprintf(stderr, L"print-link-args: CreateProcessW %ls: error %lu\n", rustc, GetLastError());
        return 125;
    }
    CloseHandle(process.hThread);
    WaitForSingleObject(process.hProcess, INFINITE);
    DWORD code = 125;
    GetExitCodeProcess(process.hProcess, &code);
    CloseHandle(process.hProcess);
    CloseHandle(output);
    return (int)code;
}
