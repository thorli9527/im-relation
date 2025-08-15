-- 主表：client（proto tag 对应见右注）
CREATE TABLE client (
                        id               BIGINT        NOT NULL PRIMARY KEY,          -- (1)
                        name             VARCHAR(64)   NOT NULL,                      -- (2)
                        language         VARCHAR(16)   NULL,                          -- (6) BCP-47，如 zh-CN
                        avatar           VARCHAR(256)  NOT NULL DEFAULT '',           -- (7)
                        allow_add_friend TINYINT       NOT NULL DEFAULT 0,            -- (8)
                        gender           TINYINT       NOT NULL DEFAULT 0,            -- (9)
                        user_type        TINYINT       NOT NULL DEFAULT 0,            -- (10)
                        email_norm       VARBINARY(320) NULL,                         -- (4) lower+punycode
                        phone_norm       VARBINARY(32)  NULL,                         -- (5) E.164
                        profile_fields   JSON          NULL,                          -- (11) map<string,string>
                        created_at       DATETIME(3)   NOT NULL,                      -- (12)
                        updated_at       DATETIME(3)   NOT NULL,                      -- (13)
                        version          INT           NOT NULL DEFAULT 0,
                        KEY k_email (email_norm(191)),
                        KEY k_phone (phone_norm),
                        KEY k_name  (name)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY HASH (id) PARTITIONS 32;

-- 目录表：全局唯一键，路由到主表分片（32 路）
CREATE TABLE uid_email (
                           email_norm VARBINARY(320) NOT NULL,
                           id        BIGINT NOT NULL,
                           shard_id  INT    NOT NULL,
                           state     TINYINT NOT NULL DEFAULT 1,     -- 0=pending,1=active
                           updated_at DATETIME(3) NOT NULL,
                           PRIMARY KEY (email_norm),
                           KEY k_id (id)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY KEY (email_norm) PARTITIONS 32;

CREATE TABLE uid_phone (
                           phone_norm VARBINARY(32) NOT NULL,
                           id        BIGINT NOT NULL,
                           shard_id  INT    NOT NULL,
                           state     TINYINT NOT NULL DEFAULT 1,
                           updated_at DATETIME(3) NOT NULL,
                           PRIMARY KEY (phone_norm),
                           KEY k_id (id)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY KEY (phone_norm) PARTITIONS 32;

CREATE TABLE uid_name (
                          name_norm VARCHAR(64) NOT NULL,
                          id        BIGINT      NOT NULL,
                          shard_id  INT         NOT NULL,
                          updated_at DATETIME(3) NOT NULL,
                          PRIMARY KEY (name_norm),
                          KEY k_id (id)
) ENGINE=InnoDB
  PARTITION BY KEY (name_norm) PARTITIONS 32;