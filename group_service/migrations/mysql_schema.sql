CREATE TABLE IF NOT EXISTS group_info (
    id              BIGINT UNSIGNED NOT NULL PRIMARY KEY,    -- 分区键/主键
    name            VARCHAR(64)  NOT NULL,
    avatar          VARCHAR(128)  NOT NULL DEFAULT '',
    description     TEXT NULL,
    notice          TEXT NULL,
    join_permission TINYINT UNSIGNED NOT NULL DEFAULT 0,
    owner_id        BIGINT UNSIGNED NOT NULL,
    group_type      TINYINT UNSIGNED NOT NULL DEFAULT 0,
    allow_search    TINYINT(1)    NOT NULL DEFAULT 1,
    enable          TINYINT(1)    NOT NULL DEFAULT 1,
    create_time     BIGINT UNSIGNED NOT NULL,                -- epoch ms
    update_time     BIGINT UNSIGNED NOT NULL,                -- epoch ms
    KEY idx_owner (owner_id),
    KEY idx_search (allow_search, enable),
    KEY idx_name (name)
    ) ENGINE=InnoDB
PARTITION BY HASH(id) PARTITIONS 16;

CREATE TABLE IF NOT EXISTS group_member (
    group_id    BIGINT UNSIGNED NOT NULL,                        -- 群组ID
    uid         BIGINT UNSIGNED NOT NULL,                        -- 成员用户ID
    nickname    VARCHAR(64) DEFAULT NULL,                        -- 群内昵称（可为空）
    role        TINYINT UNSIGNED NOT NULL,                       -- 成员角色(0=Owner,1=Admin,2=Member)
    updated_at  TIMESTAMP NOT NULL
    DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,                    -- 更新时间
    PRIMARY KEY (group_id, uid),
    KEY idx_user_groups (uid, group_id)
) ENGINE=InnoDB
PARTITION BY HASH(group_id) PARTITIONS 128;


CREATE TABLE IF NOT EXISTS group_meta (
                                          group_id    BIGINT UNSIGNED NOT NULL PRIMARY KEY,            -- 群组ID
                                          member_cnt  INT UNSIGNED NOT NULL DEFAULT 0,                  -- 成员数量
                                          updated_at  TIMESTAMP NOT NULL
                                          DEFAULT CURRENT_TIMESTAMP
                                          ON UPDATE CURRENT_TIMESTAMP                      -- 更新时间
) ENGINE=InnoDB;
