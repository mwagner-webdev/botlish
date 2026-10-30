/*
 * raven_bridge.c -- the event bridge of the Raven package
 * (packages/raven, RAVEN-BINDINGS.md "The event bridge").
 *
 * Raven reports everything that happens -- a click, a changed value, an
 * action, a window asking to close, a timer, an error -- by calling a C
 * function the application registered. Botlish cannot give C a function to
 * call (no Botlish function is a C function pointer: C-FFI.md, "Not here"),
 * so this file is the one place C code runs for the Botlish program: its
 * callbacks copy what each one is given into records of a queue (scalars
 * and a private copy of any text), and the program takes the records out
 * when the frame it asked for returns. Nothing here calls Botlish, keeps a
 * pointer Raven gave it past the callback, or decides anything for the
 * program but the one answer a callback must give at once (whether a
 * window may close: the policy the program stated when it watched it).
 *
 * Every function is for the UI thread (the thread that called Rinit), as
 * Raven's are; the queue is locked anyway, because Raven calls the error
 * callback on the thread that raised the error.
 *
 * The ABI (botlish_raven_bridge_abi, version 1): scalars and NUL-terminated
 * strings only. The text of the current record and every string the
 * program reads from Raven reach Botlish through botlish_raven_text_copy,
 * and a buffer of a size known only at run time (a captured frame) through
 * botlish_raven_bytes_copy: each copies bytes into storage the program
 * lends for that call.
 */
#include <Raven.h>

#include <pthread.h>
#include <stdlib.h>
#include <string.h>

#define BOTLISH_RAVEN_BRIDGE_ABI 1

/* The kinds of record. raven.bot's EventKind maps them one to one. */
enum {
    BR_NONE = 0,
    BR_CLICKED = 1,        /* a button or a menu item */
    BR_TOGGLED = 2,        /* a checkbox: value = checked */
    BR_VALUE = 3,          /* a slider or a spin box: number = value */
    BR_TEXT_CHANGED = 4,   /* a text input: text */
    BR_TEXT_COMMITTED = 5, /* a text input, Enter: text */
    BR_SELECTED = 6,       /* a combo box or a list view: value = index */
    BR_ACTIVATED = 7,      /* a list view row: value = index */
    BR_ACTION = 8,         /* an action fired: source = sender, text = name */
    BR_CLOSE = 9,          /* a window asked to close: value = allowed */
    BR_RESIZED = 10,       /* a window: value = width, extra = height */
    BR_TIMER = 11,         /* a timer elapsed: source = timer */
    BR_ERROR = 12          /* value = RError, extra = RSeverity, text = detail */
};

typedef struct {
    int kind;
    Rid source;
    int value;
    int extra;
    double number;
    char* text;            /* malloc'd, or NULL */
} br_record;

static pthread_mutex_t br_lock = PTHREAD_MUTEX_INITIALIZER;
static br_record* br_queue;      /* a ring of br_capacity records */
static size_t br_capacity;
static size_t br_head;           /* the oldest record */
static size_t br_count;
static br_record br_current;     /* the record botlish_raven_next took */
static size_t br_lost;           /* records no memory could hold */

static char* br_copy(const char* text) {
    size_t n;
    char* copy;
    if (!text) return NULL;
    n = strlen(text);
    copy = (char*)malloc(n + 1);
    if (copy) memcpy(copy, text, n + 1);
    return copy;
}

/* Appends a record (its text copied). Grows the ring; a record no memory
 * can hold is counted as lost, never written over another. */
static void br_push(int kind, Rid source, int value, int extra, double number, const char* text) {
    br_record r;
    r.kind = kind;
    r.source = source;
    r.value = value;
    r.extra = extra;
    r.number = number;
    r.text = br_copy(text);
    if (text && !r.text) {
        pthread_mutex_lock(&br_lock);
        br_lost++;
        pthread_mutex_unlock(&br_lock);
        return;
    }
    pthread_mutex_lock(&br_lock);
    if (br_count == br_capacity) {
        size_t capacity = br_capacity ? br_capacity * 2 : 64;
        br_record* grown = (br_record*)malloc(capacity * sizeof(br_record));
        size_t i;
        if (!grown) {
            br_lost++;
            pthread_mutex_unlock(&br_lock);
            free(r.text);
            return;
        }
        for (i = 0; i < br_count; i++) grown[i] = br_queue[(br_head + i) % br_capacity];
        free(br_queue);
        br_queue = grown;
        br_capacity = capacity;
        br_head = 0;
    }
    br_queue[(br_head + br_count) % br_capacity] = r;
    br_count++;
    pthread_mutex_unlock(&br_lock);
}

