#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct CardRuling {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub ruling_text: String,
    pub published_at: String,
    pub source: String,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CardRulingCreateRequest {
    pub ruling_text: String,
    pub published_at: String,
    pub source: String,
    pub card_id: i64,
}
