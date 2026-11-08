/* toolkit.h -- what the sample external tools share
 * (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md; the protocol
 * is BOTLISH-TOOLS.md): a strict JSON reader, the protocol 1 request, the
 * native library manifest (schema 2) as data, diagnostics, and output files.
 *
 * Everything a tool knows of Botlish comes from the request and the
 * manifest: no HIR, no compiler internals, no source. A manifest a tool
 * cannot read completely -- an unknown C type, a str result whose ownership
 * it does not state -- is refused, never guessed at.
 *
 * Header-only, C99, no dependencies but the C library. */
#ifndef BOTLISH_TOOLKIT_H
#define BOTLISH_TOOLKIT_H

#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

/* ------------------------------------------------------------------ JSON */

typedef enum { J_NULL, J_BOOL, J_NUM, J_STR, J_ARR, J_OBJ } jkind;

typedef struct jval {
    jkind kind;
    int boolean;
    double number;
    char *text; /* J_STR (NUL-terminated, UTF-8), J_NUM (its text) */
    size_t len;
    struct jval **items; /* J_ARR, J_OBJ values */
    char **keys;         /* J_OBJ */
    size_t count;
} jval;

typedef struct {
    const char *s;
    size_t n, i;
    char error[256];
} jparser;

static inline void *tk_alloc(size_t n) {
    void *p = calloc(1, n ? n : 1);
    if (!p) {
        fputs("out of memory\n", stderr);
        exit(70);
    }
    return p;
}

static inline char *tk_strdup(const char *s) {
    size_t n = strlen(s);
    char *p = tk_alloc(n + 1);
    memcpy(p, s, n);
    return p;
}

static inline void j_space(jparser *p) {
    while (p->i < p->n && (p->s[p->i] == ' ' || p->s[p->i] == '\t' || p->s[p->i] == '\n' || p->s[p->i] == '\r')) p->i++;
}

static inline jval *j_fail(jparser *p, const char *what) {
    if (!p->error[0]) snprintf(p->error, sizeof p->error, "%s at offset %zu", what, p->i);
    return NULL;
}

static inline jval *j_value(jparser *p, int depth);

static inline void j_push(jval *v, char *key, jval *item) {
    v->items = realloc(v->items, (v->count + 1) * sizeof *v->items);
    if (key) v->keys = realloc(v->keys, (v->count + 1) * sizeof *v->keys);
    if (!v->items || (key && !v->keys)) {
        fputs("out of memory\n", stderr);
        exit(70);
    }
    v->items[v->count] = item;
    if (key) v->keys[v->count] = key;
    v->count++;
}

static inline void j_utf8(char **out, size_t *len, size_t *cap, unsigned cp) {
    if (*len + 5 > *cap) {
        *cap = (*cap + 5) * 2;
        *out = realloc(*out, *cap);
        if (!*out) exit(70);
    }
    char *o = *out + *len;
    if (cp < 0x80) { o[0] = (char)cp; *len += 1; }
    else if (cp < 0x800) { o[0] = (char)(0xc0 | (cp >> 6)); o[1] = (char)(0x80 | (cp & 0x3f)); *len += 2; }
    else if (cp < 0x10000) { o[0] = (char)(0xe0 | (cp >> 12)); o[1] = (char)(0x80 | ((cp >> 6) & 0x3f)); o[2] = (char)(0x80 | (cp & 0x3f)); *len += 3; }
    else { o[0] = (char)(0xf0 | (cp >> 18)); o[1] = (char)(0x80 | ((cp >> 12) & 0x3f)); o[2] = (char)(0x80 | ((cp >> 6) & 0x3f)); o[3] = (char)(0x80 | (cp & 0x3f)); *len += 4; }
}

static inline int j_hex4(jparser *p, unsigned *out) {
    if (p->i + 4 > p->n) return 0;
    unsigned v = 0;
    for (int k = 0; k < 4; k++) {
        char c = p->s[p->i + k];
        v <<= 4;
        if (c >= '0' && c <= '9') v |= (unsigned)(c - '0');
        else if (c >= 'a' && c <= 'f') v |= (unsigned)(c - 'a' + 10);
        else if (c >= 'A' && c <= 'F') v |= (unsigned)(c - 'A' + 10);
        else return 0;
    }
    p->i += 4;
    *out = v;
    return 1;
}

