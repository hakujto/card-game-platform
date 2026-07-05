#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct DeckTag {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub slug: Option<String>,
    pub color: Option<String>,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckTagCreateRequest {
    pub name: String,
    pub slug: Option<String>,
    pub color: Option<String>,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckTagUpdateRequest {
    pub name: Option<String>,
    pub slug: Option<String>,
    pub color: Option<String>,
}
