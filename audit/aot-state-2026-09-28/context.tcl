# Supply the dependency context required by these two standalone fixtures.
source compiler/compiler.tcl
source surface/surface.tcl
lassign $argv setup mode
switch -- $setup {
    ascii {
        # ascii.bot documents that Byte must already have been registered.
        surface::readProgramFile lib/byte.bot
        set argv [list $mode lib/ascii.bot]
    }
    fixtures {
        set ::core::libraryDir [file normalize audit/post-native-stack/module-cases]
        set argv [list $mode audit/post-native-stack/module-cases/main.bot]
    }
    default { error "unknown setup: $setup" }
}
source main.tcl