static inline char *j_string(jparser *p, size_t *outLen) {
    if (p->i >= p->n || p->s[p->i] != '"') { j_fail(p, "a string expected"); return NULL; }
    p->i++;
    size_t cap = 16, len = 0;
    char *out = tk_alloc(cap);
    while (1) {
        if (p->i >= p->n) { j_fail(p, "an unterminated string"); free(out); return NULL; }
        unsigned char c = (unsigned char)p->s[p->i++];
        if (c == '"') break;
        if (c < 0x20) { j_fail(p, "a control character in a string"); free(out); return NULL; }
        if (c != '\\') {
            if (len + 2 > cap) { cap *= 2; out = realloc(out, cap); if (!out) exit(70); }
            out[len++] = (char)c;
            continue;
        }
        if (p->i >= p->n) { j_fail(p, "an unterminated escape"); free(out); return NULL; }
        char e = p->s[p->i++];
        unsigned cp;
        switch (e) {
        case '"': cp = '"'; break;
        case '\\': cp = '\\'; break;
        case '/': cp = '/'; break;
        case 'b': cp = '\b'; break;
        case 'f': cp = '\f'; break;
        case 'n': cp = '\n'; break;
        case 'r': cp = '\r'; break;
        case 't': cp = '\t'; break;
        case 'u':
            if (!j_hex4(p, &cp)) { j_fail(p, "a bad \\u escape"); free(out); return NULL; }
            if (cp >= 0xd800 && cp < 0xdc00) {
                unsigned low;
                if (p->i + 2 > p->n || p->s[p->i] != '\\' || p->s[p->i + 1] != 'u') { j_fail(p, "a lone surrogate"); free(out); return NULL; }
                p->i += 2;
                if (!j_hex4(p, &low) || low < 0xdc00 || low >= 0xe000) { j_fail(p, "a lone surrogate"); free(out); return NULL; }
                cp = 0x10000 + ((cp - 0xd800) << 10) + (low - 0xdc00);
            } else if (cp >= 0xdc00 && cp < 0xe000) {
                j_fail(p, "a lone surrogate");
                free(out);
                return NULL;
            }
            break;
        default: j_fail(p, "an unknown escape"); free(out); return NULL;
        }
        j_utf8(&out, &len, &cap, cp);
    }
    out[len] = 0;
    *outLen = len;
    return out;
}

static inline jval *j_value(jparser *p, int depth) {
    if (depth > 64) return j_fail(p, "nesting too deep");
    j_space(p);
    if (p->i >= p->n) return j_fail(p, "a value expected");
    char c = p->s[p->i];
    jval *v = tk_alloc(sizeof *v);
    if (c == '{') {
        v->kind = J_OBJ;
        p->i++;
        j_space(p);
        if (p->i < p->n && p->s[p->i] == '}') { p->i++; return v; }
        while (1) {
            j_space(p);
            size_t klen;
            char *key = j_string(p, &klen);
            if (!key) return NULL;
            for (size_t k = 0; k < v->count; k++)
                if (!strcmp(v->keys[k], key)) return j_fail(p, "a repeated key");
            j_space(p);
            if (p->i >= p->n || p->s[p->i] != ':') return j_fail(p, "\":\" expected");
            p->i++;
            jval *item = j_value(p, depth + 1);
            if (!item) return NULL;
            j_push(v, key, item);
            j_space(p);
            if (p->i < p->n && p->s[p->i] == ',') { p->i++; continue; }
            if (p->i < p->n && p->s[p->i] == '}') { p->i++; return v; }
            return j_fail(p, "\",\" or \"}\" expected");
        }
    }
    if (c == '[') {
        v->kind = J_ARR;
        p->i++;
        j_space(p);
        if (p->i < p->n && p->s[p->i] == ']') { p->i++; return v; }
        while (1) {
            jval *item = j_value(p, depth + 1);
            if (!item) return NULL;
            j_push(v, NULL, item);
            j_space(p);
            if (p->i < p->n && p->s[p->i] == ',') { p->i++; continue; }
            if (p->i < p->n && p->s[p->i] == ']') { p->i++; return v; }
            return j_fail(p, "\",\" or \"]\" expected");
        }
    }
    if (c == '"') {
        v->kind = J_STR;
        v->text = j_string(p, &v->len);
        return v->text ? v : NULL;
    }
    if (p->n - p->i >= 4 && !memcmp(p->s + p->i, "true", 4)) { v->kind = J_BOOL; v->boolean = 1; p->i += 4; return v; }
    if (p->n - p->i >= 5 && !memcmp(p->s + p->i, "false", 5)) { v->kind = J_BOOL; p->i += 5; return v; }
    if (p->n - p->i >= 4 && !memcmp(p->s + p->i, "null", 4)) { v->kind = J_NULL; p->i += 4; return v; }
    if (c == '-' || (c >= '0' && c <= '9')) {
        size_t start = p->i;
        if (p->s[p->i] == '-') p->i++;
        while (p->i < p->n && strchr("0123456789.eE+-", p->s[p->i])) p->i++;
        v->kind = J_NUM;
        v->len = p->i - start;
        v->text = tk_alloc(v->len + 1);
        memcpy(v->text, p->s + start, v->len);
        char *end;
        v->number = strtod(v->text, &end);
        if (*end) return j_fail(p, "a malformed number");
        return v;
    }
    return j_fail(p, "a value expected");
}

