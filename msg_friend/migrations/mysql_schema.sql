-- msg_friend: 好友消息（密文存储，单表分区）
CREATE TABLE IF NOT EXISTS `message_info` (
    `msg_id`        BIGINT       NOT NULL COMMENT '全局消息ID',
    `sender_id`     BIGINT       NOT NULL COMMENT '发送方用户ID',
    `receiver_id`   BIGINT       NOT NULL COMMENT '接收方用户ID',
    `msg_kind`      INT          NOT NULL COMMENT '消息类型，对应 socket.MsgKind',
    `created_at`    BIGINT       NOT NULL COMMENT '消息创建时间(毫秒)',
    `scheme`        VARCHAR(64)   NOT NULL COMMENT '加密方案标识，如 x25519+chacha20poly1305',
    `key_id`        VARCHAR(128)  NOT NULL COMMENT '密钥标识，用于定位密钥材料',
    `nonce`         VARBINARY(24) NOT NULL COMMENT 'AEAD 随机数/计数器随机量',
    `msg_no`        BIGINT        NOT NULL COMMENT '发送端本地单调消息序号',
    `aad`           VARBINARY(512) NULL COMMENT 'AEAD 附加认证数据(AAD)',
    `ciphertext`    LONGBLOB      NOT NULL COMMENT '密文(包含认证标签)',
    `content`       LONGBLOB      NOT NULL COMMENT '消息体二进制（如 Protobuf 编码的 Content）',

    -- 主键必须包含分区列
    PRIMARY KEY (`sender_id`, `receiver_id`, `msg_id`),

    -- 常用查询索引（按会话+时间分页）
    KEY `idx_pair_time`    (`sender_id`, `receiver_id`, `created_at`),
    KEY `idx_pair_time_rev`(`receiver_id`, `sender_id`, `created_at`),

    -- 如果你还会按单边用户维度翻页，可保留：
    KEY `idx_receiver_time` (`receiver_id`, `created_at`),
    KEY `idx_sender_time`   (`sender_id`, `created_at`)
    )
    ENGINE=InnoDB
    PARTITION BY KEY(`sender_id`, `receiver_id`) PARTITIONS 16;

-- msg_friend: 会话快照（用于最近会话列表/未读统计）
CREATE TABLE IF NOT EXISTS `conversation_snapshot` (
    `owner_id`        BIGINT      NOT NULL COMMENT '快照所属用户ID',
    `peer_id`         BIGINT      NOT NULL COMMENT '对端用户ID',
    `conversation_id` BIGINT      NOT NULL COMMENT '会话标识(按 owner_id 和 peer_id 组合生成)',
    `last_msg_id`     BIGINT      NOT NULL DEFAULT 0 COMMENT '最近消息ID',
    `last_msg_kind`   INT         NOT NULL DEFAULT 0 COMMENT '最近消息类型',
    `last_sender_id`  BIGINT      NOT NULL DEFAULT 0 COMMENT '最近消息发送者',
    `last_receiver_id` BIGINT     NOT NULL DEFAULT 0 COMMENT '最近消息接收者',
    `last_timestamp`  BIGINT      NOT NULL DEFAULT 0 COMMENT '最近消息时间(毫秒)',
    `unread_count`    INT         NOT NULL DEFAULT 0 COMMENT '未读数量',
    `created_at`      BIGINT      NOT NULL COMMENT '创建时间(毫秒)',
    `updated_at`      BIGINT      NOT NULL COMMENT '更新时间(毫秒)',
    PRIMARY KEY (`owner_id`, `conversation_id`),
    KEY `idx_owner_updated` (`owner_id`, `updated_at` DESC),
    KEY `idx_owner_peer` (`owner_id`, `peer_id`)
)
ENGINE=InnoDB
PARTITION BY KEY(`owner_id`) PARTITIONS 16;


-- msg_friend: 设备密钥（最小托管实现）
CREATE TABLE IF NOT EXISTS `device_keys` (
  `uid`        BIGINT       NOT NULL COMMENT '用户ID',
  `device_id`      VARCHAR(128) NOT NULL COMMENT '设备ID',
  `identity_curve` VARCHAR(32)  NOT NULL COMMENT '身份密钥曲线/算法',
  `identity_pub`   BLOB         NOT NULL COMMENT '身份公钥',
  `signed_pre_id`  INT          NOT NULL COMMENT '签名预密钥ID',
  `signed_pre_pub` BLOB         NOT NULL COMMENT '签名预密钥公钥',
  `signed_pre_sig` BLOB         NOT NULL COMMENT '签名预密钥签名',
  `one_time_pre_keys` LONGBLOB  NULL COMMENT '一次性预共享密钥集合(序列化 JSON/CBOR)',
  `updated_at`     BIGINT       NOT NULL COMMENT '更新时间(毫秒)',
  PRIMARY KEY (`uid`, `device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 好友申请表（用于处理申请的持久化与决策）
CREATE TABLE IF NOT EXISTS `friend_requests` (
  `id`            BIGINT       NOT NULL PRIMARY KEY COMMENT '好友申请ID',
  `from_uid`  BIGINT       NOT NULL COMMENT '申请方用户ID',
  `to_uid`    BIGINT       NOT NULL COMMENT '被申请方用户ID',
  `reason`        VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '申请理由',
  `source`        INT          NOT NULL DEFAULT 0 COMMENT '申请来源(枚举)',
  `created_at`    BIGINT       NOT NULL COMMENT '申请时间(毫秒)',
  `decided_at`    BIGINT       NULL COMMENT '处理时间(毫秒，可空)',
  `accepted`      TINYINT(1)   NULL COMMENT '是否接受(可空)',
  `remark`        VARCHAR(1024) NULL COMMENT '备注(可空)',
  KEY `idx_friend_req_from` (`from_uid`),
  KEY `idx_friend_req_to`   (`to_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
