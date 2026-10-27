/*
 * single/macos/launcher.c -- the main executable of the macOS application,
 * Botlish.app/Contents/MacOS/botlish (MACOS-AARCH64-MILESTONE-9.md, "The
 * launcher").
 *
 * The compiler is single/main.tcl and the checkout's main.tcl, in the
 * application's ZIP archive; Tcl is the application's Tcl.framework. This
 * program only starts them, the way a Tcl application starts (Tcl_Main with
 * an application initialization procedure), with the application's own
 * parts:
 *
 *   1. It finds its bundle: this executable's real path
 *      (_NSGetExecutablePath, symbolic links resolved), whose directory is
 *      Contents/MacOS -- never the working directory, argv[0] or PATH.
 *   2. It checks that Tcl was loaded, and from the bundle: the framework is
 *      weakly linked, so a missing, damaged or foreign Tcl.framework is this
 *      program's diagnostic rather than dyld's abort, and the Tcl dyld
 *      loaded (through LC_RPATH @executable_path/../Frameworks) must be
 *      Contents/Frameworks/Tcl.framework, of the Tcl version this was
 *      compiled against.
 *   3. It runs Tcl_MainEx with argv[0] replaced by that real path (so
 *      `info nameofexecutable` is this executable, however it was invoked)
 *      and the startup script //zipfs:/app/main.tcl (single/main.tcl): the
 *      remaining arguments are the compiler's, unchanged, as ::argv.
 *   4. Its Tcl_AppInitProc (every path given to Tcl converted from the
 *      system encoding, as Tcl's strings are) puts back the locale the
 *      environment named (step 5), sets tcl_library to the loaded framework's own
 *      script library (Versions/9.0/Resources/Scripts beside the Tcl binary:
 *      never $TCL_LIBRARY, which Tcl's own search would try first, or another
 *      installation's), runs Tcl_Init, mounts Contents/Resources/botlish.zip
 *      at //zipfs:/app, and tells single/main.tcl where the bundle is:
 *      ::single::bundle, the Contents directory.
 *   5. (macOS) Tcl initializes in a UTF-8 locale: when the environment's
 *      codeset is another -- no locale at all is the C locale's US-ASCII --
 *      LC_ALL is UTF-8 while Tcl starts and is put back, exactly as it was
 *      or unset, before anything runs. Tcl 9.0.1 crashes in that case when
 *      its framework's path is not ASCII: its startup looks for an
 *      encoding file of the codeset ("us-ascii", which it has no name for)
 *      twice, and the second search, after the system encoding became
 *      UTF-8, reads a search path it converted wrongly (Tcl_GetEncoding,
 *      from Tcl_MainEx's TclpSetInitialEncodings: MACOS-AARCH64-MILESTONE-9.md,
 *      "Native launcher implementation"). single/main.tcl makes UTF-8 the
 *      system encoding anyway; a macOS path is UTF-8 whatever the locale.
 *
 * Every failure before the compiler runs is reported on standard error as
 * "botlish: ..." with exit status 2, saying which part of the application is
 * missing or damaged. Nothing is ever printed on standard output: it is the
 * compiler's (and the language server's protocol).
 *
 * Built and shipped for macOS (single/macos/build.sh). It also compiles on
 * Linux, against the system's libtcl (Tcl's own script library search),
 * for testing the startup's logic without a Mac; that build is never
 * packaged.
 */
#include <tcl.h>

#include <dlfcn.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#ifdef __APPLE__
#include <langinfo.h>
#include <locale.h>
#include <mach-o/dyld.h>
#endif

#define MOUNT "//zipfs:/app"
#define ARCHIVE "Resources/botlish.zip"
#define FRAMEWORK "Frameworks/Tcl.framework"

#ifdef __APPLE__
/* Weakly imported (the framework is linked with -weak_framework): its
 * address is NULL when dyld could not load the framework. */
extern const char *Tcl_InitSubsystems(void) __attribute__((weak_import));
#endif

static char *contents;  /* the bundle's Contents directory, real path */
static char *scripts;   /* the loaded Tcl's script library (macOS) */
static int localeReplaced;  /* LC_ALL is UTF-8 while Tcl starts (macOS) */
static char *savedLocale;   /* LC_ALL as the environment had it, or NULL */