/* The value of the JSON text TEXT (LEN bytes), or NULL with ERROR set. */
static inline jval *json_parse(const char *text, size_t len, char *error, size_t errorSize) {
    jparser p = {text, len, 0, {0}};
    jval *v = j_value(&p, 0);
    if (v) {
        j_space(&p);
        if (p.i != p.n) { j_fail(&p, "text after the value"); v = NULL; }
    }
    if (!v) snprintf(error, errorSize, "%s", p.error);
    return v;
}

static inline jval *json_get(const jval *object, const char *key) {
    if (!object || object->kind != J_OBJ) return NULL;
    for (size_t k = 0; k < object->count; k++)
        if (!strcmp(object->keys[k], key)) return object->items[k];
    return NULL;
}

/* The string member KEY of OBJECT, or NULL. */
static inline const char *json_str(const jval *object, const char *key) {
    jval *v = json_get(object, key);
    return v && v->kind == J_STR ? v->text : NULL;
}

/* ----------------------------------------------------------- diagnostics */

static const char *tk_tool = "tool";
static const char *tk_diagnosticsPath = NULL;
static FILE *tk_diagnostics = NULL;
static int tk_diagnosticCount = 0;

static inline void tk_json_string(FILE *f, const char *s) {
    fputc('"', f);
    for (const unsigned char *c = (const unsigned char *)s; *c; c++) {
        if (*c == '"' || *c == '\\') fprintf(f, "\\%c", *c);
        else if (*c == '\n') fputs("\\n", f);
        else if (*c == '\t') fputs("\\t", f);
        else if (*c < 0x20) fprintf(f, "\\u%04x", *c);
        else fputc(*c, f);
    }
    fputc('"', f);
}

/* Reports a diagnostic: on standard error, and in the request's structured
 * diagnostics file (BOTLISH-TOOLS.md, "Diagnostics"). */
static inline void tk_report(const char *severity, const char *code, const char *file, const char *fmt, ...) {
    char message[2048];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(message, sizeof message, fmt, ap);
    va_end(ap);
    fprintf(stderr, "%s: %s: %s%s%s (%s)\n", tk_tool, severity, file ? file : "", file ? ": " : "", message, code);
    if (tk_diagnosticsPath && !tk_diagnostics) {
        tk_diagnostics = fopen(tk_diagnosticsPath, "w");
        if (tk_diagnostics) fputs("{\"diagnostics\": [", tk_diagnostics);
    }
    if (tk_diagnostics) {
        fputs(tk_diagnosticCount ? ",\n" : "\n", tk_diagnostics);
        fputs("{\"severity\": ", tk_diagnostics);
        tk_json_string(tk_diagnostics, severity);
        fputs(", \"code\": ", tk_diagnostics);
        tk_json_string(tk_diagnostics, code);
        fputs(", \"message\": ", tk_diagnostics);
        tk_json_string(tk_diagnostics, message);
        if (file) {
            fputs(", \"file\": ", tk_diagnostics);
            tk_json_string(tk_diagnostics, file);
        }
        fputc('}', tk_diagnostics);
        tk_diagnosticCount++;
    }
}

