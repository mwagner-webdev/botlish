//! WASM-ARCH PROTOTYPE (experiment W3): a request-invoked wasi:http handler.
//! A module-level counter shows whether the host keeps an instance between
//! requests (the host owns dispatch and instance lifetime, not the guest).
use wasi::http::types::{Fields, IncomingRequest, OutgoingBody, OutgoingResponse, ResponseOutparam};
static mut REQUESTS: u32 = 0;
struct Handler;
wasi::http::proxy::export!(Handler);
impl wasi::exports::http::incoming_handler::Guest for Handler {
    fn handle(_request: IncomingRequest, out: ResponseOutparam) {
        let n = unsafe { REQUESTS += 1; REQUESTS };
        let response = OutgoingResponse::new(Fields::new());
        let body = response.body().unwrap();
        ResponseOutparam::set(out, Ok(response));
        let stream = body.write().unwrap();
        stream.blocking_write_and_flush(format!("requests seen by this instance: {n}\n").as_bytes()).unwrap();
        drop(stream);
        OutgoingBody::finish(body, None).unwrap();
    }
}
