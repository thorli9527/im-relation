class ValidatorUtil {
  /// 验证是否为空
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// 验证邮箱格式
  static bool isEmail(String? value) {
    if (value == null || value.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  /// 验证手机号（中国大陆 + 国际格式，支持 +86、+1 等 E.164）
  static bool isPhone(String? value) {
    if (value == null || value.isEmpty) return false;

    // 中国大陆手机号：11位，以 1 开头，第二位是 3~9
    final chinaMobileRegex = RegExp(r'^1[3-9]\d{9}$');

    // 国际手机号（E.164），以 + 开头，最多 15 位数字
    final internationalRegex = RegExp(r'^\+?[1-9]\d{6,14}$');

    return chinaMobileRegex.hasMatch(value) || internationalRegex.hasMatch(value);
  }

  /// 验证密码（至少6位）
  static bool isPasswordValid(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.length >= 6;
  }

  /// 验证身份证号码（中国）
  static bool isIdCard(String? value) {
    if (value == null || value.isEmpty) return false;
    final idCardRegex = RegExp(
      r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$',
    );
    return idCardRegex.hasMatch(value);
  }

  /// 验证用户名（字母数字下划线组合）
  static bool isUsernameValid(String? value) {
    if (value == null || value.isEmpty) return false;
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(value);
  }
}
