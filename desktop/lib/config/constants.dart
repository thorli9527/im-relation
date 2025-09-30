/// 应用常量定义
class AppConstants {
  AppConstants._();

  // -------------------
  // 应用信息
  // -------------------

  /// 应用名称
  static const String appName = 'IM Client';
  
  /// 应用版本
  static const String appVersion = '1.0.0';
  
  /// 应用描述
  static const String appDescription = 'A modern IM client built with Flutter';

  // -------------------
  // 网络配置
  // -------------------

  /// 默认服务器地址
  static const String defaultServerUrl = 'ws://localhost:8080';
  
  /// 默认API地址
  static const String defaultApiUrl = 'http://localhost:8080/api';
  
  /// 连接超时时间（秒）
  static const int connectionTimeout = 30;
  
  /// 心跳间隔（秒）
  static const int heartbeatInterval = 30;
  
  /// 重连最大次数
  static const int maxReconnectAttempts = 5;
  
  /// 重连间隔（秒）
  static const int reconnectInterval = 3;

  // -------------------
  // 消息配置
  // -------------------

  /// 消息发送超时时间（秒）
  static const int messageSendTimeout = 10;
  
  /// 消息重发最大次数
  static const int maxMessageRetries = 3;
  
  /// 消息缓存大小
  static const int messageCacheSize = 1000;
  
  /// 消息ID长度
  static const int messageIdLength = 32;

  // -------------------
  // 用户配置
  // -------------------

  /// 用户名最小长度
  static const int minUsernameLength = 3;
  
  /// 用户名最大长度
  static const int maxUsernameLength = 20;
  
  /// 密码最小长度
  static const int minPasswordLength = 6;
  
  /// 密码最大长度
  static const int maxPasswordLength = 50;
  
  /// 用户头像最大大小（字节）
  static const int maxAvatarSize = 1024 * 1024; // 1MB

  // -------------------
  // 文件配置
  // -------------------

  /// 图片最大大小（字节）
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  /// 文件最大大小（字节）
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  
  /// 支持的图片格式
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'webp'
  ];
  
  /// 支持的文件格式
  static const List<String> supportedFileFormats = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
    'txt', 'zip', 'rar', '7z'
  ];

  // -------------------
  // UI配置
  // -------------------

  /// 默认动画时长（毫秒）
  static const int defaultAnimationDuration = 300;
  
  /// 长按动画时长（毫秒）
  static const int longPressAnimationDuration = 100;
  
  /// 页面切换动画时长（毫秒）
  static const int pageTransitionDuration = 250;
  
  /// 默认圆角半径
  static const double defaultBorderRadius = 16.0;
  
  /// 小圆角半径
  static const double smallBorderRadius = 8.0;
  
  /// 大圆角半径
  static const double largeBorderRadius = 24.0;

  // -------------------
  // 颜色配置
  // -------------------

  /// 主色调
  static const int primaryColor = 0xFF2255A5;
  
  /// 成功色
  static const int successColor = 0xFF4CAF50;
  
  /// 警告色
  static const int warningColor = 0xFFFF9800;
  
  /// 错误色
  static const int errorColor = 0xFFF44336;
  
  /// 信息色
  static const int infoColor = 0xFF2196F3;

  // -------------------
  // 缓存配置
  // -------------------

  /// 缓存过期时间（天）
  static const int cacheExpirationDays = 7;
  
  /// 最大缓存大小（字节）
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  /// 图片缓存大小（字节）
  static const int imageCacheSize = 50 * 1024 * 1024; // 50MB

  // -------------------
  // 日志配置
  // -------------------

  /// 日志文件最大大小（字节）
  static const int maxLogFileSize = 10 * 1024 * 1024; // 10MB
  
  /// 日志文件保留天数
  static const int logFileRetentionDays = 30;
  
  /// 日志级别
  static const String defaultLogLevel = 'info';

  // -------------------
  // 数据库配置
  // -------------------

  /// 数据库名称
  static const String databaseName = 'im_client';
  
  /// 数据库版本
  static const int databaseVersion = 1;
  
  /// 数据库最大大小（字节）
  static const int maxDatabaseSize = 500 * 1024 * 1024; // 500MB

  // -------------------
  // 安全配置
  // -------------------

  /// Token过期时间（小时）
  static const int tokenExpirationHours = 24;
  
  /// 刷新Token过期时间（天）
  static const int refreshTokenExpirationDays = 7;
  
  /// 密码加密盐值长度
  static const int passwordSaltLength = 32;
  
  /// 最大登录失败次数
  static const int maxLoginAttempts = 5;
  
  /// 登录锁定时间（分钟）
  static const int loginLockoutMinutes = 30;

  // -------------------
  // 功能开关
  // -------------------

  /// 是否启用自动重连
  static const bool enableAutoReconnect = true;
  
  /// 是否启用消息加密
  static const bool enableMessageEncryption = false;
  
  /// 是否启用消息压缩
  static const bool enableMessageCompression = true;
  
  /// 是否启用离线消息
  static const bool enableOfflineMessages = true;
  
  /// 是否启用消息已读状态
  static const bool enableReadReceipts = true;
  
  /// 是否启用消息撤回
  static const bool enableMessageRecall = true;
  
  /// 是否启用消息转发
  static const bool enableMessageForward = true;
  
  /// 是否启用消息搜索
  static const bool enableMessageSearch = true;
  
  /// 是否启用文件传输
  static const bool enableFileTransfer = true;
  
  /// 是否启用语音消息
  static const bool enableVoiceMessages = false;
  
  /// 是否启用视频通话
  static const bool enableVideoCall = false;
} 