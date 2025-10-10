//! 领域消息模型及 Kafka / socket 之间的互转逻辑。

use anyhow::{anyhow, Result};

use crate::infra::grpc::grpc_socket::socket::{KafkaMsg, MsgKind, ServerMsg};

use super::{delivery::DeliveryOptions, MsgCategory};

/// 统一承载 IM 消息在服务内部流转时所需的上下文。
#[derive(Debug, Clone)]
pub struct DomainMessage {
    /// 目标用户或群组 ID。
    pub to: i64,
    /// 持久化后的消息 ID。
    pub msg_id: Option<i64>,
    /// 枚举类型，用于区别消息场景。
    pub msg_kind: MsgKind,
    /// 原始业务负载（二进制，通常为 protobuf）。
    pub payload: Vec<u8>,
    /// 业务层记录的毫秒时间戳。
    pub ts_ms: i64,
    /// 投递行为控制配置。
    pub delivery: DeliveryOptions,
    /// 发送者 ID（群聊、单聊可选）。
    pub sender_id: Option<i64>,
    /// 单聊接收者 ID。
    pub receiver_id: Option<i64>,
    /// 群聊 ID。
    pub group_id: Option<i64>,
}

impl DomainMessage {
    /// 构造单聊消息，附带发送方与接收方信息。
    pub fn friend(
        to: i64,
        msg_id: Option<i64>,
        msg_kind: MsgKind,
        payload: Vec<u8>,
        ts_ms: i64,
        delivery: DeliveryOptions,
        sender_id: Option<i64>,
        receiver_id: Option<i64>,
    ) -> Self {
        // 只允许好友分类的消息进入此构造器，避免消息错路由。
        debug_assert!(matches!(msg_kind.category(), MsgCategory::Friend));
        Self {
            to,
            msg_id,
            msg_kind,
            payload,
            ts_ms,
            delivery,
            sender_id,
            receiver_id,
            group_id: None,
        }
    }

    /// 构造群聊消息，可携带群 ID 与发送者。
    pub fn group(
        to: i64,
        msg_id: Option<i64>,
        msg_kind: MsgKind,
        payload: Vec<u8>,
        ts_ms: i64,
        delivery: DeliveryOptions,
        group_id: Option<i64>,
        sender_id: Option<i64>,
    ) -> Self {
        // 断言消息类型属于群聊，防止误传。
        debug_assert!(matches!(msg_kind.category(), MsgCategory::Group));
        Self {
            to,
            msg_id,
            msg_kind,
            payload,
            ts_ms,
            delivery,
            sender_id,
            receiver_id: None,
            group_id,
        }
    }

    /// 构造系统消息，通常没有明确的发送者。
    pub fn system(
        to: i64,
        msg_id: Option<i64>,
        msg_kind: MsgKind,
        payload: Vec<u8>,
        ts_ms: i64,
        delivery: DeliveryOptions,
    ) -> Self {
        // 系统消息必须有 System 分类。
        debug_assert!(matches!(msg_kind.category(), MsgCategory::System));
        Self {
            to,
            msg_id,
            msg_kind,
            payload,
            ts_ms,
            delivery,
            sender_id: None,
            receiver_id: None,
            group_id: None,
        }
    }

    /// 便捷读取消息的领域类别。
    pub fn category(&self) -> MsgCategory {
        self.msg_kind.category()
    }

    /// 转换为 Kafka 传输结构，携带投递控制字段。
    pub fn to_kafka_msg(&self) -> KafkaMsg {
        // KafkaMsg 使用枚举的 i32 表示类型，其余配置直接拷贝。
        KafkaMsg {
            to: self.to,
            id: self.msg_id,
            kind: self.msg_kind as i32,
            payload: self.payload.clone(),
            require_ack: Some(self.delivery.require_ack),
            expire_ms: self.delivery.expire_ms,
            max_retry: self.delivery.max_retry,
            ts_ms: Some(self.ts_ms),
        }
    }

    /// 生成 socket 下发格式，注入指定的消息 ID。
    pub fn to_server_msg(&self, id: i64) -> ServerMsg {
        // 发布给 socket 时需要外部传入最终消息 ID。
        ServerMsg {
            id,
            kind: self.msg_kind as i32,
            payload: self.payload.clone(),
            ts_ms: self.ts_ms,
        }
    }

    /// 返回消息目标 ID（好友或群）。
    pub fn target(&self) -> i64 {
        // to 字段统一表示消息投递目标。
        self.to
    }

    /// 获取当前消息的投递选项。
    pub fn delivery(&self) -> &DeliveryOptions {
        &self.delivery
    }

    /// 原样暴露消息类型，方便外部使用枚举方法。
    pub fn kind(&self) -> MsgKind {
        // MsgKind 自带 Copy，实现直接返回值。
        self.msg_kind
    }

    /// 消息原始时间戳（毫秒）。
    pub fn timestamp_ms(&self) -> i64 {
        // timestamp 默认来自业务端或消息 ID。
        self.ts_ms
    }

    /// 业务生成的消息 ID（若尚未持久化则为空）。
    pub fn message_id(&self) -> Option<i64> {
        // 持久化前消息 ID 可能缺失。
        self.msg_id
    }

    /// 获取消息载荷的只读视图。
    pub fn payload(&self) -> &[u8] {
        // 返回 slice 避免额外拷贝。
        &self.payload
    }
}

impl TryFrom<KafkaMsg> for DomainMessage {
    type Error = anyhow::Error;

    /// 将 Kafka 消息转换回领域模型，根据类型分发到具体构造函数。
    fn try_from(value: KafkaMsg) -> Result<Self> {
        let KafkaMsg {
            to,
            id,
            kind,
            payload,
            require_ack,
            expire_ms,
            max_retry,
            ts_ms,
        } = value;

        // 尝试转换枚举值，未知值回退到 MkUnknown。
        let kind = MsgKind::try_from(kind).unwrap_or(MsgKind::MkUnknown);
        // 构建投递参数，默认要求 ACK。
        let delivery = DeliveryOptions {
            require_ack: require_ack.unwrap_or(true),
            expire_ms,
            max_retry,
        };
        // 没有 ts_ms 时退回使用消息 ID 保持幂等顺序。
        let ts_ms = ts_ms.unwrap_or_else(|| id.unwrap_or(0));

        match kind.category() {
            // 好友消息补全接收者字段，便于后续业务使用。
            MsgCategory::Friend => Ok(DomainMessage::friend(
                to,
                id,
                kind,
                payload,
                ts_ms,
                delivery,
                None,
                Some(to),
            )),
            // 群消息若缺少群 ID，则caller需另行补齐。
            MsgCategory::Group => Ok(DomainMessage::group(
                to, id, kind, payload, ts_ms, delivery, None, None,
            )),
            MsgCategory::System => Ok(DomainMessage::system(
                to, id, kind, payload, ts_ms, delivery,
            )),
            // 对于未知类型抛错，避免静默丢弃。
            MsgCategory::Unknown => Err(anyhow!("unsupported msg_kind {:?}", kind)),
        }
    }
}
