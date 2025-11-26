-- msg_system: 系统/账号级消息存储
CREATE TABLE IF NOT EXISTS `system_messages` (
    `msg_id`      BIGINT      NOT NULL COMMENT '系统消息ID（雪花）',
    `sender_id`   BIGINT      NOT NULL COMMENT '发送方（系统/操作者）',
    `receiver_id` BIGINT      NOT NULL COMMENT '接收方用户ID',
    `created_at`  BIGINT      NOT NULL COMMENT '创建时间(毫秒)',
    `content`     LONGBLOB    NOT NULL COMMENT '消息体二进制（protobuf 编码的 message.Content）',
    PRIMARY KEY (`receiver_id`, `msg_id`),
    KEY `idx_receiver_time` (`receiver_id`, `created_at`)
) ENGINE=InnoDB
PARTITION BY KEY(`receiver_id`) PARTITIONS 16;
