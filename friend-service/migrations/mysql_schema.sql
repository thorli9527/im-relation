CREATE TABLE friend_edge (
                             user_id BIGINT UNSIGNED NOT NULL,
                             friend_id BIGINT UNSIGNED NOT NULL,
                             alias VARCHAR ( 64 ) NULL,-- NULL/空串 表示无别名
                             created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY ( user_id, friend_id ),
                             KEY idx_user_alias ( user_id, alias ),
                             KEY idx_friend_user ( friend_id, user_id )
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 PARTITION BY HASH ( user_id ) PARTITIONS 256;
CREATE TABLE
    IF
    NOT EXISTS user_friends_meta (
                                     user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
                                     friend_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
                                     updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;