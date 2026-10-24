/* probe.c -- a Tcl 9 extension over the Botlish native library bj
 * (COMPILER-SERVICE-CENSUS.md, "FFI and JSON feasibility";
 * NATIVE-LIBRARY-MILESTONE-1.md). It includes only the generated bj.h and
 * links only libbj.a: nothing of the compiler or its runtime's internals.
 *
 *   load ./libbjprobe.so Bjprobe
 *   bj::token_count BYTES   -> int, or a Tcl error (below)
 *   bj::token_table BYTES   -> bytes: one "KIND START END" line per token
 *   bj::shout BYTES         -> bytes
 *   bj::checked INT         -> int, or a Tcl error
 *   bj::churn INT           -> int
 *   bj::sample              -> int
 *   bj::reset               destroys the instance and creates a new one
 *
 * BYTES are UTF-8 (e.g. [encoding convertto utf-8 $text]). A failed call is a
 * Tcl error whose -errorcode is {BOTLISH STATUS IDENTITY FIELDS}: STATUS the
 * library's status name (DECLARED, RUNTIME, BOUNDARY, INVOCATION, INTERNAL),
 * IDENTITY the error's identity as the library reports it (data, e.g.
 * json_tokens::Malformed), FIELDS a dict of its payload fields; the
 * message is the library's message.
 *
 * One instance, made when the extension is loaded, on the loading thread
 * (Tcl's main thread here), and destroyed with the interpreter. A String
 * result is a buffer the extension owns: copied into a Tcl object, then
 * released. */
#include <tcl.h>
#include <string.h>
#include "bj.h"

static bj_instance *instance;

static const char *StatusName(int32_t status) {
    switch (status) {
    case bj_STATUS_DECLARED: return "DECLARED";
    case bj_STATUS_RUNTIME: return "RUNTIME";
    case bj_STATUS_BOUNDARY: return "BOUNDARY";
    case bj_STATUS_INVOCATION: return "INVOCATION";
    case bj_STATUS_INTERNAL: return "INTERNAL";
    default: return "UNKNOWN";
    }
}

/* The Tcl error of a failed call, from ERROR (released here). */
static int Fail(Tcl_Interp *interp, int32_t status, bj_error *error) {
    const uint8_t *ptr;
    size_t len;
    Tcl_Obj *code = Tcl_NewListObj(0, NULL);
    Tcl_ListObjAppendElement(interp, code, Tcl_NewStringObj("BOTLISH", -1));
    Tcl_ListObjAppendElement(interp, code, Tcl_NewStringObj(StatusName(status), -1));
    if (error == NULL) {
        Tcl_SetObjErrorCode(interp, code);
        Tcl_SetObjResult(interp, Tcl_ObjPrintf("botlish status %d", (int) status));
        return TCL_ERROR;
    }
    bj_error_identity(error, &ptr, &len);
    Tcl_ListObjAppendElement(interp, code, Tcl_NewStringObj((const char *) ptr, (Tcl_Size) len));
    Tcl_Obj *fields = Tcl_NewDictObj();
    for (size_t i = 0; i < bj_error_field_count(error); i++) {
        Tcl_Obj *value = NULL;
        int64_t n;
        bool b;
        double x;
        const uint8_t *text;
        size_t text_len;
        switch (bj_error_field_type(error, i)) {
        case bj_FIELD_INT:
            if (bj_error_field_int(error, i, &n) == bj_STATUS_OK) value = Tcl_NewWideIntObj(n);
            break;
        case bj_FIELD_BOOL:
            if (bj_error_field_bool(error, i, &b) == bj_STATUS_OK) value = Tcl_NewBooleanObj(b);
            break;
        case bj_FIELD_FLOAT64:
            if (bj_error_field_float64(error, i, &x) == bj_STATUS_OK) value = Tcl_NewDoubleObj(x);
            break;
        case bj_FIELD_STR:
            if (bj_error_field_str(error, i, &text, &text_len) == bj_STATUS_OK)
                value = Tcl_NewStringObj((const char *) text, (Tcl_Size) text_len);
            break;
        }
        if (value == NULL) continue;
        bj_error_field_name(error, i, &ptr, &len);
        Tcl_DictObjPut(interp, fields, Tcl_NewStringObj((const char *) ptr, (Tcl_Size) len), value);
    }
    Tcl_ListObjAppendElement(interp, code, fields);
    Tcl_SetObjErrorCode(interp, code);
    bj_error_message(error, &ptr, &len);
    Tcl_SetObjResult(interp, Tcl_NewStringObj((const char *) ptr, (Tcl_Size) len));
    bj_error_release(&error);
    return TCL_ERROR;
}

static int Bytes(Tcl_Interp *interp, Tcl_Obj *obj, const unsigned char **ptr, Tcl_Size *len) {
    *ptr = Tcl_GetBytesFromObj(interp, obj, len);
    return *ptr ? TCL_OK : TCL_ERROR;
}

