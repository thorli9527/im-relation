-- 主表：user_info（proto tag 对应见右注）
-- user_service/migrations/mysql_schema.sql

-- 主表：user_info（proto tag 对应见右注）
-- migrations/mysql_schema.sql
CREATE TABLE IF NOT EXISTS user_info (
                    id               BIGINT        NOT NULL PRIMARY KEY,          -- (1)
                    name             VARCHAR(64)   NOT NULL,                      -- (2)
                    password         VARCHAR(255)  NOT NULL,                      -- 密码字段（明文）
                    language         VARCHAR(16)   NULL,                          -- (6) BCP-47，如 zh-CN
                    avatar           VARCHAR(256)  NOT NULL DEFAULT '',           -- (7)
                    allow_add_friend TINYINT       NOT NULL DEFAULT 0,            -- (8)
                    gender           TINYINT       NOT NULL DEFAULT 0,            -- (9)
                    user_type        TINYINT       NOT NULL DEFAULT 0,            -- (10)
                    email_norm       VARBINARY(320) NULL,                         -- (4) lower+punycode
                    phone_norm       VARBINARY(32)  NULL,                         -- (5) E.164
                    profile_fields   JSON          NULL,                          -- 扩展个人资料字段
                    created_at       DATETIME(3)   NOT NULL,                      -- (12)
                    updated_at       DATETIME(3)   NOT NULL,                      -- (13)
                    version          INT           NOT NULL DEFAULT 0,
                    KEY k_email (email_norm(191)),
                    KEY k_phone (phone_norm),
                    KEY k_name  (name)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY HASH (id) PARTITIONS 32;


-- 建议：name 采用二进制比较避免 collation 干扰
-- 如需保持 VARCHAR，可加 COLLATE utf8mb4_bin；或改为 VARBINARY(96)
-- email -> id
CREATE TABLE IF NOT EXISTS uid_email (
                           email        VARBINARY(255) NOT NULL,
                           id           BIGINT         NOT NULL,
                           state        TINYINT        NOT NULL DEFAULT 1,  -- 0=占位, 1=生效
                           create_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                           update_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                           PRIMARY KEY (email),
                           KEY idx_state (state),
                           KEY idx_update_time (update_time)
) ENGINE=InnoDB
PARTITION BY KEY(email) PARTITIONS 64;

-- phone -> id
CREATE TABLE IF NOT EXISTS uid_phone (
                           phone        VARBINARY(32)  NOT NULL,
                           id           BIGINT         NOT NULL,
                           state        TINYINT        NOT NULL DEFAULT 1,
                           create_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                           update_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                           PRIMARY KEY (phone),
                           KEY idx_state (state),
                           KEY idx_update_time (update_time)
) ENGINE=InnoDB
PARTITION BY KEY(phone) PARTITIONS 64;

-- name -> id
CREATE TABLE IF NOT EXISTS uid_name (
                          name         VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
                          id           BIGINT         NOT NULL,
                          state        TINYINT        NOT NULL DEFAULT 1,
                          create_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                          update_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                          PRIMARY KEY (name),
                          KEY idx_state (state),
                          KEY idx_update_time (update_time)
) ENGINE=InnoDB
PARTITION BY KEY(name) PARTITIONS 64;

-- 设备 session token：单表存储，记录每台设备的会话令牌及其过期时间（15 天）
CREATE TABLE IF NOT EXISTS user_session (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    device_type TINYINT NOT NULL COMMENT '设备类型',
    device_id VARCHAR(128) NOT NULL COMMENT '设备唯一标识',
    session_token VARBINARY(96) NOT NULL COMMENT '当前 session token（随机32字节）',
    refresh_token VARBINARY(96) NULL COMMENT '可选 refresh token',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1=active 2=revoked 3=expired',
    issued_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'token下发时间',
    expires_at DATETIME(3) NOT NULL COMMENT 'token 过期时间',
    last_seen_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '最近活跃时间',
    login_ip VARBINARY(32) NULL COMMENT '登录IP（可选）',
    login_user_agent VARCHAR(256) NULL COMMENT '登录UserAgent（可选）',
    PRIMARY KEY (id),
    UNIQUE KEY uk_uid_device (user_id, device_type, device_id),
    UNIQUE KEY uk_token (session_token),
    KEY idx_uid_status (user_id, status),
    KEY idx_expires_at (expires_at)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;
