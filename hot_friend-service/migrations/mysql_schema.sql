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

CREATE TABLE client (
                        id               BIGINT        NOT NULL PRIMARY KEY,
                        name             VARCHAR(64)   NOT NULL,
                        password_hash    VARBINARY(72) NOT NULL,
                        password_algo    TINYINT       NOT NULL DEFAULT 1,
                        language         CHAR(5)       NULL,
                        avatar           VARCHAR(256)  NOT NULL DEFAULT '',
                        allow_add_friend TINYINT       NOT NULL DEFAULT 0,
                        gender           TINYINT       NOT NULL DEFAULT 0,
                        user_type        TINYINT       NOT NULL DEFAULT 0,
                        email_norm       VARBINARY(320) NULL,
                        phone_norm       VARBINARY(32)  NULL,
                        profile_fields   JSON          NULL,
                        created_at       DATETIME(3)   NOT NULL,
                        updated_at       DATETIME(3)   NOT NULL,
                        version          INT           NOT NULL DEFAULT 0,
                        KEY k_email (email_norm(191)),
                        KEY k_phone (phone_norm)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY HASH (id) PARTITIONS 32;

CREATE TABLE uid_email (
                           email_norm VARBINARY(320) NOT NULL,
                           id         BIGINT NOT NULL,
                           shard_id   INT    NOT NULL,
                           state      TINYINT NOT NULL DEFAULT 1,
                           updated_at DATETIME(3) NOT NULL,
                           PRIMARY KEY (email_norm),
                           KEY k_id (id)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY KEY (email_norm) PARTITIONS 32;

CREATE TABLE uid_phone (
                           phone_norm VARBINARY(32) NOT NULL,
                           id         BIGINT NOT NULL,
                           shard_id   INT    NOT NULL,
                           state      TINYINT NOT NULL DEFAULT 1,
                           updated_at DATETIME(3) NOT NULL,
                           PRIMARY KEY (phone_norm),
                           KEY k_id (id)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  PARTITION BY KEY (phone_norm) PARTITIONS 32;
