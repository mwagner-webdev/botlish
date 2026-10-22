/* probe.c -- a Tcl 9 extension over the library-mode stand-in's static
 * library (COMPILER-SERVICE-CENSUS.md, "FFI and JSON feasibility").
 *
 *   load ./libbjprobe.so Bjprobe
 *   bj::token_count BYTES    -> int     (BYTES: UTF-8, e.g. [encoding convertto utf-8 $text])
 *   bj::shout BYTES          -> bytes   (copied at once: the stand-in lends a
 *                                         str result until this thread's next call)
 *   bj::checked INT          -> int, or a Tcl error {BOTLISH IDENTITY} MESSAGE
 *   bj::churn INT            -> int
 *
 * Every call goes to the Vm the stand-in creates on first use, on the
 * calling thread and stack (Tcl's main thread here). */
#include <tcl.h>
#include <string.h>
#include "bj_botlish.h"

static int Fail(Tcl_Interp *interp, int32_t status) {
    if (status == bj_ERROR) {
        BotlishStr identity, message;
        bj_last_error(&identity, &message);
        Tcl_Obj *code = Tcl_NewListObj(0, NULL);
        Tcl_ListObjAppendElement(interp, code, Tcl_NewStringObj("BOTLISH", -1));
        Tcl_ListObjAppendElement(interp, code, Tcl_NewByteArrayObj(identity.ptr, (Tcl_Size) identity.len));
        Tcl_SetObjErrorCode(interp, code);
        Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(message.ptr, (Tcl_Size) message.len));
    } else {
        Tcl_SetObjResult(interp, Tcl_ObjPrintf("botlish status %d", (int) status));
    }
    return TCL_ERROR;
}

static int Bytes(Tcl_Interp *interp, Tcl_Obj *obj, const unsigned char **ptr, Tcl_Size *len) {
    *ptr = Tcl_GetBytesFromObj(interp, obj, len);
    return *ptr ? TCL_OK : TCL_ERROR;
}

static int TokenCount(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    const unsigned char *p; Tcl_Size n; int64_t out;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "bytes"); return TCL_ERROR; }
    if (Bytes(interp, objv[1], &p, &n) != TCL_OK) return TCL_ERROR;
    int32_t status = bj_token_count(p, (size_t) n, &out);
    if (status != bj_OK) return Fail(interp, status);
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(out));
    return TCL_OK;
}

static int Shout(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    const unsigned char *p; Tcl_Size n; BotlishStr out;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "bytes"); return TCL_ERROR; }
    if (Bytes(interp, objv[1], &p, &n) != TCL_OK) return TCL_ERROR;
    int32_t status = bj_shout(p, (size_t) n, &out);
    if (status != bj_OK) return Fail(interp, status);
    /* Copy now: the bytes belong to the Botlish heap until the next call. */
    Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out.ptr, (Tcl_Size) out.len));
    return TCL_OK;
}

static int IntCall(Tcl_Interp *interp, int objc, Tcl_Obj *const objv[], int32_t (*f)(int64_t, int64_t *)) {
    Tcl_WideInt in; int64_t out;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "int"); return TCL_ERROR; }
    if (Tcl_GetWideIntFromObj(interp, objv[1], &in) != TCL_OK) return TCL_ERROR;
    int32_t status = f((int64_t) in, &out);
    if (status != bj_OK) return Fail(interp, status);
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(out));
    return TCL_OK;
}
static int Checked(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) { return IntCall(interp, objc, objv, bj_checked); }
static int Churn(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) { return IntCall(interp, objc, objv, bj_churn); }

DLLEXPORT int Bjprobe_Init(Tcl_Interp *interp) {
    if (Tcl_InitStubs(interp, "9.0", 0) == NULL) return TCL_ERROR;
    Tcl_CreateObjCommand(interp, "bj::token_count", TokenCount, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::shout", Shout, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::checked", Checked, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::churn", Churn, NULL, NULL);
    return Tcl_PkgProvide(interp, "bjprobe", "0.1");
}
