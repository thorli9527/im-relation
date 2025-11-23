use axum::extract::Query;
use axum::{routing::get, Router};
use common::core::errors::AppError;
use common::core::result::{result, ApiResponse};
use fake::{faker::name::raw::FirstName, locales::EN, Fake};
use serde::Deserialize;

pub fn router() -> Router {
    Router::new()
        .route("/status", get(status))
        .route("/nickname", get(random_nickname))
}

#[utoipa::path(
    get,
    path = "/status",
    responses(
        (status = 200, description = "服务状态", body = ApiResponse<String>)
    ),
    tag = "app_api"
)]
async fn status() -> Result<ApiResponse<String>, AppError> {
    Ok(result())
}

/// 随机生成英文昵称（单词），gender 支持 "male"/"female"，其他值走随机。
pub fn random_english_nickname(gender: Option<&str>) -> String {
    let gender = gender.map(|g| g.to_ascii_lowercase());

    let first: String = FirstName(EN).fake();

    match gender.as_deref() {
        Some("male") | Some("m") => format!("Mr{}", first),
        Some("female") | Some("f") => format!("Ms{}", first),
        _ => first,
    }
}

#[derive(Debug, Deserialize)]
struct RandomNicknameQuery {
    /// gender 可选：male/female，其他值随机
    gender: Option<String>,
}

#[utoipa::path(
    get,
    path = "/nickname/random",
    params(
        ("gender" = Option<String>, Query, description = "male/female，缺省则随机")
    ),
    responses(
        (status = 200, description = "随机英文昵称", body = ApiResponse<String>)
    ),
    tag = "app_api"
)]
async fn random_nickname(
    Query(q): Query<RandomNicknameQuery>,
) -> Result<ApiResponse<String>, AppError> {
    let name = random_english_nickname(q.gender.as_deref());
    Ok(ApiResponse::success(name))
}
