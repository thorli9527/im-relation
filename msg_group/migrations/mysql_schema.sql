-- msg_group: 群聊相关持久化模型定义。
--
-- 1. message_info           群聊消息主表，保存原始明文消息体。
-- 2. group_join_request     入群申请/邀请记录，支持去重与审批流。
-- 3. group_action_log       群级操作审计日志。
--
-- 注意：所有表按 group_id 做 Hash 分区或具备 group_id 索引，以保证横向扩展能力。

CREATE TABLE IF NOT EXISTS `message_info` (
  `msg_id`        BIGINT       NOT NULL COMMENT '全局消息 ID（雪花 ID，保证全局有序）',
  `group_id`      BIGINT       NOT NULL COMMENT '群 ID（与分区键一致）',
  `sender_id`     BIGINT       NOT NULL COMMENT '发送者用户 ID',
  `msg_kind`      INT          NOT NULL COMMENT '消息类型（参见 socket.MsgKind 枚举）',
  `timestamp_ms`  BIGINT       NOT NULL COMMENT '客户端发送时间戳（毫秒精度）',
  `created_at_ms` BIGINT       NOT NULL COMMENT '服务端入库时间（毫秒精度，用于幂等/补偿逻辑）',
  `msg_no`        BIGINT       NOT NULL COMMENT '发送端本地单调序号（用于按端内顺序补齐）',
  `content`       LONGBLOB     NOT NULL COMMENT '原始消息体（二进制序列化结果，例如 protobuf Content）',

  PRIMARY KEY (`group_id`, `msg_id`),
  KEY `idx_group_time` (`group_id`, `timestamp_ms`),
  KEY `idx_sender_time` (`group_id`, `sender_id`, `timestamp_ms`),
  KEY `idx_msg_id` (`msg_id`)  -- 如果你需要根据 msg_id 查找消息
)
ENGINE=InnoDB
COMMENT='msg_group 群聊消息表，按 group_id 哈希分片'
PARTITION BY HASH(`group_id`) PARTITIONS 32;

-- msg_group: 会话快照（用于最近群会话列表/未读统计）
CREATE TABLE IF NOT EXISTS `conversation_snapshot` (
  `uid`        BIGINT  NOT NULL COMMENT '快照所属用户ID',
  `group_id`       BIGINT  NOT NULL COMMENT '群ID',
  `last_msg_id`    BIGINT  NOT NULL DEFAULT 0 COMMENT '最近消息ID',
  `last_msg_kind`  INT     NOT NULL DEFAULT 0 COMMENT '最近消息类型',
  `last_sender_id` BIGINT  NOT NULL DEFAULT 0 COMMENT '最近消息发送者',
  `last_timestamp` BIGINT  NOT NULL DEFAULT 0 COMMENT '最近消息时间(毫秒)',
  `unread_count`   INT     NOT NULL DEFAULT 0 COMMENT '未读数量',
  `created_at`     BIGINT  NOT NULL COMMENT '创建时间(毫秒)',
  `updated_at`     BIGINT  NOT NULL COMMENT '更新时间(毫秒)',
  PRIMARY KEY (`uid`, `group_id`),
  KEY `idx_user_updated` (`uid`, `updated_at` DESC),
  KEY `idx_group_updated` (`group_id`, `updated_at` DESC)
)
ENGINE=InnoDB
PARTITION BY HASH(`uid`) PARTITIONS 32;


-- group_join_request: 入群申请与邀请记录。
-- 状态机：0-待处理，1-已同意，2-已拒绝，3-申请人取消。
CREATE TABLE IF NOT EXISTS `group_join_request` (
  `id`            BIGINT       NOT NULL COMMENT '主键 ID（雪花 ID，用于并发写入）',
  `group_id`      BIGINT       NOT NULL COMMENT '群 ID（分区键）',
  `applicant_id`  BIGINT       NOT NULL COMMENT '申请人/被邀请人用户 ID',
  `extra`         TEXT         NULL COMMENT '申请补充信息（JSON 字符串）',
  `join_source`   VARCHAR(64)  NULL COMMENT '申请来源标识（客户端埋点或渠道）',
  `inviter_id`    BIGINT       NULL COMMENT '邀请人用户 ID（主动申请时为空）',
  `inviter_extra` TEXT         NULL COMMENT '邀请附加信息（JSON 字符串）',
  `inviter_join_source` VARCHAR(64) NULL COMMENT '邀请来源标识',
  `join_time_ms`  BIGINT       NOT NULL COMMENT '申请或邀请触发时间（毫秒）',
  `status`        TINYINT      NOT NULL DEFAULT 0 COMMENT '处理状态：0待处理、1已同意、2已拒绝、3申请人取消',
  `remark`        TEXT         NULL COMMENT '审核备注或拒绝原因',
  `decided_by`    BIGINT       NULL COMMENT '审批人用户 ID',
  `decided_at`    BIGINT       NULL COMMENT '审批时间（毫秒）',
  `created_at`    BIGINT       NOT NULL COMMENT '记录创建时间（毫秒）',
  `updated_at`    BIGINT       NOT NULL COMMENT '记录更新时间（毫秒）',
  PRIMARY KEY (`group_id`, `id`),
  -- group_id + applicant 做唯一约束，防止重复申请。
  UNIQUE KEY `uniq_group_applicant` (`group_id`, `applicant_id`),
  -- 支撑按群维度查询审批队列。
  KEY `idx_group_status` (`group_id`, `status`),
  KEY `idx_request_id` (`id`)
)
ENGINE=InnoDB
COMMENT='群入群申请/邀请记录表'
PARTITION BY HASH(`group_id`) PARTITIONS 32;

-- group_action_log: 群内操作审计日志，记录如加人、踢人、禁言等动作。
CREATE TABLE IF NOT EXISTS `group_action_log` (
  `id`          BIGINT       NOT NULL COMMENT '主键 ID（雪花 ID）',
  `group_id`    BIGINT       NOT NULL COMMENT '群 ID',
  `event_type`  VARCHAR(64)  NOT NULL COMMENT '事件类型标识（如 add_member、mute_member）',
  `operator_id` BIGINT       NOT NULL COMMENT '操作者用户 ID',
  `target_id`   BIGINT       NOT NULL DEFAULT 0 COMMENT '事件目标用户 ID（无目标时为 0）',
  `payload`     TEXT         NULL COMMENT '事件附加信息（JSON 序列化）',
  `created_at`  BIGINT       NOT NULL COMMENT '事件发生时间（毫秒）',
  PRIMARY KEY (`id`),
  -- 支撑按群顺序拉取审计日志。
  KEY `idx_group_created` (`group_id`, `created_at`)
)
ENGINE=InnoDB
COMMENT='群操作审计日志表';
