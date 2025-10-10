//! 统一 Web API 返回体与便捷 JSON 工具函数。

use axum::response::{IntoResponse, Response};
use axum::{http::StatusCode, Json};
use serde::Serialize;
use serde_json::Value;
use std::fmt::Debug;
use std::option::Option;
use utoipa::ToSchema;

/// 生成一个携带 `success=true` 的数据结果。
pub fn result_data<T: Serialize + Debug>(data: T) -> Value {
    serde_json::json!({"success":true,"data":data})
}

/// 构造失败提示的轻量 JSON。
pub fn result_error_msg(msg: &str) -> Value {
    serde_json::json!({"success":false,"msg":msg})
}

/// 返回成功但带有提示信息的 JSON。
pub fn result_warn_msg(msg: &str) -> Value {
    serde_json::json!({"success":true,"msg":msg})
}

/// 标准化的 API 响应结构。
#[derive(Serialize, ToSchema, Debug)]
pub struct ApiResponse<T> {
    code: i32,
    message: String,
    data: Option<T>,
}

impl<T: Serialize> ApiResponse<T> {
    /// 构造成功响应并携带数据。
    pub fn success(data: T) -> Self {
        ApiResponse {
            code: 0,
            message: "success".to_string(),
            data: Some(data),
        }
    }

    /// 构造指定错误码与消息的响应。
    pub fn error(code: i32, msg: impl AsRef<str> + ToString) -> Self {
        ApiResponse {
            code,
            message: msg.to_string(),
            data: None,
        }
    }
}

impl ApiResponse<Value> {
    /// 返回状态 200 且无数据体的响应。
    pub fn json_ok() -> Self {
        ApiResponse {
            code: 200,
            message: "success".to_string(),
            data: None,
        }
    }
    /// 将 JSON 值直接包裹为响应。
    pub fn json(data: Value) -> Self {
        ApiResponse {
            code: 200,
            message: "success".to_string(),
            data: Some(data),
        }
    }
    /// 返回带有错误描述的 JSON 响应。
    pub fn json_error(code: i32, msg: impl AsRef<str> + ToString) -> Self {
        ApiResponse {
            code,
            message: msg.to_string(),
            data: None,
        }
    }
}

impl ApiResponse<String> {
    /// 返回 200 状态且数据为空字符串的响应。
    pub fn success_ok() -> Self {
        ApiResponse {
            code: 200,
            message: "success".to_string(),
            data: Option::None,
        }
    }
}

// pub fn result_page<T: Serialize>(page: PageResult<T>) -> ApiResponse<PageResult<T>> {
//     ApiResponse::success(page)
// }

/// 生成一个默认成功响应。
pub fn result() -> ApiResponse<String> {
    ApiResponse::<String>::success_ok()
}

/// 将列表类 JSON 转换为标准分页数据结构（仅透传 items）。
pub fn result_list(json: Value) -> ApiResponse<Value> {
    // 透传 items 字段为 list，保持兼容旧接口。
    let json = serde_json::json!({
        "list":json.get("items"),
    });
    ApiResponse::<Value>::json(json)
}

/// 包含分页标记的响应结构。
pub fn result_page(json: Value) -> ApiResponse<Value> {
    // 同时携带 hasNext/hasPrev，便于前端分页渲染。
    let json = serde_json::json!({
        "list":json.get("items"),
        "hasNext":json.get("hasNext"),
        "hasPrev":json.get("hasPrev")
    });
    ApiResponse::<Value>::json(json)
}

/// 直接包裹任意 JSON 结果。
pub fn result_json(json: Value) -> ApiResponse<Value> {
    ApiResponse::<Value>::json(json)
}
/// 返回携带错误码的 JSON 结果。
pub fn result_json_error(message: &str, code: i32) -> ApiResponse<Value> {
    // 复用 json_error，统一错误码与文案。
    ApiResponse::<Value>::json_error(code, message)
}

/// 构造 500 错误的字符串响应。
pub fn result_error(message: &str) -> ApiResponse<String> {
    ApiResponse::<String>::error(500, message)
}
/// 返回指定错误码与消息的字符串响应。
pub fn result_error_code(message: &str, code: i32) -> ApiResponse<String> {
    ApiResponse::<String>::error(code, message)
}
impl<T: Serialize> IntoResponse for ApiResponse<T> {
    /// 让 `ApiResponse` 可以直接作为 axum 处理器返回值。
    fn into_response(self) -> Response {
        // Axum 要求返回 (StatusCode, body)，此处统一使用 200。
        (StatusCode::OK, Json(self)).into_response()
    }
}
