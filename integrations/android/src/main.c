/* main.c -- botlish-android, the `android` tool of the package
 * botlish_android (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md):
 * from one Botlish application library -- its manifest (schema 3: a
 * host-startable entry, NAME_main), header and Android AArch64 shared
 * object -- and the SDL3 package's Android view installed in the project,
 * an Android Gradle project whose SDLActivity starts the application.
 *
 *   botlish tool -out DIR -artifact LIB.manifest.json -target android-aarch64 \
 *       android generate [-application-id ID] [-name NAME] [-activity CLASS]
 *       [-version-code N] [-version-name V] [-android-api N] [-sdl3 PACKAGE]
 *       [-packaging uncompressed|extracted] [-assets DIR] [-intent-arguments]
 *       [-replace]
 *   botlish tool -out DIR -artifact LIB.manifest.json -target android-aarch64 \
 *       android build [-task assembleRelease|assembleDebug]
 *
 * It speaks tool protocol 1 (BOTLISH-TOOLS.md) and knows Botlish through the
 * request, the manifest and the installed sdl3 package's files only: no
 * HIR, no source, no compiler internals, no file of a checkout. Every fact
 * it relies on is checked first -- the manifest's schema, target, C ABI
 * version, application entry and its contract, native dependencies and
 * runtime ABI; every artifact's SHA-256; the shared object's ELF (AArch64,
 * ET_DYN, 16 KiB segments, its SONAME, Android's platform libraries and
 * SDL3 only, NAME_main exported); the SDL3 package's Android descriptor,
 * each of its files' SHA-256, its libSDL3.so (AArch64, 16 KiB, SONAME
 * libSDL3.so, SDL's revision of the stated version) and its binding's
 * version -- and a fact it cannot read completely is refused, never
 * guessed at. Nothing about any one application is built in: names come
 * from the manifest and the options.
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
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define TOOL_NAME "botlish-android"
#define TOOL_VERSION "0.1.0"

/* The Android build this tool generates for: the Android Gradle Plugin,
 * Gradle (its distribution pinned by SHA-256), the platform compiled
 * against and targeted, and CMake. One row: a combination not listed here
 * is not generated. SDL 3.4.18's own android-project uses the same plugin
 * and Gradle. */
static const struct {
    const char *agp;
    const char *gradle;
    const char *gradleSha256;
    int compileSdk;
    int targetSdk;
    const char *cmake;
} build = {"8.7.3", "8.12", "7a00d51fb93147819aab76024feece20b6b84e420694101f276be952e08bef03", 35, 35, "3.22.1"};

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
    fprintf(stderr, "android: %s: %s%s%s (%s)\n", severity, file ? file : "", file ? ": " : "", message, code);
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
 * invocation). Nothing of a project is left half-written: generation
 * checks every input before its first write. */
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
        fputs("android: out of memory\n", stderr);
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

#define MAX_BINDINGS 64
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

/* TEMPLATE with every @KEY@ replaced by its binding (a key: uppercase
 * letters, digits after the first, and _). A key without a binding is a
 * defect of this tool. */
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
        if (*end >= 'A' && *end <= 'Z')
            while ((*end >= 'A' && *end <= 'Z') || (*end >= '0' && *end <= '9') || *end == '_') end++;
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
                fprintf(stderr, "android: internal: template key @%.*s@ has no value\n", (int)n, at + 1);
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

static int isDirectory(const char *path) {
    struct stat s;
    return stat(path, &s) == 0 && S_ISDIR(s.st_mode);
}

