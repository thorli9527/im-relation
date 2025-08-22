use crate::grpc::auth::{AuthType, DeviceType};
use crate::grpc::client_service::{ClientEntity, FindByContentReq, RegisterUserReq, UserType};
use crate::service::client_rpc_service_impl::ClientRpcServiceImpl;
use crate::service::user_service::{UserService, UserAuthOpt, UserRegType, UserServiceAuthOpt};
use anyhow::anyhow;
use async_trait::async_trait;
use deadpool_redis::redis::AsyncCommands;
use log::error;
use common::{UserId};
use common::util::common_utils::{build_md5_with_key, build_snow_id, build_uid, build_uuid};
use common::util::date_util::now;
use serde::{Deserialize, Serialize};
use tonic::IntoRequest;
use utoipa::openapi::security::Password;
use common::config::AppConfig;
use common::redis::redis_pool;
use common::redis::redis_pool::RedisPoolTools;

#[derive(Serialize, Deserialize)]
pub struct VerifySession {
    //昵称
    pub name: String,
    pub password: String,
    //验证码
    pub code: String,
    //注册方式
    pub reg_type: u8,
    //目标
    pub target: String,
}
#[derive(Serialize, Deserialize)]
pub struct TokenSession {
    pub uid: i64,
    pub name: String,
    pub reg_type: u8,
    pub target: String,
}
#[async_trait]
impl UserServiceAuthOpt for UserService {
    async fn login_by_type(
        &self,
        password: &str,
        auth_type: &UserRegType,
        target: &str,
        device_type: &DeviceType,
    ) -> anyhow::Result<String> {
        let client_service = ClientRpcServiceImpl::get();
        let mut client = client_service.client.lock().await;

        // 根据认证类型选择不同的查找方法
        let client_entity = match auth_type {
            UserRegType::Email => {
                let req = FindByContentReq {
                    content: target.to_string(),
                };
                let response = client.find_by_email(req).await?;
                response.into_inner()
            }
            UserRegType::Phone => {
                let req = FindByContentReq {
                    content: target.to_string(),
                };
                let response = client.find_by_phone(req).await?;
                response.into_inner()
            }

            _ => {
                return Err(anyhow!("Invalid auth type"));
            }
        };

        // 验证密码（这里简化处理，实际应该调用密码验证服务）
        let token = build_uuid();

        Ok(token)
    }