static inline void tk_finish(void) {
    if (tk_diagnostics) {
        fputs("\n]}\n", tk_diagnostics);
        fclose(tk_diagnostics);
        tk_diagnostics = NULL;
    }
}

/* Ends the tool with STATUS after reporting an error. */
static inline void tk_die(int status, const char *code, const char *file, const char *fmt, ...) {
    char message[2048];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(message, sizeof message, fmt, ap);
    va_end(ap);
    tk_report("error", code, file, "%s", message);
    tk_finish();
    exit(status);
}

/* ------------------------------------------------------------------ files */

static inline char *tk_read(const char *path, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    size_t cap = 4096, n = 0;
    char *buf = tk_alloc(cap);
    size_t got;
    while ((got = fread(buf + n, 1, cap - n - 1, f)) > 0) {
        n += got;
        if (cap - n < 2) { cap *= 2; buf = realloc(buf, cap); if (!buf) exit(70); }
    }
    fclose(f);
    buf[n] = 0;
    if (len) *len = n;
    return buf;
}

static inline jval *tk_read_json(const char *path, const char *what) {
    size_t len;
    char *text = tk_read(path, &len);
    if (!text) tk_die(2, "TOOL-INPUT", path, "cannot read %s: %s", what, strerror(errno));
    char error[300];
    jval *v = json_parse(text, len, error, sizeof error);
    if (!v) tk_die(2, "TOOL-INPUT", path, "%s is no JSON text: %s", what, error);
    return v;
}

static inline char *tk_join(const char *dir, const char *name) {
    size_t n = strlen(dir) + strlen(name) + 2;
    char *p = tk_alloc(n);
    snprintf(p, n, "%s/%s", dir, name);
    return p;
}

/* Makes the directory PATH and its parents. */
static inline void tk_mkdirs(const char *path) {
    char *copy = tk_strdup(path);
    for (char *c = copy + 1; *c; c++) {
        if (*c == '/') {
            *c = 0;
            mkdir(copy, 0777);
            *c = '/';
        }
    }
    mkdir(copy, 0777);
    free(copy);
}

/* A growing text buffer, written to a file at once. */
typedef struct { char *s; size_t len, cap; } tk_text;

static inline void tk_printf(tk_text *t, const char *fmt, ...) {
    va_list ap;
    while (1) {
        va_start(ap, fmt);
        int need = vsnprintf(t->s ? t->s + t->len : NULL, t->s ? t->cap - t->len : 0, fmt, ap);
        va_end(ap);
        if (need < 0) exit(70);
        if (t->s && t->len + (size_t)need < t->cap) { t->len += (size_t)need; return; }
        t->cap = (t->cap + (size_t)need + 1) * 2;
        t->s = realloc(t->s, t->cap);
        if (!t->s) exit(70);
    }
}

/* S as a JSON string, into T. */
static inline void tk_json_text(tk_text *t, const char *s) {
    tk_printf(t, "\"");
    for (const unsigned char *c = (const unsigned char *)s; *c; c++) {
        if (*c == '"' || *c == '\\') tk_printf(t, "\\%c", *c);
        else if (*c == '\n') tk_printf(t, "\\n");
        else if (*c == '\t') tk_printf(t, "\\t");
        else if (*c < 0x20) tk_printf(t, "\\u%04x", *c);
        else tk_printf(t, "%c", *c);
    }
    tk_printf(t, "\"");
}

/* Writes T to DIR/NAME (DIR made), as the tool's output. */
static inline void tk_write(const char *dir, const char *name, const tk_text *t) {
    char *path = tk_join(dir, name);
    char *slash = strrchr(path, '/');
    *slash = 0;
    tk_mkdirs(path);
    *slash = '/';
    FILE *f = fopen(path, "wb");
    if (!f || fwrite(t->s ? t->s : "", 1, t->len, f) != t->len || fclose(f) != 0)
        tk_die(1, "TOOL-OUTPUT", path, "cannot write: %s", strerror(errno));
    free(path);
}

/* --------------------------------------------------------------- request */

