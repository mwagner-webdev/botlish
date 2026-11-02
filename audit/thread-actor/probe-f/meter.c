/* meter.c -- Probe F helper (THREAD-ACTOR-ARCHITECTURE-CENSUS.md): the
 * process's virtual size and resident set, in KiB, from /proc/self/status. */
#include <stdio.h>
#include <string.h>

static long long field(const char *name) {
    FILE *f = fopen("/proc/self/status", "r");
    char line[256];
    long long v = -1;
    size_t n = strlen(name);
    if (!f) return -1;
    while (fgets(line, sizeof line, f)) {
        if (strncmp(line, name, n) == 0) { sscanf(line + n, "%lld", &v); break; }
    }
    fclose(f);
    return v;
}

long long meter_rss_kb(void) { return field("VmRSS:"); }
long long meter_vm_kb(void) { return field("VmSize:"); }
