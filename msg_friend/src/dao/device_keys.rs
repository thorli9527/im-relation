use anyhow::Result;
use serde::{Deserialize, Serialize};
use sqlx::{MySql, Pool, Row};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeviceKeysRow {
    pub user_id: i64,
    pub device_id: String,
    pub identity_curve: String,
    pub identity_pub: Vec<u8>,
    pub signed_pre_id: i32,
    pub signed_pre_pub: Vec<u8>,
    pub signed_pre_sig: Vec<u8>,
    pub one_time_pre_keys: Option<Vec<u8>>, // JSON bytes
    pub updated_at: i64,
}

pub async fn upsert_device_keys(pool: &Pool<MySql>, row: &DeviceKeysRow) -> Result<u64> {
    let r = sqlx::query(
        r#"REPLACE INTO device_keys
        (user_id, device_id, identity_curve, identity_pub, signed_pre_id, signed_pre_pub, signed_pre_sig, one_time_pre_keys, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"#,
    )
    .bind(row.user_id)
    .bind(&row.device_id)
    .bind(&row.identity_curve)
    .bind(&row.identity_pub)
    .bind(row.signed_pre_id)
    .bind(&row.signed_pre_pub)
    .bind(&row.signed_pre_sig)
    .bind(&row.one_time_pre_keys)
    .bind(row.updated_at)
    .execute(pool)
    .await?;
    Ok(r.rows_affected())
}

pub async fn fetch_device_bundles(pool: &Pool<MySql>, user_id: i64) -> Result<Vec<DeviceKeysRow>> {
    let rows = sqlx::query(r#"SELECT user_id, device_id, identity_curve, identity_pub, signed_pre_id, signed_pre_pub, signed_pre_sig, one_time_pre_keys, updated_at FROM device_keys WHERE user_id = ?"#)
        .bind(user_id)
        .fetch_all(pool)
        .await?;
    let mut out = Vec::with_capacity(rows.len());
    for r in rows {
        out.push(DeviceKeysRow {
            user_id: r.get("user_id"),
            device_id: r.get("device_id"),
            identity_curve: r.get("identity_curve"),
            identity_pub: r.get("identity_pub"),
            signed_pre_id: r.get("signed_pre_id"),
            signed_pre_pub: r.get("signed_pre_pub"),
            signed_pre_sig: r.get("signed_pre_sig"),
            one_time_pre_keys: r.get("one_time_pre_keys"),
            updated_at: r.get("updated_at"),
        });
    }
    Ok(out)
}
