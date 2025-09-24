//! 设备密钥 gRPC 服务实现。

use tonic::{Request, Response, Status};

use crate::dao::{fetch_device_bundles, upsert_device_keys, DeviceKeysRow};
use crate::server::Services;
use common::grpc::grpc_msg_friend::msg_friend_service as msgpb;

#[tonic::async_trait]
impl msgpb::key_service_server::KeyService for Services {
    async fn upload_device_keys(
        &self,
        request: Request<msgpb::UploadDeviceKeysRequest>,
    ) -> Result<Response<msgpb::UploadDeviceKeysResponse>, Status> {
        let req = request.into_inner();
        let idk = req
            .identity_key
            .ok_or(Status::invalid_argument("identity_key missing"))?;
        let spk = req
            .signed_pre_key
            .ok_or(Status::invalid_argument("signed_pre_key missing"))?;
        let otks_json = serde_json::to_vec(&req.one_time_pre_keys).unwrap_or_default();
        let now = chrono::Utc::now().timestamp_millis();
        let row = DeviceKeysRow {
            user_id: req.user_id,
            device_id: req.device_id,
            identity_curve: idk.curve,
            identity_pub: idk.pub_key,
            signed_pre_id: spk.key_id as i32,
            signed_pre_pub: spk.pub_key,
            signed_pre_sig: spk.signature,
            one_time_pre_keys: Some(otks_json),
            updated_at: now,
        };
        let _ = upsert_device_keys(self.pool(), &row)
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;
        Ok(Response::new(msgpb::UploadDeviceKeysResponse {
            success: true,
        }))
    }

    async fn fetch_device_keys(
        &self,
        request: Request<msgpb::FetchDeviceKeysRequest>,
    ) -> Result<Response<msgpb::FetchDeviceKeysResponse>, Status> {
        let req = request.into_inner();
        let rows = fetch_device_bundles(self.pool(), req.user_id)
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;
        let bundles = rows
            .into_iter()
            .map(|r| msgpb::DeviceKeyBundle {
                user_id: r.user_id,
                device_id: r.device_id,
                identity_key: Some(msgpb::IdentityKey {
                    curve: r.identity_curve,
                    pub_key: r.identity_pub,
                }),
                signed_pre_key: Some(msgpb::SignedPreKey {
                    key_id: r.signed_pre_id as u32,
                    pub_key: r.signed_pre_pub,
                    signature: r.signed_pre_sig,
                }),
                one_time_pre_keys: serde_json::from_slice::<Vec<msgpb::OneTimePreKey>>(
                    &r.one_time_pre_keys.unwrap_or_default(),
                )
                .unwrap_or_default(),
            })
            .collect();
        Ok(Response::new(msgpb::FetchDeviceKeysResponse { bundles }))
    }
}
