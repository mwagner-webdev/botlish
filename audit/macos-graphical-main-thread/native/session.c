/* session.c -- what graphical session this process has
 * (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md, section 4), asked of
 * CoreGraphics before any window is attempted: the login session
 * (CGSessionCopyCurrentDictionary: none without a WindowServer session),
 * whether it is on the console, the displays, and whether this process may
 * capture the screen (CGPreflightScreenCaptureAccess: asks, never prompts).
 * One "MTP" line on standard error. */
#include <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

static int flag(CFDictionaryRef d, CFStringRef key) {
    if (!d) return -1;
    CFBooleanRef v = CFDictionaryGetValue(d, key);
    return v ? CFBooleanGetValue(v) : -1;
}

int main(void) {
    CFDictionaryRef session = CGSessionCopyCurrentDictionary();
    char user[256] = "";
    if (session) {
        CFStringRef name = CFDictionaryGetValue(session, kCGSessionUserNameKey);
        if (name) CFStringGetCString(name, user, sizeof user, kCFStringEncodingUTF8);
    }
    uint32_t displays = 0;
    CGGetActiveDisplayList(0, NULL, &displays);
    CGDirectDisplayID main = CGMainDisplayID();
    fprintf(stderr, "MTP {\"kind\":\"session\",\"session\":%d,\"on_console\":%d,\"login_done\":%d,\"user\":\"%s\","
            "\"active_displays\":%u,\"main_display_width\":%zu,\"main_display_height\":%zu,\"screen_capture_access\":%d}\n",
            session != NULL, flag(session, kCGSessionOnConsoleKey), flag(session, kCGSessionLoginDoneKey), user,
            displays, CGDisplayPixelsWide(main), CGDisplayPixelsHigh(main), (int)CGPreflightScreenCaptureAccess());
    if (session) CFRelease(session);
    return 0;
}