static int isRegular(const char *path) {
    struct stat s;
    return lstat(path, &s) == 0 && S_ISREG(s.st_mode);
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
#define MAX_WRITTEN 4096
static char *written[MAX_WRITTEN];
static int nwritten = 0;

static void writeFile(const char *dir, const char *name, const char *data, size_t len, mode_t mode) {
    char *path = xprintf("%s/%s", dir, name);
    char *slash = strrchr(path, '/');
    *slash = 0;
    mkdirs(path);
    *slash = '/';
    unlink(path);
    FILE *f = fopen(path, "wb");
    if (!f || fwrite(data, 1, len, f) != len || fclose(f) != 0)
        die(1, "AN-WRITE", path, "cannot write: %s", strerror(errno));
    if (chmod(path, mode) != 0) die(1, "AN-WRITE", path, "cannot set its mode: %s", strerror(errno));
    free(path);
    if (nwritten == MAX_WRITTEN) die(1, "AN-WRITE", dir, "more than %d files", MAX_WRITTEN);
    written[nwritten++] = xstrdup(name);
}

static void writeText(const char *dir, const char *name, const text *t) {
    writeFile(dir, name, t->s ? t->s : "", t->len, 0644);
}

/* Copies the file FROM (its bytes, never a link) to NAME in DIR. */
static void copyFile(const char *from, const char *dir, const char *name, mode_t mode) {
    size_t len;
    if (!isRegular(from)) die(1, "AN-INPUT", from, "is no regular file");
    char *data = readFile(from, &len);
    if (!data) die(1, "AN-INPUT", from, "cannot read: %s", strerror(errno));
    writeFile(dir, name, data, len, mode);
    free(data);
}

/* ---------------------------------------------------------------- request */

typedef struct {
    const char *path;
    const char *output;
    const char *target;
    const char *host;
    const char *project;
    const char *manifest;
} request;

static request openRequest(void) {
    request r = {0};
    r.path = getenv("BOTLISH_TOOL_REQUEST");
    if (!r.path || !*r.path) {
        fprintf(stderr, "android: no BOTLISH_TOOL_REQUEST: this is a Botlish tool, run as `botlish tool -out DIR "
                        "-artifact LIB.manifest.json -target android-aarch64 android generate` (BOTLISH-TOOLS.md)\n");
        exit(64);
    }
    jval *root = readJson(r.path, "the request", "AN-REQUEST");
    const char *diag = json_str(root, "diagnostics");
    if (diag) diagnosticsPath = diag;
    long long protocol;
    if (!json_int(root, "protocol", &protocol) || protocol != 1)
        die(2, "AN-REQUEST", r.path, "this tool speaks tool protocol 1, and the request is no protocol 1 request");
    const char *kind = json_str(root, "kind");
    if (!kind || strcmp(kind, "botlish-tool-request"))
        die(2, "AN-REQUEST", r.path, "the request's kind is not botlish-tool-request");
    r.output = json_str(root, "output");
    r.target = json_str(root, "target");
    r.host = json_str(root, "host");
    r.project = json_str(root, "project");
    jval *artifacts = json_get(root, "artifacts");
    if (!r.output || !r.target || !r.host || !r.project || !artifacts || artifacts->kind != J_ARR)
        die(2, "AN-REQUEST", r.path, "the request lacks output, target, host, project or artifacts");
    for (size_t i = 0; i < artifacts->count; i++) {
        const char *k = json_str(artifacts->items[i], "kind");
        if (k && !strcmp(k, "native-library")) {
            if (r.manifest) die(2, "AN-REQUEST", r.path, "two native-library artifacts: a project starts one application library");
            r.manifest = json_str(artifacts->items[i], "manifest");
        }
    }
    if (!r.manifest)
        die(2, "AN-REQUEST", r.path, "no native-library artifact: run `botlish tool -artifact LIB.manifest.json ...`");
    return r;
}

/* ------------------------------------------------------------ the library */

typedef struct {
    char *path, *dir;
    char *library, *target, *triple, *runtimeAbi;
    char *supportPackage, *toolchain, *toolchainRevision;
    long long minimumApi;
    char *staticName, *sharedName, *headerName;
    char *shaStatic, *shaShared, *shaHeader, *shaManifest;
    char *symbol;
    int needsSdl;
} library;

static const char *need(const jval *object, const char *key, const char *path, const char *what) {
    const char *s = json_str(object, key);
    if (!s) die(1, "AN-MANIFEST", path, "%s has no string \"%s\"", what, key);
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

/* Android's platform libraries an application library may need: on every
 * device of its API level, never bundled (the NDK's stable APIs). */
static const char *const platformLibraries[] = {"c", "m", "dl", "log", "android", "z", "EGL", "GLESv1_CM", "GLESv2",
    "GLESv3", "OpenSLES", "aaudio", "vulkan", "jnigraphics", "mediandk", "nativewindow"};

static int platformLibrary(const char *name) {
    for (size_t i = 0; i < sizeof platformLibraries / sizeof *platformLibraries; i++)
        if (!strcmp(platformLibraries[i], name)) return 1;
    return 0;
}

/* Reads the manifest PATH completely: a schema 3 application library for
 * android-aarch64, every fact this tool relies on checked. */
static library openLibrary(const char *path, const char *target) {
    library lib = {0};
    jval *m = readJson(path, "the native library manifest", "AN-MANIFEST");
    lib.path = xstrdup(path);
    lib.dir = xstrdup(path);
    char *slash = strrchr(lib.dir, '/');
    if (slash) *slash = 0;
    else strcpy(lib.dir, ".");
    char hex[65];
    if (!sha256_file(path, hex)) die(1, "AN-MANIFEST", path, "cannot read the manifest");
    lib.shaManifest = xstrdup(hex);

    if (!matches(json_str(m, "kind"), "botlish-native-library"))
        die(1, "AN-MANIFEST", path, "not a native library manifest (kind botlish-native-library)");
    long long schema = 0;
    json_int(m, "schema", &schema);
    if (schema == 2 || (schema == 3 && !json_get(m, "application")))
        die(1, "AN-NOT-APPLICATION", path, "an ordinary native library (schema %lld) has no host-startable entry: an Android application is an application library -- build its entry program with -emit-native-library NAME -application", schema);
    if (schema != 3)
        die(1, "AN-MANIFEST", path, "a native library manifest of schema %lld: this generator reads the application manifest, schema 3", schema);
    lib.library = xstrdup(need(m, "library", path, "the manifest"));
    if (!isIdentifier(lib.library))
        die(1, "AN-MANIFEST", path, "the library name \"%s\" is no C identifier of lowercase letters, digits and _", lib.library);
    const char *L = lib.library;
    if (!strcmp(L, "main") || !strcmp(L, "sdl3") || !strcmp(L, "c") || !strcmp(L, "m") || !strcmp(L, "dl") || !strcmp(L, "log"))
        die(1, "AN-NAME", path, "the library name \"%s\" is the name of a library the application loads beside it (libmain.so, libSDL3.so or a platform library)", L);
    long long abi = 0;
    if (!json_int(m, "abi", &abi) || abi != 1)
        die(1, "AN-UNSUPPORTED", path, "the library's C ABI version is %lld: this generator knows version 1", abi);

    jval *t = json_get(m, "target");
    lib.target = xstrdup(need(t, "name", path, "target"));
    lib.triple = xstrdup(need(t, "triple", path, "target"));
    if (strcmp(lib.target, "android-aarch64") || strcmp(lib.triple, "aarch64-linux-android"))
        die(1, "AN-TARGET", path, "the library is built for %s (%s); an Android application needs an android-aarch64 (aarch64-linux-android) library: build it with -target android-aarch64 -target-support PACKAGE",
            lib.target, lib.triple);
    if (strcmp(target, lib.target))
        die(1, "AN-TARGET", path, "the request's target is %s and the library's %s: run the tool with -target %s", target, lib.target, lib.target);

    jval *compiler = json_get(m, "compiler");
    lib.runtimeAbi = xstrdup(need(compiler, "runtimeAbi", path, "compiler"));
    if (!isHex(lib.runtimeAbi, 16))
        die(1, "AN-RUNTIME-ABI", path, "the runtime ABI \"%s\" is no runtime ABI fingerprint (16 hexadecimal digits)", lib.runtimeAbi);
    jval *support = json_get(m, "targetSupport");
    if (!support || support->kind != J_OBJ)
        die(1, "AN-MANIFEST", path, "the manifest names no target support package: an Android library is linked with one (-target-support)");
    lib.supportPackage = xstrdup(need(support, "package", path, "targetSupport"));
    const char *supportAbi = need(support, "runtimeAbi", path, "targetSupport");
    if (strcmp(supportAbi, lib.runtimeAbi))
        die(1, "AN-RUNTIME-ABI", path, "the library's runtime ABI is %s and its target support package's (%s) %s: the library was linked with a runtime of another ABI",
            lib.runtimeAbi, lib.supportPackage, supportAbi);
    if (!json_int(json_get(support, "platform"), "minimumApi", &lib.minimumApi) || lib.minimumApi < 21)
        die(1, "AN-MANIFEST", path, "targetSupport.platform.minimumApi is no Android API level of at least 21");
    jval *toolchain = json_get(support, "toolchain");
    lib.toolchain = xstrdup(need(toolchain, "name", path, "targetSupport.toolchain"));
    lib.toolchainRevision = xstrdup(need(toolchain, "revision", path, "targetSupport.toolchain"));
    for (const char *c = lib.toolchainRevision; *c; c++)
        if (!isdigit((unsigned char)*c) && *c != '.')
            die(1, "AN-MANIFEST", path, "the toolchain revision \"%s\" is no NDK revision", lib.toolchainRevision);

    /* The application entry and its contract. */
    jval *application = json_get(m, "application");
    lib.symbol = xprintf("%s_main", L);
    char *signature = xprintf("int32_t %s_main(int argc, char **argv, %s_error **error)", L, L);
    if (!matches(json_str(application, "symbol"), lib.symbol) || !matches(json_str(application, "c"), signature))
        die(1, "AN-ENTRY", path, "the application entry is not %s", signature);
    if (!matches(json_str(application, "thread"), "calling") || !matches(json_str(application, "execution"), "blocking-to-completion"))
        die(1, "AN-ENTRY", path, "the application entry's contract is thread \"%s\", execution \"%s\": SDL's bootstrap calls it on SDLThread and waits for it, which this generator knows only for an entry run on the calling thread, blocking, to completion",
            json_str(application, "thread") ? json_str(application, "thread") : "?", json_str(application, "execution") ? json_str(application, "execution") : "?");
    jval *api = json_get(m, "api");
    static const char *used[] = {"main", "error_release", "error_identity", "error_message"};
    for (size_t u = 0; u < sizeof used / sizeof *used; u++) {
        char *want = xprintf("%s_%s", L, used[u]);
        int listed = 0;
        for (size_t a = 0; api && api->kind == J_ARR && a < api->count; a++)
            if (api->items[a]->kind == J_STR && !strcmp(api->items[a]->text, want)) listed = 1;
        if (!listed) die(1, "AN-MANIFEST", path, "the manifest's api does not list %s", want);
        free(want);
    }
    jval *statuses = json_get(m, "statuses");
    long long ok = -1;
    if (!json_int(statuses, "ok", &ok) || ok != 0) die(1, "AN-UNSUPPORTED", path, "the status \"ok\" is not 0");

    /* Native dependencies: Android's platform libraries, and SDL3 (the
     * sdl3 package's libSDL3.so, which the generated project bundles). */
    jval *dependencies = json_get(m, "dependencies");
    if (!dependencies || dependencies->kind != J_ARR) die(1, "AN-MANIFEST", path, "the manifest has no dependencies");
    for (size_t d = 0; d < dependencies->count; d++) {
        jval *dep = dependencies->items[d];
        const char *kind = json_str(dep, "kind"), *name = json_str(dep, "name"), *linkage = json_str(dep, "linkage");
        if (!matches(kind, "library") || !name)
            die(1, "AN-DEPENDENCY", path, "native dependency %zu is a %s, not a library: this generator bundles none", d, kind ? kind : "?");
        if (!strcmp(name, "SDL3")) {
            if (!matches(linkage, "default"))
                die(1, "AN-DEPENDENCY", path, "SDL3 is linked \"%s\": the generated project bundles SDL's shared libSDL3.so", linkage ? linkage : "?");
            lib.needsSdl = 1;
        } else if (!platformLibrary(name) || !matches(linkage, "default")) {
            die(1, "AN-DEPENDENCY", path, "the native dependency \"%s\" (%s) is neither one of Android's platform libraries nor SDL3: this generator bundles SDL3's library only, and a library it does not bundle would be missing on the device",
                name, linkage ? linkage : "?");
        }
    }

    /* The files, bound by their digests. */
    jval *files = json_get(m, "artifacts");
    jval *sha = json_get(m, "sha256");
    lib.staticName = xstrdup(need(files, "static", path, "artifacts"));
    lib.headerName = xstrdup(need(files, "header", path, "artifacts"));
    const char *shared = json_str(files, "shared");
    if (!shared)
        die(1, "AN-ARTIFACT", path, "the library has no shared object: an Android application loads lib%s.so", L);
    lib.sharedName = xstrdup(shared);
    char *expect[3] = {xprintf("lib%s.a", L), xprintf("lib%s.so", L), xprintf("%s.h", L)};
    char *names[3] = {lib.staticName, lib.sharedName, lib.headerName};
    const char *keys[3] = {"static", "shared", "header"};
    char **digests[3] = {&lib.shaStatic, &lib.shaShared, &lib.shaHeader};
    for (int i = 0; i < 3; i++) {
        if (strcmp(names[i], expect[i]))
            die(1, "AN-MANIFEST", path, "artifacts.%s is \"%s\", not %s", keys[i], names[i], expect[i]);
        const char *recorded = json_str(sha, keys[i]);
        if (!isHex(recorded, 64)) die(1, "AN-MANIFEST", path, "sha256.%s is no SHA-256", keys[i]);
        char *file = xprintf("%s/%s", lib.dir, names[i]);
        if (!sha256_file(file, hex))
            die(1, "AN-ARTIFACT", file, "the library's %s file is missing or unreadable: %s", keys[i], strerror(errno));
        if (strcmp(hex, recorded))
            die(1, "AN-ARTIFACT", file, "is not the file the manifest describes: its SHA-256 is %s, the manifest's %s (a stale or substituted %s)", hex, recorded, keys[i]);
        *digests[i] = xstrdup(recorded);
        free(file);
    }
    return lib;
}

/* The header must declare the entry (its text, not the manifest's word). */
static void checkHeader(const library *lib, const char *data) {
    char *abi = xprintf("#define %s_ABI_VERSION 1", lib->library);
    if (!strstr(data, abi)) die(1, "AN-ARTIFACT", lib->headerName, "the header does not state the C ABI version 1 (%s)", abi);
    char *decl = xprintf("int32_t %s_main(int argc, char **argv, %s_error **error);", lib->library, lib->library);
    if (!strstr(data, decl)) die(1, "AN-ARTIFACT", lib->headerName, "the header does not declare %s", decl);
    free(abi);
    free(decl);
}

/* The sonames of Android's platform libraries. */
static int platformSoname(const char *soname) {
    for (size_t i = 0; i < sizeof platformLibraries / sizeof *platformLibraries; i++) {
        char *s = xprintf("lib%s.so", platformLibraries[i]);
        int same = !strcmp(s, soname);
        free(s);
        if (same) return 1;
    }
    return 0;
}

/* An Android AArch64 shared object aligned for 16 KiB pages, from its
 * bytes. */
static elf_facts checkAndroidElf(const char *file, const char *what, const char *soname) {
    size_t len;
    char *data = readFile(file, &len);
    if (!data) die(1, "AN-ARTIFACT", file, "cannot read %s", what);
    elf_facts f = elf_read((const uint8_t *)data, len);
    if (!f.ok) die(1, "AN-ELF", file, "%s is no shared library this generator reads: %s", what, f.error);
    if (f.machine != 183)
        die(1, "AN-ELF", file, "%s is built for the ELF machine %d, not AArch64 (183): it is no arm64-v8a library", what, f.machine);
    if (f.type != 3) die(1, "AN-ELF", file, "%s is no shared object (ELF type %d)", what, f.type);
    if (f.minAlign < 16384)
        die(1, "AN-ELF", file, "%s has a loadable segment aligned to %llu bytes: Android's 16 KiB page devices need 16384", what,
            (unsigned long long)f.minAlign);
    if (!f.soname || strcmp(f.soname, soname)) die(1, "AN-ELF", file, "%s's SONAME is \"%s\", not %s", what, f.soname ? f.soname : "", soname);
    for (size_t i = 0; i < f.nversions; i++)
        if (!strncmp(f.versions[i], "GLIBC_", 6))
            die(1, "AN-ELF", file, "%s requires the glibc symbol version %s: it is a Linux/glibc library, not an Android one", what, f.versions[i]);
    if (f.textrel) die(1, "AN-ELF", file, "%s has text relocations, which Android refuses", what);
    free(data);
    return f;
}

static void checkShared(library *lib, const char *file) {
    char *soname = xprintf("lib%s.so", lib->library);
    elf_facts f = checkAndroidElf(file, "the application library", soname);
    int sdl = 0;
    for (size_t i = 0; i < f.nneeded; i++) {
        if (!strcmp(f.needed[i], "libSDL3.so")) sdl = 1;
        else if (!platformSoname(f.needed[i]))
            die(1, "AN-ELF", file, "needs %s, which is neither one of Android's platform libraries nor libSDL3.so: it would be missing on the device", f.needed[i]);
    }
    if (sdl && !lib->needsSdl)
        die(1, "AN-ELF", file, "needs libSDL3.so, which its manifest's dependencies do not declare");
    if (!elf_has(f.symbols, f.nsymbols, lib->symbol)) die(1, "AN-ELF", file, "does not export %s, the application entry", lib->symbol);
    static const char *api[] = {"error_release", "error_identity", "error_message"};
    for (size_t u = 0; u < sizeof api / sizeof *api; u++) {
        char *s = xprintf("%s_%s", lib->library, api[u]);
        if (!elf_has(f.symbols, f.nsymbols, s)) die(1, "AN-ELF", file, "does not export %s", s);
        free(s);
    }
    free(soname);
}

/* -------------------------------------------------------- the SDL3 package */

typedef struct {
    char *package, *packageVersion, *view;
    char *sdlVersion, *sdlCommit, *sdlTag;
    long long minimumApi;
    char *library, *librarySha;
    char *javaRoot;
    char **java;
    size_t njava;
    char *resRoot;
    char **res;
    size_t nres;
    char *wrapperJar, *gradlew, *license, *proguard;
} sdlpkg;

/* A relative path of a package's descriptor: '/'-separated, no empty, '.'
 * or '..' segment, no leading '/', printable ASCII of [A-Za-z0-9._-/]. */
static int safePath(const char *s) {
    if (!s || !*s || *s == '/' || strlen(s) > 400) return 0;
    const char *seg = s;
    for (const char *c = s;; c++) {
        if (*c == '/' || *c == 0) {
            size_t n = (size_t)(c - seg);
            if (n == 0 || (n == 1 && seg[0] == '.') || (n == 2 && seg[0] == '.' && seg[1] == '.')) return 0;
            if (*c == 0) break;
            seg = c + 1;
        } else if (!isalnum((unsigned char)*c) && *c != '.' && *c != '_' && *c != '-') {
            return 0;
        }
    }
    return 1;
}

/* A file of the package's view, named by the descriptor at KEY, with the
 * SHA-256 it states. */
static char *checkedFile(const sdlpkg *s, const char *descriptor, const jval *entry, const char *what) {
    const char *rel = json_str(entry, "path");
    const char *sha = json_str(entry, "sha256");
    if (!safePath(rel)) die(1, "AN-SDL3", descriptor, "%s's path \"%s\" is no relative path inside the package", what, rel ? rel : "?");
    if (!isHex(sha, 64)) die(1, "AN-SDL3", descriptor, "%s has no SHA-256", what);
    char *file = xprintf("%s/%s", s->view, rel);
    char hex[65];
    if (!isRegular(file) || !sha256_file(file, hex)) die(1, "AN-SDL3", file, "%s is missing or no regular file", what);
    if (strcmp(hex, sha))
        die(1, "AN-SDL3", file, "%s is not the file the package's Android descriptor states: its SHA-256 is %s, the descriptor's %s (a stale or substituted file)", what, hex, sha);
    return xstrdup(rel);
}

static char **checkedList(const sdlpkg *s, const char *descriptor, const jval *list, const char *what, size_t *n) {
    if (!list || list->kind != J_ARR || !list->count) die(1, "AN-SDL3", descriptor, "the descriptor lists no %s", what);
    char **out = xalloc(list->count * sizeof *out);
    for (size_t i = 0; i < list->count; i++) out[i] = checkedFile(s, descriptor, list->items[i], what);
    *n = list->count;
    return out;
}

/* Contains NEEDLE as bytes. */
static int containsBytes(const char *data, size_t len, const char *needle) {
    size_t n = strlen(needle);
    if (n == 0 || n > len) return 0;
    for (size_t i = 0; i + n <= len; i++)
        if (data[i] == needle[0] && !memcmp(data + i, needle, n)) return 1;
    return 0;
}

/* The SDL3 package PACKAGE installed in the project for android-aarch64:
 * its target view's Android descriptor and every file it states. */
static sdlpkg openSdl(const char *project, const char *package) {
    sdlpkg s = {0};
    s.package = xstrdup(package);
    s.view = xprintf("%s/.bot_modules/.targets/android-aarch64/%s", project, package);
    if (!isDirectory(s.view))
        die(1, "AN-SDL3", project, "the project has no package %s installed for android-aarch64 (no %s): an SDL3 Android application needs it (`botlish add %s -target android-aarch64`)",
            package, s.view, package);
    char *pkgJson = xprintf("%s/botlish.json", s.view);
    jval *pj = readJson(pkgJson, "the SDL3 package's botlish.json", "AN-SDL3");
    s.packageVersion = xstrdup(need(pj, "version", pkgJson, "the package"));
    char *descriptor = xprintf("%s/android/sdl3-android.json", s.view);
    if (!isRegular(descriptor))
        die(1, "AN-SDL3", descriptor, "the package %s %s has no Android descriptor: it is no SDL3 package with an android-aarch64 view (its Java classes and libSDL3.so)", package, s.packageVersion);
    jval *d = readJson(descriptor, "the SDL3 package's Android descriptor", "AN-SDL3");
    long long schema = 0;
    if (!matches(json_str(d, "kind"), "botlish-sdl3-android") || !json_int(d, "schema", &schema) || schema != 1)
        die(1, "AN-SDL3", descriptor, "is no botlish-sdl3-android descriptor of schema 1");
    if (!matches(json_str(d, "target"), "android-aarch64") || !matches(json_str(d, "abi"), "arm64-v8a"))
        die(1, "AN-SDL3", descriptor, "describes SDL for %s (%s), not android-aarch64 (arm64-v8a)", json_str(d, "target") ? json_str(d, "target") : "?",
            json_str(d, "abi") ? json_str(d, "abi") : "?");
    jval *sdl = json_get(d, "sdl");
    s.sdlVersion = xstrdup(need(sdl, "version", descriptor, "sdl"));
    s.sdlTag = xstrdup(need(sdl, "tag", descriptor, "sdl"));
    s.sdlCommit = xstrdup(need(sdl, "commit", descriptor, "sdl"));
    int major, minor, micro;
    char rest;
    if (sscanf(s.sdlVersion, "%d.%d.%d%c", &major, &minor, &micro, &rest) != 3 || major != 3)
        die(1, "AN-SDL3", descriptor, "SDL %s is no SDL 3 release version", s.sdlVersion);
    if (!isHex(s.sdlCommit, 40)) die(1, "AN-SDL3", descriptor, "sdl.commit is no Git commit");
    if (!json_int(d, "minimumApi", &s.minimumApi) || s.minimumApi < 21) die(1, "AN-SDL3", descriptor, "minimumApi is no API level of at least 21");

    /* libSDL3.so: its digest, its ELF, its revision. */
    jval *lib = json_get(d, "library");
    if (!matches(json_str(lib, "soname"), "libSDL3.so")) die(1, "AN-SDL3", descriptor, "library.soname is not libSDL3.so");
    s.library = checkedFile(&s, descriptor, lib, "libSDL3.so");
    s.librarySha = xstrdup(json_str(lib, "sha256"));
    char *libFile = xprintf("%s/%s", s.view, s.library);
    elf_facts f = checkAndroidElf(libFile, "libSDL3.so", "libSDL3.so");
    for (size_t i = 0; i < f.nneeded; i++)
        if (!platformSoname(f.needed[i]))
            die(1, "AN-SDL3", libFile, "libSDL3.so needs %s, which is none of Android's platform libraries", f.needed[i]);
    if (!elf_has(f.symbols, f.nsymbols, "SDL_RunApp") || !elf_has(f.symbols, f.nsymbols, "JNI_OnLoad"))
        die(1, "AN-SDL3", libFile, "does not export SDL_RunApp and JNI_OnLoad: it is no SDL3 for Android");
    size_t len;
    char *bytes = readFile(libFile, &len);
    char *revision = xprintf("SDL-%s-", s.sdlVersion);
    if (!bytes || !containsBytes(bytes, len, revision))
        die(1, "AN-SDL3", libFile, "holds no SDL revision of version %s (\"%s...\"): it is another SDL than the package states", s.sdlVersion, revision);
    free(bytes);

    /* The binding states the same version. */
    char *version = xprintf("%s/sdl3/version.bot", s.view);
    char *binding = readFile(version, &len);
    char *expected = xprintf("SDL_VERSION = sdl3::ctypes::c_int(%d)", major * 1000000 + minor * 1000 + micro);
    if (!binding || !strstr(binding, expected))
        die(1, "AN-SDL3", version, "the package's binding is not SDL %s's (no \"%s\"): binding and library disagree", s.sdlVersion, expected);
    free(binding);

    /* SDL's Java classes, resources, the Gradle wrapper and the license. */
    jval *java = json_get(d, "java");
    if (!matches(json_str(java, "package"), "org.libsdl.app")) die(1, "AN-SDL3", descriptor, "java.package is not org.libsdl.app");
    s.java = checkedList(&s, descriptor, json_get(java, "files"), "Java source", &s.njava);
    int activity = 0;
    for (size_t i = 0; i < s.njava; i++) {
        const char *base = strrchr(s.java[i], '/');
        if (strncmp(s.java[i], "android/java/org/libsdl/app/", 28) || !base || strchr(base + 1, '/'))
            die(1, "AN-SDL3", descriptor, "the Java source %s is not under android/java/org/libsdl/app/", s.java[i]);
        if (!strcmp(base, "/SDLActivity.java")) activity = 1;
    }
    if (!activity) die(1, "AN-SDL3", descriptor, "the Java sources hold no SDLActivity.java");
    s.res = checkedList(&s, descriptor, json_get(d, "resources"), "resource", &s.nres);
    for (size_t i = 0; i < s.nres; i++)
        if (strncmp(s.res[i], "android/res/", 12))
            die(1, "AN-SDL3", descriptor, "the resource %s is not under android/res/", s.res[i]);
    jval *gradle = json_get(d, "gradle");
    s.wrapperJar = checkedFile(&s, descriptor, json_get(gradle, "wrapper"), "the Gradle wrapper");
    s.gradlew = checkedFile(&s, descriptor, json_get(gradle, "gradlew"), "gradlew");
    s.license = checkedFile(&s, descriptor, json_get(d, "license"), "SDL's license");
    s.proguard = checkedFile(&s, descriptor, json_get(d, "proguard"), "SDL's ProGuard rules");
    return s;
}

/* ---------------------------------------------------------------- options */

static const char *const javaKeywords[] = {"abstract", "assert", "boolean", "break", "byte", "case", "catch", "char",
    "class", "const", "continue", "default", "do", "double", "else", "enum", "extends", "final", "finally", "float",
    "for", "goto", "if", "implements", "import", "instanceof", "int", "interface", "long", "native", "new", "package",
    "private", "protected", "public", "return", "short", "static", "strictfp", "super", "switch", "synchronized",
    "this", "throw", "throws", "transient", "try", "void", "volatile", "while", "true", "false", "null", "var",
    "record", "yield", "sealed", "permits", "non-sealed"};

static int javaKeyword(const char *s, size_t n) {
    for (size_t i = 0; i < sizeof javaKeywords / sizeof *javaKeywords; i++)
        if (strlen(javaKeywords[i]) == n && !strncmp(javaKeywords[i], s, n)) return 1;
    return 0;
}

/* An Android application ID: two or more segments of [A-Za-z][A-Za-z0-9_]*,
 * none a Java keyword (it is also the Java package of the Activity). */
static int validApplicationId(const char *s) {
    size_t n = strlen(s);
    if (n == 0 || n > 200) return 0;
    int segments = 0;
    const char *seg = s;
    for (const char *c = s;; c++) {
        if (*c == '.' || *c == 0) {
            size_t len = (size_t)(c - seg);
            if (len == 0 || !isalpha((unsigned char)seg[0]) || javaKeyword(seg, len)) return 0;
            segments++;
            if (*c == 0) break;
            seg = c + 1;
        } else if (!isalnum((unsigned char)*c) && *c != '_') {
            return 0;
        }
    }
    return segments >= 2;
}

static int validClass(const char *s) {
    size_t n = strlen(s);
    if (n == 0 || n > 64 || !isupper((unsigned char)s[0]) || javaKeyword(s, n)) return 0;
    for (const char *c = s; *c; c++)
        if (!isalnum((unsigned char)*c) && *c != '_') return 0;
    return strcmp(s, "SDLActivity") != 0;
}

/* Well-formed UTF-8 without control characters, 1 to 100 bytes. */
static int validName(const char *s) {
    size_t n = strlen(s);
    if (n == 0 || n > 100) return 0;
    const unsigned char *p = (const unsigned char *)s;
    while (*p) {
        unsigned c = *p;
        int extra;
        unsigned cp;
        if (c < 0x80) {
            if (c < 0x20 || c == 0x7f) return 0;
            p++;
            continue;
        } else if ((c & 0xe0) == 0xc0) {
            extra = 1;
            cp = c & 0x1f;
        } else if ((c & 0xf0) == 0xe0) {
            extra = 2;
            cp = c & 0x0f;
        } else if ((c & 0xf8) == 0xf0) {
            extra = 3;
            cp = c & 0x07;
        } else {
            return 0;
        }
        p++;
        for (int i = 0; i < extra; i++, p++) {
            if ((*p & 0xc0) != 0x80) return 0;
            cp = (cp << 6) | (*p & 0x3f);
        }
        if ((extra == 1 && cp < 0x80) || (extra == 2 && cp < 0x800) || (extra == 3 && cp < 0x10000) || cp > 0x10ffff ||
            (cp >= 0xd800 && cp <= 0xdfff) || (cp >= 0x80 && cp < 0xa0))
            return 0;
    }
    return 1;
}

/* NAME as the text of an Android string resource: XML's escapes, and
 * Android's own for the apostrophe, the quotation mark, the backslash and
 * a leading @ or ?. */
static char *xmlName(const char *s) {
    text t = {0};
    for (const char *c = s; *c; c++) {
        if (c == s && (*c == '@' || *c == '?')) printf_(&t, "\\%c", *c);
        else if (*c == '&') puts_(&t, "&amp;");
        else if (*c == '<') puts_(&t, "&lt;");
        else if (*c == '>') puts_(&t, "&gt;");
        else if (*c == '\'') puts_(&t, "\\'");
        else if (*c == '"') puts_(&t, "\\\"");
        else if (*c == '\\') puts_(&t, "\\\\");
        else put(&t, c, 1);
    }
    if (!t.s) puts_(&t, "");
    return t.s;
}

static int validVersionName(const char *s) {
    size_t n = strlen(s);
    if (n == 0 || n > 64) return 0;
    for (const char *c = s; *c; c++)
        if (!isalnum((unsigned char)*c) && !strchr(".-+_", *c)) return 0;
    return 1;
}

typedef struct {
    int command; /* 0 generate, 1 build */
    char *applicationId, *name, *activity, *versionName, *sdl3, *assets, *task;
    long long versionCode, api;
    int extracted, intentArguments, replace;
} options;

static void usage(const char *message) {
    die(2, "AN-USAGE", NULL,
        "%s; usage: botlish tool -out DIR -artifact LIB.manifest.json -target android-aarch64 android generate "
        "[-application-id ID] [-name NAME] [-activity CLASS] [-version-code N] [-version-name V] [-android-api N] "
        "[-sdl3 PACKAGE] [-packaging uncompressed|extracted] [-assets DIR] [-intent-arguments] [-replace]; "
        "or ... android build [-task assembleRelease|assembleDebug]",
        message);
}

static long long number(const char *option, const char *v, long long low, long long high) {
    char *end;
    errno = 0;
    long long n = strtoll(v, &end, 10);
    if (errno || *end || !*v || n < low || n > high) usage(xprintf("%s %s is no number from %lld to %lld", option, v, low, high));
    return n;
}

static options parseOptions(int argc, char **argv, const library *lib) {
    options o = {0};
    if (argc < 2) usage("no command");
    if (!strcmp(argv[1], "generate")) o.command = 0;
    else if (!strcmp(argv[1], "build")) o.command = 1;
    else usage(xprintf("unknown command \"%s\"", argv[1]));
    for (int i = 2; i < argc; i++) {
        const char *a = argv[i];
        if (o.command == 0 && !strcmp(a, "-replace")) {
            o.replace = 1;
            continue;
        }
        if (o.command == 0 && !strcmp(a, "-intent-arguments")) {
            o.intentArguments = 1;
            continue;
        }
        if (i + 1 >= argc) usage(xprintf("%s needs a value", a));
        const char *v = argv[++i];
        if (o.command == 1) {
            if (!strcmp(a, "-task")) o.task = xstrdup(v);
            else usage(xprintf("unknown option \"%s\" of build", a));
            continue;
        }
        if (!strcmp(a, "-application-id")) o.applicationId = xstrdup(v);
        else if (!strcmp(a, "-name")) o.name = xstrdup(v);
        else if (!strcmp(a, "-activity")) o.activity = xstrdup(v);
        else if (!strcmp(a, "-version-code")) o.versionCode = number(a, v, 1, 2100000000);
        else if (!strcmp(a, "-version-name")) o.versionName = xstrdup(v);
        else if (!strcmp(a, "-android-api")) o.api = number(a, v, 21, 99);
        else if (!strcmp(a, "-sdl3")) o.sdl3 = xstrdup(v);
        else if (!strcmp(a, "-assets")) o.assets = xstrdup(v);
        else if (!strcmp(a, "-packaging")) {
            if (!strcmp(v, "uncompressed")) o.extracted = 0;
            else if (!strcmp(v, "extracted")) o.extracted = 1;
            else usage(xprintf("-packaging %s is neither uncompressed nor extracted", v));
        } else usage(xprintf("unknown option \"%s\"", a));
    }
    if (o.command == 1) {
        if (!o.task) o.task = xstrdup("assembleRelease");
        if (strcmp(o.task, "assembleRelease") && strcmp(o.task, "assembleDebug"))
            usage(xprintf("-task %s is neither assembleRelease nor assembleDebug", o.task));
        return o;
    }
    if (!o.applicationId) o.applicationId = xprintf("org.botlish.%s", lib->library);
    if (!validApplicationId(o.applicationId))
        die(1, "AN-NAME", NULL, "\"%s\" is no Android application ID (two or more segments of a letter, then letters, digits and _; no Java keyword)", o.applicationId);
    if (!o.name) o.name = xstrdup(lib->library);
    if (!validName(o.name)) die(1, "AN-NAME", NULL, "the display name is no text of 1 to 100 bytes of UTF-8 without control characters");
    if (!o.activity) o.activity = xstrdup("MainActivity");
    if (!validClass(o.activity))
        die(1, "AN-NAME", NULL, "\"%s\" is no Activity class name (an uppercase letter, then letters, digits and _; not SDLActivity or a Java keyword)", o.activity);
    if (!o.versionCode) o.versionCode = 1;
    if (!o.versionName) o.versionName = xstrdup("1.0");
    if (!validVersionName(o.versionName)) die(1, "AN-NAME", NULL, "\"%s\" is no version name (letters, digits, . - + _)", o.versionName);
    if (!o.sdl3) o.sdl3 = xstrdup("sdl3");
    if (!isIdentifier(o.sdl3)) die(1, "AN-NAME", NULL, "\"%s\" is no package name", o.sdl3);
    return o;
}

/* ---------------------------------------------------------------- the output */

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

/* Removes the empty directories under DIR (the previous project's). */
static void pruneEmpty(const char *dir) {
    DIR *d = opendir(dir);
    if (!d) return;
    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (!strcmp(e->d_name, ".") || !strcmp(e->d_name, "..")) continue;
        char *p = xprintf("%s/%s", dir, e->d_name);
        struct stat s;
        if (lstat(p, &s) == 0 && S_ISDIR(s.st_mode)) {
            pruneEmpty(p);
            rmdir(p);
        }
        free(p);
    }
    closedir(d);
}

#define MARKER "botlish-android.json"

/* The output directory, made ready: empty, or holding only a project this
 * generator made (with -replace), whose files are removed. Anything else
 * there is someone's, and refused. */
/* Removes the file or directory tree P, if there is one (a directory with
 * /bin/rm -rf: a build's outputs, never a file of the project's record). */
static void removePath(const char *p) {
    struct stat s;
    if (lstat(p, &s) != 0) return;
    if (!S_ISDIR(s.st_mode)) {
        unlink(p);
        return;
    }
    char *cmd[] = {"/bin/rm", "-rf", "--", (char *)p, NULL};
    pid_t pid = fork();
    if (pid == 0) {
        execv(cmd[0], cmd);
        _exit(127);
    }
    int status;
    if (pid > 0) waitpid(pid, &status, 0);
}

static void prepareOutput(const char *out, const char *project, int replace) {
    if (strstr(out, "/.bot_modules/") || (strlen(out) >= 13 && !strcmp(out + strlen(out) - 13, "/.bot_modules")))
        die(1, "AN-OUTPUT", out, "lies inside a .bot_modules directory, the installed packages, which no tool writes");
    if (!strcmp(out, project)) die(1, "AN-OUTPUT", out, "is the project's own directory: choose an empty directory for the Android project");
    if (!isDirectory(out)) mkdirs(out);
    if (!isDirectory(out)) die(1, "AN-OUTPUT", out, "is no directory");
    if (emptyDirectory(out)) return;
    char *marker = xprintf("%s/" MARKER, out);
    if (access(marker, F_OK) != 0)
        die(1, "AN-OUTPUT", out, "is not empty and holds no project this generator made: choose an empty directory");
    if (!replace) die(1, "AN-OUTPUT", out, "holds a project this generator made: pass -replace to generate it again");
    jval *previous = readJson(marker, "the previous project's record", "AN-OUTPUT");
    jval *files = json_get(previous, "files");
    if (!files || files->kind != J_ARR) die(1, "AN-OUTPUT", marker, "the record lists no files");
    for (size_t i = 0; i < files->count; i++) {
        const char *f = files->items[i]->kind == J_STR ? files->items[i]->text : NULL;
        if (!safePath(f)) die(1, "AN-OUTPUT", marker, "the record names a file outside the project");
    }
    for (size_t i = 0; i < files->count; i++) {
        char *p = xprintf("%s/%s", out, files->items[i]->text);
        unlink(p);
        free(p);
    }
    unlink(marker);
    pruneEmpty(out);
    /* A previous build's outputs are the build's, not the project's. */
    static const char *derived[] = {".gradle", "build", "app/build", "app/.cxx", "local.properties"};
    for (size_t i = 0; i < sizeof derived / sizeof *derived; i++) {
        char *p = xprintf("%s/%s", out, derived[i]);
        removePath(p);
        free(p);
    }
    if (!emptyDirectory(out))
        die(1, "AN-OUTPUT", out, "holds files the previous project's record does not name: they are someone's; remove them or choose another directory");
}

/* An asset name: [A-Za-z0-9._-], not starting with '.'. */
static int assetName(const char *s) {
    if (!*s || *s == '.' || strlen(s) > 120) return 0;
    for (const char *c = s; *c; c++)
        if (!isalnum((unsigned char)*c) && !strchr("._-", *c)) return 0;
    return 1;
}

typedef struct {
    char **rel;
    size_t n, cap;
} pathlist;

static int compareStrings(const void *a, const void *b) { return strcmp(*(char *const *)a, *(char *const *)b); }

/* The files under ROOT/REL: regular files and directories only (a link,
 * device or anything else is refused), at most 8 levels and 1000 files. */
static void listAssets(const char *root, const char *rel, int depth, pathlist *out) {
    char *dir = rel[0] ? xprintf("%s/%s", root, rel) : xstrdup(root);
    DIR *d = opendir(dir);
    if (!d) die(1, "AN-ASSETS", dir, "cannot read the assets directory: %s", strerror(errno));
    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (!strcmp(e->d_name, ".") || !strcmp(e->d_name, "..")) continue;
        char *p = xprintf("%s/%s", dir, e->d_name);
        char *r = rel[0] ? xprintf("%s/%s", rel, e->d_name) : xstrdup(e->d_name);
        if (!assetName(e->d_name)) die(1, "AN-ASSETS", p, "is no asset name (letters, digits, . _ -; not hidden)");
        struct stat s;
        if (lstat(p, &s) != 0) die(1, "AN-ASSETS", p, "cannot be read");
        if (S_ISDIR(s.st_mode)) {
            if (depth >= 8) die(1, "AN-ASSETS", p, "lies deeper than 8 directories");
            listAssets(root, r, depth + 1, out);
        } else if (S_ISREG(s.st_mode)) {
            if (out->n == 1000) die(1, "AN-ASSETS", root, "holds more than 1000 files");
            if (out->n == out->cap) {
                out->cap = out->cap ? out->cap * 2 : 16;
                out->rel = realloc(out->rel, out->cap * sizeof *out->rel);
                if (!out->rel) exit(70);
            }
            out->rel[out->n++] = xstrdup(r);
        } else {
            die(1, "AN-ASSETS", p, "is no regular file or directory (a link is refused: an asset is a file of the application)");
        }
        free(p);
        free(r);
    }
    closedir(d);
    free(dir);
}

