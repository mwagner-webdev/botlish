/* probe-tool.c -- the fixture tool of tests/external-tools.test
 * (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md): a protocol 1
 * tool that records how it was run and does what its first argument says.
 *
 * Every run first appends a line to the file PROBE_MARKER names (fixed when
 * it is built, -DPROBE_MARKER="PATH"): the record of every execution, which
 * shows that installing, importing or compiling never runs it. Then, with a
 * request (BOTLISH_TOOL_REQUEST), it writes into the request's output
 * directory:
 *
 *   argv.hex      each argument after the program's name, as hexadecimal
 *                 bytes, one per line (an empty argument an empty line)
 *   request.json  the request, byte for byte
 *
 * and does what its first argument says:
 *
 *   ok                  exit 0
 *   exit N              exit N
 *   abort               end by SIGABRT
 *   diagnose            write two structured diagnostics, exit 3
 *   tamper PATH         append to the file PATH, exit 0
 *   say TEXT            write TEXT to standard output and standard error
 *   (anything else)     exit 0
 */
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef PROBE_MARKER
#define PROBE_MARKER "/dev/null"
#endif

static char *join(const char *dir, const char *name) {
    size_t n = strlen(dir) + strlen(name) + 2;
    char *p = malloc(n);
    if (!p) exit(70);
    snprintf(p, n, "%s/%s", dir, name);
    return p;
}

/* The member "output" of the request text TEXT (a flat search: the request
 * is the package manager's own JSON, and an output path holds no quote in
 * the tests that read it). */
static char *output_of(const char *text) {
    const char *key = strstr(text, "\"output\": \"");
    if (!key) return NULL;
    key += strlen("\"output\": \"");
    const char *end = strchr(key, '"');
    if (!end) return NULL;
    char *out = malloc((size_t)(end - key) + 1);
    if (!out) exit(70);
    memcpy(out, key, (size_t)(end - key));
    out[end - key] = 0;
    return out;
}

static char *diagnostics_of(const char *text) {
    const char *key = strstr(text, "\"diagnostics\": \"");
    if (!key) return NULL;
    key += strlen("\"diagnostics\": \"");
    const char *end = strchr(key, '"');
    if (!end) return NULL;
    char *out = malloc((size_t)(end - key) + 1);
    if (!out) exit(70);
    memcpy(out, key, (size_t)(end - key));
    out[end - key] = 0;
    return out;
}

int main(int argc, char **argv) {
    FILE *marker = fopen(PROBE_MARKER, "a");
    if (marker) {
        fprintf(marker, "ran %s\n", argc > 1 ? argv[1] : "");
        fclose(marker);
    }
    const char *request = getenv("BOTLISH_TOOL_REQUEST");
    char *text = NULL;
    if (request) {
        FILE *f = fopen(request, "rb");
        if (f) {
            size_t cap = 1 << 16, n = 0;
            text = malloc(cap);
            if (!text) exit(70);
            n = fread(text, 1, cap - 1, f);
            text[n] = 0;
            fclose(f);
            char *out = output_of(text);
            if (out) {
                char *path = join(out, "request.json");
                FILE *copy = fopen(path, "wb");
                if (copy) {
                    fwrite(text, 1, n, copy);
                    fclose(copy);
                }
                path = join(out, "argv.hex");
                FILE *hex = fopen(path, "w");
                if (hex) {
                    for (int i = 1; i < argc; i++) {
                        for (const unsigned char *c = (const unsigned char *)argv[i]; *c; c++) fprintf(hex, "%02x", *c);
                        fputc('\n', hex);
                    }
                    fclose(hex);
                }
            }
        }
    }
    if (argc < 2) return 0;
    if (!strcmp(argv[1], "exit") && argc > 2) return atoi(argv[2]);
    if (!strcmp(argv[1], "abort")) {
        signal(SIGABRT, SIG_DFL);
        abort();
    }
    if (!strcmp(argv[1], "diagnose")) {
        char *path = text ? diagnostics_of(text) : NULL;
        if (path) {
            FILE *d = fopen(path, "w");
            if (d) {
                fputs("{\"diagnostics\": [\n"
                      "  {\"severity\": \"error\", \"code\": \"PROBE-BROKEN\", \"message\": \"the input is broken\", \"file\": \"in.txt\", \"line\": 3, \"column\": 7},\n"
                      "  {\"severity\": \"warning\", \"code\": \"PROBE-ODD\", \"message\": \"something odd\"}\n"
                      "]}\n", d);
                fclose(d);
            }
        }
        fputs("probe: the input is broken (its own words)\n", stderr);
        return 3;
    }
    if (!strcmp(argv[1], "tamper") && argc > 2) {
        FILE *f = fopen(argv[2], "ab");
        if (f) {
            fputs("tampered\n", f);
            fclose(f);
        }
        return 0;
    }
    if (!strcmp(argv[1], "say") && argc > 2) {
        printf("out: %s\n", argv[2]);
        fprintf(stderr, "err: %s\n", argv[2]);
        return 0;
    }
    return 0;
}
