#[derive(Debug, Clone, Default)]
pub struct DatabaseConfig {
    /// Optional absolute path to the SQLite database file.
    pub path: Option<String>,
}
