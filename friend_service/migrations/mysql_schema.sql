CREATE TABLE IF NOT EXISTS friend_edge (
                             uid BIGINT UNSIGNED NOT NULL,
                             friend_id BIGINT UNSIGNED NOT NULL,
                             nickname VARCHAR ( 64 ) NULL,-- NULL/空串 表示无昵称
                             remark VARCHAR(256) NULL DEFAULT NULL,-- 好友备注
                             blacklisted TINYINT(1) NOT NULL DEFAULT 0,-- 黑名单标记
                             created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY ( uid, friend_id ),
                             KEY idx_user_nickname ( uid, nickname ),
                             KEY idx_friend_user ( friend_id, uid )
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 PARTITION BY HASH ( uid ) PARTITIONS 256;
CREATE TABLE IF NOT EXISTS user_friends_meta (
                                     uid BIGINT UNSIGNED NOT NULL PRIMARY KEY,
                                     friend_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
                                     updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- NOTE: client 以及 uid_* 相关表应由 hot_online_service 管理，已从此处移除

-- 补偿任务：好友关系双向添加失败的重试队列表
CREATE TABLE IF NOT EXISTS friend_add_jobs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  uid BIGINT UNSIGNED NOT NULL,
  friend_uid BIGINT UNSIGNED NOT NULL,
  nickname_for_user VARCHAR(64) NULL,
  nickname_for_friend VARCHAR(64) NULL,
  error_msg VARCHAR(512) NULL,
  retry_count INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 0, -- 0=pending,1=done,2=failed
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_status_created (status, created_at),
  KEY idx_user_friend (uid, friend_uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
