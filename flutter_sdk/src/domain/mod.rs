pub mod config_entity;
pub mod conversation_entity;
pub mod friend_entity;
pub mod group_entity;
pub mod message_entity;
pub mod user_entity;
pub mod proto_adapter;
pub use config_entity::*;
pub use conversation_entity::*;
pub use friend_entity::*;
pub use group_entity::*;
pub use message_entity::*;
pub use user_entity::*;

pub fn init() {
    config_entity::init();
    friend_entity::init();
    conversation_entity::init();
    group_entity::init();
    message_entity::init();
    user_entity::init();
}
