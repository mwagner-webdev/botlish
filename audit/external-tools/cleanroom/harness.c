/* harness.c -- a JavaScript-like host of the hostgen package's generated
 * adapter (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md,
 * experiment E): it plays the 2048 game whose steps standard input holds
 * ("DIRECTION TILE" per line) through the adapter's host values, then makes
 * the calls whose host errors it prints. tests/external-tools.test and the
 * clean room (cleanroom.sh) build it against a generated module. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "game_host.h"

static char state[512];

static void show(const char *what, hv_result *r) {
    if (r->failed) printf("%s %s %s\n", what, r->error, r->code);
    else if (r->value.kind == HV_STRING) { printf("%s %.*s\n", what, (int)r->value.length, r->value.text); snprintf(state, sizeof state, "%.*s", (int)r->value.length, r->value.text); }
    else if (r->value.kind == HV_NUMBER) printf("%s %.17g\n", what, r->value.number);
    else if (r->value.kind == HV_BOOLEAN) printf("%s %s\n", what, r->value.boolean ? "true" : "false");
    game_host_result_release(r);
}

static hv_value str(const char *s) { hv_value v = {HV_STRING, 0, 0, s, strlen(s)}; return v; }
static hv_value num(double d) { hv_value v = {HV_NUMBER, d, 0, NULL, 0}; return v; }

int main(void) {
    game_host *h;
    char message[256];
    if (game_host_open(&h, message, sizeof message)) { printf("open failed %s\n", message); return 1; }
    hv_result r;
    hv_value a[4];
    game_host_call(h, "newGame", NULL, 0, &r); show("state", &r);
    a[0] = str(state); a[1] = num(2); game_host_call(h, "spawnFirst", a, 2, &r); show("state", &r);
    a[0] = str(state); a[1] = num(4); game_host_call(h, "spawnFirst", a, 2, &r); show("state", &r);
    int d, t;
    while (scanf("%d %d", &d, &t) == 2) {
        a[0] = str(state); a[1] = num(d); game_host_call(h, "move", a, 2, &r); show("state", &r);
        a[0] = str(state); a[1] = num(t); game_host_call(h, "spawnFirst", a, 2, &r); show("state", &r);
    }
    a[0] = str(state); game_host_call(h, "score", a, 1, &r); show("score", &r);
    a[0] = str("not a state"); a[1] = num(0); game_host_call(h, "move", a, 2, &r); show("move", &r);
    a[0] = num(1); a[1] = num(0); game_host_call(h, "move", a, 2, &r); show("move", &r);
    a[0] = str(state); a[1] = num(1.5); game_host_call(h, "move", a, 2, &r); show("move", &r);
    a[0] = str(state); a[1] = num(9007199254740993.0); game_host_call(h, "move", a, 2, &r); show("move", &r);
    a[0] = str(state); game_host_call(h, "move", a, 1, &r); show("move", &r);
    game_host_call(h, "eval", NULL, 0, &r); show("eval", &r);
    game_host_close(h);
    return 0;
}
