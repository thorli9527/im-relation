fn main() -> Result<(), Box<dyn std::error::Error>> {
    // message.proto 已迁移至 msg_group/msg_friend
    println!("cargo:rerun-if-changed=build.rs");
    Ok(())
}
