use crate::service::user_service::UserRegType;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::{Validate, ValidateEmail, ValidationError};

#[derive(Debug, Deserialize, Serialize, ToSchema, Validate, Clone)]
pub struct RegisterRequest {
    /// 昵称
    #[validate(length(min = 4, message = "昵称至少4位"))]
    pub name: String,
    /// 密码（至少6位，含字母和数字）
    #[validate(length(min = 6, message = "密码至少8位"))]
    #[validate(custom(function = "validate_password"))]
    pub password: String,

    /// 注册类型：1=Phone，2=Email，3=LoginName
    pub reg_type: UserRegType,

    /// 目标值：手机号 / 邮箱 / 登录名
    #[validate(custom(function = "validate_target"))]
    pub target: String,
}

#[derive(Debug, Deserialize, Validate, ToSchema, Clone)]
pub struct RegisterVerifyRequest {
    /// 验证码（手机号/邮箱必填，登录名可留空）
    #[validate(custom(function = "validate_verify_code"))]
    pub code: String,
    /// 验证码 Redis ID（服务端注册返回的 reg_id）
    #[validate(length(min = 8, message = "注册 ID 无效"))]
    pub reg_id: String,
}

fn validate_target(value: &str) -> Result<(), ValidationError> {
    if value.contains('@') {
        if value.validate_email() {
            Ok(())
        } else {
            Err(ValidationError::new("邮箱格式无效"))
        }
    } else {
        let phone_re = regex::Regex::new(r"^\+?[0-9]{7,20}$").unwrap();
        if phone_re.is_match(value) {
            return Ok(());
        }
        let username_re = regex::Regex::new(r"^[A-Za-z0-9_]{3,32}$").unwrap();
        if username_re.is_match(value) {
            return Ok(());
        }
        Err(ValidationError::new("登录名格式错误"))
    }
}

fn validate_password(pwd: &str) -> Result<(), ValidationError> {
    let has_letter = pwd.chars().any(|c| c.is_ascii_alphabetic());
    let has_digit = pwd.chars().any(|c| c.is_ascii_digit());

    if has_letter && has_digit {
        Ok(())
    } else {
        Err(ValidationError::new("密码必须包含字母和数字"))
    }
}

fn validate_verify_code(code: &str) -> Result<(), ValidationError> {
    if code.is_empty() || code.len() == 6 {
        Ok(())
    } else {
        Err(ValidationError::new("验证码格式错误"))
    }
}

#[derive(Debug, Deserialize, Validate, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ChangePasswordRequestDto {
    #[validate(length(min = 1, message = "token.required"))]
    pub session_token: String,
    #[validate(length(min = 6, message = "密码至少6位"))]
    pub old_password: String,
    #[validate(length(min = 6, message = "密码至少6位"))]
    #[validate(custom(function = "validate_password"))]
    pub new_password: String,
}

#[derive(Debug, Deserialize, Validate, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ChangePhoneRequestDto {
    #[validate(length(min = 1, message = "token.required"))]
    pub session_token: String,
    #[validate(custom(function = "validate_phone"))]
    pub new_phone: String,
    pub old_phone_code: Option<String>,
    #[validate(length(equal = 6, message = "验证码格式错误"))]
    pub new_phone_code: String,
}

#[derive(Debug, Deserialize, Validate, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ChangeEmailRequestDto {
    #[validate(length(min = 1, message = "token.required"))]
    pub session_token: String,
    #[validate(email(message = "邮箱格式无效"))]
    pub new_email: String,
    pub old_email_code: Option<String>,
    #[validate(length(equal = 6, message = "验证码格式错误"))]
    pub new_email_code: String,
}

#[derive(Debug, Deserialize, Validate, Clone)]
#[serde(rename_all = "camelCase")]
pub struct UpdateProfileRequestDto {
    #[validate(length(min = 1, message = "token.required"))]
    pub session_token: String,
    pub avatar: Option<String>,
    pub gender: Option<i32>,
}

fn validate_phone(value: &str) -> Result<(), ValidationError> {
    let phone_re = regex::Regex::new(r"^\+?[0-9]{7,20}$").unwrap();
    if phone_re.is_match(value) {
        Ok(())
    } else {
        Err(ValidationError::new("手机号格式错误"))
    }
}