typedef int32_t (*BytesToInt)(bj_instance *, const uint8_t *, size_t, int64_t *, bj_error **);
typedef int32_t (*BytesToBytes)(bj_instance *, const uint8_t *, size_t, bj_bytes *, bj_error **);
typedef int32_t (*IntToInt)(bj_instance *, int64_t, int64_t *, bj_error **);

static int CallBytesToInt(Tcl_Interp *interp, int objc, Tcl_Obj *const objv[], BytesToInt f) {
    const unsigned char *p;
    Tcl_Size n;
    int64_t out;
    bj_error *error = NULL;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "bytes"); return TCL_ERROR; }
    if (Bytes(interp, objv[1], &p, &n) != TCL_OK) return TCL_ERROR;
    int32_t status = f(instance, p, (size_t) n, &out, &error);
    if (status != bj_STATUS_OK) return Fail(interp, status, error);
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(out));
    return TCL_OK;
}

static int CallBytesToBytes(Tcl_Interp *interp, int objc, Tcl_Obj *const objv[], BytesToBytes f) {
    const unsigned char *p;
    Tcl_Size n;
    bj_bytes out;
    bj_error *error = NULL;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "bytes"); return TCL_ERROR; }
    if (Bytes(interp, objv[1], &p, &n) != TCL_OK) return TCL_ERROR;
    int32_t status = f(instance, p, (size_t) n, &out, &error);
    if (status != bj_STATUS_OK) return Fail(interp, status, error);
    Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out.ptr, (Tcl_Size) out.len));
    bj_bytes_release(&out);
    return TCL_OK;
}

static int CallIntToInt(Tcl_Interp *interp, int objc, Tcl_Obj *const objv[], IntToInt f) {
    Tcl_WideInt in;
    int64_t out;
    bj_error *error = NULL;
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "int"); return TCL_ERROR; }
    if (Tcl_GetWideIntFromObj(interp, objv[1], &in) != TCL_OK) return TCL_ERROR;
    int32_t status = f(instance, (int64_t) in, &out, &error);
    if (status != bj_STATUS_OK) return Fail(interp, status, error);
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(out));
    return TCL_OK;
}

static int TokenCount(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) { return CallBytesToInt(interp, objc, objv, bj_token_count); }
static int TokenTable(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) { return CallBytesToBytes(interp, objc, objv, bj_token_table); }
static int Shout(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) { return CallBytesToBytes(interp, objc, objv, bj_shout); }
static int Checked(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) { return CallIntToInt(interp, objc, objv, bj_checked); }
static int Churn(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) { return CallIntToInt(interp, objc, objv, bj_churn); }

static int Sample(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    int64_t out;
    bj_error *error = NULL;
    if (objc != 1) { Tcl_WrongNumArgs(interp, 1, objv, ""); return TCL_ERROR; }
    int32_t status = bj_sample(instance, &out, &error);
    if (status != bj_STATUS_OK) return Fail(interp, status, error);
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(out));
    return TCL_OK;
}

static int Create(Tcl_Interp *interp) {
    bj_error *error = NULL;
    int32_t status = bj_create(&instance, &error);
    if (status != bj_STATUS_OK) {
        instance = NULL;
        return Fail(interp, status, error);
    }
    return TCL_OK;
}

static int Reset(void *cd, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
    if (objc != 1) { Tcl_WrongNumArgs(interp, 1, objv, ""); return TCL_ERROR; }
    int32_t status = bj_destroy(instance);
    if (status != bj_STATUS_OK) return Fail(interp, status, NULL);
    return Create(interp);
}

static void Delete(void *cd, Tcl_Interp *interp) {
    if (instance != NULL) {
        bj_destroy(instance);
        instance = NULL;
    }
}

DLLEXPORT int Bjprobe_Init(Tcl_Interp *interp) {
    if (Tcl_InitStubs(interp, "9.0", 0) == NULL) return TCL_ERROR;
    if (bj_abi_version() != bj_ABI_VERSION) {
        Tcl_SetObjResult(interp, Tcl_NewStringObj("bj: the library's ABI is not the header's", -1));
        return TCL_ERROR;
    }
    if (Create(interp) != TCL_OK) return TCL_ERROR;
    Tcl_CallWhenDeleted(interp, Delete, NULL);
    Tcl_CreateObjCommand(interp, "bj::token_count", TokenCount, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::token_table", TokenTable, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::shout", Shout, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::checked", Checked, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::churn", Churn, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::sample", Sample, NULL, NULL);
    Tcl_CreateObjCommand(interp, "bj::reset", Reset, NULL, NULL);
    return Tcl_PkgProvide(interp, "bjprobe", "0.2");
}
