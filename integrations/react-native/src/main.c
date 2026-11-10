/* main.c -- botlish-react-native, the `react-native` tool of the package
 * botlish_react_native (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md):
 * from one Botlish native library -- its manifest (schema 2), header and
 * Android AArch64 shared object -- an npm package that React Native's New
 * Architecture installs as a Pure C++ TurboModule.
 *
 *   botlish tool -out DIR -artifact LIB.manifest.json -target android-aarch64 \
 *       react-native generate [-name NPM-NAME] [-module MODULE] [-version V]
 *       [-react-native M.m] [-android-api N] [-license SPDX] [-replace]
 *
 * It speaks tool protocol 1 (BOTLISH-TOOLS.md) and knows Botlish through the
 * request and the manifest only: no HIR, no source, no compiler internals,
 * no file of a checkout. Every fact it relies on is checked first -- the
 * manifest's schema, target, C ABI version, types, ownership, threading and
 * reentrancy contracts; every artifact's SHA-256; the shared object's ELF
 * (AArch64, ET_DYN, 16 KiB segments, its SONAME, Bionic's libraries only,
 * its C ABI exported) -- and a manifest it cannot read completely is
 * refused, never guessed at. Nothing about any one library is built in:
 * names, methods and types come from the manifest and the options.
 *
 * The package's native interface is React Native's own: the app's Codegen
 * generates it from the TypeScript spec (codegenConfig, includesGeneratedCode
 * false); the tool writes the spec, a checked TypeScript entry point, the
 * C++ adapter, its CMake file, the autolinking configuration, the library
 * and its header, and a record of what it was generated from.
 *
 * Output is deterministic: no time, host path or directory order. C99 and
 * POSIX, the C library only. */
#define _POSIX_C_SOURCE 200809L
#include "elf.h"
#include "json.h"
#include "sha256.h"
#include "templates.h"

#include <ctype.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

#define TOOL_NAME "botlish-react-native"
#define TOOL_VERSION "0.1.0"

/* ----------------------------------------------------------- diagnostics */

static const char *diagnosticsPath = NULL;
static FILE *diagnostics = NULL;
static int diagnosticCount = 0;

static void json_out(FILE *f, const char *s) {
    fputc('"', f);
    for (const unsigned char *c = (const unsigned char *)s; *c; c++) {
        if (*c == '"' || *c == '\\') fprintf(f, "\\%c", *c);
        else if (*c == '\n') fputs("\\n", f);
        else if (*c < 0x20) fprintf(f, "\\u%04x", *c);
        else fputc(*c, f);
    }
    fputc('"', f);
}

/* Reports a diagnostic on standard error and in the request's structured
 * diagnostics (BOTLISH-TOOLS.md, section 7). */
static void report(const char *severity, const char *code, const char *file, const char *fmt, ...) {
    char message[4096];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(message, sizeof message, fmt, ap);
    va_end(ap);
    fprintf(stderr, "react-native: %s: %s%s%s (%s)\n", severity, file ? file : "", file ? ": " : "", message, code);
    if (diagnosticsPath && !diagnostics) {
        diagnostics = fopen(diagnosticsPath, "w");
        if (diagnostics) fputs("{\"diagnostics\": [", diagnostics);
    }
    if (diagnostics) {
        fputs(diagnosticCount ? ",\n" : "\n", diagnostics);
        fputs("{\"severity\": ", diagnostics);
        json_out(diagnostics, severity);
        fputs(", \"code\": ", diagnostics);
        json_out(diagnostics, code);
        fputs(", \"message\": ", diagnostics);
        json_out(diagnostics, message);
        if (file) {
            fputs(", \"file\": ", diagnostics);
            json_out(diagnostics, file);
        }
        fputc('}', diagnostics);
        diagnosticCount++;
    }
}

static void finish(void) {
    if (diagnostics) {
        fputs("\n]}\n", diagnostics);
        fclose(diagnostics);
        diagnostics = NULL;
    }
}

/* Refuses: reports CODE and ends with STATUS (1 a refusal, 2 a malformed
 * invocation), having written nothing. */
static void die(int status, const char *code, const char *file, const char *fmt, ...) {
    char message[4096];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(message, sizeof message, fmt, ap);
    va_end(ap);
    report("error", code, file, "%s", message);
    finish();
    exit(status);
}

/* ----------------------------------------------------------------- memory */

static void *xalloc(size_t n) {
    void *p = calloc(1, n ? n : 1);
    if (!p) {
        fputs("react-native: out of memory\n", stderr);
        exit(70);
    }
    return p;
}

static char *xstrdup(const char *s) {
    char *p = xalloc(strlen(s) + 1);
    strcpy(p, s);
    return p;
}

static char *xprintf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    int n = vsnprintf(NULL, 0, fmt, ap);
    va_end(ap);
    char *p = xalloc((size_t)n + 1);
    va_start(ap, fmt);
    vsnprintf(p, (size_t)n + 1, fmt, ap);
    va_end(ap);
    return p;
}

/* A growing text. */
typedef struct {
    char *s;
    size_t len, cap;
} text;

static void put(text *t, const char *s, size_t n) {
    if (t->len + n + 1 > t->cap) {
        t->cap = (t->len + n + 1) * 2;
        t->s = realloc(t->s, t->cap);
        if (!t->s) exit(70);
    }
    memcpy(t->s + t->len, s, n);
    t->len += n;
    t->s[t->len] = 0;
}

static void puts_(text *t, const char *s) { put(t, s, strlen(s)); }

static void printf_(text *t, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    int n = vsnprintf(NULL, 0, fmt, ap);
    va_end(ap);
    char *p = xalloc((size_t)n + 1);
    va_start(ap, fmt);
    vsnprintf(p, (size_t)n + 1, fmt, ap);
    va_end(ap);
    put(t, p, (size_t)n);
    free(p);
}

/* S as a JSON string. */
static void json_text(text *t, const char *s) {
    puts_(t, "\"");
    for (const unsigned char *c = (const unsigned char *)s; *c; c++) {
        if (*c == '"' || *c == '\\') printf_(t, "\\%c", *c);
        else if (*c == '\n') puts_(t, "\\n");
        else if (*c < 0x20) printf_(t, "\\u%04x", *c);
        else put(t, (const char *)c, 1);
    }
    puts_(t, "\"");
}

/* ---------------------------------------------------------------- templates */

typedef struct {
    const char *key;
    const char *value;
} binding;

#define MAX_BINDINGS 48
static binding bindings[MAX_BINDINGS];
static int nbindings = 0;

static void bind(const char *key, const char *value) {
    for (int i = 0; i < nbindings; i++) {
        if (!strcmp(bindings[i].key, key)) {
            bindings[i].value = value;
            return;
        }
    }
    if (nbindings == MAX_BINDINGS) exit(70);
    bindings[nbindings].key = key;
    bindings[nbindings].value = value;
    nbindings++;
}

/* The template TEMPLATE with every @KEY@ replaced by its binding. A key
 * without a binding is a defect of this tool. */
static text expand(const char *template_) {
    text t = {0};
    const char *p = template_;
    while (*p) {
        const char *at = strchr(p, '@');
        if (!at) {
            puts_(&t, p);
            break;
        }
        put(&t, p, (size_t)(at - p));
        const char *end = at + 1;
        while ((*end >= 'A' && *end <= 'Z') || *end == '_') end++;
        if (*end == '@' && end > at + 1) {
            size_t n = (size_t)(end - at - 1);
            int found = 0;
            for (int i = 0; i < nbindings; i++) {
                if (strlen(bindings[i].key) == n && !memcmp(bindings[i].key, at + 1, n)) {
                    puts_(&t, bindings[i].value);
                    found = 1;
                    break;
                }
            }
            if (!found) {
                fprintf(stderr, "react-native: internal: template key @%.*s@ has no value\n", (int)n, at + 1);
                exit(70);
            }
            p = end + 1;
        } else {
            put(&t, "@", 1);
            p = at + 1;
        }
    }
    if (!t.s) puts_(&t, "");
    return t;
}

/* ------------------------------------------------------------------ files */