/* ---- The callbacks Raven calls. ---- */

static void br_clicked(Rid source, void* user_data) {
    (void)user_data;
    br_push(BR_CLICKED, source, 0, 0, 0.0, NULL);
}

static void br_toggled(Rid source, int checked, void* user_data) {
    (void)user_data;
    br_push(BR_TOGGLED, source, checked != 0, 0, 0.0, NULL);
}

static void br_slider(Rid source, float value, void* user_data) {
    (void)user_data;
    br_push(BR_VALUE, source, 0, 0, (double)value, NULL);
}

static void br_spin_box(Rid source, double value, void* user_data) {
    (void)user_data;
    br_push(BR_VALUE, source, 0, 0, value, NULL);
}

static void br_text_changed(Rid source, const char* text, void* user_data) {
    (void)user_data;
    br_push(BR_TEXT_CHANGED, source, 0, 0, 0.0, text ? text : "");
}

static void br_text_committed(Rid source, const char* text, void* user_data) {
    (void)user_data;
    br_push(BR_TEXT_COMMITTED, source, 0, 0, 0.0, text ? text : "");
}

static void br_selected(Rid source, int index, void* user_data) {
    (void)user_data;
    br_push(BR_SELECTED, source, index, 0, 0.0, NULL);
}

static void br_activated(Rid source, int index, void* user_data) {
    (void)user_data;
    br_push(BR_ACTIVATED, source, index, 0, 0.0, NULL);
}

static void br_action(Rid sender, const char* action, void* user_data) {
    (void)user_data;
    br_push(BR_ACTION, sender, 0, 0, 0.0, action ? action : "");
}

/* The answer is the program's policy for this window, given when it was
 * watched (user_data: 1 lets it close, 0 keeps it open). */
static int br_close(Rid window, void* user_data) {
    int allowed = user_data != NULL;
    br_push(BR_CLOSE, window, allowed, 0, 0.0, NULL);
    return allowed ? R_TRUE : R_FALSE;
}

static void br_resized(Rid window, int width, int height, void* user_data) {
    (void)user_data;
    br_push(BR_RESIZED, window, width, height, 0.0, NULL);
}

static void br_timer(Rid timer, void* user_data) {
    (void)user_data;
    br_push(BR_TIMER, timer, 0, 0, 0.0, NULL);
}

static void br_error(RError code, RSeverity severity, const char* detail) {
    br_push(BR_ERROR, R_INVALID_ID, (int)code, (int)severity, 0.0, detail ? detail : "");
}

/* ---- Registration: the program names what it wants to hear about. ---- */

int botlish_raven_bridge_abi(void) {
    return BOTLISH_RAVEN_BRIDGE_ABI;
}

/* Errors, from now on (before Rinit too, to see its errors). */
void botlish_raven_watch_errors(void) {
    Rerror_set_callback(br_error);
}

/* Every action no Raction_bind names (actions of XML interfaces). */
void botlish_raven_watch_actions(void) {
    Raction_set_default_handler(br_action, NULL);
}

void botlish_raven_bind_action(const char* name) {
    Raction_bind(name, br_action, NULL);
}

void botlish_raven_watch_button(Rid button) {
    Rbutton_set_clicked_callback(button, br_clicked, NULL);
}

void botlish_raven_watch_menu_item(Rid item) {
    Rmenu_item_set_clicked_callback(item, br_clicked, NULL);
}

void botlish_raven_watch_checkbox(Rid checkbox) {
    Rcheckbox_set_changed_callback(checkbox, br_toggled, NULL);
}

void botlish_raven_watch_slider(Rid slider) {
    Rslider_set_changed_callback(slider, br_slider, NULL);
}

void botlish_raven_watch_spin_box(Rid spin_box) {
    Rspin_box_set_changed_callback(spin_box, br_spin_box, NULL);
}

