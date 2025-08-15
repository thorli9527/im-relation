CREATE TABLE IF NOT EXISTS group_member (
                                            group_id    BIGINT UNSIGNED NOT NULL,                        -- 群组ID
                                            user_id     BIGINT UNSIGNED NOT NULL,                        -- 成员用户ID
                                            alias       VARCHAR(64) DEFAULT NULL,                        -- 群内别名（可为空）
    role        TINYINT UNSIGNED NOT NULL,                       -- 成员角色(0=Owner,1=Admin,2=Member)
    updated_at  TIMESTAMP NOT NULL
    DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,                    -- 更新时间
    PRIMARY KEY (group_id, user_id),
    KEY idx_user_groups (user_id, group_id)
    ) ENGINE=InnoDB
    PARTITION BY HASH(group_id) PARTITIONS 128;


CREATE TABLE IF NOT EXISTS group_meta (
                                          group_id    BIGINT UNSIGNED NOT NULL PRIMARY KEY,            -- 群组ID
                                          member_cnt  INT UNSIGNED NOT NULL DEFAULT 0,                  -- 成员数量
                                          updated_at  TIMESTAMP NOT NULL
                                          DEFAULT CURRENT_TIMESTAMP
                                          ON UPDATE CURRENT_TIMESTAMP                      -- 更新时间
) ENGINE=InnoDB;
