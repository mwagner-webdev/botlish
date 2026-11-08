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
 * The ABI (botlish_raven_bridge_abi, version 2): scalars and NUL-terminated
 * strings only. The text of the current record and every string the
 * program reads from Raven reach Botlish through botlish_raven_text_copy,
 * and a buffer of a size known only at run time (a captured frame) through
 * botlish_raven_bytes_copy: each copies bytes into storage the program
 * lends for that call. Every number a record holds is finite: Botlish's
 * Float64 has no NaN or infinity, and a record that would carry one says
 * so instead (BR_VALUE's value 1).
 *
 * Version 2 adds raw input: a window the program watches for input
 * (botlish_raven_watch_input) has its event hook here, which records keys,
 * mouse buttons, pointer moves and the wheel and never consumes an event,
 * so Raven handles every one exactly as it would without the hook.
 */
#include <Raven.h>

#include <math.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>

#define BOTLISH_RAVEN_BRIDGE_ABI 2

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
    BR_ERROR = 12,         /* value = RError, extra = RSeverity, text = detail */
    /* Raw input of a window watched for it (source = the window; x, y =
     * the pointer, in the window's logical units; extra = the modifiers). */
    BR_KEY_PRESSED = 13,   /* value = RKey, the first press */
    BR_KEY_REPEATED = 14,  /* value = RKey, an auto-repeat while held */
    BR_KEY_RELEASED = 15,  /* value = RKey */
    BR_MOUSE_PRESSED = 16, /* value = RMouseButton */
    BR_MOUSE_RELEASED = 17,/* value = RMouseButton */
    BR_MOUSE_MOVED = 18,   /* dx, dy = the movement (consecutive moves are one record) */
    BR_WHEEL = 19          /* dx, dy = the scroll, in lines (positive: left, up) */
};

typedef struct {
    int kind;
    Rid source;
    int value;
    int extra;
    double number;
    double x, y;           /* the pointer (raw input) */
    double dx, dy;         /* a move's movement, the wheel's scroll */
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

/* NUMBER, or 0.0 when it is no finite number (a record never holds one). */
static double br_finite(double number) {
    return isfinite(number) ? number : 0.0;
}

/* Appends R (its text already copied, or NULL). Grows the ring; a record no
 * memory can hold is counted as lost, never written over another. The
 * caller holds br_lock. */
static void br_append_locked(br_record r) {
    if (br_count == br_capacity) {
        size_t capacity = br_capacity ? br_capacity * 2 : 64;
        br_record* grown = (br_record*)malloc(capacity * sizeof(br_record));
        size_t i;
        if (!grown) {
            br_lost++;
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
}

/* Appends a record (its text copied). */
static void br_push(int kind, Rid source, int value, int extra, double number, const char* text) {
    br_record r;
    memset(&r, 0, sizeof r);
    r.kind = kind;
    r.source = source;
    r.value = value;
    r.extra = extra;
    r.number = br_finite(number);
    r.text = br_copy(text);
    if (text && !r.text) {
        pthread_mutex_lock(&br_lock);
        br_lost++;
        pthread_mutex_unlock(&br_lock);
        return;
    }
    pthread_mutex_lock(&br_lock);
    br_append_locked(r);
    pthread_mutex_unlock(&br_lock);
}

/* Appends a raw input record of WINDOW. A pointer move right after another
 * move of the same window with the same modifiers is merged into it (its
 * position the new one, its movement the sum): a program that drains the
 * queue once a frame sees one move per frame, never hundreds. */
static void br_push_input(int kind, Rid window, int value, int extra, double x, double y, double dx, double dy) {
    br_record r;
    memset(&r, 0, sizeof r);
    r.kind = kind;
    r.source = window;
    r.value = value;
    r.extra = extra;
    r.x = br_finite(x);
    r.y = br_finite(y);
    r.dx = br_finite(dx);
    r.dy = br_finite(dy);
    pthread_mutex_lock(&br_lock);
    if (kind == BR_MOUSE_MOVED && br_count) {
        br_record* last = &br_queue[(br_head + br_count - 1) % br_capacity];
        if (last->kind == BR_MOUSE_MOVED && last->source == window && last->extra == extra) {
            last->x = r.x;
            last->y = r.y;
            last->dx = br_finite(last->dx + r.dx);
            last->dy = br_finite(last->dy + r.dy);
            pthread_mutex_unlock(&br_lock);
            return;
        }
    }
    br_append_locked(r);
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

/* A spin box given an infinite range (raven.bot's set_spin_box_raw_range)
 * can hold an infinity: its record says so (value 1, number 0.0), and the
 * program reads the value itself (spin_box_raw_value). */
static void br_spin_box(Rid source, double value, void* user_data) {
    (void)user_data;
    br_push(BR_VALUE, source, isfinite(value) ? 0 : 1, 0, value, NULL);
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

/* A watched window's raw input, seen before its widgets. The answer is
 * always R_FALSE: the event is recorded, never consumed, so Raven goes on
 * to deliver it to its widgets, shortcuts and dialogs as it would without
 * the hook. Text (R_EVENT_TEXT) is a text input's TextChanged; focus and
 * enter/leave are not recorded. */
static int br_input(Rid window, const REvent* event, void* user_data) {
    (void)user_data;
    if (!event) return R_FALSE;
    switch (event->type) {
    case R_EVENT_KEY_DOWN:
        br_push_input(event->repeat ? BR_KEY_REPEATED : BR_KEY_PRESSED, window, (int)event->key,
            (int)event->modifiers, event->x, event->y, 0.0, 0.0);
        break;
    case R_EVENT_KEY_UP:
        br_push_input(BR_KEY_RELEASED, window, (int)event->key, (int)event->modifiers, event->x, event->y, 0.0, 0.0);
        break;
    case R_EVENT_MOUSE_DOWN:
        br_push_input(BR_MOUSE_PRESSED, window, (int)event->button, (int)event->modifiers, event->x, event->y, 0.0, 0.0);
        break;
    case R_EVENT_MOUSE_UP:
        br_push_input(BR_MOUSE_RELEASED, window, (int)event->button, (int)event->modifiers, event->x, event->y, 0.0, 0.0);
        break;
    case R_EVENT_MOUSE_MOVE:
        br_push_input(BR_MOUSE_MOVED, window, 0, (int)event->modifiers, event->x, event->y, event->delta_x, event->delta_y);
        break;
    case R_EVENT_MOUSE_WHEEL:
        br_push_input(BR_WHEEL, window, 0, (int)event->modifiers, event->x, event->y, event->wheel_x, event->wheel_y);
        break;
    default:
        break;
    }
    return R_FALSE;
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

/* WINDOW's raw input (keys, mouse buttons, pointer moves, the wheel) as
 * records, from now on; WATCH 0 stops it. */
void botlish_raven_watch_input(Rid window, int watch) {
    Rwindow_set_event_hook(window, watch ? br_input : NULL, NULL);
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
double botlish_raven_x(void) { return br_current.x; }
double botlish_raven_y(void) { return br_current.y; }
double botlish_raven_dx(void) { return br_current.dx; }
double botlish_raven_dy(void) { return br_current.dy; }

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
