/*
 * host_main.c -- a hosted test harness for a program the Botlish C backend
 * generated (C-COMPILE-FREESTANDING-MILESTONE-1.md, "Entry points and
 * embedding"). It is not part of the program: it runs it the way main.tcl
 * shows a run, on a desktop with a C library, and prints
 *
 *     value: TEXT              the program's value, as Botlish displays it
 *     error: MESSAGE (CODE)    the error the run ended in (exit status 1)
 *
 * Build it with the program, its display unit and any providers:
 *
 *     cc -std=c11 -DBOTLISH_PROGRAM=fact -DBOTLISH_PROGRAM_HEADER='"fact.h"' \
 *        -I OUT host_main.c OUT/fact.c OUT/fact_display.c [PROVIDER.c...]
 */
#include <stdio.h>
#include <stdlib.h>

#include BOTLISH_PROGRAM_HEADER

#define BOTLISH_CAT2(a, b) a##b
#define BOTLISH_CAT(a, b) BOTLISH_CAT2(a, b)
#define P(name) BOTLISH_CAT(BOTLISH_PROGRAM, name)

int main(void)
{
    P(_value) value;
    P(_status) status = P(_run)(&value);
    size_t length;
    char *text;
    if (status != P(_OK)) {
        printf("error: %s (%s)\n", P(_status_message)(status), P(_status_code)(status));
        return 1;
    }
    length = P(_show)(&value, NULL, 0);
    text = malloc(length + 1);
    if (text == NULL) {
        fputs("host_main: out of memory\n", stderr);
        return 2;
    }
    P(_show)(&value, text, length);
    printf("value: %.*s\n", (int)length, text);
    free(text);
    return 0;
}
