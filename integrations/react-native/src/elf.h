/* elf.h -- reads the facts of a 64-bit little-endian ELF shared object from
 * its bytes, never running or loading it: the machine, the type, each
 * loadable segment's alignment, DT_SONAME, DT_NEEDED, the symbol version
 * requirements (DT_VERNEED) and the defined global dynamic symbols. The
 * botlish-react-native tool checks a native library with it before a byte
 * of a package is written: an Android AArch64 shared object, aligned for
 * 16 KiB pages, needing Bionic's libraries only, exporting its C ABI.
 * C99, header-only. */
#ifndef BRN_ELF_H
#define BRN_ELF_H

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int ok;
    char error[200];
    int machine;    /* e_machine: 183 is EM_AARCH64 */
    int type;       /* e_type: 3 is ET_DYN */
    int bits;       /* 64 */
    int little;     /* 1 */
    uint64_t minAlign; /* the smallest PT_LOAD p_align */
    int loads;
    char *soname;
    char **needed;
    size_t nneeded;
    char **versions; /* every version name a DT_VERNEED entry requires */
    size_t nversions;
    char **symbols; /* defined global or weak dynamic symbols */
    size_t nsymbols;
    int textrel;
} elf_facts;

static inline uint64_t elf_u(const uint8_t *p, int n) {
    uint64_t v = 0;
    for (int i = n - 1; i >= 0; i--) v = (v << 8) | p[i];
    return v;
}

static inline void elf_push(char ***list, size_t *n, const char *s) {
    char **grown = realloc(*list, (*n + 1) * sizeof **list);
    char *copy = malloc(strlen(s) + 1);
    if (!grown || !copy) exit(70);
    strcpy(copy, s);
    grown[*n] = copy;
    *list = grown;
    (*n)++;
}

/* The C string at OFFSET of DATA (SIZE bytes), or NULL when it is not one. */
static inline const char *elf_string(const uint8_t *data, size_t size, uint64_t offset) {
    if (offset >= size) return NULL;
    const uint8_t *end = memchr(data + offset, 0, size - offset);
    return end ? (const char *)data + offset : NULL;
}

/* The file offset of the virtual address ADDR (through the loadable
 * segments), or (uint64_t)-1. */
static inline uint64_t elf_offset(const uint8_t *d, size_t size, uint64_t phoff, int phnum, uint64_t addr) {
    for (int i = 0; i < phnum; i++) {
        const uint8_t *ph = d + phoff + (uint64_t)i * 56;
        if (elf_u(ph, 4) != 1) continue;
        uint64_t off = elf_u(ph + 8, 8), vaddr = elf_u(ph + 16, 8), filesz = elf_u(ph + 32, 8);
        if (addr >= vaddr && addr - vaddr < filesz && off + (addr - vaddr) < size) return off + (addr - vaddr);
    }
    return (uint64_t)-1;
}

#define ELF_FAIL(...) do { snprintf(f.error, sizeof f.error, __VA_ARGS__); return f; } while (0)

