/* writefile-inject.c -- test infrastructure for tests/windows-io.test on
 * Windows (WINDOWS-X86-64-MILESTONE-2.md, "Short writes and failures"): an
 * injector of kernel32's WriteFile that makes chosen calls short, stalled or
 * failed, as `strace -e inject=write:...` does for tests/portable-io.test on
 * Linux and tests/cffi/write-inject.c's dyld interposer does on macOS.
 *
 * Windows has neither: a synchronous WriteFile to a file, a console or a
 * pipe writes everything or fails. So this static library, linked into one
 * test program (`extern c library "botlish_writefile_inject"`), rewrites the
 * program's own import address table when the program calls bcfw_install():
 * every slot importing WriteFile -- the program's call of kernel32's
 * WriteFile goes through one, by the import library's thunk -- then points to
 * inject_write_file, which follows the plan and otherwise calls the real
 * WriteFile; every slot importing CloseHandle to inject_close_handle, which
 * counts the calls that would close a standard handle. The program calls
 * the real kernel32 symbol: nothing in Botlish knows the injector exists,
 * and this library stands where Windows would have answered.
 *
 *   BCFW_TARGET  output (STD_OUTPUT_HANDLE, the default) or error: the
 *                standard handle whose writes the plan applies to
 *   BCFW_PLAN    one action per WriteFile call on that handle, separated by
 *                commas, the rest passed through unchanged:
 *                  N    (N > 0) write at most N bytes (a short write when the
 *                       call asked for more), returning what the real
 *                       WriteFile returns
 *                  0    write nothing and return TRUE, 0 bytes written (no
 *                       progress)
 *                  -E   write nothing and fail: return FALSE, last-error E
 *   BCFW_LIMIT   N (N > 0): every call on that handle after the plan writes
 *                at most N bytes
 *   BCFW_LOG     a file every call on that handle is recorded in, planned or
 *                passed through, one line "ASKED RESULT ERROR" each (RESULT
 *                the count written, or -1 when the call failed)
 *
 * Built by the test with MSVC's cl into botlish_writefile_inject.lib
 * (tests/ctoolchain.tcl), with the static C runtime every Botlish executable
 * links. */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#pragma comment(lib, "kernel32")

typedef BOOL(WINAPI *bcfw_write_file_fn)(HANDLE, LPCVOID, DWORD, LPDWORD, LPOVERLAPPED);
typedef BOOL(WINAPI *bcfw_close_handle_fn)(HANDLE);

static bcfw_write_file_fn bcfw_real_write_file;
static bcfw_close_handle_fn bcfw_real_close_handle;
static DWORD bcfw_target = STD_OUTPUT_HANDLE;
static const char *bcfw_plan;
static long bcfw_limit;
static FILE *bcfw_log;
static long bcfw_std_close_count;

/* The next action of the plan: 1 and *VALUE when there is one. */
static int bcfw_next(long *value) {
    if (bcfw_plan == NULL || *bcfw_plan == 0) {
        return 0;
    }
    char *end;
    *value = strtol(bcfw_plan, &end, 10);
    bcfw_plan = *end == ',' ? end + 1 : end;
    return 1;
}

static void bcfw_record(DWORD asked, long result, DWORD error) {
    if (bcfw_log != NULL) {
        fprintf(bcfw_log, "%lu %ld %lu\n", (unsigned long)asked, result, (unsigned long)error);
        fflush(bcfw_log);
    }
}

static BOOL WINAPI inject_write_file(HANDLE file, LPCVOID buffer, DWORD count, LPDWORD written,
                                     LPOVERLAPPED overlapped) {
    if (file != GetStdHandle(bcfw_target) || file == NULL || file == INVALID_HANDLE_VALUE) {
        return bcfw_real_write_file(file, buffer, count, written, overlapped);
    }
    long action;
    DWORD asked = count;
    if (bcfw_next(&action)) {
        if (action < 0) {
            if (written != NULL) {
                *written = 0;
            }
            bcfw_record(asked, -1, (DWORD)-action);
            SetLastError((DWORD)-action);
            return FALSE;
        }
        if (action == 0) {
            if (written != NULL) {
                *written = 0;
            }
            bcfw_record(asked, 0, 0);
            return TRUE;
        }
        if ((DWORD)action < count) {
            count = (DWORD)action;
        }
    } else if (bcfw_limit > 0 && (DWORD)bcfw_limit < count) {
        count = (DWORD)bcfw_limit;
    }
    BOOL ok = bcfw_real_write_file(file, buffer, count, written, overlapped);
    DWORD error = ok ? 0 : GetLastError();
    bcfw_record(asked, ok && written != NULL ? (long)*written : -1, error);
    SetLastError(error);
    return ok;
}

