use crate::service::grpc_gateway;
use crate::service::user_service::{
    SessionTokenInfo, UserLogType, UserRegType, UserService, UserServiceAuthOpt,
};
use anyhow::anyhow;
use async_trait::async_trait;
use common::config::AppConfig;
use common::grpc::grpc_hot_online::online_service::{
    client_rpc_service_client::ClientRpcServiceClient, AuthType, ClientEntity, DeviceType,
    FindByContentReq, RegisterUserReq, UpsertSessionTokenRequest, UserType,
};
use common::redis::redis_pool::RedisPoolTools;
use common::util::common_utils::{build_md5_with_key, build_uuid};
use common::UserId;
use deadpool_redis::redis::AsyncCommands;
use log::error;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct VerifySession {
    pub name: String,
    pub password_hash: String,
    pub reg_type: UserRegType,
    pub contact: Option<String>,
    pub code: Option<String>,
}

#[derive(Clone, Debug)]
struct RegistrationTargetMeta {
    contact: Option<String>,
    requires_code: bool,
}

impl UserService {
    fn reg_type_from_login(login_type: &UserLogType) -> Option<UserRegType> {
        match login_type {
            UserLogType::Phone => Some(UserRegType::Phone),
            UserLogType::Email => Some(UserRegType::Email),
            UserLogType::LoginName => Some(UserRegType::LoginName),
            _ => None,
        }
    }

    async fn fetch_client_by_reg_type(
        client: &mut ClientRpcServiceClient<tonic::transport::Channel>,
        reg_type: UserRegType,
        value: &str,
    ) -> anyhow::Result<Option<ClientEntity>> {
        let req = FindByContentReq {
            content: value.to_string(),
        };
        let response = match reg_type {
            UserRegType::Email => client.find_by_email(req).await?,
            UserRegType::Phone => client.find_by_phone(req).await?,
            UserRegType::LoginName => client.find_by_name(req).await?,
        };
        Ok(response.into_inner().client)
    }

