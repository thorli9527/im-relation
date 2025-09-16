//! msg_friend server module (aligned with app_socket/server style)

pub mod server_grpc;

pub use server_grpc::run_server;
pub use server_grpc::start_grpc_server;
