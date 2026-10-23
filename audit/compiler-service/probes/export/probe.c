/* probe.c -- a Tcl 9 extension over the native library bj that main.tcl
 * -emit-native-library builds from exports.bot (COMPILER-SERVICE-CENSUS.md,
 * "FFI and JSON feasibility"; NATIVE-LIBRARY-MILESTONE-1.md). It includes
 * only the generated header bj.h and links only the generated library: no
 * compiler internals.
 *
 *   load ./libbjprobe.so Bjprobe
 *   bj::token_count BYTES  -> int   (BYTES: UTF-8, e.g. [encoding convertto utf-8 $text])
 *   bj::tokens BYTES       -> int, or a Tcl error (the declared error, below)
 *   bj::shout BYTES        -> bytes (the library's owned buffer, copied, then released)
 *   bj::checked INT        -> int, or a Tcl error
 *   bj::churn INT          -> int
 *   bj::destroy            destroys this interpreter's instance
 *   bj::create             creates a fresh one (after bj::destroy)
 *
 * A failed call is a Tcl error whose -errorcode is
 *   {BOTLISH STATUS IDENTITY FIELDS}
 * STATUS one of DECLARED RUNTIME BOUNDARY INVOCATION, IDENTITY the error's
 * identity (a declared error's canonical name: Rejected,
 * json_tokens::Malformed), FIELDS a dict of its payload fields (name ->
 * value as text) -- all read from the library's error object as data,
 * never parsed from its message, which is the Tcl error's message.
 *
 * Each interpreter owns one instance, created when the extension is loaded
 * (on the loading thread: the instance is that thread's) and destroyed when
 * the interpreter is deleted. */
#include <tcl.h>
#include <string.h>
#include "bj.h"

typedef struct {
    bj_instance *instance;
} Probe;

static Tcl_Obj *Text(bj_text t) {
    return Tcl_NewStringObj((const char *) t.data, (Tcl_Size) t.len);
}

/* The Tcl error of a call that returned STATUS with ERROR (which it
 * releases). */
static int Fail(Tcl_Interp *interp, int32_t status, bj_error *error) {
    static const char *names[] = {"OK", "DECLARED", "RUNTIME", "BOUNDARY", "INVOCATION"};
    Tcl_Obj *code = Tcl_NewListObj(0, NULL);
    Tcl_ListObjAppendElement(interp, code, Tcl_NewStringObj("BOTLISH", -1));
    Tcl_ListObjAppendElement(interp, code, Tcl_NewStringObj(status >= 0 && status <= 4 ? names[status] : "?", -1));
    bj_text t;
    if (error && bj_error_identity(error, &t) == bj_OK) {
        Tcl_ListObjAppendElement(interp, code, Text(t));
    } else {
        Tcl_ListObjAppendElement(interp, code, Tcl_NewStringObj("", 0));
    }
    Tcl_Obj *fields = Tcl_NewDictObj();
    size_t n = error ? bj_error_field_count(error) : 0;
    for (size_t i = 0; i < n; i++) {
        bj_text name, value;
        if (bj_error_field_name(error, i, &name) == bj_OK && bj_error_field_text(error, i, &value) == bj_OK) {
            Tcl_DictObjPut(interp, fields, Text(name), Text(value));
        }
    }
    Tcl_ListObjAppendElement(interp, code, fields);
    Tcl_SetObjErrorCode(interp, code);
    if (error && bj_error_message(error, &t) == bj_OK) {
        Tcl_SetObjResult(interp, Text(t));
    } else {
        Tcl_SetObjResult(interp, Tcl_ObjPrintf("botlish status %d", (int) status));
    }
    bj_error_release(error);
    return TCL_ERROR;
}

static int Bytes(Tcl_Interp *interp, Tcl_Obj *obj, const unsigned char **ptr, Tcl_Size *len) {
    *ptr = Tcl_GetBytesFromObj(interp, obj, len);
    return *ptr ? TCL_OK : TCL_ERROR;
}

typedef int32_t (*TextToInt)(bj_instance *, const uint8_t *, size_t, int64_t *, bj_error **);
typedef int32_t (*IntToInt)(bj_instance *, int64_t, int64_t *, bj_error **);