static char *readFile(const char *path, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    size_t cap = 1 << 16, n = 0;
    char *buf = xalloc(cap);
    size_t got;
    while ((got = fread(buf + n, 1, cap - n - 1, f)) > 0) {
        n += got;
        if (cap - n < 2) {
            cap *= 2;
            buf = realloc(buf, cap);
            if (!buf) exit(70);
        }
    }
    int bad = ferror(f);
    fclose(f);
    if (bad) {
        free(buf);
        return NULL;
    }
    buf[n] = 0;
    *len = n;
    return buf;
}

static jval *readJson(const char *path, const char *what, const char *code) {
    size_t len;
    char *data = readFile(path, &len);
    if (!data) die(1, code, path, "cannot read %s: %s", what, strerror(errno));
    char error[300];
    jval *v = json_parse(data, len, error, sizeof error);
    if (!v) die(1, code, path, "%s is no JSON text: %s", what, error);
    return v;
}

static void mkdirs(const char *path) {
    char *copy = xstrdup(path);
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

/* The files written, relative to the output directory, in order. */
static char *written[64];
static int nwritten = 0;

static void writeFile(const char *dir, const char *name, const char *data, size_t len) {
    char *path = xprintf("%s/%s", dir, name);
    char *slash = strrchr(path, '/');
    *slash = 0;
    mkdirs(path);
    *slash = '/';
    FILE *f = fopen(path, "wb");
    if (!f || fwrite(data, 1, len, f) != len || fclose(f) != 0)
        die(1, "RN-WRITE", path, "cannot write: %s", strerror(errno));
    free(path);
    if (nwritten < 64) written[nwritten++] = xstrdup(name);
}

static void writeText(const char *dir, const char *name, const text *t) {
    writeFile(dir, name, t->s ? t->s : "", t->len);
}

/* ---------------------------------------------------------------- request */

typedef struct {
    const char *path;
    const char *output;
    const char *target;
    const char *host;
    const char *manifest;
} request;

static request openRequest(void) {
    request r = {0};
    r.path = getenv("BOTLISH_TOOL_REQUEST");
    if (!r.path || !*r.path) {
        fprintf(stderr, "react-native: no BOTLISH_TOOL_REQUEST: this is a Botlish tool, run as `botlish tool -out DIR "
                        "-artifact LIB.manifest.json -target android-aarch64 react-native generate` (BOTLISH-TOOLS.md)\n");
        exit(64);
    }
    jval *root = readJson(r.path, "the request", "RN-REQUEST");
    const char *diag = json_str(root, "diagnostics");
    if (diag) diagnosticsPath = diag;
    long long protocol;
    if (!json_int(root, "protocol", &protocol) || protocol != 1)
        die(2, "RN-REQUEST", r.path, "this tool speaks tool protocol 1, and the request is no protocol 1 request");
    const char *kind = json_str(root, "kind");
    if (!kind || strcmp(kind, "botlish-tool-request"))
        die(2, "RN-REQUEST", r.path, "the request's kind is not botlish-tool-request");
    r.output = json_str(root, "output");
    r.target = json_str(root, "target");
    r.host = json_str(root, "host");
    jval *artifacts = json_get(root, "artifacts");
    if (!r.output || !r.target || !r.host || !artifacts || artifacts->kind != J_ARR)
        die(2, "RN-REQUEST", r.path, "the request lacks output, target, host or artifacts");
    for (size_t i = 0; i < artifacts->count; i++) {
        const char *k = json_str(artifacts->items[i], "kind");
        if (k && !strcmp(k, "native-library")) {
            if (r.manifest) die(2, "RN-REQUEST", r.path, "two native-library artifacts: a package wraps one library");
            r.manifest = json_str(artifacts->items[i], "manifest");
        }
    }
    if (!r.manifest)
        die(2, "RN-REQUEST", r.path, "no native-library artifact: run `botlish tool -artifact LIB.manifest.json ...`");
    return r;
}

/* ------------------------------------------------------------ the library */

typedef enum { B_INT, B_BOOL, B_FLOAT64, B_STR, B_UNIT } btype;

typedef struct {
    char *name; /* the Botlish parameter */
    char *js;   /* its JavaScript name */
    btype type;
} param;

typedef struct {
    char *name;    /* the Botlish function */
    char *symbol;  /* its C function */
    char *botlish; /* its Botlish signature */
    char *js;      /* its JavaScript method */
    param *params;
    size_t nparams;
    btype result;
    char **errors;
    size_t nerrors;
} export_;

typedef struct {
    char *path, *dir;
    char *library, *target, *triple, *runtimeAbi, *frontEnd;
    char *supportPackage, *toolchain, *toolchainRevision;
    long long minimumApi;
    char *staticName, *sharedName, *headerName;
    char *shaStatic, *shaShared, *shaHeader, *shaManifest;
    export_ *exports;
    size_t nexports;
} library;

static const char *need(const jval *object, const char *key, const char *path, const char *what) {
    const char *s = json_str(object, key);
    if (!s) die(1, "RN-MANIFEST", path, "%s has no string \"%s\"", what, key);
    return s;
}

static int matches(const char *s, const char *expected) { return s && expected && !strcmp(s, expected); }

static int isHex(const char *s, size_t n) {
    if (!s || strlen(s) != n) return 0;
    for (size_t i = 0; i < n; i++)
        if (!isdigit((unsigned char)s[i]) && !(s[i] >= 'a' && s[i] <= 'f')) return 0;
    return 1;
}

static int isIdentifier(const char *s) {
    if (!s || !*s || !(islower((unsigned char)*s))) return 0;
    for (const char *c = s; *c; c++)
        if (!islower((unsigned char)*c) && !isdigit((unsigned char)*c) && *c != '_') return 0;
    return strlen(s) <= 64;
}

static btype typeNamed(const char *path, const char *where, const char *name, int result) {
    if (matches(name, "int")) return B_INT;
    if (matches(name, "bool")) return B_BOOL;
    if (matches(name, "float64")) return B_FLOAT64;
    if (matches(name, "str")) return B_STR;
    if (result && matches(name, "unit")) return B_UNIT;
    die(1, "RN-UNSUPPORTED", path, "%s has the boundary type \"%s\", which this generator does not map to JavaScript (it maps int, bool, float64, str and a unit result): it refuses rather than guess",
        where, name ? name : "?");
    return B_UNIT;
}

/* camel_case of NAME: snake_case words joined, each after the first
 * capitalized. */
static char *camel(const char *name) {
    char *out = xalloc(strlen(name) + 1);
    size_t o = 0;
    int up = 0;
    for (const char *c = name; *c; c++) {
        if (*c == '_') {
            up = o > 0;
            continue;
        }
        out[o++] = up ? (char)toupper((unsigned char)*c) : *c;
        up = 0;
    }
    out[o] = 0;
    return out;
}

static char *pascal(const char *name) {
    char *out = camel(name);
    out[0] = (char)toupper((unsigned char)out[0]);
    return out;
}

static const char *const jsReserved[] = {
    "arguments", "await", "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete", "do",
    "else", "enum", "eval", "export", "extends", "false", "finally", "for", "function", "if", "implements", "import", "in",
    "instanceof", "interface", "let", "new", "null", "package", "private", "protected", "public", "return", "static",
    "super", "switch", "this", "throw", "true", "try", "typeof", "undefined", "var", "void", "while", "with", "yield",
};

static int jsReservedWord(const char *s) {
    for (size_t i = 0; i < sizeof jsReserved / sizeof *jsReserved; i++)
        if (!strcmp(jsReserved[i], s)) return 1;
    return 0;
}

/* The names a method may not have: the TurboModule's own members, the
 * object protocol, and the entry point's own exports. */
static const char *const methodReserved[] = {
    "getConstants", "constructor", "botlishDiagnostics", "toString", "valueOf", "hasOwnProperty", "isPrototypeOf",
    "propertyIsEnumerable", "toLocaleString", "library", "diagnostics", "declaredErrors", "isBotlishError",
};

/* Reads the manifest PATH completely, refusing what this generator cannot
 * read: every C type and ownership is checked to be exactly what the C ABI
 * version 1 states for its boundary type. */
static library openLibrary(const char *path, const char *target) {
    library lib = {0};
    jval *m = readJson(path, "the native library manifest", "RN-MANIFEST");
    lib.path = xstrdup(path);
    lib.dir = xstrdup(path);
    char *slash = strrchr(lib.dir, '/');
    if (slash) *slash = 0;
    else strcpy(lib.dir, ".");
    char hex[65];
    if (!sha256_file(path, hex)) die(1, "RN-MANIFEST", path, "cannot read the manifest");
    lib.shaManifest = xstrdup(hex);

    if (!matches(json_str(m, "kind"), "botlish-native-library"))
        die(1, "RN-MANIFEST", path, "not a native library manifest (kind botlish-native-library)");
    long long schema = 0;
    if (!json_int(m, "schema", &schema) || schema != 2)
        die(1, "RN-MANIFEST", path, "a native library manifest of schema %lld: this generator reads schema 2 (a schema 1 manifest binds no files and states no ownership: build the library again)", schema);
    lib.library = xstrdup(need(m, "library", path, "the manifest"));
    if (!isIdentifier(lib.library))
        die(1, "RN-MANIFEST", path, "the library name \"%s\" is no C identifier of lowercase letters, digits and _", lib.library);
    const char *L = lib.library;
    long long abi = 0;
    if (!json_int(m, "abi", &abi) || abi != 1)
        die(1, "RN-UNSUPPORTED", path, "the library's C ABI version is %lld: this generator knows version 1", abi);

    /* The target: an Android AArch64 library, the one this generator
     * packages, and the one the tool command checked the artifact against. */
    jval *t = json_get(m, "target");
    lib.target = xstrdup(need(t, "name", path, "target"));
    lib.triple = xstrdup(need(t, "triple", path, "target"));
    if (strcmp(lib.target, "android-aarch64") || strcmp(lib.triple, "aarch64-linux-android"))
        die(1, "RN-TARGET", path, "the library is built for %s (%s); a React Native Android package needs an android-aarch64 (aarch64-linux-android) library: build it with -target android-aarch64 -target-support PACKAGE",
            lib.target, lib.triple);
    if (strcmp(target, lib.target))
        die(1, "RN-TARGET", path, "the request's target is %s and the library's %s: run the tool with -target %s", target, lib.target, lib.target);

    /* The compiler and the runtime ABI. */
    jval *compiler = json_get(m, "compiler");
    lib.runtimeAbi = xstrdup(need(compiler, "runtimeAbi", path, "compiler"));
    lib.frontEnd = xstrdup(need(compiler, "frontEnd", path, "compiler"));
    if (!isHex(lib.runtimeAbi, 16))
        die(1, "RN-RUNTIME-ABI", path, "the runtime ABI \"%s\" is no runtime ABI fingerprint (16 hexadecimal digits)", lib.runtimeAbi);
    jval *support = json_get(m, "targetSupport");
    if (!support || support->kind != J_OBJ)
        die(1, "RN-MANIFEST", path, "the manifest names no target support package: an Android library is linked with one (-target-support)");
    lib.supportPackage = xstrdup(need(support, "package", path, "targetSupport"));
    const char *supportAbi = need(support, "runtimeAbi", path, "targetSupport");
    if (strcmp(supportAbi, lib.runtimeAbi))
        die(1, "RN-RUNTIME-ABI", path, "the library's runtime ABI is %s and its target support package's (%s) %s: the library was linked with a runtime of another ABI",
            lib.runtimeAbi, lib.supportPackage, supportAbi);
    if (!json_int(json_get(support, "platform"), "minimumApi", &lib.minimumApi) || lib.minimumApi < 21)
        die(1, "RN-MANIFEST", path, "targetSupport.platform.minimumApi is no Android API level of at least 21");
    jval *toolchain = json_get(support, "toolchain");
    lib.toolchain = xstrdup(need(toolchain, "name", path, "targetSupport.toolchain"));
    lib.toolchainRevision = xstrdup(need(toolchain, "revision", path, "targetSupport.toolchain"));

    /* The contracts the adapter relies on. */
    if (!matches(json_str(m, "threading"), "thread-affine") || !matches(json_str(m, "reentrancy"), "refused"))
        die(1, "RN-UNSUPPORTED", path, "the library's threading is \"%s\" and its reentrancy \"%s\": this generator knows thread-affine instances that refuse reentrant calls",
            json_str(m, "threading") ? json_str(m, "threading") : "?", json_str(m, "reentrancy") ? json_str(m, "reentrancy") : "?");
    jval *callbacks = json_get(m, "callbacks");
    if (!callbacks || callbacks->kind != J_ARR || callbacks->count)
        die(1, "RN-UNSUPPORTED", path, "the library takes callbacks: this generator maps none");
    jval *dependencies = json_get(m, "dependencies");
    if (!dependencies || dependencies->kind != J_ARR || dependencies->count)
        die(1, "RN-UNSUPPORTED", path, "the library has native dependencies of its own: this generator packages a library that needs Android's system libraries only");
    static const struct {
        const char *name;
        long long value;
    } statuses[] = {{"ok", 0}, {"declared", 1}, {"runtime", 2}, {"boundary", 3}, {"invocation", 4}, {"internal", 5}};
    jval *st = json_get(m, "statuses");
    for (size_t i = 0; i < sizeof statuses / sizeof *statuses; i++) {
        long long v;
        if (!json_int(st, statuses[i].name, &v) || v != statuses[i].value)
            die(1, "RN-UNSUPPORTED", path, "the status \"%s\" is not %lld: this generator knows the C ABI version 1's statuses", statuses[i].name, statuses[i].value);
    }
    jval *ownership = json_get(m, "ownership");
    jval *instance = json_get(ownership, "instance");
    char *create = xprintf("%s_create", L), *destroy = xprintf("%s_destroy", L);
    char *bytesRelease = xprintf("%s_bytes_release", L), *errorRelease = xprintf("%s_error_release", L);
    char *bytesType = xprintf("%s_bytes", L), *bytesC = xprintf("%s_bytes *", L), *errorC = xprintf("%s_error **", L);
    if (!matches(json_str(instance, "owner"), "caller") || !matches(json_str(instance, "create"), create) || !matches(json_str(instance, "release"), destroy))
        die(1, "RN-UNSUPPORTED", path, "ownership.instance is not the caller's, created by %s and released by %s", create, destroy);
    jval *strArgument = json_get(ownership, "str-argument");
    if (!matches(json_str(strArgument, "lifetime"), "call"))
        die(1, "RN-UNSUPPORTED", path, "ownership.str-argument is not borrowed for the call");
    if (!matches(json_str(json_get(ownership, "str-result"), "owner"), "caller") || !matches(json_str(json_get(ownership, "str-result"), "release"), bytesRelease))
        die(1, "RN-UNSUPPORTED", path, "ownership.str-result is not the caller's, released by %s", bytesRelease);
    if (!matches(json_str(json_get(ownership, "error"), "owner"), "caller") || !matches(json_str(json_get(ownership, "error"), "release"), errorRelease))
        die(1, "RN-UNSUPPORTED", path, "ownership.error is not the caller's, released by %s", errorRelease);
    if (!matches(json_str(json_get(json_get(m, "types"), "str"), "result"), bytesType))
        die(1, "RN-UNSUPPORTED", path, "types.str.result is not %s", bytesType);
    jval *api = json_get(m, "api");
    static const char *used[] = {"create", "destroy", "error_release", "error_identity", "error_message", "error_field_count",
        "error_field_name", "error_field_type", "error_field_int", "error_field_bool", "error_field_float64",
        "error_field_str", "bytes_release"};
    for (size_t u = 0; u < sizeof used / sizeof *used; u++) {
        char *want = xprintf("%s_%s", L, used[u]);
        int listed = 0;
        for (size_t a = 0; api && api->kind == J_ARR && a < api->count; a++)
            if (api->items[a]->kind == J_STR && !strcmp(api->items[a]->text, want)) listed = 1;
        if (!listed) die(1, "RN-MANIFEST", path, "the manifest's api does not list %s", want);
        free(want);
    }

    /* The files, bound by their digests. */
    jval *files = json_get(m, "artifacts");
    jval *sha = json_get(m, "sha256");
    lib.staticName = xstrdup(need(files, "static", path, "artifacts"));
    lib.headerName = xstrdup(need(files, "header", path, "artifacts"));
    const char *shared = json_str(files, "shared");
    if (!shared)
        die(1, "RN-ARTIFACT", path, "the library has no shared object: React Native's Android build packages lib%s.so", L);
    lib.sharedName = xstrdup(shared);
    char *expect[3] = {xprintf("lib%s.a", L), xprintf("lib%s.so", L), xprintf("%s.h", L)};
    char *names[3] = {lib.staticName, lib.sharedName, lib.headerName};
    const char *keys[3] = {"static", "shared", "header"};
    char **digests[3] = {&lib.shaStatic, &lib.shaShared, &lib.shaHeader};
    for (int i = 0; i < 3; i++) {
        if (strcmp(names[i], expect[i]))
            die(1, "RN-MANIFEST", path, "artifacts.%s is \"%s\", not %s", keys[i], names[i], expect[i]);
        const char *recorded = json_str(sha, keys[i]);
        if (!isHex(recorded, 64)) die(1, "RN-MANIFEST", path, "sha256.%s is no SHA-256", keys[i]);
        char *file = xprintf("%s/%s", lib.dir, names[i]);
        if (!sha256_file(file, hex))
            die(1, "RN-ARTIFACT", file, "the library's %s file is missing or unreadable: %s", keys[i], strerror(errno));
        if (strcmp(hex, recorded))
            die(1, "RN-ARTIFACT", file, "is not the file the manifest describes: its SHA-256 is %s, the manifest's %s (a stale or substituted %s)", hex, recorded, keys[i]);
        *digests[i] = xstrdup(recorded);
        free(file);
    }

    /* The exports. */
    jval *exports = json_get(m, "exports");
    if (!exports || exports->kind != J_ARR || !exports->count)
        die(1, "RN-MANIFEST", path, "the library exports no function");
    lib.exports = xalloc(exports->count * sizeof *lib.exports);
    for (size_t e = 0; e < exports->count; e++) {
        jval *x = exports->items[e];
        export_ *out = &lib.exports[lib.nexports++];
        out->name = xstrdup(need(x, "name", path, "an export"));
        out->symbol = xstrdup(need(x, "symbol", path, "an export"));
        out->botlish = xstrdup(need(x, "botlish", path, "an export"));
        char *symbol = xprintf("%s_%s", L, out->name);
        if (!isIdentifier(out->name) || strcmp(out->symbol, symbol))
            die(1, "RN-MANIFEST", path, "export \"%s\": its C symbol is \"%s\", not %s", out->name, out->symbol, symbol);
        out->js = camel(out->name);
        jval *params = json_get(x, "params");
        if (!params || params->kind != J_ARR) die(1, "RN-MANIFEST", path, "export %s has no params", out->name);
        out->params = xalloc((params->count + 1) * sizeof *out->params);
        for (size_t p = 0; p < params->count; p++) {
            jval *pv = params->items[p];
            param *q = &out->params[out->nparams++];
            q->name = xstrdup(need(pv, "name", path, "a parameter"));
            char *where = xprintf("export %s, parameter %s,", out->name, q->name);
            q->type = typeNamed(path, where, json_str(pv, "type"), 0);
            jval *c = json_get(pv, "c");
            const char *want0 = q->type == B_INT ? "int64_t" : q->type == B_BOOL ? "bool" : q->type == B_FLOAT64 ? "double" : "const uint8_t *";
            size_t count = q->type == B_STR ? 2 : 1;
            if (!c || c->kind != J_ARR || c->count != count || c->items[0]->kind != J_STR || strcmp(c->items[0]->text, want0)
                || (count == 2 && (c->items[1]->kind != J_STR || strcmp(c->items[1]->text, "size_t"))))
                die(1, "RN-UNSUPPORTED", path, "%s has C types this generator does not read (expected %s%s)", where, want0, count == 2 ? ", size_t" : "");
            const char *own = json_str(pv, "ownership");
            if (q->type == B_STR ? !(matches(own, "borrowed") && matches(json_str(pv, "lifetime"), "call")) : !matches(own, "value"))
                die(1, "RN-UNSUPPORTED", path, "%s states the ownership \"%s\": this generator reads %s", where, own ? own : "?", q->type == B_STR ? "borrowed for the call" : "value");
            q->js = camel(q->name);
            int clash = jsReservedWord(q->js) || !*q->js;
            for (size_t o = 0; o + 1 < out->nparams; o++)
                if (!strcmp(out->params[o].js, q->js)) clash = 1;
            if (clash) {
                char *renamed = xprintf("%sArg%zu", *q->js ? q->js : "arg", p);
                free(q->js);
                q->js = renamed;
            }
            free(where);
        }
        jval *result = json_get(x, "result");
        char *where = xprintf("export %s's result", out->name);
        out->result = typeNamed(path, where, json_str(result, "type"), 1);
        const char *rc = json_str(result, "c");
        const char *rown = json_str(result, "ownership");
        switch (out->result) {
        case B_INT: if (!matches(rc, "int64_t *") || !matches(rown, "value")) die(1, "RN-UNSUPPORTED", path, "%s is not an int64_t * value", where); break;
        case B_BOOL: if (!matches(rc, "bool *") || !matches(rown, "value")) die(1, "RN-UNSUPPORTED", path, "%s is not a bool * value", where); break;
        case B_FLOAT64: if (!matches(rc, "double *") || !matches(rown, "value")) die(1, "RN-UNSUPPORTED", path, "%s is not a double * value", where); break;
        case B_STR:
            if (!matches(rc, bytesC) || !matches(rown, "owned") || !matches(json_str(result, "release"), bytesRelease))
                die(1, "RN-UNSUPPORTED", path, "%s is not an owned %s released by %s", where, bytesC, bytesRelease);
            break;
        case B_UNIT: if (!matches(rown, "none")) die(1, "RN-UNSUPPORTED", path, "%s is unit with the ownership \"%s\", not none", where, rown ? rown : "?"); break;
        }
        free(where);
        jval *error = json_get(x, "error");
        if (!matches(json_str(error, "c"), errorC) || !matches(json_str(error, "ownership"), "owned") || !matches(json_str(error, "release"), errorRelease))
            die(1, "RN-UNSUPPORTED", path, "export %s: its error out-parameter is not an owned %s released by %s", out->name, errorC, errorRelease);
        jval *errors = json_get(x, "errors");
        if (!errors || errors->kind != J_ARR) die(1, "RN-MANIFEST", path, "export %s has no errors", out->name);
        out->errors = xalloc((errors->count + 1) * sizeof *out->errors);
        for (size_t k = 0; k < errors->count; k++)
            out->errors[out->nerrors++] = xstrdup(need(errors->items[k], "name", path, "a declared error"));
        /* Its JavaScript name. */
        int bad = strlen(out->js) == 0 || jsReservedWord(out->js);
        for (size_t r = 0; r < sizeof methodReserved / sizeof *methodReserved; r++)
            if (!strcmp(methodReserved[r], out->js)) bad = 1;
        if (bad)
            die(1, "RN-NAME", path, "export %s: its JavaScript name %s is reserved (a JavaScript word, a TurboModule member or a name of the package's entry point)", out->name, out->js);
        for (size_t o = 0; o + 1 < lib.nexports; o++)
            if (!strcmp(lib.exports[o].js, out->js))
                die(1, "RN-NAME", path, "exports %s and %s have the same JavaScript name %s", lib.exports[o].name, out->name, out->js);
        free(symbol);
    }
    return lib;
}

/* The header must declare every export (its text, not the manifest's word). */
static void checkHeader(const library *lib, const char *data) {
    char *guard = xprintf("#define %s_ABI_VERSION 1", lib->library);
    if (!strstr(data, guard))
        die(1, "RN-ARTIFACT", lib->headerName, "the header does not state the C ABI version 1 (%s)", guard);
    for (size_t e = 0; e < lib->nexports; e++) {
        char *decl = xprintf("int32_t %s(", lib->exports[e].symbol);
        if (!strstr(data, decl)) die(1, "RN-ARTIFACT", lib->headerName, "the header does not declare %s", lib->exports[e].symbol);
        free(decl);
    }
    free(guard);
}

/* The shared object, from its bytes: an Android AArch64 shared library,
 * aligned for 16 KiB pages, needing Bionic's system libraries only (no
 * glibc), exporting its C ABI. */
static void checkShared(const library *lib, const char *file) {
    size_t len;
    char *data = readFile(file, &len);
    if (!data) die(1, "RN-ARTIFACT", file, "cannot read the shared library");
    elf_facts f = elf_read((const uint8_t *)data, len);
    if (!f.ok) die(1, "RN-ELF", file, "is no shared library this generator reads: %s", f.error);
    if (f.machine != 183)
        die(1, "RN-ELF", file, "is built for the ELF machine %d, not AArch64 (183): it is no arm64-v8a library", f.machine);
    if (f.type != 3) die(1, "RN-ELF", file, "is no shared object (ELF type %d)", f.type);
    if (f.minAlign < 16384)
        die(1, "RN-ELF", file, "has a loadable segment aligned to %llu bytes: Android's 16 KiB page devices need 16384 (link with -z max-page-size=16384)",
            (unsigned long long)f.minAlign);
    char *soname = xprintf("lib%s.so", lib->library);
    if (!f.soname || strcmp(f.soname, soname))
        die(1, "RN-ELF", file, "its SONAME is \"%s\", not %s", f.soname ? f.soname : "", soname);
    static const char *bionic[] = {"libc.so", "libm.so", "libdl.so", "liblog.so"};
    for (size_t i = 0; i < f.nneeded; i++) {
        int ok = 0;
        for (size_t b = 0; b < sizeof bionic / sizeof *bionic; b++)
            if (!strcmp(f.needed[i], bionic[b])) ok = 1;
        if (!ok)
            die(1, "RN-ELF", file, "needs %s, which is none of Android's system libraries (libc.so, libm.so, libdl.so, liblog.so): it is no Android library (a glibc library needs libc.so.6)", f.needed[i]);
    }
    for (size_t i = 0; i < f.nversions; i++)
        if (!strncmp(f.versions[i], "GLIBC_", 6))
            die(1, "RN-ELF", file, "requires the glibc symbol version %s: it is a Linux/glibc library, not an Android one", f.versions[i]);
    if (f.textrel) die(1, "RN-ELF", file, "has text relocations, which Android refuses");
    static const char *api[] = {"create", "destroy", "error_release", "error_identity", "error_message", "error_field_count",
        "error_field_name", "error_field_type", "error_field_int", "error_field_bool", "error_field_float64",
        "error_field_str", "bytes_release"};
    for (size_t u = 0; u < sizeof api / sizeof *api; u++) {
        char *s = xprintf("%s_%s", lib->library, api[u]);
        if (!elf_has(f.symbols, f.nsymbols, s)) die(1, "RN-ELF", file, "does not export %s", s);
        free(s);
    }
    for (size_t e = 0; e < lib->nexports; e++)
        if (!elf_has(f.symbols, f.nsymbols, lib->exports[e].symbol))
            die(1, "RN-ELF", file, "does not export %s, the C function of %s", lib->exports[e].symbol, lib->exports[e].name);
    free(soname);
    free(data);
}

/* ---------------------------------------------------------------- options */

/* The React Native versions this generator generates for: the adapter's
 * C++ interface (Codegen's CxxSpec, Bridging, JSI) and the autolinking of a
 * pure C++ dependency with app-owned Codegen, as they are in that minor
 * version. A version not listed here is refused, never assumed to agree. */
static const struct {
    const char *minor;
    const char *range;
    const char *tested;
    int minimumApi;
} reactNatives[] = {
    {"0.88", ">=0.88.0 <0.89.0", "0.88.1", 24},
};

typedef struct {
    char *npm;
    char *module;
    char *version;
    char *license;
    int rn;
    long long api;
    int replace;
} options;

static int validNpm(const char *s) {
    size_t n = strlen(s);
    if (n == 0 || n > 214) return 0;
    const char *p = s;
    if (*p == '@') {
        p++;
        if (!islower((unsigned char)*p) && !isdigit((unsigned char)*p)) return 0;
        while (*p && *p != '/') {
            if (!islower((unsigned char)*p) && !isdigit((unsigned char)*p) && !strchr("._-", *p)) return 0;
            p++;
        }
        if (*p != '/') return 0;
        p++;
    }
    if (!islower((unsigned char)*p) && !isdigit((unsigned char)*p)) return 0;
    for (; *p; p++)
        if (!islower((unsigned char)*p) && !isdigit((unsigned char)*p) && !strchr("._-", *p)) return 0;
    return 1;
}

static int validModule(const char *s) {
    size_t n = strlen(s);
    if (n == 0 || n > 64 || !isupper((unsigned char)s[0])) return 0;
    for (const char *p = s; *p; p++)
        if (!isalnum((unsigned char)*p)) return 0;
    return 1;
}

static int validVersion(const char *s) {
    /* MAJOR.MINOR.PATCH, optionally -PRERELEASE of [0-9A-Za-z.-]. */
    int dots = 0;
    const char *p = s;
    for (int part = 0; part < 3; part++) {
        if (!isdigit((unsigned char)*p)) return 0;
        if (*p == '0' && isdigit((unsigned char)p[1])) return 0;
        while (isdigit((unsigned char)*p)) p++;
        if (part < 2) {
            if (*p != '.') return 0;
            p++;
            dots++;
        }
    }
    if (*p == '-') {
        p++;
        if (!*p) return 0;
        for (; *p; p++)
            if (!isalnum((unsigned char)*p) && *p != '.' && *p != '-') return 0;
    }
    return *p == 0 && dots == 2;
}

static void usage(const char *message) {
    die(2, "RN-USAGE", NULL,
        "%s; usage: botlish tool -out DIR -artifact LIB.manifest.json -target android-aarch64 react-native generate "
        "[-name NPM-NAME] [-module MODULE] [-version V] [-react-native M.m] [-android-api N] [-license SPDX] [-replace]",
        message);
}

static options parseOptions(int argc, char **argv, const library *lib) {
    options o = {0};
    o.rn = -1;
    o.api = 0;
    const char *rn = "0.88";
    if (argc < 2) usage("no command");
    if (strcmp(argv[1], "generate")) usage(xprintf("unknown command \"%s\"", argv[1]));
    for (int i = 2; i < argc; i++) {
        const char *a = argv[i];
        if (!strcmp(a, "-replace")) {
            o.replace = 1;
            continue;
        }
        if (i + 1 >= argc) usage(xprintf("%s needs a value", a));
        const char *v = argv[++i];
        if (!strcmp(a, "-name")) o.npm = xstrdup(v);
        else if (!strcmp(a, "-module")) o.module = xstrdup(v);
        else if (!strcmp(a, "-version")) o.version = xstrdup(v);
        else if (!strcmp(a, "-license")) o.license = xstrdup(v);
        else if (!strcmp(a, "-react-native")) rn = v;
        else if (!strcmp(a, "-android-api")) {
            char *end;
            o.api = strtoll(v, &end, 10);
            if (*end || o.api <= 0) usage(xprintf("-android-api %s is no API level", v));
        } else usage(xprintf("unknown option \"%s\"", a));
    }
    for (size_t r = 0; r < sizeof reactNatives / sizeof *reactNatives; r++) {
        size_t n = strlen(reactNatives[r].minor);
        if (!strncmp(rn, reactNatives[r].minor, n) && (rn[n] == 0 || (rn[n] == '.' && validVersion(rn))))
            o.rn = (int)r;
    }
    if (o.rn < 0) {
        text known = {0};
        for (size_t r = 0; r < sizeof reactNatives / sizeof *reactNatives; r++) printf_(&known, "%s%s", r ? ", " : "", reactNatives[r].minor);
        die(1, "RN-REACT-NATIVE", NULL, "React Native %s is no version this generator generates for (it knows %s): its C++ module interface and autolinking are checked per minor version",
            rn, known.s);
    }
    if (!o.npm) {
        o.npm = xprintf("react-native-botlish-%s", lib->library);
        for (char *c = o.npm; *c; c++)
            if (*c == '_') *c = '-';
    }
    if (!validNpm(o.npm)) die(1, "RN-NAME", NULL, "\"%s\" is no npm package name (lowercase, digits, . _ -, an optional @scope/)", o.npm);
    if (!o.module) {
        char *p = pascal(lib->library);
        o.module = xprintf("Botlish%s", p);
        free(p);
    }
    if (!validModule(o.module))
        die(1, "RN-NAME", NULL, "\"%s\" is no module name (an uppercase letter, then letters and digits; at most 64)", o.module);
    if (!o.version) o.version = xstrdup("0.1.0");
    if (!validVersion(o.version)) die(1, "RN-NAME", NULL, "\"%s\" is no semantic version", o.version);
    if (!o.license) o.license = xstrdup("UNLICENSED");
    for (const char *c = o.license; *c; c++)
        if (!isalnum((unsigned char)*c) && !strchr(".-+ ()", *c)) die(1, "RN-NAME", NULL, "\"%s\" is no SPDX license expression", o.license);
    long long floor = reactNatives[o.rn].minimumApi > lib->minimumApi ? reactNatives[o.rn].minimumApi : lib->minimumApi;
    if (o.api && o.api < floor)
        die(1, "RN-ANDROID-API", NULL, "-android-api %lld is below the floor %lld (React Native %s's %d, the library's %lld)", o.api,
            floor, reactNatives[o.rn].minor, reactNatives[o.rn].minimumApi, lib->minimumApi);
    if (!o.api) o.api = floor;
    return o;
}

/* --------------------------------------------------------------- the output */

static int isDirectory(const char *path) {
    struct stat s;
    return stat(path, &s) == 0 && S_ISDIR(s.st_mode);
}

static int emptyDirectory(const char *path) {
    DIR *d = opendir(path);
    if (!d) return 1;
    struct dirent *e;
    int empty = 1;
    while ((e = readdir(d)) != NULL)
        if (strcmp(e->d_name, ".") && strcmp(e->d_name, "..")) empty = 0;
    closedir(d);
    return empty;
}

/* The output directory, made ready: empty, or holding only a package this
 * generator made (with -replace), whose files are removed. Anything else
 * there is someone's, and refused. */
static void prepareOutput(const char *out, int replace) {
    if (strstr(out, "/.bot_modules/") || (strlen(out) >= 13 && !strcmp(out + strlen(out) - 13, "/.bot_modules")))
        die(1, "RN-OUTPUT", out, "lies inside a .bot_modules directory, the installed packages, which no tool writes");
    if (!isDirectory(out)) mkdirs(out);
    if (!isDirectory(out)) die(1, "RN-OUTPUT", out, "is no directory");
    if (emptyDirectory(out)) return;
    char *marker = xprintf("%s/botlish-react-native.json", out);
    if (access(marker, F_OK) != 0)
        die(1, "RN-OUTPUT", out, "is not empty and holds no package this generator made: choose an empty directory");
    if (!replace)
        die(1, "RN-OUTPUT", out, "holds a package this generator made: pass -replace to generate it again");
    jval *previous = readJson(marker, "the previous package's record", "RN-OUTPUT");
    jval *files = json_get(previous, "files");
    if (!files || files->kind != J_ARR) die(1, "RN-OUTPUT", marker, "the record lists no files");
    for (size_t i = 0; i < files->count; i++) {
        const char *f = files->items[i]->kind == J_STR ? files->items[i]->text : NULL;
        if (!f || f[0] == '/' || strstr(f, "..") || strstr(f, "//"))
            die(1, "RN-OUTPUT", marker, "the record names a file outside the package");
        char *p = xprintf("%s/%s", out, f);
        unlink(p);
        free(p);
    }
    unlink(marker);
    static const char *dirs[] = {"native/android/arm64-v8a", "native/android", "native", "src", "cpp", "include", "android", "botlish"};
    for (size_t i = 0; i < sizeof dirs / sizeof *dirs; i++) {
        char *p = xprintf("%s/%s", out, dirs[i]);
        rmdir(p);
        free(p);
    }
    if (!emptyDirectory(out))
        die(1, "RN-OUTPUT", out, "holds files the previous package's record does not name: they are someone's; remove them or choose another directory");
}

static const char *tsType(btype t) {
    switch (t) {
    case B_INT: case B_FLOAT64: return "number";
    case B_BOOL: return "boolean";
    case B_STR: return "string";
    default: return "void";
    }
}

/* The C++ type of a Core method's parameter or result. */
static const char *coreType(btype t, int result) {
    switch (t) {
    case B_INT: case B_FLOAT64: return "double";
    case B_BOOL: return "bool";
    case B_STR: return result ? "std::string" : "const std::string &";
    default: return "void";
    }
}

/* The C++ type of a TurboModule method's parameter or result (Codegen's
 * bridging converts JSI values to and from them). */
static const char *moduleType(btype t, int result) {
    switch (t) {
    case B_INT: case B_FLOAT64: return "double";
    case B_BOOL: return "bool";
    case B_STR: return result ? "jsi::String" : "jsi::String";
    default: return "void";
    }
}

static void comment(text *t, const char *s) {
    for (; *s; s++) {
        if (s[0] == '*' && s[1] == '/') puts_(t, "* /");
        else put(t, s, 1);
    }
}

int main(int argc, char **argv) {
    request r = openRequest();
    library lib = openLibrary(r.manifest, r.target);
    options o = parseOptions(argc, argv, &lib);
    size_t headerLen;
    char *headerFile = xprintf("%s/%s", lib.dir, lib.headerName);
    char *header = readFile(headerFile, &headerLen);
    if (!header) die(1, "RN-ARTIFACT", headerFile, "cannot read the header");
    checkHeader(&lib, header);
    char *sharedFile = xprintf("%s/%s", lib.dir, lib.sharedName);
    checkShared(&lib, sharedFile);
    prepareOutput(r.output, o.replace);

    const char *L = lib.library;
    const char *M = o.module;
    char *lower = xstrdup(M);
    for (char *c = lower; *c; c++) *c = (char)tolower((unsigned char)*c);
    char *core = xprintf("%sCore", M);
    char *spec = xprintf("%sSpec", M);
    char *ns = xprintf("botlish_rn_%s", lower);
    char *cmake = xprintf("botlish_rn_%s", lower);
    char *imported = xprintf("botlish_library_%s", L);
    char *javaPackage = xprintf("org.botlish.rn.%s", lower);
    char *minApi = xprintf("%lld", o.api);
    char *libraryApi = xprintf("%lld", lib.minimumApi);
    const char *rnMinor = reactNatives[o.rn].minor;
    bind("LIBRARY", L);
    bind("PREFIX", L);
    bind("MODULE", M);
    bind("CORE", core);
    bind("SPEC", spec);
    bind("NAMESPACE", ns);
    bind("CMAKE_TARGET", cmake);
    bind("IMPORTED_TARGET", imported);
    bind("HEADER", lib.headerName);
    bind("TOOL_VERSION", TOOL_VERSION);
    bind("MANIFEST_SHA", lib.shaManifest);
    bind("SHARED_SHA", lib.shaShared);
    bind("RUNTIME_ABI", lib.runtimeAbi);
    bind("TARGET", lib.target);
    bind("TRIPLE", lib.triple);
    bind("NPM_NAME", o.npm);
    bind("NPM_VERSION", o.version);
    bind("MIN_API", minApi);
    bind("LIBRARY_API", libraryApi);
    bind("RN_MAJOR_MINOR", rnMinor);
    bind("RN_RANGE", reactNatives[o.rn].range);
    bind("RN_TESTED", reactNatives[o.rn].tested);

    /* Per export: the spec's methods, the entry point's wrappers, the
     * Core's and the Module's declarations and definitions. */
    text methods = {0}, wrappers = {0}, errors = {0}, coreDecls = {0}, coreDefs = {0}, moduleDecls = {0}, moduleDefs = {0}, api = {0};
    for (size_t e = 0; e < lib.nexports; e++) {
        const export_ *x = &lib.exports[e];
        /* Spec. */
        puts_(&methods, "  /** ");
        comment(&methods, x->botlish);
        printf_(&methods, " */\n  %s(", x->js);
        for (size_t p = 0; p < x->nparams; p++) printf_(&methods, "%s%s: %s", p ? ", " : "", x->params[p].js, tsType(x->params[p].type));
        printf_(&methods, "): %s;\n", tsType(x->result));
        /* Declared errors. */
        printf_(&errors, "  %s: [", x->js);
        for (size_t k = 0; k < x->nerrors; k++) {
            if (k) puts_(&errors, ", ");
            json_text(&errors, x->errors[k]);
        }
        puts_(&errors, "],\n");
        /* Wrapper. */
        puts_(&wrappers, "/** Botlish `");
        comment(&wrappers, x->botlish);
        puts_(&wrappers, "`");
        if (x->nerrors) {
            puts_(&wrappers, ". Throws a BotlishError whose identity is ");
            for (size_t k = 0; k < x->nerrors; k++) printf_(&wrappers, "%s%s", k ? (k + 1 == x->nerrors ? " or " : ", ") : "", x->errors[k]);
            puts_(&wrappers, " when the library declares one");
        }
        puts_(&wrappers, ". */\n");
        printf_(&wrappers, "export function %s(", x->js);
        for (size_t p = 0; p < x->nparams; p++) printf_(&wrappers, "%s%s: %s", p ? ", " : "", x->params[p].js, tsType(x->params[p].type));
        printf_(&wrappers, "): %s {\n  check_count('%s', arguments.length, %zu);\n", tsType(x->result), x->js, x->nparams);
        for (size_t p = 0; p < x->nparams; p++) {
            const char *check = x->params[p].type == B_INT ? "check_int" : x->params[p].type == B_FLOAT64 ? "check_float64" : x->params[p].type == B_BOOL ? "check_bool" : "check_str";
            printf_(&wrappers, "  %s('%s', %zu, '%s', %s);\n", check, x->js, p, x->params[p].js, x->params[p].js);
        }
        printf_(&wrappers, "  try {\n    %snative_module('%s').%s(", x->result == B_UNIT ? "" : "return ", x->js, x->js);
        for (size_t p = 0; p < x->nparams; p++) printf_(&wrappers, "%s%s", p ? ", " : "", x->params[p].js);
        puts_(&wrappers, ");\n  } catch (e) {\n    rethrow_native(e);\n  }\n}\n\n");
        /* README's API line. */
        printf_(&api, "* `%s(", x->js);
        for (size_t p = 0; p < x->nparams; p++) printf_(&api, "%s%s: %s", p ? ", " : "", x->params[p].js, tsType(x->params[p].type));
        printf_(&api, "): %s` -- Botlish `%s`\n", tsType(x->result), x->botlish);
        /* Core. */
        printf_(&coreDecls, "  // %s\n  %s %s(", x->botlish, coreType(x->result, 1), x->js);
        printf_(&coreDefs, "%s %s::%s(", coreType(x->result, 1), core, x->js);
        for (size_t p = 0; p < x->nparams; p++) {
            const char *ct = coreType(x->params[p].type, 0);
            const char *gap = ct[strlen(ct) - 1] == '&' ? "" : " ";
            printf_(&coreDecls, "%s%s%sa%zu", p ? ", " : "", ct, gap, p);
            printf_(&coreDefs, "%s%s%sa%zu", p ? ", " : "", ct, gap, p);
        }
        puts_(&coreDecls, ");\n");
        printf_(&coreDefs, ") {\n  const char *method = \"%s\";\n", x->js);
        for (size_t p = 0; p < x->nparams; p++) {
            if (x->params[p].type == B_INT)
                printf_(&coreDefs, "  int64_t c%zu = intArgument(method, %zu, \"%s\", a%zu);\n", p, p, x->params[p].js, p);
            else if (x->params[p].type == B_FLOAT64)
                printf_(&coreDefs, "  double c%zu = floatArgument(method, %zu, \"%s\", a%zu);\n", p, p, x->params[p].js, p);
        }
        puts_(&coreDefs, "  Call call(*this, method);\n");
        switch (x->result) {
        case B_INT: puts_(&coreDefs, "  int64_t out = 0;\n"); break;
        case B_BOOL: puts_(&coreDefs, "  bool out = false;\n"); break;
        case B_FLOAT64: puts_(&coreDefs, "  double out = 0;\n"); break;
        case B_STR: puts_(&coreDefs, "  OwnedBytes out;\n"); break;
        default: break;
        }
        printf_(&coreDefs, "  OwnedError error;\n  int32_t status = call.run([&] { return %s(call.instance", x->symbol);
        for (size_t p = 0; p < x->nparams; p++) {
            switch (x->params[p].type) {
            case B_INT: case B_FLOAT64: printf_(&coreDefs, ", c%zu", p); break;
            case B_BOOL: printf_(&coreDefs, ", a%zu", p); break;
            case B_STR: printf_(&coreDefs, ", bytesOf(a%zu), a%zu.size()", p, p); break;
            default: break;
            }
        }
        if (x->result == B_STR) puts_(&coreDefs, ", &out.value");
        else if (x->result != B_UNIT) puts_(&coreDefs, ", &out");
        printf_(&coreDefs, ", &error.value); });\n  if (status != %s_STATUS_OK) {\n    if (error.value != nullptr) totals().errorsAcquired++;\n    throw failureOf(method, status, error.value);\n  }\n", L);
        switch (x->result) {
        case B_INT: puts_(&coreDefs, "  return intResult(method, out);\n"); break;
        case B_BOOL: case B_FLOAT64: puts_(&coreDefs, "  return out;\n"); break;
        case B_STR: puts_(&coreDefs, "  out.take();\n  return text(out.value.ptr, out.value.len);\n"); break;
        default: break;
        }
        puts_(&coreDefs, "}\n\n");
        /* Module. */
        printf_(&moduleDecls, "  %s %s(jsi::Runtime &rt", moduleType(x->result, 1), x->js);
        printf_(&moduleDefs, "%s %sModule::%s(jsi::Runtime &rt", moduleType(x->result, 1), M, x->js);
        for (size_t p = 0; p < x->nparams; p++) {
            printf_(&moduleDecls, ", %s a%zu", moduleType(x->params[p].type, 0), p);
            printf_(&moduleDefs, ", %s a%zu", moduleType(x->params[p].type, 0), p);
        }
        puts_(&moduleDecls, ");\n");
        puts_(&moduleDefs, ") {\n  try {\n    ");
        if (x->result == B_STR) puts_(&moduleDefs, "return utf8(rt, ");
        else if (x->result != B_UNIT) puts_(&moduleDefs, "return ");
        printf_(&moduleDefs, "core_.%s(", x->js);
        for (size_t p = 0; p < x->nparams; p++) {
            if (x->params[p].type == B_STR) printf_(&moduleDefs, "%sa%zu.utf8(rt)", p ? ", " : "", p);
            else printf_(&moduleDefs, "%sa%zu", p ? ", " : "", p);
        }
        printf_(&moduleDefs, ")%s;\n  } catch (const %s::Failure &f) {\n    raise(rt, f);\n  }\n}\n\n", x->result == B_STR ? ")" : "", ns);
    }
    /* Trim the last blank lines of generated sections. */
    while (coreDefs.len && coreDefs.s[coreDefs.len - 1] == '\n') coreDefs.s[--coreDefs.len] = 0;
    while (moduleDefs.len && moduleDefs.s[moduleDefs.len - 1] == '\n') moduleDefs.s[--moduleDefs.len] = 0;
    while (wrappers.len && wrappers.s[wrappers.len - 1] == '\n') wrappers.s[--wrappers.len] = 0;
    while (methods.len && methods.s[methods.len - 1] == '\n') methods.s[--methods.len] = 0;
    while (coreDecls.len && coreDecls.s[coreDecls.len - 1] == '\n') coreDecls.s[--coreDecls.len] = 0;
    while (moduleDecls.len && moduleDecls.s[moduleDecls.len - 1] == '\n') moduleDecls.s[--moduleDecls.len] = 0;
    while (errors.len && errors.s[errors.len - 1] == '\n') errors.s[--errors.len] = 0;
    while (api.len && api.s[api.len - 1] == '\n') api.s[--api.len] = 0;
    bind("METHODS", methods.s);
    bind("WRAPPERS", wrappers.s);
    bind("ERRORS", errors.s ? errors.s : "");
    bind("CORE_DECLS", coreDecls.s);
    bind("CORE_DEFS", coreDefs.s);
    bind("MODULE_DECLS", moduleDecls.s);
    bind("MODULE_DEFS", moduleDefs.s);
    bind("API", api.s);

    const char *out = r.output;
    text t;
    /* package.json */
    t = (text){0};
    puts_(&t, "{\n  \"name\": ");
    json_text(&t, o.npm);
    puts_(&t, ",\n  \"version\": ");
    json_text(&t, o.version);
    char *description = xprintf("The Botlish native library \"%s\" as a React Native Pure C++ TurboModule (%s), Android arm64-v8a", L, M);
    puts_(&t, ",\n  \"description\": ");
    json_text(&t, description);
    puts_(&t, ",\n  \"license\": ");
    json_text(&t, o.license);
    puts_(&t, ",\n  \"main\": \"src/index.ts\",\n  \"types\": \"src/index.ts\",\n  \"react-native\": \"src/index.ts\",\n  \"source\": \"src/index.ts\",\n");
    puts_(&t, "  \"files\": [\n    \"src\",\n    \"cpp\",\n    \"include\",\n    \"android\",\n    \"native\",\n    \"botlish\",\n    \"react-native.config.js\",\n    \"botlish-react-native.json\",\n    \"README.md\"\n  ],\n");
    printf_(&t, "  \"peerDependencies\": {\n    \"react-native\": \"%s\"\n  },\n", reactNatives[o.rn].range);
    printf_(&t, "  \"codegenConfig\": {\n    \"name\": \"%s\",\n    \"type\": \"modules\",\n    \"jsSrcsDir\": \"src\",\n    \"android\": {\n      \"javaPackageName\": \"%s\"\n    },\n    \"includesGeneratedCode\": false\n  },\n", spec, javaPackage);
    printf_(&t, "  \"botlish\": {\n    \"generator\": \"%s %s\",\n    \"library\": \"%s\",\n    \"target\": \"%s\",\n    \"platforms\": {\n      \"android\": {\n        \"abis\": [\n          \"arm64-v8a\"\n        ],\n        \"minimumApi\": %lld\n      },\n      \"ios\": null\n    }\n  }\n}\n",
        TOOL_NAME, TOOL_VERSION, L, lib.target, o.api);
    writeText(out, "package.json", &t);

    t = expand(tpl_react_native_config_js);
    writeText(out, "react-native.config.js", &t);
    char *name;
    t = expand(tpl_Native_ts);
    name = xprintf("src/Native%s.ts", M);
    writeText(out, name, &t);
    t = expand(tpl_index_ts);
    writeText(out, "src/index.ts", &t);
    t = expand(tpl_Core_h);
    name = xprintf("cpp/%s.h", core);
    writeText(out, name, &t);
    t = expand(tpl_Core_cpp);
    name = xprintf("cpp/%s.cpp", core);
    writeText(out, name, &t);
    t = expand(tpl_Module_h);
    name = xprintf("cpp/%sModule.h", M);
    writeText(out, name, &t);
    t = expand(tpl_Module_cpp);
    name = xprintf("cpp/%sModule.cpp", M);
    writeText(out, name, &t);
    t = expand(tpl_CMakeLists_txt);
    writeText(out, "android/CMakeLists.txt", &t);
    t = expand(tpl_README_md);
    writeText(out, "README.md", &t);
    /* The library, its header and its manifest, unchanged. */
    name = xprintf("include/%s", lib.headerName);
    writeFile(out, name, header, headerLen);
    size_t len;
    char *data = readFile(sharedFile, &len);
    if (!data) die(1, "RN-ARTIFACT", sharedFile, "cannot read the shared library");
    char hex[65];
    sha256_ctx c;
    sha256_init(&c);
    sha256_update(&c, data, len);
    sha256_hex(&c, hex);
    if (strcmp(hex, lib.shaShared)) die(1, "RN-ARTIFACT", sharedFile, "changed while it was being packaged");
    name = xprintf("native/android/arm64-v8a/%s", lib.sharedName);
    writeFile(out, name, data, len);
    free(data);
    data = readFile(lib.path, &len);
    if (!data) die(1, "RN-ARTIFACT", lib.path, "cannot read the manifest");
    name = xprintf("botlish/%s.manifest.json", L);
    writeFile(out, name, data, len);
    free(data);

    /* The record: what the package was generated from and for, and its
     * files (what -replace removes). */
    t = (text){0};
    printf_(&t, "{\n  \"schema\": 1,\n  \"kind\": \"botlish-react-native-package\",\n  \"generator\": {\n    \"name\": \"%s\",\n    \"version\": \"%s\",\n    \"protocol\": 1\n  },\n", TOOL_NAME, TOOL_VERSION);
    puts_(&t, "  \"package\": {\n    \"name\": ");
    json_text(&t, o.npm);
    puts_(&t, ",\n    \"version\": ");
    json_text(&t, o.version);
    printf_(&t, ",\n    \"module\": \"%s\",\n    \"spec\": \"%s\",\n    \"cxxModule\": \"%sModule\",\n    \"cmakeTarget\": \"%s\"\n  },\n", M, spec, M, cmake);
    printf_(&t, "  \"library\": {\n    \"name\": \"%s\",\n    \"manifestSchema\": 2,\n    \"abi\": 1,\n    \"target\": \"%s\",\n    \"triple\": \"%s\",\n    \"frontEnd\": \"%s\",\n    \"runtimeAbi\": \"%s\",\n    \"targetSupport\": \"%s\",\n    \"toolchain\": \"%s %s\",\n",
        L, lib.target, lib.triple, lib.frontEnd, lib.runtimeAbi, lib.supportPackage, lib.toolchain, lib.toolchainRevision);
    printf_(&t, "    \"sha256\": {\n      \"manifest\": \"%s\",\n      \"shared\": \"%s\",\n      \"header\": \"%s\",\n      \"static\": \"%s\"\n    },\n    \"exports\": [", lib.shaManifest, lib.shaShared, lib.shaHeader, lib.shaStatic);
    for (size_t e = 0; e < lib.nexports; e++) printf_(&t, "%s\n      \"%s\"", e ? "," : "", lib.exports[e].name);
    puts_(&t, "\n    ]\n  },\n");
    printf_(&t, "  \"reactNative\": {\n    \"range\": \"%s\",\n    \"tested\": \"%s\",\n    \"architecture\": \"new\",\n    \"engine\": \"hermes\",\n    \"module\": \"pure-cxx-turbomodule\",\n    \"codegen\": \"app\"\n  },\n",
        reactNatives[o.rn].range, reactNatives[o.rn].tested);
    printf_(&t, "  \"android\": {\n    \"abis\": [\n      \"arm64-v8a\"\n    ],\n    \"minimumApi\": {\n      \"library\": %lld,\n      \"reactNative\": %d,\n      \"package\": %lld\n    },\n    \"pageSize\": 16384\n  },\n",
        lib.minimumApi, reactNatives[o.rn].minimumApi, o.api);
    puts_(&t, "  \"ios\": null,\n  \"files\": [");
    for (int i = 0; i < nwritten; i++) printf_(&t, "%s\n    \"%s\"", i ? "," : "", written[i]);
    puts_(&t, "\n  ]\n}\n");
    writeText(out, "botlish-react-native.json", &t);
    printf("react-native: generated %s %s (module %s, %zu functions) from %s\n", o.npm, o.version, M, lib.nexports, lib.library);
    finish();
    return 0;
}
