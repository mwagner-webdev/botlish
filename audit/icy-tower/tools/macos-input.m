// macos-input.m -- the window system's side of the macOS Icy Tower
// acceptance (ICY-TOWER-MACOS-MILESTONE-1.md, "Keyboard input"; driven by
// macos-session.py): what a person at the Mac does, done from outside the
// game through macOS's own interfaces -- never by the game, never by SDL
// (no SDL_PushEvent, nothing in the game's process).
//
//   clang -fobjc-arc -framework AppKit -framework ApplicationServices \
//       -o macos-input macos-input.m
//
//   macos-input preflight              the permissions this process has:
//                                      posting events (CGPreflightPostEventAccess),
//                                      screen capture, Accessibility
//   macos-input frontmost              the active application
//   macos-input windows PID            PID's windows the WindowServer has
//                                      (CGWindowListCopyWindowInfo): id,
//                                      bounds in global points, on screen
//   macos-input activate PID           NSRunningApplication's activation
//   macos-input ax-raise PID           Accessibility: PID frontmost, its
//                                      first window raised and main
//   macos-input ax-close PID           Accessibility: press the close button
//                                      of PID's first window (the window's
//                                      own close request, as a click on it)
//   macos-input click X Y              a left click at the global point X, Y
//                                      (Quartz events, the HID tap)
//   macos-input key NAME down|up|tap [hid|session|pid:PID]
//                                      a key (left right a d r escape w q;
//                                      cmd+NAME with the Command key) posted
//                                      as a keyboard event (Quartz events:
//                                      the HID tap by default)
//   macos-input steal-focus SECONDS    an application window of this
//                                      process's own (top left), made key
//                                      and active for SECONDS: another
//                                      application takes the keyboard focus
//
// Every command prints one line of JSON and exits 0 when it did what it
// says, 1 otherwise (the JSON then says why), 2 on a usage error.
#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static void json(NSDictionary *d) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:d options:0 error:nil];
    printf("%.*s\n", (int)data.length, (const char *)data.bytes);
    fflush(stdout);
}

static NSDictionary *frontmost(void) {
    NSRunningApplication *a = [[NSWorkspace sharedWorkspace] frontmostApplication];
    return @{@"pid": @(a ? a.processIdentifier : -1), @"name": a.localizedName ?: @"", @"bundle": a.bundleIdentifier ?: @""};
}

static int keycode(const char *name) {
    static const struct { const char *name; int code; } keys[] = {
        {"left", 123}, {"right", 124}, {"up", 126}, {"down", 125}, {"a", 0}, {"d", 2}, {"r", 15},
        {"escape", 53}, {"w", 13}, {"q", 12}, {"space", 49},
    };
    for (size_t i = 0; i < sizeof keys / sizeof keys[0]; i++)
        if (!strcmp(keys[i].name, name)) return keys[i].code;
    return -1;
}

static AXUIElementRef first_window(pid_t pid, AXError *error) {
    AXUIElementRef app = AXUIElementCreateApplication(pid);
    CFArrayRef windows = NULL;
    *error = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute, (CFTypeRef *)&windows);
    CFRelease(app);
    if (*error != kAXErrorSuccess || !windows) return NULL;
    AXUIElementRef w = NULL;
    if (CFArrayGetCount(windows) > 0) w = (AXUIElementRef)CFRetain(CFArrayGetValueAtIndex(windows, 0));
    CFRelease(windows);
    return w;
}

static void post_mouse(CGEventType type, CGPoint p) {
    CGEventRef e = CGEventCreateMouseEvent(NULL, type, p, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, e);
    CFRelease(e);
}