static inline elf_facts elf_read(const uint8_t *d, size_t size) {
    elf_facts f;
    memset(&f, 0, sizeof f);
    if (size < 64 || memcmp(d, "\177ELF", 4)) ELF_FAIL("not an ELF file");
    f.bits = d[4] == 2 ? 64 : 32;
    f.little = d[5] == 1;
    if (f.bits != 64 || !f.little) ELF_FAIL("not a 64-bit little-endian ELF file");
    f.type = (int)elf_u(d + 16, 2);
    f.machine = (int)elf_u(d + 18, 2);
    uint64_t phoff = elf_u(d + 32, 8);
    int phentsize = (int)elf_u(d + 54, 2), phnum = (int)elf_u(d + 56, 2);
    if (phentsize != 56 || phoff > size || (uint64_t)phnum * 56 > size - phoff) ELF_FAIL("malformed program headers");
    uint64_t dynOff = 0, dynSize = 0;
    f.minAlign = UINT64_MAX;
    for (int i = 0; i < phnum; i++) {
        const uint8_t *ph = d + phoff + (uint64_t)i * 56;
        uint32_t type = (uint32_t)elf_u(ph, 4);
        if (type == 1) {
            uint64_t align = elf_u(ph + 48, 8);
            f.loads++;
            if (align < f.minAlign) f.minAlign = align;
        } else if (type == 2) {
            dynOff = elf_u(ph + 8, 8);
            dynSize = elf_u(ph + 32, 8);
        }
    }
    if (!f.loads) f.minAlign = 0;
    if (!dynOff || dynOff > size || dynSize > size - dynOff) ELF_FAIL("no dynamic section");
    uint64_t strtab = 0, strsz = 0, symtab = 0, syment = 24, hash = 0, gnuhash = 0, verneed = 0, verneednum = 0;
    uint64_t sonameOff = (uint64_t)-1;
    uint64_t neededOffs[64];
    int nneeded = 0;
    for (uint64_t p = dynOff; p + 16 <= dynOff + dynSize; p += 16) {
        int64_t tag = (int64_t)elf_u(d + p, 8);
        uint64_t val = elf_u(d + p + 8, 8);
        if (tag == 0) break;
        switch (tag) {
        case 1: if (nneeded < 64) neededOffs[nneeded++] = val; break;
        case 5: strtab = val; break;
        case 6: symtab = val; break;
        case 10: strsz = val; break;
        case 11: syment = val; break;
        case 14: sonameOff = val; break;
        case 4: hash = val; break;
        case 0x6ffffef5: gnuhash = val; break;
        case 0x6ffffffe: verneed = val; break;
        case 0x6fffffff: verneednum = val; break;
        case 22: f.textrel = 1; break;
        case 30: if (val & 4) f.textrel = 1; break; /* DT_FLAGS, DF_TEXTREL */
        default: break;
        }
    }
    uint64_t str = elf_offset(d, size, phoff, phnum, strtab);
    if (str == (uint64_t)-1 || strsz > size - str) ELF_FAIL("no dynamic string table");
    const uint8_t *strings = d + str;
    if (sonameOff != (uint64_t)-1) {
        const char *s = elf_string(strings, strsz, sonameOff);
        if (s) f.soname = strdup(s);
    }
    for (int i = 0; i < nneeded; i++) {
        const char *s = elf_string(strings, strsz, neededOffs[i]);
        if (s) elf_push(&f.needed, &f.nneeded, s);
    }
    if (verneed) {
        uint64_t v = elf_offset(d, size, phoff, phnum, verneed);
        for (uint64_t n = 0; v != (uint64_t)-1 && n < verneednum && v + 16 <= size; n++) {
            uint64_t cnt = elf_u(d + v + 2, 2), aux = elf_u(d + v + 8, 4), next = elf_u(d + v + 12, 4);
            uint64_t a = v + aux;
            for (uint64_t k = 0; k < cnt && a + 16 <= size; k++) {
                const char *s = elf_string(strings, strsz, elf_u(d + a + 8, 4));
                if (s) elf_push(&f.versions, &f.nversions, s);
                uint64_t an = elf_u(d + a + 12, 4);
                if (!an) break;
                a += an;
            }
            if (!next) break;
            v += next;
        }
    }
    /* The number of dynamic symbols: DT_HASH's nchain, else the GNU hash
     * table's highest chain end. */
    uint64_t nsyms = 0;
    if (hash) {
        uint64_t h = elf_offset(d, size, phoff, phnum, hash);
        if (h != (uint64_t)-1 && h + 8 <= size) nsyms = elf_u(d + h + 4, 4);
    } else if (gnuhash) {
        uint64_t g = elf_offset(d, size, phoff, phnum, gnuhash);
        if (g != (uint64_t)-1 && g + 16 <= size) {
            uint64_t nbuckets = elf_u(d + g, 4), symoffset = elf_u(d + g + 4, 4), bloom = elf_u(d + g + 8, 4);
            uint64_t buckets = g + 16 + bloom * 8, chains = buckets + nbuckets * 4;
            uint64_t last = 0;
            for (uint64_t b = 0; b < nbuckets && buckets + b * 4 + 4 <= size; b++) {
                uint64_t s = elf_u(d + buckets + b * 4, 4);
                if (s > last) last = s;
            }
            if (last >= symoffset) {
                while (chains + (last - symoffset) * 4 + 4 <= size && !(elf_u(d + chains + (last - symoffset) * 4, 4) & 1)) last++;
                nsyms = last + 1;
            } else {
                nsyms = symoffset;
            }
        }
    }
    uint64_t sym = elf_offset(d, size, phoff, phnum, symtab);
    for (uint64_t i = 1; sym != (uint64_t)-1 && i < nsyms && sym + (i + 1) * syment <= size; i++) {
        const uint8_t *s = d + sym + i * syment;
        int bind = s[4] >> 4;
        uint64_t shndx = elf_u(s + 6, 2);
        if ((bind != 1 && bind != 2) || shndx == 0) continue;
        const char *name = elf_string(strings, strsz, elf_u(s, 4));
        if (name && *name) elf_push(&f.symbols, &f.nsymbols, name);
    }
    f.ok = 1;
    return f;
}

#undef ELF_FAIL

static inline int elf_has(char **list, size_t n, const char *s) {
    for (size_t i = 0; i < n; i++)
        if (!strcmp(list[i], s)) return 1;
    return 0;
}

#endif
