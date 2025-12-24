-- ====================
-- msg_friend 数据库
-- ====================
CREATE DATABASE IF NOT EXISTS `msg_friend`;
USE `msg_friend`;
TRUNCATE TABLE `message_info`;
TRUNCATE TABLE `conversation_snapshot`;
TRUNCATE TABLE `device_keys`;
TRUNCATE TABLE `friend_requests`;

-- ====================
-- msg_system 数据库
-- ====================
CREATE DATABASE IF NOT EXISTS `msg_system`;
USE `msg_system`;
TRUNCATE TABLE `system_messages`;

-- ====================
-- friend_service 数据库
-- ====================
CREATE DATABASE IF NOT EXISTS `friend`;
USE `friend`;
TRUNCATE TABLE `friend_edge`;
TRUNCATE TABLE `user_friends_meta`;
TRUNCATE TABLE `friend_add_jobs`;
