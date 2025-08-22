use std::collections::HashMap;
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use serde::ser::SerializeStruct;
use crate::grpc::client_service::ClientEntity;

pub mod online_service;
pub mod online_service_impl;
pub mod client_service;
pub mod client_service_impl;

