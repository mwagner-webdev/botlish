/* sdl_main.c -- the SDL_main of an Android SDL3 application whose entry is a
 * Botlish application library (RN-HOST-STARTABLE-APPLICATION-LIBRARY-
 * MILESTONE-1.md, "Android AArch64 artifacts"): SDLActivity loads
 * libSDL3.so and libmain.so and, on its "SDLThread", calls nativeRunMain,
 * which dlsym()s SDL_main here and runs it through SDL_RunApp
 * (SDL_android.c). It passes its arguments to the library's NAME_main,
 * which runs the application's entry program on this thread to its end,
 * and reports a failure to Android's log. It holds no application logic,
 * installs no Botlish context and keeps no handle: the shape the external
 * Android package generates.
 *
 *   NDK clang --target=aarch64-linux-android21 -shared -fPIC \
 *       -DAPP_HEADER='"icy.h"' -DAPP_PREFIX=icy sdl_main.c -licy -lSDL3 -llog */
#include <android/log.h>
#include <stdint.h>
#include APP_HEADER

#define JOIN(a, b) a##_##b
#define NAME(a, b) JOIN(a, b)
#define APP(suffix) NAME(APP_PREFIX, suffix)

__attribute__((visibility("default"))) int SDL_main(int argc, char *argv[]) {
    APP(error) *error = NULL;
    if (APP(main)(argc, argv, &error) != APP(STATUS_OK)) {
        const uint8_t *identity = NULL, *message = NULL;
        size_t identity_len = 0, message_len = 0;
        APP(error_identity)(error, &identity, &identity_len);
        APP(error_message)(error, &message, &message_len);
        __android_log_print(ANDROID_LOG_ERROR, "Botlish", "the application failed: %.*s: %.*s",
                            (int)identity_len, (const char *)identity, (int)message_len, (const char *)message);
        APP(error_release)(&error);
        return 1;
    }
    return 0;
}