typedef struct {
    jval *root;
    const char *output;
    const char *target;
    const char *host;
    jval *artifacts;
    jval *arguments;
} tk_request;

/* The request BOTLISH_TOOL_REQUEST names (protocol 1), checked. */
static inline tk_request tk_open_request(const char *tool) {
    tk_tool = tool;
    const char *path = getenv("BOTLISH_TOOL_REQUEST");
    if (!path || !*path) {
        fprintf(stderr, "%s: no BOTLISH_TOOL_REQUEST: this is a Botlish tool, run by `botlish tool %s ...` (BOTLISH-TOOLS.md)\n", tool, tool);
        exit(64);
    }
    tk_request r = {0};
    r.root = tk_read_json(path, "the request");
    const char *diagnostics = json_str(r.root, "diagnostics");
    if (diagnostics) tk_diagnosticsPath = diagnostics;
    jval *protocol = json_get(r.root, "protocol");
    if (!protocol || protocol->kind != J_NUM || protocol->number != 1)
        tk_die(2, "TOOL-PROTOCOL", path, "this tool speaks tool protocol 1, and the request is no protocol 1 request");
    const char *kind = json_str(r.root, "kind");
    if (!kind || strcmp(kind, "botlish-tool-request"))
        tk_die(2, "TOOL-PROTOCOL", path, "the request's kind is not botlish-tool-request");
    r.output = json_str(r.root, "output");
    r.target = json_str(r.root, "target");
    r.host = json_str(r.root, "host");
    r.artifacts = json_get(r.root, "artifacts");
    r.arguments = json_get(r.root, "arguments");
    if (!r.output || !r.target || !r.host || !r.artifacts || r.artifacts->kind != J_ARR || !r.arguments || r.arguments->kind != J_ARR)
        tk_die(2, "TOOL-PROTOCOL", path, "the request lacks output, target, host, artifacts or arguments");
    return r;
}

/* ---------------------------------------------------- the library manifest */

typedef enum { T_INT, T_BOOL, T_FLOAT64, T_STR, T_UNIT } tk_type;

typedef struct {
    char *name;
    tk_type type;
} tk_param;

typedef struct {
    char *name;   /* the Botlish function */
    char *symbol; /* its C function */
    char *botlish;
    tk_param *params;
    size_t nparams;
    tk_type result;
    char *resultRelease; /* a str result's release function (the manifest's) */
    char *resultCType;   /* the result's out-parameter type, e.g. lib_bytes * */
    char *errorRelease;  /* the error out-parameter's release function */
} tk_export;

typedef struct {
    char *path;   /* the manifest */
    char *dir;    /* its directory, where its artifacts are */
    char *library;
    char *header; /* the header file's name */
    char *staticLib;
    char *runtimeAbi;
    char **link;
    size_t nlink;
    char **dependencies; /* each dependency's link argument */
    size_t ndependencies;
    char *create, *destroy, *bytesType;
    tk_export *exports;
    size_t nexports;
} tk_library;

static inline tk_type tk_type_named(const char *path, const char *name, int result) {
    if (!strcmp(name, "int")) return T_INT;
    if (!strcmp(name, "bool")) return T_BOOL;
    if (!strcmp(name, "float64")) return T_FLOAT64;
    if (!strcmp(name, "str")) return T_STR;
    if (result && !strcmp(name, "unit")) return T_UNIT;
    tk_die(1, "TOOL-UNSUPPORTED", path, "the boundary type \"%s\" is none this tool reads (int, bool, float64, str, unit): it refuses rather than guess", name);
    return T_UNIT;
}

static inline const char *tk_need_str(const jval *object, const char *key, const char *path, const char *what) {
    const char *s = json_str(object, key);
    if (!s) tk_die(1, "TOOL-MANIFEST", path, "%s has no string \"%s\"", what, key);
    return s;
}

/* The native library whose manifest is PATH (schema 2), read completely:
 * every export's parameters' and result's C types as the manifest states
 * them, and the ownership of what the caller owns. */
