use anyhow::{anyhow, Result};

use crate::grpc::grpc_socket::socket::{KafkaMsg, MsgCategory, MsgKind, ServerMsg};

#[derive(Debug, Clone)]
pub struct DeliveryOptions {
    pub require_ack: bool,
    pub expire_ms: Option<u64>,
    pub max_retry: Option<u32>,
}

impl DeliveryOptions {
    pub fn require_ack_defaults() -> Self {
        Self {
            require_ack: true,
            expire_ms: Some(10_000),
            max_retry: Some(10),
        }
    }

    pub fn fire_and_forget() -> Self {
        Self {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }
    }
}

#[derive(Debug, Clone)]
pub struct DomainMessage {
    pub to: i64,
    pub msg_id: Option<i64>,
    pub msg_kind: MsgKind,
    pub payload: Vec<u8>,
    pub ts_ms: i64,
    pub delivery: DeliveryOptions,
    pub sender_id: Option<i64>,
    pub receiver_id: Option<i64>,
    pub group_id: Option<i64>,
}

impl DomainMessage {
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

    pub fn system(
        to: i64,
        msg_id: Option<i64>,
        msg_kind: MsgKind,
        payload: Vec<u8>,
        ts_ms: i64,
        delivery: DeliveryOptions,
    ) -> Self {
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

    pub fn category(&self) -> MsgCategory {
        self.msg_kind.category()
    }

    pub fn to_kafka_msg(&self) -> KafkaMsg {
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

    pub fn to_server_msg(&self, id: i64) -> ServerMsg {
        ServerMsg {
            id,
            kind: self.msg_kind as i32,
            payload: self.payload.clone(),
            ts_ms: self.ts_ms,
        }
    }

    pub fn target(&self) -> i64 {
        self.to
    }

    pub fn delivery(&self) -> &DeliveryOptions {
        &self.delivery
    }

    pub fn kind(&self) -> MsgKind {
        self.msg_kind
    }

    pub fn timestamp_ms(&self) -> i64 {
        self.ts_ms
    }

    pub fn message_id(&self) -> Option<i64> {
        self.msg_id
    }

    pub fn payload(&self) -> &[u8] {
        &self.payload
    }
}

impl TryFrom<KafkaMsg> for DomainMessage {
    type Error = anyhow::Error;

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

        let kind = MsgKind::try_from(kind).unwrap_or(MsgKind::MkUnknown);
        let delivery = DeliveryOptions {
            require_ack: require_ack.unwrap_or(true),
            expire_ms,
            max_retry,
        };
        let ts_ms = ts_ms.unwrap_or_else(|| id.unwrap_or(0));

        match kind.category() {
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
            MsgCategory::Group => Ok(DomainMessage::group(
                to, id, kind, payload, ts_ms, delivery, None, None,
            )),
            MsgCategory::System => Ok(DomainMessage::system(
                to, id, kind, payload, ts_ms, delivery,
            )),
            MsgCategory::Unknown => Err(anyhow!("unsupported msg_kind {:?}", kind)),
        }
    }
}
