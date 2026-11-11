/* json.h -- a strict JSON reader (RFC 8259: no comments, no trailing commas,
 * no repeated keys, no lone surrogates), the botlish-react-native tool's.
 * It is the reader of the PM-7A sample tools
 * (audit/external-tools/src/toolkit.h), unchanged but for the integer
 * accessor at the end. C99, the C library only. */
#ifndef BRN_JSON_H
#define BRN_JSON_H

#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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


/* The member KEY of OBJECT as an integer, when it is a JSON number holding
 * an integer exactly (no fraction, no exponent); 0 otherwise. */
static inline int json_int(const jval *object, const char *key, long long *out) {
    jval *v = json_get(object, key);
    if (!v || v->kind != J_NUM) return 0;
    const char *t = v->text;
    if (*t == '-') t++;
    if (!*t) return 0;
    for (; *t; t++)
        if (*t < '0' || *t > '9') return 0;
    char *end;
    errno = 0;
    long long n = strtoll(v->text, &end, 10);
    if (errno || *end) return 0;
    *out = n;
    return 1;
}

#endif
