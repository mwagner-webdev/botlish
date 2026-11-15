fn main() {
    std::fs::write("wasi_snapshot_preview1.command.wasm", wasi_preview1_component_adapter_provider::WASI_SNAPSHOT_PREVIEW1_COMMAND_ADAPTER).unwrap();
    std::fs::write("wasi_snapshot_preview1.reactor.wasm", wasi_preview1_component_adapter_provider::WASI_SNAPSHOT_PREVIEW1_REACTOR_ADAPTER).unwrap();
}