static void Fail(const char *format, ...) __attribute__((noreturn, format(printf, 1, 2)));

static void
Fail(const char *format, ...)
{
    va_list args;
    fputs("botlish: ", stderr);
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fputc('\n', stderr);
    exit(2);
}

static char *
Join(const char *dir, const char *name)
{
    size_t length = strlen(dir) + 1 + strlen(name) + 1;
    char *path = malloc(length);
    if (path == NULL) {
        Fail("out of memory");
    }
    snprintf(path, length, "%s/%s", dir, name);
    return path;
}

static char *
Parent(const char *path)
{
    char *copy = strdup(path);
    char *slash = copy ? strrchr(copy, '/') : NULL;
    if (slash == NULL) {
        Fail("cannot find the directory of %s", path);
    }
    *slash = '\0';
    return copy;
}

/* This executable's real path. */
static char *
ExecutablePath(void)
{
    char *path;
#ifdef __APPLE__
    uint32_t size = 0;
    _NSGetExecutablePath(NULL, &size);
    path = malloc(size + 1);
    if (path == NULL || _NSGetExecutablePath(path, &size) != 0) {
        Fail("cannot find this executable's path");
    }
#else
    path = malloc(PATH_MAX);
    ssize_t length = path ? readlink("/proc/self/exe", path, PATH_MAX - 1) : -1;
    if (length < 0) {
        Fail("cannot find this executable's path");
    }
    path[length] = '\0';
#endif
    char *real = realpath(path, NULL);
    if (real == NULL) {
        Fail("cannot resolve this executable's path %s: %s", path, strerror(errno));
    }
    free(path);
    return real;
}

#ifdef __APPLE__
/* The script library of the Tcl that was loaded: Resources/Scripts beside
 * the framework's binary, which must be the application's own. */
static char *
TclScripts(void)
{
    char *expected = Join(contents, FRAMEWORK "/Versions/" TCL_VERSION "/Tcl");
    if (Tcl_InitSubsystems == NULL) {
        /* dyld could not load it: ask it why, at the path it should be. */
        void *handle = dlopen(expected, RTLD_NOW | RTLD_LOCAL);
        const char *why = handle ? "it loads, but not as this executable's Tcl" : dlerror();
        Fail("cannot load Tcl, which this application carries as %s/" FRAMEWORK ": %s; "
             "the application is damaged: reinstall it", contents, why ? why : "unknown reason");
    }
    Dl_info info;
    if (!dladdr((const void *)Tcl_InitSubsystems, &info) || info.dli_fname == NULL) {
        Fail("cannot find the loaded Tcl library");
    }
    char *loaded = realpath(info.dli_fname, NULL);
    char *own = realpath(expected, NULL);
    if (loaded == NULL || own == NULL || strcmp(loaded, own) != 0) {
        Fail("loaded Tcl from %s, not this application's own %s: the application is damaged: reinstall it",
             info.dli_fname, expected);
    }
    char *library = Join(Parent(loaded), "Resources/Scripts");
    free(loaded);
    free(own);
    free(expected);
    return library;
}
#endif

#ifdef __APPLE__
/* Tcl starts in a UTF-8 locale (step 5 above): LC_ALL=UTF-8 unless the
 * environment's locale is UTF-8 already; RestoreLocale puts it back. */
static void
Utf8WhileTclStarts(void)
{
    if (setlocale(LC_CTYPE, "") != NULL && strcmp(nl_langinfo(CODESET), "UTF-8") == 0) {
        return;
    }
    const char *old = getenv("LC_ALL");
    savedLocale = old ? strdup(old) : NULL;
    if ((old && savedLocale == NULL) || setenv("LC_ALL", "UTF-8", 1) != 0) {
        Fail("cannot start Tcl in a UTF-8 locale: %s", strerror(errno));
    }
    localeReplaced = 1;
}
#endif

/* LC_ALL as the environment had it, in the process's environment and in
 * Tcl's env array (which Tcl copied when it created the interpreter). */
