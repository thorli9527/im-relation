# Socket 客户端「好友关系已建立」序列图

下图说明 socket 收到 `好友关系已建立` 业务消息时的处理流程，核心逻辑位于 `flutter_sdk/src/service/socket_client.rs` 的 `handle_friend_established` 分支。

```mermaid
sequenceDiagram
    participant Server
    participant SocketLoop as run_socket_loop
    participant Inbound as handle_inbound_content
    participant Persist as persist_inbound_content
    participant FriendBiz as handle_friend_business/handle_friend_established
    participant FriendSvc as FriendService
    participant FriendAPI as friend_api::get_friend_detail
    participant ConvSvc as ConversationService
    participant SysMsg as LocalSystemMessageService

    Server-->>SocketLoop: ServerMsg(payload=Content{friend_business.established})
    SocketLoop->>Inbound: decode Content; mark ack if present
    Inbound->>Persist: persist_inbound_content(content,current_uid)
    Persist->>FriendBiz: handle_friend_business(...)
    FriendBiz->>FriendBiz: validate current_uid matches uid_a/uid_b -> friend_id
    FriendBiz->>FriendSvc: get_by_friend_id(friend_id) (skip if exists)
    alt friend not found
        FriendBiz->>FriendAPI: get_friend_detail(friend_id)
        FriendAPI-->>FriendBiz: detail{nickname,avatar,remark}
        FriendBiz->>FriendSvc: ensure_friend(friend_id,nickname,established_at)
        FriendBiz->>FriendSvc: apply_profile_update(nickname,avatar)
        FriendBiz->>ConvSvc: persist_established_snapshot -> upsert conversation (unread+1, last_message="已成为好友")
        FriendBiz->>SysMsg: insert local system message("已成为好友",established_at)
    end
    Persist->>Persist: persist_message_entity(base64 protobuf)
    Persist->>ConvSvc: update_conversation_snapshot(content,...)
    SocketLoop-->>Server: send_delivery_ack(pb.id)
```
