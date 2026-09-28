//! Runtime shared by the JIT driver and statically linked AOT executables.
//! No code generator is linked into an executable through this library.
pub mod nir;
pub mod runtime;