static void
RestoreLocale(Tcl_Interp *interp)
{
    if (!localeReplaced) {
        return;
    }
    if (savedLocale == NULL) {
        Tcl_UnsetVar2(interp, "env", "LC_ALL", TCL_GLOBAL_ONLY);
        unsetenv("LC_ALL");
    } else {
        Tcl_DString value;
        Tcl_SetVar2(interp, "env", "LC_ALL", Tcl_ExternalToUtfDString(NULL, savedLocale, -1, &value), TCL_GLOBAL_ONLY);
        Tcl_DStringFree(&value);
        setenv("LC_ALL", savedLocale, 1);
    }
    localeReplaced = 0;
}

/* PATH, a native (system-encoded) string, as Tcl's own string: Tcl
 * converts it back to the same bytes whenever it opens it. */
static const char *
TclPath(const char *path)
{
    Tcl_DString *ds = malloc(sizeof *ds);
    if (ds == NULL) {
        Fail("out of memory");
    }
    return Tcl_ExternalToUtfDString(NULL, path, -1, ds);
}

static int
AppInit(Tcl_Interp *interp)
{
    RestoreLocale(interp);
    if (scripts != NULL) {
        Tcl_SetVar2(interp, "tcl_library", NULL, TclPath(scripts), TCL_GLOBAL_ONLY);
    }
    if (Tcl_Init(interp) != TCL_OK) {
        Fail("cannot initialize Tcl: %s", Tcl_GetStringResult(interp));
    }
    char *archive = Join(contents, ARCHIVE);
    struct stat status;
    if (stat(archive, &status) != 0) {
        Fail("the compiler archive %s is missing (%s): the application is incomplete: reinstall it",
             archive, strerror(errno));
    }
    if (TclZipfs_Mount(interp, TclPath(archive), MOUNT, NULL) != TCL_OK) {
        Fail("cannot mount the compiler archive %s: %s: the application is damaged: reinstall it",
             archive, Tcl_GetStringResult(interp));
    }
    Tcl_Obj *main = Tcl_NewStringObj(MOUNT "/main.tcl", -1);
    Tcl_IncrRefCount(main);
    if (Tcl_FSAccess(main, R_OK) != 0) {
        Fail("the compiler archive %s holds no main.tcl: the application is damaged: reinstall it", archive);
    }
    Tcl_DecrRefCount(main);
    if (Tcl_EvalEx(interp, "namespace eval ::single {}", -1, TCL_EVAL_GLOBAL) != TCL_OK ||
            Tcl_SetVar2(interp, "::single::bundle", NULL, TclPath(contents), TCL_GLOBAL_ONLY | TCL_LEAVE_ERR_MSG) == NULL) {
        Fail("cannot start the compiler: %s", Tcl_GetStringResult(interp));
    }
    return TCL_OK;
}

int
main(int argc, char **argv)
{
    char *executable = ExecutablePath();
    contents = Parent(Parent(executable));
#ifdef __APPLE__
    scripts = TclScripts();  /* fails here, before Tcl runs, when Tcl is not the bundle's */
    Utf8WhileTclStarts();
#endif
    int major, minor;
    Tcl_GetVersion(&major, &minor, NULL, NULL);
    if (major != TCL_MAJOR_VERSION || minor != TCL_MINOR_VERSION) {
        Fail("the application's Tcl is %d.%d, not the Tcl %s it was built for: the application is damaged: reinstall it",
             major, minor, TCL_VERSION);
    }
    /* argv as Tcl_MainEx reads it: this executable's real path, then the
     * arguments (which become ::argv: the startup script is set). */
    char **args = calloc((size_t)argc + 1, sizeof *args);
    if (args == NULL) {
        Fail("out of memory");
    }
    args[0] = executable;
    for (int i = 1; i < argc; i++) {
        args[i] = argv[i];
    }
    Tcl_FindExecutable(executable);
    Tcl_SetStartupScript(Tcl_NewStringObj(MOUNT "/main.tcl", -1), "utf-8");
    Tcl_Main(argc > 0 ? argc : 1, args, AppInit);
    return 0;
}