    async fn login(
        &self,
        message_id: &i64,
        auth_type: &AuthType,
        auth_content: &str,
        password: &str,
        device_type: &DeviceType,
    ) -> anyhow::Result<(String, ClientEntity)> {
        let client_service = ClientRpcServiceImpl::get();
        let mut client = client_service.client.lock().await;

        // 根据认证类型选择不同的查找方法
        let client_entity = match auth_type {
            AuthType::Email => {
                let req = FindByContentReq {
                    content: auth_content.to_string(),
                };
                let response = client.find_by_email(req).await?;
                response.into_inner()
            }
            AuthType::Phone => {
                let req = FindByContentReq {
                    content: auth_content.to_string(),
                };
                let response = client.find_by_phone(req).await?;
                response.into_inner()
            }
            AuthType::Username => {
                let req = FindByContentReq {
                    content: auth_content.to_string(),
                };
                let response = client.find_by_name(req).await?;
                response.into_inner()
            }
            _ => {
                return Err(anyhow!("Invalid auth type"));
            }
        };

        // 验证密码（这里简化处理，实际应该调用密码验证服务）
        let token = build_uuid();

        let client=client_entity.client.unwrap();
         let session=TokenSession{
             uid: client.id.clone(),
             name: client.name.clone(),
             reg_type: auth_type.clone() as u8,
             target: auth_content.to_string(),
         };
        let json_data = serde_json::to_string(&session)?;
        let redis_token_key=format!("login:token:{}", token);
        let mut conn = RedisPoolTools::get().get().await?;
        conn.set::<_, _, ()>(&redis_token_key, json_data).await?;
        Ok((token, client.clone()))
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

        let client_service = ClientRpcServiceImpl::get();
        let mut client = client_service.client.lock().await;
        // 根据注册类型构建注册请求
        let mut reg_session = match reg_type {
            UserRegType::Email => {
                let response = client
                    .find_by_email(FindByContentReq {
                        content: target.to_string(),
                    })
                    .await?;
                if response.into_inner().client.is_some() {
                    return Err(anyhow::anyhow!("邮箱已存在"));
                }
                let code = format!("{:06}", rand::random::<u32>() % 1000000);
                VerifySession {
                    name: name.to_string(),
                    password: password.to_string(),
                    code,
                    reg_type: reg_type.clone() as u8,
                    target: target.to_string(),
                }
            }
            UserRegType::Phone => {
                let response = client
                    .find_by_phone(FindByContentReq {
                        content: target.to_string(),
                    })
                    .await?;
                if response.into_inner().client.is_some() {
                    return Err(anyhow::anyhow!("邮箱已存在"));
                }
                let code = format!("{:06}", rand::random::<u32>() % 1000000);
                VerifySession {
                    name: name.to_string(),
                    password: password.to_string(),
                    code,
                    reg_type: reg_type.clone() as u8,
                    target: target.to_string(),
                }
            }

            _ => {
                return Err(anyhow!("Invalid register type"));
            }
        };
        let key = &AppConfig::get().sys.clone().unwrap().md5_key.unwrap();
        reg_session.password=build_md5_with_key(&reg_session.password, key);
        let reg_id = build_uuid();
        let redis_key = format!("register:verify:uuid:{}", reg_id);

        let json_data = serde_json::to_string(&reg_session)?;

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
        let json_data:String=conn.get(redis_key.clone()).await.map_err(|e| anyhow!("Redis error: {}", e))?;
        // 4. 反序列化验证会话数据
        let verify_session: VerifySession = serde_json::from_str(&json_data)
            .map_err(|e| anyhow!("Failed to deserialize verify session: {}", e))?;

        //5. 验证验证码
        if verify_session.code != code {
            return Err(anyhow!("Invalid verification code"));
        }

        // 6. 删除已使用的验证码（可选）
        // /*
        let _: () = conn.del(redis_key).await.map_err(|e| anyhow!("Failed to delete redis key: {}",e.to_string()))?;

        let client_service = ClientRpcServiceImpl::get();
        let mut client = client_service.client.lock().await;
        let user_reg_type=UserRegType::from_i32(verify_session.reg_type as i32).unwrap();
        match user_reg_type {
            UserRegType::Phone => {
                let result=client.register(RegisterUserReq{
                    name: verify_session.name,
                    password: verify_session.password,
                    email: None,
                    phone: Some(verify_session.target),
                    language: None,
                    avatar: "".to_string(),
                    allow_add_friend: 0,
                    gender: 0,
                    user_type: UserType::Normal as i32,
                    profile_fields: Default::default(),
                }).await;
                if result.is_ok() {
                    return Ok(());
                }
                error!("reg.error: {:?}", result.err().unwrap().code());
                return Err( anyhow!("reg.error"));
            }
            UserRegType::Email => {
                let result=client.register(RegisterUserReq{
                    name: verify_session.name,
                    password: verify_session.password,
                    email: Some(verify_session.target),
                    phone: None,
                    language: None,
                    avatar: "".to_string(),
                    allow_add_friend: 0,
                    gender: 0,
                    user_type: UserType::Normal as i32,
                    profile_fields: Default::default(),
                }).await;
                if result.is_ok() {
                    return Ok(());
                }
                error!("reg.error: {:?}", result.err().unwrap().code());
                return Err( anyhow!("reg.error"));
            }
            _ => {
                return Err( anyhow!("reg.error"));
            }
        }
    }
}