    async fn ensure_register_target(
        client: &mut ClientRpcServiceClient<tonic::transport::Channel>,
        reg_type: &UserRegType,
        name: &str,
        target: &str,
    ) -> anyhow::Result<RegistrationTargetMeta> {
        match reg_type {
            UserRegType::Email => {
                if Self::fetch_client_by_reg_type(client, *reg_type, target)
                    .await?
                    .is_some()
                {
                    return Err(anyhow!("邮箱已存在"));
                }
                Ok(RegistrationTargetMeta {
                    contact: Some(target.to_string()),
                    requires_code: true,
                })
            }
            UserRegType::Phone => {
                if Self::fetch_client_by_reg_type(client, *reg_type, target)
                    .await?
                    .is_some()
                {
                    return Err(anyhow!("手机号已存在"));
                }
                Ok(RegistrationTargetMeta {
                    contact: Some(target.to_string()),
                    requires_code: true,
                })
            }
            UserRegType::LoginName => {
                if Self::fetch_client_by_reg_type(client, *reg_type, name)
                    .await?
                    .is_some()
                {
                    return Err(anyhow!("用户名已存在"));
                }
                Ok(RegistrationTargetMeta {
                    contact: None,
                    requires_code: false,
                })
            }
        }
    }
}
#[async_trait]
impl UserServiceAuthOpt for UserService {
    async fn login_by_type(
        &self,
        login_type: &UserLogType,
        target: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(ClientEntity, SessionTokenInfo)> {
        let md5_key = AppConfig::get()
            .sys
            .as_ref()
            .and_then(|s| s.md5_key.clone())
            .ok_or_else(|| anyhow!("md5_key missing"))?;

        let reg_type =
            Self::reg_type_from_login(login_type).ok_or_else(|| anyhow!("Invalid auth type"))?;

        let mut client = grpc_gateway::get_client_rpc_client().await?;

        let mut entity = Self::fetch_client_by_reg_type(&mut client, reg_type, target)
            .await?
            .ok_or_else(|| anyhow!("login.error"))?;

        let stored_password = entity.password.clone();
        if password != build_md5_with_key(&stored_password, &md5_key) {
            return Err(anyhow!("login.error"));
        }
        entity.password.clear();

        let mut online_client = grpc_gateway::get_online_client().await?;
        let token_resp = online_client
            .upsert_session_token(UpsertSessionTokenRequest {
                user_id: entity.id,
                device_type: *device_type as i32,
                device_id: device_id.to_string(),
                login_ip: None,
                user_agent: None,
            })
            .await?
            .into_inner();

        let info = SessionTokenInfo {
            token: token_resp.session_token,
            expires_at: token_resp.expires_at,
        };

        Ok((entity, info))
    }

    async fn login(
        &self,
        _message_id: &i64,
        auth_type: &AuthType,
        auth_content: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(SessionTokenInfo, ClientEntity)> {
        let login_type = match auth_type {
            AuthType::Email => UserLogType::Email,
            AuthType::Phone => UserLogType::Phone,
            AuthType::Username => UserLogType::LoginName,
            _ => return Err(anyhow!("Invalid auth type")),
        };

        let (entity, info) = self
            .login_by_type(&login_type, auth_content, password, device_type, device_id)
            .await?;

        Ok((info, entity))
    }

    async fn logout(&self, uid: UserId, device_type: &DeviceType) -> anyhow::Result<()> {
        // 实现登出逻辑
        Ok(())
    }

    async fn build_register_code(
        &self,
        name: &str,
        password: &str,
        reg_type: &UserRegType,
        target: &str,
    ) -> anyhow::Result<String> {
        let mut client = grpc_gateway::get_client_rpc_client().await?;
        let key = &AppConfig::get().sys.clone().unwrap().md5_key.unwrap();

        let meta = UserService::ensure_register_target(&mut client, reg_type, name, target).await?;
        let reg_id = build_uuid();
        let mut verify_session = VerifySession {
            name: name.to_string(),
            password_hash: build_md5_with_key(password, key),
            reg_type: reg_type.clone(),
            contact: meta.contact.clone(),
            code: None,
        };
        if meta.requires_code {
            let code = format!("{:06}", rand::random::<u32>() % 1_000_000);
            verify_session.code = Some(code);
        }
        let redis_key = format!("register:verify:uuid:{}", reg_id);

        let json_data = serde_json::to_string(&verify_session)?;

        let mut conn = RedisPoolTools::get().get().await?;
        conn.set_ex::<_, _, ()>(&redis_key, json_data, 300).await?;

        // 返回 uuid 给前端
        Ok(reg_id)
    }

    // 用户注册方法

    // 用户注册验证码验证方法
    async fn register_verify_code(&self, reg_id: &str, code: &str) -> anyhow::Result<()> {
        // 1. 构造 Redis Key
        let redis_key = format!("register:verify:uuid:{}", reg_id);

        // 2. 从 Redis 获取验证会话数据
        // 注意：这里需要根据您的实际 Redis 配置进行调整
        // /*
        let redis_pool = RedisPoolTools::get();
        let mut conn = redis_pool.get().await?;
        let json_data: String = conn
            .get(redis_key.clone())
            .await
            .map_err(|e| anyhow!("Redis error: {}", e))?;
        let verify_session: VerifySession = serde_json::from_str(&json_data)
            .map_err(|e| anyhow!("Failed to deserialize verify session: {}", e))?;

        if let Some(expected) = &verify_session.code {
            if expected != code {
                return Err(anyhow!("Invalid verification code"));
            }
        }

        // 6. 删除已使用的验证码（可选）
        // /*
        let _: () = conn
            .del(redis_key)
            .await
            .map_err(|e| anyhow!("Failed to delete redis key: {}", e.to_string()))?;

        let mut client = grpc_gateway::get_client_rpc_client().await?;
        match verify_session.reg_type {
            UserRegType::Phone => {
                let phone = verify_session
                    .contact
                    .clone()
                    .ok_or_else(|| anyhow!("手机号缺失"))?;
                let result = client
                    .register(RegisterUserReq {
                        name: verify_session.name,
                        password: verify_session.password_hash.clone(),
                        email: None,
                        phone: Some(phone),
                        language: None,
                        avatar: "".to_string(),
                        allow_add_friend: 0,
                        gender: 0,
                        user_type: UserType::Normal as i32,
                        profile_fields: Default::default(),
                    })
                    .await;
                if result.is_ok() {
                    return Ok(());
                }
                error!("reg.error: {:?}", result.err().unwrap().code());
                return Err(anyhow!("reg.error"));
            }
            UserRegType::Email => {
                let email = verify_session
                    .contact
                    .clone()
                    .ok_or_else(|| anyhow!("邮箱缺失"))?;
                let result = client
                    .register(RegisterUserReq {
                        name: verify_session.name,
                        password: verify_session.password_hash.clone(),
                        email: Some(email),
                        phone: None,
                        language: None,
                        avatar: "".to_string(),
                        allow_add_friend: 0,
                        gender: 0,
                        user_type: UserType::Normal as i32,
                        profile_fields: Default::default(),
                    })
                    .await;
                if result.is_ok() {
                    return Ok(());
                }
                error!("reg.error: {:?}", result.err().unwrap().code());
                return Err(anyhow!("reg.error"));
            }
            UserRegType::LoginName => {
                let result = client
                    .register(RegisterUserReq {
                        name: verify_session.name,
                        password: verify_session.password_hash.clone(),
                        email: None,
                        phone: None,
                        language: None,
                        avatar: "".to_string(),
                        allow_add_friend: 0,
                        gender: 0,
                        user_type: UserType::Normal as i32,
                        profile_fields: Default::default(),
                    })
                    .await;
                if result.is_ok() {
                    return Ok(());
                }
                error!("reg.error: {:?}", result.err().unwrap().code());
                return Err(anyhow!("reg.error"));
            }
        }
    }

    async fn register_login_name(&self, name: &str, password: &str) -> anyhow::Result<i64> {
        let key = AppConfig::get()
            .sys
            .as_ref()
            .and_then(|s| s.md5_key.clone())
            .ok_or_else(|| anyhow!("md5_key missing"))?;

        common::util::validate::validate_username(name).map_err(|err| {
            let message = err
                .message
                .clone()
                .map(|m| m.into_owned())
                .unwrap_or_else(|| err.code.to_string());
            anyhow!(message)
        })?;

        let mut client = grpc_gateway::get_client_rpc_client().await?;
        UserService::ensure_register_target(&mut client, &UserRegType::LoginName, name, name)
            .await?;

        let response = client
            .register(RegisterUserReq {
                name: name.to_string(),
                password: build_md5_with_key(password, &key),
                email: None,
                phone: None,
                language: None,
                avatar: "".to_string(),
                allow_add_friend: 0,
                gender: 0,
                user_type: UserType::Normal as i32,
                profile_fields: Default::default(),
            })
            .await?;

        Ok(response.into_inner().id)
    }
}
