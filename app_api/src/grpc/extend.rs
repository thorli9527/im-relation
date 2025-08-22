use std::collections::HashMap;
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use serde::ser::SerializeStruct;
use utoipa::{PartialSchema, ToSchema};
use crate::grpc::auth::DeviceType;
use crate::grpc::client_service::ClientEntity;
use std::fmt;
use utoipa::openapi::{RefOr, Schema};

// 手动实现序列化
impl Serialize for ClientEntity {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        let mut state = serializer.serialize_struct("ClientEntity", 14)?;

        // 序列化每个字段
        state.serialize_field("id", &self.id)?;
        state.serialize_field("password", &self.password)?;
        state.serialize_field("name", &self.name)?;

        if let Some(email) = &self.email {
            state.serialize_field("email", email)?;
        }

        if let Some(phone) = &self.phone {
            state.serialize_field("phone", phone)?;
        }

        if let Some(language) = &self.language {
            state.serialize_field("language", language)?;
        }

        state.serialize_field("avatar", &self.avatar)?;

        // 序列化枚举（转换为对应的变体名称）
        let add_friend_policy = match self.allow_add_friend {
            0 => "AllowAll",
            1 => "RequireApproval",
            2 => "DenyAll",
            _ => "Unknown",
        };
        state.serialize_field("allowAddFriend", add_friend_policy)?;

        let gender = match self.gender {
            0 => "Unspecified",
            1 => "Male",
            2 => "Female",
            3 => "Other",
            _ => "Unknown",
        };
        state.serialize_field("gender", gender)?;

        let user_type = match self.user_type {
            0 => "Regular",
            1 => "Admin",
            2 => "Guest",
            _ => "Unknown",
        };
        state.serialize_field("userType", user_type)?;

        state.serialize_field("profileFields", &self.profile_fields)?;
        state.serialize_field("createTime", &self.create_time)?;
        state.serialize_field("updateTime", &self.update_time)?;
        state.serialize_field("version", &self.version)?;

        state.end()
    }
}

// 手动实现反序列化
impl<'de> Deserialize<'de> for ClientEntity {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        #[derive(Deserialize)]
        #[serde(rename_all = "camelCase")]
        struct Helper {
            id: i64,
            password: String,
            name: String,
            email: Option<String>,
            phone: Option<String>,
            language: Option<String>,
            avatar: String,
            allow_add_friend: String,
            gender: String,
            user_type: String,
            profile_fields: HashMap<String, String>,
            create_time: i64,
            update_time: i64,
            version: i32,
        }

        let helper = Helper::deserialize(deserializer)?;

        // 转换枚举字符串为对应的i32值
        let allow_add_friend = match helper.allow_add_friend.as_str() {
            "AllowAll" => 0,
            "RequireApproval" => 1,
            "DenyAll" => 2,
            _ => return Err(serde::de::Error::custom("invalid AddFriendPolicy value")),
        };

        let gender = match helper.gender.as_str() {
            "Unspecified" => 0,
            "Male" => 1,
            "Female" => 2,
            "Other" => 3,
            _ => return Err(serde::de::Error::custom("invalid Gender value")),
        };

        let user_type = match helper.user_type.as_str() {
            "Regular" => 0,
            "Admin" => 1,
            "Guest" => 2,
            _ => return Err(serde::de::Error::custom("invalid UserType value")),
        };

        Ok(ClientEntity {
            id: helper.id,
            password: helper.password,
            name: helper.name,
            email: helper.email,
            phone: helper.phone,
            language: helper.language,
            avatar: helper.avatar,
            allow_add_friend,
            gender,
            user_type,
            profile_fields: helper.profile_fields,
            create_time: helper.create_time,
            update_time: helper.update_time,
            version: helper.version,
        })
    }
}

// 序列化实现：将枚举转换为字符串名称（如"Mobile"）
impl Serialize for DeviceType {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        let name = match self {
            DeviceType::DeviceUnknown => "DeviceUnknown",
            DeviceType::Mobile => "Mobile",
            DeviceType::Desktop => "Desktop",
            DeviceType::Web => "Web",
            DeviceType::All => "All",
        };
        serializer.serialize_str(name)
    }
}

// 反序列化实现：从字符串解析为枚举
impl<'de> Deserialize<'de> for DeviceType {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        match s.as_str() {
            "DeviceUnknown" => Ok(DeviceType::DeviceUnknown),
            "Mobile" => Ok(DeviceType::Mobile),
            "Desktop" => Ok(DeviceType::Desktop),
            "Web" => Ok(DeviceType::Web),
            "All" => Ok(DeviceType::All),
            _ => Err(serde::de::Error::custom(format!(
                "无效的DeviceType值: {}",
                s
            ))),
        }
    }
}