static int TextInt(Probe *probe, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[], TextToInt f) {
    const unsigned char *p;
    Tcl_Size n;
    int64_t out;
    bj_error *error = NULL;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "bytes"); return TCL_ERROR; }
    if (Bytes(interp, objv[1], &p, &n) != TCL_OK) return TCL_ERROR;
    int32_t status = f(probe->instance, p, (size_t) n, &out, &error);
    if (status != bj_OK) return Fail(interp, status, error);
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(out));
    return TCL_OK;
}

static int IntInt(Probe *probe, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[], IntToInt f) {
    Tcl_WideInt in;
    int64_t out;
    bj_error *error = NULL;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "int"); return TCL_ERROR; }
    if (Tcl_GetWideIntFromObj(interp, objv[1], &in) != TCL_OK) return TCL_ERROR;
    int32_t status = f(probe->instance, (int64_t) in, &out, &error);
    if (status != bj_OK) return Fail(interp, status, error);
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(out));
    return TCL_OK;
}

static int TokenCount(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    return TextInt(cd, interp, objc, objv, bj_token_count);
}
static int Tokens(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    return TextInt(cd, interp, objc, objv, bj_tokens);
}
static int Checked(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    return IntInt(cd, interp, objc, objv, bj_checked);
}
static int Churn(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    return IntInt(cd, interp, objc, objv, bj_churn);
}

static int Shout(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    Probe *probe = cd;
    const unsigned char *p;
    Tcl_Size n;
    bj_bytes out;
    bj_error *error = NULL;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "bytes"); return TCL_ERROR; }
    if (Bytes(interp, objv[1], &p, &n) != TCL_OK) return TCL_ERROR;
    int32_t status = bj_shout(probe->instance, p, (size_t) n, &out, &error);
    if (status != bj_OK) return Fail(interp, status, error);
    /* The caller owns the buffer: copy it into a Tcl object, then release. */
    Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out.data, (Tcl_Size) out.len));
    bj_bytes_release(&out);
    return TCL_OK;
}

static int Destroy(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    Probe *probe = cd;
    int32_t status = bj_destroy(probe->instance);
    if (status != bj_OK) return Fail(interp, status, NULL);
    return TCL_OK;
}

static int Create(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    Probe *probe = cd;
    bj_error *error = NULL;
    int32_t status = bj_create(&probe->instance, &error);
    if (status != bj_OK) return Fail(interp, status, error);
    return TCL_OK;
}

static void Delete(void *cd, Tcl_Interp *interp) {
    Probe *probe = cd;
    bj_destroy(probe->instance);
    Tcl_Free(probe);
}

DLLEXPORT int Bjprobe_Init(Tcl_Interp *interp) {
    if (Tcl_InitStubs(interp, "9.0", 0) == NULL) return TCL_ERROR;
    if (bj_abi_version() != BJ_ABI_VERSION) {
        Tcl_SetObjResult(interp, Tcl_NewStringObj("bj: the library's C interface is another version than its header's", -1));
        return TCL_ERROR;
    }
    Probe *probe = Tcl_Alloc(sizeof(Probe));
    bj_error *error = NULL;
    int32_t status = bj_create(&probe->instance, &error);
    if (status != bj_OK) {
        Tcl_Free(probe);
        return Fail(interp, status, error);
    }
    Tcl_CallWhenDeleted(interp, Delete, probe);
    Tcl_CreateObjCommand(interp, "bj::token_count", TokenCount, probe, NULL);
    Tcl_CreateObjCommand(interp, "bj::tokens", Tokens, probe, NULL);
    Tcl_CreateObjCommand(interp, "bj::shout", Shout, probe, NULL);
    Tcl_CreateObjCommand(interp, "bj::checked", Checked, probe, NULL);
    Tcl_CreateObjCommand(interp, "bj::churn", Churn, probe, NULL);
    Tcl_CreateObjCommand(interp, "bj::destroy", Destroy, probe, NULL);
    Tcl_CreateObjCommand(interp, "bj::create", Create, probe, NULL);
    return Tcl_PkgProvide(interp, "bjprobe", "0.2");
}