static void runBuild(const char *out, const char *task) {
    char *marker = xprintf("%s/" MARKER, out);
    if (access(marker, F_OK) != 0)
        die(1, "AN-OUTPUT", out, "holds no project this generator made: run `android generate` first");
    char *gradlew = xprintf("%s/gradlew", out);
    if (!isRegular(gradlew)) die(1, "AN-OUTPUT", gradlew, "is missing: generate the project again");
    if (!getenv("ANDROID_HOME") || !*getenv("ANDROID_HOME"))
        die(1, "AN-TOOLCHAIN", NULL, "ANDROID_HOME is not set: the Android SDK builds the project");
    /* An earlier build's packages go first: a build that fails leaves no
     * APK that looks like its result. */
    char *outputs = xprintf("%s/app/build/outputs", out);
    removePath(outputs);
    free(outputs);
    finish();
    fflush(NULL);
    pid_t pid = fork();
    if (pid < 0) die(1, "AN-BUILD", out, "cannot start Gradle: %s", strerror(errno));
    if (pid == 0) {
        if (chdir(out) != 0) _exit(127);
        execl("./gradlew", "./gradlew", "--no-daemon", "--console=plain", task, (char *)NULL);
        _exit(127);
    }
    int status;
    if (waitpid(pid, &status, 0) < 0) die(1, "AN-BUILD", out, "cannot wait for Gradle");
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        fprintf(stderr, "android: Gradle's %s failed\n", task);
        exit(1);
    }
    exit(0);
}