static BOOL WINAPI inject_close_handle(HANDLE handle) {
    if (handle != NULL && handle != INVALID_HANDLE_VALUE
            && (handle == GetStdHandle(STD_INPUT_HANDLE) || handle == GetStdHandle(STD_OUTPUT_HANDLE)
                || handle == GetStdHandle(STD_ERROR_HANDLE))) {
        bcfw_std_close_count++;
    }
    return bcfw_real_close_handle(handle);
}

/* Points every import address table slot of MODULE that imports NAME (by
 * name, from any DLL) to HOOK, keeping the first slot's address in
 * *ORIGINAL: how many slots it changed. */
static int bcfw_patch(HMODULE module, const char *name, void *hook, void **original) {
    BYTE *base = (BYTE *)module;
    IMAGE_NT_HEADERS *nt = (IMAGE_NT_HEADERS *)(base + ((IMAGE_DOS_HEADER *)base)->e_lfanew);
    IMAGE_DATA_DIRECTORY imports = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
    if (imports.VirtualAddress == 0) {
        return 0;
    }
    int patched = 0;
    for (IMAGE_IMPORT_DESCRIPTOR *d = (IMAGE_IMPORT_DESCRIPTOR *)(base + imports.VirtualAddress); d->Name; d++) {
        IMAGE_THUNK_DATA *names = (IMAGE_THUNK_DATA *)(base + (d->OriginalFirstThunk ? d->OriginalFirstThunk : d->FirstThunk));
        IMAGE_THUNK_DATA *slots = (IMAGE_THUNK_DATA *)(base + d->FirstThunk);
        for (; names->u1.AddressOfData; names++, slots++) {
            if (IMAGE_SNAP_BY_ORDINAL(names->u1.Ordinal)) {
                continue;
            }
            IMAGE_IMPORT_BY_NAME *by = (IMAGE_IMPORT_BY_NAME *)(base + names->u1.AddressOfData);
            if (strcmp((const char *)by->Name, name) != 0) {
                continue;
            }
            DWORD protection;
            if (!VirtualProtect(&slots->u1.Function, sizeof slots->u1.Function, PAGE_READWRITE, &protection)) {
                continue;
            }
            if (*original == NULL) {
                *original = (void *)slots->u1.Function;
            }
            slots->u1.Function = (ULONG_PTR)hook;
            VirtualProtect(&slots->u1.Function, sizeof slots->u1.Function, protection, &protection);
            patched++;
        }
    }
    return patched;
}

/* Reads the plan and installs the injector in this process's executable:
 * how many slots now import WriteFile through it (0: nothing injected). */
int bcfw_install(void) {
    const char *target = getenv("BCFW_TARGET");
    if (target != NULL && strcmp(target, "error") == 0) {
        bcfw_target = STD_ERROR_HANDLE;
    }
    bcfw_plan = getenv("BCFW_PLAN");
    const char *limit = getenv("BCFW_LIMIT");
    if (limit != NULL) {
        bcfw_limit = atol(limit);
    }
    const char *log = getenv("BCFW_LOG");
    if (log != NULL) {
        bcfw_log = fopen(log, "wb");
    }
    HMODULE self = GetModuleHandleW(NULL);
    bcfw_patch(self, "CloseHandle", (void *)inject_close_handle, (void **)&bcfw_real_close_handle);
    return bcfw_patch(self, "WriteFile", (void *)inject_write_file, (void **)&bcfw_real_write_file);
}

/* How many CloseHandle calls since bcfw_install would have closed one of the
 * process's standard handles. */
long bcfw_std_closes(void) {
    return bcfw_std_close_count;
}
