/* Probe E's Android bootstrap
 * (ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md): the whole
 * native host an SDL3 Android application of Botlish needs, given an entry
 * that can be started from C. SDLActivity loads libSDL3.so and libmain.so
 * (getLibraries) and, on its "SDLThread", calls nativeRunMain, which
 * dlsym()s SDL_main in libmain.so and runs it through SDL_RunApp
 * (SDL_android.c). This SDL_main starts the Botlish entry computation
 * (libicy.so's create, standing in for the proposed NAME_main) on that
 * thread, waits for it to end, and reports a failure to Android's log. It
 * holds no game logic, installs no Botlish context and never enters the
 * instance again. */
#include <android/log.h>
#include <stdint.h>
#include "icy.h"

__attribute__((visibility("default"))) int SDL_main(int argc, char *argv[]) {
    (void)argc; (void)argv;
    icy_instance *instance = NULL;
    icy_error *error = NULL;
    if (icy_create(&instance, &error) != 0) {
        const uint8_t *identity = NULL, *message = NULL;
        size_t identity_len = 0, message_len = 0;
        icy_error_identity(error, &identity, &identity_len);
        icy_error_message(error, &message, &message_len);
        __android_log_print(ANDROID_LOG_ERROR, "Botlish", "the application failed: %.*s: %.*s",
                            (int)identity_len, (const char *)identity, (int)message_len, (const char *)message);
        icy_error_release(&error);
        return 1;
    }
    return icy_destroy(instance) == 0 ? 0 : 1;
}