int main(int argc, char **argv) {
    @autoreleasepool {
        if (argc < 2) { fprintf(stderr, "usage: macos-input COMMAND ...\n"); return 2; }
        const char *cmd = argv[1];
        if (!strcmp(cmd, "preflight")) {
            NSDictionary *trusted = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @NO};
            json(@{@"post_event": @(CGPreflightPostEventAccess()), @"listen_event": @(CGPreflightListenEventAccess()),
                   @"screen_capture": @(CGPreflightScreenCaptureAccess()),
                   @"accessibility": @(AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)trusted)),
                   @"frontmost": frontmost(), @"pid": @(getpid()),
                   @"screens": @([[NSScreen screens] count]),
                   @"main_screen": [NSScreen mainScreen] ? @{
                       @"width": @([NSScreen mainScreen].frame.size.width), @"height": @([NSScreen mainScreen].frame.size.height),
                       @"scale": @([NSScreen mainScreen].backingScaleFactor)} : @{}});
            return 0;
        }
        if (!strcmp(cmd, "frontmost")) { json(frontmost()); return 0; }
        if (!strcmp(cmd, "windows") && argc == 3) {
            pid_t pid = atoi(argv[2]);
            NSArray *all = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID));
            NSMutableArray *mine = [NSMutableArray array];
            for (NSDictionary *w in all) {
                if ([w[(__bridge NSString *)kCGWindowOwnerPID] intValue] != pid) continue;
                NSDictionary *b = w[(__bridge NSString *)kCGWindowBounds];
                [mine addObject:@{@"id": w[(__bridge NSString *)kCGWindowNumber],
                                  @"layer": w[(__bridge NSString *)kCGWindowLayer] ?: @0,
                                  @"onscreen": w[(__bridge NSString *)kCGWindowIsOnscreen] ?: @NO,
                                  @"alpha": w[(__bridge NSString *)kCGWindowAlpha] ?: @0,
                                  @"x": b[@"X"] ?: @0, @"y": b[@"Y"] ?: @0, @"w": b[@"Width"] ?: @0, @"h": b[@"Height"] ?: @0}];
            }
            json(@{@"pid": @(pid), @"windows": mine});
            return 0;
        }
        if (!strcmp(cmd, "activate") && argc == 3) {
            NSRunningApplication *a = [NSRunningApplication runningApplicationWithProcessIdentifier:atoi(argv[2])];
            BOOL ok = a ? [a activateWithOptions:NSApplicationActivateAllWindows] : NO;
            usleep(300000);
            json(@{@"requested": @(ok), @"frontmost": frontmost()});
            return ok ? 0 : 1;
        }
        if (!strcmp(cmd, "ax-raise") && argc == 3) {
            pid_t pid = atoi(argv[2]);
            AXUIElementRef app = AXUIElementCreateApplication(pid);
            AXError front = AXUIElementSetAttributeValue(app, kAXFrontmostAttribute, kCFBooleanTrue);
            CFRelease(app);
            AXError werr, raise = kAXErrorFailure, main = kAXErrorFailure;
            AXUIElementRef w = first_window(pid, &werr);
            if (w) {
                raise = AXUIElementPerformAction(w, kAXRaiseAction);
                main = AXUIElementSetAttributeValue(w, kAXMainAttribute, kCFBooleanTrue);
                CFRelease(w);
            }
            usleep(300000);
            json(@{@"frontmost_error": @(front), @"windows_error": @(werr), @"raise_error": @(raise), @"main_error": @(main),
                   @"frontmost": frontmost()});
            return front == kAXErrorSuccess ? 0 : 1;
        }
        if (!strcmp(cmd, "ax-close") && argc == 3) {
            AXError werr, berr = kAXErrorFailure, press = kAXErrorFailure;
            AXUIElementRef w = first_window(atoi(argv[2]), &werr);
            if (w) {
                AXUIElementRef button = NULL;
                berr = AXUIElementCopyAttributeValue(w, kAXCloseButtonAttribute, (CFTypeRef *)&button);
                if (berr == kAXErrorSuccess && button) {
                    press = AXUIElementPerformAction(button, kAXPressAction);
                    CFRelease(button);
                }
                CFRelease(w);
            }
            json(@{@"windows_error": @(werr), @"button_error": @(berr), @"press_error": @(press)});
            return press == kAXErrorSuccess ? 0 : 1;
        }
        if (!strcmp(cmd, "click") && argc == 4) {
            CGPoint p = CGPointMake(atof(argv[2]), atof(argv[3]));
            post_mouse(kCGEventMouseMoved, p);
            usleep(50000);
            post_mouse(kCGEventLeftMouseDown, p);
            usleep(60000);
            post_mouse(kCGEventLeftMouseUp, p);
            usleep(300000);
            json(@{@"x": @(p.x), @"y": @(p.y), @"frontmost": frontmost()});
            return 0;
        }
        if (!strcmp(cmd, "key") && (argc == 4 || argc == 5)) {
            const char *name = argv[2];
            CGEventFlags flags = 0;
            if (!strncmp(name, "cmd+", 4)) { flags = kCGEventFlagMaskCommand; name += 4; }
            int code = keycode(name);
            const char *action = argv[3];
            const char *mode = argc == 5 ? argv[4] : "hid";
            if (code < 0 || (strcmp(action, "down") && strcmp(action, "up") && strcmp(action, "tap"))) {
                fprintf(stderr, "usage: macos-input key NAME down|up|tap [hid|session|pid:PID]\n");
                return 2;
            }
            int downs[2] = {!strcmp(action, "up") ? 0 : 1, !strcmp(action, "tap") ? 0 : -1};
            for (int i = 0; i < 2; i++) {
                if (downs[i] < 0) break;
                CGEventRef e = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)code, downs[i] == 1);
                if (flags) CGEventSetFlags(e, flags);
                if (!strncmp(mode, "pid:", 4)) CGEventPostToPid(atoi(mode + 4), e);
                else CGEventPost(!strcmp(mode, "session") ? kCGSessionEventTap : kCGHIDEventTap, e);
                CFRelease(e);
                if (i == 0 && downs[1] == 0) usleep(80000);
            }
            json(@{@"key": @(argv[2]), @"code": @(code), @"action": @(action), @"mode": @(mode),
                   @"post_event": @(CGPreflightPostEventAccess())});
            return 0;
        }
        if (!strcmp(cmd, "steal-focus") && argc == 3) {
            double seconds = atof(argv[2]);
            [NSApplication sharedApplication];
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
            NSRect frame = NSMakeRect(0, [NSScreen mainScreen].frame.size.height - 160, 180, 120);
            NSWindow *w = [[NSWindow alloc] initWithContentRect:frame
                                                      styleMask:NSWindowStyleMaskTitled
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
            w.title = @"focus";
            [w makeKeyAndOrderFront:nil];
            [NSApp activateIgnoringOtherApps:YES];
            [NSApp finishLaunching];
            NSDate *until = [NSDate dateWithTimeIntervalSinceNow:seconds];
            BOOL active = NO, printed = NO;
            while ([until timeIntervalSinceNow] > 0) {
                NSEvent *e = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]
                                                   inMode:NSDefaultRunLoopMode dequeue:YES];
                if (e) [NSApp sendEvent:e];
                if (!printed) {
                    // Where the window is (global points, top left origin), for a click on it.
                    NSRect f = w.frame;
                    CGFloat top = [NSScreen mainScreen].frame.size.height - (f.origin.y + f.size.height);
                    json(@{@"event": @"ready", @"pid": @(getpid()), @"window": @(w.windowNumber),
                           @"x": @(f.origin.x), @"y": @(top), @"w": @(f.size.width), @"h": @(f.size.height)});
                    printed = YES;
                }
                active = active || NSApp.active;
            }
            json(@{@"event": @"done", @"was_active": @(active), @"frontmost": frontmost()});
            return 0;
        }
        fprintf(stderr, "usage: macos-input preflight|frontmost|windows PID|activate PID|ax-raise PID|ax-close PID|click X Y|key NAME ACTION [MODE]|steal-focus SECONDS\n");
        return 2;
    }
}
