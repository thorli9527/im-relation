fn main() {
    let out_dir = std::env::var("OUT_DIR").expect("OUT_DIR");
    // 1) 编译自身 socket.proto（仍使用 OUT_DIR）
    prost_build::Config::new()
        .out_dir(&out_dir)
        .compile_protos(&["proto/socket.proto"], &["proto"]) // self proto
        .expect("Failed to compile socket.proto");
    println!("cargo:rerun-if-changed=proto/socket.proto");
    println!("cargo:rerun-if-changed=proto");

    // 2) 统一按分类目录生成外部 gRPC 客户端桩
    std::fs::create_dir_all("src/grpc_arb/").ok();
    std::fs::create_dir_all("src/grpc_msg_friend/").ok();
    std::fs::create_dir_all("src/grpc_hot_friend/").ok();
    std::fs::create_dir_all("src/grpc_msg_group/").ok();
    std::fs::create_dir_all("src/grpc_hot_online/").ok();
    // arb-service
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/grpc_arb/")
        .compile_protos(
            &["../arb-service/proto/arb_server.proto"],
            &["../arb-service/proto"],
        ) // arb proto
        .expect("Failed to compile arb_server.proto");
    println!("cargo:rerun-if-changed=../arb-service/proto/arb_server.proto");
    println!("cargo:rerun-if-changed=../arb-service/proto");

    // FriendBizService（msg_friend）
    tonic_build::configure()
        .build_server(false)
        .build_client(true)
        .out_dir("src/grpc_msg_friend/")
        .compile_protos(
            &["../msg_friend/proto/friend.proto"],
            &["../msg_friend/proto"],
        ) // friend biz proto
        .expect("Failed to compile friend.proto");
    println!("cargo:rerun-if-changed=../msg_friend/proto/friend.proto");
    println!("cargo:rerun-if-changed=../msg_friend/proto");

    // hot_friend_service（双向好友等）
    tonic_build::configure()
        .build_server(false)
        .build_client(true)
        .out_dir("src/grpc_hot_friend/")
        .compile_protos(
            &["../hot_friend_service/proto/friend_service.proto"],
            &["../hot_friend_service/proto"],
        )
        .expect("Failed to compile friend_service.proto");
    println!("cargo:rerun-if-changed=../hot_friend_service/proto/friend_service.proto");
    println!("cargo:rerun-if-changed=../hot_friend_service/proto");

    // hot_group_service（群）
    tonic_build::configure()
        .build_server(false)
        .build_client(true)
        .out_dir("src/grpc_msg_group/")
        .compile_protos(
            &["../hot_group_service/proto/group_service.proto"],
            &["../hot_group_service/proto"],
        )
        .expect("Failed to compile group_service.proto");
    println!("cargo:rerun-if-changed=../hot_group_service/proto/group_service.proto");
    println!("cargo:rerun-if-changed=../hot_group_service/proto");

    // hot_online_service（在线/鉴权）
    tonic_build::configure()
        .build_server(false)
        .build_client(true)
        .out_dir("src/grpc_hot_online/")
        .compile_protos(
            &[
                "../hot_online_service/proto/online.proto",
                "../hot_online_service/proto/auth.proto",
                "../hot_online_service/proto/client_entity.proto",
            ],
            &["../hot_online_service/proto"],
        )
        .expect("Failed to compile online/auth/client_entity protos");
    println!("cargo:rerun-if-changed=../hot_online_service/proto/online.proto");
    println!("cargo:rerun-if-changed=../hot_online_service/proto/auth.proto");
    println!("cargo:rerun-if-changed=../hot_online_service/proto/client_entity.proto");
}