void botlish_raven_watch_text_input(Rid text_input) {
    Rtext_input_set_changed_callback(text_input, br_text_changed, NULL);
    Rtext_input_set_committed_callback(text_input, br_text_committed, NULL);
}

void botlish_raven_watch_combo_box(Rid combo_box) {
    Rcombo_box_set_changed_callback(combo_box, br_selected, NULL);
}

void botlish_raven_watch_list_view(Rid list_view) {
    Rlist_view_set_selection_changed_callback(list_view, br_selected, NULL);
    Rlist_view_set_activated_callback(list_view, br_activated, NULL);
}

/* A window's close requests and resizes; ALLOW_CLOSE is the answer every
 * close request gets (R_FALSE keeps the window open: the program closes it
 * itself, Rwindow_destroy, when it has decided). */
void botlish_raven_watch_window(Rid window, int allow_close) {
    Rwindow_set_close_callback(window, br_close, allow_close ? (void*)1 : NULL);
    Rwindow_set_resize_callback(window, br_resized, NULL);
}

/* A timer whose every tick is a record: Rtimer_create's own handle. */
Rid botlish_raven_timer(double interval_seconds, int repeat) {
    return Rtimer_create(interval_seconds, repeat, br_timer, NULL);
}

/* ---- The queue, read by the program. ---- */

/* Takes the oldest record as the current one (the previous current
 * record's text is released): its kind, BR_NONE when the queue is empty. */
int botlish_raven_next(void) {
    pthread_mutex_lock(&br_lock);
    free(br_current.text);
    memset(&br_current, 0, sizeof br_current);
    if (br_count) {
        br_current = br_queue[br_head];
        br_head = (br_head + 1) % br_capacity;
        br_count--;
    }
    pthread_mutex_unlock(&br_lock);
    return br_current.kind;
}

Rid botlish_raven_source(void) { return br_current.kind ? br_current.source : R_INVALID_ID; }
int botlish_raven_value(void) { return br_current.value; }
int botlish_raven_extra(void) { return br_current.extra; }
double botlish_raven_number(void) { return br_current.number; }

/* The current record's text ("" when it has none), valid until the next
 * botlish_raven_next. */
const char* botlish_raven_text(void) { return br_current.text ? br_current.text : ""; }

size_t botlish_raven_pending(void) {
    size_t n;
    pthread_mutex_lock(&br_lock);
    n = br_count;
    pthread_mutex_unlock(&br_lock);
    return n;
}

size_t botlish_raven_lost(void) {
    size_t n;
    pthread_mutex_lock(&br_lock);
    n = br_lost;
    pthread_mutex_unlock(&br_lock);
    return n;
}

/* Releases every record (Rshutdown's companion: the program's handles are
 * gone, and so is what was said about them). */
void botlish_raven_clear(void) {
    pthread_mutex_lock(&br_lock);
    while (br_count) {
        free(br_queue[br_head].text);
        br_head = (br_head + 1) % br_capacity;
        br_count--;
    }
    free(br_queue);
    br_queue = NULL;
    br_capacity = 0;
    br_head = 0;
    free(br_current.text);
    memset(&br_current, 0, sizeof br_current);
    pthread_mutex_unlock(&br_lock);
}

/* ---- Strings. ---- */

/* The length in bytes of TEXT (a NUL-terminated string Raven or the bridge
 * returned; 0 for NULL). */
size_t botlish_raven_text_length(const char* text) {
    return text ? strlen(text) : 0;
}

/* Copies the COUNT bytes at DATA (a buffer Raven returned, such as
 * Rwindow_capture's pixels, at least COUNT bytes long) into OUT; returns
 * COUNT (0 for a null DATA). Botlish reads native memory through layouts,
 * whose sizes are fixed when the program is compiled: a buffer whose size
 * Raven reports at run time is copied here. */
size_t botlish_raven_bytes_copy(const unsigned char* data, unsigned char* out, size_t count) {
    if (!data || !count) return 0;
    memcpy(out, data, count);
    return count;
}

/* Copies TEXT's first CAPACITY bytes (fewer when it is shorter; no NUL)
 * into OUT; returns how many it copied. */
size_t botlish_raven_text_copy(const char* text, char* out, size_t capacity) {
    size_t n = text ? strlen(text) : 0;
    if (n > capacity) n = capacity;
    if (n) memcpy(out, text, n);
    return n;
}