int main(int argc, char **argv) {
    request r = openRequest();
    library lib = openLibrary(r.manifest, r.target);
    options o = parseOptions(argc, argv, &lib);
    if (o.command == 1) runBuild(r.output, o.task);
    size_t headerLen;
    char *headerFile = xprintf("%s/%s", lib.dir, lib.headerName);
    char *header = readFile(headerFile, &headerLen);
    if (!header) die(1, "AN-ARTIFACT", headerFile, "cannot read the header");
    checkHeader(&lib, header);
    char *sharedFile = xprintf("%s/%s", lib.dir, lib.sharedName);
    checkShared(&lib, sharedFile);
    sdlpkg sdl = openSdl(r.project, o.sdl3);
    long long floor = lib.minimumApi > sdl.minimumApi ? lib.minimumApi : sdl.minimumApi;
    if (o.api && o.api < floor)
        die(1, "AN-ANDROID-API", NULL, "-android-api %lld is below the floor %lld (the library's %lld, SDL's %lld)", o.api, floor, lib.minimumApi, sdl.minimumApi);
    if (!o.api) o.api = floor;
    if (o.api > build.compileSdk)
        die(1, "AN-ANDROID-API", NULL, "-android-api %lld is above the platform this project compiles against (%d)", o.api, build.compileSdk);
    pathlist assets = {0};
    if (o.assets) {
        if (!isDirectory(o.assets)) die(1, "AN-ASSETS", o.assets, "is no directory");
        listAssets(o.assets, "", 0, &assets);
        qsort(assets.rel, assets.n, sizeof *assets.rel, compareStrings);
    }
    prepareOutput(r.output, r.project, o.replace);

    const char *L = lib.library;
    char *minSdk = xprintf("%lld", o.api), *libraryApi = xprintf("%lld", lib.minimumApi);
    char *compileSdk = xprintf("%d", build.compileSdk), *targetSdk = xprintf("%d", build.targetSdk);
    char *versionCode = xprintf("%lld", o.versionCode);
    char *project = xstrdup(o.applicationId);
    for (char *c = project; *c; c++)
        if (*c == '.') *c = '-';
    bind("TOOL_VERSION", TOOL_VERSION);
    bind("LIBRARY", L);
    bind("HEADER", lib.headerName);
    bind("MANIFEST_SHA256", lib.shaManifest);
    bind("APP_SHA256", lib.shaShared);
    bind("RUNTIME_ABI", lib.runtimeAbi);
    bind("SUPPORT_PACKAGE", lib.supportPackage);
    bind("LIBRARY_API", libraryApi);
    bind("NDK_REVISION", lib.toolchainRevision);
    bind("APPLICATION_ID", o.applicationId);
    bind("ACTIVITY", o.activity);
    bind("PROJECT", project);
    bind("DISPLAY_NAME", o.name);
    bind("DISPLAY_NAME_XML", xmlName(o.name));
    bind("VERSION_CODE", versionCode);
    bind("VERSION_NAME", o.versionName);
    bind("MIN_SDK", minSdk);
    bind("COMPILE_SDK", compileSdk);
    bind("TARGET_SDK", targetSdk);
    bind("AGP", build.agp);
    bind("GRADLE", build.gradle);
    bind("GRADLE_SHA256", build.gradleSha256);
    bind("CMAKE", build.cmake);
    bind("SDL_VERSION", sdl.sdlVersion);
    bind("SDL_SHA256", sdl.librarySha);
    bind("SDL3_PACKAGE", sdl.package);
    bind("SDL3_VERSION", sdl.packageVersion);
    bind("LEGACY_PACKAGING", o.extracted ? "true" : "false");
    bind("PACKAGING_NOTE", o.extracted
        ? "-packaging extracted: the libraries are compressed in the APK and extracted at installation"
        : "-packaging uncompressed (the default): the libraries are stored uncompressed and page-aligned in the APK and loaded from it; SDLActivity loads them by name (System.loadLibrary, and nativeRunMain retries libmain.so by its bare name)");
    bind("ARGUMENTS_METHOD", o.intentArguments
        ? "\n    // A test configuration (botlish-android -intent-arguments): the\n"
          "    // application's arguments are the launching intent's string array\n"
          "    // extra org.botlish.android.ARGUMENTS. A project generated without\n"
          "    // the option passes none.\n"
          "    @Override\n"
          "    protected String[] getArguments() {\n"
          "        String[] extra = getIntent().getStringArrayExtra(\"org.botlish.android.ARGUMENTS\");\n"
          "        return extra != null ? extra : new String[0];\n"
          "    }\n"
        : "");

    const char *out = r.output;
    text t;
    t = expand(tpl_settings_gradle);
    writeText(out, "settings.gradle", &t);
    t = expand(tpl_build_gradle);
    writeText(out, "build.gradle", &t);
    t = expand(tpl_gradle_properties);
    writeText(out, "gradle.properties", &t);
    t = expand(tpl_gradle_wrapper_properties);
    writeText(out, "gradle/wrapper/gradle-wrapper.properties", &t);
    t = expand(tpl_app_build_gradle);
    writeText(out, "app/build.gradle", &t);
    t = expand(tpl_AndroidManifest_xml);
    writeText(out, "app/src/main/AndroidManifest.xml", &t);
    t = expand(tpl_strings_xml);
    writeText(out, "app/src/main/res/values/strings.xml", &t);
    char *javaDir = xstrdup(o.applicationId);
    for (char *c = javaDir; *c; c++)
        if (*c == '.') *c = '/';
    t = expand(tpl_Activity_java);
    char *activityFile = xprintf("app/src/main/java/%s/%s.java", javaDir, o.activity);
    writeText(out, activityFile, &t);
    t = expand(tpl_main_c);
    writeText(out, "app/src/main/cpp/main.c", &t);
    t = expand(tpl_CMakeLists_txt);
    writeText(out, "app/src/main/cpp/CMakeLists.txt", &t);
    t = expand(tpl_README_md);
    writeText(out, "README.md", &t);

    /* The application library and its header, and SDL's files, as their
     * packages hold them. */
    char *appDest = xprintf("app/src/main/botlish/arm64-v8a/lib%s.so", L);
    copyFile(sharedFile, out, appDest, 0644);
    char *headerDest = xprintf("app/src/main/cpp/%s", lib.headerName);
    copyFile(headerFile, out, headerDest, 0644);
    char *sdlFile = xprintf("%s/%s", sdl.view, sdl.library);
    copyFile(sdlFile, out, "app/src/main/botlish/arm64-v8a/libSDL3.so", 0644);
    for (size_t i = 0; i < sdl.njava; i++) {
        char *from = xprintf("%s/%s", sdl.view, sdl.java[i]);
        char *to = xprintf("app/src/main/java/%s", sdl.java[i] + strlen("android/java/"));
        copyFile(from, out, to, 0644);
    }
    for (size_t i = 0; i < sdl.nres; i++) {
        char *from = xprintf("%s/%s", sdl.view, sdl.res[i]);
        char *to = xprintf("app/src/main/res/%s", sdl.res[i] + strlen("android/res/"));
        if (!strcmp(to, "app/src/main/res/values/strings.xml")) continue;
        copyFile(from, out, to, 0644);
    }
    char *from = xprintf("%s/%s", sdl.view, sdl.wrapperJar);
    copyFile(from, out, "gradle/wrapper/gradle-wrapper.jar", 0644);
    from = xprintf("%s/%s", sdl.view, sdl.gradlew);
    copyFile(from, out, "gradlew", 0755);
    from = xprintf("%s/%s", sdl.view, sdl.license);
    copyFile(from, out, "LICENSES/SDL.txt", 0644);
    from = xprintf("%s/%s", sdl.view, sdl.proguard);
    copyFile(from, out, "app/proguard-rules.pro", 0644);
    for (size_t i = 0; i < assets.n; i++) {
        char *af = xprintf("%s/%s", o.assets, assets.rel[i]);
        char *to = xprintf("app/src/main/assets/%s", assets.rel[i]);
        copyFile(af, out, to, 0644);
    }

    /* The record, last: what the project was generated from, and its
     * files (a later -replace removes exactly these). */
    text rec = {0};
    puts_(&rec, "{\n  \"kind\": \"botlish-android-project\",\n  \"schema\": 1,\n  \"generator\": {\"name\": ");
    json_text(&rec, TOOL_NAME);
    puts_(&rec, ", \"version\": ");
    json_text(&rec, TOOL_VERSION);
    puts_(&rec, "},\n  \"library\": {\"name\": ");
    json_text(&rec, L);
    puts_(&rec, ", \"entry\": ");
    json_text(&rec, lib.symbol);
    puts_(&rec, ", \"manifestSha256\": ");
    json_text(&rec, lib.shaManifest);
    puts_(&rec, ", \"sharedSha256\": ");
    json_text(&rec, lib.shaShared);
    puts_(&rec, ", \"runtimeAbi\": ");
    json_text(&rec, lib.runtimeAbi);
    puts_(&rec, ", \"targetSupport\": ");
    json_text(&rec, lib.supportPackage);
    puts_(&rec, "},\n  \"sdl3\": {\"package\": ");
    json_text(&rec, sdl.package);
    puts_(&rec, ", \"version\": ");
    json_text(&rec, sdl.packageVersion);
    puts_(&rec, ", \"sdl\": ");
    json_text(&rec, sdl.sdlVersion);
    puts_(&rec, ", \"commit\": ");
    json_text(&rec, sdl.sdlCommit);
    puts_(&rec, ", \"librarySha256\": ");
    json_text(&rec, sdl.librarySha);
    puts_(&rec, "},\n  \"android\": {\"applicationId\": ");
    json_text(&rec, o.applicationId);
    puts_(&rec, ", \"activity\": ");
    json_text(&rec, o.activity);
    printf_(&rec, ", \"abi\": \"arm64-v8a\", \"minSdk\": %lld, \"compileSdk\": %d, \"targetSdk\": %d, \"agp\": ", o.api,
            build.compileSdk, build.targetSdk);
    json_text(&rec, build.agp);
    puts_(&rec, ", \"gradle\": ");
    json_text(&rec, build.gradle);
    puts_(&rec, ", \"ndk\": ");
    json_text(&rec, lib.toolchainRevision);
    printf_(&rec, ", \"packaging\": \"%s\", \"intentArguments\": %s},\n  \"files\": [", o.extracted ? "extracted" : "uncompressed",
            o.intentArguments ? "true" : "false");
    char **sorted = xalloc((size_t)nwritten * sizeof *sorted);
    memcpy(sorted, written, (size_t)nwritten * sizeof *sorted);
    qsort(sorted, (size_t)nwritten, sizeof *sorted, compareStrings);
    for (int i = 0; i < nwritten; i++) {
        puts_(&rec, i ? ",\n    " : "\n    ");
        json_text(&rec, sorted[i]);
    }
    puts_(&rec, "\n  ]\n}\n");
    char *markerPath = xprintf("%s/" MARKER, out);
    FILE *mf = fopen(markerPath, "wb");
    if (!mf || fwrite(rec.s, 1, rec.len, mf) != rec.len || fclose(mf) != 0)
        die(1, "AN-WRITE", markerPath, "cannot write the record: %s", strerror(errno));
    fprintf(stderr, "android: generated %s (%d files): %s for %s, SDL %s, minimum API %lld\n", out, nwritten, o.applicationId, L,
            sdl.sdlVersion, o.api);
    finish();
    return 0;
}
