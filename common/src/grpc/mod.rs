pub mod grpc_hot_friend;
pub mod grpc_hot_group;
pub mod grpc_hot_online;
pub mod grpc_msg_friend;
pub mod grpc_msg_group;
pub mod grpc_socket;
pub mod message;

use dashmap::DashMap;
use futures::future::BoxFuture;
use std::future::Future;
use std::sync::Arc;
use tokio::sync::OnceCell;

pub struct GrpcClientManager<C, E> {
    factory: Arc<dyn Fn(String) -> BoxFuture<'static, Result<C, E>> + Send + Sync>,
    clients: DashMap<String, Arc<OnceCell<Arc<C>>>>,
}

impl<C, E> GrpcClientManager<C, E>
where
    C: Send + Sync + 'static,
    E: Send + 'static,
{
    pub fn new<F, Fut>(factory: F) -> Self
    where
        F: Fn(String) -> Fut + Send + Sync + 'static,
        Fut: Future<Output = Result<C, E>> + Send + 'static,
    {
        let factory = Arc::new(move |addr: String| -> BoxFuture<'static, Result<C, E>> {
            Box::pin(factory(addr))
        });
        Self {
            factory,
            clients: DashMap::new(),
        }
    }

    pub async fn get(&self, addr: &str) -> Result<Arc<C>, E> {
        let entry = self
            .clients
            .entry(addr.to_string())
            .or_insert_with(|| Arc::new(OnceCell::new()));
        let cell = entry.value().clone();
        let factory = self.factory.clone();
        let addr_owned = addr.to_string();

        let client = cell
            .get_or_try_init(|| {
                let factory = factory.clone();
                let addr = addr_owned.clone();
                async move {
                    let created = factory(addr).await?;
                    Ok::<Arc<C>, E>(Arc::new(created))
                }
            })
            .await?
            .clone();

        Ok(client)
    }

    pub fn invalidate(&self, addr: &str) {
        self.clients.remove(addr);
    }

    pub fn clear(&self) {
        self.clients.clear();
    }
}

impl<C, E> Clone for GrpcClientManager<C, E> {
    fn clone(&self) -> Self {
        Self {
            factory: Arc::clone(&self.factory),
            clients: self.clients.clone(),
        }
    }
}
