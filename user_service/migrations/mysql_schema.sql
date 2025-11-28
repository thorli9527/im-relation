-- user_service/migrations/mysql_schema.sql

-- 主表：user_info（proto tag 对应见右注）
-- 备注：
-- 1) password 列用于存放密码哈希（64 长度可容纳 bcrypt/argon2 hash），勿存明文。
-- 2) time 字段统一采用 UTC，应用层负责时区转换。
-- 3) 分区：主表按 id 做 HASH 32 分区；uid_* 映射表按 KEY 分区便于扩展。
-- 字段说明（user_info）：
--   id              用户唯一 ID（雪花等）
--   name            登录名/用户名（唯一约束见业务层）
--   password        密码哈希（bcrypt/argon2 等，不存明文）
--   language        BCP-47 语言标记，例如 zh-CN
--   country         ISO 国家/地区代码，例如 CN/US
--   nickname        展示昵称
--   avatar          头像 URL（可为空字符串）
--   allow_add_friend 好友策略，枚举：0=未设置(等同需验证)、1=任何人可直接添加、2=需验证、3=仅手机号/拒绝
--   gender          枚举：0=未设置，1=男，2=女，9=保密
--   user_type       枚举：0=未设置，1=普通用户，2=测试账号，3=机器人
--   email_norm      归一化邮箱（lower+punycode）
--   phone_norm      归一化手机号（E.164）
--   profile_fields  JSON 扩展资料
--   created_at/updated_at  创建/更新时间（UTC）
--   version         乐观锁版本号
CREATE TABLE IF NOT EXISTS user_info (
                    id               BIGINT        NOT NULL PRIMARY KEY,          -- 用户ID（雪花等）
                    name             VARCHAR(32)   NOT NULL,                      -- 登录名/用户名（唯一约束见业务层）
                    password         VARCHAR(64)   NOT NULL,                      -- 密码哈希（bcrypt/argon2）
                    language         VARCHAR(16)   NULL,                          -- 语言，BCP-47，例如 zh-CN
                    country          VARCHAR(32)   NULL,                          -- 国家/地区代码，例如 CN/US
                    nickname         VARCHAR(32)   NULL,                          -- 昵称
                    avatar           VARCHAR(128)  NOT NULL DEFAULT '',           -- 头像 URL
                    allow_add_friend TINYINT       NOT NULL DEFAULT 0,            -- 好友策略：0 未设/需验证；1 直接通过；2 需验证；3 手机/拒绝
                    gender           TINYINT       NOT NULL DEFAULT 0,            -- 性别：0 未设；1 男；2 女；9 保密
                    user_type        TINYINT       NOT NULL DEFAULT 0,            -- 用户类型：0 未设；1 普通；2 测试；3 机器人
                    email_norm       VARBINARY(64) NULL,                          -- 归一化邮箱（lower+punycode）
                    phone_norm       VARBINARY(32) NULL,                          -- 归一化手机号（E.164）
                    profile_fields   JSON          NULL,                          -- 扩展个人资料 JSON
                    created_at       DATETIME(3)   NOT NULL,                      -- 创建时间（UTC）
                    updated_at       DATETIME(3)   NOT NULL,                      -- 更新时间（UTC）
                    version          INT           NOT NULL DEFAULT 0,            -- 乐观锁版本
                    KEY k_email (email_norm(191)),                                -- 邮箱索引
                    KEY k_phone (phone_norm),                                     -- 手机索引
                    KEY k_name  (name)                                            -- 用户名索引
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY HASH (id) PARTITIONS 32;


-- 建议：name 采用二进制比较避免 collation 干扰
-- 如需保持 VARCHAR，可加 COLLATE utf8mb4_bin；或改为 VARBINARY(96)
-- email -> id
CREATE TABLE IF NOT EXISTS uid_email (
                           email        VARBINARY(64) NOT NULL,                  -- 归一化邮箱
                           id           BIGINT         NOT NULL,                 -- 用户ID
                           state        TINYINT        NOT NULL DEFAULT 1,       -- 状态：0 占位，1 生效
                           create_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3), -- 创建时间
                           update_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3), -- 更新时间
                           PRIMARY KEY (email),
                           KEY idx_state (state),                                -- 状态索引
                           KEY idx_update_time (update_time)                     -- 更新时间索引
) ENGINE=InnoDB
PARTITION BY KEY(email) PARTITIONS 64;

