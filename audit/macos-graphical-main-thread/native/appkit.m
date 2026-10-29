/* appkit.m -- AppKit without SDL (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md,
 * section 4): make an NSWindow directly on the calling thread, and report
 * whether AppKit allowed it or the exception it raised. csdl's appkit-main
 * and appkit-worker run it on the process's main thread and on a worker, so
 * that AppKit's own rule -- not SDL's, not a guess from an archived
 * document -- is what the census records. (Manual reference counting.)
 */
#import <AppKit/AppKit.h>
#include <stdio.h>

int mtp_appkit_window(char *reason, size_t size) {
    @autoreleasepool {
        @try {
            [NSApplication sharedApplication];
            NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 160, 120)
                                                           styleMask:NSWindowStyleMaskTitled
                                                             backing:NSBackingStoreBuffered
                                                               defer:NO];
            window.releasedWhenClosed = NO;
            snprintf(reason, size, "created windowNumber %ld", (long)window.windowNumber);
            [window close];
            [window release];
            return 1;
        } @catch (NSException *e) {
            snprintf(reason, size, "%s: %s", e.name.UTF8String, e.reason.UTF8String);
            return 0;
        }
    }
}
