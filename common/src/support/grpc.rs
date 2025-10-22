use log::error;
use tonic::Status;

/// Log internal errors and return a sanitized gRPC status that does not expose internals to clients.
#[track_caller]
pub fn internal_error<E>(err: E) -> Status
where
    E: std::fmt::Debug,
{
    let location = std::panic::Location::caller();
    error!(
        "gRPC internal error at {}:{} - {:?}",
        location.file(),
        location.line(),
        err
    );
    Status::internal("internal server error")
}
