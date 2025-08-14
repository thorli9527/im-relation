CREATE TABLE IF NOT EXISTS friend_edge (
     user_id     BIGINT UNSIGNED NOT NULL,
     friend_id   BIGINT UNSIGNED NOT NULL,
     status      TINYINT NOT NULL DEFAULT 1,
     created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (user_id, friend_id),          -- 覆盖主查询
     KEY idx_friend_user (friend_id, user_id)   -- 反向/互查用（非唯一）
)
PARTITION BY HASH(user_id) PARTITIONS 256     -- 按 user_id 哈希分 256 分区
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_friends_meta (
     user_id     BIGINT UNSIGNED NOT NULL PRIMARY KEY,
     friend_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
     updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
     ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;