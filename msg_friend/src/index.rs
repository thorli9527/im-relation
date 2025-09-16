#[cfg(feature = "tantivy")]
pub mod friend_index {
    use std::path::Path;
    use tantivy::{Index, schema::{Schema, SchemaBuilder, TEXT, STORED, FAST}, Document};
    use anyhow::Result;
    use crate::dao::EncryptedMessageRecord;

    pub struct Indexer {
        index: Index,
        f_msg_id: tantivy::schema::Field,
        f_sender_id: tantivy::schema::Field,
        f_receiver_id: tantivy::schema::Field,
        f_timestamp: tantivy::schema::Field,
        f_key_id: tantivy::schema::Field,
    }

    impl Indexer {
        pub fn open_or_create<P: AsRef<Path>>(path: P) -> Result<Self> {
            let mut sb = SchemaBuilder::new();
            let f_msg_id = sb.add_i64_field("msg_id", FAST | STORED);
            let f_sender_id = sb.add_i64_field("sender_id", FAST);
            let f_receiver_id = sb.add_i64_field("receiver_id", FAST);
            let f_timestamp = sb.add_i64_field("timestamp", FAST);
            let f_key_id = sb.add_text_field("key_id", TEXT);
            let schema: Schema = sb.build();
            let index = if path.as_ref().exists() { Index::open_in_dir(&path)? } else { Index::create_in_dir(&path, schema.clone())? };
            Ok(Self { index, f_msg_id, f_sender_id, f_receiver_id, f_timestamp, f_key_id })
        }

        pub fn index_record(&self, rec: &EncryptedMessageRecord) -> Result<()> {
            let mut doc = Document::default();
            doc.add_i64(self.f_msg_id, rec.msg_id);
            doc.add_i64(self.f_sender_id, rec.sender_id);
            doc.add_i64(self.f_receiver_id, rec.receiver_id);
            doc.add_i64(self.f_timestamp, rec.created_at);
            doc.add_text(self.f_key_id, &rec.key_id);
            let mut writer = self.index.writer(10_000_000)?;
            writer.add_document(doc);
            writer.commit()?;
            Ok(())
        }
    }
}

