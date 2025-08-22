-- 主表：client（proto tag 对应见右注）
-- hot_online_service/migrations/mysql_schema.sql

-- 主表：client（proto tag 对应见右注）
-- migrations/mysql_schema.sql
-- 主表：client（proto tag 对应见右注）
CREATE TABLE client (
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
CREATE TABLE uid_email (
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
CREATE TABLE uid_phone (
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
CREATE TABLE uid_name (
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

