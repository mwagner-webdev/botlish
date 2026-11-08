/*
 * single/basekit.c -- the main program of the single-file compiler's base
 * kit (SINGLE-EXECUTABLE.md, "How it is built"). single/build.sh links it
 * with the static Tcl library and script library it builds from the pinned
 * Tcl release, in place of Tcl's own unix/tclAppInit.c; the base kit then
 * runs single/package.tcl, and becomes the executable part of
 * single/out/botlish.
 *
 * It is tclsh with one difference: Tcl starts without the user's
 * TCL_LIBRARY. Tcl's own startup reads it first. Tcl_Init's tclInit sources
 * init.tcl from $TCL_LIBRARY before it looks anywhere else, and
 * TclpInitLibraryPath puts $TCL_LIBRARY/encoding first on the encoding
 * search path while Tcl_FindExecutable loads the locale's encoding. A stock
 * tclsh or zipkit therefore runs whatever init.tcl the variable names --
 * another installation's library, or anything else -- before the archive's
 * main.tcl (single/main.tcl) runs at all.
 *
 * So main removes TCL_LIBRARY from the environment before Tcl starts. Tcl
 * then finds the archive's own library (::tcl::zipfs::tcl_library_init,
 * which also makes that library's encodings the only ones). Once Tcl_Init
 * is done, before the startup script runs, the variable is put back exactly
 * as it was, in the process's environment and in Tcl's env array. The
 * compiler's children (the native backend, the programs it runs and links,
 * the C compiler) see the environment the user set, and nothing else
 * (single/smoke-test.sh checks both). The macOS application's launcher,
 * single/macos/launcher.c, keeps the same rule its own way. single/main.tcl
 * keeps the rest of Tcl's script search -- auto_path and the module path --
 * inside the packaged library.
 *
 * Otherwise this is unix/tclAppInit.c. TclZipfs_AppHook mounts the archive
 * attached to the executable at //zipfs:/app and makes its main.tcl the
 * startup script, and Tcl_Main runs that script, or (in a base kit, whose
 * archive is only Tcl's library) a script named on the command line or read
 * from standard input. It sets no tcl_rcFileName: an interactive base kit
 * sources no ~/.tclshrc.
 */
#include <tcl.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char *library;  /* TCL_LIBRARY as the environment had it, or NULL */

/* TCL_LIBRARY as the environment had it: Tcl's env array (which Tcl copied
 * from the environment when it created the interpreter, without it) and the
 * process's environment, the latter byte for byte. */
static void
RestoreLibrary(Tcl_Interp *interp)
{
    if (library == NULL) {
        return;
    }
    Tcl_DString value;
    Tcl_SetVar2(interp, "env", "TCL_LIBRARY", Tcl_ExternalToUtfDString(NULL, library, -1, &value), TCL_GLOBAL_ONLY);
    Tcl_DStringFree(&value);
    setenv("TCL_LIBRARY", library, 1);
}

static int
AppInit(Tcl_Interp *interp)
{
    int status = Tcl_Init(interp);
    RestoreLibrary(interp);
    return status;
}

int
main(int argc, char **argv)
{
    const char *value = getenv("TCL_LIBRARY");
    if (value != NULL) {
        library = strdup(value);
        if (library == NULL || unsetenv("TCL_LIBRARY") != 0) {
            fputs("botlish: cannot start Tcl without TCL_LIBRARY\n", stderr);
            return 2;
        }
    }
    TclZipfs_AppHook(&argc, &argv);
    Tcl_Main(argc, argv, AppInit);
    return 0;
}