static inline tk_library tk_open_library(const char *path) {
    tk_library lib = {0};
    jval *m = tk_read_json(path, "the native library manifest");
    lib.path = tk_strdup(path);
    lib.dir = tk_strdup(path);
    char *slash = strrchr(lib.dir, '/');
    if (slash) *slash = 0; else strcpy(lib.dir, ".");
    jval *schema = json_get(m, "schema");
    const char *kind = json_str(m, "kind");
    if (!kind || strcmp(kind, "botlish-native-library"))
        tk_die(1, "TOOL-MANIFEST", path, "not a native library manifest (kind botlish-native-library)");
    if (!schema || schema->kind != J_NUM || schema->number != 2)
        tk_die(1, "TOOL-MANIFEST", path, "a native library manifest of schema %s: this tool reads schema 2", schema && schema->kind == J_NUM ? schema->text : "?");
    lib.library = tk_strdup(tk_need_str(m, "library", path, "the manifest"));
    /* The C ABI version fixes the runtime API's forms (create, destroy, the
     * error accessors): this tool knows version 1's, and checks the manifest
     * lists every function it calls. */
    jval *abi = json_get(m, "abi");
    if (!abi || abi->kind != J_NUM || abi->number != 1)
        tk_die(1, "TOOL-UNSUPPORTED", path, "the library's C ABI version is %s: this tool knows version 1", abi && abi->kind == J_NUM ? abi->text : "?");
    jval *api = json_get(m, "api");
    static const char *used[] = {"create", "destroy", "error_release", "error_identity", "error_message", "error_field_count",
        "error_field_name", "error_field_type", "error_field_int", "error_field_bool", "error_field_float64", "error_field_str", "bytes_release"};
    for (size_t u = 0; u < sizeof used / sizeof *used; u++) {
        char want[256];
        snprintf(want, sizeof want, "%s_%s", lib.library, used[u]);
        int listed = 0;
        for (size_t a = 0; api && api->kind == J_ARR && a < api->count; a++)
            if (api->items[a]->kind == J_STR && !strcmp(api->items[a]->text, want)) listed = 1;
        if (!listed) tk_die(1, "TOOL-MANIFEST", path, "the manifest's api does not list %s", want);
    }
    jval *artifacts = json_get(m, "artifacts");
    lib.header = tk_strdup(tk_need_str(artifacts, "header", path, "artifacts"));
    lib.staticLib = tk_strdup(tk_need_str(artifacts, "static", path, "artifacts"));
    lib.runtimeAbi = tk_strdup(tk_need_str(json_get(m, "compiler"), "runtimeAbi", path, "compiler"));
    jval *link = json_get(m, "link");
    if (!link || link->kind != J_ARR) tk_die(1, "TOOL-MANIFEST", path, "no \"link\"");
    lib.link = tk_alloc(link->count * sizeof *lib.link);
    for (size_t i = 0; i < link->count; i++) {
        if (link->items[i]->kind != J_STR) tk_die(1, "TOOL-MANIFEST", path, "a link argument that is no string");
        lib.link[lib.nlink++] = tk_strdup(link->items[i]->text);
    }
    jval *dependencies = json_get(m, "dependencies");
    if (dependencies && dependencies->kind == J_ARR) {
        lib.dependencies = tk_alloc(dependencies->count * sizeof *lib.dependencies);
        for (size_t i = 0; i < dependencies->count; i++)
            lib.dependencies[lib.ndependencies++] = tk_strdup(tk_need_str(dependencies->items[i], "link", path, "a dependency"));
    }
    /* Ownership: the conventions as data. */
    jval *ownership = json_get(m, "ownership");
    jval *strResult = json_get(ownership, "str-result");
    jval *error = json_get(ownership, "error");
    jval *instance = json_get(ownership, "instance");
    if (!strResult || !error || !instance)
        tk_die(1, "TOOL-MANIFEST", path, "the manifest states no ownership of str results, errors or the instance: this tool does not guess who releases what");
    lib.create = tk_strdup(tk_need_str(instance, "create", path, "ownership.instance"));
    lib.destroy = tk_strdup(tk_need_str(instance, "release", path, "ownership.instance"));
    jval *types = json_get(json_get(m, "types"), "str");
    lib.bytesType = tk_strdup(tk_need_str(types, "result", path, "types.str"));
    jval *exports = json_get(m, "exports");
    if (!exports || exports->kind != J_ARR) tk_die(1, "TOOL-MANIFEST", path, "no \"exports\"");
    lib.exports = tk_alloc(exports->count * sizeof *lib.exports);
    for (size_t e = 0; e < exports->count; e++) {
        jval *x = exports->items[e];
        tk_export *out = &lib.exports[lib.nexports++];
        out->name = tk_strdup(tk_need_str(x, "name", path, "an export"));
        out->symbol = tk_strdup(tk_need_str(x, "symbol", path, "an export"));
        out->botlish = tk_strdup(tk_need_str(x, "botlish", path, "an export"));
        jval *params = json_get(x, "params");
        if (!params || params->kind != J_ARR) tk_die(1, "TOOL-MANIFEST", path, "export %s has no params", out->name);
        out->params = tk_alloc(params->count * sizeof *out->params);
        for (size_t p = 0; p < params->count; p++) {
            jval *param = params->items[p];
            tk_param *q = &out->params[out->nparams++];
            q->name = tk_strdup(tk_need_str(param, "name", path, "a parameter"));
            q->type = tk_type_named(path, tk_need_str(param, "type", path, "a parameter"), 0);
            jval *c = json_get(param, "c");
            const char *ownershipOf = json_str(param, "ownership");
            /* The C types, exactly as the manifest states them. */
            const char *expected[2] = {NULL, NULL};
            switch (q->type) {
            case T_INT: expected[0] = "int64_t"; break;
            case T_BOOL: expected[0] = "bool"; break;
            case T_FLOAT64: expected[0] = "double"; break;
            case T_STR: expected[0] = "const uint8_t *"; expected[1] = "size_t"; break;
            default: break;
            }
            size_t want = expected[1] ? 2 : 1;
            if (!c || c->kind != J_ARR || c->count != want || strcmp(c->items[0]->text ? c->items[0]->text : "", expected[0])
                || (want == 2 && strcmp(c->items[1]->text ? c->items[1]->text : "", expected[1])))
                tk_die(1, "TOOL-UNSUPPORTED", path, "export %s: parameter %s has C types this tool does not read", out->name, q->name);
            if (!ownershipOf || strcmp(ownershipOf, q->type == T_STR ? "borrowed" : "value"))
                tk_die(1, "TOOL-MANIFEST", path, "export %s: parameter %s states no ownership this tool reads", out->name, q->name);
        }
        jval *result = json_get(x, "result");
        out->result = tk_type_named(path, tk_need_str(result, "type", path, "a result"), 1);
        out->resultCType = tk_strdup(tk_need_str(result, "c", path, "a result"));
        const char *resultOwnership = json_str(result, "ownership");
        if (!resultOwnership) tk_die(1, "TOOL-MANIFEST", path, "export %s: its result states no ownership", out->name);
        if (out->result == T_STR) {
            const char *release = json_str(result, "release");
            if (strcmp(resultOwnership, "owned") || !release)
                tk_die(1, "TOOL-MANIFEST", path, "export %s: its str result states no owner and release function", out->name);
            out->resultRelease = tk_strdup(release);
        }
        jval *errorOut = json_get(x, "error");
        const char *errorRelease = json_str(errorOut, "release");
        if (!errorRelease) tk_die(1, "TOOL-MANIFEST", path, "export %s: its error out-parameter states no release function", out->name);
        out->errorRelease = tk_strdup(errorRelease);
    }
    return lib;
}

/* The one native-library artifact of the request R. */
static inline tk_library tk_request_library(const tk_request *r) {
    const char *manifest = NULL;
    for (size_t i = 0; i < r->artifacts->count; i++) {
        const char *kind = json_str(r->artifacts->items[i], "kind");
        if (kind && !strcmp(kind, "native-library")) {
            if (manifest) tk_die(2, "TOOL-INPUT", NULL, "two native-library artifacts: this tool reads one");
            manifest = json_str(r->artifacts->items[i], "manifest");
        }
    }
    if (!manifest) tk_die(2, "TOOL-INPUT", NULL, "no native-library artifact (botlish tool -artifact LIB.manifest.json ...)");
    return tk_open_library(manifest);
}

static inline const char *tk_type_name(tk_type t) {
    switch (t) {
    case T_INT: return "int";
    case T_BOOL: return "bool";
    case T_FLOAT64: return "float64";
    case T_STR: return "str";
    default: return "unit";
    }
}

#endif
