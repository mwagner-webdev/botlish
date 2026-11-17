//! What a target's Botlish runtime provides that generated code is shaped by
//! (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, "Emitting is not
//! running"; WASM-RESUMABLE-COROUTINES-SHADOW-ROOTS-MILESTONE-1.md): every
//! decision of code generation and of NIR's call effects that depends on the
//! runtime reads one `RuntimeCapabilities` value -- today this driver's own
//! runtime's (`host`), and a target's for code emitted for it
//! (codegen::target's `runtime_capabilities`) -- never the runtime's
//! constants directly.

/// Where a Botlish frame's GC roots are kept (codegen::roots).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RootMode {
    /// Stack maps and the frame walk (runtime::framewalk's
    /// NATIVE_FRAME_ROOTS): a function's root slots are in its own native
    /// frame, found by walking the machine stack.
    NativeFrame,
    /// One LIFO shadow stack per Vm (the `fallback-roots` build, and
    /// WebAssembly): every function with a root slot reserves its frame
    /// there -- leaf or not, nothing published anywhere else -- and pops it
    /// on every exit. `depth_token`: a function with a Botlish call reserves
    /// one slot even with no root, because nothing but the shadow array's
    /// end bounds the recursion (a host without the stack guard).
    ShadowOnly { depth_token: bool },
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct RuntimeCapabilities {
    /// GC roots in native frames (stack maps and the frame walk).
    pub frame_roots: bool,
    /// An exhausted native stack is the guard's NATIVE LIMIT STACK
    /// (runtime::native_stack's `native_stack_overflow_supported`).
    pub stack_guard: bool,
    /// Coroutines switch stacks (runtime::coroutine's STACK_SWITCHING).
    pub stack_switching: bool,
    /// Coroutines run as resumable state machines over heap frames
    /// (runtime::resumable's RESUMABLE; codegen::resumable lowers them).
    pub resumable: bool,
}

impl RuntimeCapabilities {
    /// This build's own runtime.
    pub const fn host() -> RuntimeCapabilities {
        RuntimeCapabilities {
            frame_roots: super::framewalk::NATIVE_FRAME_ROOTS,
            stack_guard: super::native_stack::native_stack_overflow_supported(),
            stack_switching: super::coroutine::STACK_SWITCHING,
            resumable: super::resumable::RESUMABLE,
        }
    }

    /// Where generated code keeps its GC roots.
    pub const fn root_mode(self) -> RootMode {
        if self.frame_roots { RootMode::NativeFrame } else { RootMode::ShadowOnly { depth_token: !self.stack_guard } }
    }

    /// Whether a general coroutine mechanism runs every coroutine: stack
    /// switching or resumable frames. Coroutine fusion (codegen::fusion)
    /// runs exactly where one does, so fusing never makes a program run that
    /// the general mechanism would refuse (AGENTS.md, "Coroutine fusion").
    pub const fn coroutines(self) -> bool {
        self.stack_switching || self.resumable
    }

    /// Whether a function's prologue can fail with NATIVE LIMIT STACK, so
    /// that its callers check (nir's call effects): only where the shadow
    /// stack's end is the only bound on recursion -- no stack guard. Where
    /// the guard exists, an exhausted stack is terminal on every root plan:
    /// the guard's fault, or a full shadow array reported the same way
    /// (runtime::ops's `rt_shadow_overflow`).
    pub const fn prologue_may_fail(self) -> bool {
        !self.stack_guard
    }
}

const _: () = {
    let host = RuntimeCapabilities::host();
    assert!(host.stack_switching != host.resumable, "exactly one general coroutine mechanism per runtime");
    assert!(!host.frame_roots || host.stack_guard, "native-frame GC roots need the native stack guard");
};

#[cfg(test)]
mod tests {
    use super::*;

    /// The fallback-roots build is the resumable, ShadowOnly runtime; every
    /// other build of a supported host the stackful, native-frame one.
    #[test]
    fn the_host_runtime_is_one_of_the_two_shapes() {
        let host = RuntimeCapabilities::host();
        assert!(host.coroutines());
        if cfg!(feature = "fallback-roots") {
            assert!(host.resumable && !host.stack_switching);
            assert_eq!(host.root_mode(), RootMode::ShadowOnly { depth_token: !host.stack_guard });
        }
        if host.frame_roots {
            assert_eq!(host.root_mode(), RootMode::NativeFrame);
            assert!(!host.prologue_may_fail());
        }
    }
}