-- phone -> id
CREATE TABLE IF NOT EXISTS uid_phone (
                           phone        VARBINARY(32)  NOT NULL,                 -- 归一化手机号（E.164）
                           id           BIGINT         NOT NULL,                 -- 用户ID
                           state        TINYINT        NOT NULL DEFAULT 1,       -- 状态：0 占位，1 生效
                           create_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3), -- 创建时间
                           update_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3), -- 更新时间
                           PRIMARY KEY (phone),
                           KEY idx_state (state),                                -- 状态索引
                           KEY idx_update_time (update_time)                     -- 更新时间索引
) ENGINE=InnoDB
PARTITION BY KEY(phone) PARTITIONS 64;

-- name -> id
CREATE TABLE IF NOT EXISTS uid_name (
                          name         VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, -- 用户名（区分大小写）
                          id           BIGINT         NOT NULL,                                   -- 用户ID
                          state        TINYINT        NOT NULL DEFAULT 1,                         -- 状态：0 占位，1 生效
                          create_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3),      -- 创建时间
                          update_time  DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3), -- 更新时间
                          PRIMARY KEY (name),
                          KEY idx_state (state),                                                -- 状态索引
                          KEY idx_update_time (update_time)                                     -- 更新时间索引
) ENGINE=InnoDB
PARTITION BY KEY(name) PARTITIONS 64;

-- 设备 session token：单表存储，记录每台设备的会话令牌及其过期时间（15 天）
CREATE TABLE IF NOT EXISTS user_session (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,                 -- 自增主键
    uid              BIGINT         NOT NULL,                                 -- 用户ID
    device_type      TINYINT        NOT NULL,                                 -- 设备类型：0 UNKNOWN，1 MOBILE，3 WEB，4 PC
    device_id        VARCHAR(128)   NOT NULL,                                 -- 设备唯一标识
    session_token    VARBINARY(96)  NOT NULL,                                 -- 当前 session token（随机32字节）
    refresh_token    VARBINARY(96)  NULL,                                     -- 可选 refresh token
    status           TINYINT        NOT NULL DEFAULT 1,                       -- 状态：1 active，2 revoked，3 expired
    issued_at        DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3),    -- token下发时间
    expires_at       DATETIME(3)    NOT NULL,                                 -- token 过期时间
    last_seen_at     DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3),    -- 最近活跃时间
    login_ip         VARBINARY(32)  NULL,                                     -- 登录IP（可选）
    login_user_agent VARCHAR(256)   NULL,                                     -- 登录UserAgent（可选）
    PRIMARY KEY (id),
    UNIQUE KEY uk_uid_device (uid, device_type),
    UNIQUE KEY uk_token (session_token),
    KEY idx_uid_status (uid, status),
    KEY idx_expires_at (expires_at)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

-- 字段说明（user_session）：
--   uid           用户 ID
--   device_type   枚举：0=UNKNOWN 1=MOBILE 3=WEB 4=PC
--   device_id     客户端生成的设备唯一标识
--   session_token 会话 token（当前生效）
--   refresh_token 可选 refresh token
--   status        枚举：1=active 2=revoked 3=expired
--   issued_at     token 下发时间（UTC）
--   expires_at    token 过期时间（UTC）
--   last_seen_at  最近活跃时间（UTC）
--   login_ip      登录 IP（归一化存储）
--   login_user_agent 登录 UA 文本
